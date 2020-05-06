function [intervals, coverage] = QOOB_jackknifePlus(XTrain, YTrain, XTest, YTest, nTrees, alpha, lowerQuantile, upperQuantile)
    fprintf("Running QOOB (jackknife+) with nTrees = %d.\n", nTrees);
    assert(lowerQuantile <= upperQuantile); 
    
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
    ticks = zeros(2*NTrain, 1); 
    for i = 1:NTest
        ticks(1:NTrain, :) = YPredAllLower(i,:)'-trainRes;
        ticks((NTrain+1):(2*NTrain), :) = ...
                            YPredAllUpper(i,:)'+trainRes;

        for j = 1:NTrain
            if(ticks(j) > ticks(j+NTrain))
                ticks(j) = Inf; 
                ticks(j+NTrain) = -Inf; 
            end
        end
        predsLower = sort(ticks(1:NTrain, :));
        predsUpperNeg = sort(-ticks(NTrain+1:2*NTrain, :));

        tau = rand; 
        if(predsLower(ceil(alpha*(NTrain+1) - tau)) < Inf && ...
                predsUpperNeg(ceil(alpha*(NTrain+1) - tau)) < Inf)
            intervals{i}{end+1} = [predsLower(ceil(alpha*(NTrain+1) - tau)) ...
			      -predsUpperNeg(ceil(alpha*(NTrain+1) - tau))];
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