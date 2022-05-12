function ProcessDataTri(Data,P,t)

%loop through and create individual triangles
n = size(t,2);
X = zeros(3,n);
Y = X;  Z = X;
C = zeros(n,1);

dMax = max(Data);
dMin = min(Data);
for I = 1:n
    X(:,I) = P(1,t(:,I));
    Y(:,I) = P(2,t(:,I));
    Z(:,I) = Data(I);
    
    C(I) = (Data(I)-dMin)/(dMax-dMin);
end
patch(X,Y,Z,C','facecolor','flat');
xlabel('X axis');
ylabel('Y axis');
view(30,30);

end