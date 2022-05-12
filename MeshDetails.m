function [EL,Vc] = MeshDetails(mesh)
    
n = size(mesh.Elements,2);
Vc = cell(n,1);

for v = 1:n
    Vertices = mesh.Elements(:,logical(sum(mesh.Elements==v,1)));
    Vc{v} = Vertices(unique(Vertices(:))~=v);
    EL = vecnorm(mesh.Nodes(:,v)-mesh.Nodes(:,Vc{v}),2,1);
end
    

end