function [ktype, style, color, width] = splitstyle(stylestr)
% Fornece o tipo de objeto (ponto, linha, area, texto) e
% converte um string de estilo em tres componentes (estilo, cor e espessura)

width = str2double(stylestr(end));
if isnan(width)
    width = 1;
else
    stylestr(end) = [];
end

ix = find(stylestr == '[');

if isempty(ix)
    style = stylestr(1:end-1);
    color = stylestr(end);
else
    style = stylestr(1:ix-1);
    color = str2num(stylestr(ix:end));
end

if any(style(1) == '.ods^p')
    ktype = 'point';
elseif style(1) == 'A'
    ktype = 'area';
elseif style(1) == 'T'
    ktype = 'text';
else
    ktype = 'line';
end
