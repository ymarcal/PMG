function fname = SetFileExtension(fname,ext)
% Acrescenta ou substitui extensao de 'fname' por 'ext'
% O ponto em 'ext' é opcional

ix = find(fname=='.');
if ~isempty(ix)
    fname(ix(end):end) = [];
end

ext(ext=='.') = [];

fname = [fname '.' ext];
