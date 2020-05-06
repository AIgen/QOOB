function [intervals, coverage] = splitConformal(XTrain, YTrain, XTest, YTest, nCalibration, alpha, regressor, predictor)
    fprintf("Running split-conformal.\n");
    assert(nCalibration < size(XTrain, 1));
    NTest = size(XTest, 1);

    XCalibration = XTrain(1:nCalibration, :);
    YCalibration = YTrain(1:nCalibration, 1);
    XLearn = XTrain(nCalibration+1:end, :);
    YLearn = YTrain(nCalibration+1:end, 1);
    theta = regressor(XLearn, YLearn);
    res = sort(abs(predictor(XCalibration, theta) - YCalibration));

    level1 = min(nCalibration, ceil((nCalibration + 1)*(1 - alpha)));
    level2 = min(nCalibration, floor((nCalibration + 1)*(1 - alpha)));
    p =	level1 - min(nCalibration, (nCalibration + 1)*(1 - alpha));
    thresh1 = res(level1);
    thresh2 = res(level2);

    preds = predictor(XTest, theta);
    intervalsMatLiberal = [preds - thresh1, preds + thresh1];
    intervalsMatConservative = [preds - thresh2, preds + thresh2];
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
        intervals{i} = {};
        intervals{i}{end+1} = intervalsMat(i, :);
    end
end


