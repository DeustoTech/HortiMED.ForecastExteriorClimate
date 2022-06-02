clear 

load('ExternaClimateMenaka_hourly_2020_2021')

EC(isnan(EC.radiation),:) = [];
EC((EC.radiation)100,:) = [];

%%
lat  = 43.349024834327; 
lon = -2.797651290893;
DGMT = 2;
    
iter = 0;
Nt = size(EC,1);


    %
EC.Elevation = DateTime2Elevation(EC.DateTime,lon,lat,DGMT);
EC.delta     =  Day2Declination(EC.DateTime);
EC.Rad     =  DateTime2Rad(EC.DateTime,lon,lat,DGMT);

%%
clf
plot(EC.Elevation,EC.radiation./EC.Rad,'.')
