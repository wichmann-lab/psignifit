%% demo_007 Legacy option conversion
% Demo_007 demonstrate the use of psignifit 4 for users of the Wichmann & Hill (2001) "legacy-toolbox" psignifit 2.5.
%
% The bootstrap-based psignifit 2.5 toolbox allowed the user to change the
% behaviour of the (constrained) ML-estimation, statistics and plots via a
% list of option and value pairs.
% Psignifit 4, on the other hand, expects the specification of the shape of
% the sigmoid of the psychometric function, or the experimental design to
% be supplied via an option struct.
% To ease the transition from the old to the new version of psignifit we
% provide a function called "PsignifitLegacyOptionsConverter.m".
% 
% Additionally psignifit 4 now expects the number of correct trials instead
% of the proportion correct in the data matrix. 


%% Feedback in the console
% "PsignifitLegacyOptionsConverter.m" provides a lot of feedback and
% warnings in the console. Please look at them carefully, as there are
% considerable differences between the old and the new version, and not all
% options have a simple one-to-one translation/conversion.

%% Data
% To have something to estimate and plot, we again use the example data as provided in
% demo_001, but now provided in the 2.5.6 format,
% i.e. with proportion correct in the second column:

data =    [...
    0.0010,   0.5000,   90.0000;...
    0.0015,   0.5556,   90.0000;...
    0.0020,   0.4889,   90.0000;...
    0.0025,   0.4889,   90.0000;...
    0.0030,   0.5778,   90.0000;...
    0.0035,   0.5889,   90.0000;...
    0.0040,   0.6889,   90.0000;...
    0.0045,   0.7111,   90.0000;...
    0.0050,   0.8444,   90.0000;...
    0.0060,   0.8778,   90.0000;...
    0.0070,   0.9778,   90.0000;...
    0.0080,   1.0000,   90.0000;...
    0.0100,   1.0000,   90.0000];

% The data format can be changed to the new one with this simple command:
data(:,2) = round(data(:,2).*data(:,3));

% The round command is necessary to remove the rounding errors which
% usually occure when saving the successrate as proportion correct. 

%% Convert the options and call psignifit 4:
options = PsignifitLegacyOptionsConverter('shape', 'Weibull', 'n_intervals', 2, 'conf', [0.023 0.977], 'runs', 1999)
result = psignifit(data, options);

% The conversion is quite verbose and in most cases more than one function 
% needs to be fit with the same settings. Thus we recommend to convert
% the options only once and then replace the call with a direct setting of
% the options.
% For the example this can be done as follows:
options = struct;
options.sigmoidName = 'weibull';
options.expType = 'nAFC';
options.expN = 2;
options.confP = 0.9500;



%% Basic plot of the psychometric function:
% Set a few plot options, see demo_005 or https://github.com/wichmann-lab/psignifit/wiki/Plot-functions
plotOptions = struct;
plotOptions.CIthresh = 'true';
plotOptions.aspectRatio = 'true';

plotPsych(result, plotOptions);
