function checkPriors(data,options)
% this runs a short test whether the provided priors are functional
%function checkPriors(data,options)
% concretely the priors are evaluated for a 25 values on each dimension and
% a warning is issued for zeros and a error for nan and infs and negative
% values


if options.logspace
    data(:, 1) = log(data(:, 1));
end

%% on threshold
% values chosen according to standard boarders 
% at the borders it may be 0 -> a little inwards
dataspread = max(data(:, 1)) - min(data(:, 1));                                      % spread of the data
testValues = linspace(min(data(:, 1)) - .4 * dataspread, max(data(:, 1)) + .4 * dataspread,25); % threshold testvalues

testresult = options.priors{1}(testValues);

assert(all(isfinite(testresult)),'the prior you provided for the threshold returns non-finite values');
assert(all(testresult>=0),       'the prior you provided for the threshold returns negative values');
if any(testresult==0)
    warning('the prior you provided for the threshold returns zeros');
end

%% on width
% values according to standard priors
testValues = linspace(1.1*min(diff(sort(unique(data(:, 1))))) , 2.9 * dataspread,25); 

testresult = options.priors{2}(testValues);

assert(all(isfinite(testresult)),'the prior you provided for the width returns non-finite values');
assert(all(testresult>=0),       'the prior you provided for the width returns negative values');
if any(testresult==0)
    warning('the prior you provided for the width returns zeros');
end

%% on lambda 
% values 0 to .9
testValues = linspace(0.001,.9,25);

testresult = options.priors{3}(testValues);

assert(all(isfinite(testresult)),'the prior you provided for lambda returns non-finite values');
assert(all(testresult>=0),       'the prior you provided for lambda returns negative values');
if any(testresult==0)
    warning('the prior you provided for the lambda returns zeros');
end

%% on gamma
% values 0 to .9
testValues = linspace(0.0001,.9,25);

testresult = options.priors{4}(testValues);

assert(all(isfinite(testresult)),'the prior you provided for gamma returns non-finite values');
assert(all(testresult>=0),       'the prior you provided for gamma returns negative values');
if any(testresult==0)
    warning('the prior you provided for the gamma returns zeros');
end

%% on eta
% values 0 to .9
testValues = linspace(0,.9,25);

testresult = options.priors{5}(testValues);

assert(all(isfinite(testresult)),'the prior you provided for eta returns non-finite values');
assert(all(testresult>=0),       'the prior you provided for eta returns negative values');
if any(testresult==0)
    warning('the prior you provided for the eta returns zeros');
end



