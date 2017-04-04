function out = PsignifitLegacyOptionsConverter( varargin )
%% function out = PsignifitLegacyOptionsConverter( varargin )
%
% Converts the most important options from  the bootstrap-based legacy version 2.5
% to new Bayesian psignifit 4.
%
%   FAW      04.2017       v0.5 Conversion of the most important options.
%                          v0.9 Conversion of all (?) options.
%                          v1.0 Bug fixes and comments from Heiko Schuett
%                          included.
%
VERBOSE = 'true';

if strcmp(VERBOSE, 'true')
    disp(' ')
    disp('This function converts, as far as possible, options from the bootstrap-based legacy version 2.5')
    disp(' to the new Bayesian version psignifit 4. For further information refer to the open access publication')
    disp(' Schuett, Harmeling, Macke and Wichmann (2016). Painfree and accurate Bayesian estimation')
    disp(' of psychometric functions for (potentially) overdispersed data. Vision Research 122, 105-123.')
    disp(' ')
    warning(['Psignifit 4 by default assumes psychometric functions to be increasing' ...
        ' functions, i.e. to have a positive slope. If you want to fit a decreasing' ...
        ' psychometric function with negative slope you need to prepend "neg_" to the' ...
        ' name of the sigmoid in the options struct, e.g. options.sigmoidName = ''neg_weibull''; '])
end

if isempty(varargin) || (length(varargin) < 2), error('Function must be called with at least one option pair, i.e. at least two arguments.'), end
if length(varargin)/2 ~= round(length(varargin)/2), error('Function must be called with an even number of arguments: pairs of options and values.'), end

i = 1; out = [];
while ~isempty(varargin)
    arg = lower(varargin{1});
    val = lower(varargin{2});            % lower does not affect numerical entries (MATLAB R2016b)
    if isnumeric(arg), error('expected a string specifying an option, found a number as argument at position %d', i)
    elseif isempty(arg), error('could not interpret argument %d as an option string', i)
    elseif ~isempty(arg)
        % look for legal option strings ?
        out = LegalOptions(arg, val, i, out);
    end
    varargin(1:2) = []; i = i + 2;
end
disp(' ')
end




function out = LegalOptions(myOption, myValue, myIndex, tmp)
%% function out = LegalOptions(myOption, myValue, myIndex, tmp)
out = tmp;
switch myOption
    case 'n_intervals'
        if ~isnumeric(myValue)
            error('Value supplied at position %d must be a number for the option "n_intervals"---you entered %s', myIndex+1, myValue)
        end
        if (myValue ~= round(myValue)) || myValue <= 0
            error('Value supplied at position %d must be a positive integer for the option "n_intervals"---you entered %f', myIndex+1, myValue)
        end
        
        % Make sure to set this option only if user has not previously set
        % 'lambda_equals_gamma', i.e. do not overwrite this setting.
        if ~isfield(out, 'expType')
            % Thus the field "expType" has not yet been set
            if myValue == 1, out.expType = 'YesNo';
            elseif myValue > 1
                out.expType = 'nAFC';
                out.expN = myValue;
            end
        else
            % Thus the field "expType" has already been set before. Check whether due
            % to a call to "lambda_equals_gamma"
            if strcmp(out.expType, 'equalAsymptote')
                if myValue ~= 1
                    error('Inconsistent options settings: You have set the option "lambda_equals_gamma" in combination with a nAFC design in "n_intervals". One of the two options settings must be changed.')
                end
            end
        end
        
    case 'plot_opt'
        disp(' ')
        disp('Psignifit 4 uses separate functions for the Bayesian estimation of the ')
        disp(' psychometric function ("psignifit"), and the plotting of the results ("plotPsych", ')
        disp(' "plotMarginal", "plot2D", "plotBayes" and "plotPrior").')
        disp(' Thus the option "plot_opt" is ignored in the call to "psignifit".')
        disp(' For details see https://github.com/wichmann-lab/psignifit/wiki/Plot-Functions')
        
    case 'shape'
        if strcmp(myValue, 'weibull')
            out.sigmoidName = 'weibull';
        elseif strcmp(myValue, 'logistic')
            out.sigmoidName = 'logistic';
        elseif strcmp(myValue, 'cumulative gaussian')
            out.sigmoidName = 'norm';
        elseif strcmp(myValue, 'gumbel')
            out.sigmoidName = 'gumbel';
        elseif strcmp(myValue, 'linear')
            error('Psignifit 4 no longer supports a linear psychometric function')
        else
            error('Value "%s" supplied at position %d is unknown for the option "shape"', myValue, myIndex+1)
        end
        
    case 'lambda_equals_gamma'
        if myValue == 1
            out.expType = 'equalAsymptote';
            if isfield(out, 'expN')
                if out.expN > 1
                    error('Inconsistent options settings: You have set the option "lambda_equals_gamma" in combination with a nAFC design in "n_intervals". One of the two options settings must be changed.')
                end
            end
        else
            disp(' ')
            disp('You turned off equal asymptotes, i.e. lambda is not enforced to be equal to gamma.')
            disp(' This is the default behaviour of both legacy psignifit 2.5 as well as the')
            disp(' new psignifit 4. Thus there is no need to explicitly set this option.')
        end
        
    case 'cuts'
        if ~isnumeric(myValue), error('Value supplied at position %d must be a number for the option "cuts"---you entered %s', myIndex+1, myValue),  end
        if length(myValue) > 1
            error('Psignifit 4 can only calculate Bayesian credible intervals at a single nominal value on the sigmoid; please supply a single number between 0 and 1 as option for "cuts" (default: 0.5)')
        end
        if any(myValue < 0) || any(myValue > 1), error('The value at which to obtain the point estimates and credible intervals must be within the nominal range of the sigmoid, i.e. between 0 and 1 (default: 0.5)'), end
        out.threshPC = myValue;
        if myValue ~= 0.5
            disp(' ')
            warning('You have selected to obtain a threshold different than the psignifits default value of 0.5. This may require you to manually adjust the priors, see https://github.com/wichmann-lab/psignifit/wiki/How-to-Change-the-Threshold-Percent-Correct')
        else
            disp(' ')
            disp('You have selected to obtain a threshold at 0.5, i.e. in the middle of the')
            disp(' range of the sigmoidal function. This is the default behaviour of ')
            disp(' psignifit 4. Thus there is no need to explicitly set this option.')
        end
        
    case 'conf'
        if ~isnumeric(myValue), error('Value supplied at position %d must be a number for the option "conf"---you entered %s', myIndex+1, myValue), end
        if any(myValue < 0) || any(myValue) > 1, error('The coverage of the credible intervals has to be between 0 and 1 (default: 0.95, 0.9 and 0.68)'), end
        % psignifit 2.5 convention was different; lower and upper
        % boundaries were specified.
        myValue = sort(myValue, 'descend');  % order convention of psignifit 4
        if length(myValue)/2 == round(length(myValue)/2)
            tmpCounter = 1;
            for j = 1:length(myValue)/2
                if (myValue(j)+myValue(end-j+1) >= 0.999) && (myValue(j)+myValue(end-j+1) <= 1.001)
                    out.confP(tmpCounter) = round(100*(myValue(j)-myValue(end-j+1)))/100;
                    disp(' ')
                    warning('It appears you may have specified the confidence interval in the way psignifit 2.5 defined them, i.e. specifying a lower and upper bound---you entered %f and %f. The options converter converted this entry to the %d-percent credible interval expected by psignifit 4.  If this automatic conversion is not line with your intention, please manually change the values in the "confP" field of the options struct.' , myValue(j), myValue(end-j+1), 100*out.confP(tmpCounter) )
                end
                tmpCounter = tmpCounter+1;
            end
        else
            out.confP = myValue;
        end
        
    case 'slope_opt'
        if strcmp(myValue, 'linear x')
            disp(' ')
            disp('Psignifit 4 no longer allows you to choose a linear x-axis for')
            disp(' all psychometric function shapes. If you choose the "logistic", "cumulative gaussian" or "gumbel" for the shape,')
            disp(' or manually enter "rgumbel" (the reversed Gumbel) in the options struct, i.e. options.sigmoidName = ''rgumbel'',')
            disp(' then psignifit 4 will (automatically) assume data to be on a linear scale.')
            disp(' For the functions getSlope and getSlopePC Psignifit 4 always assumes a linear scale.')
        elseif strcmp(myValue, 'log x')
            disp(' ')
            disp('Psignifit 4 no longer allows you to choose a logarithmic x-axis for')
            disp(' all psychometric function shapes. If you choose the "Weibull" for the shape,')
            disp(' or manually enter "logn" (the log-normal) in the options struct, i.e. options.sigmoidName = ''logn'',')
            disp(' then psignifit 4 will (automatically) assume data to be on a log-scale.')
            disp(' For the functions getSlope and getSlopePC Psignifit 4 always assumes a linear scale.')
        else
            disp(' ')
            disp(['Value "' myValue '" supplied at position ' num2str(myIndex+1) ' is unknown for the option "slope_opt and thus ignored,'])
        end
        
        
    case 'fix_shift'
        if ~isfield(out, 'fixedPars'), out.fixedPars = NaN(5,1); end
        if ~isnumeric(myValue)
            error('Value supplied at position %d must be a number for the option "fix_shift"---you entered %s' , myIndex+1, myValue)
        end
        out.fixedPars(1) = myValue;
        
    case 'fix_slope'
        if ~isfield(out, 'fixedPars'), out.fixedPars = NaN(5,1); end
        if ~isnumeric(myValue), error('Value supplied at position %d must be a number for the option "fix_slope"---you entered %s' , myIndex+1, myValue); end
        out.fixedPars(2) = myValue;
        disp(' ')
        warning(['Psignifit 4 defines and estimates psychometric functions in' ...
            ' terms of the width, not the slope of the psychometric function.' ...
            ' Please review the value you have supplied, and make sure it corresponds to ' ...
            ' the width of the psychometric function!' ...
            ' Consult the Schuett et al. (2016) paper and see https://github.com/wichmann-lab/psignifit/wiki' ])
        
    case 'fix_alpha'
        if ~isfield(out, 'fixedPars'), out.fixedPars = NaN(5,1); end
        if ~isnumeric(myValue)
            error('Value supplied at position %d must be a number for the option "fix_alpha"---you entered %s' , myIndex+1, myValue)
        end
        out.fixedPars(1) = myValue;
        disp(' ')
        warning(['Psignifit 4 defines and estimates psychometric functions in terms of the threshold, not the alpha parameter of the psychometric function.' ...
            ' Please review the value you have supplied, and make sure it corresponds to the threshold of the psychometric function!' ...
            ' Consult the Schuett et al. (2016) paper and see https://github.com/wichmann-lab/psignifit/wiki'])
        
    case 'fix_beta'
        if ~isfield(out, 'fixedPars'), out.fixedPars = NaN(5,1); end
        if ~isnumeric(myValue)
            error('Value supplied at position %d must be a number for the option "fix_beta"---you entered %s' , myIndex+1, myValue)
        end
        out.fixedPars(2) = myValue;
        disp(' ')
        warning(['Psignifit 4 defines and estimates psychometric functions in terms of the width, not the beta parameter of the psychometric function.' ...
            ' Please review the value you have supplied, and make sure it corresponds to the width of the psychometric function!' ...
            ' Consult the Schuett et al. (2016) paper and see https://github.com/wichmann-lab/psignifit/wiki'])
        
    case 'fix_gamma'
        if ~isfield(out, 'fixedPars'), out.fixedPars = NaN(5,1); end
        if ~isnumeric(myValue), error(['Value supplied at position ' num2str(myIndex+1) ' must be a number for the option "fix_gamma"---you entered "' myValue '" ']), end
        if myValue < 0 || myValue > 1, error('Gamma can only be fixed to 0 <= gamma <= 1.0'), end
        out.fixedPars(4) = myValue;
        
    case 'fix_lambda'
        if ~isfield(out, 'fixedPars'), out.fixedPars = NaN(5,1); end
        if ~isnumeric(myValue)
            error(['Value supplied at position ' num2str(myIndex+1) ' must be a number for the option "fix_lambda"---you entered "' myValue '" '])
        end
        if myValue < 0 || myValue > 1, error('Lambda can only be fixed to 0 <= lambda <= 1.0'), end
        out.fixedPars(3) = myValue;
        
    case 'runs'
        disp(' ')
        disp('Option "runs", the number of bootstrap repetitions, is no longer needed,')
        disp(' because psignifit 4 uses Grid evaluations to obtain credible')
        disp(' intervals and point estimates.')
        disp(' To change the precision of the Bayesian credible intervals refer to')
        disp(' "options.stepN" on https://github.com/wichmann-lab/psignifit/wiki/Options-Struct')
        disp(' Only change this option, however, if you know what you are doing!')
        
    case {'alpha_limits','beta_limits','gamma_limits','lambda_limits'}
        disp(' ')
        disp('Setting limits on one of the parameters to constrain the maximum-likelihood fit')
        disp([' is not longer supported in psignifit 4---you tried to enforce a limit using "' myOption '" '])
        disp(' Please consult the psignifit 4 documentation or the github-Wiki on how to adjust')
        disp(' the priors instead---should you really need to do this: https://github.com/wichmann-lab/psignifit/wiki/Priors')
        
    case {'alpha_prior','beta_prior','gamma_prior','lambda_prior'}
        disp(' ')
        warning('You attempt to change the default prior using the "%s" option. However, changing the default priors in psignifit 4 has changed considerably from the legacy version 2.5. Please consult the psignifit 4 documentation or the github-Wiki on how to adjust the priors: https://github.com/wichmann-lab/psignifit/wiki/Priors', myOption)
        
    case {'gen_shape','gen_params','gen_values'}
        disp(' ')
        disp('Psignifit 4 can not be used to generate synthetic datasets.')
        
    case {'sens','sens_coverage'}
        disp(' ')
        disp('Psignifit 4 uses Bayesian statistics, and thus a sensitivity analysis is no longer needed.')
        
    case 'compute_stats'
        disp(' ')
        disp('Psignifit 4 always calculates the appropriate statistics, the option "compute_stats" is thus no longer needed')
        disp(' To explore (potential) interval bias in the data please see https://github.com/wichmann-lab/psignifit/wiki/Interval-Bias')
        
    case 'refit'
        disp(' ')
        disp('Psignifit 4 uses Bayesian statistics, and thus the "refit" option in statistics is no longer needed.')
        
    case 'verbose'
        disp(' ')
        disp('Psignifit 4 no longer lets you choose the level of verbosity---it is never overly verbose ;-)')
        disp('Should any of the important warnings psignifit produces particularly annoy you, you can turn them off')
        
    case {'data_x','data_y','data_n','data_right','data_wrong','matrix_format','est_gamma','est_lambda','mesh_resolution', ...
            'mesh_iterations','random_seed','compute_params'}
        disp(' ')
        disp(['Option ' myOption ' is no longer needed and/or supported in psignifit 4.'])
        
    otherwise
        disp(' ')
        if ~isempty(strfind(myOption, 'write_'))
            disp('None of the many low-level "write_ ..." options of psignifit 2.5 are supported in psignifit 4.')
        else
            warning('Option "%s" supplied at position %d is unknown and thus ignored together with the value supplied at position %d', myOption, myIndex, myIndex+1)
        end
end

end


