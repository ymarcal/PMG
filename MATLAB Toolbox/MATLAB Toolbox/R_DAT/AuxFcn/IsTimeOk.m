function [ok, ndc, nna] = IsTimeOk(T)
% Informa se a trilha de tempo T e´ adequada
% Criterios: T tem de ser monotonica crescente e sem NaNs
% Saidas: ok = 0/1: validade da trilha
%         ndc = pontos nao crescentes
%         nna = pontos invalidos (NaN)

if isempty(T)
    ok  = 0;
    ndc = 0;
    nna = 0;
    return
end

if nargout == 1 % Quick check
    
    ndc = any(diff(T)<=0);
    nna = any(isnan(T));
    ok  = ~ndc && ~nna;
    
else  % Full check
    
    ndc = find(diff(denan(T))<=0)+1;
    nna = find(isnan(T));
    ndc = setdiff(ndc,nna);
    ok  = isempty(ndc) && isempty(nna);
    
end
