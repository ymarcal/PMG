function S = goodnessfit(y, yf, m)

% Calculates the goodness of fit statistics:
%  normres: Norm of residues.
%  SSE:     Sum of Squares due to Error. This statistic measures the total deviation of the fit to the original data.
%           It is also called the summed square of residuals. A value closer to 0 indicates a better fit.
%  MSE:     Mean square error or the residual mean square, where MSE = SSE/v.
%  SSR:     Sum of Squares of the Regression. It's the sum of squares of the fit about the mean.
%  SST:     Total Sum of Squares or sum of squares about the mean, where SST = SSR + SSE.
%  R2:      R-Square is the ratio of SSR and SST, and takes on values between 0 and 1. A value closer to 1
%           indicates a better fit.
%  adjR2:   Adjusted R-Square. This statistic adjusts the the R-square based on the residual degrees of freedom,
%           which is defined as the number of response values n minus the number of fit coefficients m.
%  RMSE:    Root Mean Squared Error, also known as the fit standard error and the standard error of the regression.
%           A value closer to 0 indicates a better fit.
%  STDE:    Standard deviation of errors
%
% Input data:
%  y:  original data
%  yf: fitted data
%  m:  number of fit coefficients
%
% Output data
%  S: Structure containing all statistics, plus:
%     n: number of observations
%     v: degrees of freedom (n-m)
%
% Syntax: S = goodnessfit(y, yf, m)

n = length(y);
v = n - m;

if isempty(y) || any(isnan(y)) || any(isnan(yf)) || v <= 0
    S.n = NaN;
    S.m = NaN;
    S.v = NaN;
    S.normres = NaN;
    S.SSE = NaN;
    S.MSE = NaN;
    S.SSR = NaN;
    S.SST = NaN;
    S.R2 = NaN;
    S.adjR2 = NaN;
    S.RMSE = NaN;
    S.STDE = NaN;
    return
end

ym = mean(y);

normres = norm(yf-y);

SSE = sum((yf-y).^2);

MSE = SSE/v;

SSR = sum((yf-ym).^2);

SST = sum((y-ym).^2);

if SST>0
    R2 = SSR/SST;
else
    R2 = NaN;
end

if SST>0 && v>1
    adjR2 = 1 - SSE/SST .* (n-1)/(v-1);
else
    adjR2 = NaN;
end

if v>0
    RMSE = sqrt(SSE/v);
else
    RMSE = NaN;
end

STDE = nanstd(yf-y);

% -------------------
S.n = n;
S.m = m;
S.v = v;
S.normres = normres;
S.SSE = SSE;
S.MSE = MSE;
S.SSR = SSR;
S.SST = SST;
S.R2 = R2;
S.adjR2 = adjR2;
S.RMSE = RMSE;
S.STDE = STDE;
