function displaybox(str,tit,dw)
% Mostra um texto em uma caixa de dialogo e pode copia-lo para o cliboard
% Sintaxe: displaybox(str,tit,dw)
%          str: Texto com varias linhas (char ou cell)
%          tit: Nome da caixa de dialogo
%          dw:  Largura da caixa de dialogo (default 180 pixels)

switch nargin
    case 1
        tit = '';
        dw = 180;
    case 2
        dw = 180;
end

dw = min(800,max(dw,120));

if ischar(str)
    str = cellstr(str);
end
nl = length(str);  % Number of lines

if nl > 50
    str(51:end) = [];
    str{51} = '   :';
    nl = length(str);  % Number of lines
end

dh = 13*nl+8+13;  % Displaybox height
d = 10;  % Borders
bw = 60; % Button width
bh = 20; % Button height
fw = dw+2*d;    % Figure width
fh = bh+dh+3*d; % Figure height
ss = get(0,'ScreenSize');

% Callbacks
ok_CB  = 'set(gcbf,''UserData'',''OK''); uiresume;';
cp_CB  = 'set(gcbf,''UserData'',''CP''); uiresume;';
key_CB = ['cc=get(gcf,''CurrentCharacter''); if cc==13 || cc==27, ' ok_CB ' end'];

% Object creation
figH = dialog('Visible','on','Name',tit,'Position',[(ss(3)-fw)/2 (ss(4)-fh)/2 fw fh],'WindowStyle','modal','KeyPressFcn',key_CB);
dispH = uicontrol(figH,'Style','edit','String',str,'HorizontalAlignment','left','Position',[d d+bh+d dw dh],...
    'BackGroundColor',[1 1 1],'Max',3,'Enable','inactive');
copyH = uicontrol(figH,'Style','pushbutton','Position',[fw/2-bw-d/2 d bw bh],'String','Copiar','Callback',cp_CB);
okH = uicontrol(figH,'Style','pushbutton','Position',[fw/2+d/2 d bw bh],'String','OK','Callback',ok_CB);

% Button response
uiwait(figH);
if ishandle(figH)
    if strcmp(get(figH,'UserData'),'OK')
        delete(figH);
    elseif strcmp(get(figH,'UserData'),'CP')
        str2 = str{1};
        for n = 2:length(str)
            str2 = [str2 char(10) str{n}];
        end
        clipboard('copy',str2);
        set(copyH,'Enable','off');
        uiwait(figH);
        if ishandle(figH)
            if strcmp(get(figH,'UserData'),'OK')
                delete(figH);
            end
        end
    end       
end