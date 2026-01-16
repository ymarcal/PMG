% M2QCPA   calcula a razao qc/pa correspondente a dado numero de Mach
%          ex:   qcpa=m2qcpa(m)
function qp=m2qcpa(m)
a1=m<1;
a2=m>=1;
qp=a1.*((1+.2 .*m.^2).^3.5-1)+...
   a2.*(1.892929.*m.^7 ./(1+1.1666666666 .*(m.^2-1)).^2.5-1);
%


