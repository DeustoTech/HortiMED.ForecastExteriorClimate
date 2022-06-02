classdef FourierStadistics
    %FOURIERSTADISTICS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        FourierTerms
        angle
        abs
        SizeSamples
        NumbSamples
        ec
    end
    
    methods
        function obj = FourierStadistics(Values,DateTimes,SizeSamples,NumbSamples)
            %FOURIERSTADISTICS Construct an instance of this class
            %   Detailed explanation goes here
            
            Nt = length(Values);
            obj.SizeSamples = SizeSamples;
            obj.NumbSamples = NumbSamples;
            fourier_terms = zeros(SizeSamples+1,NumbSamples);
            
            iter = 0;
            ec = [];
            for i = 1:NumbSamples

                ind = randsample(find(DateTimes.Hour == 0),1);

                maxind = ind+SizeSamples;
                if maxind > Nt 
                    continue
                end 
                iter = iter + 1;

                sValues = Values(ind:maxind);

                ss.Value = sValues;
                ss.DateTime = DateTimes(ind:maxind);
                
                ec{iter} = struct2table(ss);
                %
                fourier_terms(:,iter) = fft(sValues);

            end
            if true
                obj.ec = ec;
                obj.FourierTerms = fourier_terms(:,1:iter);  

            end
            
            SizeSamples = size(fourier_terms,1);
            sl = 1:((SizeSamples)/2+1);

            obj.angle.mean =  mean(angle(fourier_terms(sl,:)),2);
            obj.angle.std =  std(angle(fourier_terms(sl,:)),[],2);
            
            obj.abs.mean =  mean(abs(fourier_terms(sl,:)),2);
            obj.abs.std =  std(abs(fourier_terms(sl,:)),[],2);
            
        end
        function plot(obj)

            size_samples = obj.SizeSamples;
            fourier_terms = obj.FourierTerms;
            %
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
            mu_abs =  obj.abs.mean; 
            st_abs =  obj.abs.std; 

            plot(log(mu_abs),'marker','none','LineStyle','-','LineWidth',2)
            plot(log(mu_abs + 0.5*st_abs),'marker','none','LineStyle','-','LineWidth',2)
            plot(log(mu_abs - 0.5*st_abs),'marker','none','LineStyle','-','LineWidth',2)


            subplot(2,1,2)
            mu_angle =  obj.angle.mean; 
            st_angle =  obj.angle.std; 
            plot(mu_angle,'marker','none','LineStyle','-','color','k','LineWidth',2)
            plot((mu_angle + 0.5*st_angle),'marker','none','LineStyle','-','LineWidth',2)
            plot((mu_angle - 0.5*st_angle),'marker','none','LineStyle','-','LineWidth',2)

        end
    end
end

