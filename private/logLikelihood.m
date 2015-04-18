function p = logLikelihood(data,options,alpha,beta,lambda,gamma,varscale)
% the core function to evaluate the logLikelihood of the data
%function p=logLikelihood(data,options,alpha,beta,lambda,gamma,varscale)
% Calculates the logLikelihood of the given data with given parameter
% values. It is fully vectorized and contains the core calculations of
% psignifit.
% this actually adds the log priors as well. Technically it calculates the
% unnormalized log-posterior
%
% We strongly suggest not to change this code!

sigmoidHandle = options.sigmoidHandle;

if ~exist('alpha', 'var')   || isempty(alpha),    error('not enough parameters'); end
if ~exist('beta', 'var')    || isempty(beta),     error('not enough parameters'); end
if ~exist('lambda', 'var')  || isempty(lambda),   lambda   = 0 ;                  end
if ~exist('gamma', 'var')   || isempty(gamma),    gamma    = .5;                  end
if ~exist('varscale','var') || isempty(varscale), varscale = 1 ;                  end


oneParameter = ~(numel(alpha) > 1 ||  ...         % is the input only one point?
    numel(beta) > 1 ||   ...
    numel(lambda) > 1 || ...
    numel(gamma) > 1 ||  ...
    numel(varscale) > 1);

if oneParameter  % in optimization if the parameter supplied is not the fixed value
                 % Replace it somewhere else because optimizing on this becomes random!   
    if isfinite(options.fixedPars(1))
        alpha = options.fixedPars(1);
    end
    if isfinite(options.fixedPars(2))
        beta = options.fixedPars(2);
    end
    if isfinite(options.fixedPars(3))
        lambda = options.fixedPars(3);
    end
    if isfinite(options.fixedPars(4))
        gamma = options.fixedPars(4);
    end
    if isfinite(options.fixedPars(5))
        varscale = options.fixedPars(5);
    end
end

% issues for automization: limit range for lambda & gamma
lambda(  lambda   < 0 | lambda   > 1-max(gamma )) = nan;
gamma(   gamma    < 0 | gamma    > 1-max(lambda)) = nan;
varscale(varscale < 0 | varscale > 1)             = nan;

varscaleOrig = reshape(varscale,1,1,1,1,[]);

useGPU = options.useGPU && ...                                 % did the user ask for GPU?
    ~oneParameter;                                                    %do we need the gpu?


if oneParameter
    if strcmp(options.expType,'equalAsymptote')
        gamma = lambda;                                                 % enforce equality
    end
    p = 0;
    scale =  1 - gamma - lambda;                                  % scaling of the sigmoid
    psi   = arrayfun(@(x) sigmoidHandle(x, alpha, beta), data(:,1));% value of the sigmoid
    psi   = gamma + scale*psi;                  % average probability of success predicted
    n     = data(:, 3);                                            % number of trials at x
    k     = data(:, 2);                                         % number of successes at x
    varscale = varscale.^2;
    if varscale < 10^-9
        p  = p + k .* log(psi) + (n-k) .* log(1-psi);                       % binomial model
    else
        v     = 1./varscale -1;
        a     = psi*v;                                            % alpha for betabinomial
        b     = (1-psi)*v;                                         % beta for betabinomial
        p     = p + gammaln(k + a);                                         % Betabinomial
        p     = p + gammaln(n - k + b);
        p     = p - gammaln(n + v);
        p     = p - gammaln(a) - gammaln(b);
        p     = p + gammaln(v);
    end
    p = sum(p);% add up loglikelihood
    % + (be-1).*log(1-varscale)-betaln(1,be); % add up loglikelihood and add prior
    if isnan(p)
        p = -inf;
    end
else % for grid evaluation! with bsxfuns
    %reshaping
    alpha   = reshape(alpha   ,[],1);
    beta    = reshape(beta    ,1,[]);
    lambda  = reshape(lambda  ,1,1,[]);
    gamma   = reshape(gamma   ,1,1,1,[]);
    varscale= reshape(varscale,1,1,1,1,[]);
    varscale= varscale.^2;                         % go from standard deviation to variance
    vbinom  = varscale < 10^-9;                 % for variances smaller than this we assume
    % the binomial model, otherwise numerical errors occur
    
    v       = varscale(~vbinom);
    v       = 1./v-1;
    v       = reshape(v       ,1,1,1,1,[]);
    p       = 0;                                                                % posterior
    pbin    = 0;                                        % posterior for binomial model part
    n       = size(data,1);
    levels  = data(:,1);                  % needed for GPU work, as we copy data to the GPU
    
    % use GPU if specified
    if useGPU
        gamma    = gpuArray(gamma);
        lambda   = gpuArray(lambda);
        v        = gpuArray(v);
        data     = gpuArray(data);
        p        = gpuArray(p);
        pbin     = gpuArray(pbin);
    end
    
    
    if strcmp(options.expType,'equalAsymptote')
        gamma = lambda;                                                       % enforce equality
    end
    scale = bsxfun(@(g,l) 1-g-l,gamma,lambda);                          % scaling of the sigmoid
    for i = 1:n
        if options.verbose > 3, fprintf('\r%d/%d', i, n);    end                 % show progress
        xi    = levels(i);                                                    % the ith location
        psi   = bsxfun(@(a,b) sigmoidHandle(xi, a, b), alpha, beta);      % value of the sigmoid
        psi   = bsxfun(@plus,bsxfun(@times, psi,scale), gamma);% average probability of success predicted
        if useGPU, psi = gpuArray(psi); end
        ni    = data(i, 3);                                             % number of trials at xi
        ki    = data(i, 2);                                          % number of successes at xi
        if (ni-ki)>0 && ki>0
            pbin  = pbin + ki * log(psi) + (ni-ki) * log(1-psi);                    % binomial model
            if ~isempty(v)                                                  % catch if only binomial
                a     = bsxfun(@times,psi,v);                               % alpha for betabinomial
                b     = bsxfun(@times,1-psi,v);                              % beta for betabinomial
                p     = p + gammaln(ki + a);                                          % Betabinomial
                p     = p + gammaln(ni - ki + b);
                p     = bsxfun(@minus, p, gammaln(ni + v));
                p     = p - gammaln(a) - gammaln(b);
                p     = bsxfun(@plus,p, gammaln(v));
            else
                p     = [];
            end
        elseif ki>0 % => ni-ki == 0
            pbin  = pbin + ki * log(psi);                                           % binomial model
            if ~isempty(v)                                                  % catch if only binomial
                a     = bsxfun(@times,psi,v);                               % alpha for betabinomial
                p     = p + gammaln(ki + a);                                          % Betabinomial
                p     = bsxfun(@minus, p, gammaln(ni + v));
                p     = p - gammaln(a);
                p     = bsxfun(@plus,p, gammaln(v));
            else
                p     = [];
            end
        elseif (ni-ki)>0 % => ki == 0
            pbin  = pbin + (ni-ki) * log(1-psi);                                    % binomial model
            if ~isempty(v)                                                  % catch if only binomial
                b     = bsxfun(@times,1-psi,v);                              % beta for betabinomial
                p     = p + gammaln(ni - ki + b);
                p     = bsxfun(@minus, p, gammaln(ni + v));
                p     = p  - gammaln(b);
                p     = bsxfun(@plus,p, gammaln(v));
            else
                p     = [];
            end
        else 
            % do nothing-> no trial done at this stimulus level
        end
    end
    if options.verbose > 3, fprintf('\n'); end
    p = cat(5,repmat(pbin,[1,1,1,1,sum(vbinom)]),p);
    if useGPU
        p      = gather(p);
        lambda = gather(lambda);
        gamma  = gather(gamma);
        alpha  = gather(alpha);
        beta   = gather(beta);
    end
    % now with the other priors
    %p = bsxfun(@plus,p,(be-1).*log(1-varscale)-betaln(1,be));
    
    p(isnan(p)) = -inf;
end

if ~isempty(options.priors)
    if iscell(options.priors)
        if isa(options.priors{1},'function_handle')
            p = bsxfun(@plus,p,log(options.priors{1}(alpha)));
        end
        if isa(options.priors{2},'function_handle')
            p = bsxfun(@plus,p,log(options.priors{2}(beta)));
        end
        if isa(options.priors{3},'function_handle')
            p = bsxfun(@plus,p,log(options.priors{3}(lambda)));
        end
        if isa(options.priors{4},'function_handle')
            p = bsxfun(@plus,p,log(options.priors{4}(gamma)));
        end
        if isa(options.priors{5},'function_handle')
            p = bsxfun(@plus,p,log(options.priors{5}(varscaleOrig)));
        end
    end
end

end
