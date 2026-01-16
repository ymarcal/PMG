function [ilat, ilon] = mapgrid(scale, dlat, dlon)
% Fornece as coordenadas da grade com escala 'scale' que abrange
% os dados limitados por dlat = [minlat maxlat] e dlon = [minlon maxlon]

step = scale * .025;

minlat = dlat(1);
maxlat = dlat(2);
minlon = dlon(1);
maxlon = dlon(2);

ilat = 0 : step :  90+step;  ilat = [-fliplr(ilat(2:end)) ilat(1:end-1)];
ilon = 0 : step : 180+step;  ilon = [-fliplr(ilon(2:end)) ilon(1:end-1)];

ilat = roundn(ilat,-3);
ilon = roundn(ilon,-3);

ilat(ilat+step <= minlat | ilat > maxlat) = [];
ilon(ilon+step <= minlon | ilon > maxlon) = [];