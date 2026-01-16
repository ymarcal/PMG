function out = errorchk
% Funçao que verifica se houve esgotamento de memória ou erro de execuçao

[err_msg, err_id] = lasterr;

if ~isempty(err_msg)
    out = 1;
    if strcmp(err_id,'MATLAB:nomem')
        beep; errordlg({'Não houve memória suficiente para realizar a operação.',...
                'Libere mais espaço ou reduza o arquivo de trabalho.',' ',...
                '                             ATENÇÃO:',...
                'A matriz de dados pode ter sido corrompida, portanto',...
                'é altamente recomendado fechar, reiniciar o R_DAT',...
                'e continuar a partir do último arquivo salvo.'},'Erro','modal'); drawnow;
    else
        beep; errordlg({err_id,err_msg,'','Favor reportar este erro ao programador responsável,',...
                'descrevendo as circunstâncias em que o mesmo ocorreu.'},'Erro','modal'); drawnow;
    end
        lasterr('');
else
    out = 0;
end
