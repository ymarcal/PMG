function S = cell2str(C,p,s,d,a)
% Converts a cell array with numbers and text into a char array
%  S = cell2str(C,p,s,d)
%    p: precision or number format string [default: 6]
%    s: number of separating blanks  [default: 2]
%    d: aditional delimiter (string)
%    a: column alignment (0=left, 1=right) [default: 0]

if isempty(C)
    S = '';
    return
end

switch nargin
    case 1
        p = 6;
        s = 2;
        d = '';
        a = 0;
    case 2
        s = 2;
        d = '';
        a = 0;
    case 3
        d = '';
        a = 0;
    case 4    
        a = 0;
end

[N, M] = size(C);

if ~iscell(C)
    C = num2cell(C);
end

for m = 1:M
    for n = 1:N
        if isempty(C{n,m})
            C{n,m} = ' ';
        elseif isnumeric(C{n,m})
            C{n,m} = num2str(C{n,m},p);
        end
        if m ~= M
            C{n,m} = [C{n,m} d];
        end
    end
end

S = [];

for m = 1:M
    col = char(C{:,m});
    if a
        col = flipblanks(col);
    end
    if m > 1
        col = [char(32*ones(N,s)) col];
    end
    S   = [S col];
end

% ------------------------------------------------
function str = flipblanks(str)
% Alinhamento a direita

if isempty(str)
    return
end

for n = 1:size(str,1)
    if str(n,1) ~= ' ' && str(n,end) == ' '
        while str(n,end) == ' '
            str(n,:) = [' ' str(n,1:end-1)];
        end
    end
end