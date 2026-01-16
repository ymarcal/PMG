function [yf, yfdot] = eval_1st_ord(cfs,t)
% Fornece os pontos fitados de t segundo os coeficientes cfs, na forma:
%      y(t) = a + b.[1-exp(-t/c)]
% Tambem fornece a primeira derivada.
%
% Sintaxe:
%     [yf, yfdot] = eval_1st_ord(cfs,t)

fun = inline('X(1)+X(2).*(1-exp(-t./X(3)))','X','t');
fundot = inline('X(2)./X(3).*exp(-t./X(3))','X','t');

yf    = fun(cfs,t);
yfdot = fundot(cfs,t);
