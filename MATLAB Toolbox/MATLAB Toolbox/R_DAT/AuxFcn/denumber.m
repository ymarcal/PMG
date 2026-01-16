function PARAM = denumber(PARAM)
% Remove numeraçao de PARAM ou de nome de parametro

if iscell(PARAM)
    c = 1;
else
    PARAM = cellstr(PARAM);
    c = 0;
end

for n = 1:length(PARAM)
    ni = find(PARAM{n}=='-');
    if ~isempty(ni) 
        ni = ni(1);
        if length(PARAM{n}) > ni && ( ni == 1 || ~isempty(str2num(PARAM{n}(1:ni-1))) ) %#ok<ST2NM>
            PARAM{n}(1:ni) = [];
        end
    end
end

if ~c
    PARAM = char(PARAM);
end
