function [t, str] = str2time(str)
% Função que converte um string de tempo em um valor em segundos
% Sintaxe: [t, str] = str2time(str)
% Formatos aceitos: 'h:m:s:ms', 'h:m:s', 'h:m', 's', com ou sem " : "
% Informação de data é descartada, porém dia no formato d+h:m:s é aceito

if ~isempty(str)
    
    str(str=='\') = '/';
    if any(str=='/');
        x = find(str=='/');
        if length(x) > 1
            str(x(1):x(end)) = '0';
            x = x(1);
        end
        k = 0;
        while x-k && any(str(x-k)=='0123456789') %#ok
            str(x-k) = ' ';
            k = k+1;
        end
        k = 1;
        while x+k<=length(str) && any(str(x+k)=='0123456789')
            str(x+k) = ' ';
            k = k+1;
        end
        str(str=='-') = ' ';
    end
    
    str(str==':') = ' ';
    str(str=='_') = ' ';
    
    str = strtrim(str);
    
    np = find(str=='+');
    if length(np) == 1 && np > 1
        if any(str=='-')
            t = NaN;
            str = '';
            return
        else
            d = str2double(str(1:np-1));
            str(1:np) = [];
        end
        if isnan(d)
            d = 0;
        end
    else
        d = 0;
    end
    
    % Identificar formato aaaa-mm-ddThh:mm:ss.mssZ
    if length(str)>19 && str(11) == 'T' && str(end) == 'Z'
        str = str(12:end-1);
    end
    
    M = str2num(str); %#ok
    if isempty(M) || length(M) > 4
        t = NaN;
        str = '';
    else
        
        sgn = sign(M(1));
        if sgn < 0
            M = abs(M);
        elseif sgn == 0
            if str(1) == '-';
                sgn = -1;
            else
                sgn = 1;
            end
        end
        
        switch length(M)
            case 1 % SS
                M = [0 0 M 0];
            case 2 % HH MM
                M = [M 0 0];
            case 3 % HH MM SS
                M = [M 0];
        end
        t = sgn * (24*3600*d + abs(M(1))*3600 + M(2)*60 + M(3) + M(4)/1000);
        
        if nargout == 2
            str = time2str2(t);
        end
    end
    
else
    t = NaN;
    str = '';
end