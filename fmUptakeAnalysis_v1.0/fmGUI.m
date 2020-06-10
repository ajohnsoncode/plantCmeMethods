function varargout = fmGUI(varargin)
% FMGUI MATLAB code for fmGUI.fig
%      FMGUI, by itself, creates a new FMGUI or raises the existing
%      singleton*.
%
%      H = FMGUI returns the handle to a new FMGUI or the handle to
%      the existing singleton*.
%
%      FMGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FMGUI.M with the given input arguments.
%
%      FMGUI('Property','Value',...) creates a new FMGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before fmGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to fmGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help fmGUI

% Last Modified by GUIDE v2.5 06-Jun-2019 17:57:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fmGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @fmGUI_OutputFcn, ...
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


% --- Executes just before fmGUI is made visible.
function fmGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to fmGUI (see VARARGIN)

%% get the data 
% the file for analysis
[file,path] = uigetfile('*.tif','Select the image file');
cd(path)
image = imread(file);

% blur
imageBlur = imgaussfilt(image,2);

thres = 0.3;

% make binary
imageBin = im2bw(imageBlur,thres);

% fill cells
imageEdges = edge(imageBin,'zerocross');
imageFilled = imfill(imageEdges,'hole');

imageData.file = file;
imageData.image = image;
imageData.imageBlur = imageBlur;
imageData.thres = thres;
imageData.imageBin = imageBin;
imageData.imageEdges = imageEdges;
imageData.imageFilled = imageFilled;

save('imageData.mat','imageData')

% Choose default command line output for fmGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes fmGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);
imshow(file, 'Parent', handles.axes1)
imshow(imageFilled, 'Parent', handles.axes2)


% --- Outputs from this function are returned to the command line.
function varargout = fmGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function thresVal_edit_Callback(hObject, eventdata, handles)
% hObject    handle to thresVal_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of thresVal_edit as text
%        str2double(get(hObject,'String')) returns contents of thresVal_edit as a double


% --- Executes during object creation, after setting all properties.
function thresVal_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to thresVal_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in applyButton.
function applyButton_Callback(hObject, eventdata, handles)

y = str2double(get(handles.thresVal_edit, 'String'));

load('imageData.mat')
% make binary
imageData.imageBin = im2bw(imageData.imageBlur,y);

% fill cells
imageData.imageEdges = edge(imageData.imageBin,'zerocross');
imageData.imageFilled = imfill(imageData.imageEdges,'hole');

% update the imageData file
imageData.thres = y;

save('imageData.mat','imageData')

imshow(imageData.imageFilled, 'Parent', handles.axes2)
% hObject    handle to applyButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in saveButton.
function saveButton_Callback(hObject, eventdata, handles)
close('fmGUI')
% hObject    handle to saveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

