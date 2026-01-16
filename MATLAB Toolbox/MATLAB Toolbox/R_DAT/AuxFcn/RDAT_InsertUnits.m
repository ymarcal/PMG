function varargout = RDAT_InsertUnits(varargin)
% RDAT_INSERTUNITS M-file for RDAT_InsertUnits.fig
% Last Modified by GUIDE v2.5 15-Apr-2011 16:48:11

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RDAT_InsertUnits_OpeningFcn, ...
                   'gui_OutputFcn',  @RDAT_InsertUnits_OutputFcn, ...
                   'gui_LayoutFcn',  @RDAT_InsertUnits_LayoutFcn, ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1}) && size(varargin{1},1)==1
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

% -------------------------------------------------------------------------
function h = RDAT_InsertUnits_LayoutFcn(varargin)
% Função de layout inicial

h = openfig('RDAT_InsertUnits.fig','reuse','invisible');

% -------------------------------------------------------------------------
function RDAT_InsertUnits_OpeningFcn(hObject, eventdata, handles, varargin)

scrsz = get(0,'ScreenSize');
winsz = get(handles.window,'Position');
set(handles.window,'Position',[.5*(scrsz(3)-winsz(3)) .5*(scrsz(4)-winsz(4)) winsz(3) winsz(4)],'Visible','on');

bgc = getbuttoncolor(handles.window);
set(handles.help_btn,'CData',geticon('DatButtons.mat','help',bgc));

if nargin >= 4
    handles.PARAM = cellstr(varargin{1});
else
    handles.PARAM = {};
end
if nargin >= 5
    handles.maxparamlength = varargin{2};
else
    handles.maxparamlength = 48;
end

[typelist, convlist] = getconvlist;
exc = strmatch('Variação temporal',typelist);
typelist(exc) = [];
convlist(exc) = [];

handles.convlist = convlist;

set(handles.dim_sel,'String',[typelist,{'Outra'}],'Value',1,'UserData',length(typelist)+1);
set(handles.unit_sel,'String',handles.convlist{1}(:,1),'Value',1);

set(handles.paramlist,'String',handles.PARAM,'Value',[]);

handles.ok  = 0;
handles.chg = 0;

guidata(hObject, handles);
uiwait(handles.window);

% -------------------------------------------------------------------------
function varargout = RDAT_InsertUnits_OutputFcn(hObject, eventdata, handles)

if handles.ok
    varargout{1} = handles.PARAM;
else
    varargout{1} = [];
end
delete(handles.window);

% -------------------------------------------------------------------
function help_btn_Callback(hObject, eventdata, handles)
% Botao Ajuda

helpme('Ferramentas\inserirunidades');

% -------------------------------------------------------------------------
function dim_sel_Callback(hObject, eventdata, handles)
% Seleciona a dimensao das unidades

ntype = get(handles.dim_sel,'Value');
other = get(handles.dim_sel,'UserData');

if ntype < other
    set(handles.unit_sel,'Style','popupmenu','String',handles.convlist{ntype}(:,1),'Value',1);
else
    set(handles.unit_sel,'Style','edit','String','');
end

% -------------------------------------------------------------------
function ok_btn_Callback(hObject, eventdata, handles)

if handles.chg
    button = questdlg('Deseja confirmar a operação?','Confirmação','Sim','Não','Não');
else
    button = 'Sim';
end

if strcmp(button,'Sim')
    handles.ok = 1;
    guidata(hObject, handles);
    uiresume;
end

% -------------------------------------------------------------------
function cancel_btn_Callback(hObject, eventdata, handles)

if handles.chg
    button = questdlg('Deseja cancelar a operação?','Confirmação','Sim','Não','Não');
else
    button = 'Sim';
end

if strcmp(button,'Sim')
    uiresume;
end

% -------------------------------------------------------------------------
function insert_btn_Callback(hObject, eventdata, handles)
% Insere as unidades nos parametros selecionados

PARAM = handles.PARAM;
ntype = get(handles.dim_sel,'Value');
other = get(handles.dim_sel,'UserData');
nunit = get(handles.unit_sel,'Value');
nP    = get(handles.paramlist,'Value');
top   = get(handles.paramlist,'ListboxTop');

if isempty(nP)
    beep; uiwait(errordlg('Nenhum parâmetro selecionado.','Erro','modal')); drawnow;
    return
end

if ntype < other
    unit = handles.convlist{ntype}{nunit,1};
else
    unit = fliplr(deblank(fliplr(deblank(get(handles.unit_sel,'String')))));
    set(handles.unit_sel,'String',unit);
end

for np = nP
    param = PARAM{np};
    i1 = sort([find(param=='(') find(param=='[')]);
    i2 = sort([find(param==')') find(param==']')]);
    
    if ~isempty(i1)
        param(i1) = '(';
        param = [param(1:i1(1)) unit ')'];
    else
        param(i2) = [];
        param = [param ' (' unit ')'];
    end
    param = deblank(strrep(param,'()',''));
    
    param = TrimParamName(param,handles.maxparamlength);
    
    PARAM{np} = param;
end

handles.PARAM = PARAM;
set(handles.paramlist,'String',PARAM,'ListboxTop',top);

handles.chg = 1;
guidata(hObject, handles);

%--------------------------------------------------------------------------
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
        window_CloseRequestFcn(hObject, eventdata, handles);
        
end

% -------------------------------------------------------------------------
function window_CloseRequestFcn(hObject, eventdata, handles)
cancel_btn_Callback(hObject, eventdata, handles);
