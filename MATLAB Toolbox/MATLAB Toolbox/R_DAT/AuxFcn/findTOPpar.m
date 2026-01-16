function topcols = findTOPpar(PARAM)
% Localiza os parametros reconhecidos como TOP

topcols = findpar(PARAM,{'Event','TOP','Mark','tseq','seq'},1,0);