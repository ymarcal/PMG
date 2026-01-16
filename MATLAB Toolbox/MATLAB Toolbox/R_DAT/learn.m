function varargout = learn(varargin)
% LEARN M-file for learn.fig
%      LEARN, by itself, creates a new LEARN or raises the existing
%      singleton*.
%
%      H = LEARN returns the handle to a new LEARN or the handle to
%      the existing singleton*.
%
%      LEARN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LEARN.M with the given input arguments.
%
%      LEARN('Property','Value',...) creates a new LEARN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before learn_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to learn_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help learn

% Last Modified by GUIDE v2.5 23-Apr-2014 14:56:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @learn_OpeningFcn, ...
                   'gui_OutputFcn',  @learn_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end



if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before learn is made visible.
function learn_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to learn (see VARARGIN)

% Choose default command line output for learn
handles.output = hObject;

%global Dados;
Dados = [0:10];
handles.Dados = Dados;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes learn wait for user response (see UIRESUME)
% uiwait(handles.figTest);


% --- Outputs from this function are returned to the command line.
function varargout = learn_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in btnTest.
function btnTest_Callback(hObject, eventdata, handles)
% hObject    handle to btnTest (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject,'String','Aprendendo');
plot(handles.Dados);
