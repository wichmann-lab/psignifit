function h=plotPsych(result,h,plotOptions)
% plot your data with the fitted function
%function plotPsych(result,h,plotOptions)
% This function produces a plot of the fitted psychometric function with
% the data.

if exist('h','var') && ~isempty(h)
    axes(h);
else
    axes(gca);
    h=gca;
end

if ~exist('plotOptions','var'),         plotOptions           = struct;               end
assert(isstruct(plotOptions),'If you pass a option file it must be a struct!');

if ~isfield(plotOptions,'dataColor'),      plotOptions.dataColor      = [0,105/255,170/255];end
if ~isfield(plotOptions,'plotData'),       plotOptions.plotData       = 1;                  end
if ~isfield(plotOptions,'lineColor'),      plotOptions.lineColor      = [0,0,0];            end
if ~isfield(plotOptions,'lineWidth'),      plotOptions.lineWidth      = 2;                  end
if ~isfield(plotOptions,'xLabel'),         plotOptions.xLabel         = 'stimulus level';   end
if ~isfield(plotOptions,'yLabel'),         plotOptions.yLabel         = 'percent correct';  end
if ~isfield(plotOptions,'labelSize'),      plotOptions.labelSize      = 14;                 end
if ~isfield(plotOptions,'fontSize'),       plotOptions.fontSize       = 10;                 end
if ~isfield(plotOptions,'fontName'),       plotOptions.fontName       = 'Helvetica';        end
if ~isfield(plotOptions,'tufteAxis'),      plotOptions.tufteAxis      = true;               end
if ~isfield(plotOptions,'plotPar'),        plotOptions.plotPar        = true;               end
if ~isfield(plotOptions,'aspectRatio'),    plotOptions.aspectRatio    = false;              end
if ~isfield(plotOptions,'extrapolLength'), plotOptions.extrapolLength = .2;                 end


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
    otherwise
        ymin = 0;
end

%% plot data
if plotOptions.plotData
    for i=1:length(result.data)
        plot(result.data(i,1),result.data(i,2)./result.data(i,3),'.','MarkerSize',sqrt(plotOptions.dataSize*result.data(i,3)),'Color',plotOptions.dataColor)
        hold on
    end
end

%% plot fitted function
%for dashed ends:
if result.options.logspace
    xlength   = log(max(result.data(:,1)))-log(min(result.data(:,1)));
    x         = exp(linspace(log(min(result.data(:,1))),log(max(result.data(:,1))),1000));
    xLow      = exp(linspace(log(min(result.data(:,1)))-.2*xlength,log(min(result.data(:,1))),100));
    xHigh     = exp(linspace(log(max(result.data(:,1))),log(max(result.data(:,1)))+.2*xlength,100));
else
    xlength   = max(result.data(:,1))-min(result.data(:,1));
    x         = linspace(min(result.data(:,1)),max(result.data(:,1)),1000);
    xLow      = linspace(min(result.data(:,1))-.2*xlength,min(result.data(:,1)),100);
    xHigh     = linspace(max(result.data(:,1)),max(result.data(:,1))+.2*xlength,100);
end
fitValuesLow    = (1-result.Fit(3)-result.Fit(4))*arrayfun(@(x) result.options.sigmoidHandle(x,result.Fit(1),result.Fit(2)),xLow)+result.Fit(4);
fitValuesHigh   = (1-result.Fit(3)-result.Fit(4))*arrayfun(@(x) result.options.sigmoidHandle(x,result.Fit(1),result.Fit(2)),xHigh)+result.Fit(4);

fitValues = (1-result.Fit(3)-result.Fit(4))*arrayfun(@(x) result.options.sigmoidHandle(x,result.Fit(1),result.Fit(2)),x)+result.Fit(4);
plot(x,     fitValues,          'Color', plotOptions.lineColor,'LineWidth',plotOptions.lineWidth)
plot(xLow,  fitValuesLow,'--',  'Color', plotOptions.lineColor,'LineWidth',plotOptions.lineWidth)
plot(xHigh, fitValuesHigh,'--', 'Color', plotOptions.lineColor,'LineWidth',plotOptions.lineWidth)

if result.options.logspace
    set(gca,'XScale','log')
end

%% plot parameter Illustrations
if plotOptions.plotPar
    % threshold
    if result.options.logspace
        plot([exp(result.Fit(1)),exp(result.Fit(1))],[ymin,result.Fit(4)+(1-result.Fit(3)-result.Fit(4))./2],'k-');
    else
        plot([result.Fit(1),result.Fit(1)],[ymin,result.Fit(4)+(1-result.Fit(3)-result.Fit(4))./2],'k-');
    end
    % asymptotes
    plot([min(x),max(x)],[1-result.Fit(3),1-result.Fit(3)],':k');
    plot([min(x),max(x)],[result.Fit(4),result.Fit(4)],':k');
end

%% axis settings
axis tight
set(gca,'FontSize',plotOptions.fontSize)
ylabel(plotOptions.yLabel,'FontName',plotOptions.fontName,'FontSize', plotOptions.labelSize)
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
end

