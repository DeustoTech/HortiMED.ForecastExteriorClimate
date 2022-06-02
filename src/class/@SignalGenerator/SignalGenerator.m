classdef SignalGenerator
    %SIGNALGENERATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        TimeTable          timetable
        FS                  FourierStadistics
        limits              = [-inf inf]
    end
    
    methods
        function obj = SignalGenerator(TimeTable,size_samples,Nsamples)
            %SIGNALGENERATOR 
            obj.TimeTable = TimeTable;
            
            namevar = TimeTable.Properties.VariableNames(1);
            Values = TimeTable.(namevar{:});
            DateTimes = TimeTable.Properties.RowTimes;

            obj.FS = FourierStadistics(Values,DateTimes,size_samples,Nsamples);
        end
        
        function [sTT,oldsTT] = genSignal(obj,DateTime,copy_fq)
            

           DateRange = DateTime:hours(1):(DateTime + (obj.FS.SizeSamples)*hours(1)) ;
           TT = obj.TimeTable;
           namevar = obj.TimeTable.Properties.VariableNames(1);
            
           % indice en el que el dia del año coincide
           objDateTimes = TT.Properties.RowTimes;
           ind = find(day(objDateTimes,'dayofyear') == day(DateTime,'dayofyear'),1,'first');

           objDateTimes = objDateTimes + years(-objDateTimes(ind).Year + DateTime.Year);

           sValues = interp1(objDateTimes , ...
                         TT.(namevar{:})           , ...
                         DateRange);
           %
           
           %
           sTT.DateTime = DateRange';
           sTT.(namevar{:}) = sValues';
           
           sTT = struct2table(sTT);
           sTT = table2timetable(sTT);
           %
           %
           Values_fft = fft(sValues);

           st_angle = obj.FS(1).angle.std;
           st_abs   = obj.FS(1).abs.std;
           mu_angle = obj.FS(1).angle.mean;
           mu_abs   = obj.FS(1).abs.mean;           
           
           
           
           th = mean(st_angle) - std(st_angle);

           new_angle = 2*(rand(length(st_abs),1) - 0.5)*pi;
           new_angle(st_angle< th) = angle(Values_fft(st_angle< th));
            
           %copy_fq = 10;

           new_angle(1:copy_fq) =  angle(Values_fft(1:copy_fq));

            new_angle = [new_angle ;-flipud(new_angle(2:end))];
            new_angle(1) = 0;
            %
            new_abs   = random(1,mu_abs,5e-2*st_abs);
            new_abs(1:copy_fq) =  abs(Values_fft(1:copy_fq));
            new_abs(st_angle< th) = abs(Values_fft(st_angle< th));

            new_abs   =   [new_abs ;flipud(new_abs(2:end))];
            %
            newSignal_fft = new_abs.*exp(1i.*new_angle);
            newSignal = ifft(newSignal_fft);
            
            %%
            if ~isinf(obj.limits(1))
                newSignal(newSignal < obj.limits(1) ) =  obj.limits(1);
            end
            if ~isinf(obj.limits(2))
                newSignal(newSignal > obj.limits(2) ) =  obj.limits(2);
            end
            %%
            oldsTT = sTT;
            sTT.(namevar{:}) = newSignal;

            sTT.(namevar{:}) = lowpass(newSignal,0.5);
            
            
        end
         
    end
    
    
end


function data = random(N,mu,st)
    u1 = rand(N,1);
    u2 = rand(N,1);
    data = (sqrt(st.^3/(2*pi))).*(sqrt(-2.*log(u1))).*cos(2*pi*u2) + mu;    
end

