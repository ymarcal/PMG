function varargout = RDAT_LoadFilter(varargin)
% RDAT_LOADFILTER M-file for RDAT_LoadFilter.fig
% Last Modified by GUIDE v2.5 07-Dec-2010 10:30:42

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RDAT_LoadFilter_OpeningFcn, ...
                   'gui_OutputFcn',  @RDAT_LoadFilter_OutputFcn, ...
                   'gui_LayoutFcn',  @RDAT_LoadFilter_LayoutFcn, ...
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

% -------------------------------------------------------------------
function h = RDAT_LoadFilter_LayoutFcn(varargin)
% Função de layout inicial

h = openfig('RDAT_LoadFilter.fig','reuse','invisible');

% -------------------------------------------------------------------
function RDAT_LoadFilter_OpeningFcn(hObject, eventdata, handles, varargin)
% Funçao de inicializaçao

bgc = getbuttoncolor(handles.window);
set([handles.add1 handles.add2 handles.add3 handles.add4],'CData',geticon('DatButtons.mat','arrow_r',bgc));
set(handles.ML_FDATool_btn,'CData',geticon('DatButtons.mat','fda',bgc));
set(handles.view_btn,      'CData',geticon('DatButtons.mat','filterplot',bgc));
set(handles.browse_btn,    'CData',geticon('DatButtons.mat','open',bgc));
set(handles.help_btn,      'CData',geticon('DatButtons.mat','help',bgc));

scrsz = get(0,'ScreenSize');
winsz = get(handles.window,'Position');
set(handles.window,'Position',[.5*(scrsz(3)-winsz(3)) .5*(scrsz(4)-winsz(4)) winsz(3) winsz(4)],'Visible','on');

set(handles.form_sel,'String',{'Objeto Filtro','Função de Transferência','Espaço de Estados',...
        'Zeros, Polos e Ganho','Seções de 2ª Ordem e Ganho','Média Móvel'},'Value',1)

handles.entries = [...
        handles.text1 handles.add1 handles.entry1;...
        handles.text2 handles.add2 handles.entry2;...
        handles.text3 handles.add3 handles.entry3;...
        handles.text4 handles.add4 handles.entry4];

handles.ok = 0;
handles.Hd = [];
handles.fname = '';
handles.data = {[],[],[],[]};

guidata(hObject, handles);

if length(varargin) == 1 && isstruct(varargin{1})
    setup = varargin{1};
    
    if setup.source == 1
        work_chk_Callback(hObject, eventdata, handles);
    else
        handles.fname = setup.fname;
        [fpath,fname,fext] = fileparts(setup.fname);
        set(handles.fname_entry,'String',[fname fext],'TooltipString',setup.fname);
        file_chk_Callback(hObject, eventdata, handles);
    end
    
    set(handles.form_sel,'Value',setup.format);
    form_sel_Callback(hObject, eventdata, handles);
    
    for n = 1:4
        set(handles.entries(n,3),'String',setup.entry{n});
        val = enterdata_Callback(hObject, eventdata, handles, n);
        handles.data{n} = val;
        if isempty(val)
            set(handles.entries(n,3),'String','');
        end

    end
    
else
    work_chk_Callback(hObject, eventdata, handles);
    form_sel_Callback(hObject, eventdata, handles);
end

guidata(hObject, handles);


uiwait(handles.window);

% -------------------------------------------------------------------
function varargout = RDAT_LoadFilter_OutputFcn(hObject, eventdata, handles)
% Funçao de saida

if handles.ok
    varargout{1} = handles.Hd;
    
    setup.source = get(handles.file_chk,'Value')+1;
    setup.fname  = handles.fname;
    setup.format = get(handles.form_sel,'Value');
    for n = 1:4
        setup.entry{n} = get(handles.entries(n,3),'String');
    end
    
    varargout{2} = setup;
    
else
    varargout = {[],[]};
end
delete(handles.window);

% -------------------------------------------------------------------
function ML_FDATool_btn_Callback(hObject, eventdata, handles)
% Ferramenta de criação de filtros do MATLAB

fdatool;

% -------------------------------------------------------------------
function work_chk_Callback(hObject, eventdata, handles)
% Seleciona workspace como origem de dados

set(handles.work_chk,'Value',1);
set(handles.file_chk,'Value',0);
set(handles.fname_entry,'Enable','off');

aux = evalin('base','whos');
for n = 1:size(aux,1)
    vars(n).name  = aux(n).name;
    vars(n).size  = aux(n).size;
    vars(n).class = aux(n).class;
end
if ~isempty(aux)
    vars = struct2cell(vars')';
else
    vars = {};
end
    
for n = 1:size(vars,1)
    if length(vars{n,2}) == 3
        vars{n,2} = ['(' num2str(vars{n,2}(1)) '×' num2str(vars{n,2}(2)) '×' num2str(vars{n,2}(3)) ')'];
    else
        vars{n,2} = ['(' num2str(vars{n,2}(1)) '×' num2str(vars{n,2}(2)) ')'];
    end
    vars{n,3} = ['(' vars{n,3} ')'];
end
set(handles.contents_list,'String',cell2str(vars),'UserData',vars,'Value',1);

% -------------------------------------------------------------------
function file_chk_Callback(hObject, eventdata, handles)
% Seleciona arquivo como origem de dados

set(handles.work_chk,'Value',0);
set(handles.file_chk,'Value',1);
set(handles.fname_entry,'Enable','inactive');

try
    aux = whos('-file',handles.fname);
    for n = 1:size(aux,1)
        vars(n).name  = aux(n).name;
        vars(n).size  = aux(n).size;
        vars(n).class = aux(n).class;
    end
    if ~isempty(aux)
        vars = struct2cell(vars')';
    else
        vars = {};
    end

    for n = 1:size(vars,1)
        if length(vars{n,2}) == 3
            vars{n,2} = ['(' num2str(vars{n,2}(1)) '×' num2str(vars{n,2}(2)) '×' num2str(vars{n,2}(3)) ')'];
        else
            vars{n,2} = ['(' num2str(vars{n,2}(1)) '×' num2str(vars{n,2}(2)) ')'];
        end
        vars{n,3} = ['(' vars{n,3} ')'];
    end
    set(handles.contents_list,'String',cell2str(vars),'UserData',vars,'Value',1);
catch
    set(handles.contents_list,'String','','UserData',[],'Value',1);
end

% -------------------------------------------------------------------
function browse_btn_Callback(hObject, eventdata, handles)
% Localizar arquivo de filtros

[fname, fpath] = uigetfile({'*.mat','Arquivo mat (*.mat)'},'Indique arquivo de filtros'); drawnow;
if ischar(fname)
    set(handles.fname_entry,'String',fname,'TooltipString',[fpath fname]);
    handles.fname = [fpath fname];
    guidata(hObject, handles);
    file_chk_Callback(hObject, eventdata, handles);
end

% -------------------------------------------------------------------
function contents_list_Callback(hObject, eventdata, handles)
% Abre variavel selecionada com duplo-clique

set(handles.window,'WindowStyle','normal')

if strcmp(get(handles.window,'SelectionType'),'open');
    
    n = get(handles.contents_list,'Value');
    vars = get(handles.contents_list,'UserData');
    
    if isempty(vars)
        return
    end
    
    var = vars{n,1};
    
    if get(handles.work_chk,'Value');
        dat = evalin('base',var);
    else
        try
            load(handles.fname,var);
            eval(['dat = ' var ';']);
        catch
            beep; errordlg(lasterr,'Erro','modal'); drawnow;
            return
        end
    end
    
    if isnumeric(dat)
        
        if size(dat,1) >= 101
            dat(100:end,:) = [];
        end
        
        if size(dat,2) >= 13
            dat(:,13:end) = [];
            str = num2str2(dat);
            
            str(:,end+1) = '.';
            str(:,end+1) = '.';
            str(:,end+1) = '.';
            
        else
            str = num2str2(dat);
        end
        
        ext = strextent(str);
        
    elseif ischar(dat)
        
        str = dat;
        ext = strextent(str);
        
    end
    
    try
        displaybox(str,var,max(ext)+20);
    catch
        beep; errordlg('Não é possível exibir a variável.','Erro','modal'); drawnow;
    end
    
end

% -------------------------------------------------------------------
function form_sel_Callback(hObject, eventdata, handles)
% Seleciona tipo de entradas

% Obj | FT | SS | ZP | SOS | MM
M = {...
        'Objeto','','','';...
        'Numerador','Denominador','','';...
        'Matriz A','Matriz B','Matriz C','Matriz D';...
        'Zeros','Polos','Ganho','';...
        'Matriz SOS','Ganho','','';...
        'Ordem','','',''};
vis = {'on','off'};

form = get(handles.form_sel,'Value');
for n = 1:4
    set(handles.entries(n,1),'String',M{form,n});
    set(handles.entries(n,:),'Visible',vis{isempty(M{form,n})+1});
end

set(handles.info_txt,'String',{'-';'-';'-';'-'});

% -------------------------------------------------------------------
function add1_Callback(hObject, eventdata, handles)
adddata_Callback(hObject, eventdata, handles, 1);

% -------------------------------------------------------------------
function add2_Callback(hObject, eventdata, handles)
adddata_Callback(hObject, eventdata, handles, 2);

% -------------------------------------------------------------------
function add3_Callback(hObject, eventdata, handles)
adddata_Callback(hObject, eventdata, handles, 3);

% -------------------------------------------------------------------
function add4_Callback(hObject, eventdata, handles)
adddata_Callback(hObject, eventdata, handles, 4);

% -------------------------------------------------------------------
function entry1_Callback(hObject, eventdata, handles)
enterdata_Callback(hObject, eventdata, handles, 1);

% -------------------------------------------------------------------
function entry2_Callback(hObject, eventdata, handles)
enterdata_Callback(hObject, eventdata, handles, 2);

% -------------------------------------------------------------------
function entry3_Callback(hObject, eventdata, handles)
enterdata_Callback(hObject, eventdata, handles, 3);

% -------------------------------------------------------------------
function entry4_Callback(hObject, eventdata, handles)
enterdata_Callback(hObject, eventdata, handles, 4);

% -------------------------------------------------------------------
function view_btn_Callback(hObject, eventdata, handles)
% Visualizar diagramas do filtro

lasterr('');

Hd = createfilter(hObject, eventdata, handles);

if isempty(Hd)
    beep; uiwait(errordlg(char('Erro na definição do filtro.',' ',lasterr),'Erro','modal'));
else
    try
        fvtool(Hd);
    catch
        beep; uiwait(errordlg(char('Erro na definição do filtro.',' ',lasterr),'Erro','modal'));
        Hd = [];
    end
end
ny = {'Não','Sim'};
if ~isempty(Hd)
    s1 = num2str(order(Hd));
    s2 = ny{isfir(Hd)+1};
    s3 = ny{isstable(Hd)+1};
    s4 = ny{islinphase(Hd)+1};
    str = {s1;s2;s3;s4};
else
    str = {'-';'-';'-';'-'};
end
set(handles.info_txt,'String',str);

% -------------------------------------------------------------------
function help_btn_Callback(hObject, eventdata, handles)
% Botao Ajuda

helpme('Funcoes\filtragem');

% -------------------------------------------------------------------
function ok_btn_Callback(hObject, eventdata, handles)
% Botao OK

Hd = createfilter(hObject, eventdata, handles);

if isempty(Hd)
    beep; uiwait(errordlg('Filtro definido incorretamente ou não definido.','Erro','modal'));
else
    button = questdlg('Deseja confirmar a seleção?','Confirmação','Sim','Não','Não');
    if strcmp(button,'Sim')
        handles.ok = 1;
        handles.Hd = Hd;
        guidata(hObject, handles);
        uiresume;
    end
end

% -------------------------------------------------------------------
function cancel_btn_Callback(hObject, eventdata, handles)
% Botao Cancela

button = questdlg('Deseja cancelar a seleção?','Confirmação','Sim','Não','Não');
if strcmp(button,'Sim')
    uiresume;
end

% -------------------------------------------------------------------
function window_KeyPressFcn(hObject, eventdata, handles)
% Acionamento de tecla do teclado

cc = get(handles.window,'CurrentCharacter');

if isempty(cc)
    return
end

switch abs(cc)
    
    case {abs('v'),abs('V')}
        view_btn_Callback(hObject, eventdata, handles);
        
    case {abs('f'),abs('F')}
        browse_btn_Callback(hObject, eventdata, handles);
        
    case 13 % Enter
        ok_btn_Callback(hObject, eventdata, handles);
        
    case 27 % Esc
        cancel_btn_Callback(hObject, eventdata, handles);
        
end

% -------------------------------------------------------------------
function window_CloseRequestFcn(hObject, eventdata, handles)
cancel_btn_Callback(hObject, eventdata, handles);

% -------------------------------------------------------------------
function adddata_Callback(hObject, eventdata, handles, d)
% Atribui variavel selecionada ao parametro desejado

n    = get(handles.contents_list,'Value');
vars = get(handles.contents_list,'UserData');

if ~isempty(vars)
    if get(handles.work_chk,'Value') == 1
        val = evalin('base',vars{n,1});
    else
        load(handles.fname,vars{n,1});
        eval(['val = ' vars{n,1} ';']);
    end
    set(handles.entries(d,3),'String',vars{n,1});
    handles.data{d} = val;
    guidata(hObject, handles);
end

set(handles.info_txt,'String',{'-';'-';'-';'-'});

% -------------------------------------------------------------------
function val = enterdata_Callback(hObject, eventdata, handles, d)
% Inserçao manual do parametro desejado

str = deblank(get(handles.entries(d,3),'String'));
if isempty(str)
    val = [];
else
    num = str2num(str);
    if ~isempty(num)
        val = num;
    else
        try
            if get(handles.work_chk,'Value') == 1
                val = evalin('base',str);
            else
                load(handles.fname,str);
                eval(['val = ' str ';']);
            end
        catch
            val = [];
        end
    end
end
handles.data{d} = val;
guidata(hObject, handles);
if isempty(val)
    set(handles.entries(d,3),'String','');
end

set(handles.info_txt,'String',{'-';'-';'-';'-'});

% -------------------------------------------------------------------
function Hd = createfilter(hObject, eventdata, handles)
% Cria objeto filtro com os paramentros desejados

form = get(handles.form_sel,'Value');
empt = 0;
switch form
    case 1 % Obj
        if isempty(handles.data{1})
            empt = 1;
        end
    case 2 % FT
        if isempty(handles.data{1}) || isempty(handles.data{2})
            empt = 1;
        end
    case 3 % SS
        if isempty(handles.data{1}) || isempty(handles.data{2}) || isempty(handles.data{3}) || isempty(handles.data{4})
            empt = 1;
        end
    case 4 % ZP
        if isempty(handles.data{1}) || isempty(handles.data{2}) || isempty(handles.data{3})
            empt = 1;
        end
    case 5 % SOS
        if isempty(handles.data{1}) || isempty(handles.data{2})
            empt = 1;
        end
    case 6 % MM
        if isempty(handles.data{1})
            empt = 1;
        end
end
if empt
    lasterr('Um ou mais parâmetros não definidos.');
    Hd = [];
    return
end

try
    switch form
        case 1 % Obj
            Hd = handles.data{1};
            clss = class(Hd);
            if ~strcmp(clss(1:5),'dfilt')
                Hd = [];
                lasterr('Objeto não é da classe ''dfilt''.');
            end
        case 2 % FT
            b = handles.data{1};
            a = handles.data{2};
            Hd = dfilt.df1(b,a);
        case 3 % SS
            A = handles.data{1};
            B = handles.data{2};
            C = handles.data{3};
            D = handles.data{4};
            Hd = dfilt.statespace(A,B(:,1),C(1,:),D(1));
        case 4 % ZP
            z = handles.data{1};
            p = handles.data{2};
            k = handles.data{3};
            [b,a] = zp2tf(z(:),p(:),k);
            Hd = dfilt.df1(b,a);
        case 5 % SOS
            s = handles.data{1};
            g = handles.data{2};
            Hd = dfilt.df1sos(s,g);
        case 6 % MM
            ord = handles.data{1};
            b = ones(1,ord)/ord ;
            a = 1;
            Hd = dfilt.df1(b,a);
    end
catch
    Hd = [];
end

