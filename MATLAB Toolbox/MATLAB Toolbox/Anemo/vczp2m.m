%  VCZP2M  calcula o numero de Mach dados Vc (Kt) e Zp (ft)
%
%          ex: m = vczp2m(Vc,Zp)
%
function m=vczp2m(vc,zp)
m=qcpa2m(vc2qc(vc),zp2pa(zp));
%