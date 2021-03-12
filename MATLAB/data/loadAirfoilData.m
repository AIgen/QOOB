function [X, Y] = loadAirfoilData()
    D = readmatrix('airfoil/airfoil_self_noise.dat');
    X = D(:, 1:5); 
    Y = D(:, 6); 
    
    %%% subsample because data is too large
    subSampleSize = 1000; 
    subS = randperm(size(X, 1)); 
    X = X(subS(1:subSampleSize), :); 
    Y = Y(subS(1:subSampleSize), :); 

    fprintf("Loaded airfoil dataset.\n");
end
