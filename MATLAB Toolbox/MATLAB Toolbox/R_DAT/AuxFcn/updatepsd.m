function updatepsd
% Funçao que atualiza a apresentaçao do PSD

hf = gcf;

tempdata = getappdata(hf,'tempdata');

Y  = tempdata{1};
Fs = tempdata{2};
hp = tempdata{3};
hw = tempdata{4};
hr = tempdata{5};
NFFT_list = tempdata{6};
OVLP_list = tempdata{7};
WNDW_list = tempdata{8};
H_NFFT = tempdata{9};
H_OVLP = tempdata{10};
H_WNDW = tempdata{11};

try
    
    NFFT = min(length(Y),NFFT_list(get(H_NFFT,'Value')));
    OVLP = round(OVLP_list(get(H_OVLP,'Value'))/100 * NFFT);
    WNDW = feval(WNDW_list{get(H_WNDW,'Value'),2},NFFT);
    
    [Px, F] = psd(Y,NFFT,Fs,WNDW,OVLP);
    
    nMax = find(Px==max(Px));
    
    if isempty(nMax)
        resstr = '';
    else
        resstr = {'Máximo:',[num2str(10*log10(Px(nMax))) ' dB'],[num2str(F(nMax)) ' Hz']};
    end
    
catch
    beep; uiwait(errordlg(lasterr,'Erro','modal')); drawnow;
    F  = NaN;
    Px = NaN;
    WNDW = NaN*WNDW;
    resstr = '';
end

set(hp,'XData',F,'YData',10*log10(Px));
set(hw,'XData',linspace(0,1,length(WNDW)),'YData',WNDW);
set(hr,'String',resstr);
