function simulate_data(filename,expType,obsType,levelType,N,sigmoidName)
% this function simulates data and saves it to a file
% function simulate_data(filename,expType,obsType,levelType,N,iSigmoidGen,iSigmoidFit)
% the function is based on the simulation functions for the paper

addpath('..')
warning('off','psignifit:pooling')

% get random numbers from a new set
rng('shuffle')

% factor for widht correction
Cfactor   = (my_norminv(.95,0,1) - my_norminv(.05,0,1))./( my_norminv(.95,0,1) - my_norminv(.05,0,1));

% dimensionality of parameter
d      = 5;

% parameter for the sequential dependent observer.
% the contrast seems to be Cseq higher for trials when the observer was
% right in the trial before and Cseq lower when he/she was wrong
Cseq     = .2;

% parameter for the fluctuating observer
% it starts with the threshold and then adds an error with a normal
% distribution with std = CfluctError. It simultaneously decays back to the
% original threshold with decay constant CfluctDecay
CfluctError = .05;
CfluctDecay = .95;

% tested Prior on beta (beta(1,betaprior))
betaPrior = 10;

% define finalized psignifit options
options = struct;
options.expType   = expType;
options.betaPrior = 1;
options.threshPC  = 0.5;

%choose threshold and width
thresh = 1;
width  = 1./Cfactor;

%% choose levels
width = Cfactor *width;
switch levelType
    % all blocks level setting include half the blocks above and half the
    % blocks below threshold
    case {'Blocks5_random','Blocks5_random_reorder'}            % 5 blocks
        % for 5 blocks three above because it does not fit otherwise
        levels = thresh-width+2*rand(5,1)*width;
    case {'Blocks10_random','Blocks10_random_reorder'}          % 10 blocks
        levels = thresh-width+2*rand(10,1)*width;
    case {'Blocks20_random','Blocks20_random_reorder'}          % 20 blocks
        levels = thresh-width+2*rand(20,1)*width;
    case {'Blocks5_fix','Blocks5_fix_reorder'}               % 5 blocks
        levels = linspace(thresh-.75*width,thresh+.75*width,5)';
    case {'Blocks10_fix','Blocks10_fix_reorder'}              % 10 blocks
        levels = linspace(thresh-.75*width,thresh+.75*width,10)';
    case {'Blocks20_fix','Blocks20_fix_reorder'}              % 20 blocks
        levels = linspace(thresh-.75*width,thresh+.75*width,20)';
    case {'N1_fix','N1_fix_reorder'}                    % N levels linearly spaced threshold +- width
        levels = linspace(thresh-.75*width,thresh+.75*width,N)';
    case 'N1_random'                 % N levels randomly between threshold +- width
        levels = [thresh-width+2*rand(N,1)*width];
    case '3down1up'             % simple adaptive sampling
        % nothing to do here !!
        % levels chosen while sampling
        options.stimulusRange = [.25,1.75]; % adjusted prior
    case 'Quest'
        % nothing to do here !!
        % levels chosen while sampling
        options.stimulusRange = [.25,1.75]; % adjusted prior
    case 'optimal'
        lapse = .05;
        % actually not used
        switch expType
            case 'YesNo'
                gamma = .1*rand;
            case '2AFC'
                gamma = .5;
                options.expN=2;
            case 'equalAsymptote'
                gamma = lapse;
        end
        theta0 = [thresh;width;.05;gamma;0];
        levels = getSamplePoints(theta0,'logistic'); % according to paper optimal points to obtain info about parameters
end
width = width./Cfactor;

if strcmp(sigmoidName, 'Weibull') || strcmp(sigmoidName, 'logn')
    if ~strcmp(levelType,'3down1up') && ~strcmp(levelType,'Quest')
        levels = exp(levels);
    end
end


%choose #trials
if ~strcmp(levelType,'3down1up') && ~strcmp(levelType,'Quest')
    ntotal = floor(N/length(levels))*ones(size(levels));
    indAdd = randperm(length(levels)); % which positions get an additional run
    indAdd = indAdd(1:mod(N,length(levels)));
    ntotal(indAdd) = ntotal(indAdd) + 1;   % add sample
end

sigmoid = getSigmoidHandle(sigmoidName);
options.sigmoidName = sigmoidName;
options.sigmoidHandle = getSigmoidHandle(options);


%% choose generating parameter
lapse  = .1*rand;

switch expType
    case 'YesNo'
        gamma = .1*rand;
    case '2AFC'
        gamma = .5;
        options.expN=2;
    case 'equalAsymptote'
        gamma = lapse;
end
pthreshold = gamma + .5*(1-lapse-gamma);

switch obsType
    case 'binom'
        sigma = 0;
    case 'beta'
        sigma = .2;
    case 'strongBeta'
        sigma = .5;
    case 'learning'
        sigma = NaN;
    case 'sequential'
        sigma = NaN;
    case 'fluct'
        sigma = NaN;
    case 'seqReal'
        sigma = NaN;
end

theta0 = [thresh;width;lapse;gamma;sigma];
options.theta0 = theta0;
%% generate Data
% generate data blockwise binomial or beta
% init levels
if exist('levels','var')
    levels1Trial = [];
    for i = 1:length(levels)
        levels1Trial = [levels1Trial;repmat(levels(i),ntotal(i),1)];
    end
    levels = levels1Trial;
    clear levels1Trial;
    if regexp(levelType,'reorder')
        levels = levels(randperm(length(levels)));
    end
else
    levels = nan(N,1);
end
% quest init
if strcmp(levelType,'Quest')
    if iSigmoidGen > 5
        q=QuestCreate(exp(1),3,pthreshold,4,lapse,gamma);
    else
        q=QuestCreate(1,2,pthreshold,4,lapse,gamma);
    end
    levels(1) = QuestQuantile(q);
end
% 3 down 1 up init
if strcmp(levelType,'3down1up')
    if iSigmoidGen == 6 || iSigmoidGen == 7
        levels(1) = exp(thresh+.5*width);
    else
        levels(1) = thresh+.5*width;
    end
end
% preallocate
ncorrect = nan(N,1);
ntotal   = ones(N,1);
threshRecord = nan(N,1);
widthRecord  = nan(N,1);
%% trials
for itrial = 1:N
    %choose threshold/width
    switch obsType
        case 'sequential'
            if itrial > 1
                if ncorrect(itrial-1)
                    threshCorrected = thresh - Cseq;
                else
                    threshCorrected = thresh + Cseq;
                end
            else
                threshCorrected = thresh;
            end
            widthCorrected  = width;
        case 'learning'
            threshCorrected = (1+Cthresh* 2^((1-itrial)/halftime))*thresh;
            widthCorrected  = (1+Cwidth * 2^((1-itrial)/halftime))*width;
        case 'fluct'
            if itrial > 1
                threshCorrected = thresh+CfluctDecay*(threshCorrected-thresh)+CfluctError.*normrnd(0,1);
                widthCorrected  = width;
            else
                threshCorrected = thresh;
                widthCorrected  = width;
            end
        case 'seqReal'
            if itrial > 1
                if ncorrect(itrial-1)
                    sideOld = sideStim;
                else
                    sideOld = 3-sideStim; % the other one
                end
                sideStim = randi(2);
                if ncorrect(itrial-1)
                    if sideOld == sideStim
                        threshCorrected = thresh -Cseq;
                        widthCorrected  = width;
                    else
                        threshCorrected = thresh +Cseq;
                        widthCorrected  = width;
                    end
                else % last trial wrong
                    if sideOld == sideStim
                        threshCorrected = thresh +Cseq;
                        widthCorrected  = width;
                    else
                        threshCorrected = thresh -Cseq;
                        widthCorrected  = width;
                    end
                    
                end
            else
                threshCorrected = thresh;
                widthCorrected  = width;
                sideStim = randi(2);
            end
        otherwise
            threshCorrected = thresh;
            widthCorrected  = width;
    end
    threshRecord(itrial) = threshCorrected;
    widthRecord(itrial)  = widthCorrected;
    %draw trial
    
    if strcmp(obsType,'beta') || strcmp(obsType,'strongBeta')% this line was wrong and costed us a MONTH at least....
        if itrial<=1 || levels(itrial-1)~=levels(itrial) %whenever the stimulus level changes
            psigf = gamma + (1-lapse-gamma)*sigmoid(levels(itrial),threshCorrected,widthCorrected);
            psigf = betarnd(psigf.*(1./sigma.^2-1),(1-psigf).*(1./sigma.^2-1));
        end
    else
        psigf = gamma + (1-lapse-gamma)*sigmoid(levels(itrial),threshCorrected,widthCorrected);
    end
    ncorrect(itrial) = rand < psigf;
    
    if strcmp(levelType,'Quest')
        q = QuestUpdate(q,levels(itrial),ncorrect(itrial));
    end
    
    %choose level for next trial
    switch levelType
        case '3down1up'
            if itrial < 3
                if ncorrect(itrial)
                    levels(itrial+1) = levels(itrial);
                else
                    levels(itrial+1) = 1.1*levels(itrial);
                end
            elseif itrial < N
                if all(ncorrect((itrial-2):itrial)) && levels(itrial-1) == levels(itrial) && levels(itrial-1) == levels(itrial-2)
                    levels(itrial+1) = .9*levels(itrial);
                elseif ~ncorrect(itrial)
                    levels(itrial+1) = 1.1*levels(itrial);
                else
                    levels(itrial+1) = levels(itrial);
                end
            end
        case 'Quest'
            if itrial < N
                levels(itrial+1) = QuestQuantile(q);
            end
        otherwise
            %levels set a priori
    end
    
end

data = [levels,ncorrect,ntotal];

% save data into csv file:
dlmwrite([filename, '_data.csv'], data, 'delimiter', ',', 'precision', 25);

%% run psignifit with different priors
if isnan(betaPrior)
    if ~isfield(options,'fixedPars')
        options.fixedPars    = nan(5,1);
    end
    options.fixedPars(5) = 0;
    options.betaPrior    = 1;
else
    options.betaPrior    = betaPrior;
    options.fixedPars    = nan(5,1);
end
% fixed setting for pooling
options.poolxTol       = 0.05;
options.poolMaxLength  = inf;
options.poolMaxGap     = inf;
options.estimateType = 'MAP';

% fit data
resCurrent = psignifit(data,options);
% get mean estimate
Fit = zeros(d,1);
for id = 1:d
    Fit(id) = sum(resCurrent.marginals{id}.*resCurrent.marginalsW{id}.*resCurrent.marginalsX{id});
end
resCurrent.meanFit = Fit;
clear Fit;
% get MAP (was chosen as original fit)
resCurrent.MAP = resCurrent.Fit;

% save MATLAB options and result
resStruct = rmfield(resCurrent,{'Posterior','weight', 'options', 'psiHandle'});
optStruct = rmfield(options, 'sigmoidHandle');

fprintf(fopen([filename, '_opt.json'], 'w'), jsonencode(optStruct));
fprintf(fopen([filename, '_res.json'], 'w'), jsonencode(resStruct));

