function [XTrain, YTrain, XTest, YTest] = createSplit(X, Y, NTrain)
    assert(size(X, 1) == size(Y, 1)); 
    assert(size(X, 1) >= NTrain); 
    N = size(X, 1); 
    if(NTrain < 1)
        NTrain = floor(NTrain*N); 
        assert(NTrain > 1); 
    end
    NTest = N - NTrain;
    perm = randperm(N);
    XTrain = X(perm(1:NTrain), :); 
    YTrain = Y(perm(1:NTrain), :); 
    XTest = X(perm((N+1-NTest):N), :); 
    YTest = Y(perm((N+1-NTest):N), :); 
end