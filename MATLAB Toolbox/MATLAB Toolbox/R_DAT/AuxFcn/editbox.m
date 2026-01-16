function str2 = editbox(str,tit,dw)
% Mostra um texto em uma caixa de dialogo para ediçao
% Sintaxe: editbox(str,tit,dw)
%          str: Texto com varias linhas (char ou cell)
%          tit: Nome da caixa de dialogo
%          dw:  Largura da caixa de dialogo (default 180 pixels)

str2 = [];
switch nargin
    case 1
        tit = '';
        dw = 380;
    case 2
        dw = 380;
end

if ischar(str)
    str = cellstr(str);
end
nl = max(10,min(32,length(str)));  % Number of lines

dh = 13*nl+8;  % Displaybox height
d = 10;  % Borders
bw = 60; % Button width
bh = 20; % Button height
fw = dw+2*d;    % Figure width
fh = bh+dh+3*d; % Figure height
ss = get(0,'ScreenSize');

% Callbacks
ok_CB = 'set(gcbf,''UserData'',''OK''); uiresume;';
cn_CB = 'set(gcbf,''UserData'',''CN''); uiresume;';
key_CB = ['cc=get(gcf,''CurrentCharacter''); if cc==13, ' ok_CB ' elseif cc==27, ' cn_CB ' end'];

% Object creation
figH = dialog('Visible','on','Name',tit,'Position',[(ss(3)-fw)/2 (ss(4)-fh)/2 fw fh],'WindowStyle','modal','KeyPressFcn',key_CB);
dispH = uicontrol(figH,'Style','edit','String',str,'HorizontalAlignment','left','Position',[d d+bh+d dw dh],...
    'BackGroundColor',[1 1 1],'Max',3,'Enable','on');
cnH = uicontrol(figH,'Style','pushbutton','Position',[fw/2-bw-d/2 d bw bh],'String','Cancelar','Callback',cn_CB);
okH = uicontrol(figH,'Style','pushbutton','Position',[fw/2+d/2 d bw bh],'String','OK','Callback',ok_CB);

% Button response
uiwait(figH);
if ishandle(figH)
    if strcmp(get(figH,'UserData'),'OK')
        str2 = char(get(dispH,'String'));
        delete(figH);
    elseif strcmp(get(figH,'UserData'),'CN')
        str2 = [];
        delete(figH);
    end       
end