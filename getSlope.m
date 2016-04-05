function slope = getSlope(result, stimLevel)
% function slope = getSlope(result, stimLevel, unscaled)
% This function finds the slope of the psychometric function at a given
% performance level in percent correct.
%
% result is a result struct from psignifit
%
% stimLevel is the stimuluslevel where to evaluate the slope
%
% This function cannot provide credible intervals. 


if isstruct(result)
    theta0 = result.Fit;
else
    error('Result needs to be a result struct generated by psignifit');
end


%% calculate point estimate -> transform only result.Fit

alpha = result.options.widthalpha;
if isfield(result.options,'threshPC')
    PC    = result.options.threshPC;
else
    PC = 0.5;
end

% find the (normalized) stimulus level, where the given percent correct is
% reached and evaluate slope there
switch result.options.sigmoidName
    case {'norm','gauss'}   % cumulative normal distribution
        C         = my_norminv(1-alpha,0,1) - my_norminv(alpha,0,1);
        normalizedStimLevel = (stimLevel-theta0(1))/theta0(2).*C;
        slopeNormalized = normpdf(normalizedStimLevel);
        slope = slopeNormalized *C./theta0(2);
    case 'logistic'         % logistic function
        C = 2 * log(1./alpha - 1) ./ theta0(2);
        d = log(1/PC-1);
        slope = C.*exp(-C.*(stimLevel-theta0(1))+d)./(1+exp(-C.*(stimLevel-theta0(1))+d)).^2;
    case 'gumbel'           % gumbel
        % note that gumbel and reversed gumbel definitions are sometimesswapped
        % and sometimes called extreme value distributions
        C      = log(-log(alpha)) - log(-log(1-alpha));
        stimLevel = C./theta0(2).*(stimLevel-theta0(1))+log(-log(1-PC));
        slope = C./theta0(2).*exp(-exp(stimLevel)).*exp(stimLevel);
    case 'rgumbel'          % reversed gumbel
        % note that gumbel and reversed gumbel definitions are sometimesswapped
        % and sometimes called extreme value distributions
        C      = log(-log(1-alpha)) - log(-log(alpha));
        stimLevel = C./theta0(2).*(stimLevel-theta0(1))+log(-log(PC));
        slope = -C./theta0(2).*exp(-exp(stimLevel)).*exp(stimLevel);
    case 'logn'             % cumulative lognormal distribution
        C      = my_norminv(1-alpha,0,1) - my_norminv(alpha,0,1);
        normalizedStimLevel = (log(stimLevel)-theta0(1))/theta0(2);
        slopeNormalized = normpdf(normalizedStimLevel);
        slope = slopeNormalized *C./theta0(2)./stimLevel; 
        
    case {'Weibull','weibull'} % Weibull
        C      = log(-log(alpha)) - log(-log(1-alpha));
        stimLevelNormalized = C./theta0(2).*(log(stimLevel)-theta0(1))+log(-log(1-PC));
        slope = C./theta0(2).*exp(-exp(stimLevelNormalized)).*exp(stimLevelNormalized);
        slope = slope./stimLevel;
    case {'tdist','student','heavytail'}
        % student T distribution with 1 df
        %-> heavy tail distribution
        C      = (my_t1icdf(1-alpha) - my_t1icdf(alpha));
        stimLevel = (stimLevel-theta0(1))./theta0(2).*C+my_t1icdf(PC);
        slope = C./theta0(2).*tpdf(stimLevel,1);
    otherwise
        error('unknown sigmoid function');
end

slope = (1-theta0(3)-theta0(4))*slope;