function varargout = R_DAT(varargin)
% R_DAT - Programa de Redução e Análise de dados do IPEV

gui_Singleton = 1;
gui_State = struct('gui_Name', mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @R_DAT_OpeningFcn, ...
    'gui_OutputFcn',  @R_DAT_OutputFcn, ...
    'gui_LayoutFcn',  @R_DAT_LayoutFcn, ...
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
        try
            errorchk;
        end
    end
end

% --------------------------------------------------------------------------------------------------
function h = R_DAT_LayoutFcn(varargin)
% Função de layout inicial

warning('off','MATLAB:dispatcher:InexactCaseMatch');
h = openfig('R_DAT.fig','reuse','visible');

% --------------------------------------------------------------------------------------------------
function R_DAT_OpeningFcn(hObject, eventdata, handles, varargin)
% Função de inicialização

global rdatisrunning

if isempty(rdatisrunning) || ~rdatisrunning
    rdatisrunning = 1;
else
    return
end

set(handles.window,'Visible','off');

clc
disp(' ');
disp(' ');
disp('  -----------------------------------------------------------------------------');
disp('                           ATENÇÃO: R-DAT EM EXECUÇÃO.                         ');
disp('             NÃO UTILIZE O WORKSPACE PARA EXECUTAR OUTROS PROGRAMAS.           ');
disp('                   SE NECESSÁRIO, ABRA OUTRA SESSÃO DE MATLAB.                 ');
disp('  -----------------------------------------------------------------------------');
disp(' ');
disp('                       VERSÃO EXPERIMENTAL PARA MATLAB 7.8                     ');
disp(' ');
disp('  -----------------------------------------------------------------------------');
disp(' ');

set(0,'RecursionLimit',10000);

set(handles.window,'Pointer','watch');

clear global DADOS

try
    
    % Acréscimo do "path" atual e das pastas auxiliares
    RDATpath = which('R_DAT.m');
    ind = find(RDATpath=='\');
    RDATpath  = RDATpath(1:ind(end));
    auxpath   = [RDATpath 'AuxFcn\'];
    dbpath    = [RDATpath 'AuxFcn\DB\'];
    
    path(RDATpath,path);
    path(auxpath,path);
    path(dbpath,path);
    
    handles.RDATpath  = RDATpath;  % Caminho do R_DAT
    handles.auxpath   = auxpath;   % Caminho das funções auxiliares
    handles.dbpath    = dbpath;    % Caminho da base de dados
    
    %Verifica se o path sem acesso a leitura e gravação
    if ~iswrite(dbpath);
        delete(handles.window);
        beep; uiwait(errordlg({'Não é possível executar o R_DAT.','','É necessário acesso completo à pasta ',dbpath(1:end-1)},...
            'Erro','modal')); drawnow;
        rdatisrunning = 0;
        return
    end
    
    % Ocultar controle de "docking"
    if getver >= 7
        set(handles.window,'DockControls','off');
    end
    
    % Localizar toolbox de anemometria
    if exist('pa2zp.m','file')
        anemopath = '';
    else
        toolpath = RDATpath(1:ind(end-1));
        if exist([RDATpath 'AuxFcn\Anemo\'],'dir')
            anemopath = [RDATpath 'AuxFcn\Anemo\'];
        elseif exist([RDATpath 'Anemo\'],'dir')
            anemopath = [RDATpath 'Anemo\'];
        elseif exist([toolpath 'Anemo\'],'dir')
            anemopath = [toolpath 'Anemo\'];
        else
            anemopath = '';
        end
        if exist(anemopath,'dir')
            path(anemopath,path);
        end
    end
    handles.anemopath = anemopath;
    
    % Listas de handles
    handles.vername     = 'R-DAT 7.17 BETA';
    handles.releasedate = '07/Mai/2012';
    handles.inittime    = clock;
    handles.graphs      = [handles.graph handles.graph2 handles.graph3 handles.graph4 handles.graph5];
    handles.menulist    = [handles.FileMenu handles.FunctionsMenu handles.DataMenu handles.ToolsMenu handles.PlotMachLines handles.PartialData];
    handles.controlbtns = [handles.ZoomIn_btn handles.ZoomOut_btn handles.ShiftLeft_btn handles.ShiftRight_btn handles.FitZoom];
    handles.entries     = [handles.entry1 handles.entry2 handles.entry3 handles.entry4];
    handles.entriestxt  = [handles.entry1txt handles.entry2txt handles.entry3txt handles.entry4txt];
    
    FileDisabled    = [handles.SaveMatFile handles.SaveMatFileAs handles.SavePartialMat handles.ConcatFile handles.MergeFile,...
        handles.ExportFile handles.Hold handles.ImportFile_param handles.Properties];
    ToolsDisabled   = [setdiff(get(handles.ToolsMenu,'Children')',handles.ExtToolsMenu) handles.ExportTrajGE handles.PlaybackGE];
    OptionsDisabled = [handles.FitZoom handles.BoxZoom handles.MouseDrag];
    ShowDisabled    = [handles.ShowRuler handles.ShowSyncLine handles.ShowDataTips handles.PlotMachLines handles.ShowTestPoints,...
        handles.ShowTestPointsDescr handles.ShowEvents handles.ShowEventsDescr handles.PartialData];
    
    handles.inidisabled = [FileDisabled handles.FunctionsMenu handles.DataMenu ToolsDisabled OptionsDisabled ShowDisabled,...
        handles.xlist handles.ylist handles.controlbtns];
    
    handles.printlist = [handles.PageSetup_btn handles.PrintPreview_btn handles.Print_btn];
    
    set([0 handles.window handles.graphs],'Units','pixels');
    ss = get(0,'ScreenSize');
    ws = get(handles.window,'Position');
    handles.minscreensize = [800 600]; % Tamanho mínimo da tela
    handles.screenborders = [  8  78]; % Tamanho das bordas da tela (área não utilizável)
    handles.toolbarheight = 24;        % Altura da barra de ferramentas
    
    if ss(3) < handles.minscreensize(1) || ss(4) < handles.minscreensize(2)
        delete(handles.window);
        beep; uiwait(errordlg({[handles.vername,' requer resolução mínima de '...
            num2str(handles.minscreensize(1)) ' × ' num2str(handles.minscreensize(2)) ' pixels.'],...
            ['Resolução atual: ',int2str(ss(3)),' × ',int2str(ss(4)),'.'],...
            ' ','Aviso: Depois de alterar a resolução da tela, é necessário','reinicializar o MATLAB.'},'Erro','modal')); drawnow;
        rdatisrunning = 0;
        return
    end
    
    % Verificação de atualizações
    load(which('DatOptions.mat'),'updt');
    if updt && ~isdeveloper
        SearchUpdate_Callback(hObject, eventdata, handles, 0);
        if ~exist('rdatisrunning','var')
            return
        end
    end
    
    % RDAT 13- executa o arquivo de instalacao proprio, com a estrutura de pastas antiga
    % RDAT 14+ executa o arquivo de instalaçao da rede, com a estrutura de pastas atual
    % Se a estrutura for a antiga, forçar a reinstalaçao
    if exist([matlabroot '\help\toolbox\R_DAT'],'dir')
        uiwait(warndlg({'O R_DAT foi atualizado da versão 7.0 Beta 13 para a 14 ou posterior.','É necessário reestruturar as pastas do R_DAT.'},'Aviso','modal')); drawnow;
        SearchUpdate_Callback(hObject, eventdata, handles, 2);
        if ~exist('rdatisrunning','var')
            return
        end
    end
    
    % Atualizaçao de arquivos individuais
    try
        result = R_DAT_update(handles.vername);
        if result
            clear functions;
        end
        if result == 2
            delete(handles.window);
            warndlg({'Arquivo principal atualizado.','Execute o R_DAT novamente.'},'Aviso','modal');
            rdatisrunning = 0;
            return
        end
    end
    
    % Carregamento de opções salvas
    load(which('DatOptions.mat'));
    
    if ~exist('firstrun','var')
        firstrun = true;
    end
    
    % Lista de arquivos recentes
    setappdata(handles.window,'recents',recents);
    UpdateRecents(hObject, eventdata, handles);
    
    % Configuração de página
    for n = 1:size(pagesetup,1)
        set(handles.window,pagesetup{n,1},pagesetup{n,2});
    end
    
    % Remoção de prefixos
    if ~exist('remprefix','var')
        remprefix = true;
        save(which('DatOptions.mat'),'remprefix','-append',saveopt);
    end
    if remprefix
        set(handles.RemovePrefix,'Checked','on');
    else
        set(handles.RemovePrefix,'Checked','off');
    end
    
    % Analisar subcomutação
    if ~exist('subcomut','var')
        subcomut = true;
        save(which('DatOptions.mat'),'subcomut','-append',saveopt);
    end
    if subcomut
        set(handles.CheckSubcomut,'Checked','on');
    else
        set(handles.CheckSubcomut,'Checked','off');
    end
    
    % Variaveis auxiliares de valor não dinamico (armazenadas no handles) ------------------------------
    handles.fpath    = [pwd '\'];     % Pasta de dados
    handles.expfpath = [pwd '\'];     % Pasta de arquivos exportados
    handles.fname    = '';            % Nome do arquivo atual
    handles.maxparamlength = 48;      % Tamanho máximo de nome de parâmetro (fora numeração)
    handles.precision = precision;    % Precisao decimal do display de coordenadas
    handles.rulersize = rulersize;    % Numero de segmentos da regua
    handles.histbins  = histbins;     % Numero de calulas do histograma
    handles.btnvis    = btnvis;       % Visibilidade dos botões
    bu = 22;  % Borda Up
    bd = 120; % Borda Down
    bl = 74;  % Borda Left
    br = 20;  % Borda Right
    handles.borders  = [bu bd bl br]; % Bordas
    handles.framepos = [205 10 406 60;  6 10 606 60]; % Posições do frame
    
    % Variaveis auxiliares de controle e armazenamento (armazenadas no application data) -----------------------
    setappdata(handles.window,'func','none');          % Codigo da função corrente
    setappdata(handles.window,'change',0);             % Flag de alteração das matrizes de trabalho
    setappdata(handles.window,'cancel',0);             % Flag do botao Cancela
    setappdata(handles.window,'ok',0);                 % Flag do botao Ok
    setappdata(handles.window,'clickfunc','none');     % Codigo da função corrente de clicar mouse (zoom, bar, ruler)
    setappdata(handles.window,'dragfunc','none');      % Flag da função de arrastar mouse (ruler, centerpt, testpts, datatips)
    setappdata(handles.window,'zoomtype','norm');      % Tipo de zoom (norm, rect, drag)
    setappdata(handles.window,'rbbox',0);              % Flag da função "ruberband box"
    setappdata(handles.window,'dragdata',0);           % Coordenadas para arrastamento
    setappdata(handles.window,'sel',[]);               % Lista de pontos selecionados
    setappdata(handles.window,'part',[]);              % Lista de pontos parciais a serem exibidos
    setappdata(handles.window,'events',[]);            % Lista de eventos
    setappdata(handles.window,'testpts',[]);           % Lista de pontos de ensaio
    setappdata(handles.window,'reftime','');           % Tempo de referencia dos eventos
    setappdata(handles.window,'tempdata',[]);          % Dados temporarios
    setappdata(handles.window,'xzoom',[]);             % Vetor de x para zoom in
    setappdata(handles.window,'barpts',[]);            % Vetor de pontos da barra de seleção
    setappdata(handles.window,'timecols',[]);          % Número dos parâmetros de tempo
    setappdata(handles.window,'datatipn',[]);          % Número da linha do datatip
    setappdata(handles.window,'properties',[]);        % Propriedades
    setappdata(handles.window,'setup',[]);             % Configuração de parâmetros para playback
    setappdata(handles.window,'scenario',[]);          % Cenario tatico para playback
    setappdata(handles.window,'btnlines',1);           % Numero de linhas da barra de ferramentas
    setappdata(handles.window,'showsync',0);           % Exibir linha de sincronismo quando selecionada
    setappdata(handles.window,'playbackopt',[]);       % Opções da ferramenta de reprodução do voo
    setappdata(handles.window,'filteropt',{[],[],1});  % Setup da janela de filtro
    setappdata(handles.window,'issingle',0);           % Salvar arquivo com precisão simples
    
    % Listas de parâmetros das funções de exibição múltipla
    setappdata(handles.window,'mp5_list',  {'','','',''});
    setappdata(handles.window,'mp16_list', {'','','','','','','','','','','','','','','',''});
    setappdata(handles.window,'mp3_list',  {'','','',''});
    setappdata(handles.window,'mg5_list',  {'','','',''});
    setappdata(handles.window,'mg3x5_list',{'','','','','','','','','','','','','','',''});
    
    % Dados dos botões das funções
    btndata = getbuttondata(handles);
    btnvis = btnvis(:);
    if length(btnvis) ~= size(btndata,1)
        btnvis = ones(size(btndata,1),1);
    end
    btndata   = [btndata num2cell(btnvis)];
    btnlabels = get([btndata{:,1}],'Label');
    chgs = {'Salvar','Salvar arquivo temporário';...
        'Carregar','Carregar arquivo temporário';...
        'Tipos de linhas','Tipos de linhas e cor de fundo';...
        'Um parâmetro','Conversão de unidades';...
        'Grupo de parâmetros','Conversão de unidades em grupo';...
        'Unidimensional','Interpolação tabular unidimensional';...
        'Bidimensional','Interpolação tabular bidimensional';...
        'y','Renomear parâmetro y';...
        'Pontos selecionados','Excluir pontos selecionados';...
        'Selecionar ...','Selecionar pontos ...';...
        'Todos os pontos','Desselecionar todos os pontos';...
        'Até 5 com mesma abscissa','Plotes múltiplos';...
        'Até 5 com mesma abscissa','Gráficos múltiplos';...
        'Gerenciamento de pontos de ensaio ...','Obter dados ...' };
    for n = 1:size(chgs,1)
        k = strmatch(chgs{n,1},btnlabels,'exact');
        if ~isempty(k)
            btnlabels{k(1)} = chgs{n,2};
        end
    end
    for n = 1:length(btnlabels)
        set(btndata{n,2},'TooltipString',btnlabels{n});
    end
    setappdata(handles.window,'btndata',btndata);
    
    % Dados dos cursores
    [handles.cursors.drag{1}, handles.cursors.drag_hs{1}] = getcursor('DatCursors.mat', 'hand0');
    [handles.cursors.drag{2}, handles.cursors.drag_hs{2}] = getcursor('DatCursors.mat', 'hand1');
    [handles.cursors.zoom,    handles.cursors.zoom_hs   ] = getcursor('DatCursors.mat', 'zoom');
    [handles.cursors.select,  handles.cursors.select_hs ] = getcursor('DatCursors.mat', 'select');
    
    axes(handles.graph); set(handles.window,'Visible','off');
    set(handles.xlabel,'String','x');
    handles.ylabel = ylabel('y','Interpreter','none','BackgroundColor','none','Units','pixels','Position',[-50, .5*(ws(4)-bu-bd), 0]);
    handles.title = title('','Interpreter','none','BackgroundColor','none','Units','pixels','Position',[.5*(ws(3)-bl-br) ws(4)-bu-bd+4 0]);
    handles.ylabels(1) = handles.ylabel;
    
    % Criação dos elementos gráficos
    for n = 5:-1:1
        handles.plots(1,n)   = plot(NaN,NaN);
    end
    handles.plot   = handles.plots(1,1);
    
    handles.selpts    = plot(NaN,NaN,'ro','MarkerSize',5);
    handles.selbar    = plot(NaN,NaN,'Color',[.5 .5 .5],'Marker','+','MarkerEdgeColor',[.5 .5 .5],'MarkerSize',10);
    handles.ruler     = plot(NaN,NaN,'Color','k','Marker','+');
    handles.auxline   = plot(NaN,NaN,'Color',[.5 .5 .5]);
    handles.inipts    = plot(NaN,NaN,'>k','MarkerFaceColor','c','HitTest','off');
    handles.endpts    = plot(NaN,NaN,'<k','MarkerFaceColor','c','HitTest','off');
    handles.eventpts  = plot(NaN,NaN,'r+','MarkerSize',12);
    handles.markertip = text(0,0,' ','Visible','off','Color','k','VerticalAlignment','bottom','Clipping','off','Interpreter','none');
    for n = 1:12
        handles.eventlbl(n) = text(0,0,[' ' num2str(n)],'Visible','off','Color','k','VerticalAlignment','bottom','Clipping','on',...
            'Interpreter','none');
        handles.testptlbl(n) = text(0,0,'','Visible','off','Color','k','VerticalAlignment','bottom','Clipping','on','Interpreter','none');
    end
    handles.auxlines(1) = handles.auxline;
    
    handles.fit      = plot(NaN,NaN,'k--','MarkerSize',5,'LineWidth',2);
    handles.fitpt    = plot(NaN,NaN,'ko','MarkerSize',5,'MarkerFaceColor','k');
    handles.centerpt = plot(NaN,NaN,'r+','MarkerSize',12);
    
    for n = 5:-1:1
        axes(handles.graphs(n)); set(handles.window,'Visible','off');
        if n >= 2
            handles.plots(2,n)   = plot(NaN,NaN);
            handles.ylabels(n)   = ylabel(['y' num2str(n)],'Interpreter','none','BackgroundColor','none','Units','pixels');
            handles.auxlines(n)  = plot(NaN,NaN,'Color',[.5 .5 .5]);
        end
        if n <= 3
            handles.valplots(n) = plot(NaN,NaN,'g.');
            handles.invplots(n) = plot(NaN,NaN,'r.');
        end
        handles.auxplots(n,1) = plot(NaN, NaN,'-.k','LineWidth',2);
        handles.auxplots(n,2) = plot(NaN, NaN,'--r');
        handles.auxplots(n,3) = plot(NaN, NaN,'--m');
        handles.ptmarker(n,1) = text(0,0,'[','FontSize',40,'FontName','Courier New','Color','r','HorizontalAlignment','center','Visible','off','Clipping','on');
        handles.ptmarker(n,2) = text(0,0,']','FontSize',40,'FontName','Courier New','Color','r','HorizontalAlignment','center','Visible','off','Clipping','on');
    end
    handles.plots(2,1)   = handles.plots(1,1);
    
    for n = 1:5
        handles.datatips(n,1,1) = plot(NaN,NaN,'sk','MarkerFaceColor','k','MarkerSize',5);
        handles.datatips(n,2,1) = text(0,0,'','BackgroundColor',[1 1 .8],'EdgeColor',[0 0 0],'FontSize',9,'Margin',.1,'Clipping','on',...
            'HorizontalAlignment','left','VerticalAlignment','bottom','Visible','off','UIContextMenu',handles.DataTipMove);
    end
    for n = 2:5
        axes(handles.graphs(n)); set(handles.window,'Visible','off');
        handles.datatips(n,1,2) = plot(NaN,NaN,'sk','MarkerFaceColor','k','MarkerSize',5);
        handles.datatips(n,2,2) = text(0,0,' ','BackgroundColor',[1 1 .8],'EdgeColor',[0 0 0],'FontSize',9,'Margin',.1,...
            'HorizontalAlignment','left','VerticalAlignment','bottom','Clipping','on','Visible','off',...
            'UIContextMenu',handles.DataTipMove);
    end
    handles.datatips(1,:,2) = handles.datatips(1,:,1);
    
    set(handles.graphs(2:5),'Visible','off');
    
    for n = 1:5;
        set(handles.plots(:,n),...
            'LineStyle',       linespec(n).linestyle,...
            'Color',           linespec(n).color,...
            'LineWidth',       linespec(n).linewidth,...
            'Marker',          linespec(n).marker,...
            'MarkerEdgeColor', linespec(n).markeredgecolor,...
            'MarkerFaceColor', linespec(n).markerfacecolor,...
            'MarkerSize',      linespec(n).markersize);
        
        if n <= 3
            hp = handles.plots(2,n);
            hpc = get(hp,'MarkerEdgeColor');
            if hpc(1) <= .1 && hpc(2) >= .8 && hpc(3) <= .1 % Verdes
                cv = 'b';
            else
                cv = [0 .8 0];
            end
            if hpc(1) >= .8 && hpc(2) <= .1 && hpc(3) <= .1 % Vermelhos
                ci = 'm';
            else
                ci = 'r';
            end
            set(handles.valplots(n),'Marker', get(hp,'Marker'), 'MarkerSize', get(hp,'MarkerSize'), 'MarkerEdgeColor', cv, 'MarkerFaceColor', cv);
            set(handles.invplots(n),'Marker', get(hp,'Marker'), 'MarkerSize', get(hp,'MarkerSize'), 'MarkerEdgeColor', ci, 'MarkerFaceColor', ci);
        end
        
    end
    
    guidata(hObject, handles);
    
    % Reposicionamento da tela
    set(handles.infobox,'UserData',1);
    set(handles.window,'Position',[.5*handles.screenborders(1) .5*handles.screenborders(2)-5,...
        ss(3)-handles.screenborders(1) ss(4)-handles.screenborders(2)],'Visible','on','Name',handles.vername);
    
    set(handles.graphs,'Color',colorspec.graphcolor);
    switch colorspec.colordef
        case 'w'
            ColorDefWhite_Callback(hObject, eventdata, handles, 0);
        case 'k'
            ColorDefBlack_Callback(hObject, eventdata, handles, 0);
    end
    
    set(handles.inidisabled,'Enable','off');
    
    % Splash screen
    
    splashfile = [auxpath 'datsplash.bmp'];
    if exist(splashfile,'file')
        
        splashdisable = [handles.FileMenu handles.EditMenu handles.ToolsMenu handles.OptionsMenu handles.DisplayMenu handles.HelpMenu handles.Fetch];
        
        set(splashdisable,'Enable','off');
        
        UpdateButtonStatus(hObject, eventdata, handles);
        set(handles.window,'CloseRequestFcn',[],'WindowButtonMotionFcn',[]);
        
        [X,M] = imread(which(splashfile));
        if ~isempty(M)
            X = ind2rgb(X,M);
        end
        for n = 1:3
            X(:,:,n) = flipud(X(:,:,n));
        end
        X = double(X)/255;
        bgc = get(handles.graph,'Color');
        Xi = X(:,:,1)==1 & X(:,:,2)==0 & X(:,:,3)==1;
        for n = 1:size(Xi,1)
            for m = 1:size(Xi,2)
                if Xi(n,m)
                    X(n,m,1) = bgc(1);
                    X(n,m,2) = bgc(2);
                    X(n,m,3) = bgc(3);
                end
            end
        end
        
        ap = get(handles.graph,'Position');
        [h,w] = size(X(:,:,1));
        xs = .5 + .5*w/ap(3)*[-1 1];
        ys = .5 + .5*h/ap(4)*[-1 1];
        axes(handles.graph);
        set(handles.graph,'XGrid','off','YGrid','off');
        imh = image(xs,ys,X);
        txh(1) = text(mean(xs),ys(2)+.1,'Instituto de Pesquisas e Ensaios em Voo','Color',[0 .2 1],...
            'HorizontalAlignment','Center','FontSize',18,'FontAngle','italic','FontWeight','demi');
        txh(2) = text(mean(xs),ys(2)+.05,'Divisão de Ensaios em Voo','Color',[0 .2 1],...
            'HorizontalAlignment','Center','FontSize',18,'FontAngle','italic','FontWeight','demi');
        txh(3) = text(mean(xs),ys(1)-.05,[handles.vername ' - REDUÇÃO E ÁNALISE DE DADOS'],'Color',[1 .5 .25],...
            'HorizontalAlignment','Center','FontSize',18,'FontAngle','italic','FontWeight','demi','Interpreter','none');
        set(handles.graph,'XLim',[0 1],'YLim',[0 1]);
        pause(2);
        delete([imh, txh]);
        set(handles.graph,'YLimMode','auto','XGrid','on','YGrid','on');
        set(handles.window,'CloseRequestFcn','R_DAT(''Window_CloseRequestFcn'',gcf,[],guidata(gcf))',...
            'WindowButtonMotionFcn','R_DAT(''Window_ButtonMotionFcn'',gcbo,[],guidata(gcbo))');
        
        set(splashdisable,'Enable','on');
    end
    
    UpdateButtonStatus(hObject, eventdata, handles);
    
    try wavplay(wavread('init.wav')); end
    
    t = clock;
    msg = {[datetime2str(t(1:5)),'. Bem-vindo ao ',handles.vername,'©'],'Desenvolvido por IPEV/EEV para MATLAB 6.5 e 7.8'};
    set(handles.infobox,'String',msg,'Value',length(msg));
    
catch
    beep; uiwait(errordlg(lasterr,'Erro','modal')); drawnow;
    delete(handles.window);
    rdatisrunning = 0;
    return
end

set(handles.window,'Pointer','arrow');

% Anemometry toolbox check
if ~exist('pa2zp.m','file') 
    uiwait(warndlg({'O Toolbox de anemometria não foi encontrado.','',...
            'As operações que necessitam das conversões anemométricas',...
            'não serão executadas.','',...
            'Solicite auxílio à CTI ou consulte o arquivo abaixo:','',...
            [netpath 'Instalação.pdf']},'Aviso','modal')); drawnow;
end

set(handles.window,'Visible','on');

% Mensagens de 1ª execução
if firstrun && ~isdeveloper
    if getver < 7
        uiwait(warndlg({'Esta é uma versão experimental do R-DAT para MATLAB 7.8,',...
                'mas que ainda mantém a compatibilidade com a versão 6.5.',...
                'Futuras versões poderão perder essa capacidade.',...
                'Informe qualquer problema ao programador responsável.','',...
                'Após migração do MATLAB 6.5 para o 7.8, será necessário',...
                'reinstalar o R-DAT neste computador. Solicite auxílio',...
                'à CTI ou consulte o seguinte arquivo:','',...
                [netpath 'Instalação.pdf']},'Aviso','modal')); drawnow;
    end
    
    pause(.2);
    uiwait(msgbox({'O que há de novo nesta versão:','',...
            '  - Verificação automática de subcomutação ao carregar arquivo',...
            '    (pode ser desabilitada pelo menu Opções),',...
            '  - Análise e correção de parâmetros subcomutados (menu Dados),',...
            '  - Nova ortografia da Língua Portuguesa,',...
            '  - Pequenas correções e melhorias.'},'Aviso','modal')); drawnow;
    
    firstrun = 0;
    save(which('DatOptions.mat'),'firstrun','-append',saveopt);
end

% -------------------------------------------------------------------
function varargout = R_DAT_OutputFcn(hObject, eventdata, handles)


% ####################################################################
%                    FUNÇÕES DO MENU ARQUIVO
% ####################################################################

function LoadMatFile_Callback(hObject, eventdata, handles, fpath, fname)
% Função de carregamento de Matão..

if nargin ~=5
    fname = '';
end

if isempty(fname)
    PreventiveSave(hObject, eventdata, handles);
    [fname, fpath, opt] = uigetfile({...
        '*.mat','Arquivo mat (*.mat)';...
        '*.zip','Arquivo mat compactado (*.zip)'},'Carregar arquivo mat',handles.fpath); drawnow;
else
    switch fname(end-2:end)
        case 'mat'
            opt = 1;
        case 'zip'
            opt = 2;
    end
end

if ~ischar(fname)
    Window_ButtonMotionFcn(hObject, eventdata, handles);
    return
end

if opt == 2
    iszip = 1;
    zpath = fpath;
    zname = fname;
    fpath = [tempdir 'R_DAT\'];
    fname = [fname(1:end-3) 'mat'];
    try
        dos(['mkdir "' fpath '"']);
        
        h = waitdlg(['Extraindo arquivo ''' zname ''' ...'],'Aguarde','modal');
        unzip([zpath zname],fpath);
        try, delete(h); end
        
    catch
        beep; uiwait(errordlg(lasterr,'Erro','modal')); drawnow;
        return
    end
else
    iszip = 0;
end

if iszip && ~exist([fpath fname],'file')
    beep; uiwait(errordlg(['O arquivo ''' zname ''' não contém um arquivo mat de mesmo nome.'],'Erro','modal')); drawnow;
    if iszip, dos(['rmdir "' fpath '" /S /Q']); end
    Window_ButtonMotionFcn(hObject, eventdata, handles);
    return
end

set(handles.window,'Pointer','watch');
[DADOS, PARAM, err] = LoadMat(fname, fpath, handles.maxparamlength);

if isempty(DADOS) || isempty(PARAM)
    beep; uiwait(errordlg({['Erro ao carregar o arquivo ''' fname '''.'],err},'Erro','modal')); drawnow;
    if iszip, dos(['rmdir "' fpath '" /S /Q']); end
    Window_ButtonMotionFcn(hObject, eventdata, handles);
    return
end

% Arquivo valido
if iszip
    handles.fpath = zpath;
    handles.fname = zname;
    NewEvent(handles,['Arquivo carregado: ''' zname '''.']);
    UpdateRecents(hObject, eventdata, handles, zpath, zname);
else
    handles.fpath = fpath;
    handles.fname = fname;
    NewEvent(handles,['Arquivo carregado: ''' fname '''.']);
    UpdateRecents(hObject, eventdata, handles, fpath, fname);
end
guidata(hObject, handles);

StartupWorkData(hObject, eventdata, handles, DADOS, PARAM);

fileinfo = whos('-file',[fpath fname]);
properties = [];

% Matrizes auxiliares
if strmatch('properties',{fileinfo.name},'exact');
    load([fpath fname],'properties');
else
    try
        if strmatch('ENSAIO',{fileinfo.name},'exact');
            load([fpath fname],'ENSAIO');
            ENSAIO = cellstr(ENSAIO);
            for n = length(ENSAIO):-1:1, if isempty(ENSAIO{n}), ENSAIO(n) = []; end, end
            properties.mission = ENSAIO;
        end
    end
    try
        if strmatch('NAMES',{fileinfo.name},'exact');
            load([fpath fname],'NAMES');
            NAMES = cellstr(NAMES);
            for n = length(NAMES):-1:1, if isempty(NAMES{n}), NAMES(n) = []; end, end
            properties.crew = NAMES;
        end
    end
    try
        if strmatch('NOMES',{fileinfo.name},'exact');
            load([fpath fname],'NOMES');
            NOMES = cellstr(NOMES);
            for n = length(NOMES):-1:1, if isempty(NOMES{n}), NOMES(n) = []; end, end
            properties.crew = NOMES;
        end
    end
    try
        if strmatch('OBS',{fileinfo.name},'exact');
            load([fpath fname],'OBS');
            OBS = cellstr(OBS);
            for n = length(OBS):-1:1, if isempty(OBS{n}), OBS(n) = []; end, end
            OBS = OBS(:);
        else
            OBS = {};
        end
    end
    try
        if strmatch('INFOS',{fileinfo.name},'exact');
            load([fpath fname],'INFOS');
            INFOS = cellstr(INFOS);
            for n = length(INFOS):-1:1, if isempty(INFOS{n}), INFOS(n) = []; end, end
            INFOS = INFOS(:);
            properties.remarks = [INFOS; OBS];
        end
    end
    try
        if strmatch('CONFIG',{fileinfo.name},'exact');
            load([fpath fname],'CONFIG');
            CONFIG = cellstr(CONFIG);
            for n = length(CONFIG):-1:1, if isempty(CONFIG{n}), CONFIG(n) = []; end, end
            properties.inventory = CONFIG;
        end
    end
end
setappdata(handles.window,'properties',properties);

% Configuraçao e cenario
try
    if strmatch('setup',{fileinfo.name},'exact');
        load([fpath fname],'setup');
        setappdata(handles.window,'setup',setup);
    end
end
try
    if strmatch('scenario',{fileinfo.name},'exact');
        load([fpath fname],'scenario');
        setappdata(handles.window,'scenario',scenario);
    end
end

% Eventos e pontos de ensaio
if strmatch('events',{fileinfo.name},'exact');
    load([fpath fname],'events');
    setappdata(handles.window,'events',events);
end
if strmatch('testpts',{fileinfo.name},'exact');
    load([fpath fname],'testpts');
    testpts = backcompat(testpts,'testpts');
    setappdata(handles.window,'testpts',testpts);
end

if strmatch('reftime',{fileinfo.name},'exact');
    load([fpath fname],'reftime');
    setappdata(handles.window,'reftime',reftime);
    UpdateTimeCols(hObject, eventdata, handles);
    
    tcol = findpar(PARAM,reftime,0,1);
    if isempty(reftime)
        uiwait(warndlg('Tempo de referência não definido.','Aviso','modal')); drawnow;
    elseif isempty(tcol)
        uiwait(warndlg(['O tempo de referência ''' reftime ''' não foi encontrado no arquivo.'],'Aviso','modal')); drawnow;
    elseif ~IsTimeOk(double(DADOS(:,tcol)))
        uiwait(warndlg({['O tempo de referência ''' reftime ''' não é adequado.'],...
                'O tempo deve ser monotônico crescente e sem pontos inválidos.'},'Aviso','modal')); drawnow;
    end
end

if (exist('events','var') || exist('testpts','var')) && ~exist('reftime','var')
    uiwait(warndlg('Tempo de referência não definido.','Aviso','modal')); drawnow;
end

if iszip, dos(['rmdir "' fpath '" /S /Q']); end
Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function ImportFile_xls_Callback(hObject, eventdata, handles)
% Função para importação de planilhas Excel
% Formato da planilha:
%   Param_1 Param_2 Param_3 ...  (nomes dos parâmetros - opcional)
%   Unit_1  Unit_2  Unit_3  ...  (unidades - opcional)
%   Val_11  Val_12  Val_13  ...  (valores numericos)
%   Val_21  Val_22  Val_23  ...
%     :      :      :

PreventiveSave(hObject, eventdata, handles);

[fname, fpath] = uigetfile({'*.xls','Planilha MS Excel (*.xls)'},'Indique a planilha Excel',handles.fpath); drawnow;

if ~ischar(fname)
    Window_ButtonMotionFcn(hObject, eventdata, handles);
    return
end

set(handles.window,'Pointer','watch');
try
    [DADOS, param] = xlsread([fpath fname]);
catch
    beep; uiwait(errordlg('Arquivo com formato incompatível.','Erro','modal')); drawnow;
    Window_ButtonMotionFcn(hObject, eventdata, handles);
    return
end

% Eliminação de NaNs da matriz param
if ~isempty(param)
    for n = 1:size(param,1)
        for m = 1:size(param,2)
            if strcmpi(param{n,m},'NaN')
                param{n,m} = [];
            end
        end
    end
    for n = size(param,1):-1:1
        if isempty([param{n,:}])
            param(n,:) = [];
        end
    end
end

% Formataçao do cabeçalho
if size(param,1) > 2
    opt = RDAT_InputOption('Opção','Informe a formatação do cabeçalho:',...
        {'Ignorar cabeçalho','Uma linha (nomes dos parâmetros)','Duas linhas (nomes dos parâmetros e unidades)'},3,300);
    if isempty(opt)
        Window_ButtonMotionFcn(hObject, eventdata, handles);
        return
    end
    param(opt:end,:) = [];
end
if isempty(param) && ~isempty(DADOS)
    param = cellstr(char(abs('?')*ones(size(DADOS,2),1)))';
end

if isempty(DADOS) || isempty(param) || size(DADOS,2) ~= size(param,2) % Checa compatibilidade
    beep; uiwait(errordlg('Planilha com formato incompatível.','Erro','modal')); drawnow;
    Window_ButtonMotionFcn(hObject, eventdata, handles);
    return
end

% Formatação de PARAM

for n = 1:size(param,1)
    for m = 1:size(param,2)
        if ~ischar(param{n,m})
            if n == 1
                param{n,m} = '?';
            else
                param{n,m} = '';
            end
        end
    end
end

if size(param,1) == 1
    PARAM = param';
else
    unit  = param(2,:)';
    param = param(1,:)';
    
    for n = 1:length(unit)
        unit{n}(unit{n}=='(') = [];
        unit{n}(unit{n}==')') = [];
        unit{n}(unit{n}=='[') = [];
        unit{n}(unit{n}==']') = [];
        PARAM{n,1} = strrep([param{n} ' (' unit{n} ')'], ' ()','');
    end
    
end

PARAM = SetParamFormat(PARAM,handles.maxparamlength);

sel = listdlg2('Name','Importar planilha Excel','HeaderString',{'Indique os parâmetros de tempo que','apresentam formato HH:MM:SS:'},...
    'SelectionMode','multiple','ListString',PARAM(1:end-1),'OKString','OK','CancelString','Cancela',...
    'SelectAllString','Selecionar tudo','SelectNoneString','Limpar','ListSize',[200 305]); drawnow;
for n = 1:length(sel)
    d0 = floor(DADOS(1,sel(n)));
    DADOS(:,sel(n)) = ( DADOS(:,sel(n))-d0 ) * 24*3600;
end

[DADOS, PARAM] = InsertNOBS(DADOS,PARAM);
CheckRepParam(PARAM);

NewEvent(handles,['Arquivo importado: ''' fname '''.']);
handles.fpath = fpath;
handles.fname = fname(1:end-4);
guidata(hObject, handles);
StartupWorkData(hObject, eventdata, handles, DADOS, PARAM);
pause(.4);
RemoveInvalidParams_Callback(hObject, eventdata, handles, 0);
setappdata(handles.window,'change',1);

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function ImportFile_txt_Callback(hObject, eventdata, handles)
% Função para importação de arquivos de texto formatado
% Formato do arquivo:
%   Param_1 Param_2 Param_3 ...  (nomes dos parâmetros - opcional)
%   Unit_1  Unit_2  Unit_3  ...  (unidades - opcional)
%   Val_11  Val_12  Val_13  ...  (valores numericos)
%   Val_21  Val_22  Val_23  ...
%     :      :      :

PreventiveSave(hObject, eventdata, handles);

[fname, fpath] = uigetfile({...
        '*.txt;*.dat;*.csv','Dados em formato texto (*.txt, *.dat, *.csv)';...
        '*.*','Todos os arquivos'},'Indique o arquivo de texto',handles.fpath); drawnow;

if ~ischar(fname)
    Window_ButtonMotionFcn(hObject, eventdata, handles);
    return
end

button = questdlg('Deseja habilitar substituição de texto-padrão por números?','Opção','Sim','Não','Não'); drawnow;
if strcmp(button,'Sim')
    [fname2, fpath2, opt] = uigetfile({'*.txt','Arquivo de texto (*.txt)';'*.xls','Planilha MS Excel (*.xls)'},...
        'Indique o arquivo de texto para substituição',fpath); drawnow;
    if ischar(fname2)
        try
            if opt == 1
                [num, txt] = txtread([fpath2 fname2]);
            else
                [num, txt] = xlsread([fpath2 fname2]);
            end
            if isempty(num) || size(num,1) ~= size(txt,1) || size(num,2) ~= 1 || size(txt,2) ~= 1
                beep; uiwait(errordlg('Arquivo de texto para substituição com formato incompatível.','Erro','modal')); drawnow;
                return
            end
            subst(:,1) = txt;
            subst(:,2) = mat2cell(num,ones(size(num,1),1));
            if size(char(txt),2) > 32
                beep; uiwait(errordlg('Texto para substituição deve ter no máximo 32 caracteres.','Erro','modal')); drawnow;
                return
            end
            if length(txt) <= 15
                liststr = [char(txt) char(ones(size(subst,1),1)*abs('  -->  ')) num2str(num)];
            else
                liststr = char([char(txt(1:15)) char(ones(15,1)*abs('  -->  ')) num2str(num(1:15))],'     (...)');
            end
            button = questdlg({'Substituição de texto-padrão por números:',' ',liststr,' ',...
                    'Deseja prosseguir?'},'Confirmação','Sim','Não','Sim'); drawnow;
            if ~strcmp(button,'Sim')
                return
            end
        catch
            beep; uiwait(errordlg('Arquivo de texto para substituição com formato incompatível.','Erro','modal')); drawnow;
            return
        end
    else
        subst = [];
    end
else
    subst = [];
end

set(handles.window,'Pointer','watch');

set(handles.window,'Pointer','watch');
try
    [DADOS, param, err] = txtread([fpath fname],[],subst);
    if ~isempty(err)
        if strcmp(err,'Operação cancelada.')
            uiwait(warndlg(err,'Aviso','modal')); drawnow;
        else
            beep; uiwait(errordlg(err,'Erro','modal')); drawnow;
        end
        Window_ButtonMotionFcn(hObject, eventdata, handles);
        return
    end
catch
    beep; uiwait(errordlg('Arquivo com formato incompatível.','Erro','modal')); drawnow;
    Window_ButtonMotionFcn(hObject, eventdata, handles);
    return
end

% Formataçao do cabeçalho
if size(param,1) > 2
    opt = RDAT_InputOption('Opção','Informe a formatação do cabeçalho:',...
        {'Ignorar cabeçalho','Uma linha (nomes dos parâmetros)','Duas linhas (nomes dos parâmetros e unidades)'},3,300);
    if isempty(opt)
        Window_ButtonMotionFcn(hObject, eventdata, handles);
        return
    end
    param(opt:end,:) = [];
end
if isempty(param) && ~isempty(DADOS)
    param = cellstr(char(abs('?')*ones(size(DADOS,2),1)))';
end

if isempty(DADOS) || isempty(param) || size(DADOS,2) ~= size(param,2) % Checa compatibilidade
    beep; uiwait(errordlg('Arquivo com formato incompatível.','Erro','modal')); drawnow;
    Window_ButtonMotionFcn(hObject, eventdata, handles);
    return
end

% Formatação de PARAM

for n = 1:size(param,1)
    for m = 1:size(param,2)
        if ~ischar(param{n,m})
            if n == 1
                param{n,m} = '?';
            else
                param{n,m} = '';
            end
        end
    end
end

if size(param,1) == 1
    PARAM = param';
else
    unit  = param(2,:)';
    param = param(1,:)';
    
    for n = 1:length(unit)
        unit{n}(unit{n}=='(') = [];
        unit{n}(unit{n}==')') = [];
        unit{n}(unit{n}=='[') = [];
        unit{n}(unit{n}==']') = [];
        PARAM{n,1} = strrep([param{n} ' (' unit{n} ')'], ' ()','');
    end
    
end

PARAM = SetParamFormat(PARAM,handles.maxparamlength);
[DADOS, PARAM] = InsertNOBS(DADOS,PARAM);
CheckRepParam(PARAM);

NewEvent(handles,['Arquivo importado: ''' fname '''.']);
handles.fpath = fpath;
handles.fname = fname(1:end-4);
guidata(hObject, handles);
StartupWorkData(hObject, eventdata, handles, DADOS, PARAM);
pause(.4);
RemoveInvalidParams_Callback(hObject, eventdata, handles, 0);
setappdata(handles.window,'change',1);

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function ImportFile_J_Callback(hObject, eventdata, handles)
% Função para importar arquivo J de processamento DGPS

PreventiveSave(hObject, eventdata, handles);

[fname, fpath] = uigetfile({'J*.*','Arquivo J'},'Indique o arquivo de DGPS',handles.fpath); drawnow;

if ~ischar(fname)
    Window_ButtonMotionFcn(hObject, eventdata, handles);
    return
end

set(handles.window,'Pointer','watch');

try
    DADOS = load([fpath fname],'-ascii');
catch
    beep; uiwait(errordlg('Arquivo J com formato incompatível.','Erro','modal')); drawnow;
    Window_ButtonMotionFcn(hObject, eventdata, handles);
    return
end
if isempty(DADOS) || size(DADOS,2) ~= 18
    beep; uiwait(errordlg('Arquivo J com formato incompatível.','Erro','modal')); drawnow;
    Window_ButtonMotionFcn(hObject, eventdata, handles);
    return
end

PARAM = {'Tempo GPS (s)'  ;...
        'PDOP'            ;...
        'Dist Leste (m)'  ;...
        'Erro RMS E (m)'  ;...
        'Dist Norte (m)'  ;...
        'Erro RMS N (m)'  ;...
        'Altura (m)'      ;...
        'Erro RMS H (m)'  ;...
        'Vel Leste (m/s)' ;...
        'RMS Vel E (m/s)' ;...
        'Vel Norte (m/s)' ;...
        'RMS Vel N (m/s)' ;...
        'Vel Vert (m/s)'  ;...
        'RMS VVert (m/s)' ;...
        'Resíduo (m)'     ;...
        'Chi²'            ;...
        'SVs'             ;...
        'Mov/Stat (1/0)'  }; % Internamente, PARAM é cell de strings. Ao salvar será char array.

PARAM2 = {'Dist Horiz (m)';...
        'Dist Total (m)'  ;...
        'Radial (°)'      ;...
        'Curso (°)'       ;...
        'Vel Horiz (m/s)' ;...
        'Vel Res (m/s)'   ;...
        'Desloc Horiz (m)';...
        'Desloc Total (m)';...
        'Rampa Geomét (°)';...
        'No. OBS.'        };

parnames = {'Distância Horizontal (m)';...
        'Distância Total (m)'         ;...
        'Radial da Estação Base (°)'  ;...
        'Curso Verdadeiro (°)'        ;...
        'Velocidade Horizontal (m/s)' ;...
        'Velocidade Resultante (m/s)' ;...
        'Deslocamento Horizontal (m)' ;...
        'Deslocamento Total (m)'      ;...
        'Rampa Geométrica (°)'        };    

opt = RDAT_InputOption('Opção','Indique os parâmetros adicionais:',parnames,ones(1,length(parnames)),220); drawnow;

set(handles.window,'Pointer','watch');

if isempty(opt)
    opt = zeros(length(parnames),1);
end

opt(end+1) = 1; % No.OBS. sempre é adicionado

DADOS2 = zeros(size(DADOS,1),length(find(opt)));

% Calculo de parâmetros adicionais
npar = 1;
for n = 1:length(opt)
    if opt(n)
        switch n
            case 1  % Distância Horizontal
                DADOS2(:,npar) = sqrt(DADOS(:,3).^2 + DADOS(:,5).^2);
            case 2  % Distância Total
                DADOS2(:,npar) = sqrt(DADOS(:,3).^2 + DADOS(:,5).^2 + DADOS(:,7).^2);
            case 3  % Radial da Estação Base
                DADOS2(:,npar) = mod(180/pi*atan2(DADOS(:,3),DADOS(:,5 )),360);
            case 4  % Curso Verdadeiro
                VE = DADOS(:,9);
                VN = DADOS(:,11);
                mE = zeros(size(VE));
                mN = zeros(size(VN));
                sE = zeros(size(VE));
                sN = zeros(size(VN));
                N = length(VE);
                for m = 1:N
                    mE(m) = nanmean(VE(max(1,m-5):min(m+5,N)));
                    mN(m) = nanmean(VN(max(1,m-5):min(m+5,N)));
                    sE(m) = nanstd(VE(max(1,m-5):min(m+5,N)));
                    sN(m) = nanstd(VN(max(1,m-5):min(m+5,N)));
                end
                invcrs = abs(mE)-2*sE <= 0 & abs(mN)-2*sN <= 0;
                Crs = mod(180/pi*atan2(DADOS(:,9),DADOS(:,11)),360);
                Crs(invcrs) = NaN;
                Crs = denan(Crs);
                DADOS2(:,npar) = Crs;
            case 5  % Velocidade Horizontal
                DADOS2(:,npar) = sqrt(DADOS(:,9).^2 + DADOS(:,11).^2);
            case 6  % Velocidade Resultante
                DADOS2(:,npar) = sqrt(DADOS(:,9).^2 + DADOS(:,11).^2 + DADOS(:,13).^2);
            case 7  % Deslocamento Horizontal
                DADOS2(:,npar) = [0; cumsum(sqrt(diff(DADOS(:,3)).^2 + diff(DADOS(:,5)).^2))];
            case 8  % Deslocamento Total
                DADOS2(:,npar) = [0; cumsum(sqrt(diff(DADOS(:,3)).^2 + diff(DADOS(:,5)).^2 + diff(DADOS(:,7)).^2))];
            case 9  % Rampa Geométrica
                Vh = sqrt(DADOS(:,9).^2 + DADOS(:,11).^2);
                Vh(Vh==0) = NaN;
                DADOS2(:,npar) = atan(DADOS(:,13)./Vh)*180/pi;
            case 10 % Número de Observações
                DADOS2(:,npar) = (1:size(DADOS,1))';
        end
        npar = npar + 1;
    end
end

DADOS = [DADOS DADOS2];
PARAM = [PARAM; PARAM2(find(opt))];

button = questdlg('Deseja descontar o tempo referente aos dias da semana GPS?','Opção','Sim','Não','Não'); drawnow;
if strcmp(button,'Sim')
    dd = min(floor(DADOS(:,1)/(24*3600)));
    DADOS(:,1) = DADOS(:,1)-dd*24*3600;
end

PARAM = SetParamNumbers(PARAM);

NewEvent(handles,['Arquivo importado: ''' fname '''.']);
handles.fpath = fpath;
handles.fname = fname(1:end-4);
guidata(hObject, handles);
StartupWorkData(hObject, eventdata, handles, DADOS, PARAM);
setappdata(handles.window,'change',1);

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function ImportFile_C_Callback(hObject, eventdata, handles)
% Função para importar arquivo C de processamento DGPS

PreventiveSave(hObject, eventdata, handles);

[fname, fpath] = uigetfile({'C*.*','Arquivo C'},'Indique o arquivo de DGPS',handles.fpath); drawnow;

if ~ischar(fname)
    Window_ButtonMotionFcn(hObject, eventdata, handles);
    return    
end

set(handles.window,'Pointer','watch');

try
    fid = fopen([fpath fname]);
    D = fread(fid);
    D = D';
    fclose(fid);
catch
    beep; uiwait(errordlg(lasterr,'Erro','modal')); drawnow;
    try
        fclose(fid);
    end
    Window_ButtonMotionFcn(hObject, eventdata, handles);
    return    
end

if isempty(D)
    beep; uiwait(errordlg('Arquivo com formato incompatível.','Erro','modal')); drawnow;
    Window_ButtonMotionFcn(hObject, eventdata, handles);
    return
end

% Eliminação de "pre-enter"
D(D==13) = [];

% Extração das informações iniciais
L1 = strfind(char(D(1:min(1000,length(D)))),'SITE');
if isempty(L1)
    beep; uiwait(errordlg('Arquivo com formato incompatível.','Erro','modal')); drawnow;
    Window_ButtonMotionFcn(hObject, eventdata, handles);
    return
else
    L1 = L1(1);
end

if L1 > 1
    remarks = char(D(1:L1-2));
    D(1:L1-1) = [];
else
    remarks = '';
end

% Eliminação do cabeçalho
L = find(D==10);  % Localização de "enter"
if isempty(L)
    beep; uiwait(errordlg('Arquivo com formato incompatível.','Erro','modal')); drawnow;
    Window_ButtonMotionFcn(hObject, eventdata, handles);
    return
end
D(1:L(1)) = [];

% Eliminação de espaços contiguos
S  = D==32;
S2 = [0 S(1:end-1)];
S  = S&S2;
D(S) = [];

% Eliminação de 'N' e 'E'
D(D==abs('N')) = [];
D(D==abs('E')) = [];

% Substituição de 'S' e 'W' por '-'
n = find(D==abs('S'));
D(n) = '-';
D(n+1) = [];
n = find(D==abs('W'));
D(n) = '-';
D(n+1) = [];

% Eliminação do caracter "/" para leitura de datas
D(D==abs('/')) = ' ';

% Definição do caracter delimitador
dlm = ' ';

% Eliminação de linhas vazias
while D(1)==10, D(1) = []; end
L = find(D==10);  % Localização de "enter"
D(L(find(diff(L)==1))) = [];

% Colocação de "enter" no final
if D(end) ~= 10;
    D = [D 10];    
end
L = [0 find(D==10)];

% Estimativa do tamanho da matriz
line1 = D(L(1)+1:L(2)-1);
Ndlm  = length(find(line1==dlm));

h = waitbar(0,['Capturando arquivo ''' fname '''.'],'Name','0.0% concluído',...
    'Color',get(handles.ZoomIn_btn,'BackgroundColor'),'Renderer','zbuffer','Pointer','watch','WindowStyle','modal');

% Captura das células
D2 = cell(length(L)-1,Ndlm+1);
try
    for n = 1:length(L)-1;
        Dline = D(L(n)+1:L(n+1)-1);
        Ddlm = [0, find(Dline == dlm), length(Dline)+1];
        for m = 1:length(Ddlm)-1;
            D2{n,m} = char(Dline(Ddlm(m)+1:Ddlm(m+1)-1));
        end
        Pd = .5*n/(length(L)-1);
        if ishandle(h)
            try
                waitbar(Pd,h);
                set(h,'Name',[num2str(100*Pd,'%1.1f') '% concluído']);
            end
        else
            uiwait(warndlg('Operação cancelada.','Aviso','modal')); drawnow;
            Window_ButtonMotionFcn(hObject, eventdata, handles);
            return
        end
    end
    D = [];
catch
    try, delete(h); end
    beep; uiwait(errordlg('Arquivo com formato incompatível.','Erro','modal')); drawnow;
    Window_ButtonMotionFcn(hObject, eventdata, handles);
    return
end
if isempty(D2)
    try, delete(h); end
    beep; uiwait(errordlg('Arquivo com formato incompatível.','Erro','modal')); drawnow;
    Window_ButtonMotionFcn(hObject, eventdata, handles);
    return
end

try
    % Conversao para valores numericos
    [N,M] = size(D2);
    DADOS = zeros(size(D2));
    for n = 1:N
        for m = 1:M
            val = str2double(D2{n,m});
            if isnan(val)
                val = str2time(D2{n,m}); % Tenta ler "hh:mm:ss"
            end
            DADOS(n,m) = val;
        end
        Pd = .5+ .5*n/N;
        if ishandle(h)
            try
                waitbar(Pd,h,['Convertendo arquivo ''' fname '''.']);
                set(h,'Name',[num2str(100*Pd,'%1.1f') '% concluído']);
            end
        else
            uiwait(warndlg('Operação cancelada.','Aviso','modal')); drawnow;
            Window_ButtonMotionFcn(hObject, eventdata, handles);
            return
        end
    end
    
    % Eliminação da coluna 'SITE', troca de Mes e Dia e conversao do ano para 4 digitos
    DADOS(:,1) = [];
    aux = DADOS(:,2);
    DADOS(:,2) = DADOS(:,1);
    DADOS(:,1) = aux;
    ind = DADOS(:,3)>=0 & DADOS(:,3)<60;
    DADOS(ind,3) = DADOS(ind,3) + 2000;
    ind = DADOS(:,3)>=60 & DADOS(:,3)<100;
    DADOS(ind,3) = DADOS(ind,3) + 1900;
    
    % Inclusao de NoObs
    DADOS(:,end+1) = (1:size(DADOS,1))';
    
    % Inserção do nome do ROVR e reshape em remarks
    rover = D2{1};
    if ~isempty(remarks)
        nR = strfind(remarks,'ROVR');
        try
            nR = nR(end);
            remarks(nR+6:nR+6+length(rover)-1) = rover;
        end
        if remarks(end) ~= char(10);
            remarks = [remarks char(10)];
        end
        L = find(remarks==char(10));
        if isempty(L)
            L = length(remarks);
        end
        L = [0 L];
        for n = 1:length(L)-1;
            remarks2{n,1} = remarks(L(n)+1:L(n+1)-1);
        end
        remarks = remarks2;
    end
    properties.remarks = remarks;
    
    properties.date = [num2str(DADOS(1,1),'%02.0f') '/' num2str(DADOS(1,2),'%02.0f') '/' num2str(DADOS(1,3),'%04.0f')];
    
    str = time2str2(DADOS(1,4),1,0);
    if ~isempty(str), properties.time = str(1:end-3); end
    
    try, pause(.4); delete(h); end
    
catch
    try, delete(h); end
    set(handles.window,'Pointer','arrow');
    beep; uiwait(errordlg('Arquivo com formato incompatível.','Erro','modal')); drawnow;
    Window_ButtonMotionFcn(hObject, eventdata, handles);
    return
end

% Criação de PARAM

PARAM = {'Dia'            ;...
        'Mês'             ;...
        'Ano'             ;...
        'Tempo GPS (s)'   ;...
        'SVs'             ;...
        'PDOP'            ;...
        'Latitude (°)'    ;...
        'Longitude (°)'   ;...
        'Altitude (m)'    ;...
        'RMS Alt (m)'     ;...
        'Flag'            ;...
        'Vel Leste (m/s)' ;...
        'Vel Norte (m/s)' ;...
        'Vel Vert (m/s)'  ;...
        'No. OBS.'        }; % Internamente, PARAM é cell de strings. Ao salvar será char array.

PARAM = SetParamNumbers(PARAM);

NewEvent(handles,['Arquivo importado: ''' fname '''.']);
handles.fpath = fpath;
handles.fname = fname(1:end-4);
guidata(hObject, handles);
StartupWorkData(hObject, eventdata, handles, DADOS, PARAM);
setappdata(handles.window,'properties',properties);
setappdata(handles.window,'change',1);

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function ImportFile_xml_Callback(hObject, eventdata, handles)
% Função para conversao de arquivos AACMI das aeronaves F-5M / A-29
% Formato dos nomes dos arquivos: ACDAT####.xml e ENG_DAT.xml
% Concatena automaticamente todos os arquivos de uma pasta
% Faz uso das funções acdat2mat.m e engdat2mat.m

PreventiveSave(hObject, eventdata, handles);

fpath = uigetdir(handles.fpath,'Indique a pasta dos arquivos AACMI:'); drawnow;

if ~ischar(fpath);
    Window_ButtonMotionFcn(hObject, eventdata, handles);
    return    
else
    fpath = [fpath '\'];
    fpathlist{1} = fpath; 
end

spath = fpath;
iszip = 0;

set(handles.window,'Pointer','watch');

flist = dir(fpath);
flist = sortrows(char(flist.name));
for n = size(flist,1):-1:1;
    if size(flist,2)<12 || ~strcmpi(flist(n,[1:5,9:12]),'acdat.xml')
        flist(n,:) = [];
    end
end
if isempty(flist) && exist([fpath 'Cyclic.zip'],'file')
    try
        pause(.2);
        
        h = waitdlg('Extraindo arquivo ''Cyclic.zip'' ....','Aguarde','modal');
        unzip([fpath 'Cyclic.zip'],tempdir);
                
        if exist([fpath 'Static.zip'],'file')
            
            try, delete(h); end
            pause(.2);
            h = waitdlg('Extraindo arquivo ''Static.zip'' ....','Aguarde','modal');
            unzip([fpath 'Static.zip'],tempdir);
            
        end
        
        if exist([tempdir 'ACDAT001.xml'],'file')
            fpath = tempdir;
        else
            fpath = [tempdir 'mmc-pc\'];
            dirdata = dir(fpath);
            fpath = [fpath dirdata(3).name '\'];
            dirdata = dir(fpath);
            fpath = [fpath dirdata(3).name '\'];
        end
        iszip = 1;
        
        flist = dir(fpath);
        flist = sortrows(char(flist.name));
        for n = size(flist,1):-1:1;
            if ~strcmpi(flist(n,[1:5,9:12]),'acdat.xml')
                flist(n,:) = [];
            end
        end
    catch
        flist = [];
    end
end

try, pause(.4); delete(h); end

if isempty(flist)
    beep; uiwait(errordlg('Não foram encontrados arquivos de dados AACMI.','Erro','modal')); drawnow;
    if iszip, dos(['rmdir "' tempdir 'mmc-pc" /S /Q']); end
    Window_ButtonMotionFcn(hObject, eventdata, handles);
    return
end

[PARAM, UNITS, PARAM2, UNITS2, opt] = RDAT_XMLParamSel;
if isempty(PARAM) && isempty(PARAM2)
    Window_ButtonMotionFcn(hObject, eventdata, handles);
    if iszip, dos(['rmdir "' tempdir 'mmc-pc" /S /Q']); end
    return
end

N = size(flist,1);
DADOS = {};
Fnum  = [];

if ~isempty(PARAM) % ACDAT
    
    t0 = clock;
    h = waitbar(0,['Convertendo arquivo 1 de ' num2str(N) '.  ?:??s restantes.'],...
        'Name','0.0% concluído','Color',get(handles.ZoomIn_btn,'BackgroundColor'),'Pointer','watch','WindowStyle','modal');
    
    for n = 1:N
        try
            [DADOSi, PARAM, UNITS] = acdat2mat([fpath flist(n,:)], PARAM, UNITS);
            fnumi = str2double(flist(n,6:8))*ones(size(DADOSi,1),1);
        catch
            beep; uiwait(errordlg({['Erro ao converter o arquivo ''',flist(n,:),'''.'],'Arquivo ignorado.'},'Erro','modal')); drawnow;
            DADOSi = [];
            fnumi = [];
        end
        DADOS{n,1} = DADOSi;
        Fnum       = [Fnum;  fnumi];
        
        % Calculos para janela de progresso
        if ishandle(h)
            Tel = etime(clock,t0);        % Elapsed time
            Pd = n/N;                     % Percent done
            Trem = round(Tel*(1-Pd)/Pd);  % Remaining time
            mm = fix(Trem/60);
            ss = rem(Trem,60);
            try
                waitbar(Pd,h,['Convertendo arquivo ' num2str(min(N,n+1)) ' de ' num2str(N) '.  ',...
                        num2str(mm) ':' num2str(ss,'%02d') 's restantes.']);
                set(h,'Name',[num2str(100*Pd,'%1.1f') '% concluído'],'Pointer','watch');
            end
        else
            if n < N
                uiwait(warndlg(['Processo interrompido no arquivo ' num2str(n) '/' num2str(N),'.'],'Aviso','modal')); drawnow;
            end
            break
        end
    end
    try, pause(.4); delete(h); end
    
    DADOS = cell2mat(DADOS);
    
    if isempty(DADOS)
        beep; uiwait(errordlg('Não foi possível obter dados.','Erro','modal')); drawnow;
        if iszip, dos(['rmdir "' tempdir 'mmc-pc" /S /Q']); end
        Window_ButtonMotionFcn(hObject, eventdata, handles);
        return
    end
    
else
    DADOS = [];
end

if opt.fnum
    DADOS = [DADOS Fnum];
    PARAM = char(PARAM,'File_number');
    UNITS = char(UNITS,'');
end

if ~isempty(PARAM2) % ENG_DAT
    
    if exist([fpath 'ENG_DAT.xml'])
        
        pause(.1);            
        h = waitbar(0,'Convertendo arquivo ''ENG\_DAT.xml''.',...
            'Name','0.0% concluído','Color',get(handles.ZoomIn_btn,'BackgroundColor'),'Pointer','watch','WindowStyle','modal');
        
        DADOS2 = [];
        try
            [DADOS2,PARAM2,UNITS2] = engdat2mat([fpath 'ENG_DAT.xml'],PARAM2,UNITS2);
        catch
            if ishandle(h), delete(h); end
            beep; uiwait(errordlg({'Erro ao converter o arquivo ''ENG_DAT.xml''.','Formato incompatível.'},'Erro','modal')); drawnow;
        end
        
        if ishandle(h)
            waitbar(1,h);
            set(h,'Name','100.0% concluído');
            pause(1);
            delete(h);
        end
        
        if isempty(DADOS2)
            beep; uiwait(errordlg({'Erro ao converter o arquivo ''ENG_DAT.xml''.','Dados incoerentes.'},'Erro','modal')); drawnow;
        end
    else
        beep; uiwait(errordlg('Arquivo ''ENG_DAT.xml'' não encontrado.','Erro','modal')); drawnow;
        DADOS2 = [];
    end
else
    DADOS2 = [];
end

% Incorporação de dados ACDAT e ENG_DAT
if ~isempty(DADOS) && ~isempty(DADOS2)
    pause(.4);
    if ~strcmp(deblank(PARAM(1,:)),'UTC') || ~strcmp(deblank(PARAM2(1,:)),'UTC')
        beep; uiwait(errordlg({'É necessário selecionar o parâmetro ''UTC'' nas colunas',...
                '''AIRCRAFT'' e ''ENGINE'' para incorporação dos dados de motores.'},'Erro','modal')); drawnow;
    else
        T1 = denan(DADOS(:,1));
        T2 = denan(DADOS2(:,1));
        
        % Ordenar e remover tempos repetidos para interpolação
        [T1c,ord] = sort(T1);
        DADOS = sortrows(DADOS);
        exc = find(~diff(T1c));            
        DADOS(exc,:) = [];
        T1c(exc)     = [];
        ord(exc)     = [];
        
        T2c = sort(T2);
        DADOS2 = sortrows(DADOS2);
        exc = find(~diff(T2c));            
        DADOS2(exc,:) = [];
        T2c(exc)      = [];
        
        % Interpolação
        try
            DADOS = [DADOS interp1(T2c,DADOS2(:,2:end),T1c,'linear',NaN)];
            PARAM = char(PARAM,PARAM2(2:end,:));
            UNITS = char(UNITS,UNITS2(2:end,:));
        catch
            beep; uiwait(errordlg(lasterr,'Erro','modal')); drawnow;
        end
        
        % Retornar à ordem original
        [void,ord] = sort(ord);
        DADOS = DADOS(ord,:); 
    end
    
elseif isempty(DADOS) && ~isempty(DADOS2)
    
    DADOS = DADOS2;
    PARAM = PARAM2;
    UNITS = UNITS2;
end

% Concatenação de PARAM e UNITS
PARAM_UNITS = [];
for n = 1:size(PARAM,1);
    if ~isempty(deblank(UNITS(n,:)))
        PARAM_UNITS = strvcat(PARAM_UNITS,[deblank(PARAM(n,:)),' (',deblank(UNITS(n,:)),')']);
    else
        PARAM_UNITS = strvcat(PARAM_UNITS,deblank(PARAM(n,:)));
    end
end
PARAM = PARAM_UNITS;    
PARAM = cellstr(PARAM);

% Correção de unidades para o A-29
if strcmp(opt.acft,'A29')
    nfuel = findpar(PARAM,'Fuel (lb)',0,1);
    if ~isempty(nfuel)
        PARAM{nfuel} = strrep(PARAM{nfuel},'lb','kg');
    end
end

% Preparação dos dados para HUD & TSD
if opt.play
    
    n = findpar(PARAM,'LAT (SemiCircl)',0,1);
    if ~isempty(n)
        DADOS(:,n) = DADOS(:,n)*180; % SemiCircl -> deg
        PARAM{n} = strrep(PARAM{n},'SemiCircl','deg');
    end
    n = findpar(PARAM,'Long (SemiCircl)',0,1);
    if ~isempty(n)
        DADOS(:,n) = DADOS(:,n)*180; % SemiCircl -> deg
        PARAM{n} = strrep(PARAM{n},'SemiCircl','deg');
    end
    n = findpar(PARAM,'HPT_Rng (ft)',0,1);
    if ~isempty(n)
        DADOS(:,n) = DADOS(:,n)*.3048/1852; % ft -> NM
        PARAM{n} = strrep(PARAM{n},'ft','NM');
    end
    n = findpar(PARAM,'SPT_Rng (ft)',0,1);
    if ~isempty(n)
        DADOS(:,n) = DADOS(:,n)*.3048/1852; % ft -> NM
        PARAM{n} = strrep(PARAM{n},'ft','NM');
    end
    n = findpar(PARAM,'RDR_TGT_Range (ft)',0,1);
    if ~isempty(n)
        DADOS(:,n) = DADOS(:,n)*.3048/1852; % ft -> NM
        PARAM{n} = strrep(PARAM{n},'ft','NM');
    end
    n = findpar(PARAM,'HPT_Elev (deg)',0,1);
    if ~isempty(n)
        DADOS(:,n) = -DADOS(:,n); % Inverter sinal
    end
    n = findpar(PARAM,'RDR_TGT_Elev (deg)',0,1);
    if ~isempty(n)
        DADOS(:,n) = -DADOS(:,n); % Inverter sinal
    end
    n = findpar(PARAM,'Pipper_AZ (mr)',0,1);
    if ~isempty(n)
        DADOS(:,n) = DADOS(:,n)*0.001*180/pi; % mr -> deg
        PARAM{n} = strrep(PARAM{n},'mr','deg');
    end
    n = findpar(PARAM,'Pipper_Elev (mr)',0,1);
    if ~isempty(n)
        DADOS(:,n) = -DADOS(:,n)*0.001*180/pi; % mr -> deg & inverter sinal
        PARAM{n} = strrep(PARAM{n},'mr','deg');
    end
    n = findpar(PARAM,'IR_Seek_AZ (mr)',0,1);
    if ~isempty(n)
        DADOS(:,n) = DADOS(:,n)*0.001*180/pi; % mr -> deg
        PARAM{n} = strrep(PARAM{n},'mr','deg');
    end
    n = findpar(PARAM,'IR_Seek_Elev (mr)',0,1);
    if ~isempty(n)
        DADOS(:,n) = -DADOS(:,n)*0.001*180/pi; % mr -> deg & inverter sinal
        PARAM{n} = strrep(PARAM{n},'mr','deg');
    end
    n1 = findpar(PARAM,'True_AOA (deg)',0,1);
    n2 = findpar(PARAM,'Indi_AOA (deg)',0,1);
    if ~isempty(n1) && ~isempty(n2)
        DADOS(:,n2) = round(.75*(DADOS(:,n1)+8)); % deg -> units
        PARAM{n2} = strrep(PARAM{n2},'deg','units');
    elseif ~isempty(n1) && isempty(n2)
        DADOS(:,end+1) = round(.75*(DADOS(:,n1)+8)); % deg -> units
        PARAM{end+1} = 'Indi_AOA (units)';
    end
    % Criação do parâmetro 'HPT_Gnd_Speed'
    nN = findpar(PARAM,'HPT_North_Vel (kt)',0,1);
    nE = findpar(PARAM,'HPT_East_Vel (kt)',0,1);
    if ~isempty(nN) && ~isempty(nE)
        DADOS(:,end+1) = sqrt(DADOS(:,nN).^2+DADOS(:,nE).^2);
        PARAM{end+1} = 'HPT_Gnd_Speed (kt)';
    end
    % Criação dos parâmetros 'FPM_Azim' e 'FPM_Depr'
    nVN  = findpar(PARAM,'Nor_Vel (kt)'   ,0,1);
    nVE  = findpar(PARAM,'East_Vel (kt)'  ,0,1);
    nVD  = findpar(PARAM,'Down_Vel (kt)'  ,0,1);
    nPSI = findpar(PARAM,'True_Head (deg)',0,1);
    nTET = findpar(PARAM,'Pitch (deg)'    ,0,1);
    nPHI = findpar(PARAM,'Roll (deg)'     ,0,1);
    if length([nVN nVE nVD nPSI nTET nPHI]) == 6
        [FPM_Azim, FPM_Elev] = earth2hud(DADOS(:,nVN),DADOS(:,nVE),DADOS(:,nVD),DADOS(:,nPSI),DADOS(:,nTET),DADOS(:,nPHI));
        DADOS(:,end+1:end+2) = [FPM_Azim -FPM_Elev];
        PARAM{end+1} = 'FPM_Azim (deg)';
        PARAM{end+1} = 'FPM_Depr (deg)';
    end
    % Correção da DLZ ([0 0 0] -> NaN)
    n1 = findpar(PARAM,'DLZ_MAX_Range (NM)',0,1);
    n2 = findpar(PARAM,'DLZ_NO_Esc_Range (NM)',0,1);
    n3 = findpar(PARAM,'DLZ_MIN_Range (NM)',0,1);
    if length([n1 n2 n3]) == 3
        allZero = DADOS(:,n1) == 0 & DADOS(:,n2) == 0 & DADOS(:,n3) == 0;
        DADOS(allZero,n1) = NaN;
        DADOS(allZero,n2) = NaN;
        DADOS(allZero,n2) = NaN;
    end
    % Criação do parâmetro WRB
    if findpar(PARAM,'UTC (sec)',0,1) && exist([fpath 'EVENTS.xml'],'file')
        try
            ev = eventsread([fpath 'EVENTS.xml'],[6 8]);
        catch
            ev = [];
        end
    else
        ev = [];
    end
    if ~isempty(ev)
        T = DADOS(:,1);
        WRB = 0*DADOS(:,1);
        for n = 1:size(ev,1)
            evt = ev{n,2};
            WRB(T>=evt & T<=evt+1) = 1;
        end
        DADOS(:,end+1) = WRB;
        PARAM{end+1} = 'Pickle';
    end
    % Criação do parâmetro Trigger
    if findpar(PARAM,'UTC (sec)',0,1) && exist([fpath 'EVENTS.xml'],'file')
        try
            ev = eventsread([fpath 'EVENTS.xml'],[5 7]);
        catch
            ev = [];
        end
    else
        ev = [];
    end
    if ~isempty(ev)
        trig = [];
        for n = 1:size(ev,1)
            descr = ev{n,3};
            if ~isempty(strfind(descr,'Trigger'))
                c1 = strfind(descr,'Burst')+6;
                c2 = strfind(descr,'Ammo')-3;
                try
                    num = str2double(descr(c1:c2));
                    trig(num,1) = num;
                    if size(trig,2) == 1
                        trig(1,2:3) = 0;
                    end
                    if ~trig(num,2) % Press
                        trig(num,2) = ev{n,2};
                    else           % Release
                        trig(num,3) = ev{n,2};
                    end
                end
            end
        end
        T = DADOS(:,1);
        TRIG = 0*DADOS(:,1);
        for n = 1:size(trig,1)
            if trig(n,1)
                if trig(n,3) == 0
                    trig(n,3) = trig(n,2)+1;
                end
                evt1 = trig(n,2);
                evt2 = trig(n,3);
                TRIG(T>=evt1 & T<=evt2) = 1;
            end
        end
        DADOS(:,end+1) = TRIG;
        PARAM{end+1} = 'Trigger';
    end
    
    % Cadastro dos parâmetros
    setup.params.time  = 'UTC (sec)';
    setup.params.Zp    = 'Corr_Alt (ft)';
    setup.params.Vc    = 'CAS (kt)';
    setup.params.M     = 'MACH';
    setup.params.Zagl  = 'RALT_Alt (ft)';
    setup.params.Zgeo  = 'SYS_Alt (ft)';
    setup.params.lat   = 'LAT (deg)';
    setup.params.lon   = 'Long (deg)';
    setup.params.Nz    = 'Nor_Accel (g)';
    setup.params.psi   = 'Mag_Head (deg)';
    setup.params.Gtrk  = 'Gnd_Track (deg)';
    setup.params.tet   = 'Pitch (deg)';
    setup.params.phi   = 'Roll (deg)';
    setup.params.aoa   = 'True_AOA (deg)';
    setup.params.Wdir  = 'Wind_Dir (deg)';
    setup.params.Wmag  = 'Wind_Mag (kt)';
    setup.params.rpm1  = 'RPM_L (%)';
    setup.params.egt1  = 'EGT_L (°C)';
    setup.params.ff1   = 'Fuel_Flow_L (lb/h)';
    setup.params.fuel1 = 'Fuel (lb)';
    setup.params.rpm2  = 'RPM_R (%)';
    setup.params.egt2  = 'EGT_R (°C)';
    setup.params.ff2   = 'Fuel_Flow_R (lb/h)';
    setup.params.Raz   = 'HPT_Az (deg)';
    setup.params.Rel   = 'HPT_Elev (deg)';
    setup.params.Rrng  = 'HPT_Rng (NM)';
    setup.params.Rclo  = 'HPT_Closure_Rate (kt)';
    setup.params.Rzp   = 'HPT_Altitude (ft)';
    setup.params.Rvc   = 'HPT_Gnd_Speed (kt)';
    setup.params.Rpsi  = 'HPT_Heading (deg)';
    setup.params.Rasp  = 'HPT_Aspect (deg)';
    setup.params.Maz   = 'IR_Seek_AZ (deg)';
    setup.params.Mel   = 'IR_Seek_Elev (deg)';
    setup.params.trk   = 'Cage_STS';
    setup.params.Paz   = 'Pipper_AZ (deg)';
    setup.params.Pel   = 'Pipper_Elev (deg)';
    setup.params.wrb   = 'Pickle';
    setup.params.Saz   = 'FWD_HMD_AZ (deg)';
    setup.params.Sel   = 'FWD_HMD_Elev (deg)';
    setup.params.trig  = 'Trigger';
    setup.params.Rmax1 = 'DLZ_MAX_Range (NM)';
    setup.params.Rmax2 = 'DLZ_NO_Esc_Range (NM)';
    setup.params.Rmin  = 'DLZ_MIN_Range (NM)';

    setup.engmax = [120 1200 6000; 1  1 1000];
    setup.acft   = 'F-5';
    setup.fov    = 10;
    
    paramlist = fields(setup.params);
    for n = 1:length(paramlist)
        if isempty(findpar(PARAM,setup.params.(paramlist{n}),0,1))
            setup.params.(paramlist{n}) = '';
        end
    end
    if ~isempty(findpar(PARAM,'FPM_Depr (deg)',0,1))
        setup.params.aoa = 'FPM_Depr (deg)';
    end
    if ~isempty(findpar(PARAM,'FPM_Azim (deg)',0,1))
        setup.params.aos = 'FPM_Azim (deg)';
    end
    
else
    setup = [];
end

% Carregamento do cenario
if opt.scen
    pause(.4);
    scenario = scenarioread(fpath);
    if ~isempty(scenario)
        if scenario.Dmag == 0
            nthdg = findpar(PARAM,'True_Head (deg)',0,1);
            nmhdg = findpar(PARAM,'Mag_Head (deg)',0,1);
            if ~isempty(nthdg) && ~isempty(nmhdg)
                Dmag = nanmean(mod(DADOS(:,nthdg)-DADOS(:,nmhdg),360));
                if isnan(Dmag),
                    Dmag = 0;
                elseif Dmag > 180
                    Dmag = Dmag - 360;
                end
                Dmag = roundn(Dmag,-2);
            else
                Dmag = '';
            end
            go = 1;
            while go
                Dmag = inputvalue('Definir','Declinação magnética (°):',num2str(Dmag)); drawnow;
                if ~ischar(Dmag) % Cancel
                    scenario = [];
                    go = 0;
                else % Enter
                    if ~isempty(Dmag)
                        Dmag = str2double(Dmag);
                        if ~isnan(Dmag)
                            scenario.Dmag = Dmag;
                            go = 0;
                        else
                            Dmag = '';
                        end
                    end
                end
            end
        end
    else
        uiwait(warndlg({'Não foram encontrados arquivos de cenário válidos.','O cenário tático não será carregado.'},'Aviso','modal')); drawnow;
        scenario = [];
    end
else
    scenario = [];
end

% Carregamento de eventos
if opt.evts
    pause(.4);
    if exist([fpath 'EVENTS.xml'],'file')
        eventtypes    = {'Armament switches', 'Takeoff & landing', 'AA trigger', 'AA launch', 'AG trigger', 'AG release', 'Warnings', 'Fuel warnings', 'Mark, Fix, Acal', 'Stores jettison', 'Chaff/Flare'};
        eventtypesnum = {1, [2 3 4], 5, 6, 7, 8, [9 10], [11 12], [13 14 15], 16, 17};
        types = RDAT_InputOption('Opção', 'Tipos de evento desejados:', eventtypes, 1:17, 180);
        
        if ~isempty(types) && any(types)
            elist = [];
            for n = 1:length(types)
                if types(n)
                    elist = [elist eventtypesnum{n}];
                end
            end
            
            try
                events = eventsread([fpath 'EVENTS.xml'],elist);
            catch
                beep; uiwait(errordlg('Arquivo de enventos com formato incompatível.','Erro','modal')); drawnow;
                events = [];
            end
            if isempty(events)
                beep; uiwait(errordlg('Não foram encontrados eventos no arquivo.','Erro','modal')); drawnow;
                events = [];
            end
        else
            events = [];
        end
    else
        uiwait(warndlg({'Arquivo ''EVENTS.xml'' não encontrado.','Não serão carregados eventos do voo.'},'Aviso','modal')); drawnow;
        events = [];
    end
else
    events = [];
end

if strcmp(PARAM{1},'UTC (sec)')
    reftime = 'UTC (sec)';
    nreftime = 1;
else
    reftime = '';
    nreftime = [];
end

% Análise e correção do Tempo UTC
if ~isempty(nreftime)
    UTC = DADOS(:,nreftime);
    [ok, ndc, nna] = IsTimeOk(UTC);
    if ~ok
        pause(.4);
        button = questdlg({'Parâmetro ''UTC (sec)'' não é adequado:','',...
                [' - Pontos inválidos: ' num2str(length(nna))],...
                [' - Pontos não crescentes: ' num2str(length(ndc))],'',...
                'Deseja que o R_DAT tente corrigi-lo?'},'Aviso','Sim','Não','Sim'); drawnow;
        if strcmp(button,'Sim')
            UTCcorr = UTC_fix(UTC);
            if ~isequal(UTC,UTCcorr)
                DADOS = [UTCcorr DADOS];
                PARAM = PARAM(:);
                PARAM = [{'UTC (sec)'}; PARAM];
                PARAM{2} = 'UTC_uncorrected (sec)';
            end
            [ok, ndc, nna] = IsTimeOk(UTCcorr);
            if ~ok
                uiwait(warndlg({'Parâmetro ''UTC (sec)'' ainda não é adequado:','',...
                        [' - Pontos inválidos: ' num2str(length(nna))],...
                        [' - Pontos não crescentes: ' num2str(length(ndc))],'',...
                        'Os pontos serão selecionados para análise.','Tente corrigi-los manualmente.'},'Aviso','modal')); drawnow;
            else
                uiwait(okdlg({'Parâmetro ''UTC (sec)'' corrigido.','Verifique visualmente as correções.'},'Aviso','modal')); drawnow;
            end
        else
            pause(.4);
            uiwait(warndlg({'Os pontos inadequados serão selecionados para análise.','Tente corrigi-los manualmente.'}','Aviso','modal')); drawnow;
        end
    end
end

% Propriedades
properties = [];
if opt.auxm
    
    if exist([fpath,'GENERAL.xml'],'file')
        try
            properties.mission = char(xmldataread([fpath,'GENERAL.xml'],{{'General','Mission_Name'}},{{'',''}}));
        end
        try
            properties.remarks = char(xmldataread([fpath,'GENERAL.xml'],{{'General','DTC_Name'}},{{'','DTC'}}));
        end
        try
            crew = xmldataread([fpath,'GENERAL.xml'],{{'General','Pilot_1_Name','Pilot_2_Name'}},{{'','',''}});
            if strcmp(crew{2},'-')
                crew(2) = [];
            end
            properties.crew = crew;
        end
        try
            properties.aircraft = [char(xmldataread([fpath,'GENERAL.xml'],{{'General','AC_TYPE'}},{{'',''}})) '-' char(xmldataread([fpath,'GENERAL.xml'],{{'General','AC_Config'}},{{'',''}}))];
        end
    end
    if exist([fpath,'FLT_DAT.xml'],'file')
        try
            dat = char(xmldataread([fpath,'FLT_DAT.xml'],{{'Takeoff','Date'}},{{'',''}}));
            dat(dat=='-') = '/';
            dat = [dat(1:6) '20' dat(7:8)];
            properties.date = dat;
        end
        try
            tkf = char(xmldataread([fpath,'FLT_DAT.xml'],{{'Takeoff','Time'}},{{'',''}}));
            properties.time = tkf(1:5);
        end
        try
            lnd = char(xmldataread([fpath,'FLT_DAT.xml'],{{'Landing','Time'}},{{'',''}}));
            flt = str2time(lnd)-str2time(tkf);
            if flt > 0
                flt = round(flt/60)*60;
                flt = time2str2(flt,1,0);
                properties.flighttime = flt(1:end-3);
            end
        end
        try
            properties.aircraft = char(xmldataread([fpath,'FLT_DAT.xml'],{{'Takeoff','AC_TYPE'}},{{'',''}}));
        end
        try
            properties.tailnumber = char(xmldataread([fpath,'FLT_DAT.xml'],{{'Takeoff','Tail_Num'}},{{'',''}}));
        end
    end
    if exist([fpath,'REAL_INV.xml'],'file')
        try
            properties.inventory = xmldataread([fpath,'REAL_INV.xml']);
        end
    end
end

% Incorporação de outras aeronaves
if opt.play && ~isempty(reftime)
    
    DADOS2 = [];
    PARAM2 = [];

    nother = 2;
    while nother <= 4
        
        DADOSN = [];
        PARAMN = [];
        UNITSN = [];
        
        button = questdlg(['Deseja incorporar dados de uma ' num2str(nother) 'ª aeronave?'],'Opção','Sim','Não','Não'); drawnow;
        if ~strcmp(button,'Sim')
            break
        end
         
        fpathN = uigetdir(handles.fpath,'Indique a pasta dos arquivos AACMI:'); drawnow;
        if ~ischar(fpathN);
            break
        else
            fpathN = [fpathN '\'];
        end
        
        if ~isempty(strmatch(fpathN,fpathlist,'exact'))
            beep; uiwait(errordlg('A pasta indicada já foi importada.','Erro','modal')); drawnow;
            continue
        else
            fpathlist{nother} = fpathN;
        end
        
        set(handles.window,'Pointer','watch');
        
        flist = dir(fpathN);
        flist = sortrows(char(flist.name));
        for n = size(flist,1):-1:1;
            if size(flist,2)<12 || ~strcmpi(flist(n,[1:5,9:12]),'acdat.xml')
                flist(n,:) = [];
            end
        end
        if isempty(flist) && exist([fpathN 'Cyclic.zip'],'file')
            try
                pause(.2);
                
                if iszip, dos(['rmdir "' tempdir 'mmc-pc" /S /Q']); end
                iszip = 0;
                
                h = waitdlg('Extraindo arquivo ''Cyclic.zip'' ....','Aguarde','modal');
                unzip([fpathN 'Cyclic.zip'],tempdir);
                
                if exist([tempdir 'ACDAT001.xml'],'file')
                    fpathN = tempdir;
                else
                    fpathN = [tempdir 'mmc-pc\'];
                    dirdata = dir(fpathN);
                    fpathN = [fpathN dirdata(3).name '\'];
                    dirdata = dir(fpathN);
                    fpathN = [fpathN dirdata(3).name '\'];
                end
                iszip = 1;
                
                flist = dir(fpathN);
                flist = sortrows(char(flist.name));
                for n = size(flist,1):-1:1;
                    if ~strcmpi(flist(n,[1:5,9:12]),'acdat.xml')
                        flist(n,:) = [];
                    end
                end
            catch
                flist = [];
            end
        end
        
        try, pause(.4); delete(h); end
        
        if isempty(flist)
            beep; uiwait(errordlg('Não foram encontrados arquivos de dados AACMI.','Erro','modal')); drawnow;
            fpathlist(nother) = [];
            continue
        end
        
        PARAMN = [...
                'UTC     ';...
                'LAT     ';...
                'Long    ';...
                'Mag_Head';...
                'Corr_Alt'];
        UNITSN = [...
                'sec      ';...
                'SemiCircl';...
                'SemiCircl';...
                'deg      ';...
                'ft       '];
        
        N = size(flist,1);
        DADOSN = {};
        
        t0 = clock;
        h = waitbar(0,['Convertendo arquivo 1 de ' num2str(N) '.  ?:??s restantes.'],...
            'Name','0.0% concluído','Color',get(handles.ZoomIn_btn,'BackgroundColor'),'Pointer','watch','WindowStyle','modal');
        
        for n = 1:N
            try
                [DADOSNi, PARAMN, UNITSN] = acdat2mat([fpathN flist(n,:)], PARAMN, UNITSN);
            catch
                beep; uiwait(errordlg({['Erro ao converter o arquivo ''',flist(n,:),'''.'],'Arquivo ignorado.'},'Erro','modal')); drawnow;
                DADOSNi = [];
            end
            DADOSN{n,1} = DADOSNi;
            
            % Calculos para janela de progresso
            if ishandle(h)
                Tel = etime(clock,t0);        % Elapsed time
                Pd = n/N;                     % Percent done
                Trem = round(Tel*(1-Pd)/Pd);  % Remaining time
                mm = fix(Trem/60);
                ss = rem(Trem,60);
                try
                    waitbar(Pd,h,['Convertendo arquivo ' num2str(min(N,n+1)) ' de ' num2str(N) '.  ',...
                            num2str(mm) ':' num2str(ss,'%02d') 's restantes.']);
                    set(h,'Name',[num2str(100*Pd,'%1.1f') '% concluído'],'Pointer','watch');
                end
            else
                if n < N
                    uiwait(warndlg(['Processo interrompido no arquivo ' num2str(n) '/' num2str(N),'.'],'Aviso','modal')); drawnow;
                end
                break
            end
        end
        try, pause(.4); delete(h); end
        
        DADOSN = cell2mat(DADOSN);
        PARAMN = cellstr(PARAMN);
        UNITSN = cellstr(UNITSN);
        for n = 2:length(PARAMN);
            PARAMN{n,1} = [PARAMN{n} '_' num2str(nother) ' (' UNITSN{n} ')'];
        end
        
        if isempty(DADOSN)
            beep; uiwait(errordlg('Não foi possível obter dados.','Erro','modal')); drawnow;
            fpathlist(nother) = [];
            continue
        end
        
        if ~IsTimeOk(DADOSN(:,1))
            DADOSN(:,1) = UTC_fix(DADOSN(:,1));
        end
        
        % Verificaçao dos parâmetros de tempo
        ok1 = 1 * IsTimeOk(DADOS(:,1));
        ok2 = 2 * IsTimeOk(DADOSN(:,1));
        if ~ok1 || ~ok2
            switch ok1 + ok2
                case 0
                    str = { 'Os parâmetros de tempo contêm pontos inadequados que',...
                            'podem causar erros de sincronismo entre as aeronaves.',...
                            '',...
                            'Deseja prosseguir?'} ;
                case 1
                    str = { ['O parâmetro de tempo da ' num2str(nother) 'ª aeronave contém pontos inadequados'],...
                            'que podem causar erros de sincronismo entre as aeronaves.',...
                            '',...
                            'Deseja prosseguir?'} ;
                case 2
                    str = { 'O parâmetro de tempo da aeronave principal contém pontos inadequados',...
                            'que podem causar erros de sincronismo entre as aeronaves.',...
                            '',...
                            'Deseja prosseguir?'} ;
            end
            button = questdlg(str,'Confirmação','Sim','Não','Não'); drawnow;
            if ~strcmp(button,'Sim')
                fpathlist(nother) = [];
                continue
            end
        end
        
        % Condicionamento dos parâmetros de tempo
        if nother == 2
            T1 = denan(DADOS(:,1));
            [T1c,ord] = sort(T1);
            DADOS = sortrows(DADOS);
            exc = find(~diff(T1c));
            DADOS(exc,:) = [];
            ord(exc)     = [];
        end
        
        TN = denan(DADOSN(:,1));
        TNc = sort(TN);
        DADOSN = sortrows(DADOSN);
        exc = find(~diff(TNc));
        DADOSN(exc,:) = [];
        TNc(exc) = [];
        
        % Interpolação
        try
            DADOS2 = [DADOS2 interp1(TNc,DADOSN(:,2:end),T1c,'linear',NaN)];
            PARAM2 = [PARAM2; PARAMN(2:end)];
            nother = nother + 1;
        catch
            beep; uiwait(errordlg(lasterr,'Erro','modal')); drawnow;
        end
        
    end
    
    if ~isempty(DADOS2)
        
        try
            % Incorporação
            DADOS = [DADOS  DADOS2];
            PARAM = [PARAM; PARAM2];
            
            % Retornar à ordem original
            [void,ord] = sort(ord);
            DADOS = DADOS(ord,:);
            
            PARAM = SetParamFormat(PARAM,handles.maxparamlength);
            
            if opt.play
                
                for nother = 2:4
                    n = findpar(PARAM,['LAT_' num2str(nother) ' (SemiCircl)'],0,1);
                    if ~isempty(n)
                        DADOS(:,n) = DADOS(:,n)*180; % SemiCircl -> deg
                        PARAM{n} = strrep(PARAM{n},'SemiCircl','deg');
                    end
                    n = findpar(PARAM,['Long_' num2str(nother) ' (SemiCircl)'],0,1);
                    if ~isempty(n)
                        DADOS(:,n) = DADOS(:,n)*180; % SemiCircl -> deg
                        PARAM{n} = strrep(PARAM{n},'SemiCircl','deg');
                    end
                end
                
                
                setup.params.lat2  = 'LAT_2 (deg)';
                setup.params.lon2  = 'Long_2 (deg)';
                setup.params.psi2  = 'Mag_Head_2 (deg)';
                setup.params.alt2  = 'Corr_Alt_2 (ft)';
                setup.params.lat3  = 'LAT_3 (deg)';
                setup.params.lon3  = 'Long_3 (deg)';
                setup.params.psi3  = 'Mag_Head_3 (deg)';
                setup.params.alt3  = 'Corr_Alt_3 (ft)';
                setup.params.lat4  = 'LAT_4 (deg)';
                setup.params.lon4  = 'Long_4 (deg)';
                setup.params.psi4  = 'Mag_Head_4 (deg)';
                setup.params.alt4  = 'Corr_Alt_4 (ft)';
                
                paramlist = fields(setup.params);
                for n = 1:length(paramlist)
                    if isempty(findpar(PARAM,setup.params.(paramlist{n}),0,1))
                        setup.params.(paramlist{n}) = '';
                    end
                end
                
            end
        catch
            beep; uiwait(errordlg(lasterr,'Erro','modal')); drawnow;
        end
        
    end
end

% Formatação das matrizes
PARAM = SetParamFormat(PARAM,handles.maxparamlength);
[DADOS, PARAM] = InsertNOBS(DADOS,PARAM);

handles.fpath = spath;
handles.fname = 'ACDAT';
guidata(hObject, handles);

NewEvent(handles,['Arquivos AACMI importados da pasta ''' spath '''.']);
StartupWorkData(hObject, eventdata, handles, DADOS, PARAM);

setappdata(handles.window,'properties',properties);
setappdata(handles.window,'change',1);
setappdata(handles.window,'reftime',reftime);
setappdata(handles.window,'events',events);
setappdata(handles.window,'setup',setup);
setappdata(handles.window,'scenario',scenario);

% Remover parâmetros inteiramente inválidos
pause(.4);
RemoveInvalidParams_Callback(hObject, eventdata, handles, 0);

% Selecionar pontos inválidos de tempo
if ~isempty(reftime) && ~IsTimeOk(DADOS(:,nreftime))
    pause(.4);
    SelectInvalidTime_Callback(hObject, eventdata, handles);
end

if iszip, dos(['rmdir "' tempdir 'mmc-pc" /S /Q']); end
Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function ImportFile_Acra_Callback(hObject, eventdata, handles)
% Função para importação de arquivos do SAD ACRA KAM-500

fname = acra_load;

if isempty(fname) || ~ischar(fname)
    return
end

if ~exist(fname,'file')
    beep; uiwait(errordlg({'Arquivo não encontrado:',fname},'Erro','modal')); drawnow;
    return
end

[fpath, fname, ext] = fileparts(fname);
fpath = [fpath '\'];
fname = [fname ext];

LoadMatFile_Callback(hObject, eventdata, handles, fpath, fname);

% --------------------------------------------------------------------
function ImportFile_CDF_Callback(hObject, eventdata, handles)
% Importa dados de arquivo format CDF - Common Data Format

PreventiveSave(hObject, eventdata, handles);

[fname, fpath] = uigetfile({'*.cdf','Commom Data Format (*.cdf)'},'Indique o arquivo CDF',handles.fpath); drawnow;

if ~ischar(fname)
    Window_ButtonMotionFcn(hObject, eventdata, handles);
    return
end

set(handles.window,'Pointer','watch');

DADOS = cell2mat(cdfread([fpath fname]));
info = cdfinfo([fpath fname]);
PARAM = char(info.VariableAttributes.UNITS(:,1));
UNIT = info.VariableAttributes.UNITS(:,2);
clear info;
PARAM = strcat(PARAM,'(',UNIT,')');
PARAM = SetParamFormat(PARAM,handles.maxparamlength);

NewEvent(handles,['Arquivo importado: ''' fname '''.']);
handles.fpath = fpath;
handles.fname = fname(1:end-4);
guidata(hObject, handles);

StartupWorkData(hObject, eventdata, handles, DADOS, PARAM);
pause(.4);
RemoveInvalidParams_Callback(hObject, eventdata, handles, 0);
setappdata(handles.window,'change',1);

Window_ButtonMotionFcn(hObject, eventdata, handles);





% --------------------------------------------------------------------
function ImportFile_param_Callback(hObject, eventdata, handles)
% Importa lista de nomes de parâmetros de arquivo txt ou xls

oldPARAM = get(handles.xlist,'String');
reftime  = getappdata(handles.window,'reftime');

[fname,fpath,ind] = uigetfile({'*.txt', 'Arquivo de texto (*.txt)'; ...
        '*.xls','Planilha MS Excel (*.xls)'}, 'Indique o arquivo com a lista de nomes de parâmetros',handles.fpath); drawnow;

if ~ischar(fname)
    Window_ButtonMotionFcn(hObject, eventdata, handles);
    return    
end

set(handles.window,'Pointer','watch');

switch ind
    case 1 % txt
        
        try
            [void, PARAM] = txtread([fpath,fname],char(254));
        catch
            beep; uiwait(errordlg('Arquivo com formato incompatível.','Erro','modal')); drawnow;
            Window_ButtonMotionFcn(hObject, eventdata, handles);
            return
        end
        
    case 2 % xls
        try
            [void, PARAM] = xlsread([fpath,fname]);
        catch
            beep; uiwait(errordlg('Arquivo com formato incompatível.','Erro','modal')); drawnow;
            Window_ButtonMotionFcn(hObject, eventdata, handles);
            return
        end
end

if isempty(PARAM)
    beep; uiwait(errordlg('Não foram encontrados nomes de parâmetros no arquivo.','Erro','modal')); drawnow;
    Window_ButtonMotionFcn(hObject, eventdata, handles);
    return
end

[nlin,ncol] = size(PARAM);
for n = 1:nlin
    for m = 1:ncol
        if ~ischar(PARAM{n,m})
            PARAM{n,m} = '';
        end
    end
end

if nlin > 1 || ncol > 1
    if ncol > nlin
        PARAM = PARAM';
    end
    if size(PARAM,2) > 1
        UNITS = char(PARAM(:,2));
    end
    PARAM = char(PARAM(:,1));
end

if exist('UNITS','var')
    PARAM = MergeParamUnits(PARAM,UNITS);
end
PARAM = cellstr(denumber(PARAM));

for n = length(PARAM):-1:1
    if isempty(deblank(PARAM{n}))
        PARAM(n) = [];
    end
end

if ~strcmp(PARAM{end},'No. OBS.')
    PARAM{end+1} = [num2str(length(PARAM)+1,'%02d') '-No. OBS.'];
end

if length(PARAM) ~= length(oldPARAM)
    beep; uiwait(errordlg('Tamanho da matriz PARAM incompatível com matriz DADOS.','Erro','modal')); drawnow;
    Window_ButtonMotionFcn(hObject, eventdata, handles);
    return
end

button = questdlg('Deseja alterar todos os nomes de parâmetros?','Confirmação','Sim','Não','Não'); drawnow;
if strcmp(button,'Sim');
    
    PARAM = SetParamFormat(PARAM,handles.maxparamlength);
    CheckRepParam(PARAM);

    set([handles.xlist handles.ylist],'String',PARAM);
    
    xcol = get(handles.xlist,'Value');
    ycol = get(handles.ylist,'Value');
    
    set(handles.xlabel,'String',denumber(PARAM{xcol}));
    set(handles.ylabel,'String',denumber(PARAM{ycol}));
    
    if ~isempty(reftime)
        nreftime = findpar(oldPARAM,reftime,0,1);
        if ~isempty(nreftime)
            setappdata(handles.window,'reftime',denumber(PARAM{nreftime}));
        end
    end
    UpdateTimeCols(hObject, eventdata, handles);
    
    setappdata(handles.window,'change',1);
    NewEvent(handles,['Lista de nomes de parâmetros importada: ''' fname '''.']);
    
end

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function ConcatFile_Callback(hObject, eventdata, handles)
global DADOS
% Função para contatenar arquivos mat (mesmo PARAM)

PARAM   = get(handles.xlist,'String');
reftime = getappdata(handles.window,'reftime');
nf = 2;

[fname, fpath] = uigetfile({'*.mat','Arquivo mat (*.mat)'},'Carregar 2° arquivo mat para concatenação',handles.fpath); drawnow;

while ischar(fname)
    
    set(handles.window,'Pointer','watch');
    
    if strcmp(get(handles.ShowRuler,'Checked'),'on')
        ShowRuler_Callback(hObject, eventdata, handles);
    end
    
    [DADOS2, PARAM2, err] = LoadMat(fname,fpath,handles.maxparamlength);
    if isa(DADOS2,'single')
        DADOS2 = double(DADOS2);
    end
    
    set(handles.window,'Pointer','arrow');
    
    if isempty(DADOS2) || isempty(PARAM2)
        beep; uiwait(errordlg({['Erro ao carregar o arquivo ''' fname '''.'],err},'Erro','modal')); drawnow;
        Window_ButtonMotionFcn(hObject, eventdata, handles);
        return
    end
    
    PARAM2 = cellstr(PARAM2);
    
    if length(PARAM) ~= length(PARAM2)
        beep; uiwait(errordlg({'O número de parâmetros dos dois arquivos deve ser igual.'},'Erro','modal')); drawnow;
        Window_ButtonMotionFcn(hObject, eventdata, handles);
        return
    end
    
    difpar = find(strcmp(PARAM,PARAM2)==0);
    Nd = length(difpar);
    if ~Nd
        button = 'Sim';
    else
        if Nd == 1
            button = questdlg({'Encontrado um parâmetro com nome diferente:',' ',...
                    [num2str(difpar) ': ''' denumber(PARAM{difpar}) ''' e ''' denumber(PARAM2{difpar}) ''''],...
                    ' ','Deseja prosseguir mantendo o nome do primeiro arquivo?'},'Confirmação','Sim','Não','Não'); drawnow;
        elseif Nd <= 20
            for n = 1:Nd
                str{n} = [num2str(difpar(n)) ': ''' denumber(PARAM{difpar(n)}) ''' e ''' denumber(PARAM2{difpar(n)}) ''''];
            end
            button = questdlg({['Encontrados ' num2str(Nd) ' parâmetros com nomes diferentes:'],' ',char(str),...
                    ' ','Deseja prosseguir mantendo os nomes do primeiro arquivo?'},'Confirmação','Sim','Não','Não'); drawnow;
        else
            button = questdlg({['Encontrados ' num2str(Nd) ' parâmetros com nomes diferentes.'],...
                    ' ','Deseja prosseguir mantendo os nomes do primeiro arquivo?'},'Confirmação','Sim','Não','Não'); drawnow;
        end
    end
    
    if ~strcmp(button,'Sim')
        Window_ButtonMotionFcn(hObject, eventdata, handles);
        return
    end
    
    opt = RDAT_InputOption('Opção','Que tipo de concatenação deseja realizar?',{'Simples (uma matriz sobre a outra)','Usando tempo de referência'},1,280,1); drawnow;
    
    if isempty(opt)
        Window_ButtonMotionFcn(hObject, eventdata, handles);
        return
    end
    
    switch opt
        
        case 1 % Simples
            button = questdlg('Deseja inserir linha de "NaN" entre os dados?','Opção','Sim','Não','Não'); drawnow;
            if strcmp(button,'Sim')
                NaNline = NaN*ones(1,size(DADOS,2));
            else
                NaNline = [];
            end
            
            DADOS = [DADOS; NaNline; DADOS2];
            UpdateGraph(hObject, eventdata, handles, get(handles.xlist,'Value'), get(handles.ylist,'Value'), PARAM);
            set(handles.graphs,'XLim',AutoLim(handles.plot));
            
            setappdata(handles.window,'change',1);
            NewEvent(handles,['Arquivo ''' fname ''' concatenado.']);
            
        case 2 % No tempo
            
            if isempty(handles.fname)
                currentfname = 'Arquivo atual';
            else
                currentfname = handles.fname;
            end
            
            tcol = findpar(PARAM,reftime,0,1);
            if isempty(tcol)
                tcol = 1;
            end
            nt = inputvalue('Concatenação','Tempo de referência:', PARAM, tcol, 1.35); drawnow;
            if ~isempty(nt)
                
                t1 = DADOS(:,nt);
                t2 = DADOS2(:,nt);
                
                ok1 = 1 * IsTimeOk(t1);
                ok2 = 2 * IsTimeOk(t2);
                if ~ok1 || ~ok2
                    switch ok1 + ok2
                        case 0
                            err = { 'Os parâmetros de tempo indicados não são adequados.',...
                                    'Os tempos devem ser monotônicos, crescentes e sem pontos invalidos.'} ;
                        case 1
                            err = {['O parâmetro de tempo do arquivo ''' fname ''' não é adequado.'],...
                                    'O tempo deve ser monotônico, crescente e sem pontos invalidos.'} ;
                        case 2
                            if ~isempty(handles.fname)
                                err = {['O parâmetro de tempo do arquivo ''' handles.fname ''' não é adequado.'],...
                                        'O tempo deve ser monotônico, crescente e sem pontos invalidos.'} ;
                            else
                                err = { 'O parâmetro de tempo do arquivo atual não é adequado.',...
                                        'O tempo deve ser monotônico, crescente e sem pontos invalidos.'} ;
                            end
                    end
                    beep; uiwait(errordlg(err,'Erro','modal')); drawnow;
                    Window_ButtonMotionFcn(hObject, eventdata, handles);
                    return
                end
                
                N = size(DADOS,1);
                T1(1:3:3*N-2) = t1;
                T1(2:3:3*N-1) = t1;
                T1(3:3:3*N)   = NaN;
                
                Y1(1:3:3*N-2) = 0;
                Y1(2:3:3*N-1) = 1;
                Y1(3:3:3*N)   = NaN;
                
                N = size(DADOS2,1);
                T2(1:3:3*N-2) = t2;
                T2(2:3:3*N-1) = t2;
                T2(3:3:3*N)   = NaN;
                
                Y2(1:3:3*N-2) = -1;
                Y2(2:3:3*N-1) =  0;
                Y2(3:3:3*N)   = NaN;
                
                xmin = min([t1; t2]);
                xmax = max([t1; t2]);
                
                set([handles.plot handles.selpts],'Visible','off');
                axes(handles.graph);
                auxH(1) = plot(T1,Y1,'b-');
                auxH(2) = plot(T2,Y2,'r-');
                auxH(3) = text(xmin+.02*(xmax-xmin), .5,strrep(currentfname,'.mat',''),'BackgroundColor','w','Interpreter','none');
                auxH(4) = text(xmin+.02*(xmax-xmin),-.5,strrep(fname,'.mat',''),'BackgroundColor','w','Interpreter','none');
                set(handles.title,'String','Distribuição dos dados no tempo');
                set(handles.xlabel,'String','Tempo de referência');
                set(handles.ylabel,'String','');
                set(handles.graph,'Xlim',[xmin xmax],'Ylim',[-10,10],'YTick',[],'YTickLabel',[]);
                
                button = questdlg({...
                        [currentfname ': ' time2str2(t1(1)) ' a ' time2str2(t1(end)) ' h.'],...
                        [fname        ': ' time2str2(t2(1)) ' a ' time2str2(t2(end)) ' h.'],...
                        ' ','Deseja continuar?'},'Confirmação','Sim','Não','Não'); drawnow;
                
                if strcmp(button,'Sim')
                    
                    if (max(t1) >= min(t2)) && (max(t2) >= min(t1)) % Sobreposição
                        button = questdlg({'Há sobreposição de intervalos.',['Deseja eliminar o intervalo repetido do ' num2str(nf) 'º arquivo?']},...
                            'Opção','Sim','Não','Não'); drawnow;
                        if strcmp(button,'Sim')
                            ovr = intersect(find(t2<=max(t1)), find(t2>=min(t1)));
                            DADOS2(ovr,:) = [];
                        end
                        DADOS = sortrows([DADOS; DADOS2],nt);
                        
                        if any(diff(DADOS(:,nt))==0)
                            button = questdlg({'Encontrados tempos repetidos.','Deseja eliminá-los?'},'Opção',...
                                'Sim','Não','Sim'); drawnow;
                            if strcmp(button,'Sim')
                                DADOS(diff(DADOS(:,nt))==0,:) = [];
                            end
                        end
                        
                    else  % Sem sobreposição
                        button = questdlg('Deseja inserir linha de "NaN" entre os dados?','Opção','Sim','Não','Não'); drawnow;
                        if strcmp(button,'Sim')
                            NaNline = NaN*ones(1,size(DADOS,2));
                            if max(t1) < min(t2)
                                NaNline(nt) = (max(t1)+min(t2))/2;
                            else
                                NaNline(nt) = (min(t1)+max(t2))/2;
                            end
                        else
                            NaNline = [];
                        end
                        if max(t1) < min(t2)
                            DADOS = [DADOS; NaNline; DADOS2];
                        else
                            DADOS = [DADOS2; NaNline; DADOS];
                        end
                    end
                    
                    setappdata(handles.window,'change',1);
                    NewEvent(handles,['Arquivo ''' fname ''' concatenado.']);
                end
                
                delete(auxH);
                set(handles.title,'String','');
                set([handles.plot handles.selpts],'Visible','on');
                UpdateGraph(hObject, eventdata, handles, length(PARAM), nt, PARAM);
                set(handles.graphs,'XLim',AutoLim(handles.plot),'YLimMode','auto','YTickMode','auto','YTickLabelMode','auto');
            end
        
    end
    nf = nf + 1;
    [fname, fpath] = uigetfile({'*.mat','Arquivo mat (*.mat)'},['Carregar ' num2str(nf) '° arquivo mat para concatenação'],handles.fpath); drawnow;
end

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function MergeFile_Callback(hObject, eventdata, handles)
global DADOS DADOS2
% Função para incorporar arquivos mat (PARAM diferentes)

PARAM   = get(handles.xlist,'String');
Npar1   = length(PARAM);
events  = getappdata(handles.window,'events');
reftime = getappdata(handles.window,'reftime');

[fname, fpath] = uigetfile({'*.mat','Arquivo mat (*.mat)'},'Carregar arquivo mat para incorporação',handles.fpath); drawnow;

if ~ischar(fname)
    Window_ButtonMotionFcn(hObject, eventdata, handles);
    return    
end

set(handles.window,'Pointer','watch');

if strcmp(get(handles.ShowRuler,'Checked'),'on')
    ShowRuler_Callback(hObject, eventdata, handles);
end

[DADOS2, PARAM2, err] = LoadMat(fname,fpath,handles.maxparamlength);
if isa(DADOS2,'single')
    DADOS2 = double(DADOS2);
end

fileinfo = whos('-file',[fpath fname]);
if strmatch('events',{fileinfo.name},'exact');
    D = load([fpath fname],'events');
    events2 = D.events;
else
    events2 = [];
end
if strmatch('reftime',{fileinfo.name},'exact');
    D = load([fpath fname],'reftime');
    reftime2 = D.reftime;
else
    reftime2 = [];
end

if isempty(DADOS2) || isempty(PARAM2)
    beep; uiwait(errordlg({['Erro ao carregar o arquivo ''' fname '''.'],err},'Erro','modal')); drawnow;
    Window_ButtonMotionFcn(hObject, eventdata, handles);
    return
end

if isempty(handles.fname)
    currentfname = 'Arquivo atual';
else
    currentfname = handles.fname;
end

[nt1, nt2, offset, method, parlist] = RDAT_MergeSync(PARAM,PARAM2,reftime,reftime2,events,events2); drawnow;

if isempty(nt1)
    Window_ButtonMotionFcn(hObject, eventdata, handles);
    return
end

DADOS2 = DADOS2(:,parlist);
PARAM2 = PARAM2(parlist);

t1 = DADOS(:,nt1);
t2 = DADOS2(:,nt2)-offset;

ok1 = 1 * IsTimeOk(t1);
ok2 = 2 * IsTimeOk(t2);
if ~ok1 || ~ok2
    switch ok1 + ok2
        case 0
            err = { 'Os parâmetros de tempo indicados não são adequados.',...
                    'Os tempos devem ser monotônicos, crescentes e sem pontos invalidos.'} ;
        case 1
            err = {['O parâmetro de tempo do arquivo ''' fname ''' não é adequado.'],...
                    'O tempo deve ser monotônico, crescente e sem pontos invalidos.'} ;
        case 2
            if ~isempty(handles.fname)
                err = {['O parâmetro de tempo do arquivo ''' handles.fname ''' não é adequado.'],...
                        'O tempo deve ser monotônico, crescente e sem pontos invalidos.'} ;
            else
                err = { 'O parâmetro de tempo do arquivo atual não é adequado.',...
                        'O tempo deve ser monotônico, crescente e sem pontos invalidos.'} ;
            end
    end
    beep; uiwait(errordlg(err,'Erro','modal')); drawnow;
    Window_ButtonMotionFcn(hObject, eventdata, handles);
    return
end

[sel1, ok, sel2] = listdlg2('Name','Incorporação','HeaderString',{'Indique os parâmetros com escala cíclica que contenham descontinuidades, como proa,','inclinação lateral, atitude, direção, radial etc.:'},...
    'PromptString','Intervalo de 0 a 360°','PromptString2','Intervalo de -180 a 180°','SelectionMode','multiple','ListString',PARAM2(1:end-1),'ListString2',PARAM2(1:end-1),...
    'OKString','OK','CancelString','Cancela','SelectAllString','Selecionar tudo','SelectNoneString','Limpar','ListSize',[200 305]); drawnow;
pause(.2);
sel3 = listdlg2('Name','Incorporação','HeaderString',{'Indique os parâmetros lógicos ou inteiros,','como estado de botões, gatilho, modo de','operação, TOP, hora, minuto etc.:'},...
    'SelectionMode','multiple','ListString',PARAM2(1:end-1),'OKString','OK','CancelString','Cancela','SelectAllString','Selecionar tudo','SelectNoneString','Limpar','ListSize',[200 305]); drawnow;

for n = 1:length(sel1) % [0 360°] -> continuo
    DADOS2(:,sel1(n)) = unwrap2(DADOS2(:,sel1(n)));
end
for n = 1:length(sel2) % [±180°] -> continuo
    DADOS2(:,sel2(n)) = unwrap2(DADOS2(:,sel2(n)));
end
if ~isempty(sel3);
    DADOS2int = DADOS2(:,sel3);
end

set(handles.window,'Pointer','watch');

sel1 = setdiff(sel1,nt2);
sel2 = setdiff(sel2,nt2);
sel3 = setdiff(sel3,nt2);

N = size(DADOS,1);
T1(1:3:3*N-2) = t1;
T1(2:3:3*N-1) = t1;
T1(3:3:3*N)   = NaN;

Y1(1:3:3*N-2) = 0;
Y1(2:3:3*N-1) = 1;
Y1(3:3:3*N)   = NaN;

N = size(DADOS2,1);
T2(1:3:3*N-2) = t2;
T2(2:3:3*N-1) = t2;
T2(3:3:3*N)   = NaN;

Y2(1:3:3*N-2) = -1;
Y2(2:3:3*N-1) =  0;
Y2(3:3:3*N)   = NaN;

xmin = min([t1; t2]);
xmax = max([t1; t2]);

set([handles.plot handles.selpts],'Visible','off');
axes(handles.graph);
auxH(1) = plot(T1,Y1,'b-');
auxH(2) = plot(T2,Y2,'r-');
auxH(3) = text(xmin+.02*(xmax-xmin), .5,strrep(currentfname,'.mat',''),'BackgroundColor','w','Interpreter','none');
auxH(4) = text(xmin+.02*(xmax-xmin),-.5,strrep(fname,'.mat',''),'BackgroundColor','w','Interpreter','none');
set(handles.title,'String','Distribuição dos dados no tempo');
set(handles.xlabel,'String','Tempo de sincronismo');
set(handles.ylabel,'String','');
set(handles.graph,'Xlim',[xmin xmax],'Ylim',[-10,10],'YTick',[],'YTickLabel',[]);

if offset ~= 0
    button = questdlg({...
            [currentfname ': ' time2str2(t1(1))        ' a ' time2str2(t1(end))        ' h.'],...
            [fname        ' original:   ' time2str2(t2(1)+offset) ' a ' time2str2(t2(end)+offset) ' h.'],...
            [fname        ' corrigido: '  time2str2(t2(1))        ' a ' time2str2(t2(end))        ' h.'],...
            ['Offset: ' time2str2(offset) ' h.'],' ','Deseja continuar?'},'Confirmação','Sim','Não','Não'); drawnow;
else
    button = questdlg({...
            [currentfname ': ' time2str2(t1(1)) ' a ' time2str2(t1(end)) ' h.'],...
            [fname        ': ' time2str2(t2(1)) ' a ' time2str2(t2(end)) ' h.'],...
            ' ','Deseja continuar?'},'Confirmação','Sim','Não','Não'); drawnow;
end

if strcmp(button,'Sim')
    
    DADOS(:,end)  = [];
    DADOS2(:,end) = [];
    if offset == 0
        DADOS2(:,nt2) = [];
        sel1(sel1>nt2) = sel1(sel1>nt2) - 1;
        sel2(sel2>nt2) = sel2(sel2>nt2) - 1;
        sel3(sel3>nt2) = sel3(sel3>nt2) - 1;
    end
    sel1 = sel1 + size(DADOS,2);
    sel2 = sel2 + size(DADOS,2);
    sel3 = sel3 + size(DADOS,2);
    
    if ~( min(t1) <= min(t2) && max(t1) >= max(t2) )
        opt = RDAT_InputOption('Opção',{'Parte do 2º arquivo está fora do intervalo de tempo',...
            'do arquivo principal. O que deseja fazer?'},...
            {'Manter apenas o intervalo principal','Considerar os dois intervalos'},1,280,1); drawnow;
        
        if isempty(opt)
            DADOS(:,end+1) = (1:size(DADOS,1))';
            delete(auxH);
            set(handles.title,'String','');
            set(handles.plot,'Visible','on');
            UpdatePlot(hObject, eventdata, handles);
            set(handles.graphs,'XLim',AutoLim(handles.plot),'YLimMode','auto','YTickMode','auto','YTickLabelMode','auto');
            Window_ButtonMotionFcn(hObject, eventdata, handles);
            return
        end
        
        set(handles.window,'Pointer','watch');
        h = waitdlg('Interpolando dados ...','Aguarde','modal');
        
        switch opt
            case 1 % Apenas o principal
                tref = t1;
                DADOS2 = interp1(t2,DADOS2,tref,method,NaN);
                DADOS = [DADOS DADOS2 (1:size(DADOS,1))'];
                
            case 2 % Considerar os dois
                nexc = intersect(find(t2<=max(t1)),find(t2>=min(t1)));
                ninc = setdiff(1:length(t2),nexc);
                tref = sort([t1; t2(ninc)]);
                
                DADOS  = interp1(t1,DADOS, tref,method,NaN);
                DADOS2 = interp1(t2,DADOS2,tref,method,NaN);
                DADOS(:,nt1) = tref;
                DADOS = [DADOS DADOS2 (1:size(DADOS,1))'];
                
        end
    else
        
        set(handles.window,'Pointer','watch');
        h = waitdlg('Interpolando dados ...','Aguarde','modal');
        
        tref = t1;
        DADOS2 = interp1(t2,DADOS2,tref,method,NaN);
        DADOS = [DADOS DADOS2 (1:size(DADOS,1))'];
    end
    
    for n = 1:length(sel1) % continuo -> [0 360°]
        DADOS(:,sel1(n)) = mod(DADOS(:,sel1(n)),360);
    end
    for n = 1:length(sel2) % continuo -> [±180°]
        DADOS(:,sel2(n)) = mod(DADOS(:,sel2(n)),360);
        neg = find(DADOS(:,sel2(n)) > 180);
        DADOS(neg,sel2(n)) = DADOS(neg,sel2(n)) - 360;
    end
    for n = 1:length(sel3), DADOS(:,sel3(n)) = interp1(t2,DADOS2int(:,n),tref,'nearest'); end
    
    try, delete(h); end
    clear global DADOS2
    
    PARAM(end) = [];
    if offset == 0
        PARAM2(nt2) = [];
    end
    
    Nrep = 0;
    for n = 1:length(PARAM2)
        if ~isempty(findpar(PARAM,PARAM2{n},0,1))
            Nrep = Nrep + 1;
        end
    end
    if Nrep == 1
        uiwait(warndlg({'ATENÇÃO!','','Encontrado um parâmetro com nome igual nos dois arquivos.'},'Aviso','modal')); drawnow;
    elseif Nrep > 1
        uiwait(warndlg({'ATENÇÃO!','',['Encontrados ' num2str(Nrep) ' parâmetros com nomes iguais nos dois arquivos.']},'Aviso','modal')); drawnow;
    end
    
    PARAM = [PARAM; PARAM2];
    PARAM = SetParamFormat(PARAM,handles.maxparamlength);
    
    setappdata(handles.window,'change',1);
    NewEvent(handles,['Arquivo ''' fname ''' incoporado.']); 
end

delete(auxH);
set(handles.title,'String','');
set([handles.plot handles.selpts],'Visible','on');
UpdateGraph(hObject, eventdata, handles, length(PARAM), nt1, PARAM);
set(handles.graphs,'XLim',AutoLim(handles.plot),'YLimMode','auto','YTickMode','auto','YTickLabelMode','auto');

FixTOPs(hObject, eventdata, handles, Npar1);

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function SaveMatFile_Callback(hObject, eventdata, handles, noconf)
global DADOS
% Função para salvar o arquivo mat em uso

issingle = getappdata(handles.window,'issingle');

if nargin ~= 4
    noconf = 0;
end

if ~exist([handles.fpath handles.fname],'file') || ~ismat(handles.fname)
    SaveMatFileAs_Callback(hObject, eventdata, handles);
    Window_ButtonMotionFcn(hObject, eventdata, handles);
    return
end

if noconf
    button = 'Sim';
else
    button = savedlg({'Deseja salvar o arquivo atual',[handles.fpath handles.fname '?']},'Confirmação','Sim','Não','Não'); drawnow;
end

if ~strcmp(button,'Sim')
    Window_ButtonMotionFcn(hObject, eventdata, handles);
    return
end

set(handles.window,'Pointer','watch');

if strcmpi(handles.fname(end-2:end),'zip')
    iszip = 1;
    fpath = tempdir;
    fname = [handles.fname(1:end-3) 'mat'];
else
    iszip = 0;
    fpath = handles.fpath;
    fname = handles.fname;
end

if issingle
    DADOS = single(DADOS);
end

PARAM = char(get(handles.xlist,'String'));  % PARAM convertido novamente para char array
try
    save([fpath fname],'DADOS','PARAM',saveopt);
    if issingle
        DADOS = double(DADOS);
    end
catch
    beep; uiwait(errordlg(lasterr,'Erro','modal')); drawnow;
    Window_ButtonMotionFcn(hObject, eventdata, handles);
    return
end

% Variaveis secundarias
events   = getappdata(handles.window,'events');
testpts  = getappdata(handles.window,'testpts');
reftime  = getappdata(handles.window,'reftime');
setup    = getappdata(handles.window,'setup');
scenario = getappdata(handles.window,'scenario');
properties = getappdata(handles.window,'properties');

if ~isempty(events)
    save([fpath fname],'events','-append',saveopt);
end
if ~isempty(testpts)
    save([fpath fname],'testpts','-append',saveopt);
end
if ~isempty(reftime)
    save([fpath fname],'reftime','-append',saveopt);
end
if ~isempty(setup)
    save([fpath fname],'setup','-append',saveopt);
end
if ~isempty(scenario)
    save([fpath fname],'scenario','-append',saveopt);
end
if ~isempty(properties)
    save([fpath fname],'properties','-append',saveopt);
end

if iszip
    try
        h = waitdlg(['Compactando arquivo ''' fname ''' ...'],'Aguarde','modal');
        zip([handles.fpath handles.fname],[fpath fname]);
        try, delete(h); end
    catch
        beep; uiwait(errordlg(lasterr,'Erro','modal')); drawnow;
        dos(['del "' fpath fname '"']);
        Window_ButtonMotionFcn(hObject, eventdata, handles);
        return
    end
    dos(['del "' fpath fname '"']);
end

setappdata(handles.window,'change',0);
NewEvent(handles,['Arquivo salvo: ''' handles.fname '''.']);

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function SaveMatFileAs_Callback(hObject, eventdata, handles)
global DADOS
% Função para salvar o arquivo mat em uso com outro nome

[fname, fpath, opt] = uiputfile({...
        '*.mat','Arquivo mat (*.mat)';...
        '*.mat','Arquivo mat de precisão simples (*.mat)';...
        '*.zip','Arquivo mat compactado (*.zip)'},'Salvar arquivo de dados',[handles.fpath handles.fname]); drawnow;

if ~ischar(fname)
    Window_ButtonMotionFcn(hObject, eventdata, handles);
    return
end

set(handles.window,'Pointer','watch');

if opt == 2
    button = questdlg({'Deseja salvar o arquivo atual com precisão simples (32 bits)?',...
            'A resolução dos dados será reduzida.'},'Confirmação','Sim','Não','Não'); drawnow;
    if ~strcmp(button,'Sim')
        return
    end
    DADOS = single(DADOS);
    issingle = 1;
else
    issingle = 0;
end

if opt == 3 % zip
    fname = SetFileExtension(fname,'zip');
    iszip = 1;
    zpath = fpath;
    zname = fname;
    fpath = tempdir;
    fname = [fname(1:end-3) 'mat'];
else
    iszip = 0;
end

fname = SetFileExtension(fname,'mat');
PARAM = char(get(handles.xlist,'String'));  % PARAM convertido novamente para char array

try
    save([fpath fname],'DADOS','PARAM',saveopt);
    if issingle
        DADOS = double(DADOS);
    end
catch
    beep; uiwait(errordlg(lasterr,'Erro','modal')); drawnow;
    return
end

% Variaveis secundarias
events   = getappdata(handles.window,'events');
testpts  = getappdata(handles.window,'testpts');
reftime  = getappdata(handles.window,'reftime');
setup    = getappdata(handles.window,'setup');
scenario = getappdata(handles.window,'scenario');
properties = getappdata(handles.window,'properties');

if ~isempty(events)
    save([fpath fname],'events','-append',saveopt);
end
if ~isempty(testpts)
    save([fpath fname],'testpts','-append',saveopt);
end
if ~isempty(reftime)
    save([fpath fname],'reftime','-append',saveopt);
end
if ~isempty(setup)
    save([fpath fname],'setup','-append',saveopt);
end
if ~isempty(scenario)
    save([fpath fname],'scenario','-append',saveopt);
end
if ~isempty(properties)
    save([fpath fname],'properties','-append',saveopt);
end

if iszip
    try
        h = waitdlg(['Compactando arquivo ''' fname ''' ...'],'Aguarde','modal');
        zip([zpath zname],[fpath fname]);
        try, delete(h); end
    catch
        beep; uiwait(errordlg(lasterr,'Erro','modal')); drawnow;
        dos(['del "' fpath fname '"']);
        Window_ButtonMotionFcn(hObject, eventdata, handles);
        return
    end
    dos(['del "' fpath fname '"']);
end

if iszip
    handles.fpath = zpath;
    handles.fname = zname;
else
    handles.fpath = fpath;
    handles.fname = fname;
end
guidata(hObject, handles);

setappdata(handles.window,'issingle',issingle);
set(handles.window,'Name',[handles.vername,' [', handles.fname,']']);
setappdata(handles.window,'change',0);
NewEvent(handles,['Arquivo salvo como ''' handles.fname '''.']);
UpdateRecents(hObject, eventdata, handles, handles.fpath, handles.fname);

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function SaveSliceAs_Callback(hObject, eventdata, handles)
global DADOS
% Função para salvar o intervalo selecionado como arquivo mat

pts = GetIntervPts(handles);
if isempty(pts)
    beep; uiwait(errordlg('Não há pontos no intervalo selecionado.','Erro','modal')); drawnow;
    return
end

[fname, fpath] = uiputfile({'*.mat','Arquivo mat (*.mat)'},'Salvar intervalo selecionado',handles.fpath); drawnow;

if ~ischar(fname)
    Window_ButtonMotionFcn(hObject, eventdata, handles);
    return
end

set(handles.window,'Pointer','watch');

fname = SetFileExtension(fname,'mat');
PARAM = char(get(handles.xlist,'String')); % PARAM convertido novamente para char array

try
    AuxSaveSlice([fpath fname],[DADOS(pts,1:end-1) (1:length(pts))'], PARAM);
catch
    beep; uiwait(errordlg(lasterr,'Erro','modal')); drawnow;
    return
end

properties = getappdata(handles.window,'properties');

if ~isempty(properties)
    save([fpath fname],'properties','-append',saveopt);
end

NewEvent(handles,['Intervalo salvo como ''' fname '''.']);

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function SaveSelectionAs_Callback(hObject, eventdata, handles)
global DADOS
% Função para salvar os pontos selecionados como arquivo mat

sel = getappdata(handles.window,'sel');
if isempty(sel)
    beep; uiwait(errordlg('Não há pontos selecionados.','Erro','modal')); drawnow;
    return
end

[fname, fpath] = uiputfile({'*.mat','Arquivo mat (*.mat)'},'Salvar seleção',handles.fpath); drawnow;

if ~ischar(fname)
    Window_ButtonMotionFcn(hObject, eventdata, handles);
    return
end

set(handles.window,'Pointer','watch');

fname = SetFileExtension(fname,'mat');
PARAM = char(get(handles.xlist,'String')); % PARAM convertido novamente para char array

try
    AuxSaveSlice([fpath fname],[DADOS(sel,1:end-1) (1:length(sel))'], PARAM);
catch
    beep; uiwait(errordlg(lasterr,'Erro','modal')); drawnow;
    return
end

properties = getappdata(handles.window,'properties');

if ~isempty(properties)
    save([fpath fname],'properties','-append',saveopt);
end

NewEvent(handles,['Seleção salva como ''' fname '''.']);

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function SaveTestPtsAs_Callback(hObject, eventdata, handles)
global DADOS
% Função para salvar os trechos definidos como pontos de ensaio em arquivos mat

PARAM   = get(handles.xlist,'String');
testpts = getappdata(handles.window,'testpts');
reftime = getappdata(handles.window,'reftime');

if ~isfield(testpts,'number') || isempty([testpts.number])
    beep; uiwait(errordlg('Não há pontos de ensaio definidos.','Erro','modal')); drawnow;
    return
end

if isempty(reftime)
    beep; uiwait(errordlg('O tempo de referência não está definido.','Erro','modal')); drawnow;
    return
end

tcol = findpar(PARAM,reftime,0,1);
if isempty(tcol)
    beep; uiwait(errordlg(['O tempo de referência ''' reftime ''' não foi encontrado.'],'Erro','modal')); drawnow;
    return
end

Ngrp = size(testpts,2);

ptslist{1} = 'Todos os pontos de ensaio';
ptsindx(1) = 0;
for n = 1:Ngrp
    ptslist{length(ptslist)+1} = [' -Grupo ' testpts(n).group];
    ptsindx(length(ptsindx)+1) = n;
    for m = 1:length(testpts(n).number)
        ptslist{length(ptslist)+1} = ['    Ponto ' testpts(n).number{m} ' - ' testpts(n).descr{m}];
        ptsindx(length(ptsindx)+1) = n + m*i;
    end
end

opt = inputvalue('Opção','Indique o(s) ponto(s) de ensaio que deseja salvar:',ptslist,1,2);

if isempty(opt)
    return
else
    ind = ptsindx(opt);
end

if ind == 0 % Todos
    testptslist.time  = [testpts.time];
    testptslist.descr = [testpts.descr];
    opt = RDAT_InputOption('Opção','Como deseja salvar os pontos?',{'Todos os pontos em um único arquivo','Cada ponto em um arquivo separado'},1,260,1); drawnow;
    if isempty(opt)
        return
    elseif opt == 1
        dfname = '';
    else
        for n = 1:length(testptslist.descr)
            dfname{n} = [testptslist.descr{n} '.mat'];
        end
    end
elseif imag(ind) == 0  % Grupo
    testptslist.time = testpts(ind).time;
    opt = RDAT_InputOption('Opção','Como deseja salvar o grupo?',{'Todos os pontos em um único arquivo','Cada ponto em um arquivo separado'},1,260,1); drawnow;
    if isempty(opt)
        return
    elseif opt == 1
        dfname = ['Grupo ' testpts(ind).group '.mat'];
    else
        for n = 1:length(testpts(ind).descr)
            dfname{n} = [testpts(ind).descr{n} '.mat'];
        end
    end
else % Ponto
    testptslist.time = testpts(real(ind)).time(:,imag(ind));
    dfname = [testpts(real(ind)).descr{imag(ind)} '.mat'];
end

if isempty(testptslist.time)
    beep; uiwait(errordlg(['Não há pontos de ensaio definidos no grupo ''' testpts(ind).group '''.'],'Erro','modal')); drawnow;
    return
end

if ischar(dfname)
    
    T = DADOS(:,tcol);
    
    pts = [];
    for n = 1:size(testptslist.time,2)
        if ~isnan(testptslist.time(2,n)-testptslist.time(1,n))
            pts = [pts; GetIntervPts(T,testptslist.time(1,n),testptslist.time(2,n))];
        end
    end
    
    pts = unique(pts);
    
    if isempty(pts)
        beep; uiwait(errordlg('Intervalo(s) do(s) ponto(s) de ensaio não definido(s) ou sem dados.','Erro','modal')); drawnow;
        return
    end
    
    [fname, fpath] = uiputfile({'*.mat','Arquivo mat (*.mat)'},'Salvar trecho(s) de ponto(s) de ensaio',[handles.fpath dfname]); drawnow;
    if ischar(fname)
        
        set(handles.window,'Pointer','watch');
        
        D = DADOS(pts,:);
        
        D(:,end) = (1:size(D,1))';
        
        fname = SetFileExtension(fname,'mat');
        PARAM = char(get(handles.xlist,'String')); % PARAM convertido novamente para char array
        
        try
            AuxSaveSlice([fpath fname], D, PARAM);
        catch
            beep; uiwait(errordlg(lasterr,'Erro','modal')); drawnow;
            return
        end
        
        save([fpath fname],'reftime','-append',saveopt);
        save([fpath fname],'testpts','-append',saveopt);
        
        events   = getappdata(handles.window,'events');
        setup    = getappdata(handles.window,'setup');
        scenario = getappdata(handles.window,'scenario');
        properties = getappdata(handles.window,'properties');
        
        if ~isempty(events)
            save([fpath fname],'events','-append',saveopt);
        end
        if ~isempty(setup)
            save([fpath fname],'setup','-append',saveopt);
        end
        if ~isempty(scenario)
            save([fpath fname],'scenario','-append',saveopt);
        end
        if ~isempty(properties)
            save([fpath fname],'properties','-append',saveopt);
        end
        
        while ptslist{opt}(1) == ' '
            ptslist{opt}(1) = [];
        end
        if ptslist{opt}(1) == '-'
            ptslist{opt}(1) = [];
        end
        
        if ind == 0
            str = ['Trechos de todos os pontos de ensaio salvos como ''' fname '''.'];
        elseif imag(ind) == 0
            str = ['Trechos dos pontos de ensaio do ' ptslist{opt} ' salvos como ''' fname '''.'];
        else
            str = ['Trecho do ' ptslist{opt} ' salvo como ''' fname '''.'];
        end
        NewEvent(handles,str);
        
    end
    
elseif iscell(dfname)
    
    PARAM    = char(get(handles.xlist,'String'));
    events   = getappdata(handles.window,'events');
    setup    = getappdata(handles.window,'setup');
    scenario = getappdata(handles.window,'scenario');
    properties = getappdata(handles.window,'properties');
    
    T = DADOS(:,tcol);
    Npt = length(dfname);
    fpath = handles.fpath;
    
    for npt = 1:Npt
        
        if isnan(testptslist.time(2,npt)-testptslist.time(1,npt))
            beep; uiwait(errordlg(['Intervalo do ponto de ensaio ''' dfname{npt}(1:end-4) ''' não definido.'],'Erro','modal')); drawnow;
            continue
        end
        
        pts = GetIntervPts(T,testptslist.time(1,npt),testptslist.time(2,npt));
        
        if isempty(pts)
            beep; uiwait(errordlg(['Intervalo do ponto de ensaio ''' dfname{npt}(1:end-4) ''' não contém dados.'],'Erro','modal')); drawnow;
            continue
        end
        
        [fname, fpath] = uiputfile({'*.mat','Arquivo mat (*.mat)'},['Salvar trecho de ponto de ensaio (' num2str(npt) '/' num2str(Npt) ')'],...
            [fpath dfname{npt}]); drawnow;
        if ischar(fname)
            
            set(handles.window,'Pointer','watch');
            
            D = DADOS(pts,:);
            
            D(:,end) = (1:size(D,1))';
            
            fname = SetFileExtension(fname,'mat');
            
            try
                AuxSaveSlice([fpath fname],D, PARAM);
            catch
                beep; uiwait(errordlg(lasterr,'Erro','modal')); drawnow;
                continue
            end
            
            save([fpath fname],'reftime','-append',saveopt);
            save([fpath fname],'testpts','-append',saveopt);
            
            if ~isempty(events)
                save([fpath fname],'events','-append',saveopt);
            end
            if ~isempty(setup)
                save([fpath fname],'setup','-append',saveopt);
            end
            if ~isempty(scenario)
                save([fpath fname],'scenario','-append',saveopt);
            end
            if ~isempty(properties)
                save([fpath fname],'properties','-append',saveopt);
            end
            
            NewEvent(handles,['Trecho do ponto de ensaio ' dfname{npt}(1:end-4) ' salvo como ''' fname '''.']);
            
        end
    end
    
end

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function ExportFile_xls_Callback(hObject, eventdata, handles)
global DADOS
% Função para exportar os dados para planilha Excel

if size(DADOS,1)+2 > 65536
    beep; uiwait(errordlg({'Tamanho da matriz DADOS incompatível.','Planilha Excel limitada a 65.536 linhas.'},'Erro','modal')); drawnow;
    return
elseif size(DADOS,2) > 256
    beep; uiwait(errordlg({'Número de parâmetros incompatível.','Planilha Excel limitada a 256 colunas.'},'Erro','modal')); drawnow;
    return
end

ExportData_xls(hObject, eventdata, handles, DADOS(:,end));

% --------------------------------------------------------------------
function ExportFile_txt_Callback(hObject, eventdata, handles)
global DADOS
% Função para exportar os dados para o Notepad

N = numel(DADOS);

if N > 500000
    button = questdlg({'ATENÇÃO!',' ','A matriz DADOS é muito grande para ser convertida em texto.',...
            'O processo pode demorar vários minutos e consumir todos','os recursos do computador.',...
            'Não é recomendado prosseguir!',' ','Deseja prosseguir?'},'Confirmação','Sim','Não','Não'); drawnow;
elseif N > 100000
    button = questdlg({'A matriz DADOS é muito grande para ser convertida em texto.',...
            'O processo pode demorar vários minutos.',' ','Deseja prosseguir?'},'Confirmação','Sim','Não','Não'); drawnow;
else
    button = 'Sim';
end

if strcmp(button,'Sim')
    ExportData_txt(hObject, eventdata, handles, DADOS(:,end));
end

% --------------------------------------------------------------------
function ExportSlice_xls_Callback(hObject, eventdata, handles)
global DADOS
% Função para exportar intervalo selecionado para planilha Excel

pts = GetIntervPts(handles);

if length(pts)+2 > 65536
    beep; uiwait(errordlg({'Tamanho do intervalo incompatível.','Planilha Excel limitada a 65.536 linhas.'},'Erro','modal')); drawnow;
    return
elseif size(DADOS,2) > 256
    beep; uiwait(errordlg({'Número de parâmetros incompatível.','Planilha Excel limitada a 256 colunas.'},'Erro','modal')); drawnow;
    return
elseif isempty(pts)
    beep; uiwait(errordlg('Não há pontos no intervalo selecionado.','Erro','modal')); drawnow;
    return
end

ExportData_xls(hObject, eventdata, handles, pts);

% --------------------------------------------------------------------
function ExportSlice_txt_Callback(hObject, eventdata, handles)
global DADOS
% Função para exportar intervalo selecionado para o Notepad

pts = GetIntervPts(handles);

N = length(pts)*size(DADOS,2);

if N > 500000
    button = questdlg({'ATENÇÃO!',' ','O intervalo selecionado é muito grande para ser convertido em texto.',...
            'O processo pode demorar vários minutos e consumir todos','os recursos do computador.',...
            'Não é recomendado prosseguir!',' ','Deseja prosseguir?'},'Confirmação','Sim','Não','Não'); drawnow;
elseif N > 100000
    button = questdlg({'O intervalo selecionado é muito grande para ser convertido em texto.',...
            'O processo pode demorar vários minutos.',' ','Deseja prosseguir?'},'Confirmação','Sim','Não','Não'); drawnow;
elseif N == 0
    beep; uiwait(errordlg('Não há pontos no intervalo selecionado.','Erro','modal')); drawnow;
    return
else
    button = 'Sim';
end

if strcmp(button,'Sim')
    ExportData_txt(hObject, eventdata, handles, pts);
end  

% --------------------------------------------------------------------
function ExportSelection_xls_Callback(hObject, eventdata, handles)
global DADOS
% Função para exportar pontos selecionados para planilha Excel

sel = getappdata(handles.window,'sel');

if length(sel)+2 > 65536
    beep; uiwait(errordlg({'Número de pontos selecionados incompatível.','Planilha Excel limitada a 65.536 linhas.'},'Erro','modal')); drawnow;
    return
elseif size(DADOS,2) > 256
    beep; uiwait(errordlg({'Número de parâmetros incompatível.','Planilha Excel limitada a 256 colunas.'},'Erro','modal')); drawnow;
    return
elseif isempty(sel)
    beep; uiwait(errordlg('Não há pontos selecionados.','Erro','modal')); drawnow;
    return
end

ExportData_xls(hObject, eventdata, handles, sel);

% --------------------------------------------------------------------
function ExportSelection_txt_Callback(hObject, eventdata, handles)
global DADOS
% Função para exportar pontos selecionados para o Notepad

sel = getappdata(handles.window,'sel');

N = length(sel)*size(DADOS,2);

if N > 500000
    button = questdlg({'ATENÇÃO!',' ','O número de pontos selecionados é muito grande para ser convertido em texto.',...
            'O processo pode demorar vários minutos e consumir todos','os recursos do computador.',...
            'Não é recomendado prosseguir!',' ','Deseja prosseguir?'},'Confirmação','Sim','Não','Não'); drawnow;
elseif N > 100000
    button = questdlg({'O número de pontos selecionados é muito grande para ser convertido em texto.',...
            'O processo pode demorar vários minutos.',' ','Deseja prosseguir?'},'Confirmação','Sim','Não','Não'); drawnow;
elseif N == 0
    beep; uiwait(errordlg('Não há pontos selecionados.','Erro','modal')); drawnow;
    return
else
    button = 'Sim';
end

if strcmp(button,'Sim')
    ExportData_txt(hObject, eventdata, handles, sel);
end  

% --------------------------------------------------------------------
function ExportTestPts_xls_Callback(hObject, eventdata, handles)
global DADOS
% Função para exportar trechos definidos como pontos de ensaio para planilha Excel

PARAM   = get(handles.xlist,'String');
testpts = getappdata(handles.window,'testpts');
reftime = getappdata(handles.window,'reftime');

if ~isfield(testpts,'number') || isempty([testpts.number])
    beep; uiwait(errordlg('Não há pontos de ensaio definidos.','Erro','modal')); drawnow;
    return
end

if isempty(reftime)
    beep; uiwait(errordlg('O tempo de referência não está definido.','Erro','modal')); drawnow;
    return
end

tcol = findpar(PARAM,reftime,0,1);
if isempty(tcol)
    beep; uiwait(errordlg(['O tempo de referência ''' reftime ''' não foi encontrado.'],'Erro','modal')); drawnow;
    return
end

Ngrp = size(testpts,2);

ptslist{1} = 'Todos os pontos de ensaio';
ptsindx(1) = 0;
for n = 1:Ngrp
    ptslist{length(ptslist)+1} = [' -Grupo ' testpts(n).group];
    ptsindx(length(ptsindx)+1) = n;
    for m = 1:length(testpts(n).number)
        ptslist{length(ptslist)+1} = ['    Ponto ' testpts(n).number{m} ' - ' testpts(n).descr{m}];
        ptsindx(length(ptsindx)+1) = n + m*1i;
    end
end

opt = inputvalue('Opção','Indique o(s) ponto(s) de ensaio que deseja exportar:',ptslist,1,2);

if isempty(opt)
    return
else
    ind = ptsindx(opt);
end

if ind == 0 % Todos
    testptslist.time = [testpts.time];
elseif imag(ind) == 0  % Grupo
    testptslist.time = testpts(ind).time;
else % Ponto
    testptslist.time = testpts(real(ind)).time(:,imag(ind));
end

if isempty(testptslist.time)
    beep; uiwait(errordlg(['Não há pontos de ensaio definidos no grupo ''' testpts(ind).group '''.'],'Erro','modal')); drawnow;
    return
end

set(handles.window,'Pointer','watch');

T = DADOS(:,tcol);

pts = [];
for n = 1:size(testptslist.time,2)
    if ~isnan(testptslist.time(2,n)-testptslist.time(1,n))
        pts = [pts; GetIntervPts(T,testptslist.time(1,n),testptslist.time(2,n))];
    end
end

pts = unique(pts);

if isempty(pts)
    beep; uiwait(errordlg('Intervalo(s) do(s) ponto(s) de ensaio não definido(s) ou sem dados.','Erro','modal')); drawnow;
    return
end

if length(pts)+2 > 65536
    beep; uiwait(errordlg({'Quantidade de dados incompatível.','Planilha Excel limitada a 65.536 linhas.'},'Erro','modal')); drawnow;
    return
elseif size(DADOS,2) > 256
    beep; uiwait(errordlg({'Número de parâmetros incompatível.','Planilha Excel limitada a 256 colunas.'},'Erro','modal')); drawnow;
    return
elseif isempty(pts)
    beep; uiwait(errordlg('Intervalo do(s) ponto(s) de ensaio sem dados.','Erro','modal')); drawnow;
    return
end

ExportData_xls(hObject, eventdata, handles, pts);

% --------------------------------------------------------------------
function ExportTestPts_txt_Callback(hObject, eventdata, handles)
global DADOS
% Função para exportar trechos definidos como pontos de ensaio para planilha Excel

PARAM   = get(handles.xlist,'String');
testpts = getappdata(handles.window,'testpts');
reftime = getappdata(handles.window,'reftime');

if ~isfield(testpts,'number') || isempty([testpts.number])
    beep; uiwait(errordlg('Não há pontos de ensaio definidos.','Erro','modal')); drawnow;
    return
end

if isempty(reftime)
    beep; uiwait(errordlg('O tempo de referência não está definido.','Erro','modal')); drawnow;
    return
end

tcol = findpar(PARAM,reftime,0,1);
if isempty(tcol)
    beep; uiwait(errordlg(['O tempo de referência ''' reftime ''' não foi encontrado.'],'Erro','modal')); drawnow;
    return
end

Ngrp = size(testpts,2);

ptslist{1} = 'Todos os pontos de ensaio';
ptsindx(1) = 0;
for n = 1:Ngrp
    ptslist{length(ptslist)+1} = [' -Grupo ' testpts(n).group];
    ptsindx(length(ptsindx)+1) = n;
    for m = 1:length(testpts(n).number)
        ptslist{length(ptslist)+1} = ['    Ponto ' testpts(n).number{m} ' - ' testpts(n).descr{m}];
        ptsindx(length(ptsindx)+1) = n + m*1i;
    end
end

opt = inputvalue('Opção','Indique o(s) ponto(s) de ensaio que deseja exportar:',ptslist,1,2);

if isempty(opt)
    return
else
    ind = ptsindx(opt);
end

if ind == 0 % Todos
    testptslist.time = [testpts.time];
elseif imag(ind) == 0  % Grupo
    testptslist.time = testpts(ind).time;
else % Ponto
    testptslist.time = testpts(real(ind)).time(:,imag(ind));
end

if isempty(testptslist.time)
    beep; uiwait(errordlg(['Não há pontos de ensaio definidos no grupo ''' testpts(ind).group '''.'],'Erro','modal')); drawnow;
    return
end

set(handles.window,'Pointer','watch');

T = DADOS(:,tcol);

pts = [];
for n = 1:size(testptslist.time,2)
    if ~isnan(testptslist.time(2,n)-testptslist.time(1,n))
        pts = [pts; GetIntervPts(T,testptslist.time(1,n),testptslist.time(2,n))];
    end
end

pts = unique(pts);

if isempty(pts)
    beep; uiwait(errordlg('Intervalo(s) do(s) ponto(s) de ensaio não definido(s) ou sem dados.','Erro','modal')); drawnow;
    return
end

N = length(pts)*size(DADOS,2);

if N > 500000
    button = questdlg({'ATENÇÃO!',' ','A quantidade de dados é muito grande para ser convertida em texto.',...
            'O processo pode demorar vários minutos e consumir todos','os recursos do computador.',...
            'Não é recomendado prosseguir!',' ','Deseja prosseguir?'},'Confirmação','Sim','Não','Não'); drawnow;
elseif N > 100000
    button = questdlg({'A quantidade de dados é muito grande para ser convertida em texto.',...
            'O processo pode demorar vários minutos.',' ','Deseja prosseguir?'},'Confirmação','Sim','Não','Não'); drawnow;
elseif N == 0
    beep; uiwait(errordlg('Intervalo do ponto de ensaio não definido ou sem dados.','Erro','modal')); drawnow;
    return
else
    button = 'Sim';
end

if strcmp(button,'Sim')
    ExportData_txt(hObject, eventdata, handles, pts);
end  

% --------------------------------------------------------------------
function ExportData_xls(hObject, eventdata, handles, pts)
global DADOS
% Função para exportar dados para planilha Excel

set(handles.window,'Pointer','watch');

PARAM = get(handles.xlist,'String');
[PARAM, UNITS] = SplitParamUnits(cellstr(denumber(PARAM)));

for n = 1:length(UNITS)
    if ~isempty(UNITS{n})
        UNITS{n} = ['[' UNITS{n} ']'];
    end
end

if ~isempty(char(UNITS))
    colnames = [PARAM,UNITS]';
else
    colnames = PARAM';
end

[fname, fpath] = uiputfile({'*.xls','Planilha MS Excel (*.xls)'},'Exportar dados para planilha Excel',handles.expfpath); drawnow;

if ischar(fname)
    
    set(handles.window,'Pointer','watch');
    fname = SetFileExtension(fname,'xls');
    try
        if exist([fpath fname],'file')
            lastwarn('');
            delete([fpath fname]);
            if ~isempty(lastwarn)
                beep; uiwait(errordlg(lastwarn,'Erro','modal')); drawnow;
                return
            end
        end
        xlswrite([DADOS(pts,1:end-1) (1:length(pts))'],[],colnames,[fpath fname]);
        
        Excel = actxserver('Excel.Application');
        op = invoke(Excel.Workbooks, 'open', [fpath fname]);
        set(Excel, 'Visible', 1);
        delete(Excel);
        
        handles.expfpath = fpath;
        guidata(hObject, handles);
        NewEvent(handles,['Dados exportados para planilha Excel ''' fname '''.']);
        
    catch
        beep; uiwait(errordlg(lasterr,'Erro','modal')); drawnow;
    end
end

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function ExportData_txt(hObject, eventdata, handles, pts)
global DADOS
% Função para exportar dados para o Notepad

seplist = [abs(' ') 9 abs(',') abs(';')];
preclist = (16:-1:1)';
precliststr = cellstr(num2str2(preclist));
precliststr{end+1} = 9;

[nsep, nprec] = inputvalues('Opções',{'Delimitador:','Precisão:'},...
    {{'Espaço','Tabulação','Vírgula','Ponto e vírgula'},precliststr}); drawnow;

if isempty(nsep)
    Window_ButtonMotionFcn(hObject, eventdata, handles);
    return
end

set(handles.window,'Pointer','watch');

PARAM = get(handles.xlist,'String');
[PARAM, UNITS] = SplitParamUnits(cellstr(denumber(PARAM)));

if ~isempty(char(UNITS))
    for n = 1:length(UNITS)
        UNITS{n} = ['[' UNITS{n} ']'];
    end
    colnames = [PARAM, UNITS]';
else
    colnames = PARAM';
end

sep = char(seplist(nsep));
for n = 1:size(colnames,1)
    for m = 1:size(colnames,2)
        colnames{n,m}(colnames{n,m}==sep) = '_';
    end
end

try
    sep = [char(seplist(nsep)*ones(size(colnames,1)+length(pts),1)) char(32*ones(size(colnames,1)+length(pts),1))];
    
    for n = 1:size(colnames,2)
        if n ~= size(colnames,2)
            COL = fliplr(char(fliplr( char(colnames{:,n}) ), fliplr(num2str( DADOS(pts,n),preclist(nprec)) )));
        else
            COL = fliplr(char(fliplr( char(colnames{:,n}) ), fliplr(num2str( (1:length(pts))' ) )));
        end
        if n == 1
            D = COL;
        else
            D = [D sep COL];
        end
    end
    
    [fname,fpath] = uiputfile({'*.txt','Arquivo de texto (*.txt)'},'Exportar dados para arquivo de texto',handles.expfpath); drawnow;
    
    if ischar(fname)
        
        set(handles.window,'Pointer','watch');
        
        fname = SetFileExtension(fname,'txt');        
        strwrite([fpath fname],D,0);
        
        handles.expfpath = fpath;
        guidata(hObject, handles);
        NewEvent(handles,['Dados exportados para arquivo texto ''' fname '''.']);
        
        try
            set(handles.window,'Pointer','arrow');
            dos(['notepad ' fpath fname]);
        end
    end
    
catch
    beep; uiwait(errordlg(lasterr,'Erro','modal')); drawnow;
end

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function Hold_Callback(hObject, eventdata, handles)
global DADOS
% Função para gravar temporariamente as matrizes de trabalho.
% Usada antes de uma operação possibilita desfaze-la com a função Fetch

button = questdlg('Deseja armazenar arquivo temporário?','Confirmação','Sim','Não','Não'); drawnow;

if strcmp(button,'Sim')
    
    tempfile = [handles.dbpath 'tempfile.mat'];
    savetime = datetime2str(clock);
    
    PARAM      = char(get(handles.xlist,'String'));
    events     = getappdata(handles.window,'events');
    testpts    = getappdata(handles.window,'testpts');
    reftime    = getappdata(handles.window,'reftime');
    setup      = getappdata(handles.window,'setup');
    scenario   = getappdata(handles.window,'scenario');
    properties = getappdata(handles.window,'properties');
    fpath      = handles.fpath;
    fname      = handles.fname;
    
    set(handles.window,'Pointer','watch');
    
    save(tempfile,'DADOS','PARAM','savetime','properties','events','testpts','reftime','setup','scenario','fpath','fname',saveopt);
    
    NewEvent(handles,'Arquivo temporário armazenado.');
end

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function Fetch_Callback(hObject, eventdata, handles)
% Função para recuperar matrizes de trabalho salvas temporariamente pela função Hold

tempfile = [handles.dbpath 'tempfile.mat'];

if ~exist(tempfile,'file')
    beep; uiwait(errordlg('Não há arquivo temporário armazenado.','Erro','modal')); drawnow;
    return
end

fileinfo = whos('-file',tempfile);

if      isempty(strmatch('DADOS'      , {fileinfo.name},'exact')) || ...
        isempty(strmatch('PARAM'      , {fileinfo.name},'exact')) || ...
        isempty(strmatch('savetime'   , {fileinfo.name},'exact')) || ...
        isempty(strmatch('properties' , {fileinfo.name},'exact')) || ...
        isempty(strmatch('events'     , {fileinfo.name},'exact')) || ...
        isempty(strmatch('testpts'    , {fileinfo.name},'exact')) || ...
        isempty(strmatch('reftime'    , {fileinfo.name},'exact')) || ...
        isempty(strmatch('setup'      , {fileinfo.name},'exact')) || ...
        isempty(strmatch('scenario'   , {fileinfo.name},'exact')) || ...
        isempty(strmatch('fpath'      , {fileinfo.name},'exact')) || ...
        isempty(strmatch('fname'      , {fileinfo.name},'exact'))
    
    beep; uiwait(errordlg('Arquivo de armazenamento temporário incompatível.','Erro','modal')); drawnow;
    return
end

PreventiveSave(hObject, eventdata, handles);

load(tempfile,'savetime');
savetime = strrep(savetime,' ',' às ');
button = questdlg({'Deseja recuperar o arquivo temporário salvo em',[savetime ' ?']},'Confirmação','Sim','Não','Não'); drawnow;

if strcmp(button,'Sim')
    set(handles.window,'Pointer','watch');
    
    load(tempfile);
    
    if ~exist(fpath,'dir')
        uiwait(warndlg({'Caminho do arquivo original não encontrado:',fpath},'Aviso','modal')); drawnow;
    else
        handles.fpath = fpath;
    end
    handles.fname = fname;
    guidata(hObject, handles);
    
    testpts = backcompat(testpts,'testpts');
    StartupWorkData(hObject, eventdata, handles, DADOS, PARAM);
    NewEvent(handles,'Arquivo temporário recuperado.');
    
    setappdata(handles.window,'events',events);
    setappdata(handles.window,'testpts',testpts);
    setappdata(handles.window,'reftime',reftime);
    setappdata(handles.window,'setup',setup);
    setappdata(handles.window,'scenario',scenario);
    setappdata(handles.window,'properties',properties);
    UpdateTimeCols(hObject, eventdata, handles);
    
end

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function ClearTemp_Callback(hObject, eventdata, handles)
% Função para apagar as matrizes de trabalho salvas temporariamente pela função Hold

tempfile = [handles.dbpath 'tempfile.mat'];

if ~exist(tempfile,'file')
    beep; uiwait(errordlg('Não há arquivo temporário definido.','Erro','modal')); drawnow;
    return
end

load(tempfile,'savetime');
savetime = strrep(savetime,' ',' às ');
button = questdlg({'Deseja apagar o arquivo temporário salvo em',[savetime ' ?']},'Confirmação','Sim','Não','Não'); drawnow;

if strcmp(button,'Sim')
    set(handles.window,'Pointer','watch');
    
    delete(tempfile);
    
    NewEvent(handles,'Arquivo temporário apagado.');
end

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function Properties_Callback(hObject, eventdata, handles)
global DADOS
% Apresenta as propriedades do arquivo corrente

set(handles.window,'Pointer','watch');

[Nobs,Npar] = size(DADOS);
issingle = getappdata(handles.window,'issingle');
events   = getappdata(handles.window,'events');
testpts  = getappdata(handles.window,'testpts');
reftime  = getappdata(handles.window,'reftime');
setup    = getappdata(handles.window,'setup');
scenario = getappdata(handles.window,'scenario');
properties = getappdata(handles.window,'properties');

if isempty(handles.fname)
    fdata.fname = '';
else
    fdata.fname = handles.fname;
end

if exist([handles.fpath handles.fname],'file') && ismat(handles.fname)
    aux = dir([handles.fpath handles.fname]);
    fdata.fpath = handles.fpath;
    fdata.fdate = datestr(aux.date,'dd/mm/yyyy');
    fdata.ftime = datestr(aux.date,'HH:MM:SS');
    fdata.fsize = aux.bytes;
else
    fdata.fpath = '';
    fdata.fdate = '';
    fdata.ftime = '';
    fdata.fsize = '';
end 
fdata.npar = num2str(Npar);
fdata.nobs = num2str(Nobs);

if isempty(events)
    fdata.events = '';
else
    fdata.events = num2str(size(events,1));
end
if ~isfield(testpts,'number') || isempty([testpts.number])
    fdata.testpts = '';
else
    fdata.testpts = num2str(length([testpts.number]));
end
if isempty(reftime)
    fdata.reftime = '';
else
    fdata.reftime = reftime;
end
if isempty(setup)
    fdata.setup = '';
else
    fdata.setup = 'Sim';
end
if isempty(scenario)
    fdata.scenario = '';
else
    fdata.scenario = 'Sim';
end
if issingle
    fdata.prec = '32 b (single)';
else
    fdata.prec = '64 b (double)';   
end

[properties, clearopt] = RDAT_Properties(properties,fdata);

if ~isempty(properties)
    setappdata(handles.window,'properties',properties);
    setappdata(handles.window,'change',1);
    NewEvent(handles,'Propriedades do arquivo alteradas.');
    
    if clearopt(1)
        setappdata(handles.window,'events',[]);
        set([handles.ShowEvents handles.ShowEventsDescr],'Checked','off');
        set(handles.Events_btn,'Value',0);
        UpdateEvents(hObject, eventdata, handles);
        NewEvent(handles,'Lista de eventos excluída.');
    end
    if clearopt(2)
        setappdata(handles.window,'testpts',[]);
        set([handles.ShowTestPoints handles.ShowTestPointsDescr],'Checked','off');
        set(handles.TestPoints_btn,'Value',0);
        UpdateTestPoints(hObject, eventdata, handles);
        NewEvent(handles,'Lista de pontos de ensaio excluída.');
    end
    if clearopt(3)
        setappdata(handles.window,'reftime','');
        UpdateTimeCols(hObject, eventdata, handles);
        NewEvent(handles,'Tempo de referência liberado.');
    end
    if clearopt(4)
        setappdata(handles.window,'setup',[]);
        NewEvent(handles,'Configuração de parâmetros excluída.');
    end
    if clearopt(5)
        setappdata(handles.window,'scenario',[]);
        NewEvent(handles,'Cenario excluído.');
    end
    
end

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function PageSetup_Callback(hObject, eventdata, handles)
% Configuração de página para impressão

load(which('DatOptions.mat'),'pagesetup');
pagesetup_old = pagesetup;
for n = 1:size(pagesetup,1)
    set(handles.window,pagesetup{n,1},pagesetup{n,2});
end

pagesetupdlg;

for n = 1:size(pagesetup,1)
    pagesetup{n,2} = get(handles.window,pagesetup{n,1});
end

if ~isequal(pagesetup,pagesetup_old)
    save(which('DatOptions.mat'),'pagesetup','-append',saveopt);
end

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function PrintPreview_Callback(hObject, eventdata, handles)
% Visualizar impressão da janela principal

Copy_Callback(hObject, eventdata, handles, 'preview');

% --------------------------------------------------------------------
function Print_Callback(hObject, eventdata, handles)
% Imprimir janela principal

Copy_Callback(hObject, eventdata, handles, 'print');

% --------------------------------------------------------------------
function LoadRecent(hObject, eventdata, handles, n)
% Função para carregar um arquivo recente da lista

recents = getappdata(handles.window,'recents');
recent  = recents{n};

if isempty(recent)
    return
end

PreventiveSave(hObject, eventdata, handles);

button = questdlg({'Deseja carregar o arquivo',[recent ' ?']},'Confirmação','Sim','Não','Não'); drawnow;
if ~strcmp(button,'Sim')
    return
end

if ~exist(recent,'file')
    beep; uiwait(errordlg({'Arquivo não encontrado:',recent},'Erro','modal')); drawnow;
    UpdateRecents(hObject, eventdata, handles, 'remove', n);
    return
end

[fpath,fname,fext] = fileparts(recents{n});
fpath = [fpath '\'];
fname = [fname fext];

LoadMatFile_Callback(hObject, eventdata, handles, fpath, fname);

% --------------------------------------------------------------------
function UpdateRecents(hObject, eventdata, handles, fpath, fname)
% Função para atualizar a lista de arquivos recentes

H = [handles.Recent1 handles.Recent2 handles.Recent3 handles.Recent4];
recents = getappdata(handles.window,'recents');

if nargin == 3 % Atualizar lista
    
    for n = 1:4
        bb = '\\';
        str = recents{n};
        if isempty(str)
            str = '-';
            val = 'off';
        else
            if length(str) >=2 && strcmp(str(1:2),bb)
                str(1:2) = [];
            else
                bb = '';
            end
            nsep = find(str=='\');
            while length(str)>36 && length(nsep)>2
                if strcmp(str(nsep(1)+1:nsep(2)-1),'...')
                    nsep(2) = [];
                end
                str = strrep(str,str(nsep(1)+1:nsep(2)-1),'...');
                nsep = find(str=='\');
            end
            val = 'on';
            str = [bb str];
        end
        set(H(n),'Label',str,'Enable',val);
    end
    return
end

if strcmp(fpath,'remove') % Apagar arquivo
    recents(fname) = [];
    recents = [recents; {''}];
    
else % Acrescentar arquivo
    
    n = strmatch([fpath fname],recents,'exact');
    if ~isempty(n) % Arquivo já está na lista
        recents(n(1)) = [];
    else           % Arquivo não está na lista
        recents(4) = [];
    end
    recents = [{[fpath fname]}; recents(:)];
end

setappdata(handles.window,'recents',recents);
save(which('DatOptions.mat'),'recents','-append',saveopt);
UpdateRecents(hObject, eventdata, handles);

% --------------------------------------------------------------------
function AuxSaveSlice(fname,DADOS,PARAM)
% Função auxiliar para salvar o intervalo selecionado como .mat
% Usa workspace local e DADOS / PARAM como argumentos para preservar DADOS original

save(fname,'DADOS','PARAM',saveopt);

% --------------------------------------------------------------------
function PreventiveSave(hObject, eventdata, handles)
% Função que questiona se o usuario quer salvar o arquivo atual antes de abrir um novo

if getappdata(handles.window,'change')
    if exist([handles.fpath handles.fname],'file') && ismat(handles.fname)
        SaveMatFile_Callback(hObject, eventdata, handles);
    else
        button = savedlg('Deseja salvar o arquivo atual?','Confirmação','Sim','Não','Não'); drawnow;
        if strcmp(button,'Sim')
            SaveMatFileAs_Callback(hObject, eventdata, handles);
        end
    end
end

% --------------------------------------------------------------------
function StartupWorkData(hObject, eventdata, handles, newDADOS, PARAM)
global DADOS
% Função que inicializa o ambiente de trabalho com as matrizes
% DADOS e PARAM validadas

set(handles.window,'Pointer','watch');

if isa(newDADOS,'single')
    DADOS = double(newDADOS);
    setappdata(handles.window,'issingle',1);
else
    DADOS = newDADOS;
    setappdata(handles.window,'issingle',0);
end

if ischar(PARAM)
    PARAM = cellstr(PARAM); % Internamente, PARAM é cell de strings. Ao salvar será char array.
end

setappdata(handles.window,'change',0);
setappdata(handles.window,'sel',[]);
setappdata(handles.window,'events',[]);
setappdata(handles.window,'testpts',[]);
setappdata(handles.window,'reftime','');
setappdata(handles.window,'tempdata',[]);
setappdata(handles.window,'xzoom',[]);
setappdata(handles.window,'barpts',[]);
setappdata(handles.window,'timecols',[]);
setappdata(handles.window,'datatipn',[]);
setappdata(handles.window,'setup',[]);
setappdata(handles.window,'scenario',[]);
setappdata(handles.window,'properties',[]);
setappdata(handles.window,'playbackopt',[]);
setappdata(handles.window,'clickfunc','zoom');

set([handles.selbar handles.ruler handles.auxlines handles.fit handles.fitpt handles.centerpt],'XData',NaN,'YData',NaN);
set(handles.datatips(:,1,1),'XData',NaN,'YData',NaN);
set(handles.datatips(:,1,2),'XData',NaN,'YData',NaN);
set(handles.datatips(:,2,1),'Position',[0 0],'String','','Visible','off');
set(handles.datatips(:,2,2),'Position',[0 0],'String','','Visible','off');

set([handles.ShowRuler handles.ShowSyncLine handles.ShowDataTips handles.ShowTestPoints handles.ShowTestPointsDescr,...
        handles.ShowEvents handles.ShowEventsDescr],'Checked','off');
set(handles.title,'String','');
set(handles.inidisabled,'Enable','on');
set(handles.window,'Name',[handles.vername,' [', handles.fname,']']);

ForgetMultiPar_Callback(hObject, eventdata, handles, 1);
UpdateButtonStatus(hObject, eventdata, handles);
UpdateGraph(hObject, eventdata, handles, length(PARAM), 1, PARAM);
set(handles.graphs,'XLim',AutoLim(handles.plot));
set([handles.yint handles.ydec handles.xint handles.xdec],'Visible','on');

% Análise de subcomutação
load(which('DatOptions.mat'),'subcomut');
if subcomut
    N = min(500,size(DADOS,1));
    M = size(DADOS,2);
    comord = ones(1,M);
    if N > 2
        for m = 1:M
            tx = median(diff(find(~isnan(DADOS(1:N,m)))));
            if ~isempty(tx) && tx <= 64
                comord(m) = tx;
            end            
        end
    end
    comlist = find(comord>1);
    if ~isempty(comlist);
        if length(comlist) == 1
            str = 'Foi encontrado um parâmetro subcomutado na matriz de dados.';
        else
            str = ['Foram encontrados ' num2str(length(comlist)) ' parâmetros subcomutados na matriz de dados.'];
        end
        pause(.2);
        uiwait(warndlg({str,'',...
                'É recomendado executar a análise de subcomutação para','correção do problema antes de trabalhar com o arquivo.'},...
            'Aviso','modal')); drawnow;
    end
end

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function CloseWindow_Callback(hObject, eventdata, handles)
% Função de fechamento do programa

Window_CloseRequestFcn(hObject, eventdata, handles);


% ####################################################################
%                     FUNÇÕES DO MENU EDITAR
% ####################################################################

function Copy_Callback(hObject, eventdata, handles, opt)
% Copia a imagem da janela principal para o Clipboard
% Visualiza a impressão da janela principal (opt: 'preview')
% Imprime a imagem da janela principal      (opt: 'print')
% Obs.: Botões e objetos de controle sao ocultados

if nargin == 3
    opt = 'copy';
end

btnvis = strcmp(get(handles.ShowToolbar,'Checked'),'on');

if btnvis
    ShowToolbar_Callback(hObject, eventdata, handles);
end

hidehandles1 = [handles.controlbtns(1:4) handles.xint handles.xdec handles.yint handles.ydec];
hidehandles2 = [handles.NobsNpar handles.infobox handles.ok_btn handles.cancel_btn];
vislist = get(hidehandles2,'Visible');

bgc = get(handles.window,'Color');

list1 = findobj(handles.window,'Color',bgc);
list2 = findobj(handles.window,'BackGroundColor',bgc);

if ~any(bgc) % Black background
    ColorDefWhite_Callback(hObject, eventdata, handles, 0);
end

set(list1,'Color','w');
set(list2,'BackGroundColor','w');

set([hidehandles1 hidehandles2],'Visible','off');
if strcmp(get(handles.frame,'Visible'),'off') || isequal(get(handles.frame,'Position'),handles.framepos(1,:))
    set([handles.xlist handles.ylist handles.xtext handles.ytext],'Visible','off');
end

if strcmp(opt,'copy')
    
    set(handles.window,'PaperPositionMode','auto');
    print(handles.window,'-zbuffer','-dbitmap');
    
else
    
    if strcmp(get(handles.window,'PaperPositionMode'),'auto')        
        load(which('DatOptions.mat'),'pagesetup');
        for n = 1:size(pagesetup,1)
            set(handles.window,pagesetup{n,1},pagesetup{n,2});
        end        
    end
    
    warning off
    set(handles.infobox,'UserData',0);
    switch opt
        case 'preview'
            printpreview(handles.window);
        case 'print'
            print(handles.window,'-v','-loose');
    end
    set(handles.infobox,'UserData',1);
    warning on
    
end

set(hidehandles1,'Visible','on');
set([handles.xlist handles.ylist handles.xtext handles.ytext],'Visible','on');
for n = 1:length(hidehandles2)
    set(hidehandles2(n),'Visible',vislist{n});
end

set(list1,'Color',bgc);
set(list2,'BackGroundColor',bgc);

if btnvis
    ShowToolbar_Callback(hObject, eventdata, handles);
end

if ~any(bgc) % Black background
    ColorDefBlack_Callback(hObject, eventdata, handles, 0);
end

% --------------------------------------------------------------------
function CopyFormat_Callback(hObject, eventdata, handles)
global DADOS
% Copia o gráfico atual para o Clipboard segundo um modelo

if isempty(DADOS)
    beep; uiwait(errordlg('Não há dados para cópia.','Erro','modal')); drawnow;
    return
end

func = getappdata(handles.window,'func');
part = getappdata(handles.window,'part');

switch func
    case 'MultiGraph3x5_1'
        uiwait(warndlg({'O modelo para cópia não suporta gráficos múltiplos com plotes múltiplos.','Use cópia comum.'},'Aviso','modal')); drawnow;
        return
    case 'MultiPlot16_1'
        uiwait(warndlg({'O modelo para cópia não suporta mais que 5 plotes múltiplos.','Use cópia comum.'},'Aviso','modal')); drawnow;
        return
end

[fh, ah, ph, xh, yh, th] = GetTemplate([handles.dbpath 'copytemplate.fig']);

if ~isempty(fh)
    set(fh,'Visible','off');
    
    set(ah,'XLim',get(handles.graph,'XLim'),'YLim',get(handles.graph,'YLim'),'Units','normalized');
    val = [];
    
    if strcmp(func,'MultiGraph5_1')
        k = 2;
    else
        k = 1;
    end
    
    pts = GetIntervPts(handles);
    for n = 1:5
        X = get(handles.plots(k,n),'XData');
        Y = get(handles.plots(k,n),'YData');
        if isempty(Y) || all(isnan(Y))
            set(ph(n),'XData',X,'YData',Y);
        else
            if isempty(part)
                set(ph(n),'XData',X(pts),'YData',Y(pts));
            else
                set(ph(n),'XData',X,'YData',Y);
            end
            val = [val n];
        end
    end
    set(ph(6),'XData',get(handles.fit,'XData'),'YData',get(handles.fit,'YData'));
    
    set(xh,'String',get(handles.xlabel,'String'));
    set(yh,'String',get(handles.ylabel,'String'));
    set(th,'String',get(handles.title, 'String'),'Interpreter','TeX');
    
    switch func
        case 'MultiPlot5_1'
            PARAM = cellstr(denumber(get(handles.entry1,'String')));
            P{1} = PARAM{get(handles.ylist,'Value')+1};
            P{2} = PARAM{get(handles.entry1,'Value')};
            P{3} = PARAM{get(handles.entry2,'Value')};
            P{4} = PARAM{get(handles.entry3,'Value')};
            P{5} = PARAM{get(handles.entry4,'Value')};
            [ah lh] = legend(ph(val),P(val),'Interpreter','none');
            set(lh(1),'FontSize',10,'FontName',get(ah,'FontName'),'Interpreter','none');
            delete(yh);
            
        case 'MultiGraph5_1'
            PARAM = cellstr(denumber(get(handles.entry1,'String')));
            P{1} = PARAM{get(handles.ylist,'Value')+1};
            P{2} = PARAM{get(handles.entry1,'Value')};
            P{3} = PARAM{get(handles.entry2,'Value')};
            P{4} = PARAM{get(handles.entry3,'Value')};
            P{5} = PARAM{get(handles.entry4,'Value')};
            
            while isempty(deblank(P{end}))
                P(end) = [];
            end
            N = length(P);
            
            pos = get(ah,'Position');
            d = .03;
            
            gh = (pos(4)-(N-1)*d)/N;
            
            for n = 2:N
                ah(n) = axes;
                copyprops(ah(1),ah(n));
                set(ph(n),'Parent',ah(n));
                yh(n) = ylabel(P{n},'Units','normalized');
                copyprops(yh(1),yh(n));
            end
            set(ah(1:N-1),'XTickLabel',[]);
            
            for n = 1:N
                set(ah(n),'Position',[pos(1) pos(2)+(N-n)*(gh+d) pos(3) gh]);
                if n > 1
                    set(ah(n),'YLim',get(handles.graphs(n),'YLim'));
                end
            end
            
            xpos = get(xh,'Position');
            set(xh,'Position',[xpos(1) xpos(2)*pos(4)/gh xpos(3)],'Parent',ah(N));
            
    end
    
    set(fh,'Visible','on','Menubar','figure');
    pause(.5);
    print(fh, '-zbuffer','-noui', '-dbitmap');
    plotedit on;
    
end

% --------------------------------------------------------------------
function copyprops(h1,h2,exc)
% Copia as propriedades de um objeto para outro

if nargin == 2
    exc = {};
end
defaultexc = {'Parent','Tag','String'};
exc = [exc defaultexc];

fp = get(h1);
for n = 1:length(exc)
    if isfield(fp,exc{n})
        fp = rmfield(fp,exc{n});
    end
end

ffield = fieldnames(fp);
fprops = struct2cell(fp);
for n = 1:length(fprops)
    try
        set(h2,ffield{n},fprops{n});
    end
end

% --------------------------------------------------------------------
function EditCopyTemplate_Callback(hObject, eventdata, handles)
% Edita o modelo para copia de gráfico

assignin('base','dbpath',handles.dbpath);

[fh, ah, ph, xh, yh, th] = GetTemplate([handles.dbpath 'copytemplate.fig'], 0);

if isempty(saveopt)
    ok_CB = 'delete(findobj(gcf,''Style'',''pushbutton'')); hgsave(gcf,[dbpath ''copytemplate.fig'']); delete(gcf); clear dbpath;';
else
    ok_CB = 'delete(findobj(gcf,''Style'',''pushbutton'')); hgsave(gcf,[dbpath ''copytemplate.fig''],''-v6''); delete(gcf); clear dbpath;';
end
cn_CB = 'delete(gcf);';
key_CB = ['cc=get(gcf,''CurrentCharacter''); if cc==13, ' ok_CB ' elseif cc==27, ' cn_CB ' end'];

if isempty(fh)
    
    ss = get(0,'ScreenSize');
    fh = figure('NumberTitle','off','Menubar','none','Name','Modelo para Cópia','Color',get(handles.window,'Color'),...
        'Position',[.5*(ss(3)-560) .5*(ss(4)-450) 560 450],'Visible','off','Tag','aux','KeyPressFcn',key_CB);
    ah = axes('Units','pixels','Position',[70 60 450 360],'Box','on','XGrid','on','YGrid','on','NextPlot','add','Tag','axs');
    
    c = 'brgmc';
    x = linspace(0,2*pi,32)';
    for n = 1:5
        y = sin(x)+n;
        ph(n) = plot(x,y,['.-' c(n)],'Tag',['plot' num2str(n)]);
    end
    ph(6) = plot([.5; 5.5],[.5; 5.5],'k--','MarkerSize',5,'LineWidth',2,'Tag','fit');
    
    xlabel('Eixo x','Interpreter','none','Units','normalized');
    ylabel('Eixo y','Interpreter','none','Units','normalized');
    title('Título','Interpreter','none','Units','normalized');
    
    set(fh,'Visible','on');
    
end

okh = uicontrol('Style','pushbutton','String','OK','Position',[10 10 50 20],'Callback',ok_CB);
cnh = uicontrol('Style','pushbutton','String','Cancela','Position',[70 10 50 20],'Callback',cn_CB);

plotedit on;

if getver >= 7
    set(fh,'Menubar','figure');
end

uiwait(fh);
evalin('base','clear dbpath;');

% --------------------------------------------------------------------
function LineTypes_Callback(hObject, eventdata, handles)
% Redefine tipo de linha dos plots

load(which('DatOptions.mat'));

linespec = RDAT_LineOpt(linespec,colorspec.graphcolor);

if ~isempty(linespec);
    for n = 1:5;
        set(handles.plots(:,n),...
            'LineStyle',       linespec(n).linestyle,...
            'Color',           linespec(n).color,...
            'LineWidth',       linespec(n).linewidth,...
            'Marker',          linespec(n).marker,...
            'MarkerEdgeColor', linespec(n).markeredgecolor,...
            'MarkerFaceColor', linespec(n).markerfacecolor,...
            'MarkerSize',      linespec(n).markersize);
        
        if n <= 3
            hp = handles.plots(2,n);
            hpc = get(hp,'MarkerEdgeColor');
            if hpc(1) <= .1 && hpc(2) >= .8 && hpc(3) <= .1 % Verdes
                cv = 'b';
            else
                cv = [0 .8 0];
            end
            if hpc(1) >= .8 && hpc(2) <= .1 && hpc(3) <= .1 % Vermelhos
                ci = 'm';
            else
                ci = 'r';
            end
            set(handles.valplots(n),'Marker', get(hp,'Marker'), 'MarkerSize', get(hp,'MarkerSize'), 'MarkerEdgeColor', cv, 'MarkerFaceColor', cv);
            set(handles.invplots(n),'Marker', get(hp,'Marker'), 'MarkerSize', get(hp,'MarkerSize'), 'MarkerEdgeColor', ci, 'MarkerFaceColor', ci);
        end
    end
    
    save(which('DatOptions.mat'),'linespec','-append',saveopt);
end

% --------------------------------------------------------------------
function BackgroundColor_Callback(hObject, eventdata, handles)
% Mudança na cor de fundo dos gráficos

oldcolor = get(handles.graph,'Color');
bgcolor = uisetcolor(oldcolor);

if ~isequal(bgcolor,oldcolor)
    set(handles.graphs,'Color',bgcolor);
    
    load(which('DatOptions.mat'),'colorspec');
    colorspec.graphcolor = bgcolor;
    
    save(which('DatOptions.mat'),'colorspec','-append',saveopt);
end

% --------------------------------------------------------------------
function ColorDefWhite_Callback(hObject, eventdata, handles, grph)
% Define cor branca para o gráfico

if nargin == 3
    grph = 1;
end
func = getappdata(handles.window,'func');

set(handles.ColorDefWhite,'Checked','on');
set(handles.ColorDefBlack,'Checked','off');

togglelistW = [handles.xlist handles.ylist handles.infobox handles.entries];
togglelistB = [handles.NobsNpar handles.ytext handles.xtext handles.frametxt handles.frame handles.controlbtns(1:4),...
        handles.entriestxt handles.yint handles.ydec handles.xint handles.xdec handles.xlabel handles.ok_btn handles.cancel_btn];

bgc = get(0,'DefaultUicontrolBackgroundColor');
set(handles.window,'Color',bgc);
set(handles.graphs,'XColor','k','YColor','k');
set(togglelistW,'BackgroundColor','w','ForegroundColor','k');
set(togglelistB,'BackgroundColor',bgc,'ForegroundColor','k');
set(handles.title,'Color','k');
set([handles.auxplots(:,1)' handles.ruler handles.fit handles.fitpt handles.datatips(:,1,1)' handles.datatips(:,1,2)'],...
    'Color','k','MarkerEdgeColor','k','MarkerFaceColor','k');
set([handles.eventlbl handles.testptlbl handles.markertip],'Color','k');
set(findobj(handles.graph,'Userdata','auxh'),'Color','k');

if strcmp(func,'MultiPlot5_1')
    set(handles.entry1txt,'ForegroundColor',get(handles.plots(1,2),'Color'));
    set(handles.entry2txt,'ForegroundColor',get(handles.plots(1,3),'Color'));
    set(handles.entry3txt,'ForegroundColor',get(handles.plots(1,4),'Color'));
    set(handles.entry4txt,'ForegroundColor',get(handles.plots(1,5),'Color'));
end

load(which('DatOptions.mat'),'colorspec');
colorspec.colordef = 'w';
if grph
    set(handles.graphs,'Color','w');
    colorspec.graphcolor = [1 1 1];
    save(which('DatOptions.mat'),'colorspec','-append',saveopt);
end
getbuttoncolor(handles.window);

% --------------------------------------------------------------------
function ColorDefBlack_Callback(hObject, eventdata, handles, grph)
% Define cor preta para o gráfico e janela

if nargin == 3
    grph = 1;
end
func = getappdata(handles.window,'func');

set(handles.ColorDefBlack,'Checked','on');
set(handles.ColorDefWhite,'Checked','off');

togglelistW = [handles.xlist, handles.ylist handles.infobox handles.entries];
togglelistB = [handles.NobsNpar handles.ytext handles.xtext handles.frametxt handles.frame handles.controlbtns(1:4),...
        handles.entriestxt handles.yint handles.ydec handles.xint handles.xdec handles.xlabel handles.ok_btn handles.cancel_btn];

set(handles.window,'Color','k');
set(handles.graphs,'XColor','w','YColor','w');
set(togglelistW,'BackgroundColor','k','ForegroundColor','w');
set(togglelistB,'BackgroundColor','k','ForegroundColor','w');
set(handles.title,'Color','w');
set([handles.auxplots(:,1)' handles.ruler handles.fit handles.fitpt handles.datatips(:,1,1)' handles.datatips(:,1,2)'],...
    'Color','w','MarkerEdgeColor','w','MarkerFaceColor','w');
set([handles.eventlbl handles.testptlbl handles.markertip],'Color','w');
set(findobj(handles.graph,'Userdata','auxh'),'Color','w');

if strcmp(func,'MultiPlot5_1')
    set(handles.entry1txt,'ForegroundColor',get(handles.plots(1,2),'Color'));
    set(handles.entry2txt,'ForegroundColor',get(handles.plots(1,3),'Color'));
    set(handles.entry3txt,'ForegroundColor',get(handles.plots(1,4),'Color'));
    set(handles.entry4txt,'ForegroundColor',get(handles.plots(1,5),'Color'));
end

load(which('DatOptions.mat'),'colorspec');
colorspec.colordef = 'k';
if grph
    set(handles.graphs,'Color','k');
    colorspec.graphcolor = [0 0 0];
    save(which('DatOptions.mat'),'colorspec','-append',saveopt);
end


% ####################################################################
%                     FUNÇÕES DO MENU FUNÇÕES
% ####################################################################

function GenerateSyncTime_Callback(hObject, eventdata, handles)
global DADOS
% Gera tempo em segundos a partir dos quatro parâmetros HH, MM, SS e MSS

PARAM  = get(handles.xlist,'String');
func   = getappdata(handles.window,'func');
cancel = getappdata(handles.window,'cancel');

if strcmp(func,'none') && ~cancel
    
    set(handles.entry1txt,'String','Hora:');
    set(handles.entry2txt,'String','Minuto:');
    set(handles.entry3txt,'String','Segundo:');
    set(handles.entry4txt,'String','Milisseg.:');
    set(handles.entries(1:3),'String',PARAM);
    set(handles.entries(4),'String',[{'Ignorar'};PARAM]);
    
    set([handles.entries handles.entriestxt handles.ok_btn handles.cancel_btn],'Visible','on');
    SetFrame(handles,1,'Indique os parâmetros de tempo:');
    set([handles.menulist handles.xlist handles.ylist],'Enable','off');
    UpdateButtonStatus(hObject, eventdata, handles);
    
    parHH = findpar(PARAM,{'hh','hora','hour'});
    if isempty(parHH), parHH = 1; end
    parMM = findpar(PARAM,{'mm','min'});
    if isempty(parMM), parMM = 1; end
    parSS = findpar(PARAM,{'ss','seg','sec'});
    if isempty(parSS), parSS = 1; end
    parMS = findpar(PARAM,{'ms','milis'}) + 1;
    if isempty(parMS), parMS = 1; end
    
    set(handles.entry1,'Value',parHH);
    set(handles.entry2,'Value',parMM);
    set(handles.entry3,'Value',parSS);
    set(handles.entry4,'Value',parMS);
    
    set(handles.xlist,'Value',length(PARAM));
    xlist_Callback(hObject, eventdata, handles);
    
    setappdata(handles.window,'func','GenerateSyncTime_1');
    MultiParamOperation_setgraph(hObject, eventdata, handles, 4);
    
elseif strcmp(func,'GenerateSyncTime_1') && ~cancel
    
    set(handles.window,'Pointer','watch');
    
    hh = DADOS(:,get(handles.entry1,'Value'));
    mm = DADOS(:,get(handles.entry2,'Value'));
    ss = DADOS(:,get(handles.entry3,'Value'));
    if get(handles.entry4,'Value') == 1
        ms = 0*ss;
    else
        ms = DADOS(:,get(handles.entry4,'Value')-1);
    end
    
    time = hh*60*60 + mm*60 + ss + ms/1000;
    setappdata(handles.window,'tempdata',time);
    
    MultiParamOperation_setgraph(hObject, eventdata, handles, 0, 0);
    ShowTemporaryPlot(hObject, eventdata, handles, time, 'Tempo (s)');
    set(handles.graphs,'XLim',AutoLim(handles.plots(1,2)));
    
    setappdata(handles.window,'func','GenerateSyncTime_2');
    
elseif strcmp(func,'GenerateSyncTime_2') && ~cancel
    
    name = TrimParamName(get(handles.entry1,'String'),handles.maxparamlength);
    if isempty(name)
        beep; uiwait(errordlg('Nome do parâmetro não pode ser vazio.','Erro','modal')); drawnow;
        return
    end
    PARAM = InsertParam(PARAM,name);
    CheckRepParam(PARAM,name);
    
    data  = getappdata(handles.window,'tempdata');
    DADOS = [DADOS(:,1:end-1), data, DADOS(:,end)];
    
    xcol = length(PARAM);
    ycol = length(PARAM)-1;
    
    HideTemporaryPlot(hObject, eventdata, handles, xcol, ycol, PARAM);
    setappdata(handles.window,'func','none');
    
    setappdata(handles.window,'change',1);
    NewEvent(handles,['Parâmetro de tempo criado: ''' name '''.']);
    
elseif cancel
    
    MultiParamOperation_setgraph(hObject, eventdata, handles, 0, 0);
    HideTemporaryPlot(hObject, eventdata, handles);
    
end

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function DegMinSec2Deg_Callback(hObject, eventdata, handles)
global DADOS
% Gera coordenada em graus partir dos parâmetros Grau, Min e Seg

PARAM  = get(handles.xlist,'String');
func   = getappdata(handles.window,'func');
cancel = getappdata(handles.window,'cancel');

if strcmp(func,'none') && ~cancel
    
    set(handles.entry1txt,'String','Grau:');
    set(handles.entry2txt,'String','Minuto:');
    set(handles.entry3txt,'String','Segundo:');
    set(handles.entry4txt,'String','Sinal:');
    set(handles.entries(1:3),'String',PARAM);
    set(handles.entry4,'String',{' ±[G M S]',' [±G M S]'},'Value',1);
    
    set([handles.entries handles.entriestxt handles.ok_btn handles.cancel_btn],'Visible','on');
    SetFrame(handles,1,'Indique os parâmetros de coordenadas:');
    set([handles.menulist handles.xlist handles.ylist],'Enable','off');
    UpdateButtonStatus(hObject, eventdata, handles);
    
    parDD = findpar(PARAM,{'grau','deg'});
    if isempty(parDD), parDD = 1; end
    parMM = findpar(PARAM,'min');
    if isempty(parMM), parMM = 1; end
    parSS = findpar(PARAM,{'seg','sec'});
    if isempty(parSS), parSS = 1; end
    
    set(handles.entry1,'Value',parDD);
    set(handles.entry2,'Value',parMM);
    set(handles.entry3,'Value',parSS);
    
    set(handles.xlist,'Value',length(PARAM));
    xlist_Callback(hObject, eventdata, handles);
    
    setappdata(handles.window,'func','DegMinSec2Deg_1');
    MultiParamOperation_setgraph(hObject, eventdata, handles, 3);
    
elseif strcmp(func,'DegMinSec2Deg_1') && ~cancel
    
    set(handles.window,'Pointer','watch');
    
    dd = DADOS(:,get(handles.entry1,'Value'));
    mm = DADOS(:,get(handles.entry2,'Value'));
    ss = DADOS(:,get(handles.entry3,'Value'));
    opt = get(handles.entry4,'Value');
    
    switch opt
        case 1
            deg = dd + mm/60 + ss/3600;
        case 2
            deg = dd + sign(dd).*(mm/60 + ss/3600);
    end
    
    setappdata(handles.window,'tempdata',deg);
    
    MultiParamOperation_setgraph(hObject, eventdata, handles, 0, 0);
    ShowTemporaryPlot(hObject, eventdata, handles, deg, '');
    set(handles.graphs,'XLim',AutoLim(handles.plots(1,2)));
    
    setappdata(handles.window,'func','DegMinSec2Deg_2');
    
elseif strcmp(func,'DegMinSec2Deg_2') && ~cancel
    
    name = TrimParamName(get(handles.entry1,'String'),handles.maxparamlength);
    if isempty(name)
        beep; uiwait(errordlg('Nome do parâmetro não pode ser vazio.','Erro','modal')); drawnow;
        return
    end 
    PARAM = InsertParam(PARAM,name);
    CheckRepParam(PARAM,name);
    
    data  = getappdata(handles.window,'tempdata');
    DADOS = [DADOS(:,1:end-1), data, DADOS(:,end)];
    
    xcol = length(PARAM);
    ycol = length(PARAM)-1;
    
    HideTemporaryPlot(hObject, eventdata, handles, xcol, ycol, PARAM);
    setappdata(handles.window,'func','none');
    
    setappdata(handles.window,'change',1);
    NewEvent(handles,['Parâmetro de coordenada criado: ''' name '''.']);
    
elseif cancel
    
    MultiParamOperation_setgraph(hObject, eventdata, handles, 0, 0);
    HideTemporaryPlot(hObject, eventdata, handles);
    
end

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function MergeValidSections_Callback(hObject, eventdata, handles)
global DADOS
% Gera tempo em segundos a partir dos quatro parâmetros HH, MM, SS e MSS

PARAM  = get(handles.xlist,'String');
func   = getappdata(handles.window,'func');
cancel = getappdata(handles.window,'cancel');

if strcmp(func,'none') && ~cancel
    
    set([handles.entry1txt handles.ylabels(2)],'String','Param 2');
    set([handles.entry2txt handles.ylabels(3)],'String','Param 3');
    set([handles.entry3txt handles.ylabels(4)],'String','Param 4');
    set([handles.entry4txt handles.ylabels(5)],'String','Param 5');
    set(handles.entries,'String',[{' '};PARAM],'Value',1);
    set(handles.graphs,'XLim',get(handles.graph,'XLim'));
    
    set([handles.entries handles.entriestxt handles.ok_btn handles.cancel_btn],'Visible','on');
    SetFrame(handles,2,'Indique os parâmetros para composição:');
    set(handles.menulist,'Enable','off');
    UpdateButtonStatus(hObject, eventdata, handles);
    
    setappdata(handles.window,'func','MergeValidSections_1');
    
elseif strcmp(func,'MergeValidSections_1') && ~cancel
    
    YY = NaN*zeros(size(DADOS,1),5);
    
    n1 = get(handles.ylist,'Value');
    n2 = get(handles.entry1,'Value')-1;
    n3 = get(handles.entry2,'Value')-1;
    n4 = get(handles.entry3,'Value')-1;
    n5 = get(handles.entry4,'Value')-1;
    
    if ~any([n2 n3 n4 n5])
        beep; uiwait(errordlg('Selecione pelo menos dois parâmetros.','Erro','modal')); drawnow;
        return
    end
    
    YY(:,1) = DADOS(:,n1);
    if n2, YY(:,2) = DADOS(:,n2); end
    if n3, YY(:,3) = DADOS(:,n3); end
    if n4, YY(:,4) = DADOS(:,n4); end
    if n5, YY(:,5) = DADOS(:,n5); end
    
    notnan = ~isnan(YY);
    intx = nansum(notnan')';
    
    if any(intx > 1)
        opt = RDAT_InputOption('Opção',{'Encontrados trechos válidos (com valores diferentes','de NaN) comuns a mais de um parâmetro.','','O que deseja fazer?'},...
            {'Manter valores dos parâmetros anteriores','Manter valores dos parâmetros posteriores','Obter o valor médio','Somar os valores'},1,280,1); drawnow;
        if isempty(opt)
            Window_ButtonMotionFcn(hObject, eventdata, handles);
            return
        end 
        
        switch opt
            case 1 % Valores anteriores
                for n = 1:4
                    YY(notnan(:,n),n+1:end) = NaN;
                end
                Y = nansum(YY')';
                
            case 2 % Valores posteriores
                YY = fliplr(YY);
                notnan = fliplr(notnan);
                for n = 1:4
                    YY(notnan(:,n),n+1:end) = NaN;
                end
                Y = nansum(YY')';
                
            case 3 % Media
                Y = nanmean(YY')';
                
            case 4 % Somar
                Y = nansum(YY')';
                
        end
        
    else
        Y = nansum(YY')';
    end
    
    setappdata(handles.window,'tempdata',Y);
    
    MultiParamOperation_setgraph(hObject, eventdata, handles, 0, 0);
    ShowTemporaryPlot(hObject, eventdata, handles, Y, '');
    set(handles.graphs,'XLim',AutoLim(handles.plots(1,2)));
    
    setappdata(handles.window,'func','MergeValidSections_2');
    
elseif strcmp(func,'MergeValidSections_2') && ~cancel
    
    name = TrimParamName(get(handles.entry1,'String'),handles.maxparamlength);
    if isempty(name)
        beep; uiwait(errordlg('Nome do parâmetro não pode ser vazio.','Erro','modal')); drawnow;
        return
    end
    PARAM = InsertParam(PARAM,name);
    CheckRepParam(PARAM,name);
    
    data  = getappdata(handles.window,'tempdata');
    DADOS = [DADOS(:,1:end-1), data, DADOS(:,end)];
    
    xcol = length(PARAM);
    ycol = length(PARAM)-1;
    
    HideTemporaryPlot(hObject, eventdata, handles, xcol, ycol, PARAM);
    setappdata(handles.window,'func','none');
    
    setappdata(handles.window,'change',1);
    NewEvent(handles,['Parâmetro ''' name ''' criado por composição de trechos válidos.']);
    
elseif cancel
    
    MultiParamOperation_setgraph(hObject, eventdata, handles, 0, 0);
    HideTemporaryPlot(hObject, eventdata, handles);
    
end

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function SignalFilter_Callback(hObject, eventdata, handles)
global DADOS
% Filtragem de sinal

PARAM  = get(handles.xlist,'String');
func   = getappdata(handles.window,'func');
cancel = getappdata(handles.window,'cancel');
ok     = getappdata(handles.window,'ok');

if strcmp(func,'none') && ~cancel
    
    filteropt = getappdata(handles.window,'filteropt');
    set(handles.entry1txt,'String','Param.:');
    set(handles.entry2txt,'String','Passes:');
    set(handles.entry3txt,'String','Filtro:');
    set(handles.entry4txt,'String','Em:');
    set(handles.entry1,'String',PARAM,'Value',get(handles.ylist,'Value'));
    set(handles.entry2,'String',{'1 (ida)','2 (ida e volta)'},'Value',filteropt{3});
    set(handles.entry3,'Style','pushbutton','String','Carregar ...');
    set(handles.entry4,'String',{'Tudo','Itervalo'},'Value',1);
    
    set([handles.entries handles.entriestxt handles.ok_btn handles.cancel_btn],'Visible','on');
    SetFrame(handles,1,'Indique os parâmetros de filtragem:');
    set([handles.menulist handles.xlist handles.ylist],'Enable','off');
    UpdateButtonStatus(hObject, eventdata, handles);
    
    setappdata(handles.window,'func','SignalFilter_1');
    
    SignalFilter_Callback(hObject, eventdata, handles);
    
elseif strcmp(func,'SignalFilter_1') && ~cancel
    
    if ok
        
        Y2 = getappdata(handles.window,'tempdata');
        if isempty(Y2)
            beep; uiwait(errordlg('Filtro não definido.','Erro','modal')); drawnow;
        else
            ShowTemporaryPlot(hObject, eventdata, handles, Y2, ['Filt ' get(handles.ylabel,'String')]);
            setappdata(handles.window,'tempdata',Y2);
            setappdata(handles.window,'func','SignalFilter_2');
        end
    else
        
        filteropt = getappdata(handles.window,'filteropt');
        Hd = filteropt{1};
        if isempty(Hd)
            set(handles.plots(1,2),'XData',NaN,'YData',NaN);
            setappdata(handles.window,'tempdata',[]);
            return
        end
        
        set(handles.window,'Pointer','watch');
        
        opt = get(handles.entry2,'Value');
        in  = get(handles.entry4,'Value');
        
        switch in
            case 1 % Tudo
                pts = DADOS(:,end);
            case 2 % Intervalo
                pts = GetIntervPts(handles);
        end
        
        X = DADOS(:,get(handles.xlist,'Value'));
        Y = DADOS(:,get(handles.entry1,'Value'));
        
        nnan = find(isnan(Y));
        
        Y  = denan(Y);
        Y2 = Y;
        
        if isempty(pts);
            beep; uiwait(errordlg('Não há pontos no intervalo selecionado.','Erro','modal')); drawnow;
        end
        
        try
            switch opt
                case 1 % Ida
                    Y2(pts) = filter(Hd,Y(pts));
                case 2 % Ida e volta
                    Hd = convert(Hd,'df1');
                    b = Hd.Numerator;
                    a = Hd.Denominator;
                    Y2(pts) = filtfilt(b,a,Y(pts));
            end
        catch
            set(handles.plots(1,2),'XData',NaN,'YData',NaN);
            beep; uiwait(errordlg(lasterr,'Erro','modal')); drawnow;
            Window_ButtonMotionFcn(hObject, eventdata, handles);
            return
        end
        
        Y2(nnan) = NaN;
        set(handles.plots(1,2),'XData',X,'YData',Y2);
        setappdata(handles.window,'tempdata',Y2);
        
    end
    
elseif strcmp(func,'SignalFilter_2') && ~cancel
    
    name = TrimParamName(get(handles.entry1,'String'),handles.maxparamlength);
    if isempty(name)
        beep; uiwait(errordlg('Nome do parâmetro não pode ser vazio.','Erro','modal')); drawnow;
        return
    end 
    PARAM = InsertParam(PARAM,name);
    CheckRepParam(PARAM,name);
    
    data  = getappdata(handles.window,'tempdata');
    DADOS = [DADOS(:,1:end-1), data, DADOS(:,end)];
    
    xcol = get(handles.xlist,'Value');
    if xcol == length(PARAM)-1
        xcol = xcol+1;
    end
    ycol = length(PARAM)-1;
    
    HideTemporaryPlot(hObject, eventdata, handles, xcol, ycol, PARAM);
    setappdata(handles.window,'func','none');
    
    setappdata(handles.window,'change',1);
    NewEvent(handles,['Parâmetro ''' name ''' criado por filtragem.']);
    
elseif cancel
    
    HideTemporaryPlot(hObject, eventdata, handles);
    
end

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function ML_FDATool_Callback(hObject, eventdata, handles)
% Ferramenta de criação de filtros do MATLAB

fdatool;

% --------------------------------------------------------------------
function InterpSelPts_Callback(hObject, eventdata, handles)
global DADOS
% Interpola os pontos selecionados

PARAM     = get(handles.xlist,'String');
func      = getappdata(handles.window,'func');
clickfunc = getappdata(handles.window,'clickfunc');
cancel    = getappdata(handles.window,'cancel');
ok        = getappdata(handles.window,'ok');
sel       = getappdata(handles.window,'sel');

xcol = get(handles.xlist,'Value');
ycol = get(handles.ylist,'Value');
X = DADOS(:,xcol);
Y = DADOS(:,ycol);
NObs = DADOS(:,end);

if strcmp(func,'none') && ~cancel
    
    if isempty(sel)
        beep; errordlg('Nenhum ponto selecionado.','Erro','modal'); drawnow;
        return
    end
    if length(sel) == size(DADOS,1)
        beep; errordlg('Todos os pontos estão selecionados.','Erro','modal'); drawnow;
        return
    end
    
    if ~IsTimeOk(X)
        beep; errordlg({'O parâmetro x deve ser monotônico crescente e sem pontos inválidos.',...
                'Use ''No. OBS.'' ou um parâmetro de tempo adequado.'},'Erro','modal'); drawnow;
        return
    end
    if all(isnan(Y))
        beep; errordlg('O parâmetro é inteiramente inválido.','Erro','modal'); drawnow;
        return
    end
    
    if strcmp(clickfunc,'select')
        
        method = 'linear';
        nans   = find(isnan(Y));
        
        % Correção da discrepancia de seleção nos extremos
        if sel(1) == 1
            ind = setdiff(NObs,sel); % 1o pto não selecionado
            ind = ind(1);
            Y(1:ind-1) = Y(ind);
            sel(1) = [];
        end
        if sel(end) == length(NObs)
            ind = setdiff(NObs,sel); % Ultimo pto não selecionado
            ind = ind(end);
            Y(ind+1:end) = Y(ind);
            sel(end) = [];
        end
        
        invsel = setdiff(NObs,sel);
        
        Y2 = denan(Y);
        Y2 = interp1(X(invsel),Y2(invsel),X,method);
        Y2(setdiff(nans,sel)) = NaN;
        
        set(handles.plots(1,2),'XData',X,'YData',Y2);
        
        button = questdlg({'Deseja interpolar linearmente os pontos','selecionados e substituir o parâmetro?',...
                'Os dados originais serão perdidos!'},'Confirmação','Sim','Não','Não'); drawnow;
        if strcmp(button,'Sim')
            
            DADOS(:,ycol) = Y2;
            
            UpdateGraph(hObject, eventdata, handles);
            setappdata(handles.window,'change',1);
            NewEvent(handles,['Parâmetro ''' get(handles.ylabel,'String') ''' alterado por interpolação de pontos selecionados.']);
        end
        
        set(handles.plots(1,2),'XData',NaN,'YData',NaN);
        return
    end
    
    set(handles.entry1txt,'String','Método:');
    set(handles.entry2txt,'String','Valor:');
    set(handles.entry3txt,'String','Em:');
    set(handles.entry4txt,'String','Opção:');
    set(handles.entry1,'String',{'Linear','Vizinho','Spline','Cúbico','Repetir','Especificar','Continuar','Regredir'},'Value',1);
    set(handles.entry2,'Style','edit','String','0');
    set(handles.entry3,'String',{'Tudo','Intervalo'},'Value',1);
    set(handles.entry4,'String',{'Novo parâmetro','Substituir atual'},'Value',1);
    
    set([handles.entries([1 3 4]) handles.entriestxt([1 3 4]) handles.ok_btn handles.cancel_btn],'Visible','on');
    SetFrame(handles,1,'Interpolação dos pontos selecionados:');
    set([handles.menulist handles.xlist handles.ylist],'Enable','off');
    UpdateButtonStatus(hObject, eventdata, handles);
    
    setappdata(handles.window,'func','InterpSelPts_1');
    entry1_Callback(hObject, eventdata, handles);
    
elseif strcmp(func,'InterpSelPts_1') && ~cancel
    
    opt = get(handles.entry4,'Value');
    
    if ok
        if opt == 1 % Novo parâmetro
            
            Y2 = getappdata(handles.window,'tempdata');
            ShowTemporaryPlot(hObject, eventdata, handles, Y2, get(handles.ylabel,'String'));
            setappdata(handles.window,'func','InterpSelPts_2');
            
        else % Substituir
            
            button = questdlg({'Deseja substituir o parâmetro?','Os dados originais serão perdidos!'},'Confirmação',...
                'Sim','Não','Não'); drawnow;
            if strcmp(button,'Sim')
                
                Y2 = getappdata(handles.window,'tempdata');
                DADOS(:,ycol) = Y2;
                
                setappdata(handles.window,'func','none');
                setappdata(handles.window,'tempdata',[]);
                
                HideTemporaryPlot(hObject, eventdata, handles);
                
                setappdata(handles.window,'change',1);
                NewEvent(handles,['Parâmetro ''' get(handles.ylabel,'String') ''' alterado por interpolação de pontos selecionados.']);
            end
        end
        
    else
        
        set(handles.window,'Pointer','watch');
        
        methodlist = {'linear','nearest','spline','cubic'};
        method     = get(handles.entry1,'Value');
        if method == 6
            val    = str2double(get(handles.entry2,'String'));
        elseif method == 7 || method == 8
            delta  = get(handles.entry2,'Value');
        end
        in         = get(handles.entry3,'Value');
        
        nans   = find(isnan(Y));
        pts    = GetIntervPts(handles);
        invpts = setdiff(NObs,pts);
        
        if in == 2 && isempty(pts)
            beep; errordlg('Não há pontos no intervalo selecionado.','Erro','modal'); drawnow;
            Y2 = Y;
            set(handles.plots(1,2),'XData',X,'YData',Y2);
            setappdata(handles.window,'tempdata',Y2);
            Window_ButtonMotionFcn(hObject, eventdata, handles);
            return
        end
        
        if method == 6 && isnan(val)
            beep; errordlg('Parâmetro de entrada incoerente.','Erro','modal'); drawnow;
            Y2 = Y;
            set(handles.plots(1,2),'XData',X,'YData',Y2);
            setappdata(handles.window,'tempdata',Y2);
            Window_ButtonMotionFcn(hObject, eventdata, handles);
            return
        end
        
        % Correção da discrepancia de seleção nos extremos
        if method ~= 6 && method ~= 7 && method ~= 8
            if sel(1) == 1 % 1º pto selecionado
                ind = setdiff(NObs,sel);
                ind = ind(1);
                Y(1:ind-1) = Y(ind);
                sel(1) = [];
            end
            if ~isempty(sel) && sel(end) == length(NObs) % Ultimo pto selecionado
                ind = setdiff(NObs,sel);
                ind = ind(end);
                Y(ind+1:end) = Y(ind);
                sel(end) = [];
            end
        end
        
        if in == 2 % Operação apenas no intervalo
            sel = setdiff(sel,invpts);
        end
        
        invsel = setdiff(NObs,sel);
        
        if method == 5 % Repetir
            Y2 = denan(Y);
            Y2(sel) = NaN;
            Y2 = denan(Y2,1);
            Y2(setdiff(nans,sel)) = NaN;
        elseif method == 6 % Especificar
            Y2 = Y;
            Y2(sel) = val;
        elseif method == 7 % Tirar descontinuidade
            Y2 = Y;
            nbrk = sort([sel(1); sel(find(diff(sel)>1)); sel(find(diff(sel)>1)+1); sel(end)]);
            for n = 1:length(nbrk)/2
                if nbrk(2*n-1) ~= 1
                    if delta == 1
                        d = 0;
                    else
                        d = Y2(nbrk(2*n-1)-1) - Y2(max(1,nbrk(2*n-1)-2));
                    end
                    Y2(nbrk(2*n-1):nbrk(2*n)) = Y2(nbrk(2*n-1):nbrk(2*n)) - Y2(nbrk(2*n-1)) + Y2(nbrk(2*n-1)-1) + d;
                end
            end
        elseif method == 8 % Tirar descontinuidade para tras
            Y2 = Y;
            Nobs = length(Y);
            nbrk = sort([sel(1); sel(find(diff(sel)>1)); sel(find(diff(sel)>1)+1); sel(end)]);
            for n = 1:length(nbrk)/2
                if nbrk(2*n) ~= Nobs
                    if delta == 1
                        d = 0;
                    else
                        d = Y2(min(Nobs,nbrk(2*n)+2)) - Y2(nbrk(2*n)+1);
                    end
                    Y2(nbrk(2*n-1):nbrk(2*n)) = Y2(nbrk(2*n-1):nbrk(2*n)) - Y2(nbrk(2*n)) + Y2(nbrk(2*n)+1) - d;
                end
            end
        else 
            Y2 = denan(Y);
            Y2 = interp1(X(invsel),Y2(invsel),X,methodlist{method});
            Y2(setdiff(nans,sel)) = NaN;
        end
        
        set(handles.plots(1,2),'XData',X,'YData',Y2);
        setappdata(handles.window,'tempdata',Y2);
        
    end
    
elseif strcmp(func,'InterpSelPts_2') && ~cancel
    
    name = TrimParamName(get(handles.entry1,'String'),handles.maxparamlength);
    if isempty(name)
        beep; uiwait(errordlg('Nome do parâmetro não pode ser vazio.','Erro','modal')); drawnow;
        return
    end 
    PARAM = InsertParam(PARAM,name);
    CheckRepParam(PARAM,name);
    
    data  = getappdata(handles.window,'tempdata');
    DADOS = [DADOS(:,1:end-1), data, DADOS(:,end)];
    
    if xcol == length(PARAM)-1
        xcol = xcol+1;
    end
    ycol = length(PARAM)-1;
    
    HideTemporaryPlot(hObject, eventdata, handles, xcol, ycol, PARAM);
    setappdata(handles.window,'func','none');
    
    setappdata(handles.window,'change',1);
    NewEvent(handles,['Parâmetro ''' name ''' criado por interpolação de pontos selecionados.']);
    
elseif cancel
    
    HideTemporaryPlot(hObject, eventdata, handles);
    
end

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function InterpNaNPts_Callback(hObject, eventdata, handles)
global DADOS
% Interpola os pontos invalidos

PARAM     = get(handles.xlist,'String');
func      = getappdata(handles.window,'func');
cancel    = getappdata(handles.window,'cancel');
ok        = getappdata(handles.window,'ok');

xcol = get(handles.xlist,'Value');
ycol = get(handles.ylist,'Value');
X = DADOS(:,xcol);
Y = DADOS(:,ycol);
NObs = DADOS(:,end);

nans = find(isnan(Y));

if strcmp(func,'none') && ~cancel
    
    if isempty(nans)
        beep; errordlg('Nenhum ponto inválido.','Erro','modal'); drawnow;
        return
    end
    
    if ~IsTimeOk(X)
        beep; errordlg({'O parâmetro x deve ser monotônico crescente e sem pontos inválidos.',...
                'Use ''No. OBS.'' ou um parâmetro de tempo adequado.'},'Erro','modal'); drawnow;
        return
    end
    
    set(handles.entry1txt,'String','Método:');
    set(handles.entry2txt,'String','Valor:');
    set(handles.entry3txt,'String','Em:');
    set(handles.entry4txt,'String','Opção:');
    set(handles.entry1,'String',{'Linear','Vizinho','Spline','Cúbico','Repetir','Especificar'},'Value',1);
    set(handles.entry2,'Style','edit','String','0');
    set(handles.entry3,'String',{'Tudo','Intervalo'},'Value',1);
    set(handles.entry4,'String',{'Novo parâmetro','Substituir atual'},'Value',1);
    
    set([handles.entries([1 3 4]) handles.entriestxt([1 3 4]) handles.ok_btn handles.cancel_btn],'Visible','on');
    SetFrame(handles,1,'Interpolação dos pontos inválidos:');
    set([handles.menulist handles.xlist handles.ylist],'Enable','off');
    UpdateButtonStatus(hObject, eventdata, handles);
    
    setappdata(handles.window,'func','InterpNaNPts_1');
    entry1_Callback(hObject, eventdata, handles);
    
elseif strcmp(func,'InterpNaNPts_1') && ~cancel
    
    opt = get(handles.entry4,'Value');
    
    if ok
        if opt == 1 % Novo parâmetro
            
            Y2 = getappdata(handles.window,'tempdata');
            ShowTemporaryPlot(hObject, eventdata, handles, Y2, get(handles.ylabel,'String'));
            setappdata(handles.window,'func','InterpNaNPts_2');
            
        else % Substituir
            
            button = questdlg({'Deseja substituir o parâmetro?','Os dados originais serão perdidos!'},'Confirmação',...
                'Sim','Não','Não'); drawnow;
            if strcmp(button,'Sim')
                
                Y2 = getappdata(handles.window,'tempdata');
                DADOS(:,ycol) = Y2;
                
                setappdata(handles.window,'func','none');
                setappdata(handles.window,'tempdata',[]);
                
                HideTemporaryPlot(hObject, eventdata, handles);
                
                setappdata(handles.window,'change',1);
                NewEvent(handles,['Parâmetro ''' get(handles.ylabel,'String') ''' alterado por interpolação de pontos inválidos.']);
            end
        end
        
    else
        
        set(handles.window,'Pointer','watch');
        
        methodlist = {'linear','nearest','spline','cubic'};
        method     = get(handles.entry1,'Value');
        if method == 6
            val    = str2double(get(handles.entry2,'String'));
        end
        in         = get(handles.entry3,'Value');
        
        pts    = GetIntervPts(handles);
        invpts = setdiff(NObs,pts);
        
        if in == 2 && isempty(pts)
            beep; errordlg('Não há pontos no intervalo selecionado.','Erro','modal'); drawnow;
            Y2 = Y;
            set(handles.plots(1,2),'XData',X,'YData',Y2);
            setappdata(handles.window,'tempdata',Y2);
            Window_ButtonMotionFcn(hObject, eventdata, handles);
            return
        end
        
        if method == 6 && isnan(val)
            beep; errordlg('Parâmetro de entrada incoerente.','Erro','modal'); drawnow;
            Y2 = Y;
            set(handles.plots(1,2),'XData',X,'YData',Y2);
            setappdata(handles.window,'tempdata',Y2);
            Window_ButtonMotionFcn(hObject, eventdata, handles);
            return
        end
        
        if in == 2 % Operação apenas no intervalo
            Y0 = Y;
        end
        
        if all(isnan(Y))
            
            if method == 6 % Especificar
                Y2 = Y;
                Y2(nans) = val;
            else
                Y2 = Y;
            end
            
        else
            
            % Correção da discrepancia de invalidez nos extremos
            if method ~= 6
                if nans(1) == 1 % 1o pto inválido
                    ind = setdiff(NObs,nans);
                    ind = ind(1);
                    Y(1:ind-1) = Y(ind);
                    nans(1) = [];
                end
                if ~isempty(nans) && nans(end) == length(NObs) % Ultimo pto inválido
                    ind = setdiff(NObs,nans);
                    ind = ind(end);
                    Y(ind+1:end) = Y(ind);
                    nans(end) = [];
                end
            end
            
            if method == 5 % Repetir
                Y2 = denan(Y,1);
            elseif method == 6 % Especificar
                Y2 = Y;
                Y2(nans) = val;
            else 
                invnans = setdiff(NObs,nans);
                Y2 = interp1(X(invnans),Y(invnans),X,methodlist{method});
            end
            
        end
        
        if in == 2 % Operação apenas no intervalo
            Y2(invpts) = Y0(invpts);
        end
        
        set(handles.plots(1,2),'XData',X,'YData',Y2);
        setappdata(handles.window,'tempdata',Y2);
        
    end
    
elseif strcmp(func,'InterpNaNPts_2') && ~cancel
    
    name = TrimParamName(get(handles.entry1,'String'),handles.maxparamlength);
    if isempty(name)
        beep; uiwait(errordlg('Nome do parâmetro não pode ser vazio.','Erro','modal')); drawnow;
        return
    end 
    PARAM = InsertParam(PARAM,name);
    CheckRepParam(PARAM,name);
    
    data  = getappdata(handles.window,'tempdata');
    DADOS = [DADOS(:,1:end-1), data, DADOS(:,end)];
    
    if xcol == length(PARAM)-1
        xcol = xcol+1;
    end
    ycol = length(PARAM)-1;
    
    HideTemporaryPlot(hObject, eventdata, handles, xcol, ycol, PARAM);
    setappdata(handles.window,'func','none');
    
    setappdata(handles.window,'change',1);
    NewEvent(handles,['Parâmetro ''' name ''' criado por interpolação de pontos inválidos.']);
    
elseif cancel
    
    HideTemporaryPlot(hObject, eventdata, handles);
    
end

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function CreateMilisec_Callback(hObject, eventdata, handles)
global DADOS
% Cria os milissegundos no caso de composição de HH:MM:SS inteiros

PARAM  = get(handles.xlist,'String');
xcol   = get(handles.xlist,'Value');
ycol   = get(handles.ylist,'Value');
func   = getappdata(handles.window,'func');
cancel = getappdata(handles.window,'cancel');
ok     = getappdata(handles.window,'ok');

if strcmp(func,'none') && ~cancel
    
    if xcol ~= length(PARAM)
        set(handles.xlist,'Value',length(PARAM));
        xlist_Callback(hObject, eventdata, handles);
    end
    
    T = denan(DADOS(:,ycol),1);
    
    if any(diff(T)<0)
        beep; uiwait(errordlg('Encontrados pontos descrescentes no tempo.','Erro','modal')); drawnow;
        return
    end
    if any(T-fix(T))
        beep; uiwait(errordlg({'Encontrados valores não-inteiros no tempo.'...
                'Para a geração de milissegundos é necessário que o tempo','seja composto apenas por valores inteiros.'},'Erro','modal')); drawnow;
        return
    end
    if all(diff(T)>0)
        beep; uiwait(errordlg('Não foram encontrados pontos repetidos no tempo.','Erro','modal')); drawnow;
        return
    end
    
    D = find(diff(T));
    if length(D) < 2
        beep; uiwait(errordlg('São necessários no mínimo duas variações no valor do tempo.','Erro','modal')); drawnow;
        return
    end
    
    set(handles.entry1txt,'String','Ajuste:');
    set(handles.entry2txt,'String','Opção:');
    set(handles.entry1,'String',{'Truncamento','Arredondamento'},'Value',1);
    set(handles.entry2,'String',{'Novo parâmetro','Substituir atual'},'Value',1);
    
    set([handles.entries(1:2) handles.entriestxt(1:2) handles.ok_btn handles.cancel_btn],'Visible','on');
    SetFrame(handles,1,'Geração de milissegundos:');
    set([handles.menulist handles.xlist handles.ylist],'Enable','off');
    UpdateButtonStatus(hObject, eventdata, handles);
    
    setappdata(handles.window,'func','CreateMilisec_1');
    entry1_Callback(hObject, eventdata, handles);

elseif strcmp(func,'CreateMilisec_1') && ~cancel
    
    set(handles.window,'Pointer','watch');
    
    T = denan(DADOS(:,ycol),1);
    NObs = DADOS(:,end);
    D = find(diff(T));
    
    dt1 = (   T(D(2)) - T(D(1))     ) / (   D(2) - D(1)     );
    dt2 = ( T(D(end)) - T(D(end-1)) ) / ( D(end) - D(end-1) );
    
    T([true; diff(T)==0]) = NaN;
    
    T(1)   = T(D(1)+1) - dt1*D(1);
    T(end) = T(D(end)+1) + dt2*(length(T)-D(end)-1);
    
    if get(handles.entry1,'Value') == 1 % Truncamento
        adj = 0;
    else
        adj = -.5;
    end
    
    T = denan(T) + adj;
    
    set(handles.plots(1,2),'XData',NObs,'YData',T);
    setappdata(handles.window,'tempdata',T);
    
    opt = get(handles.entry2,'Value');
    
    if ok
        if opt == 1 % Novo parâmetro
            
            ShowTemporaryPlot(hObject, eventdata, handles, T, get(handles.ylabel,'String'));
            setappdata(handles.window,'func','CreateMilisec_2');
            
        else % Substituir
            
            button = questdlg({'Deseja substituir o parâmetro?','Os dados originais serão perdidos!'},'Confirmação',...
                'Sim','Não','Não'); drawnow;
            if strcmp(button,'Sim')
                
                DADOS(:,ycol) = T;
                
                setappdata(handles.window,'func','none');
                setappdata(handles.window,'tempdata',[]);
                
                HideTemporaryPlot(hObject, eventdata, handles);
                
                setappdata(handles.window,'change',1);
                NewEvent(handles,['Parâmetro ''' get(handles.ylabel,'String') ''' alterado por geração de milissegundos.']);
            end
        end
    end
 
elseif strcmp(func,'CreateMilisec_2') && ~cancel
    
    name = TrimParamName(get(handles.entry1,'String'),handles.maxparamlength);
    if isempty(name)
        beep; uiwait(errordlg('Nome do parâmetro não pode ser vazio.','Erro','modal')); drawnow;
        return
    end 
    PARAM = InsertParam(PARAM,name);
    CheckRepParam(PARAM,name);
    
    data  = getappdata(handles.window,'tempdata');
    DADOS = [DADOS(:,1:end-1), data, DADOS(:,end)];
    
    if xcol == length(PARAM)-1
        xcol = xcol+1;
    end
    ycol = length(PARAM)-1;
    
    HideTemporaryPlot(hObject, eventdata, handles, xcol, ycol, PARAM);
    setappdata(handles.window,'func','none');
    
    setappdata(handles.window,'change',1);
    NewEvent(handles,['Parâmetro ''' name ''' criado por geração de milissegundos.']);
    
elseif cancel
    
    HideTemporaryPlot(hObject, eventdata, handles);
    
end

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function Sortrows_Callback(hObject, eventdata, handles)
global DADOS
% Reordena a matriz DADOS segundo a ordem crescente de um parâmetro

PARAM   = get(handles.xlist,'String');
sel     = getappdata(handles.window,'sel');
ordlist = {'Crescente','Decrescente'};

[npar, opt] = inputvalues('Reordenar',{'Parâmetro de referência:','Ordem:'},{PARAM,ordlist},1.35); drawnow;
if isempty(npar)
    return
end

button = questdlg({'Deseja reordenar a matriz de dados segundo o parâmetro',...
        ['''' denumber(PARAM{npar}) ''' em ordem ' lower(ordlist{opt}) '?'],...
        'Os dados originais serão perdidos!'},'Confirmação','Sim','Não','Não'); drawnow;

if strcmp(button,'Sim')
    set(handles.window,'Pointer','watch');
    
    [DADOS, ind] = sortrows(DADOS,npar);
    if opt == 2;
        DADOS = flipud(DADOS);
    end
    DADOS(:,end) = (1:size(DADOS,1))';
    
    if ~isempty(sel)
        SEL = zeros(size(DADOS(:,1)));
        SEL(sel) = 1;
        SEL = SEL(ind);
        sel = find(SEL);
        setappdata(handles.window,'sel',sel);
    end
    
    UpdatePlot(hObject, eventdata, handles);
    
    setappdata(handles.window,'change',1);
    NewEvent(handles,['Dados reordenados segundo o parâmetro ''' denumber(PARAM{npar}) '''.']);
end

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function ChangeRate_Callback(hObject, eventdata, handles)
global DADOS
% Alteração de cadencia (interpolação/decimação)

PARAM  = get(handles.xlist,'String');
xcol   = get(handles.xlist,'Value');
func   = getappdata(handles.window,'func');
cancel = getappdata(handles.window,'cancel');
Nlist  = {'1','2','3','4','5','6','7','8','9','10'};
methodnames = {'Linear','Vizinho','Spline','Cúbico'};

if strcmp(func,'none') && ~cancel
    
    set(handles.entry1txt,'String','Interp.:');
    set(handles.entry2txt,'String','Decim.:');
    set(handles.entry3txt,'String','Método:');
    set(handles.entry4txt,'String','Em:');
    set([handles.entry1 handles.entry2],'String',Nlist,'Value',1);
    set(handles.entry3,'Style','popupmenu','String',methodnames,'Value',1);
    set(handles.entry4,'Style','popupmenu','String',{'Tudo','Intervalo'},'Value',1);
    
    set([handles.entries([1 2 4]) handles.entriestxt([1 2 4]) handles.ok_btn handles.cancel_btn],'Visible','on');
    SetFrame(handles,1,'Indique os parâmetros para alteração de cadência:');
    set([handles.menulist],'Enable','off');
    UpdateButtonStatus(hObject, eventdata, handles);
    
    setappdata(handles.window,'func','ChangeRate_1');
    
elseif strcmp(func,'ChangeRate_1') && ~cancel
    
    Q = str2double(Nlist{get(handles.entry1,'Value')});
    R = str2double(Nlist{get(handles.entry2,'Value')});
    methodlist = {'linear','nearest','spline','cubic'};
    method = methodlist{get(handles.entry3,'Value')};
    methodname = methodnames{get(handles.entry3,'Value')};
    opt = get(handles.entry4,'Value');
    
    if Q*R == 1
        uiwait(warndlg('Nenhuma alteração selecionada.','Aviso','modal')); drawnow;
        return
    end
    
    if Q == R
        uiwait(warndlg('Fatores iguais não resultam em alteração.','Aviso','modal')); drawnow;
        return
    end
    
    if opt == 1 % Tudo
        str = {'Alteração da cadência de amostragem da matriz de dados.',...
                ' ',...
                ['Fator de interpolação: ' num2str(Q)],...
                ['Método: ' methodname],...
                ' ',...
                ['Fator de decimação: ' num2str(R)],...
                ' ','Deseja prosseguir?'};
    else % Intervalo
        str = {'Alteração da cadência de amostragem do intervalo selecionado.',...
                ' ',...
                ['Fator de interpolação: ' num2str(Q)],...
                ['Método: ' methodname],...
                ' ',...
                ['Fator de decimação: ' num2str(R)],...
                ' ',...
                'Não é recomendado alterar a cadência apenas em um intervalo.',...
                'Deseja prosseguir?'};
    end
    
    if Q == 1
        str(2:4) = [];
    elseif R == 1;
        str(5:6) = [];
    end
    
    button = questdlg(str,'Confirmação','Sim','Não','Não'); drawnow;
        
    if ~strcmp(button,'Sim')
        return
    end
    
    set(handles.window,'Pointer','watch');
    
    if opt == 1 % Tudo
        pts = DADOS(:,end);
    else % Intervalo
        pts = GetIntervPts(handles);
    end
    if pts(end) ~= DADOS(end,end)
        DADOS2 = DADOS(pts(end)+1:end,:);
        DADOS(pts(end)+1:end,:) = [];
    else
        DADOS2 = [];
    end
    if pts(1) ~= 1
        DADOS1 = DADOS(1:pts(1)-1,:);
        DADOS(1:pts(1)-1,:) = [];
    else
        DADOS1 = [];
    end
    DADOS(:,end) = (1:length(DADOS(:,end)))';
    
    if Q > 1 % Interpolação
        X  = DADOS(:,end);
        N  = length(X);
        Xi = linspace(1,X(end),Q*(N-1)+1)';
        
        [sel1, ok, sel2] = listdlg2('Name','Interpolação','HeaderString',{'Indique os parâmetros com escala cíclica que contenham descontinuidades, como proa,','inclinação lateral, atitude, direção, radial etc.:'},...
            'PromptString','Intervalo de 0 a 360°','PromptString2','Intervalo de -180 a 180°','SelectionMode','multiple','ListString',PARAM(1:end-1),'ListString2',PARAM(1:end-1),...
            'OKString','OK','CancelString','Cancela','SelectAllString','Selecionar tudo','SelectNoneString','Limpar','ListSize',[200 305]); drawnow;
        pause(.2);
        sel3 = listdlg2('Name','Interpolação','HeaderString',{'Indique os parâmetros lógicos ou inteiros,','como estado de botões, gatilho, modo de','operação, TOP, hora, minuto etc.:'},...
            'SelectionMode','multiple','ListString',PARAM(1:end-1),'OKString','OK','CancelString','Cancela','SelectAllString','Selecionar tudo','SelectNoneString','Limpar','ListSize',[200 305]); drawnow;
        
        for n = 1:length(sel1) % [0 360°] -> continuo
            DADOS(:,sel1(n)) = unwrap2(DADOS(:,sel1(n)));
        end
        for n = 1:length(sel2) % [±180°] -> continuo
            DADOS(:,sel2(n)) = unwrap2(DADOS(:,sel2(n)));
        end
        
        sel1 = setdiff(sel1,xcol);
        sel2 = setdiff(sel2,xcol);
        sel3 = setdiff(sel3,xcol);
        
        try
            
            if ~isempty(sel3);
                DADOSint = DADOS(:,sel3);
            end
            
            h = waitdlg('Interpolando dados ...','Aguarde','modal');
            
            DADOS = interp1(X,DADOS,Xi,method);
            
            for n = 1:length(sel3)
                DADOS(:,sel3(n)) = interp1(X,DADOSint(:,n),Xi,'nearest');
            end
            
            try, delete(h); end
            
        catch
            
            for n = 1:length(sel1) % continuo -> [0 360°]
                DADOS(:,sel1(n)) = mod(DADOS(:,sel1(n)),360);
            end
            for n = 1:length(sel2) % continuo -> [±180°]
                DADOS(:,sel2(n)) = mod(DADOS(:,sel2(n)),360);
                neg = find(DADOS(:,sel2(n)) > 180);
                DADOS(neg,sel2(n)) = DADOS(neg,sel2(n)) - 360;
            end
            
            beep; uiwait(errordlg(lasterr,'Erro','modal')); drawnow;
            Window_ButtonMotionFcn(hObject, eventdata, handles);
            return
        end
        
        for n = 1:length(sel1) % continuo -> [0 360°]
            DADOS(:,sel1(n)) = mod(DADOS(:,sel1(n)),360);
        end
        for n = 1:length(sel2) % continuo -> [±180°]
            DADOS(:,sel2(n)) = mod(DADOS(:,sel2(n)),360);
            neg = find(DADOS(:,sel2(n)) > 180);
            DADOS(neg,sel2(n)) = DADOS(neg,sel2(n)) - 360;
        end
        
    end
    
    if R > 1 % Decimação
        X  = DADOS(:,end);
        N  = length(X);
        Xi = (1:R:N)';
        
        DADOS = DADOS(Xi,:);
    end
    
    DADOS = [DADOS1; DADOS; DADOS2];
    DADOS(:,end) = (1:length(DADOS(:,end)))';
    
    if xcol == size(DADOS,2) && opt == 1;
        set(handles.graphs,'XLim',get(handles.graph,'XLim')*Q/R);
    end
    
    ClearEntryBox(hObject, eventdata, handles);
    DeselectAll_Callback(hObject, eventdata, handles, 0);
    UpdateGraph(hObject, eventdata, handles);
    setappdata(handles.window,'func','none');
    
    setappdata(handles.window,'change',1);
    NewEvent(handles,['Cadência alterada de ' num2str(Q) '/' num2str(R) '.']);
    
    if Q > 1
        FixTOPs(hObject, eventdata, handles);
    end
    
end

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function Resample_Callback(hObject, eventdata, handles)
global DADOS
% Reamostragem de dados

PARAM    = get(handles.xlist,'String');
func     = getappdata(handles.window,'func');
cancel   = getappdata(handles.window,'cancel');
timecols = getappdata(handles.window,'timecols');
xcol     = get(handles.xlist,'Value');
methodnames = {'Linear','Vizinho','Spline','Cúbico'};

if strcmp(func,'none') && ~cancel
    
    if isempty(timecols)
        button = questdlg({'Não foram encontrados parâmetros de tempo.',...
                ['Deseja usar o parâmetro ''' get(handles.xlabel,'String') '''?']},'Erro','Sim','Não','Não'); drawnow;
        if ~strcmp(button,'Sim')
            return
        end
    else
        if xcol~=timecols % xcol não é tempo -> Mudar para primeiro parâmetro de tempo da lista
            xcol = timecols(1);
            set(handles.xlist,'Value',xcol);
            xlist_Callback(hObject, eventdata, handles);
            pause(.3);
        end
    end
    
    T = DADOS(:,xcol);
    
    set(handles.entry1txt,'String','T ini:');
    set(handles.entry2txt,'String','T fim:');
    set(handles.entry3txt,'String','Passo (s):');
    set(handles.entry4txt,'String','Método:');
    set(handles.entry1,'Style','Edit','String',time2str2(T(1)));
    set(handles.entry2,'Style','Edit','String',time2str2(T(end)));
    set(handles.entry3,'Style','Edit','String',num2str(nanmean(diff(T))));
    set(handles.entry4,'String',methodnames,'Value',1);
    
    set([handles.entries handles.entriestxt handles.ok_btn handles.cancel_btn],'Visible','on');
    SetFrame(handles,1,'Indique os parâmetros para reamostragem:');
    set([handles.menulist handles.xlist],'Enable','off');
    UpdateButtonStatus(hObject, eventdata, handles);
    
    setappdata(handles.window,'func','Resample_1');
    
elseif strcmp(func,'Resample_1') && ~cancel
    
    T = DADOS(:,xcol);
    
    Tini = str2time(get(handles.entry1,'String'));
    Tend = str2time(get(handles.entry2,'String'));
    dt   = str2double(get(handles.entry3,'String'));
    methodlist = {'linear','nearest','spline','cubic'};
    method     = methodlist{get(handles.entry4,'Value')};
    methodname = methodnames{get(handles.entry4,'Value')};

    if isnan(Tini+Tend+dt);
        beep; uiwait(errordlg('Parâmetro de entrada incoerente.','Erro','modal')); drawnow;
        return
    end
    
    [ok, ndc, nna] = IsTimeOk(T);
    if ~ok
        beep; uiwait(errordlg({'Parâmetro de tempo não é adequado:',' ',...
                ['Pontos inválidos: ' num2str(length(nna))],...
                ['Pontos não crescentes: ' num2str(length(ndc))]},'Erro','modal')); drawnow;
        return
    end
    
    if Tini >= Tend
        beep; uiwait(errordlg('Tempo inicial deve ser menor que tempo final para reamostragem.','Erro','modal'));
        return
    end
    if Tini < T(1) || Tend > T(end)
        beep; uiwait(errordlg({'Tempo de reamostragem deve estar contido no intervalo',...
                ['do parâmetro ' get(handles.xlabel,'String') ': [' time2str2(T(1)) ', ' time2str2(T(end)) '].']},'Erro','modal'));
        return
    end
    if dt <= 0
        beep; uiwait(errordlg('Passo para reamostragem deve ser positivo não nulo.','Erro','modal'));
        return
    end
    
    Ti = (Tini:dt:Tend)';
    
    if length(Ti) < 2
        beep; uiwait(errordlg({'Parâmetros de entrada incoerentes:','Tempo de reamostragem deve ter pelo menos duas observações.'},'Erro','modal')); drawnow;
        return
    end

    str = {'Reamostragem da matriz de dados.',...
            ' ',...
            ['Intervalo: ' time2str2(Tini) ' a ' time2str2(Tend)],...
            ['Passo: ' num2str(dt) ' s'],...
            ['Número de observações: ' num2str(length(Ti))],...
            ['Método: ' methodname],...
            ' ','Deseja prosseguir?'};
    
    button = questdlg(str,'Confirmação','Sim','Não','Não'); drawnow;
    
    if ~strcmp(button,'Sim')
        return
    end
    
    [sel1, ok, sel2] = listdlg2('Name','Reamostragem','HeaderString',{'Indique os parâmetros com escala cíclica que contenham descontinuidades, como proa,','inclinação lateral, atitude, direção, radial etc.:'},...
        'PromptString','Intervalo de 0 a 360°','PromptString2','Intervalo de -180 a 180°','SelectionMode','multiple','ListString',PARAM(1:end-1),'ListString2',PARAM(1:end-1),...
        'OKString','OK','CancelString','Cancela','SelectAllString','Selecionar tudo','SelectNoneString','Limpar','ListSize',[200 305]); drawnow;
    pause(.2);
    sel3 = listdlg2('Name','Reamostragem','HeaderString',{'Indique os parâmetros lógicos ou inteiros,','como estado de botões, gatilho, modo de','operação, TOP, hora, minuto etc.:'},...
        'SelectionMode','multiple','ListString',PARAM(1:end-1),'OKString','OK','CancelString','Cancela','SelectAllString','Selecionar tudo','SelectNoneString','Limpar','ListSize',[200 305]); drawnow;
    
    for n = 1:length(sel1) % [0 360°] -> continuo
        DADOS(:,sel1(n)) = unwrap2(DADOS(:,sel1(n)));
    end
    for n = 1:length(sel2) % [±180°] -> continuo
        DADOS(:,sel2(n)) = unwrap2(DADOS(:,sel2(n)));
    end
    
    sel1 = setdiff(sel1,xcol);
    sel2 = setdiff(sel2,xcol);
    sel3 = setdiff(sel3,xcol);
    
    set(handles.window,'Pointer','watch');
    
    try
        
        if ~isempty(sel3);
            DADOSint = DADOS(:,sel3);
        end
        
        h = waitdlg('Interpolando dados ...','Aguarde','modal');
        
        DADOS = interp1(T,DADOS,Ti,method);
        
        for n = 1:length(sel3)
            DADOS(:,sel3(n)) = interp1(T,DADOSint(:,n),Ti,'nearest');
        end
        
        try, delete(h); end
        
    catch
        
        for n = 1:length(sel1) % continuo -> [0 360°]
            DADOS(:,sel1(n)) = mod(DADOS(:,sel1(n)),360);
        end
        for n = 1:length(sel2) % continuo -> [±180°]
            DADOS(:,sel2(n)) = mod(DADOS(:,sel2(n)),360);
            neg = find(DADOS(:,sel2(n)) > 180);
            DADOS(neg,sel2(n)) = DADOS(neg,sel2(n)) - 360;
        end
        
        beep; uiwait(errordlg(lasterr,'Erro','modal')); drawnow;
        Window_ButtonMotionFcn(hObject, eventdata, handles);
        return
    end
    
    for n = 1:length(sel1) % continuo -> [0 360°]
        DADOS(:,sel1(n)) = mod(DADOS(:,sel1(n)),360);
    end
    for n = 1:length(sel2) % continuo -> [±180°]
        DADOS(:,sel2(n)) = mod(DADOS(:,sel2(n)),360);
        neg = find(DADOS(:,sel2(n)) > 180);
        DADOS(neg,sel2(n)) = DADOS(neg,sel2(n)) - 360;
    end
    
    ClearEntryBox(hObject, eventdata, handles);
    DeselectAll_Callback(hObject, eventdata, handles, 0);
    UpdateGraph(hObject, eventdata, handles);
    setappdata(handles.window,'func','none');
    
    setappdata(handles.window,'change',1);
    NewEvent(handles,'Matriz de dados reamostrada.');
    
    FixTOPs(hObject, eventdata, handles);
    
end

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function ChangeCircularInterval_Callback(hObject, eventdata, handles)
global DADOS
% Alterações de intervalos angulares

PARAM  = get(handles.xlist,'String');
xcol   = get(handles.xlist,'Value');
ycol   = get(handles.ylist,'Value');
func   = getappdata(handles.window,'func');
cancel = getappdata(handles.window,'cancel');

if strcmp(func,'none') && ~cancel
    
    if ~isempty(strfind(lower(PARAM{ycol}),'(rad'))
        n_unit = 2;
    else
        n_unit = 1;
    end
    set(handles.entry1txt,'String','Intervalo:');
    set(handles.entry2txt,'String','Unidade:');
    set(handles.entry3txt,'String','Opção:');
    set(handles.entry1,'String',{'0 a 360°','-180 a 180°','Contínuo','Trig --> Geo','Geo --> Trig'},'Value',1);
    set(handles.entry2,'String',{'Graus','Radianos'},'Value',n_unit);
    set(handles.entry3,'String',{'Novo parâmetro','Substituir atual'},'Value',1);
    
    set([handles.entries(1:3) handles.entriestxt(1:3) handles.ok_btn handles.cancel_btn],'Visible','on');
    SetFrame(handles,2,'Alteração de intervalo circular:');
    set([handles.menulist handles.xlist],'Enable','off');
    UpdateButtonStatus(hObject, eventdata, handles);
    
    setappdata(handles.window,'func','CircInterv_1');
    
elseif strcmp(func,'CircInterv_1') && ~cancel
    
    set(handles.window,'Pointer','watch');
    
    Y = DADOS(:,ycol);
    oper = get(handles.entry1,'Value');
    unit = get(handles.entry2,'Value');
    opt  = get(handles.entry3,'Value');
    
    if ycol == length(PARAM) && opt == 2
        beep; uiwait(errordlg('Não é possível alterar o parâmetro ''No. OBS.''','Erro','modal')); drawnow;
        return
    end
    
    if unit == 1
        D90  = 90;
        D180 = 180;
        D360 = 360;
    else
        D90  = pi/2;
        D180 = pi;
        D360 = 2*pi;
    end
    
    switch oper
        case 1 % 0/360°
            Y2 = mod(Y,D360);
        case 2 % -180/180°
            Y2 = mod(Y,D360);
            Y2(Y2>D180) = Y2(Y2>D180) - D360;
        case 3 % Desencapsular
            Y2 = unwrap2(Y,D360);
        case {4,5} % Trigonometrico <--> Geometrico
            Y2 = mod(D90-Y,D360);
    end
    
    if opt == 1 % Novo parâmetro
        
        setappdata(handles.window,'tempdata',Y2);
        ShowTemporaryPlot(hObject, eventdata, handles, Y2, get(handles.ylabel,'String'));
        setappdata(handles.window,'func','CircInterv_2');
        
    else % Substituir
        
        button = questdlg({'Deseja substituir o parâmetro?','Os dados originais serão perdidos!'},'Confirmação',...
            'Sim','Não','Não'); drawnow;
        if strcmp(button,'Sim')
            
            DADOS(:,ycol) = Y2;
            
            setappdata(handles.window,'func','none');
            setappdata(handles.window,'tempdata',[]);
            
            HideTemporaryPlot(hObject, eventdata, handles);
            
            setappdata(handles.window,'change',1);
            NewEvent(handles,['Parâmetro ''' get(handles.ylabel,'String') ''' alterado.']);
        end
    end
    
elseif strcmp(func,'CircInterv_2') && ~cancel
    
    name = TrimParamName(get(handles.entry1,'String'),handles.maxparamlength);
    if isempty(name)
        beep; uiwait(errordlg('Nome do parâmetro não pode ser vazio.','Erro','modal')); drawnow;
        return
    end 
    PARAM = InsertParam(PARAM,name);
    CheckRepParam(PARAM,name);
    
    data  = getappdata(handles.window,'tempdata');
    DADOS = [DADOS(:,1:end-1), data, DADOS(:,end)];
    
    if xcol == length(PARAM)-1
        xcol = xcol+1;
    end
    ycol = length(PARAM)-1;
    
    HideTemporaryPlot(hObject, eventdata, handles, xcol, ycol, PARAM);
    setappdata(handles.window,'func','none');
    
    setappdata(handles.window,'change',1);
    NewEvent(handles,['Parâmetro ''' name ''' criado por alteração de intervalo circular.']);
    
elseif cancel
    
    HideTemporaryPlot(hObject, eventdata, handles);
    
end

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function CenterOnSelPt_Callback(hObject, eventdata, handles)
global DADOS
% Centraliza dados no ponto selecionado

PARAM  = get(handles.xlist,'String');
xcol   = get(handles.xlist,'Value');
ycol   = get(handles.ylist,'Value');
func   = getappdata(handles.window,'func');
cancel = getappdata(handles.window,'cancel');
sel    = getappdata(handles.window,'sel');

if isempty(sel)
    beep; uiwait(errordlg('Nenhum ponto selecionado.','Erro','modal')); drawnow;
    return
end

if strcmp(func,'none') && ~cancel
    
    if length(sel) > 1
        button = questdlg({'Mais de um ponto selecionado.','Usar valor médio?'},'Confirmação','Sim','Não','Não'); drawnow;
        if ~strcmp(button,'Sim')
            return
        end
        str = 'Centragem na média dos pontos selecionados:';
    else
        str = 'Centragem no ponto selecionado:';
    end
    
    set(handles.entry1txt,'String','Eixo:');
    set(handles.entry2txt,'String','Opção:');
    set(handles.entry1,'String',{'y','x'},'Value',1);
    set(handles.entry2,'String',{'Novo parâmetro','Substituir atual'},'Value',1);
    
    set([handles.entry1 handles.entry2 handles.entry1txt handles.entry2txt handles.ok_btn handles.cancel_btn],'Visible','on');
    SetFrame(handles,2,str);
    set(handles.menulist,'Enable','off');
    UpdateButtonStatus(hObject, eventdata, handles);
    
    setappdata(handles.window,'func','CenterOnSelPt_1');
    
elseif strcmp(func,'CenterOnSelPt_1') && ~cancel
    
    optaxis = get(handles.entry1,'Value');
    opt = get(handles.entry2,'Value');
    
    if optaxis==1 && opt == 2 && ycol==length(PARAM) || optaxis==2 && opt == 2 && xcol==length(PARAM)
        beep; uiwait(errordlg('Não é possível alterar o parâmetro ''No. OBS.''','Erro','modal')); drawnow;
        return
    end
    
    set(handles.window,'Pointer','watch');
    
    X = DADOS(:,xcol);
    Y = DADOS(:,ycol);
    
    x0 = nanmean(X(sel)); if isnan(x0), x0 = 0; end
    y0 = nanmean(Y(sel)); if isnan(y0), y0 = 0; end
    
    switch optaxis
        case 1 % Centralizar em y
            Y = Y - y0;
        case 2 % Centralizar em x
            X = X - x0;
    end
    
    if opt == 1 % Novo parâmetro
        
        switch optaxis
            case 1 % y
                tempdata = {Y,'y'};
                str = 'y:';
                par = get(handles.ylabel,'String');
            case 2 % x
                tempdata = {X,'x'};
                str = 'x:';
                par = get(handles.xlabel,'String');
        end
        setappdata(handles.window,'tempdata',tempdata);
        ShowTemporaryPlot(hObject, eventdata, handles, NaN*Y, get(handles.ylabel,'String'));
        set(handles.plots(1,2),'XData',X,'YData',Y);
        set(handles.entry1,'String',par);
        set(handles.entry1txt,'String',str);
        if optaxis == 2
            set(handles.graphs,'XLim',get(handles.graph,'XLim')-x0);
        end
        
        setappdata(handles.window,'func','CenterOnSelPt_2');
        
    else % Substituir
        
        button = questdlg({'Deseja substituir o parâmetro?','Os dados originais serão perdidos!'},'Confirmação',...
            'Sim','Não','Não'); drawnow;
        if strcmp(button,'Sim')
            
            switch optaxis
                case 1 % y
                    DADOS(:,ycol) = Y;
                    par = get(handles.ylabel,'String');
                case 2 % x
                    DADOS(:,xcol) = X;
                    par = get(handles.xlabel,'String');
            end
            
            setappdata(handles.window,'func','none');
            setappdata(handles.window,'tempdata',[]);
            
            HideTemporaryPlot(hObject, eventdata, handles);
            if optaxis == 2
                set(handles.graphs,'XLim',get(handles.graph,'XLim')-x0);
            end
            
            setappdata(handles.window,'change',1);
            NewEvent(handles,['Parâmetro ''' par ''' alterado por centragem no(s) ponto(s) selecionado(s).']);
            
            button = questdlg('Deseja renomear o parâmetro?','Opção','Sim','Não','Não'); drawnow;
            if strcmp(button,'Sim')
                RenameParamY_Callback(hObject, eventdata, handles);
            end
            Window_ButtonMotionFcn(hObject, eventdata, handles);
            return
        end
        
    end
    
elseif strcmp(func,'CenterOnSelPt_2') && ~cancel
    
    name = TrimParamName(get(handles.entry1,'String'),handles.maxparamlength);
    if isempty(name)
        beep; uiwait(errordlg('Nome do parâmetro não pode ser vazio.','Erro','modal')); drawnow;
        return
    end                
    PARAM = InsertParam(PARAM,name);
    CheckRepParam(PARAM,name);
    
    tempdata = getappdata(handles.window,'tempdata');
    data = tempdata{1};
    opt  = tempdata{2};
    DADOS = [DADOS(:,1:end-1), data, DADOS(:,end)];
    
    switch opt
        case 'y'
            ycol = size(DADOS,2)-1;
            if xcol >= ycol;
                xcol = xcol+1;
            end
        case 'x'
            xcol = size(DADOS,2)-1;
            if ycol >= xcol;
                ycol = ycol+1;
            end
    end
    
    HideTemporaryPlot(hObject, eventdata, handles, xcol, ycol, PARAM);
    setappdata(handles.window,'func','none');
    
    setappdata(handles.window,'change',1);
    NewEvent(handles,['Parâmetro ''' name ''' criado por centragem no(s) ponto(s) selecionado(s).']);
    
elseif cancel
    
    HideTemporaryPlot(hObject, eventdata, handles);
    
end

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function Anemometry_Callback(hObject, eventdata, handles)
global DADOS
% Conversões anemometricas

PARAM  = get(handles.xlist,'String');
xcol   = get(handles.xlist,'Value');
ycol   = get(handles.ylist,'Value');
func   = getappdata(handles.window,'func');
cancel = getappdata(handles.window,'cancel');

if strcmp(func,'none') && ~cancel
    
    convlist = {...
            ' pa --> Zp'         , ' Zp --> pa'    ,                   ...
            ' qc --> Vc'         , ' Vc --> qc'    ,                   ...
            ' qc, pa --> M'      , ' M --> qc/pa'  ,                   ...
            ' Zp --> Ta'         , ' Ta --> Zp'    , ' Zp, Ta --> ro', ...
            ' Zp, Vc --> M'      , ' Zp, M --> Vc' , ' Vc, M --> Zp' , ...
            ' M, Ta --> Va'      , ' Va, M --> Ta' ,                   ...
            ' qc, pa --> Ve'     , ' Zp, Vc --> Ve',                   ...
            ' Zp, QNH --> Zp adj', ' Zp, Z --> QNH'};
    
    set(handles.entry1txt,'String','Oper.:');
    set(handles.entry1,'String',convlist,'Value',1);
    set(handles.entry2,'Style','edit','String','0');
    set(handles.entries(3:4),'String',PARAM,'Value',ycol);
    
    set([handles.entry1 handles.entry1txt handles.ok_btn handles.cancel_btn],'Visible','on');
    SetFrame(handles,1,'Indique os parâmetros para conversão anemométrica:');
    set([handles.menulist handles.xlist handles.ylist],'Enable','off');
    UpdateButtonStatus(hObject, eventdata, handles);
    
    setappdata(handles.window,'func','Anemometry_1');
    entry1_Callback(hObject, eventdata, handles);
    entry4_Callback(hObject, eventdata, handles);
    entry3_Callback(hObject, eventdata, handles);
    
elseif strcmp(func,'Anemometry_1') && ~cancel
    
    oper   = get(handles.entry1,'Value');
    auxpar = str2double(get(handles.entry2,'String'));
    npar1  = get(handles.entry3,'Value');
    npar2  = get(handles.entry4,'Value');
    
    if isnan(auxpar)
        beep; uiwait(errordlg('Parâmetro de entrada incoerente.','Erro','modal')); drawnow;
        Window_ButtonMotionFcn(hObject, eventdata, handles);
        return
    end
    
    %        1          2         3         4         5      6       7         8         9            10     11        12         13        14        15        16        17                 18
    outpar={'Zp (ft)'  'pa (mb)' 'Vc (kt)' 'qc (mb)' 'Mach' 'qc/pa' 'Ta (°C)' 'Zp (ft)' 'ro (kg/m³)' 'Mach' 'Vc (kt)' 'Zp (ft)'  'Va (kt)' 'Ta (°C)' 'Ve (kt)' 'Ve (kt)' 'Zp ajustada (ft)' 'QNH (mb)';...
            'Zpb (ft)' 'pb (mb)' 'Vb (kt)' 'qb (mb)' 'Mb'   'qb/pb' '       ' '       ' ''           'Mb'   'Vb (kt)' 'Zpb (ft)' '       ' '       ' '       ' '       ' '                ' '        '};
    
    set(handles.window,'Pointer','watch');
    
    % Restrictions:
    %  1 pa2zp:   pa > 0
    %  2 zp2pa:   -
    %  3 qc2vc:   -
    %  4 vc2qc:   -
    %  5 qcpa2m:  pa > 0
    %  6 m2qcpa:  -
    %  7 zp2ta:   -
    %  8 ta2zp:   -
    %  9 zpta2ro:  -
    % 10 zpvc2m:  -
    % 11 zpm2vc:  -
    % 12 vcm2zp:  M > 0 & Vc > 0
    % 13 mta2va:  M > 0 
    % 14 vam2ta:  M > 0 
    % 15 qcpa2ve: pa > 0
    % 16 zpvc2ve: -
    % 17 zp2zpaj: -
    % 18 zpz2qnh: -

    try
        switch oper                                       
            case 1  % pa->Zp
                pa = DADOS(:,npar1);
                if any(pa <= 0)
                    uiwait(warndlg({'Encontrados pontos de ''pa'' menores ou iguais a zero.',...
                            'Os pontos resultantes serão invalidados (NaN).'},'Aviso','modal')); drawnow;
                    pa(pa <= 0) = NaN;
                end
                Y = pa2zp(pa);
                
            case 2  % Zp->pa
                Y = zp2pa(DADOS(:,npar1));
                
            case 3  % qc->Vc
                Y = qc2vc(DADOS(:,npar1));
                
            case 4  % Vc->qc
                Y = vc2qc(DADOS(:,npar1));
                
            case 5  % qc,pa->M
                pa = DADOS(:,npar2);
                if any(pa <= 0)
                    uiwait(warndlg({'Encontrados pontos de ''pa'' menores ou iguais a zero.',...
                            'Os pontos resultantes serão invalidados (NaN).'},'Aviso','modal')); drawnow;
                    pa(pa <= 0) = NaN;
                end
                Y = qcpa2m(DADOS(:,npar1), pa);
                
            case 6  % M->qc/pa
                Y = m2qcpa(DADOS(:,npar1));
                
            case 7  % Zp->Ta
                DISA = auxpar;
                Y = zp2ta(DADOS(:,npar1)) - 273.15 + DISA;
                
            case 8  % Ta->Zp
                DISA = auxpar;
                Y = ta2zp(DADOS(:,npar1)  + 273.15 - DISA);
                
            case 9 % Zp, Ta -> ro
                Y = 100*zp2pa(DADOS(:,npar1))./(287.053*(DADOS(:,npar2)+273.15));
                
            case 10  % Zp,Vc->M
                Y = qcpa2m(vc2qc(DADOS(:,npar2)), zp2pa(DADOS(:,npar1)));
                
            case 11 % Zp,M->Vc
                Y = qc2vc(m2qcpa(DADOS(:,npar2)) .* zp2pa(DADOS(:,npar1)));
                
            case 12 % Vc,M->Zp
                Vc = DADOS(:,npar1);
                if any(Vc <= 0)
                    uiwait(warndlg({'Encontrados pontos de ''Vc'' menores ou iguais a zero.',...
                            'Os pontos resultantes serão invalidados (NaN).'},'Aviso','modal')); drawnow;
                    Vc(Vc <= 0) = NaN;
                end
                M = DADOS(:,npar2);
                if any(M <= 0)
                    uiwait(warndlg({'Encontrados pontos de ''Mach'' menores ou iguais a zero.',...
                            'Os pontos resultantes serão invalidados (NaN).'},'Aviso','modal')); drawnow;
                    M(M <= 0) = NaN;
                end
                Y = pa2zp(vc2qc(Vc) ./ m2qcpa(M));
                
            case 13 % M,Ta->Va
                M  = DADOS(:,npar1);
                Ta = DADOS(:,npar2) + 273.15;
                if any(M <= 0)
                    uiwait(warndlg({'Encontrados pontos de ''Mach'' menores ou iguais a zero.',...
                            'Os pontos resultantes serão invalidados (NaN).'},'Aviso','modal')); drawnow;
                    M(M <= 0) = NaN;
                end
                Y = M.*sqrt(Ta*1.4*287.053)*3600/1852;
                
            case 14 % Va,M->Ta
                Va = DADOS(:,npar1);
                M  = DADOS(:,npar2);
                if any(M <= 0)
                    uiwait(warndlg({'Encontrados pontos de ''Mach'' menores ou iguais a zero.',...
                            'Os pontos resultantes serão invalidados (NaN).'},'Aviso','modal')); drawnow;
                    M(M <= 0) = NaN;
                end
                Y = (Va*1852/3600./M).^2 / (1.4*287.053) - 273.15;
                
            case 15 % qc,pa->Ve
                qc = DADOS(:,npar1);
                pa = DADOS(:,npar2);
                if any(pa <= 0)
                    uiwait(warndlg({'Encontrados pontos de ''pa'' menores ou iguais a zero.',...
                            'Os pontos resultantes serão invalidados (NaN).'},'Aviso','modal')); drawnow;
                    pa(pa <= 0) = NaN;
                end
                M = qcpa2m(qc,pa);
                Y = M.* sqrt( 1.4*pa*100 / 1.225 ) * 3600/1852;
                
            case 16 % Zp,Vc->Ve
                qc = vc2qc(DADOS(:,npar2));
                pa = zp2pa(DADOS(:,npar1));
                M = qcpa2m(qc,pa);
                Y = M.* sqrt( 1.4*pa*100 / 1.225 ) * 3600/1852;
                
            case 17 % Zp,qnh->Zp aj
                QHN = auxpar;
                pa = zp2pa(DADOS(:,npar1));
                Y = pa2zp(pa*1013.25/QHN);
                
            case 18 % Zp,Z->qnh
                Y = zpz2qnh(DADOS(:,npar1),DADOS(:,npar2));

        end
        
    catch
        beep; uiwait(errordlg(lasterr,'Erro','modal')); drawnow;
        Window_ButtonMotionFcn(hObject, eventdata, handles);
        return
    end
    
    if any(oper==[1:6 10:12])
        button = questdlg('Valores de entrada são básicos ou calibrados?','Confirmação','Básicos','Calibrados','Básicos'); drawnow;
    else
        button = 'Calibrados';
    end
    if strcmp(button,'Calibrados');
        ncal = 1;
    else
        ncal = 2;
    end
    
    setappdata(handles.window,'tempdata',Y);
    
    MultiParamOperation_setgraph(hObject, eventdata, handles, 0, 0);
    ShowTemporaryPlot(hObject, eventdata, handles, Y, outpar{ncal,oper});
    
    setappdata(handles.window,'func','Anemometry_2');
    
elseif strcmp(func,'Anemometry_2') && ~cancel
    
    name = TrimParamName(get(handles.entry1,'String'),handles.maxparamlength);
    if isempty(name)
        beep; uiwait(errordlg('Nome do parâmetro não pode ser vazio.','Erro','modal')); drawnow;
        return
    end 
    PARAM = InsertParam(PARAM,name);
    CheckRepParam(PARAM,name);
    
    data  = getappdata(handles.window,'tempdata');
    DADOS = [DADOS(:,1:end-1), data, DADOS(:,end)];
    
    if xcol == length(PARAM)-1
        xcol = xcol+1;
    end
    ycol = length(PARAM)-1;
    
    HideTemporaryPlot(hObject, eventdata, handles, xcol, ycol, PARAM);
    setappdata(handles.window,'func','none');
    
    setappdata(handles.window,'change',1);
    NewEvent(handles,['Parâmetro ''' name ''' criado por conversão anemométrica.']);
    
elseif cancel
    
    MultiParamOperation_setgraph(hObject, eventdata, handles, 0, 0);
    HideTemporaryPlot(hObject, eventdata, handles);
    
end

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function UnitsConversion_Callback(hObject, eventdata, handles)
global DADOS
% Conversao de unidades

PARAM  = get(handles.xlist,'String');
ycol   = get(handles.ylist,'Value');
xcol   = get(handles.xlist,'Value');
func   = getappdata(handles.window,'func');
cancel = getappdata(handles.window,'cancel');

if strcmp(func,'none') && ~cancel
    
    [typelist, convlist] = getconvlist;
    
    set(handles.entry1txt,'String','Dimens.:');
    set(handles.entry2txt,'String','Opção:');
    set(handles.entry3txt,'String','De:');
    set(handles.entry4txt,'String','Para:');
    set(handles.entry1,'String',typelist,'Value',1);
    set(handles.entry2,'String',{'Novo parâmetro','Substituir atual'},'Value',1);
    set(handles.entries(3:4),'String',convlist{1}(:,1),'Value',1);
    
    set([handles.entries handles.entriestxt handles.ok_btn handles.cancel_btn],'Visible','on');
    SetFrame(handles,2,'Conversão de unidades do parâmetro y:');
    set([handles.menulist handles.xlist],'Enable','off');
    UpdateButtonStatus(hObject, eventdata, handles);
    
    setappdata(handles.window,'tempdata',convlist);
    setappdata(handles.window,'func','UnitsConversion_1');
    
elseif strcmp(func,'UnitsConversion_1') && ~cancel
    
    set(handles.window,'Pointer','watch');
    
    Y     = DADOS(:,ycol);
    ntype = get(handles.entry1,'Value');
    opt   = get(handles.entry2,'Value');
    nu1   = get(handles.entry3,'Value');
    nu2   = get(handles.entry4,'Value');
    
    if ycol == length(PARAM) && opt == 2
        beep; uiwait(errordlg('Não é possível alterar o parâmetro ''No. OBS.''','Erro','modal')); drawnow;
        return
    end
    
    convlist = getappdata(handles.window,'tempdata');
    k1 = convlist{ntype}{nu1,2};
    k2 = convlist{ntype}{nu2,2};
    b1 = convlist{ntype}{nu1,3};
    b2 = convlist{ntype}{nu2,3};
    
    Y2 = ( k1*Y + b1 - b2 ) / k2;
    
    switch opt
        case 1 % Novo parâmetro
            
            setappdata(handles.window,'tempdata',{Y2,'new'});
            setappdata(handles.window,'func','UnitsConversion_2');
            
        case 2 % Substituir
            
            button = questdlg({'Deseja substituir o parâmetro?','Os dados originais serão perdidos!'},'Confirmação',...
                'Sim','Não','Não'); drawnow;
            if strcmp(button,'Sim')
                setappdata(handles.window,'tempdata',{Y2,'replace'});
                setappdata(handles.window,'func','UnitsConversion_2');
            else
                Window_ButtonMotionFcn(hObject, eventdata, handles);
                return
            end
    end
    
    unit1 = convlist{ntype}{nu1,1};
    unit2 = convlist{ntype}{nu2,1};
    
    newname = unitrep(get(handles.ylabel,'String'),unit1,unit2);
    
    ShowTemporaryPlot(hObject, eventdata, handles, Y2, newname);
    if opt == 2
        set(handles.frametxt,'String','Defina o novo nome do parâmetro:');
    end
    
elseif strcmp(func,'UnitsConversion_2') && ~cancel
    
    name = TrimParamName(get(handles.entry1,'String'),handles.maxparamlength);
    if isempty(name)
        beep; uiwait(errordlg('Nome do parâmetro não pode ser vazio.','Erro','modal')); drawnow;
        return
    end 
    
    tempdata = getappdata(handles.window,'tempdata');
    data = tempdata{1};
    opt  = tempdata{2};
    
    switch opt
        case 'new'
            DADOS = [DADOS(:,1:end-1), data, DADOS(:,end)];
            PARAM = InsertParam(PARAM,name);
            NewEvent(handles,['Parâmetro ''' name ''' criado por conversão de unidades.']);
            ycol = size(DADOS,2)-1;
            if xcol >= ycol;
                xcol = xcol+1;
            end
        case 'replace'
            DADOS(:,ycol) = data;
            oldname = denumber(PARAM{ycol});
            PARAM{ycol} = strrep(PARAM{ycol}, oldname, name);
            NewEvent(handles,['Parâmetro ''' oldname ''' convertido para ''' name '''.']);
    end
    CheckRepParam(PARAM,name);
    
    HideTemporaryPlot(hObject, eventdata, handles, xcol, ycol, PARAM);
    
    setappdata(handles.window,'change',1);
    setappdata(handles.window,'func','none');
    
elseif cancel
    
    HideTemporaryPlot(hObject, eventdata, handles);
    
end

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function UnitsConversionGroup_Callback(hObject, eventdata, handles)
% Conversao de um grupo de unidades

oldPARAM = get(handles.xlist,'String');

reftime  = getappdata(handles.window,'reftime');
nreftime = findpar(oldPARAM,reftime,0,1);

togglelist = setdiff(findobj(handles.window,'Enable','on'),findobj(handles.window,'Style','text'));
set(togglelist,'Enable','off');
UpdateButtonStatus(hObject, eventdata, handles);

[PARAM, Nout] = RDAT_UnitConv(oldPARAM,handles.maxparamlength);

set(togglelist,'Enable','on');
UpdateButtonStatus(hObject, eventdata, handles);

if ~isempty(PARAM)
    new = length(PARAM) - length(oldPARAM);
    
    if  new % Acrescentar
        if new == 1
            NewEvent(handles,['Parâmetro ''' denumber(PARAM{Nout}) ''' criado por conversão de unidades.']);
        else
            NewEvent(handles,[num2str(new) ' parâmetros criados por conversão de unidades.']);
        end
        
    else % Substituir
        if length(Nout) == 1
            NewEvent(handles,['Parâmetro ''' denumber(oldPARAM{Nout}) ''' convertido para ''' denumber(PARAM{Nout}) '''.']);
        else
            NewEvent(handles,['Unidade de ' num2str(length(Nout)) ' parâmetros convertida.']);
        end
    end
    
    xcol = get(handles.xlist,'Value');
    ycol = get(handles.ylist,'Value');
    if xcol == length(oldPARAM)
        xcol = length(PARAM);
    end
    if ycol == length(oldPARAM)
        ycol = length(PARAM);
    end
    
    set(handles.xlist,'String',PARAM,'Value',xcol);
    set(handles.ylist,'String',PARAM,'Value',ycol);
    
    if ~isempty(nreftime)
        newreftime = denumber(PARAM{nreftime});
        if ~strcmp(reftime,newreftime);
            reftime = newreftime;
            setappdata(handles.window,'reftime',reftime);
            UpdateTimeCols(hObject, eventdata, handles);
        end
    end
    
    UpdatePlot(hObject, eventdata, handles, ycol, xcol);
    setappdata(handles.window,'change',1);
end

% --------------------------------------------------------------------
function ElementaryOperation_Callback(hObject, eventdata, handles)
global DADOS
% Operação matematica elementar com um parâmetro

PARAM  = get(handles.xlist,'String');
xcol   = get(handles.xlist,'Value');
ycol   = get(handles.ylist,'Value');
sel    = getappdata(handles.window,'sel');
func   = getappdata(handles.window,'func');
cancel = getappdata(handles.window,'cancel');

if strcmp(func,'none') && ~cancel
    
    set(handles.entry1txt,'String','Tipo:');
    set(handles.entry2txt,'String','Oper.:');
    set(handles.entry3txt,'String','Em:');
    set(handles.entry4txt,'String','Opção:');
    set(handles.entry1,'String',{'Exponenciação','Arredondamento','Estatística','Trigonometria (grau)','Trigonometria (rad)','Trig. hiperbólica','Lógica','Variação'},'Value',1);
    set(handles.entry2,'String','');
    set(handles.entry3,'String',{'Tudo','Intervalo','Seleção'},'Value',1);
    set(handles.entry4,'String',{'Novo parâmetro','Substituir atual'},'Value',1);
    
    set([handles.entries handles.entriestxt handles.ok_btn handles.cancel_btn],'Visible','on');
    SetFrame(handles,2,'Operação matemática elementar:');
    set([handles.menulist handles.xlist],'Enable','off');
    UpdateButtonStatus(hObject, eventdata, handles);
    
    setappdata(handles.window,'func','ElementaryOperation_1');
    
    entry1_Callback(hObject, eventdata, handles);
    
elseif strcmp(func,'ElementaryOperation_1') && ~cancel
    
    set(handles.window,'Pointer','watch');
    
    Y = DADOS(:,ycol);
    grp  = get(handles.entry1,'Value');
    oper = get(handles.entry2,'Value');
    opt  = get(handles.entry3,'Value');
    
    if ycol == length(PARAM) && get(handles.entry4,'Value') == 2
        beep; uiwait(errordlg('Não é possível alterar o parâmetro ''No. OBS.''','Erro','modal')); drawnow;
        return
    end
    
    switch opt
        case 1 % Tudo
            pts = (1:size(DADOS,1))';
        case 2 % Intervalo
            pts = GetIntervPts(handles);
            if isempty(pts)
                beep; uiwait(errordlg('Não há pontos no intervalo selecionado.','Erro','modal')); drawnow;
                Window_ButtonMotionFcn(hObject, eventdata, handles);
                return
            end
        case 3 % Seleção
            pts = sel;
            if isempty(pts)
                beep; uiwait(errordlg('Não há pontos selecionados.','Erro','modal')); drawnow;
                Window_ButtonMotionFcn(hObject, eventdata, handles);
                return
            end
    end
    
    if all(isnan(Y(pts)))
        beep; uiwait(errordlg('Não há pontos válidos para a operação.','Erro','modal')); drawnow;
        Window_ButtonMotionFcn(hObject, eventdata, handles);
        return
    end
    
    %  # Operação                  Restrições
    
    %  Exponenciação -----------------------------
    %  1 Quadrado                  -
    %  2 Cubo                      -
    %  3 Exponencial natural       -
    %  4 Raiz quadrada             y >= 0
    %  5 Raiz cúbica               y >= 0
    %  6 Logaritmo natural         y > 0
    %  7 Logaritmo base 2          y > 0
    %  8 Logaritmo base 10         y > 0
    %  9 Inverso                   y ~= 0
    
    %  Arredondamento ----------------------------
    %  1 Arredondar                -
    %  2 Arredondar para cima      -
    %  3 Arredondar para baixo     -
    %  4 Truncar                   -
    %  5 Módulo                    -
    %  6 Zerar negativos           -
    %  7 Sinal                     -
    
    %  Estatística -------------------------------
    %  1 Média                     -
    %  2 Desvio padrão             -
    %  3 Máximo                    -
    %  4 Mínimo                    -
    %  5 Amplitude                 -
    %  6 Variação                  -
    %  7 Variância                 -
    %  8 Mediana                   -
    %  9 Diferenças                -
    % 10 Oposto                    -
    
    %  Trigonometria -----------------------------
    %  1 Seno                      -
    %  2 Cosseno                   -
    %  3 Tangente                  y ~= ±90º
    %  4 Secante                   y ~= ±90º
    %  5 Cossecante                y ~= 0, ±180º
    %  6 Cotangente                y ~= 0, ±180º
    %  7 Arco seno                -1 <= y <= 1
    %  8 Arco cosseno             -1 <= y <= 1
    %  9 Arco tangente             -
    % 10 Arco secante              y <= -1, y >= 1
    % 11 Arco cossecante           y <= -1, y >= 1
    % 12 Arco cotangente           -
    
    %  Trig. hiperbólica -------------------------
    %  1 Seno hiperbólico          -
    %  2 Cosseno hiperbólico       -
    %  3 Tangente hiperbólica      -
    %  4 Secante hiperbólica       -
    %  5 Cossecante hiperbólica    y ~= 0
    %  6 Cotangente hiperbólica    y ~= 0
    %  7 Inv. seno hiperbólico     -
    %  8 Inv. cosseno hiperb.      y >= 1
    %  9 Inv. tangente hiperb.    -1 < y < 1
    % 10 Inv. secante hiperb.      0 < y <= 1
    % 11 Inv. cossec. hiperb.      y ~= 0
    % 12 Inv. cotang. hiperb.      y < -1, y > 1
    
    %  Lógica ------------------------------------
    %  1 Não                       y ~= NaN
    
    %  Variação ----------------------------------
    %  1 Nunca diminuir            -
    %  2 Nunca aumentar            -
    
    % Cheque de validade
    if grp == 1 % Exponenciação
        
        if (oper == 4 || oper == 5) && any(Y(pts)<0)
            uiwait(warndlg({'Encontrados valores menores que zero no parâmetro y.',...
                    'Valores resultantes serão invalidados (NaN).'},'Aviso','modal')); drawnow;
            Y(Y(pts)<0) = NaN;
        end
        if (oper == 6 || oper == 7 || oper == 8) && any(Y(pts)<=0)
            uiwait(warndlg({'Encontrados valores menores ou iguais a zero no parâmetro y.',...
                    'Valores resultantes serão invalidados (NaN).'},'Aviso','modal')); drawnow;
            Y(Y(pts)<=0) = NaN;
        end
        if oper == 9 && any(Y(pts)==0)
            uiwait(warndlg({'Encontrados valores iguais a zero no parâmetro y.',...
                    'Valores resultantes serão invalidados (NaN).'},'Aviso','modal')); drawnow;
            Y(Y(pts)==0) = NaN;
        end

    elseif grp == 4 || grp == 5 % Trigonometria
        
        if any(oper == [1 2 3 4 5 6])
            if grp == 4
                Y(pts) = Y(pts)*pi/180; % deg -> rad
            end
            Y(pts) = mod(Y(pts),2*pi); % 0/360°
        end
        
        if ( oper == 3 || oper == 4 ) && ( any(Y(pts)==pi/2) || any(Y(pts)==3*pi/2) )
            uiwait(warndlg({'Encontrados valores iguais a ±90° no parâmetro y.',...
                    'Valores resultantes serão invalidados (NaN).'},'Aviso','modal')); drawnow;
            Y(Y(pts)==pi/2)   = NaN;
            Y(Y(pts)==3*pi/2) = NaN;
        end
        if ( oper == 5 || oper == 6 ) && ( any(Y(pts)==0) || any(Y(pts)==pi) )
            uiwait(warndlg({'Encontrados valores iguais a 0 ou ±180° no parâmetro y.',...
                    'Valores resultantes serão invalidados (NaN).'},'Aviso','modal')); drawnow;
            Y(Y(pts)==0)  = NaN;
            Y(Y(pts)==pi) = NaN;
        end
        if ( oper == 7 || oper == 8 ) && ( any(Y(pts)<-1) || any(Y(pts)>1) )
            uiwait(warndlg({'Encontrados valores fora do intervalo [-1, 1] no parâmetro y.',...
                    'Valores resultantes serão invalidados (NaN).'},'Aviso','modal')); drawnow;
            Y(Y(pts)<-1) = NaN;
            Y(Y(pts)>1)  = NaN;
        end
        if ( oper == 10 || oper == 11 ) && any(Y(pts)>-1 & Y(pts)<1)
            uiwait(warndlg({'Encontrados valores dentro do intervalo [-1, 1] no parâmetro y.',...
                    'Valores resultantes serão invalidados (NaN).'},'Aviso','modal')); drawnow;
            Y(Y(pts)>-1 & Y(pts)<1) = NaN;
        end
        if oper == 12 && any(Y(pts)==0)
            Y(Y(pts)==0) = 1e-16;
        end

    elseif grp == 6 % Trigonometria hiperbolica
        
        if ( oper == 5 || oper == 6 || oper == 11 ) && any(Y(pts)==0)
            uiwait(warndlg({'Encontrados valores iguais a zero no parâmetro y.',...
                    'Valores resultantes serão invalidados (NaN).'},'Aviso','modal')); drawnow;
            Y(Y(pts)==0) = NaN;
        end
        if oper == 8 && any(Y(pts)<1)
            uiwait(warndlg({'Encontrados valores menores que um no parâmetro y.',...
                    'Valores resultantes serão invalidados (NaN).'},'Aviso','modal')); drawnow;
            Y(Y(pts)<1) = NaN;
        end
        if oper == 9 && ( any(Y(pts)<=-1) || any(Y(pts)>=1) )
            uiwait(warndlg({'Encontrados valores fora do intervalo ]-1, 1[ no parâmetro y.',...
                    'Valores resultantes serão invalidados (NaN).'},'Aviso','modal')); drawnow;
            Y(Y(pts)<=-1) = NaN;
            Y(Y(pts)>=1)  = NaN;
        end
        if oper == 10 && ( any(Y(pts)<=0) || any(Y(pts)>1) )
            uiwait(warndlg({'Encontrados valores fora do intervalo ]0, 1] no parâmetro y.',...
                    'Valores resultantes serão invalidados (NaN).'},'Aviso','modal')); drawnow;
            Y(Y(pts)<=0) = NaN;
            Y(Y(pts)>1)  = NaN;
        end
        if oper == 12 && any(Y(pts)>=-1 & Y(pts)<=1)
            uiwait(warndlg({'Encontrados valores dentro do intervalo ]-1, 1[ no parâmetro y.',...
                    'Valores resultantes serão invalidados (NaN).'},'Aviso','modal')); drawnow;
            Y(Y(pts)>=-1 & Y(pts)<=1) = NaN;
        end
        
    end
    
    % Calculo
    if grp == 1 % Exponenciação
        
        switch oper
            case 1
                Y(pts) = Y(pts).^2;
            case 2
                Y(pts) = Y(pts).^3;
            case 3
                Y(pts) = exp(Y(pts));
            case 4
                Y(pts) = sqrt(Y(pts));
            case 5
                Y(pts) = Y(pts).^(1/3);
            case 6
                Y(pts) = log(Y(pts));
            case 7
                Y(pts) = log2(Y(pts));
            case 8
                Y(pts) = log10(Y(pts));
            case 9
                Y(pts) = 1./Y(pts);
        end
        
    elseif grp == 2 % Arredondamento
        
        switch oper
            case 1
                Y(pts) = round(Y(pts));
            case 2
                Y(pts) = ceil(Y(pts));
            case 3
                Y(pts) = floor(Y(pts));
            case 4
                Y(pts) = fix(Y(pts));
            case 5
                Y(pts) = abs(Y(pts));
            case 6
                Y(pts) = max(0,Y(pts));
            case 7
                Y(pts) = sign(Y(pts));
        end
        
    elseif grp == 3 % Estatistica
        
        nnan = find(isnan(Y));
        
        switch oper
            case 1
                Y(pts) = nanmean(Y(pts));
            case 2
                Y(pts) = nanstd(Y(pts));
            case 3
                Y(pts) = max(Y(pts));
            case 4
                Y(pts) = min(Y(pts));
            case 5
                Y(pts) = max(Y(pts))-min(Y(pts));
            case 6
                Y2 = Y(pts);
                Y2(isnan(Y2)) = [];
                Y(pts) = Y2(end)-Y2(1);
            case 7
                Y2 = Y(pts);
                Y2(isnan(Y2)) = [];
                Y(pts) = var(Y2);
            case 8
                Y(pts) = nanmedian(Y(pts));
            case 9
                if length(pts) > 1
                    Y(pts) = [diff(Y(pts)); NaN];
                else
                    Y(pts) = 0;
                end
            case 10
                Y(pts) = -Y(pts);
        end
        
        Y(nnan) = NaN;
        
    elseif grp == 4 || grp == 5 % Trigonometria
        
        switch oper
            case 1
                Y(pts) = sin(Y(pts));
            case 2
                Y(pts) = cos(Y(pts));
            case 3
                Y(pts) = tan(Y(pts));
            case 4
                Y(pts) = sec(Y(pts));
            case 5
                Y(pts) = csc(Y(pts));
            case 6
                Y(pts) = cot(Y(pts));
            case 7
                Y(pts) = asin(Y(pts));
            case 8
                Y(pts) = acos(Y(pts));
            case 9
                Y(pts) = atan(Y(pts));
            case 10
                Y(pts) = asec(Y(pts));
            case 11
                Y(pts) = acsc(Y(pts));
            case 12
                Y(pts) = acot(Y(pts));
        end
        
        if grp == 4
            if any(oper == [7 8 9 10 11 12])
                Y(pts) = Y(pts)*180/pi; % rad -> deg
            end
        end
        
    elseif grp == 6 % Trigonometria hiperbolica
        
        switch oper
            case 1
                Y(pts) = sinh(Y(pts));
            case 2
                Y(pts) = cosh(Y(pts));
            case 3
                Y(pts) = tanh(Y(pts));
            case 4
                Y(pts) = sech(Y(pts));
            case 5
                Y(pts) = csch(Y(pts));
            case 6
                Y(pts) = coth(Y(pts));
            case 7
                Y(pts) = asinh(Y(pts));
            case 8
                Y(pts) = acosh(Y(pts));
            case 9
                Y(pts) = atanh(Y(pts));
            case 10
                Y(pts) = asech(Y(pts));
            case 11
                Y(pts) = acsch(Y(pts));
            case 12
                Y(pts) = acoth(Y(pts));
        end
        
    elseif grp == 7 % Logica
        
        nnan = find(isnan(Y));                
        Y = nan2zero(Y);
        
        switch oper
            case 1
                Y(pts) = ~Y(pts);
        end
        
        Y(nnan) = NaN;
        
    elseif grp == 8 % Variação
        
        switch oper
            case 1
                for n = 2:length(pts)
                    if Y(pts(n)) < Y(pts(n-1))
                        Y(pts(n)) = Y(pts(n-1));
                    end
                end
            case 2
                for n = 2:length(pts)
                    if Y(pts(n)) > Y(pts(n-1))
                        Y(pts(n)) = Y(pts(n-1));
                    end
                end
        end
        
    end
    
    if get(handles.entry4,'Value') == 1 % Novo parâmetro
        
        setappdata(handles.window,'tempdata',Y);
        ShowTemporaryPlot(hObject, eventdata, handles, Y, get(handles.ylabel,'String'));
        
        setappdata(handles.window,'func','OneParamOperation_2');
        
    else % Substituir
        
        button = questdlg({'Deseja substituir o parâmetro?','Os dados originais serão perdidos!'},'Confirmação',...
            'Sim','Não','Não'); drawnow;
        if strcmp(button,'Sim')
            
            DADOS(:,ycol) = Y;
            
            setappdata(handles.window,'func','none');
            setappdata(handles.window,'tempdata',[]);
            
            HideTemporaryPlot(hObject, eventdata, handles);
            
            setappdata(handles.window,'change',1);
            NewEvent(handles,['Parâmetro ''' get(handles.ylabel,'String') ''' alterado por operação matemática.']);
            
            button = questdlg('Deseja renomear o parâmetro?','Opção','Sim','Não','Não'); drawnow;
            if strcmp(button,'Sim')
                RenameParamY_Callback(hObject, eventdata, handles);
            end
            Window_ButtonMotionFcn(hObject, eventdata, handles);
            return
        end
        
    end
    
elseif strcmp(func,'ElementaryOperation_2') && ~cancel
    
    name = TrimParamName(get(handles.entry1,'String'),handles.maxparamlength);
    if isempty(name)
        beep; uiwait(errordlg('Nome do parâmetro não pode ser vazio.','Erro','modal')); drawnow;
        return
    end 
    PARAM = InsertParam(PARAM,name);
    CheckRepParam(PARAM,name);
    
    data  = getappdata(handles.window,'tempdata');
    DADOS = [DADOS(:,1:end-1), data, DADOS(:,end)];
    
    if xcol == length(PARAM)-1
        xcol = xcol+1;
    end
    ycol = length(PARAM)-1;
    
    HideTemporaryPlot(hObject, eventdata, handles, xcol, ycol, PARAM);
    setappdata(handles.window,'func','none');
    
    setappdata(handles.window,'change',1);
    NewEvent(handles,['Parâmetro ''' name ''' criado por operação matemática elementar.']);
    
elseif cancel
    
    HideTemporaryPlot(hObject, eventdata, handles);
    
end

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function OneParamOperation_Callback(hObject, eventdata, handles)
global DADOS
% Operação matematica com um parâmetro e uma constante

PARAM  = get(handles.xlist,'String');
xcol   = get(handles.xlist,'Value');
ycol   = get(handles.ylist,'Value');
sel    = getappdata(handles.window,'sel');
func   = getappdata(handles.window,'func');
cancel = getappdata(handles.window,'cancel');

if strcmp(func,'none') && ~cancel
    
    set(handles.entry1txt,'String','Oper.:');
    set(handles.entry2txt,'String','k:');
    set(handles.entry3txt,'String','Em:');
    set(handles.entry4txt,'String','Opção:');
    set(handles.entry1,'String',{' y + k',' y - k',' k - y',' y * k',' y / k',' k / y',' y ^ k',' k ^ y',' y ^ 1/k',' k ^ 1/y',...
            ' log k (y)',' log y (k)',' y > k',' y < k',' y >= k',' y <= k',' y == k',' y ~= k'},'Value',1);
    set(handles.entry2,'Style','edit','String','');
    set(handles.entry3,'String',{'Tudo','Intervalo','Seleção'},'Value',1);
    set(handles.entry4,'String',{'Novo parâmetro','Substituir atual'},'Value',1);
    
    set([handles.entries handles.entriestxt handles.ok_btn handles.cancel_btn],'Visible','on');
    SetFrame(handles,2,'Operação matemática com um parâmetro e uma constante:');
    set([handles.menulist handles.xlist],'Enable','off');
    UpdateButtonStatus(hObject, eventdata, handles);
    
    setappdata(handles.window,'func','OneParamOperation_1');
    
elseif strcmp(func,'OneParamOperation_1') && ~cancel
    
    set(handles.window,'Pointer','watch');
    
    Y = DADOS(:,ycol);
    oper = get(handles.entry1,'Value');
    K = str2double(get(handles.entry2,'String'));
    opt = get(handles.entry3,'Value');
    
    if isnan(K)
        beep; uiwait(errordlg('Parâmetro de entrada incoerente.','Erro','modal')); drawnow;
        Window_ButtonMotionFcn(hObject, eventdata, handles);
        return
    end
    
    if ycol == length(PARAM) && get(handles.entry4,'Value') == 2
        beep; uiwait(errordlg('Não é possível alterar o parâmetro ''No. OBS.''','Erro','modal')); drawnow;
        return
    end
    
    switch opt
        case 1 % Tudo
            pts = (1:size(DADOS,1))';
        case 2 % Intervalo
            pts = GetIntervPts(handles);
            if isempty(pts)
                beep; uiwait(errordlg('Não há pontos no intervalo selecionado.','Erro','modal')); drawnow;
                Window_ButtonMotionFcn(hObject, eventdata, handles);
                return
            end
        case 3 % Seleção
            pts = sel;
            if isempty(pts)
                beep; uiwait(errordlg('Não há pontos selecionados.','Erro','modal')); drawnow;
                Window_ButtonMotionFcn(hObject, eventdata, handles);
                return
            end
    end
    
    if all(isnan(Y(pts)))
        beep; uiwait(errordlg('Não há pontos válidos para a operação.','Erro','modal')); drawnow;
        Window_ButtonMotionFcn(hObject, eventdata, handles);
        return
    end

    % Operações         % Restrições
    
    %  1  y + k           -
    %  2  y - k           -
    %  3  k - y           -
    %  4  y * k           -
    %  5  y / k           k ~= 0
    %  6  k / y           y ~= 0
    %  7  y ^ k           -
    %  8  k ^ y           -
    %  9  y ^ 1/k         k ~= 0
    % 10  k ^ 1/y         y ~= 0
    % 11  log k (y)       y > 0,  k > 0,  k ~= 1
    % 12  log y (k)       y > 0,  k > 0,  y ~= 1
    % 13  y > k           y ~= NaN
    % 14  y < k           y ~= NaN
    % 15  y >= k          y ~= NaN
    % 16  y <= k          y ~= NaN
    % 17  y == k          y ~= NaN
    % 18  y ~= k          y ~= NaN
    
    % Cheque de validade
    if ( oper == 5 || oper == 9 ) && ~K % divisao por zero
        beep; uiwait(errordlg({'Parâmetro de entrada incoerente:','Divisão por zero.'},'Erro','modal')); drawnow;
        Window_ButtonMotionFcn(hObject, eventdata, handles);
        return
    end
    if ( oper == 6 || oper == 10 ) && any(Y(pts)==0) % divisao por zero
        uiwait(warndlg({'Encontrados valores iguais a zero no parâmetro y.',...
                'Valores resultantes dessa divisão serão invalidados (NaN).'},'Aviso','modal')); drawnow;
        Y(Y(pts)==0) = NaN;
    end
    
    if oper == 11 && (K <= 0 || K == 1) % log com base 0, negativa ou 1
        beep; uiwait(errordlg({'Parâmetro de entrada incoerente:','Base de logaritmo negativa, nula ou unitária.'},'Erro','modal')); drawnow;
        Window_ButtonMotionFcn(hObject, eventdata, handles);
        return
    end
    if oper == 11 && any(Y(pts)<=0) % log de 0 ou negativo
        uiwait(warndlg({'Encontrados valores menores ou iguais a zero no parâmetro y.',...
                'Valores resultantes desse logaritmo serão invalidados (NaN).'},'Aviso','modal')); drawnow;
        Y(Y(pts)<=0) = NaN;
    end
    
    if oper == 12 && K <= 0 % log de 0 ou negativo
        beep; uiwait(errordlg({'Parâmetro de entrada incoerente:','Logaritmo de número negativo ou nulo.'},'Erro','modal')); drawnow;
        Window_ButtonMotionFcn(hObject, eventdata, handles);
        return
    end
    if oper == 12 && ( any(Y(pts)<=0) || any(Y(pts)==1) ) % log com base 0, negativa ou 1
        uiwait(warndlg({'Encontrados valores menores ou iguais a zero ou iguais a um no parâmetro y.',...
                'Valores resultantes do logaritmo com essas bases serão invalidados (NaN).'},'Aviso','modal')); drawnow;
        Y(Y(pts)<=0) = NaN;
        Y(Y(pts)==1) = NaN;
    end
    
    if any(oper==(13:18)) % Logica
        nnan = find(isnan(Y));
        Y = nan2zero(Y);
    end
    
    % Calculo
    switch oper
        case 1 % y + k
            Y(pts) = Y(pts) + K;
        case 2 % y - k
            Y(pts) = Y(pts) - K;
        case 3 % k - y
            Y(pts) = K - Y(pts);
        case 4 % y * k
            Y(pts) = Y(pts) * K;
        case 5 % y / k
            Y(pts) = Y(pts) ./ K;
        case 6 % k / y
            Y(pts) = K ./ Y(pts);
        case 7 % y ^ k
            Y(pts) = Y(pts) .^ K;
        case 8 % k ^ y
            Y(pts) = K .^ Y(pts);
        case 9 % y ^ 1/k
            Y(pts) = Y(pts) .^ (1/K);
        case 10 % k ^ 1/y
            Y(pts) = K .^ (1./Y(pts));
        case 11 % log k (y)
            Y(pts) = log10(Y(pts)) ./ log10(K);
        case 12 % log y (k)
            Y(pts) = log10(K) ./ log10(Y(pts));
        case 13 % y > k
            Y(pts) = Y(pts) > K;
        case 14 % y < k
            Y(pts) = Y(pts) < K;
        case 15 % y >= k
            Y(pts) = Y(pts) >= K;
        case 16 % y <= k
            Y(pts) = Y(pts) <= K;
        case 17 % y == k
            Y(pts) = Y(pts) == K;
        case 18 % y ~= k
            Y(pts) = Y(pts) ~= K;
    end
    
    if any(oper==(13:18)) % Logica
        Y(nnan) = NaN;
    end
    
    if get(handles.entry4,'Value') == 1 % Novo parâmetro
        
        setappdata(handles.window,'tempdata',Y);
        ShowTemporaryPlot(hObject, eventdata, handles, Y, get(handles.ylabel,'String'));
        
        setappdata(handles.window,'func','OneParamOperation_2');
        
    else % Substituir
        
        button = questdlg({'Deseja substituir o parâmetro?','Os dados originais serão perdidos!'},'Confirmação',...
            'Sim','Não','Não'); drawnow;
        if strcmp(button,'Sim')
            
            DADOS(:,ycol) = Y;
            
            setappdata(handles.window,'func','none');
            setappdata(handles.window,'tempdata',[]);
            
            HideTemporaryPlot(hObject, eventdata, handles);
            
            setappdata(handles.window,'change',1);
            NewEvent(handles,['Parâmetro ''' get(handles.ylabel,'String') ''' alterado por operação matemática.']);
            
            button = questdlg('Deseja renomear o parâmetro?','Opção','Sim','Não','Não'); drawnow;
            if strcmp(button,'Sim')
                RenameParamY_Callback(hObject, eventdata, handles);
            end
            Window_ButtonMotionFcn(hObject, eventdata, handles);
            return
        end
        
    end
    
elseif strcmp(func,'OneParamOperation_2') && ~cancel
    
    name = TrimParamName(get(handles.entry1,'String'),handles.maxparamlength);
    if isempty(name)
        beep; uiwait(errordlg('Nome do parâmetro não pode ser vazio.','Erro','modal')); drawnow;
        return
    end 
    PARAM = InsertParam(PARAM,name);
    CheckRepParam(PARAM,name);
    
    data  = getappdata(handles.window,'tempdata');
    DADOS = [DADOS(:,1:end-1), data, DADOS(:,end)];
    
    if xcol == length(PARAM)-1
        xcol = xcol+1;
    end
    ycol = length(PARAM)-1;
    
    HideTemporaryPlot(hObject, eventdata, handles, xcol, ycol, PARAM);
    setappdata(handles.window,'func','none');
    
    setappdata(handles.window,'change',1);
    NewEvent(handles,['Parâmetro ''' name ''' criado por operação matemática.']);
    
elseif cancel
    
    HideTemporaryPlot(hObject, eventdata, handles);
    
end

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function TwoParamOperation_Callback(hObject, eventdata, handles)
global DADOS
% Operação entre dois parâmetros

PARAM  = get(handles.xlist,'String');
xcol   = get(handles.xlist,'Value');
ycol   = get(handles.ylist,'Value');
func   = getappdata(handles.window,'func');
cancel = getappdata(handles.window,'cancel');
sel    = getappdata(handles.window,'sel');

if strcmp(func,'none') && ~cancel
    
    set(handles.entry1txt,'String','Param 1:');
    set(handles.entry2txt,'String','Param 2:');
    set(handles.entry3txt,'String','Oper.:');
    set(handles.entry4txt,'String','Em:');
    set([handles.entry1 handles.entry2],'String',PARAM,'Value',ycol);
    set(handles.entry3,'String',{'Soma','Subtração','Multiplicação','Divisão','Potência','Raiz','Logaritmo','Diferença percentual',...
            'Composição cartesiana','Ângulo de fase','E','Ou','Ou exclusivo','Maior que','Menor que','Maior ou igual a','Menor ou igual a',...
            'Igual a','Diferente de'},'Value',1);
    set(handles.entry4,'String',{'Tudo','Intervalo','Seleção'},'Value',1);
    
    set([handles.entries handles.entriestxt handles.ok_btn handles.cancel_btn],'Visible','on');
    SetFrame(handles,1,'Operação matemática com dois parâmetros:');
    set([handles.menulist handles.xlist handles.ylist],'Enable','off');
    UpdateButtonStatus(hObject, eventdata, handles);
    
    set(handles.xlist,'Value',length(PARAM));
    xlist_Callback(hObject, eventdata, handles);
    
    setappdata(handles.window,'func','TwoParamOperation_1');
    MultiParamOperation_setgraph(hObject, eventdata, handles, 2);
    
elseif strcmp(func,'TwoParamOperation_1') && ~cancel
    
    set(handles.window,'Pointer','watch');
    
    Y1 = DADOS(:,get(handles.entry1,'Value'));
    Y2 = DADOS(:,get(handles.entry2,'Value'));
    Y = Y1;
    oper = get(handles.entry3,'Value');
    opt = get(handles.entry4,'Value');
    
    switch opt
        case 1 % Tudo
            pts = (1:size(DADOS,1))';
        case 2 % Intervalo
            pts = GetIntervPts(handles);
            if isempty(pts)
                beep; uiwait(errordlg('Não há pontos no intervalo selecionado.','Erro','modal')); drawnow;
                Window_ButtonMotionFcn(hObject, eventdata, handles);
                return
            end
        case 3 % Seleção
            pts = sel;
            if isempty(pts)
                beep; uiwait(errordlg('Não há pontos selecionados.','Erro','modal')); drawnow;
                Window_ButtonMotionFcn(hObject, eventdata, handles);
                return
            end
    end
    
    if all(isnan(Y1(pts))) || all(isnan(Y2(pts)))
        beep; uiwait(errordlg('Não há pontos válidos para a operação.','Erro','modal')); drawnow;
        Window_ButtonMotionFcn(hObject, eventdata, handles);
        return
    end
    
    % Operações          % Restrições
    
    % 1  P1 + P2           -
    % 2  P1 - P2           -
    % 3  P1 × P2           -
    % 4  P1 / P2           P2 ~= 0
    % 5  P1^ P2            -
    % 6  P1^ 1/P2          P2 ~= 0
    % 7  logP2(P1)         P1  > 0,  P2 > 0,  P2 ~= 1
    % 8  100×(P2-P1)/P1    P1 ~= 0
    % 9  sqrt(P1^2+P2^2)   -
    % 10 angle(P1+P2.i)    -
    % 11 E                 P1 ~= NaN, P2 ~= NaN
    % 12 Ou                P1 ~= NaN, P2 ~= NaN
    % 13 Ou exclusivo      P1 ~= NaN, P2 ~= NaN
    % 14 >                 P1 ~= NaN, P2 ~= NaN
    % 15 <                 P1 ~= NaN, P2 ~= NaN
    % 16 >=                P1 ~= NaN, P2 ~= NaN
    % 17 <=                P1 ~= NaN, P2 ~= NaN
    % 18 ==                P1 ~= NaN, P2 ~= NaN
    % 19 ~=                P1 ~= NaN, P2 ~= NaN
    
    % Cheque de validade
    if oper == 4 && any(Y2(pts)==0) % divisao por zero
        uiwait(warndlg({'Encontrados valores iguais a zero no Parâmetro 2.',...
                'Valores resultantes da divisão por zero serão invalidados (NaN).'},'Aviso','modal')); drawnow;
        Y2(Y2==0) = NaN;
    end
    if oper == 6 && any(Y2(pts)==0) % radiciação por zero
        uiwait(warndlg({'Encontrados valores iguais a zero no Parâmetro 2.',...
                'Valores resultantes dessa radiciação serão invalidados (NaN).'},'Aviso','modal')); drawnow;
        Y2(Y2==0) = NaN;
    end
    if oper == 7 && any(Y1(pts)<=0) % log menor ou igual a 0
        uiwait(warndlg({'Encontrados valores menores ou iguais a zero no Parâmetro 1.',...
                'Valores resultantes desse logaritmo serão invalidados (NaN).'},'Aviso','modal')); drawnow;
        Y1(Y1<=0) = NaN;
    end
    if oper == 7 && ( any(Y2(pts)<=0) || any(Y2(pts)==1) ) % log com base 1, 0 ou negativa
        uiwait(warndlg({'Encontrados valores unitários, nulos ou negativos no Parâmetro 2.',...
                'Valores resultantes do logaritmo com essas bases serão invalidados (NaN).'},'Aviso','modal')); drawnow;
        Y2(Y2<=0) = NaN;
        Y2(Y2==1) = NaN;
    end
    if oper == 8 && any(Y1(pts)==0)
        uiwait(warndlg({'Encontrados valores iguais a zero no Parâmetro 1.',...
                'Valores resultantes dessa operação serão invalidados (NaN).'},'Aviso','modal')); drawnow;
        Y1(Y1==0) = NaN;
    end
    
    if any(oper==(11:19)) % Logica
        nnan = find(isnan(Y1) | isnan(Y2));
        Y1 = nan2zero(Y1);
        Y2 = nan2zero(Y2);
    end
    
    % Calculo
    switch oper
        case 1 % +
            Y(pts) = Y1(pts) + Y2(pts);
        case 2 % -
            Y(pts) = Y1(pts) - Y2(pts);
        case 3 % *
            Y(pts) = Y1(pts) .* Y2(pts);
        case 4 % /
            Y(pts) = Y1(pts) ./ Y2(pts);
        case 5 % ^
            Y(pts) = Y1(pts) .^ Y2(pts);
        case 6 % raiz
            Y(pts) = Y1(pts) .^ (1./Y2(pts));
        case 7 % log
            Y(pts) = log10(Y1(pts)) ./ log10(Y2(pts));
        case 8 % dif %
            Y(pts) = 100*(Y2(pts)-Y1(pts))./Y1(pts);
        case 9 % norma
            Y(pts) = sqrt(Y1(pts).^2 + Y2(pts).^2);
        case 10 % angulo
            Y(pts) = atan2(Y2(pts), Y1(pts)) * 180/pi;
        case 11 % e
            Y(pts) = and(Y1(pts),Y2(pts));
        case 12 % ou
            Y(pts) =  or(Y1(pts),Y2(pts));
        case 13 % ou exclusivo
            Y(pts) = xor(Y1(pts),Y2(pts));
        case 14 % >
            Y(pts) = Y1(pts) > Y2(pts);
        case 15 % <
            Y(pts) = Y1(pts) < Y2(pts);
        case 16 % >=
            Y(pts) = Y1(pts) >= Y2(pts);
        case 17 % <=
            Y(pts) = Y1(pts) <= Y2(pts);
        case 18 % ==
            Y(pts) = Y1(pts) == Y2(pts);
        case 19 % ~=
            Y(pts) = Y1(pts) ~= Y2(pts);
    end
    
    if any(oper==(11:19)) % Logica
        Y(nnan) = NaN;
    end
    
    setappdata(handles.window,'tempdata',Y);
    
    MultiParamOperation_setgraph(hObject, eventdata, handles, 0, 0);
    ShowTemporaryPlot(hObject, eventdata, handles, Y, '');
    set(handles.graphs,'XLim',AutoLim(handles.plots(1,2)));
    
    setappdata(handles.window,'func','TwoParamOperation_2');
    
elseif strcmp(func,'TwoParamOperation_2') && ~cancel
    
    name = TrimParamName(get(handles.entry1,'String'),handles.maxparamlength);
    if isempty(name)
        beep; uiwait(errordlg('Nome do parâmetro não pode ser vazio.','Erro','modal')); drawnow;
        return
    end 
    PARAM = InsertParam(PARAM,name);
    CheckRepParam(PARAM,name);
    
    data  = getappdata(handles.window,'tempdata');
    DADOS = [DADOS(:,1:end-1), data, DADOS(:,end)];
    
    if xcol == length(PARAM)-1
        xcol = xcol+1;
    end
    ycol = length(PARAM)-1;
    
    HideTemporaryPlot(hObject, eventdata, handles, xcol, ycol, PARAM);
    setappdata(handles.window,'func','none');
    
    setappdata(handles.window,'change',1);
    NewEvent(handles,['Parâmetro ''' name ''' criado por operação entre parâmetros.']);
    
elseif cancel
    
    MultiParamOperation_setgraph(hObject, eventdata, handles, 0, 0);
    HideTemporaryPlot(hObject, eventdata, handles);
    
end

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function FourParamOperation_Callback(hObject, eventdata, handles)
global DADOS
% Operação com até quatro parâmetros

PARAM  = get(handles.xlist,'String');
xcol   = get(handles.xlist,'Value');
ycol   = get(handles.ylist,'Value');
func   = getappdata(handles.window,'func');
cancel = getappdata(handles.window,'cancel');

if strcmp(func,'none') && ~cancel
    
    set(handles.entry1txt,'String','x:');
    set(handles.entry2txt,'String','y:');
    set(handles.entry3txt,'String','z:');
    set(handles.entry4txt,'String','w:');
    set(handles.entries,'String',[{'Ignorar'};PARAM],'Value',1);
    set(handles.entry1,'Value',ycol+1)
    
    set([handles.entries handles.entriestxt handles.ok_btn handles.cancel_btn],'Visible','on');
    SetFrame(handles,1,'Indique até quatro parâmetros para operação:');
    set([handles.menulist handles.xlist handles.ylist],'Enable','off');
    UpdateButtonStatus(hObject, eventdata, handles);
    
    set(handles.xlist,'Value',length(PARAM));
    xlist_Callback(hObject, eventdata, handles);
    
    setappdata(handles.window,'func','FourParamOperation_1');
    MultiParamOperation_setgraph(hObject, eventdata, handles, 4);
    
elseif strcmp(func,'FourParamOperation_1') && ~cancel
    
    xcol = get(handles.entry1,'Value')-1;
    ycol = get(handles.entry2,'Value')-1;
    zcol = get(handles.entry3,'Value')-1;
    wcol = get(handles.entry4,'Value')-1;
    
    paramcols = [xcol ycol zcol wcol];
    setappdata(handles.window,'tempdata',paramcols);
    
    if any(paramcols)
        
        set(handles.frametxt,'String','Indique a função de x, y, z e w:');
        set(handles.entry1txt,'String','f =');
        SetEntrySize(handles,handles.entry1,2);
        set(handles.entry1,'Style','edit','String','');
        
        set([handles.entries(2:4) handles.entriestxt(2:4)],'Visible','off');
        
        setappdata(handles.window,'func','FourParamOperation_2');
    else
        beep; uiwait(errordlg('Necessário pelo menos um parâmetro para executar a operação.','Erro','modal')); drawnow;
        return
    end
    
elseif strcmp(func,'FourParamOperation_2') && ~cancel
    
    set(handles.window,'Pointer','watch');
    
    fun = vectorize(inline(get(handles.entry1,'String'),'x','y','z','w'));
    paramcols = getappdata(handles.window,'tempdata');
    
    xcol = paramcols(1);
    ycol = paramcols(2);
    zcol = paramcols(3);
    wcol = paramcols(4);
    
    if xcol; x = DADOS(:,xcol); else x = NaN*DADOS(:,end); end
    if ycol; y = DADOS(:,ycol); else y = NaN*DADOS(:,end); end
    if zcol; z = DADOS(:,zcol); else z = NaN*DADOS(:,end); end
    if wcol; w = DADOS(:,wcol); else w = NaN*DADOS(:,end); end
    
    try
        lastwarn('');
        Y = fun(x,y,z,w);
        if ~isempty(lastwarn)
            uiwait(warndlg(lastwarn,'Aviso','modal')); drawnow;
        end
    catch
        beep; uiwait(errordlg('Erro na definição da função.','Erro','modal')); drawnow;
        Window_ButtonMotionFcn(hObject, eventdata, handles);
        return
    end
    
    if size(Y,1) ~= size(DADOS,1) || size(Y,2) ~= 1
        beep; uiwait(errordlg('Resultado da operação incompatível com matriz DADOS.','Erro','modal')); drawnow;
        Window_ButtonMotionFcn(hObject, eventdata, handles);
        return
    end
    
    if any(imag(Y))
        uiwait(warndlg({'Encontrados valores complexos no resultado da expressão.',...
                'Será armazenada somente a parte real.'},'Aviso','modal')); drawnow;
        Y = real(Y);
    end
    
    if any(isinf(Y))
        uiwait(warndlg({'Encontrados valores infinitos no resultado da expressão.',...
                'Será atribuído "NaN".'},'Aviso','modal')); drawnow;
        Y(isinf(Y)) = NaN;
    end
    
    if all(isnan(Y))
        button = questdlg({'Encontrados apenas valores inválidos no resultado da expressão.',...
                'Deseja prosseguir?'},'Confirmação','Sim','Não','Não'); drawnow;
        if ~strcmp(button,'Sim')
            Window_ButtonMotionFcn(hObject, eventdata, handles);
            return
        end
    end
    
    setappdata(handles.window,'tempdata',Y);
    
    MultiParamOperation_setgraph(hObject, eventdata, handles, 0, 0);
    ShowTemporaryPlot(hObject, eventdata, handles, Y, '');
    set(handles.graphs,'XLim',AutoLim(handles.plots(1,2)));
    
    setappdata(handles.window,'func','FourParamOperation_3');
    
elseif strcmp(func,'FourParamOperation_2') && cancel
    
    MultiParamOperation_setgraph(hObject, eventdata, handles, 0, 0);
    HideTemporaryPlot(hObject, eventdata, handles);
    
elseif strcmp(func,'FourParamOperation_3') && ~cancel
    
    name = TrimParamName(get(handles.entry1,'String'),handles.maxparamlength);
    if isempty(name)
        beep; uiwait(errordlg('Nome do parâmetro não pode ser vazio.','Erro','modal')); drawnow;
        return
    end 
    PARAM = InsertParam(PARAM,name);
    CheckRepParam(PARAM,name);
    
    data  = getappdata(handles.window,'tempdata');
    DADOS = [DADOS(:,1:end-1), data, DADOS(:,end)];
    
    if xcol == length(PARAM)-1
        xcol = xcol+1;
    end
    ycol = length(PARAM)-1;
    
    HideTemporaryPlot(hObject, eventdata, handles, xcol, ycol, PARAM);
    setappdata(handles.window,'func','none');
    
    setappdata(handles.window,'change',1);
    NewEvent(handles,['Parâmetro ''' name ''' criado por operação com parâmetros.']);
    
elseif cancel
    
    MultiParamOperation_setgraph(hObject, eventdata, handles, 0, 0);
    HideTemporaryPlot(hObject, eventdata, handles);
    
end

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function GetBit_Callback(hObject, eventdata, handles)
global DADOS
% Função que extrai um bit específico de uma palavra

PARAM  = get(handles.xlist,'String');
xcol   = get(handles.xlist,'Value');
ycol   = get(handles.ylist,'Value');
func   = getappdata(handles.window,'func');
ok     = getappdata(handles.window,'ok');
cancel = getappdata(handles.window,'cancel');

if strcmp(func,'none') && ~cancel
    
    set(handles.entry1txt,'String','Tipo:');
    set(handles.entry2txt,'String','Decimais:');
    set(handles.entry3txt,'String','Bit:');
    set(handles.entry1,'String',{'Inteiro positivo','Complemento de 2'},'Value',1);
    set(handles.entry2,'String',{'Arredondar','Truncar'},'Value',1);
    set(handles.entry3,'String',char(' ',num2str((1:32)')),'Value',1);
    
    set([handles.entries(1:3) handles.entriestxt(1:3) handles.ok_btn handles.cancel_btn],'Visible','on');
    SetFrame(handles,2,'Obtenção de bit da palavra:');
    set([handles.menulist handles.xlist],'Enable','off');
    UpdateButtonStatus(hObject, eventdata, handles);
    
    setappdata(handles.window,'func','GetBit_1');
    MultiParamOperation_setgraph(hObject, eventdata, handles, 2);
    
elseif strcmp(func,'GetBit_1') && ~cancel
    
    set(handles.window,'Pointer','watch');
    
    Y    = DADOS(:,ycol);
    X    = DADOS(:,xcol);
    nnan = find(isnan(Y));
    type = get(handles.entry1,'Value');
    opt  = get(handles.entry2,'Value');
    n    = get(handles.entry3,'Value')-1;
    
    if ~n
        bit  = Y*NaN;

    else
        
        switch opt
            case 1 % Arredondar
                Y = round(denan(Y,1));
            case 2 % Truncar
                Y = fix(denan(Y,1));
        end
        
        switch type
            case 1 % Inteiro positivo (zerar negativos)
                Y = max(0,Y);
                bit = bitget(Y,n);
            case 2 % Complemento de 2
                bit = bitget(bin2dec(dec2twos(Y,n)),n);
        end
        
        bit(nnan) = NaN;
        
    end
    
    if ok
        
        if ~n
            beep; uiwait(errordlg('Bit não definido.','Erro','modal')); drawnow;
            return    
        end
        
        setappdata(handles.window,'tempdata',bit);
        
        MultiParamOperation_setgraph(hObject, eventdata, handles, 0, 0);
        ShowTemporaryPlot(hObject, eventdata, handles, bit, ['Bit ' num2str(n)]);
        set(handles.graphs,'XLim',AutoLim(handles.plots(1,2)));
        
        setappdata(handles.window,'func','GetBit_2');
        
    else
        set(handles.plots(2,2),'XData',X,'YData',bit);
        if n
            set(handles.ylabels(2),'String',['Bit ' num2str(n)]);
        else
            set(handles.ylabels(2),'String','');
        end
    end
    
elseif strcmp(func,'GetBit_2') && ~cancel
    
    name = TrimParamName(get(handles.entry1,'String'),handles.maxparamlength);
    if isempty(name)
        beep; uiwait(errordlg('Nome do parâmetro não pode ser vazio.','Erro','modal')); drawnow;
        return
    end 
    PARAM = InsertParam(PARAM,name);
    CheckRepParam(PARAM,name);
    
    data  = getappdata(handles.window,'tempdata');
    DADOS = [DADOS(:,1:end-1), data, DADOS(:,end)];
    
    if xcol == length(PARAM)-1
        xcol = xcol+1;
    end
    ycol = length(PARAM)-1;
    
    HideTemporaryPlot(hObject, eventdata, handles, xcol, ycol, PARAM);
    setappdata(handles.window,'func','none');
    
    setappdata(handles.window,'change',1);
    NewEvent(handles,['Parâmetro ''' name ''' criado por obtenção de bit da palavra.']);
    
elseif cancel
    
    MultiParamOperation_setgraph(hObject, eventdata, handles, 0, 0);
    HideTemporaryPlot(hObject, eventdata, handles);
    
end

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function SetBit_Callback(hObject, eventdata, handles)
global DADOS
% Função que atribui um valor a um bit especifico de um palavra

xcol   = get(handles.xlist,'Value');
ycol   = get(handles.ylist,'Value');
func   = getappdata(handles.window,'func');
ok     = getappdata(handles.window,'ok');
cancel = getappdata(handles.window,'cancel');
PARAM  = get(handles.ylist,'String');

if strcmp(func,'none') && ~cancel
    
    set(handles.entry1txt,'String','Em:');
    set(handles.entry2txt,'String','Opção:');
    set(handles.entry1,'String',{'Tudo','Intervalo','Seleção'},'Value',1);
    set(handles.entry2,'String',{'Novo parâmetro','Substituir atual'},'Value',1);

    set([handles.entries(1:2) handles.entriestxt(1:2) handles.ok_btn handles.cancel_btn],'Visible','on');
    SetFrame(handles,2,'Atribuição de bit à palavra:');
    set([handles.menulist handles.xlist],'Enable','off');
    UpdateButtonStatus(hObject, eventdata, handles);
    
    setappdata(handles.window,'func','SetBit_1');
    
elseif strcmp(func,'SetBit_1') && ~cancel
    
    in   = get(handles.entry1,'Value');
    opt  = get(handles.entry2,'Value');
    
    sel  = getappdata(handles.window,'sel');
    pts  = GetIntervPts(handles);
    
    if ok
        
        if ycol == length(PARAM) && opt == 2
            beep; uiwait(errordlg('Não é possível alterar o parâmetro ''No. OBS.''','Erro','modal')); drawnow;
            Window_ButtonMotionFcn(hObject, eventdata, handles);
            return
        end
        if in == 2 && isempty(pts)
            beep; uiwait(errordlg('Não há pontos no intervalo selecionado.','Erro','modal')); drawnow;
            Window_ButtonMotionFcn(hObject, eventdata, handles);
            return
        elseif in == 3 && isempty(sel)
            beep; uiwait(errordlg('Não há pontos selecionados.','Erro','modal')); drawnow;
            Window_ButtonMotionFcn(hObject, eventdata, handles);
            return
        end
        
        setappdata(handles.window,'tempdata',[in opt]);
        
        set(handles.entry1txt,'String','Tipo:');
        set(handles.entry2txt,'String','Decimais:');
        set(handles.entry3txt,'String','Bit:');
        set(handles.entry4txt,'String','Valor:');
        set(handles.entry1,'String',{'Inteiro positivo','Complemento de 2'},'Value',1);
        set(handles.entry2,'String',{'Arredondar','Truncar'},'Value',1);
        set(handles.entry3,'String',char(' ',num2str((1:32)')),'Value',1);
        set(handles.entry4,'String',{'0','1'},'Value',1);
        
        set([handles.entries handles.entriestxt],'Visible','on');
        set(handles.ylist,'Enable','off');
        
        if in == 2
            set(handles.controlbtns,'Enable','off');
            setappdata(handles.window,'clickfunc','none');
        end
        
        MultiParamOperation_setgraph(hObject, eventdata, handles, 2);
        setappdata(handles.window,'func','SetBit_2');
    end
    
elseif strcmp(func,'SetBit_2') && ~cancel

    set(handles.window,'Pointer','watch');
    
    tempdata = getappdata(handles.window,'tempdata');
    in   = tempdata(1);
    opt  = tempdata(2);
    
    type = get(handles.entry1,'Value');
    dec  = get(handles.entry2,'Value');
    n    = get(handles.entry3,'Value')-1;
    v    = get(handles.entry4,'Value')-1;
    
    Y    = DADOS(:,ycol);
    X    = DADOS(:,xcol);
    nnan = find(isnan(Y));
    Y    = denan(Y,1);
    
    if ~n
        bit  = [];
        pts  = [];
    else
        
        switch in
            case 1
                pts = DADOS(:,end);
            case 2
                pts  = GetIntervPts(handles);
            case 3
                pts = getappdata(handles.window,'sel');
        end
        
        switch dec
            case 1 % Arredondar
                Y(pts) = round(Y(pts));
            case 2 % Truncar
                Y(pts) = fix(Y(pts));
        end
        
        switch type
            case 1 % Inteiro positivo (zerar negativos)
                Y(pts) = max(0,Y(pts));
                bin = dec2bin(Y(pts),n);
                bit = bitget(Y(pts),n);
            case 2 % Complemento de 2
                bin = dec2twos(Y(pts),n);
                bit = bitget(bin2dec(bin),n);
        end
        
        bin(:,end-n+1) = num2str(v);
        
        switch type
            case 1 % Inteiro positivo
                Y(pts) = bin2dec(bin);
            case 2 % Complemento de 2
                Y(pts) = twos2dec(bin,n);
        end
        
        Y(nnan) = NaN;
        
    end
    
    if ok
        
        if ~n
            beep; uiwait(errordlg('Bit não definido.','Erro','modal')); drawnow;
            Window_ButtonMotionFcn(hObject, eventdata, handles);
            return    
        end
        
        if opt == 1 % Novo parâmetro
            
            setappdata(handles.window,'tempdata',Y);
            MultiParamOperation_setgraph(hObject, eventdata, handles, 0, 0);
            ShowTemporaryPlot(hObject, eventdata, handles, Y, get(handles.ylabel,'String'));
            setappdata(handles.window,'func','SetBit_3');
            
        else % Substituir
            
            button = questdlg({'Deseja substituir o parâmetro?','Os dados originais serão perdidos!'},'Confirmação',...
                'Sim','Não','Não'); drawnow;
            if strcmp(button,'Sim')
                
                DADOS(:,ycol) = Y;
                
                setappdata(handles.window,'func','none');
                setappdata(handles.window,'tempdata',[]);
                
                MultiParamOperation_setgraph(hObject, eventdata, handles, 0, 0);
                HideTemporaryPlot(hObject, eventdata, handles);
                
                setappdata(handles.window,'change',1);
                NewEvent(handles,['Parâmetro ''' get(handles.ylabel,'String') ''' alterado por atribuição de bit à palavra.']);
            end
        end
        
    else
        Y2 = NaN*Y;
        Y2(pts) = bit;
        set(handles.plots(2,2),'XData',X,'YData',Y2);
        if n
            set(handles.ylabels(2),'String',['Bit ' num2str(n)]);
        else
            set(handles.ylabels(2),'String','');
        end
    end
   
elseif strcmp(func,'SetBit_2') && cancel
    
    MultiParamOperation_setgraph(hObject, eventdata, handles, 0, 0);
    HideTemporaryPlot(hObject, eventdata, handles);
    
elseif strcmp(func,'SetBit_3') && ~cancel
    
    name = TrimParamName(get(handles.entry1,'String'),handles.maxparamlength);
    if isempty(name)
        beep; uiwait(errordlg('Nome do parâmetro não pode ser vazio.','Erro','modal')); drawnow;
        return
    end 
    PARAM = InsertParam(PARAM,name);
    CheckRepParam(PARAM,name);
    
    data  = getappdata(handles.window,'tempdata');
    DADOS = [DADOS(:,1:end-1), data, DADOS(:,end)];
    
    if xcol == length(PARAM)-1
        xcol = xcol+1;
    end
    ycol = length(PARAM)-1;
    
    HideTemporaryPlot(hObject, eventdata, handles, xcol, ycol, PARAM);
    setappdata(handles.window,'func','none');
    
    setappdata(handles.window,'change',1);
    NewEvent(handles,['Parâmetro ''' name ''' criado por atribuição de bit à palavra.']);
    
elseif cancel
    
    MultiParamOperation_setgraph(hObject, eventdata, handles, 0, 0);
    HideTemporaryPlot(hObject, eventdata, handles);
    
end

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function JoinWords_Callback(hObject, eventdata, handles)
global DADOS
% Função que compoe duas palavas binarias

xcol   = get(handles.xlist,'Value');
ycol   = get(handles.ylist,'Value');
func   = getappdata(handles.window,'func');
cancel = getappdata(handles.window,'cancel');
PARAM  = get(handles.xlist,'String');

if strcmp(func,'none') && ~cancel
    
    set(handles.entry1txt,'String','LSW:');
    set(handles.entry2txt,'String','MSW:');
    set(handles.entry3txt,'String','Bits:');
    set(handles.entry4txt,'String','Tipo:');
    set(handles.entries(1:2),'String',PARAM,'Value',ycol);
    set(handles.entry3,'String',num2str((1:32)'),'Value',8);
    set(handles.entry4,'String',{'Inteiro positivo','Complemento de 2'},'Value',1);
    
    set([handles.entries handles.entriestxt handles.ok_btn handles.cancel_btn],'Visible','on');
    SetFrame(handles,1,'Indique as palavras menos e mais significativas:');
    set([handles.menulist handles.xlist handles.ylist],'Enable','off');
    UpdateButtonStatus(hObject, eventdata, handles);
    
    setappdata(handles.window,'func','JoinWords_1');
    MultiParamOperation_setgraph(hObject, eventdata, handles, 2);
    entry2_Callback(hObject, eventdata, handles);
    
elseif strcmp(func,'JoinWords_1') && ~cancel
    
    set(handles.window,'Pointer','watch');
    
    LSW  = DADOS(:,get(handles.entry1,'Value'));
    MSW  = DADOS(:,get(handles.entry2,'Value'));
    nb   = get(handles.entry3,'Value');
    type = get(handles.entry4,'Value');
    
    nnan = find(isnan(LSW+MSW));
    
    LSW(nnan) = 0;
    MSW(nnan) = 0;
    
    if any(LSW<0) || any(MSW<0) || any(LSW-fix(LSW)) || any(MSW-fix(MSW))
        uiwait(warndlg({'Encontrados valores negativos e/ou não inteiros nos parâmetros de entrada.',...
                'Valores negativos serão zerados e valores não inteiros serão arredondados','para a conversão para a representaçao binária.'},'Aviso','modal'));
        LSW = round(max(0,LSW));
        MSW = round(max(0,MSW));
        
        Y = [dec2bin(MSW,nb) dec2bin(LSW,nb)];
        
        switch type
            
            case 1 % Inteiro positivo
                Y = bin2dec(Y);
                
            case 2 % Complemento de 2
                Y = twos2dec(Y,2*nb);
                
        end
        
    end
    
    Y(nnan) = NaN;
    
    setappdata(handles.window,'tempdata',Y);
    
    MultiParamOperation_setgraph(hObject, eventdata, handles, 0, 0);
    ShowTemporaryPlot(hObject, eventdata, handles, Y, '');
    set(handles.graphs,'XLim',AutoLim(handles.plots(1,2)));
    
    setappdata(handles.window,'func','JoinWords_2');
    
elseif strcmp(func,'JoinWords_2') && ~cancel
    
    name = TrimParamName(get(handles.entry1,'String'),handles.maxparamlength);
    if isempty(name)
        beep; uiwait(errordlg('Nome do parâmetro não pode ser vazio.','Erro','modal')); drawnow;
        return
    end 
    PARAM = InsertParam(PARAM,name);
    CheckRepParam(PARAM,name);
    
    data  = getappdata(handles.window,'tempdata');
    DADOS = [DADOS(:,1:end-1), data, DADOS(:,end)];
    
    if xcol == length(PARAM)-1
        xcol = xcol+1;
    end
    ycol = length(PARAM)-1;
    
    HideTemporaryPlot(hObject, eventdata, handles, xcol, ycol, PARAM);
    setappdata(handles.window,'func','none');
    
    setappdata(handles.window,'change',1);
    NewEvent(handles,['Parâmetro ''' name ''' criado por composição de palavras binárias.']);
    
elseif cancel
    
    MultiParamOperation_setgraph(hObject, eventdata, handles, 0, 0);
    HideTemporaryPlot(hObject, eventdata, handles);
    
end

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function LatLong2DeDn_Callback(hObject, eventdata, handles)
global DADOS
% Conversao de Lat/Long em De/Dn

PARAM  = get(handles.xlist,'String');
func   = getappdata(handles.window,'func');
cancel = getappdata(handles.window,'cancel');

if strcmp(func,'none') && ~cancel
    
    set(handles.entry1txt,'String','Lat 0:');
    set(handles.entry2txt,'String','Long 0:');
    set(handles.entry3txt,'String','Unidade:');
    set([handles.entry1 handles.entry2],'Style','edit','String','');
    set(handles.entry3,'String',{'Metros','Quilômetros','Milhas Náuticas','Pés'},'Value',1);
    
    set([handles.entries(1:3) handles.entriestxt(1:3) handles.ok_btn handles.cancel_btn],'Visible','on');
    SetFrame(handles,2,'Indique latitude, longitude, ponto-base e unidade de saída:');
    set(handles.menulist,'Enable','off');
    UpdateButtonStatus(hObject, eventdata, handles);
    
    nLat = findpar(PARAM,'lat');
    if isempty(nLat)
        nLat = get(handles.ylist,'Value');
    else
        set(handles.ylist,'Value',nLat);
        ylist_Callback(hObject, eventdata, handles);
    end
    nLon = findpar(PARAM,{'long','lon'});
    if isempty(nLon)
        nLon = get(handles.xlist,'Value');
    else
        set(handles.xlist,'Value',nLon);
        xlist_Callback(hObject, eventdata, handles);
    end
    
    LatM = nanmean(DADOS(:,nLat));
    LonM = nanmean(DADOS(:,nLon));
    
    set(handles.entry1,'String',deg2latlong(LatM,1,3));
    set(handles.entry2,'String',deg2latlong(LonM,2,3));
    set(handles.centerpt,'XData',LonM,'YData',LatM);
    
    if ~isempty(strfind(lower([get(handles.xlabel,'String') get(handles.ylabel,'String')]),'semicirc'))
        uiwait(warndlg({'Foi detectada unidade "SemiCírculo" no nome do(s) parâmetro(s).',...
                'A operação deve ser realizada em graus.'},'Aviso','modal')); drawnow;
    end    
    
    setappdata(handles.window,'func','LatLong2DeDn_1');
    
elseif strcmp(func,'LatLong2DeDn_1') && ~cancel
    
    [str,Lat0] = latlongread(get(handles.entry1,'String'),1);
    [str,Lon0] = latlongread(get(handles.entry2,'String'),2);
    
    unit = get(handles.entry3,'Value');
    
    if isempty(Lat0) && isempty(Lon0)
        beep; uiwait(errordlg('Defina as coordenadas do ponto-base.','Erro','modal')); drawnow;
        return
    end
    if isempty(Lat0)
        beep; uiwait(errordlg('Defina a latitude do ponto-base.','Erro','modal')); drawnow;
        return
    end
    if isempty(Lon0)
        beep; uiwait(errordlg('Defina a longitude do ponto-base.','Erro','modal')); drawnow;
        return
    end
    
    set(handles.window,'Pointer','watch');
    
    Lat = DADOS(:,get(handles.ylist,'Value'));
    Lon = DADOS(:,get(handles.xlist,'Value'));
    
    [DE, DN] = latlong2dxdy(Lat0,Lon0,Lat,Lon);
    
    switch unit
        case 1
            unit = '(m)';
        case 2 % km
            DE = DE/1000;
            DN = DN/1000;
            unit = '(km)';
        case 3 % NM
            DE = DE/1852;
            DN = DN/1852;
            unit = '(NM)';
        case 4 % ft
            DE = DE/.3048;
            DN = DN/.3048;
            unit = '(ft)';
    end
    
    setappdata(handles.window,'tempdata',[DN DE]);
    
    set([handles.xlist handles.ylist handles.Ruler_btn handles.DataTips_btn handles.Events_btn handles.TestPoints_btn],'Enable','off');
    SetFrame(handles,1,'Defina o nome dos novos parâmetros:');
    set(handles.entry1txt,'String','DNorte:');
    set(handles.entry2txt,'String','DLeste:');
    SetEntrySize(handles,handles.entry1,2);
    SetEntrySize(handles,handles.entry2,2);
    set(handles.entry1,'Style','edit','String',['DNorte ' unit]);
    set(handles.entry2,'Style','edit','String',['DLeste ' unit]);
    set([handles.entry3 handles.entry3txt],'Visible','off');
    
    % Plot Temporario
    set([handles.plot handles.selpts],'XData',NaN,'YData',NaN);
    set(handles.centerpt,'XData',0,'YData',0);
    set([handles.inipts handles.endpts handles.testptlbl handles.eventpts handles.eventlbl],'Visible','off');
    set(handles.plots(1,2),'XData',DE,'YData',DN);
    set(handles.graphs,'XLim',AutoLim([handles.plots(1,2) handles.centerpt]));
    set(handles.ylabel,'String',['DNorte ' unit]);
    set(handles.xlabel,'String',['DLeste ' unit]);
    UpdateDataTips(hObject, eventdata, handles);
    
    setappdata(handles.window,'func','LatLong2DeDn_2');
    
elseif strcmp(func,'LatLong2DeDn_2') && ~cancel
    
    name1 = TrimParamName(get(handles.entry1,'String'),handles.maxparamlength);
    name2 = TrimParamName(get(handles.entry2,'String'),handles.maxparamlength);
    if isempty(name1) || isempty(name2)
        beep; uiwait(errordlg('Nome do parâmetro não pode ser vazio.','Erro','modal')); drawnow;
        return
    end 
    PARAM = InsertParam(PARAM,name1);
    PARAM = InsertParam(PARAM,name2);
    CheckRepParam(PARAM,name1);
    CheckRepParam(PARAM,name2);
    
    data  = getappdata(handles.window,'tempdata');
    DADOS = [DADOS(:,1:end-1), data, DADOS(:,end)];
    
    ycol = length(PARAM)-2;
    xcol = length(PARAM)-1;
    
    set(handles.centerpt,'XData',NaN,'YData',NaN);
    HideTemporaryPlot(hObject, eventdata, handles, xcol, ycol, PARAM);
    setappdata(handles.window,'func','none');
    
    setappdata(handles.window,'change',1);
    NewEvent(handles,['Parâmetros ''' name1 ''' e ''' name2 ''' criados por conversão de coordenadas.']);
    
elseif cancel
    
    set(handles.centerpt,'XData',NaN,'YData',NaN);
    HideTemporaryPlot(hObject, eventdata, handles);
    set(handles.graphs,'XLim',AutoLim(handles.plot));
    
end

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function DeDn2LatLong_Callback(hObject, eventdata, handles)
global DADOS
% Conversao de De/Dn em Lat/Long

PARAM  = get(handles.xlist,'String');
func   = getappdata(handles.window,'func');
cancel = getappdata(handles.window,'cancel');

if strcmp(func,'none') && ~cancel
    
    set(handles.entry1txt,'String','Lat 0:');
    set(handles.entry2txt,'String','Long 0:');
    set(handles.entry3txt,'String','Unidade:');
    set([handles.entry1 handles.entry2],'Style','edit','String','');
    set(handles.entry3,'String',{'Metros','Quilômetros','Milhas Náuticas','Pés'},'Value',1);
    
    set([handles.entries(1:3) handles.entriestxt(1:3) handles.ok_btn handles.cancel_btn],'Visible','on');
    SetFrame(handles,2,'Indique distância norte, distância leste, ponto-base e unidade de entrada:');
    set(handles.menulist,'Enable','off');
    UpdateButtonStatus(hObject, eventdata, handles);
    
    nDE = findpar(PARAM,{'de (','dleste','deast'});
    if ~isempty(nDE);
        set(handles.xlist,'Value',nDE);
        xlist_Callback(hObject, eventdata, handles);
    end
    nDN = findpar(PARAM,{'dn (','dnort'});
    if ~isempty(nDN);
        set(handles.ylist,'Value',nDN);
        ylist_Callback(hObject, eventdata, handles);
    end
    
    params = SetUnits([get(handles.xlabel,'String') get(handles.ylabel,'String')]);
    if     strfind(params,'(km)')
        unit = 2;
    elseif strfind(params,'(NM)')
        unit = 3;
    elseif strfind(params,'(ft)')
        unit = 4;
    else
        unit = 1;
    end
    set(handles.entry3,'Value',unit);
    
    setappdata(handles.window,'func','DeDn2LatLong_1');
    
elseif strcmp(func,'DeDn2LatLong_1') && ~cancel
    
    [str,Lat0] = latlongread(get(handles.entry1,'String'),1);
    [str,Lon0] = latlongread(get(handles.entry2,'String'),2);
    
    unit = get(handles.entry3,'Value');
    
    if isempty(Lat0) && isempty(Lon0)
        beep; uiwait(errordlg('Defina as coordenadas do ponto-base.','Erro','modal')); drawnow;
        return
    end
    if isempty(Lat0)
        beep; uiwait(errordlg('Defina a latitude do ponto-base.','Erro','modal')); drawnow;
        return
    end
    if isempty(Lon0)
        beep; uiwait(errordlg('Defina a longitude do ponto-base.','Erro','modal')); drawnow;
        return
    end
    
    set(handles.window,'Pointer','watch');
    
    DN = DADOS(:,get(handles.ylist,'Value'));
    DE = DADOS(:,get(handles.xlist,'Value'));
    
    switch unit
        case 2 % km
            DE = DE*1000;
            DN = DN*1000;
        case 3 % NM
            DE = DE*1852;
            DN = DN*1852;
        case 4 % ft
            DE = DE*.3048;
            DN = DN*.3048;
    end
    
    [LAT, LONG] = dxdy2latlong(Lat0,Lon0,DN,DE);
    
    setappdata(handles.window,'tempdata',[LAT LONG]);
    
    set([handles.xlist handles.ylist handles.Ruler_btn handles.DataTips_btn handles.Events_btn handles.TestPoints_btn],'Enable','off');
    SetFrame(handles,1,'Defina o nome dos novos parâmetros:');
    set(handles.entry1txt,'String','Lat:');
    set(handles.entry2txt,'String','Long:');
    SetEntrySize(handles,handles.entry1,2);
    SetEntrySize(handles,handles.entry2,2);
    set(handles.entry1,'Style','edit','String','Latitude (°)');
    set(handles.entry2,'Style','edit','String','Longitude (°)');
    set([handles.entry3 handles.entry3txt],'Visible','off');
    
    % Plot Temporario
    set([handles.plot handles.selpts],'XData',NaN,'YData',NaN);
    set(handles.centerpt,'XData',Lon0,'YData',Lat0);
    set([handles.inipts handles.endpts handles.testptlbl handles.eventpts handles.eventlbl],'Visible','off');
    set(handles.plots(1,2),'XData',LONG,'YData',LAT);
    set(handles.graphs,'XLim',AutoLim([handles.plots(1,2) handles.centerpt]));
    set(handles.ylabel,'String','Latitude (°)');
    set(handles.xlabel,'String','Longitude (°)');
    UpdateDataTips(hObject, eventdata, handles);
    
    setappdata(handles.window,'func','DeDn2LatLong_2');
    
elseif strcmp(func,'DeDn2LatLong_2') && ~cancel
    
    name1 = TrimParamName(get(handles.entry1,'String'),handles.maxparamlength);
    name2 = TrimParamName(get(handles.entry2,'String'),handles.maxparamlength);
    if isempty(name1) || isempty(name2)
        beep; uiwait(errordlg('Nome do parâmetro não pode ser vazio.','Erro','modal')); drawnow;
        return
    end 
    PARAM = InsertParam(PARAM,name1);
    PARAM = InsertParam(PARAM,name2);
    CheckRepParam(PARAM,name1);
    CheckRepParam(PARAM,name2);
    
    data  = getappdata(handles.window,'tempdata');
    DADOS = [DADOS(:,1:end-1), data, DADOS(:,end)];
    
    ycol = length(PARAM)-2;
    xcol = length(PARAM)-1;
    
    set(handles.centerpt,'XData',NaN,'YData',NaN);
    HideTemporaryPlot(hObject, eventdata, handles, xcol, ycol, PARAM);
    setappdata(handles.window,'func','none');
    
    setappdata(handles.window,'change',1);
    NewEvent(handles,['Parâmetros ''' name1 ''' e ''' name2 ''' criados por conversão de coordenadas.']);
    
elseif cancel
    
    set(handles.centerpt,'XData',NaN,'YData',NaN);
    HideTemporaryPlot(hObject, eventdata, handles);
    set(handles.graphs,'XLim',AutoLim(handles.plot));
    
end

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function LatLong2RdlDist_Callback(hObject, eventdata, handles)
global DADOS
% Conversao de Lat/Long em RDL/Dist

PARAM  = get(handles.xlist,'String');
func   = getappdata(handles.window,'func');
cancel = getappdata(handles.window,'cancel');

if strcmp(func,'none') && ~cancel
    
    set(handles.entry1txt,'String','Lat 0:');
    set(handles.entry2txt,'String','Long 0:');
    set(handles.entry3txt,'String','Unidade:');
    set(handles.entry4txt,'String','Declin.:');
    set(handles.entries(1:2),'Style','edit','String','');
    set(handles.entry3,'String',{'Metros','Quilômetros','Milhas Náuticas','Pés'},'Value',1);
    set(handles.entry4,'String',[{'Especificar'};PARAM],'Value',2);
    
    set([handles.entries handles.entriestxt handles.ok_btn handles.cancel_btn],'Visible','on');
    SetFrame(handles,2,'Indique latitude, longitude, ponto-base, unidade de saída e declinação magnética:');
    set(handles.menulist,'Enable','off');
    UpdateButtonStatus(hObject, eventdata, handles);
    
    nLat = findpar(PARAM,'lat');
    if isempty(nLat)
        nLat = get(handles.ylist,'Value');
    else
        set(handles.ylist,'Value',nLat);
        ylist_Callback(hObject, eventdata, handles);
    end
    nLon = findpar(PARAM,{'long','lon'});
    if isempty(nLon)
        nLon = get(handles.xlist,'Value');
    else
        set(handles.xlist,'Value',nLon);
        xlist_Callback(hObject, eventdata, handles);
    end
    nDclin = findpar(PARAM,{'dmag','declin'});
    if ~isempty(nDclin);
        set(handles.entry4,'Value',nDclin+1);
    end
    
    LatM = nanmean(DADOS(:,nLat));
    LonM = nanmean(DADOS(:,nLon));
    
    set(handles.entry1,'String',deg2latlong(LatM,1,3));
    set(handles.entry2,'String',deg2latlong(LonM,2,3));
    set(handles.centerpt,'XData',LonM,'YData',LatM);
    
    if ~isempty(strfind(lower([get(handles.xlabel,'String') get(handles.ylabel,'String')]),'semicirc'))
        uiwait(warndlg({'Foi detectada unidade "SemiCírculo" no nome do(s) parâmetro(s).',...
                'A operação deve ser realizada em graus.'},'Aviso','modal')); drawnow;
    end    
    
    setappdata(handles.window,'func','LatLong2RdlDist_1');
    
elseif strcmp(func,'LatLong2RdlDist_1') && ~cancel
    
    [str,Lat0] = latlongread(get(handles.entry1,'String'),1);
    [str,Lon0] = latlongread(get(handles.entry2,'String'),2);
    
    unit = get(handles.entry3,'Value');
    
    switch get(handles.entry4,'Style')
        case 'popupmenu'
            Dmag = DADOS(:,get(handles.entry4,'Value')-1);
        case 'edit'
            Dmag = str2double(get(handles.entry4,'String'));
    end
    
    if isempty(Lat0) && isempty(Lon0)
        beep; uiwait(errordlg('Defina as coordenadas do ponto-base.','Erro','modal')); drawnow;
        return
    end
    if isempty(Lat0)
        beep; uiwait(errordlg('Defina a latitude do ponto-base.','Erro','modal')); drawnow;
        return
    end
    if isempty(Lon0)
        beep; uiwait(errordlg('Defina a longitude do ponto-base.','Erro','modal')); drawnow;
        return
    end
    if length(Dmag) == 1 && isnan(Dmag)
        beep; uiwait(errordlg('Defina a declinação magnética.','Erro','modal')); drawnow;
        return
    end
    
    set(handles.window,'Pointer','watch');
    
    Lat = DADOS(:,get(handles.ylist,'Value'));
    Lon = DADOS(:,get(handles.xlist,'Value'));
    
    [DE, DN] = latlong2dxdy(Lat0,Lon0,Lat,Lon);
    [RDL,Dist] = DeDn2RdlDist(DE,DN,Dmag);
    
    switch unit
        case 1
            unit = '(m)';
        case 2 % km
            Dist = Dist/1000;
            unit = '(km)';
        case 3 % NM
            Dist = Dist/1852;
            unit = '(NM)';
        case 4 % ft
            Dist = Dist/.3048;
            unit = '(ft)';
    end
    
    setappdata(handles.window,'tempdata',[RDL Dist]);
    
    set([handles.xlist handles.ylist handles.Ruler_btn handles.DataTips_btn handles.Events_btn handles.TestPoints_btn],'Enable','off');
    SetFrame(handles,1,'Defina o nome dos novos parâmetros:');
    set(handles.entry1txt,'String','RDL:');
    set(handles.entry2txt,'String','Dist:');
    SetEntrySize(handles,handles.entry1,2);
    SetEntrySize(handles,handles.entry2,2);
    set(handles.entry1,'Style','edit','String','RDL (°)');
    set(handles.entry2,'Style','edit','String',['Dist ' unit]);
    set([handles.entries(3:4) handles.entriestxt(3:4)],'Visible','off');
    
    % Plot Temporario
    set([handles.plot handles.selpts],'XData',NaN,'YData',NaN);
    set(handles.centerpt,'XData',NaN,'YData',NaN);
    set([handles.inipts handles.endpts handles.testptlbl handles.eventpts handles.eventlbl],'Visible','off');
    set(handles.plots(1,2),'XData',RDL,'YData',Dist);
    set(handles.graphs,'XLim',AutoLim(handles.plots(1,2)));
    set(handles.xlabel,'String','RDL (°)');
    set(handles.ylabel,'String',['Dist ' unit]);
    UpdateDataTips(hObject, eventdata, handles);
    
    setappdata(handles.window,'func','LatLong2RdlDist_2');
    
elseif strcmp(func,'LatLong2RdlDist_2') && ~cancel
    
    name1 = TrimParamName(get(handles.entry1,'String'),handles.maxparamlength);
    name2 = TrimParamName(get(handles.entry2,'String'),handles.maxparamlength);
    if isempty(name1) || isempty(name2)
        beep; uiwait(errordlg('Nome do parâmetro não pode ser vazio.','Erro','modal')); drawnow;
        return
    end 
    PARAM = InsertParam(PARAM,name1);
    PARAM = InsertParam(PARAM,name2);
    CheckRepParam(PARAM,name1);
    CheckRepParam(PARAM,name2);
    
    data  = getappdata(handles.window,'tempdata');
    DADOS = [DADOS(:,1:end-1), data, DADOS(:,end)];
    
    ycol = length(PARAM)-1;
    xcol = length(PARAM)-2;
    
    HideTemporaryPlot(hObject, eventdata, handles, xcol, ycol, PARAM);
    setappdata(handles.window,'func','none');
    
    setappdata(handles.window,'change',1);
    NewEvent(handles,['Parâmetros ''' name1 ''' e ''' name2 ''' criados por conversão de coordenadas.']);
    
elseif cancel
    
    set(handles.centerpt,'XData',NaN,'YData',NaN);
    HideTemporaryPlot(hObject, eventdata, handles);
    set(handles.graphs,'XLim',AutoLim(handles.plot));
    
end

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function RdlDist2LatLong_Callback(hObject, eventdata, handles)
global DADOS
% Conversao de RDL/Dist em Lat/Long

PARAM  = get(handles.xlist,'String');
func   = getappdata(handles.window,'func');
cancel = getappdata(handles.window,'cancel');

if strcmp(func,'none') && ~cancel
    
    set(handles.entry1txt,'String','Lat 0:');
    set(handles.entry2txt,'String','Long 0:');
    set(handles.entry3txt,'String','Unidade:');
    set(handles.entry4txt,'String','Declin.:');
    set(handles.entries(1:2),'Style','edit','String','');
    set(handles.entry3,'String',{'Metros','Quilômetros','Milhas Náuticas','Pés'},'Value',1);
    set(handles.entry4,'String',[{'Especificar'};PARAM],'Value',2);
    
    set([handles.entries handles.entriestxt handles.ok_btn handles.cancel_btn],'Visible','on');
    SetFrame(handles,2,'Indique distância, radial (°), ponto-base, unidade de entrada e declinação magnética:');
    set(handles.menulist,'Enable','off');
    UpdateButtonStatus(hObject, eventdata, handles);
    
    nRDL = findpar(PARAM,{'radial','rdl'});
    if ~isempty(nRDL);
        set(handles.xlist,'Value',nRDL);
        xlist_Callback(hObject, eventdata, handles);
    end
    nDist = findpar(PARAM,{'dist','dme'});
    if ~isempty(nDist);
        set(handles.ylist,'Value',nDist);
        ylist_Callback(hObject, eventdata, handles);
    end
    nDclin = findpar(PARAM,{'dmag','declin'});
    if ~isempty(nDclin);
        set(handles.entry4,'Value',nDclin+1);
    end
    
    ypar = SetUnits(get(handles.ylabel,'String'));
    if     strfind(ypar,'(km)')
        unit = 2;
    elseif strfind(ypar,'(NM)')
        unit = 3;
    elseif strfind(ypar,'(ft)')
        unit = 4;
    else
        unit = 1;
    end
    set(handles.entry3,'Value',unit);
    
    setappdata(handles.window,'func','RdlDist2LatLong_1');
    
elseif strcmp(func,'RdlDist2LatLong_1') && ~cancel
    
    [str,Lat0] = latlongread(get(handles.entry1,'String'),1);
    [str,Lon0] = latlongread(get(handles.entry2,'String'),2);
    
    unit = get(handles.entry3,'Value');
    
    switch get(handles.entry4,'Style')
        case 'popupmenu'
            Dmag = DADOS(:,get(handles.entry4,'Value')-1);
        case 'edit'
            Dmag = str2double(get(handles.entry4,'String'));
    end

    if isempty(Lat0) && isempty(Lon0)
        beep; uiwait(errordlg('Defina as coordenadas do ponto-base.','Erro','modal')); drawnow;
        return
    end
    if isempty(Lat0)
        beep; uiwait(errordlg('Defina a latitude do ponto-base.','Erro','modal')); drawnow;
        return
    end
    if isempty(Lon0)
        beep; uiwait(errordlg('Defina a longitude do ponto-base.','Erro','modal')); drawnow;
        return
    end
    if length(Dmag) == 1 && isnan(Dmag)
        beep; uiwait(errordlg('Defina a declinação magnética.','Erro','modal')); drawnow;
        return
    end
    
    set(handles.window,'Pointer','watch');
    
    RDL  = DADOS(:,get(handles.xlist,'Value'));
    Dist = DADOS(:,get(handles.ylist,'Value'));
    
    switch unit
        case 2 % km
            Dist = Dist*1000;
        case 3 % NM
            Dist = Dist*1852;
        case 4 % ft
            Dist = Dist*.3048;
    end
    
    [DE, DN] = RdlDist2DeDn(RDL,Dist,Dmag);
    [LAT, LONG] = dxdy2latlong(Lat0,Lon0,DN,DE);
    
    setappdata(handles.window,'tempdata',[LAT LONG]);
    
    set([handles.xlist handles.ylist handles.Ruler_btn handles.DataTips_btn handles.Events_btn handles.TestPoints_btn],'Enable','off');
    SetFrame(handles,1,'Defina o nome dos novos parâmetros:');
    set(handles.entry1txt,'String','Lat:');
    set(handles.entry2txt,'String','Long:');
    SetEntrySize(handles,handles.entry1,2);
    SetEntrySize(handles,handles.entry2,2);
    set(handles.entry1,'Style','edit','String','Latitude (°)');
    set(handles.entry2,'Style','edit','String','Longitude (°)');
    set([handles.entries(3:4) handles.entriestxt(3:4)],'Visible','off');
    
    % Plot Temporario
    set([handles.plot handles.selpts],'XData',NaN,'YData',NaN);
    set(handles.centerpt,'XData',Lon0,'YData',Lat0);
    set([handles.inipts handles.endpts handles.testptlbl handles.eventpts handles.eventlbl],'Visible','off');
    set(handles.plots(1,2),'XData',LONG,'YData',LAT);
    set(handles.graphs,'XLim',AutoLim([handles.plots(1,2) handles.centerpt]));
    set(handles.ylabel,'String','Latitude (°)');
    set(handles.xlabel,'String','Longitude (°)');
    UpdateDataTips(hObject, eventdata, handles);
    
    setappdata(handles.window,'func','RdlDist2LatLong_2');
    
elseif strcmp(func,'RdlDist2LatLong_2') && ~cancel
    
    name1 = TrimParamName(get(handles.entry1,'String'),handles.maxparamlength);
    name2 = TrimParamName(get(handles.entry2,'String'),handles.maxparamlength);
    if isempty(name1) || isempty(name2)
        beep; uiwait(errordlg('Nome do parâmetro não pode ser vazio.','Erro','modal')); drawnow;
        return
    end 
    PARAM = InsertParam(PARAM,name1);
    PARAM = InsertParam(PARAM,name2);
    CheckRepParam(PARAM,name1);
    CheckRepParam(PARAM,name2);
    
    data  = getappdata(handles.window,'tempdata');
    DADOS = [DADOS(:,1:end-1), data, DADOS(:,end)];
    
    ycol = length(PARAM)-2;
    xcol = length(PARAM)-1;
    
    set(handles.centerpt,'XData',NaN,'YData',NaN);
    HideTemporaryPlot(hObject, eventdata, handles, xcol, ycol, PARAM);
    setappdata(handles.window,'func','none');
    
    setappdata(handles.window,'change',1);
    NewEvent(handles,['Parâmetros ''' name1 ''' e ''' name2 ''' criados por conversão de coordenadas.']);
    
elseif cancel
    
    set(handles.centerpt,'XData',NaN,'YData',NaN);
    HideTemporaryPlot(hObject, eventdata, handles);
    set(handles.graphs,'XLim',AutoLim(handles.plot));
    
end

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function DeDn2RdlDist_Callback(hObject, eventdata, handles)
global DADOS
% Conversao de De/Dn em RDL/Dist

PARAM  = get(handles.xlist,'String');
func   = getappdata(handles.window,'func');
cancel = getappdata(handles.window,'cancel');

if strcmp(func,'none') && ~cancel
    
    set(handles.entry1txt,'String','Unidade:');
    set(handles.entry2txt,'String','Declin.:');
    set(handles.entry1,'String',{'Metros','Quilômetros','Milhas Náuticas','Pés'},'Value',1);
    set(handles.entry2,'String',[{'Especificar'};PARAM],'Value',2);
    
    set([handles.entries(1:2) handles.entriestxt(1:2) handles.ok_btn handles.cancel_btn],'Visible','on');
    SetFrame(handles,2,'Indique distância norte, distância leste, unidade de entrada e declinação magnética:');
    set(handles.menulist,'Enable','off');
    UpdateButtonStatus(hObject, eventdata, handles);
    
    nDE = findpar(PARAM,{'de (','dleste','deast'});
    if ~isempty(nDE);
        set(handles.xlist,'Value',nDE);
        xlist_Callback(hObject, eventdata, handles);
    end
    nDN = findpar(PARAM,{'dn (','dnort'});
    if ~isempty(nDN);
        set(handles.ylist,'Value',nDN);
        ylist_Callback(hObject, eventdata, handles);
    end
    nDclin = findpar(PARAM,{'dmag','declin'});
    if ~isempty(nDclin);
        set(handles.entry2,'Value',nDclin+1);
    end
    
    params = SetUnits([get(handles.xlabel,'String') get(handles.ylabel,'String')]);
    if     strfind(params,'(km)')
        unit = 2;
    elseif strfind(params,'(NM)')
        unit = 3;
    elseif strfind(params,'(ft)')
        unit = 4;
    else
        unit = 1;
    end
    set(handles.entry1,'Value',unit);
    
    setappdata(handles.window,'func','DeDn2RdlDist_1');
    
elseif strcmp(func,'DeDn2RdlDist_1') && ~cancel
    
    switch get(handles.entry2,'Style')
        case 'popupmenu'
            Dmag = DADOS(:,get(handles.entry2,'Value')-1);
        case 'edit'
            Dmag = str2double(get(handles.entry2,'String'));
    end
    
    if length(Dmag) == 1 && isnan(Dmag)
        beep; uiwait(errordlg('Defina a declinação magnética.','Erro','modal')); drawnow;
        return
    end
    
    set(handles.window,'Pointer','watch');
    
    unit = get(handles.entry1,'Value');
    
    DN = DADOS(:,get(handles.ylist,'Value'));
    DE = DADOS(:,get(handles.xlist,'Value'));
    
    switch unit
        case 1
            unit = '(m)';
        case 2 % km
            unit = '(km)';
        case 3 % NM
            unit = '(NM)';
        case 4 % ft
            unit = '(ft)';
    end
    
    [RDL,Dist] = DeDn2RdlDist(DE,DN,Dmag);
    
    setappdata(handles.window,'tempdata',[RDL Dist]);
    
    set([handles.xlist handles.ylist handles.Ruler_btn handles.DataTips_btn handles.Events_btn handles.TestPoints_btn],'Enable','off');
    SetFrame(handles,1,'Defina o nome dos novos parâmetros:');
    set(handles.entry1txt,'String','RDL:');
    set(handles.entry2txt,'String','Dist:');
    SetEntrySize(handles,handles.entry1,2);
    SetEntrySize(handles,handles.entry2,2);
    set(handles.entry1,'Style','edit','String','RDL (°)');
    set(handles.entry2,'Style','edit','String',['Dist ' unit]);
    
    % Plot Temporario
    set([handles.plot handles.selpts],'XData',NaN,'YData',NaN);
    set([handles.inipts handles.endpts handles.testptlbl handles.eventpts handles.eventlbl],'Visible','off');
    set(handles.plots(1,2),'XData',RDL,'YData',Dist);
    set(handles.graphs,'XLim',AutoLim(handles.plots(1,2)));
    set(handles.ylabel,'String','RDL (°)');
    set(handles.xlabel,'String',['Dist ' unit]);
    UpdateDataTips(hObject, eventdata, handles);
    
    setappdata(handles.window,'func','DeDn2RdlDist_2');
    
elseif strcmp(func,'DeDn2RdlDist_2') && ~cancel
    
    name1 = TrimParamName(get(handles.entry1,'String'),handles.maxparamlength);
    name2 = TrimParamName(get(handles.entry2,'String'),handles.maxparamlength);
    if isempty(name1) || isempty(name2)
        beep; uiwait(errordlg('Nome do parâmetro não pode ser vazio.','Erro','modal')); drawnow;
        return
    end 
    PARAM = InsertParam(PARAM,name1);
    PARAM = InsertParam(PARAM,name2);
    CheckRepParam(PARAM,name1);
    CheckRepParam(PARAM,name2);
    
    data  = getappdata(handles.window,'tempdata');
    DADOS = [DADOS(:,1:end-1), data, DADOS(:,end)];
    
    ycol = length(PARAM)-1;
    xcol = length(PARAM)-2;
    
    HideTemporaryPlot(hObject, eventdata, handles, xcol, ycol, PARAM);
    setappdata(handles.window,'func','none');
    
    setappdata(handles.window,'change',1);
    NewEvent(handles,['Parâmetros ''' name1 ''' e ''' name2 ''' criados por conversão de coordenadas.']);
    
elseif cancel
    
    HideTemporaryPlot(hObject, eventdata, handles);
    set(handles.graphs,'XLim',AutoLim(handles.plot));
    
end

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function RdlDist2DeDn_Callback(hObject, eventdata, handles)
global DADOS
% Conversao de RDL/Dist em De/Dn

PARAM  = get(handles.xlist,'String');
func   = getappdata(handles.window,'func');
cancel = getappdata(handles.window,'cancel');

if strcmp(func,'none') && ~cancel
    
    set(handles.entry1txt,'String','Unidade:');
    set(handles.entry2txt,'String','Declin.:');
    set(handles.entry1,'String',{'Metros','Quilômetros','Milhas Náuticas','Pés'},'Value',1);
    set(handles.entry2,'String',[{'Especificar'};PARAM],'Value',2);
    
    set([handles.entries(1:2) handles.entriestxt(1:2) handles.ok_btn handles.cancel_btn],'Visible','on');
    SetFrame(handles,2,'Indique distância, radial (°), unidade de entrada e declinação magnética:');
    set(handles.menulist,'Enable','off');
    UpdateButtonStatus(hObject, eventdata, handles);
    
    nRDL = findpar(PARAM,{'radial','rdl'});
    if ~isempty(nRDL);
        set(handles.xlist,'Value',nRDL);
        xlist_Callback(hObject, eventdata, handles);
    end
    nDist = findpar(PARAM,{'dist','dme'});
    if ~isempty(nDist);
        set(handles.ylist,'Value',nDist);
        ylist_Callback(hObject, eventdata, handles);
    end
    nDclin = findpar(PARAM,{'dmag','declin'});
    if ~isempty(nDclin);
        set(handles.entry2,'Value',nDclin+1);
    end
    
    ypar = SetUnits(get(handles.ylabel,'String'));
    if     strfind(ypar,'(km)')
        unit = 2;
    elseif strfind(ypar,'(NM)')
        unit = 3;
    elseif strfind(ypar,'(ft)')
        unit = 4;
    else
        unit = 1;
    end
    set(handles.entry1,'Value',unit);
    
    setappdata(handles.window,'func','RdlDist2DeDn_1');
    
elseif strcmp(func,'RdlDist2DeDn_1') && ~cancel
    
    switch get(handles.entry2,'Style')
        case 'popupmenu'
            Dmag = DADOS(:,get(handles.entry2,'Value')-1);
        case 'edit'
            Dmag = str2double(get(handles.entry2,'String'));
    end
    
    if length(Dmag) == 1 && isnan(Dmag)
        beep; uiwait(errordlg('Defina a declinação magnética.','Erro','modal')); drawnow;
        return
    end
    
    set(handles.window,'Pointer','watch');
    
    unit = get(handles.entry1,'Value');
    
    RDL  = DADOS(:,get(handles.xlist,'Value'));
    Dist = DADOS(:,get(handles.ylist,'Value'));
    
    switch unit
        case 1
            unit = '(m)';
        case 2 % km
            unit = '(km)';
        case 3 % NM
            unit = '(NM)';
        case 4 % ft
            unit = '(ft)';
    end
    
    [DE,DN] = RdlDist2DeDn(RDL,Dist,Dmag);
    
    setappdata(handles.window,'tempdata',[DN DE]);
    
    set([handles.xlist handles.ylist handles.Ruler_btn handles.DataTips_btn handles.Events_btn handles.TestPoints_btn],'Enable','off');
    SetFrame(handles,1,'Defina o nome dos novos parâmetros:');
    set(handles.entry1txt,'String','DNorte:');
    set(handles.entry2txt,'String','DLeste:');
    SetEntrySize(handles,handles.entry1,2);
    SetEntrySize(handles,handles.entry2,2);
    set(handles.entry1,'Style','edit','String',['DNorte ' unit]);
    set(handles.entry2,'Style','edit','String',['DLeste ' unit]);
    
    % Plot Temporario
    set([handles.plot handles.selpts],'XData',NaN,'YData',NaN);
    set([handles.inipts handles.endpts handles.testptlbl handles.eventpts handles.eventlbl],'Visible','off');
    set(handles.plots(1,2),'XData',DE,'YData',DN);
    set(handles.graphs,'XLim',AutoLim(handles.plots(1,2)));
    set(handles.ylabel,'String',['DNorte ' unit]);
    set(handles.xlabel,'String',['DLeste ' unit]);
    UpdateDataTips(hObject, eventdata, handles);
    
    setappdata(handles.window,'func','RdlDist2DeDn_2');
    
elseif strcmp(func,'RdlDist2DeDn_2') && ~cancel
    
    name1 = TrimParamName(get(handles.entry1,'String'),handles.maxparamlength);
    name2 = TrimParamName(get(handles.entry2,'String'),handles.maxparamlength);
    if isempty(name1) || isempty(name2)
        beep; uiwait(errordlg('Nome do parâmetro não pode ser vazio.','Erro','modal')); drawnow;
        return
    end 
    PARAM = InsertParam(PARAM,name1);
    PARAM = InsertParam(PARAM,name2);
    CheckRepParam(PARAM,name1);
    CheckRepParam(PARAM,name2);
    
    data  = getappdata(handles.window,'tempdata');
    DADOS = [DADOS(:,1:end-1), data, DADOS(:,end)];
    
    ycol = length(PARAM)-2;
    xcol = length(PARAM)-1;
    
    HideTemporaryPlot(hObject, eventdata, handles, xcol, ycol, PARAM);
    setappdata(handles.window,'func','none');
    
    setappdata(handles.window,'change',1);
    NewEvent(handles,['Parâmetros ''' name1 ''' e ''' name2 ''' criados por conversão de coordenadas.']);
    
elseif cancel
    
    HideTemporaryPlot(hObject, eventdata, handles);
    set(handles.graphs,'XLim',AutoLim(handles.plot));
    
end

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function SystemsConversion_Callback(hObject, eventdata, handles)
% Conversao de sistemas de referencia

PARAM = get(handles.xlist,'String');
xcol = get(handles.xlist,'Value');
ycol = get(handles.ylist,'Value');
Npar = length(PARAM);

togglelist = setdiff(findobj(handles.window,'Enable','on'),findobj(handles.window,'Style','text'));
set(togglelist,'Enable','off');
UpdateButtonStatus(hObject, eventdata, handles);

PARAM = RDAT_SysConv(PARAM);

set(togglelist,'Enable','on');
UpdateButtonStatus(hObject, eventdata, handles);

if ~isempty(PARAM)
    if xcol == Npar
        xcol = length(PARAM);
    end
    if ycol == Npar
        ycol = length(PARAM);
    end
    UpdateGraph(hObject, eventdata, handles, xcol, ycol, PARAM);
    
    setappdata(handles.window,'change',1);
    NewEvent(handles,'Parâmetros criados por conversão de sistemas.');
end

% --------------------------------------------------------------------
function Interp1D_Callback(hObject, eventdata, handles)
global DADOS
% Interpolação tabular unidimensional (Table Lookup)

PARAM  = get(handles.xlist,'String');
func   = getappdata(handles.window,'func');
cancel = getappdata(handles.window,'cancel');

if strcmp(func,'none') && ~cancel
    
    set(handles.entry1txt,'String','Param.:');
    set(handles.entry2txt,'String','Extrap.:');
    set(handles.entry3txt,'String','Curva:');
    set(handles.entry4txt,'String','Método:');
    set(handles.entry1,'String',PARAM,'Value',get(handles.ylist,'Value'));
    set(handles.entry2,'Style','popupmenu','String',{'NaN','0','Max / Min','Extrapolar'},'Value',3);
    set(handles.entry3,'Style','pushbutton','String','Localizar ...');
    set(handles.entry4,'Style','popupmenu','String',{'Linear','Vizinho','Spline','Cúbico'},'Value',1);
    
    set([handles.entries handles.entriestxt handles.ok_btn handles.cancel_btn],'Visible','on');
    SetFrame(handles,1,'Interpolação tabular unidimensional:');
    set([handles.menulist handles.xlist handles.ylist],'Enable','off');
    UpdateButtonStatus(hObject, eventdata, handles);
    
    setappdata(handles.window,'func','Interp1D_1');
    
elseif strcmp(func,'Interp1D_1') && ~cancel
    
    dat = getappdata(handles.window,'tempdata');
    if isempty(dat)
        beep; uiwait(errordlg('Curva de interpolação não definida.','Erro','modal')); drawnow;
        return
    end
    
    set(handles.window,'Pointer','watch');
    
    Xi = DADOS(:,get(handles.entry1,'Value'));
    X = dat(:,1);
    Y = dat(:,2);
    
    methodlist = {'linear','nearest','spline','cubic'};
    method = methodlist{get(handles.entry4,'Value')};
    
    switch get(handles.entry2,'Value')
        case 1 % NaN
            extrap = NaN;
        case 2 % 0
            extrap = 0;
        case 3 % Max / Min
            Xi(Xi>max(X)) = max(X);
            Xi(Xi<min(X)) = min(X);
            extrap = 'extrap';
        case 4 % extrap
            extrap = 'extrap';
    end
    
    try
        Yi = interp1(X,Y,Xi,method,extrap);
    catch
        beep; uiwait(errordlg(lasterr,'Erro','modal')); drawnow;
        return
    end
    
    setappdata(handles.window,'tempdata',Yi);
    ShowTemporaryPlot(hObject, eventdata, handles, Yi, '');
    
    setappdata(handles.window,'func','Interp1D_2');
    
elseif strcmp(func,'Interp1D_2') && ~cancel
    
    name = TrimParamName(get(handles.entry1,'String'),handles.maxparamlength);
    if isempty(name)
        beep; uiwait(errordlg('Nome do parâmetro não pode ser vazio.','Erro','modal')); drawnow;
        return
    end 
    PARAM = InsertParam(PARAM,name);
    CheckRepParam(PARAM,name);
    
    data  = getappdata(handles.window,'tempdata');
    DADOS = [DADOS(:,1:end-1), data, DADOS(:,end)];
    
    xcol = get(handles.xlist,'Value');
    if xcol == length(PARAM)-1
        xcol = xcol+1;
    end
    ycol = length(PARAM)-1;
    
    HideTemporaryPlot(hObject, eventdata, handles, xcol, ycol, PARAM);
    setappdata(handles.window,'func','none');
    
    setappdata(handles.window,'change',1);
    NewEvent(handles,['Parâmetro ''' name ''' criado por interpolação unidimensional.']);
    
elseif cancel
    
    HideTemporaryPlot(hObject, eventdata, handles);
    
end

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function Interp2D_Callback(hObject, eventdata, handles)
global DADOS
% Interpolação tabular bidimensional (Table Lookup)
% Formato de entrada:
%   NaN y1  y2  y3  ... ym
%   x1  z11 z12 z13 ... z1m
%   x2  z21 z22 z23 ...  :
%   :    :   :   :       :
%   xn  zn1 zn2 zn3 ... znm

PARAM  = get(handles.xlist,'String');
func   = getappdata(handles.window,'func');
cancel = getappdata(handles.window,'cancel');

if strcmp(func,'none') && ~cancel
    
    set(handles.entry1txt,'String','Extrap.:');
    set(handles.entry2txt,'String','Método:');
    set(handles.entry3txt,'String','Tabela:');
    set(handles.entry1,'Style','popupmenu','String',{'NaN','0','Max / Min'},'Value',3);
    set(handles.entry2,'Style','popupmenu','String',{'Linear','Vizinho','Spline','Cúbico'},'Value',1);
    set(handles.entry3,'Style','pushbutton','String','Localizar ...');
    
    set([handles.entries(1:3) handles.entriestxt(1:3) handles.ok_btn handles.cancel_btn],'Visible','on');
    SetFrame(handles,2,'Interpolação tabular bidimensional:');
    set(handles.menulist,'Enable','off');
    UpdateButtonStatus(hObject, eventdata, handles);
    
    setappdata(handles.window,'func','Interp2D_1');
    
elseif strcmp(func,'Interp2D_1') && ~cancel
    
    dat = getappdata(handles.window,'tempdata');
    if isempty(dat)
        beep; uiwait(errordlg('Tabela de interpolação não definida.','Erro','modal')); drawnow;
        return
    end
    
    set(handles.window,'Pointer','watch');
    
    Xi = DADOS(:,get(handles.xlist,'Value'));
    Yi = DADOS(:,get(handles.ylist,'Value'));
    X = dat(2:end,1);
    Y = dat(1,2:end);
    Z = dat(2:end,2:end)';
    
    extr = get(handles.entry1,'Value');
    methodlist = {'linear','nearest','spline','cubic'};
    method = methodlist{get(handles.entry2,'Value')};
    
    switch extr
        case 1 % NaN
            % Nada a fazer
        case 2 % 0
            % Alterar apos o calculo
        case 3 % Max / Min
            Xi(Xi>max(X)) = max(X);
            Xi(Xi<min(X)) = min(X);
            Yi(Yi>max(Y)) = max(Y);
            Yi(Yi<min(Y)) = min(Y);
    end
    
    try
        [X,Y] = meshgrid(X,Y);
        Zi = interp2(X,Y,Z,Xi,Yi,method);
        if extr == 2
            Zi(Xi>max(X)) = 0;
            Zi(Xi<min(X)) = 0;
            Zi(Yi>max(Y)) = 0;
            Zi(Yi<min(Y)) = 0;
        end
    catch
        beep; uiwait(errordlg(lasterr,'Erro','modal')); drawnow;
        Window_ButtonMotionFcn(hObject, eventdata, handles);
        return
    end
    
    setappdata(handles.window,'tempdata',Zi);
    ShowTemporaryPlot(hObject, eventdata, handles, Zi, '');
    set(handles.plots(1,2),'XData',DADOS(:,end));
    set(handles.xlabel,'String',denumber(PARAM{end}));
    set(handles.graphs,'XLim',AutoLim(handles.plots(1,2)));
    UpdateDataTips(hObject, eventdata, handles);
    
    setappdata(handles.window,'func','Interp2D_2');
    
elseif strcmp(func,'Interp2D_2') && ~cancel
    
    name = TrimParamName(get(handles.entry1,'String'),handles.maxparamlength);
    if isempty(name)
        beep; uiwait(errordlg('Nome do parâmetro não pode ser vazio.','Erro','modal')); drawnow;
        return
    end 
    PARAM = InsertParam(PARAM,name);
    CheckRepParam(PARAM,name);
    
    data  = getappdata(handles.window,'tempdata');
    DADOS = [DADOS(:,1:end-1), data, DADOS(:,end)];
    
    xcol = length(PARAM);
    ycol = length(PARAM)-1;
    
    HideTemporaryPlot(hObject, eventdata, handles, xcol, ycol, PARAM);
    setappdata(handles.window,'func','none');
    
    setappdata(handles.window,'change',1);
    NewEvent(handles,['Parâmetro ''' name ''' criado por interpolação bidimensional.']);
    
elseif cancel
    
    HideTemporaryPlot(hObject, eventdata, handles);
    set(handles.graphs,'XLim',AutoLim(handles.plot));
    
end

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function TrajIntegration_Callback(hObject, eventdata, handles)
global DADOS
% Integração de trajetoria (DLeste/DNorte                -> Deslocamento horizontal)
%                          (VLeste/VNorte x Tempo        -> Deslocamento horizontal)
%                          (aLeste/aNorte x Tempo² * 1/2 -> Deslocamento horizontal)

PARAM    = get(handles.xlist,'String');
func     = getappdata(handles.window,'func');
cancel   = getappdata(handles.window,'cancel');
timecols = getappdata(handles.window,'timecols');

if strcmp(func,'none') && ~cancel
    
    if ~isempty(timecols)
        nT = timecols(1);
    else
        nT = 1;
    end 
    
    set(handles.entry1txt,'String','Entrada:');
    set(handles.entry2txt,'String','Tempo:');
    set(handles.entry3txt,'String','Vy 0:');
    set(handles.entry4txt,'String','Vx 0:');
    set(handles.entry1,'String',{'Posição','Velocidade','Aceleração','Latitude/Longitude'},'Value',1);
    set(handles.entry2,'String',PARAM,'Value',nT);
    set(handles.entry3,'Style','edit','String','0');
    set(handles.entry4,'Style','edit','String','0');
    
    set([handles.entry1 handles.entry1txt handles.ok_btn handles.cancel_btn],'Visible','on');
    SetFrame(handles,2,'Indique as componentes de trajetória:');
    set(handles.menulist,'Enable','off');
    UpdateButtonStatus(hObject, eventdata, handles);
    
    setappdata(handles.window,'func','TrajIntegration_1');
    entry2_Callback(hObject, eventdata, handles)
    
elseif strcmp(func,'TrajIntegration_1') && ~cancel
    
    set(handles.window,'Pointer','watch');
    
    opt = get(handles.entry1,'Value');
    
    if opt == 3 % Acel
        Vx0 = str2double(get(handles.entry4,'String'));
        Vy0 = str2double(get(handles.entry3,'String'));
        if isnan(Vx0) || isnan(Vy0)
            beep; uiwait(errordlg('Parâmetros de entrada incoerentes.','Erro','modal')); drawnow;
            Window_ButtonMotionFcn(hObject, eventdata, handles);
            return
        end
    end
    
    X = DADOS(:,get(handles.xlist,'Value'));
    Y = DADOS(:,get(handles.ylist,'Value'));
    
    Nnan = union(find(isnan(X)),find(isnan(Y)));
    if ~isempty(Nnan)
        if length(Nnan) == 1
            firstline = 'Encontrado 1 ponto inválido nos dados de trajetória.';
        else
            firstline = ['Encontrados ' num2str(length(Nnan)) ' pontos inválidos nos dados de trajetória.'];
        end
        button = questdlg({firstline,'O que deseja fazer?'},'Confirmação','Interpolar','Repetir','Cancelar','Interpolar'); drawnow;
        
        switch button
            case 'Interpolar'
                X = denan(X);
                Y = denan(Y);
            case 'Repetir'
                X = denan(X,1);
                Y = denan(Y,1);
            otherwise
                Window_ButtonMotionFcn(hObject, eventdata, handles);
                return
        end
    end
    
    if opt == 2 || opt == 3
        
        % Cheque do parâmetro tempo
        T = DADOS(:,get(handles.entry2,'Value'));
        [ok, ndc, nna] = IsTimeOk(T);
        if ~ok
            beep; uiwait(errordlg({'Parâmetro de tempo não é adequado:',' ',...
                    ['Pontos inválidos: ' num2str(length(nna))],...
                    ['Pontos não crescentes: ' num2str(length(ndc))]},'Erro','modal')); drawnow;
            Window_ButtonMotionFcn(hObject, eventdata, handles);
            return
        end
        
    end
    
    if opt == 4 % Lat/Long
        Lat0 = nanmean(Y);
        Lon0 = nanmean(X);
        [X, Y] = latlong2dxdy(Lat0,Lon0,Y,X);
    end
    
    % Integração
    if length(X) == 1;
        D = 0;
    else
        switch opt
            case 2 % Velocidade
                Vx = .5* (X(1:end-1) + X(2:end));
                Vy = .5* (Y(1:end-1) + Y(2:end));
                X  = [0; cumsum(Vx.*diff(T))];
                Y  = [0; cumsum(Vy.*diff(T))];
            case 3 % Aceleração
                ax = .5* (X(1:end-1) + X(2:end));
                ay = .5* (Y(1:end-1) + Y(2:end));
                X  = [0; Vx0.*cumsum(diff(T)) + .5*cumsum(ax.*diff(T).^2)];
                Y  = [0; Vy0.*cumsum(diff(T)) + .5*cumsum(ay.*diff(T).^2)];
        end
        D = [0; cumsum(sqrt(diff(X).^2 + diff(Y).^2))];
    end
    
    ylabel = SetUnits(get(handles.ylabel,'String'));
    switch opt
        case 1 % Posição
            if     ~isempty(strfind(ylabel,'(NM)')), unit = ' (NM)';
            elseif ~isempty(strfind(ylabel,'(m)' )), unit = ' (m)';
            elseif ~isempty(strfind(ylabel,'(km)')), unit = ' (km)';
            elseif ~isempty(strfind(ylabel,'(ft)')), unit = ' (ft)';
            else,   unit = ''; end
        case {2,3} % Velocidade ou Aceleração
            if     ~isempty(strfind(ylabel,'(m/s')),  unit = ' (m)';
            elseif ~isempty(strfind(ylabel,'(ft/s')), unit = ' (ft)';
            else,   unit = ''; end
        case 4 % Lat/Long
            unit = ' (m)';
    end
    
    setappdata(handles.window,'tempdata',D);
    set(handles.xlist,'Value',length(PARAM));
    xlist_Callback(hObject, eventdata, handles);
    ShowTemporaryPlot(hObject, eventdata, handles, D, ['Deslocamento' unit]);
    
    setappdata(handles.window,'func','TrajIntegration_2');
    
elseif strcmp(func,'TrajIntegration_2') && ~cancel
    
    name = TrimParamName(get(handles.entry1,'String'),handles.maxparamlength);
    if isempty(name)
        beep; uiwait(errordlg('Nome do parâmetro não pode ser vazio.','Erro','modal')); drawnow;
        return
    end 
    PARAM = InsertParam(PARAM,name);
    CheckRepParam(PARAM,name);
    
    data  = getappdata(handles.window,'tempdata');
    DADOS = [DADOS(:,1:end-1), data, DADOS(:,end)];
    
    xcol = get(handles.xlist,'Value');
    if xcol == length(PARAM)-1
        xcol = xcol+1;
    end
    ycol = length(PARAM)-1;
    
    HideTemporaryPlot(hObject, eventdata, handles, xcol, ycol, PARAM);
    set(handles.graphs,'XLim',AutoLim(handles.plot));
    setappdata(handles.window,'func','none');
    
    setappdata(handles.window,'change',1);
    NewEvent(handles,['Parâmetro ''' name ''' criado por integração de trajetória.']);
    
elseif cancel
    
    HideTemporaryPlot(hObject, eventdata, handles);
    set(handles.graphs,'XLim',AutoLim(handles.plot));
    
end

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function CourseCalculation_Callback(hObject, eventdata, handles)
global DADOS
% Obtenção do curso a partir de distancia ou velocidade leste/norte

PARAM  = get(handles.xlist,'String');
func   = getappdata(handles.window,'func');
cancel = getappdata(handles.window,'cancel');
steplist = [1 2 4 6 8 10 20 40];

if strcmp(func,'none') && ~cancel
    
    set(handles.entry1txt,'String','Entrada:');
    set(handles.entry2txt,'String','Passo:');
    set(handles.entry4txt,'String','Declin.:');
    set(handles.entry1,'String',{'Posição','Velocidade','Latitude/Longitude'},'Value',1);
    set(handles.entry2,'Style','popup','String',num2str2(steplist'),'Value',1);
    set(handles.entry4,'String',[{'Especificar'};PARAM],'Value',2);
    
    set([handles.entries([1 2 4]) handles.entriestxt([1 2 4]) handles.ok_btn handles.cancel_btn],'Visible','on');
    SetFrame(handles,2,'Indique as componentes de trajetória norte e leste, passo e declinação magnética:');
    set(handles.menulist,'Enable','off');
    UpdateButtonStatus(hObject, eventdata, handles);
    
    nDE = findpar(PARAM,{'de (','dleste','deast'});
    if ~isempty(nDE);
        set(handles.xlist,'Value',nDE);
        xlist_Callback(hObject, eventdata, handles);
    end
    nDN = findpar(PARAM,{'dn (','dnort'});
    if ~isempty(nDN);
        set(handles.ylist,'Value',nDN);
        ylist_Callback(hObject, eventdata, handles);
    end
    nDclin = findpar(PARAM,{'dmag','declin'});
    if ~isempty(nDclin);
        set(handles.entry4,'Value',nDclin+1);
    end
    
    setappdata(handles.window,'func','CourseCalculation_1');
    
elseif strcmp(func,'CourseCalculation_1') && ~cancel
    
    switch get(handles.entry4,'Style')
        case 'popupmenu'
            Dmag = DADOS(:,get(handles.entry4,'Value')-1);
        case 'edit'
            Dmag = str2double(get(handles.entry4,'String'));
    end
    
    if length(Dmag) == 1 && isnan(Dmag)
        beep; uiwait(errordlg('Defina a declinação magnética.','Erro','modal')); drawnow;
        return
    end
    
    set(handles.window,'Pointer','watch');
    
    opt = get(handles.entry1,'Value');
    step = steplist(get(handles.entry2,'Value'));
    E = DADOS(:,get(handles.xlist,'Value'));
    N = DADOS(:,get(handles.ylist,'Value'));
    
    % Eliminação de NaN dos dados de entrada
    nnan = union(find(isnan(E)),find(isnan(N)));
    if ~isempty(nnan)
        E = denan(E);
        N = denan(N);
    end
    
    if opt == 3 % Lat/Long
        Lat0 = nanmean(N);
        Lon0 = nanmean(E);
        [E, N] = latlong2dxdy(Lat0,Lon0,N,E);
    end
    
    if step > 1;
        dE = 0*E;
        dN = 0*N;
    end
    
    if length(E) == 1
        Crs = 0;
    else
        
        switch opt
            case {1,3} % Posição ou Lat/Long
                
                if step == 1
                    dE = [diff(E); 0];
                    dN = [diff(N); 0];
                else
                    for n = 1:length(E)
                        dE(n) = E(min(length(E),n+step/2)) - E(max(1,n-step/2));
                        dN(n) = N(min(length(N),n+step/2)) - N(max(1,n-step/2));
                    end
                end
                Crs = mod((180/pi*atan2(dE,dN)-Dmag),360);
                
            case 2 % Velocidade
                
                if step == 1
                    dE = E;
                    dN = N;
                else
                    for n = 1:length(E)
                        dE(n) = nanmean( E(max(1,n-step/2) : min(length(E),n+step/2)) );
                        dN(n) = nanmean( N(max(1,n-step/2) : min(length(N),n+step/2)) );
                    end
                end
                Crs = mod((180/pi*atan2(dE,dN)-Dmag),360);
                
        end
    end
    
    % Reatribuição de NaN em Crs
    if ~isempty(nnan)
        Crs(nnan) = NaN;
    end
    
    setappdata(handles.window,'tempdata',Crs);
    set(handles.xlist,'Value',length(PARAM));
    xlist_Callback(hObject, eventdata, handles);
    ShowTemporaryPlot(hObject, eventdata, handles, Crs, 'Curso (°)');
    
    setappdata(handles.window,'func','CourseCalculation_2');
    
elseif strcmp(func,'CourseCalculation_2') && ~cancel
    
    name = TrimParamName(get(handles.entry1,'String'),handles.maxparamlength);
    if isempty(name)
        beep; uiwait(errordlg('Nome do parâmetro não pode ser vazio.','Erro','modal')); drawnow;
        return
    end 
    PARAM = InsertParam(PARAM,name);
    CheckRepParam(PARAM,name);
    
    data  = getappdata(handles.window,'tempdata');
    DADOS = [DADOS(:,1:end-1), data, DADOS(:,end)];
    
    xcol = get(handles.xlist,'Value');
    if xcol == length(PARAM)-1
        xcol = xcol+1;
    end
    ycol = length(PARAM)-1;
    
    HideTemporaryPlot(hObject, eventdata, handles, xcol, ycol, PARAM);
    set(handles.graphs,'XLim',AutoLim(handles.plot));
    setappdata(handles.window,'func','none');
    
    setappdata(handles.window,'change',1);
    NewEvent(handles,['Parâmetro ''' name ''' criado por obtenção de curso.']);
    
elseif cancel
    
    HideTemporaryPlot(hObject, eventdata, handles);
    set(handles.graphs,'XLim',AutoLim(handles.plot));
    
end

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function DmagModel_Callback(hObject, eventdata, handles)
global DADOS
% Obtenção da declinação magnética pelo Modelo Magnético Terrestre (WMM)

PARAM  = get(handles.xlist,'String');
xcol   = get(handles.xlist,'Value');
func   = getappdata(handles.window,'func');
cancel = getappdata(handles.window,'cancel');
properties = getappdata(handles.window,'properties');

if strcmp(func,'none') && ~cancel
    
    set(handles.entry1txt,'String','Lat.:');
    set(handles.entry2txt,'String','Long.:');
    set(handles.entry3txt,'String','Alt.:');
    set(handles.entry4txt,'String','Data:');
    set(handles.entries(1:3),'String',PARAM);
    set(handles.entry4,'Style','edit','String','');
    
    set([handles.entries handles.entriestxt handles.ok_btn handles.cancel_btn],'Visible','on');
    SetFrame(handles,1,'Indique latitude, longitude, altitude geodética (ft) e data do voo:');
    set([handles.menulist handles.xlist handles.ylist],'Enable','off');
    UpdateButtonStatus(hObject, eventdata, handles);
    
    setappdata(handles.window,'func','DmagModel_1');
    
    nLat = findpar(PARAM,'lat');
    nLon = findpar(PARAM,{'long','lon'});
    nAlt = findpar(PARAM,{'alt','zp'});
    if isempty(nLat)
        nLat = get(handles.ylist,'Value');
    end
    if isempty(nLon)
        nLon = get(handles.xlist,'Value');
    end
    if isempty(nAlt)
        nAlt = 1;
    end
    set(handles.entry1,'Value',nLat);
    set(handles.entry2,'Value',nLon);
    set(handles.entry3,'Value',nAlt);
    entry2_Callback(hObject, eventdata, handles);
    
    if isfield(properties,'date')
        set(handles.entry4,'String',properties.date);
    end
   
    if ~isempty(strfind(lower([get(handles.xlabel,'String') get(handles.ylabel,'String')]),'semicirc'))
        uiwait(warndlg({'Foi detectada unidade "SemiCírculo" no nome do(s) parâmetro(s).',...
                'A operação deve ser realizada em graus.'},'Aviso','modal')); drawnow;
    end    
    
elseif strcmp(func,'DmagModel_1') && ~cancel
    
    lat = DADOS(:,get(handles.entry1,'Value')); lat(lat<-90 )  = -90  ; lat(lat>90 ) = 90;
    lon = DADOS(:,get(handles.entry2,'Value')); lon(lon<-180)  = -180 ; lon(lon>180) = 180;
    alt = DADOS(:,get(handles.entry3,'Value')); alt(alt<-2000) = -2000; alt(alt>1e5) = 1e5;
    [void, void, dat] = dateread(get(handles.entry4,'String'));
    
    if isempty(dat)
        beep; uiwait(errordlg('Informe a data do voo.','Erro','modal')); drawnow;
        return
    end
        
    [void, void, void, void, epoch] = geomag(0, 0, 0, dat);
    if dat < epoch || dat >= epoch+5
        button = questdlg({'Não foi encontrado o arquivo de coeficientes correspondente'...
                ['à epoca do voo (' num2str(fix(dat)) ' a ' num2str(fix(dat)+5) ').'],...
                ['Deseja prosseguir usando a época atual (' num2str(epoch) ' a ' num2str(epoch+5) ')?']},...
            'Confirmação','Sim','Não','Sim'); drawnow;
        if ~strcmp(button,'Sim')
            return
        end
    end
    
    set(handles.window,'Pointer','watch');
    
    h = waitdlg('Calculando declinação magnética ...','Aguarde','modal');
    Dmag = geomag(alt, lat, lon, dat);
    try, delete(h); end
    
    setappdata(handles.window,'tempdata',Dmag);
    ShowTemporaryPlot(hObject, eventdata, handles, Dmag, 'Declin. mag. (°)');
    
    setappdata(handles.window,'func','DmagModel_2');
    
elseif strcmp(func,'DmagModel_2') && ~cancel
    
    name = TrimParamName(get(handles.entry1,'String'),handles.maxparamlength);
    if isempty(name)
        beep; uiwait(errordlg('Nome do parâmetro não pode ser vazio.','Erro','modal')); drawnow;
        return
    end 
    PARAM = InsertParam(PARAM,name);
    CheckRepParam(PARAM,name);
    
    data  = getappdata(handles.window,'tempdata');
    DADOS = [DADOS(:,1:end-1), data, DADOS(:,end)];
    
    if xcol == length(PARAM)-1
        xcol = xcol+1;
    end
    ycol = length(PARAM)-1;
    
    HideTemporaryPlot(hObject, eventdata, handles, xcol, ycol, PARAM);
    setappdata(handles.window,'func','none');
    
    setappdata(handles.window,'change',1);
    NewEvent(handles,'Declinação magnética obtida do modelo magnético terrestre.');
    
elseif cancel
    
    HideTemporaryPlot(hObject, eventdata, handles);
    
end

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function DmagDpsi_Callback(hObject, eventdata, handles)
global DADOS
% Obtenção da declinação magnética pela diferença entre proa verdadeira e magnética

PARAM  = get(handles.xlist,'String');
ycol   = get(handles.ylist,'Value');
xcol   = get(handles.xlist,'Value');
func   = getappdata(handles.window,'func');
cancel = getappdata(handles.window,'cancel');

if strcmp(func,'none') && ~cancel
    
    set(handles.entry1txt,'String','Verd.:');
    set(handles.entry2txt,'String','Mag.:');
    set([handles.entry1 handles.entry2],'String',PARAM,'Value',ycol);
    
    set([handles.entries(1:2) handles.entriestxt(1:2) handles.ok_btn handles.cancel_btn],'Visible','on');
    SetFrame(handles,1,'Indique a proa verdadeira e a proa magnética (graus):');
    set([handles.menulist handles.xlist handles.ylist],'Enable','off');
    UpdateButtonStatus(hObject, eventdata, handles);
    
    set(handles.xlist,'Value',length(PARAM));
    xlist_Callback(hObject, eventdata, handles);
    entry2_Callback(hObject, eventdata, handles);

    setappdata(handles.window,'func','DmagDpsi_1');
    
elseif strcmp(func,'DmagDpsi_1') && ~cancel
    
    set(handles.window,'Pointer','watch');
    
    Tpsi = DADOS(:,get(handles.entry1,'Value'));
    Mpsi = DADOS(:,get(handles.entry2,'Value'));
    
    Dmag = mod(Tpsi-Mpsi,360);
    Dmag(Dmag>180) = Dmag(Dmag>180) - 360;
    setappdata(handles.window,'tempdata',Dmag);
    
    ShowTemporaryPlot(hObject, eventdata, handles, Dmag, 'Declin. mag. (°)');
    set(handles.graphs,'XLim',AutoLim(handles.plots(1,2)));
    
    setappdata(handles.window,'func','DmagDpsi_2');
    
elseif strcmp(func,'DmagDpsi_2') && ~cancel
    
    name = TrimParamName(get(handles.entry1,'String'),handles.maxparamlength);
    if isempty(name)
        beep; uiwait(errordlg('Nome do parâmetro não pode ser vazio.','Erro','modal')); drawnow;
        return
    end 
    PARAM = InsertParam(PARAM,name);
    CheckRepParam(PARAM,name);
    
    data  = getappdata(handles.window,'tempdata');
    DADOS = [DADOS(:,1:end-1), data, DADOS(:,end)];
    
    if xcol == length(PARAM)-1
        xcol = xcol+1;
    end
    ycol = length(PARAM)-1;
    
    HideTemporaryPlot(hObject, eventdata, handles, xcol, ycol, PARAM);
    setappdata(handles.window,'func','none');
    
    setappdata(handles.window,'change',1);
    NewEvent(handles,'Declinação magnética obtida por diferença entre proas.');
    
elseif cancel
    
    HideTemporaryPlot(hObject, eventdata, handles);
    
end

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function PsiConversion_Callback(hObject, eventdata, handles)
global DADOS
% Conversao entre proas a partir da declinação magnética

PARAM  = get(handles.xlist,'String');
xcol   = get(handles.xlist,'Value');
func   = getappdata(handles.window,'func');
cancel = getappdata(handles.window,'cancel');

if strcmp(func,'none') && ~cancel
    
    set(handles.entry1txt,'String','Oper.:');
    set(handles.entry2txt,'String','Declin.:');
    set(handles.entry1,'String',{'Geo --> Mag','Mag --> Geo'},'Value',1);
    set(handles.entry2,'String',[{'Especificar'};PARAM],'Value',2);
    
    set([handles.entries(1:2) handles.entriestxt(1:2) handles.ok_btn handles.cancel_btn],'Visible','on');
    SetFrame(handles,2,'Indique proa de entrada, operação e declinação magnética (°):');
    set(handles.menulist,'Enable','off');
    UpdateButtonStatus(hObject, eventdata, handles);
    
    setappdata(handles.window,'func','PsiConversion_1');
    
elseif strcmp(func,'PsiConversion_1') && ~cancel
    
    Psi1 = DADOS(:,get(handles.ylist,'Value'));
    oper = get(handles.entry1,'Value');
    
    switch get(handles.entry2,'Style')
        case 'popupmenu'
            Dmag = DADOS(:,get(handles.entry2,'Value')-1);
        case 'edit'
            Dmag = str2double(get(handles.entry2,'String'));
    end
    
    if length(Dmag) == 1 && isnan(Dmag)
        beep; uiwait(errordlg('Defina a declinação magnética.','Erro','modal')); drawnow;
        return
    end
        
    set(handles.window,'Pointer','watch');
    
    switch oper
        case 1 % Geo --> Mag
            Psi2 = Psi1 - Dmag;
            name = 'Proa Mag (°)';
        case 2 % Mag --> Geo
            Psi2 = Psi1 + Dmag;
            name = 'Proa Verd (°)';
    end
    
    Psi2 = mod(Psi2,360);
    
    setappdata(handles.window,'tempdata',Psi2);
    ShowTemporaryPlot(hObject, eventdata, handles, Psi2, name);
    
    setappdata(handles.window,'func','PsiConversion_2');
    
elseif strcmp(func,'PsiConversion_2') && ~cancel
    
    name = TrimParamName(get(handles.entry1,'String'),handles.maxparamlength);
    if isempty(name)
        beep; uiwait(errordlg('Nome do parâmetro não pode ser vazio.','Erro','modal')); drawnow;
        return
    end 
    PARAM = InsertParam(PARAM,name);
    CheckRepParam(PARAM,name);
    
    data  = getappdata(handles.window,'tempdata');
    DADOS = [DADOS(:,1:end-1), data, DADOS(:,end)];
    
    if xcol == length(PARAM)-1
        xcol = xcol+1;
    end
    ycol = length(PARAM)-1;
    
    HideTemporaryPlot(hObject, eventdata, handles, xcol, ycol, PARAM);
    setappdata(handles.window,'func','none');
    
    setappdata(handles.window,'change',1);
    NewEvent(handles,'Novo parâmetro obtido por conversão entre proas.');
    
elseif cancel
    
    HideTemporaryPlot(hObject, eventdata, handles);
    
end

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function NumericInteg_Callback(hObject, eventdata, handles)
global DADOS
% Integração numerica do parâmetro y = f(t) pelo metodo trapezoidal

PARAM    = get(handles.xlist,'String');
func     = getappdata(handles.window,'func');
cancel   = getappdata(handles.window,'cancel');
timecols = getappdata(handles.window,'timecols');

if strcmp(func,'none') && ~cancel
    
    if ~isempty(timecols) && ~any(get(handles.xlist,'Value')==timecols)
        set(handles.xlist,'Value',timecols(1));
        xlist_Callback(hObject, eventdata, handles);
    end
    
    set(handles.entry1txt,'String','Opção:');
    set(handles.entry2txt,'String','Valor:');
    set(handles.entry1,'String',{'Valor inicial nulo','Valor médio nulo','Valor final nulo','Especif. valor inicial'},'Value',1);
    set(handles.entry2,'Style','Edit','String','0');
    
    set([handles.entry1 handles.entry1txt handles.ok_btn handles.cancel_btn],'Visible','on');
    SetFrame(handles,2,'Indique os parâmetros para integração:');
    set(handles.menulist,'Enable','off');
    UpdateButtonStatus(hObject, eventdata, handles);
    
    setappdata(handles.window,'func','NumInteg_1');
    
elseif strcmp(func,'NumInteg_1') && ~cancel
    
    set(handles.window,'Pointer','watch');
    
    y = DADOS(:,get(handles.ylist,'Value'));
    t = DADOS(:,get(handles.xlist,'Value'));
    opt = get(handles.entry1,'Value');
    Y0 = str2double(get(handles.entry2,'String'));
    
    if opt == 4 && isnan(Y0);
        beep; uiwait(errordlg('Parâmetro de entrada incoerente.','Erro','modal')); drawnow;
        Window_ButtonMotionFcn(hObject, eventdata, handles);
        return
    end
    
    % Cheque do parâmetro de tempo    
    [ok, ndc, nna] = IsTimeOk(t);
    if ~ok
        beep; uiwait(errordlg({'Parâmetro x não é adequado:',' ',...
                ['Pontos inválidos: ' num2str(length(nna))],...
                ['Pontos não crescentes: ' num2str(length(ndc))]},'Erro','modal')); drawnow;
        Window_ButtonMotionFcn(hObject, eventdata, handles);
        return
    end
    
    % Cheque do parâmetro y
    nna = length(find(isnan(y)));
    if nna
        if nna == 1
            firstline = 'Encontrado 1 ponto inválido no parâmetro y.';
        else
            firstline = ['Encontrados ' num2str(nna) ' pontos inválidos no parâmetro y.'];
        end
        button = questdlg({firstline,'O que deseja fazer?'},'Confirmação','Interpolar','Repetir','Zerar','Interpolar'); drawnow;
        
        switch button
            case 'Interpolar'
                y = denan(y);
            case 'Repetir'
                y = denan(y,1);
            case 'Zerar'
                y(isnan(y)) = 0;
            otherwise
                Window_ButtonMotionFcn(hObject, eventdata, handles);
                return
        end
    end
    
    % Loop de integração
    if length(y) == 1
        Y = 0;
    else
        Y = zeros(size(y));
        for n = 2:length(Y)
            Y(n) = Y(n-1) + .5*(y(n)+y(n-1)) * (t(n)-t(n-1));
        end
    end
    
    switch opt
        case 1
            Y0 = 0;
        case 2
            Y0 = -mean(Y);
        case 3
            Y0 = -Y(end);
        case 4
            Y0 = Y0;
    end
    Y = Y + Y0;
    
    setappdata(handles.window,'tempdata',Y);
    ShowTemporaryPlot(hObject, eventdata, handles, Y, '');
    
    setappdata(handles.window,'func','NumInteg_2');
    
elseif strcmp(func,'NumInteg_2') && ~cancel
    
    name = TrimParamName(get(handles.entry1,'String'),handles.maxparamlength);
    if isempty(name)
        beep; uiwait(errordlg('Nome do parâmetro não pode ser vazio.','Erro','modal')); drawnow;
        return
    end 
    PARAM = InsertParam(PARAM,name);
    CheckRepParam(PARAM,name);
    
    data  = getappdata(handles.window,'tempdata');
    DADOS = [DADOS(:,1:end-1), data, DADOS(:,end)];
    
    xcol = get(handles.xlist,'Value');
    if xcol == length(PARAM)-1
        xcol = xcol+1;
    end
    ycol = length(PARAM)-1;
    
    HideTemporaryPlot(hObject, eventdata, handles, xcol, ycol, PARAM);
    setappdata(handles.window,'func','none');
    
    setappdata(handles.window,'change',1);
    NewEvent(handles,['Parâmetro ''' name ''' criado por integração numérica.']);
    
elseif cancel
    
    HideTemporaryPlot(hObject, eventdata, handles);
    set(handles.graphs,'XLim',AutoLim(handles.plot));
    
end

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function NumericDiffer_Callback(hObject, eventdata, handles)
global DADOS
% Diferenciação numerica do parâmetro y = f(x) pelos metodos dy/dx ou ajuste de curva

PARAM    = get(handles.xlist,'String');
func     = getappdata(handles.window,'func');
cancel   = getappdata(handles.window,'cancel');
timecols = getappdata(handles.window,'timecols');
steplist = [-1 1 2 4 6 8 10 20 40];

if strcmp(func,'none') && ~cancel
    
    if ~isempty(timecols) && ~any(get(handles.xlist,'Value')==timecols)
        set(handles.xlist,'Value',timecols(1));
        xlist_Callback(hObject, eventdata, handles);
    end
    
    set(handles.entry1txt,'String','Método:');
    set(handles.entry2txt,'String','Passo:');
    set(handles.entry3txt,'String','Tipo:');
    set(handles.entry1,'String',{'dy/dx','Ajuste'},'Value',1);
    set(handles.entry2,'String',{'1 (anterior)','1 (seguinte)','2','4','6','8','10','20','40'},'Value',3);
    set(handles.entry3,'String',{'Linear','Quadrático','Cúbico'},'Value',1);
    
    set([handles.entries(1:2) handles.entriestxt(1:2) handles.ok_btn handles.cancel_btn],'Visible','on');
    SetFrame(handles,2,'Indique os parâmetros para diferenciação:');
    set(handles.menulist,'Enable','off');
    UpdateButtonStatus(hObject, eventdata, handles);
    
    setappdata(handles.window,'func','NumDiffer_1');
    
elseif strcmp(func,'NumDiffer_1') && ~cancel
    
    y = DADOS(:,get(handles.ylist,'Value'));
    t = DADOS(:,get(handles.xlist,'Value'));
    opt = get(handles.entry1,'Value');
    stp = steplist(get(handles.entry2,'Value'));
    ord = get(handles.entry3,'Value');
    
    if opt == 1
        mtd = 'dy/dx';
    else
        mtd = 'de ajuste de curva';
    end
    button = questdlg({['Diferenciação numérica pelo método ' mtd '.'],...
            ' ','CERTIFIQUE-SE QUE O PARÂMETRO Y NÃO CONTENHA RUÍDO!',...
            ' ','Deseja prosseguir?',' '},'Confirmação','Sim','Não','Não'); drawnow;
    if ~strcmp(button,'Sim')
        return
    end
    
    set(handles.window,'Pointer','watch');
    
    % Cheque do parâmetro tempo
    [ok, ndc, nna] = IsTimeOk(t);
    if ~ok
        beep; uiwait(errordlg({'Parâmetro x não é adequado:',' ',...
                ['Pontos inválidos: ' num2str(length(nna))],...
                ['Pontos não crescentes: ' num2str(length(ndc))]},'Erro','modal')); drawnow;
        Window_ButtonMotionFcn(hObject, eventdata, handles);
        return
    end
    
    % Eliminação de NaN em y
    nnan = find(isnan(y));
    if ~isempty(nnan)
        y = denan(y);
    end
    
    % Diferenciação
    if length(y) == 1
        ydot = 0;
        
    elseif length(y) == 2
        ydot = diff(y)./diff(t);
        ydot = [ydot(1); ydot];
    else
        
        switch stp
            case 1 % Intervalo anterior
                ydot = diff(y)./diff(t);
                ydot = [ydot(1); ydot];
                
            case 2 % Intervalo seguinte
                ydot = diff(y)./diff(t);
                ydot = [ydot; ydot(end)];
                
            otherwise % Intervalo ao redor do ponto
                ydot = zeros(size(y));
                N = length(y);
                
                if opt == 1 % dy/dx
                    for n = 1:length(y)
                        ydot(n) = ( y(min(N,n+stp/2))-y(max(1,n-stp/2)) ) / ( t(min(N,n+stp/2))-t(max(1,n-stp/2)) );
                    end
                    
                else % Ajuste
                    h = waitbar(0,'Executando diferenciação.','Name','0.0% concluído',...
                        'Color',get(handles.ZoomIn_btn,'BackgroundColor'),'Renderer','zbuffer','Pointer','watch','WindowStyle','modal');
                    
                    ord = min(ord,stp);
                    warning off MATLAB:polyfit:RepeatedPointsOrRescale
                    for n = 1:length(y)
                        ydot(n) = polyval(polyder(polyfit( t(max(1,n-stp/2):min(N,n+stp/2))-t(n), y(max(1,n-stp/2):min(N,n+stp/2)), ord )), 0);
                        if ishandle(h)
                            try
                                waitbar(n/length(y),h);
                                set(h,'Name',[num2str(100*n/length(y),'%1.1f') '% concluído']);
                            end
                        else
                            uiwait(warndlg('Operação cancelada.','Aviso','modal')); drawnow;
                            Window_ButtonMotionFcn(hObject, eventdata, handles);
                            return
                        end
                    end
                    try, pause(.4); delete(h); end
                    warning on MATLAB:polyfit:RepeatedPointsOrRescale
                end
        end
    end
    
    % Reatribuição de NaN em ydot
    if ~isempty(nnan)
        ydot(nnan) = NaN;
    end
    
    setappdata(handles.window,'tempdata',ydot);
    ShowTemporaryPlot(hObject, eventdata, handles, ydot, '');
    
    setappdata(handles.window,'func','NumDiffer_2');
    
elseif strcmp(func,'NumDiffer_2') && ~cancel
    
    name = TrimParamName(get(handles.entry1,'String'),handles.maxparamlength);
    if isempty(name)
        beep; uiwait(errordlg('Nome do parâmetro não pode ser vazio.','Erro','modal')); drawnow;
        return
    end 
    PARAM = InsertParam(PARAM,name);
    CheckRepParam(PARAM,name);
    
    data  = getappdata(handles.window,'tempdata');
    DADOS = [DADOS(:,1:end-1), data, DADOS(:,end)];
    
    xcol = get(handles.xlist,'Value');
    if xcol == length(PARAM)-1
        xcol = xcol+1;
    end
    ycol = length(PARAM)-1;
    
    HideTemporaryPlot(hObject, eventdata, handles, xcol, ycol, PARAM);
    setappdata(handles.window,'func','none');
    
    setappdata(handles.window,'change',1);
    NewEvent(handles,['Parâmetro ''' name ''' criado por diferenciação numérica.']);
    
elseif cancel
    
    HideTemporaryPlot(hObject, eventdata, handles);
    set(handles.graphs,'XLim',AutoLim(handles.plot));
    
end

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function FitCurve_Callback(hObject, eventdata, handles, click)
global DADOS
% Ferramenta de ajuste de curva no intervalo

if isempty(GetIntervPts(handles))
    beep; uiwait(errordlg('Não há pontos no intervalo selecionado.','Erro','modal')); drawnow;
    return
end

if nargin == 3
    click = 0;
end

xcol   = get(handles.xlist,'Value');
ycol   = get(handles.ylist,'Value');
xpar   = get(handles.xlabel,'String');
func   = getappdata(handles.window,'func');
ok     = getappdata(handles.window,'ok');
cancel = getappdata(handles.window,'cancel');

if strcmp(func,'none') && ~cancel
    
    if length(GetIntervPts(handles)) > 10000
        button = questdlg({'Intervalo para análise aparenta ser muito grande.','Deseja prosseguir?'},'Confirmação',...
            'Sim','Não','Não'); drawnow;
        if ~strcmp(button,'Sim')
            return
        end
    end
    
    pts = GetIntervPts(handles);
    nanx = find(isnan(DADOS(pts,xcol)));
    nany = find(isnan(DADOS(pts,ycol)));
    
    if length(nany) == length(pts)
        beep; uiwait(errordlg('Não há dados válidos no intervalo selecionado.','Erro','modal')); drawnow;
        return
    end
    if ~isempty(nanx)
        beep; uiwait(errordlg({'Parâmetro x não é adequado:',' ',...
                ['Pontos inválidos: ' num2str(length(nanx))]},'Erro','modal')); drawnow;
        return
    end
    
    if ~isempty(nany)
        if length(nany) == 1
            button = questdlg({'Encontrado 1 ponto inválido em y',...
                    'que será inperpolado linearmente.','Deseja prosseguir?'},'Confirmação',...
                'Sim','Não','Não'); drawnow;
        else
            button = questdlg({['Encontrados ' num2str(length(nany)) ' pontos inválidos em y'],...
                    'que serão inperpolados linearmente.','Deseja prosseguir?'},'Confirmação',...
                'Sim','Não','Não'); drawnow;
        end
        if ~strcmp(button,'Sim')
            return
        end
    end
    
    set(handles.ShowRuler,'Enable','off');
    if strcmp(get(handles.ShowRuler,'Checked'),'on')
        ShowRuler_Callback(hObject, eventdata, handles);
    end
    
    set(handles.entry1txt,'String','Tipo:');
    set(handles.entry2txt,'String','x');
    set(handles.entry3txt,'String','y');
    set(handles.entry4txt,'String','y''');
    set(handles.entry1,'String',{' ','Média','Linear','Quadrático','Cúbico','4° grau','5° grau','6° grau','1ª ordem','2ª ordem'},'Value',1);
    set(handles.entry2,'String','','Style','edit');
    set([handles.entry3 handles.entry4],'String','','Style','edit','Enable','inactive');
    set([handles.NobsNpar handles.selpts],'Visible','off');
    
    set([handles.entries handles.entriestxt handles.ok_btn handles.cancel_btn],'Visible','on');
    SetFrame(handles,1,'Opções de ajuste de curva:');
    set([handles.menulist handles.xlist handles.ylist handles.controlbtns],'Enable','off');
    UpdateButtonStatus(hObject, eventdata, handles);
    
    setappdata(handles.window,'clickfunc','none');
    setappdata(handles.window,'func','FitCurve_1');
    
elseif strcmp(func,'FitCurve_1') && ~cancel
    
    lastwarn('');
    
    if ok
        
        tempdata = getappdata(handles.window,'tempdata');
        if length(tempdata) >= 6
            yf = tempdata{6};
        else
            yf = [];
        end
        
        if ~isempty(yf) && ~all(isnan(yf))
            button = questdlg({'Deseja substituir o intervalo original pela curva ajustada?',...
                    'Os dados originais serão perdidos!'},'Confirmação','Sim','Não','Não'); drawnow;
            if strcmp(button,'Sim')
                if ycol == size(DADOS,2)
                    beep; uiwait(errordlg('Não é possível alterar o parâmetro ''No. OBS.''','Erro','modal')); drawnow;
                    return
                end
                pts = GetIntervPts(handles);
                ypar = get(handles.ylabel,'String');
                DADOS(pts,ycol) = yf;
                UpdatePlot(hObject, eventdata, handles);
                
                setappdata(handles.window,'change',1);
                NewEvent(handles,['Parâmetro ''' ypar ''' alterado por substituição de pontos por curva ajustada.']); 
            end
        else
            beep; uiwait(errordlg('Não há dados ajustados.','Erro','modal')); drawnow;
            return    
        end
        cancel_btn_Callback(hObject, eventdata, handles);
        
    else
        
        if ~click % Recalcular
            set(handles.window,'Pointer','watch');
            
            n = get(handles.entry1,'Value')-2;
            pts = GetIntervPts(handles);
            x = DADOS(pts,xcol);
            y = denan(DADOS(pts,ycol));
            xr = linspace(min(x),max(x),4*(length(x)-1)+1)';
            
            if n<=6 && length(pts) <= n
                beep; uiwait(errordlg('Ordem do polinômio deve ser menor ou igual ao número de pontos.','Erro','modal')); drawnow;
                n = -1;
            elseif n==7 && length(pts) < 3
                beep; uiwait(errordlg('São necessários pelo menos 3 pontos para ajuste de 1ª ordem.','Erro','modal')); drawnow;
                n = -1;
            elseif n==8 && length(pts) < 6
                beep; uiwait(errordlg('São necessários pelo menos 6 pontos para ajuste de 2ª ordem.','Erro','modal')); drawnow;
                n = -1;
            end
            
            if strcmp(get(handles.DontResetOriginForFit,'Checked'),'on')
                x0 = 0;
            else
                x0 = x(1);
            end
            
            switch n
                case -1 % Nenhum
                    fittype = 'none';
                    cfs   = [];
                    E     = [];
                    S     = [];
                    xr    = NaN;
                    yf    = NaN;
                    yfr   = NaN;
                    delta = NaN;
                    set(handles.title,'String','','Interpreter','none','UIContextMenu',[]);
                    
                case {0 1 2 3 4 5 6} % Polinomio
                    
                    warning off MATLAB:polyfit:RepeatedPointsOrRescale
                    
                    fittype = 'poly';
                    [cfs, S] = polyfit(x-x0,y,n);
                    yf  = polyval(cfs,x-x0);
                    [yfr, delta] = polyval(cfs,xr-x0,S);
                    E = goodnessfit(y, yf, length(cfs));
                    
                    if n
                        if x0
                            sgn = num2str(-x0,'%+0d');
                            sgn = sgn(1);
                            eq = poly2eq(cfs,'\xi');
                            titlestr = [eq,'   [\xi = x ' sgn ' ' num2str(abs(x0),6) ']'];
                        else
                            titlestr = poly2eq(cfs,'x');
                        end
                    else
                        titlestr = ['y = ' num2str(cfs)];
                    end
                    set(handles.title,'String',titlestr,'Interpreter','TeX','UIContextMenu',handles.TitleMenu);
                    
                case 7 % 1a ordem
                    
                    if ~IsTime(xpar)
                        button = questdlg({'Para ajuste de 1ª ordem a abscissa deve ser parâmetro de tempo.','Deseja prosseguir?'},...
                            'Confirmação','Sim','Não','Não'); drawnow;
                        if ~strcmp(button,'Sim')
                            set(handles.entry1,'Value',1);
                            entry1_Callback(hObject, eventdata, handles);
                            Window_ButtonMotionFcn(hObject, eventdata, handles);
                            return
                        end
                    end
                    
                    [yf, t, cfs, tau, yinf] = fit_1st_ord(x,y);
                    yfr = eval_1st_ord(cfs,xr-x0);
                    S = [];
                    E = goodnessfit(y, yf, length(cfs));
                    delta = E.STDE * ones(size(yfr));
                    fittype = '1ord';
                    
                    set(handles.title,'String',['\tau:  ' num2str(tau,4) ' s     y0:  ' num2str(cfs(1),6) '     y\infty:  ' num2str(yinf,6)],...
                        'Interpreter','TeX','UIContextMenu',handles.TitleMenu);
                    
                case 8 % 2a ordem
                    
                    if ~IsTime(xpar)
                        button = questdlg({'Para ajuste de 2ª ordem a abscissa deve ser parâmetro de tempo.','Deseja prosseguir?'},...
                            'Confirmação','Sim','Não','Não'); drawnow;
                        if ~strcmp(button,'Sim')
                            set(handles.entry1,'Value',1);
                            entry1_Callback(hObject, eventdata, handles);
                            Window_ButtonMotionFcn(hObject, eventdata, handles);
                            return
                        end
                    end
                    
                    [yf, t, cfs, z, wn] = fit_2nd_ord(x,y);
                    yfr = eval_2nd_ord(cfs,xr-x0);
                    S = [];
                    E = goodnessfit(y, yf, length(cfs));
                    delta = E.STDE * ones(size(yfr));
                    fittype = '2ord';
                    
                    set(handles.title,'String',['\zeta:  ' num2str(z,4) '     \omegan:  ' num2str(wn,'%0.4f') ' rad/s'],...
                        'Interpreter','TeX','UIContextMenu',handles.TitleMenu);
            end
            
            set(handles.fit,'XData',xr,'YData',yfr);
            if strcmp(get(handles.DontShowErrorBounds,'Checked'),'off')
                set(handles.auxplots(1,2),'XData',[xr; NaN; xr],'YData',[yfr+delta; NaN; yfr-delta]);
            else
                set(handles.auxplots(1,2),'XData',NaN,'YData',NaN);
            end
            setappdata(handles.window,'tempdata',{fittype,cfs,x0,S,E,yf,[xr yfr delta]});
            
            if ~isempty(lastwarn)
                uiwait(warndlg(lastwarn,'Aviso','modal')); drawnow;
            end
            
        else % Clique na tela
            
            n = get(handles.entry1,'Value')-1;
            tempdata = getappdata(handles.window,'tempdata');
            if length(tempdata) >= 3
                fittype = tempdata{1};
                cfs = tempdata{2};
                x0 = tempdata{3};
            else
                fittype = 'none';
                cfs = [];
                x0 = [];
            end
            
        end
        
        % Calculo do ponto clicado na tela
        if n >= 1 && ~isempty(cfs)
            xi = str2double(get(handles.entry2,'String'));
            ax = get(handles.graph,'XLim');
            
            if ~isnan(xi) && xi >= ax(1) && xi <= ax(2)
                switch fittype
                    case 'poly'
                        yi    = polyval(cfs,xi-x0);
                        yidot = polyval(polyder(cfs),xi-x0);
                    case '1ord'
                        [yi, yidot] = eval_1st_ord(cfs,xi-x0);
                    case '2ord'
                        [yi, yidot] = eval_2nd_ord(cfs,xi-x0);
                end
                set(handles.entry3,'String',num2str(yi));
                set(handles.entry4,'String',num2str(yidot));
                set(handles.fitpt,'XData',xi,'YData',yi);
            else
                set([handles.entry3 handles.entry4],'String','');
                set(handles.fitpt,'XData',NaN,'YData',NaN);
            end
        else
            set([handles.entry3 handles.entry4],'String','');
            set(handles.fitpt,'XData',NaN,'YData',NaN);
        end
        
    end
    
elseif cancel
    
    set([handles.fit handles.fitpt handles.auxplots(1,2)],'XData',NaN,'YData',NaN);
    set(handles.title,'String','','Interpreter','none','UIContextMenu',[]);
    set([handles.NobsNpar handles.selpts],'Visible','on');
    set(handles.ShowRuler,'Enable','on');
    warning on MATLAB:polyfit:RepeatedPointsOrRescale
    
end

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function ML_CFTool_Callback(hObject, eventdata, handles)
global DADOS
% Ferramenta de ajuste de curva do MATLAB

xcol = get(handles.xlist,'Value');
ycol = get(handles.ylist,'Value');

pts = GetIntervPts(handles);

if ~isempty(pts);
    X = DADOS(pts,xcol);
    Y = DADOS(pts,ycol);
    cftool(X,Y);
else
    uiwait(errordlg('Não há pontos no intervalo selecionado.','Erro','modal')); drawnow;
end

% --------------------------------------------------------------------
function ExternalFunction_Callback(hObject, eventdata, handles)
global DADOS
% Executar função externa para criação de parâmetros

PARAM = get(handles.xlist,'String');

[DADOS2, PARAM2] = RDAT_ExternalFcn(PARAM,handles.maxparamlength);

if isempty(DADOS2)
    return
end

DADOS = [DADOS(:,1:end-1) DADOS2 (1:size(DADOS,1))'];
PARAM = [PARAM(1:end-1); PARAM2; PARAM(end)];

PARAM = SetParamFormat(PARAM,handles.maxparamlength);
for n = 1:length(PARAM2)
    CheckRepParam(PARAM,PARAM2{n});
end

setappdata(handles.window,'change',1);
if length(PARAM2) == 1
    NewEvent(handles,[' Parâmetro ''' PARAM2{1} ''' criado por função externa.']); 
else
    NewEvent(handles,[num2str(length(PARAM2)) ' parâmetros criados por função externa.']); 
end

UpdateGraph(hObject, eventdata, handles, length(PARAM), 1, PARAM);


% ####################################################################
%                      FUNÇÕES DO MENU DADOS
% ####################################################################

function GoToTime_Callback(hObject, eventdata, handles)
global DADOS
% Ir para instante no tempo

xcol     = get(handles.xlist,'Value');
timecols = getappdata(handles.window,'timecols');
func     = getappdata(handles.window,'func');
cancel   = getappdata(handles.window,'cancel');

if strcmp(func,'none') && ~cancel
    
    if isempty(timecols)
        button = questdlg({'Não foram encontrados parâmetros de tempo.',...
                ['Deseja usar o parâmetro ''' get(handles.xlabel,'String') '''?']},'Erro','Sim','Não','Não'); drawnow;
        if ~strcmp(button,'Sim')
            return
        end
    else
        if xcol~=timecols % xcol não é tempo -> Mudar para primeiro parâmetro de tempo da lista
            xcol = timecols(1);
            set(handles.xlist,'Value',xcol);
            xlist_Callback(hObject, eventdata, handles);
            pause(.3);
        end
    end
    
    T = DADOS(:,xcol);
    if max(T) == min(T)
        beep; uiwait(errordlg('Intervalo do parâmetros de tempo indicado é nulo.','Erro','modal')); drawnow;
        return    
    end
    
    set(handles.entry1txt,'String','Tempo:');
    set(handles.entry2txt,'String','Intervalo:');
    set(handles.entry3txt,'String','(h m s)','HorizontalAlignment','left');
    set(handles.entry4txt,'String','(s)','HorizontalAlignment','left');
    set(handles.entry1,'Style','edit','String','');
    set(handles.entry2,'Style','edit','String','-5');
    set(handles.entry4,'Style','edit','String','5');
    
    SetEntriesForInterval(handles,1);
    set([handles.entries([1,2,4]) handles.entriestxt handles.ok_btn handles.cancel_btn],'Visible','on');
    SetFrame(handles,1,'Indique o tempo desejado e o intervalo:');
    set([handles.menulist handles.xlist],'Enable','off');
    UpdateButtonStatus(hObject, eventdata, handles);
    SetButtonStatus(handles,handles.Setpt_btn,1);

    setappdata(handles.window,'func','GoToTime_1');
    
elseif strcmp(func,'GoToTime_1') && ~cancel
    
    t0s  = get(handles.entry1,'String');
    Dt1s = get(handles.entry2,'String');
    Dt2s = get(handles.entry4,'String');
    
    t0  = str2time(t0s);
    Dt1 = str2double(Dt1s);
    Dt2 = str2double(Dt2s);
    
    if isnan(t0)
        beep; uiwait(errordlg('Tempo incoerente.','Erro','modal')); drawnow;
        return
    elseif isnan(Dt1) || isnan(Dt2) || Dt2-Dt1 < 1e-4
        beep; uiwait(errordlg('Intervalo incoerente.','Erro','modal')); drawnow;
        return
    end
    
    T = DADOS(:,xcol);
    
    if t0 < min(T) || t0 > max(T)
        beep; uiwait(errordlg(['Tempo ' time2str2(t0) ' fora do intervalo [' time2str2(min(T)) ', ' time2str2(max(T)) '].'],...
            'Erro','modal')); drawnow;
    else
        x1 = max(t0+Dt1,min(T));
        x2 = min(t0+Dt2,max(T));
        
        setappdata(handles.window,'clickfunc','none');
        
        set(handles.graphs,'XLim',AutoLim(handles.plot),'YLimMode','auto');
        pause(.2)
        
        set(handles.graph,'YLimMode','manual');
        ay = get(handles.graph,'YLim');
        set(handles.auxline,'XData',[x1 x1 NaN t0 t0 NaN x2 x2],'YData',[ay NaN ay NaN ay],'Visible','on');
        pause(.5);
        set(handles.auxline,'Visible','off');
        set(handles.graph,'YLimMode','auto');
        
        set(handles.graph,'XLim',[x1 x2]);
        drawnow;
        
        set(handles.graph,'YLimMode','manual');
        set(handles.auxline,'XData',[t0 t0],'YData',get(handles.graph,'YLim'),'Visible','on');
        pause(.2);
        set(handles.auxline,'Visible','off');
        set(handles.graph,'YLimMode','auto');
        
        setappdata(handles.window,'clickfunc','zoom');
        
    end
elseif cancel
    
    set(handles.entriestxt(3:4),'HorizontalAlignment','right');
    SetEntriesForInterval(handles,0);
    
end

% --------------------------------------------------------------------
function GoToTOP_Callback(hObject, eventdata, handles)
global DADOS
% Ir para TOP

PARAM    = get(handles.xlist,'String');
xcol     = get(handles.xlist,'Value');
reftime  = getappdata(handles.window,'reftime');
timecols = getappdata(handles.window,'timecols');
func     = getappdata(handles.window,'func');
cancel   = getappdata(handles.window,'cancel');
topcols  = findTOPpar(PARAM);

if isempty(topcols)
    beep; uiwait(errordlg('Não foram encontrados parâmetros de TOP.','Erro','modal')); drawnow;
    return
end

if strcmp(func,'none') && ~cancel
    
    if length(topcols) > 1
        ntop = inputvalue('Opção','Parâmetro TOP:',PARAM(topcols),1,1.2); drawnow;
        if isempty(ntop)
            return
        end
    else
        ntop = 1;
    end
    set(handles.ylist,'Value',topcols(ntop));
    ylist_Callback(hObject, eventdata, handles);
    
    tcol = findpar(PARAM,reftime,0,1);
    if ~isempty(tcol)
        set(handles.xlist,'Value',tcol);
        xlist_Callback(hObject, eventdata, handles);
        pause(.3);
    else
        if isempty(timecols)
            button = questdlg({'Não foram encontrados parâmetros de tempo.',...
                    ['Deseja usar o parâmetro ''' get(handles.xlabel,'String') '''?']},'Erro','Sim','Não','Não'); drawnow;
            if ~strcmp(button,'Sim')
                return
            end
        else
            if xcol~=timecols % xcol não é tempo -> Mudar para primeiro parâmetro de tempo da lista
                xcol = timecols(1);
                set(handles.xlist,'Value',xcol);
                xlist_Callback(hObject, eventdata, handles);
                pause(.3);
            end
        end
    end
    
    [tops, ntops, err] = getTOPs(DADOS(:,topcols(ntop)));
    
    if isempty(tops)
        beep; uiwait(errordlg(err,'Erro','modal')); drawnow;
        return
    end
    
    T = DADOS(:,xcol);
    toplist = {' ', NaN};
    toplist(2,:) = {'Início', min(T)};
    for n = 1:length(tops)
        ttop = mean(T(ntops(n)-1:ntops(n)));
        if ~isnan(ttop)
            toplist(end+1,:) = {num2str(tops(n)),ttop};
        end
    end
    toplist(end+1,:) = {'Fim', max(T)};
    
    setappdata(handles.window,'tempdata',toplist);
    
    set(handles.entry1txt,'String','TOP:');
    set(handles.entry3txt,'String','Opção:');
    set(handles.entry1,'Style','popupmenu','String',toplist(:,1),'Value',1);
    set(handles.entry3,'Style','popupmenu','String',{'Centralizado','Entre TOPs'},'Value',1);
    
    set([handles.entries([1 3]) handles.entriestxt([1 3]) handles.entriestxt handles.ok_btn handles.cancel_btn],'Visible','on');
    SetFrame(handles,1,'Indique o TOP desejado:');
    set([handles.menulist handles.xlist],'Enable','off');
    UpdateButtonStatus(hObject, eventdata, handles);
    SetButtonStatus(handles,handles.Setpt_btn,1);

    setappdata(handles.window,'func','GoToTOP_1');
    entry3_Callback(hObject, eventdata, handles);
    
elseif strcmp(func,'GoToTOP_1') && ~cancel
    
    T = DADOS(:,xcol);
    toplist = getappdata(handles.window,'tempdata');
    
    opt = get(handles.entry3,'Value');
    switch opt
        
        case 1 % Centralizado
            
            n1  = get(handles.entry1,'Value');
            Dt1 = str2double(get(handles.entry2,'String'));
            Dt2 = str2double(get(handles.entry4,'String'));
            
            if n1 == 1
                return
            end
            
            if isnan(Dt2+Dt1) || Dt2-Dt1 < 1e-4
                beep; uiwait(errordlg('Intervalo incoerente.','Erro','modal')); drawnow;
                return
            end
            
            t1 = toplist{n1,2} + Dt1;
            t2 = toplist{n1,2} + Dt2;
            
        case 2 % Entre TOPs
            
            n1  = get(handles.entry1,'Value');
            n2  = get(handles.entry2,'Value');
            
            if n1 == 1 || n2 == 1
                return
            end
            
            t1 = toplist{n1,2};
            t2 = toplist{n2,2};
            
            if t2-t1 < 1e-4
                beep; uiwait(errordlg('TOP inicial deve ser anterior ao TOP final.','Erro','modal')); drawnow;
                return
            end
            
    end
    
    x1 = max(t1,min(T));
    x2 = min(t2,max(T));
    
    if x2 - x1 > 1e-2
        
        setappdata(handles.window,'clickfunc','none');
        
        set(handles.graph,'XLim',AutoLim(handles.plot),'YLimMode','auto');
        pause(.2)
        
        set(handles.graph,'YLimMode','manual');
        ay = get(handles.graph,'YLim');
        set(handles.auxline,'XData',[x1 x1 NaN x2 x2],'YData',[ay NaN ay],'Visible','on');
        pause(.5);
        set(handles.auxline,'Visible','off');
        set(handles.graph,'YLimMode','auto');
        
        set(handles.graph,'XLim',sort([x1 x2]));
        drawnow;
        
        set(handles.graph,'YLimMode','manual');
        set(handles.auxline,'XData',[t1 t1],'YData',get(handles.graph,'YLim'),'Visible','on');
        pause(.2);
        set(handles.auxline,'Visible','off');
        set(handles.graph,'YLimMode','auto');
        
        setappdata(handles.window,'clickfunc','zoom');
        
    else
        beep; uiwait(errordlg('Não é possível obter o intervalo desejado.','Erro','modal')); drawnow;
    end
    
elseif cancel
    
    set(handles.entry4txt,'HorizontalAlignment','right');
    SetEntriesForInterval(handles,0);
    
end

% --------------------------------------------------------------------
function GoToEvent_Callback(hObject, eventdata, handles)
global DADOS
% Ir para Evento

PARAM   = get(handles.xlist,'String');
xcol    = get(handles.xlist,'Value');
reftime = getappdata(handles.window,'reftime');
events  = getappdata(handles.window,'events');
func    = getappdata(handles.window,'func');
cancel  = getappdata(handles.window,'cancel');

if isempty(events)
    beep; uiwait(errordlg('Não há eventos definidos.','Erro','modal')); drawnow;
    return
end

if strcmp(func,'none') && ~cancel
    
    xcol = findpar(PARAM,reftime,0,1);
    if isempty(xcol)
        beep; uiwait(errordlg(['O tempo de referência ''' reftime ''' não foi encontrado.'],'Erro','modal')); drawnow;
        return
    else
        set(handles.xlist,'Value',xcol);
        xlist_Callback(hObject, eventdata, handles);
        pause(.3);
    end
    
    eventlist = {' ', NaN};
    eventlist(2,:) = {'Início', min(DADOS(:,xcol))};
    for n = 1:size(events,1)
        if events{n,1} && ~isnan(events{n,2})
            eventlist(end+1,:) = {[num2str(n) ' - ' events{n,3}],events{n,2}};
        end
    end
    eventlist(end+1,:) = {'Fim', max(DADOS(:,xcol))};
    
    if size(eventlist,1) == 3
        beep; uiwait(errordlg('Não há eventos válidos.','Erro','modal')); drawnow;
        return
    end
    
    setappdata(handles.window,'tempdata',eventlist);
    
    set(handles.entry1txt,'String','Evento:');
    set(handles.entry3txt,'String','Opção:');
    set(handles.entry1,'Style','popupmenu','String',eventlist(:,1),'Value',1);
    set(handles.entry3,'Style','popupmenu','String',{'Centralizado','Entre eventos'},'Value',1);
    
    set([handles.entries([1 3]) handles.entriestxt([1 3]) handles.entriestxt handles.ok_btn handles.cancel_btn],'Visible','on');
    SetFrame(handles,1,'Indique o evento desejado:');
    set([handles.menulist handles.xlist],'Enable','off');
    UpdateButtonStatus(hObject, eventdata, handles);
    SetButtonStatus(handles,[handles.Setpt_btn],1);

    setappdata(handles.window,'func','GoToEvent_1');
    entry3_Callback(hObject, eventdata, handles);
    
elseif strcmp(func,'GoToEvent_1') && ~cancel
    
    T = DADOS(:,xcol);
    eventlist = getappdata(handles.window,'tempdata');
    
    opt = get(handles.entry3,'Value');
    switch opt
        
        case 1 % Centralizado
            
            n1  = get(handles.entry1,'Value');
            Dt1 = str2double(get(handles.entry2,'String'));
            Dt2 = str2double(get(handles.entry4,'String'));
            
            if n1 == 1
                return
            end
            
            if isnan(Dt2+Dt1) || Dt2-Dt1 < 1e-4
                beep; uiwait(errordlg('Intervalo incoerente.','Erro','modal')); drawnow;
                return
            end
            
            t1 = eventlist{n1,2} + Dt1;
            t2 = eventlist{n1,2} + Dt2;
            
        case 2 % Entre eventos
            
            n1  = get(handles.entry1,'Value');
            n2  = get(handles.entry2,'Value');
            
            if n1 == 1 || n2 == 1
                return
            end
            
            t1 = eventlist{n1,2};
            t2 = eventlist{n2,2};
            
            if t2-t1 < 1e-4
                beep; uiwait(errordlg('Evento inicial deve ser anterior ao evento final.','Erro','modal')); drawnow;
                return
            end
            
    end
    
    x1 = max(t1,min(T));
    x2 = min(t2,max(T));
    
    if x2 - x1 > 1e-2
        
        setappdata(handles.window,'clickfunc','none');
        
        set(handles.graph,'XLim',AutoLim(handles.plot),'YLimMode','auto');
        pause(.2)
        
        set(handles.graph,'YLimMode','manual');
        ay = get(handles.graph,'YLim');
        set(handles.auxline,'XData',[x1 x1 NaN x2 x2],'YData',[ay NaN ay],'Visible','on');
        pause(.5);
        set(handles.auxline,'Visible','off');
        set(handles.graph,'YLimMode','auto');
        
        set(handles.graph,'XLim',sort([x1 x2]));
        drawnow;
        
        set(handles.graph,'YLimMode','manual');
        set(handles.auxline,'XData',[t1 t1],'YData',get(handles.graph,'YLim'),'Visible','on');
        pause(.2);
        set(handles.auxline,'Visible','off');
        set(handles.graph,'YLimMode','auto');
        
        setappdata(handles.window,'clickfunc','zoom');
        
    else
        beep; uiwait(errordlg('Não é possível obter o intervalo desejado.','Erro','modal')); drawnow;
    end
    
elseif cancel
    
    set(handles.entry4txt,'HorizontalAlignment','right');
    SetEntriesForInterval(handles,0);
    
end

% --------------------------------------------------------------------
function GoToPoint_Callback(hObject, eventdata, handles)
global DADOS
% Ir para ponto de ensaio

PARAM   = get(handles.xlist,'String');
xcol    = get(handles.xlist,'Value');
reftime = getappdata(handles.window,'reftime');
testpts = getappdata(handles.window,'testpts');
func    = getappdata(handles.window,'func');
cancel  = getappdata(handles.window,'cancel');

if ~isfield(testpts,'number') || isempty([testpts.number])
    beep; uiwait(errordlg('Não há pontos de ensaio definidos.','Erro','modal')); drawnow;
    return
end

if isempty(reftime)
    beep; uiwait(errordlg('O tempo de referência não está definido.','Erro','modal')); drawnow;
    return
end

if strcmp(func,'none') && ~cancel
    
    xcol = findpar(PARAM,reftime,0,1);
    if isempty(xcol)
        beep; uiwait(errordlg(['O tempo de referência ''' reftime ''' não foi encontrado.'],'Erro','modal')); drawnow;
        return
    else
        set(handles.xlist,'Value',xcol);
        xlist_Callback(hObject, eventdata, handles);
        pause(.3);
    end
    
    testptslist.number = [testpts.number];
    testptslist.descr  = [testpts.descr];
    
    for n = 1:length(testptslist.number)
        ptslist{n} = [testptslist.number{n} ' - ' testptslist.descr{n}];
    end
    ptslist = [{' '}, ptslist];
    
    set(handles.entry1txt,'String','Ponto:');
    set(handles.entry1,'String',ptslist,'Value',1);
    SetEntrySize(handles,handles.entry1,2);
    
    set([handles.entry1 handles.entry1txt handles.ok_btn handles.cancel_btn],'Visible','on');
    SetFrame(handles,1,'Indique o ponto de ensaio desejado:');
    set([handles.menulist handles.xlist],'Enable','off');
    UpdateButtonStatus(hObject, eventdata, handles);
    
    setappdata(handles.window,'func','GoToPoint_1');
    
elseif strcmp(func,'GoToPoint_1') && ~cancel
    
    testptslist.time  = [testpts.time];
    npt = get(handles.entry1,'Value')-1;
    
    if npt == 0
        return
    end
    
    Tini = testptslist.time(1,npt);
    Tend = testptslist.time(2,npt);
    
    if isnan(Tend-Tini)
        beep; uiwait(errordlg('Intervalo do ponto não definido corretamente.','Erro','modal')); drawnow;
        return
    end
    
    T = DADOS(:,xcol);
    
    if Tend < min(T) || Tini > max(T)
        beep; uiwait(errordlg({['Intervalo do ponto [' time2str2(Tini) ', ' time2str2(Tend) ']'],...
                ['fora do intervalo de dados [' time2str2(min(T)) ', ' time2str2(max(T)) '].']}, 'Erro','modal')); drawnow;
    else
        x1 = max(Tini,min(T));
        x2 = min(Tend,max(T));
        
        setappdata(handles.window,'clickfunc','none');
        
        set(handles.graphs,'XLim',AutoLim(handles.plot),'YLimMode','auto');
        pause(.2)
        
        set(handles.graph,'YLimMode','manual');
        ay = get(handles.graph,'YLim');
        set(handles.auxline,'XData',[x1 x1 NaN x2 x2],'YData',[ay NaN ay],'Visible','on');
        pause(.5);
        set(handles.auxline,'Visible','off');
        set(handles.graph,'YLimMode','auto');
        
        set(handles.graph,'XLim',[x1 x2]);
        pause(.2);
        
        set(handles.auxline,'Visible','off');
        set(handles.graph,'YLimMode','auto');
        
        setappdata(handles.window,'clickfunc','zoom');
        
    end
    
elseif cancel
    
    pos1 = get(handles.entry1,'Position');
    pos2 = get(handles.entry2,'Position');
    set(handles.entry1,'Position',[pos1(1) pos1(2) pos2(3) pos1(4)]);
    
end

% --------------------------------------------------------------------
function GetIntervalData_Callback(hObject, eventdata, handles)
global DADOS
% Função que fornece dados notaveis do intervalo

timecols    = getappdata(handles.window,'timecols');
displaytime = strcmp(get(handles.DisplayDetailedTime,'Checked'),'on');
xcol  = get(handles.xlist,'Value');
ycol  = get(handles.ylist,'Value');
pts   = GetIntervPts(handles);
X     = DADOS(pts,xcol);
Y     = DADOS(pts,ycol);

if ~isempty(pts)
    
    Xmin = min(X);
    Xmax = max(X);
    Ym   = nanmean(Y);
    Ymin = min(Y);
    Ymax = max(Y);
    Ys   = nanstd(Y);
    Ynan = length(find(isnan(Y)));
    
    if displaytime && any(xcol==timecols)
        Xrange = time2str2(Xmax-Xmin);
        Xmin = time2str2(Xmin);
        Xmax = time2str2(Xmax);
    else
        Xrange = num2str(Xmax-Xmin);
        Xmin = num2str(Xmin);
        Xmax = num2str(Xmax);
    end
    
    str = {...
            ['No. Obs.:  ',           num2str(length(pts))],...
            ['Pontos inválidos:  ',   num2str(Ynan)       ],...
            ' ',...
            ['X mínimo:  ',           Xmin                ],...
            ['X máximo:  ',           Xmax                ],...
            ['Amplitude de X:  ',     Xrange              ],...
            ' ',...
            ['Y médio:  ',            num2str(Ym)         ],...
            ['Y mínimo:  ',           num2str(Ymin)       ],...
            ['Y máximo:  ',           num2str(Ymax)       ],...
            ['Amplitude de Y:  ',     num2str(Ymax-Ymin)  ],...
            ['Desvio padrão de Y:  ', num2str(Ys)         ]};
    
    ax = get(handles.graph,'XLim');
    set(handles.graph,'YLimMode','manual');
    set(handles.auxplots(1,1), 'XData', [ax(1) ax(2)], 'YData', [Ym Ym]);
    set(handles.auxplots(1,2), 'XData', [ax(1) ax(2) NaN ax(1) ax(2)], 'YData', [Ymin Ymin NaN Ymax Ymax]);
    set(handles.auxplots(1,3), 'XData', [ax(1) ax(2) NaN ax(1) ax(2)], 'YData', Ym+[Ys Ys NaN -Ys -Ys]);
    displaybox(str,'Dados do intervalo',160);
    set(handles.auxplots(1,:),'XData',NaN,'YData',NaN);
    set(handles.graph,'YLimMode','auto');
else
    beep; uiwait(errordlg('Não há pontos no intervalo selecionado.','Erro','modal')); drawnow;
end

% --------------------------------------------------------------------
function Histogram_Callback(hObject, eventdata, handles)
global DADOS
% Mostra histograma dos dados em y

ypar = get(handles.ylabel,'String');
ycol = get(handles.ylist,'Value');
func = getappdata(handles.window,'func');

pts = GetIntervPts(handles);

if strcmp(func,'CreateParam_1')
    Y = get(handles.plots(1,2),'YData');
    Y = Y(pts);
else
    Y = DADOS(pts,ycol);
end

if isempty(Y)
    beep; uiwait(errordlg('Não há pontos no intervalo selecionado.','Erro','modal')); drawnow;
    return
end
if all(isnan(Y))
    beep; uiwait(errordlg('Não há dados válidos no intervalo selecionado.','Erro','modal')); drawnow;
    return
end

key_CB = 'cc=get(gcf,''CurrentCharacter''); if cc==13 || cc==27, delete(gcf); end';

ss = get(0,'ScreenSize');
hf = figure('NumberTitle','off','Menubar','figure','Name',['Histograma do parâmetro ''' ypar ''''],'Color',get(handles.window,'Color'),...
    'Position',[.5*(ss(3)-560) .5*(ss(4)-450) 560 450],'Resize','off','Visible','off','Tag','aux','KeyPressFcn',key_CB);
ax(1) = axes('Units','pixels','Position',[70 60 440 360],'Box','on','XGrid','on','YGrid','on','NextPlot','add');
uicontrol('Style','pushbutton','String','OK','Position',[10 10 50 20],'Callback','delete(gcf)');
xlabel(ypar,'Interpreter','none');
ylabel('Número de ocorrências');
title(['Tamanho da amostra: ' num2str(length(Y))]);

set(hf,'Visible','on');

try
    hist(Y,handles.histbins);
    
    tks = get(ax(1),'YTick');
    for n = 1:length(tks)
        str{n} = [num2str(roundn(tks(n)*100/length(Y), -1)) '%'];
    end
    
    ax(2) = axes('Units','pixels','Position',get(ax(1),'Position'),'YAxisLocation','right','Color','none','XGrid','off',...
        'YGrid','off','Box','off','XLim',get(ax(1),'XLim'),'YLim',get(ax(1),'YLim'),'YTick',get(ax(1),'YTick'),...
        'YTickLabel',str);
    
catch
    beep; uiwait(errordlg(lasterr,'Erro','modal')); drawnow;
    delete(hf);
end

% --------------------------------------------------------------------
function CheckTimeY_Callback(hObject, eventdata, handles)
global DADOS
% Verifica a validade do parâmetro y como tempo
% Criterios: Sem NaNs e monotonico crescente

set(handles.window,'Pointer','watch');

xcol = get(handles.xlist,'Value');
ycol = get(handles.ylist,'Value');
ypar = get(handles.ylabel,'String');

if xcol ~= size(DADOS,2)
    set(handles.xlist,'Value',size(DADOS,2));
    xlist_Callback(hObject, eventdata, handles);
end

if IsTime(ypar)
    nameok = 'sim';
else
    nameok = 'não';
end

t = DADOS(:,ycol);

[ok, ndc, nna] = IsTimeOk(t);

if ok
    res = '';
else
    res = 'NÃO ';
end

if length(t) > 1
    [Fs, sFs] = getfreq(t);
    if ~isempty(Fs)
        Fs  = [num2str(Fs)  ' Hz'];
        sFs = [num2str(sFs) ' Hz'];
    else
        Fs  = 'indefidida.';
        sFs = 'indefidido.';
    end
else
    Fs  = 'indefidida.';
    sFs = 'indefidido.';
end

str = char({['Análise do parâmetro ''' ypar ''':'],...
        ' ',...
        [' - Nome reconhecido como tempo: ' nameok],...
        ' ',...
        [' - Cadência média: ' Fs],...
        [' - Desvio padrão: ' sFs],...
        ' ',...
        [' - Pontos inválidos: '      num2str(length(nna))],...
        [' - Pontos não crescentes: ' num2str(length(ndc))],...
        ' ',...
        ['O parâmetro ' res 'PODE ser utilizado como tempo.']});

set(handles.window,'Pointer','arrow');

if ok
    okdlg(str,'Análise','modal'); drawnow;
else
    str = char({str,...
            ' ',...
            'Deseja selecionar os pontos inadequados?'});
    button = questdlg(str,'Análise','Sim','Não','Sim'); drawnow;
    if strcmp(button,'Sim')
        SelectInvalidTime_Callback(hObject, eventdata, handles)
    end
end

% --------------------------------------------------------------------
function CheckTopY_Callback(hObject, eventdata, handles)
global DADOS
% Verifica a validade do parâmetro y como TOP
% Criterios: Inteiros sem NaNs e não-decrescentes

xcol = get(handles.xlist,'Value');
ycol = get(handles.ylist,'Value');
ypar = get(handles.ylabel,'String');

if xcol ~= size(DADOS,2)
    set(handles.xlist,'Value',size(DADOS,2));
    xlist_Callback(hObject, eventdata, handles);
end

if isempty(findTOPpar(ypar))
    badname = 'sim';
else
    badname = 'não';
end

TOP = DADOS(:,ycol);

nni = length(find(denan(TOP)-fix(denan(TOP))~=0));
nna = length(find(isnan(TOP)));
nng = length(find(TOP<0));

if nni + nna + nng
    str2 = char({'','Discrepâncias não críticas (não interferem na identificação dos TOPs):',...
            [' - Pontos não-inteiros que serão arredondados: ' num2str(nni)],...
            [' - Pontos inválidos que serão repetidos: '       num2str(nna)],...
            [' - Pontos negativos que serão zerados: '         num2str(nng)],...
            ''});
    
    TOP(TOP<0) = 0;
    TOP = round(denan(TOP,1));
else
    str2 = '';
end

ndc = length(find(diff(TOP)<0));
tops = getTOPs(TOP);

if isempty(tops)
    if ndc == 0
        Ntops = '0';
    else
        Ntops = 'indefinido';
    end
else
    Ntops = num2str(length(tops));
end

if ndc == 0 && ~isempty(tops) && ~isempty(findTOPpar(ypar))
    res = '';
else
    res = 'NÃO ';
end

str1 = char({'Discrepâncias críticas:',...
        [' - Nome inadequado: '      badname],...
        [' - Pontos decrescentes: '  num2str(ndc)]});

str = char({['Análise do parâmetro ''' ypar ''':'],...
        ' ',...
        ['Número de TOPs encontrados: ' Ntops],...
        ' ',...
        str1,...
        str2,...
        ['O parâmetro ' res 'PODE ser utilizado como TOP.']});

if isempty(res) % OK
    if isempty(str2) % OK
        okdlg(str,'Análise','modal'); drawnow;
    else % Discrepancias nao criticas
        str = char({str,...
                ' ',...
                'Deseja corrigir as discrepâncias não críticas?'});
        button = questdlg(str,'Análise','Sim','Não','Não'); drawnow;
        if strcmp(button,'Sim')
            DADOS(:,ycol) = TOP;
            UpdatePlot(hObject, eventdata, handles);
            setappdata(handles.window,'change',1);
            NewEvent(handles,['Corrigidas as discrepâncias não críticas no parâmetro de TOPs ''' ypar '''.']);
        end
    end
else % Nao OK
    if isempty(str2)
        uiwait(warndlg(str,'Análise','modal')); drawnow;
    else % Discrepancias não criticas
        str = char({str,...
                ' ',...
                'Deseja corrigir as discrepâncias não críticas?'});
        button = questdlg(str,'Análise','Sim','Não','Não'); drawnow;
        if strcmp(button,'Sim')
            DADOS(:,ycol) = TOP;
            UpdatePlot(hObject, eventdata, handles);
            setappdata(handles.window,'change',1);
            NewEvent(handles,['Corrigidas as discrepâncias não críticas no parâmetro de TOPs ''' ypar '''.']);
        end
    end
end

% --------------------------------------------------------------------
function FreqResp_Callback(hObject, eventdata, handles)
global DADOS
% Resposta em frequencia

pts = GetIntervPts(handles);
if length(pts) < 64
    beep; uiwait(errordlg('O tamanho mínimo da amostra é 64.','Erro','modal')); drawnow;
    return
end

PARAM = get(handles.xlist,'String');
timecols = getappdata(handles.window,'timecols');

if isempty(timecols)
    beep; uiwait(errordlg('Não foram encontrados parâmetros de tempo.','Erro','modal')); drawnow;
    return
end

T = DADOS(pts,timecols(1));

Fs = getfreq(T);

if isempty(Fs)
    beep; uiwait(errordlg(['Parâmetro de tempo ''' denumber(PARAM{timecols(1)}) ''' inadequado.'],'Erro','modal')); drawnow;
    return
end

if ~IsTimeOk(T)
    uiwait(warndlg({['Parâmetro de tempo ''' denumber(PARAM{timecols(1)}) ''' inadequado.'],...
            'Podem ocorrer distorções na análise.'},'Aviso','modal')); drawnow;
end

RDAT_FreqResp(PARAM,timecols(1),pts);

% --------------------------------------------------------------------
function PowSpectr_Callback(hObject, eventdata, handles)
global DADOS
% Apresenta um gráfico de PSD do parâmetro Y

pts = GetIntervPts(handles);
if length(pts) < 64
    beep; uiwait(errordlg('O tamanho mínimo da amostra é 64.','Erro','modal')); drawnow;
    return
end

PARAM = get(handles.xlist,'String');
ypar = get(handles.ylabel,'String');
ycol = get(handles.ylist,'Value');
timecols = getappdata(handles.window,'timecols');

NFFT_list = (2.^(6:12))';
OVLP_list = (0:10:90)';
WNDW_list = {'Bartlett-Hann','barthannwin';...
        'Bartlett','bartlett';...
        'Blackman','blackman';...
        'Blackman-Harris','blackmanharris';...
        'Bohman','bohmanwin';...
        'Flat Top','flattopwin';...
        'Gaussian','gausswin';...
        'Hamming','hamming';...
        'Hanning','hann';...
        'Nuttall''s Blackman-Harris','nuttallwin';...
        'Parzen (Valle-Poussin)','parzenwin';...
        'Retangular','rectwin';...
        'Triangular','triang'};   
    
if isempty(timecols)
    beep; uiwait(errordlg('Não foram encontrados parâmetros de tempo.','Erro','modal')); drawnow;
    return
end

T = DADOS(pts,timecols(1));
Y = denan(DADOS(pts,ycol));

Y = Y-mean(Y);

Fs = getfreq(T);

if isempty(Fs)
    beep; uiwait(errordlg(['Parâmetro de tempo ''' denumber(PARAM{timecols(1)}) ''' inadequado.'],'Erro','modal')); drawnow;
    return
end

if IsTimeOk(T)
    try
        Y = interp1(T,Y,min(T):1/Fs:max(T),'linear');
    catch
        uiwait(warndlg({['Parâmetro de tempo ''' denumber(PARAM{timecols(1)}) ''' inadequado.'],...
                'Podem ocorrer distorções na análise.'},'Aviso','modal')); drawnow;
    end
else
    uiwait(warndlg({['Parâmetro de tempo ''' denumber(PARAM{timecols(1)}) ''' inadequado.'],...
            'Podem ocorrer distorções na análise.'},'Aviso','modal')); drawnow;
end

key_CB = 'cc=get(gcf,''CurrentCharacter''); if cc==13 || cc==27, delete(gcf); end';

ss = get(0,'ScreenSize');
hf = figure('NumberTitle','off','MenuBar','figure','Name',['Análise espectral do parâmetro ''' ypar ''''],'Color',get(handles.window,'Color'),...
    'Position',[.5*(ss(3)-560) .5*(ss(4)-450) 560 470],'Resize','off','Renderer','zbuffer','Visible','off','Tag','aux','KeyPressFcn',key_CB);
axes('Units','pixels','Position',[370 10 50 36],'Box','on','XGrid','off','YGrid','of','NextPlot','add','XTick',[],'YTick',[],'XLim',[0 1],'YLim',[0 1.05]);
hw = plot(NaN,NaN,'-b');
axes('Units','pixels','Position',[70 90 450 350],'Box','on','XGrid','on','YGrid','on','NextPlot','add');
hp = plot(NaN,NaN,'-b');
hr = uicontrol('Style','text','String','','Position',[440 10 80 40],'HorizontalAlignment','left');

uicontrol('Style','pushbutton','String','OK','Position',[10 10 50 20],'Callback','delete(gcf)');
H_NFFT = uicontrol('Style','popupmenu','String',NFFT_list,'Value',3,'Position',[70 10 60 20],'BackgroundColor','w','TooltipString','Tamanho das seções','Callback','updatepsd;');
H_OVLP = uicontrol('Style','popupmenu','String',OVLP_list,'Value',6,'Position',[140 10 60 20],'BackgroundColor','w','TooltipString','Superposição (%)','Callback','updatepsd;');
H_WNDW = uicontrol('Style','popupmenu','String',WNDW_list(:,1),'Value',9,'Position',[210 10 150 20],'BackgroundColor','w','TooltipString','Janelamento','Callback','updatepsd;');
uicontrol('Style','text','String',' Tam./Seç.','Position',[70 30 60 16],'HorizontalAlignment','left');
uicontrol('Style','text','String',' Superp. %','Position',[140 30 60 16],'HorizontalAlignment','left');
uicontrol('Style','text','String',' Janelamento','Position',[210 30 160 16],'HorizontalAlignment','left');

tempdata = {Y, Fs, hp, hw, hr, NFFT_list, OVLP_list, WNDW_list, H_NFFT, H_OVLP, H_WNDW};
setappdata(hf,'tempdata',tempdata);

xlabel('Frequência (Hz)','Interpreter','none');
ylabel('Espectro de Potência (dB)','Interpreter','none');
title(['Tamanho da amostra: ' num2str(length(Y)) '    Cadência de amostragem: ' num2str(Fs) ' Hz']);

set(hf,'Visible','on');

updatepsd;

% --------------------------------------------------------------------
function ML_SPTool_Callback(hObject, eventdata, handles)
global DADOS
% Abre a ferramenta de processamento de sinais do MatLab

timecols = getappdata(handles.window,'timecols');
xcol = get(handles.xlist,'Value');
ycol = get(handles.ylist,'Value');
xpar = get(handles.xlabel,'String');
ypar = get(handles.ylabel,'String');

if any(xcol == timecols)
    button = 'Sim';
else
    button = questdlg({['O parâmetro ''' xpar ''' não aparenta ser de tempo.'],...
            'Deseja utilizá-lo para cálculo da frequência de amostragem?'},...
        'Confirmação','Sim','Não','Não'); drawnow;
end

if strcmp(button,'Sim')
    X = DADOS(:,xcol);
    if ~IsTimeOk(X)
        beep; uiwait(errordlg({'O parâmetro de tempo indicado não é adequado.',...
                'O tempo deve ser monotônico, crescente e sem pontos invalidos.'},'Erro','modal')); drawnow;
        return
    end
else
    return
end

if ~isvarname(ypar(1))
    ypar = 'Y';
else
    while ~isvarname(ypar)
        ypar(end) = [];
    end
end

try
    Fs = getfreq(X);

    if isempty(Fs)
        beep; uiwait(errordlg(['Parâmetro de tempo ''' xpar ''' inadequado.'],'Erro','modal')); drawnow;
        return
    end
    
    try
        Y = interp1(X,denan(DADOS(:,ycol)),min(X):1/Fs:max(X),'linear');
    catch
        beep; uiwait(errordlg(lasterr,'Erro','modal')); drawnow;
        return
    end
    
    s = SPTool('create','Signal',Y,Fs,ypar);
    SPTool('load',s);
    
catch
    beep; uiwait(errordlg(lasterr,'Erro','modal')); drawnow;
end

% --------------------------------------------------------------------
function ComutationAnalysis_Callback(hObject, eventdata, handles)
% Analise de subcomutação

PARAM   = get(handles.xlist,'String');
reftime = getappdata(handles.window,'reftime');

togglelist = setdiff(findobj(handles.window,'Enable','on'),findobj(handles.window,'Style','text'));
set(togglelist,'Enable','off');
UpdateButtonStatus(hObject, eventdata, handles);

ok = RDAT_Comutation(PARAM,reftime); drawnow;

set(togglelist,'Enable','on');
UpdateButtonStatus(hObject, eventdata, handles);

if ok
    setappdata(handles.window,'change',1);
    if ok == 1
        NewEvent(handles,'Parâmetros subcomutados alterados por interpolação.');
    else
        NewEvent(handles,'Cadência alterada de acordo com parâmetro subcomutado.');
        DeselectAll_Callback(hObject, eventdata, handles, 0);
    end
    UpdateGraph(hObject, eventdata, handles);
end

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function CreateParam_Callback(hObject, eventdata, handles)
global DADOS
% Criação de parâmetro

PARAM  = get(handles.xlist,'String');
func   = getappdata(handles.window,'func');
cancel = getappdata(handles.window,'cancel');
ok     = getappdata(handles.window,'ok');

if strcmp(func,'none') && ~cancel
    
    set(handles.xlist,'Value',size(DADOS,2));
    xlist_Callback(hObject, eventdata, handles);
    
    optlist = {'Duplicar','Série de zeros','Série de uns','Série constante','Série crescente','Série aleatória'};
    set(handles.entry1txt,'String','Opção:');
    set(handles.entry1,'String',optlist,'Value',1);
    
    set([handles.entry1 handles.entry1txt handles.ok_btn handles.cancel_btn],'Visible','on');
    SetFrame(handles,1,'Indique as opções para criação de parâmetro:');
    set([handles.menulist handles.xlist handles.ylist],'Enable','off');
    UpdateButtonStatus(hObject, eventdata, handles);
    
    set([handles.plot handles.selpts],'XData',NaN,'YData',NaN);
    set([handles.inipts handles.endpts handles.testptlbl handles.eventpts handles.eventlbl],'Visible','off');
    
    setappdata(handles.window,'func','CreateParam_1');
    entry1_Callback(hObject, eventdata, handles);
    
elseif strcmp(func,'CreateParam_1') && ~cancel
    
    if ok
        
        Y = getappdata(handles.window,'tempdata');
        if ~isempty(Y)
            ShowTemporaryPlot(hObject, eventdata, handles, Y, get(handles.ylabel,'String'));
            setappdata(handles.window,'func','CreateParam_2');
        else
            beep; uiwait(errordlg('Erro na criação dos dados.','Erro','modal')); drawnow;
            return
        end
        
    else
        
        set(handles.window,'Pointer','watch');
        opt = get(handles.entry1,'Value');
        X = DADOS(:,end);
        
        switch opt        
            case 1  % Duplicar
                ycol = get(handles.entry2,'Value');
                Y = DADOS(:,ycol);
                ypar = denumber(PARAM{ycol});
                
            case 2  % Série de zeros
                Y = zeros(size(DADOS,1),1);
                ypar = 'Zeros';
                
            case 3  % Série de uns
                Y = ones(size(DADOS,1),1);
                ypar = 'Uns';
                
            case 4  % Série constante
                k = str2double(get(handles.entry2,'String'));
                if isnan(k);
                    beep; uiwait(errordlg('Parâmetro de entrada incoerente.','Erro','modal')); drawnow;
                    Y = [];
                else
                    Y = k*ones(size(DADOS,1),1);
                end
                ypar = 'Constante';
                
            case 5  % Série crescente
                k1 = str2double(get(handles.entry3,'String'));
                k2 = str2double(get(handles.entry4,'String'));
                if isnan(k1) || isnan(k2)
                    beep; uiwait(errordlg('Parâmetro de entrada incoerente.','Erro','modal')); drawnow;
                    Y = [];
                else
                    Y = linspace(k1,k2,size(DADOS,1))';
                end
                ypar = 'Rampa';
                
            case 6  % Série aleatória
                drawnow;
                pdf_code = {'beta','chi2','unid','exp','f','gam','logn','nbin','norm','rayl','t','unif','weib'};
                pdf_npar = [2, 1, 1, 1, 2, 2, 2, 2, 2, 1, 1, 2, 2];
                Npdf = get(handles.entry2,'Value');
                p1 = str2double(get(handles.entry3,'String'));
                if pdf_npar(Npdf) == 2
                    p2 = str2double(get(handles.entry4,'String'));
                else
                    p2 = [];
                end
                if isnan(p1) || (pdf_npar(Npdf)==2 && isnan(p2))
                    beep; uiwait(errordlg('Parâmetro de entrada incoerente.','Erro','modal')); drawnow;
                    Y = [];
                else
                    try
                        Y = icdf(pdf_code{Npdf},rand(size(DADOS,1),1),p1,p2);
                    catch
                        beep; uiwait(errordlg(lasterr,'Erro','modal')); drawnow;
                        Y = [];
                    end
                end
                ypar = ['Aleatória (' pdf_code{Npdf} ')'];
                
        end
        
        if ~isempty(Y)
            set(handles.plots(1,2),'XData',X,'YData',Y);
        else
            set(handles.plots(1,2),'XData',NaN,'YData',NaN);
        end
        set(handles.ylabel,'String',ypar);
        setappdata(handles.window,'tempdata',Y);
        UpdateDataTips(hObject, eventdata, handles);
        
    end
    
elseif strcmp(func,'CreateParam_2') && ~cancel
    
    name = TrimParamName(get(handles.entry1,'String'),handles.maxparamlength);
    if isempty(name)
        beep; uiwait(errordlg('Nome do parâmetro não pode ser vazio.','Erro','modal')); drawnow;
        return
    end 
    PARAM = InsertParam(PARAM,name);
    CheckRepParam(PARAM,name);
    
    data  = getappdata(handles.window,'tempdata');
    DADOS = [DADOS(:,1:end-1), data, DADOS(:,end)];
    
    xcol = length(PARAM);
    ycol = length(PARAM)-1;
    
    HideTemporaryPlot(hObject, eventdata, handles, xcol, ycol, PARAM);
    SetButtonStatus(handles,handles.Hist_btn,1);
    setappdata(handles.window,'func','none');
    
    setappdata(handles.window,'change',1);
    NewEvent(handles,['Parâmetro ''' name ''' criado.']);
    
elseif cancel
    
    SetButtonStatus(handles,handles.Hist_btn,1);
    HideTemporaryPlot(hObject, eventdata, handles);
    
end

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function RenameParamY_Callback(hObject, eventdata, handles)
% Função para renomear parâmetro selecionado em y

PARAM   = get(handles.xlist,'String');
Nren    = get(handles.ylist,'Value');
func    = getappdata(handles.window,'func');
cancel  = getappdata(handles.window,'cancel');
reftime = getappdata(handles.window,'reftime');

if Nren == length(PARAM);
    beep; uiwait(errordlg('Não é possível renomear parâmetro ''No. OBS.''','Erro','modal')); drawnow;
    return
end

if strcmp(func,'none') && ~cancel
    
    SetEntrySize(handles,handles.entry1,2);
    set(handles.entry1,'Style','edit','String',get(handles.ylabel,'String'));
    
    set([handles.entry1 handles.ok_btn handles.cancel_btn],'Visible','on');
    SetFrame(handles,1,'Renomear parâmetro y:');
    set([handles.menulist handles.ylist],'Enable','off');
    UpdateButtonStatus(hObject, eventdata, handles);
    
    setappdata(handles.window,'func','RenameParamY_1');
    
elseif strcmp(func,'RenameParamY_1') && ~cancel
    
    oldname = get(handles.ylabel,'String');
    name = TrimParamName(get(handles.entry1,'String'),handles.maxparamlength);
    if isempty(name)
        beep; uiwait(errordlg('Nome do parâmetro não pode ser vazio.','Erro','modal')); drawnow;
        return
    elseif strcmp(oldname,name)
        cancel_btn_Callback(hObject, eventdata, handles);
        return
    end
    PARAM{Nren} = strrep(PARAM{Nren}, oldname, name);
    CheckRepParam(PARAM,name);
    
    if strcmp(oldname,reftime)
        reftime = name;
        setappdata(handles.window,'reftime',reftime);
    end
    ClearEntryBox(hObject, eventdata, handles);
    SetEntrySize(handles,handles.entry1,1);
    set([handles.xlist handles.ylist],'String',PARAM);
    set(handles.ylabel,'String',name);
    UpdateTimeCols(hObject, eventdata, handles);
    setappdata(handles.window,'func','none');
    
    setappdata(handles.window,'change',1);
    NewEvent(handles,['Parâmetro ''' oldname ''' renomeado para ''' name '''.']);
    
elseif cancel
    
    SetEntrySize(handles,handles.entry1,1);
    
end

% --------------------------------------------------------------------
function CutSelectedPts_Callback(hObject, eventdata, handles)
global DADOS
% Função que exclui os pontos selecionados

sel = getappdata(handles.window,'sel');

if isempty(sel)
    beep; uiwait(errordlg('Não há pontos selecionados.','Erro','modal')); drawnow;
    return
elseif length(sel) == size(DADOS,1)
    beep; uiwait(errordlg('Pontos selecionados correspodem a todo o arquivo.','Erro','modal')); drawnow;
    return
end

button = questdlg({['Deseja excluir ' int2str(length(sel)) ' pontos selecionados?'],...
        'Todos os parâmetros serão afetados.'},'Confirmação','Sim','Não','Não'); drawnow;
if strcmp(button,'Sim')
    
    set(handles.window,'Pointer','watch');
    DADOS(sel,:) = [];
    setappdata(handles.window,'sel',[]);
    UpdateGraph(hObject, eventdata, handles);
    
    setappdata(handles.window,'change',1);
    NewEvent(handles,[int2str(length(sel)) ' observações excluídas.']);
    
    Window_ButtonMotionFcn(hObject, eventdata, handles);
end

% --------------------------------------------------------------------
function CutNaNPts_Callback(hObject, eventdata, handles)
global DADOS
% Função que exclui os pontos invalidos (NaN)

ycol  = get(handles.ylist,'Value');
ypar = get(handles.ylabel,'String');
sel   = getappdata(handles.window,'sel');

Y = DADOS(:,ycol);
exc = find(isnan(Y));

if isempty(exc)
    beep; uiwait(errordlg(['Não há pontos inválidos no parâmetro ''' ypar '''.'],'Erro','modal')); drawnow;
    return
elseif length(exc) == size(DADOS,1)
    beep; uiwait(errordlg('Pontos inválidos correspodem a todo o arquivo.','Erro','modal')); drawnow;
    return
end

button = questdlg({['Deseja excluir ' int2str(length(exc)) ' pontos inválidos do parâmetro ''' ypar '''?'],...
        'Todos os parâmetros serão afetados.'},'Confirmação','Sim','Não','Não'); drawnow;
if strcmp(button,'Sim')
    
    set(handles.window,'Pointer','watch');
    
    sel2 = zeros(size(DADOS,1),1);
    sel2(sel) = 1;
    
    sel2(exc) = [];
    DADOS(exc,:) = [];
    
    sel = find(sel2);
    setappdata(handles.window,'sel',sel);
    
    UpdateGraph(hObject, eventdata, handles);
    
    setappdata(handles.window,'change',1);
    NewEvent(handles,[int2str(length(exc)) ' observações excluídas.']);
    
    Window_ButtonMotionFcn(hObject, eventdata, handles);
end

% --------------------------------------------------------------------
function EliminateSlice_Callback(hObject, eventdata, handles)
global DADOS
% Função que elimina intervalo selecionado

pts = GetIntervPts(handles);
sel = getappdata(handles.window,'sel');

if isempty(pts)
    beep; uiwait(errordlg('Não há pontos no intervalo selecionado.','Erro','modal')); drawnow;
    return
elseif length(pts) == size(DADOS,1)
    beep; uiwait(errordlg('Intervalo selecionado corresponde a todo o arquivo.','Erro','modal')); drawnow;
    return
end

button = questdlg({['Pontos no intervalo: ' num2str(length(pts))],'Deseja excluir o intervalo selecionado?',...
        'Todos os parâmetros serão afetados.'},'Confirmação','Sim','Não','Não'); drawnow;

if strcmp(button,'Sim')
    
    set(handles.window,'Pointer','watch');
    
    sel2 = zeros(size(DADOS,1),1);
    sel2(sel) = 1;
    
    sel2(pts) = [];
    DADOS(pts,:) = [];
    
    sel = find(sel2);
    setappdata(handles.window,'sel',sel);
    
    UpdateGraph(hObject, eventdata, handles);
    
    setappdata(handles.window,'change',1);
    NewEvent(handles,[int2str(length(pts)) ' observações excluídas.']);
    
    Window_ButtonMotionFcn(hObject, eventdata, handles);
end

% --------------------------------------------------------------------
function EliminateInverseSlice_Callback(hObject, eventdata, handles)
global DADOS
% Função que elimina inverso do intervalo selecionado

pts = GetIntervPts(handles);
sel = getappdata(handles.window,'sel');

if isempty(pts)
    beep; uiwait(errordlg('Inverso do intervalo selecionado corresponde a todo o arquivo.','Erro','modal')); drawnow;
    return
elseif length(pts) == size(DADOS,1)
    beep; uiwait(errordlg('Não há pontos fora do intervalo selecionado.','Erro','modal')); drawnow;
    return
end

button = questdlg({['Pontos fora do intervalo: ' num2str(size(DADOS,1)-length(pts))],...
        'Deseja excluir o inverso do intervalo selecionado?',...
        'Todos os parâmetros serão afetados.'},'Confirmação','Sim','Não','Não'); drawnow;

if strcmp(button,'Sim')
    
    set(handles.window,'Pointer','watch');
    exc = setdiff(DADOS(:,end),pts);
    
    sel2 = zeros(size(DADOS,1),1);
    sel2(sel) = 1;
    
    sel2(exc) = [];
    DADOS(exc,:) = [];
    
    sel = find(sel2);
    setappdata(handles.window,'sel',sel);
    
    UpdateGraph(hObject, eventdata, handles);
    
    setappdata(handles.window,'change',1);
    NewEvent(handles,[int2str(length(exc)) ' observações excluídas.']);
    
    Window_ButtonMotionFcn(hObject, eventdata, handles);
end

% --------------------------------------------------------------------
function RemoveParamY_Callback(hObject, eventdata, handles)
global DADOS
% Função para remover o parâmetro selecionado em y

PARAM    = get(handles.xlist,'String');
reftime  = getappdata(handles.window,'reftime');
nreftime = findpar(PARAM,reftime,0,1);
Nrem     = get(handles.ylist,'Value');
ypar     = get(handles.ylabel,'String');

if Nrem == length(PARAM);
    beep; uiwait(errordlg('Não é possível remover o parâmetro ''No. OBS.''','Erro','modal')); drawnow;
    return
end

if ~isempty(nreftime) && Nrem == nreftime
    beep; uiwait(errordlg({['Não é possível remover o parâmetro ''' ypar ''''],...
            'pois o mesmo está definido como tempo de referência.'},'Erro','modal')); drawnow;
    return
end

button = questdlg(['Deseja excluir o parâmetro ''' get(handles.ylabel,'String') '''?'],'Confirmação','Sim','Não','Não'); drawnow;
if strcmp(button,'Sim')
    set(handles.window,'Pointer','watch');
    DADOS(:,Nrem) = [];
    PARAM(Nrem)   = [];
    PARAM = SetParamNumbers(PARAM);
    UpdateGraph(hObject, eventdata, handles,min(get(handles.xlist,'Value'),length(PARAM)), min(Nrem,length(PARAM)),PARAM);
    
    setappdata(handles.window,'change',1);
    NewEvent(handles,['Parâmetro ''' get(handles.ylabel,'String') ''' excluído.']);
    
    Window_ButtonMotionFcn(hObject, eventdata, handles);
end

% --------------------------------------------------------------------
function RemoveInvalidParams_Callback(hObject, eventdata, handles, zerowarn)
global DADOS
% Remove todos os parâmetros invalidos (apenas NaNs)

if nargin == 3
    zerowarn = 1;
end

PARAM = get(handles.xlist,'String');

exc = [];
for n = 1:size(DADOS,2)-1
    if all(isnan(DADOS(:,n)))
        exc = [exc; n];
    end
end

Nexc = length(exc);

if Nexc == 0
    if zerowarn
        uiwait(warndlg('Não foram encontrados parâmetros inválidos.','Aviso','modal')); drawnow;
    end
else
    if Nexc == 1
        excpar = PARAM{exc};
        str = char('O seguinte parâmetro não contém dados válidos:',' ',['-   ' excpar],' ',...
            'Deseja excluí-lo?');
    elseif Nexc <= 32
        str = char('Os seguintes parâmetros não contêm dados válidos:',' ',[char(45*ones(Nexc,1)) char(32*ones(Nexc,3)) ...
                char(PARAM{exc})],' ','Deseja excluí-los?');
    else
        str = {['Foram encontrados ' num2str(Nexc) ' parâmetros inteiramente inválidos.'],' ','Deseja excluí-los?'};
    end
    
    button = questdlg(str,'Opção','Sim','Não','Não'); drawnow;
    
    if strcmp(button,'Sim')
        
        set(handles.window,'Pointer','watch');
        DADOS(:,exc) = [];
        PARAM(exc)   = [];
        PARAM = SetParamNumbers(PARAM);
        UpdateGraph(hObject, eventdata, handles, length(PARAM), 1, PARAM);
        set(handles.graphs,'XLim',AutoLim(handles.plot));
        
        setappdata(handles.window,'change',1);
        if Nexc == 1
            NewEvent(handles,['Parâmetro inválido ''' excpar ''' excluído.']);
        else
            NewEvent(handles,[num2str(Nexc) ' parâmetros inválidos excluídos.']);
        end
        
        Window_ButtonMotionFcn(hObject, eventdata, handles);
    end
end

% --------------------------------------------------------------------
function NanSelectedPts_Callback(hObject, eventdata, handles)
global DADOS
% Função que invalida os pontos selecionados (atribui NaN)

sel  = getappdata(handles.window,'sel');
ycol = get(handles.ylist,'Value');
ypar = get(handles.ylabel,'String');

if isempty(sel)
    beep; uiwait(errordlg('Não há pontos selecionados.','Erro','modal')); drawnow;
    return
end
if ycol == size(DADOS,2)
    beep; uiwait(errordlg('Não é possível alterar o parâmetro ''No. OBS.''','Erro','modal')); drawnow;
    return
end

button = questdlg({['Deseja invalidar ',int2str(length(sel)),' pontos selecionados?'],...
        ['Apenas o parâmetro ''' ypar ''' será afetado.']},'Confirmação','Sim','Não','Não'); drawnow;

if strcmp(button,'Sim')
    
    set(handles.window,'Pointer','watch');
    DADOS(sel,ycol) = NaN;
    UpdatePlot(hObject, eventdata, handles);
    
    setappdata(handles.window,'change',1);
    NewEvent(handles,[int2str(length(sel)) ' pontos invalidados no parâmetro ''' ypar '''.']);
    
    Window_ButtonMotionFcn(hObject, eventdata, handles);
end

% --------------------------------------------------------------------
function NanSlice_Callback(hObject, eventdata, handles)
global DADOS
% Função que invalida o intervalo selecionado (atribui NaN)

ycol = get(handles.ylist,'Value');
ypar = get(handles.ylabel,'String');
pts = GetIntervPts(handles);

if isempty(pts)
    beep; uiwait(errordlg('Não há pontos no intervalo selecionado.','Erro','modal')); drawnow;
    return
end
if ycol == size(DADOS,2)
    beep; uiwait(errordlg('Não é possível alterar o parâmetro ''No. OBS.''','Erro','modal')); drawnow;
    return
end

button = questdlg({['Pontos no intervalo: ' num2str(length(pts))],'Deseja invalidar o intervalo selecionado?',...
        ['Apenas o parâmetro ''' ypar ''' será afetado.']},'Confirmação','Sim','Não','Não'); drawnow;

if strcmp(button,'Sim')
    
    set(handles.window,'Pointer','watch');
    DADOS(pts,ycol) = NaN;
    UpdatePlot(hObject, eventdata, handles);
    
    setappdata(handles.window,'change',1);
    NewEvent(handles,[int2str(length(pts)) ' pontos invalidados no parâmetro ''' ypar '''.']);
    
    Window_ButtonMotionFcn(hObject, eventdata, handles);
end

% --------------------------------------------------------------------
function NanInverseSlice_Callback(hObject, eventdata, handles)
global DADOS
% Função que invalida o inverso do intervalo selecionado (atribui NaN)

ycol = get(handles.ylist,'Value');
ypar = get(handles.ylabel,'String');
pts = GetIntervPts(handles);

if length(pts) == size(DADOS,1)
    beep; uiwait(errordlg('Não há pontos fora do intervalo selecionado.','Erro','modal')); drawnow;
    return
end
if ycol == size(DADOS,2)
    beep; uiwait(errordlg('Não é possível alterar o parâmetro ''No. OBS.''','Erro','modal')); drawnow;
    return
end

button = questdlg({['Pontos fora do intervalo: ' num2str(size(DADOS,1)-length(pts))],...
        'Deseja invalidar o inverso do intervalo selecionado?',...
        ['Apenas o parâmetro ''' ypar ''' será afetado.']},'Confirmação','Sim','Não','Não'); drawnow;

if strcmp(button,'Sim')
    
    set(handles.window,'Pointer','watch');
    exc = setdiff(DADOS(:,end),pts);
    DADOS(exc,ycol) = NaN;
    UpdatePlot(hObject, eventdata, handles);
    
    setappdata(handles.window,'change',1);
    NewEvent(handles,[int2str(length(exc)) ' pontos invalidados no parâmetro ''' ypar '''.']);
    
    Window_ButtonMotionFcn(hObject, eventdata, handles);
end

% --------------------------------------------------------------------
function SendToWorkspace_all_Callback(hObject, eventdata, handles)
global DADOS
% Função que transfere DADOS e PARAM para o Workspace

button = questdlg('Deseja enviar as matrizes DADOS e PARAM para o Workspace?','Confirmação','Sim','Não','Não'); drawnow;
if strcmp(button,'Sim')
    
    PARAM = char(get(handles.xlist,'String'));
    
    assignin('base','DADOS',DADOS);
    assignin('base','PARAM',PARAM);
    
    uiwait(okdlg('Variáveis DADOS e PARAM criadas no Workspace.','Aviso','modal')); drawnow;
end

% --------------------------------------------------------------------
function SendToWorkspace_slice_Callback(hObject, eventdata, handles)
global DADOS
% Função que transfere o intervalo selecionado de DADOS e PARAM para o Workspace

pts = GetIntervPts(handles);
if isempty(pts)
    beep; uiwait(errordlg('Não há pontos no intervalo selecionado.','Erro','modal')); drawnow;
    return
end

button = questdlg({['Pontos no intervalo: ' num2str(length(pts))],'Deseja enviar o intervalo selecionado das',...
        'matrizes DADOS e PARAM para o Workspace?'},'Confirmação','Sim','Não','Não'); drawnow;

if strcmp(button,'Sim')
    
    PARAM = char(get(handles.xlist,'String'));
    DADOS2 = [DADOS(pts,1:end-1), (1:length(pts))'];
    
    assignin('base','DADOS',DADOS2);
    assignin('base','PARAM',PARAM);
    
    uiwait(okdlg('Variáveis DADOS e PARAM criadas no Workspace.','Aviso','modal')); drawnow;
end

% --------------------------------------------------------------------
function SendToWorkspace_sel_Callback(hObject, eventdata, handles)
global DADOS
% Função que transfere os pontos selecionados de DADOS e PARAM para o Workspace

sel = getappdata(handles.window,'sel');
if isempty(sel)
    beep; uiwait(errordlg('Não há pontos selecionados.','Erro','modal')); drawnow;
    return
end

button = questdlg({'Deseja enviar os pontos selecionados das','matrizes DADOS e PARAM para o Workspace?'},...
    'Confirmação','Sim','Não','Não'); drawnow;

if strcmp(button,'Sim')
    
    PARAM = char(get(handles.xlist,'String'));
    DADOS2 = [DADOS(sel,1:end-1), (1:length(sel))'];
    
    assignin('base','DADOS',DADOS2);
    assignin('base','PARAM',PARAM);
    
    uiwait(okdlg('Variáveis DADOS e PARAM criadas no Workspace.','Aviso','modal')); drawnow;
end

% --------------------------------------------------------------------
function SendToWorkspaceXY_all_Callback(hObject, eventdata, handles)
% Função que transfere os parâmetros X e Y para o Workspace

xcol = get(handles.xlist,'Value');
ycol = get(handles.ylist,'Value');
xpar = get(handles.xlabel,'String');
ypar = get(handles.ylabel,'String');

button = questdlg(['Deseja enviar os parâmetros ''' xpar ''' e ''' ypar ''' para o Workspace?'],'Confirmação',...
    'Sim','Não','Não'); drawnow;

if ~strcmp(button,'Sim')
    return
end

[name1, name2] = inputvalues('Variáveis',{[xpar ':'],[ypar ':']},{name2var(xpar),name2var(ypar)});

if ~ischar(name1)
    return
end

if strcmp(name1,name2) || isempty(name1) || isempty(name2)
    beep; uiwait(errordlg('Os nomes devem ser distintos e não vazios.','Erro','modal')); drawnow;
    return
end
if any(exist(name1) == [2 3 4 5 6])
    beep; uiwait(errordlg(['''' name1 ''' é nome de função ou arquivo.'],'Erro','modal')); drawnow;
    return
end
if any(exist(name2) == [2 3 4 5 6])
    beep; uiwait(errordlg(['''' name2 ''' é nome de função ou arquivo.'],'Erro','modal')); drawnow;
    return
end
if ~strcmp(name1,name2var(name1))
    beep; uiwait(errordlg(['''' name1 ''' não é nome de variável válido.'],'Erro','modal')); drawnow;
    return
end
if ~strcmp(name2,name2var(name2))
    beep; uiwait(errordlg(['''' name2 ''' não é nome de variável válido.'],'Erro','modal')); drawnow;
    return
end

global DADOS
assignin('base',name1,DADOS(:,xcol));
assignin('base',name2,DADOS(:,ycol));

uiwait(okdlg(['Variáveis ''' name1 ''' e ''' name2 ''' criadas no Workspace.'],'Aviso','modal')); drawnow;

% --------------------------------------------------------------------
function SendToWorkspaceXY_slice_Callback(hObject, eventdata, handles)
% Função que transfere o intervalo selecionado dos parâmetros X e Y para o Workspace

pts = GetIntervPts(handles);
if isempty(pts)
    beep; uiwait(errordlg('Não há pontos no intervalo selecionado.','Erro','modal')); drawnow;
    return
end

xcol = get(handles.xlist,'Value');
ycol = get(handles.ylist,'Value');
xpar = get(handles.xlabel,'String');
ypar = get(handles.ylabel,'String');

button = questdlg({['Pontos no intervalo: ' num2str(length(pts))],'Deseja enviar o intervalo selecionado dos parâmetros',...
        ['''' xpar ''' e ''' ypar ''' para o Workspace?']},'Confirmação','Sim','Não','Não'); drawnow;

if ~strcmp(button,'Sim')
    return
end

[name1, name2] = inputvalues('Variáveis',{[xpar ':'],[ypar ':']},{name2var(xpar),name2var(ypar)});

if ~ischar(name1)
    return
end

if strcmp(name1,name2) || isempty(name1) || isempty(name2)
    beep; uiwait(errordlg('Os nomes devem ser distintos e não vazios.','Erro','modal')); drawnow;
    return
end
if any(exist(name1) == [2 3 4 5 6])
    beep; uiwait(errordlg(['''' name1 ''' é nome de função ou arquivo.'],'Erro','modal')); drawnow;
    return
end
if any(exist(name2) == [2 3 4 5 6])
    beep; uiwait(errordlg(['''' name2 ''' é nome de função ou arquivo.'],'Erro','modal')); drawnow;
    return
end
if ~strcmp(name1,name2var(name1))
    beep; uiwait(errordlg(['''' name1 ''' não é nome de variável válido.'],'Erro','modal')); drawnow;
    return
end
if ~strcmp(name2,name2var(name2))
    beep; uiwait(errordlg(['''' name2 ''' não é nome de variável válido.'],'Erro','modal')); drawnow;
    return
end

global DADOS
assignin('base',name1,DADOS(pts,xcol));
assignin('base',name2,DADOS(pts,ycol));

uiwait(okdlg(['Variáveis ''' name1 ''' e ''' name2 ''' criadas no Workspace.'],'Aviso','modal')); drawnow;

% --------------------------------------------------------------------
function SendToWorkspaceXY_sel_Callback(hObject, eventdata, handles)
% Função que transfere os pontos selecionados dos parâmetros X e Y para o Workspace

sel = getappdata(handles.window,'sel');
if isempty(sel)
    beep; uiwait(errordlg('Não há pontos selecionados.','Erro','modal')); drawnow;
    return
end

xcol = get(handles.xlist,'Value');
ycol = get(handles.ylist,'Value');
xpar = get(handles.xlabel,'String');
ypar = get(handles.ylabel,'String');

button = questdlg({'Deseja enviar os pontos selecionados dos parâmetros',['''' xpar ''' e ''' ypar ''' para o Workspace?']},...
    'Confirmação','Sim','Não','Não'); drawnow;

if ~strcmp(button,'Sim')
    return
end

[name1, name2] = inputvalues('Variáveis',{[xpar ':'],[ypar ':']},{name2var(xpar),name2var(ypar)});

if ~ischar(name1)
    return
end

if strcmp(name1,name2) || isempty(name1) || isempty(name2)
    beep; uiwait(errordlg('Os nomes devem ser distintos e não vazios.','Erro','modal')); drawnow;
    return
end
if any(exist(name1) == [2 3 4 5 6])
    beep; uiwait(errordlg(['''' name1 ''' é nome de função ou arquivo.'],'Erro','modal')); drawnow;
    return
end
if any(exist(name2) == [2 3 4 5 6])
    beep; uiwait(errordlg(['''' name2 ''' é nome de função ou arquivo.'],'Erro','modal')); drawnow;
    return
end
if ~strcmp(name1,name2var(name1))
    beep; uiwait(errordlg(['''' name1 ''' não é nome de variável válido.'],'Erro','modal')); drawnow;
    return
end
if ~strcmp(name2,name2var(name2))
    beep; uiwait(errordlg(['''' name2 ''' não é nome de variável válido.'],'Erro','modal')); drawnow;
    return
end

global DADOS
assignin('base',name1,DADOS(sel,xcol));
assignin('base',name2,DADOS(sel,ycol));

uiwait(okdlg(['Variáveis ''' name1 ''' e ''' name2 ''' criadas no Workspace.'],'Aviso','modal')); drawnow;

% --------------------------------------------------------------------
function GetFromWorkspace_Callback(hObject, eventdata, handles)
global DADOS
% Função que obtem parâmetros do Workspace

PARAM  = get(handles.xlist,'String');
func   = getappdata(handles.window,'func');
cancel = getappdata(handles.window,'cancel');

if strcmp(func,'none') && ~cancel
    
    N = size(DADOS,1);
    vars = struct2cell(evalin('base','whos'))'; % Name Size Bytes Class
    
    if isempty(vars)
        beep; uiwait(errordlg('Não há variáveis no Workspace.','Erro','modal')); drawnow;
        return
    end
    for n = size(vars,1):-1:1
        if ~strcmp(vars{n,4},'double') || length(vars{n,2}) ~= 2 || vars{n,2}(1) ~= N
            vars(n,:) = [];
        end
    end
    if isempty(vars)
        beep; uiwait(errordlg(['Não há variáveis no Workspace com tamanho compatível (' num2str(N) ' × n).'],'Erro','modal')); drawnow;
        return
    end
    for n = 1:size(vars,1)
        varslist{n} = [vars{n,1} '  (' num2str(vars{n,2}(1)) '×' num2str(vars{n,2}(2)) ')'];
    end
    
    [sel,ok] = listdlg2('Name','Obter parâmetros','HeaderString','Variáveis compatíveis do Workspace:','SelectionMode','multiple','ListString',varslist,...
        'OKString','OK','CancelString','Cancela','SelectAllString','Selecionar tudo','SelectNoneString','Limpar','ListSize',[190 305]); drawnow;
    
    if ~ok
        return
    elseif isempty(sel)
        beep; uiwait(errordlg('Nenhuma variável selecionada.','Erro','modal')); drawnow;
        return
    else
        newDADOS = [];
        varnames = {};
        for n = 1:length(sel)
            newvar   = evalin('base',vars{sel(n),1});
            newDADOS = [newDADOS newvar];
            for m = 1:size(newvar,2)
                if size(newvar,2) == 1
                    varnames{length(varnames)+1} = vars{sel(n),1};
                else
                    varnames{length(varnames)+1} = [vars{sel(n),1} '_' num2str(m)];
                end
            end
        end
    end
    
    Nnewpar = size(newDADOS,2);
    
    setappdata(handles.window,'tempdata',{newDADOS,1,Nnewpar,varnames});
    ShowTemporaryPlot(hObject, eventdata, handles, newDADOS(:,1), varnames{1});
    if Nnewpar > 1
        set(handles.frametxt,'String',['Defina o nome do novo parâmetro (1/' num2str(Nnewpar) '):']);
    end
    
    setappdata(handles.window,'func','GetFromWorkspace_1');
    
elseif strcmp(func,'GetFromWorkspace_1') && ~cancel
    
    tempdata = getappdata(handles.window,'tempdata');
    newDADOS = tempdata{1};
    nnewpar  = tempdata{2};
    Nnewpar  = tempdata{3};
    varnames = tempdata{4};
    
    name = TrimParamName(get(handles.entry1,'String'),handles.maxparamlength);
    if isempty(name)
        beep; uiwait(errordlg('Nome do parâmetro não pode ser vazio.','Erro','modal')); drawnow;
        return
    end 
    PARAM = InsertParam(PARAM,name);
    CheckRepParam(PARAM,name);
    
    data = newDADOS(:,1);
    DADOS = [DADOS(:,1:end-1), data, DADOS(:,end)];
    
    xcol = get(handles.xlist,'Value');
    if xcol == length(PARAM)-1
        xcol = xcol+1;
    end
    ycol = length(PARAM)-1;
    
    NewEvent(handles,['Parâmetro ''' name ''' obtido do Workspace.']);
    setappdata(handles.window,'change',1);
    
    newDADOS(:,1) = [];
    varnames(1) = [];
    nnewpar = nnewpar+1;
    
    if size(newDADOS,2)
        set(handles.xlist,'String',PARAM,'Value',xcol);
        set(handles.ylist,'String',PARAM,'Value',ycol);
        setappdata(handles.window,'tempdata',{newDADOS,nnewpar,Nnewpar,varnames});
        ShowTemporaryPlot(hObject, eventdata, handles, newDADOS(:,1), varnames{1});
        set(handles.frametxt,'String',['Defina o nome do novo parâmetro (' num2str(nnewpar) '/' num2str(Nnewpar) '):']);
    else
        HideTemporaryPlot(hObject, eventdata, handles, xcol, ycol, PARAM);
        setappdata(handles.window,'func','none');
    end
    
elseif cancel
    
    HideTemporaryPlot(hObject, eventdata, handles);
    
end

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function SelectPoints_Callback(hObject, eventdata, handles)
% Seleciona pontos por caixa de seleção
% Continua ativada enquanto o usuario não interromper

func = getappdata(handles.window,'func');
multilist = {'MultiPlot5_1','MultiPlot3_1','MultiGraph5_1'};

if strcmp(get(handles.SelectPoints,'Checked'),'off')
    
    set(handles.SelectPoints,'Checked','on');
    
    if isempty(strmatch(func,multilist,'exact'))
            set([handles.menulist handles.OptionsMenu handles.DisplayMenu],'Enable','off');
            UpdateButtonStatus(hObject, eventdata, handles);
            SetButtonStatus(handles,[handles.Selection_btn handles.Delete_btn handles.InterpSelPts_btn handles.FitZoom_btn,...
                    handles.DeSel_btn handles.Setpt2_btn handles.Setevt_btn handles.TestPoints_btn handles.Events_btn],1);
    end
    
    oldfunc = getappdata(handles.window,'clickfunc');
    sel = getappdata(handles.window,'sel');
    setappdata(handles.window,'tempdata',{oldfunc,sel});
    setappdata(handles.window,'clickfunc','select');
    
    set(handles.title,'String','Selecione / Desselecione pontos');
    set(handles.window,'CloseRequestFcn',[]);
    
else
    
    set(handles.title,'String','');
    
    tempdata = getappdata(handles.window,'tempdata');
    oldfunc = tempdata{1};
    oldsel  = tempdata{2};
    setappdata(handles.window,'tempdata',[]);
    setappdata(handles.window,'clickfunc',oldfunc);
    
    sel = getappdata(handles.window,'sel');
    
    if ~isequal(sel,oldsel);
        NewEvent(handles,['Pontos selecionados: ' num2str(length(sel))]);
    end
    
    set(handles.SelectPoints,'Checked','off');
    
    if isempty(strmatch(func,multilist,'exact'))
        set([handles.menulist handles.OptionsMenu handles.DisplayMenu],'Enable','on');
        UpdateButtonStatus(hObject, eventdata, handles);
    else
        set(handles.Selection_btn,'Value',0);
    end
    
    set(handles.window,'CloseRequestFcn','R_DAT(''Window_CloseRequestFcn'',gcf,[],guidata(gcf))');
    
end

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function SelectByBox_Callback(hObject, eventdata, handles)
global DADOS
% Seleciona pontos por caixa de seleção

xcol    = get(handles.xlist,'Value');
ycol    = get(handles.ylist,'Value');
sel     = getappdata(handles.window,'sel');
oldfunc = getappdata(handles.window,'clickfunc');
setappdata(handles.window,'clickfunc','none');

set(handles.title,'String','Selecione pontos');

set(handles.window,'CloseRequestFcn',[]);
set([handles.menulist handles.xlist handles.ylist handles.controlbtns],'Enable','off');
UpdateButtonStatus(hObject, eventdata, handles);

waitforbuttonpress;
p1 = get(handles.graph,'CurrentPoint');
setappdata(handles.window,'rbbox',1);
rbbox;
setappdata(handles.window,'rbbox',0);
p2 = get(handles.graph,'CurrentPoint');

set([handles.menulist handles.xlist handles.ylist handles.controlbtns],'Enable','on');
UpdateButtonStatus(hObject, eventdata, handles);
set(handles.window,'CloseRequestFcn','R_DAT(''Window_CloseRequestFcn'',gcf,[],guidata(gcf))');

p1 = p1(1,1:2);
p2 = p2(1,1:2);

xbox = sort([p1(1) p2(1)]);
ybox = sort([p1(2) p2(2)]);

X = denan(DADOS(:,xcol));
Y = denan(DADOS(:,ycol));

sel = union(sel, intersect(...
    intersect(find(X >= xbox(1)), find(X <= xbox(2))), ...
    intersect(find(Y >= ybox(1)), find(Y <= ybox(2))) ));

set(handles.title,'String','')
setappdata(handles.window,'sel',sel);
setappdata(handles.window,'clickfunc',oldfunc);
NewEvent(handles,['Pontos selecionados: ' num2str(length(sel))]);
UpdateSel(hObject, eventdata, handles);

% --------------------------------------------------------------------
function SelectByBar_Callback(hObject, eventdata, handles)
global DADOS
% Seleciona pontos por barra de seleção

sel = getappdata(handles.window,'sel');
barpts = getappdata(handles.window,'barpts');

if size(barpts,1) ~= 3
    barpts = [];
    set(handles.title,'String','Defina o primeiro ponto da barra de seleção');
    set(handles.selbar,'XData',NaN,'YData',NaN);
    setappdata(handles.window,'clickfunc','bar');
else
    
    xcol = get(handles.xlist,'Value');
    ycol = get(handles.ylist,'Value');
    
    X = denan(DADOS(:,xcol));
    Y = denan(DADOS(:,ycol));
    
    if diff(barpts(1:2,1)) > eps
        cfs = polyfit(barpts(1:2,1),barpts(1:2,2),1);
        
        if barpts(3,1) == 1
            sel2 = find(Y >= polyval(cfs,X));
        else
            sel2 = find(Y < polyval(cfs,X));
        end
        sel = union(sel, intersect(intersect(find(X >= barpts(1,1)), find(X <= barpts(2,1))), sel2));
    end
    
    barpts = [];
    set(handles.title,'String','');
    set(handles.selbar,'XData',NaN,'YData',NaN);
    setappdata(handles.window,'sel',sel);
    setappdata(handles.window,'clickfunc','zoom');
    NewEvent(handles,['Pontos selecionados: ' num2str(length(sel))]);
    UpdateSel(hObject, eventdata, handles);
end
setappdata(handles.window,'barpts',barpts);

% --------------------------------------------------------------------
function SelectByValue_Callback(hObject, eventdata, handles)
global DADOS
% Seleciona pontos por valor

func   = getappdata(handles.window,'func');
cancel = getappdata(handles.window,'cancel');
sel    = getappdata(handles.window,'sel');

if strcmp(func,'none') && ~cancel
    
    set(handles.entry1txt,'String','Opção:');
    set(handles.entry2txt,'String','Em:');
    set(handles.entry3txt,'String','Valor:');
    set(handles.entry1,'String',{'Acima','Abaixo','Acima inclusive','Abaixo inclusive','Igual a',...
            'Entre','Entre inclusive','Fora de','Fora de inclusive'},'Value',1);
    set(handles.entry2,'String',{'Tudo','Intervalo'},'Value',1);
    set(handles.entries(3:4),'Style','edit','String','');
    
    set([handles.entries(1:3) handles.entriestxt(1:3) handles.ok_btn handles.cancel_btn],'Visible','on');
    SetFrame(handles,2,'Indique as opções para seleção:');
    set([handles.menulist handles.xlist],'Enable','off');
    UpdateButtonStatus(hObject, eventdata, handles);
    
    setappdata(handles.window,'func','SelectByValue_1');
    
elseif strcmp(func,'SelectByValue_1') && ~cancel
    
    Y = DADOS(:,get(handles.ylist,'Value'));
    
    y1 = str2double(get(handles.entry3,'String'));
    y2 = str2double(get(handles.entry4,'String'));
    opt = get(handles.entry1,'Value');
    in = get(handles.entry2,'Value');
    
    if isnan(y1) || (opt>5 && isnan(y2))
        beep; uiwait(errordlg('Parâmetro de entrada incoerente.','Erro','modal')); drawnow;
        return
    end
    if opt <= 4
        y2 = NaN;
    else
        y12 = sort([y1 y2]);
        y1 = min(y12);
        y2 = max(y12);
    end
    
    if in == 1 % Tudo
        pts = DADOS(:,end);
    else       % Intervalo
        pts = GetIntervPts(handles);
    end
    if isempty(pts)
        beep; uiwait(errordlg('Não há pontos no intervalo selecionado.','Erro','modal')); drawnow;
        return
    end
    
    switch opt
        case 1 % Acima
            sel2 = find(Y > y1);
        case 2 % Abaixo
            sel2 = find(Y < y1);
        case 3 % Acima inclusive
            sel2 = find(Y >= y1);
        case 4 % Abaixo inclusive
            sel2 = find(Y <= y1);
        case 5 % Igual a
            sel2 = find(Y == y1);
        case 6 % Entre
            sel2 = intersect(find(Y > y1), find(Y < y2));
        case 7 % Entre inclusive
            sel2 = intersect(find(Y >= y1), find(Y <= y2));
        case 8 % Fora de
            sel2 = union(find(Y < y1), find(Y > y2));
        case 9 % Fora de inclusive
            sel2 = union(find(Y <= y1), find(Y >= y2));
    end
    
    if isempty(sel2)
        beep; uiwait(errordlg('Não há pontos no critério indicado.','Erro','modal')); drawnow;
        return
    end

    if ~isempty(sel)
        button = questdlg({['Já há ' num2str(length(sel)) ' pontos selecionados.'],...
                'Deseja acrescentar ou substituir a nova seleção?'},...
            'Confirmação','Acrescentar','Substituir','Cancelar','Acrescentar'); drawnow;
        
        switch button
            case 'Acrescentar'
                % Nada a fazer
            case 'Substituir'
                sel = [];
            otherwise
                return
        end
    end
    
    sel = union(sel, intersect(sel2,pts));
    
    ax = get(handles.graph,'XLim');
    set(handles.auxline,'XData',[ax NaN ax],'YData',[y1 y1 NaN y2 y2],'Visible','on');
    pause(.2);
    set(handles.auxline,'Visible','off');
    
    setappdata(handles.window,'sel',sel);
    ClearEntryBox(hObject, eventdata, handles);
    NewEvent(handles,['Pontos selecionados: ' num2str(length(sel))]);
    UpdateSel(hObject, eventdata, handles);
    setappdata(handles.window,'func','none');
    
end

% --------------------------------------------------------------------
function SelectByTime_Callback(hObject, eventdata, handles)
global DADOS
% Seleciona pontos por tempo (intervalo)

func     = getappdata(handles.window,'func');
cancel   = getappdata(handles.window,'cancel');
sel      = getappdata(handles.window,'sel');
timecols = getappdata(handles.window,'timecols');

if strcmp(func,'none') && ~cancel
    
    if ~isempty(timecols) && ~any(get(handles.xlist,'Value')==timecols)
        set(handles.xlist,'Value',timecols(1));
        xlist_Callback(hObject, eventdata, handles);
    end
    
    set(handles.entry1txt,'String','T ini:');
    set(handles.entry2txt,'String','T fim:');
    set(handles.entriestxt(3:4),'String','(h m s)','HorizontalAlignment','left');
    set(handles.entry1,'Style','edit','String','');
    set(handles.entry2,'Style','edit','String','');
    
    set([handles.entries(1:2) handles.entriestxt handles.ok_btn handles.cancel_btn],'Visible','on');
    SetFrame(handles,1,'Indique as opções para seleção:');
    set([handles.menulist handles.xlist],'Enable','off');
    UpdateButtonStatus(hObject, eventdata, handles);
    
    setappdata(handles.window,'func','SelectByTime_1');
    
elseif strcmp(func,'SelectByTime_1') && ~cancel
    
    T = DADOS(:,get(handles.xlist,'Value'));
    
    t1 = str2time(get(handles.entry1,'String'));
    t2 = str2time(get(handles.entry2,'String'));
    
    if isnan(t2-t1)
        beep; uiwait(errordlg('Parâmetro de entrada incoerente.','Erro','modal')); drawnow;
        return
    end
    if t2-t1 < 0
        beep; uiwait(errordlg('Tempo final deve ser maior ou igual ao tempo inicial.','Erro','modal')); drawnow;
        return
    end
    
    sel2 = GetIntervPts(T,t1,t2);
    
    if isempty(sel2)
        beep; uiwait(errordlg('Não há pontos no intervalo indicado.','Erro','modal')); drawnow;
        return
    end

    if ~isempty(sel)
        button = questdlg({['Já há ' num2str(length(sel)) ' pontos selecionados.'],...
                'Deseja acrescentar ou substituir a nova seleção?'},...
            'Confirmação','Acrescentar','Substituir','Cancelar','Acrescentar'); drawnow;
        
        switch button
            case 'Acrescentar'
                % Nada a fazer
            case 'Substituir'
                sel = [];
            otherwise
                return
        end
    end
    
    sel = union(sel, sel2);
    
    ay = get(handles.graph,'YLim');
    d = diff(ay)/100;
    set(handles.auxline,'XData',[t1 t1 NaN t2 t2],'YData',[ay NaN ay]+[d -d NaN d -d],'Visible','on');
    pause(.2);
    set(handles.auxline,'Visible','off');
    
    setappdata(handles.window,'sel',sel);
    ClearEntryBox(hObject, eventdata, handles);
    set(handles.entriestxt(3:4),'HorizontalAlignment','right');
    NewEvent(handles,['Pontos selecionados: ' num2str(length(sel))]);
    UpdateSel(hObject, eventdata, handles);
    setappdata(handles.window,'func','none');
    
elseif cancel
    
    set(handles.entriestxt(3:4),'HorizontalAlignment','right');
    
end

% --------------------------------------------------------------------
function SelectNans_Callback(hObject, eventdata, handles)
global DADOS
% Seleciona pontos invalidos (NaN)

ycol = get(handles.ylist,'Value');
ypar = get(handles.ylabel,'String');
sel  = getappdata(handles.window,'sel');

Y = DADOS(:,ycol);
pts = find(isnan(Y));

if isempty(pts)
    uiwait(warndlg(['Nenhum ponto inválido encontrado no parâmetro ''' ypar '''.'],'Aviso','modal')); drawnow;
else
    if ~isempty(sel)
        button = questdlg({['Já há ' num2str(length(sel)) ' pontos selecionados.'],...
                'Deseja acrescentar ou substituir a seleção dos pontos inválidos?'},...
            'Confirmação','Acrescentar','Substituir','Cancelar','Acrescentar'); drawnow;
    else
        button = 'Substituir';
    end
    switch button
        case 'Acrescentar'
            sel = union(sel,pts);
        case 'Substituir'
            sel = pts;
        otherwise
            return
    end
    setappdata(handles.window,'sel',sel);
    NewEvent(handles,['Pontos selecionados: ' num2str(length(sel))]);
    UpdateSel(hObject, eventdata, handles);
end

% --------------------------------------------------------------------
function SelectRepPts_Callback(hObject, eventdata, handles)
global DADOS
% Seleciona pontos repetidos e NaNs

ycol = get(handles.ylist,'Value');
ypar = get(handles.ylabel,'String');
sel  = getappdata(handles.window,'sel');

Y = DADOS(:,ycol);
pts = find([~1; diff(Y)==0]);

if isempty(pts)
    uiwait(warndlg(['Nenhum ponto repetido encontrado no parâmetro ''' ypar '''.'],'Aviso','modal')); drawnow;
else
    if ~isempty(sel)
        button = questdlg({['Já há ' num2str(length(sel)) ' pontos selecionados.'],'O que deseja fazer?'},...
            'Confirmação','Acrescentar','Substituir','Cancelar','Acrescentar'); drawnow;
    else
        button = 'Substituir';
    end
    switch button
        case 'Acrescentar'
            sel = union(sel,pts);
        case 'Substituir'
            sel = pts;
        otherwise
            return
    end
    setappdata(handles.window,'sel',sel);
    NewEvent(handles,['Pontos selecionados: ' num2str(length(sel))]);
    UpdateSel(hObject, eventdata, handles);
end

% --------------------------------------------------------------------
function SelectTimeNoise_Callback(hObject, eventdata, handles)
global DADOS
% Seleciona ruido no tempo por analise de tolerancia a um ajuste linear

xcol   = get(handles.xlist,'Value');
ycol   = get(handles.ylist,'Value');
ypar   = get(handles.ylabel,'String');
func   = getappdata(handles.window,'func');
cancel = getappdata(handles.window,'cancel');
ok     = getappdata(handles.window,'ok');
sel    = getappdata(handles.window,'sel');

if strcmp(func,'none') && ~cancel
    
    timecols = getappdata(handles.window,'timecols');
    
    if ycol~=timecols
        button = questdlg({['O parâmetro ''' ypar ''' não aparenta ser de tempo.'],'Deseja prosseguir?'},...
            'Confirmação','Sim','Não','Não'); drawnow;
        if ~strcmp(button,'Sim')
            return
        end
    end
    
    if xcol < size(DADOS,2)
        set(handles.xlist,'Value',size(DADOS,2));
        xlist_Callback(hObject, eventdata, handles);
    end
    
    if ~isempty(sel)
        button = questdlg({['Já há ' num2str(length(sel)) ' pontos selecionados.'],'O que deseja fazer?'},...
            'Confirmação','Acrescentar','Substituir','Cancelar','Acrescentar'); drawnow;
    else
        button = 'Substituir';
    end
    switch button
        case 'Acrescentar'
            setappdata(handles.window,'tempdata',{sel,'add'});
        case 'Substituir'
            setappdata(handles.window,'tempdata',{sel,'rep'});
            setappdata(handles.window,'sel',[]);
            UpdatePlot(hObject, eventdata, handles);
        otherwise
            return
    end
    
    set(handles.entry1txt,'String','Iterações:');
    set(handles.entry2txt,'String','Tol.:');
    set(handles.entry3txt,'String','Em:');
    set(handles.entry1,'Style','edit','String',10);
    set(handles.entry2,'Style','edit','String',.02*diff(get(handles.graph,'YLim')));
    set(handles.entry3,'String',{'Tudo','Intervalo'},'Value',1);
    
    set([handles.entries(1:3) handles.entriestxt(1:3) handles.ok_btn handles.cancel_btn],'Visible','on');
    SetFrame(handles,1,'Seleção de spikes por análise de tolerância a um ajuste linear:');
    set([handles.menulist handles.xlist handles.ylist],'Enable','off');
    UpdateButtonStatus(hObject, eventdata, handles);
    
    setappdata(handles.window,'func','SelectTimeNoise_1');
    entry1_Callback(hObject, eventdata, handles);
    
elseif strcmp(func,'SelectTimeNoise_1') && ~cancel
    
    if ok
        
        ClearEntryBox(hObject, eventdata, handles);
        set(handles.auxplots(1,1:2),'XData',NaN,'YData',NaN);
        
        setappdata(handles.window,'func','none');
        setappdata(handles.window,'tempdata',[]);
        NewEvent(handles,['Pontos de ruído no tempo selecionados: ' num2str(length(sel))]);
        
    else
        set(handles.window,'Pointer','watch');
        
        iter = str2double(get(handles.entry1,'String'));
        tol = str2double(get(handles.entry2,'String'));
        in  = get(handles.entry3,'Value');
        
        switch in
            case 1 % Tudo
                pts = DADOS(:,end);
            case 2 % Intervalo
                pts = GetIntervPts(handles);
        end
        
        if isempty(pts)
            beep; uiwait(errordlg('Não há pontos no intervalo selecionado.','Erro','modal')); drawnow;
            sel = [];
            X = NaN;
            Yf = NaN;
        else
            
            Y = denan(DADOS(pts,ycol));
            X = DADOS(pts,xcol);
            
            if isnan(iter) || isnan(tol)
                beep; uiwait(errordlg('Parâmetro de entrada incoerente.','Erro','modal')); drawnow;
                sel = [];
                X = NaN;
                Yf = NaN;
            else
                
                if iter < 1
                    beep; uiwait(errordlg('Número de iterações deve ser maior que 0.','Erro','modal')); drawnow;
                    sel = [];
                    X = NaN;
                    Yf = NaN;
                else
                    
                    sel = [];
                    lastwarn('');
                    for n = 1:iter
                        okpts = setdiff(pts,sel) - pts(1)+1;
                        cfs = polyfit(X(okpts),Y(okpts),1);
                        if ~isempty(lastwarn)
                            uiwait(warndlg(lastwarn,'Aviso','modal')); drawnow;
                            sel = [];
                            X = NaN;
                            Yf = NaN;
                            break
                        end
                        Yf = polyval(cfs,X);
                        sel = find(abs(Y-Yf) > tol) + pts(1)-1;
                    end
                end
            end
        end
        
        tempdata = getappdata(handles.window,'tempdata');
        oldsel = tempdata{1};
        opt = tempdata{2};
        if strcmp(opt,'add');
            sel = union(sel,oldsel);
        end
        
        setappdata(handles.window,'sel',sel);
        UpdateSel(hObject, eventdata, handles);
        
        set(handles.auxplots(1,1),'XData',X,'YData',Yf);
        set(handles.auxplots(1,2),'XData',[X; NaN; X],'YData',[Yf-tol; NaN; Yf+tol]);
    end
    
elseif cancel
    
    set(handles.auxplots(1,1:2),'XData',NaN,'YData',NaN);
    tempdata = getappdata(handles.window,'tempdata');
    oldsel = tempdata{1};
    setappdata(handles.window,'sel',oldsel);
    UpdateSel(hObject, eventdata, handles);
    
end

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function SelectInvalidTime_Callback(hObject, eventdata, handles)
global DADOS
% Seleciona pontos invalidos num parâmetro de tempo
% Criterio: Pontos invalidos (NaN) e não crescentes

ycol     = get(handles.ylist,'Value');
ypar     = get(handles.ylabel,'String');
sel      = getappdata(handles.window,'sel');
timecols = getappdata(handles.window,'timecols');

if ycol~=timecols
    button = questdlg({['O parâmetro ''' ypar ''' não aparenta ser de tempo.'],'Deseja prosseguir?'},...
        'Confirmação','Sim','Não','Não'); drawnow;
    if ~strcmp(button,'Sim')
        return
    end
end

Y = DADOS(:,ycol);
[ok, ndc, nna] = IsTimeOk(Y);
pts = union(ndc,nna);

if ok
    uiwait(warndlg(['Nenhum ponto inadequado de tempo encontrado no parâmetro ''' ypar '''.'],'Aviso','modal')); drawnow;
else
    if ~isempty(sel)
        button = questdlg({['Já há ' num2str(length(sel)) ' pontos selecionados.'],'O que deseja fazer?'},...
            'Confirmação','Acrescentar','Substituir','Cancelar','Acrescentar'); drawnow;
    else
        button = 'Substituir';
    end
    switch button
        case 'Acrescentar'
            sel = union(sel,pts);
        case 'Substituir'
            sel = pts;
        otherwise
            return
    end
    setappdata(handles.window,'sel',sel);
    NewEvent(handles,['Pontos selecionados: ' num2str(length(sel))]);
    UpdateSel(hObject, eventdata, handles);
end

% --------------------------------------------------------------------
function SelectInvalidTop_Callback(hObject, eventdata, handles)
global DADOS
% Seleciona pontos invalidos num parâmetro de TOP
% Criterio: Pontos invalidos (NaN), decrescentes, negativos e não-inteiros

ycol = get(handles.ylist,'Value');
ypar = get(handles.ylabel,'String');
sel  = getappdata(handles.window,'sel');

TOP = DADOS(:,ycol);

nni = find(denan(TOP)-fix(denan(TOP))~=0);
nna = find(isnan(TOP));
nng = find(TOP<0);
ndc = find(diff(TOP)<0)+1;

pts = union(union(nni,nna),union(nng,ndc));

if isempty(pts)
    uiwait(warndlg(['Nenhum ponto inadequado de TOP encontrado no parâmetro ''' ypar '''.'],'Aviso','modal')); drawnow;
else
    if ~isempty(sel)
        button = questdlg({['Já há ' num2str(length(sel)) ' pontos selecionados.'],'O que deseja fazer?'},...
            'Confirmação','Acrescentar','Substituir','Cancelar','Acrescentar'); drawnow;
    else
        button = 'Substituir';
    end
    switch button
        case 'Acrescentar'
            sel = union(sel,pts);
        case 'Substituir'
            sel = pts;
        otherwise
            return
    end
    setappdata(handles.window,'sel',sel);
    NewEvent(handles,['Pontos selecionados: ' num2str(length(sel))]);
    UpdateSel(hObject, eventdata, handles);
end

% --------------------------------------------------------------------
function SelectSpikes_Callback(hObject, eventdata, handles)
global DADOS
% Seleção de spikes por media movel

xcol   = get(handles.xlist,'Value');
ycol   = get(handles.ylist,'Value');
func   = getappdata(handles.window,'func');
cancel = getappdata(handles.window,'cancel');
ok     = getappdata(handles.window,'ok');
sel    = getappdata(handles.window,'sel');

if strcmp(func,'none') && ~cancel
    
    X = DADOS(:,xcol);
    if ~IsTimeOk(X);
        beep; errordlg({'O parâmetro x deve ser monotônico crescente e sem pontos inválidos.',...
                'Use ''No. OBS.'' ou um parâmetro de tempo adequado.'},'Erro','modal'); drawnow;
        return
    end
    
    if ~isempty(sel)
        button = questdlg({['Já há ' num2str(length(sel)) ' pontos selecionados.'],'O que deseja fazer?'},...
            'Confirmação','Acrescentar','Substituir','Cancelar','Acrescentar'); drawnow;
    else
        button = 'Substituir';
    end
    switch button
        case 'Acrescentar'
            setappdata(handles.window,'tempdata',{sel,'add'});
        case 'Substituir'
            setappdata(handles.window,'tempdata',{sel,'rep'});
            setappdata(handles.window,'sel',[]);
            UpdatePlot(hObject, eventdata, handles);
        otherwise
            return
    end
    
    set(handles.entry1txt,'String','Ordem:');
    set(handles.entry2txt,'String','Tol.:');
    set(handles.entry3txt,'String','Em:');
    set(handles.entry1,'Style','edit','String',10);
    set(handles.entry2,'Style','edit','String',.05*diff(get(handles.graph,'YLim')));
    set(handles.entry3,'String',{'Tudo','Intervalo'},'Value',1);
    
    set([handles.entries(1:3) handles.entriestxt(1:3) handles.ok_btn handles.cancel_btn],'Visible','on');
    SetFrame(handles,1,'Seleção de spikes por filtro de média móvel:');
    set([handles.menulist handles.xlist handles.ylist],'Enable','off');
    UpdateButtonStatus(hObject, eventdata, handles);
    
    setappdata(handles.window,'func','SelectSpikes_1');
    entry1_Callback(hObject, eventdata, handles);
    
elseif strcmp(func,'SelectSpikes_1') && ~cancel
    
    if ok
        
        ClearEntryBox(hObject, eventdata, handles);
        set(handles.auxplots(1,1:2),'XData',NaN,'YData',NaN);
        
        setappdata(handles.window,'func','none');
        setappdata(handles.window,'tempdata',[]);
        NewEvent(handles,['Spikes selecionados: ' num2str(length(sel))]);
        
    else
        set(handles.window,'Pointer','watch');
        
        ord = str2double(get(handles.entry1,'String'));
        tol = str2double(get(handles.entry2,'String'));
        in  = get(handles.entry3,'Value');
        
        switch in
            case 1 % Tudo
                pts = DADOS(:,end);
            case 2 % Intervalo
                pts = GetIntervPts(handles);
        end
        Y = DADOS(pts,ycol);
        X = DADOS(pts,xcol);
        
        if isnan(ord) || isnan(tol)
            beep; uiwait(errordlg('Parâmetro de entrada incoerente.','Erro','modal')); drawnow;
            sel = [];
            X = NaN;
            Yf = NaN;
        else 
            
            if ord <=1
                beep; uiwait(errordlg('Ordem deve ser maior que 1.','Erro','modal')); drawnow;
                sel = [];
                X = NaN;
                Yf = NaN;
            elseif ord > length(pts)/3
                beep; uiwait(errordlg('Ordem deve ser menor ou igual a um terço do número de observações.','Erro','modal')); drawnow;
                sel = [];
                X = NaN;
                Yf = NaN;
            else
                
                try
                    A = 1;
                    B = 1/ord * ones(1,ord);
                    
                    Ya = denan(Y);
                    Yf = filtfilt(B,A,Ya);
                    sel = find(abs(Ya-Yf) > tol) + pts(1)-1;
                    sel(isnan(DADOS(sel,ycol))) = [];
                catch
                    beep; uiwait(errordlg({'Erro na implementação do filtro:',lasterr},'Erro','modal')); drawnow;
                    sel = [];
                    X = NaN;
                    Yf = NaN;
                end
            end
        end
        
        tempdata = getappdata(handles.window,'tempdata');
        oldsel = tempdata{1};
        opt = tempdata{2};
        if strcmp(opt,'add');
            sel = union(sel,oldsel);
        end
        
        setappdata(handles.window,'sel',sel);
        UpdateSel(hObject, eventdata, handles);
        
        set(handles.auxplots(1,1),'XData',X,'YData',Yf);
        set(handles.auxplots(1,2),'XData',[X; NaN; X],'YData',[Yf-tol; NaN; Yf+tol]);
    end
    
elseif cancel
    
    set(handles.auxplots(1,1:2),'XData',NaN,'YData',NaN);
    tempdata = getappdata(handles.window,'tempdata');
    oldsel = tempdata{1};
    setappdata(handles.window,'sel',oldsel);
    UpdateSel(hObject, eventdata, handles);
    
end

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function DeselectByBox_Callback(hObject, eventdata, handles)
global DADOS
% Desseleciona pontos por caixa de seleção

xcol = get(handles.xlist,'Value');
ycol = get(handles.ylist,'Value');
sel  = getappdata(handles.window,'sel');
setappdata(handles.window,'clickfunc','none');

set(handles.title,'String','Desselecione pontos')

set(handles.window,'CloseRequestFcn',[]);
set(handles.menulist,'Enable','off');
UpdateButtonStatus(hObject, eventdata, handles);

waitforbuttonpress;
p1 = get(handles.graph,'CurrentPoint');
setappdata(handles.window,'rbbox',1);
rbbox;
setappdata(handles.window,'rbbox',0);
p2 = get(handles.graph,'CurrentPoint');

set(handles.menulist,'Enable','on');
UpdateButtonStatus(hObject, eventdata, handles);
set(handles.window,'CloseRequestFcn','R_DAT(''Window_CloseRequestFcn'',gcf,[],guidata(gcf))');

p1 = p1(1,1:2);
p2 = p2(1,1:2);

xbox = sort([p1(1), p2(1)]);
ybox = sort([p1(2), p2(2)]);

X = denan(DADOS(:,xcol));
Y = denan(DADOS(:,ycol));

sel = setdiff(sel, intersect(...
    intersect(find(X >= xbox(1)), find(X <= xbox(2))), ...
    intersect(find(Y >= ybox(1)), find(Y <= ybox(2))) ));

set(handles.title,'String','')
setappdata(handles.window,'sel',sel);
setappdata(handles.window,'clickfunc','zoom');
NewEvent(handles,['Pontos selecionados: ' num2str(length(sel))]);
UpdateSel(hObject, eventdata, handles);

% --------------------------------------------------------------------
function DeselectAll_Callback(hObject, eventdata, handles, confirm)
% Desseleciona todos os pontos

if nargin == 3;
    confirm = 1;
end
sel = getappdata(handles.window,'sel');

if ~isempty(sel)
    if confirm
        if length(sel) == 1
            button = questdlg({'1 ponto selecionado.','Deseja desselecionar o ponto?'},'Confirmação','Sim','Não','Não'); drawnow;
        else
            button = questdlg({[num2str(length(sel)),' pontos selecionados.'],'Deseja desselecionar todos os pontos?'},...
                'Confirmação','Sim','Não','Não'); drawnow;
        end
    else
        button = 'Sim';
    end
    if strcmp(button,'Sim')
        setappdata(handles.window,'sel',[]);
        NewEvent(handles,'Pontos selecionados: 0');
        UpdateSel(hObject, eventdata, handles);
    end
end

% --------------------------------------------------------------------
function InvertSelection_Callback(hObject, eventdata, handles)
global DADOS
% Inverte a seleção de pontos

button = questdlg('Deseja inverter a seleção de pontos?','Confirmação','Sim','Não','Não'); drawnow;
if strcmp(button,'Sim')
    sel = getappdata(handles.window,'sel');
    pts = DADOS(:,end);
    sel = setdiff(pts,sel);
    setappdata(handles.window,'sel',sel);
    NewEvent(handles,['Pontos selecionados: ' num2str(length(sel))]);
    UpdateSel(hObject, eventdata, handles);
end

% --------------------------------------------------------------------
function MultiPlot5_Callback(hObject, eventdata, handles)
% Função que habilita múltiplos plotes (até 5)

PARAM  = get(handles.xlist,'String');
func   = getappdata(handles.window,'func');
cancel = getappdata(handles.window,'cancel');
part   = getappdata(handles.window,'part');
parlist = getappdata(handles.window,'mp5_list');

if ~isempty(part) && strcmp(func,'MultiGraph5_1')
    cancel_btn_Callback(hObject, eventdata, handles);
    MultiPlot5_Callback(hObject, eventdata, handles);
end

if strcmp(func,'none') && ~cancel
    
    set(handles.entry1txt,'String','--------','ForegroundColor',get(handles.plots(1,2),'Color'));
    set(handles.entry2txt,'String','--------','ForegroundColor',get(handles.plots(1,3),'Color'));
    set(handles.entry3txt,'String','--------','ForegroundColor',get(handles.plots(1,4),'Color'));
    set(handles.entry4txt,'String','--------','ForegroundColor',get(handles.plots(1,5),'Color'));
    set(handles.entries,'String',[{' '};PARAM],'Value',1);
    
    set([handles.entries handles.entriestxt handles.cancel_btn],'Visible','on');
    SetFrame(handles,2,'Parâmetros para plotes múltiplos:');
    set(handles.menulist,'Enable','off');
    if isempty(part)
        UpdateButtonStatus(hObject, eventdata, handles);
        SetButtonStatus(handles,[handles.printlist handles.Setpt_btn handles.Setpt2_btn handles.DeSel_btn handles.Delete_btn handles.Playback_btn handles.Selection_btn],1);
    end
    
    setappdata(handles.window,'showsync',1);
    setappdata(handles.window,'func','MultiPlot5_1');
    
    if strcmp(get(handles.RememberMultiPar,'Checked'),'on')
        for n = 1:4
            npar = findpar(PARAM,parlist{n},0,1);
            if npar
                set(handles.entries(n),'Value',npar+1);
            end
        end
        entry1_Callback(hObject, eventdata, handles);
        entry2_Callback(hObject, eventdata, handles);
        entry3_Callback(hObject, eventdata, handles);
        entry4_Callback(hObject, eventdata, handles);
    end
    
elseif cancel
    
    if strcmp(get(handles.RememberMultiPar,'Checked'),'on')
        for n = 1:4
            npar = get(handles.entries(n),'Value')-1;
            if npar
                parlist{n} = denumber(PARAM{npar});
            else
                parlist{n} = '';
            end
        end
        setappdata(handles.window,'mp5_list',parlist);
    end
    
    set(handles.plots(1,2:5),'XData',NaN,'YData',NaN);
    set(handles.entriestxt,'ForegroundColor',get(handles.frametxt,'ForegroundColor'));
    setappdata(handles.window,'showsync',0);
    set(handles.SelectPoints,'Checked','off');
    set(handles.title,'String','');
    UpdateDataTips(hObject, eventdata, handles);
    
end

% --------------------------------------------------------------------
function MultiPlot16_Callback(hObject, eventdata, handles)
%  Função que habilita múltiplos plotes (até 16)

toggleenable  = [handles.menulist handles.xlist handles.ylist handles.OptionsMenu];
togglevisible = [handles.plot handles.selpts handles.inipts handles.endpts handles.testptlbl,...
        handles.eventpts handles.eventlbl handles.datatips(:)'];

set(handles.ylabel,'String','');
set(toggleenable,'Enable','off');
set(togglevisible,'Visible','off');
UpdateButtonStatus(hObject, eventdata, handles);
SetButtonStatus(handles,handles.printlist,1);

colors = [0 0 1; 1 0 0; 0 .8 0; 1 0 1; 0 .8 .8; .8 .8 0; 0 .6 0; 1 .5 0];
axes(handles.graph);
for n = 1:8
    hmultiplots(n)   = plot(NaN,NaN,'-', 'Color',colors(n,:));
    hmultiplots(n+8) = plot(NaN,NaN,'--','Color',colors(n,:));
end

setappdata(handles.window,'showsync',1);
setappdata(handles.window,'func','MultiPlot16_1');
set(handles.window,'CloseRequestFcn',[]);

set([handles.Ruler_btn handles.DataTips_btn handles.TestPoints_btn handles.Events_btn],'Enable','inactive');

ss = get(0,'ScreenSize');
ws = get(handles.window,'Position');
set(handles.window,'Position',[.5*handles.screenborders(1)+226 .5*handles.screenborders(2)-5,...
        ss(3)-handles.screenborders(1)-224 ss(4)-handles.screenborders(2)]);

waitfor( RDAT_MultiPlot(hmultiplots, handles) ); drawnow;

set(handles.window,'Position',ws);

set(handles.window,'CloseRequestFcn','R_DAT(''Window_CloseRequestFcn'',gcf,[],guidata(gcf))');
setappdata(handles.window,'showsync',0);
setappdata(handles.window,'func','none');
delete(hmultiplots);
set(toggleenable,'Enable','on');
set(togglevisible,'Visible','on');
UpdateButtonStatus(hObject, eventdata, handles);

PARAM = get(handles.xlist,'String');
lastxpar = findpar(PARAM,get(handles.xlabel,'String'));
UpdatePlot(hObject, eventdata, handles);
if lastxpar ~= get(handles.xlist,'Value')
    set(handles.graphs,'XLim',AutoLim(handles.plot));
end

% --------------------------------------------------------------------
function MultiPlot3_Callback(hObject, eventdata, handles)
% Função que habilita multiplos plotes (até 3) com X diferentes

func    = getappdata(handles.window,'func');
cancel  = getappdata(handles.window,'cancel');
PARAM   = get(handles.xlist,'String');
parlist = getappdata(handles.window,'mp3_list');

if strcmp(func,'none') && ~cancel
    
    set(handles.entry1txt,'String','y2');
    set(handles.entry2txt,'String','x2');
    set(handles.entry3txt,'String','y3');
    set(handles.entry4txt,'String','x3');
    set(handles.entries,'String',[{' '};PARAM],'Value',1);
    
    set([handles.entries handles.entriestxt handles.cancel_btn],'Visible','on');
    SetFrame(handles,2,'Parâmetros para plotes múltiplos:');
    set(handles.menulist,'Enable','off');
    UpdateButtonStatus(hObject, eventdata, handles);
    SetButtonStatus(handles,[handles.printlist handles.Setpt_btn handles.Setpt2_btn handles.DeSel_btn handles.Delete_btn handles.Playback_btn handles.Selection_btn],1);
    
    setappdata(handles.window,'func','MultiPlot3_1');
    
    if strcmp(get(handles.RememberMultiPar,'Checked'),'on')
        for n = 1:4
            npar = findpar(PARAM,parlist{n},0,1);
            if npar
                set(handles.entries(n),'Value',npar+1);
            end
        end
        entry1_Callback(hObject, eventdata, handles);
        entry2_Callback(hObject, eventdata, handles);
        entry3_Callback(hObject, eventdata, handles);
        entry4_Callback(hObject, eventdata, handles);
    end

elseif cancel
    
    if strcmp(get(handles.RememberMultiPar,'Checked'),'on')
        for n = 1:4
            npar = get(handles.entries(n),'Value')-1;
            if npar
                parlist{n} = denumber(PARAM{npar});
            else
                parlist{n} = '';
            end
        end
        setappdata(handles.window,'mp3_list',parlist);
    end

    set(handles.plots(1,2:3),'XData',NaN,'YData',NaN);
    set(handles.SelectPoints,'Checked','off');
    set(handles.title,'String','');
    UpdateDataTips(hObject, eventdata, handles);    
    
end

% --------------------------------------------------------------------
function MultiGraph5_Callback(hObject, eventdata, handles)
% Função que habilita múltiplos gráficos (até 5)

PARAM  = get(handles.xlist,'String');
func   = getappdata(handles.window,'func');
cancel = getappdata(handles.window,'cancel');
part   = getappdata(handles.window,'part');
parlist = getappdata(handles.window,'mg5_list');

if ~isempty(part) && strcmp(func,'MultiPlot5_1')
    cancel_btn_Callback(hObject, eventdata, handles);
    MultiGraph5_Callback(hObject, eventdata, handles);
end

if strcmp(func,'none') && ~cancel
    
    set([handles.entry1txt handles.ylabels(2)],'String','y2');
    set([handles.entry2txt handles.ylabels(3)],'String','y3');
    set([handles.entry3txt handles.ylabels(4)],'String','y4');
    set([handles.entry4txt handles.ylabels(5)],'String','y5');
    set(handles.entries,'String',[{' '};PARAM],'Value',1);
    set(handles.graphs,'XLim',get(handles.graph,'XLim'));
    
    set([handles.entries handles.entriestxt handles.cancel_btn],'Visible','on');
    SetFrame(handles,2,'Parâmetros para gráficos múltiplos:');
    set(handles.menulist,'Enable','off');
    if isempty(part)
        UpdateButtonStatus(hObject, eventdata, handles);
        SetButtonStatus(handles,[handles.printlist handles.Setpt_btn handles.Setpt2_btn handles.DeSel_btn handles.Delete_btn handles.Playback_btn handles.Selection_btn],1);
    else
        set(handles.PartialData_btn,'Enable','inactive');
    end
    
    setappdata(handles.window,'showsync',1);
    setappdata(handles.window,'func','MultiGraph5_1');
    
    if strcmp(get(handles.RememberMultiPar,'Checked'),'on')
        for n = 1:4
            npar = findpar(PARAM,parlist{n},0,1);
            if npar
                set(handles.entries(n),'Value',npar+1);
            end
        end
        entry1_Callback(hObject, eventdata, handles);
        entry2_Callback(hObject, eventdata, handles);
        entry3_Callback(hObject, eventdata, handles);
        entry4_Callback(hObject, eventdata, handles);
    end

elseif cancel
    
    if strcmp(get(handles.RememberMultiPar,'Checked'),'on')
        for n = 1:4
            npar = get(handles.entries(n),'Value')-1;
            if npar
                parlist{n} = denumber(PARAM{npar});
            else
                parlist{n} = '';
            end
        end
        setappdata(handles.window,'mg5_list',parlist);
    end
    
    setappdata(handles.window,'showsync',0);
    MultiParamOperation_setgraph(hObject, eventdata, handles, 0, 0);
    set(handles.SelectPoints,'Checked','off');
    set(handles.title,'String','');
    UpdateDataTips(hObject, eventdata, handles);
    set(handles.PartialData_btn,'Enable','on');
    
end

% --------------------------------------------------------------------
function MultiGraph3x5_Callback(hObject, eventdata, handles)
% Função que habilita gráficos múltiplos com plotes múltiplos (até 3x5)

toggleenable  = [handles.menulist handles.xlist handles.ylist handles.OptionsMenu];
togglevisible = [handles.plot handles.selpts handles.inipts handles.endpts handles.testptlbl,...
        handles.eventpts handles.eventlbl handles.datatips(:)'];

for n = 1:5
    set(handles.ylabels(n),'String',num2str(n));
end

set(toggleenable,'Enable','off');
set(togglevisible,'Visible','off');
UpdateButtonStatus(hObject, eventdata, handles);
SetButtonStatus(handles,handles.printlist,1);

colors = [0 0 1; 1 0 0; 0 .8 0];
for n = 1:5
    axes(handles.graphs(n));
    for m = 1:3
        hmultiplots(3*n-3+m) = plot(NaN,NaN,'-', 'Color',colors(m,:));
    end
end

setappdata(handles.window,'showsync',1);
setappdata(handles.window,'func','MultiGraph3x5_1');
set(handles.window,'CloseRequestFcn',[]);

btnlines = getappdata(handles.window,'btnlines');

set([handles.Ruler_btn handles.DataTips_btn handles.TestPoints_btn handles.Events_btn],'Enable','inactive');

ss = get(0,'ScreenSize');
ws = get(handles.window,'Position');
set(handles.window,'Position',[.5*handles.screenborders(1)+216 .5*handles.screenborders(2)-5,...
        ss(3)-handles.screenborders(1)-214 ss(4)-handles.screenborders(2)]);

waitfor( RDAT_MultiGraph(hmultiplots, handles, handles.borders+[btnlines*handles.toolbarheight 0 0 0]) ); drawnow;

set(handles.window,'Position',ws);

set(handles.window,'CloseRequestFcn','R_DAT(''Window_CloseRequestFcn'',gcf,[],guidata(gcf))');
MultiParamOperation_setgraph(hObject, eventdata, handles, 0, 0);
setappdata(handles.window,'showsync',0);
setappdata(handles.window,'func','none');
delete(hmultiplots);
set(toggleenable,'Enable','on');
set(togglevisible,'Visible','on');
UpdateButtonStatus(hObject, eventdata, handles);

PARAM = get(handles.xlist,'String');
lastxpar = findpar(PARAM,get(handles.xlabel,'String'));
UpdatePlot(hObject, eventdata, handles);
if lastxpar ~= get(handles.xlist,'Value')
    set(handles.graphs,'XLim',AutoLim(handles.plot));
end

% --------------------------------------------------------------------
function MultiGraph_update(hObject, eventdata, handles)
% Função que atualiza a distribuição de gráficos múltiplos na tela
% de acordo com as seleções das entradas 1 a 4

func = getappdata(handles.window,'func');
btnlines = getappdata(handles.window,'btnlines');
ws = get(handles.window,'Position');

b = 22; % Borda entre gráficos
bu = handles.borders(1)+btnlines*handles.toolbarheight;  % Up
bd = handles.borders(2);  % Down
bl = handles.borders(3);  % Left
br = handles.borders(4);  % Right
Ax = ws(3)-bl-br; % Largura dos gráficos
Ay = ws(4)-bu-bd; % Altura disponivel dos gráficos

for n = 1:4
    ycol(n) = get(handles.entries(n),'Value')-1;
end

ngraph = max(find(ycol)) + 1;
if isempty(ngraph); ngraph = 1; end

set(handles.graphs(ngraph),'XTickLabelMode','auto');
set(handles.graphs(setdiff(1:5,ngraph)),'XTickLabel',[]);

if ngraph<5; set(handles.graphs(ngraph+1:5),'Visible','off'); end

ay = (Ay-(ngraph-1)*b)/ngraph;
set(handles.title,'Position',[.5*Ax ay+4 0]);

for n = 1:ngraph
    py = bd+(ngraph-n)*(ay+b);
    
    set(handles.graphs(n),'Position',[bl py Ax ay],'Visible','on');
    set(handles.ylabels(n),'Position',[-50, ay/2, 0]);
end

% --------------------------------------------------------------------
function MultiParamOperation_setgraph(hObject, eventdata, handles, ngraph, opt)
% Função que ajusta n gráficos na tela para operação entre parâmetros
% ngraph: Numero de gráficos desejados
% opt:    Auto executar callbacks dos data entries (default = 1)

if nargin < 5
    opt = 1;
end

ws = get(handles.window,'Position');
btnlines = getappdata(handles.window,'btnlines');
bu = handles.borders(1)+btnlines*handles.toolbarheight;  % Up
bd = handles.borders(2);  % Down
bl = handles.borders(3);  % Left
br = handles.borders(4);  % Right

if ngraph >= 1 % Habilitar
    
    b = 22; % Borda entre gráficos
    Ax = ws(3)-bl-br; % Largura dos gráficos
    Ay = ws(4)-bu-bd; % Altura disponivel dos gráficos
    
    ay = (Ay-(ngraph-1)*b)/ngraph;
    set(handles.title,'Position',[.5*Ax ay+4 0]);
    
    for n = 1:ngraph
        py = bd+(ngraph-n)*(ay+b);
        
        set(handles.graphs(n),'Position',[bl py Ax ay],'Visible','on');
        set(handles.ylabels(n),'Position',[-50, ay/2, 0])
    end
    
    setappdata(handles.window,'showsync',1);
    set(handles.graphs(ngraph),'XTickLabelMode','auto');
    set(handles.graphs(1:ngraph-1),'XTickLabel',[]);
    
    set(handles.graphs,'XLim',get(handles.graph,'XLim'));
    set(handles.graphs(ngraph+1:5),'Visible','off');
    set(handles.plots(2,ngraph+1:5),'XData',NaN,'YData',NaN);
    
    if opt
        if ngraph >= 1; entry1_Callback(hObject, eventdata, handles); end
        if ngraph >= 2; entry2_Callback(hObject, eventdata, handles); end
        if ngraph >= 3; entry3_Callback(hObject, eventdata, handles); end
        if ngraph >= 4; entry4_Callback(hObject, eventdata, handles); end
    end
    
else % Desabilitar
    setappdata(handles.window,'showsync',0);
    set(handles.sync_line,'Visible','off');
    set(handles.graph,'Position',[bl bd ws(3)-bl-br ws(4)-bd-bu],'XTickLabelMode','auto');
    set(handles.title,'Position',[.5*(ws(3)-bl-br) ws(4)-bu-bd+4 0]);    
    set(handles.ylabel,'Position',[-50 .5*(ws(4)-bu-bd) 0]);
    set(handles.graphs(2:5),'Visible','off','XTickLabel',[]);
    set(handles.plots(2,2:5),'XData',NaN,'YData',NaN);
    if opt
        ylist_Callback(hObject, eventdata, handles);
    end
end


% ####################################################################
%                   FUNÇÕES DO MENU FERRAMENTAS
% ####################################################################

function ParamSelect_Callback(hObject, eventdata, handles)
global DADOS
% Redefine lista de parâmetros

PARAM    = get(handles.xlist,'String');
reftime  = getappdata(handles.window,'reftime');
nreftime = findpar(PARAM,reftime,0,1);

togglelist = setdiff(findobj(handles.window,'Enable','on'),findobj(handles.window,'Style','text'));
set(togglelist,'Enable','off');
UpdateButtonStatus(hObject, eventdata, handles);

index = RDAT_ParamSel(PARAM(1:end-1)); drawnow; % Omissao de No. OBS.

set(togglelist,'Enable','on');
UpdateButtonStatus(hObject, eventdata, handles);

if ~isempty(index)
    
    if ~isempty(nreftime) && ~any(nreftime==index) % reftime foi excluido
        beep; uiwait(errordlg({['O parâmetro ''' reftime ''' não pode ser excluído'],...
                'pois está definido como tempo de referência.'},'Erro','modal')); drawnow;
        if nreftime > length(index)
            index = [index; nreftime];
        else
            index = [index(1:nreftime-1); nreftime; index(nreftime:end)];
        end
    end
    
    index = [index; length(PARAM)];    % Reinclusao de No. OBS.
    PARAM = SetParamNumbers(PARAM(index));
    DADOS = DADOS(:,index);
    UpdateGraph(hObject, eventdata, handles, size(DADOS,2), 1, PARAM);
    set(handles.graphs,'XLim',AutoLim(handles.plot));
    
    setappdata(handles.window,'change',1);
    NewEvent(handles,'Lista de parâmetros alterada.');
    
end

% --------------------------------------------------------------------
function EditParam_Callback(hObject, eventdata, handles)
% Editor da lista de parâmetros

oldPARAM = get(handles.xlist,'String');
reftime  = getappdata(handles.window,'reftime');

PARAM = RDAT_EditParam(oldPARAM(1:end-1),handles.maxparamlength);

if isempty(PARAM)
    return
end

PARAM{end+1} = [num2str(length(PARAM)+1,'%02d') '-No. OBS.'];
CheckRepParam(PARAM);

set([handles.xlist handles.ylist],'String',PARAM);

xcol = get(handles.xlist,'Value');
ycol = get(handles.ylist,'Value');

set(handles.xlabel,'String',denumber(PARAM{xcol}));
set(handles.ylabel,'String',denumber(PARAM{ycol}));

if ~isempty(reftime)
    nreftime = findpar(oldPARAM,reftime,0,1);
    if ~isempty(nreftime)
        setappdata(handles.window,'reftime',denumber(PARAM{nreftime}));
    end
end
UpdateTimeCols(hObject, eventdata, handles);

setappdata(handles.window,'change',1);
NewEvent(handles,'Lista de nomes de parâmetros alterada.');

% --------------------------------------------------------------------
function UnitsInsert_Callback(hObject, eventdata, handles)
% Insersor de unidades na lista de parâmetros

oldPARAM = get(handles.xlist,'String');
reftime  = getappdata(handles.window,'reftime');

PARAM = RDAT_InsertUnits(oldPARAM(1:end-1),handles.maxparamlength);

if isempty(PARAM)
    return
end

PARAM{end+1} = [num2str(length(PARAM)+1,'%02d') '-No. OBS.'];

set([handles.xlist handles.ylist],'String',PARAM);

xcol = get(handles.xlist,'Value');
ycol = get(handles.ylist,'Value');

set(handles.xlabel,'String',denumber(PARAM{xcol}));
set(handles.ylabel,'String',denumber(PARAM{ycol}));

if ~isempty(reftime)
    nreftime = findpar(oldPARAM,reftime,0,1);
    if ~isempty(nreftime)
        setappdata(handles.window,'reftime',denumber(PARAM{nreftime}));
    end
end
UpdateTimeCols(hObject, eventdata, handles);

setappdata(handles.window,'change',1);
NewEvent(handles,'Unidades inseridas na lista de parâmetros.');

% --------------------------------------------------------------------
function UnitsNameSet_Callback(hObject, eventdata, handles)
% Padronização dos nomes das unidades

PARAM = get(handles.xlist,'String');

reftime  = getappdata(handles.window,'reftime');
nreftime = findpar(PARAM,reftime,0,1);

togglelist = setdiff(findobj(handles.window,'Enable','on'),findobj(handles.window,'Style','text'));
set(togglelist,'Enable','off');
UpdateButtonStatus(hObject, eventdata, handles);

PARAM = RDAT_SetUnits(PARAM); drawnow;

set(togglelist,'Enable','on');
UpdateButtonStatus(hObject, eventdata, handles);

if ~isempty(PARAM)
    set([handles.xlist handles.ylist],'String',PARAM);
    
    xcol = get(handles.xlist,'Value');
    ycol = get(handles.ylist,'Value');
    set(handles.xlabel,'String',denumber(PARAM{xcol}));
    set(handles.ylabel,'String',denumber(PARAM{ycol}));
    
    if ~isempty(nreftime)
        newreftime = denumber(PARAM{nreftime});
        if ~strcmp(reftime,newreftime);
            reftime = newreftime;
            setappdata(handles.window,'reftime',reftime);
        end
    end
    testpts = getappdata(handles.window,'testpts');
    if ~isempty(testpts) && isfield(testpts,'param')
        for ngrp = 1:size(testpts,2)
            for npar = 1:length(testpts(ngrp).param)
                if isempty(findpar(PARAM,testpts(ngrp).param{npar})) && ~isempty(findpar(PARAM,SetUnits(testpts(ngrp).param{npar})))
                    testpts(ngrp).param{npar} = SetUnits(testpts(ngrp).param{npar});
                end
            end
        end
        setappdata(handles.window,'testpts',testpts);
    end
    
    UpdateTimeCols(hObject, eventdata, handles);
    
    setappdata(handles.window,'change',1);
    NewEvent(handles,'Unidades dos parâmetros padronizadas.');
end

% --------------------------------------------------------------------
function ViewDataTable_Callback(hObject, eventdata, handles)
% Visualizador de dados em formato de tabela

PARAM  = get(handles.xlist,'String');
oldsel = getappdata(handles.window,'sel');
xcol   = get(handles.xlist,'Value');
ycol   = get(handles.ylist,'Value');

pts = GetIntervPts(handles);
if isempty(pts)
    pts = 1;
end

togglelist = setdiff(findobj(handles.window,'Enable','on'),findobj(handles.window,'Style','text'));
set(togglelist,'Enable','off');
UpdateButtonStatus(hObject, eventdata, handles);

[ok, sel] = RDAT_DataTable(PARAM,oldsel,[xcol ycol pts(1)]); drawnow;

set(togglelist,'Enable','on');
UpdateButtonStatus(hObject, eventdata, handles);

if ok
    setappdata(handles.window,'change',1);
    NewEvent(handles,'Pontos alterados na tabela de visualização de dados.');
    if ~isequal(oldsel,sel)
        setappdata(handles.window,'sel',sel);
        NewEvent(handles,['Pontos selecionados: ' num2str(length(sel))]);
    end
    UpdatePlot(hObject, eventdata, handles, ycol, xcol);
end

% --------------------------------------------------------------------
function TableParam_Callback(hObject, eventdata, handles)
global DADOS
% Cria parametro a partir de tabela

PARAM  = get(handles.xlist,'String');
xcol   = get(handles.xlist,'Value');
xpar   = get(handles.xlabel,'String');
cancel = getappdata(handles.window,'cancel');
func   = getappdata(handles.window,'func');
timecols = getappdata(handles.window,'timecols');

if strcmp(func,'none') && ~cancel
    
    if ~isempty(timecols) && ~any(xcol==timecols)
        set(handles.xlist,'Value',timecols(1));
        xlist_Callback(hObject, eventdata, handles);
        xcol = get(handles.xlist,'Value');
        xpar = get(handles.xlabel,'String');
    end
    
    T = DADOS(:,xcol);
    
    if xcol == length(PARAM)
        beep; uiwait(errordlg({'Não é possível utilizar o parâmetro ''No.OBS.''',...
                'Use um parâmetro de tempo adequado.'},'Erro','modal')); drawnow;
        return
    end
    if ~IsTimeOk(T)
        beep; uiwait(errordlg({['O parâmetro de tempo ''' xpar ''' não é adequado.'],...
                'O tempo deve ser monotônico crescente e sem pontos inválidos.'},'Erro','modal')); drawnow;
        return
    end
    
    togglelist = setdiff(findobj(handles.window,'Enable','on'),findobj(handles.window,'Style','text'));
    set(togglelist,'Enable','off');
    UpdateButtonStatus(hObject, eventdata, handles);
    
    Y2 = RDAT_TableParam(T, xpar); drawnow;
    
    set(togglelist,'Enable','on');
    UpdateButtonStatus(hObject, eventdata, handles);
    
    if ~isempty(Y2)
        
        set([handles.entry1 handles.ok_btn handles.cancel_btn],'Visible','on');
        set([handles.menulist handles.xlist handles.ylist],'Enable','off');
        UpdateButtonStatus(hObject, eventdata, handles);
        
        ShowTemporaryPlot(hObject, eventdata, handles, Y2, '');
        setappdata(handles.window,'tempdata',Y2);
        setappdata(handles.window,'func','TableParam_1');
        
    end
    
elseif strcmp(func,'TableParam_1') && ~cancel
    
    name = TrimParamName(get(handles.entry1,'String'),handles.maxparamlength);
    if isempty(name)
        beep; uiwait(errordlg('Nome do parâmetro não pode ser vazio.','Erro','modal')); drawnow;
        return
    end 
    PARAM = InsertParam(PARAM,name);
    CheckRepParam(PARAM,name);
    
    data  = getappdata(handles.window,'tempdata');
    DADOS = [DADOS(:,1:end-1), data, DADOS(:,end)];
    
    if xcol == length(PARAM)-1
        xcol = xcol+1;
    end
    ycol = length(PARAM)-1;
    
    HideTemporaryPlot(hObject, eventdata, handles, xcol, ycol, PARAM);
    setappdata(handles.window,'func','none');
    
    setappdata(handles.window,'change',1);
    NewEvent(handles,['Parâmetro ''' name ''' criado a partir de tabela de dados.']);
    
elseif cancel
    
    HideTemporaryPlot(hObject, eventdata, handles);
    
end

% --------------------------------------------------------------------
function TrackPoints_Callback(hObject, eventdata, handles)
global DADOS
% Corrigir dados por pontos de controle

PARAM  = get(handles.xlist,'String');
xcol   = get(handles.xlist,'Value');
ycol   = get(handles.ylist,'Value');
xpar   = get(handles.xlabel,'String');
ypar   = get(handles.ylabel,'String');
xlim   = get(handles.graph,'XLim');
cancel = getappdata(handles.window,'cancel');
func   = getappdata(handles.window,'func');

if strcmp(func,'none') && ~cancel
    
    X = DADOS(:,xcol);
    Y = DADOS(:,ycol);
    
    if ~IsTimeOk(X)
        beep; errordlg({'O parâmetro x deve ser monotônico crescente e sem pontos inválidos.',...
                'Use ''No. OBS.'' ou um parâmetro de tempo adequado.'},'Erro','modal'); drawnow;
        return
    end
    
    togglelist = setdiff(findobj(handles.window,'Enable','on'),findobj(handles.window,'Style','text'));
    set(togglelist,'Enable','off');
    UpdateButtonStatus(hObject, eventdata, handles);
    
    [Y2, opt] = RDAT_TrackPoints(X, Y, xpar, ypar, [], xlim); drawnow;
    
    set(togglelist,'Enable','on');
    UpdateButtonStatus(hObject, eventdata, handles);
    
    if ~isempty(Y2)
        
        switch opt
            case 1 % Novo parâmetro
                set([handles.entry1 handles.ok_btn handles.cancel_btn],'Visible','on');
                set([handles.menulist handles.xlist handles.ylist],'Enable','off');
                UpdateButtonStatus(hObject, eventdata, handles);
                
                ShowTemporaryPlot(hObject, eventdata, handles, Y2, ypar);
                setappdata(handles.window,'tempdata',Y2);
                setappdata(handles.window,'func','TrackPoints_1');
                
            case 2 % Substituir
                DADOS(:,ycol) = Y2;
                UpdatePlot(hObject, eventdata, handles);
                
                setappdata(handles.window,'change',1);
                NewEvent(handles,['Parâmetro ''' ypar ''' alterado por pontos de controle.']);
                
            otherwise
                return
        end
    end
    
elseif strcmp(func,'TrackPoints_1') && ~cancel
    
    name = TrimParamName(get(handles.entry1,'String'),handles.maxparamlength);
    if isempty(name)
        beep; uiwait(errordlg('Nome do parâmetro não pode ser vazio.','Erro','modal')); drawnow;
        return
    end 
    PARAM = InsertParam(PARAM,name);
    CheckRepParam(PARAM,name);
    
    data  = getappdata(handles.window,'tempdata');
    DADOS = [DADOS(:,1:end-1), data, DADOS(:,end)];
    
    if xcol == length(PARAM)-1
        xcol = xcol+1;
    end
    ycol = length(PARAM)-1;
    
    HideTemporaryPlot(hObject, eventdata, handles, xcol, ycol, PARAM);
    setappdata(handles.window,'func','none');
    
    setappdata(handles.window,'change',1);
    NewEvent(handles,['Parâmetro ''' name ''' criado por pontos de controle.']);
    
elseif cancel
    
    HideTemporaryPlot(hObject, eventdata, handles);
    
end

% --------------------------------------------------------------------
function FlightPlayback_Callback(hObject, eventdata, handles)
% Reproduz o voo em HUD e TSD

setup       = getappdata(handles.window,'setup');
scenario    = getappdata(handles.window,'scenario');
events      = getappdata(handles.window,'events');
testpts     = getappdata(handles.window,'testpts');
playbackopt = getappdata(handles.window,'playbackopt');

N = GetIntervPts(handles);
if isempty(N);
    N = 1;
else
    N = N(1);
end

PARAM = get(handles.xlist,'String');
[setup, scenario, playbackopt] = RDAT_Playback(PARAM,N,setup,scenario,events,testpts,playbackopt); drawnow;

if ~isempty(setup)
    setappdata(handles.window,'setup',setup);
    setappdata(handles.window,'scenario',scenario);
    setappdata(handles.window,'change',1);
end

setappdata(handles.window,'playbackopt',playbackopt);

% --------------------------------------------------------------------
function AnemoCalc_Callback(hObject, eventdata, handles)
% Calculadora anemometrica

anemocalc;

% --------------------------------------------------------------------
function KlegkaCalc_Callback(hObject, eventdata, handles)
% Diagrama de desempenho em curva

klegkacalc;

% --------------------------------------------------------------------
function WinConverter_Callback(hObject, eventdata, handles)
% Abre o conversor de unidades 'stand alone'

s = '';
try
    [a,s] = dos([handles.auxpath 'convert.exe']);
catch
    beep; uiwait(errordlg(lasterr,'Erro','modal')); drawnow;
    return
end
if ~isempty(s)
    beep; uiwait(errordlg('Erro ao tentar carregar "Convert.exe".','Erro','modal')); drawnow;
end

% --------------------------------------------------------------------
function ExportTrajGE_Callback(hObject, eventdata, handles)
global DADOS
% Exportar trajetoria de voo para o Google Earth

PARAM  = get(handles.xlist,'String');
Rlist  = [1 2 5 10 20];
Rstr   = cellstr(num2str(Rlist'));

[folder,traj,descr,nLat,nLon,nAlt,unit,part,R] = inputvalues('Google Earth',...
    {'Nome da pasta:','Nome da trajetória:','Descrição:','Latitide (°):','Longitude (°):','Altitude:','Unidade:','Trecho:','Decimação:'},...
    {'','','',PARAM,PARAM,[{'Altitude do terreno'};PARAM],{'m','km','NM','ft'},{'Tudo','Intervalo'},Rstr},1.2);

if ~ischar(folder)
    return
end

nAlt = nAlt-1;
R    = Rlist(R);

if part == 1;
    pts = DADOS(:,end);
else
    pts = GetIntervPts(handles);
    if isempty(pts)
        beep; uiwait(errordlg('Não há pontos no intervalo selecionado.','Erro','modal')); drawnow;
        return
    end
end

Lat = DADOS(pts(1):R:pts(end),nLat);
Lon = DADOS(pts(1):R:pts(end),nLon);
if ~nAlt
    Alt = 0*Lat;
else
    Alt = DADOS(pts(1):R:pts(end),nAlt);
end

switch unit
    case 1 % m
        % Nada a fazer
    case 2 % km
        Alt = Alt*1000;
    case 3 % NM
        Alt = Alt*1852;
    case 4 % ft
        Alt = Alt*.3048;
end

kmldata.data   = [Lat Lon Alt];
kmldata.type   = 'line';
kmldata.name   = traj;
kmldata.descr  = descr;
kmldata.folder = folder;
kmldata.color  = 'w';
kmldata.width  = 2;

fname = kmlwrite(kmldata,'','Trajetória');

if ischar(fname) && ~isempty(fname)
    NewEvent(handles,['Trajetória exportada como arquivo de Google Earth: ''' fname '''.']);
    
    button = questdlg('Deseja visualizar a trajetória no Google Earth?','Confirmação','Sim','Não','Sim'); drawnow;
    
    if strcmp(button,'Sim')
        try
            [s, r] = dos(['"' fname '" & exit']);
        catch
            beep; uiwait(errordlg(lasterr,'Erro','modal')); drawnow;
            return
        end
        try
            if ~isempty(r)
                beep; uiwait(errordlg({'Erro ao carregar o arquivo.',...
                        'Verifique se o Google Earth está instalado corretamente.'},'Erro','modal')); drawnow;
            end
        end
    end
end

% --------------------------------------------------------------------
function PlaybackGE_Callback(hObject, eventdata, handles)
% Reproduz o voo no Google Earth

button = questdlg({'Essa função é experimental e ainda está em testes.',...
    ' ','Deseja continuar?'},'Confirmação','Sim','Não','Não'); drawnow; % @@

if ~strcmp(button,'Sim')
    return
end

setup       = getappdata(handles.window,'setup');
scenario    = getappdata(handles.window,'scenario');
events      = getappdata(handles.window,'events');
testpts     = getappdata(handles.window,'testpts');

N = GetIntervPts(handles);
if isempty(N);
    N = 1;
else
    N = N(1);
end

PARAM = get(handles.xlist,'String');
RDAT_PlaybackGE(PARAM,N,setup,scenario,events,testpts); drawnow;

% --------------------------------------------------------------------
function EditCalibData_Callback(hObject, eventdata, handles)
% Abre o editor de dados de calibração de aeronaves

RDAT_EditCalibData;

% --------------------------------------------------------------------
function ProcessData_Callback(hObject, eventdata, handles)
% Processamento de dados a partir das curvas de calibração da aeronave

PARAM = get(handles.xlist,'String');
xcol = get(handles.xlist,'Value');
ycol = get(handles.ylist,'Value');
Npar = length(PARAM);

togglelist = setdiff(findobj(handles.window,'Enable','on'),findobj(handles.window,'Style','text'));
set(togglelist,'Enable','off');
UpdateButtonStatus(hObject, eventdata, handles);

PARAM = RDAT_DataProcess(PARAM); drawnow;

set(togglelist,'Enable','on');
UpdateButtonStatus(hObject, eventdata, handles);

if ~isempty(PARAM)
    if xcol == Npar
        xcol = length(PARAM);
    end
    if ycol == Npar
        ycol = length(PARAM);
    end
    UpdateGraph(hObject, eventdata, handles, xcol, ycol, PARAM)
    
    setappdata(handles.window,'change',1);
    NewEvent(handles,'Processamento de dados realizado.');
end

% --------------------------------------------------------------------
function TestPts_Editor_Callback(hObject, eventdata, handles)
% Edita as definições dos pontos de ensaio (intervalos, parâmetros, tolerancias ...)

PARAM   = get(handles.xlist,'String');
testpts = getappdata(handles.window,'testpts');
reftime = getappdata(handles.window,'reftime');
events  = getappdata(handles.window,'events');

togglelist = setdiff(findobj(handles.window,'Enable','on'),findobj(handles.window,'Style','text'));
set(togglelist,'Enable','off');
UpdateButtonStatus(hObject, eventdata, handles);

[testpts, reftime] = RDAT_TestPoints(PARAM,testpts,reftime,events); drawnow;

set(togglelist,'Enable','on');
UpdateButtonStatus(hObject, eventdata, handles);

if ~isempty(testpts)
    check_reftime(PARAM,reftime);
    setappdata(handles.window,'testpts',testpts);
    setappdata(handles.window,'reftime',reftime);
    set(handles.ShowTestPoints,'Checked','on');
    set(handles.TestPoints_btn,'Value',1);
    UpdateEvents(hObject, eventdata, handles);
    UpdateTestPoints(hObject, eventdata, handles, 1);
    UpdateTimeCols(hObject, eventdata, handles);
    
    setappdata(handles.window,'change',1);
    NewEvent(handles,'Lista de pontos de ensaio alterada.');
end

% --------------------------------------------------------------------
function TestPts_Create_Callback(hObject, eventdata, handles)
global DADOS
% Função que habilita múltiplos gráficos (até 3) para criação/alteração de ponto de ensaio

PARAM   = get(handles.xlist,'String');
func    = getappdata(handles.window,'func');
cancel  = getappdata(handles.window,'cancel');
reftime = getappdata(handles.window,'reftime');
testpts = getappdata(handles.window,'testpts');

if strcmp(func,'none') && ~cancel
    
    nreftime = findpar(PARAM,reftime,0,1);
    if isempty(nreftime)
        nreftime = inputvalue('Definir','Tempo de referência:',PARAM,1,1.35); drawnow;
        if isempty(nreftime)
            return
        else
            [ok, ndc, nna] = IsTimeOk(DADOS(:,nreftime));
            if ~ok
                beep; uiwait(errordlg({'Parâmetro de tempo não é adequado:',' ',...
                        ['Pontos inválidos: ' num2str(length(nna))],...
                        ['Pontos não crescentes: ' num2str(length(ndc))]},'Erro','modal')); drawnow;
                return
            else
                reftime = denumber(PARAM{nreftime});
                setappdata(handles.window,'reftime',reftime);
                UpdateTimeCols(hObject, eventdata, handles);
                UpdateTestPoints(hObject, eventdata, handles, 1);
                
                setappdata(handles.window,'change',1);
                NewEvent(handles,['Tempo de referência definido: ''' reftime '''.']);
            end
        end
    end
    
    tcol = findpar(PARAM,reftime,0,1);
    if isempty(tcol)
        beep; uiwait(errordlg(['O tempo de referência ''' reftime ''' não foi encontrado.'],'Erro','modal')); drawnow;
        return
    else
        if get(handles.xlist,'Value') ~= tcol
            set(handles.xlist,'Value',tcol);
            xlist_Callback(hObject, eventdata, handles);
        end
    end
    
    ptslist{1} = ' ';
    if ~isempty(testpts)
        testptsnumber = [testpts.number];
        testptsdescr  = [testpts.descr];
        
        for n = 1:length(testptsnumber)
            ptslist{n+1} = [testptsnumber{n} ' - ' testptsdescr{n}];
        end
    end
    
    ax = get(handles.graph,'Xlim');
    t1 = ax(1)+diff(ax)/5;
    t2 = ax(2)-diff(ax)/5;
    
    set(handles.entries([1,3]),'String',[{' '};PARAM],'Value',1);
    set(handles.entry2,'String',{'Criar','Alterar'},'Value',1);
    set(handles.entry4,'Position',get(handles.entry4,'Position')+[-50 0 50 0],'String',ptslist,'Value',1);
    set([handles.entry1txt handles.ylabels(2)],'String','y2');
    set([handles.entry3txt handles.ylabels(4)],'String','y3');
    set(handles.entry2txt,'String','Opção:');
    
    set([handles.menulist handles.xlist handles.ShowTestPoints handles.ShowTestPointsDescr],'Enable','off');
    set([handles.entries(1:3) handles.entriestxt(1:3) handles.ok_btn handles.cancel_btn],'Visible','on');
    SetFrame(handles,2,'Criar/alterar ponto de ensaio:');
    set(handles.title,'UIContextMenu',handles.TitleMenu);
    UpdateButtonStatus(hObject, eventdata, handles);
    
    setappdata(handles.window,'func','TestPtCreation_1');
    setappdata(handles.window,'tempdata',[t1 t2]);
    UpdateCreationWindow(hObject, eventdata, handles);
    
elseif strcmp(func,'TestPtCreation_1') && ~cancel
    
    tempdata = getappdata(handles.window,'tempdata');
    testpts  = getappdata(handles.window,'testpts');
    
    opt = get(handles.entry2,'Value');
    npt = get(handles.entry4,'Value')-1;
    
    switch opt
        case 1 % Criar
            
            button = questdlg({'Deseja definir o intervalo',['[' time2str2(tempdata(1)) ', ' time2str2(tempdata(2)) ,']'],...
                    'como um ponto de ensaio?'},'Confirmação','Sim','Não','Não'); drawnow;
            if ~strcmp(button,'Sim')
                return
            end
            
            ngrp = 1;
            num = '';
            descr = '';
            
            if isempty(testpts) || ~isfield(testpts,'group')
                grouplist = {};
            else
                grouplist = {testpts.group};
            end
            grouplist{end+1} = 'Novo Grupo';
            
            while ischar(num) && isempty(num) || ischar(descr) && isempty(descr)
                [ngrp, num, descr] = inputpoint2('Novo Ponto de Ensaio','Grupo:','Número:','Descrição:', grouplist, num, descr, ngrp);
            end
            if isempty(ngrp)
                cancel_btn_Callback(hObject, eventdata, handles);
                return
            end
            
            if ngrp == length(grouplist)
                group = '';
                while ischar(group) && isempty(group)
                    group = inputvalue('Novo Grupo','Nome:',group,[],1.05);
                end
                if isempty(group)
                    cancel_btn_Callback(hObject, eventdata, handles);
                    return
                end
                if length(group) > 16
                    group = group(1:16);
                end
                if ngrp == 1
                    testpts = emptytestptslist;
                else
                    testpts(ngrp) = emptytestptslist;
                end
                testpts(ngrp).group = group;
            end
            
            if length(num) > 8
                num = num(1:8);
            end
            if length(descr) > 56
                descr = descr(1:56);
            end
            
            Npts = length(testpts(ngrp).number);
            Npar = length(testpts(ngrp).param);
            
            % Valores por ponto (uma coluna um ponto)
            testpts(ngrp).number{Npts+1}   = num;
            testpts(ngrp).descr{Npts+1}    = descr;
            testpts(ngrp).time(:,Npts+1)   = tempdata';
            
            % Valores por ponto e parâmetro (uma linha por ponto e uma coluna por parâmetro)
            testpts(ngrp).aim(Npts+1,:)    = NaN*ones(1,Npar);
            testpts(ngrp).range1(Npts+1,:) = NaN*ones(1,Npar);
            testpts(ngrp).range2(Npts+1,:) = NaN*ones(1,Npar);
            testpts(ngrp).tol1(Npts+1,:)   = NaN*ones(1,Npar);
            testpts(ngrp).tol2(Npts+1,:)   = NaN*ones(1,Npar);
            
            NewEvent(handles,['Ponto de ensaio criado: ''' num ' - ' descr '''.']);
            
        case 2 % Alterar
            
            if isempty(testpts)
                beep; uiwait(errordlg('Não há pontos de ensaio definidos.','Erro','modal')); drawnow;
                return
            end
            if ~npt
                beep; uiwait(errordlg('Ponto de ensaio não selecionado.','Erro','modal')); drawnow;
                return
            end
            
            ptsindx = [];
            for n = 1:size(testpts,2)
                for m = 1:length(testpts(n).number)
                    ptsindx(length(ptsindx)+1) = n + m*1i;
                end
            end
            Ngrp = real(ptsindx(npt));
            Npt  = imag(ptsindx(npt));
            
            button = questdlg({['Deseja alterar ponto de ensaio ''' testpts(Ngrp).number{Npt} ' - ' testpts(Ngrp).descr{Npt} ''''],...
                    ['para o intervalo [' time2str2(tempdata(1)) ', ' time2str2(tempdata(2)) ,']?']},...
                'Confirmação','Sim','Não','Não'); drawnow;
            if ~strcmp(button,'Sim')
                return
            end
            
           testpts(Ngrp).time(:,Npt) = tempdata';
           
           NewEvent(handles,['Ponto de ensaio alterado: ''' testpts(Ngrp).number{Npt} ' - ' testpts(Ngrp).descr{Npt} '''.']);

   end
   
   setappdata(handles.window,'func','none');
   setappdata(handles.window,'tempdata',[]);
   setappdata(handles.window,'testpts',testpts);    
   UpdateTestPoints(hObject, eventdata, handles, 1);
   
   set(handles.entry4,'Position',get(handles.entry4,'Position')-[-50 0 50 0]);
   set([handles.auxplots(:)' handles.plots(2,2:3)],'XData',NaN,'YData',NaN);
   set([handles.ShowTestPoints handles.ShowTestPointsDescr],'Enable','on');
   set(handles.title,'String','','UIContextMenu',[]);
   ClearEntryBox(hObject, eventdata, handles);
   MultiParamOperation_setgraph(hObject, eventdata, handles, 0, 0);
   
   setappdata(handles.window,'change',1);
   
elseif cancel
    
    set(handles.entry4,'Position',get(handles.entry4,'Position')-[-50 0 50 0]);
    set([handles.auxplots(:)' handles.plots(2,2:3)],'XData',NaN,'YData',NaN);
    set([handles.ShowTestPoints handles.ShowTestPointsDescr],'Enable','on');
    set(handles.title,'String','','UIContextMenu',[]);
    MultiParamOperation_setgraph(hObject, eventdata, handles, 0, 0);
    
end

% --------------------------------------------------------------------
function TestPts_DefineInterval_Callback(hObject, eventdata, handles)
global DADOS
% Define o intervalo selecionado como ponto de ensaio

PARAM   = get(handles.xlist,'String');
testpts = getappdata(handles.window,'testpts');
reftime = getappdata(handles.window,'reftime');
xcol    = get(handles.xlist,'Value');

pts = GetIntervPts(handles);
if isempty(pts)
    beep; uiwait(errordlg('Não há pontos no intervalo selecionado.','Erro','modal')); drawnow;
    return
end

if isempty(reftime)
    nreftime = inputvalue('Definir','Tempo de referência:',PARAM,1,1.35); drawnow;
    if isempty(nreftime)
        return
    else
        reftime = denumber(PARAM{nreftime});
        check_reftime(PARAM,reftime);
        setappdata(handles.window,'reftime',reftime);
        UpdateTimeCols(hObject, eventdata, handles);
        
        setappdata(handles.window,'change',1);
        NewEvent(handles,['Tempo de referência definido: ''' reftime '''.']);
    end
end

tcol = findpar(PARAM,reftime,0,1);
if isempty(tcol)
    beep; uiwait(errordlg(['O tempo de referência ''' reftime ''' não foi encontrado.'],'Erro','modal')); drawnow;
    return
end

if xcol == length(PARAM) % No.OBS.
    T = DADOS(:,tcol);
    [ok, ndc, nna] = IsTimeOk(T);
    if ok
        ax = interp1(DADOS(:,end),T,get(handles.graph,'XLim'),'linear','extrap');
        set(handles.xlist,'Value',tcol);
        xlist_Callback(hObject, eventdata, handles);
        set(handles.graphs,'XLim',ax);
        xcol = tcol;
    else
        beep; uiwait(errordlg({'Parâmetro de tempo não é adequado:',' ',...
                ['Pontos inválidos: ' num2str(length(nna))],...
                ['Pontos não crescentes: ' num2str(length(ndc))]},'Erro','modal')); drawnow;
        return
    end
end

if xcol ~= tcol
    beep; uiwait(errordlg({'Para definir o intervalo como ponto de ensaio,',...
            ['a abcissa deve ser o tempo de referência ''' reftime ''''],...
            'ou o parâmetro ''No. OBS.''.'},'Erro','modal')); drawnow;
    return
end

ax = get(handles.graph,'XLim');
Tini = floor(1000*ax(1))/1000;
Tend = ceil(1000*ax(2))/1000;

button = questdlg({'Deseja definir o intervalo',['[' time2str2(Tini) ', ' time2str2(Tend) ,']'],...
        'como um ponto de ensaio?'},'Confirmação','Sim','Não','Não'); drawnow;
if ~strcmp(button,'Sim')
    return
end

ngrp = 1;
num = '';
descr = '';

if isempty(testpts) || ~isfield(testpts,'group')
    grouplist = {};
else
    grouplist = {testpts.group};
end
grouplist{end+1} = 'Novo Grupo';

while ischar(num) && isempty(num) || ischar(descr) && isempty(descr)
    [ngrp, num, descr] = inputpoint2('Novo Ponto de Ensaio','Grupo:','Número:','Descrição:', grouplist, num, descr, ngrp);
end
if isempty(ngrp)
    return
end

if ngrp == length(grouplist)
    group = '';
    while ischar(group) && isempty(group)
        group = inputvalue('Novo Grupo','Nome:',group,[],1.05);
    end
    if isempty(group)
        return
    end
    if length(group) > 16
        group = group(1:16);
    end
    if ngrp == 1
        testpts = emptytestptslist;
    else
        testpts(ngrp) = emptytestptslist;
    end
    testpts(ngrp).group = group;
end

if length(num) > 8
    num = num(1:8);
end
if length(descr) > 56
    descr = descr(1:56);
end

Npts = length(testpts(ngrp).number);
Npar = length(testpts(ngrp).param);

% Valores por ponto (uma coluna um ponto)
testpts(ngrp).number{Npts+1}   = num;
testpts(ngrp).descr{Npts+1}    = descr;
testpts(ngrp).time(:,Npts+1)   = [Tini; Tend];

% Valores por ponto e parâmetro (uma linha por ponto e uma coluna por parâmetro)
testpts(ngrp).aim(Npts+1,:)    = NaN*ones(1,Npar);
testpts(ngrp).range1(Npts+1,:) = NaN*ones(1,Npar);
testpts(ngrp).range2(Npts+1,:) = NaN*ones(1,Npar);
testpts(ngrp).tol1(Npts+1,:)   = NaN*ones(1,Npar);
testpts(ngrp).tol2(Npts+1,:)   = NaN*ones(1,Npar);

setappdata(handles.window,'testpts',testpts);
UpdateTestPoints(hObject, eventdata, handles, 1);

setappdata(handles.window,'change',1);
NewEvent(handles,['Ponto de ensaio inserido: ''' num ' - ' descr '''.']);

% --------------------------------------------------------------------
function TestPts_DefineSelection_Callback(hObject, eventdata, handles)
global DADOS
% Define a seleção como ponto de ensaio

PARAM   = get(handles.xlist,'String');
sel     = getappdata(handles.window,'sel');
testpts = getappdata(handles.window,'testpts');
reftime = getappdata(handles.window,'reftime');

if isempty(sel)
    beep; uiwait(errordlg('Não há pontos selecionados.','Erro','modal')); drawnow;
    return
end

if isempty(reftime)
    nreftime = inputvalue('Definir','Tempo de referência:',PARAM,1,1.35); drawnow;
    if isempty(nreftime)
        return
    else
        reftime = denumber(PARAM{nreftime});
        check_reftime(PARAM,reftime);
        setappdata(handles.window,'reftime',reftime);
        UpdateTimeCols(hObject, eventdata, handles);
        
        setappdata(handles.window,'change',1);
        NewEvent(handles,['Tempo de referência definido: ''' reftime '''.']);
    end
end

tcol = findpar(PARAM,reftime,0,1);
if isempty(tcol)
    beep; uiwait(errordlg(['O tempo de referência ''' reftime ''' não foi encontrado.'],'Erro','modal')); drawnow;
    return
end

Dt = sort(DADOS(sel([1 end]),tcol));

Tini = min(Dt);
Tend = max(Dt);

button = questdlg({'Deseja definir a seleção',['[' time2str2(Tini) ', ' time2str2(Tend) ,']'],...
        'como um ponto de ensaio?'},'Confirmação','Sim','Não','Não'); drawnow;
if ~strcmp(button,'Sim')
    return
end

ngrp = 1;
num = '';
descr = '';

if isempty(testpts) || ~isfield(testpts,'group')
    grouplist = {};
else
    grouplist = {testpts.group};
end
grouplist{end+1} = 'Novo Grupo';

while ischar(num) && isempty(num) || ischar(descr) && isempty(descr)
    [ngrp, num, descr] = inputpoint2('Novo Ponto de Ensaio','Grupo:','Número:','Descrição:', grouplist, num, descr, ngrp);
end
if isempty(ngrp)
    return
end

if ngrp == length(grouplist)
    group = '';
    while ischar(group) && isempty(group)
        group = inputvalue('Novo Grupo','Nome:',group,[],1.05);
    end
    if isempty(group)
        return
    end
    if length(group) > 16
        group = group(1:16);
    end
    if ngrp == 1
        testpts = emptytestptslist;
    else
        testpts(ngrp) = emptytestptslist;
    end
    testpts(ngrp).group = group;
end

if length(num) > 8
    num = num(1:8);
end
if length(descr) > 56
    descr = descr(1:56);
end

if isempty(testpts)
    testpts = emptytestptslist;
end

Npts = length(testpts(ngrp).number);
Npar = length(testpts(ngrp).param);

% Valores por ponto (uma coluna um ponto)
testpts(ngrp).number{Npts+1}   = num;
testpts(ngrp).descr{Npts+1}    = descr;
testpts(ngrp).time(:,Npts+1)   = [Tini; Tend];

% Valores por ponto e parâmetro (uma linha por ponto e uma coluna por parâmetro)
testpts(ngrp).aim(Npts+1,:)    = NaN*ones(1,Npar);
testpts(ngrp).range1(Npts+1,:) = NaN*ones(1,Npar);
testpts(ngrp).range2(Npts+1,:) = NaN*ones(1,Npar);
testpts(ngrp).tol1(Npts+1,:)   = NaN*ones(1,Npar);
testpts(ngrp).tol2(Npts+1,:)   = NaN*ones(1,Npar);

setappdata(handles.window,'testpts',testpts);
UpdateTestPoints(hObject, eventdata, handles, 1);

setappdata(handles.window,'change',1);
NewEvent(handles,['Ponto de ensaio inserido: ''' num ' - ' descr '''.']);

pause(.5);
DeselectAll_Callback(hObject, eventdata, handles);

% --------------------------------------------------------------------
function TestPts_Validation_Callback(hObject, eventdata, handles)
% Função que habilita múltiplos gráficos (até 3)
% para verificação visual de validade (tolerâncias) de pontos de ensaio

PARAM   = get(handles.xlist,'String');
func    = getappdata(handles.window,'func');
cancel  = getappdata(handles.window,'cancel');
testpts = getappdata(handles.window,'testpts');
reftime = getappdata(handles.window,'reftime');

if strcmp(func,'none') && ~cancel
    
    if ~isfield(testpts,'number') || isempty([testpts.number])
        beep; uiwait(errordlg('Não há pontos de ensaio definidos.','Erro','modal')); drawnow;
        return
    end
    
    if isempty(reftime)
        beep; uiwait(errordlg('O tempo de referência não está definido.','Erro','modal')); drawnow;
        return
    end
    
    tcol = findpar(PARAM,reftime,0,1);
    if isempty(tcol)
        beep; uiwait(errordlg(['O tempo de referência ''' reftime ''' não foi encontrado.'],'Erro','modal')); drawnow;
        return
    else
        if get(handles.xlist,'Value') ~= tcol
            set(handles.xlist,'Value',tcol);
            xlist_Callback(hObject, eventdata, handles);
        end
    end
    
    for ngrp = 1:size(testpts,2)
        Nexc = [];
        for n = 1:length(testpts(ngrp).param)
            if isempty(findpar(PARAM,testpts(ngrp).param{n},1,1))
                Nexc = [Nexc n];
            end
        end
        if ~isempty(Nexc)
            if length(Nexc) == 1
                str = {'O seguinte parâmetro não foi encontrado:',' ',testpts(ngrp).param{Nexc},' ','Deseja prosseguir?'};
            elseif length(Nexc) <= 20
                str = {'Os seguintes parâmetros não foram encontrados:',' ',testpts(ngrp).param{Nexc},' ','Deseja prosseguir?'};
            else
                str = {[num2str(length(Nexc)) ' parâmetros não foram encontrados.'],' ','Deseja prosseguir?'};
            end
            str = [{['Grupo: ' testpts(ngrp).group '.']}, str];
            button = questdlg(str,'Confirmação','Sim','Não','Não'); drawnow;
            if ~strcmp(button,'Sim')
                return
            end
        end
    end
    
    setappdata(handles.window,'tempdata',testpts);
    
    set(handles.entry4,'Position',get(handles.entry4,'Position')+[-50 0 50 0]);

    set(handles.entries([1,3]),'String',[{' '};PARAM],'Value',1);
    set(handles.entry2,'String',{testpts.group},'Value',1);
    set([handles.entry1txt handles.ylabels(2)],'String','y2');
    set([handles.entry3txt handles.ylabels(4)],'String','y3');
    set(handles.entry2txt,'String','Grp/Pto:');
    set(handles.cancel_btn,'String','OK');
    
    set([handles.menulist handles.xlist handles.ShowTestPoints handles.ShowTestPointsDescr],'Enable','off');
    set([handles.entries handles.entriestxt(1:3) handles.cancel_btn],'Visible','on');
    SetFrame(handles,2,'Parâmetros para validação de pontos de ensaio:');
    set(handles.title,'UIContextMenu',handles.TitleMenu);
    UpdateButtonStatus(hObject, eventdata, handles);
    
    setappdata(handles.window,'func','TestPtsValidation_1');
    entry2_Callback(hObject, eventdata, handles);
    UpdateValidationWindow(hObject, eventdata, handles, 1);
    
elseif cancel
    
    tempdata = getappdata(handles.window,'tempdata');
    old_testpts = tempdata;
    
    if ~isequalwithequalnans(testpts,old_testpts)
        button = questdlg({'Intervalos dos pontos de ensaio foram alterados.',...
                'Deseja confirmar as alterações?'},'Confirmação','Sim','Não','Não'); drawnow;
        if strcmp(button,'Sim')
            UpdateTestPoints(hObject, eventdata, handles);
        else
            testpts = old_testpts;
            setappdata(handles.window,'testpts',testpts);
            
            setappdata(handles.window,'change',1);
            NewEvent(handles,'Intervalos de pontos de ensaio alterados.');
        end
    end
    
    set(handles.entry4,'Position',get(handles.entry4,'Position')-[-50 0 50 0]);

    set([handles.valplots handles.invplots],'XData',NaN,'YData',NaN);
    set([handles.auxplots(:)' handles.plots(2,2:3)],'XData',NaN,'YData',NaN);
    set(handles.ptmarker,'Visible','off');
    set([handles.ShowTestPoints handles.ShowTestPointsDescr],'Enable','on');
    set(handles.ylist,'String',get(handles.xlist,'String'));
    set(handles.title,'String','','UIContextMenu',[]);
    set(handles.cancel_btn,'Visible','off','String','Cancela');
    MultiParamOperation_setgraph(hObject, eventdata, handles, 0, 0);
    
end

% --------------------------------------------------------------------
function TestPts_FitView_Callback(hObject, eventdata, handles)
global DADOS
% Função para verificação visual dos ajustes de curva dos pontos de ensaio

PARAM   = get(handles.xlist,'String');
func    = getappdata(handles.window,'func');
cancel  = getappdata(handles.window,'cancel');
testpts = getappdata(handles.window,'testpts');
reftime = getappdata(handles.window,'reftime');

if strcmp(func,'none') && ~cancel
    
    if ~isfield(testpts,'number') || isempty([testpts.number])
        beep; uiwait(errordlg('Não há pontos de ensaio definidos.','Erro','modal')); drawnow;
        return
    end
    
    if isempty(reftime)
        beep; uiwait(errordlg('O tempo de referência não está definido.','Erro','modal')); drawnow;
        return
    end
    
    Nfit = 0;
    if isfield(testpts,'fit')
        for ngrp = 1:size(testpts,2)
            if ~isempty(testpts(ngrp).fit)
                Nfit = Nfit + length(find(testpts(ngrp).fit(:,1))) .* length(testpts(ngrp).number);
            end
        end
    end
    if ~Nfit
        beep; uiwait(errordlg('Não há ajustes de curva definidos.','Erro','modal')); drawnow;
        return
    end
    
    if isempty(reftime)
        beep; uiwait(errordlg('O tempo de referência não está definido.','Erro','modal')); drawnow;
        return
    end
    tcol = findpar(PARAM,reftime,0,1);
    if isempty(tcol)
        beep; uiwait(errordlg(['O tempo de referência ''' reftime ''' não foi encontrado.'],'Erro','modal')); drawnow;
        return
    else
        if get(handles.xlist,'Value') ~= tcol
            set(handles.xlist,'Value',tcol);
            xlist_Callback(hObject, eventdata, handles);
        end
    end
    
    for ngrp = 1:size(testpts,2)
        Nexc = [];
        for n = 1:length(testpts(ngrp).param)
            if isempty(findpar(PARAM,testpts(ngrp).param{n},1,1)) && testpts(ngrp).fit(n,1)
                Nexc = [Nexc n];
            end
        end
        if ~isempty(Nexc)
            if length(Nexc) == 1
                str = {'O seguinte parâmetro não foi encontrado:',' ',testpts(ngrp).param{Nexc},' ','Deseja prosseguir?'};
            elseif length(Nexc) <= 20
                str = {'Os seguintes parâmetros não foram encontrados:',' ',testpts(ngrp).param{Nexc},' ','Deseja prosseguir?'};
            else
                str = {[num2str(length(Nexc)) ' parâmetros não foram encontrados.'],' ','Deseja prosseguir?'};
            end
            str = [{['Grupo: ' testpts(ngrp).group '.']}, str];
            button = questdlg(str,'Confirmação','Sim','Não','Não'); drawnow;
            if ~strcmp(button,'Sim')
                return
            end
        end
    end
    
    % Obtenção dos dados de ajuste
    
    drawnow;
    set(handles.window,'Pointer','watch');
    
    T = DADOS(:,tcol);
    
    Ngrp = size(testpts,2);
    nfit = 1;
    
    h = waitbar(0,['Gerando ajuste ' num2str(nfit) ' de ' num2str(Nfit) '.'],'Name','0.0% concluído',...
        'Color',get(handles.ZoomIn_btn,'BackgroundColor'),'Renderer','zbuffer','Pointer','watch','WindowStyle','modal');
    set(get(get(h,'children'),'Title'),'Interpreter','none');
    
    for ngrp = 1:Ngrp
        
        Npts = length(testpts(ngrp).number);
        Npar = length(testpts(ngrp).param);
        
        for npar = 1:Npar
            for npt = 1:Npts
                
                colpar = findpar(PARAM,testpts(ngrp).param{npar},0,1);
                if isempty(colpar)
                    pts = [];
                    Y = NaN;
                else
                    if isnan(testpts(ngrp).time(2,npt)-testpts(ngrp).time(1,npt))
                        pts = [];
                        Y = NaN;
                    else
                        pts = GetIntervPts(T,testpts(ngrp).time(1,npt),testpts(ngrp).time(2,npt));
                        Y = DADOS(pts,colpar);
                    end
                end
                
                ord = testpts(ngrp).fit(npar,1);
                if ord
                    if testpts(ngrp).fit(npar,2)
                        if ~isempty(pts)
                            t0 = T(pts(1));
                        else
                            t0 = NaN;
                        end
                    else
                        t0 = 0;
                    end
                    if ord <= 6 % Poly
                        if isempty(pts)
                            cfs = NaN*ones(1,ord+1);
                            Yf = NaN*Y;
                        else
                            try
                                cfs = polyfit(T(pts)-t0,Y,ord);
                                Yf  = polyval(cfs,T(pts)-t0);
                            catch
                                cfs = NaN*ones(1,ord+1);
                                Yf = NaN*Y;
                            end
                        end
                    elseif ord == 7 % 1st order
                        if isempty(pts)
                            cfs = NaN*ones(1,3);
                            Yf = NaN*Y;
                        else
                            try
                                [Yf, t, cfs] = fit_1st_ord(T(pts),Y);
                            catch
                                cfs = NaN*ones(1,3);
                                Yf = NaN*Y;
                            end
                        end
                    else % 2nd order
                        if isempty(pts)
                            cfs = NaN*ones(1,6);
                            Yf = NaN*Y;
                        else
                            try
                                [Yf, t, cfs] = fit_2nd_ord(T(pts),Y);
                            catch
                                cfs = NaN*ones(1,6);
                                Yf = NaN*Y;
                            end
                        end
                    end
                    S = goodnessfit(Y, Yf, length(cfs));
                    
                    if isempty(pts)
                        X = NaN;
                    else
                        X = T(pts);
                    end
                    
                    D(ngrp,npt,npar).cfs = cfs;
                    D(ngrp,npt,npar).ord = ord;
                    D(ngrp,npt,npar).t0  = t0;
                    D(ngrp,npt,npar).S   = S;
                    D(ngrp,npt,npar).X   = X;
                    D(ngrp,npt,npar).ym  = nanmean(Y);
                    D(ngrp,npt,npar).Yf  = Yf;
                    
                end
                if testpts(ngrp).fit(npar,1)
                    if ishandle(h)
                        try
                            waitbar(nfit/Nfit,h,['Gerando ajuste ' num2str(nfit) ' de ' num2str(Nfit) '.']);
                            set(h,'Name',[num2str(100*nfit/Nfit,'%1.1f') '% concluído']);
                        end
                    else
                        return
                    end
                    nfit = nfit+1;
                end
            end
        end
    end
    try, pause(.4); delete(h); end
    
    setappdata(handles.window,'tempdata',{[],[],[],[],[],D});
    
    set(handles.entry4,'Position',get(handles.entry4,'Position')+[-50 0 50 0]);
    
    set(handles.entry1,'String',PARAM,'Value',get(handles.ylist,'Value'));
    set(handles.entry2,'String',{testpts.group},'Value',1);
    set(handles.entry3,'Style','edit','String','','Enable','inactive');
    set(handles.entry1txt,'String','Param.:');
    set(handles.entry2txt,'String','Grp/Pto:');
    set(handles.entry3txt,'String','Adj-R² :');
    set(handles.cancel_btn,'String','OK');
    
    set([handles.entries handles.entriestxt(1:3) handles.cancel_btn],'Visible','on');
    SetFrame(handles,1,'Parâmetros para visualização de ajuste de curva:');
    set([handles.menulist handles.xlist handles.ylist],'Enable','off');
    UpdateButtonStatus(hObject, eventdata, handles);
    
    setappdata(handles.window,'func','TestPtsFitView_1');
    entry2_Callback(hObject, eventdata, handles);
    entry1_Callback(hObject, eventdata, handles);
    
elseif strcmp(func,'TestPtsFitView_1') && ~cancel
    
    ycol = get(handles.entry1,'Value');
    ngrp = get(handles.entry2,'Value');
    npt  = get(handles.entry4,'Value')-1;
    
    tempdata = getappdata(handles.window,'tempdata');
    D = tempdata{6};
    
    if ~npt || isempty(testpts(ngrp).number)
        set(handles.ptmarker(1,1),'Position',[0 0 0],'Visible','off');
        set(handles.ptmarker(1,2),'Position',[0 0 0],'Visible','off');
        set(handles.fit,'XData',NaN,'YData',NaN);
        set(handles.entry3,'String','');
        set(handles.title,'String','','Interpreter','TeX','UIContextMenu',[]);
        setappdata(handles.window,'tempdata',{[],[],[],[],[],D});
        return
    end
    
    tcol = get(handles.xlist,'Value');
    T = DADOS(:,tcol);
    Tini = testpts(ngrp).time(1,npt);
    Tend = testpts(ngrp).time(2,npt);
    pts  = GetIntervPts(T,Tini,Tend);
    if isempty(pts)
        t1 = 0;
        t2 = 0;
        y1 = 0;
        y2 = 0;
        vis = 'off';
    else
        t1 = DADOS(pts(1),tcol);   if isnan(t1); t1 = Tini; end
        t2 = DADOS(pts(end),tcol); if isnan(t2); t1 = Tend; end
        y1 = DADOS(pts(1),ycol);   if isnan(y1); y1 = nanmean(DADOS(pts,ycol)); end
        y2 = DADOS(pts(end),ycol); if isnan(y2); y2 = nanmean(DADOS(pts,ycol)); end
        vis = 'on';
        if isnan(y1+y2+t1+t2)
            t1 = 0;
            t2 = 0;
            y1 = 0;
            y2 = 0;
            vis = 'off';
        end
    end
    
    set(handles.ptmarker(1,1),'Position',[t1 y1 0],'Visible',vis);
    set(handles.ptmarker(1,2),'Position',[t2 y2 0],'Visible',vis);
    
    npar = findpar(testpts(ngrp).param,denumber(PARAM{ycol}),0,1);
    
    if isempty(npar)
        set(handles.fit,'XData',NaN,'YData',NaN);
        set(handles.entry3,'String','');
        set(handles.title,'String','','Interpreter','TeX','UIContextMenu',[]);
        setappdata(handles.window,'tempdata',{[],[],[],[],[],D});
        
    else
        
        cfs = D(ngrp,npt,npar).cfs;
        ord = D(ngrp,npt,npar).ord;
        t0  = D(ngrp,npt,npar).t0;
        S   = D(ngrp,npt,npar).S;
        X   = D(ngrp,npt,npar).X;
        Yf  = D(ngrp,npt,npar).Yf;
        
        if ~isempty(cfs)
            set(handles.fit,'XData',X,'YData',Yf);
            set(handles.entry3,'String',num2str(S.adjR2));
            
            if ord <= 6 % Polinomio
                
                fittype = 'poly';
                if t0 ~= 0
                    sgn = num2str(t0,'%+0d');
                    sgn = sgn(1);
                    eq = poly2eq(cfs,'\xi');
                    titlestr = [eq,'   [\xi = x ' sgn ' ' num2str(abs(t0),6) ']'];
                else
                    titlestr = poly2eq(cfs,'x');
                end
                set(handles.title,'String',titlestr,'Interpreter','TeX','UIContextMenu',handles.TitleMenu);
                
            elseif ord == 7 % 1a ordem
                
                fittype = '1ord';
                tau  = cfs(3);
                yini = cfs(1);
                yinf = cfs(1)+cfs(2);
                
                set(handles.title,'String',['\tau:  ' num2str(tau,4) ' s     y0:  ' num2str(yini,6) '     y\infty:  ' num2str(yinf,6)],...
                    'Interpreter','TeX','UIContextMenu',handles.TitleMenu);
                
            else % 2a ordem
                
                fittype = '2ord';
                wn = sqrt(cfs(5)^2+cfs(3)^2);
                z = cfs(3)/wn;
                
                set(handles.title,'String',['\zeta:  ',num2str(z,4),'     \omegan:  ',num2str(wn,'%0.4f'),' rad/s'],...
                    'Interpreter','TeX','UIContextMenu',handles.TitleMenu);
            end
            setappdata(handles.window,'tempdata',{fittype,cfs,t0,[],S,D});
            
        else
            set(handles.fit,'XData',NaN,'YData',NaN);
            set(handles.entry3,'String','');
            set(handles.title,'String','','Interpreter','TeX','UIContextMenu',[]);
            setappdata(handles.window,'tempdata',{[],[],[],[],[],D});
        end
    end
    
elseif cancel
    
    set(handles.entry4,'Position',get(handles.entry4,'Position')-[-50 0 50 0]);
    
    set(handles.title,'String','','Interpreter','TeX','UIContextMenu',[]);
    set(handles.fit,'XData',NaN,'YData',NaN);
    set(handles.ptmarker,'Visible','off');
    set(handles.cancel_btn,'Visible','off','String','Cancela');
    setappdata(handles.window,'tempdata',[]);
    UpdatePlot(hObject, eventdata, handles);
    
end

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function TestPts_GetData_Callback(hObject, eventdata, handles)
global DADOS
% Obtem os dados relevantes dos pontos de ensaio

PARAM   = get(handles.xlist,'String');
testpts = getappdata(handles.window,'testpts');
reftime = getappdata(handles.window,'reftime');
displaytime = strcmp(get(handles.DisplayDetailedTime,'Checked'),'on');

if ~isfield(testpts,'number') || isempty([testpts.number])
    beep; uiwait(errordlg('Não há pontos de ensaio definidos.','Erro','modal')); drawnow;
    return
end

if isempty(reftime)
    beep; uiwait(errordlg('O tempo de referência não está definido.','Erro','modal')); drawnow;
    return
end

tcol = findpar(PARAM,reftime,0,1);
if isempty(tcol)
    beep; uiwait(errordlg(['O tempo de referência ''' reftime ''' não foi encontrado.'],'Erro','modal')); drawnow;
    return
end

if size(testpts,2) == 1
    ngrp = 1;
else
    ngrp = inputvalue('Opção','Grupo de pontos:',{testpts.group},1,1.05); drawnow;
    if isempty(ngrp)
        return
    end
end

if isempty(testpts(ngrp).number)
    beep; uiwait(errordlg(['Não há pontos de ensaio definidos no grupo ''' testpts(ngrp).group '''.'],'Erro','modal')); drawnow;
    return
end

Nexc = [];
for n = 1:length(testpts(ngrp).param)
    if isempty(findpar(PARAM,testpts(ngrp).param{n},1,1)) && any(testpts(ngrp).data(n,:))
        Nexc = [Nexc n];
    end
end
if ~isempty(Nexc)
    if length(Nexc) == 1
        str = {'O seguinte parâmetro não foi encontrado:',' ',testpts(ngrp).param{Nexc},' ','Deseja prosseguir?'};
    elseif length(Nexc) <= 20
        str = {'Os seguintes parâmetros não foram encontrados:',' ',testpts(ngrp).param{Nexc},' ','Deseja prosseguir?'};
    else
        str = {[num2str(length(Nexc)) ' parâmetros não foram encontrados.'],' ','Deseja prosseguir?'};
    end
    str = [{['Grupo: ' testpts(ngrp).group '.']}, str];
    button = questdlg(str,'Confirmação','Sim','Não','Não'); drawnow;
    if ~strcmp(button,'Sim')
        return
    end
end

try
    
    set(handles.window,'Pointer','watch');
    
    % Criação dos cabeçalhos ------------------
    
    header = {'Pontos de Ensaio',''         ,'T Inicial','T Final','Duração','No. OBS.','Validade';...
            'Número'            ,'Descrição','(h:m:s)'  ,'(h:m:s)','(h:m:s)',''        ,'(%)'     };
    data = {'Média','DesvPad','Mínimo','Máximo','Amplitude','Valor Ini','Valor Fim','Variação','Validade','Tau (s)','Zeta','Wn (rad/s)','Derivada'};
    
    if ~displaytime
        header(2,[3 4 5]) = {'(s)','(s)','(s)'};
    end
    
    incheader = header(:,[1 find(testpts(ngrp).include)+1]);
    
    paramheader = {};
    if ~isempty(testpts(ngrp).param)
        ncol = 1;
        for npar = 1:length(testpts(ngrp).param)
            if any(testpts(ngrp).data(npar,:))
                paramheader{1,ncol} = testpts(ngrp).param{npar};
                for ndata = 1:13
                    if testpts(ngrp).data(npar,ndata)
                        paramheader{2,ncol} = data{ndata};
                        ncol = ncol+1;                    
                    end
                end
            end
        end
    end
    
    ptslist = testpts(ngrp).number';
    
    % Obtenção dos dados ----------------------
    
    T = DADOS(:,tcol);
    
    Npts = length(testpts(ngrp).number);
    Npar = length(testpts(ngrp).param);
    
    if any(testpts(ngrp).include)
        for npt = 1:Npts
            n = 1;
            for ninc = 1:6
                if testpts(ngrp).include(ninc);
                    switch ninc
                        case 1 % Descr
                            val = testpts(ngrp).descr{npt};
                        case 2 % Tini
                            if displaytime
                                val = ['''' time2str2(testpts(ngrp).time(1,npt))];
                            else
                                val = testpts(ngrp).time(1,npt);
                            end
                        case 3 % Tfim
                            if displaytime
                                val = ['''' time2str2(testpts(ngrp).time(2,npt))];
                            else
                                val = testpts(ngrp).time(2,npt);
                            end
                        case 4 % Duração
                            if displaytime
                                val = ['''' time2str2(diff(testpts(ngrp).time(:,npt)))];
                            else
                                val = diff(testpts(ngrp).time(:,npt));
                            end
                        case 5 % No. OBS.
                            if isnan(testpts(ngrp).time(2,npt)-testpts(ngrp).time(1,npt))
                                val = NaN;
                            else
                                val = length(GetIntervPts(T,testpts(ngrp).time(1,npt),testpts(ngrp).time(2,npt)));
                            end
                        case 6 % Validade
                            if ~Npar
                                val = NaN;
                            else
                                colpar = findpar(PARAM,testpts(ngrp).param,1,1);
                                if length(colpar) ~= Npar
                                    val = NaN;
                                else
                                    pts = GetIntervPts(T,testpts(ngrp).time(1,npt),testpts(ngrp).time(2,npt));
                                    if isempty(pts)
                                        val = NaN;
                                    else
                                        if testpts(ngrp).inisample == 0
                                            k = length(pts);
                                        else
                                            k = length(find((T(pts)-T(pts(1))<=testpts(ngrp).inisample)));
                                        end
                                        Dval = DADOS(pts,colpar);
                                        val = checkval(Dval,testpts(ngrp).aim(npt,:),testpts(ngrp).range1(npt,:),testpts(ngrp).range2(npt,:),testpts(ngrp).tol1(npt,:),testpts(ngrp).tol2(npt,:),k);
                                        if all(all(isnan(val)))
                                            val = NaN;
                                        else
                                            val(isnan(val)) = 1;
                                            if size(val,2) > 1
                                                val = prod(val,2);
                                            end
                                            val = 100 * length(find(val)) / length(pts);
                                        end
                                    end
                                end
                            end
                    end
                    Dinc{npt,n} = val;
                    n = n+1;
                end
            end
        end
    else
        Dinc = {};
    end
    
    D = [];
    for npar = 1:Npar
        colpar = findpar(PARAM,testpts(ngrp).param{npar},0,1);
        Dparam = [];
        for npt = 1:Npts
            if isempty(colpar)
                pts = [];
                Y = NaN;
            else
                if isnan(testpts(ngrp).time(2,npt)-testpts(ngrp).time(1,npt))
                    pts = [];
                    Y = NaN;
                else
                    pts = GetIntervPts(T,testpts(ngrp).time(1,npt),testpts(ngrp).time(2,npt));
                    Y = DADOS(pts,colpar);
                end
            end
            Ddata = [];
            if testpts(ngrp).data(npar,10)
                try
                    [yf, t, cfs, tau] = fit_1st_ord(T(pts),Y);
                catch
                    tau = NaN;
                end
            end
            if testpts(ngrp).data(npar,11) || testpts(ngrp).data(npar,12)
                try
                    [yf, t, cfs, zeta, wn] = fit_2nd_ord(T(pts),Y);
                catch
                    zeta = NaN;
                    wn   = NaN;
                end
            end
            for ndata = 1:13
                if testpts(ngrp).data(npar,ndata)
                    if isempty(pts) || isempty(Y)
                        val = NaN;
                    else
                        switch ndata
                            case 1 % Média
                                val = nanmean(Y);
                            case 2 % DesvPad
                                val = nanstd(Y);
                            case 3 % Mínimo
                                val = min(Y);
                            case 4 % Máximo
                                val = max(Y);
                            case 5 % Amplitude
                                val = range(Y);
                            case 6 % Valor Inicial
                                val = Y(1);
                            case 7 % Valor Final
                                val = Y(end);
                            case 8 % Variação
                                val = Y(end)-Y(1);
                            case 9 % Validade
                                if testpts(ngrp).inisample == 0
                                    k = length(pts);
                                else
                                    k = length(find((T(pts)-T(pts(1))<=testpts(ngrp).inisample)));
                                end
                                val = checkval(Y,testpts(ngrp).aim(npt,npar),testpts(ngrp).range1(npt,npar),testpts(ngrp).range2(npt,npar),testpts(ngrp).tol1(npt,npar),testpts(ngrp).tol2(npt,npar),k);
                                if isempty(pts) || all(isnan(val))
                                    val = NaN;
                                else
                                    val = 100 * length(find(val)) / length(pts);
                                end
                            case 10 % Tau
                                val = tau;
                            case 11 % Zeta
                                val = zeta;
                            case 12 % Wn
                                val = wn;
                            case 13 % Derivada media
                                try
                                    cfs = polyfit(T(pts)-T(pts(1)),denan(Y),1);
                                catch
                                    cfs = NaN;
                                end
                                val = cfs(1);
                        end
                    end
                    Ddata = [Ddata val];
                end
            end
            Dparam = [Dparam; Ddata];
        end
        D = [D Dparam];
    end
    
    D = num2cell(D);
    
    
    % Concatenação das partes -----------------
    
    DATA = [incheader paramheader; ptslist Dinc D];
    
    
    % Eliminação de celulas invalidas ---------
    
    [N,M] = size(DATA);
    for n = 1:N
        for m = 1:M
            if isempty(DATA{n,m})
                DATA{n,m} = '';
            elseif isnan(DATA{n,m})
                DATA{n,m} = 'NaN';
            end
        end
    end
    
    % Exportação da matriz --------------------
    
    if N > 65536
        beep; uiwait(errordlg({'Número de pontos incompatível.','Planilha Excel limitada a 65.536 linhas.'},'Erro','modal')); drawnow;
        return
    end
    if M > 256 
        beep; uiwait(errordlg({'Compilação de dados incompatível.','Planilha Excel limitada a 256 colunas.'},'Erro','modal')); drawnow;
        return
    end
    
    xlswrite(DATA);
    
catch
    beep; uiwait(errordlg(lasterr,'Erro','modal')); drawnow;
end

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function TestPts_GetFits_Callback(hObject, eventdata, handles)
global DADOS
% Obtem os dados de ajustes de curva dos pontos de ensaio

PARAM   = get(handles.xlist,'String');
testpts = getappdata(handles.window,'testpts');
reftime = getappdata(handles.window,'reftime');
displaytime = strcmp(get(handles.DisplayDetailedTime,'Checked'),'on');

if ~isfield(testpts,'number') || isempty([testpts.number])
    beep; uiwait(errordlg('Não há pontos de ensaio definidos.','Erro','modal')); drawnow;
    return
end

if isempty(reftime)
    beep; uiwait(errordlg('O tempo de referência não está definido.','Erro','modal')); drawnow;
    return
end

Nfit = 0;
if isfield(testpts,'fit')
    for ngrp = 1:size(testpts,2)
        if ~isempty(testpts(ngrp).fit)
            Nfit = Nfit + length(find(testpts(ngrp).fit(:,1))) .* length(testpts(ngrp).number);
        end
    end
end
if ~Nfit
    beep; uiwait(errordlg('Não há ajustes de curva definidos.','Erro','modal')); drawnow;
    return
end

if isempty(reftime)
    beep; uiwait(errordlg('O tempo de referência não está definido.','Erro','modal')); drawnow;
    return
end
tcol = findpar(PARAM,reftime,0,1);
if isempty(tcol)
    beep; uiwait(errordlg(['O tempo de referência ''' reftime ''' não foi encontrado.'],'Erro','modal')); drawnow;
    return
end

if size(testpts,2) == 1
    ngrp = 1;
else
    ngrp = inputvalue('Opção','Grupo de pontos:',{testpts.group},1,1.05); drawnow;
    if isempty(ngrp)
        return
    end
end

if isempty(testpts(ngrp).number)
    beep; uiwait(errordlg(['Não há pontos de ensaio definidos no grupo ''' testpts(ngrp).group '''.'],'Erro','modal')); drawnow;
    return
end

Nexc = [];
for n = 1:length(testpts(ngrp).param)
    if isempty(findpar(PARAM,testpts(ngrp).param{n},1,1)) && testpts(ngrp).fit(n,1)
        Nexc = [Nexc n];
    end
end
if ~isempty(Nexc)
    if length(Nexc) == 1
        str = {'O seguinte parâmetro não foi encontrado:',' ',testpts(ngrp).param{Nexc},' ','Deseja prosseguir?'};
    elseif length(Nexc) <= 20
        str = {'Os seguintes parâmetros não foram encontrados:',' ',testpts(ngrp).param{Nexc},' ','Deseja prosseguir?'};
    else
        str = {[num2str(length(Nexc)) ' parâmetros não foram encontrados.'],' ','Deseja prosseguir?'};
    end
    str = [{['Grupo: ' testpts(ngrp).group '.']}, str];
    button = questdlg(str,'Confirmação','Sim','Não','Não'); drawnow;
    if ~strcmp(button,'Sim')
        return
    end
end

try
    
    set(handles.window,'Pointer','watch');
    
    % Criação dos cabeçalhos ------------------
    
    header = {'Pontos de Ensaio',''         ,'T Inicial','T Final','Duração','No. OBS.','Validade';...
            'Número'            ,'Descrição','(h:m:s)'  ,'(h:m:s)','(h:m:s)',''        ,'(%)'     };
    data = {'t0','DOF','NormRes','SSE','RMS','DesvPad','Adj-R2'};
    types = {'Linear','Quadrático','Cúbico','de 4° grau','de 5° grau','de 6° grau','de Primeira Ordem','de Segunda Ordem'};
    
    if ~displaytime
        header(2,[3 4 5]) = {'(s)','(s)','(s)'};
    end
    
    testpts(ngrp).include(6) = 0;
    incheader = header(:,[1 find(testpts(ngrp).include)+1]);
    
    paramheader = {};
    if ~isempty(testpts(ngrp).param)
        ncol = 1;
        for npar = 1:length(testpts(ngrp).param)
            ord = testpts(ngrp).fit(npar,1);
            if ord
                paramheader{1,ncol} = [testpts(ngrp).param{npar} ' - Ajuste ' types{ord}];
                if ord <= 6 % Poly
                    for n = ord:-1:0
                        paramheader{2,ncol} = ['c' num2str(n)];
                        ncol = ncol+1;
                    end
                elseif ord == 7 % 1st order
                    paramheader(2,ncol:ncol+2) = {'a','b','c'};
                    ncol = ncol+3;
                else % 2nd order
                    paramheader(2,ncol:ncol+5) = {'a','b','c','d','e','f'};
                    ncol = ncol+6;
                end
            end
            for n = 1:7
                if testpts(ngrp).fit(npar,n+1)
                    paramheader{2,ncol} = data{n};
                    ncol = ncol+1;
                end
            end
        end
    end
    
    ptslist = testpts(ngrp).number';
    
    % Obtenção dos dados ----------------------
    
    T = DADOS(:,tcol);
    
    Npts = length(testpts(ngrp).number);
    Npar = length(testpts(ngrp).param);
    
    if any(testpts(ngrp).include)
        for npt = 1:Npts
            n = 1;
            for ninc = 1:6
                if testpts(ngrp).include(ninc);
                    switch ninc
                        case 1 % Descr
                            val = testpts(ngrp).descr{npt};
                        case 2 % Tini
                            if displaytime
                                val = ['''' time2str2(testpts(ngrp).time(1,npt))];
                            else
                                val = testpts(ngrp).time(1,npt);
                            end
                        case 3 % Tfim
                            if displaytime
                                val = ['''' time2str2(testpts(ngrp).time(2,npt))];
                            else
                                val = testpts(ngrp).time(2,npt);
                            end
                        case 4 % Duração
                            if displaytime
                                val = ['''' time2str2(diff(testpts(ngrp).time(:,npt)))];
                            else
                                val = diff(testpts(ngrp).time(:,npt));
                            end
                        case 5 % No. OBS.
                            if isnan(testpts(ngrp).time(2,npt)-testpts(ngrp).time(1,npt))
                                val = NaN;
                            else
                                val = length(GetIntervPts(T,testpts(ngrp).time(1,npt),testpts(ngrp).time(2,npt)));
                            end
                    end
                    Dinc{npt,n} = val;
                    n = n+1;
                end
            end
        end
    else
        Dinc = {};
    end
    
    D = [];
    for npar = 1:Npar
        colpar = findpar(PARAM,testpts(ngrp).param{npar},0,1);
        Dfit = [];
        for npt = 1:Npts
            if isempty(colpar)
                pts = [];
                Y = NaN;
            else
                if isnan(testpts(ngrp).time(2,npt)-testpts(ngrp).time(1,npt))
                    pts = [];
                    Y = NaN;
                else
                    pts = GetIntervPts(T,testpts(ngrp).time(1,npt),testpts(ngrp).time(2,npt));
                    Y = DADOS(pts,colpar);
                end
            end
            
            ord = testpts(ngrp).fit(npar,1);
            if ord
                if testpts(ngrp).fit(npar,2)
                    if ~isempty(pts)
                        t0 = T(pts(1));
                    else
                        t0 = NaN;
                    end
                else
                    t0 = 0;
                end
                if ord <= 6 % Poly
                    if isempty(pts)
                        cfs = NaN*ones(1,ord+1);
                        Yf = NaN*Y;
                    else
                        try
                            cfs = polyfit(T(pts)-t0,Y,ord);
                            Yf  = polyval(cfs,T(pts)-t0);
                        catch
                            cfs = NaN*ones(1,ord+1);
                            Yf = NaN*Y;
                        end
                    end
                elseif ord == 7 % 1st order
                    if isempty(pts)
                        cfs = NaN*ones(1,3);
                        Yf = NaN*Y;
                    else
                        try
                            [Yf, t, cfs] = fit_1st_ord(T(pts),Y);
                        catch
                            cfs = NaN*ones(1,3);
                            Yf = NaN*Y;
                        end
                    end
                else % 2nd order
                    if isempty(pts)
                        cfs = NaN*ones(1,6);
                        Yf = NaN*Y;
                    else
                        try
                            [Yf, t, cfs] = fit_2nd_ord(T(pts),Y);
                        catch
                            cfs = NaN*ones(1,6);
                            Yf = NaN*Y;
                        end
                    end
                end
                S = goodnessfit(Y, Yf, length(cfs));
                stat = [];
                for n = 1:7
                    if testpts(ngrp).fit(npar,n+1);
                        switch n
                            case 1 % t0
                                val = t0;
                            case 2 % DOF
                                val = S.v;
                            case 3 % NormRes
                                val = S.normres;
                            case 4 % SSE
                                val = S.SSE;
                            case 5 % RMSE
                                val = S.RMSE;
                            case 6 % STDE
                                val = S.STDE;
                            case 7 % Adj-R2
                                val = S.adjR2;
                        end
                        stat = [stat val];
                    end
                end
            else
                cfs = [];
                stat = [];
            end
            Dfit = [Dfit; [cfs, stat]];
        end
        D = [D Dfit];
    end
    
    D = num2cell(D);
    
    
    % Concatenação das partes -----------------
    
    DATA = [incheader paramheader; ptslist Dinc D];
    
    
    % Eliminação de celulas invalidas ---------
    
    [N,M] = size(DATA);
    for n = 1:N
        for m = 1:M
            if isempty(DATA{n,m})
                DATA{n,m} = '';
            elseif isnan(DATA{n,m})
                DATA{n,m} = 'NaN';
            end
        end
    end
    
    % Exportação da matriz --------------------
    
    if N > 65536
        beep; uiwait(errordlg({'Número de pontos incompatível.','Planilha Excel limitada a 65.536 linhas.'},'Erro','modal')); drawnow;
        return
    end
    if M > 256 
        beep; uiwait(errordlg({'Dados de ajustes incompatíveis.','Planilha Excel limitada a 256 colunas.'},'Erro','modal')); drawnow;
        return
    end
    
    xlswrite(DATA);
    
catch
    beep; uiwait(errordlg(lasterr,'Erro','modal')); drawnow;
end

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function TestPts_GetDataTable_Callback(hObject, eventdata, handles)
global DADOS
% Obtem os dados relevantes dos pontos de ensaio em forma de tabela

PARAM   = get(handles.xlist,'String');
testpts = getappdata(handles.window,'testpts');
reftime = getappdata(handles.window,'reftime');

seplist = [abs(' ') 9 abs(',') abs(';')];
preclist = cellstr(num2str((16:-1:1)'));
paramlist = 1:length(PARAM);

if ~isfield(testpts,'number') || isempty([testpts.number])
    beep; uiwait(errordlg('Não há pontos de ensaio definidos.','Erro','modal')); drawnow;
    return
end

if isempty(reftime)
    beep; uiwait(errordlg('O tempo de referência não está definido.','Erro','modal')); drawnow;
    return
end

tcol = findpar(PARAM,reftime,0,1);
if isempty(tcol)
    beep; uiwait(errordlg(['O tempo de referência ''' reftime ''' não foi encontrado.'],'Erro','modal')); drawnow;
    return
end

if size(testpts,2) == 1
    grouplist = {testpts.group};
else
    grouplist = [{'Todos'} {testpts.group}];
end

[ndatatype, ngrp, nfileformat, nsep, nprec, igrp, inum, idescr, iheader, paramlist] = RDAT_TestPointsData(grouplist,PARAM,paramlist); drawnow;

if isempty(ndatatype)
    return
end

if isempty(paramlist)
    beep; uiwait(errordlg({'Nenhum parâmetro selecionado.'},'Erro','modal')); drawnow;
    return
end

set(handles.window,'Pointer','watch');

if ngrp == 0
    testptslist.number = [testpts.number];
    testptslist.descr  = [testpts.descr];
    testptslist.time   = [testpts.time];
    for n = 1:size(testpts,2)
        n2(n) = length(testpts(n).number);
    end
    ini = cumsum(n2)-n2+1;
    fin = cumsum(n2);
    for n = 1:size(testpts,2)
        testptslist.group(ini(n):fin(n)) = {testpts(n).group};
    end
else
    testptslist.number = testpts(ngrp).number;
    testptslist.descr  = testpts(ngrp).descr;
    testptslist.time   = testpts(ngrp).time;
    testptslist.group(1:length(testpts(ngrp).number)) = {testpts(ngrp).group};
end

Npts = length(testptslist.number);
Npar = length(paramlist);

if ~Npts
    beep; uiwait(errordlg(['Não há pontos de ensaio definidos no grupo ''' testpts(ngrp).group '''.'],'Erro','modal')); drawnow;
    return
end

if nfileformat == 1 % xls
    if Npar + igrp + inum + idescr > 256
        beep; uiwait(errordlg({'Número de parâmetros incompatível.','Planilha Excel limitada a 256 colunas.'},'Erro','modal')); drawnow;
        return
    end
    if Npts + 2*iheader > 65536
        beep; uiwait(errordlg({'Número de pontos incompatível.','Planilha Excel limitada a 65.536 linhas.'},'Erro','modal')); drawnow;
        return
    end
end

% Criação dos cabeçalhos ------------------

PARAM = PARAM(paramlist);

if idescr
    PARAM = [{'Descrição'}; PARAM];
    descrlist = testptslist.descr';
else
    descrlist = [];
end
if inum
    PARAM = [{'Ponto'}; PARAM];
    ptslist = testptslist.number';
else
    ptslist = [];
end
if igrp
    PARAM = [{'Grupo'}; PARAM];
    grouplist = testptslist.group';
else
    grouplist = [];
end

if iheader
    [PARAM, UNITS] = SplitParamUnits(denumber(PARAM));
    parnames  = PARAM';
    unitnames = UNITS';
else
    parnames  = [];
    unitnames = [];
end

if nfileformat == 2 % txt
    
    sep = char(seplist(nsep));
    
    if ~isempty(char(unitnames))
        for n = 1:length(unitnames)
            unitnames{n} = ['[' unitnames{n} ']'];
            unitnames{n}(unitnames{n}==sep) = '_';
        end
    else
        unitnames = [];
    end
    for n = 1:length(parnames)
        parnames{n}(parnames{n}==sep) = '_';
    end
    for n = 1:length(descrlist)
        descrlist{n}(descrlist{n}==sep) = '_';
    end
    for n = 1:length(ptslist)
        ptslist{n}(ptslist{n}==sep) = '_';
    end
    for n = 1:length(grouplist)
        grouplist{n}(grouplist{n}==sep) = '_';
    end
end

% Obtenção dos dados ----------------------

T = DADOS(:,tcol);

Ddat = [];
for npt = 1:Npts
    if isnan(testptslist.time(2,npt)-testptslist.time(1,npt))
        Dpt = NaN;
    else
        pts = GetIntervPts(T,testptslist.time(1,npt),testptslist.time(2,npt));
        Dpt = DADOS(pts,paramlist);
    end
    
    if isempty(Dpt) || all(all(isnan(Dpt)))
        Dline = NaN*ones(1,Npar);
    else
        switch ndatatype
            case 1 % Média
                Dline = nanmean(Dpt);
            case 2 % DesvPad
                Dline = nanstd(Dpt);
            case 3 % Mínimo
                Dline = min(Dpt);
            case 4 % Máximo
                Dline = max(Dpt);
            case 5 % Amplitude
                Dline = range(Dpt);
            case 6 % Valor Inicial
                Dline = Dpt(1,:);
            case 7 % Valor Final
                Dline = Dpt(end,:);
            case 8 % Variação
                Dline = Dpt(end,:) - Dpt(1,:);
            case 9 % No. de NaNs
                Dline = sum(isnan(Dpt));
            case 10 % Derivada média
                t = T(pts);
                for n = 1:Npar
                    try
                        cfs = polyfit(t-t(1),denan(Dpt(:,n)),1);
                    catch
                        cfs = NaN;
                    end
                    Dline(1,n) = cfs(1);
                end
        end
    end
    Ddat = [Ddat; Dline];
end

Dcell = num2cell(Ddat);

% Concatenação das partes -----------------

DATA = [parnames; unitnames; grouplist ptslist descrlist Dcell];

% Eliminação de celulas invalidas ---------

[N,M] = size(DATA);
for n = 1:N
    for m = 1:M
        if isempty(DATA{n,m})
            DATA{n,m} = '';
        elseif isnan(DATA{n,m})
            DATA{n,m} = 'NaN';
        end
    end
end

% Exportação da matriz --------------------

sep = char(seplist(nsep));
p   = str2double(preclist(nprec));

fnames = {'Médias','Desvios padrão','Valores mínimos','Valores máximos','Amplitudes','Valores iniciais',...
        'Valores finais','Variações','Números de NaNs','Derivadas médias'};
fexts     = {'.xls','.txt','.dat','.mat'};
fname = fnames{ndatatype};
fext  = fexts{nfileformat};

switch nfileformat
    
    case 1 % xls
        try
            xlswrite(DATA);
        catch
            beep; uiwait(errordlg({'Não foi possível exportar para o MS Excel.',...
                    'Verifique se o programa está instalado',...
                    'e funcionando corretamente no Windows.'},'Erro','modal')); drawnow;
        end
        
    case {2,3} % txt / dat
        
        DATA = cell2str(DATA,p,1,sep);
        
        if exist([handles.fpath fname fext],'file');
            n = 1;
            fname = [fname '(' num2str(n) ')'];
            while exist([handles.fpath fname fext],'file');
                n = n+1;
                fname = [fname(1:end-2-length(num2str(n-1))) '(' num2str(n) ')'];
            end
        end
        
        err = 0;
        try
            strwrite([handles.fpath fname fext],DATA,0);
            try
                dos(['notepad ' handles.fpath fname fext]);
            catch
                err = 1;
            end
            delete([handles.fpath fname fext]);
        catch
            err = 1;
        end
        if err
            beep; uiwait(errordlg({'Não foi possível exportar para o Notepad.',...
                    'Verifique se o programa está instalado',...
                    'e funcionando corretamente no Windows.'},'Erro','modal')); drawnow;
        end
        
    case 4 % mat
        
        [fname2,fpath] = uiputfile({'*.mat','Arquivo mat (*.mat)'},['Salvar matriz de ' lower(fname)], handles.fpath); drawnow;
        if ischar(fname2)
            set(handles.window,'Pointer','watch');
            
            PARAM = char(SetParamFormat(PARAM,handles.maxparamlength));
            
            if inum
                Ddat = [(1:Npts)' Ddat];
            end
            
            try
                AuxSaveSlice([fpath fname2],Ddat,PARAM);
            catch
                beep; uiwait(errordlg(lasterr,'Erro','modal')); drawnow;
                return
            end
            
            NewEvent(handles,['Arquivo de ' lower(fname) ' dos pontos de ensaio salvo.']);
            
        end
end

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function Events_Editor_Callback(hObject, eventdata, handles)
global DADOS
% Abre janela de edição de eventos

if isempty(DADOS)
    return
end

PARAM   = get(handles.xlist,'String');
events  = getappdata(handles.window,'events');
reftime = getappdata(handles.window,'reftime');

togglelist = setdiff(findobj(handles.window,'Enable','on'),findobj(handles.window,'Style','text'));
set(togglelist,'Enable','off');
UpdateButtonStatus(hObject, eventdata, handles);

[events, reftime] = RDAT_EditEvents(events,PARAM,reftime); drawnow;

set(togglelist,'Enable','on');
UpdateButtonStatus(hObject, eventdata, handles);

if ~isempty(events) || ~isempty(reftime)
    check_reftime(PARAM,reftime);
    setappdata(handles.window,'events',events);
    setappdata(handles.window,'reftime',reftime);
    set(handles.ShowEvents,'Checked','on');
    set(handles.Events_btn,'Value',1);
    UpdateEvents(hObject, eventdata, handles, 1);
    UpdateTestPoints(hObject, eventdata, handles);
    UpdateTimeCols(hObject, eventdata, handles);
    
    setappdata(handles.window,'change',1);
    NewEvent(handles,'Lista de eventos alterada.');
end

% --------------------------------------------------------------------
function Events_DefineSelection_Callback(hObject, eventdata, handles)
global DADOS
% Define os pontos selecionados como eventos

PARAM   = get(handles.xlist,'String');
events  = getappdata(handles.window,'events');
reftime = getappdata(handles.window,'reftime');
sel     = getappdata(handles.window,'sel');

if isempty(sel)
    beep; uiwait(errordlg('Não há pontos selecionados.','Erro','modal')); drawnow;
    return
elseif length(sel) > 50
    beep; uiwait(errordlg({['Há ' num2str(length(sel)) ' pontos selecionados.'],...
            'Só é possível definir até 50 eventos por vez.'},'Erro','modal')); drawnow;
    return
end

nreftime = findpar(PARAM,reftime,0,1);
if isempty(nreftime)
    nreftime = inputvalue('Definir','Tempo de referência:',PARAM,1,1.35); drawnow;
    if isempty(nreftime)
        return
    else
        [ok, ndc, nna] = IsTimeOk(DADOS(:,nreftime));
        if ~ok
            beep; uiwait(errordlg({'Parâmetro de tempo não é adequado:',' ',...
                    ['Pontos inválidos: ' num2str(length(nna))],...
                    ['Pontos não crescentes: ' num2str(length(ndc))]},'Erro','modal')); drawnow;
            return
        else            
            reftime = denumber(PARAM{nreftime});
            setappdata(handles.window,'reftime',reftime);
            UpdateTimeCols(hObject, eventdata, handles);
            UpdateTestPoints(hObject, eventdata, handles, 1);
            
            setappdata(handles.window,'change',1);
            NewEvent(handles,['Tempo de referência definido: ''' reftime '''.']);
        end
    end
end

if length(sel) == 1
    str = 'Deseja definir o ponto selecionado como evento?';
else
    str = ['Deseja definir ' num2str(length(sel)) ' pontos selecionados como eventos?'];
end

button = questdlg(str,'Confirmação','Sim','Não','Não'); drawnow;
if ~strcmp(button,'Sim')
    return
end

n0 = size(events,1);
for n = n0:-1:1
    if isnan(events{n,2}) && isempty(deblank(events{n,3}))
        n0 = n-1;
    else
        break
    end
end

if ~isempty(events)
    
    timelist1 = cell2mat(events(:,2));
    timelist2 = DADOS(sel,nreftime);
    
    [rep, i1, i2] = intersect(timelist1,timelist2);
    
    if ~isempty(rep)
        if length(rep) == 1
            if length(sel) == 1
                str1 = 'O ponto selecionado já está definido como evento.';
            else
                str1 = 'Um dos pontos selecionados já está definido como evento.';
            end
        else
            if length(rep) == length(sel)
                str1 = ['Todos os ' num2str(length(rep)) ' pontos selecionados já estão definidos como eventos.'];
            else
                str1 = [num2str(length(rep)) ' pontos selecionados já estão definidos como eventos.'];
            end
        end
        if length(rep) == 1
            str2 = 'Deseja ignorá-lo?';
        else
            str2 = 'Deseja ignorá-los?';
        end
        button = questdlg({str1,str2},'Confirmação','Sim','Não','Não'); drawnow;
        if strcmp(button,'Sim')
            sel(i2) = [];
        end
        if isempty(sel)
            return
        end
    end
end

for n = 1:length(sel)
    events{n0+n,1} = 1;
    events{n0+n,2} = DADOS(sel(n),nreftime);
    events{n0+n,3} = '';
end

setappdata(handles.window,'events',events);
set(handles.ShowEvents,'Checked','on');
set(handles.Events_btn,'Value',1);
UpdateEvents(hObject, eventdata, handles, 1);
setappdata(handles.window,'change',1);

if length(sel) == 1
    str = '1 ponto selecionado definido como evento.';
else
    str = [num2str(length(sel)) ' pontos selecionados definidos como eventos.'];
end
NewEvent(handles,str);

pause(.6);
DeselectAll_Callback(hObject, eventdata, handles);

% --------------------------------------------------------------------
function Events_Offset_Callback(hObject, eventdata, handles)
% Desloca os eventos no tempo (aplica offset)

events = getappdata(handles.window,'events');

if isempty(events)
    beep; uiwait(errordlg('Não há eventos definidos.','Erro','modal')); drawnow;
    return
end

dts = inputvalue('Deslocar eventos','Variação:','00:00:00',1,1.1); drawnow;

if isempty(dts)
    return
end

[dt, str] = str2time(dts);

if isnan(dt)
    beep; uiwait(errordlg(['Valor de tempo incoerente: ' dts],'Erro','modal')); drawnow;
    return
end

if dt
    button = questdlg(['Deseja deslocar todos os eventos em ' str ' h?'],'Confirmação','Sim','Não','Não'); drawnow;
    if strcmp(button,'Sim')
        for n = 1:size(events,1)
            events{n,2} = events{n,2} + dt;
        end
        setappdata(handles.window,'events',events);
        UpdateEvents(hObject, eventdata, handles);
        setappdata(handles.window,'change',1);
        NewEvent(handles,['Eventos deslocados ' str ' h no tempo.']);
    end
end

% --------------------------------------------------------------------
function Events_GetData_Callback(hObject, eventdata, handles)
global DADOS
% Obtem os dados dos eventos em forma de tabela

PARAM   = get(handles.xlist,'String');
events  = getappdata(handles.window,'events');
reftime = getappdata(handles.window,'reftime');

seplist   = [abs(' ') 9 abs(',') abs(';')];
preclist  = cellstr(num2str((16:-1:1)'));
paramlist = 1:length(PARAM);

if isempty(events)
    beep; uiwait(errordlg('Não há eventos definidos.','Erro','modal')); drawnow;
    return
end

if isempty(reftime)
    beep; uiwait(errordlg('O tempo de referência não está definido.','Erro','modal')); drawnow;
    return
end

tcol = findpar(PARAM,reftime,0,1);
if isempty(tcol)
    beep; uiwait(errordlg(['O tempo de referência ''' reftime ''' não foi encontrado.'],'Erro','modal')); drawnow;
    return
end

[nfileformat, nmethod, ninv, nsep, nprec, ival, inum, itime, idescr, iheader, paramlist] = RDAT_EventsData(PARAM,paramlist); drawnow;

if isempty(nfileformat)
    return
end

if isempty(paramlist)
    beep; uiwait(errordlg({'Nenhum parâmetro selecionado.'},'Erro','modal')); drawnow;
    return
end

set(handles.window,'Pointer','watch');

T = DADOS(:,tcol);

Npts = size(events,1);
Npar = length(paramlist);

if nfileformat == 1 % xls
    if Npar + ival + inum + idescr > 256 
        beep; uiwait(errordlg({'Número de parâmetros incompatível.','Planilha Excel limitada a 256 colunas.'},'Erro','modal')); drawnow;
        return
    end
    if (ninv ~= 2 && Npts + 2*iheader > 65536 ) || (ninv == 2 && Npts*length(find([events{:,1}])) + 2*iheader > 65536 )
        beep; uiwait(errordlg({'Número de eventos incompatível.','Planilha Excel limitada a 65.536 linhas.'},'Erro','modal')); drawnow;
        return
    end
end

% Criação dos cabeçalhos ------------------

PARAM = PARAM(paramlist);

if idescr
    PARAM = [{'Descrição'}; PARAM];
    descrlist = events(:,3);
else
    descrlist = [];
end
if itime
    PARAM = [{'Tempo'}; PARAM];
    for n = 1:Npts
        timelist{n,1} = time2str2(events{n,2});
    end
else
    timelist = [];
end
if inum
    PARAM = [{'Evento'}; PARAM];
    ptslist = num2cell(1:Npts)';
else
    ptslist = [];
end
if ival
    PARAM = [{'Validade'}; PARAM];
    vallist = num2cell([events{:,1}])';
else
    vallist = [];
end

if iheader
    [PARAM, UNITS] = SplitParamUnits(denumber(PARAM));
    parnames  = PARAM';
    unitnames = UNITS';
else
    parnames  = [];
    unitnames = [];
end

if nfileformat == 2 % txt
    
    sep = char(seplist(nsep));
    
    if ~isempty(char(unitnames))
        for n = 1:length(unitnames)
            unitnames{n} = ['[' unitnames{n} ']'];
            unitnames{n}(unitnames{n}==sep) = '_';
        end
    else
        unitnames = [];
    end
    for n = 1:length(parnames)
        parnames{n}(parnames{n}==sep) = '_';
    end
    for n = 1:length(descrlist)
        if isempty(descrlist{n})
            descrlist{n} = '-';
        else
            descrlist{n}(descrlist{n}==sep) = '_';
        end
    end
    for n = 1:length(timelist)
        if isempty(timelist{n})
            timelist{n} = '-';
        end
    end
end

% Obtenção dos dados ----------------------

methodlist = {'linear','nearest','spline','cubic'};
method = methodlist{nmethod};

if ninv == 3
    for n = 1:Npts
        if  events{n,1}
            evt(n,1) = events{n,2};
        else
            evt(n,1) = NaN;
        end
    end
else
    evt = [events{:,2}]';
end

try
    Edat = interp1(T, DADOS(:,paramlist), evt, method, NaN);
catch
    Edat = NaN*ones(length(evt),Npar);
end

if nmethod == 2
    nnan = find(isnan(evt));
    if ~isempty(nnan)
        Edat(nnan,:) = NaN;
    end
end

Dcell = num2cell(Edat);

% Exclusao dos eventos invalidos ----------

exc = ~[events{:,1}];

if ninv == 2 && any(exc)
    if length(find(exc)) == Npts
        beep; uiwait(errordlg('Não há eventos válidos.','Erro','modal')); drawnow;
        return
    else
        if inum,   ptslist(exc)   = []; end
        if itime,  timelist(exc)  = []; end
        if idescr, descrlist(exc) = []; end
        Dcell(exc,:)   = [];
    end
end

% Concatenação das partes -----------------

DATA = [parnames; unitnames; vallist ptslist timelist descrlist Dcell];

% Eliminação de celulas invalidas ---------

[N,M] = size(DATA);
for n = 1:N
    for m = 1:M
        if isempty(DATA{n,m})
            DATA{n,m} = '';
        elseif isnan(DATA{n,m})
            DATA{n,m} = 'NaN';
        end
    end
end

% Exportação da matriz --------------------

sep = char(seplist(nsep));
p   = str2double(preclist(nprec));

fexts = {'.xls','.txt','.dat','.mat'};
fname = 'Dados dos eventos';
fext  = fexts{nfileformat};

switch nfileformat
    
    case 1 % xls
        try
            xlswrite(DATA);
        catch
            beep; uiwait(errordlg({'Não foi possível exportar para o MS Excel.',...
                    'Verifique se o programa está instalado',...
                    'e funcionando corretamente no Windows.'},'Erro','modal')); drawnow;
        end
        
    case {2,3} % txt / dat
        
        DATA = cell2str(DATA,p,1,sep);
        
        if exist([handles.fpath fname fext],'file');
            n = 1;
            fname = [fname '(' num2str(n) ')'];
            while exist([handles.fpath fname fext],'file');
                n = n+1;
                fname = [fname(1:end-2-length(num2str(n-1))) '(' num2str(n) ')'];
            end
        end
        
        err = 0;
        try
            strwrite([handles.fpath fname fext],DATA,0);
            try
                dos(['notepad ' handles.fpath fname fext]);
            catch
                err = 1;
            end
            delete([handles.fpath fname fext]);
        catch
            err = 1;
        end
        if err
            beep; uiwait(errordlg({'Não foi possível exportar para o Notepad.',...
                    'Verifique se o programa está instalado',...
                    'e funcionando corretamente no Windows.'},'Erro','modal')); drawnow;
        end
        
    case 4 % mat
        
        [fname2,fpath] = uiputfile({'*.mat','Arquivo mat (*.mat)'},'Salvar matriz de dados dos eventos', handles.fpath); drawnow;
        if ischar(fname2)
            set(handles.window,'Pointer','watch');
            
            PARAM = char(SetParamFormat(PARAM,handles.maxparamlength));
            
            if inum
                Edat = [(1:Npts)' Edat];
            end
            
            try
                AuxSaveSlice([fpath fname2],Edat,PARAM);
            catch
                beep; uiwait(errordlg(lasterr,'Erro','modal')); drawnow;
                return
            end
            
            NewEvent(handles,'Arquivo de dados dos eventos salvo.');
            
        end
end

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function Top2Event_Callback(hObject, eventdata, handles)
global DADOS
% Converter parâmetro de TOP em eventos

PARAM   = get(handles.xlist,'String');
xcol    = get(handles.xlist,'Value');
events  = getappdata(handles.window,'events');
reftime = getappdata(handles.window,'reftime');
topcols = findTOPpar(PARAM);

if isempty(topcols)
    beep; uiwait(errordlg('Não foram encontrados parâmetros de TOP.','Erro','modal')); drawnow;
    return
end

if length(topcols) > 1
    ntop = inputvalue('Opção','Parâmetro TOP:',PARAM(topcols),1,1.2); drawnow;
    if isempty(ntop)
        return
    end
else
    ntop = 1;
end
set(handles.ylist,'Value',topcols(ntop));
ylist_Callback(hObject, eventdata, handles);

nreftime = findpar(PARAM,reftime,0,1);
if isempty(nreftime)
    nreftime = inputvalue('Definir','Tempo de referência:',PARAM,1,1.35); drawnow;
    if isempty(nreftime)
        return
    else
        [ok, ndc, nna] = IsTimeOk(DADOS(:,nreftime));
        if ~ok
            beep; uiwait(errordlg({'Parâmetro de tempo não é adequado:',' ',...
                    ['Pontos inválidos: ' num2str(length(nna))],...
                    ['Pontos não crescentes: ' num2str(length(ndc))]},'Erro','modal')); drawnow;
            return
        else            
            reftime = denumber(PARAM{nreftime});
            setappdata(handles.window,'reftime',reftime);
            UpdateTimeCols(hObject, eventdata, handles);
            UpdateTestPoints(hObject, eventdata, handles, 1);
            
            setappdata(handles.window,'change',1);
            NewEvent(handles,['Tempo de referência definido: ''' reftime '''.']);
        end
    end
end

if xcol ~= nreftime
    set(handles.xlist,'Value',nreftime);
    xlist_Callback(hObject, eventdata, handles);
    pause(.3);
end

[tops, ntops, err] = getTOPs(DADOS(:,topcols(ntop)));

if isempty(tops)
    beep; uiwait(errordlg(err,'Erro','modal')); drawnow;
    return
end

nev = 0;
if ~isempty(events)
    for n = 1:size(events,1)
        if ~isnan(events{n,2}) || ~isempty(deblank(events{n,3}))
            nev = nev+1;
        end
    end
end

if nev
    if nev == 1
        str = 'Há 1 evento definido que será perdido.';
    else
        str = ['Há ' num2str(nev) ' eventos definidos que serão perdidos.'];
    end
    button = questdlg({str,'Deseja prosseguir?'},'Confirmação','Sim','Não','Não'); drawnow;
else
    button = questdlg({['TOPs encontrados: ' num2str(length(tops))],'Deseja prosseguir?'},...
        'Confirmação','Sim','Não','Sim'); drawnow;
end
if ~strcmp(button,'Sim');
    return
end

set(handles.window,'Pointer','watch');

T = DADOS(:,nreftime);
N = max(tops);
events = [num2cell(zeros(N,1)), num2cell(NaN*ones(N,1)), cellstr(char(zeros(N,1)))];

for n = 1:length(ntops)
    events(tops(n),:) = {1,mean(T(ntops(n)-1:ntops(n))),''};
end

setappdata(handles.window,'events',events);
set(handles.ShowEvents,'Checked','on');
set(handles.Events_btn,'Value',1);
UpdateEvents(hObject, eventdata, handles, 1);

setappdata(handles.window,'change',1);
NewEvent(handles,'Parâmetro de TOPs convertido em eventos.');

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function Event2Top_Callback(hObject, eventdata, handles)
global DADOS
% Converter eventos em parâmetro de TOP

PARAM   = get(handles.xlist,'String');
xcol    = get(handles.xlist,'Value');
events  = getappdata(handles.window,'events');
reftime = getappdata(handles.window,'reftime');
func    = getappdata(handles.window,'func');
cancel  = getappdata(handles.window,'cancel');

if strcmp(func,'none') && ~cancel
    
    if isempty(events)
        beep; uiwait(errordlg('Não há eventos definidos.','Erro','modal')); drawnow;
        return
    end
    
    nreftime = findpar(PARAM,reftime,0,1);
    if isempty(nreftime)
        nreftime = inputvalue('Definir','Tempo de referência:',PARAM,1,1.35); drawnow;
        if isempty(nreftime)
            return
        else
            [ok, ndc, nna] = IsTimeOk(DADOS(:,nreftime));
            if ~ok
                beep; uiwait(errordlg({'Parâmetro de tempo não é adequado:',' ',...
                        ['Pontos inválidos: ' num2str(length(nna))],...
                        ['Pontos não crescentes: ' num2str(length(ndc))]},'Erro','modal')); drawnow;
                return
            else            
                reftime = denumber(PARAM{nreftime});
                setappdata(handles.window,'reftime',reftime);
                UpdateTimeCols(hObject, eventdata, handles);
                
                setappdata(handles.window,'change',1);
                NewEvent(handles,['Tempo de referência definido: ''' reftime '''.']);
            end
        end
    end
    
    tev = [events{:,2}]';
    if diff(denan(tev,1))<0
        beep; uiwait(errordlg({'Para criação do parâmetro de TOPs os',...
                'eventos devem estar em ordem cronológica.'},'Erro','modal')); drawnow;
        return
    end
    
    set(handles.window,'Pointer','watch');
    
    T = DADOS(:,nreftime);
    
    TOP = zeros(size(T));
    
    for n = 1:length(tev)
        if ~isnan(tev(n)) && tev(n) > min(T)
            TOP(T>=tev(n)) = n;
        end
    end
    
    set(handles.xlist,'Value',length(PARAM));
    xlist_Callback(hObject, eventdata, handles);
    set([handles.menulist handles.xlist handles.ylist],'Enable','off');
    UpdateButtonStatus(hObject, eventdata, handles);
    
    setappdata(handles.window,'tempdata',TOP);
    ShowTemporaryPlot(hObject, eventdata, handles, TOP, 'TOP');
    
    setappdata(handles.window,'func','Event2Top_1');
    
elseif strcmp(func,'Event2Top_1') && ~cancel
    
    name = TrimParamName(get(handles.entry1,'String'),handles.maxparamlength);
    if isempty(name)
        beep; uiwait(errordlg('Nome do parâmetro não pode ser vazio.','Erro','modal')); drawnow;
        return
    end 
    PARAM = InsertParam(PARAM,name);
    CheckRepParam(PARAM,name);
    
    data  = getappdata(handles.window,'tempdata');
    DADOS = [DADOS(:,1:end-1), data, DADOS(:,end)];
    
    if xcol == length(PARAM)-1
        xcol = xcol+1;
    end
    ycol = length(PARAM)-1;
    
    HideTemporaryPlot(hObject, eventdata, handles, xcol, ycol, PARAM);
    setappdata(handles.window,'func','none');
    
    setappdata(handles.window,'change',1);
    NewEvent(handles,['Parâmetro ''' name ''' criado por conversão de eventos em TOPs.']);
    
elseif cancel
    
    HideTemporaryPlot(hObject, eventdata, handles);
    
end

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function Logical2Event_Callback(hObject, eventdata, handles)
global DADOS
% Converter parâmetro de sinal lógico em eventos

PARAM   = get(handles.xlist,'String');
xcol    = get(handles.xlist,'Value');
ycol    = get(handles.ylist,'Value');
events  = getappdata(handles.window,'events');
reftime = getappdata(handles.window,'reftime');
func   = getappdata(handles.window,'func');
cancel = getappdata(handles.window,'cancel');

if strcmp(func,'none') && ~cancel
    
    Y = denan(DADOS(:,ycol),1);
    if any(Y~=0 & Y~=1) 
        beep; uiwait(errordlg('O parâmetro de sinal lógico deve conter apenas 0 ou 1.','Erro','modal')); drawnow;
        return
    end
    
    nreftime = findpar(PARAM,reftime,0,1);
    if isempty(nreftime)
        nreftime = inputvalue('Definir','Tempo de referência:',PARAM,1,1.35); drawnow;
        if isempty(nreftime)
            return
        else
            [ok, ndc, nna] = IsTimeOk(DADOS(:,nreftime));
            if ~ok
                beep; uiwait(errordlg({'Parâmetro de tempo não é adequado:',' ',...
                        ['Pontos inválidos: ' num2str(length(nna))],...
                        ['Pontos não crescentes: ' num2str(length(ndc))]},'Erro','modal')); drawnow;
                return
            else            
                reftime = denumber(PARAM{nreftime});
                setappdata(handles.window,'reftime',reftime);
                UpdateTimeCols(hObject, eventdata, handles);
                UpdateTestPoints(hObject, eventdata, handles, 1);
                
                setappdata(handles.window,'change',1);
                NewEvent(handles,['Tempo de referência definido: ''' reftime '''.']);
            end
        end
    end
    
    if xcol ~= nreftime
        set(handles.xlist,'Value',nreftime);
        xlist_Callback(hObject, eventdata, handles);
        pause(.3);
    end
    
    set(handles.entry1txt,'String','Variação:');
    set(handles.entry2txt,'String','Em:');
    set(handles.entry3txt,'String','Descr.:');
    set(handles.entry4txt,'String','Descr.:');
    set(handles.entry1,'String',{'Subidas','Descidas','Subidas e descidas'},'Value',1);
    set(handles.entry2,'String',{'Tudo','Intervalo'},'Value',1);
    set(handles.entry3,'Style','edit','String','ON #');
    set(handles.entry4,'Style','edit','String','OFF #');
    
    set([handles.entries(1:3) handles.entriestxt(1:3) handles.ok_btn handles.cancel_btn],'Visible','on');
    SetFrame(handles,1,'Converter sinal lógico em eventos:');
    set([handles.menulist handles.ylist handles.xlist],'Enable','off');
    UpdateButtonStatus(hObject, eventdata, handles);
    
    setappdata(handles.window,'func','Logical2Event_1');
    
elseif strcmp(func,'Logical2Event_1') && ~cancel
    
    set(handles.window,'Pointer','watch');
    
    opt = get(handles.entry1,'Value');
    in  = get(handles.entry2,'Value');
    descr1 = get(handles.entry3,'String');
    descr2 = get(handles.entry4,'String');
    
    while ~isempty(strfind(descr1,'##'))
        descr1 = strrep(descr1,'##','#');
    end
    while ~isempty(strfind(descr2,'##'))
        descr2 = strrep(descr2,'##','#');
    end
    
    nreftime = findpar(PARAM,reftime,0,1);
    Y = denan(DADOS(:,ycol),1);
    T = DADOS(:,nreftime);
    
    up = find( Y & ~[Y(1); Y(1:end-1)]);
    dn = find(~Y &  [Y(1); Y(1:end-1)]);
    
    if in == 2 % Intervalo
        pts = GetIntervPts(handles);
        if isempty(pts)
            beep; uiwait(errordlg('Não há pontos no intervalo selecionado.','Erro','modal')); drawnow;
            return
        end
        up(up<pts(1))   = [];
        up(up>pts(end)) = [];
        dn(dn<pts(1))   = [];
        dn(dn>pts(end)) = [];
    end
    
    if opt == 1
        dn = [];
    elseif opt == 2
        up = [];
    end
    
    if opt == 1 && isempty(up)
        beep; uiwait(errordlg('Nenhuma variação de subida encontrada.','Erro','modal')); drawnow;
        return
    elseif opt == 2 && isempty(dn)
        beep; uiwait(errordlg('Nenhuma variação de descida encontrada.','Erro','modal')); drawnow;
        return
    elseif opt == 3 && isempty(up) && isempty(dn)
        beep; uiwait(errordlg('Nenhuma variação de sinal lógico encontrada.','Erro','modal')); drawnow;
        return
    end
    
    chg = [up; dn];
    if ~isempty(events)
        
        timelist  = cell2mat(events(:,2));
        timelist1 = T(up);
        timelist2 = T(dn);
        
        [rep1, void, i1] = intersect(timelist,timelist1);
        [rep2, void, i2] = intersect(timelist,timelist2);
        rep = [rep1; rep2];
        
        if ~isempty(rep)
            if length(rep) == 1
                if length(chg) == 1
                    str1 = 'O ponto já está definido como evento.';
                else
                    str1 = 'Um dos pontos já está definido como evento.';
                end
            else
                if length(rep) == length(chg)
                    str1 = ['Todos os ' num2str(length(rep)) ' pontos já estão definidos como eventos.'];
                else
                    str1 = [num2str(length(rep)) ' pontos já estão definidos como eventos.'];
                end
            end
            if length(rep) == 1
                str2 = 'Deseja ignorá-lo?';
            else
                str2 = 'Deseja ignorá-los?';
            end
            button = questdlg({str1,str2},'Confirmação','Sim','Não','Não'); drawnow;
            if strcmp(button,'Sim')
                up(i1) = [];
                dn(i2) = [];
                chg = [up; dn];
            end
            if isempty(chg)
                return
            end
        end
    end
    
    if length(chg) == 1
        str = 'Deseja acrescentar 1 novo evento?';
    else
        str = ['Deseja acrescentar ' num2str(length(chg)) ' novos eventos?'];
    end
    button = questdlg(str,'Confirmação','Sim','Não','Não'); drawnow;
    if ~strcmp(button,'Sim')
        return
    end
    
    events2 = {};
    n0 = 0;
    if ~isempty(events) && ~isempty(descr1) && descr1(end) == '#'
        k = strmatch(descr1(1:end-1),events(:,3));
        if ~isempty(k)
            for ki = k'
                if length(events{ki,3}) >= length(descr1)
                    lastno = str2double(events{ki,3}(length(descr1-1):end));
                    if ~isnan(lastno)
                        n0 = max(n0,lastno);
                    end
                end
            end
        end
    end
    for n = 1:length(up)
        events2{n,1} = 1;
        events2{n,2} = T(up(n));
        events2{n,3} = strrep(descr1,'#',num2str(n+n0));
    end
    n0 = 0;
    if ~isempty(events) && ~isempty(descr2) && descr2(end) == '#'
        k = strmatch(descr2(1:end-1),events(:,3));
        if ~isempty(k)
            for ki = k'
                if length(events{ki,3}) >= length(descr2)
                    lastno = str2double(events{ki,3}(length(descr2-1):end));
                    if ~isnan(lastno)
                        n0 = max(n0,lastno);
                    end
                end
            end
        end
    end
    for n = 1:length(dn)
        events2{length(up)+n,1} = 1;
        events2{length(up)+n,2} = T(dn(n));
        events2{length(up)+n,3} = strrep(descr2,'#',num2str(n0+n));
    end
    
    if opt == 3
        [void, ord] = sort([events2{:,2}]);
        events2 = events2(ord,:);
    end

    events = [events; events2];
    
    setappdata(handles.window,'events',events);
    set(handles.ShowEvents,'Checked','on');
    set(handles.Events_btn,'Value',1);
    UpdateEvents(hObject, eventdata, handles, 1);
    setappdata(handles.window,'change',1);
    
    if length(chg) == 1
        str = '1 variação de sinal lógico definida como evento.';
    else
        str = [num2str(length(chg)) ' variações de sinal lógico definidas como eventos.'];
    end
    NewEvent(handles,str);
    
    setappdata(handles.window,'func','none');
    ClearEntryBox(hObject, eventdata, handles);

end

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function Event2Logical_Callback(hObject, eventdata, handles)
global DADOS
% Converter eventos em parâmetro de sinal lógico

PARAM   = get(handles.xlist,'String');
xcol    = get(handles.xlist,'Value');
events  = getappdata(handles.window,'events');
reftime = getappdata(handles.window,'reftime');
func   = getappdata(handles.window,'func');
cancel = getappdata(handles.window,'cancel');

if strcmp(func,'none') && ~cancel
    
    if isempty(events)
        beep; uiwait(errordlg('Não há eventos definidos.','Erro','modal')); drawnow;
        return
    end
    
    nreftime = findpar(PARAM,reftime,0,1);
    if isempty(nreftime)
        nreftime = inputvalue('Definir','Tempo de referência:',PARAM,1,1.35); drawnow;
        if isempty(nreftime)
            return
        else
            [ok, ndc, nna] = IsTimeOk(DADOS(:,nreftime));
            if ~ok
                beep; uiwait(errordlg({'Parâmetro de tempo não é adequado:',' ',...
                        ['Pontos inválidos: ' num2str(length(nna))],...
                        ['Pontos não crescentes: ' num2str(length(ndc))]},'Erro','modal')); drawnow;
                return
            else            
                reftime = denumber(PARAM{nreftime});
                setappdata(handles.window,'reftime',reftime);
                UpdateTimeCols(hObject, eventdata, handles);
                UpdateTestPoints(hObject, eventdata, handles, 1);
                
                setappdata(handles.window,'change',1);
                NewEvent(handles,['Tempo de referência definido: ''' reftime '''.']);
            end
        end
    end
    
    if xcol ~= nreftime
        set(handles.xlist,'Value',nreftime);
        xlist_Callback(hObject, eventdata, handles);
        pause(.3);
    end
    
    for n = 1:size(events,1)
        eventstr{n} = [num2str(n,'%02.0f') '- ' time2str2(events{n,2},0) ' - ' events{n,3}];
    end
    
    [up, ok, dn] = listdlg2('Name','Converter eventos em sinal lógico','HeaderString',...
        'Indique os eventos correspondentes às variações no sinal lógico:           (para descida por tempo, não selecione os eventos de descida)',...
        'PromptString','Subida (0 para 1):','PromptString2','Descida (1 para 0):','SelectionMode','multiple','ListString',eventstr,'ListString2',eventstr,...
        'OKString','OK','CancelString','Cancela','SelectAllString','Selecionar tudo','SelectNoneString','Limpar','ListSize',[300 309]); drawnow;
    
    if ~ok || isempty(up)
        return
    end
    
    T = DADOS(:,nreftime);
    Y = 0*T;
    
    if ~isempty(dn) % Subidas e descidas
        
        chg = [up       dn];
        val = [0*up+1 0*dn];
        tev = [events{chg,2}];
        
    else % Subidas por evento e descidas por tempo
        dt = inputvalue('Duração dos eventos','Segundos:','1',1,1.2); drawnow;
        if isempty(dt)
            return
        end
        dt = str2double(dt);
        if isnan(dt)
            beep; errordlg('Parâmetro de entrada incoerente.','Erro','modal'); drawnow;
            return
        end
        dt = max(0,dt);
        
        chg = [up       up];
        val = [0*up+1 0*up];
        tev = [events{up,2} [events{up,2}]+dt];
        
    end
    
    [void, ord] = sort(tev);
    
    chg = chg(ord);
    val = val(ord);
    tev = tev(ord);
    
    for n = 1:length(chg)
        if ~isnan(tev(n))
            Y(T>=tev(n)) = val(n);
        end
    end
    
    setappdata(handles.window,'tempdata',Y);
    ShowTemporaryPlot(hObject, eventdata, handles, Y, '');
    
    setappdata(handles.window,'func','Event2Logical_1');
    
elseif strcmp(func,'Event2Logical_1') && ~cancel
    
    name = TrimParamName(get(handles.entry1,'String'),handles.maxparamlength);
    if isempty(name)
        beep; uiwait(errordlg('Nome do parâmetro não pode ser vazio.','Erro','modal')); drawnow;
        return
    end 
    PARAM = InsertParam(PARAM,name);
    CheckRepParam(PARAM,name);
    
    data  = getappdata(handles.window,'tempdata');
    DADOS = [DADOS(:,1:end-1), data, DADOS(:,end)];
    
    xcol = get(handles.xlist,'Value');
    if xcol == length(PARAM)-1
        xcol = xcol+1;
    end
    ycol = length(PARAM)-1;
    
    HideTemporaryPlot(hObject, eventdata, handles, xcol, ycol, PARAM);
    set(handles.graphs,'XLim',AutoLim(handles.plot));
    setappdata(handles.window,'func','none');
    
    setappdata(handles.window,'change',1);
    NewEvent(handles,['Parâmetro ''' name ''' criado por conversão de eventos em sinal lógico.']);
    
elseif cancel
    
    HideTemporaryPlot(hObject, eventdata, handles);
    set(handles.graphs,'XLim',AutoLim(handles.plot));
    
end

Window_ButtonMotionFcn(hObject, eventdata, handles);

% ####################################################################
%                     FUNÇÕES DO MENU OPÇÕES
% ####################################################################

% --------------------------------------------------------------------
function FitZoom_Callback(hObject, eventdata, handles)
% Mostra todo o arquivo (zoom mínimo)

func = getappdata(handles.window,'func');
clickfunc = getappdata(handles.window,'clickfunc');

if strcmp(clickfunc,'zoom') || strcmp(clickfunc,'select')
    
    set(handles.auxlines,'Visible','off')
    set(handles.graphs,'XLim',AutoLim([handles.plots(1,1:3) handles.ruler]),'YLimMode','auto');
    setappdata(handles.window,'xzoom',[]);
    if strcmp(func,'PlotMachLines_1')
        PlotMachLines_Callback(hObject, eventdata, handles);
    end
    Window_ButtonMotionFcn(hObject, eventdata, handles);
    
else
    beep;
end

% --------------------------------------------------------------------
function BoxZoom_Callback(hObject, eventdata, handles)
% Habilita zoom retangular com o mouse

func = getappdata(handles.window,'func');

if all(isnan(get(handles.plot,'XData'))) && all(isnan(get(handles.plots(1,2),'XData')))
    set(handles.BoxZoom,'Checked','off');
    set(handles.BoxZoom_btn,'Value',0);
    return
end

if strcmp(get(handles.BoxZoom,'Checked'),'off')
    set(handles.BoxZoom,'Checked','on');
    set(handles.BoxZoom_btn,'Value',1);
    set(handles.MouseDrag,'Checked','off');
    set(handles.MouseDrag_btn,'Value',0);
    setappdata(handles.window,'zoomtype','rect');
else
    set(handles.title,'String','');
    set(handles.BoxZoom,'Checked','off');
    set(handles.BoxZoom_btn,'Value',0);
    set(handles.graphs,'YLimMode','auto');
    if strcmp(get(handles.MouseDrag,'Checked'),'off')
        setappdata(handles.window,'zoomtype','norm');
    end
    if strcmp(func,'PlotMachLines_1')
        PlotMachLines_Callback(hObject, eventdata, handles);
    end
end
Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function MouseDrag_Callback(hObject, eventdata, handles)
% Habilita arrastar o gráfico com o mouse

if all(isnan(get(handles.plot,'XData'))) && all(isnan(get(handles.plots(1,2),'XData')))
    set(handles.MouseDrag,'Checked','off');
    set(handles.MouseDrag_btn,'Value',0);
    return
end

if strcmp(get(handles.MouseDrag,'Checked'),'off')
    set(handles.MouseDrag,'Checked','on');
    set(handles.MouseDrag_btn,'Value',1);
    setappdata(handles.window,'zoomtype','drag');
else
    set(handles.MouseDrag,'Checked','off');
    set(handles.MouseDrag_btn,'Value',0);
    switch get(handles.BoxZoom,'Checked')
        case 'off'
            zoomtype = 'norm';
        case 'on'
            zoomtype = 'rect';
    end
    setappdata(handles.window,'zoomtype',zoomtype);
end
Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function CursorPrecision_Callback(hObject, eventdata, handles)
% Redefine numero de casas decimais da posição do cursor

precisions = [0 1 2 3 4 5 6];
n_old = find(handles.precision==precisions);

n = inputvalue('Precisão','Casas decimais:',num2str(precisions'),n_old); drawnow;

if ~isempty(n)
    precision = precisions(n);
    save(which('DatOptions.mat'),'precision','-append',saveopt);
    handles.precision = precision;
    guidata(hObject, handles);
    Window_ButtonMotionFcn(hObject, eventdata, handles);
    UpdateCreationWindow(hObject, eventdata, handles);
end

% --------------------------------------------------------------------
function RulerSegments_Callback(hObject, eventdata, handles)
% Redefine numero de segmentos da regua

sizes = 1:10;
n_old = find(handles.rulersize==sizes);

n = inputvalue('Régua','Número de segmentos:',num2str(sizes'),n_old); drawnow;

if ~isempty(n)
    rulersize = sizes(n);
    save(which('DatOptions.mat'),'rulersize','-append',saveopt);
    handles.rulersize = rulersize;
    guidata(hObject, handles);
    
    dx = get(handles.ruler,'XData');
    dy = get(handles.ruler,'YData');
    
    set(handles.ruler,'XData',linspace(dx(1),dx(end),handles.rulersize+1),'YData',linspace(dy(1),dy(end),handles.rulersize+1));
    
end

% --------------------------------------------------------------------
function HistBins_Callback(hObject, eventdata, handles)
% Redefine numero de celulas do histograma

histbins = inputvalue('Histograma','Número de células:',num2str(handles.histbins)); drawnow;

if ischar(histbins) && ~isempty(histbins)
    
    err = '';
    histbins = str2double(histbins);
    
    if isnan(histbins)
        err = 'Valor incoerente.';
    elseif histbins < 2
        err = 'O número de células do histograma deve ser maior que 1.';
    elseif histbins > 200
        err = 'O número máximo de células do histograma é 200.';
    elseif histbins - round(histbins) ~= 0
        err = 'O número de células do histograma deve ser inteiro.';
    end
    if ~isempty(err)
        beep; uiwait(errordlg(err,'Erro','modal')); drawnow;
        return
    end
    
    save(which('DatOptions.mat'),'histbins','-append',saveopt);
    
    handles.histbins = histbins;
    guidata(hObject, handles);
    
end

% --------------------------------------------------------------------
function DisplayDetailedTime_Callback(hObject, eventdata, handles)
% Função que habilita apresentação de tempo no formato hh:mm:ss.mss

if strcmp(get(handles.DisplayDetailedTime,'Checked'),'off');
    set(handles.DisplayDetailedTime,'Checked','on');
else
    set(handles.DisplayDetailedTime,'Checked','off');
end
Window_ButtonMotionFcn(hObject, eventdata, handles);
UpdateDataTips(hObject, eventdata, handles);

% --------------------------------------------------------------------
function DisplayDetailedCoord_Callback(hObject, eventdata, handles)
% Função que habilita apresentação de lat/long

if strcmp(get(handles.DisplayDetailedCoord,'Checked'),'off');
    set(handles.DisplayDetailedCoord,'Checked','on');
else
    set(handles.DisplayDetailedCoord,'Checked','off');
end

% --------------------------------------------------------------------
function RememberMultiPar_Callback(hObject, eventdata, handles)
% Opção de memorizar parâmetros selecionados nas funções de exibição múltipla

if strcmp(get(handles.RememberMultiPar,'Checked'),'off')
    set(handles.RememberMultiPar,'Checked','on');
else
    set(handles.RememberMultiPar,'Checked','off');
end

% --------------------------------------------------------------------
function ForgetMultiPar_Callback(hObject, eventdata, handles, noconf)
% Limpar os parâmetros memorizados das funções de exibição múltipla

if nargin == 3
    noconf = 0;
end

if noconf
    button = 'Sim';
else
    button = questdlg('Deseja limpar os parâmetros memorizados das funções de exibição múltipla?','Confirmação','Sim','Não','Não'); drawnow;
end

if strcmp(button,'Sim')
    setappdata(handles.window,'mp5_list',  {'','','',''});
    setappdata(handles.window,'mp16_list', {'','','','','','','','','','','','','','','',''});
    setappdata(handles.window,'mp3_list',  {'','','',''});
    setappdata(handles.window,'mg5_list',  {'','','',''});
    setappdata(handles.window,'mg3x5_list',{'','','','','','','','','','','','','','',''});
end

% --------------------------------------------------------------------
function DontResetOriginForFit_Callback(hObject, eventdata, handles)
% Opção de não ajustar x = 0 no inicio do trecho a ser fitado

if strcmp(get(handles.DontResetOriginForFit,'Checked'),'on')
    set(handles.DontResetOriginForFit,'Checked','off');
else
    set(handles.DontResetOriginForFit,'Checked','on');
end

func = getappdata(handles.window,'func');
if strcmp(func,'FitCurve_1')
    FitCurve_Callback(hObject, eventdata, handles);
end

% --------------------------------------------------------------------
function DontShowErrorBounds_Callback(hObject, eventdata, handles)
% Opção de não exibir limiares de erro de 50%

if strcmp(get(handles.DontShowErrorBounds,'Checked'),'on')
    set(handles.DontShowErrorBounds,'Checked','off');
    tempdata = getappdata(handles.window,'tempdata');
    if length(tempdata) == 7
        xr = tempdata{7}(:,1);
        yfr = tempdata{7}(:,2);
        delta = tempdata{7}(:,3);
    else
        xr = NaN;
        yfr = NaN;
        delta = NaN;
    end
    set(handles.auxplots(1,2),'XData',[xr; NaN; xr],'YData',[yfr+delta; NaN; yfr-delta]);
else
    set(handles.DontShowErrorBounds,'Checked','on');
    set(handles.auxplots(1,2),'XData',NaN,'YData',NaN);
end

% --------------------------------------------------------------------
function RemovePrefix_Callback(hObject, eventdata, handles)
% Remover ou manter prefixos de telemetria ao carregar arquivo mat

load(which('DatOptions.mat'),'remprefix');
remprefix = ~remprefix;

if remprefix
    set(handles.RemovePrefix,'Checked','on');
else
    set(handles.RemovePrefix,'Checked','off');
end

save(which('DatOptions.mat'),'remprefix','-append',saveopt);

% --------------------------------------------------------------------
function CheckSubcomut_Callback(hObject, eventdata, handles)
% Analisar subcomutação ao carregar arquivo mat

load(which('DatOptions.mat'),'subcomut');
subcomut = ~subcomut;

if subcomut
    set(handles.CheckSubcomut,'Checked','on');
else
    set(handles.CheckSubcomut,'Checked','off');
end

save(which('DatOptions.mat'),'subcomut','-append',saveopt);


% ####################################################################
%                     FUNÇÕES DO MENU EXIBIR
% ####################################################################

function ShowToolbar_Callback(hObject, eventdata, handles)
% Ocultar barra de ferramentas (botões)

if strcmp(get(handles.ShowToolbar,'Checked'),'on')    
    set(handles.ShowToolbar,'Checked','off');
else
    set(handles.ShowToolbar,'Checked','on');
end

Window_ResizeFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function RedefineToolbar_Callback(hObject, eventdata, handles)
% Redefine os botões da barra de ferramentas

btndata   = getappdata(handles.window,'btndata');
btnlabels = get([btndata{:,2}],'TooltipString');
oldbtnvis = [btndata{:,6}];

btnvis = RDAT_EditToolbar(btndata,btnlabels,oldbtnvis); drawnow;

if ~isempty(btnvis)
    set(handles.window,'Pointer','watch');
    if ~isequal(btnvis,oldbtnvis)
        btndata(:,6) = num2cell(btnvis');
        setappdata(handles.window,'btndata',btndata);
        save(which('DatOptions.mat'),'btnvis','-append',saveopt);
    end
    set(handles.ShowToolbar,'Checked','on');
    Window_ResizeFcn(hObject, eventdata, handles);
    Window_ButtonMotionFcn(hObject, eventdata, handles);
end

% --------------------------------------------------------------------
function ShowRuler_Callback(hObject, eventdata, handles)
% Alterna exibição de regua no gráfico

if isequalwithequalnans(get(handles.plot,'XData'),NaN)
    return
end

if isequalwithequalnans(get(handles.plot,'XData'),NaN)
    set(handles.ShowRuler,'Checked','off');
    set(handles.Ruler_btn,'Value',0);
    set(handles.title,'UIContextMenu',[]);
    return
end

if strcmp(get(handles.ShowRuler,'Checked'),'off')
    set(handles.title,'String','Arraste os extremos da régua');
    set(handles.ShowRuler,'Checked','on');
    set(handles.Ruler_btn,'Value',1);
    ax = get(handles.graph,'XLim');
    ay = get(handles.graph,'YLim');
    set(handles.ruler,'XData',linspace(ax(1)+.25*diff(ax),ax(2)-.25*diff(ax),handles.rulersize+1),...
        'YData',linspace(mean(ay),mean(ay),handles.rulersize+1));
    set(handles.title,'UIContextMenu',handles.TitleMenu);
else
    set(handles.title,'String','');
    set(handles.ShowRuler,'Checked','off');
    set(handles.Ruler_btn,'Value',0);
    set(handles.ruler,'XData',NaN,'YData',NaN);
    set(handles.graphs,'YLimMode','auto');
    set(handles.title,'UIContextMenu',[]);
end

% --------------------------------------------------------------------
function ShowSyncLine_Callback(hObject, eventdata, handles)
% Alterna exibição de linha de sincronismo em gráficos ou plots múltiplos

if strcmp(get(handles.ShowSyncLine,'Checked'),'off')
    set(handles.ShowSyncLine,'Checked','on');
    set(handles.SyncLine_btn,'Value',1);
else
    set(handles.ShowSyncLine,'Checked','off');
    set(handles.sync_line,'Visible','off');
    set(handles.SyncLine_btn,'Value',0);
end
Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function ShowDataTips_Callback(hObject, eventdata, handles)
% Alterna exibição de datatips

if isequalwithequalnans(get(handles.plot,'XData'),NaN)
    return
end

if strcmp(get(handles.ShowDataTips,'Checked'),'on')
    
    set(handles.ShowDataTips,'Checked','off');
    set(handles.DataTips_btn,'Value',0);
    set(handles.datatips(:,1,1),'XData',NaN,'YData',NaN);
    set(handles.datatips(:,1,2),'XData',NaN,'YData',NaN);
    set(handles.datatips(:,2,1),'Position',[0 0],'String','','Visible','off');
    set(handles.datatips(:,2,2),'Position',[0 0],'String','','Visible','off');
    
else
    
    set(handles.datatips(:,2,1),'VerticalAlignment','bottom','HorizontalAlignment','left');
    set(handles.datatips(:,2,2),'VerticalAlignment','bottom','HorizontalAlignment','left');
    X = get(handles.plot,'XData');
    Y = get(handles.plot,'YData');
    if all(isnan(X))
        beep; uiwait(errordlg('Não há dados válidos no parâmetro x.','Erro','modal')); drawnow;
        set(handles.ShowDataTips,'Checked','off');
        set(handles.DataTips_btn,'Value',0);
        return
    end
    set(handles.ShowDataTips,'Checked','on');
    set(handles.DataTips_btn,'Value',1);
    ax = get(handles.graph,'XLim');
    ay = get(handles.graph,'YLim');
    x = mean(ax);
    y = mean(ay);
    X(X<ax(1)|X>ax(2)) = NaN;
    Y(Y<ay(1)|Y>ay(2)) = NaN;
    D = sqrt((X-x).^2+(Y-y).^2);
    n = find(D == min(D));
    if ~isempty(n)
        n = n(1);
        setappdata(handles.window,'datatipn',n);
        UpdateDataTips(hObject, eventdata, handles);
    else
        set(handles.ShowDataTips,'Checked','off');
        set(handles.DataTips_btn,'Value',0);
        return
    end
end

% --------------------------------------------------------------------
function PlotMachLines_Callback(hObject, eventdata, handles)
% Plota linhas de Mach num gráfico Vc x Zp

if isequalwithequalnans(get(handles.plot,'XData'),NaN)
    set(handles.PlotMachLines,'Checked','off');
    return
end

xpar   = get(handles.xlabel,'String');
ypar   = get(handles.ylabel,'String');
func   = getappdata(handles.window,'func');
cancel = getappdata(handles.window,'cancel');

if strcmp(func,'none') && ~cancel
    
    % Cheque dos parâmetros
    if ~isempty(findpar(xpar,{'Vc','Vb','CAS'},1,0))
        isV = 1;
    else
        isV = 0;
    end
    if ~isempty(findpar(ypar,{'Zp','Zpb','BARO'},1,0))
        isZ = 1;
    else
        isZ = 0;
    end
    
    switch isV + 2*isZ
        case 0
            str = char('Os parâmetros não aparentam ser','velocidade calibrada e altitude pressão.');
        case 1
            str = 'O parâmetro y não aparenta ser altitude pressão.';
        case 2
            str = 'O parâmetro x não aparenta ser velocidade calibrada.';
        otherwise
            str = '';
    end
    if ~isempty(str)
        button = questdlg({str,'Deseja continuar?'},'Confirmação','Sim','Não','Sim'); drawnow;
        if ~strcmp(button,'Sim')
            return
        end
    end
    
    % Cheque das unidades
    if ~isempty( [strfind(xpar,'kt') strfind(xpar,'knot') strfind(xpar,'nós') strfind(xpar,'nos')] )
        isK = 1;
    else
        isK = 0;
    end
    if ~isempty( [strfind(ypar,'ft') strfind(ypar,'feet') strfind(ypar,'pés') strfind(ypar,'pes')] )
        isF = 1;
    else
        isF = 0;
    end
    
    switch isK + 2*isF
        case 0
            str = 'Os parâmetros não aparentam estar em nós e pés.';
        case 1
            str = 'O parâmetro y não aparenta estar em pés.';
        case 2
            str = 'O parâmetro x não aparenta estar em nós.';
        otherwise
            str = '';
    end
    if ~isempty(str)
        button = questdlg({str,'Deseja continuar?'},'Confirmação','Sim','Não','Sim'); drawnow;
        if ~strcmp(button,'Sim')
            return
        end
    end
    
    set(handles.entry1txt,'String','Intervalo:');
    set(handles.entry1,'String',{'0,02 M','0,05 M','0,10 M','0,20 M'},'Value',3);
    
    set([handles.entry1 handles.entry1txt handles.cancel_btn],'Visible','on');
    SetFrame(handles,1,'Linhas de Mach');
    set([handles.menulist handles.xlist handles.ylist],'Enable','off');
    UpdateButtonStatus(hObject, eventdata, handles);
    
    setappdata(handles.window,'func','PlotMachLines_1');
    UpdateDataTips(hObject, eventdata, handles);
    entry1_Callback(hObject, eventdata, handles);
    
elseif strcmp(func,'PlotMachLines_1') && ~cancel
    
    set(handles.auxplots,'XData',NaN,'YData',NaN);
    delete(findobj(handles.graph,'Userdata','auxh'));
    
    ax = get(handles.graph,'XLim');
    ay = get(handles.graph,'YLim');
    
    Vc1 = ax(1);
    Vc2 = ax(2);
    Zp1 = ay(1);
    Zp2 = ay(2);
    
    steps = [.02 .05 .1 .2];
    step = steps(get(handles.entry1,'Value'));
    
    try
        
        M1 = step;
        M2 = qcpa2m(vc2qc(Vc2),zp2pa(Zp2));
        
        Mi = (M1:step:M2)';
        if isempty(Mi)
            beep; uiwait(errordlg('Intervalo de dados inválido.','Erro','modal')); drawnow;
            return
        end
        
        VcM1 = [];
        Vc   = [];
        Zp   = [];
        Zpi  = linspace(Zp1,Zp2,100)';
        
        for n = 1:length(Mi)
            Vci = qc2vc(m2qcpa(Mi(n)).*zp2pa(Zpi));
            inc = Vci>=Vc1 & Vci<=Vc2;
            
            if abs(Mi(n)-1) <= eps
                VcM1 = Vci;
            else
                Zp = [Zp; NaN; Zpi(inc)];
                Vc = [Vc; NaN; Vci(inc)];
            end
            
            % Tick labels
            if Vci(1) < Vc2
                xlbl = Vci(1);
                ylbl = Zp1;
                haling = 'left';
                valign = 'bottom';
            else
                xlbl = Vc2;
                ylbl = vcm2zp(Vc2,Mi(n));
                haling = 'right';
                valign = 'cap';
            end
            if Vci(1) >= Vc1
                str = num2str(Mi(n));
            else
                str = '';
            end
            
            auxh(n) = text(xlbl,ylbl,str,'HorizontalAlignment',haling,'VerticalAlignment',valign,'Color',get(handles.xlabel,'ForegroundColor'),...
                'Clipping','on','Userdata','auxh');
            
        end
        if isempty(VcM1)
            VcM1 = NaN*Zpi;
        end
        
        set(handles.auxplots(1,1),'XData',VcM1,'YData',Zpi);
        set(handles.auxplots(1,2),'XData',Vc,'YData',Zp);
        
    catch
        cancel_btn_Callback(hObject, eventdata, handles);
        beep; uiwait(errordlg(lasterr,'Erro','modal')); drawnow;
        return
    end
    
elseif cancel
    
    set(handles.auxplots,'XData',NaN,'YData',NaN);
    delete(findobj(handles.graph,'Userdata','auxh'));
    UpdateDataTips(hObject, eventdata, handles);
    
end

% --------------------------------------------------------------------
function ShowTestPoints_Callback(hObject, eventdata, handles)
% Alterna apresentação de marcadores de pontos de ensaio

if isequalwithequalnans(get(handles.plot,'XData'),NaN)
    return
end

if strcmp(get(handles.ShowTestPoints,'Checked'),'off');
    testpts = getappdata(handles.window,'testpts');
    if isempty(testpts)
        beep; uiwait(errordlg('Não há pontos de ensaio definidos.','Erro','modal')); drawnow;
        set([handles.ShowTestPoints handles.ShowTestPointsDescr] ,'Checked','off');
        set(handles.TestPoints_btn,'Value',0);
    else
        set(handles.ShowTestPoints,'Checked','on');
        set(handles.TestPoints_btn,'Value',1);
    end
else
    set(handles.ShowTestPoints,'Checked','off');
    set(handles.TestPoints_btn,'Value',0);
end
UpdateTestPoints(hObject, eventdata, handles, 1);
Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function ShowTestPointsDescr_Callback(hObject, eventdata, handles)
% Alterna apresentação das descrições dos pontos de ensaio

if isequalwithequalnans(get(handles.plot,'XData'),NaN)
    return
end

if strcmp(get(handles.ShowTestPointsDescr,'Checked'),'off');
    testpts = getappdata(handles.window,'testpts');
    if isempty(testpts)
        beep; uiwait(errordlg('Não há pontos de ensaio definidos.','Erro','modal')); drawnow;
        set([handles.ShowTestPoints handles.ShowTestPointsDescr],'Checked','off');
        set(handles.TestPoints_btn,'Value',0);
    else
        set([handles.ShowTestPoints handles.ShowTestPointsDescr],'Checked','on');
        set(handles.TestPoints_btn,'Value',1);
    end
else
    set(handles.ShowTestPointsDescr,'Checked','off');
end
UpdateTestPoints(hObject, eventdata, handles, 1);
Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function ShowEvents_Callback(hObject, eventdata, handles)
% Alterna apresentação de eventos

if isequalwithequalnans(get(handles.plot,'XData'),NaN)
    return
end

if strcmp(get(handles.ShowEvents,'Checked'),'off');
    events = getappdata(handles.window,'events');
    if isempty(events)
        beep; uiwait(errordlg('Não há eventos definidos.','Erro','modal')); drawnow;
        set([handles.ShowEvents handles.ShowEventsDescr],'Checked','off');
        set(handles.Events_btn,'Value',0);
    else
        set(handles.ShowEvents,'Checked','on');
        set(handles.Events_btn,'Value',1);
    end
else
    set(handles.ShowEvents,'Checked','off');
    set(handles.Events_btn,'Value',0);
end
UpdateEvents(hObject, eventdata, handles, 1);
Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function ShowEventsDescr_Callback(hObject, eventdata, handles)
% Alterna apresentação das descrições dos eventos

if isequalwithequalnans(get(handles.plot,'XData'),NaN)
    return
end

if strcmp(get(handles.ShowEventsDescr,'Checked'),'off');
    events = getappdata(handles.window,'events');
    if isempty(events)
        beep; uiwait(errordlg('Não há eventos definidos.','Erro','modal')); drawnow;
        set([handles.ShowEvents handles.ShowEventsDescr],'Checked','off');
        set(handles.Events_btn,'Value',0);
    else
        set([handles.ShowEvents handles.ShowEventsDescr],'Checked','on');
        set(handles.Events_btn,'Value',1);
    end
else
    set(handles.ShowEventsDescr,'Checked','off');
end
UpdateEvents(hObject, eventdata, handles, 1);
Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function PartialData_Callback(hObject, eventdata, handles)
global DADOS
% Alterna exibição parcial de dados (trecho selecionado)

if strcmp(get(handles.PartialData,'Checked'),'off')
    
    pts = GetIntervPts(handles);
    
    if isempty(pts)
        beep; uiwait(errordlg('Não há pontos no intervalo selecionado.','Erro','modal')); drawnow;
        set(handles.PartialData_btn,'Value',0);
        return
    elseif length(pts) == size(DADOS,1)
        beep; uiwait(errordlg('Intervalo selecionado corresponde a todo o arquivo.','Erro','modal')); drawnow;
        set(handles.PartialData_btn,'Value',0);
        return
    end
    
    part = min(pts):max(pts);
    
    button = questdlg({['Pontos no intervalo: ' num2str(length(part))],'Deseja exibir apenas o intervalo selecionado?'},...
        'Confirmação','Sim','Não','Não'); drawnow;
    
    if strcmp(button,'Sim')
        
        set(handles.PartialData,'Checked','on');
        set(handles.menulist,'Enable','off');
        UpdateButtonStatus(hObject, eventdata, handles);
        SetButtonStatus(handles,[handles.printlist handles.PartialData_btn handles.Multiplot_btn handles.Multigraph_btn],1);
        
        datatipn = getappdata(handles.window,'datatipn');
        if ~isempty(datatipn)
            datatipn = min(length(part),max(1,datatipn-part(1)+1));
            setappdata(handles.window,'datatipn',datatipn);
        end
        
        setappdata(handles.window,'part',part);
        UpdatePlot(hObject, eventdata, handles);
        
    else
        set(handles.PartialData_btn,'Value',0);
    end
    
else
    
    button = questdlg('Deseja desabilitar a exibição parcial de dados?','Confirmação','Sim','Não','Não'); drawnow;
    
    if strcmp(button,'Sim')
        
        set(handles.PartialData,'Checked','off');
        set(handles.menulist,'Enable','on');
        UpdateButtonStatus(hObject, eventdata, handles);
        
        part     = getappdata(handles.window,'part');
        datatipn = getappdata(handles.window,'datatipn');
        if ~isempty(datatipn)
            datatipn = datatipn+part(1)-1;
            setappdata(handles.window,'datatipn',datatipn);
        end
        
        setappdata(handles.window,'part',[]);
        UpdatePlot(hObject, eventdata, handles);
        
    else
        set(handles.PartialData_btn,'Value',1);
    end
    
end

Window_ButtonMotionFcn(hObject, eventdata, handles);

% ####################################################################
%                     FUNÇÕES DO MENU AJUDA
% ####################################################################

function Help_Callback(hObject, eventdata, handles)
% Chama o documento de ajuda em html (manual do usuario)

func = getappdata(handles.window,'func');

if strcmp(get(handles.SelectPoints,'Checked'),'on')
    func = 'SelectPoints_1';
elseif strcmp(get(handles.PartialData,'Checked'),'on')
    func = 'PartialData_1';
end

if isempty(func)
    helpme('R_DAT');
else
    
    switch func(1:end-2)
        
        case 'GenerateSyncTime'
            helpme('Funcoes\composicao_param','hora');
        case 'DegMinSec2Deg'
            helpme('Funcoes\composicao_param','grau');
        case 'MergeValidSections'
            helpme('Funcoes\composicao_param','valid');
        case 'SignalFilter'
            helpme('Funcoes\filtragem');
        case 'InterpSelPts'
            helpme('Funcoes\interpselpts');
        case 'InterpNaNPts'
            helpme('Funcoes\interpnanpts');
        case 'CreateMilisec'
            helpme('Funcoes\criarmiliseg');
        case 'ChangeRate'
            helpme('Funcoes\alterarcadencia');
        case 'Resample'
            helpme('Funcoes\reamostrar');
        case 'CircInterv'
            helpme('Funcoes\intervalocircular');
        case 'CenterOnSelPt'
            helpme('Funcoes\centrarptsel');
        case 'ElementaryOperation'
            helpme('Funcoes\opermatematica','elem');
        case 'OneParamOperation'
            helpme('Funcoes\opermatematica','um');
        case 'TwoParamOperation'
            helpme('Funcoes\opermatematica','dois');
        case 'FourParamOperation'
            helpme('Funcoes\opermatematica','quatro');
        case 'GetBit'
            helpme('Funcoes\operbinarias','obter');
        case 'SetBit'
            helpme('Funcoes\operbinarias','atrib');
        case 'JoinWords'
            helpme('Funcoes\operbinarias','comp');
        case 'Interp1D'
            helpme('Funcoes\interpolacao','uni');
        case 'Interp2D'
            helpme('Funcoes\interpolacao','bi');
        case 'Anemometry'
            helpme('Funcoes\anemometria');
        case 'UnitsConversion'
            helpme('Funcoes\convunidades','um');
        case 'LatLong2DeDn'
            helpme('Funcoes\convcoord','LL2EN');
        case 'DeDn2LatLong'
            helpme('Funcoes\convcoord','EN2LL');
        case 'LatLong2RdlDist'
            helpme('Funcoes\convcoord','LL2RD');
        case 'RdlDist2LatLong'
            helpme('Funcoes\convcoord','RD2LL');
        case 'DeDn2RdlDist'
            helpme('Funcoes\convcoord','EN2RD');
        case 'RdlDist2DeDn'
            helpme('Funcoes\convcoord','RD2EN');
        case 'TrajIntegration'
            helpme('Funcoes\integratraj');
        case 'CourseCalculation'
            helpme('Funcoes\obtencaocurso');
        case 'DmagModel'
            helpme('Funcoes\calculodmag','model');
        case 'DmagDpsi'
            helpme('Funcoes\calculodmag','dpsi');
        case 'PsiConversion'
            helpme('Funcoes\calculodmag','conv');
        case 'NumInteg'
            helpme('Funcoes\integracao');
        case 'NumDiffer'
            helpme('Funcoes\diferenciacao');
        case 'FitCurve'
            helpme('Funcoes\ajustedecurva');
            
        case 'GoToTime'
            helpme('Dados\irpara','tempo');
        case 'GoToTOP'
            helpme('Dados\irpara','top');
        case 'GoToEvent'
            helpme('Dados\irpara','evento');
        case 'GoToPoint'
            helpme('Dados\irpara','ponto');
        case 'CreateParam'
            helpme('Dados\criarparam');
        case 'RenameParamY'
            helpme('Dados\renomear');
        case 'GetFromWorkspace'
            helpme('Dados\enviarpworkspace','get');
        case 'SelectPoints'
            helpme('Dados\sel_dessel');
        case 'SelectByValue'
            helpme('Dados\selecionar','val');
        case 'SelectByTime'
            helpme('Dados\selecionar','time');
        case 'SelectTimeNoise'
            helpme('Dados\selecionartempo');
        case 'SelectSpikes'
            helpme('Dados\selecionarspikes');
        case 'MultiPlot5'
            helpme('Dados\plotesmultiplos','mp5');
        case 'MultiPlot3'
            helpme('Dados\plotesmultiplos','mp3');
        case 'MultiGraph5'
            helpme('Dados\graficosmultiplos','mg5');
            
        case 'TableParam'
            helpme('Ferramentas\paramdetabela');
        case 'TrackPoints'
            helpme('Ferramentas\correcaoptscontrole');
        case 'TestPtCreation'
            helpme('Ferramentas\novopontodeens');
        case 'TestPtsValidation'
            helpme('Ferramentas\validacaopontosdeens');
        case 'TestPtsFitView'
            helpme('Ferramentas\visualizacaoajustes');
        case 'Event2Top'
            helpme('Ferramentas\conversoeseventos','ev2top');
        case 'Logical2Event'
            helpme('Ferramentas\conversoeseventos','logic2ev');
        case 'Event2Logical'
            helpme('Ferramentas\conversoeseventos','ev2logic');
            
       case 'PlotMachLines'
            helpme('Exibir\linhasmach');
        case 'PartialData';
            helpme('Exibir\exibirparcial');

        otherwise
            helpme('R_DAT');
    end
end

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function About_Callback(hObject, eventdata, handles)
% Fornece informações sobre o programa

str = {...
        ['Versão: ' handles.vername],...
        ['Data: ' handles.releasedate],...
        ' ',...
        'Programa desenvolvido por IPEV/EEV',...
        'Todos os direitos reservados',...
        ' ',...
        'Engenheiro responsável:',...
        'Cap Eng Leonardo Lopes - Curinga 46',...
        ' ',...    
        'Problemas, dúvidas ou sugestões:',...
        '  leonardolmfl@ipev.intraer',...
        '  leonardo_ita01@yahoo.com.br',...
    };

msgbox(str,'Sobre o R_DAT','modal'); drawnow;

% --------------------------------------------------------------------
function SearchUpdate_Callback(hObject, eventdata, handles, opt)
% Procura por atualização na rede
% opt = 0: Nao apresentar mensagens de erro
% opt = 1: Apresentar mensagens de erro
% Opt = 2: Forçar atualizaçao

if nargin == 3
    opt = 1;
end

go = 0;

updtfile = 'lastver.inf';
installfile = 'R_DAT_install.m';

set(handles.window,'Pointer','watch');
if ~exist(netpath,'dir')
    if opt == 1
        beep; uiwait(errordlg({'Caminho da rede não encontrado:',netpath},'Erro','modal')); drawnow;
    end
    return
end
if ~exist([netpath updtfile],'file')
    if opt == 1
        beep; uiwait(errordlg({'Arquivo de registro não encontrado:',[netpath updtfile]},'Erro','modal')); drawnow;
    end
    return
end
if ~exist([netpath installfile],'file')
    if opt == 1
        beep; uiwait(errordlg({'Arquivo de intalação não encontrado:',[netpath installfile]},'Erro','modal')); drawnow;
    end
    return
end

fid = fopen([netpath updtfile]);
lastver = char(fread(fid)');
fclose(fid);

load(which('DatOptions.mat'),'updt');

set(handles.window,'Pointer','arrow');

if opt == 2
    go = 1;
else
    if strcmp(handles.vername,lastver)
        if opt == 1
            updt2 = RDAT_InputOption('Aviso',{'','Não há atualização disponível.',''},...
                'Verificar ao iniciar',logical(updt),220,1);
        else
            updt2 = [];
        end
    else
        [button, updt2] = questdlg2({'Há uma versão mais recente disponível na rede.',...
                ['Deseja atualizar para a versão ' lastver '?']},'Confirmação','Verificar ao iniciar','Sim','Não','','Sim',updt);
        switch button
            case 'Sim'
                go = 1;
            case 'Não'
                % Nada a fazer
            otherwise
                updt2 = [];
        end
    end
    
    if ~isempty(updt2) && updt2 ~= updt
        updt = logical(updt2);
        save(which('DatOptions.mat'),'updt','-append',saveopt);
    end
end

if go
    
    RDATpath = which('R_DAT.m');
    ind = find(RDATpath=='\');
    RDATpath(ind(end)+1:end) = [];
    auxpath = [RDATpath 'AuxFcn\'];
    path(auxpath,path);
    
    if exist([matlabroot '\work\'],'dir') && iswrite([matlabroot '\work\'])
        destination_path = [matlabroot '\work\'];
    else
        destination_path = handles.dbpath;
    end
    dos(['copy "' netpath installfile '" "' destination_path installfile '"']);
    
    Window_CloseRequestFcn(hObject, eventdata, handles, 0);
    
    inipath = cd;
    cd(destination_path);
    R_DAT_install(0);
    cd(inipath);
    if exist([destination_path 'R_DAT_install.m'],'file')
        dos(['del "' destination_path 'R_DAT_install.m"']);
    end
    
    clear functions;
    
end

% ####################################################################
%                 CALLBACKS DOS OBJETOS DE CONTROLE
% ####################################################################

function xlist_Callback(hObject, eventdata, handles)
% Seleção do parâmetro x

UpdatePlot(hObject, eventdata, handles);

func = getappdata(handles.window,'func');

switch func
    case 'MultiPlot3_1'
        set(handles.graphs,'XLim',AutoLim(handles.plots(1:3)));
        
    case {'LatLong2DeDn_1','LatLong2RdlDist_1'}
        set(handles.graphs,'XLim',AutoLim([handles.plot handles.centerpt]));
        
    case {'MultiPlot5_1','MultiGraph5_1'}
        m = 1 + strcmp(func,'MultiGraph5_1');
        for n = 2:5
            yi = get(handles.plots(m,n),'YData');
            if ~isequalwithequalnans(yi,NaN)
                set(handles.plots(m,n),'XData',get(handles.plot,'XData'));
            end
        end
        UpdateDataTips(hObject, eventdata, handles);
        set(handles.graphs,'XLim',AutoLim(handles.plot));
        
    otherwise
        set(handles.graphs,'XLim',AutoLim(handles.plot));
        
end

% --------------------------------------------------------------------
function ylist_Callback(hObject, eventdata, handles)
% Seleção do parâmetro y

UpdatePlot(hObject, eventdata, handles);

func = getappdata(handles.window,'func');

switch func
    case 'GetBit_1'
        GetBit_Callback(hObject, eventdata, handles);
    case 'TestPtsValidation_1'
        UpdateValidationWindow(hObject, eventdata, handles, 1);
    case 'TestPtCreation_1'
        UpdateCreationWindow(hObject, eventdata, handles);
end

% -------------------------------------------------------------------------
function entry1_Callback(hObject, eventdata, handles)
% Campo de entrada de dados numero 1

PARAM = get(handles.xlist,'String');
func  = getappdata(handles.window,'func');

switch func
    case {'SelectSpikes_1','SelectTimeNoise_1'}
        EntryFix(handles.entry1);
end

switch func
    
    case 'Anemometry_1'
        opt = get(handles.entry1,'Value');
        %        1         2         3         4         5         6         7         8         9          10        11        12        13        14         15        16         17             18
        %        pa->Zp    Zp->pa    qc->Vc    Vc->qc    qc,pa->M  M->qc/pa  Zp->Ta    Ta->Zp    Zp,Ta->ro  Zp,Vc->M  Zp,M->Vc  Vc,M->Zp  M,Ta->Va  Va,M->Ta  qc,pa->Ve  Zp,Vc->Ve  Zp,QNH->Zp aj  Zp,Z->QNH
        var1 = {'pa (mb)' 'Zp (ft)' 'qc (mb)' 'Vc (kt)' 'qc (mb)' 'Mach'    'Zp (ft)' 'Ta (°C)' 'Zp (ft)'  'Zp (ft)' 'Zp (ft)' 'Vc (kt)' 'Mach'    'Va (kt)' 'qc (mb)'  'Zp (ft)'  'Zp (ft)'      'Zp (ft)'};
        var2 = {' '       ' '       ' '       ' '       'pa (mb)' ' '       ' '       ' '       'Ta (°C)'  'Vc (kt)' 'Mach'    'Mach'    'Ta (°C)' 'Mach'    'pa (mb)'  'Vc (kt)'  '       '      'Z (ft)' };
        set(handles.entry3txt,'String',var1{opt});
        set(handles.entry4txt,'String',var2{opt});
        switch opt
            case {5 9 10 11 12 13 14 15 16 18} % Two entry operations
                set([handles.entries(3:4) handles.entriestxt(3:4)],'Visible','on');
                MultiParamOperation_setgraph(hObject, eventdata, handles, 2, 0);
                entry4_Callback(hObject, eventdata, handles);
            otherwise
                set([handles.entry3 handles.entry3txt],'Visible','on');
                set([handles.entry4 handles.entry4txt],'Visible','off');
                MultiParamOperation_setgraph(hObject, eventdata, handles, 0, 0);
        end
        if any(opt==[7 8]) % DISA entry operations
            set(handles.entry2txt,'String','DISA (°C)','Visible','on');
            set(handles.entry2,'String','0','Visible','on');
        elseif opt==17 % QNH entry operations
            set(handles.entry2txt,'String','QNH(mb)','Visible','on');
            set(handles.entry2,'String','1013.25','Visible','on');
        else
            set([handles.entry2 handles.entry2txt],'Visible','off');
        end
        
    case {'InterpSelPts_1','InterpNaNPts_1'}
        switch get(handles.entry1,'Value')
            case 6
                vis = 'on';
                sty = 'edit';
                defstr = '0';
                txtstr = 'Valor:';
            case 7
                vis = 'on';
                sty = 'popupmenu';
                defstr = {'Zero','Variação anterior'};
                txtstr = 'Dif. inic.:';
            case 8
                vis = 'on';
                sty = 'popupmenu';
                defstr = {'Zero','Variação seguinte'};
                txtstr = 'Dif. final:';
            otherwise
                vis = 'off';
                sty = 'popupmenu';
                defstr = '';
                txtstr = '';
       end
        set(handles.entry2,'Visible',vis,'Style',sty,'String',defstr,'Value',1);
        set(handles.entry2txt,'Visible',vis,'String',txtstr);
        if strcmp(func,'InterpSelPts_1')
            InterpSelPts_Callback(hObject, eventdata, handles);
        else
            InterpNaNPts_Callback(hObject, eventdata, handles);
        end
        
    case 'CreateMilisec_1'
        CreateMilisec_Callback(hObject, eventdata, handles);
        
    case 'MultiPlot5_1'
        ycol = get(handles.entry1,'Value')-1;
        UpdatePlotN(hObject, eventdata, handles, 1, 2, ycol);
        
    case 'MultiPlot3_1'
        ycol = get(handles.entry1,'Value')-1;
        xcol = get(handles.entry2,'Value')-1;
        UpdatePlotN(hObject, eventdata, handles, 1, 2, ycol, xcol);
        
    case {'MergeValidSections_1','MultiGraph5_1'}
        ycol = get(handles.entry1,'Value')-1;
        UpdatePlotN(hObject, eventdata, handles, 2, 2, ycol);
        if ~ycol
            set(handles.ylabels(2),'String','y2');
        end
        MultiGraph_update(hObject, eventdata, handles);
        
    case 'UnitsConversion_1'
        ntype = get(handles.entry1,'Value');
        convlist = getappdata(handles.window,'tempdata');
        set(handles.entries(3:4),'String',convlist{ntype}(:,1),'Value',1);
        
    case 'TestPtsValidation_1'
        ycol = get(handles.entry1,'Value')-1;
        UpdatePlotN(hObject, eventdata, handles, 2, 2, ycol);
        if ~ycol
            set(handles.ylabels(2),'String','y2');
        end
        UpdateValidationWindow(hObject, eventdata, handles, 2);
        
    case 'TestPtsFitView_1'
        ycol = get(handles.entry1,'Value');
        UpdatePlot(hObject, eventdata, handles, ycol);
        TestPts_FitView_Callback(hObject, eventdata, handles);
        
    case 'TestPtCreation_1'
        ycol = get(handles.entry1,'Value')-1;
        UpdatePlotN(hObject, eventdata, handles, 2, 2, ycol);
        if ~ycol
            set(handles.ylabels(2),'String','y2');
        end
        UpdateCreationWindow(hObject, eventdata, handles);
        
    case 'ElementaryOperation_1'
        switch get(handles.entry1,'Value');
            case 1 % Exponencial
                oplist = {'Quadrado',...
                        'Cubo',...
                        'Exponencial natural',...
                        'Raiz quadrada',...
                        'Raiz cúbica',...
                        'Logaritmo natural',...
                        'Logaritmo base 2',...
                        'Logaritmo base 10',...
                        'Inverso'};
            case 2 % Arredondamento
                oplist = {'Arredondar',...
                        'Arredondar para cima',...
                        'Arredondar para baixo',...
                        'Truncar',...
                        'Módulo',...
                        'Zerar negativos',...
                        'Sinal'};
            case 3 % Estatistica
                oplist = {'Média',...
                        'Desvio padrão',...
                        'Máximo',...
                        'Mínimo',...
                        'Amplitude',...
                        'Variação',...
                        'Variância',...
                        'Mediana',...
                        'Direfenças',...
                        'Oposto'};
            case {4,5} % Trigonometria
                oplist = {'Seno',...
                        'Cosseno',...
                        'Tangente',...
                        'Secante',...
                        'Cossecante',...
                        'Cotangente',...
                        'Arco seno',...
                        'Arco cosseno',...
                        'Arco tangente',...
                        'Arco secante',...
                        'Arco cossecante',...
                        'Arco cotangente'};
            case 6 % Trigonometria hiperbólica
                oplist = {'Seno hiperbólico',...
                        'Cosseno hiperbólico',...
                        'Tangente hiperbólica',...
                        'Secante hiperbólica',...
                        'Cossecante hiperbólica',...
                        'Cotangente hiperbólica',...
                        'Inv. seno hiperbólico',...
                        'Inv. cosseno hiperb.',...
                        'Inv. tangente hiperb.',...
                        'Inv. secante hiperb.',...
                        'Inv. cossec. hiperb.',...
                        'Inv. cotang. hiperb.'};
            case 7 % Logica
                oplist = {'Não'};
            case 8 % Variaçao
                oplist = {'Nunca diminuir',...
                        'Nunca aumentar'};
                
        end
        set(handles.entry2,'String',oplist,'Value',1);
        
    case 'TwoParamOperation_1'
        ycol = get(handles.entry1,'Value');
        UpdatePlot(hObject, eventdata, handles, ycol);
        
    case 'FourParamOperation_1'
        ycol = get(handles.entry1,'Value')-1;
        UpdatePlot(hObject, eventdata, handles, ycol);
        if ~ycol
            set(handles.ylabel,'String','x');
        end
        
    case 'JoinWords_1'
        ycol = get(handles.entry1,'Value');
        UpdatePlot(hObject, eventdata, handles, ycol);
        
    case 'NumDiffer_1'
        if get(handles.entry1,'Value') == 1
            vis = 'off';
        else
            vis = 'on';
        end
        set([handles.entry3 handles.entry3txt],'Visible',vis);
        
    case 'TrajIntegration_1'
        switch get(handles.entry1,'Value')
            case {1,4} % Desloc, Lat/Long
                set([handles.entries(2:4) handles.entriestxt(2:4)],'Visible','off');
            case 2 % Veloc
                set([handles.entry2 handles.entry2txt],'Visible','on');
                set([handles.entries(3:4) handles.entriestxt(3:4)],'Visible','off');
            case 3 % Acel
                set([handles.entries(2:4) handles.entriestxt(2:4)],'Visible','on');
        end
        
    case 'DmagModel_1'
        ycol = get(handles.entry1,'Value');
        UpdatePlot(hObject, eventdata, handles, ycol);
        
    case 'DmagDpsi_1'
        ycol = get(handles.entry1,'Value');
        UpdatePlot(hObject, eventdata, handles, ycol);
        
    case {'GenerateSyncTime_1','DegMinSec2Deg_1'}
        ycol = get(handles.entry1,'Value');
        UpdatePlot(hObject, eventdata, handles, ycol);
        
    case 'FitCurve_1'
        FitCurve_Callback(hObject, eventdata, handles);
        
    case 'GoToTime_1'
        [t, str] = str2time(get(handles.entry1,'String'));
        set(handles.entry1,'String',str);
        GoToTime_Callback(hObject, eventdata, handles);
        
    case 'GoToTOP_1'
        GoToTOP_Callback(hObject, eventdata, handles);
        
    case 'GoToEvent_1'
        GoToEvent_Callback(hObject, eventdata, handles);
        
    case 'GoToPoint_1'
        GoToPoint_Callback(hObject, eventdata, handles);
        
    case 'NumInteg_1'
        opt = get(handles.entry1,'Value');
        if opt == 4
            set([handles.entry2 handles.entry2txt],'Visible','on');
        else
            set([handles.entry2 handles.entry2txt],'Visible','off');
        end
        
    case 'SignalFilter_1'
        ycol = get(handles.entry1,'Value');
        UpdatePlot(hObject, eventdata, handles, ycol);
        SignalFilter_Callback(hObject, eventdata, handles);
        
    case 'PlotMachLines_1'
        PlotMachLines_Callback(hObject, eventdata, handles);
        
    case 'SelectByValue_1'
        opt = get(handles.entry1,'Value');
        switch opt
            case {1,2,3,4,5}
                str1 = 'Valor:';
                str2 = '';
                vis  = 'off';
            otherwise
                str1 = 'Valor 1:';
                str2 = 'Valor 2:';
                vis  = 'on';
        end
        set(handles.entry3txt,'String',str1);
        set(handles.entry4txt,'String',str2,'Visible',vis);
        set(handles.entry4,'Visible',vis);
        
    case 'SelectByTime_1'
        [t, str] = str2time(get(handles.entry1,'String'));
        set(handles.entry1,'String',str);
        
    case 'CreateParam_1'
        opt = get(handles.entry1,'Value');
        if opt == 6
            SetButtonStatus(handles,handles.Hist_btn,1);
        else
            SetButtonStatus(handles,handles.Hist_btn,0);
        end
        
        switch opt
            case 1  % Duplicar
                set(handles.entry2,'Style','popupmenu','String',PARAM,'Value',get(handles.ylist,'Value'));
                set(handles.entry2txt,'String','Param.:');
                set([handles.entry2 handles.entry2txt],'Visible','on');
                set([handles.entries(3:4) handles.entriestxt(3:4)],'Visible','off');
                
            case 2  % Série de zeros
                set([handles.entries(2:4) handles.entriestxt(2:4)],'Visible','off');
                
            case 3  % Série de uns
                set([handles.entries(2:4) handles.entriestxt(2:4)],'Visible','off');
                
            case 4  % Série constante
                set(handles.entry2,'Style','edit','String','0');
                set(handles.entry2txt,'String','Valor:');
                set([handles.entry2 handles.entry2txt],'Visible','on');
                set([handles.entries(3:4) handles.entriestxt(3:4)],'Visible','off');
                
            case 5  % Série crescente
                set(handles.entry3,'Style','edit','String','0');
                set(handles.entry4,'Style','edit','String','1');
                set(handles.entry3txt,'String','Inicial:');
                set(handles.entry4txt,'String','Final:');
                set([handles.entry2 handles.entry2txt],'Visible','off');
                set([handles.entries(3:4) handles.entriestxt(3:4)],'Visible','on');
                
            case 6  % Série aleatória
                pdf_name = {'Beta','Chi-Quadrada','Uniforme Discreta','Exponencial','F','Gama','Lognormal',...
                        'Binomial Negativa','Normal','Rayleigh','T de Student','Uniforme','Weibull'};
                set(handles.entry2,'Style','popupmenu','String',pdf_name,'Value',9);
                set(handles.entries(3:4),'Style','edit','String','');
                set(handles.entry2txt,'String','Distrib.:');
                set([handles.entries(2:4) handles.entriestxt(2:4)],'Visible','on');
                entry2_Callback(hObject, eventdata, handles);
        end
        if opt ~= 6
            CreateParam_Callback(hObject, eventdata, handles);
        end
        
    case 'GetBit_1'
        GetBit_Callback(hObject, eventdata, handles);
        
    case 'SetBit_2'
        SetBit_Callback(hObject, eventdata, handles);
        
    case {'LatLong2DeDn_1','DeDn2LatLong_1','LatLong2RdlDist_1','RdlDist2LatLong_1'}
        str1 = get(handles.entry1,'String');
        [str2,Lat0] = latlongread(str1,1);
        if isempty(str2)
            beep; uiwait(errordlg(['Coordenada inválida: ' str1 '.'],'Erro','modal')); drawnow;
            Lat0 = NaN;
        end
        if strcmp(func,'LatLong2DeDn_1') || strcmp(func,'LatLong2RdlDist_1')
            set(handles.centerpt,'YData',Lat0);
        end
        set(handles.entry1,'String',str2);
        
    case 'Interp1D_1'
        ycol = get(handles.entry1,'Value');
        UpdatePlot(hObject, eventdata, handles, ycol);
        
    case 'Resample_1'
        [t,str] = str2time(get(handles.entry1,'String'));
        set(handles.entry1,'String',str);
        
    case 'ChangeRate_1'
        if get(handles.entry1,'Value') == 1
            vis = 'off';
        else
            vis = 'on';
        end
        set([handles.entry3txt handles.entry3],'Visible',vis);
        
    case 'SelectSpikes_1'
        SelectSpikes_Callback(hObject, eventdata, handles);
        
    case 'SelectTimeNoise_1'
        SelectTimeNoise_Callback(hObject, eventdata, handles);
        
    case 'Logical2Event_1'
        switch get(handles.entry1,'Value')
            case 1
                set([handles.entry3 handles.entry3txt],'Visible','on');
                set([handles.entry4 handles.entry4txt],'Visible','off');
            case 2
                set([handles.entry3 handles.entry3txt],'Visible','off');
                set([handles.entry4 handles.entry4txt],'Visible','on');
            case 3
                set([handles.entry3 handles.entry3txt],'Visible','on');
                set([handles.entry4 handles.entry4txt],'Visible','on');
        end
end

% -------------------------------------------------------------------------
function entry2_Callback(hObject, eventdata, handles)
% Campo de entrada de dados numero 2

PARAM = get(handles.xlist,'String');
func  = getappdata(handles.window,'func');

switch func
    case {'OneParamOperation_1','Anemometry_1','NumInteg_1','SelectSpikes_1','SelectTimeNoise_1','GoToTime_1','FitCurve_1'}
        EntryFix(handles.entry2);
    case 'CreateParam_1'
        if get(handles.entry1,'Value') == 4
            EntryFix(handles.entry2);
        end
    case {'GoToEvent_1','GoToTOP_1'}
        if strcmp(get(handles.entry2,'Style'),'edit')
            EntryFix(handles.entry2);
        end
    case {'InterpSelPts_1','InterpNaNPts_1'}
        if get(handles.entry1,'Value') == 6
            EntryFix(handles.entry2);
        end
end

switch func
    
    case 'InterpSelPts_1'
        InterpSelPts_Callback(hObject, eventdata, handles);
        
    case 'InterpNaNPts_1'
        InterpNaNPts_Callback(hObject, eventdata, handles);
        
    case 'MultiPlot5_1'
        ycol = get(handles.entry2,'Value')-1;
        UpdatePlotN(hObject, eventdata, handles, 1, 3, ycol);
        
    case 'MultiPlot3_1'
        ycol = get(handles.entry1,'Value')-1;
        xcol = get(handles.entry2,'Value')-1;
        UpdatePlotN(hObject, eventdata, handles, 1, 2, ycol, xcol);
        set(handles.graphs,'XLim',AutoLim([handles.plot handles.plots(1,2) handles.plots(1,3)]));
        
    case {'MergeValidSections_1','MultiGraph5_1'}
        ycol = get(handles.entry2,'Value')-1;
        UpdatePlotN(hObject, eventdata, handles, 2, 3, ycol);
        if ~ycol
            set(handles.ylabels(3),'String','y3');
        end
        MultiGraph_update(hObject, eventdata, handles);
        
    case 'TestPtCreation_1'
        if get(handles.entry2,'Value') == 1
            set(handles.entry4,'Visible','off');
        else
            set(handles.entry4,'Visible','on');
        end
        entry4_Callback(hObject, eventdata, handles);
        
    case 'TestPtsValidation_1'
        testpts = getappdata(handles.window,'testpts');
        ngrp = get(handles.entry2,'Value');
        ptslist{1} = ' ';
        for n = 1:length(testpts(ngrp).number)
            ptslist{n+1} = [testpts(ngrp).number{n} ' - ' testpts(ngrp).descr{n}];
        end
        set(handles.entry4,'String',ptslist,'Value',1);
        entry4_Callback(hObject, eventdata, handles);
        
    case 'TestPtsFitView_1'
        testpts = getappdata(handles.window,'testpts');
        ngrp = get(handles.entry2,'Value');
        ptslist{1} = ' ';
        for n = 1:length(testpts(ngrp).number)
            ptslist{n+1} = [testpts(ngrp).number{n} ' - ' testpts(ngrp).descr{n}];
        end
        set(handles.entry4,'String',ptslist,'Value',1);
        entry4_Callback(hObject, eventdata, handles);
        for n = 1:length(testpts(ngrp).param)
            npar = findpar(PARAM,testpts(ngrp).param{n},1,1); 
            if ~isempty(npar) && testpts(ngrp).fit(n)
                PARAM{npar} = ['*' PARAM{npar}];
            end
        end
        set(handles.entry1,'String',PARAM);
        
    case 'TwoParamOperation_1'
        ycol = get(handles.entry2,'Value');
        UpdatePlotN(hObject, eventdata, handles, 2, 2, ycol);
        
    case 'FourParamOperation_1'
        ycol = get(handles.entry2,'Value')-1;
        UpdatePlotN(hObject, eventdata, handles, 2, 2, ycol);
        if ~ycol
            set(handles.ylabels(2),'String','y');
        end
        
    case 'JoinWords_1'
        ycol = get(handles.entry2,'Value');
        UpdatePlotN(hObject, eventdata, handles, 2, 2, ycol);
        
    case {'GenerateSyncTime_1','DegMinSec2Deg_1'}
        ycol = get(handles.entry2,'Value');
        UpdatePlotN(hObject, eventdata, handles, 2, 2, ycol);
        
    case 'FitCurve_1'
        FitCurve_Callback(hObject, eventdata, handles, 1);
        
    case 'GoToTime_1'
        GoToTime_Callback(hObject, eventdata, handles);
        
    case 'GoToTOP_1'
        GoToTOP_Callback(hObject, eventdata, handles);
        
    case 'GoToEvent_1'
        GoToEvent_Callback(hObject, eventdata, handles);
        
    case 'CircInterv_1'
        switch get(handles.entry2,'Value')
            case 1 % Graus
                str = {'0 a 360°','-180 a 180°','Contínuo','Trig --> Geo','Geo --> Trig'};
            case 2 % Rad
                str = {'0 a 2.pi','-pi a pi','Contínuo','Trig --> Geo','Geo --> Trig'};
        end
        set(handles.entry1,'String',str);
        
    case 'DmagModel_1'
        ycol = get(handles.entry1,'Value');
        xcol = get(handles.entry2,'Value');
        UpdatePlot(hObject, eventdata, handles, ycol, xcol);
        set(handles.graphs,'XLim',AutoLim(handles.plot));
        
    case 'DmagDpsi_1'
        ycol = get(handles.entry2,'Value');
        UpdatePlotN(hObject, eventdata, handles, 1, 2, ycol);
        
    case 'SignalFilter_1'
        filteropt = getappdata(handles.window,'filteropt');
        setappdata(handles.window,'filteropt',{filteropt{1},filteropt{2},get(handles.entry2,'Value')});
        SignalFilter_Callback(hObject, eventdata, handles);
        
    case 'CreateParam_1'
        opt = get(handles.entry1,'Value');
        if opt == 6  % Série aleatória
            %           beta chi2 unid exp  f     gam logn    nbin  norm    rayl t    unif weib};
            pdf_par1 = {'a'  'nu' 'N'  'mu' 'nu1' 'a' 'mu'    'r'   'mu'    'b'  'nu' 'N1' 'a'};
            pdf_par2 = {'b'  ''   ''   ''   'nu2' 'b' 'sigma' 'p'   'sigma' ''   ''   'N2' 'b'};
            pdf_def1 = {'2'  '10' '10' '1'  '10'  '2' '0'     '1'   '0'     '1'  '10' '0'  '2'};
            pdf_def2 = {'2'  ''   ''   ''   '10'  '2' '1'     '0.2' '1'     ''   ''   '1'  '2'};
            Npdf = get(handles.entry2,'Value');
            set(handles.entry3txt,'String',pdf_par1{Npdf});
            set(handles.entry4txt,'String',pdf_par2{Npdf});
            set(handles.entry3,'String',pdf_def1{Npdf});
            set(handles.entry4,'String',pdf_def2{Npdf});
            if isempty(pdf_par2{Npdf})
                set([handles.entry4 handles.entry4txt],'Visible','off');
            else
                set([handles.entry4 handles.entry4txt],'Visible','on');
            end
        end
        CreateParam_Callback(hObject, eventdata, handles);
        
    case 'GetBit_1'
        GetBit_Callback(hObject, eventdata, handles);
        
    case 'SetBit_2'
        SetBit_Callback(hObject, eventdata, handles);
        
    case {'LatLong2DeDn_1','DeDn2LatLong_1','LatLong2RdlDist_1','RdlDist2LatLong_1'}
        str1 = get(handles.entry2,'String');
        [str2,Lon0] = latlongread(str1,2);
        if isempty(str2)
            beep; uiwait(errordlg(['Coordenada inválida: ' str1 '.'],'Erro','modal')); drawnow;
            Lon0 = NaN;
        end
        if strcmp(func,'LatLong2DeDn_1') || strcmp(func,'LatLong2RdlDist_1')
            set(handles.centerpt,'XData',Lon0);
        end
        set(handles.entry2,'String',str2);
        
    case {'DeDn2RdlDist_1','RdlDist2DeDn_1','PsiConversion_1'}
        switch get(handles.entry2,'Style')
            case 'popupmenu'
                n = get(handles.entry2,'Value');
                if n == 1
                    pause(.5);
                    set(handles.entry2,'Style','edit','String','0');
                end
            case 'edit'
                EntryFix(handles.entry2);
                Dmag = str2double(get(handles.entry2,'String'));
                if ~isnan(Dmag)
                    Dmag = max(-90,min(90,Dmag));
                    set(handles.entry2,'String',num2str(Dmag))
                end
        end
        
    case 'Resample_1'
        [t,str] = str2time(get(handles.entry2,'String'));
        set(handles.entry2,'String',str);
        
    case 'SelectByTime_1'
        [t, str] = str2time(get(handles.entry2,'String'));
        set(handles.entry2,'String',str);
        
    case 'SelectSpikes_1'
        SelectSpikes_Callback(hObject, eventdata, handles);
        
    case 'SelectTimeNoise_1'
        SelectTimeNoise_Callback(hObject, eventdata, handles);
        
end

% -------------------------------------------------------------------------
function entry3_Callback(hObject, eventdata, handles)
% Campo de entrada de dados numero 3

func  = getappdata(handles.window,'func');

switch func
    case {'SelectByValue_1','CreateParam_1','TrajIntegration_1','CourseCalculation_1','Resample_1'}
        EntryFix(handles.entry3);
end

switch func
    
    case 'InterpSelPts_1'
        InterpSelPts_Callback(hObject, eventdata, handles);
        
    case 'InterpNaNPts_1'
        InterpNaNPts_Callback(hObject, eventdata, handles);
        
    case 'Anemometry_1'
        ycol = get(handles.entry3,'Value');
        UpdatePlot(hObject, eventdata, handles, ycol);
        
    case 'MultiPlot5_1'
        ycol = get(handles.entry3,'Value')-1;
        UpdatePlotN(hObject, eventdata, handles, 1, 4, ycol);
        
    case 'MultiPlot3_1'
        ycol = get(handles.entry3,'Value')-1;
        xcol = get(handles.entry4,'Value')-1;
        UpdatePlotN(hObject, eventdata, handles, 1, 3, ycol, xcol);
        
    case {'MergeValidSections_1','MultiGraph5_1'}
        ycol = get(handles.entry3,'Value')-1;
        UpdatePlotN(hObject, eventdata, handles, 2, 4, ycol);
        if ~ycol
            set(handles.ylabels(4),'String','y4');
        end
        MultiGraph_update(hObject, eventdata, handles)
        
    case 'TestPtsValidation_1'
        ycol = get(handles.entry3,'Value')-1;
        UpdatePlotN(hObject, eventdata, handles, 2, 3, ycol);
        if ~ycol
            set(handles.ylabels(3),'String','y3');
        end
        UpdateValidationWindow(hObject, eventdata, handles, 3);
        
    case 'TestPtCreation_1'
        ycol = get(handles.entry3,'Value')-1;
        UpdatePlotN(hObject, eventdata, handles, 2, 3, ycol);
        if ~ycol
            set(handles.ylabels(3),'String','y3');
        end
        UpdateCreationWindow(hObject, eventdata, handles);
        
    case 'FourParamOperation_1'
        ycol = get(handles.entry3,'Value')-1;
        UpdatePlotN(hObject, eventdata, handles, 2, 3, ycol);
        if ~ycol
            set(handles.ylabels(3),'String','z');
        end
        
    case {'GenerateSyncTime_1','DegMinSec2Deg_1'}
        ycol = get(handles.entry3,'Value');
        UpdatePlotN(hObject, eventdata, handles, 2, 3, ycol);
        
    case 'GoToTOP_1'
        opt = get(handles.entry3,'Value');
        switch opt
            case 1 % Centralizado
                set(handles.entry1,'Value',1);
                set(handles.entry2,'Style','edit','String','-5','Visible','on');
                set(handles.entry2txt,'String','Intervalo:','Visible','on');
                set(handles.entry4,'Style','edit','String','5','Visible','on');
                set(handles.entry4txt,'String','(s)','HorizontalAlignment','left','Visible','on');
                SetEntriesForInterval(handles,1);
            case 2 % Entre TOPs
                set([handles.entry1 handles.entry2],'Style','popupmenu','String',get(handles.entry1,'String'),'Value',1);
                set(handles.entry2txt,'String','até:','Visible','on');
                set([handles.entry4 handles.entry4txt],'Visible','off');
                SetEntriesForInterval(handles,0);
        end
        GoToTOP_Callback(hObject, eventdata, handles);
        
    case 'GoToEvent_1'
        opt = get(handles.entry3,'Value');
        switch opt
            case 1 % Centralizado
                set(handles.entry1,'Value',1);
                set(handles.entry2,'Style','edit','String','-5','Visible','on');
                set(handles.entry2txt,'String','Intervalo:','Visible','on');
                set(handles.entry4,'Style','edit','String','5','Visible','on');
                set(handles.entry4txt,'String','(s)','HorizontalAlignment','left','Visible','on');
                SetEntriesForInterval(handles,1);
            case 2 % Entre eventos
                set([handles.entry1 handles.entry2],'Style','popupmenu','String',get(handles.entry1,'String'),'Value',1);
                set(handles.entry2txt,'String','até:','Visible','on');
                set([handles.entry4 handles.entry4txt],'Visible','off');
                SetEntriesForInterval(handles,0);
        end
        GoToEvent_Callback(hObject, eventdata, handles);
        
    case 'Interp1D_1'
        [fname,fpath,ind] = uigetfile({'*.txt;*.dat', 'Dados em formato texto (*.txt, *.dat)'; ...
                '*.xls','Planilha MS Excel (*.xls)'}, 'Indique o arquivo com a curva de interpolação',handles.fpath); drawnow;
        if ischar(fname)
            switch ind
                case 1 % txt
                    try
                        [dat, hdr] = txtread([fpath,fname]);
                    catch
                        dat = [];
                        hdr = [];
                    end
                case 2 % xls
                    try
                        [dat, hdr] = xlsread([fpath,fname]);
                    catch
                        dat = [];
                        hdr = [];
                    end
            end
            if size(hdr,1) > 0 && size(hdr,2) > 1
                xlbl = hdr{1,1};
                ylbl = hdr{1,2};
            else
                xlbl = 'x';
                ylbl = 'y';
            end
            if size(dat,1) < 2 || size(dat,2) ~= 2
                beep; uiwait(errordlg('Formato incompatível.','Erro','modal')); drawnow;
                fname = 'Localizar ...';
                dat = [];
            else
                key_CB = 'cc=get(gcf,''CurrentCharacter''); if cc==13 || cc==27, delete(gcf); end';
                ss = get(0,'ScreenSize');
                hf = figure('NumberTitle','off','Menubar','none','Name','Visualização de Curva de Interpolação',...
                    'Color',get(handles.window,'Color'),'Position',[.5*(ss(3)-560) .5*(ss(4)-450) 560 450],'Resize','off',...
                    'Visible','off','Tag','aux','KeyPressFcn',key_CB);
                axes('Units','pixels','Position',[70 60 450 360],'Box','on','XGrid','on','YGrid','on','NextPlot','add');
                uicontrol('Style','pushbutton','String','OK','Position',[10 10 50 20],'Callback','delete(gcf)');
                plot(dat(:,1),dat(:,2),'.-b');
                plot([min(get(handles.plot,'YData')) max(get(handles.plot,'YData'))], min(get(gca,'YLim'))*[1 1],'+-r',...
                    'MarkerSize',10);
                xlabel(xlbl,'Interpreter','none');
                ylabel(ylbl,'Interpreter','none');
                title(fname,'Interpreter','none');
                
                set(hf,'Visible','on');
            end
            
            handles.fpath = fpath;
            guidata(hObject, handles);
            set(handles.entry3,'String',fname);
            setappdata(handles.window,'tempdata',dat);
        end
        
    case 'Interp2D_1'
        [fname,fpath,ind] = uigetfile({'*.txt;*.dat', 'Dados em formato texto (*.txt, *.dat)'; ...
                '*.xls','Planilha MS Excel (*.xls)'}, 'Indique o arquivo com a tabela de interpolação',handles.fpath); drawnow;
        if ischar(fname)
            switch ind
                case 1 % txt
                    try
                        dat = load([fpath fname]);
                    catch
                        dat = [];
                    end
                case 2 % xls
                    try
                        dat = xlsread([fpath,fname]);
                    catch
                        dat = [];
                    end
            end
            if size(dat,1) < 3 || size(dat,2) < 3
                beep; uiwait(errordlg('Formato incompatível.','Erro','modal')); drawnow;
                fname = 'Localizar ...';
                dat = [];
            else
                key_CB = 'cc=get(gcf,''CurrentCharacter''); if cc==13 || cc==27, delete(gcf); end';
                ss = get(0,'ScreenSize');
                hf = figure('NumberTitle','off','Menubar','none','Name','Visualização de Tabela de Interpolação',...
                    'Color',get(handles.window,'Color'),'Position',[.5*(ss(3)-560) .5*(ss(4)-450) 560 450],'Resize','off',...
                    'Visible','off','Tag','aux','KeyPressFcn',key_CB);
                uicontrol('Style','pushbutton','String','OK','Position',[10 10 50 20],'Callback','delete(gcf)');
                
                x = dat(2:end,1);
                y = dat(1,2:end);
                Z = dat(2:end,2:end)';
                [X,Y] = meshgrid(x,y);
                mesh(X,Y,Z);
                
                set(gca,'Units','pixels','Box','on','XGrid','on','YGrid','on','ZGrid','on','NextPlot','add');
                plot3(get(handles.plot,'XData'),get(handles.plot,'YData'),min(get(gca,'ZLim')).*ones(size(get(handles.plot,'XData'))),'-b');
                plot3([min(x) max(x) max(x) min(x) min(x)],[min(y) min(y) max(y) max(y) min(y)],min(get(gca,'ZLim')).*ones(1,5),'-r');
                axis vis3d
                colorbar('vert')
                rotate3d on
                
                xlabel('x');
                ylabel('y');
                zlabel('z');
                title(fname,'Interpreter','none');
                
                set(hf,'Visible','on');
            end
            
            handles.fpath = fpath;
            guidata(hObject, handles);
            set(handles.entry3,'String',fname);
            setappdata(handles.window,'tempdata',dat);
        end
        
    case 'CreateParam_1'
        CreateParam_Callback(hObject, eventdata, handles);
        
    case 'GetBit_1'
        GetBit_Callback(hObject, eventdata, handles);
        
    case 'SetBit_2'
        SetBit_Callback(hObject, eventdata, handles);
        
    case 'SignalFilter_1'
        filteropt = getappdata(handles.window,'filteropt');
        [Hd, stp] = RDAT_LoadFilter(filteropt{2}); drawnow;
        if ~isempty(Hd)
            setappdata(handles.window,'filteropt',{Hd,stp,get(handles.entry2,'Value')});
            SignalFilter_Callback(hObject, eventdata, handles);
        end
        
    case 'SelectSpikes_1'
        SelectSpikes_Callback(hObject, eventdata, handles);
        
    case 'SelectTimeNoise_1'
        SelectTimeNoise_Callback(hObject, eventdata, handles);
        
end

% -------------------------------------------------------------------------
function entry4_Callback(hObject, eventdata, handles)
% Campo de entrada de dados numero 4

PARAM = get(handles.xlist,'String');
func  = getappdata(handles.window,'func');

switch func
    case {'CreateParam_1','SelectByValue_1','TrajIntegration_1','GoToTOP_1','GoToEvent_1','GoToTime_1'}
        EntryFix(handles.entry4);
end

switch func
    
    case 'Anemometry_1'
        ycol = get(handles.entry4,'Value');
        UpdatePlotN(hObject, eventdata, handles, 2, 2, ycol);
        
    case 'DmagModel_1'
        dat = dateread(get(handles.entry4,'String'));
        if isempty(dat)
            set(handles.entry4,'String','');
        else
            set(handles.entry4,'String',dat);
        end
        
    case {'CourseCalculation_1','LatLong2RdlDist_1','RdlDist2LatLong_1'}
        switch get(handles.entry4,'Style')
            case 'popupmenu'
                n = get(handles.entry4,'Value');
                if n == 1
                    pause(.5);
                    set(handles.entry4,'Style','edit','String','0');
                end
            case 'edit'
                EntryFix(handles.entry4);
                Dmag = str2double(get(handles.entry4,'String'));
                if ~isnan(Dmag)
                    Dmag = max(-90,min(90,Dmag));
                    set(handles.entry4,'String',num2str(Dmag))
                end
        end
        
    case 'MultiPlot5_1'
        ycol = get(handles.entry4,'Value')-1;
        UpdatePlotN(hObject, eventdata, handles, 1, 5, ycol);
        
    case 'MultiPlot3_1'
        ycol = get(handles.entry3,'Value')-1;
        xcol = get(handles.entry4,'Value')-1;
        UpdatePlotN(hObject, eventdata, handles, 1, 3, ycol, xcol);
        set(handles.graphs,'XLim',AutoLim([handles.plot handles.plots(1,2) handles.plots(1,3)]));
        
    case {'MergeValidSections_1','MultiGraph5_1'}
        ycol = get(handles.entry4,'Value')-1;
        UpdatePlotN(hObject, eventdata, handles, 2, 5, ycol);
        if ~ycol
            set(handles.ylabels(5),'String','y5');
        end
        MultiGraph_update(hObject, eventdata, handles);
        
    case 'FourParamOperation_1'
        ycol = get(handles.entry4,'Value')-1;
        UpdatePlotN(hObject, eventdata, handles, 2, 4, ycol);
        if ~ycol
            set(handles.ylabels(4),'String','w');
        end
        
    case 'GenerateSyncTime_1'
        ycol = get(handles.entry4,'Value')-1;
        UpdatePlotN(hObject, eventdata, handles, 2, 4, ycol);
        if ~ycol
            set(handles.ylabels(4),'String','ms');
        end
        
    case 'SetBit_2'
        SetBit_Callback(hObject, eventdata, handles);
        
    case 'TestPtCreation_1'
        if get(handles.entry2,'Value') ~= 2
            return
        end
        
        npt = get(handles.entry4,'Value')-1;
        if ~npt
            setappdata(handles.window,'tempdata',[NaN NaN]);
            UpdateCreationWindow(hObject, eventdata, handles);
            return
        end
        
        testpts = getappdata(handles.window,'testpts');
        testptstime  = [testpts.time];
        
        Tini = testptstime(1,npt);
        Tend = testptstime(2,npt);
        
        if isnan(Tend-Tini)
            beep; uiwait(errordlg('Intervalo do ponto não definido corretamente.','Erro','modal')); drawnow;
            return
        end
        
        T = get(handles.plot,'XData');
        
        if Tend < min(T) || Tini > max(T)
            beep; uiwait(errordlg({['Intervalo do ponto [' time2str2(Tini) ', ' time2str2(Tend) ']'],...
                    ['fora do intervalo de dados [' time2str2(min(T)) ', ' time2str2(max(T)) '].']}, 'Erro','modal')); drawnow;
            return
        end
        
        x1 = max(Tini,min(T));
        x2 = min(Tend,max(T));
        d = x2-x1;
        x1 = x1-d/5;
        x2 = x2+d/5;
        
        set(handles.graphs,'XLim',AutoLim(handles.plot),'YLimMode','auto');
        pause(.2)
        
        set(handles.graphs,'YLimMode','manual');
        for n = 1:3
            if strcmpi(get(handles.graphs(n),'Visible'),'on')
                ay = get(handles.graphs(n),'YLim');
                set(handles.auxlines(n),'XData',[x1 x1 NaN x2 x2],'YData',[ay NaN ay],'Visible','on');
            end
        end
        pause(.5);
        set(handles.auxlines,'Visible','off');
        set(handles.graphs,'YLimMode','auto');
        
        set(handles.graphs,'XLim',[x1 x2]);
        pause(.2);
        
        set(handles.auxlines,'Visible','off');
        set(handles.graphs,'YLimMode','auto');
        
        setappdata(handles.window,'tempdata',[Tini Tend]);
        UpdateCreationWindow(hObject, eventdata, handles);
        Window_ButtonMotionFcn(hObject, eventdata, handles);
        
    case 'SignalFilter_1'
        SignalFilter_Callback(hObject, eventdata, handles);
        
    case 'CreateParam_1'
        CreateParam_Callback(hObject, eventdata, handles);
        
    case 'GoToTime_1'
        GoToTime_Callback(hObject, eventdata, handles);
        
    case 'GoToTOP_1'
        GoToTOP_Callback(hObject, eventdata, handles);
        
    case 'GoToEvent_1'
        GoToEvent_Callback(hObject, eventdata, handles);
        
    case 'TestPtsValidation_1'
        testpts = getappdata(handles.window,'testpts');
        X = get(handles.plot,'XData');
        ngrp = get(handles.entry2,'Value');
        npt  = get(handles.entry4,'Value')-1;
        if npt && ~isempty(testpts(ngrp).number)
            Tini = testpts(ngrp).time(1,npt);
            Tend = testpts(ngrp).time(2,npt);
            if ~isnan(Tend-Tini)
                Tini = max(min(X),Tini);
                Tend = min(max(X),Tend);
                if Tend-Tini < 1e-4
                    Tend = Tini + .5;
                    Tini = Tini - .5;
                end
                dT = Tend-Tini;
                set(handles.graphs,'XLim',[Tini-dT/4 Tend+dT/4]);
            end
        end
        for n = 1:length(testpts(ngrp).param)
            npar = findpar(PARAM,testpts(ngrp).param{n},1,1); 
            if npt && ~isempty(npar) && any(~isnan([...
                        testpts(ngrp).aim(npt,n)   ,...
                        testpts(ngrp).range1(npt,n),...
                        testpts(ngrp).range2(npt,n),...
                        testpts(ngrp).tol1(npt,n)  ,...
                        testpts(ngrp).tol2(npt,n)  ] ))
                PARAM{npar} = ['*' PARAM{npar}];
            end
        end
        set(handles.ylist,'String',PARAM);
        set(handles.entries([1,3]),'String',[{' '};PARAM]);
        UpdateValidationWindow(hObject, eventdata, handles);

    case 'TestPtsFitView_1'
        testpts = getappdata(handles.window,'testpts');
        X = get(handles.plot,'XData');
        ngrp = get(handles.entry2,'Value');
        npt  = get(handles.entry4,'Value')-1;
        if npt && ~isempty(testpts(ngrp).number)
            Tini = testpts(ngrp).time(1,npt);
            Tend = testpts(ngrp).time(2,npt);
            if ~isnan(Tend-Tini)
                Tini = max(min(X),Tini);
                Tend = min(max(X),Tend);
                if Tend-Tini < 1e-4
                    Tend = Tini + .5;
                    Tini = Tini - .5;
                end
                dT = Tend-Tini;
                set(handles.graphs,'XLim',[Tini-dT/4 Tend+dT/4]);
            end
        end
        TestPts_FitView_Callback(hObject, eventdata, handles);
        
end

% -------------------------------------------------------------------------
function ok_btn_Callback(hObject, eventdata, handles)
% Botao Ok

setappdata(handles.window,'ok',1);
func = getappdata(handles.window,'func');

switch func(1:end-2)
    case 'GenerateSyncTime'
        GenerateSyncTime_Callback(hObject, eventdata, handles);
    case 'DegMinSec2Deg'
        DegMinSec2Deg_Callback(hObject, eventdata, handles);
    case 'MergeValidSections'
        MergeValidSections_Callback(hObject, eventdata, handles);
    case 'SignalFilter'
        SignalFilter_Callback(hObject, eventdata, handles);
    case 'InterpSelPts'
        InterpSelPts_Callback(hObject, eventdata, handles);
    case 'InterpNaNPts'
        InterpNaNPts_Callback(hObject, eventdata, handles);
    case 'CreateMilisec'
        CreateMilisec_Callback(hObject, eventdata, handles);
    case 'ChangeRate'
        ChangeRate_Callback(hObject, eventdata, handles);
    case 'Resample'
        Resample_Callback(hObject, eventdata, handles);
    case 'CircInterv'
        ChangeCircularInterval_Callback(hObject, eventdata, handles);
    case 'CenterOnSelPt'
        CenterOnSelPt_Callback(hObject, eventdata, handles);
    case 'ElementaryOperation'
        ElementaryOperation_Callback(hObject, eventdata, handles);
    case 'OneParamOperation'
        OneParamOperation_Callback(hObject, eventdata, handles);
    case 'TwoParamOperation'
        TwoParamOperation_Callback(hObject, eventdata, handles);
    case 'FourParamOperation'
        FourParamOperation_Callback(hObject, eventdata, handles);
    case 'GetBit'
        GetBit_Callback(hObject, eventdata, handles);
    case 'SetBit'
        SetBit_Callback(hObject, eventdata, handles);
    case 'JoinWords'
        JoinWords_Callback(hObject, eventdata, handles);
    case 'Interp1D'
        Interp1D_Callback(hObject, eventdata, handles);
    case 'Interp2D'
        Interp2D_Callback(hObject, eventdata, handles);
    case 'Anemometry'
        Anemometry_Callback(hObject, eventdata, handles);
    case 'UnitsConversion'
        UnitsConversion_Callback(hObject, eventdata, handles);
    case 'LatLong2DeDn'
        LatLong2DeDn_Callback(hObject, eventdata, handles);
    case 'DeDn2LatLong'
        DeDn2LatLong_Callback(hObject, eventdata, handles);
    case 'LatLong2RdlDist'
        LatLong2RdlDist_Callback(hObject, eventdata, handles);
    case 'RdlDist2LatLong'
        RdlDist2LatLong_Callback(hObject, eventdata, handles);
    case 'DeDn2RdlDist'
        DeDn2RdlDist_Callback(hObject, eventdata, handles);
    case 'RdlDist2DeDn'
        RdlDist2DeDn_Callback(hObject, eventdata, handles);
    case 'TrajIntegration'
        TrajIntegration_Callback(hObject, eventdata, handles);
    case 'CourseCalculation'
        CourseCalculation_Callback(hObject, eventdata, handles);
    case 'DmagModel'
        DmagModel_Callback(hObject, eventdata, handles);
    case 'DmagDpsi'
        DmagDpsi_Callback(hObject, eventdata, handles);
    case 'PsiConversion'
        PsiConversion_Callback(hObject, eventdata, handles)
    case 'NumInteg'
        NumericInteg_Callback(hObject, eventdata, handles);
    case 'NumDiffer'
        NumericDiffer_Callback(hObject, eventdata, handles);
    case 'FitCurve'
        FitCurve_Callback(hObject, eventdata, handles);
        
    case 'GoToTime'
        GoToTime_Callback(hObject, eventdata, handles);
    case 'GoToTOP'
        GoToTOP_Callback(hObject, eventdata, handles);
    case 'GoToEvent'
        GoToEvent_Callback(hObject, eventdata, handles);
    case 'GoToPoint'
        GoToPoint_Callback(hObject, eventdata, handles);
    case 'CreateParam'
        CreateParam_Callback(hObject, eventdata, handles);
    case 'RenameParamY'
        RenameParamY_Callback(hObject, eventdata, handles);
    case 'GetFromWorkspace'
        GetFromWorkspace_Callback(hObject, eventdata, handles);
    case 'SelectByValue'
        SelectByValue_Callback(hObject, eventdata, handles);
    case 'SelectByTime'
        SelectByTime_Callback(hObject, eventdata, handles);
    case 'SelectTimeNoise'
        SelectTimeNoise_Callback(hObject, eventdata, handles);
    case 'SelectSpikes'
        SelectSpikes_Callback(hObject, eventdata, handles);
    case 'MultiPlot5'
        MultiPlot5_Callback(hObject, eventdata, handles);
    case 'MultiPlot3'
        MultiPlot3_Callback(hObject, eventdata, handles);
    case 'MultiGraph5'
        MultiGraph5_Callback(hObject, eventdata, handles);
        
    case 'TableParam'
        TableParam_Callback(hObject, eventdata, handles);
    case 'TrackPoints'
        TrackPoints_Callback(hObject, eventdata, handles);
    case 'TestPtCreation'
        TestPts_Create_Callback(hObject, eventdata, handles);
    case 'TestPtsValidation'
        TestPts_Validation_Callback(hObject, eventdata, handles);
    case 'TestPtsFitView'
        TestPts_FitView_Callback(hObject, eventdata, handles);
    case 'Event2Top'
        Event2Top_Callback(hObject, eventdata, handles);
    case 'Logical2Event'
        Logical2Event_Callback(hObject, eventdata, handles);
    case 'Event2Logical'
        Event2Logical_Callback(hObject, eventdata, handles);
        
    case 'PlotMachLines'
        PlotMachLines_Callback(hObject, eventdata, handles);
        
end

setappdata(handles.window,'ok',0);

% -------------------------------------------------------------------------
function cancel_btn_Callback(hObject, eventdata, handles)
% Botao Cancela

setappdata(handles.window,'cancel',1);
ok_btn_Callback(hObject, eventdata, handles);
setappdata(handles.window,'func','none');
setappdata(handles.window,'cancel',0);
setappdata(handles.window,'tempdata',[]);
set(handles.window,'CloseRequestFcn','R_DAT(''Window_CloseRequestFcn'',gcf,[],guidata(gcf))');

ClearEntryBox(hObject, eventdata, handles);

% --------------------------------------------------------------------
function ImportFile_btn_Callback(hObject, eventdata, handles)
% Botao de importação de dados

opt = RDAT_InputOption('Opção','Tipo de dados para importação:',{'Planilha MS Excel (.xls)','Arquivo de texto (.txt, .dat, .csv)',...
        'Arquivo DGPS (J)','Arquivo DGPS (C)','Arquivos AACMI F-5M / A-29 (.xml)','Arquivos de instrumentação ACRA'},1,280);
drawnow;

if ~isempty(opt)
    switch opt
        case 1
            ImportFile_xls_Callback(hObject, eventdata, handles);
        case 2
            ImportFile_txt_Callback(hObject, eventdata, handles);
        case 3
            ImportFile_J_Callback(hObject, eventdata, handles);
        case 4
            ImportFile_C_Callback(hObject, eventdata, handles);
        case 5
            ImportFile_xml_Callback(hObject, eventdata, handles);
        case 6
            ImportFile_Acra_Callback(hObject, eventdata, handles);
    end
end

% --------------------------------------------------------------------
function SaveFileAs_btn_Callback(hObject, eventdata, handles)
% Botao para salvar arquivo mat com outro nome

opt = RDAT_InputOption('Opção',{'Indique que parte da matriz de dados','deseja salvar em outro arquivo:'},{'Tudo','Intervalo','Seleção','Pontos de ensaio'},1,230);
drawnow;

if ~isempty(opt)
    switch opt
        case 1
            SaveMatFileAs_Callback(hObject, eventdata, handles);
        case 2
            SaveSliceAs_Callback(hObject, eventdata, handles);
        case 3
            SaveSelectionAs_Callback(hObject, eventdata, handles);
        case 4
            SaveTestPtsAs_Callback(hObject, eventdata, handles);
    end
end

% --------------------------------------------------------------------
function ExportFile_btn_Callback(hObject, eventdata, handles)
% Botao de exportação de dados

opt = RDAT_InputOption('Opção','Tipo de arquivo e intervalo de dados para exportação:',{...
        'Planilha Excel  -  Tudo','Planilha Excel  -  Intervalo','Planilha Excel  -  Seleção','Planilha Excel  -  Pontos de ensaio',...
        'Arquivo texto  -  Tudo','Arquivo texto  -  Intervalo','Arquivo texto  -  Seleção','Arquivo texto  -  Pontos de ensaio'},1,290);
drawnow;

if ~isempty(opt)
    switch opt
        case 1
            ExportFile_xls_Callback(hObject, eventdata, handles);
        case 2
            ExportSlice_xls_Callback(hObject, eventdata, handles);
        case 3
            ExportSelection_xls_Callback(hObject, eventdata, handles);
        case 4
            ExportTestPts_xls_Callback(hObject, eventdata, handles);
        case 5
            ExportFile_txt_Callback(hObject, eventdata, handles);
        case 6
            ExportSlice_txt_Callback(hObject, eventdata, handles);
        case 7
            ExportSelection_txt_Callback(hObject, eventdata, handles);
        case 8
            ExportTestPts_txt_Callback(hObject, eventdata, handles);
    end
end

% --------------------------------------------------------------------
function LineTypes_btn_Callback(hObject, eventdata, handles)
% Botao de edição das linhas e cor de fundo

opt = RDAT_InputOption('Opção','O que deseja editar?',{'Linhas dos plotes','Cor de fundo'},1,200,1); drawnow;

if ~isempty(opt)
    switch opt
        case 1
            LineTypes_Callback(hObject, eventdata, handles);
        case 2
            BackgroundColor_Callback(hObject, eventdata, handles);
    end
end

% --------------------------------------------------------------------
function Oper_btn_Callback(hObject, eventdata, handles)
% Botao de operação matematica

opt = RDAT_InputOption('Opção','Que tipo de operação deseja realizar?',...
    {'Elementar','Um parâmetro e uma constante','Dois parâmetros','Até quatro parâmetros','Função externa'},1,260,1); drawnow;

if ~isempty(opt)
    switch opt
        case 1
            ElementaryOperation_Callback(hObject, eventdata, handles);
        case 2
            OneParamOperation_Callback(hObject, eventdata, handles);
        case 3
            TwoParamOperation_Callback(hObject, eventdata, handles);
        case 4
            FourParamOperation_Callback(hObject, eventdata, handles);
        case 5
            ExternalFunction_Callback(hObject, eventdata, handles);
    end
end

% --------------------------------------------------------------------
function Coord_btn_Callback(hObject, eventdata, handles)
% Botao de conversao de coordenadas

opt = RDAT_InputOption('Opção','Indique a conversão desejada:',{'Lat/Long  -->  DE/DN','DE/DN  -->  Lat/Long',...
        'Lat/Long  -->  RDL/Dist','RDL/Dist  -->  Lat/Long','DE/DN  -->  RDL/Dist','RDL/Dist  -->  DE/DN'},1); drawnow;

if ~isempty(opt)
    switch opt
        case 1
            LatLong2DeDn_Callback(hObject, eventdata, handles);
        case 2
            DeDn2LatLong_Callback(hObject, eventdata, handles);
        case 3
            LatLong2RdlDist_Callback(hObject, eventdata, handles);
        case 4
            RdlDist2LatLong_Callback(hObject, eventdata, handles);
        case 5
            DeDn2RdlDist_Callback(hObject, eventdata, handles);
        case 6
            RdlDist2DeDn_Callback(hObject, eventdata, handles);
    end
end

% --------------------------------------------------------------------
function GoTo_btn_Callback(hObject, eventdata, handles)
% Botao Ir Para

opt = RDAT_InputOption('Opção','Método de busca:',{'Tempo','TOP','Evento','Ponto de ensaio'},1,180); drawnow;

if ~isempty(opt)
    switch opt
        case 1 % Tempo
            GoToTime_Callback(hObject, eventdata, handles);
        case 2 % TOP
            GoToTOP_Callback(hObject, eventdata, handles);
        case 3 % Evento
            GoToEvent_Callback(hObject, eventdata, handles);
        case 4 % Ponto de ensaio
            GoToPoint_Callback(hObject, eventdata, handles);
    end
end

% --------------------------------------------------------------------
function Select_btn_Callback(hObject, eventdata, handles)
% Botao de seleção de pontos

opt = RDAT_InputOption('Opção','Método de seleção:',{'Por caixa','Por barra','Por valor','Por tempo','Pontos inválidos',...
        'Pontos repetidos','Ruído no tempo','Pontos inadequados de tempo','Pontos inadequados de TOP','Spikes'},1,200); drawnow;

if ~isempty(opt)
    switch opt
        case 1 % Por caixa
            SelectByBox_Callback(hObject, eventdata, handles);
        case 2 % Por barra
            SelectByBar_Callback(hObject, eventdata, handles);
        case 3 % Por valor
            SelectByValue_Callback(hObject, eventdata, handles);
        case 4 % Por tempo
            SelectByTime_Callback(hObject, eventdata, handles);
        case 5 % Pontos inválidos
            SelectNans_Callback(hObject, eventdata, handles);
        case 6 % Pontos repetidos
            SelectRepPts_Callback(hObject, eventdata, handles);
        case 7 % Ruído no tempo
            SelectTimeNoise_Callback(hObject, eventdata, handles);
        case 8 % Pontos inadequados de tempo
            SelectInvalidTime_Callback(hObject, eventdata, handles);
        case 9 % Pontos inadequados de TOP
            SelectInvalidTop_Callback(hObject, eventdata, handles);
        case 10 % Spikes
            SelectSpikes_Callback(hObject, eventdata, handles);
    end
end

% --------------------------------------------------------------------
function GetData_btn_Callback(hObject, eventdata, handles)
% Botao de obtenção de dados

opt = RDAT_InputOption('Opção','Tipo de dados:',{'Compilação de dados dos pontos de ensaio',...
        'Dados dos ajustes de curva','Tabela de dados dos pontos de ensaio','Tabela de dados dos eventos'},1,260); drawnow;

if ~isempty(opt)
    switch opt
        case 1 % Compilação
            TestPts_GetData_Callback(hObject, eventdata, handles);
        case 2 % Ajustes
            TestPts_GetFits_Callback(hObject, eventdata, handles);
        case 3 % Tabela
            TestPts_GetDataTable_Callback(hObject, eventdata, handles);
        case 4 % Eventos
            Events_GetData_Callback(hObject, eventdata, handles);
    end
end

% --------------------------------------------------------------------
function ZoomIn_btn_Callback(hObject, eventdata, handles)
% Botao de zoom in

func = getappdata(handles.window,'func');
clickfunc = getappdata(handles.window,'clickfunc');

setappdata(handles.window,'xzoom',[]);
set(handles.graphs,'YLimMode','auto');
set(handles.auxlines,'XData',NaN,'YData',NaN);

if strcmp(clickfunc,'zoom') || strcmp(clickfunc,'select')
    ax = get(handles.graph,'XLim');
    if 2/3*diff(ax) > 1e-4
        set(handles.graphs,'XLim',[ax(1)+diff(ax)/6, ax(2)-diff(ax)/6],'YLimMode','auto');
        if strcmp(func,'PlotMachLines_1')
            PlotMachLines_Callback(hObject, eventdata, handles);
        end
    else
        beep;
    end
else
    beep;
end

% --------------------------------------------------------------------
function BoxZoomIn_btn_Callback(hObject, eventdata, handles)
% Zoom in da função zoom retangular

func = getappdata(handles.window,'func');
clickfunc = getappdata(handles.window,'clickfunc');

setappdata(handles.window,'xzoom',[]);
set(handles.graphs,'YLimMode','auto');
set(handles.auxlines,'XData',NaN,'YData',NaN);

if strcmp(clickfunc,'zoom')
    ng = find(handles.graphs==gca);
    dx = diff(get(handles.graphs(ng),'XLim'));
    dy = diff(get(handles.graphs(ng),'YLim'));
    cp = get(handles.graphs(ng),'CurrentPoint');
    set(handles.graphs(ng),...
        'XLim',[cp(1,1)-max(.5e-4,dx/4), cp(1,1)+max(.5e-4,dx/4)],...
        'YLim',[cp(1,2)-max(.5e-4,dy/4), cp(1,2)+max(.5e-4,dy/4)]);
    set(handles.graphs(setdiff(1:5,ng)),'XLim',get(handles.graphs(ng),'XLim'));
    if strcmp(func,'PlotMachLines_1')
        PlotMachLines_Callback(hObject, eventdata, handles);
    end
end

% --------------------------------------------------------------------
function ZoomOut_btn_Callback(hObject, eventdata, handles)
% Botao de zoom out

func = getappdata(handles.window,'func');
clickfunc = getappdata(handles.window,'clickfunc');

setappdata(handles.window,'xzoom',[]);
set(handles.graphs,'YLimMode','auto');
set(handles.auxlines,'XData',NaN,'YData',NaN);

if strcmp(clickfunc,'zoom') || strcmp(clickfunc,'select')
    ax = get(handles.graph,'XLim');
    [Xmin, Xmax] = GetGraphLimits(handles, 1);
    Lzoom = ax(1) > Xmin;
    Rzoom = ax(2) < Xmax;
    if  Lzoom || Rzoom
        x1 = max(Xmin,ax(1)-Lzoom*diff(ax)/4);
        x2 = min(Xmax,ax(2)+Rzoom*diff(ax)/4);
        if x2 > x1
            set(handles.graphs,'XLim',[x1 x2]);
        else
            set(handles.graphs,'XLim',AutoLim([handles.plots(1,1:3) handles.ruler]));
        end
        drawnow;
        set(handles.graphs,'YLimMode','manual');
        for n = 1:5
            if strcmp(get(handles.graphs(n),'Visible'),'on')
                ay = get(handles.graphs(n),'YLim');
                set(handles.auxlines(n),'XData',[ax(1) ax(1) NaN ax(2) ax(2)],'YData',[ay NaN ay],'Visible','on');
            end
        end
        if strcmp(func,'PlotMachLines_1')
            PlotMachLines_Callback(hObject, eventdata, handles);
        end
        pause(.2);
        set(handles.auxlines,'Visible','off');
        set(handles.graphs,'YLimMode','auto');
        Window_ButtonMotionFcn(hObject, eventdata, handles);
    else
        beep;
    end
else
    beep;
end

% --------------------------------------------------------------------
function BoxZoomOut_btn_Callback(hObject, eventdata, handles)
% Zoom out da função zoom retangular

func = getappdata(handles.window,'func');
clickfunc = getappdata(handles.window,'clickfunc');

setappdata(handles.window,'xzoom',[]);
set(handles.graphs,'YLimMode','auto');
set(handles.auxlines,'XData',NaN,'YData',NaN);

if strcmp(clickfunc,'zoom')
    ng = find(handles.graphs==gca);    
    ax = get(handles.graphs(ng),'XLim');
    ay = get(handles.graphs(ng),'YLim');
    [Xmin, Xmax, Ymin, Ymax] = GetGraphLimits(handles, ng);
    Lzoom = ax(1) > Xmin;
    Rzoom = ax(2) < Xmax;
    Dzoom = ay(1) > Ymin;
    Uzoom = ay(2) < Ymax;
    if  Lzoom || Rzoom || Dzoom || Uzoom
        set(handles.graphs(ng),...
            'XLim',[max(Xmin,ax(1)-Lzoom*diff(ax)/4), min(Xmax,ax(2)+Rzoom*diff(ax)/4)],...
            'YLim',[max(Ymin,ay(1)-Dzoom*diff(ay)/4), min(Ymax,ay(2)+Uzoom*diff(ay)/4)]);
        set(handles.auxlines(ng),'XData',[ax ax(2) ax(1) ax(1)],'YData',[ay(1) ay ay(2) ay(1)],'Visible','on');
        set(handles.graphs(setdiff(1:5,ng)),'XLim',get(handles.graphs(ng),'XLim'));
        drawnow;
        set(handles.graphs,'YLimMode','manual');
        for n = 1:5
            if n ~= ng
                if strcmp(get(handles.graphs(n),'Visible'),'on')
                    ay = get(handles.graphs(n),'YLim');
                    set(handles.auxlines(n),'XData',[ax(1) ax(1) NaN ax(2) ax(2)],'YData',[ay NaN ay],'Visible','on');
                end
            end
        end
        if strcmp(func,'PlotMachLines_1')
            PlotMachLines_Callback(hObject, eventdata, handles);
        end
        pause(.2);
        set(handles.auxlines,'Visible','off');
        set(handles.graphs(setdiff(1:5,ng)),'YLimMode','auto');
        Window_ButtonMotionFcn(hObject, eventdata, handles);
    else
        beep;
    end
else
    beep;
end

% --------------------------------------------------------------------
function ShiftLeft_btn_Callback(hObject, eventdata, handles)
% Deslocamento 20% à esquerda

func = getappdata(handles.window,'func');

setappdata(handles.window,'xzoom',[]);
set(handles.graphs,'YLimMode','auto');
set(handles.auxlines,'XData',NaN,'YData',NaN);

ax = get(handles.graph,'XLim');
[Xmin, Xmax] = GetGraphLimits(handles, 1);
if ax(1) > Xmin
    set(handles.graphs,'XLim',ax-.2*diff(ax));
    if strcmp(func,'PlotMachLines_1')
        PlotMachLines_Callback(hObject, eventdata, handles);
    end
    Window_ButtonMotionFcn(hObject, eventdata, handles);
else
    beep;
end

% --------------------------------------------------------------------
function ShiftRight_btn_Callback(hObject, eventdata, handles)
% Deslocamento 20% à direita

func = getappdata(handles.window,'func');

setappdata(handles.window,'xzoom',[]);
set(handles.graphs,'YLimMode','auto');
set(handles.auxlines,'XData',NaN,'YData',NaN);

ax = get(handles.graph,'XLim');
[Xmin, Xmax] = GetGraphLimits(handles, 1);
if ax(2) < Xmax
    set(handles.graphs,'XLim',ax+.2*diff(ax));
    if strcmp(func,'PlotMachLines_1')
        PlotMachLines_Callback(hObject, eventdata, handles);
    end
    Window_ButtonMotionFcn(hObject, eventdata, handles);
else
    beep;
end


% ####################################################################
%                   CALLBACKS DOS CONTEXT MENUS
% ####################################################################

function TitleCopy_Callback(hObject, eventdata, handles)
% Copia o texto do titulo do gráfico

str = get(handles.title,'String');
str(str=='\') = '';
str(str=='_') = '';
str = strrep(str,'omega','w');
str = strrep(str,'infty','inf');
clipboard('copy',str);

% --------------------------------------------------------------------
function TitleDetails_Callback(hObject, eventdata, handles)
global DADOS
% Apresenta os detalhes do que está sendo mostrado no titulo (ajuste de curva e validação de pontos)

func = getappdata(handles.window,'func');

switch func
    
    case {'FitCurve_1','TestPtsFitView_1'}
        tempdata = getappdata(handles.window,'tempdata');
        fittype = tempdata{1};
        cfs = tempdata{2};
        x0 = tempdata{3};
        E = tempdata{5};
        
        switch fittype
            case 'poly'
                N = length(cfs)-1;
                if N
                    str = {['Ajuste polinomial de ' num2str(N),'° grau'],...
                            ' ',...
                            'Coeficientes:'};
                    for n = 1:N+1
                        str{length(str)+1} = ['    p' num2str(n) ' = ' num2str(cfs(n))];
                    end
                    str{length(str)+1} = ' ';
                    str{length(str)+1} = ['Abcissa centralizada em x0 = ' num2str(x0)];
                    str{length(str)+1} = ' ';
                else
                    str = { 'Ajuste polinomial de grau zero (média)',...
                            ' ',...
                            'Coeficiente:'};
                    str{length(str)+1} = ['    p0 = ' num2str(cfs)];
                    str{length(str)+1} = ' ';
                    
                end
                
            case '1ord'
                str = {'Ajuste de sistema de 1ª ordem na forma',...
                        'y(t) = a + b.[1-exp(-t/c)]',...
                        ' ',...
                        'Coeficientes: ',...
                        ['    a = ' num2str(cfs(1))],...
                        ['    b = ' num2str(cfs(2))],...
                        ['    c = ' num2str(cfs(3))],...
                        ' ',...
                        ['Abcissa centralizada em t0 = ' num2str(x0)],...
                        ' ',...
                        ['    y0 = a = ' num2str(cfs(1))],...
                        ['    yinf = a+b = ' num2str(cfs(1)+cfs(2))],...
                        ['    tau = c = ' num2str(cfs(3)) ' s'],...
                        ' '};
                
            case '2ord'
                str = {'Ajuste de sistema de 2ª ordem na forma',...
                        'y(t) = a + b.exp[-c.(t-d)].sin[e.(t-d)] + f.t',...
                        ' ',...
                        'Coeficientes: ',...
                        ['    a = ' num2str(cfs(1))],...
                        ['    b = ' num2str(cfs(2))],...
                        ['    c = ' num2str(cfs(3))],...
                        ['    d = ' num2str(cfs(4))],...
                        ['    e = ' num2str(cfs(5))],...
                        ['    f = ' num2str(cfs(6))],...
                        ' ',...
                        ['Abcissa centralizada em t0 = ' num2str(x0)],...
                        ' ',...
                        ['    wn = sqrt(e²+c²) = ' num2str(sqrt(cfs(5)^2+cfs(3)^2)) ' rad/s'],...
                        ['    zeta = c/wn = ' num2str(cfs(3)/(sqrt(cfs(5)^2+cfs(3)^2)))],...
                        ' '};
        end
        
        statstr = {'Estatística do ajuste:',...
                ['    Número de pontos: ' num2str(E.n)],...
                ['    Número de coeficientes: ' num2str(E.m)],...
                ['    Graus de liberdade: ' num2str(E.v)],...
                ['    Norma dos resíduos: ' num2str(E.normres)],...
                ['    SSE: ' num2str(E.SSE)],...
                ['    Erro RMS: ' num2str(E.RMSE)],...
                ['    Desvio padrão: ' num2str(E.STDE)],...
                ['    R² ajustado: ' num2str(E.adjR2)] };
        
        
        displaybox([str statstr],'Ajuste de curva',220);
        
    case 'TestPtsValidation_1'
        
        PARAM = get(handles.xlist,'String');
        testpts = getappdata(handles.window,'testpts');
        reftime = getappdata(handles.window,'reftime');
        displaytime = strcmp(get(handles.DisplayDetailedTime,'Checked'),'on');
        
        tcol = findpar(PARAM,reftime,0,1);
        T = DADOS(:,tcol);
        ngrp = get(handles.entry2,'Value');
        npt  = get(handles.entry4,'Value')-1;
        
        Tini = testpts(ngrp).time(1,npt);
        Tend = testpts(ngrp).time(2,npt);
        pts  = GetIntervPts(T,Tini,Tend);
        
        if testpts(ngrp).inisample == 0
            k = length(pts);
        else
            k = length(find(T-T(1)<=testpts(ngrp).inisample));
        end

        group  = testpts(ngrp).group;
        number = testpts(ngrp).number{npt};
        descr  = testpts(ngrp).descr{npt};
        if displaytime
            Tini = time2str2(testpts(ngrp).time(1,npt));
            Tend = time2str2(testpts(ngrp).time(2,npt));
            dur  = time2str2(diff(testpts(ngrp).time(:,npt)));
        else
            Tini = [num2str(testpts(ngrp).time(1,npt)) ' s'];
            Tend = [num2str(testpts(ngrp).time(2,npt)) ' s'];
            dur  = [num2str(diff(testpts(ngrp).time(:,npt))) ' s'];
        end

        NObs = num2str(length(pts));
        
        for npar = 1:length(testpts(ngrp).param)
            colpar = findpar(PARAM,testpts(ngrp).param{npar},1,1);
            if isempty(colpar)
                val{npar} = 'Não encontrado';
            else
                D = DADOS(pts,colpar);
                val{npar} = checkval(D,testpts(ngrp).aim(npt,npar),testpts(ngrp).range1(npt,npar),testpts(ngrp).range2(npt,npar),testpts(ngrp).tol1(npt,npar),testpts(ngrp).tol2(npt,npar),k);
                if all(isnan(val{npar}))
                    val{npar} = 'Não definido';
                else
                    val{npar}(isnan(val{npar})) = 1;
                    val{npar} = [num2str(100 * length(find(val{npar})) / length(pts), '%0.2f') '%'];
                end
            end
        end
        
        colpar = findpar(PARAM,testpts(ngrp).param,1,1);
        if length(colpar) ~= length(testpts(ngrp).param)
            genval = 'Não obtida (algum parâmetro não encontrado)';
        else
            D = DADOS(pts,colpar);
            genval = checkval(D,testpts(ngrp).aim(npt,:),testpts(ngrp).range1(npt,:),testpts(ngrp).range2(npt,:),testpts(ngrp).tol1(npt,:),testpts(ngrp).tol2(npt,:),k);
            if all(all(isnan(genval)))
                genval = 'Não definida';
            else
                genval(isnan(genval)) = 1;
                if size(genval,2) > 1
                    genval = prod(genval,2);
                end
                genval = [num2str(100 * length(find(genval)) / length(pts), '%0.2f') '%'];
            end
        end
        
        str1 = {['Ponto de Ensaio: ' number ' - ' descr],...
                ['Grupo: ' group],...
                ' ',...
                ['Tempo inicial: ' Tini],...
                ['Tempo final: ' Tend],...
                ['Duração: ' dur],...
                ['No. Obs.: ' NObs],...
                ' ',...
                'Validade:'};
        
        for npar = 1:length(testpts(ngrp).param)
            str2{npar} = ['    ' testpts(ngrp).param{npar} ':  ' val{npar}];
        end
        if length(testpts(ngrp).param) > 12
            exc = strmatch('Não definido',val);
            str2(exc) = [];
        end
        
        str3 = {' ',['Validade final: ' genval]};
        
        displaybox([str1 str2 str3],'Validação',300);
        
    case 'TestPtCreation_1'
        
        PARAM = get(handles.xlist,'String');
        tempdata = getappdata(handles.window,'tempdata');
        displaytime = strcmp(get(handles.DisplayDetailedTime,'Checked'),'on');
        
        xcol = get(handles.xlist,'Value');
        X = DADOS(:,xcol);
        
        Xmin = tempdata(1);
        Xmax = tempdata(2);
        pts  = GetIntervPts(X,Xmin,Xmax);
        
        if ~isempty(pts)            
            
            if displaytime
                Xrange = time2str2(Xmax-Xmin);
                Xmin = time2str2(Xmin);
                Xmax = time2str2(Xmax);
            else
                Xrange = num2str(Xmax-Xmin);
                Xmin = num2str(Xmin);
                Xmax = num2str(Xmax);
            end
            
            ycol = get(handles.ylist,'Value');
            Y    = DADOS(pts,ycol);
            
            Ym   = nanmean(Y);
            Ymin = min(Y);
            Ymax = max(Y);
            Ys   = nanstd(Y);
            Ynan = length(find(isnan(Y)));
            
            str = {...
                    ['No. Obs.:  ',           num2str(length(pts))],...
                    ' '                                            ,...
                    ['Tempo inicial:  ',      Xmin                ],...
                    ['Tempo final:  ',        Xmax                ],...
                    ['Duração:  ',            Xrange              ],...
                    ' '                                            ,...
                    [denumber(PARAM{ycol}) ':'                    ],...
                    ['  Média:  ',            num2str(Ym)         ],...
                    ['  Mínimo:  ',           num2str(Ymin)       ],...
                    ['  Máximo:  ',           num2str(Ymax)       ],...
                    ['  Amplitude:  ',        num2str(Ymax-Ymin)  ],...
                    ['  Desvio Padrão:  ',    num2str(Ys)         ],...
                    ['  Pontos inválidos:  ', num2str(Ynan)       ]};
            
            ycol = get(handles.entry1,'Value')-1;
            if ycol
                Y    = DADOS(pts,ycol);
                
                Ym   = nanmean(Y);
                Ymin = min(Y);
                Ymax = max(Y);
                Ys   = nanstd(Y);
                Ynan = length(find(isnan(Y)));
                
                str2 = {...
                        ' '                                            ,...
                        [denumber(PARAM{ycol}) ':'                    ],...
                        ['  Média:  ',            num2str(Ym)         ],...
                        ['  Mínimo:  ',           num2str(Ymin)       ],...
                        ['  Máximo:  ',           num2str(Ymax)       ],...
                        ['  Amplitude:  ',        num2str(Ymax-Ymin)  ],...
                        ['  Desvio Padrão:  ',    num2str(Ys)         ],...
                        ['  Pontos inválidos:  ', num2str(Ynan)       ]};
                
            else
                str2 = [];
            end
            
            ycol = get(handles.entry3,'Value')-1;
            if ycol
                Y    = DADOS(pts,ycol);
                
                Ym   = nanmean(Y);
                Ymin = min(Y);
                Ymax = max(Y);
                Ys   = nanstd(Y);
                Ynan = length(find(isnan(Y)));
                
                str3 = {...
                        ' '                                            ,...
                        [denumber(PARAM{ycol}) ':'                    ],...
                        ['  Média:  ',            num2str(Ym)         ],...
                        ['  Mínimo:  ',           num2str(Ymin)       ],...
                        ['  Máximo:  ',           num2str(Ymax)       ],...
                        ['  Amplitude:  ',        num2str(Ymax-Ymin)  ],...
                        ['  Desvio Padrão:  ',    num2str(Ys)         ],...
                        ['  Pontos inválidos:  ', num2str(Ynan)       ]};
                
            else
                str3 = [];
            end
            str = [str str2 str3];
            
            displaybox(str,'Dados do ponto de ensaio',200);
            
        else
            beep; uiwait(errordlg('Ponto de ensaio vazio.','Erro','modal')); drawnow;
        end
        
    otherwise
        
        if strcmp(get(handles.ShowRuler,'Checked'),'on')
            
            p = handles.precision;
            xcol = get(handles.xlist,'Value');
            timecols = getappdata(handles.window,'timecols');
            displaytime = strcmp(get(handles.DisplayDetailedTime,'Checked'),'on');

            xr = get(handles.ruler,'XData'); xr = xr([1 end]);
            yr = get(handles.ruler,'YData'); yr = yr([1 end]);
            
            dx = diff(xr);
            dy = diff(yr);
            if abs(dx) <= eps
                if abs(dy) <= eps
                    dydx = 0;
                else
                    dydx = sign(dy)*Inf;
                end
            else
                dydx = dy/dx;
            end
            
            if displaytime && any(xcol==timecols)
                x1str = time2str2(xr(1),0,p);
                x2str = time2str2(xr(2),0,p);
                dxstr = time2str2(dx,0,p);
            else
                x1str = num2str(xr(1));
                x2str = num2str(xr(2));
                dxstr = num2str(dx);
            end
            
            str = {...
                    ['x:  ' x1str          ', ' x2str          ],...
                    ['y:  ' num2str(yr(1)) ', ' num2str(yr(2)) ],...
                    ' '                                         ,...
                    ['dx: ' dxstr                              ],...
                    ['dy: ' num2str(dy)                        ],...
                    ['D:  ' num2str(sqrt(dx^2+dy^2))           ],...
                    ' '                                         ,...
                    ['dy/dx: ' num2str(dydx)                   ],...
                    ['Rampa: ' num2str(180/pi*atan2(dy,dx)) '°'],...
                    ['Proa:  ' num2str(mod(180/pi*atan2(dx,dy),360),'%05.1f') '°']};
            
            if any(xcol==timecols)
                str = strrep(str,'x','t');
            end
            
            displaybox(str,'Dados da régua',200);
            
        end
end

% --------------------------------------------------------------------
function ClearInfoBox_Callback(hObject, eventdata, handles)
% Limpa historico da sessao

msg = {' ';' '};
set(handles.infobox,'String',msg,'Value',2);

% --------------------------------------------------------------------
function SaveInfoBox_Callback(hObject, eventdata, handles)
% Salva historico da sessao

[fname, fpath] = uiputfile({'*.txt','Arquivo de texto (*.txt)'},'Salvar histórico da sessão',handles.fpath); drawnow;

if ischar(fname);
    
    set(handles.window,'Pointer','watch');
    
    fname = SetFileExtension(fname,'txt');
    strwrite([fpath fname],get(handles.infobox,'String'),0);
    
    Window_ButtonMotionFcn(hObject, eventdata, handles);
    
end

% --------------------------------------------------------------------
function DataTipMove_Callback(hObject, eventdata, handles)
% Alterna a posição relativa dos datatips

if get(handles.DataTipMove,'Userdata');
    set(handles.DataTipMove,'Userdata',0);
    return
end

h = gco;

if     any(h == handles.datatips(:,2,1))
    m = 1;
elseif any(h == handles.datatips(:,2,2))
    m = 2;
else
    return
end
n = find(h == handles.datatips(:,2,m));
if isempty(n)
    return
end

V = 1*strcmp(get(handles.datatips(n,2,m),'VerticalAlignment'),'bottom');
H = 2*strcmp(get(handles.datatips(n,2,m),'HorizontalAlignment'),'left');

switch V + H
    case 0 % top right
        VA = 'bottom';
        HA = 'right';
    case 1 % bottom right
        VA = 'bottom';
        HA = 'left';
    case 2 % top left
        VA = 'top';
        HA = 'right';
    case 3 % bottom left
        VA = 'top';
        HA = 'left';
end
set(handles.datatips(n,2,m),'VerticalAlignment',VA,'HorizontalAlignment',HA);

% --------------------------------------------------------------------
function HideButtonMenu_Callback(hObject, eventdata, handles)
% Menu para ocultar botao

btndata = getappdata(handles.window,'btndata');
btnh    = [btndata{:,2}];
btnvis  = [btndata{:,6}];

n = find(btnh==gco);
btnvis(n) = 0;
btndata{n,6} = 0;

setappdata(handles.window,'btndata',btndata);
save(which('DatOptions.mat'),'btnvis','-append',saveopt);
Window_ResizeFcn(hObject, eventdata, handles);


% ####################################################################
%                           FUNÇÕES ESPECIAIS
% ####################################################################

function Window_CloseRequestFcn(hObject, eventdata, handles, conf)
% Função de fechamento do programa

if nargin == 3
    conf = 1; % Confirmação
end

haux = [findobj(0,'Tag','aux')'...
        findobj(0,'Name','Calculadora Anemométrica')',...
        findobj(0,'Name','Desempenho em Curva')'];

if getappdata(handles.window,'change')
    
    if exist([handles.fpath handles.fname],'file') && ismat(handles.fname)
        button = savedlg({'Deseja salvar o arquivo atual',[handles.fpath handles.fname '?']},'Confirmação','Sim','Não','Cancela','Cancela'); drawnow;
    else
        button = savedlg('Deseja salvar o arquivo atual?','Confirmação','Sim','Não','Cancela','Cancela'); drawnow;
    end
    
    if strcmp(button,'Sim')
        if exist([handles.fpath handles.fname],'file') && ismat(handles.fname)
            SaveMatFile_Callback(hObject, eventdata, handles, 1);
        else
            SaveMatFileAs_Callback(hObject, eventdata, handles);
        end
    elseif isempty(button) || strcmp(button,'Cancela')
        return        
    end
    
else
    if conf
        button = questdlg(['Deseja sair do ',handles.vername,'?'],'Confirmação','Sim','Não','Não'); drawnow;
    else
        button = 'Sim';
    end
    if ~strcmp(button,'Sim')
        return
    end
end

% Usage log
fname = [netpath 'uselog.inf'];
if exist(fname,'file')
    try
        if ~isdeveloper
            
            usestr = [strrep(datestr(clock),' ',', ') ', ' time2str2(etime(clock,handles.inittime),0,0) ', ' handles.vername ', ' getuser];
            usestr = char(-abs(usestr)+287);
            
            fid = fopen(fname,'r+');
            D = char(fread(fid)');
            fclose(fid);
            
            D = [D usestr];
            
            strwrite(fname,D,0);
        end
    end
end

delete(handles.window);
delete(haux);
rmpath(handles.auxpath);
rmpath(handles.dbpath);
if ~isempty(findstr(lower(path),lower(handles.anemopath(1:end-1)))), rmpath(handles.anemopath); end
clear global DADOS rdatisrunning;

clc

% ----------------------------------------------------------------
function Window_ButtonDownFcn(hObject, eventdata, handles)
% Função exeutada ao se pressionar o botao do mouse

func      = getappdata(handles.window,'func');
clickfunc = getappdata(handles.window,'clickfunc');
dragfunc  = getappdata(handles.window,'dragfunc');
zoomtype  = getappdata(handles.window,'zoomtype');
barpts    = getappdata(handles.window,'barpts');
xzoom     = getappdata(handles.window,'xzoom');

ng = find(gca==handles.graphs);

cp = get(handles.graphs(ng),'CurrentPoint');
x = cp(1,1);
y = cp(1,2);
ax = get(handles.graphs(ng),'XLim');
ay = get(handles.graphs(ng),'YLim');

if x > ax(1) && x < ax(2) && y > ay(1) && y < ay(2)
    
    xmin = min(cell2mat(get([handles.plot; handles.plots(1,2); handles.plots(1,3)],'XData')'));
    xmax = max(cell2mat(get([handles.plot; handles.plots(1,2); handles.plots(1,3)],'XData')'));
    
    if strcmp(func,'FitCurve_1') && get(handles.entry1,'Value') ~= 1
        set(handles.entry2,'String',num2str(x));
        entry2_Callback(hObject, eventdata, handles);
    end
    
    switch clickfunc
        case 'zoom'
            
            switch zoomtype                
                case 'norm' % Zoom normal
                    
                    switch get(handles.window,'SelectionType')
                        case 'open' % Duplo clique
                            
                            set(handles.auxlines,'Visible','off')
                            set(handles.graphs,'XLim',AutoLim([handles.plots(1,1:3) handles.ruler]),'YLimMode','auto');
                            xzoom = [];
                            if strcmp(func,'PlotMachLines_1')
                                PlotMachLines_Callback(hObject, eventdata, handles);
                            end
                            Window_ButtonMotionFcn(hObject, eventdata, handles);
                            
                        case 'normal' % Clique simples
                            
                            if length(xzoom) == 1
                                if abs(x-xzoom) > 1e-4 && max(x,xzoom) > xmin && min(x,xzoom) < xmax
                                    set(handles.graphs,'YLimMode','manual');
                                    for n = 1:5
                                        if strcmp(get(handles.graphs(n),'Visible'),'on')
                                            ayi = get(handles.graphs(n),'YLim');
                                            set(handles.auxlines(n),'XData',[xzoom xzoom NaN x x],'YData',[ayi NaN ayi],'Visible','on');
                                        end
                                    end
                                    pause(.2);
                                    xzoom = getappdata(handles.window,'xzoom');
                                    if ~isempty(xzoom)
                                        xzoom = sort([xzoom x]);
                                        set(handles.graphs,'XLim',xzoom);
                                        set(handles.auxlines,'Visible','off');
                                        set(handles.graphs,'YLimMode','auto');
                                        xzoom = [];
                                        if strcmp(func,'PlotMachLines_1')
                                            PlotMachLines_Callback(hObject, eventdata, handles);
                                        end
                                        Window_ButtonMotionFcn(hObject, eventdata, handles);
                                    end
                                else
                                    beep;
                                end
                            else
                                xzoom = x;
                                set(handles.graphs,'YLimMode','manual');
                                for n = 1:5
                                    if strcmp(get(handles.graphs(n),'Visible'),'on')
                                        ayi = get(handles.graphs(n),'YLim');
                                        set(handles.auxlines(n),'XData',[xzoom, xzoom],'YData',ayi,'Visible','on');
                                    end
                                end
                            end
                            
                        case 'alt' % Botao direito
                            
                            zout = 1;
                            try
                                if strcmp(get(gco,'Type'),'text')
                                    zout = 0;
                                    set(handles.DataTipMove,'Userdata',0);
                                end
                            end
                            if zout
                                set(handles.DataTipMove,'Userdata',1);
                                if length(xzoom) == 1
                                    xzoom = [];
                                    set(handles.auxlines,'Visible','off');
                                    set(handles.graphs,'YLimMode','auto');
                                else
                                    ZoomOut_btn_Callback(hObject, eventdata, handles);
                                    Window_ButtonMotionFcn(hObject, eventdata, handles);
                                end
                            end
                    end
                    
                case 'rect' % Zoom retangular
                    
                    switch get(handles.window,'SelectionType')
                        case 'open' % Duplo clique
                            
                            set(handles.graphs,'XLim',AutoLim(handles.plots(1,1:3)),'YLimMode','auto');
                            if strcmp(func,'PlotMachLines_1')
                                PlotMachLines_Callback(hObject, eventdata, handles);
                            end
                            Window_ButtonMotionFcn(hObject, eventdata, handles);
                            
                        case 'normal' % Clique simples
                            
                            t0 = clock;
                            p1 = get(handles.graphs(ng),'CurrentPoint');
                            setappdata(handles.window,'rbbox',1);
                            rbbox;
                            setappdata(handles.window,'rbbox',0);
                            p2 = get(handles.graphs(ng),'CurrentPoint');
                            dt = etime(clock,t0);
                            
                            x1 = min(p1(1,1),p2(1,1));
                            x2 = max(p1(1,1),p2(1,1));
                            y1 = min(p1(1,2),p2(1,2));
                            y2 = max(p1(1,2),p2(1,2));
                            
                            if x2 == x1 && y2 == y1
                                if dt > .5
                                    beep;
                                else
                                    BoxZoomIn_btn_Callback(hObject, eventdata, handles);
                                end
                            else
                                
                                if x2-x1 > 1e-4 && y2-y1 > 1e-4
                                    
                                    set(handles.graphs(ng),'YLimMode','manual');
                                    set(handles.graphs(setdiff(1:5,ng)),'YLimMode','auto');
                                    set(handles.graphs,'XLim',[x1 x2]);
                                    set(handles.graphs(ng),'YLim',[y1 y2]);
                                    if strcmp(func,'PlotMachLines_1')
                                        PlotMachLines_Callback(hObject, eventdata, handles);
                                    end
                                    Window_ButtonMotionFcn(hObject, eventdata, handles);
                                else
                                    beep;
                                end
                            end
                            
                        case 'alt' % Botao direito
                            
                            zout = 1;
                            try
                                if strcmp(get(gco,'Type'),'text')
                                    zout = 0;
                                    set(handles.DataTipMove,'Userdata',0);
                                end
                            end
                            if zout
                                set(handles.DataTipMove,'Userdata',1);
                                BoxZoomOut_btn_Callback(hObject, eventdata, handles);
                                if strcmp(func,'PlotMachLines_1')
                                    PlotMachLines_Callback(hObject, eventdata, handles);
                                end
                                Window_ButtonMotionFcn(hObject, eventdata, handles);
                            end
                            
                    end
                    
                case 'drag' % Arrastar
                    
                    switch get(handles.window,'SelectionType')
                        case {'normal','open'} % Clique simples
                            [ng, cp]  = GetCurrentGraph(handles);
                            [Xmin, Xmax, Ymin, Ymax] = GetGraphLimits(handles, ng);
                            if isempty(Xmin)
                                [Xmin Xmax] = GetGraphLimits(handles, 1);
                            end
                            if isempty(Ymin)
                                Ymin = .5;
                                Ymax = .5;
                            end
                            ap = get(handles.graphs(ng),'Position');
                            setappdata(handles.window,'dragdata',[1 cp ax ay ap(3:4) Xmin Xmax Ymin Ymax]);
                            Window_ButtonMotionFcn(hObject, eventdata, handles);
                        case 'alt' % Botao direito
                            MouseDrag_Callback(hObject, eventdata, handles);
                            setappdata(handles.window,'dragdata',0);
                            Window_ButtonMotionFcn(hObject, eventdata, handles);
                    end
                    
            end
            
        case 'select' % Seleção contínua de pontos
            
            if get(handles.Selection_btn,'Value')
                
                p1 = get(handles.graphs(ng),'CurrentPoint');
                setappdata(handles.window,'rbbox',1);
                rbbox;
                setappdata(handles.window,'rbbox',0);
                p2 = get(handles.graphs(ng),'CurrentPoint');
                
                p1 = p1(1,1:2);
                p2 = p2(1,1:2);
                
                xbox = sort([p1(1) p2(1)]);
                ybox = sort([p1(2) p2(2)]);
                
                sel = getappdata(handles.window,'sel');
                
                if ng == 1
                    k  = 1;
                    np = 1:5;
                else
                    k  = 2;
                    np = ng;
                end
                
                for n = 1:length(np)
                    
                    X = denan(get(handles.plots(k,np(n)),'XData'));
                    Y = denan(get(handles.plots(k,np(n)),'YData'));
                    
                    switch get(handles.window,'SelectionType')
                        
                        case 'normal' % Botao esquerdo
                            
                            if diff(xbox) < eps && diff(ybox) < eps
                                xbox = xbox(1)+.003*diff(ax)*[-1 1];
                                ybox = ybox(1)+.005*diff(ay)*[-1 1];
                                sngl = 1;
                            else
                                sngl = 0;
                            end
                            newsel = intersect(...
                                intersect(find(X >= xbox(1)), find(X <= xbox(2))), ...
                                intersect(find(Y >= ybox(1)), find(Y <= ybox(2))) );
                            if sngl && length(newsel)>1
                                newsel = newsel(round(length(newsel)/2));
                            end
                            sel = union(sel, newsel);
                            
                        case 'alt' % Botao direito
                            
                            if diff(xbox) < eps && diff(ybox) < eps
                                SelectPoints_Callback(hObject, eventdata, handles);
                                return
                            else
                                sel = setdiff(sel, intersect(...
                                    intersect(find(X >= xbox(1)), find(X <= xbox(2))), ...
                                    intersect(find(Y >= ybox(1)), find(Y <= ybox(2))) ));
                            end
                    end
                end
                
                setappdata(handles.window,'sel',sel);
                UpdateSel(hObject, eventdata, handles);
                
            end
            
        case 'bar'
            if strcmp(get(handles.window,'SelectionType'),'normal');
                if isempty(barpts)
                    barpts = [x, y];
                    set(handles.selbar,'XData',barpts(:,1),'YData',barpts(:,2));
                    set(handles.title,'String','Defina o segundo ponto da barra de seleção');
                elseif size(barpts,1) == 1
                    barpts = sortrows([barpts; [x y]],1);
                    set(handles.selbar,'XData',barpts(:,1),'YData',barpts(:,2));
                    set(handles.title,'String','Clique acima ou abaixo da barra de seleção para selecionar');
                elseif size(barpts,1) == 2
                    if angle((x+1i*y) - (barpts(1,1)+1i*barpts(1,2))) - angle((barpts(2,1)+1i*barpts(2,2)) - (barpts(1,1)+1i*barpts(1,2))) >= 0
                        barpts(3,1:2) = [1,1];
                    else
                        barpts(3,1:2) = -[1,1];
                    end
                    setappdata(handles.window,'barpts',barpts);
                    SelectByBar_Callback(hObject, eventdata, handles);
                    barpts = getappdata(handles.window,'barpts');
                    clickfunc = getappdata(handles.window,'clickfunc');
                end
            elseif strcmp(get(handles.window,'SelectionType'),'alt');
                barpts = [];
                clickfunc = 'zoom';
                set(handles.title,'String','');
                set(handles.selbar,'XData',NaN,'YData',NaN);
            end
            
        case {'ruler1','ruler2'}
            if ng == 1
                dragfunc = 'ruler';
            end
            
        case 'centerpt'
            if ng == 1
                dragfunc = 'centerpt';
            end
            
        case {'testpts1','testpts2'}
            dragfunc = 'testpts';
            
        case {'datatips0','datatips1','datatips2','datatips3','datatips4','datatips5'}
            dragfunc = 'datatips';
            
    end
    setappdata(handles.window,'xzoom',xzoom);
    setappdata(handles.window,'barpts',barpts);
    setappdata(handles.window,'clickfunc',clickfunc);
    setappdata(handles.window,'dragfunc',dragfunc);
end

% --------------------------------------------------------------------
function Window_ButtonUpFcn(hObject, eventdata, handles)
% Função executada apos a soltura do botao do mouse

func = getappdata(handles.window,'func');

if strcmp(func,'PlotMachLines_1') && strcmp(get(handles.BoxZoom,'Checked'),'on')
    PlotMachLines_Callback(hObject, eventdata, handles);
end

setappdata(handles.window,'dragfunc','none');
setappdata(handles.window,'dragdata',0);
Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function Window_ButtonMotionFcn(hObject, eventdata, handles)
% Função executada ao se mover o mouse

if ~isfield(handles,'graphs')
    return
end
    
xcol      = get(handles.xlist,'Value');
func      = getappdata(handles.window,'func');
clickfunc = getappdata(handles.window,'clickfunc');
dragfunc  = getappdata(handles.window,'dragfunc');
zoomtype  = getappdata(handles.window,'zoomtype');
dragdata  = getappdata(handles.window,'dragdata');
timecols  = getappdata(handles.window,'timecols');
xzoom     = getappdata(handles.window,'xzoom');
displaycoord = strcmp(get(handles.DisplayDetailedCoord,'Checked'),'on');
displaytime  = strcmp(get(handles.DisplayDetailedTime,'Checked'),'on');

[ng, cp, ax, ay, x, y]  = GetCurrentGraph(handles);

if ~ng && size(xzoom,1) > 0  % Sair da tela durante uma operação de zoom -> cancelar
    setappdata(handles.window,'xzoom',[]);
    set(handles.graphs,'YLimMode','auto');
    set(handles.auxlines,'XData',NaN,'YData',NaN);
end    
if ~ng && strcmp(clickfunc,'bar')  % Sair da tela durante uma seleção por barra -> cancelar
    clickfunc = 'zoom';
    setappdata(handles.window,'clickfunc',clickfunc);
    setappdata(handles.window,'barpts',[]);
    set(handles.selbar,'XData',NaN,'YData',NaN);
    set(handles.title,'String','');
end
if ~ng && strcmp(dragfunc,'datatips')  % Sair da tela durante a movimentação do datatip -> cancelar
    clickfunc = 'zoom';
    dragfunc = 'none';
end
if ~ng && strcmp(zoomtype,'drag')  % Sair da tela durante arrastamento -> cancelar
    setappdata(handles.window,'dragdata',0);
end

% Determinação da função de click
if ng && strcmp(dragfunc,'none') && ~strcmp(clickfunc,'none') && ~strcmp(clickfunc,'select') && ~strcmp(clickfunc,'bar')
    
    clickfunc = 'zoom';
    
    % Regua
    if ng == 1 && strcmp(get(handles.ShowRuler,'Checked'),'on')
        dx = get(handles.ruler,'XData'); dx = dx([1 end]);
        dy = get(handles.ruler,'YData'); dy = dy([1 end]);
        k = .01;
        if abs(x-dx(1)) < k*diff(ax) && abs(y-dy(1)) < k*diff(ay)
            clickfunc = 'ruler1';
        elseif abs(x-dx(2)) < k*diff(ax) && abs(y-dy(2)) < k*diff(ay)
            clickfunc = 'ruler2';
        end
    end
    
    % Centerpoint
    if func(end) == '1'
        xp = get(handles.centerpt,'XData');
        yp = get(handles.centerpt,'YData');
        k = .01;
        if abs(x-xp) < k*diff(ax) && abs(y-yp) < k*diff(ay)
            clickfunc = 'centerpt';
        end
    end   
    
    % Datatips
    if ng && strcmp(get(handles.ShowDataTips,'Checked'),'on')
        k = .01;
        if ng == 1
            for nd = 1:5
                xp = get(handles.datatips(nd,1,1),'XData');
                yp = get(handles.datatips(nd,1,1),'YData');
                if abs(x-xp) < k*diff(ax) && abs(y-yp) < 2*k*diff(ay)
                    clickfunc = ['datatips' num2str(nd)];
                    break
                end
            end
        else
            xp = get(handles.datatips(ng,1,2),'XData');
            yp = get(handles.datatips(ng,1,2),'YData');
            if abs(x-xp) < k*diff(ax) && abs(y-yp) < 2*k*diff(ay)
                clickfunc = 'datatips0';
            end
        end
    end    
    
    % Marcadores de ponto de ensaio
    if ng && strcmp(func,'TestPtsValidation_1') || strcmp(func,'TestPtCreation_1')
        pos1 = get(handles.ptmarker(ng,1),'Position');
        pos2 = get(handles.ptmarker(ng,2),'Position');
        k = .01;
        if abs(x-pos1(1)) < k*diff(ax)
            clickfunc = 'testpts1';
        elseif abs(x-pos2(1)) < k*diff(ax)
            clickfunc = 'testpts2';
        end
    end
    if ng && strcmp(func,'TestPtCreation_1')
        tempdata = getappdata(handles.window,'tempdata');
        pos1 = tempdata(1);
        pos2 = tempdata(2);
        k = .01;
        if abs(x-pos1(1)) < k*diff(ax)
            clickfunc = 'testpts1';
        elseif abs(x-pos2(1)) < k*diff(ax)
            clickfunc = 'testpts2';
        end
    end
    
end

setappdata(handles.window,'clickfunc',clickfunc);
setappdata(handles.window,'dragfunc',dragfunc);

% Tipo de cursor
if ng
    switch clickfunc(1:end-1)
        case {'ruler','centerp'}
            pointer = 'arrow';
        case 'testpts'
            pointer = 'left';
        case 'datatips'
            pointer = 'fleur';
        case 'zoo'
            switch zoomtype
                case 'norm'
                    pointer = 'crosshair';
                case 'rect'
                    set(handles.window,'Pointer','custom','PointerShapeCData',handles.cursors.zoom,'PointerShapeHotSpot',handles.cursors.zoom_hs);
                    pointer = '';
                case 'drag'
                    set(handles.window,'Pointer','custom','PointerShapeCData',handles.cursors.drag{dragdata(1)+1},'PointerShapeHotSpot',handles.cursors.drag_hs{dragdata(1)+1});
                    pointer = '';
            end
        case 'selec'
            set(handles.window,'Pointer','custom','PointerShapeCData',handles.cursors.select,'PointerShapeHotSpot',handles.cursors.select_hs);
            pointer = '';
        otherwise
            pointer = 'crosshair';
    end
    if ~isempty(pointer)
        set(handles.window,'Pointer',pointer);
    end
else
    set(handles.window,'Pointer','arrow');
end

% Linha de sincronismo
if ng && strcmp(get(handles.ShowSyncLine,'Checked'),'on')
    if getappdata(handles.window,'showsync')
        syncpos = get(handles.sync_line,'Position');
        set(handles.sync_line,'Visible','on','Position',[cp(1), syncpos(2:4)]);
    else
        set(handles.sync_line,'Visible','off');
    end
else
    set(handles.sync_line,'Visible','off');
end

% Descrição de eventos e pontos de ensaio sob o cursor
if ~getappdata(handles.window,'rbbox')
    if strcmp(get(handles.ShowTestPoints,'Checked'),'on') && strcmp(get(handles.ShowTestPointsDescr,'Checked'),'off') && ~isempty(handles.testptlbl)
        pos = cell2mat(get(handles.testptlbl,'Position'));
        n = find(abs(x-pos(:,1)) < .01*diff(ax) & abs(y-pos(:,2)) < .02*diff(ay));
        if ~isempty(n)
            set(handles.markertip,'Position',pos(n(1),:),'String',get(handles.testptlbl(n(1)),'UserData'),'Visible','on');
        else
            set(handles.markertip,'String','','Position',[0 0],'Visible','off');
        end
    else
        set(handles.markertip,'String','','Position',[0 0],'Visible','off');
    end
    if strcmp(get(handles.markertip,'Visible'),'off')
        if strcmp(get(handles.ShowEvents,'Checked'),'on') && strcmp(get(handles.ShowEventsDescr,'Checked'),'off') && ~isempty(handles.eventlbl)
            pos = cell2mat(get(handles.eventlbl,'Position'));
            n = find(abs(x-pos(:,1)) < .01*diff(ax) & abs(y-pos(:,2)) < .02*diff(ay));
            if ~isempty(n)
                set(handles.markertip,'Position',pos(n(1),:),'String',get(handles.eventlbl(n(1)),'UserData'),'Visible','on');
            else
                set(handles.markertip,'String','','Position',[0 0],'Visible','off');
            end
        else
            set(handles.markertip,'String','','Position',[0 0],'Visible','off');
        end
    end
end

% Arrastamento do gráfico
if ng && dragdata(1);
    try
        %             1 23 45 67 8  9  10   11   12   13
        % dragdata = [1 cp ax ay gw gh Xmin Xmax Ymin Ymax]
        Dx = min(max(0,dragdata(4)-dragdata(10)), max(min(0,dragdata(5)-dragdata(11)), (cp(1)-dragdata(2))*diff(ax)/dragdata(8) ));
        Dy = min(max(0,dragdata(7)-dragdata(12)), max(min(0,dragdata(6)-dragdata(13)), (cp(2)-dragdata(3))*diff(ay)/dragdata(9) ));
        switch get(handles.BoxZoom,'Checked');
            case 'on'
                set(handles.graphs(ng),'XLim',dragdata(4:5)-Dx,'YLim',dragdata(6:7)-Dy);
            case 'off'
                set(handles.graphs(ng),'XLim',dragdata(4:5)-Dx);
        end
        set(handles.graphs(setdiff(1:5,ng)),'XLim',dragdata(4:5)-Dx,'YLimMode','auto');
    end
end

p = handles.precision;
strfmt = ['%0.',num2str(p),'f'];

% Posição do cursor
if ng
    
    xpar = get(handles.xlabel,'String');
    ypar = get(handles.ylabels(ng),'String');
    
    if displaytime && any(xcol==timecols)
        str = time2str2(x,0,p);
        xint = str(1:end-7);
        xdec = str(end-6:end);
    elseif displaycoord && ( ~isempty(strfind(lower(xpar),'lat ')) || ~isempty(strfind(lower(xpar),'latit')) )
        xstr = deg2latlong(x,1,p);
        xint = xstr(1:6);
        xdec = xstr(7:end);
    elseif displaycoord && ( ~isempty(strfind(lower(xpar),'long ')) ||  ~isempty(strfind(lower(xpar),'lon ')) || ...
            ~isempty(strfind(lower(xpar),'longit')) )
        xstr = deg2latlong(x,2,p);
        xint = xstr(1:7);
        xdec = xstr(8:end);
    else
        xstr = num2str(x,strfmt);
        xint = xstr(1:end-p-1);
        xdec = xstr(end-p:end);
    end
    
    if displaytime && IsTime(ypar)
        str = time2str2(y,0,p);
        yint = str(1:end-7);
        ydec = str(end-6:end);
    elseif displaycoord && ( ~isempty(strfind(lower(ypar),'lat ')) || ~isempty(strfind(lower(ypar),'latit')) )
        ystr = deg2latlong(y,1,p);
        yint = ystr(1:6);
        ydec = ystr(7:end);
    elseif displaycoord && ( ~isempty(strfind(lower(ypar),'long ')) ||  ~isempty(strfind(lower(ypar),'lon ')) || ...
            ~isempty(strfind(lower(ypar),'longit')) )
        ystr = deg2latlong(y,2,p);
        yint = ystr(1:7);
        ydec = ystr(8:end);
    else
        ystr = num2str(y,strfmt);
        yint = ystr(1:end-p-1);
        ydec = ystr(end-p:end);
    end
else
    xint = '';
    xdec = '';
    yint = '';
    ydec = '';
end

set(handles.xint,'String',xint);
set(handles.xdec,'String',xdec);
set(handles.yint,'String',yint);
set(handles.ydec,'String',ydec);

% Movimentação dos objetos
switch dragfunc
    
    case 'ruler'
        dx = get(handles.ruler,'XData');
        dy = get(handles.ruler,'YData');
        if strcmp(clickfunc,'ruler1');
            set(handles.ruler,'XData',linspace(x,dx(end),handles.rulersize+1),'YData',linspace(y,dy(end),handles.rulersize+1));
        elseif strcmp(clickfunc,'ruler2');
            set(handles.ruler,'XData',linspace(dx(1),x,handles.rulersize+1),'YData',linspace(dy(1),y,handles.rulersize+1));
        end
        dx = dx(end)-dx(1);
        dy = dy(end)-dy(1);
        if abs(dx) <= eps
            if abs(dy) <= eps
                dydx = 0;
            else
                dydx = sign(dy)*Inf;
            end
        else
            dydx = dy/dx;
        end
        if displaytime && any(xcol==timecols)
            dxstr = time2str2(dx,0,p);
        else
            dxstr = num2str(dx,strfmt);
        end
        
        str = [' dx: ' dxstr '  dy: ' num2str(dy,strfmt) '  D: ' num2str(sqrt(dx^2+dy^2),strfmt) ...
                '  dy/dx: ' num2str(dydx,strfmt) ' (' num2str(180/pi*atan2(dy,dx),strfmt) '°)' ];
        
        if any(xcol==timecols)
            str = strrep(str,'x','t');
        end

        set(handles.title,'String',str);
        
    case 'centerpt'
        set(handles.centerpt,'XData',x,'YData',y);
        set(handles.entry1,'String',deg2latlong(y,1,3));
        set(handles.entry2,'String',deg2latlong(x,2,3));
        drawnow;
        
    case 'testpts'
        
        switch func
            case 'TestPtsValidation_1'
                n = sscanf(clickfunc(end),'%d');
                if ~isempty(n)
                    testpts = getappdata(handles.window,'testpts');
                    ngrp = get(handles.entry2,'Value');
                    npt  = get(handles.entry4,'Value')-1;
                    if npt && ~isempty(testpts(ngrp).number)
                        if ( n == 1 && x < testpts(ngrp).time(2,npt) ) || ( n == 2 && x > testpts(ngrp).time(1,npt) )
                            T = get(handles.plot,'XData');
                            testpts(ngrp).time(n,npt) = min(T(end),max(T(1),x));
                            setappdata(handles.window,'testpts',testpts);
                            UpdateValidationWindow(hObject, eventdata, handles);
                        end
                    end
                end
            case 'TestPtCreation_1'
                n = sscanf(clickfunc(end),'%d');
                if ~isempty(n)
                    tempdata = getappdata(handles.window,'tempdata');
                    if ( n == 1 && x < tempdata(2) ) || ( n == 2 && x > tempdata(1) )
                        tempdata(n) = x;
                        setappdata(handles.window,'tempdata',tempdata);
                        UpdateCreationWindow(hObject, eventdata, handles);
                    end
                end
        end
        
    case 'datatips'
        nd = sscanf(clickfunc(end),'%d');
        if ng
            if nd == 0 % Multigraph
                X = get(handles.plots(2,ng),'XData');
                Y = get(handles.plots(2,ng),'YData');
                dx = diff(get(handles.graphs(ng),'XLim'));
                dy = diff(get(handles.graphs(ng),'YLim'));
                pos = get(handles.graphs(ng),'Position');
            else
                X = [get(handles.plots(1,nd),'XData') get(handles.eventpts,'XData')];
                Y = [get(handles.plots(1,nd),'YData') get(handles.eventpts,'YData')];
                dx = diff(get(handles.graphs(1),'XLim'));
                dy = diff(get(handles.graphs(1),'YLim'));
                pos = get(handles.graphs(1),'Position');
            end
            
            if ~isempty(X)
                D = sqrt(((X-x)*pos(3)/dx).^2 + ((Y-y)*pos(4)/dy).^2);
                n = find(D == min(D));
                if ~isempty(n) && ~isequal(n(1),getappdata(handles.window,'datatipn'))
                    n = n(1);
                    setappdata(handles.window,'datatipn',n);
                    UpdateDataTips(hObject, eventdata, handles);
                end
            end
        end
end

% --------------------------------------------------------------------
function Window_KeyPressFcn(hObject, eventdata, handles)
% Acionamento de tecla do teclado

cc = get(handles.window,'CurrentCharacter');

if isempty(cc)
    return
end

switch abs(cc)
    
    % Comandos gerais
    
    case 28 % <--
        if strcmp(get(handles.ShiftLeft_btn,'Enable'),'on')
            ShiftLeft_btn_Callback(hObject, eventdata, handles);
        end
        
    case 29 % -->
        if strcmp(get(handles.ShiftRight_btn,'Enable'),'on')
            ShiftRight_btn_Callback(hObject, eventdata, handles);
        end
        
    case 30 % Up
        if strcmp(get(handles.ylist,'Enable'),'on')
            ycol = get(handles.ylist,'Value');
            if ycol > 1
                set(handles.ylist,'Value',ycol-1)
                ylist_Callback(hObject, eventdata, handles);
            end
        end
        
    case 31 % Down
        if strcmp(get(handles.ylist,'Enable'),'on')
            ycol = get(handles.ylist,'Value');
            if ycol < length(get(handles.ylist,'String'))
                set(handles.ylist,'Value',ycol+1)
                ylist_Callback(hObject, eventdata, handles);
            end
        end
        
    case abs('+')
        if strcmp(get(handles.ZoomIn_btn,'Enable'),'on')
            ZoomIn_btn_Callback(hObject, eventdata, handles);
        end
        
    case abs('-')
        if strcmp(get(handles.ZoomOut_btn,'Enable'),'on')
            ZoomOut_btn_Callback(hObject, eventdata, handles);
        end
        
    case 13 % Enter
        if strcmp(get(handles.ok_btn,'Enable'),'on') && strcmp(get(handles.ok_btn,'Visible'),'on')
            ok_btn_Callback(hObject, eventdata, handles);
        end
        
    case 27 % Esc
        if strcmp(get(handles.cancel_btn,'Enable'),'on') && strcmp(get(handles.cancel_btn,'Visible'),'on') && ...
                strcmp(get(handles.cancel_btn,'String'),'Cancela')
            cancel_btn_Callback(hObject, eventdata, handles);
        elseif strcmp(get(handles.Selection_btn,'Enable'),'on') && get(handles.Selection_btn,'Value')
            SelectPoints_Callback(hObject, eventdata, handles);
        end
        
        % Menu Arquivo
        
    case {abs('a'),abs('A')}
        if strcmp(get(handles.LoadMat_btn,'Enable'),'on')
            LoadMatFile_Callback(hObject, eventdata, handles);
        end
        
    case abs('i')
        if strcmp(get(handles.ImportFile_btn,'Enable'),'on')
            ImportFile_btn_Callback(hObject, eventdata, handles);
        end
        
    case abs('s')
        if strcmp(get(handles.SaveFileAs_btn,'Enable'),'on')
            SaveMatFileAs_Callback(hObject, eventdata, handles);
        end
        
    case abs('S')
        if strcmp(get(handles.SaveFileAs_btn,'Enable'),'on')
            SaveFileAs_btn_Callback(hObject, eventdata, handles);
        end
        
    case 19 % Ctrl + s
        if strcmp(get(handles.SaveMat_btn,'Enable'),'on')
            SaveMatFile_Callback(hObject, eventdata, handles);
        end

    case {abs('o'),abs('O')}
        if strcmp(get(handles.ExportFile_btn,'Enable'),'on')
            ExportFile_btn_Callback(hObject, eventdata, handles);
        end
        
    case {abs('q'),abs('Q')}
        if strcmp(get(handles.Hold_btn,'Enable'),'on')
            Hold_Callback(hObject, eventdata, handles);
        end
        
    case {abs('w'),abs('W')}
        if strcmp(get(handles.Fetch_btn,'Enable'),'on')
            Fetch_Callback(hObject, eventdata, handles);
        end
        
    case abs('I')
        if strcmp(get(handles.Print_btn,'Enable'),'on')
            Print_Callback(hObject, eventdata, handles);
        end
        
    case 17 % Ctrl + q
        if strcmp(get(handles.FileMenu,'Enable'),'on')
            Window_CloseRequestFcn(hObject, eventdata, handles);
        end
        
        % Menu Editar
        
    case abs('c')
        if strcmp(get(handles.Copy_btn,'Enable'),'on')
            Copy_Callback(hObject, eventdata, handles);
        end
        
    case abs('C')
        if strcmp(get(handles.CopyFormat_btn,'Enable'),'on')
            CopyFormat_Callback(hObject, eventdata, handles);
        end
        
        % Menu Funções
        
    case abs('F')
        if strcmp(get(handles.Filter_btn,'Enable'),'on')
            SignalFilter_Callback(hObject, eventdata, handles);
        end
        
    case {abs('t'),abs('T')}
        if strcmp(get(handles.InterpSelPts_btn,'Enable'),'on')
            InterpSelPts_Callback(hObject, eventdata, handles);
        end
        
    case abs('=')
        if strcmp(get(handles.Oper_btn,'Enable'),'on')
            Oper_btn_Callback(hObject, eventdata, handles);
        end
        
    case abs('1')
        if strcmp(get(handles.Interp1D_btn,'Enable'),'on')
            Interp1D_Callback(hObject, eventdata, handles);
        end
        
    case abs('2')
        if strcmp(get(handles.Interp2D_btn,'Enable'),'on')
            Interp2D_Callback(hObject, eventdata, handles);
        end
        
    case {abs('k'),abs('K')}
        if strcmp(get(handles.Anemo_btn,'Enable'),'on')
            Anemometry_Callback(hObject, eventdata, handles);
        end
        
    case abs('u')
        if strcmp(get(handles.UnitsConv_btn,'Enable'),'on')
            UnitsConversion_Callback(hObject, eventdata, handles);
        end
        
    case abs('U')
        if strcmp(get(handles.UnitsConvGrp_btn,'Enable'),'on')
            UnitsConversionGroup_Callback(hObject, eventdata, handles);
        end
        
    case abs('/')
        if strcmp(get(handles.Integ_btn,'Enable'),'on')
            NumericInteg_Callback(hObject, eventdata, handles);
        end
        
    case abs('\')
        if strcmp(get(handles.Differ_btn,'Enable'),'on')
            NumericDiffer_Callback(hObject, eventdata, handles);
        end
        
    case abs('f')
        if strcmp(get(handles.CurveFit_btn,'Enable'),'on')
            FitCurve_Callback(hObject, eventdata, handles);
        end
        
   % Menu Dados
        
    case abs('*')
        if strcmp(get(handles.GoTo_btn,'Enable'),'on')
            GoTo_btn_Callback(hObject, eventdata, handles);
        end
        
    case abs('h')
        if strcmp(get(handles.Stats_btn,'Enable'),'on')
            GetIntervalData_Callback(hObject, eventdata, handles);
        end
        
    case abs('H')
        if strcmp(get(handles.Hist_btn,'Enable'),'on')
            Histogram_Callback(hObject, eventdata, handles);
        end
        
    case abs('n')
        if strcmp(get(handles.RenameY_btn,'Enable'),'on')
            RenameParamY_Callback(hObject, eventdata, handles);
        end
        
    case 127 % del
        if strcmp(get(handles.Delete_btn,'Enable'),'on')
            CutSelectedPts_Callback(hObject, eventdata, handles);
        end
        
    case abs('x')
        if strcmp(get(handles.Selection_btn,'Enable'),'on')
            SelectPoints_Callback(hObject, eventdata, handles);
        end
        
    case abs('X')
        if strcmp(get(handles.Select_btn,'Enable'),'on')
            Select_btn_Callback(hObject, eventdata, handles);
        end
        
    case 24 % Ctrl + x
        if strcmp(get(handles.DeSel_btn,'Enable'),'on')
            DeselectAll_Callback(hObject, eventdata, handles);
        end
        
    case abs('m')
        if strcmp(get(handles.Multiplot_btn,'Enable'),'on')
            MultiPlot5_Callback(hObject, eventdata, handles);
        end
        
    case abs('M')
        if strcmp(get(handles.Multigraph_btn,'Enable'),'on')
            MultiGraph5_Callback(hObject, eventdata, handles);
        end
        
      % Menu Ferramentas
        
    case abs('!')
        if strcmp(get(handles.ParSel_btn,'Enable'),'on')
            ParamSelect_Callback(hObject, eventdata, handles);
        end
        
    case abs('N')
        if strcmp(get(handles.EditParam,'Enable'),'on') && strcmp(get(handles.ToolsMenu,'Enable'),'on')
            EditParam_Callback(hObject, eventdata, handles);
        end
        
    case abs('#')
        if strcmp(get(handles.Table_btn,'Enable'),'on')
            ViewDataTable_Callback(hObject, eventdata, handles);
        end
        
    case abs('@')
        if strcmp(get(handles.Process_btn,'Enable'),'on')
            ProcessData_Callback(hObject, eventdata, handles);
        end
        
    case 16 % Ctrl + p
        if strcmp(get(handles.Ptsedit_btn,'Enable'),'on')
            TestPts_Editor_Callback(hObject, eventdata, handles);
        end
        
    case {abs('['),abs(']')}
        if strcmp(get(handles.Setpt_btn,'Enable'),'on')
            TestPts_DefineInterval_Callback(hObject, eventdata, handles);
        end
        
    case {abs('{'),abs('}')}
        if strcmp(get(handles.Setpt2_btn,'Enable'),'on')
            TestPts_DefineSelection_Callback(hObject, eventdata, handles);
        end

    case abs('v')
        if strcmp(get(handles.Ptvalid_btn,'Enable'),'on')
            TestPts_Validation_Callback(hObject, eventdata, handles);
        end
        
    case abs('V')
        if strcmp(get(handles.Ptsfits_btn,'Enable'),'on')
            TestPts_FitView_Callback(hObject, eventdata, handles);
        end
        
    case abs('$')
        if strcmp(get(handles.GetData_btn,'Enable'),'on')
            GetData_btn_Callback(hObject, eventdata, handles);
        end
        
    case 5 % Ctrl + e
        if strcmp(get(handles.Eventedit_btn,'Enable'),'on')
            Events_Editor_Callback(hObject, eventdata, handles);
        end
        
    case {abs('('),abs(')')}
        if strcmp(get(handles.Setevt_btn,'Enable'),'on')
            Events_DefineSelection_Callback(hObject, eventdata, handles);
        end
        
        % Menu Opções
        
    case abs('.')
        if strcmp(get(handles.FitZoom_btn,'Enable'),'on')
            FitZoom_Callback(hObject, eventdata, handles);
        end
        
    case abs('z')
        if strcmp(get(handles.BoxZoom_btn,'Enable'),'on')
            BoxZoom_Callback(hObject, eventdata, handles);
        end
        
    case abs('Z')
        if strcmp(get(handles.MouseDrag_btn,'Enable'),'on')
            MouseDrag_Callback(hObject, eventdata, handles);
        end
        
        % Menu Exibir
        
    case {abs('r'),abs('R')}
        if strcmp(get(handles.Ruler_btn,'Enable'),'on')
            ShowRuler_Callback(hObject, eventdata, handles);
        end

    case {abs('l'),abs('L')}
        if strcmp(get(handles.DataTips_btn,'Enable'),'on')
            ShowDataTips_Callback(hObject, eventdata, handles);
        end

    case abs('p')
        if strcmp(get(handles.TestPoints_btn,'Enable'),'on')
            ShowTestPoints_Callback(hObject, eventdata, handles);
        end
        
    case abs('P')
        if strcmp(get(handles.ShowTestPointsDescr,'Enable'),'on') && strcmp(get(handles.DisplayMenu,'Enable'),'on')
            ShowTestPointsDescr_Callback(hObject, eventdata, handles);
        end
        
    case abs('e')
        if strcmp(get(handles.Events_btn,'Enable'),'on')
            ShowEvents_Callback(hObject, eventdata, handles);
        end
        
    case abs('E')
        if strcmp(get(handles.ShowEventsDescr,'Enable'),'on') && strcmp(get(handles.DisplayMenu,'Enable'),'on')
            ShowEventsDescr_Callback(hObject, eventdata, handles);
        end
        
        % Menu Ajuda
        
    case {abs('j'),abs('J')}
        Help_Callback(hObject, eventdata, handles);
        
end

Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function Window_ResizeFcn(hObject, eventdata, handles)
% Função de mudança de tamanho da tela

try
    
    % Limite mínimo
    ws = get(handles.window,'Position');
    sw = handles.minscreensize(1) - handles.screenborders(1);
    sh = handles.minscreensize(2) - handles.screenborders(2);
    % Limite máximo
    ss = get(0,'ScreenSize');
    xw = ss(3);
    xh = ss(4)-6;
    
    % Tamanho mínimo
    if ws(3) < sw || ws(4) < sh
        set(handles.window,'Position',[ws(1) ws(2)+ws(4)-max(ws(4),sh) max(ws(3),sw) max(ws(4),sh)]);
    end
    % Tamanho máximo
    if ws(3) > xw || ws(4) > xh
        set(handles.window,'Position',[ws(1) ws(2) min(ws(3),xw) min(ws(4),xh)]);
    end
    ws = get(handles.window,'Position');
    
    % Reposicionamento dos botões de funções
    btndata = getappdata(handles.window,'btndata');
    if strcmp(get(handles.ShowToolbar,'Checked'),'on')
        btnlines = 1;
        Hbtns = [btndata{:,2}];
        pos = [6-22 ws(4)-btnlines*24 22 22];
        for n = 1:length(Hbtns)
            if n>1 && btndata{n,5} ~= btndata{n-1,5}
                pos(1) = pos(1)+6;
            end
            if pos(1)+23+22 >= ws(3)
                btnlines = btnlines+1;
                pos(1) = 6-22;
            end
            if ~btndata{n,6}
                set(Hbtns(n),'Visible','off');
            else
                pos = [pos(1)+23 ws(4)-btnlines*24 22 22];
                set(Hbtns(n),'Position',pos,'Visible','on');
            end
        end
    else
        btnlines = 0;
        set([btndata{:,2}],'Visible','off');
    end
    setappdata(handles.window,'btnlines',btnlines);
    
    % Bordas
    bu = handles.borders(1)+btnlines*handles.toolbarheight;  % Up
    bd = handles.borders(2);  % Down
    bl = handles.borders(3);  % Left
    br = handles.borders(4);  % Right
    b = 22; % Borda entre gráficos
    
    Ax = ws(3)-bl-br; % Largura dos gráficos
    Ay = ws(4)-bu-bd; % Altura disponivel dos gráficos
    
    ngraph = max( [...
            1 * strcmp(get(handles.graphs(1),'Visible'),'on'),...
            2 * strcmp(get(handles.graphs(2),'Visible'),'on'),...
            3 * strcmp(get(handles.graphs(3),'Visible'),'on'),...
            4 * strcmp(get(handles.graphs(4),'Visible'),'on'),...
            5 * strcmp(get(handles.graphs(5),'Visible'),'on') ] );
    
    for n = 1:ngraph    
        ay = (Ay-(ngraph-1)*b)/ngraph;
        py = bd+(ngraph-n)*(ay+b);
        set(handles.graphs(n),'Position',[bl py Ax ay]);
        set(handles.ylabels(n),'Position',[-50, ay/2, 0])
    end
    
    % Reposicionamento do texto NobsNpar
    p0 = get(handles.NobsNpar,'Position');
    set(handles.NobsNpar,'Position', [ws(3)-p0(3)-br ws(4)-bu+2 p0(3) p0(4)]);
    
    % Reposicionamento do xlabel
    p0 = get(handles.xlabel,'Position');
    set(handles.xlabel,'Position', [bl+(Ax-p0(3))/2 p0(2:4)]);
    
    % Reposicionamento dos botões de controle
    Hbtns = [handles.ShiftRight_btn handles.ShiftLeft_btn handles.ZoomOut_btn handles.ZoomIn_btn]; 
    for n = 1:length(Hbtns)
        p0 = get(Hbtns(n),'Position');
        set(Hbtns(n),'Position',[ws(3)-p0(3)-2 bd+(n-1)*p0(4) p0(3:4)]);
    end
    
    % Reposicionamento da caixa de mensagem
    vis  = get(handles.infobox,'UserData');
    if vis && ws(3) > 1000
        vis = 'on';
    else
        vis = 'off';
    end
    p0 = get(handles.infobox,'Position');
    set(handles.infobox,'Position', [ws(3)-p0(3)-br+1 p0(2:4)],'Visible',vis);
    
    % Reposicionamento das coordenadas do cursor
    p0 = get(handles.yint,'Position');
    set(handles.yint,'Position', [ws(3)-p0(3)-50-br p0(2:4)]);
    p0 = get(handles.ydec,'Position');
    set(handles.ydec,'Position', [ws(3)-p0(3)-br p0(2:4)]);
    p0 = get(handles.xint,'Position');
    set(handles.xint,'Position', [ws(3)-p0(3)-50-br p0(2:4)]);
    p0 = get(handles.xdec,'Position');
    set(handles.xdec,'Position', [ws(3)-p0(3)-br p0(2:4)]);
    
    % Reposicionamento da linha de sincronismo
    p0 = get(handles.sync_line,'Position');
    set(handles.sync_line,'Position', [p0(1) bd p0(3) ws(4)-bu-bd]);
    
    % Reposicionamento do titulo
    set(handles.title,'Position',[.5*Ax ay+4 0]);
    
end

% ####################################################################
%                           FUNÇÕES AUXILIARES
% ####################################################################

function ClearEntryBox(hObject, eventdata, handles)
% Oculta os campos de entrada de dados

part = getappdata(handles.window,'part');

set([handles.entries handles.entriestxt],'Visible','off','String','');
set([handles.frame handles.frametxt handles.ok_btn handles.cancel_btn],'Visible','off');
set(handles.entries,'Style','popupmenu','Enable','on');

SetEntrySize(handles,handles.entry1,1);
SetEntrySize(handles,handles.entry2,1);

setappdata(handles.window,'clickfunc','zoom');
setappdata(handles.window,'tempdata',[]);

if isempty(part)
    set([handles.menulist handles.xlist handles.ylist handles.controlbtns],'Enable','on');
    UpdateButtonStatus(hObject, eventdata, handles);
end

% --------------------------------------------------------------------
function NewEvent(handles,str)
% Insere novo envento no historico

maxext = 320;

eventtime = clock;
msg = {[num2str(eventtime(4),'%02d'),':',num2str(eventtime(5),'%02d'),...
            ':',num2str(round(eventtime(6)),'%02d'),'  ',str]};

ext = strextent(msg);

n = 1;
while ext > maxext
    msg{n+1} = [];
    while ext > maxext
        msg{n+1} = [msg{n}(end) msg{n+1}];
        msg{n}(end) = [];
        ext = strextent(msg{n});
    end
    n = n+1;
    ext = strextent(msg{n});
end

msg = cat(1, get(handles.infobox,'String'), msg(:));

while isempty(deblank(msg{1})) && length(msg) > 2
    msg(1) = [];
end

set(handles.infobox,'String',msg,'Value',length(msg));

% --------------------------------------------------------------------
function UpdateGraph(hObject, eventdata, handles, xcol, ycol, PARAM)
global DADOS
% Atualiza x, y, labels, Nobs e Npar

switch nargin
    case 5
        set(handles.xlist,'Value',xcol);
        set(handles.ylist,'Value',ycol);
    case 6
        set(handles.xlist,'String',PARAM,'Value',xcol);
        set(handles.ylist,'String',PARAM,'Value',ycol);
end
DADOS(:,end) = (1:size(DADOS,1))';
UpdateTimeCols(hObject, eventdata, handles);
UpdatePlot(hObject, eventdata, handles);

func = getappdata(handles.window,'func');

switch func
    case {'MultiPlot5_1','MultiGraph5_1'}
        entry1_Callback(hObject, eventdata, handles);
        entry2_Callback(hObject, eventdata, handles);
        entry3_Callback(hObject, eventdata, handles);
        entry4_Callback(hObject, eventdata, handles);
    case 'MultiPlot3_1'
        entry1_Callback(hObject, eventdata, handles);
        entry3_Callback(hObject, eventdata, handles);
end

% --------------------------------------------------------------------
function UpdatePlot(hObject, eventdata, handles, ycol, xcol)
global DADOS
% Atualiza o plot principal sem alteração de Nobs

if isempty(DADOS)
    return
end

part = getappdata(handles.window,'part');

setappdata(handles.window,'xzoom',[]);
set(handles.graphs,'YLimMode','auto');
set(handles.auxlines,'XData',NaN,'YData',NaN);

switch nargin
    case 3
        xcol = get(handles.xlist,'Value');
        ycol = get(handles.ylist,'Value');
    case 4
        xcol = get(handles.xlist,'Value');
end

if ~ycol
    set(handles.ylabel,'String','');
    if ~isempty(part)
        set(handles.plot,'XData',DADOS(part,xcol),'YData',NaN*DADOS(part,xcol));
    else
        set(handles.plot,'XData',DADOS(:,xcol),'YData',NaN*DADOS(:,xcol));
    end
    set(handles.selpts,'XData',NaN,'YData',NaN);
    set([handles.inipts handles.endpts handles.eventpts],'XData',NaN,'YData',NaN);
    set([handles.testptlbl handles.eventlbl],'Position',[0 0],'Visible','off');
    return
end

sel = getappdata(handles.window,'sel');
PARAM = get(handles.xlist,'String');
ax = get(handles.graph,'XLim');

set(handles.xlabel,'String',denumber(PARAM{xcol}));
set(handles.ylabel,'String',denumber(PARAM{ycol}));
if ~isempty(part)
    set(handles.plot,'XData',DADOS(part,xcol),'YData',DADOS(part,ycol));
else
    set(handles.plot,'XData',DADOS(:,xcol),'YData',DADOS(:,ycol));
end

set(handles.graph,'YlimMode','auto');

if xcol == ycol && max(DADOS(:,xcol)) < ax(1) || min(DADOS(:,xcol)) > ax(2)
    set(handles.graphs,'XLim',AutoLim(handles.plot));
end

if ~isempty(sel)
    if any(isnan([DADOS(sel,xcol); DADOS(sel,ycol)]))
        X = denan(DADOS(:,xcol));
        Y = denan(DADOS(:,ycol));
        set(handles.selpts,'XData',X(sel),'YData',Y(sel));
    else
        set(handles.selpts,'XData',DADOS(sel,xcol),'YData',DADOS(sel,ycol));
    end
else
    set(handles.selpts,'XData',NaN,'YData',NaN);
end

UpdateEvents(hObject, eventdata, handles);
UpdateTestPoints(hObject, eventdata, handles);
UpdateDataTips(hObject, eventdata, handles);
Window_ButtonMotionFcn(hObject, eventdata, handles);

set(handles.NobsNpar,'String',[int2str(size(DADOS,2)),' par, ',int2str(size(DADOS,1)),' obs, ',int2str(length(sel)),' sel']);

% --------------------------------------------------------------------
function UpdatePlotN(hObject, eventdata, handles, m, n, ycol, xcol)
global DADOS
% Atualiza os plots secundarios
% m = 1: Multiplot, m = 2: Multigraph
% n: Numero do plot ou gráfico

if isempty(DADOS)
    return
end
if nargin == 6
    xcol = get(handles.xlist,'Value');
end

part = getappdata(handles.window,'part');

setappdata(handles.window,'xzoom',[]);
set(handles.graphs,'YLimMode','auto');
set(handles.auxlines,'XData',NaN,'YData',NaN);

if ~ycol && xcol
    set(handles.ylabels(n),'String','');
    if isempty(part)
        set(handles.plots(m,n),'XData',DADOS(:,xcol),'YData',NaN*DADOS(:,xcol));
    else
        set(handles.plots(m,n),'XData',DADOS(part,xcol),'YData',NaN*DADOS(part,xcol));
    end
elseif ~xcol
    set(handles.ylabels(n),'String','');
    set(handles.plots(m,n),'XData',NaN,'YData',NaN);
else
    PARAM = get(handles.xlist,'String');
    set(handles.ylabels(n),'String',denumber(PARAM{ycol}));
    if isempty(part)
        set(handles.plots(m,n),'XData',DADOS(:,xcol),'YData',DADOS(:,ycol));
    else
        set(handles.plots(m,n),'XData',DADOS(part,xcol),'YData',DADOS(part,ycol));
    end
end

if m == 2
    set(handles.graphs(n),'YlimMode','auto');
end

UpdateDataTips(hObject, eventdata, handles);
Window_ButtonMotionFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function UpdateSel(hObject, eventdata, handles)
global DADOS
% Atualiza o plot dos pontos selecionados, sem alterar x e y

if isempty(DADOS)
    return
end

xcol = get(handles.xlist,'Value');
ycol = get(handles.ylist,'Value');

sel = getappdata(handles.window,'sel');

if ~isempty(sel)
    if any(isnan([DADOS(sel,xcol); DADOS(sel,ycol)]))
        X = denan(DADOS(:,xcol));
        Y = denan(DADOS(:,ycol));
        set(handles.selpts,'XData',X(sel),'YData',Y(sel));
    else
        set(handles.selpts,'XData',DADOS(sel,xcol),'YData',DADOS(sel,ycol));
    end
else
    set(handles.selpts,'XData',NaN,'YData',NaN);
end

set(handles.NobsNpar,'String',[int2str(size(DADOS,2)),' par, ',int2str(size(DADOS,1)),' obs, ',int2str(length(sel)),' sel']);

% --------------------------------------------------------------------
function UpdateCreationWindow(hObject, eventdata, handles, ngraph)
global DADOS
% Função para atualizar as janelas de criação de pontos de ensaio

PARAM    = get(handles.xlist,'String');
reftime  = getappdata(handles.window,'reftime');
tempdata = getappdata(handles.window,'tempdata');

if isempty(reftime) || isempty(tempdata)
    return
end

Ngraphs = max(find([ 1 get(handles.entry1,'Value')-1 get(handles.entry3,'Value')>1 ]));
MultiParamOperation_setgraph(hObject, eventdata, handles, Ngraphs, 0);

tcol = findpar(PARAM,reftime,0,1);
t1 = tempdata(1);
t2 = tempdata(2);
durstr = time2str2(t2-t1,0);

pts = GetIntervPts(DADOS(:,tcol),t1,t2);
V = NaN*zeros(3,2);

if isempty(pts)
    if ~isempty(durstr)
        set(handles.title,'String',['Duração: ' durstr],'UIContextMenu',[]);
    else
        set(handles.title,'String','','UIContextMenu',[]);
    end
    set(handles.auxplots,'XData',NaN,'YData',NaN);
    return
else
    set(handles.title,'UIContextMenu',handles.TitleMenu);
end

for ng = 1:3
    switch ng
        case 1
            ycol = get(handles.ylist,'Value');
        case 2
            ycol = get(handles.entries(1),'Value')-1;
        case 3
            ycol = get(handles.entries(3),'Value')-1;
    end
    
    if ~ycol % Nenhum parâmetro selecionado
        set(handles.auxplots(ng,:),'XData',NaN,'YData',NaN);
        
    else
        
        ym = nanmean(DADOS(pts,ycol));
        
        y1 = nanmin(DADOS(pts,ycol));
        y2 = nanmax(DADOS(pts,ycol));
        
        z1 = ym-nanstd(DADOS(pts,ycol));
        z2 = ym+nanstd(DADOS(pts,ycol));
        
        if isempty(y1), y1 = NaN; end
        if isempty(y2), y2 = NaN; end
        if isempty(z1), z1 = NaN; end
        if isempty(z2), z2 = NaN; end
        
        V(ng,:) = [ym z2-ym];
        
        set(handles.auxplots(ng,1), 'XData', [t1 t2], 'YData', [ym ym]);
        set(handles.auxplots(ng,2), 'XData', [t1 t2 t2 t1 t1], 'YData', [y1 y1 y2 y2 y1]);
        set(handles.auxplots(ng,3), 'XData', [t1 t2 t2 t1 t1], 'YData', [z1 z1 z2 z2 z1]);
    end
end

valuestr = '';
strfmt = ['%0.',num2str(handles.precision),'f'];

for n = 1:3
    if ~isnan(V(n,1))
        if n == 1
            id = '';
        else
            id = num2str(n);
        end
        valuestr = [valuestr '   y' id ' = ' num2str(V(n,1),strfmt) ' ± ' num2str(V(n,2),strfmt)];
    end
end

set(handles.title,'String',['Duração: ' durstr valuestr]);

% --------------------------------------------------------------------
function UpdateValidationWindow(hObject, eventdata, handles, ngraph)
global DADOS
% Função para atualizar as janelas de validação de pontos de ensaio

PARAM   = get(handles.xlist,'String');
testpts = getappdata(handles.window,'testpts');
reftime = getappdata(handles.window,'reftime');

Ngraphs = max(find([ 1 get(handles.entry1,'Value')-1 get(handles.entry3,'Value')>1 ]));
MultiParamOperation_setgraph(hObject, eventdata, handles, Ngraphs, 0);

tcol = findpar(PARAM,reftime,0,1);
ngrp = get(handles.entry2,'Value');
npt  = get(handles.entry4,'Value')-1;

if ~npt || isempty(testpts(ngrp).number)
    set(handles.title,'String','','UIContextMenu',[]);
    set(handles.auxplots,'XData',NaN,'YData',NaN);
    set([handles.valplots handles.invplots],'XData',NaN,'YData',NaN);
    set(handles.ptmarker,'Position',[nan2zero(DADOS(1,tcol))-1e6 0 0],'Visible','off');
    return
end

Tini = testpts(ngrp).time(1,npt);
Tend = testpts(ngrp).time(2,npt);
Dt = Tend-Tini;
if isnan(Dt)
    durstr = '-';
else
    durstr = time2str2(Dt,0);
end

pts = GetIntervPts(DADOS(:,tcol),Tini,Tend);
T = DADOS(pts,tcol);

if isempty(pts)
    set(handles.title,'String',['Duração: ' durstr '  Validade:   '],'UIContextMenu',[]);
    set(handles.auxplots,'XData',NaN,'YData',NaN);
    set([handles.valplots handles.invplots],'XData',NaN,'YData',NaN);
    set(handles.ptmarker,'Position',[nan2zero(min(T))-1e6 0 0],'Visible','off');
    return
else
    set(handles.title,'UIContextMenu',handles.TitleMenu);
end

if length(pts) == 1
    pts2 = [pts-1 pts pts+1];
else
    pts2 = [pts(1)-1 pts(1) pts(end) pts(end)+1];
end
if pts2(1) == 0
    pts2(1) = [];
end
if pts2(end) > size(DADOS,1)
    pts2(end) = [];
end

if testpts(ngrp).inisample == 0
    k = length(pts);
else
    k = length(find(T-T(1)<=testpts(ngrp).inisample));
end

titlestr = get(handles.title,'String');
sep = findstr(titlestr,' ');
if length(sep)~=6
    titlestr = ['Duração: ' durstr '  Validade:   '];
    sep = findstr(titlestr,' ');
end
valstr{1} = titlestr(sep(4)+1:sep(5)-1);
valstr{2} = titlestr(sep(5)+1:sep(6)-1);
valstr{3} = titlestr(sep(6)+1:end);

if nargin == 3
    ngraph = [1 2 3];
end

for ng = ngraph
    switch ng
        case 1
            ycol = get(handles.ylist,'Value');
        case 2
            ycol = get(handles.entries(1),'Value')-1;
        case 3
            ycol = get(handles.entries(3),'Value')-1;
    end
    
    if ~ycol % Nenhum parâmetro selecionado
        valstr{ng} = '';
        set(handles.title,'String',['Duração: ' durstr '  Validade: ' valstr{1} ' ' valstr{2} ' ' valstr{3}]);
        set(handles.auxplots(ng,:),'XData',NaN,'YData',NaN);
        set([handles.valplots(ng) handles.invplots(ng)],'XData',NaN,'YData',NaN);
        set(handles.ptmarker(ng,:),'Position',[min(get(handles.graph,'XLim'))-1e6 0 0],'Visible','off');
    else
        
        ym = nanmean(DADOS(pts(1:k),ycol));
        t1 = Tini;
        t2 = Tend;
        if length(pts2) > 1
            y1 = interp1(DADOS(pts2,tcol),DADOS(pts2,ycol),t1,'linear','extrap'); if isnan(y1); y1 = ym;   end
            y2 = interp1(DADOS(pts2,tcol),DADOS(pts2,ycol),t2,'linear','extrap'); if isnan(y2); y2 = ym;   end
        else
            y1 = DADOS(pts2,ycol);
            y2 = DADOS(pts2,ycol);
        end
        vis = 'on';
        
        if isnan(y1+y2+t1+t2)
            t1 = min(get(handles.graph,'XLim'))-1e6;
            t2 = t1;
            y1 = 0;
            y2 = 0;
            vis = 'off';
        end
        
        set(handles.ptmarker(ng,1),'Position',[t1 y1 0],'Visible',vis);
        set(handles.ptmarker(ng,2),'Position',[t2 y2 0],'Visible',vis);
        
        npar = findpar(testpts(ngrp).param,denumber(PARAM{ycol}),0,1);
        
        if isempty(npar) % Parâmetro selecionado não está na lista parâmetros dos pontos de ensaio
            
            valstr{ng} = '';
            set(handles.title,'String',['Duração: ' durstr '  Validade: ' valstr{1} ' ' valstr{2} ' ' valstr{3}]);
            set(handles.auxplots(ng,:),'XData',NaN,'YData',NaN);
            set([handles.valplots(ng) handles.invplots(ng)],'XData',NaN,'YData',NaN);
            
        else
            aim = testpts(ngrp).aim(npt,npar);
            range1 = testpts(ngrp).range1(npt,npar);
            range2 = testpts(ngrp).range2(npt,npar);
            tol1 = testpts(ngrp).tol1(npt,npar);
            tol2 = testpts(ngrp).tol2(npt,npar);
            
            if isnan(aim+range1+range2) && isnan(tol1+tol2) % Faixa e tolerancia não definidas
                valstr{ng} = '';
                set(handles.title,'String',['Duração: ' durstr '  Validade: ' valstr{1} ' ' valstr{2} ' ' valstr{3}]);
                set(handles.auxplots(ng,:),'XData',NaN,'YData',NaN);
                set([handles.valplots(ng) handles.invplots(ng)],'XData',NaN,'YData',NaN);
            else
                if isnan(tol1+tol2)
                    ym = NaN;
                end
                val = checkval(DADOS(pts,ycol),aim,range1,range2,tol1,tol2,k);
                if all(isnan(val))
                    valstr{ng} = '';
                    set([handles.valplots(ng) handles.invplots(ng)],'XData',NaN,'YData',NaN);
                else
                    val(isnan(val)) = 1;
                    val = logical(val);
                    valpts = pts( val);
                    invpts = pts(~val);
                    set(handles.valplots(ng),'XData',DADOS(valpts,tcol),'YData',DADOS(valpts,ycol));
                    set(handles.invplots(ng),'XData',DADOS(invpts,tcol),'YData',DADOS(invpts,ycol));
                    val = 100 * length(find(val)) / length(pts);
                    valstr{ng} = [num2str(val,'%0.2f') '%'];
                end
                set(handles.title,'String',['Duração: ' durstr '  Validade: ' valstr{1} ' ' valstr{2} ' ' valstr{3}]);
                set(handles.ptmarker(ng,:),'Visible','off');
                set(handles.auxplots(ng,1), 'XData', [t1 t2], 'YData', [aim aim]);
                set(handles.auxplots(ng,2), 'XData', [t1 t2 t2 t1 t1], 'YData', aim+[range1 range1 range2 range2 range1]);
                set(handles.auxplots(ng,3), 'XData', [t1 t2 t2 t1 t1 NaN t1 t2 NaN [t1 t1]+min(testpts(ngrp).inisample,t2-t1)], 'YData', ym+[tol1 tol1 tol2 tol2 tol1 NaN 0 0 NaN tol1 tol2]);
            end
        end
    end
end

% --------------------------------------------------------------------
function UpdateTimeCols(hObject, eventdata, handles)
% Função que atualiza a lista de parâmetros de tempo

PARAM   = get(handles.xlist,'String');
reftime = getappdata(handles.window,'reftime');

timecols = findpar(PARAM,reftime,1,1);
for n = 1:length(PARAM)
    if IsTime(PARAM{n})
        timecols = [timecols(:); n];
    end        
end
timecols = unique(timecols);
setappdata(handles.window,'timecols',timecols);

% --------------------------------------------------------------------
function UpdateEvents(hObject, eventdata, handles, updtlbl)
global DADOS
% Atualiza apresentação dos marcadores de eventos

if nargin < 4
    updtlbl = 0;
end

PARAM   = get(handles.xlist,'String');
events  = getappdata(handles.window,'events');
reftime = getappdata(handles.window,'reftime');
part    = getappdata(handles.window,'part');

tcol = findpar(PARAM,reftime,0,1);

if ~isempty(tcol) && ~isempty(events)
    
    if strcmp(get(handles.ShowEvents,'Checked'),'on')
        
        if ~isempty(part)
            T = DADOS(part,tcol);
        else
            T = DADOS(:,tcol);
        end
        X = denan(get(handles.plot,'XData'));
        Y = denan(get(handles.plot,'YData'));
        
        N = size(events,1);
        M = length(handles.eventlbl);
        
        for n = 1:N
            if  events{n,1}
                evt(n,1) = events{n,2};
            else
                evt(n,1) = NaN;
            end
        end
        
        try
            xev = interp1(T, X, evt, 'linear', NaN);
        catch
            xev = evt*NaN;
        end
        try
            yev = interp1(T, Y, evt, 'linear', NaN);
        catch
            yev = evt*NaN;
        end
        
        [void, ind] = sort(xev);
        
        set(handles.eventpts,'XData',xev(ind),'YData',yev(ind),'Visible','on');
        
        for n = 1:N
            if n > M
                handles.eventlbl(n) = text(0,0,' ','Visible','off','Color',get(handles.eventlbl(1),'Color'),...
                    'VerticalAlignment','bottom','Clipping','on','Interpreter','none');
            end
            
            if ~isnan(xev(n)+yev(n))
                set(handles.eventlbl(n),'Position',[xev(n), yev(n)],'Visible','on');
            else
                set(handles.eventlbl(n),'Position',[0 0],'Visible','off');
            end
        end
        
        % Atualização dos labels (apenas numero ou numero e descrição)
        if updtlbl
            
            if ~isempty(events)
                descr = events(:,3);
            else
                descr = cellstr(char(zeros(N,1)));
            end
            
            if strcmp(get(handles.ShowEventsDescr,'Checked'),'on');
                
                for n = 1:N
                    
                    if isempty(descr{n})
                        rot = 0;
                        aln = 'Bottom';
                        str = ' ';
                        sep = '';
                    else
                        rot = 90;
                        aln = 'Middle';
                        str = '   ';
                        sep = ' - ';
                    end
                    
                    set(handles.eventlbl(n),'String',[str num2str(n) sep descr{n}],'Rotation',rot,'VerticalAlignment',aln,'UserData','');
                end
            else
                
                for n = 1:N
                    
                    if isempty(descr{n})
                        sep = '';
                    else
                        sep = ' - ';
                    end

                    set(handles.eventlbl(n),'String',[' ' num2str(n)],'Rotation',0,'VerticalAlignment','Bottom','UserData',[' ' num2str(n) sep descr{n}]);
                end
            end
        end
        
        if N < M
            set(handles.eventlbl(N+1:end),'Position',[0 0],'Visible','off');
        elseif N > M
            guidata(hObject, handles);
        end
        
    else
        set(handles.eventpts,'XData',NaN,'YData',NaN);
        set(handles.eventlbl,'Position',[0 0],'Visible','off');
    end
else
    set(handles.eventpts,'XData',NaN,'YData',NaN);
    set(handles.eventlbl,'Position',[0 0],'Visible','off');
end

% --------------------------------------------------------------------
function UpdateTestPoints(hObject, eventdata, handles, updtlbl)
global DADOS
% Atualiza apresentação dos marcadores de pontos de ensaio

if nargin < 4
    updtlbl = 0;
end

PARAM   = get(handles.xlist,'String');
testpts = getappdata(handles.window,'testpts');
reftime = getappdata(handles.window,'reftime');
part    = getappdata(handles.window,'part');

tcol = findpar(PARAM,reftime,0,1);

if ~isempty(tcol) && isfield(testpts,'number') && ~isempty([testpts.number])
    
    if strcmp(get(handles.ShowTestPoints,'Checked'),'on')
        
        if ~isempty(part)
            T = DADOS(part,tcol);
        else
            T = DADOS(:,tcol);
        end
        X = denan(get(handles.plot,'XData'));
        Y = denan(get(handles.plot,'YData'));
        
        vis = (logical([testpts.visible]));
        
        testptslist.number = [testpts(vis).number];
        testptslist.descr  = [testpts(vis).descr];
        testptslist.time   = [testpts(vis).time];
        
        if isempty(testptslist.number)
            set([handles.inipts handles.endpts],'XData',NaN,'YData',NaN);
            set(handles.testptlbl,'Position',[0 0],'Visible','off');
            return
        end
        
        N = length(testptslist.number);
        M = length(handles.testptlbl);
        
        tini = testptslist.time(1,:);
        tend = testptslist.time(2,:);
        
        nnan = isnan(tend) | isnan(tini);
        
        tini(nnan) = NaN;
        tend(nnan) = NaN;
        
        tini(tini<T(1)|tini>T(end)) = NaN;
        tend(tend<T(1)|tend>T(end)) = NaN;
        
        try
            xini = interp1(T, X, tini, 'linear', NaN);
        catch
            xini = tini*NaN;
        end
        try
            yini = interp1(T, Y, tini, 'linear', NaN);
        catch
            yini = tini*NaN;
        end
        try
            xend = interp1(T, X, tend, 'linear', NaN);
        catch
            xend = tend*NaN;
        end
        try
            yend = interp1(T, Y, tend, 'linear', NaN);
        catch
            yend = tend*NaN;
        end
        
        [void, iini] = sort(xini);
        [void, iend] = sort(xend);
        
        set(handles.inipts,'XData',xini(iini),'YData',yini(iini),'Visible','on');
        set(handles.endpts,'XData',xend(iend),'YData',yend(iend),'Visible','on');
        
        for n = 1:N
            if n > M
                handles.testptlbl(n) = text(0,0,' ','Visible','off','Color',get(handles.testptlbl(1),'Color'),...
                    'VerticalAlignment','bottom','Clipping','on','Interpreter','none');
            end
            
            if ~isnan(xini(n)+yini(n))
                set(handles.testptlbl(n),'Position',[xini(n), yini(n)],'Visible','on');
            else
                set(handles.testptlbl(n),'Position',[0 0],'Visible','off');
            end
        end
        
        % Atualização dos labels (apenas numero ou numero e descrição)
        if updtlbl
            
            if strcmp(get(handles.ShowTestPointsDescr,'Checked'),'on');
                for n = 1:N
                    str = [' ' testptslist.number{n} ' - ' testptslist.descr{n}];
                    set(handles.testptlbl(n),'String',str,'UserData','');
                end
            else
                for n = 1:N
                    str = [' ' testptslist.number{n}];
                    set(handles.testptlbl(n),'String',str,'UserData',[' ' testptslist.number{n} ' - ' testptslist.descr{n}]);
                end
            end
        end
        
        if N < M
            set(handles.testptlbl(N+1:end),'Position',[0 0],'Visible','off');
        elseif N > M
            guidata(hObject, handles);
        end
        
    else
        set([handles.inipts handles.endpts],'XData',NaN,'YData',NaN);
        set(handles.testptlbl,'Position',[0 0],'Visible','off');
    end
else
    set([handles.inipts handles.endpts],'XData',NaN,'YData',NaN);
    set(handles.testptlbl,'Position',[0 0],'Visible','off');
end

% --------------------------------------------------------------------
function UpdateDataTips(hObject, eventdata, handles)
% Atualiza apresentação dos datatips

if strcmp(get(handles.ShowDataTips,'Checked'),'on')
    
    n = getappdata(handles.window,'datatipn');
    timecols = getappdata(handles.window,'timecols');
    displaytime  = strcmp(get(handles.DisplayDetailedTime,'Checked'),'on');

    for np = 1:5
        
        % Multiplot
        if np == 1
            X = [get(handles.plots(1,np),'XData') get(handles.eventpts,'XData')];
            Y = [get(handles.plots(1,np),'YData') get(handles.eventpts,'YData')];
            XT = displaytime & any(get(handles.xlist,'Value')==timecols);
            YT = displaytime & any(get(handles.ylist,'Value')==timecols);
        else
            X = get(handles.plots(1,np),'XData');
            Y = get(handles.plots(1,np),'YData');
            XT = displaytime & any(get(handles.xlist,'Value')==timecols);
            YT = strcmp(getappdata(handles.window,'func'),'MultiPlot5_1') && displaytime && any(get(handles.entries(np-1),'Value')-1==timecols);
        end

        if np > 1 && strcmp(getappdata(handles.window,'func'),'MultiPlot3_1')
            switch np
                case 2
                    XT = displaytime && any(get(handles.entries(2),'Value')-1==timecols);
                    YT = displaytime && any(get(handles.entries(1),'Value')-1==timecols);
                case 3
                    XT = displaytime && any(get(handles.entries(4),'Value')-1==timecols);
                    YT = displaytime && any(get(handles.entries(3),'Value')-1==timecols);
            end
        end
        
        if length(X) >= n && ~isnan(X(n)) && length(Y) >= n && ~isnan(Y(n))
            if XT
                Xstr = [' X: ' time2str2(X(n))];
            else
                Xstr = [' X: ' num2str(X(n),16)];
            end
            if YT
                Ystr = [' Y: ' time2str2(Y(n))];
            else
                Ystr = [' Y: ' num2str(Y(n),16)];
            end
            set(handles.datatips(np,1,1),'XData',X(n),'YData',Y(n));
            set(handles.datatips(np,2,1),'Position',[X(n) Y(n)],'String',{Ystr,Xstr},'Visible','on');
        else
            set(handles.datatips(np,1,1),'XData',NaN,'YData',NaN);
            set(handles.datatips(np,2,1),'Position',[0 0],'String','','Visible','off');
        end
        
        % Multigraph
        if np >= 2
            X = get(handles.plots(2,np),'XData');
            Y = get(handles.plots(2,np),'YData');
            XT = displaytime & any(get(handles.xlist,'Value')==timecols);
            YT = strcmp(getappdata(handles.window,'func'),'MultiGraph5_1') && displaytime && any(get(handles.entries(np-1),'Value')-1==timecols);
            
            if length(X) >= n && ~isnan(X(n)) && length(Y) >= n && ~isnan(Y(n))
                
                if XT
                    Xstr = [' X: ' time2str2(X(n))];
                else
                    Xstr = [' X: ' num2str(X(n),16)];
                end
                if YT
                    Ystr = [' Y: ' time2str2(Y(n))];
                else
                    Ystr = [' Y: ' num2str(Y(n),16)];
                end
                
                set(handles.datatips(np,1,2),'XData',X(n),'YData',Y(n));
                set(handles.datatips(np,2,2),'Position',[X(n) Y(n)],'String',{Ystr,Xstr},'Visible','on');
            else
                set(handles.datatips(np,1,2),'XData',NaN,'YData',NaN);
                set(handles.datatips(np,2,2),'Position',[0 0],'String','','Visible','off');
            end
        end
    end
    
    if strcmp(getappdata(handles.window,'func'),'PlotMachLines_1') && ~getappdata(handles.window,'cancel')
        try
            Vc = get(handles.datatips(1,1,1),'XData');
            Zp = get(handles.datatips(1,1,1),'YData');
            M  = qcpa2m(vc2qc(Vc),zp2pa(Zp));
            set(handles.datatips(1,2,1),'String',{[' Vc: ' num2str(Vc,6)],[' Zp: ' num2str(Zp,6)],[' M: ' num2str(M,6)]});
        end
    end
    
end

% --------------------------------------------------------------------
function UpdateButtonStatus(hObject, eventdata, handles)
% Atualiza o estado dos botões em função do estado dos menus

btndata = getappdata(handles.window,'btndata');

for n = 1:size(btndata,1)
    
    H0 = btndata{n,1};
    H1 = get(H0,'Parent');
    H2 = get(H1,'Parent');
    
    if strcmp(get(H0,'Enable'),'off') || ...
            ( strcmp(get(H1,'Type'),'uimenu') && strcmp(get(H1,'Enable'),'off') ) || ...
            ( strcmp(get(H2,'Type'),'uimenu') && strcmp(get(H2,'Enable'),'off') )
        set(btndata{n,2},'Enable','inactive','CData',btndata{n,4});
    else
        set(btndata{n,2},'Enable','on','CData',btndata{n,3});
    end
    
    if strcmp(get(btndata{n,1},'Checked'),'off')
        set(btndata{n,2},'Value',0);
    else
        set(btndata{n,2},'Value',1);
    end
    
end

% --------------------------------------------------------------------
function SetButtonStatus(handles,btnlist,opt)
% Altera o estado dos botões listados

btndata = getappdata(handles.window,'btndata');
btnhandles = [btndata{:,2}];

if opt
    opt1 = 'on';
    opt2 = 'on';
    ncol = 3;
else
    opt1 = 'inactive';
    opt2 = 'off';
    ncol = 4;
end

for n = 1:length(btnlist)
    
    nb = find(btnlist(n) == btnhandles);
    set(btnlist(n),   'Enable',opt1,'CData',btndata{nb,ncol});
    set(btndata{nb,1},'Enable',opt2);
    
end

% --------------------------------------------------------------------
function ShowTemporaryPlot(hObject, eventdata, handles, Y, name)
global DADOS
% Apresenta plot temporario para confirmação

PARAM = get(handles.xlist,'String');
xcol = get(handles.xlist,'Value');
set([handles.xlist handles.ylist],'Enable','off');
SetButtonStatus(handles,[handles.Ruler_btn handles.DataTips_btn handles.Events_btn handles.TestPoints_btn],0);

set([handles.plot handles.selpts],'XData',NaN,'YData',NaN);
set([handles.inipts handles.endpts handles.testptlbl handles.eventpts handles.eventlbl],'Visible','off');
set(handles.plots(1,2),'XData',DADOS(:,xcol),'YData',Y);
set(handles.xlabel,'String',denumber(PARAM{xcol}));
set(handles.ylabel,'String',name);
set(handles.entry1,'Style','edit','String',name);
SetEntrySize(handles,handles.entry1,2);
set([handles.entries(2:4) handles.entriestxt],'Visible','off');
set([handles.entry1 handles.ok_btn handles.cancel_btn],'Visible','on');
SetFrame(handles,1,'Defina o nome do novo parâmetro:');
set(handles.graphs,'XLim',AutoLim(handles.plots(1,2)));
UpdateDataTips(hObject, eventdata, handles);

% --------------------------------------------------------------------
function HideTemporaryPlot(hObject, eventdata, handles, xcol, ycol, PARAM)
% Apaga plot temporario e retorna ao plot normal
% Se xcol, ycol e PARAM forem especificados:     confirmação
% Se xcol, ycol e PARAM não forem especificados: cancelamento

ClearEntryBox(hObject, eventdata, handles);
set(handles.plots(1,2),'XData',NaN,'YData',NaN);
SetButtonStatus(handles,[handles.Ruler_btn handles.DataTips_btn handles.Events_btn handles.TestPoints_btn],1);
if nargin == 3
    UpdatePlot(hObject, eventdata, handles);
else
    UpdateGraph(hObject, eventdata, handles, xcol, ycol, PARAM);
end

% --------------------------------------------------------------------
function [ng, cp, ax, ay, x, y]  = GetCurrentGraph(handles)
% Função que informa em qual gráfico o mouse está e fornece:
% ng: numero do gráfico (1 a 5) ou 0 para nenhum
% cp: posição do cursor na tela
% ax: extremos do eixo x
% ay: extremos do eixo y
% x e y: coordenadas do cursor no gráfico

cp = get(handles.window,'CurrentPoint') + [0 1];

ngraph = max( [...
        1 * strcmp(get(handles.graphs(1),'Visible'),'on'),...
        2 * strcmp(get(handles.graphs(2),'Visible'),'on'),...
        3 * strcmp(get(handles.graphs(3),'Visible'),'on'),...
        4 * strcmp(get(handles.graphs(4),'Visible'),'on'),...
        5 * strcmp(get(handles.graphs(5),'Visible'),'on') ] );

ng = 0;
for n = 1:ngraph
    ap = get(handles.graphs(n),'Position');
    ax = get(handles.graphs(n),'XLim');
    ay = get(handles.graphs(n),'YLim');
    
    x = (cp(1)-ap(1))*(ax(2)-ax(1))/ap(3) + ax(1);
    y = (cp(2)-ap(2))*(ay(2)-ay(1))/ap(4) + ay(1);
    
    if x >= ax(1) && x <= ax(2) && y >= ay(1) && y <= ay(2);
        ng = n;
        return
    end
end

% --------------------------------------------------------------------
function check_reftime(PARAM,reftime)
global DADOS
% Analisa o parâmetro de tempo e informa se o mesmo não for adequado

tcol = findpar(PARAM,reftime,0,1);

if isempty(tcol)
    beep; errordlg(['Parâmetro ''' reftime ''' não encontrado.'],'Erro','modal'); drawnow;
    return
end

[ok, ndc, nna] = IsTimeOk(DADOS(:,tcol));
if ~ok
    uiwait(warndlg({['O parâmetro ''' reftime ''' não é adequado para ser utilizado'],...
            'como tempo de referência:',' ',...
            ['Pontos inválidos: ' num2str(length(nna))],...
            ['Pontos não crescentes: ' num2str(length(ndc))],...
            ' ',...
            'Algumas operações referenciadas no tempo podem não funcionar ',...
            'corretamente. Certifique que o parâmetro de tempo seja ',...
            'monotônico crescente e sem pontos inválidos.'},'Aviso','modal')); drawnow;
end

% --------------------------------------------------------------------
function pts = GetIntervPts(handles_or_T,Tini,Tend)
global DADOS
% Fornece os indices dos pontos de um intervalo

if nargin == 1 % Pontos do intervalo selecionado no gráfico 1
    
    handles = handles_or_T;
    ax = get(handles.graph,'XLim');
    xcol = get(handles.xlist,'Value');
    
    X = denan(DADOS(:,xcol));
    pts = intersect(find(X >= ax(1)), find(X <= ax(2)));
    
    if strcmp(get(handles.BoxZoom,'Checked'),'on') % Zoom y não automático
        ay = get(handles.graph,'YLim');
        ycol = get(handles.ylist,'Value');
        Y = denan(DADOS(:,ycol));
        pts2 = intersect(find(Y >= ay(1)), find(Y <= ay(2)));
        pts = intersect(pts,pts2);
    end
    
elseif nargin == 3 % Pontos do tempo T compreendidos entre os tempos Tini e Tend (inclusive)
    
    T = handles_or_T;
    pts = intersect(find(T>=Tini),find(T<=Tend));
    
else
    pts = [];
    
end

% --------------------------------------------------------------------
function [fh, ah, ph, xh, yh, th] = GetTemplate(fname,msg)
% Abre e valida o modelo para copia de gráfico

if nargin == 1
    msg = 1;
end

try
    fh = hgload(fname);
catch
    fh = [];
    ah = [];
    ph = [];
    xh = [];
    yh = [];
    th = [];
    if msg
        beep; uiwait(errordlg({'Modelo não definido.','Defina o modelo com todos os componentes.'},'Erro','modal')); drawnow;
    end
    return
end
ah  = findobj(fh,'Tag','axs');
ph1 = findobj(fh,'Tag','plot1');
ph2 = findobj(fh,'Tag','plot2');
ph3 = findobj(fh,'Tag','plot3');
ph4 = findobj(fh,'Tag','plot4');
ph5 = findobj(fh,'Tag','plot5');
ph6 = findobj(fh,'Tag','fit');
ph  = [ph1 ph2 ph3 ph4 ph5 ph6];
if ishandle(ah)
    xh = get(ah,'XLabel');
    yh = get(ah,'YLabel');
    th = get(ah,'Title');
else
    xh = [];
    yh = [];
    th = [];
end

if length([ah ph xh yh th]) ~= 10
    fh = [];
    ah = [];
    ph = [];
    xh = [];
    yh = [];
    th = [];
    delete(fh);
    if msg
        beep; uiwait(errordlg({'Modelo incompleto.','Redefina o modelo com todos os componentes.'},'Erro','modal')); drawnow;
    end
    delete([handles.dbpath 'copytemplate.fig']);
    return
end

% --------------------------------------------------------------------
function EntryFix(h,p,def)
% Interpreta um valor numerico ou formula inserida numa caixa de texto
%    h: handle do objeto
%    p: digitos de precisao (default = 16)
%    def: string default

switch nargin
    case 1
        p = 16;
        def = '';
    case 2
        def = '';
end

val = real(str2num(get(h,'String')));
if isempty(val)
    if     strcmpi(get(h,'String'),'e')
        val = exp(1);
    elseif strcmpi(get(h,'String'),'pi')
        val = pi;
    end
end

if length(val) ~= 1 || isnan(val)
    str = def;
else
    str = num2str(val,p);
end

set(h,'String',str);

% --------------------------------------------------------------------
function [Xmin, Xmax, Ymin, Ymax] = GetGraphLimits(handles, ng)
% Fornece os limites de dados contidos no gráfico ng

H = findobj(handles.graphs(ng),'Type','line');
H = intersect(H,[handles.plots(:); handles.auxplots(ng,:)'; handles.ruler]);

if length(H) == 1
    Xmin = nanmin(get(H,'XData'));
    Xmax = nanmax(get(H,'XData'));
    Ymin = nanmin(get(H,'YData'));
    Ymax = nanmax(get(H,'YData'));
else
    Xmin = nanmin(cell2mat(get(H,'XData')'));
    Xmax = nanmax(cell2mat(get(H,'XData')'));
    Ymin = nanmin(cell2mat(get(H,'YData')'));
    Ymax = nanmax(cell2mat(get(H,'YData')'));
end

% --------------------------------------------------------------------
function ax = AutoLim(h)
% Função que fornece os valores limites para zoom automático no
% eixo x, baseados nos valores mínimo e máximo de um plot

if length(h) > 1
    xmin = min(cell2mat(get(h,'XData')'));
    xmax = max(cell2mat(get(h,'XData')'));
else
    xmin = min(get(h,'XData'));
    xmax = max(get(h,'XData'));
end

dx = xmax-xmin;

if isnan(dx)
    ax = [0 1];
elseif dx < 1e-4
    ax = [xmin-.5 xmax+.5];
else
    ax = [xmin-.05*dx xmax+.05*dx];
end

% --------------------------------------------------------------------
function SetEntrySize(handles, h, opt)
% Ajusta o tamanho dos entryboxes

pos = get(h,'Position') .* [1 1 0 1] + get(handles.entry3,'Position') .* [0 0 opt 0];
set(h,'Position',pos);

% --------------------------------------------------------------------
function SetFrame(handles,opt,str)
% Ajusta a posição e do texto do frame para operações com entryboxes

if nargin == 2
    str = '';
end

switch opt
    case {1,2}
        set(handles.frame,'Position',handles.framepos(opt,:),'Visible','on');
        set(handles.frametxt,'Visible','on','String',str);
    otherwise
        set(handles.frame,'Position',handles.framepos(1,:),'Visible','off');
        set(handles.frametxt,'Visible','off','String','');
end

% --------------------------------------------------------------------
function SetEntriesForInterval(handles,opt)
% Ajusta a posição dos entryboxes 2 e 4 para entrada de intervalo

pos1 = get(handles.entry1,'Position');
pos2 = get(handles.entry2,'Position');
pos3 = get(handles.entry3,'Position');
pos4 = get(handles.entry4,'Position');

switch opt
    case 1
        set(handles.entry2,'Position',[pos2(1)            pos2(2) pos1(3)/2 pos2(4)]);
        set(handles.entry4,'Position',[pos2(1)+pos1(3)/2  pos2(2) pos1(3)/2 pos2(4)]);
    otherwise
        set(handles.entry2,'Position',[pos2(1) pos2(2) pos1(3) pos2(4)]);
        set(handles.entry4,'Position',[pos3(1) pos4(2) pos1(3) pos2(4)]);
end

% --------------------------------------------------------------------
function FixTOPs(hObject, eventdata, handles, inipar)
global DADOS
% Corrige parâmetros de TOPs que tenham sido afetados por interpolação

if nargin == 3
    inipar = 1;
end

PARAM = get(handles.xlist,'String');
topcols = findTOPpar(PARAM(inipar:end))+inipar-1;

if isempty(topcols)
    return
end

nnint = [];
for n = 1:length(topcols)
    TOP = DADOS(:,topcols(n));
    if ~isequalwithequalnans(fix(TOP),TOP)
        nnint = [nnint; topcols(n)];
    end
end

Nnint = length(nnint);

if ~Nnint
    return
end

if Nnint == 1
    str = {['O parâmetro de TOPs ''' denumber(PARAM{nnint}) ''' parece ter sido afetado pela interpolação.'],...
            'Deseja tentar corrigi-lo?'};
elseif Nnint <= 32
    str = {'Os seguintes parâmetros de TOPs parecem ter sido afetados pela interpolação:',' ',...
            [char(45*ones(Nnint,1)) char(32*ones(Nnint,3)) char(PARAM{nnint})],' ',...
            'Deseja tentar corrigi-los?'};
else
    str = {[num2str(Nnint) ' parâmetros de TOPs parecem ter sido afetados pela interpolação.'],...
            'Deseja tentar corrigi-los?'};
end

button = questdlg(str,'Confirmação','Sim','Não','Sim'); drawnow;
if strcmp(button,'Sim')
    for n = 1:Nnint
        DADOS(:,nnint(n)) = round(DADOS(:,nnint(n)));
    end
end

UpdatePlot(hObject, eventdata, handles);

% --------------------------------------------------------------------
function ok = ismat(fname)
% Informa se o nome de arquivo tem extensão válida (mat ou zip)

if length(fname) > 4
    ext = lower(fname(end-2:end));
    if strcmp(ext,'mat') || strcmp(ext,'zip')
        ok = 1;
    else
        ok = 0;
    end
else
    ok = 0;
end

% --------------------------------------------------------------------
% --------------------------------------------------------------------
% --------------------------------------------------------------------



