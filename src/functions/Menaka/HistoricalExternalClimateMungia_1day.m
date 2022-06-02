function ds_all = HistoricalExternalClimateMungia_1day(date)
% https://www.euskalmet.euskadi.eus/observacion/datos-de-estaciones/#
% Historicos recientes de Mungia 



% Descriptions of variables

% Station Code 
stat_code = 'C057';

url = "https://www.euskalmet.euskadi.eus/vamet/stations/readings/"+ ...
       stat_code+ ...
       "/" + num2str(date.Year,'%04.f')   + ...
       "/" + num2str(date.Month,'%02.f')  + ...
       "/" + num2str(date.Day,'%02.f')    + ...
       "/readingsData.json";

r = webread(url);
%%


% x11 wind
% x31 humidity
% x21 temperature
% x70 radiation
%
names_var = {'wind','humidity','temperature','radiation'};

iter = 0;
ds = [];
for key = {'x11','x31','x21','x70'}
    iter = iter + 1;
    subname = fieldnames(r.(key{:}).data);
    signal = r.(key{:}).data.(subname{:});

    date_str = string(datestr(date));
    time = fieldnames(signal);
    time = arrayfun(@(i)  datetime(date_str +" "+i{:}(2:3)+":"+i{:}(5:6)),time,'UniformOutput',1);
    values = struct2array(signal);

    ds(iter).(names_var{iter}) = values;
    ds(iter).DateTime = time;

end

DateTimeAlls = unique(vertcat(ds.DateTime));
%%
ds_all = [];
ds_all.DateTime = DateTimeAlls;
for i = 1:4
    ds_all.(names_var{i}) = interp1(ds(i).DateTime,ds(i).(names_var{i}),DateTimeAlls);
end
ds_all = struct2table(ds_all);

end

