function [intervals, coverage] = OOB_normalizedCrossConformal(XTrain, YTrain, XTest, YTest, nTrees, alpha)
    fprintf("Running OOB-NCC with nTrees = %d.\n", nTrees);
    NTrain = size(XTrain, 1); 
    NTest = size(XTest, 1); 
    
    mdl = TreeBagger(nTrees, XTrain, YTrain, 'Method', 'regression', 'OOBPrediction', 'on');
    if(sum(sum(mdl.OOBIndices, 2) > 0) < NTrain)
        fprintf("Some training points are not out of bag for any tree. Try increasing the number of trees.\n"); 
    end

    individualIndicesRepeated = reshape(repmat(logical(eye(nTrees)), NTest, 1),...
                            nTrees, nTrees*NTest)'; 
    individualPreds = predict(mdl, repmat(XTest, nTrees, 1), ...
                            'UseInstanceForTree', individualIndicesRepeated);
    individualPreds = reshape(individualPreds, NTest, nTrees); 
    YPredAll = (individualPreds * mdl.OOBIndices')./ ...
                repmat(sum(mdl.OOBIndices, 2)', NTest, 1); 
    YPredStdAll = (((individualPreds.^2 * mdl.OOBIndices')./ ...
                repmat(sum(mdl.OOBIndices, 2)', NTest, 1)) - ...
                (YPredAll.^2)).^(0.5); 
    
    individualIndicesRepeatedTrain = reshape(repmat(logical(eye(nTrees)), NTrain, 1),...
                            nTrees, nTrees*NTrain)'; 
    individualPredsTrain = predict(mdl, repmat(XTrain, nTrees, 1), ...
                            'UseInstanceForTree', individualIndicesRepeatedTrain);
    individualPredsTrain = reshape(individualPredsTrain, NTrain, nTrees);                     
    YPredAllTrain = oobPredict(mdl);
    YPredStdAllTrain = zeros(NTrain, 1); 
    for i = 1:NTrain
        p = individualPredsTrain(i, :); 
        p = p(mdl.OOBIndices(i, :)); 
        YPredStdAllTrain(i) = (var(p)*((numel(p) - 1)/numel(p)))^0.5; 
    end
            
    trainRes = abs(YPredAllTrain - YTrain)./YPredStdAllTrain; 
    intervals = cell(NTest,1);
    ticks = zeros(2*NTrain, 2); 
    for i = 1:NTest
        tau = rand;
        ticks(1:NTrain, :) = [YPredAll(i,:)'-trainRes.*(YPredStdAll(i,:)'), ...
                             ones(NTrain,1)];
        ticks((NTrain+1):(2*NTrain), :) = [YPredAll(i,:)'+trainRes.*(YPredStdAll(i,:)'), ...
                                zeros(NTrain,1)];
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