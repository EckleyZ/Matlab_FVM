function model = MakeMesh(x,y,DetailLevel,Adaptive,ShowPlot)

%make shape from x and y
model = createpde();
warning off
shp = polyshape(x,y,'Simplify',0);

tr = triangulation(shp);
p = tr.Points';
t = tr.ConnectivityList';
geometryFromMesh(model,p,t);

%find max dimension for mesh generation
if isa(x,'cell')
    xb = zeros(1,numel(x));
    yb = zeros(1,numel(y));
    for c = 1:numel(x)
        xb(c) = max(abs(x{c}));
        yb(c) = max(abs(y{c}));
    end
    maxB = max(max(xb),max(yb));
else
    maxB = max(max(x),max(y));
end

if Adaptive==1
    Scale = [10 50; 10 100; 15 150; 20 200; 30 300; 40 400; 50 500];
    Grad = 1.05;
else
    Scale = [8 10; 12 15; 20 24; 30 35; 42 48; 70 75; 125 150];
    Grad = 1.2;
end
ds = Scale(DetailLevel,:);

%generate mesh
generateMesh(model,'Hmax',maxB/ds(1),'Hmin',maxB/ds(2),'Hgrad',Grad,'GeometricOrder','linear');

%plot if you want to see it
if ShowPlot==1    
    figure();
    pdeplot(model);
    axis equal;
%     uiwait(msgbox('Click ok to continue'));
end

q = meshQuality(model.Mesh);
minQ = min(q);
maxQ = max(q);
meanQ =mean(q);
Q95 = sum(q>=0.95)/numel(q)*100;

%print mesh information
fprintf('  ~~~ MESH INFO ~~~\n');
fprintf('    # of nodes ~ %d\n',max(max(model.Mesh.Elements(1:3,:))));
fprintf('    # of cells ~ %d\n',size(model.Mesh.Elements,2));
fprintf(' Avg cell qual ~ %0.3f\n',meanQ);
fprintf(' Max cell qual ~ %0.3f\n',maxQ);
fprintf(' Min cell qual ~ %0.3f\n',minQ);
fprintf(' Cell q >=0.95 ~ %0.3f%%\n\n\n',Q95);
warning on
end