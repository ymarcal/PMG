function M = rot3(M,k)
% Rotaçao de matriz tridimensional
% Sintaxe: M = rot3(M,k)
% k: numero de rotaçoes de 90º no sentido anti-horario

if nargin == 1; k = 1; end
for n = 1:size(M,3);    
    M2(:,:,n) = rot90(M(:,:,n),k);
end
M = M2;
