function varargout = RDAT_ExternalFcn(varargin)
% RDAT_EXTERNALFCN M-file for RDAT_ExternalFcn.fig
% Last Modified by GUIDE v2.5 03-Dec-2010 14:15:02

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RDAT_ExternalFcn_OpeningFcn, ...
                   'gui_OutputFcn',  @RDAT_ExternalFcn_OutputFcn, ...
                   'gui_LayoutFcn',  @RDAT_ExternalFcn_LayoutFcn, ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1}) && size(varargin{1},1)==1
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

% -------------------------------------------------------------------------
% -- WINDOW FUNCTIONS -----------------------------------------------------
% -------------------------------------------------------------------------

function h = RDAT_ExternalFcn_LayoutFcn(varargin)
% Função de layout inicial

h = openfig('RDAT_ExternalFcn.fig','reuse','invisible');

% --------------------------------------------------------------------------------------------------
function RDAT_ExternalFcn_OpeningFcn(hObject, eventdata, handles, varargin)
global DADOS
% Funçao de inicializaçao

scrsz = get(0,'ScreenSize');
winsz = get(handles.window,'Position');
set(handles.window,'Position',[.5*(scrsz(3)-winsz(3)) .5*(scrsz(4)-winsz(4)) winsz(3) winsz(4)],'Visible','on');

bgc = getbuttoncolor(handles.window);
set(handles.browse_btn,'CData',geticon('DatButtons.mat','open',bgc));
set(handles.clear_btn, 'CData',geticon('DatButtons.mat','new', bgc));
set(handles.help_btn,  'CData',geticon('DatButtons.mat','help',bgc));
handles.search_ico = { geticon('DatButtons.mat','zoom',bgc), geticon('DatButtons.mat','zoom',bgc,0,0,0,1,.5) };
set(handles.search_btn,'CData',handles.search_ico{2},'Enable','inactive');

handles.fpath = [cd '\'];
handles.temppath = {};

if nargin >= 4
    PARAM = cellstr(varargin{1});
else
    set(handles.window,'Visible','off');
    beep; uiwait(errordlg('Dados de entrada não fornecidos.','Erro','modal'));
    handles.ok = 0;
    guidata(hObject, handles);
    uiresume;
    return
end
if nargin >= 5
    handles.maxparamlength = varargin{2};
else
    handles.maxparamlength = 48;
end

PARAM = [{' ';'Especificar'}; PARAM];

handles.inputsel = [handles.input1_sel handles.input2_sel handles.input3_sel handles.input4_sel handles.input5_sel,...
        handles.input6_sel handles.input7_sel handles.input8_sel handles.input9_sel handles.input10_sel];
handles.inputvars = [handles.input1 handles.input2 handles.input3 handles.input4 handles.input5,...
        handles.input6 handles.input7 handles.input8 handles.input9 handles.input10];
handles.inputnames = [handles.in1_txt handles.in2_txt handles.in3_txt handles.in4_txt handles.in5_txt,...
        handles.in6_txt handles.in7_txt handles.in8_txt handles.in9_txt handles.in10_txt];
handles.outputvars = [handles.output1 handles.output2 handles.output3 handles.output4 handles.output5,...
        handles.output6 handles.output7 handles.output8 handles.output9 handles.output10];

set(handles.inputsel,'String',PARAM,'Value',1);
set(handles.inputvars,'Enable','off','BackgroundColor',bgc);
set(handles.inputsel(2:end),'Value',1,'Enable','off','BackgroundColor',bgc);
set(handles.outputvars(2:end),'Enable','off','BackgroundColor',bgc);
set(handles.NObs_txt,'String',['No. OBS.: ' num2str(size(DADOS,1))]);
set([handles.paramlist handles.setname],'Enable','off','String','');

setappdata(handles.window,'results',[]);

handles.ok = 0;
guidata(hObject, handles);
uiwait(handles.window);

% -------------------------------------------------------------------------
function varargout = RDAT_ExternalFcn_OutputFcn(hObject, eventdata, handles)
% Funçao de saida

if handles.ok
    
    results = getappdata(handles.window,'results');
    DADOS2 = [];
    
    PARAM2 = get(handles.paramlist,'String');
    for n = 1:size(results,1)
        if results{n,3}
            DADOS2 = [DADOS2 results{n,2}];
        end
    end
    
    varargout{1} = DADOS2;
    varargout{2} = PARAM2;
else
    varargout{1} = [];
    varargout{2} = [];
end

for n = 1:length(handles.temppath)
    rmpath(handles.temppath{n});
end

delete(handles.window);

% -------------------------------------------------------------------------
function window_KeyPressFcn(hObject, eventdata, handles)
% Acionamento de tecla do teclado

cc = get(handles.window,'CurrentCharacter');

if isempty(cc)
    return
end

switch abs(cc)
    
    case {abs('f'),abs('F')}
        browse_btn_Callback(hObject, eventdata, handles);
        
    case {abs('l'),abs('L')}
        clear_btn_Callback(hObject, eventdata, handles);
    
    case {abs('p'),abs('P')}
        if strcmp(get(handles.search_btn,'Enable'),'on')
            search_btn_Callback(hObject, eventdata, handles);
        end
        
    case {abs('x'),abs('X')}
        run_btn_Callback(hObject, eventdata, handles);
        
    case 13 % Enter
        ok_btn_Callback(hObject, eventdata, handles);
        
    case 27 % Esc
        cancel_btn_Callback(hObject, eventdata, handles);
        
end

% -------------------------------------------------------------------
function window_CloseRequestFcn(hObject, eventdata, handles)
% Fechamento da janela

cancel_btn_Callback(hObject, eventdata, handles);

% -------------------------------------------------------------------
% -- BOTOES ---------------------------------------------------------
% -------------------------------------------------------------------

function browse_btn_Callback(hObject, eventdata, handles)
% Procura por funçao

[fname, fpath] = uigetfile({'*.m;*.mex;*.dll'},'Localizar função',handles.fpath);
if ischar(fname)
    set(handles.fcnname_entry,'String',fname);
    if ~exist(fname,'file')
        button = questdlg({'Função não encontrada na lista de caminhos.',...
                'Deseja adicionar temporariamente o caminho da função?',['''' fpath '''']},...
            'Erro','Sim','Não','Não'); drawnow;
        if strcmp(button,'Sim')
            path(path,fpath);
            handles.temppath{end+1} = fpath;
        end
    end
    handles.fpath = fpath;
    guidata(hObject, handles);
    fcnname_entry_Callback(hObject, eventdata, handles);
end

% -------------------------------------------------------------------------
function search_btn_Callback(hObject, eventdata, handles)
% Tenta localizar as variaveis de entrada automaticamente

PARAM = get(handles.input1_sel,'String');
PARAM(1:2) = [];

for n = 1:length(handles.inputnames)
    name = get(handles.inputnames(n),'String');
    if ~isempty(name)
        ncol = findpar(PARAM,name);
        if ~isempty(ncol)
            set(handles.inputsel(n),'Value',ncol+2);
        else
            set(handles.inputsel(n),'Value',2);
        end
        update_inputs(hObject, eventdata, handles, n);
    end
end

% -------------------------------------------------------------------------
function clear_btn_Callback(hObject, eventdata, handles)
% Limpa lista de variaveis de entrada

set(handles.inputsel(1),'Value',1);
update_inputs(hObject, eventdata, handles, 1);

% -------------------------------------------------------------------------
function run_btn_Callback(hObject, eventdata, handles)
global DADOS
% Executa a funçao selecionada

fcn = get(handles.fcnname_entry,'String');
out_var = {};
in_str  = '';
out_str = '';

if isempty(fcn)
    beep; uiwait(errordlg('Função não definida.','Erro','modal')); drawnow;
    return
end
if ~exist([fcn '.m'],'file') && ~exist([fcn '.mex'],'file') && ~exist([fcn '.dll'],'file')
    beep; uiwait(errordlg(['Função ' fcn ' não encontrada.'],'Erro','modal')); drawnow;
    return
end

for ni = 1:length(handles.inputvars)
    in_n = get(handles.inputvars(ni),'String');
    if ~isempty(in_n)
        if ni == 1
            in_str = in_n;
        else
            in_str = [in_str ',' in_n];
        end
    else
        break
    end
end
for no = 1:length(handles.outputvars)
    out_n = get(handles.outputvars(no),'String');
    if ~isempty(out_n)
        out_var{no} = out_n;
        if no == 1
            out_str = out_n;
        else
            out_str = [out_str ',' out_n];
        end
    else
        break
    end
end

if isempty(in_str)
    beep; uiwait(errordlg('Variáveis de entrada não definidas.','Erro','modal')); drawnow;
    return
end
if isempty(out_str)
    beep; uiwait(errordlg('Variáveis de saída não definidas.','Erro','modal')); drawnow;
    return
end
if length(out_var) ~= length(unique(out_var))
    beep; uiwait(errordlg('Nomes das variáveis de saída devem ser únicos.','Erro','modal')); drawnow;
    return
end

fcnstr = ['[' out_str '] = ' fcn '(' in_str ');'];

try
    set(handles.window,'Pointer','watch');
    eval(fcnstr);
    for n = 1:length(out_var)
        results{n,1} = out_var{n};
        eval(['results{' num2str(n) ',2} = ' out_var{n} ';']);
        results{n,3} = 0;
    end
    setappdata(handles.window,'results',results);
catch
    beep; uiwait(errordlg(lasterr,'Erro','modal')); drawnow;
    setappdata(handles.window,'results',[]);
end

update_results(hObject, eventdata, handles);
set(handles.window,'Pointer','arrow');

% -------------------------------------------------------------------------
function add_btn_Callback(hObject, eventdata, handles)
global DADOS
% Inclui variavel

results = getappdata(handles.window,'results');
n_inc = get(handles.outputlist,'Value');

if isempty(results) || isempty(n_inc)
    return
end

for n = 1:length(n_inc)
    if isempty(results{n_inc(n),2})
        beep; uiwait(errordlg(['Variável ''' results{n_inc(n),1} ''' vazia.'],'Erro','modal'));
    elseif size(results{n_inc(n),2},1) ~= size(DADOS,1) || size(results{n_inc(n),2},3) ~= 1
        beep; uiwait(errordlg(['Variável ''' results{n_inc(n),1} ''' não é compatível com a matriz de dados.'],'Erro','modal'));
    else
        results{n_inc(n),3} = 1;
    end
end

setappdata(handles.window,'results',results);
update_include(hObject, eventdata, handles)

% -------------------------------------------------------------------------
function rem_btn_Callback(hObject, eventdata, handles)
% Remove variavel

results = getappdata(handles.window,'results');
n_exc = get(handles.includelist,'Value');
ind = get(handles.includelist,'UserData');

if isempty(results) || isempty(n_exc) || isempty(ind)
    return
end

for n = 1:length(n_exc)
    results{ind(n_exc(n)),3} = 0;
end

setappdata(handles.window,'results',results);
update_include(hObject, eventdata, handles)

% -------------------------------------------------------------------------
function transpose_btn_Callback(hObject, eventdata, handles)
% Inclui variavel

results = getappdata(handles.window,'results');
n_tr = get(handles.outputlist,'Value');

if isempty(results) || isempty(n_tr)
    return
end

for n = 1:length(n_tr)
    if results{n_tr(n),3} == 1
        beep; uiwait(errordlg({['Variável ''' results{n_tr(n),1} ''' não pode ser transposta'],...
                'pois já foi adicionada.'},'Erro','modal'));
    else
        results{n_tr(n),2} = results{n_tr(n),2}';
    end
end

setappdata(handles.window,'results',results);
update_results(hObject, eventdata, handles);
update_include(hObject, eventdata, handles);
set(handles.outputlist,'Value',n_tr);

% -------------------------------------------------------------------
function help_btn_Callback(hObject, eventdata, handles)
% Botao Ajuda

helpme('Funcoes\funcaoexterna');

% -------------------------------------------------------------------------
function ok_btn_Callback(hObject, eventdata, handles)
% Botao OK

PARAM2 = get(handles.paramlist,'String');

if isempty(PARAM2)
    beep; uiwait(errordlg('Não há parâmetros selecionados.','Erro','modal'));
    return
end

button = questdlg('Deseja confirmar a operação?','Confirmação','Sim','Não','Não');
if strcmp(button,'Sim')
    handles.ok = 1;
    guidata(hObject, handles);
    uiresume;
end

% -------------------------------------------------------------------
function cancel_btn_Callback(hObject, eventdata, handles)
% Botao Cancela

button = questdlg('Deseja cancelar a operação?','Confirmação','Sim','Não','Não');
if strcmp(button,'Sim')
    uiresume;
end

% -------------------------------------------------------------------------
% -- FIELD FUNCTIONS ------------------------------------------------------
% -------------------------------------------------------------------------

function fcnname_entry_Callback(hObject, eventdata, handles)
% Entrada do nome da funçao

bgc = get(handles.window,'Color');
fcn = get(handles.fcnname_entry,'String');

if isempty(fcn)
    set(handles.fcnhelp,'String','');
    return
end

ix = find(fcn=='.');
if ~isempty(ix)
    fcn(ix(1):end) = [];
    set(handles.fcnname_entry,'String',fcn);
end

if ~exist(fcn)
    str = 'Função não encontrada na lista de caminhos.';
else
    hstr = help(fcn);
    if isempty(hstr)
        str = 'Função não contém ajuda.';
    else
        hstr = [char(10) hstr char(10)];
        ix = find(hstr == char(10));
        for n = 1:length(ix)-1
            str{n} = hstr(ix(n)+1:ix(n+1)-1);
        end
    end
end
set(handles.fcnhelp,'String',str);

[invars, outvars] = getvarnames(fcn);

if isempty(invars)
    for n = 1:length(handles.inputnames)
        set(handles.inputnames(n),'String',num2str(n));
    end
    set(handles.search_btn,'CData',handles.search_ico{2},'Enable','inactive');
else
    N = min(length(invars),length(handles.inputnames));
    for n = 1:N
        set(handles.inputnames(n),'String',invars{n});
    end
    set(handles.inputnames(N+1:length(handles.inputnames)),'String','');
    set(handles.search_btn,'CData',handles.search_ico{1},'Enable','on');
end
if isempty(outvars)
    set(handles.outputvars,'String','');
    set(handles.outputvars(2:end),'Enable','off','BackgroundColor',bgc);
else
    N = min(length(outvars),length(handles.outputvars));
    for n = 1:N
        set(handles.outputvars(n),'String',outvars{n},'Enable','on','BackgroundColor','w');
    end
    if N < length(handles.outputvars)
        set(handles.outputvars(N+1),'String','','Enable','on','BackgroundColor','w');
    end
    set(handles.outputvars(N+2:end),'String','','Enable','off','BackgroundColor',bgc);
end

if length(invars) > length(handles.inputvars) && length(outvars) > length(handles.outputvars)
    uiwait(warndlg('A função aparenta ter mais variáveis de entrada e saída que o suportado.','Aviso','modal'));
else
    if length(invars) > length(handles.inputvars)
        uiwait(warndlg('A função aparenta ter mais variáveis de entrada que o suportado.','Aviso','modal'));
    end
    if length(outvars) > length(handles.outputvars)
        uiwait(warndlg('A função aparenta ter mais variáveis de saída que o suportado.','Aviso','modal'));
    end
end

% -------------------------------------------------------------------------
function input1_sel_Callback(hObject, eventdata, handles)
update_inputs(hObject, eventdata, handles, 1);
% -------------------------------------------------------------------------
function input2_sel_Callback(hObject, eventdata, handles)
update_inputs(hObject, eventdata, handles, 2);
% -------------------------------------------------------------------------
function input3_sel_Callback(hObject, eventdata, handles)
update_inputs(hObject, eventdata, handles, 3);
% -------------------------------------------------------------------------
function input4_sel_Callback(hObject, eventdata, handles)
update_inputs(hObject, eventdata, handles, 4);
% -------------------------------------------------------------------------
function input5_sel_Callback(hObject, eventdata, handles)
update_inputs(hObject, eventdata, handles, 5);
% -------------------------------------------------------------------------
function input6_sel_Callback(hObject, eventdata, handles)
update_inputs(hObject, eventdata, handles, 6);
% -------------------------------------------------------------------------
function input7_sel_Callback(hObject, eventdata, handles)
update_inputs(hObject, eventdata, handles, 7);
% -------------------------------------------------------------------------
function input8_sel_Callback(hObject, eventdata, handles)
update_inputs(hObject, eventdata, handles, 8);
% -------------------------------------------------------------------------
function input9_sel_Callback(hObject, eventdata, handles)
update_inputs(hObject, eventdata, handles, 9);
% -------------------------------------------------------------------------
function input10_sel_Callback(hObject, eventdata, handles)
update_inputs(hObject, eventdata, handles, 10);

% -------------------------------------------------------------------------
function input1_Callback(hObject, eventdata, handles)
set(handles.input1_sel,'Value',2);
% -------------------------------------------------------------------------
function input2_Callback(hObject, eventdata, handles)
set(handles.input2_sel,'Value',2);
% -------------------------------------------------------------------------
function input3_Callback(hObject, eventdata, handles)
set(handles.input3_sel,'Value',2);
% -------------------------------------------------------------------------
function input4_Callback(hObject, eventdata, handles)
set(handles.input4_sel,'Value',2);
% -------------------------------------------------------------------------
function input5_Callback(hObject, eventdata, handles)
set(handles.input5_sel,'Value',2);
% -------------------------------------------------------------------------
function input6_Callback(hObject, eventdata, handles)
set(handles.input6_sel,'Value',2);
% -------------------------------------------------------------------------
function input7_Callback(hObject, eventdata, handles)
set(handles.input7_sel,'Value',2);
% -------------------------------------------------------------------------
function input8_Callback(hObject, eventdata, handles)
set(handles.input8_sel,'Value',2);
% -------------------------------------------------------------------------
function input9_Callback(hObject, eventdata, handles)
set(handles.input9_sel,'Value',2);
% -------------------------------------------------------------------------
function input10_Callback(hObject, eventdata, handles)
set(handles.input10_sel,'Value',2);

% -------------------------------------------------------------------------
function output1_Callback(hObject, eventdata, handles)
update_outputs(hObject, eventdata, handles, 1);
% -------------------------------------------------------------------------
function output2_Callback(hObject, eventdata, handles)
update_outputs(hObject, eventdata, handles, 2);
% -------------------------------------------------------------------------
function output3_Callback(hObject, eventdata, handles)
update_outputs(hObject, eventdata, handles, 3);
% -------------------------------------------------------------------------
function output4_Callback(hObject, eventdata, handles)
update_outputs(hObject, eventdata, handles, 4);
% -------------------------------------------------------------------------
function output5_Callback(hObject, eventdata, handles)
update_outputs(hObject, eventdata, handles, 5);
% -------------------------------------------------------------------------
function output6_Callback(hObject, eventdata, handles)
update_outputs(hObject, eventdata, handles, 6);
% -------------------------------------------------------------------------
function output7_Callback(hObject, eventdata, handles)
update_outputs(hObject, eventdata, handles, 7);
% -------------------------------------------------------------------------
function output8_Callback(hObject, eventdata, handles)
update_outputs(hObject, eventdata, handles, 8);
% -------------------------------------------------------------------------
function output9_Callback(hObject, eventdata, handles)
update_outputs(hObject, eventdata, handles, 9);
% -------------------------------------------------------------------------
function output10_Callback(hObject, eventdata, handles)
update_outputs(hObject, eventdata, handles, 10);

% -------------------------------------------------------------------------
function paramlist_Callback(hObject, eventdata, handles)
% Clique na lista de parametros

PARAM = get(handles.paramlist,'String');
n = get(handles.paramlist,'Value');

if isempty(PARAM)
    set(handles.setname,'Enable','off','String','');
    return
end

set(handles.setname,'Enable','on','String',PARAM{n});

% -------------------------------------------------------------------------
function setname_Callback(hObject, eventdata, handles)
% Ediçao de nome de parametro

PARAM = get(handles.paramlist,'String');
n = get(handles.paramlist,'Value');

parname = TrimParamName(get(handles.setname,'String'),handles.maxparamlength);

if ~isempty(parname)
    PARAM{n} = parname;
    set(handles.setname,'String',PARAM{n});
end

set(handles.paramlist,'String',PARAM);
paramlist_Callback(hObject, eventdata, handles);

% -------------------------------------------------------------------------
% -- UPDATE FUNCTIONS -----------------------------------------------------
% -------------------------------------------------------------------------

function update_results(hObject, eventdata, handles)
% Atualiza lista de variaveis de saida

results = getappdata(handles.window,'results');

if ~isempty(results)
    
    for n = 1:size(results,1)
        str{n,1} = results{n,1};
        str{n,2} = ['(' num2str(size(results{n,2},1)) '×' num2str(size(results{n,2},2)) ')'];
        str{n,3} = ['(' class(results{n,2}) ')'];
    end
    str = cell2str(str);
else
    str = '';
end

set(handles.outputlist,'String',str,'Value',1);
set(handles.includelist,'String',[],'UserData',[],'Value',1);
update_params(hObject, eventdata, handles);

% -------------------------------------------------------------------------
function update_inputs(hObject, eventdata, handles, n)
% Atualiza e habilita as entradas de dados

np = get(handles.inputsel(n),'Value');

if np == 1 % Ignorar
    str = '';
    en = 'off';
    bgc = get(handles.window,'Color');
elseif np == 2 % Especificar
    str = '';
    en = 'on';
    bgc = 'w';
else  % Parametro
    str = ['DADOS(:,' num2str(np-2) ')'];
    en  = 'on';
    bgc = 'w';
end
set(handles.inputvars(n),'String',str,'Enable',en,'BackgroundColor',bgc);

in = cell2mat(get(handles.inputsel,'Value'));
aux = min(find(in==1));
set(handles.inputvars(aux:end),'String','','Enable','off','BackgroundColor',get(handles.window,'Color'));
set(handles.inputsel(aux+1:end),'Value',1,'Enable','off','BackgroundColor',get(handles.window,'Color'));
set(handles.inputsel(1:aux),'Enable','on','BackgroundColor','w');

% -------------------------------------------------------------------------
function update_outputs(hObject, eventdata, handles, n)
% Verifica e habilita as saidas de dados

out_str = get(handles.outputvars(n),'String');

out_str = name2var(out_str);
set(handles.outputvars(n),'String',out_str);

for n = 1:length(handles.outputvars)
    if isempty(get(handles.outputvars(n),'String'))
        set(handles.outputvars(n+1:end),'String','','Enable','off','BackgroundColor',get(handles.window,'Color'));
        set(handles.outputvars(1:n),'Enable','on','BackgroundColor','w');
        break
    end
end

% -------------------------------------------------------------------------
function update_params(hObject, eventdata, handles)
% Atualiza lista de parametros

results = getappdata(handles.window,'results');
if isempty(results) || ~any(cell2mat(results(:,3)))
    set([handles.paramlist handles.setname],'Enable','off','String','');
    return
end

PARAM = {};
for n = 1:size(results,1)
    if results{n,3}
        if size(results{n,2},2) == 1
            PARAM{length(PARAM)+1} = results{n,1};
        else
            for m = 1:size(results{n,2},2)
                PARAM{length(PARAM)+1} = [results{n,1} '_' num2str(m)];
            end
        end
    end
end

set(handles.paramlist,'Enable','on','String',PARAM,'Value',1);
paramlist_Callback(hObject, eventdata, handles);

% -------------------------------------------------------------------------
function update_include(hObject, eventdata, handles)
% Atualiza a lista de variaveis incluidas

results = getappdata(handles.window,'results');

inc = {};
ind = [];
for n = 1:size(results,1)
    if results{n,3}
        inc{length(inc)+1} = results{n,1};
        ind(length(ind)+1) = n;
    end
end

set(handles.includelist,'String',inc,'UserData',ind,'Value',1);
update_params(hObject, eventdata, handles);
