function var_out = backcompat(var_in, opt)
% Compatibilidade com versoes anteriores

if isempty(var_in);
    var_out = var_in;
    return
end

switch opt
    
    case 'testpts' % -------------------------------------------------------------------------
        
        testpts = var_in;
        
        if isfield(testpts,'minvalid')
            testpts = rmfield(testpts,'minvalid');
        end
        for n = 1:size(testpts,2)
            if size(testpts(n).data,2) == 11
                testpts(n).data = [testpts(n).data(:,1:9) zeros(size(testpts(n).data,1),1) testpts(n).data(:,10:11) zeros(size(testpts(n).data,1),1)];
            end
            if size(testpts(n).data,2) == 12
                testpts(n).data = [testpts(n).data zeros(size(testpts(n).data,1),1)];
            end
            if size(testpts(n).fit,2) == 7
                testpts(n).fit = [testpts(n).fit(:,1:6) zeros(size(testpts(n).fit,1),1) testpts(n).fit(:,7)];
            end
        end
        if size(testpts,2) == 1 && ~isfield(testpts,'group')
            if size(testpts.time,1) >= size(testpts.time,2)
                testpts.time = testpts.time';
            end
            testpts.group = '1';
        end
        if ~isfield(testpts,'visible')
            for n = 1:size(testpts,2)
                testpts(n).visible = 1;
            end
        end
        
        var_out = testpts;
        
        
    case 'setup' % -------------------------------------------------------------------------
        
        setup = var_in;
        
        % Inserçao do "cage"
        if isfield(setup,'paramlist') && length(setup.paramlist) == 33
            setup.paramlist = [setup.paramlist(1:30), {''}, setup.paramlist(31:33)];
        end
        % Inserçao do data-link
        if ~isempty(setup) && ~isfield(setup,'others') && ~isfield(setup,'params')
            setup.others = {'','','','','','','',''};
        end
        % Inserçao da DLZ
        if isfield(setup,'paramlist') && length(setup.paramlist) == 34
            setup.paramlist = [setup.paramlist, {'','',''}];
        end
        % Mudança de lista para estrutura
        if isfield(setup,'paramlist')
            params = {'time','Zp','Vc','M','Zagl','lat','lon','Nz','psi','tet','phi','aoa','aos','rpm1','egt1','ff1','fuel1','rpm2',...
                    'egt2','ff2','Raz','Rel','Rrng','Rclo','Rzp','Rvc','Rpsi','Rasp','Maz','Mel','trk','Paz','Pel','wrb',...
                    'Rmax1','Rmax2','Rmin'};
            for n = 1:length(params)
                setup.params.(params{n}) = setup.paramlist{n};
            end
            setup = rmfield(setup,'paramlist');
        end
        % Tipo de aeronave
        if ~isempty(setup) && ~isfield(setup,'acft')
            setup.acft = 'F-5';
        end
        % Campo de visao do HUD
        if ~isempty(setup) && ~isfield(setup,'fov')
            setup.fov = 10;
        end
        % Incorporaçao de 'others' aos campos nomeados
        if isfield(setup,'others')
            params = {'lat2','lon2','alt2','psi2','lat3','lon3','alt3','psi3'};
            for n = 1:length(params)
                setup.params.(params{n}) = setup.others{n};
            end
            setup = rmfield(setup,'others');
        end
        
        var_out = setup;
        
        
    case 'scenario' % -------------------------------------------------------------------------
        
        scenario = var_in;
        
        if ~isstruct(scenario)
            var_out = [];
            return
        end
        
        if isfield(scenario,'date') % New structure
            var_out = scenario;
            return
        else % Old structure
            d = clock;
            scenario2.date = [num2str(d(3),'%02.0f') '/' num2str(d(2),'%02.0f') '/' num2str(d(1))];
        end
        
        if isfield(scenario,'Dmag')
            scenario2.Dmag = scenario.Dmag;
        else
            scenario2.Dmag = 0;
        end

        scenario2.map = [];
        scenario2.aux = [];
        scenario2.wpt = [];
        scenario2.fa  = [];
        scenario2.rt  = [];
        scenario2.avd = [];
        scenario2.thr = [];
        scenario2.cnt = [];
        
        if isfield(scenario,'mapname')
            for n = 1:length(scenario.mapname)
                scenario2.map(n).name = scenario.mapname{n};
                scenario2.map(n).data = scenario.mappos{n};
            end
        end
        
        if isfield(scenario,'auxcod')
            for n = 1:length(scenario.auxcod)
                [ktype, style, color, width] = splitstyle(scenario.auxstl{n});
                scenario2.aux(n).name  = scenario.auxname{n};
                scenario2.aux(n).type  = ktype;
                scenario2.aux(n).style = style;
                scenario2.aux(n).color = color;
                scenario2.aux(n).width = width;
                scenario2.aux(n).data  = scenario.auxpos{n};
                scenario2.aux(n).code  = scenario.auxcod{n}';
            end
        end
        
        if ~isfield(scenario,'aid')
            scenario2.aid = [];
        end

        if isfield(scenario,'wptcod')
            scenario2.wpt.code = scenario.wptcod';
            scenario2.wpt.data = [scenario.wptnum' scenario.wptpos];
        end
        
        if isfield(scenario,'rtwpt')
            for n = 1:length(scenario.rtwpt)
                scenario2.rt(n).wpt = scenario.rtwpt{n};
            end
        end
        
        if isfield(scenario,'facod')
            for n = 1:length(scenario.facod)
                [ktype, style, color] = splitstyle(scenario.fastl{n});
                scenario2.fa(n).descr = '';
                scenario2.fa(n).code  = scenario.facod{n};
                scenario2.fa(n).style = style;
                scenario2.fa(n).color = color;
                scenario2.fa(n).data  = scenario.fapos{n};
            end
        end
        
        if isfield(scenario,'avdcod')
            scenario2.avd.code = scenario.avdcod';
            scenario2.avd.data = scenario.avdpos;
        end
        
        if isfield(scenario,'thrcod')
            scenario2.thr.code = scenario.thrcod';
            scenario2.thr.data = scenario.thrpos;
        end
        
        if isfield(scenario,'cntpos')
            scenario2.cnt.data = scenario.cntpos;
        end
        
        if ~isempty(scenario2.aux)
            for n = 1:length(scenario2.aux)
                scenario2.aux(n).code = scenario2.aux(n).code(:);
            end
        end
        if ~isempty(scenario2.aid)
            scenario2.aid.code = scenario2.aid.code(:);
            scenario2.aid.type = scenario2.aid.type(:);
        end
        if ~isempty(scenario2.wpt)
            scenario2.wpt.code = scenario2.wpt.code(:);
        end
        if ~isempty(scenario2.avd)
            scenario2.avd.code = scenario2.avd.code(:);
        end
        if ~isempty(scenario2.thr)
            scenario2.thr.code = scenario2.thr.code(:);
        end
        
        var_out = scenario2;
        
    case 'acftdb' % -------------------------------------------------------------------------

        acftdb = var_in;
        
        if isfield(acftdb,'Dpbtype')
            for na = 1:length(acftdb)
                Dpbtype = acftdb(na).Dpbtype;
                Dpb = acftdb(na).Dpb;
                for nc = 1:length(Dpbtype)
                    for nt = 1:3
                        if nt == Dpbtype(nc)
                            acftdb(na).Dpb(nc,:,nt) = Dpb(nc,:);
                        else
                            acftdb(na).Dpb(nc,:,nt) = NaN*ones(1,6);
                        end
                    end
                end
                Dqbtype = acftdb(na).Dqbtype;
                Dqb = acftdb(na).Dqb;
                for nc = 1:length(Dqbtype)
                    for nt = 1:3
                        if nt == Dqbtype(nc)
                            acftdb(na).Dqb(nc,:,nt) = Dqb(nc,:);
                        else
                            acftdb(na).Dqb(nc,:,nt) = NaN*ones(1,6);
                        end
                    end
                end
            end
            acftdb = rmfield(acftdb,'Dpbtype');
            acftdb = rmfield(acftdb,'Dqbtype');
        end
        
        var_out = acftdb;


    otherwise
        
        var_out = var_in;
        
end


% --------------------------------------------------------------------------
function [ktype, style, color, width] = splitstyle(stylestr)
% Fornece o tipo de objeto (ponto, linha, area, texto) e
% converte um string de estilo em tres componentes (estilo, cor e espessura)
% Usado apenas até a versao 7.0 BETA 14

width = str2double(stylestr(end));
if isnan(width)
    width = 1;
else
    stylestr(end) = [];
end

ix = find(stylestr == '[');

if isempty(ix)
    style = stylestr(1:end-1);
    color = stylestr(end);
else
    style = stylestr(1:ix-1);
    color = str2num(stylestr(ix:end));
end

if any(style(1) == '.ods^p')
    ktype = 'point';
elseif style(1) == 'A'
    ktype = 'area';
elseif style(1) == 'T'
    ktype = 'text';
else
    ktype = 'line';
end
