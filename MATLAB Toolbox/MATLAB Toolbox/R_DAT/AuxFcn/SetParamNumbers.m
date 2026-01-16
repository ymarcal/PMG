function PARAM = SetParamNumbers(PARAM)
% Insere ou atualiza numeraçao em PARAM

if iscell(PARAM)
    c = 1;
else
    PARAM = cellstr(PARAM);
    c = 0;
end

PARAM = denumber(PARAM);
for n = 1:length(PARAM)
    PARAM{n} = [num2str(n,'%02d') '-' PARAM{n}];
end

if ~c
    PARAM = char(PARAM);
end
