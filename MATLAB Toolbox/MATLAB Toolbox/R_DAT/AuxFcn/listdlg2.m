function [selection, ok, selection2] = listdlg2(varargin)
%LISTDLG  List selection dialog box.
%   [SELECTION,OK] = LISTDLG2('ListString',S) creates a modal dialog box 
%   which allows you to select a string or multiple strings from a list.
%   SELECTION is a vector of indices of the selected strings (length 1
%   in the single selection mode).  This will be [] when OK is 0.
%   OK is 1 if you push the OK button, or 0 if you push the Cancel 
%   button or close the figure.
%   Double-clicking on an item or pressing <CR> when multiple items are
%   selected has the same effect as clicking the OK button.
%
%   Inputs are in parameter,value pairs:
%
%   Parameter         Description
%   'ListString'      cell array of strings for the 1st list box.
%   'ListString2'     cell array of strings for the 2nd list box.
%   'SelectionMode'   string; can be 'single' or 'multiple'; defaults to
%                     'multiple'.
%   'ListSize'        [width height] of listbox in pixels; defaults
%                     to [160 305].
%   'InitialValue'    vector of indices of which items of the 1st list box
%                     are initially selected; defaults to the first item.
%   'InitialValue2'   vector of indices of which items of the 2nd list box
%                     are initially selected; defaults to the first item.
%   'Name'            String for the figure's title. Defaults to ''.
%   'HeaderString'    string matrix or cell array of strings which appears 
%                     as text above the list boxes.  Defaults to {}.
%   'PromptString'    string matrix or cell array of strings which appears 
%                     as text above the 1st list box.  Defaults to {}.
%   'PromptString2'   string matrix or cell array of strings which appears 
%                     as text above the 2nd list box.  Defaults to {}.
%   'OKString'        string for the OK button; defaults to 'OK'.
%   'CancelString'    string for the Cancel button; defaults to 'Cancel'.
%   'SelectAllString  string for the Select All button; defaults to 'Select All'.
%   'SelectNoneString string for the Select None button; defaults to 'Select None'.
%   'uh'              uicontrol button height, in pixels; default = 18.
%   'uw'              uicontrol button width, in pixels; default = 70.
%   'fus'             frame/uicontrol spacing, in pixels; default = 8.
%   'ffs'             frame/figure spacing, in pixels; default = 8.
%
%   'Select all' and 'Select none' buttons are provided in the multiple selection case.
%
%   Example:
%     d = dir;
%     str = {d.name};
%     [s,v] = listdlg('PromptString','Select a file:',...
%                     'SelectionMode','single',...
%                     'ListString',str)

%   T. Krauss, 12/7/95, P.N. Secakusuma, 6/10/97
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.20 $  $Date: 2002/04/09 01:36:06 $
%
%   Modified by L. Lopes - GEEV, 2009/04/08, to allow two lists

% simple test:
%
% d = dir; [s,v] = listdlg2('PromptString','Select a file:','ListString',{d.name});
% 

error(nargchk(1,inf,nargin))

figname = 'Option';
smode = 2;   % (multiple)
headerstring = {};
promptstring = {};
promptstring2 = {};
liststring = [];
liststring2 = [];
listsize = [160 305];
initialvalue = [];
initialvalue2 = [];
okstring = 'OK';
cancelstring = 'Cancel';
selectallstring = 'Select All';
selectnonestring = 'Select None';
fus = 8;
ffs = 8;
uh = 18;
uw = 70;

if mod(length(varargin),2) ~= 0
    error('Arguments to LISTDLG must come in param/value pairs.')
end
for i=1:2:length(varargin)
    switch lower(varargin{i})
        case 'name'
            figname = varargin{i+1};
        case 'headerstring'
            headerstring = varargin{i+1};
        case 'promptstring'
            promptstring = varargin{i+1};
        case 'promptstring2'
            promptstring2 = varargin{i+1};
        case 'selectionmode'
            switch lower(varargin{i+1})
                case 'single'
                    smode = 1;
                case 'multiple'
                    smode = 2;
            end
        case 'listsize'
            listsize = varargin{i+1};
        case 'liststring'
            liststring = varargin{i+1};
        case 'liststring2'
            liststring2 = varargin{i+1};
        case 'initialvalue'
            initialvalue = varargin{i+1};
        case 'initialvalue2'
            initialvalue2 = varargin{i+1};
        case 'uh'
            uh = varargin{i+1};
        case 'uw'
            uw = varargin{i+1};
        case 'fus'
            fus = varargin{i+1};
        case 'ffs'
            ffs = varargin{i+1};
        case 'okstring'
            okstring = varargin{i+1};
        case 'cancelstring'
            cancelstring = varargin{i+1};
        case 'selectallstring'
            selectallstring = varargin{i+1};
        case 'selectnonestring'
            selectnonestring = varargin{i+1};
        otherwise
            error(['Unknown parameter name passed to LISTDLG: ' varargin{i}]);
    end
end

headerstring  = cellstr(headerstring);
promptstring  = cellstr(promptstring);
liststring    = cellstr(liststring);
if ~isempty(liststring2)
    promptstring2 = cellstr(promptstring2);
    liststring2   = cellstr(liststring2);
end

if length(promptstring2) > length(promptstring)
    for n = length(promptstring)+1:length(promptstring2)
        promptstring{n} = '';
    end
end

if smode == 1 && isempty(initialvalue)
    initialvalue = 1;
end
if smode == 1 && isempty(initialvalue2)
    initialvalue2 = 1;
end

if isempty(liststring)
    error('ListString parameter is required.')
end

Hh1 = 13*length(headerstring);
Hh2 = fus*(~isempty(headerstring));

Ph1 = 13*length(promptstring);
Ph2 = fus*(~isempty(promptstring));

Sh1 = uh*(smode==2);
Sh2 = fus*(smode==2);

ss = get(0,'ScreenSize');

if isempty(liststring2)
    w = 2*(fus+ffs)+listsize(1);
else
    w = 4*(fus+ffs)+2*listsize(1);
end
h = 2*ffs+4*fus+Hh1+Hh2+Ph1+Ph2+Sh1+Sh2+listsize(2)+uh;
fp = [(ss(3)-w)/2 (ss(4)-h)/2 w h];

fig_props = { ...
        'name'                   figname ...
        'resize'                 'off'   ...
        'numbertitle'            'off'   ...
        'menubar'                'none'  ...
        'windowstyle'            'modal' ...
        'visible'                'off'   ...
        'createfcn'              ''      ...
        'position'               fp      ...
        'closerequestfcn'        'delete(gcbf)' ...
        'color'                  get(0,'defaultuicontrolbackgroundcolor') ...
    };

fig = figure(fig_props{:});

uicontrol('style','frame',...
    'position',[ffs ffs+2*fus+uh 2*fus+listsize(1) listsize(2)+2*fus+Ph1+Ph2+Sh1+Sh2]);

if ~isempty(headerstring)
    header_text = uicontrol('style','text','string',headerstring,...
        'horizontalalignment','left','units','pixels','fontsize',8,...
        'position',[ffs fp(4)-(ffs+Hh1) fp(3)-2*ffs Hh1]);
end

if ~isempty(promptstring)
    prompt_text = uicontrol('style','text','string',promptstring,...
        'horizontalalignment','left','units','pixels','fontsize',8,...
        'position',[ffs+fus fp(4)-(ffs+Hh1+Hh2+fus+Ph1) listsize(1) Ph1]);
end

if ~isempty(liststring2)
    uicontrol('style','frame',...
        'position',[3*ffs+2*fus+listsize(1) ffs+2*fus+uh 2*fus+listsize(1) listsize(2)+2*fus+Ph1+Ph2+Sh1+Sh2]);
    
    if ~isempty(promptstring2)
        prompt_text2 = uicontrol('style','text','string',promptstring2,...
            'horizontalalignment','left','units','pixels','fontsize',8,...
            'position',[3*ffs+2*fus+fus+listsize(1) fp(4)-(ffs+Hh1+Hh2+fus+Ph1) listsize(1) Ph1]);
    end
end

listbox = uicontrol('style','listbox',...
    'position',[ffs+fus ffs+uh+3*fus+Sh1+Sh2 listsize],...
    'string',liststring,...
    'backgroundcolor','w',...
    'max',smode,...
    'tag','listbox',...
    'value',initialvalue, ...
    'callback', '');
setappdata(fig,'listbox',listbox);
setappdata(fig,'listbox2',[]);
setappdata(fig,'ok',0);

if ~isempty(liststring2)
    listbox2 = uicontrol('style','listbox',...
        'position',[3*ffs+3*fus+listsize(1) ffs+uh+3*fus+Sh1+Sh2 listsize],...
        'string',liststring2,...
        'backgroundcolor','w',...
        'max',smode,...
        'tag','listbox2',...
        'value',initialvalue2, ...
        'callback', '');
    setappdata(fig,'listbox2',listbox2);
end

ok_btn = uicontrol('style','pushbutton',...
    'string',okstring,...
    'position',[w/2-fus-uw ffs+fus/2 uw uh],...
    'callback',{@doOK,fig});

cancel_btn = uicontrol('style','pushbutton',...
    'string',cancelstring,...
    'position',[w/2+fus ffs+fus/2 uw uh],...
    'callback',{@doCancel,fig});

if smode == 2
    selectall_btn = uicontrol('style','pushbutton',...
        'string',selectallstring,...
        'position',[ffs+fus 3*fus+ffs+uh listsize(1)/2 uh],...
        'tag','selectall_btn',...
        'callback',{@doSelectAll,fig});
    
    selectnone_btn = uicontrol('style','pushbutton',...
        'string',selectnonestring,...
        'position',[ffs+fus+listsize(1)/2 3*fus+ffs+uh listsize(1)/2 uh],...
        'tag','selectnone_btn',...
        'callback',{@doSelectNone,fig});

    if ~isempty(liststring2)
        selectall2_btn = uicontrol('style','pushbutton',...
            'string',selectallstring,...
            'position',[3*ffs+3*fus+listsize(1) 3*fus+ffs+uh listsize(1)/2 uh],...
            'tag','selectall_btn2',...
            'callback',{@doSelectAll2,fig});
        
        selectnone2_btn = uicontrol('style','pushbutton',...
            'string',selectnonestring,...
            'position',[3*ffs+3*fus+listsize(1)+listsize(1)/2 3*fus+ffs+uh listsize(1)/2 uh],...
            'tag','selectnone2_btn',...
            'callback',{@doSelectNone2,fig});
    end
end

try
    set(fig,'Visible','on');
    uiwait(fig);
catch
    if ishandle(fig)
        delete(fig);
        return
    end
end

if ishandle(fig) && getappdata(fig,'ok')
    selection  = get(listbox,'value');
    ok = 1;
    if ~isempty(liststring2)
        selection2 = get(listbox2,'value');
    else
        selection2 = [];
    end
else
    selection  = [];
    ok = 0;
    selection2 = [];
end

if ishandle(fig)
    delete(fig);
end

%---------------------------------------------------------------------
function doOK(ok_btn, evd, fig)
setappdata(fig,'ok',1);
uiresume(fig);

%---------------------------------------------------------------------
function doCancel(cancel_btn, evd, fig)
uiresume(fig);

%---------------------------------------------------------------------
function doSelectAll(selectall_btn, evd, fig)
listbox = getappdata(fig,'listbox');
set(listbox,'value',1:length(get(listbox,'string')));

%---------------------------------------------------------------------
function doSelectNone(selectnone_btn, evd, fig)
listbox = getappdata(fig,'listbox');
set(listbox,'value',[]);

%---------------------------------------------------------------------
function doSelectAll2(selectall2_btn, evd, fig)
listbox2 = getappdata(fig,'listbox2');
set(listbox2,'value',1:length(get(listbox2,'string')));

%---------------------------------------------------------------------
function doSelectNone2(selectnone2_btn, evd, fig)
listbox2 = getappdata(fig,'listbox2');
set(listbox2,'value',[]);

