function [DADOS, PARAM] = InsertNOBS(DADOS,PARAM)
% Acrescenta a coluna No. OBS.
% PARAM ja tem que estar numerada

if iscell(PARAM)
    c = 1;
else
    PARAM = cellstr(PARAM);
    c = 0;
end

N = length(PARAM);

if isempty(strfind(PARAM{N},'No. OBS.'))
    DADOS(:,N+1) = (1:size(DADOS,1))';
    PARAM{N+1} = [num2str(N+1,'%02d') '-No. OBS.'];
end

if ~c
    PARAM = char(PARAM);
end
