function plotsModelfit(res)
%function plotsModelfit(res)
% plots some standard plots, meant to help you judge whether there are
% systematic deviations from the model.
%
% These are the same plots as presented in psignifit 2 for this purpose.
%
% The deviance bootstrap samples plot is generated with getDeviance, i.e.
% does not contain refitting.

stimRange = [min(res.data(:,1)),max(res.data(:,1))];
stimRange = [1.1*stimRange(1)-.1*stimRange(2),1.1*stimRange(2)-.1*stimRange(1)];


figure
Pos=get(gcf,'Position');
Pos(3)=1200;
set(gcf,'Position',Pos);
subplot(1,3,1)
% the psychometric function
x = linspace(stimRange(1),stimRange(2),1000);
y = res.psiHandle(x);

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
set(gca,'TickDir','out')

subplot(1,3,2)
% stimulus level vs. deviance
[devianceResiduals,deviance,deviance_samples] = getDeviance(res);
% pPred = res.psiHandle(res.data(:,1));
% pMeasured = res.data(:,2)./res.data(:,3);
% 
% loglikelihoodPred = res.data(:,2).*log(pPred)+(res.data(:,3)-res.data(:,2)).*log((1-pPred));
% loglikelihoodMeasured = res.data(:,2).*log(pMeasured)+(res.data(:,3)-res.data(:,2)).*log((1-pMeasured));
% loglikelihoodMeasured(pMeasured==1) = 0;
% loglikelihoodMeasured(pMeasured==0) = 0;
% 
% deviance= -2*sign(pMeasured-pPred).*(loglikelihoodMeasured - loglikelihoodPred);
xValues = linspace(min(res.data(:,1)),max(res.data(:,1)),1000);

plot(res.data(:,1),devianceResiduals,'k.','MarkerSize',20)
xlabel('Stimulus Level','FontSize',14)
ylabel('Deviance Residuals','FontSize',14)
hold on
linefit = polyfit(res.data(:,1),devianceResiduals,1);
plot(xValues,polyval(linefit,xValues),'k-')
linefit = polyfit(res.data(:,1),devianceResiduals,2);
plot(xValues,polyval(linefit,xValues),'k--')
linefit = polyfit(res.data(:,1),devianceResiduals,3);
plot(xValues,polyval(linefit,xValues),'k:')
title('Shape Check','FontSize',20)
box off
set(gca,'TickDir','out')

subplot(1,3,3)

BlockN  = (1:length(devianceResiduals))';
xValues = linspace(min(BlockN),max(BlockN),1000);
plot(BlockN,devianceResiduals,'k.','MarkerSize',20)
hold on
linefit = polyfit(BlockN,devianceResiduals,1);
plot(xValues,polyval(linefit,xValues),'k-')
linefit = polyfit(BlockN,devianceResiduals,2);
plot(xValues,polyval(linefit,xValues),'k--')
linefit = polyfit(BlockN,devianceResiduals,3);
plot(xValues,polyval(linefit,xValues),'k:')
xlabel('Block #','FontSize',14)
ylabel('Deviance Residuals','FontSize',14)
title('Time Dependence?','FontSize',20)
box off
set(gca,'TickDir','out')

figure 
[N,x] = hist(deviance_samples,100);
bar(x,N,'FaceColor',[.5,.5,.5],'EdgeColor',[0.5,0.5,0.5])
hold on
plot([deviance,deviance] ,[0,max(get(gca,'ylim'))],'k-','linewidth',2)
box off 
set(gca,'TickDir','out')
xlabel('Deviance','FontSize',14)
ylabel('# Bootstrap Samples','FontSize',14)