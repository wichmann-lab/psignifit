%% demo_006 additonal functionality
% This demo shows some convenience functions we added, which are not
% directly used for the final fitting of psychometric functions. 

% We will need some fitted function for illustration. Thus we first fit our
% standard data from demo_001.m again:
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
options             = struct;   % initialize as an empty struct
options.sigmoidName = 'norm';   % choose a cumulative Gauss as the sigmoid
options.expType     = '2AFC';   % choose 2-AFC as the paradigm of the experiment
res = psignifit(data,options);

%% obtaining threshold values 
% For comparison to other estimation techniques we provide functions to
% calculate thresholds at any given percent correct. 

% The first function is getThreshold(result, pCorrect, unscaled). It
% calculates the threshold of the function fit in result with pCorrect
% proportion correct. Unscaled toggles, whether you refer to the pCorrect
% obtained in the experiment (default), or to the percent correct on the
% original function unscaled by guessing and lapse rate.

% For example: This call will find the value at which our function reaches
% 90% correct:
getThreshold(res,0.9)
% which should be 0.0058 

% A usecase for the unscaled case might be to find the threshold for the
% middle of the psychometric function independent of the guessing and lapse
% rate:
getThreshold(res,0.5,1)
% which should be 0.0046, which is exactly the definition of the threshold
% we use in the fitting.

% The function also computes worst case credible intervals for the
% threshold. 

[threshold,CI] = getThreshold(res,0.5,1)

% The credible intervals are for the confidence levels given for your
% function fit. 
% The estimates calculated by this function are very conservative, when
% you move far away from the original threshold, as we simply assume the
% worst case for all other parameters instead of averaging over the values
% correctly.

%% Obtaining slope values
% We also provide two functions to calculate the slope of the psychometric
% function from the fits.
% These functions provide no credible intervals.

% getSlope(res,stimLevel), will calculate the slope at a given stimulus
% level. 
% For example: 
getSlope(res,0.006)
% Will yield the slope at 0.006, which is 89.0673

% getSlopePC(res,pCorrect,unscaled), will calculate the slope at a given 
% percent correct.
% For example: 
getSlopePC(res,0.6)
% Will yield the slope at the value where the psychometric function reaches
% 60% correct (at 0.0034). This slope is 98.3160.

% as for the getThreshold function, the unscaled option allows you to
% specify the percent correct on the unscaled sigmoid instead. 
% For example we can calculate the slope at the midpoint of the
% psychometric function using:
getSlopePC(res,0.5,1)
% This slope is 140.0991

%% Bias Analysis
% For 2AFC experiments it makes sense to check whether the observers are
% biased, i.e. whether they treat the two alternative answers differently.
% To facilitate such checks we provide a function
% biasAna(data1,data2,options), which we demonstrate in this section.

% In the background this function calculates fits with changed priors
% on the guessing and lapse rate, to leave the guessing rate free with only
% a weak prior (beta(2,2)) to be near 0.5. To allow this in the fitting we
% have to constrain the lapse rate to the range [0,0.1] leaving the range
% [0,0.9] for the guessing rate.

% To use the function we first have to separate our dataset to produce two
% separate datasets for the two alternatives (i.e. for signal in first
% interval vs. signal in second interval; signal left vs signal right, etc.)

% For demonstration purposes we produce different pairs of datasets, which
% combine to our standard test dataset (data11 and data12, data21 and data22,
% and data31 and data32 are a pair each:

data11 = [...
    0.0010,   22.0000,   45.0000;...
    0.0015,   27.0000,   45.0000;...
    0.0020,   24.0000,   47.0000;...
    0.0025,   20.0000,   44.0000;...
    0.0030,   27.0000,   45.0000;...
    0.0035,   27.0000,   44.0000;...
    0.0040,   30.0000,   45.0000;...
    0.0045,   30.0000,   44.0000;...
    0.0050,   39.0000,   43.0000;...
    0.0060,   40.0000,   46.0000;...
    0.0070,   47.0000,   48.0000;...
    0.0080,   47.0000,   47.0000;...
    0.0100,   42.0000,   42.0000];

data12 = [...
    0.0010,   23.0000,   45.0000;...
    0.0015,   23.0000,   45.0000;...
    0.0020,   20.0000,   43.0000;...
    0.0025,   24.0000,   46.0000;...
    0.0030,   25.0000,   45.0000;...
    0.0035,   26.0000,   46.0000;...
    0.0040,   32.0000,   45.0000;...
    0.0045,   34.0000,   46.0000;...
    0.0050,   37.0000,   47.0000;...
    0.0060,   38.0000,   44.0000;...
    0.0070,   41.0000,   42.0000;...
    0.0080,   43.0000,   43.0000;...
    0.0100,   48.0000,   48.0000];


data21 = [...
    0.0010,   33.0000,   45.0000;...
    0.0015,   37.0000,   45.0000;...
    0.0020,   36.0000,   47.0000;...
    0.0025,   32.0000,   44.0000;...
    0.0030,   36.0000,   45.0000;...
    0.0035,   36.0000,   44.0000;...
    0.0040,   37.0000,   45.0000;...
    0.0045,   36.0000,   44.0000;...
    0.0050,   42.0000,   43.0000;...
    0.0060,   43.0000,   46.0000;...
    0.0070,   47.0000,   48.0000;...
    0.0080,   47.0000,   47.0000;...
    0.0100,   42.0000,   42.0000];

data22 = [...
    0.0010,   12.0000,   45.0000;...
    0.0015,   13.0000,   45.0000;...
    0.0020,   8.0000,   43.0000;...
    0.0025,   12.0000,   46.0000;...
    0.0030,   16.0000,   45.0000;...
    0.0035,   17.0000,   46.0000;...
    0.0040,   25.0000,   45.0000;...
    0.0045,   28.0000,   46.0000;...
    0.0050,   34.0000,   47.0000;...
    0.0060,   35.0000,   44.0000;...
    0.0070,   41.0000,   42.0000;...
    0.0080,   43.0000,   43.0000;...
    0.0100,   48.0000,   48.0000];


data31 = [...
    0.0010,   22.0000,   45.0000;...
    0.0015,   25.0000,   45.0000;...
    0.0020,   24.0000,   47.0000;...
    0.0025,   20.0000,   44.0000;...
    0.0030,   20.0000,   45.0000;...
    0.0035,   21.0000,   44.0000;...
    0.0040,   22.0000,   45.0000;...
    0.0045,   25.0000,   44.0000;...
    0.0050,   32.0000,   43.0000;...
    0.0060,   35.0000,   46.0000;...
    0.0070,   46.0000,   48.0000;...
    0.0080,   47.0000,   47.0000;...
    0.0100,   42.0000,   42.0000];

data32 = [...
    0.0010,   23.0000,   45.0000;...
    0.0015,   25.0000,   45.0000;...
    0.0020,   20.0000,   43.0000;...
    0.0025,   24.0000,   46.0000;...
    0.0030,   32.0000,   45.0000;...
    0.0035,   32.0000,   46.0000;...
    0.0040,   40.0000,   45.0000;...
    0.0045,   39.0000,   46.0000;...
    0.0050,   44.0000,   47.0000;...
    0.0060,   43.0000,   44.0000;...
    0.0070,   42.0000,   42.0000;...
    0.0080,   43.0000,   43.0000;...
    0.0100,   48.0000,   48.0000];

% now we can check whether our different pairs show biased behaviour:

% We start with the first pair of data:
biasAna(data11,data12,options)
% This command will open a figure, which constains plots for the first
% dataset alone (red), for the second dataset alone (blue) and for the
% combined dataset (black).

% The top plot show the three psychometric functions, which for the first
% split of the data lie neatly on top of each other, suggesting already
% that the psychometric functions obtained for the two intervals are very
% similar and that no strong biases occured.

% Below there are posterior marginal plots for the threshold, width, lapse
% rate and guessing rate. These plots are diagnostic which aspects of the
% psychometric function changed between intervals. 
% For our first example these plots all confirm the first impression
% obtained from the first plot. It seems neither of the parameters has
% changed much. 

% Next, we check our second split of data:
biasAna(data21,data22,options)

% In this case there seems to be very strong "finger bias", i.e. the
% observer is much better at guessing in one than in the other part of the
% data. This can happen, when observer do not guess the two intervals
% with equal probability. 

% This bias can be seen directly in the fitted psychometric functions, but
% also in the marginal distributions, which show that the guessing rate
% gamma is very different for the two passed datasets, but the other
% parameters are still consistent.

% As this kind of bias leads to relatively undisturbed inference for 
% threshold and width, the estimates from the original function might still
% be usable.

% Now we have a look at our third splitting:
biasAna(data31,data32,options)

% In this case the guessing rate does not seem to differ between intervals,
% but the psychometric functions are shifted, i.e. the task was easier in
% one than in the other case. 

% This can be observed in the plotted functions again or by observing that
% the posterior clearly favours different thresholds for the two parts of
% the data. 

% If this type of bias occurs one should be careful in interpreting the
% results, as it seems that the two allegedly equal variants of the
% experiment would not yield equal results. 
% Also the width estimate of the combined function will not be the width of
% the two functions in the two intervals, contaminating this measure as
% well.


% In summary: Use these plots to find if the psychometric functions for the
% two alternatives in 2AFC differ. This should allow you to find the
% relatively harmless biases in the guessing of observers and the much more
% harmful biases in true performance. 
% This is especially important as all biases we demonstrated here cannot be
% detected by looking at the combined psychometric function only. 
% In real datsets the biases we demonstrated can be combined. Nonetheless
% the plots of the marginals should allow a separation of the different
% biases.


%% plotsModelfit
% We offer you a function which creates the plots psignifit 2 created for
% checking the modelfit.
% It can be run with the following command follows:

plotsModelfit(res)

% This method will show you three plots, based on the deviance residuals,
% which are the normalized deviations from the fitted psychometric function:
% 1) the psychometric function with the data around it as a first general
% check.
% 2) deviance residuals against the stimulus level. This is a check whether
% the data systematicall lie above or below the psychometric function at a
% range of stimulus levels. The three lines are polinomials of first
% second and third order fitted to the points. If these dots deviate
% strongly and/or systematically from 0, this is worrysome. Such deviations
% indicate that the shape of the psychometric function fitted does not
% match the data.
% 3) deviance residuals against the block order. This plot is meant as a help 
% to detect, when performance changes over time. Assuming that your blocks
% somewhat reflect the order in which the data were collected, this shows
% you how the deviations from the psychometric function changed over time. 
% Again strong and/or systematic deviations from 0 are a cause for worry.


%% Quick and dirty mode
% To fit functions fast, for example during experiments or to have a fast
% early look at your data

resFast = psignifitFast(data,options);

% To reduce processing time this function changes three aspects:
% 1) It uses only a binomial model instead of the full beta-binomial model 
%      sacrificing robustness against overdispersion
% 2) It reduces the number of gridpoints to evaluate the posterior
% 3) It limits the number of function evaluations for the final optimization
%      to find the MAP. 

% Using this function will issue warnings and will not provide you with 
% credible intervals as the grid we use here to evaluate the posterior 
% is probably not dense enough for this type of inference and the 
% beta-binomial model was deactivated. Otherwise the result struct has 
% the same structure as for the full analysis.
