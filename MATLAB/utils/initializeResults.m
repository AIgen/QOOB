function [results] = initializeResults()
    results = struct; 
    results.totalCoverage = 0; 
    results.totalVarCoverage = 0; 
    results.totalMeanLength = 0;
    results.totalVarLength = 0;
    results.totalMeanNumber = 0; 
    results.totalVarNumber = 0; 
    results.totalMultiple = 0; 
    results.totalEmpty = 0; 
    results.numExperiments = 0;
end