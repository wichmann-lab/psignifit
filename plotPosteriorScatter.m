function plotPosteriorScatter(result, dims, minP)
% plotPosteriorScatter(result, [dims], [minP]) 
% where 'dims' is a subset of 1:5 with 2 or three elements
% marginalizes over all other dims and makes either a 2d or 3d scatter plot
% of the resulting marginal posterior grid, ignoring data with posterior 
% probability less than 'minP'


P = result.Posterior.*result.weight;

if nargin < 2, dims = [1 2 3]; end
assert((length(dims)>=2 & length(dims<=3)),'plotPosteriorScatter expects to plot 2 or 3 dimensions');

% Default threshold = 100 * uniform for given # grid points after
% marginalization.
if nargin < 3, minP = 0; end


% Marginalize all dimensions of P except 'dims'.
margdims = setdiff(1:5, dims);
for i=length(margdims):-1:1
    P = sum(P, margdims(i));
end
P = squeeze(P);


% Get gridpoints and names for each parameter.
gridpts = cell(size(dims));
meshpts = cell(size(dims));
names = cell(size(dims));
for i=1:length(dims)
    gridpts{i} = result.X1D{dims(i)};
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
        xlabel(names{1}); 
        ylabel(names{2}); 
        if gridpts{1}(end)> gridpts{1}(1)
            xlim([gridpts{1}(1) gridpts{1}(end)]);
        end
        if gridpts{2}(end)> gridpts{2}(1)
             ylim([gridpts{2}(1) gridpts{2}(end)]);
        end
    case 3
        % 3d scatter
        scatter3(meshpts{1}(pts), meshpts{2}(pts), meshpts{3}(pts), 30, P(pts), 'filled', 'Marker', 'o');
        
        xlabel(names{1});
        ylabel(names{2});
        zlabel(names{3});
        if gridpts{1}(end)> gridpts{1}(1)
            xlim([gridpts{1}(1) gridpts{1}(end)]);
        end
        if gridpts{2}(end)> gridpts{2}(1)
             ylim([gridpts{2}(1) gridpts{2}(end)]);
        end
        if gridpts{3}(end)> gridpts{3}(1)
            zlim([gridpts{3}(1) gridpts{3}(end)]);
        end
        set(gca, 'YDir', 'reverse');
end

end
