
function [full_ds,ds_forecast] = ExternalClimateBuilderNIOF(DateInit)

    %NIOF
    lat = 30.45846869104686;
    lon =  30.55153477683711;
    DGMT = 2;
    %%
    today = datetime(datestr(now));
    today.Minute = 0;
    today.Second = 0;
    today = today - hours(1);
    %%
    sc01 = [DateInit today];

    r = NIOFDataCall(sc01);
    ds_hist = [];
    ds_hist.DateTime = r.DateTime;
    %ds_hist.radiation = r.RadiacionEuskalmet_Sol;
    ds_hist.humidity = r.ambinet_Humi_Biological_filter_P_5;
    ds_hist.temperature = r.ambient_temp_Biological_filter_P_5;
    %ds_hist.wind = r.VelocidadVientoEuskalmet_Viento;
    
    
    load('EC_NIOF_2')
    load('data/SignalsGenerator_NIOF.mat')

    if ((ds.DateTime(1)<DateInit)&&(ds.DateTime(end)>DateInit))
        ds_hist.wind = interp1(ds.DateTime,ds.wind,ds_hist.DateTime);
        ds_hist.radiation = interp1(ds.DateTime,ds.radiation,ds_hist.DateTime);

        ds_hist = struct2table(ds_hist);

        ds_hist(isnan(sum(ds_hist{:,2:end},2)),:) = [];
    else
        rr_wind = genSignal(iSG.wind,DateInit,10);
        rr_wind = rr_wind(rr_wind.DateTime<today,:);
        rr_wind = rr_wind(2:end,:);
        ds_hist.wind = rr_wind.wind;
        %
        rad = DateTime2Rad(ds_hist.DateTime, lon,lat,DGMT);
        rad = rad + 0.15*rad;

        att = normrnd(0.7,0.6,size(rad));
        att = smoothdata(att,'movmean','SmoothingFactor',0.7);
        att(att>1) = 1;
        att(att<0) = 0;

        ds_hist.radiation = rad.*att;        
        
    end

    %%
    newDateTime = ds_hist.DateTime(1):hours(1):ds_hist.DateTime(end);
    new_ds_hist.DateTime = newDateTime';
    new_ds_hist.radiation   = interp1(ds_hist.DateTime,ds_hist.radiation,newDateTime)';
    new_ds_hist.humidity    = interp1(ds_hist.DateTime,ds_hist.humidity,newDateTime)';
    new_ds_hist.temperature = interp1(ds_hist.DateTime,ds_hist.temperature,newDateTime)';
    new_ds_hist.wind        = interp1(ds_hist.DateTime,ds_hist.wind,newDateTime)';

    ds_hist = struct2table(new_ds_hist);



    ds_forecast  = ForecastOPW(lat,lon);
    %%
    %%
    ds_syntetic = [];

    %     {'humidity'}    {'temperature'}    {'wind'}    {'radiation'}
    freqz = [4 40 40 4];
    freqz = [40 4 40 4];
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
