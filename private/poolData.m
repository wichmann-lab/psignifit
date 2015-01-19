function pooledData = poolData(data,options)
% pools the data 
%function data = poolData(data, options)
% data must be a nx3 matrix of the form [stim.Level|#correct|#total]
%
% This function will pool trials together which differ at maximum poolxTol
% from the first one it finds, are separated by maximally poolMaxGap
% trials of other levels and at max poolMaxLength trials appart in general.

                         
counted = false(size(data,1),1);        % which elements we already counted
gap     = options.poolMaxGap;           % max gap between two trials of a block
maxL    = options.poolMaxLength;        % maximal blocklength 
xTol    = options.poolxTol;             % maximal difference to elements pooled in a block
cTrialN = [0;cumsum(data(:,3))];        % cumulated number of trials with leading 0
if size(data,2) == 4
    cTrialN = data(:,4);
end

i       = 1;                            % where we currently count
pooledData =[];

while i <= size(data,1)
    if counted(i)
        % do nothing
    else
        curLevel     = data(i,1);           % current stimulus level
        block        = [];                  % the data to be pooled in this block
        j            = i;                   % index running from current position
        GapViolation = false;               % gap larger than allowed detected
        curGap       = 0;                   % current length of a gap
        while (j<= size(data,1) && cTrialN(j+1)-cTrialN(i) <= maxL && ~GapViolation) || j==i  % while there might be additional trials to add to this block
            if abs(data(j,1)-curLevel)<=xTol && ~counted(j) % if line is added to block
                counted(j) = 1;                     % line was just counted
                block      = [block;data(j,:)];     % add to block data
                curGap     = 0;                     % this was an added trial -> reset gap
            else 
                curGap     = curGap + data(j,3);    % if its not of the current level increase gap
            end
            if curGap > gap                         % detect gap violations
                GapViolation = true;
            end
            j = j+1;
        end
        ntotal   = sum(block(:,3));                     % sum # of trials 
        ncorrect = sum(block(:,2));                     % sum # of correct trials
        level    = sum(block(:,1).*block(:,3))/ntotal;  % take weighted sum of stimulus levels;
        pooledData = [pooledData;level,ncorrect,ntotal];% append to result
    end
    i = i+1;
end