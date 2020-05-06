function [X, Y] = loadBlogData()
    D = csvread('blog/blogData_train.csv');
    X = D(:, 1:280); 
    Y = D(:, 281); 
    
    %%% subsample because data is too large
    subSampleSize = 1000; 
    subS = randperm(size(X, 1)); 
    X = X(subS(1:subSampleSize), :); 
    Y = Y(subS(1:subSampleSize), :); 

    fprintf("Loaded blog feedback dataset.\n");
end
