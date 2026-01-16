function varargout = RDAT_EditToolbar(varargin)
% RDAT_EDITTOOLBAR M-file for RDAT_EditToolbar.fig
% Last Modified by GUIDE v2.5 16-Nov-2009 14:34:18

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RDAT_EditToolbar_OpeningFcn, ...
                   'gui_OutputFcn',  @RDAT_EditToolbar_OutputFcn, ...
                   'gui_LayoutFcn',  @RDAT_EditToolbar_LayoutFcn, ...
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
function h = RDAT_EditToolbar_LayoutFcn(varargin)
% Função de layout inicial

h = openfig('RDAT_EditToolbar.fig','reuse','invisible');

% ---------------------------------------------------------------------
function RDAT_EditToolbar_OpeningFcn(hObject, eventdata, handles, varargin)
% Funçao de abertura

ss = get(0,'ScreenSize');
ws = get(handles.window,'Position');
set(handles.window,'Position',[(ss(3)-ws(3))/2, (ss(4)-ws(4))/2, ws(3), ws(4)]);

bgc = getbuttoncolor(handles.window);
set(findobj(handles.window,'Style','text'),'BackgroundColor',get(handles.window,'Color'));
set(findobj(handles.window,'Style','pushbutton'),'BackgroundColor',bgc);

if length(varargin) == 3
    handles.btndata   = varargin{1};
    handles.btnlabels = varargin{2};
    handles.btnvis    = varargin{3};
else
    beep; uiwait(errordlg('Configuração atual não fornecida.','Erro','modal'));
    handles.ok = 0;
    guidata(hObject, handles);
    uiresume;
    return
end

handles.hcheck = [handles.check01, handles.check02, handles.check03, handles.check04,...
        handles.check05, handles.check06, handles.check07, handles.check08,...
        handles.check09, handles.check10, handles.check11, handles.check12];
handles.hbtns  = [handles.btn01, handles.btn02, handles.btn03, handles.btn04,...
        handles.btn05, handles.btn06, handles.btn07, handles.btn08,...
        handles.btn09, handles.btn10, handles.btn11, handles.btn12];
handles.hdescr = [handles.descr01, handles.descr02, handles.descr03, handles.descr04,...
        handles.descr05, handles.descr06, handles.descr07, handles.descr08,...
        handles.descr09, handles.descr10, handles.descr11, handles.descr12];

handles.ok = 0;

guidata(hObject, handles);

initialize(hObject, eventdata, handles, 1);
uiwait(handles.window);

% ---------------------------------------------------------------------
function varargout = RDAT_EditToolbar_OutputFcn(hObject, eventdata, handles) 
% Funçao de saida

if handles.ok   
    varargout{1} = handles.btnvis;
else
    varargout{1} = [];
end
delete(handles.window);

% ---------------------------------------------------------------------
function check01_Callback(hObject, eventdata, handles)
updatebtndata(hObject, eventdata, handles, 1);
% ---------------------------------------------------------------------
function check02_Callback(hObject, eventdata, handles)
updatebtndata(hObject, eventdata, handles, 2);
% ---------------------------------------------------------------------
function check03_Callback(hObject, eventdata, handles)
updatebtndata(hObject, eventdata, handles, 3);
% ---------------------------------------------------------------------
function check04_Callback(hObject, eventdata, handles)
updatebtndata(hObject, eventdata, handles, 4);
% ---------------------------------------------------------------------
function check05_Callback(hObject, eventdata, handles)
updatebtndata(hObject, eventdata, handles, 5);
% ---------------------------------------------------------------------
function check06_Callback(hObject, eventdata, handles)
updatebtndata(hObject, eventdata, handles, 6);
% ---------------------------------------------------------------------
function check07_Callback(hObject, eventdata, handles)
updatebtndata(hObject, eventdata, handles, 7);
% ---------------------------------------------------------------------
function check08_Callback(hObject, eventdata, handles)
updatebtndata(hObject, eventdata, handles, 8);
% ---------------------------------------------------------------------
function check09_Callback(hObject, eventdata, handles)
updatebtndata(hObject, eventdata, handles, 9);
% ---------------------------------------------------------------------
function check10_Callback(hObject, eventdata, handles)
updatebtndata(hObject, eventdata, handles, 10);
% ---------------------------------------------------------------------
function check11_Callback(hObject, eventdata, handles)
updatebtndata(hObject, eventdata, handles, 11);
% ---------------------------------------------------------------------
function check12_Callback(hObject, eventdata, handles)
updatebtndata(hObject, eventdata, handles, 12);

% ---------------------------------------------------------------------
function ok_btn_Callback(hObject, eventdata, handles)
% Botao OK

handles.ok = 1;
guidata(hObject, handles);
uiresume;

% ---------------------------------------------------------------------
function cancel_btn_Callback(hObject, eventdata, handles)
% Botao Cancela

uiresume;

% ---------------------------------------------------------------------
function window_CloseRequestFcn(hObject, eventdata, handles)
% Funçao de fechamento da janela

cancel_btn_Callback(hObject, eventdata, handles);

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
        
end

% ---------------------------------------------------------------
function initialize(hObject, eventdata, handles, n1)
% Funçao de inicializaçao

N = length(handles.btnvis);

if nargin == 3
    s0   = get(handles.slider,'Value');
    max0 = get(handles.slider,'Max');
    if max0 >= 2
        s = max(1, N-11-max0+s0);
    else
        s = max(1, N-11);
    end
else
    s = max(1, N-11-n1+1);
end

vmax = max(1+1e-6, N-11);

if N <= 12
    stepv = [1 1e6];
    ven = 'off';
else
    stepv = [1 5]/(N-12);
    ven = 'on';
end

set(handles.slider,'Value',s,'SliderStep',stepv,'Min',1,'Max',vmax,'Enable',ven);

updatetable(hObject, eventdata, handles);

% ---------------------------------------------------------------
function updatetable(hObject, eventdata, handles)
% Funçao de atualizaçao dos icones dos botoes

N = length(handles.btnvis);
n1 = max(1, N-get(handles.slider,'Value')-10);

for k = 1:min(12,N)
    n = n1+k-1;
    set(handles.hcheck(k),'Value', handles.btnvis(n));
    if handles.btnvis(n)
        enbl = 'on';
        ncol = 3;
    else
        enbl = 'off';
        ncol = 4;
    end
    set(handles.hbtns(k), 'CData', handles.btndata{n,ncol});
    set(handles.hdescr(k),'String',handles.btnlabels{n},'Enable',enbl);
end

% --------------------------------------------------------------------
function updatebtndata(hObject, eventdata, handles, lin)
% Funçao de atualizaçao da habilitaçao dos botoes

chk = get(handles.hcheck(lin),'Value');

N = length(handles.btnvis);
n1 = max(1, N-get(handles.slider,'Value')-10);
n = n1+lin-1;

handles.btnvis(n) = chk;
guidata(hObject, handles);

if any(~handles.btnvis)
    set(handles.all_chk,'Value',0);
end

updatetable(hObject, eventdata, handles);

% --------------------------------------------------------------------
function slider_Callback(hObject, eventdata, handles)
% Funçao da barra de rolagem

set(handles.slider,'Value',round(get(handles.slider,'Value')));
updatetable(hObject, eventdata, handles);

% --------------------------------------------------------------------
function all_chk_Callback(hObject, eventdata, handles)
% Selecionar todos os botoes

if get(handles.all_chk,'Value')
    
    handles.btnvis(:) = 1;
    guidata(hObject, handles);
    
    updatetable(hObject, eventdata, handles);
    
end