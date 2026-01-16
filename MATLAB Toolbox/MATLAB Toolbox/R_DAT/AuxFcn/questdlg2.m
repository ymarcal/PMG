function [ButtonName, Opt] = questdlg2(Question,Title,Option,Btn1,Btn2,Btn3,Default,DefOpt)
% QUESTDLG enhancement with a checkbox
%
% [ButtonName, Opt] = questdlg2(Question,Title,Option,Btn1,Btn2,Btn3,Default,DefOpt)
%

%%%%%%%%%%%%%%%%%%%%
%%% Nargin Check %%%
%%%%%%%%%%%%%%%%%%%%

if nargout>2,error('Wrong number of output arguments for QUESTDLG');end

if nargin == 0
    Question = 'Are you feeling OK?';
    Title    = 'Question';
    Option   = 'Stop asking';
    Btn1     = 'Yes';
    Btn2     = 'No';
    Btn3     = 'Cancel';
    Default  = 'Cancel';
    DefOpt   = true;
    NumButtons = 3;
elseif nargin ~= 8
    error('Incorrect number of arguments.')
end

if ~isempty(Btn3)
    NumButtons = 3;
else
    NumButtons = 2;
end
if isempty(Default)
    Default = Btn1;
end
if isempty(DefOpt)
    DefOpt = true;
end

%%%%%%%%%%%%%%%%%%%%%
%%% Default Press %%%
%%%%%%%%%%%%%%%%%%%%%
persistent DefaultValid;

Interpreter='none';
if ~iscell(Question),Question=cellstr(Question);end

if strcmp(Question{1},'#FigKeyPressFcn'),
    QuestFig=get(0,'CurrentFigure');
    AsciiVal= abs(get(QuestFig,'CurrentCharacter'));
    if ~isempty(AsciiVal),
        if AsciiVal==32 | AsciiVal==13,
            % Check if the default string matches any button string.
            % If not then dont resune till the user selects a valid input.
            if(~DefaultValid)
                warnstate = warning('backtrace','off');
                warning('MATLAB:QUESTDLG:stringMismatch','Default string does not match any button string name.');
                warning(warnstate);
                return;
            end
            set(QuestFig,'UserData',1);
            uiresume(QuestFig);
        end %if AsciiVal
    end %if ~isempty
    return
end

%%%%%%%%%%%%%%%%%%%%%
%%% General Info. %%%
%%%%%%%%%%%%%%%%%%%%%
Black      =[0       0        0      ]/255;
LightGray  =[192     192      192    ]/255;
LightGray2 =[160     160      164    ]/255;
MediumGray =[128     128      128    ]/255;
White      =[255     255      255    ]/255;

%%%%%%%%%%%%%%%%%%%%%%%
%%% Create QuestFig %%%
%%%%%%%%%%%%%%%%%%%%%%%
FigPos=get(0,'DefaultFigurePosition');
FigWidth=190; FigHeight=50;
if isempty(gcbf)
    ScreenUnits=get(0,'Units');
    set(0,'Units','points');
    ScreenSize=get(0,'ScreenSize');
    set(0,'Units',ScreenUnits);
    
    FigPos(1)=1/2*(ScreenSize(3)-FigWidth);
    FigPos(2)=2/3*(ScreenSize(4)-FigHeight);
else
    GCBFOldUnits = get(gcbf,'Units');
    set(gcbf,'Units','points');
    GCBFPos = get(gcbf,'Position');
    set(gcbf,'Units',GCBFOldUnits);
    FigPos(1:2) = [(GCBFPos(1) + GCBFPos(3) / 2) - FigWidth / 2, ...
            (GCBFPos(2) + GCBFPos(4) / 2) - FigHeight / 2];
end
FigPos(3:4)=[FigWidth FigHeight];
QuestFig=dialog(                                               ...
    'Visible'         ,'off'                      , ...
    'Name'            ,Title                      , ...
    'Pointer'         ,'arrow'                    , ...
    'Units'           ,'points'                   , ...
    'Position'        ,FigPos                     , ...
    'KeyPressFcn'     ,'questdlg #FigKeyPressFcn;', ...
    'UserData'        ,0                          , ...
    'IntegerHandle'   ,'off'                      , ...
    'WindowStyle'     ,'normal'                   , ... 
    'HandleVisibility','callback'                 , ...
    'Tag'             ,Title                        ...
);

%%%%%%%%%%%%%%%%%%%%%
%%% Set Positions %%%
%%%%%%%%%%%%%%%%%%%%%
%DefOffset=3;
DefOffset=7;

%IconWidth=32;
IconWidth=36;
%IconHeight=32;
IconHeight=37;
IconXOffset=DefOffset;
IconYOffset=FigHeight-DefOffset-IconHeight;
IconCMap=[Black;get(QuestFig,'Color')];

DefBtnWidth=40;
BtnHeight=20;
ChkHeight=20;
ChkWidth=100;
BtnYOffset=DefOffset;
BtnFontSize=get(0,'FactoryUIControlFontSize');
BtnFontName=get(0,'FactoryUIControlFontName');

BtnWidth=DefBtnWidth;

ExtControl=uicontrol(QuestFig   , ...
    'Style'    ,'pushbutton', ...
    'String'   ,' '         , ...
    'FontUnits','points'    , ...                     
    'FontSize' ,BtnFontSize , ...
    'FontName' ,BtnFontName   ...
);

set(ExtControl,'String',Btn1);
BtnExtent=get(ExtControl,'Extent');
BtnWidth=max(BtnWidth,BtnExtent(3)+8);
if NumButtons > 1
    set(ExtControl,'String',Btn2);
    BtnExtent=get(ExtControl,'Extent');
    BtnWidth=max(BtnWidth,BtnExtent(3)+8);
    if NumButtons > 2
        set(ExtControl,'String',Btn3);
        BtnExtent=get(ExtControl,'Extent');
        BtnWidth=max(BtnWidth,BtnExtent(3)+8);
    end 
end

delete(ExtControl);

MsgTxtXOffset=IconXOffset+IconWidth;

FigWidth=max(FigWidth,MsgTxtXOffset+NumButtons*(BtnWidth+2*DefOffset));
FigPos(3)=FigWidth;
set(QuestFig,'Position',FigPos);

BtnXOffset=zeros(NumButtons,1);

if NumButtons==1,
    BtnXOffset=(FigWidth-BtnWidth)/2;
elseif NumButtons==2,
    BtnXOffset=[MsgTxtXOffset
        FigWidth-DefOffset-BtnWidth];
elseif NumButtons==3,
    BtnXOffset=[MsgTxtXOffset
        0
        FigWidth-DefOffset-BtnWidth];
    BtnXOffset(2)=(BtnXOffset(1)+BtnXOffset(3))/2;
end

MsgTxtYOffset=DefOffset+BtnYOffset+BtnHeight;
MsgTxtWidth=FigWidth-DefOffset-MsgTxtXOffset-IconWidth;
MsgTxtHeight=FigHeight-DefOffset-MsgTxtYOffset;
MsgTxtForeClr=Black;
MsgTxtBackClr=get(QuestFig,'Color');

CBString='uiresume(gcf)';

% Checks to see if the Default string passed does match one of the
% strings on the buttons in the dialog. If not, throw a warning.
DefaultValid = 0;
ButtonString=Btn1;
ButtonTag='Btn1';
BtnHandle(1)=uicontrol(QuestFig       , ...
    'Style'              ,'pushbutton', ...
    'Units'              ,'points'    , ...
    'Position'           ,[ BtnXOffset(1) BtnYOffset BtnWidth BtnHeight ] , ...
    'CallBack'           ,CBString    , ...
    'String'             ,ButtonString, ...
    'HorizontalAlignment','center'    , ...
    'FontUnits'          ,'points'    , ...
    'FontSize'           ,BtnFontSize , ...
    'FontName'           ,BtnFontName , ...
    'Tag'                ,ButtonTag     ...
);
if strcmp(ButtonString, Default)
    DefaultValid = 1;
    set(BtnHandle(1),'FontWeight','bold');
end

if NumButtons > 1
    ButtonString=Btn2;
    ButtonTag='Btn2';
    BtnHandle(2)=uicontrol(QuestFig       , ...
        'Style'              ,'pushbutton', ...
        'Units'              ,'points'    , ...
        'Position'           ,[ BtnXOffset(2) BtnYOffset BtnWidth BtnHeight ] , ...
        'CallBack'           ,CBString    , ...
        'String'             ,ButtonString, ...
        'HorizontalAlignment','center'    , ...
        'FontUnits'          ,'points'    , ...
        'FontSize'           ,BtnFontSize , ...
        'FontName'           ,BtnFontName , ...
        'Tag'                ,ButtonTag     ...
    );
    if strcmp(ButtonString, Default)
        DefaultValid = 1;
        set(BtnHandle(2),'FontWeight','bold');
    end
    
    if NumButtons > 2
        ButtonString=Btn3;
        ButtonTag='Btn3';
        BtnHandle(3)=uicontrol(QuestFig       , ...
            'Style'              ,'pushbutton', ...
            'Units'              ,'points'    , ...
            'Position'           ,[ BtnXOffset(3) BtnYOffset BtnWidth BtnHeight ] , ...
            'CallBack'           ,CBString    , ...
            'String'             ,ButtonString, ...
            'HorizontalAlignment','center'    , ...
            'FontUnits'          ,'points'    , ...
            'FontSize'           ,BtnFontSize , ...
            'FontName'           ,BtnFontName , ...
            'Tag'                ,ButtonTag     ...
        );
        if strcmp(ButtonString, Default)
            DefaultValid = 1;
            set(BtnHandle(3),'FontWeight','bold');
        end
    end
end

if ~isempty(Option)
    OptString=Option;
    OptTag='Option';
    OptHandle=uicontrol(QuestFig            , ...
        'Style'              ,'checkbox'  , ...
        'Value'              ,DefOpt     ,...
        'Units'              ,'points'    , ...
        'Position'           ,[ MsgTxtXOffset+8 BtnYOffset+25 ChkWidth ChkHeight ] , ...
        'String'             ,OptString, ...
        'HorizontalAlignment','center'    , ...
        'FontUnits'          ,'points'    , ...
        'FontSize'           ,BtnFontSize , ...
        'FontName'           ,BtnFontName , ...
        'Tag'                ,OptTag     ...
    );
else
    OptHandle = [];
end

if(DefaultValid == 0)
    warnstate = warning('backtrace','off');
    warning('MATLAB:QUESTDLG:stringMismatch','Default string does not match any button string name.');
    warning(warnstate);
end

MsgHandle=uicontrol(QuestFig             , ...
    'Style'              ,'text'         , ...
    'Units'              ,'points'       , ...
    'Position'           ,[MsgTxtXOffset MsgTxtYOffset 0.95*MsgTxtWidth MsgTxtHeight ] , ...
    'String'             ,{' '}          , ...
    'Tag'                ,'Question'     , ...
    'HorizontalAlignment','left'         , ...    
    'FontUnits'          ,'points'       , ...
    'FontWeight'         ,'bold'         , ...
    'FontSize'           ,BtnFontSize    , ...
    'FontName'           ,BtnFontName    , ...
    'BackgroundColor'    ,MsgTxtBackClr  , ...
    'ForegroundColor'    ,MsgTxtForeClr    ...
);

[WrapString,NewMsgTxtPos]=textwrap(MsgHandle,Question,75);

NumLines=size(WrapString,1);

% The +2 is to add some slop for the border of the control.
MsgTxtWidth=max(MsgTxtWidth,NewMsgTxtPos(3)+2);
MsgTxtHeight=NewMsgTxtPos(4)+2;

MsgTxtXOffset=IconXOffset+IconWidth+DefOffset;
FigWidth=max(NumButtons*(BtnWidth+DefOffset)+DefOffset, ...
    MsgTxtXOffset+MsgTxtWidth+DefOffset);


% Center Vertically around icon  
if IconHeight>MsgTxtHeight,
    IconYOffset=BtnYOffset+BtnHeight+DefOffset;
    MsgTxtYOffset=IconYOffset+(IconHeight-MsgTxtHeight)/2;
    FigHeight=IconYOffset+IconHeight+DefOffset;
    % center around text    
else
    MsgTxtYOffset=BtnYOffset+BtnHeight+DefOffset;
    IconYOffset=MsgTxtYOffset+(MsgTxtHeight-IconHeight)/2;
    FigHeight=MsgTxtYOffset+MsgTxtHeight+DefOffset;
end    

if NumButtons==1,
    BtnXOffset=(FigWidth-BtnWidth)/2;
elseif NumButtons==2,
    BtnXOffset=[(FigWidth-DefOffset)/2-BtnWidth
        (FigWidth+DefOffset)/2      
    ];
    
elseif NumButtons==3,
    BtnXOffset(2)=(FigWidth-BtnWidth)/2;
    BtnXOffset=[BtnXOffset(2)-DefOffset-BtnWidth
        BtnXOffset(2)
        BtnXOffset(2)+BtnWidth+DefOffset
    ];              
end

FigPos(3:4)=[FigWidth FigHeight+20*~isempty(Option)];

set(QuestFig ,'Position',FigPos);

BtnPos=get(BtnHandle,{'Position'});BtnPos=cat(1,BtnPos{:});
BtnPos(:,1)=BtnXOffset;
BtnPos=num2cell(BtnPos,2);  
set(BtnHandle,{'Position'},BtnPos);  

delete(MsgHandle);
AxesHandle=axes('Parent',QuestFig,'Position',[0 0 1 1],'Visible','off');

MsgHandle=text( ...
    'Parent'              ,AxesHandle                      , ...
    'Units'               ,'points'                        , ...
    'FontUnits'           ,'points'                        , ...
    'FontSize'            ,BtnFontSize                     , ...
    'FontName'            ,BtnFontName                     , ...
    'HorizontalAlignment' ,'left'                          , ...
    'VerticalAlignment'   ,'bottom'                        , ...
    'HandleVisibility'    ,'callback'                      , ...
    'Position'            ,[MsgTxtXOffset MsgTxtYOffset+20*~isempty(Option) 0] , ...
    'String'              ,WrapString                      , ...
    'Interpreter'         ,Interpreter                     , ...
    'Tag'                 ,'Question'                        ...
    );

IconAxes=axes(                             ...
    'Units'       ,'points'              , ...
    'Parent'      ,QuestFig              , ...  
    'Position'    ,[IconXOffset IconYOffset+10*~isempty(Option) IconWidth IconHeight], ...
    'NextPlot'    ,'replace'             , ...
    'Tag'         ,'IconAxes'              ...
    );

set(QuestFig ,'NextPlot','add');

load dialogicons.mat
IconData=questIconData;
questIconMap(256,:)=get(QuestFig,'color');
IconCMap=questIconMap;

Img=image('CData',IconData,'Parent',IconAxes);
set(QuestFig, 'Colormap', IconCMap);
set(IconAxes, ...
    'Visible','off'           , ...
    'YDir'   ,'reverse'       , ...
    'XLim'   ,get(Img,'XData'), ...
    'YLim'   ,get(Img,'YData')  ...
    );
set(findobj(QuestFig),'HandleVisibility','callback');
set(QuestFig ,'WindowStyle','modal','Visible','on');
drawnow;

uiwait(QuestFig);

TempHide=get(0,'ShowHiddenHandles');
set(0,'ShowHiddenHandles','on');

if any(get(0,'Children')==QuestFig),
    if get(QuestFig,'UserData'),
        ButtonName=Default;
        Opt=DefOpt;
    else
        ButtonName=get(get(QuestFig,'CurrentObject'),'String');
        if ishandle(OptHandle); Opt=logical(get(OptHandle,'Value')); else; Opt=[]; end
    end
    delete(QuestFig);
else
    ButtonName='';
    Opt=[];
end

set(0,'ShowHiddenHandles',TempHide);
