clear

% Forecast
%%
% NIOF
lat = 30.45846869104686;
lon =  30.55153477683711;

ds = ForecastOPW(lat,lon);

%%
% Menaka
DGMT = 2;
rad = DateTime2Rad(ds.DateTime',lon,lat,DGMT)';
ds.Rad = rad.*(1 - 0.3*ds.clouds/100);
%%


%%
