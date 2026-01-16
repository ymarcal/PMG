function CheckRepParam(PARAM,param)
% Verifica e avisa se há nomes repetidos na matriz param

if nargin == 1
    param = [];
end

if ischar(PARAM)
    PARAM = cellstr(PARAM);
end

if isempty(param) % Verifica todos os parametros
    
    N = length(PARAM);
    rep = 0;
    ind = 1:N;
    str = {'ATENÇÃO!','','Encontrados parâmetros com nomes repetidos:',''};
    PARAM2 = denumber(PARAM);
    for n = 1:length(PARAM2)
        param = denumber(PARAM{n});
        if ~strcmp(param,'?')
            r = strmatch(param,PARAM2,'exact');
            if length(r) > 1
                rep = 1;
                strn = num2str(ind(r(1)),'%02.f');
                for k = 2:length(r)
                    if k < length(r)
                        strn = [strn ', ' num2str(ind(r(k)),'%02.f')];
                    else
                        strn = [strn ' e ' num2str(ind(r(k)),'%02.f')];
                    end
                end
                str{end+1} = [strn ' - ' param];
                PARAM2(r) = [];
                ind(r) = [];
            end
        end
    end
    if rep
        uiwait(warndlg(str,'Aviso','modal')); drawnow;
    end
    
else % Verifica apenas o parametro "param"
    
    rep = 0;
    str = {'ATENÇÃO!','','O nome indicado não é único:',''};
    PARAM2 = denumber(PARAM);
    if ~strcmp(param,'?')
        r = strmatch(param,PARAM2,'exact');
        if length(r) > 1
            rep = 1;
            strn = num2str(r(1),'%02.f');
            for k = 2:length(r)
                if k < length(r)
                    strn = [strn ', ' num2str(r(k),'%02.f')];
                else
                    strn = [strn ' e ' num2str(r(k),'%02.f')];
                end
            end
            str{end+1} = [strn ' - ' param];
        end
    end
    if rep
        uiwait(warndlg(str,'Aviso','modal')); drawnow;
    end
    
end