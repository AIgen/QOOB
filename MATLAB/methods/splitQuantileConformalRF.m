function [intervals, coverage] = splitQuantileConformalRF(XTrain, YTrain, XTest, YTest, nCalibration, nTrees, alpha, lowerQuantile, upperQuantile)
    fprintf("Running split quantile conformal with (nTrees, lowerQ, upperQ) = (%d, %.2f, %.2f).\n", nTrees, lowerQuantile, upperQuantile);
    assert(nCalibration < size(XTrain, 1));
    NTest = size(XTest, 1);

    XCalibration = XTrain(1:nCalibration, :);
    YCalibration = YTrain(1:nCalibration, 1);
    XLearn = XTrain(nCalibration+1:end, :);
    YLearn = YTrain(nCalibration+1:end, 1);
    mdl = TreeBagger(nTrees, XLearn, YLearn, 'Method', 'regression');
    res = sort(max(quantilePredict(mdl, XCalibration, 'quantile', lowerQuantile) - YCalibration, ...
           YCalibration - quantilePredict(mdl, XCalibration, 'quantile', upperQuantile)));

    level1 = min(nCalibration, ceil((nCalibration + 1)*(1 - alpha)));
    level2 = min(nCalibration, floor((nCalibration + 1)*(1 - alpha)));
    p =	level1 - min(nCalibration, (nCalibration + 1)*(1 - alpha));
    thresh1 = res(level1);
    thresh2 = res(level2);

    quantilePreds = [quantilePredict(mdl, XTest, 'quantile', lowerQuantile) ...
                    quantilePredict(mdl, XTest, 'quantile', upperQuantile)];
    intervalsMatLiberal = [quantilePreds(:,1) - thresh1, quantilePreds(:,2) + thresh1];
    intervalsMatConservative = [quantilePreds(:,1) - thresh2, quantilePreds(:,2) + thresh2];
    intervalsMat = zeros(NTest, 2);
    coverage = 0;
    for i = 1:NTest
    	arbitrate = binornd(1,p);
        if(arbitrate == 1)
            intervalsMat(i, :) = intervalsMatConservative(i, :);
        else
            intervalsMat(i, :) = intervalsMatLiberal(i,	:);
        end
        if(YTest(i) >= intervalsMat(i,1) && YTest(i) <= intervalsMat(i,2))
            coverage = coverage + 1;
        end
    end
    coverage = coverage/NTest;

    intervals = cell(NTest, 1);
    for i = 1:NTest
        if(intervalsMat(i,2) >= intervalsMat(i,1))
            intervals{i}{1} = intervalsMat(i, :);
        end
    end
end


