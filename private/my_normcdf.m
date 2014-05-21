function p = my_normcdf(x, mu, sigma)
%MY_NORMCDF implements the most common case of Matlab's NORMCDF.
%function p = my_normcdf(x, mu, sigma)
% ths function computes quantiles of the normal distribution
%input:
%       x = point
%      mu = mean of the distribution
%   sigma = standard deviation 
%
%output: 
%       p = the requested probability
%
% see also: normcdf

%% normalize
z = (x-mu) ./ sigma;

%% calculate normalized CDF
p = 0.5 * erfc(-z ./ sqrt(2));
return
