function MAP = getColormap()
% returns our standard Tuebingen Colormap
%function getColormap()
    
%midBlue   = [0  105 170]./255;
midBlue   = [165 30  55]./255;
%lightBlue = [80 170 200]./255;
%lightBlue = [125 165 75]./255;
lightBlue = [210 150  0]./255;

steps     = linspace(0,1,100)';

%MAP       = bsxfun(@times,steps,midBlue);
MAP       = [];
MAP       = [MAP; bsxfun(@times,steps,lightBlue)+bsxfun(@times,1-steps,midBlue)];
MAP       = [MAP; bsxfun(@times,steps,[1,1,1])+bsxfun(@times,1-steps,lightBlue)];

end