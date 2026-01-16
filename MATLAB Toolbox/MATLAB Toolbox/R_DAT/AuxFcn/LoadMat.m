function [newDADOS, PARAM, err] = LoadMat(fname,fpath,maxparamlength)
% Funçao para carregamento de arquivo de dados em formato mat

switch nargin
    case 0
        [fname, fpath] = uigetfile({'*.mat','Arquivo mat (*.mat)'},'Carregar arquivo mat'); drawnow;
        if ~ischar(fname)
            return
        end
        maxparamlength = 48;
    case 1;
        fpath = '';
        maxparamlength = 48;
    case 2;
        maxparamlength = 48;
end

% FORMATO IPEV
[newDADOS, PARAM, err] = LoadMatIpev(fname,fpath,maxparamlength);

if ~isempty(err)
    % FORMATO EMBRAER
    [newDADOS, PARAM, err2] = LoadMatEmb(fname,fpath,maxparamlength);
    
    if isempty(err2)
        err = '';
    end
end
