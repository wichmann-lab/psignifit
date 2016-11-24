function [devianceResiduals,deviance] = getDeviance(result)

pPred = result.psiHandle(result.data(:,1));
pMeasured = result.data(:,2)./result.data(:,3);

loglikelihoodPred = result.data(:,2).*log(pPred)+(result.data(:,3)-result.data(:,2)).*log((1-pPred));
loglikelihoodMeasured = result.data(:,2).*log(pMeasured)+(result.data(:,3)-result.data(:,2)).*log((1-pMeasured));
loglikelihoodMeasured(pMeasured==1) = 0;
loglikelihoodMeasured(pMeasured==0) = 0;

devianceResiduals = -2*sign(pMeasured-pPred).*(loglikelihoodMeasured - loglikelihoodPred);

deviance = sum(abs(devianceResiduals));

