function [slope, CI, marginal] = getSlopeMarginal(result, mode, varargin)
% getSlopeMarginal(result, mode, ...) approximate error bars and marginal
% distribution over fit 'slope'.
%
% getSlopeMarginal(result, 'stimLevel', stimLevel) uses the 'getSlope'
% function.
%
% getSlopeMarginal(result, 'pc', pCorrect, [unscaled]) uses the
% 'getSlopePC' function.

% Marginalize posterior over 'eta' since it doesn't affect slope.
P = sum(result.Posterior .* result.weight, 5);
slopeValuesGrid = zeros(size(P));

switch lower(mode)
    case 'stimlevel'
        slopeFn = @getSlope;
    case 'pc'
        slopeFn = @getSlopePC;
    otherwise
        error('''mode'' must be ''stimLevel'' for getSlope or ''pc'' for getSlopePC');
end

for i=1:numel(P)
    dummyResult = result;
    [th, w, lam, gam, eta] = ind2sub(size(P), i);
    dummyResult.Fit = [result.X1D{1}(th) result.X1D{2}(w) result.X1D{3}(lam) result.X1D{4}(gam) result.X1D{5}(eta)];
    slopeValuesGrid(i) = slopeFn(result, varargin{:});
end

% Flip sign so support in ksdensity is always positive. This will be undone
% after the density has been fit.
if strcmp(result.options.sigmoidName(1:3),'neg')
    slopeSign = -1;
else
    slopeSign = +1;
end

%% Fit continuous density to slopes distribution

[slopesPost, slopesVals] = ksdensity(slopeSign * slopeValuesGrid(:), 'Weights', P(:), 'Support', 'positive');
slopesVals = slopeSign * slopesVals;

% Create 'marginal' from iterpolated/smoothed ksdensity values.
marginal = [slopesVals(:) slopesPost(:)];

switch result.options.estimateType
    case 'MAP'
        [~, mapIdx] = max(slopesPost);
        slope = slopesVals(mapIdx);
    case 'mean'
        slope = dot(P(:), slopeValuesGrid);
end

%% Compute confidence intervals by interpolating the inverse cdf

cdf = cumsum(slopesPost) / sum(slopesPost);
conf = result.options.confP;
CI = zeros(length(conf), 2);

% Note: interp1 expects all unique values in 'x' which here is the cdf.
% However, the cdf might contain duplicates where the pdf was very close to
% 0. Hack solution: take only 'unique' values of the cdf and corresponding
% values of the slope. This is reasonable when the pdf is unimodal.
[uCdf, uI] = unique(cdf);
for i=1:length(conf)
    CI(i, 1) = interp1(uCdf, slopesVals(uI), 1-conf(i));
    CI(i, 2) = interp1(uCdf, slopesVals(uI), conf(i));
end

end