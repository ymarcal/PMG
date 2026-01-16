function newname = unitrep(oldname,unit1,unit2)
% Troca a unidade 'unit1' pela 'unit2' no nome de um parametro
% A unidade original do parametro sera padronizada para a troca
% Caso 'unit1' nao seja encontrada, o parametro nao sofre alteraçao

stdname = SetUnits(oldname);
unit1 = SetUnits(['(' unit1 ')']);
unit1([1,end]) = [];
unit2 = SetUnits(['(' unit2 ')']);
unit2([1,end]) = [];

newname = strrep(stdname,['(' unit1 ')'],['(' unit2 ')']);

if ~isempty(newname=='/')
    newname = strrep(newname,['(' unit1 '/'],['(' unit2 '/']);
end

if ~isempty(unit1) && unit1(1) == '/'
    newname = strrep(newname,[unit1 ')'],[unit2 ')']);
end

if isequal(stdname,newname) && isempty(strfind(stdname,['(' unit1])) && isempty(strfind(stdname,[unit1 ')']))
    newname = oldname;
end
