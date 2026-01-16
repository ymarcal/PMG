%
%  MTI2TA  calcula TA a partir de mach e ti;
%
%          ex: [ta]=MTI2TA(mach,ti,ksonda)
%
 function ta=mti2ta(mach,ti,ksonda)
 %
 if(nargin < 3),
   ksonda=input(' constante da sonda de temperatura : ');
 end
 if(mean(ti) < 150),
   ti=ti+273.15;
 end
 ta=ti./(1+ksonda*.2*mach.^2);
 %
