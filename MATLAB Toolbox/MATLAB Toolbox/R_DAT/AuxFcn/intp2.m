function zi = intp2(xi,yi,M,av)

%   Função de interpolação bidimensional linear.
%   Sintaxe: zi = intp2(xi,yi,M,av)
%
%   M é uma matriz da forma:
%
%     NaN y1  y2  y3  ...     (O primeiro elemento de M é descartado)
%     x1  z11 z12 z13 ...
%     x2  z21 z22 z23 ...
%     x3  z31 z32 z33 ...
%     :   :   :   :
%
%   xi e yi são os pontos dos eixos para os quais será determinado um valor zi.
%   av é um parâmetro opcional que controla os avisos de extrapolação.
%   av = 1: avisos habilitados (default).
%   av = 0: avisos desabilitados.
%   Valores extrapolados são sempre fornecidos, independentemente de av.
%
%   Copyright 1°Ten.Eng. Leonardo - Abr/2003

if nargin ~= 4
    av = 1;
end

[a,b] = size(M);

x = M(2:a,1);
y = M(1,2:b);
z = M(2:a,2:b);

for i = 1:length(xi)
    
    if (xi(i)<min(x) | xi(i)>max(x)) & av
        disp('  ')
        disp(['  ATENÇÃO: Extrapolação em x (',num2str(min(x)),' a ',num2str(max(x)),')'])
    end
    if (yi(i)<min(y) | yi(i)>max(y)) & av
        disp('  ')
        disp(['  ATENÇÃO: Extrapolação em y (',num2str(min(y)),' a ',num2str(max(y)),')'])
    end
    
    for col = 1:length(y)
        aux(col) = interp1(x,z(:,col),xi(i));
    end
    
    zi(i,1) = interp1(y,aux,yi(i));
    
end