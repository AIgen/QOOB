function [alpha] = findQuantileRF(XTrain, YTrain, mdl)
    alpha = zeros(size(XTrain,1), 1); 
    for i = 1:size(XTrain,1)
        x = XTrain(i, :); 
        y = YTrain(i); 
        treesToUse = mdl.OOBIndices(i,:); 
        
        allQuants = quantilePredict(mdl, x, ...
                    'UseInstanceForTree', treesToUse, ...
                    'quantile', 0.01:0.01:1);
        if(allQuants(1) > y)
            alpha(i) = 0.01; 
            continue; 
        end
        a = 0.01;
        b = 1;
        lw=ceil(50*(a+b))/100;
        while ((a < b) && (allQuants(round(100*a)) < allQuants(round(100*b))))
            yQuantileLw = allQuants(round(100*lw));
            if (yQuantileLw > y)
                b = lw-0.01; 
            else
                a = lw;
            end
            lw=ceil(50*(a+b))/100;
            %fprintf("100*lw, 100*a, 100*b = %f, %f, %f\n", 100*lw, 100*a, 100*b); 
        end
        alpha(i) = min(lw, 1-lw); 
    end
end