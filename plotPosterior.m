function plotPosterior(fitResult, dims, minP)
%PLOTPOSTERIOR make 2d or 3d plot of joint posterior.
%
% PLOTPOSTERIOR(fitResult, [dims], [minP]) where 'dims' is a subset of 1:5
% marginalizes over all other dims and makes either a 2d or 3d scatter plot
% of the resulting marginal posterior grid, ignoring data less than 'minP'.

P = fitResult.Posterior;

if nargin < 2, dims = [1 2 3]; end

% Marginalize all dimensions of P except 'dims'.
margdims = setdiff(1:5, dims);
for i=length(margdims):-1:1
    % Since 'margdims' will be sorted, we are passing over the data
    % starting with the last dimension and moving backwards. This allows a
    % 'squeeze' at every iteration.
    P = squeeze(sum(P, margdims(i)));
end

% Default threshold = 100 * uniform for given # grid points after
% marginalization.
if nargin < 3, minP = 100/numel(P); end

% Get gridpoints and names for each parameter.
gridpts = cell(size(dims));
meshpts = cell(size(dims));
names = cell(size(dims));
for i=1:length(dims)
    gridpts{i} = linspace(fitResult.options.borders(dims(i), 1), fitResult.options.borders(dims(i), 2), fitResult.options.stepN(dims(i)));
    switch dims(i)
        case 1, names{i} = 'Threshold';
        case 2, names{i} = 'Width';
        case 3, names{i} = 'Lambda';
        case 4, names{i} = 'Gamma';
        case 5, names{i} = 'Eta';
        otherwise
            error('Each dim must be in range [1, 5]');
    end
end

% 'meshgrid' expand points - works for both 2d and 3d.
[meshpts{:}] = meshgrid(gridpts{:});
pts = P >= minP;

% Create plot
switch length(dims)
    case 2
        % 2d scatter
        scatter(meshpts{1}(pts), meshpts{2}(pts), 30, P(pts), 'filled', 'Marker', 'o');
        xlabel(names{1}); xlim([gridpts{1}(1) gridpts{1}(end)]);
        ylabel(names{2}); ylim([gridpts{2}(1) gridpts{2}(end)]);
    case 3
        % 3d scatter
        scatter3(meshpts{1}(pts), meshpts{2}(pts), meshpts{3}(pts), 30, P(pts), 'filled', 'Marker', 'o');
        
        xlabel(names{1}); xlim([gridpts{1}(1) gridpts{1}(end)]);
        ylabel(names{2}); ylim([gridpts{2}(1) gridpts{2}(end)]);
        zlabel(names{3}); zlim([gridpts{3}(1) gridpts{3}(end)]);
        set(gca, 'YDir', 'reverse');
    otherwise
        error('plotPosterior expects 2 or 3 dimensions');
end

end