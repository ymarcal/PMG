function fname = kmlwrite(data,fname,docname)
% Funçao para exportaçao de uma matriz de dados de coordenadas
% geograficas para o formato ".kml" (Google Earth)
% Formato da matriz:   [Lon Lat Alt]
% Unidades:            [º   º   m  ]
% Pode ser utilizada uma estrutura de dados para detalhar a apresentaçao

% Numero de parametros de entrada
if nargin == 1
    fname = '';
    docname = 'Novo documento';
elseif nargin == 2
    docname = 'Novo documento';
elseif nargin ~= 3
    fname = '';
    beep; errordlg('Número de dados de entrada incorreto.','Erro','modal');
    return
end

% Entrada numerica
if isnumeric(data)
    data.data   = data;
    data.type   = 'line';
    data.folder = 'Nova pasta';
    data.name   = 'Novo objeto';
    data.descr  = '';
    data.color  = 'FFFFFF';
    data.width  = 1.5;
end

N = length(data);

% Verificaçao da estrutura de entrada
if ~isfield(data,'data')
    beep; errordlg('Dados de entrada vazios.','Erro','modal');
    return
end
if ~isfield(data,'type')
    for n = 1:N
        data(n).type = 'line';
    end
end
if ~isfield(data,'folder')
    for n = 1:N
        data(n).folder = 'Pasta';
    end
end
if ~isfield(data,'name')
    for n = 1:N
        data(n).name = 'Trajetória';
    end
end
if ~isfield(data,'descr')
    for n = 1:N
        data(n).descr = 'Descrição';
    end
end
if ~isfield(data,'color')
    for n = 1:N
        data(n).color = 'FFFFFF';
    end
else
    for n = 1:N
        data(n).color = rgb2hex(data(n).color);
    end
end
if ~isfield(data,'width')
    for n = 1:N
        data(n).width = 1.5;
    end
end

% Validaçao dos dados
for n = 1:N
    switch size(data(n).data,2)
        case 1
            beep; errordlg('Dados de entrada incoerentes.','Erro','modal');
            return
        case 2
            data(n).data(:,3) = 0*data(n).data(:,1);
            data(n).altmode = 'clampToGround';
        otherwise
            data(n).data = data(n).data(:,1:3);
            if any(data(n).data(:,3))
                data(n).altmode = 'absolute';
            else
                data(n).altmode = 'clampToGround';
            end
    end
    data(n).data = data(n).data(:,[2 1 3]); % Lat Lon Alt -> Lon Lat Alt
    
    switch data(n).type
        case 'point'
            if ischar(data(n).descr)
                descr = data(n).descr;
                for m = 1:size(data(n).data,1)
                    data(n).descr{m} = descr;
                end
            end
        case 'area'
            if data(n).data(end,1) ~= data(n).data(1,1) || data(n).data(end,2) ~= data(n).data(1,2)
                data(n).data(end+1,:) = data(n).data(1,:);
            end
    end
end

% Eliminaçao de "NaN" contiguos e no inicio e final dos dados
for n = N:-1:1
    
    exc = isnan(sum(data(n).data,2));
    exc = exc & [exc(2:end); 0];
    data(n).data(exc,:) = [];
    
    if ~isempty(data(n).data) && isnan(sum(data(n).data(1,:)))
        data(n).data(1,:) = [];
    end
    if ~isempty(data(n).data) && isnan(sum(data(n).data(end,:)))
        data(n).data(end,:) = [];
    end
    if isempty(data(n).data)
        data(n) = [];
    end
end
N = length(data);

if isempty(data)
    beep; errordlg('Dados de entrada inválidos.','Erro','modal');
    return
end

% Divisao das linhas separadas por "NaN"
for n = N:-1:1
    nnan = find(isnan(sum(data(n).data,2)));
    k = 1;
    while ~isempty(nnan)
        data = cat(2,data(1:n),data(n),data(n+1:end));
        data(n).data   = data(n).data(1:nnan(end)-1,:);
        data(n+1).data = data(n+1).data(nnan(end)+1:end,:);
        nnan = find(isnan(sum(data(n).data,2)));
        k = k+1;
    end
    if k > 1
        for m = n+1:n+k-1
            data(m).name = [data(m).name ' (' num2str(m-n+1) ')'];
        end
    end
end
N = length(data);

% Ordenar por pastas
[void, ord] = sort({data.folder});
data = data(ord);

% Abertura e fechamento das pastas
openfolder = 1;
if N > 1
    for n = 2:N
        if strcmp(data(n).folder,data(n-1).folder)
            openfolder(n) = 0;
            closefolder(n) = 0;
        else
            openfolder(n) = 1;
            closefolder(n-1) = 1;
        end
    end
end
closefolder(N) = 1;

% Abertura do arquivo
L = {...
        '<?xml version="1.0" encoding="UTF-8"?>';...
        '<kml xmlns="http://www.opengis.net/kml/2.2">';...
        '<Document>';...
        ['<name>' docname '</name>'];...
        '<open>1</open>'};

for n = 1:N
    
    % Abertura de nova pasta
    if openfolder(n)
        FOLDERopen = {...
                '  <Folder>';...
                ['    <name>' data(n).folder '</name>']};
        L = [L; FOLDERopen];
    end
    
    % Definiçao dos estilos
    switch data(n).type
        
        case 'point'
            STYLE = {
                ['    <Style id="ptstyle_' num2str(n) '">'];
                '      <IconStyle>';
                ['        <color>FF' data(n).color '</color>'];
                '        <scale>0.6</scale>';
                '        <Icon>';
                ['          <href>' strrep(which('wpt.png'),'\','/') '</href>'];
                '        </Icon>';
                '      </IconStyle>';
                '    </Style>'};
            
        case 'line'
            STYLE = {
                ['    <Style id="linestyle_' num2str(n) '">'];
                '      <LineStyle>';
                ['        <color>FF' data(n).color '</color>'];
                ['        <width>' num2str(data(n).width) '</width>'];
                '      </LineStyle>';
                '    </Style>'};
            
        case 'area'
            STYLE = {
                ['    <Style id="areastyle_' num2str(n) '">'];
                '      <LineStyle>';
                ['        <color>FF' data(n).color '</color>'];
                '        <width>2</width>';
                '      </LineStyle>';
                '      <PolyStyle>';
                ['        <color>80' data(n).color '</color>'];
                '      </PolyStyle>';
                '    </Style>'};
    end
    L = [L; STYLE];
    
    % Definiçao dos Placemarks
    switch data(n).type
        
        case 'point'
            PLACE = {};
            for m = 1:size(data(n).data,1)
                PLACEn = {
                    '    <Placemark>';
                    ['      <styleUrl>#ptstyle_' num2str(n) '</styleUrl>'];
                    ['      <name>' data(n).name{m} '</name>'];
                    ['      <description>' data(n).descr{m} '</description>'];
                    '      <Point>';
                    '        <extrude>0</extrude>';
                    ['        <altitudeMode>' data(n).altmode '</altitudeMode>'];
                    '        <coordinates>';
                    ['          ' sprintf('%f,%f,%f ',data(n).data(m,:)')];
                    '        </coordinates>';
                    '      </Point>';
                    '    </Placemark>'};
                PLACE = [PLACE; PLACEn];    
            end
            
        case 'line'
            PLACE = {
                '    <Placemark>';
                ['      <name>' data(n).name '</name>'];
                ['      <description>' data(n).descr '</description>'];
                ['      <styleUrl>#linestyle_' num2str(n) '</styleUrl>'];
                '      <LineString>';
                '        <extrude>0</extrude>';
                '        <tessellate>1</tessellate>';
                ['        <altitudeMode>' data(n).altmode '</altitudeMode>'];
                '        <coordinates>';
                ['          ' sprintf('%f,%f,%f ',data(n).data')];
                '        </coordinates>';
                '      </LineString>';
                '    </Placemark>'};
            
        case 'area'
            PLACE = {
                '    <Placemark>';
                ['      <name>' data(n).name '</name>'];
                ['      <description>' data(n).descr '</description>'];
                ['      <styleUrl>#areastyle_' num2str(n) '</styleUrl>'];
                '      <Polygon>';
                '        <extrude>0</extrude>';
                '        <tessellate>1</tessellate>';
                ['        <altitudeMode>' data(n).altmode '</altitudeMode>'];
                '        <outerBoundaryIs>';
                '          <LinearRing>';
                '            <coordinates>';
                ['              ' sprintf('%f,%f,%f ',data(n).data')];
                '            </coordinates>';
                '          </LinearRing>';
                '        </outerBoundaryIs>';
                '      </Polygon>';
                '    </Placemark>'};
    end
    L = [L; PLACE];

    % Fechamento da pasta
    if closefolder(n)
        FOLDERclose = {'  </Folder>'};
        L = [L; FOLDERclose];
    end
    
end

% Fechamento do arquivo
DOCclose = {...
        '</Document>';...
        '</kml>' };
L = [L; DOCclose];

% Gravaçao do arquivo .kml
if isempty(fname)
    [fname,fpath] = uiputfile({'*.kml','Arquivo Google Earth (*.kml)'},'Salvar arquivo do Google Earth');
    if ~ischar(fname)
        return
    end
    fname = [fpath fname];
end

strwrite(fname,L,0);

% -------------------------------------------------
function hex = rgb2hex(c)
% Converte uma cor RGB ou caractere de cor em um string hexadecimal BGR (blue, green, red)

if ischar(c) && length(c) == 1
    rgb = char2rgb(c);
    
elseif ischar(c) && length(c) == 8
    hex = c;
    try
        hex2dec(hex);
    catch
        hex = 'FFFFFF';
    end
    return
    
else
    rgb = c;
    
end

if length(rgb) ~= 3
    hex = 'FFFFFF';
    
else    
    rgb = round(rgb*255);
    hex = [dec2hex(rgb(3),2)  dec2hex(rgb(2),2)  dec2hex(rgb(1),2) ];
end

% --------------------------------------------------------------------
function rgb = char2rgb(c)
% Converte um caracter de cor em um trio RGB

if isnumeric(c)
    rgb = c;
    return
end

if length(c) == 1
    
    switch c
        case 'b'
            rgb = [0 0 1];
        case 'g'
            rgb = [0 1 0];
        case 'r'
            rgb = [1 0 0];
        case 'c'
            rgb = [0 1 1];
        case 'm'
            rgb = [1 0 1];
        case 'y'
            rgb = [1 1 0];
        case 'w'
            rgb = [1 1 1];
        otherwise
            rgb = [1 1 1];
    end
    
else
    rgb = str2num(c); %#ok<ST2NM>
end