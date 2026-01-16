function colpar = findpar(PARAM,param,all,exact,prfx)
% Fornece indices de parametros iniciados com "param" dentro de PARAM
%   Nao é case-sensitive
%   Numeraçao de PARAM é ignorada
%   Espaços a esquerda sao ignorados
%
%   Sintaxe: colpar = findpar(PARAM,param,all,exact,prfx)
%            colpar: vetor de indices
%            PARAM:  lista de parametros (char ou cell)
%            param:  lista de parametros a serem procurados (char ou cell)
%            all:    1: encontra todas as ocorrencias de param     0: encontra apenas a primeira ocorrencia (default)
%            exact:  1: encontra apenas ocorrencias exatas         0: encontra ocorrencias parciais (default)
%            prfx:   1: considera os prefixos de telemetria ":"    0: ignora os prefixos de telemetria (default)

if isempty(param) && ~ischar(param)
    colpar = [];
    return
end
    
switch nargin
    case 2
        all   = 0;
        exact = 0;
        prfx  = 0;
    case 3
        exact = 0;
        prfx  = 0;
    case 4
        prfx  = 0;
end

PARAM = cellstr(lower(PARAM));
param = cellstr(lower(param));
try
    PARAM = denumber(PARAM);
    param = denumber(param);
end

if ~prfx
    for n = 1:length(PARAM)
        prfx = PARAM{n} == ':';
        if any(prfx)
            prfx = find(prfx);
            PARAM{n}(1:prfx(end)) = [];
        end
    end
end

colpar = [];

for n = 1:length(param)
    
    if isempty(param{n})
        colpar2 = [];
    else    
        if exact
            colpar2 = strmatch(param{n},PARAM,'exact');
        else
            colpar2 = strmatch(param{n},PARAM);
        end
    end
    colpar = [colpar; colpar2];
    
end

if ~all && ~isempty(colpar)
    colpar = colpar(1);
end