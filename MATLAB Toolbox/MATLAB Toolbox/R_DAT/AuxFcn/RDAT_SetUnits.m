function varargout = RDAT_SetUnits(varargin)
% RDAT_SETUNITS M-file for RDAT_SetUnits.fig
% Last Modified by GUIDE v2.5 07-Dec-2010 11:02:23

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RDAT_SetUnits_OpeningFcn, ...
                   'gui_OutputFcn',  @RDAT_SetUnits_OutputFcn, ...
                   'gui_LayoutFcn',  @RDAT_SetUnits_LayoutFcn, ...
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

% --------------------------------------------------------------------------------------------------
function h = RDAT_SetUnits_LayoutFcn(varargin)
% Função de layout inicial

h = openfig('RDAT_SetUnits.fig','reuse','invisible');

% -------------------------------------------------------------------------
function RDAT_SetUnits_OpeningFcn(hObject, eventdata, handles, varargin)
% Funçao de inicializaçao

scrsz = get(0,'ScreenSize');
winsz = get(handles.window,'Position');
set(handles.window,'Position',[.5*(scrsz(3)-winsz(3)) .5*(scrsz(4)-winsz(4)) winsz(3) winsz(4)],'Visible','on');

bgc = getbuttoncolor(handles.window);
set(handles.Nalt,'BackgroundColor',get(handles.window,'Color'));
set(handles.savelist_btn,'CData',geticon('DatButtons.mat','save',bgc));
set(handles.help_btn,    'CData',geticon('DatButtons.mat','help',bgc));
set([handles.addstd_btn handles.addalt_btn],  'CData',geticon('DatButtons.mat','add_s', bgc));
set([handles.remstd_btn handles.remalt_btn],  'CData',geticon('DatButtons.mat','rem_s', bgc));
set([handles.editstd_btn handles.editalt_btn],'CData',geticon('DatButtons.mat','edit_s',bgc));

if isempty(varargin)
    PARAM = {' '};
else
    PARAM = cellstr(varargin{1});
end
set(handles.originalPARAM,'String',PARAM,'Value',[]);
set(handles.alteredPARAM, 'String',PARAM,'Value',[]);

load(which('DatUnits.mat'),'datunits');
handles.datunits = datunits;
set(handles.stdunitslist,'String',{datunits.std},'Value',1);
set(handles.altunitslist,'String',datunits(1).alt);
handles.ignore = zeros(length({datunits.std}),1);

handles.ok = 0;
guidata(hObject, handles);
updt(hObject, eventdata, handles);
uiwait(handles.window);

% -------------------------------------------------------------------------
function varargout = RDAT_SetUnits_OutputFcn(hObject, eventdata, handles)
% Funçao de saida

if handles.ok
    varargout{1} = get(handles.alteredPARAM,'String');
else
    varargout{1} = [];
end
delete(handles.window);

% -------------------------------------------------------------------------
function originalPARAM_ButtonDownFcn(hObject, eventdata, handles)
% Clicar na lista original

n = get(handles.originalPARAM,'ListBoxTop');
set(handles.alteredPARAM,'ListBoxTop',n);

% -------------------------------------------------------------------------
function alteredPARAM_ButtonDownFcn(hObject, eventdata, handles)
% Clicar na lista alterada

n = get(handles.alteredPARAM,'ListBoxTop');
set(handles.originalPARAM,'ListBoxTop',n);

% -------------------------------------------------------------------------
function stdunitslist_Callback(hObject, eventdata, handles)
% Clicar na lista de unidades padronizadas

ns = get(handles.stdunitslist,'Value');
if isempty(handles.datunits(ns).alt);
    val = [];
else
    val = 1;
end
set(handles.altunitslist,'String',handles.datunits(ns).alt,'Value',val);
set(handles.ignore_chk,'Value',handles.ignore(ns));

% -------------------------------------------------------------------------
function addstd_btn_Callback(hObject, eventdata, handles)
% Adicionar unidade padronizada

unit = '';
while ischar(unit) && isempty(unit)
    unit = inputvalue('Adicionar','Unidade padrão:','',1,1.1);
    unit = fliplr(deblank(fliplr(deblank(unit))));
end
if ischar(unit)
    if length(unit) > 20
        unit(21:end) = [];
    end
    Ns = size({handles.datunits.std},2);
    handles.datunits(Ns+1).std = unit;
    handles.ignore(Ns+1) = 0;
    set(handles.stdunitslist,'String',{handles.datunits.std},'Value',Ns+1);
    set(handles.ignore_chk,'Value',0);
    guidata(hObject, handles);
    stdunitslist_Callback(hObject, eventdata, handles);
    updt(hObject, eventdata, handles);
end

% -------------------------------------------------------------------------
function remstd_btn_Callback(hObject, eventdata, handles)
% Remover unidade padronizada

Ns = size({handles.datunits.std},2);
ns = get(handles.stdunitslist,'Value');
if strcmp(handles.datunits(ns).std,'[ ]')
    beep; uiwait(errordlg('A opção "sem unidade" não pode ser removida.','Erro','modal'));
else
    ns = get(handles.stdunitslist,'Value');
    button = questdlg(['Deseja remover a unidade ''' handles.datunits(ns).std '''?'],'Confirmação','Sim','Não','Não');
    if strcmp(button,'Sim')
        handles.datunits(ns) = [];
        handles.ignore(ns) = [];
        if ns == Ns
            ns = ns-1;
        end
        set(handles.stdunitslist,'String',{handles.datunits.std},'Value',ns);
        set(handles.ignore_chk,'Value',handles.ignore(ns));
        guidata(hObject, handles);
        stdunitslist_Callback(hObject, eventdata, handles);
        updt(hObject, eventdata, handles);
    end
end
    
% -------------------------------------------------------------------------
function editstd_btn_Callback(hObject, eventdata, handles)
% Editar unidade padronizada

ns = get(handles.stdunitslist,'Value');
if strcmp(handles.datunits(ns).std,'[ ]')
    beep; uiwait(errordlg('A opção "sem unidade" não pode ser alterada.','Erro','modal'));
    return
end
unit = inputvalue('Alterar','Unidade padrão:',handles.datunits(ns).std,1,1.1);
unit = fliplr(deblank(fliplr(deblank(unit))));
while ischar(unit) && isempty(unit)
    unit = inputvalue('Alterar','Unidade padrão:',unit,1,1.1);
    unit = fliplr(deblank(fliplr(deblank(unit))));
end
if ischar(unit)
    if length(unit) > 20
        unit(21:end) = [];
    end
    handles.datunits(ns).std = unit;
    set(handles.stdunitslist,'String',{handles.datunits.std});
    guidata(hObject, handles);
    updt(hObject, eventdata, handles);
end

% -------------------------------------------------------------------------
function ignore_chk_Callback(hObject, eventdata, handles)
% Ignorar alteraçao selecionada

ns = get(handles.stdunitslist,'Value');
chk = get(handles.ignore_chk,'Value');
if chk
    handles.ignore(ns) = 1;
else
    handles.ignore(ns) = 0;
end
guidata(hObject, handles);

updt(hObject, eventdata, handles);

% -------------------------------------------------------------------------
function addalt_btn_Callback(hObject, eventdata, handles)
% Adicionar nome alternativo

ns = get(handles.stdunitslist,'Value');
alt = '';
while ischar(alt) && isempty(alt)
    alt = inputvalue('Adicionar',['Nome alternativo para ' handles.datunits(ns).std ':'],'',1,1.1);
    alt = fliplr(deblank(fliplr(deblank(alt))));
end
if ischar(alt)
    if length(alt) > 20
        alt(21:end) = [];
    end
    Na = length(handles.datunits(ns).alt);
    handles.datunits(ns).alt{Na+1} = alt;
    guidata(hObject, handles);
    stdunitslist_Callback(hObject, eventdata, handles);
    set(handles.altunitslist,'Value',Na+1);
    updt(hObject, eventdata, handles);
end

% -------------------------------------------------------------------------
function remalt_btn_Callback(hObject, eventdata, handles)
% Remover nome alternativo

ns = get(handles.stdunitslist,'Value');
Na = length(handles.datunits(ns).alt);
if     Na == 0
    beep;
elseif Na == 1
    beep; uiwait(errordlg('A lista não pode ser vazia.','Erro','modal'));
else
    na = get(handles.altunitslist,'Value');
    button = questdlg(['Deseja remover o nome alternativo ''' handles.datunits(ns).alt{na} '''?'],'Confirmação','Sim','Não','Não');
    if strcmp(button,'Sim')
        handles.datunits(ns).alt(na) = [];
        if na == Na
            na = na-1;
        end
        set(handles.altunitslist,'String',handles.datunits(ns).alt,'Value',na);
        guidata(hObject, handles);
        updt(hObject, eventdata, handles);
    end
end

% -------------------------------------------------------------------------
function editalt_btn_Callback(hObject, eventdata, handles)
% Editar nome alternativo

ns = get(handles.stdunitslist,'Value');
if isempty(handles.datunits(ns).alt)
    beep;
else
    na = get(handles.altunitslist,'Value');
    alt = inputvalue('Alterar','Nome alternativo:',handles.datunits(ns).alt{na},1,1.1);
    alt = fliplr(deblank(fliplr(deblank(alt))));
    while ischar(alt) && isempty(alt)
        alt = inputvalue('Alterar','Nome alternativo:',alt,1,1.1);
        alt = fliplr(deblank(fliplr(deblank(alt))));
    end
    if ischar(alt)
        if length(alt) > 20
            alt(21:end) = [];
        end
        handles.datunits(ns).alt{na} = alt;
        set(handles.altunitslist,'String',handles.datunits(ns).alt);
        guidata(hObject, handles);
        updt(hObject, eventdata, handles);
    end
end

% -------------------------------------------------------------------------
function savelist_btn_Callback(hObject, eventdata, handles)
% Salvar listas de nomes de unidades

button = savedlg('Deseja salvar lista de unidades?','Confirmação','Sim','Não','Sim');
if strcmp(button,'Sim')
    datunits = handles.datunits;
    [void,ind] = sort(lower({datunits.std}));
    datunits = datunits(ind);
    for ns = 1:size({datunits.std},2);
        datunits(ns).alt = sort(datunits(ns).alt);
    end
    try
        save(which('DatUnits.mat'),'datunits',saveopt);
    catch
        beep; uiwait(errordlg(lasterr,'Erro','modal')); drawnow;
        return
    end
end

% -------------------------------------------------------------------
function help_btn_Callback(hObject, eventdata, handles)
% Botao Ajuda

helpme('Ferramentas\padronizacaounid');

% -------------------------------------------------------------------------
function ok_Callback(hObject, eventdata, handles)
% Botao OK

button = questdlg('Deseja confirmar as alterações?','Confirmação','Sim','Não','Não');
if strcmp(button,'Sim')
    handles.ok = 1;
    guidata(hObject, handles);
    uiresume;
end

% -------------------------------------------------------------------------
function cancel_Callback(hObject, eventdata, handles)
% Botao Cancela

button = questdlg('Deseja cancelar a operação?','Confirmação','Sim','Não','Não');
if strcmp(button,'Sim')
    uiresume;
end

% -------------------------------------------------------------------------
function window_KeyPressFcn(hObject, eventdata, handles)
% Acionamento de tecla do teclado

cc = get(handles.window,'CurrentCharacter');

if isempty(cc)
    return
end

switch abs(cc)
    
    case {abs('s'),abs('S')}
        savelist_btn_Callback(hObject, eventdata, handles);
        
    case 13 % Enter
        ok_Callback(hObject, eventdata, handles);
        
    case 27 % Esc
        cancel_Callback(hObject, eventdata, handles);
        
end

% -------------------------------------------------------------------------
function window_CloseRequestFcn(hObject, eventdata, handles)
% Funçao de fechamento da janela

cancel_Callback(hObject, eventdata, handles);

% -------------------------------------------------------------------------
function window_WindowButtonMotionFcn(hObject, eventdata, handles)
% Funçao de movimentaçao do cursor

n1 = get(handles.originalPARAM,'ListboxTop');
n2 = get(handles.alteredPARAM ,'ListboxTop');

if n1 ~= n2
    
    ws = get(handles.window,'Position');
    cp = get(handles.window,'CurrentPoint') + [.5 .5];
    
    if cp(1) < ws(3)/2+50
        set(handles.alteredPARAM ,'ListBoxTop',n1);
    else
        set(handles.originalPARAM,'ListBoxTop',n2);
    end
end

% -------------------------------------------------------------------------
function updt(hObject, eventdata, handles)
% Atualizar alteraçoes

PARAM = get(handles.originalPARAM,'String');

[PARAM, Nalt] = SetUnits(PARAM,handles.datunits,handles.ignore);

set(handles.alteredPARAM,'String',PARAM);
set(handles.Nalt,'String',num2str(Nalt));
