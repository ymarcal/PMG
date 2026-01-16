function str = datetime2str(dt)
% Converte um vetor numerico de data-hora em um string
% Sintaxe: str = datetime2str(dt)
%          dt: data-hora no formato [ano mes dia hora min seg] (seg é opcional)
%          str: string no formato '25/10/2007 11:33h' ou '25/10/2007 11h33m24s'

if size(dt,2) == 3
    dt(:,[4 5]) = 0;
    onlydate = 1;
else
    onlydate = 0;
end

for n = 1:size(dt,1);
    ano = dt(n,1);
    mes = dt(n,2);
    dia = dt(n,3);
    hra = dt(n,4);
    mnt = dt(n,5);
    
    ano = max(0, min(9999, ano));

    if size(dt,2) == 6
        seg = fix(dt(n,6));
    end
    
    dia = num2str(dia,'%02d');
    mes = num2str(mes,'%02d');
    ano = num2str(ano,'%04d');
    hra = num2str(hra,'%02d');
    mnt = num2str(mnt,'%02d');
    
    if size(dt,2) == 6
        seg = num2str(seg,'%02d');
    else
        seg = '';
    end
    
    if size(dt,2) == 6
        str(n,:) = [dia,'/',mes,'/',ano,' ',hra,'h',mnt,'m',seg,'s'];
    else
        str(n,:) = [dia,'/',mes,'/',ano,' ',hra,':',mnt,'h'];
    end
    
end

if onlydate
    ind = find(str(1,:)==' ');
    str(:,ind:end) = [];
end
