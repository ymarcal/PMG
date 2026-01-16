function PARAM = SetParamFormat(PARAM,maxparamlength)
% Ajusta o tamanho maximo dos nomes dos parametros
% e insere / atualiza numeraçao

if iscell(PARAM)
    c = 1;
else
    PARAM = cellstr(PARAM);
    c = 0;
end

PARAM = denumber(PARAM);
for n = 1:length(PARAM)
    PARAM{n} = fliplr(deblank(fliplr(deblank(PARAM{n}))));
    if length(PARAM{n}) > maxparamlength
        uiwait(warndlg({'Parâmetro com excesso de caracteres:',' ', PARAM{n}, ' ',...
                'será renomeado para', ' ', PARAM{n}(1:maxparamlength)},'Aviso','modal'));
        PARAM{n} = PARAM{n}(1:maxparamlength);
    end
end
PARAM = SetParamNumbers(PARAM);

if ~c
    PARAM = char(PARAM);
end

