function [X, Y] = loadCycleData()
    D = readmatrix('cycle/fold1.csv');
    X = D(:, 1:4); 
    Y = D(:, 5); 
    
    %%% subsample because data is too large
    subSampleSize = 1000; 
    subS = randperm(size(X, 1)); 
    X = X(subS(1:subSampleSize), :); 
    Y = Y(subS(1:subSampleSize), :); 

    fprintf("Loaded combined cycle power plant dataset.\n");
end
