function [yf, yfdot] = eval_2nd_ord(cfs,t)
% Fornece os pontos fitados de t segundo os coeficientes cfs, na forma:
%      y(t) = a + b.exp[-c.(t-d)].sin[e.(t-d)] + f.t
% Tambem fornece a primeira derivada.
%
% Sintaxe:
%     [yf, yfdot] = eval_2nd_ord(cfs,t)

fun = inline('X(1)+X(2).*exp(-X(3).*(t-X(4))).*sin(X(5).*(t-X(4)))+X(6).*t','X','t');
fundot = inline(['0*X(1) - X(2).*X(3).*exp(-X(3).*(t-X(4))).*sin(X(5).*(t-X(4))) + ',...
        'X(2).*exp(-X(3).*(t-X(4))).*X(5).*cos(X(5).*(t-X(4))) + X(6)'],'X','t');

yf    = fun(cfs,t);
yfdot = fundot(cfs,t);
