function h=plotMarginal(result,dim,plotOptions)
% plots the marginal for a single dimension
%function plotMarginal(result,dim,plotOptions)
%  result       should be a result struct from the main psignifit routine
%  dim          is the parameter to plot
%                   1=threshold,2=width,3=lambda,4=gamma,5=sigma
%  plotOPtions  a struct with additional options for the plot
% This always plots into gca

if ~exist('plotOptions','var'),            plotOptions                = struct;             end
if ~isfield(plotOptions,'lineColor'),      plotOptions.lineColor      = [0,105/255,170/255];end
if ~isfield(plotOptions,'lineWidth'),      plotOptions.lineWidth      = 2;                  end
if ~isfield(plotOptions,'xLabel'),         plotOptions.xLabel         = [];                 end
if ~isfield(plotOptions,'labelSize'),      plotOptions.labelSize      = 14;                 end
if ~isfield(plotOptions,'tufteAxis'),      plotOptions.tufteAxis      = true;               end
if ~isfield(plotOptions,'prior'),          plotOptions.prior          = true;               end
if ~isfield(plotOptions,'priorColor'),     plotOptions.priorColor     = [.7,.7,.7];         end
if ~isfield(plotOptions,'CIpatch'),        plotOptions.CIpatch        = true;               end


if ~exist('dim','var'),                    dim                        = 1;                  end

if isempty(plotOptions.xLabel)    
    switch dim
        case 1
            plotOptions.xLabel='threshold';
        case 2
            plotOptions.xLabel='width';
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
    %normalize prior
    n = 1000;
    xprior = linspace(result.options.borders(dim,1),result.options.borders(dim,2),n);
    y = result.options.priors{dim}(xprior).*(result.options.borders(dim,2)-result.options.borders(dim,1));
    factor = 1./(n-1)*(0.5 * (y(1)+y(end)) + sum(y(2:(end-1))));
    % plot prior
    xprior = linspace(min(x),max(x),1000);
    plot(xprior,result.options.priors{dim}(xprior)./factor,'--','Color',plotOptions.priorColor);
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
set(hlabel,'Position',get(hlabel,'Position') - [0 .05 0])
hlabel = ylabel('marginal density','FontSize',plotOptions.labelSize);
set(hlabel,'Visible','on')
set(hlabel,'Position',get(hlabel,'Position') - [.05 0 0])