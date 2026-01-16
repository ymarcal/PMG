function jpg = rgb2jpg(rgb)
% Converte uma imagem RGB em um vetor uint8 com codificaçao JPEG

imwrite(rgb,[tempdir 'jpeg_temp_file.jpg'],'jpg');
fid = fopen([tempdir 'jpeg_temp_file.jpg'],'r');
jpg = uint8(fread(fid));
fclose(fid);
delete([tempdir 'jpeg_temp_file.jpg']);
