classdef testConsistency < matlab.unittest.TestCase
    properties (TestParameter)
        sigmoidName = {'norm','gumbel','rgumbel','logistic','tdist','Weibull','logn'};
        expType = {'2AFC','YesNo','eA'};
    end
    methods (Test)
        function testC(testCase, sigmoidName, expType)
            test_consistency(sprintf('test_cases/test_%s_%s', expType, sigmoidName));
        end
        function test1(testCase)
            test_consistency('test_cases/test1');
        end
        function testBlock(testCase)
            test_consistency('test_cases/test_noblock');
        end
    end
end


function test_consistency(filename)
% this function simulates data and saves it to a file
% function simulate_data(filename,expType,obsType,levelType,N,iSigmoidGen,iSigmoidFit)
% the function is based on the simulation functions for the paper

% read data from csv file:
data = csvread([filename, '_data.csv']);
options = jsondecode(fileread([filename, '_opt.json']));
if isempty(options.poolMaxLength)
    options.poolMaxLength = inf;
end
if isempty(options.poolMaxGap)
    options.poolMaxGap = inf;
end
resOld = jsondecode(fileread([filename, '_res.json']));

resCurrent = psignifit(data,options);

% get mean estimate
d = 5;
Fit = zeros(d,1);
for id = 1:d
    Fit(id) = sum(resCurrent.marginals{id}.*resCurrent.marginalsW{id}.*resCurrent.marginalsX{id});
end
resCurrent.meanFit = Fit;
clear Fit;
% get MAP (was chosen as original fit)
resCurrent.MAP = resCurrent.Fit;

%% asserting consistency
EPS = 10 ^ -6;
for i = 1:5
    assert(all(abs(resCurrent.X1D{i} - resOld.X1D{i}') < EPS), ...
        sprintf('Error: different grid for parameter %d', i))
    assert(all(abs(resCurrent.marginals{i} - resOld.marginals{i}) < EPS), ...
        sprintf('Error: different marginals for parameter %d', i))
    assert(all(abs(resCurrent.marginalsX{i} - resOld.marginalsX{i}) < EPS), ...
        sprintf('Error: different marginals for parameter %d', i))
    assert(all(abs(resCurrent.marginalsW{i} - resOld.marginalsW{i}) < EPS), ...
        sprintf('Error: different marginals for parameter %d', i))
end
assert(max(abs(resOld.logPmax-resCurrent.logPmax))< EPS, 'Error: Pmax changed!')
assert(max(abs(resOld.Fit-resCurrent.Fit))< 100*EPS, 'Error: Fit changed!')
assert(max(abs(resOld.meanFit-resCurrent.meanFit))< EPS, 'Error: Mean Fit changed!')
assert(max(abs(resOld.conf_Intervals(:)-resCurrent.conf_Intervals(:)))< EPS, 'Error: CIs changed!')
assert(max(abs(resOld.devianceResiduals(:)-resCurrent.devianceResiduals(:)))< 100*EPS, 'Error: deviances changed!')
end