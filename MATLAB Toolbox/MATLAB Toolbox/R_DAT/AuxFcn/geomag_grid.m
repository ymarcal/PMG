function [lat, lon, Dmag] = geomag_grid(lat1,lat2,lon1,lon2,d,alt,yr)
% Gera grade de declinaçao magnetica com resoluçao de d graus
%
% Sintaxe:
%    [lat, lon, Dmag] = geomag_grid(lat1,lat2,lon1,lon2,d,alt,yr)
%
% Formataçao:
%
%       lon1 ..  ..  .. lon2
%  lat1  + - - - - - - - +
%   :    |               |
%   :    |      Dmag     |
%   :    |               |
%  lat2  + - - - - - - - +
%

if nargin <= 4
    d = 1;
end
if nargin <= 5
    alt = 0;
end
if nargin <= 6
    D = clock;
    try
        [str, dmy, yr] = dateread([num2str(D(3)) '/' num2str(D(2)) '/' num2str(D(1))]);
    catch
        yr = sum(clock.*[1 1/12 0 0 0 0]);
    end
end

lat1 = max( -90,min( 90,lat1));
lat2 = max( -90,min( 90,lat2));
lon1 = max(-180,min(180,lon1));
lon2 = max(-180,min(180,lon2));

lat2 = max(lat1,lat2);
lon2 = max(lon1,lon2);

lat = (floor(lat1) : d : ceil(lat2))';
lon =  floor(lon1) : d : ceil(lon2);

N = length(lat);
M = length(lon);

Dmag = zeros(N,M);

if M >= N
    
    L = ones(1,M);
    for n = 1:N
        Dmag(n,:) = geomag(alt,L*lat(n)',lon,yr);
    end
    
else
    
    L = ones(N,1);
    for m = 1:M
        Dmag(:,m) = geomag(alt,lat,L*lon(m)',yr);
    end
    
end