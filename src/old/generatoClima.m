clear 
close all
load('ExternaClimateMenaka_hourly_2020_2021')

EC(isnan(EC.radiation),:) = [];

    
iter = 0;
Nt = size(EC,1);


Nsamples = 1000;
size_samples = 8000;
fourier_terms = zeros(size_samples+1,Nsamples);

dates = EC.DateTime(1);
for i = 1:Nsamples
    
%
    %ind = randsample(find(logical((day(EC.DateTime,'dayofyear') == 1 )+(day(EC.DateTime,'dayofyear') == 177))),1);

    ind = randsample(find(EC.DateTime.Hour == 0),1);
    %ind = randsample(1:Nt,1);

    
    maxind = ind+size_samples;
    if maxind > Nt 
        continue
    end 
    iter = iter + 1;

    iEC = EC(ind:maxind,:);
    dates(iter) = iEC.DateTime(1);

    %
    Values = iEC.temperature;
    %
    fourier_terms(:,iter) = fft(Values);
    if mod(iter,50) == 1
        fprintf("Iter = "+iter+"\n")
    end

end

fourier_terms = fourier_terms(:,1:iter);
%%
figure
clf
sl = 1:((size_samples)/2+1);

subplot(2,1,1)
hold on
subplot(2,1,2)
hold on

for i = 1:20:size(fourier_terms,2)
    subplot(2,1,1)
    plot(log(abs(fourier_terms(sl,i))),'marker','.','LineStyle','none','color',[1 0.5 0.5])
    subplot(2,1,2)
    plot((angle(fourier_terms(sl,i))),'marker','.','LineStyle','none','color',[1 0.5 0.5])
    
end
%
subplot(2,1,1)
mu_abs = mean(abs(fourier_terms(sl,:)),2); 
st_abs = std(abs(fourier_terms(sl,:)),[],2); 

plot(log(mu_abs),'marker','none','LineStyle','-','LineWidth',2)
plot(log(mu_abs + 0.5*st_abs),'marker','none','LineStyle','-','LineWidth',2)
plot(log(mu_abs - 0.5*st_abs),'marker','none','LineStyle','-','LineWidth',2)


subplot(2,1,2)
mu_angle = mean(angle(fourier_terms(sl,:)),2); 

st_angle = std(angle(fourier_terms(sl,:)),[],2); 

plot(mu_angle,'marker','none','LineStyle','-','color','k','LineWidth',2)
plot((mu_angle + 0.5*st_angle),'marker','none','LineStyle','-','LineWidth',2)
plot((mu_angle - 0.5*st_angle),'marker','none','LineStyle','-','LineWidth',2)

%%
ind = randsample(Nt,1);
maxind = ind+size_samples;
%
iEC = EC(ind:maxind,:);

%%
Values = iEC.temperature;


Values_fft = fft(Values);

th = mean(st_angle) - std(st_angle);
%
%st_angle(st_angle< th) = 0;
new_angle = 2*(rand(length(st_abs),1) - 0.5)*pi;
%new_angle   = angle(fft(iEC.radiation));
new_angle(st_angle< th) = angle(Values_fft(st_angle< th));
%new_angle   = random(1,mu_angle,10*st_angle);

copy_fq = 2;

new_angle(1:copy_fq) =  angle(Values_fft(1:copy_fq));

new_angle = [new_angle ;-flipud(new_angle(2:end))];
new_angle(1) = 0;

%
new_abs   = random(1,mu_abs,1e-2*st_abs);
new_abs(1:copy_fq) =  abs(Values_fft(1:copy_fq));
new_abs(st_angle< th) = abs(Values_fft(st_angle< th));

new_abs   =   [new_abs ;flipud(new_abs(2:end))];
%


newSignal_fft = new_abs.*exp(1i.*new_angle);
%
%


%
%

figure
subplot(3,1,1)
hold on
plot(iEC.DateTime,mag2db(abs(newSignal_fft)),'LineWidth',3)
plot(iEC.DateTime,mag2db(abs(fft(Values))))
legend('newT','T')
title('log(abs)')
subplot(3,1,2)
hold on
plot(iEC.DateTime,angle(newSignal_fft))
plot(iEC.DateTime,angle(fft(Values)))

title('angle')

newT = ifft(newSignal_fft);
%
subplot(3,1,3)
hold on


%newT = (Values) + std(Values)*(newT  - mean(newT))/std(newT);



plot(iEC.DateTime,(newT))
plot(iEC.DateTime,(Values))
ylim([-5 40])
legend('newT','T')
title('newT generation')
% 
% figure
% lowpass((newT),0.5)

%%
clf 
plot(EC.DateTime,EC.temperature)
periodogram(EC.temperature)

%%
function data = random(N,mu,st)
    u1 = rand(N,1);
    u2 = rand(N,1);
    data = (sqrt(st.^3/(2*pi))).*(sqrt(-2.*log(u1))).*cos(2*pi*u2) + mu;    
end
