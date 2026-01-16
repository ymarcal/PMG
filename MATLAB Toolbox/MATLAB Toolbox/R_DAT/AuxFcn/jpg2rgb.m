function rgb = jpg2rgb(jpg)
% Converte um vetor uint8 com codificaçao JPEG em imagem RGB

fid = fopen([tempdir 'jpeg_temp_file.jpg'],'w');
fwrite(fid,jpg);
fclose(fid);
rgb = imread([tempdir 'jpeg_temp_file.jpg']);
delete([tempdir 'jpeg_temp_file.jpg']);
