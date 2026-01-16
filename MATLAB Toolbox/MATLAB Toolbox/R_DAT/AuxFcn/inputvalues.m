function varargout = inputvalues(name, texts, defs, k)
% Mostra uma janela para obtençao de multiplos valores ou opçoes
% Sintaxe: [out1, out2, ...] = inputvalue(name, texts, defs, k)
%          name:  Nome da janela
%          texts: Cell array com nomes dos parametros
%          defs:  Cell array com valores default dos parametros
%                 Se um elemento de defs for cell array, sera apresentado como lista
%                 Se o ultimo elemento do cell array de um elemento de defs for numerico, sera o valor default da lista
%          k:     Fator de aumento da largura das caixas de entrada (1 a 3x)
%          outn:  String inserido no campo "n" ou indice da lista "n" (cancel retorna [])
%                 Se houver mais de um campo e apenas uma saida, essa sera um cell array com o conteudo de todos os campos
%
% Exemplo: [nome, unid] = inputvalues('Opções', {'Nome:','Unidade:'}, {'Velocidade',{'m/s','km/h','kt',3}}, 1)
%

switch nargin
    case 0
        name  = 'Entrada';
        texts = {'Valor 1:','Valor 2:'};
        defs  = {'',''};
        k = 1;
    case 1
        texts = {'Valor 1:','Valor 2:'};
        defs  = {'',''};
        k = 1;
    case 2
        defs(1:length(texts)) = {''};
        k = 1;
    case 3
        k = 1;
end

if isempty(defs)
    defs(1:length(texts)) = {''};
end

if iscell(defs) && length(defs) == 1 && ischar(defs{1})
    defs = {defs};
end
if ischar(texts)
    texts = cellstr(texts);
end
if ischar(defs)
    defs = cellstr(defs);
end
if length(texts) == 1 && length(defs) > 1
    defs = {defs};
end

k = max(1,min(3,k));

N = length(texts);

dh = 10;        % Vertical borders
dw = 10;        % Horizontal borders
th = 15;        % Text height
ew = k*130;     % Entrybox width
eh = 20;        % Entrybox height
bw = 60;        % Button width
bh = 26;        % Button height
fw = 2*dw+ew;   % Figure width

fh = bh+N*eh+N*th+(N+2)*dh; % Figure height

ss = get(0,'ScreenSize');

ok_CB = 'set(gcbf,''UserData'',''OK''); uiresume;';
cn_CB = 'set(gcbf,''UserData'',''CN''); uiresume;';
key_CB = ['cc=get(gcf,''CurrentCharacter''); if cc==13, ' ok_CB ' elseif cc==27, ' cn_CB ' end'];

figH    = dialog('Visible','on','Name',name,'Position',[(ss(3)-fw)/2 (ss(4)-fh)/2 fw fh],'KeyPressFcn',key_CB);

for n = 1:N
    
    varargout{n} = [];
    
    if iscell(defs{n})
        style = 'popupmenu';
        if isnumeric(defs{n}{end}) && length(defs{n}) > 1
            val = defs{n}{end};
            defs{n}(end) = [];
        else
            val = 1;
        end
    else
        style = 'edit';
        val = 1;
    end
    
    textH(n)  = uicontrol(figH,'Style','text','String',texts{n},'Position',[dw fh-n*(eh+th+dh)+eh ew th],'HorizontalAlignment','left');
    editH(n)  = uicontrol(figH,'Style',style, 'String',defs{n}, 'Position',[dw fh-n*(eh+th+dh)    ew eh],'BackGroundColor',[1 1 1],'Value',val);
end
okH     = uicontrol(figH,'Style','pushbutton','Position',[fw/2-bw-dw/2 dh bw bh],'String','OK','Callback',ok_CB);
cancelH = uicontrol(figH,'Style','pushbutton','Position',[fw/2+dw/2 dh bw bh],'String','Cancel','Callback',cn_CB);

uiwait(figH);
if ishandle(figH)
    if strcmp(get(figH,'UserData'),'OK')
        for n = 1:N
            if strcmp(get(editH(n),'Style'),'edit')
                str = get(editH(n),'String');
                varargout{n} = fliplr(deblank(fliplr(deblank(str))));
            else
                varargout{n} = get(editH(n),'Value');
            end
        end
        if nargout == 1
            if N == 1
                varargout{1} = varargout{1};
            else
                varargout{1} = varargout;
            end
        end
    else
        for n = 1:N
            varargout{n} = [];
        end
    end
    delete(figH)
end
