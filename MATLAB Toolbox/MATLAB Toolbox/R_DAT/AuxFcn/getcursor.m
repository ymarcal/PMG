function [M, p] = getcursor(fname, cur)
% Funçao que fornece uma figura para uso em cursores
% Sintaxe: [M, p] = getcursor(fname, cur)
%          M:     matriz do cursor (1 = preto, 2 = branco, NaN = transparente)
%          p:     ponto-quente do cursor
%          fname: arquivo com as variaveis dos cursores
%          cur:   nome do cursor desejado

if ~exist(fname,'file') || isempty(strfind(fname,'.mat'))
    M = NaN*ones(16);
    M(:,8) = 1;
    M(8,:) = 1;
    p = [8 8];
    return
end

fileinfo = whos('-file',fname);
if isempty(strmatch(cur,{fileinfo.name},'exact'))
    M = NaN*ones(16);
    M(:,8) = 1;
    M(8,:) = 1;
    p = [8 8];
    return
end

D = load(fname,cur);
eval(['M = D.' cur ';']);

if isempty(strmatch([cur '_hs'],{fileinfo.name},'exact'))
    p = [8 8];
    return
end

P = load(fname,[cur '_hs']);
eval(['p = P.' cur '_hs;']);
