function [F, sF] = getfreq(T)
% Funçao para obter a frequencia de um parametro de tempo

if length(T) <= 1
    F  = [];
    sF = [];
    return
end

T = T(:);

T = denan(T);

% Eliminar pontos decrescentes
c = 0;
while c < 200 && length(T)>1 && any(diff(T)<=0)
    T([false; diff(T)<=0]) = [];
    c = c+1;
end

if c == 200 || length(T) <= 1
    F  = [];
    sF = [];
    return
end

D = diff(T);

Fold = -1;
F = 1/mean(D);

% Eliminar saltos maiores que 2 desvios-padrao
while F ~= Fold
    
    Fold = F;
    
    M = mean(D);
    S = std(D);
    
    D(D>M+2*S) = [];
    
    if isempty(D)
        F  = [];
        sF = [];
        return
    end
    
    F  = 1/mean(D);
    
end

% Calculo do desvio padrao
if nargout == 2
    sF = [];
    D = sort(D);
    k = fix(length(D)/100);
    if k == 0
        sF = 0;
    else
        for n = 1:k:length(D)
            sF(end+1) = 1/mean(D(n:min(n+k-1,length(D))));
        end
        sF = std(sF);
    end
end