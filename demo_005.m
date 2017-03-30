%% demo_005 Plotting Functions

% Here the basic plot functions which come with the toolbox are explained. 
% Most of the functions return the handle of the axis they plotted in 
% to enable you to plot further details and change axis properties after the plot. 

% In our Wiki on Github you will find a file explaining these functions as
% well together with the plots generated to check your results.


% To have something to plot we use the example data as provided in
% demo_001:
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
options.expType     = '2AFC';

result = psignifit(data,options);

%% plotPsych 
%This funciton plots the fitted psychometric function with the measured data. 
% It takes the result struct you want to plot and an struct with plotting options as input.

    plotOptions = struct;
    plotPsych(result,plotOptions);

%The following fields of the plotOptions struct may be provided (the value gives the standard value):

    plotOptions.h              = gca;              % axes handle to plot in
    plotOptions.dataColor      = [0,105/255,170/255];  % color of the datapoints
    plotOptions.plotData       = 1;                % Shall the data be plotted at all?
    plotOptions.lineColor      = [0,0,0];          % Color of the psychometric function
    plotOptions.lineWidth      = 2;                % Thikness of the psychometric function
    plotOptions.xLabel         = 'Stimulus Level'; % X-Axis label
    plotOptions.yLabel         = 'Percent Correct';% Y-Axis label
    plotOptions.labelSize      = 15;               % Font size for labels
    plotOptions.fontSize       = 10;               % Tick Font size
    plotOptions.fontName       = 'Helvetica';      % Font type
    plotOptions.tufteAxis      = false;            % use customly drawn axis 
    plotOptions.plotPar        = true;             % plot indications of threshold and asymptotes
    plotOptions.aspectRatio    = false;            % sets the aspect ratio to a golden ratio
    plotOptions.extrapolLength = .2;               % how far to extrapolate from the data
                                                   % (in proportion of the datarange) 
    plotOptions.CIthresh       = false;            % plot a confidence interval at threshold

%% plotMarginal
%This function plots the marginal posterior density for a single parameter. As input it requires a results struct, the parameter to plot and optionally a handle to an axis to plot in and an options struct. (As usual 1 = threshold, 2 = width, 3 = lambda, 4 = gamma, 5 = eta)

    %plotMarginal(result,dim,plotOptions)
    plotOptions = struct;
    plotMarginal(result,1,plotOptions);

%The gray shadow corresponds to the chosen confidence interval and the black line shows the point estimate for the plotted parameter. The prior is also included in the plot as a gray dashed line.

%In the options struct you may set the following options again with their respective default values assigned to change the behaviour of the plot:

    plotOptions.h              = gca;                 % axes handle to plot in
    plotOptions.lineColor      = [0,105/255,170/255]; % color of the density
    plotOptions.lineWidth      = 2;                   % width of the plotline
    plotOptions.xLabel         = [parameter name];    % X-Axis label
    plotOptions.yLabel         = 'Marginal Density';  % Y-Axis label
    plotOptions.labelSize      = 15;                  % Font size for the label
    plotOptions.tufteAxis      = false;               % custom axis drawing enabled
    plotOptions.prior          = true;                % include the prior as a dashed weak line
    plotOptions.priorColor     = [.7,.7,.7];          % color of the prior distibution
    plotOptions.CIpatch        = true;                % draw the patch for the confidence interval
    plotOptions.plotPE         = true;                % plot the point estimate?


%% plot2D
%This plots 2 dimensional posterior marginals. As input this function expects the result struct, two numbers for the two parameters to plot against each other and optionally a handle h to the axis to plot in and an options struct for further options.

    %plot2D(result,par1,par2,plotOptions)
    plotOptions = struct;
    plot2D(result,1,2,plotOptions);

%As options the following fields in plotOptions can be set: 

    plotOptions.h         = gca;               % axes handle to plot in
    plotOptions.colorMap  = getColormap;       % A colormap for the posterior
    plotOptions.labelSize = 15;                % FontSize for the labels
    plotOptions.fontSize  = 10;                % FontSize for the ticks
    plotOptions.label1    = '[parameter name]';   % label for the first parameter
    plotOptopms.label2    = '[parameter name]';   % label for the second parameter

%% plotBayes
% This function is a tool to look at the posterior density of the parameter. 
% It plots a grid of all 2 paramter combinations of marginals. 
% By klicking on them you can enlarge and shrink them again. If a parameter 
% is fixed in the analysis you will see a 1 dimensional plot in the overview 
% and the enlarging will give you the one dimensional marginal plot.

    plotBayes(result);

%You may provide an additional plotOptions struct, but it does not provide much options.


%% plotPrior
%As a tool this function plots the actually used priors of the provided result struct.

    plotPrior(result);
    
