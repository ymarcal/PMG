function [yf, t, cfs, tau, yinf] = fit_1st_ord(x,y,ini)
% Faz um ajuste de curva para uma resposta de primeira ordem, na forma:
%      y(t) = a + b.[1-exp(-t/c)]
% Sendo:
%      t    = x - x0
%      yi   = y - y0
%      tau  = c
%      yini = a
%      yinf = a + b
%
% Sintaxe:
%     [yf, t, cfs, tau, yinf] = fit_1st_ord(x,y,ini);
%
% O inicio da resposta é considerado como sendo no primeiro ponto da amostra
% Utiliza o metodo dos minimos quadrados (lsqcurvefit.m)
%

if nargin == 2
    ini = [range(y) range(x)/6];
end
if length(ini) == 3
    ini(1) = [];
end

if any(isnan(x)) || any(isnan(y)) || any(isnan(ini))
    yf   = NaN*y;
    t    = NaN*x;
    cfs  = [NaN NaN NaN];
    yinf = NaN;
    tau  = NaN;
    return
end

t  = x - x(1);

fun = inline('X(1).*(1-exp(-t./X(2)))','X','t');

cfs = lsqcurvefit(fun,ini,t,y-y(1));
yf = fun(cfs,t)+y(1);

cfs = [y(1) cfs];

yinf = cfs(1)+cfs(2);
tau = cfs(3);
