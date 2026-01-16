function varargout = RDAT_Properties(varargin)
% RDAT_PROPERTIES M-file for RDAT_Properties.fig
% Last Modified by GUIDE v2.5 03-Sep-2011 20:03:24

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RDAT_Properties_OpeningFcn, ...
                   'gui_OutputFcn',  @RDAT_Properties_OutputFcn, ...
                   'gui_LayoutFcn',  @RDAT_Properties_LayoutFcn, ...
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
function h = RDAT_Properties_LayoutFcn(varargin)
% Função de layout inicial

h = openfig('RDAT_Properties.fig','reuse','invisible');

% ---------------------------------------------------------------------
function RDAT_Properties_OpeningFcn(hObject, eventdata, handles, varargin)
% Funçao de inicializaçao

ss = get(0,'ScreenSize');
ws = get(handles.window,'Position');
set(handles.window,'Position',[(ss(3)-ws(3))/2, (ss(4)-ws(4))/2, ws(3), ws(4)]);

bgc = getbuttoncolor(handles.window);
set(handles.clear_btn,'CData',geticon('DatButtons.mat','new', bgc));
set(handles.help_btn,'CData',geticon('DatButtons.mat','help', bgc));
set([handles.clearevents_btn handles.cleartestpts_btn handles.clearreftime_btn,...
     handles.clearsetup_btn handles.clearscenario_btn],'CData',geticon('DatButtons.mat','clear', bgc));

if ~isempty(varargin)
    properties = varargin{1};
    fdata = varargin{2};
else
    properties = [];
    fdata = {};
end

infolist = {...
        'mission','crew','date','time','flighttime','number',...
        'aircraft','tailnumber','unit','inventory',...
        'operation','location','security',...
        'remarks','responsible'};
datalist = {'fname','fpath','fdate','ftime','fsize','npar','nobs','prec','reftime','events','testpts','setup','scenario'};

handles.ok  = 0;
handles.chg = 0;
handles.clearopt = [0 0 0 0 0];
handles.infolist = infolist;
handles.datalist = datalist;

guidata(hObject, handles);

bgc = get(handles.window,'Color');
for n = 1:length(datalist)
    set(handles.(datalist{n}),'BackgroundColor',bgc);
end

for n = 1:length(infolist)
    try
        if isfield(properties,infolist{n}) && isfield(handles,infolist{n})
            switch get(handles.(infolist{n}),'Style')
                case 'popupmenu'
                    val = strmatch(properties.(infolist{n}),cellstr(get(handles.(infolist{n}),'String')),'exact');
                    if isempty(val), val = 1; end
                    set(handles.(infolist{n}),'Value',val);
                case 'edit'
                    set(handles.(infolist{n}),'String',properties.(infolist{n}));
            end
        end
    catch
        beep; uiwait(errordlg(lasterr,'Erro','modal')); drawnow;
    end
end
for n = 1:length(datalist)
    if isfield(fdata,datalist{n}) && isfield(handles,datalist{n})
        if strcmp(datalist{n},'fsize')
            fsize = fdata.(datalist{n});
            if isempty(fsize)
                fsize_str = '';
                unit_str  = '';
            elseif fsize < 1024
                fsize_str = num2str(fsize);
                unit_str  = 'bytes';
            elseif fsize < 99*1024^2
                fsize_str = num2str(round(fsize/1024));
                unit_str  = 'KB';
            else
                fsize_str = num2str(roundn(fsize/1024/1024,-2));
                unit_str  = 'MB';
            end
            set(handles.(datalist{n}),'String',fsize_str);
            set(handles.bytes_txt,'String',unit_str);
        else
            set(handles.(datalist{n}),'String',fdata.(datalist{n}));
        end
    end
end

if isfield(fdata,'fpath') && sum(get(handles.fpath,'Extent').*[0 0 1 0]) > 154
    set(handles.fpath,'TooltipString',fdata.fpath);
end
if isfield(fdata,'fname') && sum(get(handles.fname,'Extent').*[0 0 1 0]) > 154
    set(handles.fname,'TooltipString',fdata.fname);
end

uiwait(handles.window);

% ---------------------------------------------------------------------
function varargout = RDAT_Properties_OutputFcn(hObject, eventdata, handles) 
% Funçao de saida

if handles.ok
    
    infolist = handles.infolist;
    
    for n = 1:length(infolist)
        switch get(handles.(infolist{n}),'Style')
            case 'popupmenu'
                strlist = cellstr(get(handles.(infolist{n}),'String'));
                properties.(infolist{n}) = strlist{get(handles.(infolist{n}),'Value')};
            case 'edit'
                properties.(infolist{n}) = get(handles.(infolist{n}),'String');
        end
    end
    
    varargout{1} = properties;
    varargout{2} = handles.clearopt;
else
    varargout{1} = [];
    varargout{2} = [];
end

delete(handles.window);

% --------------------------------------------------------------------
function clear_btn_Callback(hObject, eventdata, handles)
% Limpa todos os campos

button = questdlg('Deseja limpar todos os campos?','Confirmação','Sim','Não','Não'); drawnow;

if strcmp(button,'Sim')
    infolist = handles.infolist;
    for n = 1:length(infolist)
        if isfield(handles,infolist{n})
            switch get(handles.(infolist{n}),'Style')
                case 'popupmenu'
                    set(handles.(infolist{n}),'Value',1);
                case 'edit'
                    set(handles.(infolist{n}),'String','');
            end
        end
    end
    handles.chg = 1;
    guidata(hObject, handles);
end

% -------------------------------------------------------------------
function help_btn_Callback(hObject, eventdata, handles)
% Botao Ajuda

helpme('Arquivo\propriedades');

% ---------------------------------------------------------------------
function ok_btn_Callback(hObject, eventdata, handles)
% Botao OK

if handles.chg
    button = questdlg('Deseja confirmar as alterações?','Confirmação','Sim','Não','Sim'); drawnow;
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
    button = questdlg('Deseja descartar as alterações?','Confirmação','Sim','Não','Não'); drawnow;
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
    
    case 13 % Enter
        ok_btn_Callback(hObject, eventdata, handles);
        
    case 27 % Esc
        cancel_btn_Callback(hObject, eventdata, handles);
        
    case {abs('l'),abs('L')} % Novo
        clear_btn_Callback(hObject, eventdata, handles);
        
end

% ---------------------------------------------------------------------
function window_CloseRequestFcn(hObject, eventdata, handles)
% Funçao de fechamento da janela

cancel_btn_Callback(hObject, eventdata, handles);

% --------------------------------------------------------------------
function mission_Callback(hObject, eventdata, handles)
% Descriçao do voo

handles.chg = 1;
guidata(hObject, handles);

% --------------------------------------------------------------------
function crew_Callback(hObject, eventdata, handles)

str = cellstr(get(handles.crew,'String'));
if length(str) > 2
    uiwait(warndlg('O campo ''Tripulação'' suporta apenas duas linhas de texto.','Aviso','modal')); drawnow;
    set(handles.crew,'String',str(1:2));
end
handles.chg = 1;
guidata(hObject, handles);

% --------------------------------------------------------------------
function date_Callback(hObject, eventdata, handles)
% Data do voo

dat = dateread(get(handles.date,'String'));
if isempty(dat)
    set(handles.date,'String','');
else
    set(handles.date,'String',dat);
end

handles.chg = 1;
guidata(hObject, handles);

% --------------------------------------------------------------------
function time_Callback(hObject, eventdata, handles)
% Hora da decolagem

[t, str] = str2time(get(handles.time,'String'));
if ~isnan(str)
    set(handles.time,'String',str(1:end-3));
else
    set(handles.time,'String','');
end
handles.chg = 1;
guidata(hObject, handles);

% --------------------------------------------------------------------
function flighttime_Callback(hObject, eventdata, handles)
% Tempo de voo

[t, str] = str2time(get(handles.flighttime,'String'));
if ~isnan(str)
    set(handles.flighttime,'String',str(1:end-3));
else
    set(handles.flighttime,'String','');
end
handles.chg = 1;
guidata(hObject, handles);

% --------------------------------------------------------------------
function number_Callback(hObject, eventdata, handles)
% Numero do voo

handles.chg = 1;
guidata(hObject, handles);

% --------------------------------------------------------------------
function aircraft_Callback(hObject, eventdata, handles)
% Tipo da aeronave

handles.chg = 1;
guidata(hObject, handles);

% --------------------------------------------------------------------
function tailnumber_Callback(hObject, eventdata, handles)
% Matricula da aeronave

handles.chg = 1;
guidata(hObject, handles);

% --------------------------------------------------------------------
function unit_Callback(hObject, eventdata, handles)
% Unidade da aeronave

handles.chg = 1;
guidata(hObject, handles);

% --------------------------------------------------------------------
function inventory_Callback(hObject, eventdata, handles)
% Configuraçao da aeronave

handles.chg = 1;
guidata(hObject, handles);

% --------------------------------------------------------------------
function operation_Callback(hObject, eventdata, handles)
% Nome da Operaçao ou Campanha

handles.chg = 1;
guidata(hObject, handles);

% --------------------------------------------------------------------
function location_Callback(hObject, eventdata, handles)
% Localidade

handles.chg = 1;
guidata(hObject, handles);

% --------------------------------------------------------------------
function security_Callback(hObject, eventdata, handles)
% Grau de sigilo

handles.chg = 1;
guidata(hObject, handles);

% --------------------------------------------------------------------
function remarks_Callback(hObject, eventdata, handles)
% Observaçoes

handles.chg = 1;
guidata(hObject, handles);

% --------------------------------------------------------------------
function responsible_Callback(hObject, eventdata, handles)
% Responsavel

handles.chg = 1;
guidata(hObject, handles);

% --------------------------------------------------------------------
function clearreftime_btn_Callback(hObject, eventdata, handles)
% Limpar tempo de referencia

str = get(handles.reftime,'String');

if isempty(str)
    return
end

if ~isempty(get(handles.events,'String')) || ~isempty(get(handles.testpts,'String'))
    beep; uiwait(errordlg({'Não é possível excluir o tempo de referência.',...
            'Há eventos e/ou pontos de ensaio definidos.'},'Erro','modal')); drawnow;
    return
end

button = questdlg('Deseja excluir o tempo de referência?','Confirmação','Sim','Não','Não'); drawnow;

if strcmp(button,'Sim')
    set(handles.reftime,'String','','HorizontalAlignment','center');
    handles.clearopt(3) = 1;
    handles.chg = 1;
    guidata(hObject, handles);
end

% --------------------------------------------------------------------
function clearevents_btn_Callback(hObject, eventdata, handles)
% Limpar eventos

str = get(handles.events,'String');

if isempty(str)
    return
end

button = questdlg('Deseja limpar toda a lista de eventos?','Confirmação','Sim','Não','Não'); drawnow;

if strcmp(button,'Sim')
    set(handles.events,'String','');
    handles.clearopt(1) = 1;
    handles.chg = 1;
    guidata(hObject, handles);
end

% --------------------------------------------------------------------
function cleartestpts_btn_Callback(hObject, eventdata, handles)
% Limpar pontos de ensaio

str = get(handles.testpts,'String');

if isempty(str)
    return
end

button = questdlg('Deseja limpar toda a lista de pontos de ensaio?','Confirmação','Sim','Não','Não'); drawnow;

if strcmp(button,'Sim')
    set(handles.testpts,'String','');
    handles.clearopt(2) = 1;
    handles.chg = 1;
    guidata(hObject, handles);
end

% --------------------------------------------------------------------
function clearsetup_btn_Callback(hObject, eventdata, handles)
% Limpar configuraçao de parametros

str = get(handles.setup,'String');

if isempty(str)
    return
end

button = questdlg('Deseja limpar toda a configuração de parâmetros?','Confirmação','Sim','Não','Não'); drawnow;

if strcmp(button,'Sim')
    set(handles.setup,'String','');
    handles.clearopt(4) = 1;
    handles.chg = 1;
    guidata(hObject, handles);
end

% --------------------------------------------------------------------
function clearscenario_btn_Callback(hObject, eventdata, handles)
% Limpar cenario

str = get(handles.scenario,'String');

if isempty(str)
    return
end

button = questdlg('Deseja limpar todo o cenário?','Confirmação','Sim','Não','Não'); drawnow;

if strcmp(button,'Sim')
    set(handles.scenario,'String','');
    handles.clearopt(5) = 1;
    handles.chg = 1;
    guidata(hObject, handles);
end
