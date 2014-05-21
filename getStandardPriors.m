function priors = getStandardPriors(data,options)
% sets the standard Priors
% function priors = getStandardPriors(data,options)
% The priors set here are the ones used if the user does supply own priors.
% Thus this functions constitutes a way to change the priors permanently
% note here that the priors here are not normalized. Psignifit takes care
% of the normalization implicitly.

priors = cell(5,1);

%% treat logspace sigmoids
if options.logspace
    data(:,1) = log(data(:,1));
end


%% threshold
xspread   = max(data(:,1))-min(data(:,1));
% we assume the threshold is in the range of the data, for larger or
% smaller values we tapre down to 0 with a raised cosine across half the
% dataspread
priors{1} = @(x) (x>=(min(data(:,1))-.5*xspread)).*(x<=min(data(:,1))).*(.5+.5*cos(2*pi.*(min(data(:,1))-x)./xspread))...
    + (x>min(data(:,1))).*(x<max(data(:,1)))...
    + (x>=max(data(:,1))).*(x<=max(data(:,1))+.5*xspread).*(.5+.5*cos(2*pi.*(x-max(data(:,1)))./xspread));


%% width
% minimum = minimal difference of two stimulus levels
widthmin  = min(diff(sort(unique(data(:,1)))));
% maximum = spread of the data 
widthmax  = xspread;
% add a cosine devline over 2 times the spread of the data
priors{2} = @(x) (x>=widthmin).*(x<=2*widthmin).*(.5-.5*cos(pi.*(x-widthmin)./widthmin))...
    + (x>2*widthmin).*(x<widthmax)...
    + (x>=widthmax).*(x<=3*widthmax).*(.5+.5*cos(pi./2.*((x-widthmax)./xspread)));


%% asymptotes
% set asymptote prior to the 1, 20 beta prior, which corresponds to the
% knowledge obtained from 19 correct trials at infinite stimulus level
priors{3} = @(x) betapdf(x,1,20);
priors{4} = @(x) betapdf(x,1,20);

%% sigma
be = options.betaPrior;
priors{5} = @(x) betapdf(x,1,be);

end