function testpts = emptytestptslist
% Cria lista de pontos de ensaio vazia

% Nome do grupo
testpts.group = '1';

% Valores gerais
testpts.visible = 1;
testpts.include = [1 zeros(1,5)];
testpts.inisample = 0;

% Valores por ponto (uma coluna um ponto)
testpts.number   = {};
testpts.descr    = {};
testpts.time     = [];

% Valores por parametro (uma linha por parametro)
testpts.param = {};
testpts.data  = []; % mean | std | min | max | range | ini | end | var | val | tau | zeta | wn | deriv
testpts.fit   = [];

% Valores por ponto e parametro (uma linha por ponto e uma coluna por parametro)
testpts.aim    = [];
testpts.range1 = [];
testpts.range2 = [];
testpts.tol1   = [];
testpts.tol2   = [];