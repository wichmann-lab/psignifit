function x=my_t1icdf(p)
% inverse cumulative distribution function of a t-dist. with 1 degree of freedom
%function p=my_t1icdf(x)
%input
%       x = point
%output
%       p = cumulative probability
%
%see also: tinv

x = tan(pi * (p - 0.5));