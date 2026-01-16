function varargout = RDAT_DataProcess(varargin)
% RDAT_DATAPROCESS M-file for RDAT_DataProcess.fig
% Last Modified by GUIDE v2.5 29-Mar-2013 19:17:17

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RDAT_DataProcess_OpeningFcn, ...
                   'gui_OutputFcn',  @RDAT_DataProcess_OutputFcn, ...
                   'gui_LayoutFcn',  @RDAT_DataProcess_LayoutFcn, ...
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
function h = RDAT_DataProcess_LayoutFcn(varargin)
% Função de layout inicial

h = openfig('RDAT_DataProcess.fig','reuse','invisible');

% -------------------------------------------------------------------
function RDAT_DataProcess_OpeningFcn(hObject, eventdata, handles, varargin)
% Função de inicialização

bgc = getbuttoncolor(handles.window);
set(handles.help_btn,'CData',geticon('DatButtons.mat','help',bgc));

bgc = get(handles.window,'Color');
axes(handles.poserrtypes);
image(flipud3(getbutton('poserrtypes.bmp',bgc)),'ButtonDownFcn','RDAT_DataProcess(''poserrfcn'',gcbo,[],guidata(gcbo))');
set(handles.poserrtypes,'Xcolor',bgc,'Ycolor',bgc,'Zcolor',bgc)
axes(handles.velerrtypes);
image(flipud3(getbutton('velerrtypes.bmp',bgc)),'ButtonDownFcn','RDAT_DataProcess(''velerrfcn'',gcbo,[],guidata(gcbo))');
set(handles.velerrtypes,'Xcolor',bgc,'Ycolor',bgc,'Zcolor',bgc)

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

if ~exist('DatAcftDB.mat','file')
    set(handles.window,'Visible','off');
    beep; uiwait(errordlg('Base de dados não encontrada.','Erro','modal'));
    handles.ok = 0;
    guidata(hObject, handles);
    uiresume
    return
end

load(which('DatAcftDB.mat'),'acftdb');

% Conversão de base de dados ---------
acftdb = backcompat(acftdb,'acftdb');
%-------------------------------------

handles.acftdb = acftdb;
handles.ok = 0;
handles.maxparamlength = 48;
setappdata(handles.window,'changes',{});

for n = 1:size(handles.acftdb,2);
    names{n} = [handles.acftdb(n).type ' ' handles.acftdb(n).tail];
end    
set(handles.acft_sel,'String',names,'Value',1);

handles.param_lists = [handles.Ncorr_Nx_sel handles.Ncorr_Ny_sel handles.Ncorr_Nz_sel handles.giro_P_sel handles.giro_Q_sel,...
        handles.giro_R_sel handles.euler_tet_sel handles.euler_phi_sel handles.anemo_pb_sel handles.anemo_qb_sel handles.Delta_entry1 handles.Delta_entry2,...
        handles.Delta_entry3 handles.Wcalc_fuel_sel handles.K_Ti_sel handles.K_M_sel handles.CL_Alfa_sel handles.polar_CL_sel,...
        handles.uvw_Va_sel handles.uvw_Alfa_sel handles.Va_M_sel handles.Va_Ta_sel,...
        handles.FPM_VN_sel handles.FPM_VE_sel handles.FPM_VD_sel handles.FPM_psi_sel handles.FPM_tet_sel handles.FPM_phi_sel];
handles.ignparam_lists = [handles.euler_psi_sel handles.anemo_Zpb_sel handles.anemo_Vb_sel handles.anemo_Mb_sel handles.AB_Alfag_sel handles.AB_Betag_sel,...
     handles.uvw_Beta_sel handles.Cmd_Ddm_sel handles.Cmd_Ddl_sel handles.Cmd_Ddn_sel handles.Cmd_Pi1_sel handles.Cmd_Pi2_sel];
handles.Ncorr_group = [handles.Ncorr_Nx_sel handles.Ncorr_Ny_sel handles.Ncorr_Nz_sel handles.Ncorr_opt handles.Nxcorr_name,...
        handles.Nycorr_name handles.Nzcorr_name handles.Ncorr_go];
handles.giro_group  = [handles.giro_P_sel handles.giro_Q_sel handles.giro_R_sel handles.giro_opt handles.Pcorr_name,...
        handles.Qcorr_name handles.Rcorr_name handles.giro_go];
handles.euler_group = [handles.euler_psi_sel handles.euler_tet_sel handles.euler_phi_sel handles.euler_opt handles.psicorr_name,...
        handles.tetcorr_name handles.phicorr_name handles.euler_go];
handles.Delta_group = [handles.Delta_entry1 handles.Delta_entry2 handles.Delta_entry3 handles.Dpb_name handles.Dqb_name handles.Delta_go];
handles.anemo_group = [handles.anemo_pb_sel handles.anemo_qb_sel handles.anemo_Zpb_sel handles.anemo_Vb_sel handles.anemo_Mb_sel,...
        handles.anemo_opt handles.pa_name handles.qc_name handles.Zp_name handles.Vc_name handles.M_name handles.anemo_go];
handles.Wcalc_group = [handles.Wcalc_fuel_sel handles.Wref handles.Wcalc_tot_sel handles.Wcalc_detot_sel handles.Wcalc_name handles.Wcalc_go];
handles.K_group     = [handles.K_Ti_sel handles.K_M_sel handles.Ta_name handles.K_go];
handles.AB_group    = [handles.AB_Alfag_sel handles.AB_Betag_sel handles.AB_opt handles.Alfa_name handles.Beta_name handles.AB_go];
handles.Alfa_group  = [handles.AB_Alfag_sel handles.Alfa_name];
handles.Beta_group  = [handles.AB_Betag_sel handles.Beta_name];
handles.CL_group    = [handles.CL_Alfa_sel handles.CL_name handles.CL_go];
handles.polar_group = [handles.polar_CL_sel handles.CD_name handles.polar_go];
handles.Va_group    = [handles.Va_M_sel handles.Va_Ta_sel handles.Va_name handles.Va_go];
handles.uvw_group   = [handles.uvw_Va_sel handles.uvw_Alfa_sel handles.uvw_Beta_sel handles.u_name handles.v_name handles.w_name handles.uvw_go];
handles.Cmd_group   = [handles.Cmd_Ddm_sel handles.Cmd_Ddl_sel handles.Cmd_Ddn_sel handles.Cmd_Pi1_sel handles.Cmd_Pi2_sel handles.Ddm_name,...
        handles.Ddl_name handles.Ddn_name handles.Pi1_name handles.Pi2_name handles.Cmd_opt handles.Cmd_go];
handles.Ddm_group   = [handles.Cmd_Ddm_sel handles.Ddm_name];
handles.Ddl_group   = [handles.Cmd_Ddl_sel handles.Ddl_name];
handles.Ddn_group   = [handles.Cmd_Ddn_sel handles.Ddn_name];
handles.Pi1_group   = [handles.Cmd_Pi1_sel handles.Pi1_name];
handles.Pi2_group   = [handles.Cmd_Pi2_sel handles.Pi2_name];
handles.FPM_group   = [handles.FPM_VN_sel handles.FPM_VE_sel handles.FPM_VD_sel handles.FPM_psi_sel handles.FPM_tet_sel handles.FPM_phi_sel,...
        handles.FPMaz_name handles.FPMdp_name handles.FPM_go];

handles.ptypes = [handles.ptype1 handles.ptype2 handles.ptype3];
handles.vtypes = [handles.vtype1 handles.vtype2 handles.vtype3];

if length(varargin) == 1
    PARAM = varargin{1};
else
    PARAM = ' ';
end

set(handles.param_lists,'String',cellstr(PARAM));
set(handles.ignparam_lists,'String',cellstr(char('Ignorar',char(PARAM))));

acft_sel_Callback(hObject, eventdata, handles);

Nxcol   = findpar(PARAM,'Nx');
Nycol   = findpar(PARAM,'Ny');
Nzcol   = findpar(PARAM,'Nz');
Pcol    = findpar(PARAM,'P (');
Qcol    = findpar(PARAM,'Q (');
Rcol    = findpar(PARAM,'R (');
psicol  = findpar(PARAM,'psi');
tetcol  = findpar(PARAM,{'thet','tet','pitch ('});
phicol  = findpar(PARAM,{'phi','fi ','roll ('});
pbcol   = findpar(PARAM,'pb');
qbcol   = findpar(PARAM,'qb');
fuelcol = findpar(PARAM,{'tot','detot'});
Vacol   = findpar(PARAM,{'vt','tas'});
Alfacol = findpar(PARAM,{'alfa','alpha','aoa'});
Betacol = findpar(PARAM,{'beta','aos'});
Ddmcol  = findpar(PARAM,'ddm');
Ddlcol  = findpar(PARAM,'ddl');
Ddncol  = findpar(PARAM,'ddn');

if isempty(Nxcol),   Nxcol   = 1; end, set(handles.Ncorr_Nx_sel,  'Value', Nxcol);
if isempty(Nycol),   Nycol   = 1; end, set(handles.Ncorr_Ny_sel,  'Value', Nycol);
if isempty(Nzcol),   Nzcol   = 1; end, set(handles.Ncorr_Nz_sel,  'Value', Nzcol);
if isempty(Pcol),    Pcol    = 1; end, set(handles.giro_P_sel,    'Value', Pcol);
if isempty(Qcol),    Qcol    = 1; end, set(handles.giro_Q_sel,    'Value', Qcol);
if isempty(Rcol),    Rcol    = 1; end, set(handles.giro_R_sel,    'Value', Rcol);
if isempty(psicol),  psicol  = 1; end, set(handles.euler_psi_sel, 'Value', psicol);
if isempty(tetcol),  tetcol  = 1; end, set(handles.euler_tet_sel, 'Value', tetcol);
if isempty(phicol),  phicol  = 1; end, set(handles.euler_phi_sel, 'Value', phicol);
if isempty(pbcol),   pbcol   = 1; end, set(handles.anemo_pb_sel,  'Value', pbcol);
if isempty(qbcol),   qbcol   = 1; end, set(handles.anemo_qb_sel,  'Value', qbcol);
if isempty(fuelcol), fuelcol = 1; end, set(handles.Wcalc_fuel_sel,'Value', fuelcol);
if isempty(Vacol),   Vacol   = 1; end, set(handles.uvw_Va_sel,    'Value', Vacol);

if isempty(psicol),  psicol  = 0; end, set(handles.euler_psi_sel, 'Value', psicol+1);
if isempty(Alfacol), Alfacol = 0; end, set(handles.AB_Alfag_sel,  'Value', Alfacol+1);
if isempty(Betacol), Betacol = 0; end, set(handles.AB_Betag_sel,  'Value', Betacol+1);
if isempty(Ddmcol),  Ddmcol  = 0; end, set(handles.Cmd_Ddm_sel,   'Value', Ddmcol+1);
if isempty(Ddlcol),  Ddlcol  = 0; end, set(handles.Cmd_Ddl_sel,   'Value', Ddlcol+1);
if isempty(Ddncol),  Ddncol  = 0; end, set(handles.Cmd_Ddn_sel,   'Value', Ddncol+1);

if isempty(psicol),  tetcol  = 1; end, set(handles.FPM_psi_sel,   'Value', psicol);
if isempty(tetcol),  tetcol  = 1; end, set(handles.FPM_tet_sel,   'Value', tetcol);
if isempty(phicol),  phicol  = 1; end, set(handles.FPM_phi_sel,   'Value', phicol);

guidata(hObject, handles);
uiwait(handles.window);

% -------------------------------------------------------------------
function varargout = RDAT_DataProcess_OutputFcn(hObject, eventdata, handles)
global DADOS
% Função de saída

changes = getappdata(handles.window,'changes');

if handles.ok
    PARAM = get(handles.Ncorr_Nx_sel,'String');
    varargout{1} = PARAM;
else
    if ~isempty(changes) % Desfazer alterações
        for n = size(changes,1):-1:1
            if isempty(changes{n,2})
                DADOS(:,changes{n,1}) = [];
            else
                DADOS(:,changes{n,1}) = changes{n,2};
            end
        end
    end
    varargout{1} = [];
end
delete(handles.window);

% -------------------------------------------------------------------
function acft_sel_Callback(hObject, eventdata, handles)
% Seleção da aeronave

[na, nc] = getnanc(handles);
set(handles.date_sel,'String',datetime2str([handles.acftdb(na).date]),'Value',size(handles.acftdb(na).date,1));

% -------------------------------------------------------------------
function date_sel_Callback(hObject, eventdata, handles)
% Seleção da data da calibração

% -------------------------------------------------------------------
function updatetypes(hObject, eventdata, handles)
% Atualiza os tipos de curva de calibração

[np, nv] = getnpnv(handles);

switch np
    case 1
        set(handles.Delta_txt1,'String','W','TooltipString','');
        set(handles.Delta_txt2,'String','Nz','TooltipString','g');
        set(handles.Delta_txt3,'String','qb','TooltipString','mb');
        set([handles.Delta_entry2 handles.Delta_entry3 handles.Delta_txt2 handles.Delta_txt3],'Visible','on');
    case 2
        set(handles.Delta_txt1,'String','Mb','TooltipString','');
        set(handles.Delta_txt2,'String','qb','TooltipString','mb');
        set([handles.Delta_entry2 handles.Delta_txt2],'Visible','on');
        set([handles.Delta_entry3 handles.Delta_txt3],'Visible','off');
    case 3
        set(handles.Delta_txt1,'String','qb','TooltipString','mb');
        set([handles.Delta_entry2 handles.Delta_entry3 handles.Delta_txt2 handles.Delta_txt3],'Visible','off');
end

% -------------------------------------------------------------------
function Ncorr_go_Callback(hObject, eventdata, handles)
global DADOS
% Realizar calibração de fatores de carga

[na, nc] = getnanc(handles);

button = questdlg({'Deseja corrigir os fatores de carga',...
        ['da aeronave ' handles.acftdb(na).type ' ' handles.acftdb(na).tail ],...
        ['usando a calibração de ' datetime2str(handles.acftdb(na).date(nc,:)) '?']},'Processar','Sim','Não','Não');

if strcmp(button,'Sim')
    
    set([handles.acft_sel handles.date_sel],'Enable','off');
    PARAM = get(handles.Ncorr_Nx_sel,'String');
    L     = ortocorr(handles.acftdb(na).orto(nc,1:3));
    kL    = handles.acftdb(na).orto(nc,4);
    
    if any(isnan(L(:)))
        beep; uiwait(errordlg({'Não é possível processar.',...
                'Os ângulos de correção não estão definidos adequadamente.'},'Erro','modal'));
        set([handles.Ncorr_group handles.giro_group handles.euler_group],'Enable','off');
        
    elseif isnan(kL)
        beep; uiwait(errordlg({'Não é possível processar.',...
                'O fator de escala não está definido adequadamente.'},'Erro','modal'));
        set(handles.Ncorr_group,'Enable','off');
        
    else
        Nxcol = get(handles.Ncorr_Nx_sel,'Value');
        Nycol = get(handles.Ncorr_Ny_sel,'Value');
        Nzcol = get(handles.Ncorr_Nz_sel,'Value');
        
        Nxname = TrimParamName(get(handles.Nxcorr_name,'String'),handles.maxparamlength);
        Nyname = TrimParamName(get(handles.Nycorr_name,'String'),handles.maxparamlength);
        Nzname = TrimParamName(get(handles.Nzcorr_name,'String'),handles.maxparamlength);
        
        if isempty(Nxname) || isempty(Nyname) || isempty(Nzname)
            beep; uiwait(errordlg('Nome do parâmetro não pode ser vazio.','Erro','modal'));
            return
        end
        
        Nxyz_corr = ( kL * L * DADOS(:,[Nxcol Nycol Nzcol])' )';
        
        switch get(handles.Ncorr_opt,'Value')
            case 0 % Novos parâmetros
                PARAM = InsertParam(PARAM,Nxname);
                PARAM = InsertParam(PARAM,Nyname);
                PARAM = InsertParam(PARAM,Nzname);
                DADOS = [DADOS(:,1:end-1)  Nxyz_corr  DADOS(:,end)];
                
                Npar = length(PARAM);
                addchange(handles,Npar-3,[]);
                addchange(handles,Npar-2,[]);
                addchange(handles,Npar-1,[]);
                
            case 1 % Substituir
                button = questdlg({'Deseja substituir os parâmetros?','Os dados originais serão perdidos!'},'Confirmação','Sim','Não','Não');
                if strcmp(button,'Sim')
                    
                    if any([Nxcol Nycol Nzcol] == length(PARAM))
                        beep; uiwait(errordlg('Não é possível alterar o parâmetro ''No. OBS.''','Erro','modal'));
                        return
                    end
                    
                    addchange(handles,Nxcol,DADOS(:,Nxcol));
                    addchange(handles,Nycol,DADOS(:,Nycol));
                    addchange(handles,Nzcol,DADOS(:,Nzcol));
                    
                    DADOS(:,Nxcol) = Nxyz_corr(:,1);
                    DADOS(:,Nycol) = Nxyz_corr(:,2);
                    DADOS(:,Nzcol) = Nxyz_corr(:,3);
                    
                    button = questdlg('Deseja alterar os nomes originais?','Confirmação','Sim','Não','Não');
                    if strcmp(button,'Sim')
                        PARAM{Nxcol} = strrep(PARAM{Nxcol}, denumber(PARAM{Nxcol}), Nxname);
                        PARAM{Nycol} = strrep(PARAM{Nycol}, denumber(PARAM{Nycol}), Nyname);
                        PARAM{Nzcol} = strrep(PARAM{Nzcol}, denumber(PARAM{Nzcol}), Nzname);
                    end
                    
                else
                    return
                end
        end
        
        uiwait(okdlg('Processamento realizado com sucesso.','Aviso','modal'));
        set(handles.Ncorr_group,'Enable','off');
        set(handles.Ncorr_go,'String','Processado','BackgroundColor','g','Enable','inactive')
        set(handles.param_lists,'String',PARAM);
        set(handles.ignparam_lists,'String',char('Ignorar',char(PARAM)));
    end
end

% -------------------------------------------------------------------
function giro_go_Callback(hObject, eventdata, handles)
global DADOS
% Realizar calibração de P Q R

[na, nc] = getnanc(handles);

button = questdlg({'Deseja corrigir as velocidades angulares',...
        ['da aeronave ' handles.acftdb(na).type ' ' handles.acftdb(na).tail ],...
        ['usando a calibração de ' datetime2str(handles.acftdb(na).date(nc,:)) '?']},'Processar','Sim','Não','Não');

if strcmp(button,'Sim')
    
    set([handles.acft_sel handles.date_sel],'Enable','off');
    PARAM = cellstr(get(handles.giro_P_sel,'String'));
    L     = ortocorr(handles.acftdb(na).orto(nc,1:3));
    
    if any(isnan(L(:)))
        beep; uiwait(errordlg({'Não é possível processar.',...
                'Os ângulos de correção não estão definidos adequadamente.'},'Erro','modal'));
        set([handles.Ncorr_group handles.giro_group handles.euler_group],'Enable','off');
        
    else
        Pcol = get(handles.giro_P_sel,'Value');
        Qcol = get(handles.giro_Q_sel,'Value');
        Rcol = get(handles.giro_R_sel,'Value');
        
        Pname = TrimParamName(get(handles.Pcorr_name,'String'),handles.maxparamlength);
        Qname = TrimParamName(get(handles.Qcorr_name,'String'),handles.maxparamlength);
        Rname = TrimParamName(get(handles.Rcorr_name,'String'),handles.maxparamlength);
        
        if isempty(Pname) || isempty(Qname) || isempty(Rname)
            beep; uiwait(errordlg('Nome do parâmetro não pode ser vazio.','Erro','modal'));
            return
        end
        
        PQR_corr = ( L * DADOS(:,[Pcol Qcol Rcol])' )';
        
        switch get(handles.giro_opt,'Value')
            case 0 % Novos parâmetros
                PARAM = InsertParam(PARAM,Pname);
                PARAM = InsertParam(PARAM,Qname);
                PARAM = InsertParam(PARAM,Rname);
                DADOS = [DADOS(:,1:end-1)  PQR_corr  DADOS(:,end)];
                
                Npar = length(PARAM);
                addchange(handles,Npar-3,[]);
                addchange(handles,Npar-2,[]);
                addchange(handles,Npar-1,[]);

            case 1 % Substituir
                button = questdlg({'Deseja substituir os parâmetros?','Os dados originais serão perdidos!'},'Confirmação','Sim','Não','Não');
                if strcmp(button,'Sim')
                    
                    if any([Pcol Qcol Rcol] == length(PARAM))
                        beep; uiwait(errordlg('Não é possível alterar o parâmetro ''No. OBS.''','Erro','modal'));
                        return
                    end
                    
                    addchange(handles,Pcol,DADOS(:,Pcol));
                    addchange(handles,Qcol,DADOS(:,Qcol));
                    addchange(handles,Rcol,DADOS(:,Rcol));

                    DADOS(:,Pcol) = PQR_corr(:,1);
                    DADOS(:,Qcol) = PQR_corr(:,2);
                    DADOS(:,Rcol) = PQR_corr(:,3);
                    
                    button = questdlg('Deseja alterar os nomes originais?','Confirmação','Sim','Não','Não');
                    if strcmp(button,'Sim')
                        PARAM{Pcol} = strrep(PARAM{Pcol}, denumber(PARAM{Pcol}), Pname);
                        PARAM{Qcol} = strrep(PARAM{Qcol}, denumber(PARAM{Qcol}), Qname);
                        PARAM{Rcol} = strrep(PARAM{Rcol}, denumber(PARAM{Rcol}), Rname);
                    end
                    
                else
                    return
                end
        end
        
        uiwait(okdlg('Processamento realizado com sucesso.','Aviso','modal'));
        set(handles.giro_group,'Enable','off');
        set(handles.giro_go,'String','Processado','BackgroundColor','g','Enable','inactive')
        set(handles.param_lists,'String',PARAM);
        set(handles.ignparam_lists,'String',char('Ignorar',char(PARAM)));
    end
end

% -------------------------------------------------------------------
function euler_go_Callback(hObject, eventdata, handles)
global DADOS
% Realizar correção das atitudes

[na, nc] = getnanc(handles);

button = questdlg({'Deseja corrigir as atitudes',...
        ['da aeronave ' handles.acftdb(na).type ' ' handles.acftdb(na).tail ],...
        ['usando a calibração de ' datetime2str(handles.acftdb(na).date(nc,:)) '?']},'Processar','Sim','Não','Não');

if strcmp(button,'Sim')
    
    set([handles.acft_sel handles.date_sel],'Enable','off');
    PARAM = cellstr(get(handles.euler_tet_sel,'String'));
    dpsi = handles.acftdb(na).orto(nc,1);
    dtet = handles.acftdb(na).orto(nc,2);
    dphi = handles.acftdb(na).orto(nc,3);
    
    if isnan(dpsi+dtet+dphi)
        beep; uiwait(errordlg({'Não é possível processar.',...
                'Os ângulos de correção não estão definidos adequadamente.'},'Erro','modal'));
        set([handles.Ncorr_group handles.giro_group handles.euler_group],'Enable','off');
        
    else
        psicol = get(handles.euler_psi_sel,'Value')-1;
        tetcol = get(handles.euler_tet_sel,'Value');
        phicol = get(handles.euler_phi_sel,'Value');
        
        if psicol
            psiname = TrimParamName(get(handles.psicorr_name,'String'),handles.maxparamlength);
        else
            psiname = '-';
        end
        tetname = TrimParamName(get(handles.tetcorr_name,'String'),handles.maxparamlength);
        phiname = TrimParamName(get(handles.phicorr_name,'String'),handles.maxparamlength);
        
        if isempty(psiname) || isempty(tetname) || isempty(phiname)
            beep; uiwait(errordlg('Nome do parâmetro não pode ser vazio.','Erro','modal'));
            return
        end
        
        tet = DADOS(:,tetcol);
        phi = DADOS(:,phicol);
        if psicol
            psi    = DADOS(:,psicol);
            psicor = psi - ( dtet*sin((phi+dphi)*pi/180) + dpsi*cos((phi+dphi)*pi/180) );
            psicor = mod(psicor, 360);
        else
            psicor = [];
        end
        tetcor = tet - ( dtet*cos((phi+dphi)*pi/180) -+ dpsi*sin((phi+dphi)*pi/180) );
        tetcor = mod(tetcor, 360);
        tetcor(tetcor>180) = tetcor(tetcor>180) - 360;
        phicor = phi - ( dpsi*sin((tet+dtet)*pi/180) + dphi);
        phicor = mod(phicor, 360);
        phicor(phicor>180) = phicor(phicor>180) - 360;
        
        switch get(handles.euler_opt,'Value')
            case 0 % Novos parâmetros
                if psicol
                    PARAM = InsertParam(PARAM,psiname);
                end
                PARAM = InsertParam(PARAM,tetname);
                PARAM = InsertParam(PARAM,phiname);
                DADOS = [DADOS(:,1:end-1) psicor tetcor phicor DADOS(:,end)];
                
                Npar = length(PARAM);
                if psicol
                    addchange(handles,Npar-3,[]);
                end
                addchange(handles,Npar-2,[]);
                addchange(handles,Npar-1,[]);

            case 1 % Substituir
                button = questdlg({'Deseja substituir os parâmetros?','Os dados originais serão perdidos!'},'Confirmação','Sim','Não','Não');
                if strcmp(button,'Sim')
                    
                    if any([psicol tetcol phicol] == length(PARAM))
                        beep; uiwait(errordlg('Não é possível alterar o parâmetro ''No. OBS.''','Erro','modal'));
                        return
                    end
                    
                    if psicol
                        addchange(handles,psicol,DADOS(:,psicol));
                    end
                    addchange(handles,tetcol,DADOS(:,tetcol));
                    addchange(handles,phicol,DADOS(:,phicol));

                    if psicol
                        DADOS(:,psicol) = psicor;
                    end
                    DADOS(:,tetcol) = tetcor;
                    DADOS(:,phicol) = phicor;
                    
                    button = questdlg('Deseja alterar os nomes originais?','Confirmação','Sim','Não','Não');
                    if strcmp(button,'Sim')
                        if psicol
                            PARAM{psicol} = strrep(PARAM{psicol}, denumber(PARAM{psicol}), psiname);
                        end
                        PARAM{tetcol} = strrep(PARAM{tetcol}, denumber(PARAM{tetcol}), tetname);
                        PARAM{phicol} = strrep(PARAM{phicol}, denumber(PARAM{phicol}), phiname);
                    end
                    
                else
                    return
                end
        end
        
        uiwait(okdlg('Processamento realizado com sucesso.','Aviso','modal'));
        set(handles.euler_group,'Enable','off');
        set(handles.euler_go,'String','Processado','BackgroundColor','g','Enable','inactive')
        set(handles.param_lists,'String',PARAM);
        set(handles.ignparam_lists,'String',char('Ignorar',char(PARAM)));
    end
end

% -------------------------------------------------------------------
function Delta_go_Callback(hObject, eventdata, handles)
global DADOS
% Criar erros anemométricos

[na, nc] = getnanc(handles);

button = questdlg({'Deseja obter os erros anemométricos',...
        ['da aeronave ' handles.acftdb(na).type ' ' handles.acftdb(na).tail ],...
        ['usando a calibração de ' datetime2str(handles.acftdb(na).date(nc,:)) '?']},'Processar','Sim','Não','Não');

if strcmp(button,'Sim')
    
    [np, nv] = getnpnv(handles);

    set([handles.acft_sel handles.date_sel],'Enable','off');
    PARAM   = cellstr(get(handles.Delta_entry1,'String'));
    pcoefs  = handles.acftdb(na).Dpb(nc,:,np);
    vcoefs  = handles.acftdb(na).Dqb(nc,:,nv);
    Ws      = handles.acftdb(na).Ws(nc);
    
    if any(isnan(pcoefs))
        beep; uiwait(errordlg({'Não é possível processar.',...
                'Os coeficientes da curva de erro de posição',...
                'não estão definidos adequadamente.'},'Erro','modal'));
        set([handles.Delta_group handles.anemo_group],'Enable','off');
        return
    elseif np == 1 && isnan(Ws)
        beep; uiwait(errordlg({'Não é possível processar.',...
                'O peso padrão da aeronave não está definido adequadamente.'},'Erro','modal'));
        set([handles.Delta_group handles.anemo_group],'Enable','off');
        return
    elseif nv ~= 1 && any(isnan(vcoefs))
                beep; uiwait(errordlg({'Não é possível processar.',...
                'Os coeficientes da curva de erro de velocidade',...
                'não estão definidos adequadamente.'},'Erro','modal'));
        set([handles.Delta_group handles.anemo_group],'Enable','off');
        return
    end
    
    switch np
        case 1 % Dpb/n' = f(sqrt(qb/n'))
            Wcol  = get(handles.Delta_entry1,'Value');
            Nzcol = get(handles.Delta_entry2,'Value');
            qbcol = get(handles.Delta_entry3,'Value');
            nl    = DADOS(:,Nzcol) .* DADOS(:,Wcol) / Ws;
            if any(nl == 0)
                uiwait(warndlg({'Encontrados pontos de n'' iguais a zero.',...
                        'Os pontos resultantes serão invalidados (NaN).'},'Aviso','modal')); drawnow;
                nl(nl == 0) = NaN;
            end
            Rqbnl = sqrt( DADOS(:,qbcol) ./ nl );
            Dpb   = nl .* polyval(pcoefs, Rqbnl);
            
        case 2 % Dpb/qb = f(Mb)
            Mbcol = get(handles.Delta_entry1,'Value');
            qbcol = get(handles.Delta_entry2,'Value');
            Dpb = DADOS(:,qbcol) .* polyval(pcoefs, DADOS(:,Mbcol));
            
        case 3 % Dpb = f(qb)
            qbcol = get(handles.Delta_entry1,'Value');
            Dpb = polyval(pcoefs, DADOS(:,qbcol));
    end
    
    switch nv
        case 1 % Dqb = -Dpb
            Dqb = -Dpb;
            
        case 2 % Dqb = f(qb)
            qbcol = get(handles.Delta_entry1,'Value');
            Dqb = polyval(vcoefs, DADOS(:,qbcol));
            
        case 3 % Dpp = f(qb)
            qbcol = get(handles.Delta_entry1,'Value');
            Dpp = polyval(vcoefs, DADOS(:,qbcol));
            Dqb = Dpp - Dpb;
            
    end
    
    set(handles.Dpb_name,'Userdata',Dpb);
    set(handles.Dqb_name,'Userdata',Dqb);
    
    button = questdlg({'Deseja adicionar os erros de posição e velocidade à matriz DADOS?',...
            '(caso negativo, serão armazenados temporariamente).'},'Confirmação','Sim','Não','Cancela','Sim');
    
    switch button
        
        case 'Sim'
            Dpbname = TrimParamName(get(handles.Dpb_name,'String'),handles.maxparamlength);
            Dqbname = TrimParamName(get(handles.Dqb_name,'String'),handles.maxparamlength);
            if isempty(Dpbname) || isempty(Dqbname)
                set(handles.Dpb_name,'Userdata',[]);  
                set(handles.Dqb_name,'Userdata',[]);  
                beep; uiwait(errordlg('Nome do parâmetro não pode ser vazio.','Erro','modal'));
                return
            end
            PARAM = InsertParam(PARAM,Dpbname);
            PARAM = InsertParam(PARAM,Dqbname);
            DADOS = [DADOS(:,1:end-1)  Dpb  Dqb  DADOS(:,end)];
            
            addchange(handles,length(PARAM)-2,[]);
            addchange(handles,length(PARAM)-1,[]);
            
        case 'Não'
            % Nada a fazer
            
        otherwise
            set(handles.Dpb_name,'Userdata',[]);
            set(handles.Dqb_name,'Userdata',[]);
            return
    end
    
    uiwait(okdlg('Processamento realizado com sucesso.','Aviso','modal'));
    set(handles.Delta_group,'Enable','off');
    set(handles.Delta_go,'String','Processado','BackgroundColor','g','Enable','inactive')
    set(handles.param_lists,'String',PARAM);
    set(handles.ignparam_lists,'String',char('Ignorar',char(PARAM)));
end

% -------------------------------------------------------------------
function anemo_opt_Callback(hObject, eventdata, handles)
% Opção de Novos/Substituir parâmetros anemométricos 

hlist = [handles.anemo_Zpb_txt handles.anemo_Vb_txt handles.anemo_Mb_txt,...
    handles.anemo_Zpb_sel handles.anemo_Vb_sel handles.anemo_Mb_sel];

switch get(gcbo,'Value')
    case 0 % Novos parâmetros
        set(hlist,'Visible','off');
    case 1 % Substituir
        set(hlist,'Visible','on');
end

% -------------------------------------------------------------------
function anemo_go_Callback(hObject, eventdata, handles)
global DADOS
% Realizar calibração anemométrica

[na, nc] = getnanc(handles);

button = questdlg({'Deseja corrigir os parâmetros anemométricos básicos',...
        ['da aeronave ' handles.acftdb(na).type ' ' handles.acftdb(na).tail ],...
        ['usando a calibração de ' datetime2str(handles.acftdb(na).date(nc,:)) '?']},'Processar','Sim','Não','Não');

if strcmp(button,'Sim')
    
    PARAM = cellstr(get(handles.anemo_pb_sel,'String'));
    Dpb = get(handles.Dpb_name,'Userdata');
    Dqb = get(handles.Dqb_name,'Userdata');
    
    if isempty(Dpb) || isempty(Dqb)
        beep; uiwait(errordlg({'Não é possível processar.','Defina os erro de posição e velocidade primeiro.'},'Erro','modal'));
        return
    end
    
    pbcol  = get(handles.anemo_pb_sel,'Value');
    qbcol  = get(handles.anemo_qb_sel,'Value');
    Zpbcol = get(handles.anemo_Zpb_sel,'Value') - 1;
    Vbcol  = get(handles.anemo_Vb_sel,'Value')  - 1;
    Mbcol  = get(handles.anemo_Mb_sel,'Value')  - 1;
    
    paname = TrimParamName(get(handles.pa_name,'String'),handles.maxparamlength);
    qcname = TrimParamName(get(handles.qc_name,'String'),handles.maxparamlength);
    Zpname = TrimParamName(get(handles.Zp_name,'String'),handles.maxparamlength);
    Vcname = TrimParamName(get(handles.Vc_name,'String'),handles.maxparamlength);
    Mname  = TrimParamName(get(handles.M_name, 'String'),handles.maxparamlength);
    
    if isempty(paname) || isempty(qcname) || ...
            Zpbcol && isempty(Zpname) || Vbcol && isempty(Vcname) || Mbcol && isempty(Mname)
        beep; uiwait(errordlg('Nome do parâmetro não pode ser vazio.','Erro','modal'));
        return
    end
    
    pb = DADOS(:,pbcol);
    qb = DADOS(:,qbcol);
    
    pa = pb - Dpb;            
    qc = qb - Dqb;
    
    try
        Zp = pa2zp(pa);
        Vc = qc2vc(qc);
        M  = qcpa2m(qc,pa);
    catch
        beep; uiwait(errordlg(lasterr,'Erro','modal'));
        return
    end
    
    switch get(handles.anemo_opt,'Value')
        case 0 % Novos parâmetros
            PARAM = InsertParam(PARAM,paname);
            PARAM = InsertParam(PARAM,qcname);
            PARAM = InsertParam(PARAM,Zpname);
            PARAM = InsertParam(PARAM,Vcname);
            PARAM = InsertParam(PARAM,Mname);
            DADOS = [DADOS(:,1:end-1)  pa  qc  Zp  Vc  M  DADOS(:,end)];
            
            Npar = length(PARAM);
            addchange(handles,Npar-5,[]);
            addchange(handles,Npar-4,[]);
            addchange(handles,Npar-3,[]);
            addchange(handles,Npar-2,[]);
            addchange(handles,Npar-1,[]);
            
        case 1 % Substituir
            button = questdlg({'Deseja substituir os parâmetros?','Os dados originais serão perdidos!'},'Confirmação','Sim','Não','Não');
            if strcmp(button,'Sim')
                
                if any([pbcol qbcol Zpbcol Vbcol Mbcol] == length(PARAM))
                    beep; uiwait(errordlg('Não é possível alterar o parâmetro ''No. OBS.''','Erro','modal'));
                    return
                end
                
                addchange(handles,pbcol,DADOS(:,pbcol));
                DADOS(:,pbcol) = pa;
                PARAM{pbcol}   = strrep(PARAM{pbcol}, denumber(PARAM{pbcol}), paname);
                
                addchange(handles,qbcol,DADOS(:,qbcol));
                DADOS(:,qbcol) = qc;
                PARAM{qbcol}   = strrep(PARAM{qbcol}, denumber(PARAM{qbcol}), qcname);
                
                if Zpbcol
                    addchange(handles,Zpbcol,DADOS(:,Zpbcol));
                    DADOS(:,Zpbcol) = Zp;
                    PARAM{Zpbcol}   = strrep(PARAM{Zpbcol}, denumber(PARAM{Zpbcol}), Zpname);
                else
                    DADOS = [DADOS(:,1:end-1)  Zp  DADOS(:,end)];
                    PARAM = InsertParam(PARAM,Zpname);
                    addchange(handles,length(PARAM)-1,[]);
                end
                if Vbcol
                    addchange(handles,Vbcol,DADOS(:,Vbcol));
                    DADOS(:,Vbcol) = Vc;
                    PARAM{Vbcol}   = strrep(PARAM{Vbcol}, denumber(PARAM{Vbcol}), Vcname);
                else
                    DADOS = [DADOS(:,1:end-1)  Vc  DADOS(:,end)];
                    PARAM = InsertParam(PARAM,Vcname);
                    addchange(handles,length(PARAM)-1,[]);
                end
                if Mbcol
                    addchange(handles,Mbcol,DADOS(:,Mbcol));
                    DADOS(:,Mbcol) = M;
                    PARAM{Mbcol}   = strrep(PARAM{Mbcol}, denumber(PARAM{Mbcol}), Mname);
                else
                    DADOS = [DADOS(:,1:end-1)  M  DADOS(:,end)];
                    PARAM = InsertParam(PARAM,Mname);
                    addchange(handles,length(PARAM)-1,[]);
                end
            else
                return
            end
    end
    
    uiwait(okdlg('Processamento realizado com sucesso.','Aviso','modal'));
    set(handles.anemo_group,'Enable','off');
    set(handles.anemo_go,'String','Processado','BackgroundColor','g','Enable','inactive')
    set(handles.param_lists,'String',PARAM);
    set(handles.ignparam_lists,'String',char('Ignorar',char(PARAM)));
end

% -------------------------------------------------------------------
function Wref_Callback(hObject, eventdata, handles)
% Inserção do peso de referência (W0 ou Wzf)

val = str2num(get(gcbo,'String'));
if length(val) ~= 1
    str = '';
else
    str = num2str(max(0,val),12);
end
set(gcbo,'String',str);

% -------------------------------------------------------------------
function Wcalc_tot_sel_Callback(hObject, eventdata, handles)
% Seleção Tot

set(handles.Wcalc_tot_sel,'Value',1);
set(handles.Wcalc_detot_sel,'Value',0);

set(handles.Wcalc_fuel_txt,'String','Tot');
set(handles.Wcalc_Wref_txt,'String','Wo');
set(handles.Wref,'TooltipString','Peso total inicial');

% -------------------------------------------------------------------
function Wcalc_detot_sel_Callback(hObject, eventdata, handles)
% Seleção Detot

set(handles.Wcalc_tot_sel,'Value',0);
set(handles.Wcalc_detot_sel,'Value',1);

set(handles.Wcalc_fuel_txt,'String','Detot');
set(handles.Wcalc_Wref_txt,'String','Wzf');
set(handles.Wref,'TooltipString','Peso zero-combustível');

% -------------------------------------------------------------------
function Wcalc_go_Callback(hObject, eventdata, handles)
global DADOS
% Realizar cálculo do peso

[na, nc] = getnanc(handles);

button = questdlg({'Deseja calcular o peso em voo', ['da aeronave ' handles.acftdb(na).type ' ' handles.acftdb(na).tail ' ?']},...
    'Processar','Sim','Não','Não');

if strcmp(button,'Sim')
    
    set([handles.acft_sel handles.date_sel],'Enable','off');
    
    PARAM    = cellstr(get(handles.Wcalc_fuel_sel,'String'));
    fuelcol  = get(handles.Wcalc_fuel_sel,'Value');
    Wref     = str2double(get(handles.Wref,'String'));
    fueltype = get(handles.Wcalc_tot_sel,'Value');
    
    if isnan(Wref)
        if fueltype == 1
            str = 'peso total inicial';
        else
            str = 'peso zero-combustível';
        end
        beep; uiwait(errordlg({'Não é possível processar.',...
                ['O ' str ' não está definido adequadamente.']},'Erro','modal'));
        
    else
        
        Wname = TrimParamName(get(handles.Wcalc_name,'String'),handles.maxparamlength);
        if isempty(Wname)
            beep; uiwait(errordlg('Nome do parâmetro não pode ser vazio.','Erro','modal'));
            return
        end
        
        switch fueltype
            case 1 % TOT
                W = Wref - DADOS(:,fuelcol);
            case 0 % DETOT
                W = Wref + DADOS(:,fuelcol);
        end
        
        PARAM = InsertParam(PARAM,Wname);
        DADOS = [DADOS(:,1:end-1)  W  DADOS(:,end)];
        addchange(handles,length(PARAM)-1,[]);
        
        uiwait(okdlg('Processamento realizado com sucesso.','Aviso','modal'));
        set(handles.Wcalc_group,'Enable','off');
        set(handles.Wcalc_go,'String','Processado','BackgroundColor','g','Enable','inactive')
        set(handles.param_lists,'String',PARAM);
        set(handles.ignparam_lists,'String',char('Ignorar',char(PARAM)));
    end
end

% -------------------------------------------------------------------
function K_go_Callback(hObject, eventdata, handles)
global DADOS
% Realizar cálculo da temperatura do ar

[na, nc] = getnanc(handles);

button = questdlg({'Deseja calcular a temperatura do ar',...
        ['para a aeronave ' handles.acftdb(na).type ' ' handles.acftdb(na).tail ],...
        ['usando a calibração de ' datetime2str(handles.acftdb(na).date(nc,:)) '?']},'Processar','Sim','Não','Não');

if strcmp(button,'Sim')
    
    set([handles.acft_sel handles.date_sel],'Enable','off');
    
    PARAM = cellstr(get(handles.K_Ti_sel,'String'));
    Ticol = get(handles.K_Ti_sel,'Value');
    Mcol  = get(handles.K_M_sel,'Value');
    K     = handles.acftdb(na).K(nc);
    
    if isnan(K)
        beep; uiwait(errordlg({'Não é possível processar.',...
                'O coeficiente de restituição da sonda de temperatura',...
                'não está definido adequadamente.'},'Erro','modal'));
       set(handles.K_group,'Enable','off'); 
    else
        
        Taname = TrimParamName(get(handles.Ta_name,'String'),handles.maxparamlength);
        if isempty(Taname)
            beep; uiwait(errordlg('Nome do parâmetro não pode ser vazio.','Erro','modal'));
            return
        end
        
        Ta = (DADOS(:,Ticol)+273.15) ./ (1+(K/5) * DADOS(:,Mcol).^2) - 273.15;
        
        PARAM = InsertParam(PARAM,Taname);
        DADOS = [DADOS(:,1:end-1)  Ta  DADOS(:,end)];
        addchange(handles,length(PARAM)-1,[]);
        
        uiwait(okdlg('Processamento realizado com sucesso.','Aviso','modal'));
        set(handles.K_group,'Enable','off');
        set(handles.K_go,'String','Processado','BackgroundColor','g','Enable','inactive')
        set(handles.param_lists,'String',PARAM);
        set(handles.ignparam_lists,'String',char('Ignorar',char(PARAM)));
    end
end

% -------------------------------------------------------------------
function AB_go_Callback(hObject, eventdata, handles)
global DADOS
% Realizar calibração de alfa e beta

[na, nc] = getnanc(handles);

button = questdlg({'Deseja corrigir os ângulos de ataque e derrapagem',...
        ['da aeronave ' handles.acftdb(na).type ' ' handles.acftdb(na).tail ],...
        ['usando a calibração de ' datetime2str(handles.acftdb(na).date(nc,:)) '?']},'Processar','Sim','Não','Não');

if strcmp(button,'Sim')
    
    set([handles.acft_sel handles.date_sel],'Enable','off');
    
    PARAM    = cellstr(get(handles.Ncorr_Nx_sel,'String'));
    Alfagcol = get(handles.AB_Alfag_sel,'Value')-1;
    Betagcol = get(handles.AB_Betag_sel,'Value')-1;
    Acoefs   = handles.acftdb(na).alpha(nc,:);
    Bcoefs   = handles.acftdb(na).beta(nc,:);
    A = 1;
    B = 1;
    
    if ~Alfagcol && ~Betagcol
        beep; uiwait(errordlg('Parâmetros dos sensores de alfa e beta não estão definidos.','Erro','modal'));
        return
    end
    
    if Alfagcol && any(isnan(Acoefs))
        beep; uiwait(errordlg({'Não é possível processar o ângulo de ataque.',...
                'Os coeficientes da curva do sensor de alfa',...
                'não estão definidos adequadamente.'},'Erro','modal'));
        A = 0;
        set(handles.AB_Alfag_sel,'Value',1);
        set(handles.Alfa_group,'Enable','off');
    end
    if Betagcol && any(isnan(Bcoefs))
        beep; uiwait(errordlg({'Não é possível processar o ângulo de derrapagem.',...
                'Os coeficientes da curva do sensor de beta',...
                'não estão definidos adequadamente.'},'Erro','modal'));
        B = 0;
        set(handles.AB_Betag_sel,'Value',1);
        set(handles.Beta_group,'Enable','off');
    end
    if ~A && ~B
        set(handles.AB_group,'Enable','off');
    end
    if ~Alfagcol
        A = 0;
    end
    if ~Betagcol
        B = 0;
    end

    if A || B
        
        Alfaname = TrimParamName(get(handles.Alfa_name,'String'),handles.maxparamlength);
        Betaname = TrimParamName(get(handles.Beta_name,'String'),handles.maxparamlength);
        if A && isempty(Alfaname) || B && isempty(Betaname)
            beep; uiwait(errordlg('Nome do parâmetro não pode ser vazio.','Erro','modal'));
            return
        end
        
        if A
            Alfa  = polyval(Acoefs, DADOS(:,Alfagcol));
        end
        if B
            Beta  = polyval(Bcoefs, DADOS(:,Betagcol));
        end
        
        switch get(handles.AB_opt,'Value')
            case 0 % Novos parâmetros
                
                if A
                    PARAM = InsertParam(PARAM,Alfaname);
                    DADOS = [DADOS(:,1:end-1)  Alfa  DADOS(:,end)];
                    addchange(handles,length(PARAM)-1,[]);
                end
                if B
                    PARAM = InsertParam(PARAM,Betaname);
                    DADOS = [DADOS(:,1:end-1)  Beta  DADOS(:,end)];
                    addchange(handles,length(PARAM)-1,[]);
                end
                
            case 1 % Substituir
                
                if A && B
                    str = 'Deseja substituir os parâmetros?';
                else
                    str = 'Deseja substituir o parâmetro?';
                end
                button = questdlg({str,'Os dados originais serão perdidos!'},'Confirmação','Sim','Não','Não');
                if strcmp(button,'Sim')
                    
                    if A && Alfagcol == length(PARAM) || B && Betagcol == length(PARAM)
                        beep; uiwait(errordlg('Não é possível alterar o parâmetro ''No. OBS.''','Erro','modal'));
                        return
                    end

                    if A
                        addchange(handles,Alfagcol,DADOS(:,Alfagcol));
                        DADOS(:,Alfagcol) = Alfa;
                        PARAM{Alfagcol}   = strrep(PARAM{Alfagcol}, denumber(PARAM{Alfagcol}), Alfaname);
                    end
                    if B
                        addchange(handles,Betagcol,DADOS(:,Betagcol));
                        DADOS(:,Betagcol) = Beta;
                        PARAM{Betagcol}   = strrep(PARAM{Betagcol}, denumber(PARAM{Betagcol}), Betaname);
                    end
                else
                    return
                end
        end
        
        uiwait(okdlg('Processamento realizado com sucesso.','Aviso','modal'));
        set(handles.AB_group,'Enable','off');
        set(handles.AB_go,'String','Processado','BackgroundColor','g','Enable','inactive')
        set(handles.param_lists,'String',PARAM);
        set(handles.ignparam_lists,'String',char('Ignorar',char(PARAM)));
    end
end

% -------------------------------------------------------------------
function CL_go_Callback(hObject, eventdata, handles)
global DADOS
% Realizar cálculo do CL

[na, nc] = getnanc(handles);

button = questdlg({'Deseja calcular o coeficiente de sustentação',...
        ['da aeronave ' handles.acftdb(na).type ' ' handles.acftdb(na).tail ],...
        ['usando a calibração de ' datetime2str(handles.acftdb(na).date(nc,:)) '?']},'Processar','Sim','Não','Não');

if strcmp(button,'Sim')
    
    set([handles.acft_sel handles.date_sel],'Enable','off');
    
    PARAM   = cellstr(get(handles.CL_Alfa_sel,'String'));
    Alfacol = get(handles.CL_Alfa_sel,'Value');
    coefs   = handles.acftdb(na).CL(nc,:);
    
    if any(isnan(coefs))
        beep; uiwait(errordlg({'Não é possível processar.',...
                'Os coeficientes da curva de CL x Alfa',...
                'não estão definidos adequadamente.'},'Erro','modal'));
       set(handles.CL_group,'Enable','off');
    else
        
        CLname = TrimParamName(get(handles.CL_name,'String'),handles.maxparamlength);
        if isempty(CLname)
            beep; uiwait(errordlg('Nome do parâmetro não pode ser vazio.','Erro','modal'));
            return
        end
        
        CL = polyval(coefs, DADOS(:,Alfacol));
        
        PARAM = InsertParam(PARAM,CLname);
        DADOS = [DADOS(:,1:end-1)  CL  DADOS(:,end)];
        addchange(handles,length(PARAM)-1,[]);
        
        uiwait(okdlg('Processamento realizado com sucesso.','Aviso','modal'));
        set(handles.CL_group,'Enable','off');
        set(handles.CL_go,'String','Processado','BackgroundColor','g','Enable','inactive')
        set(handles.param_lists,'String',PARAM);
        set(handles.ignparam_lists,'String',char('Ignorar',char(PARAM)));
    end
end

% -------------------------------------------------------------------
function polar_go_Callback(hObject, eventdata, handles)
global DADOS
% Realizar cálculo da polar de arrasto

[na, nc] = getnanc(handles);

button = questdlg({'Deseja calcular o coeficiente de arrasto',...
        ['da aeronave ' handles.acftdb(na).type ' ' handles.acftdb(na).tail ],...
        ['usando a calibração de ' datetime2str(handles.acftdb(na).date(nc,:)) '?']},'Processar','Sim','Não','Não');

if strcmp(button,'Sim')
    
    set([handles.acft_sel handles.date_sel],'Enable','off');
    
    PARAM = cellstr(get(handles.polar_CL_sel,'String'));
    CLcol = get(handles.polar_CL_sel,'Value');
    coefs = handles.acftdb(na).polar(nc,:);
    
    if any(isnan(coefs))
        beep; uiwait(errordlg({'Não é possível processar.',...
                'Os coeficientes da polar de arrasto',...
                'não estão definidos adequadamente.'},'Erro','modal'));
       set(handles.polar_group,'Enable','off');
    else
        
        CDname = TrimParamName(get(handles.CD_name,'String'),handles.maxparamlength);
        if isempty(CDname)
            beep; uiwait(errordlg('Nome do parâmetro não pode ser vazio.','Erro','modal'));
            return
        end
        
        CD = polyval(coefs, DADOS(:,CLcol));
        
        PARAM = InsertParam(PARAM,CDname);
        DADOS = [DADOS(:,1:end-1)  CD  DADOS(:,end)];
        addchange(handles,length(PARAM)-1,[]);
        
        uiwait(okdlg('Processamento realizado com sucesso.','Aviso','modal'));
        set(handles.polar_group,'Enable','off');
        set(handles.polar_go,'String','Processado','BackgroundColor','g','Enable','inactive')
        set(handles.param_lists,'String',PARAM);
        set(handles.ignparam_lists,'String',char('Ignorar',char(PARAM)));
    end
end

% -------------------------------------------------------------------
function Va_go_Callback(hObject, eventdata, handles)
global DADOS
% Realizar cálculo da Va

[na, nc] = getnanc(handles);

button = questdlg({'Deseja calcular a velocidade verdadeira',...
        ['da aeronave ' handles.acftdb(na).type ' ' handles.acftdb(na).tail ' ?']},'Processar','Sim','Não','Não');

if strcmp(button,'Sim')
    
    set([handles.acft_sel handles.date_sel],'Enable','off');
    
    PARAM = cellstr(get(handles.Va_M_sel,'String'));
    Mcol  = get(handles.Va_M_sel,'Value');
    Tacol = get(handles.Va_Ta_sel,'Value');
    
    Vaname = TrimParamName(get(handles.Va_name,'String'),handles.maxparamlength);
    if isempty(Vaname)
        beep; uiwait(errordlg('Nome do parâmetro não pode ser vazio.','Erro','modal'));
        return
    end
    
    Va = DADOS(:,Mcol).*sqrt((DADOS(:,Tacol)+273.15)*1.4*287.053)*3600/1852;
    
    PARAM = InsertParam(PARAM,Vaname);
    DADOS = [DADOS(:,1:end-1)  Va  DADOS(:,end)];
    addchange(handles,length(PARAM)-1,[]);
    
    uiwait(okdlg('Processamento realizado com sucesso.','Aviso','modal'));
    set(handles.Va_group,'Enable','off');
    set(handles.Va_go,'String','Processado','BackgroundColor','g','Enable','inactive')
    set(handles.param_lists,'String',PARAM);
    set(handles.ignparam_lists,'String',char('Ignorar',char(PARAM)));
end

% -------------------------------------------------------------------
function uvw_go_Callback(hObject, eventdata, handles)
global DADOS
% Realizar cálculo de u v w

[na, nc] = getnanc(handles);

button = questdlg({'Deseja obter as componentes de velocidade',...
        ['da aeronave ' handles.acftdb(na).type ' ' handles.acftdb(na).tail ' ?']},...
    'Processar','Sim','Não','Não');

if strcmp(button,'Sim')
    
    set([handles.acft_sel handles.date_sel],'Enable','off');
    
    PARAM = cellstr(get(handles.uvw_Va_sel,'String'));
    Vacol = get(handles.uvw_Va_sel,'Value');
    Alfacol = get(handles.uvw_Alfa_sel,'Value');
    Betacol = get(handles.uvw_Beta_sel,'Value')-1;
    
    uname = TrimParamName(get(handles.u_name,'String'),handles.maxparamlength);
    if isempty(uname)
        beep; uiwait(errordlg('Nome do parâmetro não pode ser vazio.','Erro','modal'));
        return
    end
    vname = TrimParamName(get(handles.v_name,'String'),handles.maxparamlength);
    if isempty(vname)
        beep; uiwait(errordlg('Nome do parâmetro não pode ser vazio.','Erro','modal'));
        return
    end
    wname = TrimParamName(get(handles.w_name,'String'),handles.maxparamlength);
    if isempty(wname)
        beep; uiwait(errordlg('Nome do parâmetro não pode ser vazio.','Erro','modal'));
        return
    end
    
    Va   = DADOS(:,Vacol);
    Alfa = DADOS(:,Alfacol) * pi/180;
    if Betacol
        Beta = DADOS(:,Betacol) * pi/180;
    else
        Beta = 0*Alfa;
    end
    
    u = Va .* cos(Beta) .* cos(Alfa) ;
    v = Va .* sin(Beta)              ;
    w = Va .* cos(Beta) .* sin(Alfa) ;
    
    PARAM = InsertParam(PARAM,uname);
    PARAM = InsertParam(PARAM,vname);
    PARAM = InsertParam(PARAM,wname);
    DADOS = [DADOS(:,1:end-1)  u  v  w  DADOS(:,end)];
    
    Npar = length(PARAM);
    addchange(handles,Npar-3,[]);
    addchange(handles,Npar-2,[]);
    addchange(handles,Npar-1,[]);
    
    uiwait(okdlg('Processamento realizado com sucesso.','Aviso','modal'));
    set(handles.uvw_group,'Enable','off');
    set(handles.uvw_go,'String','Processado','BackgroundColor','g','Enable','inactive')
    set(handles.param_lists,'String',PARAM);
    set(handles.ignparam_lists,'String',char('Ignorar',char(PARAM)));
end

% -------------------------------------------------------------------
function Cmd_go_Callback(hObject, eventdata, handles)
global DADOS
% Realizar calibração de comandos

[na, nc] = getnanc(handles);

button = questdlg({'Deseja calibrar as deflexões de comando',...
        ['da aeronave ' handles.acftdb(na).type ' ' handles.acftdb(na).tail ],...
        ['usando a calibração de ' datetime2str(handles.acftdb(na).date(nc,:)) '?']},'Processar','Sim','Não','Não');

if strcmp(button,'Sim')
    
    set([handles.acft_sel handles.date_sel],'Enable','off');
    
    PARAM   = cellstr(get(handles.Ncorr_Nx_sel,'String'));
    Ddmcol  = get(handles.Cmd_Ddm_sel,'Value')-1;
    Ddlcol  = get(handles.Cmd_Ddl_sel,'Value')-1;
    Ddncol  = get(handles.Cmd_Ddn_sel,'Value')-1;
    Pi1col  = get(handles.Cmd_Pi1_sel,'Value')-1;
    Pi2col  = get(handles.Cmd_Pi2_sel,'Value')-1;
    Cmddata = handles.acftdb(na).Cmd(:,:,nc);
    
    M  = 1;
    L  = 1;
    N  = 1;
    P1 = 1;
    P2 = 2;
    
    if (Ddmcol + Ddlcol + Ddncol + Pi1col + Pi2col) == 0
        beep; uiwait(errordlg('Parâmetros das deflexões não estão definidos.','Erro','modal'));
        return
    end
    
    if Ddmcol && isnan( Cmddata(1,1)+Cmddata(3,1) )
        beep; uiwait(errordlg({'Não é possível processar a deflexão longitudinal.',...
                'Os batentes de deflexão não estão definidos adequadamente.'},'Erro','modal'));
        M = 0;
        set(handles.Cmd_Ddm_sel,'Value',1);
        set(handles.Ddm_group,'Enable','off');
    end
    if Ddlcol && isnan( Cmddata(1,2)+Cmddata(3,2) )
        beep; uiwait(errordlg({'Não é possível processar a deflexão lateral.',...
                'Os batentes de deflexão não estão definidos adequadamente.'},'Erro','modal'));
        L = 0;
        set(handles.Cmd_Ddl_sel,'Value',1);
        set(handles.Ddl_group,'Enable','off');
    end
    if Ddncol && isnan( Cmddata(1,3)+Cmddata(3,3) )
        beep; uiwait(errordlg({'Não é possível processar a deflexão direcional.',...
                'Os batentes de deflexão não estão definidos adequadamente.'},'Erro','modal'));
        N = 0;
        set(handles.Cmd_Ddn_sel,'Value',1);
        set(handles.Ddn_group,'Enable','off');
    end
    if Pi1col && isnan( Cmddata(1,4)+Cmddata(3,4) )
        beep; uiwait(errordlg({'Não é possível processar o fator propulsivo do motor 1.',...
                'Os batentes de deflexão não estão definidos adequadamente.'},'Erro','modal'));
        P1 = 0;
        set(handles.Cmd_Pi1_sel,'Value',1);
        set(handles.Pi1_group,'Enable','off');
    end
    if Pi2col && isnan( Cmddata(1,5)+Cmddata(3,5) )
        beep; uiwait(errordlg({'Não é possível processar o fator propulsivo do motor 2.',...
                'Os batentes de deflexão não estão definidos adequadamente.'},'Erro','modal'));
        P2 = 0;
        set(handles.Cmd_Pi2_sel,'Value',1);
        set(handles.Pi2_group,'Enable','off');
    end
    
    if (M + L + N + P1 + P2) == 0
        set(handles.Cmd_group,'Enable','off');
    end
    if ~Ddmcol
        M = 0;
    end
    if ~Ddlcol
        L = 0;
    end
    if ~Ddncol
        N = 0;
    end
    if ~Pi1col
        P1 = 0;
    end
    if ~Pi2col
        P2 = 0;
    end
    
    if (M + L + N + P1 + P2) == 0
        return
    end
    
    Ddmname = TrimParamName(get(handles.Ddm_name,'String'),handles.maxparamlength);
    Ddlname = TrimParamName(get(handles.Ddl_name,'String'),handles.maxparamlength);
    Ddnname = TrimParamName(get(handles.Ddn_name,'String'),handles.maxparamlength);
    Pi1name = TrimParamName(get(handles.Pi1_name,'String'),handles.maxparamlength);
    Pi2name = TrimParamName(get(handles.Pi2_name,'String'),handles.maxparamlength);
    if M && isempty(Ddmname) || L && isempty(Ddlname) || N && isempty(Ddnname) || P1 && isempty(Pi1name) || P2 && isempty(Pi2name)
        beep; uiwait(errordlg('Nome do parâmetro não pode ser vazio.','Erro','modal'));
        return
    end
    
    % Cálculos
    if M
        
        Ddmmin = Cmddata(1,1);
        Ddmzro = Cmddata(2,1);
        Ddmmax = Cmddata(3,1);
        Ddmk   = Cmddata(4,1);
        if isnan(Ddmzro), Ddmzro = (Ddmmin+Ddmmax)/2; end
        T = sortrows([Ddmmin -1; Ddmzro 0; Ddmmax 1],1);
        try
            Ddm = Ddmk*interp1(T(:,1),T(:,2),DADOS(:,Ddmcol),'linear','extrap');
        catch
            beep; uiwait(errordlg({'Erro ao processar Ddm:',lasterr},'Erro','modal'));
            M = 0;
        end
        
    end
    if L
        
        Ddlmin = Cmddata(1,2);
        Ddlzro = Cmddata(2,2);
        Ddlmax = Cmddata(3,2);
        Ddlk   = Cmddata(4,2);
        if isnan(Ddlzro), Ddlzro = (Ddlmin+Ddlmax)/2; end
        T = sortrows([Ddlmin -1; Ddlzro 0; Ddlmax 1],1);
        try
            Ddl = Ddlk*interp1(T(:,1),T(:,2),DADOS(:,Ddlcol),'linear','extrap');
        catch
            beep; uiwait(errordlg({'Erro ao processar Ddl:',lasterr},'Erro','modal'));
            L = 0;
        end
        
    end
    if N
        
        Ddnmin = Cmddata(1,3);
        Ddnzro = Cmddata(2,3);
        Ddnmax = Cmddata(3,3);
        Ddnk   = Cmddata(4,3);
        if isnan(Ddnzro), Ddnzro = (Ddnmin+Ddnmax)/2; end
        T = sortrows([Ddnmin -1; Ddnzro 0; Ddnmax 1],1);
        try
            Ddn = Ddnk*interp1(T(:,1),T(:,2),DADOS(:,Ddncol),'linear','extrap');
        catch
            beep; uiwait(errordlg({'Erro ao processar Ddn:',lasterr},'Erro','modal'));
            N = 0;
        end
        
    end
    if P1
        
        Pi1min = Cmddata(1,4);
        Pi1zro = Cmddata(2,4);
        Pi1max = Cmddata(3,4);
        Pi1k   = Cmddata(4,4);
        if isnan(Pi1zro), Pi1zro = (Pi1min+Pi1max)/2; end
        T = sortrows([Pi1min -1; Pi1zro 0; Pi1max 1],1);
        try
            Pi1 = Pi1k*interp1(T(:,1),T(:,2),DADOS(:,Pi1col),'linear','extrap');
        catch
            beep; uiwait(errordlg({'Erro ao processar Pi1:',lasterr},'Erro','modal'));
            P1 = 0;
        end
        
    end
    if P2
        
        Pi2min = Cmddata(1,5);
        Pi2zro = Cmddata(2,5);
        Pi2max = Cmddata(3,5);
        Pi2k   = Cmddata(4,5);
        if isnan(Pi2zro), Pi2zro = (Pi2min+Pi2max)/2; end
        T = sortrows([Pi2min -1; Pi2zro 0; Pi2max 1],1);
        try
            Pi2 = Pi2k*interp1(T(:,1),T(:,2),DADOS(:,Pi2col),'linear','extrap');
        catch
            beep; uiwait(errordlg({'Erro ao processar Pi2:',lasterr},'Erro','modal'));
            P2 = 0;
        end
        
    end
    
    if (M + L + N + P1 + P2) == 0
        return
    end
    
    switch get(handles.Cmd_opt,'Value')
        case 0 % Novos parâmetros
            
            if M
                PARAM = InsertParam(PARAM,Ddmname);
                DADOS = [DADOS(:,1:end-1)  Ddm  DADOS(:,end)];
                addchange(handles,length(PARAM)-1,[]);
            end
            if L
                PARAM = InsertParam(PARAM,Ddlname);
                DADOS = [DADOS(:,1:end-1)  Ddl  DADOS(:,end)];
                addchange(handles,length(PARAM)-1,[]);
            end
            if N
                PARAM = InsertParam(PARAM,Ddnname);
                DADOS = [DADOS(:,1:end-1)  Ddn  DADOS(:,end)];
                addchange(handles,length(PARAM)-1,[]);
            end
            if P1
                PARAM = InsertParam(PARAM,Pi1name);
                DADOS = [DADOS(:,1:end-1)  Pi1  DADOS(:,end)];
                addchange(handles,length(PARAM)-1,[]);
            end
            if P2
                PARAM = InsertParam(PARAM,Pi2name);
                DADOS = [DADOS(:,1:end-1)  Pi2  DADOS(:,end)];
                addchange(handles,length(PARAM)-1,[]);
            end
            
        case 1 % Substituir
            
            if (M+L+N+P1+P2) > 1
                str = 'Deseja substituir os parâmetros?';
            else
                str = 'Deseja substituir o parâmetro?';
            end
            button = questdlg({str,'Os dados originais serão perdidos!'},'Confirmação','Sim','Não','Não');
            if strcmp(button,'Sim')
                
                if M && Ddmcol == length(PARAM) || L && Ddlcol == length(PARAM) || N && Ddncol == length(PARAM) || ...
                        P1 && Pi1col == length(PARAM) || P2 && Pi2col == length(PARAM)
                    beep; uiwait(errordlg('Não é possível alterar o parâmetro ''No. OBS.''','Erro','modal'));
                    return
                end
                
                if M
                    addchange(handles,Ddmcol,DADOS(:,Ddmcol));
                    DADOS(:,Ddmcol) = Ddm;
                    PARAM{Ddmcol}   = strrep(PARAM{Ddmcol}, denumber(PARAM{Ddmcol}), Ddmname);
                end
                if L
                    addchange(handles,Ddlcol,DADOS(:,Ddlcol));
                    DADOS(:,Ddlcol) = Ddl;
                    PARAM{Ddlcol}   = strrep(PARAM{Ddlcol}, denumber(PARAM{Ddlcol}), Ddlname);
                end
                if N
                    addchange(handles,Ddncol,DADOS(:,Ddncol));
                    DADOS(:,Ddncol) = Ddn;
                    PARAM{Ddncol}   = strrep(PARAM{Ddncol}, denumber(PARAM{Ddncol}), Ddnname);
                end
                if P1
                    addchange(handles,Pi1col,DADOS(:,Pi1col));
                    DADOS(:,Pi1col) = Pi1;
                    PARAM{Pi1col}   = strrep(PARAM{Pi1col}, denumber(PARAM{Pi1col}), Pi1name);
                end
                if P2
                    addchange(handles,Pi2col,DADOS(:,Pi2col));
                    DADOS(:,Pi2col) = Pi2;
                    PARAM{Pi2col}   = strrep(PARAM{Pi2col}, denumber(PARAM{Pi2col}), Pi2name);
                end
                
            else
                return
            end
    end
    
    uiwait(okdlg('Processamento realizado com sucesso.','Aviso','modal'));
    set(handles.Cmd_group,'Enable','off');
    set(handles.Cmd_go,'String','Processado','BackgroundColor','g','Enable','inactive')
    set(handles.param_lists,'String',PARAM);
    set(handles.ignparam_lists,'String',char('Ignorar',char(PARAM)));
end

% -------------------------------------------------------------------
function FPM_go_Callback(hObject, eventdata, handles)
global DADOS
% Realizar cálculo de azimute e depressão do FPM

[na, nc] = getnanc(handles);

button = questdlg({'Deseja obter as componentes do indicador de trajetória (FPM)',...
        ['da aeronave ' handles.acftdb(na).type ' ' handles.acftdb(na).tail ' ?']},...
    'Processar','Sim','Não','Não');

if strcmp(button,'Sim')
    
    set([handles.acft_sel handles.date_sel],'Enable','off');
    
    PARAM = cellstr(get(handles.FPM_VN_sel,'String'));
    VNcol = get(handles.FPM_VN_sel,'Value');
    VEcol = get(handles.FPM_VE_sel,'Value');
    VDcol = get(handles.FPM_VD_sel,'Value');
    psicol = get(handles.FPM_psi_sel,'Value');
    tetcol = get(handles.FPM_tet_sel,'Value');
    phicol = get(handles.FPM_phi_sel,'Value');
    
    FPMazname = TrimParamName(get(handles.FPMaz_name,'String'),handles.maxparamlength);
    if isempty(FPMazname)
        beep; uiwait(errordlg('Nome do parâmetro não pode ser vazio.','Erro','modal'));
        return
    end
    FPMdpname = TrimParamName(get(handles.FPMdp_name,'String'),handles.maxparamlength);
    if isempty(FPMdpname)
        beep; uiwait(errordlg('Nome do parâmetro não pode ser vazio.','Erro','modal'));
        return
    end
    
    VN  = DADOS(:,VNcol);
    VE  = DADOS(:,VEcol);
    VD  = DADOS(:,VDcol);
    psi = DADOS(:,psicol);
    tet = DADOS(:,tetcol);
    phi = DADOS(:,phicol);
    
    [FPM_Azim, FPM_Elev] = earth2hud(VN,VE,VD,psi,tet,phi);
    FPM_Depr = -FPM_Elev;
    
    PARAM = InsertParam(PARAM,FPMazname);
    PARAM = InsertParam(PARAM,FPMdpname);
    DADOS = [DADOS(:,1:end-1)  FPM_Azim  FPM_Depr  DADOS(:,end)];
    
    Npar = length(PARAM);
    addchange(handles,Npar-2,[]);
    addchange(handles,Npar-1,[]);
    
    uiwait(okdlg('Processamento realizado com sucesso.','Aviso','modal'));
    set(handles.FPM_group,'Enable','off');
    set(handles.FPM_go,'String','Processado','BackgroundColor','g','Enable','inactive')
    set(handles.param_lists,'String',PARAM);
    set(handles.ignparam_lists,'String',char('Ignorar',char(PARAM)));
end

% -------------------------------------------------------------------
function help_btn_Callback(hObject, eventdata, handles)
% Botão Ajuda

helpme('Ferramentas\processardados');

% -------------------------------------------------------------------
function ok_btn_Callback(hObject, eventdata, handles)
% Botão OK

if isempty(getappdata(handles.window,'changes'))
    str = 'Deseja sair?';
else
    str = 'Deseja confirmar a operação?';
end
button = questdlg(str,'Confirmação','Sim','Não','Não');
if strcmp(button,'Sim')
    handles.ok = 1;
    guidata(hObject, handles);
    uiresume;
end

% -------------------------------------------------------------------
function cancel_btn_Callback(hObject, eventdata, handles)
% Botão Cancela

if isempty(getappdata(handles.window,'changes'))
    str = 'Deseja sair?';
else
    str = 'Deseja cancelar a operação?';
end
button = questdlg(str,'Confirmação','Sim','Não','Não');
if strcmp(button,'Sim')
    uiresume;
end

% -------------------------------------------------------------------
function window_CloseRequestFcn(hObject, eventdata, handles)
cancel_btn_Callback(hObject, eventdata, handles);

% -------------------------------------------------------------------
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

% -------------------------------------------------------------------
function addchange(handles,npar,olddata)
% Registra nova alteração de dados

changes = getappdata(handles.window,'changes');
changes = [changes; {npar,olddata}];
setappdata(handles.window,'changes',changes);

% -------------------------------------------------------------------
function [na, nc] = getnanc(handles)
% Fornece os índices de aeronave e calibração

na = get(handles.acft_sel,'Value');
nc = get(handles.date_sel,'Value');

% -------------------------------------------------------------------
function [np, nv] = getnpnv(handles)
% Fornece os índices dos tipos de curvas de calibração

for np = 1:3
    if get(handles.ptypes(np),'Value');
        break
    end
end
for nv = 1:3
    if get(handles.vtypes(nv),'Value');
        break
    end
end

% -------------------------------------------------------------------
function L = ortocorr(dpsi_dtet_dphi)
% Matriz de correção de ortogonalidade dos sensores

dpsi = dpsi_dtet_dphi(1)*pi/180;
dtet = dpsi_dtet_dphi(2)*pi/180;
dphi = dpsi_dtet_dphi(3)*pi/180;

L = [cos(dtet)*cos(dpsi)                               cos(dtet)*sin(dpsi)                               -sin(dtet)           ;
    sin(dphi)*sin(dtet)*cos(dpsi)-cos(dphi)*sin(dpsi)  cos(dphi)*cos(dpsi)+sin(dphi)*sin(dtet)*sin(dpsi)  sin(dphi)*cos(dtet) ;
    sin(dphi)*sin(dpsi)+cos(dphi)*sin(dtet)*cos(dpsi)  cos(dphi)*sin(dtet)*sin(dpsi)-sin(dphi)*cos(dpsi)  cos(dphi)*cos(dtet) ];

% -------------------------------------------------------------------
function poserrfcn(hObject, eventdata, handles)
% Clicar sobre um tipo de curva de erro de posição

cp = get(handles.poserrtypes,'CurrentPoint');
x = cp(1);
if x < 111
    ptype1_Callback(hObject, eventdata, handles)
elseif x < 219
    ptype2_Callback(hObject, eventdata, handles)
else
    ptype3_Callback(hObject, eventdata, handles)
end

% -------------------------------------------------------------------
function velerrfcn(hObject, eventdata, handles)
% Clicar sobre um tipo de curva de erro de velocidade

cp = get(handles.velerrtypes,'CurrentPoint');
x = cp(1);
if x < 88
    vtype1_Callback(hObject, eventdata, handles)
elseif x < 193
    vtype2_Callback(hObject, eventdata, handles)
else
    vtype3_Callback(hObject, eventdata, handles)
end

% -------------------------------------------------------------------
function ptype1_Callback(hObject, eventdata, handles)
% Selcionar curva de erro de posição 1

if get(handles.ptypes(2),'Value') || get(handles.ptypes(3),'Value')
    reset_anemo(hObject, eventdata, handles)
end
set(handles.ptypes(1),'Value',1);
set(handles.ptypes([2 3]),'Value',0);
updatetypes(hObject, eventdata, handles);

% -------------------------------------------------------------------
function ptype2_Callback(hObject, eventdata, handles)
% Selcionar curva de erro de posição 2

if get(handles.ptypes(1),'Value') || get(handles.ptypes(3),'Value')
    reset_anemo(hObject, eventdata, handles)
end
set(handles.ptypes(2),'Value',1);
set(handles.ptypes([1 3]),'Value',0);
updatetypes(hObject, eventdata, handles);

% -------------------------------------------------------------------
function ptype3_Callback(hObject, eventdata, handles)
% Selcionar curva de erro de posição 3

if get(handles.ptypes(1),'Value') || get(handles.ptypes(2),'Value')
    reset_anemo(hObject, eventdata, handles)
end
set(handles.ptypes(3),'Value',1);
set(handles.ptypes([1 2]),'Value',0);
updatetypes(hObject, eventdata, handles);

% -------------------------------------------------------------------
function vtype1_Callback(hObject, eventdata, handles)
% Selcionar curva de erro de velocidade 1

if get(handles.vtypes(2),'Value') || get(handles.vtypes(3),'Value')
    reset_anemo(hObject, eventdata, handles)
end
set(handles.vtypes(1),'Value',1);
set(handles.vtypes([2 3]),'Value',0);

% -------------------------------------------------------------------
function vtype2_Callback(hObject, eventdata, handles)
% Selcionar curva de erro de velocidade 2

if get(handles.vtypes(1),'Value') || get(handles.vtypes(3),'Value')
    reset_anemo(hObject, eventdata, handles)
end
set(handles.vtypes(2),'Value',1);
set(handles.vtypes([1 3]),'Value',0);

% -------------------------------------------------------------------
function vtype3_Callback(hObject, eventdata, handles)
% Selcionar curva de erro de velocidade 3

if get(handles.vtypes(1),'Value') || get(handles.vtypes(2),'Value')
    reset_anemo(hObject, eventdata, handles)
end
set(handles.vtypes(3),'Value',1);
set(handles.vtypes([1 2]),'Value',0);

% -------------------------------------------------------------------
function reset_anemo(hObject, eventdata, handles)
% Resetar processamento de Dpb e Dqb

set(handles.Dpb_name,'Userdata',[]);
set(handles.Dqb_name,'Userdata',[]);
set([handles.Delta_go handles.anemo_go],'String','Processar','BackgroundColor',get(handles.ok_btn,'BackgroundColor'),'Enable','on');
set([handles.Delta_group handles.anemo_group],'Enable','on');

% -------------------------------------------------------------------
function M = getbutton(fname, bgc)
% Função que carrega um bitmap de 16 ou 256 cores e converte a cor magenta
% em cor de fundo para uso como icone de botões
% Sintaxe: M = buttons(fname, bgc)
%          fname: nome do arquivo bmp (com extensão)
%          bgc: cor de fundo desejada [r g b]

if ~exist(fname,'file')
    M = [];
    return
end
    
[M,c] = imread(fname);
if ~isempty(c)
    M = ind2rgb(M,c);
end
for n=1:size(M,1)
    for m=1:size(M,2)
        if M(n,m,1)==1 && M(n,m,2)==0 && M(n,m,3)==1
            M(n,m,1) = bgc(1);
            M(n,m,2) = bgc(2);
            M(n,m,3) = bgc(3);
        end
    end
end
