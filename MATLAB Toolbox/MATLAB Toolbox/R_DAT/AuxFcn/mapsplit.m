function layerscale = mapsplit(DAT, COD, ktype, scale)
% Segmenta o mapa em n x m setores

% step = scale * .025;
% 
% % Limites dos dados
% minlat = min(DAT(:,1));
% maxlat = max(DAT(:,1));
% minlon = min(DAT(:,2));
% maxlon = max(DAT(:,2));
% 
% % Grade abrangendo os dados
% [ilat, ilon] = mapgrid(scale, [minlat maxlat], [minlon maxlon]);
% 
% % Centro dos dados
% ilatc = ilat(round(length(ilat)/2));
% ilonc = ilon(round(length(ilon)/2));
% 
% % Nova grade potencia-de-2
% rng = max(.01,max([maxlat-minlat maxlon-minlon]));
% rng = ceil(rng/step)*step;
% ex  = ceil(log2(rng/step));
% rng = step*2^ex;
% rng = ceil(rng/2)*2;
% 
% ilat2 = ilatc-rng/2 : step : ilatc+rng/2-step;
% ilon2 = ilonc-rng/2 : step : ilonc+rng/2-step;
% 
% % Setor inicial
% dat0 = {};
% dat0{1} = DAT;
% step0 = rng;
% ilat0 = ilat2(1);
% ilon0 = ilon2(1);
% 
% % close all
% % figure('Renderer','zbuffer')
% % plot(DAT(:,2),DAT(:,1));
% % hold;
% % axis equal;
% 
% h = waitbar(0,char({['Segmentando mapa na escala de ' num2str(scale) ' NM.'],['?:??:??s restantes.']}),...
%     'Name','0.0% concluído','Renderer','zbuffer','Pointer','watch','WindowStyle','modal');
% K = sum(4.^(1:ex));
% k = 0;
% t0 = clock;
% 
% % Segmentaçao progressiva
% for n = 1:ex
%     
%     Nv = size(dat0,1);
%     Nh = size(dat0,2);
%     dat1 = cell(2*Nv,2*Nh);
%     
%     for nv = 1:2*Nv
%         for nh = 1:2*Nh
%             
%             if isempty(dat0{ceil(nv/2),ceil(nh/2)})
%                 dat1{nv,nh} = [];
%                 
%             else
%                 
% %                 plot(ilon0(ceil(nh/2))+~rem(nh,2)*step0/2 + step0/2*[0 1 1 0 0],...
% %                     ilat0(ceil(nv/2))+~rem(nv,2)*step0/2  + step0/2*[0 0 1 1 0] ,'-r');
% %                 drawnow
%                 
%                 [Y, X, Iin] = mapcut(dat0{ceil(nv/2),ceil(nh/2)}(:,1),dat0{ceil(nv/2),ceil(nh/2)}(:,2),...
%                     ilat0(ceil(nv/2))+~rem(nv,2)*step0/2 + [0 step0/2],...
%                     ilon0(ceil(nh/2))+~rem(nh,2)*step0/2 + [0 step0/2],     ktype,0);
%                 
%                 if isempty(X)
%                     dat1{nv,nh} = [];
%                 else
%                     dat1{nv,nh} = [Y X];
%                 end
%             end
%             
%             k = k+1;
%             Tel = etime(clock,t0);         % Elapsed time
%             Pd = k/K;                      % Percent done
%             Trem = round(Tel*(1-Pd)/Pd);   % Remaining time
%             hh = fix(Trem/3600);
%             mm = fix(Trem/60)-hh*60;
%             ss = rem(Trem,60);
% 
%             if ishandle(h)
%                 try
%                     waitbar(Pd,h,char({['Segmentando mapa na escala de ' num2str(scale) ' NM.'],[num2str(hh) ':' num2str(mm,'%02d') ':' num2str(ss,'%02d') 's restantes.']}));
%                     set(h,'Name',[num2str(100*Pd,'%1.1f') '% concluído']);
%                 end
%             else
%                 layerscale = [];
%                 uiwait(warndlg('Operação cancelada.','Aviso','modal')); drawnow;
%                 return
%             end
%             
%         end
%     end
%     dat0 = dat1;
%     step0 = step0/2;
%     ilat0 = ilat0(1) : step0 : ilat0(1)+rng-step0;
%     ilon0 = ilon0(1) : step0 : ilon0(1)+rng-step0;
%     
% end
% 
% if ishandle(h), pause(.4); delete(h); drawnow; end
% 
% cod0 = {};
% 
% % Transformar em 'single'
% for nv = 1:size(dat0,1);
%     for nh = 1:size(dat0,2);
%         dat0{nv,nh} = single(dat0{nv,nh});
%     end
% end
% 
% % Data triming
% exc = find(ilat0 < ilat(1) | ilat0 > ilat(end));
% dat0(exc,:) = [];
% exc = find(ilon0 < ilon(1) | ilon0 > ilon(end));
% dat0(:,exc) = [];
% 
% % Atribuiçao final
% layerscale.ilat = ilat;
% layerscale.ilon = ilon;
% layerscale.data = dat0;
% layerscale.code = cod0;
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% return
% OLD CODE --------------------------------------------------------------------------

pack;

step = scale * .025;

minlat = min(DAT(:,1));
maxlat = max(DAT(:,1));
minlon = min(DAT(:,2));
maxlon = max(DAT(:,2));

[ilat, ilon] = mapgrid(scale, [minlat maxlat], [minlon maxlon]);

dat = cell(length(ilat),length(ilon));
if isempty(COD)
    cod = {};
else
    cod = cell(length(ilat),length(ilon));
end

h = waitbar(0,char({['Segmentando mapa na escala de ' num2str(scale) ' NM.'],'?:??:??s restantes.'}),...
    'Name','0.0% concluído','Renderer','zbuffer','Pointer','watch','WindowStyle','modal');

try
    k = 0;
    t0 = clock;
    for n = 1:length(ilat)
        % Segmentaçao em latitude
        if n == 5
            1
        end
        [Y, X, Iin] = mapcut(DAT(:,1),DAT(:,2),[ilat(n) ilat(n)+step],[minlon maxlon],ktype,0);
        CODn = COD(Iin);
        for m = 1:length(ilon)
            % Segmentaçao em longitude
            if ~isempty(X)
                if n == 5 && m == 17
                    1
                end
                [y, x, Iin] = mapcut(Y,X,[ilat(n) ilat(n)+step],[ilon(m) ilon(m)+step],ktype,0);
            else
                x   = [];
                y   = [];
                Iin = [];
            end
            if isempty(x)
                dat{n,m} = single([]);
            else
                dat{n,m} = single([y x]);
            end
            if ~isempty(COD);
                cod{n,m} = CODn(Iin);
            end
            
            k = k+1;
            Tel = etime(clock,t0);               % Elapsed time
            Pd = k/(length(ilat)*length(ilon));  % Percent done
            Trem = round(Tel*(1-Pd)/Pd);         % Remaining time
            hh = fix(Trem/3600);
            mm = fix(Trem/60)-hh*60;
            ss = rem(Trem,60);
            
            if ishandle(h)
                try
                    waitbar(Pd,h,char({['Segmentando mapa na escala de ' num2str(scale) ' NM.'],[num2str(hh) ':' num2str(mm,'%02d') ':' num2str(ss,'%02d') 's restantes.']}));
                    set(h,'Name',[num2str(100*Pd,'%1.1f') '% concluído']);
                end
            else
%                 layerscale = [];
%                 uiwait(warndlg('Operação cancelada.','Aviso','modal')); drawnow;
%                 return
            end
        end
    end
    if ishandle(h), pause(.4); delete(h); drawnow; end
catch
    if ishandle(h), pause(.4); delete(h); drawnow; end
    beep; uiwait(errordlg(lasterr,'Erro','modal')); drawnow;  
    layerscale = [];
    return
end

layerscale.ilat = ilat;
layerscale.ilon = ilon;
layerscale.data = dat;
layerscale.code = cod;
