function result=psignifit(data,options)
% main function for fitting psychometric functions
%function result=psignifit(data,options)
% This function is the user interface for fitting psychometric functions to
% data.
%
% pass your data in the n x 3 matrix of the form:
%       [x-value, number correct, number of trials]
%
% options should be a 1x1 struct in which you set the options for your fit.
% You can find a full overview over the options in demo002
%
% The result of this function is a struct, which contains all information
% the program produced for your fit. You can pass this as whole to all
% further processing function provided with psignifit. Especially to the
% plot functions.
% You can find an explanation for all fields of the result in demo003
%
%
% To get an introduction to basic useage start with demo001




%% input parsing
%% data
if all(data(:,2) <=1 & data(:,2) >= 0) && any(data(:,2) > 0 & data(:,2) < 1) % percent correct data
    data(:,2) = round(data(:,3).*data(:,2)); % we try to convert it to our notation
    % Note: No sanity checks here!
end


%% options
if ~exist('options','var'),                  options=struct;                          end
if ~isfield(options,'sigmoidName'),          options.sigmoidName    = 'norm';         end
if ~isfield(options,'expType'),              options.expType        = 'YesNo';        end
if ~isfield(options,'estimateType'),         options.estimateType   = 'MAP';          end
if ~isfield(options,'confP'),                options.confP          = [0.95,0.9,.68]; end
if ~isfield(options,'instantPlot'),          options.instantPlot    = 0;              end
if ~isfield(options,'maxBorderValue'),       options.maxBorderValue = .00001;         end
if ~isfield(options,'moveBorders'),          options.moveBorders    = 1;              end
if ~isfield(options,'dynamicGrid'),          options.dynamicGrid    = 0;              end
if ~isfield(options,'widthalpha'),           options.widthalpha     = .05;            end
if ~isfield(options,'threshPC'),             options.threshPC       = .5;             end
if ~isfield(options,'CImethod'),             options.CImethod       = 'percentiles';  end
if ~isfield(options,'gridSetType'),          options.gridSetType    = 'cumDist';      end
if ~isfield(options,'fixedPars'),            options.fixedPars      = nan(5,1);       end
if ~isfield(options,'nblocks'),              options.nblocks        = 25;             end
if ~isfield(options,'useGPU'),               options.useGPU         = 0;              end
if ~isfield(options,'poolMaxGap'),           options.poolMaxGap     = inf;            end
if ~isfield(options,'poolMaxLength'),        options.poolMaxLength  = inf;            end
if ~isfield(options,'poolxTol'),             options.poolxTol       = 0;              end
if ~isfield(options,'betaPrior'),            options.betaPrior      = 10;             end
if ~isfield(options,'verbose'),              options.verbose        = 0;              end
if ~isfield(options,'stimulusRange'),        options.stimulusRange  = 0;              end
if ~isfield(options,'fastOptim'),            options.fastOptim      = false;          end



if strcmp(options.expType,'2AFC'),
    options.expType        = 'nAFC';
    options.expN           = 2;
end
if strcmp(options.expType,'3AFC'),
    options.expType        = 'nAFC';
    options.expN           = 3;        
end
if strcmp(options.expType,'4AFC'),
    options.expType        = 'nAFC';
    options.expN           = 4;        
end

if all(~isnan(options.fixedPars(3:4)))
    if options.fixedPars(3)>(1-options.fixedPars(4))
        error('You fixed the lapse rate and the guessing rate to values corresponding to a decreasing sigmoid, which is not supported');
    end
elseif any(~isnan(options.fixedPars(3:4)))
    if ~isnan(options.fixedPars(3))
    end
end

if strcmp(options.expType,'nAFC') && ~isfield(options,'expN');
    error('For nAFC experiments please also pass the number of alternatives (options.expN)'); end

switch options.expType
    case 'YesNo'
        if ~isfield(options,'stepN'),   options.stepN   = [40,40,20,20,20];  end
        if ~isfield(options,'mbStepN'), options.mbStepN = [25,30,10,10,15];  end
    case 'nAFC'
        if ~isfield(options,'stepN'),   options.stepN   = [40,40,20,1,20];   end
        if ~isfield(options,'mbStepN'), options.mbStepN = [30,40,10,1,20];   end
        assert((options.mbStepN(4) == 1) && (options.stepN(4) == 1), 'For nAFC experiments gamma is fixed. The number of gridpoints for it must be 1!')
    case 'equalAsymptote'
        if ~isfield(options,'stepN'),   options.stepN   = [40,40,20,1,20];   end
        if ~isfield(options,'mbStepN'), options.mbStepN = [30,40,10,1,20];   end
        assert((options.mbStepN(4) == 1) && (options.stepN(4) == 1), 'For equal asymptote experiments gamma is fixed equal to lambda. The number of gridpoints for it must be 1!')
    otherwise
        error('You specified an illegal experiment type')
end

assert(max(data(:,1)) > min(data(:,1)) , 'Your data does not have variance on the x-axis! This makes fitting impossible')

% log space sigmoids
% we fit these functions with a log transformed physical axis
% This is because it makes the paramterization easier and also the priors
% fit our expectations better then.
% The flag is needed for the setting of the parameter bounds in setBorders

if any(strcmpi(options.sigmoidName,{'Weibull','logn','weibull'})) % This is NOT run if options.sigmoidName is a handle here
    options.logspace = 1;
    assert(min(data(:,1)) > 0, 'The sigmoid you specified is not defined for negative data points!');
else
    options.logspace=0;
end


% if range was not given take from data
if numel(options.stimulusRange)<=1
    if options.logspace
        options.stimulusRange = log([min(data(:,1)),max(data(:,1))]);
    else
        options.stimulusRange = [min(data(:,1)),max(data(:,1))];
    end
    stimRangeSet = false;
else
    stimRangeSet = true;
    if options.logspace
        options.stimulusRange = log(options.stimulusRange);
    end
end

if ~isfield(options,'widthmin')
    if length(unique(data(:,1)))>1 && ~stimRangeSet
        if options.logspace
            options.widthmin  = min(diff(sort(unique(log(data(:,1))))));
        else
            options.widthmin  = min(diff(sort(unique(data(:,1)))));
        end
    else
        options.widthmin = 100*eps(options.stimulusRange(2));
    end
end

% check gpuOptions
if options.useGPU && ~gpuDeviceCount
    warning('You wanted to use your GPU but MATLAB does not recognize any useable GPU. We thus disabled GPU useage')
    options.useGPU=0;
end
if options.useGPU
    gpuDevice(options.useGPU);
end


% add priors
if options.threshPC  ~= .5 && ~isfield(options,'priors')
    warning('psignifit:ThresholdPCchanged','You changed the percent correct corresponding to the threshold\n please check that the prior is still sensible!')
end

if ~isfield(options,'priors')
    options.priors         = getStandardPriors(options);
else 
    if iscell(options.priors)
        priors = getStandardPriors(options);
        % if provided priors are to short
        if length(options.priors)<5 
            options.priors = [options.priors,cell(1,5-length(options.priors))];
        end
        for ipar = 1:5
            if isa(options.priors{ipar},'function_handle')
                % use the provided prior
            else
                options.priors{ipar} = priors{ipar};
            end
        end
    else
        error('if you provide your own priors it should be a cell array of function handles')
    end
    %check priors 
    checkPriors(data,options);
end

% for dynamic grid setting
if options.dynamicGrid && ~isfield(options,'GridSetEval'),   options.GridSetEval   = 10000; end
if options.dynamicGrid && ~isfield(options,'UniformWeight'), options.UniformWeight = 1;    end



%% initialize

% Warning if many blocks were measured -> adaptive sampling?
if length(unique(data(:,1))) >= 25 && numel(options.stimulusRange)==1
    warning('psignifit:probablyAdaptive', 'The data you supplied contained >= 25 stimulus levels.\n Did you sample adaptively?\n If so please specify a range which contains the whole psychometric function in options.stimulusRange.\n This will allow psignifit to choose an appropriate prior.\n For now we use the standard heuristic, assuming that the psychometric function is covered by the stimulus levels\n, which is frequently invalid for adaptive procedures!')
end

% pool data if necessary
% -> more than options.nblocks blocks or only 1 trial per block
if max(data(:, 3)) == 1 || size(data, 1) > options.nblocks
    warning('psignifit:pooling','We pooled your data, to avoid problems with n=1 blocks or to save time fitting because you have a lot of blocks\n You can force acceptence of your blocks by increasing options.nblocks');
    data = poolData(data,options);
    %options.nblocks = size(data, 1);
else
    %options.nblocks = size(data, 1);
end

% Warning if few trials per block -> adaptive sampling
if all(data(:,3)<=5) && numel(options.stimulusRange)==1
    warning('psignifit:probablyAdaptive', 'All provided data blocks contain <= 5 trials \n Did you sample adaptively?\n If so please specify a range which contains the whole psychometric function in options.stimulusRange.\n This will allow psignifit to choose an appropriate prior.\n For now we use the standard heuristic, assuming that the psychometric function is covered by the stimulus levels\n, which is frequently invalid for adaptive procedures!')
end

% create function handle to the sigmoid
if ~isfield(options,'sigmoidHandle')
    options.sigmoidHandle = getSigmoidHandle(options);
    if isa(options.sigmoidName, 'function_handle')
        options.sigmoidName = 'Custom Handle Provided';
    end
else 
    if strcmp(options.sigmoidName,'norm') % i.e. sigmoidName not set by user
        options.sigmoidName = 'Custom Handle Provided';
    end
end
% borders of integration
if isfield(options, 'borders')
    borders = setBorders(options);
    options.borders(isnan(options.borders)) = borders(isnan(options.borders));
    options.borders(~isnan(options.fixedPars),1) = options.fixedPars(~isnan(options.fixedPars)); %fix parameter values
    options.borders(~isnan(options.fixedPars),2) = options.fixedPars(~isnan(options.fixedPars)); %fix parameter values
else
    options.borders = setBorders(options);
    options.borders(~isnan(options.fixedPars),1) = options.fixedPars(~isnan(options.fixedPars)); %fix parameter values
    options.borders(~isnan(options.fixedPars),2) = options.fixedPars(~isnan(options.fixedPars)); %fix parameter values
end

% normalize priors to first choice of borders

options.priors = normalizePriors(options);

if options.moveBorders
    options.borders = moveBorders(data,options);
end

% Warning for high confidence values
if any(options.confP > 0.95)
    warning('psingifit:confPLarge','You requested a confidence with higher confidence than 95%%. This was not thoroughly tested.');
end


%% core

result = psignifitCore(data, options);


%% after processing

%check that the marginals go to nearly 0 at the borders of the grid
if options.verbose > -5
    if result.marginals{1}(1).* result.marginalsW{1}(1) > .001
        warning('psignifit:borderWarning',...
           ['The marginal for the threshold is not near 0 at the lower border\n',...
            'This indicates that smaller Thresholds would be possible'])
    end
    if result.marginals{1}(end).* result.marginalsW{1}(end) > .001
        warning('psignifit:borderWarning',...
           ['The marginal for the threshold is not near 0 at the upper border\n',...
            'This indicates that your data is not sufficient to exclude much higher thresholds.\n',...
            'Refer to the paper or the manual for more info on this topic'])
    end
    if result.marginals{2}(1).* result.marginalsW{2}(1) > .001
        warning('psignifit:borderWarning',...
           ['The marginal for the width is not near 0 at the lower border\n',...
            'This indicates that your data is not sufficient to exclude much lower widths.\n',...
            'Refer to the paper or the manual for more info on this topic'])
    end
    if result.marginals{2}(end).* result.marginalsW{2}(end) > .001
        warning('psignifit:borderWarning',...
           ['The marginal for the width is not near 0 at the lower border\n',...
            'This indicates that your data is not sufficient to exclude much higher widths.\n',...
            'Refer to the paper or the manual for more info on this topic'])
    end
end

result.psiHandle = @(x) result.Fit(4)+ (1-result.Fit(3)-result.Fit(4))*result.options.sigmoidHandle(x,result.Fit(1),result.Fit(2));

[result.devianceResiduals,result.deviance] = getDeviance(result);

result.Cov = getCov(result);
result.Cor = getCor(result);

result.timestamp = datestr(now);

if options.instantPlot
    plotPsych(result);
    plotBayes(result);
end

