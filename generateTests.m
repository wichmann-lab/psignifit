function generateTests()
% this function generates some test data to be used with the consistency
% tests. It is just a list of the testcases effectively

% the most basic dataset
simulate_data('tests/test_cases/test1','2AFC','binom','Blocks10_fix',100,'norm')

% test case without blocks
simulate_data('tests/test_cases/test_noblock',...
              '2AFC','binom','N1_random',100,'norm');

% test different sigmoids & types of experiment
for iSigmoid = 1:7
    switch iSigmoid
        case 1
            sigmoidName = 'norm';
        case 2
            sigmoidName = 'gumbel';
        case 3
            sigmoidName = 'rgumbel';
        case 4
            sigmoidName = 'logistic';
        case 5
            sigmoidName = 'tdist';
        case 6
            sigmoidName = 'Weibull';
        case 7
            sigmoidName = 'logn';
    end
    simulate_data(sprintf('tests/test_cases/test_2AFC_%s', sigmoidName),...
                  '2AFC','binom','Blocks10_fix',100,sigmoidName);
    simulate_data(sprintf('tests/test_cases/test_YesNo_%s', sigmoidName),...
                  'YesNo','binom','Blocks10_fix',100,sigmoidName);
    simulate_data(sprintf('tests/test_cases/test_eA_%s', sigmoidName),...
                  'equalAsymptote','binom','Blocks10_fix',100,sigmoidName);
end