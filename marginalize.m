function [marginal, x, weight] = marginalize(result, dimension)
% get the marginal posterior distributions from your result
%function [marginal,x,weight]=marginalize(result,dimension)
% this function gets the marginal distribution for result
% It returns 3 variables:
%
%   marginal - the values of the marginal posterior
%   x        - the gridpoints at which the posterior is sampled
%   weight   - the integration weight for this point
%
% This also works for more than one dimension in dimension to obtain
% multidimensional marginals, x then becomes a cell array of the 1D ticks
% of the grid.

assert(isnumeric(dimension),'the dimensions you want to marginalize to should be given as a vector of numbers 1:5');
assert(all(ismember(dimension(:),1:5)),'the dimensions you want to marginalize to should be given as a vector of numbers 1:5');

%Init
d = length(result.X1D);


if length(dimension) == 1 && isfield(result,'marginals') && length(result.marginals)>=dimension
    marginal = result.marginals{dimension};
    weight   = result.marginalsW{dimension};
    x        = result.marginalsX{dimension};
else
    if ~isfield(result, 'Posterior')
        error('marginals cannot be computed anymore because posterior was droped');
        
    else
        assert(all(size(result.Posterior)==size(result.weight)),'dimensions mismatch in marginalization');
        
        % Pass grid positions
        if length(dimension)==1
            x = result.X1D{dimension}(:);
        else
            x = nan;
        end
        
        marginal = result.weight.*result.Posterior;         % calculate mass at each gridpoint
        
        weight   = result.weight;                           % weight at each point
        for id=1:d
            if ~any(id==dimension) && size(marginal,id)>1   % if dimension has to be integrated out
                marginal = sum(marginal,id);                % sum/integrate accross this dimension
                weight   = sum(weight,id)./(max(result.X1D{id})-min(result.X1D{id})); % normalize by mass in the removed direction
            end
        end
        marginal = marginal ./ weight;
        
        if length(dimension)==1
            marginal = reshape(marginal,[],1);
            weight   = reshape(weight,  [],1);
            x        = reshape(x,       [],1);
        else 
            marginal = marginal;
            weight   = weight;
            x        = result.X1D(sort(dimension));
        end
    end
end