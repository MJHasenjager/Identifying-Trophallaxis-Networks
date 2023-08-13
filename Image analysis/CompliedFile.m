clc;    % Clear the command window.
fprintf('Beginning to run %s.m ...\n', mfilename);
close all;  % Close all figures (except those of imtool.)
imtool close all;  % Close all imtool figures.
clear;  % Erase all existing variables.
workspace;  % Make sure the workspace panel is showing
numberOfAnts = 27

datafile1=('Z:\Images\DESKTOP-M33S9D8\D\6-14-2\ImageAnt\')
datafile2 = ('Z:\Images\DESKTOP-M33S9D8\D\6-14-2\ImageFluo\')
startframe = 1
endframe = 1200
Tracking
AddLabelSpeed
FrameSelectionForCalibration
ReferenceImageCreationForCalibration
CalibratinPointsCollectionsClicking
DistanceApproximation
InterpolatingLocatingHeadBuildingNetworks


