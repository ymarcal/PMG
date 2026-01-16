function twos = dec2twos(dec, nb) 
% Converts a decimal integer to two's complement binary representation

dec = round(dec);

if nargin == 1
    nb1 = 2;
else
    nb1 = max(2,nb);
end

nb = max(nb1,max(ceil(log2(max(0,max(abs(dec)))+1)+1)));

if min(dec) < 0 && -min(dec) > max(dec) && rem(log2(-min(dec)),1) == 0
    nb = max(nb1,nb-1);
end
    
twos = dec2bin(mod((dec),2^nb),nb);
