function newds = NIOFDataCall(time)

start = time(1);
stop = time(2);
    
dt = hours(1);
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
      % Biological filter P-5'
      
    call = ['from(bucket:"Egypt") |> range(start:',start,',stop:',stop,')  |> aggregateWindow(every: 1h, fn: mean, createEmpty: false)', ...
        '  |> filter(fn: (r) => r["_measurement"] == "ambient_temp" or r["_measurement"] == "ambinet_Humi")'];
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

    id = string(ds.x_measurement)+"+"+string(ds.SensorName);
    %ids = replace(id,' ','');
    vars = unique(id);

    
    vars(strcmp(vars,'_measurement-location')) = [];

   newds = [];

    
    newds.DateTime  = tspan';
    for ivar = vars'
        
        
       rs = strsplit(ivar{:},'+');
       
       ms = rs{1};
       loc = rs{2};
       
       bolean = strcmp(ds.SensorName,loc);
       select = ds(bolean,:);
       
       bolean = strcmp(select.x_measurement,ms);
       select = select(bolean,:);

       %
       %
       tspan_local = datetime(select.x_time,'InputFormat','yyyy-MM-dd''T''HH:mm:ss''Z''');
       values = select.x_value;
       %
       
       
       splits =  find(diff(tspan_local) > minutes(60));
       for is = splits
           values(is) = nan;
       end
       %
       new_name = replace(ivar{:},'%','_percent');
       new_name = replace(new_name,'+','_');
       new_name = replace(new_name,'-','_');
       new_name = replace(new_name,' ','_');
        try
            newds.(new_name) = interp1(tspan_local,values,tspan');
        catch
            
            "No interpolation "+new_name
        end
   
    end
    newds = struct2table(newds);
end
%%