%MAIN
clear
close all
clc
format long

%create geometry
%Dimaond Wedge
x = {[-12 60 60 -12], [linspace(-6,0,100), linspace(0,6,100), linspace(6,0,100), linspace(0,-6,100)]};
y = {[15 15 -15 -15], [linspace(0,0.6,100), linspace(0.6,0,100), linspace(0,-0.6,100), linspace(-0.6,0,100)]};
% t = 15;
% DCM = [cosd(t), -sind(t); sind(t), cosd(t)];
% rotated = [x{2};y{2}]'*DCM;
% x{2} = rotated(:,1);
% y{2} = rotated(:,2);
%Nozzle
% x = [-20:30, 30:-1:-20];
% y = [15*ones(1,21), linspace(15,9,30), linspace(-9,-15,30), -15*ones(1,21)];
%blunt edge
% x = [-20 30 30 0 0 -20];
% y = [10 10 -6 -6 -10 -10];
%lunar Capsule
% x = {[-33 70 70 -33], [1.5*cos(pi/2:pi/64:3*pi/2), 6 6]};
% y = {[30 30 -30 -30], [6*sin(pi/2:pi/64:3*pi/2), -2 2]};
%SR-71 Blackbird
% x = {[-50 350 350 -50], [30*cos(pi/2:pi/64:3*pi/2)+30, 31:179, 20*cos(-pi/2:pi/64:pi/2)+180, 180, 153, 135, 134:-1:51, 20*cos(pi/2:pi/64:(63*pi/64))+50]};
% y = {[120 120 -120 -120], [3*sin(pi/2:pi/64:3*pi/2), -3*ones(1,149), 3*sin(-pi/2:pi/64:0), 3*sin(pi/64:pi/64:pi/2), 19, 19, 7, 7*ones(1,84), 4*sin(pi/2:pi/64:(63*pi/64))+3]};

if isa(x,'cell')
    xM = zeros(1,numel(x));
    xm = zeros(1,numel(x));
    yM = zeros(1,numel(y));
    ym = zeros(1,numel(y));
    for c = 1:numel(x)
        xM(c) = max(x{c});
        xm(c) = min(x{c});
        yM(c) = max(y{c});
        ym(c) = min(y{c});
    end
    maxX = max(xM);
    minX = min(xm);
    maxY = max(yM);
    minY = min(ym);
else
    maxX = max(x);
    minX = min(x);
    maxY = max(y);
    minY = min(y);
end

model = MakeMesh(x,y,4,1,1);
set(gca,'visible','off');
axis equal;

%% BOUNDARY SETUP & MESH DETAILS

%select edges to be an outlet inlet or wall
[bType, oN, iN, wN, bConds] = setupBoundaries(model);
fprintf('Boundary Conditions Set\n');

%find mesh details
[Cj,N,S,A,cC] = meshInfo(model.Mesh,oN,iN);
fprintf('\nMesh Details Created\n\n');


%% SOLVE SYSTEM

%Establish initial Conditions
k = 1.4;
R = 287;
Vel = 0*343;
cv = R/(k-1);
cp = (k*R)/(k-1);
T = 288.15;
rho = 1.225;
E = cv*T + Vel^2/2;
H = cp*T + Vel^2/2;
y0 = repmat([rho,rho*Vel,0,rho*E]',size(model.Mesh.Elements,2),1);

%Create ode45 function
%Eqn = @(t,y) ddtAir(t,y,Cj,N,A,bConds,k,totalTime);

%create time step and time span
tStep = 2.5e-3;
tspan = [0 tStep];
Tspan = [0 5];
Steps = ceil(Tspan(2)/tStep);

%initialize other variables
Data = zeros(Steps,length(y0));
IniConds = y0;
es = 10^-6;
ea = zeros(Steps,1);
for t = 1:Steps
    %solve with ODE Integrator
    Eqn = @(t,y) ddtAir(t,y,Cj,N,A,bConds,k,t*tStep);
    [T,Y] = ode45(Eqn,tspan,IniConds);
    Data(t,:) = Y(end,:);
    
    %make new "initial" conditions
    IniConds = Y(end,:);
    
    %print update
    if t>1
        fprintf(repmat('\b',1,numel(msg)));
    end
    msg = sprintf('Time step %d of %d\n',t,Steps);
    fprintf('%s',msg);
    
    %plot update
    clf;
    ProcessDataTri(Data(t,1:4:end),model.Mesh.Nodes,model.Mesh.Elements(1:3,:));
    view(0,90);
    axis equal
    xlim([minX, maxX]);
    ylim([minY, maxY]);
    title(sprintf('Density Plot: Time step %d of %d',t,Steps));
    pause(0.01);
    
    %check error
    if t>1
        ea(t) = max(abs(Data(t,:)-Data(t-1,:)))/tStep;
    end
    if t>5
        if ea(t)<es
            %check previous 4 time steps
            eA = max(ea(t-4:t))./tStep;
            if eA<es
                fprintf('Steady state has been reached. Exiting solver.\n');
                rowNum = size(Data,1)-t;
                Data(t+1:end,:) = repmat(Data(t,:),rowNum,1);
                break
            end
        end
    end
end


%% POST PROCESSING

%play in a movie

%gather info on the variables from the user
% info = inputdlg('Number of Variables','Input Variable Number',[1 20]);
% prompt = num2str((1:str2double(info))');
% prompt = num2cell(strcat(repmat("Var ",numel(prompt),1),prompt," Name"));
% VarNames = inputdlg(prompt,'Input Variable Names',[1 40]);
VarNames = {'Density','X Vel.','Y Vel.','Internal Energy'};
ShowSaveData('',VarNames,2,model,Data,tStep:tStep:Tspan(2));
stop = 1;

%save the thing if it works
%save(file stuff)

