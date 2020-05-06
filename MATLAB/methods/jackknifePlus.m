function [intervals, coverage] = jackknifePlus(XTrain, YTrain, XTest, YTest, nFold, alpha, regressor, predictor)
    fprintf("Running jackknife+.\n");
    NTrain = size(XTrain, 1);
    NTest = size(XTest, 1); 
    assert(mod(NTrain, nFold) == 0)
    nTrain = NTrain/nFold;

    YPredAll = zeros(NTest, nFold); 
    learntTheta = cell(nFold);
    resTrain = zeros(NTrain,1); %all residuals are sorted within the fold
    for fold = 1:nFold
        XFold = XTrain([(1:nTrain*(fold-1)), ((nTrain*fold+1):nTrain*nFold)], :);
        YFold = YTrain([(1:nTrain*(fold-1)), ((nTrain*fold+1):nTrain*nFold)]);
        learntTheta{fold} = regressor(XFold, YFold); 
        
        XConf = XTrain((nTrain*(fold-1) + 1):(nTrain*fold), :);
        YConf = YTrain((nTrain*(fold-1) + 1):(nTrain*fold));
        YPred = arrayfun(@(j) predictor(XConf(j,:), learntTheta{fold}), 1:nTrain);
        resTrain((nTrain*(fold-1) + 1):(nTrain*fold)) = abs(YConf - YPred(:));
        YPredAll(:,fold) = arrayfun(@(j) predictor(XTest(j,:), learntTheta{fold}), 1:NTest);
    end
    
    lowerLevelLiberal = floor(alpha * (NTrain + 1));
    lowerLevelConservative= ceil(alpha * (NTrain + 1));
    upperLevelLiberal = ceil((1 - alpha)*(NTrain + 1));
    upperLevelConservative= floor((1 - alpha)*(NTrain + 1));
    pLower = alpha * (NTrain + 1) - lowerLevelLiberal; 
    pUpper = upperLevelLiberal - (1 - alpha)*(NTrain + 1); 
    intervalBeginsJP = zeros(NTest,1);
    intervalEndsJP = zeros(NTest,1);
    intervals = cell(NTest, 1); 
    for i = 1:NTest
        intervals{i} = {}; 
        temp = repmat(YPredAll(i,:), nTrain, 1); 
        temp = temp(:);
        predsLower = sort(temp - resTrain);
        predsUpper = sort(temp + resTrain);
        if(binornd(1,pLower))
            intervalBeginsJP(i) = predsLower(lowerLevelConservative);
        else
            intervalBeginsJP(i) = predsLower(lowerLevelLiberal);
        end
        if(binornd(1,pUpper))
            intervalEndsJP(i) = predsUpper(upperLevelConservative);
        else 
            intervalEndsJP(i) = predsUpper(upperLevelLiberal);
        end
        intervals{i}{end+1} = [intervalBeginsJP(i) intervalEndsJP(i)];
    end

    coverage = 0;
    for i = 1:NTest
        if((YTest(i) >= intervalBeginsJP(i)) && (YTest(i) <= intervalEndsJP(i)))
            coverage = coverage + 1;
        end
    end
    coverage = coverage/NTest;
end

