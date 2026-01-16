function [typelist, convlist] = getconvlist
% Lista de unidades para conversoes 
%    typelist: cell string com os grupos de unidades
%    convlist: cell array com nome das unidades e coeficientes de conversao para unidade padrao
%    Equacionamento: Y = k*X + b

typelist = {'Distância','Velocidade','Aceleração','Peso','Massa','Ângulo','Temperatura','Pressão','Volume','Tempo','Variação temporal','Frequência','Torque','Potência','Densidade'};

convlist{1} = {
    'm',  1,        0;
    'in', 0.0254,   0;
    'ft', 0.3048,   0;
    'mi', 1609.344, 0;
    'yd', 0.9144,   0;
    'NM', 1852,     0;
    'cm', 0.01,     0;
    'km', 1000,     0 };

convlist{2} = {
    'm/s',    1,             0;
    'ft/s',   0.3048,        0;
    'ft/min', 0.3048/60,     0;
    'mi/h',   1609.344/3600, 0;
    'kt',     1852/3600,     0;
    'km/h',   1/3.6,         0 };

convlist{3} = {
    'm/s²',  1,         0;
    'ft/s²', 0.3048,    0;
    'kt/s',  1852/3600, 0;
    'g',     9.80665    0 };

convlist{4} = {
    'kgf', 1,            0;
    'lb',  1/2.204623,   0;
    'N',   1/9.80665,    0;
    'kN',  1000/9.80665, 0 };

convlist{5} = {
    'kg',   1,                      0;
    'lbm',  1/2.204623,             0;
    'slug', 9.80665/.3048/2.204623, 0 };

convlist{6} = {
    '°',         1,            0;
    'rad',       180/pi,       0;
    'mr',        .001*180/pi,  0;
    'SemiCircl', 180,          0 };

convlist{7} = {
    '°C', 1,    0;
    '°F', 5/9, -32*5/9;
    'K',  1,   -273.15 };

convlist{8} = {
    'Pa',   1,           0;
    'atm',  101325,      0;
    'bar',  100000,      0;
    'mb',   100,         0;
    'psi',  9.80665/2.204623/0.0254^2, 0;
    'inHg', 3386.388158, 0;
    'mmHg', 133.3223684, 0 };

convlist{9} = {
    'L',   1,           0;
    'ml',  0.001,       0;
    'm³',  1000,        0;
    'cm³', 0.001,       0;
    'in³', 0.254^3,     0;
    'USG', 3.785411784, 0 };

convlist{10} = {
    's',   1,     0;
    'min', 60,    0;
    'h',   3600,  0;
    'd',   86400, 0 };

convlist{11} = {
    '/s',   1,       0;
    '/min', 1/60,    0;
    '/h',   1/3600,  0;
    '/d',   1/86400, 0 };

convlist{12} = {
    'Hz',    1,        0;
    'rad/s', 1/(2*pi), 0;
    'RPM',   1/60,     0};

convlist{13} = {
    'N.m',   1,        0;
    'kgf.m', 9.80665,  0;
    'lb.ft', 9.80665/2.204623*0.3048, 0;
    'lb.in', 9.80665/2.204623*0.0254, 0 };

convlist{14} = {
    'W',     1,           0;
    'HP',    745.6998716, 0;
    'cal/s', 4.183076342, 0 };

convlist{15} = {
    'kg/m³',  1,     0;
    'kg/L',   0.001, 0;
    'lb/in³', 1/2.204623/0.0254^3, 0;
    'lb/ft³', 1/2.204623/0.3048^3, 0;
    'lb/USG', 1000/2.204623/3.785411784, 0 };