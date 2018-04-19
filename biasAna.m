function biasAna(data1,data2,options)
% function biasAna(data1,data2,options)
% runs a short analysis to see whether two 2AFC datasets have a bias and
% whether it can be explained with a "finger bias"-> a bias in guessing

options.expType = 'YesNo'; % must be set this way to fit gamma & lambda

if ~isfield(options,'priors')
    options.priors = cell(5,1);
end
if isempty(options.priors{4})
    options.priors{4} = @(x) my_betapdf(x,2,2);
end
if ~isfield(options,'borders')
    options.borders = nan(5,2);
end
if isnan(options.border(3,1))
    options.borders(3,:) = [0,.1];
end
if isnan(options.border(4,1))
    options.borders(4,:) = [.11,.89];
end
if ~isfield(options,'fixedPars')
    options.fixedPars = nan(5,1);
    options.fixedPars(5) = 0;
end
if ~isfield(options,'stepN')
    options.stepN   = [40,40,40,40,1];
end
if ~isfield(options,'mbStepN')
    options.mbStepN = [30,30,20,20,1];
end
resAll = psignifit([data1;data2],options);
res1 = psignifit(data1,options);
res2 = psignifit(data2,options);

fh = figure;
set(fh,'Position',[100,1000,400,1200])

%subplot(6,1,1:2)
axes('Position',[0.15,4.35/6,0.75,1.5/6])

plotPsych(resAll);
hold on
plotOptions.lineColor = [1,0,0];
plotOptions.dataColor = [1,0,0];
plotPsych(res1,plotOptions);
plotOptions.lineColor = [0,0,1];
plotOptions.dataColor = [0,0,1];
plotPsych(res2,plotOptions);
ylim([0,1])

%subplot(6,1,3)
axes('Position',[0.15,3.35/6,0.75,0.5/6]);
plotOptions.prior          = false;
plotOptions.CIpatch        = false;
plotOptions.lineColor = [0,0,0];
plotMarginal(resAll,1,plotOptions);
hold on
plotOptions.lineColor = [1,0,0];
plotMarginal(res1,1,plotOptions);
plotOptions.lineColor = [0,0,1];
plotMarginal(res2,1,plotOptions);
xlim auto
ylim auto

%subplot(6,1,4)
axes('Position',[0.15,2.35/6,0.75,0.5/6]);
plotOptions.prior          = false;
plotOptions.CIpatch        = false;
plotOptions.lineColor = [0,0,0];
plotMarginal(resAll,2,plotOptions),
hold on
plotOptions.lineColor = [1,0,0];
plotMarginal(res1,2,plotOptions);
plotOptions.lineColor = [0,0,1];
plotMarginal(res2,2,plotOptions);
xlim auto
ylim auto

%subplot(6,1,5)
axes('Position',[0.15,1.35/6,0.75,0.5/6]);
plotOptions.prior          = false;
plotOptions.CIpatch        = false;
plotOptions.lineColor = [0,0,0];
plotMarginal(resAll,3,plotOptions),
hold on
plotOptions.lineColor = [1,0,0];
plotMarginal(res1,3,plotOptions);
plotOptions.lineColor = [0,0,1];
plotMarginal(res2,3,plotOptions);
xlim auto
ylim auto

%subplot(6,1,6)
axes('Position',[0.15,0.35/6,0.75,0.5/6]);
plotOptions.prior          = false;
plotOptions.CIpatch        = false;
plotOptions.lineColor = [0,0,0];
plotMarginal(resAll,4,plotOptions);
hold on
plotOptions.lineColor = [1,0,0];
plotMarginal(res1,4,plotOptions);
plotOptions.lineColor = [0,0,1];
plotMarginal(res2,4,plotOptions);
xlim([0,1])
ylim auto