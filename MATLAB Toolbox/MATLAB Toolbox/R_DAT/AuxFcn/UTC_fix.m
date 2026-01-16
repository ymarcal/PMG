function T = UTC_fix(UTC)
% Corrige falhas e saltos no tempo UTC dos dados de debriefing da aeronave F-5M

T = denan(UTC);
N = length(T);

if ~any(find(diff(T)<=0))
    return
end

ok = 0;

dt = mean(diff(T));
jp = 1;

h = waitbar(0,'Corrigindo Tempo UTC. 0.0% concluído.','Name','Aguarde ...','Pointer','watch','Color',get(0,'DefaultUIControlBackground'),'WindowStyle','modal');

while ~ok
    n0 = 1;
    n1 = 0;
    n2 = 0;
    for n = n0:N-1
        if n == N-1
            ok = 1;
            break
        end
        if T(n+1)-T(n) > .9*(jp+dt) && T(n+1)-T(n) < 1.1*(jp+dt) % Subida
            n1 = n;
        end
        if T(n+1)-T(n) < -.9*(jp-dt) && T(n+1)-T(n) > -1.1*(jp-dt) % Descida
            n2 = n+1;
        end
        if n1 && n2 && n2 > n1
            T(n1:n2) = linspace(T(n1),T(n2),n2-n1+1);
            n0 = n2;
            if ishandle(h)
                waitbar(n0/N,h,['Corrigindo Tempo UTC. ' num2str(100*n0/N,'%1.1f') '% concluído.']);
            end
            break
        end        
    end
end

if ishandle(h)
    waitbar(1,h,'Corrigindo Tempo UTC. 100.0% concluído.');
    pause(1);
    delete(h);
end


