%% demo_002 fields of the options struct - Which options can one set?
% This demo explains all fields of the options struct, e.g. which options
% you can set for the fitting process as a user.

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

% now or at any later time you can run a fit with this command.

result=psignifit(data,options);



%% list of options fields
% Here we list all fields of the option struct in the format
% options.[field]        = default Value
%
% after it follow some explanation and allowed values


%% options.sigmoidName    = 'norm'
% This sets the type of sigmoid you fit to your data. 

% The dafault value 'norm' fits a cumulative gaussian to your data. 
options.sigmoidName    = 'norm';

% another standard alternative is the logistic function
options.sigmoidName    = 'logistic';

% For data on a logscale you may want to fit a log-normal distribution or a
% Weibull which you invoce with:
options.sigmoidName    = 'logn';
%or
options.sigmoidName    = 'weibull';

% We also included the gumbel and reversed gumbel functions for asymmetric
% psychometric functions. The gumbel has a longer lower tail the reversed
% gumbel a longer upper tail. 

options.sigmoidName    = 'gumbel';
% or
options.sigmoidName    = 'rgumbel';

% for a heavy tailed distribution use
options.sigmoidName    = 'tdist';

%% options.sigmoidHandle
% Here you may provide a handle to your own sigmoid which takes two
% parameters as input and hands back a function value. This should be
% vectorized or even a formula.
% However this is usually obtained from options.sigmoidName.
% This is needed if you want to use your own sigmoid, which is not built in 


%% options.expType        = 'YesNo'
% This sets which parameters you want to be free and which you fix and to
% which values, for standard experiment types.

% 'YesNo', default sets all parameters free, which is suitable for a standard
% yes/no paradigm.
options.expType        = 'YesNo';

% '2AFC', fixes the lower asymptote to .5 and fits the rest, for 2
% alternative forced choice experiments.
options.expType        = '2AFC';

% 'nAFC', fixes the lower asymptote to 1/n and fits the rest. For this type
% of experiment you MUST also provide options.expN the number of
% alternatives.
% As an example with 3 alternatives:
options.expType        = 'nAFC';
options.expN           = 3;


%% options.estimateType   = 'mean'
% How you want to estimate your fit from the posterior

% 'MAP' The MAP estimator is the maximum a posteriori computed from
% the posterior. 
options.estimateType   = 'MAP';

% 'mean' The posterior mean. In a Bayesian sense a more suitable estimate.
% the expected value of the Posterior.

options.estimateType   = 'mean';

%% options.stepN   = [40,40,20,20,20]
%% options.mbStepN = [25,20,10,10,20]
% This sets the number of grid points on each dimension in the final
% fitting (stepN) and in the moving of borders mbStepN
% the order is 
% [threshold,width,upper asymptote,lower asymptote,variance scaling]

% You may change this if you need more accurate estimates on the sparsely
% sampled parameters or if you want to play with them to save time

% for example to get an even more exact estimate on the 
% lapse rate/upper asymptote plug in 
options.stepN=[40,40,50,20,20];
% now the lapse rate is sampled at 50 places giving you a much more exact
% and smooth curve for comparisons.


%% options.confP          = [.95,.9,.68]
% The confidence level for the computed confidence intervals.
% This may be set to any number between 0 and 1 excluding.

% for example to get 99% confidence intervals try 
options.confP          = .99;

% You may specify a vector as well. If you do the conf_intervals in the
% result will be a 5x2xN array containing the values for the different
% confidence levels in the 3rd dimension. 

options.confP = [.95,.9,.68,.5];
% will return 4 confidence intervals for each parameter for example.



%% options.threshPC       = .5
% Which percent correct correspond to the threshold? 
% Given in Percent correct on the unscaled sigmoid (reaching from 0 to 1).

% For example to define the threshold as 90% correct try:  

options.threshPC       = .9;



%% options.CImethod       ='stripes'
% This sets how the confidence intervals are computed in getConfRegion.m
% possible variants are:
%       'project' -> project the confidence region on each axis

%       'stripes' -> find a threshold with (1-alpha) above it

% This will disregard intervals of low posterior probability and then move
% in from the sides to adjust the exact CI size.
% This can handle borders and asymmetric distributions slightly better, but
% will introduce slight jumps of the confidence interval when confp is
% adjusted depending on when the gridpoints get too small posterior
% probability.

%   'percentiles' -> find alpha/2 and 1-alpha/2 percentiles
%                    (alpha = 1-confP)

% cuts at the estimated percentiles-> always tries to place alpha/2
% posterior probability above and below the credible interval.
% This has no jumping but will exclude border values even when they have
% the highest posterior. Additionally it will not choose the area of
% highest posterior density if the distribution is skewed. 

%% options.priors  = getStandardPriors()
% This field contains a cell array of function handles, which define the
% priors for each parameter.
% If you want to set your priors manually, here is the place for it.

% For details on how do change these refer to 
% https://github.com/wichmann-lab/psignifit/wiki/Priors


%% options.betaPrior      = 20
% this sets the strength of the Prior in favor of a binomial observer.
% Larger values correspond to a stronger prior. We choose this value after
% a rather large number of simulations. Refer to the paper to learn more
% about this

%% options.useGPU         = 0;
% this option allows you to use your graphics card to do the
% computations, which can speed them up considerably, if it works. Set it
% to the ID of the graphics card to use. Usually this is 1 if you do not
% have multiple graphic cards in your computer.

%% options.nblocks        = inf;
%% options.poolMaxGap     = inf;       
%% options.poolMaxLength  = 50;      
%% options.poolxTol       = 0;        
% these options set how your data is pooled into blocks. Your data is only
% pooled if your data Matrix has more than nblocks lines. Then we pool
% together a maximum of poolMaxLength trials, which are separated by a
% maximum of poolMaxGap trials of other stimulus levels. If you want you may 
% specify a tolerance in stimulus level to pool trials, but by default we 
% only pool trials with exactly the same stimulus level.



%% options.instantPlot    = 0
% A boolean to control whether you immediately get 2 standard plots of your
% fit. Turn to 1 to see the effect.
options.instantPlot    = 1;

%% options.borders
% In this field you may provide your own bounds for the parameters.
% This should be a 5x2 matrix of start and end of the range for the 5
% parameters. (threshold,width,upper asymptote,lower asymptote,variance
% scale)

%For example this would set the borders to 
options.borders= [ 1,2  ...   % threshold between 1 and 2
                  .1,5  ...   % width between .1 and 5
                 .05,.05...   % a fixed lapse rate of .05
                  .5,.5 ...   % a fixed lower asymptote at .05
            exp(-20),.2];     % a maximum on the variance scale of .2

% NOTE: By this you artificially exclude all values out of this range. Only
% exclude parameter values, which are truely impossible!
 

%% options.maxBorderValue = exp(-10)
% Parts of the grid which produce marginal values below this are considered
% 0 and are excluded from the calculation in moveBorders.m 
% it should be a very small value and at least smaller than 1/(max(stepN))

% This for example would exclude fewer values and more conservative
% movement of the borders:
options.maxBorderValue = exp(-20);

%% options.moveBorders    = 1
% Toggles the movement of borders by moveBorders.m 
% Usually this is good to concentrate on the right area in the parameter
% space.
options.moveBorders    = 1;

% If you set
options.moveBorders    = 0;
% your posterior will always use the initial setting for the borders.
% This is usefull if you set options.borders by hand and do not want
% psignifit to move them after this.

%% options.dynamicGrid    = 0
% Toggles the useage of a dynamic/adaptive grid.
% there was hope for a more exact estimate by this, but although the curves
% look smoother the confidence intervals were not more exact. Thus this is
% deactivated by default.
options.dynamicGrid    = 1;
options.dynamicGrid    = 0;

% options.GridSetEval    = 10000
% How many Likelihood evaluations are done per dimension to set the
% adaptive grid. Should be a relatively large number.
options.GridSetEval    = 10000;
% Only used with dynamic grid,-> by default not at all


% options.UniformWeight  = 0.5000
% How many times the average is added to each position while setting the
% adaptive grid. You may increase this number to get a more equally sampled
% grid or decrease it to get an even stronger focus of the sampling on the
% peak.
% When you increase this value very much try to set options.dynamicGrid
% = 0; which produces an equal stepsize grid right away.

% As an example: Will produce a more focused grid which leaves the borders
% very weakly sampled.
options.UniformWeight  = 0.01000;
% Only used with dynamic grid,-> by default not at all


%% options.widthalpha     = .05
% This changes how the width of a psychometric function is defined
% width= psi^(-1)(1-alpha) - psi^(-1)(alpha)
% where psi^(-1) is the inverse of the sigmoid function.
% widthalpha must be between 0 and .5 excluding

% Thus this would enable the useage of the interval from .1 to .9 as the
% width for example:
options.widthalpha     = .1;

%% options.logspace:      = 0
% this is triggered when you fit lognormal or Weibull functions, which are
% fitted in logspace. This is an internal variable which is used to pass
% this to all functions. It is of no interest for a user.

