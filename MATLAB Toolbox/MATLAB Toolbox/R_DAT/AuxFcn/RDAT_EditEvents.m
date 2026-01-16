function varargout = RDAT_EditEvents(varargin)
% RDAT_EDITEVENTS M-file for RDAT_EditEvents.fig
% Last Modified by GUIDE v2.5 03-Dec-2010 11:51:10

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RDAT_EditEvents_OpeningFcn, ...
                   'gui_OutputFcn',  @RDAT_EditEvents_OutputFcn, ...
                   'gui_LayoutFcn',  @RDAT_EditEvents_LayoutFcn, ...
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
function h = RDAT_EditEvents_LayoutFcn(varargin)
% Função de layout inicial

h = openfig('RDAT_EditEvents.fig','reuse','invisible');

% ---------------------------------------------------------------------
function RDAT_EditEvents_OpeningFcn(hObject, eventdata, handles, varargin)
% Funçao de inicializaçao

ss = get(0,'ScreenSize');
ws = get(handles.window,'Position');
set(handles.window,'Position',[(ss(3)-ws(3))/2, (ss(4)-ws(4))/2, ws(3), ws(4)]);

bgc = getbuttoncolor(handles.window);
set(handles.new_btn,   'CData',geticon('DatButtons.mat','new',   bgc));
set(handles.open_btn,  'CData',geticon('DatButtons.mat','open',  bgc));
set(handles.import_btn,'CData',geticon('DatButtons.mat','import',bgc));
set(handles.save_btn,  'CData',geticon('DatButtons.mat','save',  bgc));
set(handles.help_btn,  'CData',geticon('DatButtons.mat','help',  bgc));

if ~isempty(varargin)
    events = varargin{1};
    if length(varargin) == 3
        PARAM = cellstr(varargin{2});
        reftime = varargin{3};
    else
        PARAM = {' '};
        reftime = '';
    end
else
    events = {};
    PARAM = {' '};
    reftime = '';
end
if isempty(events)
    events = [num2cell(zeros(12,1)), num2cell(NaN*ones(12,1)), cellstr(char(zeros(12,1)))];
end

handles.hlines = [handles.text01, handles.text02, handles.text03, handles.text04,...
        handles.text05, handles.text06, handles.text07, handles.text08,...
        handles.text09, handles.text10, handles.text11, handles.text12];
handles.hcheck = [handles.check01, handles.check02, handles.check03, handles.check04,...
        handles.check05, handles.check06, handles.check07, handles.check08,...
        handles.check09, handles.check10, handles.check11, handles.check12];
handles.htimes = [handles.time01, handles.time02, handles.time03, handles.time04,...
        handles.time05, handles.time06, handles.time07, handles.time08,...
        handles.time09, handles.time10, handles.time11, handles.time12];
handles.hdescr = [handles.descr01, handles.descr02, handles.descr03, handles.descr04,...
        handles.descr05, handles.descr06, handles.descr07, handles.descr08,...
        handles.descr09, handles.descr10, handles.descr11, handles.descr12];

try    
    if isempty(deblank(reftime))
        tcol = inputvalue('Definir','Tempo de referência:',PARAM,1,1.35); drawnow;
        if isempty(tcol)
            handles.ok = 0;
            guidata(hObject, handles);
            uiresume;
            return
        end
    else
        tcol = findpar(denumber(PARAM),reftime,0,1);
        if isempty(tcol)
            tcol = 1;
            beep; uiwait(errordlg(['Tempo de referência ''' reftime ''' não encontrado.'],'Erro','modal'));
        end
    end
    set(handles.paramlist,'String',PARAM,'Value',tcol);
    paramlist_Callback(hObject, eventdata, handles);
    
    for n = 1:size(events,1)
        events{n,1} = ~isequal(events{n,1},0);
    end
    
    path(path,cd);
    handles.k = [];
    handles.ok = 0;
    handles.chg = 0;
    handles.events = events;
    handles.copydata = [];
    handles.fname = '*.mat';
    handles.fpath = [pwd filesep];
    guidata(hObject, handles);
    
    initialize(hObject, eventdata, handles, 1);
    uiwait(handles.window);
    
catch
    handles.ok = 0;
    guidata(hObject, handles);
    uiresume;
    beep; uiwait(errordlg('Lista de eventos incompatível.','Erro','modal'));
end

% ---------------------------------------------------------------------
function varargout = RDAT_EditEvents_OutputFcn(hObject, eventdata, handles) 
% Funçao de saida

if handles.ok
    events  = handles.events;
    PARAM   = get(handles.paramlist,'String');
    reftime = denumber(PARAM{get(handles.paramlist,'Value')});
    
    varargout{1} = events;
    varargout{2} = reftime;
else
    varargout{1} = [];
    varargout{2} = [];
end
delete(handles.window);

% ---------------------------------------------------------------------
function paramlist_Callback(hObject, eventdata, handles)
global DADOS
% Funçao de seleçao do parametro de tempo

if isempty(DADOS) || isequal(char(get(handles.paramlist,'String')),' ')
    return
end

timecol = get(handles.paramlist,'Value');
Tini = time2str2(DADOS(1,timecol));
Tend = time2str2(DADOS(end,timecol));
if isempty(Tini), Tini = '??:??:??'; end;
if isempty(Tend), Tend = '??:??:??'; end;

set(handles.interv_txt,'String',[Tini ' a ' Tend ' h']);

[ok, ndc, nna] = IsTimeOk(DADOS(:,timecol));
if ~ok
    beep; uiwait(warndlg({'Parâmetro de tempo não é adequado:',' ',...
            ['Pontos inválidos: ' num2str(length(nna))],...
            ['Pontos não crescentes: ' num2str(length(ndc))]},'Aviso','modal')); drawnow;
end

handles.chg = 1; guidata(hObject, handles);

% ---------------------------------------------------------------------
function check01_Callback(hObject, eventdata, handles)
updateevents(hObject, eventdata, handles, 1, 1);
% ---------------------------------------------------------------------
function check02_Callback(hObject, eventdata, handles)
updateevents(hObject, eventdata, handles, 2, 1);
% ---------------------------------------------------------------------
function check03_Callback(hObject, eventdata, handles)
updateevents(hObject, eventdata, handles, 3, 1);
% ---------------------------------------------------------------------
function check04_Callback(hObject, eventdata, handles)
updateevents(hObject, eventdata, handles, 4, 1);
% ---------------------------------------------------------------------
function check05_Callback(hObject, eventdata, handles)
updateevents(hObject, eventdata, handles, 5, 1);
% ---------------------------------------------------------------------
function check06_Callback(hObject, eventdata, handles)
updateevents(hObject, eventdata, handles, 6, 1);
% ---------------------------------------------------------------------
function check07_Callback(hObject, eventdata, handles)
updateevents(hObject, eventdata, handles, 7, 1);
% ---------------------------------------------------------------------
function check08_Callback(hObject, eventdata, handles)
updateevents(hObject, eventdata, handles, 8, 1);
% ---------------------------------------------------------------------
function check09_Callback(hObject, eventdata, handles)
updateevents(hObject, eventdata, handles, 9, 1);
% ---------------------------------------------------------------------
function check10_Callback(hObject, eventdata, handles)
updateevents(hObject, eventdata, handles, 10, 1);
% ---------------------------------------------------------------------
function check11_Callback(hObject, eventdata, handles)
updateevents(hObject, eventdata, handles, 11, 1);
% ---------------------------------------------------------------------
function check12_Callback(hObject, eventdata, handles)
updateevents(hObject, eventdata, handles, 12, 1);

% ---------------------------------------------------------------------
function time01_Callback(hObject, eventdata, handles)
updateevents(hObject, eventdata, handles, 1, 2);
% ---------------------------------------------------------------------
function time02_Callback(hObject, eventdata, handles)
updateevents(hObject, eventdata, handles, 2, 2);
% ---------------------------------------------------------------------
function time03_Callback(hObject, eventdata, handles)
updateevents(hObject, eventdata, handles, 3, 2);
% ---------------------------------------------------------------------
function time04_Callback(hObject, eventdata, handles)
updateevents(hObject, eventdata, handles, 4, 2);
% ---------------------------------------------------------------------
function time05_Callback(hObject, eventdata, handles)
updateevents(hObject, eventdata, handles, 5, 2);
% ---------------------------------------------------------------------
function time06_Callback(hObject, eventdata, handles)
updateevents(hObject, eventdata, handles, 6, 2);
% ---------------------------------------------------------------------
function time07_Callback(hObject, eventdata, handles)
updateevents(hObject, eventdata, handles, 7, 2);
% ---------------------------------------------------------------------
function time08_Callback(hObject, eventdata, handles)
updateevents(hObject, eventdata, handles, 8, 2);
% ---------------------------------------------------------------------
function time09_Callback(hObject, eventdata, handles)
updateevents(hObject, eventdata, handles, 9, 2);
% ---------------------------------------------------------------------
function time10_Callback(hObject, eventdata, handles)
updateevents(hObject, eventdata, handles, 10, 2);
% ---------------------------------------------------------------------
function time11_Callback(hObject, eventdata, handles)
updateevents(hObject, eventdata, handles, 11, 2);
% ---------------------------------------------------------------------
function time12_Callback(hObject, eventdata, handles)
updateevents(hObject, eventdata, handles, 12, 2);

% ---------------------------------------------------------------------
function descr01_Callback(hObject, eventdata, handles)
updateevents(hObject, eventdata, handles, 1, 3);
% ---------------------------------------------------------------------
function descr02_Callback(hObject, eventdata, handles)
updateevents(hObject, eventdata, handles, 2, 3);
% ---------------------------------------------------------------------
function descr03_Callback(hObject, eventdata, handles)
updateevents(hObject, eventdata, handles, 3, 3);
% ---------------------------------------------------------------------
function descr04_Callback(hObject, eventdata, handles)
updateevents(hObject, eventdata, handles, 4, 3);
% ---------------------------------------------------------------------
function descr05_Callback(hObject, eventdata, handles)
updateevents(hObject, eventdata, handles, 5, 3);
% ---------------------------------------------------------------------
function descr06_Callback(hObject, eventdata, handles)
updateevents(hObject, eventdata, handles, 6, 3);
% ---------------------------------------------------------------------
function descr07_Callback(hObject, eventdata, handles)
updateevents(hObject, eventdata, handles, 7, 3);
% ---------------------------------------------------------------------
function descr08_Callback(hObject, eventdata, handles)
updateevents(hObject, eventdata, handles, 8, 3);
% ---------------------------------------------------------------------
function descr09_Callback(hObject, eventdata, handles)
updateevents(hObject, eventdata, handles, 9, 3);
% ---------------------------------------------------------------------
function descr10_Callback(hObject, eventdata, handles)
updateevents(hObject, eventdata, handles, 10, 3);
% ---------------------------------------------------------------------
function descr11_Callback(hObject, eventdata, handles)
updateevents(hObject, eventdata, handles, 11, 3);
% ---------------------------------------------------------------------
function descr12_Callback(hObject, eventdata, handles)
updateevents(hObject, eventdata, handles, 12, 3);

% -------------------------------------------------------------------
function help_btn_Callback(hObject, eventdata, handles)
% Botao Ajuda

helpme('Ferramentas\editoreventos');

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
        
    case {abs('n'),abs('N')} % Novo
        new_btn_Callback(hObject, eventdata, handles);
        
    case {abs('a'),abs('A')} % Abrir
        open_btn_Callback(hObject, eventdata, handles);
        
    case {abs('i'),abs('I')} % Importar
        import_btn_Callback(hObject, eventdata, handles);
        
    case {abs('s'),abs('S')} % Salvar
        save_btn_Callback(hObject, eventdata, handles);
       
end

% ---------------------------------------------------------------------
function window_CloseRequestFcn(hObject, eventdata, handles)
% Funçao de fechamento da janela

cancel_btn_Callback(hObject, eventdata, handles);

% --------------------------------------------------------------------
function ContextMenu_Callback(hObject, eventdata, handles)
% Menu do botao direito

k = find(gco==handles.hlines);
if isempty(k)
    k = find(gco==handles.hcheck);
end
if isempty(k)
    k = find(gco==handles.htimes);
end
if isempty(k)
    k = find(gco==handles.hdescr);
end

if strcmp(get(handles.hcheck(k),'Enable'),'on')
    set([handles.MoveUp handles.MoveDn handles.Copy handles.Cut handles.Paste handles.Delete],'Enable','on');
else
    set([handles.MoveUp handles.MoveDn handles.Copy handles.Cut handles.Paste handles.Delete],'Enable','off');
end

handles.k = k;
guidata(hObject, handles);

% --------------------------------------------------------------------
function New_Callback(hObject, eventdata, handles)
% Novo evento (fim da lista)

N = size(handles.events,1);

handles.events(N+1,:) = {0,NaN,''};
handles.chg = 1;

guidata(hObject, handles);
initialize(hObject, eventdata, handles, N-10);

% --------------------------------------------------------------------
function Insert_Callback(hObject, eventdata, handles)
% Inserir evento no meio da lista

N = size(handles.events,1);
n = str2double(get(handles.hlines(handles.k),'String'));

if ~N
    button = questdlg('Deseja inserir um novo evento?',...
        'Confirmação','Sim','Não','Não'); drawnow;
elseif n >= N
    button = questdlg(['Deseja inserir um novo evento após o evento ' num2str(min(n,N)) '?'],...
        'Confirmação','Sim','Não','Não'); drawnow;
else
    button = questdlg(['Deseja inserir um novo evento entre os eventos ' num2str(n) ' e ' num2str(n+1) '?'],...
        'Confirmação','Sim','Não','Não'); drawnow;
end

if strcmp(button,'Sim')
    if n >= N
        New_Callback(hObject, eventdata, handles);
    else
        handles.events = [handles.events(1:n,:); {0,NaN,''}; handles.events(n+1:end,:)];
        handles.chg = 1;
        
        guidata(hObject, handles);
        initialize(hObject, eventdata, handles);
    end
end

% --------------------------------------------------------------------
function Sort_Callback(hObject, eventdata, handles)
% Ordenar eventos

if isempty(handles.events);
    return
end

button = questdlg('Deseja ordenar os eventos por tempo?','Confirmação','Sim','Não','Não'); drawnow;
if strcmp(button,'Sim')

    [void,ind] = sortrows([handles.events{:,2}]');
    handles.events = handles.events(ind,:);
    handles.chg = 1;
    
    guidata(hObject, handles);
    updatetable(hObject, eventdata, handles);
end

% --------------------------------------------------------------------
function MoveUp_Callback(hObject, eventdata, handles)
% Mover evento para cima

n = str2double(get(handles.hlines(handles.k),'String'));

if n > 1
    aux = handles.events(n-1,:);
    handles.events(n-1,:) = handles.events(n,:);
    handles.events(n,:) = aux;
    handles.chg = 1;
    
    guidata(hObject, handles);
    updatetable(hObject, eventdata, handles);
end

% --------------------------------------------------------------------
function MoveDn_Callback(hObject, eventdata, handles)
% Mover evento para baixo

n = str2double(get(handles.hlines(handles.k),'String'));
N = size(handles.events,1);

if n < N
    aux = handles.events(n+1,:);
    handles.events(n+1,:) = handles.events(n,:);
    handles.events(n,:) = aux;
    handles.chg = 1;
    
    guidata(hObject, handles);
    updatetable(hObject, eventdata, handles);
end

% --------------------------------------------------------------------
function Delete_Callback(hObject, eventdata, handles)
% Apagar evento

n = str2double(get(handles.hlines(handles.k),'String'));

button = questdlg(['Deseja excluir o evento ' num2str(n) '?'],'Confirmação','Sim','Não','Não'); drawnow;
if strcmp(button,'Sim')
    handles.events(n,:) = [];
    handles.chg = 1;
    
    guidata(hObject, handles);
    initialize(hObject, eventdata, handles);
end

% --------------------------------------------------------------------
function DeleteOutside_Callback(hObject, eventdata, handles)
global DADOS
% Apagar eventos fora do intervalo

timecol = get(handles.paramlist,'Value');
Tini = DADOS(1,timecol);
Tend = DADOS(end,timecol);

outs = union(find([handles.events{:,2}] < Tini), find([handles.events{:,2}] > Tend));

if isempty(outs)
    return
elseif length(outs) == 1
    button = questdlg('Deseja excluir 1 evento fora do intervalo?','Confirmação','Sim','Não','Não'); drawnow;
else
    button = questdlg(['Deseja excluir ' num2str(length(outs)) ' eventos fora do intervalo?'],'Confirmação','Sim','Não','Não'); drawnow;
end

if strcmp(button,'Sim')
    handles.events(outs,:) = [];
    handles.chg = 1;
    
    guidata(hObject, handles);
    initialize(hObject, eventdata, handles);
end

% --------------------------------------------------------------------
function DeleteInvalid_Callback(hObject, eventdata, handles)
% Apagar eventos invalidos

invd = find([handles.events{:,1}] == 0);

if isempty(invd)
    return
elseif length(invd) == 1
    button = questdlg('Deseja excluir 1 evento inválido?','Confirmação','Sim','Não','Não'); drawnow;
else
    button = questdlg(['Deseja excluir ' num2str(length(invd)) ' eventos inválidos?'],'Confirmação','Sim','Não','Não'); drawnow;
end

if strcmp(button,'Sim')
    handles.events(invd,:) = [];
    handles.chg = 1;
    
    guidata(hObject, handles);
    initialize(hObject, eventdata, handles);
end

% --------------------------------------------------------------------
function Copy_Callback(hObject, eventdata, handles)
% Copiar evento

n = str2double(get(handles.hlines(handles.k),'String'));

handles.copydata = handles.events(n,:);
guidata(hObject, handles);

% --------------------------------------------------------------------
function Cut_Callback(hObject, eventdata, handles)
% Recortar evento

n = str2double(get(handles.hlines(handles.k),'String'));

handles.copydata = handles.events(n,:);
handles.events(n,:) = {0,NaN,''};
handles.chg = 1;

guidata(hObject, handles);
updatetable(hObject, eventdata, handles);

% --------------------------------------------------------------------
function Paste_Callback(hObject, eventdata, handles)
% Colar evento

if isempty(handles.copydata)
    return
end

n = str2double(get(handles.hlines(handles.k),'String'));

if ~isnan(handles.events{n,2}) || ~isempty(handles.events{n,3})
    button = questdlg(['Deseja substituir o conteúdo do evento ' num2str(n) '?'],'Confirmação','Sim','Não','Não'); drawnow;
else
    button = 'Sim';
end

if strcmp(button,'Sim')
    
    handles.events(n,:) = handles.copydata;
    handles.chg = 1;
    
    guidata(hObject, handles);
    updatetable(hObject, eventdata, handles);
end

% --------------------------------------------------------------------
function new_btn_Callback(hObject, eventdata, handles)
% Nova lista de eventos

button = questdlg('Deseja criar uma nova lista de eventos?','Confirmação','Sim','Não','Não');

if strcmp(button,'Sim')
    
    handles.events = [num2cell(zeros(12,1)), num2cell(NaN*ones(12,1)), cellstr(char(zeros(12,1)))];
    handles.chg = 1;
    
    guidata(hObject, handles);
    initialize(hObject, eventdata, handles, 1);
end

% --------------------------------------------------------------------
function save_btn_Callback(hObject, eventdata, handles)
% Salvar lista de eventos

events  = handles.events;
PARAM   = get(handles.paramlist,'String');
reftime = denumber(PARAM{get(handles.paramlist,'Value')});

[fname, fpath] = uiputfile(handles.fname,'Salvar arquivo de eventos',handles.fpath);
if ischar(fname)
    
    try
        save([fpath fname],'events','reftime',saveopt);
    catch
        beep; uiwait(errordlg(lasterr,'Erro','modal')); drawnow;
        return
    end
    
    handles.fname = fname;
    handles.fpath = fpath;
    guidata(hObject, handles);
    
end

% --------------------------------------------------------------------
function open_btn_Callback(hObject, eventdata, handles)
% Carregar lista de eventos

[fname, fpath] = uigetfile({'*.mat','Arquivo mat (*.mat)'},'Carregar arquivo de eventos',handles.fpath);

if ischar(fname)
    
    try
        load([fpath fname],'events');
        try
            load([fpath fname],'reftime');
        end
    catch
        beep; uiwait(errordlg('Arquivo inválido.','Erro','modal'));
        return
    end
    
    if ~exist('events','var') || isempty(events)
        beep; uiwait(errordlg(['Arquivo ''' fname ''' não contém eventos.'],'Erro','modal'));
        return
    end
    
    if ~iscell(events) || size(events,2) ~= 3 || ~isnumeric([events{:,1:2}]) || isnumeric([events{:,3}])
        beep; uiwait(errordlg('Arquivo de eventos com formato incompatível.','Erro','modal'));
        return
    end
    
    if exist('reftime','var') && ~isempty(deblank(reftime))
        PARAM = get(handles.paramlist,'String');
        tcol = findpar(denumber(PARAM),reftime,0,1);
        if isempty(tcol)
            beep; uiwait(errordlg(['Tempo de referência ''' reftime ''' não encontrado.'],'Erro','modal'));
        else
            set(handles.paramlist,'Value',tcol);
            paramlist_Callback(hObject, eventdata, handles);
        end
    end
    
    for n = 1:size(events,1)
        events{n,1} = ~isequal(events{n,1},0);
    end
    
    handles.chg = 1;
    handles.events = events;
    handles.fname  = fname;
    handles.fpath  = fpath;
    guidata(hObject, handles);
    
    initialize(hObject, eventdata, handles, 1);
    
end

% ---------------------------------------------------------------
function initialize(hObject, eventdata, handles, n1)
% Inicializar lista

N = size(handles.events,1);

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

if N < 12
    set([handles.hdescr(N+1:12) handles.htimes(N+1:12)],'Enable','off','BackgroundColor',get(handles.window,'Color'),'String','');
    set( handles.hcheck(N+1:12),'Enable','off','Value',0);
end
set([handles.hdescr(1:min(12,N)) handles.htimes(1:min(12,N))],'Enable','on','BackgroundColor','w');
set( handles.hcheck(1:min(12,N)),'Enable','on');

updatetable(hObject, eventdata, handles);

% ---------------------------------------------------------------
function updatetable(hObject, eventdata, handles)
% Atualizar tabela

N = size(handles.events,1);
n1 = max(1, N-get(handles.slider,'Value')-10);
d = get(handles.descr01,'Position');

for k = 1:min(12,N)
    n = n1+k-1;
    set(handles.hlines(k),'String',num2str(n));
    set(handles.hcheck(k),'Value',handles.events{n,1});
    set(handles.htimes(k),'String',time2str2(handles.events{n,2}));
    set(handles.hdescr(k),'String',handles.events{n,3});
    
    ext = get(handles.hdescr(k),'Extent');
    if ext(3) > d(3)
        set(handles.hdescr(k),'TooltipString',handles.events{n,3});
    else
        set(handles.hdescr(k),'TooltipString','');
    end
end

% --------------------------------------------------------------------
function updateevents(hObject, eventdata, handles, lin, col)
% Atualizar eventos

switch col
    case 1 % Check
        val = get(handles.hcheck(lin),'Value');
    case 2 % Time
        val = str2time(get(handles.htimes(lin),'String'));
    case 3 % Descr
        val = get(handles.hdescr(lin),'String');
end

N = size(handles.events,1);
n1 = max(1, N-get(handles.slider,'Value')-10);
n = n1+lin-1;

if ~isequal(val,handles.events{n,col});
    handles.events{n,col} = val;
    handles.chg = 1;
    guidata(hObject, handles);
    updatetable(hObject, eventdata, handles)
end

% --------------------------------------------------------------------
function slider_Callback(hObject, eventdata, handles)
% Barra de rolagem

set(handles.slider,'Value',round(get(handles.slider,'Value')));
updatetable(hObject, eventdata, handles);

% --------------------------------------------------------------------
function import_btn_Callback(hObject, eventdata, handles)
% Importar lista de eventos

[fname,fpath,ind] = uigetfile({...
        '*.txt;*.dat', 'Arquivo de texto (*.txt, *.dat)';...
        '*.xls',       'Planilha MS Excel (*.xls)';...
        '*.dat',       'Arquivo de eventos DGPS (photo.dat)';...
        '*.xml',       'Arquivo de eventos do F-5M/A-29 (*.xml)';...
        '*.xml',       'Arquivo de MFLs do F-5M/A-29 (*.xml)'},...
    'Importar arquivo com lista de eventos',handles.fpath); drawnow;

if ~ischar(fname)
    return
end

switch ind
    case {1,3} % .txt / .dat / PHOTO.DAT
        
        try
            [NUM, TXT] = txtread([fpath, fname]);
        catch
            beep; uiwait(errordlg('Arquivo com formato incompatível.','Erro','modal')); drawnow;
            return
        end
        
        if isempty(NUM)
            beep; uiwait(errordlg('Não foram encontrados eventos no arquivo.','Erro','modal')); drawnow;
            return
        end
        
        [Nn, Mn] = size(NUM);
        [Nt, Mt] = size(TXT);
        
        if Nt > Nn
            beep; uiwait(errordlg('Arquivo com formato incompatível.','Erro','modal')); drawnow;
            return
        end
        
        if ind == 3
            
            button = questdlg('Deseja incluir o tempo referente aos dias da semana GPS?','Opção','Sim','Não','Não'); drawnow;
            if strcmp(button,'Sim')
                gpsday = 1;
            else
                gpsday = 0;
            end
            for n = 1:Nn
                events{n,1} = 1;
                events{n,2} = NUM(n,end) + gpsday*NUM(n,end-1)*24*60*60;
                events{n,3} = '';
            end
            
        else
            switch Mn
                case 1 % time
                    for n = 1:Nn
                        events{n,1} = 1;
                        events{n,2} = NUM(n,1);
                    end
                case 2 % val / time
                    for n = 1:Nn
                        events{n,1} = double(NUM(n,1) ~= 0);
                        events{n,2} = NUM(n,2);
                    end
                otherwise
                    beep; uiwait(errordlg('Arquivo com formato incompatível.','Erro','modal')); drawnow;
                    return
            end
            
            if Nt
                for n = 1:Nt
                    events{n,3} = recat(TXT(n,:));
                end
            else
                for n = 1:Nn
                    events{n,3} = '';
                end
            end
            
        end
        
    case 2 % xls
        try
            [NUM, TXT] = xlsread([fpath, fname]);
        catch
            beep; uiwait(errordlg('Arquivo com formato incompatível.','Erro','modal')); drawnow;
            return
        end
        
        if isempty(NUM)
            beep; uiwait(errordlg('Não foram encontrados eventos no arquivo.','Erro','modal')); drawnow;
            return
        end
        
        [Nn, Mn] = size(NUM);
        [Nt, Mt] = size(TXT);
        
        if Nt > Nn
            beep; uiwait(errordlg('Arquivo com formato incompatível.','Erro','modal')); drawnow;
            return
        end
        
        switch Mn
            case 1 % time
                for n = 1:Nn
                    events{n,1} = 1;
                    events{n,2} = NUM(n,1);
                end
            case 2 % val / time
                for n = 1:Nn
                    events{n,1} = double(NUM(n,1) ~= 0);
                    events{n,2} = NUM(n,2);
                end
            otherwise
                beep; uiwait(errordlg('Arquivo com formato incompatível.','Erro','modal')); drawnow;
                return
        end
        
        if Nt
            for n = 1:Nt
                events{n,3} = recat(TXT(n,:));
            end
        else
            for n = 1:Nn
                events{n,3} = '';
            end
        end
        
        opt = RDAT_InputOption('Opção','Informe o formato do parâmetro de tempo na planilha:',{'Segundos','HH:MM:SS'},1,320,1);
        
        if isempty(opt)
            return
        end
        
        if opt == 2 % HH:MM:SS
            for n = 1:size(events,1)
                d0 = floor(events{n,2});
                events{n,2} = ( events{n,2}-d0 ) * 24*3600;
            end
        end

    case {4,5} % Events.xml / MFL.xml
        
        switch ind
            case 4 % Events
                eventtypes    = {'Armament switches', 'Takeoff & landing', 'AA trigger', 'AA launch', 'AG trigger', 'AG release', 'Warnings', 'Fuel warnings', 'Mark, Fix, Acal', 'Stores jettison', 'Chaff/Flare'};
                eventtypesnum = {1, [2 3 4], 5, 6, 7, 8, [9 10], [11 12], [13 14 15], 16, 17};
                opt = RDAT_InputOption('Opção', 'Tipos de evento desejados:', eventtypes, 1:17, 180);
                
                if isempty(opt)
                    return
                elseif ~any(opt)
                    beep; uiwait(errordlg('Não foram selecionados eventos.','Erro','modal')); drawnow;
                    return
                else
                    elist = [];
                    for n = 1:length(opt)
                        if opt(n)
                            elist = [elist eventtypesnum{n}];
                        end
                    end
                end
                
            case 5 % MFLs
                elist = 18;
        end
        
        try
            events = eventsread([fpath, fname],elist);
        catch
            beep; uiwait(errordlg('Arquivo com formato incompatível.','Erro','modal')); drawnow;
            return
        end
        
        if isempty(events)
            switch ind
                case 4
                    beep; uiwait(errordlg('Não foram encontrados eventos no arquivo.','Erro','modal')); drawnow;
                case 5
                    beep; uiwait(errordlg('Não foram encontradas MFLs no arquivo.','Erro','modal')); drawnow;
            end
            return
        end
        
end

if all(isnan([handles.events{:,2}])) && ( isempty(char(handles.events{:,3})) || all(all(char(handles.events{:,3})==' ')) )
    button = 'Substituir';
else
    button = questdlg({'Já há eventos cadastrados.','O que deseja fazer?'},...
        'Opção','Substituir','Adicionar','Cancelar','Substituir'); drawnow;
end

if isempty(button)
    return
end

switch button
    case 'Substituir'
        handles.events = events;
        handles.fname = '*.mat';
    case 'Adicionar'
        handles.events = [handles.events; events];
    otherwise
        return
end

handles.chg = 1;
handles.fpath = fpath;
guidata(hObject, handles);

initialize(hObject, eventdata, handles, 1);

% --------------------------------------------------------------------
function str = recat(strs)
% Concatenar celulas de texto em um texto unico

str = '';
for n = 1:length(strs)
    if ~isempty(strs{n})
        if isempty(str)
            str = strs{n};
        else
            str = [str ' ' strs{n}];
        end
    end
end
