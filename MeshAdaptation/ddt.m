function dwdt = ddt(t,w,Vc,bI,Lx,Ly,C,g,col)
%This function creates a series of ODEs using the spring equation.
%
% INPUTS:
%    w - Initial/current conditions of the system listed in order as
%        follows:
%             x1
%             y1
%            vx1
%            vy1
%             x2
%             y2
%            vx2
%            vy2
%             .
%             .
%             .
%             xn
%             yn
%            vxn
%            vyn
%   Lx - Initial lengths in x of the connections between vertices
%   Ly - Initial Lengths in y of the connections between vertices
%    C - Spring eqation constant (k/m) where k is the spring constant and m
%        is mass
%    g - Damping ratio for the system
%  col - number of columns required for this system. This number represents
%        the maximum number of connections that any of the vertices has
%
% OUPUTS:
%   dwdt - change in the conditions used to find conditions for new time
%          step


Xi = w(1:4:end);
Yi = w(2:4:end);
Xj = repmat(Xi,1,col);
Yj = repmat(Yi,1,col);
Xj(Vc~=0) = Xi(Vc(Vc~=0));
Yj(Vc~=0) = Yi(Vc(Vc~=0));
dx = Xj-Xi;
dy = Yj-Yi;

dwdt = w*0;
dwdt(1:4:end) = w(3:4:end);
dwdt(2:4:end) = w(4:4:end);
dwdt(3:4:end) = -g*w(3:4:end)-C*sum(Lx-dx,2);
dwdt(4:4:end) = -g*w(4:4:end)-C*sum(Ly-dy,2);

%remove any movement for the boundary points
boundary = (bI-1)*4+(1:4)';
dwdt(boundary(:)) = 0;
if sum(isnan(dwdt))>0 || sum(imag(dwdt))>0
    stop = 1;
end
