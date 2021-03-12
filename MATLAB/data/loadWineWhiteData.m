function [X, Y] = loadWineWhiteData()
    D = readmatrix('wine/winequality-white.csv');
    X = D(:, 1:11); 
    Y = D(:, 12); 
    
    %%% subsample because data is too large
    subSampleSize = 1000; 
    subS = randperm(size(X, 1)); 
    X = X(subS(1:subSampleSize), :); 
    Y = Y(subS(1:subSampleSize), :); 

    fprintf("Loaded wine quality (white) dataset.\n");
end
