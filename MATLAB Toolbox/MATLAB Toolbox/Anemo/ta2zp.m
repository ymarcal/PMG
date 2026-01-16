% TA2ZP calcula a altitude correspondente a uma certa temperatura segundo a
%       lei da atmosfera padrao.
%
%       ex:  zp=ta2zp(ta,isa)
%                            calcula zp(ft) correspondente a ta(k) numa atm
%                            com desvio isa (K) da atm padrao
%
function zp=ta2zp(ta,disa)
if (nargin==1),
    disa=0.;
end
a1=find(ta<=216.65+disa);
[l,m]=size(a1);
zp=(288.15+disa-ta)/.0065; % (em m)
zp(a1)=ones(l,m)*11000;
zp=zp/.3048; % (em ft)
%