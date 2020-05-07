
# Quantile out-of-bag (QOOB) conformal
Conformal inference is a distribution-free way of performing predictive inference [1, 2]. For a description of the prediction problem that conformal solves and some standard references for conformal inference, please read Section 1 (introduction) of our paper [3]. This repository contains an implementation of our novel conformal method, QOOB [3]. Conformal inference (and QOOB) have primarily been developed for regression but can be extended to non-regression problems, such as classification.

## Usage
Please clone the repo as:
			
	git clone https://github.com/AIgen/QOOB.git	

A MATLAB implementation is required to run the code. The code was developed using MATLAB 2019b and has been tested on MATLAB 2019a. 

This repository comes bundled with the six publicly available datasets used in our paper. To reproduce the results in Table 2 and 3 of our paper [3] on the protein dataset, please call the function `compareConformalMethods` in the `MATLAB` folder with the following parameters:

	compareConformalMethods("protein", "table2", 100, 0.1, 0.768, ["SC100", "SQC100", "CC100", "OOBCC100", "OOBNCC100", "QOOB100"]);
The third parameter above is the number of simulations to average over; we recommend using a smaller value such as 5-10 on a personal computer. Once the execution above completes, an output results file is produced at `MATLAB/results/protein/table2.txt`, and more detailed experimental results are dumped in `MATLAB/dumps/protein_table2.mat`. This folder structure comes pre-constructed on cloning the repository. 

### Sample output 
Post execution, a call to `compareConformalMethods` will produce an output at `MATLAB/results/protein/table2.txt` which looks like the following: 
	
	Method        Coverage  Var(<--)    Width    Var(<--)
 	SC100          0.9007    0.0005    16.6917    0.6942    
 	SQC100         0.9005    0.0006    14.1580    0.9069    
 	CC100          0.9054    0.0004    16.3174    0.1982    
 	OOBCC100       0.9043    0.0004    16.3554    0.2106    
 	OOBNCC100      0.9094    0.0004    14.9131    0.2588    
 	QOOB100        0.9134    0.0004    13.7582    0.2446   

The first column represents the method; the second column represents the average mean-coverage across simulations and the third column represents the estimated variance of the mean-coverage across simulations; the fourth and fifth columns represent the average and variance of the mean-width across simulations. In our paper [3] we compare these methods on the basis of the average values for mean-width and mean-coverage. To provide a confidence for these values, we compute the empirical standard deviation of the average values as 

std-deviation of the average = (variance(from table) / number of simulations)<sup>0.5</sup>.
	
These are the values reported in Tables 2 and 3 in the parantheses. 

### Parameters for `compareConformalMethods`
1. `"protein"`: The dataset name. The following datasets are bundled - protein, blog, concrete, superconductor, news or kernel. Additional datasets can be added. 
2. `"table2"`: The experiment name. Experimental output files are named using this value. 
3. `100`: Number of simulations to run for each conformal method. 
4. `0.1`: The value for $\alpha$. 
5. `0.768`: Number of training points as a ratio of the total number of points in the dataset. 
6. `["SC100", ... ,"QOOB100"]`: Conformal methods to compare. In each case, the uppercase alphabets defines the conformal method to use and the number after them denotes the number of trees for the random forest based base algorithm. In this case we have the following conformal methods (references and descriptions can be found in our paper [3]): 
	
		- SC100: Split conformal with random forests (100 trees). 
		- SQC100: Split conformalized quantile regression with quantile random forests (100 trees). 
		- CC100: Cross-conformal with 8-folds (hard-coded) and random forests (100 trees). 
		- OOBCC100: Out-of-bag cross-conformal with random forests (100 trees).
		- OOBNCC100: Out-of-bag normalized-cross-conformal with random forests (100 trees).
		- QOOB100: Quantile out-of-bag conformal with quantile random forests (100 trees). 

The last method above is our novel conformal method. These methods can be called with any positive number of trees (for example `QOOB200` calls QOOB with 200 trees). Calls to the other conformal methods that are supported (with 100 trees) are as follows: 

	- JP100: Jackknife+ with 8-folds (hard-coded) and random forests (100 trees).
	- QOOB_j100: QOOB (jackknife+) with quantile random forests (100) trees.
	- QOOB_i100: QOOB (interval completion/convex hull) with quantile random forests (100 trees).
	- QOOB_d100: QOOB (distributional) with quantile random forests (100 trees).

### Folder structure
The main wrapper function `compareConformalMethods` is in the folder `MATLAB`. It uses the functions in the folders in the `MATLAB` directory, which are organized as follows.

`methods`: QOOB and other conformal methods are defined as separate functions here.

`data:` Dataset files (in separate folders) and functions to load the datasets.

`dumps:` All outputs of the experiments are stored as `.mat` files here. 

`results:` Collated human-readable results of experiments.  

`utils:` Miscellaneous support  routines. 

## Contribute or request 
Please email us if you wish to contribute or request content. We are currently working on providing an efficient implementation of QOOB in Python. 

## License
QOOB is licensed under the terms of the [MIT non-commercial License](LICENSE).

## References
[1] [Algorithmic Learning in a Random World](https://link.springer.com/book/10.1007/b106715)

[2] [Distribution-Free Predictive Inference For Regression](https://arxiv.org/abs/1604.04173)

[3] [Nested conformal prediction and quantile out-of-bag ensemble methods](https://arxiv.org/abs/1910.10562)
