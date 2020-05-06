function [X, Y] = loadKernelData()
    D = csvread('kernel/sgemm_product.csv', 0, 0);
    X = D(:, 1:14); 
    Y = mean(D(:, 15:18), 2); 
    
    %%% subsample because data is too large
    subSampleSize = 1000; 
    subS = randperm(size(X, 1)); 
    X = X(subS(1:subSampleSize), :); 
    Y = Y(subS(1:subSampleSize), :); 

    fprintf("Loaded kernel performance dataset.\n");
end