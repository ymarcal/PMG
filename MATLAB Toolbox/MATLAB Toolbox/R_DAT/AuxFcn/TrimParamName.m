function name = TrimParamName(name,maxparamlength)
% Ajusta o tamanho do nome de um parametro

name = fliplr(deblank(fliplr(deblank(name))));
if length(name) > maxparamlength;
    name = name(1:maxparamlength);
    uiwait(warndlg({['Nome do parâmetro truncado em ' num2str(maxparamlength) ' caracteres:'],['''' name '''']},...
        'Aviso','modal'));
end