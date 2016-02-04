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

options.sigmoidName = 'norm';   % choose a cumulative Gauss as the sigmoid
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
% 'norm'        a cummulative gauss distribution
% 'logistic'    a logistic function
% 'gumbel'      a cummulative gumbel distribution
% 'rgumbel'     a reversed gumbel distribution
% 'tdist'       a t-distribution with df=1 as a heavytail distribution
%
% for positive stimulus levels which make sence on a log-scale:
% 'logn'        a cumulative lognormal distribution
% 'Weibull'     a Weibull function

% There are many other options you can set in the options-file. You find
% them in demo_002


%% Now run psignifit
% Now we are ready to run the main function, which fits the function to the
% data. You obtain a struct, which contains all the information about the
% fitted function and can be passed to the many other functions in this
% toolbox, to further process the results.

res = psignifit(data,options);

%% visualize the results
% For example you can use the result struct res to plot your psychometric
% function with the data:

plotPsych(res);



%% remark for insufficient memory issues
% especially for YesNo experiments the result structs can become rather
% large. If you run into Memory issues you can drop the Posterior from the
% result with the following command.

result = rmfield(res,{'Posterior','weight'});

% without these fields you will not be able to use the 2D Bayesian plots
% anymore. All other functions work without it.
