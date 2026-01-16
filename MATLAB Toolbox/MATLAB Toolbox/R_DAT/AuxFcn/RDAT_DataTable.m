function varargout = RDAT_DataTable(varargin)
% RDAT_DATATABLE M-file for RDAT_DataTable.fig
% Last Modified by GUIDE v2.5 16-Apr-2011 19:06:31

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RDAT_DataTable_OpeningFcn, ...
                   'gui_OutputFcn',  @RDAT_DataTable_OutputFcn, ...
                   'gui_LayoutFcn',  @RDAT_DataTable_LayoutFcn, ...
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
function h = RDAT_DataTable_LayoutFcn(varargin)
% Função de layout inicial

h = openfig('RDAT_DataTable.fig','reuse','invisible');

% ---------------------------------------------------------------
function RDAT_DataTable_OpeningFcn(hObject, eventdata, handles, varargin)
global DADOS
% Funçao de inicializaçao

bgc = getbuttoncolor(handles.window);
set(handles.undo,'CData',geticon('DatButtons.mat','undo',bgc));
set(handles.help_btn,'CData',geticon('DatButtons.mat','help',bgc));
set([handles.xvalue handles.yvalue],'BackgroundColor',get(handles.window,'Color'));

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
set(handles.window,'Position',[(ss(3)-ws(3))/2, (ss(4)-ws(4))/2-2, ws(3), ws(4)]);

if length(varargin) == 3
    PARAM = varargin{1};
    sel   = varargin{2};
    pos   = varargin{3}; % [xcol, ycol, n]
else
    beep; uiwait(errordlg('Dados não fornecidos.','Erro','modal'));
    handles.ok = 0;
    guidata(hObject, handles);
    uiresume;
    return
end

handles.params = [handles.param1 handles.param2 handles.param3 handles.param4 handles.param5 handles.param6];
handles.lines = [handles.line01 handles.line02 handles.line03 handles.line04 handles.line05 handles.line06 handles.line07 handles.line08,...
        handles.line09 handles.line10 handles.line11 handles.line12 handles.line13 handles.line14 handles.line15 handles.line16];
handles.sels = [handles.sel01 handles.sel02 handles.sel03 handles.sel04 handles.sel05 handles.sel06 handles.sel07 handles.sel08,...
        handles.sel09 handles.sel10 handles.sel11 handles.sel12 handles.sel13 handles.sel14 handles.sel15 handles.sel16];

handles.a = [handles.a011 handles.a012 handles.a013 handles.a014 handles.a015 handles.a016;...
        handles.a021 handles.a022 handles.a023 handles.a024 handles.a025 handles.a026;...
        handles.a031 handles.a032 handles.a033 handles.a034 handles.a035 handles.a036;...
        handles.a041 handles.a042 handles.a043 handles.a044 handles.a045 handles.a046;...
        handles.a051 handles.a052 handles.a053 handles.a054 handles.a055 handles.a056;...
        handles.a061 handles.a062 handles.a063 handles.a064 handles.a065 handles.a066;...
        handles.a071 handles.a072 handles.a073 handles.a074 handles.a075 handles.a076;...
        handles.a081 handles.a082 handles.a083 handles.a084 handles.a085 handles.a086;...
        handles.a091 handles.a092 handles.a093 handles.a094 handles.a095 handles.a096;...
        handles.a101 handles.a102 handles.a103 handles.a104 handles.a105 handles.a106;...
        handles.a111 handles.a112 handles.a113 handles.a114 handles.a115 handles.a116;...
        handles.a121 handles.a122 handles.a123 handles.a124 handles.a125 handles.a126;...
        handles.a131 handles.a132 handles.a133 handles.a134 handles.a135 handles.a136;...
        handles.a141 handles.a142 handles.a143 handles.a144 handles.a145 handles.a146;...
        handles.a151 handles.a152 handles.a153 handles.a154 handles.a155 handles.a156;...
        handles.a161 handles.a162 handles.a163 handles.a164 handles.a165 handles.a166 ];

selz = zeros(size(DADOS,1),1);
selz(sel) = 1;
sel = selz;

handles.PARAM = cellstr(PARAM);
handles.sel = sel;
handles.ok = 0;

handles.chg = {'Lin','Par','Anterior','','Alterado'};
set(handles.undolist,'String',' ','Value',[]);
set(handles.undo_hdr,'String',cell2str(handles.chg,6,1),'Value',1);

set(handles.ylist,'String',handles.PARAM,'Value',pos(2));
set(handles.xlist,'String',handles.PARAM,'Value',pos(1));

handles.plot1   = plot(NaN,NaN,'.-k','Color',[0 .8 0]);
handles.plot2   = plot(NaN,NaN,'.-b');
handles.selpts  = plot(NaN,NaN,'or','MarkerSize',5);
handles.auxline = plot(NaN,NaN,'Color',[.5 .5 .5]);
setappdata(handles.window,'xzoom',[]);

guidata(hObject, handles);

initialize(hObject, eventdata, handles, pos);
updatetable(hObject, eventdata, handles);
updateplot(hObject, eventdata, handles);

uiwait(handles.window);

% ---------------------------------------------------------------
function varargout = RDAT_DataTable_OutputFcn(hObject, eventdata, handles)
% Funçao de saida

if handles.ok
    varargout{1} = 1;
    varargout{2} = find(handles.sel);
else
    varargout{1} = 0;
    varargout{2} = [];
end
delete(handles.window);

% ---------------------------------------------------------------
function initialize(hObject, eventdata, handles, pos)
global DADOS
% Configuraçao inicial da tela

[N, M] = size(DADOS);

m1 = max(1,min(M-5,pos(2)));
n1 = max(1, N-15-pos(3)+1);
hmax = max(1+1e-6, M-5);
vmax = max(1+1e-6, N-15);

if M <= 6
    steph = [1 1e6];
    hen = 'off';
else
    steph = [1 2]/(M-6);
    hen = 'on';
end

if N <= 16
    stepv = [1 1e6];
    ven = 'off';
else
    stepv = [1 5]/(N-16);
    ven = 'on';
end

set(handles.Hslider,'Value',m1,'SliderStep',steph,'Min',1,'Max',hmax,'Enable',hen);
set(handles.Vslider,'Value',n1,'SliderStep',stepv,'Min',1,'Max',vmax,'Enable',ven);

if N < 16
    set(handles.lines(N+1:16),'String','');
    set(handles.sels(N+1:16),'Enable','off');
    set(handles.a(N+1:16,:),'Enable','off','BackgroundColor',get(handles.window,'Color'));
end
if M < 6
    set(handles.params(M+1:6),'String','');
    set(handles.a(:,M+1:6),'Enable','off','BackgroundColor',get(handles.window,'Color'));
end

%----------------------------------------------------------------
function updatetable(hObject, eventdata, handles)
global DADOS
% Atualizar tabela

[N, M] = size(DADOS);

n1 = max(1, N-get(handles.Vslider,'Value')-14);
m1 = max(1, get(handles.Hslider,'Value'));

for v = 1:min(16,N)
    for h = 1:min(6,M)
        if v == 1;
            set(handles.params(h),'String',handles.PARAM{m1+h-1},'TooltipString',handles.PARAM{m1+h-1});
        end
        set(handles.a(v,h),'String',num2str(DADOS(n1+v-1,m1+h-1),16));
    end
    set(handles.lines(v),'String',num2str(n1+v-1));
    set(handles.sels(v),'Value',handles.sel(n1+v-1));
end
if M <= 6
    set(handles.a(:,M),'Enable','inactive');
else
    if m1+5 == M
        set(handles.a(:,6),'Enable','inactive');
    else
        set(handles.a(:,6),'Enable','on');
    end
end

% ---------------------------------------------------------------
function updatedata(hObject, eventdata, handles)
global DADOS
% Atualizar dados numericamente

[N, M] = size(DADOS);

n1 = max(1,N-get(handles.Vslider,'Value')-14);
m1 = max(1,get(handles.Hslider,'Value'));

H = gcbo;
EntryFix(H,16,'NaN');
tag = get(H,'Tag');
v = str2num(tag(2:3));
h = str2num(tag(4));

n = n1+v-1;
m = m1+h-1;

newval = str2double(get(H,'String'));
oldval = DADOS(n,m);

if newval ~= oldval
    
    handles.chg = [handles.chg; {n, m, oldval, '->', newval}];
    DADOS(n,m) = newval;
    set(H,'String',num2str(newval,16));
    
    chgstr = cell2str(handles.chg,6,1);
    set(handles.undo_hdr,'String',chgstr(1,:),'Value',1);
    set(handles.undolist,'String',chgstr(2:end,:),'Value',size(handles.chg,1)-1);
    guidata(hObject, handles);
    
    xcol = get(handles.xlist,'Value');
    ycol = get(handles.ylist,'Value');
    if m == xcol || m == ycol
        updateplot(hObject, eventdata, handles);
    end
end

% ---------------------------------------------------------------
function updatesel(hObject, eventdata, handles)
global DADOS
% Atualizar seleçao

H = gcbo;

N = size(DADOS,1);

n1 = max(1, N-get(handles.Vslider,'Value')-14);

tag = get(H,'Tag');
v = str2num(tag(4:5));

n = n1+v-1;

handles.sel(n) = get(H,'Value');
guidata(hObject, handles);

updateplot(hObject, eventdata, handles);

% ---------------------------------------------------------------
function updateplot(hObject, eventdata, handles)
global DADOS
% Atualizar plote

[N, M] = size(DADOS);

n1 = max(1, N-get(handles.Vslider,'Value')-14);
xcol = get(handles.xlist,'Value');
ycol = get(handles.ylist,'Value');
sel = logical(handles.sel);

if isempty(gcbo) || gcbo ~= handles.Vslider
    set(handles.plot1,'XData',DADOS(:,xcol),'YData',DADOS(:,ycol));
    set(handles.selpts,'XData',DADOS(sel,xcol),'YData',DADOS(sel,ycol));
end

pts = (1:min(16,N)) + n1 - 1;
set(handles.plot2,'XData',DADOS(pts,xcol),'YData',DADOS(pts,ycol));

if get(handles.follow_btn,'Value')
    x1 = min(DADOS(pts,xcol));
    x2 = max(DADOS(pts,xcol));
    dx = x2-x1;
    if isnan(dx)
        return
    elseif dx < 1e-4
        x1 = x1 - .5;
        x2 = x2 + .5;
    end
    set(handles.graph,'XLim',[x1 x2]+.2*dx*[-1 1]);
end

% ---------------------------------------------------------------
function undo_Callback(hObject, eventdata, handles)
global DADOS
% Desfazer alteraçao

Nu = get(handles.undolist,'Value');

if size(handles.chg,1) > 1 && ~isempty(Nu)
    for nu = Nu
        n = handles.chg{nu+1,1};
        m = handles.chg{nu+1,2};
        oldval = handles.chg{nu+1,3};
        newval = handles.chg{nu+1,5};
        
        DADOS(n,m) = oldval;
    end
    handles.chg(Nu+1,:) = [];
    guidata(hObject, handles);
    
    chgstr = cell2str(handles.chg,6,1);
    set(handles.undo_hdr,'String',chgstr(1,:),'Value',1);
    if size(handles.chg,1) == 1
        set(handles.undolist,'String',' ','Value',[]);
    else
        set(handles.undolist,'String',chgstr(2:end,:),'Value',size(handles.chg,1)-1);
    end
    
    updatetable(hObject, eventdata, handles);
    updateplot(hObject, eventdata, handles);
    
end

% ---------------------------------------------------------------
function undolist_Callback(hObject, eventdata, handles)
% Lista de alteraçoes

if size(handles.chg,1) == 1
    set(handles.undolist,'String',' ','Value',[]);
end

% ---------------------------------------------------------------
function xlist_Callback(hObject, eventdata, handles)
% Seleçao da abscissa

set(handles.graph,'XLimMode','auto');
updateplot(hObject, eventdata, handles);
window_WindowButtonMotionFcn(hObject, eventdata, handles);

% ---------------------------------------------------------------
function ylist_Callback(hObject, eventdata, handles)
% Seleçao da ordenada

updateplot(hObject, eventdata, handles);
window_WindowButtonMotionFcn(hObject, eventdata, handles);

% ---------------------------------------------------------------
function Vslider_Callback(hObject, eventdata, handles)
% Barra de rolagem vertical

set(handles.Vslider,'Value',round(get(handles.Vslider,'Value')));
updatetable(hObject, eventdata, handles);
updateplot(hObject, eventdata, handles);

% ---------------------------------------------------------------
function Hslider_Callback(hObject, eventdata, handles)
% Barra de rolagem horizontal

set(handles.Hslider,'Value',round(get(handles.Hslider,'Value')));
updatetable(hObject, eventdata, handles);

% ---------------------------------------------------------------
function follow_btn_Callback(hObject, eventdata, handles)
% Rerstringir o grafico ao trecho da tabela

updateplot(hObject, eventdata, handles);

% --------------------------------------------------------------------
function left_btn_Callback(hObject, eventdata, handles)
% Deslocar grafico para esquerda

set(handles.follow_btn,'Value',0);

Xmin = min(get(handles.plot1,'XData'));
ax = get(handles.graph,'XLim');
if ax(1) > Xmin
    set(handles.graph,'XLim',ax-.2*diff(ax));
else
    beep;
end

% --------------------------------------------------------------------
function right_btn_Callback(hObject, eventdata, handles)
% Deslocar grafico para direita

set(handles.follow_btn,'Value',0);

Xmax = max(get(handles.plot1,'XData'));
ax = get(handles.graph,'XLim');
if ax(2) < Xmax
    set(handles.graph,'XLim',ax+.2*diff(ax));
else
    beep;
end

% ---------------------------------------------------------------
function help_btn_Callback(hObject, eventdata, handles)
% Botao Ajuda

helpme('Ferramentas\visualizartabela');

% -------------------------------------------------------------------
function ok_btn_Callback(hObject, eventdata, handles)
% Botao OK

if size(handles.chg,1) == 1
    str = 'Deseja sair?';
else
    str = 'Deseja confirmar alterações?';
end
button = questdlg(str,'Confirmação','Sim','Não','Não');
if strcmp(button,'Sim')
    handles.ok = 1;
    guidata(hObject, handles);
    uiresume;            
end

% ---------------------------------------------------------------
function cancel_btn_Callback(hObject, eventdata, handles)
% Botao cancela

if size(handles.chg,1) == 1
    str = 'Deseja sair?';
else
    str = 'Deseja descartar alterações?';
end
button = questdlg(str,'Confirmação','Sim','Não','Não');
if strcmp(button,'Sim')
    if size(handles.chg,1) > 1
        set(handles.undolist,'Value',1:size(handles.chg,1)-1);
        undo_Callback(hObject, eventdata, handles);
        pause(.4);
    end
    uiresume;
end

% ---------------------------------------------------------------
function window_CloseRequestFcn(hObject, eventdata, handles)
% Funçao de fechamento

cancel_btn_Callback(hObject, eventdata, handles);

% ---------------------------------------------------------------
function window_WindowButtonDownFcn(hObject, eventdata, handles)
% Funçao executada ao se pressionar o botao do mouse

xzoom = getappdata(handles.window,'xzoom');

cp = get(handles.graph,'CurrentPoint');
x = cp(1,1);
y = cp(1,2);
ax = get(handles.graph,'XLim');
ay = get(handles.graph,'YLim');

if x > ax(1) && x < ax(2) && y > ay(1) && y < ay(2)
    
    xmin = min(get(handles.plot1,'XData'));
    xmax = max(get(handles.plot1,'XData'));
    
    if strcmp(get(handles.window,'SelectionType'),'open'); % Duplo clique
        set(handles.auxline,'Visible','off')
        set(handles.graph,'XLimMode','auto','YLimMode','auto');
        xzoom = [];
        set(handles.follow_btn,'Value',0);
        window_WindowButtonMotionFcn(hObject, eventdata, handles);
        
    elseif strcmp(get(handles.window,'SelectionType'),'normal'); % Clique simples
        if length(xzoom) == 1 && x ~= xzoom
            if abs(x-xzoom) > 1e-4 && max(x,xzoom) > xmin  && min(x,xzoom) < xmax
                set(handles.graph,'YLimMode','manual');
                ay = get(handles.graph,'YLim');
                set(handles.auxline,'XData',[xzoom xzoom NaN x x],'YData',[ay NaN ay],'Visible','on');
                pause(.2);
                xzoom = getappdata(handles.window,'xzoom');
                if ~isempty(xzoom)
                    xzoom = sort([xzoom x]);
                    set(handles.graph,'XLim',xzoom);
                    set(handles.follow_btn,'Value',0);
                    window_WindowButtonMotionFcn(hObject, eventdata, handles);
                end
            else
                beep;
            end
            set(handles.auxline,'Visible','off');
            set(handles.graph,'YLimMode','auto');
            xzoom = [];
        else
            xzoom = x;
            set(handles.graph,'YLimMode','manual');
            ay = get(handles.graph,'YLim');
            set(handles.auxline,'XData',[xzoom, xzoom],'YData',ay,'Visible','on');
        end
        
    elseif strcmp(get(handles.window,'SelectionType'),'alt'); % Botao direito
        if length(xzoom) == 1
            xzoom = [];
            set(handles.auxline,'Visible','off');
            set(handles.graph,'YLimMode','auto');
        else
            ax = get(handles.graph,'XLim');
            Lzoom = ax(1) > xmin;
            Rzoom = ax(2) < xmax;
            if  Lzoom || Rzoom
                set(handles.graph,'XLim',[ax(1)-Lzoom*diff(ax)/4, ax(2)+Rzoom*diff(ax)/4]);
                set(handles.follow_btn,'Value',0);
                window_WindowButtonMotionFcn(hObject, eventdata, handles);
                drawnow;
                set(handles.graph,'YLimMode','manual');
                ay = get(handles.graph,'YLim');
                set(handles.auxline,'XData',[ax(1) ax(1) NaN ax(2) ax(2)],'YData',[ay NaN ay],'Visible','on');
                pause(.2);
                set(handles.auxline,'Visible','off');
                set(handles.graph,'YLimMode','auto');
            else
                beep;
            end
        end
    end
    
    setappdata(handles.window,'xzoom',xzoom);
end

% ---------------------------------------------------------------
function window_WindowButtonMotionFcn(hObject, eventdata, handles)
% Funçao executada ao se mover o mouse

xzoom = getappdata(handles.window,'xzoom');

cp = get(handles.window,'CurrentPoint') + [.5 .5];
ap = get(handles.graph,'Position');
ax = get(handles.graph,'XLim');
ay = get(handles.graph,'YLim');

x = (cp(1)-ap(1))*(ax(2)-ax(1))/ap(3) + ax(1);
y = (cp(2)-ap(2))*(ay(2)-ay(1))/ap(4) + ay(1);

if x >= ax(1) && x <= ax(2) && y >= ay(1) && y <= ay(2);
    ng = 1;
else
    ng = 0;        
end

if ~ng && size(xzoom,1) > 0  % Sair da tela durante uma operaçao de zoom -> cancelar
    setappdata(handles.window,'xzoom',[]);
    set(handles.graph,'YLimMode','auto');
    set(handles.auxline,'XData',NaN,'YData',NaN);
end

% Tipo e posiçao do cursor
if ng
    
    set(handles.window,'Pointer','crosshair');
    
    if IsTime(handles.PARAM{get(handles.xlist,'Value')})
        xstr = time2str2(x,0,3);
    else        
        xstr = num2str(x,'%0.4f');
    end
    ystr = num2str(y,'%0.4f');
    
else
    
    set(handles.window,'Pointer','arrow');
    xstr = '';
    ystr = '';
    
end

set(handles.xvalue,'String',xstr);
set(handles.yvalue,'String',ystr);

% -------------------------------------------------------------------
function window_KeyPressFcn(hObject, eventdata, handles)
% Acionamento de tecla do teclado

cc = get(handles.window,'CurrentCharacter');

if isempty(cc)
    return
end

switch abs(cc)
    
    case 28 % <--
        if strcmp(get(handles.Hslider,'Enable'),'on')
            h1 = get(handles.Hslider,'Min');
            h  = get(handles.Hslider,'Value');
            if h > h1
                set(handles.Hslider,'Value',h-1);
            end
            updatetable(hObject, eventdata, handles);
            drawnow;
        end
        
    case 29 % -->
        if strcmp(get(handles.Hslider,'Enable'),'on')
            h2 = get(handles.Hslider,'Max');
            h  = get(handles.Hslider,'Value');
            if h < h2
                set(handles.Hslider,'Value',h+1);
            end
            updatetable(hObject, eventdata, handles);
            drawnow;
        end
        
    case 31 % Down
        if strcmp(get(handles.Vslider,'Enable'),'on')
            v1 = get(handles.Vslider,'Min');
            v  = get(handles.Vslider,'Value');
            if v > v1
                set(handles.Vslider,'Value',v-1);
            end
            updatetable(hObject, eventdata, handles);
            updateplot(hObject, eventdata, handles);
            drawnow;
        end
        
    case 30 % Up
        if strcmp(get(handles.Vslider,'Enable'),'on')
            v2 = get(handles.Vslider,'Max');
            v  = get(handles.Vslider,'Value');
            if v < v2
                set(handles.Vslider,'Value',v+1);
            end
            updatetable(hObject, eventdata, handles);
            updateplot(hObject, eventdata, handles);
            drawnow;
        end
        
    case {abs('c'),abs('C')}
        set(handles.follow_btn,'Value',~get(handles.follow_btn,'Value'));
        follow_btn_Callback(hObject, eventdata, handles);
        
    case abs('<')
        left_btn_Callback(hObject, eventdata, handles);
        
    case abs('>')
        right_btn_Callback(hObject, eventdata, handles);
        
    case abs('.')
        set(handles.auxline,'Visible','off')
        set(handles.graph,'XLimMode','auto','YLimMode','auto');
        xzoom = [];
        set(handles.follow_btn,'Value',0);
        setappdata(handles.window,'xzoom',xzoom);
        window_WindowButtonMotionFcn(hObject, eventdata, handles);

    case 26 % Ctrl + z
        undo_Callback(hObject, eventdata, handles);
        
    case 13 % Enter
        ok_btn_Callback(hObject, eventdata, handles);
        
    case 27 % Esc
        cancel_btn_Callback(hObject, eventdata, handles);
        
end

% ---------------------------------------------------------------
function EntryFix(h,p,def)
% Corrige um valor numerico inserido numa caixa de texto
% Executa o string, realizando contas embutidas
%    h: handle do objeto
%    p: digitos de precisao (default = 16)
%    def: string default

switch nargin
    case 1
        p = 16;
        def = '';
    case 2
        def = '';
end

val = real(str2num(get(h,'String')));
if length(val) ~= 1 || isnan(val)
    str = def;
else
    str = num2str(val,p);
end
set(h,'String',str);
