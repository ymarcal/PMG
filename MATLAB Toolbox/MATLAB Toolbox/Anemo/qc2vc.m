% qc2vc  calcula a veloc. calibrada (Kt) correspondente a um valor de
%        qc(mbar). Para Vc > 661.5 Kt e usada uma aproximacao dada no
%        manual da atm padrao.
%
function vc=qc2vc(qc)
ind=find(qc < 0);
if( ~isempty(ind))
  [l,c]=size(ind);
  qc(ind)=zeros(l,c);
end  
vc=661.47 .*(5 .*((qc./1013.25+1).^.28571-1)).^.5;
a1=vc>=661.47;
vc=vc+a1.*(257.97 .*(vc./661.47-1).^2.55);
%




