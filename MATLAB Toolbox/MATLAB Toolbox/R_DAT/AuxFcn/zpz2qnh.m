% ZPZ2QNH
% Calcula o ajuste altímetro QNH (mbar)
% para uma dada altitude pressao Zp (pés)
% e uma dada altitude geométrica Z (pés)
%
%       Ex:   QNH = zpz2qnh(Zp,Z)
%
function QNH = zpz2qnh(Zp,Z)

pa = zp2pa(Zp);
QNH = pa.*(1-Z/145442).^(-1/0.190263);
QNH(pa<226.3) = pa(pa<226.3)./(0.223361*exp((36089-Z(pa<226.3))*4.80614E-5));