function PARAM = InsertParam(PARAM,name)
% Acrescenta um nome de parametro
% PARAM ja tem que estar numerada
% O nome deve ser ajustado primeiro

if iscell(PARAM)
    c = 1;
else
    PARAM = cellstr(PARAM);
    c = 0;
end

n = length(PARAM);
PARAM{n+1} = [num2str(n+1,'%02d') '-' denumber(PARAM{n})]; % Move 'No. OBS.' para baixo
PARAM{n}   = [num2str(n  ,'%02d') '-' name];               % Insere o novo parametro

if ~c
    PARAM = char(PARAM);
end
