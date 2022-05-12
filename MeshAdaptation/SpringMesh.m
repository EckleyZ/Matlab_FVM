%Spring Mesh Adaptation
clear;
close all;
format long;
clc;

%create mesh
theta = 0:359;
r = 1+0.3*cosd(8*theta);
x1 = r.*cosd(theta);
y1 = r.*sind(theta);
% x1 = [linspace(0,10,51), 5];
% y1 = [linspace(-5,5,51).^2, 25]/5;


% theta = 0:4:360;
% r1 = 1+0.3*cosd(8*theta);
% x1 = r1.*cosd(theta);
% y1 = r1.*sind(theta);
model = MakeMesh(x1,y1,4,0,0);

%identify boundary points
if model.Geometry.NumEdges==1
    bI = sort(findNodes(model.Mesh,'region','Edge',1));
else
    bI = sort(findNodes(model.Mesh,'region','Edge',1:model.Geometry.NumEdges));
end
bP = model.Mesh.Nodes(:,bI)';
% hold on
% scatter(model.Mesh.Nodes(1,bI),model.Mesh.Nodes(2,bI),30,'g','filled');

%find vertex connections
[Vc,Xj,Yj,Lx,Ly] = MeshDetails(model.Mesh);
k = 10^6;   %spring constant
m = 1;      %mass of each vertex
C = k/m;    %Constant in spring equation
g = sqrt(4*k*m);
RealConn = Vc~=0;

%Move Boundary points in some way
func = @(x) ((x-4).^2.*(x-6).^2)/115.2;
[p,e,t] = meshToPet(model.Mesh);
% mod = findNodes(model.Mesh,'region','Edge',1:model.Geometry.NumEdges);
mod = findNodes(model.Mesh,'region','Edge',1);
%p(2,mod) = func(p(1,mod));
theta = atan2(p(2,mod),p(1,mod));
p(1,mod) = cos(theta).*(1.5+0.15*cos(8*theta));
p(2,mod) = sin(theta).*(1.5+0.15*cos(8*theta));
figure();
pdeplot(p,e,t);

%apply spring equatin stuff and find new positions
w0 = zeros(4*size(p,2),1);
w0(1:4:end) = p(1,:)';
w0(2:4:end) = p(2,:)';

Eqn = @(t,w) ddt(t,w,Vc,bI,Lx,Ly,C,g,size(Vc,2));

%% solve
es = 10^-4;
figure('WindowState','maximized');
steps = 0;
totalSteps = 0;
tStep = 0.0005;
Xr = [min(p(1,:)), max(p(1,:))]*1.1;
Yr = [min(p(2,:)), max(p(1,:))]*1.1;
ds = 2*Xr;

i = 0;
filename = 'SpringMeshTest.gif';
%begin loop
Balance = 0;
while Balance==0
    %complete another time step
    [T,Y] = ode45(Eqn,[0 tStep],w0);
    i = i+1;
    
    %find if system has reached equilibrium
    if steps>0
        ds = max(vecnorm([Y(end,1:4:end)-oldY(1:4:end); Y(end,2:4:end)-oldY(2:4:end)],2,1));
        if ds<es
            Balance = 1;
        end
    end
    
    %update loop info
    oldY = Y(end,:);
    steps = steps+1;
    totalSteps = totalSteps+size(Y,1);
    w0 = Y(end,:)';
    
    %update plot
    clf;
    p2 = [Y(end,1:4:end); Y(end,2:4:end)];
    pdeplot(p2,e,t);
    title(sprintf('Time = %0.2f seconds | %d Total Steps',steps*tStep, totalSteps));
    grid off
    axis equal
    xlim(Xr);
    ylim(Yr);
    
    pause(0.01);
    if steps==1
        uiwait(msgbox('click to continue'));
    end

    frame = getframe(2);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    if i == 1
        imwrite(imind,cm,filename,'gif', 'Loopcount',inf);
    else
        imwrite(imind,cm,filename,'gif','WriteMode','append');
    end
end

newX = Y(end,1:4:end);
newY = Y(end,2:4:end);

newMesh = MakeMesh(newX(mod),newY(mod),4,0,1);




