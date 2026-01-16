function varargout = acra_load(varargin)
% ACRA_LOAD    Carrega dados salvos pelo sistema Acra KAM-500.
%       ACRA_LOAD gera um matão a partir dos dados salvos pelo sistema.
%
%       S = ACRA_LOAD retorna uma string S contendo o caminho completo do
%       matão gerado por ACRA_LOAD.
%

versao = 1.35;
%       VERSÃO 1.35
%
%       What's new (v1.35):
%           - (LEO) posicionamento da janela no centro da tela
%           - (LEO) vários novos testes de execução e mensagens de erro
%
%       What's new (v1.3):
%           - novos tipos de parametros, provenientes do TCG102: tcgdoy,
%           tcgns, tcgew, tcgsv, tcgsu, tcglat, tcglon, tcgvel, tcghdg,
%           tcgalt, tcgpdop, tcghdop, tcgvdop
%           - teste de erros no carregamento de dados
%           - (LEO) bug no argumento de saida sem processar dados
%           - (LEO) acentuaçoes faltando (outras aparecerao...)
%           - (LEO) padronizaçao na separaçao e comentario de funçoes
%
%       What's new (v1.2):
%           - nao ha mais dados em count; se desejado, devem ser colocados
%           na planilha 'formato'
%           - novo tipo de parametro ('time'): TempoSAD virou parametro
%           gerado pela planilha 'formato' (gera tempo a partir de HI_TIME,
%           LO_TIME e MICRO_TIME; serve para BCU, TCG, DSI)
%
%       What's new (v1.15):
%           - suporte a parametros do ICD do A-1 (left justified) - numero
%           de bits em c2 da planilha 'formato'
%
%       What's new (v1.1):
%           - controle de revisões (a partir da v0.8)
%           - versão colocada no título
%           - utiliza 'uiwait' apenas se houver argumento de saída
%           - retirada função 'counts_Callback' (sem função)
%           - corrigida 'tag' repetida em 'tirar' e 'fechar'
%           - função 'cell2str' incorporada (pra evitar dor de cabeça), já
%           que não existe no MATLAB 6.5
%           - novos tipos de parâmetros ('bit1', 'bit2', 'bit3')
%           - função que carrega dados separada do callback de 'gerar'
%           - botões desabilitados durante carregamento dos dados
%
%       What's new (v1.0):
%           - permite escolher o nome do matão
%           - retorna o caminho do matão salvo (possível interface com
%           R_DAT)
%           - limitação: os parâmetros de tempo devem ter a menor
%           amostragem possível (1 por frame)
%           - argumento 'exact' em 'strmatch' (função 'cal_dados') evita
%           problemas com parâmetros de nomes parecidos (LAT e LAT_F)
%
%       What's new (v0.99):
%           - corrigida interpolação/extrapolação no tempo
%
%       What's new (v0.98):
%           - bug: texto dos caminhos não era apagado ao não selecionar
%           arquivos
%           - colocada condição para incluir dados em counts
%           - bug: 'interp_nan' não era utilizada para dados em UE
%           - incluído MICRO_TIME no cálculo do tempo
%           - dúvidas em relação a 'cell2str'
%
%       What's new (v0.97):
%           - botão 'Gerar' inicialmente desabilitado
%           - retirado checkbox 'incluir counts'
%           - incluído botão 'OK' na janela de seleção
%           - retirados comentários da função 'TwosComplement'
%
%       What's new (v0.95):
%           - bug: counts incluídos com 'incluir counts' não selecionado
%
%       What's new (v0.9):
%           - nova função 'TwosComplement' (pois 'typecast' não existe no
%           MATLAB 6.5)
%           - mudanças ao carregar as planilhas ('xlsread' do MATLAB 6.5
%           não retorna argumento 'raw')
%
%       What's new (v0.8):
%           - GUI construída no próprio programa (sem GUIDE)
%           - opção de incluir parâmetros em counts
%           - seleção de arquivos de formato e calibração
%           - novos tipos de parâmetros ('cp2', 'cp2w', 'bcd', 'bcd2')
%           - opção de salvar apenas dados em counts
%

%  Initialization tasks

ss = get(0,'ScreenSize');

%  Construct the components
h01 = figure('Name',['ACRA LOAD v' num2str(versao)],'Tag','main','MenuBar','none','NumberTitle','off','Position',[(ss(3)-500)/2 (ss(4)-400)/2 500 400],'Resize','off','Color',get(0,'defaultUicontrolBackgroundColor'));
uicontrol(h01,'Style','text','Tag','text1','String','Dados','Position',[10 365 60 20],'HorizontalAlignment','Left');
uicontrol(h01,'Style','edit','Tag','caminho_dados','HorizontalAlignment','left','Position',[70 370 340 20],'Enable','inactive');
uicontrol(h01,'Style','pushbutton','Tag','dados','String','Abrir','Callback',@dados_Callback,'Position',[420 370 70 20]);
uicontrol(h01,'Style','text','Tag','text2','String','Formato','Position',[10 335 60 20],'HorizontalAlignment','Left');
uicontrol(h01,'Style','edit','Tag','caminho_formato','HorizontalAlignment','left','Position',[70 340 340 20],'Enable','inactive');
uicontrol(h01,'Style','pushbutton','Tag','formato','String','Abrir','Callback',@formato_Callback,'Position',[420 340 70 20]);
uicontrol(h01,'Style','text','Tag','text3','String','Calibração','Position',[10 305 60 20],'HorizontalAlignment','Left');
uicontrol(h01,'Style','edit','Tag','caminho_calib','HorizontalAlignment','left','Position',[70 310 340 20],'Enable','inactive');
uicontrol(h01,'Style','pushbutton','Tag','calib','String','Abrir','Callback',@calib_Callback,'Position',[420 310 70 20]);
uicontrol(h01,'Style','text','Tag','text5','String','Mensagens','Position',[10 270 60 20],'HorizontalAlignment','Left');
uicontrol(h01,'Style','listbox','Tag','msg','Position', [10 10 480 260],'Enable','inactive');
uicontrol(h01,'Style','pushbutton','Tag','gerar','String','Gerar','Enable','off','Callback',@gerar_Callback,'Position',[420 280 70 20]);

%  Initialization tasks
handles = guihandles;
handles.dir0 = cd;
handles.dir_atual = cd;
handles.dir_dados = 0;
handles.formato_f = 0;
handles.calib_f = 0;
handles.matao = 0;

warning off MATLAB:divideByZero

guidata(handles.main,handles);

if nargout == 1
    set(handles.main,'WindowStyle','modal');
    uiwait;
    if ishandle(handles.main)
        handles = guidata(handles.main);
        varargout{1} = handles.matao;
        delete(handles.main);
    else
        varargout{1} = [];
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function dados_Callback(hObject, eventdata)
handles = guidata(gcbo);

handles.dir_dados = uigetdir(handles.dir_atual, 'Escolha o diretório dos arquivos de dados');
if(handles.dir_dados)
    handles.dir_atual = [handles.dir_dados filesep];
    set(handles.caminho_dados,'String', handles.dir_dados);
    set(handles.gerar, 'Enable', 'on');
else
    set(handles.caminho_dados,'String', '');
    set(handles.gerar, 'Enable', 'off');
end

guidata(hObject,handles);

% ---------------------------------------------------------------------
function formato_Callback(hObject, eventdata)
handles = guidata(gcbo);

[handles.formato_f, handles.formato_d] = uigetfile({'*.xls', 'Excel (*.xls)'}, 'Escolha o arquivo de formato de dados',handles.dir_atual);
if(handles.formato_f)
    handles.dir_atual = handles.formato_d;
    set(handles.caminho_formato,'String', [handles.formato_d, handles.formato_f]);
else
    set(handles.caminho_formato,'String', '');
end

guidata(hObject,handles);

% ---------------------------------------------------------------------
function calib_Callback(hObject, eventdata)
handles = guidata(gcbo);

[handles.calib_f, handles.calib_d] = uigetfile({'*.xls', 'Excel (*.xls)'}, 'Escolha o arquivo de coeficientes de calibração',handles.dir_atual);
if(handles.calib_f)
    handles.dir_atual = handles.calib_d;
    set(handles.caminho_calib,'String', [handles.calib_d, handles.calib_f]);
else
    set(handles.caminho_calib,'String', '');
end

guidata(hObject,handles);

% ---------------------------------------------------------------------
function gerar_Callback(hObject, eventdata)
handles = guidata(gcbo);

habilitar(handles, 'off');

try
    handles = gerar_dados(handles);
catch
    set(handles.msg, 'String', strvcat(get(handles.msg, 'String'),'Erro ao gerar matriz DADOS.'),'Value',size(get(handles.msg, 'String'),1)+1);
    cd(handles.dir0);
    habilitar(handles, 'on');
    return
end

guidata(hObject,handles);
habilitar(handles, 'on');

if ~isempty(handles.matao) && ischar(handles.matao)
    uiresume;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Utility functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function S = cell2str(C,p,s,d)
% Converts a cell array with numbers and text into a char array
%    p: precision or number format string
%    s: number of separating blanks
%    d: aditional delimiter (string)

if isempty(C)
    S = '';
    return
end

switch nargin
    case 1
        p = 6;
        s = 2;
        d = '';
    case 2
        s = 2;
        d = '';
    case 3
        d = '';
end

[N, M] = size(C);
for m = 1:M
    for n = 1:N
        if isempty(C{n,m})
            C{n,m} = ' ';
        elseif isnumeric(C{n,m})
            C{n,m} = num2str(C{n,m},p);
        end
        if m ~= M
            C{n,m} = [C{n,m} d];
        end
    end
end

S = [];

for m = 1:M
    col = char(C{:,m});
    if m > 1
        col = [char(32*ones(N,s)) col];
    end
    S   = [S col];
end

% ---------------------------------------------------------------------
function habilitar(handles, en)
% Habilita ou desabilita botões da interface, para evitar cliques acidentais

if strcmp(en, 'on')
    set(handles.main,'Pointer','arrow');
else
    set(handles.main,'Pointer','watch');
end
set(handles.dados,'Enable',en);
set(handles.formato,'Enable',en);
set(handles.calib,'Enable',en);
set(handles.gerar,'Enable',en);

% ---------------------------------------------------------------------
function t = tempo_sad(hi_time, lo_time, mi_time)
% Gera tempo (BCU, TCG, DSI) a partir de HI_TIME, LO_TIME e MICRO_TIME (sistema Acra)

mil_mil_seg = bitand(mi_time, bin2dec('1111'));
cen_mil_seg = bitand(bitshift(mi_time, -4), bin2dec('1111'));
dec_mil_seg = bitand(bitshift(mi_time, -8), bin2dec('1111'));
mil_seg = bitand(bitshift(mi_time, -12), bin2dec('1111'));

cen_seg = bitand(lo_time, bin2dec('1111'));
dec_seg = bitand(bitshift(lo_time, -4), bin2dec('1111'));
seg = bitand(bitshift(lo_time, -8), bin2dec('1111'));
dez_seg = bitand(bitshift(lo_time, -12), bin2dec('111'));

min = bitand(hi_time, bin2dec('1111'));
dez_min = bitand(bitshift(hi_time, -4), bin2dec('111'));
hor = bitand(bitshift(hi_time, -7), bin2dec('1111'));
dez_hor = bitand(bitshift(hi_time, -11), bin2dec('11'));

t = ([0.000001 0.00001 0.0001 0.001 0.01 0.1 1 10 60 600 3600 36000] * double([mil_mil_seg cen_mil_seg dec_mil_seg mil_seg cen_seg dec_seg seg dez_seg min dez_min hor dez_hor])')';

% ---------------------------------------------------------------------
function lat = tcg_lat(lhi, llo, lmm)
% Gera latitude a partir de LatitudeHi, LatitudeLo e LatitudeMicroMinutes

deg = bitand(bitshift(lhi, -8), bin2dec('01111')) + 10 * bitand(bitshift(lhi, -12), bin2dec('01111'));
min = bitand(lhi, bin2dec('01111')) + 10 * bitand(bitshift(lhi, -4), bin2dec('01111'));
dec_min = bitand(bitshift(llo, -12), bin2dec('1111'));
cen_min = bitand(bitshift(llo, -8), bin2dec('1111'));
mil_min = bitand(bitshift(llo, -4), bin2dec('1111'));
dec_mil_min = bitand(llo, bin2dec('1111'));
cen_mil_min = bitand(lmm, bin2dec('1111'));

lat = ([1 1/60 1/600 1/6000 1/60000 1/600000 1/6000000] * double([deg min dec_min cen_min mil_min dec_mil_min cen_mil_min])')';

% ---------------------------------------------------------------------
function lon = tcg_lon(lhi, llo, lmm)
% Gera longitude a partir de LongitudeHi, LongitudeLo e LongitudeMicroMinutes

deg = bitand(lhi, bin2dec('01111')) + 10 * bitand(bitshift(lhi, -4), bin2dec('01111')) + 100 * bitand(bitshift(lhi, -8), bin2dec('01111'));
min = bitand(bitshift(llo, -8), bin2dec('01111')) + 10 * bitand(bitshift(llo, -12), bin2dec('01111'));
dec_min = bitand(bitshift(llo, -4), bin2dec('1111'));
cen_min = bitand(llo, bin2dec('1111'));
mil_min = bitand(bitshift(lmm, -8), bin2dec('1111'));
dec_mil_min = bitand(bitshift(lmm, -4), bin2dec('1111'));
cen_mil_min = bitand(lmm, bin2dec('1111'));

lon = ([1 1/60 1/600 1/6000 1/60000 1/600000 1/6000000] * double([deg min dec_min cen_min mil_min dec_mil_min cen_mil_min])')';

% ---------------------------------------------------------------------
function y = interp_nan(x, n)
% Interpolação de vetores com NaN
% n deve ser inteiro

if n ~= 1
    y = NaN * ones(n * size(x,1), size(x,2));
    i = 1:size(x,1);
    y(n*(i-1)+1,:) = x(i,:);
else
    y = x;
end

% ---------------------------------------------------------------------
function n = max_samples(fpath, files)
% Verifica qual a variável com o maior número de amostras dentre os
% arquivos selecionados na planilha de formato

files = files(:);

n = 0;

for i = 1:length(files)
    if exist([fpath filesep files{i} '.mat'],'file')
        s = whos('-file',[fpath filesep files{i} '.mat']);
        if size(s,1) == 1
            n = max(n, s.size(2));
        end
    end
end

% ---------------------------------------------------------------------
function value = TwosComplement(x, numBits)
% Calcula complemento de 2

msb = bitshift(x, -(numBits - 1) );

value = - double(msb) .* (double(bitcmp(x, numBits)) + 1) + double(~msb) .* double(x);

% ---------------------------------------------------------------------
function var = carrega_dados(calib, nome)
% Carrega matao com dados e aplica curva de calibraçao da planilha

nlinha = strmatch(nome, calib(:,1),'exact'); %% Falta testar caso nao existente

if(size(nlinha, 1) == 0)
    var = [];
else
	linha = calib(nlinha, :);
	matao = char(cell2str(linha(1)));
	coef = cell2mat(linha(2:11));
    
    try
        load([deblank(matao) '.mat'], '-mat');
        var = eval(matao)';
        var = polyval(coef, double(var));
    catch
        var = [];
    end
end

% ---------------------------------------------------------------------
function var0 = cal_dados(form, calib, nmax)
% Retorna a i-ésima variável calculada, assumindo que se está no diretório
% dos dados. "form" é a linha do parâmetro a ser calculado, e "calib" é
% calib_raw completa

nome = cell2str(form(1));
tipo = cell2str(form(2));
var1 = cell2str(form(3));
var2 = cell2str(form(4));
var3 = cell2str(form(5));
c0 = cell2mat(form(6));
c1 = cell2mat(form(7));
c2 = cell2mat(form(8));

var1 = carrega_dados(calib, var1);

switch tipo
    
    % Parametro de tempo ACRA (BCU, TCG, DSI)
    case 'time'
        var2 = carrega_dados(calib, var2);
        var3 = carrega_dados(calib, var3);
        
        % Gera o tempo SAD inicial, que é o início de cada acquisition cycle
        var0 = tempo_sad(var1, var2, var3);
        nt = size(var0,1);
        % Interpola linearmente o tempo SAD utilizando o parâmetro de maior taxa de amostragem
        var0 = interp1(1:nt, var0, linspace(1, nt+1-nt/nmax, nmax), 'linear', 'extrap')';
    
    % Parametros em complemento de 2    
    case 'cp2'
        var0 = TwosComplement(var1, 16);
    case 'cp2w'
        var2 = carrega_dados(calib, var2);
        var0 = TwosComplement(double(var1) * 2^16 + double(var2), 32);
    
    % Parametros do barramento do A-1
    case 'cp2a1'
        var1 = bitshift(var1, c2-16);
        var0 = TwosComplement(var1, c2);
    case 'cp2wa1' % Apenas LAT e LON
        var2 = carrega_dados(calib, var2);
        var1 = bitand(var1, bin2dec('1111110000000000'));
        var0 = TwosComplement(double(var1) * 2^6 + double(var2), 22);
    
    % Parametros em bits e bcd
    case 'bit1'
        var0 = bitand(bitshift(var1, -c2), bin2dec('00001'));
    case 'bit2'
        var0 = bitand(bitshift(var1, -c2), bin2dec('00011'));
    case 'bit3'
        var0 = bitand(bitshift(var1, -c2), bin2dec('00111'));
    case 'bcd'
        var0 = bitand(bitshift(var1, -c2), bin2dec('01111'));
    case 'bcd2'
        var0 = bitand(bitshift(var1, -c2), bin2dec('01111')) + 10 * bitand(bitshift(var1, -(c2+4)), bin2dec('01111'));
    
    % Parametros do TCG102 (GPS)
    case 'tcgdoy'
        var0 = bitand(var1, bin2dec('01111')) + 10 * bitand(bitshift(var1, -4), bin2dec('01111')) + 100 * bitand(bitshift(var1, -8), bin2dec('00111'));
    case 'tcgns'
        var0 = bitand(bitshift(var1, -10), bin2dec('00001'));
    case 'tcgew'
        var0 = bitand(bitshift(var1, -9), bin2dec('00001'));
    case 'tcgsv'
        var0 = bitand(bitshift(var1, -4), bin2dec('01111'));
    case 'tcgsu'
        var0 = bitand(var1, bin2dec('01111'));
    case 'tcglat'
        var2 = carrega_dados(calib, var2);
        var3 = carrega_dados(calib, var3);
        
        var0 = tcg_lat(var1, var2, var3);
    case 'tcglon'
        var2 = carrega_dados(calib, var2);
        var3 = carrega_dados(calib, var3);
        
        var0 = tcg_lon(var1, var2, var3);
    case 'tcgvel' % kt e kph
        var0 = bitand(var1, bin2dec('01111')) + 10 * bitand(bitshift(var1, -4), bin2dec('01111')) + 100 * bitand(bitshift(var1, -8), bin2dec('01111')) + 1000 * bitand(bitshift(var1, -12), bin2dec('01111'));
    case 'tcghdg'
        var2 = carrega_dados(calib, var2);
        
        var0 = 0.01 * bitand(var2, bin2dec('01111')) + 0.1 * bitand(bitshift(var2, -4), bin2dec('01111')) + bitand(var1, bin2dec('01111')) + 10 * bitand(bitshift(var1, -4), bin2dec('01111')) + 100 * bitand(bitshift(var1, -8), bin2dec('00011'));
    case 'tcgalt'
        var2 = carrega_dados(calib, var2);
        
        var0 = bitand(var2, bin2dec('01111')) + 10 * bitand(bitshift(var2, -4), bin2dec('01111')) + 100 * bitand(bitshift(var2, -8), bin2dec('01111')) + 1000 * bitand(bitshift(var2, -12), bin2dec('01111')) + 10000 * bitand(var1, bin2dec('01111'));
    case 'tcgpdop'
        var0 = bitand(bitshift(var1, -8), bin2dec('01111'));
    case 'tcghdop'
        var0 = bitand(bitshift(var1, -4), bin2dec('01111'));
    case 'tcgvdop'
        var0 = bitand(var1, bin2dec('01111'));
        
    % Binario comum (counts)
    case 'bin'
        var0 = var1;
        
    % Tipos nao reconhecido (assume binario)
    otherwise
        var0 = var1;
        
end

var0 = interp_nan(var0, nmax/size(var0, 1));
var0 = c0 + c1 * double(var0);

% ---------------------------------------------------------------------
function handles = gerar_dados(handles)
% Gera dados calibrados e salva no matão

set(handles.msg, 'String', strvcat(get(handles.msg, 'String'),' '),'Value',size(get(handles.msg, 'String'),1)+1);

if ~ischar(handles.dir_dados)
    set(handles.msg, 'String', strvcat(get(handles.msg, 'String'),'Selecione antes o diretório dos dados.'),'Value',size(get(handles.msg, 'String'),1)+1);
    return;
end
if ~ischar(handles.formato_f)
    set(handles.msg, 'String', strvcat(get(handles.msg, 'String'),'Selecione antes o arquivo de formato.'),'Value',size(get(handles.msg, 'String'),1)+1);
    return
end
if ~ischar(handles.calib_f)
    set(handles.msg, 'String', strvcat(get(handles.msg, 'String'),'Selecione antes o arquivo de calibração.'),'Value',size(get(handles.msg, 'String'),1)+1);
    return
end

try
    [a,b] = xlsread(get(handles.caminho_formato,'String'));
    form_raw = b;
    if size(b,1) == size(a,1)
        form_raw(2:end,6:8) = num2cell(a(2:end,1:3));
    else
        form_raw(2:end,6:8) = num2cell(a(:,1:3));
    end
catch
    set(handles.msg, 'String', strvcat(get(handles.msg, 'String'),'Arquivo de formato incompatível.'),'Value',size(get(handles.msg, 'String'),1)+1);
    return
end

try
    [a,b] = xlsread(get(handles.caminho_calib,'String'));
    calib_raw = b;
    calib_raw(2:end,2:11) = num2cell(a(:,1:10));
    clear a b
catch
    set(handles.msg, 'String', strvcat(get(handles.msg, 'String'),'Arquivo de calibração incompatível.'),'Value',size(get(handles.msg, 'String'),1)+1);
    return
end

handles.np = size(form_raw, 1) - 1;

cd(handles.dir_dados);

handles.nmax = max_samples(handles.dir_dados, form_raw(2:end,3:5));

% Inicializa a matriz DADOS (velocidade) e PARAM
try
    DADOS = double(zeros(handles.nmax, handles.np));
catch
    set(handles.msg, 'String', strvcat(get(handles.msg, 'String'),'Número de amostras muito grande.', lasterr));
    set(handles.msg, 'String', strvcat(get(handles.msg, 'String'),'Para tentar diminuir o número de amostras, verifique se há parâmetros com taxa de amostragem',...
                      'muito alta (como VÍDEO) e que não serão utilizados e retire-os do diretório dos dados. Ainda,',...
                      'tente separar os parâmetros em duas planilhas de formato distintas (sendo então necessários',...
                      'dois processamentos), para diminuir o número de colunas da matriz DADOS.'),'Value',size(get(handles.msg, 'String'),1)+4);
    cd(handles.dir0);
    return
end
PARAM = [];

vazio = [];

% Salva dados em UE selecionados
if handles.np
    for i=1:handles.np
        try
            DADOS(:, i) = cal_dados(form_raw(i+1,:), calib_raw, handles.nmax);
        catch
            vazio = [vazio; i];
            if                                  isempty(strmatch(form_raw{i+1,3}, calib_raw(:,1),'exact'))
                set(handles.msg, 'String', strvcat(get(handles.msg, 'String'),['Palavra ' cell2str(form_raw(i+1,3)) ' não definida na planilha de calibração.']),'Value',size(get(handles.msg, 'String'),1)+1);
            elseif ~isempty(form_raw{i+1,4}) && isempty(strmatch(form_raw{i+1,4}, calib_raw(:,1),'exact'))
                set(handles.msg, 'String', strvcat(get(handles.msg, 'String'),['Palavra ' cell2str(form_raw(i+1,4)) ' não definida na planilha de calibração.']),'Value',size(get(handles.msg, 'String'),1)+1);
            elseif ~isempty(form_raw{i+1,5}) && isempty(strmatch(form_raw{i+1,5}, calib_raw(:,1),'exact'))
                set(handles.msg, 'String', strvcat(get(handles.msg, 'String'),['Palavra ' cell2str(form_raw(i+1,5)) ' não definida na planilha de calibração.']),'Value',size(get(handles.msg, 'String'),1)+1);
            elseif ~isempty(form_raw{i+1,3}) && ~exist([handles.dir_dados filesep form_raw{i+1,3} '.mat'],'file')
                set(handles.msg, 'String', strvcat(get(handles.msg, 'String'),['Arquivo ' form_raw{i+1,3} ' não encontrado no diretório.']),'Value',size(get(handles.msg, 'String'),1)+1);
            elseif ~isempty(form_raw{i+1,4}) && ~exist([handles.dir_dados filesep form_raw{i+1,4} '.mat'],'file')
                set(handles.msg, 'String', strvcat(get(handles.msg, 'String'),['Arquivo ' form_raw{i+1,4} ' não encontrado no diretório.']),'Value',size(get(handles.msg, 'String'),1)+1);
            elseif ~isempty(form_raw{i+1,5}) && ~exist([handles.dir_dados filesep form_raw{i+1,5} '.mat'],'file')
                set(handles.msg, 'String', strvcat(get(handles.msg, 'String'),['Arquivo ' form_raw{i+1,5} ' não encontrado no diretório.']),'Value',size(get(handles.msg, 'String'),1)+1);
            end    
            set(handles.msg, 'String', strvcat(get(handles.msg, 'String'),['Variável ' cell2str(form_raw(i+1, 1)) ' não foi adicionada à matriz DADOS.']),'Value',size(get(handles.msg, 'String'),1)+1);
        end
    end
    
    PARAM = strvcat(PARAM, strvcat(form_raw(2:end,1)));
end

DADOS(:,vazio) = [];
PARAM(vazio,:) = [];

if isempty(DADOS)
    set(handles.msg, 'String', strvcat(get(handles.msg, 'String'),'Erro na criação da matriz DADOS: Matriz vazia.'),'Value',size(get(handles.msg, 'String'),1)+1);
    cd(handles.dir0);
    return
end

cd(handles.dir0);

% Salvando matao
[handles.matao_f, handles.matao_d] = uiputfile({'*.mat', 'Matão (*.mat)'}, 'Escolha o arquivo de dados (matão) a ser salvo');
if ischar(handles.matao_f)
    if length(handles.matao_f)>4 && ~strcmpi(handles.matao_f(end-3:end),'.mat')
        handles.matao_f = [handles.matao_f '.mat'];
    end
	save([handles.matao_d handles.matao_f],'DADOS','PARAM');
	clear DADOS PARAM
    handles.matao = [handles.matao_d handles.matao_f];
	set(handles.msg, 'String', strvcat(get(handles.msg, 'String'),['Arquivo ' handles.matao_f ' gerado com sucesso.']),'Value',size(get(handles.msg, 'String'),1)+1);
end

cd(handles.dir0);
