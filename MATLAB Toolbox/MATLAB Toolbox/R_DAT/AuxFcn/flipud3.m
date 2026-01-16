function M = flipud3(M)
% Espelhamento vertical de matriz tridimensional

for n = 1:size(M,3);    
    M(:,:,n) = flipud(M(:,:,n));
end
