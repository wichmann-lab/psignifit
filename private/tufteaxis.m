function tufteaxis(mmx, mmy)
%TUFTEAXIS changes the coordinate axis in a Tufte style.
%
% inputs:
%   mmx     [min(x), max(x)], the existing XTick are used, OR
%           [min(x), t1, t2, t3, max(x)], use exactly these
%   mmy     [min(y), max(y)], the existing YTick are used, OR
%           [min(y), t1, t2, t3, max(y)], use exactly these
%
% example:
%   xy = randn(100,2);
%   mmx = [min(xy(:,1)), max(xy(:,1))];
%   mmy = [min(xy(:,2)), max(xy(:,2))];
%   scatter(xy(:,1), xy(:,2));
%   tufteaxis(mmx, mmy);
%
% note:
%   the current implementation should be robust against the commands:
%      xlim
%      ylim
%      pbaspect
%      daspect
%
% using tricks from:
%   http://www.mathworks.de/matlabcentral/fileexchange/43905-kozak-scatterplot
%   http://undocumentedmatlab.com/blog/setting-axes-tick-labels-format/
%
% Stefan Harmeling * 2014-02-05

% (0) remove existing tufte axis

%tag = sprintf('%d', gca); % old version working till 2014a
% new version, adding a random tag instead of the handle tag.
tag = get(gca,'Tag');
if strcmp(tag,'')
    tag = sprintf('%d',rand);
else
    set(gca,'Tag','');
    delete(findall(gcf, 'Tag', tag))
    setappdata(gca, 'XLimListener', []);
    setappdata(gca, 'YLimListener', []);
    setappdata(gca, 'PositionListener', []);
    setappdata(gca, 'PlotBoxAspectRatioModeListener', []);
    setappdata(gca, 'PlotBoxAspectRatioListener', []);
    setappdata(gca, 'DataAspectRatioModeListener', []);
    setappdata(gca, 'DataAspectRatioListener', []);
    tag = sprintf('%d',rand);
end
set(gca,'Tag',tag);
% (0a) sort input
mmx = sort(mmx);
mmy = sort(mmy);

% (1) modify the current ticks
if length(mmx) > 2
    XTick = get(gca, 'XTick');                                      % start with the current
    %XTick = mmx;                                                  % take the ticks from mmx
    offx  = (mmx(end)-mmx(1))./10;
    for i = 1:length(mmx)
        % remove to crowded ticks
        XTick(XTick >= mmx(i) - offx & XTick <= mmx(i) + offx) = [];
    end
    XTick(XTick<mmx(1))   = [];
    XTick(XTick>mmx(end)) = [];
    XTick = [XTick,mmx];
    XTick = sort(XTick);
    mmx   = [mmx(1), mmx(end)];
else
    XTick = get(gca, 'XTick');                                      % start with the current
    if length(XTick) > 1
        offx = mean(diff(XTick))/2;
    else
        offx = 0;
    end                                                                % avoid crowded ticks
    XTick(XTick <= mmx(1) + offx) = [];         % remove ticks that are smaller than min+off
    XTick(XTick >= mmx(2) - offx) = [];           % remove ticks that are large than max-off
    XTick = [mmx(1), XTick, mmx(2)];                                       % add min and max
end
if length(mmy) > 2
    XTick = get(gca, 'YTick');                                      % start with the current
    %YTick = mmy;
    offy  = (mmy(end)-mmy(1))./10;
    for i = 1:length(mmy)
        % remove to crowded ticks
        YTick(YTick >= mmy(i) - offy & YTick <= mmy(i) + offy) = [];
    end
    YTick(YTick<mmx(1))   = [];
    YTick(YTick>mmx(end)) = [];
    YTick = [YTick,mmy];
    YTick = sort(YTick);
    mmy   = [mmy(1), mmy(end)];
else
    YTick = get(gca, 'YTick');
    if length(YTick) > 1
        offy = mean(diff(YTick))/2;
    else
        offy = 0;
    end
    YTick(YTick <= mmy(1) + offy) = [];         % remove ticks that are smaller than min+off
    YTick(YTick >= mmy(2) - offy) = [];           % remove ticks that are large than max-off
    YTick = [mmy(1), YTick, mmy(2)];                                       % add min and max
end

% (2) switch off the current axis and add some new white background
switch 1
    case 0
        % for debugging purposes: check whether the new axis align with the original ones
    case 1
        %% IN THIS SETTING ALSO THE WHITE AREA BELOW THE AXIS DISAPPEARS
        axis off                                                           % switch off the axis
    case 2
        %% WARNING THIS CASE LEADS TO GHOSTS IN PRINTOUTS
        box off                                                                         % no box
        grid off                                                                       % no grid
        set(gca, 'XTick', XTick);                                             % change the ticks
        set(gca, 'YTick', YTick);
        set(gca, 'TickDir', 'out'); % the ticks should point out, otherwise we can not hide them
        Color = get(gcf, 'Color');                          % get background color of the figure
        set(gca, 'XColor', Color);                                 % hide the ticks and the axis
        set(gca, 'YColor', Color);
end

% (4) create conversion functions
XLim = get(gca, 'XLim');                                       % get the coordinate system
YLim = get(gca, 'YLim');                                       % get the coordinate system
XLim = [min(mmx(1), XLim(1)), max(mmx(2), XLim(2))];        % increase limits if necessary
YLim = [min(mmy(1), YLim(1)), max(mmy(2), YLim(2))];        % increase limits if necessary
if strcmp(get(gca,'XScale'), 'linear')
    XLim(1) = min(XLim(1), mmx(1) - 0.1*(mmx(2)-mmx(1)));        % to avoid points on the axis
else %logspace
    XLim(1) = min(XLim(1), exp(log(mmx(1)) - 0.1*(log(mmx(2))-log(mmx(1)))));
end
if strcmp(get(gca,'YScale'), 'linear')
    YLim(1) = min(YLim(1), mmy(1) - 0.1*(mmy(2)-mmy(1)));        % to avoid points on the axis
else
    YLim(1) = min(YLim(1), exp(log(mmy(1)) - 0.1*(log(mmy(2))-log(mmy(1)))));
end
set(gca, 'XLim', XLim);
set(gca, 'YLim', YLim);
[left, bottom, width, height] = calcLimits(gca);
if strcmp(get(gca,'XScale'), 'linear')
    tx   = @(x) left   + width  * (x - XLim(1)) / diff(XLim);     % convert to global position
else % logscale
    tx   = @(x) left   + width  * (log(x) - log(XLim(1))) / diff(log(XLim));     % convert to global position
end
if strcmp(get(gca,'YScale'), 'linear')
    ty   = @(y) bottom + height * (y - YLim(1)) / diff(YLim);     % convert to global position
else % logscale
    ty   = @(y) bottom + height * (log(y) - log(YLim(1))) / diff(log(YLim));     % convert to global position
end

% (5) draw new axis
ax   = annotation('line', tx(mmx), bottom*[1,1]);                      % x coordinate axis
ay   = annotation('line', left*[1,1], ty(mmy));                        % y coordinate axis

% (6) draw new ticks
gcfpos      = get(gcf, 'Position');
ticklength  = 7;                                                                % in pixel
xticklength = ticklength / gcfpos(4);             % in pixel / "number of vertical pixels"
yticklength = ticklength / gcfpos(3);           % in pixel / "number of horizontal pixels"
nXTick      = length(XTick);
ttx         = zeros(nXTick, 1);                                           % to store ticks
tlx         = zeros(nXTick, 1);                                          % to store labels
for i = 1:nXTick
    ttx(i) = annotation('line', tx(XTick(i)*[1,1]), bottom-[0, xticklength]);
    tlx(i) = annotation('textbox', [tx(XTick(i)), bottom-xticklength, 0, 0], ...
        'string', num2str(XTick(i),'%.3g'), ...
        'VerticalAlignment', 'top', ...
        'HorizontalAlignment', 'center', ...
        'EdgeColor', 'none',...
        'FontSize',get(gca,'FontSize'));
end
nYTick = length(YTick);
tty    = zeros(nYTick, 1);                                                % to store ticks
tly    = zeros(nYTick, 1);                                               % to store labels
for i = 1:length(YTick)
    tty(i) = annotation('line', left-[0, yticklength], ty(YTick(i)*[1,1]));
    tly(i) = annotation('textbox', [left-yticklength, ty(YTick(i)), 0, 0], ...
        'string', num2str(YTick(i),'%.3g'), ...
        'VerticalAlignment', 'middle', ...
        'HorizontalAlignment', 'right', ...
        'EdgeColor', 'none',...
        'FontSize',get(gca,'FontSize'));
end
for h = [ax; ttx(:); tlx(:); ay; tty(:); tly(:)]'
    set(h, 'Tag', tag);   % mark the annotations to find them on our next
    % call using axis specific tag should make
    % this compatible with SUBPLOT
end

% (7) and now some magic tricks (to auto update the axis after
% changing parameters via XLIM, YLIM, DASPECT, PBASPECT)
hhAxes    = handle(gca);                        % gca is the Matlab handle of our axes

hProp     = findprop(hhAxes,'XLim');                                % a schema.prop object
hListener = handle.listener(hhAxes, hProp, 'PropertyPostSet', @updateAxis);
setappdata(gca, 'XLimListener', hListener);
hProp     = findprop(hhAxes,'YLim');                                % a schema.prop object
hListener = handle.listener(hhAxes, hProp, 'PropertyPostSet', @updateAxis);
setappdata(gca, 'YLimListener', hListener);
hProp     = findprop(hhAxes,'Position');                            % a schema.prop object
hListener = handle.listener(hhAxes, hProp, 'PropertyPostSet', @updateAxis);
setappdata(gca, 'PositionListener', hListener);
hProp      = findprop(hhAxes,'PlotBoxAspectRatioMode');             % a schema.prop object
hListener = handle.listener(hhAxes, hProp, 'PropertyPostSet', @updateAxis);
setappdata(gca, 'PlotBoxAspectRatioModeListener', hListener);
hProp      = findprop(hhAxes,'PlotBoxAspectRatio');                 % a schema.prop object
hListener = handle.listener(hhAxes, hProp, 'PropertyPostSet', @updateAxis);
setappdata(gca, 'PlotBoxAspectRatioListener', hListener);
hProp      = findprop(hhAxes,'DataAspectRatioMode');                % a schema.prop object
hListener = handle.listener(hhAxes, hProp, 'PropertyPostSet', @updateAxis);
setappdata(gca, 'DataAspectRatioModeListener', hListener);
hProp      = findprop(hhAxes,'DataAspectRatio');                    % a schema.prop object
hListener = handle.listener(hhAxes, hProp, 'PropertyPostSet', @updateAxis);
setappdata(gca, 'DataAspectRatioListener', hListener);

% (8) helper functions

    function [left, bottom, width, height] = calcLimits(axisHandle)
        % calculate the correct positions of the axes depending on
        % 'Position'
        % 'PlotBoxAspectRatioMode', 'PlotBoxAspectRatio'
        % 'DataAspectRatioMode', 'DataAspectRatio'
        % 'CameraViewAngleMode', 'CameraViewAngle'
        OrigUnits = get(gcf, 'Units');
        set(gcf, 'Units', 'pixels');
        fpos      = get(gcf, 'Position');                        % left, bottom, width, height
        factor    = fpos(3)/fpos(4);                          % ratio between width and height
        set(gcf, 'Units', OrigUnits);
        pos       = get(axisHandle, 'Position');
        left = pos(1); bottom = pos(2); width = pos(3); height = pos(4);
        if strcmp(get(gca, 'PlotBoxAspectRatioMode'), 'manual') || strcmp(get(gca, 'DataAspectRatioMode'), 'manual')
            % PlotBoxAspectRatio influences the exact position
            % curiously for DataAspectRatioMode the following also works
            pbar = pbaspect();
            pbar12 = pbar(1)/pbar(2)/factor;
            wh     = width/height;
            if pbar12 < wh
                % adjust left and width
                widthnew = height * pbar12;
                left     = left + width/2 - widthnew/2;
                width    = widthnew;
            elseif pbar12 > wh
                % adjust bottom and height
                heightnew = width / pbar12;
                bottom    = bottom + height/2 - heightnew/2;
                height    = heightnew;
            end
        end
        if strcmp(get(gca, 'CameraViewAngleMode'), 'manual')
            error('manual CameraViewAngleMode not support yet')
        end
    end


    function updateAxis(hProp,eventData)
        XLim = get(eventData.AffectedObject, 'XLim');                                   % get the coordinate system
        YLim = get(eventData.AffectedObject, 'YLim');                                   % get the coordinate system
        [left, bottom, width, height] = calcLimits(eventData.AffectedObject);
        if strcmp(get(eventData.AffectedObject,'XScale'), 'linear')
            tx   = @(x) left   + width  * (x - XLim(1)) / diff(XLim);     % convert to global position
        else % logscale
            tx   = @(x) left   + width  * (log(x) - log(XLim(1))) / diff(log(XLim));     % convert to global position
        end
        if strcmp(get(eventData.AffectedObject,'YScale'), 'linear')
            ty   = @(y) bottom + height * (y - YLim(1)) / diff(YLim);     % convert to global position
        else % logscale
            ty   = @(y) bottom + height * (log(y) - log(YLim(1))) / diff(log(YLim));     % convert to global position
        end
        set(ax, 'X', max(min(tx(mmx), left+width), left));
        set(ax, 'Y', bottom*[1,1]);
        for i = 1:nXTick
            XTicki = XTick(i);
            if XTicki < XLim(1) || XLim(2) < XTicki
                set(ttx(i), 'Visible', 'off');
                set(tlx(i), 'Visible', 'off');
            else
                set(ttx(i), 'Visible', 'on');
                set(tlx(i), 'Visible', 'on');
                thex = tx(XTicki);
                set(ttx(i), 'X', thex*[1,1]);
                set(ttx(i), 'Y', bottom-[0,xticklength]);
                tlxPos = get(tlx(i), 'Position');
                tlxPos(1) = thex;
                tlxPos(2) = bottom-xticklength;
                set(tlx(i), 'Position', tlxPos);
            end
        end
        set(ay, 'X', left*[1,1]);
        set(ay, 'Y', max(min(ty(mmy), bottom+height), bottom));
        for i = 1:nYTick
            YTicki = YTick(i);
            if YTicki < YLim(1) || YLim(2) < YTicki
                set(tty(i), 'Visible', 'off');
                set(tly(i), 'Visible', 'off');
            else
                set(tty(i), 'Visible', 'on');
                set(tly(i), 'Visible', 'on');
                they = ty(YTicki);
                set(tty(i), 'X', left-[0,yticklength]);
                set(tty(i), 'Y', they*[1,1]);
                tlyPos = get(tly(i), 'Position');
                tlyPos(1) = left-yticklength;
                tlyPos(2) = they;
                set(tly(i), 'Position', tlyPos);
            end
        end
    end
end
