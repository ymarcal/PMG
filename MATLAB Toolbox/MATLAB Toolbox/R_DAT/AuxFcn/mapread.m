function [vmappos,vmapcod] = mapread(ktype,fname)
% Le um vectormap definido por vetores x-y separados por NaN
% Formatos: .kml (Google Earth), .xls (Excel) e .txt
% Sintaxe: [pos,cod] = mapread(ktype,fname)

if ~nargin
    opt = inputvalue('Opção','Tipo de mapa:',{'Ponto','Linha','Área','Texto'});
    if isempty(opt)
        return
    end
    switch opt
        case 1
            ktype = 'point';
        case 2
            ktype = 'line';
        case 3
            ktype = 'area';
        case 4
            ktype = 'text';
    end
end
if nargin < 2
    [fname,fpath] = uigetfile({...
            '*.kml',       'Arquivo Google Earth (*.kml)';...
            '*.xls',       'Planilha MS Excel (*.xls)';...
            '*.txt;*.dat', 'Arquivo de texto (*.txt, *.dat)'},...
        'Importar arquivo de mapas vetoriais'); drawnow;
    if ~ischar(fname)
        return
    else
        fname = [fpath fname];
    end
end

ext = lower(fname(end-2:end));

vmappos = [];
vmapcod = {};

switch ktype
    
    case 'point'
        
        switch ext
            
            case 'kml'
                data = xmldataread(fname, {{'Placemark','SimpleData name="F_CODE"','coordinates'}},{{'','Code','Coordinates'}});
                if isempty(data)
                    return
                end
                
                k = 1;
                for n = strmatch('Code:',data)'
                    
                    if strcmpi(data{n+1}(1:11),'Coordinates')
                        
                        cod = data{n}(7:end);
                        
                        temp = str2num(strrep(data{n+1}(13:end),' ',';'));
                        coord(1) = mean(temp(:,2));
                        coord(2) = mean(temp(:,1));
                        pos = coord;
                        
                        vmappos(k,:) = pos;
                        vmapcod{k}   = cod;
                        k = k+1;
                    end
                    
                end
                
            case {'xls','txt','dat'}
                
                if strcmp(ext,'xls')
                    [data, txt] = xlsread(fname);
                else
                    [data, txt] = txtread(fname);
                end
                
                if isempty(data)
                    return
                end
                
                if     size(data,1) < size(txt,1)
                    txt(1:size(txt,1)-size(data,1),:) = [];
                elseif size(data,1) > size(txt,1)
                    txt = cell(size(data,1),1);
                end
                
                nnan = isnan(data(:,1)) | isnan(data(:,2));
                data(nnan,:) = [];
                txt(nnan,:)  = [];
                for n = 1:size(txt,1)
                    for m = 1:size(txt,2)
                        if isempty(deblank(txt{n,m}))
                            txt{n,m} = '';
                        end
                    end
                end
                vmappos = data(:,1:2);
                for n = 1:size(txt,1)
                    vmapcod{n} = '';
                    for m = 1:size(txt,2)
                        vmapcod{n} = [vmapcod{n} txt{n,m}];
                    end
                end
                
        end
        
    case 'line'
        
        switch ext
            
            case 'kml'
                data = xmldataread(fname, {{'Placemark','SimpleData name="F_CODE"','coordinates'}},{{'','Code','Coordinates'}});
                if isempty(data)
                    return
                end
                
                for n = strmatch('Code:',data)'
                    
                    if strcmpi(data{n+1}(1:11),'Coordinates')
                        
                        cod = data{n}(7:end);
                        
                        temp = str2num(strrep(data{n+1}(13:end),' ',';'));
                        coord = fliplr(temp(:,1:2));
                        pos = coord;
                        
                        if isempty(vmappos)
                            vmappos = pos;
                        else
                            vmappos = [vmappos; NaN NaN; pos];
                        end
                        
                    end
                    
                end
                
            case {'xls','txt','dat'}
                
                if strcmp(ext,'xls')
                    data = xlsread(fname);
                else
                    data = txtread(fname);
                end
                
                if isempty(data) && ( strcmp(ext,'txt') || strcmp(ext,'dat') )
                    fid = fopen(fname);
                    str = char(fread(fid)');
                    fclose(fid);
                    data = latlongreadlist(str);
                end
                
                if isempty(data)
                    return
                end
                
                nnan = isnan(data(:,1)) | isnan(data(:,2));
                data(nnan,:) = NaN;
                
                exc = isnan(data(:,1));
                exc = exc & [exc(2:end); 0];
                data(exc,:) = [];
                
                vmappos = data(:,1:2);
                
        end
        
    case 'area'
        
        switch ext
            
            case 'kml'
                data = xmldataread(fname, {{'Placemark','SimpleData name="F_CODE"','outerBoundaryIs><LinearRing><coordinates','innerBoundaryIs><LinearRing><coordinates'}},{{'','Code','Outer','Inner'}});
                if isempty(data)
                    return
                end
                
                % Alternativa à funçao strmatch('Code:',data)', que esta dando 'OUT-OF-MEMORY'
                k = [];
                for n = 1:length(data)
                    if length(data{n})>=5 && strcmp(data{n}(1:5),'Code:')
                        k = [k n];
                    end
                end
                
                for n = k
                    
                    if strcmpi(data{n+1}(1:5),'Outer')
                        
                        cod = data{n}(7:end);
                        
                        temp = str2num(strrep(data{n+1}(7:end),' ',';'));
                        coord = fliplr(temp(:,1:2));
                        pos = coord;
                        
                        nxt = n + 2;
                        while nxt<=length(data) && strcmpi(data{nxt}(1:5),'Inner')
                            temp = str2num(strrep(data{nxt}(7:end),' ',';'));
                            if ~isempty(temp)
                                coord = fliplr(temp(:,1:2));
                                inner = coord;
                                
                                [posx posy] = polycut([pos(:,1); NaN; inner(:,1)],[pos(:,2); NaN; inner(:,2)]);
                                pos = [posx posy];
                            end
                            nxt = nxt + 1;
                        end
                        
                        if isempty(vmappos)
                            vmappos = pos;
                        else
                            vmappos = [vmappos; NaN NaN; pos];
                        end
                        
                    end
                    
                end
                
            case {'xls','txt','dat'}
                
                if strcmp(ext,'xls')
                    data = xlsread(fname);
                else
                    data = txtread(fname);
                end

                if isempty(data) && ( strcmp(ext,'txt') || strcmp(ext,'dat') )
                    fid = fopen(fname);
                    str = char(fread(fid)');
                    fclose(fid);
                    data = latlongreadlist(str);
                end
                
                if isempty(data)
                    return
                end
                
                nnan = isnan(data(:,1)) | isnan(data(:,2));
                data(nnan,:) = NaN;
                
                exc = isnan(data(:,1));
                exc = exc & [exc(2:end); 0];
                data(exc,:) = [];
                
                vmappos = data(:,1:2);
                
        end
        
    case 'text'
        
        switch ext
            
            case 'kml'
                data = xmldataread(fname, {{'Placemark','SimpleData name="F_CODE"','coordinates'}},{{'','Code','Coordinates'}});
                if isempty(data)
                    return
                end
                
                k = 1;
                for n = strmatch('Code:',data)'
                    
                    if strcmpi(data{n+1}(1:11),'Coordinates')
                        
                        cod = data{n}(7:end);
                        
                        temp = str2num(strrep(data{n+1}(13:end),' ',';'));
                        coord(1) = mean(temp(:,2));
                        coord(2) = mean(temp(:,1));
                        pos = coord;
                        
                        vmappos(k,:) = [pos zeros(size(pos,1),2)];
                        vmapcod{k}   = cod;
                        k = k+1;
                    end
                    
                end
                
            case {'xls','txt','dat'}
                
                if strcmp(ext,'xls')
                    [data, txt] = xlsread(fname);
                else
                    [data, txt] = txtread(fname);
                end
                
                if isempty(data)
                    return
                end
                
                if     size(data,1) < size(txt,1)
                    txt(1:size(txt,1)-size(data,1),:) = [];
                elseif size(data,1) > size(txt,1)
                    txt = cell(size(data,1),1);
                end
                
                nnan = isnan(data(:,1)) | isnan(data(:,2));
                data(nnan,:) = [];
                txt(nnan,:)  = [];
                if size(data,2) == 2
                    data = [data zeros(size(data,1),1)];
                elseif size(data,2) == 3
                    data = [data zeros(size(data,1),2)];
                end
                data(isnan(data(:,4)),4) = 0;
                for n = 1:size(txt,1)
                    for m = 1:size(txt,2)
                        if isempty(deblank(txt{n,m}))
                            txt{n,m} = '';
                        end
                    end
                end
                vmappos = data(:,1:4);
                for n = 1:size(txt,1)
                    vmapcod{n} = '';
                    for m = 1:size(txt,2)
                        vmapcod{n} = [vmapcod{n} txt{n,m}];
                    end
                end
                
        end
        
end

% Excluir pontos repetidos
if strcmp(ktype,'line') || strcmp(ktype,'area')
    exc = diff(vmappos(:,1)) == 0 & diff(vmappos(:,2)) == 0;
    vmappos(exc,:) = [];
end

% Eliminar pontos colineares (~1/2 centesimo de grau)
if strcmp(ktype,'line') || strcmp(ktype,'area')
    exc = logical([0; abs(diff(angle(diff(vmappos(:,1))+1i*diff(vmappos(:,2))))) < 1e-4; 0]);
    vmappos(exc,:) = [];
end