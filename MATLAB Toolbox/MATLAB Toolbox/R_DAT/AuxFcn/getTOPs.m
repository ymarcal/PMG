function [tops, ntops, err] = getTOPs(TOP)
% Funçao para obter os TOPs e a posiçao em que ocorreram
% Apenas numeros inteiros maiores que zero sao considerados TOPs 

TOP(TOP<0) = 0;
TOP = round(denan(TOP(:),1));

decr = find(diff(TOP)<0);

if ~isempty(decr)
    if length(decr) == 1
        err = char('Parâmetro inadequado:','Encontrado 1 ponto decrescente.');
    else
        err = char('Parâmetro inadequado:',['Encontrados ' num2str(length(decr)) ' pontos decrescentes.']);
    end
    tops    = [];
    ntops   = [];
    return
end

tops = setdiff(unique(TOP),TOP(1));
if isempty(tops)
    err = 'Não há TOPs registrados.';
    tops    = [];
    ntops   = [];
    return
end

for n = 1:length(tops)
    aux = find(TOP==tops(n));
    ntops(n,1) = aux(1);
end
err = '';
