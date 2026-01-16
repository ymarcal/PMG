function F = unwrap2(F,cutoff)
% Resolve saltos de fase em vetores de dominio ciclico,
% transformando-os em vetores de dominio continuo
%    Fcont = unwrap2(Fciclic,cutoff)
%    cutoff defaul: 360°

if isempty(F)
    return
end

if nargin == 1
    cutoff = 360;
end

nnan = find(isnan(F));
F = denan(F,1);

% Converter dados de entrada para graus
k = 360 / cutoff;
F = F * k;

% Matriciacao do algoritmo
for m = 1:size(F,2)
    
    % Volta inicial no circulo trigonometrico
    q0 = floor(F(1,m)/360);
    
    % Colocar todos os dados no intervalo [0 360[
    F(:,m) = mod(F(:,m),360);
    
    for n = 2:size(F,1)
        if     F(n,m) - F(n-1,m) < -270
            F(n:end,m) = F(n:end,m) + 360;
        elseif F(n,m) - F(n-1,m) > 270
            F(n:end,m) = F(n:end,m) - 360;
        end
    end
    
    % Volta inicial no circulo trigonometrico
    F(:,m) = F(:,m) + q0*360;
    
end

% Converter dados de entrada para unidade oriinal
F = F / k;

F(nnan) = NaN;
