function val = checkval(D,aim,range1,range2,tol1,tol2,k)
% Verifica a validade de uma matriz de dados D segundo os parametros aim, range e tol
% Opçao: k = numero de observaçoes que definem o valor inicial do ponto (0 = todo o ponto)

if nargin == 6
    k = 0;
end

[Npts,Npar] = size(D);

if k == 0
    inisample = 1:Npts;
else
    inisample = 1:min(k,Npts);
end

for npar = 1:Npar
    if isnan(aim(npar)) && isnan(range1(npar)) && isnan(range2(npar)) && isnan(tol1(npar)) && isnan(tol2(npar)) % No valid parameters
        val(:,npar) = NaN*ones(Npts,1);
    else
        if ~isnan(aim(npar)) && ~isnan(range2(npar)-range1(npar)) && isnan(tol2(npar)-tol1(npar)) % Only aim & range
            tol1(npar) = -Inf;
            tol2(npar) =  Inf;
        elseif (isnan(aim(npar)) || isnan(range2(npar)-range1(npar))) && ~isnan(tol2(npar)-tol1(npar)) % Only tol
            aim(npar) = 0;
            range1(npar) = -Inf;
            range2(npar) =  Inf;
        end
        val(:,npar) = (D(:,npar) >= aim(npar)+range1(npar)) .* (D(:,npar) <= aim(npar)+range2(npar)) .* ...
            (D(:,npar) >= (nanmean(D(inisample,npar))+tol1(npar))) .* (D(:,npar) <= (nanmean(D(inisample,npar))+tol2(npar)));
    end
end