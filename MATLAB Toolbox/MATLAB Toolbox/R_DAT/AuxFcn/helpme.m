function helpme(fname,fmark)
% Chama o documento de ajuda em html
% Exemplo: helpme('Funcoes\convsist')

if ~nargin || ~ischar(fname)
    beep; errordlg('Arquivo de ajuda não especificado.','Erro','modal');
    return
end

RDATpath = which('R_DAT.m');

if isempty(RDATpath)
    beep; errordlg('Arquivo de ajuda não encontrado.','Erro','modal');
    return
end
    
ind = find(RDATpath==filesep);
RDATpath(ind(end)+1:end) = [];

if any(fname=='\')
    fname = ['Menu_' fname];
end

% if nargin == 1
    helpfile = [RDATpath 'help\' fname '.html'];
% else
%     helpfile = [RDATpath 'help\' fname '_' fmark '.url'];
% end
    
if ~exist(helpfile,'file')
    beep; errordlg({'Arquivo de ajuda não encontrado:',helpfile,' ','Contate o Suporte Técnico.'},'Erro','modal');
    return
end

dos(helpfile);
