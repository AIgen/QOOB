function [intervals, coverage] = QOOB_interval(XTrain, YTrain, XTest, YTest, nTrees, alpha, lowerQuantile, upperQuantile)
    assert(lowerQuantile <= upperQuantile); 
    fprintf("Running QOOB (convex hull) with nTrees = %d.\n", nTrees);
    
    NTrain = size(XTrain, 1); 
    NTest = size(XTest, 1); 
    
    mdl = TreeBagger(nTrees, XTrain, YTrain, 'Method', 'regression', 'OOBPrediction', 'on');
    if(sum(sum(mdl.OOBIndices, 2) > 0) < NTrain)
        fprintf("Some training points are not out of bag for any tree. Try increasing the number of trees.\n"); 
    end

    oobIndicesRepeated = reshape(repmat(mdl.OOBIndices', NTest, 1), nTrees, NTrain*NTest)'; 
    
    predsUpper = quantilePredict(mdl, repmat(XTest, size(XTrain,1), 1), 'UseInstanceForTree', oobIndicesRepeated, 'quantile', upperQuantile); 
    predsLower = quantilePredict(mdl, repmat(XTest, size(XTrain,1), 1), 'UseInstanceForTree', oobIndicesRepeated, 'quantile', lowerQuantile); 
    YPredAllUpper = reshape(predsUpper, NTest, NTrain);
    YPredAllLower = reshape(predsLower, NTest, NTrain);

    trainRes = max(oobQuantilePredict(mdl, 'quantile', lowerQuantile) - YTrain, YTrain - oobQuantilePredict(mdl, 'quantile', upperQuantile)); 
                
    intervals = cell(NTest,1);
    ticks = zeros(2*NTrain, 2); 
    for i = 1:NTest
        tau = rand;
        ticks(1:NTrain, :) = [YPredAllLower(i,:)'- trainRes, ones(NTrain,1)];
        ticks((NTrain+1):(2*NTrain), :) = ...
                            [YPredAllUpper(i,:)'+ trainRes, -ones(NTrain,1)];
        openTicks = 0; 
        for j = 1:NTrain
            if(ticks(j, 1) > ticks(j+NTrain, 1))
                ticks(j, 2) = 0; 
                ticks(j+NTrain, 2) = 0; 
            end
        end
        [~, ind] = sort(ticks(:, 1)); 
        ticks = ticks(ind, :); 
        
        intervals{i} = {};
        intBegin = 0;
        thresh = (alpha*(NTrain+1)) - tau; 
        assert(thresh >= 1)
        
        intBegin = Inf; 
        for j = 1:size(ticks, 1)
            tick = ticks(j, :);
            if(tick(2) == 1)
                if(openTicks < thresh && ((openTicks+1) >= thresh) && (intBegin == Inf))
                    intBegin = tick(1); 
                end
                openTicks = openTicks + 1; 
            elseif(tick(2) == -1)
                if(openTicks >= thresh && ((openTicks-1) < thresh))
                    intEnd = tick(1); 
                end
                openTicks = openTicks - 1; 
            end 
        end
        if(intBegin < Inf)
            intervals{i}{end+1} = [intBegin, intEnd];
            % else intervals{i} stays empty
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