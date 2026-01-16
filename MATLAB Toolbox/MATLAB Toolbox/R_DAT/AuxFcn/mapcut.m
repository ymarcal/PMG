function [xc, yc, Iin] = mapcut(x,y,xlim,ylim,ktype,plotopt)
% A partir de um par de vetores x-y que definem vector maps (linhas, pontos ou areas),
% extrai uma seçao definida por um retangulo [xmin xmax] e [ymin ymax]
% Sintaxe: [xc, yc, Iin] = mapcut(x,y,xlim,ylim,ktype,plotopt)

if isempty(x)
    xc  = [];
    yc  = [];
    Iin = [];
    return
end

switch nargin
    case 4
        ktype = 'point';
        plotopt = 0;
    case 5
        plotopt = 0;
end

x1 = xlim(1); x2 = xlim(2);
y1 = ylim(1); y2 = ylim(2);

xc = x(:);
yc = y(:);

switch ktype
    case {'point','text'}
        
        % Localizar pontos dentro da area demarcada
        in = xc>=x1 & xc<x2 & yc>=y1 & yc<y2;
        
        % Excluir pontos fora da area demarcada
        xc(~in) = [];
        yc(~in) = [];
        Iin = in;
        
    case 'line'

        % Colocar NaN de x em y e vice-versa
        xc(isnan(yc)) = NaN;
        yc(isnan(xc)) = NaN;
        
        % Colocar NaN no inicio e fim
        xc = [NaN; xc; NaN];
        yc = [NaN; yc; NaN];
        
        for side = 1:4 % Cada lado [esq, dir, abaixo, acima]
            
            % Localizar pontos dentro da area demarcada
            switch side
                case 1 % esq
                    in = xc>=x1;
                    xcut = [  x1  x1]';
                    ycut = [-Inf Inf]';
                    opt  = 1;
                case 2 % dir
                    in = xc<=x2;
                    xcut = [  x2  x2]';
                    ycut = [-Inf Inf]';
                    opt  = 1;
                case 3 % abaixo
                    in = yc>=y1;
                    xcut = [-Inf Inf]';
                    ycut = [  y1  y1]';
                    opt  = 2;
                case 4 % acima
                    in = yc<=y2;
                    xcut = [-Inf Inf]';
                    ycut = [  y2  y2]';
                    opt  = 2;
            end

            % Adicionar um ponto adjacente aos pontos internos
            in2 = in | [in(2:end); 0] | [0; in(1:end-1)];
            
            % Invalidar pontos fora da area
            xc(~in2) = NaN;
            yc(~in2) = NaN;
            
            % Separar pontos isolados fora da area   --o--x--o--
            singleout = find(~isnan(xc) & ~in & [1; in(1:end-1)] & [in(2:end); 1]);
            for n = length(singleout):-1:1
                xc = [xc(1:singleout(n)); NaN; xc(singleout(n):end)];
                yc = [yc(1:singleout(n)); NaN; yc(singleout(n):end)];
                in = [in(1:singleout(n));   0; in(singleout(n):end)];
            end
            
            % Separar pontos duplos isolados fora da area   --o--x--x--o--
            doubleout = find(~isnan(xc) & ~in & [1; in(1:end-1)] & ~[in(2:end); 1] & [in(3:end); 1; 1]);
            for n = length(doubleout):-1:1
                xc = [xc(1:doubleout(n)); NaN; xc(doubleout(n)+1:end)];
                yc = [yc(1:doubleout(n)); NaN; yc(doubleout(n)+1:end)];
                in = [in(1:doubleout(n));   0; in(doubleout(n)+1:end)];
            end
            
            % Localizar pontos fora da area demarcada
            out = ~in;
            
            % Cortar os segmentos na fronteira da area demarcada
            out2in = find(out & [ in(2:end); 0]);
            in2out = find(in  & [out(2:end); 0]);

            for n = 1:length(out2in)
                k = out2in(n);
                if all(~isnan(xc(k:k+1))) && all(~isnan(yc(k:k+1)))
                    [xi,yi] = linexline(xc(k:k+1),yc(k:k+1),xcut,ycut,opt);
                    if ~isempty(xi)
                        xc(k) = xi(1);
                        yc(k) = yi(1);
                    end
                end
            end
            for n = 1:length(in2out)
                k = in2out(n);
                if all(~isnan(xc(k:k+1))) && all(~isnan(yc(k:k+1)))
                    [xi,yi] = linexline(xc(k:k+1),yc(k:k+1),xcut,ycut,opt);
                    if ~isempty(xi)
                        xc(k+1) = xi(1);
                        yc(k+1) = yi(1);
                    end
                end
            end
            
        end
        
        % Excluir NaN's contiguos
        exc = isnan(xc) | isnan(yc);
        exc = exc & [exc(2:end); 0];
        xc(exc) = [];
        yc(exc) = [];
        
        % Eliminar pontos repetidos
        if length(xc) > 1
            exc = diff(xc) == 0 & diff(yc) == 0;
            xc(exc) = [];
            yc(exc) = [];
        end
        
        % Eliminar pontos colineares
        if length(xc) > 1
            exc = logical([0; diff(angle(diff(xc)+1i*diff(yc))) == 0; 0]);
            xc(exc) = [];
            yc(exc) = [];
        end
        
        % Eliminar pontos isolados
        if length(xc) > 2
            exc = [0; isnan(xc(1:end-1))] & [isnan(xc(2:end)); 0];
            exc = (exc | [0; exc(1:end-1)]);
            xc(exc) = [];
            yc(exc) = [];
        end
        
         % Eliminar NaN no inicio e final dos vetores
        if ~isempty(xc) && isnan(xc(1))
            xc(1) = [];
            yc(1) = [];
        end
        if ~isempty(xc) && isnan(xc(end))
            xc(end) = [];
            yc(end) = [];
        end
        
       % Vetor de indices nao usado para 'linha'
        Iin = [];
        
    case 'area'
        
%         % ATENÇAO: A AREA NAO PODE CONTER BURACOS INTERNOS. USE 'POLYCUT' PARA ELIMINA-LOS
%         
%         % Colocar NaN de x em y e vice-versa
%         xc(isnan(yc)) = NaN;
%         yc(isnan(xc)) = NaN;
%         
%         % Colocar NaN no inicio e fim
%         xc = [NaN; xc; NaN];
%         yc = [NaN; yc; NaN];
%         
%         % Excluir NaN's contiguos
%         exc = isnan(xc);
%         exc = exc & [exc(2:end); 0];
%         xc(exc) = [];
%         yc(exc) = [];
%         
%         for side = 1:4 % Cada lado [esq, dir, abaixo, acima]
%             
%             % Localizar pontos dentro da area demarcada
%             switch side
%                 case 1 % esq
%                     in = xc>=x1;
%                 case 2 % dir
%                     in = xc<=x2;
%                 case 3 % abaixo
%                     in = yc>=y1;
%                 case 4 % acima
%                     in = yc<=y2;
%             end
%             
%             % Duplicar pontos isolados fora da area
%             singleout = find(~isnan(xc) & ~in & [in(2:end); 1] & [1; in(1:end-1)]);
%             
%             for n = length(singleout):-1:1
%                 xc = [xc(1:singleout(n)); xc(singleout(n):end)];
%                 yc = [yc(1:singleout(n)); yc(singleout(n):end)];
%                 in = [in(1:singleout(n)); in(singleout(n):end)];
%             end
%             
%             % Estender o vetor em -1 e +1 ponto para fora da area
%             in2 = in | [in(2:end); 0] | [0; in(1:end-1)];
%             
%             % Exscluir os pontos fora da area
%             xc(~in2) = [];
%             yc(~in2) = [];
%             in(~in2) = [];
%             
%             % Cortar os segmentos na fronteira da area demarcada
%             out = ~in;
%             
%             out2in = find(out & [ in(2:end); 0]);
%             in2out = find(in  & [out(2:end); 0]);
%             
%             switch side
%                 case 1 % esq
%                     rx = [x1 x1];
%                     ry = [-Inf Inf];
%                 case 2 % dir
%                     rx = [x2 x2];
%                     ry = [-Inf Inf];
%                 case 3 % abaixo
%                     rx = [-Inf Inf];
%                     ry = [y1 y1];
%                 case 4 % acima
%                     rx = [-Inf Inf];
%                     ry = [y2 y2];
%             end
% 
%             for n = 1:length(find(out2in))
%                 k = out2in(n);
%                 if all(~isnan(xc(k:k+1))) && all(~isnan(yc(k:k+1)))
%                     [xi,yi] = polyxpoly(xc(k:k+1),yc(k:k+1),rx,ry);
%                     if ~isempty(xi)
%                         xc(k) = xi(1);
%                         yc(k) = yi(1);
%                     end
%                 end
%             end
%             for n = 1:length(find(in2out))
%                 k = in2out(n);
%                 if all(~isnan(xc(k:k+1))) & all(~isnan(yc(k:k+1)))
%                     [xi,yi] = polyxpoly(xc(k:k+1),yc(k:k+1),rx,ry);
%                     if ~isempty(xi)
%                         xc(k+1) = xi(1);
%                         yc(k+1) = yi(1);
%                     end
%                 end
%             end
%         end
%         
%         % Colocar NaN de x em y e vice-versa
%         xc(isnan(yc)) = NaN;
%         yc(isnan(xc)) = NaN;
%         
%         % Colocar NaN no inicio e fim
%         xc = [NaN; xc; NaN];
%         yc = [NaN; yc; NaN];
%         
%         % Excluir NaN's contiguos
%         exc = isnan(xc);
%         exc = exc & [exc(2:end); 0];
%         xc(exc) = [];
%         yc(exc) = [];
%         
%         % Eliminar pontos repetidos
%         if length(xc) > 1
%             exc = diff(xc) == 0 & diff(yc) == 0;
%             xc(exc) = [];
%             yc(exc) = [];
%         end
%         
%         % Eliminar pontos colineares
%         if length(xc) > 1
%             exc = logical([0; diff(angle(diff(xc)+i*diff(yc))) == 0; 0]);
%             xc(exc) = [];
%             yc(exc) = [];
%         end
%         
%         % Eliminar pontos isolados
%         if length(xc) > 2
%             exc = [0; isnan(xc(1:end-1))] & [isnan(xc(2:end)); 0];
%             exc = [exc | [0; exc(1:end-1)]];
%             xc(exc) = [];
%             yc(exc) = [];
%         end
%         
%         % Eliminar NaN no inicio e final dos vetores
%         if ~isempty(xc) && isnan(xc(1))
%             xc(1) = [];
%             yc(1) = [];
%         end
%         if ~isempty(xc) && isnan(xc(end))
%             xc(end) = [];
%             yc(end) = [];
%         end
%         
%        % Vetor de indices nao usado para 'linha'
%         Iin = [];

        % Colocar NaN de x em y e vice-versa
        yc(isnan(xc)) = NaN;
        xc(isnan(yc)) = NaN;
        
        % Colocar NaN no inicio e fim dos vetores
        xc = [NaN; xc; NaN];
        yc = [NaN; yc; NaN];
        
        % Excluir NaN's contiguos
        exc = isnan(xc);
        exc = exc & [exc(2:end); 0];
        xc(exc) = [];
        yc(exc) = [];
        
        % Separar os vetores em celulas
        [XC,YC] = mat2cell_map(xc,yc);
        
        % Separar poligonos unidos por um segmento
        for n = 1:length(XC)
            [XC{n},YC{n}] = seppoly(XC{n},YC{n});
        end
        [xc,yc] = cell2mat_map(XC,YC);
        [XC,YC] = mat2cell_map(xc,yc);
        
        % Realizar operaçao booleana
        for n = 500:length(XC)
            % [XC{n},YC{n}] = areacut(XC{n},YC{n},[x1 x2],[y1 y2]);
            try
                [XC{n},YC{n}] = polybool('intersection',XC{n},YC{n},[x1 x2 x2 x1 x1]',[y1 y1 y2 y2 y1]');
            catch
%                 [XC{n},YC{n}] = seppoly(XC{n},YC{n});
                try
                    [XC{n},YC{n}] = polybool('subtraction',XC{n},YC{n},[-Inf   x1  x1 -Inf]',[-Inf -Inf Inf  Inf]');
                    [XC{n},YC{n}] = polybool('subtraction',XC{n},YC{n},[ Inf   x2  x2  Inf]',[-Inf -Inf Inf  Inf]');
                    [XC{n},YC{n}] = polybool('subtraction',XC{n},YC{n},[-Inf -Inf Inf  Inf]',[-Inf   y1  y1 -Inf]');
                    [XC{n},YC{n}] = polybool('subtraction',XC{n},YC{n},[-Inf -Inf Inf  Inf]',[ Inf   y2  y2  Inf]');
                catch
                    XC{n} = [];
                    YC{n} = [];
                    beep;
                    disp(' ');
                    disp('Erro ao segmentar o setor');
                    disp(['[' deg2latlong(x1,1) ',  ' deg2latlong(x2,1) '] × [' deg2latlong(y1,2) ',  ' deg2latlong(y2,2) ']']);
                end
            end
            % Eliminar o bug que fornece o retangulo completo
            c1 = find(XC{n}==x1 & YC{n}==y1);
            c2 = find(XC{n}==x2 & YC{n}==y1);
            c3 = find(XC{n}==x1 & YC{n}==y2);
            c4 = find(XC{n}==x2 & YC{n}==y2);
            if ~isempty(c1) && ~isempty(c2) && ~isempty(c3) && ~isempty(c4)
                XC{n}([c1; c2; c3; c4]) = [];
                YC{n}([c1; c2; c3; c4]) = [];
            end
            
            if any(isnan(XC{n}))
                [XC{n}, YC{n}] = polycut(XC{n}, YC{n});
            end
        end
        
        % Reunificar os vetores
        [xc,yc] = cell2mat_map(XC,YC);
        
        % Colocar NaN no inicio e fim dos vetores
        xc = [NaN; xc; NaN];
        yc = [NaN; yc; NaN];
        
        % Excluir NaN's contiguos
        exc = isnan(xc);
        exc = exc & [exc(2:end); 0];
        xc(exc) = [];
        yc(exc) = [];
        
        % Eliminar repetiçao do 1º ponto no final de cada poligono
        nnan = isnan(xc) | isnan(yc);
        nnan = find(nnan);
        exc = [];
        for n = 2:length(nnan)
            k1 = nnan(n-1)+1;
            k2 = nnan(n)-1;
            if xc(k1) == xc(k2) && yc(k1) == yc(k2)
                exc = [exc k2];
            end
        end
        xc(exc) = [];
        yc(exc) = [];
                
        % Eliminar NaN no inicio e fim dos vetores
        if ~isempty(xc) && isnan(xc(1))
            xc(1) = [];
            yc(1) = [];
        end
        if ~isempty(xc) && isnan(xc(end))
            xc(end) = [];
            yc(end) = [];
        end
        
        % Eliminar pontos repetidos
        if length(xc) > 1
            exc = diff(xc) == 0 & diff(yc) == 0;
            xc(exc) = [];
            yc(exc) = [];
        end
        
        % Eliminar pontos colineares (centesimo de grau)
        if length(xc) > 1
            exc = logical([0; abs(diff(angle(diff(xc)+1i*diff(yc)))) < 1e-4; 0]);
            xc(exc) = [];
            yc(exc) = [];
        end
        
        % Vetor de indices nao usado para 'area'
        Iin = [];
        
end

% Plotagem do resultado
if plotopt
    
    axes
    hold on
    
    switch ktype
        case 'point'
            plot(x,y,'.b');
            plot(xc,yc,'.g');
            
        case 'line'
            plot(x,y,'-ob');
            plot(xc,yc,'-+g');
            
        case 'area'
            patchplot(x,y,'b');
            patchplot(xc,yc,'g');
    end
    
    plot([x1 x2 x2 x1 x1],[y1 y1 y2 y2 y1],'--r');
end

%-----------------------------------------------------------
function [x, y] = unique2(x, y)
% Elimina pontos [x y] repetidos

exc = [];
for n = 2:length(x)
    if any(x(n)==x(1:n-1) & y(n)==y(1:n-1))
        exc = [exc n];
    end
end
x(exc) = [];
y(exc) = [];

%-----------------------------------------------------------
function [xi,yi] = linexline(x,y,xc,yc,opt)
% Fornece o ponto de interseçao entre duas retas

if nargin == 4
    opt = 0;
end

if opt == 1
    % Cortar na vertical (x)
    xi = xc(1);
    yi = (y(2)-y(1))*(xc(1)-x(1))/(x(2)-x(1)) + y(1);
    
elseif opt == 2
    % Cortar na horizontal (y)
    yi = yc(1);
    xi = (x(2)-x(1))*(yc(1)-y(1))/(y(2)-y(1)) + x(1);
    
else
    % Corte arbitrario
    try
        [xi,yi] = polyxpoly(x,y,xc,yc);
    catch
        xi = [];
        yi = [];
    end
    
end

% -------------------------------------------------------------------------------
function [XC,YC] = mat2cell_map(xc,yc)
% Separa os vetores delimitados por "NaN" em celulas

if ~isnan(xc(1))
    xc = [NaN; xc];
    yc = [NaN; yc];
end
if ~isnan(xc(end))
    xc = [xc; NaN];
    yc = [yc; NaN];
end

nn = find(isnan(xc));
XC = cell(length(nn)-1,1);
YC = XC;

for n = 1:length(nn)-1
    XC{n} = xc(nn(n)+1:nn(n+1)-1);
    YC{n} = yc(nn(n)+1:nn(n+1)-1);
end

% -------------------------------------------------------------------------------
function [xc,yc] = cell2mat_map(XC,YC)
% Reunificar vetores separados por celula em vetores continuos delimitados por "NaN"

xc = [];
yc = [];

for n = 1:length(XC)
    xc = [xc; NaN; XC{n}];
    yc = [yc; NaN; YC{n}];
end














% -------------------------------------------------------------------------------
function out = issplitarea(x,y,r1,r2,r3)
% Indica se um poligono que define uma area deve ser separado em dois
% ao ser cortado por uma reta nos pontos r1, r2 e r3

if polywise(x,y) >= 0
    if     r1>r2 && r3<r2  ||  r2<r1 && r3>r1  ||  r1<r3 && r2>r3
        out = 0; % Sem corte
    elseif r1<r2 && r3>r2  ||  r2>r1 && r3<r1
        out = 1; % Corte simples
    else
        out = 2; % Corte com inversao da ordem
    end
else
    if     r1<r2 && r3>r2  ||  r1>r3 && r2<r3  ||  r2>r1 && r3<r1
        out = 0; % Sem corte
    elseif r1>r2 && r3<r2  ||  r2<r1 && r3>r1
        out = 1; % Corte simples
    else
        out = 2; % Corte com inversao da ordem
    end
end        

% -------------------------------------------------------------------------------
function w = polywise(x,y)
% Indica a orientaçao de traçado de um poligono (horario = -1 / Anti-horario = 1)

nnan = find(isnan(x+y));
if ~isempty(nnan)
    x = x(nnan+1:end);
    y = y(nnan+1:end);
end

A = 0;
for n = 1:length(x)
    if n == 1
        a = angle( x(n+1)-x(n) + 1i* (y(n+1)-y(n))) - angle( x(n)-x(end) + 1i* (y(n)-y(end)));
    elseif n == length(x)
        a = angle( x( 1 )-x(n) + 1i* (y( 1 )-y(n))) - angle( x(n)-x(n-1) + 1i* (y(n)-y(n-1)));
    else
        a = angle( x(n+1)-x(n) + 1i* (y(n+1)-y(n))) - angle( x(n)-x(n-1) + 1i* (y(n)-y(n-1)));
    end
    
    a = mod(a,2*pi);
    if a > pi
        a = a - 2*pi;
    end;

    A = A + a;
end

w = sign(A);

%-----------------------------------------------------------
function [x, y] = areacut(x,y,dx,dy)
% Interseçao entre uma area [x y] e um retangulo [x1 x2],[y1 y2]

if length(x) < 3
    x = [];
    y = [];
    return
end

% Abertura da area
if x(end) == x(1) && y(end) == y(1)
    x(end) = [];
    y(end) = [];
end

x1 = dx(1);
x2 = dx(2);
y1 = dy(1);
y2 = dy(2);

for s = 1:4
    
    if s == 1 % Cortar à esquerda ----------------------
        
        in  = x >= x1;
        out = ~in;
        
        % Nenhum ponto interno
        if all(out)
            x = [];
            y = [];
            return
        end
        
        % Apenas pontos internos
        if all(in)
            continue
        end
        
        % O primeiro ponto deve estar na fronteira de entrada
        out2in = find(out & [ in(2:end); 0]);
        if ~isempty(out2in)
            x   = [x(out2in(1)+1:end); x(1:out2in(1))];
            y   = [y(out2in(1)+1:end); y(1:out2in(1))];
            in  = x >= x1;
            out = ~in;
        end
        [xc,yc] = linexline(x([end 1]),y([end 1]),x1,Inf,1);
        r1 = yc;
        hp = plot(xc,yc,'ok');
        
        % Analise ponto-a-ponto
        for n = 1:length(x)
            if n == 1 % 1º ponto
                xc = [xc; x(n)];
                yc = [yc; y(n)];
            elseif in(n) && in(n-1)
                % Continua dentro
                xc = [xc; x(n)];
                yc = [yc; y(n)];
            elseif ~in(n) && in(n-1)
                % Saiu
                [xi,yi] = linexline(x(n-1:n),y(n-1:n),x1,Inf,1);
                r2 = yi;
                xc = [xc; xi];
                yc = [yc; yi];
            elseif ~in(n) && ~in(n-1)
                % Continua fora
            elseif in(n) && ~in(n-1)
                % Entrou
                [xi,yi] = linexline(x(n-1:n),y(n-1:n),x1,Inf,1);
                opt = issplitarea(x,y,r1,r2,yi);
                if opt == 1
                    xc = [xc; NaN; xi; x(n)];
                    yc = [yc; NaN; yi; y(n)];
                elseif opt == 2
                    beep
                    return
                else
                    xc = [xc; xi; x(n)];
                    yc = [yc; yi; y(n)];
                end
                r1 = yi;
                in(n-1) = 1;
            end
            set(hp,'XData',xc,'YData',yc);
        end
        x = xc;
        y = yc;
    end
    
end
