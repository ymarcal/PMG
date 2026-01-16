function var = name2var(name)
% Funcao para transformar o nome de um parametro em nome de variavel

validchars   = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_';
replacechars = 'áàâãéêíóôõúçÁÀÂÃÉÊÍÓÔÕÚÇ';
alterchars   = 'aaaaeeioooucAAAAEEIOOOUC';

name = SplitParamUnits(name);

ix = find(name == ':');
if ~isempty(ix)
    name(1:ix(end)) = [];
end

name(name=='.') = [];
name(name==',') = [];

if isempty(name)
    var = '';
    return
end

for n = 1:length(name)
    k = find(name(n) == replacechars);
    if ~isempty(k)
        name(n) = alterchars(k);
    end
end

for n = 1:length(name)
    if ~any(name(n) == validchars)
        name(n) = '_';
    end
end

if any(name(1) == '0123456789_')
    name = ['X' name];
end

var = name;