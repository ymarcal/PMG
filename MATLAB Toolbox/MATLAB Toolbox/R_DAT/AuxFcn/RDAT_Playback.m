function varargout = RDAT_Playback(varargin)
% RDAT_PLAYBACK M-file for RDAT_Playback.fig
% Last Modified by GUIDE v2.5 29-Feb-2012 16:26:16

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RDAT_Playback_OpeningFcn, ...
                   'gui_OutputFcn',  @RDAT_Playback_OutputFcn, ...
                   'gui_LayoutFcn',  @RDAT_Playback_LayoutFcn, ...
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
function h = RDAT_Playback_LayoutFcn(varargin)
% Função de layout inicial

h = openfig('RDAT_Playback.fig','reuse','invisible');

% ---------------------------------------------------------------
function RDAT_Playback_OpeningFcn(hObject, eventdata, handles, varargin)
global DADOS DADOS2
% Funçao de inicializaçao

%  set(handles.window,'windowstyle','normal') % @@

bgc = getbuttoncolor(handles.window);
set(handles.load_btn,  'CData',geticon('DatButtons.mat','open',    bgc));
set(handles.save_btn,  'CData',geticon('DatButtons.mat','save',    bgc));
set(handles.edit_btn,  'CData',geticon('DatButtons.mat','scenario',bgc));
set(handles.OpenGL_btn,'CData',geticon('DatButtons.mat','opengl',  bgc));
set(handles.help_btn,  'CData',geticon('DatButtons.mat','help',    bgc));
set(handles.ini_btn,   'CData',geticon('DatButtons.mat','ini',     bgc));
set(handles.prev_btn,  'CData',geticon('DatButtons.mat','prev',    bgc));
set(handles.play_btn,  'CData',geticon('DatButtons.mat','play',    bgc));
set(handles.next_btn,  'CData',geticon('DatButtons.mat','next',    bgc));
set(handles.goto_btn,  'CData',geticon('DatButtons.mat','goto',    bgc));

ss = get(0,'ScreenSize');
minscreensize = [1024 768]; % Tamanho minimo da tela
if ss(3) < minscreensize(1) || ss(4) < minscreensize(2)
    beep; uiwait(errordlg({['Necessário resolução mínima de '...
                num2str(minscreensize(1)) ' × ' num2str(minscreensize(2)) ' pixels.'],...
            ['Resolução atual: ',int2str(ss(3)),' × ',int2str(ss(4)),'.'],...
            ' ','Aviso: Depois de alterar a resolução da tela, é necessário','reinicializar o MATLAB.'},'Erro','modal')); drawnow;
    handles.ok = 0;
    guidata(hObject, handles);
    uiresume;
    return
end

if isempty(varargin)
    beep; uiwait(errordlg('Dados não fornecidos.','Erro','modal'));
    handles.ok = 0;
    guidata(hObject, handles);
    uiresume;
    return
end

ws = get(handles.window,'Position');
set(handles.window,'Position',[(ss(3)-ws(3))/2, (ss(4)-ws(4))/2-2, ws(3), ws(4)],'Visible','off');

wbgc = get(handles.window,'Color');
set(handles.slideraxes,'Color',wbgc,'XColor',wbgc,'YColor',wbgc,'ZColor',wbgc);

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
if length(varargin) >= 7
    options = varargin{7};
else
    options = [];
end

if isempty(options)
    options.OpenGL    = 0;
    options.ttrail    = 0;
    options.FYT       = [];
    options.NAV       = [];
    options.CRS       = 0;
    options.scale     = 80;
    options.screens   = [1 0 1 0];
    options.winpos    = [];
    options.slider    = [];
    options.declutter = [0 0 ones(1,10)];
else
    if~isfield(options,'OpenGL')
        options.OpenGL    = 0;
    end
    if ~isfield(options,'ttrail')
        options.ttrail    = 0;
    end
    if ~isfield(options,'FYT')
        options.FYT       = [];
    end
    if ~isfield(options,'NAV')
        options.NAV       = [];
    end
    if ~isfield(options,'CRS')
        options.CRS       = 0;
    end
    if ~isfield(options,'scale')
        options.scale     = 80;
    end
    if ~isfield(options,'screens')
        options.screens   = [1 0 1 0];
    end
    if ~isfield(options,'winpos')
        options.winpos    = [];
    end
    if ~isfield(options,'slider')
        options.slider    = [];
    end
    if ~isfield(options,'declutter')
        options.declutter = [0 0 ones(1,10)];
    end
end

if ~isempty(events)
    evt = [events{:,2}];
    evd = events(:,3);
    for n = 1:size(events,1)
        if ~events{n,1}
            evt(n) = NaN;
        end
        if isempty(evd{n})
            evd{n} = '?';
        end
    end
    exc = isnan(evt);
    evt(exc) = [];
    evd(exc) = [];
else
    evt = [];
    evd = [];
end

if ~isempty(testpts)
    tpt           = [testpts.time];
    tpd           = {};
    testptsnumber = [testpts.number];
    testptsdescr  = [testpts.descr];
    for n = 1:length(testptsnumber)
        tpd{n} = [testptsnumber{n} ' - ' testptsdescr{n}];
    end
else
    tpt = [];
    tpd = {};
end

% --- BACKWARD COMPATIBILITY ----
setup    = backcompat(setup,'setup');
scenario = backcompat(scenario,'scenario');
% -------------------------------

handles.sellist = [handles.time_sel handles.Zp_sel handles.Vc_sel handles.M_sel handles.Zagl_sel handles.Gtrk_sel handles.lat_sel handles.lon_sel,...
        handles.Nz_sel handles.psi_sel handles.tet_sel handles.phi_sel handles.aoa_sel handles.aos_sel handles.Wdir_sel handles.Wmag_sel,...
        handles.Ddm_sel handles.Ddl_sel handles.Ddn_sel,...
        handles.thr1_sel handles.rpm1_sel handles.egt1_sel handles.ff1_sel handles.fuel1_sel handles.thr2_sel handles.rpm2_sel handles.egt2_sel handles.ff2_sel handles.fuel2_sel,...
        handles.Raz_sel handles.Rel_sel handles.Rrng_sel handles.Rclo_sel handles.Rzp_sel handles.Rvc_sel handles.Rpsi_sel handles.Rasp_sel,...
        handles.Maz_sel handles.Mel_sel handles.trk_sel handles.Paz_sel handles.Pel_sel handles.wrb_sel handles.trig_sel,...
        handles.Rmax1_sel handles.Rmax2_sel handles.Rmin_sel handles.Mlat_sel handles.Mlon_sel handles.Saz_sel handles.Sel_sel];
handles.sellist2 = [handles.warn1_sel handles.warn2_sel handles.warn3_sel handles.warn4_sel,...
        handles.lat2_sel handles.lon2_sel handles.alt2_sel handles.psi2_sel,...
        handles.lat3_sel handles.lon3_sel handles.alt3_sel handles.psi3_sel,...
        handles.lat4_sel handles.lon4_sel handles.alt4_sel handles.psi4_sel];
handles.displist = [handles.time_disp handles.Zp_disp handles.Vc_disp handles.M_disp handles.Zagl_disp handles.Gtrk_disp handles.lat_disp handles.lon_disp,...
        handles.Nz_disp handles.psi_disp handles.tet_disp handles.phi_disp handles.aoa_disp handles.aos_disp handles.Wdir_disp handles.Wmag_disp,...
        handles.Ddm_disp handles.Ddl_disp handles.Ddn_disp,...
        handles.thr1_disp handles.rpm1_disp handles.egt1_disp handles.ff1_disp handles.fuel1_disp handles.thr2_disp handles.rpm2_disp handles.egt2_disp handles.ff2_disp handles.fuel2_disp,...
        handles.Raz_disp handles.Rel_disp handles.Rrng_disp handles.Rclo_disp handles.Rzp_disp handles.Rvc_disp handles.Rpsi_disp handles.Rasp_disp,...
        handles.Maz_disp handles.Mel_disp handles.trk_disp handles.Paz_disp handles.Pel_disp handles.wrb_disp handles.trig_disp,...
        handles.Rmax1_disp handles.Rmax2_disp handles.Rmin_disp handles.Mlat_disp handles.Mlon_disp handles.Saz_disp handles.Sel_disp];
handles.gridlist1 = [handles.ref; findobj(handles.window,'UserData',1)];
handles.gridlist2 = [handles.wpn_frame; findobj(handles.window,'UserData',2)];
handles.ctrllist  = [handles.ok_btn; findobj(handles.window,'UserData',3)];
handles.HUDctrl   = [handles.fovup_btn handles.fovdn_btn];
handles.TSDctrl   = [handles.map_chk handles.vmap_chk handles.aux_chk handles.aid_chk handles.wpt_chk handles.rt_chk handles.fa_chk handles.avd_chk handles.thr_chk handles.cnt_chk,...
        handles.lbl_chk handles.dl_chk handles.scaleup_btn handles.scaledn_btn handles.mode_btn handles.trailup_btn handles.traildn_btn,...
        handles.FYTup_btn handles.FYTdn_btn handles.NAVup_btn handles.NAVdn_btn handles.CRSup_btn handles.CRSdn_btn handles.CRSup10_btn handles.CRSdn10_btn];
handles.warnlist = [handles.warn1 handles.warn2 handles.warn3 handles.warn4;...
        handles.warn1_light handles.warn2_light handles.warn3_light handles.warn4_light];
handles.warncolors = [0 1 1; 0 1 0; 1 .7 0; 1 0 0];

set([handles.sellist handles.sellist2],'String',char(' ',char(PARAM)),'Value',1);

% Variaveis de dados
if isempty(setup)
    setup.params = [];
    setup.engmax = [120 900 6000; 1 1 1000];
    setup.acft   = 'F-5';
    setup.fov    = 10;
end
if isempty(scenario)
    d = clock;
    scenario.date = [num2str(d(3),'%02.0f') '/' num2str(d(2),'%02.0f') '/' num2str(d(1))];
    scenario.Dmag = 0;
    scenario.map = [];
    scenario.aux = [];
    scenario.aid = [];
    scenario.wpt = [];
    scenario.fa  = [];
    scenario.rt  = [];
    scenario.avd = [];
    scenario.thr = [];
    scenario.cnt = [];
end

% Listagem e verificaçao de todos os parametros
handles.paramtags = {'time','Zp','Vc','M','Zagl','Gtrk','lat','lon','Nz','psi','tet','phi','aoa','aos','Wdir','Wmag','Ddm','Ddl','Ddn',...
        'thr1','rpm1','egt1','ff1','fuel1','thr2','rpm2','egt2','ff2','fuel2',...
        'Raz','Rel','Rrng','Rclo','Rzp','Rvc','Rpsi','Rasp',...
        'Maz','Mel','trk','Paz','Pel','wrb','trig','Rmax1','Rmax2','Rmin','Mlat','Mlon','Saz','Sel',...
        'warn1','warn2','warn3','warn4',...
        'lat2','lon2','alt2','psi2','lat3','lon3','alt3','psi3','lat4','lon4','alt4','psi4'};
for n = 1:length(handles.paramtags)
    if ~isfield(setup.params,handles.paramtags{n})
        setup.params.(handles.paramtags{n}) = '';
    end
end

% Constantes
Nobs = size(DADOS,1);
fov = setup.fov; % Semi abertura do HUD (graus)
bst = 3; % Boresight (graus)
blue   = [0 .5  1];
green  = [0 .95 0];
brown  = [0.78 0.5 0];
orange = [1 .5 .25];
handles.steps  = [-20 -10 -5 -2 -1 -.5 -.2 -.1 .1 .2 .5 0 1 2 5 10 20];
steps_str = num2str2(handles.steps');
steps_str(12,:) = 'Auto';
set(handles.step_sel,'String',steps_str,'Value',12);

% Criaçao do time-slider e dos marcadores de eventos --------------------------------

axes(handles.slideraxes);
set(handles.window,'Visible','off');
set(handles.slideraxes,'XLim',[1 size(DADOS,1)]);
handles.sliderline = plot([1 size(DADOS,1)],[.3 .3],'k-','HitTest','off','UserData',0);
handles.sliderball = plot3(N,.3,1,'bo','MarkerSize',8,'MarkerFaceColor','b','Clipping','off','UserData',0,'ButtonDownFcn','RDAT_Playback(''sliderball_ButtonDownFcn'',gcbo,[],guidata(gcbo))');

handles.eventpts = plot(NaN,NaN,'rv','MarkerSize',5,'MarkerFaceColor','r','HitTest','off');
handles.ptslines = plot(NaN,NaN,'b-','LineWidth',3,'HitTest','off','Color',[0 .5 1]);
handles.eventtip = text(0,0,'','HorizontalAlignment','center','Interpreter','none','UserData',NaN);

if Nobs >= 800, en = 'on'; else en = 'off'; end
set(handles.divide8,'Enable',en);
if Nobs >= 400, en = 'on'; else en = 'off'; end
set(handles.divide4,'Enable',en);
if Nobs >= 200, en = 'on'; else en = 'off'; end
set(handles.divide2,'Enable',en);

% Criaçao dos objetos graficos do HUD --------------------------------

axes(handles.HUD);
set(handles.window,'Visible','off');
set(handles.HUD,'XLim',fov*[-1 1],'YLim',fov*[-1 1]-bst,'Color',blue);

% Ground
handles.Xg = fov*[-10 10 10 -10];
handles.Yg = fov*[ 0  0 -20 -20];
handles.ground = patch(handles.Xg,handles.Yg,[-1 -1 -1 -1],brown,'EdgeColor',brown);

% Boresight cross
handles.bstcross = plot(fov*[-.04 -.015 NaN .015 .04 NaN 0 0 0 0 0],fov*[0 0 NaN 0 0 NaN -.04 -.015 NaN .015 .04],'-','Color',green);

% Roll arc, ticks and marker
Xr0 = .3*fov*cos((210:5:330)*pi/180);
Yr0 = .3*fov*sin((210:5:330)*pi/180)-.65*fov-bst;
Xr1 = .3*fov*cos((210:10:330)*pi/180);
Yr1 = .3*fov*sin((210:10:330)*pi/180)-.65*fov-bst;
Xr2 = .32*fov*cos((210:10:330)*pi/180);
Yr2 = .32*fov*sin((210:10:330)*pi/180)-.65*fov-bst;
Xr(1:3:3*13) = Xr1;
Xr(2:3:3*13) = Xr2;
Xr(3:3:3*13) = NaN;
Yr(1:3:3*13) = Yr1;
Yr(2:3:3*13) = Yr2;
Yr(3:3:3*13) = NaN;
handles.rollarc = plot([Xr0 NaN Xr],[Yr0 NaN Yr],'-','Color',green);
handles.Xrol = .8*[0 .02 -.02 0];
handles.Yrol = .8*[0 .06  .06 0]-.3;
handles.roll = plot(fov*handles.Xrol,fov*handles.Yrol-.65*fov-bst,'-','Color',green);

% Horizon line
handles.Xh = [-.5 -.09 NaN .09 .5];
handles.Yh = [0 0 NaN 0 0];
handles.horizon = plot(fov*handles.Xh,fov*handles.Yh,'-','Color',green);

% Positive pitch lines
fov0 = 10;

handles.Xpu = [];
handles.Ypu = [];
handles.pitchuplbl = [];
for deg = 5:5:85
    Xpu = fov0*[-.3 -.3 -.09 NaN .09 .3 .3];
    Ypu = fov0*[-.04 0 -.2*sin(min(deg,30)*pi/180) NaN -.2*sin(min(deg,30)*pi/180) 0 -.04] + deg;
    handles.Xpu = [handles.Xpu NaN Xpu];
    handles.Ypu = [handles.Ypu NaN Ypu];
end
handles.Xpu = [handles.Xpu NaN .04*fov0*.8*cos(linspace(0,2*pi,17))    NaN .04*fov0*.8*cos(linspace(0,2*pi,17))];
handles.Ypu = [handles.Ypu NaN .04*fov0*.8*sin(linspace(0,2*pi,17))+90 NaN .04*fov0*.8*sin(linspace(0,2*pi,17))-90];
for deg = 85:-5:70
    Xpu = fov0*[-.3 -.3 -.09 NaN .09 .3 .3];
    Ypu = fov0*[.04 0 .2*sin(min(deg,30)*pi/180) NaN .2*sin(min(deg,30)*pi/180) 0 .04]+180-deg;
    handles.Xpu = [handles.Xpu NaN Xpu];
    handles.Ypu = [handles.Ypu NaN Ypu];
end
handles.pitchup = plot(handles.Xpu,handles.Ypu,'-','Color',green);

% Negative pitch lines
handles.Xpd = [];
handles.Ypd = [];
handles.pitchdnlbl = [];
for deg = -5:-5:-85
    Xpd = fov0*[-.3 -.3 -.09 NaN .09 .3 .3];
    Ypd = fov0*[.04 0 -.2*sin(min(deg,30)*pi/180) NaN -.2*sin(min(deg,30)*pi/180) 0 .04]+deg;
    handles.Xpd = [handles.Xpd NaN Xpd];
    handles.Ypd = [handles.Ypd NaN Ypd];
end
for deg = -85:5:-70
    Xpd = fov0*[-.3 -.3 -.09 NaN .09 .3 .3];
    Ypd = fov0*[-.04 0 .2*sin(min(deg,30)*pi/180) NaN .2*sin(min(deg,30)*pi/180) 0 -.04]-180-deg;
    handles.Xpd = [handles.Xpd NaN Xpd];
    handles.Ypd = [handles.Ypd NaN Ypd];
end
handles.pitchdn = plot(handles.Xpd,handles.Ypd,'--','Color',green);

% Pitch labels
handles.pitchuplblpos = [];
d = .37;
for deg = -85:5:85
    if deg ~= 0
        if deg < 0
            valn = 'baseline';
        else
            valn = 'cap';
        end
        Rlbl = [-fov0*d deg];
        Llbl = [ fov0*d deg];
        handles.pitchuplblpos = [handles.pitchuplblpos; Rlbl];
        handles.pitchuplblpos = [handles.pitchuplblpos; Llbl];
        handles.pitchuplbl = [handles.pitchuplbl text(Rlbl(1),Rlbl(2),num2str(deg),'HorizontalAlignment','center','VerticalAlignment',valn,'Color',green)];
        handles.pitchuplbl = [handles.pitchuplbl text(Llbl(1),Llbl(2),num2str(deg),'HorizontalAlignment','center','VerticalAlignment',valn,'Color',green)];
    end
end
for deg = 85:-5:70
    Rlbl = [-fov0*d 180-deg];
    Llbl = [ fov0*d 180-deg];
    handles.pitchuplblpos = [handles.pitchuplblpos; Rlbl];
    handles.pitchuplblpos = [handles.pitchuplblpos; Llbl];
    handles.pitchuplbl = [handles.pitchuplbl text(Rlbl(1),Rlbl(2),num2str(deg),'HorizontalAlignment','center','VerticalAlignment','Cap','Color',green)];
    handles.pitchuplbl = [handles.pitchuplbl text(Llbl(1),Llbl(2),num2str(deg),'HorizontalAlignment','center','VerticalAlignment','Cap','Color',green)];
end
for deg = -85:5:-70
    Rlbl = [-fov0*d -180-deg];
    Llbl = [ fov0*d -180-deg];
    handles.pitchuplblpos = [handles.pitchuplblpos; Rlbl];
    handles.pitchuplblpos = [handles.pitchuplblpos; Llbl];
    handles.pitchuplbl = [handles.pitchuplbl text(Rlbl(1),Rlbl(2),num2str(deg),'HorizontalAlignment','center','VerticalAlignment','Baseline','Color',green)];
    handles.pitchuplbl = [handles.pitchuplbl text(Llbl(1),Llbl(2),num2str(deg),'HorizontalAlignment','center','VerticalAlignment','Baseline','Color',green)];
end

% Time box
handles.time = text(-fov*0.9,-fov*.86-bst,'XX:XX:XX.XX','HorizontalAlignment','left','Color',green);

% Speed box
handles.Vcbox = plot(-fov*[.76 .63 .59 .63 .76 .76],fov*[0 0 .035 .07 .07 0]-bst,'-','Color',green);
handles.Vc = text(-fov*0.635,fov*.038-bst,'XXX','HorizontalAlignment','right','Color',green);
Xtick = [];
Ytick = [];
Ytk = linspace(-.3,.3,21);
for n = 1:21
    Xtick = [Xtick NaN -[.58 .56]];
    Ytick = [Ytick NaN  [Ytk(n) Ytk(n)]+.035];
end
handles.XVticks  = Xtick;
handles.YVticks  = Ytick;
handles.Vcticks  = plot(fov*Xtick,fov*Ytick-bst,'-','Color',green);
Vclblpos = [-.59 .035];
handles.Vclbl(1) = text(-fov*Vclblpos(1),fov*(Vclblpos(2)-.0),'XX','HorizontalAlignment','right','Color',green);
handles.Vclbl(2) = text(-fov*Vclblpos(1),fov*(Vclblpos(2)-.6),'XX','HorizontalAlignment','right','Color',green);
handles.Vclbl(3) = text(-fov*Vclblpos(1),fov*(Vclblpos(2)-.2),'XX','HorizontalAlignment','right','Color',green);
handles.Vclbl(4) = text(-fov*Vclblpos(1),fov*(Vclblpos(2)-.4),'XX','HorizontalAlignment','right','Color',green);
handles.Vclblpos = Vclblpos;

% Acceleration bar
handles.acc = plot(-fov*[.535 .535],[NaN NaN],'-g');

% Altitude box
handles.Zpbox = plot(fov*[.86 .63 .59 .63 .86 .86],fov*[0 0 .035 .07 .07 0]-bst,'-','Color',green);
handles.Zp = text(fov*0.85,fov*.038-bst,'XX,XXX','HorizontalAlignment','right','Color',green);
Xtick = [];
Ytick = [];
Ytk = linspace(-.3,.3,21);
for n = 1:21
    Xtick = [Xtick NaN  .58 .56];
    Ytick = [Ytick NaN [Ytk(n) Ytk(n)]+.035];
end
handles.XZticks  = Xtick;
handles.YZticks  = Ytick;
handles.Zpticks  = plot(fov*Xtick,fov*Ytick-bst,'-','Color',green);
Zplblpos = [.59 .035];
handles.Zplbl(1) = text(fov*Zplblpos(1),fov*(Zplblpos(2)-.0),'XX.X','HorizontalAlignment','left','Color',green);
handles.Zplbl(2) = text(fov*Zplblpos(1),fov*(Zplblpos(2)-.6),'XX.X','HorizontalAlignment','left','Color',green);
handles.Zplbl(3) = text(fov*Zplblpos(1),fov*(Zplblpos(2)-.2),'XX.X','HorizontalAlignment','left','Color',green);
handles.Zplbl(4) = text(fov*Zplblpos(1),fov*(Zplblpos(2)-.4),'XX.X','HorizontalAlignment','left','Color',green);
handles.Zplblpos = Zplblpos;

% Climb bar
handles.climb = plot(fov*[.535 .535],[NaN NaN],'-g');

% Heading box
handles.psibox = plot(fov*[-.068 .068 .068 -.068 -.068 NaN 0 0],fov*[.665 .665 .735 .735 .665 NaN .75 .82]-bst,'-','Color',green);
handles.psi = text(0,fov*.703-bst,'XXX','HorizontalAlignment','center','Color',green);
Xtick = [];
Ytick = [];
Xtk = linspace(-.4,.4,9);
for n = 1:9
    Xtick = [Xtick NaN  Xtk(n) Xtk(n)];
    Ytick = [Ytick NaN .75 .79];
end
handles.XHticks   = Xtick;
handles.YHticks   = Ytick;
handles.psiticks  = plot(fov*Xtick,fov*Ytick-bst,'-','Color',green);
psilblpos = [0 .71];
handles.psilbl(1) = text(fov*(psilblpos(1)+.27),fov*psilblpos(2)-bst,'XX','HorizontalAlignment','center','Color',green);
handles.psilbl(2) = text(fov*(psilblpos(1)-.27),fov*psilblpos(2)-bst,'XX','HorizontalAlignment','center','Color',green);
handles.psilbl(3) = text(fov*(psilblpos(1)+.00),fov*psilblpos(2)-bst, '' ,'HorizontalAlignment','center','Color',green);
handles.psilbl(4) = text(fov*(psilblpos(1)+.14),fov*psilblpos(2)-bst,'XX','HorizontalAlignment','center','Color',green);
handles.psilbl(5) = text(fov*(psilblpos(1)-.14),fov*psilblpos(2)-bst,'XX','HorizontalAlignment','center','Color',green);
handles.psilblpos = psilblpos;
handles.psilist = -20:10:380;

% Ground track tick
handles.GtrkH = text(0,fov*(psilblpos(2)+ 0.082)-bst,'','FontName','Arial','Color',green,'HorizontalAlignment','center','VerticalAlignment','baseline');

% Radar altimeter box
handles.Zaglbox = plot(fov*[.58 .75 .75 .58 .58],-fov*[.44 .44 .368 .368 .44]-bst,'-','Color',green);
handles.Zagllbl = text(fov*.52,-fov*.4-bst,'R','Color',green);
handles.Zagl = text(fov*.735,-fov*.4-bst,'XXXX','HorizontalAlignment','right','Color',green);

% DLZ
handles.DLZscales = [5 10 20 40 80];
XDLZticks = [.44 .50 NaN .50 .44];
YDLZticks = [-.3 -.3 NaN .3 .3]+.035;
handles.DLZticks  = plot(fov*XDLZticks,fov*YDLZticks-bst,'-','Color',green);
handles.DLZscale  = text(fov*0.47,.31*fov+fov*.035-bst,'XX','HorizontalAlignment','center','VerticalAlignment','bottom','Color',green);
XDLZbrkt1  = [.50 .46 .46 .50];
XDLZbrkt2  = [.46 .50 .50 .46];
handles.DLZbrkt1  = plot(fov*XDLZbrkt1,fov*[NaN NaN NaN NaN],'-','Color',green);
handles.DLZbrkt2  = plot(fov*XDLZbrkt2,fov*[NaN NaN NaN NaN],'-','Color',green);
handles.DLZrng    = text(fov*XDLZbrkt2(1),-5,'>','HorizontalAlignment','right','VerticalAlignment','middle','Color',green);
handles.XDLZbrkt  = [XDLZbrkt1; XDLZbrkt2];

% Nz box
handles.Nz = text(-fov*.41,fov*.5-bst,'X.X','HorizontalAlignment','right','Color',green);

% Mach box
handles.M = text(-fov*.41,-fov*.4-bst,'X.XX','HorizontalAlignment','right','Color',green);

% AOA box
handles.aoa = text(-fov*.65,-fov*.5-bst,'XX','HorizontalAlignment','right','Color',green);

% Range box
handles.Rrng = text(fov*.735,-fov*.49-bst,'XXXX','HorizontalAlignment','right','Color',green);

% Closure rate box
handles.Rclo = text(fov*.735,-fov*.55-bst,'XXX','HorizontalAlignment','right','Color',green);

% FYT symbol
handles.FYTsymb = plot(NaN,NaN,'-','Color',green);
handles.Xfythud = .025*[-.1 .1 NaN -1 1 1 -1 -1];
handles.Yfythud = .025*[0 0 NaN -1 -1 1 1 -1];

% FYT box
handles.FYTbox = text(fov*.735,-fov*.68-bst,{'XXXº > XX','XX.X / XX:XX'},'HorizontalAlignment','right','Color',green);

% NAV box
handles.NAVbox = text(fov*.735,-fov*.81-bst,'XXXº V XX.X','HorizontalAlignment','right','Color',green);

% Fuel box
handles.fuel = text(-fov*0.9,-fov*.93-bst,'XXXX','HorizontalAlignment','left','Color',green);

% Seeker angle box
handles.seekerang = text(fov*.635,fov*.59-bst,'','HorizontalAlignment','right','Color',green);

% Target angle-off box
handles.tdbang = text(fov*-.08,0,'','HorizontalAlignment','right','Color',green);

% Pickle
handles.pickle = text(-fov*0.85,fov*.7-bst,'','HorizontalAlignment','left','Color',green);

% Trigger
handles.trigger = text(-fov*0.8,fov*.7-bst,'','HorizontalAlignment','left','Color',green);

% Messages
handles.eventdescr  = text(-fov*0.95,fov*.95-bst,'','HorizontalAlignment','left','Color',green,'Interpreter','none');
handles.testptdescr = text(-fov*0.95,fov*.89-bst,'','HorizontalAlignment','left','Color',green,'Interpreter','none');

% FPM
handles.Xf = .04*[.8*cos(linspace(0,2*pi,17)) NaN .8 2 NaN  0 0 NaN -.8 -2];
handles.Yf = .04*[.8*sin(linspace(0,2*pi,17)) NaN  0 0 NaN .8 2 NaN   0  0];
handles.fpm = plot(fov*handles.Xf,fov*handles.Yf,'-','Color',green);

% Target box
handles.tdb = plot(NaN,NaN,'-','Color',green);
handles.Xtdb = .05*[-1 1 1 -1 -1];
handles.Ytdb = .05*[-1 -1 1 1 -1];
handles.Xasp = .08*[0 -.2  .2 0];
handles.Yasp = .08*[0 -.4 -.4 0];
handles.asp  = plot(NaN,NaN,'-','Color',green);

% Seeker
handles.seeker = plot(NaN,NaN,'-','Color',green);
handles.Xseeker = .025*[0 1 0 -1 0];
handles.Yseeker = .025*[-1 0 1 0 -1];

% Sensor
handles.sensor = plot(NaN,NaN,'-','Color',green);
a = (0:22.5:360)*pi/180;
handles.Xsensor = .032*cos(a);
handles.Ysensor = .032*sin(a);

% Piper
handles.piper = plot(NaN,NaN,'-','Color',green);
handles.Xpiper = .032*[-.008 .008 NaN cos(a)];
handles.Ypiper = .032*[-.008 .008 NaN sin(a)];

% Out-of-fov X
handles.XX = .04*[NaN -1 1 NaN -1 1];
handles.YX = .04*[NaN -1 1 NaN 1 -1];

% Others
handles.acft2hud = text(0,0,'','HorizontalAlignment','center','Color',green,'EdgeColor',green,'Margin',0.1,'Interpreter','none');
handles.acft3hud = text(0,0,'','HorizontalAlignment','center','Color',green,'EdgeColor',green,'Margin',0.1,'Interpreter','none');
handles.acft4hud = text(0,0,'','HorizontalAlignment','center','Color',green,'EdgeColor',green,'Margin',0.1,'Interpreter','none');

set(findobj(handles.HUD,'Type','line'),'LineWidth',1.5);
set([handles.acc handles.climb],'LineWidth',3);
set(findobj(handles.HUD,'Type','text'),'FontWeight','demi','FontName','Arial','Clipping','on');

% Criaçao dos objetos graficos de motor --------------------------------

axes(handles.ENG);
set(handles.window,'Visible','off');
pos = get(handles.ENG,'Position');
set(handles.ENG,'XLim',[0 pos(3)/pos(4)],'YLim',[0 1]);

% Manete, RPM, TEMP & FF
handles.engmax = setup.engmax;
x = [.8 1.7 2.6];
for n = 1:3
    harc = plot(.3*cos(linspace(0,3*pi/2,19))+x(n),.3*sin(linspace(0,3*pi/2,19))+.5,'-','Color',green);
    A = linspace(0,3*pi/2,13);
    X = [];
    Y = [];
    for m = 1:length(A)
        X = [X NaN .3*cos(A(m))+x(n)  .26*cos(A(m))+x(n)];
        Y = [Y NaN .3*sin(A(m))+.5    .26*sin(A(m))+.5];
    end
    if handles.engmax(2,n) == 1
        multstr = '';
    else
        multstr = ['x' num2str(handles.engmax(2,n))];
    end
    handles.engmult(n)   = text(x(n)    ,.64,multstr,'HorizontalAlignment','center','Color',green);
    handles.engtext(n,1) = text(x(n)    ,.14,'0','HorizontalAlignment','center','Color',green);
    handles.engtext(n,2) = text(x(n)-.32,.50,num2str(1/3*handles.engmax(1,n)/handles.engmax(2,n)),'HorizontalAlignment','right','Color',green);
    handles.engtext(n,3) = text(x(n)    ,.86,num2str(2/3*handles.engmax(1,n)/handles.engmax(2,n)),'HorizontalAlignment','center','Color',green);
    handles.engtext(n,4) = text(x(n)+.24,.76,num2str(5/6*handles.engmax(1,n)/handles.engmax(2,n)),'HorizontalAlignment','left','Color',green);
    htick = plot(X,Y,'-','Color',green);
    handles.engpointer(n,1) = plot(NaN,NaN,'-','Color','w');
    handles.engpointer(n,2) = plot(NaN,NaN,'-','Color',[.8 .8 .8]);
    hcenter = plot3(x(n),.5,1,'o','Color',green,'MarkerSize',5,'MarkerFaceColor','k');
end
text(x(1)-.4,.91,'RPM' ,'HorizontalAlignment','left','Color',green);
text(x(2)-.4,.91,'TEMP','HorizontalAlignment','left','Color',green);
text(x(3)-.4,.91,' FF' ,'HorizontalAlignment','left','Color',green);
handles.rpm1 = text(x(1)+.35,.35,'XX.X','HorizontalAlignment','right','Color','w');
handles.rpm2 = text(x(1)+.35,.25,'XX.X','HorizontalAlignment','right','Color',[.8 .8 .8]);
handles.egt1 = text(x(2)+.35,.35,'XXX', 'HorizontalAlignment','right','Color','w');
handles.egt2 = text(x(2)+.35,.25,'XXX', 'HorizontalAlignment','right','Color',[.8 .8 .8]);
handles.ff1  = text(x(3)+.35,.35,'XXXX','HorizontalAlignment','right','Color','w');
handles.ff2  = text(x(3)+.35,.25,'XXXX','HorizontalAlignment','right','Color',[.8 .8 .8]);

X = [-1    1   NaN -1  1 1 -1 -1];
Y = [-1.5 -1.5 NaN -1 -1 1  1 -1];
X = [X NaN -1   -1   NaN  -.5  -.5  NaN  0    0   NaN   .5   .5  NaN  1    1  ];
Y = [Y NaN -1.5 -1.3 NaN -1.5 -1.35 NaN -1.5 -1.3 NaN -1.5 -1.35 NaN -1.5 -1.3];
X = [X NaN -1 -.9 NaN -.8 -.7 NaN -.6 -.4 NaN -.3 -.2 NaN -.1 .1 NaN .2 .3 NaN .4 .6 NaN .7 .8 NaN .9 1];
Y = [Y NaN  0  0  NaN  0   0  NaN  0   0  NaN  0   0  NaN  0  0  NaN  0  0 NaN  0  0 NaN  0  0 NaN  0 0];
X = [X NaN  0  0  NaN  0   0  NaN  0   0  NaN  0   0  NaN  0  0  NaN  0  0 NaN  0  0 NaN  0  0 NaN  0 0];
Y = [Y NaN -1 -.9 NaN -.8 -.7 NaN -.6 -.4 NaN -.3 -.2 NaN -.1 .1 NaN .2 .3 NaN .4 .6 NaN .7 .8 NaN .9 1];
X = [X NaN -1 -.85 NaN -.1 .1 NaN .85  1 NaN  -1 -.85 NaN -.1  .1 NaN  .85  1 ];
Y = [Y NaN .5  .5  NaN  .5 .5 NaN .5  .5 NaN -.5 -.5  NaN -.5 -.5 NaN -.5  -.5];
X = [X NaN .5  .5  NaN  .5 .5 NaN .5  .5 NaN -.5 -.5  NaN -.5 -.5 NaN -.5  -.5];
Y = [Y NaN -1 -.85 NaN -.1 .1 NaN .85  1 NaN  -1 -.85 NaN -.1  .1 NaN  .85  1 ];
x = 2.85;
y = .55;
k = .26;
cmdgrid = plot(x+X*k,y+Y*k,'-g','UserData',[x-k x+k y-k y+k]);
handles.stick  = plot3(2.9,.56,1,'ow','MarkerFaceColor','w','MarkerSize',5);
handles.rudder = plot3(2.6,.11,1,'^w','MarkerFaceColor','w','MarkerSize',5);
handles.cmdgrid = [cmdgrid handles.stick handles.rudder];

handles.ffgauge = [harc htick hcenter handles.ff1 handles.ff2 handles.engpointer(3,:) handles.engtext(3,:) handles.engmult(3)];

x = .16;
handles.thr1 = text(x,.15,'XX.X','HorizontalAlignment','center','Color','w');
handles.thr2 = text(x,.05,'XX.X','HorizontalAlignment','center','Color',[.8 .8 .8]);
handles.throttleaxis = plot([x x],[.25 .9],'-g');
handles.throttles    = plot(x+[-.09 -.05 -.01 0 .01 .05 .09],NaN*ones(1,7),'w');

x = 2.26;
handles.fftape1  = patch(x+[-.02 .02 .02 -.02],[.25 .25 .5 .5],'w','EdgeColor','w');
ffframe1 = plot(x+[-.02 .02 .02 -.02 -.02],[.25 .25 .8 .8 .25],'g');
x = 2.34;
handles.fftape2 = patch(x+[-.02 .02 .02 -.02],[.25 .25 .6 .6],'w','EdgeColor','w');
ffframe2 = plot(x+[-.02 .02 .02 -.02 -.02],[.25 .25 .8 .8 .25],'g');
x = 2.3;
handles.fft1 = text(x,.15,'XX.X','HorizontalAlignment','center','Color','w');
handles.fft2 = text(x,.05,'XX.X','HorizontalAlignment','center','Color',[.8 .8 .8]);

handles.fftapes = [ffframe1 handles.fftape1 handles.fft1; ffframe2 handles.fftape2 handles.fft2];

set(findobj(handles.ENG,'Type','line'),'LineWidth',1.5,'HitTest','off');
set(findobj(handles.ENG,'Type','text'),'FontWeight','demi','FontName','Arial','Clipping','on','HitTest','off');

set(handles.throttleaxis,'LineWidth',2);
set(handles.throttles,'LineWidth',4);

% Criaçao dos objetos graficos do TSD --------------------------------

scale = options.scale;
axes(handles.TSD);
set(handles.window,'Visible','off');
set(handles.TSD,'XLim',6/8*scale*[-.5 .5],'YLim',scale*[-1/3 2/3]);

handles.ylbl = [];
handles.hlbl = [];

% Decluter
dclt = {'MAP','VMAP','AUX','AID','WPT','RT','FA','AVD','THR','CNT','LBL','DL'};
nr = 4;
for n = 1:nr
    y = 1.001-n*.0227;
    handles.ylbl(end+1) = y;
    handles.hlbl(end+1) = text(1-.01,y,dclt{n},'Units','normalized','HorizontalAlignment','right','Color',green,'FontSize',8);
end
for n = nr+1:length(dclt)
    y = 1.001-(n-nr)*.0227;
    handles.ylbl(end+1) = y;
    handles.hlbl(end+1) = text(.01,y,dclt{n},'Units','normalized','HorizontalAlignment','left','Color',green,'FontSize',8);
end

% Trail
y = .723;
handles.ylbl(end+1) = y;
handles.trailstr = text(.01,y,{'TRL','0'},'Units','normalized','HorizontalAlignment','left','Color',green,'FontSize',8);
handles.trail  = plot3(NaN,NaN,0,'-','Color',[.5 .5 .5]);
handles.trail2 = plot3(NaN,NaN,0,'-','Color',[.5 .5 .5]);
handles.trail3 = plot3(NaN,NaN,0,'-','Color',[.5 .5 .5]);
handles.trail4 = plot3(NaN,NaN,0,'-','Color',[.5 .5 .5]);
handles.hlbl(end+1) = handles.trailstr;

% Scale
y = 0.664;
handles.ylbl(end+1) = y;
handles.scalelist = [1 2 5 10 20 40 80 160 320 640 1280];
handles.scale = text(.01,y,num2str(scale),'Units','normalized','HorizontalAlignment','left','Color',green);
handles.hlbl(end+1) = handles.scale;

% Mode
y = 0.61;
handles.ylbl(end+1) = y;
handles.mode = text(.01,y,'DYN','Units','normalized','HorizontalAlignment','left','Color',green,'FontSize',8);
handles.hlbl(end+1) = handles.mode;

% FYT
y = 0.56;
handles.ylbl(end+1) = y;
handles.FYTlbl = text(.01,y,{'FYT','OFF'},'UserData',options.FYT,'Units','normalized','HorizontalAlignment','left','Color',green,'FontSize',8);
handles.hlbl(end+1) = handles.FYTlbl;

handles.Xfyt =  .06*[-.1 .1 .1 -.1 -.1 NaN -.14 0 .14 0 -.14];
handles.Yfyt = [.08*[-.1 -.1 .2 .2 -.1]-.221 NaN .08*[0 -.14 0 .14 0]+.215];
handles.FYT = plot3(scale*handles.Xfyt,scale*handles.Yfyt,0*handles.Xfyt+2,'-','Color','m');

% NAV
y = 0.499;
handles.ylbl(end+1) = y;
handles.NAVlbl = text(.01,y,{'NAV','OFF'},'UserData',options.NAV,'Units','normalized','HorizontalAlignment','left','Color',green,'FontSize',8);
handles.hlbl(end+1) = handles.NAVlbl;

% CRS
y = 0.438;
handles.ylbl(end+1) = y;
handles.CRSlbl = text(.01,y,{'CRS',num2str(options.CRS,'%03.0f')},'UserData',options.CRS,'Units','normalized','HorizontalAlignment','left','Color',green,'FontSize',8);
handles.hlbl(end+1) = handles.CRSlbl;

% Cursor data block
handles.cdb = text(.01,.05,{' ',' '},'Units','normalized','HorizontalAlignment','left','VerticalAlignment','bottom','Color','w');
handles.cur = nan*ones(16);
handles.cur(:,[1 2 end-1 end]) = 2;

% Radar data block
handles.rdb = text(.99,.05,{' ',' ',' '},'Units','normalized','HorizontalAlignment','right','VerticalAlignment','bottom','Color','y');

% Acft2 data block
handles.acft2db = text(.99,.15,{' ',' '},'Units','normalized','HorizontalAlignment','right','VerticalAlignment','bottom','Color',green);

% Acft3 data block
handles.acft3db = text(.99,.22,{' ',' '},'Units','normalized','HorizontalAlignment','right','VerticalAlignment','bottom','Color',blue);

% Acft4 data block
handles.acft4db = text(.99,.29,{' ',' '},'Units','normalized','HorizontalAlignment','right','VerticalAlignment','bottom','Color',orange);

% Wind rose ticks
A = [0 90 180 270]*pi/180;
handles.Xwrt = [];
handles.Ywrt = [];
for n = 1:length(A)
    handles.Xwrt = [handles.Xwrt NaN .205*cos(A(n)) .22*cos(A(n))];
    handles.Ywrt = [handles.Ywrt NaN .205*sin(A(n)) .22*sin(A(n))];
end
handles.windroseticks = plot3(scale*handles.Xwrt,scale*handles.Ywrt,0*handles.Xwrt+2,'-','Color','w');

% Wind rose
A = (90-linspace(0,360,37))*pi/180;
A(end) = [];
handles.Xwr = [];
handles.Ywr = [];
handles.windroselblpos = [];
for n = 1:length(A)
    if rem(n-1,3)
        handles.Xwr = [handles.Xwr NaN .20*cos(A(n)) .18*cos(A(n))];
        handles.Ywr = [handles.Ywr NaN .20*sin(A(n)) .18*sin(A(n))];
    else
        handles.windroselblpos = [handles.windroselblpos; .19*cos(A(n)) .19*sin(A(n))];
    end
end
handles.windrose = plot3(scale*handles.Xwr,scale*handles.Ywr,0*handles.Xwr+2,'-','Color','w');
windroselbl = {'N','03','06','E','12','15','S','21','24','W','30','33'};
for n = 1:size(handles.windroselblpos,1)
    handles.windroselbl(n) = text(scale*handles.windroselblpos(n,1),scale*handles.windroselblpos(n,2),2,windroselbl{n},'HorizontalAlignment','center','Color','w');
end

% Wind
handles.Xwind = .06*[-.1 0 .1];
handles.Ywind = .10*[.1 0 .1]+.21;
handles.Wdir = plot3(scale*handles.Xwind,scale*handles.Ywind,0*handles.Xwind+2,'-','Color','w');
handles.Wmag = text(0,0,2,'X','Color','w','HorizontalAlignment','center');

% Ground track
handles.Xgt = .06*[-.1 0 .1];
handles.Ygt = .10*[.1 0 .1]+.205;
handles.GtrkT = plot3(scale*handles.Xgt,scale*handles.Ygt,0*handles.Xgt+2,'-','Color','w');

% RMI
handles.Xrmi =  .06*[-.1 .1 .1 -.1 -.1 NaN -.1 .1 .1 .25 0 -.25 -.1 -.1];
handles.Yrmi = [.08*[-.1 -.1 .3 .3 -.1]-.165 NaN .08*[-.3 -.3 0 0 .3 0 0 -.3]+.15];
handles.RMI = plot3(scale*handles.Xrmi,scale*handles.Yrmi,0*handles.Xrmi+2,'-','Color','y');

% VOR
handles.Xvor =  .06*[-.1 .1 .1 -.1 -.1 NaN -.14 0 .14 0 -.14];
handles.Yvor = [.08*[-.1 -.1 .2 .2 -.1]-.221 NaN .08*[0 -.14 0 .14 0]+.215];
handles.VOR = plot3(scale*handles.Xvor,scale*handles.Yvor,0*handles.Xvor+2,'-','Color','g');

% CRS
handles.Xcrs =  .06*[0 0 NaN 0 0 NaN -.2 0 .2];
handles.Ycrs = [.08*[-.1 .45]-.165 NaN .08*[-.45 .3 NaN 0 .3 0]+.15];
handles.CRS = plot3(scale*handles.Xcrs,scale*handles.Ycrs,0*handles.Xcrs+2,'-','Color','w');

% CDI
handles.Xcdi =  .06*[0 0];
handles.Ycdi = [.08*.5-.165 .08*-.5+.15];
handles.CDI = plot3(scale*handles.Xcdi,scale*handles.Ycdi,0*handles.Xcdi+2,'-','Color','w');

% TO/FROM
handles.Xtf = .06*[-.3 0 .3];
handles.Ytf = .08*[0 -.2 0]-.07;
handles.TF = patch(scale*handles.Xtf,scale*handles.Ytf,0*handles.Xtf+2.1,'g','EdgeColor','g');

% Scenario objects
handles.map       = [];
handles.aux       = [];
handles.auxlbl    = {};
handles.rt        = [];
handles.aid       = [];
handles.aidlbl    = [];
handles.wpt       = [];
handles.wptnumlbl = [];
handles.wptcodlbl = [];
handles.fyt       = [];
handles.nav       = [];
handles.fa        = [];
handles.falbl     = [];
handles.avd       = [];
handles.avdlbl    = [];
handles.thr       = [];
handles.thrlbl    = [];
handles.cnt       = [];

% Target
handles.tgtpts = .015*[[cos(linspace(0,2*pi,17)) NaN .9*[0 cos(210*pi/180) cos(330*pi/180) 0] 0]' ...
        [sin(linspace(0,2*pi,17)) NaN .9*[1 sin(210*pi/180) sin(330*pi/180) 1] 2]'];
handles.target = plot3(NaN,NaN,NaN,'y');
handles.tgtalt = text(0,0,'','HorizontalAlignment','center','Color','y');

% Missile present position
handles.mpp = plot3(NaN,NaN,NaN,'or','MarkerFaceColor','r');

% Aircrafts
handles.acftlist = {'F-5','AT-26','A-1','A-29','Mirage','Gripen','F-16','F-18','F-14','F-15','F-22','Su-35','Su-47','X-Wing'};

handles.acftshapes{1} = [ % F-5
    0.610	0.000
    0.450	0.040
    0.230	0.040
    0.190	0.080
    0.090	0.080
    -0.030	0.290
    0.070	0.290
    -0.120	0.290
    -0.100	0.290
    -0.100	0.060
    -0.210	0.060
    -0.270	0.160
    -0.330	0.160
    -0.330	0.050
    -0.390	0.050
    -0.390	0.000
];

handles.acftshapes{end+1} = [ % AT-26
    0.441    0.000
    0.334    0.038
    0.126    0.038
    0.126    0.082
    0.082    0.082
    0.025    0.410
    0.101    0.428
    0.000    0.447
    -0.158    0.428
    -0.095    0.410
    -0.095    0.038
    -0.334    0.038
    -0.365    0.164
    -0.428    0.164
    -0.428    0.025
    -0.460    0.025
    -0.460    0.000
];

handles.acftshapes{end+1} = [ % A-1
    0.569	0.000
    0.408	0.039
    0.208	0.039
    0.208	0.080
    0.120	0.080
    -0.032	0.333
    0.040	0.333
    -0.140	0.333
    -0.073	0.064
    -0.227	0.053
    -0.376	0.192
    -0.421	0.192
    -0.363	0.028
    -0.363	0.000
    -0.420	0.000
];

handles.acftshapes{end+1} = [ % A-29
    0.350	0.000
    0.310	0.015
    0.310	0.090
    0.310	0.015
    0.090	0.035
    0.070	0.360
    0.000	0.360
    -0.090	0.035
    -0.390	0.020
    -0.420	0.150
    -0.470	0.150
    -0.470	0.000
    -0.500  0.000
];

handles.acftshapes{end+1} = [ % Mirage 2000
    0.680	0.000
    0.560	0.032
    0.390	0.032
    0.350	0.060
    0.280	0.060
    -0.130	0.330
    -0.160	0.330
    -0.170	0.050
    -0.320	0.030
    -0.320	0.000
];

handles.acftshapes{end+1} = [ % Gripen
    0.653	0.000
    0.599	0.000
    0.483	0.032
    0.332	0.032
    0.230	0.150
    0.190	0.150
    0.210	0.056
    0.138	0.056
    -0.068	0.290
    0.062	0.290
    -0.201	0.290
    -0.164	0.290
    -0.201	0.056
    -0.346	0.018
    -0.346	0.000
];

handles.acftshapes{end+1} = [ % F-16
    0.610	0.000
    0.520	0.025
    0.400	0.025
    0.150	0.070
    -0.038	0.280
    0.040	0.280
    -0.100	0.280
    -0.100	0.050
    -0.200	0.050
    -0.300	0.155
    -0.340	0.155
    -0.340	0.030
    -0.360	0.030
    -0.360	0.000
];

handles.acftshapes{end+1} = [ % F-18
    0.671    0.000
    0.572    0.028
    0.341    0.027
    0.319    0.066
    0.110    0.066
   -0.022    0.319
    0.044    0.319
   -0.121    0.319
   -0.121    0.055
   -0.220    0.055
   -0.352    0.171
   -0.413    0.172
   -0.330    0.044
   -0.385    0.044
   -0.385    0.000
];

handles.acftshapes{end+1} = [ % F-14
    0.650	0.000
    0.560	0.032
    0.320	0.040
    0.320	0.080
    0.090	0.160
    -0.030	0.424
    -0.100	0.440
    -0.080	0.112
    -0.150	0.112
    -0.310	0.232
    -0.350	0.192
    -0.320	0.096
    -0.320	0.024
    -0.370	0.024
    -0.370	0.000
];

handles.acftshapes{end+1} = [ % F-15
    0.650	0.000
    0.530	0.030
    0.330	0.030
    0.330	0.100
    0.150	0.100
    -0.120	0.360
    -0.190	0.310
    -0.170	0.210
    -0.170	0.100
    -0.220	0.100
    -0.350	0.220
    -0.390	0.190
    -0.370	0.080
    -0.310	0.070
    -0.310	0.000
];

handles.acftshapes{end+1} = [ % F-22
    0.650	0.000
    0.530	0.028
    0.390	0.028
    0.340	0.080
    0.170	0.080
    -0.045	0.320
    -0.120	0.320
    -0.200	0.110
    -0.300	0.200
    -0.360	0.200
    -0.390	0.130
    -0.320	0.060
    -0.270	0.060
    -0.270	0.000
];

handles.acftshapes{end+1} = [ % Su-35
    0.683    0.000
    0.557    0.029
    0.336    0.029
    0.210    0.126
    0.179    0.126
    0.200    0.074
    0.147    0.074
    -0.095   0.315
    0.000    0.315
    -0.179   0.315
    -0.105   0.074
    -0.147   0.074
    -0.284   0.210
    -0.336   0.179
    -0.315   0.021
    -0.378   0.021
    -0.410   0.000
];

handles.acftshapes{end+1} = [ % Su-47
    0.720	0.000
    0.580	0.032
    0.460	0.032
    0.360	0.100
    0.300	0.100
    0.220	0.180
    0.180	0.180
    0.150	0.100
    0.050	0.150
    0.140	0.440
    0.040	0.420
    -0.150	0.150
    -0.330	0.200
    -0.370	0.200
    -0.370	0.090
    -0.340	0.090
    -0.340	0.000
];

handles.circle = .015*[cos(linspace(0,2*pi,13)') sin(linspace(0,2*pi,13)')];

acftn = strmatch(setup.acft,handles.acftlist);
if isempty(acftn), acftn(n) = 1; end
handles.acftn = acftn(1);

acftpts = handles.acftshapes{handles.acftn};

handles.acftpts = .06*[[acftpts 0*acftpts(:,1)]; flipud(acftpts(2:end-1,1)) flipud(-acftpts(2:end-1,2)) 0*acftpts(2:end-1,1)];
handles.acft = patch(scale*handles.acftpts(:,2),scale*handles.acftpts(:,1),4*ones(size(handles.acftpts(:,1))),'w','EdgeColor','w');

handles.acft2 = patch(NaN*handles.acftpts(:,2),NaN*handles.acftpts(:,1),3*ones(size(handles.acftpts(:,1))),'k','EdgeColor',green);
handles.acft3 = patch(NaN*handles.acftpts(:,2),NaN*handles.acftpts(:,1),3*ones(size(handles.acftpts(:,1))),'k','EdgeColor',blue);
handles.acft4 = patch(NaN*handles.acftpts(:,2),NaN*handles.acftpts(:,1),3*ones(size(handles.acftpts(:,1))),'k','EdgeColor',orange);

handles.acft2alt = text(0,0,'','HorizontalAlignment','center','Color',green);
handles.acft3alt = text(0,0,'','HorizontalAlignment','center','Color',blue);
handles.acft4alt = text(0,0,'','HorizontalAlignment','center','Color',orange);

set(findobj(handles.TSD,'Type','line'),'LineWidth',1.5);
set(findobj(handles.TSD,'Type','text'),'FontWeight','demi','FontName','Arial','Clipping','on');

% Armazenamento das constantes
handles.ok = 0;
handles.bst = bst;
handles.Nobs = Nobs;
handles.fname = '*.mat';
handles.fpath = [pwd filesep];
handles.trails = [0 15 30 60 120 300 600 1200];
handles.evt = evt;
handles.evd = evd;
handles.tpt = tpt;
handles.tpd = tpd;
handles.events  = events;
handles.testpts = testpts;
setappdata(handles.window,'N',N);
setappdata(handles.window,'Q',1);
setappdata(handles.window,'fov',fov);
setappdata(handles.window,'mode',1);
setappdata(handles.window,'origin',[0 0 0]);
setappdata(handles.window,'acftdata',[0 0 0]);
setappdata(handles.window,'ttrail',options.ttrail);
setappdata(handles.window,'showwpt',[]);
setappdata(handles.window,'scenario',scenario);
DADOS2 = zeros(Nobs,4); % [evt, testpt, dt, freq]

handles.hudfixedsymbols = [handles.rollarc handles.Vcbox handles.Zpbox handles.psibox handles.Zaglbox handles.DLZticks];
handles.hudfixedtexts = [handles.time handles.Vc handles.Zp handles.psi handles.Zagl handles.Nz handles.M handles.aoa handles.Rrng,...
        handles.Rclo handles.FYTbox handles.NAVbox handles.fuel handles.seekerang handles.pickle handles.trigger,...
        handles.eventdescr handles.testptdescr handles.Zagllbl handles.DLZscale];

guidata(hObject, handles);

% Configuraçao das telas
if ~isempty(options.winpos)
    set(handles.window,'Position',options.winpos);
end
set(handles.HUD_chk ,'Value',options.screens(1));
set(handles.LTSD_chk,'Value',options.screens(2));
set(handles.grid_chk,'Value',options.screens(3));
set(handles.RTSD_chk,'Value',options.screens(4));
updatescreen(hObject, eventdata, handles);
trailup_btn_Callback(hObject, eventdata, handles, 0);
for n = 1:length(options.declutter)
    set(handles.TSDctrl(n),'Value',options.declutter(n));
end
set(handles.OpenGL_btn,'Value',options.OpenGL);
OpenGL_btn_Callback(hObject, eventdata, handles);

if ~isempty(options.slider)
    set(handles.vslider,'Value',options.slider);
    vslider_Callback(hObject, eventdata, handles);
end

% Configuraçao dos dados
setplaybackdata(hObject, eventdata, handles, setup, scenario, 0);
setevents(hObject, eventdata, handles);
settestpts(hObject, eventdata, handles);

uiwait(handles.window);

% ---------------------------------------------------------------
function varargout = RDAT_Playback_OutputFcn(hObject, eventdata, handles)
global DADOS2
% Funçao de saida

if handles.ok
    [setup, scenario] = getplaybackdata(handles);
    varargout{1} = setup;
    varargout{2} = scenario;
else
    varargout{1} = [];
    varargout{2} = [];
end

try
    options.OpenGL  = get(handles.OpenGL_btn,'Value');
    options.ttrail  = getappdata(handles.window,'ttrail');
    options.FYT     = get(handles.FYTlbl,'UserData');
    options.NAV     = get(handles.NAVlbl,'UserData');
    options.CRS     = get(handles.CRSlbl,'UserData');
    options.scale   = str2double(get(handles.scale,'String'));
    options.screens = [get(handles.HUD_chk,'Value') get(handles.LTSD_chk,'Value') get(handles.grid_chk,'Value') get(handles.RTSD_chk,'Value')];
    options.winpos  = get(handles.window,'Position');
    options.slider  = get(handles.vslider,'Value');
    for n = 1:length(handles.TSDctrl), options.declutter(n) = get(handles.TSDctrl(n),'Value'); end
catch
    options = [];
end

varargout{3} = options;
clear global DADOS2

delete(handles.window);

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
    set(handles.sliderball,'XData',round(N));
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
    set(handles.sliderball,'XData',1);
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
    set(handles.sliderball,'XData',N);
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
    set(handles.sliderball,'XData',N);
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

set(handles.sliderball,'XData',N);
setappdata(handles.window,'N',N);
set(handles.NoOBS,'String',num2str(N));
updateplot(hObject, eventdata, handles);

% ---------------------------------------------------------------
function updateplot(hObject, eventdata, handles)
global DADOS DADOS2
% Atualizaçao de todas as telas

N = round(getappdata(handles.window,'N'));

H = get(handles.HUD_chk,'Value');
T = get(handles.LTSD_chk,'Value') || get(handles.RTSD_chk,'Value');
G = get(handles.grid_chk,'Value');

scenario = getappdata(handles.window,'scenario');
fov = getappdata(handles.window,'fov');

% Data collection

% Common data
n_time  = get(handles.time_sel,'Value')-1;
n_Zp    = get(handles.Zp_sel  ,'Value')-1;
n_lat   = get(handles.lat_sel ,'Value')-1;
n_lon   = get(handles.lon_sel ,'Value')-1;
n_psi   = get(handles.psi_sel ,'Value')-1;
n_Gtrk  = get(handles.Gtrk_sel,'Value')-1;
n_tet   = get(handles.tet_sel ,'Value')-1;
n_phi   = get(handles.phi_sel ,'Value')-1;
n_Raz   = get(handles.Raz_sel ,'Value')-1;
n_Rel   = get(handles.Rel_sel ,'Value')-1;
n_Rrng  = get(handles.Rrng_sel,'Value')-1;
n_Rasp  = get(handles.Rasp_sel,'Value')-1;

n_lat2 = get(handles.lat2_sel,'Value')-1;
n_lon2 = get(handles.lon2_sel,'Value')-1;
n_alt2 = get(handles.alt2_sel,'Value')-1;
n_lat3 = get(handles.lat3_sel,'Value')-1;
n_lon3 = get(handles.lon3_sel,'Value')-1;
n_alt3 = get(handles.alt3_sel,'Value')-1;
n_lat4 = get(handles.lat4_sel,'Value')-1;
n_lon4 = get(handles.lon4_sel,'Value')-1;
n_alt4 = get(handles.alt4_sel,'Value')-1;

if n_time
    if N > 1
        dt = DADOS2(N,3);
    else
        dt = NaN;
    end
else
    dt = NaN;
end
if n_Zp
    Zp = DADOS(N,n_Zp);
    Zp_str = int2str(Zp);
    if length(Zp_str) > 3, Zp_str = [Zp_str(1:end-3) ',' Zp_str(end-2:end)]; end
else
    Zp = 0;
    Zp_str = 'XX,XXX';
end
if n_lat
    lat = DADOS(N,n_lat);
    if isnan(lat)
        lat = 0;
    end
else
    lat = 0;
end
if n_lon
    lon = DADOS(N,n_lon);
    if isnan(lon)
        lon = 0;
    end
else
    lon = 0;
end
if n_psi
    psi = mod(DADOS(N,n_psi),360);
    if isnan(psi)
        psi = 0;
        psi_str = 'XXX';
        n_Gtrk = 0;
    else
        psi_str = int2str(psi);
        while length(psi_str) < 3
            psi_str = ['0' psi_str];
        end
    end
else
    psi = 0;
    psi_str = 'XXX';
    n_Gtrk = 0;
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
if n_Gtrk
    Gtrk = DADOS(N,n_Gtrk);
else
    Gtrk = NaN;
end
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
    if isnan(Rrng)
        Rrng_str = '';
    else
        if Rrng >= 1; 
            Rrng_str = num2str(Rrng,'%3.1f');
        else
            Rrng_str = num2str(Rrng*1852/.3048/100,'%04.0f');
        end
    end
else
    Rrng = NaN;
    Rrng_str = '';
end
if n_Rasp
    Rasp = mod(DADOS(N,n_Rasp),360);
else
    Rasp = NaN;
end

if n_lat2
    lat2 = DADOS(N,n_lat2);
else
    lat2 = NaN;
end
if n_lon2
    lon2 = DADOS(N,n_lon2);
else
    lon2 = NaN;
end
if n_alt2
    alt2 = DADOS(N,n_alt2);
    if isnan(alt2)
        alt2_str = '';
    else
        alt2_str = num2str(alt2/1000,'%2.1f');
    end
else
    alt2 = NaN;
    alt2_str = '';
end
if n_lat3
    lat3 = DADOS(N,n_lat3);
else
    lat3 = NaN;
end
if n_lon3
    lon3 = DADOS(N,n_lon3);
else
    lon3 = NaN;
end
if n_alt3
    alt3 = DADOS(N,n_alt3);
    if isnan(alt3)
        alt3_str = '';
    else
        alt3_str = num2str(alt3/1000,'%2.1f');
    end
else
    alt3 = NaN;
    alt3_str = '';
end
if n_lat4
    lat4 = DADOS(N,n_lat4);
else
    lat4 = NaN;
end
if n_lon4
    lon4 = DADOS(N,n_lon4);
else
    lon4 = NaN;
end
if n_alt4
    alt4 = DADOS(N,n_alt4);
    if isnan(alt4)
        alt4_str = '';
    else
        alt4_str = num2str(alt4/1000,'%2.1f');
    end
else
    alt4 = NaN;
    alt4_str = '';
end

phi = mod(phi,360);
if phi>180, phi = phi - 360; end

FYT = get(handles.FYTlbl,'UserData');
if ~isempty(FYT) && ~isempty(scenario) && ~isempty(scenario.wpt)
    nFYT = find(scenario.wpt.data(:,1)==FYT);
else
    nFYT = [];
end
nNAV = get(handles.NAVlbl,'UserData');
if isempty(scenario) || isempty(scenario.aid)
    nNAV = [];
end
CRS = get(handles.CRSlbl,'UserData');

Dmag = str2double(get(handles.Dmag_entry,'String'));
tpsi = psi + Dmag;
    
show_dl = get(handles.dl_chk  ,'Value');

% HUD & ENG data

if H
    n_Vc    = get(handles.Vc_sel   ,'Value')-1;
    n_M     = get(handles.M_sel    ,'Value')-1;
    n_Zagl  = get(handles.Zagl_sel ,'Value')-1;
    n_Nz    = get(handles.Nz_sel   ,'Value')-1;
    n_aoa   = get(handles.aoa_sel  ,'Value')-1;
    n_aos   = get(handles.aos_sel  ,'Value')-1;
    
    n_Ddm   = get(handles.Ddm_sel  ,'Value')-1;
    n_Ddl   = get(handles.Ddl_sel  ,'Value')-1;
    n_Ddn   = get(handles.Ddn_sel  ,'Value')-1;
    
    n_thr1  = get(handles.thr1_sel ,'Value')-1;
    n_thr2  = get(handles.thr2_sel ,'Value')-1;
    n_rpm1  = get(handles.rpm1_sel ,'Value')-1;
    n_egt1  = get(handles.egt1_sel ,'Value')-1;
    n_ff1   = get(handles.ff1_sel  ,'Value')-1;
    n_fuel1 = get(handles.fuel1_sel,'Value')-1;
    n_fuel2 = get(handles.fuel2_sel,'Value')-1;
    n_rpm2  = get(handles.rpm2_sel ,'Value')-1;
    n_egt2  = get(handles.egt2_sel ,'Value')-1;
    n_ff2   = get(handles.ff2_sel  ,'Value')-1;
    
    n_Rclo  = get(handles.Rclo_sel ,'Value')-1;
    n_Maz   = get(handles.Maz_sel  ,'Value')-1;
    n_Mel   = get(handles.Mel_sel  ,'Value')-1;
    n_trk   = get(handles.trk_sel  ,'Value')-1;
    n_Rmax1 = get(handles.Rmax1_sel,'Value')-1;
    n_Rmax2 = get(handles.Rmax2_sel,'Value')-1;
    n_Rmin  = get(handles.Rmin_sel ,'Value')-1;
    n_Paz   = get(handles.Paz_sel  ,'Value')-1;
    n_Pel   = get(handles.Pel_sel  ,'Value')-1;
    n_wrb   = get(handles.wrb_sel  ,'Value')-1;
    n_trig  = get(handles.trig_sel ,'Value')-1;
    n_Saz   = get(handles.Saz_sel  ,'Value')-1;
    n_Sel   = get(handles.Sel_sel  ,'Value')-1;
    
    if n_time
        time_str = time2str2(DADOS(N,n_time),0,2);
    else
        time_str = 'XX:XX:XX.XX';
    end
    if n_Vc
        Vc = DADOS(N,n_Vc);
        Vc_str = int2str(Vc);
    else
        Vc = 0;
        Vc_str = 'XXX';
    end
    if n_M
        M_str = num2str(DADOS(N,n_M),'%3.2f');
    else
        M_str = 'X.XX';
    end
    if n_Nz
        Nz_str = num2str(DADOS(N,n_Nz),'%2.1f');
    else
        Nz_str = 'X.X';
    end
    if n_Zagl
        Zagl = DADOS(N,n_Zagl);
        if isnan(Zagl)
            Zagl_str = '';
        else
            Zagl_str = int2str(DADOS(N,n_Zagl));
        end
    else
        Zagl = NaN;
        Zagl_str = '';
    end
    if n_aoa
        aoa = DADOS(N,n_aoa);
        aoa_str = int2str(aoa);
    else
        aoa = NaN;
        aoa_str = 'XX';
    end
    if n_aos
        aos = DADOS(N,n_aos);
    else
        aos = 0;
    end
    if n_Ddm
        Ddm = DADOS(N,n_Ddm);
    else
        Ddm = NaN;
    end
    if n_Ddl
        Ddl = DADOS(N,n_Ddl);
    else
        Ddl = NaN;
    end
    if n_Ddn
        Ddn = DADOS(N,n_Ddn);
    else
        Ddn = NaN;
    end
    
    if n_thr1
        thr1 = DADOS(N,n_thr1);
        thr1_str = num2str(thr1,'%3.1f');
    else
        thr1 = NaN;
        thr1_str = 'XX.X';
    end
    if n_rpm1
        rpm1 = DADOS(N,n_rpm1);
        rpm1_str = num2str(rpm1,'%3.1f');
    else
        rpm1 = NaN;
        rpm1_str = 'XX.X';
    end
    if n_egt1
        egt1 = DADOS(N,n_egt1);
        egt1_str = int2str(egt1);
    else
        egt1 = NaN;
        egt1_str = 'XXX';
    end
    if n_ff1
        ff1 = DADOS(N,n_ff1);
        ff1_str = int2str(ff1);
    else
        ff1 = NaN;
        ff1_str = 'XXXX';
    end
    if n_thr2
        thr2 = DADOS(N,n_thr2);
        thr2_str = num2str(thr2,'%3.1f');
    else
        thr2 = NaN;
        thr2_str = '';
    end
    if n_rpm2
        rpm2 = DADOS(N,n_rpm2);
        rpm2_str = num2str(rpm2,'%3.1f');
    else
        rpm2 = NaN;
        rpm2_str = '';
    end
    if n_egt2
        egt2 = DADOS(N,n_egt2);
        egt2_str = int2str(egt2);
    else
        egt2 = NaN;
        egt2_str = '';
    end
    if n_ff2
        ff2 = DADOS(N,n_ff2);
        ff2_str = int2str(ff2);
    else
        ff2 = NaN;
        ff2_str = '';
    end
    if n_fuel1
        fuel1 = DADOS(N,n_fuel1);
    else
        fuel1 = 0;
    end
    if n_fuel2
        fuel2 = DADOS(N,n_fuel2);
    else
        fuel2 = 0;
    end
    if n_fuel1 || n_fuel2
        if ~isnan(fuel1+fuel2)
            fuel_str = int2str(fuel1+fuel2);
        else
            fuel_str = 'XXXX';
        end
    else
        fuel_str = '';
    end

    if n_Rclo
        Rclo = DADOS(N,n_Rclo);
        if isnan(Rclo)
            Rclo_str = '';
        else
            Rclo_str = int2str(Rclo);
        end
    else
        Rclo = NaN;
        Rclo_str = '';
    end
    if n_Maz
        Maz = DADOS(N,n_Maz);
    else
        Maz = NaN;
    end
    if n_Mel
        Mel = DADOS(N,n_Mel);
    else
        Mel = NaN;
    end
    if n_trk
        trk = DADOS(N,n_trk) ~= 0;
    else
        trk = 0;
    end
    if n_Paz
        Paz = DADOS(N,n_Paz);
    else
        Paz = NaN;
    end
    if n_Pel
        Pel = DADOS(N,n_Pel);
    else
        Pel = NaN;
    end
    if n_wrb
        wrb = DADOS(N,n_wrb) > 0;
    else
        wrb = 0;
    end
    if n_trig
        trig = DADOS(N,n_trig) > 0;
    else
        trig = 0;
    end
    if n_Rmax1
        Rmax1 = DADOS(N,n_Rmax1);
    else
        Rmax1 = NaN;
    end
    if n_Rmax2
        Rmax2 = DADOS(N,n_Rmax2);
    else
        Rmax2 = NaN;
    end
    if n_Rmin
        Rmin = DADOS(N,n_Rmin);
    else
        Rmin = NaN;
    end
    if n_Saz
        Saz = DADOS(N,n_Saz);
    else
        Saz = NaN;
    end
    if n_Sel
        Sel = DADOS(N,n_Sel);
    else
        Sel = NaN;
    end
    
end

% WARN data
n_warn = [...
        get(handles.warn1_sel,'Value')-1,...
        get(handles.warn2_sel,'Value')-1,...
        get(handles.warn3_sel,'Value')-1,...
        get(handles.warn4_sel,'Value')-1];
warn   = [NaN NaN NaN NaN];
for n = 1:4
    if n_warn(n)
        warn(n) = max(0,round(DADOS(N,n_warn(n))));
    else
        warn(n) = NaN;
    end
end

% TSD data
if T
    
    mode = getappdata(handles.window,'mode');
    
    n_Wdir = get(handles.Wdir_sel,'Value')-1;
    n_Wmag = get(handles.Wmag_sel,'Value')-1;
    
    n_Rpsi = get(handles.Rpsi_sel,'Value')-1;
    n_Rzp  = get(handles.Rzp_sel ,'Value')-1;
    n_Rvc  = get(handles.Rvc_sel ,'Value')-1;
    
    n_Mlat = get(handles.Mlat_sel,'Value')-1;
    n_Mlon = get(handles.Mlon_sel,'Value')-1;
    
    n_psi2 = get(handles.psi2_sel,'Value')-1;
    n_psi3 = get(handles.psi3_sel,'Value')-1;
    n_psi4 = get(handles.psi4_sel,'Value')-1;

    if n_Wdir && n_Wmag
        Wdir = DADOS(N,n_Wdir);
        Wmag = DADOS(N,n_Wmag);
    else
        Wdir = NaN;
        Wmag = NaN;
    end
    if n_Rzp
        Rzp = DADOS(N,n_Rzp);
        if isnan(Rzp)
            Rzp_str = '';
        else
            Rzp_str = num2str(Rzp/1000,'%2.1f');
        end
    else
        Rzp_str = '';
        Rzp = NaN;
    end
    if n_Rvc
        Rvc = DADOS(N,n_Rvc);
        if isnan(Rvc)
            Rvc_str = ' ';
        else
            Rvc_str = int2str(Rvc);
        end
    else
        Rvc_str = ' ';
        Rvc = NaN;
    end
    if n_Rpsi
        Rpsi = mod(DADOS(N,n_Rpsi),360);
        if isnan(Rpsi)
            Rpsi_str = '';
        else
            Rpsi_str = [int2str(Rpsi) 'º'];
            while length(Rpsi_str) < 4
                Rpsi_str = ['0' Rpsi_str];
            end
        end
    else
        Rpsi_str = '';
        Rpsi = NaN;
    end
    if isnan(Rasp)
        Rasp_str = '';
    elseif Rasp >= 355 || Rasp <= 5
        Rasp_str = 'T';
    elseif Rasp >  5   && Rasp <  175
        Rasp_str = [int2str(Rasp/10) 'R'];
        while length(Rasp_str) < 3
            Rasp_str = ['0' Rasp_str];
        end
    elseif Rasp >= 175 && Rasp <= 185
        Rasp_str = 'H';
    elseif Rasp >  185 && Rasp <  355
        Rasp_str = [int2str(36-Rasp/10) 'L'];
        while length(Rasp_str) < 3
            Rasp_str = ['0' Rasp_str];
        end
    else
        Rasp_str = '';
    end
    
    if n_Mlat
        Mlat = DADOS(N,n_Mlat);
    else
        Mlat = NaN;
    end
    if n_Mlon
        Mlon = DADOS(N,n_Mlon);
    else
        Mlon = NaN;
    end

    if n_psi2
        psi2 = DADOS(N,n_psi2);
    else
        psi2 = NaN;
    end
    if n_psi3
        psi3 = DADOS(N,n_psi3);
    else
        psi3 = NaN;
    end
    if n_psi4
        psi4 = DADOS(N,n_psi4);
    else
        psi4 = NaN;
    end
    
    scale = str2double(get(handles.scale,'String'));
    
    % TSD mode
    if     mode == 1 % DYN
        origin = [lat lon psi];
    elseif mode == 1.5 % Armed FIX
        origin = [lat lon psi];
        setappdata(handles.window,'origin',origin);
        mode = 2; % FIX
        setappdata(handles.window,'mode',mode);
    elseif mode == 3 % CTR
        origin = [lat lon -Dmag];
    end
    if mode == 2
        origin = getappdata(handles.window,'origin');
    else
        setappdata(handles.window,'origin',origin);
    end
    
end

% HUD & ENG boxes
if H
    set(handles.time ,'String',time_str);
    set(handles.Vc   ,'String',Vc_str);
    set(handles.Zp   ,'String',Zp_str);
    set(handles.M    ,'String',M_str);
    set(handles.Zagl ,'String',Zagl_str);
    set(handles.Nz   ,'String',Nz_str);
    set(handles.psi  ,'String',psi_str);
    set(handles.aoa  ,'String',aoa_str);
    set(handles.thr1 ,'String',thr1_str);
    set(handles.rpm1 ,'String',rpm1_str);
    set(handles.egt1 ,'String',egt1_str);
    set([handles.ff1 handles.fft1] ,'String',ff1_str);
    set(handles.fuel ,'String',fuel_str);
    set(handles.thr2 ,'String',thr2_str);
    set(handles.rpm2 ,'String',rpm2_str);
    set(handles.egt2 ,'String',egt2_str);
    set([handles.ff2 handles.fft2] ,'String',ff2_str);
    set(handles.Rrng ,'String',Rrng_str);
    set(handles.Rclo ,'String',Rclo_str);
end

% HUD & ENG symbology
if H
    % Ground
    R = 21000000;
    if ~isnan(Zagl) % Aparent pitch due to height
        delta = acos(R/max(0,R+Zagl))*180/pi;
    else
        delta = acos(R/max(0,R+denan(Zp)))*180/pi;
    end
    
    Xg = handles.Xg * cos(-phi*pi/180) + handles.Yg * sin(-phi*pi/180) - (tet+delta)*sin(-phi*pi/180);
    Yg = handles.Yg * cos(-phi*pi/180) - handles.Xg * sin(-phi*pi/180) - (tet+delta)*cos(-phi*pi/180);
    set(handles.ground,'XData',Xg,'YData',Yg);
    
    % Horizon line
    Xh = fov* ( handles.Xh * cos(-phi*pi/180) + handles.Yh * sin(-phi*pi/180) ) - tet*sin(-phi*pi/180);
    Yh = fov* ( handles.Yh * cos(-phi*pi/180) - handles.Xh * sin(-phi*pi/180) ) - tet*cos(-phi*pi/180);
    set(handles.horizon,'XData',Xh,'YData',Yh);
    
    % Pitch up bars
    Xpu = handles.Xpu * cos(-phi*pi/180) + handles.Ypu * sin(-phi*pi/180) - tet*sin(-phi*pi/180);
    Ypu = handles.Ypu * cos(-phi*pi/180) - handles.Xpu * sin(-phi*pi/180) - tet*cos(-phi*pi/180);
    set(handles.pitchup,'XData',Xpu,'YData',Ypu);
    
    % Pitch down bars
    Xpd = handles.Xpd * cos(-phi*pi/180) + handles.Ypd * sin(-phi*pi/180) - tet*sin(-phi*pi/180);
    Ypd = handles.Ypd * cos(-phi*pi/180) - handles.Xpd * sin(-phi*pi/180) - tet*cos(-phi*pi/180);
    set(handles.pitchdn,'XData',Xpd,'YData',Ypd);
    
    % Pitch labels
    Xpu = handles.pitchuplblpos(:,1) * cos(-phi*pi/180) + handles.pitchuplblpos(:,2) * sin(-phi*pi/180) - tet*sin(-phi*pi/180);
    Ypu = handles.pitchuplblpos(:,2) * cos(-phi*pi/180) - handles.pitchuplblpos(:,1) * sin(-phi*pi/180) - tet*cos(-phi*pi/180);
    for n = 1:length(handles.pitchuplbl)
        if handles.pitchuplblpos(n,2) < 90 && handles.pitchuplblpos(n,2) > -90
            rot = phi;
        else
            rot = -phi+180;
        end
        set(handles.pitchuplbl(n),'Position',denanpos([Xpu(n) Ypu(n) 0]),'Rotation',rot);
    end
    
    % Roll marker
    if phi<=60 && phi>=-60
        Xrol = fov * ( handles.Xrol * cos(-phi*pi/180) + handles.Yrol * sin(-phi*pi/180) );
        Yrol = fov * ( handles.Yrol * cos(-phi*pi/180) - handles.Xrol * sin(-phi*pi/180)-.65 ) - handles.bst;
    else
        Xrol = NaN;
        Yrol = NaN;
    end
    set(handles.roll,'XData',Xrol,'YData',Yrol);
    
    % Speed ticks
    d = fov*( handles.YVticks(5)-handles.YVticks(3) );
    offset = d*(Vc-round(Vc));
    set(handles.Vcticks,'XData',fov*handles.XVticks,'YData',fov*handles.YVticks-offset-handles.bst);
    
    Vup = ceil(Vc/10)*10;
    if Vup == round(Vc), Vup = Vup + 10; end
    offset = d*(Vup-Vc);
    if Vup-Vc >= 2.5, vis = 'on'; else, vis = 'off'; end
    set(handles.Vclbl(1),'Position',denanpos([fov*handles.Vclblpos(1) fov*handles.Vclblpos(2)+offset-handles.bst 0]),'String',num2str(Vup),'Visible',vis);
    
    Vdn = Vup - 10;
    if Vdn == round(Vc), Vdn = Vdn - 10; end
    offset = d*(Vdn-Vc);
    if Vc-Vdn >= 2.5, vis = 'on'; else, vis = 'off'; end
    set(handles.Vclbl(2),'Position',denanpos([fov*handles.Vclblpos(1) fov*handles.Vclblpos(2)+offset-handles.bst 0]),'String',num2str(Vdn),'Visible',vis);
    
    if Vup-Vc > 5.5, Vup = Vup - 5; else, Vup = Vup + 5; end
    offset = d*(Vup-Vc);
    if Vup-Vc >= 2.5, vis = 'on'; else, vis = 'off'; end
    set(handles.Vclbl(3),'Position',denanpos([fov*handles.Vclblpos(1) fov*handles.Vclblpos(2)+offset-handles.bst 0]),'String',num2str(Vup),'Visible',vis);

    if Vc-Vdn > 5.5, Vdn = Vdn + 5; else, Vdn = Vdn - 5; end
    offset = d*(Vdn-Vc);
    if Vc-Vdn >= 2.5, vis = 'on'; else, vis = 'off'; end
    set(handles.Vclbl(4),'Position',denanpos([fov*handles.Vclblpos(1) fov*handles.Vclblpos(2)+offset-handles.bst 0]),'String',num2str(Vdn),'Visible',vis);
    
    % Acceleration bar
    if n_Vc && ~isnan(dt)
        k1 = max(1,N-round(1/dt));
        k2 = min(handles.Nobs,N+round(1/dt));
        dVdt = (DADOS(k2,n_Vc)-DADOS(k1,n_Vc)) / ((k2-k1)*dt);
        y = .3*dVdt/10;
        if abs(y) < 0.006;
            y = 0.006;
        end
        set(handles.acc,'XData',-fov*[.535 .535],'YData',fov*[0 y]+fov*.035-handles.bst);
    else
        set(handles.acc,'YData',[NaN NaN]);
    end
    
    % Altitude ticks
    Zp = Zp/100;
    offset = d*(Zp-round(Zp));
    set(handles.Zpticks,'XData',fov*handles.XZticks,'YData',fov*handles.YZticks-offset-handles.bst);
    
    Zup = ceil(Zp/10)*10;
    if Zup == round(Zp), Zup = Zup + 10; end
    offset = d*(Zup-Zp);
    if Zup-Zp >= 3, vis = 'on'; else, vis = 'off'; end
    set(handles.Zplbl(1),'Position',denanpos([fov*handles.Zplblpos(1) fov*handles.Zplblpos(2)+offset-handles.bst 0]),'String',strrep(num2str(Zup/10,'%04.1f'),'.',','),'Visible',vis);
    
    Zdn = Zup - 10;
    if Zdn == round(Zp), Zdn = Zdn - 10; end
    offset = d*(Zdn-Zp);
    if Zp-Zdn >= 3, vis = 'on'; else, vis = 'off'; end
    set(handles.Zplbl(2),'Position',denanpos([fov*handles.Zplblpos(1) fov*handles.Zplblpos(2)+offset-handles.bst 0]),'String',strrep(num2str(Zdn/10,'%04.1f'),'.',','),'Visible',vis);
    
    if Zup-Zp > 5.5, Zup = Zup - 5; else, Zup = Zup + 5; end
    offset = d*(Zup-Zp);
    if Zup-Zp >= 2.5, vis = 'on'; else, vis = 'off'; end
    set(handles.Zplbl(3),'Position',denanpos([fov*handles.Zplblpos(1) fov*handles.Zplblpos(2)+offset-handles.bst 0]),'String',strrep(num2str(Zup/10,'%04.1f'),'.',','),'Visible',vis);

    if Zp-Zdn > 5.5, Zdn = Zdn + 5; else, Zdn = Zdn - 5; end
    offset = d*(Zdn-Zp);
    if Zp-Zdn >= 2.5, vis = 'on'; else, vis = 'off'; end
    set(handles.Zplbl(4),'Position',denanpos([fov*handles.Zplblpos(1) fov*handles.Zplblpos(2)+offset-handles.bst 0]),'String',strrep(num2str(Zdn/10,'%04.1f'),'.',','),'Visible',vis);

    Zp = Zp*100;
    
    % Climb bar
    if n_Zp && ~isnan(dt)
        k1 = max(1,N-round(2/dt));
        k2 = min(handles.Nobs,N+round(2/dt));
        dZdt = (DADOS(k2,n_Zp)-DADOS(k1,n_Zp)) / ((k2-k1)*dt);
        y = .3*dZdt*60/10000;
        if abs(y) < 0.006;
            y = 0.006;
        end
        set(handles.climb,'XData',fov*[.535 .535],'YData',fov*[0 y]+fov*.035-handles.bst);
    else
        set(handles.climb,'YData',[NaN NaN]);
    end
    
    % Heading ticks
    d = fov*( handles.XHticks(5)-handles.XHticks(3) );
    offset = d*(psi-round(psi/5)*5)/5;
    set(handles.psiticks,'XData',fov*handles.XHticks-offset,'YData',fov*handles.YHticks-handles.bst);
    
    n = find(round(psi/10)*10==handles.psilist);
    psilbl = handles.psilist(n-2:n+2);
    psilbl2 = psilbl + (psilbl<=0)*360 - (psilbl>360)*360;
    offset = d*(psilbl-psi)/5;
    for n = 1:5
        if abs(offset(n)) <= .45*fov && abs(offset(n)) > .1*fov 
            vis = 'on';
        else
            vis = 'off';
        end
        set(handles.psilbl(n),'Position',denanpos([fov*handles.psilblpos(1)+offset(n) fov*handles.psilblpos(2)-handles.bst 0]),'String',num2str(psilbl2(n)/10,'%02.0f'),'Visible',vis);
    end

    % Ground track tick
    if ~isnan(Gtrk)
        d = mod(Gtrk-psi,360);
        if d > 180
            d = d - 360;
        end
        set(handles.GtrkH,'Position',fov*[d*.4/20 handles.psilblpos(2)+0.082 0]-[0 handles.bst 0],'String','V');
    else
        set(handles.GtrkH,'String','');
    end
    
    % FPM
    if ~isnan(aoa+aos)
        lmt = 0;
        aos_lmt = aos;
        aoa_lmt = aoa;
        if     aos < -.92*fov, aos_lmt = -.92*fov; lmt = 1;
        elseif aos >  .92*fov, aos_lmt =  .92*fov; lmt = 1; end
        if     -aoa < -.92*fov-handles.bst, aoa_lmt = -(-.92*fov-handles.bst); lmt = 1;
        elseif -aoa >  .92*fov-handles.bst, aoa_lmt = -( .92*fov-handles.bst); lmt = 1; end
        if ~lmt
            Xf = fov*handles.Xf + aos_lmt;
            Yf = fov*handles.Yf - aoa_lmt;
        else
            Xf = fov*[handles.Xf handles.XX] + aos_lmt;
            Yf = fov*[handles.Yf handles.YX] - aoa_lmt;
        end
        set(handles.fpm,'XData',Xf,'YData',Yf);
    else
        set(handles.fpm,'XData',NaN*handles.Xf,'YData',NaN*handles.Yf);
    end
    
    % FYT box and FYT symbol
    if ~isempty(nFYT) && n_lat && n_lon
        [DE, DN] = latlong2dxdy(lat,lon,scenario.wpt.data(nFYT,2),scenario.wpt.data(nFYT,3));
        DZ = (Zp-scenario.wpt.data(nFYT,4))*.3048;
        D = norm([DE DN])/1852;
        P = mod(atan2(DE,DN)*180/pi-Dmag,360);
        if ~isnan(dt)
            k1 = max(1,N-round(2/dt));
            k2 = min(handles.Nobs,N+round(2/dt));
            [dE, dN] = latlong2dxdy(DADOS(k1,n_lat),DADOS(k1,n_lon),DADOS(k2,n_lat),DADOS(k2,n_lon));
            dD = norm([dE dN])/1852;
            dT = DADOS(k2,n_time)-DADOS(k1,n_time);
            if dD/dT*3600 > 50;
                str = time2str2(round(dT*D/dD));
                if all(str(1:3)=='00:')
                    str(1:3) = [];
                end
            else
                str = 'XX:XX';
            end
        else
            str = 'XX:XX';
        end
        [Faz, Fel] = earth2hud(DN,DE,DZ,tpsi,tet,phi);
        lmt = 0;
        if     Faz < -.92*fov, Faz = -.92*fov; lmt = 1;
        elseif Faz >  .92*fov, Faz =  .92*fov; lmt = 1; end
        if     Fel < -.92*fov-handles.bst, Fel = -.92*fov-handles.bst; lmt = 1;
        elseif Fel >  .92*fov-handles.bst, Fel =  .92*fov-handles.bst; lmt = 1; end
        if ~lmt
            set(handles.FYTsymb,'XData',fov*handles.Xfythud+Faz,'YData',fov*handles.Yfythud+Fel);
        else
            set(handles.FYTsymb,'XData',fov*[handles.Xfythud handles.XX]+Faz,'YData',fov*[handles.Yfythud handles.YX]+Fel);
        end
        set(handles.FYTbox,'String',{[num2str(P,'%03.0f') 'º > ' num2str(FYT,'%02.0f')],[num2str(D,'%0.1f') ' / ' str]});
    else
        set(handles.FYTbox,'String','');
        set(handles.FYTsymb,'XData',NaN,'YData',NaN);
    end
    
    % NAV box
    if ~isempty(nNAV) && n_lat && n_lon
        [DE, DN] = latlong2dxdy(lat,lon,scenario.aid.data(nNAV,1),scenario.aid.data(nNAV,2));
        DZ = (Zp-scenario.aid.data(nNAV,3))*.3048;
        D = norm([DE DN DZ])/1852;
        P = mod(atan2(DE,DN)*180/pi-Dmag,360);
        set(handles.NAVbox,'String',[num2str(P,'%03.0f') 'º V ' num2str(D,'%0.1f')]);
    else
        set(handles.NAVbox,'String','');
    end

    % TDBox
    if ~isnan(Raz+Rel)
        
        tdbang = round(acos(cos(Raz*pi/180)*cos(Rel*pi/180))*180/pi);
        lmt = 0;
        Raz_lmt = Raz;
        Rel_lmt = Rel;
        if     Raz < -.92*fov, Raz_lmt = -.92*fov; lmt = 1;
        elseif Raz >  .92*fov, Raz_lmt =  .92*fov; lmt = 1; end
        if     Rel < -.09*fov-handles.bst, Rel_lmt = -.92*fov-handles.bst; lmt = 1;
        elseif Rel >  .92*fov-handles.bst, Rel_lmt =  .92*fov-handles.bst; lmt = 1; end
        if ~lmt
            set(handles.tdb,'XData',fov*handles.Xtdb+Raz_lmt,'YData',fov*handles.Ytdb+Rel_lmt);
        else
            set(handles.tdb,'XData',fov*[handles.Xtdb 1.5*handles.XX]+Raz_lmt,'YData',fov*[handles.Ytdb 1.5*handles.YX]+Rel_lmt);
        end
        
        if ~isnan(Rasp)
            Xasp = fov*( handles.Xasp * cos(Rasp*pi/180) + handles.Yasp * sin(Rasp*pi/180) );
            Yasp = fov*( handles.Yasp * cos(Rasp*pi/180) - handles.Xasp * sin(Rasp*pi/180) );
            d = 1.1*abs(fov*handles.Xtdb(1));
            if Rasp >= 315 || Rasp < 45
                Xasp = Xasp+Raz_lmt-d*tan(Rasp*pi/180);
                Yasp = Yasp+Rel_lmt-d;
            elseif Rasp >= 45 && Rasp < 135
                Xasp = Xasp+Raz_lmt-d;
                Yasp = Yasp+Rel_lmt-d*cot(Rasp*pi/180);
            elseif Rasp >= 135 && Rasp < 225
                Xasp = Xasp+Raz_lmt+d*tan(Rasp*pi/180);
                Yasp = Yasp+Rel_lmt+d;
            else 
                Xasp = Xasp+Raz_lmt+d;
                Yasp = Yasp+Rel_lmt+d*cot(Rasp*pi/180);
            end
            set(handles.asp,'XData',Xasp,'YData',Yasp);
        else
            set(handles.asp,'XData',NaN*handles.Xasp,'YData',NaN*handles.Yasp);
        end
        
        if lmt && ~isnan(tdbang)
            set(handles.tdbang,'String',num2str(tdbang));
        else
            set(handles.tdbang,'String','');
        end
        
    else
        set(handles.tdb,'XData',NaN*handles.Xtdb,'YData',NaN*handles.Ytdb);
        set(handles.asp,'XData',NaN*handles.Xasp,'YData',NaN*handles.Yasp);
        set(handles.tdbang,'String','');
    end
    
    % Seeker
    if ~isnan(Maz+Mel)
        seekerang = round(acos(cos(Maz*pi/180)*cos(Mel*pi/180))*180/pi);
        if isnan(seekerang)
            seekerang = '';
        end
        set(handles.seekerang,'String',num2str(seekerang));
        lmt = 0;
        Maz_lmt = Maz;
        Mel_lmt = Mel;
        if     Maz < -.92*fov, Maz_lmt = -.92*fov; lmt = 1;
        elseif Maz >  .92*fov, Maz_lmt =  .92*fov; lmt = 1; end
        if     Mel < -.92*fov-handles.bst, Mel_lmt = -.92*fov-handles.bst; lmt = 1;
        elseif Mel >  .92*fov-handles.bst, Mel_lmt =  .92*fov-handles.bst; lmt = 1; end
        if ~lmt
            set(handles.seeker,'XData',fov*(trk+1)*[handles.Xseeker]+Maz_lmt,'YData',fov*(trk+1)*[handles.Yseeker]+Mel_lmt);
        else
            set(handles.seeker,'XData',fov*(trk+1)*[handles.Xseeker .7*handles.XX]+Maz_lmt,'YData',fov*(trk+1)*[handles.Yseeker .7*handles.YX]+Mel_lmt);
        end
    else
        set(handles.seekerang,'String','');
        set(handles.seeker,'XData',NaN*handles.Xseeker,'YData',NaN*handles.Yseeker);
    end
    
    % Sensor
    if ~isnan(Saz+Sel)
        lmt = 0;
        Saz_lmt = Saz;
        Sel_lmt = Sel;
        if     Saz < -.92*fov, Saz_lmt = -.92*fov; lmt = 1;
        elseif Saz >  .92*fov, Saz_lmt =  .92*fov; lmt = 1; end
        if     Sel < -.92*fov-handles.bst, Sel_lmt = -.92*fov-handles.bst; lmt = 1;
        elseif Sel >  .92*fov-handles.bst, Sel_lmt =  .92*fov-handles.bst; lmt = 1; end
        if ~lmt
            set(handles.sensor,'XData',fov*handles.Xsensor+Saz_lmt,'YData',fov*handles.Ysensor+Sel_lmt);
        else
            set(handles.sensor,'XData',fov*[handles.Xsensor handles.XX]+Saz_lmt,'YData',fov*[handles.Ysensor handles.YX]+Sel_lmt);
        end
    else
        set(handles.sensor,'XData',NaN*handles.Xsensor,'YData',NaN*handles.Ysensor);
    end
    
    % Piper
    if ~isnan(Paz+Pel)
        if isnan(aoa) || get(handles.AA_chk,'Value')
            a = atan2(Paz,Pel);
            Xp = [fov*handles.Xpiper+Paz NaN fov*.05*sin(a) Paz-fov*.032*sin(a)];
            Yp = [fov*handles.Ypiper+Pel NaN fov*.05*cos(a) Pel-fov*.032*cos(a)];
        else
            a = atan2(Paz-aos,Pel+aoa);
            Xp = [fov*handles.Xpiper+Paz NaN  aos+fov*.032*sin(a) Paz-fov*.032*sin(a)];
            Yp = [fov*handles.Ypiper+Pel NaN -aoa+fov*.032*cos(a) Pel-fov*.032*cos(a)];
        end
        set(handles.piper,'XData',Xp,'YData',Yp);
    else
        set(handles.piper,'XData',NaN*handles.Xpiper,'YData',NaN*handles.Ypiper);
    end
    
    % DLZ
    if ~any([Rmax1 Rmax2 Rmin])
        Rmax1 = NaN;
        Rmax2 = NaN;
        Rmin  = NaN;
    end
    if ~isnan(Rmin) && ( ~isnan(Rmax1) || ~isnan(Rmax2) )
        DLZscale = min( max(0, max([Rrng Rmax1 Rmax2 Rmin])), handles.DLZscales(end));
        DLZscale = handles.DLZscales(min(find(handles.DLZscales >= DLZscale)));
        if ~isnan(Rmax1), Rmax1 = max( 0  ,min(Rmax1,DLZscale)); end
        if ~isnan(Rmin) , Rmin  = max( 0  ,min(Rmin ,Rmax1));    end
        if ~isnan(Rmax2), Rmax2 = max(Rmin,min(Rmax2,Rmax1));    end
        y0 = min(get(handles.DLZticks,'YData'));
        y1 = max(get(handles.DLZticks,'YData'));
        Rmax1 = Rmax1*(y1-y0)/DLZscale + y0;
        Rmax2 = Rmax2*(y1-y0)/DLZscale + y0;
        Rmin  = Rmin *(y1-y0)/DLZscale + y0;
        Rrngc = Rrng *(y1-y0)/DLZscale + y0;
        set(handles.DLZscale,'String',num2str(DLZscale));
        set(handles.DLZbrkt1,'XData',fov*handles.XDLZbrkt(1,:),'YData',[Rmin Rmin Rmax1 Rmax1]);
        set(handles.DLZbrkt2,'XData',fov*handles.XDLZbrkt(2,:),'YData',[Rmin Rmin Rmax2 Rmax2]);
        if isnan(Rrngc) || Rrng > DLZscale
            Rrngc = 1e4;
        end
        set(handles.DLZrng,'Position',[fov*handles.XDLZbrkt(2,1) Rrngc 0]);
        set([handles.DLZticks handles.DLZscale handles.DLZrng],'Visible','on');
    else
        set([handles.DLZticks handles.DLZscale handles.DLZrng],'Visible','off');
        set(handles.DLZbrkt1,'XData',NaN*handles.XDLZbrkt(1,:),'YData',[NaN NaN NaN NaN]);
        set(handles.DLZbrkt2,'XData',NaN*handles.XDLZbrkt(2,:),'YData',[NaN NaN NaN NaN]);
    end
    
    % Pickle
    if wrb
        set(handles.pickle,'String','P');
    else
        set(handles.pickle,'String','');
    end
    if trig
        set(handles.trigger,'String','T');
    else
        set(handles.trigger,'String','');
    end
    
    % Messages
    if DADOS2(N,1)
        set(handles.eventdescr,'String',handles.evd{DADOS2(N,1)});
    else
        set(handles.eventdescr,'String','');
    end
    if DADOS2(N,2)
        str = handles.tpd{DADOS2(N,2)};
        ix = find(str=='-');
        set(handles.testptdescr,'String',str(ix(1)+2:end));
    else
        set(handles.testptdescr,'String','');
    end
    
    % Other acft
    if show_dl
        if n_lat2 && n_lon2 && n_alt2
            [DE, DN] = latlong2dxdy(lat,lon,lat2,lon2);
            DZ = (Zp-alt2)*.3048;
            [Daz, Del] = earth2hud(DN,DE,DZ,tpsi,tet,phi);
            set(handles.acft2hud,'String',' 2 ','Position',denanpos([Daz Del 0]));
        else
            set(handles.acft2hud,'String','');
        end
        if n_lat3 && n_lon3 && n_alt3
            [DE, DN] = latlong2dxdy(lat,lon,lat3,lon3);
            DZ = (Zp-alt3)*.3048;
            [Daz, Del] = earth2hud(DN,DE,DZ,tpsi,tet,phi);
            set(handles.acft3hud,'String',' 3 ','Position',denanpos([Daz Del 0]));
        else
            set(handles.acft3hud,'String','');
        end
        if n_lat4 && n_lon4 && n_alt4
            [DE, DN] = latlong2dxdy(lat,lon,lat4,lon4);
            DZ = (Zp-alt4)*.3048;
            [Daz, Del] = earth2hud(DN,DE,DZ,tpsi,tet,phi);
            set(handles.acft4hud,'String',' 4 ','Position',denanpos([Daz Del 0]));
        else
            set(handles.acft4hud,'String','');
        end
    else
        set([handles.acft2hud handles.acft3hud handles.acft4hud],'String','');
    end
    
    % Engine & Flight Controls screen setup
    pos = get(handles.ENG,'Position');
    if n_thr1+n_thr2
        set([handles.thr1 handles.thr2 handles.throttleaxis handles.throttles],'Visible','on');
        set(handles.ENG,'XLim',[0 pos(3)/pos(4)],'YLim',[0 1]);
    else
        set([handles.thr1 handles.thr2 handles.throttleaxis handles.throttles],'Visible','off');
        if n_Ddm+n_Ddl+n_Ddn
            set(handles.ENG,'XLim',[0 pos(3)/pos(4)]+.15,'YLim',[0 1]);
        else
            set(handles.ENG,'XLim',[0 .94*pos(3)/pos(4)]+.15,'YLim',[.06 1]-.01);
        end
    end
    if n_Ddm+n_Ddl+n_Ddn
        set(handles.ffgauge,'Visible','off');
        set(handles.fftapes(1,:),'Visible','on');
        if n_ff2
            set(handles.fftapes(2,:),'Visible','on');
        else
            set(handles.fftapes(2,:),'Visible','off');
        end
        set(handles.cmdgrid,'Visible','on');
    else
        set(handles.ffgauge,'Visible','on');
        set(handles.fftapes,'Visible','off');
        set(handles.cmdgrid,'Visible','off');
    end
    
    % Flight Controls
    dxdy = get(handles.cmdgrid(1),'UserData'); dx = dxdy(1:2); dy = dxdy(3:4);
    if ~isnan(Ddm), pm = (max(-100,min(100,-Ddm))+100)/200*(dy(2)-dy(1))+dy(1); else pm = NaN; end
    if ~isnan(Ddl), pl = (max(-100,min(100, Ddl))+100)/200*(dx(2)-dx(1))+dx(1); else pl = NaN; end
    if ~isnan(Ddn), pn = (max(-100,min(100, Ddn))+100)/200*(dx(2)-dx(1))+dx(1); else pn = NaN; end
    set(handles.stick,'XData',pl,'YData',pm);
    set(handles.rudder,'XData',pn);

    % Engine indications
    dy = [.25 .9];
    if ~isnan(thr1), p1 = max(0,min(100,thr1))/100*(dy(2)-dy(1))+dy(1); else p1 = NaN; end
    if ~isnan(thr2), p2 = max(0,min(100,thr2))/100*(dy(2)-dy(1))+dy(1); else p2 = NaN; end
    if n_thr1 && ~n_thr2
        set(handles.throttles,'YData',[NaN p1 p1 p1 p1 p1 NaN]);
    else
        set(handles.throttles,'YData',[p1 p1 p1 NaN p2 p2 p2]);
    end
    
    dy = [.25 .8];
    p1 = ff1/handles.engmax(1,3);
    p2 = ff2/handles.engmax(1,3);
    if ~isnan(p1), p1 = max(0,min(1,p1))*(dy(2)-dy(1))+dy(1); end
    if ~isnan(p2), p2 = max(0,min(1,p2))*(dy(2)-dy(1))+dy(1); end
    set(handles.fftape1,'YData',[.25 .25 p1 p1]);
    set(handles.fftape2,'YData',[.25 .25 p2 p2]);
    
    a1 = rpm1/handles.engmax(1,1);
    a2 = rpm2/handles.engmax(1,1);
    if ~isnan(a1), a1 = max(0,min(1,a1))*3.1*pi/2; end
    if ~isnan(a2), a2 = max(0,min(1,a2))*3.1*pi/2; end
    set(handles.engpointer(1,1),'XData',.8+[0 -.25*sin(a1)],'YData',.5+[0 -.25*cos(a1)]);
    set(handles.engpointer(1,2),'XData',.8+[0 -.25*sin(a2)],'YData',.5+[0 -.25*cos(a2)]);
    a1 = egt1/handles.engmax(1,2);
    a2 = egt2/handles.engmax(1,2);
    if ~isnan(a1), a1 = max(0,min(1,a1))*3.1*pi/2; end
    if ~isnan(a2), a2 = max(0,min(1,a2))*3.1*pi/2; end
    set(handles.engpointer(2,1),'XData',1.7+[0 -.25*sin(a1)],'YData',.5+[0 -.25*cos(a1)]);
    set(handles.engpointer(2,2),'XData',1.7+[0 -.25*sin(a2)],'YData',.5+[0 -.25*cos(a2)]);
    a1 = ff1/handles.engmax(1,3);
    a2 = ff2/handles.engmax(1,3);
    if ~isnan(a1), a1 = max(0,min(1,a1))*3.1*pi/2; end
    if ~isnan(a2), a2 = max(0,min(1,a2))*3.1*pi/2; end
    set(handles.engpointer(3,1),'XData',2.6+[0 -.25*sin(a1)],'YData',.5+[0 -.25*cos(a1)]);
    set(handles.engpointer(3,2),'XData',2.6+[0 -.25*sin(a2)],'YData',.5+[0 -.25*cos(a2)]);
end

% Warnings
for n = 1:4
    if isnan(warn(n))
        set(handles.warnlist(:,n),'Visible','off');
    else
        if ~warn(n)
            set(handles.warnlist(1,n),'String','','Visible','off');
            set(handles.warnlist(2,n),'BackgroundColor',handles.warncolors(n,:)*.25,'Visible','on');
        elseif warn(n) == 1
            set(handles.warnlist(1,n),'String','','Visible','off');
            set(handles.warnlist(2,n),'BackgroundColor',handles.warncolors(n,:),'Visible','on');
        elseif warn(n) >= 99.5
            set(handles.warnlist(1,n),'String','X');
            set(handles.warnlist(:,n),'BackgroundColor',handles.warncolors(n,:),'Visible','on');
        else
            set(handles.warnlist(1,n),'String',int2str(warn(n)));
            set(handles.warnlist(:,n),'BackgroundColor',handles.warncolors(n,:),'Visible','on');
        end
    end
end

% TSD symbology
if T
    
    show_map  = get(handles.map_chk ,'Value');
    show_aux  = get(handles.aux_chk ,'Value');
    show_aid  = get(handles.aid_chk ,'Value');
    show_wpt  = get(handles.wpt_chk ,'Value');
    show_fa   = get(handles.fa_chk  ,'Value');
    show_rt   = get(handles.rt_chk  ,'Value');
    show_avd  = get(handles.avd_chk ,'Value');
    show_thr  = get(handles.thr_chk ,'Value');
    show_cnt  = get(handles.cnt_chk ,'Value');

    % TSD origin
    lat1 = origin(1);
    lon1 = origin(2);
    psi1 = origin(3);
    
    tpsi1 = psi1 + Dmag;

    % Cursor data block
    updatecursor(hObject, eventdata, handles);
    
    % Radar data block
    set(handles.rdb,'String',{Rvc_str,Rpsi_str,Rasp_str});
    
    % Acft 2,3,4 data block
    if show_dl
        [DE, DN] = latlong2dxdy(lat,lon,lat2,lon2);
        Rng = sqrt(DE^2+DN^2)/1852;
        Brg = mod(atan2(DE,DN)*180/pi-Dmag,360);
        if ~isnan(Rng)
            set(handles.acft2db,'String',{[num2str(Brg,'%03.0f') 'º'],num2str(Rng,'%0.1f')});
        else
            set(handles.acft2db,'String',{'',''});
        end
        
        [DE, DN] = latlong2dxdy(lat,lon,lat3,lon3);
        Rng = sqrt(DE^2+DN^2)/1852;
        Brg = mod(atan2(DE,DN)*180/pi-Dmag,360);
        if ~isnan(Rng)
            set(handles.acft3db,'String',{[num2str(Brg,'%03.0f') 'º'],num2str(Rng,'%0.1f')});
        else
            set(handles.acft3db,'String',{'',''});
        end
        
        [DE, DN] = latlong2dxdy(lat,lon,lat4,lon4);
        Rng = sqrt(DE^2+DN^2)/1852;
        Brg = mod(atan2(DE,DN)*180/pi-Dmag,360);
        if ~isnan(Rng)
            set(handles.acft4db,'String',{[num2str(Brg,'%03.0f') 'º'],num2str(Rng,'%0.1f')});
        else
            set(handles.acft4db,'String',{'',''});
        end
    end
    
    % Wind rose
    if mode == 2 % FIX
        dx = mean(get(handles.TSD,'XLim'));
        dy = min(get(handles.TSD,'YLim'))+1/3*diff(get(handles.TSD,'YLim'));
    else
        dx = 0;
        dy = 0;
    end
    Xwr = handles.Xwr * cos(-psi1*pi/180) + handles.Ywr * sin(-psi1*pi/180);
    Ywr = handles.Ywr * cos(-psi1*pi/180) - handles.Xwr * sin(-psi1*pi/180);
    set(handles.windrose,'XData',scale*Xwr+dx,'YData',scale*Ywr+dy);
    Xwr = handles.windroselblpos(:,1) * cos(-psi1*pi/180) + handles.windroselblpos(:,2) * sin(-psi1*pi/180);
    Ywr = handles.windroselblpos(:,2) * cos(-psi1*pi/180) - handles.windroselblpos(:,1) * sin(-psi1*pi/180);
    for n = 1:size(handles.windroselblpos,1)
        set(handles.windroselbl(n),'Position',denanpos([scale*Xwr(n)+dx scale*Ywr(n)+dy 2]));
    end

    % Wind rose ticks
    switch mode
        case 1 % DYN
            set(handles.windroseticks,'XData',scale*handles.Xwrt,'YData',scale*handles.Ywrt);
        case 2 % FIX
            set(handles.windroseticks,'XData',NaN*handles.Xwrt);
        case 3 % CTR
            Xwrt = handles.Xwrt * cos((psi-psi1)*pi/180) + handles.Ywrt * sin((psi-psi1)*pi/180);
            Ywrt = handles.Ywrt * cos((psi-psi1)*pi/180) - handles.Xwrt * sin((psi-psi1)*pi/180);
            set(handles.windroseticks,'XData',scale*Xwrt,'YData',scale*Ywrt);            
    end

    % Wind
    if ~isnan(Wdir) && ~isnan(Wmag)
        ang = mod(Wdir-psi1,360);
        if Wmag >= 99.5
            r = .24;
        else
            r = .235;
        end
        Xwind = handles.Xwind * cos(ang*pi/180) + handles.Ywind * sin(ang*pi/180);
        Ywind = handles.Ywind * cos(ang*pi/180) - handles.Xwind * sin(ang*pi/180);
        set(handles.Wmag,'Position',denanpos([scale*r*sin(ang*pi/180) scale*r*cos(ang*pi/180) 2]+[dx dy 0]),'String',int2str(Wmag));
    else
        Xwind = NaN;
        Ywind = NaN;
        set(handles.Wmag,'Position',denanpos([NaN NaN NaN]));
    end
    set(handles.Wdir,'XData',scale*Xwind+dx,'YData',scale*Ywind+dy,'ZData',2+0*Xwind);
    
    % Ground track
    if ~isnan(Gtrk) && mode ~= 2
        ang = mod(Gtrk-psi1,360);
        Xgt = handles.Xgt * cos(ang*pi/180) + handles.Ygt * sin(ang*pi/180);
        Ygt = handles.Ygt * cos(ang*pi/180) - handles.Xgt * sin(ang*pi/180);
    else
        Xgt = NaN;
        Ygt = NaN;
    end
    set(handles.GtrkT,'XData',scale*Xgt+dx,'YData',scale*Ygt+dy,'ZData',2+0*Xgt);
    
    % RMI
    if ~isempty(nNAV) && strcmp(get(handles.CRSlbl,'Visible'),'off') && mode == 1
        [DE, DN] = latlong2dxdy(lat,lon,scenario.aid.data(nNAV,1),scenario.aid.data(nNAV,2));
        P = atan2(DE,DN);
        Xrmi = handles.Xrmi * cos(P-tpsi1*pi/180) + handles.Yrmi * sin(P-tpsi1*pi/180);
        Yrmi = handles.Yrmi * cos(P-tpsi1*pi/180) - handles.Xrmi * sin(P-tpsi1*pi/180);
    else
        Xrmi = NaN;
        Yrmi = NaN;
    end
    set(handles.RMI,'XData',scale*Xrmi,'Ydata',scale*Yrmi,'ZData',2+0*Xrmi);
    
    % VOR
    if ~isempty(nNAV) && strcmp(get(handles.CRSlbl,'Visible'),'on') && mode == 1
        [DE, DN] = latlong2dxdy(lat,lon,scenario.aid.data(nNAV,1),scenario.aid.data(nNAV,2));
        P = atan2(DE,DN);
        Rdl = mod((P - pi)*180/pi - Dmag,360);
        dev = rem(CRS - Rdl,360);
        if dev > 180
            dev = dev - 360;
        end
        if abs(dev) > 90
            dev = 180-dev;
            tf = -1;
            if dev > 180
                dev = dev - 360;
            end
        else
            tf = 1;
        end
        k = 10;
        if dev < -k
            dev = -k;
            st = '--';
        elseif dev > k
            dev = k;
            st = '--';
        else
            st = '-';
        end
        if abs(dev) <= 5
            ky = 1;
        else
            ky = cos((dev*45/5)*pi/180)+1-cos(pi/4);
        end
        Xvor = handles.Xvor * cos(P-tpsi1*pi/180) + handles.Yvor * sin(P-tpsi1*pi/180);
        Yvor = handles.Yvor * cos(P-tpsi1*pi/180) - handles.Xvor * sin(P-tpsi1*pi/180);
        Xcrs = handles.Xcrs * cos((CRS-psi1)*pi/180) + handles.Ycrs * sin((CRS-psi1)*pi/180);
        Ycrs = handles.Ycrs * cos((CRS-psi1)*pi/180) - handles.Xcrs * sin((CRS-psi1)*pi/180);
        Xcdi = (handles.Xcdi+.17*dev/k) * cos((CRS-psi1)*pi/180) + ky*handles.Ycdi * sin((CRS-psi1)*pi/180);
        Ycdi = ky*handles.Ycdi * cos((CRS-psi1)*pi/180) - (handles.Xcdi+.17*dev/k) * sin((CRS-psi1)*pi/180);
        Xtf  = handles.Xtf * cos((CRS-psi1)*pi/180) + tf*handles.Ytf * sin((CRS-psi1)*pi/180);
        Ytf  = tf*handles.Ytf * cos((CRS-psi1)*pi/180) - handles.Xtf * sin((CRS-psi1)*pi/180);
    else
        Xvor = NaN;
        Yvor = NaN;
        Xcrs = NaN;
        Ycrs = NaN;
        Xcdi = NaN;
        Ycdi = NaN;
        Xtf  = NaN;
        Ytf  = NaN;
        st = '-';
    end
    set(handles.VOR,'XData',scale*Xvor,'Ydata',scale*Yvor,'ZData',2+0*Xvor);
    set(handles.CRS,'XData',scale*Xcrs,'Ydata',scale*Ycrs,'ZData',2+0*Xcrs);
    set(handles.CDI,'XData',scale*Xcdi,'Ydata',scale*Ycdi,'ZData',2+0*Xcdi,'LineStyle',st);
    set(handles.TF ,'XData',scale*Xtf ,'Ydata',scale*Ytf ,'ZData',2.1+0*Xtf);
    
    % Aircraft
    [DE, DN] = latlong2dxdy(lat1,lon1,lat,lon);
    Dx = ( DE * cos(-tpsi1*pi/180) + DN * sin(-tpsi1*pi/180) )/1852;
    Dy = ( DN * cos(-tpsi1*pi/180) - DE * sin(-tpsi1*pi/180) )/1852;
    Xacft = scale*( handles.acftpts(:,2) * cos((psi-psi1)*pi/180) + handles.acftpts(:,1) * sin((psi-psi1)*pi/180) );
    Yacft = scale*( handles.acftpts(:,1) * cos((psi-psi1)*pi/180) - handles.acftpts(:,2) * sin((psi-psi1)*pi/180) );
    Xacft = Xacft + Dx;
    Yacft = Yacft + Dy;
    set(handles.acft,'XData',Xacft,'YData',Yacft,'ZData',4+0*Xacft);
    setappdata(handles.window,'acftdata',[Dx Dy psi]);
    
    % Other acfts
    if show_dl
        if n_psi2
            Xacft = scale*( handles.acftpts(:,2) * cos((psi2-psi1)*pi/180) + handles.acftpts(:,1) * sin((psi2-psi1)*pi/180) );
            Yacft = scale*( handles.acftpts(:,1) * cos((psi2-psi1)*pi/180) - handles.acftpts(:,2) * sin((psi2-psi1)*pi/180) );
            set(handles.acft2,'LineWidth',.5);
        else
            Xacft = scale*handles.circle(:,2);
            Yacft = scale*handles.circle(:,1);
            set(handles.acft2,'LineWidth',1.5);
        end
        [DE, DN] = latlong2dxdy(lat1,lon1,lat2,lon2);
        Xacft = Xacft + ( DE * cos(-tpsi1*pi/180) + DN * sin(-tpsi1*pi/180) )/1852;
        Yacft = Yacft + ( DN * cos(-tpsi1*pi/180) - DE * sin(-tpsi1*pi/180) )/1852;
        set(handles.acft2,'XData',Xacft,'YData',Yacft,'ZData',3+0*Xacft);
        if sign(sin((psi2-psi1)*pi/180)) < 0 && sign(cos((psi2-psi1)*pi/180)) < 0,  k = 1; else, k = -1; end
        set(handles.acft2alt,'String',alt2_str,'Position',denanpos([nanmean(Xacft)+k*.025*scale nanmean(Yacft)-.025*scale 0]));
        
        if n_psi3
            Xacft = scale*( handles.acftpts(:,2) * cos((psi3-psi1)*pi/180) + handles.acftpts(:,1) * sin((psi3-psi1)*pi/180) );
            Yacft = scale*( handles.acftpts(:,1) * cos((psi3-psi1)*pi/180) - handles.acftpts(:,2) * sin((psi3-psi1)*pi/180) );
            set(handles.acft3,'LineWidth',.5);
        else
            Xacft = scale*handles.circle(:,2);
            Yacft = scale*handles.circle(:,1);
            set(handles.acft3,'LineWidth',1.5);
        end
        [DE, DN] = latlong2dxdy(lat1,lon1,lat3,lon3);
        Xacft = Xacft + ( DE * cos(-tpsi1*pi/180) + DN * sin(-tpsi1*pi/180) )/1852;
        Yacft = Yacft + ( DN * cos(-tpsi1*pi/180) - DE * sin(-tpsi1*pi/180) )/1852;
        set(handles.acft3,'XData',Xacft,'YData',Yacft,'ZData',3+0*Xacft);
        if sign(sin((psi3-psi1)*pi/180)) < 0 && sign(cos((psi3-psi1)*pi/180)) < 0,  k = 1; else, k = -1; end
        set(handles.acft3alt,'String',alt3_str,'Position',denanpos([nanmean(Xacft)+k*.025*scale nanmean(Yacft)-.025*scale 0]));
        
        if n_psi4
            Xacft = scale*( handles.acftpts(:,2) * cos((psi4-psi1)*pi/180) + handles.acftpts(:,1) * sin((psi4-psi1)*pi/180) );
            Yacft = scale*( handles.acftpts(:,1) * cos((psi4-psi1)*pi/180) - handles.acftpts(:,2) * sin((psi4-psi1)*pi/180) );
            set(handles.acft4,'LineWidth',.5);
        else
            Xacft = scale*handles.circle(:,2);
            Yacft = scale*handles.circle(:,1);
            set(handles.acft4,'LineWidth',1.5);
        end
        [DE, DN] = latlong2dxdy(lat1,lon1,lat4,lon4);
        Xacft = Xacft + ( DE * cos(-tpsi1*pi/180) + DN * sin(-tpsi1*pi/180) )/1852;
        Yacft = Yacft + ( DN * cos(-tpsi1*pi/180) - DE * sin(-tpsi1*pi/180) )/1852;
        set(handles.acft4,'XData',Xacft,'YData',Yacft,'ZData',3+0*Xacft);
        if sign(sin((psi4-psi1)*pi/180)) < 0 && sign(cos((psi4-psi1)*pi/180)) < 0,  k = 1; else, k = -1; end
        set(handles.acft4alt,'String',alt4_str,'Position',denanpos([nanmean(Xacft)+k*.025*scale nanmean(Yacft)-.025*scale 0]));
    end
    
    % Trail
    if isnan(dt)
        set([handles.trail handles.trail2 handles.trail3 handles.trail4],'XData',NaN,'YData',NaN,'ZData',NaN);
    else
        ttrail = getappdata(handles.window,'ttrail');
        k = fix(ttrail/dt);
        if n_lat && n_lon
            [DE, DN] = latlong2dxdy(lat1,lon1,DADOS(max(1,N-k):N,n_lat),DADOS(max(1,N-k):N,n_lon));
        else
            DE = NaN;
            DN = NaN;
        end
        Xtrail = ( DE * cos(-tpsi1*pi/180) + DN * sin(-tpsi1*pi/180) )/1852;
        Ytrail = ( DN * cos(-tpsi1*pi/180) - DE * sin(-tpsi1*pi/180) )/1852;
        set(handles.trail,'XData',Xtrail,'YData',Ytrail,'ZData',0*Xtrail);
        
        if n_lat2 && n_lon2
            [DE, DN] = latlong2dxdy(lat1,lon1,DADOS(max(1,N-k):N,n_lat2),DADOS(max(1,N-k):N,n_lon2));
        else
            DE = NaN;
            DN = NaN;
        end
        Xtrail = ( DE * cos(-tpsi1*pi/180) + DN * sin(-tpsi1*pi/180) )/1852;
        Ytrail = ( DN * cos(-tpsi1*pi/180) - DE * sin(-tpsi1*pi/180) )/1852;
        set(handles.trail2,'XData',Xtrail,'YData',Ytrail,'ZData',0*Xtrail);
        
        if n_lat3 && n_lon3
            [DE, DN] = latlong2dxdy(lat1,lon1,DADOS(max(1,N-k):N,n_lat3),DADOS(max(1,N-k):N,n_lon3));
        else
            DE = NaN;
            DN = NaN;
        end
        Xtrail = ( DE * cos(-tpsi1*pi/180) + DN * sin(-tpsi1*pi/180) )/1852;
        Ytrail = ( DN * cos(-tpsi1*pi/180) - DE * sin(-tpsi1*pi/180) )/1852;
        set(handles.trail3,'XData',Xtrail,'YData',Ytrail,'ZData',0*Xtrail);

        if n_lat4 && n_lon4
            [DE, DN] = latlong2dxdy(lat1,lon1,DADOS(max(1,N-k):N,n_lat4),DADOS(max(1,N-k):N,n_lon4));
        else
            DE = NaN;
            DN = NaN;
        end
        Xtrail = ( DE * cos(-tpsi1*pi/180) + DN * sin(-tpsi1*pi/180) )/1852;
        Ytrail = ( DN * cos(-tpsi1*pi/180) - DE * sin(-tpsi1*pi/180) )/1852;
        set(handles.trail4,'XData',Xtrail,'YData',Ytrail,'ZData',0*Xtrail);

    end
    
    % Target
    if ~isnan(Rpsi)
        Xtgt = handles.tgtpts(:,1) * cos((Rpsi-psi1)*pi/180) + handles.tgtpts(:,2) * sin((Rpsi-psi1)*pi/180);
        Ytgt = handles.tgtpts(:,2) * cos((Rpsi-psi1)*pi/180) - handles.tgtpts(:,1) * sin((Rpsi-psi1)*pi/180);
    else
        Xtgt = handles.tgtpts(1:17,1);
        Ytgt = handles.tgtpts(1:17,2);
    end
    Rxy = tgt2earth(Rrng.*[cos(Rel*pi/180).*cos(Raz*pi/180) cos(Rel*pi/180).*sin(-Raz*pi/180) sin(Rel*pi/180)],psi-psi1,tet,phi,Dx,Dy,0);
    Xtgt = scale*Xtgt+Rxy(1);
    Ytgt = scale*Ytgt+Rxy(2);
    set(handles.target,'XData',Xtgt,'YData',Ytgt,'ZData',0*Xtgt+3);
    set(handles.tgtalt,'String',Rzp_str,'Position',denanpos([nanmean(Xtgt)-.025*scale nanmean(Ytgt)-.025*scale 0]));
    
    % Missile present position
    if ~isnan(Mlat) && ~isnan(Mlon)
        [DE, DN] = latlong2dxdy(lat1,lon1,Mlat,Mlon);
        Xmpp = ( DE * cos(-tpsi1*pi/180) + DN * sin(-tpsi1*pi/180) )/1852;
        Ympp = ( DN * cos(-tpsi1*pi/180) - DE * sin(-tpsi1*pi/180) )/1852;
    else
        Xmpp = NaN;
        Ympp = NaN;
    end
    set(handles.mpp,'XData',Xmpp,'YData',Ympp,'ZData',3.5);

    % Maps
    if show_map && ~isempty(handles.map)
        for n = 1:length(handles.map)
            [DE, DN] = latlong2dxdy(lat1,lon1,scenario.map(n).data(:,1),scenario.map(n).data(:,2));
            Xmap = ( DE * cos(-tpsi1*pi/180) + DN * sin(-tpsi1*pi/180) )/1852;
            Ymap = ( DN * cos(-tpsi1*pi/180) - DE * sin(-tpsi1*pi/180) )/1852;
            Xmap = [Xmap(1) Xmap(2); Xmap(3) Xmap(4)];
            Ymap = [Ymap(1) Ymap(2); Ymap(3) Ymap(4)];
            set(handles.map(n),'XData',Xmap,'YData',Ymap);
        end
    end
    
    % Auxiliary shapes
    if show_aux && ~isempty(handles.aux)
        for n = 1:length(handles.aux)
            if ~isempty(scenario.aux(n).data)
                L = size(scenario.aux(n).data,2);
                if scenario.aux(n).style(1) == 'T'
                    Raux = 90 - scenario.aux(n).data(:,3) + psi1;
                    Raux(isnan(Raux)) = 0;
                    L = 2;
                else
                    Raux = 0*scenario.aux(n).data(:,1);
                end
                [DE, DN] = latlong2dxdy(lat1,lon1,scenario.aux(n).data(:,1:L/2),scenario.aux(n).data(:,L/2+1:L));
                Xaux = ( DE * cos(-tpsi1*pi/180) + DN * sin(-tpsi1*pi/180) )/1852;
                Yaux = ( DN * cos(-tpsi1*pi/180) - DE * sin(-tpsi1*pi/180) )/1852;
            else
                Xaux = [NaN; NaN];
                Yaux = [NaN; NaN];
                Raux = [0; 0];
            end
            set(handles.aux(n),'XData',Xaux,'YData',Yaux);
            for m = 1:length(handles.auxlbl{n})
                set(handles.auxlbl{n}(m),'Position',denanpos([Xaux(m) Yaux(m) 0]),'Rotation',Raux(m));
            end
        end
    end
    
    % Nav Aids
    if show_aid && ~isempty(handles.aid)
        [DE, DN] = latlong2dxdy(lat1,lon1,scenario.aid.data(:,1),scenario.aid.data(:,2));
        Xaid = ( DE * cos(-tpsi1*pi/180) + DN * sin(-tpsi1*pi/180) )/1852;
        Yaid = ( DN * cos(-tpsi1*pi/180) - DE * sin(-tpsi1*pi/180) )/1852;
        Raid = nan2zero(90-45 - scenario.aid.data(:,4) + psi1);
        for n = 1:length(Xaid)
            set(handles.aid(n),'Position',denanpos([Xaid(n) Yaid(n) 0]),'Rotation',Raid(n));
            set(handles.aidlbl(n),'Position',denanpos([Xaid(n) Yaid(n) 0]));
        end
    end
    
    % Waypoints
    if (show_wpt || show_rt) && ~isempty(handles.wpt)
        [DE, DN] = latlong2dxdy(lat1,lon1,scenario.wpt.data(:,2),scenario.wpt.data(:,3));
        Xwpt = ( DE * cos(-tpsi1*pi/180) + DN * sin(-tpsi1*pi/180) )/1852;
        Ywpt = ( DN * cos(-tpsi1*pi/180) - DE * sin(-tpsi1*pi/180) )/1852;
        if show_aid
            showwpt = getappdata(handles.window,'showwpt');
        else
            showwpt = ones(size(Xwpt));
        end
        set(handles.wpt,'XData',showwpt.*Xwpt,'YData',Ywpt,'ZData',0*Xwpt+1);
        for n = 1:length(Xwpt)
            if ~isnan(showwpt(n))
                set(handles.wptcodlbl(n),'Position',denanpos([Xwpt(n) Ywpt(n) 0]));
            else
                set(handles.wptcodlbl(n),'Position',[-10000 -10000 0]);
            end
            set(handles.wptnumlbl(n),'Position',denanpos([Xwpt(n) Ywpt(n) 0]));
        end
        
    end
    
    % FYT
    if ~isempty(nFYT)
        [DE, DN] = latlong2dxdy(lat1,lon1,scenario.wpt.data(nFYT,2),scenario.wpt.data(nFYT,3));
        Xfyt = ( DE * cos(-tpsi1*pi/180) + DN * sin(-tpsi1*pi/180) )/1852;
        Yfyt = ( DN * cos(-tpsi1*pi/180) - DE * sin(-tpsi1*pi/180) )/1852;
    else
        Xfyt = NaN;
        Yfyt = NaN;
    end
    set(handles.fyt,'XData',Xfyt,'YData',Yfyt,'ZData',1);
    if ~isempty(nFYT) && mode == 1
        P = atan2(DE,DN);
        Xfyt = handles.Xfyt * cos(P-tpsi1*pi/180) + handles.Yfyt * sin(P-tpsi1*pi/180);
        Yfyt = handles.Yfyt * cos(P-tpsi1*pi/180) - handles.Xfyt * sin(P-tpsi1*pi/180);
    else
        Xfyt = NaN;
        Yfyt = NaN;
    end
    set(handles.FYT,'XData',scale*Xfyt,'Ydata',scale*Yfyt,'ZData',2+0*Xfyt);
    
    % NAV
    if ~isempty(nNAV)
        [DE, DN] = latlong2dxdy(lat1,lon1,scenario.aid.data(nNAV,1),scenario.aid.data(nNAV,2));
        Xaid = ( DE * cos(-tpsi1*pi/180) + DN * sin(-tpsi1*pi/180) )/1852;
        Yaid = ( DN * cos(-tpsi1*pi/180) - DE * sin(-tpsi1*pi/180) )/1852;
    else
        Xaid = NaN;
        Yaid = NaN;
    end
    set(handles.nav,'XData',Xaid,'YData',Yaid,'ZData',1);
    
    % Route
    if show_rt && ~isempty(handles.wpt) && ~isempty(handles.rt)
        for n = 1:length(handles.rt)
            if isempty(handles.nrtwpt{n})
                set(handles.rt(n),'XData',NaN,'YData',NaN);
            else
                set(handles.rt(n),'XData',Xwpt(handles.nrtwpt{n}),'YData',Ywpt(handles.nrtwpt{n}));
            end
        end
    end
    
    % Flight Areas
    if show_fa && ~isempty(handles.fa)
        for n = 1:length(handles.fa)
            if ~isempty(scenario.fa(n).data)
                [DE, DN] = latlong2dxdy(lat1,lon1,scenario.fa(n).data(:,1),scenario.fa(n).data(:,2));
                Xfa = ( DE * cos(-tpsi1*pi/180) + DN * sin(-tpsi1*pi/180) )/1852;
                Yfa = ( DN * cos(-tpsi1*pi/180) - DE * sin(-tpsi1*pi/180) )/1852;
            else
                Xfa = [NaN; NaN];
                Yfa = [NaN; NaN];
            end
            set(handles.fa(n),'XData',Xfa,'YData',Yfa);
            set(handles.falbl(n),'Position',denanpos([nanmean(Xfa(1:end-1)) nanmean(Yfa(1:end-1)) 0]));
        end
    end
    
    % Avoid zones
    if show_avd && ~isempty(handles.avd)
        [DE, DN] = latlong2dxdy(lat1,lon1,scenario.avd.data(:,1),scenario.avd.data(:,2));
        for n = 1:length(handles.avd)
            Xavd = ( DE * cos(-tpsi1*pi/180) + DN * sin(-tpsi1*pi/180) )/1852;
            Yavd = ( DN * cos(-tpsi1*pi/180) - DE * sin(-tpsi1*pi/180) )/1852;
            set(handles.avd(n),'XData',Xavd(n)+scenario.avd.data(n,3)*cos(linspace(0,2*pi,36)),'YData',Yavd(n)+scenario.avd.data(n,3)*sin(linspace(0,2*pi,36)));
            set(handles.avdlbl(n),'Position',denanpos([Xavd(n) Yavd(n) 0]));
        end
    end
    
    % Threat areas
    if show_thr && ~isempty(handles.thr)
        [DE, DN] = latlong2dxdy(lat1,lon1,scenario.thr.data(:,1),scenario.thr.data(:,2));
        for n = 1:length(handles.thr)
            Rthr = interp1([-2000 scenario.thr.data(n,[3 4])],scenario.thr.data(n,[5 5 6]),Zp,'linear',NaN);
            Xthr = ( DE * cos(-tpsi1*pi/180) + DN * sin(-tpsi1*pi/180) )/1852;
            Ythr = ( DN * cos(-tpsi1*pi/180) - DE * sin(-tpsi1*pi/180) )/1852;
            set(handles.thr(n),'XData',Xthr(n)+Rthr*cos(linspace(0,2*pi,36)),'YData',Ythr(n)+Rthr*sin(linspace(0,2*pi,36)));
            set(handles.thrlbl(n),'Position',denanpos([Xthr(n) Ythr(n) 0]));
        end
    end
    
    % Contact line
    if show_cnt && ~isempty(handles.cnt)
        [DE, DN] = latlong2dxdy(lat1,lon1,scenario.cnt.data(:,1),scenario.cnt.data(:,2));
        Xcnt = ( DE * cos(-tpsi1*pi/180) + DN * sin(-tpsi1*pi/180) )/1852;
        Ycnt = ( DN * cos(-tpsi1*pi/180) - DE * sin(-tpsi1*pi/180) )/1852;
        set(handles.cnt,'XData',Xcnt,'YData',Ycnt);
    end
    
end

% Monitors
if G && (~H || ~T)
    for n = 1:length(handles.sellist)
        nsel = get(handles.sellist(n),'Value')-1;
        if nsel
            str = num2str(DADOS(N,nsel));
        else
            str = '';
        end
        set(handles.displist(n),'String',str,'TooltipString',str);
    end
    for n = 1:length(handles.sellist2)
        nsel = get(handles.sellist2(n),'Value')-1;
        if nsel
            str = num2str(DADOS(N,nsel));
        else
            str = '';
        end
        set(handles.sellist2(n),'TooltipString',str);
    end
end

set(handles.NoOBS,'String',num2str(N));
updateslider(hObject, eventdata, handles);

drawnow;

% ---------------------------------------------------------------
function updatescreen(hObject, eventdata, handles)
% Funçao de atualizaçao da disposiçao da tela

H  = get(handles.HUD_chk,'Value');
LT = get(handles.LTSD_chk,'Value');
G  = get(handles.grid_chk,'Value');
RT = get(handles.RTSD_chk,'Value');

HUDlist = [handles.HUD; get(handles.HUD,'Children'); handles.HUDctrl'];
ENGlist = [handles.ENG; get(handles.ENG,'Children')];
TSDlist = [handles.TSD; get(handles.TSD,'Children'); handles.TSDctrl'];

if G
    set([handles.back_frame; handles.gridlist1; handles.gridlist2; handles.vslider],'Visible','on');
else
    set([handles.back_frame; handles.gridlist1; handles.gridlist2; handles.vslider],'Visible','off');
end

if H
    set([HUDlist; ENGlist],'Visible','on');
else
    set([HUDlist; ENGlist],'Visible','off');
end

if LT || RT
    set(TSDlist,'Visible','on');
    updateNAV_Callback(hObject, eventdata, handles);
    decluter(hObject, eventdata, handles);
else
    set(TSDlist,'Visible','off');
end

window_ResizeFcn(hObject, eventdata, handles);
updateplot(hObject, eventdata, handles);

% --------------------------------------------------------------------
function updateslider(hObject, eventdata, handles, config)
% Atualiza a escala da barra de rolagem

if nargin == 3
    config = 0;
end

N = getappdata(handles.window,'N');
Q = getappdata(handles.window,'Q');
ax = get(handles.slideraxes,'XLim');

if config || N < ax(1) || N > ax(2)
    
    D = round(handles.Nobs/Q);
    
    switch Q
        
        case 2
            
            if N <= D
                XLim = [1 D];
                str1 = '0';
                str2 = '1/2';
            else
                XLim = [D+1 handles.Nobs];
                str1 = '1/2';
                str2 = '2/2';
            end
            
        case 4
            
            if      N <= D
                XLim = [1 D];
                str1 = '0';
                str2 = '1/4';
            elseif N <= 2*D
                XLim = [D+1 2*D];
                str1 = '1/4';
                str2 = '2/4';
            elseif N <= 3*D
                XLim = [2*D+1 3*D];
                str1 = '2/4';
                str2 = '3/4';
            else
                XLim = [3*D+1 handles.Nobs];
                str1 = '3/4';
                str2 = '4/4';
            end
            
        case 8
            
            if      N <= D
                XLim = [1 D];
                str1 = '0';
                str2 = '1/8';
            elseif N <= 2*D
                XLim = [D+1 2*D];
                str1 = '1/8';
                str2 = '2/8';
            elseif N <= 3*D
                XLim = [2*D+1 3*D];
                str1 = '2/8';
                str2 = '3/8';
            elseif N <= 4*D
                XLim = [3*D+1 4*D];
                str1 = '3/8';
                str2 = '4/8';
            elseif N <= 5*D
                XLim = [4*D+1 5*D];
                str1 = '4/8';
                str2 = '5/8';
            elseif N <= 6*D
                XLim = [5*D+1 6*D];
                str1 = '5/8';
                str2 = '6/8';
            elseif N <= 7*D
                XLim = [6*D+1 7*D];
                str1 = '6/8';
                str2 = '7/8';
            else
                XLim = [7*D+1 handles.Nobs];
                str1 = '7/8';
                str2 = '8/8';
            end
            
    end
    
    if Q > 1
        
        set(handles.slideraxes,'XLim',XLim);
        set(handles.N1_txt,'String',str1);
        set(handles.N2_txt,'String',str2);
        
    end
    
end

% ---------------------------------------------------------------
function updatecursor(hObject, eventdata, handles)
% Funçao de atualizaçao do cursor

if strcmp(get(handles.window,'Pointer'),'watch')
    return
end

cp = get(handles.window,'CurrentPoint') + [.5 .5];
ap = get(handles.TSD,'Position');
ax = get(handles.TSD,'XLim');
ay = get(handles.TSD,'YLim');

x = (cp(1)-ap(1))*(ax(2)-ax(1))/ap(3) + ax(1);
y = (cp(2)-ap(2))*(ay(2)-ay(1))/ap(4) + ay(1);

if x >= ax(1) && x <= ax(2) && y >= ay(1) && y <= ay(2);
    ng = 1;
else
    ng = 0;
end

% Tipo e posiçao do cursor
if ng && strcmp(get(handles.TSD,'Visible'),'on')
    
    if getappdata(handles.window,'mode') == 2 % FIX
        xr = (x-ax(1))/(ax(2)-ax(1));
        yr = (y-ay(1))/(ay(2)-ay(1));
        if     xr < .1 && yr > .9
            pointer = 'topl';
        elseif xr > .9 && yr > .9
            pointer = 'topr';
        elseif xr > .9 && yr < .1
            pointer = 'botr';
        elseif xr < .1 && yr < .1
            pointer = 'botl';
        elseif xr < .1
            pointer = 'left';
        elseif xr > .9
            pointer = 'right';
        elseif yr > .9
            pointer = 'top';
        elseif yr < .1
            pointer = 'bottom';
        else
            pointer = [];
        end
        if isempty(pointer)
            set(handles.window,'Pointer','custom','PointerShapeCData',handles.cur,'PointerShapeHotSpot',[8 8]);
        else
            set(handles.window,'Pointer',pointer);
        end
    else
        set(handles.window,'Pointer','custom','PointerShapeCData',handles.cur,'PointerShapeHotSpot',[8 8]);
    end
    
    acftdata = getappdata(handles.window,'acftdata');
    origin   = getappdata(handles.window,'origin');
    
    Dx   = acftdata(1);
    Dy   = acftdata(2);
    psi  = acftdata(3);
    psi1 = origin(3);
    
    brg = [num2str(mod(atan2(x-Dx,y-Dy)*180/pi+psi1,360),'%03.0f') 'º'];
    rng = num2str(sqrt((x-Dx)^2+(y-Dy)^2),'%3.1f');

    if isnan(brg)
        brg = ' ';
    end
    if isnan(rng)
        rng = ' ';
    end
    
else
    set(handles.window,'Pointer','arrow');
    brg = ' ';
    rng = ' ';
end

set(handles.cdb,'String',{brg,rng});

% ---------------------------------------------------------------
function updateUImenu(hObject, eventdata, handles)
% Funçao de atualizaçao dos menus do contexo (evita right-click menu lock)

cp = get(handles.window,'CurrentPoint') + [.5 .5];

% ENG
ap = get(handles.ENG,'Position');

if cp(1) >= ap(1) && cp(1) <= ap(1)+ap(3) && cp(2) >= ap(2) && cp(2) <= ap(2)+ap(4)
    set(handles.ENG,'UIContextMenu',handles.setengmaxmenu);
else
    set(handles.ENG,'UIContextMenu',[]);
end

% Slider
ap = get(handles.slideraxes,'Position');

if cp(1) >= ap(1) && cp(1) <= ap(1)+ap(3) && cp(2) >= ap(2) && cp(2) <= ap(2)+ap(4)
    set(handles.slideraxes,'UIContextMenu',handles.slidermenu);
else
    set(handles.slideraxes,'UIContextMenu',[]);
end

% ---------------------------------------------------------------
function updateball(hObject, eventdata, handles)
% Funçao de arrastamento da bola da barra de rolagem

cp = get(handles.window,'CurrentPoint') + [.5 .5];
ap = get(handles.slideraxes,'Position');
ax = get(handles.slideraxes,'XLim');

x = (cp(1)-ap(1))*(ax(2)-ax(1))/ap(3) + ax(1);

N = min(ax(2),max(ax(1),round(x)));
setappdata(handles.window,'N',N);
set(handles.sliderball,'XData',N);
updateplot(hObject, eventdata, handles);

% ---------------------------------------------------------------
function updateeventtip(hObject, eventdata, handles)
% Funçao de atualizaçao do nome do evento ou ponto de ensaio sob o cursor

if all(isnan(get(handles.eventpts,'XData'))) && all(isnan(get(handles.ptslines,'XData')))
    set(handles.eventtip,'String','','Position',[0 0 0],'UserData',NaN);
    return
end

evN  = getappdata(handles.window,'evN');
tpN1 = getappdata(handles.window,'tpN1');
tpN2 = getappdata(handles.window,'tpN2');

cp = get(handles.window,'CurrentPoint') + [.5 .5];
ap = get(handles.slideraxes,'Position');
ax = get(handles.slideraxes,'XLim');
ay = get(handles.slideraxes,'YLim');

x = (cp(1)-ap(1))*(ax(2)-ax(1))/ap(3) + ax(1);
y = (cp(2)-ap(2))*(ay(2)-ay(1))/ap(4) + ay(1);

if x >= ax(1) && x <= ax(2) && y >= .5 && y <= .6 % Evento
    
    ne = find(abs(x-evN) < 3*diff(ax)/ap(3));
    if ~isempty(ne)
        ne = ne(1);
        set(handles.eventtip,'String',[num2str(ne,'%02.0f') ' - ' time2str2(handles.evt(ne)) ' - ' handles.evd{ne}],'Position',[evN(ne) .8 0],'HorizontalAlignment','center','UserData',evN(ne));
    else
        set(handles.eventtip,'String','','Position',[0 0 0],'UserData',NaN);
    end
    ext_chk = 1;
    
elseif x >= ax(1) && x <= ax(2) && y >= 0.02 && y <= .1 % Ponto de ensaio
    
    nt = intersect(find(x>=tpN1),find(x<=tpN2));
    if ~isempty(nt)
        nt = nt(1);
        set(handles.eventtip,'String',handles.tpd{nt},'Position',[(tpN1(nt)+tpN2(nt))/2 .8 0],'HorizontalAlignment','center','UserData',tpN1(nt));
    else
        set(handles.eventtip,'String','','Position',[0 0 0],'UserData',NaN);
    end
    ext_chk = 1;
    
else
    set(handles.eventtip,'String','','Position',[0 0 0],'UserData',NaN);
    ext_chk = 0;
end

if ext_chk
    ext = get(handles.eventtip,'Extent');
    if ext(1)+ext(3) > ax(2);
        set(handles.eventtip,'Position',[ax(2) .8 0],'HorizontalAlignment','right');
    end
    ext = get(handles.eventtip,'Extent');
    if ext(1) < ax(1);
        set(handles.eventtip,'Position',[ax(1)+diff(ax)/ap(3) .8 0],'HorizontalAlignment','left');
    end
end

%--------------------------------------------------------------------------
function updateFYT_Callback(hObject, eventdata, handles)
% Atualiza a apresentaçao do FYT

FYT = get(handles.FYTlbl,'UserData');
scenario = getappdata(handles.window,'scenario');

if isempty(FYT) || isempty(scenario) || isempty(scenario.wpt) || isempty(scenario.wpt.data) || isempty(find(scenario.wpt.data(:,1)==FYT))
    FYT = [];
end

if ~isempty(FYT)
    str = num2str(FYT,'%02.0f');
else
    str = 'OFF';
end

set(handles.FYTlbl,'String',{'FYT',str},'UserData',FYT);

updateplot(hObject, eventdata, handles);

%--------------------------------------------------------------------------
function updateNAV_Callback(hObject, eventdata, handles)
% Atualiza a apresentaçao do nav aid selecionado

nNAV = get(handles.NAVlbl,'UserData');
scenario = getappdata(handles.window,'scenario');
CRS_group = [handles.CRSup_btn handles.CRSdn_btn handles.CRSup10_btn handles.CRSdn10_btn handles.CRSlbl];

if isempty(nNAV) ||  isempty(scenario) || isempty(scenario.aid) || isempty(scenario.aid.data) || nNAV < 1 || nNAV > size(scenario.aid.data,1)
    nNAV = [];
end

if ~isempty(nNAV)
    str = upper({strrep(scenario.aid.type{nNAV},'VOR/DME','V/D'), scenario.aid.code{nNAV}});
    switch scenario.aid.type{nNAV}
        case {'VOR','VOR/DME','ILS'}
            set(CRS_group,'Visible','on');
        otherwise
            set(CRS_group,'Visible','off');
    end
else
    str = {'NAV','OFF'};
    set(CRS_group,'Visible','off');
end

set(handles.NAVlbl,'String',str,'UserData',nNAV);

updateplot(hObject, eventdata, handles);

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
        
    case {abs('a'),abs('A')}
        load_btn_Callback(hObject, eventdata, handles);
        
    case {abs('s'),abs('S')}
        save_btn_Callback(hObject, eventdata, handles);
        
    case {abs('e'),abs('E')}
        edit_btn_Callback(hObject, eventdata, handles);
        
    case {abs('o'),abs('O')}
        set(handles.OpenGL_btn,'Value',~get(handles.OpenGL_btn,'Value'));
        OpenGL_btn_Callback(hObject, eventdata, handles);
        
    case {abs('h'),abs('H')}
        HUD_chk_Callback(hObject, eventdata, handles);
        
    case abs('T')
        LTSD_chk_Callback(hObject, eventdata, handles);
        
    case abs('t')
        RTSD_chk_Callback(hObject, eventdata, handles);
        
    case {abs('g'),abs('G')}
        grid_chk_Callback(hObject, eventdata, handles);
        
    case 13 % Enter
        ok_btn_Callback(hObject, eventdata, handles);
        
    case 27 % Esc
        window_CloseRequestFcn(hObject, eventdata, handles);
        
    case '*'
        
        if ~get(handles.play_btn,'Value')
            handles.acftn = handles.acftn + 1;
            if handles.acftn > length(handles.acftshapes); handles.acftn = 1; end
            acftpts = handles.acftshapes{handles.acftn};
            handles.acftpts = .06*[[acftpts 0*acftpts(:,1)]; flipud(acftpts(2:end-1,1)) flipud(-acftpts(2:end-1,2)) 0*acftpts(2:end-1,1)];
            guidata(hObject, handles);
            updateplot(hObject, eventdata, handles);
        end
end

% ---------------------------------------------------------------
function window_CloseRequestFcn(hObject, eventdata, handles)
% Funçao de fechamento da janela

set(handles.play_btn,'Value',0);
button = questdlg('Deseja descartar alterações e sair?','Confirmação','Sim','Não','Não');
if strcmp(button,'Sim')
    uiresume;            
end

% ---------------------------------------------------------------
function window_WindowButtonDownFcn(hObject, eventdata, handles)
% Funçao executada ao se pressionar o botao do mouse

cp = get(handles.window,'CurrentPoint') + [.5 .5];
screenlist = [handles.HUD handles.TSD];
ng = 0;

for n = 1:length(screenlist)
    
    if strcmp(get(screenlist(n),'Visible'),'on')
        
        ap = get(screenlist(n),'Position');
        ax = get(screenlist(n),'XLim');
        ay = get(screenlist(n),'YLim');
        
        x = (cp(1)-ap(1))*(ax(2)-ax(1))/ap(3) + ax(1);
        y = (cp(2)-ap(2))*(ay(2)-ay(1))/ap(4) + ay(1);
        
        if x >= ax(1) && x <= ax(2) && y >= ay(1) && y <= ay(2)
            ng = n;
            break
        end
        
    end
end

if ng == 1 % HUD
    set(handles.play_btn,'Value',~get(handles.play_btn,'Value'))
    play_btn_Callback(hObject, eventdata, handles);
    
elseif ng == 2 % TSD
    switch get(handles.window,'Pointer')
        case 'topl'
            dx = -.1*diff(ax);
            dy =  .1*diff(ay);
        case 'topr'
            dx =  .1*diff(ax);
            dy =  .1*diff(ay);
        case 'botr'
            dx =  .1*diff(ax);
            dy = -.1*diff(ay);
        case 'botl'
            dx = -.1*diff(ax);
            dy = -.1*diff(ay);
        case 'left'
            dx = -.1*diff(ax);
            dy =  0;
        case 'right'
            dx =  .1*diff(ax);
            dy =  0;
        case 'top'
            dx =  0;
            dy =  .1*diff(ay);
        case 'bottom'
            dx =  0;
            dy = -.1*diff(ay);
        otherwise
            switch get(handles.window,'SelectionType')
                case 'normal'
                    scaledn_btn_Callback(hObject, eventdata, handles);
                case 'alt'
                    scaleup_btn_Callback(hObject, eventdata, handles);
            end
            return
    end
    set(handles.TSD,'XLim',ax+dx,'YLim',ay+dy);
    updateplot(hObject, eventdata, handles);
end

%--------------------------------------------------------------------------
function window_WindowButtonUpFcn(hObject, eventdata, handles)
% Soltura do botao do mouse

set(handles.sliderline,'UserData',0);
set(handles.sliderball,'UserData',0);

% ---------------------------------------------------------------
function window_WindowButtonMotionFcn(hObject, eventdata, handles)
% Funçao executada ao se mover o mouse

if isempty(handles) || ~isfield(handles,'sliderball')
    return
end

if get(handles.sliderball,'UserData');
    updateball(hObject, eventdata, handles);
else
    updateUImenu(hObject, eventdata, handles);
    if ~get(handles.play_btn,'Value');
        updatecursor(hObject, eventdata, handles);
    end
    if ~isempty(handles.evt) || ~isempty(handles.tpt)
        updateeventtip(hObject, eventdata, handles);
    end
end

% --------------------------------------------------------------------
function window_ResizeFcn(hObject, eventdata, handles)
% Funçao de redimensionamento da janela

if isempty(handles) || ~isfield(handles,'sellist')
    return
end

% Limite minimo
ws = get(handles.window,'Position');
sw = 1000;
sh =  700;

if ws(3) < sw || ws(4) < sh
    set(handles.window,'Position',[ws(1) ws(2)+ws(4)-max(ws(4),sh) max(ws(3),sw) max(ws(4),sh)]);
end

ws = get(handles.window,'Position');

H  = get(handles.HUD_chk, 'Value');
LT = get(handles.LTSD_chk,'Value');
RT = get(handles.RTSD_chk,'Value');
G  = get(handles.grid_chk,'Value');

Dx = ws(3)/2-40;
Dy = ws(4)-67-20;

k = 460/613; % x/y

% TSD dimensions
if Dx/Dy < k
    Tw = Dx;
    Th = Tw/k;
else
    Th = Dy;
    Tw = Th*k;
end
Ty = 67+Dy/2-Th/2;
if LT
    Tx = 20+Dx/2-Tw/2;
else
    Tx = ws(3)-20-Dx/2-Tw/2;
end

% HUD & ENG dimensions
Hw = Tw;
Hh = Hw;
Ew = Tw;
Eh = 143/460*Ew;

Ex = Dx/2+20-Ew/2;
Ey = Ty;

Hx = Ex;
Hy = Ey+Eh+10;

% Grid dimensions
GH = 793;              % Altura total
Gh = min(GH,ws(4)-97); % Altura disponivel
Gw = 470;
Gx = ws(3)-20-Dx/2-240;
Gy = (ws(4)-97)/2+68-Gh/2;

% Displays
set(handles.HUD,'Position',[Hx Hy Hw Hh]);
set(handles.ENG,'Position',[Ex Ey Ew Eh]);
set(handles.TSD,'Position',[Tx Ty Tw Th]);

set(handles.HUD_chk ,'Position',[Dx/2+20-60 ws(4)-18 60 16]);
set(handles.LTSD_chk,'Position',[Dx/2+20+10 ws(4)-18 60 16]);
set(handles.grid_chk,'Position',[ws(3)/2+Dx/2+20-100 ws(4)-18 140 16]);
set(handles.RTSD_chk,'Position',[ws(3)/2+Dx/2+20+40  ws(4)-18  60 16]);

% HUD controls
set(handles.fovup_btn,'Position',[Hx-16 Hy+Hh-20 14 14])
set(handles.fovdn_btn,'Position',[Hx-16 Hy+Hh-34 14 14])

% TSD controls
nr = 4;

TSDctrl = handles.TSDctrl(1:nr);
dpos = zeros(length(TSDctrl),4);
dpos(1,:) = [0 0 14 14];
pos0 = get(TSDctrl(1),'Position').*[1 1 0 0];
for n = 2:length(TSDctrl)
    dpos(n,:) = get(TSDctrl(n),'Position')-pos0;
end
for n = 1:length(TSDctrl)
    set(TSDctrl(n),'Position',[Tx+Tw+2 Ty+Th-20 0 0]+dpos(n,:));
end

TSDctrl = handles.TSDctrl(nr+1:end);
dpos = zeros(length(TSDctrl),4);
dpos(1,:) = [0 0 14 14];
pos0 = get(TSDctrl(1),'Position').*[1 1 0 0];
for n = 2:length(TSDctrl)
    dpos(n,:) = get(TSDctrl(n),'Position')-pos0;
end
for n = 1:length(TSDctrl)
    set(TSDctrl(n),'Position',[Tx-16 Ty+Th-20 0 0]+dpos(n,:));
end

% Warnings
Wx = Ex+Ew+5;
set(handles.warn4_light,'Position',[Wx   Ty+20  20 18]);
set(handles.warn4      ,'Position',[Wx+3 Ty+23  16 14]);
set(handles.warn3_light,'Position',[Wx   Ty+48  20 18]);
set(handles.warn3      ,'Position',[Wx+3 Ty+51  16 14]);
set(handles.warn2_light,'Position',[Wx   Ty+76  20 18]);
set(handles.warn2      ,'Position',[Wx+3 Ty+79  16 14]);
set(handles.warn1_light,'Position',[Wx   Ty+104 20 18]);
set(handles.warn1      ,'Position',[Wx+3 Ty+107 16 14]);

if G
    % Grid Slider
    maxofst = GH-Gh;
    val = min(maxofst,get(handles.vslider,'Value'));
    ofst = maxofst-val;
    if get(handles.vslider,'UserData') == -1
        ofst = 0;
    end
    if ofst == 0
        set(handles.vslider,'UserData',-1);
    end
    if maxofst == 0
        set(handles.vslider,'Max',1,'Value',1,'SliderStep',[1 1],'Visible','off','UserData',-1);
    else
        set(handles.vslider,'Max',maxofst,'Value',maxofst-ofst,'SliderStep',[min(1,5/maxofst) min(1,20/maxofst)],'Visible','on');
    end
    
    % Grid
    dpos = zeros(length(handles.gridlist1),4);
    pos0 = get(handles.ref,'Position');
    for n = 1:length(handles.gridlist1)
        dpos(n,:) = get(handles.gridlist1(n),'Position')-[pos0(1) pos0(2)+pos0(4) 0 0];
    end
    for n = 1:length(handles.gridlist1)
        style = get(handles.gridlist1(n),'Style');
        py = Gy+Gh+ofst;
        if py+dpos(n,2)+dpos(n,4) < Gy+Gh-3 - strcmp(style,'text')*4 - strcmp(style,'edit')*1 - strcmp(style,'frame')*12 
            vis = 'on';
        else
            vis = 'off';
        end
        set(handles.gridlist1(n),'Position',[Gx py 0 0]+dpos(n,:),'Visible',vis);
    end
    
    dpos = zeros(length(handles.gridlist2),4);
    fpos = get(handles.others_frame,'Position');
    for n = 1:length(handles.gridlist2)
        dpos(n,:) = get(handles.gridlist2(n),'Position')-[fpos(1) fpos(2)+fpos(4) 0 0];
    end
    for n = 1:length(handles.gridlist2)
        py = Gy+Gh-GH+93+ofst;
        if py+dpos(n,2) > Gy+5 - strcmp(get(handles.gridlist2(n),'Style'),'text')*2
            vis = 'on';
        else
            vis = 'off';
        end
        set(handles.gridlist2(n),'Position',[Gx py 0 0]+dpos(n,:),'Visible',vis);
    end
    
    set(handles.back_frame,'Position',[Gx Gy Gw Gh]);
    set(handles.vslider,'Position',[Gx+Gw+1 Gy 14 Gh]);
end

% Control buttons
dpos = zeros(length(handles.ctrllist),4);
dpos(1,:) = [0 0 60 20];
pos0 = get(handles.ctrllist(1),'Position').*[1 1 0 0];
for n = 2:length(handles.ctrllist)
    dpos(n,:) = get(handles.ctrllist(n),'Position')-pos0;
end
for n = 1:length(handles.ctrllist)
    set(handles.ctrllist(n),'Position',[ws(3)-75 10 0 0]+dpos(n,:));
end

for n = 1:length(handles.hlbl)
    pos = get(handles.hlbl(n),'Position');
    y = 1 - (1-handles.ylbl(n)) * 613/Th;
    set(handles.hlbl(n),'Position',[pos(1) y pos(3)]);
end

set(handles.slideraxes,'Position',[20 10 ws(3)-465 50]);

% Tamanho das fontes do HUD
Htxt = findobj(handles.HUD,'Type','text');
set(Htxt,'FontSize',round(10/460*Hh));
set(handles.DLZrng,'FontSize',round(14/460*Hh));

%--------------------------------------------------------------------------
function sliderball_ButtonDownFcn(hObject, eventdata, handles)
% Clicar sobre a bola da barra de rolagem

set(handles.sliderball,'UserData',1);

%--------------------------------------------------------------------------
function slideraxes_ButtonDownFcn(hObject, eventdata, handles)
% Clicar no eixo de rolagem, eventos e pontos de ensaio

if ~strcmp(get(handles.window,'SelectionType'),'normal')
    return
end

cp = get(handles.slideraxes,'CurrentPoint');
N = round(getappdata(handles.window,'N'));
step = max(1,abs(handles.steps(get(handles.step_sel,'Value'))));
set(handles.sliderline,'UserData',1);

if cp(1,2) > .2 && cp(1,2) < .4  % Clicar sobre a barra de rolagem
    
    if cp(1,1) < N % Retroceder
        while get(handles.sliderline,'UserData');
            N = max(1,N-10*step);
            setappdata(handles.window,'N',N);
            set(handles.sliderball,'XData',N);
            updateplot(hObject, eventdata, handles);
        end
    elseif cp(1,1) > N % Avançar
        while get(handles.sliderline,'UserData');
            N = min(handles.Nobs,N+10*step);
            setappdata(handles.window,'N',N);
            set(handles.sliderball,'XData',N);
            updateplot(hObject, eventdata, handles);
        end
    end
    
else % Ir para evento ou ponto de ensaio
    
    N = get(handles.eventtip,'UserData');
    if ~isnan(N)
        set(handles.sliderball,'XData',N);
        setappdata(handles.window,'N',N);
        updateplot(hObject, eventdata, handles);
    end
    
end
    
% --------------------------------------------------------------------
function setengmaxmenu_Callback(hObject, eventdata, handles)
% Menu de definiçao dos valores maximos dos indicadores do motor

set(handles.play_btn,'Value',0);

% --------------------------------------------------------------------
function setengmax_Callback(hObject, eventdata, handles)
% Definiçao dos valores maximos dos indicadores do motor

x = [.8 1.7 2.6];
cp = get(handles.ENG,'CurrentPoint');
n = min(find(abs(cp(1)-x)==min(abs(cp(1)-x))));
str = {'RPM','TEMP','FF'};

out = inputvalues(['Indicador ' str{n}],{'Valor máximo:','Divisor:'},...
    {num2str(handles.engmax(1,n)),{'1','10','100','1000',find(handles.engmax(2,n)==[1 10 100 1000])} });

if isempty(out)
    return
end

vmax = str2double(out{1});
div  = out{2};

if isnan(vmax) || vmax <= 0
    beep; uiwait(errordlg('Valor incoerente.','Erro','modal'));
elseif rem(vmax,3) ~= 0
    beep; uiwait(errordlg('Valor máximo deve ser divisível por 12.','Erro','modal'));
else
    handles.engmax(:,n) = [vmax; 10^(div-1)];
    guidata(hObject, handles);
    
    if handles.engmax(2,n) == 1
        multstr = '';
    else
        multstr = ['×' num2str(handles.engmax(2,n))];
    end
    set(handles.engmult(n),  'String',multstr);
    set(handles.engtext(n,1),'String','0');
    set(handles.engtext(n,2),'String',num2str(1/3*handles.engmax(1,n)/handles.engmax(2,n)));
    set(handles.engtext(n,3),'String',num2str(2/3*handles.engmax(1,n)/handles.engmax(2,n)));
    set(handles.engtext(n,4),'String',num2str(5/6*handles.engmax(1,n)/handles.engmax(2,n)));
    
    updateplot(hObject, eventdata, handles);
end

% --------------------------------------------------------------------
function divide1_Callback(hObject, eventdata, handles)
% Nao dividir a barra de rolagem

set(handles.divide1,'Checked','on');
set([handles.divide2 handles.divide4 handles.divide8],'Checked','off');
set(handles.slideraxes,'XLim',[1 handles.Nobs]);
setappdata(handles.window,'Q',1);
set([handles.N1_txt handles.N2_txt],'String','');

% --------------------------------------------------------------------
function divide2_Callback(hObject, eventdata, handles)
% Dividir a barra de rolagem em 2 partes

set(handles.divide2,'Checked','on');
set([handles.divide1 handles.divide4 handles.divide8],'Checked','off');
setappdata(handles.window,'Q',2);
updateslider(hObject, eventdata, handles, 1);

% --------------------------------------------------------------------
function divide4_Callback(hObject, eventdata, handles)
% Dividir a barra de rolagem em 4 partes

set(handles.divide4,'Checked','on');
set([handles.divide1 handles.divide2 handles.divide8],'Checked','off');
setappdata(handles.window,'Q',4);
updateslider(hObject, eventdata, handles, 1);

% --------------------------------------------------------------------
function divide8_Callback(hObject, eventdata, handles)
% Dividir a barra de rolagem em 8 partes

set(handles.divide8,'Checked','on');
set([handles.divide1 handles.divide2 handles.divide4],'Checked','off');
setappdata(handles.window,'Q',8);
updateslider(hObject, eventdata, handles, 1);

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
function [setup, scenario] = getplaybackdata(handles)
% Obtem as estruturas de configuraçao e cenario

try
    PARAM = denumber(cellstr(get(handles.time_sel,'String')));
    for n = 1:length(handles.paramtags)
        setup.params.(handles.paramtags{n}) = PARAM{get(handles.([handles.paramtags{n} '_sel']),'Value')};
    end
    setup.engmax = handles.engmax;
    setup.acft = handles.acftlist{handles.acftn};
    setup.fov  = getappdata(handles.window,'fov');
    
    scenario = getappdata(handles.window,'scenario');
    scenario.Dmag = str2double(get(handles.Dmag_entry,'String'));
    for n = 1:length(scenario.aux)
        if strcmp(scenario.aux(n).type,'area')
            L = size(scenario.aux(n).data,2);
            [x, y] = patchnan(scenario.aux(n).data(:,L/2+1:end),scenario.aux(n).data(:,1:L/2));
            scenario.aux(n).data = [y x];
        end
    end
catch
    setup    = [];
    scenario = [];
end

% ---------------------------------------------------------------
function setplaybackdata(hObject, eventdata, handles, setup, scenario, showok)
% Configura os parametros e cria o cenario
% showok = 1: mostra mensagem de sucesso
% showok = 0: nao mostra mensagem de sucesso
% Mensagens de erro total ou sucesso parcial sempre sao mostradas

if nargin == 5;
    showok = 1;
end

% Flags
stp  = 0; % Setup loading
nf   = 0; % Param failure
nok  = 0; % Param loaded
scn  = 0; % Scenario loading
mf   = 0; % Map failures
cerr = 0; % Config error
serr = 0; % Scenario error

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
            warn_sel_Callback(hObject, eventdata, handles);
            stp = 1;
        end
        
        if ~isempty(setup.engmax)
            handles.engmax = setup.engmax;
            for n = 1:2
                if handles.engmax(2,n) == 1
                    multstr = '';
                else
                    multstr = ['x' num2str(handles.engmax(2,n))];
                end
                set(handles.engmult(n),  'String',multstr);
                set(handles.engtext(n,1),'String','0');
                set(handles.engtext(n,2),'String',num2str(1/3*handles.engmax(1,n)/handles.engmax(2,n)));
                set(handles.engtext(n,3),'String',num2str(2/3*handles.engmax(1,n)/handles.engmax(2,n)));
                set(handles.engtext(n,4),'String',num2str(5/6*handles.engmax(1,n)/handles.engmax(2,n)));
            end
        end
        
    catch
        set(handles.sellist,'Value',1);
        set(handles.sellist2,'Value',1);
        cerr = 1;
        stp = 0;
    end
end

if ~nok && ~nf
    stp = 0;
end

if ~isempty(scenario) % Carregar cenario
    
    if ~isfield(scenario,'date')
        d = clock;
        scenario.date = [num2str(d(3),'%02.0f') '/' num2str(d(2),'%02.0f') '/' num2str(d(1))];
    end
    if ~isfield(scenario,'Dmag'), scenario.Dmag = 0;  end
    if ~isfield(scenario,'map') , scenario.map  = []; end
    if ~isfield(scenario,'aux') , scenario.aux  = []; end
    if ~isfield(scenario,'aid') , scenario.aid  = []; end
    if ~isfield(scenario,'wpt') , scenario.wpt  = []; end
    if ~isfield(scenario,'fa')  , scenario.fa   = []; end
    if ~isfield(scenario,'rt')  , scenario.rt   = []; end
    if ~isfield(scenario,'avd') , scenario.avd  = []; end
    if ~isfield(scenario,'thr') , scenario.thr  = []; end
    if ~isfield(scenario,'cnt') , scenario.cnt  = []; end
    
    % Apagar todo o cenario atual
    if ~isempty(handles.map)
        delete(handles.map);
        handles.map = [];
    end
    if ~isempty(handles.aux)
        delete([handles.aux cell2mat(handles.auxlbl)]);
        handles.aux    = [];
        handles.auxlbl = {};
    end
    if ~isempty(handles.wpt)
        delete([handles.wpt handles.wptnumlbl handles.wptcodlbl handles.fyt]);
        handles.wpt = [];
        handles.wptnumlbl = [];
        handles.wptcodlbl = [];
        handles.fyt = [];
    end
    if ~isempty(handles.aid)
        delete([handles.aid handles.aidlbl handles.nav]);
        handles.aid    = [];
        handles.aidlbl = [];
        handles.nav    = [];
    end
    if ~isempty(handles.rt)
        delete(handles.rt);
        handles.rt = [];
    end
    if ~isempty(handles.fa)
        delete([handles.fa handles.falbl]);
        handles.fa = [];
        handles.falbl = [];
    end
    if ~isempty(handles.avd)
        delete([handles.avd handles.avdlbl]);
        handles.avd = [];
        handles.avdlbl = [];
    end
    if ~isempty(handles.thr)
        delete([handles.thr handles.thrlbl]);
        handles.thr = [];
        handles.thrlbl = [];
    end
    if ~isempty(handles.cnt)
        delete(handles.cnt);
        handles.cnt = [];
    end
    
    % Recriaçao do cenario
    try
        
        set(handles.Dmag_entry,'String',num2str(scenario.Dmag));
        
        axes(handles.TSD);
        set(handles.window,'Visible','off');
        set(handles.window,'Pointer','watch');

        % Map
        if ~isempty(scenario.map)
            load(which('DatMaps.mat'),'mapdb');
            exc = [];
            for n = 1:length(scenario.map)
                k = strmatch(scenario.map(n).name,mapdb.mapname,'exact');
                if isempty(k)
                    beep; uiwait(errordlg(['Mapa não encontrado: ' scenario.map(n).name],'Erro','modal'));
                    mapdata(1,1,1) = 0; mapdata(1,1,2) = 0; mapdata(1,1,3) = 0;
                    alpha = 1;
                    scenario.map(n).data = NaN*ones(4,2);
                    exc = [exc n];
                else
                    if isfield(mapdb,'mapalpha') && length(mapdb.mapalpha)>=k && ~isempty(mapdb.mapalpha{k})
                        alpha = double(mapdb.mapalpha{k});
                    else
                        alpha = 1;
                    end
                    mapname = ['map' num2str(k,'%05.0f')];
                    load(which('DatMaps.mat'),mapname);
                    eval(['mapdata = ' mapname ';']);
                    mapdata = flipud3(jpg2rgb(mapdata));
                    scenario.map(n).data = mapdb.mappos{k};
                end
                Xmap = scenario.map(n).data(:,2);
                Ymap = scenario.map(n).data(:,1);
                handles.map(n) = surface([Xmap(1) Xmap(2); Xmap(3) Xmap(4)],[Ymap(1) Ymap(2); Ymap(3) Ymap(4)],-1+[0 0; 0 0],...
                    mapdata,'FaceColor','texturemap','EdgeColor','none');
                if length(alpha) > 1
                    set(handles.map(n),'AlphaData',alpha,'FaceColor','texture','FaceAlpha','texturemap');
                end
            end
            if ~isempty(exc)
                scenario.map(exc) = [];
                delete(handles.map(exc));
                handles.map(exc) = [];
            end
            scn = 1;
        end
        
        % Auxiliary shapes
        handles.boguslbl = text(-10000,-10000,'');
        for n = 1:length(scenario.aux)
            auxtype  = scenario.aux(n).type;
            auxstyle = scenario.aux(n).style;
            auxcolor = scenario.aux(n).color;
            auxwidth = scenario.aux(n).width;
            switch auxtype
                case 'point'
                    handles.aux(n) = plot(NaN,NaN,auxstyle,'Color',auxcolor,'LineWidth',pix2width(auxwidth),'MarkerSize',8);
                    for m = 1:length(scenario.aux(n).code)
                        if ~isempty(deblank(scenario.aux(n).code{m}))
                            handles.auxlbl{n}(m) = text(-10000,-10000,{' ',' ',scenario.aux(n).code{m}},'HorizontalAlignment','center','Color',auxcolor,'Interpreter','none');
                        else
                            handles.auxlbl{n}(m) = handles.boguslbl;
                        end
                    end
                case 'line'
                    handles.aux(n) = plot(NaN,NaN,auxstyle,'Color',auxcolor,'LineWidth',pix2width(auxwidth));
                    handles.auxlbl{n} = [];
                case 'area'
                    if size(scenario.aux(n).data,2) == 2
                        [XC, YC] = patchplot(scenario.aux(n).data(:,2),scenario.aux(n).data(:,1));
                        scenario.aux(n).data = [YC XC];
                    end
                    handles.aux(n) = patchplot(NaN,NaN,auxcolor);
                    handles.auxlbl{n} = [];
                case 'text'
                    alnlist = {'left','center','right'};
                    handles.aux(n) = plot(NaN,NaN,'-k');
                    for m = 1:length(scenario.aux(n).code)
                        handles.auxlbl{n}(m) = text(-10000,-10000,scenario.aux(n).code{m},'HorizontalAlignment',alnlist{scenario.aux(n).data(m,4)+2},'Color',auxcolor,'Interpreter','TeX');
                    end
            end
            scn = 1;
        end

        % Flight areas
        for n = 1:length(scenario.fa)
            handles.fa(n) = plot(NaN,NaN,scenario.fa(n).style,'Color',scenario.fa(n).color);
            handles.falbl(n) = text(-10000,-10000,scenario.fa(n).code,'HorizontalAlignment','center','Color',scenario.fa(n).color,'Interpreter','none');
            scn = 1;
        end
        
        % Contact line
        if ~isempty(scenario.cnt) && ~isempty(scenario.cnt.data)
            handles.cnt = plot(NaN,NaN,'-r');
            scn = 1;
        end
        
        % Avoid zones
        if ~isempty(scenario.avd)
            for n = 1:size(scenario.avd.data,1)
                handles.avd(n) = plot(NaN,NaN,'--y');
                handles.avdlbl(n) = text(-10000,-10000,scenario.avd.code{n},'HorizontalAlignment','center','Color','y','Interpreter','none');
                scn = 1;
            end
        end
        
        % Threat areas
        if ~isempty(scenario.thr)
            for n = 1:size(scenario.thr.data,1)
                handles.thr(n) = plot(NaN,NaN,'--r');
                handles.thrlbl(n) = text(-10000,-10000,scenario.thr.code{n},'HorizontalAlignment','center','Color','r','Interpreter','none');
                scn = 1;
            end
        end

        % Routes
        for n = 1:length(scenario.rt)
            handles.rt(n) = plot(NaN,NaN,'-m');
            scn = 1;
        end
        
        % Nav Aids
        if ~isempty(scenario.aid) && ~isempty(scenario.aid.data)
            for n = 1:length(scenario.aid.code)
                [aidchar,aidfont,aidweight,aidsize,aidcolor] = navaidprop(scenario.aid.type{n});
                handles.aid(n)    = text(-10000,-10000,aidchar,'FontName',aidfont,'FontWeight',aidweight,'FontSize',aidsize,'Color',aidcolor,'HorizontalAlignment','center','Interpreter','TeX');
                handles.aidlbl(n) = text(-10000,-10000,{' ',' ',scenario.aid.code{n}},'HorizontalAlignment','center','Color',aidcolor,'Interpreter','none');
                scn = 1;
            end
            handles.nav = plot(NaN,NaN,'sb','Color',aidcolor,'MarkerSize',16);
        end

        % Waypoints
        if ~isempty(scenario.wpt) && ~isempty(scenario.wpt.data)
            handles.wpt = plot(NaN,NaN,'om','MarkerSize',8,'MarkerFaceColor','k');
            scn = 1;
            for n = 1:length(scenario.wpt.code)
                handles.wptnumlbl(n) = text(-10000,-10000,['   ' num2str(scenario.wpt.data(n,1),'%02.0f')],'HorizontalAlignment','left','Color','m','Interpreter','none');
                handles.wptcodlbl(n) = text(-10000,-10000,{' ',' ',scenario.wpt.code{n}},'HorizontalAlignment','center','Color','m','Interpreter','none');
            end
        end
        for n = 1:length(scenario.rt)
            rtwpt = scenario.rt(n).wpt;
            nrtwpt = [];
            for m = 1:length(rtwpt)
                nrtwpt = [nrtwpt find(rtwpt(m)==scenario.wpt.data(:,1))];
            end
            handles.nrtwpt{n} = nrtwpt;
        end
        handles.fyt = plot(NaN,NaN,'om','MarkerSize',14);
        
        % NavAids-Waypoint occlusion
        if ~isempty(scenario.wpt) && ~isempty(scenario.wpt.data)
            Xwpt = scenario.wpt.data(:,3);
            Ywpt = scenario.wpt.data(:,2);
            showwpt = ones(size(Xwpt));
            if ~isempty(scenario.aid) && ~isempty(scenario.aid.data)
                Xaid = scenario.aid.data(:,2);
                Yaid = scenario.aid.data(:,1);
                for n = 1:length(Xwpt)
                    if any(sqrt((Xwpt(n)-Xaid).^2+(Ywpt(n)-Yaid).^2)<1/6000)
                        showwpt(n) = NaN;
                    end
                end
            end
        else
            showwpt = [];
        end
        setappdata(handles.window,'showwpt',showwpt);
        
        % Armazenar cenario
        setappdata(handles.window,'scenario',scenario);
        
        set(setdiff(findobj(handles.TSD,'Type','line'),handles.aux),'LineWidth',1.5);
        set(setdiff(findobj(handles.TSD,'Type','text'),handles.aid),'FontWeight','demi','FontName','Arial');
        set(findobj(handles.TSD,'Type','text'),'Clipping','on');
        decluter(hObject, eventdata, handles);
        
    catch
        
        if ~isempty(handles.map)
            delete(handles.map);
            handles.map = [];
        end
        if ~isempty(handles.aux)
            delete([handles.aux cell2mat(handles.auxlbl)]);
            handles.aux    = [];
            handles.auxlbl = {};
        end
        if ~isempty(handles.wpt)
            delete([handles.wpt handles.wptnumlbl handles.wptcodlbl]);
            handles.wpt = [];
            handles.wptnumlbl = [];
            handles.wptcodlbl = [];
        end
        if ~isempty(handles.rt)
            delete(handles.rt);
            handles.rt = [];
        end
        if ~isempty(handles.fa)
            delete([handles.fa handles.falbl]);
            handles.fa = [];
            handles.falbl = [];
        end
        if ~isempty(handles.avd)
            delete([handles.avd handles.avdlbl]);
            handles.avd = [];
            handles.avdlbl = [];
        end
        if ~isempty(handles.thr)
            delete([handles.thr handles.thrlbl]);
            handles.thr = [];
            handles.thrlbl = [];
        end
        if ~isempty(handles.cnt)
            delete(handles.cnt);
            handles.cnt = [];
        end
        
        setappdata(handles.window,'scenario',[]);
        serr = 1;
        scn = 0;
    end
end

guidata(hObject, handles);
updateFYT_Callback(hObject, eventdata, handles);
updateNAV_Callback(hObject, eventdata, handles);

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

% Mensagens de erro
str = {};
if cerr
    str = [str, {' ','Erro ao carregar configuração.'}];
end
if serr
    str = [str, {' ','Erro ao carregar cenário.'}];
end
if cerr || serr
    beep; uiwait(errordlg(str,'Erro','modal')); drawnow;
end

% Mensagens de sucesso total ou parcial
str = {};

if stp % Config carregada
    if ~nok
        str = [str, {' ','Nenhum parâmetro de configuração encontrado.'}];
    elseif nf > 0
        str = [str, {' ','Configuração carregada parcialmente.',['Parâmetros não encontrados: ' num2str(nf)]}];
    else
        str = [str, {' ','Configuração carregada com sucesso.'}];
    end
end
if scn % Cenario carregado
    if mf
        str = [str, {' ','Cenário carregado parcialmente.',['Mapas não encontrados: ' num2str(mf)]}];
    else
        str = [str, {' ','Cenário carregado com sucesso.'}];
    end
end

if ~isempty(str)
    if (stp && (~nok || nf>0)) || (scn && mf)
        uiwait(warndlg(str,'Aviso','modal')); drawnow;
    elseif showok
        uiwait(okdlg(str,'Aviso','modal')); drawnow;
    end
end

set(handles.window,'Visible','on');

% TSD com fundo branco @@
% prop = {'Color','MarkerFaceColor','FaceColor','EdgeColor'};
% for n = 1:length(prop)
%     W = findobj(handles.TSD,prop{n},[1 1 1]);
%     K = findobj(handles.TSD,prop{n},[0 0 0]);
%     Y = findobj(handles.TSD,prop{n},[1 1 0]);
%     set(W,prop{n},'k');
%     set(K,prop{n},'w');
%     set(Y,prop{n},[.9 .9 0]);
% end
% handles.cur = nan*ones(16);
% handles.cur(:,[1 2 end-1 end]) = 1;
% guidata(hObject, handles);

%--------------------------------------------------------------------------
function setevents(hObject, eventdata, handles)
global DADOS DADOS2
% Cria as marcaçoes de eventos na barra de rolagem

n_time = get(handles.time_sel,'Value')-1;

if ~n_time || isempty(handles.evt) || isnan(DADOS(end,n_time)-DADOS(1,n_time)) || DADOS(end,n_time)-DADOS(1,n_time) < 1e-4
    set(handles.eventpts,'XData',NaN,'YData',NaN);
    set(handles.eventtip,'String','','Position',[0 0 0],'UserData',NaN);
    setappdata(handles.window,'evN',NaN*handles.evt);
    return
end

set(handles.window,'Pointer','watch');

T = DADOS(:,n_time);
for n = 1:length(handles.evt)
    if isnan(handles.evt(n)) || handles.evt(n) < min(T) || handles.evt(n) > max(T)
        evN(n) = NaN;
    else
        Dtime = abs(T-handles.evt(n));
        evn = find(Dtime==min(Dtime));
        evN(n) = evn(1);
        
        DADOS2(T>=handles.evt(n)&T<=handles.evt(n)+1,1) = n;
        DADOS2(min(find(T>handles.evt(n)))-1,1) = n;
    end
end

setappdata(handles.window,'evN',evN);

set(handles.eventpts,'XData',evN,'YData',.55*ones(size(evN)));

set(handles.window,'Pointer','arrow');

%--------------------------------------------------------------------------
function settestpts(hObject, eventdata, handles)
global DADOS DADOS2
% Cria as marcaçoes de pontos de ensaio na barra de rolagem

n_time = get(handles.time_sel,'Value')-1;

if ~n_time || isempty(handles.tpt) || isnan(DADOS(end,n_time)-DADOS(1,n_time)) || DADOS(end,n_time)-DADOS(1,n_time) < 1e-4
    set(handles.ptslines,'XData',NaN,'YData',NaN);
    set(handles.eventtip,'String','','Position',[0 0 0],'UserData',NaN);
    setappdata(handles.window,'tpN1',NaN*handles.tpt);
    setappdata(handles.window,'tpN2',NaN*handles.tpt);
    return
end

set(handles.window,'Pointer','watch');

dx    = 550; % pixels
mindx = 1;   % pixels
mindn = ceil(mindx*size(DADOS,1)/dx);

T = DADOS(:,n_time);
for n = 1:size(handles.tpt,2)
    if isnan(handles.tpt(1,n)) || isnan(handles.tpt(2,n)) || handles.tpt(1,n) < min(T) || handles.tpt(2,n) > max(T)
        tpN1(n) = NaN;
        tpN2(n) = NaN;
    else
        tpN = find(T >= handles.tpt(1,n));
        tpN1(n) = tpN(1);
        tpN = find(T <= handles.tpt(2,n));
        tpN2(n) = max(tpN(end),tpN1(n)+mindn);
        
        DADOS2(T>=handles.tpt(1,n)&T<=handles.tpt(2,n),2) = n;
    end
end

setappdata(handles.window,'tpN1',tpN1);
setappdata(handles.window,'tpN2',tpN2);

tpN = [];
for n = 1:length(tpN1)
    tpN = [tpN NaN tpN1(n) tpN2(n)];
end

set(handles.ptslines,'XData',tpN,'YData',.05*ones(size(tpN)));

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

%--------------------------------------------------------------------------
function warn_sel_Callback(hObject, eventdata, handles)
% Seleçao dos alarmes

PARAM = cellstr(get(handles.warn4_sel,'String'));
warn_sel = [handles.warn1_sel handles.warn2_sel handles.warn3_sel handles.warn4_sel];

for n = 1:4
    k = get(warn_sel(n),'Value');
    set(handles.warnlist(:,n),'TooltipString',denumber(PARAM{k}));
end

updateplot(hObject, eventdata, handles);

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
    set(handles.sliderball,'XData',N2);
    setappdata(handles.window,'N',N2);
else
    N2 = N;
end

set(handles.NoOBS,'String',num2str(N2));
updateplot(hObject, eventdata, handles);

% ---------------------------------------------------------------
function load_btn_Callback(hObject, eventdata, handles)
% Carrega configuraçao e/ou cenario

set(handles.play_btn,'Value',0);

[fname, fpath] = uigetfile({'*.mat','Arquivo mat (*.mat)'},'Carregar configuração e/ou cenário',handles.fpath);

if ~ischar(fname)
    return
end

try
    fdat = whos('-file',[fpath fname]);
    if ~isempty(strmatch('setup',{fdat.name}))
        load([fpath fname],'setup');
    end
    if ~isempty(strmatch('scenario',{fdat.name}))
        load([fpath fname],'scenario');
    end
catch
    beep; uiwait(errordlg('Arquivo inválido.','Erro','modal'));
    return
end

if ~exist('setup','var') && ~exist('scenario','var')
    beep; uiwait(errordlg(['''' fname ''' não é arquivo de configuração e/ou cenário.'],'Erro','modal'));
    return
end

if ~exist('setup','var')
    setup = [];
end
if ~exist('scenario','var')
    scenario = [];
end

if ~isempty(setup) && ~isempty(scenario)
    opt = RDAT_InputOption('Opção','O que deseja carregar:',{'Configuração de parâmetros','Cenário tático'},[1 1],220); drawnow;
elseif ~isempty(setup)
    button = questdlg({['Arquivo ''' fname ''' não possui cenário.'],...
            'Deseja carregar configuração de parâmetros?'},'Confirmação','Sim','Não','Não');
    if strcmp(button,'Sim')
        opt = [1 0];
    else
        return
    end
elseif ~isempty(scenario)
    button = questdlg({['Arquivo ''' fname ''' não possui configuração.'],...
        'Deseja carregar cenário tático?'},'Confirmação','Sim','Não','Não');
    if strcmp(button,'Sim')
        opt = [0 1];
    else
        return
    end
end

if ~any(opt)
    return
end

if ~opt(1)
    setup = [];
end
if ~opt(2)
    scenario = [];
end

handles.fname = fname;
handles.fpath = fpath;
guidata(hObject, handles);

% --- BACKWARD COMPATIBILITY ----
setup    = backcompat(setup,'setup');
scenario = backcompat(scenario,'scenario');
% -------------------------------

setplaybackdata(hObject, eventdata, handles, setup, scenario);
setevents(hObject, eventdata, handles);
settestpts(hObject, eventdata, handles);

% ---------------------------------------------------------------
function save_btn_Callback(hObject, eventdata, handles)
% Salva configuraçao e/ou cenario

set(handles.play_btn,'Value',0);

opt = RDAT_InputOption('Opção','O que deseja salvar:',{'Configuração de parâmetros','Cenário tático'},[1 1],220); drawnow;

if isempty(opt)
    return
end

if opt(1) && opt(2)
    str = 'Salvar configuração e cenário';
elseif opt(1)
    str = 'Salvar configuração';
elseif opt(2)
    str = 'Salvar cenário';
else
    return
end

[fname, fpath] = uiputfile({'*.mat','Arquivo mat (*.mat)'},str,[handles.fpath handles.fname]);
if ischar(fname)
    
    [setup, scenario] = getplaybackdata(handles);
    
    try
        if opt(1) && opt(2)
            save([fpath fname],'setup','scenario',saveopt);
        elseif opt(1)
            save([fpath fname],'setup',saveopt);
        elseif opt(2)
            save([fpath fname],'scenario',saveopt);
        end
    catch
        beep; uiwait(errordlg(lasterr,'Erro','modal')); drawnow;
        return
    end
    
    handles.fname = fname;
    handles.fpath = fpath;
    guidata(hObject, handles);
    
end

%--------------------------------------------------------------------------
function edit_btn_Callback(hObject, eventdata, handles)
% Abre o editor de cenario

set(handles.play_btn,'Value',0);

[setup, scenario] = getplaybackdata(handles);
scenario = RDAT_EditScenario(scenario);

if ~isempty(scenario)
    setplaybackdata(hObject, eventdata, handles, [], scenario);
end

%--------------------------------------------------------------------------
function OpenGL_btn_Callback(hObject, eventdata, handles)
% Alterna o renderizador da janela

if get(handles.OpenGL_btn,'Value')
    try
        set(handles.window,'Renderer','OpenGL');
    catch
        beep; uiwait(errordlg({'Não foi possível carregar OpenGL.','Será usado o modo normal.'},'Erro','modal'));
        set(handles.window,'Renderer','zbuffer');
        set(handles.OpenGL_btn,'Value',0);
    end
else
    set(handles.window,'Renderer','zbuffer');
end

% -------------------------------------------------------------------
function help_btn_Callback(hObject, eventdata, handles)
% Botao Ajuda

helpme('Ferramentas\reproduzirvoo');

% ---------------------------------------------------------------
function ok_btn_Callback(hObject, eventdata, handles)
% Botao OK

set(handles.play_btn,'Value',0);
button = questdlg('Deseja confirmar alterações e sair?','Confirmação','Sim','Não','Não');
if strcmp(button,'Sim')
    handles.ok = 1;
    guidata(hObject, handles);
    uiresume;            
end

% ---------------------------------------------------------------
function HUD_chk_Callback(hObject, eventdata, handles)
% Seleciona HUD&ENG na tela da esquerda

set(handles.HUD_chk,'Value',1);
set(handles.LTSD_chk,'Value',0);
updatescreen(hObject, eventdata, handles);

% ---------------------------------------------------------------
function LTSD_chk_Callback(hObject, eventdata, handles)
% Seleciona TSD na tela da esquerda

set(handles.LTSD_chk,'Value',1);
set(handles.HUD_chk,'Value',0);
set(handles.RTSD_chk,'Value',0);
set(handles.grid_chk,'Value',1);
updatescreen(hObject, eventdata, handles);

% ---------------------------------------------------------------
function grid_chk_Callback(hObject, eventdata, handles)
% Seleciona grade de parametros na tela da direita

set(handles.grid_chk,'Value',1);
set(handles.RTSD_chk,'Value',0);
updatescreen(hObject, eventdata, handles);

% ---------------------------------------------------------------
function RTSD_chk_Callback(hObject, eventdata, handles)
% Seleciona TSD na tela da direita

set(handles.grid_chk,'Value',0);
set(handles.RTSD_chk,'Value',1);
set(handles.HUD_chk,'Value',1);
set(handles.LTSD_chk,'Value',0);
updatescreen(hObject, eventdata, handles);

%--------------------------------------------------------------------------
function AG_chk_Callback(hObject, eventdata, handles)
% Seleciona simbologia ar-solo no piper

set(handles.AG_chk,'Value',1);
set(handles.AA_chk,'Value',0);
updateplot(hObject, eventdata, handles);

%--------------------------------------------------------------------------
function AA_chk_Callback(hObject, eventdata, handles)
% Seleciona simbologia ar-ar no piper

set(handles.AA_chk,'Value',1);
set(handles.AG_chk,'Value',0);
updateplot(hObject, eventdata, handles);

%--------------------------------------------------------------------------
function vslider_Callback(hObject, eventdata, handles)
% Slider da grade de parametros

val = get(handles.vslider,'Value');
maxofst = get(handles.vslider,'Max');

if val == maxofst
    set(handles.vslider,'UserData',-1);
else
    set(handles.vslider,'UserData',0);
end

window_ResizeFcn(hObject, eventdata, handles);

%--------------------------------------------------------------------------
function fovup_btn_Callback(hObject, eventdata, handles)
% Aumenta o campo de visão do HUD

set(handles.fovup_btn,'Value',0);
fov = getappdata(handles.window,'fov');

if fov < 30
    fov = fov+5;
    set(handles.HUD,'XLim',fov*[-1 1],'YLim',fov*[-1 1]-handles.bst);
    setappdata(handles.window,'fov',fov);
    fixhudsymbols(hObject, eventdata, handles, 1);
    updateplot(hObject, eventdata, handles);
end

%--------------------------------------------------------------------------
function fovdn_btn_Callback(hObject, eventdata, handles)
% Reduz o campo de visão do HUD

set(handles.fovdn_btn,'Value',0);
fov = getappdata(handles.window,'fov');

if fov > 10
    fov = fov-5;
    set(handles.HUD,'XLim',fov*[-1 1],'YLim',fov*[-1 1]-handles.bst);
    setappdata(handles.window,'fov',fov);
    fixhudsymbols(hObject, eventdata, handles, -1);
    updateplot(hObject, eventdata, handles);
end

%--------------------------------------------------------------------------
function fixhudsymbols(hObject, eventdata, handles, opr)
% Reajusta as coordenadas dos objetos fixos do HUD após alteração de FOV

fov = getappdata(handles.window,'fov');

if opr == 1
    k = fov/(fov-5);
else
    k = fov/(fov+5);
end

% Bst cross
x = get(handles.bstcross,'XData');
y = get(handles.bstcross,'YData');
set(handles.bstcross,'XData',k*x,'YData',k*y);

% Target angle-off box
set(handles.tdbang,'Position',[-.08*fov 0 0]);

% Objetos fixos
H = handles.hudfixedsymbols;
for n = 1:length(H)
    x = get(H(n),'XData');
    y = get(H(n),'YData')+handles.bst;
    set(H(n),'XData',k*x,'YData',k*y-handles.bst);
end

% Texto de posiçao fixa
H = handles.hudfixedtexts;
for n = 1:length(H)
    pos = get(H(n),'Position')+[0 handles.bst 0];
    set(H(n),'Position',[k*pos(1) k*pos(2)-handles.bst pos(3)]);
end

%--------------------------------------------------------------------------
function decluter(hObject, eventdata, handles)
% Alterna a exibiçao dos objetos

show_map = get(handles.map_chk ,'Value');
show_aux = get(handles.aux_chk ,'Value');
show_aid = get(handles.aid_chk ,'Value');
show_wpt = get(handles.wpt_chk ,'Value');
show_fa  = get(handles.fa_chk  ,'Value');
show_rt  = get(handles.rt_chk  ,'Value');
show_avd = get(handles.avd_chk ,'Value');
show_thr = get(handles.thr_chk ,'Value');
show_cnt = get(handles.cnt_chk ,'Value');
show_lbl = get(handles.lbl_chk ,'Value');
show_dl  = get(handles.dl_chk  ,'Value');

updateplot(hObject, eventdata, handles);

if ~isempty(handles.map)
    if show_map
        set(handles.map,'Visible','on');
        set(handles.wpt,'MarkerFaceColor','none');
    else
        set(handles.map,'Visible','off');
        set(handles.wpt,'MarkerFaceColor','k');
    end
end
if ~isempty(handles.aux)
    if show_aux
        set([handles.aux cell2mat(handles.auxlbl)],'Visible','on');
    else
        set([handles.aux cell2mat(handles.auxlbl)],'Visible','off');
    end
end
if ~isempty(handles.aid)
    if show_aid
        set([handles.aid handles.aidlbl],'Visible','on');
    else
        set([handles.aid handles.aidlbl],'Visible','off');
    end
end
if ~isempty(handles.wpt)
    if show_wpt
        set([handles.wpt handles.wptnumlbl handles.wptcodlbl],'Visible','on');
    else
        set([handles.wpt handles.wptnumlbl handles.wptcodlbl],'Visible','off');
    end
end
if ~isempty(handles.fa)
    if show_fa
        set([handles.fa handles.falbl],'Visible','on');
    else
        set([handles.fa handles.falbl],'Visible','off');
    end
end
if ~isempty(handles.rt)
    if show_rt
        set(handles.rt,'Visible','on');
    else
        set(handles.rt,'Visible','off');
    end
end
if ~isempty(handles.avd)
    if show_avd
        set([handles.avd handles.avdlbl],'Visible','on');
    else
        set([handles.avd handles.avdlbl],'Visible','off');
    end
end
if ~isempty(handles.thr)
    if show_thr
        set([handles.thr handles.thrlbl],'Visible','on');
    else
        set([handles.thr handles.thrlbl],'Visible','off');
    end
end
if ~isempty(handles.cnt)
    if show_cnt
        set(handles.cnt,'Visible','on');
    else
        set(handles.cnt,'Visible','off');
    end
end
if show_lbl
    vislist = [];
    if show_aux
        vislist = [vislist cell2mat(handles.auxlbl)];
    end
    if show_aid
        vislist = [vislist handles.aidlbl];
    end
    if show_wpt
        vislist = [vislist handles.wptcodlbl];
    end
    if show_fa
        vislist = [vislist handles.falbl];
    end
    if show_avd
        vislist = [vislist handles.avdlbl];
    end
    if show_thr
        vislist = [vislist handles.thrlbl];
    end
    if ~isempty(vislist)
        set(vislist,'Visible','on');
    end
else
    lbllist = [cell2mat(handles.auxlbl) handles.aidlbl handles.wptcodlbl handles.falbl handles.avdlbl handles.thrlbl];
    if ~isempty(lbllist)
        set(lbllist,'Visible','off');
    end
end
if show_dl
    set([handles.acft2 handles.acft2alt handles.acft2db handles.trail2],'Visible','on');
    set([handles.acft3 handles.acft3alt handles.acft3db handles.trail3],'Visible','on');
    set([handles.acft4 handles.acft4alt handles.acft4db handles.trail4],'Visible','on');
else
    set([handles.acft2 handles.acft2alt handles.acft2db handles.trail2],'Visible','off');
    set([handles.acft3 handles.acft3alt handles.acft3db handles.trail3],'Visible','off');
    set([handles.acft4 handles.acft4alt handles.acft4db handles.trail4],'Visible','off');
end

% ---------------------------------------------------------------
function scaleup_btn_Callback(hObject, eventdata, handles)
% Aumentar escala do TSD

mode = getappdata(handles.window,'mode');

set(handles.scaleup_btn,'Value',0);
scale = str2double(get(handles.scale,'String'));
n = find(scale == handles.scalelist);
if n < length(handles.scalelist)
    scale = handles.scalelist(n+1);
    set(handles.scale,'String',num2str(scale));
    switch mode
        case 1 % DYN
            set(handles.TSD,'XLim',6/8*scale*[-.5 .5],'YLim',scale*[-1/3 2/3]);
        case 2 % FIX
            cx = mean(get(handles.TSD,'XLim'));
            cy = min(get(handles.TSD,'YLim'))+1/3*diff(get(handles.TSD,'YLim'));
            set(handles.TSD,'XLim',6/8*scale*[-.5 .5]+cx,'YLim',scale*[-1/3 2/3]+cy);
        case 3 % CTR
            set(handles.TSD,'XLim',6/8*scale*[-.5 .5],'YLim',scale*[-.5 .5]);
    end
end
updateplot(hObject, eventdata, handles);

% ---------------------------------------------------------------
function scaledn_btn_Callback(hObject, eventdata, handles)
% Reduzir escala do TSD

mode = getappdata(handles.window,'mode');

set(handles.scaledn_btn,'Value',0);
scale = str2double(get(handles.scale,'String'));
n = find(scale == handles.scalelist);
if n > 1
    scale = handles.scalelist(n-1);
    set(handles.scale,'String',num2str(scale));
    switch mode
        case 1 % DYN
            set(handles.TSD,'XLim',6/8*scale*[-.5 .5],'YLim',scale*[-1/3 2/3]);
        case 2 % FIX
            cx = mean(get(handles.TSD,'XLim'));
            cy = min(get(handles.TSD,'YLim'))+1/3*diff(get(handles.TSD,'YLim'));
            set(handles.TSD,'XLim',6/8*scale*[-.5 .5]+cx,'YLim',scale*[-1/3 2/3]+cy);
        case 3 % CTR
            set(handles.TSD,'XLim',6/8*scale*[-.5 .5],'YLim',scale*[-.5 .5]);
    end
end
updateplot(hObject, eventdata, handles);

%--------------------------------------------------------------------------
function mode_btn_Callback(hObject, eventdata, handles)
% Alterna o modo entre dinamico (cenario se move ao redor da aeronave)
% e fixo (aeronave se move pelo cenario)

% Modos: 1:   Dinamico
%        1.5: Fixo armado
%        2:   Fixo
%        3:   Centralizado

mode = getappdata(handles.window,'mode');
scale = str2double(get(handles.scale,'String'));

switch mode
    case 1
        mode = 1.5;
        set(handles.mode,'String','FIX');
    case 2
        mode = 3;
        set(handles.mode,'String','CTR');
        set(handles.TSD,'XLim',6/8*scale*[-.5 .5],'YLim',scale*[-.5 .5]);
    case 3
        mode = 1;
        set(handles.mode,'String','DYN');
        scale = str2double(get(handles.scale,'String'));
        set(handles.TSD,'XLim',6/8*scale*[-.5 .5],'YLim',scale*[-1/3 2/3]);
end

setappdata(handles.window,'mode',mode);
set(handles.mode_btn,'Value',0);
updateplot(hObject, eventdata, handles);

%--------------------------------------------------------------------------
function trailup_btn_Callback(hObject, eventdata, handles, btnpress)
% Aumenta o tamanho do rastro da aeronave

if nargin == 3
    btnpress = 1;
end

set(handles.trailup_btn,'Value',0);

ttrail = getappdata(handles.window,'ttrail');

if btnpress
    n = find(ttrail == handles.trails);
    if n == length(handles.trails)
        beep;
        return
    else
        n = n+1;
    end
    
    ttrail = handles.trails(n);
    setappdata(handles.window,'ttrail',ttrail);
end

if ttrail == 0
    trailstr = '0';
elseif ttrail <= 60
    trailstr = [num2str(ttrail) ''''''];
else
    trailstr = [num2str(ttrail/60) ''''];
end
set(handles.trailstr,'String',{'TRL' trailstr});

if btnpress
    updateplot(hObject, eventdata, handles);
end

%--------------------------------------------------------------------------
function traildn_btn_Callback(hObject, eventdata, handles)
% Diminui o tamanho do rastro da aeronave

if nargin == 3
    btnpress = 1;
end

set(handles.traildn_btn,'Value',0);

ttrail = getappdata(handles.window,'ttrail');

if btnpress
    n = find(ttrail == handles.trails);
    if n == 1
        beep;
        return
    else
        n = n-1;
    end
    
    ttrail = handles.trails(n);
    setappdata(handles.window,'ttrail',ttrail);
end

if ttrail == 0
    trailstr = '0';
elseif ttrail <= 60
    trailstr = [num2str(ttrail) ''''''];
else
    trailstr = [num2str(ttrail/60) ''''];
end
set(handles.trailstr,'String',{'TRL' trailstr});

if btnpress
    updateplot(hObject, eventdata, handles);
end

%--------------------------------------------------------------------------
function FYTup_btn_Callback(hObject, eventdata, handles)
% Seleciona o proximo waypoint como FYT

set(handles.FYTup_btn,'Value',0);
scenario = getappdata(handles.window,'scenario');

if isempty(scenario) || isempty(scenario.wpt) || isempty(scenario.wpt.data)
    return
end

wptnum = scenario.wpt.data(:,1);
FYT = get(handles.FYTlbl,'UserData');

if isempty(FYT)
    FYT = wptnum(1);
else
    n = find(wptnum==FYT);
    if n < length(wptnum)
        FYT = wptnum(n+1);
    else
        FYT = [];
    end
end

set(handles.FYTlbl,'UserData',FYT);
updateFYT_Callback(hObject, eventdata, handles);

%--------------------------------------------------------------------------
function FYTdn_btn_Callback(hObject, eventdata, handles)
% Seleciona o waypoint anterior como FYT

set(handles.FYTdn_btn,'Value',0);
scenario = getappdata(handles.window,'scenario');

if isempty(scenario) || isempty(scenario.wpt) || isempty(scenario.wpt.data)
    return
end

wptnum = scenario.wpt.data(:,1);
FYT = get(handles.FYTlbl,'UserData');

if isempty(FYT)
    FYT = wptnum(end);
else
    n = find(wptnum==FYT);
    if n > 1
        FYT = wptnum(n-1);
    else
        FYT = [];
    end
end

set(handles.FYTlbl,'UserData',FYT);
updateFYT_Callback(hObject, eventdata, handles);

%--------------------------------------------------------------------------
function NAVup_btn_Callback(hObject, eventdata, handles)
% Seleciona o proximo auxilio como NAV

set(handles.NAVup_btn,'Value',0);
scenario = getappdata(handles.window,'scenario');

if isempty(scenario) || isempty(scenario.aid) || isempty(scenario.aid.data)
    return
end

NAV = get(handles.NAVlbl,'UserData');

if isempty(NAV)
    NAV = 1;
else
    if NAV < size(scenario.aid.data,1)
        NAV = NAV + 1;
    else
        NAV = [];
    end
end

set(handles.NAVlbl,'UserData',NAV);
updateNAV_Callback(hObject, eventdata, handles);

%--------------------------------------------------------------------------
function NAVdn_btn_Callback(hObject, eventdata, handles)
% Seleciona o auxilio anterior como NAV

set(handles.NAVdn_btn,'Value',0);
scenario = getappdata(handles.window,'scenario');

if isempty(scenario) || isempty(scenario.aid) || isempty(scenario.aid.data)
    return
end

NAV = get(handles.NAVlbl,'UserData');

if isempty(NAV)
    NAV = size(scenario.aid.data,1);
else
    if NAV > 1
        NAV = NAV - 1;
    else
        NAV = [];
    end
end

set(handles.NAVlbl,'UserData',NAV);
updateNAV_Callback(hObject, eventdata, handles);

%--------------------------------------------------------------------------
function CRSup_btn_Callback(hObject, eventdata, handles)
% Aumenta o curso selecionado em 1°

set(handles.CRSup_btn,'Value',0);
CRS = mod(get(handles.CRSlbl,'UserData')+1,360);
set(handles.CRSlbl,'String',{'CRS',num2str(CRS,'%03.0f')},'UserData',CRS);
updateplot(hObject, eventdata, handles);

%--------------------------------------------------------------------------
function CRSdn_btn_Callback(hObject, eventdata, handles)
% Diminui o curso selecionado em 1°

set(handles.CRSdn_btn,'Value',0);
CRS = mod(get(handles.CRSlbl,'UserData')-1,360);
set(handles.CRSlbl,'String',{'CRS',num2str(CRS,'%03.0f')},'UserData',CRS);
updateplot(hObject, eventdata, handles);

%--------------------------------------------------------------------------
function CRSup10_btn_Callback(hObject, eventdata, handles)
% Aumenta o curso selecionado em 10°

set(handles.CRSup10_btn,'Value',0);
CRS = mod(get(handles.CRSlbl,'UserData')+10,360);
set(handles.CRSlbl,'String',{'CRS',num2str(CRS,'%03.0f')},'UserData',CRS);
updateplot(hObject, eventdata, handles);

%--------------------------------------------------------------------------
function CRSdn10_btn_Callback(hObject, eventdata, handles)
% Diminui o curso selecionado em 10°

set(handles.CRSdn10_btn,'Value',0);
CRS = mod(get(handles.CRSlbl,'UserData')-10,360);
set(handles.CRSlbl,'String',{'CRS',num2str(CRS,'%03.0f')},'UserData',CRS);
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
