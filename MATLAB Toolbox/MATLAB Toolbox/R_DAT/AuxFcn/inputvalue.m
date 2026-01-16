function t = inputvalue(name,txt,def,n,k)
% Mostra uma janela para obtençao de um valor ou uma opçao
% Sintaxe: t = inputvalue(name,txt,def,n,k)
%          name: Nome da janela
%          tet:  Nome do parametro
%          def:  Valor default
%          n:    Posiçao default da lista (caso aplicavel)
%          k:    Fator de aumento da caixa de entrada
%          t:    String com o conteudo inserido (cancel retorna [])
%
% Se def for um cell array ou matriz de strings, sera apresentada uma lista para escolha
% e a saida sera o indice da lista
%

switch nargin
    case 0
        name = 'Entrada';
        txt = 'Valor:';
        def = '';
        n = 1;
        k = 1;
    case 1
        txt = 'Valor:';
        def = '';
        n = 1;
        k = 1;
    case 2
        def = '';
        n = 1;
        k = 1;
    case 3
        n = 1;
        k = 1;
    case 4
        k = 1;
end

if ischar(def) && size(def,1) > 1
    def = cellstr(def);
end

if iscell(def)
    edit1style = 'popupmenu';
else
    edit1style = 'edit';
end

t = [];

dh = 10;        % Vertical borders
dw = 10;        % Horizontal borders
th = 15;        % Text height
ew = k*130;     % Entrybox width
eh = 20;        % Entrybox height
bw = 60;        % Button width
bh = 26;        % Button height
fw = 2*dw+ew;   % Figure width
fh = bh+eh+th+3*dh; % Figure height

ss = get(0,'ScreenSize');

ok_CB = 'set(gcbf,''UserData'',''OK''); uiresume;';
cn_CB = 'set(gcbf,''UserData'',''CN''); uiresume;';
key_CB = ['cc=get(gcf,''CurrentCharacter''); if cc==13, ' ok_CB ' elseif cc==27, ' cn_CB ' end'];

figH    = dialog('Visible','on','Name',name,'Position',[(ss(3)-fw)/2 (ss(4)-fh)/2 fw fh],'KeyPressFcn',key_CB);
textH   = uicontrol(figH,'Style','text','String',txt,'Position',[dw 2*dh+bh+eh ew th],'HorizontalAlignment','left');
editH   = uicontrol(figH,'Style',edit1style,'String',def,'Value',n,'Position',[dw dh+bh+dh ew eh],'BackGroundColor',[1 1 1]);
okH     = uicontrol(figH,'Style','pushbutton','Position',[fw/2-bw-dw/2 dh bw bh],'String','OK','Callback',ok_CB);
cancelH = uicontrol(figH,'Style','pushbutton','Position',[fw/2+dw/2 dh bw bh],'String','Cancela','Callback',cn_CB);

uiwait(figH);
if ishandle(figH)
    if strcmp(get(figH,'UserData'),'OK')
        if iscell(def)
            t = get(editH,'Value');
        else
            t = get(editH,'String');
            t = fliplr(deblank(fliplr(deblank(t))));
        end
    else
        t = [];
    end
    delete(figH)
end
