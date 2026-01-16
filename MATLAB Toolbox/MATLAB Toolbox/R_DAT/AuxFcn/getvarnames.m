function [invars, outvars] = getvarnames(fname)
% Fornece os nomes das variaveis de entrada e saida de uma funçao

if nargin == 0
    fname = 'getvarnames.m';
end

[fpath,fname0,fext] = fileparts(fname);
if ~isempty(fpath)
    fpath = [fpath filesep];
end
if isempty(fext)
    fext = '.m';
end
fname = [fpath fname0 fext];

if exist(fname,'file') ~= 2
    invars  = {};
    outvars = {};
    return
end

fid = fopen(fname);
D = char(fread(fid)');
fclose(fid);

D = [char(10) D char(13)];
i_nl = find(D==char(10));
i_rt = find(D==char(13));

for n = 1:min([length(i_nl) length(i_rt)])
    
    line = D(i_nl(n)+1:i_rt(n)-1);
    line(line==' ') = [];
    
    if ~isempty(line) && line(1) == char(10)
        line(1) = [];
    end
    if strfind(line,'function') == 1
        D(i_rt(n):end) = [];
        break
    end
    
end

if isempty(line)
    invars  = {};
    outvars = {};
    return
end

i_p = sort([find(line==')') find(line==char(13)) find(line==char(10))]);
i_e = find(line=='=');

if isempty(i_p) || isempty(i_e)
    invars  = {};
    outvars = {};
    return
end

fstr = line(1:i_p(1)-1);

fstr(fstr==' ') = ',';
fstr(fstr=='[') = [];
fstr(fstr==']') = [];
fstr(fstr=='(') = [];
fstr(fstr==')') = [];
fstr = strrep(fstr,'function','');
fstr = strrep(fstr,fname0,'');

while ~isempty(strfind(fstr,',,'))
    fstr = strrep(fstr,',,',',');
end

i_e = find(fstr == '=');

instr  = fstr(i_e+1:end);
outstr = fstr(1:i_e-1);

if isempty(strrep(instr,',',''))
    invars = {};
else
    if instr(end) ~= ','
        instr = [instr ','];
    end
    if instr(1) ~= ','
        instr = [',' instr];
    end
    
    ic = find(instr == ',');
    for n = 1:length(ic)-1
        invars{n} = instr(ic(n)+1:ic(n+1)-1);
    end
end

if isempty(strrep(outstr,',',''))
    outvars = {};
else
    if outstr(end) ~= ','
        outstr = [outstr ','];
    end
    if outstr(1) ~= ','
        outstr = [',' outstr];
    end
    
    ic = find(outstr == ',');
    for n = 1:length(ic)-1
        outvars{n} = outstr(ic(n)+1:ic(n+1)-1);
    end
end