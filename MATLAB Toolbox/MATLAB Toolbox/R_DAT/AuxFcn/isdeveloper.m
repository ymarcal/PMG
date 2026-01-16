function res = isdeveloper
% Indica se o programa esta sendo executado por um desenvolvedor

if strcmpi(getuser,'leonardomfl') || strcmpi(getuser,'leonardolmfl')
    res = true;
else
    res = false;
end