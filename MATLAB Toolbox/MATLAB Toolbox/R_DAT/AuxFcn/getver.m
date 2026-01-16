function mver = getver
% Fornece a opçao para salvamento de arquivo mat sempre no padrao da versao 6

mver = version;

if length(mver) > 2
    ix = find(mver=='.');
    mver = str2double(mver(1:ix(2)-1));
else
    mver = 0;
end
