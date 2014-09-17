function priors=normalizePriors(options)
% normalization of given priors
%function Priors=normalizePriors(options)
% This function normalizes the priors from the given options struct, to
% obtain normalized priors.
% This normalization makes later computations for the Bayesfactor and
% plotting of the prior easier.
%
% this should be run with the original borders to obtain the correct
% normalization

priors = options.priors; 

for id= 1:length(priors)
    if options.borders(id,2)> options.borders(id,1)
        % choose xValues for calculation of the integral
        x = linspace(options.borders(id,1),options.borders(id,2),1000);
        % evaluate unnormalized prior
        y = priors{id}(x);
        w = conv(diff(x),[.5,.5]);
        integral = sum(y(:).*w(:));
        priors{id} = @(x) priors{id}(x)./integral;
    else 
        priors{id} = @(x) 1;
    end
end