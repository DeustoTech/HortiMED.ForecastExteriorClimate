clear 
close all
load('ExternaClimateMenaka_hourly_2020_2021')

EC(isnan(EC.radiation),:) = [];
EC(isnan(EC.wind),:) = [];
EC(isnan(EC.humidity),:) = [];

%
%%
Nsamples = 5000;
size_samples = 1000;

iter = 0;

iSG = [];

TT = table2timetable(EC(:,{'DateTime','temperature'}));

iSG = SignalGenerator(TT,size_samples,Nsamples);

%%

save_path = 'data/fft_data';
mkdir(fullfile(save_path,'trajectories'))
mkdir(fullfile(save_path,'fft'))

for i = 1:length(iSG.FS.ec)
    fq = iSG.FS.FourierTerms(:,i);
    img = [];
    img.module = abs(fq) ;
    img.angle  = angle(fq);
    img = struct2table(img);
    writetable(iSG.FS.ec{i},fullfile(save_path,'trajectories',"traj_"+num2str(i,'%.5d')+".csv"))
    writematrix(img{:,:},fullfile(save_path,'fft',"fft_traj_"+num2str(i,'%.5d')+".txt"))
end
%%