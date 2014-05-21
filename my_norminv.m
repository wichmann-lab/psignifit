function x=my_norminv(p,mu,sigma)
% implements the most common version of MATLABs norminv function
%function x=my_norminv(p,mu,sigma)
% ths function computes quantiles of the normal distribution
%input:
%       p = percentage requested
%      mu = mean of the distribution
%   sigma = standard deviation 
%
%output: 
%       x = the requested quantile
%
% see also: norminv

x0 = -sqrt(2).*erfcinv(2*p);
x  = sigma.*x0 + mu;