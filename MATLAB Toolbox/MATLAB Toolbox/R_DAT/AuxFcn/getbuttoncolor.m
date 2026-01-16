function bgc = getbuttoncolor(h)
% Fornece a cor de fundo adequada para os botoes e
% altera a aparência dos botões da versão 7 para a versão 6

if getver >= 7
    
    bgc = min(get(0,'DefaultUIControlBackgroundColor')+.04,1);
    
    if nargin
        set([findobj(h,'Style','pushbutton'); findobj(h,'Style','togglebutton')],'BackgroundColor',bgc);
    end
    
else
    
    bgc = get(0,'DefaultUIControlBackgroundColor');
    
end