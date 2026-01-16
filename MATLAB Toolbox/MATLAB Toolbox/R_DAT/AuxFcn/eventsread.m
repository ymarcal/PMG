function events = eventsread(fname, elist)
% Function to import F-5M / A-29 EVENTS and MFL files

if nargin == 0
    [fname,fpath] = uigetfile('*.xml','Arquivo de EVENTOS ou MFLs:');
    if ischar(fname)
        fname = [fpath fname];    
    else
        events = {};
        return
    end
end

fid = fopen(fname);
D = char(fread(fid)');
fclose(fid);

%                 Event Name       Ref Time      Param1          Param2        Param3  ...
eventlist{1}  = { 'Switches'     , 'UTC'       , 'MASS'        , 'Late_ARM'                  };
eventlist{2}  = { 'Takeoff'      , 'UTC'                                                     };
eventlist{3}  = { 'Touch_and_Go' , 'UTC'                                                     };
eventlist{4}  = { 'Land'         , 'UTC'                                                     };
eventlist{5}  = { 'AA_Trigger'   , 'UTC'       , 'SYS_Mode'   , 'Trigger_Num', 'Quantity'    };
eventlist{6}  = { 'AA_Pickle'    , 'UTC'       , 'SYS_Mode'   , 'Station'    , 'Weapon_Type' };
eventlist{7}  = { 'AG_Trigger'   , 'UTC'       , 'Trigger_Num', 'Quantity'                   };
eventlist{8}  = { 'AG_Release'   , 'UTC'       , 'SYS_Mode'   , 'Station'    , 'Weapon_Type' };
eventlist{9}  = { 'AA_X_Break'   , 'UTC'                                                     };
eventlist{10} = { 'WARN'         , 'Start_UTC' , 'ID'         , 'Warn_Limit'                 };
eventlist{11} = { 'Fuel_Warn'    , 'UTC'       , 'ID'         , 'Warn_Limit'                 };
eventlist{12} = { 'FRCS'         , 'UTC'       , 'HP_Num'     , 'Route_Num'  , 'FRCS_Value'  };
eventlist{13} = { 'MARK'         , 'UTC'       , 'ID'         , 'FYT_Num'    , 'MARK_Source' };
eventlist{14} = { 'FIX'          , 'UTC'       , 'FYT_Num'    , 'FIX_Source'                 };
eventlist{15} = { 'ACAL'         , 'UTC'       , 'FYT_Num'    , 'ACAL_Source'                };
eventlist{16} = { 'Jetisson'     , 'UTC'       , 'ID'         , 'Station'                    };
eventlist{17} = { 'CHAFF_&_FLARE', 'UTC'                                                   };
eventlist{18} = { 'MFL_REC'      , 'UTC'       , 'Sys_Name'   , 'LRU_Name'   , 'Fault_Code', 'State', 'Supp_Data'};

if nargin == 2
    try
        eventlist = eventlist(elist);
    end
end

events = {};

for n = 1:length(eventlist)
    
    % Event blocks
    Bi = strfind(D,['<'  eventlist{n}{1} '>']);
    Bf = strfind(D,['</' eventlist{n}{1} '>']);
    
    if     length(Bi) > length(Bf)
        Bi = Bi(1:length(Bf));
    elseif length(Bi) < length(Bf)
        Bf = Bf(1:length(Bi));
    end
    
    if ~isempty(Bi) && all(Bf-Bi > 0)
        
        % Event type found
        
        Np = length(eventlist{n});
        NE = size(events,1);
        
        for ne = 1:length(Bi)
            
            % Event block
            B = D(Bi(ne):Bf(ne));
            
            % Validity
            events{NE+ne,1} = 1;
            
            % Time        
            ni = strfind(B,['<'  eventlist{n}{2} '>']);
            nf = strfind(B,['</' eventlist{n}{2} '>']);
            
            if ~isempty(ni+nf)
                et = sscanf( B( ni+length(eventlist{n}{2})+2 : nf-1 ), '%f');
                if isempty(et)
                    et = NaN;
                end
            else
                et = NaN;
            end
            events{NE+ne,2} = et/1000;
            
            % Descr
            descr = eventlist{n}{1};
            if Np > 2
                
                for np = 3:Np
                    ni = strfind(B,['<'  eventlist{n}{np} '>']);
                    nf = strfind(B,['</' eventlist{n}{np} '>']);
                    
                    if ~isempty(ni+nf)
                        ed = B( ni+length(eventlist{n}{np})+2 : nf-1 );
                    else
                        ed = '';
                    end
                    if ~isempty(ed)
                        ned = str2double(ed);
                        if ~isnan(ned)
                            ed = num2str(ned);
                        end
                        
                        if np == 3
                            descr = [descr ' (' eventlist{n}{np} ': ' ed];
                        else
                            descr = [descr ', ' eventlist{n}{np} ': ' ed];
                        end
                    end
                    
                end
                descr = [descr ')'];
                
            end
            events{NE+ne,3} = descr;
        end
    end
end

if ~isempty(events)
    [void,ind] = sort([events{:,2}]);
    events = events(ind,:);    
end

str_corr = {
    'Land','Landing';
    'Late_ARM','LASS';
    'Start_UTC','UTC';
    'SYS_Mode','Mode';
    'X_Break','X-Break';
    'Trigger_Num','Burst';
    'Quantity','Ammo';
    '_Type','';
    '_Name','';
    '_Num','';
    'CHAFF_&_FLARE','CH/FL';
    'MFL_REC','MFL';
    'Sys_Name','System';
    '_',' '};

for n = 1:size(events,1)
    for m = 1:size(str_corr,1)
        events{n,3} = strrep(events{n,3},str_corr{m,1},str_corr{m,2});
    end
end

for n = 1:size(events,1)
    for m = 1:size(str_corr,1)
        events{n,3} = strrep(events{n,3},str_corr{m,1},str_corr{m,2});
    end
end

% Trigger Press and Trigger Release
trig = [];
for n = 1:size(events,1)
    descr = events{n,3};
    if ~isempty(strfind(descr,'Trigger'))
        c1 = strfind(descr,'Burst')+6;
        c2 = strfind(descr,'Ammo')-3;
        try
            num = str2double(descr(c1:c2));
            trig(num,1) = num;
            if size(trig,2) == 1
                trig(1,2:3) = 0;
            end
            if ~trig(num,2) % Press
                trig(num,2) = events{n,2};
                events{n,3} = strrep(events{n,3},'Trigger','Trigger Press');
            else           % Release
                trig(num,3) = events{n,2};
                events{n,3} = strrep(events{n,3},'Trigger','Trigger Release');
            end
        end
    end
end
