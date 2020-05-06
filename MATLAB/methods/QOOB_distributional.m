function [intervals, coverage] = QOOB_distributional(XTrain, YTrain, XTest, YTest, nTrees, alpha)
    fprintf("Running QOOB (distributional) with nTrees = %d.\n", nTrees);
    
    NTrain = size(XTrain, 1); 
    NTest = size(XTest, 1); 
    
    mdl = TreeBagger(nTrees, XTrain, YTrain, 'Method', 'regression', 'OOBPrediction', 'on');
    if(sum(sum(mdl.OOBIndices, 2) > 0) < NTrain)
        fprintf("Some training points are not out of bag for any tree. nTrees = %d.\n", nTrees);
    end
    
    trainRes = findQuantileRF(XTrain, YTrain, mdl);
    
    YPredAllUpper = zeros(NTest, NTrain); 
    YPredAllLower = zeros(NTest, NTrain); 
    for j = 1:NTrain
        YPredAllUpper(:, j) = quantilePredict(mdl, ...
                            XTest, 'UseInstanceForTree', ...
                            repmat(mdl.OOBIndices(j, :), NTest, 1), ...
                            'quantile', 1-trainRes(j)); 
        YPredAllLower(:, j) = quantilePredict(mdl, ...
                            XTest, 'UseInstanceForTree', ...
                            repmat(mdl.OOBIndices(j, :), NTest, 1), ...
                            'quantile', trainRes(j)); 
    end
    
    intervals = cell(NTest,1);
    ticks = zeros(2*NTrain, 2); 
    for i = 1:NTest
        tau = rand;
        ticks(1:NTrain, :) = [YPredAllLower(i,:)', ones(NTrain,1)];
        ticks((NTrain+1):(2*NTrain), :) = ...
                            [YPredAllUpper(i,:)', -ones(NTrain,1)];
        
        [~, ind] = sort(ticks(:, 1)); 
        ticks = ticks(ind, :); 
        
        intervals{i} = {};
        thresh = (alpha*(NTrain+1)) - tau; 
        assert(thresh >= 1)
        
        openTicks = 0; 
        intBegin = Inf; 
        for j = 1:size(ticks, 1)
            tick = ticks(j, :);
            if(tick(2) == 1)
                if(openTicks < thresh && ((openTicks+1) >= thresh))
                    intBegin = tick(1); 
                end
                openTicks = openTicks + 1; 
            elseif(tick(2) == -1)
                if(openTicks >= thresh && ((openTicks-1) < thresh))
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