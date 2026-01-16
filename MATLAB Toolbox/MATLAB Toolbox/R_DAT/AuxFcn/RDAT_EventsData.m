function varargout = RDAT_EventsData(varargin)
% RDAT_EVENTSDATA M-file for RDAT_EventsData.fig
% Last Modified by GUIDE v2.5 03-Dec-2010 13:49:49

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RDAT_EventsData_OpeningFcn, ...
                   'gui_OutputFcn',  @RDAT_EventsData_OutputFcn, ...
                   'gui_LayoutFcn',  @RDAT_EventsData_LayoutFcn, ...
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

% ---------------------------------------------------------------
function h = RDAT_EventsData_LayoutFcn(varargin)
% Função de layout inicial

h = openfig('RDAT_EventsData.fig','reuse','invisible');

% ---------------------------------------------------------------
function RDAT_EventsData_OpeningFcn(hObject, eventdata, handles, varargin)
% Funçao de abertura

ss = get(0,'ScreenSize');
ws = get(handles.window,'Position');
set(handles.window,'Position',[(ss(3)-ws(3))/2, (ss(4)-ws(4))/2-2, ws(3), ws(4)]);

bgc = getbuttoncolor(handles.window);
set(handles.parsel_btn,'CData',geticon('DatButtons.mat','list',bgc));
set(handles.help_btn,  'CData',geticon('DatButtons.mat','help',bgc));

if length(varargin) == 2
    PARAM     = varargin{1};
    paramlist = varargin{2};
else
    PARAM     = {};
    paramlist = [];
end

formatlist = {'Planilha Excel (.xls)','Arquivo de texto (.txt)','Arquivo de texto (.dat)','Arquivo MATLAB (.mat)'};
methodlist = {'Linear','Vizinho','Spline','Cúbico'};
invlist    = {'Manter','Excluir','NaN'};
seplist    = {'Espaço','Tabulação','Vírgula','Ponto e vírgula'};
preclist   = cellstr(num2str2((16:-1:1)'));

set(handles.fileformat,'String',formatlist);
set(handles.method,'String',methodlist);
set(handles.invalid,'String',invlist);
set(handles.separator,'String',seplist);
set(handles.precision,'String',preclist,'Value',9);
set(handles.param_txt,'String',['Parâmetros: ' num2str(length(paramlist))],'UserData',paramlist);

handles.PARAM = PARAM;
guidata(hObject, handles);

fileformat_Callback(hObject, eventdata, handles);
uiwait(handles.window);

% ---------------------------------------------------------------
function varargout = RDAT_EventsData_OutputFcn(hObject, eventdata, handles)
% Funçao de saida

if handles.ok
    varargout{1}  = get(handles.fileformat,'Value');
    varargout{2}  = get(handles.method,    'Value');
    varargout{3}  = get(handles.invalid,   'Value');
    varargout{4}  = get(handles.separator, 'Value');
    varargout{5}  = get(handles.precision, 'Value');
    varargout{6}  = get(handles.val_chk,   'Value');
    varargout{7}  = get(handles.num_chk,   'Value');
    varargout{8}  = get(handles.time_chk,  'Value');
    varargout{9}  = get(handles.descr_chk, 'Value');
    varargout{10} = get(handles.header_chk,'Value');
    varargout{11} = get(handles.param_txt, 'UserData');
else
    varargout = {[],[],[],[],[],[],[],[],[],[],[]};
end
delete(handles.window);

% -------------------------------------------------------------------
function help_btn_Callback(hObject, eventdata, handles)
% Botao Ajuda

helpme('Ferramentas\obtencaodadoseventos');

% ---------------------------------------------------------------
function ok_btn_Callback(hObject, eventdata, handles)
% Botao OK

button = questdlg('Deseja confirmar a seleção?','Confirmação','Sim','Não','Não');
if strcmp(button,'Sim')
    handles.ok = 1;
    guidata(hObject, handles);
    uiresume;
end

% ---------------------------------------------------------------
function cancel_btn_Callback(hObject, eventdata, handles)
% Botao Cancela

button = questdlg('Deseja cancelar a operação?','Confirmação','Sim','Não','Não');
if strcmp(button,'Sim')
    handles.ok = 0;
    guidata(hObject, handles);
    uiresume;
end

% ---------------------------------------------------------------
function parsel_btn_Callback(hObject, eventdata, handles)
% Seleçao dos parametros desejados

paramlist = RDAT_ParamSel(handles.PARAM,get(handles.param_txt,'UserData')); drawnow;

if ~isempty(paramlist)
    set(handles.param_txt,'String',['Parâmetros: ' num2str(length(paramlist))],'UserData',paramlist);
end

% ---------------------------------------------------------------
function window_CloseRequestFcn(hObject, eventdata, handles)
% Funçao de fechamento da janela

cancel_btn_Callback(hObject, eventdata, handles);

% ---------------------------------------------------------------
function window_KeyPressFcn(hObject, eventdata, handles)
% Acionamento de tecla do teclado

cc = get(handles.window,'CurrentCharacter');

if isempty(cc)
    return
end

switch abs(cc)
    
    case 13 % Enter
        ok_btn_Callback(hObject, eventdata, handles);
        
    case 27 % Esc
        cancel_btn_Callback(hObject, eventdata, handles);
        
end

% ---------------------------------------------------------------
function fileformat_Callback(hObject, eventdata, handles)
% Seleçao do formato do arquivo

switch get(handles.fileformat,'Value')
    case 1 % xls
        set([handles.descr_chk handles.time_chk handles.header_chk],'Enable','on');
        set([handles.separator handles.precision handles.sep_txt handles.prec_txt],'Enable','off');
    case 2 % txt
        set([handles.descr_chk handles.time_chk handles.header_chk],'Enable','on');
        set([handles.separator handles.precision handles.sep_txt handles.prec_txt],'Enable','on');
    case 3 % dat
        set([handles.descr_chk handles.time_chk handles.header_chk],'Enable','off','Value',0);
        set([handles.separator handles.precision handles.sep_txt handles.prec_txt],'Enable','on');
    case 4 % mat
        set([handles.descr_chk handles.time_chk handles.header_chk],'Enable','off','Value',0);
        set([handles.separator handles.precision handles.sep_txt handles.prec_txt],'Enable','off');
end
