function [intervals_, coverage] = intervalUnion(X, Y, intervals)
    N = size(X, 1); 
    intervals_ = cell(N, 1); 
    coverage = 0; 
    for i = 1:N
        minPred = inf;
        maxPred = -Inf; 
        for j = 1:numel(intervals{i})
            interval = intervals{i}{j}; 
            minPred = min(minPred, interval(1)); 
            maxPred = max(maxPred, interval(2)); 
        end
        intervals_{i}{end+1} = [minPred, maxPred]; 
        if(Y(i) >= minPred && Y(i) <= maxPred)
            coverage = coverage + 1;
        end
    end
    coverage = coverage/N; 
end

