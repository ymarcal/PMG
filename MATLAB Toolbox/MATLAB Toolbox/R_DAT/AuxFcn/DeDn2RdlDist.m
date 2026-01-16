function [RDL,Dist] = DeDn2RdlDist(DE,DN,decl)
% Converte Dist_Norte/Dist_Leste em Radial/Distancia
% Sintaxe: [RDL,Dist] = DeDn2RdlDist(DE,DN,decl)

RDL  = mod((pi-atan2(DE,-DN))*180/pi-decl,360); % graus
Dist = sqrt(DE.^2 + DN.^2);                     % mesma unidade que DE e DN
