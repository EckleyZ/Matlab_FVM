function y0 = InitialConditions(mesh,cC)

type = menu('Select intiial condition','Water droplet','Tilted','Wave');

n = size(mesh.Elements,2);

y0 = zeros(3,n);
switch type
    case 1
        height = max(max(mesh.Nodes))+1;
        Z = @(x,y) (25*height./(1+2*(x.^2+y.^2)))+1;
    case 2
        height = max(max(abs(mesh.Nodes)));
        Z = @(x,y) 0.4*x+0*y+0.4*height;
    case 3
        %later
        Z = @(x,y) 1;
end
x = cC(1,:)';
y = cC(2,:)';
y0(1,:) = Z(x,y);
y0 = y0(:);
end