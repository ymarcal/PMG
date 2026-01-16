function x = nan2zero(x,val)
% Funçao que substitui valores invalidos (NaN) por um valor numerico (default = 0)
% Sintaxe: x = nan2zero(x,val)

if nargin == 1
    val = 0;
end

x(isnan(x)) = val;