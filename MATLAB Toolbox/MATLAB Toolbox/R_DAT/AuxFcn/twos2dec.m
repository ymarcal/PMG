function dec = twos2dec(x,nb)
%  twos2dec(data,nbits)
%  Converts 2's complement binary notation to decimal

if nargin == 1
    nb = size(x,2);
else
    nb = max(nb,size(x,2));
end

x = bin2dec(x);
dec = zeros(length(x),1);

for i = 1:length(x),
    if bitget(x(i),nb) == 1,
        dec(i) = (bitxor(x(i),2^nb-1)+1)*-1;
    else
        dec(i) = x(i);
    end
end
