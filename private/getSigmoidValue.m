function pfun=getSigmoidValue(X,sigmoid,m,width)
% this gets the value of a given sigmoid with parameters:
% 1: alpha
% 2: beta
% 

if isa(sigmoid,'function_handle')
    sigmoidHandle = sigmoid;
elseif ischar(sigmoid)
    sigmoidHandle = getSigmoidHandle(sigmoid);
else 
    error('sigmoid of invalid type specified')
end

pfun = sigmoidHandle(X,m,width);
