function [XC, YC] = patchplot(x,y,c)
% Creates a single patch object from a series of NaN-delimited polygons
% Holes are not accepted (use polycut to embbed holes in outer polygon)
% Syntax: h = patchplot(x,y,c) ou [XC, YC] = patchplot(x,y,c)
%         h: patch handle
%         x, y: NaN-delimited vectors
%         c: color code character
%         XC, YC: matrizes contendo um poligono por coluna

if isempty(x)
    XC = [];
    YC = [];
    return
end

if nargin == 2
    c = 'b';
end

xc = x(:);
yc = y(:);

% Colocar NaN de x em y e vice-versa
yc(isnan(xc)) = NaN;
xc(isnan(yc)) = NaN;

% Colocar NaN no inicio e fim
xc = [NaN; xc; NaN];
yc = [NaN; yc; NaN];

% Excluir NaN's contiguos
exc = isnan(xc);
exc = exc & [exc(2:end); 0];
xc(exc) = [];
yc(exc) = [];

% Concatenar lateralmente as coordenadas de cada poligono
nnan = find(isnan(xc));
C = length(nnan)-1;
L = max(diff(nnan))-1;

XC = zeros(L,C);
YC = zeros(L,C);

for n = 1:length(nnan)-1
    XC(:,n) = [xc(nnan(n)+1 : nnan(n+1)-1); xc(nnan(n)+1)*ones(L-nnan(n+1)+nnan(n)+1,1)];
    YC(:,n) = [yc(nnan(n)+1 : nnan(n+1)-1); yc(nnan(n)+1)*ones(L-nnan(n+1)+nnan(n)+1,1)];
end

if isempty(XC)
    XC = NaN;
    YC = NaN;
end

if nargout <= 1
    % Criar patch
    h = patch(XC,YC,c,'LineStyle','none','EdgeColor','none');
    XC = h;
end
