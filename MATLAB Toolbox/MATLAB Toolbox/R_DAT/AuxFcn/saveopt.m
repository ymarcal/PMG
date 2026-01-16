function saveopt = saveopt
% Fornece a opçao para salvamento de arquivo mat sempre no padrao da versao 6

if getver >= 7
    saveopt = '-v6';
else
    saveopt = '';
end
