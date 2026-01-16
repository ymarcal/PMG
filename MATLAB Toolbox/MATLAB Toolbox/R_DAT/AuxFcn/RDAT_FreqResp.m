function varargout = RDAT_FreqResp(varargin)
% RDAT_FreqResp M-file for RDAT_FreqResp.fig
% Version Beta 1.0 JUN/08
% Last Modified by GUIDE v2.5 07-Dec-2010 09:55:03

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RDAT_FreqResp_OpeningFcn, ...
                   'gui_OutputFcn',  @RDAT_FreqResp_OutputFcn, ...
                   'gui_LayoutFcn',  @RDAT_FreqResp_LayoutFcn, ...
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

% --------------------------------------------------------------------
% -- WINDOW FUNCTIONS ------------------------------------------------
% --------------------------------------------------------------------

function h = RDAT_FreqResp_LayoutFcn(varargin)
% Função de layout inicial

h = openfig('RDAT_FreqResp.fig','reuse','visible');

% --------------------------------------------------------------------
function RDAT_FreqResp_OpeningFcn(hObject, eventdata, handles, varargin)
global DADOS

% Funçao de inicializaçao
set(handles.window,'windowstyle','normal');
if length(varargin) == 3
    PARAM = varargin{1};
    ntime = varargin{2};
    pts   = varargin{3};
    n_in  = 1;
    n_out = 1;
else
    set(handles.window,'Visible','off');
    beep; uiwait(errordlg('Dados não fornecidos.','Erro','modal'));
    delete(handles.window);
    return
end

T0 = denan(DADOS(pts,ntime));
Fs = getfreq(T0);
Ti = T0(1):1/Fs:T0(end);

if IsTimeOk(T0)
    try
        X = interp1(T0,denan(DADOS(pts,n_in )),Ti);
        Y = interp1(T0,denan(DADOS(pts,n_out)),Ti);
    catch
        X = denan(DADOS(pts,n_in ));
        Y = denan(DADOS(pts,n_out));
    end
else
    X = denan(DADOS(pts,n_in ));
    Y = denan(DADOS(pts,n_out));
end
X = detrend(X);
Y = detrend(Y);

% Dados constantes
handles.T0  = T0;
handles.Fs  = Fs;
handles.Ti  = Ti;
handles.pts = pts;
handles.N   = length(X);

% Posicionamento da tela
ss = get(0,'ScreenSize');
ws = get(handles.window,'Position');
set(handles.window,'Position',[(ss(3)-ws(3))/2, (ss(4)-ws(4))/2, ws(3), ws(4)]);

% Atribuiçao das figuras dos botoes
bgc = getbuttoncolor(handles.window);
set(handles.save_btn,    'CData',geticon('DatButtons.mat','save',     bgc));
set(handles.copy_btn,    'CData',geticon('DatButtons.mat','snapshot', bgc));
set(handles.reset_btn,   'CData',geticon('DatButtons.mat','fit',      bgc));
set(handles.datatips_btn,'CData',geticon('DatButtons.mat','datatip',  bgc));
set(handles.help_btn,    'CData',geticon('DatButtons.mat','help',     bgc));

% Definiçao dos grupos de handles
handles.graphs  = [handles.mag_graph handles.phase_graph handles.aux_graph];
handles.buttons = [handles.save_btn handles.copy_btn handles.reset_btn handles.datatips_btn handles.help_btn];

% Constantes
handles.fpath     = [cd filesep];
handles.nfft_list = [256 2.^(6:12)]';
handles.ovlp_list = (0:10:90)';
handles.lim_list  = (.5:.05:.95)';
handles.wndw_list = {'Bartlett-Hann','barthannwin';...
        'Bartlett','bartlett';...
        'Blackman','blackman';...
        'Blackman-Harris','blackmanharris';...
        'Bohman','bohmanwin';...
        'Flat Top','flattopwin';...
        'Gaussian','gausswin';...
        'Hamming','hamming';...
        'Hanning','hann';...
        'Nuttall''s Blackman-Harris','nuttallwin';...
        'Parzen (Valle-Poussin)','parzenwin';...
        'Retangular','rectwin';...
        'Triangular','triang'};   

lim_list_str{1} = 'Manual';
for n = 1:length(handles.lim_list)
    lim_list_str{n+1} = num2str(handles.lim_list(n));
end

setappdata(handles.window,'X',X);
setappdata(handles.window,'Y',Y);
setappdata(handles.window,'Fcut1',NaN);
setappdata(handles.window,'Fcut2',NaN);
setappdata(handles.window,'xzoom',[]);
setappdata(handles.window,'dragdata',0);
setappdata(handles.window,'datatipn',1);

% Atribuiçoes dos seletores
set([handles.input_sel handles.output_sel],'String',PARAM,'Value',1);

set(handles.input_sel, 'Value',n_in);
set(handles.output_sel,'Value',n_out);

set(handles.nfft_sel,'String',handles.nfft_list,'Value',4);
set(handles.ovlp_sel,'String',handles.ovlp_list,'Value',6);
set(handles.wndw_sel,'String',handles.wndw_list(:,1),'Value',9);
set(handles.lim_sel, 'String',lim_list_str,'Value',4);
    
% Criaçao dos plots
axes(handles.mag_graph);
handles.mag     = plot(NaN,NaN,'-b','HitTest','off');
handles.mag1    = plot(NaN,NaN,'--r','HitTest','off','Visible','off');
handles.mag2    = plot(NaN,NaN,'--r','HitTest','off','Visible','off');
handles.fmin1   = plot(NaN,NaN,'--k','HitTest','off');
handles.fmax1   = plot(NaN,NaN,'--k','HitTest','off');
handles.fminstr = text(0,0,'Fmin','HitTest','off','HorizontalAlignment','center','FontSize',8);
handles.fmaxstr = text(0,0,'Fmax','HitTest','off','HorizontalAlignment','center','FontSize',8);

handles.auxlines(1) = plot(NaN,NaN,'Color',[.5 .5 .5]);
handles.datatips(1,1) = plot(NaN,NaN,'sk','MarkerFaceColor','k','MarkerSize',5);
handles.datatips(1,2) = text(0,0,' ','BackgroundColor',[1 1 .8],'EdgeColor',[0 0 0],'FontSize',9,'Margin',.1,...
    'HorizontalAlignment','left','VerticalAlignment','bottom','Clipping','on','Visible','off');

ylabel('Magnitude (dB)','FontSize',10);

axes(handles.phase_graph);
handles.phase  = plot(NaN,NaN,'-b','HitTest','off');
handles.phase1 = plot(NaN,NaN,'--r','HitTest','off','Visible','off');
handles.phase2 = plot(NaN,NaN,'--r','HitTest','off','Visible','off');
handles.fmin2  = plot(NaN,NaN,'--k','HitTest','off');
handles.fmax2  = plot(NaN,NaN,'--k','HitTest','off');

handles.auxlines(2) = plot(NaN,NaN,'Color',[.5 .5 .5]);
handles.datatips(2,1) = plot(NaN,NaN,'sk','MarkerFaceColor','k','MarkerSize',5);
handles.datatips(2,2) = text(0,0,' ','BackgroundColor',[1 1 .8],'EdgeColor',[0 0 0],'FontSize',9,'Margin',.1,...
    'HorizontalAlignment','left','VerticalAlignment','bottom','Clipping','on','Visible','off');

ylabel('Fase (°)','FontSize',10);

axes(handles.aux_graph);
handles.psdx    = plot(0,0,'-b','HitTest','off','Visible','off');
handles.psdy    = plot(0,0,'-g','HitTest','off','Color',[0 .8 0],'Visible','off');
handles.csdxy   = plot(0,0,'-m','HitTest','off','Visible','off');
handles.coher   = plot(NaN,NaN,'-b','HitTest','off');
handles.lim     = plot(NaN,NaN,'--r','HitTest','off');
handles.cut1    = plot(NaN,NaN,'--k','HitTest','off');
handles.cut2    = plot(NaN,NaN,'--k','HitTest','off');
handles.cut1str = text(0,1.1,'Fcut1','HitTest','off','HorizontalAlignment','right','FontSize',8);
handles.cut2str = text(0,1.1,'Fcut2','HitTest','off','HorizontalAlignment','left','FontSize',8);
handles.ylabel  = ylabel('Coerência','FontSize',10);
handles.xlabel  = xlabel('Frequência (Hz)','FontSize',10);
handles.auxlines(3) = plot(NaN,NaN,'Color',[.5 .5 .5]);

axes(handles.window_graph);
handles.wndwplot = plot(NaN,NaN,'-b','HitTest','off');

axes(handles.legend_graph);
plot([.07 .22],[.2 .2],'-m');
plot([.07 .22],[.5 .5],'-g','Color',[0 .8 0]);
plot([.07 .22],[.8 .8],'-b');
text(.3,.2,0,'Cruzada','FontSize',8);
text(.3,.5,0,'Saída','FontSize',8);
text(.3,.8,0,'Entrada','FontSize',8);
set([handles.legend_graph; get(handles.legend_graph,'Children')],'Visible','off');

set(handles.title_str,'String',['Tamanho da amostra: ' num2str(length(X)) '    Cadência de amostragem: ' num2str(Fs) ' Hz']);

guidata(hObject, handles);

nfft_sel_Callback(hObject, eventdata, handles);
coher_chk_Callback(hObject, eventdata, handles);
conf_chk_Callback(hObject, eventdata, handles);

% --------------------------------------------------------------------
function varargout = RDAT_FreqResp_OutputFcn(hObject, eventdata, handles)
% Funçao de saida

% --------------------------------------------------------------------
function window_CloseRequestFcn(hObject, eventdata, handles)
% Funçao de fechamento da janela

opt = questdlg('Deseja sair?','Confirmação','Sim','Não','Não');
if strcmp(opt,'Sim');
    delete(handles.window);
end

% --------------------------------------------------------------------
function window_WindowButtonDownFcn(hObject, eventdata, handles)
% Funçao de clique do mouse

dragdata = getappdata(handles.window,'dragdata');
[ng, x]  = getcurrentgraph(hObject, eventdata, handles);

if ~ng
    return
end

switch dragdata
    case -1
        dragdata = 1;
    case -2
        dragdata = 2;
    case -3
        dragdata = 3;
    case 0
        switch get(handles.window,'SelectionType')
            case 'open' % Duplo clique
                reset_btn_Callback(hObject, eventdata, handles);
                setappdata(handles.window,'xzoom',[]);
            case 'normal' % Clique simples
                xzoom = getappdata(handles.window,'xzoom');
                switch length(xzoom)
                    case 0
                        for n = 1:3
                            set(handles.auxlines(n),'XData',[x x],'YData',get(handles.graphs(n),'YLim'));
                        end
                        setappdata(handles.window,'xzoom',x);
                    case 1
                        xzoom = sort([xzoom x]);
                        if diff(xzoom) < 1e-4
                            beep;
                            set(handles.auxlines,'XData',NaN,'YData',NaN);
                        else
                            for n = 1:3
                                set(handles.auxlines(n),'XData',[xzoom([1 1]) NaN xzoom([2 2])],'YData',[get(handles.graphs(n),'YLim') NaN get(handles.graphs(n),'YLim')]);
                            end
                            pause(.3);
                            set([handles.fmin1 handles.fmax1 handles.fmin2 handles.fmax2],'YData',[NaN NaN]);
                            set([handles.fminstr handles.fmaxstr],'Visible','off');
                            set(handles.auxlines,'XData',NaN,'YData',NaN);
                            
                            set(handles.graphs,'XLim',xzoom);
                            set([handles.mag_graph handles.phase_graph],'YLimMode','auto');
                            drawnow;
                            set([handles.mag_graph handles.phase_graph],'YLimMode','manual');
                            
                            set([handles.fmin1 handles.fmax1],'YData',get(handles.graphs(1),'YLim'));
                            set([handles.fmin2 handles.fmax2],'YData',get(handles.graphs(2),'YLim'));
                            
                            pos = get(handles.mag_graph,'Position');
                            ay  = get(handles.mag_graph,'YLim');
                            set(handles.fminstr,'Position',get(handles.fminstr,'Position').*[1 0 0]+[0 ay(1)-diff(ay)/pos(4)*11 0],'Visible','on');
                            set(handles.fmaxstr,'Position',get(handles.fmaxstr,'Position').*[1 0 0]+[0 ay(1)-diff(ay)/pos(4)*11 0],'Visible','on');
                            
                        end
                        setappdata(handles.window,'xzoom',[]);
                end
            case 'alt' % Botao direito
                reset_btn_Callback(hObject, eventdata, handles);
                setappdata(handles.window,'xzoom',[]);
        end
        window_WindowButtonMotionFcn(hObject, eventdata, handles);
end

if dragdata
    setappdata(handles.window,'dragdata',dragdata);
end

% --------------------------------------------------------------------
function window_KeyPressFcn(hObject, eventdata, handles)
% Acionamento de tecla do teclado

cc = get(handles.window,'CurrentCharacter');

if isempty(cc)
    return
end

switch abs(cc)
    
    case {abs('s'),abs('S')}
        save_btn_Callback(hObject, eventdata, handles);
    
    case {abs('c'),abs('C')}
        copy_btn_Callback(hObject, eventdata, handles);
        
    case abs('.')
        reset_btn_Callback(hObject, eventdata, handles);
        
    case {abs('l'),abs('L')}
        set(handles.datatips_btn,'Value',~get(handles.datatips_btn,'Value'))
        datatips_btn_Callback(hObject, eventdata, handles);
        
    case 13 % Enter
        ok_btn_Callback(hObject, eventdata, handles);
        
    case 27 % Esc
        window_CloseRequestFcn(hObject, eventdata, handles);
        
end

% --------------------------------------------------------------------
% -- MOUSE FUNCTIONS -------------------------------------------------
% --------------------------------------------------------------------

function window_WindowButtonUpFcn(hObject, eventdata, handles)
% Funçao de soltura do mouse

dragdata = getappdata(handles.window,'dragdata');

switch dragdata
    case {1,2}
        set(handles.lim_sel,'Value',1);
        updateplot(hObject, eventdata, handles);
        setappdata(handles.window,'dragdata',0);
        window_WindowButtonMotionFcn(hObject, eventdata, handles);
    case 3
        setappdata(handles.window,'dragdata',0);
        window_WindowButtonMotionFcn(hObject, eventdata, handles);
end

% --------------------------------------------------------------------
function window_WindowButtonMotionFcn(hObject, eventdata, handles)
% Funçao de movimentaçao do mouse

if isempty(handles) || ~isfield(handles,'graphs')
    return
end

dragdata = getappdata(handles.window,'dragdata');

if isempty(dragdata)
    return
end

[ng, x, y, ax, ay, ap, xp]  = getcurrentgraph(hObject, eventdata, handles);

% Cursor sobre um dos graficos
if ng
    if dragdata == 0
        set(handles.window,'Pointer','crosshair');
    end
    set(handles.x_cur,'String',num2str(x));
    set(handles.y_cur,'String',num2str(y));
else
    setappdata(handles.window,'xzoom',[]);
    set(handles.auxlines,'XData',NaN,'YData',NaN);
    set(handles.window,'Pointer','arrow');
    set([handles.x_cur handles.y_cur],'String','');
end

% Movimentaçao do datatip de magnitude e fase
if (ng == 1 || ng == 2) && dragdata ~= 3;
    xtip = get(handles.datatips(ng,1),'XData');
    ytip = get(handles.datatips(ng,1),'YData');
    
    kx = 3*diff(ax)/ap(3);
    ky = 3*diff(ay)/ap(4);
    if get(handles.log_chk,'Value')
        x2 = 10^((xp+kx-ax(1))/diff(ax) * diff(log10(ax)) + log10(ax(1)));
        kx = x2-x;
    end
    
    if abs(x-xtip) <= kx && abs(y-ytip) <= ky 
        pointer  = 'fleur';
        dragdata = -3;
    else
        pointer = 'crosshair';
        dragdata = 0;
    end
    set(handles.window,'Pointer',pointer);
    setappdata(handles.window,'dragdata',dragdata);
end
if (ng == 1 || ng == 2) && dragdata == 3
    F = get(handles.mag,'XData');
    n = find(abs(F-x)==min(abs(F-x)));
    n_old = getappdata(handles.window,'datatipn');
    if n ~= n_old
        setappdata(handles.window,'datatipn',n);
        updatedatatips(hObject, eventdata, handles);
    end
end

% Movimentaçao das barras de frequencia minima e maxima
if ~get(handles.coher_chk,'Value')
    return
end

if ng == 3
    if get(handles.Hz_chk,'Value')
        k = 1;
    else
        k = 2*pi;
    end
    Fcut1 = getappdata(handles.window,'Fcut1')*k;
    Fcut2 = getappdata(handles.window,'Fcut2')*k;
end

if ng==3 && dragdata < 1
    
    d = 2*diff(ax)/ap(3);
    if get(handles.log_chk,'Value')
        x2 = 10^((xp+d-ax(1))/diff(ax) * diff(log10(ax)) + log10(ax(1)));
        d = x2-x;
    end
    
    if     abs(x-Fcut1) <= d
        pointer  = 'left';
        dragdata = -1;
    elseif abs(x-Fcut2) <= d
        pointer  = 'left';
        dragdata = -2;
    else
        pointer = 'crosshair';
        dragdata = 0;
    end
    set(handles.window,'Pointer',pointer);
    setappdata(handles.window,'dragdata',dragdata);
end

if ~ng && (dragdata == 1 || dragdata == 2 || dragdata == 3) 
    window_WindowButtonUpFcn(hObject, eventdata, handles);
    return
end

if ng == 3 && dragdata == 1 || dragdata == 2
    F = get(handles.coher,'XData');
    if get(handles.Hz_chk,'Value')
        k = 1;
    else
        k = 1/(2*pi);
    end
    if dragdata == 1
        xi = min(Fcut2,F(abs(F-x)==min(abs(F-x))));
        setappdata(handles.window,'Fcut1',xi*k);
        set(handles.cut1str,'Position',[xi 1.06 0],'String',num2str(xi,3));
        set(handles.cut1,'XData',[xi xi]);
    else
        xi = max(Fcut1,F(abs(F-x)==min(abs(F-x))));
        setappdata(handles.window,'Fcut2',xi*k);
        set(handles.cut2str,'Position',[xi 1.06 0],'String',num2str(xi,3));
        set(handles.cut2,'XData',[xi xi]);
    end
end

% --------------------------------------------------------------------
function window_ResizeFcn(hObject, eventdata, handles)
% Funçao de redimensionamento da janela

if isempty(handles) || ~isfield(handles,'graphs')
    return
end

% Limite minimo
ws = get(handles.window,'Position');
sw = 710;
sh = 580;

if ws(3) < sw || ws(4) < sh
    set(handles.window,'Position',[ws(1) ws(2)+ws(4)-max(ws(4),sh) max(ws(3),sw) max(ws(4),sh)]);
end

ws = get(handles.window,'Position');

X = 130;

gx  = 70;
gw  =  ws(3) - (70+20);
gh  = (ws(4) - (X+25+20+45))/3;
gy1 = X+25+20+2*gh;
gy2 = X+25+gh;
gy3 = X;

tx = gx+90;
ty = gy1+gh+10;
tw = gw-180;
th = 16;

set(handles.mag_graph,  'Position',[gx gy1 gw gh]);
set(handles.phase_graph,'Position',[gx gy2 gw gh]);
set(handles.aux_graph,  'Position',[gx gy3 gw gh]);
set(handles.title_str,  'Position',[tx ty tw th]);

set(handles.x_cur,'Position',[ws(3)-90 ws(4)-43 70 15]);
set(handles.y_cur,'Position',[ws(3)-90 ws(4)-28 70 15]);

pos = get(handles.mag_graph,'Position');
ay  = get(handles.mag_graph,'YLim');
set(handles.fminstr,'Position',get(handles.fminstr,'Position').*[1 0 0]+[0 ay(1)-diff(ay)/pos(4)*11 0]);
set(handles.fmaxstr,'Position',get(handles.fmaxstr,'Position').*[1 0 0]+[0 ay(1)-diff(ay)/pos(4)*11 0]);

set(handles.legend_graph,'Position',[gx+gw-65 gy3+gh-38 62 35]);
set(handles.coher_chk,   'Position',[ws(3)-175 90 70 16]);
set(handles.psd_chk,     'Position',[ws(3)-90  90 80 16]);
set(handles.conf_chk,    'Position',[ws(3)-175 70 160 16]);
set(handles.ok_btn,      'Position',[ws(3)-64 15 50 22]);

set(handles.save_btn,    'Position',[ 5 ws(4)-25 22 22]);
set(handles.copy_btn,    'Position',[28 ws(4)-25 22 22]);
set(handles.reset_btn,   'Position',[51 ws(4)-25 22 22]);
set(handles.datatips_btn,'Position',[74 ws(4)-25 22 22]);
set(handles.help_btn,    'Position',[97 ws(4)-25 22 22]);


% --------------------------------------------------------------------
% -- BUTTON FUNCTIONS ------------------------------------------------
% --------------------------------------------------------------------

function save_btn_Callback(hObject, eventdata, handles)
% Salvar resultados

updateplot(hObject, eventdata, handles, 1);

% --------------------------------------------------------------------
function copy_btn_Callback(hObject, eventdata, handles)
% Copia a imagem da janela principal para o Clipboard
% Botoes e objetos de controle sao ocultados para copia

hidehandles = [handles.buttons handles.x_cur handles.y_cur handles.Hz_chk handles.rad_chk,...
        handles.log_chk handles.lin_chk handles.coher_chk handles.psd_chk handles.conf_chk handles.ok_btn];

bgc = get(handles.window,'Color');

list1 = findobj(handles.window,'Color',bgc);
list2 = findobj(handles.window,'BackGroundColor',bgc);

set(list1,'Color','w');
set(list2,'BackGroundColor','w');
set(hidehandles,'Visible','off');

print(handles.window, '-zbuffer','-noui', '-dbitmap');

set(hidehandles,'Visible','on');
set(list1,'Color',bgc);
set(list2,'BackGroundColor',bgc);

% --------------------------------------------------------------------
function reset_btn_Callback(hObject, eventdata, handles)
% Restaurar o zoom total

set([handles.fmin1 handles.fmax1 handles.fmin2 handles.fmax2],'YData',[NaN NaN]);
set([handles.fminstr handles.fmaxstr],'Visible','off');
set(handles.auxlines,'XData',NaN,'YData',NaN);
setappdata(handles.window,'xzoom',[]);

mag   = get(handles.mag,  'YData');
phase = get(handles.phase,'YData');

set(handles.aux_graph,'XLimMode','auto');
set([handles.mag_graph handles.phase_graph],'XLim',get(handles.aux_graph,'XLim'));

if range(mag) < 1e-4
    set(handles.mag_graph,'YLim',mag(1)+[-.5 .5]);
else
    set(handles.mag_graph,'YLimMode','auto');
end
if range(phase) < 1e-4
    set(handles.phase_graph,'YLim',phase(1)+[-.5 .5]);
else
    set(handles.phase_graph,'YLimMode','auto');
end
drawnow;
set([handles.mag_graph handles.phase_graph],'YLimMode','manual');

set([handles.fmin1 handles.fmax1],'YData',get(handles.mag_graph,'YLim'));
set([handles.fmin2 handles.fmax2],'YData',get(handles.phase_graph,'YLim'));
set(handles.lim,'XData',get(handles.aux_graph,'XLim'));

pos = get(handles.mag_graph,'Position');
ay  = get(handles.mag_graph,'YLim');
set(handles.fminstr,'Position',get(handles.fminstr,'Position').*[1 0 0]+[0 ay(1)-diff(ay)/pos(4)*11 0],'Visible','on');
set(handles.fmaxstr,'Position',get(handles.fmaxstr,'Position').*[1 0 0]+[0 ay(1)-diff(ay)/pos(4)*11 0],'Visible','on');

window_WindowButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function datatips_btn_Callback(hObject, eventdata, handles)
% Alternar exibiçao de datatips

if isequalwithequalnans(get(handles.mag,'XData'),NaN)
    set(handles.datatips_btn,'Value',0);
end
updatedatatips(hObject, eventdata, handles);

% -------------------------------------------------------------------
function help_btn_Callback(hObject, eventdata, handles)
% Botao Ajuda

helpme('Dados\analiseespectral','respfreq');

% --------------------------------------------------------------------
function ok_btn_Callback(hObject, eventdata, handles)
% Botao OK

window_CloseRequestFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
% -- CHECKBOX FUNCTIONS ----------------------------------------------
% --------------------------------------------------------------------

function Hz_chk_Callback(hObject, eventdata, handles)
% Define a unidade da abscissa como Hz

set(handles.Hz_chk,'Value',1);
set(handles.rad_chk,'Value',0);
set(handles.xlabel,'String','Frequência (Hz)');
updateplot(hObject, eventdata, handles);
reset_btn_Callback(hObject, eventdata, handles);

% --------------------------------------------------------------------
function rad_chk_Callback(hObject, eventdata, handles)
% Define a unidade da abscissa como rad/s

set(handles.rad_chk,'Value',1);
set(handles.Hz_chk,'Value',0);
set(handles.xlabel,'String','Frequência (rad/s)');
updateplot(hObject, eventdata, handles);
reset_btn_Callback(hObject, eventdata, handles);

% --------------------------------------------------------------------
function lin_chk_Callback(hObject, eventdata, handles)
% Define a escala da abscissa como linear

set(handles.lin_chk,'Value',1);
set(handles.log_chk,'Value',0);

set(handles.graphs,'XScale','linear');
lim_sel_Callback(hObject, eventdata, handles);

% --------------------------------------------------------------------
function log_chk_Callback(hObject, eventdata, handles)
% Define a escala da abscissa como logaritmica

set(handles.lin_chk,'Value',0);
set(handles.log_chk,'Value',1);

set(handles.graphs,'XScale','log');
lim_sel_Callback(hObject, eventdata, handles);

% --------------------------------------------------------------------
function coher_chk_Callback(hObject, eventdata, handles)
% Exibe funçao coerencia

set(handles.coher_chk,'Value',1);
set(handles.psd_chk,'Value',0);
set(handles.ylabel,'String','Coerência');
set([handles.legend_graph; get(handles.legend_graph,'Children')],'Visible','off');
updatetype(hObject, eventdata, handles);

% --------------------------------------------------------------------
function psd_chk_Callback(hObject, eventdata, handles)
% Exibe funçoes espectrais

set(handles.psd_chk,'Value',1);
set(handles.coher_chk,'Value',0);
set(handles.ylabel,'String','Espectros (dB)');
set([handles.legend_graph; get(handles.legend_graph,'Children')],'Visible','on');
updatetype(hObject, eventdata, handles);

% --------------------------------------------------------------------
function conf_chk_Callback(hObject, eventdata, handles)
% Exibir intervalos de confiança

if get(handles.conf_chk,'Value')
    vis = 'on';
else
    vis = 'off';
end

set([handles.fmin1 handles.fmax1 handles.fmin2 handles.fmax2],'Visible','off');
set([handles.fminstr handles.fmaxstr],'Visible','off');
set(handles.auxlines,'XData',NaN,'YData',NaN);
setappdata(handles.window,'xzoom',[]);

set([handles.mag1 handles.mag2 handles.phase1 handles.phase2],'Visible',vis);

mag   = get(handles.mag,  'YData');
phase = get(handles.phase,'YData');

if range(mag) < 1e-4
    set(handles.mag_graph,'YLim',mag(1)+[-.5 .5]);
else
    set(handles.mag_graph,'YLimMode','auto');
end
if range(phase) < 1e-4
    set(handles.phase_graph,'YLim',phase(1)+[-.5 .5]);
else
    set(handles.phase_graph,'YLimMode','auto');
end
drawnow;
set([handles.mag_graph handles.phase_graph],'YLimMode','manual');

set([handles.fmin1 handles.fmax1],'YData',get(handles.mag_graph,  'YLim'),'Visible','on');
set([handles.fmin2 handles.fmax2],'YData',get(handles.phase_graph,'YLim'),'Visible','on');

pos = get(handles.mag_graph,'Position');
ay  = get(handles.mag_graph,'YLim');
set(handles.fminstr,'Position',get(handles.fminstr,'Position').*[1 0 0]+[0 ay(1)-diff(ay)/pos(4)*11 0],'Visible','on');
set(handles.fmaxstr,'Position',get(handles.fmaxstr,'Position').*[1 0 0]+[0 ay(1)-diff(ay)/pos(4)*11 0],'Visible','on');

% --------------------------------------------------------------------
% -- SELECTION LIST FUNCTIONS ----------------------------------------
% --------------------------------------------------------------------

function input_sel_Callback(hObject, eventdata, handles)
global DADOS
% Seleçao do parametro de entrada

n_in  = get(handles.input_sel, 'Value');
n_out = get(handles.output_sel,'Value');

if IsTimeOk(handles.T0)
    try
        X = interp1(handles.T0,denan(DADOS(handles.pts,n_in )),handles.Ti);
        Y = interp1(handles.T0,denan(DADOS(handles.pts,n_out)),handles.Ti);
    catch
        X = denan(DADOS(handles.pts,n_in ));
        Y = denan(DADOS(handles.pts,n_out));
    end
else
    X = denan(DADOS(handles.pts,n_in ));
    Y = denan(DADOS(handles.pts,n_out));
end
X = detrend(X);
Y = detrend(Y);

setappdata(handles.window,'X',X);
setappdata(handles.window,'Y',Y);
updateplot(hObject, eventdata, handles);

% --------------------------------------------------------------------
function output_sel_Callback(hObject, eventdata, handles)
global DADOS
% Seleçao do parametro de saida

n_in  = get(handles.input_sel, 'Value');
n_out = get(handles.output_sel,'Value');

if IsTimeOk(handles.T0)
    try
        X = interp1(handles.T0,denan(DADOS(handles.pts,n_in )),handles.Ti);
        Y = interp1(handles.T0,denan(DADOS(handles.pts,n_out)),handles.Ti);
    catch
        X = denan(DADOS(handles.pts,n_in ));
        Y = denan(DADOS(handles.pts,n_out));
    end
else
    X = denan(DADOS(handles.pts,n_in ));
    Y = denan(DADOS(handles.pts,n_out));
end
X = detrend(X);
Y = detrend(Y);

setappdata(handles.window,'X',X);
setappdata(handles.window,'Y',Y);
updateplot(hObject, eventdata, handles);

% --------------------------------------------------------------------
function nfft_sel_Callback(hObject, eventdata, handles)
% Seleçao do tamanho das seçoes

NFFT = min(handles.N,handles.nfft_list(get(handles.nfft_sel,'Value')));

dt = 1/handles.Fs;
Dt = roundn((NFFT-1)*dt,-1);

set(handles.time_entry,'String',num2str(Dt));
if NFFT < handles.nfft_list(get(handles.nfft_sel,'Value'))
    time_entry_Callback(hObject, eventdata, handles);
end

wndw_sel_Callback(hObject, eventdata, handles);

% --------------------------------------------------------------------
function time_entry_Callback(hObject, eventdata, handles)
% Entrada de tamanho da janela em segundos

Dt = str2double(get(handles.time_entry,'String'));

if isnan(Dt)
    nfft_sel_Callback(hObject, eventdata, handles);
    return
end

dt = 1/handles.Fs;

NFFT = floor(min(handles.N,max(64,Dt/dt+1)));

handles.nfft_list(1) = NFFT;
guidata(hObject, handles);

set(handles.nfft_sel,'String',handles.nfft_list,'Value',1);
nfft_sel_Callback(hObject, eventdata, handles);

% --------------------------------------------------------------------
function ovlp_sel_Callback(hObject, eventdata, handles)
% Seleçao da porcentagem de sobreposiçao das seçoes

updateplot(hObject, eventdata, handles);

% --------------------------------------------------------------------
function wndw_sel_Callback(hObject, eventdata, handles)
% Seleçao do tipo de janelamento

NFFT = min(handles.N,handles.nfft_list(get(handles.nfft_sel,'Value')));
WNDW = feval(handles.wndw_list{get(handles.wndw_sel,'Value'),2},NFFT);
    
set(handles.wndwplot,'XData',linspace(0,1,length(WNDW)),'YData',WNDW);
updateplot(hObject, eventdata, handles);

% --------------------------------------------------------------------
function lim_sel_Callback(hObject, eventdata, handles)
% Seleçao do limite de aceitaçao

updateplot(hObject, eventdata, handles);

% --------------------------------------------------------------------
% -- UPDATE FUNCTIONS ------------------------------------------------
% --------------------------------------------------------------------

function updateplot(hObject, eventdata, handles, savedata)
% Atualiza a plotagem do grafico

if nargin == 3
    savedata = 0;
end

set(handles.window,'Pointer','watch');

Fs = handles.Fs;
X  = getappdata(handles.window,'X');
Y  = getappdata(handles.window,'Y');

NFFT = min(handles.N,handles.nfft_list(get(handles.nfft_sel,'Value')));
OVLP = round(handles.ovlp_list(get(handles.ovlp_sel,'Value'))/100 * NFFT);
WNDW = feval(handles.wndw_list{get(handles.wndw_sel,'Value'),2},NFFT);
n_lim = get(handles.lim_sel,'Value')-1;
F_min = Fs/NFFT;

[Pxx, F] = psd(X,NFFT,Fs,WNDW,OVLP);
[Pyy, F] = psd(Y,NFFT,Fs,WNDW,OVLP);
[Cxy, F] = csd(X,Y,NFFT,Fs,WNDW,OVLP);

Pxx(Pxx==0) = NaN;
Pyy(Pyy==0) = NaN;
Cxy(Cxy==0) = NaN;

F(1)   = [];
Pxx(1) = [];
Pyy(1) = [];
Cxy(1) = [];

F_max = max(F);

if get(handles.rad_chk,'Value')
    Fs = Fs*2*pi;
    F  = F*2*pi;
    F_min = F_min*2*pi;
    F_max = F_max*2*pi;
end

Gxy = abs(Cxy).^2./(abs(Pxx).*abs(Pyy));

set(handles.psdx, 'XData',F,'YData',10*log10(Pxx));
set(handles.psdy, 'XData',F,'YData',10*log10(Pyy));
set(handles.csdxy,'XData',F,'YData',10*log10(Cxy));
set(handles.coher,'XData',F,'YData',Gxy);

if ~n_lim
    LIM = NaN;
    
    Fcut1 = getappdata(handles.window,'Fcut1');
    Fcut2 = getappdata(handles.window,'Fcut2');
    
    if get(handles.rad_chk,'Value')
        Fcut1 = Fcut1*2*pi;
        Fcut2 = Fcut2*2*pi;
    end
    
    if isnan(Fcut2-Fcut1)
        Fcut1 = F(1);
        Fcut2 = F(end);
    end
else
    
    LIM = handles.lim_list(n_lim);
    
    set([handles.lim handles.fmin1 handles.fmax1 handles.fmin2 handles.fmax2],'XData',NaN,'YData',NaN);
    
    acc = find(Gxy >= LIM);
    if isempty(acc)
        Fcut1 = NaN;
        Fcut2 = NaN;
    elseif length(acc) == length(Gxy)
        Fcut1 = min(F);
        Fcut2 = max(F);
    else
        Dacc = diff(acc);
        x = [0 any2row(find(Dacc>1)) length(acc)];
        for n = 2:length(x)
            S(n-1) = acc(x(n)) - acc(x(n-1)+1) +1;
        end
        n = find(S == max(S));
        n = n(1);
        acc = acc(x(n)+1:x(n+1));
        if length(acc) >= 3
            Fcut1 = F(acc(1));
            Fcut2 = F(acc(end));
        else
            Fcut1 = NaN;
            Fcut2 = NaN;
        end
    end
    
end

set(handles.cut1,'XData',Fcut1*[1 1],'YData',[0 1]);
set(handles.cut2,'XData',Fcut2*[1 1],'YData',[0 1]);

if ~isnan(Fcut2-Fcut1)
    set(handles.cut1str,'Position',[Fcut1 1.06 0],'String',num2str(Fcut1,3));
    set(handles.cut2str,'Position',[Fcut2 1.06 0],'String',num2str(Fcut2,3));
else
    set(handles.cut1str,'String','');
    set(handles.cut2str,'String','');
end

if get(handles.Hz_chk,'Value')
    k = 1;
else
    k = 1/(2*pi);
end
setappdata(handles.window,'Fcut1',Fcut1*k);
setappdata(handles.window,'Fcut2',Fcut2*k);

nf = intersect(find(F>=F_min),intersect(find(F>=Fcut1),find(F<=Fcut2)));

if ~isempty(nf)
    H = Cxy(nf)./Pxx(nf);
    
    mag   = abs(H);
    phase = unwrap2(angle(H)*180/pi);
    
    Nw = ceil(handles.N/(NFFT-OVLP));
    Er = sqrt(1-Gxy(nf))./abs(sqrt(Gxy(nf)).*sqrt(2*Nw));
    
    Em1 = 20*log10(mag - 2*mag.*Er);
    Em2 = 20*log10(mag + 2*mag.*Er);
    Ef1 = phase - 2*Er*180/pi;
    Ef2 = phase + 2*Er*180/pi;
    
    mag = 20*log10(mag);

    set(handles.mag   ,'XData',F(nf),'YData',mag);
    set(handles.phase ,'XData',F(nf),'YData',phase);
    
    set(handles.mag1  ,'XData',F(nf),'YData',Em1);
    set(handles.mag2  ,'XData',F(nf),'YData',Em2);
    set(handles.phase1,'XData',F(nf),'YData',Ef1);
    set(handles.phase2,'XData',F(nf),'YData',Ef2);
    
else
    set([handles.mag   handles.mag1   handles.mag2]  ,'XData',NaN,'YData',NaN);
    set([handles.phase handles.phase1 handles.phase2],'XData',NaN,'YData',NaN);
    
    mag   = 0;
    phase = 0;
end

if range(mag) < 1e-4
    set(handles.mag_graph,'YLim',mag(1)+[-.5 .5]);
else
    set(handles.mag_graph,'YLimMode','auto');
end
if range(phase) < 1e-4
    set(handles.phase_graph,'YLim',phase(1)+[-.5 .5]);
else
    set(handles.phase_graph,'YLimMode','auto');
end

set([handles.fmin1 handles.fmax1 handles.fmin2 handles.fmax2 handles.fminstr handles.fmaxstr],'Visible','off');

set(handles.lim,'XData',get(handles.aux_graph,'XLim'),'YData',LIM*[1 1]);
set([handles.mag_graph handles.phase_graph],'XLim',get(handles.aux_graph,'XLim'));

drawnow;
set([handles.mag_graph handles.phase_graph],'YLimMode','manual');

set(handles.fmin1,'XData',F_min*[1 1],'YData',get(handles.mag_graph,'YLim'),  'Visible','on');
set(handles.fmax1,'XData',F_max*[1 1],'YData',get(handles.mag_graph,'YLim'),  'Visible','on');
set(handles.fmin2,'XData',F_min*[1 1],'YData',get(handles.phase_graph,'YLim'),'Visible','on');
set(handles.fmax2,'XData',F_max*[1 1],'YData',get(handles.phase_graph,'YLim'),'Visible','on');

pos = get(handles.mag_graph,'Position');
ay  = get(handles.mag_graph,'YLim');
set(handles.fminstr,'Position',[F_min ay(1)-diff(ay)/pos(4)*11 0],'String',num2str(F_min,3),'Visible','on');
set(handles.fmaxstr,'Position',[F_max ay(1)-diff(ay)/pos(4)*11 0],'String',num2str(F_max,3),'Visible','on');

if savedata
    if ~isempty(nf)
        
        opt = RDAT_InputOption('Opção','O que deseja salvar?',{'Toda a extensão de frequências','Apenas o trecho válido'}, 1, 220, 1);

        if isempty(opt)
            return
        end
        
        if isempty(opt)
            return
        elseif opt == 1
            DADOS2 = [F 10*log10(Pxx) 10*log10(Pyy) 10*log10(Cxy) Gxy NaN*zeros(length(F),6)];
            DADOS2(nf,6:11) = [mag phase Em1-mag Em2-mag Ef1-phase Ef2-phase];
        else
            DADOS2 = [F(nf) 10*log10(Pxx(nf)) 10*log10(Pyy(nf)) 10*log10(Cxy(nf)) Gxy(nf) mag phase Em1-mag Em2-mag Ef1-phase Ef2-phase];
        end
        
        PARAM2 = char({...
                '01-Frequência (Hz)',...
                '02-PSD da Entrada (dB)',...
                '03-PSD da Saída (dB)',...
                '04-PSD Cruzada (dB)',...
                '05-Coerência',...
                '06-Magnitude (dB)',...
                '07-Fase (°)',...
                '08-Int. Conf. Inf. Mag. (dB)',...
                '09-Int. Conf. Sup. Mag. (dB)',...
                '10-Int. Conf. Inf. Fase (°)',...
                '11-Int. Conf. Sup. Fase (°)'});
        if get(handles.rad_chk,'Value'), PARAM2(1,15:21) = '(rad/s)'; end
        
        [fname, fpath] = uiputfile({'*.mat','Arquivo mat (*.mat)'},'Salvar dados da análise',handles.fpath);
        if ischar(fname)
            AuxSaveSlice([fpath fname],DADOS2,PARAM2);
            handles.fpath = fpath;
            guidata(hObject, handles);
        end
    else
        beep; uiwait(errordlg('A análise não contém dados.','Erro','modal'));
    end
end
updatetype(hObject, eventdata, handles);
updatedatatips(hObject, eventdata, handles);

set(handles.window,'Pointer','arrow');

% --------------------------------------------------------------------
function updatedatatips(hObject, eventdata, handles)
% Atualiza apresentaçao dos datatips

if ~get(handles.datatips_btn,'Value')
    
    set(handles.datatips(:,1),'XData',NaN,'YData',NaN);
    set(handles.datatips(:,2),'Position',[0 0],'String','','Visible','off');
    
else
    
    X = get(handles.mag,'XData');
    n = getappdata(handles.window,'datatipn');
    
    if ~all(isnan(X))
        n = min(n,length(X));
        setappdata(handles.window,'datatipn',n);
        
        Y = get(handles.mag,'YData');
        Z = get(handles.phase,'YData');
        
        if ~isnan(X(n)) && ~isnan(Y(n)) && ~isnan(Z(n))
            if get(handles.Hz_chk,'Value')
                unitstr = ' Hz, ';
            else
                unitstr = ' rad/s, ';
            end
            ax = get(handles.mag_graph,'XLim');
            if get(handles.log_chk,'Value');
                if log10(X(n))-log10(ax(1)) < .75*diff(log10(ax))
                    halign = 'left';
                else
                    halign = 'right';
                end
            else
                if X(n)-ax(1) < .75*diff(ax)
                    halign = 'left';
                else
                    halign = 'right';
                end
            end
            ay = get(handles.mag_graph,'YLim');
            if Y(n)-ay(1) < .85*diff(ay)
                valign1 = 'bottom';
            else
                valign1 = 'top';
            end
            ay = get(handles.phase_graph,'YLim');
            if Z(n)-ay(1) < .85*diff(ay)
                valign2 = 'bottom';
            else
                valign2 = 'top';
            end
            set(handles.datatips(1,1),'XData',X(n),'YData',Y(n));
            set(handles.datatips(2,1),'XData',X(n),'YData',Z(n));
            set(handles.datatips(1,2),'Position',[X(n) Y(n)],'String',[' ' num2str(X(n)) unitstr num2str(Y(n)) ' dB'],'Visible','on',...
                'VerticalAlignment',valign1,'HorizontalAlignment',halign);
            set(handles.datatips(2,2),'Position',[X(n) Z(n)],'String',[' ' num2str(X(n)) unitstr num2str(Z(n)) '°'],'Visible','on',...
                'VerticalAlignment',valign2,'HorizontalAlignment',halign);
        else
            set(handles.datatips(np,1),'XData',NaN,'YData',NaN);
            set(handles.datatips(np,2),'Position',[0 0],'String','','Visible','off');
        end
    else
        set(handles.datatips(:,1),'XData',NaN,'YData',NaN);
        set(handles.datatips(:,2),'Position',[0 0],'String','','Visible','off');
    end
end

% --------------------------------------------------------------------
function updatetype(hObject, eventdata, handles)
% Atualiza o tipo do grafico coerencia x psd

if get(handles.coher_chk,'Value')
    set([handles.psdx handles.psdy handles.csdxy],'Visible','off');
    set([handles.coher handles.lim handles.cut1 handles.cut2 handles.cut1str handles.cut2str],'Visible','on');
    set(handles.aux_graph,'YLimMode','manual','YLim',[0 1.01],'YTick',[0 .2 .4 .6 .8 1]);
else
    set([handles.psdx handles.psdy handles.csdxy],'Visible','on');
    set([handles.coher handles.lim handles.cut1 handles.cut2 handles.cut1str handles.cut2str],'Visible','off');
    set(handles.aux_graph,'YLimMode','auto','YTickMode','auto');
end

% --------------------------------------------------------------------
% -- AUXILIARY FUNCTIONS ---------------------------------------------
% --------------------------------------------------------------------

function AuxSaveSlice(fname,DADOS,PARAM)
% Funçao auxiliar para salvar os resultados como .mat
% Usa workspace local e DADOS / PARAM como argumentos para preservar DADOS original

save(fname,'DADOS','PARAM',saveopt);

% --------------------------------------------------------------------
function [ng, x, y, ax, ay, ap, xp]  = getcurrentgraph(hObject, eventdata, handles)
% Funçao que obtem o numero do grafico sobre o qual está o cursor

cp = get(handles.window,'CurrentPoint') + [.5 .5];

ng = 0;
for n = 1:3
    ap = get(handles.graphs(n),'Position');
    ax = get(handles.graphs(n),'XLim');
    ay = get(handles.graphs(n),'YLim');
    
    x = (cp(1)-ap(1))*(ax(2)-ax(1))/ap(3) + ax(1);
    y = (cp(2)-ap(2))*(ay(2)-ay(1))/ap(4) + ay(1);
    
    xp = x;
    if get(handles.log_chk,'Value')
        xp = x;
        x = 10^((x-ax(1))/diff(ax) * diff(log10(ax)) + log10(ax(1)));
    end
    
    if x >= ax(1) && x <= ax(2) && y >= ay(1) && y <= ay(2);
        ng = n;
        break
    end
end

% --------------------------------------------------------------------
function X = any2row(X)
% Funçao que transforma um vetor qualquer em vetor linha

X = X(:)';
