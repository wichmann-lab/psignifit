function Seed = getSeed(data,options)
% calculation of a first guess for the parameters
%function Seed=getSeed(data,options)
% This function finds a seed for initial optimization by logistic
% regression of the data
% Additional parameter is the options.widthalpha which specifies the
% scaling of the width by
% width= psi^(-1)(1-alpha) - psi^(-1)(alpha)
% where psi^(-1) is the inverse of the sigmoid function.

%input parsing
alpha0 = options.widthalpha;
if options.logspace,    data(:,1) = log(data(:,1)); end

x      = data(:,1);
y      = data(:,2)./data(:,3);

% lower and upper asymptote taken simply from min/max of the data
lambda = 1-max(data(:,2)./data(:,3));
gamma  = min(data(:,2)./data(:,3));

% rescale y
y      = (y - gamma) ./ (1 - lambda - gamma);


% prevent 0 and 1 as bad input for the logit
% this moves the data in from the borders by .25 of a trial from up and
% .25 of a trial from the bottom
factor = .25 ./ data(:,3);
y      = factor + (1-2 .* factor) .* y;

% logit transform
y      = log(y ./ (1-y));


% fit robust if possible
if exist('robustfit')
    fit = robustfit(x, y);
else % Without statistics toolbox do standard linear regression
    fit = polyfit(x, y, 1);
    fit = [fit(2);fit(1)];  % change to format as it is returned from robustfit
end


% threshold at the zero of the linear fit
% fit(2)*alpha+fit(1)=0
alpha    = -fit(1) / fit(2);

% width of the function difference between x'es where the logistic is alpha
% and where it is 1-alpha
beta     = (log((1-alpha0) ./ alpha0) - log(alpha0 ./ (1-alpha0))) ./ fit(2);

% varscale is set to almost 0-> we start with the binomial model
varscale = exp(-20);


Seed     = [alpha; beta; lambda; gamma; varscale];


end