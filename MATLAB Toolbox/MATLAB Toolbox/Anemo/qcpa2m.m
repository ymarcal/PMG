%  qcpa2m   calcula o valor do numero de Mach dados os valores de
%           qc(mbar) e pa(mbar). Para Mach > 1 o calculo e aprox.
%           (ver manual da atm padrao).
%
%           ex:     m=qcpa2m(qc,pa)
%
function m=qcpa2m(qc,pa)
m=(5 .*((qc./pa+1).^.28571-1)).^.5;
a1=m>1;
m=m+a1.*.39 .*(m-1).^2.55;
%
