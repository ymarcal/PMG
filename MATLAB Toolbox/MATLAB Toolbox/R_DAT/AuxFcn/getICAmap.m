function [lat1, lat2, lon1, lon2] = getICAmap(name)
% Obtem as coordenadas de um mapa que usa a nomenclatura CNAV/CAP do
% ICA - Instituto de Cartografia da Aeronautica
%
% Exemplo: S31W052X --> [-30.5 -30 -52 -51.5] (graus)
%
%   -30 +---+---+
%       | X | Z |
%       +---+---+
%       | W | Y |
%   -31 +---+---+
%      -52     -51
%

ix = find(name == '.');
if ~isempty(ix)
    name(ix:end) = [];
end
name = upper(name);

if length(name) ~= 8
    lat1 = [];
    lat2 = [];
    lon1 = [];
    lon2 = [];
    return
end

if     name(1) == 'N'
    slat =  1;
elseif name(1) == 'S'
    slat = -1;
else
    slat = 0;
end
if     name(4) == 'E'
    slon =  1;
elseif name(4) == 'W'
    slon = -1;
else
    slon = 0;
end

if ~slat || ~slon
    lat1 = [];
    lat2 = [];
    lon1 = [];
    lon2 = [];
    return
end

lat = slat*str2double(name(2:3));
lon = slon*str2double(name(5:7));

switch name(8)
    case 'W'
        % Nada a fazer
    case 'X'
        lat = lat+.5;
    case 'Y'
        lon = lon+.5;
    case 'Z'
        lat = lat+.5;
        lon = lon+.5;
    otherwise
        lat1 = [];
        lat2 = [];
        lon1 = [];
        lon2 = [];
        return
end

lat1 = lat;
lat2 = lat+.5;
lon1 = lon;
lon2 = lon+.5;