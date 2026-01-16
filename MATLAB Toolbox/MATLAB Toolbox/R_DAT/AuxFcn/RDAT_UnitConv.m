function varargout = RDAT_UnitConv(varargin)
% RDAT_UNITCONV M-file for RDAT_UnitConv.fig
% Last Modified by GUIDE v2.5 07-Dec-2010 12:53:15

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RDAT_UnitConv_OpeningFcn, ...
                   'gui_OutputFcn',  @RDAT_UnitConv_OutputFcn, ...
                   'gui_LayoutFcn',  @RDAT_UnitConv_LayoutFcn, ...
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
function h = RDAT_UnitConv_LayoutFcn(varargin)
% Função de layout inicial

h = openfig('RDAT_UnitConv.fig','reuse','invisible');

% -------------------------------------------------------------------------
function RDAT_UnitConv_OpeningFcn(hObject, eventdata, handles, varargin)

scrsz = get(0,'ScreenSize');
winsz = get(handles.window,'Position');
set(handles.window,'Position',[.5*(scrsz(3)-winsz(3)) .5*(scrsz(4)-winsz(4)) winsz(3) winsz(4)],'Visible','on');
handles.ok = 0;

bgc = getbuttoncolor(handles.window);
set(handles.help_btn,'CData',geticon('DatButtons.mat','help',bgc));

if nargin >= 4
    handles.PARAM = cellstr(varargin{1});
else
    handles.PARAM = {''};
end
if nargin >= 5
    handles.maxparamlength = varargin{2};
else
    handles.maxparamlength = 48;
end

handles.names = [handles.name1 handles.name2 handles.name3 handles.name4 handles.name5 handles.name6 handles.name7 handles.name8];

[typelist, handles.convlist] = getconvlist;
set(handles.dim_sel,'String',typelist,'Value',1);
set(handles.opt_sel,'String',{'Novos parâmetros','Substituir atuais'},'Value',1);
set([handles.from_sel handles.to_sel],'String',handles.convlist{1}(:,1),'Value',1);

set(handles.paramlist,'String',handles.PARAM,'Value',[]);
paramlist_Callback(hObject, eventdata, handles);

guidata(hObject, handles);
uiwait(handles.window);

% -------------------------------------------------------------------------
function varargout = RDAT_UnitConv_OutputFcn(hObject, eventdata, handles)
global DADOS
% Função de saída

if handles.ok    
    
    PARAM = handles.PARAM;
    ntype = get(handles.dim_sel ,'Value');
    nu1   = get(handles.from_sel,'Value');
    nu2   = get(handles.to_sel  ,'Value');
    
    k1 = handles.convlist{ntype}{nu1,2};
    k2 = handles.convlist{ntype}{nu2,2};
    b1 = handles.convlist{ntype}{nu1,3};
    b2 = handles.convlist{ntype}{nu2,3};
    
    Nin  = get(handles.paramlist,'Value');
    
    if get(handles.opt_sel,'Value') == 1 % Novos
        
        Nout = size(DADOS,2) : size(DADOS,2)-1+length(Nin);
    
        for n = 1:length(Nin)
            newname = get(handles.names(n),'String');
            PARAM = InsertParam(PARAM,newname);
            DADOS(:,Nout(n)) = (k1*DADOS(:,Nin(n)) + b1 - b2 ) / k2;
        end
        DADOS(:,Nout(n)+1) = (1:size(DADOS,1))';
        
    else % Substituir
        
        Nout = Nin;
        
        for n = 1:length(Nin)
            newname = get(handles.names(n),'String');
            PARAM{Nin(n)} = strrep(PARAM{Nin(n)}, denumber(PARAM{Nin(n)}), newname);
            DADOS(:,Nout(n)) = (k1*DADOS(:,Nin(n)) + b1 - b2 ) / k2;
        end
        
    end
    
    varargout{1} = PARAM;
    varargout{2} = Nout;
else
    varargout{1} = [];
    varargout{2} = [];
end
delete(handles.window);

% -------------------------------------------------------------------
function help_btn_Callback(hObject, eventdata, handles)
% Botao Ajuda

helpme('Funcoes\convunidades','grupo');

% -------------------------------------------------------------------
function ok_btn_Callback(hObject, eventdata, handles)

N = get(handles.paramlist,'Value');
if isempty(N)
    beep; uiwait(errordlg('Não há parâmetros selecionados.','Erro','modal'));
    return
end
if N(end) == length(handles.PARAM)
    beep; uiwait(errordlg('O parâmetro ''No. OBS.'' não pode ser alterado.','Erro','modal'));
    return
end
for n = 1:length(N)
    if isempty(deblank(get(handles.names(n),'String')))
        beep; uiwait(errordlg('O nome do parâmetro não pode ser vazio.','Erro','modal'));
        return
    end
end

if get(handles.opt_sel,'Value') == 1
    button = questdlg({'Deseja confirmar a operação','e criar novos parâmetros?'},'Confirmação','Sim','Não','Não');
else
    button = questdlg({'Deseja confirmar a operação?','Os dados originais serão perdidos!'},'Confirmação','Sim','Não','Não');
end

if strcmp(button,'Sim')
    handles.ok = 1;
    guidata(hObject, handles);
    uiresume;
end

% -------------------------------------------------------------------
function cancel_btn_Callback(hObject, eventdata, handles)

button = questdlg('Deseja cancelar a operação?','Confirmação','Sim','Não','Não');
if strcmp(button,'Sim')
    uiresume;
end

%--------------------------------------------------------------------------
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
        window_CloseRequestFcn(hObject, eventdata, handles);
        
end

% -------------------------------------------------------------------------
function window_CloseRequestFcn(hObject, eventdata, handles)
cancel_btn_Callback(hObject, eventdata, handles);

% -------------------------------------------------------------------------
function setname(hObject, eventdata, handles, n)

if nargin == 3
    n = 1:length(handles.names);
end

for n = n
    name = TrimParamName(get(handles.names(n),'String'),handles.maxparamlength);
    set(handles.names(n),'String',name);
end

% -------------------------------------------------------------------------
function paramlist_Callback(hObject, eventdata, handles)

n = get(handles.paramlist,'Value');
nmax = length(handles.names);

if length(n) > nmax
    beep;
    n(nmax+1:end) = [];
    set(handles.paramlist,'Value',n);
end

ntype = get(handles.dim_sel ,'Value');
nu1   = get(handles.from_sel,'Value');
nu2   = get(handles.to_sel  ,'Value');

unit1 = handles.convlist{ntype}{nu1,1};
unit2 = handles.convlist{ntype}{nu2,1};

for ni = 1:length(n)
    
    newname = unitrep(denumber(handles.PARAM{n(ni)}),unit1,unit2);
    
    set(handles.names(ni),'String',newname,'Enable','on','BackgroundColor','w');
end

if length(n) < nmax
    set(handles.names(length(n)+1:nmax),'String','','Enable','off','BackgroundColor',get(handles.window,'Color'));
end

setname(hObject, eventdata, handles);

% -------------------------------------------------------------------------
function dim_sel_Callback(hObject, eventdata, handles)

ntype = get(handles.dim_sel,'Value');
set([handles.from_sel handles.to_sel],'String',handles.convlist{ntype}(:,1),'Value',1);
paramlist_Callback(hObject, eventdata, handles);

% -------------------------------------------------------------------------
function from_sel_Callback(hObject, eventdata, handles)
paramlist_Callback(hObject, eventdata, handles);

% -------------------------------------------------------------------------
function to_sel_Callback(hObject, eventdata, handles)
paramlist_Callback(hObject, eventdata, handles);

% -------------------------------------------------------------------------
function opt_sel_Callback(hObject, eventdata, handles)

if get(handles.opt_sel,'Value') == 1
    set(handles.names_txt,'String','Nomes');
else
    set(handles.names_txt,'String','Novos nomes');
end
