function borders = moveBorders(data,options)
% move parameter-boundaries to save computing power 
%function borders=moveBorders(data, options)
% this function evaluates the likelihood on a much sparser, equally spaced
% grid definded by mbStepN and moves the borders in so that that 
% marginals below tol are taken away from the borders.
%
% this is meant to save computing power by not evaluating the likelihood in
% areas where it is practically 0 everywhere.

tol = options.maxBorderValue;
d   = size(options.borders,1);

%% move borders out
% should our borders be to tight, e.g. the distribution does not go to zero
% at the borders we move them out until this is the case. 

%% Currently disabled, because we did not solve the issue with infinit bounds!!

% 
% %alpha
% aboveTol=1;
% while aboveTol
%     for id=1:d
%         OutRes.X1D{id}=linspace(options.borders(id,1),options.borders(id,2),options.mbStepN(id));
%     end
%     OutRes.Posterior=likelihood(options.sigmoidHandle,data,OutRes.X1D{:});
%     OutRes.weight=getWeights(OutRes.X1D);
%     margin=marginalize(OutRes,1);
%     margin=margin/max(margin);
%     
%     aboveTol=0;
%     if margin(1)>tol
%         options.borders(1,1)=options.borders(1,1)-(options.borders(1,2)-options.borders(1,1));
%         aboveTol=1;
%     end
%     if margin(end)>tol
%         options.borders(1,2)=options.borders(1,2)+(options.borders(1,2)-options.borders(1,1));
%         aboveTol=1;
%     end
% end
% 
% clear OutRes
% %beta
% aboveTol=1;
% while aboveTol
%     for id=1:d
%         OutRes.X1D{id}=linspace(options.borders(id,1),options.borders(id,2),options.mbStepN(id));
%     end
%     OutRes.Posterior=likelihood(options.sigmoidHandle,data,OutRes.X1D{:});
%     OutRes.weight=getWeights(OutRes.X1D);
%     margin=marginalize(OutRes,2);
%     margin=margin/max(margin);
%     
%     aboveTol=0;
%     if margin(1)>tol
%         options.borders(2,1)=options.borders(2,1)/2;
%         aboveTol=1;
%     end
%     if margin(end)>tol
%         options.borders(2,2)=options.borders(2,2)*2;
%         aboveTol=1;
%     end
% end
% 
% 



%% move borders inwards
% set up grid
for id = 1:d
    if length(options.mbStepN) >= id && options.mbStepN(id) >= 2 && options.borders(id,1) ~= options.borders(id,2)
        MBresult.X1D{id} = linspace(options.borders(id,1), options.borders(id,2), options.mbStepN(id));
    else
        % just in case the borders differ but only one value for this
        % evaluation is wanted
        % This should usually not happen!
        if options.borders(id,1) ~= options.borders(id,2) ...
                && ~strcmp(options.expType,'equalAsymptote'),...
                warning('MoveBorders: You set only one evaluation for moving the borders!'); end;
        MBresult.X1D{id} = .5*(options.borders(id,1)+options.borders(id,2));
    end
end

MBresult.weight    = getWeights(MBresult.X1D);                                    % get integration weights
MBresult.Posterior = likelihood(data, options, MBresult.X1D{:});                  % evaluate likelihood
integral           = sum(MBresult.Posterior(:) .* MBresult.weight(:));            % get total probability
MBresult.Posterior = MBresult.Posterior ./ integral;                              % normalize

borders            = zeros(d,2);
for id=1:d
    % this is already normed to have integral 1
    [L1D, x, w]    = marginalize(MBresult,id);                                    % marginalize
    x1             = x(max(find(L1D.*w>=tol, 1, 'first') - 1, 1));                % find first rise above threshold
    x2             = x(min(find(L1D.*w>=tol, 1, 'last' ) + 1, length(x)));        % find last point above threshold
    borders(id,:)  = [x1,x2];                                                     % format result
end