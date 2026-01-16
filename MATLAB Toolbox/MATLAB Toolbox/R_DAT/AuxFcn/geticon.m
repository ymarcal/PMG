function M = geticon(fname, btn, bgc, rot, fliph, flipv, bw, k)
% Funçao que fornece um icone para uso em botoes, atribuindo uma cor de fundo
% Sintaxe: M = geticon(fname, btn, bgc, rot, fliph, flipv)
%          fname: arquivo com as variaveis dos icones
%          btn:   nome do icone desejado
%          bgc:   cor de fundo desejada [r g b]
%          rot:   numero de rotaçoes do 90º anti-horarios (0, 1, 2, 3)
%          fliph: inversao horizontal (0, 1)
%          flipv: inversao vertical (0, 1)
%          bw:    converter imagem para preto e branco
%          k:     fator de correçao de cor (0: cor original, -1: preto, 1: branco)

if length(fname) > 4 && ~strcmpi(fname(end-3:end),'.mat')
    fname = [fname '.mat'];
end

if ~exist(fname,'file')
    M = [];
    return
end

fileinfo = whos('-file',fname);
if isempty(strmatch(btn,{fileinfo.name},'exact'))
    btn = [btn '_'];
end
if isempty(strmatch(btn,{fileinfo.name},'exact'))
    M = [];
    return
end

switch nargin
    case 3
        rot = 0;
        fliph = 0;
        flipv = 0;
        bw = 0;
        k = 0;
    case 4
        fliph = 0;
        flipv = 0;
        bw = 0;
        k = 0;
    case 5
        flipv = 0;
        bw = 0;
        k = 0;
    case 6
        bw = 0;
        k = 0;
    case 7
        k = 0;
end


D = load(fname,btn);
eval(['M = D.' btn ';']);

if bw > 0
    N = any(isnan(M),3);
    BW = rgb2gray(M);
    BW(N) = NaN;
    M(:,:,1) = BW;
    M(:,:,2) = BW;
    M(:,:,3) = BW;
end

if k ~= 0
    if k < 0 % Escurecer
        k = 1+max(-1,k);
        M = k*M;
    elseif k > 0 % Clarear
        k = 1-min(1,k);
        M = 1-(k*(1-M));
    end
end

for n = 1:size(M,1)
    for m = 1:size(M,2)
        if isnan(M(n,m,1)) || isnan(M(n,m,2)) || isnan(M(n,m,3))
            M(n,m,1) = bgc(1);
            M(n,m,2) = bgc(2);
            M(n,m,3) = bgc(3);
        end
    end
end

if rot
    M = rot3(M,rot);
end
if fliph
    M = fliplr3(M);
end
if flipv
    M = flipud3(M);
end
    
% ---------------------------------------------------------
function M = rot3(M,k)

if nargin == 1; k = 1; end
for n = 1:size(M,3);    
    M(:,:,n) = rot90(M(:,:,n),k);
end

% ---------------------------------------------------------
function M = fliplr3(M)

for n = 1:size(M,3);    
    M(:,:,n) = fliplr(M(:,:,n));
end

% ---------------------------------------------------------
function M = flipud3(M)

for n = 1:size(M,3);    
    M(:,:,n) = flipud(M(:,:,n));
end

