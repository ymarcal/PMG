function PARAM = MergeParamUnits(PARAM,UNITS)
% Acrescenta ou atualiza unidades à matriz PARAM

PARAM = SplitParamUnits(PARAM);

if ischar(PARAM)
    PARAM = cellstr(PARAM);
    c = 1;
else
    c = 0;
end
if ischar(UNITS)
    UNITS = cellstr(UNITS);
end

if size(PARAM,2) > size(PARAM,1)
    PARAM = PARAM';
end
PARAM = PARAM(:,1);
if size(UNITS,2) > size(UNITS,1)
    UNITS = UNITS';
end
UNITS = UNITS(:,1);

while isempty(deblank(UNITS{end})) && length(UNITS) > length(PARAM)
    UNITS(end) = [];
end

if length(UNITS) ~= length(PARAM)
    uiwait(warndlg({'Tamanho da matriz UNITS incompatível com matriz PARAM.','Unidades serão descartadas.'},'Aviso','modal'));
    return
end
        
UNITS = char(UNITS);
UNITS(~abs(UNITS)) = ' ';
UNITS = cellstr(UNITS);

for n = 1:length(UNITS)
    if ~isempty(UNITS{n})
        UNITS{n}(UNITS{n}=='(') = [];
        UNITS{n}(UNITS{n}==')') = [];
        UNITS{n}(UNITS{n}=='[') = [];
        UNITS{n}(UNITS{n}==']') = [];
        PARAM{n} = [PARAM{n} ' (' UNITS{n} ')'];
    end
end

if c
    PARAM = char(PARAM);
end