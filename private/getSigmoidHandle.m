function Handle=getSigmoidHandle(options)
% creates a function handle to a specific sigmoid
%function Handle=getSigmoidHandle(options)
% This function creates a function handle to the sigmoid specified by its
% name in options.sigmoidName. 
% Additional parameter is the options.widthalpha which specifies the
% scaling of the width by
% width= psi^(-1)(1-alpha) - psi^(-1)(alpha)
% where psi^(-1) is the inverse of the sigmoid function.
%

if isstruct(options)
    %actually is checked in psignifit as well
    if ~isfield(options,'widthalpha'), options.widthalpha = .05; end
    alpha   = options.widthalpha;
    sigmoid = options.sigmoidName;
    PC      = options.threshPC;
elseif ischar(options)
    sigmoid = options;
    alpha   = .05;
    PC      = .5;
end
if ischar(sigmoid)
    if strcmp(sigmoid(1:3),'neg')
        PC = 1-PC;
    end
end

if ischar(sigmoid)
    switch sigmoid
        case {'norm','gauss'}   % cumulative normal distribution
            C      = my_norminv(1-alpha,0,1) - my_norminv(alpha,0,1);
            Handle = @(X, m, width) my_normcdf(X, m-my_norminv(PC,0,width./C), width ./ C);
        case 'logistic'         % logistic function
            Handle = @(X, m, width) 1 ./ (1 + exp(-2 * log(1./alpha - 1) ./ width .* (X-m) + log(1./PC - 1)));
        case 'gumbel'           % gumbel
            % note that gumbel and reversed gumbel definitions are sometimes swapped
            % and sometimes called extreme value distributions
            C      = log(-log(alpha)) - log(-log(1-alpha));
            Handle = @(X, m, width) 1 - exp(-exp(C ./ width .* (X-m) + log(-log(1-PC))));
        case 'rgumbel'          % reversed gumbel 
            % note that gumbel and reversed gumbel definitions are sometimesswapped
            % and sometimes called extreme value distributions
            C      = log(-log(1-alpha)) - log(-log(alpha));
            Handle = @(X, m, width) exp(-exp( C ./ width .* (X-m) + log(-log(PC))));
        case 'logn'             % cumulative lognormal distribution
            C      = my_norminv(1-alpha,0,1) - my_norminv(alpha,0,1);
            Handle = @(X, m, width) my_normcdf(log(X), m-my_norminv(PC,0,width./C), width ./ C);
        case {'Weibull','weibull'} % Weibull
            C      = log(-log(alpha)) - log(-log(1-alpha));
            Handle = @(X, m, width) 1 - exp(-exp(C./ width .* (log(X)-m) + log(-log(1-PC))));
        case {'tdist','student','heavytail'} 
                                % student T distribution with 1 df
                                %-> heavy tail distribution
            C      = (my_t1icdf(1-alpha) - my_t1icdf(alpha));
            Handle = @(X, m, width) my_t1cdf(C.*(X-m)./ width + my_t1icdf(PC));            
        
        case {'neg_norm','neg_gauss'}   % cumulative normal distribution
            C      = my_norminv(1-alpha,0,1) - my_norminv(alpha,0,1);
            Handle = @(X, m, width) 1-my_normcdf(X, m-my_norminv(PC,0,width./C), width ./ C);
        case 'neg_logistic'         % logistic function
            Handle = @(X, m, width) 1-(1 ./ (1 + exp(-2 * log(1./alpha - 1) ./ width .* (X-m) + log(1./PC - 1))));
        case 'neg_gumbel'           % gumbel
            % note that gumbel and reversed gumbel definitions are sometimes swapped
            % and sometimes called extreme value distributions
            C      = log(-log(alpha)) - log(-log(1-alpha));
            Handle = @(X, m, width) 1-(1 - exp(-exp(C ./ width .* (X-m) + log(-log(1-PC)))));
        case 'neg_rgumbel'          % reversed gumbel 
            % note that gumbel and reversed gumbel definitions are sometimesswapped
            % and sometimes called extreme value distributions
            C      = log(-log(1-alpha)) - log(-log(alpha));
            Handle = @(X, m, width) 1-exp(-exp( C ./ width .* (X-m) + log(-log(PC))));
        case 'neg_logn'             % cumulative lognormal distribution
            C      = my_norminv(1-alpha,0,1) - my_norminv(alpha,0,1);
            Handle = @(X, m, width) 1-my_normcdf(log(X), m-my_norminv(PC,0,width./C), width ./ C);
        case {'neg_Weibull','neg_weibull'} % Weibull
            C      = log(-log(alpha)) - log(-log(1-alpha));
            Handle = @(X, m, width) exp(-exp(C./ width .* (log(X)-m) + log(-log(1-PC))));
        case {'neg_tdist','neg_student','neg_heavytail'} 
                                % student T distribution with 1 df
                                %-> heavy tail distribution
            C      = (my_t1icdf(1-alpha) - my_t1icdf(alpha));
            Handle = @(X, m, width) 1-my_t1cdf(C.*(X-m)./ width + my_t1icdf(PC));
        otherwise
            error('unknown sigmoid function');
    end
elseif isa(sigmoid,'function_handle')
    Handle = sigmoid;  
else
    error('sigmoid must be either handle or name of a sigmoid');
end

end

