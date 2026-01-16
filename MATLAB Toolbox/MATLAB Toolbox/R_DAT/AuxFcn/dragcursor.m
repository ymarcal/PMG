function [M, p] = dragcursor(opt)
% Fornece icone de "mão" para uso de cursor de arrastamento
% opt = 0: mao aberta (default)
% opt = 1: mao fechada

if nargin == 0
    opt = 0;
end

if opt
    
    M = [
        NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN
        NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN
        NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN
        NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN
        NaN	NaN	NaN	NaN	NaN	NaN	1	NaN	1	NaN	1	NaN	NaN	NaN	NaN	NaN
        NaN	NaN	NaN	NaN	NaN	1	2	1	2	1	2	1	1	NaN	NaN	NaN
        NaN	NaN	NaN	NaN	NaN	1	2	1	2	1	2	1	2	1	NaN	NaN
        NaN	NaN	NaN	NaN	1	1	2	1	2	1	2	1	2	1	NaN	NaN
        NaN	NaN	NaN	1	2	1	2	2	2	2	2	2	2	1	NaN	NaN
        NaN	NaN	NaN	1	2	2	2	2	2	2	2	2	2	1	NaN	NaN
        NaN	NaN	NaN	1	2	2	2	2	2	2	2	2	2	1	NaN	NaN
        NaN	NaN	NaN	NaN	1	2	2	2	2	2	2	2	1	NaN	NaN	NaN
        NaN	NaN	NaN	NaN	NaN	1	2	2	2	2	2	2	1	NaN	NaN	NaN
        NaN	NaN	NaN	NaN	NaN	1	2	2	2	2	2	1	NaN	NaN	NaN	NaN
        NaN	NaN	NaN	NaN	NaN	1	2	2	2	2	2	1	NaN	NaN	NaN	NaN
        NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN
    ];
    
else
    
    M = [
        NaN	NaN	NaN	NaN	NaN	NaN	NaN	1	1	NaN	NaN	NaN	NaN	NaN	NaN	NaN
        NaN	NaN	NaN	NaN	NaN	NaN	1	1	2	1	1	NaN	NaN	NaN	NaN	NaN
        NaN	NaN	NaN	NaN	NaN	1	2	1	2	1	2	1	NaN	NaN	NaN	NaN
        NaN	NaN	NaN	NaN	NaN	1	2	1	2	1	2	1	1	NaN	NaN	NaN
        NaN	NaN	NaN	NaN	NaN	1	2	1	2	1	2	1	2	1	NaN	NaN
        NaN	NaN	NaN	NaN	NaN	1	2	1	2	1	2	1	2	1	NaN	NaN
        NaN	NaN	1	1	NaN	1	2	1	2	1	2	1	2	1	NaN	NaN
        NaN	NaN	1	2	1	1	2	1	2	1	2	1	2	1	NaN	NaN
        NaN	NaN	1	2	2	1	2	2	2	2	2	2	2	1	NaN	NaN
        NaN	NaN	NaN	1	2	2	2	2	2	2	2	2	2	1	NaN	NaN
        NaN	NaN	NaN	1	2	2	2	2	2	2	2	2	2	1	NaN	NaN
        NaN	NaN	NaN	NaN	1	2	2	2	2	2	2	2	1	NaN	NaN	NaN
        NaN	NaN	NaN	NaN	NaN	1	2	2	2	2	2	2	1	NaN	NaN	NaN
        NaN	NaN	NaN	NaN	NaN	1	2	2	2	2	2	1	NaN	NaN	NaN	NaN
        NaN	NaN	NaN	NaN	NaN	1	2	2	2	2	2	1	NaN	NaN	NaN	NaN
        NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN
    ];
    
end

p = [8 7];