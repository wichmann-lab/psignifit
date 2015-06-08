function y = my_betapdf(x,a,b)
% this implements the betapdf with less input checks and to work with GPU
% and non GPU inputs correctly
% function y = my_betapdf(x,a,b)

% Initialize y to zero.
y = zeros(size(x));

if numel(a) == 1
    a = repmat(a,size(x));
end

if numel(b) == 1
    b = repmat(b,size(x));
end


% Special cases
y(a==1 & x==0) = b(a==1 & x==0);
y(b==1 & x==1) = a(b==1 & x==1);
y(a<1 & x==0) = Inf;
y(b<1 & x==1) = Inf;

% Return NaN for out of range parameters.
y(a<=0) = NaN;
y(b<=0) = NaN;
y(isnan(a) | isnan(b) | isnan(x)) = NaN;

% Normal values
k = a>0 & b>0 & x>0 & x<1;
a = a(k);
b = b(k);
x = x(k);

% Compute logs
smallx = x<0.1;

loga = (a-1).*log(x);

logb = zeros(size(x));
logb(smallx) = (b(smallx)-1) .* log1p(-x(smallx));
logb(~smallx) = (b(~smallx)-1) .* log(1-x(~smallx));

y(k) = exp(loga+logb - betaln(a,b));
