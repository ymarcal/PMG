% PA2ZP    calcula a altitude pressao zp(ft) dada a pressao atmosferica
%          pa(mbar)
%
function zp=pa2zp(pa)
a1 = pa>=226.31;
a2 = pa<226.31;
zp = a1.*4.4330171e4.*( 1-(pa./1013.25).^.190263096)/.3048+...
   a2.*(11000-6.3413149e3.*log(pa/226.31))/.3048;
%
