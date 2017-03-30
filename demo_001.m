%% DEMO_001 basic useage
% The Psignifit 101

%% save data in right format

% First we need the data in the format (x | nCorrect | total)
% As an example we use the following dataset from a 2AFC experiment with 90
% trials at each stimulus level. This dataset comes from a simple signal
% detection experiment.

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

% remark: This format differs slightly from the format used in older
% psignifit versions. 

%% construct an options struct
% To start psignifit you need to pass a struct, which specifies, what kind
% of experiment you did and any other parameters of the fit you might want
% to set:

% You can create a struct by simply calling [name]=struct

options             = struct;   % initialize as an empty struct

%Now you can set the different options with lines of the form
%[name].[field] as in the following lines:

options.sigmoidName = 'norm';   % choose a cumulative Gaussian as the sigmoid
options.expType     = '2AFC';   % choose 2-AFC as the paradigm of the experiment
                                % this sets the guessing rate to .5 and
                                % fits the rest of the parameters

% There are 3 other types of experiments supported out of the box:
% n alternative forces choice. The guessing rate is known.
%       options.expType = "nAFC"
%       options.expN    = [number of alternatives]
% Yes/No experiments a free guessing and lapse rate is estimated
%       options.expType = "YesNo"
% equal asymptote, as Yes/No, but enforces that guessing and lapsing occure
% equally often
%       options.expType = "equalAsymptote"

% Out of the box psignifit supports the following sigmoid functions,
% choosen by:
% options.sigmoidName = ...
% 
% 'norm'        a cummulative Gaussian distribution
% 'logistic'    a logistic function
% 'gumbel'      a cummulative gumbel distribution
% 'rgumbel'     a reversed gumbel distribution
% 'tdist'       a t-distribution with df=1 as a heavytail distribution
%
% for positive stimulus levels which make sense on a log-scale:
% 'logn'        a cumulative lognormal distribution
% 'Weibull'     a Weibull function

% There are many other options you can set in the options-file. You find
% them in demo_002


%% Now run psignifit
% Now we are ready to run the main function, which fits the function to the
% data. You obtain a struct, which contains all the information about the
% fitted function and can be passed to the many other functions in this
% toolbox, to further process the results.

result = psignifit(data,options);

%result is a struct which contains all information obtained from fitting your data. 
%Perhaps of primary interest are the fit and the confidence intervals:

result.Fit
result.conf_Intervals

% This gives you the basic result of your fit. The five values reported are:
%    the threshold
%    the width (difference between the 95 and the 5 percent point of the unscaled sigmoid)
%    lambda, the upper asymptote/lapse rate
%    gamma, the lower asymptote/guess rate
%    eta, scaling the extra variance introduced (a value near zero indicates 
%         your data to be basically binomially distributed, whereas values 
%         near one indicate severely overdispersed data)
% The field conf_Intervals returns credible intervals for the values provided 
% in options.confP. By default these are 68%, 90% and 95%. With default settings 
% you should thus receive a 5x2x3 array, which contains 3 sets of credible intervals 
% (lower and upper end = 2 values) for each of the 5 parameters.

%% visualize the results
% For example you can use the result struct res to plot your psychometric
% function with the data:

plotPsych(result);



%% remark for insufficient memory issues
% especially for YesNo experiments the result structs can become rather
% large. If you run into Memory issues you can drop the Posterior from the
% result with the following command.

resultSmall = rmfield(result,{'Posterior','weight'});

% without these fields you will not be able to use the 2D Bayesian plots
% anymore. All other functions work without it.
