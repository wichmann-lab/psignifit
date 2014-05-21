function weight=getWeights(X1D)
% creates the weights for quadrature / numerical integration
%function weight=getWeights(X1D)
% this function calculates the weights for integration/the volume of the
% cuboids given by the 1 dimensional borders in X1D

d=length(X1D);

% puts the X values in their respective dimensions to use bsxfun for
% evaluation
            Xreshape{1}=reshape(X1D{1},[],1);
if  d>=2,   Xreshape{2}=reshape(X1D{2},1,[]);                             end
for id=3:d, Xreshape{id}=reshape(X1D{id},[ones(1,id-1),length(X1D{id})]); end

% to find and handle singleton dimensions
for id=1:d  Xlength(id)=length(X1D{id}); end

%calculate weights
% 1) calculate mass/volume for each cuboid
weight=1;
for id=1:d
    if Xlength(id)>1
        weight=bsxfun(@(x,y) x.*y,weight,diff(Xreshape{id}));
    end
end
% 2) sum to get weight for each point
% convolution seems to be the way
if d>1
    % to handle singleton dimensions correctly: 
    dims=repmat(2,[1,d]);
    dims(Xlength==1)=1;
    d=sum(Xlength>1);
    weight=2^(-d).*convn(weight,ones(dims)); % sum neighboring cuboids
else
    weight=2^(-1).*conv(weight,[1;1]);
end