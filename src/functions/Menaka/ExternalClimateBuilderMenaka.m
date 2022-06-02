
function [full_ds,ds_forecast] = ExternalClimateBuilderMenaka(DateInit)

    today = datetime(datestr(now));
    today.Minute = 0;
    today.Second = 0;
    today = today - hours(1);
    %%
    sc01 = [DateInit today];

    r = MenakaDataCall_ECF(sc01);
    ds_hist = [];
    ds_hist.DateTime = r.DateTime;
    ds_hist.radiation = r.RadiacionEuskalmet_Sol;
    ds_hist.humidity = r.HumedadEuskalmet_TemperaturaHumedad;
    ds_hist.temperature = r.TemperaturaEuskalmet_TemperaturaHumedad;
    ds_hist.wind = r.VelocidadVientoEuskalmet_Viento;
    ds_hist = struct2table(ds_hist);

    ds_hist(isnan(sum(ds_hist{:,2:end},2)),:) = [];
    %%
    ds_hist.wind = ds_hist.wind; 

    
    %%
    newDateTime = ds_hist.DateTime(1):hours(1):ds_hist.DateTime(end);
    new_ds_hist.DateTime = newDateTime';
    new_ds_hist.radiation   = interp1(ds_hist.DateTime,ds_hist.radiation,newDateTime)';
    new_ds_hist.humidity    = interp1(ds_hist.DateTime,ds_hist.humidity,newDateTime)';
    new_ds_hist.temperature = interp1(ds_hist.DateTime,ds_hist.temperature,newDateTime)';
    new_ds_hist.wind        = interp1(ds_hist.DateTime,ds_hist.wind,newDateTime)';

    ds_hist = struct2table(new_ds_hist);

    % Menaka
    lat  = 43.349024834327; 
    lon = -2.797651290893;

    ds_forecast  = ForecastOPW(lat,lon);
    %%
    load('data/SignalsGenerator.mat')
    %%
    ds_syntetic = [];


    freqz = [4 40 40 4];
    iter = 0;
    for ivar = fieldnames(iSG)'
        iter = iter + 1;
        ds_syntetic.(ivar{:}) = genSignal(iSG.(ivar{:}),ds_forecast.DateTime(end),freqz(iter));
        DateTime = ds_syntetic.(ivar{:}).DateTime;
        ds_syntetic.(ivar{:}) = ds_syntetic.(ivar{:}).(ivar{:});

    end
    DGMT = 2;
    ds_syntetic.DateTime = DateTime;
    rad = DateTime2Rad(ds_syntetic.DateTime, lon,lat,DGMT);
    rad = rad + 0.15*rad;

    att = normrnd(0.7,0.6,size(rad));
    att = smoothdata(att,'movmean','SmoothingFactor',0.7);
    att(att>1) = 1;
    att(att<0) = 0;

    %att = 1 - 0.8*att;
    ds_syntetic.radiation = rad.*att;

    %ds_syntetic = struct2table(ds_syntetic);
    %ds_syntetic.radiation = ds_syntetic.radiation + 0.15*ds_syntetic.radiation;
    %
    full_ds = [];
    for ivar = {'DateTime','temperature','humidity','wind','radiation'}
        full_ds.(ivar{:}) = [ds_hist.(ivar{:}); ds_forecast.(ivar{:}); ds_syntetic.(ivar{:})];
    end

    full_ds = struct2table(full_ds);
    %
end
