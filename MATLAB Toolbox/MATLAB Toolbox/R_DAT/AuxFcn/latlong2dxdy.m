function [DE, DN] = latlong2dxdy(F1,L1,F2,L2)
% [DE, DN] = latlong2dxdy(F1,L1,F2,L2)
% Funcao que fornece a posiçao relativa entre dois pontos, dados:
%   F1, L1  -> Latitude e longitude do ponto base (graus);
%   F2, L2  -> Latitude e longitude do ponto remoto (graus);
%   DE, DN  -> Distancias Leste e Norte (metros);

a = 6378137;  % m
f = 1/298.2572;
e = sqrt(f*(2-f));

Rm = a*(1-e^2)./(1-(sin(F1*pi/180)).^2*e^2).^(3/2); % m
Rp = a./(1-(sin(F1*pi/180)).^2*e^2).^(1/2);         % m

DN  = (F2-F1)*pi/180.*Rm;                    % m
DE  = (L2-L1)*pi/180.*Rp.*cos(F1*pi/180);    % m
