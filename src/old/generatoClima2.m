clear 

load('ExternaClimateMenaka_hourly_2020_2021')

%%
% newtspan = EC.DateTime(1):hours(1):EC.DateTime(end);
% newEC.temperature = interp1(EC.DateTime,EC.temperature,newtspan)';
% newEC.DateTime = newtspan';
% 
% EC = struct2table(newEC);
%%

%%
lat  = 43.349024834327; 
lon = -2.797651290893;
DGMT = 2;    
%
Elevation = DateTime2Elevation(EC.DateTime,lon,lat,DGMT);
delta     =  Day2Declination(EC.DateTime);

%%
EC.Delta = delta;
EC.Elevation = Elevation;

%%
%t = days(iEC.DateTime - iEC.DateTime(1));        % Time vector
T = EC.temperature;
%

%%
percent = 0.15;
lowpass(T,percent)
Tclean =lowpass(T,percent);
%%
tspan = days(EC.DateTime - EC.DateTime(1));
dTclean = gradient(Tclean,tspan);
ddTclean = gradient(dTclean,tspan);

%%
figure(1)
clf
hold on
plot(tspan,Tclean)
yyaxis right
plot(tspan,dTclean)
%%
clf
Nt = 500;
plot(Tclean(1:Nt),dTclean(1:Nt),'-')
grid on