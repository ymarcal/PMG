function user = getuser
% Funçao que fornece o nome do usuario logado no Windows

try
    
    user = prefdir;
    
    ix = find(user=='\');
    iy = findstr(lower(user),'\application data');
    if isempty(iy)
        iy = findstr(lower(user),'\dados de aplicativos');
    end
    if isempty(iy)
        iy = findstr(lower(user),'\appdata');
    end
    n = find(ix==iy);
    
    user = user(ix(n-1)+1 : iy-1);
    
catch
    
    user = 'unknown';
    
end