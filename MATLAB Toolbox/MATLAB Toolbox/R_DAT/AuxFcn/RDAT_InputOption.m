function varargout = RDAT_InputOption(varargin)
% RDAT_INPUTOPTION M-file for RDAT_InputOption.fig
% Funçao para apresentaçao de opçoes ao usuario
% Sintaxe: opt = RDAT_InputOption(name, title, options, default, window width, showicon)
% Last Modified by GUIDE v2.5 12-May-2010 17:06:35

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RDAT_InputOption_OpeningFcn, ...
                   'gui_OutputFcn',  @RDAT_InputOption_OutputFcn, ...
                   'gui_LayoutFcn',  @RDAT_InputOption_LayoutFcn, ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1}) && isvarname(varargin{1})
    try
        gui_State.gui_Callback = str2func(varargin{1});
    end
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

% ---------------------------------------------------------------------
function h = RDAT_InputOption_LayoutFcn(varargin)
% Função de layout inicial

h = openfig('RDAT_InputOption.fig','reuse','invisible');

% ---------------------------------------------------------------------
function RDAT_InputOption_OpeningFcn(hObject, eventdata, handles, varargin)

if length(varargin) >= 3
    namestr  = varargin{1};
    titlestr = varargin{2};
    labels   = varargin{3};
    if ischar(titlestr)
        titlestr = cellstr(titlestr);
    end
    if ischar(labels)
        labels   = cellstr(labels);
    end
    if length(varargin) >= 4
        def = varargin{4};
    else
        def = 1;
    end
    if length(varargin) >= 5
        ww = max(160,varargin{5});
    else
        ww = 220;
    end
    if length(varargin) >= 6
        showicon = varargin{6};
    else
        showicon = 0;
    end
else
    namestr  = 'Confirmação';
    titlestr = {'Informe a opção:'};
    labels   = {'Opção 1','Opção 2','Opção 3'};
    def = 1;
    ww = 220;
    showicon = 0;
    set(handles.window,'WindowStyle','normal');
end

handles.hcheck = [handles.check01, handles.check02, handles.check03, handles.check04,...
        handles.check05, handles.check06, handles.check07, handles.check08,...
        handles.check09, handles.check10, handles.check11, handles.check12];

for n = length(titlestr):-1:1
    if ~ischar(titlestr{n}) && isempty(titlestr{n})
        titlestr(n) = [];
    end
end

if length(labels) > 12
    labels(13:end) = [];
end
if length(def) > 12
    def(13:end) = [];
end

if length(def) > 1 || islogical(def)
    set(handles.hcheck,'Style','checkbox');
    handles.opt = 0;
else
    set(handles.hcheck,'Enable','inactive');
    handles.opt = 1;
end

T = length(titlestr);
N = length(labels);

if length(def) == 1
    set(handles.hcheck(def),'Value',1);
else
    set(handles.hcheck(find(def)),'Value',1);
end

set(handles.window,'Name',namestr);
set(handles.title_txt,'String',titlestr,'Position',get(handles.title_txt,'Position').*[1 1 0 T]+[0 0 ww-20 0]);

for n = 1:N
    set(handles.hcheck(n),'String',labels{n},'Position',get(handles.hcheck(n),'Position').*[1 1 0 1]+[0 0 ww-20 0]);
end

ss = get(0,'ScreenSize');

if N < 12
    set(handles.hcheck(N+1:12),'Visible','off');
    
    for n = 1:N
        set(handles.hcheck(n),'Position',get(handles.hcheck(n),'Position')-[0 (12-N)*20 0 0]);
    end
    set(handles.title_txt,'Position',get(handles.title_txt,'Position')-[0 (12-N)*20 0 0]);
end

ws = get(handles.window,'Position');
set(handles.window,'Position',[ws(1) ws(2) ww ws(4)+15*(T-1)-(12-N)*20]);
bp = get(handles.ok_btn,'Position');
set(handles.ok_btn,'Position',[ww/2-10-bp(3) bp(2:4)]);
bp = get(handles.cancel_btn,'Position');
set(handles.cancel_btn,'Position',[ww/2+10 bp(2:4)]);

if showicon
    
    ws = get(handles.window,'Position');

    IconW = 48;
    IconH = 48;
    IconX = 10;
    IconY = (ws(4)-IconH)/2+10;
    D = IconX+IconW;

    set(handles.window,'Position',get(handles.window,'Position')+[0 0 D 0]);
    set(handles.title_txt,'Position',get(handles.title_txt,'Position')+[D 0 0 0]);
    for n = 1:12
        set(handles.hcheck(n),'Position',get(handles.hcheck(n),'Position')+[D 0 0 0]);
    end
    set(handles.ok_btn,'Position',get(handles.ok_btn,'Position')+[D/2 0 0 0]);
    set(handles.cancel_btn,'Position',get(handles.cancel_btn,'Position')+[D/2 0 0 0]);
    
    figure(handles.window);
    IconAxes = axes('Units','pixels','Position',[IconX IconY IconW IconH]);
    
    load dialogicons.mat
    IconData = questIconData;
    questIconMap(256,:) = get(handles.window,'Color');
    IconCMap = questIconMap;
    
    Img = image('CData',IconData);
    colormap(IconCMap);
    set(IconAxes, ...
        'Visible','off'           , ...
        'YDir'   ,'reverse'       , ...
        'XLim'   ,get(Img,'XData'), ...
        'YLim'   ,get(Img,'YData')  ...
        );
end

ws = get(handles.window,'Position');
set(handles.window,'Position',[(ss(3)-ws(3))/2, (ss(4)-ws(4))/2, ws(3), ws(4)]);

handles.N = N;
handles.ok = 0;

guidata(hObject, handles);
uiwait(handles.window);

% ---------------------------------------------------------------------
function varargout = RDAT_InputOption_OutputFcn(hObject, eventdata, handles) 

if handles.ok
    if handles.opt
        varargout{1} = find(cell2mat(get(handles.hcheck,'Value')));
    else
        if handles.N > 1
            varargout{1} = cell2mat(get(handles.hcheck(1:handles.N),'Value'));
        else
            varargout{1} = get(handles.hcheck(1),'Value');
        end
    end
else
    varargout{1} = [];
end
delete(handles.window);

% ---------------------------------------------------------------------
function check01_Callback(hObject, eventdata, handles)
% ---------------------------------------------------------------------
function check02_Callback(hObject, eventdata, handles)
% ---------------------------------------------------------------------
function check03_Callback(hObject, eventdata, handles)
% ---------------------------------------------------------------------
function check04_Callback(hObject, eventdata, handles)
% ---------------------------------------------------------------------
function check05_Callback(hObject, eventdata, handles)
% ---------------------------------------------------------------------
function check06_Callback(hObject, eventdata, handles)
% ---------------------------------------------------------------------
function check07_Callback(hObject, eventdata, handles)
% ---------------------------------------------------------------------
function check08_Callback(hObject, eventdata, handles)
% ---------------------------------------------------------------------
function check09_Callback(hObject, eventdata, handles)
% ---------------------------------------------------------------------
function check10_Callback(hObject, eventdata, handles)
% ---------------------------------------------------------------------
function check11_Callback(hObject, eventdata, handles)
% ---------------------------------------------------------------------
function check12_Callback(hObject, eventdata, handles)

% ---------------------------------------------------------------------
function ok_btn_Callback(hObject, eventdata, handles)

handles.ok = 1;
guidata(hObject, handles);
uiresume;

% ---------------------------------------------------------------------
function cancel_btn_Callback(hObject, eventdata, handles)

uiresume;

% ---------------------------------------------------------------------
function window_CloseRequestFcn(hObject, eventdata, handles)

cancel_btn_Callback(hObject, eventdata, handles);

% ---------------------------------------------------------------------
function window_WindowButtonDownFcn(hObject, eventdata, handles)

if handles.opt
    
    cp = get(handles.window,'CurrentPoint');
    
    for n = 1:length(handles.hcheck)
        
        pos = get(handles.hcheck(n),'Position');
        
        if      cp(1) > pos(1) && cp(1) < pos(1)+pos(3) && ...
                cp(2) > pos(2) && cp(2) < pos(2)+pos(3)
            
            switch get(handles.window,'SelectionType')
                case {'normal','alt'}
                    set(handles.hcheck,'Value',0); set(handles.hcheck(n),'Value',1);
                case 'open'
                    ok_btn_Callback(hObject, eventdata, handles);
            end
            
            return
        end
    end
end

% ---------------------------------------------------------------------
function window_KeyPressFcn(hObject, eventdata, handles)

cc = get(handles.window,'CurrentCharacter');

if isempty(cc)
    return
end

switch abs(cc)
    
    case 30 % Up
        if strcmpi(get(handles.check01,'Style'),'radiobutton')
            n = find(cell2mat(get(handles.hcheck,'Value')));
            if n > 1
                set(handles.hcheck,'Value',0); set(handles.hcheck(n-1),'Value',1);
            end
        end
        
    case 31 % Down
        if strcmpi(get(handles.check01,'Style'),'radiobutton')
            n = find(cell2mat(get(handles.hcheck,'Value')));
            if n < handles.N
                set(handles.hcheck,'Value',0); set(handles.hcheck(n+1),'Value',1);
            end
        end
        
    case 13 % Enter
        ok_btn_Callback(hObject, eventdata, handles);
        
    case 27 % Esc
        cancel_btn_Callback(hObject, eventdata, handles);
        
end

