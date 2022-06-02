%%
clear
%%
filename = 'ExternalClimateForescasting.m';
filepath = which(filename);
filepath = replace(filepath,filename,'');
%
filepath_dependences = fullfile(filepath,'src','dependences');
%%
unzip('https://github.com/djoroya/HortiMED-Data-Sources/archive/refs/heads/main.zip',filepath_dependences)
%%
unzip('https://github.com/DeustoTech/MechanisticSolarRadiationModel/archive/refs/heads/main.zip',filepath_dependences)

