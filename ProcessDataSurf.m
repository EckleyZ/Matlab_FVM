function ProcessDataSurf(Data,P,t)

%initialize needed variables
dMax = max(Data);
dMin = min(Data);

%loop through and find color of each node
C = zeros(size(P,2),1);
for v = 1:size(P,2)
    C(v) = (Data(:,v)-dMin)/(dMax-dMin);
%     cp = (Data(:,v)-dMin)/(dMax-dMin)/2;
%     C(v,:) = [0.5-cp, 0.5-cp, 1]; 
end


patch('vertices',[P; Data]','faces',t','edgecol','none','FaceVertexCData',C,'facecolor','interp');
xlabel('X axis');
ylabel('Y axis');
view(30,30);
axis tight;
end