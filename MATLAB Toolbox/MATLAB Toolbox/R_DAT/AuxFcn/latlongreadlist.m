function M = latlongreadlist(str)
% Funçao que le uma lista de coordenadas nos formatos aceitos pela funçao latlongread.m
% A latitude e a longitude de cada ponto é separada por uma barra (/)
% e os pontos sao separados por espaço, virgula, ponto-e-virgula ou outro caracter neutro
% 
% Sintaxe: M = latlongreadlist(str)
%          str: lista de pontos em string ou cellstring (exemplo: '2259.10S/04553.01W, 2224.48S/04529.44W e 2256.20S/04507.58W')
%          M  : matriz [lat long] em graus
%

M = [];

% Pre-formataçao de str
if iscell(str)
    C = str;
    str = '';
    for n = 1:length(C)
        str = [str ' ' C{n}];
    end
end
if size(str,1) > 1
    C = str;
    str = '';
    for n = 1:size(C,1)
        str = [str ' ' C(n,:)];
    end
end
str = [' ' upper(str) ' '];

% Eliminação de caracteres invalidos
validchars = '-0123456789./ NSEWLO';
invalidchars = setdiff(str,validchars);
for n = 1:length(invalidchars)
    str = strrep(str,invalidchars(n),' ');
end

% Eliminação de espaços contiguos
S = str==' ';
S2 = [0 S(1:end-1)];
str(S&S2) = [];

% Contagem e interpretaçao de celulas
S = find(str==' ');
for n = 1:length(S)-1
    coord = str(S(n)+1:S(n+1)-1);
    while ~isempty(coord) && coord(end) == '.';
        coord(end) = [];
    end
    x = find(coord=='/');
    if length(coord)>=3 && length(x)==1 && x > 1 && x < length(coord)
        [void,lat] = latlongread(coord(1:x-1),1);
        [void,lon] = latlongread(coord(x+1:end),2);
        if ~isempty(lat) && ~isempty(lon)
            M = [M; lat lon];
        end
    end
end
