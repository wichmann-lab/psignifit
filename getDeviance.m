function [devianceResiduals,deviance,samples_deviance,samples_devianceResiduals] = getDeviance(result,Nsamples)
%function [devianceResiduals,deviance,samples_deviance,samples_devianceResiduals] = getDeviance(result,Nsamples)
% This function calculates the observed deviance from the model. 
%
% If you ask for more than 2 outputs it also calculates bootstrap samples
% from the function and calculates the deviance & deviance residuals for
% these samples. This was implemented due to public demand to replicate a
% funcionality of psignifit 2. There it corresponds to the sampling method
% without refitting. 

pPred = result.psiHandle(result.data(:,1));
pMeasured = result.data(:,2)./result.data(:,3);

loglikelihoodPred = result.data(:,2).*log(pPred)+(result.data(:,3)-result.data(:,2)).*log((1-pPred));
loglikelihoodMeasured = result.data(:,2).*log(pMeasured)+(result.data(:,3)-result.data(:,2)).*log((1-pMeasured));
loglikelihoodMeasured(pMeasured==1) = 0;
loglikelihoodMeasured(pMeasured==0) = 0;

devianceResiduals = sign(pMeasured-pPred).*sqrt(2*max(loglikelihoodMeasured - loglikelihoodPred, 0));

deviance = sum(devianceResiduals.^2);

if nargout > 2
    if ~exist('Nsamples','var') || isempty(Nsamples)
        Nsamples = 5000;
    end
    
    samples_devianceResiduals = nan(Nsamples,size(result.data,1));
    for iData = 1:size(result.data,1)
        samp_dat = binornd(result.data(iData,3),pPred(iData),Nsamples,1);
        pMeasured = samp_dat./result.data(iData,3);
        loglikelihoodPred = samp_dat.*log(pPred(iData))+(result.data(iData,3)-samp_dat).*log((1-pPred(iData)));
        loglikelihoodMeasured = samp_dat.*log(pMeasured)+(result.data(iData,3)-samp_dat).*log((1-pMeasured));
        loglikelihoodMeasured(pMeasured==1) = 0;
        loglikelihoodMeasured(pMeasured==0) = 0;
        samples_devianceResiduals(:,iData) = sign(pMeasured-pPred(iData)).*sqrt(2.*max(loglikelihoodMeasured - loglikelihoodPred,0));
    end
    samples_deviance = sum(samples_devianceResiduals.^2, 2);
end