function scenario = scenarioread(fpath,fname,opt)
% Function to import F-5M / A-29 scenario files

if nargin == 0
    fpath = [];
    fname = [];
    opt = 'all';
elseif nargin == 1
    fname = [];
    opt = 'all';
elseif nargin == 2
    opt = 'all';
end

if isempty(fpath)
    fpath = uigetdir('*.xml','Pasta dos arquivos de cenário F-5M / A-29:');
    fname = [];
    if ~ischar(fpath)
        scenario = {};
        return
    end
end

if ~isempty(fname)
    fname = [fpath fname];
end

% Magnetic variation
if strcmp(opt,'all')
    try
        fname = [fpath filesep 'NAV_SYS.xml'];
        if exist(fname,'file')
            fid = fopen(fname); D = char(fread(fid)'); fclose(fid);
            Dmag = getxmldata(D,'General_Warn',{'Mag_Var'});
        else
            Dmag = {};
        end
        fname = [];
    catch
        Dmag = {};
    end
else
    Dmag = {};
end

% Map
scenario.mappos  = {};
scenario.mapname = {};

% Waypoints
if strcmp(opt,'all') || strcmp(opt,'wpt')
    try
        if isempty(fname)
            fname = [fpath filesep 'WAYPOINT.xml'];
        end
        if exist(fname,'file')
            fid = fopen(fname); D = char(fread(fid)'); fclose(fid);
            wptdata = getxmldata(D,'Way_Point_Rec',{'ID','LAT','LONG','Elev','Name'});
            if isempty(wptdata) % Airfields
                fid = fopen(fname); D = char(fread(fid)'); fclose(fid);
                wptdata = getxmldata(D,'Airfield_Rec',{'ID','LAT','LONG','Elev','Name'});
            end
        else
            wptdata = {};
        end
        fname = [];
    catch
        wptdata = {};
    end
else
    wptdata = {};
end

% Airfields
if strcmp(opt,'all') || strcmp(opt,'wpt') || ( strcmp(opt,'aid') && ~strcmp(opt,'wpt') )
    try
        if isempty(fname) && strcmp(opt,'all')
            fname = [fpath filesep 'AIRFIELD.xml'];
        end
        if exist(fname,'file')
            fid = fopen(fname); D = char(fread(fid)'); fclose(fid);
            airfdata = getxmldata(D,'Airfield_Rec',{'ID','LAT','LONG','Elev','Name'});
        else
            airfdata = {};
        end
        fname = [];
    catch
        airfdata = {};
    end
else
    airfdata = {};
end

wptdata = [wptdata; airfdata];

% Flight Areas
if strcmp(opt,'all') || strcmp(opt,'fa')
    try
        if isempty(fname)
            fname = [fpath filesep 'FLT_AREA.xml'];
        end
        if exist(fname,'file')
            fid = fopen(fname); D = char(fread(fid)'); fclose(fid);
            fadata1 = getxmldata(D,'Area',{'Name','Type','Points_Cntr'});
            fadata2 = getxmldata(D,'Point',{'Point_ID','LAT','LONG'});
            
            Pt_ID = str2num([fadata2{:,1}]');
            N_pts = str2num([fadata1{:,3}]');
            if sum(N_pts) ~= size(fadata2,1)
                n1 = find(Pt_ID==1);
                n2 = n1 + N_pts - 1;
                inc = [];
                for n = 1:length(n1)
                    inc = [inc n1(n):n2(n)];
                end
                fadata2 = fadata2(inc,:);
            end
        else
            fadata1 = {};
            fadata2 = {};
        end
        fname = [];
    catch
        fadata1 = {};
        fadata2 = {};
    end
else
    fadata1 = {};
    fadata2 = {};
end

% Routes
if strcmp(opt,'all') || strcmp(opt,'rt')
    try
        if isempty(fname)
            fname = [fpath filesep 'F_ROUTE.xml'];
        end
        if exist(fname,'file')
            fid = fopen(fname); D = char(fread(fid)'); fclose(fid);
            rtdata1 = getxmldata(D,'Flight_Route_Rec',{'WayP_Cntr'});
            rtdata2 = getxmldata(D,'WayP',{'WP_ID'});
        else
            rtdata1 = {};
            rtdata2 = {};
        end
        fname = [];
    catch
        rtdata1 = {};
        rtdata2 = {};
    end
else
    rtdata1 = {};
    rtdata2 = {};
end

% Avoid zone
if strcmp(opt,'all') || strcmp(opt,'avd')
    try
        if isempty(fname)
            fname = [fpath filesep 'AVD_AREA.xml'];
        end
        if exist(fname,'file')
            fid = fopen(fname); D = char(fread(fid)'); fclose(fid);
            avddata = getxmldata(D,'Avoidance_Area',{'LAT','LONG','RADIUS'});
        else
            avddata = {};
        end
        fname = [];
    catch
        avddata = {};
    end
else
    avddata = {};
end

% Threat area
if strcmp(opt,'all') || strcmp(opt,'thr')
    try
        if isempty(fname)
            fname = [fpath filesep 'THR_AREA.xml'];
        end
        if exist(fname,'file')
            fid = fopen(fname); D = char(fread(fid)'); fclose(fid);
            thrdata1 = getxmldata(D,'Threat_Area',{'LAT','LONG','Code'});
        else
            thrdata1 = {};
        end
        fname = [fpath filesep 'THR_CODE.xml'];
        if exist(fname,'file')
            fid = fopen(fname); D = char(fread(fid)'); fclose(fid);
            thrdata2 = getxmldata(D,'Threat_Code',{'ID','Code_Label','Alt_1','Alt_2','Radius_1','Radius_2'});
        else
            thrdata2 = {};
        end
        fname = [];
    catch
        thrdata1 = {};
        thrdata2 = {};
    end
else
    thrdata1 = {};
    thrdata2 = {};
end

% Contact line
if strcmp(opt,'all') || strcmp(opt,'cnt')
    try
        if isempty(fname)
            fname = [fpath filesep 'CNT_LINE.xml'];
        end
        if exist(fname,'file')
            fid = fopen(fname); D = char(fread(fid)'); fclose(fid);
            cntdata = getxmldata(D,'Contact_Line',{'LAT','LONG'});
        else
            cntdata = {};
        end
        fname = [];
    catch
        cntdata = {};
    end
else
    cntdata = {};
end

% Data formating ---------------------

if ~isempty(fname) && exist([fpath fname],'file')
    aux = dir([fpath fname]);
    scenario.date = datestr(aux(end).date,'dd/mm/yyyy');
else
    d = clock;
    scenario.date = [num2str(d(3),'%02.0f') '/' num2str(d(2),'%02.0f') '/' num2str(d(1))];
end

if ~isempty(Dmag)
    scenario.Dmag = str2double(Dmag{1});
    if isnan(scenario.Dmag)
        scenario.Dmag = 0;
    end
else
    scenario.Dmag = 0;
end
if ~isempty(airfdata)
    try
        aid = 1;
        scenario.aid.code = airfdata(:,5);
        scenario.aid.data = [str2double(airfdata(:,2:3))*180 str2double(airfdata(:,4))];
        for n = 1:size(airfdata,1)
            scenario.aid.type{n,1} = 'AFLD';
            scenario.aid.data(n,4) = 45;
        end
    catch
        aid = 0;
        scenario.aid = [];
        beep; uiwait(errordlg('Erro ao converter aerodrómos.','Erro','modal'));
    end
else
    aid = 0;
    scenario.aid = [];
end
if ~isempty(wptdata)
    try
        wpt = 1;
        scenario.wpt.code = wptdata(:,5);
        scenario.wpt.data = [str2double(wptdata(:,1)) str2double(wptdata(:,2:3))*180 str2double(wptdata(:,4))];
    catch
        wpt = 0;
        scenario.wpt = [];
        beep; uiwait(errordlg('Erro ao converter waypoints.','Erro','modal'));
    end
else
    wpt = 0;
    scenario.wpt = [];
end
if ~isempty(fadata1) && ~isempty(fadata2)
    try
        fa = 1;
        for n = 1:size(fadata1,1)
            scenario.fa(n).code  = fadata1{n,1};
            scenario.fa(n).descr = '';
        end
        points = str2double(fadata2(:,2:3))*180;
        np = str2double(fadata1(:,3));
        pf = cumsum(np);
        pi = pf-np+1;
        fatypes  = {  'A',  'B',  'C',  'D',  'E',  'F', 'G', 'H'};
        fastyles = {'-.y','-.g','-.m','--y','--g','--m','-y','-m'};
        for n = 1:length(scenario.fa)
            k = strmatch(fadata1{n,2},fatypes);
            scenario.fa(n).style = fastyles{k}(1:end-1);
            scenario.fa(n).color = fastyles{k}(end);
            scenario.fa(n).data = points(pi(n):pf(n),:);
            if ~isequal(scenario.fa(n).data(1,:),scenario.fa(n).data(end,:))
                scenario.fa(n).data(end+1,:) = scenario.fa(n).data(1,:);
            end
        end
    catch
        fa = 0;
        scenario.fa = [];
        beep; uiwait(errordlg('Erro ao converter áreas de voo.','Erro','modal'));
    end
else
    fa = 0;
    scenario.fa = [];
end

if ~isempty(rtdata1) && ~isempty(rtdata2)
    try
        rt = 1;
        wpoints = str2double(rtdata2)';
        wpoints(~wpoints) = [];
        np = str2double(rtdata1);
        pf = cumsum(np);
        pi = pf-np+1;
        for n = 1:length(np)
            scenario.rt(n).wpt = wpoints(pi(n):pf(n));
        end
    catch
        rt = 0;
        scenario.rt = [];
        beep; uiwait(errordlg('Erro ao converter rotas.','Erro','modal'));
    end
else
    rt = 0;
    scenario.rt = [];
end
if strcmp(opt,'all')
    if isempty(scenario.wpt)
        rt = 0;
        scenario.rt = [];
    end    
    for n = 1:length(scenario.rt)
        for k = length(scenario.rt(n).wpt):-1:1
            ki = find(scenario.rt(n).wpt(k)==scenario.wpt.data(:,1));
            if isempty(ki)
                scenario.rt(n).wpt(k) = [];
            end
        end
    end
end
if ~isempty(avddata)
    try
        avd = 1;
        scenario.avd.data = [str2double(avddata(:,1:2))*180 str2double(avddata(:,3))];
        for n = 1:size(avddata,1)
            scenario.avd.code{n} = '';
        end
    catch
        avd = 0;
        scenario.avd = [];
        beep; uiwait(errordlg('Erro ao converter avoid zones.','Erro','modal'));
    end
else
    avd = 0;
    scenario.avd = [];
end
if ~isempty(thrdata1) && ~isempty(thrdata2)
    try
        thr = 1;
        scenario.thr.data = str2double(thrdata1(:,1:2))*180;
        codes = str2double(thrdata1(:,3));
        codelist  = str2double(thrdata2(:,1));
        labellist = thrdata2(:,2);
        datalist  = [str2double(thrdata2(:,3:4))*1000 str2double(thrdata2(:,5:6))];
        for n = 1:length(codes)
            k = find(codes(n)==codelist);
            scenario.thr.data(n,3:6) = datalist(k,:);
            scenario.thr.code{n} = labellist{k};
        end
    catch
        thr = 0;
        scenario.thr = [];
        beep; uiwait(errordlg('Erro ao converter threat areas.','Erro','modal'));
    end
else
    thr = 0;
    scenario.thr = [];
end
if ~isempty(cntdata)
    try
        cnt = 1;
        scenario.cnt.data = str2double(cntdata)*180;
    catch
        cnt = 0;
        scenario.cnt = [];
        beep; uiwait(errordlg('Erro ao converter linha de contato.','Erro','modal'));
    end
else
    cnt = 0;
    scenario.cnt = [];
end

if ~(aid || wpt || rt || fa || avd || thr || cnt)
    scenario = [];
end

% ---------------------------------------------------------
function data = getxmldata(D,blockname,datalist)

% Event blocks
Bi = strfind(D,['<'  blockname '>']);
Bf = strfind(D,['</' blockname '>']);

if     length(Bi) > length(Bf)
    Bi = Bi(1:length(Bf));
elseif length(Bi) < length(Bf)
    Bf = Bf(1:length(Bi));
end

if ~isempty(Bi) && all(Bf-Bi > 0)
    
    Nd = length(datalist);  % Number of data types
    Nb = length(Bi);        % Number of blocks
    
    data = cell(Nb,Nd);
    
    for nb = 1:length(Bi)
        
        % Event block
        B = D(Bi(nb):Bf(nb));
        
        % Data acquisition
        for nd = 1:Nd
            ni = strfind(B,['<'  datalist{nd} '>']);
            nf = strfind(B,['</' datalist{nd} '>']);
            
            if ~isempty(ni+nf)
                d = B( ni+length(datalist{nd})+2 : nf-1 );
            else
                d = '';
            end
            data{nb,nd} = fliplr(deblank(fliplr(deblank(d))));
        end
    end
    
else
    data = {};
end