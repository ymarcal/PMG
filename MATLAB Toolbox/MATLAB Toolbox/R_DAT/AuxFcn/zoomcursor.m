function [M, p] = zoomcursor
% Fornece icone de "lupa" para uso de cursor de zoom

M = [
  NaN NaN NaN NaN   1   1   1   1 NaN NaN NaN NaN NaN NaN NaN NaN
  NaN NaN   1   1 NaN NaN NaN NaN   1   1 NaN NaN NaN NaN NaN NaN
  NaN   1 NaN   2   2   2 NaN NaN NaN NaN   1 NaN NaN NaN NaN NaN
  NaN   1   2   2 NaN NaN NaN NaN NaN NaN   1 NaN NaN NaN NaN NaN
  1   NaN   2 NaN NaN NaN NaN NaN NaN NaN NaN   1 NaN NaN NaN NaN
  1   NaN   2 NaN NaN NaN NaN NaN NaN NaN NaN   1 NaN NaN NaN NaN
  1   NaN NaN NaN NaN NaN NaN NaN NaN   2 NaN   1 NaN NaN NaN NaN
  1   NaN NaN NaN NaN NaN NaN NaN   2   2 NaN   1 NaN NaN NaN NaN
  NaN   1 NaN NaN NaN NaN NaN NaN   2 NaN   1 NaN NaN NaN NaN NaN
  NaN   1 NaN NaN NaN NaN   2   2   2 NaN   1 NaN NaN NaN NaN NaN
  NaN NaN   1   1 NaN NaN NaN NaN NaN   1   1   1 NaN NaN NaN NaN
  NaN NaN NaN NaN   1   1   1   1   1   2   1   1   1 NaN NaN NaN
  NaN NaN NaN NaN NaN NaN NaN NaN NaN   1   2   1   1   1 NaN NaN
  NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN   1   2   1   1   1 NaN
  NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN   1   2   1   1 NaN
  NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN   1   1 NaN NaN
];

p = [6 6];