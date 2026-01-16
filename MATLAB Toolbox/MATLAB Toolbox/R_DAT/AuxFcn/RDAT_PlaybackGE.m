function varargout = RDAT_PlaybackGE(varargin)
% RDAT_PLAYBACKGE M-file for RDAT_PlaybackGE.fig
% Last Modified by GUIDE v2.5 05-Jul-2011 15:55:36

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RDAT_PlaybackGE_OpeningFcn, ...
                   'gui_OutputFcn',  @RDAT_PlaybackGE_OutputFcn, ...
                   'gui_LayoutFcn',  @RDAT_PlaybackGE_LayoutFcn, ...
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

% --------------------------------------------------------------------------------------------------
function h = RDAT_PlaybackGE_LayoutFcn(varargin)
% Função de layout inicial

h = openfig('RDAT_PlaybackGE.fig','reuse','invisible');

% ---------------------------------------------------------------
function RDAT_PlaybackGE_OpeningFcn(hObject, eventdata, handles, varargin)
global DADOS DADOS2 hGE
% Funçao de inicializaçao

% set(handles.window,'windowstyle','normal') % @@

bgc = getbuttoncolor(handles.window);
set(handles.help_btn,  'CData',geticon('DatButtons.mat','help',    bgc));
set(handles.ini_btn,   'CData',geticon('DatButtons.mat','ini',     bgc));
set(handles.prev_btn,  'CData',geticon('DatButtons.mat','prev',    bgc));
set(handles.play_btn,  'CData',geticon('DatButtons.mat','play',    bgc));
set(handles.next_btn,  'CData',geticon('DatButtons.mat','next',    bgc));
set(handles.goto_btn,  'CData',geticon('DatButtons.mat','goto',    bgc));
set(handles.throwscen_btn,'CData',geticon('DatButtons.mat','scenario',bgc));

if isempty(varargin)
    beep; uiwait(errordlg('Dados não fornecidos.','Erro','modal'));
    handles.ok = 0;
    guidata(hObject, handles);
    uiresume;
    return
end

ss = get(0,'ScreenSize');
ws = get(handles.window,'Position');
set(handles.window,'Position',[(ss(3)-ws(3))-10, 50, ws(3), ws(4)],'Visible','off');

if length(varargin) >= 1
    PARAM = varargin{1};
end
if length(varargin) >= 2
    N = varargin{2};
else
    N = 1;
end
if length(varargin) >= 3
    setup = varargin{3};
else
    setup = [];
end
if length(varargin) >= 4
    scenario = varargin{4};
else
    scenario = [];
end
if length(varargin) >= 5
    events = varargin{5};
else
    events = [];
end
if length(varargin) >= 6
    testpts = varargin{6};
else
    testpts = [];
end

try
    hGE.IsInitialized;
catch
    try
        hGE = actxserver('GoogleEarth.ApplicationGE');
    catch
        beep; uiwait(errordlg({'Erro ao inicializar aplicativo.',...
                'Verifique se o Google Earth está instalado corretamente.'},'Erro','modal')); drawnow;
        handles.ok = 0;
        guidata(hObject, handles);
        uiresume;
        return
    end
end

% --- BACKWARD COMPATIBILITY ----
setup    = backcompat(setup,'setup');
scenario = backcompat(scenario,'scenario');
% -------------------------------

handles.sellist = [handles.time_sel handles.Zp_sel handles.Vc_sel handles.M_sel handles.lat_sel handles.lon_sel,...
        handles.Nz_sel handles.psi_sel handles.tet_sel handles.phi_sel,...
        handles.Raz_sel handles.Rel_sel handles.Rrng_sel handles.Rpsi_sel,...
        ];
handles.displist = [handles.time_disp handles.Zp_disp handles.Vc_disp handles.M_disp handles.lat_disp handles.lon_disp,...
        handles.Nz_disp handles.psi_disp handles.tet_disp handles.phi_disp,...
        handles.Raz_disp handles.Rel_disp handles.Rrng_disp handles.Rpsi_disp,...
        ];

set(handles.sellist,'String',char(' ',char(PARAM)),'Value',1);

% Variaveis de dados
if isempty(setup)
    setup.params = [];
end
if isempty(scenario)
    d = clock;
    scenario.date = [num2str(d(3),'%02.0f') '/' num2str(d(2),'%02.0f') '/' num2str(d(1))];
    scenario.Dmag = 0;
end

% Listagem e verificaçao de todos os parametros
handles.paramtags = {'time','Zp','Vc','M','lat','lon','Nz','psi','tet','phi',...
        'Raz','Rel','Rrng','Rpsi'};
for n = 1:length(handles.paramtags)
    if ~isfield(setup.params,handles.paramtags{n})
        setup.params.(handles.paramtags{n}) = '';
    end
end

% Constantes
Nobs = size(DADOS,1);
handles.steps  = [-20 -10 -5 -2 -1 -.5 -.2 -.1 .1 .2 .5 0 1 2 5 10 20];
steps_str = num2str2(handles.steps');
steps_str(12,:) = 'Auto';
set(handles.step_sel,'String',steps_str,'Value',12);

% Armazenamento das constantes
handles.ok = 0;
handles.Nobs = Nobs;
handles.events = events;
handles.testpts = testpts;
setappdata(handles.window,'N',N);
setappdata(handles.window,'scenario',scenario);
setappdata(handles.window,'camalt',2000);
DADOS2 = zeros(Nobs,4); % [evt, testpt, dt, freq]

guidata(hObject, handles);

% Configuraçao dos dados
setplaybackdata(hObject, eventdata, handles, setup, scenario);

togglesize_btn_Callback(hObject, eventdata, handles);
uiwait(handles.window);

% ---------------------------------------------------------------
function varargout = RDAT_PlaybackGE_OutputFcn(hObject, eventdata, handles)
global DADOS2 hGE
% Funçao de saida

clear global DADOS2 hGE
delete(handles.window);

%--------------------------------------------------------------------------
function togglesize_btn_Callback(hObject, eventdata, handles)
% Expande/Reduz o tamanho da janela de controle

set(handles.togglesize_btn,'Value',0);
ws = get(handles.window,'Position');

switch get(handles.togglesize_btn,'String')
    case '+'
        set(handles.togglesize_btn,'String','-','TooltipString','Reduzir');
        set(handles.window,'Position',[ws(1) ws(2) ws(3) 310]);
        
    case '-'
        set(handles.togglesize_btn,'String','+','TooltipString','Expandir');
        set(handles.window,'Position',[ws(1) ws(2) ws(3) 52]);
       
end

% ---------------------------------------------------------------
function play_btn_Callback(hObject, eventdata, handles)
global DADOS2
% Executar

N = getappdata(handles.window,'N');
step = handles.steps(get(handles.step_sel,'Value'));
fps = getappdata(handles.window,'fps');

if step >= 0 && N == handles.Nobs
    N = 1;
end

tic;
count = 0;

while ishandle(handles.window) && get(handles.play_btn,'Value')
    
    step = handles.steps(get(handles.step_sel,'Value'));
    if ~step % Auto
        n_time = get(handles.time_sel,'Value')-1;
        if n_time
            nps = DADOS2(round(N),4);
            if ~isempty(nps)
                step = nps/fps;
            else
                step = 1;
            end
            set(handles.step_txt,'String',['Passo: ' num2str(step,'%0.1f')]);
        else
            step = 1;
            set(handles.step_sel,'Value',get(handles.step_sel,'Value')+1);
            set(handles.step_txt,'String','');
        end
    else
        set(handles.step_txt,'String','');
    end
    
    N = max(1,min(handles.Nobs,N+step));
    setappdata(handles.window,'N',N);
    
    updateplot(hObject, eventdata, handles);
    count = count+1;
    
    N = getappdata(handles.window,'N');
    
    if step < 0 && N == 1
        break
    end
    if step > 0 && N == handles.Nobs
        break
    end
    
    if toc > 1
        fps = count/toc;
        set(handles.fps_txt,'String',['Fps: ' num2str(fps,'%0.1f')]);
        count = 0;
        tic;
    end
    
end

set(handles.play_btn,'Value',0);
set([handles.step_txt handles.fps_txt],'String','');
setappdata(handles.window,'fps',fps);

% ---------------------------------------------------------------
function ini_btn_Callback(hObject, eventdata, handles)
% Vai para o inicio

set(handles.play_btn,'Value',0);

if ishandle(handles.window) && ~get(handles.play_btn,'Value')
    setappdata(handles.window,'N',1);
    updateplot(hObject, eventdata, handles);
end

set(handles.ini_btn,'Value',0);

% ---------------------------------------------------------------
function next_btn_Callback(hObject, eventdata, handles)
% Avança um passo

set(handles.play_btn,'Value',0);

N = round(getappdata(handles.window,'N'));
step = max(1,abs(handles.steps(get(handles.step_sel,'Value'))));

if ishandle(handles.window) && ~get(handles.play_btn,'Value')
    N = min(handles.Nobs,N+step);
    setappdata(handles.window,'N',N);
    updateplot(hObject, eventdata, handles);
end

set(handles.next_btn,'Value',0);

% ---------------------------------------------------------------
function prev_btn_Callback(hObject, eventdata, handles)
% Regressa um passo

set(handles.play_btn,'Value',0);

N = round(getappdata(handles.window,'N'));
step = max(1,abs(handles.steps(get(handles.step_sel,'Value'))));

if ishandle(handles.window) && ~get(handles.play_btn,'Value')
    N = max(1,N-step);
    setappdata(handles.window,'N',N);
    updateplot(hObject, eventdata, handles);
end

set(handles.prev_btn,'Value',0);

%--------------------------------------------------------------------------
function goto_btn_Callback(hObject, eventdata, handles)
global DADOS
% Ir para

n_time  = get(handles.time_sel,'Value')-1;

if ~n_time
    beep; uiwait(errordlg('Parâmetro de tempo não definido.','Erro','modal')); drawnow;
    return
end

if ~IsTimeOk(DADOS(:,n_time))
    beep; uiwait(errordlg('Parâmetro de tempo não é adequado.','Erro','modal')); drawnow;
    return
end

t = RDAT_GoTo(handles.events,handles.testpts);

if isempty(t)
    return
end

T = DADOS(:,n_time);

if t < T(1) || t > T(end)
    beep; uiwait(errordlg({['Tempo ' time2str2(t) ' fora do intervalo de dados'],[time2str2(T(1)) ' a ' time2str2(T(end)) ' h.']},...
        'Erro','modal')); drawnow;
    return
end

N = find(T>=t);
N = N(1);

setappdata(handles.window,'N',N);
set(handles.NoOBS,'String',num2str(N));
updateplot(hObject, eventdata, handles);

%--------------------------------------------------------------------------
function throwscen_btn_Callback(hObject, eventdata, handles)
global DADOS hGE
% Exporta o cenario e a trajetoria para o Google Earth

try
    hGE.IsInitialized;
catch
    beep; uiwait(errordlg('A instância do Google Earth aberta pelo R_DAT não foi encontrada.','Erro','modal')); drawnow;
    return
end

% Exportar cenario

scenario = getappdata(handles.window,'scenario');

if isempty(scenario)
    uiwait(errordlg('Cenário não definido.','Erro','modal')); drawnow;
else
    
    kmldata = [];
    N = 0;
    
    if ~isempty(scenario.aux) % Objetos auxiliares
        
        for n = 1:length(scenario.aux)        
            if ~isempty(scenario.aux(n).data)
                
                switch scenario.aux(n).type
                    case 'point'
                        kmldata(N+1).data   = scenario.aux(n).data(:,1:2);
                        kmldata(N+1).type   = scenario.aux(n).type;
                        kmldata(N+1).name   = scenario.aux(n).code;
                        kmldata(N+1).descr  = '';
                        kmldata(N+1).folder = ['Objeto auxiliar - ' scenario.aux(n).name];
                        kmldata(N+1).color  = scenario.aux(n).color;
                        kmldata(N+1).width  = scenario.aux(n).width;
                        N = N + 1;
                    case {'line','area'}
                        kmldata(N+1).data   = scenario.aux(n).data(:,1:2);
                        kmldata(N+1).type   = scenario.aux(n).type;
                        kmldata(N+1).name   = scenario.aux(n).name;
                        kmldata(N+1).descr  = '';
                        kmldata(N+1).folder = 'Objetos auxiliares';
                        kmldata(N+1).color  = scenario.aux(n).color;
                        kmldata(N+1).width  = scenario.aux(n).width;
                        N = N + 1;
                end
                
            end
        end
    end
    
    if ~isempty(scenario.aid) && ~isempty(scenario.aid.data) % Nav Aids
        
        kmldata(N+1).data   = scenario.aid.data(:,1:3);
        kmldata(N+1).type   = 'point';
        kmldata(N+1).name   = scenario.aid.code;
        for n = 1:size(scenario.aid.data,1)
            kmldata(N+1).descr{n} = scenario.aid.type{n};
        end
        kmldata(N+1).folder = 'Auxílios/Aeródromos';
        kmldata(N+1).color  = [0 .5 1];
        kmldata(N+1).width  = 1;
        N = N + 1;
        
    end
    
    if ~isempty(scenario.wpt) && ~isempty(scenario.wpt.data) % Waypoints
        
        kmldata(N+1).data   = scenario.wpt.data(:,2:4);
        kmldata(N+1).type   = 'point';
        for n = 1:size(scenario.wpt.data,1)
            kmldata(N+1).name{n} = [num2str(scenario.wpt.data(n,1),'%02.0f') ' - ' scenario.wpt.code{n}];
        end
        kmldata(N+1).descr  = '';
        kmldata(N+1).folder = 'Waypoints';
        kmldata(N+1).color  = 'm';
        kmldata(N+1).width  = 1;
        N = N + 1;
        
    end
    
    for n = 1:length(scenario.rt) % Routes
        
        wpt = scenario.rt(n).wpt;
        if ~isempty(wpt)
            nwpt = [];
            for k = 1:length(wpt)
                nwpt = [nwpt find(wpt(k)==scenario.wpt.data(:,1))];
            end
            kmldata(N+1).data   = scenario.wpt.data(nwpt,2:4);
            kmldata(N+1).type   = 'line';
            kmldata(N+1).name   = ['Rota ' num2str(n)];
            kmldata(N+1).descr  = '';
            kmldata(N+1).folder = 'Rotas';
            kmldata(N+1).color  = 'm';
            kmldata(N+1).width  = 2;
            N = N + 1;
        end
        
    end
    
    for n = 1:length(scenario.fa) % Flight Areas
        
        if ~isempty(scenario.fa(n).data)
            kmldata(N+1).data   = scenario.fa(n).data;
            kmldata(N+1).type   = 'line';
            kmldata(N+1).name   = scenario.fa(n).code;
            kmldata(N+1).descr  = scenario.fa(n).descr;
            kmldata(N+1).color  = scenario.fa(n).color;
            kmldata(N+1).folder = 'Áreas de voo';
            kmldata(N+1).width  = 2;
            N = N + 1;
        end
        
    end
    
    if ~isempty(scenario.avd) % Avoid Zones
        
        for n = 1:size(scenario.avd.data,1)
            
            Xavd = scenario.avd.data(n,2);
            Yavd = scenario.avd.data(n,1);
            Ravd = scenario.avd.data(n,3);
            [Ry, Rx] = dxdy2latlong(Yavd,Xavd,Ravd*1852,Ravd*1852);
            Ry = Ry-Yavd;
            Rx = Rx-Xavd;
            
            kmldata(N+1).data   = [Yavd+Ry*sin(linspace(0,2*pi,36)') Xavd+Rx*cos(linspace(0,2*pi,36)')];
            kmldata(N+1).type   = 'line';
            kmldata(N+1).name   = scenario.avd.code{n};
            kmldata(N+1).descr  = '';
            kmldata(N+1).color  = 'y';
            kmldata(N+1).folder = 'Avoid zones';
            kmldata(N+1).width  = 2;
            N = N + 1;
        end
        
    end
    
    if ~isempty(scenario.thr) % Ameaças
        
        for n = 1:size(scenario.thr.data,1)
            
            Xthr = scenario.thr.data(n,2);
            Ythr = scenario.thr.data(n,1);
            Rthr1 = scenario.thr.data(n,5);
            Rthr2 = scenario.thr.data(n,6);
            [Ry1, Rx1] = dxdy2latlong(Ythr,Xthr,Rthr1*1852,Rthr1*1852);
            Ry1 = Ry1-Ythr;
            Rx1 = Rx1-Xthr;
            [Ry2, Rx2] = dxdy2latlong(Ythr,Xthr,Rthr2*1852,Rthr2*1852);
            Ry2 = Ry2-Ythr;
            Rx2 = Rx2-Xthr;
            
            kmldata(N+1).data   = [Ythr+[Ry1*sin(linspace(0,2*pi,36)') NaN Ry2*sin(linspace(0,2*pi,36)')] Xthr+[Rx1*cos(linspace(0,2*pi,36)') NaN Rx2*cos(linspace(0,2*pi,36)')]];
            kmldata(N+1).type   = 'line';
            kmldata(N+1).name   = scenario.thr.code{n};
            kmldata(N+1).descr  = '';
            kmldata(N+1).color  = 'r';
            kmldata(N+1).folder = 'Ameaças';
            kmldata(N+1).width  = 2;
            N = N + 1;
        end
        
    end
    
    if ~isempty(scenario.cnt) && ~isempty(scenario.cnt.data) % Contact Line
        
        kmldata(N+1).data   = scenario.cnt.data;
        kmldata(N+1).type   = 'line';
        kmldata(N+1).name   = 'Linha de contato';
        kmldata(N+1).descr  = '';
        kmldata(N+1).folder = 'Linhas de contato';
        kmldata(N+1).color  = 'r';
        kmldata(N+1).width  = 2;
        
    end
    
    if isempty(kmldata)
        return
    end
    
    try
        fname = [tempdir 'tempfile.kml'];
        for m = 1:length(kmldata)
            if size(kmldata(m).data,2) == 3
                kmldata(m).data(:,3) = kmldata(m).data(:,3)*.3048; % ft -> m
            end
        end
        kmlwrite(kmldata,fname,'Cenário');
    end
    
    if exist(fname,'file')
        button = questdlg('Deseja carregar o cenário?','Confirmação','Sim','Não','Sim');
        if strcmp(button,'Sim')
            dos(fname);
        end
        delete(fname);
    end
end


% Exportar trajetoria de voo

kmldata = [];
n_alt = get(handles.Zp_sel  ,'Value')-1;
n_lat = get(handles.lat_sel ,'Value')-1;
n_lon = get(handles.lon_sel ,'Value')-1;

if n_lat && n_lon
    
    lat = DADOS(:,n_lat);
    lon = DADOS(:,n_lon);
    if ~n_alt
        alt = 0*lat;
    else
        alt = DADOS(:,n_alt)*.3048;
    end
    
    kmldata.data   = [lat lon alt];
    kmldata.type   = 'line';
    kmldata.name   = 'Trajetória do voo';
    kmldata.descr  = '';
    kmldata.folder = 'Aeronave';
    kmldata.color  = 'w';
    kmldata.width  = 2;
    
    fname = [tempdir 'tempfile2.kml'];
    kmlwrite(kmldata,fname,'Trajetórias');
    if exist(fname,'file')
        button = questdlg('Deseja carregar a trajetória do voo?','Confirmação','Sim','Não','Sim');
        if strcmp(button,'Sim')
            dos(fname);
        end
        delete(fname);
    end
    
end

% ---------------------------------------------------------------
function updateplot(hObject, eventdata, handles)
global DADOS hGE
% Atualizaçao de todas as telas

N = round(getappdata(handles.window,'N'));

% Data collection

% Common data
n_Zp    = get(handles.Zp_sel  ,'Value')-1;
n_lat   = get(handles.lat_sel ,'Value')-1;
n_lon   = get(handles.lon_sel ,'Value')-1;
n_psi   = get(handles.psi_sel ,'Value')-1;
n_tet   = get(handles.tet_sel ,'Value')-1;
n_phi   = get(handles.phi_sel ,'Value')-1;
n_Raz   = get(handles.Raz_sel ,'Value')-1;
n_Rel   = get(handles.Rel_sel ,'Value')-1;
n_Rrng  = get(handles.Rrng_sel,'Value')-1;

if n_Zp
    Zp = DADOS(N,n_Zp);
else
    Zp = NaN;
end
if n_lat
    lat = DADOS(N,n_lat);
else
    lat = NaN;
end
if n_lon
    lon = DADOS(N,n_lon);
else
    lon = NaN;
end
if n_psi
    psi = mod(DADOS(N,n_psi),360);
else
    psi = NaN;
end
if n_tet
    tet = DADOS(N,n_tet);
else
    tet = 0;
end
if n_phi
    phi = DADOS(N,n_phi);
else
    phi = 0;
end
[tet, phi] = attfix(tet,phi);
if n_Raz
    Raz = DADOS(N,n_Raz);
else
    Raz = NaN;
end
if n_Rel
    Rel = DADOS(N,n_Rel);
else
    Rel = NaN;
end
if n_Rrng
    Rrng = DADOS(N,n_Rrng);
else
    Rrng = NaN;
end

phi = mod(phi,360);
if phi>180, phi = phi - 360; end

Dmag = str2double(get(handles.Dmag_entry,'String'));
tpsi = psi + Dmag;

% Monitors
for n = 1:length(handles.sellist)
    nsel = get(handles.sellist(n),'Value')-1;
    if nsel
        str = num2str(DADOS(N,nsel));
    else
        str = '';
    end
    set(handles.displist(n),'String',str,'TooltipString',str);
end

set(handles.NoOBS,'String',num2str(N));

if get(handles.HUD_chk,'Value')
    alt = max(0,Zp*.3048);
    altMode = 2;
    range = 0;
    tilt = max(0,min(90,tet+90));
    heading = tpsi;
    speed = 10;
else
    alt = getappdata(handles.window,'camalt');
    altMode = 2;
    range = 0;
    tilt = 0;
    heading = tpsi;
    speed = 10;
end

if get(handles.play_btn,'Value')
    try
        hGE.IsInitialized;
    catch
        beep; uiwait(errordlg('A instância do Google Earth aberta pelo R_DAT não foi encontrada.','Erro','modal')); drawnow;
        set(handles.play_btn,'Value',0);
        return
    end
    if get(handles.HUD_chk,'Value') && (~n_lat || ~n_lon || ~n_Zp || ~n_psi) || get(handles.TSD_chk,'Value') && (~n_lat || ~n_lon)
        beep; uiwait(errordlg('Parâmetros não definidos.','Erro','modal')); drawnow;
        set(handles.play_btn,'Value',0);
        return
    end
end

if ~isnan(lat+lon+alt)
    try
        hGE.SetCameraParams(lat,lon,alt,altMode,range,tilt,heading,speed);
        pause(.01);
    end
end

%--------------------------------------------------------------------------
function window_KeyPressFcn(hObject, eventdata, handles)
% Acionamento de tecla do teclado

cc = get(handles.window,'CurrentCharacter');

if isempty(cc)
    return
end

switch abs(cc)
    
    case 28 % <--
        prev_btn_Callback(hObject, eventdata, handles);
        
    case 29 % -->
        next_btn_Callback(hObject, eventdata, handles);
        
    case 31 % Down
        n = get(handles.step_sel,'Value');
        if n > 1
            set(handles.step_sel,'Value',n-1);
        end
        
    case 30 % Up
        n = get(handles.step_sel,'Value');
        if n < length(handles.steps)
            set(handles.step_sel,'Value',n+1);
        end

    case abs('1')
        n = find(handles.steps==1);
        set(handles.step_sel,'Value',n);
        
    case abs('0')
        ini_btn_Callback(hObject, eventdata, handles);
        
    case abs('+')
        scaledn_btn_Callback(hObject, eventdata, handles);
        
    case abs('-')
        scaleup_btn_Callback(hObject, eventdata, handles);
        
    case 32 % Espaço
        set(handles.play_btn,'Value',~get(handles.play_btn,'Value'));
        play_btn_Callback(hObject, eventdata, handles);
        
    case {abs('h'),abs('H')}
        HUD_chk_Callback(hObject, eventdata, handles);
        
    case {abs('t'),abs('T')}
        LTSD_chk_Callback(hObject, eventdata, handles);
        
    case 13 % Enter
        ok_btn_Callback(hObject, eventdata, handles);
        
    case 27 % Esc
        window_CloseRequestFcn(hObject, eventdata, handles);
        
end

% ---------------------------------------------------------------
function window_CloseRequestFcn(hObject, eventdata, handles)
% Funçao de fechamento da janela

set(handles.play_btn,'Value',0);
button = questdlg('Deseja sair?','Confirmação','Sim','Não','Não');
if strcmp(button,'Sim')
    uiresume;            
end

% --------------------------------------------------------------------
function calcDmagmenu_Callback(hObject, eventdata, handles)
% Menu do campo de Declinaçao magnetica

set(handles.play_btn,'Value',0);

% --------------------------------------------------------------------
function DmagModel_Callback(hObject, eventdata, handles)
global DADOS
% Calculo da declinaçao magnetica a partir do modelo magnetico terrestre

PARAM = cellstr(get(handles.time_sel,'String'));
PARAM(1) = [];

PARAM1 = PARAM;
PARAM2 = PARAM;
PARAM3 = PARAM;
n_lat = get(handles.lat_sel ,'Value')-1;
n_lon = get(handles.lon_sel ,'Value')-1;
n_alt = get(handles.Zp_sel  ,'Value')-1;

if n_lat
    PARAM1{end+1} = n_lat;
end
if n_lon
    PARAM2{end+1} = n_lon;
end
if n_alt
    PARAM3{end+1} = n_alt;
end

[n_lat, n_lon, n_alt, dat] = inputvalues('Modelo Dmag',{'Latitude (°):','Longitude (°):','Altitude geodética (ft):','Data'},{PARAM1,PARAM2,PARAM3,''});

if ~isempty(n_lat)
    lat = nanmean(DADOS(:,n_lat));
    lon = nanmean(DADOS(:,n_lon));
    alt = nanmean(DADOS(:,n_alt));
    [void,void,dat] = dateread(dat);
    if isempty(dat)
        beep; uiwait(errordlg('Informe a data do voo.','Erro','modal')); drawnow;
        return
    end
 
    [Dmag, void, void, void, epoch] = geomag(alt, lat, lon, dat);
    if dat < epoch || dat >= epoch+5
        uiwait(warndlg({'Não foi encontrado o arquivo de coeficientes correspondente'...
                ['à época do voo (' num2str(fix(dat)) ' a ' num2str(fix(dat)+5) ').'],...
                ['Foi utilizada a época atual (' num2str(epoch) ' a ' num2str(epoch+5) ')']},'Aviso','modal')); drawnow;
    end

    set(handles.Dmag_entry,'String',num2str(roundn(Dmag,-2)));
    Dmag_entry_Callback(hObject, eventdata, handles);
end

% --------------------------------------------------------------------
function DmagDpsi_Callback(hObject, eventdata, handles)
global DADOS
% Calculo da declinaçao magnetica a partir de PSI_mag e PSI_true

PARAM = cellstr(get(handles.time_sel,'String'));
PARAM(1) = [];

PARAM1 = PARAM;
PARAM2 = PARAM;
n_tpsi = findpar(PARAM,'True_Head',0,0);
n_psi  = get(handles.psi_sel,'Value')-1;
if n_psi
    PARAM1{end+1} = n_psi;
end
if n_tpsi
    PARAM2{end+1} = n_tpsi;
end

[n_PSIm, n_PSIt] = inputvalues('Calcular Dmag',{'Proa magnética (°):','Proa verdadeira (°):'},{PARAM1,PARAM2});

if ~isempty(n_PSIm)
    Dmag = nanmean(mod(DADOS(:,n_PSIt)-DADOS(:,n_PSIm),360));
    if isnan(Dmag),
        Dmag = 0;
    elseif Dmag > 180
        Dmag = Dmag - 360;
    end
    set(handles.Dmag_entry,'String',num2str(roundn(Dmag,-2)));
    Dmag_entry_Callback(hObject, eventdata, handles);
end

% --------------------------------------------------------------------
function DmagParam_Callback(hObject, eventdata, handles)
global DADOS
% Calculo da declinaçao magnetica pela media de um parametro Dmag

PARAM = cellstr(get(handles.time_sel,'String'));
PARAM(1) = [];

n_Dmag = findpar(PARAM,{'Dmag','Declin'},0,0);

if n_Dmag
    PARAM{end+1} = n_Dmag;
end

n_Dmag = inputvalues('Calcular Dmag','Parâmetro Dmag (°):',PARAM);

if ~isempty(n_Dmag)
    Dmag = nanmean(mod(DADOS(:,n_Dmag),360));
    if isnan(Dmag),
        Dmag = 0;
    elseif Dmag > 180
        Dmag = Dmag - 360;
    end
    set(handles.Dmag_entry,'String',num2str(roundn(Dmag,-2)));
    Dmag_entry_Callback(hObject, eventdata, handles);
end

% ---------------------------------------------------------------
function setplaybackdata(hObject, eventdata, handles, setup, scenario)
% Configura os parametros e cria o cenario

% Flags
stp  = 0; % Setup loading
nf   = 0; % Param failure
nok  = 0; % Param loaded
cerr = 0; % Config error

if ~isempty(setup) % Carregar config
    
    try
        if ~isempty(handles.paramtags)
            PARAM = denumber(cellstr(get(handles.time_sel,'String')));
            PARAM(1) = [];
            
            PARAM = SetUnits(PARAM);
            paramlist = SetUnits(struct2cell(setup.params));
            setup.params = cell2struct(paramlist,fieldnames(setup.params));
            
            for n = 1:length(handles.paramtags)
                if isfield(setup.params,handles.paramtags{n})
                    parname = setup.params.(handles.paramtags{n});
                    if ~isempty(parname)
                        npar = findpar(PARAM,parname,0,1);
                        if ~isempty(npar)
                            nok = nok + 1;
                        else
                            npar = 0;
                            nf = nf + 1;
                        end
                    else
                        npar = 0;
                    end
                else
                    npar = 0;
                end
                set(handles.([handles.paramtags{n} '_sel']),'Value',npar+1);
                if n == 1
                    time_sel_Callback(hObject, eventdata, handles, 0);
                end
            end
            stp = 1;
        end
        
    catch
        set(handles.sellist,'Value',1);
        cerr = 1;
    end
end

if ~isempty(scenario) % Carregar cenario
    
    if ~isfield(scenario,'Dmag'), scenario.Dmag = 0;  end
    set(handles.Dmag_entry,'String',num2str(scenario.Dmag));
    
end

setappdata(handles.window,'scenario',scenario);

guidata(hObject, handles);

% Initial framerate estimation
count = 0;
tic;
while toc < 1
    updateplot(hObject, eventdata, handles);
    count = count+1;
end
fps = count/toc;
setappdata(handles.window,'fps',fps);

set(handles.window,'Pointer','arrow');

%--------------------------------------------------------------------------
function time_sel_Callback(hObject, eventdata, handles, updt)
global DADOS DADOS2
% Seletor do parametro de tempo

if nargin == 3
    updt = 1;
end

set(handles.window,'Pointer','watch');
drawnow;

n_time  = get(handles.time_sel,'Value')-1;

if n_time
    T = DADOS(:,n_time);

    [ok, ndc, nna] = IsTimeOk(T);
    if ok
        Nobs = handles.Nobs;
        for n = [3:5:Nobs Nobs]
            k1 = max(1,n-2);
            k2 = min(Nobs,n+2);
            
            DADOS2(k1:k2,3) = nanmean(diff(T(max(1,round(n)-10):min(Nobs,round(n)+10))));
            DADOS2(k1:k2,4) = getfreq(T(max(1,round(n)-10):min(Nobs,round(n)+10)));
        end
    else
        beep; uiwait(errordlg({'Parâmetro de tempo não é adequado:',' ',...
                ['Pontos inválidos: ' num2str(length(nna))],...
                ['Pontos não crescentes: ' num2str(length(ndc))]},'Erro','modal')); drawnow;
        set(handles.time_sel,'Value',1);
        DADOS2(:,[3 4]) = zeros(handles.Nobs,2);
    end
else
    DADOS2(:,[3 4]) = zeros(handles.Nobs,2);
end

if updt
    DADOS2(:,[1 2]) = zeros(handles.Nobs,2);
    setevents(hObject, eventdata, handles);
    settestpts(hObject, eventdata, handles);
end

set(handles.window,'Pointer','arrow');
drawnow;

if updt
    updateplot(hObject, eventdata, handles);
end

% --------------------------------------------------------------------
function Dmag_entry_Callback(hObject, eventdata, handles)
% Inserçao manual de declinaçao magnetica

Dmag = str2double(get(handles.Dmag_entry,'String'));
if isnan(Dmag)
    str = '0';
    set(handles.Dmag_entry,'String','0');
else
    Dmag = mod(Dmag,360);
    if Dmag > 180, Dmag = Dmag - 360; end
    str = num2str(roundn(Dmag,-2));
end

set(handles.Dmag_entry,'String',str);
updateplot(hObject, eventdata, handles);

% ---------------------------------------------------------------
function NoOBS_Callback(hObject, eventdata, handles)
% Entrada direta do numero do frame

N = round(getappdata(handles.window,'N'));
N2 = round(str2double(get(handles.NoOBS,'String')));

if ~isnan(N2) && N2 ~= N
    N2 = max(1,min(N2,handles.Nobs));
    setappdata(handles.window,'N',N2);
else
    N2 = N;
end

set(handles.NoOBS,'String',num2str(N2));
updateplot(hObject, eventdata, handles);

% -------------------------------------------------------------------
function help_btn_Callback(hObject, eventdata, handles)
% Botao Ajuda

helpme('Ferramentas\reproduzirvooGE');

% ---------------------------------------------------------------
function ok_btn_Callback(hObject, eventdata, handles)
% Botao OK

set(handles.play_btn,'Value',0);
button = questdlg('Deseja sair?','Confirmação','Sim','Não','Não');
if strcmp(button,'Sim')
    handles.ok = 1;
    guidata(hObject, handles);
    uiresume;            
end

% ---------------------------------------------------------------
function HUD_chk_Callback(hObject, eventdata, handles)
% Seleciona HUD&ENG na tela da esquerda

set(handles.HUD_chk,'Value',1);
set(handles.TSD_chk,'Value',0);
set([handles.goup_btn handles.godn_btn handles.camalt_txt],'Visible','off');
updateplot(hObject, eventdata, handles);

% ---------------------------------------------------------------
function TSD_chk_Callback(hObject, eventdata, handles)
% Seleciona TSD na tela da esquerda

set(handles.TSD_chk,'Value',1);
set(handles.HUD_chk,'Value',0);
set([handles.goup_btn handles.godn_btn handles.camalt_txt],'Visible','on');
updateplot(hObject, eventdata, handles);

%--------------------------------------------------------------------------
function goup_btn_Callback(hObject, eventdata, handles)
% Elevar a altitude da camera

set(handles.goup_btn,'Value',0);
alt = getappdata(handles.window,'camalt');
setappdata(handles.window,'camalt',min(1024000,2*alt));
updateplot(hObject, eventdata, handles);

%--------------------------------------------------------------------------
function godn_btn_Callback(hObject, eventdata, handles)
% Reduzir a altitude da camera

set(handles.godn_btn,'Value',0);
alt = getappdata(handles.window,'camalt');
setappdata(handles.window,'camalt',max(250,alt/2));
updateplot(hObject, eventdata, handles);

%--------------------------------------------------------------------------
function Po = tgt2earth(Pb, psi, tet, phi, x, y, z)
% Funçao de conversao de coordenadas do sistema do corpo para o da terra
% - Rotaciona de psi, teta, phi
% - Translada para x, y, z

psi = psi * pi/180;
tet = tet * pi/180;
phi = phi * pi/180;

Po = zeros(size(Pb));

for n = 1:length(psi)
    
    R = [1 0 0; 0 cos(phi(n)) sin(phi(n)); 0 -sin(phi(n)) cos(phi(n))]*...
        [cos(tet(n)) 0 sin(tet(n)); 0 1 0; sin(tet(n)) 0 cos(tet(n))]*...
        [sin(psi(n)) cos(psi(n)) 0; -cos(psi(n)) sin(psi(n)) 0; 0 0 1];
    
    Po(n,:) = Pb(n,:)*R + [x(n) y(n) z(n)];
end

% ---------------------------------------------------------------
function [tet, phi] = attfix(tet,phi)
% Mantem a atitude no dominio [-90 90]

tet = mod(tet,360);
tet(tet>180) = tet(tet>180) - 360;

phi(tet> 90) = phi(tet> 90)+180;
phi(tet<-90) = phi(tet<-90)+180;

tet(tet> 90) =  180 - tet(tet> 90);
tet(tet<-90) = -180 - tet(tet<-90);

%--------------------------------------------------------------------------
function pos = denanpos(pos)
% Evita bug de "NaN" na propriedade "Position" do texto

pos(isnan(pos)) = -10000;

