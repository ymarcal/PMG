function [PARAM, UNITS] = SplitParamUnits(PARAM)
% Separa unidades de PARAM
% Sintaxe: [PARAM, UNITS] = SplitParamUnits(PARAM)

if iscell(PARAM)
    c = 1;
else
    PARAM = cellstr(PARAM);
    c = 0;
end

for n = 1:length(PARAM)
    ind = find(PARAM{n} == '(');
    if isempty(ind)
        ind = find(PARAM{n} == '[');   
    end
    if ~isempty(ind)
        UNITS{n,1} = PARAM{n}(ind(end):end);
        PARAM{n} = deblank(PARAM{n}(1:ind(end)-1));
    else
        UNITS{n,1} = '';
    end
end
UNITS = strrep(UNITS,'(','');
UNITS = strrep(UNITS,')','');
UNITS = strrep(UNITS,'[','');
UNITS = strrep(UNITS,']','');

if ~c
    PARAM = char(PARAM);
    UNITS = char(UNITS);
end
