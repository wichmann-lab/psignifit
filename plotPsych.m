function [hline,hdata] = plotPsych(result,plotOptions)
% plot your data with the fitted function
%function plotPsych(result,plotOptions)
% This function produces a plot of the fitted psychometric function with
% the data.
% In the struct plotOptions you may set a lot of options, which are listed 
% here with their default values:
% 
%plotOptions.dataColor      = [0,105/255,170/255];  % color of the data
%plotOptions.plotData       = 1;                    % plot the data?
%plotOptions.lineColor      = [0,0,0];              % color of the PF
%plotOptions.lineWidth      = 2;                    % lineWidth of the PF
%plotOptions.xLabel         = 'Stimulus Level';     % xLabel
%plotOptions.yLabel         = 'Percent Correct';    % yLabel
%plotOptions.labelSize      = 15;                   % font size labels
%plotOptions.fontSize       = 10;                   % font size numbers
%plotOptions.fontName       = 'Helvetica';          % font
%plotOptions.tufteAxis      = false;                % use special axis
%plotOptions.plotAsymptote  = true;                 % plot Asympotes 
%plotOptions.plotThresh     = true;                 % plot Threshold Mark
%plotOptions.aspectRatio    = false;                % set aspect ratio
%plotOptions.extrapolLength = .2;                   % extrapolation percentage
%plotOptions.CIthresh       = false;                % draw CI on threhold
%plotOptions.dataSize       = 10000./sum(result.data(:,3)) % size of the data-dots

if ~exist('plotOptions','var'),         plotOptions           = struct;               end
assert(isstruct(plotOptions),'If you pass an option file it must be a struct!');

if isfield(plotOptions,'h')
    h = plotOptions.h;
else 
    h = gca;
end
assert(ishandle(h),'Invalid axes handle provided to plot in.')
axes(h);

if ~isfield(plotOptions,'dataColor'),      plotOptions.dataColor      = [0,105/255,170/255]; end
if ~isfield(plotOptions,'plotData'),       plotOptions.plotData       = 1;                   end
if ~isfield(plotOptions,'lineColor'),      plotOptions.lineColor      = [0,0,0];             end
if ~isfield(plotOptions,'lineWidth'),      plotOptions.lineWidth      = 2;                   end
if ~isfield(plotOptions,'xLabel'),         plotOptions.xLabel         = 'Stimulus Level';    end
if ~isfield(plotOptions,'yLabel'),         plotOptions.yLabel         = 'Proportion Correct';end
if ~isfield(plotOptions,'labelSize'),      plotOptions.labelSize      = 15;                  end
if ~isfield(plotOptions,'fontSize'),       plotOptions.fontSize       = 10;                  end
if ~isfield(plotOptions,'fontName'),       plotOptions.fontName       = 'Helvetica';         end
if ~isfield(plotOptions,'tufteAxis'),      plotOptions.tufteAxis      = false;               end
if ~isfield(plotOptions,'plotAsymptote'),  plotOptions.plotAsymptote  = true;                end
if ~isfield(plotOptions,'plotThresh'),     plotOptions.plotThresh     = true;                end
if ~isfield(plotOptions,'aspectRatio'),    plotOptions.aspectRatio    = false;               end
if ~isfield(plotOptions,'extrapolLength'), plotOptions.extrapolLength = .2;                  end
if ~isfield(plotOptions,'CIthresh'),       plotOptions.CIthresh       = false;               end

if isnan(result.Fit(4)),                   result.Fit(4)=result.Fit(3);    end

if isempty(result.data)
    return
end



if ~isfield(plotOptions,'dataSize')
    plotOptions.dataSize  = 10000./sum(result.data(:,3));
end


switch result.options.expType
    case {'nAFC'}
        ymin = 1./result.options.expN;
        ymin = min(ymin,min(result.data(:,2)./result.data(:,3)));
    otherwise
        ymin = 0;
end

% backcompatibility
if isfield(plotOptions,'plotPar') && ~plotOptions.plotPar
    plotOptions.plotAsymptote  = false;
    plotOptions.plotThresh     = false;
end

%% plot data
holdState = ishold(h);
if ~holdState
    cla(h);
end
hold on
if exist ('OCTAVE_VERSION', 'builtin')
    hdata = zeros(size(result.data,1),1);
else
if verLessThan('matlab', '8.1')
    hdata = zeros(size(result.data,1),1);
else
    hdata = gobjects(size(result.data,1),1);
end
end
if plotOptions.plotData
    for i=1:size(result.data,1)
        hdata(i) = plot(result.data(i,1),result.data(i,2)./result.data(i,3),'.','MarkerSize',sqrt(plotOptions.dataSize*result.data(i,3)),'Color',plotOptions.dataColor);
    end
end

%% plot fitted function
%for dashed ends:
if result.options.logspace
    xlength   = log(max(result.data(:,1)))-log(min(result.data(:,1)));
    x         = exp(linspace(log(min(result.data(:,1))),log(max(result.data(:,1))),1000));
    xLow      = exp(linspace(log(min(result.data(:,1)))-plotOptions.extrapolLength*xlength,log(min(result.data(:,1))),100));
    xHigh     = exp(linspace(log(max(result.data(:,1))),log(max(result.data(:,1)))+plotOptions.extrapolLength*xlength,100));
else
    xlength   = max(result.data(:,1))-min(result.data(:,1));
    x         = linspace(min(result.data(:,1)),max(result.data(:,1)),1000);
    xLow      = linspace(min(result.data(:,1))-plotOptions.extrapolLength*xlength,min(result.data(:,1)),100);
    xHigh     = linspace(max(result.data(:,1)),max(result.data(:,1))+plotOptions.extrapolLength*xlength,100);
end
fitValuesLow    = (1-result.Fit(3)-result.Fit(4))*arrayfun(@(x) result.options.sigmoidHandle(x,result.Fit(1),result.Fit(2)),xLow)+result.Fit(4);
fitValuesHigh   = (1-result.Fit(3)-result.Fit(4))*arrayfun(@(x) result.options.sigmoidHandle(x,result.Fit(1),result.Fit(2)),xHigh)+result.Fit(4);

fitValues = (1-result.Fit(3)-result.Fit(4))*arrayfun(@(x) result.options.sigmoidHandle(x,result.Fit(1),result.Fit(2)),x)+result.Fit(4);
hline = plot(x,     fitValues,          'Color', plotOptions.lineColor,'LineWidth',plotOptions.lineWidth);
plot(xLow,  fitValuesLow,'--',  'Color', plotOptions.lineColor,'LineWidth',plotOptions.lineWidth)
plot(xHigh, fitValuesHigh,'--', 'Color', plotOptions.lineColor,'LineWidth',plotOptions.lineWidth)

if result.options.logspace
    set(gca,'XScale','log')
end

%% plot parameter Illustrations
% threshold
if plotOptions.plotThresh
    if result.options.logspace
        plot([exp(result.Fit(1)),exp(result.Fit(1))],[ymin,result.Fit(4)+(1-result.Fit(3)-result.Fit(4)).*result.options.threshPC],'-','Color',plotOptions.lineColor);
    else
        plot([result.Fit(1),result.Fit(1)],[ymin,result.Fit(4)+(1-result.Fit(3)-result.Fit(4)).*result.options.threshPC],'-','Color',plotOptions.lineColor);
    end
end
if plotOptions.plotAsymptote
    % asymptotes
    plot([min(xLow),max(xHigh)],[1-result.Fit(3),1-result.Fit(3)],':','Color',plotOptions.lineColor);
    plot([min(xLow),max(xHigh)],[result.Fit(4),result.Fit(4)],':','Color',plotOptions.lineColor);
end

if plotOptions.CIthresh
    if result.options.logspace
        result.conf_Intervals(1,:,1) = exp(result.conf_Intervals(1,:,1));
    end
    plot(result.conf_Intervals(1,:,1),repmat(result.Fit(4)+result.options.threshPC*(1-result.Fit(3)-result.Fit(4)),1,2),'Color',plotOptions.lineColor)
    plot(repmat(result.conf_Intervals(1,1,1),1,2),repmat(result.Fit(4)+result.options.threshPC*(1-result.Fit(3)-result.Fit(4)),1,2)+[-.01,+.01],'Color',plotOptions.lineColor)
    plot(repmat(result.conf_Intervals(1,2,1),1,2),repmat(result.Fit(4)+result.options.threshPC*(1-result.Fit(3)-result.Fit(4)),1,2)+[-.01,+.01],'Color',plotOptions.lineColor)
end

%% axis settings
axis tight
set(gca,'FontSize',plotOptions.fontSize)
ylabel(plotOptions.yLabel,'FontName',plotOptions.fontName,'FontSize', plotOptions.labelSize);
xlabel(plotOptions.xLabel,'FontName',plotOptions.fontName,'FontSize', plotOptions.labelSize);
if plotOptions.aspectRatio
    set(gca,'PlotBoxAspectRatio',[(1+sqrt(5))/2,1,1])
end
if plotOptions.tufteAxis
    if result.options.logspace
        tufteaxis([min(result.data(:,1)),exp(result.Fit(1)),max(result.data(:,1))],[ymin,1]);
    else
        tufteaxis([min(result.data(:,1)),result.Fit(1),max(result.data(:,1))],[ymin,1]);
    end
    set(get(gca,'xLabel'),'visible','on')
    set(get(gca,'yLabel'),'visible','on')
else 
    ylim([ymin,1]);
    set(gca,'TickDir','out')
    box off
end

%% toggle back hold state
if ~holdState
    hold off
end