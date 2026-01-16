function varargout = RDAT_TrackPoints(varargin)
% RDAT_TRACKPOINTS M-file for RDAT_TrackPoints.fig
% Last Modified by GUIDE v2.5 16-Apr-2011 18:57:49

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RDAT_TrackPoints_OpeningFcn, ...
                   'gui_OutputFcn',  @RDAT_TrackPoints_OutputFcn, ...
                   'gui_LayoutFcn',  @RDAT_TrackPoints_LayoutFcn, ...
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
function h = RDAT_TrackPoints_LayoutFcn(varargin)
% Função de layout inicial

h = openfig('RDAT_TrackPoints.fig','reuse','invisible');

% ---------------------------------------------------------------
function RDAT_TrackPoints_OpeningFcn(hObject, eventdata, handles, varargin)

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

if length(varargin) >= 4
    X    = varargin{1};
    Y    = varargin{2};
    xpar = varargin{3};
    ypar = varargin{4};
    if length(varargin) >= 5
        handles.points = varargin{5};
    else
        handles.points = [];
    end
    if length(varargin) >= 6
        xlim = varargin{6};
    else
        xlim = [];
    end
else
    beep; uiwait(errordlg('Dados de entrada não fornecidos.','Erro','modal')); drawnow;
    handles.ok = 0;
    guidata(hObject, handles);
    uiresume;
    return
end

setappdata(handles.window,'xzoom',[]);

handles.X = X;
handles.Y = Y;
handles.ok = 0;
handles.fpath = [pwd filesep];

handles.graphs = [handles.graph handles.graph2];

axes(handles.graph);
handles.ylabel   = ylabel(ypar,'Interpreter','none');
handles.plot1    = plot(handles.X,handles.Y,'.-c');
handles.plot2    = plot(NaN,NaN,'.-b');
handles.baseline = plot(NaN,NaN,'-k');
handles.auxline  = plot(NaN,NaN,'Color',[.5 .5 .5]);
handles.auxpts   = plot(NaN,NaN,'+k');
handles.trkpts   = plot(NaN,NaN,'+r','MarkerSize',14);
set(handles.method_list,'String',{'Linear','Spline','Cúbico'});
set(handles.extrap_list,'String',{'Zero','Vizinho','Linear'});
set(handles.opt_sel,'String',{'Novo parâmetro','Substituir atual'});

axes(handles.graph2);
handles.xlabel = xlabel(xpar,'Interpreter','none');
ylabel('Correção');
handles.diffplot = plot(NaN,NaN,'-b');

axes(handles.legendgraph)
plot([.05 .15],[.5 .5],'-c');
plot([.55 .65],[.5 .5],'-b');
plot(.1, .5,'.c');
plot(.6, .5,'.b');
text(.2, .5,'Original');
text(.7, .5,'Corrigido');
axis([0 1 0 1]);

guidata(hObject, handles);

updatetable(hObject, eventdata, handles);
updateplot(hObject, eventdata, handles, xlim);

uiwait(handles.window);

% ---------------------------------------------------------------
function varargout = RDAT_TrackPoints_OutputFcn(hObject, eventdata, handles)

if handles.ok
    varargout{1} = handles.Y2;
    varargout{2} = get(handles.opt_sel,'Value');
else
    varargout{1} = [];
    varargout{2} = [];
end
delete(handles.window);

% ---------------------------------------------------------------
function updateplot(hObject, eventdata, handles, xlim)
% Atualizaçao dos graficos

if nargin == 3
    xlim = [];
end

if ~isempty(handles.points)
    set(handles.trkpts,'XData',handles.points(:,1),'YData',handles.points(:,2));
    
    nna = find(isnan(handles.Y));
    methodlist = {'linear','spline','cubic'};
    extraplist = {'zero','nearest','linear'};
    method = methodlist{get(handles.method_list,'Value')};
    extrap = extraplist{get(handles.extrap_list,'Value')};
        
    [Y2, Yshift, Ybase] = trackpoints(handles.X, denan(handles.Y), handles.points, method, extrap);
    Y2(nna) = NaN;
    
    Yaux = interp1(handles.X,handles.Y,handles.points(:,1),'linear','extrap');
    set(handles.auxpts,'XData',handles.points(:,1),'YData',Yaux);

    set(handles.plot2,'XData',handles.X,'YData',Y2);
    set(handles.baseline,'XData',[handles.X; NaN; handles.X],'YData',[Yshift; NaN; Ybase]);
    
    if ~isempty(xlim)
        set(handles.graph,'XLim',xlim);
    end
    
    set(handles.diffplot,'XData',handles.X,'YData',Yshift-Ybase);
    set(handles.graph2,'XLim',get(handles.graph,'XLim'));
    
else
    Y2 = [];
    set([handles.plot2 handles.baseline handles.trkpts handles.auxpts handles.diffplot],'XData',NaN,'YData',NaN);
    
    if ~isempty(xlim)
        set(handles.graph,'XLim',xlim);
    end
    
    set(handles.graph2,'XLim',get(handles.graph,'XLim'));
end

handles.Y2 = Y2;
guidata(hObject, handles);

% ---------------------------------------------------------------
function updatetable(hObject, eventdata, handles, n)
% Atualizaçao da tabela

if nargin == 3 || isempty(handles.points)
    n = 1;
end

if isempty(handles.points)
    str = '';
elseif IsTime(get(handles.xlabel,'String'))
    str = [time2str2(handles.points(:,1),0,3) spc(size(handles.points,1),2) mat2str2(handles.points(:,2))];
else
    str = mat2str2(handles.points);
end
set(handles.points_list,'String',str,'Value',n);

% ---------------------------------------------------------------
function method_list_Callback(hObject, eventdata, handles)
% Lista de metodos de interpolaçao

updateplot(hObject, eventdata, handles);

% ---------------------------------------------------------------
function extrap_list_Callback(hObject, eventdata, handles)
% Lista de metodos de extrapolaçao

updateplot(hObject, eventdata, handles);

% ---------------------------------------------------------------
function add_btn_Callback(hObject, eventdata, handles)
% Adiciona ponto

[Xs, Ys] = inputvalues('Novo ponto', {[get(handles.xlabel,'String') ':'], [get(handles.ylabel,'String') ':']});
if ~isempty(Xs) && ~isempty(Ys)
    Xi = str2double(Xs);
    if isnan(Xi)
        Xi = str2time(Xs);
    end
    Yi = str2double(Ys);
    if isnan(Xi) || isnan(Yi)
        beep; uiwait(errordlg('Valor incoerente.','Erro','modal')); drawnow;
    else
        if ~isempty(handles.points) && any(Xi==handles.points(:,1));
            beep; uiwait(errordlg('Ponto já existente.','Erro','modal')); drawnow;
            return
        end
        handles.points = sortrows([handles.points; Xi Yi],1);
        guidata(hObject, handles);
        
        updatetable(hObject, eventdata, handles, find(Xi==handles.points(:,1)));
        updateplot(hObject, eventdata, handles);
    end
else
    if ischar(Xs) || ischar(Ys)
        beep; uiwait(errordlg('Dados incompletos.','Erro','modal')); drawnow;
    end
end

% --------------------------------------------------------------------
function get_btn_Callback(hObject, eventdata, handles)
% Adquire ponto do grafico

H = findobj(handles.window,'Enable','on');
H = setdiff(H,findobj(handles.window,'Style','text'));
set(H,'Enable','inactive');

btn = waitforbuttonpress;

Xi = str2double(get(handles.xvalue,'String'));
Yi = str2double(get(handles.yvalue,'String'));
if isnan(Xi)
    Xi = str2time(get(handles.xvalue,'String'));
end

set(H,'Enable','on');
set(handles.get_btn,'Value',0);
window_WindowButtonMotionFcn(hObject, eventdata, handles);

if btn || strcmp(get(handles.window,'SelectionType'),'alt')
    return
end

if gca ~= handles.graph || isnan(Xi+Yi)
    beep; uiwait(errordlg('Clique no gráfico principal.','Erro','modal')); drawnow;
    return
end

if ~isempty(Xi) && ~isempty(Yi)
    if ~isempty(handles.points) && any(Xi==handles.points(:,1));
        beep; uiwait(errordlg('Ponto já existente.','Erro','modal')); drawnow;
        return
    end
    handles.points = sortrows([handles.points; Xi Yi],1);
    guidata(hObject, handles);
    
    updatetable(hObject, eventdata, handles, find(Xi==handles.points(:,1)));
    updateplot(hObject, eventdata, handles);
end

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

if IsTime(get(handles.xlabel,'String'))
    xstr = time2str2(handles.points(n,1),0,3);
else
    xstr = num2str(handles.points(n,1));
end

[Xs, Ys] = inputvalues('Alterar ponto', {[get(handles.xlabel,'String') ':'], [get(handles.ylabel,'String') ':']},...
    {xstr, num2str(handles.points(n,2))});
if ~isempty(Xs) && ~isempty(Ys)
    Xi = str2double(Xs);
    if isnan(Xi)
        Xi = str2time(Xs);
    end
    Yi = str2double(Ys);
    if isnan(Xi) || isnan(Yi)
        beep; uiwait(errordlg('Valor incoerente.','Erro','modal')); drawnow;
    else
        k = size(handles.points,1);
        if k > 1 && any(Xi==handles.points(setdiff(1:k,n),1));
            beep; uiwait(errordlg('Ponto já existente.','Erro','modal'));
            return
        end
        handles.points(n,:) = [Xi Yi];
        handles.points = sortrows(handles.points,1);
        guidata(hObject, handles);
        
        updatetable(hObject, eventdata, handles, find(Xi==handles.points(:,1)));
        updateplot(hObject, eventdata, handles);
    end
else
    if ischar(Xs) || ischar(Ys)
        beep; uiwait(errordlg('Dados incompletos.','Erro','modal')); drawnow;
    end
end

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
                
                if IsTime(get(handles.xlabel,'String'))
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
    if size(dat,1) > 0 && size(dat,2) == 2 && ~any(any((isnan(dat))))
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
            beep; uiwait(errordlg('Arquivo com dados inválidos.','Erro','modal')); drawnow;
        else
            beep; uiwait(errordlg('Formato incompatível.','Erro','modal')); drawnow;
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
    Xmin = min(handles.X);
else
    Xmin = min([handles.X; handles.points(:,1)]);
end

ax = get(handles.graph,'XLim');
if ax(1) > Xmin
    set([handles.graph handles.graph2],'XLim',ax-.2*diff(ax));
else
    beep;
end

% --------------------------------------------------------------------
function right_btn_Callback(hObject, eventdata, handles)
% Deslocamento 20% à direita

if isempty(handles.points)
    Xmax = max(handles.X);
else
    Xmax = max([handles.X; handles.points(:,1)]);
end

ax = get(handles.graph,'XLim');
if ax(2) < Xmax
    set([handles.graph handles.graph2],'XLim',ax+.2*diff(ax));
else
    beep;
end

% -------------------------------------------------------------------
function help_btn_Callback(hObject, eventdata, handles)
% Botao Ajuda

helpme('Ferramentas\correcaoptscontrole');

% ---------------------------------------------------------------
function ok_btn_Callback(hObject, eventdata, handles)
% Botao OK

if isempty(handles.Y2)
    beep; uiwait(errordlg('Não há dados corrigidos.','Erro','modal')); drawnow;
    return
end
if get(handles.opt_sel,'Value') == 2 && strcmp(get(handles.ylabel,'String'),'No. OBS.')
    beep; uiwait(errordlg('O parâmetro ''No. OBS.'' não pode ser alterado.','Erro','modal')); drawnow;
    return
end

if get(handles.opt_sel,'Value') == 1
    button = questdlg({'Deseja confirmar a operação','e criar um novo parâmetro?'},'Confirmação','Sim','Não','Não'); drawnow;
else
    button = questdlg({'Deseja confirmar a operação?','Os dados originais serão perdidos!'},'Confirmação','Sim','Não','Não'); drawnow;
end

if strcmp(button,'Sim')
    handles.ok = 1;
    guidata(hObject, handles);
    uiresume;            
end

% ---------------------------------------------------------------
function cancel_btn_Callback(hObject, eventdata, handles)
% Botao Cancela

if isempty(handles.Y2)
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
        set(handles.graph2,'XLim',get(handles.graph,'XLim'));
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
    
    xmin = min(handles.X);
    xmax = max(handles.X);
    
    if strcmp(get(handles.window,'SelectionType'),'open'); % Duplo clique
        set(handles.auxline,'Visible','off')
        set(handles.graph,'XLimMode','auto','YLimMode','auto');
        set(handles.graph2,'XLim',get(handles.graph,'XLim'));
        xzoom = [];
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
                    set([handles.graph handles.graph2],'XLim',xzoom);
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
            if ~isempty(handles.points)
                Lzoom = ax(1) > min([xmin; handles.points(:,1)]);
                Rzoom = ax(2) < max([xmax; handles.points(:,1)]);
            else
                Lzoom = ax(1) > xmin;
                Rzoom = ax(2) < xmax;
            end
            if  Lzoom || Rzoom
                set([handles.graph handles.graph2],'XLim',[ax(1)-Lzoom*diff(ax)/4, ax(2)+Rzoom*diff(ax)/4]);
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

if isempty(handles) || ~isfield(handles,'graphs')
    return
end

cp = get(handles.window,'CurrentPoint') + [.5 .5];
ng = 0;

for n = 1:2
    ap = get(handles.graphs(n),'Position');
    ax = get(handles.graphs(n),'XLim');
    ay = get(handles.graphs(n),'YLim');
    
    x = (cp(1)-ap(1))*(ax(2)-ax(1))/ap(3) + ax(1);
    y = (cp(2)-ap(2))*(ay(2)-ay(1))/ap(4) + ay(1);
    
    if x >= ax(1) && x <= ax(2) && y >= ay(1) && y <= ay(2);
        ng = n;
        break
    end
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
    
    if IsTime(get(handles.xlabel,'String'))
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

