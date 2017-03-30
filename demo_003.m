%% demo_003 fields of the results struct - Which information is contained in the result of Psignifit

% to have some data we use the data from demo_001
data =    [...
    0.0010,   45.0000,   90.0000;...
    0.0015,   50.0000,   90.0000;...
    0.0020,   44.0000,   90.0000;...
    0.0025,   44.0000,   90.0000;...
    0.0030,   52.0000,   90.0000;...
    0.0035,   53.0000,   90.0000;...
    0.0040,   62.0000,   90.0000;...
    0.0045,   64.0000,   90.0000;...
    0.0050,   76.0000,   90.0000;...
    0.0060,   79.0000,   90.0000;...
    0.0070,   88.0000,   90.0000;...
    0.0080,   90.0000,   90.0000;...
    0.0100,   90.0000,   90.0000];


% just initialize the options struct
options=struct;

% and run psignifit

result=psignifit(data,options);
% now we can have a look at the result struct and all its fields


%% list of result struct fields
% Here we list all fields of the result struct in the format
% result.[field]        = short description
%
% after it follow some explanation and allowed values


%% result.Fit = the fitted parameter of the psychometric function
% Which kind of fit was performed is determined by the options you set. 
% It might be mean, median or MAP.
% The order of reported parameters is
% [threshold,width,lambda,gamma,eta]
% Along the third dimension you find this credible intervals for the 
% different confidence levels as set in options.confP. 
% (default for options.confP = [.95,.9,.68])

%% result.conf_Intervals = confidence intervals for the fit
% the confidence intervals for the 5 parameters.  
% The order of reported parameters is
% [threshold,width,lambda,gamma,eta]

%% result.data = data used for the fit
% the array used as data input for psignifit

%% result.options = the options struct used for the fit
% contains all options set for the fit including automatically set values

%% result.timestamp = When the data result was created

%% result.Posterior = posterior density at the gridpoints
% normalized Posterior density evaluated at the final gridpoints

%% result.weight = integration weight for each gridpoint
% this is the volume of parameter space each gridpoint "speaks for". This
% is needed for integrations over the space.

%% result.X1D = positions of the gridpoints on the 5 dimensions
% a cell array of vectors

%% result.marginals   = marginal densities for the 5 parameters
%% result.marginalsX  = positions of the marginal evaluations
%% result.marginalsW  = integration weight for each gridpoint
% Used together these three represent the marginal posterior distributions


%% result.logPmax, result.integral = normalization constants
% the maximal log-likelihood which is subtracted prior to computing the
% exponential to avoid numerical problems 
% and the integral over the likelihood accross the parameter space, used
% for normalizing into a probability.

