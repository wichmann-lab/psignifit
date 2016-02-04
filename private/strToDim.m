function dim = strToDim(str)
% function dim = strToDim(str)
% Finds the number corresponding to a dim/parameter given as a string. 

switch lower(str)
    case {'threshold','thresh','m','t','alpha'}
        dim = 1;
    case {'width','w','beta'}
        dim = 2;
    case {'lapse','lambda','lapserate','lapse rate','lapse-rate','upper asymptote','l'}
        dim = 3;
    case {'gamma','guess','guessrate','guess rate','guess-rate','lower asymptote','g'}
        dim = 4;
    case {'sigma','std','s','eta','e'} % for backward compatibility this allows sigma as a name still
        dim = 5;
end