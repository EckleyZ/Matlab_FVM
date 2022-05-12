function [bType, oN, iN, wN, bConds] = setupBoundaries(model)
%allows user to select the type of boundary for each edge of the 2D mesh.
%If there are any inlets the user also sets the flow rate of the inlet


figure('WindowState','maximized');
pdegplot(model,'EdgeLabels','on');
title({'Model Geometry With Edge Labels', ''});
axis equal;
set(gca,'XTick',[],'YTick',[]);
bType = zeros(model.Geometry.NumEdges,1);
for E = 1:model.Geometry.NumEdges
    msg = sprintf('Select boundary type for E%d',E);
    type = menu(msg,'Outlet','Inlet','Wall');
    bType(E) = type;
end

%find outlet nodes
oN = findNodes(model.Mesh,'region','edge',find(bType==1));
%find inlet nodes
iN = findNodes(model.Mesh,'region','edge',find(bType==2));
%find wall nodes
wN = findNodes(model.Mesh,'region','edge',find(bType==3));

%user specified minimum height for outlet
prompt = {'Min Outlet Height (0 for none)','max Outlet Flow Rate (0 for none)'};
dlgtitle = 'Specify Inlet Conditions';
dims = [1 50];
definput = {'0','0'};
info = inputdlg(prompt,dlgtitle,dims,definput);
bConds(1,1) = str2double(info{1});
bConds(2,1) = str2double(info{2});

%user specified inlet flow rate
prompt = {'Max Inlet Height (0 for none)','Inlet flow rate'};
dlgtitle = 'Specify Inlet Conditions';
dims = [1 50];
definput = {'8','0.1'};
info = inputdlg(prompt,dlgtitle,dims,definput);
bConds(1,2) = str2double(info{1});
bConds(2,2) = str2double(info{2});

%hard Coded boundary conditions
R = 287;
k = 1.4;
cp = (k*R)/(k-1);
rho = 1.225;
Vel = 5*343;
%Vel = @(t) min(34.3*(t.^0.8)+343,7*343);
T = 288.15;
P = rho*R*T;
H = cp*T + Vel.^2/2;
bConds = [rho, Vel, P, H; rho, Vel, P, H]';

end

