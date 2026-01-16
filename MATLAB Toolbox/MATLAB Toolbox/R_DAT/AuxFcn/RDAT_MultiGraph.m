function varargout = RDAT_MultiGraph(varargin)
% RDAT_MULTIGRAPH M-file for RDAT_MultiGraph.fig
% Last Modified by GUIDE v2.5 28-Jul-2009 11:23:07

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RDAT_MultiGraph_OpeningFcn, ...
                   'gui_OutputFcn',  @RDAT_MultiGraph_OutputFcn, ...
                   'gui_LayoutFcn',  @RDAT_MultiGraph_LayoutFcn, ...
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
function h = RDAT_MultiGraph_LayoutFcn(varargin)
% Função de layout inicial

h = openfig('RDAT_MultiGraph.fig','reuse','visible');

% --------------------------------------------------------------------
function RDAT_MultiGraph_OpeningFcn(hObject, eventdata, handles, varargin)
% Funçao de abertura

ss = get(0,'ScreenSize');
ws = get(handles.window,'Position');
set(handles.window,'Position',[4 ss(4)-ws(4)-25 ws(3) ws(4)]);

handles.multiplots = varargin{1};
handles.hcaller    = varargin{2};
handles.borders    = varargin{3};

PARAM              = get(handles.hcaller.xlist,'String');
xcol               = get(handles.hcaller.xlist,'Value');
handles.plot       = handles.hcaller.plot;
handles.xlabel     = handles.hcaller.xlabel;
handles.mainwindow = handles.hcaller.window;
handles.allgraphs  = handles.hcaller.graphs;
handles.ylabels    = handles.hcaller.ylabels;

handles.y = [handles.y1; handles.y2; handles.y3;...
        handles.y4;  handles.y5;  handles.y6;...
        handles.y7;  handles.y8;  handles.y9;...
        handles.y10; handles.y11; handles.y12;...
        handles.y13; handles.y14; handles.y15];

set(handles.y,'String',char(' ',char(PARAM)));
set(handles.x,'String',PARAM,'Value',xcol);

if strcmp(get(handles.hcaller.RememberMultiPar,'Checked'),'on')
    parlist = getappdata(handles.hcaller.window,'mg3x5_list');
    for n = 1:15
        npar = findpar(PARAM,parlist{n},0,1);
        if npar
            set(handles.y(n),'Value',npar+1);
            UpdatePlot(hObject, eventdata, handles, n);
        end
    end
end

guidata(hObject, handles);

% --------------------------------------------------------------------
function varargout = RDAT_MultiGraph_OutputFcn(hObject, eventdata, handles)
% Funçao de saida

varargout{1} = handles.window;

% --------------------------------------------------------------------
function y1_Callback(hObject, eventdata, handles)
UpdatePlot(hObject, eventdata, handles, 1);

% --------------------------------------------------------------------
function y2_Callback(hObject, eventdata, handles)
UpdatePlot(hObject, eventdata, handles, 2);

% --------------------------------------------------------------------
function y3_Callback(hObject, eventdata, handles)
UpdatePlot(hObject, eventdata, handles, 3);

% --------------------------------------------------------------------
function y4_Callback(hObject, eventdata, handles)
UpdatePlot(hObject, eventdata, handles, 4);

% --------------------------------------------------------------------
function y5_Callback(hObject, eventdata, handles)
UpdatePlot(hObject, eventdata, handles, 5);

% --------------------------------------------------------------------
function y6_Callback(hObject, eventdata, handles)
UpdatePlot(hObject, eventdata, handles, 6);

% --------------------------------------------------------------------
function y7_Callback(hObject, eventdata, handles)
UpdatePlot(hObject, eventdata, handles, 7);

% --------------------------------------------------------------------
function y8_Callback(hObject, eventdata, handles)
UpdatePlot(hObject, eventdata, handles, 8);

% --------------------------------------------------------------------
function y9_Callback(hObject, eventdata, handles)
UpdatePlot(hObject, eventdata, handles, 9);

% --------------------------------------------------------------------
function y10_Callback(hObject, eventdata, handles)
UpdatePlot(hObject, eventdata, handles, 10);

% --------------------------------------------------------------------
function y11_Callback(hObject, eventdata, handles)
UpdatePlot(hObject, eventdata, handles, 11);

% --------------------------------------------------------------------
function y12_Callback(hObject, eventdata, handles)
UpdatePlot(hObject, eventdata, handles, 12);

% --------------------------------------------------------------------
function y13_Callback(hObject, eventdata, handles)
UpdatePlot(hObject, eventdata, handles, 13);

% --------------------------------------------------------------------
function y14_Callback(hObject, eventdata, handles)
UpdatePlot(hObject, eventdata, handles, 14);

% --------------------------------------------------------------------
function y15_Callback(hObject, eventdata, handles)
UpdatePlot(hObject, eventdata, handles, 15);

% --------------------------------------------------------------------
function x_Callback(hObject, eventdata, handles)
global DADOS
% Seleçao da abscissa

PARAM = get(handles.x,'String');
nx = get(handles.x,'Value');
set(handles.plot,'XData',DADOS(:,nx));
set(handles.allgraphs,'XLim',autolim(handles.plot));
set(handles.xlabel,'String',PARAM{nx}(4:end));
for n = 1:15
    ny = get(handles.y(n),'Value')-1;
    if ny
        set(handles.multiplots(n),'XData',DADOS(:,nx),'YData',DADOS(:,ny));
    else
        set(handles.multiplots(n),'XData',NaN,'YData',NaN);
    end
end

% --------------------------------------------------------------------
function UpdatePlot(hObject, eventdata, handles, n)
global DADOS
% Atualiza os plotes

ny = get(handles.y(n),'Value')-1;
nx = get(handles.x,'Value');
if ny
    set(handles.multiplots(n),'XData',DADOS(:,nx),'YData',DADOS(:,ny));
else
    set(handles.multiplots(n),'XData',NaN,'YData',NaN);
end

npar = cell2mat(get(handles.y,'Value'))-1;
for n = 1:5
    ngraph(n) = sum(npar(3*n-2:3*n));
end
ngraph = max(find(ngraph));

setgraph(hObject, eventdata, handles, ngraph);

% --------------------------------------------------------------------
function window_KeyPressFcn(hObject, eventdata, handles)
% Acionamento de tecla do teclado

cc = get(handles.window,'CurrentCharacter');

if ~isempty(cc) && cc == 27 % Esc
    window_CloseRequestFcn(hObject, eventdata, handles);
end

% --------------------------------------------------------------------
function window_CloseRequestFcn(hObject, eventdata, handles)
% Funçao de fechamento da janela

button = questdlg('Deseja sair?','Confirmação','Sim','Não','Não');
if strcmp(button,'Sim')
    
    if strcmp(get(handles.hcaller.RememberMultiPar,'Checked'),'on')
        PARAM   = get(handles.hcaller.xlist,'String');
        parlist = getappdata(handles.hcaller.window,'mg3x5_list');
        for n = 1:15
            npar = get(handles.y(n),'Value')-1;
            if npar
                parlist{n} = denumber(PARAM{npar});
            else
                parlist{n} = '';
            end
        end
        setappdata(handles.hcaller.window,'mg3x5_list',parlist);
    end
    
    delete(handles.window);
end

% --------------------------------------------------------------------
function setgraph(hObject, eventdata, handles, ngraph)
% Funçao que ajusta n graficos na tela

ws = get(handles.mainwindow,'Position');
bu = handles.borders(1);  % Up
bd = handles.borders(2);  % Down
bl = handles.borders(3);  % Left
br = handles.borders(4);  % Right

b = 22; % Borda entre graficos
Ax = ws(3)-bl-br; % Largura dos graficos
Ay = ws(4)-bu-bd; % Altura disponivel dos graficos

for n = 1:ngraph
    
    ay = (Ay-(ngraph-1)*b)/ngraph;
    py = bd+(ngraph-n)*(ay+b);
    
    set(handles.allgraphs(n),'Position',[bl py Ax ay],'Visible','on');
    set(handles.ylabels(n),'Position',[-50, ay/2, 0]);
end

set(handles.allgraphs,'XLim',get(handles.allgraphs(1),'XLim'));
set(handles.allgraphs(ngraph+1:end),'Visible','off');

set(handles.allgraphs(ngraph),'XTickLabelMode','auto');
set(handles.allgraphs(setdiff(1:5,ngraph)),'XTickLabel',[]);

% --------------------------------------------------------------------
function ax = autolim(h)
% Funçao que ajusta os limites do eixo x dos graficos

xmin = min(get(h,'XData'));
xmax = max(get(h,'XData'));
dx = xmax-xmin;

if isnan(dx)
    ax = [0 1];
elseif dx < 1e-4
    ax = [xmin-.5 xmax+.5];
else
    ax = [xmin-.05*dx xmax+.05*dx];
end
