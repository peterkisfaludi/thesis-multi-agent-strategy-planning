function varargout = simwindow2(varargin)
% SIMWINDOW2 M-file for simwindow2.fig
%      SIMWINDOW2, by itself, creates a new SIMWINDOW2 or raises the existing
%      singleton*.
%
%      H = SIMWINDOW2 returns the handle to a new SIMWINDOW2 or the handle to
%      the existing singleton*.
%
%      SIMWINDOW2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SIMWINDOW2.M with the given input arguments.
%
%      SIMWINDOW2('Property','Value',...) creates a new SIMWINDOW2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before simwindow2_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to simwindow2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help simwindow2

% Last Modified by GUIDE v2.5 30-Mar-2010 21:17:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @simwindow2_OpeningFcn, ...
                   'gui_OutputFcn',  @simwindow2_OutputFcn, ...
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

% --- Executes just before simwindow2 is made visible.
function simwindow2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to simwindow2 (see VARARGIN)

% Choose default command line output for simwindow2
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes simwindow2 wait for user response (see UIRESUME)
% uiwait(handles.figure1);
global SILENTMODE pressed_key
SILENTMODE = false;
pressed_key = 3;
plot(0,0,'w');

% --- Outputs from this function are returned to the command line.
function varargout = simwindow2_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in start_button.
function start_button_Callback(hObject, eventdata, handles)
% hObject    handle to start_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global LOGGERHANDLE
LOGGERHANDLE = handles.logger;
set(LOGGERHANDLE,'String','');
curdir = cd;

p1_path = get(handles.player1_path,'String');
[p1_pathstr,p1_stratname] = fileparts(p1_path);

p2_path = get(handles.player2_path,'String');
[p2_pathstr,p2_stratname] = fileparts(p2_path);

cd(p1_pathstr);
player1_handle = str2func(p1_stratname);

cd(p2_pathstr);
player2_handle = str2func(p2_stratname);

cd(curdir);
global S1 S2
S1=[10 0 2;
    11 0 2;
    12 0 2;
    13 0 2;        
    ];
S2=[55 0 2;
    54 0 2;
    53 0 2;
    52 0 2
    ];

simulator(player1_handle,player2_handle);

% --- Executes during object creation, after setting all properties.
function battlefield_CreateFcn(hObject, eventdata, handles)
% hObject    handle to battlefield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate battlefield



% --- Executes on key press with focus on start_button and no controls selected.
function start_button_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to start_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on mouse press over axes background.
function battlefield_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to battlefield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes when selected object is changed in action_panel.
function action_panel_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in action_panel 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global pressed_key
switch get(hObject,'String')
    case 'LEFT'
        pressed_key=0;
    case 'RIGHT'
        pressed_key=1;
    case 'FORWARD'
        pressed_key=2;
    case 'FIRE'
        pressed_key=3;
    case 'HALT'
        pressed_key=4;
end


% --- Executes on button press in p1_browse_button.
function p1_browse_button_Callback(hObject, eventdata, handles)
% hObject    handle to p1_browse_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile('*.m','Select player1''s strategy');
set(handles.player1_path,'String',fullfile(pathname,filename));

% --- Executes on button press in p2_browse_button.
function p2_browse_button_Callback(hObject, eventdata, handles)
% hObject    handle to p2_browse_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile('*.m','Select player2''s strategy');
set(handles.player2_path,'String',fullfile(pathname,filename));

