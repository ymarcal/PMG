function varargout = RDAT_ParamSel(varargin)
% RDAT_PARAMSEL M-file for RDAT_ParamSel.fig
% Last Modified by GUIDE v2.5 30-Apr-2011 11:20:24

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RDAT_ParamSel_OpeningFcn, ...
                   'gui_OutputFcn',  @RDAT_ParamSel_OutputFcn, ...
                   'gui_LayoutFcn',  @RDAT_ParamSel_LayoutFcn, ...
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
function h = RDAT_ParamSel_LayoutFcn(varargin)
% Função de layout inicial

h = openfig('RDAT_ParamSel.fig','reuse','invisible');

% -------------------------------------------------------------------------
function RDAT_ParamSel_OpeningFcn(hObject, eventdata, handles, varargin)
% Funçao de inicializaçao

bgc = getbuttoncolor(handles.window);
set(handles.up_btn   ,'CData', geticon('DatButtons.mat', 'arrow'  , bgc, 1    ) );
set(handles.down_btn ,'CData', geticon('DatButtons.mat', 'arrow'  , bgc, 3, 1 ) );
set(handles.exc_btn  ,'CData', geticon('DatButtons.mat', 'excluir', bgc       ) );
set(handles.inc_btn  ,'CData', geticon('DatButtons.mat', 'incluir', bgc       ) );
set(handles.sort_btn ,'CData', geticon('DatButtons.mat', 'sort'   , bgc       ) );
set(handles.help_btn ,'CData', geticon('DatButtons.mat','help'    , bgc       ) );

scrsz = get(0,'ScreenSize');
winsz = get(handles.window,'Position');
set(handles.window,'Position',[.5*(scrsz(3)-winsz(3)) .5*(scrsz(4)-winsz(4)) winsz(3) winsz(4)],'Visible','on');
handles.ok = 0;

if     nargin == 5
    handles.PARAM = char(varargin{1});
    index = varargin{2};
elseif nargin == 4
    handles.PARAM = char(varargin{1});
    index = (1:size(handles.PARAM,1))';
else
    handles.PARAM = ' ';
    index = 1;
end

index = index(:);
allparam = (1:size(handles.PARAM,1))';

handles.index    = index;
handles.iniindex = handles.index;
handles.outdex   = setdiff(allparam,index);

set(handles.included,'String',handles.PARAM(handles.index ,:));
set(handles.excluded,'String',handles.PARAM(handles.outdex,:));

set(handles.nin_txt, 'String',num2str(length(handles.index)));
set(handles.nout_txt,'String',num2str(length(handles.outdex)));

guidata(hObject, handles);
uiwait(handles.window);

% -------------------------------------------------------------------------
function varargout = RDAT_ParamSel_OutputFcn(hObject, eventdata, handles)
% Funçao de saida

if handles.ok
    varargout{1} = handles.index;    
else
    varargout{1} = [];
end
delete(handles.window);

% -------------------------------------------------------------------------
function inc_btn_Callback(hObject, eventdata, handles)
% Inclui parametros selecionados

Nout = get(handles.excluded,'Value');
if ~isempty(handles.outdex)
    handles.index = [handles.index; handles.outdex(Nout)];
    handles.outdex(Nout) = [];
    guidata(hObject, handles);
    
    set(handles.excluded,'Value',max(1,min(length(handles.outdex),Nout(1))),'String',handles.PARAM(handles.outdex,:));
    set(handles.included,'String',handles.PARAM(handles.index,:));
    
    set(handles.nin_txt, 'String',num2str(length(handles.index)));
    set(handles.nout_txt,'String',num2str(length(handles.outdex)));
else
    beep;
end

% -------------------------------------------------------------------------
function exc_btn_Callback(hObject, eventdata, handles)
% Exclui parametros selecionados

Nin = get(handles.included,'Value');
if ~isempty(Nin) && ~isempty(handles.index)
    handles.outdex = sort([handles.outdex; handles.index(Nin)]);
    handles.index(Nin) = [];
    guidata(hObject, handles);
    
    set(handles.included,'Value',max(1,min(length(handles.index),Nin(1))),'String',handles.PARAM(handles.index,:));
    set(handles.excluded,'String',handles.PARAM(handles.outdex,:));
    
    set(handles.nin_txt, 'String',num2str(length(handles.index)));
    set(handles.nout_txt,'String',num2str(length(handles.outdex)));
else
    beep;
end

% -------------------------------------------------------------------------
function incall_btn_Callback(hObject, eventdata, handles)
% Incluir todos os parametros

if ~isempty(handles.outdex)
    handles.index = [handles.index; handles.outdex];
    handles.outdex = [];
    guidata(hObject, handles);
    
    set(handles.excluded,'Value',1,'String','');
    set(handles.included,'String',handles.PARAM(handles.index,:));
    
    set(handles.nin_txt, 'String',num2str(length(handles.index)));
    set(handles.nout_txt,'String',num2str(length(handles.outdex)));
else
    beep;
end

% -------------------------------------------------------------------------
function excall_btn_Callback(hObject, eventdata, handles)
% Excluir todos os parametros

if ~isempty(handles.index)
    handles.outdex = sort([handles.outdex; handles.index]);
    handles.index = [];
    guidata(hObject, handles);
    
    set(handles.included,'Value',1,'String','');
    set(handles.excluded,'String',handles.PARAM(handles.outdex,:));
    
    set(handles.nin_txt, 'String',num2str(length(handles.index)));
    set(handles.nout_txt,'String',num2str(length(handles.outdex)));
else
    beep;
end

% -------------------------------------------------------------------------
function up_btn_Callback(hObject, eventdata, handles)
% Move parametros selecionados para cima

Nin = get(handles.included,'Value');
if ~isempty(handles.index) && ~isempty(Nin) && min(Nin) > 1
    for n = 1:length(Nin)
        aux = handles.index(Nin(n)-1);
        handles.index(Nin(n)-1) = handles.index(Nin(n));
        handles.index(Nin(n))   = aux;
    end
    guidata(hObject, handles);
    set(handles.included,'String',handles.PARAM(handles.index,:),'Value',Nin-1);
else
    beep;
end

% -------------------------------------------------------------------------
function down_btn_Callback(hObject, eventdata, handles)
% Move parametros selecionados para baixo

Nin = get(handles.included,'Value');
if ~isempty(handles.index) && ~isempty(Nin) && max(Nin) < length(handles.index)
    for n = length(Nin):-1:1
        aux = handles.index(Nin(n)+1);
        handles.index(Nin(n)+1) = handles.index(Nin(n));
        handles.index(Nin(n))   = aux;
    end
    guidata(hObject, handles);
    set(handles.included,'String',handles.PARAM(handles.index,:),'Value',Nin+1);
else
    beep;
end

% -------------------------------------------------------------------------
function sort_btn_Callback(hObject, eventdata, handles)
% Ordena lista de parametros

if isempty(handles.index)
    beep;
    return
end

if any(diff(handles.index)<0)
    button = questdlg('Deseja reordenar todos os parâmetros?','Confirmação','Sim','Não','Não');
    if strcmp(button,'Sim')
        handles.index = sort(handles.index);
        guidata(hObject, handles);
        
        set(handles.included,'String',handles.PARAM(handles.index,:));
    end
else
    warndlg('Os parâmetros já estão em ordem.','Aviso','modal');
end

% -------------------------------------------------------------------
function help_btn_Callback(hObject, eventdata, handles)
% Botao Ajuda

helpme('Ferramentas\seletordeparam');

% -------------------------------------------------------------------
function ok_btn_Callback(hObject, eventdata, handles)
% Botao OK

if isempty(handles.index)
    beep; uiwait(errordlg('Não é possível excluir todos os parâmetros.','Erro','modal'));
    return
end

if isequal(handles.index,handles.iniindex)
    button = questdlg({'Nenhuma alteração efetuada.','Deseja sair do seletor de parâmetros?'},'Confirmação','Sim','Não','Não');
    if strcmp(button,'Sim')
        uiresume;
    end
else
    button = questdlg('Deseja confirmar a operação?','Confirmação','Sim','Não','Não');
    if strcmp(button,'Sim')
        handles.ok = 1;
        guidata(hObject, handles);
        uiresume;            
    end
end

% -------------------------------------------------------------------
function cancel_btn_Callback(hObject, eventdata, handles)
% Botao Cancela

if isequal(handles.index,handles.iniindex)
    button = 'Sim';
else
    button = questdlg('Deseja cancelar a operação?','Confirmação','Sim','Não','Não');
end
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
    
    case 28 % <--
        inc_btn_Callback(hObject, eventdata, handles);
        
    case 29 % -->
        exc_btn_Callback(hObject, eventdata, handles);
        
    case 30 % Up
        up_btn_Callback(hObject, eventdata, handles);
        
    case 31 % Down
        down_btn_Callback(hObject, eventdata, handles);
        
    case {abs('o'),abs('O')}
        sort_btn_Callback(hObject, eventdata, handles);
        
    case 13 % Enter
        ok_btn_Callback(hObject, eventdata, handles);
        
    case 27 % Esc
        cancel_btn_Callback(hObject, eventdata, handles);
        
end

% -------------------------------------------------------------------------
function window_CloseRequestFcn(hObject, eventdata, handles)
% Funçao de fechamento da janela

cancel_btn_Callback(hObject, eventdata, handles);
