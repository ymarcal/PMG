function strwrite(fname,str,conf)
% Writes a character matrix or cell into an ASCII text file
% Syntax:   strwrite(fname,str,conf)

if nargin == 2
    conf = 1;
end

switch class(str)
    case 'char'
        
        S = abs(str)';
        S = [S; 13*ones(1,size(S,2)); 10*ones(1,size(S,2))];
        S = S(:);
        
    case 'cell'
        
        S = [];
        [N,M] = size(str);
        for n = 1:N
            for m = 1:M
                if size(str{n,m},1) > 1
                    str{n,m} = str{n,m}';
                end
                S = [S; abs(str{n,m}(:)); 13; 10];
            end
        end
        S(end-1:end) = [];
        
    otherwise
        
        error('Invalid input class');
end

if conf && exist(fname,'file')
    btn = questdlg({[fname ' already exists.'],'Do you wish to replace it?'},'Save file:','Yes','No','No');
else
    btn = 'Yes';
end

if strcmp(btn,'Yes')
    fid = fopen(fname,'w');
    fwrite(fid,S);
    fclose(fid);
end