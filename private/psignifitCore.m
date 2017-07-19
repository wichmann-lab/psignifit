function result=psignifitCore(data,options)
% this is the Core processing of psignifit, call the frontend psignifit!
%function result=psignifitCore(data,options)
% Data nx3 matrix with values [x, percCorrect, NTrials]
%
% sigmoid should be a handle to a function, which accepts
% X,parameters as inputs and gives back a value in [0,1]. ideally
% parameters(1) should correspond to the threshold and parameters(2) to
% the width (distance containing 95% of the function



d = size(options.borders, 1);

%% Choose grid dynamically from data
if options.dynamicGrid
    % get seed from linear regression with logit transform
    Seed = getSeed(data, options);
    % further optimize the logliklihood to obtain a good estimate of the MAP
    switch options.expType
        case 'YesNo'
            Seed = fminsearch(@(X) - logLikelihood(data, options, X(1), X(2), X(3), X(4), X(5)), Seed);
        case 'nAFC'
            Seed = fminsearch(@(X) - logLikelihood(data, options, X(1), X(2), X(3), 1/options.expN, X(4)), Seed([1:3, 5]));
            Seed = [Seed(1:3); 1/options.expN; Seed(4)];
    end
    result.X1D = gridSetting(data, options, Seed);
    
else % for types which do not need a MAP estimate
    if any(strcmp(options.gridSetType, {'priorlike','STD','exp','4power'}))
        result.X1D = gridSetting(data, options);
    else % Use a linear grid
        for id=1:d
            if options.borders(id, 1) < options.borders(id, 2)           % If there is an actual Interval
                result.X1D{id} = linspace(options.borders(id,1), options.borders(id,2), options.stepN(id));
            else
                result.X1D{id} = options.borders(id,1);                  % if the parameter was fixed
            end
        end
    end
end



%% evaluate likelihood and form it into a posterior

[result.Posterior,result.logPmax] = likelihood(data, options, result.X1D{:});% calculate likelihood
result.weight    = getWeights(result.X1D);                                  % get quadrature weight of the grid points
integral         = sum(result.Posterior(:) .* result.weight(:));            % calculate total probability
result.Posterior = result.Posterior ./ integral;                            % Normalize
result.integral  = integral;

%% compute marginal distributions
%result.marginals  = cell;    % Values of the marginals
%result.marginalsX = cell;    % Gridpoint positons of the marginals
%result.marginalsW = cell;    % Quadrature weights of the marginals

for id = 1:d % for each parameter
  [result.marginals{id}, result.marginalsX{id}, result.marginalsW{id}] = marginalize(result,id);
end


%% find point estimate
switch options.estimateType
 case {'MAP','MLE'}
  % get MLE estimate
  % For now with builtin MATLAB functions
  
  % start at most likely gridpoint
  [~, idx]    = max(result.Posterior(:));
  index       = cell(d,1);
  [index{:}]  = ind2sub(size(result.Posterior), idx);
  Fit         = zeros(d,1);
  for id = 1:d, Fit(id) = result.X1D{id}(index{id}); end
  
  % set special options, if fastOptim was chosen.
  
  switch options.expType
   case 'YesNo'
    fun = @(X) -logLikelihood(data, options, X(1), X(2), X(3), X(4), X(5));
    x0  = Fit;
   case 'nAFC'
    fun = @(X) -logLikelihood(data, options, X(1), X(2), X(3), 1/options.expN, X(4));
    x0  = Fit([(1:3)'; 5]);
   case 'equalAsymptote'
    fun = @(X) -logLikelihood(data, options, X(1), X(2), X(3), NaN, X(4));
    x0  = Fit([(1:3)'; 5]);
   otherwise, error('unknown expType'); 
  end
  if options.fastOptim 
      optimiseOptions = optimset('MaxFunEvals',100,'MaxIter',100,'TolX',0,'TolFun',0);
      warning('changed options for optimization')
  else
      optimiseOptions = optimset('Display','off');
  end
  if ~exist('OCTAVE_VERSION', 'builtin')
      Fit = fminsearch(fun, x0,optimiseOptions); %MATLAB standard choice 
  else
      Fit = fminunc(fun, x0,optimiseOptions);    % in Octave fminsearch does not work here, god knows why...
  end
  switch options.expType
   case 'YesNo',           result.Fit = Fit;
   case 'nAFC',            result.Fit = [Fit(1:3); 1/options.expN; Fit(4)];
   case 'equalAsymptote',  result.Fit = Fit([1:3,3,4]);
   otherwise, error('unknown expType'); 
  end
  result.Fit(~isnan(options.fixedPars)) = options.fixedPars(~isnan(options.fixedPars)); % fix parameters
 case 'mean'
  % get mean estimate
  Fit = zeros(d,1);
  for id = 1:d
    Fit(id) = sum(result.marginals{id}.*result.marginalsW{id}.*result.marginalsX{id});
  end
  result.Fit = Fit;
  clear Fit;
end

%% include input into result
result.options = options;
result.data    = data;



%% compute confidence intervals
if ~options.fastOptim
    result.conf_Intervals = getConfRegion(result);
end


