clear 

%load('SignalsGenerator')
%%
DateInit = datetime('01-Jan-2022');
%%

[full_ds,ds_forecast] =  ExternalClimateBuilderNIOF(DateInit);
%%
figure
clf
for i = 1:4
    subplot(4,1,i)
    plot(full_ds.DateTime,full_ds{:,i+1})

    xline(ds_forecast.DateTime(end),'LineWidth',4)
    xline(ds_forecast.DateTime(1),'LineWidth',4)

    xlim([DateInit DateInit+years(1)])
    title(full_ds.Properties.VariableNames{i+1})
end


