function r = HistoricalExternalClimateMungia(date_range)


InitDay = date_range(1);
InitDay.Hour = 0;
InitDay.Minute = 0;
InitDay.Second = 0;

EndDay  = date_range(2);
EndDay.Hour = 0;
EndDay.Minute = 0;
EndDay.Second = 0;
%%
i = 0;
measure = [];
for iday = InitDay:days(1):EndDay
    i = i + 1;
    try
    measure{i} = HistoricalExternalClimateMungia_1day(iday);
    fprintf("Do it: "+string(iday)+"\n")
    catch
        %measure{i} = [];
        measure{i} = measure{i-1}([],:);
        fprintf("No found : "+string(iday)+"\n")

    end
end
r = vertcat(measure{:});
