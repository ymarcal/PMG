function varargout = klegkacalc(varargin)
% Last Modified by GUIDE v2.5 03-May-2011 17:34:47

gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @klegkacalc_OpeningFcn, ...
                   'gui_OutputFcn',  @klegkacalc_OutputFcn, ...
                   'gui_LayoutFcn',  @klegkacalc_LayoutFcn, ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

% ---------------------------------------------------------------
function h = klegkacalc_LayoutFcn(varargin)
% Função de layout inicial

h = openfig('klegkacalc.fig','reuse','visible');

% ---------------------------------------------------------------
function klegkacalc_OpeningFcn(hObject, eventdata, handles, varargin)
% Funçao de inicializaçao

ss = get(0,'ScreenSize');
fs = get(handles.window,'Position');

set(handles.window,'Position',[(ss(3)-fs(3))/2 (ss(4)-fs(4))/2 fs(3:4)]);
handles.axeslist = [handles.axes1 handles.axes2];
setappdata(handles.window,'moved',0);
setappdata(handles.window,'fixcur',0);

if exist('geticon.m','file')
    bgc = getbuttoncolor(handles.window);
    set(handles.help_btn,'CData',geticon('DatButtons.mat','help',bgc));
else
    bgc = get(handles.window,'Color');
    set(handles.help_btn,'Visible','off');
end

if ~exist('inputvalues.m','file')
    set(handles.axes2,'UIContextMenu',[]);
end

handles.controls = findobj(handles.window,'UserData',1);
for n = 1:length(handles.controls)
    pos = get(handles.controls(n),'Position');
    handles.Xcontrols(n) = pos(1)-450;
    handles.Ycontrols(n) = pos(2);
end

handles.R = 287.053;
handles.dT = 273.15;
handles.Ta0 = 15;
handles.gama = 1.4;
handles.g = 9.80665/.3048; % ft/s²
handles.kt2fps = 1852/3600/.3048;

handles.V_lim = [40 600];
handles.Z_lim = [0 50000];
handles.DISA_lim = [-30 30];
handles.dMach = .2;
handles.Nzmax = 12;
handles.Mmax  = 2;

handles.VZ_lim = [0 ceil(qc2vc(m2qcpa(handles.Mmax)*zp2pa(-2000))) -2000 100000];

Mmax = qcpa2m(vc2qc(handles.V_lim(2)),zp2pa(handles.Z_lim(2)));
Wmax = 20;

handles.Zp    = 0;
handles.Vc    = handles.V_lim(1);
handles.M     = qcpa2m(vc2qc(handles.Vc),zp2pa(handles.Zp));
handles.DISA  = 0;
handles.TaISA = handles.Ta0;
handles.Ta    = handles.Ta0;
handles.a     = sqrt(handles.gama*handles.R*(handles.Ta0+handles.dT))/(1852/3600);
handles.Va    = handles.a*handles.M;
handles.Ve    = 0;
handles.sigma = 1;
handles.phi   = 0;
handles.Nza   = 1;
handles.W     = 0;
handles.Rad   = Inf;

axes(handles.axes2);
xlabel('Vc, Va (kt)');
ylabel('Zp (ft)');
for Mi = handles.dMach:handles.dMach:Mmax
    Zpi = linspace(handles.Z_lim(1),handles.Z_lim(2),50);
    Vci = qc2vc(m2qcpa(Mi).*zp2pa(Zpi));
    plot(Vci,Zpi,'-k','HitTest','off','Tag','aux');
    text(max(Vci),handles.Z_lim(1),num2str(Mi,'%0.1f'),'Clipping','on','FontSize',8,'HorizontalAlignment','center','VerticalAlignment','bottom','HitTest','off','Tag','aux');
end
axis([handles.V_lim handles.Z_lim]);
handles.p_VcZp  = plot(handles.Vc,handles.Zp ,'bo','MarkerFaceColor','b','MarkerSize',5,'Clipping','off');
handles.p_VaZp  = plot(handles.Va,handles.Zp ,'gd','MarkerEdgeColor',[0 .8 0],'MarkerFaceColor',[0 .8 0],'MarkerSize',5,'Clipping','off');

set(handles.slider1,'Min',1,'Max',handles.Nzmax,'Value',handles.Nza,'SliderStep',[.02 .5]/(handles.Nzmax-1));
set(handles.slider2,'Min',handles.DISA_lim(1),'Max',handles.DISA_lim(2),'Value',handles.DISA,'SliderStep',[.2 5]/diff(handles.DISA_lim));

setappdata(handles.window,'dragdata',0);

axes(handles.axes1)
handles.h_Nza = text(1.08,.5,'Nza','Units','normalized','HorizontalAlignment','center','Rotation',90);
title({'Raio de Curva (m)',' '});
xlabel('Mach');
ylabel('Razão de Curva (°/s)');

handles.p_MW = plot(handles.M,handles.W ,'bs','MarkerFaceColor','b','MarkerSize',5,'Clipping','off');

guidata(hObject, handles);

updateklegka(hObject, eventdata, handles);
updatefields(hObject, eventdata, handles);

% ---------------------------------------------------------------
function varargout = klegkacalc_OutputFcn(hObject, eventdata, handles)
% Funçao de fechamento

varargout{1} = [];

% ---------------------------------------------------------------
% -- CALLBACK FUNCTIONS -----------------------------------------
% ---------------------------------------------------------------

function slider1_Callback(hObject, eventdata, handles)
% Slider do phi

handles.Nza = get(handles.slider1,'Value');
handles.phi = acos(1/handles.Nza)*180/pi;
handles.W = 180/pi*(handles.g/(handles.Va*handles.kt2fps))*sqrt(handles.Nza.^2-1);
if handles.W
    handles.Rad = (handles.Va*handles.kt2fps) / (handles.W*pi/180);
else
    handles.Rad = Inf;
end

if handles.Rad < 100/.3048
    handles.Rad = 100/.3048;
    handles.W   = 180/pi * (handles.Va*handles.kt2fps) / handles.Rad;
    handles.Nza = sqrt((handles.W / (180/pi*(handles.g/(handles.Va*handles.kt2fps))))^2 + 1);
    handles.phi = acos(1/handles.Nza)*180/pi;
end

guidata(hObject, handles);

set(handles.slider1,'Value',handles.Nza);
updateklegka(hObject, eventdata, handles);
updatefields(hObject, eventdata, handles);

% ---------------------------------------------------------------
function slider2_Callback(hObject, eventdata, handles)
% Slider do DISA

handles.DISA = get(handles.slider2,'Value');

handles.Ta  = handles.TaISA+handles.DISA;
handles.a   = sqrt(handles.gama*handles.R*(handles.Ta+handles.dT))/(1852/3600);
handles.Va  = handles.a*handles.M;
handles.W = 180/pi*(handles.g/(handles.Va*handles.kt2fps))*sqrt(handles.Nza.^2-1);
if handles.W
    handles.Rad = (handles.Va*handles.kt2fps) / (handles.W*pi/180);
else
    handles.Rad = Inf;
end

if handles.Rad < 100/.3048
    handles.Rad = 100/.3048;
    handles.W   = 180/pi * (handles.Va*handles.kt2fps) / handles.Rad;
    handles.Nza = sqrt((handles.W / (180/pi*(handles.g/(handles.Va*handles.kt2fps))))^2 + 1);
    handles.phi = acos(1/handles.Nza)*180/pi;
end

guidata(hObject, handles);

updateklegka(hObject, eventdata, handles);
updatefields(hObject, eventdata, handles);

% ---------------------------------------------------------------
function e_Zp_Callback(hObject, eventdata, handles)
% Entrada manual de Zp

Zp = str2double(get(handles.e_Zp,'String'));
if ~isnan(Zp)
    Zpmax = pa2zp(vc2qc(handles.Vc)/m2qcpa(handles.Mmax));
    handles.Zp = max(handles.VZ_lim(3), min(min(Zpmax,handles.VZ_lim(4)),Zp));
    guidata(hObject, handles);
    dragdata = [2 0 0 0 handles.Vc handles.Zp 1];
    window_WindowButtonMotionFcn(hObject, eventdata, handles, dragdata);
    handles = guidata(hObject);
    updateklegka(hObject, eventdata, handles);
else
    updatefields(hObject, eventdata, handles);
end

% ---------------------------------------------------------------
function e_Vc_Callback(hObject, eventdata, handles)
% Entrada manual de Vc

Vc = str2double(get(handles.e_Vc,'String'));
if ~isnan(Vc)
    Vcmax = qc2vc(m2qcpa(handles.Mmax)*zp2pa(handles.Zp));
    handles.Vc = max( handles.VZ_lim(1) , min( min( Vcmax , handles.VZ_lim(2)) , Vc));
    guidata(hObject, handles);
    dragdata = [2 0 0 0 handles.Vc handles.Zp 1];
    window_WindowButtonMotionFcn(hObject, eventdata, handles, dragdata);
    handles = guidata(hObject);
    updateklegka(hObject, eventdata, handles);
else
    updatefields(hObject, eventdata, handles);
end

% ---------------------------------------------------------------
function e_M_Callback(hObject, eventdata, handles)
% Entrada manual de M

M = str2double(get(handles.e_M,'String'));
if ~isnan(M)
    handles.M = max(qcpa2m(vc2qc(handles.V_lim(1)),zp2pa(handles.Zp)),min(handles.Mmax,M));
    guidata(hObject, handles);
    dragdata = [1 0 0 0 handles.M handles.W 1];
    window_WindowButtonMotionFcn(hObject, eventdata, handles, dragdata);
    handles = guidata(hObject);
    updateklegka(hObject, eventdata, handles);
else
    updatefields(hObject, eventdata, handles);
end

% ---------------------------------------------------------------
function e_phi_Callback(hObject, eventdata, handles)
% Entrada manual de Zpb

phi = abs(str2double(get(handles.e_phi,'String')));
if ~isnan(phi)
    handles.phi = max(1,min(acos(1/handles.Nzmax)*180/pi,phi));
    handles.Nza = 1/cos(handles.phi*pi/180);
    set(handles.slider1,'Value',handles.Nza);
    slider1_Callback(hObject, eventdata, handles);
else
    updatefields(hObject, eventdata, handles);
end

% ---------------------------------------------------------------
function e_Nza_Callback(hObject, eventdata, handles)
% Entrada manual de Zpb

Nza = str2double(get(handles.e_Nza,'String'));
if ~isnan(Nza)
    handles.Nza = max(1,min(handles.Nzmax,Nza));
    set(handles.slider1,'Value',handles.Nza);
    slider1_Callback(hObject, eventdata, handles);
else
    updatefields(hObject, eventdata, handles);
end

% ---------------------------------------------------------------
function e_W_Callback(hObject, eventdata, handles)
% Entrada manual de Omega

W = str2double(get(handles.e_W,'String'));
if ~isnan(W)
    handles.W = max(0,min(100,W));
    guidata(hObject, handles);
    dragdata = [1 0 0 0 handles.M handles.W 1];
    window_WindowButtonMotionFcn(hObject, eventdata, handles, dragdata);
    handles = guidata(hObject);
    updateklegka(hObject, eventdata, handles);
else
    updatefields(hObject, eventdata, handles);
end

% ---------------------------------------------------------------
function e_Rad_Callback(hObject, eventdata, handles)
% Entrada manual de Raio de curva

Rad = str2double(get(handles.e_Rad,'String'));
if ~isnan(Rad)
    handles.Rad = max(100,Rad)/.3048;
    handles.W = 180/pi * (handles.Va*handles.kt2fps) / handles.Rad;
    guidata(hObject, handles);
    dragdata = [1 0 0 0 handles.M handles.W 1];
    window_WindowButtonMotionFcn(hObject, eventdata, handles, dragdata);
    updateklegka(hObject, eventdata, handles);
else
    updatefields(hObject, eventdata, handles);
end

% ---------------------------------------------------------------
function e_DISA_Callback(hObject, eventdata, handles)
% Entrada manual de DISA

DISA = str2double(get(handles.e_DISA,'String'));
if ~isnan(DISA)
    DISA = max(-30,min(30,DISA));
    set(handles.slider2,'Value',DISA);
end
slider2_Callback(hObject, eventdata, handles);

% ---------------------------------------------------------------
function e_Va_Callback(hObject, eventdata, handles)
% Entrada manual de Va

Va = str2double(get(handles.e_Va,'String'));
if ~isnan(Va)
    handles.Va = max(handles.VZ_lim(1),min(handles.VZ_lim(2),Va));
    guidata(hObject, handles);
    dragdata = [3 0 0 0 handles.Va handles.Zp 1];
    window_WindowButtonMotionFcn(hObject, eventdata, handles, dragdata);
    handles = guidata(hObject);
    updateklegka(hObject, eventdata, handles);
else
    updatefields(hObject, eventdata, handles);
end

% ---------------------------------------------------------------
function dir1_ButtonDownFcn(hObject, eventdata, handles)
% Indiciador da direçao da movimentaçao dos pontos do grafico qc x pa

switch get(handles.dir1,'String');
    case '+'
        set(handles.dir1,'String','-','FontSize',12);
    case '-'
        set(handles.dir1,'String','|','FontSize',4);
    case '|'
        set(handles.dir1,'String','\','FontSize',8);
    case '\'
        set(handles.dir1,'String','/','FontSize',8);
    case '/'
        set(handles.dir1,'String','+','FontSize',10);
end

% ---------------------------------------------------------------
function dir2_ButtonDownFcn(hObject, eventdata, handles)
% Indiciador da direçao da movimentaçao dos pontos do grafico Vc x Zp

switch get(handles.dir2,'String');
    case '+'
        set(handles.dir2,'String','-','FontSize',12);
    case '-'
        set(handles.dir2,'String','|','FontSize',4);
    case '|'
        set(handles.dir2,'String','\','FontSize',8);
    case '\'
        set(handles.dir2,'String','+','FontSize',10);
end

% ---------------------------------------------------------------
% -- WINDOW FUNCTIONS -------------------------------------------
% ---------------------------------------------------------------

function window_WindowButtonDownFcn(hObject, eventdata, handles)
% Funçao de clique do mouse

n = find(handles.axeslist == gca);

cp  = get(handles.axeslist(n),'CurrentPoint');
ct  = get(handles.window,'SelectionType');
cur = get(0,'PointerLocation');

if isempty(cp)
    return
end

x = cp(1,1);
y = cp(1,2);

k = 0;

switch n % Numero do grafico
    
    case 1 % M x W
        ax = diff(get(handles.axeslist(n),'XLim'));
        ay = diff(get(handles.axeslist(n),'YLim'));
        pos = get(handles.axeslist(n),'Position');
        
        xp1 = get(handles.p_MW,'XData');
        yp1 = get(handles.p_MW,'YData');
        
        if  abs(x-xp1) < 5*ax/pos(3) && abs(y-yp1) < 5*ay/pos(4) % Calibrado
            k = 1;
            h = handles.p_MW;
        end
        
        switch get(handles.dir1,'String');
            case '+'
                d = 1;
            case '-'
                d = 2;
            case '|'
                d = 3;
            case '\'
                d = 4;
            case '/'
                d = 5;
        end
        
    case 2 % Vc x Zp
        ax = diff(get(handles.axeslist(n),'XLim'));
        ay = diff(get(handles.axeslist(n),'YLim'));
        pos = get(handles.axeslist(n),'Position');

        xp2 = get(handles.p_VcZp,'XData');
        yp2 = get(handles.p_VcZp,'YData');
        xp4 = get(handles.p_VaZp,'XData');
        yp4 = get(handles.p_VaZp,'YData');

        if  abs(x-xp2) < 4*ax/pos(3) && abs(y-yp2) < 4*ay/pos(4) % Calibrado
            k = 2;
            h = handles.p_VcZp;
        elseif  abs(x-xp4) < 4*ax/pos(3) && abs(y-yp4) < 4*ay/pos(4) % Va
            k = 3;
            h = handles.p_VaZp;
        else
            switch ct
                case 'normal' % Esq
                    setappdata(handles.window,'fixcur',1);
                    p1 = get(handles.axeslist(n),'CurrentPoint');
                    rbbox;
                    p2 = get(handles.axeslist(n),'CurrentPoint');
                    setappdata(handles.window,'fixcur',0);
                    updatescale(hObject, eventdata, handles, [n sort([p1(1,1) p2(1,1)]) sort([p1(1,2) p2(1,2)])]);
                    updateklegka(hObject, eventdata, handles);
                case 'alt'    % Dir
                    setappdata(handles.window,'fixcur',1);
                    set(handles.window,'Pointer','arrow');
                case 'open'   % Duplo
                    if y > handles.Z_lim(1) && y < handles.Z_lim(2)
                        updatescale(hObject, eventdata, handles, [n 0 700 0 50000]);
                        updateklegka(hObject, eventdata, handles);
                    end
            end
        end
        
        switch get(handles.dir2,'String');
            case '+'
                d = 1;
            case '-'
                d = 2;
            case '|'
                d = 3;
            case '\'
                d = 4;
        end

end

if k
    setappdata(handles.window,'dragdata',[k h cur x y d]);
    set(handles.window,'Pointer','arrow');
else
    setappdata(handles.window,'dragdata',0);
end

% ---------------------------------------------------------------
function window_WindowButtonMotionFcn(hObject, eventdata, handles, dragdata)
% Funçao de movimentaçao do mouse

if ~isfield(handles,'axeslist')
    return
end

if nargin == 3
    dragdata = getappdata(handles.window,'dragdata');
    n = find(handles.axeslist == gca);
end

if isempty(dragdata)
    return
end

if dragdata(1)
    H  = dragdata(2);
    cx = dragdata(3);
    cy = dragdata(4);
    x  = dragdata(5);
    y  = dragdata(6);
    d  = dragdata(7);
    
    if H
        cur = get(0,'PointerLocation');
        ax = diff(get(handles.axeslist(n),'XLim'));
        ay = diff(get(handles.axeslist(n),'YLim'));
        pos = get(handles.axeslist(n),'Position');
        
        dx = ax/pos(3)*(cur(1)-cx);
        dy = ay/pos(4)*(cur(2)-cy);
    else
        dx = 0;
        dy = 0;
    end
    
    switch dragdata(1)
        
        case 1 % M, W
            Mmin = qcpa2m(vc2qc(handles.V_lim(1)),zp2pa(handles.Zp));
            if H
                ax = get(handles.axes1,'XLim');
                ay = get(handles.axes1,'YLim');
                M = min(ax(2),max(Mmin,x+dx));
                W = min(ay(2),max(ay(1),y+dy));
            else
                M = min(handles.Mmax,max(Mmin,x+dx));
                W = max(0,y+dy);
            end
            
            switch d
                case 1 % +
                    handles.M = M;
                    handles.W = W;
                case 2 % -
                    handles.M = M;
                case 3 % |
                    handles.W = W;
                case 4 % \
                    W = W;
                    Va = handles.g/(pi/180*W)*sqrt(handles.Nza.^2-1)/handles.kt2fps;
                    M = min(handles.Mmax,max(Mmin,Va/handles.a));
                    Va = handles.a*M;
                    W = 180/pi*(handles.g/(Va*handles.kt2fps))*sqrt(handles.Nza.^2-1);
                    handles.M = M;
                    handles.W = W;
                case 5 % /
                    Va = handles.Rad * W*pi/180 / handles.kt2fps;
                    M  = max(Mmin,Va/handles.a);
                    Va = handles.a*M;
                    W = 180/pi * (Va*handles.kt2fps) / handles.Rad;
                    Nza = sqrt((W / (180/pi*(handles.g/(Va*handles.kt2fps))))^2 + 1);
                    if Nza <= handles.Nzmax
                        handles.M = M;
                        handles.W = W;
                    end
            end
            
            handles.Vc = qc2vc(m2qcpa(handles.M)*zp2pa(handles.Zp));
            handles.Va = handles.a*handles.M;
            
            if handles.Va
                handles.Nza = min(handles.Nzmax,sqrt((handles.W / (180/pi*(handles.g/(handles.Va*handles.kt2fps))))^2 + 1));
                handles.phi = acos(1/handles.Nza)*180/pi;
                handles.W   = 180/pi*(handles.g/(handles.Va*handles.kt2fps))*sqrt(handles.Nza.^2-1);
            else
                handles.Nza = 1;
                handles.phi = 0;
                handles.W   = 0;
            end
            
            if handles.W
                handles.Rad = (handles.Va*handles.kt2fps) / (handles.W*pi/180);
            else
                handles.Rad = Inf;
            end
            
            set(handles.slider1,'Value',handles.Nza);
            
        case 2 % Vc, Zp
            if H
                if d == 4
                    handles.Zp = min(handles.Z_lim(2),max(handles.Z_lim(1),y+dy));
                    handles.Vc = qc2vc(m2qcpa(handles.M)*zp2pa(handles.Zp));
                else
                    if d ~= 2, handles.Zp = min(handles.Z_lim(2),max(handles.Z_lim(1),y+dy)); end
                    if d ~= 3, handles.Vc = min(qc2vc(m2qcpa(handles.Mmax)*zp2pa(handles.Zp)),min(handles.V_lim(2),max(handles.V_lim(1),x+dx))); end
                end
            else
                handles.Vc = min(handles.VZ_lim(2),max(handles.VZ_lim(1),x+dx));
                handles.Zp = min(handles.VZ_lim(4),max(handles.VZ_lim(3),y+dy));
            end
            
            qc = vc2qc(handles.Vc);
            pa = zp2pa(handles.Zp);
            if d ~= 4
                handles.M = qcpa2m(qc,pa);
            end
            handles.TaISA = zp2ta(handles.Zp)-handles.dT;
            handles.Ta    = handles.TaISA+handles.DISA;
            handles.a     = sqrt(handles.gama*handles.R*(handles.Ta+handles.dT))/(1852/3600);
            handles.Va    = handles.a*handles.M;
            handles.W     = 180/pi*(handles.g/(handles.Va*handles.kt2fps))*sqrt(handles.Nza.^2-1);
            if handles.W
                handles.Rad = (handles.Va*handles.kt2fps) / (handles.W*pi/180);
            else
                handles.Rad = Inf;
            end
                        
        case 3 % Va, Zp
            if H
                if d == 4
                    handles.Zp    = min(handles.Z_lim(2),max(handles.Z_lim(1),y+dy));
                    handles.TaISA = zp2ta(handles.Zp)-handles.dT;
                    handles.Ta    = handles.TaISA+handles.DISA;
                    handles.a     = sqrt(handles.gama*handles.R*(handles.Ta+handles.dT))/(1852/3600);
                    handles.Va    = handles.a*handles.M;
                else
                    if d ~= 3, handles.Va = min(handles.V_lim(2),max(handles.V_lim(1),x+dx)); end
                    if d ~= 2, handles.Zp = min(handles.Z_lim(2),max(handles.Z_lim(1),y+dy)); end
                end
            else
                handles.Va = min(handles.VZ_lim(2),max(handles.VZ_lim(1),x+dx));
                handles.Zp = min(handles.VZ_lim(4),max(handles.VZ_lim(3),y+dy));
            end
            
            if d ~= 4
                handles.TaISA = zp2ta(handles.Zp)-handles.dT;
                handles.Ta    = handles.TaISA+handles.DISA;
                handles.a     = sqrt(handles.gama*handles.R*(handles.Ta+handles.dT))/(1852/3600);
                handles.M     = handles.Va/handles.a;
                if handles.M > handles.Mmax
                    handles.M  = handles.Mmax;
                    handles.Va = handles.M*handles.a;
                end
            end
            pa = zp2pa(handles.Zp);
            qc = m2qcpa(handles.M)*pa;
            handles.Vc = qc2vc(qc);
            handles.W  = 180/pi*(handles.g/(handles.Va*handles.kt2fps))*sqrt(handles.Nza.^2-1);
            if handles.W
                handles.Rad = (handles.Va*handles.kt2fps) / (handles.W*pi/180);
            else
                handles.Rad = Inf;
            end
            
    end
    
    if handles.Rad < 100/.3048
        handles.Rad = 100/.3048;
        handles.W   = 180/pi * (handles.Va*handles.kt2fps) / handles.Rad;
        handles.Nza = sqrt((handles.W / (180/pi*(handles.g/(handles.Va*handles.kt2fps))))^2 + 1);
        handles.phi = acos(1/handles.Nza)*180/pi;
    end
    
    if dragdata(1)
        guidata(hObject, handles);
        updatefields(hObject, eventdata, handles);
    end
    
else
    updatecursor(hObject, eventdata, handles);
end

% ---------------------------------------------------------------
function window_WindowButtonUpFcn(hObject, eventdata, handles)
% Funçao de soltura do botao do mouse

setappdata(handles.window,'dragdata',0);
updateklegka(hObject, eventdata, handles);

% ---------------------------------------------------------------
function window_ResizeFcn(hObject, eventdata, handles)
% Alteraçao do tamanho da janela

if ~isfield(handles,'controls')
    return
end
    
minsize = [750 460];
ws = get(handles.window,'Position');
if ws(3) < minsize(1)
    ws(3) = minsize(1);
end
if ws(4) < minsize(2)
    ws(4) = minsize(2);
end
set(handles.window,'Position',ws);

set(handles.help_btn,'Position',[ws(3)-42 ws(4)-30 22 22]);

X = ws(3)-300;
set(handles.axes1  ,'Position',[50 50 X-50 ws(4)-90]);
set(handles.axes2  ,'Position',[X+80 ws(4)-200 200 160]);
set(handles.dir1   ,'Position',[X-12 16 10 14]);
set(handles.dir2   ,'Position',[X+268 ws(4)-229 10 14]);

for n = 1:length(handles.controls)
    pos = get(handles.controls(n),'Position');
    set(handles.controls(n),'Position',[X+handles.Xcontrols(n) handles.Ycontrols(n)+ws(4)-460 pos(3:4)]);
end

% -------------------------------------------------------------------
function window_KeyPressFcn(hObject, eventdata, handles)
% Acionamento de tecla do teclado

cc = get(handles.window,'CurrentCharacter');

if ~isempty(cc) && abs(cc) == 27 % Esc
    window_CloseRequestFcn(hObject, eventdata, handles);
end

% ---------------------------------------------------------------
function window_CloseRequestFcn(hObject, eventdata, handles)
% Solicitaçao de fechamento da janela

button = questdlg('Deseja sair?','Sair','Sim','Não','Não');
if ~strcmp(button,'Sim')
    return
end

delete(hObject);

% ---------------------------------------------------------------
% -- MENU FUNCTIONS ---------------------------------------------
% ---------------------------------------------------------------

function axes2menu_Callback(hObject, eventdata, handles)
% Menu do grafico Vc x Zp
setappdata(handles.window,'fixcur',0);

% --------------------------------------------------------------------
function editlimits_Callback(hObject, eventdata, handles)
% Editar limites dos graficos Vc x Zp e qc x pa

[Vmin, Vmax, Zmin, Zmax, dMach] = inputvalues('Limites',{'V min (kt):','V max (kt):','Z min (ft):','Z max (ft):','Intervalo de Mach:'},...
    {num2str(handles.V_lim(1)),num2str(handles.V_lim(2)),num2str(handles.Z_lim(1)),num2str(handles.Z_lim(2)),num2str(handles.dMach)});

if isempty(Vmin)
    return
end

Vmin  = roundn(str2double(Vmin),1);
Vmax  = roundn(str2double(Vmax),1);
Zmin  = roundn(str2double(Zmin),2);
Zmax  = roundn(str2double(Zmax),2);
dMach = roundn(str2double(dMach),-2);

if isnan(Vmin+Vmax+Zmin+Zmax+dMach)
    beep; uiwait(errordlg('Um ou mais valores incoerentes.','Erro'));
    return
end
if Vmax-Vmin < 10
    beep; uiwait(errordlg('Limites de velocidade incoerentes.','Erro'));
    return
end
if Zmax-Zmin < 100
    beep; uiwait(errordlg('Limites de altitude incoerentes.','Erro'));
    return
end
if dMach < .02
    beep; uiwait(errordlg('Intervalo de Mach incoerente.','Erro'));
    return
end

delete(findobj(handles.axes2,'Tag','aux'));

handles.V_lim = [max(handles.VZ_lim(1),Vmin) min(handles.VZ_lim(2),Vmax)];
handles.Z_lim = [max(handles.VZ_lim(3),Zmin) min(handles.VZ_lim(4),Zmax)];
handles.dMach = max(.01,dMach);
Mmax = qcpa2m(vc2qc(handles.V_lim(2)),zp2pa(handles.Z_lim(2)));

if handles.dMach < .1
    Mstr = '%0.2f';
else
    Mstr = '%0.1f';
end

guidata(hObject, handles);

axes(handles.axes2);
for Mi = handles.dMach:handles.dMach:Mmax
    Zpi = linspace(handles.Z_lim(1),handles.Z_lim(2),50);
    Vci = qc2vc(m2qcpa(Mi).*zp2pa(Zpi));
    plot(Vci,Zpi,'-k','HitTest','off','Tag','aux');
    text(max(Vci),handles.Z_lim(1),num2str(Mi,Mstr),'Clipping','on','FontSize',8,'HorizontalAlignment','center','VerticalAlignment','bottom','HitTest','off','Tag','aux');
end
axis([handles.V_lim handles.Z_lim]);

% --------------------------------------------------------------------
function updatescale(hObject, eventdata, handles, zoomdata)
% Alterar limites dos graficos Vc x Zp e qc x pa atraves do mouse

n = zoomdata(1);

if n == 1
    updatecursor(hObject, eventdata, handles);
    return
elseif n == 2
    Vmin = zoomdata(2);
    Vmax = zoomdata(3);
    Zmin = zoomdata(4);
    Zmax = zoomdata(5);
end

Vmin  = roundn(Vmin,1);
Vmax  = roundn(Vmax,1);
Zmin  = roundn(Zmin,2);
Zmax  = roundn(Zmax,2);

if Vmin == Vmax || Zmin == Zmax
    updatecursor(hObject, eventdata, handles);
    return
end

if Vmax-Vmin < 10
    Vm = mean([Vmax Vmin]);
    Vmin = Vm - 5;
    Vmax = Vm + 5;
end
if Zmax-Zmin < 100
    Zm = mean([Zmax Zmin]);
    Zmin = Zm - 50;
    Zmax = Zm + 50;
end

if ~(Vmax > handles.VZ_lim(1) && Vmin < handles.VZ_lim(2) && Zmax > handles.VZ_lim(3) && Zmin < handles.VZ_lim(4))
    updatecursor(hObject, eventdata, handles);
    return
end

delete(findobj(handles.axes2,'Tag','aux'));

handles.V_lim = [max(handles.VZ_lim(1),Vmin) min(handles.VZ_lim(2),Vmax)];
handles.Z_lim = [max(handles.VZ_lim(3),Zmin) min(handles.VZ_lim(4),Zmax)];

q_lim = vc2qc(handles.V_lim);
p_lim = sort(zp2pa(handles.Z_lim));

Mmax = qcpa2m(vc2qc(handles.V_lim(2)),zp2pa(handles.Z_lim(2)));

handles.dMach = (qcpa2m(q_lim(2),p_lim(2))-qcpa2m(q_lim(1),p_lim(2)))/6;
if handles.dMach < .05
    handles.dMach = roundn(handles.dMach,-2);
else
    handles.dMach = roundn(handles.dMach,-1);
end

handles.dMach = max(.01,handles.dMach);

if handles.dMach < .1
    Mstr = '%0.2f';
else
    Mstr = '%0.1f';
end

guidata(hObject, handles);

try
    axes(handles.axes2);
    axis([handles.V_lim handles.Z_lim]);
    for Mi = handles.dMach:handles.dMach:Mmax
        Zpi = linspace(handles.Z_lim(1),handles.Z_lim(2),50);
        Vci = qc2vc(m2qcpa(Mi).*zp2pa(Zpi));
        plot(Vci,Zpi,'-k','HitTest','off','Tag','aux');
        text(max(Vci),handles.Z_lim(1),num2str(Mi,Mstr),'Clipping','on','FontSize',8,'HorizontalAlignment','center','VerticalAlignment','bottom','HitTest','off','Tag','aux');
    end
end

updatecursor(hObject, eventdata, handles);

% ---------------------------------------------------------------
% -- UPDATE FUNCTIONS -------------------------------------------
% ---------------------------------------------------------------

function updatefields(hObject, eventdata, handles)
% Atualiza as caixas de texto

set(handles.e_Zp   ,'String', num2str(roundn(handles.Zp,-2)));
set(handles.e_Vc   ,'String', num2str(roundn(handles.Vc,-2)));
set(handles.e_M    ,'String', num2str(roundn(handles.M,-5)));
set(handles.e_phi  ,'String', num2str(roundn(handles.phi,-2)));
set(handles.e_Nza  ,'String', num2str(roundn(handles.Nza,-3)));
set(handles.e_W    ,'String', num2str(roundn(handles.W,-3)));
set(handles.e_Rad  ,'String', num2str(roundn(handles.Rad*.3048,-1)));
set(handles.e_DISA ,'String', num2str(roundn(handles.DISA,-3)));
set(handles.e_Va   ,'String', num2str(roundn(handles.Va,-2)));

set(handles.p_VcZp ,'XData',handles.Vc,'YData',handles.Zp);
set(handles.p_VaZp ,'XData',handles.Va,'YData',handles.Zp);
set(handles.p_MW   ,'XData',handles.M,'YData',handles.W);

drawnow;

% ---------------------------------------------------------------
function updateklegka(hObject, eventdata, handles)
% Atualiza o diagrama klegka

axes(handles.axes1);
Mmax = min(handles.Mmax,max(handles.M+.05,.9));
Wmax = max(20,handles.W+2);

exc = setdiff(findobj(handles.axes1,'Type','line'),handles.p_MW);
delete(exc);
exc = setdiff(findobj(handles.axes1,'Type','text'),handles.h_Nza);
delete(exc);

if handles.Nza <= 6
    Nzamax = max(6,ceil(handles.Nza*2)/2);
else
    Nzamax = ceil(handles.Nza);
end
klegka(handles.Zp,Wmax,Mmax,handles.DISA,Nzamax);

obj = get(handles.axes1,'Children');
obj(find(obj==handles.p_MW)) = [];
obj = [handles.p_MW; obj];
set(handles.axes1,'Children',obj);

updatecursor(hObject, eventdata, handles);

% ---------------------------------------------------------------
function klegka(Zp,Wmax,Mmax,dISA,Nzamax)
% Cria as linhas de Nza e Raio

if nargin==3
    dISA = 0;
    Nzamax = 6;
end
if nargin==4
    Nzamax = 6;
end
if nargin==0
    dISA = 0;
    Zp = 35000;
    Wmax = 20;
    Mmax = .8;
    Nzamax = 6;
end
M = 0:.02:Mmax;

g = 32.1740;					% ft/s²
Ta = zp2ta(Zp,dISA);			% K
a = sqrt(1.4*287.053*Ta)/.3048;	% ft/s
V = M.*a;                       % ft/s

if Nzamax <= 6 && Mmax <= 1.6
    Nza = [1.1 1.5:.5:Nzamax];
else
    Nza = [1.1 2:1:Nzamax];
end

axis([min(M) max(M) 0 Wmax]);

Vmax = Mmax.*a;                 % ft/s
Rup = Vmax/(Wmax*pi/180)*.3048; % m
Rup = ceil(Rup/100)*100;        % m
Rmax = Rup*3;

if Rup <= 1000
    dR = 100;
else
    dR = 200;
end

R = dR:dR:Rmax;	      		% m
Rft = R/.3048;              % ft

for i=1:length(R)
    for j=1:length(M);
        OmegaR(j) = (180/pi)*V(j)./Rft(i);
    end
    plot(M,OmegaR,'-g','HitTest','off');
    aux = find((180/pi)*V./Rft(i)>Wmax);
    if aux
        tn = text(M(aux(1)),Wmax,{num2str(R(i)),' '},'FontSize',8,'HorizontalAlignment','center');
    end
end

for k=1:length(Nza);
    for p=1:length(M);
        if ~V(p)
            OmegaNza(p) = Inf;
        else
            OmegaNza(p) = (180/pi)*(g/V(p))*sqrt(Nza(k).^2-1);
        end
    end
    plot(M,OmegaNza,'-r','HitTest','off');
    tn = text(max(M),min(OmegaNza),['  ' num2str(Nza(k))],'FontSize',8);
end

% ---------------------------------------------------------------
function updatecursor(hObject, eventdata, handles)
% Atualiza o tipo e posiçao do cursor

if getappdata(handles.window,'fixcur');
    return
end

cp = get(handles.window,'CurrentPoint') + [.5 .5];

ng = 0;
for n = 1:length(handles.axeslist)
    ap = get(handles.axeslist(n),'Position');
    ax = get(handles.axeslist(n),'XLim');
    ay = get(handles.axeslist(n),'YLim');
    
    x = (cp(1)-ap(1))*(ax(2)-ax(1))/ap(3) + ax(1);
    y = (cp(2)-ap(2))*(ay(2)-ay(1))/ap(4) + ay(1);
    
    if x >= ax(1) && x <= ax(2) && y >= ay(1) && y <= ay(2);
        ng = n;
        break
    end
end

switch ng % Numero do grafico
    
    case 0
       set(handles.window,'Pointer','arrow');      
        
    case 1 % W x M
        
        xp1 = get(handles.p_MW,'XData');
        yp1 = get(handles.p_MW,'YData');

        if     abs(x-xp1) < 4*diff(ax)/ap(3) && abs(y-yp1) < 4*diff(ay)/ap(4) % W x M
            set(handles.window,'Pointer','fleur'); 
            
        else
            set(handles.window,'Pointer','crosshair'); 
        end
        
    case 2 % Vc x Zp

        xp1 = get(handles.p_VcZp,'XData');
        yp1 = get(handles.p_VcZp,'YData');
        xp2 = get(handles.p_VaZp,'XData');
        yp2 = get(handles.p_VaZp,'YData');

        if     abs(x-xp1) < 4*diff(ax)/ap(3) && abs(y-yp1) < 4*diff(ay)/ap(4) % Calibrado
            set(handles.window,'Pointer','fleur'); 
            
        elseif abs(x-xp2) < 4*diff(ax)/ap(3) && abs(y-yp2) < 4*diff(ay)/ap(4) % Verdadeiro
            set(handles.window,'Pointer','fleur'); 
            
        else
            set(handles.window,'Pointer','crosshair'); 
        end
        
end

if ng
    
    if ng == 1
        ystr = num2str(y,4);
        xstr = num2str(x,4);
    else
        ystr = num2str(round(y));
        xstr = num2str(x,4);
    end
    
    if ng == 1
        M = x;
        W = y;
        
        Va = handles.a*M;
            
        if Va
            Nza = sqrt((W / (180/pi*(handles.g/(Va*handles.kt2fps))))^2 + 1);
            if Nza < 1.01
                Nza = '';
            end
        else
            Nza = '';
        end
        
        if W && Va && ~ischar(Nza)
            Rad = (Va*handles.kt2fps) / (W*pi/180) *.3048;
        else
            Rad = '';
        end

        Nstr = num2str(Nza,4);
        Rstr = num2str(Rad,5);
    else
        Nstr = '';
        Rstr = num2str(qcpa2m(vc2qc(x),zp2pa(y)),4);
    end
    
else
    ystr = '';
    xstr = '';
    Nstr = '';
    Rstr = '';
end

set(handles.ypos,'String',ystr);
set(handles.xpos,'String',xstr);
set(handles.Npos,'String',Nstr);
set(handles.Rpos,'String',Rstr);


% -------------------------------------------------------------------
function help_btn_Callback(hObject, eventdata, handles)
% Botao Ajuda

helpme('Ferramentas\klegkacalc');

