function [observations] = observeIntervals(intervals)
    observations = struct; 
    observations.multipleIntervals = [];
    observations.emptyIntervals = []; 
    observations.meanNumber = 0; 
    observations.meanLength = 0; 
    for i = 1:numel(intervals)
        if(numel(intervals{i}) > 1)
            observations.multipleIntervals = [observations.multipleIntervals i];
        end
        if(numel(intervals{i}) == 0)
            observations.emptyIntervals = [observations.emptyIntervals i];
        end
        observations.meanNumber = observations.meanNumber + numel(intervals{i}); 
        for j = 1:numel(intervals{i})
            interval = intervals{i}{j}; 
            observations.meanLength = observations.meanLength + (interval(2) - interval(1)); 
        end
    end
    observations.meanLength = observations.meanLength/numel(intervals); 
    observations.meanNumber = observations.meanNumber/numel(intervals); 
end

