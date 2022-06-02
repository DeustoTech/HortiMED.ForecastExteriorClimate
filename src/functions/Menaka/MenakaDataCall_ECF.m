function newds = MenakaDataCall_EFC(time)

start = time(1);
stop = time(2);
    
dt = minutes(10);
tspan = start:dt:stop;
tspan(1) = [];
tspan(end) = [];
%%
start = datestr(start,'yyyy-mm-ddThh:MM:ssZ');
stop = datestr(stop,'yyyy-mm-ddThh:MM:ssZ');

%%
    import matlab.net.http.*
    import matlab.net.http.field.*


    token = 'UKVdPxGnl3lPFwGlWjgj96H8D3YvRCUtfdD37wkVxOzEX8mNs1JhvQKi3MEsfhBkIrwrX3mn_Ge23GzNsW89cA==';

    headers = [ ContentTypeField(  'application/vnd.flux'  ), ...
                AcceptField(       'application/csv'       ), ...
                AuthorizationField('Authorization',"Token "+token                   )];

      %%      
    call = ['from(bucket:"Spain") |> range(start:',start,',stop:',stop,')'];
    body = matlab.net.http.MessageBody(call);

    %%
    request = RequestMessage( 'POST',headers,body);
    %%
    org = "6ca3aa4b9c7becd5";
    uri = 'http://ec2-34-248-89-116.eu-west-1.compute.amazonaws.com:8086/api/v2/query?org='+org;
    r = send(request,uri);

    %%
    ds = r.Body.Data;
    %
    if isempty(ds)
        error("Doesn't exist any data in this time interval")
    end

    id = string(ds.x_measurement)+"-"+string(ds.location);

    vars = unique(id);

    
    vars(strcmp(vars,'_measurement-location')) = [];

    newds = [];

    
    newds.DateTime  = tspan';
    for ivar = vars'
        
        
       rs = strsplit(ivar{:},'-');
       
       ms = rs{1};
       loc = rs{2};
       
       bolean = strcmp(ds.location,loc);
       select = ds(bolean,:);
       
       bolean = strcmp(select.x_measurement,ms);
       select = select(bolean,:);

       %
       %
       tspan_local = datetime(select.x_time,'InputFormat','yyyy-MM-dd''T''HH:mm:ss''Z''');
       values = select.x_value;
       %
       
       switch ivar
           
           case {"pH-pH_1","pH-pH_2","pH-pH_3","pH-pH_4"}
               values(values<5) = nan;
           case "Temperatura-Temperatura"
               values(values>50) = nan;
           case "CO2-CO2"
               values(values<100) = nan;
           case "Humedad-Humedad"
               values(values<5) = nan;
           case {"CE-CE_1","CE-CE_2","CE-CE_3","CE-CE_4"}
               values(values<0.01) = nan;
       end
       
       splits =  find(diff(tspan_local) > minutes(60));
       for is = splits
           values(is) = nan;
       end
       %
       newds.(replace(ivar{:},'-','_')) = interp1(tspan_local,values,tspan)';

   
    end
    newds = struct2table(newds);
end
%%
