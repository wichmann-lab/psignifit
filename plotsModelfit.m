function plotsModelfit(res)
%function plotsModelfit(res)
% plots some standard plots, meant to help you judge whether there are
% systematic deviations from the model.
%
% These are the same plots as presented in psignifit 2 for this purpose.
%

stimRange = [min(res.data(:,1)),max(res.data(:,1))];
stimRange = [1.1*stimRange(1)-.1*stimRange(2),1.1*stimRange(2)-.1*stimRange(1)];


figure
Pos=get(gcf,'Position');
Pos(3)=1200;
set(gcf,'Position',Pos);
subplot(1,3,1)
% the psychometric function
x = linspace(stimRange(1),stimRange(2),1000);
y = res.Fit(4)+(1-res.Fit(3)-res.Fit(4))*res.options.sigmoidHandle(x,res.Fit(1),res.Fit(2));

hold on
plot(x,y,'k')
plot(res.data(:,1),res.data(:,2)./res.data(:,3),'.k','MarkerSize',20)
xlim(stimRange)
switch res.options.expType
    case 'YesNo'
        ylim([0,1])
    case 'equalAsymptote'
        ylim([0,1])
    case 'nAFC'
        ylim([min(1./res.options.expN,min(res.data(:,2)./res.data(:,3))),1])
end
xlabel('Stimulus Level','FontSize',14) 
ylabel('Percent Correct','FontSize',14)
title('Psychometric Function','FontSize',20)
box off

subplot(1,3,2)
% stimulus level vs. deviance
stdModel = res.Fit(4)+(1-res.Fit(3)-res.Fit(4))*res.options.sigmoidHandle(res.data(:,1),res.Fit(1),res.Fit(2));
deviance = res.data(:,2)./res.data(:,3)-stdModel;
stdModel = sqrt(stdModel.*(1-stdModel));
deviance = deviance./stdModel;
xValues = linspace(min(res.data(:,1)),max(res.data(:,1)),1000);

plot(res.data(:,1),deviance,'k.','MarkerSize',20)
xlabel('Stimulus Level','FontSize',14)
ylabel('Deviance','FontSize',14)
hold on
linefit = polyfit(res.data(:,1),deviance,1);
plot(xValues,polyval(linefit,xValues),'k-')
linefit = polyfit(res.data(:,1),deviance,2);
plot(xValues,polyval(linefit,xValues),'k--')
linefit = polyfit(res.data(:,1),deviance,3);
plot(xValues,polyval(linefit,xValues),'k:')
title('Shape Check','FontSize',20)
box off

subplot(1,3,3)

BlockN  = (1:length(deviance))';
xValues = linspace(min(BlockN),max(BlockN),1000);
plot(BlockN,deviance,'k.','MarkerSize',20)
hold on
linefit = polyfit(BlockN,deviance,1);
plot(xValues,polyval(linefit,xValues),'k-')
linefit = polyfit(BlockN,deviance,2);
plot(xValues,polyval(linefit,xValues),'k--')
linefit = polyfit(BlockN,deviance,3);
plot(xValues,polyval(linefit,xValues),'k:')
xlabel('Block #','FontSize',14)
ylabel('Deviance','FontSize',14)
title('Time Dependence?','FontSize',20)
box off
