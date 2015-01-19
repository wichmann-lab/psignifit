function Cor = getCor(result)
% calculates the correlation matrix accross parameters
%function Cor = getCor(result)
% it uses getCov to get the covariance matrix 
% result should be a result struct which contains the full posterior
% Cor then is the correlation matrix

Cor = getCov(result);
std = sqrt(diag(Cor));
Cor = bsxfun(@rdivide,Cor,std);
Cor = bsxfun(@rdivide,Cor,reshape(std,1,[]));