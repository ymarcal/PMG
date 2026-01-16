function [x, y] = patchnan(XC,YC)
% Converts matrix-based patch coordinates to NaN-delimited vectors
% (opposite to patchplot function)

x = [];
y = [];

if isempty(XC)
    return
end

% Extraçao das colunas
for n = 1:size(XC,2)
    xi = XC(:,n);
    yi = YC(:,n);
    
    % Exclusao dos pontos repetidos
    exc = [];
    for m = length(xi):-1:1
        if xi(m) == xi(1) && yi(m) == yi(1)
            exc = [exc m];
        else
            break
        end
    end
    xi(exc) = [];
    yi(exc) = [];
    
    % Empilhamento das colunas
    if ~isempty(xi)
        if isempty(x)
            x = xi;
            y = yi;
        else
            x = [x; NaN; xi];
            y = [y; NaN; yi];
        end
    end
end
