function compareConformalMethods(varargin)
    addpath(genpath('..'));
    CORES = min(varargin{3}, str2num(getenv('SLURM_TASKS_PER_NODE')));
    p = gcp('nocreate');
    if(isempty(p))
        if(isempty(CORES))
            %%% local macbook
            %parpool('local', 2);
        else
            parpool('local', CORES);
            fprintf('Using %d cores.\n', CORES);
        end
    else
        if(p.NumWorkers < CORES)
	   parpool('local', CORES);
           fprintf('Using %d cores.\n', CORES);
        end 
    end

    %% Arguments passed as parameters
    dataset = varargin{1}; % dataset name
    expName = varargin{2}; % a name for the experiment (for storing output files)
    numExp = varargin{3}; % number of simulations to average over
    alpha = varargin{4}; % tolerance value
    nTrainFrac = varargin{5}; % number of training points
    confMethods = varargin{6}; % conformal methods to execute
    fprintf('Tolerance value = %.2f\n', alpha);
    
    %% Hard-coded parameter values
    nFold = 8; % for cross-conformal or jackknife+; require mod(nTrain, nFold) = 0
    nominalQuantileFactor = 2; 
    
    %% Set up Input/Output files    
    outFile = ['results/' dataset{1} '/' expName{1} '.txt'] ;
    fprintf('Storing collated results in %s\n', outFile);
    dumpFile = ['dumps/' dataset{1} '_' expName{1} '.mat'];
    fprintf('Dumping uncollated results in %s\n', dumpFile);
    
    addpath(genpath('.'));
    
    if(dataset == "concrete")
        loadData = @loadConcreteData;
    elseif(dataset == "blog")
        loadData = @loadBlogData;    		  
    elseif(dataset == "protein")
        loadData = @loadProteinData;    		   
    elseif(dataset == "protein2")
        loadData = @loadProtein2Data;    		   
    elseif(dataset == "superconductor")
        loadData = @loadSuperconductorData;    		   
    elseif(dataset == "news")
        loadData = @loadNewsData;    		   
    elseif(dataset == "kernel")
        loadData = @loadKernelData;    		   
    elseif(dataset == "electric")
        loadData = @loadElectricData;    		   
    elseif(dataset == "wineWhite")
        loadData = @loadWineWhiteData;    		   
    elseif(dataset == "wineRed")
        loadData = @loadWineRedData;    		   
    elseif(dataset == "airfoil")
        loadData = @loadAirfoilData;    		   
    elseif(dataset == "cycle")
        loadData = @loadCycleData;    		   
    end

    %% Initialize Result Containers
    fprintf("Number of resamples of data = %d.\n", numExp);
    Intervals = cell(numExp,1); 
    Coverage = cell(numExp,1); 
    
    %% Perform experiment
    parfor expNumber = 1:numExp
    	[X, Y] = loadData(); 
        [XTrain, YTrain, XTest, YTest] = createSplit(X, Y, nTrainFrac); 

        intervals = struct;
        coverage = struct;     

        for i = 1:numel(confMethods) 
            confMethod = confMethods(i); 
            cm = confMethod{1}; 

            if(cm(1) == 'S' && cm(2) == 'C')
                nTrees = str2double(cm(3:end)); 
                regressor = @(x,y)TreeBagger(nTrees,x,y,'Method','regression');
        		predictor = @(x,pp)predict(pp, x); 
        		fprintf("Using %d trees for split-conformal.\n", nTrees);
                [intervals.(cm),coverage.(cm)] = ...
                    splitConformal(XTrain, YTrain, XTest, YTest, ...
                    floor(size(XTrain,1)/2), alpha, regressor, predictor);

            elseif(cm(1) == 'C' && cm(2) == 'C') 
        		nTrees = str2double(cm(3:end)); 
                regressor = @(x,y)TreeBagger(nTrees,x,y,'Method','regression');
                predictor = @(x,pp)predict(pp, x); 
                fprintf("Using %d trees for cross-conformal.\n", nTrees);
                [intervals.(cm),coverage.(cm)] = ...
                    crossConformal(XTrain, YTrain, XTest, YTest, ...
                    nFold, alpha, regressor, predictor);
                
            elseif(cm(1) == 'J' && cm(2) == 'P')
                nTrees = str2double(cm(3:end)); 
                regressor = @(x,y)TreeBagger(nTrees,x,y,'Method','regression');
                predictor = @(x,pp)predict(pp, x); 
                fprintf("Using %d trees for jackknife+.\n", nTrees);
                [intervals.(cm),coverage.(cm)] = ...
                    jackknifePlus(XTrain, YTrain, XTest, YTest, ...
                    nFold, alpha, regressor, predictor);
                
            elseif(cm(1) == 'S' && cm(2) == 'Q')
                nTrees = str2double(cm(4:end)); 
                quantile = nominalQuantileFactor*alpha; 
                [intervals.(cm),coverage.(cm)] = ...
                    splitQuantileConformalRF(XTrain, YTrain, XTest, YTest, floor(size(XTrain, 1)/2), nTrees, alpha, quantile, 1-quantile);
                
            elseif(cm(1) == 'O' && cm(4) == 'C')
                nTrees = str2double(cm(6:end)); 
                [intervals.(cm),coverage.(cm)] = ...
                    OOB_crossConformal(XTrain, YTrain, XTest, YTest, nTrees, alpha);
                
            elseif(cm(1) == 'O' && cm(4) == 'N')
                nTrees = str2double(cm(7:end)); 
                [intervals.(cm),coverage.(cm)] = ...
                    OOB_normalizedCrossConformal(XTrain, YTrain, XTest, YTest, nTrees, alpha); 
    
            elseif(cm(1) == 'Q' && cm(5) ~= '_')
                nTrees = str2double(cm(5:end)); 
                quantile = 2*alpha; 
                [intervals.(cm),coverage.(cm)] = ...
                    QOOB(XTrain, YTrain, XTest, YTest, nTrees, alpha, quantile, 1-quantile);
            
            elseif(cm(1) == 'Q' && cm(6) == 'd')
                nTrees = str2double(cm(7:end)); 
                [intervals.(cm),coverage.(cm)] = ...
                    QOOB_distributional(XTrain, YTrain, XTest, YTest, nTrees, alpha);
                
            elseif(cm(1) == 'Q' && cm(6) == 'j')
                nTrees = str2double(cm(7:end)); 
                quantile = nominalQuantileFactor*alpha; 
                [intervals.(cm),coverage.(cm)] = ...
                    QOOB_jackknifePlus(XTrain, YTrain, XTest, YTest, nTrees, alpha, quantile, 1-quantile);
                
            elseif(cm(1) == 'Q' && cm(6) == 'i')
                nTrees = str2double(cm(7:end)); 
                quantile = nominalQuantileFactor*alpha; 
                [intervals.(cm),coverage.(cm)] = ...
                    QOOB_interval(XTrain, YTrain, XTest, YTest, nTrees, alpha, quantile, 1-quantile);
            end
        end

        Coverage{expNumber,1} = coverage; 
        Intervals{expNumber,1} = intervals;
    end

    %% Aggregate and store results of experiment
    Results = struct; 
    for confMethod = confMethods
        Results.(confMethod{1}) = initializeResults(); 
    end
    for expNumber = 1:numExp
        intervals = Intervals{expNumber,1}; 
        coverage = Coverage{expNumber,1}; 
        for confMethod = confMethods
            Results.(confMethod{1}) = updateResults(Results.(confMethod{1}), observeIntervals(intervals.(confMethod{1})), coverage.(confMethod{1})); 
        end
    end

    collateResults(Results, confMethods, outFile);
    save(dumpFile, 'Results', 'Coverage', 'Intervals'); 
end
