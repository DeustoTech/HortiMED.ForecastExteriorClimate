clear 

load('ExternaClimateMenaka_hourly_2020_2021')
%%
lat  = 43.349024834327; 
lon = -2.797651290893;
DGMT = 2;    
%
Elevation = DateTime2Elevation(EC.DateTime,lon,lat,DGMT);
delta     =  Day2Declination(EC.DateTime);
Rad       = DateTime2Rad(EC.DateTime,lon,lat,DGMT);
%%
EC.Delta = delta;
EC.Elevation = Elevation;
EC.Rad = Rad;
EC(isnan(EC.radiation),:) = [];

%%
T = EC.temperature;
%

%%
figure(1)
clf
hold on
plot(EC.DateTime,5.5*EC.Rad.^0.5+EC.Rad+10);
plot(EC.DateTime,EC.radiation);
legend
%%

tspan = days(EC.DateTime - EC.DateTime(1));
x0 = 15*rand(4,1);
%%

%Nfreq = 300;
%freq = (length(EC.Rad)-(Nfreq-1)):length(EC.Rad);
freq = primes(700);
Nfreq = length(freq);
amplitud = 100./(1:Nfreq).^0.25;
amplitud = 1 + 0*(1:Nfreq);
Rad_noise = EC.Rad;
Rad_noise = Rad_noise - 1000*(1/Nfreq)*sum(amplitud.*abs(sin(2*pi.*freq.*tspan/tspan(end))),2);
%Rad_noise =Rad_noise- 100*rand(size(EC.Rad));
%Rad_noise = smoothdata(Rad_noise,'SmoothingFactor',0.05);
figure(5)

lowpass(Rad_noise,0.2)

figure(3)
lowpass(EC.radiation,0.2)
%%



%%
ut = griddedInterpolant(tspan,Rad_noise) ;
%%
%ut = griddedInterpolant(tspan,EC.radiation);


[tspan,xt] = ode23(@(t,x) [ 1.75  *( -1.5*(+x(1) - x(2))   + 1.5*ut(t)^0.5 )      ; ...
                            0.15 *( +1.5*(-x(2) + x(1))   + 3*(-x(2) + x(3))) ; ...
                            0.10 *( +3.0*(-x(3) + x(2))   + 1*(-x(3) + x(4))) ; ...
                            0.1 *( -1.0*(-x(4) + x(3))    + 1*(-x(4) + 2))   ], ...
    tspan,x0);
%
clf
subplot(2,1,1)
hold on
plot(tspan,xt)
plot(tspan,EC.temperature)
%
legend
subplot(2,1,2)
plot(tspan,ut(tspan))

%%
figure
lowpass(xt(:,1),0.1)

%%
figure
lowpass(T,0.1)

%%
figure
lowpass(EC.Rad,0.1)
%%
figure
lowpass(Rad_noise,0.2)
%%
figure
lowpass(EC.radiation,0.1)
%%
figure
highpass(EC.radiation,0.1)
