function plotBayes(result,plotOptions)
% this function creates the plot with the bayesian Posterior distributions
%function plotBayes(result,plotOptions)
% displayed are two dimensional marginal distributions of each parameter
% against each other parameter
% You may then enlarge each panel by clicking on it.

if ~exist('plotOptions','var')       , plotOptions          = struct;      end
if ~isfield('plotOptions','colorMap'), plotOptions.colorMap = getColormap; end

mainPlot(result,plotOptions);
end

function mainPlot(result,plotOptions)
clf;
colormap(plotOptions.colorMap);

if strcmp(result.options.expType,'equalAsymptote')
    result.X1D{4}=0;
end

% outer loop over the subplots
for i = 1:4
    for j = (i+1):5
        subplot(4,4,4*(i-1)+j-1)
        % marginalize
        marg = squeeze(marginalize(result,[i,j]));
        if isvector(marg) % one dimensional results require special treatment to rotate them correctly
            marg = reshape(marg,[],1);  % because row vectors are not squeezed to cols
            if length(result.X1D{i})~=1 % if the singleton dimension is i
                imagesc(result.X1D{j},result.X1D{i},marg);
            else % else transpose
                imagesc(result.X1D{j},result.X1D{i},marg');
            end
        else
            imagesc(result.X1D{j},result.X1D{i},marg);
        end
        % view options
        
        % axis labels
        switch i
            case 1
                ylabel('threshold');
            case 2
                ylabel('width');
            case 3
                ylabel('\lambda');
            case 4
                ylabel('\gamma');
        end
        switch j
            case 1
                xlabel('threshold');
            case 2
                xlabel('width');
            case 3
                xlabel('\lambda');
            case 4
                xlabel('\gamma');
            case 5
                xlabel('\eta');
        end
        
        handle = {@(~,~,result,plotOptions)onePlot(result,i,j,plotOptions),result,plotOptions};
        image  = get(gca,'Children');
        for ichild = 1:length(image) % in case of multiple plots
            set(image(ichild),'ButtonDownFcn',handle);
        end
    end
end
end

function onePlot(result,i,j,plotOptions)
clf;
colormap(plotOptions.colorMap);
marg = squeeze(marginalize(result,[i,j]));
if isvector(marg)
    if length(result.X1D{i})==1
        plotMarginal(result,j);
    else
        plotMarginal(result,i);
    end
else
    imagesc(result.X1D{j},result.X1D{i},marg)
    
    switch i
        case 1
            ylabel('threshold','FontSize',14);
        case 2
            ylabel('width','FontSize',14);
        case 3
            ylabel('\lambda','FontSize',14);
        case 4
            ylabel('\gamma','FontSize',14);
    end
    switch j
        case 1
            xlabel('threshold','FontSize',14);
        case 2
            xlabel('width','FontSize',14);
        case 3
            xlabel('\lambda','FontSize',14);
        case 4
            xlabel('\gamma','FontSize',14);
        case 5
            xlabel('\eta','FontSize',14);
    end
end
% if clicked go back to main display
handle = {@(~,~,result,plotOptions)mainPlot(result,plotOptions),result,plotOptions};
image  = get(gca,'Children');
set(gca,'ButtonDownFcn',handle);
for i = 1:length(image) % in case of multiple plots
    set(image(i),'ButtonDownFcn',handle);
end
end

