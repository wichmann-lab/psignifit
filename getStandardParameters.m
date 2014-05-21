function theta = getStandardParameters(theta,type,widthalpha)
% this function transforms a parameter given in threshold, width to a
% standard parameterization for comparison purposes
%function theta = getStandardParameters(theta,type,[widthalpha])
% theta = parameter
% type  = Name of the Sigmoid
%
% if you changed the widthalpha you should pass it as an additional
% argument
%
% norm/gauss/normal
%       theta(1) = threshold -> threshold
%       theta(2) = width     -> standard deviation
% logistic
%       theta(1) = threshold -> threshold
%       theta(2) = width     -> slope at threshold
% Weibull/weibull
%       theta(1) = threshold -> scale 
%       theta(2) = width     -> shape parameter
% gumbel & rgumbel distributions
%       theta(1) = threshold -> mode
%       theta(2) = width     -> scale
% tdist
%       theta(1) = threshold -> threshold/mean
%       theta(2) = width     -> standard deviation

if ~exist('widthalpha','var'), widthalpha=.05; end
assert(logical(exist('type','var')),'You need to specify which kind of sigmoid you fit');

switch type
    case {'norm','gauss','normal'}
        theta(1) = theta(1);
        C        = my_norminv(1-widthalpha,0,1) - my_norminv(widthalpha,0,1);
        theta(2) = theta(2)./C;
    case 'logistic'
        theta(1) = theta(1);
        theta(2) = 2*log(1./widthalpha-1)./theta(2);
    case {'Weibull','weibull'}
        C        = log(-log(widthalpha)) - log(-log(1-widthalpha));
        Handle   = @(X, m, width) 1 - exp(-exp(C./ width .* (log(X)-m) + log(-log(.5))));
        shape    = C./theta(2);
        scale    = 1 - Handle(1,theta(1),theta(2));
        scale    = exp(log(-1/log(scale))/shape); %Wikipediascale
        theta(1) = scale;
        theta(2) = shape;
    case {'gumbel'}
        % note that gumbel and reversed gumbel definitions are sometimes swapped
        % and sometimes called extreme value distributions
        C        = log(-log(alpha)) - log(-log(1-alpha));
        theta(2) = theta(2)/C;
        theta(1) = theta(1)+theta(2).*log(-log(.5));
    case {'rgumbel'}
        C      = log(-log(1-alpha)) - log(-log(alpha));
        theta(2) = -theta(2)./C;
        theta(1) = theta(1)-theta(2).*log(-log(.5));
    case {'tdist','student','heavytail'} 
        C      = (my_t1icdf(1-alpha) - my_t1icdf(alpha));    
        theta(1) = theta(1);
        theta(2) = theta(2)./C;
        
end