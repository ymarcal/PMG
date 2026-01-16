function x = denan(x,rep)
% Funçao que elimina valores invalidos (NaN) em um vetor
% Sintaxe: x = denan(x,rep)
% Opçoes: rep = 1: repete ultimo valor valido
%         rep = 0: interpola trecho invalido (default)

if isempty(x)
    x = [];
    return
end

if nargin == 1
    rep = 0;
end    

if size(x,1) == 1
    x = x';
    isline = 1;
else
    isline = 0;
end

for n = 1:size(x,2)
    
    if all(isnan(x(:,n)))
        x(:,n) = zeros(size(x(:,n)));
    else
        
        if isnan(x(1,n))
            x(1,n) = x(min(find(~isnan(x(:,n)))),n);
        end
        
        if isnan(x(end,n))
            x(end,n) = x(max(find(~isnan(x(:,n)))),n);
        end
        
        nnan = find(isnan(x(:,n)));
        
        if ~isempty(nnan)
            nbrk = sort([nnan(1); nnan(find(diff(nnan)>1)); nnan(find(diff(nnan)>1)+1); nnan(end)]); %#ok<FNDSB>
            
            for k = 1:length(nbrk)/2
                if rep
                    x(nbrk(2*k-1):nbrk(2*k),n) = x(nbrk(2*k-1)-1,n);
                else
                    x(nbrk(2*k-1)-1:nbrk(2*k)+1,n) = linspace(x(nbrk(2*k-1)-1,n),x(nbrk(2*k)+1,n), nbrk(2*k)-nbrk(2*k-1)+3)';
                end
            end            
        end
    end
    
end

if isline
    x = x';
end