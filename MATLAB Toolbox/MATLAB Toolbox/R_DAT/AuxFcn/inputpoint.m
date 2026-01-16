function [out1, out2] = inputpoint(name, text1, text2, def1, def2)
% Mostra uma janela para obtençao de numero e nome de ponto de ensaio
% Sintaxe: [out1, out2] = inputpoint(name, text1, text2, def1, def2)
%          name:  Nome da janela
%          text1: Nome do parametro 1
%          text2: Nome do parametro 2
%          def1:  Valor default do parametro 1
%          def1:  Valor default do parametro 2
%          out1:  String com o 1o. conteudo inserido (cancel retorna [])
%          out2:  String com o 2o. conteudo inserido (cancel retorna [])
%
% Modificaçao da mascara da funçao inputvalues

if nargin == 3
    def1 = '';
    def2 = '';
end

out1 = [];
out2 = [];

d = 10;  % Borders
th = 15; % Text height
bw = 60; % Button width
bh = 26; % Button height
ew1 = 60;  % Entrybox 1 width
ew2 = 300; % Entrybox 2 width
eh = 20;   % Entrybox height
fw = ew1+ew2+3*d;
fh = bh+eh+th+3*d;
ss = get(0,'ScreenSize');

ok_CB = 'set(gcbf,''UserData'',''OK''); uiresume;';
cn_CB = 'set(gcbf,''UserData'',''CN''); uiresume;';
key_CB = ['cc=get(gcf,''CurrentCharacter''); if cc==13, ' ok_CB ' elseif cc==27, ' cn_CB ' end'];

figH = dialog('Visible','on','Name',name,'Position',[(ss(3)-fw)/2 (ss(4)-fh)/2 fw fh],'KeyPressFcn',key_CB);
text1H = uicontrol(figH,'Style','text','String',text1,'Position',[d 2*d+bh+eh ew1 th],'HorizontalAlignment','left');
edit1H = uicontrol(figH,'Style','edit','Position',[d 2*d+bh ew1 eh],'BackGroundColor',[1 1 1],'String',def1,'HorizontalAlignment','left');
text2H = uicontrol(figH,'Style','text','String',text2,'Position',[2*d+ew1 2*d+bh+eh ew2 th],'HorizontalAlignment','left');
edit2H = uicontrol(figH,'Style','edit','Position',[2*d+ew1 2*d+bh ew2 eh],'BackGroundColor',[1 1 1],'String',def2,'HorizontalAlignment','left');
okH = uicontrol(figH,'Style','pushbutton','Position',[fw/2-bw-d d bw bh],'String','OK','Callback',ok_CB);
cancelH = uicontrol(figH,'Style','pushbutton','Position',[fw/2+d d bw bh],'String','Cancel','Callback',cn_CB);

uiwait(figH);
if ishandle(figH)
    if strcmp(get(figH,'UserData'),'OK')
        out1 = get(edit1H,'String');
        out1 = fliplr(deblank(fliplr(deblank(out1))));
        out2 = get(edit2H,'String');
        out2 = fliplr(deblank(fliplr(deblank(out2))));
    else
        out1 = [];
        out2 = [];
    end
    delete(figH)
end