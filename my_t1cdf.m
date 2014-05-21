function p=my_t1cdf(x)
% cumulative distribution function of a t-dist. with 1 degree of freedom
%function p=my_t1cdf(x)
%input
%       x = point
%output
%       p = cumulative probability
%
%see also: tcdf

xsq=x.*x;
p = betainc(1 ./ (1 + xsq), 1/2, 1/2, 'lower') / 2;
p(x>0)=1-p(x>0);