function str = num2str2(num)
% num2str com alinhamento à esquerda

str = cellstr(num2str(num));
for n = 1:length(str)
    str{n} = fliplr(deblank(fliplr(str{n})));
end
str = char(str);
