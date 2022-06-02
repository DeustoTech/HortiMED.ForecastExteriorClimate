%%
clear
DateInit = datetime('01-Jan-2022');
DateInit = datetime('31-May-2022');

DateEnd  = datetime('01-Dec-2022');
%%
today = datetime(datestr(now));
today.Minute = 0;
today.Second = 0;
today = today - hours(1);
%%
sc01 = DateInit:hours(1):today;
sc02 = today:hours(1):(today+days(7));
sc03 = (today+days(7)+hours(1)):hours(1):today;
