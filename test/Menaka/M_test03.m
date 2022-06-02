clear 
close all
load('ExternaClimateMenaka_hourly_2020_2021')

EC(isnan(EC.radiation),:) = [];
EC(isnan(EC.wind),:) = [];
EC(isnan(EC.humidity),:) = [];

%
%%
Nsamples = 1000;
size_samples = 8000;

iter = 0;

iSG = [];

limits = { [0 inf], [0 100],[-inf inf],[0 inf]}; 
for ivar = EC.Properties.VariableNames(2:end)
    iter = iter + 1;
    TT = table2timetable(EC(:,[{'DateTime'},ivar(:)']));
    
    iSG.(ivar{:}) = SignalGenerator(TT,size_samples,Nsamples);
    iSG.(ivar{:}).limits = limits{iter};
end
%%
plot(iSG.humidity.FS)

%%
%close all
DateTimes = [datetime('01-Feb-2100')];

for ivar = EC.Properties.VariableNames(2:end)
  
    [r,rold] = genSignal(iSG.(ivar{:}),DateTimes,50);
%
    fig = figure();
    compareSignals(fig,r,rold,ivar{:})
end

%%
ivar = {'temperature'};
[r,rold] = genSignal(iSG.(ivar{:}),DateTimes,10);

%
fig = figure();
compareSignals(fig,r,rold,ivar{:})

%%
save('data/SignalsGenerator_Menaka.mat','iSG')
