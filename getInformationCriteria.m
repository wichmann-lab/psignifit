function [aic,waic] = getInformationCriteria(result)
%getInformationCriteria(result) compute Akaike Information Criterion (AIC) and Watanabe-Akaike
%(Widely-Applicable) Information Criterion (WAIC) for use in model comparison with other
%psychometric models. See [1] for details of each. See also @getDeviance.
%
%[aic,waic] = getInformationCriteria(result)
%
% [1] Gelman, A., Hwang, J., & Vehtari, A. (2014). Understanding predictive information criteria for
% Bayesian models. Statistics and Computing, 24(6), 997–1016.
% https://doi.org/10.1007/s11222-013-9416-2

%% AIC (but using MAP rather than MLE)

% get log likelihood of data under maximum likelihood parameters
switch lower(result.options.estimateType)
    case {'mle', 'map'}
        map_result = result;
    otherwise
        % 'result' is something else... run MAP fitting anew
        map_options = result.options;
        map_options.estimateType = 'MAP';
        map_result = psignifit(result.data, map_options);
end

X = map_result.Fit;
[mle, mle_per] = logLikelihood(map_result.data, map_result.options, X(1), X(2), X(3), X(4), X(5));

% number of free parameters = # not-fixed parameters
isfree = isnan(result.options.fixedPars);
k = sum(isfree);

aic = -2 * mle + 2 * k;

%% WAIC

% Get marginal information for non-fixed parameters
grids = result.marginalsX(isfree);
margPost = result.Posterior;
margWt = result.weight;
for d=ndims(margPost):-1:1
    if ~isfree(d)
        margPost = mean(margPost, d);
        margWt = mean(margWt, d);
    end
end
margPost = squeeze(margPost);
margWt = squeeze(margWt);

% Restrict the n-dimensional integral to just grid points with > 1e-9 mass, and renormalize.
margWt = margPost .* margWt;
evalIdx = margWt/sum(margWt(:)) > 1e-9;
margWt = margWt / sum(margWt(evalIdx));

% Integrate over the posterior grid twice... first pass, get sum of log p per data point. Second
% pass, use the mean from the first pass to get variance of log p per data point. (Looping twice
% prevents trying to keep the [nDataPoints x nGridPoints] matrix in memory at once at the expense of
% some speed)

% --- First pass ---
m_avg_p = zeros(size(result.data,1),1); % Running mean of exp(log p - mle) = p / exp(mle)
m_log_p = zeros(size(result.data,1),1); % Running mean of log p

subidx = cell(1,k);
for ii=find(evalIdx)'
    [subidx{:}] = ind2sub(size(margPost), ii);
    X(isfree) = arrayfun(@(i) grids{i}(subidx{i}), 1:k);

    % Update running means with ll under the current posterior point
    [~, ll_per] = logLikelihood(result.data, result.options, X(1), X(2), X(3), X(4), X(5));
    m_log_p = m_log_p + margWt(ii) * ll_per;
    m_avg_p = m_avg_p + margWt(ii) * exp(ll_per - mle_per);
end

% Compute in a stable way the log of the posterior predictive probability,
% sum(log(m_avg_p.*exp(mle_per))), where the mle_per term adjust for the exp(ll_per-mle_per) in the
% loop above
lppd = sum(log(m_avg_p) + mle_per);

% --- Second pass ---
v_log_p = zeros(size(result.data,1),1); % Running variance of each ll estimate

for ii=find(evalIdx)'
    [subidx{:}] = ind2sub(size(margPost), ii);
    X(isfree) = arrayfun(@(i) grids{i}(subidx{i}), 1:k);

    % Update running variance estimate
    [~, ll_per] = logLikelihood(result.data, result.options, X(1), X(2), X(3), X(4), X(5));
    v_log_p = v_log_p + margWt(ii) * (ll_per - m_log_p).^2;
end

% Equation (13) in [1]
waic = lppd - sum(v_log_p);

% Convert to 'deviance' scale
waic = -2 * waic;

end