function copydir(source,destination)
% Copia um diretorio arquivo-por-arquivo, para evitar bug do xcopy
% A estrutura so pode ter 5 niveis de pastas

if nargin ~= 2
    error('Número incorreto de argumentos.');
end

if source(end) ~= '\'
    source = [source '\'];
end
if destination(end) ~= '\'
    destination = [destination '\'];
end

if ~exist(source,'dir')
    error('Pasta não encontrada. Nenhum arquivo copiado.');
end

FNAMES = {source};
DNAMES = {destination};
ISPATH = 1;

[levelnames{1}, leveldir{1}] = getdirlist(source);
N1 = length(levelnames{1});

for n1 = 1:N1
    FNAMES{end+1,1} = [source      levelnames{1}{n1}];
    DNAMES{end+1,1} = [destination levelnames{1}{n1}];
    ISPATH(end+1,1) = leveldir{1}(n1);
    if leveldir{1}(n1)
        FNAMES{end,1} = [FNAMES{end,1} '\'];
        DNAMES{end,1} = [DNAMES{end,1} '\'];
        [levelnames{2}, leveldir{2}] = getdirlist(FNAMES{end});
        N2 = length(levelnames{2});
        for n2 = 1:N2
            FNAMES{end+1,1} = [source      levelnames{1}{n1} '\' levelnames{2}{n2}];
            DNAMES{end+1,1} = [destination levelnames{1}{n1} '\' levelnames{2}{n2}];
            ISPATH(end+1,1) = leveldir{2}(n2);
            if leveldir{2}(n2)
                FNAMES{end,1} = [FNAMES{end,1} '\'];
                DNAMES{end,1} = [DNAMES{end,1} '\'];
                [levelnames{3}, leveldir{3}] = getdirlist(FNAMES{end});
                N3 = length(levelnames{3});
                for n3 = 1:N3
                    FNAMES{end+1,1} = [source      levelnames{1}{n1} '\' levelnames{2}{n2} '\' levelnames{3}{n3}];
                    DNAMES{end+1,1} = [destination levelnames{1}{n1} '\' levelnames{2}{n2} '\' levelnames{3}{n3}];
                    ISPATH(end+1,1) = leveldir{3}(n3);
                    if leveldir{3}(n3)
                        FNAMES{end,1} = [FNAMES{end,1} '\'];
                        DNAMES{end,1} = [DNAMES{end,1} '\'];
                        [levelnames{4}, leveldir{4}] = getdirlist(FNAMES{end});
                        N4 = length(levelnames{4});
                        for n4 = 1:N4
                            FNAMES{end+1,1} = [source      levelnames{1}{n1} '\' levelnames{2}{n2} '\' levelnames{3}{n3} '\' levelnames{4}{n4}];
                            DNAMES{end+1,1} = [destination levelnames{1}{n1} '\' levelnames{2}{n2} '\' levelnames{3}{n3} '\' levelnames{4}{n4}];
                            ISPATH(end+1,1) = leveldir{4}(n4);
                            
                            if leveldir{4}(n4)
                                FNAMES{end,1} = [FNAMES{end,1} '\'];
                                DNAMES{end,1} = [DNAMES{end,1} '\'];
                                [levelnames{5}, leveldir{5}] = getdirlist(FNAMES{end});
                                N5 = length(levelnames{5});
                                for n5 = 1:N5
                                    FNAMES{end+1,1} = [source      levelnames{1}{n1} '\' levelnames{2}{n2} '\' levelnames{3}{n3} '\' levelnames{4}{n4} '\' levelnames{5}{n5}];
                                    DNAMES{end+1,1} = [destination levelnames{1}{n1} '\' levelnames{2}{n2} '\' levelnames{3}{n3} '\' levelnames{4}{n4} '\' levelnames{5}{n5}];
                                    ISPATH(end+1,1) = leveldir{5}(n5);
                                end
                            end
                            
                        end
                    end
                end
            end
        end
    end
end

N = length(FNAMES);

bgc = get(0,'DefaultUicontrolBackgroundColor');
h = waitbar(0,['Copiando arquivo 1 de ' num2str(N) '.'],'Name','Aguarde','Color',bgc);

clc
try
    for n = 1:N
        fname = FNAMES{n};
        dname = DNAMES{n};
        ispath = ISPATH(n);
        
        if ispath
            if ~exist(dname,'dir')
                dos(['mkdir "' dname '"']);
            end
        else
            dos(['copy "' fname '" "' dname '"']);
        end
        if ishandle(h)
            waitbar(n/N,h,['Copiando arquivo ' num2str(n) ' de ' num2str(N) '.']);
        else
            h = waitbar(n/N,['Copiando arquivo ' num2str(n) ' de ' num2str(N) '.'],'Name','Aguarde','Color',bgc);
        end
    end
    if ishandle(h), pause(.8); delete(h); end
    
    clc
    disp(' ')
    disp([' ' num2str(N) ' arquivos copiados com sucesso.']);
    disp(' ')
    
catch
    error('Erro ao copiar arquivos.');
end

% ----------------------------------------------
function [fnames, ispath] = getdirlist(fpath)

fdata = dir(fpath);

fnames = {fdata.name};
ispath = [fdata.isdir];

exc = strmatch('.',fnames); 

fnames(exc) = [];
ispath(exc) = [];

[void, ord] = sort(-ispath);
ispath = ispath(ord);
fnames = fnames(ord);