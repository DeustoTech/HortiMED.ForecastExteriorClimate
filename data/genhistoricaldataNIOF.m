clear 

load('EC_NIOF.mat')

EC_NIOF = EC_NIOF(2:end,:);
%%
dt_iso_char = char(EC_NIOF.dt_iso);
%%
ds.DateTime = datetime(dt_iso_char(:,1:19),'InputFormat','yyyy-MM-dd HH:mm:ss');
ds.humidity = EC_NIOF.humidity;
ds.temperature = EC_NIOF.temp - 273.15;
ds.wind = EC_NIOF.wind_speed;
ds.clouds = EC_NIOF.clouds_all;
%%
ds = struct2table(ds);

%%
head(ds)
%% 
clf
plot(ds.DateTime,ds.clouds)
%%
DGMT = 2;
lat = 30.45846869104686;
lon =  30.55153477683711;

ds.radiation_clean = DateTime2Rad(ds.DateTime,lon,lat,DGMT);

ds.radiation = (1 - 0.7*ds.clouds/100).*ds.radiation_clean;
%%
figure
clf
hold on
plot(ds.DateTime,ds.radiation_clean)

plot(ds.DateTime,ds.radiation)
%%
save('data/EC_NIOF_2','ds')