function varargout = RDAT_EditCalibData(varargin)
% RDAT_EDITCALIBDATA M-file for RDAT_EditCalibData.fig
% Last Modified by GUIDE v2.5 29-Mar-2013 19:00:08

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RDAT_EditCalibData_OpeningFcn, ...
                   'gui_OutputFcn',  @RDAT_EditCalibData_OutputFcn, ...
                   'gui_LayoutFcn',  @RDAT_EditCalibData_LayoutFcn, ...
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
function h = RDAT_EditCalibData_LayoutFcn(varargin)
% Função de layout inicial

h = openfig('RDAT_EditCalibData.fig','reuse','invisible');

% -------------------------------------------------------------------
function RDAT_EditCalibData_OpeningFcn(hObject, eventdata, handles, varargin)
% Função de inicialização da janela

ss = get(0,'ScreenSize');
minscreensize = [1024 768]; % Tamanho mínimo da tela
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

bgc = getbuttoncolor(handles.window);
handles.icons.new     = geticon('DatButtons.mat','new'   ,bgc);
handles.icons.remove  = geticon('DatButtons.mat','remove',bgc);
handles.icons.rename  = geticon('DatButtons.mat','rename',bgc);
handles.icons.edit    = geticon('DatButtons.mat','check' ,bgc);
handles.icons.double  = geticon('DatButtons.mat','double',bgc);
handles.icons.save    = geticon('DatButtons.mat','save'  ,bgc);

handles.icons.new0    = geticon('DatButtons.mat','new'   ,bgc,0,0,0,1,.4);
handles.icons.remove0 = geticon('DatButtons.mat','remove',bgc,0,0,0,1,.2);
handles.icons.rename0 = geticon('DatButtons.mat','rename',bgc,0,0,0,1,.4);
handles.icons.edit0   = geticon('DatButtons.mat','check' ,bgc,0,0,0,1,.2);
handles.icons.double0 = geticon('DatButtons.mat','double',bgc,0,0,0,1,.4);
handles.icons.save0   = geticon('DatButtons.mat','save'  ,bgc,0,0,0,1,.3);

set(handles.help_btn,'CData',geticon('DatButtons.mat','help',bgc));

updatebuttons(hObject, eventdata, handles, 1);

ws = get(handles.window,'Position');
set(handles.window,'Position',[.5*(ss(3)-ws(3)) .5*(ss(4)-ws(4)) ws(3) ws(4)],'Visible','on');

bgc = get(handles.window,'Color');
axes(handles.poserrtypes);
image(flipud3(getbutton('poserrtypes.bmp',bgc)),'ButtonDownFcn','RDAT_EditCalibData(''poserrfcn'',gcbo,[],guidata(gcbo))');
set(handles.poserrtypes,'Xcolor',bgc,'Ycolor',bgc,'Zcolor',bgc)
axes(handles.velerrtypes);
image(flipud3(getbutton('velerrtypes.bmp',bgc)),'ButtonDownFcn','RDAT_EditCalibData(''velerrfcn'',gcbo,[],guidata(gcbo))');
set(handles.velerrtypes,'Xcolor',bgc,'Ycolor',bgc,'Zcolor',bgc)

handles.Oi  = [handles.dpsi handles.dtet handles.dphi handles.kL];
handles.pi  = [handles.p5 handles.p4 handles.p3 handles.p2 handles.p1 handles.p0];
handles.vi  = [handles.v5 handles.v4 handles.v3 handles.v2 handles.v1 handles.v0];
handles.Ai  = [handles.A3 handles.A2 handles.A1 handles.A0];
handles.Bi  = [handles.B3 handles.B2 handles.B1 handles.B0];
handles.CLi = [handles.CL3 handles.CL2 handles.CL1 handles.CL0];
handles.Ki  = [handles.K3 handles.K2 handles.K1 handles.K0];
handles.Cmd = [...
        handles.Ddm_min    handles.Ddl_min    handles.Ddn_min    handles.Pi1_min    handles.Pi2_min    ;...
        handles.Ddm_neutro handles.Ddl_neutro handles.Ddn_neutro handles.Pi1_neutro handles.Pi2_neutro ;...
        handles.Ddm_max    handles.Ddl_max    handles.Ddn_max    handles.Pi1_max    handles.Pi2_max    ;...
        handles.Ddm_k      handles.Ddl_k      handles.Ddn_k      handles.Pi1_k      handles.Pi2_k     ];
handles.p   = 12;
handles.ptypes = [handles.ptype1 handles.ptype2 handles.ptype3];
handles.vtypes = [handles.vtype1 handles.vtype2 handles.vtype3];

handles.toogleenable  = [handles.remarks handles.span handles.Sref handles.Ws handles.Oi handles.pi handles.vi handles.K handles.Ai ...
        handles.Bi handles.CLi handles.Ki handles.Cmd(:)'];
handles.toogledisable = [handles.acft_sel handles.date_sel handles.newacft_btn handles.removeacft_btn handles.editacft_btn ...
        handles.newcalib_btn handles.removecalib_btn handles.doublecalib_btn handles.save_btn handles.ok_btn handles.cancel_btn];
handles.toogledisablebtn = [handles.newacft_btn handles.removeacft_btn handles.editacft_btn ...
        handles.newcalib_btn handles.removecalib_btn handles.doublecalib_btn handles.save_btn];
set(handles.toogleenable,'Enable','off');

if ~exist('DatAcftDB.mat','file')
    set(handles.window,'Visible','off');
    beep; uiwait(errordlg('Base de dados não encontrada.','Erro','modal'));
    handles.ok = 0;
    guidata(hObject, handles);
    uiresume
    return
end

load(which('DatAcftDB.mat'),'acftdb');

% Conversão de base de dados ---------
acftdb = backcompat(acftdb,'acftdb');
%-------------------------------------

% Correção de posicionamento de texto para Windows 7
pos = get(handles.text30,'Position');
set(handles.text30,'String','[Nx Ny Nz]corr = k . L × [Nx Ny Nz]lido','Position',[pos(1) pos(2) 300 pos(4)]);
set([handles.text31 handles.text32],'Visible','off');
set(handles.deg1_txt,'Position',get(handles.deg1_txt,'Position')+[0 0 2 0]);
set(handles.deg2_txt,'Position',get(handles.deg2_txt,'Position')+[0 0 2 0]);
set(handles.deg3_txt,'Position',get(handles.deg3_txt,'Position')+[0 0 2 0]);

set([handles.ptype1 handles.vtype1],'Value',1);

handles.acftdb = acftdb;
handles.tempdata = [];
handles.ok = 0;
handles.chg = 0;
guidata(hObject, handles);

for n = 1:size(handles.acftdb,2);
    names{n} = [handles.acftdb(n).type ' ' handles.acftdb(n).tail];
end
    
set(handles.acft_sel,'String',names,'Value',1);
acft_sel_Callback(hObject, eventdata, handles);

uiwait(handles.window);

% -------------------------------------------------------------------
function varargout = RDAT_EditCalibData_OutputFcn(hObject, eventdata, handles)
% Função de saída da janela

if handles.ok
    varargout{1} = get(handles.acft_sel,'Value');
    varargout{2} = get(handles.date_sel,'Value');
else
    varargout{1} = [];
    varargout{2} = [];
end
delete(handles.window);

% -------------------------------------------------------------------
function acft_sel_Callback(hObject, eventdata, handles)
% Função executada ao se selecionar uma aeronave

[na, nc] = getnanc(handles);
set(handles.date_sel,'String',datetime2str([handles.acftdb(na).date]),'Value',size(handles.acftdb(na).date,1));
date_sel_Callback(hObject, eventdata, handles);

% -------------------------------------------------------------------
function date_sel_Callback(hObject, eventdata, handles)
% Função executada ao se selecionar uma calibração

[na, nc] = getnanc(handles);
[np, nv] = getnpnv(handles);

set(handles.span,'String',num2str(nan2empty(handles.acftdb(na).span),  handles.p));
set(handles.Sref,'String',num2str(nan2empty(handles.acftdb(na).Sref),  handles.p));
set(handles.Ws,  'String',num2str(nan2empty(handles.acftdb(na).Ws(nc)),handles.p));

set(handles.remarks,'String',handles.acftdb(na).remarks{nc});
for i = 1:4
    set(handles.Oi(i),'String',num2str(nan2empty(handles.acftdb(na).orto(nc,i)), handles.p));
end
set(handles.ptypes    ,'Value',0);
set(handles.ptypes(np),'Value',1);
set(handles.vtypes    ,'Value',0);
set(handles.vtypes(nv),'Value',1);
for i = 1:6
    set(handles.pi(i),'String',num2str(nan2empty(handles.acftdb(na).Dpb(nc,i,np)), handles.p));
    set(handles.vi(i),'String',num2str(nan2empty(handles.acftdb(na).Dqb(nc,i,nv)), handles.p));
end
if nv == 1
    set(handles.vi,'Enable','off');
end
set(handles.K,'String',num2str(nan2empty(handles.acftdb(na).K(nc)), handles.p));
for i = 1:4
    set(handles.Ai(i), 'String', num2str(nan2empty(handles.acftdb(na).alpha(nc,i)), handles.p));
    set(handles.Bi(i), 'String', num2str(nan2empty(handles.acftdb(na).beta(nc,i)),  handles.p));
    set(handles.CLi(i),'String', num2str(nan2empty(handles.acftdb(na).CL(nc,i)),    handles.p));
    set(handles.Ki(i), 'String', num2str(nan2empty(handles.acftdb(na).polar(nc,i)), handles.p));
end
for i = 1:4
    for j = 1:5
        set(handles.Cmd(i,j),'String',num2str(nan2empty(handles.acftdb(na).Cmd(i,j,nc)), handles.p));
    end
end

% -------------------------------------------------------------------
function newacft_btn_Callback(hObject, eventdata, handles)
% Criar nova aeronave

type = '';
tail = '';
while ischar(type) && isempty(type) || ischar(tail) && isempty(tail)
    [type, tail] = inputvalues('Nova Aeronave', {'Tipo:','Matrícula:'}, {type,tail});
end
if isempty(type)
    return
end

date = clock;
datestr = datetime2str(date(1:3));
ok = 0;
while ~ok
    datestr = inputvalue('Nova Calibração', 'dd/mm/aaaa:', datestr);
    if ~ischar(datestr) && isempty(datestr)
        ok = 1;
    elseif ~isempty(datestr)
        datestr2 = datestr;
        datestr2(datestr2=='/') = ' ';
        date_num = str2num(datestr2);
        if length(date_num) == 3
            date_num = fliplr(date_num);
            ok = 1;
        end
    end
end
if isempty(date)
    return
end

Na = size(handles.acftdb,2);
handles.tempdata = getacftdata(handles.acftdb,NaN);
handles.tempdata.type = type;
handles.tempdata.tail = tail;
handles.tempdata.date = date_num;
handles = setacftdata(handles,Na+1,1,handles.tempdata);

handles.chg = 1;
guidata(hObject, handles);

for n = 1:size(handles.acftdb,2);
    names{n} = [handles.acftdb(n).type ' ' handles.acftdb(n).tail];
end
set(handles.acft_sel,'String',names,'Value',Na+1);
acft_sel_Callback(hObject, eventdata, handles);

set(handles.editcalib_btn,'Value',1);
set(handles.toogleenable, 'Enable','on');
set(handles.toogledisable,'Enable','off');
updatebuttons(hObject, eventdata, handles, 0);

% -------------------------------------------------------------------
function removeacft_btn_Callback(hObject, eventdata, handles)
% Remover aeronave selecionada

[na, nc] = getnanc(handles);

button = questdlg({['Deseja remover a aeronave ' handles.acftdb(na).type ' ' handles.acftdb(na).tail ],...
        'e todas as suas calibrações?'},'Confirmação','Sim','Não','Não'); drawnow;
if strcmp(button,'Sim')
    
    Na = size(handles.acftdb,2);
    if Na == 1
        beep; uiwait(errordlg({'Não é possível remover a aeronave selecionada.',...
                'Deve haver pelo menos uma aeronave na base de dados.'},'Erro','modal'));
        return
    end
    
    handles.acftdb(na) = [];
    
    handles.chg = 1;
    guidata(hObject, handles);
    
    for n = 1:Na-1;
        names{n} = [handles.acftdb(n).type ' ' handles.acftdb(n).tail];
    end
    
    set(handles.acft_sel,'String',names,'Value',min(na,Na-1));
    acft_sel_Callback(hObject, eventdata, handles);    
    uiwait(okdlg('Aeronave removida com sucesso.','Aviso','modal'));
end

% -------------------------------------------------------------------
function editacft_btn_Callback(hObject, eventdata, handles)
% Editar nome da aeronave selecionada

[na, nc] = getnanc(handles);

[type, tail] = inputvalues('Editar Aeronave',{'Tipo:','Matrícula:'},{handles.acftdb(na).type, handles.acftdb(na).tail});
while ischar(type) && isempty(type) || ischar(tail) && isempty(tail)
    [type, tail] = inputvalues('Editar Aeronave',{'Tipo:','Matrícula:'},{type,tail});
end
if isempty(type)
    return
end

handles.acftdb(na).type = type;
handles.acftdb(na).tail = tail;

handles.chg = 1;
guidata(hObject, handles);

for n = 1:size(handles.acftdb,2);
    names{n} = [handles.acftdb(n).type ' ' handles.acftdb(n).tail];
end
set(handles.acft_sel,'String',names);

% -------------------------------------------------------------------
function newcalib_btn_Callback(hObject, eventdata, handles)
% Criar nova calibração

[na, nc] = getnanc(handles);
[np, nv] = getnpnv(handles);

button = questdlg({'Deseja acrescentar nova calibração',...
        ['para a aeronave ' handles.acftdb(na).type ' ' handles.acftdb(na).tail ' ?']},'Confirmação','Sim','Não','Não'); drawnow;
if strcmp(button,'Sim')
    
    date = clock;
    datestr = datetime2str(date(1:3));
    ok = 0;
    while ~ok
        datestr = inputvalue('Nova Calibração', 'dd/mm/aaaa:', datestr);
        if ~ischar(datestr) && isempty(datestr)
            ok = 1;
        elseif ~isempty(datestr)
            datestr2 = datestr;
            datestr2(datestr2=='/') = ' ';
            date_num = str2num(datestr2);
            if length(date_num) == 3
                date_num = fliplr(date_num);
                ok = 1;
            end
        end
    end
    if isempty(datestr)
        return
    end
    
    Nc = size(handles.acftdb(na).date,1);
    handles.tempdata = getacftdata(handles.acftdb,NaN);
    handles.tempdata.type = handles.acftdb(na).type;
    handles.tempdata.tail = handles.acftdb(na).tail;
    handles.tempdata.span = handles.acftdb(na).span;
    handles.tempdata.Sref = handles.acftdb(na).Sref;
    handles.tempdata.date = date_num;
    handles = setacftdata(handles,na,Nc+1,handles.tempdata);
    
    handles.chg = 1;
    guidata(hObject, handles);
    
    acft_sel_Callback(hObject, eventdata, handles);
    
    set(handles.editcalib_btn,'Value',1);
    set(handles.toogleenable, 'Enable','on');
    set(handles.toogledisable,'Enable','off');
    set(handles.toogledisablebtn,'Enable','inactive');
    updatebuttons(hObject, eventdata, handles, 0);
    if nv == 1
        set(handles.vi,'Enable','off');
    end
end

% -------------------------------------------------------------------
function removecalib_btn_Callback(hObject, eventdata, handles)
% Remover calibração selecionada

[na, nc] = getnanc(handles);

button = questdlg({['Deseja remover a calibração de ', datetime2str(handles.acftdb(na).date(nc,:))] ,...
            ['da aeronave ' handles.acftdb(na).type ' ' handles.acftdb(na).tail , ' ?']},'Confirmação','Sim','Não','Não'); drawnow;
if strcmp(button,'Sim')
    Nc = size(handles.acftdb(na).date,1);
    if Nc == 1
        beep; uiwait(errordlg({'Não é possível remover a calibração selecionada.',...
                'Deve haver pelo menos uma calibração por aeronave.'},'Erro','modal'));
        return
    end
    
    handles.acftdb(na).date(nc,:)  = [];
    handles.acftdb(na).remarks(nc) = [];
    handles.acftdb(na).Ws(nc)      = [];
    handles.acftdb(na).orto(nc,:)  = [];
    handles.acftdb(na).Dpb(nc,:,:) = [];
    handles.acftdb(na).Dqb(nc,:,:) = [];
    handles.acftdb(na).K(nc)       = [];
    handles.acftdb(na).alpha(nc,:) = [];
    handles.acftdb(na).beta(nc,:)  = [];
    handles.acftdb(na).CL(nc,:)    = [];
    handles.acftdb(na).polar(nc,:) = [];
    handles.acftdb(na).Cmd(:,:,nc) = [];

    handles.chg = 1;
    guidata(hObject, handles);
    
    set(handles.date_sel,'String',datetime2str([handles.acftdb(na).date]),'Value',min(nc,Nc-1));
    date_sel_Callback(hObject, eventdata, handles);
    uiwait(okdlg('Calibração removida com sucesso.','Aviso','modal'));
end

% -------------------------------------------------------------------
function doublecalib_btn_Callback(hObject, eventdata, handles)
% Duplicar calibração selecionada

[na, nc] = getnanc(handles);
[np, nv] = getnpnv(handles);

button = questdlg({['Deseja duplicar a calibração de ', datetime2str(handles.acftdb(na).date(nc,:))] ,...
            ['da aeronave ' handles.acftdb(na).type ' ' handles.acftdb(na).tail , ' ?']},'Confirmação','Sim','Não','Não'); drawnow;
if strcmp(button,'Sim')
    
    date = clock;
    datestr = datetime2str(date(1:3));
    ok = 0;
    while ~ok
        datestr = inputvalue('Nova Calibração', 'dd/mm/aaaa:', datestr);
        if ~ischar(datestr) && isempty(datestr)
            ok = 1;
        elseif ~isempty(datestr)
            datestr2 = datestr;
            datestr2(datestr2=='/') = ' ';
            date_num = str2num(datestr2);
            if length(date_num) == 3
                date_num = fliplr(date_num);
                ok = 1;
            end
        end
    end
    if isempty(datestr)
        return
    end
    
    Nc = size(handles.acftdb(na).date,1);
    handles.tempdata = getacftdata(handles.acftdb,na,nc);
    handles.tempdata.date = date_num;
    handles = setacftdata(handles,na,Nc+1,handles.tempdata);
    
    handles.chg = 1;
    guidata(hObject, handles);
    
    acft_sel_Callback(hObject, eventdata, handles);
    
    set(handles.editcalib_btn,'Value',1);
    set(handles.toogleenable, 'Enable','on');
    set(handles.toogledisable,'Enable','off');
    set(handles.toogledisablebtn,'Enable','inactive');
    updatebuttons(hObject, eventdata, handles, 0);
    if nv == 1
        set(handles.vi,'Enable','off');
    end
end

% -------------------------------------------------------------------
function editcalib_btn_Callback(hObject, eventdata, handles)
% Editar calibração selecionada

[na, nc] = getnanc(handles);
[np, nv] = getnpnv(handles);

pause(.2);
if get(handles.editcalib_btn,'Value')
    button = questdlg({'Deseja editar a calibração de ',[ datetime2str(handles.acftdb(na).date(nc,:)) ,...
            ' da aeronave ' handles.acftdb(na).type ' ' handles.acftdb(na).tail , ' ?']},'Confirmação','Sim','Não','Não'); drawnow;
    if strcmp(button,'Sim')
        set(handles.toogleenable, 'Enable','on');
        set(handles.toogledisable,'Enable','off');
        set(handles.toogledisablebtn,'Enable','inactive');
        updatebuttons(hObject, eventdata, handles, 0);
        if nv == 1
            set(handles.vi,'Enable','off');
        end
        handles.tempdata = getacftdata(handles.acftdb,na,nc);
        guidata(hObject, handles);
    else
        set(handles.editcalib_btn,'Value',0);
    end
else
    if ~isequalwithequalnans(handles.tempdata,getacftdata(handles.acftdb,na,nc))
        button = questdlg({'Deseja confirmar alterações na calibração de ',[ datetime2str(handles.acftdb(na).date(nc,:)) ,...
                    ' da aeronave ' handles.acftdb(na).type ' ' handles.acftdb(na).tail , ' ?']},'Confirmação','Sim','Não','Cancelar','Não'); drawnow;
        if strcmp(button,'Sim')
            handles = setacftdata(handles,na,nc,handles.tempdata);
            handles.tempdata = [];
            handles.chg = 1;
            guidata(hObject, handles);
            pause(.2);
            uiwait(okdlg('Alterações realizadas com sucesso.','Aviso','modal'));
        elseif strcmp(button,'Não')
            date_sel_Callback(hObject, eventdata, handles);
            pause(.2);
            uiwait(warndlg('Alterações canceladas.','Aviso','modal'));
        else
            set(handles.editcalib_btn,'Value',1);
            return
        end
    end
    set(handles.toogleenable, 'Enable','off');
    set(handles.toogledisable,'Enable','on');
    updatebuttons(hObject, eventdata, handles, 1);
end

% -------------------------------------------------------------------
% FUNÇÕES DE EDIÇÃO DOS CAMPOS DE DADOS
% -------------------------------------------------------------------

function remarks_Callback(hObject, eventdata, handles)
handles.tempdata.remarks = cellstr(get(gcbo,'String'));
guidata(hObject, handles);

% -------------------------------------------------------------------
function span_Callback(hObject, eventdata, handles)
strfix(gcbo,'',0);
span = str2double(get(gcbo,'String'));

if ~isequal(span,handles.tempdata.span);
    
    [na, nc] = getnanc(handles);
    button = questdlg({['Deseja alterar a envergadura da aeronave ' handles.acftdb(na).type ' ' handles.acftdb(na).tail '?'],...
            'Todas as calibrações serão afetadas.'},'Confirmação','Sim','Não','Sim'); drawnow;
    
    if strcmp(button,'Sim')
        handles.tempdata.span = span;
        guidata(hObject, handles);
    else
        set(gcbo,'String',num2str(handles.tempdata.span));
    end
end

% -------------------------------------------------------------------
function Sref_Callback(hObject, eventdata, handles)
strfix(gcbo,'',0);
Sref = str2double(get(gcbo,'String'));

if ~isequal(Sref,handles.tempdata.Sref);
    
    [na, nc] = getnanc(handles);
    button = questdlg({['Deseja alterar a área de referência da aeronave ' handles.acftdb(na).type ' ' handles.acftdb(na).tail '?'],...
            'Todas as calibrações serão afetadas.'},'Confirmação','Sim','Não','Sim'); drawnow;
    
    if strcmp(button,'Sim')
        handles.tempdata.Sref = Sref;
        guidata(hObject, handles);
    else
        set(gcbo,'String',num2str(handles.tempdata.Sref));
    end
end

% -------------------------------------------------------------------
function Ws_Callback(hObject, eventdata, handles)
strfix(gcbo,'',1);
handles.tempdata.Ws = str2double(get(gcbo,'String'));
guidata(hObject, handles);

% -------------------------------------------------------------------
function dpsi_Callback(hObject, eventdata, handles)
strfix(gcbo,0,-180,180);
handles.tempdata.orto(1) = str2double(get(gcbo,'String'));
guidata(hObject, handles);
% -------------------------------------------------------------------
function dtet_Callback(hObject, eventdata, handles)
strfix(gcbo,0,-90,90);
handles.tempdata.orto(2) = str2double(get(gcbo,'String'));
guidata(hObject, handles);
% -------------------------------------------------------------------
function dphi_Callback(hObject, eventdata, handles)
strfix(gcbo,0,-180,180);
handles.tempdata.orto(3) = str2double(get(gcbo,'String'));
guidata(hObject, handles);
% -------------------------------------------------------------------
function kL_Callback(hObject, eventdata, handles)
strfix(gcbo,1);
handles.tempdata.orto(4) = str2double(get(gcbo,'String'));
guidata(hObject, handles);

% -------------------------------------------------------------------
function ptype1_Callback(hObject, eventdata, handles)
set(handles.ptypes(1),'Value',1);
set(handles.ptypes([2 3]),'Value',0);
if get(handles.editcalib_btn,'Value')
    Dpb = handles.tempdata.Dpb;
else
    [na, nc] = getnanc(handles);
    Dpb = handles.acftdb(na).Dpb(nc,:,:);
end
for i = 1:6
    set(handles.pi(i),'String',num2str(nan2empty(Dpb(1,i,1)), handles.p));
end

% -------------------------------------------------------------------
function ptype2_Callback(hObject, eventdata, handles)
set(handles.ptypes(2),'Value',1);
set(handles.ptypes([1 3]),'Value',0);
if get(handles.editcalib_btn,'Value')
    Dpb = handles.tempdata.Dpb;
else
    [na, nc] = getnanc(handles);
    Dpb = handles.acftdb(na).Dpb(nc,:,:);
end
for i = 1:6
    set(handles.pi(i),'String',num2str(nan2empty(Dpb(1,i,2)), handles.p));
end

% -------------------------------------------------------------------
function ptype3_Callback(hObject, eventdata, handles)
set(handles.ptypes(3),'Value',1);
set(handles.ptypes([1 2]),'Value',0);
if get(handles.editcalib_btn,'Value')
    Dpb = handles.tempdata.Dpb;
else
    [na, nc] = getnanc(handles);
    Dpb = handles.acftdb(na).Dpb(nc,:,:);
end
for i = 1:6
    set(handles.pi(i),'String',num2str(nan2empty(Dpb(1,i,3)), handles.p));
end

% -------------------------------------------------------------------
function poserrfcn(hObject, eventdata, handles)
cp = get(handles.poserrtypes,'CurrentPoint');
x = cp(1);
if x < 111
    ptype1_Callback(hObject, eventdata, handles)
elseif x < 219
    ptype2_Callback(hObject, eventdata, handles)
else
    ptype3_Callback(hObject, eventdata, handles)
end

% -------------------------------------------------------------------
function velerrfcn(hObject, eventdata, handles)
cp = get(handles.velerrtypes,'CurrentPoint');
x = cp(1);
if x < 88
    vtype1_Callback(hObject, eventdata, handles)
elseif x < 193
    vtype2_Callback(hObject, eventdata, handles)
else
    vtype3_Callback(hObject, eventdata, handles)
end

% -------------------------------------------------------------------
function p5_Callback(hObject, eventdata, handles)
strfix(gcbo,0);
[np, nv] = getnpnv(handles);
handles.tempdata.Dpb(1,1,np) = str2double(get(gcbo,'String'));
guidata(hObject, handles);
% -------------------------------------------------------------------
function p4_Callback(hObject, eventdata, handles)
strfix(gcbo,0);
[np, nv] = getnpnv(handles);
handles.tempdata.Dpb(1,2,np) = str2double(get(gcbo,'String'));
guidata(hObject, handles);
% -------------------------------------------------------------------
function p3_Callback(hObject, eventdata, handles)
strfix(gcbo,0);
[np, nv] = getnpnv(handles);
handles.tempdata.Dpb(1,3,np) = str2double(get(gcbo,'String'));
guidata(hObject, handles);
% -------------------------------------------------------------------
function p2_Callback(hObject, eventdata, handles)
strfix(gcbo,0);
[np, nv] = getnpnv(handles);
handles.tempdata.Dpb(1,4,np) = str2double(get(gcbo,'String'));
guidata(hObject, handles);
% -------------------------------------------------------------------
function p1_Callback(hObject, eventdata, handles)
strfix(gcbo,0);
[np, nv] = getnpnv(handles);
handles.tempdata.Dpb(1,5,np) = str2double(get(gcbo,'String'));
guidata(hObject, handles);
% -------------------------------------------------------------------
function p0_Callback(hObject, eventdata, handles)
strfix(gcbo,0);
[np, nv] = getnpnv(handles);
handles.tempdata.Dpb(1,6,np) = str2double(get(gcbo,'String'));
guidata(hObject, handles);

% -------------------------------------------------------------------
function vtype1_Callback(hObject, eventdata, handles)
set(handles.vtypes(1),'Value',1);
set(handles.vtypes([2 3]),'Value',0);
set(handles.vi,'String','','Enable','off');

% -------------------------------------------------------------------
function vtype2_Callback(hObject, eventdata, handles)
set(handles.vtypes(2),'Value',1);
set(handles.vtypes([1 3]),'Value',0);
if get(handles.editcalib_btn,'Value')
    set(handles.vi,'Enable','on');
end
if get(handles.editcalib_btn,'Value')
    Dqb = handles.tempdata.Dqb;
else
    [na, nc] = getnanc(handles);
    Dqb = handles.acftdb(na).Dqb(nc,:,:);
end
for i = 1:6
    set(handles.vi(i),'String',num2str(nan2empty(Dqb(1,i,2)), handles.p));
end

% -------------------------------------------------------------------
function vtype3_Callback(hObject, eventdata, handles)
set(handles.vtypes(3),'Value',1);
set(handles.vtypes([1 2]),'Value',0);
if get(handles.editcalib_btn,'Value')
    set(handles.vi,'Enable','on');
end
if get(handles.editcalib_btn,'Value')
    Dqb = handles.tempdata.Dqb;
else
    [na, nc] = getnanc(handles);
    Dqb = handles.acftdb(na).Dqb(nc,:,:);
end
for i = 1:6
    set(handles.vi(i),'String',num2str(nan2empty(Dqb(1,i,3)), handles.p));
end

% -------------------------------------------------------------------
function v5_Callback(hObject, eventdata, handles)
strfix(gcbo,0);
[np, nv] = getnpnv(handles);
handles.tempdata.Dqb(1,1,nv) = str2double(get(gcbo,'String'));
guidata(hObject, handles);
% -------------------------------------------------------------------
function v4_Callback(hObject, eventdata, handles)
strfix(gcbo,0);
[np, nv] = getnpnv(handles);
handles.tempdata.Dqb(1,2,nv) = str2double(get(gcbo,'String'));
guidata(hObject, handles);
% -------------------------------------------------------------------
function v3_Callback(hObject, eventdata, handles)
strfix(gcbo,0);
[np, nv] = getnpnv(handles);
handles.tempdata.Dqb(1,3,nv) = str2double(get(gcbo,'String'));
guidata(hObject, handles);
% -------------------------------------------------------------------
function v2_Callback(hObject, eventdata, handles)
strfix(gcbo,0);
[np, nv] = getnpnv(handles);
handles.tempdata.Dqb(1,4,nv) = str2double(get(gcbo,'String'));
guidata(hObject, handles);
% -------------------------------------------------------------------
function v1_Callback(hObject, eventdata, handles)
strfix(gcbo,0);
[np, nv] = getnpnv(handles);
handles.tempdata.Dqb(1,5,nv) = str2double(get(gcbo,'String'));
guidata(hObject, handles);
% -------------------------------------------------------------------
function v0_Callback(hObject, eventdata, handles)
strfix(gcbo,0);
[np, nv] = getnpnv(handles);
handles.tempdata.Dqb(1,6,nv) = str2double(get(gcbo,'String'));
guidata(hObject, handles);

% -------------------------------------------------------------------
function K_Callback(hObject, eventdata, handles)
strfix(gcbo,1);
handles.tempdata.K = str2double(get(gcbo,'String'));
guidata(hObject, handles);

% -------------------------------------------------------------------
function A3_Callback(hObject, eventdata, handles)
strfix(gcbo,0);
handles.tempdata.alpha(1) = str2double(get(gcbo,'String'));
guidata(hObject, handles);
% -------------------------------------------------------------------
function A2_Callback(hObject, eventdata, handles)
strfix(gcbo,0);
handles.tempdata.alpha(2) = str2double(get(gcbo,'String'));
guidata(hObject, handles);
% -------------------------------------------------------------------
function A1_Callback(hObject, eventdata, handles)
strfix(gcbo,1);
handles.tempdata.alpha(3) = str2double(get(gcbo,'String'));
guidata(hObject, handles);
% -------------------------------------------------------------------
function A0_Callback(hObject, eventdata, handles)
strfix(gcbo,0);
handles.tempdata.alpha(4) = str2double(get(gcbo,'String'));
guidata(hObject, handles);

% -------------------------------------------------------------------
function B3_Callback(hObject, eventdata, handles)
strfix(gcbo,0);
handles.tempdata.beta(1) = str2double(get(gcbo,'String'));
guidata(hObject, handles);
% -------------------------------------------------------------------
function B2_Callback(hObject, eventdata, handles)
strfix(gcbo,0);
handles.tempdata.beta(2) = str2double(get(gcbo,'String'));
guidata(hObject, handles);
% -------------------------------------------------------------------
function B1_Callback(hObject, eventdata, handles)
strfix(gcbo,1);
handles.tempdata.beta(3) = str2double(get(gcbo,'String'));
guidata(hObject, handles);
% -------------------------------------------------------------------
function B0_Callback(hObject, eventdata, handles)
strfix(gcbo,0);
handles.tempdata.beta(4) = str2double(get(gcbo,'String'));
guidata(hObject, handles);

% -------------------------------------------------------------------
function CL3_Callback(hObject, eventdata, handles)
strfix(gcbo);
handles.tempdata.CL(1) = str2double(get(gcbo,'String'));
guidata(hObject, handles);
% -------------------------------------------------------------------
function CL2_Callback(hObject, eventdata, handles)
strfix(gcbo);
handles.tempdata.CL(2) = str2double(get(gcbo,'String'));
guidata(hObject, handles);
% -------------------------------------------------------------------
function CL1_Callback(hObject, eventdata, handles)
strfix(gcbo);
handles.tempdata.CL(3) = str2double(get(gcbo,'String'));
guidata(hObject, handles);
% -------------------------------------------------------------------
function CL0_Callback(hObject, eventdata, handles)
strfix(gcbo);
handles.tempdata.CL(4) = str2double(get(gcbo,'String'));
guidata(hObject, handles);

% -------------------------------------------------------------------
function K3_Callback(hObject, eventdata, handles)
strfix(gcbo);
handles.tempdata.polar(1) = str2double(get(gcbo,'String'));
guidata(hObject, handles);
% -------------------------------------------------------------------
function K2_Callback(hObject, eventdata, handles)
strfix(gcbo);
handles.tempdata.polar(2) = str2double(get(gcbo,'String'));
guidata(hObject, handles);
% -------------------------------------------------------------------
function K1_Callback(hObject, eventdata, handles)
strfix(gcbo);
handles.tempdata.polar(3) = str2double(get(gcbo,'String'));
guidata(hObject, handles);
% -------------------------------------------------------------------
function K0_Callback(hObject, eventdata, handles)
strfix(gcbo);
handles.tempdata.polar(4) = str2double(get(gcbo,'String'));
guidata(hObject, handles);

% -------------------------------------------------------------------
function Ddm_min_Callback(hObject, eventdata, handles)
strfix(gcbo,0);
handles.tempdata.Cmd(1,1) = str2double(get(gcbo,'String'));
guidata(hObject, handles);
% -------------------------------------------------------------------
function Ddm_neutro_Callback(hObject, eventdata, handles)
strfix(gcbo,0);
handles.tempdata.Cmd(2,1) = str2double(get(gcbo,'String'));
guidata(hObject, handles);
% -------------------------------------------------------------------
function Ddm_max_Callback(hObject, eventdata, handles)
strfix(gcbo,0);
handles.tempdata.Cmd(3,1) = str2double(get(gcbo,'String'));
guidata(hObject, handles);
% -------------------------------------------------------------------
function Ddm_k_Callback(hObject, eventdata, handles)
strfix(gcbo,100);
handles.tempdata.Cmd(4,1) = str2double(get(gcbo,'String'));
guidata(hObject, handles);
% -------------------------------------------------------------------
function Ddl_min_Callback(hObject, eventdata, handles)
strfix(gcbo,0);
handles.tempdata.Cmd(1,2) = str2double(get(gcbo,'String'));
guidata(hObject, handles);
% -------------------------------------------------------------------
function Ddl_neutro_Callback(hObject, eventdata, handles)
strfix(gcbo,0);
handles.tempdata.Cmd(2,2) = str2double(get(gcbo,'String'));
guidata(hObject, handles);
% -------------------------------------------------------------------
function Ddl_max_Callback(hObject, eventdata, handles)
strfix(gcbo,0);
handles.tempdata.Cmd(3,2) = str2double(get(gcbo,'String'));
guidata(hObject, handles);
% -------------------------------------------------------------------
function Ddl_k_Callback(hObject, eventdata, handles)
strfix(gcbo,100);
handles.tempdata.Cmd(4,2) = str2double(get(gcbo,'String'));
guidata(hObject, handles);
% -------------------------------------------------------------------
function Ddn_min_Callback(hObject, eventdata, handles)
strfix(gcbo,0);
handles.tempdata.Cmd(1,3) = str2double(get(gcbo,'String'));
guidata(hObject, handles);
% -------------------------------------------------------------------
function Ddn_neutro_Callback(hObject, eventdata, handles)
strfix(gcbo,0);
handles.tempdata.Cmd(2,3) = str2double(get(gcbo,'String'));
guidata(hObject, handles);
% -------------------------------------------------------------------
function Ddn_max_Callback(hObject, eventdata, handles)
strfix(gcbo,0);
handles.tempdata.Cmd(3,3) = str2double(get(gcbo,'String'));
guidata(hObject, handles);
% -------------------------------------------------------------------
function Ddn_k_Callback(hObject, eventdata, handles)
strfix(gcbo,100);
handles.tempdata.Cmd(4,3) = str2double(get(gcbo,'String'));
guidata(hObject, handles);

% -------------------------------------------------------------------
function Pi1_min_Callback(hObject, eventdata, handles)
strfix(gcbo,0);
handles.tempdata.Cmd(1,4) = str2double(get(gcbo,'String'));
guidata(hObject, handles);
% -------------------------------------------------------------------
function Pi1_neutro_Callback(hObject, eventdata, handles)
strfix(gcbo,0);
handles.tempdata.Cmd(2,4) = str2double(get(gcbo,'String'));
guidata(hObject, handles);
% -------------------------------------------------------------------
function Pi1_max_Callback(hObject, eventdata, handles)
strfix(gcbo,0);
handles.tempdata.Cmd(3,4) = str2double(get(gcbo,'String'));
guidata(hObject, handles);
% -------------------------------------------------------------------
function Pi1_k_Callback(hObject, eventdata, handles)
strfix(gcbo,100);
handles.tempdata.Cmd(4,4) = str2double(get(gcbo,'String'));
guidata(hObject, handles);
% -------------------------------------------------------------------
function Pi2_min_Callback(hObject, eventdata, handles)
strfix(gcbo,0);
handles.tempdata.Cmd(1,5) = str2double(get(gcbo,'String'));
guidata(hObject, handles);
% -------------------------------------------------------------------
function Pi2_neutro_Callback(hObject, eventdata, handles)
strfix(gcbo,0);
handles.tempdata.Cmd(2,5) = str2double(get(gcbo,'String'));
guidata(hObject, handles);
% -------------------------------------------------------------------
function Pi2_max_Callback(hObject, eventdata, handles)
strfix(gcbo,0);
handles.tempdata.Cmd(3,5) = str2double(get(gcbo,'String'));
guidata(hObject, handles);
% -------------------------------------------------------------------
function Pi2_k_Callback(hObject, eventdata, handles)
strfix(gcbo,100);
handles.tempdata.Cmd(4,5) = str2double(get(gcbo,'String'));
guidata(hObject, handles);

% -------------------------------------------------------------------
function save_btn_Callback(hObject, eventdata, handles)
% Salvar base de dados

button = savedlg('Deseja salvar a base de dados de calibrações?','Confirmação','Sim','Não','Sim'); drawnow;
if strcmp(button,'Sim')
    set(handles.window,'Pointer','watch');
    acftdb = sortdb(handles.acftdb);
    save(which('DatAcftDB.mat'),'acftdb','-v7');
    handles.chg = 0;
    guidata(hObject, handles);
    set(handles.window,'Pointer','arrow');
    pause(.2);
    uiwait(okdlg('Base de dados salva com sucesso.','Aviso','modal'));
end

% -------------------------------------------------------------------
function help_btn_Callback(hObject, eventdata, handles)
% Botão Ajuda

helpme('Ferramentas\editorcalib');

% -------------------------------------------------------------------
function ok_btn_Callback(hObject, eventdata, handles)
% Botão OK

if handles.chg
    button = savedlg({'A base de dados de calibrações foi alterada.',...
            'Deseja salvar alterações?'},'Confirmação','Sim','Não','Sim'); drawnow;
    if strcmp(button,'Sim')
        set(handles.window,'Pointer','watch');
        acftdb = sortdb(handles.acftdb);
        save(which('DatAcftDB.mat'),'acftdb','-v7');
        handles.ok = 1;
        guidata(hObject, handles);
        set(handles.window,'Pointer','arrow');
        uiresume;
    end
else
    button = questdlg('Deseja sair?','Confirmação','Sim','Não','Não'); drawnow;
    if strcmp(button,'Sim')
        handles.ok = 1;
        guidata(hObject, handles);
        uiresume;
    end
end

% -------------------------------------------------------------------
function cancel_btn_Callback(hObject, eventdata, handles)
% Botão Cancelar

if handles.chg
    button = questdlg({'A base de dados de calibrações foi alterada.',...
            'Deseja sair sem salvar alterações?'},'Confirmação','Sim','Não','Sim'); drawnow;
    if strcmp(button,'Sim')
        uiresume;
    end
else
    button = questdlg('Deseja sair?','Confirmação','Sim','Não','Não'); drawnow;
    if strcmp(button,'Sim')
        uiresume;
    end
end

% -------------------------------------------------------------------
function window_CloseRequestFcn(hObject, eventdata, handles)
% Função de fechamento da janela

if get(handles.editcalib_btn,'Value')
    uiwait(warndlg('Para fechar a janela, é necessário sair do modo de edição.','Aviso','modal'));
else
    cancel_btn_Callback(hObject, eventdata, handles);
end

% -------------------------------------------------------------------
function window_KeyPressFcn(hObject, eventdata, handles)
% Acionamento de tecla do teclado

cc = get(handles.window,'CurrentCharacter');

if isempty(cc)
    return
end

switch abs(cc)
    
    case 13 % Enter
        if strcmp(get(handles.ok_btn,'Enable'),'on')
            ok_btn_Callback(hObject, eventdata, handles);
        end
        
    case 27 % Esc
        if strcmp(get(handles.cancel_btn,'Enable'),'on')
            cancel_btn_Callback(hObject, eventdata, handles);
        end
        
    case {abs('s'),abs('S')}
        if strcmp(get(handles.save_btn,'Enable'),'on')
            save_btn_Callback(hObject, eventdata, handles);
        end
        
    case abs('N')
        if strcmp(get(handles.newacft_btn,'Enable'),'on')
            newacft_btn_Callback(hObject, eventdata, handles);
        end
        
    case abs('n') 
        if strcmp(get(handles.newcalib_btn,'Enable'),'on')
            newcalib_btn_Callback(hObject, eventdata, handles);
        end
        
    case abs('R')
        if strcmp(get(handles.removeacft_btn,'Enable'),'on')
            removeacft_btn_Callback(hObject, eventdata, handles);
        end
        
    case abs('r') 
        if strcmp(get(handles.removecalib_btn,'Enable'),'on')
            removecalib_btn_Callback(hObject, eventdata, handles);
        end
        
    case abs('E')
        if strcmp(get(handles.editacft_btn,'Enable'),'on')
            editacft_btn_Callback(hObject, eventdata, handles);
        end
        
    case abs('e')
        if strcmp(get(handles.editcalib_btn,'Enable'),'on')
            set(handles.editcalib_btn,'Value',~get(handles.editcalib_btn,'Value'));
            editcalib_btn_Callback(hObject, eventdata, handles);
        end
        
    case abs('d')
        if strcmp(get(handles.doublecalib_btn,'Enable'),'on')
            doublecalib_btn_Callback(hObject, eventdata, handles);
        end
        
end

% -------------------------------------------------------------------
function [na, nc] = getnanc(handles)
% Fornece os índices da aeronave e calibração selecionados

na = get(handles.acft_sel,'Value');
nc = get(handles.date_sel,'Value');

% -------------------------------------------------------------------
function [np, nv] = getnpnv(handles)
% Fornece os índices dos tipos de curvas de calibração

for np = 1:3
    if get(handles.ptypes(np),'Value');
        break
    end
end
for nv = 1:3
    if get(handles.vtypes(nv),'Value');
        break
    end
end

% -------------------------------------------------------------------
function acftdata = getacftdata(acftdb,na,nc)
% Fornece a estrutura de dados de uma calibração específica

if nargin == 2
    
    acftdata.type    = '';
    acftdata.tail    = '';
    acftdata.date    = na*ones(1,3);
    acftdata.remarks = {''};
    acftdata.span    = na;
    acftdata.Sref    = na;
    acftdata.Ws      = na;
    acftdata.orto    = na*ones(1,4);
    acftdata.Dpb     = na*ones(1,6,3);
    acftdata.Dqb     = na*ones(1,6,3);
    acftdata.K       = na;
    acftdata.alpha   = na*ones(1,4);
    acftdata.beta    = na*ones(1,4);
    acftdata.CL      = na*ones(1,4);
    acftdata.polar   = na*ones(1,4);
    acftdata.Cmd     = na*ones(4,5);
    
else
    
    acftdata.type    = acftdb(na).type;
    acftdata.tail    = acftdb(na).tail;
    acftdata.date    = acftdb(na).date(nc,:);
    acftdata.remarks = acftdb(na).remarks{nc};
    acftdata.span    = acftdb(na).span;
    acftdata.Sref    = acftdb(na).Sref;
    acftdata.Ws      = acftdb(na).Ws(nc);
    acftdata.orto    = acftdb(na).orto(nc,:);
    acftdata.Dpb     = acftdb(na).Dpb(nc,:,:);
    acftdata.Dqb     = acftdb(na).Dqb(nc,:,:);
    acftdata.K       = acftdb(na).K(nc);
    acftdata.alpha   = acftdb(na).alpha(nc,:);
    acftdata.beta    = acftdb(na).beta(nc,:);
    acftdata.CL      = acftdb(na).CL(nc,:);
    acftdata.polar   = acftdb(na).polar(nc,:);
    acftdata.Cmd     = acftdb(na).Cmd(:,:,nc);
    
end

% -------------------------------------------------------------------
function handles = setacftdata(handles,na,nc,acftdata)
% Atualiza a estrutura de dados de uma calibração específica

handles.acftdb(na).type        = acftdata.type;
handles.acftdb(na).tail        = acftdata.tail;
handles.acftdb(na).date(nc,:)  = acftdata.date;
handles.acftdb(na).remarks{nc} = acftdata.remarks;
handles.acftdb(na).span        = acftdata.span;
handles.acftdb(na).Sref        = acftdata.Sref;
handles.acftdb(na).Ws(nc)      = acftdata.Ws;
handles.acftdb(na).orto(nc,:)  = acftdata.orto;
handles.acftdb(na).Dpb(nc,:,:) = acftdata.Dpb;
handles.acftdb(na).Dqb(nc,:,:) = acftdata.Dqb;
handles.acftdb(na).K(nc)       = acftdata.K;
handles.acftdb(na).alpha(nc,:) = acftdata.alpha;
handles.acftdb(na).beta(nc,:)  = acftdata.beta;
handles.acftdb(na).CL(nc,:)    = acftdata.CL;
handles.acftdb(na).polar(nc,:) = acftdata.polar;
handles.acftdb(na).Cmd(:,:,nc) = acftdata.Cmd;

% -------------------------------------------------------------------
function updatebuttons(hObject, eventdata, handles, opt)
% Atualiza icones dos botões

if opt == 1
    
    set([handles.newacft_btn    handles.newcalib_btn   ], 'CData', handles.icons.new);
    set([handles.removeacft_btn handles.removecalib_btn], 'CData', handles.icons.remove);
    set(handles.editacft_btn   , 'CData', handles.icons.rename);
    set(handles.editcalib_btn  , 'CData', handles.icons.edit);
    set(handles.doublecalib_btn, 'CData', handles.icons.double);
    set(handles.save_btn       , 'CData', handles.icons.save);
    
else
    
    set([handles.newacft_btn    handles.newcalib_btn   ], 'CData', handles.icons.new0);
    set([handles.removeacft_btn handles.removecalib_btn], 'CData', handles.icons.remove0);
    set(handles.editacft_btn   , 'CData', handles.icons.rename0);
    set(handles.doublecalib_btn, 'CData', handles.icons.double0);
    set(handles.save_btn       , 'CData', handles.icons.save0);
    
end

% -------------------------------------------------------------------
function acftdb = sortdb(acftdb)
% Ordena por nome de aeronaves e por data de calibração

for n = 1:size(acftdb,2);
    names{n} = [acftdb(n).type ' ' acftdb(n).tail];
end

[void,ind] = sort(lower(names));
acftdb = acftdb(ind);

Na = size(acftdb,2);
for na = 1:Na
    [void,ind] = sort(datenum(acftdb(na).date));
    
    acftdb(na).date    = acftdb(na).date(ind,:);
    acftdb(na).remarks = acftdb(na).remarks(ind);
    acftdb(na).Ws      = acftdb(na).Ws(ind);
    acftdb(na).orto    = acftdb(na).orto(ind,:);
    acftdb(na).Dpb     = acftdb(na).Dpb(ind,:,:);
    acftdb(na).Dqb     = acftdb(na).Dqb(ind,:,:);
    acftdb(na).K       = acftdb(na).K(ind);
    acftdb(na).alpha   = acftdb(na).alpha(ind,:);
    acftdb(na).beta    = acftdb(na).beta(ind,:);
    acftdb(na).CL      = acftdb(na).CL(ind,:);
    acftdb(na).polar   = acftdb(na).polar(ind,:);
    acftdb(na).Cmd     = acftdb(na).Cmd(:,:,ind);
   
end

% -------------------------------------------------------------------
function strfix(h,def,vmin,vmax)
% Função que corrige o string inserido num campo

str = get(h,'String');
if isempty(str)
    return
end

val = str2num(str);

switch nargin
    case 1
        def = '';
        vmin = -inf;
        vmax =  inf;
    case 2
        vmin = -inf;
        vmax =  inf;
    case 3
        vmax =  inf;
end

if length(val) ~= 1 || isnan(val)
    str = num2str(def);
else
    val = max(vmin, min(vmax, val));
    str = num2str(val,16);
end
set(h,'String',str);

% -------------------------------------------------------------------
function str = nan2empty(str)
% Função que troca NaN pelo string vazio para apresentação dos campos

if isnan(str)
    str = '';
end

% -------------------------------------------------------------------
function M = getbutton(fname, bgc)
% Função que carrega um bitmap de 16 ou 256 cores e converte a cor magenta
% em cor de fundo para uso como icone de botões
% Sintaxe: M = buttons(fname, bgc)
%          fname: nome do arquivo bmp (com extensão)
%          bgc: cor de fundo desejada [r g b]

if ~exist(fname,'file')
    M = [];
    return
end
    
[M,c] = imread(fname);
if ~isempty(c)
    M = ind2rgb(M,c);
end
for n=1:size(M,1)
    for m=1:size(M,2)
        if M(n,m,1)==1 && M(n,m,2)==0 && M(n,m,3)==1
            M(n,m,1) = bgc(1);
            M(n,m,2) = bgc(2);
            M(n,m,3) = bgc(3);
        end
    end
end
