function y = my_normpdf(x)
% this implements the  standard normpdf without checks 
% and without the possibility to set mu and sigma
% function y = my_normpdf(x)

y = exp(-0.5 * x.^2) ./ sqrt(2*pi);
