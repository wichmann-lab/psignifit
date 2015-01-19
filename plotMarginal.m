function h=plotMarginal(result,dim,h,plotOptions)
% plots the marginal for a single dimension
%function plotMarginal(result,dim,plotOptions)
%  result       should be a result struct from the main psignifit routine
%  dim          is the parameter to plot
%                   1=threshold,2=width,3=lambda,4=gamma,5=sigma
%  plotOPtions  a struct with additional options for the plot
% This always plots into gca



assert(length(result.marginals{dim})>1,'The parameter you wanted to plot was fixed in the analysis!');

if exist('h','var') && ~isempty(h)
    axes(h);
else
    axes(gca);
    h=gca;
end

if ~exist('plotOptions','var'),            plotOptions                = struct;             end
if ~isfield(plotOptions,'lineColor'),      plotOptions.lineColor      = [0,105/255,170/255];end
if ~isfield(plotOptions,'lineWidth'),      plotOptions.lineWidth      = 2;                  end
if ~isfield(plotOptions,'xLabel'),         plotOptions.xLabel         = [];                 end
if ~isfield(plotOptions,'yLabel'),         plotOptions.yLabel         = 'Marginal Density'; end
if ~isfield(plotOptions,'labelSize'),      plotOptions.labelSize      = 15;                 end
if ~isfield(plotOptions,'tufteAxis'),      plotOptions.tufteAxis      = false;              end
if ~isfield(plotOptions,'prior'),          plotOptions.prior          = true;               end
if ~isfield(plotOptions,'priorColor'),     plotOptions.priorColor     = [.7,.7,.7];         end
if ~isfield(plotOptions,'CIpatch'),        plotOptions.CIpatch        = true;               end


if ~exist('dim','var'),                    dim                        = 1;                  end

if isempty(plotOptions.xLabel)
    switch dim
        case 1
            plotOptions.xLabel='Threshold';
        case 2
            plotOptions.xLabel='Width';
        case 3
            plotOptions.xLabel='\lambda';
        case 4
            plotOptions.xLabel='\gamma';
        case 5
            plotOptions.xLabel='\sigma';
    end
end

if exist('h','var') && ~isempty(h)
    axes(h);
else
    h=gca;
    axes(h);
end


x        = result.marginalsX{dim};
marginal = result.marginals{dim};
CI       = result.conf_Intervals(dim,:);
Fit      = result.Fit(dim);


% patch for confidence region
if plotOptions.CIpatch
    xCI      = [CI(1);x(x>=CI(1) & x<=CI(2));CI(2);CI(2);CI(1)];
    
    yCI      = [interp1(x,marginal,CI(1));          ...
        marginal(x>=CI(1) & x<=CI(2));   ...
        interp1(x,marginal,CI(2));0;0];
    patch(xCI,yCI,.5*plotOptions.lineColor+.5*[1,1,1],'EdgeColor',.5*plotOptions.lineColor+.5*[1,1,1]);
end

hold on

% plot prior
if plotOptions.prior
    % plot prior
    xprior = linspace(min(x),max(x),1000);
    plot(xprior,result.options.priors{dim}(xprior),'--','Color',plotOptions.priorColor);
end

%posterior
plot(x,marginal,'LineWidth',plotOptions.lineWidth,'Color',plotOptions.lineColor);
% point estimate
plot([Fit;Fit],[0;interp1(x,marginal,Fit)],'k');



if plotOptions.tufteAxis
    tufteaxis(unique([min(x),CI(1),Fit,CI(2),max(x)]),[0,max(marginal)]);
end

hlabel = xlabel(plotOptions.xLabel,'FontSize',plotOptions.labelSize);
set(hlabel,'Visible','on')
if plotOptions.tufteAxis
    set(hlabel,'Position',get(hlabel,'Position') - [0 .05 0]);
end
hlabel = ylabel(plotOptions.yLabel,'FontSize',plotOptions.labelSize);
set(hlabel,'Visible','on')
if plotOptions.tufteAxis
    set(hlabel,'Position',get(hlabel,'Position') - [.05 0 0])
else
    set(gca,'TickDir','out')
    box off
end