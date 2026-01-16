function [newDADOS, PARAM, err] = LoadMatEmb(fname,fpath,maxparamlength)
% Funçao para carregamento e validaçao de arquivo mat no padrao Embraer
%     Cada parametro é armazenado em uma variavel separada, no formato vetor coluna
%     O nome do parametro é definido pelo nome da variavel

try
    
    switch nargin
        case 0
            [fname, fpath] = uigetfile({'*.mat','Arquivo mat (*.mat)'},'Carregar arquivo mat'); drawnow;
            if ~ischar(fname)
                return
            end
            maxparamlength = 48;
        case 1;
            fpath = '';
            maxparamlength = 48;
        case 2;
            maxparamlength = 48;
    end
    
    err = '';
    fname = [fpath fname];
    
    % Cheque do arquivo
    if ~exist(fname,'file')
        err = 'Arquivo não encontrado.';
        newDADOS = [];
        PARAM = [];
        return
    end
    
    fdata = whos('-file',fname);
    
    if isempty(fdata)
        err = 'Arquivo de dados vazio.';
        newDADOS = [];
        PARAM = [];
        return
    end
    
    % Cheque das variaveis
    exc = [];
    for n = 1:length(fdata)
        if      ~(strcmp(fdata(n).class,'double') || strcmp(fdata(n).class,'single')) || ...
                fdata(n).size(2) ~= 1 || fdata(n).size(1) < 100 || ...
                strcmp(fdata(n).name,'DADOS')
            exc = [exc n];
        end
    end
    fdata(exc) = [];
    
    if isempty(fdata)
        err = 'Não há dados válidos no arquivo.';
        newDADOS = [];
        PARAM = [];
        return
    end
    
    Nobs = max([fdata.size]);
    
    exc = [];
    for n = 1:length(fdata)
        if fdata(n).size(1) ~= Nobs
            exc = [exc n];
        end
    end
    fdata(exc) = [];
    
    Npar = length(fdata);
    
    if Npar < 2
        err = 'O arquivo deve conter pelo menos 2 parâmetros.';
        newDADOS = [];
        PARAM = [];
        return
    end

    % Mover colunas de tempo para o inicio
    T = zeros(Npar,1);
    for n = 1:Npar
        if IsTime(fdata(n).name);
            T(n,1) = -1;
        end
    end
    if any(T==-1)
        [void, ord] = sort(T);
        fdata = fdata(ord);
    end
    
    % Montagem das matrizes de trabalho
    
    PARAM = {fdata.name}';
    newDADOS = zeros(Nobs,Npar);
    
    try
        for n = 1:Npar
            load(fname,fdata(n).name);
            eval(['newDADOS(:,n) = ' fdata(n).name ';']); 
        end
    catch
        err = lasterr;
        newDADOS = [];
        PARAM = [];
        return
    end
    
    for n = 1:size(newDADOS,2)
        newDADOS(isinf(newDADOS(:,n)),n) = NaN;
    end
    
    % Formataçao da matriz PARAM
    PARAM = SetParamFormat(PARAM,maxparamlength);
    
    % Verificaçao de nomes repetidos
    CheckRepParam(PARAM);
    
    % Inclusao de No. OBS.
    N = length(PARAM);
    if ~strcmp(denumber(PARAM{N}),'No. OBS.')
        newDADOS(:,N+1) = (1:size(newDADOS,1))';
        PARAM{N+1} = [num2str(N+1,'%02d') '-No. OBS.'];
    end
    
catch
    err = lasterr;
    newDADOS = [];
    PARAM = [];
end
