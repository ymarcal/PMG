function varargout = RDAT_TableParam(varargin)
% RDAT_TABLEPARAM M-file for RDAT_TableParam.fig
% Last Modified by GUIDE v2.5 19-Apr-2011 17:51:47

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RDAT_TableParam_OpeningFcn, ...
                   'gui_OutputFcn',  @RDAT_TableParam_OutputFcn, ...
                   'gui_LayoutFcn',  @RDAT_TableParam_LayoutFcn, ...
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

% ---------------------------------------------------------------
function h = RDAT_TableParam_LayoutFcn(varargin)
% Função de layout inicial

h = openfig('RDAT_TableParam.fig','reuse','invisible');

% ---------------------------------------------------------------
function RDAT_TableParam_OpeningFcn(hObject, eventdata, handles, varargin)

% Button setup
bgc = getbuttoncolor(handles.window);
set(handles.add_btn,   'CData',geticon('DatButtons.mat','add_s',    bgc));
set(handles.get_btn,   'CData',geticon('DatButtons.mat','acquire_s',bgc));
set(handles.remove_btn,'CData',geticon('DatButtons.mat','rem_s',    bgc));
set(handles.edit_btn,  'CData',geticon('DatButtons.mat','edit_s',   bgc));
set(handles.clear_btn, 'CData',geticon('DatButtons.mat','clear_s',  bgc));
set(handles.import_btn,'CData',geticon('DatButtons.mat','import_s', bgc));
set(handles.help_btn,  'CData',geticon('DatButtons.mat','help',     bgc));

ss = get(0,'ScreenSize');
ws = get(handles.window,'Position');
set(handles.window,'Position',[(ss(3)-ws(3))/2, (ss(4)-ws(4))/2-2, ws(3), ws(4)]);

if length(varargin) == 2
    T    = varargin{1};
    xpar = varargin{2};
else
    beep; uiwait(errordlg('Dados de entrada não fornecidos.','Erro','modal'));
    handles.ok = 0;
    guidata(hObject, handles);
    uiresume;
    return
end

if ~IsTimeOk(T)
    uiwait(warndlg({['O tempo de referência ''' xpar ''' não é adequado.'],...
            'O tempo deve ser monotônico crescente e sem pontos inválidos.'},'Aviso','modal')); drawnow;
    handles.ok = 0;
    guidata(hObject, handles);
    uiresume;
    return
end

setappdata(handles.window,'xzoom',[]);

handles.fpath = [pwd filesep];
handles.points = [];
handles.T = T;
handles.Y = NaN*T;
handles.xpar = xpar;
handles.ok = 0;

axes(handles.graph);
ylabel('y');
xlabel(xpar,'Interpreter','none');
handles.plot     = plot(handles.T,handles.Y,'.-b');
handles.auxline  = plot(NaN,NaN,'Color',[.5 .5 .5]);
handles.trkpts   = plot(NaN,NaN,'+r','MarkerSize',14);
set(handles.method_sel,'String',{'Ignorar','Repetir','Vizinho','Linear','Spline','Cúbico'},'Value',1);

guidata(hObject, handles);

updatetable(hObject, eventdata, handles);
updateplot(hObject, eventdata, handles);

uiwait(handles.window);

% ---------------------------------------------------------------
function varargout = RDAT_TableParam_OutputFcn(hObject, eventdata, handles)

if handles.ok
    varargout{1} = handles.Y;
else
    varargout{1} = [];
end
delete(handles.window);

% ---------------------------------------------------------------
function updateplot(hObject, eventdata, handles)
% Atualizaçao dos graficos

if ~isempty(handles.points)
    
    T = handles.T;
    
    Ti = handles.points(:,1);
    Yi = handles.points(:,2);
    Di = handles.points(:,3);
    set(handles.trkpts,'XData',Ti,'YData',Yi);
    
    nm = get(handles.method_sel,'Value');
    method_list = {'linear','linear','nearest','linear','spline','cubic'};
    method = method_list{nm};

    % Calculo de Y
    
    if ~isempty(Ti)
        
        Y = NaN*T;
        for n = 1:length(Ti)
            t1 = min([Ti(n) Ti(n)+Di(n)]);
            t2 = max([Ti(n) Ti(n)+Di(n)]);
            in = find(T>=t1 & T<=t2);
            Y(in) = Yi(n);
        end
        
        if nm > 1
            [Ti,ord] = sort([Ti; Ti+Di]);
            Yi = [Yi; Yi];            
            Yi = Yi(ord);
            
            exc = find(~diff(Ti));
            Ti(exc) = [];
            Yi(exc) = [];
            
            if length(Ti) ==1 || nm == 2 % Repetir
                Y2 = Y;
                for n = 1:length(Ti)-1
                    ind = find(T>=Ti(n) & T<=Ti(n+1));
                    Y2(ind) = Yi(n);
                end
            else % Interpolar
                Y2 = interp1(Ti,Yi,T,method,'extrap');
            end
            
            Y2(T<=Ti(1))   = Yi(1);
            Y2(T>=Ti(end)) = Yi(end);

            Y(isnan(Y)) = Y2(isnan(Y));
            
        end
        
    else
        Y = NaN*handles.T;
        set(handles.trkpts,'XData',NaN,'YData',NaN);
    end
else
    Y = NaN*handles.T;
    set(handles.trkpts,'XData',NaN,'YData',NaN);
end

set(handles.plot,'YData',Y);

handles.Y = Y;
guidata(hObject, handles);

set(handles.graph,'Ylim',[0 4])

% ---------------------------------------------------------------
function updatetable(hObject, eventdata, handles, n)
% Atualizaçao da tabela

if nargin == 3 || isempty(handles.points)
    n = 1;
end

if isempty(handles.points)
    str = '';
else
    str = [time2str2(handles.points(:,1),0,3) spc(size(handles.points,1),2) mat2str2(handles.points(:,[2 3]))];
end
set(handles.points_list,'String',str,'Value',n);

% ---------------------------------------------------------------
function method_sel_Callback(hObject, eventdata, handles)
% Lista de metodos de interpolaçao

updateplot(hObject, eventdata, handles);

% ---------------------------------------------------------------
function add_btn_Callback(hObject, eventdata, handles)
% Adiciona ponto

[Ts, Ys, Ds] = inputvalues('Novo ponto', {'Tempo:', 'Valor:', 'Duração:'});

if ~ischar(Ts)
    return
end
    
if isempty(Ts) || isempty(Ys) || isempty(Ds)
    beep; uiwait(errordlg('Dados incompletos.','Erro','modal')); drawnow;
    return
end

Ti = str2double(Ts);
if isnan(Ti)
    Ti = str2time(Ts);
end
Di = str2double(Ds);
if isnan(Di)
    Di = str2time(Ds);
end
Yi = str2double(Ys);

if isnan(Ti+Di+Yi)
    beep; uiwait(errordlg('Valor incoerente.','Erro','modal')); drawnow;
    return
end

if ~isempty(handles.points) && any(Ti==handles.points(:,1));
    beep; uiwait(errordlg('Ponto já existente.','Erro','modal'));
    return
end

handles.points = sortrows([handles.points; Ti Yi Di],1);
guidata(hObject, handles);

updatetable(hObject, eventdata, handles, find(Ti==handles.points(:,1)));
updateplot(hObject, eventdata, handles);

% --------------------------------------------------------------------
function get_btn_Callback(hObject, eventdata, handles)
% Adquire ponto do grafico

H = findobj(handles.window,'Enable','on');
H = setdiff(H,findobj(handles.window,'Style','text'));
set(H,'Enable','inactive');

btn = waitforbuttonpress;

Ti = str2time(get(handles.xvalue,'String'));
Yi = str2double(get(handles.yvalue,'String'));

set(H,'Enable','on');
set(handles.get_btn,'Value',0);
window_WindowButtonMotionFcn(hObject, eventdata, handles);

if btn || strcmp(get(handles.window,'SelectionType'),'alt')
    return
end

if isnan(Ti+Yi)
    beep; uiwait(errordlg('Clique no gráfico.','Erro','modal')); drawnow;
    return
end

[Ts, Ys, Ds] = inputvalues('Novo ponto', {'Tempo:', 'Valor:', 'Duração:'},{time2str2(Ti), num2str(Yi), '0'});

if ~ischar(Ts)
    return
end
    
if isempty(Ts) || isempty(Ys) || isempty(Ds)
    beep; uiwait(errordlg('Dados incompletos.','Erro','modal')); drawnow;
    return
end

Ti = str2double(Ts);
if isnan(Ti)
    Ti = str2time(Ts);
end
Di = str2double(Ds);
if isnan(Di)
    Di = str2time(Ds);
end
Yi = str2double(Ys);

if isnan(Ti+Di+Yi)
    beep; uiwait(errordlg('Valor incoerente.','Erro','modal')); drawnow;
    return
end

if ~isempty(handles.points) && any(Ti==handles.points(:,1));
    beep; uiwait(errordlg('Ponto já existente.','Erro','modal'));
    return
end

handles.points = sortrows([handles.points; Ti Yi Di],1);
guidata(hObject, handles);

updatetable(hObject, eventdata, handles, find(Ti==handles.points(:,1)));
updateplot(hObject, eventdata, handles);

% ---------------------------------------------------------------
function remove_btn_Callback(hObject, eventdata, handles)
% Exclui ponto

if isempty(handles.points)
    return
end

button = questdlg('Deseja excluir o ponto selecionado?','Confirmação','Sim','Não','Não'); drawnow;

if strcmp(button,'Sim')
    
    n = get(handles.points_list,'Value');
    handles.points(n,:) = [];
    guidata(hObject, handles);
    
    updatetable(hObject, eventdata, handles, max(1,min(n,size(handles.points,1))));
    updateplot(hObject, eventdata, handles);
end

% ---------------------------------------------------------------
function edit_btn_Callback(hObject, eventdata, handles)
% Edita ponto

if isempty(handles.points)
    return
end

n = get(handles.points_list,'Value');

[Ts, Ys, Ds] = inputvalues('Alterar ponto', {'Tempo:', 'Valor:', 'Duração (s):'},...
    {time2str2(handles.points(n,1)), num2str(handles.points(n,2)), num2str(handles.points(n,3))});

if ~ischar(Ts)
    return
end
    
if isempty(Ts) || isempty(Ys) || isempty(Ds)
    beep; uiwait(errordlg('Dados incompletos.','Erro','modal')); drawnow;
    return
end

Ti = str2double(Ts);
if isnan(Ti)
    Ti = str2time(Ts);
end
Di = str2double(Ds);
if isnan(Di)
    Di = str2time(Ds);
end
Yi = str2double(Ys);

if isnan(Ti+Di+Yi)
    beep; uiwait(errordlg('Valor incoerente.','Erro','modal')); drawnow;
    return
end

k = size(handles.points,1);
if k > 1 && any(Ti==handles.points(setdiff(1:k,n),1));
    beep; uiwait(errordlg('Ponto já existente.','Erro','modal'));
    return
end

handles.points(n,:) = [Ti Yi Di];
handles.points = sortrows(handles.points,1);
guidata(hObject, handles);

updatetable(hObject, eventdata, handles, find(Ti==handles.points(:,1)));
updateplot(hObject, eventdata, handles);

% ---------------------------------------------------------------
function import_btn_Callback(hObject, eventdata, handles)
% Importa lista de pontos

[fname,fpath,ind] = uigetfile({'*.xls','Planilha MS Excel (*.xls)';...
        '*.txt;*.dat', 'Arquivo de texto (*.txt, *.dat)'}, 'Indique o arquivo com os pontos',handles.fpath); drawnow;
if ischar(fname)
    switch ind
        case 2 % txt
            try
                dat = txtread([fpath fname]);
            catch
                dat = [];
            end
        case 1 % xls
            try
                dat = xlsread([fpath,fname]);
                
                if IsTime(handles.xpar)
                    opt = RDAT_InputOption('Opção','Informe o formato do parâmetro de tempo na planilha:',{'Segundos','HH:MM:SS'},1,320,1);
                    if isempty(opt)
                        return
                    end
                    if opt == 2 % HH:MM:SS
                        dat(:,1) = ( dat(:,1) - floor(dat(:,1)) ) * 24*3600;
                    end
                end
                
            catch
                dat = [];
            end
    end
    if size(dat,1) > 0 && ~any(any((isnan(dat)))) && (size(dat,2) == 2 || size(dat,2) == 3)
        if size(dat,2) == 2
            dat(:,3) = 0;
        end
        if ~isempty(handles.points)
            button = questdlg({'Deseja importar a lista de pontos?','A lista atual será descartada.'},'Confirmação','Sim','Não','Não'); drawnow;
        else
            button = 'Sim';
        end
        if strcmp(button,'Sim')
            handles.points = sortrows(dat,1);
            handles.fpath = fpath;
            guidata(hObject, handles);
            
            updatetable(hObject, eventdata, handles);
            updateplot(hObject, eventdata, handles);
        end
    else
        if any(any((isnan(dat))))
            beep; uiwait(errordlg('Arquivo com dados inválidos.','Erro','modal'));
        else
            beep; uiwait(errordlg('Formato incompatível.','Erro','modal'));
        end
    end
end

% ---------------------------------------------------------------
function clear_btn_Callback(hObject, eventdata, handles)
% Exclui todos os pontos

if isempty(handles.points)
    return
end

button = questdlg('Deseja excluir todos os pontos?','Confirmação','Sim','Não','Não'); drawnow;

if strcmp(button,'Sim')
    
    handles.points = [];
    guidata(hObject, handles);
    updatetable(hObject, eventdata, handles);
    updateplot(hObject, eventdata, handles);
end

% --------------------------------------------------------------------
function left_btn_Callback(hObject, eventdata, handles)
% Deslocamento 20% à esquerda

if isempty(handles.points)
    Xmin = min(handles.T);
else
    Xmin = min([handles.T; handles.points(:,1)]);
end

ax = get(handles.graph,'XLim');
if ax(1) > Xmin
    set(handles.graph,'XLim',ax-.2*diff(ax));
else
    beep;
end

% --------------------------------------------------------------------
function right_btn_Callback(hObject, eventdata, handles)
% Deslocamento 20% à direita

if isempty(handles.points)
    Xmax = max(handles.T);
else
    Xmax = max([handles.T; handles.points(:,1)]);
end

ax = get(handles.graph,'XLim');
if ax(2) < Xmax
    set(handles.graph,'XLim',ax+.2*diff(ax));
else
    beep;
end

% -------------------------------------------------------------------
function help_btn_Callback(hObject, eventdata, handles)
% Botao Ajuda

helpme('Ferramentas\paramdetabela');

% ---------------------------------------------------------------
function ok_btn_Callback(hObject, eventdata, handles)
% Botao OK

if isempty(handles.points)
    beep; errordlg('Não há dados calculados.','Erro','modal');
    return
end

button = questdlg({'Deseja confirmar a operação','e criar um novo parâmetro?'},'Confirmação','Sim','Não','Não');

if strcmp(button,'Sim')
    handles.ok = 1;
    guidata(hObject, handles);
    uiresume;            
end

% ---------------------------------------------------------------
function cancel_btn_Callback(hObject, eventdata, handles)
% Botao Cancela

if isempty(handles.points)
    button = questdlg('Deseja sair?','Confirmação','Sim','Não','Não'); drawnow;
else
    button = questdlg('Deseja cancelar a operação?','Confirmação','Sim','Não','Não'); drawnow;
end
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
    
    case 28 % <--
        left_btn_Callback(hObject, eventdata, handles);
        
    case 29 % -->
        right_btn_Callback(hObject, eventdata, handles);
        
    case abs('+')
        add_btn_Callback(hObject, eventdata, handles);
        
    case abs('*')
        set(handles.get_btn,'Value',1);
        get_btn_Callback(hObject, eventdata, handles);
        
    case {abs('-'),127} % Del
        remove_btn_Callback(hObject, eventdata, handles);
        
    case {abs('i'),abs('I')}
        import_btn_Callback(hObject, eventdata, handles);
        
    case {abs('e'),abs('E')}
        edit_btn_Callback(hObject, eventdata, handles);
        
    case abs('.')
        set(handles.auxline,'Visible','off')
        set(handles.graph,'XLimMode','auto','YLimMode','auto');
        xzoom = [];
        setappdata(handles.window,'xzoom',xzoom);
        window_WindowButtonMotionFcn(hObject, eventdata, handles);
        
    case {abs('x'),abs('X')}
        clear_btn_Callback(hObject, eventdata, handles);
        
    case 13 % Enter
        ok_btn_Callback(hObject, eventdata, handles);
        
    case 27 % Esc
        window_CloseRequestFcn(hObject, eventdata, handles);
        
end

% ---------------------------------------------------------------
function window_CloseRequestFcn(hObject, eventdata, handles)
% Funçao de fechamento da janela

cancel_btn_Callback(hObject, eventdata, handles);

% ---------------------------------------------------------------
function window_WindowButtonDownFcn(hObject, eventdata, handles)
% Funçao executada ao se pressionar o botao do mouse

if get(handles.get_btn,'Value')
    return
end

xzoom = getappdata(handles.window,'xzoom');

cp = get(handles.graph,'CurrentPoint');
x = cp(1,1);
y = cp(1,2);
ax = get(handles.graph,'XLim');
ay = get(handles.graph,'YLim');

if x > ax(1) && x < ax(2) && y > ay(1) && y < ay(2)
    
    xmin = min(handles.T);
    xmax = max(handles.T);
    
    if strcmp(get(handles.window,'SelectionType'),'open'); % Duplo clique
        set(handles.auxline,'Visible','off')
        set(handles.graph,'XLimMode','auto','YLimMode','auto');
        xzoom = [];
        window_WindowButtonMotionFcn(hObject, eventdata, handles);
        
    elseif strcmp(get(handles.window,'SelectionType'),'normal'); % Clique simples
        if length(xzoom) == 1 && x ~= xzoom
            if abs(x-xzoom) > 1e-4 && max(x,xzoom) > xmin  && min(x,xzoom) < xmax
                set(handles.graph,'XLimMode','manual','YLimMode','manual');
                ay = get(handles.graph,'YLim');
                set(handles.auxline,'XData',[xzoom xzoom NaN x x],'YData',[ay NaN ay],'Visible','on');
                pause(.2);
                xzoom = getappdata(handles.window,'xzoom');
                if ~isempty(xzoom)
                    xzoom = sort([xzoom x]);
                    set(handles.graph,'XLim',xzoom);
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
            set(handles.graph,'XLimMode','manual','YLimMode','manual');
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
            if ~isempty(handles.points)
                Lzoom = ax(1) > min([xmin; handles.points(:,1)]);
                Rzoom = ax(2) < max([xmax; handles.points(:,1)]);
            else
                Lzoom = ax(1) > xmin;
                Rzoom = ax(2) < xmax;
            end
            if  Lzoom || Rzoom
                set(handles.graph,'XLim',[ax(1)-Lzoom*diff(ax)/4, ax(2)+Rzoom*diff(ax)/4]);
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

% --------------------------------------------------------------------
function window_WindowButtonMotionFcn(hObject, eventdata, handles)
% Funçao executada ao se mover o mouse

cp = get(handles.window,'CurrentPoint') + [.5 .5];
ng = 0;

ap = get(handles.graph,'Position');
ax = get(handles.graph,'XLim');
ay = get(handles.graph,'YLim');

x = (cp(1)-ap(1))*(ax(2)-ax(1))/ap(3) + ax(1);
y = (cp(2)-ap(2))*(ay(2)-ay(1))/ap(4) + ay(1);

if x >= ax(1) && x <= ax(2) && y >= ay(1) && y <= ay(2);
    ng = 1;
end

xzoom = getappdata(handles.window,'xzoom');
if ~ng && size(xzoom,1) > 0  % Sair da tela durante uma operaçao de zoom -> cancelar
    setappdata(handles.window,'xzoom',[]);
    set(handles.graph,'YLimMode','auto');
    set(handles.auxline,'XData',NaN,'YData',NaN);
end

% Tipo e posiçao do cursor
if ng
    
    set(handles.window,'Pointer','crosshair');
    
    if IsTime(handles.xpar)
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

% --------------------------------------------------------------------
function str = mat2str2(mat)
% Converte uma matriz numerica em tabela de texto

if isempty(mat) || ~isnumeric(mat)
    str = '';
end

spc = char(32*ones(size(mat,1),2));

for n = 1:size(mat,2)
    if n == 1
        str = num2str(mat(:,n));
    else
        str = [str spc num2str(mat(:,n))];
    end
end

% --------------------------------------------------------------------
function str = spc(N,M)
% Cria coluna de espaços

if nargin == 1
    M = 1;
end

str = char(32*ones(N,M));
