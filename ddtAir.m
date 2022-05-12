function dwdt = ddtAir(t,w,Cj,N,A,bConds,k,totalTime)
%   DESCRIPTION:
% This function utilizes finite volume method with triangular mesh cells to 
% solve the 2D compressible Navier-Stokes equations. This function should
% be paired to a function handle to keep all inputs after w constant
% throughout calculation. An example is shared below.
%   Example:
%
%   Eqns = @(t,y) ddtAir(t,y,Cj,N,A,bConds,k)
%
%   Prior to creating the Eqns function handle the variables Cj, N, A,
%   bConds, and k should have already been defined. Because the function
%   handle only requires t and y as input variables the other inputs will
%   be kept constant whenever the function handle is called.
%
%   INPUTS:
%       t - current time in the ode45 solver. Can be used to define
%           boundary conditions if the user input a function handle rather
%           than a constant value
%       w - Current conditions of the flow field. Inputs are given in the
%           following order:
%               rho of cell 1
%              rhou of cell 1
%              rhov of cell 1
%              rhoE of cell 1
%               rho of cell 2
%              rhou of cell 2
%              rhov of cell 2
%              rhoE of cell 2
%                .  .  .  .
%                .  .  .  .
%                .  .  .  .
%                .  .  .  .
%               rho of cell N
%              rhou of cell N
%              rhov of cell N
%              rhoE of cell N
%      Cj - a 3xN matrix containing the cells that share sides with cell i.
%           If the value is negative the side is a boundary side. Depending
%           on the negative value the type of boundary changes.
%               -1 = Outlet
%               -2 = Inlet
%               -3 = Wall
%       N - a 3xNx3 matrix containing the normals of all 3 sides of every
%           cell
%       A - a 1XN array containing the area of each cell
%  bConds - a matrix, array, or cell array containing the information for
%           each boundary type. 
%       k - The specific heat ratio of the gas being analyzed (typically
%           1.4 for air)
%
% OUTPUTS:
%   dwdt - the change in each property ofe every cell. The output is a
%          column vector following this pattern:
%        drho of cell 1
%       drhou of cell 1
%       drhov of cell 1
%       drhoE of cell 1
%        drho of cell 2
%       drhou of cell 2
%       drhov of cell 2
%       drhoE of cell 2
%           .  .  .  .
%           .  .  .  .
%           .  .  .  .
%           .  .  .  .
%        drho of cell N
%       drhou of cell N
%       drhov of cell N
%       drhoE of cell N
%
% Functions used:
%   ode45
%   repmat
%   permute
%   reshape
%   dot
%   cross
%   vecnorm
%   abs
%   size
%   sqrt
%   (:) turns matrix to column vector
%   trnaspose notation (')


% clc;
% t

%% PROCESS AND ORGANIZE INCOMING DATA

%split input conditions into properties for flux
rho = w(1:4:end);
u = w(2:4:end)./rho;
v = w(3:4:end)./rho;
E = w(4:4:end)./rho;
P = (k-1)*rho.*(E-(u.^2+v.^2)/2);
H = E+P./rho;
Wi = [rho, u, v, E];

%define flux for each cell
Fx = [rho.*u, rho.*u.^2 + P, rho.*u.*v, rho.*u.*H];
Fy = [rho.*v, rho.*u.*v, rho.*v.^2 + P, rho.*v.*H];

%replicate Fx Fy Nx and Ny
Fx = repmat(Fx,1,1,3);
Fy = repmat(Fy,1,1,3);
Nx = repmat(permute(N(1,:,:),[2 1 3]),1,4,1);
Ny = repmat(permute(N(2,:,:),[2 1 3]),1,4,1);

%define inlet conditions
brho = bConds(1,1);
bVel = bConds(2,1);
bP = bConds(3,1);
bH = bConds(4,1);
bE = bH-bP/brho;


%% REPLACE FLUX ON SIDES SHARED WITH OTHER CELLS

%isolate sides that share another cell
Cjs = 0*Cj;
Cjs(Cj>0) = Cj(Cj>0);
Cjs = Cjs';

%initialize Fx2 Fy2
Fx2 = 0*Fx;
Fy2 = 0*Fy;

%find magnitude of N
n = vecnorm([Nx(:,1,:), Ny(:,1,:)],2,2);

%replace conditions of shared sides
Fx2(Cjs(:,1)~=0,:,1) = Fx(Cjs(Cjs(:,1)~=0,1),:,1);
Fx2(Cjs(:,2)~=0,:,2) = Fx(Cjs(Cjs(:,2)~=0,2),:,2);
Fx2(Cjs(:,3)~=0,:,3) = Fx(Cjs(Cjs(:,3)~=0,3),:,3);
Fy2(Cjs(:,1)~=0,:,1) = Fy(Cjs(Cjs(:,1)~=0,1),:,1);
Fy2(Cjs(:,2)~=0,:,2) = Fy(Cjs(Cjs(:,2)~=0,2),:,2);
Fy2(Cjs(:,3)~=0,:,3) = Fy(Cjs(Cjs(:,3)~=0,3),:,3);


%% REPLACE FLUX ON BOUNDARY SIDES

%OUTLET
Outlets = repmat(permute(Cj==-1,[2 3 1]),1,4,1);
Fx2(Outlets) = Fx(Outlets);
Fy2(Outlets) = Fy(Outlets);

%INLET
% bu = abs(bVel*Nx(:,1,:))./n;
% bv = abs(bVel*Ny(:,1,:))./n;
bVel = min(3.5*343*(totalTime),7*343);
bH = 1004.5*288.15 + bVel.^2/2;
bu = abs(bVel*Nx(:,1,:))./n;
bv = abs(bVel*Ny(:,1,:))./n;
iFx = [brho*bu, brho*bu.^2 + bP, brho*bu.*bv, brho*bu*bH];
iFy = [brho*bv, brho*bu.*bv, brho*bv.^2 + bP, brho*bv*bH];
inlets = repmat(permute(Cj==-2,[2 3 1]),1,4,1);
Fx2(inlets) = iFx(inlets);
Fy2(inlets) = iFy(inlets);

%WALL
walls = repmat(permute(Cj==-3,[2 3 1]),1,4,1);
emptySet = zeros(size(walls,1),size(walls,2),size(walls,3));
walls1 = boolean([emptySet(:,1,:), walls(:,2:4,:)]);
walls2 = boolean([walls(:,1,:), emptySet(:,2:4,:)]);
Fx2(walls1) = Fx(walls1);
Fy2(walls1) = Fy(walls1);
Fx2(walls2) = -Fx(walls2);
Fy2(walls2) = -Fy(walls2);
% Fx(walls) = 0;
% Fy(walls) = 0;
% Fx2(walls) = 0;
% Fy2(walls) = 0;
%flip sign of first column to cancel mass flux


%% CALCULATE NUMERICAL DISSIPATION FOR NEIGHBORING CELLS AND INLET
%On the outlet cells the conditions on the other side of the outlet are
%equal so Numerical dissipation will always be 0. As for the wall sides the
%conditions on the other side of the wall are unknown so numerical
%dissipation can't be calculated.

%caluclate wave speed for i cells
ws1 = abs(repmat(u,1,1,3).*Nx(:,1,:) + repmat(v,1,1,3).*Ny(:,1,:))./n + sqrt((k^2-k)*repmat(E,1,1,3));

%create array of conditions in cell i and cell j
Wj = repmat(0*Wi,1,1,3);

Wj(Cjs(:,1)~=0,:,1) = Wi(Cjs(Cjs(:,1)~=0,1),:);
Wj(Cjs(:,2)~=0,:,2) = Wi(Cjs(Cjs(:,2)~=0,2),:);
Wj(Cjs(:,3)~=0,:,3) = Wi(Cjs(Cjs(:,3)~=0,3),:);
%replace boundary sides in Wj with Wi
Wj(Cjs(:,1)==0,:,1) = Wi(Cjs(:,1)==0,:);
Wj(Cjs(:,2)==0,:,2) = Wi(Cjs(:,2)==0,:);
Wj(Cjs(:,3)==0,:,3) = Wi(Cjs(:,3)==0,:);
%replace inlet conditions
inW = [brho*ones(size(Wj,1),1,size(Wj,3)), bu, bv, bE*ones(size(Wj,1),1,size(Wj,3))];
Wj(inlets) = inW(inlets);

%calculate wave speed for j cells
uj = Wj(:,2,:);
vj = Wj(:,3,:);
Ej = Wj(:,4,:);
ws2 = abs(uj.*Nx(:,1,:) + vj.*Ny(:,1,:))./n + sqrt((k^2-k)*Ej);


%% CALCULATE Fi AND APPLY TO DWDT
Wi = repmat(Wi,1,1,3);
Ft1 = Fx.*Nx + Fy.*Ny;
Ft2 = Fx2.*Nx + Fy2.*Ny;
ws = repmat(max([ws1 ws2],[],2),1,4,1);
ws(imag(ws)~=0) = 0;
NumDiss = ws/2.*(Wi-Wj);
Fi = sum((Ft1 + Ft2)/2 + NumDiss,3);
% Fi = max(Ft1,Ft2);
% Fi(Wi>Wj) = min(Ft1(Wi>Wj),Ft2(Wi>Wj));
% Fi(walls2) = 0;
% Fi = sum(Fi + NumDiss,3);

%check for bad values
if sum(sum(sum(abs(imag(Fi)))))~=0 || sum(sum(sum(isnan(Fi))))~=0
    stop = 1;
end

dwdt = -Fi./repmat(A',1,4,1);
dwdt = dwdt';
dwdt = dwdt(:);


end