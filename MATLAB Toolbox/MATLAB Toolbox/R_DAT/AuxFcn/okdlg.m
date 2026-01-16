function varargout = okdlg(Message,Title,CreateMode)
% Cria mensagem de "OK"

if nargin<3
    CreateMode = 'normal';
end
if nargin<2
    Title = '';
end
if ~nargin
    Message = 'Whatever you were doing has been completed successfully!';
end

load okicondata.mat;

bg = find(IconMap(:,1)==1 & IconMap(:,2)==0 & IconMap(:,3)==1);
if length(bg) == 1
    IconMap(bg,:) = get(0,'DefaultUicontrolBackgroundColor');
end

h = msgbox(Message,Title,'custom',IconData,IconMap,CreateMode);

drawnow;

if nargout == 1
    varargout{1} = h;
end
