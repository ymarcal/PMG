function varargout = RDAT_EditMaps(varargin)
% RDAT_EDITMAPS M-file for RDAT_EditMaps.fig
% Last Modified by GUIDE v2.5 01-Apr-2011 18:38:02

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RDAT_EditMaps_OpeningFcn, ...
                   'gui_OutputFcn',  @RDAT_EditMaps_OutputFcn, ...
                   'gui_LayoutFcn',  @RDAT_EditMaps_LayoutFcn, ...
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
function h = RDAT_EditMaps_LayoutFcn(varargin)
% Função de layout inicial

h = openfig('RDAT_EditMaps.fig','reuse','invisible');

% ---------------------------------------------------------------------
function RDAT_EditMaps_OpeningFcn(hObject, eventdata, handles, varargin)
% Funçao de inicializaçao

set(handles.window,'windowstyle','normal')
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

ws = get(handles.window,'Position');
set(handles.window,'Position',[(ss(3)-ws(3))/2, (ss(4)-ws(4))/2, ws(3), ws(4)]);

bgc = getbuttoncolor(handles.window);
set(handles.zoom_btn,   'CData',geticon('DatButtons.mat','zoom',     bgc));
set(handles.drag_btn,   'CData',geticon('DatButtons.mat','drag',     bgc));
set(handles.fit_btn,    'CData',geticon('DatButtons.mat','fit',      bgc));
set(handles.fitmap_btn, 'CData',geticon('DatButtons.mat','fit3',     bgc));
set(handles.OpenGL_btn, 'CData',geticon('DatButtons.mat','opengl',   bgc));
set(handles.help_btn,   'CData',geticon('DatButtons.mat','help',     bgc));
set(handles.addmap_btn, 'CData',geticon('DatButtons.mat','add_s',    bgc));
set(handles.remmap_btn, 'CData',geticon('DatButtons.mat','rem_s',    bgc));
set(handles.editmap_btn,'CData',geticon('DatButtons.mat','edit_s',   bgc));
set(handles.upmap_btn,  'CData',geticon('DatButtons.mat','arrow_s',  bgc,1));
set(handles.dnmap_btn,  'CData',geticon('DatButtons.mat','arrow_s',  bgc,3,1));
set(handles.getpos_btn, 'CData',geticon('DatButtons.mat','acquire_s',bgc));

[handles.cursors.drag{1}, handles.cursors.drag_hs{1}] = getcursor('DatCursors.mat', 'hand0');
[handles.cursors.drag{2}, handles.cursors.drag_hs{2}] = getcursor('DatCursors.mat', 'hand1');
[handles.cursors.zoom,    handles.cursors.zoom_hs   ] = getcursor('DatCursors.mat', 'zoom');
setappdata(handles.window,'dragdata',0);
setappdata(handles.window,'prevsize',get(handles.maparea,'Position'));

if ~exist(which('DatMaps.mat'),'file')
    handles.ok = 0;
    guidata(hObject, handles);
    uiresume;
    beep; uiwait(errordlg('Base de dados de mapas não encontrada.','Erro','modal'));
    return
end

try
    axes(handles.maparea);
    axis equal;
    
    load(which('DatMaps.mat'));
    if isempty(mapdb)
        mapdb.mappos  = {};
        mapdb.mapres  = [];
        mapdb.mapname = {};
        mapdb.mapdata = {};
    else
        for n = 1:length(mapdb.mapname)
            mapname = ['map' num2str(n,'%05.0f')];
            eval(['mapdb.mapdata{' num2str(n) '} = ' mapname ';']);
        end
    end
    
    axes(handles.maparea);
    xlabel('Longitude');
    ylabel('Latitude');
    
    handles.map = [];
    handles.ok = 0;
    handles.chg = 0;
    handles.fname = '*.mat';
    handles.fpath = [pwd filesep];
    guidata(hObject, handles);
    
    set(handles.window,'Name','Banco de Dados de Mapas - Carregando mapas...','Pointer','watch');

    setmaps(hObject, eventdata, handles, mapdb);
    updatelist(hObject, eventdata, handles);
    fit_btn_Callback(hObject, eventdata, handles);
    
    set(handles.window,'Name','Banco de Dados de Mapas','Pointer','arrow');
    window_WindowButtonMotionFcn(hObject, eventdata, handles);
    
    uiwait(handles.window);
    
catch
    handles.ok = 0;
    guidata(hObject, handles);
    uiresume;
    beep; uiwait(errordlg('Mapas incompatíveis.','Erro','modal'));
end

% ---------------------------------------------------------------------
function varargout = RDAT_EditMaps_OutputFcn(hObject, eventdata, handles) 
% Funçao de saida

if handles.ok
    set(handles.window,'Pointer','watch');
    h = waitdlg('Salvando base de dados de mapas ...','Aguarde');
    mapdb = getappdata(handles.window,'mapdb');
    mapdata = mapdb.mapdata;
    mapdb = rmfield(mapdb,'mapdata');
    save(which('DatMaps.mat'),'mapdb',saveopt);
    for n = 1:length(mapdata)
        mapname = ['map' num2str(n,'%05.0f')];
        eval([mapname ' = mapdata{' num2str(n) '};']);
        save(which('DatMaps.mat'),mapname,'-append',saveopt);
    end
    if ishandle(h); delete(h); pause(.5); end
end

varargout{1} = handles.ok;
delete(handles.window);

% ---------------------------------------------------------------------
function updatelist(hObject, eventdata, handles, N)
% Aualiza a apresentaçao da lista e dos vertices dos mapas

if nargin == 3
    N = 1;
end

mapdb = getappdata(handles.window,'mapdb');

if isempty(mapdb.mapname)
    maps = ' ';
    nmapstr = '';
else
    k = length(mapdb.mapname);
    maps = [char(mapdb.mapname) spc(k,2) num2str(mapdb.mapres(:,1)) char( abs('x')'*ones(1,k))' num2str2(mapdb.mapres(:,2))];
    nmapstr = num2str(k);
end

set(handles.map_list,'String',maps,'Value',N);
set(handles.nmap_txt,'String',nmapstr);
map_list_Callback(hObject, eventdata, handles);

% ---------------------------------------------------------------------
function map_list_Callback(hObject, eventdata, handles)
% Funçao executada ao selecionar um mapa na lista

n = get(handles.map_list,'Value');
mapdb = getappdata(handles.window,'mapdb');

delete(findobj(handles.maparea,'UserData','sel'));

if isempty(mapdb.mapname)
    set([handles.lat1 handles.lat2 handles.lon1 handles.lon2],'String','','Enable','off');
else
    if length(n) == 1
        set(handles.lat1,'String',deg2latlong(mapdb.mappos{n}(1,1),1,3),'Enable','on');
        set(handles.lat2,'String',deg2latlong(mapdb.mappos{n}(3,1),1,3),'Enable','on');
        set(handles.lon1,'String',deg2latlong(mapdb.mappos{n}(1,2),2,3),'Enable','on');
        set(handles.lon2,'String',deg2latlong(mapdb.mappos{n}(2,2),2,3),'Enable','on');
    else
        set([handles.lat1 handles.lat2 handles.lon1 handles.lon2],'String','','Enable','off');
    end
    for k = 1:length(n)
        lat1 = mapdb.mappos{n(k)}(1,1);
        lat2 = mapdb.mappos{n(k)}(3,1);
        lon1 = mapdb.mappos{n(k)}(1,2);
        lon2 = mapdb.mappos{n(k)}(2,2);
        plot([lon1 lon1 lon2 lon2 lon1],[lat1 lat2 lat2 lat1 lat1],'--w','LineWidth',2,'UserData','sel');
    end
end

% -------------------------------------------------------------------------
function lat1_Callback(hObject, eventdata, handles)
% Latitude 1

n = get(handles.map_list,'Value');
mapdb = getappdata(handles.window,'mapdb');
[str,lat1] = latlongread(get(handles.lat1,'String'),1);
if isempty(lat1)
    lat1 = mapdb.mappos{n}(1,1);
end
mapdb.mappos{n}([1 2],1) = lat1;
updatemaps(hObject, eventdata, handles, mapdb);
updatelist(hObject, eventdata, handles, n);

handles.chg = 1;
guidata(hObject, handles);

% -------------------------------------------------------------------------
function lat2_Callback(hObject, eventdata, handles)
% Latitude 2

n = get(handles.map_list,'Value');
mapdb = getappdata(handles.window,'mapdb');
[str,lat2] = latlongread(get(handles.lat2,'String'),1);
if isempty(lat2)
    lat2 = mapdb.mappos{n}(3,1);
end
mapdb.mappos{n}([3 4],1) = lat2;
updatemaps(hObject, eventdata, handles, mapdb);
updatelist(hObject, eventdata, handles, n);

handles.chg = 1;
guidata(hObject, handles);

% -------------------------------------------------------------------------
function lon1_Callback(hObject, eventdata, handles)
% Longitude 1

n = get(handles.map_list,'Value');
mapdb = getappdata(handles.window,'mapdb');
[str,lon1] = latlongread(get(handles.lon1,'String'),2);
if isempty(lon1)
    lon1 = mapdb.mappos{n}(1,2);
end
mapdb.mappos{n}([1 3],2) = lon1;
updatemaps(hObject, eventdata, handles, mapdb);
updatelist(hObject, eventdata, handles, n);

handles.chg = 1;
guidata(hObject, handles);

% -------------------------------------------------------------------------
function lon2_Callback(hObject, eventdata, handles)
% Longitude 2

n = get(handles.map_list,'Value');
mapdb = getappdata(handles.window,'mapdb');
[str,lon2] = latlongread(get(handles.lon2,'String'),2);
if isempty(lon2)
    lon2 = mapdb.mappos{n}(2,2);
end
mapdb.mappos{n}([2 4],2) = lon2;
updatemaps(hObject, eventdata, handles, mapdb);
updatelist(hObject, eventdata, handles, n);

handles.chg = 1;
guidata(hObject, handles);

% -------------------------------------------------------------------------
function getpos_btn_Callback(hObject, eventdata, handles)
% Botao de obter as coordenadas com o mouse no grafico

n = get(handles.map_list,'Value');
mapdb = getappdata(handles.window,'mapdb');
if isempty(mapdb.mapname) || length(n) ~= 1
    beep;
    set(handles.getpos_btn,'Value',0);
    return
end
set([handles.zoom_btn handles.drag_btn],'Value',0);

% ---------------------------------------------------------------------
function window_CloseRequestFcn(hObject, eventdata, handles)
% Funçao de fechamento da janela

cancel_btn_Callback(hObject, eventdata, handles);

% --------------------------------------------------------------------
function window_WindowButtonMotionFcn(hObject, eventdata, handles)
% Funçao executada ao se mover o mouse

if strcmp(get(handles.window,'Pointer'),'watch')
    return
end

dragdata = getappdata(handles.window,'dragdata');
cp = get(handles.window,'CurrentPoint') + [.5 .5];
ng = 0;

ap = get(handles.maparea,'Position');
ax = get(handles.maparea,'XLim');
ay = get(handles.maparea,'YLim');

x = (cp(1)-ap(1))*(ax(2)-ax(1))/ap(3) + ax(1);
y = (cp(2)-ap(2))*(ay(2)-ay(1))/ap(4) + ay(1);

if x >= ax(1) && x <= ax(2) && y >= ay(1) && y <= ay(2);
    ng = 1;
end

% Tipo do cursor
if ng
    if get(handles.zoom_btn,'Value')
        set(handles.window,'Pointer','custom','PointerShapeCData',handles.cursors.zoom,'PointerShapeHotSpot',handles.cursors.zoom_hs);
        pointer = '';
    elseif get(handles.drag_btn,'Value')
        set(handles.window,'Pointer','custom','PointerShapeCData',handles.cursors.drag{dragdata(1)+1},'PointerShapeHotSpot',handles.cursors.drag_hs{dragdata(1)+1});
        pointer = '';
    else
        pointer = 'crosshair';
    end
    if ~isempty(pointer)
        set(handles.window,'Pointer',pointer);
    end
else
    set(handles.window,'Pointer','arrow');
end

% Arrastamento do grafico
if ng && dragdata(1)
    try
        %             1 23 45 67 8  9
        % dragdata = [1 cp ax ay gw gh]
        Dx = (cp(1)-dragdata(2))*diff(ax)/dragdata(8);
        Dy = (cp(2)-dragdata(3))*diff(ay)/dragdata(9);
        
        Ax = dragdata(4:5)-Dx;
        Ay = dragdata(6:7)-Dy;
        
        if Ax(1) < -180
            Ax = Ax - (Ax(1)+180);
        end
        if Ax(2) > 180
            Ax = Ax - (Ax(2)-180);
        end
        if Ay(1) < -90
            Ay = Ay - (Ay(1)+90);
        end
        if Ay(2) > 90
            Ay = Ay - (Ay(2)-90);
        end
        
        set(handles.maparea,'XLim',Ax,'YLim',Ay);
    end
end

% Posiçao do cursor
if ng
    latstr = deg2latlong(y,1,3);
    lonstr = deg2latlong(x,2,3);
else
    latstr = '';
    lonstr = '';
end

if ~dragdata(1)
    set(handles.lat,'String',latstr);
    set(handles.lon,'String',lonstr);
end

% ----------------------------------------------------------------
function window_WindowButtonDownFcn(hObject, eventdata, handles)
% Funçao exeutada ao se pressionar o botao do mouse

cp = get(handles.maparea,'CurrentPoint');
x = cp(1,1);
y = cp(1,2);
ax = get(handles.maparea,'XLim');
ay = get(handles.maparea,'YLim');

if x > ax(1) && x < ax(2) && y > ay(1) && y < ay(2)
    
    if get(handles.zoom_btn,'Value')
        switch get(handles.window,'SelectionType')
            case 'open' % Duplo clique
                
                set(handles.maparea,'XLimMode','auto','YLimMode','auto');
                
            case 'normal' % Clique simples
                
                t0 = clock;
                p1 = get(handles.maparea,'CurrentPoint');
                rbbox;
                p2 = get(handles.maparea,'CurrentPoint');
                dt = etime(clock,t0);
                
                x1 = max(-180,min(180,min(p1(1,1),p2(1,1))));
                x2 = max(-180,min(180,max(p1(1,1),p2(1,1))));
                y1 = max( -90,min( 90,min(p1(1,2),p2(1,2))));
                y2 = max( -90,min( 90,max(p1(1,2),p2(1,2))));
                
                if x2 == x1 && y2 == y1
                    if dt > .5
                        beep;
                    else
                        set(handles.maparea,'XLim',x1+[-.25 .25]*diff(ax),'YLim',y1+[-.25 .25]*diff(ay));                        
                    end
                else
                    if x2-x1 > 1e-4 && y2-y1 > 1e-4
                        pos = get(handles.maparea,'Position');
                        Tw = pos(3);
                        Th = pos(4);
                        if (x2-x1)/Tw >= (y2-y1)/Th
                            set(handles.maparea,'XLim',[x1 x2],'YLim',mean([y1 y2])+[-.5 .5]*(x2-x1)*Th/Tw);
                        else
                            set(handles.maparea,'XLim',mean([x1 x2])+[-.5 .5]*(y2-y1)*Tw/Th,'YLim',[y1 y2]);
                        end
                    else
                        beep;
                    end
                end
            case 'alt' % Botao direito
                set(handles.maparea,'XLim',x+[-1 1]*diff(ax),'YLim',y+[-1 1]*diff(ay));   
                
        end
        adjust_aspect(hObject, eventdata, handles);
        
    elseif get(handles.drag_btn,'Value')
        
        switch get(handles.window,'SelectionType')
            case {'normal','open'} % Clique simples
                ap = get(handles.maparea,'Position');
                cp = get(handles.window,'CurrentPoint') + [.5 .5];
                setappdata(handles.window,'dragdata',[1 cp ax ay ap(3:4)]);
            case 'alt' % Botao direito
                set(handles.drag_btn,'Value',0);
                setappdata(handles.window,'dragdata',0);
        end
    elseif get(handles.getpos_btn,'Value')
        
        p1 = get(handles.maparea,'CurrentPoint');
        rbbox;
        p2 = get(handles.maparea,'CurrentPoint');
        
        x1 = max(-180,min(180,min(p1(1,1),p2(1,1))));
        x2 = max(-180,min(180,max(p1(1,1),p2(1,1))));
        y1 = max( -90,min( 90,min(p1(1,2),p2(1,2))));
        y2 = max( -90,min( 90,max(p1(1,2),p2(1,2))));
        
        if x2 == x1 && y2 == y1
            beep;
        else
            if x2-x1 > 1e-4 && y2-y1 > 1e-4
                
                n = get(handles.map_list,'Value');
                mapdb = getappdata(handles.window,'mapdb');
                mapdb.mappos{n} = [y1 x1; y1 x2; y2 x1; y2 x2];
                updatemaps(hObject, eventdata, handles, mapdb);
                updatelist(hObject, eventdata, handles, n);
                
                handles.chg = 1;
                guidata(hObject, handles);
                
            else
                beep;
            end
        end
        
    else
        
        mapdb = getappdata(handles.window,'mapdb');
        for n = length(mapdb.mappos):-1:1
            lat1 = mapdb.mappos{n}(1,1);
            lat2 = mapdb.mappos{n}(3,1);
            lon1 = mapdb.mappos{n}(1,2);
            lon2 = mapdb.mappos{n}(2,2);
            if x > lon1 && x < lon2 && y > lat1 && y < lat2
                set(handles.map_list,'Value',n);
                map_list_Callback(hObject, eventdata, handles);
                break
            end
        end
        
    end
end

set(handles.getpos_btn,'Value',0);
window_WindowButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function window_WindowButtonUpFcn(hObject, eventdata, handles)
% Funçao executada apos a soltura do botao do mouse

setappdata(handles.window,'dragdata',0);
window_WindowButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function window_KeyPressFcn(hObject, eventdata, handles)
% Acionamento de tecla do teclado

cc = get(handles.window,'CurrentCharacter');

if isempty(cc)
    return
end

switch abs(cc)
    
    case 28 % <--
        ax = get(handles.maparea,'XLim');
        dx = min(.2*diff(ax),180+ax(1));
        set(handles.maparea,'XLim',ax-dx);
        
    case 29 % -->
        ax = get(handles.maparea,'XLim');
        dx = min(.2*diff(ax),180-ax(2));
        set(handles.maparea,'XLim',ax+dx);
        
    case 31 % Down
        ay = get(handles.maparea,'YLim');
        dy = min(.2*diff(ay),90+ay(1));
        set(handles.maparea,'YLim',ay-dy);
        
    case 30 % Up
        ay = get(handles.maparea,'YLim');
        dy = min(.2*diff(ay),90-ay(2));
        set(handles.maparea,'YLim',ay+dy);
        
    case abs('+')
        ax = get(handles.maparea,'XLim');
        dx = 1/6*diff(ax);
        ay = get(handles.maparea,'YLim');
        dy = 1/6*diff(ay);
        if dx >= 1e-3 && dy >= 1e-3
            set(handles.maparea,'XLim',ax+[1 -1]*dx,'YLim',ay+[1 -1]*dy);
        end
        
    case abs('-')
        ax = get(handles.maparea,'XLim');
        dx = .25*diff(ax);
        ay = get(handles.maparea,'YLim');
        dy = .25*diff(ay);
        if ax(1)-dx >= -180 && ax(2)+dx <= 180 && ay(1)-dy >= -90 && ay(2)+dy <= 90
            set(handles.maparea,'XLim',ax+[-1 1]*dx,'YLim',ay+[-1 1]*dy);
        end
        
    case abs('.')
        fit_btn_Callback(hObject, eventdata, handles);
        
    case abs('z')
        set(handles.zoom_btn,'Value',~get(handles.zoom_btn,'Value'))
        zoom_btn_Callback(hObject, eventdata, handles);
        
    case abs('Z')
        set(handles.drag_btn,'Value',~get(handles.drag_btn,'Value'))
        drag_btn_Callback(hObject, eventdata, handles);
        
    case 13 % Enter
        ok_btn_Callback(hObject, eventdata, handles);
        
    case 27 % Esc
        cancel_btn_Callback(hObject, eventdata, handles);
        
end

% --------------------------------------------------------------------
function window_ResizeFcn(hObject, eventdata, handles)
% Funçao de redimensionamento da janela

if isempty(handles)
    return
end

% Limite minimo
ws = get(handles.window,'Position');
sw = 820;
sh = 540;

if ws(3) < sw || ws(4) < sh
    set(handles.window,'Position',[ws(1) ws(2)+ws(4)-max(ws(4),sh) max(ws(3),sw) max(ws(4),sh)]);
end

ws = get(handles.window,'Position');

Tw = ws(3)-360;
Th = ws(4)-80;

set(handles.maparea,'Position',[340 60 Tw Th]);
adjust_aspect(hObject, eventdata, handles, 1);

ctrlh = findobj(handles.window,'UserData',1);
dpos = zeros(length(ctrlh),4);
pos0 = get(handles.fit_btn,'Position').*[1 1 0 0];
for n = 1:length(ctrlh)
    dpos(n,:) = get(ctrlh(n),'Position')-pos0;
end
for n = 1:length(ctrlh)
    set(ctrlh(n),'Position',[20 ws(4)-30 0 0]+dpos(n,:));
end

set(handles.map_list,'Position',[20 188 220 ws(4)-188-60]);

set(handles.lat,'Position',[ws(3)-100 20 80 15]);
set(handles.lon,'Position',[ws(3)-100  5 80 15]);

% --------------------------------------------------------------------
function adjust_aspect(hObject, eventdata, handles, resize)
% Funçao que ajusta as proporções da área gráfica de acordo com o aspecto

if isempty(handles)
    return
end

if nargin == 3
    resize = 0;
end

if resize
    prevpos = getappdata(handles.window,'prevsize');
    
    pos = get(handles.maparea,'Position');
    Tw = pos(3);
    Th = pos(4);
    
    ax  = get(handles.maparea,'XLim');
    ay  = get(handles.maparea,'YLim');
    
    set(handles.maparea,'XLim',mean(ax)+diff(ax)*Tw/prevpos(3)*[-.5 .5],'YLim',mean(ay)+diff(ay)*Th/prevpos(4)*[-.5 .5]);

    setappdata(handles.window,'prevsize',pos);
    
else
    
    pos = get(handles.maparea,'Position');
    Tw = pos(3);
    Th = pos(4);

    ax  = get(handles.maparea,'XLim');
    ay  = get(handles.maparea,'YLim');
    
    if Tw < Th
        set(handles.maparea,'YLim',mean(ay)+diff(ax)*Th/Tw*[-.5 .5]);
    else
        set(handles.maparea,'XLim',mean(ax)+diff(ay)*Tw/Th*[-.5 .5]);
    end
    
end

ax = get(handles.maparea,'XLim');
ay = get(handles.maparea,'YLim');
ar = diff(ay)/diff(ax);

if diff(ay) > 180
    ay = [-90 90];
    ax = mean(ax)+180/ar*[-.5 .5];
end
if diff(ax) > 360
    ax = [-180 180];
    ay = mean(ay)+ar*360*[-.5 .5];
end

if ay(1) < -90
    ay = -90+[0 diff(ay)];
end
if ay(2) > 90
    ay = 90-[diff(ay) 0];
end
if ax(1) < -180
    ax = -180+[0 diff(ax)];
end
if ax(2) > 180
    ax = 180-[diff(ax) 0];
end

set(handles.maparea,'XLim',ax,'YLim',ay);

% --------------------------------------------------------------------
function fit_btn_Callback(hObject, eventdata, handles)
% Botao de auto ajuste do zoom

set(handles.maparea,'XLimMode','auto','YLimMode','auto');
adjust_aspect(hObject, eventdata, handles);
set([handles.zoom_btn handles.drag_btn handles.getpos_btn],'Value',0);
window_WindowButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function fitmap_btn_Callback(hObject, eventdata, handles)
% Botao de auto ajuste do zoom ao mapa selecionado

hsel = findobj(handles.maparea,'UserData','sel');

xmin = NaN; xmax = NaN;
ymin = NaN; ymax = NaN;

for n = 1:length(hsel)
    x1 = min(get(hsel(n),'XData'));
    if ~isempty(x1), xmin = min(xmin, x1); end
    x2 = max(get(hsel(n),'XData'));
    if ~isempty(x2), xmax = max(xmax, x2); end
    y1 = min(get(hsel(n),'YData'));
    if ~isempty(y1), ymin = min(ymin, y1); end
    y2 = max(get(hsel(n),'YData'));
    if ~isempty(y2), ymax = max(ymax, y2); end
end

if isnan(xmin), xmin = -1; end
if isnan(xmax), xmax =  1; end
if isnan(ymin), ymin = -1; end
if isnan(ymax), ymax =  1; end

ax = xmax - xmin;
ay = ymax - ymin;

if ax < eps && ay < eps
    xmin = xmin - 1;
    xmax = xmax + 1;
    ymin = ymin - 1;
    ymax = ymax + 1;
elseif ax < eps
    xmin = xmin - ay/2;
    xmax = xmax + ay/2;
end
if ay < eps
    ymin = ymin - ax/2;
    ymax = ymax + ax/2;
end

xmin = xmin-.05*ax;
xmax = xmax+.05*ax;
ymin = ymin-.05*ay;
ymax = ymax+.05*ay;

ax = xmax - xmin;
ay = ymax - ymin;

pos = get(handles.maparea,'Position');
Tw = pos(3);
Th = pos(4);

if Tw/ax > Th/ay
    dy = [ymin ymax];
    dx = mean([xmin xmax]) + .5*[-1 1]*ay*Tw/Th ;
else
    dx = [xmin xmax];
    dy = mean([ymin ymax]) + .5*[-1 1]*ax*Th/Tw ;
end

set(handles.maparea,'XLim',dx,'YLim',dy);

set([handles.zoom_btn handles.drag_btn handles.getpos_btn],'Value',0);
window_WindowButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function zoom_btn_Callback(hObject, eventdata, handles)
% Botao de zoom com o mouse

set([handles.drag_btn  handles.getpos_btn],'Value',0);
window_WindowButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function drag_btn_Callback(hObject, eventdata, handles)
% Botao de arrastar com o mouse

set([handles.zoom_btn  handles.getpos_btn],'Value',0);
window_WindowButtonMotionFcn(hObject, eventdata, handles);

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

helpme('Ferramentas\editormapas');

% ---------------------------------------------------------------------
function ok_btn_Callback(hObject, eventdata, handles)
% Botao OK

if handles.chg
    button = questdlg('Deseja confirmar as alterações?','Confirmação','Sim','Não','Sim'); drawnow;
    if strcmp(button,'Sim')
        handles.ok = 1;
        guidata(hObject, handles);
        uiresume;
    end
else
    cancel_btn_Callback(hObject, eventdata, handles);
end

% ---------------------------------------------------------------------
function cancel_btn_Callback(hObject, eventdata, handles)
% Botao de cancelar

if handles.chg
    button = questdlg('Deseja descartar as alterações?','Confirmação','Sim','Não','Não');
else
    button = 'Sim';
end
if strcmp(button,'Sim')
    uiresume;
end

%--------------------------------------------------------------------------
function addmap_btn_Callback(hObject, eventdata, handles)
% Importar mapa

set(handles.addmap_btn,'Value',0);

mapdb = getappdata(handles.window,'mapdb');
N = length(mapdb.mapname);
oldmapdb = mapdb;

types = {...
        '*.jpg;*.tif;*.gif;*.bmp;*.hdf;*.bpm;*.pcx;*.pgm;*.png;*.ppm;*.ras;*.xwd','Todos os arquivos de imagem';...
        '*.jpg;*.jpeg','Joint Photographic Experts Group (.jpg)';...
        '*.tif;*.tiff','Tagged Image File Format (.tif)';...
        '*.gif','Graphics Interchange Format (.gif)';...
        '*.bmp','Windows Bitmap (.bmp)';...
        '*.hdf','Hierarchical Data Format (.hdf)';...
        '*.pbm','Portable Bitmap (.pbm)';...
        '*.pcx','Windows Paintbrush (.pcx)';...
        '*.pgm','Portable Graymap (.pgm)';...
        '*.png','Portable Network Graphics (.png)';...
        '*.ppm','Portable Pixmap (.ppm)';...
        '*.ras','Sun Raster (.ras)';...
        '*.xwd','X Windows Dump (.xwd)';...
        '*.*','Todos os arquivos'};

[fname, fpath] = uigetfile(types,'Adicionar mapa',handles.fpath);

if ~ischar(fname)
    return
end

try
    [M,C] = imread([fpath, fname]);
catch
    beep; uiwait(errordlg('O arquivo indicado não é de imagem.','Erro','modal'));
    return
end

if ~isempty(C)
    M = ind2rgb(M,C);
end

alpha = [];
button = questdlg({'Deseja converter uma determinada cor em transparência?','(só funciona com renderizador OpenGL)'},'Opção','Sim','Não','Não');
if strcmp(button,'Sim')
    alphacolor = uisetcolor('Defina a cor transparente:');
    if length(alphacolor) == 3
        Muint8 = im2uint8(M);
        alphacolor = uint8(alphacolor*255);
        alpha = true(size(M));
        for v = 1:size(M,1)
            for h = 1:size(M,2)
                if Muint8(v,h,1) == alphacolor(1) && Muint8(v,h,2) == alphacolor(2) && Muint8(v,h,3) == alphacolor(3)
                    alpha(v,h) = false;
                end
            end
        end
        if all(all(alpha))
            uiwait(warndlg('A cor indicada não foi encontrada na imagem.','Aviso','modal'));
            alpha = [];
        end
    else
        return
    end
end

[path, name] = fileparts([fpath, fname]);

newname = inputvalues('Novo mapa','Nome:',name); drawnow;

if ~ischar(newname)
    return
end

if ~isempty(strmatch(newname,mapdb.mapname,'exact'))
    beep; uiwait(errordlg(['Mapa ' newname ' já cadastrado.'],'Erro','modal'));
    return
end

[lat1 lat2 lon1 lon2] = getICAmap(name);
if ~isempty(lat1)
    button = questdlg({'O mapa carregado possui nomenclatura padrão ICA.',...
            'Deseja interpretar as coordenadas?'},'Opção','Sim','Não','Sim'); drawnow;
else
    button = 'Não';
end

set(handles.window,'Pointer','watch');

mapdb.mapname{N+1} = newname;
mapdb.mapres(N+1,:)= [size(M,2) size(M,1)];
mapdb.mapdata{N+1} = rgb2jpg(M);
if strcmp(button,'Sim')
    mapdb.mappos{N+1}  = [lat1 lon1; lat1 lon2; lat2 lon1; lat2 lon2];
else
    mapdb.mappos{N+1}  = NaN*ones(4,2);
end
if ~isempty(alpha)
    mapdb.mapalpha{N+1} = flipud(alpha);
end

handles.fpath = fpath;

guidata(hObject, handles);
if ~isequalwithequalnans(mapdb,oldmapdb)
    handles.chg = 1;
    guidata(hObject, handles);
    
    setmaps(hObject, eventdata, handles, mapdb, N+1);
    updatelist(hObject, eventdata, handles, N+1);
end

set(handles.window,'Pointer','arrow');

%--------------------------------------------------------------------------
function remmap_btn_Callback(hObject, eventdata, handles)
% Remover mapas

set(handles.remmap_btn,'Value',0);

n = get(handles.map_list,'Value');
mapdb = getappdata(handles.window,'mapdb');

if isempty(mapdb.mapname)
    beep;
    return
end

if length(n) == 1
    button = questdlg(['Deseja remover o mapa ''' mapdb.mapname{n} ''' ?'],'Confirmação','Sim','Não','Não');
else
    button = questdlg(['Deseja remover os ' num2str(length(n)) ' mapas selecionados?'],'Confirmação','Sim','Não','Não');
end

if strcmp(button,'Sim')
    mapdb.mappos(n)  = [];
    mapdb.mapname(n) = [];
    mapdb.mapres(n,:)= [];
    mapdb.mapdata(n) = [];
    N = min(max(n),max(1,length(mapdb.mapname)));
    
    delete(handles.map(n));
    handles.map(n) = [];
    handles.chg = 1;

    guidata(hObject, handles);
    
    setappdata(handles.window,'mapdb',mapdb);
    updatelist(hObject, eventdata, handles, N);
end

%--------------------------------------------------------------------------
function editmap_btn_Callback(hObject, eventdata, handles)
% Mudar nome do mapa

n = get(handles.map_list,'Value');

if length(n) ~= 1
    beep;
    return
end

mapdb = getappdata(handles.window,'mapdb');
oldmapdb = mapdb;

if isempty(mapdb.mapname)
    beep;
    return
else
    [newname, chgimg] = inputvalues('Editar mapa',{'Nome:','Arquivo fonte:'},{mapdb.mapname{n},{'Manter','Alterar'}}); drawnow;
    
    if ~ischar(newname)
        return
    end
    
    if ~isequal(newname,mapdb.mapname{n}) && ~isempty(strmatch(newname,mapdb.mapname,'exact'))
        beep; uiwait(errordlg(['Mapa ' newname ' já cadastrado.'],'Erro','modal'));
        return
    end
    
    mapdb.mapname{n} = newname;
    
    if chgimg == 2
        
        types = {...
                '*.jpg;*.tif;*.gif;*.bmp;*.hdf;*.bpm;*.pcx;*.pgm;*.png;*.ppm;*.ras;*.xwd','Todos os arquivos de imagem';...
                '*.jpg;*.jpeg','Joint Photographic Experts Group (.jpg)';...
                '*.tif;*.tiff','Tagged Image File Format (.tif)';...
                '*.gif','Graphics Interchange Format (.gif)';...
                '*.bmp','Windows Bitmap (.bmp)';...
                '*.hdf','Hierarchical Data Format (.hdf)';...
                '*.pbm','Portable Bitmap (.pbm)';...
                '*.pcx','Windows Paintbrush (.pcx)';...
                '*.pgm','Portable Graymap (.pgm)';...
                '*.png','Portable Network Graphics (.png)';...
                '*.ppm','Portable Pixmap (.ppm)';...
                '*.ras','Sun Raster (.ras)';...
                '*.xwd','X Windows Dump (.xwd)';...
                '*.*','Todos os arquivos'};
        
        [fname, fpath] = uigetfile(types,'Alterar mapa',handles.fpath);
        
        if ~ischar(fname)
            return
        end
        
        try
            [M,C] = imread([fpath, fname]);
        catch
            beep; uiwait(errordlg('O arquivo indicado não é de imagem.','Erro','modal'));
            return
        end
        
        if ~isempty(C)
            M = ind2rgb(M,C);
        end
        
        alpha = [];
        button = questdlg({'Deseja converter uma determinada cor em transparência?','(só funciona com renderizador OpenGL)'},'Opção','Sim','Não','Não');
        if strcmp(button,'Sim')
            alphacolor = uisetcolor('Defina a cor transparente:');
            if length(alphacolor) == 3
                Muint8 = im2uint8(M);
                alphacolor = uint8(alphacolor*255);
                alpha = true(size(M));
                for v = 1:size(M,1)
                    for h = 1:size(M,2)
                        if Muint8(v,h,1) == alphacolor(1) && Muint8(v,h,2) == alphacolor(2) && Muint8(v,h,3) == alphacolor(3)
                            alpha(v,h) = false;
                        end
                    end
                end
            else
                return
            end
        end
        
        set(handles.window,'Pointer','watch');
        
        mapdb.mapres(n,:) = [size(M,2) size(M,1)];
        mapdb.mapdata{n}  = rgb2jpg(M);
        if ~isempty(alpha)
            mapdb.mapalpha{n} = flipud(alpha);
        end
        
        handles.fpath = fpath;
        
        set(handles.window,'Pointer','arrow');
        
    end
    
end

if ~isequalwithequalnans(mapdb,oldmapdb) || chgimg == 2
    handles.chg = 1;
    guidata(hObject, handles);
    
    updatemaps(hObject, eventdata, handles, mapdb, n, chgimg-1);
    updatelist(hObject, eventdata, handles, n);
end

%--------------------------------------------------------------------------
function upmap_btn_Callback(hObject, eventdata, handles)
% Mover mapa para cima

n = get(handles.map_list,'Value');
mapdb = getappdata(handles.window,'mapdb');
oldmapdb = mapdb;

if length(n) ~= 1 || n == 1
    beep;
    return
end

if isempty(mapdb.mapname)
    beep;
    return
end
aux                = mapdb.mapname{n-1};
mapdb.mapname{n-1} = mapdb.mapname{n};
mapdb.mapname{n}   = aux;
aux                = mapdb.mappos{n-1};
mapdb.mappos{n-1}  = mapdb.mappos{n};
mapdb.mappos{n}    = aux;
aux                = mapdb.mapres(n-1,:);
mapdb.mapres(n-1,:)= mapdb.mapres(n,:);
mapdb.mapres(n,:)  = aux;
aux                = mapdb.mapdata{n-1};
mapdb.mapdata{n-1} = mapdb.mapdata{n};
mapdb.mapdata{n}   = aux;

if ~isequalwithequalnans(mapdb,oldmapdb)
    handles.chg = 1;
    guidata(hObject, handles);
    
    aux1 = get(handles.map(n-1),'XData');
    aux2 = get(handles.map(n-1),'YData');
    aux3 = get(handles.map(n-1),'CData');
    aux4 = get(handles.map(n-1),'Visible');
    set(handles.map(n-1),'XData',get(handles.map(n),'XData'),'YData',get(handles.map(n),'YData'),'CData',get(handles.map(n),'CData'),'Visible',get(handles.map(n),'Visible'));
    set(handles.map(n)  ,'XData',aux1,'YData',aux2,'CData',aux3,'Visible',aux4);
     
    setappdata(handles.window,'mapdb',mapdb);
    updatelist(hObject, eventdata, handles, n-1);
end

%--------------------------------------------------------------------------
function dnmap_btn_Callback(hObject, eventdata, handles)
% Mover mapa para baixo

n = get(handles.map_list,'Value');
mapdb = getappdata(handles.window,'mapdb');
oldmapdb = mapdb;

if length(n) ~= 1 || n >= length(cellstr(get(handles.map_list,'String')))
    beep;
    return
end

if isempty(mapdb.mapname)
    beep;
    return
end
aux                = mapdb.mapname{n+1};
mapdb.mapname{n+1} = mapdb.mapname{n};
mapdb.mapname{n}   = aux;
aux                = mapdb.mappos{n+1};
mapdb.mappos{n+1}  = mapdb.mappos{n};
mapdb.mappos{n}    = aux;
aux                = mapdb.mapres(n+1,:);
mapdb.mapres(n+1,:)= mapdb.mapres(n,:);
mapdb.mapres(n,:)  = aux;
aux                = mapdb.mapdata{n+1};
mapdb.mapdata{n+1} = mapdb.mapdata{n};
mapdb.mapdata{n}   = aux;

if ~isequalwithequalnans(mapdb,oldmapdb)
    handles.chg = 1;
    guidata(hObject, handles);
    
    aux1 = get(handles.map(n+1),'XData');
    aux2 = get(handles.map(n+1),'YData');
    aux3 = get(handles.map(n+1),'CData');
    aux4 = get(handles.map(n+1),'Visible');
    set(handles.map(n+1),'XData',get(handles.map(n),'XData'),'YData',get(handles.map(n),'YData'),'CData',get(handles.map(n),'CData'),'Visible',get(handles.map(n),'Visible'));
    set(handles.map(n)  ,'XData',aux1,'YData',aux2,'CData',aux3,'Visible',aux4);
     
    setappdata(handles.window,'mapdb',mapdb);
    updatelist(hObject, eventdata, handles, n+1);
end

% --------------------------------------------------------------------
function setmaps(hObject, eventdata, handles, mapdb, N)
% Refazer apresentaçao dos mapas

if isempty(mapdb)
    return
end

set(handles.window,'Pointer','watch');

if nargin == 4
    N = 1:length(mapdb.mappos);
end

% Apagar todos os mapas atuais
if ~isempty(handles.map) && length(N) > 1
    delete(handles.map);
    handles.map = [];
end

% Recriaçao dos mapas
try
    
    axes(handles.maparea);
    
    % Maps
    for n = N
        img = flipud3(jpg2rgb(mapdb.mapdata{n}));
        if isfield(mapdb,'mapalpha') && length(mapdb.mapalpha)>=n && ~isempty(mapdb.mapalpha{n})
            alpha = double(mapdb.mapalpha{n});
        else
            alpha = 1;
        end
        if length(handles.map)>=n && ishandle(handles.map(n))
            delete(handles.map(n))
        end
        if any(isnan(mapdb.mappos{n}(:))) % Bug do MatLab: "NaN" na posiçao da figura é irreversivel
            handles.map(n) = image([0 1],[0 1],img,'AlphaData',alpha,'Visible','off');
        else
            handles.map(n) = image(mapdb.mappos{n}([1,4],2),mapdb.mappos{n}([1,4],1),img,'AlphaData',alpha,'Visible','on');
        end
        drawnow;
    end
    setappdata(handles.window,'mapdb',mapdb);
    
catch
    
    if ~isempty(handles.map)
        delete(handles.map);
        handles.map = [];
    end
    
    beep; uiwait(errordlg('Erro ao carregar mapas.','Erro','modal'));
    
end

guidata(hObject, handles);

set(handles.window,'Pointer','arrow');

% --------------------------------------------------------------------
function updatemaps(hObject, eventdata, handles, mapdb, N, opt)
% Atualiza mapas atuais

if nargin <= 4
    N = 1:length(mapdb.mappos);
end
if nargin <= 5
    opt = 0; % Atualizar imagem
end

if ~isempty(mapdb)
    
    % Atualizaçao dos mapas
    
    for n = N
        if ~any(isnan(mapdb.mappos{n}(:))) % Bug do MatLab: "NaN" na posiçao da figura é irreversivel
            set(handles.map(n),'XData',mapdb.mappos{n}([1,4],2),'YData',mapdb.mappos{n}([1,4],1),'Visible','on');
        end
        if opt
            img = flipud3(jpg2rgb(mapdb.mapdata{n}));
            if isfield(mapdb,'mapalpha') && length(mapdb.mapalpha)>=n && ~isempty(mapdb.mapalpha{n})
                alpha = double(mapdb.mapalpha{n});
            else
                alpha = 1;
            end
            set(handles.map(n),'CData',img,'AlphaData',alpha,'AlphaDataMapping','none');
        end
    end
    
    setappdata(handles.window,'mapdb',mapdb);
    
end

% --------------------------------------------------------------------
function str = spc(N,M)
% Cria coluna de espaços

if nargin == 1
    M = 1;
end

str = char(32*ones(N,M));
