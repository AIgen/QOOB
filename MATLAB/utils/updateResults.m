function [results] = updateResults(results, observations, coverage)
    results.totalCoverage = results.totalCoverage + coverage;
    results.totalVarCoverage = results.totalVarCoverage + coverage^2;
    results.totalMeanLength = results.totalMeanLength + observations.meanLength; 
    results.totalVarLength = results.totalVarLength + (observations.meanLength)^2; 
    results.totalMeanNumber = results.totalMeanNumber +  observations.meanNumber; 
    results.totalVarNumber = results.totalVarNumber + (observations.meanNumber)^2; 
    results.totalMultiple = results.totalMultiple + numel(observations.multipleIntervals); 
    results.totalEmpty = results.totalEmpty + numel(observations.emptyIntervals); 
    results.numExperiments = results.numExperiments + 1; 
end