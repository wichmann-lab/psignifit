function [conf_Intervals, confRegion]=getConfRegion(result)
% get confidence intervals and region for parameters
% function [conf_Intervals, confRegion]=getConfRegion(result)
% This function returns the conf_intervals for all parameters and a
% confidence region on the whole parameter space.
%
% Useage
% pass the result obtained from psignifit
% additionally in confP the confidence/ the p-value for the interval is required
% finally you can specify in CImethod how to compute the intervals
%       'project' -> project the confidence region down each axis
%       'stripes' -> find a threshold with (1-alpha) above it
%   'percentiles' -> find alpha/2 and 1-alpha/2 percentiles
%                    (alpha = 1-confP)
%
% confP may also be a vector of confidence levels. The returned CIs
% are a 5x2xN array then containting the confidence intervals at the different
% confidence levels. (any shape of confP will be interpreted as a vector)


mode = result.options.CImethod;
d    = length(result.X1D);

%% get confIntervals for each paramerter-> marginalize

conf_Intervals=zeros(d,2,numel(result.options.confP));

for iConfP = 1:numel(result.options.confP)
    
    if nargout > 1 || strcmp(mode,'project')
        [~,order]  = sort(result.Posterior(:),'descend');
        
        Mass       = result.Posterior.*result.weight;
        Mass       = cumsum(Mass(order));
        
        confRegion = true(size(result.Posterior));
        confRegion(order(Mass>=result.options.confP(iConfP))) = false;
    end
    switch mode
        case 'project'
            for id=1:d
                confRegionM = confRegion;
                for id2=1:d
                    if id~=id2
                        confRegionM = any(confRegionM,id2);
                    end
                end
                start  = result.X1D{id}(find(confRegionM,1,'first'));
                stop   = result.X1D{id}(find(confRegionM,1,'last'));
                conf_Intervals(id,:,iConfP) = [start,stop];
            end
        case 'stripes'
            for id=1:d
                [margin,x,weight1D] = marginalize(result,id);
                [~,order] = sort(margin,'descend');
                
                Mass = margin.*weight1D;
                MassSort = cumsum(Mass(order));
                % find smallest possible percentage above confP
                confP1      = min(MassSort(MassSort>result.options.confP(iConfP)));
                confRegionM = true(size(margin));
                confRegionM(order(MassSort>confP1))=false;
                
                % Now we have the confidence regions
                % put the borders between the nearest contained and the first
                % not contained point
                
                % we move in from the outer points to collect the half of the
                % leftover confidence from each side
                
                startIndex=find(confRegionM,1,'first');
                pleft = confP1-result.options.confP(iConfP);
                if startIndex>1,
                    start = (x(startIndex)+x(startIndex-1))/2;
                    start = start + pleft/2/margin(startIndex);
                else
                    start = x(startIndex);
                    pleft = pleft*2; % move stop twice as far to account for the whole probability left
                end
                stopIndex=find(confRegionM,1,'last');
                if stopIndex < length(x)
                    stop = (x(stopIndex)+x(stopIndex+1))/2;
                    stop = stop - pleft/2/margin(stopIndex);
                else
                    stop = x(stopIndex);
                    if startIndex > 1;
                        start = start + pleft/2/margin(startIndex); % move start a second step
                    end
                end
                
                conf_Intervals(id,:,iConfP)=[start,stop];
            end
        case 'percentiles'
            for id=1:d
                [margin,x,weight1D]=marginalize(result,id); % marginalize
                if length(x)==1 % catch when a dimension was fixed
                    start=x;
                    stop=x;
                else
                    Mass    = margin.*weight1D;                   % probability Mass for each point
                    cumMass = cumsum(Mass);                       % cumulated p-Mass
                    
                    % in the intervall are all points between the alpha and the
                    % 1-alpha percentile.-> where alpha<cumMass<(1-alpha)
                    confRegionM = cumMass > ((1-result.options.confP(iConfP))/2) & cumMass < (1-(1-result.options.confP(iConfP))/2);
                    
                    if any(confRegionM)
                        % Now we have the confidence regions
                        % put the borders between the nearest contained and the first
                        % not contained point
                        alpha       = (1-result.options.confP(iConfP))/2;
                        startIndex  = find(confRegionM,1,'first');
                        if startIndex > 1
                            start = (x(startIndex-1)+x(startIndex))/2 +(alpha-cumMass(startIndex-1))/margin(startIndex);
                        else
                            start = x(startIndex)+ alpha/margin(startIndex);
                        end
                        
                        stopIndex=find(confRegionM,1,'last');
                        if stopIndex < length(x)
                            stop  = (x(stopIndex)+x(stopIndex+1))/2 + (1-alpha-cumMass(stopIndex))/margin(stopIndex+1);
                        else
                            stop = x(stopIndex)-alpha/margin(stopIndex); % this actually cannot happen because cumMass(end) ==1 > (1-(1-result.options.confP)/2) -> End is never in confRegionM
                        end
                    else
                        idx = find(cumMass >((1-result.options.confP(iConfP))/2), 1,'first');
                        MMid = cumMass(idx)-Mass(idx)/2; % middle of the bar which contains both start and stop
                        start = x(idx)+ ((1-result.options.confP(iConfP))/2-MMid)/margin(idx);
                        stop = x(idx)+ ((1-(1-result.options.confP(iConfP))/2)-MMid)/margin(idx);
                    end
                end
                
                conf_Intervals(id,:,iConfP)=[start,stop];
            end
        otherwise
            error('You specified an invalid mode')
    end
end
