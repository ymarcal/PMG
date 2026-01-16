function varargout = RDAT_TestPoints(varargin)
% RDAT_TESTPOINTS M-file for RDAT_TestPoints.fig
% Last Modified by GUIDE v2.5 07-Dec-2010 11:10:26

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RDAT_TestPoints_OpeningFcn, ...
                   'gui_OutputFcn',  @RDAT_TestPoints_OutputFcn, ...
                   'gui_LayoutFcn',  @RDAT_TestPoints_LayoutFcn, ...
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
function h = RDAT_TestPoints_LayoutFcn(varargin)
% Função de layout inicial

h = openfig('RDAT_TestPoints.fig','reuse','invisible');

% -------------------------------------------------------------------
function RDAT_TestPoints_OpeningFcn(hObject, eventdata, handles, varargin)
% Funcao de inicializacao

ss = get(0,'ScreenSize');
minscreensize = [1024 768]; % Tamanho minimo da tela
if ss(3) < minscreensize(1) || ss(4) < minscreensize(2)
    beep; uiwait(errordlg({['Necessário resolução mínima de '...
                num2str(minscreensize(1)) ' × ' num2str(minscreensize(2)) ' pixels.'],...
            ['Resolução atual: ',int2str(ss(3)),' × ',int2str(ss(4)),'.'],...
            ' ','Aviso: Depois de alterar a resolução da tela, é necessário','reinicializar o MATLAB.'},'Erro','modal')); drawnow;
    handles.ok = 0;
    guidata(hObject, handles);
    uiresume;
    return
end

ws = get(handles.window,'Position');
set(handles.window,'Position',[.5*(ss(3)-ws(3)) .5*(ss(4)-ws(4)) ws(3) ws(4)],'Visible','on');

bgc = getbuttoncolor(handles.window);
set(handles.new_btn, 'CData',geticon('DatButtons.mat','new', bgc));
set(handles.open_btn,'CData',geticon('DatButtons.mat','open',bgc));
set(handles.save_btn,'CData',geticon('DatButtons.mat','save',bgc));
set(handles.help_btn,'CData',geticon('DatButtons.mat','help',bgc));
handles.up_ico = {geticon('DatButtons.mat','arrow_s',bgc,1),     geticon('DatButtons.mat','arrow_s',bgc,1,0,0,1,.7) };
handles.dn_ico = {geticon('DatButtons.mat','arrow_s',bgc,1,0,1), geticon('DatButtons.mat','arrow_s',bgc,1,0,1,1,.7) };

set([handles.upgrp_btn handles.uppt_btn handles.upparam_btn],'CData',handles.up_ico{1});
set([handles.dngrp_btn handles.dnpt_btn handles.dnparam_btn],'CData',handles.dn_ico{1});

handles.inisamples = [0 .1 .2 .5 1 2 5];
set(handles.fitord_sel,'String',{'Nenhum','Linear','Quadrático','Cúbico','4° grau','5° grau','6° grau','Primeira ordem','Segunda ordem'},'Value',1);

handles.data_chk = [handles.mean_chk handles.std_chk handles.min_chk handles.max_chk handles.range_chk,...
        handles.ini_chk handles.end_chk handles.var_chk handles.valn_chk handles.tau_chk handles.zeta_chk handles.wn_chk handles.der_chk];
handles.include_chk = [handles.descr_chk handles.Tini_chk handles.Tend_chk handles.dur_chk handles.size_chk handles.val_chk];
handles.fit_chk = [handles.sett0_chk handles.dof_chk handles.normres_chk handles.SSE_chk handles.RMSE_chk handles.STDE_chk handles.adjR2_chk];
handles.toggleenable = [handles.doublept_btn handles.removept_btn handles.renamept_btn handles.uppt_btn,...
        handles.dnpt_btn handles.Tini handles.Tend handles.duration handles.TOPini handles.TOPend handles.EVTini handles.EVTend,...
        handles.data_chk handles.paramlist handles.paramsel handles.addparam_btn handles.remparam_btn handles.addallparam_txt,...
        handles.remallparam_btn handles.upparam_btn handles.dnparam_btn handles.fitord_sel handles.fit_chk,...
        handles.aim handles.range1 handles.range2 handles.tol1 handles.tol2];

if length(varargin) == 4
    PARAM   = varargin{1};
    testpts = varargin{2};
    reftime = varargin{3};
    events  = varargin{4};
else
    set(handles.window,'Visible','off');
    beep; uiwait(errordlg('Dados de entrada incompletos.','Erro','modal'));
    handles.ok = 0;
    guidata(hObject, handles);
    uiresume;
    return
end

PARAM = cellstr(PARAM);
if isempty(testpts)
    testpts = emptytestptslist;
end

testpts = backcompat(testpts,'testpts');

if isempty(deblank(reftime))
    set(handles.window,'Visible','off');
    nreftime = inputvalue('Definir','Tempo de referência:',PARAM,1,1.35); drawnow;
    if isempty(nreftime)
        handles.ok = 0;
        guidata(hObject, handles);
        uiresume;
        return
    end
else
    nreftime = findpar(denumber(PARAM),reftime,0,1);
    if isempty(nreftime)
        beep; uiwait(errordlg(['Tempo de referência ''' reftime ''' não encontrado.'],'Erro','modal'));
        nreftime = inputvalue('Redefinir','Tempo de referência:',PARAM,1,1.35); drawnow;
    end
end
if ~isempty(nreftime)
    reftime = denumber(PARAM{nreftime});
else
    handles.ok = 0;
    guidata(hObject, handles);
    uiresume;
    return
end

eventlist{1} = ' ';
for n = 1:size(events,1)
    eventlist{n+1} = num2str(n);
end
if ~isempty(events)
    exc = find(isnan([events{:,2}]));
    events(exc,:) = [];
    eventlist(exc+1) = [];
end

handles.chg = 0;
handles.ok  = 0;
handles.initestpts = testpts;
handles.inireftime = reftime;
handles.events     = events;
handles.fpath = [pwd filesep];
handles.fname = '*.mat';

set([handles.EVTini handles.EVTend],'String',eventlist);

for ngrp = 1:size(testpts,2)
    if isempty(deblank(PARAM{1}))
        handles.outdex{ngrp} = [];
    else
        handles.outdex{ngrp} = (1:length(PARAM))';
    end
    handles.index{ngrp} = [];
end

guidata(hObject, handles);

topcols = findTOPpar(PARAM);
set(handles.top_sel,'String',[{' '}; PARAM(topcols)]);

set(handles.reftime_sel,'String',PARAM);
set(handles.paramlist,'String',PARAM,'Value',[]);

open_btn_Callback(hObject, eventdata, handles, testpts, reftime);

uiwait(handles.window);

% -------------------------------------------------------------------
function varargout = RDAT_TestPoints_OutputFcn(hObject, eventdata, handles)
% Funcao de saida

if handles.ok
    varargout{1} = handles.testpts;
    varargout{2} = handles.reftime;
else
    varargout{1} = [];
    varargout{2} = [];
end
delete(handles.window);

% --------------------------------------------------------------------
function new_btn_Callback(hObject, eventdata, handles)
% Criar nova lista de pontos

if handles.chg
    button = questdlg({'Deseja criar uma nova lista de pontos?','As alterações não salvas serão perdidas.'},...
        'Confirmação','Sim','Não','Não');
else
    button = questdlg('Deseja criar uma nova lista de pontos?','Confirmação','Sim','Não','Não');
end

if strcmp(button,'Sim')
    
    PARAM = get(handles.reftime_sel,'String');
    
    handles.outdex = {(1:length(PARAM))'};
    handles.index  = {[]};
    
    open_btn_Callback(hObject, eventdata, handles, emptytestptslist, handles.reftime);
end

% --------------------------------------------------------------------
function open_btn_Callback(hObject, eventdata, handles, testpts, reftime)
% Carregar lista de pontos

if nargin <= 3
    
    if handles.chg
        button = questdlg({'Deseja carregar uma lista de pontos?','As alterações não salvas serão perdidas.'},...
            'Confirmação','Sim','Não','Não');
    else
        button = 'Sim';
    end
    
    if strcmp(button,'Sim')
        [fname, fpath] = uigetfile({'*.mat','Arquivo mat (*.mat)'},'Carregar arquivo de pontos de ensaio',handles.fpath);
        if ischar(fpath);
            fname = SetFileExtension(fname,'mat');
            
            vars = who('-file',[fpath fname]);
            if ~isempty(strmatch('testpts',vars,'exact'))
                load([fpath fname],'testpts');
            else
                beep; uiwait(errordlg(['Arquivo ''' fname ''' não contém pontos de ensaio.'],'Erro','modal'));
                return
            end
            if isempty(testpts)
                beep; uiwait(errordlg(['Arquivo ''' fname ''' não contém pontos de ensaio.'],'Erro','modal'));
                return
            end
            if ~isempty(strmatch('reftime',vars,'exact'))
                load([fpath fname],'reftime');
            else
                reftime = '';
            end
            
            handles.fpath = fpath;
            if isempty(strmatch('DADOS',vars,'exact'))
                handles.fname = fname;
            else
                handles.fname = '*.mat';
            end
            
        else
            return
        end
    else
        return
    end
    
else
    fname = '';
end

if isfield(handles,'testpts')
    old_testpts = handles.testpts;
    old_reftime = handles.reftime;
    old_index   = handles.index;
    old_outdex  = handles.outdex;
else
    old_testpts = emptytestptslist;
    old_reftime = [];
    old_index   = handles.index;
    old_outdex  = handles.outdex;
end

try
    
    testpts = backcompat(testpts,'testpts');
    
    handles.testpts = testpts;
    handles.reftime = reftime;
    handles.chg = 0;
    
    PARAM = get(handles.reftime_sel,'String');
    
    % Verificaçao do tempo de referencia carregado
    
    if isempty(findpar(PARAM,handles.reftime)) && ~isempty(findpar(PARAM,SetUnits(handles.reftime)))
        handles.reftime = SetUnits(handles.reftime);
    end
    nreftime = findpar(PARAM,handles.reftime);
    if isempty(nreftime)
        if isempty(handles.reftime)
            uiwait(errordlg('Tempo de referência não definido.','Erro','modal'));
        else
            uiwait(errordlg(['O tempo de referência ''' handles.reftime ''' não foi encontrado.'],'Erro','modal'));
        end
        nreftime = inputvalue('Redefinir','Tempo de referência:',PARAM);
        if isempty(nreftime)
            return
        end
    end
    handles.reftime = denumber(PARAM{nreftime});
    set(handles.reftime_sel,'Value',nreftime);
    reftime_sel_Callback(hObject, eventdata, handles, nreftime);
    
    % Verificaçao da lista de pontos carregada
    
    if ~isempty([handles.testpts.number])
        
        Ngrp = size(handles.testpts,2);
        
        for ngrp = 1:Ngrp
            for npar = 1:length(handles.testpts(ngrp).param)
                if isempty(findpar(PARAM,handles.testpts(ngrp).param{npar})) && ~isempty(findpar(PARAM,SetUnits(handles.testpts(ngrp).param{npar})))
                    handles.testpts(ngrp).param{npar} = SetUnits(handles.testpts(ngrp).param{npar});
                end
            end
        end
        
        for ngrp = 1:Ngrp
            
            ninc = [];
            nexc = [];
            for npar = 1:length(handles.testpts(ngrp).param)
                np = strmatch(handles.testpts(ngrp).param{npar},denumber(PARAM),'exact');
                if ~isempty(np)
                    ninc = [ninc; np(1)];
                else
                    uiwait(errordlg({['Grupo: ' handles.testpts(ngrp).group '.'],...
                            ['O parâmetro ''' handles.testpts(ngrp).param{npar} ''' não foi encontrado.']},'Erro','modal'));
                    new_npar = inputvalue('Redefinir',[handles.testpts(ngrp).param{npar} ':'],PARAM);
                    while ~isempty(ninc) && ~isempty(new_npar) && any(new_npar == ninc)
                        uiwait(errordlg('Parâmetro já definido.','Erro','modal'));
                        new_npar = inputvalue('Redefinir',[handles.testpts(ngrp).param{npar} ':'],PARAM);
                    end
                    if isempty(new_npar)
                        nexc = [nexc; npar];
                    else
                        old_par = handles.testpts(ngrp).param{npar};
                        ninc = [ninc; new_npar];
                        for ng = 1:Ngrp
                            chgpar = findpar(handles.testpts(ng).param, old_par);
                            if ~isempty(chgpar)
                                handles.testpts(ng).param{chgpar} = denumber(PARAM{new_npar});
                            end
                        end
                    end
                end
            end
            
            if ~isempty(nexc)
                handles.testpts(ngrp).param(nexc)    = [];
                handles.testpts(ngrp).data(nexc,:)   = [];
                handles.testpts(ngrp).fit(nexc,:)    = [];
                handles.testpts(ngrp).aim(:,nexc)    = [];
                handles.testpts(ngrp).range1(:,nexc) = [];
                handles.testpts(ngrp).range2(:,nexc) = [];
                handles.testpts(ngrp).tol1(:,nexc)   = [];
                handles.testpts(ngrp).tol2(:,nexc)   = [];
            end
            
            if ~isempty(ninc)
                handles.index{ngrp}  = ninc;
                handles.outdex{ngrp} = setdiff((1:length(PARAM))',ninc);
                handles.testpts(ngrp).param = denumber(PARAM(handles.index{ngrp}));
            end
            
        end
    end
    
    guidata(hObject, handles);
    set(handles.grplist,'String',{testpts.group},'Value',1);
    grplist_Callback(hObject, eventdata, handles);
    
catch
    beep; uiwait(errordlg(['Arquivo ''' fname ''' incompatível.'],'Erro','modal'));
    
    handles.index  = old_index;
    handles.outdex = old_outdex;
    guidata(hObject, handles);
    
    open_btn_Callback(hObject, eventdata, handles, old_testpts, old_reftime);
end

% --------------------------------------------------------------------
function save_btn_Callback(hObject, eventdata, handles)
% Salvar lista de pontos

if isempty([handles.testpts.number])
    beep; uiwait(errordlg('Lista de pontos vazia.','Erro','modal'));
    return
end

[fname,fpath] = uiputfile({'*.mat','Arquivo mat (*.mat)'},'Salvar arquivo de pontos de ensaio',[handles.fpath handles.fname]);
if ischar(fname)
    fname = SetFileExtension(fname,'mat');
    testpts = handles.testpts;
    reftime = handles.reftime;
    
    try    
        save([fpath fname],'testpts','reftime',saveopt);
    catch
        beep; uiwait(errordlg(lasterr,'Erro','modal')); drawnow;
        return
    end
    
    handles.fpath = fpath;
    handles.fname = fname;
    handles.chg = 0;
    guidata(hObject, handles);
    
end

% -------------------------------------------------------------------
function reftime_sel_Callback(hObject, eventdata, handles, n)
global DADOS
% Definir o parametro de tempo de referencia

if nargin == 3
    n = 0;
end

if ~n
    PARAM = get(handles.reftime_sel,'String');
    if ~isempty(deblank(PARAM{1}))
        n = get(handles.reftime_sel,'Value');
        handles.reftime = denumber(PARAM{n});
        handles.chg = 1;
        guidata(hObject, handles);
    end
end

Tini = time2str2(DADOS(1,n));
Tend = time2str2(DADOS(end,n));
if isempty(Tini), Tini = '??:??:??'; end;
if isempty(Tend), Tend = '??:??:??'; end;
set(handles.interv_txt,'String',[Tini ' a ' Tend ' h']);

[ok, ndc, nna] = IsTimeOk(DADOS(:,n));
if ~ok
    beep; uiwait(warndlg({'Parâmetro de tempo não é adequado:',' ',...
            ['Pontos inválidos: ' num2str(length(nna))],...
            ['Pontos não crescentes: ' num2str(length(ndc))]},'Aviso','modal')); drawnow;
end

% -------------------------------------------------------------------
function top_sel_Callback(hObject, eventdata, handles)
global DADOS
% Definir o parametro de TOP

if isempty(DADOS)
    return
end

topcol = get(handles.top_sel,'Value');

if topcol==1
    set([handles.TOPini handles.TOPend],'String',' ','Value',1);
    return    
end

TOPPARAM = get(handles.top_sel,'String');
topparam = TOPPARAM{topcol};
sep = find(topparam=='-');
topcol = str2double(topparam(1:sep(1)-1));

set(handles.top_sel,'UserData',topcol);

[tops, ntops] = getTOPs(DADOS(:,topcol));

if isempty(tops)
    set([handles.TOPini handles.TOPend],'String',' ','Value',1);
    return
end

if length(tops)>500
    tops(501:end) = [];
    uiwait(warndlg({'Há muitos TOPs no parâmetro selecionado.',...
            'Apenas os 500 primeiros serão considerados.'},'Aviso','modal')); drawnow;
end

toplist{1} = ' ';
for n = 1:length(tops)
    toplist{n+1} = num2str(tops(n));
end

set([handles.TOPini handles.TOPend],'String',toplist,'Value',1);

% -------------------------------------------------------------------
function grplist_Callback(hObject, eventdata, handles)
% Atualizacao do grupo

Ngrp  = size(handles.testpts,2);
ngrp  = get(handles.grplist,'Value');
Npts  = length(handles.testpts(ngrp).number);
PARAM = get(handles.reftime_sel,'String');

if ~isempty(handles.testpts(ngrp).number)
    for n = 1:length(handles.testpts(ngrp).number);
        ptslist{n} = [handles.testpts(ngrp).number{n} ' - ' handles.testpts(ngrp).descr{n}];
    end
else
    ptslist = ' ';
    set(handles.include_chk,'Value',0);
    set(handles.inisample_sel,'Value',1);
end

set(handles.vis_chk,'Value',handles.testpts(ngrp).visible);

for n = 1:6
    set(handles.include_chk(n),'Value',handles.testpts(ngrp).include(n));
end
set(handles.inisample_sel,'Value',find(handles.testpts(ngrp).inisample == handles.inisamples));

if Npts
    set(handles.ptslist,'String',ptslist,'Value',1);
else
    set(handles.ptslist,'String',ptslist,'Value',[]);
end
set(handles.paramlist,'String',PARAM(handles.outdex{ngrp}),'Value',[]);
set(handles.paramsel, 'String',PARAM(handles.index{ngrp}),'Value',[]);
set([handles.aim handles.range1 handles.range2 handles.tol1 handles.tol2],'String','');

if Ngrp == 1
    set(handles.removegrp_btn,'Enable','off');
    set(handles.upgrp_btn,'Enable','inactive','CData',handles.up_ico{2});
    set(handles.dngrp_btn,'Enable','inactive','CData',handles.dn_ico{2});
else
    set(handles.removegrp_btn,'Enable','on');
    set(handles.upgrp_btn,'Enable','on','CData',handles.up_ico{1});
    set(handles.dngrp_btn,'Enable','on','CData',handles.dn_ico{1});
end

ptslist_Callback(hObject, eventdata, handles);

% -------------------------------------------------------------------
function newgrp_btn_Callback(hObject, eventdata, handles)
% Adicionar grupo

Ngrp  = size(handles.testpts,2);
PARAM = get(handles.reftime_sel,'String');

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

newgroup = emptytestptslist;
handles.testpts = orderfields(handles.testpts, newgroup);
handles.testpts(Ngrp+1) = newgroup;
handles.testpts(Ngrp+1).group = group;

handles.index{Ngrp+1}  = [];
handles.outdex{Ngrp+1} = (1:length(PARAM))';

handles.chg = 1;
guidata(hObject, handles);

set(handles.grplist,'String',{handles.testpts.group},'Value',Ngrp+1);
grplist_Callback(hObject, eventdata, handles);

% -------------------------------------------------------------------
function doublegrp_btn_Callback(hObject, eventdata, handles)
% Duplicar grupo selecionado

ngrp  = get(handles.grplist,'Value');
Ngrp  = size(handles.testpts,2);

group = '';
while ischar(group) && isempty(group)
    group = inputvalue('Duplicar Grupo','Nome:',group,[],1.05);
end
if isempty(group)
    return
end
if length(group) > 16
    group = group(1:16);
end

handles.testpts(Ngrp+1) = handles.testpts(ngrp);
handles.testpts(Ngrp+1).group = group;

handles.index{Ngrp+1}  = handles.index{ngrp};
handles.outdex{Ngrp+1} = handles.outdex{ngrp};

handles.chg = 1;
guidata(hObject, handles);

set(handles.grplist,'String',{handles.testpts.group},'Value',Ngrp+1);
grplist_Callback(hObject, eventdata, handles);

% -------------------------------------------------------------------
function removegrp_btn_Callback(hObject, eventdata, handles)
% Remover grupo selecionado

ngrp = get(handles.grplist,'Value');
Ngrp = size(handles.testpts,2);

if Ngrp == 1
    uiwait(errordlg('Deve haver pelo menos um grupo cadastrado.','Erro','modal'));
    return
end

button = questdlg({['Deseja exluir o grupo ''' handles.testpts(ngrp).group ''''],...
        'e todos os seus pontos de ensaio?'},'Confirmação','Sim','Não','Não');

if strcmp(button,'Sim')
    
    handles.testpts(ngrp) = [];
    handles.index(ngrp)   = [];
    handles.outdex(ngrp)  = [];
    
    guidata(hObject, handles);
    
    set(handles.grplist,'String',{handles.testpts.group},'Value',min(ngrp,Ngrp-1));
    grplist_Callback(hObject, eventdata, handles);
    
end

% -------------------------------------------------------------------
function renamegrp_btn_Callback(hObject, eventdata, handles)
% Renomear grupo

ngrp = get(handles.grplist,'Value');

group = inputvalue('Renomear Grupo','Nome:',handles.testpts(ngrp).group,[],1.05);
while ischar(group) && isempty(group)
    group = inputvalue('Renomear Grupo','Nome:',group,[],1.05);
end
if isempty(group)
    return
end
if length(group) > 16
    group = group(1:16);
end

handles.testpts(ngrp).group = group;

handles.chg = 1;
guidata(hObject, handles);

set(handles.grplist,'String',{handles.testpts.group});

% -------------------------------------------------------------------
function upgrp_btn_Callback(hObject, eventdata, handles)
% Mover grupo selecionado para cima

ngrp = get(handles.grplist,'Value');

if ngrp > 1
    
    aux = handles.testpts(ngrp-1);
    handles.testpts(ngrp-1) = handles.testpts(ngrp);
    handles.testpts(ngrp) = aux;
    
    aux = handles.index{ngrp-1};
    handles.index{ngrp-1} = handles.index{ngrp};
    handles.index{ngrp} = aux;
    
    aux = handles.outdex{ngrp-1};
    handles.outdex{ngrp-1} = handles.outdex{ngrp};
    handles.outdex{ngrp} = aux;
    
    handles.chg = 1;
    guidata(hObject, handles);
    
    set(handles.grplist,'String',{handles.testpts.group},'Value',ngrp-1);
    
else
    beep;
end

% -------------------------------------------------------------------
function dngrp_btn_Callback(hObject, eventdata, handles)
% Mover grupo selecionado para baixo

ngrp = get(handles.grplist,'Value');
Ngrp = size(handles.testpts,2);

if ngrp < Ngrp
    
    aux = handles.testpts(ngrp+1);
    handles.testpts(ngrp+1) = handles.testpts(ngrp);
    handles.testpts(ngrp) = aux;
    
    aux = handles.index{ngrp+1};
    handles.index{ngrp+1} = handles.index{ngrp};
    handles.index{ngrp} = aux;
    
    aux = handles.outdex{ngrp+1};
    handles.outdex{ngrp+1} = handles.outdex{ngrp};
    handles.outdex{ngrp} = aux;
    
    handles.chg = 1;
    guidata(hObject, handles);
    
    set(handles.grplist,'String',{handles.testpts.group},'Value',ngrp+1);
    
else
    beep;
end

% -------------------------------------------------------------------
function vis_chk_Callback(hObject, eventdata, handles)
% Alternar visibilidade do grupo no grafico principal

ngrp = get(handles.grplist,'Value');

handles.testpts(ngrp).visible = get(handles.vis_chk,'Value');
handles.chg = 1;
guidata(hObject, handles);

% -------------------------------------------------------------------
function ptslist_Callback(hObject, eventdata, handles)
% Atualizacao da lista e dos campos de dados

ngrp = get(handles.grplist,'Value');
npt  = get(handles.ptslist,'Value');
Npts = length(handles.testpts(ngrp).number);

if Npts && ~isempty(npt)
    
    set(handles.toggleenable,'Enable','on');
    set([handles.uppt_btn handles.upparam_btn],'CData',handles.up_ico{1});
    set([handles.dnpt_btn handles.dnparam_btn],'CData',handles.dn_ico{1});
    
    if length(npt) == 1
        
        set(handles.Tini,'String',time2str2(handles.testpts(ngrp).time(1,npt)));
        set(handles.Tend,'String',time2str2(handles.testpts(ngrp).time(2,npt)));
        set(handles.duration,'String',time2str2(diff(handles.testpts(ngrp).time(:,npt))));
        set([handles.TOPini handles.TOPend handles.EVTini handles.EVTend],'Value',1);
        paramsel_Callback(hObject, eventdata, handles);
        
    else
        
        set([handles.Tini handles.Tend handles.duration],'String','','Enable','off');
        set([handles.TOPini handles.TOPend handles.EVTini handles.EVTend],'Value',1,'Enable','off');
        paramsel_Callback(hObject, eventdata, handles);
        
    end
    
else
    
    set(handles.toggleenable,'Enable','off');
    set([handles.uppt_btn handles.upparam_btn],'Enable','inactive','CData',handles.up_ico{2});
    set([handles.dnpt_btn handles.dnparam_btn],'Enable','inactive','CData',handles.dn_ico{2});
    set([handles.Tini handles.Tend handles.duration handles.aim,...
            handles.range1 handles.range2 handles.tol1 handles.tol2],'String','');
    set([handles.TOPini handles.TOPend handles.EVTini handles.EVTend],'Value',1);
    paramsel_Callback(hObject, eventdata, handles);
    
end

% -------------------------------------------------------------------
function newpt_btn_Callback(hObject, eventdata, handles)
% Acrescentar novo ponto de ensaio

num = '';
descr = '';
while ischar(num) && isempty(num) || ischar(descr) && isempty(descr)
    [num, descr] = inputpoint('Novo Ponto de Ensaio','Número:','Descrição:', num, descr);
end
if isempty(num)
    return
end

if length(num) > 8
    num = num(1:8);
end
if length(descr) > 56
    descr = descr(1:56);
end

ngrp = get(handles.grplist,'Value');
Npts = length(handles.testpts(ngrp).number);
Npar = length(handles.index{ngrp});

% Valores por ponto (uma coluna por ponto)
handles.testpts(ngrp).number{Npts+1}   = num;
handles.testpts(ngrp).descr{Npts+1}    = descr;
handles.testpts(ngrp).time(:,Npts+1)   = [NaN; NaN];

% Valores por ponto e parametro (uma linha por ponto e uma coluna por parametro)
handles.testpts(ngrp).aim(Npts+1,:)    = NaN*ones(1,Npar);
handles.testpts(ngrp).range1(Npts+1,:) = NaN*ones(1,Npar);
handles.testpts(ngrp).range2(Npts+1,:) = NaN*ones(1,Npar);
handles.testpts(ngrp).tol1(Npts+1,:)   = NaN*ones(1,Npar);
handles.testpts(ngrp).tol2(Npts+1,:)   = NaN*ones(1,Npar);

if isempty([handles.testpts.number])
    PARAM = get(handles.reftime_sel,'String');
    nreftime = get(handles.reftime_sel,'Value');
    handles.reftime = denumber(PARAM{nreftime});
end

handles.chg = 1;
guidata(hObject, handles);

for n = 1:Npts+1;
    ptslist{n} = [handles.testpts(ngrp).number{n} ' - ' handles.testpts(ngrp).descr{n}];
end
set(handles.ptslist,'String',ptslist,'Value',Npts+1);

set(handles.toggleenable,'Enable','on');
set(handles.uppt_btn,'CData',handles.up_ico{1});
set(handles.dnpt_btn,'CData',handles.dn_ico{1});
ptslist_Callback(hObject, eventdata, handles);

% -------------------------------------------------------------------
function doublept_btn_Callback(hObject, eventdata, handles)
% Duplicar ponto de ensaio selecionado

ngrp1 = get(handles.grplist,'Value');
npt  = get(handles.ptslist,'Value');
Npts = length(handles.testpts(ngrp1).number);

if ~Npts || length(npt) ~= 1
    beep;
    return
end

num = '';
descr = '';
groups = {handles.testpts.group};
while ischar(num) && isempty(num) || ischar(descr) && isempty(descr)
    [ngrp2, num, descr] = inputpoint2('Duplicar Ponto de Ensaio','Grupo:','Número:','Descrição:', groups, num, descr, ngrp1);
end
if isempty(num)
    return
end

if length(num) > 8
    num = num(1:8);
end
if length(descr) > 56
    descr = descr(1:56);
end

if ngrp2 ~= ngrp1
    Npar = length(handles.index{ngrp2});
    Npts = length(handles.testpts(ngrp2).number);
end

% Valores por ponto (uma coluna por ponto)
handles.testpts(ngrp2).number{Npts+1}   = num;
handles.testpts(ngrp2).descr{Npts+1}    = descr;
handles.testpts(ngrp2).time(:,Npts+1)   = handles.testpts(ngrp1).time(:,npt);

% Valores por ponto e parametro (uma linha por ponto e uma coluna por parametro)
if ngrp2 == ngrp1
    handles.testpts(ngrp2).aim(Npts+1,:)    = handles.testpts(ngrp1).aim(npt,:);
    handles.testpts(ngrp2).range1(Npts+1,:) = handles.testpts(ngrp1).range1(npt,:);
    handles.testpts(ngrp2).range2(Npts+1,:) = handles.testpts(ngrp1).range2(npt,:);
    handles.testpts(ngrp2).tol1(Npts+1,:)   = handles.testpts(ngrp1).tol1(npt,:);
    handles.testpts(ngrp2).tol2(Npts+1,:)   = handles.testpts(ngrp1).tol2(npt,:);
else
    handles.testpts(ngrp2).aim(Npts+1,:)    = NaN*ones(1,Npar);
    handles.testpts(ngrp2).range1(Npts+1,:) = NaN*ones(1,Npar);
    handles.testpts(ngrp2).range2(Npts+1,:) = NaN*ones(1,Npar);
    handles.testpts(ngrp2).tol1(Npts+1,:)   = NaN*ones(1,Npar);
    handles.testpts(ngrp2).tol2(Npts+1,:)   = NaN*ones(1,Npar);
end

handles.chg = 1;
guidata(hObject, handles);

if ngrp2 == ngrp1
    for n = 1:Npts+1;
        ptslist{n} = [handles.testpts(ngrp1).number{n} ' - ' handles.testpts(ngrp1).descr{n}];
    end
    set(handles.ptslist,'String',ptslist,'Value',Npts+1);
end

ptslist_Callback(hObject, eventdata, handles);

% -------------------------------------------------------------------
function removept_btn_Callback(hObject, eventdata, handles)
% Remover ponto de ensaio selecionado

ngrp = get(handles.grplist,'Value');
npt  = get(handles.ptslist,'Value');
Npts = length(handles.testpts(ngrp).number);

if ~Npts || isempty(npt)
    beep;
    return
end

if length(npt) == 1
    str = ['Deseja excluir o ponto ' handles.testpts(ngrp).number{npt} ' ?'];
else
    str = ['Deseja excluir os ' num2str(length(npt)) ' pontos selecionados?'];
end

button = questdlg(str,'Confirmação','Sim','Não','Não');

if strcmp(button,'Sim')
    
    % Valores por ponto (uma coluna por ponto)
    handles.testpts(ngrp).number(npt)   = [];
    handles.testpts(ngrp).descr(npt)    = [];
    handles.testpts(ngrp).time(:,npt)   = [];
    
    % Valores por ponto e parametro (uma linha por ponto e uma coluna por parametro)
    if ~isempty(handles.testpts(ngrp).param)
        handles.testpts(ngrp).aim(npt,:)    = [];
        handles.testpts(ngrp).range1(npt,:) = [];
        handles.testpts(ngrp).range2(npt,:) = [];
        handles.testpts(ngrp).tol1(npt,:)   = [];
        handles.testpts(ngrp).tol2(npt,:)   = [];
    end
    
    handles.chg = 1;
    guidata(hObject, handles);
    
    if Npts > length(npt)
        for n = 1:Npts-length(npt);
            ptslist{n} = [handles.testpts(ngrp).number{n} ' - ' handles.testpts(ngrp).descr{n}];
        end
        set(handles.ptslist,'String',ptslist,'Value',min(npt(end),Npts-length(npt)));
    else
        set(handles.ptslist,'String',' ','Value',[]);
    end
    ptslist_Callback(hObject, eventdata, handles);
end

% -------------------------------------------------------------------
function renamept_btn_Callback(hObject, eventdata, handles)
% Renomear ponto de ensaio selecionado

ngrp = get(handles.grplist,'Value');
npt  = get(handles.ptslist,'Value');
Npts = length(handles.testpts(ngrp).number);

if ~Npts || length(npt) ~= 1
    beep;
    return
end

[num, descr] = inputpoint('Renomear Ponto de Ensaio','Número:','Descrição:', handles.testpts(ngrp).number{npt}, handles.testpts(ngrp).descr{npt});
while ischar(num) && isempty(num) || ischar(descr) && isempty(descr)
    [num, descr] = inputpoint('Renomear Ponto de Ensaio','Número:','Descrição:', num, descr);
end
if isempty(num)
    return
end

if length(num) > 8
    num = num(1:8);
end
if length(descr) > 56
    descr = descr(1:56);
end

handles.testpts(ngrp).number{npt} = num;
handles.testpts(ngrp).descr{npt}  = descr;

handles.chg = 1;
guidata(hObject, handles);

for n = 1:length(handles.testpts(ngrp).number);
    ptslist{n} = [handles.testpts(ngrp).number{n} ' - ' handles.testpts(ngrp).descr{n}];
end
set(handles.ptslist,'String',ptslist);

% -------------------------------------------------------------------
function uppt_btn_Callback(hObject, eventdata, handles)
% Mover ponto de ensaio selecionado para cima

ngrp = get(handles.grplist,'Value');
npt  = get(handles.ptslist,'Value');
Npts = length(handles.testpts(ngrp).number);

if ~Npts || length(npt) ~= 1
    beep;
    return
end

if npt > 1
    
    % Valores por ponto (uma coluna um ponto)
    aux = handles.testpts(ngrp).number{npt-1};
    handles.testpts(ngrp).number{npt-1} = handles.testpts(ngrp).number{npt};
    handles.testpts(ngrp).number{npt} = aux;
    
    aux = handles.testpts(ngrp).descr{npt-1};
    handles.testpts(ngrp).descr{npt-1} = handles.testpts(ngrp).descr{npt};
    handles.testpts(ngrp).descr{npt} = aux;
    
    aux = handles.testpts(ngrp).time(:,npt-1);
    handles.testpts(ngrp).time(:,npt-1) = handles.testpts(ngrp).time(:,npt);
    handles.testpts(ngrp).time(:,npt) = aux;
    
    % Valores por ponto e parametro (uma linha por ponto e uma coluna por parametro)
    aux = handles.testpts(ngrp).aim(npt-1,:);
    handles.testpts(ngrp).aim(npt-1,:) = handles.testpts(ngrp).aim(npt,:);
    handles.testpts(ngrp).aim(npt,:) = aux;
    
    aux = handles.testpts(ngrp).range1(npt-1,:);
    handles.testpts(ngrp).range1(npt-1,:) = handles.testpts(ngrp).range1(npt,:);
    handles.testpts(ngrp).range1(npt,:) = aux;
    
    aux = handles.testpts(ngrp).range2(npt-1,:);
    handles.testpts(ngrp).range2(npt-1,:) = handles.testpts(ngrp).range2(npt,:);
    handles.testpts(ngrp).range2(npt,:) = aux;
    
    aux = handles.testpts(ngrp).tol1(npt-1,:);
    handles.testpts(ngrp).tol1(npt-1,:) = handles.testpts(ngrp).tol1(npt,:);
    handles.testpts(ngrp).tol1(npt,:) = aux;
    
    aux = handles.testpts(ngrp).tol2(npt-1,:);
    handles.testpts(ngrp).tol2(npt-1,:) = handles.testpts(ngrp).tol2(npt,:);
    handles.testpts(ngrp).tol2(npt,:) = aux;
    
    handles.chg = 1;
    guidata(hObject, handles);
    
    for n = 1:Npts;
        ptslist{n} = [handles.testpts(ngrp).number{n} ' - ' handles.testpts(ngrp).descr{n}];
    end
    set(handles.ptslist,'String',ptslist,'Value',npt-1);
    
else
    beep;
end

% -------------------------------------------------------------------
function dnpt_btn_Callback(hObject, eventdata, handles)
% Mover ponto de ensaio selecionado para baixo

ngrp = get(handles.grplist,'Value');
npt  = get(handles.ptslist,'Value');
Npts = length(handles.testpts(ngrp).number);

if ~Npts || length(npt) ~= 1
    beep;
    return
end

if npt < Npts
    
    % Valores por ponto (uma coluna um ponto)
    aux = handles.testpts(ngrp).number{npt+1};
    handles.testpts(ngrp).number{npt+1} = handles.testpts(ngrp).number{npt};
    handles.testpts(ngrp).number{npt} = aux;
    
    aux = handles.testpts(ngrp).descr{npt+1};
    handles.testpts(ngrp).descr{npt+1} = handles.testpts(ngrp).descr{npt};
    handles.testpts(ngrp).descr{npt} = aux;
    
    aux = handles.testpts(ngrp).time(:,npt+1);
    handles.testpts(ngrp).time(:,npt+1) = handles.testpts(ngrp).time(:,npt);
    handles.testpts(ngrp).time(:,npt) = aux;
    
    % Valores por ponto e parametro (uma linha por ponto e uma coluna por parametro)
    aux = handles.testpts(ngrp).aim(npt+1,:);
    handles.testpts(ngrp).aim(npt+1,:) = handles.testpts(ngrp).aim(npt,:);
    handles.testpts(ngrp).aim(npt,:) = aux;
    
    aux = handles.testpts(ngrp).range1(npt+1,:);
    handles.testpts(ngrp).range1(npt+1,:) = handles.testpts(ngrp).range1(npt,:);
    handles.testpts(ngrp).range1(npt,:) = aux;
    
    aux = handles.testpts(ngrp).range2(npt+1,:);
    handles.testpts(ngrp).range2(npt+1,:) = handles.testpts(ngrp).range2(npt,:);
    handles.testpts(ngrp).range2(npt,:) = aux;
    
    aux = handles.testpts(ngrp).tol1(npt+1,:);
    handles.testpts(ngrp).tol1(npt+1,:) = handles.testpts(ngrp).tol1(npt,:);
    handles.testpts(ngrp).tol1(npt,:) = aux;
    
    aux = handles.testpts(ngrp).tol2(npt+1,:);
    handles.testpts(ngrp).tol2(npt+1,:) = handles.testpts(ngrp).tol2(npt,:);
    handles.testpts(ngrp).tol2(npt,:) = aux;
    
    handles.chg = 1;
    guidata(hObject, handles);
    
    for n = 1:Npts;
        ptslist{n} = [handles.testpts(ngrp).number{n} ' - ' handles.testpts(ngrp).descr{n}];
    end
    set(handles.ptslist,'String',ptslist,'Value',npt+1);
    
    ptslist_Callback(hObject, eventdata, handles);
    
else
    beep;
end

% -------------------------------------------------------------------
function Tini_Callback(hObject, eventdata, handles, opt)
% Definir tempo inicial do ponto de ensaio selecionado

if nargin == 3
    opt = 1;
end
if opt
    set([handles.TOPini handles.EVTini],'Value',1);
end

[t, str] = str2time(get(handles.Tini,'String'));
set(handles.Tini,'String',str);

ngrp = get(handles.grplist,'Value');
npt  = get(handles.ptslist,'Value');

if t > handles.testpts(ngrp).time(2,npt)
    uiwait(warndlg('Tempo inicial não pode ser maior que tempo final.','Aviso','modal'));
    t = handles.testpts(ngrp).time(1,npt);
    str = time2str2(t);
    set([handles.TOPini handles.EVTini],'Value',1);
end
set(handles.Tini,'String',str);
handles.testpts(ngrp).time(1,npt) = t;

handles.chg = 1;
guidata(hObject, handles);

set(handles.duration,'String',time2str2(diff(handles.testpts(ngrp).time(:,npt))));

% -------------------------------------------------------------------
function Tend_Callback(hObject, eventdata, handles, opt)
% Definir tempo final do ponto de ensaio selecionado

if nargin == 3
    opt = 1;
end
if opt
    set([handles.TOPend handles.EVTend],'Value',1);
end

[t, str] = str2time(get(handles.Tend,'String'));
set(handles.Tend,'String',str);

ngrp = get(handles.grplist,'Value');
npt  = get(handles.ptslist,'Value');

if t < handles.testpts(ngrp).time(1,npt)
    uiwait(warndlg('Tempo final não pode ser menor que tempo inicial.','Aviso','modal'));
    t = handles.testpts(ngrp).time(2,npt);
    str = time2str2(t);
    set([handles.TOPend handles.EVTend],'Value',1);
end    
set(handles.Tend,'String',str);
handles.testpts(ngrp).time(2,npt) = t;

handles.chg = 1;
guidata(hObject, handles);

set(handles.duration,'String',time2str2(diff(handles.testpts(ngrp).time(:,npt))));

% -------------------------------------------------------------------
function duration_Callback(hObject, eventdata, handles)
% Definir duracao do ponto de ensaio selecionado

[dt, str] = str2time(get(handles.duration,'String'));
set(handles.duration,'String',str);

if dt < 0
    uiwait(warndlg('Duração não pode ser negativa.','Aviso','modal'));
    Tend_Callback(hObject, eventdata, handles, 0);
    return
end

ngrp = get(handles.grplist,'Value');
npt  = get(handles.ptslist,'Value');

if isnan(dt)
    set(handles.duration,'String',time2str2(diff(handles.testpts(ngrp).time(:,npt))));
else
    
    if    ~isnan(handles.testpts(ngrp).time(1,npt))
        handles.testpts(ngrp).time(2,npt) = handles.testpts(ngrp).time(1,npt)+dt;
        
    elseif isnan(handles.testpts(ngrp).time(1,npt)) && ~isnan(handles.testpts(ngrp).time(2,npt))
        handles.testpts(ngrp).time(1,npt) = handles.testpts(ngrp).time(2,npt)-dt;
        
    else
        set(handles.duration,'String','');
    end
    
    handles.chg = 1;
    guidata(hObject, handles);
    set(handles.Tini,'String',time2str2(handles.testpts(ngrp).time(1,npt)));
    set(handles.Tend,'String',time2str2(handles.testpts(ngrp).time(2,npt)));
end

% -------------------------------------------------------------------
function TOPini_Callback(hObject, eventdata, handles)
global DADOS
% Definir tempo inicial do ponto de ensaio selecionado a partir de um TOP

set(handles.EVTini,'Value',1);

if isempty(DADOS)
    return
end

tops  = get(handles.TOPini,'String');
ntop  = get(handles.TOPini,'Value');
timecol = get(handles.reftime_sel,'Value');
topcol  = get(handles.top_sel,'UserData');

if ntop == 1
    return
end

ntop = str2double(tops{ntop});

ntop = find(round(DADOS(:,topcol))==ntop);
ntop = ntop(1);

if ntop == 1
    tini = DADOS(ntop,timecol);
else
    tini = mean(DADOS(ntop-1:ntop,timecol));
end

set(handles.Tini,'String',num2str(tini,16));
Tini_Callback(hObject, eventdata, handles, 0);

% -------------------------------------------------------------------
function TOPend_Callback(hObject, eventdata, handles)
global DADOS
% Definir tempo final do ponto de ensaio selecionado a partir de um TOP

set(handles.EVTend,'Value',1);

if isempty(DADOS)
    return
end

tops  = get(handles.TOPend,'String');
ntop  = get(handles.TOPend,'Value');
timecol = get(handles.reftime_sel,'Value');
topcol  = get(handles.top_sel,'UserData');

if ntop == 1
    return
end

ntop = str2double(tops{ntop});

ntop = find(round(DADOS(:,topcol))==ntop);
ntop = ntop(1);

if ntop == 1
    tend = DADOS(ntop,timecol);
else
    tend = mean(DADOS(ntop-1:ntop,timecol));
end

set(handles.Tend,'String',num2str(tend,16));
Tend_Callback(hObject, eventdata, handles, 0);

% -------------------------------------------------------------------
function EVTini_Callback(hObject, eventdata, handles)
% Definir tempo inicial do ponto de ensaio selecionado a partir de um evento

set(handles.TOPini,'Value',1);

n = get(handles.EVTini,'Value')-1;
if n
    t = handles.events{n,2};
    set(handles.Tini,'String',num2str(t));
else
    set(handles.Tini,'String','');
end
Tini_Callback(hObject, eventdata, handles, 0);

% -------------------------------------------------------------------
function EVTend_Callback(hObject, eventdata, handles)
% Definir tempo final do ponto de ensaio selecionado a partir de um evento

set(handles.TOPend,'Value',1);

n = get(handles.EVTend,'Value')-1;
if n
    t = handles.events{n,2};
    set(handles.Tend,'String',num2str(t));
else
    set(handles.Tend,'String','');
end
Tend_Callback(hObject, eventdata, handles, 0);

% -------------------------------------------------------------------
function descr_chk_Callback(hObject, eventdata, handles)
updateincludelist(hObject, eventdata, handles, 1);

% -------------------------------------------------------------------
function Tini_chk_Callback(hObject, eventdata, handles)
updateincludelist(hObject, eventdata, handles, 2);

% -------------------------------------------------------------------
function Tend_chk_Callback(hObject, eventdata, handles)
updateincludelist(hObject, eventdata, handles, 3);

% -------------------------------------------------------------------
function dur_chk_Callback(hObject, eventdata, handles)
updateincludelist(hObject, eventdata, handles, 4);

% -------------------------------------------------------------------
function size_chk_Callback(hObject, eventdata, handles)
updateincludelist(hObject, eventdata, handles, 5);

% -------------------------------------------------------------------
function val_chk_Callback(hObject, eventdata, handles)
updateincludelist(hObject, eventdata, handles, 6);

% -------------------------------------------------------------------
function updateincludelist(hObject, eventdata, handles, ni)
ngrp = get(handles.grplist,'Value');
handles.testpts(ngrp).include(ni) = get(handles.include_chk(ni),'Value');
handles.chg = 1;
guidata(hObject, handles);

% -------------------------------------------------------------------
function inisample_sel_Callback(hObject, eventdata, handles)
ngrp = get(handles.grplist,'Value');
handles.testpts(ngrp).inisample = handles.inisamples(get(handles.inisample_sel,'Value'));
handles.chg = 1;
guidata(hObject, handles);

% -------------------------------------------------------------------
function paramlist_Callback(hObject, eventdata, handles)

% -------------------------------------------------------------------
function paramsel_Callback(hObject, eventdata, handles)
% Funcao executada ao se clicar na lista de parametros selecionados

ngrp = get(handles.grplist,'Value');
Npts = length(handles.testpts(ngrp).number);

if Npts
    npar = get(handles.paramsel,'Value');
    
    if isempty(handles.index{ngrp}) || isempty(npar)
        set([handles.data_chk handles.fit_chk],'Value',0,'ForegroundColor','k');
        set(handles.fitord_sel,'Value',1,'ForegroundColor','k');
        return
    end
    
    for nd = 1:13
        if     all( handles.testpts(ngrp).data(npar,nd)) % Todos = 1
            set(handles.data_chk(nd),'Value',1,'ForegroundColor','k');
        elseif all(~handles.testpts(ngrp).data(npar,nd)) % Todos = 0
            set(handles.data_chk(nd),'Value',0,'ForegroundColor','k');
        else
            set(handles.data_chk(nd),'Value',1,'ForegroundColor',.5*[1 1 1]);
        end
    end
    
    if     all(~diff(handles.testpts(ngrp).fit(npar,1))) % Todos iguais
        set(handles.fitord_sel,'Value',handles.testpts(ngrp).fit(npar(1),1)+1,'ForegroundColor','k');
    else
        set(handles.fitord_sel,'Value',1,'ForegroundColor',.5*[1 1 1]);
    end
    
    for nf = 1:7
        if     all( handles.testpts(ngrp).fit(npar,nf+1)) % Todos = 1
            set(handles.fit_chk(nf),'Value',1,'ForegroundColor','k');
        elseif all(~handles.testpts(ngrp).fit(npar,nf+1)) % Todos = 0
            set(handles.fit_chk(nf),'Value',0,'ForegroundColor','k');
        else
            set(handles.fit_chk(nf),'Value',1,'ForegroundColor',.5*[1 1 1]);
        end
    end
    
    npt = get(handles.ptslist,'Value');
    if ~any(any(isnan(handles.testpts(ngrp).aim(npt,npar))))    &&  length(unique(handles.testpts(ngrp).aim(npt,npar)))==1    % Todos iguais
        set(handles.aim,'String',num2str(nan2empty(handles.testpts(ngrp).aim(npt(1),npar(1))),16));
    else
        set(handles.aim,'String','');
    end
    if ~any(any(isnan(handles.testpts(ngrp).range1(npt,npar)))) &&  length(unique(handles.testpts(ngrp).range1(npt,npar)))==1 %  Todos iguais
        set(handles.range1,'String',num2str(nan2empty(handles.testpts(ngrp).range1(npt(1),npar(1))),16));
    else
        set(handles.range1,'String','');
    end
    if ~any(any(isnan(handles.testpts(ngrp).range2(npt,npar)))) &&  length(unique(handles.testpts(ngrp).range2(npt,npar)))==1 %  Todos iguais
        set(handles.range2,'String',num2str(nan2empty(handles.testpts(ngrp).range2(npt(1),npar(1))),16));
    else
        set(handles.range2,'String','');
    end
    if ~any(any(isnan(handles.testpts(ngrp).tol1(npt,npar))))   &&  length(unique(handles.testpts(ngrp).tol1(npt,npar)))==1   %  Todos iguais
        set(handles.tol1,'String',num2str(nan2empty(handles.testpts(ngrp).tol1(npt(1),npar(1))),16));
    else
        set(handles.tol1,'String','');
    end
    if ~any(any(isnan(handles.testpts(ngrp).tol2(npt,npar))))   &&  length(unique(handles.testpts(ngrp).tol2(npt,npar)))==1   %  Todos iguais
        set(handles.tol2,'String',num2str(nan2empty(handles.testpts(ngrp).tol2(npt(1),npar(1))),16));
    else
        set(handles.tol2,'String','');
    end
    
end

% -------------------------------------------------------------------
function addparam_btn_Callback(hObject, eventdata, handles)
% Acrescentar parametro à lista

PARAM = get(handles.reftime_sel,'String');
ngrp  = get(handles.grplist,'Value');
Npts  = length(handles.testpts(ngrp).number);
Nout  = get(handles.paramlist,'Value');

if ~isempty(Nout) && ~isempty(handles.outdex{ngrp})
    
    handles.index{ngrp} = [handles.index{ngrp}; handles.outdex{ngrp}(Nout)];
    handles.outdex{ngrp}(Nout) = [];
    
    handles.testpts(ngrp).param  = denumber(PARAM(handles.index{ngrp}));
    handles.testpts(ngrp).data   = [handles.testpts(ngrp).data; zeros(length(Nout),13)];
    handles.testpts(ngrp).fit    = [handles.testpts(ngrp).fit;  zeros(length(Nout),8)];
    handles.testpts(ngrp).aim    = [handles.testpts(ngrp).aim,    NaN*ones(Npts,length(Nout))];
    handles.testpts(ngrp).range1 = [handles.testpts(ngrp).range1, NaN*ones(Npts,length(Nout))];
    handles.testpts(ngrp).range2 = [handles.testpts(ngrp).range2, NaN*ones(Npts,length(Nout))];
    handles.testpts(ngrp).tol1   = [handles.testpts(ngrp).tol1,   NaN*ones(Npts,length(Nout))];
    handles.testpts(ngrp).tol2   = [handles.testpts(ngrp).tol2,   NaN*ones(Npts,length(Nout))];
    
    handles.chg = 1;
    guidata(hObject, handles);
    
    set(handles.paramlist,'String',PARAM(handles.outdex{ngrp}),'Value',max(1,min(length(handles.outdex{ngrp}),Nout(1))));
    set(handles.paramsel, 'String',PARAM(handles.index{ngrp}));
    
    paramsel_Callback(hObject, eventdata, handles);
else
    beep;
end

% -------------------------------------------------------------------
function remparam_btn_Callback(hObject, eventdata, handles)
% Remover parametro da lista

PARAM = get(handles.reftime_sel,'String');
ngrp  = get(handles.grplist,'Value');
Nin = get(handles.paramsel,'Value');

if ~isempty(Nin) && ~isempty(handles.index{ngrp})
    
    handles.outdex{ngrp} = sort([handles.outdex{ngrp}; handles.index{ngrp}(Nin)]);
    handles.index{ngrp}(Nin) = [];
    
    handles.testpts(ngrp).param = denumber(PARAM(handles.index{ngrp}));
    handles.testpts(ngrp).data(Nin,:)   = [];
    handles.testpts(ngrp).fit(Nin,:)    = [];
    handles.testpts(ngrp).aim(:,Nin)    = [];
    handles.testpts(ngrp).range1(:,Nin) = [];
    handles.testpts(ngrp).range2(:,Nin) = [];
    handles.testpts(ngrp).tol1(:,Nin)   = [];
    handles.testpts(ngrp).tol2(:,Nin)   = [];
    
    handles.chg = 1;
    guidata(hObject, handles);
    
    set(handles.paramsel, 'String',PARAM(handles.index{ngrp}),'Value',max(1,min(length(handles.index{ngrp}),Nin(1))));
    set(handles.paramlist,'String',PARAM(handles.outdex{ngrp}));
    
    paramsel_Callback(hObject, eventdata, handles);
else
    beep;
end

% -------------------------------------------------------------------
function addallparam_txt_Callback(hObject, eventdata, handles)
% Acrescentar todos os parametro à lista

PARAM = get(handles.reftime_sel,'String');
ngrp  = get(handles.grplist,'Value');
Npts  = length(handles.testpts(ngrp).number);

if ~isempty(handles.outdex{ngrp})
    
    Nout = 1:length(handles.outdex{ngrp});
    handles.index{ngrp} = [handles.index{ngrp}; handles.outdex{ngrp}(Nout)];
    handles.outdex{ngrp}(Nout) = [];
    
    handles.testpts(ngrp).param  = denumber(PARAM(handles.index{ngrp}));
    handles.testpts(ngrp).data   = [handles.testpts(ngrp).data;   zeros(length(Nout),13)];
    handles.testpts(ngrp).fit    = [handles.testpts(ngrp).fit;    zeros(length(Nout),8)];
    handles.testpts(ngrp).aim    = [handles.testpts(ngrp).aim,    NaN*ones(Npts,length(Nout))];
    handles.testpts(ngrp).range1 = [handles.testpts(ngrp).range1, NaN*ones(Npts,length(Nout))];
    handles.testpts(ngrp).range2 = [handles.testpts(ngrp).range2, NaN*ones(Npts,length(Nout))];
    handles.testpts(ngrp).tol1   = [handles.testpts(ngrp).tol1,   NaN*ones(Npts,length(Nout))];
    handles.testpts(ngrp).tol2   = [handles.testpts(ngrp).tol2,   NaN*ones(Npts,length(Nout))];
    
    handles.chg = 1;
    guidata(hObject, handles);
    
    set(handles.paramlist,'String',PARAM(handles.outdex{ngrp}),'Value',max(1,min(length(handles.outdex{ngrp}),Nout(1))));
    set(handles.paramsel, 'String',PARAM(handles.index{ngrp}));
    
    paramsel_Callback(hObject, eventdata, handles);
else
    beep;
end

% -------------------------------------------------------------------
function remallparam_btn_Callback(hObject, eventdata, handles)
% Acrescentar todos os parametro da lista

PARAM = get(handles.reftime_sel,'String');
ngrp  = get(handles.grplist,'Value');

if ~isempty(handles.index{ngrp})
    
    handles.outdex{ngrp} = (1:length(PARAM))';
    handles.index{ngrp}  = [];
    
    handles.testpts(ngrp).param  = {};
    handles.testpts(ngrp).data   = [];
    handles.testpts(ngrp).fit    = [];
    handles.testpts(ngrp).aim    = [];
    handles.testpts(ngrp).range1 = [];
    handles.testpts(ngrp).range2 = [];
    handles.testpts(ngrp).tol1   = [];
    handles.testpts(ngrp).tol2   = [];
    
    handles.chg = 1;
    guidata(hObject, handles);
    
    set(handles.paramlist,'String',PARAM(handles.outdex{ngrp}),'Value',[]);
    set(handles.paramsel, 'String',PARAM(handles.index{ngrp}),'Value',[]);
    
    paramsel_Callback(hObject, eventdata, handles);
else
    beep;
end

% -------------------------------------------------------------------
function upparam_btn_Callback(hObject, eventdata, handles)
% Mover parametro selecionado para cima

PARAM = get(handles.reftime_sel,'String');
ngrp  = get(handles.grplist,'Value');
Nin   = get(handles.paramsel,'Value');

if length(Nin) == 1 && Nin > 1
    
    aux = handles.index{ngrp}(Nin);
    handles.index{ngrp}(Nin) = handles.index{ngrp}(Nin-1);
    handles.index{ngrp}(Nin-1) = aux;
    
    handles.testpts(ngrp).param = denumber(PARAM(handles.index{ngrp}));
    
    aux = handles.testpts(ngrp).data(Nin,:);
    handles.testpts(ngrp).data(Nin,:) = handles.testpts(ngrp).data(Nin-1,:);
    handles.testpts(ngrp).data(Nin-1,:) = aux;
    
    aux = handles.testpts(ngrp).fit(Nin,:);
    handles.testpts(ngrp).fit(Nin,:) = handles.testpts(ngrp).fit(Nin-1,:);
    handles.testpts(ngrp).fit(Nin-1,:) = aux;
    
    aux = handles.testpts(ngrp).aim(:,Nin);
    handles.testpts(ngrp).aim(:,Nin) = handles.testpts(ngrp).aim(:,Nin-1);
    handles.testpts(ngrp).aim(:,Nin-1) = aux;
    
    aux = handles.testpts(ngrp).range1(:,Nin);
    handles.testpts(ngrp).range1(:,Nin) = handles.testpts(ngrp).range1(:,Nin-1);
    handles.testpts(ngrp).range1(:,Nin-1) = aux;
    
    aux = handles.testpts(ngrp).range2(:,Nin);
    handles.testpts(ngrp).range2(:,Nin) = handles.testpts(ngrp).range2(:,Nin-1);
    handles.testpts(ngrp).range2(:,Nin-1) = aux;
    
    aux = handles.testpts(ngrp).tol1(:,Nin);
    handles.testpts(ngrp).tol1(:,Nin) = handles.testpts(ngrp).tol1(:,Nin-1);
    handles.testpts(ngrp).tol1(:,Nin-1) = aux;
    
    aux = handles.testpts(ngrp).tol2(:,Nin);
    handles.testpts(ngrp).tol2(:,Nin) = handles.testpts(ngrp).tol2(:,Nin-1);
    handles.testpts(ngrp).tol2(:,Nin-1) = aux;
    
    handles.chg = 1;
    guidata(hObject, handles);
    
    set(handles.paramsel,'String',PARAM(handles.index{ngrp}),'Value',Nin-1);
    
else
    beep;
end

% -------------------------------------------------------------------
function dnparam_btn_Callback(hObject, eventdata, handles)
% Mover parametro selecionado para baixo

PARAM = get(handles.reftime_sel,'String');
ngrp  = get(handles.grplist,'Value');
Nin   = get(handles.paramsel,'Value');

if length(Nin) == 1 && Nin < length(handles.index{ngrp})
    
    aux = handles.index{ngrp}(Nin);
    handles.index{ngrp}(Nin) = handles.index{ngrp}(Nin+1);
    handles.index{ngrp}(Nin+1) = aux;
    
    handles.testpts(ngrp).param = denumber(PARAM(handles.index{ngrp}));
    
    aux = handles.testpts(ngrp).data(Nin,:);
    handles.testpts(ngrp).data(Nin,:) = handles.testpts(ngrp).data(Nin+1,:);
    handles.testpts(ngrp).data(Nin+1,:) = aux;
    
    aux = handles.testpts(ngrp).fit(Nin,:);
    handles.testpts(ngrp).fit(Nin,:) = handles.testpts(ngrp).fit(Nin+1,:);
    handles.testpts(ngrp).fit(Nin+1,:) = aux;
    
    aux = handles.testpts(ngrp).aim(:,Nin);
    handles.testpts(ngrp).aim(:,Nin) = handles.testpts(ngrp).aim(:,Nin+1);
    handles.testpts(ngrp).aim(:,Nin+1) = aux;
    
    aux = handles.testpts(ngrp).range1(:,Nin);
    handles.testpts(ngrp).range1(:,Nin) = handles.testpts(ngrp).range1(:,Nin+1);
    handles.testpts(ngrp).range1(:,Nin+1) = aux;
    
    aux = handles.testpts(ngrp).range2(:,Nin);
    handles.testpts(ngrp).range2(:,Nin) = handles.testpts(ngrp).range2(:,Nin+1);
    handles.testpts(ngrp).range2(:,Nin+1) = aux;
    
    aux = handles.testpts(ngrp).tol1(:,Nin);
    handles.testpts(ngrp).tol1(:,Nin) = handles.testpts(ngrp).tol1(:,Nin+1);
    handles.testpts(ngrp).tol1(:,Nin+1) = aux;
    
    aux = handles.testpts(ngrp).tol2(:,Nin);
    handles.testpts(ngrp).tol2(:,Nin) = handles.testpts(ngrp).tol2(:,Nin+1);
    handles.testpts(ngrp).tol2(:,Nin+1) = aux;
    
    handles.chg = 1;
    guidata(hObject, handles);
    
    set(handles.paramsel,'String',PARAM(handles.index{ngrp}),'Value',Nin+1);
    
else
    beep;
end

% -------------------------------------------------------------------
function mean_chk_Callback(hObject, eventdata, handles)
% Incluir media dos parametros selecionados
updatedatalist(hObject, eventdata, handles, 1);

% -------------------------------------------------------------------
function std_chk_Callback(hObject, eventdata, handles)
% Incluir desvio padrao dos parametros selecionados
updatedatalist(hObject, eventdata, handles, 2);

% -------------------------------------------------------------------
function min_chk_Callback(hObject, eventdata, handles)
% Incluir valor minimo dos parametros selecionados
updatedatalist(hObject, eventdata, handles, 3);

% -------------------------------------------------------------------
function max_chk_Callback(hObject, eventdata, handles)
% Incluir valor maximo dos parametros selecionados
updatedatalist(hObject, eventdata, handles, 4);

% -------------------------------------------------------------------
function range_chk_Callback(hObject, eventdata, handles)
% Incluir amplitude (max-min) dos parametros selecionados
updatedatalist(hObject, eventdata, handles, 5);

% -------------------------------------------------------------------
function ini_chk_Callback(hObject, eventdata, handles)
% Incluir valor inicial dos parametros selecionados
updatedatalist(hObject, eventdata, handles, 6);

% -------------------------------------------------------------------
function end_chk_Callback(hObject, eventdata, handles)
% Incluir valor final dos parametros selecionados
updatedatalist(hObject, eventdata, handles, 7);

% -------------------------------------------------------------------
function var_chk_Callback(hObject, eventdata, handles)
% Incluir variacao (fin-ini) dos parametros selecionados
updatedatalist(hObject, eventdata, handles, 8);

% -------------------------------------------------------------------
function valn_chk_Callback(hObject, eventdata, handles)
% Incluir validaçao dos parametros selecionados
updatedatalist(hObject, eventdata, handles, 9);

% -------------------------------------------------------------------
function tau_chk_Callback(hObject, eventdata, handles)
% Incluir constante de tempo dos parametros selecionados
updatedatalist(hObject, eventdata, handles, 10);

% -------------------------------------------------------------------
function zeta_chk_Callback(hObject, eventdata, handles)
% Incluir amortecimento dos parametros selecionados
updatedatalist(hObject, eventdata, handles, 11);

% -------------------------------------------------------------------
function wn_chk_Callback(hObject, eventdata, handles)
% Incluir frequencia natural dos parametros selecionados
updatedatalist(hObject, eventdata, handles, 12);

% -------------------------------------------------------------------
function der_chk_Callback(hObject, eventdata, handles)
% Incluir derivada media dos parametros selecionados
updatedatalist(hObject, eventdata, handles, 13);

% -------------------------------------------------------------------
function updatedatalist(hObject, eventdata, handles, nd)
% Atualiza a exibiçao da lista de dados desejados

ngrp = get(handles.grplist,'Value');
npar = get(handles.paramsel,'Value');

if ~isempty(handles.index{ngrp}) && ~isempty(npar)    
    handles.testpts(ngrp).data(npar,nd) = get(handles.data_chk(nd),'Value');
    set(handles.data_chk(nd),'ForegroundColor','k');
    handles.chg = 1;
    guidata(hObject, handles);
else
    set(handles.data_chk(nd),'Value',0);
end

% -------------------------------------------------------------------
function fitord_sel_Callback(hObject, eventdata, handles)
% Seleciona o tipo de ajuste desejado

ngrp = get(handles.grplist,'Value');
npar = get(handles.paramsel,'Value');

if ~isempty(handles.index{ngrp}) && ~isempty(npar)    
    handles.testpts(ngrp).fit(npar,1) = get(handles.fitord_sel,'Value')-1;

    n_nofit = handles.testpts(ngrp).fit(:,1) == 0;
    handles.testpts(ngrp).fit(n_nofit,:) = 0;
    n_dyn = handles.testpts(ngrp).fit(:,1 )>= 7;
    handles.testpts(ngrp).fit(n_dyn,2) = 1;

    handles.chg = 1;
    guidata(hObject, handles);
end

paramsel_Callback(hObject, eventdata, handles);

% -------------------------------------------------------------------
function sett0_chk_Callback(hObject, eventdata, handles)
% Aplicar correçao de origem nos ajustes
updatefitlist(hObject, eventdata, handles, 1);

% -------------------------------------------------------------------
function dof_chk_Callback(hObject, eventdata, handles)
% Incluir graus de liberdade dos ajustes
updatefitlist(hObject, eventdata, handles, 2);

% -------------------------------------------------------------------
function normres_chk_Callback(hObject, eventdata, handles)
% Incluir norma dos residuos dos ajustes
updatefitlist(hObject, eventdata, handles, 3);

% -------------------------------------------------------------------
function SSE_chk_Callback(hObject, eventdata, handles)
% Incluir SSE dos ajustes
updatefitlist(hObject, eventdata, handles, 4);

% -------------------------------------------------------------------
function RMSE_chk_Callback(hObject, eventdata, handles)
% Incluir RMSE dos ajustes
updatefitlist(hObject, eventdata, handles, 5);

% -------------------------------------------------------------------
function STDE_chk_Callback(hObject, eventdata, handles)
% Incluir STDE dos ajustes
updatefitlist(hObject, eventdata, handles, 6);

% -------------------------------------------------------------------
function adjR2_chk_Callback(hObject, eventdata, handles)
% Incluir adjR2 dos ajustes
updatefitlist(hObject, eventdata, handles, 7);

% -------------------------------------------------------------------
function updatefitlist(hObject, eventdata, handles, nf)
% Atualiza a exibiçao da lista de dados de ajustes

ngrp = get(handles.grplist,'Value');
npar = get(handles.paramsel,'Value');

if ~isempty(handles.index{ngrp}) && ~isempty(npar)
    handles.testpts(ngrp).fit(npar,nf+1) = get(handles.fit_chk(nf),'Value');

    n_nofit = handles.testpts(ngrp).fit(:,1) == 0;
    handles.testpts(ngrp).fit(n_nofit,:) = 0;
    n_dyn = handles.testpts(ngrp).fit(:,1 )>= 7;
    handles.testpts(ngrp).fit(n_dyn,2) = 1;
        
    handles.chg = 1;
    guidata(hObject, handles);
end

paramsel_Callback(hObject, eventdata, handles);

% -------------------------------------------------------------------
function aim_Callback(hObject, eventdata, handles)
% Insere valor desejado para o parametro selecionado do ponto selecionado

ngrp = get(handles.grplist,'Value');
npt  = get(handles.ptslist,'Value');
npar = get(handles.paramsel,'Value');

val = real(str2num(get(handles.aim,'String')));
if isempty(val)
    val = NaN;
end
val = val(1);

if ~isempty(handles.index{ngrp}) && ~isempty(npar)
    handles.testpts(ngrp).aim(npt,npar) = val;
    handles.chg = 1;
    guidata(hObject, handles);
else
    val = NaN;
end
if isnan(val)
    str = '';
else
    str = num2str(val,8);
end
set(handles.aim,'String',str);

% -------------------------------------------------------------------
function range1_Callback(hObject, eventdata, handles)
% Insere variacao inferior da faixa de medidas para o parametro selecionado do ponto selecionado

ngrp = get(handles.grplist,'Value');
npt  = get(handles.ptslist,'Value');
npar = get(handles.paramsel,'Value');

val = real(str2num(get(handles.range1,'String')));
if isempty(val)
    val = NaN;
end
val = -abs(val(1));

if ~isempty(handles.index{ngrp}) && ~isempty(npar)
    handles.testpts(ngrp).range1(npt,npar) = val;
    handles.chg = 1;
    guidata(hObject, handles);
else
    val = NaN;
end
if isnan(val)
    str = '';
else
    str = num2str(val,8);
end
set(handles.range1,'String',str);

% -------------------------------------------------------------------
function range2_Callback(hObject, eventdata, handles)
% Insere variacao superior da faixa de medidas para o parametro selecionado do ponto selecionado

ngrp = get(handles.grplist,'Value');
npt  = get(handles.ptslist,'Value');
npar = get(handles.paramsel,'Value');

val = real(str2num(get(handles.range2,'String')));
if isempty(val)
    val = NaN;
end
val = abs(val(1));

if ~isempty(handles.index{ngrp}) && ~isempty(npar)
    handles.testpts(ngrp).range2(npt,npar) = val;
    handles.chg = 1;
    guidata(hObject, handles);
else
    val = NaN;
end
if isnan(val)
    str = '';
else
    str = num2str(val,8);
end
set(handles.range2,'String',str);

% -------------------------------------------------------------------
function tol1_Callback(hObject, eventdata, handles)
% Insere variacao inferior da tolerancia para o parametro selecionado do ponto selecionado

ngrp = get(handles.grplist,'Value');
npt  = get(handles.ptslist,'Value');
npar = get(handles.paramsel,'Value');

val = real(str2num(get(handles.tol1,'String')));
if isempty(val)
    val = NaN;
end
val = -abs(val(1));

if ~isempty(handles.index{ngrp}) && ~isempty(npar)
    handles.testpts(ngrp).tol1(npt,npar) = val;
    handles.chg = 1;
    guidata(hObject, handles);
else
    val = NaN;
end
if isnan(val)
    str = '';
else
    str = num2str(val,8);
end
set(handles.tol1,'String',str);

% -------------------------------------------------------------------
function tol2_Callback(hObject, eventdata, handles)
% Insere variacao superior da tolerancia para o parametro selecionado do ponto selecionado

ngrp = get(handles.grplist,'Value');
npt  = get(handles.ptslist,'Value');
npar = get(handles.paramsel,'Value');

val = real(str2num(get(handles.tol2,'String')));
if isempty(val)
    val = NaN;
end
val = abs(val(1));

if ~isempty(handles.index{ngrp}) && ~isempty(npar)    
    handles.testpts(ngrp).tol2(npt,npar) = val;
    handles.chg = 1;
    guidata(hObject, handles);
else
    val = NaN;
end
if isnan(val)
    str = '';
else
    str = num2str(val,8);
end
set(handles.tol2,'String',str);

% -------------------------------------------------------------------
function help_btn_Callback(hObject, eventdata, handles)
% Botao Ajuda

helpme('Ferramentas\editorpontosdeens');

% -------------------------------------------------------------------
function ok_btn_Callback(hObject, eventdata, handles)
% Botao OK

if isequalwithequalnans(handles.testpts,handles.initestpts) && isequal(handles.reftime,handles.inireftime)
    button = questdlg('Deseja sair do editor de pontos?','Confirmação','Sim','Não','Não');
else
    button = questdlg('Deseja confirmar alterações?','Confirmação','Sim','Não','Não');
end

if strcmp(button,'Sim')
    
    if handles.chg && ~strcmp(handles.fname,'*.mat')
        button = savedlg({'A lista de pontos de ensaio foi alterada.',...
                ['Deseja salvar alterações em ' handles.fname '?']},'Confirmação','Sim','Não','Sim');
        if strcmp(button,'Sim')
            testpts = handles.testpts;
            reftime = handles.reftime;
            save([handles.fpath handles.fname],'testpts','reftime',saveopt);
        end
    end    
    
    handles.ok = 1;
    guidata(hObject, handles);
    uiresume;
    
end

% -------------------------------------------------------------------
function cancel_btn_Callback(hObject, eventdata, handles)
% Botao Cancela

if handles.chg && ~strcmp(handles.fname,'*.mat')
    button = questdlg({'A lista de pontos de ensaio foi alterada.',...
            ['Deseja sair sem salvar alterações em ' handles.fname '?']},'Confirmação','Sim','Não','Não');
    if strcmp(button,'Sim')
        uiresume;
    end
else
    if isequalwithequalnans(handles.testpts,handles.initestpts) && isequal(handles.reftime,handles.inireftime)
        button = questdlg('Deseja sair do editor de pontos?','Confirmação','Sim','Não','Não');
    else
        button = questdlg('Deseja descartar alterações?','Confirmação','Sim','Não','Não');
    end
    if strcmp(button,'Sim')
        uiresume;
    end
end

%--------------------------------------------------------------------------
function window_KeyPressFcn(hObject, eventdata, handles)
% Acionamento de tecla do teclado

cc = get(handles.window,'CurrentCharacter');

if isempty(cc)
    return
end

switch abs(cc)
    
    case abs('+')
        newpt_btn_Callback(hObject, eventdata, handles);
        
    case {abs('-'),127} % Del
        if strcmp(get(handles.removept_btn,'Enable'),'on')
            removept_btn_Callback(hObject, eventdata, handles);
        end
        
    case {abs('n'),abs('N')}
        new_btn_Callback(hObject, eventdata, handles);
        
    case {abs('a'),abs('A')}
        open_btn_Callback(hObject, eventdata, handles);
        
    case {abs('s'),abs('S')}
        save_btn_Callback(hObject, eventdata, handles);
        
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
function str = nan2empty(str)
% Transforma um string 'NaN' ou valor NaN em um string vazio

if isnan(str) || strcmpi(str,'nan')
    str = '';
end

