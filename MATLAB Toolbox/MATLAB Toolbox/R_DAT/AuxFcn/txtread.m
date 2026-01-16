function [dat, txt, err] = txtread(fname,dlm,subst,cellonly)
% Funçao para importar dados formatados em arquivo texto
% NAO CONFUNDIR COM A FUNÇAO "TEXTREAD"
%
% [dat, txt, err] = txtread(fname,subst,cellonly)
%
% Entradas:
%       fname:    nome do arquivo de texto
%       dlm:      caractere delimitador (vazio = busca automatica)
%       subst:    celula de substituiçao de texto-padrao (1ª coluna) para valor numerico (2ª coluna)
%                 exemplo: subst = {'CCIP', 1; 'CCRP', 2};
%       cellonly: (0 ou 1) fornece apenas a matriz de celulas, sem interpretar valores
%
% Saidas:
%       dat: matriz de valores numericos
%       txt: matriz de celulas de texto
%       err: mensagem de erro
%

dat = [];
txt = {};
err = '';

% Validar variaveis
error(nargchk(1,4,nargin));
error(nargoutchk(0,3,nargout));

switch nargin
    case 1
        dlm = [];
        subst = [];
        cellonly = 0;
    case 2
        subst = [];
        cellonly = 0;
    case 3
        cellonly = 0;
end

if ~ischar(fname)
    err = 'Nome do arquivo deve ser texto.';
    return
end
if isempty(fname)
    err = 'Nome de arquivo vazio.';
    return
end

if all(fname~='.'), fname = [fname '.txt']; end

if exist(fname,'file') ~= 2
    err = 'Arquivo não encontrado.';
    return
end

if isempty(fileparts(fname))
    fname = which(fname);
end

% Leitura do arquivo
try
    fid = fopen(fname);
    D = fread(fid);
    D = D';
    fclose(fid);
catch
    error(lasterr); end
try
    fclose(fid);
end

if isempty(D)
    err = 'Arquivo vazio.';
    return
end

% Eliminação de "pre-enter"
D(D==13) = [];

% Eliminação de espaços contiguos
S  = D==32;
S2 = [0 S(1:end-1)];
exc = S&S2;
D(exc) = [];

% Colocaçao de zero à esquerda dos segundos (ocorre em PHOTO.DAT)
% Exemplo: "11:52: 0.17" -> "11:52:00.17"
S1 = [0, D==abs(':')];
S2 = [D==abs(' '), 0];
D(S1&S2) = '0';

% Eliminação de espaço no inicio das linhas
L = [1 D==10];
L(end) = [];
S = D==32;
exc = L&S;
D(exc) = [];

% Eliminação de espaço no final das linhas
L = [D==10 1];
S = D==32;
L(1) = [];
exc = L&S;
D(exc) = [];

% Definição do caracter delimitador
if isempty(dlm)
    dlm_list = [abs(',') abs(';') 9 abs(' ')]; % 9 = tab
    for n = 1:length(dlm_list)
        N_dlm(n) = length(find(D == dlm_list(n) ));
    end
    N_dlm(4) = N_dlm(4)/2; % Delimitadores têm precedencia sobre espaços
    dlm = dlm_list( find(N_dlm==max(N_dlm)) );
    dlm = dlm(1);
end

% Eliminação de linhas vazias
while D(1)==10, D(1) = []; end
L = find(D==10);  % Localização de "enter"
D(L(find(diff(L)==1))) = [];

% Colocação de "enter" no final
if D(end) ~= 10;
    D = [D 10];
end
L = [0 find(D==10)];

% Estimativa do tamanho da matriz
line1 = D(L(1)+1:L(2)-1);
Ndlm  = length(find(line1==dlm));

[void, name] = fileparts(fname);
bgc = get(0,'DefaultUicontrolBackgroundColor');

if length(L) > 100
    wb = 1;
    h = waitbar(0,['Capturando arquivo ''' name '''.'],'Name','0.0% concluído',...
        'Color',bgc,'Renderer','zbuffer','Pointer','watch','WindowStyle','modal');
    set(get(get(h,'children'),'Title'),'Interpreter','none');
else
    h = 0;
    wb = 0;
end

% Captura das células
C = cell(length(L)-1,Ndlm+1);
try
    for n = 1:length(L)-1;
        Dline = D(L(n)+1:L(n+1)-1);
        Ddlm = [0, find(Dline == dlm), length(Dline)+1];
        for m = 1:length(Ddlm)-1;
            C{n,m} = fliplr(deblank(fliplr(deblank(   char(Dline(Ddlm(m)+1:Ddlm(m+1)-1))  )))) ;
        end
        Pd = .5*n/(length(L)-1);
        if ishandle(h)
            try
                waitbar(Pd,h);
                set(h,'Name',[num2str(100*Pd,'%1.1f') '% concluído']);
            end
        elseif wb
            err = 'Operação cancelada.';
            return
        end
    end
    for n = 1:size(C,1)
        for m = 1:size(C,2)
            if ~ischar(C{n,m}), C{n,m} = ''; end
        end
    end
    D = [];
catch
    err = 'Arquivo com formato incompatível.';
    try, delete(h); end
    return
end

if isempty(C)
    err = 'Arquivo com formato incompatível.';
    try, delete(h); end
    return
end

if cellonly
    dat = C;
    return
end

% Conversao das celulas
try
    [N,M] = size(C);
    
    dat = NaN*zeros(N,M);
    txt = cell(N,M);
    
    isdat = false(N,M);
    istxt = false(N,M);
    
    for n = 1:N
        for m = 1:M
            
            if isempty(C{n,m})
                % Nada a fazer
            elseif strcmpi(C{n,m},'NaN')
                isdat(n,m) = 1;
            else
                
                % Tentar ler numero
                val = str2double(C{n,m});
                
                % Tentar ler data
                if isnan(val) && any(C{n,m}=='/')
                    [void, void, val] = dateread(C{n,m});
                    if isempty(val), val = NaN; end
                end
                
                % Tentar ler hh:mm:ss
                if isnan(val)
                    val = str2time(C{n,m});
                end
                
                % Tentar ler lat/long
                if isnan(val)
                    [void,val] = latlongread(C{n,m});
                    if isempty(val), val = NaN; end
                end
                
                % Tentar substituição de texto-padrao por numeros
                if isnan(val) && ~isempty(subst)
                    ind = strmatch(lower(C{n,m}),lower(subst(:,1)),'exact');
                    if ~isempty(ind)
                        val = subst{ind(1),2};
                    end
                end
                
                if ~isnan(val)
                    dat(n,m) = val;
                    isdat(n,m) = 1;
                else
                    txt{n,m} = C{n,m};
                    istxt(n,m) = 1;
                end
            end
            Pd = .5+ .5*n/N;
            if ishandle(h)
                try
                    waitbar(Pd,h,['Convertendo arquivo ''' name '''.']);
                    set(h,'Name',[num2str(100*Pd,'%1.1f') '% concluído']);
                end
            elseif wb
                dat = [];
                txt = {};
                err = 'Operação cancelada.';
                try, delete(h); end
                return
            end
        end
        
    end
catch
    dat = [];
    txt = {};
    err = 'Arquivo com formato incompatível.';
    try, delete(h); end
    return
end

% Eliminar colunas e linhas invalidas de dados (à esquerda e acima)
while ~isempty(isdat) && all(~isdat(:,1))
    dat(:,1)   = [];
    isdat(:,1) = [];
end
while ~isempty(isdat) && all(~isdat(1,:))
    dat(1,:)   = [];
    isdat(1,:) = [];
end

% Eliminar colunas e linhas invalidas de texto (todos os lados)
while ~isempty(istxt) && all(~istxt(:,1))
    txt(:,1)   = [];
    istxt(:,1) = [];
end
while ~isempty(istxt) && all(~istxt(:,end))
    txt(:,end)   = [];
    istxt(:,end) = [];
end
while ~isempty(istxt) && all(~istxt(1,:))
    txt(1,:)   = [];
    istxt(1,:) = [];
end
while ~isempty(istxt) && all(~istxt(end,:))
    txt(end,:)   = [];
    istxt(end,:) = [];
end
for n = 1:size(txt,1)
    for m = 1:size(txt,2)
        if isempty(txt{n,m})
            txt{n,m} = '';
        end
    end
end

try, pause(.4); delete(h); end


