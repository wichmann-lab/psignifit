function Cov = getCov(result)
% this function calculates the covariance matrix
%function Cov = getCov(result)
% result should be a standard result struct which contains the whole
% posterior
% the function then returns the covariance matrix of the posterior believe
% about the parameters
% If result has a precalculated covariance matrix it is returned instead of
% a newly calculated one

if isfield(result,'Cov')
    Cov = result.Cov;
else
    Cov = nan(5,5);
    
    for i = 1:5
        for j = 1:5
            if j < i
                Cov(i,j) = Cov(j,i);
            else
                switch i
                    case 1, x = reshape(result.X1D{i}   ,[],1);
                    case 2, x = reshape(result.X1D{i}   ,1,[]);
                    case 3, x = reshape(result.X1D{i}   ,1,1,[]);
                    case 4, x = reshape(result.X1D{i}   ,1,1,1,[]);
                    case 5, x = reshape(result.X1D{i}   ,1,1,1,1,[]);
                end
                switch j
                    case 1, y = reshape(result.X1D{j}   ,[],1);
                    case 2, y = reshape(result.X1D{j}   ,1,[]);
                    case 3, y = reshape(result.X1D{j}   ,1,1,[]);
                    case 4, y = reshape(result.X1D{j}   ,1,1,1,[]);
                    case 5, y = reshape(result.X1D{j}   ,1,1,1,1,[]);
                end
                if length(x) == 1 || length(y)==1
                    Cov(i,j) = 0;
                else
                    [marginal,~,weight] = marginalize(result,[i,j]);
                    Mass     = marginal .*weight;
                    Exy      = sum(sum(bsxfun(@times,bsxfun(@times,Mass,x),y),i),j);
                    Ex       = sum(sum(bsxfun(@times,Mass,x),i),j);
                    Ey       = sum(sum(bsxfun(@times,Mass,y),j),i);
                    Cov(i,j) = Exy-Ex*Ey;
                end
            end
        end
    end
end