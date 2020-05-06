function [X, Y] = loadProteinData()
    D = csvread('protein/CASP.csv', 1, 0);
    X = D(:, 2:9); 
    Y = D(:, 1); 
    
    %%% subsample because data is too large
    subSampleSize = 1000; 
    subS = randperm(size(X, 1)); 
    X = X(subS(1:subSampleSize), :); 
    Y = Y(subS(1:subSampleSize), :); 

    fprintf("Loaded protein structure dataset.\n");
end