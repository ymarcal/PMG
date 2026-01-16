function varargout = RDAT_XMLParamSel(varargin)
% RDAT_XMLPARAMSEL M-file for RDAT_XMLParamSel.fig
% Last Modified by GUIDE v2.5 07-Dec-2010 12:57:28

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RDAT_XMLParamSel_OpeningFcn, ...
                   'gui_OutputFcn',  @RDAT_XMLParamSel_OutputFcn, ...
                   'gui_LayoutFcn',  @RDAT_XMLParamSel_LayoutFcn, ...
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

% ---------------------------------------------------------------
function h = RDAT_XMLParamSel_LayoutFcn(varargin)
% Função de layout inicial

h = openfig('RDAT_XMLParamSel.fig','reuse','invisible');

% -------------------------------------------------------------------
function RDAT_XMLParamSel_OpeningFcn(hObject, eventdata, handles, varargin)
global N T
% Funçao de inicializaçao

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
set(handles.Nsel,'BackgroundColor',get(handles.window,'Color'));

bgc = getbuttoncolor(handles.window);
set(handles.help_btn,'CData',geticon('DatButtons.mat','help',bgc));

N = 0;
T = clock;

handles.lists  = [handles.AC_list handles.RDR_list handles.WPN_list handles.NAV_list handles.HMD_list handles.LDP_list handles.EO_list handles.ENG_list];
handles.checks = [handles.AC_chk  handles.RDR_chk  handles.WPN_chk  handles.NAV_chk  handles.HMD_chk  handles.LDP_chk  handles.EO_chk  handles.ENG_chk];
handles.adds   = [handles.AC_add  handles.RDR_add  handles.WPN_add  handles.NAV_add  handles.HMD_add  handles.LDP_add  handles.EO_add  handles.ENG_add];
handles.rems   = [handles.AC_rem  handles.RDR_rem  handles.WPN_rem  handles.NAV_rem  handles.HMD_rem  handles.LDP_rem  handles.EO_rem  handles.ENG_rem];

handles.ok = 0;
handles.Y = '»';
handles.N = ' ';

handles.AC_param = {
    'UTC'       ; 'Nor_Vel'  ; 'East_Vel'  ; 'Down_Vel' ; 'LAT'       ; 'Long'      ; 'Nx_Accel'  ; 'Ny_Accel'   ; 'Nz_Accel' ;
    'Nor_Accel' ; 'Mag_Head' ; 'Roll'      ; 'Pitch'    ; 'True_Head' ; 'Gnd_Track' ; 'Roll_Rate' ; 'Pitch_Rate' ; 'Yaw_Rate' ;
    'TAS'       ; 'CAS'      ; 'Gnd_Speed' ; 'MACH'     ; 'True_AOA'  ; 'Indi_AOA'  ; 'Corr_Alt'  ; 'SYS_Alt'    ; 'BARO_Alt' ;
    'RALT_Alt'  ; 'Wind_Mag' ; 'Wind_Dir'  ; 'MS_Mode'  ; 'AC_Mode'   ; 'FOM'       ; 'Fuel'      };
handles.AC_units = {
    'sec'       ; 'kt'       ; 'kt'        ; 'kt'       ; 'SemiCircl' ; 'SemiCircl' ; 'm/s²'      ; 'm/s²'       ; 'm/s²'     ;
    'g'         ; 'deg'      ; 'deg'       ; 'deg'      ; 'deg'       ; 'deg'       ; 'deg/sec'   ; 'deg/sec'    ; 'deg/sec'  ;
    'kt'        ; 'kt'       ; 'kt'        ; ''         ; 'deg'       ; 'deg'       ; 'ft'        ; 'ft'         ; 'ft'       ;
    'ft'        ; 'kt'       ; 'deg'       ; ''         ; ''          ; ''          ; 'lb'        };

handles.RDR_param = {
    'RDR_State'    ; 'RDR_Mode'         ; 'RDR_Lock'      ; 'HPT_Rng'      ; 'HPT_Az'       ; 'HPT_Elev'         ; 'HPT_Heading'  ;
    'HPT_Altitude' ; 'HPT_Aspect'       ; 'HPT_North_Vel' ; 'HPT_East_Vel' ; 'HPT_Down_Vel' ; 'HPT_Closure_Rate' ; 'SPT_Rng'      ;
    'SPT_Az'       ; 'SPT_Elev'         ; 'SPT_Heading'   ; 'SPT_Alt'      ; 'SPT_Aspect'   ; 'SPT_North_Vel'    ; 'SPT_East_Vel' ;
    'SPT_Down_Vel' ; 'SPT_Closure_Rate' ; 'Slant_Range'   };
handles.RDR_units = {
    ''             ; ''                 ; ''              ; 'ft'           ; 'deg'          ; 'deg'              ; 'deg'          ;
    'ft'           ; 'deg'              ; 'kt'            ; 'kt'           ; 'kt'           ; 'kt'               ; 'ft'           ;
    'deg'          ; 'deg'              ; 'deg'           ; 'ft'           ; 'deg'          ; 'kt'               ; 'kt'           ;
    'kt'           ; 'kt'               ; 'ft'            };

handles.WPN_param = {
    'Cage_STS'         ; 'Slaving_Source'    ; 'Gun_Sight_Type'    ; 'Pipper_AZ'          ; 'Pipper_Elev'      ; 'IR_Seek_AZ'       ;
    'IR_Seek_Elev'     ; 'RDR_MSL_Status'    ; 'RDR_TGT_Range'     ; 'RDR_TGT_AZ'         ; 'RDR_TGT_Elev'     ; 'RDR_TGT_Alt'      ;
    'RDR_TGT_Heading'  ; 'RDR_TGT_North_Vel' ; 'RDR_TGT_East_Vel'  ; 'RDR_TGT_Down_Vel'   ; 'RDR_Closure_Rate' ; 'DLZ_MAX_Range'    ; 
    'DLZ_NO_Esc_Range' ; 'DLZ_MIN_Range'     ; 'ASE_Circle_Radius' ; 'ASE_AIM_DOT_Radius' ; 'ASE_AIM_DOT_AZ'   ; 'ASE_AIM_DOT_Elev' ;
    'DSR_Range'        };
handles.WPN_units = {
    ''                 ; ''                  ; ''                  ; 'mr'                 ; 'mr'               ; 'mr'               ;
    'mr'               ; ''                  ; 'ft'                ; 'deg'                ; 'deg'              ; 'ft'               ;
    'deg'              ; 'ft/s'              ; 'ft/s'              ; 'ft/s'               ; 'kt'               ; 'NM'               ; 
    'NM'               ; 'NM'                ; 'mr'                ; 'mr'                 ; 'deg'              ; 'deg'              ;
    'NM'               };

handles.NAV_param = {
    'SWP_Num'   ; 'SWP_Long'    ; 'SWP_Lat'   ; 'SWP_Bearing' ; 'FYT_Long'  ;
    'FYT_Lat'   ; 'SPOI_Source' ; 'SPOI_Lat'  ; 'SPOI_Long'   ; 'Route_Num' };
handles.NAV_units = {
    ''          ; 'SemiCircl'   ; 'SemiCircl' ; 'deg'         ; 'SemiCircl' ;
    'SemiCircl' ; ''            ; 'SemiCircl' ; 'SemiCircl'   ; ''          };

handles.HMD_param = {
  'FWD_HMD_Stat' ; 'FWD_HMD_AZ' ; 'FWD_HMD_Elev' ; 'FWD_HMD_Roll' ;
  'AFT_HMD_Stat' ; 'AFT_HMD_AZ' ; 'AFT_HMD_Elev' ; 'AFT_HMD_Roll' };
handles.HMD_units = {
  ''             ; 'deg'        ; 'deg'          ; 'deg'          ;
  ''             ; 'deg'        ; 'deg'          ; 'deg'          };

handles.LDP_param = {
    'LDP_Mode' ; 'LDP_SMode' ; 'LDP_FOV' ; 'Camera'   ; 'Laser'     ; 'LSR_STS'   ; 'LSR_Mode'   ;
    'LSR_Code' ; 'LOS_AZ'    ; 'LOS_EL'  ; 'LOS_Roll' ; 'TGT_LAT'   ; 'TGT_LON'   ; 'TGT_SRange' };
handles.LDP_units = {
    ''         ; ''          ; ''        ; ''         ; ''          ; ''          ; ''           ;
    ''         ; 'deg'       ; 'deg'     ; 'deg'      ; 'SemiCircl' ; 'SemiCircl' ; 'ft'         };

handles.EO_param = {'EO_Mode' ; 'Seeker_AZ' ; 'Seeker_EL' ; 'Station' };
handles.EO_units = {''        ; 'deg'       ; 'deg'       ; ''        };

handles.ENG_param = {
    'UTC'        ; 'RPM_L'    ; 'RPM_R'        ; 'EGT_L'          ; 'EGT_R'       ; 'NOZ_L'       ; 'NOZ_R'      ; 'OILP_L'       ; 'OILP_R' ;
    'Total_Fuel' ; 'INT_Fuel' ; 'EXT_INB_Fuel' ; 'EXT_CNTRL_Fuel' ; 'Fuel_Flow_L' ; 'Fuel_Flow_R' ; 'UTIL_Press' ; 'Flight_Press'; 'NH';'NL';'TGT';'Total_Fuel';'Fuselage_Fuel';'Left_Wing_Fuel';'Right_Wing_Fuel';'Left_Pylon_Fuel';'Right_Pylon_Fuel';'Fuel_Flow';'Hyd_1_Press';'Hyd_2_Press'};
handles.ENG_units = {
    'sec'        ; '%'        ; '%'            ; '°C'             ; '°C'          ; '%'           ; '%'          ; 'PSI'          ; 'PSI'    ;
    'lb'         ; 'lb'       ; 'lb'           ; 'lb'             ; 'lb/h'        ; 'lb/h'        ; 'PSI'        ; 'PSI'    ;'%';'%';'°C';'kg';'kg';'kg';'kg';'kg';'kg';'kg/min';'PSI';'PSI'};


AC  = ones( size( handles.AC_param , 1), 1);
RDR = ones( size( handles.RDR_param, 1), 1);
WPN = ones( size( handles.WPN_param, 1), 1);
NAV = ones( size( handles.NAV_param, 1), 1);
HMD = ones( size( handles.HMD_param, 1), 1);
LDP = ones( size( handles.LDP_param, 1), 1);
EO  = ones( size( handles.EO_param , 1), 1);
ENG = ones( size( handles.ENG_param, 1), 1);

set(handles.AC_list, 'String',[char(abs(handles.Y)*AC)  blanks(length(AC))'  char(handles.AC_param) ], 'UserData', AC);
set(handles.RDR_list,'String',[char(abs(handles.Y)*RDR) blanks(length(RDR))' char(handles.RDR_param)], 'UserData', RDR);
set(handles.WPN_list,'String',[char(abs(handles.Y)*WPN) blanks(length(WPN))' char(handles.WPN_param)], 'UserData', WPN);
set(handles.NAV_list,'String',[char(abs(handles.Y)*NAV) blanks(length(NAV))' char(handles.NAV_param)], 'UserData', NAV);
set(handles.HMD_list,'String',[char(abs(handles.Y)*HMD) blanks(length(HMD))' char(handles.HMD_param)], 'UserData', HMD);
set(handles.LDP_list,'String',[char(abs(handles.Y)*LDP) blanks(length(LDP))' char(handles.LDP_param)], 'UserData', LDP);
set(handles.EO_list, 'String',[char(abs(handles.Y)*EO)  blanks(length(EO))'  char(handles.EO_param) ], 'UserData', EO);
set(handles.ENG_list,'String',[char(abs(handles.Y)*ENG) blanks(length(ENG))' char(handles.ENG_param)], 'UserData', ENG);

set(handles.Nsel,'String',num2str(sum([AC; RDR; WPN; NAV; HMD; LDP; EO; ENG])));

guidata(hObject, handles);

% Initial settings
set([handles.AC_chk],'Value',1);
set([handles.RDR_chk handles.WPN_chk handles.NAV_chk handles.HMD_chk handles.LDP_chk handles.EO_chk handles.ENG_chk],'Value',0);
AC_chk_Callback(hObject, eventdata, handles);
RDR_chk_Callback(hObject, eventdata, handles);
WPN_chk_Callback(hObject, eventdata, handles);
NAV_chk_Callback(hObject, eventdata, handles);
HMD_chk_Callback(hObject, eventdata, handles);
LDP_chk_Callback(hObject, eventdata, handles);
EO_chk_Callback(hObject,  eventdata, handles);
ENG_chk_Callback(hObject, eventdata, handles);

uiwait(handles.window);

% -------------------------------------------------------------------
function varargout = RDAT_XMLParamSel_OutputFcn(hObject, eventdata, handles)
% Funçao de saida

if handles.ok
    
    AC  = get(handles.AC_list, 'UserData') == 1;
    RDR = get(handles.RDR_list,'UserData') == 1;
    WPN = get(handles.WPN_list,'UserData') == 1;
    NAV = get(handles.NAV_list,'UserData') == 1;
    HMD = get(handles.HMD_list,'UserData') == 1;
    LDP = get(handles.LDP_list,'UserData') == 1;
    EO  = get(handles.EO_list, 'UserData') == 1;
    ENG = get(handles.ENG_list,'UserData') == 1;
    
    if get(handles.F5M_sel,'Value')
        opt.acft = 'F5M';
    else
        opt.acft = 'A29';
        RDR = false & RDR;
        WPN = false & WPN;
        NAV = false & NAV;
        HMD = false & HMD;
        LDP = false & LDP;
        EO  = false & EO;
        ENG = false & ENG;
    end
    
    opt.auxm = get(handles.auxm_chk,'Value');
    opt.play = get(handles.play_chk,'Value');
    opt.evts = get(handles.evts_chk,'Value');
    opt.scen = get(handles.scen_chk,'Value');
    opt.fnum = get(handles.fnum_chk,'Value');
    
    PARAM = char(char(handles.AC_param{AC}),...
        char(handles.RDR_param{RDR}),...
        char(handles.WPN_param{WPN}),...
        char(handles.NAV_param{NAV}),...
        char(handles.HMD_param{HMD}),...
        char(handles.LDP_param{LDP}),...
        char(handles.EO_param{EO}) );

    UNITS = char(char(handles.AC_units{AC}),...
        char(handles.RDR_units{RDR}),...
        char(handles.WPN_units{WPN}),...
        char(handles.NAV_units{NAV}),...
        char(handles.HMD_units{HMD}),...
        char(handles.LDP_units{LDP}),...
        char(handles.EO_units{EO} ));
    
    PARAM2 = char(handles.ENG_param{ENG});
    
    UNITS2 = char(handles.ENG_units{ENG});
    
    for n = size(PARAM,1) : -1 : 1
        if isempty(deblank(PARAM(n,:)))
            PARAM(n,:) = [];
            UNITS(n,:) = [];
        end
    end

    for n = size(PARAM2,1) : -1 : 1
        if isempty(deblank(PARAM2(n,:)))
            PARAM2(n,:) = [];
            UNITS2(n,:) = [];
        end
    end

    varargout{1} = PARAM;
    varargout{2} = UNITS;
    varargout{3} = PARAM2;
    varargout{4} = UNITS2;
    varargout{5} = opt;
else
    varargout{1} = [];
    varargout{2} = [];
    varargout{3} = [];
    varargout{4} = [];
    varargout{5} = [];
end
delete(handles.window);

% -------------------------------------------------------------------
% -------------------------------------------------------------------
function AC_chk_Callback(hObject, eventdata, handles)
% Incluir todos os parametros de voo e da aeronave

AC = ones( size( handles.AC_param , 1), 1);
if get(handles.AC_chk,'Value')
    set(handles.AC_list, 'String',[char(abs(handles.Y)*AC)  blanks(length(AC))'  char(handles.AC_param) ], 'UserData',  AC);
else
    set(handles.AC_list, 'String',[blanks(length(AC))'      blanks(length(AC))'  char(handles.AC_param) ], 'UserData', ~AC);
end
update_Npar(hObject, eventdata, handles);

% -------------------------------------------------------------------
function RDR_chk_Callback(hObject, eventdata, handles)
% Incluir todos os parametros do radar

RDR = ones( size( handles.RDR_param , 1), 1);
if get(handles.RDR_chk,'Value')
    set(handles.RDR_list, 'String',[char(abs(handles.Y)*RDR)  blanks(length(RDR))'  char(handles.RDR_param) ], 'UserData',  RDR);
else
    set(handles.RDR_list, 'String',[blanks(length(RDR))'      blanks(length(RDR))'  char(handles.RDR_param) ], 'UserData', ~RDR);
end
update_Npar(hObject, eventdata, handles);

% -------------------------------------------------------------------
function WPN_chk_Callback(hObject, eventdata, handles)
% Incluir todos os parametros de armamento

WPN = ones( size( handles.WPN_param , 1), 1);
if get(handles.WPN_chk,'Value')
    set(handles.WPN_list, 'String',[char(abs(handles.Y)*WPN)  blanks(length(WPN))'  char(handles.WPN_param) ], 'UserData',  WPN);
else
    set(handles.WPN_list, 'String',[blanks(length(WPN))'      blanks(length(WPN))'  char(handles.WPN_param) ], 'UserData', ~WPN);
end
update_Npar(hObject, eventdata, handles);

% -------------------------------------------------------------------
function NAV_chk_Callback(hObject, eventdata, handles)
% Incluir todos os parametros de navegaçao

NAV = ones( size( handles.NAV_param , 1), 1);
if get(handles.NAV_chk,'Value')
    set(handles.NAV_list, 'String',[char(abs(handles.Y)*NAV)  blanks(length(NAV))'  char(handles.NAV_param) ], 'UserData',  NAV);
else
    set(handles.NAV_list, 'String',[blanks(length(NAV))'      blanks(length(NAV))'  char(handles.NAV_param) ], 'UserData', ~NAV);
end
update_Npar(hObject, eventdata, handles);

% -------------------------------------------------------------------
function HMD_chk_Callback(hObject, eventdata, handles)
% Incluir todos os parametros do HMD

HMD = ones( size( handles.HMD_param , 1), 1);
if get(handles.HMD_chk,'Value')
    set(handles.HMD_list, 'String',[char(abs(handles.Y)*HMD)  blanks(length(HMD))'  char(handles.HMD_param) ], 'UserData',  HMD);
else
    set(handles.HMD_list, 'String',[blanks(length(HMD))'      blanks(length(HMD))'  char(handles.HMD_param) ], 'UserData', ~HMD);
end
update_Npar(hObject, eventdata, handles);

% -------------------------------------------------------------------
function LDP_chk_Callback(hObject, eventdata, handles)
% Incluir todos os parametros do pod laser

LDP = ones( size( handles.LDP_param , 1), 1);
if get(handles.LDP_chk,'Value')
    set(handles.LDP_list, 'String',[char(abs(handles.Y)*LDP)  blanks(length(LDP))'  char(handles.LDP_param) ], 'UserData',  LDP);
else
    set(handles.LDP_list, 'String',[blanks(length(LDP))'      blanks(length(LDP))'  char(handles.LDP_param) ], 'UserData', ~LDP);
end
update_Npar(hObject, eventdata, handles);

% -------------------------------------------------------------------
function EO_chk_Callback(hObject, eventdata, handles)
% Incluir todos os parametros do missil eletro-optico

EO = ones( size( handles.EO_param , 1), 1);
if get(handles.EO_chk,'Value')
    set(handles.EO_list, 'String',[char(abs(handles.Y)*EO)  blanks(length(EO))'  char(handles.EO_param) ], 'UserData',  EO);
else
    set(handles.EO_list, 'String',[blanks(length(EO))'      blanks(length(EO))'  char(handles.EO_param) ], 'UserData', ~EO);
end
update_Npar(hObject, eventdata, handles);

% -------------------------------------------------------------------
function ENG_chk_Callback(hObject, eventdata, handles)
% Incluir todos os parametros de motor

ENG = ones( size( handles.ENG_param , 1), 1);
if get(handles.ENG_chk,'Value')
    set(handles.ENG_list, 'String',[char(abs(handles.Y)*ENG)  blanks(length(ENG))'  char(handles.ENG_param) ], 'UserData',  ENG);
else
    set(handles.ENG_list, 'String',[blanks(length(ENG))'      blanks(length(ENG))'  char(handles.ENG_param) ], 'UserData', ~ENG);
end
update_Npar(hObject, eventdata, handles);

% -------------------------------------------------------------------
% -------------------------------------------------------------------
function AC_add_Callback(hObject, eventdata, handles)
% Incluir parametro de voo e da aeronave

PARAM = get(handles.AC_list,'String');
AC = get(handles.AC_list,'Userdata');
n = get(handles.AC_list,'Value');

AC(n) = 1;
PARAM(n,1) = handles.Y;
set(handles.AC_list,'String',PARAM,'UserData',AC);
update_Npar(hObject, eventdata, handles);

% -------------------------------------------------------------------
function RDR_add_Callback(hObject, eventdata, handles)
% Incluir parametro do radar

PARAM = get(handles.RDR_list,'String');
RDR = get(handles.RDR_list,'Userdata');
n = get(handles.RDR_list,'Value');

RDR(n) = 1;
PARAM(n,1) = handles.Y;
set(handles.RDR_list,'String',PARAM,'UserData',RDR);
update_Npar(hObject, eventdata, handles);

% -------------------------------------------------------------------
function WPN_add_Callback(hObject, eventdata, handles)
% Incluir parametro de armamento

PARAM = get(handles.WPN_list,'String');
WPN = get(handles.WPN_list,'Userdata');
n = get(handles.WPN_list,'Value');

WPN(n) = 1;
PARAM(n,1) = handles.Y;
set(handles.WPN_list,'String',PARAM,'UserData',WPN);
update_Npar(hObject, eventdata, handles);

% -------------------------------------------------------------------
function NAV_add_Callback(hObject, eventdata, handles)
% Incluir parametro de navegaçao

PARAM = get(handles.NAV_list,'String');
NAV = get(handles.NAV_list,'Userdata');
n = get(handles.NAV_list,'Value');

NAV(n) = 1;
PARAM(n,1) = handles.Y;
set(handles.NAV_list,'String',PARAM,'UserData',NAV);
update_Npar(hObject, eventdata, handles);

% -------------------------------------------------------------------
function HMD_add_Callback(hObject, eventdata, handles)
% Incluir parametro do HMD

PARAM = get(handles.HMD_list,'String');
HMD = get(handles.HMD_list,'Userdata');
n = get(handles.HMD_list,'Value');

HMD(n) = 1;
PARAM(n,1) = handles.Y;
set(handles.HMD_list,'String',PARAM,'UserData',HMD);
update_Npar(hObject, eventdata, handles);

% -------------------------------------------------------------------
function LDP_add_Callback(hObject, eventdata, handles)
% Incluir parametro do pod laser

PARAM = get(handles.LDP_list,'String');
LDP = get(handles.LDP_list,'Userdata');
n = get(handles.LDP_list,'Value');

LDP(n) = 1;
PARAM(n,1) = handles.Y;
set(handles.LDP_list,'String',PARAM,'UserData',LDP);
update_Npar(hObject, eventdata, handles);

% -------------------------------------------------------------------
function EO_add_Callback(hObject, eventdata, handles)
% Incluir parametro do missil eletro-optico

PARAM = get(handles.EO_list,'String');
EO = get(handles.EO_list,'Userdata');
n = get(handles.EO_list,'Value');

EO(n) = 1;
PARAM(n,1) = handles.Y;
set(handles.EO_list,'String',PARAM,'UserData',EO);
update_Npar(hObject, eventdata, handles);

% -------------------------------------------------------------------
function ENG_add_Callback(hObject, eventdata, handles)
% Incluir parametro de motor

PARAM = get(handles.ENG_list,'String');
ENG = get(handles.ENG_list,'Userdata');
n = get(handles.ENG_list,'Value');

ENG(n) = 1;
PARAM(n,1) = handles.Y;
set(handles.ENG_list,'String',PARAM,'UserData',ENG);
update_Npar(hObject, eventdata, handles);

% -------------------------------------------------------------------
% -------------------------------------------------------------------
function AC_rem_Callback(hObject, eventdata, handles)
% Remover parametro de voo e da aeronave

PARAM = get(handles.AC_list,'String');
AC = get(handles.AC_list,'Userdata');
n = get(handles.AC_list,'Value');

AC(n) = 0;
PARAM(n,1) = handles.N;
set(handles.AC_list,'String',PARAM,'UserData',AC);
set(handles.AC_chk,'Value',0);
update_Npar(hObject, eventdata, handles);

% -------------------------------------------------------------------
function RDR_rem_Callback(hObject, eventdata, handles)
% Remover parametro do radar

PARAM = get(handles.RDR_list,'String');
RDR = get(handles.RDR_list,'Userdata');
n = get(handles.RDR_list,'Value');

RDR(n) = 0;
PARAM(n,1) = handles.N;
set(handles.RDR_list,'String',PARAM,'UserData',RDR);
set(handles.RDR_chk,'Value',0);
update_Npar(hObject, eventdata, handles);

% -------------------------------------------------------------------
function WPN_rem_Callback(hObject, eventdata, handles)
% Remover parametro de armamento

PARAM = get(handles.WPN_list,'String');
WPN = get(handles.WPN_list,'Userdata');
n = get(handles.WPN_list,'Value');

WPN(n) = 0;
PARAM(n,1) = handles.N;
set(handles.WPN_list,'String',PARAM,'UserData',WPN);
set(handles.WPN_chk,'Value',0);
update_Npar(hObject, eventdata, handles);

% -------------------------------------------------------------------
function NAV_rem_Callback(hObject, eventdata, handles)
% Remover parametro de navegaçao

PARAM = get(handles.NAV_list,'String');
NAV = get(handles.NAV_list,'Userdata');
n = get(handles.NAV_list,'Value');

NAV(n) = 0;
PARAM(n,1) = handles.N;
set(handles.NAV_list,'String',PARAM,'UserData',NAV);
set(handles.NAV_chk,'Value',0);
update_Npar(hObject, eventdata, handles);

% -------------------------------------------------------------------
function HMD_rem_Callback(hObject, eventdata, handles)
% Remover parametro do HMD

PARAM = get(handles.HMD_list,'String');
HMD = get(handles.HMD_list,'Userdata');
n = get(handles.HMD_list,'Value');

HMD(n) = 0;
PARAM(n,1) = handles.N;
set(handles.HMD_list,'String',PARAM,'UserData',HMD);
set(handles.HMD_chk,'Value',0);
update_Npar(hObject, eventdata, handles);

% -------------------------------------------------------------------
function LDP_rem_Callback(hObject, eventdata, handles)
% Remover parametro do pod laser

PARAM = get(handles.LDP_list,'String');
LDP = get(handles.LDP_list,'Userdata');
n = get(handles.LDP_list,'Value');

LDP(n) = 0;
PARAM(n,1) = handles.N;
set(handles.LDP_list,'String',PARAM,'UserData',LDP);
set(handles.LDP_chk,'Value',0);
update_Npar(hObject, eventdata, handles);

% -------------------------------------------------------------------
function EO_rem_Callback(hObject, eventdata, handles)
% Remover parametro do missil eletro-optico

PARAM = get(handles.EO_list,'String');
EO = get(handles.EO_list,'Userdata');
n = get(handles.EO_list,'Value');

EO(n) = 0;
PARAM(n,1) = handles.N;
set(handles.EO_list,'String',PARAM,'UserData',EO);
set(handles.EO_chk,'Value',0);
update_Npar(hObject, eventdata, handles);

% -------------------------------------------------------------------
function ENG_rem_Callback(hObject, eventdata, handles)
% Remover parametro de motor

PARAM = get(handles.ENG_list,'String');
ENG = get(handles.ENG_list,'Userdata');
n = get(handles.ENG_list,'Value');

ENG(n) = 0;
PARAM(n,1) = handles.N;
set(handles.ENG_list,'String',PARAM,'UserData',ENG);
set(handles.ENG_chk,'Value',0);
update_Npar(hObject, eventdata, handles);

% -------------------------------------------------------------------
% -------------------------------------------------------------------
function AC_list_Callback(hObject, eventdata, handles)
global N T
% Lista de parametros de voo e da aeronave

n = get(handles.AC_list,'Value');

if etime(clock,T) < .2 && n(1) == N
    
    PARAM = get(handles.AC_list,'String');
    AC = get(handles.AC_list,'Userdata');
    
    if PARAM(n,1) == handles.Y;
        PARAM(n,1) = handles.N;
        AC(n)      = 0;
        set(handles.AC_chk,'Value',0);
    else
        PARAM(n,1) = handles.Y;
        AC(n)      = 1;
    end
    
    set(handles.AC_list,'String',PARAM,'UserData',AC);
    update_Npar(hObject, eventdata, handles);
    
end
T = clock;
N = n(1);

% -------------------------------------------------------------------
function RDR_list_Callback(hObject, eventdata, handles)
global N T
% Lista de parametros do radar

n = get(handles.RDR_list,'Value');

if etime(clock,T) < .2 && n(1) == N
    
    PARAM = get(handles.RDR_list,'String');
    RDR = get(handles.RDR_list,'Userdata');
    
    if PARAM(n,1) == handles.Y;
        PARAM(n,1) = handles.N;
        RDR(n)     = 0;
        set(handles.RDR_chk,'Value',0);
    else
        PARAM(n,1) = handles.Y;
        RDR(n)     = 1;
    end
    
    set(handles.RDR_list,'String',PARAM,'UserData',RDR);
    update_Npar(hObject, eventdata, handles);
    
end
T = clock;
N = n(1);

% -------------------------------------------------------------------
function WPN_list_Callback(hObject, eventdata, handles)
global N T
% Lista de parametros de armamento

n = get(handles.WPN_list,'Value');

if etime(clock,T) < .2 && n(1) == N
    
    PARAM = get(handles.WPN_list,'String');
    WPN = get(handles.WPN_list,'Userdata');
    
    if PARAM(n,1) == handles.Y;
        PARAM(n,1) = handles.N;
        WPN(n)     = 0;
        set(handles.WPN_chk,'Value',0);
    else
        PARAM(n,1) = handles.Y;
        WPN(n)     = 1;
    end
    
    set(handles.WPN_list,'String',PARAM,'UserData',WPN);
    update_Npar(hObject, eventdata, handles);
    
end
T = clock;
N = n(1);

% -------------------------------------------------------------------
function NAV_list_Callback(hObject, eventdata, handles)
global N T
% Lista de parametros de navegaçao

n = get(handles.NAV_list,'Value');

if etime(clock,T) < .2 && n(1) == N
    
    PARAM = get(handles.NAV_list,'String');
    NAV = get(handles.NAV_list,'Userdata');
    
    if PARAM(n,1) == handles.Y;
        PARAM(n,1) = handles.N;
        NAV(n)     = 0;
        set(handles.NAV_chk,'Value',0);
    else
        PARAM(n,1) = handles.Y;
        NAV(n)     = 1;
    end
    
    set(handles.NAV_list,'String',PARAM,'UserData',NAV);
    update_Npar(hObject, eventdata, handles);
    
end
T = clock;
N = n(1);

% -------------------------------------------------------------------
function HMD_list_Callback(hObject, eventdata, handles)
global N T
% Lista de parametros do HMD

n = get(handles.HMD_list,'Value');

if etime(clock,T) < .2 && n(1) == N
    
    PARAM = get(handles.HMD_list,'String');
    HMD = get(handles.HMD_list,'Userdata');
    
    if PARAM(n,1) == handles.Y;
        PARAM(n,1) = handles.N;
        HMD(n)     = 0;
        set(handles.HMD_chk,'Value',0);
    else
        PARAM(n,1) = handles.Y;
        HMD(n)     = 1;
    end
    
    set(handles.HMD_list,'String',PARAM,'UserData',HMD);
    update_Npar(hObject, eventdata, handles);
    
end
T = clock;
N = n(1);

% -------------------------------------------------------------------
function LDP_list_Callback(hObject, eventdata, handles)
global N T
% Lista de parametros do pod laser

n = get(handles.LDP_list,'Value');

if etime(clock,T) < .2 && n(1) == N
    
    PARAM = get(handles.LDP_list,'String');
    LDP = get(handles.LDP_list,'Userdata');
    
    if PARAM(n,1) == handles.Y;
        PARAM(n,1) = handles.N;
        LDP(n)     = 0;
        set(handles.LDP_chk,'Value',0);
    else
        PARAM(n,1) = handles.Y;
        LDP(n)      = 1;
    end
    
    set(handles.LDP_list,'String',PARAM,'UserData',LDP);
    update_Npar(hObject, eventdata, handles);
    
end
T = clock;
N = n(1);

% -------------------------------------------------------------------
function EO_list_Callback(hObject, eventdata, handles)
global N T
% Lista de parametros do missil eletro-optico

n = get(handles.EO_list,'Value');

if etime(clock,T) < .2 && n(1) == N
    
    PARAM = get(handles.EO_list,'String');
    EO = get(handles.EO_list,'Userdata');
    
    if PARAM(n,1) == handles.Y;
        PARAM(n,1) = handles.N;
        EO(n)      = 0;
        set(handles.EO_chk,'Value',0);
    else
        PARAM(n,1) = handles.Y;
        EO(n)      = 1;
    end
    
    set(handles.EO_list,'String',PARAM,'UserData',EO);
    update_Npar(hObject, eventdata, handles);
    
end
T = clock;
N = n(1);

% -------------------------------------------------------------------
function ENG_list_Callback(hObject, eventdata, handles)
global N T
% Lista de parametros do motor

n = get(handles.ENG_list,'Value');

if etime(clock,T) < .2 && n(1) == N
    
    PARAM = get(handles.ENG_list,'String');
    ENG = get(handles.ENG_list,'Userdata');
    
    if PARAM(n,1) == handles.Y;
        PARAM(n,1) = handles.N;
        ENG(n)     = 0;
        set(handles.ENG_chk,'Value',0);
    else
        PARAM(n,1) = handles.Y;
        ENG(n)     = 1;
    end
    
    set(handles.ENG_list,'String',PARAM,'UserData',ENG);
    update_Npar(hObject, eventdata, handles);
    
end
T = clock;
N = n(1);

% -------------------------------------------------------------------
function update_Npar(hObject, eventdata, handles)
% Atualiza o numero de parametros selecionados

AC  = get(handles.AC_list, 'UserData');
RDR = get(handles.RDR_list,'UserData');
WPN = get(handles.WPN_list,'UserData');
NAV = get(handles.NAV_list,'UserData');
HMD = get(handles.HMD_list,'UserData');
LDP = get(handles.LDP_list,'UserData');
EO  = get(handles.EO_list, 'UserData');
ENG = get(handles.ENG_list,'UserData');
fnum = get(handles.fnum_chk,'Value');

if get(handles.F5M_sel,'Value')
    Npar = sum([AC; RDR; WPN; NAV; HMD; LDP; EO; ENG; fnum]);
else
    Npar = sum(AC);
end
set(handles.Nsel,'String',num2str(Npar));

% -------------------------------------------------------------------
function help_btn_Callback(hObject, eventdata, handles)
% Botao Ajuda

helpme('Arquivo\importardados','xml');

% -------------------------------------------------------------------
function OK_btn_Callback(hObject, eventdata, handles)
% Botao OK

ACD = [get(handles.AC_list, 'UserData');
    get(handles.RDR_list,'UserData');
    get(handles.WPN_list,'UserData');
    get(handles.NAV_list,'UserData');
    get(handles.HMD_list,'UserData');
    get(handles.LDP_list,'UserData');
    get(handles.EO_list, 'UserData')];
ENG = get(handles.ENG_list,'UserData');

if ~str2double(get(handles.Nsel,'String'))
    beep; uiwait(errordlg('Nenhum parâmetro selecionado.','Erro','modal')); drawnow;
    return
end

if any(ENG) && any(ACD) && (~ACD(1) || ~ENG(1))
    beep; uiwait(errordlg({'É necessário selecionar o parâmetro ''UTC'' nas colunas',...
            '''AIRCRAFT'' e ''ENGINE'' para incorporação dos dados de motores.'},'Erro','modal')); drawnow;
    return
end

button = questdlg('Deseja confirmar a seleção?','Confirmação','Sim','Não','Não');
if strcmp(button,'Sim')
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

%--------------------------------------------------------------------------
function window_KeyPressFcn(hObject, eventdata, handles)
% Acionamento de tecla do teclado

cc = get(handles.window,'CurrentCharacter');

if isempty(cc)
    return
end

switch abs(cc)
    
    case {abs('f'),abs('F')}
        F5M_sel_Callback(hObject, eventdata, handles);
        
    case {abs('a'),abs('A')}
        A29_sel_Callback(hObject, eventdata, handles);
        
    case 13 % Enter
        OK_btn_Callback(hObject, eventdata, handles);
        
    case 27 % Esc
        window_CloseRequestFcn(hObject, eventdata, handles);
        
end

% -------------------------------------------------------------------
function window_CloseRequestFcn(hObject, eventdata, handles)
% Funçao de fechamento da janela

cancel_btn_Callback(hObject, eventdata, handles);

% -------------------------------------------------------------------
function F5M_sel_Callback(hObject, eventdata, handles)
% Seleciona aeronave F-5

set(handles.A29_sel,'Value',0);
set(handles.F5M_sel,'Value',1);

set([handles.lists handles.checks handles.adds handles.rems],'Enable','on');

update_Npar(hObject, eventdata, handles);

% -------------------------------------------------------------------
function A29_sel_Callback(hObject, eventdata, handles)
% Seleciona aeronave A-29

set(handles.A29_sel,'Value',1);
set(handles.F5M_sel,'Value',0);

set([handles.lists(2:end) handles.checks(2:end) handles.adds(2:end) handles.rems(2:end)],'Enable','off');

update_Npar(hObject, eventdata, handles);

% -------------------------------------------------------------------
function fnum_chk_Callback(hObject, eventdata, handles)
% Incluir numero do arquivo

update_Npar(hObject, eventdata, handles);
