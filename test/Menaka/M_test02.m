clear

date =datetime('01-Jan-2022');

r = HistoricalExternalClimateMungia_1day(date);

%%

date_range = [datetime('29-May-2022') datetime('30-May-2022')];

EC = HistoricalExternalClimateMungia(date_range);

%%
% Menaka
lat  = 43.349024834327; 
lon = -2.797651290893;

ds = ForecastOPW(lat,lon);

%%
% Menaka
DGMT = 2;
rad = DateTime2Rad(ds.DateTime',lon,lat,DGMT)';
ds.Rad = rad.*(1 - 0.3*ds.clouds/100);
%%


%%
