function [intervals, coverage] = OOB_crossConformal(XTrain, YTrain, XTest, YTest, nTrees, alpha)
    fprintf("Running OOB-CC with nTrees = %d, alpha = %d.\n", nTrees, alpha);
    NTrain = size(XTrain, 1); 
    NTest = size(XTest, 1); 
    
    mdl = TreeBagger(nTrees, XTrain, YTrain, 'Method', 'regression', 'OOBPrediction', 'on');
    if(sum(sum(mdl.OOBIndices, 2) > 0) < NTrain)
        fprintf("Some training points are not out of bag for any tree. Try increasing the number of trees.\n"); 
    end

    oobIndicesRepeated = reshape(repmat(mdl.OOBIndices', NTest, 1), nTrees, NTrain*NTest)'; 
    
    preds = predict(mdl, repmat(XTest, size(XTrain,1), 1), 'UseInstanceForTree', oobIndicesRepeated);
    YPredAll = reshape(preds, NTest, NTrain);
    
    trainRes = abs(oobPredict(mdl) - YTrain); 
    intervals = cell(NTest,1);
    ticks = zeros(2*NTrain, 2); 
    for i = 1:NTest
        tau = rand;
        ticks(1:NTrain, :) = [YPredAll(i,:)'-trainRes, ones(NTrain,1)];
        ticks((NTrain+1):(2*NTrain), :) = [YPredAll(i,:)'+trainRes, zeros(NTrain,1)];
        [~, ind] = sort(ticks(:, 1)); 
        ticks = ticks(ind, :); 
        
        openTicks = 0; 
        intervals{i} = {};
        intBegin = 0;
        thresh = (alpha*(NTrain+1)) - tau; 
        assert(thresh >= 1); 

        for j = 1:size(ticks, 1)
            tick = ticks(j, :);
            if(tick(2) == 1)
                if(openTicks <= thresh && ((openTicks+1) > thresh))
                    intBegin = tick(1); 
                end
                openTicks = openTicks + 1; 
            else 
                if(openTicks > thresh && ((openTicks-1) <= thresh))
                    intEnd = tick(1); 
                    intervals{i}{end+1} = [intBegin, intEnd];
                end
                openTicks = openTicks - 1; 
            end 
        end
    end

    coverage = 0;
    for i = 1:NTest
        for j = 1:length(intervals{i})
            interval = intervals{i}{j};
            if(YTest(i) >= interval(1) && YTest(i) <= interval(2))
                coverage = coverage + 1;
                break
            end
        end
    end
    coverage = coverage/NTest;
end