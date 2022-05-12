function nodeData = Cell2Node(Data,varNum,N,E)

%break Data into sets based on varNum

R = size(Data,1);
C = size(N,2);

nodeData = cell(varNum,1);

%find which cells contain which nodes
Cn = cell(C,1);
for v = 1:C
    cells = find(sum(v==E,1)==1);
    Cn{v} = cells;
end

for Var = 1:varNum
    %update user
    vmsg = sprintf('Variable %d of %d',Var,varNum);
    fprintf('%s',vmsg);
    
    %iniitalize matrices
    nData = zeros(R,C);
    DataSet = Data(:,Var:varNum:end);
    
    %convert cell centered solution to node based
    for r = 1:R
        %transofrm data from cell based to nodal
        for v = 1:C
            cells = Cn{v};
            shared = max([1,numel(cells)]);
            nData(r,v) = sum(DataSet(r,cells),2)/shared;
        end
    end
    
    %place nData matrix into node Data cell
    nodeData{Var} = nData;
    
    %clear update statements
    fprintf(repmat('\b',1,numel(vmsg)));
end
end