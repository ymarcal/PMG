function eq = poly2eq(cfs,x,y)
% Converte um vetor de coeficientes em uma equação polinomial formatada
% Sintaxe: eq = poly2eq(cfs,x)
%          cfs: vetor de coeficientes (ex.: [1 2 3 4])
%          x:   nome da variável independente (default: 'x')
%          y:   nome da variável dependente   (default: 'y')
%          eq:  string na forma 'y = x^3 + 2 x^2 + 3 x + 4'

if nargin == 1
    x = 'x';
    y = 'y';
elseif nargin == 2
    y = 'y';
end

eq = '';

N = length(cfs);

% [a x^2 + b x - c]
for n = 1:N
    if cfs(n)
        str = '';
        if cfs(n) < 0
            if n == 1
                if cfs(n) == -1
                    str = ' -';
                else
                    str = [' -'  num2str(-cfs(n))];
                end
            else
                if cfs(n) == -1
                    str = [str ' -'];
                else
                    str = [str ' - ' num2str(-cfs(n))];
                end
            end
        else
            if n == 1
                if cfs(n) ~= 1
                    str = num2str(cfs(n));
                end
            else
                if cfs(n) == 1
                    str = [str ' +'];
                else
                    str = [str ' + ' num2str(cfs(n))];
                end
            end  
        end
        if n < N
            switch N-n
                case 1
                    str = [str ' z'];
%                 case 2
%                     str = [str ' z²'];
%                 case 3
%                     str = [str ' z³'];
                otherwise
                    str = [str ' z^' num2str(N-n)];
            end
        end
        eq = [eq str];
    end    
end
eq = strrep(eq,'z',x);

eq = [y ' = ',eq];
