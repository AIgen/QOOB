function Results = collateResults(varargin)
    Results = varargin{1}; 
    confMethods = varargin{2}; 
    outFile = varargin{3};
    
    if length(varargin) == 3
        timeInfo = {};
    else 
        timeInfo = varargin{4}; 
    end
    
    confMethod = confMethods(1);
    E = Results.(confMethod{1}).numExperiments;
    
    for j = 1:numel(confMethods)
        confMethod = confMethods(j);
        assert(Results.(confMethod{1}).numExperiments == E);
        if(E > 1)
            Results.(confMethod{1}).totalVarLength = (E/(E-1)) * ...
                (Results.(confMethod{1}).totalVarLength/E - ...
                (Results.(confMethod{1}).totalMeanLength/E)^2);
            Results.(confMethod{1}).totalVarNumber = (E/(E-1)) * ...
                (Results.(confMethod{1}).totalVarNumber/E - ...
                (Results.(confMethod{1}).totalMeanNumber/E)^2);
            Results.(confMethod{1}).totalVarCoverage = (E/(E-1)) * ...
                (Results.(confMethod{1}).totalVarCoverage/E - ...
                (Results.(confMethod{1}).totalCoverage/E)^2);
        else 
            Results.(confMethod{1}).totalVarLength = 0; 
            Results.(confMethod{1}).totalVarNumber = 0; 
            Results.(confMethod{1}).totalVarCoverage = 0; 
        end
        Results.(confMethod{1}).totalCoverage = ...
            Results.(confMethod{1}).totalCoverage/E;
        Results.(confMethod{1}).totalMeanLength = ...
            Results.(confMethod{1}).totalMeanLength/E;
        Results.(confMethod{1}).totalMeanNumber = ...
            Results.(confMethod{1}).totalMeanNumber/E;
        Results.(confMethod{1}).totalMultiple = ...
            Results.(confMethod{1}).totalMultiple/E;
        Results.(confMethod{1}).totalEmpty = ...
            Results.(confMethod{1}).totalEmpty/E;
        if(~isempty(timeInfo))
            Results.(confMethod{1}).averageTime = 0; 
            for i = 1:E
                Results.(confMethod{1}).averageTime = ...
                    Results.(confMethod{1}).averageTime + timeInfo{i, 1}.(confMethod{1});
            end
            Results.(confMethod{1}).averageTime = Results.(confMethod{1}).averageTime/E;
        end
    end

    fileID = fopen(outFile,'w');
    dataDisp = zeros(numel(confMethods), numel(fieldnames(Results.(confMethods{1}))) - 1);
    fields = fieldnames(Results.(confMethods{1}));
    fprintf(fileID, 'Method        Coverage  Var(<--)    Length   Var(<--)\n');
    fieldsOutput = pad(confMethods, 14);
    
    for j = 1:numel(confMethods)
        confMethod = confMethods(j);
        fprintf(fileID, " %s", fieldsOutput{j});
        for i = 1:4 
          dataDisp(j, i) = Results.(confMethod{1}).(fields{i});
          fprintf(fileID, "%1.4f    ", dataDisp(j, i));
        end
        if(~isempty(timeInfo))
          fprintf(fileID, "%1.4f    ", Results.(confMethod{1}).averageTime);
        end
        fprintf(fileID, "\n");
    end
    fclose(fileID);
end
