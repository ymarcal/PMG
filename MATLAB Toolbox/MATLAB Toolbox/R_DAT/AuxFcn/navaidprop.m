function [Ch,Ft,Wt,Sz,Co] = navaidprop(typ)
% Fornece as propriedades para plotagem dos Nav Aids
% char, fontname, fontweight, fontsize, color

typelist = {'NDB'      ,'VOR'      ,'VOR/DME'  ,'DME'      ,'FIX'      ,'AFLD'  };
charlist = {'¤'        ,'²'        ,'ª'        ,'¨'        ,'©'        ,'Ø'     };
fontlist = {'Wingdings','Wingdings','Wingdings','Wingdings','Wingdings','Arial' };
wghtlist = {'Normal'   ,'Bold'     ,'Normal'   ,'Normal'   ,'Normal'   ,'Normal'};
sizelist = [ 16        , 18        , 20        , 12        , 20        , 14     ];

k = strmatch(typ,typelist,'exact');

if length(k) == 1
    Ch = charlist{k};
    Ft = fontlist{k};
    Sz = sizelist(k);
    Wt = wghtlist{k};
    Co = [0 .5 1];
else
    Ch = '?';
    Ft = 'Arial';
    Sz = 14;
    Wt = 'Normal';
    Co = [0 .5 1];
end
