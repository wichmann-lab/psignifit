function res = psignifitFast(data,options)
% this uses changed settings for the fit to obtain a fast point estimate to
% your data. 
% The mean estimate with these settings is very crude, the MAP estimate is
% better, but takes a bit of time for the optimization (~100 ms)

warning('You use the speed optimized version of this program. This is NOT suitable for the final analysis, but meant for online analysis, adaptive methods etc. It has not been tested how good the estimates from this method are!')

if ~isfield(options,'expType') || strcmp(options.expType,'YesNo')
    options.stepN     = [20,20,10,10,1];
    options.mbStepN   = [20,20,10,10,1];
else
    options.stepN     = [20,20,10,1,1];
    options.mbStepN   = [20,20,10,1,1];
end
options.fixedPars = [NaN,NaN,NaN,NaN,0];
options.fastOptim = true;

res = psignifit(data,options);
