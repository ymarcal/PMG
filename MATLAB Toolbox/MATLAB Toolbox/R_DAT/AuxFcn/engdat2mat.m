function [DADOS, PARAM, UNITS] = engdat2mat(fname, PARAM, UNITS)
% Function to import F-5M ENG_DAT or ENG_FAT files

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

% Data blocks
Bi = strfind(D,'<ENG_REC>');
Bf = strfind(D,'</ENG_REC>');

if nargin == 3
    PARAM = cellstr(PARAM);
    UNITS = cellstr(UNITS);
    
elseif nargin == 2
    PARAM = cellstr(PARAM);
    UNITS = cell(size(PARAM));
    for n = 1:length(PARAM)
        UNITS{n} = ' ';
    end
    
elseif nargin == 1
    
    if ~isempty(strfind(char(D(1:200)),'ENG_DAT'))
        
        PARAM = {
            'UTC'
            'RPM_L'
            'RPM_R'
            'EGT_L'
            'EGT_R'
            'NOZ_L'
            'NOZ_R'
            'OILP_L'
            'OILP_R'
            'Total_Fuel'
            'INT_Fuel'
            'EXT_INB_Fuel'
            'EXT_CNTRL_Fuel'
            'Fuel_Flow_L'
            'Fuel_Flow_R'
            'UTIL_Press'
            'Flight_Press'
        };
        
        UNITS = {
            'sec'
            '%'
            '%'
            '°C'
            '°C'
            '%'
            '%'
            'PSI'
            'PSI'
            'lb'
            'lb'
            'lb'
            'lb'
            'lb/h'
            'lb/h'
            'PSI'
            'PSI'
        };
        
    elseif ~isempty(strfind(char(D(1:200)),'ENG_FAT'))
        
        PARAM = {
            'UTC'
            'RPM_L'
            'RPM_R'
            'EGT_L'
            'EGT_R'
            'NOZ_L'
            'NOZ_R'
            'OILP_L'
            'OILP_R'
            'Total_Fuel'
            'INT_Fuel'
            'EXT_INB_Fuel'
            'EXT_CNTRL_Fuel'
            'Fuel_Flow_L'
            'Fuel_Flow_R'
            'UTIL_Press'
            'Flight_Press'
            'OAT'
            'ALT'
            'MACH'
            'AOA'
            'CAS'
            'TAS'
            'Flaps'
            'Pitch_Rate'
            'Roll_Rate'
            'Yaw_Rate'
            'N_Accel'
            'L_Accel'
            'Weight'
        };
        
        UNITS = {
            'sec'
            '%'
            '%'
            '°C'
            '°C'
            '%'
            '%'
            'PSI'
            'PSI'
            'lb'
            'lb'
            'lb'
            'lb'
            'lb/h'
            'lb/h'
            'PSI'
            'PSI'
            '°C'
            'ft'
            ''
            'units'
            'kt'
            'kt'
            ''
            '°/s'
            '°/s'
            '°/s'
            'g'
            'g'
            'kg'
        };
        
        % Data blocks
        Bi = strfind(D,'<ENG_R>');
        Bf = strfind(D,'</ENG_R>');
        
    else
        DADOS = [];
        PARAM = '';
        UNITS = '';
        return
    end
end

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
            val = sscanf( B( ni+length(PARAM{np})+2 : nf-1 ), '%f');
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