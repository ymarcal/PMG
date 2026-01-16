function varargout = anemocalc(varargin)
% Last Modified by GUIDE v2.5 03-May-2011 17:25:07

gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @anemocalc_OpeningFcn, ...
                   'gui_OutputFcn',  @anemocalc_OutputFcn, ...
                   'gui_LayoutFcn',  @anemocalc_LayoutFcn, ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

% ---------------------------------------------------------------
function h = anemocalc_LayoutFcn(varargin)
% Função de layout inicial

h = openfig('anemocalc.fig','reuse','visible');

% ---------------------------------------------------------------
function anemocalc_OpeningFcn(hObject, eventdata, handles, varargin)
% Funçao de inicializaçao

ss = get(0,'ScreenSize');
fs = get(handles.window,'Position');
as = get(handles.axes1,'Position');

set(handles.window,'Position',[(ss(3)-fs(3))/2 (ss(4)-fs(4))/2 fs(3:4)]);
handles.axeslist = [handles.axes1 handles.axes2 handles.axes3];
setappdata(handles.window,'moved',0);
setappdata(handles.window,'fixcur',0);

bgc = get(handles.window,'Color');
set(handles.axes1,'Color',bgc,'XColor',bgc,'YColor',bgc);

if exist('geticon.m','file')
    bgc = getbuttoncolor(handles.window);
    set(handles.help_btn,'CData',geticon('DatButtons.mat','help',bgc));
else
    set(handles.help_btn,'Visible','off');
end

if ~exist('inputvalues.m','file')
    set([handles.axes2 handles.axes3],'UIContextMenu',[]);
end

handles.R = 287.053;
handles.dT = 273.15;
handles.gama = 1.4;
handles.pa0 = 1013.25;
handles.Ta0 = 15;
handles.rho0 = handles.pa0*100/(handles.R*(handles.Ta0+handles.dT));

handles.VZ_lim = [0 2000 -2000 100000];
handles.qp_lim = [vc2qc(handles.VZ_lim([1 2])) zp2pa(handles.VZ_lim([4 3]))];

handles.V_lim = [0 700];
handles.Z_lim = [0 50000];
handles.q_lim = vc2qc(handles.V_lim);
handles.p_lim = sort(zp2pa(handles.Z_lim));
handles.dMach = .2;
handles.Dpb_lim  = [-30 30];
handles.DISA_lim = [-30 30];

Mmax = qcpa2m(handles.q_lim(2),handles.p_lim(1));

handles.Zp    = 0;
handles.Vc    = 0;
handles.M     = 0;
handles.pa    = handles.pa0;
handles.qc    = 0;
handles.Dpb   = 0;
handles.Dqb   = 0;
handles.pb    = handles.pa0;
handles.qb    = 0;
handles.Zpb   = 0;
handles.Vb    = 0;
handles.Mb    = 0;
handles.DISA  = 0;
handles.TaISA = handles.Ta0;
handles.Ta    = handles.Ta0;
handles.a     = sqrt(handles.gama*handles.R*(handles.Ta0+handles.dT))/(1852/3600);
handles.Va    = 0;
handles.rho   = handles.rho0;
handles.Ve    = 0;
handles.q     = 0;
handles.delta = 1;
handles.sigma = 1;
handles.teta  = 1;

axes(handles.axes2);
xlabel('qb, qc (mb)');
ylabel('pb, pa (mb)');
for qcpai = m2qcpa(handles.dMach:handles.dMach:Mmax)
    pai = linspace(handles.p_lim(1),handles.p_lim(2),50);
    qci = qcpai.*pai;
    plot(qci,pai,'-k','HitTest','off','Tag','aux');
    text(max(qci),handles.p_lim(2),num2str(qcpa2m(qcpai,1),'%0.1f'),'Clipping','on','FontSize',8,'HorizontalAlignment','center','VerticalAlignment','top','HitTest','off','Tag','aux');
end
axis([handles.q_lim handles.p_lim]);
handles.p_qbpb = plot(handles.qb,handles.pb,'rs','MarkerFaceColor','r','MarkerSize',5,'Clipping','off');
handles.p_qcpa = plot(handles.qc,handles.pa,'bo','MarkerFaceColor','b','MarkerSize',5,'Clipping','off');

axes(handles.axes3);
xlabel('Vb, Vc, Ve, Va (kt)');
ylabel('Zpb, Zp (ft)');
for Mi = handles.dMach:handles.dMach:Mmax
    Zpi = linspace(handles.Z_lim(1),handles.Z_lim(2),50);
    Vci = qc2vc(m2qcpa(Mi).*zp2pa(Zpi));
    plot(Vci,Zpi,'-k','HitTest','off','Tag','aux');
    text(max(Vci),handles.Z_lim(1),num2str(Mi,'%0.1f'),'Clipping','on','FontSize',8,'HorizontalAlignment','center','VerticalAlignment','bottom','HitTest','off','Tag','aux');
end
axis([handles.V_lim handles.Z_lim]);
handles.p_VbZpb = plot(handles.Vb,handles.Zpb,'rs','MarkerFaceColor','r','MarkerSize',5,'Clipping','off');
handles.p_VcZp  = plot(handles.Vc,handles.Zp ,'bo','MarkerFaceColor','b','MarkerSize',5,'Clipping','off');
handles.p_VaZp  = plot(handles.Va,handles.Zp ,'gd','MarkerEdgeColor',[0 .8 0],'MarkerFaceColor',[0 .8 0],'MarkerSize',5,'Clipping','off');
handles.p_VeZp  = plot(handles.Ve,handles.Zp ,'md','MarkerFaceColor','m','MarkerSize',5,'Clipping','off');

set([handles.slider1 handles.slider3],'Min',handles.Dpb_lim(1) ,'Max',handles.Dpb_lim(2),'Value',handles.Dpb,'SliderStep',[.2 5]/diff(handles.Dpb_lim));
set(handles.slider2,'Min',handles.DISA_lim(1),'Max',handles.DISA_lim(2),'Value',handles.DISA,'SliderStep',[.2 5]/diff(handles.DISA_lim));

setappdata(handles.window,'dragdata',0);

if exist('anemopos.mat','file')
    load('anemopos.mat');
else
    x_Zp    = 0.2113;   y_Zp    = 0.4710;
    x_Vc    = 0.9237;   y_Vc    = 0.8110;
    x_M     = 0.9688;   y_M     = 0.4130;
    x_pa    = 0.3912;   y_pa    = 0.5530;
    x_qc    = 0.8238;   y_qc    = 0.6950;
    x_Dpb   = 0.5162;   y_Dpb   = 0.6690;
    x_Dqb   = 0.6488;   y_Dqb   = 0.7270;
    x_pb    = 0.3063;   y_pb    = 0.7690;
    x_qb    = 0.6388;   y_qb    = 0.9030;
    x_Zpb   = 0.1238;   y_Zpb   = 0.8070;
    x_Vb    = 0.7863;   y_Vb    = 0.9810;
    x_Mb    = 0.3237;   y_Mb    = 0.9550;
    x_DISA  = 0.0963;   y_DISA  = 0.1130;
    x_TaISA = 0.1438;   y_TaISA = 0.3150;
    x_Ta    = 0.3038;   y_Ta    = 0.1490;
    x_a     = 0.8513;   y_a     = 0.0890;
    x_Va    = 0.7712;   y_Va    = 0.3050;
    x_rho   = 0.5637;   y_rho   = 0.3850;
    x_Ve    = 0.6538;   y_Ve    = 0.2010;
    x_q     = 0.4788;   y_q     = 0.2510;
    x_delta = 0.2088;   y_delta = 0.6070;
    x_sigma = 0.7138;   y_sigma = 0.4790;
    x_teta  = 0.4362;   y_teta  = 0.0690;
end

x_Mb_qb_pb      = mean([x_Mb x_qb x_pb ]);      y_Mb_qb_pb      = mean([y_Mb y_qb y_pb]);
x_pa_pb_Dpb     = mean([x_pa x_pb x_Dpb]);      y_pa_pb_Dpb     = mean([y_pa y_pb y_Dpb]);
x_qc_qb_Dqb     = mean([x_qc x_qb x_Dqb]);      y_qc_qb_Dqb     = mean([y_qc y_qb y_Dqb]);
x_M_qc_pa       = mean([x_M x_qc x_pa ]);       y_M_qc_pa       = mean([y_M y_qc y_pa]);
x_TaISA_Ta_DISA = mean([x_TaISA x_Ta x_DISA]);  y_TaISA_Ta_DISA = mean([y_TaISA y_Ta y_DISA]);
x_Ve_Va_rho     = mean([x_Ve x_Va x_rho]);      y_Ve_Va_rho     = mean([y_Ve y_Va y_rho]);
x_pa_Ta_rho     = mean([x_pa x_Ta x_rho]);      y_pa_Ta_rho     = mean([y_pa y_Ta y_rho]);
x_M_Va_a        = mean([x_M x_Va x_a]);         y_M_Va_a        = mean([y_M y_Va y_a]);

axes(handles.axes1)

plot([x_qb x_Vb],[y_qb y_Vb],'-k');
plot([x_qc x_Vc],[y_qc y_Vc],'-k');
plot([x_Dpb x_Dqb],[y_Dpb y_Dqb],'-k');
plot([x_Zpb x_pb],[y_Zpb y_pb],'-k');
plot([x_Zp x_pa],[y_Zp y_pa],'-k');
plot([x_delta x_pa],[y_delta y_pa],'-k');
plot([x_Zp x_TaISA],[y_Zp y_TaISA],'-k');
plot([x_Ta x_teta],[y_Ta y_teta],'-k');
plot([x_Ta x_a],[y_Ta y_a],'-k');
plot([x_rho x_sigma],[y_rho y_sigma],'-k');
plot([x_Ve x_q],[y_Ve y_q],'-k');

plot([x_Mb_qb_pb x_Mb NaN x_Mb_qb_pb x_qb NaN x_Mb_qb_pb x_pb],[y_Mb_qb_pb y_Mb NaN y_Mb_qb_pb y_qb NaN y_Mb_qb_pb y_pb],'-k');
plot([x_pa_pb_Dpb x_pa NaN x_pa_pb_Dpb x_pb NaN x_pa_pb_Dpb x_Dpb],[y_pa_pb_Dpb y_pa NaN y_pa_pb_Dpb y_pb NaN y_pa_pb_Dpb y_Dpb],'-k');
plot([x_qc_qb_Dqb x_qc NaN x_qc_qb_Dqb x_qb NaN x_qc_qb_Dqb x_Dqb],[y_qc_qb_Dqb y_qc NaN y_qc_qb_Dqb y_qb NaN y_qc_qb_Dqb y_Dqb],'-k');
plot([x_M_qc_pa x_M NaN x_M_qc_pa x_qc NaN x_M_qc_pa x_pa],[y_M_qc_pa y_M NaN y_M_qc_pa y_qc NaN y_M_qc_pa y_pa],'-k');
plot([x_TaISA_Ta_DISA x_TaISA NaN x_TaISA_Ta_DISA x_Ta NaN x_TaISA_Ta_DISA x_DISA],[y_TaISA_Ta_DISA y_TaISA NaN y_TaISA_Ta_DISA y_Ta NaN y_TaISA_Ta_DISA y_DISA],'-k');
plot([x_Ve_Va_rho x_Ve NaN x_Ve_Va_rho x_Va NaN x_Ve_Va_rho x_rho],[y_Ve_Va_rho y_Ve NaN y_Ve_Va_rho y_Va NaN y_Ve_Va_rho y_rho],'-k');
plot([x_pa_Ta_rho x_pa NaN x_pa_Ta_rho x_Ta NaN x_pa_Ta_rho x_rho],[y_pa_Ta_rho y_pa NaN y_pa_Ta_rho y_Ta NaN y_pa_Ta_rho y_rho],'-k');
plot([x_M_Va_a x_M NaN x_M_Va_a x_Va NaN x_M_Va_a x_a],[y_M_Va_a y_M NaN y_M_Va_a y_Va NaN y_M_Va_a y_a],'-k');

handles.h_Zp    = text(x_Zp   , y_Zp   , 1, 'Zp'           );
handles.h_Vc    = text(x_Vc   , y_Vc   , 1, 'Vc'           );
handles.h_M     = text(x_M    , y_M    , 1, 'M'            );
handles.h_pa    = text(x_pa   , y_pa   , 1, 'pa'           );
handles.h_qc    = text(x_qc   , y_qc   , 1, 'qc'           );
handles.h_Dpb   = text(x_Dpb  , y_Dpb  , 1, '\Deltapb'     );
handles.h_Dqb   = text(x_Dqb  , y_Dqb  , 1, '\Deltaqb'     );
handles.h_pb    = text(x_pb   , y_pb   , 1, 'pb'           );
handles.h_qb    = text(x_qb   , y_qb   , 1, 'qb'           );
handles.h_Zpb   = text(x_Zpb  , y_Zpb  , 1, 'Zpb'          );
handles.h_Vb    = text(x_Vb   , y_Vb   , 1, 'Vb'           );
handles.h_Mb    = text(x_Mb   , y_Mb   , 1, 'Mb'           );
handles.h_DISA  = text(x_DISA , y_DISA , 1, '\Delta_{ ISA}');
handles.h_TaISA = text(x_TaISA, y_TaISA, 1, 'Ta_{ ISA}'    );
handles.h_Ta    = text(x_Ta   , y_Ta   , 1, 'Ta'           );
handles.h_a     = text(x_a    , y_a    , 1, 'a'            );
handles.h_Va    = text(x_Va   , y_Va   , 1, 'Va'           );
handles.h_rho   = text(x_rho  , y_rho  , 1, '\rho'         );
handles.h_Ve    = text(x_Ve   , y_Ve   , 1, 'Ve'           );
handles.h_q     = text(x_q    , y_q    , 1, 'q'           );
handles.h_delta = text(x_delta, y_delta, 1, '\delta'       );
handles.h_sigma = text(x_sigma, y_sigma, 1, '\sigma'       );
handles.h_teta  = text(x_teta , y_teta , 1, '\theta'       );

ew = 60;
eh = 20;

set(handles.e_Zp   ,'Position', [as(3)/fs(3)*(x_Zp   *fs(3))-ew/2+as(1)  as(4)/fs(4)*(y_Zp   *fs(4))-30+as(2) ew eh], 'String', num2str(handles.Zp)   ,'TooltipString','ft');
set(handles.e_Vc   ,'Position', [as(3)/fs(3)*(x_Vc   *fs(3))-ew/2+as(1)  as(4)/fs(4)*(y_Vc   *fs(4))-30+as(2) ew eh], 'String', num2str(handles.Vc)   ,'TooltipString','kt');
set(handles.e_M    ,'Position', [as(3)/fs(3)*(x_M    *fs(3))-ew/2+as(1)  as(4)/fs(4)*(y_M    *fs(4))-30+as(2) ew eh], 'String', num2str(handles.M )   ,'TooltipString','');
set(handles.e_pa   ,'Position', [as(3)/fs(3)*(x_pa   *fs(3))-ew/2+as(1)  as(4)/fs(4)*(y_pa   *fs(4))-30+as(2) ew eh], 'String', num2str(handles.pa)   ,'TooltipString','mb');
set(handles.e_qc   ,'Position', [as(3)/fs(3)*(x_qc   *fs(3))-ew/2+as(1)  as(4)/fs(4)*(y_qc   *fs(4))-30+as(2) ew eh], 'String', num2str(handles.qc)   ,'TooltipString','mb');
set(handles.e_Dpb  ,'Position', [as(3)/fs(3)*(x_Dpb  *fs(3))-ew/2+as(1)  as(4)/fs(4)*(y_Dpb  *fs(4))-30+as(2) ew eh], 'String', num2str(handles.Dpb)  ,'TooltipString','mb');
set(handles.e_Dqb  ,'Position', [as(3)/fs(3)*(x_Dqb  *fs(3))-ew/2+as(1)  as(4)/fs(4)*(y_Dqb  *fs(4))-30+as(2) ew eh], 'String', num2str(handles.Dqb)  ,'TooltipString','mb');
set(handles.e_pb   ,'Position', [as(3)/fs(3)*(x_pb   *fs(3))-ew/2+as(1)  as(4)/fs(4)*(y_pb   *fs(4))-30+as(2) ew eh], 'String', num2str(handles.pb)   ,'TooltipString','mb');
set(handles.e_qb   ,'Position', [as(3)/fs(3)*(x_qb   *fs(3))-ew/2+as(1)  as(4)/fs(4)*(y_qb   *fs(4))-30+as(2) ew eh], 'String', num2str(handles.qb)   ,'TooltipString','mb');
set(handles.e_Zpb  ,'Position', [as(3)/fs(3)*(x_Zpb  *fs(3))-ew/2+as(1)  as(4)/fs(4)*(y_Zpb  *fs(4))-30+as(2) ew eh], 'String', num2str(handles.Zpb)  ,'TooltipString','ft');
set(handles.e_Vb   ,'Position', [as(3)/fs(3)*(x_Vb   *fs(3))-ew/2+as(1)  as(4)/fs(4)*(y_Vb   *fs(4))-30+as(2) ew eh], 'String', num2str(handles.Vb)   ,'TooltipString','kt');
set(handles.e_Mb   ,'Position', [as(3)/fs(3)*(x_Mb   *fs(3))-ew/2+as(1)  as(4)/fs(4)*(y_Mb   *fs(4))-30+as(2) ew eh], 'String', num2str(handles.Mb)   ,'TooltipString','');
set(handles.e_DISA ,'Position', [as(3)/fs(3)*(x_DISA *fs(3))-ew/2+as(1)  as(4)/fs(4)*(y_DISA *fs(4))-30+as(2) ew eh], 'String', num2str(handles.DISA) ,'TooltipString','°C');
set(handles.e_TaISA,'Position', [as(3)/fs(3)*(x_TaISA*fs(3))-ew/2+as(1)  as(4)/fs(4)*(y_TaISA*fs(4))-30+as(2) ew eh], 'String', num2str(handles.TaISA),'TooltipString','°C');
set(handles.e_Ta   ,'Position', [as(3)/fs(3)*(x_Ta   *fs(3))-ew/2+as(1)  as(4)/fs(4)*(y_Ta   *fs(4))-30+as(2) ew eh], 'String', num2str(handles.Ta)   ,'TooltipString','°C');
set(handles.e_a    ,'Position', [as(3)/fs(3)*(x_a    *fs(3))-ew/2+as(1)  as(4)/fs(4)*(y_a    *fs(4))-30+as(2) ew eh], 'String', num2str(handles.a)    ,'TooltipString','kt');
set(handles.e_Va   ,'Position', [as(3)/fs(3)*(x_Va   *fs(3))-ew/2+as(1)  as(4)/fs(4)*(y_Va   *fs(4))-30+as(2) ew eh], 'String', num2str(handles.Va)   ,'TooltipString','kt');
set(handles.e_rho  ,'Position', [as(3)/fs(3)*(x_rho  *fs(3))-ew/2+as(1)  as(4)/fs(4)*(y_rho  *fs(4))-30+as(2) ew eh], 'String', num2str(handles.rho)  ,'TooltipString','kg/m³');
set(handles.e_Ve   ,'Position', [as(3)/fs(3)*(x_Ve   *fs(3))-ew/2+as(1)  as(4)/fs(4)*(y_Ve   *fs(4))-30+as(2) ew eh], 'String', num2str(handles.Ve)   ,'TooltipString','kt');
set(handles.e_q    ,'Position', [as(3)/fs(3)*(x_q    *fs(3))-ew/2+as(1)  as(4)/fs(4)*(y_q    *fs(4))-30+as(2) ew eh], 'String', num2str(handles.q)    ,'TooltipString','mb');
set(handles.e_delta,'Position', [as(3)/fs(3)*(x_delta*fs(3))-ew/2+as(1)  as(4)/fs(4)*(y_delta*fs(4))-30+as(2) ew eh], 'String', num2str(handles.delta),'TooltipString','');
set(handles.e_sigma,'Position', [as(3)/fs(3)*(x_sigma*fs(3))-ew/2+as(1)  as(4)/fs(4)*(y_sigma*fs(4))-30+as(2) ew eh], 'String', num2str(handles.sigma),'TooltipString','');
set(handles.e_teta ,'Position', [as(3)/fs(3)*(x_teta *fs(3))-ew/2+as(1)  as(4)/fs(4)*(y_teta *fs(4))-30+as(2) ew eh], 'String', num2str(handles.teta) ,'TooltipString','');

set([handles.e_a handles.e_rho handles.e_delta handles.e_sigma handles.e_teta],'Enable','inactive');

set(findobj(handles.axes1,'Type','text'),'horizontalalignment','center','BackgroundColor',[.8 1 1],'EdgeColor','k','HitTest','off');

axes(handles.legend1);
text(.2, .98, 1,'\Deltapb','HitTest','off');
text(.2, .40, 1,'\Deltaqb','HitTest','off');
text(.2, -.20, 1,'\Delta_{ ISA}','HitTest','off');

guidata(hObject, handles);

chk1_Callback(hObject, eventdata, handles);

% ---------------------------------------------------------------
function varargout = anemocalc_OutputFcn(hObject, eventdata, handles)
% Funçao de fechamento

varargout{1} = [];

% ---------------------------------------------------------------
% -- CALLBACK FUNCTIONS -----------------------------------------
% ---------------------------------------------------------------

function slider1_Callback(hObject, eventdata, handles)
% Slider do Dpb

handles.Dpb = get(handles.slider1,'Value');

if get(handles.chk1,'Value');
    handles.Dqb = -handles.Dpb;
end

handles.qc    = max(handles.qp_lim(1),handles.qb-handles.Dqb);
handles.pa    = handles.pb-handles.Dpb;
handles.Vb    = qc2vc(handles.qb);
handles.Zpb   = pa2zp(handles.pb);
handles.Mb    = qcpa2m(handles.qb,handles.pb);
handles.Vc    = qc2vc(handles.qc);
handles.Zp    = pa2zp(handles.pa);
handles.M     = qcpa2m(handles.qc,handles.pa);
handles.TaISA = zp2ta(handles.Zp)-handles.dT;
handles.Ta    = handles.TaISA+handles.DISA;
handles.teta  = (handles.Ta+handles.dT)/(handles.Ta0+handles.dT);
handles.rho   = handles.pa*100/(handles.R*(handles.Ta+handles.dT));
handles.sigma = handles.rho/handles.rho0;
handles.delta = handles.pa/handles.pa0;
handles.a     = sqrt(handles.gama*handles.R*(handles.Ta+handles.dT))/(1852/3600);
handles.Va    = handles.a*handles.M;
handles.Ve    = handles.Va*sqrt(handles.rho/handles.rho0);
handles.q     = .5*handles.rho0*(handles.Ve*1852/3600)^2/100;

guidata(hObject, handles);
set(handles.slider3,'Value',handles.Dqb);
updatefields(hObject, eventdata, handles);

% ---------------------------------------------------------------
function slider2_Callback(hObject, eventdata, handles)
% Slider do DISA

handles.DISA = get(handles.slider2,'Value');

handles.Ta    = handles.TaISA+handles.DISA;
handles.teta  = (handles.Ta+handles.dT)/(handles.Ta0+handles.dT);
handles.rho   = handles.pa*100/(handles.R*(handles.Ta+handles.dT));
handles.sigma = handles.rho/handles.rho0;
handles.delta = handles.pa/handles.pa0;
handles.a     = sqrt(handles.gama*handles.R*(handles.Ta+handles.dT))/(1852/3600);
handles.Va    = handles.a*handles.M;
handles.Ve    = handles.Va*sqrt(handles.rho/handles.rho0);
handles.q     = .5*handles.rho0*(handles.Ve*1852/3600)^2/100;

guidata(hObject, handles);
updatefields(hObject, eventdata, handles);

% ---------------------------------------------------------------
function slider3_Callback(hObject, eventdata, handles)
% Slider do Dqb

handles.Dqb = get(handles.slider3,'Value');

if get(handles.chk1,'Value');
    handles.Dpb = -handles.Dqb;
end

handles.qc    = max(handles.qp_lim(1),handles.qb-handles.Dqb);
handles.pa    = handles.pb-handles.Dpb;
handles.Vb    = qc2vc(handles.qb);
handles.Zpb   = pa2zp(handles.pb);
handles.Mb    = qcpa2m(handles.qb,handles.pb);
handles.Vc    = qc2vc(handles.qc);
handles.Zp    = pa2zp(handles.pa);
handles.M     = qcpa2m(handles.qc,handles.pa);
handles.TaISA = zp2ta(handles.Zp)-handles.dT;
handles.Ta    = handles.TaISA+handles.DISA;
handles.teta  = (handles.Ta+handles.dT)/(handles.Ta0+handles.dT);
handles.rho   = handles.pa*100/(handles.R*(handles.Ta+handles.dT));
handles.sigma = handles.rho/handles.rho0;
handles.delta = handles.pa/handles.pa0;
handles.a     = sqrt(handles.gama*handles.R*(handles.Ta+handles.dT))/(1852/3600);
handles.Va    = handles.a*handles.M;
handles.Ve    = handles.Va*sqrt(handles.rho/handles.rho0);
handles.q     = .5*handles.rho0*(handles.Ve*1852/3600)^2/100;

guidata(hObject, handles);
set(handles.slider1,'Value',handles.Dpb);
updatefields(hObject, eventdata, handles);

% ---------------------------------------------------------------
function chk1_Callback(hObject, eventdata, handles)
% Opçao Dqb = -Dpb

opt = get(handles.chk1,'Value');
if opt
    slider1_Callback(hObject, eventdata, handles);
end
updatelines(hObject, eventdata, handles, 1);

% ---------------------------------------------------------------
function e_Zp_Callback(hObject, eventdata, handles)
% Entrada manual de Zp

Zp = str2double(get(handles.e_Zp,'String'));
if ~isnan(Zp)
    handles.Zp = max(handles.VZ_lim(3),min(handles.VZ_lim(4),Zp));
    guidata(hObject, handles);
    dragdata = [5 0 0 0 handles.Vc handles.Zp 1];
    window_WindowButtonMotionFcn(hObject, eventdata, handles, dragdata);
else
    updatefields(hObject, eventdata, handles);
end

% ---------------------------------------------------------------
function e_Vc_Callback(hObject, eventdata, handles)
% Entrada manual de Vc

Vc = str2double(get(handles.e_Vc,'String'));
if ~isnan(Vc)
    handles.Vc = max(handles.VZ_lim(1),min(handles.VZ_lim(2),Vc));
    guidata(hObject, handles);
    dragdata = [5 0 0 0 handles.Vc handles.Zp 1];
    window_WindowButtonMotionFcn(hObject, eventdata, handles, dragdata);
else
    updatefields(hObject, eventdata, handles);
end

% ---------------------------------------------------------------
function e_M_Callback(hObject, eventdata, handles)
% Entrada manual de M

M = str2double(get(handles.e_M,'String'));
if ~isnan(M)
    Vc = qc2vc(m2qcpa(M)*handles.pa);
    handles.Vc = max(handles.VZ_lim(1),min(handles.VZ_lim(2),Vc));
    guidata(hObject, handles);
    dragdata = [5 0 0 0 handles.Vc handles.Zp 1];
    window_WindowButtonMotionFcn(hObject, eventdata, handles, dragdata);
else
    updatefields(hObject, eventdata, handles);
end

% ---------------------------------------------------------------
function e_pa_Callback(hObject, eventdata, handles)
% Entrada manual de pa

pa = str2double(get(handles.e_pa,'String'));
if ~isnan(pa)
    handles.pa = max(handles.qp_lim(3),min(handles.qp_lim(4),pa));
    guidata(hObject, handles);
    dragdata = [3 0 0 0 handles.qc handles.pa 1];
    window_WindowButtonMotionFcn(hObject, eventdata, handles, dragdata);
else
    updatefields(hObject, eventdata, handles);
end

% ---------------------------------------------------------------
function e_qc_Callback(hObject, eventdata, handles)
% Entrada manual de qc

qc = str2double(get(handles.e_qc,'String'));
if ~isnan(qc)
    handles.qc = max(handles.qp_lim(1),min(handles.qp_lim(2),qc));
    guidata(hObject, handles);
    dragdata = [3 0 0 0 handles.qc handles.pa 1];
    window_WindowButtonMotionFcn(hObject, eventdata, handles, dragdata);
else
    updatefields(hObject, eventdata, handles);
end

% ---------------------------------------------------------------
function e_Dpb_Callback(hObject, eventdata, handles)
% Entrada manual de Dpb

Dpb = str2double(get(handles.e_Dpb,'String'));
if ~isnan(Dpb)
    Dpb = max(-30,min(30,Dpb));
    set(handles.slider1,'Value',Dpb);
end
slider1_Callback(hObject, eventdata, handles);

% ---------------------------------------------------------------
function e_Dqb_Callback(hObject, eventdata, handles)
% Entrada manual de Dqb


Dqb = str2double(get(handles.e_Dqb,'String'));
if ~isnan(Dqb)
    Dqb = max(-30,min(30,Dqb));
    set(handles.slider3,'Value',Dqb);
end
slider3_Callback(hObject, eventdata, handles);

% ---------------------------------------------------------------
function e_pb_Callback(hObject, eventdata, handles)
% Entrada manual de pb

pb = str2double(get(handles.e_pb,'String'));
if ~isnan(pb)
    handles.pb = max(handles.qp_lim(3),min(handles.qp_lim(4),pb));
    guidata(hObject, handles);
    dragdata = [2 0 0 0 handles.qb handles.pb 1];
    window_WindowButtonMotionFcn(hObject, eventdata, handles, dragdata);
else
    updatefields(hObject, eventdata, handles);
end

% ---------------------------------------------------------------
function e_qb_Callback(hObject, eventdata, handles)
% Entrada manual de qb

qb = str2double(get(handles.e_qb,'String'));
if ~isnan(qb)
    handles.qb = max(handles.qp_lim(1),min(handles.qp_lim(2),qb));
    guidata(hObject, handles);
    dragdata = [2 0 0 0 handles.qb handles.pb 1];
    window_WindowButtonMotionFcn(hObject, eventdata, handles, dragdata);
else
    updatefields(hObject, eventdata, handles);
end

% ---------------------------------------------------------------
function e_Zpb_Callback(hObject, eventdata, handles)
% Entrada manual de Zpb

Zpb = str2double(get(handles.e_Zpb,'String'));
if ~isnan(Zpb)
    handles.Zpb = max(handles.VZ_lim(3),min(handles.VZ_lim(4),Zpb));
    guidata(hObject, handles);
    dragdata = [4 0 0 0 handles.Vb handles.Zpb 1];
    window_WindowButtonMotionFcn(hObject, eventdata, handles, dragdata);
else
    updatefields(hObject, eventdata, handles);
end

% ---------------------------------------------------------------
function e_Vb_Callback(hObject, eventdata, handles)
% Entrada manual de Vb

Vb = str2double(get(handles.e_Vb,'String'));
if ~isnan(Vb)
    handles.Vb = max(handles.VZ_lim(1),min(handles.VZ_lim(2),Vb));
    guidata(hObject, handles);
    dragdata = [4 0 0 0 handles.Vb handles.Zpb 1];
    window_WindowButtonMotionFcn(hObject, eventdata, handles, dragdata);
else
    updatefields(hObject, eventdata, handles);
end

% ---------------------------------------------------------------
function e_Mb_Callback(hObject, eventdata, handles)
% Entrada manual de Mb

Mb = str2double(get(handles.e_Mb,'String'));
if ~isnan(Mb)
    Vb = qc2vc(m2qcpa(Mb)*handles.pb);
    handles.Vb = max(handles.VZ_lim(1),min(handles.VZ_lim(2),Vb));
    guidata(hObject, handles);
    dragdata = [4 0 0 0 handles.Vb handles.Zpb 1];
    window_WindowButtonMotionFcn(hObject, eventdata, handles, dragdata);
else
    updatefields(hObject, eventdata, handles);
end

% ---------------------------------------------------------------
function e_DISA_Callback(hObject, eventdata, handles)
% Entrada manual de DISA

DISA = str2double(get(handles.e_DISA,'String'));
if ~isnan(DISA)
    DISA = max(-30,min(30,DISA));
    set(handles.slider2,'Value',DISA);
end
slider2_Callback(hObject, eventdata, handles);

% ---------------------------------------------------------------
function e_TaISA_Callback(hObject, eventdata, handles)
% Entrada manual de TaISA

TaISA = str2double(get(handles.e_TaISA,'String'))+handles.dT;
if ~isnan(TaISA)
    Zp = ta2zp(TaISA);
    handles.Zp = max(handles.VZ_lim(3),min(handles.VZ_lim(4),Zp));
    guidata(hObject, handles);
    dragdata = [5 0 0 0 handles.Vc handles.Zp 1];
    window_WindowButtonMotionFcn(hObject, eventdata, handles, dragdata);
else
    updatefields(hObject, eventdata, handles);
end

% ---------------------------------------------------------------
function e_Ta_Callback(hObject, eventdata, handles)
% Entrada manual de Ta

Ta = str2double(get(handles.e_Ta,'String'));
if ~isnan(Ta)
    DISA = Ta - handles.TaISA;
    DISA = max(-30,min(30,DISA));
    handles.Ta = handles.TaISA + DISA;
    set(handles.slider2,'Value',DISA);
end
slider2_Callback(hObject, eventdata, handles);

% ---------------------------------------------------------------
function e_a_Callback(hObject, eventdata, handles)
% Entrada manual de a (desativada)

% ---------------------------------------------------------------
function e_Va_Callback(hObject, eventdata, handles)
% Entrada manual de Va

Va = str2double(get(handles.e_Va,'String'));
if ~isnan(Va)
    handles.Va = max(handles.VZ_lim(1),min(handles.VZ_lim(2),Va));
    guidata(hObject, handles);
    dragdata = [7 0 0 0 handles.Va handles.Zp 1];
    window_WindowButtonMotionFcn(hObject, eventdata, handles, dragdata);
else
    updatefields(hObject, eventdata, handles);
end

% ---------------------------------------------------------------
function e_rho_Callback(hObject, eventdata, handles)
% Entrada manual de ro (desativada)

% ---------------------------------------------------------------
function e_Ve_Callback(hObject, eventdata, handles)
% Entrada manual de Ve

Ve = str2double(get(handles.e_Ve,'String'));
if ~isnan(Ve)
    handles.Ve = max(handles.VZ_lim(1),min(handles.VZ_lim(2),Ve));
    guidata(hObject, handles);
    dragdata = [6 0 0 0 handles.Ve handles.Zp 1];
    window_WindowButtonMotionFcn(hObject, eventdata, handles, dragdata);
else
    updatefields(hObject, eventdata, handles);
end

% ---------------------------------------------------------------
function e_q_Callback(hObject, eventdata, handles)
% Entrada manual de q

q = str2double(get(handles.e_q,'String'));
if ~isnan(q)
    q = max(0,q);
    Ve = sqrt(2*q*100/handles.rho0)/(1852/3600);
    set(handles.e_Ve,'String',num2str(Ve));
    e_Ve_Callback(hObject, eventdata, handles);
else
    updatefields(hObject, eventdata, handles);
end

% ---------------------------------------------------------------
function e_delta_Callback(hObject, eventdata, handles)
% Entrada manual de delta (desativada)

% ---------------------------------------------------------------
function e_sigma_Callback(hObject, eventdata, handles)
% Entrada manual de sigma (desativada)

% ---------------------------------------------------------------
function e_teta_Callback(hObject, eventdata, handles)
% Entrada manual de teta (desativada)

% ---------------------------------------------------------------
function dir2_ButtonDownFcn(hObject, eventdata, handles)
% Indiciador da direçao da movimentaçao dos pontos do grafico qc x pa

switch get(handles.dir2,'String');
    case '+'
        set(handles.dir2,'String','-','FontSize',12);
    case '-'
        set(handles.dir2,'String','|','FontSize',4);
    case '|'
        set(handles.dir2,'String','/','FontSize',8);
    case '/'
        set(handles.dir2,'String','+','FontSize',10);
end

% ---------------------------------------------------------------
function dir3_ButtonDownFcn(hObject, eventdata, handles)
% Indiciador da direçao da movimentaçao dos pontos do grafico Vc x Zp

switch get(handles.dir3,'String');
    case '+'
        set(handles.dir3,'String','-','FontSize',12);
    case '-'
        set(handles.dir3,'String','|','FontSize',4);
    case '|'
        set(handles.dir3,'String','\','FontSize',8);
    case '\'
        set(handles.dir3,'String','+','FontSize',10);
end

% ---------------------------------------------------------------
% -- WINDOW FUNCTIONS -------------------------------------------
% ---------------------------------------------------------------

function window_WindowButtonDownFcn(hObject, eventdata, handles)
% Funçao de clique do mouse

n = find(handles.axeslist == gca);

cp  = get(handles.axeslist(n),'CurrentPoint');
ct  = get(handles.window,'SelectionType');
cur = get(0,'PointerLocation');

if isempty(cp)
    return
end

x = cp(1,1);
y = cp(1,2);

k = 0;

switch n % Numero do grafico
    
    case 1 % Malha de dados
        H = findobj(handles.axes1,'Type','text');
        for n = 1:length(H)
            pos = get(H(n),'Position');
            if abs(x-pos(1)) < .01 && abs(y-pos(2)) < .01
                k = 1;
                h = H(n);
                d = 1;
                break
            end
        end
        
    case 2 % qc x pa
        ax = diff(get(handles.axeslist(n),'XLim'));
        ay = diff(get(handles.axeslist(n),'YLim'));
        pos = get(handles.axeslist(n),'Position');
        
        xp1 = get(handles.p_qbpb,'XData');
        yp1 = get(handles.p_qbpb,'YData');
        xp2 = get(handles.p_qcpa,'XData');
        yp2 = get(handles.p_qcpa,'YData');
        
        if abs(x-xp1) < 4*ax/pos(3) && abs(y-yp1) < 4*ay/pos(4) % Basico
            k = 2;
            h = handles.p_qbpb;
        elseif abs(x-xp2) < 4*ax/pos(3) && abs(y-yp2) < 4*ay/pos(4) % Calibrado
            k = 3;
            h = handles.p_qcpa;
        else
            switch ct
                case 'normal' % Esq
                    setappdata(handles.window,'fixcur',1);
                    p1 = get(handles.axeslist(n),'CurrentPoint');
                    rbbox;
                    p2 = get(handles.axeslist(n),'CurrentPoint');
                    setappdata(handles.window,'fixcur',0);
                    updatescale(hObject, eventdata, handles, [n sort([p1(1,1) p2(1,1)]) sort([p1(1,2) p2(1,2)])]);
                case 'alt'    % Dir
                    setappdata(handles.window,'fixcur',1);
                    set(handles.window,'Pointer','arrow');
                case 'open'   % Duplo
                    if y > handles.p_lim(1) && y < handles.p_lim(2)
                        updatescale(hObject, eventdata, handles, [n+1 0 700 0 50000]);
                    end
            end
        end
        
        switch get(handles.dir2,'String');
            case '+'
                d = 1;
            case '-'
                d = 2;
            case '|'
                d = 3;
            case '/'
                d = 4;
        end
        
    case 3 % Vc x Zp
        ax = diff(get(handles.axeslist(n),'XLim'));
        ay = diff(get(handles.axeslist(n),'YLim'));
        pos = get(handles.axeslist(n),'Position');

        xp1 = get(handles.p_VbZpb,'XData');
        yp1 = get(handles.p_VbZpb,'YData');
        xp2 = get(handles.p_VcZp,'XData');
        yp2 = get(handles.p_VcZp,'YData');
        xp3 = get(handles.p_VeZp,'XData');
        yp3 = get(handles.p_VeZp,'YData');
        xp4 = get(handles.p_VaZp,'XData');
        yp4 = get(handles.p_VaZp,'YData');

        if abs(x-xp1) < 4*ax/pos(3) && abs(y-yp1) < 4*ay/pos(4) % Basico
            k = 4;
            h = handles.p_VbZpb;
        elseif abs(x-xp2) < 4*ax/pos(3) && abs(y-yp2) < 4*ay/pos(4) % Calibrado
            k = 5;
            h = handles.p_VcZp;
        elseif abs(x-xp3) < 4*ax/pos(3) && abs(y-yp3) < 4*ay/pos(4) % Ve
            k = 6;
            h = handles.p_VeZp;
        elseif abs(x-xp4) < 4*ax/pos(3) && abs(y-yp4) < 4*ay/pos(4) % Va
            k = 7;
            h = handles.p_VaZp;
        else
            switch ct
                case 'normal' % Esq
                    setappdata(handles.window,'fixcur',1);
                    p1 = get(handles.axeslist(n),'CurrentPoint');
                    rbbox;
                    p2 = get(handles.axeslist(n),'CurrentPoint');
                    setappdata(handles.window,'fixcur',0);
                    updatescale(hObject, eventdata, handles, [n sort([p1(1,1) p2(1,1)]) sort([p1(1,2) p2(1,2)])]);
                case 'alt'    % Dir
                    setappdata(handles.window,'fixcur',1);
                    set(handles.window,'Pointer','arrow');
                case 'open'   % Duplo
                    if y > handles.Z_lim(1) && y < handles.Z_lim(2)
                        updatescale(hObject, eventdata, handles, [n 0 700 0 50000]);
                    end
            end
        end
        
        switch get(handles.dir3,'String');
            case '+'
                d = 1;
            case '-'
                d = 2;
            case '|'
                d = 3;
            case '\'
                d = 4;
        end

end

if k
    setappdata(handles.window,'dragdata',[k h cur x y d]);
    if k > 1
        set(handles.window,'Pointer','arrow');
    end
else
    setappdata(handles.window,'dragdata',0);
end

% ---------------------------------------------------------------
function window_WindowButtonMotionFcn(hObject, eventdata, handles, dragdata)
% Funçao de movimentaçao do mouse

if ~isfield(handles,'axeslist')
    return
end

if nargin == 3
    dragdata = getappdata(handles.window,'dragdata');
    n = find(handles.axeslist == gca);
end

if dragdata(1)
    H  = dragdata(2);
    cx = dragdata(3);
    cy = dragdata(4);
    x  = dragdata(5);
    y  = dragdata(6);
    d  = dragdata(7);
    
    if H
        cur = get(0,'PointerLocation');
        ax = diff(get(handles.axeslist(n),'XLim'));
        ay = diff(get(handles.axeslist(n),'YLim'));
        pos = get(handles.axeslist(n),'Position');
        
        dx = ax/pos(3)*(cur(1)-cx);
        dy = ay/pos(4)*(cur(2)-cy);
    else
        dx = 0;
        dy = 0;
    end
    
    switch dragdata(1)
        case 1 % Malha
            set(H,'Position',[max(0,min(1,x+dx)) max(0,min(1,y+dy)) 1]);
            updatelines(hObject, eventdata, handles);
            
        case 2 % qb, pb
            if H
                if d == 4
                    handles.pb = min(handles.p_lim(2),max(handles.p_lim(1),y+dy));
                    handles.qb = m2qcpa(handles.Mb)*handles.pb;
                else
                    if d ~= 3, handles.qb = min(handles.q_lim(2),max(handles.q_lim(1),x+dx)); end
                    if d ~= 2, handles.pb = min(handles.p_lim(2),max(handles.p_lim(1),y+dy)); end
                end
            else
                handles.qb = min(handles.qp_lim(2),max(handles.qp_lim(1),x+dx));
                handles.pb = min(handles.qp_lim(4),max(handles.qp_lim(3),y+dy));
            end
            
            handles.qc    = max(handles.qp_lim(1),handles.qb-handles.Dqb);
            handles.pa    = handles.pb-handles.Dpb;
            handles.Vb    = qc2vc(handles.qb);
            handles.Zpb   = pa2zp(handles.pb);
            if d ~= 4, handles.Mb    = qcpa2m(handles.qb,handles.pb); end
            handles.Vc    = qc2vc(handles.qc);
            handles.Zp    = pa2zp(handles.pa);
            handles.M     = qcpa2m(handles.qc,handles.pa);
            handles.TaISA = zp2ta(handles.Zp)-handles.dT;
            handles.Ta    = handles.TaISA+handles.DISA;
            handles.teta  = (handles.Ta+handles.dT)/(handles.Ta0+handles.dT);
            handles.rho   = handles.pa*100/(handles.R*(handles.Ta+handles.dT));
            handles.sigma = handles.rho/handles.rho0;
            handles.delta = handles.pa/handles.pa0;
            handles.a     = sqrt(handles.gama*handles.R*(handles.Ta+handles.dT))/(1852/3600);
            handles.Va    = handles.a*handles.M;
            handles.Ve    = handles.Va*sqrt(handles.rho/handles.rho0);
            handles.q     = .5*handles.rho0*(handles.Ve*1852/3600)^2/100;

        case 3 % qc, pa
            if H
                if d == 4
                    handles.pa = min(handles.p_lim(2),max(handles.p_lim(1),y+dy));
                    handles.qc = m2qcpa(handles.M)*handles.pa;
                else
                    if d ~= 3, handles.qc = min(handles.q_lim(2),max(handles.q_lim(1),x+dx)); end
                    if d ~= 2, handles.pa = min(handles.p_lim(2),max(handles.p_lim(1),y+dy)); end
                end
            else
                handles.qc = min(handles.qp_lim(2),max(handles.qp_lim(1),x+dx));
                handles.pa = min(handles.qp_lim(4),max(handles.qp_lim(3),y+dy));
            end
            
            handles.qb    = max(handles.qp_lim(1),handles.qc+handles.Dqb);
            handles.pb    = handles.pa+handles.Dpb;
            handles.Vb    = qc2vc(handles.qb);
            handles.Zpb   = pa2zp(handles.pb);
            handles.Mb    = qcpa2m(handles.qb,handles.pb);
            handles.Vc    = qc2vc(handles.qc);
            handles.Zp    = pa2zp(handles.pa);
            if d ~= 4, handles.M = qcpa2m(handles.qc,handles.pa); end
            handles.TaISA = zp2ta(handles.Zp)-handles.dT;
            handles.Ta    = handles.TaISA+handles.DISA;
            handles.teta  = (handles.Ta+handles.dT)/(handles.Ta0+handles.dT);
            handles.rho   = handles.pa*100/(handles.R*(handles.Ta+handles.dT));
            handles.sigma = handles.rho/handles.rho0;
            handles.delta = handles.pa/handles.pa0;
            handles.a     = sqrt(handles.gama*handles.R*(handles.Ta+handles.dT))/(1852/3600);
            handles.Va    = handles.a*handles.M;
            handles.Ve    = handles.Va*sqrt(handles.rho/handles.rho0);
            handles.q     = .5*handles.rho0*(handles.Ve*1852/3600)^2/100;

        case 4 % Vb, Zpb
            if H
                if d == 4
                    handles.Zpb = min(handles.Z_lim(2),max(handles.Z_lim(1),y+dy));
                    handles.Vb  = qc2vc(m2qcpa(handles.Mb)*zp2pa(handles.Zpb));
                else
                    if d ~= 3, handles.Vb  = min(handles.V_lim(2),max(handles.V_lim(1),x+dx)); end
                    if d ~= 2, handles.Zpb = min(handles.Z_lim(2),max(handles.Z_lim(1),y+dy)); end
                end
            else
                handles.Vb  = min(handles.VZ_lim(2),max(handles.VZ_lim(1),x+dx));
                handles.Zpb = min(handles.VZ_lim(4),max(handles.VZ_lim(3),y+dy));
            end
            
            handles.qb    = vc2qc(handles.Vb);
            handles.pb    = zp2pa(handles.Zpb);
            handles.qc    = max(handles.qp_lim(1),handles.qb-handles.Dqb);
            handles.pa    = handles.pb-handles.Dpb;
            if d ~= 4, handles.Mb = qcpa2m(handles.qb,handles.pb); end
            handles.Vc    = qc2vc(handles.qc);
            handles.Zp    = pa2zp(handles.pa);
            handles.M     = qcpa2m(handles.qc,handles.pa);
            handles.TaISA = zp2ta(handles.Zp)-handles.dT;
            handles.Ta    = handles.TaISA+handles.DISA;
            handles.teta  = (handles.Ta+handles.dT)/(handles.Ta0+handles.dT);
            handles.rho   = handles.pa*100/(handles.R*(handles.Ta+handles.dT));
            handles.sigma = handles.rho/handles.rho0;
            handles.delta = handles.pa/handles.pa0;
            handles.a     = sqrt(handles.gama*handles.R*(handles.Ta+handles.dT))/(1852/3600);
            handles.Va    = handles.a*handles.M;
            handles.Ve    = handles.Va*sqrt(handles.rho/handles.rho0);
            handles.q     = .5*handles.rho0*(handles.Ve*1852/3600)^2/100;
            
        case 5 % Vc, Zp
            if H
                if d == 4
                    handles.Zp = min(handles.Z_lim(2),max(handles.Z_lim(1),y+dy));
                    handles.Vc = qc2vc(m2qcpa(handles.M)*zp2pa(handles.Zp));
                else
                    if d ~= 3, handles.Vc = min(handles.V_lim(2),max(handles.V_lim(1),x+dx)); end
                    if d ~= 2, handles.Zp = min(handles.Z_lim(2),max(handles.Z_lim(1),y+dy)); end
                end
            else
                handles.Vc = min(handles.VZ_lim(2),max(handles.VZ_lim(1),x+dx));
                handles.Zp = min(handles.VZ_lim(4),max(handles.VZ_lim(3),y+dy));
            end
            
            handles.qc    = vc2qc(handles.Vc);
            handles.pa    = zp2pa(handles.Zp);
            handles.qb    = max(handles.qp_lim(1),handles.qc+handles.Dqb);
            handles.pb    = handles.pa+handles.Dpb;
            handles.Vb    = qc2vc(handles.qb);
            handles.Zpb   = pa2zp(handles.pb);
            handles.Mb    = qcpa2m(handles.qb,handles.pb);
            if d ~= 4, handles.M = qcpa2m(handles.qc,handles.pa); end
            handles.TaISA = zp2ta(handles.Zp)-handles.dT;
            handles.Ta    = handles.TaISA+handles.DISA;
            handles.teta  = (handles.Ta+handles.dT)/(handles.Ta0+handles.dT);
            handles.rho   = handles.pa*100/(handles.R*(handles.Ta+handles.dT));
            handles.sigma = handles.rho/handles.rho0;
            handles.delta = handles.pa/handles.pa0;
            handles.a     = sqrt(handles.gama*handles.R*(handles.Ta+handles.dT))/(1852/3600);
            handles.Va    = handles.a*handles.M;
            handles.Ve    = handles.Va*sqrt(handles.sigma);
            handles.q     = .5*handles.rho0*(handles.Ve*1852/3600)^2/100;

        case 6 % Ve, Zp
            if H
                if d == 4
                    handles.Zp    = min(handles.Z_lim(2),max(handles.Z_lim(1),y+dy));
                    handles.pa    = zp2pa(handles.Zp);
                    handles.TaISA = zp2ta(handles.Zp)-handles.dT;
                    handles.Ta    = handles.TaISA+handles.DISA;
                    handles.rho   = handles.pa*100/(handles.R*(handles.Ta+handles.dT));
                    handles.sigma = handles.rho/handles.rho0;
                    handles.a     = sqrt(handles.gama*handles.R*(handles.Ta+handles.dT))/(1852/3600);
                    handles.Va    = handles.a*handles.M;
                    handles.Ve    = handles.Va*sqrt(handles.sigma);
                else
                    if d ~= 3, handles.Ve = min(handles.V_lim(2),max(handles.V_lim(1),x+dx)); end
                    if d ~= 2, handles.Zp = min(handles.Z_lim(2),max(handles.Z_lim(1),y+dy)); end
                end
            else
                handles.Ve = min(handles.VZ_lim(2),max(handles.VZ_lim(1),x+dx));
                handles.Zp = min(handles.VZ_lim(4),max(handles.VZ_lim(3),y+dy));
            end
            
            handles.q     = .5*handles.rho0*(handles.Ve*1852/3600)^2/100;
            handles.pa    = zp2pa(handles.Zp);
            handles.pb    = handles.pa+handles.Dpb;
            handles.Zpb   = pa2zp(handles.pb);
            handles.TaISA = zp2ta(handles.Zp)-handles.dT;
            handles.Ta    = handles.TaISA+handles.DISA;
            handles.teta  = (handles.Ta+handles.dT)/(handles.Ta0+handles.dT);
            handles.rho   = handles.pa*100/(handles.R*(handles.Ta+handles.dT));
            handles.sigma = handles.rho/handles.rho0;
            handles.delta = handles.pa/handles.pa0;
            handles.a     = sqrt(handles.gama*handles.R*(handles.Ta+handles.dT))/(1852/3600);
            handles.Va    = handles.Ve/sqrt(handles.sigma);
            if d ~= 4, handles.M = handles.Va/handles.a; end
            handles.qc    = m2qcpa(handles.M)*handles.pa;
            handles.Vc    = qc2vc(handles.qc);
            handles.qb    = max(0,handles.qc+handles.Dqb);
            handles.Vb    = qc2vc(handles.qb);
            handles.Mb    = qcpa2m(handles.qb,handles.pb);
            
        case 7 % Va, Zp
            if H
                if d == 4
                    handles.Zp    = min(handles.Z_lim(2),max(handles.Z_lim(1),y+dy));
                    handles.TaISA = zp2ta(handles.Zp)-handles.dT;
                    handles.Ta    = handles.TaISA+handles.DISA;
                    handles.a     = sqrt(handles.gama*handles.R*(handles.Ta+handles.dT))/(1852/3600);
                    handles.Va    = handles.a*handles.M;
                else
                    if d ~= 3, handles.Va = min(handles.V_lim(2),max(handles.V_lim(1),x+dx)); end
                    if d ~= 2, handles.Zp = min(handles.Z_lim(2),max(handles.Z_lim(1),y+dy)); end
                end
            else
                handles.Va = min(handles.VZ_lim(2),max(handles.VZ_lim(1),x+dx));
                handles.Zp = min(handles.VZ_lim(4),max(handles.VZ_lim(3),y+dy));
            end
            
            handles.pa    = zp2pa(handles.Zp);
            handles.pb    = handles.pa+handles.Dpb;
            handles.Zpb   = pa2zp(handles.pb);
            handles.TaISA = zp2ta(handles.Zp)-handles.dT;
            handles.Ta    = handles.TaISA+handles.DISA;
            handles.teta  = (handles.Ta+handles.dT)/(handles.Ta0+handles.dT);
            handles.rho   = handles.pa*100/(handles.R*(handles.Ta+handles.dT));
            handles.sigma = handles.rho/handles.rho0;
            handles.Ve    = handles.Va*sqrt(handles.sigma);
            handles.q     = .5*handles.rho0*(handles.Ve*1852/3600)^2/100;
            handles.delta = handles.pa/handles.pa0;
            handles.a     = sqrt(handles.gama*handles.R*(handles.Ta+handles.dT))/(1852/3600);
            if d ~= 4, handles.M = handles.Va/handles.a; end
            handles.qc    = m2qcpa(handles.M)*handles.pa;
            handles.Vc    = qc2vc(handles.qc);
            handles.qb    = max(0,handles.qc+handles.Dqb);
            handles.Vb    = qc2vc(handles.qb);
            handles.Mb    = qcpa2m(handles.qb,handles.pb);
            
    end
    
    if dragdata(1) > 1
        guidata(hObject, handles);
        updatefields(hObject, eventdata, handles);
    end
    
else
    updatecursor(hObject, eventdata, handles);
end

% ---------------------------------------------------------------
function window_WindowButtonUpFcn(hObject, eventdata, handles)
% Funçao de soltura do botao do mouse

setappdata(handles.window,'dragdata',0);
updatecursor(hObject, eventdata, handles);

% ---------------------------------------------------------------
function window_ResizeFcn(hObject, eventdata, handles)
% Alteraçao do tamanho da janela

minsize = [700 540];
ws = get(handles.window,'Position');
if ws(3) < minsize(1)
    ws(3) = minsize(1);
end
if ws(4) < minsize(2)
    ws(4) = minsize(2);
end
set(handles.window,'Position',ws);

set(handles.help_btn,'Position',[10 ws(4)-30 22 22]);

X = ws(3)*440/700;
Y = ws(4)-90;

set(handles.axes1  ,'Position',[20 20 X-40 ws(4)-40]);
set(handles.axes2  ,'Position',[X+40 Y/2+115 ws(3)-X-60 Y/2-45]);
set(handles.axes3  ,'Position',[X+40 110 ws(3)-X-60 Y/2-45]);

set(handles.dir2   ,'Position',[ws(3)-32 Y/2+115-29 10 14]);
set(handles.dir3   ,'Position',[ws(3)-32 110-29 10 14]);

set(handles.legend1,'Position',[X 10 35 60]);
set(handles.slider1,'Position',[X+40 50 ws(3)-X-60 14]);
set(handles.slider3,'Position',[X+40 30 ws(3)-X-60 14]);
set(handles.slider2,'Position',[X+40 10 ws(3)-X-60 14]);
set(handles.chk1   ,'Position',[ws(3)-17 29 16 16]);

set(handles.qpos,'Position',[ws(3)-170 ws(4)-19 50 14]);
set(handles.ppos,'Position',[ws(3)-120 ws(4)-19 50 14]);
set(handles.mpos,'Position',[ws(3)-70  ws(4)-19 50 14]);
set(handles.Vpos,'Position',[ws(3)-170 111+Y/2-45 50 14]);
set(handles.Zpos,'Position',[ws(3)-120 111+Y/2-45 50 14]);
set(handles.Mpos,'Position',[ws(3)-70  111+Y/2-45 50 14]);

updatelines(hObject, eventdata, handles);

% -------------------------------------------------------------------
function window_KeyPressFcn(hObject, eventdata, handles)
% Acionamento de tecla do teclado

cc = get(handles.window,'CurrentCharacter');

if ~isempty(cc) && abs(cc) == 27 % Esc
    window_CloseRequestFcn(hObject, eventdata, handles);
end

% ---------------------------------------------------------------
function window_CloseRequestFcn(hObject, eventdata, handles)
% Solicitaçao de fechamento da janela

button = questdlg('Deseja sair?','Sair','Sim','Não','Não');
if ~strcmp(button,'Sim')
    return
end

if getappdata(handles.window,'moved');
    
    pos_Zp    = get(handles.h_Zp   ,'Position');
    pos_Vc    = get(handles.h_Vc   ,'Position');
    pos_M     = get(handles.h_M    ,'Position');
    pos_pa    = get(handles.h_pa   ,'Position');
    pos_qc    = get(handles.h_qc   ,'Position');
    pos_Dpb   = get(handles.h_Dpb  ,'Position');
    pos_Dqb   = get(handles.h_Dqb  ,'Position');
    pos_pb    = get(handles.h_pb   ,'Position');
    pos_qb    = get(handles.h_qb   ,'Position');
    pos_Zpb   = get(handles.h_Zpb  ,'Position');
    pos_Vb    = get(handles.h_Vb   ,'Position');
    pos_Mb    = get(handles.h_Mb   ,'Position');
    pos_DISA  = get(handles.h_DISA ,'Position');
    pos_TaISA = get(handles.h_TaISA,'Position');
    pos_Ta    = get(handles.h_Ta   ,'Position');
    pos_a     = get(handles.h_a    ,'Position');
    pos_Va    = get(handles.h_Va   ,'Position');
    pos_rho   = get(handles.h_rho  ,'Position');
    pos_Ve    = get(handles.h_Ve   ,'Position');
    pos_q     = get(handles.h_q    ,'Position');
    pos_delta = get(handles.h_delta,'Position');
    pos_sigma = get(handles.h_sigma,'Position');
    pos_teta  = get(handles.h_teta ,'Position');
    
    x_Zp    = pos_Zp(1);     y_Zp    = pos_Zp(2);
    x_Vc    = pos_Vc(1);     y_Vc    = pos_Vc(2);
    x_M     = pos_M(1);      y_M     = pos_M(2);
    x_pa    = pos_pa(1);     y_pa    = pos_pa(2);
    x_qc    = pos_qc(1);     y_qc    = pos_qc(2);
    x_Dpb   = pos_Dpb(1);    y_Dpb   = pos_Dpb(2);
    x_Dqb   = pos_Dqb(1);    y_Dqb   = pos_Dqb(2);
    x_pb    = pos_pb(1);     y_pb    = pos_pb(2);
    x_qb    = pos_qb(1);     y_qb    = pos_qb(2);
    x_Zpb   = pos_Zpb(1);    y_Zpb   = pos_Zpb(2);
    x_Vb    = pos_Vb(1);     y_Vb    = pos_Vb(2);
    x_Mb    = pos_Mb(1);     y_Mb    = pos_Mb(2);
    x_DISA  = pos_DISA(1);   y_DISA  = pos_DISA(2);
    x_TaISA = pos_TaISA(1);  y_TaISA = pos_TaISA(2);
    x_Ta    = pos_Ta(1);     y_Ta    = pos_Ta(2);
    x_a     = pos_a(1);      y_a     = pos_a(2);
    x_Va    = pos_Va(1);     y_Va    = pos_Va(2);
    x_rho   = pos_rho(1);    y_rho   = pos_rho(2);
    x_Ve    = pos_Ve(1);     y_Ve    = pos_Ve(2);
    x_q     = pos_q(1);      y_q     = pos_q(2);
    x_delta = pos_delta(1);  y_delta = pos_delta(2);
    x_sigma = pos_sigma(1);  y_sigma = pos_sigma(2);
    x_teta  = pos_teta(1);   y_teta  = pos_teta(2);
    
    if exist('anemopos.mat','file')
        try
            save(which('anemopos.mat'),'x_Zp','y_Zp','x_Vc','y_Vc','x_M','y_M','x_pa','y_pa','x_qc','y_qc','x_Dpb','y_Dpb','x_Dqb','y_Dqb','x_pb','y_pb','x_qb','y_qb','x_Zpb','y_Zpb','x_Vb','y_Vb',...
                'x_Mb','y_Mb','x_DISA','y_DISA','x_TaISA','y_TaISA','x_Ta','y_Ta','x_a','y_a','x_Va','y_Va','x_rho','y_rho','x_Ve','y_Ve','x_q','y_q','x_delta','y_delta','x_sigma','y_sigma','x_teta','y_teta',saveopt);
        end
    end
    
end

delete(hObject);

% ---------------------------------------------------------------
% -- MENU FUNCTIONS ---------------------------------------------
% ---------------------------------------------------------------

function axes1menu_Callback(hObject, eventdata, handles)
% Menu da malha de dados

% --------------------------------------------------------------------
function reset_Callback(hObject, eventdata, handles)
% Restaurar distribuiçao padrao da mahla de dados

x_Zp    = 0.2113;   y_Zp    = 0.4710;
x_Vc    = 0.9237;   y_Vc    = 0.8110;
x_M     = 0.9688;   y_M     = 0.4130;
x_pa    = 0.3912;   y_pa    = 0.5530;
x_qc    = 0.8238;   y_qc    = 0.6950;
x_Dpb   = 0.5162;   y_Dpb   = 0.6690;
x_Dqb   = 0.6488;   y_Dqb   = 0.7270;
x_pb    = 0.3063;   y_pb    = 0.7690;
x_qb    = 0.6388;   y_qb    = 0.9030;
x_Zpb   = 0.1238;   y_Zpb   = 0.8070;
x_Vb    = 0.7863;   y_Vb    = 0.9810;
x_Mb    = 0.3237;   y_Mb    = 0.9550;
x_DISA  = 0.0963;   y_DISA  = 0.1130;
x_TaISA = 0.1438;   y_TaISA = 0.3150;
x_Ta    = 0.3038;   y_Ta    = 0.1490;
x_a     = 0.8513;   y_a     = 0.0890;
x_Va    = 0.7712;   y_Va    = 0.3050;
x_rho   = 0.5637;   y_rho   = 0.3850;
x_Ve    = 0.6538;   y_Ve    = 0.2010;
x_q     = 0.4788;   y_q     = 0.2510;
x_delta = 0.2088;   y_delta = 0.6070;
x_sigma = 0.7138;   y_sigma = 0.4790;
x_teta  = 0.4362;   y_teta  = 0.0690;

set(handles.h_Zp   ,'Position',[x_Zp   , y_Zp   , 1]);
set(handles.h_Vc   ,'Position',[x_Vc   , y_Vc   , 1]);
set(handles.h_M    ,'Position',[x_M    , y_M    , 1]);
set(handles.h_pa   ,'Position',[x_pa   , y_pa   , 1]);
set(handles.h_qc   ,'Position',[x_qc   , y_qc   , 1]);
set(handles.h_Dpb  ,'Position',[x_Dpb  , y_Dpb  , 1]);
set(handles.h_Dqb  ,'Position',[x_Dqb  , y_Dqb  , 1]);
set(handles.h_pb   ,'Position',[x_pb   , y_pb   , 1]);
set(handles.h_qb   ,'Position',[x_qb   , y_qb   , 1]);
set(handles.h_Zpb  ,'Position',[x_Zpb  , y_Zpb  , 1]);
set(handles.h_Vb   ,'Position',[x_Vb   , y_Vb   , 1]);
set(handles.h_Mb   ,'Position',[x_Mb   , y_Mb   , 1]);
set(handles.h_DISA ,'Position',[x_DISA , y_DISA , 1]);
set(handles.h_TaISA,'Position',[x_TaISA, y_TaISA, 1]);
set(handles.h_Ta   ,'Position',[x_Ta   , y_Ta   , 1]);
set(handles.h_a    ,'Position',[x_a    , y_a    , 1]);
set(handles.h_Va   ,'Position',[x_Va   , y_Va   , 1]);
set(handles.h_rho  ,'Position',[x_rho  , y_rho  , 1]);
set(handles.h_Ve   ,'Position',[x_Ve   , y_Ve   , 1]);
set(handles.h_q    ,'Position',[x_q    , y_q    , 1]);
set(handles.h_delta,'Position',[x_delta, y_delta, 1]);
set(handles.h_sigma,'Position',[x_sigma, y_sigma, 1]);
set(handles.h_teta ,'Position',[x_teta , y_teta , 1]);

updatelines(hObject, eventdata, handles, 1);

setappdata(handles.window,'moved',1);

% --------------------------------------------------------------------
function axes3menu_Callback(hObject, eventdata, handles)
% Menu do grafico Vc x Zp
setappdata(handles.window,'fixcur',0);

% --------------------------------------------------------------------
function editlimits_Callback(hObject, eventdata, handles)
% Editar limites dos graficos Vc x Zp e qc x pa

[Vmin, Vmax, Zmin, Zmax, dMach] = inputvalues('Limites',{'V min (kt):','V max (kt):','Z min (ft):','Z max (ft):','Intervalo de Mach:'},...
    {num2str(handles.V_lim(1)),num2str(handles.V_lim(2)),num2str(handles.Z_lim(1)),num2str(handles.Z_lim(2)),num2str(handles.dMach)});

if isempty(Vmin)
    return
end

Vmin  = roundn(str2double(Vmin),1);
Vmax  = roundn(str2double(Vmax),1);
Zmin  = roundn(str2double(Zmin),2);
Zmax  = roundn(str2double(Zmax),2);
dMach = roundn(str2double(dMach),-2);

if isnan(Vmin+Vmax+Zmin+Zmax+dMach)
    beep; uiwait(errordlg('Um ou mais valores incoerentes.','Erro'));
    return
end
if Vmax-Vmin < 10
    beep; uiwait(errordlg('Limites de velocidade incoerentes.','Erro'));
    return
end
if Zmax-Zmin < 100
    beep; uiwait(errordlg('Limites de altitude incoerentes.','Erro'));
    return
end
if dMach < .02
    beep; uiwait(errordlg('Intervalo de Mach incoerente.','Erro'));
    return
end

delete(findobj(handles.axes2,'Tag','aux'));
delete(findobj(handles.axes3,'Tag','aux'));

handles.V_lim = [max(handles.VZ_lim(1),Vmin) min(handles.VZ_lim(2),Vmax)];
handles.Z_lim = [max(handles.VZ_lim(3),Zmin) min(handles.VZ_lim(4),Zmax)];
handles.q_lim = vc2qc(handles.V_lim);
handles.p_lim = sort(zp2pa(handles.Z_lim));
handles.dMach = max(.01,dMach);
Mmax = qcpa2m(handles.q_lim(2),handles.p_lim(1));

if handles.dMach < .1
    Mstr = '%0.2f';
else
    Mstr = '%0.1f';
end

guidata(hObject, handles);

axes(handles.axes2);
for qcpai = m2qcpa(handles.dMach:handles.dMach:Mmax)
    pai = linspace(handles.p_lim(1),handles.p_lim(2),50);
    qci = qcpai.*pai;
    plot(qci,pai,'-k','HitTest','off','Tag','aux');
    text(max(qci),handles.p_lim(2),num2str(qcpa2m(qcpai,1),Mstr),'Clipping','on','FontSize',8,'HorizontalAlignment','center','VerticalAlignment','top','HitTest','off','Tag','aux');
end
axis([handles.q_lim handles.p_lim]);

axes(handles.axes3);
for Mi = handles.dMach:handles.dMach:Mmax
    Zpi = linspace(handles.Z_lim(1),handles.Z_lim(2),50);
    Vci = qc2vc(m2qcpa(Mi).*zp2pa(Zpi));
    plot(Vci,Zpi,'-k','HitTest','off','Tag','aux');
    text(max(Vci),handles.Z_lim(1),num2str(Mi,Mstr),'Clipping','on','FontSize',8,'HorizontalAlignment','center','VerticalAlignment','bottom','HitTest','off','Tag','aux');
end
axis([handles.V_lim handles.Z_lim]);

% --------------------------------------------------------------------
function updatescale(hObject, eventdata, handles, zoomdata)
% Alterar limites dos graficos Vc x Zp e qc x pa atraves do mouse

n = zoomdata(1);

if n == 2
    Vmin = qc2vc(zoomdata(2));
    Vmax = qc2vc(zoomdata(3));
    Zmin = pa2zp(zoomdata(5));
    Zmax = pa2zp(zoomdata(4));
elseif n == 3
    Vmin = zoomdata(2);
    Vmax = zoomdata(3);
    Zmin = zoomdata(4);
    Zmax = zoomdata(5);
end

Vmin  = roundn(Vmin,1);
Vmax  = roundn(Vmax,1);
Zmin  = roundn(Zmin,2);
Zmax  = roundn(Zmax,2);

if Vmin == Vmax || Zmin == Zmax
    updatecursor(hObject, eventdata, handles);
    return
end

if Vmax-Vmin < 10
    Vm = mean([Vmax Vmin]);
    Vmin = Vm - 5;
    Vmax = Vm + 5;
end
if Zmax-Zmin < 100
    Zm = mean([Zmax Zmin]);
    Zmin = Zm - 50;
    Zmax = Zm + 50;
end

if ~(Vmax > handles.VZ_lim(1) && Vmin < handles.VZ_lim(2) && Zmax > handles.VZ_lim(3) && Zmin < handles.VZ_lim(4))
    updatecursor(hObject, eventdata, handles);
    return
end

delete(findobj(handles.axes2,'Tag','aux'));
delete(findobj(handles.axes3,'Tag','aux'));

handles.V_lim = [max(handles.VZ_lim(1),Vmin) min(handles.VZ_lim(2),Vmax)];
handles.Z_lim = [max(handles.VZ_lim(3),Zmin) min(handles.VZ_lim(4),Zmax)];
handles.q_lim = vc2qc(handles.V_lim);
handles.p_lim = sort(zp2pa(handles.Z_lim));
Mmax = qcpa2m(handles.q_lim(2),handles.p_lim(1));

handles.dMach = (qcpa2m(handles.q_lim(2),handles.p_lim(2))-qcpa2m(handles.q_lim(1),handles.p_lim(2)))/6;
if handles.dMach < .05
    handles.dMach = roundn(handles.dMach,-2);
else
    handles.dMach = roundn(handles.dMach,-1);
end

handles.dMach = max(.01,handles.dMach);

if handles.dMach < .1
    Mstr = '%0.2f';
else
    Mstr = '%0.1f';
end

guidata(hObject, handles);

try
    axes(handles.axes2);
    axis([handles.q_lim handles.p_lim]);
    for qcpai = m2qcpa(handles.dMach:handles.dMach:Mmax)
        pai = linspace(handles.p_lim(1),handles.p_lim(2),50);
        qci = qcpai.*pai;
        plot(qci,pai,'-k','HitTest','off','Tag','aux');
        text(max(qci),handles.p_lim(2),num2str(qcpa2m(qcpai,1),Mstr),'Clipping','on','FontSize',8,'HorizontalAlignment','center','VerticalAlignment','top','HitTest','off','Tag','aux');
    end
    
    axes(handles.axes3);
    axis([handles.V_lim handles.Z_lim]);
    for Mi = handles.dMach:handles.dMach:Mmax
        Zpi = linspace(handles.Z_lim(1),handles.Z_lim(2),50);
        Vci = qc2vc(m2qcpa(Mi).*zp2pa(Zpi));
        plot(Vci,Zpi,'-k','HitTest','off','Tag','aux');
        text(max(Vci),handles.Z_lim(1),num2str(Mi,Mstr),'Clipping','on','FontSize',8,'HorizontalAlignment','center','VerticalAlignment','bottom','HitTest','off','Tag','aux');
    end
end

updatecursor(hObject, eventdata, handles);

% ---------------------------------------------------------------
% -- UPDATE FUNCTIONS -------------------------------------------
% ---------------------------------------------------------------

function updatelines(hObject, eventdata, handles, opt)
% Atualiza as linhas da malha e as posiçoes das caixas de texto

if nargin == 3
    opt = 0;
end

fs = get(handles.window,'Position');
as = get(handles.axes1,'Position');

dragdata = getappdata(handles.window,'dragdata');

if isempty(dragdata)
    return
end

if dragdata(1) || opt
    setappdata(handles.window,'moved',1);
    delete(findobj(handles.axes1,'Type','line'));
end

pos_Zp    = get(handles.h_Zp   ,'Position');
pos_Vc    = get(handles.h_Vc   ,'Position');
pos_M     = get(handles.h_M    ,'Position');
pos_pa    = get(handles.h_pa   ,'Position');
pos_qc    = get(handles.h_qc   ,'Position');
pos_Dpb   = get(handles.h_Dpb  ,'Position');
pos_Dqb   = get(handles.h_Dqb  ,'Position');
pos_pb    = get(handles.h_pb   ,'Position');
pos_qb    = get(handles.h_qb   ,'Position');
pos_Zpb   = get(handles.h_Zpb  ,'Position');
pos_Vb    = get(handles.h_Vb   ,'Position');
pos_Mb    = get(handles.h_Mb   ,'Position');
pos_DISA  = get(handles.h_DISA ,'Position');
pos_TaISA = get(handles.h_TaISA,'Position');
pos_Ta    = get(handles.h_Ta   ,'Position');
pos_a     = get(handles.h_a    ,'Position');
pos_Va    = get(handles.h_Va   ,'Position');
pos_rho   = get(handles.h_rho  ,'Position');
pos_Ve    = get(handles.h_Ve   ,'Position');
pos_q     = get(handles.h_q    ,'Position');
pos_delta = get(handles.h_delta,'Position');
pos_sigma = get(handles.h_sigma,'Position');
pos_teta  = get(handles.h_teta ,'Position');

x_Zp    = pos_Zp(1);     y_Zp    = pos_Zp(2);
x_Vc    = pos_Vc(1);     y_Vc    = pos_Vc(2);
x_M     = pos_M(1);      y_M     = pos_M(2);
x_pa    = pos_pa(1);     y_pa    = pos_pa(2);
x_qc    = pos_qc(1);     y_qc    = pos_qc(2);
x_Dpb   = pos_Dpb(1);    y_Dpb   = pos_Dpb(2);
x_Dqb   = pos_Dqb(1);    y_Dqb   = pos_Dqb(2);
x_pb    = pos_pb(1);     y_pb    = pos_pb(2);
x_qb    = pos_qb(1);     y_qb    = pos_qb(2);
x_Zpb   = pos_Zpb(1);    y_Zpb   = pos_Zpb(2);
x_Vb    = pos_Vb(1);     y_Vb    = pos_Vb(2);
x_Mb    = pos_Mb(1);     y_Mb    = pos_Mb(2);
x_DISA  = pos_DISA(1);   y_DISA  = pos_DISA(2);
x_TaISA = pos_TaISA(1);  y_TaISA = pos_TaISA(2);
x_Ta    = pos_Ta(1);     y_Ta    = pos_Ta(2);
x_a     = pos_a(1);      y_a     = pos_a(2);
x_Va    = pos_Va(1);     y_Va    = pos_Va(2);
x_rho   = pos_rho(1);    y_rho   = pos_rho(2);
x_Ve    = pos_Ve(1);     y_Ve    = pos_Ve(2);
x_q     = pos_q(1);      y_q     = pos_q(2);
x_delta = pos_delta(1);  y_delta = pos_delta(2);
x_sigma = pos_sigma(1);  y_sigma = pos_sigma(2);
x_teta  = pos_teta(1);   y_teta  = pos_teta(2);

pos = get(handles.e_Zp,'Position');
ew = pos(3);
eh = pos(4);

set(handles.e_Zp   ,'Position', [as(3)/fs(3)*(x_Zp   *fs(3))-ew/2+as(1)  as(4)/fs(4)*(y_Zp   *fs(4))-30+as(2) ew eh]);
set(handles.e_Vc   ,'Position', [as(3)/fs(3)*(x_Vc   *fs(3))-ew/2+as(1)  as(4)/fs(4)*(y_Vc   *fs(4))-30+as(2) ew eh]);
set(handles.e_M    ,'Position', [as(3)/fs(3)*(x_M    *fs(3))-ew/2+as(1)  as(4)/fs(4)*(y_M    *fs(4))-30+as(2) ew eh]);
set(handles.e_pa   ,'Position', [as(3)/fs(3)*(x_pa   *fs(3))-ew/2+as(1)  as(4)/fs(4)*(y_pa   *fs(4))-30+as(2) ew eh]);
set(handles.e_qc   ,'Position', [as(3)/fs(3)*(x_qc   *fs(3))-ew/2+as(1)  as(4)/fs(4)*(y_qc   *fs(4))-30+as(2) ew eh]);
set(handles.e_Dpb  ,'Position', [as(3)/fs(3)*(x_Dpb  *fs(3))-ew/2+as(1)  as(4)/fs(4)*(y_Dpb  *fs(4))-30+as(2) ew eh]);
set(handles.e_Dqb  ,'Position', [as(3)/fs(3)*(x_Dqb  *fs(3))-ew/2+as(1)  as(4)/fs(4)*(y_Dqb  *fs(4))-30+as(2) ew eh]);
set(handles.e_pb   ,'Position', [as(3)/fs(3)*(x_pb   *fs(3))-ew/2+as(1)  as(4)/fs(4)*(y_pb   *fs(4))-30+as(2) ew eh]);
set(handles.e_qb   ,'Position', [as(3)/fs(3)*(x_qb   *fs(3))-ew/2+as(1)  as(4)/fs(4)*(y_qb   *fs(4))-30+as(2) ew eh]);
set(handles.e_Zpb  ,'Position', [as(3)/fs(3)*(x_Zpb  *fs(3))-ew/2+as(1)  as(4)/fs(4)*(y_Zpb  *fs(4))-30+as(2) ew eh]);
set(handles.e_Vb   ,'Position', [as(3)/fs(3)*(x_Vb   *fs(3))-ew/2+as(1)  as(4)/fs(4)*(y_Vb   *fs(4))-30+as(2) ew eh]);
set(handles.e_Mb   ,'Position', [as(3)/fs(3)*(x_Mb   *fs(3))-ew/2+as(1)  as(4)/fs(4)*(y_Mb   *fs(4))-30+as(2) ew eh]);
set(handles.e_DISA ,'Position', [as(3)/fs(3)*(x_DISA *fs(3))-ew/2+as(1)  as(4)/fs(4)*(y_DISA *fs(4))-30+as(2) ew eh]);
set(handles.e_TaISA,'Position', [as(3)/fs(3)*(x_TaISA*fs(3))-ew/2+as(1)  as(4)/fs(4)*(y_TaISA*fs(4))-30+as(2) ew eh]);
set(handles.e_Ta   ,'Position', [as(3)/fs(3)*(x_Ta   *fs(3))-ew/2+as(1)  as(4)/fs(4)*(y_Ta   *fs(4))-30+as(2) ew eh]);
set(handles.e_a    ,'Position', [as(3)/fs(3)*(x_a    *fs(3))-ew/2+as(1)  as(4)/fs(4)*(y_a    *fs(4))-30+as(2) ew eh]);
set(handles.e_Va   ,'Position', [as(3)/fs(3)*(x_Va   *fs(3))-ew/2+as(1)  as(4)/fs(4)*(y_Va   *fs(4))-30+as(2) ew eh]);
set(handles.e_rho  ,'Position', [as(3)/fs(3)*(x_rho  *fs(3))-ew/2+as(1)  as(4)/fs(4)*(y_rho  *fs(4))-30+as(2) ew eh]);
set(handles.e_Ve   ,'Position', [as(3)/fs(3)*(x_Ve   *fs(3))-ew/2+as(1)  as(4)/fs(4)*(y_Ve   *fs(4))-30+as(2) ew eh]);
set(handles.e_q    ,'Position', [as(3)/fs(3)*(x_q    *fs(3))-ew/2+as(1)  as(4)/fs(4)*(y_q    *fs(4))-30+as(2) ew eh]);
set(handles.e_delta,'Position', [as(3)/fs(3)*(x_delta*fs(3))-ew/2+as(1)  as(4)/fs(4)*(y_delta*fs(4))-30+as(2) ew eh]);
set(handles.e_sigma,'Position', [as(3)/fs(3)*(x_sigma*fs(3))-ew/2+as(1)  as(4)/fs(4)*(y_sigma*fs(4))-30+as(2) ew eh]);
set(handles.e_teta ,'Position', [as(3)/fs(3)*(x_teta *fs(3))-ew/2+as(1)  as(4)/fs(4)*(y_teta *fs(4))-30+as(2) ew eh]);

if dragdata(1) || opt
    
    x_Mb_qb_pb      = mean([x_Mb x_qb x_pb ]);      y_Mb_qb_pb      = mean([y_Mb y_qb y_pb]);
    x_pa_pb_Dpb     = mean([x_pa x_pb x_Dpb]);      y_pa_pb_Dpb     = mean([y_pa y_pb y_Dpb]);
    x_qc_qb_Dqb     = mean([x_qc x_qb x_Dqb]);      y_qc_qb_Dqb     = mean([y_qc y_qb y_Dqb]);
    x_M_qc_pa       = mean([x_M x_qc x_pa ]);       y_M_qc_pa       = mean([y_M y_qc y_pa]);
    x_TaISA_Ta_DISA = mean([x_TaISA x_Ta x_DISA]);  y_TaISA_Ta_DISA = mean([y_TaISA y_Ta y_DISA]);
    x_Ve_Va_rho     = mean([x_Ve x_Va x_rho]);      y_Ve_Va_rho     = mean([y_Ve y_Va y_rho]);
    x_pa_Ta_rho     = mean([x_pa x_Ta x_rho]);      y_pa_Ta_rho     = mean([y_pa y_Ta y_rho]);
    x_M_Va_a        = mean([x_M x_Va x_a]);         y_M_Va_a        = mean([y_M y_Va y_a]);
    
    axes(handles.axes1);
    plot([x_qb x_Vb],[y_qb y_Vb],'-k');
    plot([x_qc x_Vc],[y_qc y_Vc],'-k');
    if get(handles.chk1,'Value')
        plot([x_Dpb x_Dqb],[y_Dpb y_Dqb],'-k');
    end
    plot([x_Zpb x_pb],[y_Zpb y_pb],'-k');
    plot([x_Zp x_pa],[y_Zp y_pa],'-k');
    plot([x_delta x_pa],[y_delta y_pa],'-k');
    plot([x_Zp x_TaISA],[y_Zp y_TaISA],'-k');
    plot([x_Ta x_teta],[y_Ta y_teta],'-k');
    plot([x_Ta x_a],[y_Ta y_a],'-k');
    plot([x_rho x_sigma],[y_rho y_sigma],'-k');
    plot([x_Ve x_q],[y_Ve y_q],'-k');
    
    plot([x_Mb_qb_pb x_Mb NaN x_Mb_qb_pb x_qb NaN x_Mb_qb_pb x_pb]     , [y_Mb_qb_pb y_Mb NaN y_Mb_qb_pb y_qb NaN y_Mb_qb_pb y_pb],'-k');
    plot([x_pa_pb_Dpb x_pa NaN x_pa_pb_Dpb x_pb NaN x_pa_pb_Dpb x_Dpb] , [y_pa_pb_Dpb y_pa NaN y_pa_pb_Dpb y_pb NaN y_pa_pb_Dpb y_Dpb],'-k');
    plot([x_qc_qb_Dqb x_qc NaN x_qc_qb_Dqb x_qb NaN x_qc_qb_Dqb x_Dqb] , [y_qc_qb_Dqb y_qc NaN y_qc_qb_Dqb y_qb NaN y_qc_qb_Dqb y_Dqb],'-k');
    plot([x_M_qc_pa x_M NaN x_M_qc_pa x_qc NaN x_M_qc_pa x_pa]         , [y_M_qc_pa y_M NaN y_M_qc_pa y_qc NaN y_M_qc_pa y_pa],'-k');
    plot([x_TaISA_Ta_DISA x_TaISA NaN x_TaISA_Ta_DISA x_Ta NaN x_TaISA_Ta_DISA x_DISA],[y_TaISA_Ta_DISA y_TaISA NaN y_TaISA_Ta_DISA y_Ta NaN y_TaISA_Ta_DISA y_DISA],'-k');
    plot([x_Ve_Va_rho x_Ve NaN x_Ve_Va_rho x_Va NaN x_Ve_Va_rho x_rho] , [y_Ve_Va_rho y_Ve NaN y_Ve_Va_rho y_Va NaN y_Ve_Va_rho y_rho],'-k');
    plot([x_pa_Ta_rho x_pa NaN x_pa_Ta_rho x_Ta NaN x_pa_Ta_rho x_rho] , [y_pa_Ta_rho y_pa NaN y_pa_Ta_rho y_Ta NaN y_pa_Ta_rho y_rho],'-k');
    plot([x_M_Va_a x_M NaN x_M_Va_a x_Va NaN x_M_Va_a x_a]             , [y_M_Va_a y_M NaN y_M_Va_a y_Va NaN y_M_Va_a y_a],'-k');
    
end

drawnow;

% ---------------------------------------------------------------
function updatefields(hObject, eventdata, handles)
% Atualiza as caixas de texto da malha

set(handles.e_Zp    , 'String', num2str(roundn(handles.Zp,-2)));
set(handles.e_Vc    , 'String', num2str(roundn(handles.Vc,-2)));
set(handles.e_M     , 'String', num2str(roundn(handles.M,-5)));
set(handles.e_pa    , 'String', num2str(roundn(handles.pa,-3)));
set(handles.e_qc    , 'String', num2str(roundn(handles.qc,-3)));
set(handles.e_Dpb   , 'String', num2str(roundn(handles.Dpb,-4)));
set(handles.e_Dqb   , 'String', num2str(roundn(handles.Dqb,-4)));
set(handles.e_pb    , 'String', num2str(roundn(handles.pb,-3)));
set(handles.e_qb    , 'String', num2str(roundn(handles.qb,-3)));
set(handles.e_Zpb   , 'String', num2str(roundn(handles.Zpb,-2)));
set(handles.e_Vb    , 'String', num2str(roundn(handles.Vb,-2)));
set(handles.e_Mb    , 'String', num2str(roundn(handles.Mb,-5)));
set(handles.e_DISA  , 'String', num2str(roundn(handles.DISA,-3)));
set(handles.e_TaISA , 'String', num2str(roundn(handles.TaISA,-3)));
set(handles.e_Ta    , 'String', num2str(roundn(handles.Ta,-3)));
set(handles.e_a     , 'String', num2str(roundn(handles.a,-2)));
set(handles.e_Va    , 'String', num2str(roundn(handles.Va,-2)));
set(handles.e_rho   , 'String', num2str(roundn(handles.rho,-5)));
set(handles.e_Ve    , 'String', num2str(roundn(handles.Ve,-2)));
set(handles.e_q     , 'String', num2str(roundn(handles.q,-3)));
set(handles.e_delta , 'String', num2str(roundn(handles.delta,-5)));
set(handles.e_sigma , 'String', num2str(roundn(handles.sigma,-5)));
set(handles.e_teta  , 'String', num2str(roundn(handles.teta,-5)));

set(handles.p_qbpb ,'XData',handles.qb,'YData',handles.pb);
set(handles.p_qcpa ,'XData',handles.qc,'YData',handles.pa);
set(handles.p_VbZpb,'XData',handles.Vb,'YData',handles.Zpb);
set(handles.p_VcZp ,'XData',handles.Vc,'YData',handles.Zp);
set(handles.p_VaZp ,'XData',handles.Va,'YData',handles.Zp);
set(handles.p_VeZp ,'XData',handles.Ve,'YData',handles.Zp);

drawnow;

% ---------------------------------------------------------------
function updatecursor(hObject, eventdata, handles)
% Atualiza o tipo e posiçao do cursor

if getappdata(handles.window,'fixcur');
    return
end

cp = get(handles.window,'CurrentPoint') + [.5 .5];

ng = 0;
for n = 1:length(handles.axeslist)
    ap = get(handles.axeslist(n),'Position');
    ax = get(handles.axeslist(n),'XLim');
    ay = get(handles.axeslist(n),'YLim');
    
    x = (cp(1)-ap(1))*(ax(2)-ax(1))/ap(3) + ax(1);
    y = (cp(2)-ap(2))*(ay(2)-ay(1))/ap(4) + ay(1);
    
    if x >= ax(1) && x <= ax(2) && y >= ay(1) && y <= ay(2);
        ng = n;
        break
    end
end

switch ng % Numero do grafico
    
    case {0,1}
       set(handles.window,'Pointer','arrow'); 
        
    case 2 % qc x pa
        
        xp1 = get(handles.p_qbpb,'XData');
        yp1 = get(handles.p_qbpb,'YData');
        xp2 = get(handles.p_qcpa,'XData');
        yp2 = get(handles.p_qcpa,'YData');
        
        if     abs(x-xp1) < 4*diff(ax)/ap(3) && abs(y-yp1) < 4*diff(ay)/ap(4) % Basico
            set(handles.window,'Pointer','fleur'); 
            
        elseif abs(x-xp2) < 4*diff(ax)/ap(3) && abs(y-yp2) < 4*diff(ay)/ap(4) % Calibrado
            set(handles.window,'Pointer','fleur'); 
            
         else
            set(handles.window,'Pointer','crosshair'); 
            
       end
        
    case 3 % Vc x Zp

        xp1 = get(handles.p_VbZpb,'XData');
        yp1 = get(handles.p_VbZpb,'YData');
        xp2 = get(handles.p_VcZp,'XData');
        yp2 = get(handles.p_VcZp,'YData');
        xp3 = get(handles.p_VeZp,'XData');
        yp3 = get(handles.p_VeZp,'YData');
        xp4 = get(handles.p_VaZp,'XData');
        yp4 = get(handles.p_VaZp,'YData');

        if     abs(x-xp1) < 4*diff(ax)/ap(3) && abs(y-yp1) < 4*diff(ay)/ap(4) % Basico
            set(handles.window,'Pointer','fleur'); 
            
        elseif abs(x-xp2) < 4*diff(ax)/ap(3) && abs(y-yp2) < 4*diff(ay)/ap(4) % Calibrado
            set(handles.window,'Pointer','fleur'); 
            
        elseif abs(x-xp3) < 4*diff(ax)/ap(3) && abs(y-yp3) < 4*diff(ay)/ap(4) % Ve
            set(handles.window,'Pointer','fleur'); 
            
        elseif abs(x-xp4) < 4*diff(ax)/ap(3) && abs(y-yp4) < 4*diff(ay)/ap(4) % Va
            set(handles.window,'Pointer','fleur'); 
            
        else
            set(handles.window,'Pointer','crosshair'); 
        end
        
end

if     ng == 2
    qstr = num2str(x,4);
    pstr = num2str(y,4);
    mstr = num2str(qcpa2m(x,y),4);
    Vstr = '';
    Zstr = '';
    Mstr = '';
    
elseif ng == 3
    qstr = '';
    pstr = '';
    mstr = '';
    Vstr = num2str(x,4);
    Zstr = num2str(round(y));
    Mstr = num2str(qcpa2m(vc2qc(x),zp2pa(y)),4);
    
else
    qstr = '';
    pstr = '';
    mstr = '';
    Vstr = '';
    Zstr = '';
    Mstr = '';
end

set(handles.qpos,'String',qstr);
set(handles.ppos,'String',pstr);
set(handles.mpos,'String',mstr);
set(handles.Vpos,'String',Vstr);
set(handles.Zpos,'String',Zstr);
set(handles.Mpos,'String',Mstr);

% -------------------------------------------------------------------
function help_btn_Callback(hObject, eventdata, handles)
% Botao Ajuda

helpme('Ferramentas\anemocalc');

