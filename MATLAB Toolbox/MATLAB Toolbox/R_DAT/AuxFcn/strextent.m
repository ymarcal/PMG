function [ext, hgt] = strextent(str)
% Calcula o tamanho de um string mostrado com fonte 'MS Sans Serif' tamanho 8 pontos
% Aceita char arrays e cell arrays

if isempty(str)
    ext = 0;
    hgt = 0;
    return
end

% chars = {'A' 7;
%     'Á' 7;
%     'À' 7;
%     'Ã' 7;
%     'Â' 7;
%     'B' 7;
%     'C' 7;
%     'Ç' 7;
%     'D' 8;
%     'E' 7;
%     'É' 7;
%     'Ê' 7;
%     'F' 6;
%     'G' 8;
%     'H' 8;
%     'I' 3;
%     'Í' 3;
%     'J' 5;
%     'K' 7;
%     'L' 6;
%     'M' 9;
%     'N' 8;
%     'O' 8;
%     'Ó' 8;
%     'Ô' 8;
%     'Õ' 8;
%     'P' 7;
%     'Q' 8;
%     'R' 8;
%     'S' 7;
%     'T' 7;
%     'U' 8;
%     'Ú' 8;
%     'V' 7;
%     'W' 11;
%     'X' 7;
%     'Y' 7;
%     'Z' 7;
%     'a' 6;
%     'á' 6;
%     'à' 6;
%     'ã' 6;
%     'â' 6;
%     'b' 6;
%     'c' 6;
%     'ç' 6;
%     'd' 6;
%     'e' 6;
%     'é' 6;
%     'ê' 6;
%     'f' 3;
%     'g' 6;
%     'h' 6;
%     'i' 2;
%     'í' 2;
%     'j' 2;
%     'k' 6;
%     'l' 2;
%     'm' 8;
%     'n' 6;
%     'o' 6;
%     'ó' 6;
%     'õ' 6;
%     'ô' 6;
%     'p' 6;
%     'q' 6;
%     'r' 3;
%     's' 5;
%     't' 3;
%     'u' 6;
%     'ú' 6;
%     'v' 6;
%     'w' 8;
%     'x' 5;
%     'y' 5;
%     'z' 5;
%     '0' 6;
%     '1' 6;
%     '2' 6;
%     '3' 6;
%     '4' 6;
%     '5' 6;
%     '6' 6;
%     '7' 6;
%     '8' 6;
%     '9' 6;
%     '_' 6;
%     ' ' 3;
%     '.' 3;
%     ',' 3;
%     ':' 3;
%     ';' 3;
%     '+' 6;
%     '-' 3;
%     '*' 4;
%     '/' 5;
%     '\' 5;
%     '|' 2;
%     '^' 6;
%     '=' 6;
%     '''' 2;
%     '"' 5;
%     '²' 3;
%     '³' 3;
%     '?' 6;
%     '!' 3;
%     '@' 11;
%     '#' 7;
%     '$' 6;
%     '%' 8;
%     '&' 6;
%     '°' 4;
%     '(' 3;
%     ')' 3;
%     '[' 3;
%     ']' 3;
%     '{' 4;
%     '}' 4;
%     '<' 6;
%     '>' 6};

charlist = 'AÁÀÃÂBCÇDEÉÊFGHIÍJKLMNOÓÔÕPQRSTUÚVWXYZaáàãâbcçdeéêfghiíjklmnoóõôpqrstuúvwxyz0123456789_ .,:;+-*/\|^=''"²³?!@#$%&°()[]{}<>';
extlist  = [7 7 7 7 7 7 7 7 8 7 7 7 6 8 8 3 3 5 7 6 9 8 8 8 8 8 7 8 8 7 7 8 8 7 11 7 7 7 6 6 6 6 6 6 6 6 6 6 6 6 3 6 6 2 2 2 6 2 8,...
        6 6 6 6 6 6 6 3 5 3 6 6 6 8 5 5 5 6 6 6 6 6 6 6 6 6 6 6 3 3 3 3 3 6 3 4 5 5 2 6 6 2 5 3 3 6 3 11 7 6 8 6 4 3 3 3 3 4 4 6 6];

if ischar(str)
    
    for n = 1:size(str,1)
        ext(n,1) = 0;
        for m = 1:size(str,2)
            ind = findstr(str(n,m),charlist);
            if ~isempty(ind);
                ext(n,1) = ext(n,1) + extlist(ind);
            else
                ext(n,1) = ext(n,1) + max(extlist);
            end
        end
    end
    hgt = 13*size(str,1)+7;
    
elseif iscell(str)
    
    [Nrow, Ncol] = size(str);
    str = str(:);
    
    for n = 1:length(str)
        ext(n,1) = 0;
        for m = 1:length(str{n})
            ind = findstr(str{n}(m),charlist);
            if ~isempty(ind);
                ext(n,1) = ext(n,1) + extlist(ind);
            else
                ext(n,1) = ext(n,1) + max(extlist);
            end
        end
    end
    
    ext = reshape(ext,Nrow, Ncol);
    hgt = 13*length(str)+7;

else
    ext = [];
end