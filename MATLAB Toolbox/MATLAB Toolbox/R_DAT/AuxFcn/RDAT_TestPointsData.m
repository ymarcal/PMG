function varargout = RDAT_TestPointsData(varargin)
% RDAT_TESTPOINTSDATA M-file for RDAT_TestPointsData.fig
% Last Modified by GUIDE v2.5 03-Dec-2010 13:57:18

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RDAT_TestPointsData_OpeningFcn, ...
                   'gui_OutputFcn',  @RDAT_TestPointsData_OutputFcn, ...
                   'gui_LayoutFcn',  @RDAT_TestPointsData_LayoutFcn, ...
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
function h = RDAT_TestPointsData_LayoutFcn(varargin)
% Função de layout inicial

h = openfig('RDAT_TestPointsData.fig','reuse','invisible');

% ---------------------------------------------------------------
function RDAT_TestPointsData_OpeningFcn(hObject, eventdata, handles, varargin)

ss = get(0,'ScreenSize');
ws = get(handles.window,'Position');
set(handles.window,'Position',[(ss(3)-ws(3))/2, (ss(4)-ws(4))/2-2, ws(3), ws(4)]);

bgc = getbuttoncolor(handles.window);
set(handles.parsel_btn,'CData',geticon('DatButtons.mat','list',bgc));
set(handles.help_btn,  'CData',geticon('DatButtons.mat','help',bgc));

if length(varargin) == 3
    grplist   = varargin{1};
    PARAM     = varargin{2};
    paramlist = varargin{3};
else
    PARAM     = {};
    paramlist = [];
    grplist = {'Todos'};
end

datalist   = {'Média','Desvio Padrão','Valor mínimo','Valor máximo','Amplitude','Valor inicial','Valor final','Variação',...
        'Número de NaNs','Derivada média'};
formatlist = {'Planilha Excel (.xls)','Arquivo de texto (.txt)','Arquivo de texto (.dat)','Arquivo MATLAB (.mat)'};
seplist    = {'Espaço','Tabulação','Vírgula','Ponto e vírgula'};
preclist   = cellstr(num2str((16:-1:1)'));

set(handles.datatype,'String',datalist);
set(handles.group,'String',grplist);
set(handles.fileformat,'String',formatlist);
set(handles.separator,'String',seplist);
set(handles.precision,'String',preclist,'Value',9);
set(handles.param_txt,'String',['Parâmetros: ' num2str(length(paramlist))],'UserData',paramlist);

handles.PARAM = PARAM;
guidata(hObject, handles);

fileformat_Callback(hObject, eventdata, handles);
uiwait(handles.window);

% ---------------------------------------------------------------
function varargout = RDAT_TestPointsData_OutputFcn(hObject, eventdata, handles)

if handles.ok
    varargout{1} = get(handles.datatype,  'Value');
    varargout{2} = get(handles.group,     'Value')-1;
    varargout{3} = get(handles.fileformat,'Value');
    varargout{4} = get(handles.separator, 'Value');
    varargout{5} = get(handles.precision, 'Value');
    varargout{6} = get(handles.group_chk, 'Value');
    varargout{7} = get(handles.num_chk,   'Value');
    varargout{8} = get(handles.descr_chk, 'Value');
    varargout{9} = get(handles.header_chk,'Value');
    varargout{10} = get(handles.param_txt,'UserData');
else
    varargout = {[],[],[],[],[],[],[],[],[],[]};
end
delete(handles.window);

% -------------------------------------------------------------------
function help_btn_Callback(hObject, eventdata, handles)
% Botao Ajuda

helpme('Ferramentas\obtencaodedados','tab');

% ---------------------------------------------------------------
function ok_btn_Callback(hObject, eventdata, handles)

button = questdlg('Deseja confirmar a seleção?','Confirmação','Sim','Não','Não');
if strcmp(button,'Sim')
    handles.ok = 1;
    guidata(hObject, handles);
    uiresume;
end

% ---------------------------------------------------------------
function cancel_btn_Callback(hObject, eventdata, handles)

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
function window_CloseRequestFcn(hObject, eventdata, handles)
cancel_btn_Callback(hObject, eventdata, handles);

% ---------------------------------------------------------------
function fileformat_Callback(hObject, eventdata, handles)

switch get(handles.fileformat,'Value')
    case 1 % xls
        set([handles.group_chk handles.num_chk handles.descr_chk handles.header_chk],'Enable','on');
        set([handles.separator handles.precision handles.sep_txt handles.prec_txt],'Enable','off');
    case 2 % txt
        set([handles.group_chk handles.num_chk handles.descr_chk handles.header_chk],'Enable','on');
        set([handles.separator handles.precision handles.sep_txt handles.prec_txt],'Enable','on');
    case 3 % dat
        set([handles.group_chk handles.num_chk handles.descr_chk handles.header_chk],'Enable','off','Value',0);
        set([handles.separator handles.precision handles.sep_txt handles.prec_txt],'Enable','on');
    case 4 % mat
        set([handles.group_chk handles.num_chk handles.descr_chk handles.header_chk],'Enable','off','Value',0);
        set([handles.separator handles.precision handles.sep_txt handles.prec_txt],'Enable','off');
end

