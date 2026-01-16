function isw = iswrite(fpath)
% Indica se uma pasta tem acesso de gravaçao

if isempty(fpath) || ~exist(fpath,'dir')
    isw = 0;
    return
end

if fpath(end) ~= '\'
    fpath = [fpath '\'];
end

tmp = 1;
try
    save([fpath 'tmp.mat'],'tmp');
    delete([fpath 'tmp.mat']);
    isw = 1;
catch
    isw = 0;
end