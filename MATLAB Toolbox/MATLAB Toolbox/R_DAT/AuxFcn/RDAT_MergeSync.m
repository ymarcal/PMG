function varargout = RDAT_MergeSync(varargin)
% RDAT_MERGESYNC M-file for RDAT_MergeSync.fig
% Last Modified by GUIDE v2.5 30-Apr-2011 11:01:25

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RDAT_MergeSync_OpeningFcn, ...
                   'gui_OutputFcn',  @RDAT_MergeSync_OutputFcn, ...
                   'gui_LayoutFcn',  @RDAT_MergeSync_LayoutFcn, ...
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
function h = RDAT_MergeSync_LayoutFcn(varargin)
% Função de layout inicial

h = openfig('RDAT_MergeSync.fig','reuse','invisible');

% ---------------------------------------------------------------
function RDAT_MergeSync_OpeningFcn(hObject, eventdata, handles, varargin)
% Funçao de abertura

ss = get(0,'ScreenSize');
ws = get(handles.window,'Position');
set(handles.window,'Position',[(ss(3)-ws(3))/2, (ss(4)-ws(4))/2-2, ws(3), ws(4)]);

bgc = getbuttoncolor(handles.window);
set(handles.parsel_btn,'CData',geticon('DatButtons.mat','list',bgc));
set(handles.help_btn,  'CData',geticon('DatButtons.mat','help',bgc));

if length(varargin) == 6
    PARAM1   = varargin{1};
    PARAM2   = varargin{2};
    reftime1 = varargin{3};
    reftime2 = varargin{4};
    events1  = varargin{5};
    events2  = varargin{6};
else
    beep; uiwait(errordlg('Dados de entrada não fornecidos.','Erro','modal'));
    handles.ok = 0;
    guidata(hObject, handles);
    uiresume;
    return
end

PARAM1 = cellstr(PARAM1);
PARAM2 = cellstr(PARAM2);

nreftime1 = findpar(PARAM1,reftime1);
if isempty(nreftime1)
    nreftime1 = 1;
end
nreftime2 = findpar(PARAM2,reftime2);
if isempty(nreftime2)
    nreftime2 = 1;
end

set(handles.tref1,'String',PARAM1,'Value',nreftime1);
set(handles.tref2,'String',PARAM2,'Value',nreftime2);

set(handles.method,'String',{'Linear','Vizinho'},'Value',1);

topcols1 = findTOPpar(PARAM1);
set(handles.TOP1,'String',[{' '}; PARAM1(topcols1)]);

topcols2 = findTOPpar(PARAM2);
set(handles.TOP2,'String',[{' '}; PARAM2(topcols2)]);

eventlist1{1} = ' ';
for n = 1:size(events1,1)
    eventlist1{n+1} = num2str(n);
end
if ~isempty(events1)
    exc = isnan([events1{:,2}]);
    events1(exc,:)  = [];
    eventlist1(exc) = [];
end

eventlist2{1} = ' ';
for n = 1:size(events2,1)
    eventlist2{n+1} = num2str(n);
end
if ~isempty(events2)
    exc = isnan([events2{:,2}]);
    events2(exc,:)  = [];
    eventlist2(exc) = [];
end

set(handles.event1,'String',eventlist1);
set(handles.event2,'String',eventlist2);

handles.PARAM2 = PARAM2;
paramlist = 1:length(PARAM2);
set(handles.param_txt,'String',['Parâmetros: ' num2str(length(paramlist)-1)],'UserData',paramlist);

handles.events1 = events1;
handles.events2 = events2;

guidata(hObject, handles);

tref1_Callback(hObject, eventdata, handles);
tref2_Callback(hObject, eventdata, handles);

uiwait(handles.window);

% ---------------------------------------------------------------
function varargout = RDAT_MergeSync_OutputFcn(hObject, eventdata, handles)
% Funçao de saida

methodlist = {'linear','nearest'};

if handles.ok
    varargout{1} = get(handles.tref1,'Value');
    varargout{2} = get(handles.tref2,'Value');
    varargout{3} = str2time(get(handles.offset,'String'));
    varargout{4} = methodlist{get(handles.method,'Value')};
    varargout{5} = get(handles.param_txt,'UserData');
else
    varargout = {[],[],[],[],[]};
end
delete(handles.window);

% -------------------------------------------------------------------
function help_btn_Callback(hObject, eventdata, handles)
% Botao Ajuda

helpme('Arquivo\incorporar');

% ---------------------------------------------------------------
function parsel_btn_Callback(hObject, eventdata, handles)
% Seleçao dos parametros desejados

paramlist = get(handles.param_txt,'UserData');
nobs = paramlist(end);
paramlist(end) = [];

paramlist = RDAT_ParamSel(handles.PARAM2,paramlist); drawnow;

if isempty(paramlist)
    return
end

paramlist(end+1) = nobs;

nreftime2 = find(paramlist==get(handles.tref2,'Value'));
if isempty(nreftime2)
    beep; uiwait(errordlg('O tempo de referência indicado não pode ser excluído.','Erro','modal')); drawnow;
    return
end
nobs = find(paramlist==length(handles.PARAM2));
if isempty(nobs)
    beep; uiwait(errordlg('O parâmetro ''No. OBS.'' não pode ser excluído.','Erro','modal')); drawnow;
    return
end

set(handles.param_txt,'String',['Parâmetros: ' num2str(length(paramlist)-1)],'UserData',paramlist);
set(handles.tref2,'String',handles.PARAM2(paramlist),'Value',nreftime2);

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
% Funçao de fechamento da janela

cancel_btn_Callback(hObject, eventdata, handles);

% ---------------------------------------------------------------
function tref1_Callback(hObject, eventdata, handles)
global DADOS
% Seleçao do tempo de referencia 1

timecol = get(handles.tref1,'Value');
Tini = time2str2(DADOS(1,timecol),0);
Tend = time2str2(DADOS(end,timecol),0);
if isempty(Tini), Tini = '??:??:??.???'; end;
if isempty(Tend), Tend = '??:??:??.???'; end;

set(handles.interv1,'String',['Intervalo do Arquivo 1:  ' Tini ' a ' Tend ' h.']);

set([handles.TOPref1 handles.event1],'Value',1);
set(handles.tsync1,'String',' ');
tsync1_Callback(hObject, eventdata, handles, 0);

% ---------------------------------------------------------------
function tref2_Callback(hObject, eventdata, handles)
global DADOS2
% Seleçao do tempo de referencia 2

timecol = get(handles.tref2,'Value');
Tini = time2str2(DADOS2(1,timecol),0);
Tend = time2str2(DADOS2(end,timecol),0);
if isempty(Tini), Tini = '??:??:??.???'; end;
if isempty(Tend), Tend = '??:??:??.???'; end;

set(handles.interv2,'String',['Intervalo do Arquivo 2:  ' Tini ' a ' Tend ' h.']);

set([handles.TOPref2 handles.event2],'Value',1);
set(handles.tsync2,'String',' ');
tsync2_Callback(hObject, eventdata, handles, 0);

% ---------------------------------------------------------------
function offset_Callback(hObject, eventdata, handles)
% Inserçao do Offset

set([handles.TOPref1 handles.event1 handles.TOPref2 handles.event2],'Value',1);
set([handles.tsync1 handles.tsync2],'String','');

[offset, str] = str2time(get(handles.offset,'String'));

if isnan(offset)
    str = '00:00:00';
end

set(handles.offset,'String',str);

% ---------------------------------------------------------------
function tsync1_Callback(hObject, eventdata, handles, opt)
% Inserçao do tempo de sincronismo 1

if nargin == 3
    opt = 1;
end
if opt
    set([handles.TOPref1 handles.event1],'Value',1);
end

[t1, str] = str2time(get(handles.tsync1,'String'));
set(handles.tsync1,'String',str);

t2 = str2time(get(handles.tsync2,'String'));

if ~isnan(t2-t1)
    offset = time2str2(t2-t1);
else
    offset = '00:00:00';
end

set(handles.offset,'String',offset);

% ---------------------------------------------------------------
function tsync2_Callback(hObject, eventdata, handles, opt)
% Inserçao do tempo de sincronismo 2

if nargin == 3
    opt = 1;
end
if opt
    set([handles.TOPref2 handles.event2],'Value',1);
end

[t2, str] = str2time(get(handles.tsync2,'String'));
set(handles.tsync2,'String',str);

t1 = str2time(get(handles.tsync1,'String'));

if ~isnan(t2-t1)
    offset = time2str2(t2-t1);
else
    offset = '00:00:00';
end

set(handles.offset,'String',offset);

% ---------------------------------------------------------------
function TOP1_Callback(hObject, eventdata, handles)
global DADOS
% Seleçao do parametro de TOP 1

if isempty(DADOS)
    return
end

topcol = get(handles.TOP1,'Value');

if topcol==1
    set(handles.TOPref1,'String',' ','Value',1);
    set(handles.tsync1,'String',' ');
    tsync1_Callback(hObject, eventdata, handles, 0);
    return    
end

TOPPARAM = get(handles.TOP1,'String');
PARAM = get(handles.tref1,'String');
topcol = findpar(PARAM,TOPPARAM{topcol},0,1);
set(handles.TOP1,'UserData',topcol);

[tops, ntops] = getTOPs(DADOS(:,topcol));

if isempty(tops)
    set(handles.TOPref1,'String',' ','Value',1);
    set(handles.tsync1,'String',' ');
    tsync1_Callback(hObject, eventdata, handles, 0);
    return
end

if length(tops)>100
    tops(101:end) = [];
    uiwait(warndlg({'Há muitos TOPs no parâmetro selecionado.',...
            'Apenas os 100 primeiros serão considerados.'},'Aviso','modal')); drawnow;
end

toplist{1} = ' ';
for n = 1:length(tops)
    toplist{n+1} = num2str(tops(n));
end

set(handles.TOPref1,'String',toplist,'Value',1);

% ---------------------------------------------------------------
function TOP2_Callback(hObject, eventdata, handles)
global DADOS2
% Seleçao do parametro de TOP 2

if isempty(DADOS2)
    return
end

topcol = get(handles.TOP2,'Value');

if topcol==1
    set(handles.TOPref2,'String',' ','Value',1);
    set(handles.tsync2,'String',' ');
    tsync2_Callback(hObject, eventdata, handles, 0);
    return    
end

TOPPARAM = get(handles.TOP2,'String');
PARAM = get(handles.tref2,'String');
topcol = findpar(PARAM,TOPPARAM{topcol},0,1);
set(handles.TOP2,'UserData',topcol);

[tops, ntops] = getTOPs(DADOS2(:,topcol));

if isempty(tops)
    set(handles.TOPref2,'String',' ','Value',1);
    set(handles.tsync2,'String',' ');
    tsync2_Callback(hObject, eventdata, handles, 0);
    return
end

if length(tops)>100
    tops(101:end) = [];
    uiwait(warndlg({'Há muitos TOPs no parâmetro selecionado.',...
            'Apenas os 100 primeiros serão considerados.'},'Aviso','modal')); drawnow;
end

toplist{1} = ' ';
for n = 1:length(tops)
    toplist{n+1} = num2str(tops(n));
end

set(handles.TOPref2,'String',toplist,'Value',1);

% ---------------------------------------------------------------
function TOPref1_Callback(hObject, eventdata, handles)
global DADOS
% Seleçao do TOP de sincronismo 1

set(handles.event1,'Value',1);

if isempty(DADOS)
    return
end

tops  = get(handles.TOPref1,'String');
ntop  = get(handles.TOPref1,'Value');
timecol = get(handles.tref1,'Value');
topcol  = get(handles.TOP1,'UserData');

if ntop == 1
    return
end

ntop = str2double(tops{ntop});

ntop = find(round(DADOS(:,topcol))==ntop);
ntop = ntop(1);

if ntop == 1
    tsync1 = DADOS(ntop,timecol);
else
    tsync1 = mean(DADOS(ntop-1:ntop,timecol));
end

set(handles.tsync1,'String',num2str(tsync1));
tsync1_Callback(hObject, eventdata, handles, 0);

% ---------------------------------------------------------------
function TOPref2_Callback(hObject, eventdata, handles)
global DADOS2
% Seleçao do TOP de sincronismo 2

set(handles.event2,'Value',1);

if isempty(DADOS2)
    return
end

tops  = get(handles.TOPref2,'String');
ntop  = get(handles.TOPref2,'Value');
timecol = get(handles.tref2,'Value');
topcol  = get(handles.TOP2,'UserData');

if ntop == 1
    return
end

ntop = str2double(tops{ntop});

ntop = find(round(DADOS2(:,topcol))==ntop);
ntop = ntop(1);

if ntop == 1
    tsync2 = DADOS2(ntop,timecol);
else
    tsync2 = mean(DADOS2(ntop-1:ntop,timecol));
end

set(handles.tsync2,'String',num2str(tsync2));
tsync2_Callback(hObject, eventdata, handles, 0);

% ---------------------------------------------------------------
function event1_Callback(hObject, eventdata, handles)
% Seleçao do evento de sincronismo 1

set(handles.TOPref1,'Value',1);

n = get(handles.event1,'Value')-1;
if n
    t1 = handles.events1{n,2};
    set(handles.tsync1,'String',num2str(t1));
else
    set(handles.tsync1,'String','');
end
tsync1_Callback(hObject, eventdata, handles, 0);

% ---------------------------------------------------------------
function event2_Callback(hObject, eventdata, handles)
% Seleçao do evento de sincronismo 2

set(handles.TOPref2,'Value',1);

n = get(handles.event2,'Value')-1;
if n
    t2 = handles.events2{n,2};
    set(handles.tsync2,'String',num2str(t2));
else
    set(handles.tsync2,'String','');
end
tsync2_Callback(hObject, eventdata, handles, 0);
