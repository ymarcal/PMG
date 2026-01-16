function str = deg2latlong(G,opt,p)
% Converte um valor em graus para um string de coordenada geografica
% 
% Sintaxe: str = deg2latlong(G,opt,p)
%          G: Valor em graus (pode ser um vetor)
%          opt = 1: latitude
%          opt = 2: longitude
%          p: digitos decimais dos minutos
%          str: string de coordenada (exemplos: S 23°42.125' e W 043°42.125')

if isempty(G)
    str = '';
    return
end

switch nargin
    case 1
        opt = 1;
        p   = 6;
        trim0 = 1;
    case 2
        p = 6;
        trim0 = 1;
    case 3
        trim0 = 0;
end

if opt ~= 1
    opt = 2;
end

p = max(p,0);

GG = G;
for n = 1:length(GG)
    
    G = GG(n);
    
    M = roundn(G*60,-p);
    
    if sign(M) == -1;
        M = abs(M);
        if opt == 1;
            c = 'S ';
        else
            c = 'W ';
        end
    else
        if opt == 1;
            c = 'N ';
        else
            c = 'E ';
        end
    end
    
    if isnan(M)
        str = '';
    else
        
        gg = fix(M/60);
        mm = M-gg*60;
        
        gg = num2str(gg,['%0',num2str(opt+1),'.0f']);
        
        if mm < 10
            s0 = '0';
        else
            s0 = '';
        end
        
        mm = [s0, num2str(mm,p+2)];
        
        if p && ~trim0
            ix = find(mm == '.'); %#ok<EFIND>
            if isempty(ix)
                mm = [mm, '.'];
            end
            while length(mm) < p+3
                mm = [mm, '0'];
            end
        end
        
        str = [c,gg,'°',mm,''''];
    end
    
    STR{n} = str;
    
end

str = char(STR);