function [Cj,N,S,A,cC] = meshInfo(mesh,oN,iN)
%Finds necessary info for the given mesh
%
% INPUTS
%  mesh - mesh created from generateMesh (PDE toolbox)
%
% OUPUTS:
%  Cj - index of the cells neighboring cell i
%   N - normal of all three sides of each cell
%   S - side lengths for all 3 sides of every cell
%   A - Area of each cell
%  cC - cooridnates for each cell center

%set up loop
Cj = zeros(3,size(mesh.Elements,2));
N = zeros(3,size(mesh.Elements,2),3);
S = Cj;
A = zeros(1,size(mesh.Elements,2));
cC = zeros(2,size(mesh.Elements,2));

n = mesh.Nodes;
E = mesh.Elements(1:3,:);

%replicate oN and iN arrays for easier comparison
oN = [oN; oN];
iN = [iN; iN];

list = [1 2 3 1];
% sCorr = [1 0 1; 1 1 0; 0 1 1];

for T = 1:size(E,2)    
    %find centroid
    cC(:,T) = mean(n(:,E(:,T)),2);
    
    %create 2 vectors for cell area
    E1 = [n(:,E(3,T))-n(:,E(1,T)); 0];
    E2 = [n(:,E(2,T))-n(:,E(1,T)); 0];
    A(T) = 0.5*norm(cross(E1,E2));
    
    for j = 1:3
        %create vector for current side
        e1 = E(list(j),T);
        e2 = E(list(j+1),T);
        v1 = [n(:,e2)-n(:,e1); 0];
        
        %find side length
        S(j,T) = norm(v1);
        
        %find normal
        v2 = [0 0 1]*S(j,T);
        N(:,T,j) = cross(v1,v2);
        P1 = mean(n(:,[e1,e2]),2)+N(1:2,T,j);
        P2 = mean(n(:,[e1,e2]),2)-N(1:2,T,j);
        ds1 = norm(P1-cC(:,T));
        ds2 = norm(P2-cC(:,T));
        if ds2>ds1
            N(:,T,j) = -N(:,T,j);
        end
        nMag = norm(N(:,T,j));
        N(:,T,j) = N(:,T,j)*(S(j,T)/nMag);
%         N(:,T,j) = N(:,T,j)/nMag;
        
        
        %find cell neighboring current side
        match = find(sum((E(list(j),T)==E)+(E(list(j+1),T)==E),1)==2);
        match = match(match~=T);
        if isempty(match)
            if sum(sum(E(list(j:j+1),T)==oN))==2
                Cj(j,T) = -1;
            elseif sum(sum(E(list(j:j+1),T)==iN))==2
                Cj(j,T) = -2;
            else
                Cj(j,T) = -3;
            end
        else
            Cj(j,T) = match;
            
%             %find corresponding match              
%             (speeds things up but there are errors)
%             iE = repmat(E(1:3,T)',3,1); %ith elements
%             jE = repmat(E(1:3,match),1,3); %jth elements
%             mE = sum(jE==iE,2); %which indices match in jth cell
%             jMatch = (sum(sCorr==mE,1)==3)'; %side num for jth cell 
%                                              %matching ith cell
%             Cj(jMatch,match) = T;
        end
    end 
end
end
        
        
    
    
    
    
    
    
    
    
    
    