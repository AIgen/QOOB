function [X, Y] = loadConcreteData()
    D = csvread('concrete/concrete.csv');
    X = D(:, 1:8); 
    Y = D(:, 9); 

    %%% subsample for standardization
    subSampleSize = 1000; 
    subS = randperm(size(X, 1)); 
    X = X(subS(1:subSampleSize), :); 
    Y = Y(subS(1:subSampleSize), :); 

    fprintf("Loaded concrete strength dataset.\n");
end