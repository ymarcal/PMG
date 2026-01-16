function [str,G] = latlongread(str,opt)
% Funçao que lê um string de coordenadas geograficas e converte em lat/long e em valor numerico
% Sintaxe: [str,G] = latlongread(str,opt)
% Entradas:
%   str: string em um dos seguintes formatos:        Exemplos: Coordenadas de SBSJ:
%        ±graus                                          -23          / -45
%        ±graus min                                      -23 13       / -45 52
%        ±graus min seg                                  -23 13 44    / -45 52 16
%        X gg°mm.mm' / Y ggg°mm.mm'                      S 23°13.733' / W 045°52.267'
%        X gg°mm'ss" / Y ggg°mm'ss"                      S 23°13'44"  / W 045°52'16"
%        ggmm.mmX    / gggmm.mmY                         2313.733S'   / 04552.267W
%        ggmmssX     / gggmmssY                          231344S      / 0455216W
%        Obs.: X=N/S e Y=E/L/W/O (podem ser posicionados antes ou apos os numeros)
%   opt: 1 = latitude, 2 = longitude (opcional)
% Saidas:
%   str: string no formato X gg°mm.ss' ou Y ggg°mm.mm'   S 23°13.733'      , W 045°52.267'
%   G  : valor numerico em graus                         -23.22888888888889, -45.87111111111111
%

if isempty(str)
    str = '';
    G = [];
    return
end

if isnumeric(str)
    str = num2str(str,16);
end

if str(end) == '.'
    str(end) = [];
end

str = upper(str);

if any(str(end)=='NSELWO')
    str = [str(end) str(1:end-1)];
end

if nargin == 1
    if any(str(1)=='ELWO')
        opt = 2;
    else
        opt = 1;
    end
end


if any([str(1)=='-' str=='W' str=='O' str=='S'])
    sgn0 = -1;
else
    sgn0 = 1;
end

str(str=='N') = [];
str(str=='S') = '-';
str(str=='E') = [];
str(str=='L') = [];
str(str=='W') = '-';
str(str=='O') = '-';
str(str=='°') = ' ';
str(str=='º') = ' ';
str(str=='''') = ' ';
str(str=='"') = ' ';

str(str=='/') = 'X'; % Ignorar datas

GMS = str2num(str); %#ok<ST2NM>

if isempty(GMS) || length(GMS) > 3
    str = '';
    G = [];
else
    
    if GMS(1)
        sgn = sign(GMS(1));
    else
        sgn = sgn0;
    end

    GMS = abs(GMS);
    
    switch length(GMS)
        case 1
            if opt == 1 && GMS > 9000  ||  opt == 2 && GMS > 18000
                G = fix(GMS/10000);
                GMS = GMS - G*10000;
                M = fix(GMS/100);
                S = GMS - M*100;
                G = sgn * (G + M/60 + S/3600);
            elseif opt == 1 && GMS > 90  ||  opt == 2 && GMS > 180
                G = fix(GMS/100);
                M = GMS - G*100;
                G = sgn * (G + M/60);
            else
                G = sgn * GMS;
            end
        case 2
            G = sgn * (GMS(1) + GMS(2)/60);
        case 3
            G = sgn * (GMS(1) + GMS(2)/60 + GMS(3)/3600);
    end
    
    str = deg2latlong(G,opt,3);
    
end
