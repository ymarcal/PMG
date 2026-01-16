function varargout = RDAT_SysConv(varargin)
% RDAT_SYSCONV M-file for RDAT_SysConv.fig
% Last Modified by GUIDE v2.5 26-Nov-2010 15:10:16

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RDAT_SysConv_OpeningFcn, ...
                   'gui_OutputFcn',  @RDAT_SysConv_OutputFcn, ...
                   'gui_LayoutFcn',  @RDAT_SysConv_LayoutFcn, ...
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
function h = RDAT_SysConv_LayoutFcn(varargin)
% Função de layout inicial

h = openfig('RDAT_SysConv.fig','reuse','invisible');

% -------------------------------------------------------------------
function RDAT_SysConv_OpeningFcn(hObject, eventdata, handles, varargin)
% Funçao de entrada

bgc = getbuttoncolor(handles.window);
set(handles.help_btn,'CData',geticon('DatButtons.mat','help',bgc));

scrsz = get(0,'ScreenSize');
winsz = get(handles.window,'Position');
set(handles.window,'Position',[.5*(scrsz(3)-winsz(3)) .5*(scrsz(4)-winsz(4)) winsz(3) winsz(4)],'Visible','on');

handles.ok = 0;
handles.maxparamlength = 48;

if length(varargin) == 1
    PARAM = varargin{1};
else
    PARAM = ' ';
end

handles.sys_in  = [handles.Sg_in  handles.Sb_in  handles.Sa_in  handles.Sp_in  handles.So_in  handles.Spf_in  handles.PQR_in  handles.eulerdot_in];
handles.sys_out = [handles.Sg_out handles.Sb_out handles.Sa_out handles.Sp_out handles.So_out handles.Spf_out handles.PQR_out handles.eulerdot_out];

handles.in_txt  = [handles.in1_txt  handles.in2_txt  handles.in3_txt];
handles.aux_txt = [handles.aux1_txt handles.aux2_txt handles.aux3_txt handles.aux4_txt handles.aux5_txt];
handles.out_txt = [handles.out1_txt handles.out2_txt handles.out3_txt];

handles.in      = [handles.in1  handles.in2  handles.in3];
handles.aux     = [handles.aux1 handles.aux2 handles.aux3 handles.aux4 handles.aux5];
handles.out     = [handles.out1 handles.out2 handles.out3];

set([handles.in handles.aux],'String',cellstr(PARAM));

guidata(hObject, handles);

Sg_in_Callback(hObject, eventdata, handles);
uiwait(handles.window);

% -------------------------------------------------------------------
function varargout = RDAT_SysConv_OutputFcn(hObject, eventdata, handles)
% Funçao de saida

if handles.ok
    
    PARAM = get(handles.in1,'String');
    
    name1 = TrimParamName(get(handles.out1,'String'),handles.maxparamlength);
    name2 = TrimParamName(get(handles.out2,'String'),handles.maxparamlength);
    name3 = TrimParamName(get(handles.out3,'String'),handles.maxparamlength);
    
    PARAM = InsertParam(PARAM,name1);
    PARAM = InsertParam(PARAM,name2);
    PARAM = InsertParam(PARAM,name3);
    
    varargout{1} = PARAM;
    
else
    varargout{1} = [];
end
delete(handles.window);

% -------------------------------------------------------------------
function Sg_in_Callback(hObject, eventdata, handles)
updateoptions(hObject, eventdata, handles, 1, [2 3 4]);

% -------------------------------------------------------------------
function Sb_in_Callback(hObject, eventdata, handles)
updateoptions(hObject, eventdata, handles, 2, [1 3 4]);

% -------------------------------------------------------------------
function Sa_in_Callback(hObject, eventdata, handles)
updateoptions(hObject, eventdata, handles, 3, [1 2 4]);

% -------------------------------------------------------------------
function Sp_in_Callback(hObject, eventdata, handles)
updateoptions(hObject, eventdata, handles, 4, [1 2 3]);

% -------------------------------------------------------------------
function So_in_Callback(hObject, eventdata, handles)
updateoptions(hObject, eventdata, handles, 5, 6);

% -------------------------------------------------------------------
function Spf_in_Callback(hObject, eventdata, handles)
updateoptions(hObject, eventdata, handles, 6, 5);

% -------------------------------------------------------------------
function PQR_in_Callback(hObject, eventdata, handles)
updateoptions(hObject, eventdata, handles, 7, 8);

% -------------------------------------------------------------------
function eulerdot_in_Callback(hObject, eventdata, handles)
updateoptions(hObject, eventdata, handles, 8, 7);

% -------------------------------------------------------------------
function Sg_out_Callback(hObject, eventdata, handles)
set(handles.sys_out,'Value',0);
set(handles.Sg_out,'Value',1);

updatelabels(hObject, eventdata, handles);

% -------------------------------------------------------------------
function Sb_out_Callback(hObject, eventdata, handles)
set(handles.sys_out,'Value',0);
set(handles.Sb_out,'Value',1);

updatelabels(hObject, eventdata, handles);

% -------------------------------------------------------------------
function Sa_out_Callback(hObject, eventdata, handles)
set(handles.sys_out,'Value',0);
set(handles.Sa_out,'Value',1);

updatelabels(hObject, eventdata, handles);

% -------------------------------------------------------------------
function Sp_out_Callback(hObject, eventdata, handles)
set(handles.sys_out,'Value',0);
set(handles.Sp_out,'Value',1);

updatelabels(hObject, eventdata, handles);

% -------------------------------------------------------------------
function So_out_Callback(hObject, eventdata, handles)
set(handles.sys_out,'Value',0);
set(handles.So_out,'Value',1);

updatelabels(hObject, eventdata, handles);

% -------------------------------------------------------------------
function Spf_out_Callback(hObject, eventdata, handles)
set(handles.sys_out,'Value',0);
set(handles.Spf_out,'Value',1);

updatelabels(hObject, eventdata, handles);

% -------------------------------------------------------------------
function PQR_out_Callback(hObject, eventdata, handles)
set(handles.sys_out,'Value',0);
set(handles.PQR_out,'Value',1);

updatelabels(hObject, eventdata, handles);

% -------------------------------------------------------------------
function eulerdot_out_Callback(hObject, eventdata, handles)
set(handles.sys_out,'Value',0);
set(handles.eulerdot_out,'Value',1);

updatelabels(hObject, eventdata, handles);

% -------------------------------------------------------------------
function deg_chk_Callback(hObject, eventdata, handles)
set(handles.deg_chk,'Value',1);
set(handles.rad_chk,'Value',0);

% -------------------------------------------------------------------
function rad_chk_Callback(hObject, eventdata, handles)
set(handles.deg_chk,'Value',0);
set(handles.rad_chk,'Value',1);

% -------------------------------------------------------------------
function help_btn_Callback(hObject, eventdata, handles)
% Botao Ajuda

helpme('Funcoes\convsist');

% -------------------------------------------------------------------
function ok_btn_Callback(hObject, eventdata, handles)
% Botao OK

name1 = deblank(get(handles.out1,'String'));
name2 = deblank(get(handles.out2,'String'));
name3 = deblank(get(handles.out3,'String'));

if isempty(name1) || isempty(name2) || isempty(name3)
    beep; uiwait(errordlg('Nome do parâmetro não pode ser vazio.','Erro','modal'));
    return
end

n_in  = find(cell2mat(get(handles.sys_in,'Value')));
n_out = find(cell2mat(get(handles.sys_out,'Value')));

str = [get(handles.sys_in(n_in),'String') '  -->  ' get(handles.sys_out(n_out),'String') ' ?'];

button = questdlg({'Deseja confirmar a conversão',str},'Confirmação','Sim','Não','Não');
if strcmp(button,'Sim')
    try
        calculate(hObject, eventdata, handles);
    catch
        beep; uiwait(errordlg({'Erro na conversão:',lasterr},'Erro','modal'));
        return;
    end

    handles.ok = 1;
    guidata(hObject, handles);
    uiresume;
end

% -------------------------------------------------------------------
function cancel_btn_Callback(hObject, eventdata, handles)
% Botao Cancela

button = questdlg('Deseja cancelar a operação?','Confirmação','Sim','Não','Não');
if strcmp(button,'Sim')
    uiresume;
end

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
function window_CloseRequestFcn(hObject, eventdata, handles)
% Funçao de fechamento da janela

cancel_btn_Callback(hObject, eventdata, handles);

% -------------------------------------------------------------------
function updateoptions(hObject, eventdata, handles, Hin, Hout)
% Habilita / desabilita as opçoes de conversao

set(handles.sys_in,'Value',0);
set(handles.sys_in(Hin),'Value',1);

dis = setdiff(1:length(handles.sys_in),Hout);

set(handles.sys_out(Hout),'Enable','on');
set(handles.sys_out(dis), 'Enable','off');

if ~any(find(cell2mat(get(handles.sys_out,'Value'))) == Hout)
    set(handles.sys_out,'Value',0);
    set(handles.sys_out(Hout(1)),'Value',1);
end

updatelabels(hObject, eventdata, handles);

% -------------------------------------------------------------------
function updatelabels(hObject, eventdata, handles)
% Atualiza os nomes das entradas e saidas

n_in  = find(cell2mat(get(handles.sys_in,'Value')));
n_out = find(cell2mat(get(handles.sys_out,'Value')));

switch 10*n_in + n_out
    case 12 % Terrestre Movel -> Corpo
        in_lbl  = {'Norte','Leste','Baixo'};
        aux_lbl = {'Psi','Teta','Phi','',''};
        out_lbl = {'X','Y','Z'};
        out_nme = {'X','Y','Z'};
    case 13 % Terrestre Movel -> Aerodinamico
        in_lbl  = {'Norte','Leste','Baixo'};
        aux_lbl = {'Psi','Teta','Phi','Alfa','Beta'};
        out_lbl = {'Xa','Ya','Za'};
        out_nme = {'Xa','Ya','Za'};
    case 14 % Terrestre Movel -> Polar Movel
        in_lbl  = {'Norte','Leste','Baixo'};
        aux_lbl = {'Psi','Teta','Phi','',''};
        out_lbl = {'Azim.','Elev.','Dist.'};
        out_nme = {'Azimute (°)','Elevação (°)','Distância'};
        
    case 21 % Corpo -> Terrestre Movel
        in_lbl  = {'X','Y','Z'};
        aux_lbl = {'Psi','Teta','Phi','',''};
        out_lbl = {'Norte','Leste','Baixo'};
        out_nme = {'Norte','Leste','Baixo'};
    case 23 % Corpo -> Aerodinamico
        in_lbl  = {'X','Y','Z'};
        aux_lbl = {'Alfa','Beta','','',''};
        out_lbl = {'Xa','Ya','Za'};
        out_nme = {'Xa','Ya','Za'};
    case 24 % Corpo -> Polar Movel
        in_lbl  = {'X','Y','Z'};
        aux_lbl = {'','','','',''};
        out_lbl = {'Azim.','Elev.','Dist.'};
        out_nme = {'Azimute (°)','Elevação (°)','Distância'};
        
    case 31 % Aerodinamico -> Terrestre Movel
        in_lbl  = {'Xa','Ya','Za'};
        aux_lbl = {'Psi','Teta','Phi','Alfa','Beta'};
        out_lbl = {'Norte','Leste','Baixo'};
        out_nme = {'Norte','Leste','Baixo'};
    case 32 % Aerodinamico -> Corpo
        in_lbl  = {'Xa','Ya','Za'};
        aux_lbl = {'Alfa','Beta','','',''};
        out_lbl = {'X','Y','Z'};
        out_nme = {'X','Y','Z'};
    case 34 % Aerodinamico -> Polar Movel
        in_lbl  = {'Xa','Ya','Za'};
        aux_lbl = {'Alfa','Beta','','',''};
        out_lbl = {'Azim.','Elev.','Dist.'};
        out_nme = {'Azimute (°)','Elevação (°)','Distância'};
        
    case 41 % Polar Movel -> Terrestre Movel
        in_lbl  = {'Azim.','Elev.','Dist.'};
        aux_lbl = {'Psi','Teta','Phi','',''};
        out_lbl = {'Norte','Leste','Baixo'};
        out_nme = {'Norte','Leste','Baixo'};
    case 42 % Polar Movel -> Corpo
        in_lbl  = {'Azim.','Elev.','Dist.'};
        aux_lbl = {'','','','',''};
        out_lbl = {'X','Y','Z'};
        out_nme = {'X','Y','Z'};
    case 43 % Polar Movel -> Aerodinamico
        in_lbl  = {'Azim.','Elev.','Dist.'};
        aux_lbl = {'Alfa','Beta','','',''};
        out_lbl = {'Xa','Ya','Za'};
        out_nme = {'Xa','Ya','Za'};
       
    case 56 % Terrestre Fixo -> Polar Fixo
        in_lbl  = {'DN','DE','H'};
        aux_lbl = {'','','','',''};
        out_lbl = {'Rdl.','Elev.','Dist.'};
        out_nme = {'Radial (°)','Elevação (°)','Distância'};
    case 65 % Polar Fixo -> Terrestre Fixo
        in_lbl  = {'Rdl.','Elev.','Dist.'};
        aux_lbl = {'','','','',''};
        out_lbl = {'DN','DE','H'};
        out_nme = {'DNorte','DLeste','Altura'};
        
    case 78 % PQR -> Euler dot
        in_lbl  = {'P','Q','R'};
        aux_lbl = {'Teta','Phi','','',''};
        out_lbl = {'Psi''','Teta''','Phi'''};
        out_nme = {'Psi'' (°/s)','Teta'' (°/s)','Phi'' (°/s)'};
    case 87 % Euler dot -> PQR
        in_lbl  = {'Psi''','Teta''','Phi'''};
        aux_lbl = {'Teta','Phi','','',''};
        out_lbl = {'P','Q','R'};
        out_nme = {'P (°/s)','Q (°/s)','R (°/s)'};
end

for n = 1:5
    if n < 4
        set(handles.in_txt(n) ,'String',in_lbl{n});
        set(handles.out_txt(n),'String',out_lbl{n});
        set(handles.out(n)    ,'String',out_nme{n});
    end
    if isempty(aux_lbl{n})
        vis = 'off';
    else
        vis = 'on';
    end
    set(handles.aux_txt(n),'String',aux_lbl{n});
    set(handles.aux(n),'Visible',vis);
end

if n_in == 5
    set([handles.deg_chk handles.rad_chk],'Visible','off');
else
    set([handles.deg_chk handles.rad_chk],'Visible','on');
end

% -------------------------------------------------------------------
function calculate(hObject, eventdata, handles)
global DADOS
% Realiza o calculo selecionado

n_in  = find(cell2mat(get(handles.sys_in,'Value')));
n_out = find(cell2mat(get(handles.sys_out,'Value')));

switch 10*n_in + n_out
    
    case 12 % Terrestre Movel -> Corpo
        
        N   = DADOS(:,get(handles.in1,'Value'));
        E   = DADOS(:,get(handles.in2,'Value'));
        D   = DADOS(:,get(handles.in3,'Value'));
        PSI = DADOS(:,get(handles.aux1,'Value'));
        TET = DADOS(:,get(handles.aux2,'Value'));
        PHI = DADOS(:,get(handles.aux3,'Value'));
        
        if get(handles.inv1_in,'Value'), N = -N; end
        if get(handles.inv2_in,'Value'), E = -E; end
        if get(handles.inv3_in,'Value'), D = -D; end
        
        if get(handles.deg_chk,'Value')
            PSI = PSI*pi/180;
            TET = TET*pi/180;
            PHI = PHI*pi/180;
        end
            
        XYZ = earth2body(N,E,D,PSI,TET,PHI);
        
        if get(handles.inv1_out,'Value'), XYZ(:,1) = -XYZ(:,1); end
        if get(handles.inv2_out,'Value'), XYZ(:,2) = -XYZ(:,2); end
        if get(handles.inv3_out,'Value'), XYZ(:,3) = -XYZ(:,3); end
        
        DADOS = [DADOS(:,1:end-1), XYZ, DADOS(:,end)];
        
    case 13 % Terrestre Movel -> Aerodinamico
        
        N   = DADOS(:,get(handles.in1,'Value'));
        E   = DADOS(:,get(handles.in2,'Value'));
        D   = DADOS(:,get(handles.in3,'Value'));
        PSI = DADOS(:,get(handles.aux1,'Value'));
        TET = DADOS(:,get(handles.aux2,'Value'));
        PHI = DADOS(:,get(handles.aux3,'Value'));
        ALF = DADOS(:,get(handles.aux4,'Value'));
        BET = DADOS(:,get(handles.aux5,'Value'));
        
        if get(handles.inv1_in,'Value'), N = -N; end
        if get(handles.inv2_in,'Value'), E = -E; end
        if get(handles.inv3_in,'Value'), D = -D; end
        
        if get(handles.deg_chk,'Value')
            PSI = PSI*pi/180;
            TET = TET*pi/180;
            PHI = PHI*pi/180;
            ALF = ALF*pi/180;
            BET = BET*pi/180;
        end
            
        XYZ = earth2body(N,E,D,PSI,TET,PHI);
        
        XaYaZa = body2aed(XYZ(:,1),XYZ(:,2),XYZ(:,3),ALF,BET);
        
        if get(handles.inv1_out,'Value'), XaYaZa(:,1) = -XaYaZa(:,1); end
        if get(handles.inv2_out,'Value'), XaYaZa(:,2) = -XaYaZa(:,2); end
        if get(handles.inv3_out,'Value'), XaYaZa(:,3) = -XaYaZa(:,3); end

        DADOS = [DADOS(:,1:end-1), XaYaZa, DADOS(:,end)];
        
    case 14 % Terrestre Movel -> Polar Movel
                
        N   = DADOS(:,get(handles.in1,'Value'));
        E   = DADOS(:,get(handles.in2,'Value'));
        D   = DADOS(:,get(handles.in3,'Value'));
        PSI = DADOS(:,get(handles.aux1,'Value'));
        TET = DADOS(:,get(handles.aux2,'Value'));
        PHI = DADOS(:,get(handles.aux3,'Value'));
        
        if get(handles.inv1_in,'Value'), N = -N; end
        if get(handles.inv2_in,'Value'), E = -E; end
        if get(handles.inv3_in,'Value'), D = -D; end
        
        if get(handles.deg_chk,'Value')
            PSI = PSI*pi/180;
            TET = TET*pi/180;
            PHI = PHI*pi/180;
        end
            
        XYZ = earth2body(N,E,D,PSI,TET,PHI);
        
        Az =  atan2(XYZ(:,2),XYZ(:,1))*180/pi;
        El = -atan2(XYZ(:,3),sqrt(XYZ(:,1).^2+XYZ(:,2).^2))*180/pi;
        D  =  sqrt(XYZ(:,1).^2 + XYZ(:,2).^2 + XYZ(:,3).^2);
        
        if get(handles.inv1_out,'Value'), Az = -Az; end
        if get(handles.inv2_out,'Value'), El = -El; end
        if get(handles.inv3_out,'Value'), D  = -D ; end
        
        DADOS = [DADOS(:,1:end-1), Az, El, D, DADOS(:,end)];
        
        
    case 21 % Corpo -> Terrestre Movel
        
        X   = DADOS(:,get(handles.in1,'Value'));
        Y   = DADOS(:,get(handles.in2,'Value'));
        Z   = DADOS(:,get(handles.in3,'Value'));
        PSI = DADOS(:,get(handles.aux1,'Value'));
        TET = DADOS(:,get(handles.aux2,'Value'));
        PHI = DADOS(:,get(handles.aux3,'Value'));
        
        if get(handles.inv1_in,'Value'), X = -X; end
        if get(handles.inv2_in,'Value'), Y = -Y; end
        if get(handles.inv3_in,'Value'), Z = -Z; end
        
        if get(handles.deg_chk,'Value')
            PSI = PSI*pi/180;
            TET = TET*pi/180;
            PHI = PHI*pi/180;
        end
            
        NED = body2earth(X,Y,Z,PSI,TET,PHI);

        if get(handles.inv1_out,'Value'), NED(:,1) = -NED(:,1); end
        if get(handles.inv2_out,'Value'), NED(:,2) = -NED(:,2); end
        if get(handles.inv3_out,'Value'), NED(:,3) = -NED(:,3); end

        DADOS = [DADOS(:,1:end-1), NED, DADOS(:,end)];
        
    case 23 % Corpo -> Aerodinamico
        
        X   = DADOS(:,get(handles.in1,'Value'));
        Y   = DADOS(:,get(handles.in2,'Value'));
        Z   = DADOS(:,get(handles.in3,'Value'));
        ALF = DADOS(:,get(handles.aux1,'Value'));
        BET = DADOS(:,get(handles.aux2,'Value'));
        
        if get(handles.inv1_in,'Value'), X = -X; end
        if get(handles.inv2_in,'Value'), Y = -Y; end
        if get(handles.inv3_in,'Value'), Z = -Z; end
        
        if get(handles.deg_chk,'Value')
            ALF = ALF*pi/180;
            BET = BET*pi/180;
        end
            
        XaYaZa = body2aed(X,Y,Z,ALF,BET);
        
        if get(handles.inv1_out,'Value'), XaYaZa(:,1) = -XaYaZa(:,1); end
        if get(handles.inv2_out,'Value'), XaYaZa(:,2) = -XaYaZa(:,2); end
        if get(handles.inv3_out,'Value'), XaYaZa(:,3) = -XaYaZa(:,3); end

        DADOS = [DADOS(:,1:end-1), XaYaZa, DADOS(:,end)];
        
    case 24 % Corpo -> Polar Movel
         
        X  = DADOS(:,get(handles.in1,'Value'));
        Y  = DADOS(:,get(handles.in2,'Value'));
        Z  = DADOS(:,get(handles.in3,'Value'));
        
        if get(handles.inv1_in,'Value'), X = -X; end
        if get(handles.inv2_in,'Value'), Y = -Y; end
        if get(handles.inv3_in,'Value'), Z = -Z; end
        
        Az = 180/pi*atan2(Y,X);
        El = 180/pi*atan2(-Z,sqrt(X.^2 + Y.^2));
        D  = sqrt(X.^2 + Y.^2 + Z.^2);
        
        if get(handles.inv1_out,'Value'), Az = -Az; end
        if get(handles.inv2_out,'Value'), El = -El;  end
        if get(handles.inv3_out,'Value'), D  = -D ; end

        DADOS = [DADOS(:,1:end-1), Az, El, D, DADOS(:,end)];
       
        
    case 31 % Aerodinamico -> Terrestre Movel

        Xa  = DADOS(:,get(handles.in1,'Value'));
        Ya  = DADOS(:,get(handles.in2,'Value'));
        Za  = DADOS(:,get(handles.in3,'Value'));
        PSI = DADOS(:,get(handles.aux1,'Value'));
        TET = DADOS(:,get(handles.aux2,'Value'));
        PHI = DADOS(:,get(handles.aux3,'Value'));
        ALF = DADOS(:,get(handles.aux4,'Value'));
        BET = DADOS(:,get(handles.aux5,'Value'));
        
        if get(handles.inv1_in,'Value'), Xa = -Xa; end
        if get(handles.inv2_in,'Value'), Ya = -Ya; end
        if get(handles.inv3_in,'Value'), Za = -Za; end
        
        if get(handles.deg_chk,'Value')
            PSI = PSI*pi/180;
            TET = TET*pi/180;
            PHI = PHI*pi/180;
            ALF = ALF*pi/180;
            BET = BET*pi/180;
        end
        
        XYZ = aed2body(Xa,Ya,Za,ALF,BET);
            
        NED = body2earth(XYZ(:,1),XYZ(:,2),XYZ(:,3),PSI,TET,PHI);
        
        if get(handles.inv1_out,'Value'), NED(:,1) = -NED(:,1); end
        if get(handles.inv2_out,'Value'), NED(:,2) = -NED(:,2); end
        if get(handles.inv3_out,'Value'), NED(:,3) = -NED(:,3); end

        DADOS = [DADOS(:,1:end-1), NED, DADOS(:,end)];
        
    case 32 % Aerodinamico -> Corpo
        
        Xa  = DADOS(:,get(handles.in1,'Value'));
        Ya  = DADOS(:,get(handles.in2,'Value'));
        Za  = DADOS(:,get(handles.in3,'Value'));
        ALF = DADOS(:,get(handles.aux1,'Value'));
        BET = DADOS(:,get(handles.aux2,'Value'));
        
        if get(handles.inv1_in,'Value'), Xa = -Xa; end
        if get(handles.inv2_in,'Value'), Ya = -Ya; end
        if get(handles.inv3_in,'Value'), Za = -Za; end
        
        if get(handles.deg_chk,'Value')
            ALF = ALF*pi/180;
            BET = BET*pi/180;
        end
            
        XYZ = aed2body(Xa,Ya,Za,ALF,BET);
        
        if get(handles.inv1_out,'Value'), XYZ(:,1) = -XYZ(:,1); end
        if get(handles.inv2_out,'Value'), XYZ(:,2) = -XYZ(:,2); end
        if get(handles.inv3_out,'Value'), XYZ(:,3) = -XYZ(:,3); end
        
        DADOS = [DADOS(:,1:end-1), XYZ, DADOS(:,end)];
        
    case 34 % Aerodinamico -> Polar Movel
        
        Xa  = DADOS(:,get(handles.in1,'Value'));
        Ya  = DADOS(:,get(handles.in2,'Value'));
        Za  = DADOS(:,get(handles.in3,'Value'));
        ALF = DADOS(:,get(handles.aux1,'Value'));
        BET = DADOS(:,get(handles.aux2,'Value'));
        
        if get(handles.inv1_in,'Value'), Xa = -Xa; end
        if get(handles.inv2_in,'Value'), Ya = -Ya; end
        if get(handles.inv3_in,'Value'), Za = -Za; end
        
        if get(handles.deg_chk,'Value')
            ALF = ALF*pi/180;
            BET = BET*pi/180;
        end
            
        XYZ = aed2body(Xa,Ya,Za,ALF,BET);
        
        Az =  atan2(XYZ(:,2),XYZ(:,1))*180/pi;
        El = -atan2(XYZ(:,3),sqrt(XYZ(:,1).^2+XYZ(:,2).^2))*180/pi;
        D  =  sqrt(XYZ(:,1).^2 + XYZ(:,2).^2 + XYZ(:,3).^2);
        
        if get(handles.inv1_out,'Value'), Az = -Az; end
        if get(handles.inv2_out,'Value'), El = -El; end
        if get(handles.inv3_out,'Value'), D  = -D ; end
        
        DADOS = [DADOS(:,1:end-1), Az, El, D, DADOS(:,end)];
        
    case 41 % Polar Movel -> Terrestre Movel
        
        Az  = DADOS(:,get(handles.in1,'Value'));
        El  = DADOS(:,get(handles.in2,'Value'));
        D   = DADOS(:,get(handles.in3,'Value'));
        PSI = DADOS(:,get(handles.aux1,'Value'));
        TET = DADOS(:,get(handles.aux2,'Value'));
        PHI = DADOS(:,get(handles.aux3,'Value'));

        if get(handles.inv1_in,'Value'), Az = -Az; end
        if get(handles.inv2_in,'Value'), El = -El; end
        if get(handles.inv3_in,'Value'), D  = -D;  end
        
        if get(handles.deg_chk,'Value')
            PSI = PSI*pi/180;
            TET = TET*pi/180;
            PHI = PHI*pi/180;
            Az  = Az*pi/180;
            El  = El*pi/180;
        end
        
        X =  D.*cos(El).*cos(Az);
        Y =  D.*cos(El).*sin(Az);
        Z = -D.*sin(El);
        
        NED = body2earth(X,Y,Z,PSI,TET,PHI);

        if get(handles.inv1_out,'Value'), NED(:,1) = -NED(:,1); end
        if get(handles.inv2_out,'Value'), NED(:,2) = -NED(:,2); end
        if get(handles.inv3_out,'Value'), NED(:,3) = -NED(:,3); end

        DADOS = [DADOS(:,1:end-1), NED, DADOS(:,end)];
        
    case 42 % Polar Movel -> Corpo
        
        Az  = DADOS(:,get(handles.in1,'Value'));
        El  = DADOS(:,get(handles.in2,'Value'));
        D   = DADOS(:,get(handles.in3,'Value'));
        
        if get(handles.inv1_in,'Value'), Az = -Az; end
        if get(handles.inv2_in,'Value'), El = -El; end
        if get(handles.inv3_in,'Value'), D  = -D;  end
        
        if get(handles.deg_chk,'Value')
            Az = Az*pi/180;
            El = El*pi/180;
        end
        
        X =  D.*cos(El).*cos(Az);
        Y =  D.*cos(El).*sin(Az);
        Z = -D.*sin(El);
        
        if get(handles.inv1_out,'Value'), X = -X; end
        if get(handles.inv2_out,'Value'), Y = -Y; end
        if get(handles.inv3_out,'Value'), Z = -Z; end
        
        DADOS = [DADOS(:,1:end-1), X, Y, Z, DADOS(:,end)];
        
    case 43 % Polar Movel -> Aerodinamico
        
        Az  = DADOS(:,get(handles.in1,'Value'));
        El  = DADOS(:,get(handles.in2,'Value'));
        D   = DADOS(:,get(handles.in3,'Value'));
        ALF = DADOS(:,get(handles.aux1,'Value'));
        BET = DADOS(:,get(handles.aux2,'Value'));
        
        if get(handles.inv1_in,'Value'), Az = -Az; end
        if get(handles.inv2_in,'Value'), El = -El; end
        if get(handles.inv3_in,'Value'), D  = -D;  end
        
        if get(handles.deg_chk,'Value')
            Az = Az*pi/180;
            El = El*pi/180;
            ALF = ALF*pi/180;
            BET = BET*pi/180;
        end
        
        X =  D.*cos(El).*cos(Az);
        Y =  D.*cos(El).*sin(Az);
        Z = -D.*sin(El);
            
        XaYaZa = body2aed(X,Y,Z,ALF,BET);
        
        if get(handles.inv1_out,'Value'), XaYaZa(:,1) = -XaYaZa(:,1); end
        if get(handles.inv2_out,'Value'), XaYaZa(:,2) = -XaYaZa(:,2); end
        if get(handles.inv3_out,'Value'), XaYaZa(:,3) = -XaYaZa(:,3); end

        DADOS = [DADOS(:,1:end-1), XaYaZa, DADOS(:,end)];
        

    case 56 % Terrestre Fixo -> Polar Fixo
         
        DN  = DADOS(:,get(handles.in1,'Value'));
        DE  = DADOS(:,get(handles.in2,'Value'));
        H   = DADOS(:,get(handles.in3,'Value'));
        
        if get(handles.inv1_in,'Value'), DN = -DN; end
        if get(handles.inv2_in,'Value'), DE = -DE; end
        if get(handles.inv3_in,'Value'), H  = -H;  end
        
        D  = sqrt(DN.^2 + DE.^2 + H.^2);
        Az = mod(180/pi*atan2(DE,DN),360);
        El = 180/pi*atan2(H,sqrt(DN.^2 + DE.^2));
        
        if get(handles.inv1_out,'Value'), D  = -D ; end
        if get(handles.inv2_out,'Value'), Az = -Az; end
        if get(handles.inv3_out,'Value'), El = -El;  end
        
        DADOS = [DADOS(:,1:end-1), Az, El, D, DADOS(:,end)];
       
    case 65 % Polar Fixo -> Terrestre Fixo
        
        Az  = DADOS(:,get(handles.in1,'Value'));
        El  = DADOS(:,get(handles.in2,'Value'));
        D   = DADOS(:,get(handles.in3,'Value'));
        
        if get(handles.inv1_in,'Value'), Az = -Az; end
        if get(handles.inv2_in,'Value'), El = -El; end
        if get(handles.inv3_in,'Value'), D  = -D;  end
        
        if get(handles.deg_chk,'Value')
            Az = Az*pi/180;
            El = El*pi/180;
        end
        
        DN = D.*cos(El).*cos(Az);
        DE = D.*cos(El).*sin(Az);
        H  = D.*sin(El);
        
        if get(handles.inv1_out,'Value'), DN = -DN; end
        if get(handles.inv2_out,'Value'), DE = -DE; end
        if get(handles.inv3_out,'Value'), H  = -H ; end
        
        DADOS = [DADOS(:,1:end-1), DN, DE, H, DADOS(:,end)];
        
        
    case 78 % PQR -> Euler dot
        
        P   = DADOS(:,get(handles.in1,'Value'));
        Q   = DADOS(:,get(handles.in2,'Value'));
        R   = DADOS(:,get(handles.in3,'Value'));
        TET = DADOS(:,get(handles.aux1,'Value'));
        PHI = DADOS(:,get(handles.aux2,'Value'));
        
        if get(handles.inv1_in,'Value'), P = -P; end
        if get(handles.inv2_in,'Value'), Q = -Q; end
        if get(handles.inv3_in,'Value'), R = -R; end
        
        if get(handles.deg_chk,'Value')
            TET = TET*pi/180;
            PHI = PHI*pi/180;
        end
            
        EULERdot = pqr2eulerdot(P,Q,R,TET,PHI);
        
        if get(handles.inv1_out,'Value'), EULERdot(:,1) = -EULERdot(:,1); end
        if get(handles.inv2_out,'Value'), EULERdot(:,2) = -EULERdot(:,2); end
        if get(handles.inv3_out,'Value'), EULERdot(:,3) = -EULERdot(:,3); end

        DADOS = [DADOS(:,1:end-1), EULERdot, DADOS(:,end)];
        
    case 87 % Euler dot -> PQR

        PSIdot = DADOS(:,get(handles.in1,'Value'));
        TETdot = DADOS(:,get(handles.in2,'Value'));
        PHIdot = DADOS(:,get(handles.in3,'Value'));
        TET    = DADOS(:,get(handles.aux1,'Value'));
        PHI    = DADOS(:,get(handles.aux2,'Value'));
        
        if get(handles.inv1_in,'Value'), PSIdot = -PSIdot; end
        if get(handles.inv2_in,'Value'), TETdot = -TETdot; end
        if get(handles.inv3_in,'Value'), PHIdot = -PHIdot; end
        
        if get(handles.deg_chk,'Value')
            TET = TET*pi/180;
            PHI = PHI*pi/180;
        end
            
        PQR = eulerdot2pqr(PSIdot,TETdot,PHIdot,TET,PHI);
        
        if get(handles.inv1_out,'Value'), PQR(:,1) = -PQR(:,1); end
        if get(handles.inv2_out,'Value'), PQR(:,2) = -PQR(:,2); end
        if get(handles.inv3_out,'Value'), PQR(:,3) = -PQR(:,3); end

        DADOS = [DADOS(:,1:end-1), PQR, DADOS(:,end)];
end

% -------------------------------------------------------------------
function XYZ = aed2body(Xa,Ya,Za,ALF,BET)
% Conversão do sistema aerodinamico para o do corpo

XYZ = zeros(length(Xa),3);

for n = 1:length(Xa)
    
    R = [cos(ALF(n))*cos(BET(n)) -cos(ALF(n))*sin(BET(n)) -sin(ALF(n)) ;
        sin(BET(n))               cos(BET(n))                 0        ;
        sin(ALF(n))*cos(BET(n))  -sin(ALF(n))*sin(BET(n)) cos(ALF(n))  ];
    
    XYZ(n,:) = (R * [Xa(n); Ya(n); Za(n)] )';
    
end

% -------------------------------------------------------------------
function XaYaZa = body2aed(X,Y,Z,ALF,BET)
% Conversão do sistema do corpo para o aerodinamico

XaYaZa = zeros(length(X),3);

for n = 1:length(X)
    
    R = [cos(ALF(n))*cos(BET(n)) -cos(ALF(n))*sin(BET(n)) -sin(ALF(n)) ;
        sin(BET(n))               cos(BET(n))                 0        ;
        sin(ALF(n))*cos(BET(n))  -sin(ALF(n))*sin(BET(n)) cos(ALF(n))  ];
    
    XaYaZa(n,:) = (R' * [X(n); Y(n); Z(n)] )';
    
end

% -------------------------------------------------------------------
function XYZ = earth2body(N,E,D,PSI,TET,PHI)
% Conversão do sistema terrestre móvel para o do corpo

XYZ = zeros(length(N),3);

for n = 1:length(N)
    
    R = [cos(TET(n))*cos(PSI(n))                                     cos(TET(n))*sin(PSI(n))                                     -sin(TET(n))             ;
        sin(PHI(n))*sin(TET(n))*cos(PSI(n))-cos(PHI(n))*sin(PSI(n))  cos(PHI(n))*cos(PSI(n))+sin(PHI(n))*sin(TET(n))*sin(PSI(n))  sin(PHI(n))*cos(TET(n)) ;
        sin(PHI(n))*sin(PSI(n))+cos(PHI(n))*sin(TET(n))*cos(PSI(n))  cos(PHI(n))*sin(TET(n))*sin(PSI(n))-sin(PHI(n))*cos(PSI(n))  cos(PHI(n))*cos(TET(n)) ];
    
    XYZ(n,:) = (R * [N(n); E(n); D(n)] )';
    
end

% -------------------------------------------------------------------
function NED = body2earth(X,Y,Z,PSI,TET,PHI)
% Conversão do sistema do corpo para o terrestre móvel

NED = zeros(length(X),3);

for n = 1:length(X)
    
    R = [cos(TET(n))*cos(PSI(n))                                     cos(TET(n))*sin(PSI(n))                                     -sin(TET(n))             ;
        sin(PHI(n))*sin(TET(n))*cos(PSI(n))-cos(PHI(n))*sin(PSI(n))  cos(PHI(n))*cos(PSI(n))+sin(PHI(n))*sin(TET(n))*sin(PSI(n))  sin(PHI(n))*cos(TET(n)) ;
        sin(PHI(n))*sin(PSI(n))+cos(PHI(n))*sin(TET(n))*cos(PSI(n))  cos(PHI(n))*sin(TET(n))*sin(PSI(n))-sin(PHI(n))*cos(PSI(n))  cos(PHI(n))*cos(TET(n)) ];
    
    NED(n,:) = (R' * [X(n); Y(n); Z(n)] )';
    
end

% -------------------------------------------------------------------
function PQR = eulerdot2pqr(PSIdot,TETdot,PHIdot,TET,PHI)
% Conversão das derivadas dos angulos de Euler para as velocidades angulares

PQR = zeros(length(PSIdot),3);

for n = 1:length(PSIdot)
    
    R = [1  0           -sin(TET(n))             ;
        0   cos(PHI(n))  sin(PHI(n))*cos(TET(n)) ;
        0  -sin(PHI(n))  cos(PHI(n))*cos(TET(n)) ];
    
    PQR(n,:) = (R * [ PHIdot(n); TETdot(n); PSIdot(n) ] )';
    
end

% -------------------------------------------------------------------
function EULERdot = pqr2eulerdot(P,Q,R,TET,PHI)
% Conversão das velocidades angulares para as derivadas dos angulos de Euler

EULERdot = zeros(length(P),3);

for n = 1:length(P)
    
    RR = [1 sin(PHI(n))*tan(TET(n))  cos(PHI(n))*tan(TET(n)) ;
        0   cos(PHI(n))             -sin(PHI(n))             ;
        0   sin(PHI(n))*sec(TET(n))  cos(PHI(n))*sec(TET(n)) ];
    
    EULERdot(n,:) = (RR * [P(n); Q(n); R(n)] )';
    
end

EULERdot = fliplr(EULERdot);
