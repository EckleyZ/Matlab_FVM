function ShowSaveData(Filename,VarNames,SolType,model,Data,time)

%load file
if isempty(Filename)==0
    fprintf('Loading File...\n');
    load(Filename,'Data','model','time');
    clc;
end


%check if the time variable exists
if exist('time','var')==0
    tStep = 0.01;
    time = tStep:tStep:tStep*size(Data,2);
else
    tStep = mean(diff(time));
    if numel(time)>size(Data,1)
        time = time(2:end);
    end
end

E = model.Mesh.Elements(1:3,:);
N = model.Mesh.Nodes(:,1:max(max(E)));

%break Data into 3 parts
R = size(Data,1);


if SolType==1   %Cell Centered Solution
    Zmax = max(max(Data(:,1:3:end)));
    % Zmin = min(min(Data(:,1:3:end)));
else            %Nodal Solution
    fprintf('Converting Cell Solution to Nodal Solution\n');
    %create list of nodes belong to which cell
    nodeData = Cell2Node(Data,numel(VarNames),N,E);
end

clc;
fprintf('Complete!\n');

%user selects which variable they would like to see
DispVar = menu('Select the variable to be displayed',VarNames);
if SolType==1
    Display = Data(:,DispVar:numel(VarNames):end);
else
    Display = nodeData{DispVar};
    Zmax = max(max(Display));
end

%create window
figure('WindowState','Maximized');
colormap jet

%provide msgbox so user can move window where they want it
uiwait(msgbox('Click ''ok'' when you are ready to proceed'));

%find start point so last frame is the last row of data
skip  = 10;
if mod(size(Data,1),skip)==0
    Start = skip;
else
    Start = mod(size(Data,1),skip);
end

%animation loop
colormap hot
filename = 'SimulationResults.gif';
for f = Start:skip:R
    clf;
    ProcessDataSurf(Display(f,:),N,E);
    title(sprintf('Time = %0.5f seconds',time(f)));
    newZmax = max(max(Display(f,:)));
    Zmax = max([newZmax, (9*Zmax+max(max(Display(f,:))))/10]);
    axis equal;
    xlim([-9,60]);
    %zlim([0, Zmax]);
    zlim([0, 0.8]);
    view(0,90);
    pause(tStep);

    frame = getframe(1);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    if f == Start
        imwrite(imind,cm,filename,'gif', 'Loopcount',inf);
    else
        imwrite(imind,cm,filename,'gif','WriteMode','append');
    end
end
stop = 1;
end


    
