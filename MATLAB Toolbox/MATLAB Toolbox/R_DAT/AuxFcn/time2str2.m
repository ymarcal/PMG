function str = time2str2(T,rmv,p)
% Funçao que converte tempo em segundos em um string hh:mm:ss.mss
% Sintaxe: str = time2str2(T,rmv,p)
%          T:       Tempo em segundos (pode ser um vetor)
%          rmv = 1: Remover zeros dos milisegundos (default)
%          rmv = 0: Manter  zeros dos milisegundos
%          p:       Numero de casas decimais (default: 3)
%          str:     String de tempo (exemplo: 12:06:40.261)
%
% Usada pelo R_DAT como alternativa à time2str original

if     nargin == 1
    rmv = 1;
    p = 3;
elseif nargin == 2
    p = 3;
end

p = max(0,min(p,6));

if isempty(T)
    str = '';
    return
end

TT = T;
for n = 1:length(TT)
    
    T = TT(n);
    
    if isnan(T)
        str = '';
        
    else
        
        sgn = sign(T);
        T = roundn(abs(T),-p);
        
        hh = floor(T/3600);
        mm = floor((T-3600*hh)/60);
        ss = T-3600*hh-60*mm;
        %ms = (T-floor(T))*1000;
        
        hh = num2str(hh,'%02d');
        mm = num2str(mm,'%02d');
        ss = num2str(ss,['%0' num2str(p+3) '.' num2str(p) 'f']);
        
        if ~p
            ss(1) = [];
        end
        
        if sgn == -1
            sgn = '-';
        else
            sgn = '';
        end
        
        if rmv && p
            while ss(end) == '0'
                ss(end) = [];
            end
            if ss(end) == '.'
                ss(end) = [];
            end
        end
        str = [sgn hh ':' mm ':' ss];
    end
    
    STR{n} = str;
    
end

str = char(STR);