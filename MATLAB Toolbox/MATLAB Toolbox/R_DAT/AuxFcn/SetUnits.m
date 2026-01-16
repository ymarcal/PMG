function [PARAM, Nalt] = SetUnits(PARAM,datunits,ignore)
% Altera os nomes as unidades para nomes padronizados

if nargin < 2
    load(which('DatUnits.mat'),'datunits');
end
if nargin < 3
    ignore = zeros(length({datunits.std}),1);
end

if ischar(PARAM)
    PARAM = cellstr(PARAM);
    c = 1;
else
    c = 0;
end

if isempty(PARAM)
    Nalt = 0;
else
    Np = length(PARAM);
    Ns = length({datunits.std});
    Nalt = zeros(Np,1);
    
    for np = 1:Np
        
        PARAM{np}(PARAM{np}=='[')='(';
        PARAM{np}(PARAM{np}==']')=')';
        
        for ns = 1:Ns
            if ~ignore(ns)
                
                Na = length(datunits(ns).alt);
                
                % Unidate inteira
                unit = ['(' datunits(ns).std ')'];
                for na = 1:Na
                    alt = ['(' datunits(ns).alt{na} ')'];
                    ind = strfind(lower(PARAM{np}),lower(alt));
                    if ~isempty(ind)
                        alt = PARAM{np}(ind:ind+length(alt)-1);
                        if ~strcmp(alt,unit);
                            PARAM{np} = strrep(PARAM{np},alt,unit);
                            PARAM{np} = strrep(PARAM{np},'([ ])','');
                            PARAM{np} = strrep(PARAM{np},'([])','');
                            Nalt(np) = 1;
                            break
                        end
                    end
                end
                
                % Unidade no numerador
                unit = ['(' datunits(ns).std '/'];
                for na = 1:Na
                    alt = ['(' datunits(ns).alt{na} '/'];
                    ind = strfind(lower(PARAM{np}),lower(alt));
                    if ~isempty(ind)
                        alt = PARAM{np}(ind:ind+length(alt)-1);
                        if ~strcmp(alt,unit);
                            PARAM{np} = strrep(PARAM{np},alt,unit);
                            Nalt(np) = 1;
                            break
                        end
                    end
                end
                
                % Unidade no denominador
                unit = ['/' datunits(ns).std ')'];
                for na = 1:Na
                    alt = ['/' datunits(ns).alt{na} ')'];
                    ind = strfind(lower(PARAM{np}),lower(alt));
                    if ~isempty(ind)
                        alt = PARAM{np}(ind:ind+length(alt)-1);
                        if ~strcmp(alt,unit);
                            PARAM{np} = strrep(PARAM{np},alt,unit);
                            Nalt(np) = 1;
                            break
                        end
                    end
                end
            end
        end
        
        for np2 = 1:Np
            if strfind(PARAM{np2},' ()');
                PARAM{np2} = strrep(PARAM{np2},' ()','');
                Nalt(np2) = 1;
            end
        end
    end
    
    Nalt = length(find(Nalt));
end

if c
    PARAM = char(PARAM);
end