function  compareSignals(fig,r,rold,ititle)

%rng(0)
%iday = randsample(r.DateTime,9)';

l = length(r.DateTime);

index = floor(linspace(0.1,0.9,9)*l);
iday  = r.DateTime(index);

name_var = r.Properties.VariableNames(1);

ui1 =uipanel('parent',fig,'unit','norm','pos',[0 0.7 1.0 0.3]);

ax = axes('Parent',ui1);
%
plot(r.DateTime,r.(name_var{:}),'Parent',ax)
title(ititle)
hold on

plot(rold.DateTime,rold.(name_var{:}),'Parent',ax)
legend('syntetic','real')
grid on



ui2 =uipanel('parent',fig,'unit','norm','pos',[0 0.0 1.0 0.7]);

for i = 1:6
    subplot(3,2,i,'Parent',ui2)
    hold on 
    plot(r.DateTime,r.(name_var{:}),'LineWidth',2)
    plot(rold.DateTime,rold.(name_var{:}),'.')
    xlim([iday(i) iday(i)+5*days(1)*i])
    grid on
end
end

