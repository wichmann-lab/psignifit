function [p,logPmax] = likelihood(data, options, alpha, beta, lambda, gamma, varscale)
% calculates the (normalized) likelihood for the data from given parameters
%function [p,logPmax] = likelihood(typeHandle,data,alpha,beta,lambda,gamma)
% This function computes the likelihood for specific parameter values from
% the log-Likelihood
% The result is normalized to have maximum=1 because the Likelihoods become
% very small and this way stay in the range representable in floats

p = logLikelihood(data, options, alpha, beta, lambda, gamma, varscale);

% We never need the actual value of the likelihood. Something proportional
% is enough and this circumvents numerical problems for the likelihood to
% become exactly 0
logPmax = max(p(:));
p = p - max(p(:));
% exp to get back the likelihood from the log-likelihood
p = exp(p);