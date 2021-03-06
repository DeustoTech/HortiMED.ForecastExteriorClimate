function ds = ForecastOPW(lat,lon)

% Meñaka

string_lat = num2str(lat);
string_lon = num2str(lon);

API_key = '22855c4d4d8f95c2869749a8b7c02487';

urlcall = "https://api.openweathermap.org/data/2.5/forecast?lat="        +  string_lat   + ...    
                                                            "&lon="       +  string_lon  + ...
                                                            "&appid="     + API_key;
r = webread(urlcall);

%%
i = 0;
ds = [];

try 
    r.list{1};
    key_type = true;
catch
    key_type = false;
end
      
    
for il = r.list'
    i = i + 1;
    %ds.temp_min(i,:) = il{:}.main.temp_min;
    %ds.temp_max(i,:) = il{:}.main.temp_max;

    if ~key_type
        il = {il};
    end
    ds.humidity(i,:) = il{:}.main.humidity;
    ds.clouds(i,:) = il{:}.clouds.all;

    ds.wind(i,:) = il{:}.wind.speed;
    ds.temperature(i,:) = il{:}.main.temp;

    ds.epoch_time(i,:) = il{:}.dt';
    ds.DateTime(i,:) = datetime(il{:}.dt_txt,'Format','yyyy-MM-dd HH:mm:ss')';
end
%%
DGMT = 2;
ds.radiation = DateTime2Rad(ds.DateTime,lon,lat,DGMT);

ds = struct2table(ds);
ds = ds(:,[1 2 3 4 5 7 6]);
%%
HourlyDateTime = ds.DateTime(1):hours(1):ds.DateTime(end);

ds_1interp.DateTime = HourlyDateTime';
for ivar = ds.Properties.VariableNames(1:end-1)
    ds_1interp.(ivar{:}) = interp1(ds.DateTime,ds.(ivar{:}),HourlyDateTime);
    if strcmp(ivar{:},'rad')||strcmp(ivar{:},'clouds')
        ds_1interp.(ivar{:}) = ds_1interp.(ivar{:})';
    else
        ds_1interp.(ivar{:}) = smoothdata(ds_1interp.(ivar{:}),'SmoothingFactor',0.1)';
    end
end

ds = ds_1interp;

ds.radiation = (1 - 0.3*ds.clouds/100).*ds.radiation;
ds = struct2table(ds);
ds.temperature = ds.temperature - 273.15;
end

