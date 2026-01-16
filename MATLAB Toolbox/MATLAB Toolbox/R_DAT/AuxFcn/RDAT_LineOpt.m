function varargout = RDAT_LineOpt(varargin)
% RDAT_LINEOPT M-file for RDAT_LineOpt.fig
% Last Modified by GUIDE v2.5 07-Dec-2010 10:05:26

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RDAT_LineOpt_OpeningFcn, ...
                   'gui_OutputFcn',  @RDAT_LineOpt_OutputFcn, ...
                   'gui_LayoutFcn',  @RDAT_LineOpt_LayoutFcn, ...
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

% -------------------------------------------------------------------
function h = RDAT_LineOpt_LayoutFcn(varargin)
% Função de layout inicial

h = openfig('RDAT_LineOpt.fig','reuse','invisible');

% -------------------------------------------------------------------
function RDAT_LineOpt_OpeningFcn(hObject, eventdata, handles, varargin)
% Funçao de abertura

ss = get(0,'ScreenSize');
ws = get(handles.window,'Position');
set(handles.window,'Position',[.5*(ss(3)-ws(3)) .5*(ss(4)-ws(4)) ws(3) ws(4)],'Visible','on');

handles.ok = 0;

if ~isempty(varargin)
    linespec = varargin{1};
    bgcolor = varargin{2};
else
    load(which('DatOptions.mat'));
    bgcolor = colorspec.graphcolor;
end
set(handles.axes1,'Color',bgcolor);

bgc = getbuttoncolor(handles.window);
set(handles.reset_btn,'CData',geticon('DatButtons.mat','defcolr',bgc));
set(handles.help_btn, 'CData',geticon('DatButtons.mat','help',   bgc));

x = [.2; .5; .8]*60;
y = [0; 0; 0];
handles.plot1 = plot(x,y+140);
handles.plot2 = plot(x,y+110);
handles.plot3 = plot(x,y+80);
handles.plot4 = plot(x,y+50);
handles.plot5 = plot(x,y+20);

handles.plots    = [handles.plot1    handles.plot2    handles.plot3    handles.plot4    handles.plot5];
handles.lines    = [handles.line1    handles.line2    handles.line3    handles.line4    handles.line5];
handles.colors   = [handles.color1   handles.color2   handles.color3   handles.color4   handles.color5];
handles.widths   = [handles.width1   handles.width2   handles.width3   handles.width4   handles.width5];
handles.markers  = [handles.marker1  handles.marker2  handles.marker3  handles.marker4  handles.marker5];
handles.msizes   = [handles.msize1   handles.msize2   handles.msize3   handles.msize4   handles.msize5];
handles.mcolors  = [handles.mcolor1  handles.mcolor2  handles.mcolor3  handles.mcolor4  handles.mcolor5];
handles.mfcolors = [handles.mfcolor1 handles.mfcolor2 handles.mfcolor3 handles.mfcolor4 handles.mfcolor5];

linestyles = {'Sólida','Tracejada','Pontilhada','Traço-ponto','Sem linha'};
markers = {'Cruz','Círculo','Asterisco','Ponto','Xis','Quadrado','Losango','Triângulo','Nenhum'};
widths = [1 2 3 4];
msizes = [2 3 5 6 8];

for n = 1:5;
    set(handles.plots(n),...
        'LineStyle',       linespec(n).linestyle,...
        'Color',           linespec(n).color,...
        'LineWidth',       linespec(n).linewidth,...
        'Marker',          linespec(n).marker,...
        'MarkerEdgeColor', linespec(n).markeredgecolor,...
        'MarkerFaceColor', linespec(n).markerfacecolor,...
        'MarkerSize',      linespec(n).markersize);
    
    set(handles.lines(n),'String',linestyles,'Value',value2num('line',linespec(n).linestyle));
    set(handles.widths(n),'String',num2str(widths'),'Value',value2num('width',linespec(n).linewidth));
    set(handles.markers(n),'String',markers,'Value',value2num('marker',linespec(n).marker));
    set(handles.msizes(n),'String',num2str(msizes'),'Value',value2num('msize',linespec(n).markersize));
    
    set(handles.colors(n),'BackgroundColor',linespec(n).color);
    set(handles.mcolors(n),'BackgroundColor',linespec(n).markeredgecolor);
    if isequal(linespec(n).markerfacecolor,'none')
        set(handles.mfcolors(n),'BackgroundColor',get(handles.window,'Color'),'String','X');
    else
        set(handles.mfcolors(n),'BackgroundColor',linespec(n).markerfacecolor);
    end
end

setappdata(handles.window,'button','cancel');
guidata(hObject, handles);
uiwait(handles.window);

% -------------------------------------------------------------------
function varargout = RDAT_LineOpt_OutputFcn(hObject, eventdata, handles)
% Funçao de saida

if handles.ok
    for n = 1:5;
        linespec(n).linestyle       = get(handles.plots(n),'LineStyle');
        linespec(n).color           = get(handles.plots(n),'Color'); 
        linespec(n).linewidth       = get(handles.plots(n),'LineWidth');
        linespec(n).marker          = get(handles.plots(n),'Marker');
        linespec(n).markeredgecolor = get(handles.plots(n),'MarkerEdgeColor');
        linespec(n).markerfacecolor = get(handles.plots(n),'MarkerFaceColor');
        linespec(n).markersize      = get(handles.plots(n),'MarkerSize');
    end    
    varargout{1} = linespec;
else
    varargout{1} = [];
end
delete(handles.window);

% -------------------------------------------------------------------
function help_btn_Callback(hObject, eventdata, handles)
% Botao Ajuda

helpme('Editar\editarlinhas');

% -------------------------------------------------------------------
function ok_btn_Callback(hObject, eventdata, handles)
% Botao OK

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

% -------------------------------------------------------------------
function reset_btn_Callback(hObject, eventdata, handles)
% Botao Redefinir

button = questdlg('Deseja redefinir todas as linhas?','Confirmação','Sim','Não','Não');

if strcmp(button,'Sim')
    
    linespec(1).linestyle       = '-';
    linespec(1).color           = [0 0 1];
    linespec(1).linewidth       = 1;
    linespec(1).marker          = '.';
    linespec(1).markeredgecolor = [0 0 1];
    linespec(1).markerfacecolor = 'none';
    linespec(1).markersize      = 5;
    
    linespec(2).linestyle       = '-';
    linespec(2).color           = [1 0 0];
    linespec(2).linewidth       = 1;
    linespec(2).marker          = '.';
    linespec(2).markeredgecolor = [1 0 0];
    linespec(2).markerfacecolor = 'none';
    linespec(2).markersize      = 5;
    
    linespec(3).linestyle       = '-';
    linespec(3).color           = [0 0.8000 0];
    linespec(3).linewidth       = 1;
    linespec(3).marker          = '.';
    linespec(3).markeredgecolor = [0 0.8000 0];
    linespec(3).markerfacecolor = 'none';
    linespec(3).markersize      = 5;
    
    linespec(4).linestyle       = '-';
    linespec(4).color           = [1 0 1];
    linespec(4).linewidth       = 1;
    linespec(4).marker          = '.';
    linespec(4).markeredgecolor = [1 0 1];
    linespec(4).markerfacecolor = 'none';
    linespec(4).markersize      = 5;
    
    linespec(5).linestyle       = '-';
    linespec(5).color           = [0 1 1];
    linespec(5).linewidth       = 1;
    linespec(5).marker          = '.';
    linespec(5).markeredgecolor = [0 1 1];
    linespec(5).markerfacecolor = 'none';
    linespec(5).markersize      = 5;
    
    linestyles = {'Sólida','Tracejada','Pontilhada','Traço-ponto','Sem linha'};
    markers = {'Cruz','Círculo','Asterisco','Ponto','Xis','Quadrado','Losango','Triângulo','Nenhum'};
    widths = [1 2 3 4];
    msizes = [2 3 5 6 8];
    
    for n = 1:5;
        set(handles.plots(n),...
            'LineStyle',       linespec(n).linestyle,...
            'Color',           linespec(n).color,...
            'LineWidth',       linespec(n).linewidth,...
            'Marker',          linespec(n).marker,...
            'MarkerEdgeColor', linespec(n).markeredgecolor,...
            'MarkerFaceColor', linespec(n).markerfacecolor,...
            'MarkerSize',      linespec(n).markersize);
        
        set(handles.lines(n),'String',linestyles,'Value',value2num('line',linespec(n).linestyle));
        set(handles.widths(n),'String',num2str(widths'),'Value',value2num('width',linespec(n).linewidth));
        set(handles.markers(n),'String',markers,'Value',value2num('marker',linespec(n).marker));
        set(handles.msizes(n),'String',num2str(msizes'),'Value',value2num('msize',linespec(n).markersize));
        
        set(handles.colors(n),'BackgroundColor',linespec(n).color);
        set(handles.mcolors(n),'BackgroundColor',linespec(n).markeredgecolor);
        if isequal(linespec(n).markerfacecolor,'none')
            set(handles.mfcolors(n),'BackgroundColor',get(handles.window,'Color'),'String','X');
        else
            set(handles.mfcolors(n),'BackgroundColor',linespec(n).markerfacecolor);
        end
    end
    
end

% -------------------------------------------------------------------
function line1_Callback(hObject, eventdata, handles)
popup_update(handles,get(gcbo,'Tag'),get(gcbo,'Value'));

% -------------------------------------------------------------------
function line2_Callback(hObject, eventdata, handles)
popup_update(handles,get(gcbo,'Tag'),get(gcbo,'Value'));

% -------------------------------------------------------------------
function line3_Callback(hObject, eventdata, handles)
popup_update(handles,get(gcbo,'Tag'),get(gcbo,'Value'));

% -------------------------------------------------------------------
function line4_Callback(hObject, eventdata, handles)
popup_update(handles,get(gcbo,'Tag'),get(gcbo,'Value'));

% -------------------------------------------------------------------
function line5_Callback(hObject, eventdata, handles)
popup_update(handles,get(gcbo,'Tag'),get(gcbo,'Value'));

% -------------------------------------------------------------------
function width1_Callback(hObject, eventdata, handles)
popup_update(handles,get(gcbo,'Tag'),get(gcbo,'Value'));

% -------------------------------------------------------------------
function width2_Callback(hObject, eventdata, handles)
popup_update(handles,get(gcbo,'Tag'),get(gcbo,'Value'));

% -------------------------------------------------------------------
function width3_Callback(hObject, eventdata, handles)
popup_update(handles,get(gcbo,'Tag'),get(gcbo,'Value'));

% -------------------------------------------------------------------
function width4_Callback(hObject, eventdata, handles)
popup_update(handles,get(gcbo,'Tag'),get(gcbo,'Value'));

% -------------------------------------------------------------------
function width5_Callback(hObject, eventdata, handles)
popup_update(handles,get(gcbo,'Tag'),get(gcbo,'Value'));

% -------------------------------------------------------------------
function color1_Callback(hObject, eventdata, handles)
color_update(handles,get(gcbo,'Tag'),get(gcbo,'Value'));

% -------------------------------------------------------------------
function color2_Callback(hObject, eventdata, handles)
color_update(handles,get(gcbo,'Tag'),get(gcbo,'Value'));

% -------------------------------------------------------------------
function color3_Callback(hObject, eventdata, handles)
color_update(handles,get(gcbo,'Tag'),get(gcbo,'Value'));

% -------------------------------------------------------------------
function color4_Callback(hObject, eventdata, handles)
color_update(handles,get(gcbo,'Tag'),get(gcbo,'Value'));

% -------------------------------------------------------------------
function color5_Callback(hObject, eventdata, handles)
color_update(handles,get(gcbo,'Tag'),get(gcbo,'Value'));

% -------------------------------------------------------------------
function marker1_Callback(hObject, eventdata, handles)
popup_update(handles,get(gcbo,'Tag'),get(gcbo,'Value'));

% -------------------------------------------------------------------
function marker2_Callback(hObject, eventdata, handles)
popup_update(handles,get(gcbo,'Tag'),get(gcbo,'Value'));

% -------------------------------------------------------------------
function marker3_Callback(hObject, eventdata, handles)
popup_update(handles,get(gcbo,'Tag'),get(gcbo,'Value'));

% -------------------------------------------------------------------
function marker4_Callback(hObject, eventdata, handles)
popup_update(handles,get(gcbo,'Tag'),get(gcbo,'Value'));

% -------------------------------------------------------------------
function marker5_Callback(hObject, eventdata, handles)
popup_update(handles,get(gcbo,'Tag'),get(gcbo,'Value'));

% -------------------------------------------------------------------
function msize1_Callback(hObject, eventdata, handles)
popup_update(handles,get(gcbo,'Tag'),get(gcbo,'Value'));

% -------------------------------------------------------------------
function msize2_Callback(hObject, eventdata, handles)
popup_update(handles,get(gcbo,'Tag'),get(gcbo,'Value'));

% -------------------------------------------------------------------
function msize3_Callback(hObject, eventdata, handles)
popup_update(handles,get(gcbo,'Tag'),get(gcbo,'Value'));

% -------------------------------------------------------------------
function msize4_Callback(hObject, eventdata, handles)
popup_update(handles,get(gcbo,'Tag'),get(gcbo,'Value'));

% -------------------------------------------------------------------
function msize5_Callback(hObject, eventdata, handles)
popup_update(handles,get(gcbo,'Tag'),get(gcbo,'Value'));

% -------------------------------------------------------------------
function mcolor1_Callback(hObject, eventdata, handles)
color_update(handles,get(gcbo,'Tag'),get(gcbo,'Value'));

% -------------------------------------------------------------------
function mcolor2_Callback(hObject, eventdata, handles)
color_update(handles,get(gcbo,'Tag'),get(gcbo,'Value'));

% -------------------------------------------------------------------
function mcolor3_Callback(hObject, eventdata, handles)
color_update(handles,get(gcbo,'Tag'),get(gcbo,'Value'));

% -------------------------------------------------------------------
function mcolor4_Callback(hObject, eventdata, handles)
color_update(handles,get(gcbo,'Tag'),get(gcbo,'Value'));

% -------------------------------------------------------------------
function mcolor5_Callback(hObject, eventdata, handles)
color_update(handles,get(gcbo,'Tag'),get(gcbo,'Value'));

% -------------------------------------------------------------------
function mfcolor1_Callback(hObject, eventdata, handles)
color_update(handles,get(gcbo,'Tag'),get(gcbo,'Value'));

% -------------------------------------------------------------------
function mfcolor2_Callback(hObject, eventdata, handles)
color_update(handles,get(gcbo,'Tag'),get(gcbo,'Value'));

% -------------------------------------------------------------------
function mfcolor3_Callback(hObject, eventdata, handles)
color_update(handles,get(gcbo,'Tag'),get(gcbo,'Value'));

% -------------------------------------------------------------------
function mfcolor4_Callback(hObject, eventdata, handles)
color_update(handles,get(gcbo,'Tag'),get(gcbo,'Value'));

% -------------------------------------------------------------------
function mfcolor5_Callback(hObject, eventdata, handles)
color_update(handles,get(gcbo,'Tag'),get(gcbo,'Value'));

% -------------------------------------------------------------------
function window_KeyPressFcn(hObject, eventdata, handles)
% Acionamento de tecla do teclado

cc = get(handles.window,'CurrentCharacter');

if isempty(cc)
    return
end

switch abs(cc)
    
    case {abs('r'),abs('r')}
        reset_btn_Callback(hObject, eventdata, handles);
        
    case 13 % Enter
        ok_btn_Callback(hObject, eventdata, handles);
        
    case 27 % Esc
        cancel_btn_Callback(hObject, eventdata, handles);
        
end

% -------------------------------------------------------------------
function window_CloseRequestFcn(hObject, eventdata, handles)
% Funçao de fechamento da janela

cancel_btn_Callback(hObject, eventdata, handles);

% -------------------------------------------------------------------
function n = value2num(opt,value)
% Converte um valor em um indice de lista de seleçao

switch opt
    case 'line'
        linestyles = {'-','--',':','-.','none'};
        n = strmatch(value,linestyles,'exact');
        
    case 'marker'
        markers = {'+','o','*','.','x','square','diamond','^','none'};
        n = strmatch(value,markers,'exact');
        
    case 'width'
        widths = [1 2 3 4];
        n = find(value==widths);
        
    case 'msize'
        msizes = [2 3 5 6 8];
        n = find(value==msizes);
        
end        

% -------------------------------------------------------------------
function popup_update(handles,tag,val)
% Listas de seleçao de tipo e tamanho

n = str2num(tag(end));
tag(end) = [];
switch tag
    case 'line'
        linestyles = {'-','--',':','-.','none'};
        set(handles.plots(n),'LineStyle',linestyles{val});
    case 'width'
        widths = [1 2 3 4];
        set(handles.plots(n),'LineWidth',widths(val));
    case 'marker'
        markers = {'+','o','*','.','x','square','diamond','^','none'};
        set(handles.plots(n),'Marker',markers{val});
    case 'msize'
        msizes = [2 3 5 6 8];
        set(handles.plots(n),'MarkerSize',msizes(val));
end

% -------------------------------------------------------------------
function color_update(handles,tag,val)
% Botoes de seleçao de cores

n = str2num(tag(end));
tag(end) = [];
switch tag
    case 'color'
        color = uisetcolor(get(handles.colors(n),'BackgroundColor'));
        if length(color) == 3
            set(handles.plots(n),'Color',color);
            set(handles.colors(n),'BackgroundColor',color);
        end
    case 'mcolor'
        mcolor = uisetcolor(get(handles.mcolors(n),'BackgroundColor'));
        if length(mcolor) == 3
            set(handles.plots(n),'MarkerEdgeColor',mcolor);
            set(handles.mcolors(n),'BackgroundColor',mcolor);
        end
    case 'mfcolor'
        if isequal(get(handles.plots(n),'MarkerFaceColor'),'none')
            mfcolor = uisetcolor;
        else
            mfcolor = uisetcolor(get(handles.mfcolors(n),'BackgroundColor'));
        end
        if length(mfcolor) == 3
            transp = 0;
            if isequal(mfcolor, [1 1 1])
                button = questdlg('Confirme a cor interna dos marcadores:','Opção','Branca','Transparente','Branca');
                if strcmp(button,'Transparente')
                    transp = 1;
                end
            end
            if ~transp;
                set(handles.plots(n),'MarkerFaceColor',mfcolor);
                set(handles.mfcolors(n),'BackgroundColor',mfcolor,'String','');
            else
                set(handles.plots(n),'MarkerFaceColor','none');
                set(handles.mfcolors(n),'BackgroundColor',get(handles.window,'Color'),'String','X');
            end
        end
end
