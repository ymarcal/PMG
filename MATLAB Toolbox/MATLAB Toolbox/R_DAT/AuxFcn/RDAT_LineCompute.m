function varargout = RDAT_LineCompute(varargin)
% RDAT_LINECOMPUTE M-file for RDAT_LineCompute.fig
% Last Modified by GUIDE v2.5 27-Mar-2012 15:20:45

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RDAT_LineCompute_OpeningFcn, ...
                   'gui_OutputFcn',  @RDAT_LineCompute_OutputFcn, ...
                   'gui_LayoutFcn',  @RDAT_LineCompute_LayoutFcn, ...
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

% ----------------------------------------------------------------------
function h = RDAT_LineCompute_LayoutFcn(varargin)
% Função de layout inicial

h = openfig('RDAT_LineCompute.fig','reuse','invisible');

% ---------------------------------------------------------------------
function RDAT_LineCompute_OpeningFcn(hObject, eventdata, handles, varargin)
% Funçao de inicializaçao

%  set(handles.window,'windowstyle','normal') % @@

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
set(handles.clear_btn, 'CData',geticon('DatButtons.mat','new', bgc));
set(handles.fitall_btn,'CData',geticon('DatButtons.mat','fit', bgc));
set(handles.fitnew_btn,'CData',geticon('DatButtons.mat','fit3',bgc));
set(handles.prev_btn,  'CData',geticon('DatButtons.mat','play',bgc, 0, 1));
set(handles.next_btn,  'CData',geticon('DatButtons.mat','play',bgc));
set(handles.help_btn,  'CData',geticon('DatButtons.mat','help',bgc));

handles.txtlist   = [handles.txt1   handles.txt2   handles.txt3   handles.txt4   handles.txt5   handles.txt6   handles.txt7   handles.txt8   handles.txt9   handles.txt10];
handles.entrylist = [handles.entry1 handles.entry2 handles.entry3 handles.entry4 handles.entry5 handles.entry6 handles.entry7 handles.entry8 handles.entry9 handles.entry10];

if ~isempty(varargin)
    scenario = varargin{1};
    ntype    = varargin{2};
    n        = varargin{3};
    Dmaggrid = varargin{4};
else
    scenario = [];
end

if isempty(scenario)
    ktype    = 'line';
    auxpos   = [];
    auxstyle = '-';
    auxcolor = 'b';
    wptpos   = [];
    aidpos   = [];
    Dmag     = 0;
    try
        [latgrid longrid Dmaggrid] = geomag_grid(-40,10,-80,-30,2);
    catch
        latgrid  = [0 1]';
        longrid  = [0 1];
        Dmaggrid = [NaN NaN; NaN NaN];
    end
    Dmaggrid = [NaN longrid; latgrid Dmaggrid];
else
    switch ntype
        case 'aux'
            ktype    = scenario.aux(n).type;
            auxpos   = scenario.aux(n).data;
            auxstyle = scenario.aux(n).style;
            auxcolor = scenario.aux(n).color;
        case 'fa'
            ktype    = 'line';
            auxpos   = scenario.fa(n).data;
            auxstyle = scenario.fa(n).style;
            auxcolor = scenario.fa(n).color;
            if ~isempty(auxpos)
                auxpos(end,:) = [];
            end
    end
    if ~isempty(scenario.wpt)
        wptpos = scenario.wpt.data(:,2:3);
        wptnum = scenario.wpt.data(:,1);
        wptcod = scenario.wpt.code;
    else
        wptpos = [];
    end
    if ~isempty(scenario.aid)
        aidpos = scenario.aid.data(:,1:2);
        aidcod = scenario.aid.code;
        aidtyp = scenario.aid.type;
    else
        aidpos = [];
    end
    Dmag = scenario.Dmag;
end

handles.Dmag = Dmag;
handles.auxpos = auxpos;
handles.wptpos = [wptpos; aidpos];

setappdata(handles.window,'newpos',{[]});
setappdata(handles.window,'N',1);
setappdata(handles.window,'Dmaggrid',Dmaggrid);

set(handles.Dmag_entry,'String',num2str(handles.Dmag));

axes(handles.TSD);
xlabel('Longitude');
ylabel('Latitude');

set(handles.type_sel,'String',{'Perna/Ponto','Arco','Curva','Órbita'});
str{1} = ' ';
str{2} = 'Ponto anterior';
for n = 1:size(wptpos,1)
    str{end+1} = ['WPT ' num2str(wptnum(n),'%02d') ' - ' wptcod{n}];
end
for n = 1:size(aidpos,1)
    str{end+1} = [aidtyp{n} ' ' aidcod{n}];
end
set(handles.ref_sel,'String',str,'Value',2);

% Scenario objects
if isempty(auxpos)
    auxpos = [NaN NaN];
end

switch ktype
    case 'point'
        set(handles.insertnan,'Enable','off');
        newstl = auxstyle;
    case 'line'
        newstl = [auxstyle '+'];
    case 'area'
        newstl = '-+';
end

if length(varargin) ==  7 && varargin{7} == 0
    set(handles.insertnan,'Enable','off');
end

handles.aux = plot(auxpos(:,2),auxpos(:,1),auxstyle,'Color',auxcolor);
handles.new = plot(NaN,NaN,newstl,'Color',auxcolor);
handles.ref = plot(NaN,NaN,'+r','MarkerSize',8);

handles.ok = 0;

guidata(hObject, handles);

type_sel_Callback(hObject, eventdata, handles);
ref_sel_Callback(hObject, eventdata, handles);
fit_Callback(hObject, eventdata, handles);

uiwait(handles.window);

% ---------------------------------------------------------------------
function varargout = RDAT_LineCompute_OutputFcn(hObject, eventdata, handles) 
% Funçao de saida

if handles.ok
    varargout{1} = getappdata(handles.window,'newpos');
else
    varargout{1} = [];
end
delete(handles.window);

% ---------------------------------------------------------------------
function window_CloseRequestFcn(hObject, eventdata, handles)
% Funçao de fechamento da janela

cancel_btn_Callback(hObject, eventdata, handles);

% --------------------------------------------------------------------
function window_WindowButtonMotionFcn(hObject, eventdata, handles)
% Funçao executada ao se mover o mouse

cp = get(handles.window,'CurrentPoint') + [.5 .5];
ng = 0;

ap = get(handles.TSD,'Position');
ax = get(handles.TSD,'XLim');
ay = get(handles.TSD,'YLim');

x = (cp(1)-ap(1))*(ax(2)-ax(1))/ap(3) + ax(1);
y = (cp(2)-ap(2))*(ay(2)-ay(1))/ap(4) + ay(1);

if x >= ax(1) && x <= ax(2) && y >= ay(1) && y <= ay(2);
    ng = 1;
end

% Tipo do cursor
if ng
    set(handles.window,'Pointer','crosshair');
else
    set(handles.window,'Pointer','arrow');
end

% Posiçao do cursor
if ng
    latstr = deg2latlong(y,1,3);
    lonstr = deg2latlong(x,2,3);
    magvar = intp2(y,x,getappdata(handles.window,'Dmaggrid'),0);
    if ~isnan(magvar)
        varstr = [num2str(magvar,'%2.1f') '°'];
    else
        varstr = '';
    end
else
    latstr = '';
    lonstr = '';
    varstr = '';
end

set(handles.lat,'String',latstr);
set(handles.lon,'String',lonstr);
set(handles.var,'String',varstr);

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
        
end

% --------------------------------------------------------------------
function fit_Callback(hObject, eventdata, handles)
% Ajusta o zoom

Xaux = get(handles.aux,'XData');
Yaux = get(handles.aux,'YData');

Xref = get(handles.ref,'XData');
Yref = get(handles.ref,'YData');

Xnew = get(handles.new,'XData');
Ynew = get(handles.new,'YData');

if get(handles.fitall_btn,'Value');
    X = [Xaux Xref Xnew];
    Y = [Yaux Yref Ynew];
else
    X = [Xref Xnew];
    Y = [Yref Ynew];
end

exc = isnan(X+Y);
X(exc) = [];
Y(exc) = [];

x0 = -46;
y0 = -23;

if isempty(X)
    xmin = x0;
    xmax = x0;
    ymin = y0;
    ymax = y0;
else
    xmin = min(X);
    xmax = max(X);
    ymin = min(Y);
    ymax = max(Y);
end

if isnan(xmin), xmin = x0-1; end
if isnan(xmax), xmax = x0+1; end
if isnan(ymin), ymin = y0-1; end
if isnan(ymax), ymax = y0+1; end

ax = xmax - xmin;
ay = ymax - ymin;

d = .02;

if ax < d && ay < d
    xmin = xmin - d/2;
    xmax = xmax + d/2;
    ymin = ymin - d/2;
    ymax = ymax + d/2;
elseif ax < d
    xmin = xmin - ay/2;
    xmax = xmax + ay/2;
end
if ay < d
    ymin = ymin - ax/2;
    ymax = ymax + ax/2;
end

xmin = xmin-.1*ax;
xmax = xmax+.1*ax;
ymin = ymin-.1*ay;
ymax = ymax+.1*ay;

ax = xmax - xmin;
ay = ymax - ymin;

pos = get(handles.TSD,'Position');
Tw = pos(3);
Th = pos(4);

if Tw/ax > Th/ay
    dy = [ymin ymax];
    dx = mean([xmin xmax]) + .5*[-1 1]*ay*Tw/Th ;
else
    dx = [xmin xmax];
    dy = mean([ymin ymax]) + .5*[-1 1]*ax*Th/Tw ;
end

set(handles.TSD,'XLim',dx,'YLim',dy);

% ---------------------------------------------------------------------
function ok_btn_Callback(hObject, eventdata, handles)
% Botao OK

newpos = cell2mat(getappdata(handles.window,'newpos')');
k = size(newpos,1);

if ~k
    beep; uiwait(errordlg('Não há dados computados.','Erro','modal'));
    return
elseif k == 1
    button = questdlg('Deseja confirmar a inserção de 1 ponto computado?','Confirmação','Sim','Não','Sim');
else
    
    % Excluir pontos repetidos
    exc = diff(newpos(:,1)) == 0 & diff(newpos(:,2)) == 0;
    newpos(exc,:) = [];
    e = length(find(exc));
    
    if e
        button = questdlg({['Deseja confirmar a inserção de ' num2str(k-e) ' pontos computados?'],...
                ['(' num2str(e) ' pontos repetidos foram excluídos)']},'Confirmação','Sim','Não','Sim');
    else
        button = questdlg(['Deseja confirmar a inserção de ' num2str(k) ' pontos computados?'],'Confirmação','Sim','Não','Sim');
    end
    
end
if strcmp(button,'Sim')
    setappdata(handles.window,'newpos',newpos);
    handles.ok = 1;
    guidata(hObject, handles);
    uiresume;
end

% ---------------------------------------------------------------------
function cancel_btn_Callback(hObject, eventdata, handles)
% Botao Cancela

newpos = cell2mat(getappdata(handles.window,'newpos')');
k = size(newpos,1);

if ~k
    button = 'Sim';
else
    button = questdlg('Deseja descartar a inserção?','Confirmação','Sim','Não','Não');
end
if strcmp(button,'Sim')
    uiresume;
end

% ---------------------------------------------------------------------
function type_sel_Callback(hObject, eventdata, handles)
% Seleciona tipo de linha

nref  = get(handles.ref_sel,'Value');
ntype = get(handles.type_sel,'Value');
N = getappdata(handles.window,'N');
newpos = getappdata(handles.window,'newpos');

if N == 1
    POS = handles.auxpos;
else
    POS = [handles.auxpos; cell2mat(newpos(1:N-1)')];
end

if nref == 2 && ( ntype == 1 ||  ntype == 3 || ntype == 4 )
    Dmag = handles.Dmag;
    if size(POS,1) > 1
        [DE, DN] = latlong2dxdy(POS(end-1,1),POS(end-1,2),POS(end,1),POS(end,2));
        psi0 = mod((180/pi*atan2(DE,DN)-Dmag),360);
        if isnan(psi0)
            psi0 = 0;
        end
    else
        psi0 = 0;
    end
else
    psi0 = 0;
end

switch ntype
    case 1 % ponto
        Rdl = psi0;
        T   = 1;
        Zp  = 5000;
        Vc  = 200;
        Disa = 15;
        M = qcpa2m(vc2qc(Vc),zp2pa(Zp));
        D = distcalc(Zp,Vc,T,Disa);
        [DE, DN] = RdlDist2DeDn(Rdl,D,handles.Dmag);
        txtlist = {'Rdl'      ,'Dist','DE','DN',''   ,'Zp','Vc' ,'M' ,'Tempo','Disa'};
        tiplist = {'graus mag','NM'  ,'NM','NM',''   ,'ft','200',''  ,'min'  ,'°C'  };
        datlist = [ Rdl       , D    , DE ,DN  , 0   , Zp , Vc  , M  , T     , Disa ];
        vislist = {'on'       ,'on'  ,'on','on','off','on','on' ,'on','on'   ,'on'  };
    case 2 % arco
        txtlist = {'Rdl 1'    ,'Rdl 2'    ,'Raio','Passo',''   ,''   ,''   ,''   ,''   ,''   };
        tiplist = {'graus mag','graus mag','NM'  ,'graus',''   ,''   ,''   ,''   ,''   ,''   };
        datlist = [ 0         , 90        , 1    , 10    , 0   , 0   , 0   , 0   , 0   , 0   ];
        vislist = {'on'       ,'on'       ,'on'  ,'on'   ,'off','off','off','off','off','off'};
    case 3 % curva
        Zp = 5000;
        Vc = 200;
        M = qcpa2m(vc2qc(Vc),zp2pa(Zp));
        Phi = 45;
        Disa = 15;
        R = radiuscalc(Zp,Vc,Phi,Disa);
        txtlist = {'Psi 0'    ,'D psi','Passo','Raio',''   ,'Zp'  ,'Vc','M' ,'Phi'  ,'Disa'};
        tiplist = {'graus mag','graus','graus','NM'  ,''   ,'ft'  ,'kt',''  ,'graus','°C'  };
        datlist = [ psi0      , 90    , 10    , R    , 0   , Zp   , Vc , M  , Phi   , Disa ];
        vislist = {'on'       ,'on'   ,'on'   ,'on'  ,'off','on'  ,'on','on','on'   ,'on'  };
    case 4 % orbita
        T = 1;
        Zp = 5000;
        Vc = 200;
        M = qcpa2m(vc2qc(Vc),zp2pa(Zp));
        Phi = 45;
        Disa = 15;
        D = distcalc(Zp,Vc,T,Disa);
        R = radiuscalc(Zp,Vc,Phi,Disa);
        txtlist = {'Psi 0'    ,'Dist','Tempo','Passo','Raio','Zp'  ,'Vc','M' ,'Phi'  ,'Disa'};
        tiplist = {'graus mag','NM'  ,'min'  ,'graus','NM'  ,'ft'  ,'kt',''  ,'graus','°C'  };
        datlist = [ psi0      , D    , T     , 10    , R    , Zp   , Vc , M  , Phi   , Disa ];
        vislist = {'on'       ,'on'  ,'on'   ,'on'   ,'on'  ,'on'  ,'on','on','on'   ,'on'  };
        
end

for n = 1:length(txtlist)
    set(handles.txtlist(n),'String',txtlist{n},'TooltipString',tiplist{n},'Visible',vislist{n});
    set(handles.entrylist(n),'Visible',vislist{n});
    if strcmp(txtlist{n},'Tempo')
        settime(handles.entrylist(n),datlist(n));
    else
        setval(handles.entrylist(n),datlist(n));
    end
end

compute(hObject, eventdata, handles);

% ---------------------------------------------------------------------
function ref_sel_Callback(hObject, eventdata, handles)
% Seleciona o ponto de referencia

nref  = get(handles.ref_sel,'Value');
ntype = get(handles.type_sel,'Value');
N = getappdata(handles.window,'N');
newpos = getappdata(handles.window,'newpos');

if N == 1
    POS = handles.auxpos;
else
    POS = [handles.auxpos; cell2mat(newpos(1:N-1)')];
end

switch nref
    case 1 % vazio
        set([handles.lat0_entry handles.lon0_entry],'String','');
    case 2 % ponto anterior
        if isempty(POS)
            set([handles.lat0_entry handles.lon0_entry],'String','');
            set(handles.ref_sel,'Value',1);
        else
            n = max(find(~isnan(POS(:,1))));
            if ~isempty(n)
                set(handles.lat0_entry,'String',deg2latlong(POS(n,1),1,3));
                set(handles.lon0_entry,'String',deg2latlong(POS(n,2),2,3));
            else
                set([handles.lat0_entry handles.lon0_entry],'String','');
            end
        end
    otherwise % Waypoint
        set(handles.lat0_entry,'String',deg2latlong(handles.wptpos(nref-2,1),1,3));
        set(handles.lon0_entry,'String',deg2latlong(handles.wptpos(nref-2,2),2,3));
end

if nref == 2 && ( ntype == 1 ||  ntype == 3 || ntype == 4 )
    Dmag = handles.Dmag;
    if size(POS,1) > 1
        [DE, DN] = latlong2dxdy(POS(end-1,1),POS(end-1,2),POS(end,1),POS(end,2));
        psi0 = mod((180/pi*atan2(DE,DN)-Dmag),360);
        if ~isnan(psi0)
            set(handles.entry1,'String',num2str(psi0));
            entry1_Callback(hObject, eventdata, handles);
        end
    end
end

compute(hObject, eventdata, handles);

% ---------------------------------------------------------------------
function lat0_entry_Callback(hObject, eventdata, handles)
% Latitude de referencia

set(handles.ref_sel,'Value',1);

[void, lat] = latlongread(get(handles.lat0_entry,'String'),1);

if isempty(lat) || ( ~isnan(lat) && (lat<-180 || lat>180) )
    lat = NaN;
end

set(handles.lat0_entry,'String',deg2latlong(lat,1,3));

compute(hObject, eventdata, handles);

% ---------------------------------------------------------------------
function lon0_entry_Callback(hObject, eventdata, handles)
% Longitude de referencia

set(handles.ref_sel,'Value',1);

[void, lon] = latlongread(get(handles.lon0_entry,'String'),1);

if isempty(lon) || ( ~isnan(lon) && (lon<-180 || lon>180) )
    lon = NaN;
end

set(handles.lon0_entry,'String',deg2latlong(lon,2,3));

compute(hObject, eventdata, handles);

% ---------------------------------------------------------------------
function insertnan_Callback(hObject, eventdata, handles)
% Inserir ponto separador

compute(hObject, eventdata, handles);

% ---------------------------------------------------------------------
function compute(hObject, eventdata, handles)
% Calcula a curva

ntype  = get(handles.type_sel,'Value');
newpos = getappdata(handles.window,'newpos');
N      = getappdata(handles.window,'N');
Dmag = handles.Dmag;

[void, lat0] = latlongread(get(handles.lat0_entry,'String'),1);
[void, lon0] = latlongread(get(handles.lon0_entry,'String'),2);

if isempty(lat0) || isempty(lon0) || isnan(lat0+lon0)
    lat0 = NaN;
    lon0 = NaN;
    lat  = [];
    lon  = [];
    
else
    
    switch ntype
        
        case 1 % ponto
            DE = getval(handles.entry3);
            DN = getval(handles.entry4);
            
            if ~isnan(DE+DN)
                [lat, lon] = dxdy2latlong(lat0,lon0,DN*1852,DE*1852);
            else
                lat = [];
                lon = [];
            end
            
        case 2 % arco
            R1 = getval(handles.entry1);
            R2 = getval(handles.entry2);
            D  = getval(handles.entry3);
            dg = getval(handles.entry4);
            
            if ~isnan(R1+R2+D+dg)
                if R1 == R2
                    R = R1;
                elseif R1 < R2
                    R = (R1:dg:R2)';
                    if R(end) ~= R2
                        R(end+1) = R2;
                    end
                elseif R1 > R2
                    R = (R2:dg:R1)';
                    if R(end) ~= R1
                        R(end+1) = R1;
                    end
                end
                D = D*ones(size(R));
                [DE, DN]   = RdlDist2DeDn(R,D,Dmag);
                
                [lat, lon] = dxdy2latlong(lat0,lon0,DN*1852,DE*1852);
            else
                lat = [];
                lon = [];
            end
            
        case 3 % curva
            psi0 = getval(handles.entry1);
            Dpsi = getval(handles.entry2);
            dg   = getval(handles.entry3);
            R    = getval(handles.entry4);
            
            if ~isnan(psi0+Dpsi+dg+R)
                if Dpsi >= 0
                    P = 0:dg:Dpsi;
                else
                    P = 0:dg:-Dpsi;
                end
                if isempty(P)
                    P = 0;
                end
                if P(end) ~= abs(Dpsi)
                    P(end+1) = abs(Dpsi);
                end
                x = sign(Dpsi)*(R - R*cos(P*pi/180)');
                y = R*sin(P*pi/180)';
                
                e = (psi0 + Dmag)*pi/180;
                DE =  x*cos(e) + y*sin(e);
                DN = -x*sin(e) + y*cos(e);
                
                [lat, lon] = dxdy2latlong(lat0,lon0,DN*1852,DE*1852);
            else
                lat = [];
                lon = [];
            end
            
        case 4 % orbita
            psi0 = getval(handles.entry1);
            D    = getval(handles.entry2);
            dg   = getval(handles.entry4);
            R    = getval(handles.entry5);
            Phi  = getval(handles.entry9);
            
            if ~isnan(psi0+D+dg+R+Phi)
                lat1 = lat0;
                lon1 = lon0;
                
                [DE, DN]     = RdlDist2DeDn(psi0,D,Dmag);
                [lat2, lon2] = dxdy2latlong(lat0,lon0,DN*1852,DE*1852);
                
                P = dg:dg:180;
                if P(end) ~= 180
                    P(end+1) = 180;
                end
                
                x = sign(Phi)*(R - R*cos(P*pi/180)');
                y = R*sin(P*pi/180)';
                
                e = (psi0 + Dmag)*pi/180;
                DE =  x*cos(e) + y*sin(e);
                DN = -x*sin(e) + y*cos(e);
                
                [lat3, lon3] = dxdy2latlong(lat2,lon2,DN*1852,DE*1852);
                
                [DE, DN]     = RdlDist2DeDn(psi0+180,D,Dmag);
                [lat4, lon4] = dxdy2latlong(lat3(end),lon3(end),DN*1852,DE*1852);
                
                x = sign(Phi)*(R - R*cos(P*pi/180)');
                y = R*sin(P*pi/180)';
                
                e = (psi0+180 + Dmag)*pi/180;
                DE =  x*cos(e) + y*sin(e);
                DN = -x*sin(e) + y*cos(e);
                
                [lat5, lon5] = dxdy2latlong(lat4,lon4,DN*1852,DE*1852);
                
                lat = [lat1; lat2; lat3; lat4; lat5];
                lon = [lon1; lon2; lon3; lon4; lon5];
            else
                lat = [];
                lon = [];
            end
            
    end
end

if ~isempty(lat) && get(handles.insertnan,'Value') && ( ~isempty(handles.auxpos) || N>1 )
    lat = [NaN; lat];
    lon = [NaN; lon];
end

lat(lat<-90)  = -90;
lat(lat> 90)  =  90;
lon(lon<-180) = -180;
lon(lon> 180) =  180;

lat = round(lat*60*1000)/60000;
lon = round(lon*60*1000)/60000;

newpos{N} = [lat lon];

POS = cell2mat(newpos');
if isempty(POS)
    LAT = [];
    LON = [];
else
    LAT = POS(:,1);
    LON = POS(:,2);
end

if isempty(LAT)
    lat1 = [];
    lon1 = [];
else
    lat1 = LAT(1);
    lon1 = LON(1);
end

if isempty(handles.auxpos)
    auxlat = [];
    auxlon = [];
else
    auxlat = handles.auxpos(:,1);
    auxlon = handles.auxpos(:,2);
end 

% Plot update
set(handles.aux,'XData',[auxlon; lon1],'YData',[auxlat; lat1]);
set(handles.ref,'XData',lon0,'YData',lat0);
set(handles.new,'XData',LON,'YData',LAT);

set(handles.npts_txt,'String',['Trechos: ' num2str(N) ', Pontos: ' num2str(length(LAT))]);

setappdata(handles.window,'newpos',newpos);
fit_Callback(hObject, eventdata, handles);

% ---------------------------------------------------------------------
function entry1_Callback(hObject, eventdata, handles)
% Entrada de dados nº 1

switch get(handles.type_sel,'Value')
    
    case 1 % ponto (Rdl)
        Rdl  = mod(getval(handles.entry1,-360,360,0),360);
        D    = getval(handles.entry2);
        [DE, DN] = RdlDist2DeDn(Rdl,D,handles.Dmag);
        setval(handles.entry1,Rdl);
        setval(handles.entry3,DE);
        setval(handles.entry4,DN);
        
    case 2 % arco (Rdl 1)
        Rdl1 = getval(handles.entry1,-360,360,0);
        setval(handles.entry1,Rdl1);
        
    case 3 % curva (Psi 0)
        Psi0 = mod(getval(handles.entry1,-360,360,0),360);
        setval(handles.entry1,Psi0);
        
    case 4 % orbita (phi 0)
        Psi0 = mod(getval(handles.entry1,-360,360,0),360);
        setval(handles.entry1,Psi0);
        
end

compute(hObject, eventdata, handles);

% ---------------------------------------------------------------------
function entry2_Callback(hObject, eventdata, handles)
% Entrada de dados nº 2

switch get(handles.type_sel,'Value')
    
    case 1 % ponto (D)
        Rdl  = getval(handles.entry1);
        D    = getval(handles.entry2,-300,300,0);
        Zp   = getval(handles.entry6);
        Vc   = getval(handles.entry7);
        Disa = getval(handles.entry10);
        [DE, DN] = RdlDist2DeDn(Rdl,D,handles.Dmag);
        T        = timecalc(Zp,Vc,D,Disa);
        setval(handles.entry2,D);
        setval(handles.entry3,DE);
        setval(handles.entry4,DN);
        settime(handles.entry9,T);
        
    case 2 % arco (Rdl 2)
        Rdl2 = getval(handles.entry2,-360,360,0);
        setval(handles.entry2,Rdl2);
        
    case 3 % curva (Dpsi)
        Dpsi = getval(handles.entry2,-360,360,0);
        Phi  = getval(handles.entry9);
        if Dpsi, Phi = sign(Dpsi)*abs(Phi); end
        setval(handles.entry2,Dpsi);
        setval(handles.entry9,Phi);
        
    case 4 % orbita (D)
        D    = getval(handles.entry2,0,10,2);
        Zp   = getval(handles.entry6);
        Vc   = getval(handles.entry7);
        Disa = getval(handles.entry10);
        T = timecalc(Zp,Vc,D,Disa);
        setval(handles.entry2,D);
        settime(handles.entry3,T);
        
end

compute(hObject, eventdata, handles);

% ---------------------------------------------------------------------
function entry3_Callback(hObject, eventdata, handles)
% Entrada de dados nº 3

switch get(handles.type_sel,'Value')
    
    case 1 % ponto (DE)
        DE   = getval(handles.entry3,-300,300,0);
        DN   = getval(handles.entry4);
        Zp   = getval(handles.entry6);
        Vc   = getval(handles.entry7);
        Disa = getval(handles.entry10);
        [Rdl, D] = DeDn2RdlDist(DE,DN,handles.Dmag);
        T        = timecalc(Zp,Vc,D,Disa);
        setval(handles.entry1,Rdl);
        setval(handles.entry2,D);
        setval(handles.entry3,DE);
        settime(handles.entry9,T);
        
    case 2 % arco (Raio)
        R = getval(handles.entry3,0,300,0);
        setval(handles.entry3,R);
        
    case 3 % curva (step)
        dg = getval(handles.entry3,2,90,10);
        setval(handles.entry3,dg);
        
    case 4 % orbita (T)
        T    = gettime(handles.entry3,0,10,1);
        Zp   = getval(handles.entry6);
        Vc   = getval(handles.entry7);
        Disa = getval(handles.entry10);
        D = distcalc(Zp,Vc,T,Disa);
        setval(handles.entry2,D);
        settime(handles.entry3,T);
        
end

compute(hObject, eventdata, handles);

% ---------------------------------------------------------------------
function entry4_Callback(hObject, eventdata, handles)
% Entrada de dados nº 4

switch get(handles.type_sel,'Value')
    
    case 1 % ponto (DN)
        DE   = getval(handles.entry3);
        DN   = getval(handles.entry4,-300,300,0);
        Zp   = getval(handles.entry6);
        Vc   = getval(handles.entry7);
        Disa = getval(handles.entry10);
        [Rdl, D] = DeDn2RdlDist(DE,DN,handles.Dmag);
        T        = timecalc(Zp,Vc,D,Disa);
        setval(handles.entry1,Rdl);
        setval(handles.entry2,D);
        setval(handles.entry4,DN);
        settime(handles.entry9,T);
        
    case 2 % arco (step)
        dg = getval(handles.entry4,2,90,10);
        setval(handles.entry4,dg);
        
    case 3 % curva (Raio)
        R    = getval(handles.entry4,.1,30,0);
        Zp   = getval(handles.entry6);
        Vc   = getval(handles.entry7);
        Phi  = getval(handles.entry9);
        Disa = getval(handles.entry10);
        Phi  = sign(Phi)*phicalc(Zp,Vc,R,Disa);
        setval(handles.entry4,R);
        setval(handles.entry9,Phi);
        
    case 4 % orbita (Passo)
        dg = getval(handles.entry4,2,90,10);
        setval(handles.entry4,dg);
        
end

compute(hObject, eventdata, handles);

% ---------------------------------------------------------------------
function entry5_Callback(hObject, eventdata, handles)
% Entrada de dados nº 5

switch get(handles.type_sel,'Value')
    case 1 % ponto
        % Sem funçao
        
    case 2 % arco
        % Sem funçao
        
    case 3 % curva
        % Sem funçao
        
    case 4 % orbita (Raio)
        R    = getval(handles.entry5,.1,30,0);
        Zp   = getval(handles.entry6);
        Vc   = getval(handles.entry7);
        Phi  = getval(handles.entry9);
        Disa = getval(handles.entry10);
        Phi  = sign(Phi)*phicalc(Zp,Vc,R,Disa);
        setval(handles.entry5,R);
        setval(handles.entry9,Phi);
        
end

compute(hObject, eventdata, handles);

% ---------------------------------------------------------------------
function entry6_Callback(hObject, eventdata, handles)
% Entrada de dados nº 6

switch get(handles.type_sel,'Value')
    
    case 1 % ponto (Zp)
        Rdl  = getval(handles.entry1);
        Zp   = getval(handles.entry6,-2000,100000,5000);
        Vc   = getval(handles.entry7);
        M    = qcpa2m(vc2qc(Vc),zp2pa(Zp));
        T    = getval(handles.entry9);
        Disa = getval(handles.entry10);
        D    = distcalc(Zp,Vc,T,Disa);
        [DE, DN] = RdlDist2DeDn(Rdl,D,handles.Dmag);
        setval(handles.entry2,D);
        setval(handles.entry3,DE);
        setval(handles.entry4,DN);
        setval(handles.entry6,Zp);
        setval(handles.entry8,M);
        
    case 2 % arco
        % Sem funçao
        
    case 3 % curva (Zp)
        Zp   = getval(handles.entry6,-2000,100000,5000);
        Vc   = getval(handles.entry7);
        M    = qcpa2m(vc2qc(Vc),zp2pa(Zp));
        Phi  = getval(handles.entry9);
        Disa = getval(handles.entry10);
        R    = radiuscalc(Zp,Vc,Phi,Disa);
        setval(handles.entry6,Zp);
        setval(handles.entry8,M);
        setval(handles.entry4,R);
        
    case 4 % orbita (Zp)
        T    = getval(handles.entry3);
        Zp   = getval(handles.entry6,-2000,100000,5000);
        Vc   = getval(handles.entry7);
        M    = qcpa2m(vc2qc(Vc),zp2pa(Zp));
        Phi  = getval(handles.entry9);
        Disa = getval(handles.entry10);
        R    = radiuscalc(Zp,Vc,Phi,Disa);
        D    = distcalc(Zp,Vc,T,Disa);
        setval(handles.entry2,D);
        setval(handles.entry6,Zp);
        setval(handles.entry8,M);
        setval(handles.entry5,R);
        
end

compute(hObject, eventdata, handles);

% ---------------------------------------------------------------------
function entry7_Callback(hObject, eventdata, handles)
% Entrada de dados nº 7

switch get(handles.type_sel,'Value')
    
    case 1 % ponto (Vc)
        Rdl  = getval(handles.entry1);
        Zp   = getval(handles.entry6);
        Vc   = getval(handles.entry7,50,1000,200);
        M    = qcpa2m(vc2qc(Vc),zp2pa(Zp));
        T    = getval(handles.entry9);
        Disa = getval(handles.entry10);
        D    = distcalc(Zp,Vc,T,Disa);
        [DE, DN] = RdlDist2DeDn(Rdl,D,handles.Dmag);
        setval(handles.entry2,D);
        setval(handles.entry3,DE);
        setval(handles.entry4,DN);
        setval(handles.entry7,Vc);
        setval(handles.entry8,M);
        
    case 2 % arco
        % Sem funçao
        
    case 3 % curva (Vc)
        Zp   = getval(handles.entry6);
        Vc   = getval(handles.entry7,50,1000,200);
        M    = qcpa2m(vc2qc(Vc),zp2pa(Zp));
        Phi  = getval(handles.entry9);
        Disa = getval(handles.entry10);
        R    = radiuscalc(Zp,Vc,Phi,Disa);
        setval(handles.entry7,Vc);
        setval(handles.entry8,M);
        setval(handles.entry4,R);
        
    case 4 % orbita (Vc)
        T    = getval(handles.entry3);
        Zp   = getval(handles.entry6);
        Vc   = getval(handles.entry7,50,1000,200);
        M    = qcpa2m(vc2qc(Vc),zp2pa(Zp));
        Phi  = getval(handles.entry9);
        Disa = getval(handles.entry10);
        R    = radiuscalc(Zp,Vc,Phi,Disa);
        D    = distcalc(Zp,Vc,T,Disa);
        setval(handles.entry2,D);
        setval(handles.entry7,Vc);
        setval(handles.entry8,M);
        setval(handles.entry5,R);
        
end

compute(hObject, eventdata, handles);

% ---------------------------------------------------------------------
function entry8_Callback(hObject, eventdata, handles)
% Entrada de dados nº 8

switch get(handles.type_sel,'Value')
    
    case 1 % ponto (M)
        Rdl  = getval(handles.entry1);
        Zp   = getval(handles.entry6);
        M    = getval(handles.entry8,.1,2,.4);
        Vc   = qc2vc(m2qcpa(M)*zp2pa(Zp));
        T    = getval(handles.entry9);
        Disa = getval(handles.entry10);
        D    = distcalc(Zp,Vc,T,Disa);
        [DE, DN] = RdlDist2DeDn(Rdl,D,handles.Dmag);
        setval(handles.entry2,D);
        setval(handles.entry3,DE);
        setval(handles.entry4,DN);
        setval(handles.entry7,Vc);
        setval(handles.entry8,M);
        
    case 2 % arco
        % Sem funçao
        
    case 3 % curva (M)
        Zp   = getval(handles.entry6);
        M    = getval(handles.entry8,.1,2,.4);
        Vc   = qc2vc(m2qcpa(M)*zp2pa(Zp));
        Phi  = getval(handles.entry9);
        Disa = getval(handles.entry10);
        R    = radiuscalc(Zp,Vc,Phi,Disa);
        setval(handles.entry7,Vc);
        setval(handles.entry8,M);
        setval(handles.entry4,R);
        
    case 4 % orbita (M)
        T    = getval(handles.entry3);
        Zp   = getval(handles.entry6);
        M    = getval(handles.entry8,.1,2,.4);
        Vc   = qc2vc(m2qcpa(M)*zp2pa(Zp));
        Phi  = getval(handles.entry9);
        Disa = getval(handles.entry10);
        R    = radiuscalc(Zp,Vc,Phi,Disa);
        D    = distcalc(Zp,Vc,T,Disa);
        setval(handles.entry2,D);
        setval(handles.entry7,Vc);
        setval(handles.entry8,M);
        setval(handles.entry5,R);
        
end

compute(hObject, eventdata, handles);

% --------------------------------------------------------------------
function entry9_Callback(hObject, eventdata, handles)
% Entrada de dados nº 9

switch get(handles.type_sel,'Value')
    
    case 1 % ponto (T)
        Rdl  = getval(handles.entry1);
        Zp   = getval(handles.entry6);
        Vc   = getval(handles.entry7);
        T    = gettime(handles.entry9,0,60,1);
        Disa = getval(handles.entry10);
        D    = distcalc(Zp,Vc,T,Disa);
        [DE, DN] = RdlDist2DeDn(Rdl,D,handles.Dmag);
        setval(handles.entry2,D);
        setval(handles.entry3,DE);
        setval(handles.entry4,DN);
        settime(handles.entry9,T);
        
    case 2 % arco
        % Sem funçao
        
    case 3 % curva (Phi)
        Dpsi = getval(handles.entry2);
        Zp   = getval(handles.entry6);
        Vc   = getval(handles.entry7);
        Phi  = getval(handles.entry9,-85,85,45);
        if Phi <  0, Phi = min(Phi,-10); end
        if Phi >= 0, Phi = max(Phi, 10); end
        Disa = getval(handles.entry10);
        R    = radiuscalc(Zp,Vc,Phi,Disa);
        Dpsi = sign(Phi)*abs(Dpsi);
        setval(handles.entry2,Dpsi);
        setval(handles.entry9,Phi);
        setval(handles.entry4,R);
        
    case 4 % orbita (Phi)
        Zp   = getval(handles.entry6);
        Vc   = getval(handles.entry7);
        Phi  = getval(handles.entry9,-85,85,45);
        if Phi <  0, Phi = min(Phi,-10); end
        if Phi >= 0, Phi = max(Phi, 10); end
        Disa = getval(handles.entry10);
        R    = radiuscalc(Zp,Vc,Phi,Disa);
        setval(handles.entry9,Phi);
        setval(handles.entry5,R);
        
end

compute(hObject, eventdata, handles);

% --------------------------------------------------------------------
function entry10_Callback(hObject, eventdata, handles)
% Entrada de dados nº 10

switch get(handles.type_sel,'Value')
    
    case 1 % ponto (Disa)
        Rdl  = getval(handles.entry1);
        Zp   = getval(handles.entry6);
        Vc   = getval(handles.entry7);
        T    = getval(handles.entry9);
        Disa = getval(handles.entry10,-30,40,15);
        D    = distcalc(Zp,Vc,T,Disa);
        [DE, DN] = RdlDist2DeDn(Rdl,D,handles.Dmag);
        setval(handles.entry1,D);
        setval(handles.entry3,DE);
        setval(handles.entry4,DN);
        setval(handles.entry10,Disa);
        
    case 2 % arco
        % Sem funçao
        
    case 3 % curva (Disa)
        Zp   = getval(handles.entry6);
        Vc   = getval(handles.entry7);
        Phi  = getval(handles.entry9);
        Disa = getval(handles.entry10,-30,40,15);
        R    = radiuscalc(Zp,Vc,Phi,Disa);
        setval(handles.entry4,R);
        setval(handles.entry10,Disa);
        
    case 4 % orbita (Disa)
        T    = getval(handles.entry3);
        Zp   = getval(handles.entry6);
        Vc   = getval(handles.entry7);
        Phi  = getval(handles.entry9);
        Disa = getval(handles.entry10,-30,40,15);
        R    = radiuscalc(Zp,Vc,Phi,Disa);
        D    = distcalc(Zp,Vc,T,Disa);
        setval(handles.entry2,D);
        setval(handles.entry5,R);
        setval(handles.entry10,Disa);
        
end

compute(hObject, eventdata, handles);

% --------------------------------------------------------------------
function clear_btn_Callback(hObject, eventdata, handles)
% Limpar tudo

button = questdlg('Deseja limpar todos os dados?','Confirmação','Sim','Não','Não'); drawnow;
if ~strcmp(button,'Sim')
    return
end

setappdata(handles.window,'newpos',{[]});
setappdata(handles.window,'N',1);
set(handles.type_sel,'Value',1)

set(handles.type_sel,'Value',1)
type_sel_Callback(hObject, eventdata, handles);
ref_sel_Callback(hObject, eventdata, handles);

% --------------------------------------------------------------------
function fitall_btn_Callback(hObject, eventdata, handles)
% Ajustar zoom total

set(handles.fitnew_btn,'Value',0);
set(handles.fitall_btn,'Value',1);
fit_Callback(hObject, eventdata, handles);

% --------------------------------------------------------------------
function fitnew_btn_Callback(hObject, eventdata, handles)
% Ajustar zoom à curva nova

set(handles.fitnew_btn,'Value',1);
set(handles.fitall_btn,'Value',0);
fit_Callback(hObject, eventdata, handles);

% --------------------------------------------------------------------
function prev_btn_Callback(hObject, eventdata, handles)
% Retroceder trecho

N = getappdata(handles.window,'N');

if N == 1
    beep;
    return
end

button = questdlg('Deseja apagar o trecho anterior?','Confirmação','Sim','Não','Sim'); drawnow;
if ~strcmp(button,'Sim')
    return
end

newpos = getappdata(handles.window,'newpos');
newpos(N) = [];

setappdata(handles.window,'N',N-1);
setappdata(handles.window,'newpos',newpos);

set(handles.type_sel,'Value',1)
type_sel_Callback(hObject, eventdata, handles);
ref_sel_Callback(hObject, eventdata, handles);

% --------------------------------------------------------------------
function next_btn_Callback(hObject, eventdata, handles)
% Novo trecho

button = questdlg('Deseja criar novo trecho?','Confirmação','Sim','Não','Sim'); drawnow;
if ~strcmp(button,'Sim')
    return
end

N = getappdata(handles.window,'N');
newpos = getappdata(handles.window,'newpos');
newpos{N+1} = [];

setappdata(handles.window,'N',N+1);
setappdata(handles.window,'newpos',newpos);

set(handles.type_sel,'Value',1)
type_sel_Callback(hObject, eventdata, handles);
ref_sel_Callback(hObject, eventdata, handles);

% --------------------------------------------------------------------
function help_btn_Callback(hObject, eventdata, handles)
% Botao Ajuda

helpme('Ferramentas\linhacalculada');

% --------------------------------------------------------------------
function val = getval(h,vmin,vmax,def)
% Obtem um valor inserido em um campo

if nargin == 1
    val = get(h,'UserData');
    return
end
    
val = str2double(get(h,'String'));

if isnan(val)
    val = def;
else
    val = max(vmin,min(vmax,val));
end

% --------------------------------------------------------------------
function setval(h,val)
% Escreve um valor em um campo

if ischar(val)
    set(h,'String',val);
elseif isnan(val)
    set(h,'String','');
else
    if val < 10000
        p = 4;
    else
        p = fix(log10(val))+1;
    end
    set(h,'String',num2str(roundn(val,-5),p),'UserData',val);
end

% --------------------------------------------------------------------
function val = gettime(h,vmin,vmax,def)
% Obtem em minutos o valor inserido em um campo de tempo mm:ss

if nargin == 1
    val = get(h,'UserData');
    return
end

val = get(h,'String');
val(val==':') = ' ';
val = str2num(val);

if length(val) == 2
    val = val(1)+val(2)/60;
elseif length(val) ~= 1
    val = def;
end

if isnan(val)
    val = def;
else
    val = max(vmin,min(vmax,val));
end

% --------------------------------------------------------------------
function settime(h,val)
% Escreve um valor de tempo mm:ss em um campo

if ischar(val)
    set(h,'String',val);
elseif isnan(val)
    set(h,'String','');
else
    val = round(val*60)/60;
    mm = fix(val);
    ss = fix((val-mm)*60);
    set(h,'String',[num2str(mm) ':' num2str(ss,'%02.0f')],'UserData',val);
end

% --------------------------------------------------------------------
function R = radiuscalc(Zp,Vc,Phi,Disa)
% Calcula raio de curva

pa = zp2pa(Zp); % mb
qc = vc2qc(Vc); % mb
M = qcpa2m(qc,pa);
Phi = abs(Phi); % graus

Ta = zp2ta(Zp); % K
Va = M*sqrt(1.4*287.053*(Ta+Disa)); % m/s
R = (Va^2 / (9.80665*tan(Phi*pi/180))) / 1852; % NM

% --------------------------------------------------------------------
function Phi = phicalc(Zp,Vc,R,Disa)
% Calcula raio de curva

pa = zp2pa(Zp); % mb
qc = vc2qc(Vc); % mb
M = qcpa2m(qc,pa);

Ta = zp2ta(Zp); % K
Va = M*sqrt(1.4*287.053*(Ta+Disa)); % m/s
Phi = atan(Va^2 / (9.80665*R*1852))*180/pi; % graus

% --------------------------------------------------------------------
function D = distcalc(Zp,Vc,T,Disa)
% Calcula distancia da perna

pa = zp2pa(Zp); % mb
qc = vc2qc(Vc); % mb
M = qcpa2m(qc,pa);

Ta = zp2ta(Zp); % K
Va = M*sqrt(1.4*287.053*(Ta+Disa)); % m/s
D = Va*T*60 / 1852; % NM

% --------------------------------------------------------------------
function T = timecalc(Zp,Vc,D,Disa)
% Calcula tempo da perna

pa = zp2pa(Zp); % mb
qc = vc2qc(Vc); % mb
M = qcpa2m(qc,pa);

Ta = zp2ta(Zp); % K
Va = M*sqrt(1.4*287.053*(Ta+Disa)); % m/s
T = D/(Va*60)*1852; % min
