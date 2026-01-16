function data = xmldataread(fname, datalist, namelist)
% Function to read .xml data structure and return as cell string
% Used to read: F-5M / A-29 GENERAL+FLT_DAT and REAL_INV files
%               Google Earth .kml vector maps

if nargin == 0 || isempty(fname)
    [fname,fpath] = uigetfile('*.xml;*.kml','Arquivo de informações xml:');
    if ischar(fname)
        fname = [fpath fname];    
    else
        data = {};
        return
    end
end

if nargin == 2
    namelist = datalist;
end

fid = fopen(fname);
D = fread(fid)';
fclose(fid);

% Remove "ENTER" & "TAB"
D(D==10) = [];
D(D==13) = [];
D(D==9) = [];

% Remove adjacent spaces
S = D==32;
S2 = [0 S(1:end-1)];
exc = S&S2;
D(exc) = [];

% Remove spaces in the form "> <"
S = D==32;
S1 = [0 D(1:end-1)==abs('>')];
S2 = [D(2:end)==abs('<') 0];
exc = S1&S&S2;
D(exc) = [];

% Convert to char array
D = char(D);

if nargin < 2
    
    if     ~isempty(strfind(D,'<General>'))
        datalist{1} = {'General','DTC_Name','Mission_Name','Pilot_1_Name','Pilot_2_Name','Mission_Date','Mission_Time','AC_TYPE' ,'AC_Config'    };
        namelist{1} = {'General','DTC'     ,'Mission'     ,'Pilot'       ,'Copilot'     ,'Date'        ,'Time'        ,'Aircraft','Aircraft Type'};
        
    elseif ~isempty(strfind(D,'<Takeoff>'))
        datalist{1} = {'Takeoff','Date','Time','AC_TYPE','Tail_Num'};
        namelist{1} = {'Takeoff','Date','Takeoff','Aircraft','Tail Number'};
        datalist{2} = {'Landing','Time'};
        namelist{2} = {'Landing','Landing'};
        
    elseif ~isempty(strfind(D,'<Stat_INV>'))
        datalist{1} = {'Stat_INV','ID'        ,'Rack_Type','WPN1_Type','WPN1_Quan','WPN2_Type','WPN2_Quan'};
        namelist{1} = {'Stat_INV','---Station','Rack Type','Weapon 1' ,'Quantity' ,'Weapon 2' ,'Quantity' };
        
    else
        data = '';
        return
    end
    
end

data = {};

for n = 1:length(datalist)
    
    % Event blocks
    keyopen  = ['<'  datalist{n}{1} '>'];
    keyclose = strrep(keyopen,'<','</');
    
    Bi = strfind(D,keyopen);
    Bf = strfind(D,keyclose);
    
    if     length(Bi) > length(Bf)
        Bi = Bi(1:length(Bf));
    elseif length(Bi) < length(Bf)
        Bf = Bf(1:length(Bi));
    end
    
    if ~isempty(Bi) && all(Bf-Bi > 0)
        
        % Data found
        
        Np = length(datalist{n});
        
        for ne = 1:length(Bi)
            
            % Event block
            B = D(Bi(ne):Bf(ne));
            
            % Informations
            if Np > 1
                
                for np = 2:Np
                    ni = strfind(B,['<'  datalist{n}{np} '>']);
                    
                    if isempty(ni)
                        ed = {''};
                    else
                        
                        for m = 1:length(ni)
                            
                            nf = strfind(B(ni(m):end),'</')+ni(m)-1;
                            if isempty(nf)
                                ed{m} = '';
                            else
                                nf = nf(1);
                                
                                ed{m} = deblank(B( ni+length(datalist{n}{np})+2 : nf-1 ));
                                if isempty(ed{m})
                                    ed{m} = '-';
                                end
                                
                            end 
                        end
                    end
                    
                    for m = 1:length(ed)
                        if ~isempty(namelist{n}{np})
                            data{length(data)+1,1} = [namelist{n}{np} ': ' ed{m}];
                        else
                            data{length(data)+1,1} = ed{m};
                        end
                    end
                    ed = {};
                    
                end
                
            end
        end
    end
end
