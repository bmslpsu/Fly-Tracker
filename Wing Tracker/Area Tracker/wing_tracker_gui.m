function varargout = wing_tracker_gui(varargin)
% WING_TRACKER_GUI MATLAB code for wing_tracker_gui.fig
%      WING_TRACKER_GUI, by itself, creates a new WING_TRACKER_GUI or raises the existing
%      singleton*.
%
%      H = WING_TRACKER_GUI returns the handle to a new WING_TRACKER_GUI or the handle to
%      the existing singleton*.
%
%      WING_TRACKER_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in WING_TRACKER_GUI.M with the given input arguments.
%
%      WING_TRACKER_GUI('Property','Value',...) creates a new WING_TRACKER_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before wing_tracker_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to wing_tracker_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help wing_tracker_gui

% Last Modified by GUIDE v2.5 07-Mar-2019 15:22:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @wing_tracker_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @wing_tracker_gui_OutputFcn, ...
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


% --- Executes just before wing_tracker_gui is made visible.
function wing_tracker_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to wing_tracker_gui (see VARARGIN)
root = 'C:\Users\jmr65\OneDrive\Documents\video';
[files,PATH] = uigetfile({'*.mat', 'vidfile'},'select file', root, 'MultiSelect', 'off');
load([PATH files],'vidData')
global vid
vid = squeeze(vidData);
imshow(vid(:,:,1))
global filter
filter = [0,0,0];
global debug
debug = 0;
global frame
frame = 1;
global Threslow
Threslow = 0;
% Choose default command line output for wing_tracker_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes wing_tracker_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = wing_tracker_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function threshold_Callback(hObject, eventdata, handles)
% hObject    handle to threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Threslow
Threslow = get(handles.threshold, 'value');
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global vid
global IMG
global frame
IMG{1} = vid(:,:,frame);
thresh.Idx = (IMG{1} >=Threslow);
IMG{1}(thresh.Idx) = 1;                 
IMG{1}(~thresh.Idx) = 0;
IMG{1} = logical(IMG{1});
imshow(IMG{1})
global filter
filter = [0 0 0];


% --- Executes during object creation, after setting all properties.
function threshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in filter1.
function filter1_Callback(hObject, eventdata, handles)
% hObject    handle to filter1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%global vid
global IMG
%IMG{1} = vid(:,:,1);
IMG{1} = medfilt2(IMG{1});
imshow(IMG{1})
global filter
filter(1) = filter(1)+1;

% --- Executes on button press in filter2.
function filter2_Callback(hObject, eventdata, handles)
% hObject    handle to filter2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global IMG
IMG{1} = imfill(IMG{1},'holes'); 
imshow(IMG{1})
global filter
filter(2) = filter(2)+1;

% --- Executes on button press in filter3.
function filter3_Callback(hObject, eventdata, handles)
% hObject    handle to filter3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global IMG
IMG{1} = bwareaopen(IMG{1}, 5000);
imshow(IMG{1})
global filter
filter(3) = filter(3)+1;

% --- Executes on button press in start.
function start_Callback(hObject, eventdata, handles)
% hObject    handle to start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global filter
global Threslow
global vid
global debug
global Wing
[Wing] = WingTracker_Area(vid,debug,Threslow,filter,varargin);



% --- Executes on slider movement.
function frame_Callback(hObject, eventdata, handles)
% hObject    handle to frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global frame
frame = get(handles.frame, 'value');
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global vid
global filter
global IMG
global Threslow
IMG{1} = vid(:,:,frame);
thresh.Idx = (IMG{1} >=Threslow);
IMG{1}(thresh.Idx) = 1;                 
IMG{1}(~thresh.Idx) = 0;
IMG{1} = logical(IMG{1});
if filter(1)>0
for a = 1:filter(1)
    IMG{1} = medfilt2(IMG{1});
end
end
if filter(2)>0
for a = 1:filter(2)
    IMG{1} = imfill(IMG{1},'holes');
end
end
if filter(3)>0
for a = 1:filter(3)
    IMG{1} = bwareaopen(IMG{1}, 5000);
end
end
imshow(IMG{1})

% --- Executes during object creation, after setting all properties.
function frame_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in zero_filter.
function zero_filter_Callback(hObject, eventdata, handles)
% hObject    handle to zero_filter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global filter
filter = [0 0 0];


% --- Executes on button press in debug.
function debug_Callback(hObject, eventdata, handles)
% hObject    handle to debug (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global debug
debug = ~debug;
