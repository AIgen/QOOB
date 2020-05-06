function [intervals, coverage] = crossConformal(XTrain, YTrain, XTest, YTest, nFold, alpha, regressor, predictor)
    fprintf("Running cross-conformal.\n");
    NTrain = size(XTrain, 1); 
    NTest = size(XTest, 1); 
    assert(mod(NTrain, nFold) == 0)
    nTrain = NTrain/nFold;

    YPredAll = zeros(NTest, nFold); 
    learntTheta = cell(nFold);
    sortedRes = zeros(NTrain,1); %all residuals are sorted within the fold
    for fold = 1:nFold
        XFold = XTrain([(1:nTrain*(fold-1)), ((nTrain*fold+1):nTrain*nFold)], :);
        YFold = YTrain([(1:nTrain*(fold-1)), ((nTrain*fold+1):nTrain*nFold)]);
        learntTheta{fold} = regressor(XFold, YFold); 

        XConf = XTrain((nTrain*(fold-1) + 1):(nTrain*fold), :);
        YConf = YTrain((nTrain*(fold-1) + 1):(nTrain*fold));
        YPred = arrayfun(@(j) predictor(XConf(j,:), learntTheta{fold}), 1:nTrain);
        sortedRes((nTrain*(fold-1) + 1):(nTrain*fold)) = sort(abs(YPred(:) - YConf));
        YPredAll(:,fold) = arrayfun(@(j) predictor(XTest(j,:), learntTheta{fold}), 1:NTest);
    end
    
    intervals = cell(NTest,1);
    ticks = zeros(2*NTrain, 2); 
        
    for i = 1:NTest
        tau = rand;
        temp = repmat(YPredAll(i,:), nTrain, 1); 
        
        ticks(1:NTrain, :) = [temp(:)-sortedRes, ones(NTrain,1)];
        ticks((NTrain+1):(2*NTrain), :) = [temp(:)+sortedRes, zeros(NTrain,1)];
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

