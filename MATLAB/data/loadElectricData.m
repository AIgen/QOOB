function [X, Y] = loadElectricData()
    D = readmatrix('electric/Data_for_UCI_named.csv');
    X = D(:, 1:12); 
    Y = D(:, 13); 
    
    %%% subsample because data is too large
    subSampleSize = 1000; 
    subS = randperm(size(X, 1)); 
    X = X(subS(1:subSampleSize), :); 
    Y = Y(subS(1:subSampleSize), :); 

    fprintf("Loaded electrical grid stability dataset.\n");
end
