function [x,msg] = roundn(x,n)
%ROUNDN  Round numbers to specified power of 10
%
%  y = ROUNDN(x) rounds the input data x to the nearest hundredth.
%
%  y = ROUNDN(x,n) rounds the input data x at the specified power
%  of tens position.  For example, n = -2 rounds the input data to
%  the 10E-2 (hundredths) position.
%
%  See also ROUND.

% Copyright 1996-2007 The MathWorks, Inc.
% $Revision: 1.9.4.4 $    $Date: 2007/11/09 20:25:18 $
% Written by:  E. Byrns, E. Brown

% Obsolete Syntax
% ---------------
%  [y,msg] = ROUNDN(...) returns the text of any error condition
%  encountered in the output variable msg.
if nargout > 1
    warnObsoleteMSGSyntax(mfilename)
    msg = '';
end

error(nargchk(1, 2, nargin, 'struct'))

if nargin == 1
    n = -2;
end

%  Test for scalar n
assert(isscalar(n), ...
    ['map:' mfilename ':mapError'], 'Scalar accuracy required.')

n = ignoreComplex(n, mfilename, 'n');

%  Compute the exponential factors for rounding at specified
%  power of 10.  Ensure that n is an integer.
factors  = 10 ^ (fix(-n));

%  Set the significant digits for the input data
x = round(x * factors) / factors;

%-----------------------------------------
function warnObsoleteMSGSyntax(func_name)

warning(['map:' func_name ':obsoleteMSGSyntax'],...
    ['Function %s no longer returns error message strings in \noutput argument MSG.' ...
    ' Instead any errors are thrown where they occur. \nYou should remove the last' ...
    ' output argument (MSG) from your call to \n%s in order to avoid this warning.' ...
    ' If you want to handle errors \nyourself, call %s in a try-catch block.'], ...
    upper(func_name),upper(func_name),upper(func_name))
