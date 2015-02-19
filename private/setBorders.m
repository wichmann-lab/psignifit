function Borders=setBorders(data,options)
% automatically set borders on the parameters based on were you sampled.
%function Borders=setBorders(data,options)
% this function  sets borders on the parameter values of a given function
% automaically
%
% It sets: -the threshold to be within the range of the data +/- 50%
%          -the width to half the distance of two datapoints up to 10 times
%                   the range of the data
%          -the lapse rate to 0 to .5
%          -the lower asymptote to 0 to .5 or fix to 1/n for nAFC
%          -the varscale to the full range from almost 0 to almost 1



%lapse fix to 0 - .5
lapseB = [0, .5];

% for now gamma=.5 could be changed
if strcmp(options.expType,'nAFC')
    gammaB = [1/options.expN, 1/options.expN];
elseif strcmp(options.expType,'YesNo')
    gammaB = [0             , .5];
elseif strcmp(options.expType,'equalAsymptote')
    gammaB = [NaN           , NaN];
end

% varscale from 0 to 1, 1 excluded!
varscaleB = [0, 1 - exp(-20)];

if options.logspace
    data(:, 1) = log(data(:, 1));
end

% if range was not given take from data
if numel(options.stimulusRange)<=1
    options.stimulusRange = [min(data(:,1)),max(data(:,1))];
    stimRangeSet = true;
else 
    stimRangeSet = false;
end

% We then assume it is one of the reparameterized functions with
% alpha=threshold and beta= width
% The threshold is assumed to be within the range of the data +/-
% .5 times it's spread
dataspread = options.stimulusRange(2)-options.stimulusRange(1);                     % spread of the data
alphaB     = [options.stimulusRange(1) - .5 * dataspread, options.stimulusRange(2) + .5 * dataspread]; % threshold borders
% the width we assume to be between half the minimal distance of
% two points and 5 times the spread of the data

if length(unique(data(:,1)))>1 && ~stimRangeSet
    widthmin  = min(diff(sort(unique(data(:,1)))));
else
    widthmin = 100*eps(options.stimulusRange(2));
end
% We use the same prior as we previously used... e.g. we use the factor by
% which they differ for the cumulative normal function
Cfactor   = (my_norminv(.95,0,1) - my_norminv(.05,0,1))./( my_norminv(1-options.widthalpha,0,1) - my_norminv(options.widthalpha,0,1));
betaB      = [widthmin , 3./Cfactor * dataspread];                     % width borders


Borders = [alphaB; betaB; lapseB; gammaB; varscaleB];