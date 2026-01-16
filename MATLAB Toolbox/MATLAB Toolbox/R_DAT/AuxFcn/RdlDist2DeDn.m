function [DE,DN] = RdlDist2DeDn(RDL,Dist,decl)
% Converte Radial/Distancia em Dist_Norte/Dist_Leste
% Sintaxe: [DE,DN] = RdlDist2DeDn(RDL,Dist,decl)

DN = Dist.*cos((RDL+decl)*pi/180);  % mesma unidade que Dist
DE = Dist.*sin((RDL+decl)*pi/180);  % mesma unidade que Dist
