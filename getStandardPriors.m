function priors = getStandardPriors(options)
% sets the standard Priors
% function priors = getStandardPriors(data,options)
% The priors set here are the ones used if the user does supply own priors.
% Thus this functions constitutes a way to change the priors permanently
% note here that the priors here are not normalized. Psignifit takes care
% of the normalization implicitly.

priors = cell(5,1);


%% threshold
xspread = options.stimulusRange(2)-options.stimulusRange(1);
% we assume the threshold is in the range of the data, for larger or
% smaller values we tapre down to 0 with a raised cosine across half the
% dataspread
priors{1} = @(x) (x>=(options.stimulusRange(1)-.5*xspread)).*(x<=options.stimulusRange(1)).*(.5+.5*cos(2*pi.*(options.stimulusRange(1)-x)./xspread))...
    + (x>options.stimulusRange(1)).*(x<options.stimulusRange(2))...
    + (x>=options.stimulusRange(2)).*(x<=options.stimulusRange(2)+.5*xspread).*(.5+.5*cos(2*pi.*(x-options.stimulusRange(2))./xspread));


%% width
% minimum = minimal difference of two stimulus levels
widthmin = options.widthmin;
% maximum = spread of the data
widthmax  = xspread;
% We use the same prior as we previously used... e.g. we use the factor by
% which they differ for the cumulative normal function
Cfactor   = (my_norminv(.95,0,1) - my_norminv(.05,0,1))./( my_norminv(1-options.widthalpha,0,1) - my_norminv(options.widthalpha,0,1));
% add a cosine devline over 2 times the spread of the data
priors{2} = @(x) ((x.*Cfactor)>=widthmin).*((x.*Cfactor)<=2*widthmin).*(.5-.5*cos(pi.*((x.*Cfactor)-widthmin)./widthmin))...
    + ((x.*Cfactor)>2*widthmin).*((x.*Cfactor)<widthmax)...
    + ((x.*Cfactor)>=widthmax).*((x.*Cfactor)<=3*widthmax).*(.5+.5*cos(pi./2.*(((x.*Cfactor)-widthmax)./xspread)));


%% asymptotes
% set asymptote prior to the 1, 10 beta prior, which corresponds to the
% knowledge obtained from 9 correct trials at infinite stimulus level
priors{3} = @(x) my_betapdf(x,1,10);
priors{4} = @(x) my_betapdf(x,1,10);

%% eta
be = options.betaPrior;
priors{5} = @(x) my_betapdf(x,1,be);

end