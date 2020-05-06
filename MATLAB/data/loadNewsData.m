function [X, Y] = loadNewsData()
    D = csvread('news/OnlineNewsPopularity.csv', 0, 0);
    X = D(:, 1:59); 
    Y = D(:, end); 
    
    %%% subsample because data is too large
    subSampleSize = 1000; 
    subS = randperm(size(X, 1)); 
    X = X(subS(1:subSampleSize), :); 
    Y = Y(subS(1:subSampleSize), :); 

    fprintf("Loaded news popularity dataset.\n");
end