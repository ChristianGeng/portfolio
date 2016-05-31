function  [userdata,connected,active,sample,sweep,dataS,dataC,pos] = tryconnect(machine, userdata)

%  %[userdata, connectedCS6, activeCS6,sampleCS6,sweepCS6,dataSCS6,dataCCS6,posCS6]=tryconnect('CS6',userdata)
% strcmp(machine,'CS6')

%     if strcmp(machine,'CS6'),
%              disp ('test 6');
%     elseif strcmp(machine,'CS5'),
%              disp('test 5');
%     else, disp('Machine must be either CS5 or CS6.');
%     end
%     
%     
skipnew=1;

if ~skipnew
    readok=0;
    while ~readok
        try,
         switch (machine)
         case 'CS6'
               [active,sample,sweep,dataS,dataC,pos] = getEmaAll (userdata.socketCS6);
         case 'CS5'
                [active,sample,sweep,dataS,dataC,pos] = getEmaAll (userdata.socketCS5);
         otherwise
           error('Machine must be either CS5 or CS6.');
         end
            readok=1;
        catch
            disp('Reconnecting ...');
            %		disp(['I think I lost the connection...' crlf 'Type
            %		return when ready to reconnect!']);
            retrycount=0;
            connected=0;
            retrylimit=10;
            while ~connected
                try
                   switch (machine)
                    case 'CS6'
                        userdata.socketCS6.close; %close the socket in any case, maybe timeout
                        %was for different reasons than a broken
                        %socket
                        userdata.socketCS6=lida_connect_CS6(userdata.lidatimeout);
                        [active,sample,sweep,dataS,dataC,pos] = getEmaAll (userdata.socketCS6);
                    case 'CS5'
                           userdata.socketCS5.close; %close the socket in any case, maybe timeout
                        %was for different reasons than a broken
                        %socket
                        userdata.socketCS5=lida_connect_CS5(userdata.lidatimeout);
                        [active,sample,sweep,dataS,dataC,pos] = getEmaAll (userdata.socketCS5); 
                       otherwise
                           error('Machine must be either CS5 or CS6.');
                      end
                     connected=1;
                catch
                    retrycount=retrycount+1;
                    if retrycount==retrylimit
                        disp('Unable to reconnect?');
                        disp([machine, ': Is CS5recorder running?']);
                        keyboard;
                        switch (machine)
                    case 'CS6'
                        userdata.socketCS6.close; %close the socket in any case, maybe timeout
                        %was for different reasons than a broken
                        %socket
                        userdata.socketCS6=lida_connect_CS6(userdata.lidatimeout);
                        [active,sample,sweep,dataS,dataC,pos] = getEmaAll (userdata.socketCS6);
                    case 'CS5'
                           userdata.socketCS5.close; %close the socket in any case, maybe timeout
                        %was for different reasons than a broken
                        %socket
                        userdata.socketCS5=lida_connect_CS5(userdata.lidatimeout);
                        [active,sample,sweep,dataS,dataC,pos] = getEmaAll (userdata.socketCS5); 
                       otherwise
                           error('Machine must be either CS5 or CS6.');
                      end
                         connected=1;
                    end;
                end;
            end;
        end;
    end;
end

skipold=0;

if ~skipold
    conrepeat=0;
    maxconrepeat=10;
    %==================
    while 1
        try
            switch (machine)
                 case 'CS6'
                     [active,sample,sweep,dataS,dataC,pos] = getEmaAll (userdata.socketCS6);
                 case 'CS5'
                     [active,sample,sweep,dataS,dataC,pos] = getEmaAll (userdata.socketCS5);   
                 otherwise
                    error('Machine must be either CS5 or CS6.');
                end     
        catch
             switch (machine)
                 case 'CS6'
                    %disp(['I think I lost the connection...' crlf 'Type return when ready to reconnect!']);
                     userdata.socketCS6.close; %close the socket in any case, maybe timeout
                     %was for different reasons than a broken
                     %socket
                 case 'CS5'
                      %disp(['I think I lost the connection...' crlf 'Type return when ready to reconnect!']);
                     userdata.socketCS5.close; %close the socket in any case, maybe timeout
                     %was for different reasons than a broken
                      %socket
                 otherwise
                    error('Machine must be either CS5 or CS6.');
                end     
            if (conrepeat >= maxconrepeat)
                disp('Failed to connect. Is "CS5recorder" running?');
                disp('Type return to try again.');
                keyboard;
                conrepeat=0;
                disp('Type return to stop');
                continue;
            end
                  conrepeat=conrepeat+1;
                  disp([machine ': Connection lost. Auto reconnect try ' num2str(conrepeat) ' of ' num2str(maxconrepeat) '.']);
            try
                pause(0.2);
               switch (machine)
                 case 'CS6'
                           userdata.socketCS6=lida_connect_CS6(userdata.lidatimeout);
                 case 'CS5'
                          userdata.socketCS5=lida_connect_CS5(userdata.lidatimeout);
                 otherwise
                    error('Machine must be either CS5 or CS6.');
                end  
                  connected=true;
            catch
            end
            continue
        end
        break;
    end
end

%==================









