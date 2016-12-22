function plotPrior(res)
% this function creates the plot illustrating the priors on the different
% parameters
%
% this is meant to be a 3 column, 2 rows multipanel plot. 

% parameters 
lineW  = 2;
lineC  = [0,105/255,170/255];
markerSize = 30;

data = res.data;


% get correct stimulus range
if numel(res.options.stimulusRange)<=1
    res.options.stimulusRange = [min(data(:,1)),max(data(:,1))];
    stimRangeSet = false;
else
    stimRangeSet = true;
end
range = res.options.stimulusRange(2)-res.options.stimulusRange(1);

% get borders for width
% minimum = minimal difference of two stimulus levels

if length(unique(data(:,1)))>1 && ~stimRangeSet
    widthmin  = min(diff(sort(unique(data(:,1)))));
else
    widthmin = 100*eps(res.options.stimulusRange(2));
end
% maximum = spread of the data

% We use the same prior as we previously used... e.g. we use the factor by
% which they differ for the cumulative normal function
Cfactor   = (my_norminv(.95,0,1) - my_norminv(.05,0,1))./( my_norminv(1-res.options.widthalpha,0,1) - my_norminv(res.options.widthalpha,0,1));
widthmax  = range;



% calculate mean for priors
for itheta = 1:5
    switch itheta
        case 1
            x = linspace(res.options.stimulusRange(1)-.5*range,res.options.stimulusRange(2)+.5*range,10000);
        case 2
            x = linspace(min(res.X1D{itheta}),max(res.X1D{2}),10000);
        case 3
            x = linspace(0,.5,10000);
        case 4
            x = linspace(0,.5,10000);
        case 5
            x = linspace(0,1,10000);
    end
    y = res.options.priors{itheta}(x);
    theta(itheta) = sum(x.*y)./sum(y);
end
if strcmp(res.options.expType,'equalAsymptote')
    theta(4) = theta(3);
end
if strcmp(res.options.expType,'nAFC')
    theta(4) = 1./res.options.expN;
end


% get limits for the psychometric function plots

if res.options.logspace
    xLimit = exp([res.options.stimulusRange(1)-.5*range,res.options.stimulusRange(2)+.5*range]);
else
    xLimit = [res.options.stimulusRange(1)-.5*range,res.options.stimulusRange(2)+.5*range];
end
% The first row shows the prior marginal densities

%% threshold 
xthresh = linspace(res.options.stimulusRange(1)-.5*range,res.options.stimulusRange(2)+.5*range,10000);
ythresh = res.options.priors{1}(xthresh);
wthresh = conv(diff(xthresh),.5*[1,1]);
cthresh = cumsum(ythresh.*wthresh);
subplot(2,3,1)
plot(xthresh,ythresh,'LineWidth',lineW,'Color',lineC)
hold on
xlim([min(xthresh),max(xthresh)])
title('Threshold','FontSize',18)
ylabel('Density','FontSize',18)


subplot(2,3,4)
plot(data(:,1),0,'k','LineStyle','none','Marker','.','MarkerSize',markerSize*.75)
hold on
ylabel('Percent Correct','FontSize',18)
xlim(xLimit)

x = linspace(xLimit(1),xLimit(2),10000);
for idot= 1:5
    switch idot
        case 1
            xcurrent = theta(1);
            color = 'k';
        case 2
            xcurrent = min(xthresh);
            color = [1,200/255,0];
        case 3
            xcurrent = xthresh(find(cthresh>=.25,1,'first'));
            color = 'r';
        case 4
            xcurrent = xthresh(find(cthresh>=.75,1,'first'));
            color = 'b';
        case 5 
            xcurrent = max(xthresh);
            color = 'g';
    end
    y = 100*(theta(4)+ (1-theta(3)-theta(4)).* res.options.sigmoidHandle(x,xcurrent,theta(2)));
    subplot(2,3,4)
    plot(x,y,'-','LineWidth',lineW,'Color',color)
    if res.options.logspace
        set(gca,'XScale','log')
    end
    subplot(2,3,1)
    plot(xcurrent,res.options.priors{1}(xcurrent),'Color',color,'LineStyle','none','Marker','.','MarkerSize',markerSize)
end


%% width


xwidth = linspace(widthmin,3./Cfactor.*widthmax,10000);
ywidth = res.options.priors{2}(xwidth);
wwidth = conv(diff(xwidth),.5*[1,1]);
cwidth = cumsum(ywidth.*wwidth);
subplot(2,3,2)
plot(xwidth,ywidth,'LineWidth',lineW,'Color',lineC)
hold on
xlim([widthmin,3./Cfactor*widthmax])
title('Width','FontSize',18)

subplot(2,3,5)
plot(data(:,1),0,'k','LineStyle','none','Marker','.','MarkerSize',markerSize*.75)
hold on
xlim(xLimit)
xlabel('Stimulus Level','FontSize',18)

x = linspace(xLimit(1),xLimit(2),10000);
for idot= 1:5
    switch idot
        case 1
            xcurrent = theta(2);
            color = 'k';
        case 2
            xcurrent = min(xwidth);
            color = [1,200/255,0];
        case 3
            xcurrent = xwidth(find(cwidth>=.25,1,'first'));
            color = 'r';
        case 4
            xcurrent = xwidth(find(cwidth>=.75,1,'first'));
            color = 'b';
        case 5 
            xcurrent = max(xwidth);
            color = 'g';
    end
    y = 100*(theta(4)+ (1-theta(3)-theta(4)).* res.options.sigmoidHandle(x,theta(1),xcurrent));
    subplot(2,3,5)
    plot(x,y,'-','LineWidth',lineW,'Color',color)
    if res.options.logspace
        set(gca,'XScale','log')
    end
    subplot(2,3,2)
    plot(xcurrent,res.options.priors{2}(xcurrent),'Color',color,'LineStyle','none','Marker','.','MarkerSize',markerSize)
end

%% lapse

xlapse = linspace(0,.5,10000);
ylapse = res.options.priors{3}(xlapse);
wlapse = conv(diff(xlapse),.5*[1,1]);
clapse = cumsum(ylapse.*wlapse);
subplot(2,3,3)
plot(xlapse,ylapse,'LineWidth',lineW,'Color',lineC)
hold on
xlim([0,.5])
title('\lambda','FontSize',18)

subplot(2,3,6)
plot(data(:,1),0,'k','LineStyle','none','Marker','.','MarkerSize',markerSize*.75)
hold on
xlim(xLimit)


x = linspace(xLimit(1),xLimit(2),10000);
for idot= 1:5
    switch idot
        case 1
            xcurrent = theta(3);
            color = 'k';
        case 2
            xcurrent = 0;
            color = [1,200/255,0];
        case 3
            xcurrent = xlapse(find(clapse>=.25,1,'first'));
            color = 'r';
        case 4
            xcurrent = xlapse(find(clapse>=.75,1,'first'));
            color = 'b';
        case 5 
            xcurrent = .5;
            color = 'g';
    end
    y = 100*(theta(4)+ (1-xcurrent-theta(4)).* res.options.sigmoidHandle(x,theta(1),theta(2)));
    subplot(2,3,6)
    plot(x,y,'-','LineWidth',lineW,'Color',color)
    if res.options.logspace
        set(gca,'XScale','log')
    end
    subplot(2,3,3)
    plot(xcurrent,res.options.priors{3}(xcurrent),'Color',color,'LineStyle','none','Marker','.','MarkerSize',markerSize)
end

set(gcf, 'Position',[200,300,1000,600])
for i=1:6    
    subplot(2,3,i)
    box off;
end
    