function varargout = RDAT_EditScenario(varargin)
% RDAT_EDITSCENARIO M-file for RDAT_EditScenario.fig
% Last Modified by GUIDE v2.5 14-Mar-2012 15:42:17

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RDAT_EditScenario_OpeningFcn, ...
                   'gui_OutputFcn',  @RDAT_EditScenario_OutputFcn, ...
                   'gui_LayoutFcn',  @RDAT_EditScenario_LayoutFcn, ...
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
function h = RDAT_EditScenario_LayoutFcn(varargin)
% Função de layout inicial

h = openfig('RDAT_EditScenario.fig','reuse','invisible');

% ---------------------------------------------------------------------
function RDAT_EditScenario_OpeningFcn(hObject, eventdata, handles, varargin)
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
set(handles.new_btn,   'CData',geticon('DatButtons.mat','new',   bgc));
set(handles.open_btn,  'CData',geticon('DatButtons.mat','open',  bgc));
set(handles.import_btn,'CData',geticon('DatButtons.mat','import',bgc));
set(handles.save_btn,  'CData',geticon('DatButtons.mat','save',  bgc));
set(handles.export_btn,'CData',geticon('DatButtons.mat','export',bgc));
set(handles.mapdb_btn, 'CData',geticon('DatButtons.mat','maps',  bgc));
set(handles.zoom_btn,  'CData',geticon('DatButtons.mat','zoom',  bgc));
set(handles.drag_btn,  'CData',geticon('DatButtons.mat','drag',  bgc));
set(handles.fit_btn,   'CData',geticon('DatButtons.mat','fit',   bgc));
set(handles.fitobj_btn,'CData',geticon('DatButtons.mat','fit3',  bgc));
set(handles.ruler_btn, 'CData',geticon('DatButtons.mat','ruler', bgc));
set(handles.OpenGL_btn,'CData',geticon('DatButtons.mat','opengl',bgc));
set(handles.help_btn,  'CData',geticon('DatButtons.mat','help',  bgc));
set(handles.sel_map,   'CData',geticon('DatButtons.mat','map',   bgc));
set(handles.sel_aux,   'CData',geticon('DatButtons.mat','aux',   bgc));
set(handles.sel_aid,   'CData',geticon('DatButtons.mat','aid',   bgc));
set(handles.sel_wpt,   'CData',geticon('DatButtons.mat','wpt',   bgc));
set(handles.sel_rt,    'CData',geticon('DatButtons.mat','rt',    bgc));
set(handles.sel_fa,    'CData',geticon('DatButtons.mat','fa',    bgc));
set(handles.sel_avd,   'CData',geticon('DatButtons.mat','avd',   bgc));
set(handles.sel_thr,   'CData',geticon('DatButtons.mat','thr',   bgc));
set(handles.sel_cnt,   'CData',geticon('DatButtons.mat','cnt',   bgc));

set(handles.importobj_btn,                          'CData',geticon('DatButtons.mat','import_s', bgc));
set(handles.exportobj_btn,                          'CData',geticon('DatButtons.mat','import_s', bgc,0,1));
set(handles.addparamlist_btn,                       'CData',geticon('DatButtons.mat','list_s',   bgc));
set([handles.addobj_btn    handles.addparam_btn],   'CData',geticon('DatButtons.mat','add_s',    bgc));
set([handles.insertobj_btn handles.insertparam_btn],'CData',geticon('DatButtons.mat','insert_s', bgc));
set([handles.remobj_btn    handles.remparam_btn],   'CData',geticon('DatButtons.mat','rem_s',    bgc));
set([handles.editobj_btn   handles.editparam_btn],  'CData',geticon('DatButtons.mat','edit_s',   bgc));
set([handles.upobj_btn     handles.upparam_btn],    'CData',geticon('DatButtons.mat','arrow_s',  bgc,1));
set([handles.dnobj_btn     handles.dnparam_btn],    'CData',geticon('DatButtons.mat','arrow_s',  bgc,3,1));
set([handles.getobj_btn    handles.getparam_btn],   'CData',geticon('DatButtons.mat','acquire_s',bgc));

[handles.cursors.drag{1}, handles.cursors.drag_hs{1}] = getcursor('DatCursors.mat', 'hand0');
[handles.cursors.drag{2}, handles.cursors.drag_hs{2}] = getcursor('DatCursors.mat', 'hand1');
[handles.cursors.zoom,    handles.cursors.zoom_hs   ] = getcursor('DatCursors.mat', 'zoom');

handles.sel_list = [handles.sel_map handles.sel_aux handles.sel_aid handles.sel_wpt handles.sel_rt handles.sel_fa handles.sel_avd handles.sel_thr handles.sel_cnt];

setappdata(handles.window,'ntype','map');
setappdata(handles.window,'dragdata',0);
setappdata(handles.window,'prevsize',get(handles.TSD,'Position'));

handles.maxvert = 1000;

if ~isempty(varargin)
    scenario = varargin{1};
else
    scenario = [];
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
else
    scenario = backcompat(scenario,'scenario');
end

set(handles.Dmag_entry,'String',num2str(scenario.Dmag));

% Dmag grid
try
    [latgrid longrid Dmaggrid] = geomag_grid(-40,10,-80,-30,2);
catch
    latgrid  = [0 1]';
    longrid  = [0 1];
    Dmaggrid = [NaN NaN; NaN NaN];
end
setappdata(handles.window,'Dmaggrid',[NaN longrid; latgrid Dmaggrid]);

try
    
    axes(handles.TSD);
    xlabel('Longitude');
    ylabel('Latitude');
    
    % Ruler
    handles.ruler     = plot3([NaN NaN],[NaN NaN],[5 5],'Color','w','Marker','+');
    handles.rulertag1 = text(0, 0, 5,'','Color','w','Visible','off');
    handles.rulertag2 = text(0, 0, 5,'','Color','w','Visible','off');
    
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
    handles.fa        = [];
    handles.falbl     = [];
    handles.avd       = [];
    handles.avdlbl    = [];
    handles.thr       = [];
    handles.thrlbl    = [];
    handles.cnt       = [];
    
    % Decluter
    dclt = {'MAP','VMAP','AUX','AID','WPT','RT','FA','AVD','THR','CNT','LBL'};
    for n = 1:length(dclt)
        y = 1.001-n*.03;
        handles.lbl(n) = text(.99,y,1,dclt{n},'Units','normalized','HorizontalAlignment','right','Color','g','FontSize',8);
        handles.ylbl(n) = y;
    end
    
    % Selection
    hsel = plot3(NaN,NaN,NaN,'sw','MarkerSize',14,'LineWidth',2,'UIContextMenu',handles.selmenu);
    setappdata(handles.window,'hsel',hsel);
    
    handles.ok = 0;
    handles.chg = 0;
    handles.fname = '*.mat';
    handles.fpath = [pwd filesep];
    guidata(hObject, handles);
    
    setscenario(hObject, eventdata, handles, scenario, 'all', 1);
    type_sel(hObject, eventdata, handles);
    
    set(handles.TSD,'XLimMode','manual','YLimMode','manual');
    
    uiwait(handles.window);
    
catch
    handles.ok = 0;
    guidata(hObject, handles);
    uiresume;
end

% ---------------------------------------------------------------------
function varargout = RDAT_EditScenario_OutputFcn(hObject, eventdata, handles) 
% Funçao de saida

if handles.ok
    varargout{1} = getappdata(handles.window,'scenario');
else
    varargout{1} = [];
end
delete(handles.window);

% ---------------------------------------------------------------------
function type_sel(hObject, eventdata, handles, N, M)
% Executada ao se selecionar um tipo de objeto

if nargin == 3
    N = 1;
    M = 1;
elseif nargin == 4
    M = 1;
end

ntype = getappdata(handles.window,'ntype');
scenario = getappdata(handles.window,'scenario');

switch ntype
    case 'map' % Maps
        if isempty(scenario.map)
            objs = '';
            nobjstr = '';
        else
            objs = {scenario.map.name};
            nobjstr = num2str(length(objs));
        end
        objstr = 'Mapas';
        parstr = 'Limites';
        
    case 'aux' % Auxiliary Shapes
        if isempty(scenario.aux)
            objs = '';
            nobjstr = '';
        else
            for n = 1:length(scenario.aux)
                stylestr{n} = style2str(scenario.aux(n).style,1);
                colorstr{n} = style2str(scenario.aux(n).color,2);
                if istype(scenario.aux(n).type,{'text','area'})
                    widthstr{n} = ' ';
                else
                    widthstr{n} = style2str(scenario.aux(n).width,3);
                end
            end
            objs = cell2str([{scenario.aux.name}' stylestr' colorstr' widthstr']);
            nobjstr = num2str(n);
        end
        objstr = 'Objetos auxiliares';
        parstr = 'Vértices';
        
    case 'aid' % Nav Aids
        if isempty(scenario.aid) || isempty(scenario.aid.data)
            objs = '';
            nobjstr = '';
        else
            k = length(scenario.aid.code);
            FT = char( abs(' ft')'*ones(1,k))';
            objs = [char(scenario.aid.code) spc(k,2) char(scenario.aid.type) spc(k,2) ...
                    deg2latlong(scenario.aid.data(:,1),1,3) spc(k,2) deg2latlong(scenario.aid.data(:,2),2,3) spc(k,2) ...
                    num2str(scenario.aid.data(:,3)) FT];
            nobjstr = num2str(k);
        end
        objstr = 'Auxílios / Aeródromos';
        parstr = '';
        
    case 'wpt' % Waypoints
        if isempty(scenario.wpt) || isempty(scenario.wpt.data)
            objs = '';
            nobjstr = '';
        else
            k = length(scenario.wpt.code);
            FT = char( abs(' ft')'*ones(1,k))';
            objs = [num2str(scenario.wpt.data(:,1),'%02.0f') spc(k,1) char(scenario.wpt.code) spc(k,2) ...
                    deg2latlong(scenario.wpt.data(:,2),1,3) spc(k,2) deg2latlong(scenario.wpt.data(:,3),2,3) spc(k,2) ...
                    num2str(scenario.wpt.data(:,4)) FT];
            nobjstr = num2str(k);
        end
        objstr = 'Waypoints';
        parstr = '';
        
    case 'rt' % Routes
        if isempty(scenario.rt)
            objs = '';
            nobjstr = '';
        else
            n = 0;
            for n = 1:length(scenario.rt)
                objs{n} = ['Rota ' num2str(n)];
            end
            nobjstr = num2str(n);
        end
        objstr = 'Rotas';
        parstr = 'Waypoints';
        
    case 'fa' % Flight Areas
        if isempty(scenario.fa)
            objs = '';
            nobjstr = '';
        else
            for n = 1:length(scenario.fa)
                stylestr{n} = style2str(scenario.fa(n).style,1);
                colorstr{n} = style2str(scenario.fa(n).color,2);
            end
            objs = cell2str([{scenario.fa.code}' stylestr' colorstr' {scenario.fa.descr}']);
            nobjstr = num2str(n);
        end
        objstr = 'Áreas de voo';
        parstr = 'Vértices';
        
    case 'avd' % Avoid Zones
        if isempty(scenario.avd) || isempty(scenario.avd.data)
            objs = '';
            nobjstr = '';
        else
            k = length(scenario.avd.code);
            NM = char( abs(' NM')'*ones(1,k))';
            objs = [char(scenario.avd.code) spc(k,2) deg2latlong(scenario.avd.data(:,1),1,3) spc(k,2) ...
                    deg2latlong(scenario.avd.data(:,2),2,3) spc(k,2) num2str(scenario.avd.data(:,3)) NM];
            nobjstr = num2str(k);
        end
        objstr = 'Avoid zones';
        parstr = '';
        
    case 'thr' % Threat Areas
        if isempty(scenario.thr) || isempty(scenario.thr.data)
            objs = '';
            nobjstr = '';
        else
            k = length(scenario.thr.code);
            objs = [char(scenario.thr.code) spc(k,2) deg2latlong(scenario.thr.data(:,1),1,3) spc(k,2) deg2latlong(scenario.thr.data(:,2),2,3)];
            nobjstr = num2str(k);
        end
        objstr = 'Ameaças';
        parstr = 'Parâmetros';
        
    case 'cnt' % Contact Line
        if isempty(scenario.cnt)
            objs = '';
            nobjstr = '';
        else
            objs = 'Linha de contato';
            nobjstr = '1';
        end
        objstr = 'Linha de contato';
        parstr = 'Vértices';
end

switch ntype
    case 'map'
        set(handles.getobj_btn,'Value',0);
        set(handles.getparam_btn,'Value',0);
    case {'aux','rt','fa','cnt'}
        set(handles.getobj_btn,'Value',0);
    case {'aid','wpt','avd','thr'}
        set(handles.getparam_btn,'Value',0);
end

set(handles.obj_list,'String',objs,'Value',N);
set(handles.nobj_txt,'String',nobjstr);
set(handles.obj_txt,'String',objstr);
set(handles.param_txt,'String',parstr);

switch ntype
    case {'map','aid','wpt','rt','fa','avd','thr'}
        set(handles.obj_list,'Max',3);
    otherwise
        set(handles.obj_list,'Max',1);
end

obj_list_Callback(hObject, eventdata, handles, M);

% ---------------------------------------------------------------------
function obj_list_Callback(hObject, eventdata, handles, M)
% Executada ao se clicar na lista de objetos

if nargin == 3
    M = 1;
end

ntype = getappdata(handles.window,'ntype');
n     = get(handles.obj_list,'Value');
scenario = getappdata(handles.window,'scenario');

if ~strcmp(ntype,'rt')
    set(handles.param_list,'String','Gerando lista ...','Enable','inactive','Max',3,'Value',[]);
end

switch ntype
    case 'map' % Maps
        if isempty(scenario.map) || length(n) > 1
            params = '';
            nparamstr = '';
        else
            latstr1 = deg2latlong(scenario.map(n).data(1,1),1,3);
            latstr2 = deg2latlong(scenario.map(n).data(4,1),1,3);
            lonstr1 = deg2latlong(scenario.map(n).data(1,2),2,3);
            lonstr2 = deg2latlong(scenario.map(n).data(4,2),2,3);
            params  = {'Latitude:      Longitude:'; [latstr1 '   ' lonstr1]; [latstr2 '   ' lonstr2]};
            nparamstr = '';
        end
        
    case 'aux' % Auxiliary Shapes
        if isempty(scenario.aux)
            params = '';
            nparamstr = '';
        else
            k = size(scenario.aux(n).data,1);
            if ~k
                params = '';
                nparamstr = '';
            elseif k <= handles.maxvert
                auxtype = scenario.aux(n).type;
                LAT = deg2latlong(scenario.aux(n).data(:,1),1,3);
                LON = deg2latlong(scenario.aux(n).data(:,2),2,3);
                S = spc(k,2);
                switch auxtype
                    case 'point'
                        COD = char(scenario.aux(n).code);
                        params = [COD S LAT S LON];
                    case {'line','area'}
                        params = [LAT S LON];
                    case 'text'
                        alnlist = {'Esq','Ctr','Dir'};
                        ROT = [num2str(scenario.aux(n).data(:,3)) char(abs('°')*ones(k,1))];
                        for m = 1:k
                            if isnan(scenario.aux(n).data(m,3))
                                ROT(m,:) = strrep(ROT(m,:),'NaN°',' -- ');
                            end
                            ALN(m,:) = alnlist{scenario.aux(n).data(m,4)+2};
                        end
                        COD = char(scenario.aux(n).code);
                        params = [LAT S LON S ROT S ALN S COD];
                end 
                nparamstr = num2str(k);
            else
                params = 'Lista não disponível.';
                nparamstr = num2str(k);
            end
        end
        
    case 'aid' % Nav Aids
        params = '';
        nparamstr = '';
        
    case 'wpt' % Waypoints
        params = '';
        nparamstr = '';
        
    case 'rt' % Routes
        if isempty(scenario.rt) || length(n) > 1 || isempty(scenario.rt(n).wpt)
            params = '';
            nparamstr = '';
        else
            for k = 1:length(scenario.rt(n).wpt)
                ki = find(scenario.rt(n).wpt(k)==scenario.wpt.data(:,1));
                params{k,1} = num2str(scenario.wpt.data(ki,1),'%02.0f');
                params{k,2} = scenario.wpt.code{ki};
                if k < length(scenario.rt(n).wpt)
                    kj = find(scenario.rt(n).wpt(k+1)==scenario.wpt.data(:,1));
                    lat1 = scenario.wpt.data(ki,2);
                    lon1 = scenario.wpt.data(ki,3);
                    lat2 = scenario.wpt.data(kj,2);
                    lon2 = scenario.wpt.data(kj,3);
                    [DE, DN] = latlong2dxdy(lat1,lon1,lat2,lon2);
                    HDG  = mod(atan2(DE,DN)*180/pi-scenario.Dmag,360);
                    if k == 1
                        TOT = 0;
                    else
                        TOT = TOT+DIS;
                    end
                    DIS = sqrt((DE/1852)^2+(DN/1852)^2);
                    params{k,3} = [num2str(HDG,'%03.0f') '°'];
                    params{k,4} = [num2str(DIS,'%1.1f') ' NM'];
                    params{k,5} = [num2str(TOT,'%1.1f') ' NM'];
                else
                    if k == 1
                        TOT = 0;
                    else
                        TOT = TOT+DIS;
                    end
                    params{k,3} = '';
                    params{k,4} = '';
                    params{k,5} = [num2str(TOT,'%1.1f') ' NM'];
                end
            end
            params = cell2str(params,6,2,'',1);
            nparamstr = num2str(length(scenario.rt(n).wpt));
        end
        
    case 'fa' % Flight Areas
        if isempty(scenario.fa) || length(n) > 1 
            params = '';
            nparamstr = '';
        else
            k = size(scenario.fa(n).data,1);
            if k
                params = [deg2latlong(scenario.fa(n).data(1:end-1,1),1,3) spc(k-1,2) deg2latlong(scenario.fa(n).data(1:end-1,2),2,3)];
                nparamstr = num2str(k);
            else
                params = '';
                nparamstr = '';
            end
        end
        
    case 'avd' % Avoid Zones
        params = '';
        nparamstr = '';
        
    case 'thr' % Threat Areas
        if isempty(scenario.thr) || isempty(scenario.thr.data) || length(n) > 1
            params = '';
        else
            params = [['Nível 1: '; 'Nível 2: '] num2str(scenario.thr.data(n,3:4)') [' ft, ';' ft, '] ...
                    num2str(scenario.thr.data(n,5:6)') [' NM';' NM']];
        end
        nparamstr = '';
        
    case 'cnt' % Contact Line
        if isempty(scenario.cnt)
            params = '';
            nparamstr = '';
        else
            k = size(scenario.cnt.data,1);
            if k
                params = char([deg2latlong(scenario.cnt.data(:,1),1,3) spc(k,2) deg2latlong(scenario.cnt.data(:,2),2,3)]);
            else
                params = '';
            end
            nparamstr = num2str(k);
        end
        
end

set(handles.nparam_txt,'String',nparamstr);

switch ntype
    case {'map','aid','wpt','avd','thr'}
        set(handles.param_list,'String',params,'Enable','inactive','Max',3,'Value',[]);
    case 'rt'
        set(handles.param_list,'String',params,'Enable','on','Max',1,'Value',M);
    otherwise
        set(handles.param_list,'String',params,'Enable','on','Max',3,'Value',M);
end

if strcmp(params,'Lista não disponível.')
    set(handles.param_list,'Enable','inactive','Max',3,'Value',[]);
end

param_list_Callback(hObject, eventdata, handles);

window_WindowButtonMotionFcn(hObject, eventdata, handles);

% ---------------------------------------------------------------------
function param_list_Callback(hObject, eventdata, handles)
% Executada ao se clicar na lista de parametros

ntype = getappdata(handles.window,'ntype');
n     = get(handles.obj_list,'Value');
m     = get(handles.param_list,'Value');
scenario = getappdata(handles.window,'scenario');

switch ntype
    case 'map' % Maps
        if isempty(scenario.map)
            Xs = NaN;
            Ys = NaN;
        else
            Xs = [];
            Ys = [];
            for ni = 1:length(n)
                Xs = [Xs; NaN; scenario.map(n(ni)).data([1 2 4 3 1],2)];
                Ys = [Ys; NaN; scenario.map(n(ni)).data([1 2 3 4 1],1)];
            end
        end
        
    case 'aux' % Auxiliary Shapes
        if isempty(scenario.aux) || isempty(scenario.aux(n).data)
            Xs = NaN;
            Ys = NaN;
        else
            if strcmp(get(handles.param_list,'Enable'),'on')
                Xs = scenario.aux(n).data(m,2);
                Ys = scenario.aux(n).data(m,1);
            else
                Xs = NaN;
                Ys = NaN;
            end
        end
        
    case 'aid' % Nav Aids
        if isempty(scenario.aid) || isempty(scenario.aid.data)
            Xs = NaN;
            Ys = NaN;
        else
            Xs = scenario.aid.data(n,2);
            Ys = scenario.aid.data(n,1);
        end
        
    case 'wpt' % Waypoints
        if isempty(scenario.wpt) || isempty(scenario.wpt.data)
            Xs = NaN;
            Ys = NaN;
        else
            Xs = scenario.wpt.data(n,3);
            Ys = scenario.wpt.data(n,2);
        end
        
    case 'rt' % Routes
        if isempty(scenario.rt) || length(n) > 1 || isempty(scenario.rt(n).wpt)
            Xs = NaN;
            Ys = NaN;
        else
            k = find(scenario.rt(n).wpt(m)==scenario.wpt.data(:,1));
            Xs = scenario.wpt.data(k,3);
            Ys = scenario.wpt.data(k,2);
        end
        
    case 'fa' % Flight Areas
        if isempty(scenario.fa) || length(n) > 1 || isempty(scenario.fa(n).data)
            Xs = NaN;
            Ys = NaN;
        else
            Xs = scenario.fa(n).data(m,2);
            Ys = scenario.fa(n).data(m,1);
        end
        
    case 'avd' % Avoid Zones
        if isempty(scenario.avd) || isempty(scenario.avd.data)
            Xs = NaN;
            Ys = NaN;
        else
            Xs = scenario.avd.data(n,2);
            Ys = scenario.avd.data(n,1);
        end
        
    case 'thr' % Threat Areas
        if isempty(scenario.thr) || isempty(scenario.thr.data)
            Xs = NaN;
            Ys = NaN;
        else
            Xs = scenario.thr.data(n,2);
            Ys = scenario.thr.data(n,1);
        end
        
    case 'cnt' % Contact Line
        if isempty(scenario.cnt) || isempty(scenario.cnt.data)
            Xs = NaN;
            Ys = NaN;
        else
            Xs = scenario.cnt.data(m,2);
            Ys = scenario.cnt.data(m,1);
        end

end

hsel = getappdata(handles.window,'hsel');
delete(hsel);
switch ntype
    case 'map'
        hsel = plot3(Xs,Ys,0*Xs+3,'--w','LineWidth',2);
    otherwise
        hsel = plot3(Xs,Ys,0*Xs+3,'sw','MarkerSize',14,'LineWidth',2,'UIContextMenu',handles.selmenu);
end
setappdata(handles.window,'hsel',hsel);

% --------------------------------------------------------------------
function Dmag_entry_Callback(hObject, eventdata, handles)
% Entrada no campo da declinaçao magnetica

ntype = getappdata(handles.window,'ntype');
scenario = getappdata(handles.window,'scenario');
Dmag = str2double(get(handles.Dmag_entry,'String'));

if ~isnan(Dmag)
    Dmag = max(-90,min(90,Dmag));
    scenario.Dmag = roundn(Dmag,-2);
    setappdata(handles.window,'scenario',scenario);
    
    handles.chg = 1;
    guidata(hObject, handles);
end
set(handles.Dmag_entry,'String',num2str(scenario.Dmag));

updaterulertags(hObject, eventdata, handles);
if istype(ntype,'rt') % Routes
    obj_list_Callback(hObject, eventdata, handles, get(handles.param_list,'Value'));    
end
updatescenario(hObject, eventdata, handles, scenario);

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

ntype = getappdata(handles.window,'ntype');

dragruler = 0;
dragdata = getappdata(handles.window,'dragdata');
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
if dragdata(1) < 2
    if ng
        % Arrastar regua
        if get(handles.ruler_btn,'Value') && ~get(handles.drag_btn,'Value') && ~get(handles.zoom_btn,'Value')
            xr = get(handles.ruler,'XData');
            yr = get(handles.ruler,'YData');
            d = 8/ap(3)*diff(ax);
            if abs(x-xr(1)) < d && abs(y-yr(1)) < d
                pointer = 'fleur';
                dragruler = 1;
                setappdata(handles.window,'dragdata',-2.1);
            elseif abs(x-xr(2)) < d && abs(y-yr(2)) < d
                pointer = 'fleur';
                dragruler = 1;
                setappdata(handles.window,'dragdata',-2.2);
            else
                pointer = 'crosshair';
                setappdata(handles.window,'dragdata',0);
            end
        end
        if ~dragruler
            if get(handles.zoom_btn,'Value') % Zoom
                set(handles.window,'Pointer','custom','PointerShapeCData',handles.cursors.zoom,'PointerShapeHotSpot',handles.cursors.zoom_hs);
                pointer = '';
            elseif dragdata(1) >= 0 && get(handles.drag_btn,'Value') % Arrastar grafico
                set(handles.window,'Pointer','custom','PointerShapeCData',handles.cursors.drag{dragdata(1)+1},...
                    'PointerShapeHotSpot',handles.cursors.drag_hs{dragdata(1)+1});
                pointer = '';
            elseif get(handles.getobj_btn,'Value') || get(handles.getparam_btn,'Value') % Obter ponto
                if getver >= 7
                    pointer = 'cross';
                else
                    pointer = 'circle';
                end
            elseif ~istype(ntype,'map') % Arrastar ponto selecionado
                hsel = getappdata(handles.window,'hsel');
                xsel = get(hsel,'XData');
                ysel = get(hsel,'YData');
                d = 8/ap(3)*diff(ax);
                if length(xsel)==1 && ~isnan(xsel+ysel) && abs(x-xsel) < d && abs(y-ysel) < d
                    pointer = 'fleur';
                    setappdata(handles.window,'dragdata',-3);
                else
                    pointer = 'crosshair';
                    setappdata(handles.window,'dragdata',0);
                end
            else
                pointer = 'crosshair';
            end
        end
        if ~isempty(pointer)
            set(handles.window,'Pointer',pointer);
        end
    else
        set(handles.window,'Pointer','arrow');
    end
end

dragdata = getappdata(handles.window,'dragdata');
if ng
    % Arrastamento do grafico
    if dragdata(1) == 1
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
            
            set(handles.TSD,'XLim',Ax,'YLim',Ay);
            
        end
        
        % Arrastamento da regua
    elseif dragdata(1) == 2.1
        xr = get(handles.ruler,'XData');
        yr = get(handles.ruler,'YData');
        set(handles.ruler,'XData',[x xr(2)],'YData',[y yr(2)]);
        updaterulertags(hObject, eventdata, handles);
    elseif dragdata(1) == 2.2
        xr = get(handles.ruler,'XData');
        yr = get(handles.ruler,'YData');
        set(handles.ruler,'XData',[xr(1) x],'YData',[yr(1) y]);
        updaterulertags(hObject, eventdata, handles);
        
        % Arrastamento de ponto
    elseif dragdata(1) == 3
        movepoint(hObject, eventdata, handles, y-dragdata(3), x-dragdata(2));
    end
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

if dragdata(1) ~= 1
    set(handles.lat,'String',latstr);
    set(handles.lon,'String',lonstr);
    set(handles.var,'String',varstr);
end

% ----------------------------------------------------------------
function window_WindowButtonDownFcn(hObject, eventdata, handles)
% Funçao executada ao se pressionar o botao do mouse

dragdata = getappdata(handles.window,'dragdata');
cp = get(handles.TSD,'CurrentPoint');
x = cp(1,1);
y = cp(1,2);
ax = get(handles.TSD,'XLim');
ay = get(handles.TSD,'YLim');

if x > ax(1) && x < ax(2) && y > ay(1) && y < ay(2)
    
    if get(handles.zoom_btn,'Value') % Zoom
        
        switch get(handles.window,'SelectionType')
            case 'open' % Duplo clique
                
                fit_btn_Callback(hObject, eventdata, handles, 1);
                
            case 'normal' % Clique simples
                
                t0 = clock;
                p1 = get(handles.TSD,'CurrentPoint');
                rbbox;
                p2 = get(handles.TSD,'CurrentPoint');
                dt = etime(clock,t0);
                
                x1 = max(-180,min(180,min(p1(1,1),p2(1,1))));
                x2 = max(-180,min(180,max(p1(1,1),p2(1,1))));
                y1 = max( -90,min( 90,min(p1(1,2),p2(1,2))));
                y2 = max( -90,min( 90,max(p1(1,2),p2(1,2))));
                
                if x2 == x1 && y2 == y1
                    if dt > .5
                        beep;
                    else
                        set(handles.TSD,'XLim',x1+[-.25 .25]*diff(ax),'YLim',y1+[-.25 .25]*diff(ay));                        
                    end
                else
                    if x2-x1 > 1e-4 && y2-y1 > 1e-4
                        pos = get(handles.TSD,'Position');
                        Tw = pos(3);
                        Th = pos(4);
                        if (x2-x1)/Tw >= (y2-y1)/Th
                            set(handles.TSD,'XLim',[x1 x2],'YLim',mean([y1 y2])+[-.5 .5]*(x2-x1)*Th/Tw);
                        else
                            set(handles.TSD,'XLim',mean([x1 x2])+[-.5 .5]*(y2-y1)*Tw/Th,'YLim',[y1 y2]);
                        end
                    else
                        beep;
                    end
                end
            case 'alt' % Botao direito
                set(handles.TSD,'XLim',x+[-1 1]*diff(ax),'YLim',y+[-1 1]*diff(ay));
                
        end
        adjust_aspect(hObject, eventdata, handles);
        
    elseif get(handles.drag_btn,'Value') % Arrastar grafico
        
        switch get(handles.window,'SelectionType')
            case {'normal','open'} % Clique simples
                ap = get(handles.TSD,'Position');
                cp = get(handles.window,'CurrentPoint') + [.5 .5];
                setappdata(handles.window,'dragdata',[1 cp ax ay ap(3:4)]);
                
            case 'alt' % Botao direito
                set(handles.drag_btn,'Value',0);
                setappdata(handles.window,'dragdata',0);
        end
        
    elseif get(handles.getobj_btn,'Value') % Obter objeto do grafico
        
        switch get(handles.window,'SelectionType')
            case 'normal' % Clique simples
                getobj(hObject, eventdata, handles, y, x);
                
            case 'alt' % Botao direito
                set(handles.getobj_btn,'Value',0);
        end
        set(handles.getobj_btn,'Value',0);
        
    elseif get(handles.getparam_btn,'Value') % Obter parametro do grafico
        
        switch get(handles.window,'SelectionType')
            case 'normal' % Clique simples
                getparam(hObject, eventdata, handles, y, x);
                
            case 'alt' % Botao direito
                set(handles.getparam_btn,'Value',0);
        end
        
    elseif dragdata(1) == -2.1 || dragdata(1) == -2.2 % Arrastar regua
        
        switch get(handles.window,'SelectionType')
            case {'normal','open'} % Clique simples
                setappdata(handles.window,'dragdata',abs(dragdata(1)));
                
            case 'alt' % Botao direito
                setappdata(handles.window,'dragdata',dragdata(1));
        end
        
    elseif dragdata(1) == -3 % Arrastar objeto/vertice
        
        switch get(handles.window,'SelectionType')
            case {'normal','open'} % Clique simples
                hsel = getappdata(handles.window,'hsel');
                xsel = get(hsel,'XData');
                ysel = get(hsel,'YData');
                setappdata(handles.window,'dragdata',[3 x-xsel y-ysel]);
                
            case 'alt' % Botao direito
                setappdata(handles.window,'dragdata',-3);
        end
        
    else % Selecionar objeto/vertice
        
        if strcmp(get(handles.window,'SelectionType'),'normal')
            ntype = getappdata(handles.window,'ntype');
            scenario = getappdata(handles.window,'scenario');
            ap = get(handles.TSD,'Position');
            ax = get(handles.TSD,'XLim');
            d = 8/ap(3)*diff(ax);
            
            switch ntype
                case 'map' % Maps
                    for n = 1:length(scenario.map)
                        lat1 = scenario.map(n).data(1,1);
                        lat2 = scenario.map(n).data(3,1);
                        lon1 = scenario.map(n).data(1,2);
                        lon2 = scenario.map(n).data(2,2);
                        if x > lon1 && x < lon2 && y > lat1 && y < lat2
                            set(handles.obj_list,'Value',n);
                            obj_list_Callback(hObject, eventdata, handles);
                            break
                        end
                    end
                    
                case 'aux' % Auxiliary Shapes
                    ok = 0;
                    for n = 1:length(scenario.aux)
                        if size(scenario.aux(n).data,1) <= handles.maxvert
                            for m = 1:size(scenario.aux(n).data,1)
                                lat1 = scenario.aux(n).data(m,1);
                                lon1 = scenario.aux(n).data(m,2);
                                if ~isnan(lat1+lon1) && abs(x-lon1) < d && abs(y-lat1) < d
                                    set(handles.obj_list,'Value',n);
                                    obj_list_Callback(hObject, eventdata, handles, m);
                                    ok = 1;
                                    break
                                end
                            end
                        end
                        if ok
                            break
                        end
                    end
                    
                case 'aid' % Nav Aids
                    if ~isempty(scenario.aid)
                        for n = 1:size(scenario.aid.data,1)
                            lat1 = scenario.aid.data(n,1);
                            lon1 = scenario.aid.data(n,2);
                            if ~isnan(lat1+lon1) && abs(x-lon1) < d && abs(y-lat1) < d
                                set(handles.obj_list,'Value',n);
                                obj_list_Callback(hObject, eventdata, handles);
                                break
                            end
                        end
                    end
                
                case 'wpt' % Waypoints
                    if ~isempty(scenario.wpt)
                        for n = 1:size(scenario.wpt.data,1)
                            lat1 = scenario.wpt.data(n,2);
                            lon1 = scenario.wpt.data(n,3);
                            if ~isnan(lat1+lon1) && abs(x-lon1) < d && abs(y-lat1) < d
                                set(handles.obj_list,'Value',n);
                                obj_list_Callback(hObject, eventdata, handles);
                                break
                            end
                        end
                    end
                
                case 'rt' % Routes
                    ok = 0;
                    for n = 1:length(scenario.rt)
                        for m = 1:length(scenario.rt(n).wpt)
                            k = find(scenario.rt(n).wpt(m)==scenario.wpt.data(:,1));
                            lat1 = scenario.wpt.data(k,2);
                            lon1 = scenario.wpt.data(k,3);
                            if ~isnan(lat1+lon1) && abs(x-lon1) < d && abs(y-lat1) < d
                                set(handles.obj_list,'Value',n);
                                obj_list_Callback(hObject, eventdata, handles, m);
                                ok = 1;
                                break
                            end
                        end
                        if ok
                            break
                        end
                    end
                    
                case 'fa' % Flight Areas
                    ok = 0;
                    for n = 1:length(scenario.fa)
                        for m = 1:size(scenario.fa(n).data,1)-1
                            lat1 = scenario.fa(n).data(m,1);
                            lon1 = scenario.fa(n).data(m,2);
                            if ~isnan(lat1+lon1) && abs(x-lon1) < d && abs(y-lat1) < d
                                set(handles.obj_list,'Value',n);
                                obj_list_Callback(hObject, eventdata, handles, m);
                                ok = 1;
                                break
                            end
                        end
                        if ok
                            break
                        end
                    end
                    
                case 'avd' % Avoid Zones
                    if ~isempty(scenario.avd)
                        for n = 1:size(scenario.avd.data,1)
                            lat1 = scenario.avd.data(n,1);
                            lon1 = scenario.avd.data(n,2);
                            if ~isnan(lat1+lon1) && abs(x-lon1) < d && abs(y-lat1) < d
                                set(handles.obj_list,'Value',n);
                                obj_list_Callback(hObject, eventdata, handles);
                                break
                            end
                        end
                    end
                    
                case 'thr' % Threat Areas
                    if ~isempty(scenario.thr)
                        for n = 1:size(scenario.thr.data,1)
                            lat1 = scenario.thr.data(n,1);
                            lon1 = scenario.thr.data(n,2);
                            if ~isnan(lat1+lon1) && abs(x-lon1) < d && abs(y-lat1) < d
                                set(handles.obj_list,'Value',n);
                                obj_list_Callback(hObject, eventdata, handles);
                                break
                            end
                        end
                    end
                    
                case 'cnt' % Contact Line
                    if ~isempty(scenario.cnt)
                        for m = 1:size(scenario.cnt.data,1)
                            lat1 = scenario.cnt.data(m,1);
                            lon1 = scenario.cnt.data(m,2);
                            if ~isnan(lat1+lon1) && abs(x-lon1) < d && abs(y-lat1) < d
                                set(handles.param_list,'Value',m);
                                param_list_Callback(hObject, eventdata, handles);
                                break
                            end
                        end
                    end
                    
            end
        end
    end
end

if dragdata(1) ~= -3
    window_WindowButtonMotionFcn(hObject, eventdata, handles);
end

% --------------------------------------------------------------------
function window_WindowButtonUpFcn(hObject, eventdata, handles)
% Funçao executada apos a soltura do botao do mouse

setappdata(handles.window,'dragdata',0);
window_WindowButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function window_KeyPressFcn(hObject, eventdata, handles)
% Acionamento de tecla do teclado

cc = get(handles.window,'CurrentCharacter');
ntype = getappdata(handles.window,'ntype');

if isempty(cc)
    return
end

switch abs(cc)
    
    case 28 % <--
        ax = get(handles.TSD,'XLim');
        dx = min(.2*diff(ax),180+ax(1));
        set(handles.TSD,'XLim',ax-dx);
        
    case 29 % -->
        ax = get(handles.TSD,'XLim');
        dx = min(.2*diff(ax),180-ax(2));
        set(handles.TSD,'XLim',ax+dx);
        
    case 31 % Down
        ay = get(handles.TSD,'YLim');
        dy = min(.2*diff(ay),90+ay(1));
        set(handles.TSD,'YLim',ay-dy);
        
    case 30 % Up
        ay = get(handles.TSD,'YLim');
        dy = min(.2*diff(ay),90-ay(2));
        set(handles.TSD,'YLim',ay+dy);
        
    case abs('+')
        ax = get(handles.TSD,'XLim');
        dx = 1/6*diff(ax);
        ay = get(handles.TSD,'YLim');
        dy = 1/6*diff(ay);
        if dx >= 1e-3 && dy >= 1e-3
            set(handles.TSD,'XLim',ax+[1 -1]*dx,'YLim',ay+[1 -1]*dy);
        end
        
    case abs('-')
        ax = get(handles.TSD,'XLim');
        dx = .25*diff(ax);
        ay = get(handles.TSD,'YLim');
        dy = .25*diff(ay);
        if ax(1)-dx >= -180 && ax(2)+dx <= 180 && ay(1)-dy >= -90 && ay(2)+dy <= 90
            set(handles.TSD,'XLim',ax+[-1 1]*dx,'YLim',ay+[-1 1]*dy);
        end
        
    case abs('.')
        fit_btn_Callback(hObject, eventdata, handles, 1);
        
    case abs('z')
        set(handles.zoom_btn,'Value',~get(handles.zoom_btn,'Value'))
        zoom_btn_Callback(hObject, eventdata, handles);
        
    case abs('Z')
        set(handles.drag_btn,'Value',~get(handles.drag_btn,'Value'))
        drag_btn_Callback(hObject, eventdata, handles);
        
    case {abs('n'),abs('N')}
        new_btn_Callback(hObject, eventdata, handles);
        
    case {abs('a'),abs('A')}
        open_btn_Callback(hObject, eventdata, handles);
        
    case {abs('i'),abs('I')}
        import_btn_Callback(hObject, eventdata, handles);
        
    case {abs('s'),abs('S')}
        save_btn_Callback(hObject, eventdata, handles);
        
    case {abs('m'),abs('M')}
        mapdb_btn_Callback(hObject, eventdata, handles);
        
    case 13 % Enter
        ok_btn_Callback(hObject, eventdata, handles);
        
    case 27 % Esc
        cancel_btn_Callback(hObject, eventdata, handles);
        
    case 127 % del
        switch ntype
            case {'map','aid','wpt','avd','thr'}
                remobj_btn_Callback(hObject, eventdata, handles);
            case {'aux','rt','fa','cnt'}
                remparam_btn_Callback(hObject, eventdata, handles);
        end
        
end

% --------------------------------------------------------------------
function window_ResizeFcn(hObject, eventdata, handles)
% Funçao de redimensionamento da janela

if isempty(handles)
    return
end

% Limite minimo
ws = get(handles.window,'Position');
sw = 880;
sh = 540;

if ws(3) < sw || ws(4) < sh
    set(handles.window,'Position',[ws(1) ws(2)+ws(4)-max(ws(4),sh) max(ws(3),sw) max(ws(4),sh)]);
end

ws = get(handles.window,'Position');

Tw = ws(3)-420;
Th = ws(4)-80;

set(handles.TSD,'Position',[400 60 Tw Th]);
adjust_aspect(hObject, eventdata, handles, 1);

ctrlh = findobj(handles.window,'UserData',1);
dpos = zeros(length(ctrlh),4);
pos0 = get(handles.new_btn,'Position').*[1 1 0 0];
for n = 1:length(ctrlh)
    dpos(n,:) = get(ctrlh(n),'Position')-pos0;
end
for n = 1:length(ctrlh)
    set(ctrlh(n),'Position',[15 ws(4)-30 0 0]+dpos(n,:));
end

Bh = .5*(ws(4)-110-25-55);
set(handles.obj_list,  'Position',[15  55+Bh+25 310 Bh]);
set(handles.param_list,'Position',[15  47       310 Bh+13]);
set(handles.param_txt, 'Position',[17  47+Bh+13 80  15]);
set(handles.nparam_txt,'Position',[272 47+Bh+13 50  15]);

set(handles.lat,'Position',[ws(3)-100 20    80 15]);
set(handles.lon,'Position',[ws(3)-100 5     80 15]);
set(handles.var,'Position',[ws(3)-60  61+Th 40 15]);

ctrlh = findobj(handles.window,'UserData',2);
dpos = zeros(length(ctrlh),4);
pos0 = get(handles.addparam_btn,'Position').*[1 1 0 0];
for n = 1:length(ctrlh)
    dpos(n,:) = get(ctrlh(n),'Position')-pos0;
end
for n = 1:length(ctrlh)
    set(ctrlh(n),'Position',[327 47+Bh+13-18 0 0]+dpos(n,:));
end

ctrlh = findobj(handles.window,'UserData',3);
dpos = zeros(length(ctrlh),4);
pos0 = get(handles.map_chk,'Position').*[1 1 0 0];
for n = 1:length(ctrlh)
    dpos(n,:) = get(ctrlh(n),'Position')-pos0;
end
for n = 1:length(ctrlh)
    set(ctrlh(n),'Position',[ws(3)-19 ws(4)-38 0 0]+dpos(n,:));
end

for n = 1:length(handles.lbl)
    pos = get(handles.lbl(n),'Position');
    y = 1 - (1-handles.ylbl(n)) * 460/Th;
    set(handles.lbl(n),'Position',[pos(1) y pos(3)]);
end

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
    
    pos = get(handles.TSD,'Position');
    Tw = pos(3);
    Th = pos(4);
    
    ax  = get(handles.TSD,'XLim');
    ay  = get(handles.TSD,'YLim');
    
    set(handles.TSD,'XLim',mean(ax)+diff(ax)*Tw/prevpos(3)*[-.5 .5],'YLim',mean(ay)+diff(ay)*Th/prevpos(4)*[-.5 .5]);
    
    setappdata(handles.window,'prevsize',pos);
    
else
    
    pos = get(handles.TSD,'Position');
    Tw = pos(3);
    Th = pos(4);
    
    ax  = get(handles.TSD,'XLim');
    ay  = get(handles.TSD,'YLim');
    
    if Tw < Th
        set(handles.TSD,'YLim',mean(ay)+diff(ax)*Th/Tw*[-.5 .5]);
    else
        set(handles.TSD,'XLim',mean(ax)+diff(ay)*Tw/Th*[-.5 .5]);
    end
    
end

ax = get(handles.TSD,'XLim');
ay = get(handles.TSD,'YLim');
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

set(handles.TSD,'XLim',ax,'YLim',ay);

% --------------------------------------------------------------------
function new_btn_Callback(hObject, eventdata, handles)
% Novo cenario

button = questdlg('Deseja criar novo cenário?','Confirmação','Sim','Não','Não');

if strcmp(button,'Sim')
    
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
    
    setscenario(hObject, eventdata, handles, scenario);
    type_sel(hObject, eventdata, handles);
    
end

% --------------------------------------------------------------------
function open_btn_Callback(hObject, eventdata, handles)
% Abre arquivo de cenario

[fname, fpath] = uigetfile({'*.mat','Arquivo mat (*.mat)'},'Carregar cenário',handles.fpath); drawnow;

if ~ischar(fname)
    return
end

vars = who('-file',[fpath fname]);
if ~isempty(strmatch('scenario',vars,'exact'))
    load([fpath fname],'scenario');
else
    beep; uiwait(errordlg(['Arquivo ''' fname ''' não contém cenário.'],'Erro','modal'));
    return
end

scenario = backcompat(scenario,'scenario');

handles.fname = fname;
handles.fpath = fpath;
guidata(hObject, handles);

set(handles.ruler_btn,'Value',0);
ruler_btn_Callback(hObject, eventdata, handles);
set(handles.ruler,'XData',[NaN NaN],'YData',[NaN NaN]);

setscenario(hObject, eventdata, handles, scenario, 'all', 1);
type_sel(hObject, eventdata, handles);

% ---------------------------------------------------------------
function import_btn_Callback(hObject, eventdata, handles)
% Importar cenario da MPS do F-5M / A-29

Hobj = [findobj(handles.TSD,'Type','line'); findobj(handles.TSD,'Type','patch'); findobj(handles.TSD,'Type','image')];
if length(Hobj)>2
    button = questdlg('Deseja substituir o cenário atual?','Confirmação','Sim','Não','Sim');
    if ~strcmp(button,'Sim')
        return
    end
end

fpath = uigetdir(handles.fpath,'Pasta dos arquivos de cenário F-5M / A-29:');
if ~ischar(fpath)
    return
end

scenario = getappdata(handles.window,'scenario');
aux.map = scenario.map;
aux.aux = scenario.aux;

scenario = scenarioread(fpath);

if ~isempty(scenario)
    
    set(handles.ruler_btn,'Value',0);
    ruler_btn_Callback(hObject, eventdata, handles);
    set(handles.ruler,'XData',[NaN NaN],'YData',[NaN NaN]);
    
    if scenario.Dmag == 0
        uiwait(warndlg({'Declinação magnética não definida ou não encontrada.',...
                'Defina o valor no campo "Declinação Magnética".'},'Aviso','modal'));
    end
    if ~isempty(aux.map) || ~isempty(aux.aux)
        button = questdlg('Deseja manter os mapas e objetos auxiliares atuais?','Confirmação','Sim','Não','Sim');
        if strcmp(button,'Sim')
            scenario.map = aux.map;
            scenario.aux = aux.aux;
            setscenario(hObject, eventdata, handles, scenario, {'aid','wpt','rt','fa','avd','thr','cnt'}, 1);
        else
            setscenario(hObject, eventdata, handles, scenario, 'all', 1);
        end
    else
        setscenario(hObject, eventdata, handles, scenario, 'all', 1);
    end
    type_sel(hObject, eventdata, handles);
else
    beep; uiwait(errordlg('Não foram encontrados arquivos de cenário.','Erro','modal'));
end

% ---------------------------------------------------------------
function import_matfile(hObject, eventdata, handles)
% Importar objeto de outro arquivo mat

ntype = getappdata(handles.window,'ntype');
scenario = getappdata(handles.window,'scenario');

if istype(ntype,'rt')
    if isempty(scenario.wpt) || isempty(scenario.wpt.data)
        beep; uiwait(errordlg('Não é possível importar rotas quando não há waypoints cadastrados.','Erro','modal'));
        return
    end
end

[fname, fpath] = uigetfile({'*.mat','Arquivo mat (*.mat)'},'Carregar outro arquivo de cenário',handles.fpath); drawnow;

if ~ischar(fname)
    return
end

vars = who('-file',[fpath fname]);
if ~isempty(strmatch('scenario',vars,'exact'))
    load([fpath fname],'scenario');
else
    beep; uiwait(errordlg(['Arquivo ''' fname ''' não contém cenário.'],'Erro','modal'));
    return
end

scenario2 = backcompat(scenario,'scenario');

handles.fpath = fpath;
guidata(hObject, handles);

scenario = getappdata(handles.window,'scenario');

switch ntype
    case 'map' % Maps
        beep;
        return
        
    case 'aux' % Auxiliary Shapes
        
        if isempty(scenario2) || isempty(scenario2.aux)
            beep; uiwait(errordlg('Não há objetos auxiliares no arquivo especificado.','Erro','modal'));
            return
        end
        
        type_en = {'point','line','area','text'};
        type_pt = {'pontos','linha','área','texto'};
        
        for n = 1:length(scenario2.aux)
            k = strmatch(scenario2.aux(n).type,type_en);
            objs{n} = [scenario2.aux(n).name '   (' type_pt{k} ')'];
        end
        
        sel = listdlg2('Name','Importar objs. auxiliares','HeaderString',{'Objetos auxiliares disponíveis em',[fname ':']},'SelectionMode','multiple','ListString',objs,...
            'OKString','OK','CancelString','Cancela','SelectAllString','Selecionar tudo','SelectNoneString','Limpar','ListSize',[180 305]); drawnow;
        if isempty(sel)
            return
        end
        
        scenario.aux = cat(2,scenario.aux,scenario2.aux(sel));
        N = length(scenario.aux);
        
    case 'aid' % Nav Aids
        
        if isempty(scenario2.aid) || isempty(scenario2.aid.data)
            beep; uiwait(errordlg('Não há auxílios/aeródromos no arquivo especificado.','Erro','modal'));
            return
        end
        
        for n = 1:length(scenario2.aid.code)
            objs{n} = [scenario2.aid.code{n} '  (' scenario2.aid.type{n} ')'];
        end
        
        sel = listdlg2('Name','Importar auxílios/aeródromos','HeaderString',{'Auxílios/aeródromos disponíveis em',[fname ':']},'SelectionMode','multiple','ListString',objs,...
            'OKString','OK','CancelString','Cancela','SelectAllString','Selecionar tudo','SelectNoneString','Limpar','ListSize',[180 305]); drawnow;
        if isempty(sel)
            return
        end
        
        if isempty(scenario.aid)
            scenario.aid.code = {};
            scenario.aid.type = {};
            scenario.aid.data = [];
        end
        scenario.aid.code = [scenario.aid.code; scenario2.aid.code(sel)];
        scenario.aid.type = [scenario.aid.type; scenario2.aid.type(sel)];
        scenario.aid.data = [scenario.aid.data; scenario2.aid.data(sel,:)];
        N = size(scenario.aid.data,1);
        
    case 'wpt' % Waypoints
        
        if isempty(scenario2.wpt) || isempty(scenario2.wpt.data)
            beep; uiwait(errordlg('Não há waypoints no arquivo especificado.','Erro','modal'));
            return
        end
        
        for n = 1:size(scenario2.wpt.data,1)
            objs{n} = [num2str(scenario2.wpt.data(n,1),'%02.0f') ' - ' scenario2.wpt.code{n}];
        end
        
        sel = listdlg2('Name','Importar auxílios/aeródromos','HeaderString',{'Waypoints disponíveis em',[fname ':']},'SelectionMode','multiple','ListString',objs,...
            'OKString','OK','CancelString','Cancela','SelectAllString','Selecionar tudo','SelectNoneString','Limpar','ListSize',[180 305]); drawnow;
        if isempty(sel)
            return
        end
        
        if isempty(scenario.wpt)
            scenario.wpt.code = {};
            scenario.wpt.data = [];
        end
        scenario.wpt.code = [scenario.wpt.code; scenario2.wpt.code(sel)];
        scenario.wpt.data = [scenario.wpt.data; scenario2.wpt.data(sel,:)];
        N = size(scenario.wpt.data,1);

    case 'rt' % Routes
        
        if isempty(scenario2.rt) || isempty([scenario2.rt.wpt])
            beep; uiwait(errordlg({'O arquivo indicado não contém rotas válidas.'},'Erro','modal'));
            return
        end
        
        for n = 1:length(scenario2.rt)
            objs{n} = ['Rota ' num2str(n) ': [' num2str(scenario2.rt(n).wpt) ']'];
        end
        
        sel = listdlg2('Name','Importar rotas','HeaderString',{'Rotas disponíveis em',[fname ':']},'SelectionMode','multiple','ListString',objs,...
            'OKString','OK','CancelString','Cancela','SelectAllString','Selecionar tudo','SelectNoneString','Limpar','ListSize',[180 305]); drawnow;
        if isempty(sel)
            return
        end
        
        rt = scenario2.rt(sel);
        
        if ~isempty(setdiff([rt.wpt],scenario.wpt.data(:,1)'))
            button = questdlg({'Alguns waypoints das rotas importadas não estão',...
                    'cadastrados e serão descartados.','','Deseja prosseguir?'},'Confirmação','Sim','Não','Não');
            if ~strcmp(button,'Sim')
                return
            end
            for n = 1:length(rt)
                for m = length(rt(n).wpt):-1:1
                    if ~any(rt(n).wpt(m)==scenario.wpt.data(:,1))
                        rt(n).wpt(m) = [];
                    end
                end
            end
        end
        
        for n = 1:length(rt)
            N = length(scenario.rt);
            scenario.rt(N+1).wpt = rt(n).wpt;
        end
        N = length(scenario.rt);

    case 'fa' % Flight Areas
        
        if isempty(scenario2) || isempty(scenario2.fa)
            beep; uiwait(errordlg('Não há áreas de voo no arquivo especificado.','Erro','modal'));
            return
        end
        
        for n = 1:length(scenario2.fa)
            descr = scenario2.fa(n).descr;
            if ~isempty(descr)
                objs{n} = [scenario2.fa(n).code '   (' descr ')'];
            else
                objs{n} =  scenario2.fa(n).code;
            end
        end
        
        sel = listdlg2('Name','Importar áreas de voo','HeaderString',{'Áreas de voo disponíveis em',[fname ':']},'SelectionMode','multiple','ListString',objs,...
            'OKString','OK','CancelString','Cancela','SelectAllString','Selecionar tudo','SelectNoneString','Limpar','ListSize',[180 305]); drawnow;
        if isempty(sel)
            return
        end
        
        scenario.fa = cat(2,scenario.fa,scenario2.fa(sel));
        N = length(scenario.fa);
        
    case 'avd' % Avoid Zones
        
        if isempty(scenario2.avd) || isempty(scenario2.avd.data)
            beep; uiwait(errordlg('Não há avoid zones no arquivo especificado.','Erro','modal'));
            return
        end
        
        objs = scenario2.avd.code;
        
        sel = listdlg2('Name','Importar avoid zones','HeaderString',{'Avoid zones disponíveis em',[fname ':']},'SelectionMode','multiple','ListString',objs,...
            'OKString','OK','CancelString','Cancela','SelectAllString','Selecionar tudo','SelectNoneString','Limpar','ListSize',[180 305]); drawnow;
        if isempty(sel)
            return
        end

        if isempty(scenario.avd)
            scenario.avd.code = {};
            scenario.avd.data = [];
        end
        scenario.avd.code = [scenario.avd.code; scenario2.avd.code(sel)];
        scenario.avd.data = [scenario.avd.data; scenario2.avd.data(sel,:)];
        N = size(scenario.avd.data,1);
        
    case 'thr' % Threat Areas
        
        if isempty(scenario2.thr) || isempty(scenario2.thr.data)
            beep; uiwait(errordlg('Não há ameaças no arquivo especificado.','Erro','modal'));
            return
        end
        
        objs = scenario2.thr.code;
        
        sel = listdlg2('Name','Importar ameaças','HeaderString',{'Ameaças disponíveis em',[fname ':']},'SelectionMode','multiple','ListString',objs,...
            'OKString','OK','CancelString','Cancela','SelectAllString','Selecionar tudo','SelectNoneString','Limpar','ListSize',[180 305]); drawnow;
        if isempty(sel)
            return
        end
        
        if isempty(scenario.thr)
            scenario.thr.code = {};
            scenario.thr.data = [];
        end
        scenario.thr.code = [scenario.thr.code; scenario2.thr.code(sel)];
        scenario.thr.data = [scenario.thr.data; scenario2.thr.data(sel,:)];
        N = size(scenario.thr.data,1);
        
    case 'cnt' % Contact Line
        
        if isempty(scenario2.cnt) || isempty(scenario2.cnt.data)
            beep; uiwait(errordlg('Não há linha de contato no arquivo especificado.','Erro','modal'));
            return
        end
        
        if ~isempty(scenario.cnt) && ~isempty(scenario.cnt.data)
            button = questdlg('Deseja substituir a linha de contato atual?','Confirmação','Sim','Não','Não');
            if ~strcmp(button,'Sim')
                return
            end
        end
        
        scenario.cnt.data = scenario2.cnt.data;
        N = 1;
        
end

handles.chg = 1;
guidata(hObject, handles);

setscenario(hObject, eventdata, handles, scenario, ntype);
type_sel(hObject, eventdata, handles, N);
fit_btn_Callback(hObject, eventdata, handles);

% ---------------------------------------------------------------
function import_extfile(hObject, eventdata, handles)
% Importar objeto de arquivo externo (xls, txt, xml ou kml)

ntype = getappdata(handles.window,'ntype');

scenario = getappdata(handles.window,'scenario');
oldscenario = scenario;

switch ntype
    case 'map' % Maps
        beep;
        return
        
    case 'aux' % Auxiliary Shapes
        out = inputvalues('Importar aux.',{'Nome:','Tipo:        Estilo:','Cor:','Espessura (px):'},...
            {'',{'Linha      Sólido','Linha      Pontilhado','Linha      Traço-ponto','Linha      Tracejado',...
                    'Pontos    Ponto','Pontos    Círculo','Pontos    Losango','Pontos    Quadrado','Pontos    Triângulo','Pontos    Estrela',...
                    'Área        Opaco','Texto'},...
                {'Azul','Verde','Vermelho','Ciano','Magenta','Amarelo','Branco','Personalizar'},...
                [cellstr(num2str((1:8)'))' {2}] }); drawnow;
        if isempty(out)
            return
        end
        types = {'line','line','line','line','point','point','point','point','point','point','area','text'};
        styles = {'-',':','-.','--','.','o','d','s','^','p','A','T'};
        colors = 'bgrcmyw';
        auxname = out{1};
        auxtype = types{out{2}};
        auxstyle = styles{out{2}};
        if out{3} == 8
            auxcolor = uisetcolor([1 1 1],'Cor do objeto auxiliar:');
            if length(auxcolor) == 3
                auxcolor = roundn(auxcolor,-3);
            else
                return
            end
        else
            auxcolor = colors(out{3});
        end
        if out{2} <= 4 % Line
            auxwidth = out{4};
        elseif out{2} <= 10 % Point
            auxwidth = min(2,out{4});
        else % Area, Text
            auxwidth = 1;
        end
        
        [fname,fpath,opt] = uigetfile({...
                '*.xls','Planilha MS Excel (*.xls)';...
                '*.txt;*.dat','Arquivo de texto (*.txt, *.dat)';...
                '*.kml','Arquivo Google Earth (*.kml)'},...
            'Indique o arquivo de objetos auxiliares',handles.fpath); drawnow;
        if ~ischar(fname)
            return
        end
        
        try
            [auxpos,auxcod] = mapread(auxtype,[fpath fname]);
        catch
            beep; uiwait(errordlg({'Não foi possível importar os objetos auxiliares.','Verifique a formatação e o tipo dos dados.'},'Erro','modal'));
            return
        end
        
        if isempty(auxpos)
            beep; uiwait(errordlg('Não há dados no arquivo especificado.','Erro','modal'));
            return
        end
        
        % Validity check
        exc   = [];
        trunc = 0;
        empt  = [];
        switch auxtype
            case 'point'
                for n = 1:size(auxpos,1)
                    lat = auxpos(n,1);
                    lon = auxpos(n,2);
                    if isnan(lat+lon) || lat<-90 || lat>90 || lon<-180 || lon>180
                        exc = [exc n];
                    end
                end
                if ~isempty(exc)
                    auxpos(exc,:) = [];
                    auxcod(exc)   = [];
                end
                for n = 1:length(auxcod)
                    if length(auxcod{n})>12
                        auxcod{n} = auxcod{n}(1:12);
                        trunc = 1;
                    end
                end
            case {'line','area'}
                for n = 1:size(auxpos,1)
                    lat = auxpos(n,1);
                    lon = auxpos(n,2);
                    if lat<-90 || lat>90 || lon<-180 || lon>180
                        exc = [exc n];
                    end
                end
                if ~isempty(exc)
                    auxpos(exc,:) = [];
                end
            case 'text'
                auxpos(:,3) = mod(round(auxpos(:,3)),360);
                for n = 1:size(auxpos,1)
                    lat = auxpos(n,1);
                    lon = auxpos(n,2);
                    auxpos(n,4) = round(max(-1,min(1,auxpos(n,4))));
                    if isnan(lat+lon) || lat<-90 || lat>90 || lon<-180 || lon>180
                        exc = [exc n];
                    end
                end
                if ~isempty(exc)
                    auxpos(exc,:) = [];
                    auxcod(exc)   = [];
                end
                for n = 1:length(auxcod)
                    if isempty(auxcod{n})
                        empt = [empt n];
                    end
                end
                if ~isempty(empt)
                    auxpos(empt,:) = [];
                    auxcod(empt)   = [];
                end
        end
        if ~isempty(exc)
            uiwait(warndlg('Os vértices com dados incoerentes serão descartados.','Aviso','modal'));
        end
        if trunc
            uiwait(warndlg('Os códigos com mais de 12 caracteres serão truncados.','Aviso','modal'));
        end
        if ~isempty(empt)
            uiwait(warndlg('Os textos vazios serão descartados.','Aviso','modal'));
        end
        
        minlat = fixlatlong(min(auxpos(:,1)),-1);
        maxlat = fixlatlong(max(auxpos(:,1)), 1);
        minlon = fixlatlong(min(auxpos(:,2)),-1);
        maxlon = fixlatlong(max(auxpos(:,2)), 1);
        out = inputvalues('Cortar obj. aux.',{'Limite Norte:','Limite Sul:','Limite Leste:','Limite Oeste:'},...
            {   deg2latlong(maxlat,1,3), deg2latlong(minlat,1,3),...
                deg2latlong(maxlon,2,3), deg2latlong(minlon,2,3)}); drawnow;
        if isempty(out)
            return
        end
        
        [void, lat2] = latlongread(out{1});
        [void, lat1] = latlongread(out{2});
        [void, lon2] = latlongread(out{3});
        [void, lon1] = latlongread(out{4});
        if      isempty(lat1) || isempty(lon1) || lat1<-90 || lat1>90 || lon1<-180 || lon1>180 || ...
                isempty(lat2) || isempty(lon2) || lat2<-90 || lat2>90 || lon2<-180 || lon2>180 || lat1>=lat2 || lon1>=lon2
            beep; uiwait(errordlg('Coordenadas incoerentes.','Erro','modal'));
            return
        end
        
        if lat1>minlat || lat2<maxlat || lon1>minlon || lon2<maxlon
            [yc, xc, Iin] = mapcut(auxpos(:,1),auxpos(:,2),[lat1 lat2],[lon1 lon2],auxtype);
            if isempty(yc)
                beep; uiwait(errordlg('Não há dados nas coordenadas indicadas.','Erro','modal'));
                return
            end
            if istype(auxtype,'point')
                auxcod(~Iin) = [];
            end
            if istype(auxtype,'text')
                rot = auxpos(Iin,3);
                auxcod(~Iin) = [];
            else
                rot = [];
            end
            auxpos = [yc xc rot];
        end
        
        if size(auxpos,1) > handles.maxvert
            button = questdlg({'Os dados importados são muito extensos e podem prejudicar a',...
                    'reprodução do voo. É recomendado reduzir a área importada ao',...
                    'minimo relevante para a reprodução.',' ','Deseja prosseguir?'},'Confirmação','Sim','Não','Não');
            if ~strcmp(button,'Sim')
                return
            end
        end
        
        N = length(scenario.aux);
        
        scenario.aux(N+1).name  = auxname;
        scenario.aux(N+1).type  = auxtype;
        scenario.aux(N+1).style = auxstyle;
        scenario.aux(N+1).color = auxcolor;
        scenario.aux(N+1).width = auxwidth;
        scenario.aux(N+1).data  = auxpos;
        scenario.aux(N+1).code  = auxcod;
        
    case 'aid' % Nav Aids
        [fname,fpath,opt] = uigetfile({...
                '*.xls','Planilha MS Excel (*.xls)';...
                '*.txt;*.dat','Arquivo de texto (*.txt, *.dat)';...
                '*.xml','Arquivo de missão F-5M/A-29 (*.xml)'},...
            'Indique o arquivo de auxílios/aeródromos',handles.fpath); drawnow;
        if ~ischar(fname)
            return
        end
        
        if opt == 3 % xml
            try
                aux = scenarioread(fpath,fname,'aid');
                aid = aux.aid;
            catch
                beep; uiwait(errordlg({'Não foi possível importar os aeródromos.','Verifique o arquivo indicado.'},'Erro','modal'));
                return
            end
            
        else
            if opt == 1 % xls
                [data, txt] = xlsread([fpath fname]);
            else % txt
                [data, txt] = txtread([fpath fname]);
            end
            
            if isempty(data)
                beep; uiwait(errordlg({'O arquivo indicado não contém auxílios/aeródromos válidos.'},'Erro','modal'));
                return
            end
            
            if size(data,2) == 3
                data(:,4) = NaN;
            end                    
            if size(data,2) ~= 4
                beep; uiwait(errordlg({'O arquivo indicado não contém auxílios/aeródromos válidos.'},'Erro','modal'));
                return
            end
            
            if     size(data,1) < size(txt,1)
                txt(1:size(txt,1)-size(data,1),:) = [];
            elseif size(data,1) > size(txt,1)
                txt = cell(size(data,1),1);
            end
            
            emptytxt = zeros(size(txt));
            for n = 1:size(txt,1)
                for m = 1:size(txt,2)
                    if isempty(deblank(txt{n,m}))
                        txt{n,m} = '';
                    end
                    emptytxt(n,m) = isempty(txt{n,m});
                end
            end
            for m = size(txt,2):-1:1
                if all(emptytxt(:,m))
                    txt(:,m) = [];
                end
            end
            if size(txt,2) < 2
                beep; uiwait(errordlg({'O arquivo indicado não contém auxílios/aeródromos válidos.'},'Erro','modal'));
                return
            end
            
            aid.data = data(:,1:4);
            for n = 1:size(txt,1)
                aid.code{n,1} = '';
                for m = 1:size(txt,2)-1
                    aid.code{n,1} = [aid.code{n} txt{n,m}];
                end
                aid.type{n,1} = txt{n,end};
            end
            
        end
        
        % Validity check        
        if isempty(aid)
            aid.code = {};
            aid.type = {};
            aid.data = [];
        end
        
        typelist = {'NDB','VOR','VOR/DME','DME','FIX','AFLD'};
        exc = [];
        for n = 1:size(aid.data,1)
            lat = aid.data(n,1);
            lon = aid.data(n,2);
            alt = aid.data(n,3);
            psi = aid.data(n,4);
            typ = aid.type{n};
            if ~istype(typ,typelist) || isnan(lat+lon+alt) || lat<-90 || lat>90 || lon<-180 || lon>180 || alt<-2000 || alt>100000 || (istype(aid.type{n},'AFLD') && (isnan(psi) || psi<0 || psi>360) )
                exc = [exc n];
            end
        end
        
        if ~isempty(exc)
            uiwait(warndlg('Os auxílios/aeródromos com dados incoerentes serão descartados.','Aviso','modal'));
            aid.data(exc,:) = [];
            aid.code(exc)   = [];
            aid.type(exc)   = [];
        end
        trunc = 0;
        for n = 1:length(aid.code)
            if length(aid.code{n}) > 12
                aid.code{n} = aid.code{n}(1:12);
                trunc = 1;
            end
        end
        if trunc
            uiwait(warndlg('Os códigos com mais de 12 caracteres serão truncados.','Aviso','modal'));
        end
        
        if isempty(aid) || isempty(aid.data)
            beep; uiwait(errordlg({'O arquivo indicado não contém auxílios/aeródromos válidos.'},'Erro','modal'));
            return
        end       
        
        if isempty(scenario.aid)
            scenario.aid.code = {};
            scenario.aid.type = {};
            scenario.aid.data = [];
        end
        
        for n = 1:size(aid.data,1)
            N = size(scenario.aid.data,1);
            scenario.aid.code{N+1,1} = aid.code{n};
            scenario.aid.type{N+1,1} = aid.type{n};
            scenario.aid.data(N+1,:) = aid.data(n,:);
        end
        
    case 'wpt' % Waypoints
        [fname,fpath,opt] = uigetfile({...
                '*.xls','Planilha MS Excel (*.xls)';...
                '*.txt;*.dat','Arquivo de texto (*.txt, *.dat)';...
                '*.xml','Arquivo de missão F-5M/A-29 (*.xml)'},...
            'Indique o arquivo de waypoints',handles.fpath); drawnow;
        if ~ischar(fname)
            return
        end
        
        if opt == 3 % xml
            try
                aux = scenarioread(fpath,fname,'wpt');
                wptnum = aux.wpt.data(:,1)';
                wptpos = aux.wpt.data(:,2:4);
                wptcod = aux.wpt.code;
            catch
                beep; uiwait(errordlg({'Não foi possível importar os waypoints.','Verifique o arquivo indicado.'},'Erro','modal'));
                return
            end
            
        else
            if opt == 1 % xls
                [data, txt] = xlsread([fpath fname]);
            else % txt
                [data, txt] = txtread([fpath fname]);
            end
            
            if isempty(data)
                beep; uiwait(errordlg({'O arquivo indicado não contém waypoints válidos.'},'Erro','modal'));
                return
            end
            
            for n = size(data,2):-1:1
                if all(isnan(data(:,n)))
                    data(:,n) = [];
                end
            end
            
            if size(data,2) ~= 4
                beep; uiwait(errordlg({'O arquivo indicado não contém waypoints válidos.'},'Erro','modal'));
                return
            end
            
            if     size(data,1) < size(txt,1)
                txt(1:size(txt,1)-size(data,1),:) = [];
            elseif size(data,1) > size(txt,1)
                txt = cell(size(data,1),1);
            end
            
            for n = 1:size(txt,1)
                for m = 1:size(txt,2)
                    if isempty(deblank(txt{n,m}))
                        txt{n,m} = '';
                    end
                end
            end
            wptnum = data(:,1)';
            wptpos = data(:,2:4);
            for n = 1:size(txt,1)
                wptcod{n} = '';
                for m = 1:size(txt,2)
                    wptcod{n} = [wptcod{n} txt{n,m}];
                end
            end
            
            rep = [];
            for n = 2:length(wptnum)
                if any(wptnum(n)==wptnum(1:n-1))
                    rep = [rep n];
                end
            end
            if ~isempty(rep)
                uiwait(warndlg('Os waypoints repetidos serão descartados.','Aviso','modal'));
                wptnum(rep)   = [];
                wptpos(rep,:) = [];
                wptcod(rep)   = [];
            end
            
        end
        
        % Validity check
        exc = [];
        for n = 1:length(wptcod)
            lat = wptpos(n,1);
            lon = wptpos(n,2);
            alt = wptpos(n,3);
            if isnan(wptnum(n)) || isnan(lat+lon+alt) || lat<-90 || lat>90 || lon<-180 || lon>180 || alt<-2000 || alt>100000
                exc = [exc n];
            end
        end
        if ~isempty(exc)
            uiwait(warndlg('Os waypoints com dados incoerentes serão descartados.','Aviso','modal'));
            wptnum(exc)   = [];
            wptpos(exc,:) = [];
            wptcod(exc)   = [];
        end
        trunc = 0;
        for n = 1:length(wptcod)
            if length(wptcod{n}) > 12
                wptcod{n} = wptcod{n}(1:12);
                trunc = 1;
            end
        end
        if trunc
            uiwait(warndlg('Os códigos com mais de 12 caracteres serão truncados.','Aviso','modal'));
        end
        
        if isempty(wptcod)
            beep; uiwait(errordlg({'O arquivo indicado não contém waypoints válidos.'},'Erro','modal'));
            return
        end
        
        if isempty(scenario.wpt)
            scenario.wpt.data = [];
            scenario.wpt.code = {};
        end
        
        ovrwt = 0;
        exc = [];
        for n = 1:length(wptcod)
            if ~isempty(scenario.wpt.data) && any(wptnum(n)==scenario.wpt.data(:,1))
                exc = [exc n];
            end
        end
        if ~isempty(exc)
            if length(exc)==1
                str1 = ['O waypoint ' num2str(wptnum(exc)) ' já está cadastrado.'];
                str2 = [];
            else
                str1 = 'Os seguintes waypoints já estão cadastrados:';
                str2 = strrep([num2str(wptnum(exc(1:end-1))) ' e ' num2str(wptnum(exc(end))) '.'],'  ',', ');
            end
            opt = RDAT_InputOption('Opção',{str1,str2,'','O que deseja fazer?'},...
                {'Sobrescrever com os novos waypoints','Manter os waypoints originais'},1,320); drawnow;
            if isempty(opt)
                return                
            elseif opt == 1
                ovrwt = 1;
            else
                wptnum(exc)   = [];
                wptpos(exc,:) = [];
                wptcod(exc)   = [];
            end
        end
        
        for n = 1:length(wptnum)
            N = size(scenario.wpt.data,1);
            if ovrwt && any(wptnum(n)==scenario.wpt.data(:,1))
                ni = find(wptnum(n)==scenario.wpt.data(:,1));
                scenario.wpt.data(ni,2:4) = wptpos(n,:);
                scenario.wpt.code{ni,1}   = wptcod{n};
            else
                scenario.wpt.data(N+1,:) = [wptnum(n) wptpos(n,:)];
                scenario.wpt.code{N+1,1} = wptcod{n};
            end
        end
        
        if ~isempty(scenario.wpt.data) && any(diff(scenario.wpt.data(:,1))<0)
            button = questdlg('Deseja reordenar os waypoints?','Opção','Sim','Não','Não');
            if strcmp(button,'Sim')
                [void, ind] = sort(scenario.wpt.data(:,1));
                scenario.wpt.data = scenario.wpt.data(ind,:);
                scenario.wpt.code = scenario.wpt.code(ind);
            end
        end
        
    case 'rt' % Routes
        
        if isempty(scenario.wpt) || isempty(scenario.wpt.data)
            beep; uiwait(errordlg('Não é possível importar rotas quando não há waypoints cadastrados.','Erro','modal'));
            return
        end
        
        [fname,fpath,opt] = uigetfile({...
                '*.xls','Planilha MS Excel (*.xls)';...
                '*.txt;*.dat','Arquivo de texto (*.txt, *.dat)';...
                '*.xml','Arquivo de missão F-5M/A-29 (*.xml)'},...
            'Indique o arquivo de rotas',handles.fpath); drawnow;
        if ~ischar(fname)
            return
        end
        
        if opt == 3 % xml
            try
                aux = scenarioread(fpath,fname,'rt');
                rt = aux.rt;
            catch
                beep; uiwait(errordlg({'Não foi possível importar as rotas.','Verifique o arquivo indicado.'},'Erro','modal'));
                return
            end
            
        else
            if opt == 1 % xls
                data = xlsread([fpath fname]);
            else % txt
                data = txtread([fpath fname]);
            end
            
            if isempty(data)
                return
            end
            for n = 1:size(data,1)
                rt(n).wpt = data(n,:);
                rt(n).wpt(isnan(rt(n).wpt)) = [];
            end
        end
        
        if isempty(rt) || isempty([rt.wpt])
            beep; uiwait(errordlg({'O arquivo indicado não contém rotas válidas.'},'Erro','modal'));
            return
        end
        
        if ~isempty(setdiff([rt.wpt],scenario.wpt.data(:,1)'))
            button = questdlg({'Alguns waypoints das rotas importadas não estão',...
                    'cadastrados e serão descartados.','','Deseja prosseguir?'},'Confirmação','Sim','Não','Não');
            if ~strcmp(button,'Sim')
                return
            end
            for n = 1:length(rt)
                for m = length(rt(n).wpt):-1:1
                    if ~any(rt(n).wpt(m)==scenario.wpt.data(:,1))
                        rt(n).wpt(m) = [];
                    end
                end
            end
        end
        
        for n = 1:length(rt)
            N = length(scenario.rt);
            scenario.rt(N+1).wpt = rt(n).wpt;
        end
        
    case 'fa' % Flight Areas
        [fname,fpath,opt] = uigetfile({...
                '*.xls','Planilha MS Excel (*.xls)';...
                '*.txt;*.dat','Arquivo de texto (*.txt, *.dat)';...
                '*.xml','Arquivo de missão F-5M/A-29 (*.xml)'},...
            'Indique o arquivo de área de voo',handles.fpath); drawnow;
        if ~ischar(fname)
            return
        end
        
        if opt == 3 % xml
            try
                aux = scenarioread(fpath,fname,'fa');
                fa = aux.fa;
            catch
                beep; uiwait(errordlg({'Não foi possível importar as áreas de voo.','Verifique o arquivo indicado.'},'Erro','modal'));
                return
            end
            
        else % xls, txt
            
            try
                data = mapread('line',[fpath fname]);
            catch
                beep; uiwait(errordlg({'Não foi possível importar as áreas de voo.','Verifique a formatação dos dados.'},'Erro','modal'));
                return
            end
            
            if isempty(data)
                beep; uiwait(errordlg({'O arquivo indicado está vazio.'},'Erro','modal'));
                return
            end
            
            data = [NaN NaN; data; NaN NaN];
            nnan = find(isnan(data(:,1)));
            for n = 1:length(nnan)-1
                out = inputvalues(['Importar ' num2str(n) 'ª FA'],{'Código:','Descrição:','Estilo:','Cor:'},{'','',{'Sólido','Pontilhado','Traço-ponto','Tracejado'},...
                        {'Azul','Verde','Vermelho','Ciano','Magenta','Amarelo'}}); drawnow;
                if isempty(out)
                    return
                end
                styles = {'-',':','-.','--'};
                colors = 'bgrcmy';
                fa(n).code  = out{1};
                fa(n).descr = out{2};
                fa(n).data = data(nnan(n)+1:nnan(n+1)-1,:);
                fa(n).style = styles{out{3}};
                fa(n).color = colors(out{4});
            end
            
        end
        
        % Validity check
        excd  = 0;
        trunc = 0;
        for n = 1:length(fa)
            exc = [];
            for m = 1:size(fa(n).data,1)
                lat = fa(n).data(m,1);
                lon = fa(n).data(m,2);
                if isnan(lat+lon) || lat<-90 || lat>90 || lon<-180 || lon>180
                    exc = [exc m];
                end
            end
            if ~isempty(exc)
                fa(n).data(exc,:) = [];
                excd = 1;
            end
            if length(fa(n).code) > 12
                fa(n).code = fa(n).code(1:12);
                trunc = 1;
            end
        end
        if excd
            uiwait(warndlg('Os vértices com dados incoerentes serão descartados.','Aviso','modal'));
        end
        if trunc
            uiwait(warndlg('Os códigos com mais de 12 caracteres serão truncados.','Aviso','modal'));
        end
        
        for n = 1:length(fa)
            if fa(n).data(end,1)~=fa(n).data(1,1) || fa(n).data(end,2)~=fa(n).data(1,2)
                fa(n).data(end+1,:) = fa(n).data(1,:);
            end
        end
        
        if isempty(fa)
            beep; uiwait(errordlg({'O arquivo indicado não contém áreas de voos válidas.'},'Erro','modal'));
            return
        end
        
        for n = 1:length(fa)
            N = length(scenario.fa);
            scenario.fa(N+1).code  = fa(n).code;
            scenario.fa(N+1).descr = fa(n).descr;
            scenario.fa(N+1).data  = fa(n).data;
            scenario.fa(N+1).style = fa(n).style;
            scenario.fa(N+1).color = fa(n).color;
        end
        
    case 'avd' % Avoid Zones
        [fname,fpath,opt] = uigetfile({...
                '*.xls','Planilha MS Excel (*.xls)';...
                '*.txt;*.dat','Arquivo de texto (*.txt, *.dat)';...
                '*.xml','Arquivo de missão F-5M/A-29 (*.xml)'},...
            'Indique o arquivo de avoid zones',handles.fpath); drawnow;
        if ~ischar(fname)
            return
        end
        
        if opt == 3 % xml
            try
                aux = scenarioread(fpath,fname,'avd');
                avd = aux.avd;
            catch
                beep; uiwait(errordlg({'Não foi possível importar as avoid zones.','Verifique o arquivo indicado.'},'Erro','modal'));
                return
            end
            
        else
            if opt == 1 % xls
                [data, txt] = xlsread([fpath fname]);
            else % txt
                [data, txt] = txtread([fpath fname]);
            end
            
            if isempty(data)
                beep; uiwait(errordlg({'O arquivo indicado não contém avoid zones válidas.'},'Erro','modal'));
                return
            end
            
            if size(data,2) ~= 3
                beep; uiwait(errordlg({'O arquivo indicado não contém avoid zones válidas.'},'Erro','modal'));
                return
            end
            
            if     size(data,1) < size(txt,1)
                txt(1:size(txt,1)-size(data,1),:) = [];
            elseif size(data,1) > size(txt,1)
                txt = cell(size(data,1),1);
            end
            
            for n = 1:size(txt,1)
                for m = 1:size(txt,2)
                    if isempty(deblank(txt{n,m}))
                        txt{n,m} = '';
                    end
                end
            end
            avd.data = data(:,1:3);
            for n = 1:size(txt,1)
                avd.code{n,1} = '';
                for m = 1:size(txt,2)
                    avd.code{n,1} = [avd.code{n} txt{n,m}];
                end
            end
            
        end
        
        % Validity check        
        if isempty(avd)
            avd.data = [];
            avd.code = {};
        end
        
        exc = [];
        for n = 1:size(avd.data,1)
            lat = avd.data(n,1);
            lon = avd.data(n,2);
            R   = avd.data(n,3);
            if isnan(lat+lon+R) || lat<-90 || lat>90 || lon<-180 || lon>180 || R<=0 || R>300
                exc = [exc n];
            end
        end
        if ~isempty(exc)
            uiwait(warndlg('As avoid zones com dados incoerentes serão descartadas.','Aviso','modal'));
            avd.data(exc,:) = [];
            avd.code(exc)   = [];
        end
        trunc = 0;
        for n = 1:length(avd.code)
            if length(avd.code{n}) > 12
                avd.code{n} = avd.code{n}(1:12);
                trunc = 1;
            end
        end
        if trunc
            uiwait(warndlg('Os códigos com mais de 12 caracteres serão truncados.','Aviso','modal'));
        end
        
        if isempty(avd) || isempty(avd.data)
            beep; uiwait(errordlg({'O arquivo indicado não contém avoid zones válidas.'},'Erro','modal'));
            return
        end       
        
        if isempty(scenario.avd)
            scenario.avd.data = [];
            scenario.avd.code = {};
        end
        
        for n = 1:size(avd.data,1)
            N = size(scenario.avd.data,1);
            scenario.avd.code{N+1,1} = avd.code{n};
            scenario.avd.data(N+1,:) = avd.data(n,:);
        end
        
    case 'thr' % Threat Areas
        [fname,fpath,opt] = uigetfile({...
                '*.xls','Planilha MS Excel (*.xls)';...
                '*.txt;*.dat','Arquivo de texto (*.txt, *.dat)';...
                '*.xml','Arquivo de missão F-5M/A-29 (*.xml)'},...
            'Indique o arquivo de ameaças',handles.fpath); drawnow;
        if ~ischar(fname)
            return
        end
        
        if opt == 3 % xml
            try
                aux = scenarioread(fpath,fname,'thr');
                thr = aux.thr;
            catch
                beep; uiwait(errordlg({'Não foi possível importar as ameaças.','Verifique o arquivo indicado.'},'Erro','modal'));
                return
            end
            
        else
            if opt == 1 % xls
                [data, txt] = xlsread([fpath fname]);
            else % txt
                [data, txt] = txtread([fpath fname]);
            end
            
            if isempty(data)
                beep; uiwait(errordlg({'O arquivo indicado não contém ameaças válidas.'},'Erro','modal'));
                return
            end
            
            if size(data,2) ~= 6
                beep; uiwait(errordlg({'O arquivo indicado não contém ameaças válidas.'},'Erro','modal'));
                return
            end
            
            if     size(data,1) < size(txt,1)
                txt(1:size(txt,1)-size(data,1),:) = [];
            elseif size(data,1) > size(txt,1)
                txt = cell(size(data,1),1);
            end
            
            for n = 1:size(txt,1)
                for m = 1:size(txt,2)
                    if isempty(deblank(txt{n,m}))
                        txt{n,m} = '';
                    end
                end
            end
            thr.data = data(:,1:6);
            for n = 1:size(txt,1)
                thr.code{n,1} = '';
                for m = 1:size(txt,2)
                    thr.code{n,1} = [thr.code{n} txt{n,m}];
                end
            end
            
        end
        
        % Validity check
        if isempty(thr)
            thr.data = [];
            thr.code = {};
        end
        
        exc = [];
        for n = 1:size(thr.data,1)
            lat  = thr.data(n,1);
            lon  = thr.data(n,2);
            Alt1 = thr.data(n,3);
            Alt2 = thr.data(n,4);
            R1   = thr.data(n,5);
            R2   = thr.data(n,6);
            if isnan(lat+lon+Alt1+Alt2+R1+R2) || lat<-90 || lat>90 || lon<-180 || lon>180 || Alt1<-2000 || Alt1>100000 || Alt2<-2000 || Alt2>100000 || Alt1>=Alt2 || R1<0 || R1>300 || R2<0 || R2>300
                exc = [exc n];
            end
        end
        if ~isempty(exc)
            uiwait(warndlg('As ameaças com dados incoerentes serão descartadas.','Aviso','modal'));
            thr.data(exc,:) = [];
            thr.code(exc)   = [];
        end
        trunc = 0;
        for n = 1:length(thr.code)
            if length(thr.code{n}) > 12
                thr.code{n} = thr.code{n}(1:12);
                trunc = 1;
            end
        end
        if trunc
            uiwait(warndlg('Os códigos com mais de 12 caracteres serão truncados.','Aviso','modal'));
        end
        
        if isempty(thr) || isempty(thr.data)
            beep; uiwait(errordlg({'O arquivo indicado não contém ameaças válidas.'},'Erro','modal'));
            return
        end        
        
        if isempty(scenario.thr)
            scenario.thr.data = [];
            scenario.thr.code = {};
        end
        
        for n = 1:size(thr.data,1)
            N = size(scenario.thr.data,1);
            scenario.thr.code{N+1,1} = thr.code{n};
            scenario.thr.data(N+1,:) = thr.data(n,:);
        end
        
    case 'cnt' % Contact Line
        if ~isempty(scenario.cnt) && ~isempty(scenario.cnt.data)
            button = questdlg('Deseja substituir a linha de contato atual?','Confirmação','Sim','Não','Não');
            if ~strcmp(button,'Sim')
                return
            end
        end
        
        [fname,fpath,opt] = uigetfile({...
                '*.xls','Planilha MS Excel (*.xls)';...
                '*.txt;*.dat','Arquivo de texto (*.txt, *.dat)';...
                '*.xml','Arquivo de missão F-5M/A-29 (*.xml)'},...
            'Indique o arquivo de linha de contato',handles.fpath); drawnow;
        if ~ischar(fname)
            return
        end
        
        if opt == 3 % xml
            try
                aux = scenarioread(fpath,fname,'cnt');
                cnt = aux.cnt;
            catch
                beep; uiwait(errordlg({'Não foi possível importar a linha de contato.','Verifique o arquivo indicado.'},'Erro','modal'));
                return
            end
            if isempty(cnt)
                beep; uiwait(errordlg({'O arquivo indicado está vazio.'},'Erro','modal'));
                return
            end        
            
        else % xls, txt
            try
                cnt.data = mapread('line',[fpath fname]);
            catch
                beep; uiwait(errordlg({'Não foi possível importar a linha de contato.','Verifique a formatação dos dados.'},'Erro','modal'));
                return
            end
            
            if isempty(cnt.data)
                beep; uiwait(errordlg({'O arquivo indicado está vazio.'},'Erro','modal'));
                return
            end
            
            cnt.data(isnan(cnt.data(:,1)),:) = [];
            
            if isempty(cnt) || isempty(cnt.data)
                beep; uiwait(errordlg({'O arquivo indicado não contém linha de contato válida.'},'Erro','modal'));
                return
            end        
            
        end
        
        % Validity check
        exc = [];
        for n = 1:size(cnt.data,1)
            lat  = cnt.data(n,1);
            lon  = cnt.data(n,2);
            if isnan(lat+lon) || lat<-90 || lat>90 || lon<-180 || lon>180
                exc = [exc n];
            end
        end
        if ~isempty(exc)
            uiwait(warndlg('Os vértices com dados incoerentes serão descartados.','Aviso','modal'));
            cnt.data(exc,:) = [];
        end        
        
        if isempty(cnt) || isempty(cnt.data)
            beep; uiwait(errordlg({'O arquivo indicado não contém linha de contato válida.'},'Erro','modal'));
            return
        end        
        
        N = 0;
        scenario.cnt.data = cnt.data;
        
end

if ~isequalwithequalnans(scenario,oldscenario)
    handles.chg = 1;
    guidata(hObject, handles);
    
    setscenario(hObject, eventdata, handles, scenario, ntype);
    type_sel(hObject, eventdata, handles, N+1);
    fit_btn_Callback(hObject, eventdata, handles);
end

% --------------------------------------------------------------------
function save_btn_Callback(hObject, eventdata, handles)
% Salva cenario em arquivo

[fname, fpath] = uiputfile({'*.mat','Arquivo mat (*.mat)'},'Salvar cenário',[handles.fpath handles.fname]);

if ischar(fname)
    
    scenario = getappdata(handles.window,'scenario');
    
    try
        if ~exist([fpath fname],'file')
            save([fpath fname],'scenario',saveopt);
        else
            save([fpath fname],'scenario','-append',saveopt);
        end
    catch
        beep; uiwait(errordlg(lasterr,'Erro','modal')); drawnow;
        return
    end
    
    handles.fname = fname;
    handles.fpath = fpath;
    guidata(hObject, handles);
    
end

% ---------------------------------------------------------------
function export_btn_Callback(hObject, eventdata, handles)
% Exportar cenario para Google Earth

scenario = getappdata(handles.window,'scenario');

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
        kmldata(N+1).data   = [get(handles.avd(n),'YData')' get(handles.avd(n),'XData')'];
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
        kmldata(N+1).data   = [get(handles.thr(n),'YData')' get(handles.thr(n),'XData')'];
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
    beep; uiwait(errordlg('O cenário está vazio.','Erro','modal')); drawnow;
    return
end

[fname,fpath] = uiputfile({'*.kml','Arquivo Google Earth (*.kml)'},'Exportar cenário',handles.fpath); drawnow;

if ischar(fname)
    
    set(handles.window,'Pointer','watch');
    
    try
        
        fname = SetFileExtension(fname,'kml');
        for m = 1:length(kmldata)
            if size(kmldata(m).data,2) == 3
                kmldata(m).data(:,3) = kmldata(m).data(:,3)*.3048; % ft -> m
            end
        end
        kmlwrite(kmldata,[fpath fname],'Cenário');
        
        handles.fpath = fpath;
        guidata(hObject, handles);
        
    catch
        beep; uiwait(errordlg(lasterr,'Erro','modal')); drawnow;
    end
    
    set(handles.window,'Pointer','arrow');
end

window_WindowButtonMotionFcn(hObject, eventdata, handles);

% ---------------------------------------------------------------
function export_extfile(hObject, eventdata, handles)
% Exportar objetos selecionados para arquivos xls ou kml

ntype = getappdata(handles.window,'ntype');
n     = get(handles.obj_list,'Value');
scenario = getappdata(handles.window,'scenario');

if isempty(get(handles.obj_list,'String'))
    beep;
    return
end

kmldata = [];

switch ntype
    case 'map' % Maps
        beep;
        return
        
    case 'aux' % Auxiliary Shapes
        if isempty(scenario.aux) || isempty(scenario.aux(n).data)
            beep; uiwait(errordlg('O objeto auxiliar selecionado está vazio.','Erro','modal')); drawnow;
            return
        end
        switch scenario.aux(n).type
            case 'point'
                head = {'Código','Latitude','Longitude'};
                data = scenario.aux(n).data;
                data = [scenario.aux(n).code num2cell(data)];
                kmldata.data   = scenario.aux(n).data(:,1:2);
                kmldata.type   = scenario.aux(n).type;
                kmldata.name   = scenario.aux(n).code;
                kmldata.descr  = '';
                kmldata.folder = ['Objeto auxiliar - ' scenario.aux(n).name];
                kmldata.color  = scenario.aux(n).color;
                kmldata.width  = scenario.aux(n).width;
            case {'line','area'}
                data = scenario.aux(n).data;
                head = {'Latitude','Longitude'};
                kmldata.data   = scenario.aux(n).data(:,1:2);
                kmldata.type   = scenario.aux(n).type;
                kmldata.name   = scenario.aux(n).name;
                kmldata.descr  = '';
                kmldata.folder = 'Objetos auxiliares';
                kmldata.color  = scenario.aux(n).color;
                kmldata.width  = scenario.aux(n).width;
            case 'text'
                head = {'Texto','Latitude','Longitude','Orientação','Alinhamento'};
                data = scenario.aux(n).data;
                data = [scenario.aux(n).code num2cell(data)];
        end
        str = 'objeto auxiliar';
        
    case 'aid' % Nav Aids
        if isempty(scenario.aid) || isempty(scenario.aid.data)
            beep;
            return
        end
        head = {'Código','Tipo','Latitude','Longitude','Elevação (ft)','Proa (°)'};
        data = scenario.aid.data(n,:);
        data = [scenario.aid.code(n) scenario.aid.type(n) num2cell(data)];
        str = 'auxílios/aeródromos';
        
        kmldata.data   = scenario.aid.data(n,1:3);
        kmldata.type   = 'point';
        kmldata.name   = scenario.aid.code(n);
        for m = 1:length(n)
            kmldata.descr{m} = scenario.aid.type{n(m)};
        end
        kmldata.folder = 'Auxílios/Aeródromos';
        kmldata.color  = [0 .5 1];
        kmldata.width  = 1;

    case 'wpt' % Waypoints
        if isempty(scenario.wpt) || isempty(scenario.wpt.data)
            beep;
            return
        end
        head = {'Código','Número','Latitude','Longitude','Elevação (ft)'};
        data = scenario.wpt.data(n,:);
        data = [scenario.wpt.code(n) num2cell(data)];
        str = 'waypoints';
        
        kmldata.data   = scenario.wpt.data(n,2:4);
        kmldata.type   = 'point';
        for m = 1:length(n)
            kmldata.name{m} = [num2str(scenario.wpt.data(n(m),1),'%02.0f') ' - ' scenario.wpt.code{n(m)}];
        end
        kmldata.descr  = '';
        kmldata.folder = 'Waypoints';
        kmldata.color  = 'm';
        kmldata.width  = 1;
        
    case 'rt' % Routes
        if isempty(scenario.rt)
            beep;
            return
        end
        head = {};
        data = {};
        str = 'rotas';
        for m = 1:length(n)
            wpt = scenario.rt(n(m)).wpt;
            if ~isempty(wpt)
                data{m,1} = ['Rota ' num2str(n(m))];
                data(m,2:length(wpt)+1) = num2cell(wpt);
            end
        end
        if isempty(data)
            if length(n)==1
                str = 'A rota selecionada não contém waypoints.';
            else
                str = 'As rotas selecionadas não contêm waypoints.';
            end                
            beep; uiwait(errordlg(str,'Erro','modal')); drawnow;
            return
        end
        
        for m = 1:length(n)
            wpt = scenario.rt(n(m)).wpt;
            nwpt = [];
            for k = 1:length(wpt)
                nwpt = [nwpt find(wpt(k)==scenario.wpt.data(:,1))];
            end
            kmldata(m).data   = scenario.wpt.data(nwpt,2:4);
            kmldata(m).type   = 'line';
            kmldata(m).name   = ['Rota ' num2str(n(m))];
            kmldata(m).descr  = '';
            kmldata(m).folder = 'Rotas';
            kmldata(m).color  = 'm';
            kmldata(m).width  = 2;
        end
        
    case 'fa' % Flight Areas
        if isempty(scenario.fa)
            beep;
            return
        end
        head = {'Latitude','Longitude'};
        data = [];
        str = 'áreas de voo';
        for k = n
            if ~isempty(scenario.fa(k).data)
                if isempty(data)
                    data = scenario.fa(k).data;
                else
                    data = [data; NaN NaN; scenario.fa(k).data];
                end
            end
        end
        if isempty(data)
            if length(n)==1
                str = 'A área selecionada não contém vértices.';
            else
                str = 'As áreas selecionadas não contêm vértices.';
            end                
            beep; uiwait(errordlg(str,'Erro','modal')); drawnow;
            return
        end
        
        for m = 1:length(n)
            kmldata(m).data   = scenario.fa(n(m)).data;
            kmldata(m).type   = 'line';
            kmldata(m).name   = scenario.fa(n(m)).code;
            kmldata(m).descr  = scenario.fa(n(m)).descr;
            kmldata(m).color  = scenario.fa(n(m)).color;
            kmldata(m).folder = 'Áreas de voo';
            kmldata(m).width  = 2;
        end
        
    case 'avd' % Avoid Zones
        if isempty(scenario.avd) || isempty(scenario.avd.data)
            beep;
            return
        end
        head = {'Código','Latitude','Longitude','Raio (NM)'};
        data = scenario.avd.data(n,:);
        data = [scenario.avd.code(n) num2cell(data)];
        str = 'avoid zones';
        
        for m = 1:length(n)
            kmldata(m).data   = [get(handles.avd(n(m)),'YData')' get(handles.avd(n(m)),'XData')'];
            kmldata(m).type   = 'line';
            kmldata(m).name   = scenario.avd.code{n(m)};
            kmldata(m).descr  = '';
            kmldata(m).color  = 'y';
            kmldata(m).folder = 'Avoid zones';
            kmldata(m).width  = 2;
        end
        
    case 'thr' % Threat Areas
        if isempty(scenario.thr) || isempty(scenario.thr.data)
            beep;
            return
        end
        head = {'Código','Latitude','Longitude','Altitude 1 (ft)','Altitude 2 (ft)','Raio 1 (NM)','Raio 2 (NM)'};
        data = scenario.thr.data(n,:);
        data = [scenario.thr.code(n) num2cell(data)];
        str = 'ameaças';
        
        for m = 1:length(n)
            kmldata(m).data   = [get(handles.thr(n(m)),'YData')' get(handles.thr(n(m)),'XData')'];
            kmldata(m).type   = 'line';
            kmldata(m).name   = scenario.thr.code{n(m)};
            kmldata(m).descr  = '';
            kmldata(m).color  = 'r';
            kmldata(m).folder = 'Ameaças';
            kmldata(m).width  = 2;
        end

    case 'cnt' % Contact Line
        if isempty(scenario.cnt) || isempty(scenario.cnt.data)
            beep; uiwait(errordlg('A linha de contato não contém vértices.','Erro','modal')); drawnow;
            return
        end
        head = {'Latitude','Longitude'};
        data = scenario.cnt.data;
        str = 'linha de contato';
        
        kmldata.data   = scenario.cnt.data;
        kmldata.type   = 'line';
        kmldata.name   = 'Linha de contato';
        kmldata.descr  = '';
        kmldata.folder = 'Linhas de contato';
        kmldata.color  = 'r';
        kmldata.width  = 2;
        
end

if ~isempty(kmldata)
    [fname,fpath,opt] = uiputfile({'*.xls','Planilha MS Excel (*.xls)';'*.kml','Arquivo Google Earth (*.kml)'},...
        ['Exportar ' str],handles.fpath); drawnow;
else
    [fname,fpath,opt] = uiputfile({'*.xls','Planilha MS Excel (*.xls)'},...
        ['Exportar ' str],handles.fpath); drawnow;
end

if opt == 1 && size(data,1)+1 > 65536
    uiwait(warndlg({'Planilha Excel limitada a 65.536 linhas.','Parte dos dados será perdida.'},'Aviso','modal')); drawnow;
    data(65536:end,:) = [];
end

if ischar(fname)
    
    set(handles.window,'Pointer','watch');
    
    try
        switch opt
            
            case 1 % xls
                fname = SetFileExtension(fname,'xls');
                if exist([fpath fname],'file')
                    lastwarn('');
                    delete([fpath fname]);
                    if ~isempty(lastwarn)
                        beep; uiwait(errordlg(lastwarn,'Erro','modal')); drawnow;
                        return
                    end
                end
                xlswrite(data,[],head,[fpath fname]);
                
                Excel = actxserver('Excel.Application');
                op = invoke(Excel.Workbooks, 'open', [fpath fname]);
                set(Excel, 'Visible', 1);
                delete(Excel);
                
            case 2 % kml
                
                fname = SetFileExtension(fname,'kml');
                for m = 1:length(kmldata)
                    if size(kmldata(m).data,2) == 3
                        kmldata(m).data(:,3) = kmldata(m).data(:,3)*.3048; % ft -> m
                    end
                end
                kmlwrite(kmldata,[fpath fname],'Cenário');

        end
        
        handles.fpath = fpath;
        guidata(hObject, handles);
        
    catch
        beep; uiwait(errordlg(lasterr,'Erro','modal')); drawnow;
    end
    
    set(handles.window,'Pointer','arrow');
end

window_WindowButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function mapdb_btn_Callback(hObject, eventdata, handles)
% Abre o editor da base de dados de mapas

chg = RDAT_EditMaps; drawnow;
if chg
    scenario = getappdata(handles.window,'scenario');
    setscenario(hObject, eventdata, handles, scenario);
    type_sel(hObject, eventdata, handles);
end

% --------------------------------------------------------------------
function fit_btn_Callback(hObject, eventdata, handles, keepzoombtn, fitobj)
% Ajusta o zoom

if nargin <= 3
    keepzoombtn = 0;
end
if nargin <= 4
    fitobj = 0;
end

if ~keepzoombtn
    set([handles.zoom_btn handles.drag_btn],'Value',0);
end

xmin = NaN; xmax = NaN;
ymin = NaN; ymax = NaN;

if fitobj % Ajustar ao objeto selecionado
    
    N = get(handles.obj_list,'Value');
    ntype = getappdata(handles.window,'ntype');
    
    switch ntype
        
        case 'map' % Map
            if isempty(handles.map)
                return
            else
                Hplots = handles.map(N);
                Htexts = [];
            end
            
        case 'aux' % Auxiliary Shapes
            if isempty(handles.aux)
                return
            else
                Hplots = handles.aux(N);
                if length(handles.auxlbl)>=N
                    Htexts = handles.auxlbl{N};
                else
                    Htexts = [];
                end
            end
            
        case 'aid' % Nav Aids
            if isempty(handles.aid)
                return
            else
                Hplots = [];
                Htexts = handles.aid(N);
            end
            
        case 'wpt' % Waypoints
            if isempty(handles.wpt)
                return
            else
                Hplots = [];
                Htexts = handles.wptcodlbl(N);
            end
            
        case 'rt' % Routes
            if isempty(handles.rt)
                return
            else
                Hplots = handles.rt(N);
                Htexts = [];
            end
            
        case 'fa' % Flight areas
            if isempty(handles.fa)
                return
            else
                Hplots = handles.fa(N);
                Htexts = [];
            end
            
        case 'avd' % Avoid zones
            if isempty(handles.avd)
                return
            else
                Hplots = handles.avd(N);
                Htexts = [];
            end
            
        case 'thr' % Threat areas
            if isempty(handles.thr)
                return
            else
                Hplots = handles.thr(N);
                Htexts = [];
            end
            
        case 'cnt' % Contact line
            if isempty(handles.cnt)
                return
            else
                Hplots = handles.cnt;
                Htexts = [];
            end
    end
else
    Hplots = [findobj(handles.TSD,'Type','line'); findobj(handles.TSD,'Type','patch'); findobj(handles.TSD,'Type','image')];
    Htexts = setdiff(findobj(handles.TSD,'Type','text'),[handles.lbl handles.rulertag1 handles.rulertag2]);
end

% Plots
for n = 1:length(Hplots)
    x1 = min(min(get(Hplots(n),'XData')));
    if ~isempty(x1), xmin = min(xmin, x1); end
    x2 = max(max(get(Hplots(n),'XData')));
    if ~isempty(x2), xmax = max(xmax, x2); end
    y1 = min(min(get(Hplots(n),'YData')));
    if ~isempty(y1), ymin = min(ymin, y1); end
    y2 = max(max(get(Hplots(n),'YData')));
    if ~isempty(y2), ymax = max(ymax, y2); end
end

% Texts
for n = 1:length(Htexts)
    xmin = min(xmin,sum(get(Htexts(n),'Position').*[1 0 0]));
    xmax = max(xmax,sum(get(Htexts(n),'Position').*[1 0 0]));
    ymin = min(ymin,sum(get(Htexts(n),'Position').*[0 1 0]));
    ymax = max(ymax,sum(get(Htexts(n),'Position').*[0 1 0]));
end

if fitobj && isnan(xmin)
    return
end

x0 = -46;
y0 = -23;

if isnan(xmin), xmin = x0-1; end
if isnan(xmax), xmax = x0+1; end
if isnan(ymin), ymin = y0-1; end
if isnan(ymax), ymax = y0+1; end

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

% --------------------------------------------------------------------
function fitobj_btn_Callback(hObject, eventdata, handles)
% Ajusta o zoom ao objeto selecionado

fit_btn_Callback(hObject, eventdata, handles, 1, 1);

% --------------------------------------------------------------------
function zoom_btn_Callback(hObject, eventdata, handles)
% Zoom com o mouse

set([handles.drag_btn handles.getobj_btn handles.getparam_btn],'Value',0);
window_WindowButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function drag_btn_Callback(hObject, eventdata, handles)
% Arrastar com o mouse

set([handles.zoom_btn handles.getobj_btn handles.getparam_btn],'Value',0);
window_WindowButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function ruler_btn_Callback(hObject, eventdata, handles)
% Exibe / oculta regua

if get(handles.ruler_btn,'Value')
    
    xr = get(handles.ruler,'XData');
    yr = get(handles.ruler,'YData');
    
    if all(isnan(xr))
        ax = get(handles.TSD,'XLim');
        ay = get(handles.TSD,'YLim');
        xr = mean(ax)*[1 1]+diff(ax)*[-.25 .25];
        yr = mean(ay)*[1 1];
        set(handles.ruler,'XData',xr,'YData',yr,'Visible','on');
    end
    
    set([handles.ruler handles.rulertag1 handles.rulertag2],'Visible','on');
    updaterulertags(hObject, eventdata, handles);
    
else
    set([handles.ruler handles.rulertag1 handles.rulertag2],'Visible','off');
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

helpme('Ferramentas\editorcenario');

% --------------------------------------------------------------------
function sel_map_Callback(hObject, eventdata, handles)
set(handles.sel_list,'Value',0);
set(handles.sel_map,'Value',1);
setappdata(handles.window,'ntype','map');
type_sel(hObject, eventdata, handles);

% --------------------------------------------------------------------
function sel_aux_Callback(hObject, eventdata, handles)
set(handles.sel_list,'Value',0);
set(handles.sel_aux,'Value',1);
setappdata(handles.window,'ntype','aux');
type_sel(hObject, eventdata, handles);

% --------------------------------------------------------------------
function sel_aid_Callback(hObject, eventdata, handles)
set(handles.sel_list,'Value',0);
set(handles.sel_aid,'Value',1);
setappdata(handles.window,'ntype','aid');
type_sel(hObject, eventdata, handles);

% --------------------------------------------------------------------
function sel_wpt_Callback(hObject, eventdata, handles)
set(handles.sel_list,'Value',0);
set(handles.sel_wpt,'Value',1);
setappdata(handles.window,'ntype','wpt');
type_sel(hObject, eventdata, handles);

% --------------------------------------------------------------------
function sel_rt_Callback(hObject, eventdata, handles)
set(handles.sel_list,'Value',0);
set(handles.sel_rt,'Value',1);
setappdata(handles.window,'ntype','rt');
type_sel(hObject, eventdata, handles);

% --------------------------------------------------------------------
function sel_fa_Callback(hObject, eventdata, handles)
set(handles.sel_list,'Value',0);
set(handles.sel_fa,'Value',1);
setappdata(handles.window,'ntype','fa');
type_sel(hObject, eventdata, handles);

% --------------------------------------------------------------------
function sel_avd_Callback(hObject, eventdata, handles)
set(handles.sel_list,'Value',0);
set(handles.sel_avd,'Value',1);
setappdata(handles.window,'ntype','avd');
type_sel(hObject, eventdata, handles);

% --------------------------------------------------------------------
function sel_thr_Callback(hObject, eventdata, handles)
set(handles.sel_list,'Value',0);
set(handles.sel_thr,'Value',1);
setappdata(handles.window,'ntype','thr');
type_sel(hObject, eventdata, handles);

% --------------------------------------------------------------------
function sel_cnt_Callback(hObject, eventdata, handles)
set(handles.sel_list,'Value',0);
set(handles.sel_cnt,'Value',1);
setappdata(handles.window,'ntype','cnt');
type_sel(hObject, eventdata, handles);

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

%--------------------------------------------------------------------------
function addobj_btn_Callback(hObject, eventdata, handles, ins)
% Acrescentar objeto à lista

if nargin == 3
    ins = 0;
end

N = max(get(handles.obj_list,'Value'));
ntype = getappdata(handles.window,'ntype');
scenario = getappdata(handles.window,'scenario');
oldscenario = scenario;

switch ntype
    case 'map' % Maps
        if ~exist(which('DatMaps.mat'),'file')
            beep; uiwait(errordlg('Base de dados de mapas não encontrada.','Erro','modal'));
            return
        end
        load(which('DatMaps.mat'),'mapdb');
        if isempty(mapdb.mapname)
            beep; uiwait(errordlg('Não há mapas cadastrados.','Erro','modal'));
            return
        end
        if isempty(scenario.map)
            freemaps = sort(mapdb.mapname);
        else
            freemaps = setdiff(mapdb.mapname,{scenario.map.name});
        end
        if isempty(freemaps)
            beep; uiwait(errordlg('Não há mais mapas disponíveis.','Erro','modal'));
            return
        end
        
        sel = listdlg2('Name','Inserir mapas','HeaderString','Mapas disponíveis:','SelectionMode','multiple','ListString',freemaps,...
            'OKString','OK','CancelString','Cancela','SelectAllString','Selecionar tudo','SelectNoneString','Limpar','ListSize',[160 305]); drawnow;
        
        if isempty(sel)
            return
        end
        
        for n = 1:length(sel)
            newmap(n).name = freemaps{sel(n)};
            newmap(n).data = NaN*ones(4,2);
        end
        
        if ins && N < length(scenario.map)
            scenario.map = cat(2,scenario.map(1:N),newmap,scenario.map(N+1:end));
        else
            scenario.map = cat(2,scenario.map,newmap);
        end
        N = min(length(scenario.map),N+length(sel))-1;
        
        ntype = 'all';
        
    case 'aux' % Auxiliary Shapes
        out = inputvalues('Novo obj. aux.',{'Nome:','Tipo:        Estilo:','Cor:','Espessura (px):'},...
            {'',{'Linha      Sólido','Linha      Pontilhado','Linha      Traço-ponto','Linha      Tracejado',...
                    'Pontos    Ponto','Pontos    Círculo','Pontos    Losango','Pontos    Quadrado','Pontos    Triângulo','Pontos    Estrela',...
                    'Área        Opaco','Texto'},...
                {'Azul','Verde','Vermelho','Ciano','Magenta','Amarelo','Branco','Personalizar'},...
                [cellstr(num2str((1:8)'))' {2}] }); drawnow;
        if isempty(out)
            return
        end
        types = {'line','line','line','line','point','point','point','point','point','point','area','text'};
        styles = {'-',':','-.','--','.','o','d','s','^','p','A','T'};
        colors = 'bgrcmyw';
        auxname = out{1};
        auxtype = types{out{2}};
        auxstyle = styles{out{2}};
        if out{3} == 8
            auxcolor = uisetcolor([1 1 1],'Cor do objeto auxiliar:');
            if length(auxcolor) == 3
                auxcolor = roundn(auxcolor,-3);
            else
                return
            end
        else
            auxcolor = colors(out{3});
        end
        if out{2} <= 4 % Line
            auxwidth = out{4};
        elseif out{2} <= 10 % Point
            auxwidth = min(2,out{4});
        else % Area, Text
            auxwidth = 1;
        end
        
        newaux.name  = auxname;
        newaux.type  = auxtype;
        newaux.style = auxstyle;
        newaux.color = auxcolor;
        newaux.width = auxwidth;
        newaux.data  = [];
        newaux.code  = {};
        
        if ins && N < length(scenario.aux)
            scenario.aux = cat(2,scenario.aux(1:N),newaux,scenario.aux(N+1:end));
        else
            N = length(scenario.aux);
            scenario.aux = cat(2,scenario.aux,newaux);
        end
        
    case 'aid' % Nav Aids
        namelist = {'NDB','VOR','VOR/DME','DME','Fixo','Aeródromo'};
        typelist = {'NDB','VOR','VOR/DME','DME','FIX' ,'AFLD'     };
        out = inputvalues('Novo NavAid',{'Tipo:','Código:','Latitude:','Longitude:','Elevação (ft):','Proa (aeródromo):'},{namelist,'','','','0',''}); drawnow;
        if isempty(out)
            return
        end
        typ = typelist{out{1}};
        cod = out{2};
        [void, lat] = latlongread(out{3});
        [void, lon] = latlongread(out{4});
        alt = str2double(out{5});
        psi = str2double(out{6});
        if isempty(lat) || isempty(lon) || lat<-90 || lat>90 || lon<-180 || lon>180
            beep; uiwait(errordlg('Coordenadas incoerentes.','Erro','modal'));
            return
        end
        if isnan(alt) || alt<-2000 || alt>100000
            beep; uiwait(errordlg('Elevação incoerente.','Erro','modal'));
            return
        end
        if ~istype(typ,'AFLD')
            psi = NaN;
        elseif isnan(psi) || psi<0 || psi>360
            beep; uiwait(errordlg('Proa incoerente.','Erro','modal'));
            return
        end
        if length(cod) > 12
            cod = cod(1:12);
            uiwait(warndlg('Código truncado em 12 caracteres.','Aviso','modal'));
        end
        if isempty(scenario.aid)
            scenario.aid.code = {};
            scenario.aid.type = {};
            scenario.aid.data = [];
        end
        if ins && N < length(scenario.aid.code)
            scenario.aid.code = [scenario.aid.code(1:N)  ; {cod}          ; scenario.aid.code(N+1:end)];
            scenario.aid.type = [scenario.aid.type(1:N)  ; {typ}          ; scenario.aid.type(N+1:end)];
            scenario.aid.data = [scenario.aid.data(1:N,:); lat lon alt psi; scenario.aid.data(N+1:end,:)];
        else
            N = length(scenario.aid.code);
            scenario.aid.code{N+1,1} = cod;
            scenario.aid.type{N+1,1} = typ;
            scenario.aid.data(N+1,:) = [lat lon alt psi];
        end
        
    case 'wpt' % Waypoints
        if isempty(scenario.wpt) || isempty(scenario.wpt.data)
            nxtwpt = '1';
        else
            nxtwpt = num2str(max(scenario.wpt.data(:,1))+1);
        end
        out = inputvalues('Novo WPT',{'Número:','Código:','Latitude:','Longitude:','Elevação (ft):'},{nxtwpt,'','','','0'}); drawnow;
        if isempty(out)
            return
        end
        num = str2double(out{1});
        cod = out{2};
        [void, lat] = latlongread(out{3});
        [void, lon] = latlongread(out{4});
        alt = str2double(out{5});
        if num == 0 || ( num > 0 && ~rem(num,round(num)) )
            if isfield(scenario.wpt,'data') && any(num==scenario.wpt.data(:,1))
                beep; uiwait(errordlg(['Waypoint ' num2str(num) ' já cadastrado.'],'Erro','modal'));
                return
            end
        else
            beep; uiwait(errordlg('Número indicado incoerente.','Erro','modal'));
            return
        end
        if isempty(lat) || isempty(lon) || lat<-90 || lat>90 || lon<-180 || lon>180
            beep; uiwait(errordlg('Coordenadas incoerentes.','Erro','modal'));
            return
        end
        if isnan(alt) || alt<-2000 || alt>100000
            beep; uiwait(errordlg('Elevação incoerente.','Erro','modal'));
            return
        end
        if length(cod) > 12
            cod = cod(1:12);
            uiwait(warndlg('Código truncado em 12 caracteres.','Aviso','modal'));
        end
        if isempty(scenario.wpt)
            scenario.wpt.code = {};
            scenario.wpt.data = [];
        end
        if ins && N < length(scenario.wpt.code)
            scenario.wpt.code = [scenario.wpt.code(1:N)  ; {cod}          ; scenario.wpt.code(N+1:end)];
            scenario.wpt.data = [scenario.wpt.data(1:N,:); num lat lon alt; scenario.wpt.data(N+1:end,:)];
        else
            N = length(scenario.wpt.code);
            scenario.wpt.code{N+1,1} = cod;
            scenario.wpt.data(N+1,:) = [num lat lon alt];
        end
        
    case 'rt' % Routes
        button = questdlg('Deseja criar nova rota?','Confirmação','Sim','Não','Não');
        if strcmp(button,'Sim')
            newrt.wpt = [];
            if ins && N < length(scenario.rt)
                scenario.rt = cat(2,scenario.rt(1:N),newrt,scenario.rt(N+1:end));
            else
                N = length(scenario.rt);
                scenario.rt = cat(2,scenario.rt,newrt);
            end
        end
        
    case 'fa' % Flight Areas
        out = inputvalues('Nova Flt. Area',{'Código:','Descrição:','Estilo:','Cor:'},{'','',{'Sólido','Pontilhado','Traço-ponto','Tracejado'},...
                {'Azul','Verde','Vermelho','Ciano','Magenta','Amarelo'}}); drawnow;
        if isempty(out)
            return
        end
        styles = {'-',':','-.','--'};
        colors = 'bgrcmy';
        facode = out{1};
        fadescr = out{2};
        fastyle = styles{out{3}};
        facolor = colors(out{4});
        if length(facode) > 12
            facode = facode(1:12);
            uiwait(warndlg('Código truncado em 12 caracteres.','Aviso','modal'));
        end
        
        newfa.descr = fadescr;
        newfa.code  = facode;
        newfa.style = fastyle;
        newfa.color = facolor;
        newfa.data  = [];
        
        if ins && N < length(scenario.fa)
            scenario.fa = cat(2,scenario.fa(1:N),newfa,scenario.fa(N+1:end));
        else
            N = length(scenario.fa);
            scenario.fa = cat(2,scenario.fa,newfa);
        end
        
    case 'avd' % Avoid Zones
        out = inputvalues('Nova Avd. Zone',{'Código:','Latitude:','Longitude:','Raio (NM):'},{'','','',''}); drawnow;
        if isempty(out)
            return
        end
        cod = out{1};
        [void, lat] = latlongread(out{2});
        [void, lon] = latlongread(out{3});
        R = str2double(out{4});
        if isempty(lat) || isempty(lon) || lat<-90 || lat>90 || lon<-180 || lon>180
            beep; uiwait(errordlg('Coordenadas incoerentes.','Erro','modal'));
            return
        end
        if isnan(R) || R<=0 || R>300
            beep; uiwait(errordlg('Raio incoerente.','Erro','modal'));
            return
        end
        if length(cod) > 12
            cod = cod(1:12);
            uiwait(warndlg('Código truncado em 12 caracteres.','Aviso','modal'));
        end
        if isempty(scenario.avd)
            scenario.avd.code = {};
            scenario.avd.data = [];
        end
        if ins && N < length(scenario.avd.code)
            scenario.avd.code = [scenario.avd.code(1:N)  ; {cod}    ; scenario.avd.code(N+1:end)];
            scenario.avd.data = [scenario.avd.data(1:N,:); lat lon R; scenario.avd.data(N+1:end,:)];
        else
            N = length(scenario.avd.code);
            scenario.avd.code{N+1,1} = cod;
            scenario.avd.data(N+1,:) = [lat lon R];
        end

    case 'thr' % Threat Areas
        out = inputvalues('Nova ameaça',...
            {'Código:','Latitude:','Longitude:','Altitude 1 (ft):','Raio 1 (NM):','Altitude 2 (ft):','Raio 2 (NM):'},...
            {'','','','','','',''}); drawnow;
        if isempty(out)
            return
        end
        cod = out{1};
        [void, lat] = latlongread(out{2});
        [void, lon] = latlongread(out{3});
        Alt1 = str2double(out{4});
        R1   = str2double(out{5});
        Alt2 = str2double(out{6});
        R2   = str2double(out{7});
        if isempty(lat) || isempty(lon) || lat<-90 || lat>90 || lon<-180 || lon>180
            beep; uiwait(errordlg('Coordenadas incoerentes.','Erro','modal'));
            return
        end
        if isnan(Alt1) || isnan(Alt2) || Alt1<-2000 || Alt1>100000 || Alt2<-2000 || Alt2>100000
            beep; uiwait(errordlg('Altitude incoerente.','Erro','modal'));
            return
        end
        if Alt1 >= Alt2
            beep; uiwait(errordlg('Altitude 2 deve ser maior que Altitude 1.','Erro','modal'));
            return
        end
        if isnan(R1) || R1<0 || R1>300 || isnan(R2) || R2<0 || R2>300
            beep; uiwait(errordlg('Raio incoerente.','Erro','modal'));
            return
        end
        if length(cod) > 12
            cod = cod(1:12);
            uiwait(warndlg('Código truncado em 12 caracteres.','Aviso','modal'));
        end
        if isempty(scenario.thr)
            scenario.thr.code = {};
            scenario.thr.data = [];
        end
        if ins && N < length(scenario.thr.code)
            scenario.thr.code = [scenario.thr.code(1:N)  ; {cod}    ; scenario.thr.code(N+1:end)];
            scenario.thr.data = [scenario.thr.data(1:N,:); lat lon Alt1 Alt2 R1 R2; scenario.thr.data(N+1:end,:)];
        else
            N = length(scenario.thr.code);
            scenario.thr.code{N+1,1} = cod;
            scenario.thr.data(N+1,:) = [lat lon Alt1 Alt2 R1 R2];
        end
        
    case 'cnt' % Contact Line
        if ~isempty(scenario.cnt)
            beep; uiwait(errordlg('Linha de contato já definida.','Erro','modal'));
            return
        end
        button = questdlg('Deseja criar a linha de contato?','Confirmação','Sim','Não','Não');
        if strcmp(button,'Sim')
            N = 0;
            scenario.cnt.data = [];
        end
end

if ~isequalwithequalnans(scenario,oldscenario)
    handles.chg = 1;
    guidata(hObject, handles);
    
    setscenario(hObject, eventdata, handles, scenario, ntype);
    type_sel(hObject, eventdata, handles, N+1);
end

% --------------------------------------------------------------------
function insertobj_btn_Callback(hObject, eventdata, handles)
% Inserir objeto abaixo do objeto selecionado

addobj_btn_Callback(hObject, eventdata, handles, 1);

%--------------------------------------------------------------------------
function remobj_btn_Callback(hObject, eventdata, handles)
% Remover objeto da lista

ntype = getappdata(handles.window,'ntype');
n     = get(handles.obj_list,'Value');
scenario = getappdata(handles.window,'scenario');
oldscenario = scenario;
nn = length(n);

switch ntype
    case 'map' % Maps
        if isempty(scenario.map)
            beep;
            return
        end
        if nn == 1
            button = questdlg(['Deseja remover o mapa ''' scenario.map(n).name ''' ?'],'Confirmação','Sim','Não','Não');
        else
            button = questdlg(['Deseja remover os ' num2str(nn) ' mapas selecionados?'],'Confirmação','Sim','Não','Não');
        end
        if strcmp(button,'Sim')
            scenario.map(n) = [];
            N = min(n(1),max(1,length(scenario.map)));
            
            delete(handles.map(n));
            handles.map(n) = [];
        end
        
    case 'aux' % Auxiliary Shapes
        if isempty(scenario.aux)
            beep;
            return
        end
        button = questdlg(['Deseja excluir o objeto auxiliar ''' scenario.aux(n).name ''' ?'],'Confirmação','Sim','Não','Não');
        if strcmp(button,'Sim')
            auxtype = scenario.aux(n).type;
            scenario.aux(n) = [];
            N = min(n,max(1,length(scenario.aux)));
            
            delete(handles.aux(n));
            handles.aux(n) = [];
            if istype(auxtype,{'point','text'})
                delete(handles.auxlbl{n});
            end
            handles.auxlbl(n) = [];
        end
        
    case 'aid' % Nav Aids
        if isempty(scenario.aid) || isempty(scenario.aid.data)
            beep;
            return
        end
        if nn == 1
            if istype(scenario.aid.type{n},'AFLD')
                str = 'aeródromo';
            else
                str = 'auxílio';
            end
            button = questdlg(['Deseja excluir o ' str ' ''' scenario.aid.code{n} '''?'],'Confirmação','Sim','Não','Não');
        else
            button = questdlg(['Deseja excluir os ' num2str(nn) ' auxílios/aeródromos selecionados?'],'Confirmação','Sim','Não','Não');
        end
        if strcmp(button,'Sim')
            scenario.aid.code(n) = [];
            scenario.aid.type(n) = [];
            scenario.aid.data(n,:) = [];
            
            delete([handles.aid(n) handles.aidlbl(n)]);
            handles.aid(n) = [];
            handles.aidlbl(n) = [];
            
            N = min(n(1),max(1,length(scenario.aid.code)));
        end
        
    case 'wpt' % Waypoints
        if isempty(scenario.wpt) || isempty(scenario.wpt.data)
            beep;
            return
        elseif ~isempty(scenario.rt)
            for ni = 1:nn
                if any(scenario.wpt.data(n(ni),1)==[scenario.rt.wpt])
                    beep; uiwait(errordlg({['Não é possível excluir o waypoint ' num2str(scenario.wpt.data(n(ni),1),'%02.0f')],...
                            'pois o mesmo pertence a uma rota.'},'Erro','modal'));
                    return
                end
            end
        end
        if nn == 1
            button = questdlg(['Deseja excluir o waypoint ' num2str(scenario.wpt.data(n,1),'%02.0f') '?'],'Confirmação','Sim','Não','Não');
        else
            button = questdlg(['Deseja excluir os ' num2str(nn) ' waypoints selecionados?'],'Confirmação','Sim','Não','Não');
        end
        if strcmp(button,'Sim')
            scenario.wpt.code(n) = [];
            scenario.wpt.data(n,:) = [];
            
            set(handles.wpt,'XData',scenario.wpt.data(:,3),'YData',scenario.wpt.data(:,2),'ZData',ones(size(scenario.wpt.data,1),1));
            delete([handles.wptnumlbl(n) handles.wptcodlbl(n)]);
            handles.wptnumlbl(n) = [];
            handles.wptcodlbl(n) = [];
            
            N = min(n(1),max(1,length(scenario.wpt.code)));
        end
        
    case 'rt' % Routes
        if isempty(scenario.rt)
            beep;
            return
        end
        if nn == 1
            button = questdlg(['Deseja excluir a rota ' num2str(n) '?'],'Confirmação','Sim','Não','Não');
        else
            button = questdlg(['Deseja excluir as ' num2str(nn) ' rotas selecionadas?'],'Confirmação','Sim','Não','Não');
        end
        if strcmp(button,'Sim')
            scenario.rt(n) = [];
            N = min(n(1),max(1,length(scenario.rt)));
            
            delete(handles.rt(n));
            handles.rt(n) = [];
        end
        
    case 'fa' % Flight Areas
        if isempty(scenario.fa)
            beep;
            return
        end
        if nn == 1
            button = questdlg(['Deseja excluir a área ''' scenario.fa(n).code ''' ?'],'Confirmação','Sim','Não','Não');
        else
            button = questdlg(['Deseja excluir as ' num2str(nn) ' áreas selecionadas?'],'Confirmação','Sim','Não','Não');
        end
        if strcmp(button,'Sim')
            scenario.fa(n) = [];
            N = min(n(1),max(1,length(scenario.fa)));
            
            delete([handles.fa(n) handles.falbl(n)]);
            handles.fa(n)    = [];
            handles.falbl(n) = [];
        end
        
    case 'avd' % Avoid Zones
        if isempty(scenario.avd) || isempty(scenario.avd.data)
            beep;
            return
        end
        if nn == 1
            button = questdlg(['Deseja excluir a avoid zone ''' scenario.avd.code{n} ''' ?'],'Confirmação','Sim','Não','Não');
        else
            button = questdlg(['Deseja excluir as ' num2str(nn) ' avoid zones selecionadas?'],'Confirmação','Sim','Não','Não');
        end
        if strcmp(button,'Sim')
            scenario.avd.code(n) = [];
            scenario.avd.data(n,:) = [];
            N = min(n(1),max(1,length(scenario.avd.code)));
            
            delete([handles.avd(n) handles.avdlbl(n)]);
            handles.avd(n)    = [];
            handles.avdlbl(n) = [];
        end
        
    case 'thr' % Threat Areas
        if isempty(scenario.thr) || isempty(scenario.thr.data)
            beep;
            return
        end
        if nn == 1
            button = questdlg(['Deseja excluir a ameaça ''' scenario.thr.code{n} ''' ?'],'Confirmação','Sim','Não','Não');
        else
            button = questdlg(['Deseja excluir as ' num2str(nn) ' ameaças selecionadas?'],'Confirmação','Sim','Não','Não');
        end
        if strcmp(button,'Sim')
            scenario.thr.code(n) = [];
            scenario.thr.data(n,:) = [];
            N = min(n(1),max(1,length(scenario.thr.code)));
            
            delete([handles.thr(n) handles.thrlbl(n)]);
            handles.thr(n)    = [];
            handles.thrlbl(n) = [];
        end
        
    case 'cnt' % Contact Line
        if isempty(scenario.cnt) || isempty(scenario.cnt.data)
            beep;
            return
        end
        button = questdlg('Deseja excluir a linha de contato?','Confirmação','Sim','Não','Não');
        if strcmp(button,'Sim')
            scenario.cnt = [];
            N = 1;
            
            delete(handles.cnt);
            handles.cnt    = [];
        end
end

if ~isequalwithequalnans(scenario,oldscenario)
    handles.chg = 1;
    guidata(hObject, handles);
    
    if istype(ntype,{'wpt','aid'})
        updatescenario(hObject, eventdata, handles, scenario, ntype);
    else
        setappdata(handles.window,'scenario',scenario);
    end
    type_sel(hObject, eventdata, handles, N);
end

%--------------------------------------------------------------------------
function editobj_btn_Callback(hObject, eventdata, handles)
% Editar objeto da lista

ntype = getappdata(handles.window,'ntype');
n     = get(handles.obj_list,'Value');
m     = get(handles.param_list,'Value');
scenario = getappdata(handles.window,'scenario');
oldscenario = scenario;

if length(n) ~= 1
    beep;
    return
end

switch ntype
    case 'map' % Maps
        beep;
        return
        
    case 'aux' % Auxiliary Shapes
        if isempty(scenario.aux)
            beep;
            return
        end
        auxname = scenario.aux(n).name;
        auxtype = scenario.aux(n).type;
        auxstyle = scenario.aux(n).style;
        auxcolor = scenario.aux(n).color;
        auxwidth = scenario.aux(n).width;
        colors = 'bgrcmyw';
        colors_str = {'Azul','Verde','Vermelho','Ciano','Magenta','Amarelo','Branco','Personalizada','Personalizar'};
        switch auxtype
            case 'point'
                styles = {'.','o','d','s','^','p'};
                styles_str = {'Ponto','Círculo','Losango','Quadrado','Triângulo','Estrela'};
                width_str = {'1','2'};
            case 'line'
                styles = {'-',':','-.','--',};
                styles_str = {'Sólido','Pontilhado','Traço-ponto','Tracejado'};
                width_str = cellstr(num2str((1:8)'))';
            case 'area'
                styles = {'A'};
                styles_str = {'Área'};
                width_str = {'Não aplicável'};
            case 'text'
                styles = {'T'};
                styles_str = {'Texto'};
                width_str = {'Não aplicável'};
        end
        
        if length(auxcolor) == 1
            nc = find(auxcolor == colors);
            colors_str(8) = [];
        else
            nc = 8;
        end
        ns = strmatch(auxstyle,styles,'exact');
        nw = auxwidth;
        if isempty(nc), nc = 1; end
        if isempty(ns), ns = 1; end
        
        out = inputvalues('Editar obj. aux.',{'Nome:','Estilo:','Cor:','Espessura (px):','Extensão:'},...
            {auxname,[styles_str {ns}],[colors_str {nc}],[width_str {nw}],{'Manter','Cortar'}});
        if isempty(out)
            return
        end
        
        auxname  = out{1};
        auxstyle = styles{out{2}};        
        if out{3} <= 7
            auxcolor = colors(out{3});
        elseif out{3} == length(colors_str)
            auxcolor = uisetcolor(char2rgb(auxcolor),'Cor do objeto auxiliar:');
            if length(auxcolor) ~= 3
                return
            end
        end
        if length(auxcolor) == 3
            auxcolor = roundn(auxcolor,-3);
        end
        auxwidth = out{4};

        if length(auxname) > 12
            auxname = auxname(1:12);
            uiwait(warndlg('Código truncado em 12 caracteres.','Aviso','modal'));
        end
        
        scenario.aux(n).name  = auxname;
        scenario.aux(n).style = auxstyle;
        scenario.aux(n).color = auxcolor;
        scenario.aux(n).width = auxwidth;
        
        if out{5} == 2
            auxdata = scenario.aux(n).data;
            auxcode = scenario.aux(n).code;
            
            minlat = fixlatlong(min(auxdata(:,1)),-1);
            maxlat = fixlatlong(max(auxdata(:,1)), 1);
            minlon = fixlatlong(min(auxdata(:,2)),-1);
            maxlon = fixlatlong(max(auxdata(:,2)), 1);
            out = inputvalues('Cortar obj. aux.',{'Limite Norte:','Limite Sul:','Limite Leste:','Limite Oeste:'},...
                {   deg2latlong(maxlat,1,3), deg2latlong(minlat,1,3),...
                    deg2latlong(maxlon,2,3), deg2latlong(minlon,2,3)}); drawnow;
            if isempty(out)
                return
            end
            [void, lat2] = latlongread(out{1});
            [void, lat1] = latlongread(out{2});
            [void, lon2] = latlongread(out{3});
            [void, lon1] = latlongread(out{4});
            if      isempty(lat1) || isempty(lon1) || lat1<-90 || lat1>90 || lon1<-180 || lon1>180 || ...
                    isempty(lat2) || isempty(lon2) || lat2<-90 || lat2>90 || lon2<-180 || lon2>180 || lat1>=lat2 || lon1>=lon2
                beep; uiwait(errordlg('Coordenadas incoerentes.','Erro','modal'));
                return
            end
            if lat1>minlat || lat2<maxlat || lon1>minlon || lon2<maxlon
                [yc, xc, Iin] = mapcut(auxdata(:,1),auxdata(:,2),[lat1 lat2],[lon1 lon2],auxtype);
                if isempty(yc)
                    beep; uiwait(errordlg('Não há dados nas coordenadas indicadas.','Erro','modal'));
                    return
                end
                if size(yc,1) > handles.maxvert
                    button = questdlg({'Os dados ainda são muito extensos e podem prejudicar a',...
                            'reprodução do voo. É recomendado reduzir a área ao',...
                            'minimo relevante para a reprodução.',' ','Deseja prosseguir?'},'Confirmação','Sim','Não','Não');
                    if ~strcmp(button,'Sim')
                        return
                    end
                end
                if istype(auxtype,'point')
                    auxcode(~Iin) = [];
                end
                if istype(auxtype,'text')
                    rot = auxdata(Iin,3);
                    auxcode(~Iin) = [];
                else
                    rot = [];
                end
                auxdata = [yc xc rot];
                m = 1;
            end
            scenario.aux(n).data = auxdata;
            scenario.aux(n).code = auxcode;
            
        end
        
    case 'aid' % Nav Aids
        if isempty(scenario.aid) || isempty(scenario.aid.data)
            beep;
            return
        end
        namelist = {'NDB','VOR','VOR/DME','DME','Fixo','Aeródromo'};
        typelist = {'NDB','VOR','VOR/DME','DME','FIX' ,'AFLD'     };
        nt = strmatch(scenario.aid.type{n},typelist,'exact');
        psi = scenario.aid.data(n,4);
        if isnan(psi)
            psistr = '';
        else
            psistr = num2str(psi);
        end
        out = inputvalues('Editar NavAid',{'Tipo:','Código:','Latitude:','Longitude:','Elevação (ft):','Proa (aeródromo):'},...
            {[namelist {nt}],scenario.aid.code{n},deg2latlong(scenario.aid.data(n,1),1,3),deg2latlong(scenario.aid.data(n,2),2,3),...
                num2str(scenario.aid.data(n,3)),psistr}); drawnow;
        if isempty(out)
            return
        end
        typ = typelist{out{1}};
        cod = out{2};
        [void, lat] = latlongread(out{3});
        [void, lon] = latlongread(out{4});
        alt = str2double(out{5});
        psi = str2double(out{6});
        if isempty(lat) || isempty(lon) || lat<-90 || lat>90 || lon<-180 || lon>180
            beep; uiwait(errordlg('Coordenadas incoerentes.','Erro','modal'));
            return
        end
        if isnan(alt) || alt<-2000 || alt>100000
            beep; uiwait(errordlg('Elevação incoerente.','Erro','modal'));
            return
        end
        if ~istype(typ,'AFLD')
            psi = NaN;
        elseif isnan(psi) || psi<0 || psi>360
            beep; uiwait(errordlg('Proa incoerente.','Erro','modal'));
            return
        end
        if length(cod) > 12
            cod = cod(1:12);
            uiwait(warndlg('Código truncado em 12 caracteres.','Aviso','modal'));
        end
        
        scenario.aid.code{n} = cod;
        scenario.aid.type{n} = typ;
        scenario.aid.data(n,:) = [lat lon alt psi];
        
    case 'wpt' % Waypoints
        if isempty(scenario.wpt) || isempty(scenario.wpt.data)
            beep;
            return
        end
        out = inputvalues('Editar WPT',{'Número:','Código:','Latitude:','Longitude:','Elevação (ft):'},...
            {scenario.wpt.data(n,1),scenario.wpt.code{n},deg2latlong(scenario.wpt.data(n,2),1,3),deg2latlong(scenario.wpt.data(n,3),2,3),...
                num2str(scenario.wpt.data(n,4))}); drawnow;
        if isempty(out)
            return
        end
        num = str2double(out{1});
        cod = out{2};
        [void, lat] = latlongread(out{3});
        [void, lon] = latlongread(out{4});
        alt = str2double(out{5});
        if num == 0 || ( num > 0 && ~rem(num,round(num)) )
            if num ~= scenario.wpt.data(n,1) && any(num==scenario.wpt.data(:,1))
                beep; uiwait(errordlg(['Waypoint ' num2str(num) ' já cadastrado.'],'Erro','modal'));
                return
            end
        else
            beep; uiwait(errordlg('Número indicado incoerente.','Erro','modal'));
            return
        end
        if isempty(lat) || isempty(lon) || lat<-90 || lat>90 || lon<-180 || lon>180
            beep; uiwait(errordlg('Coordenadas incoerentes.','Erro','modal'));
            return
        end
        if isnan(alt) || alt<-2000 || alt>100000
            beep; uiwait(errordlg('Elevação incoerente.','Erro','modal'));
            return
        end
        if length(cod) > 12
            cod = cod(1:12);
            uiwait(warndlg('Código truncado em 12 caracteres.','Aviso','modal'));
        end
        
        scenario.wpt.code{n} = cod;
        scenario.wpt.data(n,:) = [num lat lon alt];
        
    case 'rt' % Routes
        beep;
        return
        
    case 'fa' % Flight Areas
        if isempty(scenario.fa)
            beep;
            return
        end
        
        fadescr = scenario.fa(n).descr;
        facode  = scenario.fa(n).code;
        fastyle = scenario.fa(n).style;
        facolor = scenario.fa(n).color;

        colors = 'bgrcmy';
        colors_str = {'Azul','Verde','Vermelho','Ciano','Magenta','Amarelo'};
        styles = {'-',':','-.','--'};
        styles_str = {'Sólido','Pontilhado','Traço-ponto','Tracejado'};
        nc = find(facolor == colors);
        ns = strmatch(fastyle,styles,'exact');
        if isempty(nc), nc = 1; end
        if isempty(ns), ns = 1; end
        
        out = inputvalues('Editar Flt. Area',{'Código:','Descrição','Estilo:','Cor:'},{facode,fadescr,[styles_str {ns}],[colors_str {nc}]}); drawnow;
        if isempty(out)
            return
        end
        facode  = out{1};
        fadescr = out{2};
        fastyle = styles{out{3}};
        facolor = colors(out{4});
        if length(facode) > 12
            facode = facode(1:12);
            uiwait(warndlg('Código truncado em 12 caracteres.','Aviso','modal'));
        end
        
        scenario.fa(n).descr = fadescr;
        scenario.fa(n).code  = facode;
        scenario.fa(n).style = fastyle;
        scenario.fa(n).color = facolor;
        
    case 'avd' % Avoid Zones
        if isempty(scenario.avd) || isempty(scenario.avd.data)
            beep;
            return
        end
        out = inputvalues('Editar Avd. Zone',{'Código:','Latitude:','Longitude:','Raio (NM):'},...
            {scenario.avd.code{n},deg2latlong(scenario.avd.data(n,1),1,3),deg2latlong(scenario.avd.data(n,2),2,3),...
                num2str(scenario.avd.data(n,3))}); drawnow;
        if isempty(out)
            return
        end
        cod = out{1};
        [void, lat] = latlongread(out{2});
        [void, lon] = latlongread(out{3});
        R = str2double(out{4});
        if isempty(lat) || isempty(lon) || lat<-90 || lat>90 || lon<-180 || lon>180
            beep; uiwait(errordlg('Coordenadas incoerentes.','Erro','modal'));
            return
        end
        if isnan(R) || R<=0 || R>300
            beep; uiwait(errordlg('Raio incoerente.','Erro','modal'));
            return
        end
        if length(cod) > 12
            cod = cod(1:12);
            uiwait(warndlg('Código truncado em 12 caracteres.','Aviso','modal'));
        end
        
        scenario.avd.code{n} = cod;
        scenario.avd.data(n,:) = [lat lon R];
        
    case 'thr' % Threat Areas
        if isempty(scenario.thr) || isempty(scenario.thr.data)
            beep;
            return
        end
        out = inputvalues('Editar ameaça',...
            {'Código:','Latitude:','Longitude:','Altitude 1 (ft):','Raio 1 (NM):','Altitude 2 (ft):','Raio 2 (NM):'},...
            {scenario.thr.code{n},deg2latlong(scenario.thr.data(n,1),1,3),deg2latlong(scenario.thr.data(n,2),2,3),...
                num2str(scenario.thr.data(n,3)),num2str(scenario.thr.data(n,5)),num2str(scenario.thr.data(n,4)),...
                num2str(scenario.thr.data(n,6))}); drawnow;
        if isempty(out)
            return
        end
        cod = out{1};
        [void, lat] = latlongread(out{2});
        [void, lon] = latlongread(out{3});
        Alt1 = str2double(out{4});
        R1   = str2double(out{5});
        Alt2 = str2double(out{6});
        R2   = str2double(out{7});
        if isempty(lat) || isempty(lon) || lat<-90 || lat>90 || lon<-180 || lon>180
            beep; uiwait(errordlg('Coordenadas incoerentes.','Erro','modal'));
            return
        end
        if isnan(Alt1) || isnan(Alt2) || Alt1<-2000 || Alt1>100000 || Alt2<-2000 || Alt2>100000
            beep; uiwait(errordlg('Altitude incoerente.','Erro','modal'));
            return
        end
        if Alt1 >= Alt2
            beep; uiwait(errordlg('Altitude 2 deve ser maior que Altitude 1.','Erro','modal'));
            return
        end
        if isnan(R1) || R1<0 || R1>300 || isnan(R2) || R2<0 || R2>300
            beep; uiwait(errordlg('Raio incoerente.','Erro','modal'));
            return
        end
        if length(cod) > 12
            cod = cod(1:12);
            uiwait(warndlg('Código truncado em 12 caracteres.','Aviso','modal'));
        end
        scenario.thr.code{n} = cod;
        scenario.thr.data(n,:) = [lat lon Alt1 Alt2 R1 R2];
        
    case 'cnt' % Contact Line
        beep;
        return
end

if ~isequalwithequalnans(scenario,oldscenario)
    handles.chg = 1;
    guidata(hObject, handles);
    
    if istype(ntype,'aux') && ( strcmp(auxtype,'point') || strcmp(auxtype,'text') )
        setscenario(hObject, eventdata, handles, scenario, ntype);
    elseif istype(ntype,'aid')
        setscenario(hObject, eventdata, handles, scenario, ntype);
    else
        updatescenario(hObject, eventdata, handles, scenario, ntype);
    end
    type_sel(hObject, eventdata, handles, n, m);
end

% --------------------------------------------------------------------
function importobj_btn_Callback(hObject, eventdata, handles)
% Importar objeto

ntype = getappdata(handles.window,'ntype');

switch ntype
    case 'map' % Maps
        addobj_btn_Callback(hObject, eventdata, handles);
        return
    case 'aux' % Auxiliary Shapes
        str = 'objetos auxiliares';
    case 'aid' % Nav Aids
        str = 'auxílios / aeródromos';
    case 'wpt' % Waypoints
        str = 'waypoints';
    case 'rt' % Routes
        str = 'rotas';
    case 'fa' % Flight Areas
        str = 'áreas de voo';
    case 'avd' % Avoid Zones
        str = 'avoid zones';
    case 'thr' % Threat Areas
        str = 'ameaças';
    case 'cnt' % Contact Line
        str = 'linha de contato';
end

opt = RDAT_InputOption(['Importar ' str],'De onde deseja importar?',{'Banco de dados','Outro arquivo de cenário (.mat)','Arquivo externo (.txt, .xls, .xml, .kml)'},1,280);

if isempty(opt)
    return
end

switch opt
    case 1 % Banco de dados
        errordlg('Esta função ainda não está implementada.','Aviso','modal') % @@
    case 2 % Outro arquivo mat
        import_matfile(hObject, eventdata, handles);
    case 3 % Arquivo externo
        import_extfile(hObject, eventdata, handles);
end

% --------------------------------------------------------------------
function exportobj_btn_Callback(hObject, eventdata, handles)
% Exportar objeto

ntype = getappdata(handles.window,'ntype');

if istype(ntype,'map') || isempty(get(handles.obj_list,'String'))
    beep;
    return
end

switch ntype
    case 'map' % Maps
        str = 'mapas';
    case 'aux' % Auxiliary Shapes
        str = 'objetos auxiliares';
    case 'aid' % Nav Aids
        str = 'auxílios / aeródromos';
    case 'wpt' % Waypoints
        str = 'waypoints';
    case 'rt' % Routes
        str = 'rotas';
    case 'fa' % Flight Areas
        str = 'áreas de voo';
    case 'avd' % Avoid Zones
        str = 'avoid zones';
    case 'thr' % Threat Areas
        str = 'ameaças';
    case 'cnt' % Contact Line
        str = 'linha de contato';
end

opt = RDAT_InputOption(['Exportar ' str],'Para onde deseja exportar?',{'Banco de dados','Arquivo externo (.xls, .kml)'},1,280);

if isempty(opt)
    return
end

switch opt
    case 1 % Banco de dados
        errordlg('Esta função ainda não está implementada.','Aviso','modal') % @@
    case 2 % Arquivo externo
        export_extfile(hObject, eventdata, handles);
end

%--------------------------------------------------------------------------
function upobj_btn_Callback(hObject, eventdata, handles)
% Mover objeto para cima

ntype = getappdata(handles.window,'ntype');
n     = get(handles.obj_list,'Value');
m     = get(handles.param_list,'Value');
scenario = getappdata(handles.window,'scenario');
oldscenario = scenario;

if length(n) ~= 1 || n(1) == 1
    beep;
    return
end

switch ntype
    case 'map' % Maps
        if isempty(scenario.map)
            beep;
            return
        end
        aux               = scenario.map(n-1);
        scenario.map(n-1) = scenario.map(n);
        scenario.map(n)   = aux;
        
        ntype = 'all';
        
    case 'aux' % Auxiliary Shapes
        if isempty(scenario.aux)
            beep;
            return
        end
        aux               = scenario.aux(n-1);
        scenario.aux(n-1) = scenario.aux(n);
        scenario.aux(n)   = aux;
        
    case 'aid' % Nav Aids
        if isempty(scenario.aid) || isempty(scenario.aid.data)
            beep;
            return
        end
        aux                      = scenario.aid.code{n-1};
        scenario.aid.code{n-1}   = scenario.aid.code{n};
        scenario.aid.code{n}     = aux;
        aux                      = scenario.aid.type{n-1};
        scenario.aid.type{n-1}   = scenario.aid.type{n};
        scenario.aid.type{n}     = aux;
        aux                      = scenario.aid.data(n-1,:);
        scenario.aid.data(n-1,:) = scenario.aid.data(n,:);
        scenario.aid.data(n,:)   = aux;
        
    case 'wpt' % Waypoints
        if isempty(scenario.wpt) || isempty(scenario.wpt.data)
            beep;
            return
        end
        aux                      = scenario.wpt.code{n-1};
        scenario.wpt.code{n-1}   = scenario.wpt.code{n};
        scenario.wpt.code{n}     = aux;
        aux                      = scenario.wpt.data(n-1,:);
        scenario.wpt.data(n-1,:) = scenario.wpt.data(n,:);
        scenario.wpt.data(n,:)   = aux;
        
    case 'rt' % Routes
        if isempty(scenario.rt)
            beep;
            return
        end
        aux              = scenario.rt(n-1);
        scenario.rt(n-1) = scenario.rt(n);
        scenario.rt(n)   = aux;
        
    case 'fa' % Flight Areas
        if isempty(scenario.fa)
            beep;
            return
        end
        aux              = scenario.fa(n-1);
        scenario.fa(n-1) = scenario.fa(n);
        scenario.fa(n)   = aux;
        
    case 'avd' % Avoid Zones
        if isempty(scenario.avd) || isempty(scenario.avd.data)
            beep;
            return
        end
        aux                      = scenario.avd.code{n-1};
        scenario.avd.code{n-1}   = scenario.avd.code{n};
        scenario.avd.code{n}     = aux;
        aux                      = scenario.avd.data(n-1,:);
        scenario.avd.data(n-1,:) = scenario.avd.data(n,:);
        scenario.avd.data(n,:)   = aux;
        
    case 'thr' % Threat Areas
        if isempty(scenario.thr) || isempty(scenario.thr.data)
            beep;
            return
        end
        aux                      = scenario.thr.code{n-1};
        scenario.thr.code{n-1}   = scenario.thr.code{n};
        scenario.thr.code{n}     = aux;
        aux                      = scenario.thr.data(n-1,:);
        scenario.thr.data(n-1,:) = scenario.thr.data(n,:);
        scenario.thr.data(n,:)   = aux;
        
    case 'cnt' % Contact Line
        beep;
        return
        
end

if ~isequalwithequalnans(scenario,oldscenario)
    handles.chg = 1;
    guidata(hObject, handles);
    
    setscenario(hObject, eventdata, handles, scenario, ntype);
    type_sel(hObject, eventdata, handles, n-1, m);
end

%--------------------------------------------------------------------------
function dnobj_btn_Callback(hObject, eventdata, handles)
% Mover objeto para baixo

ntype = getappdata(handles.window,'ntype');
n     = get(handles.obj_list,'Value');
m     = get(handles.param_list,'Value');
scenario = getappdata(handles.window,'scenario');
oldscenario = scenario;

if length(n) ~= 1 || n(1) >= length(cellstr(get(handles.obj_list,'String')))
    beep;
    return
end

switch ntype
    case 'map' % Maps
        if isempty(scenario.map)
            beep;
            return
        end
        aux               = scenario.map(n+1);
        scenario.map(n+1) = scenario.map(n);
        scenario.map(n)   = aux;
        
        ntype = 'all';
        
    case 'aux' % Auxiliary Shapes
        if isempty(scenario.aux)
            beep;
            return
        end
        aux               = scenario.aux(n+1);
        scenario.aux(n+1) = scenario.aux(n);
        scenario.aux(n)   = aux;
        
    case 'aid' % Nav Aids
        if isempty(scenario.aid) || isempty(scenario.aid.data)
            beep;
            return
        end
        aux                      = scenario.aid.code{n+1};
        scenario.aid.code{n+1}   = scenario.aid.code{n};
        scenario.aid.code{n}     = aux;
        aux                      = scenario.aid.type{n+1};
        scenario.aid.type{n+1}   = scenario.aid.type{n};
        scenario.aid.type{n}     = aux;
        aux                      = scenario.aid.data(n+1,:);
        scenario.aid.data(n+1,:) = scenario.aid.data(n,:);
        scenario.aid.data(n,:)   = aux;
        
    case 'wpt' % Waypoints
        if isempty(scenario.wpt) || isempty(scenario.wpt.data)
            beep;
            return
        end
        aux                      = scenario.wpt.code{n+1};
        scenario.wpt.code{n+1}   = scenario.wpt.code{n};
        scenario.wpt.code{n}     = aux;
        aux                      = scenario.wpt.data(n+1,:);
        scenario.wpt.data(n+1,:) = scenario.wpt.data(n,:);
        scenario.wpt.data(n,:)   = aux;
        
    case 'rt' % Routes
        if isempty(scenario.rt)
            beep;
            return
        end
        aux              = scenario.rt(n+1);
        scenario.rt(n+1) = scenario.rt(n);
        scenario.rt(n)   = aux;
        
    case 'fa' % Flight Areas
        if isempty(scenario.fa)
            beep;
            return
        end
        aux              = scenario.fa(n+1);
        scenario.fa(n+1) = scenario.fa(n);
        scenario.fa(n)   = aux;
        
    case 'avd' % Avoid Zones
        if isempty(scenario.avd) || isempty(scenario.avd.data)
            beep;
            return
        end
        aux                      = scenario.avd.code{n+1};
        scenario.avd.code{n+1}   = scenario.avd.code{n};
        scenario.avd.code{n}     = aux;
        aux                      = scenario.avd.data(n+1,:);
        scenario.avd.data(n+1,:) = scenario.avd.data(n,:);
        scenario.avd.data(n,:)   = aux;
        
    case 'thr' % Threat Areas
        if isempty(scenario.thr) || isempty(scenario.thr.data)
            beep;
            return
        end
        aux                      = scenario.thr.code{n+1};
        scenario.thr.code{n+1}   = scenario.thr.code{n};
        scenario.thr.code{n}     = aux;
        aux                      = scenario.thr.data(n+1,:);
        scenario.thr.data(n+1,:) = scenario.thr.data(n,:);
        scenario.thr.data(n,:)   = aux;
        
    case 'cnt' % Contact Line
        beep;
        return
end

if ~isequalwithequalnans(scenario,oldscenario)
    handles.chg = 1;
    guidata(hObject, handles);
    
    setscenario(hObject, eventdata, handles, scenario, ntype);
    type_sel(hObject, eventdata, handles, n+1, m);
end

% --------------------------------------------------------------------
function getobj_btn_Callback(hObject, eventdata, handles)
% Botao para obter objeto clicando no grafico

ntype = getappdata(handles.window,'ntype');
switch ntype
    case {'aid','wpt','avd','thr'}
        set([handles.zoom_btn handles.drag_btn handles.getparam_btn],'Value',0);
    otherwise
        beep;
        set(handles.getobj_btn,'Value',0);
end

%--------------------------------------------------------------------------
function addparam_btn_Callback(hObject, eventdata, handles, ins)
% Acrescentar parametro a um objeto

if nargin == 3
    ins = 0;
end

ntype = getappdata(handles.window,'ntype');
M     = get(handles.param_list,'Value');
n     = get(handles.obj_list,'Value');
scenario = getappdata(handles.window,'scenario');
oldscenario = scenario;

if length(n) ~= 1
    beep;
    return
end

if length(M) > 1
    M = max(get(handles.param_list,'Value'));
    if ins == 2
        beep;
        return
    end
end

switch ntype
    case 'map' % Maps
        beep;
        return
        
    case 'aux' % Auxiliary Shapes
        if isempty(scenario.aux)
            beep;
            return
        end
        auxtype = scenario.aux(n).type;
        if ins == 2
            switch auxtype
                case {'point','text'}
                    beep;
                    return
                case {'line','area'}
                    if isempty(scenario.aux(n).data)
                        beep;
                        return
                    else
                        button = questdlg('Deseja duplicar o vértice selecionado?','Confirmação','Sim','Não','Não'); drawnow;
                        if ~strcmp(button,'Sim')
                            return
                        end
                        lat = scenario.aux(n).data(M,1);
                        lon = scenario.aux(n).data(M,2);
                        rot = [];
                        aln = [];
                    end
            end
        else
            switch auxtype
                case 'point'
                    out = inputvalues('Novo ponto',{'Latitude:','Longitude:','Código:'},{'','',''}); drawnow;
                case {'line','area'}
                    out = inputvalues('Novo vértice',{'Latitude:','Longitude:'},{'',''}); drawnow;
                case 'text'
                    out = inputvalues('Novo texto',{'Latitude:','Longitude:','Texto:','Orientação (graus mag.):','Alinhamento:'},{'','','','',{'Esquerda','Centro','Direita',2}}); drawnow;
            end
            if isempty(out)
                return
            end
            [void, lat] = latlongread(out{1});
            [void, lon] = latlongread(out{2});
            if ( strcmp(auxtype,'line') || strcmp(auxtype,'area') ) && ( isempty(lat) || isempty(lon) )
                lat = NaN;
                lon = NaN;
            elseif isempty(lat) || isempty(lon) || lat<-90 || lat>90 || lon<-180 || lon>180
                beep; uiwait(errordlg('Coordenadas incoerentes.','Erro','modal'));
                return
            end
            if strcmp(auxtype,'point')
                cod = out{3};
                if length(cod) > 12
                    cod = cod(1:12);
                    uiwait(warndlg('Código truncado em 12 caracteres.','Aviso','modal'));
                end
            end
            if strcmp(auxtype,'text')
                cod = out{3};
                rot = round(mod(str2double(out{4}),360));
                aln = out{5}-2;
                if isempty(cod)
                    beep; uiwait(errordlg('O texto não pode ser vazio.','Erro','modal'));
                    return
                end
            else
                rot = [];
                aln = [];
            end
        end
        
        if ins && M < size(scenario.aux(n).data,1)
            scenario.aux(n).data = [scenario.aux(n).data(1:M,:); lat lon rot aln; scenario.aux(n).data(M+1:end,:)];
            if istype(auxtype,{'point','text'})
                scenario.auxcod{n} = [scenario.aux(n).code(1:M) {cod} scenario.aux(n).code(M+1:end)];
            end
        else
            M = size(scenario.aux(n).data,1);
            scenario.aux(n).data(M+1,:) = [lat lon rot aln];
            if istype(auxtype,{'point','text'})
                scenario.aux(n).code{M+1,1} = cod;
            end
        end
        
    case 'aid' % Nav Aids
        beep;
        return
        
    case 'wpt' % Waypoints
        beep;
        return
        
    case 'rt' % Routes
        if isempty(scenario.rt)
            beep;
            return
        end
        if ins == 2
            beep;
            return
        end
        if isempty(scenario.wpt) || isempty(scenario.wpt.data)
            beep; uiwait(errordlg('Não há waypoints cadastrados.','Erro','modal'));
            return
        end
        [freewpt, ind] = setdiff(scenario.wpt.data(:,1),scenario.rt(n).wpt);
        if isempty(freewpt)
            beep; uiwait(errordlg(['Não há waypoints disponíveis para a rota ' num2str(n) '.'],'Erro','modal'));
            return
        end
        for k = 1:length(freewpt)
            freewptlist{k} = [num2str(freewpt(k),'%02.0f') '  ' scenario.wpt.code{ind(k)}];
        end
        out = inputvalues('Inserir waypoint','Waypoint:',freewptlist); drawnow;
        if isempty(out)
            return
        end
        if ins && M < length(scenario.rt(n).wpt)
            scenario.rt(n).wpt = [scenario.rt(n).wpt(1:M) freewpt(out) scenario.rt(n).wpt(M+1:end)];
        else
            M = length(scenario.rt(n).wpt);
            scenario.rt(n).wpt(M+1) = freewpt(out);
        end
        
    case 'fa' % Flight Areas
        if isempty(scenario.fa)
            beep;
            return
        end
        if ins == 2
            if isempty(scenario.fa(n).data)
                beep;
                return
            else
                button = questdlg('Deseja duplicar o vértice selecionado?','Confirmação','Sim','Não','Não'); drawnow;
                if ~strcmp(button,'Sim')
                    return
                end
                lat = scenario.fa(n).data(M,1);
                lon = scenario.fa(n).data(M,2);
            end
        else
            out = inputvalues('Novo vértice',{'Latitude:','Longitude:'},{'',''}); drawnow;
            if isempty(out)
                return
            end
            [void, lat] = latlongread(out{1});
            [void, lon] = latlongread(out{2});
            if isempty(lat) || isempty(lon) || lat<-90 || lat>90 || lon<-180 || lon>180
                beep; uiwait(errordlg('Coordenadas incoerentes.','Erro','modal'));
                return
            end
        end
        if ins && ~isempty(scenario.fa(n).data) && M < size(scenario.fa(n).data,1)
            scenario.fa(n).data = [scenario.fa(n).data(1:M,:); lat lon; scenario.fa(n).data(M+1:end,:)];
        else
            if ~isempty(scenario.fa(n).data)
                scenario.fa(n).data(end,:) = [];
            end
            scenario.fa(n).data(end+1,:) = [lat lon];
            scenario.fa(n).data(end+1,:) = scenario.fa(n).data(1,:);
            M = size(scenario.fa(n).data,1)-2;
        end
        
    case 'avd' % Avoid Zones
        beep;
        return
        
    case 'thr' % Threat Areas
        beep;
        return
        
    case 'cnt' % Contact Line
        if ins == 2
            if isempty(scenario.cnt) || isempty(scenario.cnt.data)
                beep;
                return
            else
                button = questdlg('Deseja duplicar o vértice selecionado?','Confirmação','Sim','Não','Não'); drawnow;
                if ~strcmp(button,'Sim')
                    return
                end
                lat = scenario.cnt.data(M,1);
                lon = scenario.cnt.data(M,2);
            end
        else
            out = inputvalues('Novo vértice',{'Latitude:','Longitude:'},{'',''}); drawnow;
            if isempty(out)
                return
            end
            [void, lat] = latlongread(out{1});
            [void, lon] = latlongread(out{2});
            if isempty(lat) || isempty(lon) || lat<-90 || lat>90 || lon<-180 || lon>180
                beep; uiwait(errordlg('Coordenadas incoerentes.','Erro','modal'));
                return
            end
        end
        if isempty(scenario.cnt)
            scenario.cnt.data = [];
        end
        if ins && M < size(scenario.cnt.data,1)
            scenario.cnt.data = [scenario.cnt.data(1:M,:); lat lon; scenario.cnt.data(M+1:end,:)];
        else
            M = size(scenario.cnt.data,1);
            scenario.cnt.data(M+1,:) = [lat lon];
        end
end

if ~isequalwithequalnans(scenario,oldscenario)
    handles.chg = 1;
    guidata(hObject, handles);
    
    if istype(ntype,'aux') && ( strcmp(auxtype,'point') || strcmp(auxtype,'text') )
        setscenario(hObject, eventdata, handles, scenario, ntype);
    elseif istype(ntype,'cnt') && size(scenario.cnt.data,1) == 1
        setscenario(hObject, eventdata, handles, scenario, ntype);
    else
        updatescenario(hObject, eventdata, handles, scenario, ntype);
    end
    type_sel(hObject, eventdata, handles, n, M+1);
end

% --------------------------------------------------------------------
function doubleparam_btn_Callback(hObject, eventdata, handles)
% Duplicar parametro abaixo do parametro selecionado

set(handles.doubleparam_btn,'Value',0);
addparam_btn_Callback(hObject, eventdata, handles, 2);

% --------------------------------------------------------------------
function insertparam_btn_Callback(hObject, eventdata, handles)
% Inserir parametro abaixo do parametro selecionado

addparam_btn_Callback(hObject, eventdata, handles, 1);

%--------------------------------------------------------------------------
function addparamlist_btn_Callback(hObject, eventdata, handles)
% Acrescentar lista de parametros a um objeto

ntype = getappdata(handles.window,'ntype');
n     = get(handles.obj_list,'Value');
scenario = getappdata(handles.window,'scenario');
oldscenario = scenario;

if length(n) ~= 1
    beep;
    return
end

switch ntype
    case 'map' % Maps
        beep;
        return
        
    case 'aux' % Auxiliary Shapes
        if isempty(scenario.aux)
            beep;
            return
        end
        auxtype = scenario.aux(n).type;
        switch auxtype
            case {'point','text'}
                beep;
                return
            case {'line','area'}
                out = editbox('','Latitude / Longitude:',200); drawnow;
        end
        if isempty(out)
            return
        end
        latlon = latlongreadlist(out);
        if isempty(latlon)
            beep; uiwait(errordlg('Coordenadas incoerentes.','Erro','modal'));
            return
        end
        lat = latlon(:,1);
        lon = latlon(:,2);
        exc = [];
        for k = 1:length(lat)
            if lat(k)<-90 || lat(k)>90 || lon(k)<-180 || lon(k)>180
                exc = [exc k];
            end
        end
        if ~isempty(exc)
            uiwait(warndlg('Os vértices com dados incoerentes serão descartados.','Aviso','modal'));
            lat(exc) = [];
            lon(exc) = [];
        end
        if isempty(lat)
            beep; uiwait(errordlg('Não foram encontrados vértices válidos.','Erro','modal'));
            return
        end
        scenario.aux(n).data = [scenario.aux(n).data; lat lon];
        M = size(scenario.aux(n).data,1);
        
    case 'aid' % Nav Aids
        beep;
        return
        
    case 'wpt' % Waypoints
        beep;
        return
        
    case 'rt' % Routes
        beep;
        return
        
    case 'fa' % Flight Areas
        if isempty(scenario.fa)
            beep;
            return
        end
        out = editbox('','Latitude / Longitude:',200); drawnow;
        if isempty(out)
            return
        end
        latlon = latlongreadlist(out);
        if isempty(latlon)
            beep; uiwait(errordlg('Coordenadas incoerentes.','Erro','modal'));
            return
        end
        lat = latlon(:,1);
        lon = latlon(:,2);
        exc = [];
        for k = 1:length(lat)
            if lat(k)<-90 || lat(k)>90 || lon(k)<-180 || lon(k)>180
                exc = [exc k];
            end
        end
        if ~isempty(exc)
            uiwait(warndlg('Os vértices com dados incoerentes serão descartados.','Aviso','modal'));
            lat(exc) = [];
            lon(exc) = [];
        end
        if isempty(lat)
            beep; uiwait(errordlg('Não foram encontrados vértices válidos.','Erro','modal'));
            return
        end
        if ~isempty(scenario.fa(n).data)
            scenario.fa(n).data(end,:) = [];
        end
        scenario.fa(n).data = [scenario.fa(n).data; lat lon];
        scenario.fa(n).data(end+1,:) = scenario.fa(n).data(1,:);
        M = size(scenario.fa(n).data,1)-1;
        
    case 'avd' % Avoid Zones
        beep;
        return
        
    case 'thr' % Threat Areas
        beep;
        return
        
    case 'cnt' % Contact Line
        out = editbox('','Latitude / Longitude:',200); drawnow;
        if isempty(out)
            return
        end
        latlon = latlongreadlist(out);
        if isempty(latlon)
            beep; uiwait(errordlg('Coordenadas incoerentes.','Erro','modal'));
            return
        end
        lat = latlon(:,1);
        lon = latlon(:,2);
        exc = [];
        for k = 1:length(lat)
            if lat(k)<-90 || lat(k)>90 || lon(k)<-180 || lon(k)>180
                exc = [exc k];
            end
        end
        if ~isempty(exc)
            uiwait(warndlg('Os vértices com dados incoerentes serão descartados.','Aviso','modal'));
            lat(exc) = [];
            lon(exc) = [];
        end
        if isempty(lat)
            beep; uiwait(errordlg('Não foram encontrados vértices válidos.','Erro','modal'));
            return
        end
        if isempty(scenario.cnt)
            scenario.cnt.data = [];
        end
        scenario.cnt.data = [scenario.cnt.data; lat lon];
        M = size(scenario.cnt.data,1);

end

if ~isequalwithequalnans(scenario,oldscenario)
    handles.chg = 1;
    guidata(hObject, handles);
    
    if istype(ntype,'aux') && ( strcmp(auxtype,'point') || strcmp(auxtype,'text') )
        setscenario(hObject, eventdata, handles, scenario, ntype);
    elseif istype(ntype,'cnt') && size(scenario.cnt.data,1) == length(lat)
        setscenario(hObject, eventdata, handles, scenario, ntype);
    else
        updatescenario(hObject, eventdata, handles, scenario, ntype);
    end
    type_sel(hObject, eventdata, handles, n, M);
end

% --------------------------------------------------------------------
function linecalc_btn_Callback(hObject, eventdata, handles)
% Insere linha calculada

set(handles.linecalc_btn,'Value',0);

ntype = getappdata(handles.window,'ntype');
n     = get(handles.obj_list,'Value');
scenario = getappdata(handles.window,'scenario');
oldscenario = scenario;
Dmaggrid = getappdata(handles.window,'Dmaggrid');

if length(n) ~= 1
    beep;
    return
end

switch ntype
    
    case 'aux' % Auxiliary Shapes
        if isempty(scenario.aux)
            beep;
            return
        end
        auxtype = scenario.aux(n).type;
        if istype(auxtype,'text')
            beep;
            return
        end
        newdata = RDAT_LineCompute(scenario,ntype,n,Dmaggrid);
        if isempty(newdata)
            return
        end
        scenario.aux(n).data = [scenario.aux(n).data; newdata];
        M = size(scenario.aux(n).data,1);
        if istype(auxtype,'point')
            for m = length(scenario.aux(n).code)+1:M
                scenario.aux(n).code{m} = '';
            end
        end
        
    case 'fa'
        if isempty(scenario.fa)
            beep;
            return
        end
        newdata = RDAT_LineCompute(scenario,ntype,n,Dmaggrid);
        if isempty(newdata)
            return
        end
        if ~isempty(scenario.fa(n).data)
            scenario.fa(n).data(end,:) = [];
        end
        scenario.fa(n).data = [scenario.fa(n).data; newdata];
        scenario.fa(n).data(end+1,:) = scenario.fa(n).data(1,:);
        M = size(scenario.fa(n).data,1)-1;

    otherwise
        beep;
        return
        
end

if ~isequalwithequalnans(scenario,oldscenario)
    handles.chg = 1;
    guidata(hObject, handles);
    
    if istype(ntype,'aux') && istype(auxtype,'point')
        setscenario(hObject, eventdata, handles, scenario, ntype);
    else
        updatescenario(hObject, eventdata, handles, scenario, ntype);
    end
    type_sel(hObject, eventdata, handles, n, M);
end

%--------------------------------------------------------------------------
function remparam_btn_Callback(hObject, eventdata, handles)
% Remover parametro de um objeto

ntype = getappdata(handles.window,'ntype');
n     = get(handles.obj_list,'Value');
m     = get(handles.param_list,'Value');
scenario = getappdata(handles.window,'scenario');
oldscenario = scenario;
mm = length(m);

if length(n) ~= 1
    beep;
    return
end

switch ntype
    case 'map' % Maps
        beep;
        return
        
    case 'aux' % Auxiliary Shapes
        if isempty(scenario.aux) || isempty(scenario.aux(n).data)
            beep;
            return
        end
        if mm == 1
            button = questdlg(['Deseja excluir o vértice selecionado do objeto auxiliar ''' scenario.aux(n).name '''?'],'Confirmação','Sim','Não','Não');
        else
            button = questdlg(['Deseja excluir os ' num2str(mm) ' vértices selecionados do objeto auxiliar ''' scenario.aux(n).name '''?'],'Confirmação','Sim','Não','Não');
        end
        if strcmp(button,'Sim')
            scenario.aux(n).data(m,:) = [];
            if istype(scenario.aux(n).type,{'point','text'})
                scenario.aux(n).code(m) = [];
            end
        end
        
    case 'aid' % Nav Aids
        beep;
        return
        
    case 'wpt' % Waypoints
        beep;
        return
        
    case 'rt' % Routes
        if isempty(scenario.rt) || isempty(scenario.rt(n).wpt)
            beep;
            return
        end
        button = questdlg(['Deseja remover o waypoint ' num2str(scenario.rt(n).wpt(m),'%02.0f') ' da rota ' num2str(n) '?'],...
            'Confirmação','Sim','Não','Não');
        if strcmp(button,'Sim')
            scenario.rt(n).wpt(m) = [];
        end
        
    case 'fa' % Flight Areas
        if isempty(scenario.fa) || isempty(scenario.fa(n).data)
            beep;
            return
        end
        if mm == 1
            button = questdlg(['Deseja excluir o vértice selecionado da área ''' scenario.fa(n).code '''?'],'Confirmação','Sim','Não','Não');
        else
            button = questdlg(['Deseja excluir os ' num2str(mm) ' vértices selecionados da área ''' scenario.fa(n).code '''?'],'Confirmação','Sim','Não','Não');
        end
        if strcmp(button,'Sim')
            scenario.fa(n).data(end,:) = [];
            scenario.fa(n).data(m,:)   = [];
            if ~isempty(scenario.fa(n).data)
                scenario.fa(n).data(end+1,:) = scenario.fa(n).data(1,:);
            end
        end
        
    case 'avd' % Avoid Zones
        beep;
        return
        
    case 'thr' % Threat Areas
        beep;
        return
        
    case 'cnt' % Contact Line
        if isempty(scenario.cnt) || isempty(scenario.cnt.data)
            beep;
            return
        end
        if mm == 1
            button = questdlg('Deseja excluir o vértice selecionado da linha de contato?','Confirmação','Sim','Não','Não');
        else
            button = questdlg(['Deseja excluir os ' num2str(mm) ' vértices selecionados da linha de contato?'],'Confirmação','Sim','Não','Não');
        end
        if strcmp(button,'Sim')
            scenario.cnt.data(m,:) = [];
        end
        
end

if ~isequalwithequalnans(scenario,oldscenario)
    handles.chg = 1;
    guidata(hObject, handles);
    
    updatescenario(hObject, eventdata, handles, scenario, ntype);
    type_sel(hObject, eventdata, handles, n, max(1,m(1)-1));
end

%--------------------------------------------------------------------------
function editparam_btn_Callback(hObject, eventdata, handles)
% Editar parametro de um objeto

ntype = getappdata(handles.window,'ntype');
n     = get(handles.obj_list,'Value');
m     = get(handles.param_list,'Value');
scenario = getappdata(handles.window,'scenario');
oldscenario = scenario;

if length(n) ~= 1 || length(m) ~= 1
    beep;
    return
end

switch ntype
    case 'map' % Maps
        beep;
        return
        
    case 'aux' % Auxiliary Shapes
        if isempty(scenario.aux) || isempty(scenario.aux(n).data)
            beep;
            return
        end
        auxtype = scenario.aux(n).type;
        switch auxtype
            case 'point'
                out = inputvalues('Editar ponto',{'Latitude:','Longitude:','Código:'},...
                    {deg2latlong(scenario.aux(n).data(m,1),1,3),deg2latlong(scenario.aux(n).data(m,2),2,3),scenario.aux(n).code{m}}); drawnow;
            case {'line','area'}
                out = inputvalues('Editar vértice',{'Latitude:','Longitude:'},...
                    {deg2latlong(scenario.aux(n).data(m,1),1,3),deg2latlong(scenario.aux(n).data(m,2),2,3)}); drawnow;
            case 'text'
                rot = scenario.aux(n).data(m,3);
                if isnan(rot), rot = ''; else, rot = num2str(rot); end
                out = inputvalues('Editar texto',{'Latitude:','Longitude:','Texto:','Orientação (graus mag.):','Alinhamento:'},...
                    {deg2latlong(scenario.aux(n).data(m,1),1,3),deg2latlong(scenario.aux(n).data(m,2),2,3),scenario.aux(n).code{m},rot,...
                    {'Esquerda','Centro','Direita',scenario.aux(n).data(m,4)+2}}); drawnow;
        end
        if isempty(out)
            return
        end
        [void, lat] = latlongread(out{1});
        [void, lon] = latlongread(out{2});
        if istype(auxtype,{'line','area'}) && ( isempty(lat) || isempty(lon) )
            lat = NaN;
            lon = NaN;
        elseif isempty(lat) || isempty(lon) || lat<-90 || lat>90 || lon<-180 || lon>180
            beep; uiwait(errordlg('Coordenadas incoerentes.','Erro','modal'));
            return
        end
        if istype(auxtype,'point')
            cod = out{3};
            if length(cod) > 12
                cod = cod(1:12);
                uiwait(warndlg('Código truncado em 12 caracteres.','Aviso','modal'));
            end
        end
        if istype(auxtype,'text')
            cod = out{3};
            rot = round(mod(str2double(out{4}),360));
            aln = out{5}-2;
            if isempty(cod)
                beep; uiwait(errordlg('O texto não pode ser vazio.','Erro','modal'));
                return
            end
        else
            rot = [];
            aln = [];
        end
        scenario.aux(n).data(m,:) = [lat lon rot aln];
        if istype(auxtype,{'point','text'})
            scenario.aux(n).code{m} = cod;
        end
        
    case 'aid' % Nav Aids
        beep;
        return
        
    case 'wpt' % Waypoints
        beep;
        return
        
    case 'rt' % Routes
        if isempty(scenario.rt) || isempty(scenario.rt(n).wpt)
            beep;
            return
        end
        [freewpt, ind] = setdiff(scenario.wpt.data(:,1),scenario.rt(n).wpt(:));
        freewpt = [scenario.rt(n).wpt(m); freewpt];
        ind = [find(scenario.rt(n).wpt(m)==scenario.wpt.data(:,1)); ind];
        for k = 1:length(freewpt)
            freewptlist{k} = [num2str(freewpt(k),'%02.0f') '  ' scenario.wpt.code{ind(k)}];
        end
        out = inputvalues('Editar rota','Waypoint:',freewptlist); drawnow;
        if isempty(out)
            return
        end
        scenario.rt(n).wpt(m) = freewpt(out);
        
    case 'fa' % Flight Areas
        if isempty(scenario.fa) || isempty(scenario.fa(n).data)
            beep;
            return
        end
        out = inputvalues('Editar vértice',{'Latitude:','Longitude:'},...
            {deg2latlong(scenario.fa(n).data(m,1),1,3),deg2latlong(scenario.fa(n).data(m,2),2,3)}); drawnow;
        if isempty(out)
            return
        end
        [void, lat] = latlongread(out{1});
        [void, lon] = latlongread(out{2});
        if isempty(lat) || isempty(lon) || lat<-90 || lat>90 || lon<-180 || lon>180
            beep; uiwait(errordlg('Coordenadas incoerentes.','Erro','modal'));
            return
        end
        scenario.fa(n).data(end,:) = [];
        scenario.fa(n).data(m,:) = [lat lon];
        scenario.fa(n).data(end+1,:) = scenario.fa(n).data(1,:);
        
    case 'avd' % Avoid Zones
        beep;
        return
        
    case 'thr' % Threat Areas
        beep;
        return
        
    case 'cnt' % Contact Line
        if isempty(scenario.cnt) || isempty(scenario.cnt.data)
            beep;
            return
        end
        out = inputvalues('Editar vértice',{'Latitude:','Longitude:'},...
            {deg2latlong(scenario.cnt.data(m,1),1,3),deg2latlong(scenario.cnt.data(m,2),2,3)}); drawnow;
        if isempty(out)
            return
        end
        [void, lat] = latlongread(out{1});
        [void, lon] = latlongread(out{2});
        if isempty(lat) || isempty(lon) || lat<-90 || lat>90 || lon<-180 || lon>180
            beep; uiwait(errordlg('Coordenadas incoerentes.','Erro','modal'));
            return
        end
        scenario.cnt.data(m,:) = [lat lon];
end

if ~isequalwithequalnans(scenario,oldscenario)
    handles.chg = 1;
    guidata(hObject, handles);
    
    updatescenario(hObject, eventdata, handles, scenario, ntype);
    obj_list_Callback(hObject, eventdata, handles, m);
end

%--------------------------------------------------------------------------
function upparam_btn_Callback(hObject, eventdata, handles)
% Mover parametro para cima

ntype = getappdata(handles.window,'ntype');
n     = get(handles.obj_list,'Value');
m     = get(handles.param_list,'Value');
scenario = getappdata(handles.window,'scenario');
oldscenario = scenario;

if length(n) ~= 1 || length(m) ~= 1
    beep;
    return
end

if isempty(m) || m == 1
    beep;
    return
end

switch ntype
    case 'map' % Maps
        beep;
        return
        
    case 'aux' % Auxiliary Shapes
        if isempty(scenario.aux) || isempty(scenario.aux(n).data)
            beep;
            return
        end
        aux                         = scenario.aux(n).data(m-1,:);
        scenario.aux(n).data(m-1,:) = scenario.aux(n).data(m,:);
        scenario.aux(n).data(m,:)   = aux;
        if istype(scenario.aux(n).type,{'point','text'})
            aux                       = scenario.aux(n).code{m-1};
            scenario.aux(n).code{m-1} = scenario.aux(n).code{m};
            scenario.aux(n).code{m}   = aux;
        end
        
    case 'aid' % Nav Aids
        beep;
        return
        
    case 'wpt' % Waypoints
        beep;
        return
        
    case 'rt' % Routes
        if isempty(scenario.rt) || isempty(scenario.rt(n).wpt)
            beep;
            return
        end
        aux                     = scenario.rt(n).wpt(m-1);
        scenario.rt(n).wpt(m-1) = scenario.rt(n).wpt(m);
        scenario.rt(n).wpt(m)   = aux;
        
    case 'fa' % Flight Areas
        if isempty(scenario.fa) || isempty(scenario.fa(n).data)
            beep;
            return
        end
        scenario.fa(n).data(end,:)   = [];
        aux                          = scenario.fa(n).data(m-1,:);
        scenario.fa(n).data(m-1,:)   = scenario.fa(n).data(m,:);
        scenario.fa(n).data(m,:)     = aux;
        scenario.fa(n).data(end+1,:) = scenario.fa(n).data(1,:);
        
    case 'avd' % Avoid Zones
        beep;
        return
        
    case 'thr' % Threat Areas
        beep;
        return
        
    case 'cnt' % Contact Line
        if isempty(scenario.cnt) || isempty(scenario.cnt.data)
            beep;
            return
        end
        aux                      = scenario.cnt.data(m-1,:);
        scenario.cnt.data(m-1,:) = scenario.cnt.data(m,:);
        scenario.cnt.data(m,:)   = aux;
        
end

if ~isequalwithequalnans(scenario,oldscenario)
    handles.chg = 1;
    guidata(hObject, handles);
    
    updatescenario(hObject, eventdata, handles, scenario, ntype);
    obj_list_Callback(hObject, eventdata, handles, m-1);
end

% --------------------------------------------------------------------
function dnparam_btn_Callback(hObject, eventdata, handles)
% Mover parametro para baixo

ntype = getappdata(handles.window,'ntype');
n     = get(handles.obj_list,'Value');
m     = get(handles.param_list,'Value');
scenario = getappdata(handles.window,'scenario');
oldscenario = scenario;

if length(n) ~= 1 || length(m) ~= 1
    beep;
    return
end

if isempty(m) || m >= length(cellstr(get(handles.param_list,'String')))
    beep;
    return
end

switch ntype
    case 'map' % Maps
        beep;
        return
        
    case 'aux' % Auxiliary Shapes
        if isempty(scenario.aux) || isempty(scenario.aux(n).data)
            beep;
            return
        end
        aux                         = scenario.aux(n).data(m+1,:);
        scenario.aux(n).data(m+1,:) = scenario.aux(n).data(m,:);
        scenario.aux(n).data(m,:)   = aux;
        if istype(scenario.aux(n).type,{'point','text'})
            aux                       = scenario.aux(n).code{m+1};
            scenario.aux(n).code{m+1} = scenario.aux(n).code{m};
            scenario.aux(n).code{m}   = aux;
        end
        
    case 'aid' % Nav Aids
        beep;
        return
        
    case 'wpt' % Waypoints
        beep;
        return
        
    case 'rt' % Routes
        if isempty(scenario.rt) || isempty(scenario.rt(n).wpt)
            beep;
            return
        end
        aux                     = scenario.rt(n).wpt(m+1);
        scenario.rt(n).wpt(m+1) = scenario.rt(n).wpt(m);
        scenario.rt(n).wpt(m)   = aux;
        
    case 'fa' % Flight Areas
        if isempty(scenario.fa) || isempty(scenario.fa(n).data)
            beep;
            return
        end
        scenario.fa(n).data(end,:)   = [];
        aux                          = scenario.fa(n).data(m+1,:);
        scenario.fa(n).data(m+1,:)   = scenario.fa(n).data(m,:);
        scenario.fa(n).data(m,:)     = aux;
        scenario.fa(n).data(end+1,:) = scenario.fa(n).data(1,:);
        
    case 'avd' % Avoid Zones
        beep;
        return
        
    case 'thr' % Threat Areas
        beep;
        return
        
    case 'cnt' % Contact Line
        if isempty(scenario.cnt) || isempty(scenario.cnt.data)
            beep;
            return
        end
        aux                      = scenario.cnt.data(m+1,:);
        scenario.cnt.data(m+1,:) = scenario.cnt.data(m,:);
        scenario.cnt.data(m,:)   = aux;
        
end

if ~isequalwithequalnans(scenario,oldscenario)
    handles.chg = 1;
    guidata(hObject, handles);
    
    updatescenario(hObject, eventdata, handles, scenario, ntype);
    obj_list_Callback(hObject, eventdata, handles, m+1);
end

% --------------------------------------------------------------------
function getparam_btn_Callback(hObject, eventdata, handles)
% Botao para obter parametro clicando no grafico

ntype = getappdata(handles.window,'ntype');
objlist = deblank(get(handles.obj_list,'String'));

if istype(ntype,'cnt') || ( istype(ntype,{'aux','rt','fa'}) && ~isempty(objlist) )
    set([handles.zoom_btn handles.drag_btn handles.getobj_btn],'Value',0);
else
    beep;
    set(handles.getparam_btn,'Value',0);
end

% --------------------------------------------------------------------
function setscenario(hObject, eventdata, handles, scenario, ntype, autofit)
% Recria o cenario

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

set(handles.sel_list,'Enable','inactive');

if nargin <= 4
    ntype = {'map','aux','aid','wpt','rt','fa','avd','thr','cnt'};
end
if nargin <= 5
    autofit = 0;
end

set(handles.window,'Pointer','watch');

% Apagar todo o cenario atual

hsel = getappdata(handles.window,'hsel');
delete(hsel);
setappdata(handles.window,'hsel',[]);

if istype(ntype,'map') && ~isempty(handles.map)
    delete(handles.map);
    handles.map = [];
end
if istype(ntype,'aux') && ~isempty(handles.aux)
    delete([handles.aux cell2mat(handles.auxlbl)]);
    handles.aux    = [];
    handles.auxlbl = {};
end
if istype(ntype,'aid') && ~isempty(handles.aid)
    delete([handles.aid handles.aidlbl]);
    handles.aid    = [];
    handles.aidlbl = [];
end
if istype(ntype,{'wpt','rt'}) && ~isempty(handles.wpt)
    delete([handles.wpt handles.wptnumlbl handles.wptcodlbl]);
    handles.wpt = [];
    handles.wptnumlbl = [];
    handles.wptcodlbl = [];
end
if istype(ntype,{'wpt','rt'}) && ~isempty(handles.rt)
    delete(handles.rt);
    handles.rt = [];
end
if istype(ntype,'fa') && ~isempty(handles.fa)
    delete([handles.fa handles.falbl]);
    handles.fa = [];
    handles.falbl = [];
end
if istype(ntype,'avd') && ~isempty(handles.avd)
    delete([handles.avd handles.avdlbl]);
    handles.avd = [];
    handles.avdlbl = [];
end
if istype(ntype,'thr') && ~isempty(handles.thr)
    delete([handles.thr handles.thrlbl]);
    handles.thr = [];
    handles.thrlbl = [];
end
if istype(ntype,'cnt') && ~isempty(handles.cnt)
    delete(handles.cnt);
    handles.cnt = [];
end

% Recriaçao do cenario
try
    
    set(handles.Dmag_entry,'String',num2str(scenario.Dmag));
    
    axes(handles.TSD);
    
    % Map
    exc = [];
    if istype(ntype,'map') && ~isempty(scenario.map)
        if exist(which('DatMaps.mat'),'file')
            load(which('DatMaps.mat'),'mapdb');
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
                handles.map(n) = image(scenario.map(n).data([1,4],2),scenario.map(n).data([1,4],1),mapdata,'AlphaData',alpha);
                drawnow;
            end
        else
            beep; uiwait(errordlg('Base de dados de mapas não encontrada.','Erro','modal'));
            exc = 1:length(scenario.map);
        end
        if ~isempty(exc)
            scenario.map(exc) = [];
            if ~isempty(handles.map)
                delete(handles.map(exc));
                handles.map(exc) = [];
            end
        end
    end
    
    % Auxiliary Shapes
    if istype(ntype,'aux')
        for n = 1:length(scenario.aux)
            auxtype  = scenario.aux(n).type;
            auxstyle = scenario.aux(n).style;
            auxcolor = scenario.aux(n).color;
            auxwidth = scenario.aux(n).width;
            if ~isempty(scenario.aux(n).data)
                Xaux = scenario.aux(n).data(:,2);
                Yaux = scenario.aux(n).data(:,1);
                if strcmp(auxtype,'text')
                    Raux = 90 - scenario.aux(n).data(:,3) - scenario.Dmag;
                    Raux(isnan(Raux)) = 0;
                    Aaux = scenario.aux(n).data(:,4)+2;
                    alnlist = {'left','center','right'};
                end
            else
                Xaux = [NaN; NaN];
                Yaux = [NaN; NaN];
                Raux = [0; 0];
            end
            switch auxtype
                case {'point','line'}
                    handles.aux(n) = plot3(Xaux,Yaux,ones(size(Xaux)),auxstyle,'Color',auxcolor,'LineWidth',pix2width(auxwidth),'MarkerSize',8);
                case 'area'
                    handles.aux(n) = patchplot(Xaux,Yaux,auxcolor);
            end
            switch auxtype
                case 'point'
                    for m = 1:length(scenario.aux(n).code)
                        if ~isnan(Xaux(m)+Yaux(m))
                            handles.auxlbl{n}(m) = text(Xaux(m),Yaux(m),1,{' ',' ',scenario.aux(n).code{m}},'Color',auxcolor,'HorizontalAlignment','center','Interpreter','none');
                        else
                            handles.auxlbl{n}(m) = text(0,0,1,' ','Color',auxcolor,'HorizontalAlignment','center','Interpreter','none');
                        end
                    end
                case 'text'
                    handles.aux(n) = plot(NaN,NaN,'-k');
                    for m = 1:length(scenario.aux(n).code)
                        if ~isnan(Xaux(m)+Yaux(m))
                            handles.auxlbl{n}(m) = text(Xaux(m),Yaux(m),1,scenario.aux(n).code{m},'Rotation',Raux(m),'HorizontalAlignment',alnlist{Aaux(m)},'Color',auxcolor,'Interpreter','TeX');
                        else
                            handles.auxlbl{n}(m) = text(0,0,1,' ','Rotation',0,'HorizontalAlignment','center','Color',auxcolor,'Interpreter','TeX');
                        end
                    end
                otherwise
                    handles.auxlbl{n} = [];
            end
        end
    end
    
    % Flight areas
    if istype(ntype,'fa')
        for n = 1:length(scenario.fa)
            if ~isempty(scenario.fa(n).data)
                Xfa = scenario.fa(n).data(:,2);
                Yfa = scenario.fa(n).data(:,1);
            else
                Xfa = [NaN; NaN];
                Yfa = [NaN; NaN];
            end
            handles.fa(n) = plot3(Xfa,Yfa,ones(size(Xfa)),scenario.fa(n).style,'Color',scenario.fa(n).color);
            handles.falbl(n) = text(denanpos(nanmean(Xfa(1:end-1))),denanpos(nanmean(Yfa(1:end-1))),1,scenario.fa(n).code,...
                'HorizontalAlignment','center','Color',scenario.fa(n).color,'Interpreter','none');
        end
    end
    
    % Contact line
    if istype(ntype,'cnt')
        if ~isempty(scenario.cnt) && ~isempty(scenario.cnt.data)
            handles.cnt = plot3(scenario.cnt.data(:,2),scenario.cnt.data(:,1),ones(size(scenario.cnt.data,1),1),'-r');
        end
    end
    
    % Avoid zones
    if istype(ntype,'avd') && ~isempty(scenario.avd)
        for n = 1:length(scenario.avd.code)
            Xavd = scenario.avd.data(n,2);
            Yavd = scenario.avd.data(n,1);
            Ravd = scenario.avd.data(n,3);
            [Ry, Rx] = dxdy2latlong(Yavd,Xavd,Ravd*1852,Ravd*1852);
            Ry = Ry-Yavd;
            Rx = Rx-Xavd;
            handles.avd(n) = plot3(Xavd+Rx*cos(linspace(0,2*pi,36)),Yavd+Ry*sin(linspace(0,2*pi,36)),ones(36,1),'--y');
            handles.avdlbl(n) = text(Xavd,Yavd,1,scenario.avd.code{n},'HorizontalAlignment','center','Color','y','Interpreter','none');
        end
    end
    
    % Threat areas
    if istype(ntype,'thr') && ~isempty(scenario.thr)
        for n = 1:length(scenario.thr.code)
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
            handles.thr(n) = plot3(Xthr+[Rx1*cos(linspace(0,2*pi,36)) NaN Rx2*cos(linspace(0,2*pi,36))],...
                Ythr+[Ry1*sin(linspace(0,2*pi,36)) NaN Ry2*sin(linspace(0,2*pi,36))],ones(2*36+1,1),'--r');
            handles.thrlbl(n) = text(Xthr,Ythr,1,scenario.thr.code{n},'HorizontalAlignment','center','Color','r','Interpreter','none');
        end
    end
    
    % Nav Aids
    if istype(ntype,'aid') && ~isempty(scenario.aid)
        for n = 1:length(scenario.aid.code)
            Xaid = scenario.aid.data(n,2);
            Yaid = scenario.aid.data(n,1);
            Raid = 90-45 - scenario.aid.data(n,4) - scenario.Dmag;
            if isnan(Raid)
                Raid = 0;
            end
            [aidchar,aidfont,aidweight,aidsize,aidcolor] = navaidprop(scenario.aid.type{n});
            handles.aid(n)    = text(Xaid,Yaid,1,aidchar,'Rotation',Raid,'FontName',aidfont,'FontWeight',aidweight,'FontSize',aidsize,'Color',aidcolor,'HorizontalAlignment','center','Interpreter','TeX');
            handles.aidlbl(n) = text(Xaid,Yaid,1,{' ',' ',scenario.aid.code{n}},'Color',aidcolor,'HorizontalAlignment','center','Interpreter','none');
        end
    end

    % Waypoints
    if istype(ntype,{'wpt','rt'}) && ~isempty(scenario.wpt)
        Xwpt = scenario.wpt.data(:,3);
        Ywpt = scenario.wpt.data(:,2);
        
        showwpt = ones(size(Xwpt));
        if ~isempty(scenario.aid) && get(handles.aid_chk,'Value')
            Xaid = scenario.aid.data(:,2);
            Yaid = scenario.aid.data(:,1);
            for n = 1:length(Xwpt)
                if any(sqrt((Xwpt(n)-Xaid).^2+(Ywpt(n)-Yaid).^2)<1/6000)
                    showwpt(n) = NaN;
                end
            end
        end
        
        % Routes
        for n = 1:length(scenario.rt)
            rtwpt = scenario.rt(n).wpt;
            nrtwpt = [];
            for m = 1:length(rtwpt)
                nrtwpt = [nrtwpt find(rtwpt(m)==scenario.wpt.data(:,1))];
            end
            if isempty(nrtwpt)
                handles.rt(n) = plot3(NaN,NaN,1,'-m');
            else
                handles.rt(n) = plot3(Xwpt(nrtwpt),Ywpt(nrtwpt),ones(size(nrtwpt)),'-m');
            end
        end
        handles.wpt = plot3(showwpt.*Xwpt,Ywpt,ones(size(Xwpt)),'om','MarkerSize',8);
        
        for n = 1:length(scenario.wpt.code)
            if ~isnan(showwpt(n))
                cod = scenario.wpt.code{n};
            else
                cod = ' ';
            end
            handles.wptcodlbl(n) = text(Xwpt(n),Ywpt(n),1,{' ',' ',cod},'HorizontalAlignment','center','Color','m','Interpreter','none');
            handles.wptnumlbl(n) = text(Xwpt(n),Ywpt(n),1,['   ' num2str(scenario.wpt.data(n,1),'%02.0f')],'HorizontalAlignment','left','Color','m','Interpreter','none');
        end
        
    end
    
    set(setdiff(findobj(handles.TSD,'Type','line'),handles.aux),'LineWidth',1.5);
    set(setdiff(findobj(handles.TSD,'Type','text'),handles.aid),'FontWeight','demi','FontName','Arial');
    set(findobj(handles.TSD,'Type','text'),'Clipping','on');
    decluter(hObject, eventdata, handles);
    setappdata(handles.window,'scenario',scenario);
    
catch
    
    if istype(ntype,'map') && ~isempty(handles.map)
        delete(handles.map);
        handles.map = [];
    end
    if istype(ntype,'aux') && ~isempty(handles.aux)
        delete([handles.aux cell2mat(handles.auxlbl)]);
        handles.aux    = [];
        handles.auxlbl = {};
    end
    if istype(ntype,'wpt') && ~isempty(handles.wpt)
        delete([handles.wpt handles.wptnumlbl handles.wptcodlbl]);
        handles.wpt = [];
        handles.wptnumlbl = [];
        handles.wptcodlbl = [];
    end
    if istype(ntype,'rt') && ~isempty(handles.rt)
        delete(handles.rt);
        handles.rt = [];
    end
    if istype(ntype,'fa') && ~isempty(handles.fa)
        delete([handles.fa handles.falbl]);
        handles.fa = [];
        handles.falbl = [];
    end
    if istype(ntype,'avd') && ~isempty(handles.avd)
        delete([handles.avd handles.avdlbl]);
        handles.avd = [];
        handles.avdlbl = [];
    end
    if istype(ntype,'thr') && ~isempty(handles.thr)
        delete([handles.thr handles.thrlbl]);
        handles.thr = [];
        handles.thrlbl = [];
    end
    if istype(ntype,'cnt') && ~isempty(handles.cnt)
        delete(handles.cnt);
        handles.cnt = [];
    end
    
    beep; uiwait(errordlg('Erro ao carregar cenário.','Erro','modal'));
    
end

guidata(hObject, handles);
set(handles.window,'Pointer','arrow');

if autofit
    fit_btn_Callback(hObject, eventdata, handles);
else
    adjust_aspect(hObject, eventdata, handles);
end

set(handles.sel_list,'Enable','on');

% Trazer Declutter Labels e Regua para a camada superior
bringtofront(handles.TSD,handles.lbl);
bringtofront(handles.TSD,[handles.ruler handles.rulertag1 handles.rulertag2]);

% --------------------------------------------------------------------
function updatescenario(hObject, eventdata, handles, scenario, ntype)
% Atualiza cenario atual

if nargin == 4
    ntype = {'map','aux','aid','wpt','rt','fa','avd','thr','cnt'};
end

if ~isempty(scenario)
    
    % Atualizaçao do cenario
    
    set(handles.Dmag_entry,'String',num2str(scenario.Dmag));
    
    % Map
    if istype(ntype,'map')
        for n = 1:length(scenario.map)
            set(handles.map(n),'XData',scenario.map(n).data([1,4],2),'YData',scenario.map(n).data([1,4],1));
        end
    end
    
    % Auxiliary Shapes
    if istype(ntype,'aux')
        for n = 1:length(scenario.aux)
            auxtype = scenario.aux(n).type;
            auxstyle = scenario.aux(n).style;
            auxcolor = scenario.aux(n).color;
            auxwidth = scenario.aux(n).width;
            if ~isempty(scenario.aux(n).data)
                Xaux = scenario.aux(n).data(:,2);
                Yaux = scenario.aux(n).data(:,1);
                if strcmp(auxtype,'text')
                    Raux = 90 - scenario.aux(n).data(:,3) - scenario.Dmag;
                    Raux(isnan(Raux)) = 0;
                    Aaux = scenario.aux(n).data(:,4)+2;
                    alnlist = {'left','center','right'};
                end
            else
                Xaux = [NaN; NaN];
                Yaux = [NaN; NaN];
                Raux = [0; 0];
            end
            switch auxtype
                case 'point'
                    set(handles.aux(n),'XData',Xaux,'YData',Yaux,'ZData',ones(size(Xaux)),'Marker',auxstyle,'Color',auxcolor,'LineWidth',pix2width(auxwidth));
                case 'line'
                    set(handles.aux(n),'XData',Xaux,'YData',Yaux,'ZData',ones(size(Xaux)),'LineStyle',auxstyle,'Color',auxcolor,'LineWidth',pix2width(auxwidth));
                case 'area'
                    [Xaux, Yaux] = patchplot(Xaux,Yaux);
                    set(handles.aux(n),'XData',Xaux,'YData',Yaux,'ZData',ones(size(Xaux)),'FaceColor',auxcolor);
            end
            switch auxtype
                case 'point'
                    for m = 1:length(scenario.aux(n).code)
                        if ~isnan(Xaux(m)+Yaux(m))
                            set(handles.auxlbl{n}(m),'Position',[Xaux(m),Yaux(m),1],'String',{' ',' ',scenario.aux(n).code{m}},'Color',auxcolor);
                        else
                            set(handles.auxlbl{n}(m),'Position',[0,0,1],'String',' ','Color',auxcolor);
                        end
                    end
                case 'text'
                    for m = 1:length(scenario.aux(n).code)
                        if ~isnan(Xaux(m)+Yaux(m))
                            set(handles.auxlbl{n}(m),'Position',[Xaux(m),Yaux(m),1],'String',scenario.aux(n).code{m},'Rotation',Raux(m),'HorizontalAlignment',alnlist{Aaux(m)},'Color',auxcolor);
                        else
                            set(handles.auxlbl{n}(m),'Position',[0,0,1],0,'String','Rotation',0,'Color',auxcolor);
                        end
                    end
            end
        end
    end
    
    % Nav Aids
    if istype(ntype,'aid') && ~isempty(scenario.aid)
        for n = 1:length(scenario.aid.code)
            Xaid = scenario.aid.data(n,2);
            Yaid = scenario.aid.data(n,1);
            Raid = 90-45 - scenario.aid.data(n,4) - scenario.Dmag;
            if isnan(Raid)
                Raid = 0;
            end
            [aidchar,aidfont,aidweight,aidsize] = navaidprop(scenario.aid.type{n});
            set(handles.aid(n)   ,'Position',[Xaid,Yaid,1],'Rotation',Raid,'String',aidchar,'FontName',aidfont,'FontWeight',aidweight,'FontSize',aidsize);
            set(handles.aidlbl(n),'Position',[Xaid,Yaid,1],'String',{' ',' ',scenario.aid.code{n}});
        end
    end
    
    % Waypoints
    if istype(ntype,{'aid','wpt','rt'}) && ~isempty(scenario.wpt)
        Xwpt = scenario.wpt.data(:,3);
        Ywpt = scenario.wpt.data(:,2);
        
        showwpt = ones(size(Xwpt));
        if ~isempty(scenario.aid) && get(handles.aid_chk,'Value')
            Xaid = scenario.aid.data(:,2);
            Yaid = scenario.aid.data(:,1);
            for n = 1:length(Xwpt)
                if any(sqrt((Xwpt(n)-Xaid).^2+(Ywpt(n)-Yaid).^2)<1/6000)
                    showwpt(n) = NaN;
                end
            end
        end

        % Routes
        for n = 1:length(scenario.rt)
            rtwpt = scenario.rt(n).wpt;
            nrtwpt = [];
            for m = 1:length(rtwpt)
                nrtwpt = [nrtwpt find(rtwpt(m)==scenario.wpt.data(:,1))];
            end
            if isempty(nrtwpt)
                set(handles.rt(n),'XData',NaN,'YData',NaN,'ZData',1);
            else
                set(handles.rt(n),'XData',Xwpt(nrtwpt),'YData',Ywpt(nrtwpt),'ZData',ones(size(nrtwpt)));
            end
        end
        set(handles.wpt,'XData',showwpt.*Xwpt,'YData',Ywpt,'ZData',ones(size(Xwpt)));
        
        for n = 1:length(scenario.wpt.code)
            if ~isnan(showwpt(n))
                cod = scenario.wpt.code{n};
            else
                cod = ' ';
            end
            set(handles.wptcodlbl(n),'Position',denanpos([Xwpt(n) Ywpt(n) 1]),'String',{' ',' ',cod});
            set(handles.wptnumlbl(n),'Position',denanpos([Xwpt(n) Ywpt(n) 1]),'String',['   ' num2str(scenario.wpt.data(n,1),'%02.0f')]);
        end
        
    end
    
    % Flight areas
    if istype(ntype,'fa')
        for n = 1:length(scenario.fa)
            if ~isempty(scenario.fa(n).data)
                Xfa = scenario.fa(n).data(:,2);
                Yfa = scenario.fa(n).data(:,1);
            else
                Xfa = [NaN; NaN];
                Yfa = [NaN; NaN];
            end
            set(handles.fa(n),'XData',Xfa,'YData',Yfa,'ZData',ones(size(Xfa)),'LineStyle',scenario.fa(n).style,...
                'Color',scenario.fa(n).color);
            set(handles.falbl(n),'Position',denanpos([nanmean(Xfa(1:end-1)) nanmean(Yfa(1:end-1)) 1]),'String',scenario.fa(n).code,...
                'Color',scenario.fa(n).color);
        end
    end
    
    % Avoid zones
    if istype(ntype,'avd') && ~isempty(scenario.avd)
        for n = 1:length(scenario.avd.code)
            Xavd = scenario.avd.data(n,2);
            Yavd = scenario.avd.data(n,1);
            Ravd = scenario.avd.data(n,3);
            [Ry, Rx] = dxdy2latlong(Yavd,Xavd,Ravd*1852,Ravd*1852);
            Ry = Ry-Yavd;
            Rx = Rx-Xavd;
            set(handles.avd(n),'XData',Xavd+Rx*cos(linspace(0,2*pi,36)),'YData',Yavd+Ry*sin(linspace(0,2*pi,36)));
            set(handles.avdlbl(n),'Position',denanpos([Xavd Yavd 1]),'String',scenario.avd.code{n});
        end
    end
    
    % Threat areas
    if istype(ntype,'thr') && ~isempty(scenario.thr)
        for n = 1:length(scenario.thr.code)
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
            set(handles.thr(n),'XData',Xthr+[Rx1*cos(linspace(0,2*pi,36)) NaN Rx2*cos(linspace(0,2*pi,36))],...
                'YData',Ythr+[Ry1*sin(linspace(0,2*pi,36)) NaN Ry2*sin(linspace(0,2*pi,36))]);
            set(handles.thrlbl(n),'Position',denanpos([Xthr Ythr 1]),'String',scenario.thr.code{n});
        end
    end
    
    % Contact line
    if istype(ntype,'cnt')
        if ~isempty(scenario.cnt)
            set(handles.cnt,'XData',scenario.cnt.data(:,2),'YData',scenario.cnt.data(:,1),'ZData',ones(size(scenario.cnt.data,1),1));
        else
            set(handles.cnt,'XData',NaN,'YData',NaN,'ZData',NaN);
        end
    end
    
    setappdata(handles.window,'scenario',scenario);
    
end

% --------------------------------------------------------------------
function updaterulertags(hObject, eventdata, handles)
% Atualiza dados da regua

if ~get(handles.ruler_btn,'Value')
    return
end

xr = get(handles.ruler,'XData');
yr = get(handles.ruler,'YData');

Dmag = str2double(get(handles.Dmag_entry,'String'));

[DE, DN] = latlong2dxdy(yr(1),xr(1),yr(2),xr(2));

Rng = sqrt(DE^2+DN^2)/1852;
Brg = mod(atan2(DE,DN)*180/pi-Dmag,360);

if DE >= 0
    a1 = 'right';
    a2 = 'left';
else
    a1 = 'left';
    a2 = 'right';
end

set(handles.rulertag1,'String',['  ' num2str(Brg,'%03.0f') 'º  '] ,'Position',[xr(1) yr(1) 0],'HorizontalAlignment',a1);
set(handles.rulertag2,'String',['  ' num2str(Rng,'%0.1f') ' NM  '],'Position',[xr(2) yr(2) 0],'HorizontalAlignment',a2);

%--------------------------------------------------------------------------
function aid_chk_Callback(hObject, eventdata, handles)
% Alterna exibiçao dos auxilios/aerodromos

scenario = getappdata(handles.window,'scenario');
updatescenario(hObject, eventdata, handles, scenario, 'aid');
decluter(hObject, eventdata, handles);

%--------------------------------------------------------------------------
function wpt_chk_Callback(hObject, eventdata, handles)
% Alterna exibiçao dos waypoints

scenario = getappdata(handles.window,'scenario');
updatescenario(hObject, eventdata, handles, scenario, 'aid');
decluter(hObject, eventdata, handles);

%--------------------------------------------------------------------------
function decluter(hObject, eventdata, handles)
% Alterna exibiçao dos objetos

map = get(handles.map_chk,'Value');
aux = get(handles.aux_chk,'Value');
aid = get(handles.aid_chk,'Value');
wpt = get(handles.wpt_chk,'Value');
fa  = get(handles.fa_chk,'Value');
rt  = get(handles.rt_chk,'Value');
avd = get(handles.avd_chk,'Value');
thr = get(handles.thr_chk,'Value');
cnt = get(handles.cnt_chk,'Value');
lbl = get(handles.lbl_chk,'Value');

if ~isempty(handles.map)
    if map
        set(handles.map,'Visible','on');
        set(handles.wpt,'MarkerFaceColor','none');
    else
        set(handles.map,'Visible','off');
        set(handles.wpt,'MarkerFaceColor','k');
    end
end
if ~isempty(handles.aux)
    if aux
        set([handles.aux cell2mat(handles.auxlbl)],'Visible','on');
    else
        set([handles.aux cell2mat(handles.auxlbl)],'Visible','off');
    end
end
if ~isempty(handles.aid)
    if aid
        set([handles.aid handles.aidlbl],'Visible','on');
    else
        set([handles.aid handles.aidlbl],'Visible','off');
    end
end
if ~isempty(handles.wpt)
    if wpt
        set([handles.wpt handles.wptnumlbl handles.wptcodlbl],'Visible','on');
    else
        set([handles.wpt handles.wptnumlbl handles.wptcodlbl],'Visible','off');
    end
end
if ~isempty(handles.fa)
    if fa
        set([handles.fa handles.falbl],'Visible','on');
    else
        set([handles.fa handles.falbl],'Visible','off');
    end
end
if ~isempty(handles.rt)
    if rt
        set(handles.rt,'Visible','on');
    else
        set(handles.rt,'Visible','off');
    end
end
if ~isempty(handles.avd)
    if avd
        set([handles.avd handles.avdlbl],'Visible','on');
    else
        set([handles.avd handles.avdlbl],'Visible','off');
    end
end
if ~isempty(handles.thr)
    if thr
        set([handles.thr handles.thrlbl],'Visible','on');
    else
        set([handles.thr handles.thrlbl],'Visible','off');
    end
end
if ~isempty(handles.cnt)
    if cnt
        set(handles.cnt,'Visible','on');
    else
        set(handles.cnt,'Visible','off');
    end
end
if lbl
    vislist = [];
    if aux
        vislist = [vislist cell2mat(handles.auxlbl)];
    end
    if aid
        vislist = [vislist handles.aidlbl];
    end
    if wpt
        vislist = [vislist handles.wptcodlbl];
    end
    if fa
        vislist = [vislist handles.falbl];
    end
    if avd
        vislist = [vislist handles.avdlbl];
    end
    if thr
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

% --------------------------------------------------------------------
function selmenu_Callback(hObject, eventdata, handles)
% Menu do botao direito sobre o ponto selecionado

setappdata(handles.window,'dragdata',0);
set(handles.window,'Pointer','arrow');

% --------------------------------------------------------------------
function remsel_Callback(hObject, eventdata, handles)
% Menu do botao direito sobre o ponto selecionado -> apagar

ntype = getappdata(handles.window,'ntype');

switch ntype
    case 'map' % Maps
        beep;
        
    case 'aux' % Auxiliary Shapes
        remparam_btn_Callback(hObject, eventdata, handles);
        
    case 'aid' % Nav Aids
        remobj_btn_Callback(hObject, eventdata, handles);
        
    case 'wpt' % Waypoints
        remobj_btn_Callback(hObject, eventdata, handles);
        
    case 'rt' % Routes
        remparam_btn_Callback(hObject, eventdata, handles);
        
    case 'fa' % Flight Areas
        remparam_btn_Callback(hObject, eventdata, handles);
        
    case 'avd' % Avoid Zones
        remobj_btn_Callback(hObject, eventdata, handles);
        
    case 'thr' % Threat Areas
        remobj_btn_Callback(hObject, eventdata, handles);
        
    case 'cnt' % Contact Line
        remparam_btn_Callback(hObject, eventdata, handles);
        
end

% --------------------------------------------------------------------
function editsel_Callback(hObject, eventdata, handles)
% Menu do botao direito sobre o ponto selecionado -> editar

ntype = getappdata(handles.window,'ntype');

switch ntype
    case 'map' % Maps
        beep;
        
    case 'aux' % Auxiliary Shapes
        editparam_btn_Callback(hObject, eventdata, handles);
        
    case 'aid' % Nav Aids
        editobj_btn_Callback(hObject, eventdata, handles);
        
    case 'wpt' % Waypoints
        editobj_btn_Callback(hObject, eventdata, handles);
        
    case 'rt' % Routes
        editparam_btn_Callback(hObject, eventdata, handles);
        
    case 'fa' % Flight Areas
        editparam_btn_Callback(hObject, eventdata, handles);
        
    case 'avd' % Avoid Zones
        editobj_btn_Callback(hObject, eventdata, handles);
        
    case 'thr' % Threat Areas
        editobj_btn_Callback(hObject, eventdata, handles);
        
    case 'cnt' % Contact Line
        editparam_btn_Callback(hObject, eventdata, handles);
        
end

% --------------------------------------------------------------------
function getobj(hObject, eventdata, handles, lat, lon)
% Acrescentar objeto à lista a partir do grafico

ntype = getappdata(handles.window,'ntype');
scenario = getappdata(handles.window,'scenario');
oldscenario = scenario;

switch ntype
    case 'map' % Maps
        beep;
        return
        
    case 'aux' % Auxiliary Shapes
        beep;
        return
        
    case 'aid' % Nav Aids
        namelist = {'NDB','VOR','VOR/DME','DME','Fixo','Aeródromo'};
        typelist = {'NDB','VOR','VOR/DME','DME','FIX' ,'AFLD'     };
        out = inputvalues('Novo NavAid',{'Tipo:','Código:','Latitude:','Longitude:','Elevação (ft):','Proa (aeródromo):'},...
            {namelist,'',deg2latlong(lat,1,3),deg2latlong(lon,2,3),'0',''}); drawnow;
        if isempty(out)
            return
        end
        typ = typelist{out{1}};
        cod = out{2};
        [void, lat] = latlongread(out{3});
        [void, lon] = latlongread(out{4});
        alt = str2double(out{5});
        psi = str2double(out{6});
        if isempty(lat) || isempty(lon) || lat<-90 || lat>90 || lon<-180 || lon>180
            beep; uiwait(errordlg('Coordenadas incoerentes.','Erro','modal'));
            return
        end
        if isnan(alt) || alt<-2000 || alt>100000
            beep; uiwait(errordlg('Elevação incoerente.','Erro','modal'));
            return
        end
        if ~istype(typ,'AFLD')
            psi = NaN;
        elseif isnan(psi) || psi<0 || psi>360
            beep; uiwait(errordlg('Proa incoerente.','Erro','modal'));
            return
        end
        if length(cod) > 12
            cod = cod(1:12);
            uiwait(warndlg('Código truncado em 12 caracteres.','Aviso','modal'));
        end
        if isempty(scenario.aid)
            scenario.aid.code = {};
            scenario.aid.type = {};
            scenario.aid.data = [];
        end
        N = length(scenario.aid.code);
        scenario.aid.code{N+1,1} = cod;
        scenario.aid.type{N+1,1} = typ;
        scenario.aid.data(N+1,:) = [lat lon alt psi];
        
    case 'wpt' % Waypoints
        if isempty(scenario.wpt) || isempty(scenario.wpt.data)
            nxtwpt = '1';
        else
            nxtwpt = num2str(max(scenario.wpt.data(:,1))+1);
        end
        out = inputvalues('Novo WPT',{'Número:','Código:','Latitude:','Longitude:','Elevação (ft):'},...
            {nxtwpt,'',deg2latlong(lat,1,3),deg2latlong(lon,2,3),'0'}); drawnow;
        if isempty(out)
            return
        end
        num = str2double(out{1});
        cod = out{2};
        [void, lat] = latlongread(out{3});
        [void, lon] = latlongread(out{4});
        alt = str2double(out{5});
        if num == 0 || ( num > 0 && ~rem(num,round(num)) )
            if isfield(scenario.wpt,'data') && any(num==scenario.wpt.data(:,1))
                beep; uiwait(errordlg(['Waypoint ' num2str(num) ' já cadastrado.'],'Erro','modal'));
                return
            end
        else
            beep; uiwait(errordlg('Número indicado incoerente.','Erro','modal'));
            return
        end
        if isempty(lat) || isempty(lon) || lat<-90 || lat>90 || lon<-180 || lon>180
            beep; uiwait(errordlg('Coordenadas incoerentes.','Erro','modal'));
            return
        end
        if isnan(alt) || alt<-2000 || alt>100000
            beep; uiwait(errordlg('Elevação incoerente.','Erro','modal'));
            return
        end
        if length(cod) > 12
            cod = cod(1:12);
            uiwait(warndlg('Código truncado em 12 caracteres.','Aviso','modal'));
        end
        if isempty(scenario.wpt)
            scenario.wpt.code = {};
            scenario.wpt.data = [];
        end
        N = length(scenario.wpt.code);
        scenario.wpt.code{N+1,1} = cod;
        scenario.wpt.data(N+1,:) = [num lat lon alt];
        
    case 'rt' % Routes
        beep;
        return
        
    case 'fa' % Flight Areas
        beep;
        return
        
    case 'avd' % Avoid Zones
        out = inputvalues('Nova Avd. Zone',{'Código:','Latitude:','Longitude:','Raio (NM):'},...
            {'',deg2latlong(lat,1,3),deg2latlong(lon,2,3),''}); drawnow;
        if isempty(out)
            return
        end
        cod = out{1};
        [void, lat] = latlongread(out{2});
        [void, lon] = latlongread(out{3});
        R = str2double(out{4});
        if isempty(lat) || isempty(lon) || lat<-90 || lat>90 || lon<-180 || lon>180
            beep; uiwait(errordlg('Coordenadas incoerentes.','Erro','modal'));
            return
        end
        if isnan(R) || R<=0 || R>300
            beep; uiwait(errordlg('Raio incoerente.','Erro','modal'));
            return
        end
        if length(cod) > 12
            cod = cod(1:12);
            uiwait(warndlg('Código truncado em 12 caracteres.','Aviso','modal'));
        end
        if isempty(scenario.avd)
            scenario.avd.code = {};
            scenario.avd.data = [];
        end
        N = length(scenario.avd.code);
        scenario.avd.code{N+1,1} = cod;
        scenario.avd.data(N+1,:) = [lat lon R];
        
    case 'thr' % Threat Areas
        out = inputvalues('Nova ameaça',...
            {'Código:','Latitude:','Longitude:','Altitude 1 (ft):','Raio 1 (NM):','Altitude 2 (ft):','Raio 2 (NM):'},...
            {'',deg2latlong(lat,1,3),deg2latlong(lon,2,3),'','','',''}); drawnow;
        if isempty(out)
            return
        end
        cod = out{1};
        [void, lat] = latlongread(out{2});
        [void, lon] = latlongread(out{3});
        Alt1 = str2double(out{4});
        R1   = str2double(out{5});
        Alt2 = str2double(out{6});
        R2   = str2double(out{7});
        if isempty(lat) || isempty(lon) || lat<-90 || lat>90 || lon<-180 || lon>180
            beep; uiwait(errordlg('Coordenadas incoerentes.','Erro','modal'));
            return
        end
        if isnan(Alt1) || isnan(Alt2) || Alt1<-2000 || Alt1>100000 || Alt2<-2000 || Alt2>100000
            beep; uiwait(errordlg('Altitude incoerente.','Erro','modal'));
            return
        end
        if Alt1 >= Alt2
            beep; uiwait(errordlg('Altitude 2 deve ser maior que Altitude 1.','Erro','modal'));
            return
        end
        if isnan(R1) || R1<0 || R1>300 || isnan(R2) || R2<0 || R2>300
            beep; uiwait(errordlg('Raio incoerente.','Erro','modal'));
            return
        end
        if length(cod) > 12
            cod = cod(1:12);
            uiwait(warndlg('Código truncado em 12 caracteres.','Aviso','modal'));
        end
        if isempty(scenario.thr)
            scenario.thr.code = {};
            scenario.thr.data = [];
        end
        N = length(scenario.thr.code);
        scenario.thr.code{N+1,1} = cod;
        scenario.thr.data(N+1,:) = [lat lon Alt1 Alt2 R1 R2];
        
    case 'cnt' % Contact Line
        beep;
        return
        
end

if ~isequalwithequalnans(scenario,oldscenario)
    handles.chg = 1;
    guidata(hObject, handles);
    
    setscenario(hObject, eventdata, handles, scenario, ntype);
    type_sel(hObject, eventdata, handles, N+1);
end

%--------------------------------------------------------------------------
function getparam(hObject, eventdata, handles, lat, lon)
% Acrescentar parametro a um objeto a partir do grafico

ntype = getappdata(handles.window,'ntype');
n = get(handles.obj_list,'Value');
scenario = getappdata(handles.window,'scenario');
oldscenario = scenario;

switch ntype
    case 'map' % Maps
        beep;
        return
        
    case 'aux' % Auxiliary Shapes
        if isempty(scenario.aux)
            beep;
            return
        end
        auxtype = scenario.aux(n).type;
        switch auxtype
            
            case 'point'
                out = inputvalues('Novo ponto',{'Latitude:','Longitude:','Código:'},...
                    {deg2latlong(lat,1,3),deg2latlong(lon,2,3),''}); drawnow;
                if isempty(out)
                    return
                end
                [void, lat] = latlongread(out{1});
                [void, lon] = latlongread(out{2});
                if isempty(lat) || isempty(lon) || lat<-90 || lat>90 || lon<-180 || lon>180
                    beep; uiwait(errordlg('Coordenadas incoerentes.','Erro','modal'));
                    return
                end
                cod = out{3};
                if length(cod) > 12
                    cod = cod(1:12);
                    uiwait(warndlg('Código truncado em 12 caracteres.','Aviso','modal'));
                end
                M = size(scenario.aux(n).data,1);
                scenario.aux(n).data(M+1,:) = [lat lon];
                scenario.aux(n).code{M+1,1} = cod;
                set(handles.getparam_btn,'Value',0);
                
            case {'line','area'}
                M = size(scenario.aux(n).data,1);
                scenario.aux(n).data(M+1,:) = [lat lon];
                
            case 'text'
                out = inputvalues('Novo texto',{'Latitude:','Longitude:','Texto:','Orientação (graus mag.):','Alinhamento:'},...
                    {deg2latlong(lat,1,3),deg2latlong(lon,2,3),'','',{'Esquerda','Centro','Direita',2}}); drawnow;
                if isempty(out)
                    return
                end
                [void, lat] = latlongread(out{1});
                [void, lon] = latlongread(out{2});
                if isempty(lat) || isempty(lon) || lat<-90 || lat>90 || lon<-180 || lon>180
                    beep; uiwait(errordlg('Coordenadas incoerentes.','Erro','modal'));
                    return
                end
                cod = out{3};
                rot = round(mod(str2double(out{4}),360));
                aln = out{5}-2;
                if isempty(cod)
                    beep; uiwait(errordlg('O texto não pode ser vazio.','Erro','modal'));
                    return
                end
                M = size(scenario.aux(n).data,1);
                scenario.aux(n).data(M+1,:) = [lat lon rot aln];
                scenario.aux(n).code{M+1,1} = cod;
                set(handles.getparam_btn,'Value',0);
        end
        
    case 'aid' % Nav Aids
        beep;
        return
        
    case 'wpt' % Waypoints
        beep;
        return
        
    case 'rt' % Routes
        if isempty(scenario.rt)
            beep;
            return
        end
        if (isempty(scenario.wpt) || isempty(scenario.wpt.data)) && (isempty(scenario.aid.data) || isempty(scenario.aid.data))
            beep;
            return
        end
        if isempty(scenario.wpt) || isempty(scenario.wpt.data)
            freewpt = [];
            freeaid = 1:size(scenario.aid.data,1);
        else
            freewpt = setdiff(scenario.wpt.data(:,1),scenario.rt(n).wpt);
            if isempty(scenario.aid) || isempty(scenario.aid.data)
                freeaid = [];
            else
                freeaid = [];
                Xwpt = scenario.wpt.data(:,3);
                Ywpt = scenario.wpt.data(:,2);
                if ~isempty(scenario.aid.data)
                    Xaid = scenario.aid.data(:,2);
                    Yaid = scenario.aid.data(:,1);
                    for na = 1:length(Xaid)
                        if all(sqrt((Xaid(na)-Xwpt).^2+(Yaid(na)-Ywpt).^2) >= 1/6000)
                            freeaid = [freeaid na];
                        end
                    end
                end
            end
        end
        if isempty(freewpt) && isempty(freeaid)
            beep;
            return
        end
        d = 8/460*diff(get(handles.TSD,'XLim'));
        ok = 0;
        for m = 1:length(freewpt)
            k = find(scenario.wpt.data(:,1)==freewpt(m));
            if abs(lat-scenario.wpt.data(k,2)) < d && abs(lon-scenario.wpt.data(k,3)) < d
                ok = 1;
                break
            end
        end
        if ~ok && ~isempty(freeaid)
            for m = 1:length(freeaid)
                k = freeaid(m);
                if abs(lat-scenario.aid.data(k,1)) < d && abs(lon-scenario.aid.data(k,2)) < d
                    ok = 2;
                    break
                end
            end
        end
        if ok == 1 % Wpt
            M = length(scenario.rt(n).wpt);
            scenario.rt(n).wpt(M+1) = freewpt(m);
        elseif ok == 2 % Aid
            if isempty(scenario.wpt) || isempty(scenario.wpt.data)
                scenario.wpt.data = [];
                scenario.wpt.code = {};
                wptnum = 1;
            else
                wptnum = max(scenario.wpt.data(:,1))+1;
            end
            scenario.wpt.data(end+1,:) = [wptnum scenario.aid.data(k,1:3)]; 
            scenario.wpt.code{end+1,1} = scenario.aid.code{k};
            M = length(scenario.rt(n).wpt);
            scenario.rt(n).wpt(M+1) = wptnum;
            ntype = {'aid','wpt','rt'};
        else
            beep;
            return
        end
        
    case 'fa' % Flight Areas
        if isempty(scenario.fa)
            beep;
            return
        end
        if ~isempty(scenario.fa(n).data)
            scenario.fa(n).data(end,:) = [];
        end
        scenario.fa(n).data(end+1,:) = [lat lon];
        scenario.fa(n).data(end+1,:) = scenario.fa(n).data(1,:);
        M = size(scenario.fa(n).data,1)-2;
        
    case 'avd' % Avoid Zones
        beep;
        return
        
    case 'thr' % Threat Areas
        beep;
        return
        
    case 'cnt' % Contact Line
        if isempty(scenario.cnt)
            button = questdlg('Deseja criar a linha de contato?','Confirmação','Sim','Não','Não');
            if strcmp(button,'Sim')
                scenario.cnt.data = [];
            else
                return
            end
        end
        M = size(scenario.cnt.data,1);
        scenario.cnt.data(M+1,:) = [lat lon];
        
end

if ~isequalwithequalnans(scenario,oldscenario)
    handles.chg = 1;
    guidata(hObject, handles);
    
    if istype(ntype,'aux')
        setscenario(hObject, eventdata, handles, scenario, ntype);
    elseif istype(ntype,'cnt') && ~M
        setscenario(hObject, eventdata, handles, scenario, ntype);
    elseif istype(ntype,'rt') && istype(ntype,'aid')
        setscenario(hObject, eventdata, handles, scenario, ntype);
    else
        updatescenario(hObject, eventdata, handles, scenario, ntype);
    end
    type_sel(hObject, eventdata, handles, n, M+1);
end

%--------------------------------------------------------------------------
function movepoint(hObject, eventdata, handles, lat, lon)
% Arrastar ponto no grafico

ntype = getappdata(handles.window,'ntype');
n     = get(handles.obj_list,'Value');
m     = get(handles.param_list,'Value');
scenario = getappdata(handles.window,'scenario');
oldscenario = scenario;

switch ntype
    case 'map' % Maps
        beep;
        return
        
    case 'aux' % Auxiliary Shapes
        switch size(scenario.aux(n).data(m,:),2)
            case 2
                scenario.aux(n).data(m,:) = [lat lon];
            case 3
                scenario.aux(n).data(m,:) = [lat lon scenario.aux(n).data(m,3)];
            case 4
                scenario.aux(n).data(m,:) = [lat lon scenario.aux(n).data(m,3:4)];
        end
        
    case 'aid' % Nav Aids
        scenario.aid.data(n,1:2) = [lat lon];
        
    case 'wpt' % Waypoints
        scenario.wpt.data(n,2:3) = [lat lon];
        
    case 'rt' % Routes
        k = find(scenario.rt(n).wpt(m)==scenario.wpt.data(:,1));
        scenario.wpt.data(k,2:3) = [lat lon];
        
    case 'fa' % Flight Areas
        scenario.fa(n).data(m,:) = [lat lon];
        if m == 1
            scenario.fa(n).data(end,:) = scenario.fa(n).data(1,:);
        end
        
    case 'avd' % Avoid Zones
        scenario.avd.data(n,1:2) = [lat lon];
        
    case 'thr' % Threat Areas
        scenario.thr.data(n,1:2) = [lat lon];
        
    case 'cnt' % Contact Line
        scenario.cnt.data(m,:) = [lat lon];
        
end

if ~isequalwithequalnans(scenario,oldscenario)
    handles.chg = 1;
    guidata(hObject, handles);
    
    updatescenario(hObject, eventdata, handles, scenario, ntype);
    type_sel(hObject, eventdata, handles, n, m);
    drawnow;
end

% --------------------------------------------------------------------
function str = spc(N,M)
% Cria coluna de espaços

if nargin == 1
    M = 1;
end

str = char(32*ones(N,M));

%--------------------------------------------------------------------------
function pos = denanpos(pos)
% Evita bug de "NaN" na propriedade "Position" dos textos

pos(isnan(pos)) = -10000;

% --------------------------------------------------------------------
function str = style2str(stl, opt)
% Obtem um texto com o estilo, cor ou espessura da linha/ponto

switch opt
    
    case 1 % Estilo
        
        styles = {'-',':','-.','--','.','o','d','s','^','p','A','T'};
        styles_str = {'Sólido','Pontilhado','Traço-ponto','Tracejado','Ponto','Círculo','Losango','Quadrado','Triângulo','Estrela','Área','Texto'};
        
        ns = strmatch(stl,styles,'exact');
        
        if isempty(ns)
            str = '?';
        else
            str = styles_str{ns};
        end
        
    case 2 % Cor
        
        colors = 'bgrcmyw';
        colors_str = {'Azul','Verde','Vermelho','Ciano','Magenta','Amarelo','Branco'};
        
        if length(stl) == 1
            nc = find(stl == colors);
            
            if isempty(nc)
                str = '?';
            else
                str = colors_str{nc};
            end
        else
            str = ['[' num2str(stl(1)) ' ' num2str(stl(2)) ' ' num2str(stl(3)) ']'];
            str = strrep(str,'0.','.');
        end
        
    case 3 % Espessura
        
        if isempty(stl)
            str = '?';
        else
            str = num2str(stl);
        end
        
end

% --------------------------------------------------------------------
function bringtofront(Haxis,hobj)
% Trazer objetos (hobj) para a camada superior do eixo (Haxis)

objlist = get(Haxis,'Children');

for n = 1:length(hobj)
    k = find(objlist==hobj(n));
    objlist(k) = [];
    objlist = [hobj(n); objlist];
end

set(Haxis,'Children',objlist);

% --------------------------------------------------------------------
function r = istype(ntype,x)
% Informa se os tipos selecionados em ntype correspondem aos tipos desejados em x

if ischar(ntype) && strcmp(ntype,'all')
    r = 1;
    return
end

if ischar(ntype) && ischar(x)
    r = strcmp(ntype,x);
    return
end

if ischar(ntype)
    ntype = cellstr(ntype);
end
if ischar(x)
    x = cellstr(x);
end

r = 0;
for n = 1:length(ntype)
    for m = 1:length(x)
        if strcmp(ntype{n},x{m});
            r = 1;
            return
        end
    end
end

% --------------------------------------------------------------------
function dr = fixlatlong(d,s)
% Arredonda para cima ou para baixo uma coordenada em graus na 3ª casa decimal dos minutos

if sign(s) >= 0
    dr =  ceil(d*60*1000)/60000;
else
    dr = floor(d*60*1000)/60000;
end

% --------------------------------------------------------------------
function rgb = char2rgb(c)
% Converte um caracter de cor em um trio RGB

if isnumeric(c)
    rgb = c;
    return
end

if length(c) == 1
    
    switch c
        case 'b'
            rgb = [0 0 1];
        case 'g'
            rgb = [0 1 0];
        case 'r'
            rgb = [1 0 0];
        case 'c'
            rgb = [0 1 1];
        case 'm'
            rgb = [1 0 1];
        case 'y'
            rgb = [1 1 0];
        case 'w'
            rgb = [1 1 1];
        otherwise
            rgb = [1 1 1];
    end
    
else
    rgb = str2num(c);
end
