function varargout = RDAT_GoTo(varargin)
% RDAT_GOTO M-file for RDAT_GoTo.fig
% Last Modified by GUIDE v2.5 30-Jun-2010 17:12:21

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RDAT_GoTo_OpeningFcn, ...
                   'gui_OutputFcn',  @RDAT_GoTo_OutputFcn, ...
                   'gui_LayoutFcn',  @RDAT_GoTo_LayoutFcn, ...
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
function h = RDAT_GoTo_LayoutFcn(varargin)
% Função de layout inicial

h = openfig('RDAT_GoTo.fig','reuse','invisible');

% ---------------------------------------------------------------------
function RDAT_GoTo_OpeningFcn(hObject, eventdata, handles, varargin)
% Funçao de inicializaçao

ss = get(0,'ScreenSize');
ws = get(handles.window,'Position');
set(handles.window,'Position',[(ss(3)-ws(3))/2, (ss(4)-ws(4))/2, ws(3), ws(4)]);

if ~isempty(varargin)
    events  = varargin{1};
    testpts = varargin{2};
else
    events  = {};
    testpts = {};
end

eventlist = {};
eventtime = [];
if ~isempty(events)
    for n = 1:size(events,1)
        if events{n,1} && ~isnan(events{n,2})
            eventlist{end+1,1} = [num2str(n) ' - ' events{n,3}];
            eventtime(end+1)   = events{n,2};
        end
    end
else
    set([handles.event_sel handles.event_list],'Enable','off');
end

testptlist = {};
testpttime = [];
if isfield(testpts,'number') && ~isempty([testpts.number])
    testptnumber = [testpts.number];
    testptdescr  = [testpts.descr];
    testpttimes  = [testpts.time];
    for n = 1:size(testptnumber,2)
        if ~isnan(testpttimes(1,n))
            testptlist{end+1,1} = [testptnumber{n} ' - ' testptdescr{n}];
            testpttime(end+1)   = testpttimes(1,n);
        end
    end
else
    set([handles.testpt_sel handles.testpt_list],'Enable','off');
end

set(handles.event_list,'String',eventlist,'Value',1);
set(handles.testpt_list,'String',testptlist,'Value',1);

handles.ok = 0;
handles.eventtime  = eventtime;
handles.testpttime = testpttime;

time_sel_Callback(hObject, eventdata, handles);

guidata(hObject, handles);
uiwait(handles.window);

% ---------------------------------------------------------------------
function varargout = RDAT_GoTo_OutputFcn(hObject, eventdata, handles)
% Funçao de saida

if handles.ok
    varargout{1} = str2time(get(handles.time_entry,'String'));
else
    varargout{1} = [];
end
delete(handles.window);

% ---------------------------------------------------------------------
function time_sel_Callback(hObject, eventdata, handles)
% Seleciona opçao "Tempo"

set(handles.time_sel,'Value',1);
set([handles.event_sel handles.testpt_sel],'Value',0);

set(handles.time_entry,'Enable','on');
set([handles.event_list handles.testpt_list],'Enable','off');

% ---------------------------------------------------------------------
function time_entry_Callback(hObject, eventdata, handles)
% Insere o tempo manualmente

[t, str] = str2time(get(handles.time_entry,'String'));
if isnan(t)
    str = '';
end
set(handles.time_entry,'String',str);

% ---------------------------------------------------------------------
function event_sel_Callback(hObject, eventdata, handles)
% Seleciona opçao "Evento"

set(handles.event_sel,'Value',1);
set([handles.time_sel handles.testpt_sel],'Value',0);

set(handles.event_list,'Enable','on');
set([handles.time_entry handles.testpt_list],'Enable','off');

event_list_Callback(hObject, eventdata, handles);

% ---------------------------------------------------------------------
function event_list_Callback(hObject, eventdata, handles)
% Seleciona um evento

n = get(handles.event_list,'Value');
set(handles.time_entry,'String',time2str2(handles.eventtime(n)));

% ---------------------------------------------------------------------
function testpt_sel_Callback(hObject, eventdata, handles)
% Seleciona opçao "Ponto de Ensaio"

set(handles.testpt_sel,'Value',1);
set([handles.time_sel handles.event_sel],'Value',0);

set(handles.testpt_list,'Enable','on');
set([handles.time_entry handles.event_list],'Enable','off');

testpt_list_Callback(hObject, eventdata, handles);

% ---------------------------------------------------------------------
function testpt_list_Callback(hObject, eventdata, handles)
% Seleciona um ponto de ensaio

n = get(handles.testpt_list,'Value');
set(handles.time_entry,'String',time2str2(handles.testpttime(n)));

% ---------------------------------------------------------------------
function ok_btn_Callback(hObject, eventdata, handles)
% Botao OK

if isempty(get(handles.time_entry,'String'))
    beep; uiwait(errordlg('Tempo não definido.','Erro','modal')); drawnow;
    return
end

handles.ok = 1;
guidata(hObject, handles);
uiresume;

% ---------------------------------------------------------------------
function cancel_btn_Callback(hObject, eventdata, handles)
% Botao Cancela

uiresume;

% --------------------------------------------------------------------
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
        
    case {abs('t'),abs('T')}
        time_sel_Callback(hObject, eventdata, handles);
       
    case {abs('e'),abs('E')}
        if strcmp(get(handles.event_sel,'Enable'),'on')
            event_sel_Callback(hObject, eventdata, handles);
        end
        
    case {abs('p'),abs('P')}
        if strcmp(get(handles.testpt_sel,'Enable'),'on')
            testpt_sel_Callback(hObject, eventdata, handles);
        end
       
end

% ---------------------------------------------------------------------
function window_CloseRequestFcn(hObject, eventdata, handles)
% Funçao de fechamento da janela

cancel_btn_Callback(hObject, eventdata, handles);

