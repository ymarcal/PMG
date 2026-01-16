function [Az, El] = earth2hud(N,E,D,psi,tet,phi)
% Conversão do sistema terrestre móvel [North, East, Down] para o sistema do HUD [Azim, Elev]
% Sintaxe: [Az, El] = earth2hud(N,E,D,psi,tet,phi)
%    N, E, D:       North, East, Down  [mesma unidade]
%    psi, tet, phi: Angulos de Euler   [graus] (proa verdadeira, nao magnetica)
%    Az, El:        Azimute e elevaçao [graus]

psi = psi * pi/180;
tet = tet * pi/180;
phi = phi * pi/180;

XYZ = zeros(length(N),3);

if length(psi) == 1
    
    R = [cos(tet)*cos(psi)                            cos(tet)*sin(psi)                             -sin(tet)         ;
        sin(phi)*sin(tet)*cos(psi)-cos(phi)*sin(psi)  cos(phi)*cos(psi)+sin(phi)*sin(tet)*sin(psi)  sin(phi)*cos(tet) ;
        sin(phi)*sin(psi)+cos(phi)*sin(tet)*cos(psi)  cos(phi)*sin(tet)*sin(psi)-sin(phi)*cos(psi)  cos(phi)*cos(tet) ];
    
    for n = 1:length(N)
        XYZ(n,:) = (R * [N(n); E(n); D(n)] )';
    end
    
else
    
    for n = 1:length(psi)
        
        R = [cos(tet(n))*cos(psi(n))                                     cos(tet(n))*sin(psi(n))                                     -sin(tet(n))             ;
            sin(phi(n))*sin(tet(n))*cos(psi(n))-cos(phi(n))*sin(psi(n))  cos(phi(n))*cos(psi(n))+sin(phi(n))*sin(tet(n))*sin(psi(n))  sin(phi(n))*cos(tet(n)) ;
            sin(phi(n))*sin(psi(n))+cos(phi(n))*sin(tet(n))*cos(psi(n))  cos(phi(n))*sin(tet(n))*sin(psi(n))-sin(phi(n))*cos(psi(n))  cos(phi(n))*cos(tet(n)) ];
        
        XYZ(n,:) = (R * [N(n); E(n); D(n)] )';
        
    end
end

Az =  atan2(XYZ(:,2),XYZ(:,1))*180/pi;
El = -atan2(XYZ(:,3),sqrt(XYZ(:,1).^2+XYZ(:,2).^2))*180/pi;
