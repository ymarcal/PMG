function varargout = RDAT_EditParam(varargin)
% RDAT_EDITPARAM M-file for RDAT_EditParam.fig
% Last Modified by GUIDE v2.5 17-Apr-2011 21:18:52

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RDAT_EditParam_OpeningFcn, ...
                   'gui_OutputFcn',  @RDAT_EditParam_OutputFcn, ...
                   'gui_LayoutFcn',  @RDAT_EditParam_LayoutFcn, ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    try
        gui_mainfcn(gui_State, varargin{:});
    catch
        errorchk;
    end
end

% ---------------------------------------------------------------------
function h = RDAT_EditParam_LayoutFcn(varargin)
% Função de layout inicial

h = openfig('RDAT_EditParam.fig','reuse','invisible');

% ---------------------------------------------------------------------
function RDAT_EditParam_OpeningFcn(hObject, eventdata, handles, varargin)
% Funçao de inicializaçao

ss = get(0,'ScreenSize');
ws = get(handles.window,'Position');
set(handles.window,'Position',[(ss(3)-ws(3))/2, (ss(4)-ws(4))/2, ws(3), ws(4)]);

bgc = getbuttoncolor(handles.window);
set(handles.remprefix_btn,'CData',geticon('DatButtons.mat','prefix',bgc));
set(handles.import_btn,   'CData',geticon('DatButtons.mat','import',bgc));
set(handles.help_btn,     'CData',geticon('DatButtons.mat','help',  bgc));

if ~isempty(varargin)
    PARAM = varargin{1};
    handles.maxparamlength = varargin{2};
else
    beep; uiwait(errordlg('Dados de entrada não fornecidos.','Erro','modal'));
    handles.ok = 0;
    guidata(hObject, handles);
    uiresume;
    return
end
PARAM = denumber(cellstr(PARAM));

handles.hlines = [...
        handles.text01 handles.text02 handles.text03 handles.text04 handles.text05,...
        handles.text06 handles.text07 handles.text08 handles.text09 handles.text10,...
        handles.text11 handles.text12 handles.text13 handles.text14 handles.text15,...
        handles.text16 handles.text17 handles.text18 handles.text19 handles.text20];
handles.hparam = [...
        handles.param01 handles.param02 handles.param03 handles.param04 handles.param05,...
        handles.param06 handles.param07 handles.param08 handles.param09 handles.param10,...
        handles.param11 handles.param12 handles.param13 handles.param14 handles.param15,...
        handles.param16 handles.param17 handles.param18 handles.param19 handles.param20];

path(path,cd);
handles.ok = 0;
handles.chg = 0;
handles.PARAM = PARAM;
handles.fpath = [pwd filesep];
guidata(hObject, handles);

initialize(hObject, eventdata, handles, 1);
uiwait(handles.window);

% ---------------------------------------------------------------------
function varargout = RDAT_EditParam_OutputFcn(hObject, eventdata, handles) 
% Funçao de saida

if handles.ok
    varargout{1} = SetParamNumbers(handles.PARAM);
else
    varargout{1} = [];
end
delete(handles.window);

% ---------------------------------------------------------------------
function param01_Callback(hObject, eventdata, handles)
updateparams(hObject, eventdata, handles, 1);
% ---------------------------------------------------------------------
function param02_Callback(hObject, eventdata, handles)
updateparams(hObject, eventdata, handles, 2);
% ---------------------------------------------------------------------
function param03_Callback(hObject, eventdata, handles)
updateparams(hObject, eventdata, handles, 3);
% ---------------------------------------------------------------------
function param04_Callback(hObject, eventdata, handles)
updateparams(hObject, eventdata, handles, 4);
% ---------------------------------------------------------------------
function param05_Callback(hObject, eventdata, handles)
updateparams(hObject, eventdata, handles, 5);
% ---------------------------------------------------------------------
function param06_Callback(hObject, eventdata, handles)
updateparams(hObject, eventdata, handles, 6);
% ---------------------------------------------------------------------
function param07_Callback(hObject, eventdata, handles)
updateparams(hObject, eventdata, handles, 7);
% ---------------------------------------------------------------------
function param08_Callback(hObject, eventdata, handles)
updateparams(hObject, eventdata, handles, 8);
% ---------------------------------------------------------------------
function param09_Callback(hObject, eventdata, handles)
updateparams(hObject, eventdata, handles, 9);
% ---------------------------------------------------------------------
function param10_Callback(hObject, eventdata, handles)
updateparams(hObject, eventdata, handles, 10);
% ---------------------------------------------------------------------
function param11_Callback(hObject, eventdata, handles)
updateparams(hObject, eventdata, handles, 11);
% ---------------------------------------------------------------------
function param12_Callback(hObject, eventdata, handles)
updateparams(hObject, eventdata, handles, 12);
% ---------------------------------------------------------------------
function param13_Callback(hObject, eventdata, handles)
updateparams(hObject, eventdata, handles, 13);
% ---------------------------------------------------------------------
function param14_Callback(hObject, eventdata, handles)
updateparams(hObject, eventdata, handles, 14);
% ---------------------------------------------------------------------
function param15_Callback(hObject, eventdata, handles)
updateparams(hObject, eventdata, handles, 15);
% ---------------------------------------------------------------------
function param16_Callback(hObject, eventdata, handles)
updateparams(hObject, eventdata, handles, 16);
% ---------------------------------------------------------------------
function param17_Callback(hObject, eventdata, handles)
updateparams(hObject, eventdata, handles, 17);
% ---------------------------------------------------------------------
function param18_Callback(hObject, eventdata, handles)
updateparams(hObject, eventdata, handles, 18);
% ---------------------------------------------------------------------
function param19_Callback(hObject, eventdata, handles)
updateparams(hObject, eventdata, handles, 19);
% ---------------------------------------------------------------------
function param20_Callback(hObject, eventdata, handles)
updateparams(hObject, eventdata, handles, 20);

% -------------------------------------------------------------------
function help_btn_Callback(hObject, eventdata, handles)
% Botao Ajuda

helpme('Ferramentas\editorparam');

% ---------------------------------------------------------------------
function ok_btn_Callback(hObject, eventdata, handles)
% Botao OK

if handles.chg
    button = questdlg('Deseja confirmar as alterações?','Confirmação','Sim','Não','Sim');
else
    button = 'Sim';
end
if strcmp(button,'Sim')
    handles.ok = 1;
    guidata(hObject, handles);
    uiresume;
end

% ---------------------------------------------------------------------
function cancel_btn_Callback(hObject, eventdata, handles)
% Botao Cancela

if handles.chg
    button = questdlg('Deseja descartar as alterações?','Confirmação','Sim','Não','Não');
else
    button = 'Sim';
end
if strcmp(button,'Sim')
    uiresume;
end

% --------------------------------------------------------------------
function window_KeyPressFcn(hObject, eventdata, handles)
% Acionamento de tecla do teclado

cc = get(handles.window,'CurrentCharacter');

if isempty(cc)
    return
end

switch abs(cc)
    
    case 31 % Down
        if strcmp(get(handles.slider,'Enable'),'on')
            v1 = get(handles.slider,'Min');
            v  = get(handles.slider,'Value');
            if v > v1
                set(handles.slider,'Value',v-1);
            end
            updatetable(hObject, eventdata, handles);
            drawnow;
        end
        
    case 30 % Up
        if strcmp(get(handles.slider,'Enable'),'on')
            v2 = get(handles.slider,'Max');
            v  = get(handles.slider,'Value');
            if v < v2
                set(handles.slider,'Value',v+1);
            end
            updatetable(hObject, eventdata, handles);
            drawnow;
        end
        
    case 13 % Enter
        ok_btn_Callback(hObject, eventdata, handles);
        
    case 27 % Esc
        cancel_btn_Callback(hObject, eventdata, handles);
        
    case {abs('i'),abs('I')} % Importar
        import_btn_Callback(hObject, eventdata, handles);
        
end

% ---------------------------------------------------------------------
function window_CloseRequestFcn(hObject, eventdata, handles)
% Funçao de fechamento da janela

cancel_btn_Callback(hObject, eventdata, handles);

% ---------------------------------------------------------------
function initialize(hObject, eventdata, handles, n1)
% Inicializar lista

N = length(handles.PARAM);

if nargin == 3
    s0   = get(handles.slider,'Value');
    max0 = get(handles.slider,'Max');
    if max0 >= 2
        s = max(1, N-19-max0+s0);
    else
        s = max(1, N-19);
    end
else
    s = max(1, N-19-n1+1);
end

vmax = max(1+1e-6, N-19);

if N <= 20
    stepv = [1 1e6];
    ven = 'off';
else
    stepv = [1 5]/(N-20);
    ven = 'on';
end

set(handles.slider,'Value',s,'SliderStep',stepv,'Min',1,'Max',vmax,'Enable',ven);

if N < 20
    set(handles.hparam(N+1:20),'Enable','off','BackgroundColor',get(handles.window,'Color'),'String','');
end
set(handles.hparam(1:min(20,N)),'Enable','on','BackgroundColor','w');

updatetable(hObject, eventdata, handles);

% ---------------------------------------------------------------
function updatetable(hObject, eventdata, handles)
% Atualizar lista

N = length(handles.PARAM);
n1 = max(1, N-get(handles.slider,'Value')-18);

for k = 1:min(20,N)
    n = n1+k-1;
    set(handles.hlines(k),'String',num2str(n));
    set(handles.hparam(k),'String',handles.PARAM{n});
end

% --------------------------------------------------------------------
function updateparams(hObject, eventdata, handles, lin)
% Atualizar nome de parametro

N = length(handles.PARAM);
n1 = max(1, N-get(handles.slider,'Value')-18);
n = n1+lin-1;

name = TrimParamName(get(handles.hparam(lin),'String'),handles.maxparamlength);

if isempty(name)
    beep; uiwait(errordlg('Nome do parâmetro não pode ser vazio.','Erro','modal')); drawnow;
    set(handles.hparam(lin),'String',handles.PARAM{n});
    return
end

if ~strcmp(name,handles.PARAM{n});
    handles.PARAM{n} = name;
    handles.chg = 1;
    guidata(hObject, handles);
end
set(handles.hparam(lin),'String',name);

% --------------------------------------------------------------------
function slider_Callback(hObject, eventdata, handles)
% Barra de rolagem

set(handles.slider,'Value',round(get(handles.slider,'Value')));
updatetable(hObject, eventdata, handles);

% --------------------------------------------------------------------
function remprefix_btn_Callback(hObject, eventdata, handles)
% Remover prefixos de telemetria

PARAM = handles.PARAM;

if any(any(char(PARAM)==':'))
    
    button = questdlg('Deseja remover os prefixos de telemetria?','Confirmação','Sim','Não','Sim'); drawnow;
    if strcmp(button,'Sim')
        for n = 1:length(PARAM)
            ix = find(PARAM{n}==':');
            if ~isempty(ix)
                PARAM{n}(1:ix(end)) = [];
                if isempty(PARAM{n})
                    PARAM{n} = '?';
                end
            end
        end
        
        handles.PARAM = PARAM;
        handles.chg = 1;
        guidata(hObject, handles);
        updatetable(hObject, eventdata, handles);
    end
else
    uiwait(warndlg('Não há prefixos de telemetria.','Aviso','modal')); drawnow;
end

% --------------------------------------------------------------------
function import_btn_Callback(hObject, eventdata, handles)
% Importar lista de parametros

oldPARAM = handles.PARAM;

[fname,fpath,ind] = uigetfile({'*.txt', 'Arquivo de texto (*.txt)'; ...
        '*.xls','Planilha MS Excel (*.xls)'}, 'Indique o arquivo com a lista de nomes de parâmetros',handles.fpath); drawnow;

if ~ischar(fname)
    return
end

set(handles.window,'Pointer','watch');

switch ind
    case 1 % txt
        
        try
            [void, PARAM] = txtread([fpath,fname],char(254));
        catch
            beep; uiwait(errordlg('Arquivo com formato incompatível.','Erro','modal')); drawnow;
            set(handles.window,'Pointer','arrow');
            return
        end
        
    case 2 % xls
        
        try
            [void, PARAM] = xlsread([fpath,fname]);
        catch
            beep; uiwait(errordlg('Arquivo com formato incompatível.','Erro','modal')); drawnow;
            set(handles.window,'Pointer','arrow');
            return
        end
        
end

if isempty(PARAM)
    beep; uiwait(errordlg('Não foram encontrados nomes de parâmetros no arquivo.','Erro','modal')); drawnow;
    set(handles.window,'Pointer','arrow');
    return
end

[nlin,ncol] = size(PARAM);
for n = 1:nlin
    for m = 1:ncol
        if ~ischar(PARAM{n,m})
            PARAM{n,m} = '';
        end
    end
end

if nlin > 1 || ncol > 1
    if ncol > nlin
        PARAM = PARAM';
    end
    if size(PARAM,2) > 1
        UNITS = char(PARAM(:,2));
    end
    PARAM = char(PARAM(:,1));
end

if exist('UNITS','var')
    PARAM = MergeParamUnits(PARAM,UNITS);
end
PARAM = cellstr(denumber(PARAM));

for n = length(PARAM):-1:1
    if isempty(deblank(PARAM{n}))
        PARAM(n) = [];
    end
end

if strcmp(PARAM{end},'No. OBS.')
    PARAM(end) = [];
end

if length(PARAM) ~= length(oldPARAM)
    beep; uiwait(errordlg('Tamanho da matriz PARAM incompatível com matriz DADOS.','Erro','modal')); drawnow;
    set(handles.window,'Pointer','arrow');
    return
end

button = questdlg('Deseja alterar todos os nomes de parâmetros?','Confirmação','Sim','Não','Não'); drawnow;
if strcmp(button,'Sim');
    
    handles.PARAM = PARAM;
    handles.chg = 1;
    handles.fpath = fpath;
    guidata(hObject, handles);
    
    initialize(hObject, eventdata, handles, 1);
    set(handles.window,'Pointer','arrow');
    
end
