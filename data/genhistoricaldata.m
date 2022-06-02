date_range = [datetime('01-Jan-2021') datetime('31-Dec-2021')];

EC = HistoricalExternalClimateMungia(date_range);

%%
save('data/ExternaClimateMenaka2021.mat','EC')

%%

date_range = [datetime('01-Jan-2020') datetime('31-Dec-2020')];

EC = HistoricalExternalClimateMungia(date_range);

%
save('data/ExternaClimateMenaka2020.mat','EC')

%%
load('ExternaClimateMenaka2021')
EC2021 = EC;

load('ExternaClimateMenaka2020')
EC2020 = EC;


%%

%%
%
EC = vertcat(EC2020,EC2021);

save('data/ExternaClimateMenaka_2020_2021.mat','EC')


%%
Elevation = DateTime2Elevation(EC.DateTime,lon,lat,DGMT);
delta =  Day2Declination(EC.DateTime);

clf
subplot(2,1,1)
plot(EC.DateTime,EC.temperature)
subplot(2,1,2)
plot(EC.DateTime,Elevation)


%%
clf
plot3(delta,Elevation,EC.temperature,'.')
%%

load('ExternaClimateMenaka_2020_2021')

hourlyData = EC.DateTime(1):hours(1):EC.DateTime(end);

newEC = [];
newEC.DateTime = hourlyData';
newEC.wind = interp1(EC.DateTime,EC.wind,hourlyData)';
newEC.humidity = interp1(EC.DateTime,EC.humidity,hourlyData)';
newEC.temperature = interp1(EC.DateTime,EC.temperature,hourlyData)';
newEC.radiation = interp1(EC.DateTime,EC.radiation,hourlyData)';

newEC = struct2table(newEC);
EC = newEC;
save('data/ExternaClimateMenaka_hourly_2020_2021.mat','EC')
