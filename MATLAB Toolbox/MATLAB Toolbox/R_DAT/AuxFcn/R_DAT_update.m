function result = R_DAT_update(vername)
% Atualiza arquivos individuais do R_DAT a partir da pasta de rede
% Necessita privilegios de administrador

if nargin == 0
    vername = '';
end

result   = 0;
updtfile = 'fileupdt.inf';
verfile  = 'lastver.inf';
rdatpath = getpath('r_dat.m');

if ~exist(rdatpath,'file')
    return
end
if isdeveloper
    return
end
if ~exist([netpath verfile],'file')
    return
end

fid = fopen([netpath verfile]);
lastver = char(fread(fid)');
fclose(fid);

vername(vername=='-') = '_';
lastver(lastver=='-') = '_';
fullnetpath = [netpath lastver '\R_DAT\'];

if ~strcmpi(lastver,vername)
     return
end
if ~exist([fullnetpath 'R_DAT.m'],'file')
    return
end
if ~exist(netpath,'file')
    return
end
if ~exist([netpath updtfile],'file')
    return
end

fid = fopen([netpath updtfile]);
fname = fgetl(fid);

while ischar(fname)
    
    if exist([fullnetpath fname],'file')
        
        netfdata = dir([fullnetpath fname]);
        
        if exist([rdatpath fname],'file')
            localfdata = dir([rdatpath fname]);
        else
            localfdata.date = '00000000000000000';
        end
        
        if ~strcmp(netfdata.date(1:17),localfdata.date(1:17))
            
            if iswrite(getpath([rdatpath fname]))
                
                dos(['copy /Y ' '"' fullnetpath fname, '" "' rdatpath fname '"']);
                
                if result == 0
                    result = 1;
                end
                if strcmpi(fname,'R_DAT.m')
                    result = 2;
                end
                
            end
        end
    end
    
    fname = fgetl(fid);
end

fclose(fid);

% --------------------------------------------------------------
function fpath = getpath(fname)
% Fornece a pasta em que se encontra um arquivo

if isempty(fname)
    fpath = [];
    return
end

fpath = which(fname);
if ~isempty(fpath)
    fs = find(fpath=='\');
    fpath = fpath(1:fs(end));
else
    fs = find(fname=='\');
    if ~isempty(fs)
        fpath = fname(1:fs(end));
    else
        fpath = [];
    end
end

% --------------------------------------------------------------
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
