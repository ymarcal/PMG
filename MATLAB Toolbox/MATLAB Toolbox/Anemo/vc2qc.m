% VC2QC calcula qc(mbar) dada a velocidade calibrada Vc(Kt)
%
%       ex:   qc=vc2qc(vc)
%
 function qc=vc2qc(vc)
 k=(vc./661.47).^2;
 a1=vc<661.47;
 a2=vc>=661.47;
 qc=a1.*(1013.25 .*((1+.2 .*k).^3.5-1))+...
   a2.*(1013.25 .*((1.2 .*k).^3.5 .*(1+1.166666666 .*(k-1)).^(-2.5)-1));
%