function h = plot2D(result,par1,par2,plotOptions)
%% function h = plot2D(result,par1,par2,plotOptions)
% This function constructs a 2 dimensional marginal plot of the posterior
% density. This is the same plot as it is displayed in plotBayes in an
% unmodifyable way.
%
% The result struct is passed as result.
% par1 and par2 should code the two parameters to plot:
% 1 = threshold
% 2 = width
% 3 = lambda
% 4 = gamma
% 5 = eta
%
% As plotOptions an struct of further options may be passed.
%
%
% result, par1 and par2 are compulsory inputs, h and plotOptions may be
% ommitted or replaced by [] to produce the standard options.

% convert strings to dimension number
if ischar(par1)
    par1 = strToDim(par1);
end

if ischar(par2)
    par2 = strToDim(par2);
end

assert(isnumeric(par1) && isnumeric(par2) && par1~=par2, 'par1 and par2 must be different numbers to code for the parameters to plot');
assert(ismember(par1,1:5) && ismember(par2,1:5), 'par1 and par2 must be natural numbers up to 5 for the five parameters');

if ~exist('plotOptions','var')       , plotOptions           = struct;      end
if ~isfield(plotOptions,'colorMap')  , plotOptions.colorMap  = getColormap; end
if ~isfield(plotOptions,'labelSize') , plotOptions.labelSize = 15;          end
if ~isfield(plotOptions,'fontSize')  , plotOptions.fontSize  = 10;          end

if isfield(plotOptions,'h')
    h = plotOptions.h;
else 
    h = gca;
end
assert(ishandle(h),'Invalid axes handle provided to plot in.')
axes(h);


if ~isfield(plotOptions,'label1')
    switch par1
        case 1
            plotOptions.label1 = 'Threshold';
        case 2
            plotOptions.label1 = 'Width';
        case 3
            plotOptions.label1 = '\lambda';
        case 4
            plotOptions.label1 = '\gamma';
        case 5
            plotOptions.label1 = '\eta';
    end
end
if ~isfield(plotOptions,'label2')
    switch par2
        case 1
            plotOptions.label2 = 'Threshold';
        case 2
            plotOptions.label2 = 'Width';
        case 3
            plotOptions.label2 = '\lambda';
        case 4
            plotOptions.label2 = '\gamma';
        case 5
            plotOptions.label2 = '\eta';
    end
end


if exist('h','var') && ~isempty(h)
    axes(h);
else
    axes(gca);
    h=gca;
end


colormap(plotOptions.colorMap);
set(h,'FontSize',plotOptions.fontSize);




marg = squeeze(marginalize(result,[par1,par2]));
if par1 > par2 % flip to get right dimensions
    marg = marg';
end

if isvector(marg)
    if length(result.X1D{par1})==1
        plotMarginal(result,par2);
    else
        plotMarginal(result,par2);
    end
else
    imagesc(result.X1D{par2},result.X1D{par1},marg)
    ylabel(plotOptions.label1,'FontSize',plotOptions.labelSize);
    xlabel(plotOptions.label2,'FontSize',plotOptions.labelSize);
end
set(gca,'TickDir','out')
box off