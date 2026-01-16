function [str, dmy, Y] = dateread(str)
% Funçao que lê um string 'ano' ou 'mm/ano' ou 'dd/mm/ano' e converte em:
%    str: texto 'dd/mm/aaaa'
%    dmy: matriz numerica [dia mes ano]
%    Y  : ano corrido (com casas decimais)
% Sintaxe: [str, dmy, Y] = dateread(str)

dmy = str2num(strrep(str,'/',' '));
if length(dmy) == 1
    dmy = [1 1 dmy];
elseif length(dmy) == 2
    dmy = [1 dmy];
elseif length(dmy) ~= 3
    str = [];
    dmy = [];
    Y   = [];
    return
end

dd = dmy(1);
mm = dmy(2);
yy = dmy(3);

yy = max(0,yy);
if yy>=0 && yy<=60, yy = yy + 2000; end
if yy>60 && yy<100, yy = yy + 1900; end

mm = max(1,min(12,mm));

md = [31 28 31 30 31 30 31 31 30 31 30 31];

if ( rem(yy,4)==0 && rem(yy,100)~=0 ) || rem(yy,400)==0
    md(2) = md(2)+1;
end

dd = max(1,min(md(mm),dd));

str = [num2str(dd,'%02.0f') '/' num2str(mm,'%02.0f') '/' num2str(yy,'%04.0f')];

dmy = [dd mm yy];

if mm == 1
    Y = (dd-1)/sum(md) + yy;
else
    Y = (sum(md(1:mm-1))+dd-1)/sum(md) + yy;
end