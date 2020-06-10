function varargout = fmDataGUI(varargin)
% FMDATAGUI MATLAB code for fmDataGUI.fig
%      FMDATAGUI, by itself, creates a new FMDATAGUI or raises the existing
%      singleton*.
%
%      H = FMDATAGUI returns the handle to a new FMDATAGUI or the handle to
%      the existing singleton*.
%
%      FMDATAGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FMDATAGUI.M with the given input arguments.
%
%      FMDATAGUI('Property','Value',...) creates a new FMDATAGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before fmDataGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to fmDataGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help fmDataGUI

% Last Modified by GUIDE v2.5 15-Oct-2019 20:43:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fmDataGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @fmDataGUI_OutputFcn, ...
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


% --- Executes just before fmDataGUI is made visible.
function fmDataGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to fmDataGUI (see VARARGIN)

%% Get the data
[file,path] = uigetfile('*.mat','Select the results/output file');
cd(path)
load(file)
handles.data = data;

handles.i = 1;
handles.rangeSize = 100;

rangeSize = handles.rangeSize;
center = round(handles.data(handles.i).centroid);
x = center(1,1);
y = center(1,2);
xRange = x-rangeSize:1:x+rangeSize;
yRange = y-rangeSize:1:y+rangeSize;
xRange = xRange(xRange>0);
yRange = yRange(yRange>0);
xRange = xRange(xRange < size(handles.data(handles.i).wholeCell,2));
yRange = yRange(yRange < size(handles.data(handles.i).wholeCell,1));

wholeCell = handles.data(handles.i).wholeCell(yRange(1):yRange(end),xRange(1):xRange(end));
membrane = handles.data(handles.i).membrane(yRange(1):yRange(end),xRange(1):xRange(end));
inside = handles.data(handles.i).insideCell(yRange(1):yRange(end),xRange(1):xRange(end));

% Choose default command line output for fmDataGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes fmDataGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);
imshow(wholeCell, 'Parent', handles.wholeCellImage)
imshow(membrane, 'Parent', handles.membraneImage)
imshow(inside, 'Parent', handles.insideImage) 

% --- Outputs from this function are returned to the command line.
function varargout = fmDataGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
handles.i = handles.i - 1;

if handles.i < 1
    handles.i = 1;
end

rangeSize = handles.rangeSize;
center = round(handles.data(handles.i).centroid);
x = center(1,1);
y = center(1,2);
xRange = x-rangeSize:1:x+rangeSize;
yRange = y-rangeSize:1:y+rangeSize;
xRange = xRange(xRange>0);
yRange = yRange(yRange>0);
xRange = xRange(xRange < size(handles.data(handles.i).wholeCell,2));
yRange = yRange(yRange < size(handles.data(handles.i).wholeCell,1));

wholeCell = handles.data(handles.i).wholeCell(yRange(1):yRange(end),xRange(1):xRange(end));
membrane = handles.data(handles.i).membrane(yRange(1):yRange(end),xRange(1):xRange(end));
inside = handles.data(handles.i).insideCell(yRange(1):yRange(end),xRange(1):xRange(end));

imshow(wholeCell, 'Parent', handles.wholeCellImage)
imshow(membrane, 'Parent', handles.membraneImage)
imshow(inside, 'Parent', handles.insideImage) 
guidata(hObject, handles);
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in nextButton.
function nextButton_Callback(hObject, eventdata, handles)
handles.i = handles.i + 1;

if handles.i > size(handles.data,2)
    handles.i = size(handles.data,2);
end

rangeSize = handles.rangeSize;
center = round(handles.data(handles.i).centroid);
x = center(1,1);
y = center(1,2);
xRange = x-rangeSize:1:x+rangeSize;
yRange = y-rangeSize:1:y+rangeSize;
xRange = xRange(xRange>0);
yRange = yRange(yRange>0);
xRange = xRange(xRange < size(handles.data(handles.i).wholeCell,2));
yRange = yRange(yRange < size(handles.data(handles.i).wholeCell,1));

wholeCell = handles.data(handles.i).wholeCell(yRange(1):yRange(end),xRange(1):xRange(end));
membrane = handles.data(handles.i).membrane(yRange(1):yRange(end),xRange(1):xRange(end));
inside = handles.data(handles.i).insideCell(yRange(1):yRange(end),xRange(1):xRange(end));

imshow(wholeCell, 'Parent', handles.wholeCellImage)
imshow(membrane, 'Parent', handles.membraneImage)
imshow(inside, 'Parent', handles.insideImage) 
guidata(hObject, handles);
% hObject    handle to nextButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in saveButton.
function saveButton_Callback(hObject, eventdata, handles)

rangeSize = handles.rangeSize;
center = round(handles.data(handles.i).centroid);
x = center(1,1);
y = center(1,2);
xRange = x-rangeSize:1:x+rangeSize;
yRange = y-rangeSize:1:y+rangeSize;

wholeCell = handles.data(handles.i).wholeCell(yRange(1):yRange(end),xRange(1):xRange(end));
membrane = handles.data(handles.i).membrane(yRange(1):yRange(end),xRange(1):xRange(end));
inside = handles.data(handles.i).insideCell(yRange(1):yRange(end),xRange(1):xRange(end));

no = num2str(handles.i);
wcName = ['cell_',no,'_wholeCellImage.tif'];
imwrite(wholeCell,wcName)
mName = ['cell_',no,'_membraneImage.tif'];
imwrite(membrane,mName)
isName = ['cell_',no,'_insideImage.tif'];
imwrite(inside,isName)
    
% hObject    handle to saveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



