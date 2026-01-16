function [DADOS, PARAM, UNITS] = acdat2mat(fname, PARAM, UNITS, datablock)
% Function to import F-5M / A-29 ACDAT files

try
    fid = fopen(fname);
    D = char(fread(fid)');
    fclose(fid);
catch
    DADOS = [];
    PARAM = '';
    UNITS = '';
    return
end

if nargin <= 3
   datablock = 'AC_REC';
end
    
if nargin == 3
    PARAM = cellstr(PARAM);
    UNITS = cellstr(UNITS);

elseif nargin == 2
    PARAM = cellstr(PARAM);
    UNITS = [];
    
elseif nargin == 1
    PARAM = {
        'UTC'
        'Nor_Vel'
        'East_Vel'
        'Down_Vel'
        'LAT'
        'Long'
        'Nx_Accel'
        'Ny_Accel'
        'Nz_Accel'
        'Nor_Accel'
        'Mag_Head'
        'Roll'
        'Pitch'
        'True_Head'
        'Gnd_Track'
        'Roll_Rate'
        'Pitch_Rate'
        'Yaw_Rate'
        'TAS'
        'CAS'
        'Gnd_Speed'
        'MACH'
        'True_AOA'
        'Indi_AOA'
        'Corr_Alt'
        'SYS_Alt'
        'BARO_Alt'
        'RALT_Alt'
        'Wind_Mag' 
        'Wind_Dir' 
        'MS_Mode'
        'AC_Mode'
        'FOM'
        'Fuel'
        'RDR_State'
        'RDR_Mode'
        'RDR_Lock'
        'HPT_Rng' 
        'HPT_Az' 
        'HPT_Elev' 
        'HPT_Heading' 
        'HPT_Altitude' 
        'HPT_Aspect' 
        'HPT_North_Vel' 
        'HPT_East_Vel' 
        'HPT_Down_Vel' 
        'HPT_Closure_Rate' 
        'SPT_Rng' 
        'SPT_Az' 
        'SPT_Elev' 
        'SPT_Heading' 
        'SPT_Alt' 
        'SPT_Aspect' 
        'SPT_North_Vel' 
        'SPT_East_Vel' 
        'SPT_Down_Vel' 
        'SPT_Closure_Rate' 
        'Slant_Range'};
    
    UNITS = {
        'sec'
        'kt'
        'kt'
        'kt'
        'SemiCircl'
        'SemiCircl'
        'm/s²'
        'm/s²'
        'm/s²'
        'g'
        'deg'
        'deg'
        'deg'
        'deg'
        'deg'
        'deg/sec'
        'deg/sec'
        'deg/sec'
        'kt'
        'kt'
        'kt'
        ''
        'deg'
        'deg'
        'ft'
        'ft'
        'ft'
        'ft'
        'kt'
        'deg'
        ''
        ''
        '-'
        'lb'
        ''
        ''
        ''
        'ft'
        'deg'
        'deg'
        'deg'
        'ft'
        'deg'
        'kt'
        'kt'
        'kt'
        'kt'
        'ft'
        'deg'
        'deg'
        'deg'
        'ft'
        'deg'
        'kt'
        'kt'
        'kt'
        'kt'
        'ft'};
    
end

if isempty(UNITS)
    UNITS(1:length(PARAM)) = {' '};
end

% String to Numeric conversion
D = strrep(D,'>ON' ,'> 1' ); % "ON"  -> "1"
D = strrep(D,'>OFF','> 0 '); % "OFF" -> "0"

% Data blocks
Bi = strfind(D,['<'  datablock '>']);
Bf = strfind(D,['</' datablock '>']);

if     length(Bi) > length(Bf)
    Bi = Bi(1:length(Bf));
elseif length(Bi) < length(Bf)
    Bf = Bf(1:length(Bi));
end
if any(Bf-Bi < 0)
    DADOS = [];
    PARAM = char(PARAM);
    UNITS = char(UNITS);
    return
end

Nd = length(Bi);
Np = length(PARAM);
DADOS = zeros(Nd,Np);

for nd = 1:Nd
    B = D(Bi(nd):Bf(nd));
    
    for np = 1:Np
        ni = strfind(B,['<'  PARAM{np} '>']);
        nf = strfind(B,['</' PARAM{np} '>']);
        
        if ~isempty(ni+nf)
            
            str = B( ni+length(PARAM{np})+2 : nf-1 );
            
            if any(str==':')
                val = str2time(str);
            else
                val = sscanf( str, '%f');
            end
            
            if isempty(val)
                DADOS(nd,np) = nan;
            else
                DADOS(nd,np) = val;
            end
        else
            DADOS(nd,np) = nan;
        end
        
    end
end

if strcmp(PARAM{1},'UTC')
    DADOS(:,1) = DADOS(:,1)/1000;
end
PARAM = char(PARAM);
UNITS = char(UNITS);