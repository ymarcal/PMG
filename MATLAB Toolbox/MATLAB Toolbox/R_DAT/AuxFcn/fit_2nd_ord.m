function [yf, t, cfs, zeta, wn] = fit_2nd_ord(x,y,ini)
% Faz um ajuste de curva para uma resposta de segunda ordem, na forma:
%      y(t) = a + b.exp[-c.(t-d)].sin[e.(t-d)] + f.t
% Sendo:
%      t = x - x0
%      wn = sqrt(e²+c²)
%      zeta = c/wn
%
% Sintaxe:
%     [yf, cfs, zeta, wn] = fit_2nd_ord(x,y,ini)
%
% Utiliza o metodo dos minimos quadrados (lsqcurvefit.m)

if nargin == 2
    ini = [mean(y), max(y-mean(y)), 0.1, 0, 12*pi/(max(x)-min(x)), 0];
end

if any(isnan(x)) || any(isnan(y)) || any(isnan(ini))
    yf   = NaN*y;
    t    = NaN*x;
    cfs  = NaN*ones(1,6);
    zeta = NaN;
    wn   = NaN;
    return
end

t = x - x(1);

fun = inline('X(1)+X(2).*exp(-X(3).*(t-X(4))).*sin(X(5).*(t-X(4)))+X(6).*t','X','t');

cfs = lsqcurvefit(fun,ini,t,y);
yf = fun(cfs,t);

wn = sqrt(cfs(5)^2+cfs(3)^2);
zeta = cfs(3)/wn;
