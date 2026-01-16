function varargout = RDAT_Comutation(varargin)
% RDAT_COMUTATION M-file for RDAT_Comutation.fig
% Last Modified by GUIDE v2.5 28-Apr-2012 20:01:32

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RDAT_Comutation_OpeningFcn, ...
                   'gui_OutputFcn',  @RDAT_Comutation_OutputFcn, ...
                   'gui_LayoutFcn',  @RDAT_Comutation_LayoutFcn, ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1}) && size(varargin{1},1)==1
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
function h = RDAT_Comutation_LayoutFcn(varargin)
% Função de layout inicial

h = openfig('RDAT_Comutation.fig','reuse','invisible');

% -------------------------------------------------------------------------
function RDAT_Comutation_OpeningFcn(hObject, eventdata, handles, varargin)
% Funçao de inicializaçao

global DADOS

bgc = getbuttoncolor(handles.window);
set(handles.help_btn ,'CData', geticon('DatButtons.mat','help', bgc));

scrsz = get(0,'ScreenSize');
winsz = get(handles.window,'Position');
set(handles.window,'Position',[.5*(scrsz(3)-winsz(3)) .5*(scrsz(4)-winsz(4)) winsz(3) winsz(4)]);
handles.ok = 0;

if nargin == 5
    PARAM   = varargin{1};
    reftime = varargin{2};
else
    beep; uiwait(errordlg('Dados não fornecidos.','Erro','modal'));
    handles.ok = 0;
    guidata(hObject, handles);
    uiresume;
    return
end

handles.PARAM = PARAM;
handles.blue = [0 .5 1];
handles.red  = [1 .4 .4];

[handles.N handles.M] = size(DADOS);

if ~isempty(deblank(reftime))
    tcol = findpar(PARAM,reftime,0,1);
    if isempty(tcol)
        tcol = 1;
        beep; uiwait(errordlg(['Tempo de referência ''' reftime ''' não encontrado.'],'Erro','modal'));
    end
else
    tcol = 1;
end

set(handles.reftime_sel,'String',PARAM,'Value',tcol);

ok = initialize(hObject, eventdata, handles);

if ~ok
    handles.ok = 0;
    guidata(hObject, handles);
    uiresume;
    return
end

updategrid(hObject, eventdata, handles);

handles.paramtip = text(0,0,'','BackgroundColor',[1 1 .8],'EdgeColor',[0 0 0],'FontSize',9,'Margin',.1,'Clipping','on',...
            'HorizontalAlignment','left','VerticalAlignment','bottom','Visible','off');

guidata(hObject, handles);
uiwait(handles.window);

% -------------------------------------------------------------------------
function varargout = RDAT_Comutation_OutputFcn(hObject, eventdata, handles)
% Funçao de saida

varargout{1} = handles.ok;    
delete(handles.window);

% -------------------------------------------------------------------
function help_btn_Callback(hObject, eventdata, handles)
% Botao Ajuda

helpme('Dados\subcomutacao');

%----------------------------------------------------------------
function all_btn_Callback(hObject, eventdata, handles)
% Selecionar todos os parametros subcomutados

set(handles.comuted_list,'Value',1:length(get(handles.comuted_list,'String')));
updategrid(hObject, eventdata, handles);

%----------------------------------------------------------------
function filter_btn_Callback(hObject, eventdata, handles)
% Filtrar por ordem de comutaçao

comord  = getappdata(handles.window,'comord');
comlist = getappdata(handles.window,'comlist');

comord2 = comord;
comord2(comord2==1) = [];

ordlist = setdiff(unique(comord),1)';

n = inputvalue('Filtrar','Taxa de comutação',cellstr(num2str(ordlist)));

if ~isempty(n)
    sel = find(comord2==ordlist(n));
    
    set(handles.comuted_list,'Value',sel,'ListboxTop',get(handles.comuted_list,'ListboxTop'));
    updategrid(hObject, eventdata, handles);
end

% -------------------------------------------------------------------
function ok_btn_Callback(hObject, eventdata, handles)
% Botao OK

global DADOS

comlist = getappdata(handles.window,'comlist');

if isempty(comlist)
    handles.ok = 0;
    guidata(hObject, handles);
    uiresume;
else
    
    sel = get(handles.comuted_list,'Value');
    if isempty(sel)
        beep; uiwait(errordlg('Nenhum parâmetro selecionado.','Erro','modal')); drawnow;
        return
    end

    switch get(handles.option_sel,'Value')
        
        case 1 % Interpolar
        
            npar = comlist(sel);
            method = get(handles.method_sel,'Value');
            methodlist = {'linear','vizinho','repetir'};
            
            button = questdlg({'Deseja interpolar todos os pontos inválidos dos',...
                    ['parâmetros selecionados pelo método ''' methodlist{method} ''' ?']},'Confirmação','Sim','Não','Não'); drawnow;
            
            if strcmp(button,'Sim')
                
                tcol = get(handles.reftime_sel,'Value');
                T = DADOS(:,tcol);
                if ~IsTimeOk(T) && method <= 2
                    beep; uiwait(errordlg({['O tempo de referência ''' denumber(handles.PARAM{tcol}) ''' não é adequado.'],...
                            'O tempo deve ser monotônico crescente e sem pontos inválidos.'},'Erro','modal')); drawnow;
                    return
                end
                
                % Parâmetros cíclicos e inteiros
                if method == 1
                    [sel1, ok, sel2] = listdlg2('Name','Incorporação','HeaderString',{'Indique os parâmetros com escala cíclica que contenham descontinuidades, como proa,','inclinação lateral, atitude, direção, radial etc.:'},...
                        'PromptString','Intervalo de 0 a 360°','PromptString2','Intervalo de -180 a 180°','SelectionMode','multiple','ListString',handles.PARAM(npar),'ListString2',handles.PARAM(npar),...
                        'OKString','OK','CancelString','Cancela','SelectAllString','Selecionar tudo','SelectNoneString','Limpar','ListSize',[200 305]); drawnow;
                    pause(.2);
                    sel3 = listdlg2('Name','Incorporação','HeaderString',{'Indique os parâmetros lógicos ou inteiros,','como estado de botões, gatilho, modo de','operação, TOP, hora, minuto etc.:'},...
                        'SelectionMode','multiple','ListString',handles.PARAM(npar),'OKString','OK','CancelString','Cancela','SelectAllString','Selecionar tudo','SelectNoneString','Limpar','ListSize',[200 305]); drawnow;
                    
                    for n = 1:length(sel1) % [0 360°] -> continuo
                        DADOS(:,npar(sel1(n))) = unwrap2(DADOS(:,npar(sel1(n))));
                    end
                    for n = 1:length(sel2) % [±180°] -> continuo
                        DADOS(:,npar(sel2(n))) = unwrap2(DADOS(:,npar(sel2(n))));
                    end
                    if ~isempty(sel3); % Inteiros
                        DADOSint = DADOS(:,npar(sel3));
                    end
                end
                % ------------------
                
                % Interpolaçao
                h = waitdlg('Interpolando dados ...','Aguarde','modal');
                
                for m = 1:length(npar)
                    
                    Y = DADOS(:,npar(m));
                    val = ~isnan(Y);
                    
                    switch method
                        case 1 % Linear
                            DADOS(:,npar(m)) = interp1(T(val),Y(val),T,'linear');
                        case 2 % Vizinho
                            DADOS(:,npar(m)) = interp1(T(val),Y(val),T,'nearest');
                        case 3 % Repetir
                            DADOS(:,npar(m)) = denan(Y,1);
                    end
                end
                
                
                % Parâmetros cíclicos e inteiros
                if method == 1
                    for n = 1:length(sel1) % continuo -> [0 360°]
                        DADOS(:,npar(sel1(n))) = mod(DADOS(:,npar(sel1(n))),360);
                    end
                    for n = 1:length(sel2) % continuo -> [±180°]
                        DADOS(:,npar(sel2(n))) = mod(DADOS(:,npar(sel2(n))),360);
                        neg = find(DADOS(:,npar(sel2(n))) > 180);
                        DADOS(neg,npar(sel2(n))) = DADOS(neg,npar(sel2(n))) - 360;
                    end
                    for n = 1:length(sel3) % Inteiros
                        Y = DADOSint(:,n);
                        val = ~isnan(Y);
                        DADOS(:,npar(sel3(n))) = interp1(T(val),Y(val),T,'nearest');
                    end
                end
                % ------------------
                
                try, delete(h); end
                
                handles.ok = 1;
                guidata(hObject, handles);
                uiresume;                        
            end
            
        case 2 % Excluir
            
            npar = comlist(sel);
            button = questdlg({'Deseja excluir todos os pontos inválidos do',...
                    ['parâmetro ''' denumber(handles.PARAM{npar}) ''' ?'],...
                    'Todos os parâmetros serão afetados.'},'Confirmação','Sim','Não','Não'); drawnow;
            
            if strcmp(button,'Sim')
                Y = DADOS(:,npar);
                DADOS(isnan(Y),:) = [];
                
                handles.ok = 2;
                guidata(hObject, handles);
                uiresume;                        
            end
            
    end
end

% -------------------------------------------------------------------
function cancel_btn_Callback(hObject, eventdata, handles)
% Botao Cancela

comlist = getappdata(handles.window,'comlist');
if isempty(comlist)
    button = 'Sim';
else
    button = questdlg('Deseja cancelar a operação?','Confirmação','Sim','Não','Não');
end
if strcmp(button,'Sim')
    uiresume;
end

% -------------------------------------------------------------------------
function window_KeyPressFcn(hObject, eventdata, handles)
% Acionamento de tecla do teclado

cc = get(handles.window,'CurrentCharacter');

if isempty(cc)
    return
end

switch abs(cc)
    
    case 13 % Enter
        ok_btn_Callback(hObject, eventdata, handles);
        
    case 27 % Esc
        cancel_btn_Callback(hObject, eventdata, handles);
        
end

% -------------------------------------------------------------------------
function window_CloseRequestFcn(hObject, eventdata, handles)
% Funçao de fechamento da janela

cancel_btn_Callback(hObject, eventdata, handles);

% -------------------------------------------------------------------------
function comuted_list_Callback(hObject, eventdata, handles)
% Selecionar parametros na lista de subcomutados

updategrid(hObject, eventdata, handles);

% -------------------------------------------------------------------------
function option_sel_Callback(hObject, eventdata, handles)
% Seleçao da opçao de correçao

interplist1 = [handles.method_txt handles.method_sel handles.reftime_txt handles.reftime_sel];
interplist2 = [handles.all_btn handles.filter_btn];

switch get(handles.option_sel,'Value')
    
    case 1 % Interpolar
        set(interplist1,'Visible','on');
        set(interplist2,'Enable','on');
        set(handles.comuted_list,'Max',2);
        
    case 2 % Excluir
        set(interplist1,'Visible','off');
        set(interplist2,'Enable','off');
        sel = min(get(handles.comuted_list,'Value'));
        if isempty(sel), sel = 1; end
        set(handles.comuted_list,'Max',1,'Value',sel);
        updategrid(hObject, eventdata, handles);
end

method_sel_Callback(hObject, eventdata, handles);

% -------------------------------------------------------------------------
function method_sel_Callback(hObject, eventdata, handles)
% Seleçao de metodo de interpolaçao

reflist = [handles.reftime_txt handles.reftime_sel];

if get(handles.option_sel,'Value') == 1
    
    switch get(handles.method_sel,'Value')
        case {1,2}
            set(reflist,'Visible','on');
        case 3
            set(reflist,'Visible','off');
    end
end

% -------------------------------------------------------------------------
function Hslider_Callback(hObject, eventdata, handles)
% Barra de rolagem horizontal

set(handles.Hslider,'Value',round(get(handles.Hslider,'Value')));
updategrid(hObject, eventdata, handles);

% -------------------------------------------------------------------------
function Vslider_Callback(hObject, eventdata, handles)
% Barra de rolagem vertical

set(handles.Vslider,'Value',round(get(handles.Vslider,'Value')));
updategrid(hObject, eventdata, handles);

% ---------------------------------------------------------------
function ok = initialize(hObject, eventdata, handles)
global DADOS
% Configuraçao inicial da tela

set(handles.window,'Pointer','watch');

N = handles.N;
M = handles.M;

% Análise de comutação
comord = ones(1,M);

if N > 2
    for m = 1:M
        tx = median(diff(find(~isnan(DADOS(:,m)))));
        if ~isempty(tx) && tx <= 64
            comord(m) = tx;
        end
    end
end

comlist = find(comord>1);

if ~isempty(comlist)
    
    % Preparaçao das listas

    PARAM1 = handles.PARAM(comord==1);
    PARAM2 = handles.PARAM(comord>1);
    
    w = size(char(PARAM2),2);
    
    for m = 1:length(comlist)
        PARAM2{m} = [PARAM2{m} blanks(w-length(PARAM2{m})) '  [1:' int2str(comord(comlist(m))) ']'];
    end
    
    set(handles.normal_list, 'String',PARAM1,'Value',[]);
    set(handles.comuted_list,'String',PARAM2,'Value',[]);
    
    set(handles.nnormal_txt,'String',int2str(length(PARAM1)));
    set(handles.ncomuted_txt,'String',int2str(length(PARAM2)));
    
    % Preparaçao da grade
    
    L = 30;
    U = ones(min(L,N),1);
    S = (1:min(L,N))';
    
    axes(handles.grid);
    for n = 1:min(L,M)
        x = n*U;
        y = S;
        plot(x,y,'sk','MarkerFaceColor','w','HitTest','off');
        valplots(n) = plot(x,NaN*y,'sk','MarkerFaceColor','w','HitTest','off');
    end
    setappdata(handles.window,'valplots',valplots);
    
    m1 = max(1,min(M-L+1,1));
    n1 = max(1, N-L+1);
    hmax = max(1+1e-6, M-L+1);
    vmax = max(1+1e-6, N-L+1);
    
    if M <= L
        steph = [1 1e6];
        hen = 'off';
    else
        steph = [1 2]/(M-L);
        hen = 'on';
    end
    
    if N <= L
        stepv = [1 1e6];
        ven = 'off';
    else
        stepv = [1 L-1]/(N-L);
        ven = 'on';
    end
    
    set(handles.Hslider,'Value',m1,'SliderStep',steph,'Min',1,'Max',hmax,'Enable',hen);
    set(handles.Vslider,'Value',n1,'SliderStep',stepv,'Min',1,'Max',vmax,'Enable',ven);
    
    ok = 1;
    set(handles.window,'Pointer','arrow');
    
else
    set(handles.normal_list,'String',handles.PARAM,'Value',[]);
    
    set([handles.all_btn handles.filter_btn handles.Hslider handles.Vslider handles.option_sel handles.method_sel],'Enable','off');
    set(handles.comuted_list,'Value',[],'Enable','off');
    set([handles.N_ini handles.N_end handles.M_ini handles.M_end],'Visible','off');

    set(handles.nnormal_txt,'String',int2str(length(handles.PARAM)));
    set(handles.ncomuted_txt,'String','0');
    
    okdlg('Não há parâmetros subcomutados na matriz de dados.','Análise','modal'); drawnow;
    ok = 0;
       
end

setappdata(handles.window,'comlist',comlist);
setappdata(handles.window,'comord',comord);

%----------------------------------------------------------------
function updategrid(hObject, eventdata, handles)
global DADOS
% Atualizar tabela

comlist = getappdata(handles.window,'comlist');
if isempty(comlist)
    return
end

valplots = getappdata(handles.window,'valplots');

[N, M] = size(DADOS);
L = 30;

n1 = max(1, N-get(handles.Vslider,'Value')-L+2);
m1 = max(1, get(handles.Hslider,'Value'));

sel = comlist(get(handles.comuted_list,'Value'));

S = (1:min(L,N))';

for m = 1:min(L,M)
    
    y = S;
    y(isnan(DADOS(n1:n1+min(L,N)-1,m1+m-1))) = NaN;
    
    if ~isempty(sel) && any(m==sel-m1+1);
        mfc = handles.red;
    else
        mfc = handles.blue;
    end
    
    set(valplots(m),'YData',y,'MarkerFaceColor',mfc);
    
end

set(handles.N_ini,'String',int2str(n1));
set(handles.N_end,'String',int2str(n1+L-1));

set(handles.M_ini,'String',int2str(m1));
set(handles.M_end,'String',int2str(m1+L-1));

%----------------------------------------------------------------
function window_WindowButtonMotionFcn(hObject, eventdata, handles)
% Funçao executada ao se mover o mouse

comlist = getappdata(handles.window,'comlist');
if isempty(comlist)
    return
end

cp = get(handles.window,'CurrentPoint') + [.5 .5];
ap = get(handles.grid,'Position');
ax = get(handles.grid,'XLim');
ay = get(handles.grid,'YLim');

x = (cp(1)-ap(1))*(ax(2)-ax(1))/ap(3) + ax(1);
y = (cp(2)-ap(2))*(ay(2)-ay(1))/ap(4) + ay(1);

if x >= ax(1) && x <= ax(2) && y >= ay(1) && y <= ay(2);
    ng = 1;
else
    ng = 0;        
end

L = 30;

if ng && x <= handles.M && y >= L-handles.N+.4
    
    N = handles.N;
    x = round(x);
    
    n1 = max(1, N-get(handles.Vslider,'Value')-L+2);
    m1 = max(1, get(handles.Hslider,'Value'));
    
    if x < 18
        aln = 'left';
    else
        aln = 'right';
    end
    set(handles.paramtip,'Position',[x L-y+.4 0],'String',[' ' handles.PARAM{m1+x-1} ' '],'HorizontalAlignment',aln,'Visible','on');
    
else
    set(handles.paramtip,'Position',[0 0 0],'String','','Visible','off');
end

%----------------------------------------------------------------
function grid_ButtonDownFcn(hObject, eventdata, handles)
% Clicar sobre a grade

comlist = getappdata(handles.window,'comlist');

cp = get(handles.grid,'CurrentPoint');

x = round(cp(1,1));
y = round(cp(1,2));

if x <= handles.M && y <= handles.N
    
    N = handles.N;
    L = 30;

    n1 = max(1, N-get(handles.Vslider,'Value')-L+2);
    m1 = max(1, get(handles.Hslider,'Value'));
    
    m = m1+x-1;
    
    k = find(m==comlist);
    if ~isempty(k)
        
        sel = get(handles.comuted_list,'Value');
        
        switch get(handles.option_sel,'Value')
            
            case 1 % Interpolar
                
                switch get(handles.window,'SelectionType')
                    case 'normal'
                        sel = union(sel,k);
                    case 'alt'
                        sel = setdiff(sel,k);
                end
                
            case 2 % Excluir
                sel = k;
        end
        
        set(handles.comuted_list,'Value',sel,'ListboxTop',get(handles.comuted_list,'ListboxTop'));
        updategrid(hObject, eventdata, handles);
        
    end
    
end
