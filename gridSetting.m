function X1D = gridSetting(data, options, Seed)
%set for each dim the stepN Xvalues adaptively
%function gridSetting(data,options)
% This tries to get equal steps in cummulated likelihood in the slice
% thorugh the Seed
% it evaluates at GridSetEval points from Xborders(:,1) to Xborders(:,2)

%Initialization
d      = size(options.borders, 1);
X1D    = cell(d, 1);


%% equal steps in cumulative distribution
if strcmp(options.gridSetType, 'cumDist')
Like1D = zeros(options.GridSetEval, 1);                   % likelihood on a line thorugh the Seed
for id = 1:d
    if options.borders(id, 1) < options.borders(id, 2)    % If there is an actual Interval
        X1D{id}    = zeros(1, options.stepN(id));         % Initialize X1D
        localNeval = options.GridSetEval;                 % to be able to increase # of evaluations locally
        while any(diff(X1D{id}) == 0)                     % catch if any value appears 2 times
            Xtest1D  = linspace(options.borders(id,1),options.borders(id,2),localNeval); % where to evaluate to test
            alpha    = Seed(1);
            beta     = Seed(2);
            lambda   = Seed(3);
            gamma    = Seed(4);
            varscale = Seed(5);
            switch id                                     % Which dimension is set
                case 1, alpha    = Xtest1D;
                case 2, beta     = Xtest1D;
                case 3, lambda   = Xtest1D;
                case 4, gamma    = Xtest1D;
                case 5, varscale = Xtest1D;
            end
            % calculate Likelihood on the line
            Like1D = likelihood(data, options, alpha, beta, lambda, gamma, varscale); % Evaluate Likelihood on the line
            Like1D = Like1D + mean(Like1D)*options.UniformWeight;                     % Add UniformWeight*mean to each point to get broader spacing
            Like1D = cumsum(Like1D);                                                  % accumulate Likelihood
            Like1D = Like1D ./ max(Like1D);                                           % normalize Likelihood to sum 1
            wanted = linspace(0, 1, options.stepN(id));                               % the percentiles we want to place our gridpoints at.
            for igrid=1:options.stepN(id)                 % find the percentiles of the likelihood
                X1D{id}(igrid) = Xtest1D(find(Like1D >= wanted(igrid), 1, 'first'));
            end
            localNeval = 10*localNeval;                   % If we have problems with multiple points at the same place evaluate more densely
        end
    else
        X1D{id} = options.borders(id,1);                  % if the parameter was fixed
    end
end

%% equal steps in cumulative second derivative -> proxi for difference from linear
elseif any(strcmp(options.gridSetType, {'2', '2ndDerivative'}))
Like1D = zeros(options.GridSetEval, 1);                   % likelihood on a line thorugh the Seed
for id = 1:d
    if options.borders(id, 1) < options.borders(id, 2)    % If there is an actual Interval
        X1D{id}    = zeros(1, options.stepN(id));         % Initialize X1D
        localNeval = options.GridSetEval;                 % to be able to increase # of evaluations locally
        while any(diff(X1D{id}) == 0)                     % catch if any value appears 2 times
            Xtest1D  = linspace(options.borders(id,1),options.borders(id,2),localNeval); % where to evaluate to test
            alpha    = Seed(1);
            beta     = Seed(2);
            lambda   = Seed(3);
            gamma    = Seed(4);
            varscale = Seed(5);
            switch id                                     % Which dimension is set
                case 1, alpha    = Xtest1D;
                case 2, beta     = Xtest1D;
                case 3, lambda   = Xtest1D;
                case 4, gamma    = Xtest1D;
                case 5, varscale = Xtest1D;
            end
            % calculate Likelihood on the line
            Like1D = likelihood(data, options, alpha, beta, lambda, gamma, varscale);               % Evaluate Likelihood on the line
            Like1D = abs(conv(squeeze(Like1D),[1, -2, 1],'same'));                                  % calculate numerical second derivative
            Like1D = Like1D + mean(Like1D)*options.UniformWeight;                                   % Add UniformWeight*mean to each point to get broader spacing
            Like1D = cumsum(Like1D);                                                                % accumulate Likelihood
            Like1D = Like1D ./ max(Like1D);                                                         % normalize Likelihood to sum 1
            wanted = linspace(0, 1, options.stepN(id));                                             % the percentiles we want to place our gridpoints at.
            for igrid=1:options.stepN(id)                 % find the percentiles of the likelihood
                X1D{id}(igrid) = Xtest1D(find(Like1D >= wanted(igrid), 1, 'first'));
            end
            localNeval = 10*localNeval;                   % If we have problems with multiple points at the same place evaluate more densely
            if localNeval > 10^7                          % but we do not want to overdo it...
                X1D{id} = unique(X1D{id});
                break
            end
        end
    else
        X1D{id} = options.borders(id,1);                  % if the parameter was fixed
    end
end

%% different choices for the varscale
% WE USE STD now directly as parameterisation
elseif any(strcmp(options.gridSetType, {'priorlike','STD','exp','4power'}))
        for id=1:4
            if options.borders(id, 1) < options.borders(id, 2)           % If there is an actual Interval
                X1D{id} = linspace(options.borders(id,1), options.borders(id,2), options.stepN(id));
            else
                X1D{id} = options.borders(id,1);                         % if the parameter was fixed
            end
        end
        switch options.gridSetType
            case 'priorlike'
                maximum= betacdf(options.borders(5,2),1,options.betaPrior);
                min    = betacdf(options.borders(5,1),1,options.betaPrior);
                X1D{5} = betainv(linspace(min,maximum,options.stepN(5)),1,options.betaPrior);
            case 'STD'
                maximum= sqrt(options.borders(5,2));
                min    = sqrt(options.borders(5,1));
                X1D{5} = (linspace(min,maximum,options.stepN(5))).^2;
            case 'exp'
                p      = linspace(1,.1,options.stepN(5));
                X1D{5} = log(p)./log(.1)*(options.borders(5,2) - options.borders(5,1))+options.borders(5,1);
            case '4power'
                maximum= sqrt(sqrt(options.borders(5,2)));
                min    = sqrt(sqrt(options.borders(5,1)));
                X1D{5} = (linspace(min,maximum,options.stepN(5))).^4;   
        end
end