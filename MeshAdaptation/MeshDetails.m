function [Vc,Xj,Yj,LX,LY] = MeshDetails(mesh)
    
n = max(max(mesh.Elements));
Vc = cell(n,1);
EL = cell(n,2);

%find the indices of the boundary points

for v = 1:n
    Vertices = mesh.Elements(:,logical(sum(mesh.Elements==v,1)));
    Vc{v} = unique(Vertices(Vertices~=v))';
    if v==1
        MaxConn = numel(Vc{v});
    elseif MaxConn<numel(Vc{v})
        MaxConn = numel(Vc{v});
    end
    EL{v,1} = mesh.Nodes(1,v)-mesh.Nodes(1,Vc{v});
    EL{v,2} = mesh.Nodes(2,v)-mesh.Nodes(2,Vc{v});
end
%rearrange Vc and EL to be matrices and not
oldVc = Vc;
Vc = zeros(n,MaxConn);
LX = zeros(n,MaxConn);
LY = zeros(n,MaxConn);
Xj = zeros(n,MaxConn);
Yj = zeros(n,MaxConn);
for v = 1:n
    c = MaxConn-numel(oldVc{v});
    Vc(v,:) = [oldVc{v} zeros(1,c)];
    Xj(v,:) = [mesh.Nodes(1,oldVc{v}), zeros(1,c)];
    Yj(v,:) = [mesh.Nodes(2,oldVc{v}), zeros(1,c)];
    LX(v,:) = [EL{v,1}, zeros(1,c)];
    LY(v,:) = [EL{v,2}, zeros(1,c)];
end