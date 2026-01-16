function out = IsTime(param)
% Funçao que informa se "param" é tempo

param = lower(param);
test = [strfind(param,'tempo') strfind(param,'time') strfind(param,'utc') strfind(param,'hora')];
if ~isempty(test)
    out = 1;
else
    out = 0;
end
