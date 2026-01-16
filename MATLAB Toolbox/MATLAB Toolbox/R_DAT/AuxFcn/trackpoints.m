function [y2, yshift, ybase] = trackpoints(x, y, p, method, extrap)
% Function that adjusts a curve defined by the vectors x and y
% so that it intercepts a series of control points defined in p
% Syntax: y2 = curveshift(x, y, p, method)
%   x and y must be vectors (row or column)
%   x must be monotonic (ascending)
%   p must be a 2-column matrix with [x y] pairs
%   method is the interpolation method for the trackpoints ('nearest' | ['linear'] | 'spline' | 'cubic')
%   extrap is the extrapolation method for the trackpoints (['zero'] | 'nearest' | 'linear')
%
%   y2 is the corrected output, the same size as y
%     ybase is the base points for correction and ...
%     yshift is the shifted points, such as dy = yshift-ybase and y2 = y+dy

if nargin == 3
    method = 'linear';
    extrap = 'zero';
elseif nargin == 4
    extrap = 'zero';
end

% Check input formats
if isempty(y)
    y2 = [];
    ybase = [];
    return
end
if size(x,1) ~= 1 && size(x,2) ~= 1
    error('x must be a vector');
end
if size(y,1) ~= 1 && size(y,2) ~= 1
    error('y must be a vector');
end
if ~all(size(x) == size(y));
    error('x and y must have the same length and orientation')
end
if length(x)<2
    error('x must have at least 2 elements');
end
if length(y)<2
    error('y must have at least 2 elements');
end
if size(p,2) ~= 2
    error('p must be a 2-column matrix');
end

% Check for monotonic x (ascending)
if ~all(diff(x)>=0)
    error('x must be monotonic ascending');
end

% Adjust order of control points
if all(diff(x)>0)
    p = sortrows(p,1);
end

% Verify control-points inside data interval (only 1 pt outside each end)
in = intersect(find(p(:,1)>=x(1)),find(p(:,1)<=x(end)));
if isempty(in)
    ybase = y;
    yshift = y;
    y2 = y;
    return
end
if in(1) > 1
    in = [in(1)-1; in];
end
if in(end) < size(p,1)
    in = [in; in(end)+1];
end
p = p(in,:);

% Check end-points
p1 = [];
p2 = [];
if p(1,1) > x(1)
    switch extrap
        case 'zero'
            p1 = [x(1) y(1)];
        case 'nearest'
            p1 = [x(1) y(1)+p(1,2)-interp1(x,y,p(1,1))];
        case 'linear'
            if size(p,1) == 1
                p1 = [x(1) y(1)+p(1,2)-interp1(x,y,p(1,1),'linear','extrap')];
            else
                p1 = [x(1) interp1(p(:,1),p(:,2),x(1),'linear','extrap')];
            end
    end
end
if p(end,1) < x(end)
    switch extrap
        case 'zero'
            p2 = [x(end) y(end)];
        case 'nearest'
            p2 = [x(end) y(end)+p(end,2)-interp1(x,y,p(end,1))];
        case 'linear'
            if size(p,1) == 1
                p2 = [x(end) y(end)+p(end,2)-interp1(x,y,p(end,1),'linear','extrap')];
            else
                p2 = [x(end) interp1(p(:,1),p(:,2),x(end),'linear','extrap')];
            end
    end
end
p = [p1; p; p2];

ybase  = interp1(p(:,1), interp1(x, y, p(:,1), 'linear', 'extrap'), x, method);
yshift = interp1(p(:,1), p(:,2), x, method);
dy = yshift-ybase;

y2 = y+dy;
