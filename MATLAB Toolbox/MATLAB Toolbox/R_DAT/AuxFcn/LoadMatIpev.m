function [newDADOS, PARAM, err] = LoadMatIpev(fname,fpath,maxparamlength)
% Funçao para carregamento e validaçao de arquivo mat no padrao IPEV
%     DADOS: matriz numerica [Nobs x Npar]
%     PARAM: Matriz ou celula de texto com nomes dos parametros

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
    
    try
        fdata = whos('-file',fname);
    catch
        err = 'Arquivo com formato incompatível.';
        newDADOS = [];
        PARAM = [];
        return
    end
    
    if isempty(fdata)
        try
            load(fname);
            err = 'Arquivo vazio.';
        catch
            err = 'Arquivo mat corrompido ou de versão incompatível.';
        end
        newDADOS = [];
        PARAM = [];
        return
    end
    
    eD = 1 * ~isempty(strmatch('DADOS',{fdata.name},'exact'));
    eP = 2 * ~isempty(strmatch('PARAM',{fdata.name},'exact'));
    if ~eD || ~eP
        switch eD + eP
            case 0
                err = 'Matrizes DADOS e PARAM não encontradas.';
            case 1
                err = 'Matriz PARAM não encontrada.';
            case 2
                err = 'Matriz DADOS não encontrada.';
        end
        newDADOS = [];
        PARAM = [];
        return
    end
    
    try
        load(fname,'PARAM');
        D = load(fname,'DADOS');
        newDADOS = D.DADOS;
        clear D;
    catch
        err = lasterr;
        newDADOS = [];
        PARAM = [];
        return
    end
    
    if ~isempty(strmatch('UNIT',{fdata.name},'exact'));
        try
            load(fname,'UNIT');
        end
    end
    if ~isempty(strmatch('UNITS',{fdata.name},'exact'));
        try
            load(fname,'UNITS');
        end
    end
    
    % Cheque da matriz DADOS
    if ~isnumeric(newDADOS)
        err = 'Matriz DADOS deve ser numérica.';
        newDADOS = [];
        PARAM = [];
        return
    end
    
    if ~isa(newDADOS,'double') && ~isa(newDADOS,'single')
        newDADOS = double(newDADOS);
    end
    if isempty(newDADOS) || size(newDADOS,3) > 1 
        err = 'Matriz DADOS com formato incompatível.';
        newDADOS = [];
        PARAM = [];
        return
    end
    for n = 1:size(newDADOS,2)
        newDADOS(isinf(newDADOS(:,n)),n) = NaN;
    end
    
    % Cheque da matriz PARAM
    try
        char(PARAM);
    catch
        err = 'Matriz PARAM deve conter apenas texto.';
        newDADOS = [];
        PARAM = [];
        return
    end
    
    [nlin,ncol] = size(PARAM);
    if iscell(PARAM) && (nlin > 1 || ncol > 1)
        if ncol > nlin
            PARAM = PARAM';
        end
        if size(PARAM,2) > 1
            UNITS = char(PARAM(:,2));
        end
        PARAM = char(PARAM(:,1));
    end
    PARAM = char(PARAM);
    
    while isempty(deblank(PARAM(end,:))) && size(PARAM,1) > size(newDADOS,2)
        PARAM(end,:) = [];
    end
    
    if size(PARAM,1) ~= size(newDADOS,2)
        err = 'Tamanho da matriz PARAM incompatível com matriz DADOS.';
        newDADOS = [];
        PARAM = [];
        return
    end
    
    PARAM = PARAM(1:size(newDADOS,2),:);
    PARAM(~abs(PARAM)) = ' ';
    PARAM = deblank(PARAM);
    PARAM2 = PARAM;
    PARAM2(PARAM2==':') = ' ';
    PARAM2 = deblank(PARAM2);
    if isempty(PARAM) || isempty(PARAM2)
        err = 'Matriz PARAM vazia ou sem texto válido.';
        newDADOS = [];
        PARAM = [];
        return
    end
    
    %%%%%% Arquivo válido %%%%%%
    
    % Remoçao de prefixos de telemetria
    if any(any(PARAM==':'))
        load(which('DatOptions.mat'),'remprefix');
        if remprefix
            PARAM = cellstr(PARAM);
            for n = 1:length(PARAM)
                ix = find(PARAM{n}==':');
                if ~isempty(ix)
                    PARAM{n}(1:ix(end)) = [];
                end
            end
        end
    end
    
    if ischar(PARAM); PARAM = cellstr(PARAM); end
    
    PARAM = denumber(PARAM);
    
    % Colocaçao de "?" em parametros sem nome
    emptynames = [];
    for n = 1:length(PARAM)
        if isempty(PARAM{n})
            PARAM{n} = '?';
            emptynames = [emptynames n];
        end
    end
    if ~isempty(emptynames)
        if length(emptynames) > 150
            str = ['Encontrados ' num2str(length(emptynames)) ' parâmetros sem nome.'];
        elseif length(emptynames) > 1
            str = {'Parâmetros sem nome:',' ',CreateNumberList(emptynames)};
        else
            str = ['Parâmetro ' num2str(emptynames) ' sem nome.'];
        end
        uiwait(warndlg(str,'Aviso','modal')); drawnow;
    end
    
    % Inclusao de UNIT em PARAM
    if exist('UNIT','var') && ~exist('UNITS','var')
        UNITS = UNIT;
    end
    
    if exist('UNITS','var')
        PARAM = MergeParamUnits(PARAM,UNITS);
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

% --------------------------------------------------
function str = CreateNumberList(N)

str = '';

if ~isempty(N)
    for n = 1:length(N)
        if     n == 1
            str = num2str(N(n));
        elseif n == length(N)
            str = [str ' e ' num2str(N(n))];
        else
            str = [str ', ' num2str(N(n))];
        end
    end
    str = [str '.'];
end