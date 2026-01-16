function [LAT, LONG] = dxdy2latlong(F1,L1,DN,DE)
% Funcao que fornece a latitude e longitude de um ponto, dados:
% Sintaxe: [LAT, LONG] = dxdy2latlong(F1,L1,DN,DE)
%   F1, L1  -> Latitude e longitude do ponto base (graus);
%   DN      -> Distancia do ponto ao ponto base no eixo Norte verdadeiro (m);
%   DE      -> Distancia do ponto ao ponto base no eixo Leste verdadeiro (m);

a = 6378137;  % m
f = 1/298.2572;
e = sqrt(f*(2-f));

Rm = a*(1-e^2)./(1-(sin(F1*pi/180)).^2*e^2).^(3/2); % m
Rp = a./(1-(sin(F1*pi/180)).^2*e^2).^(1/2);         % m

LAT = DN./(pi./180*Rm)+F1;                     % graus
LONG = DE./(pi./180.*Rp.*cos(F1*pi/180))+L1;   % graus
