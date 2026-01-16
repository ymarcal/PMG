function va_kt = zpvc2va(zp_ft,vc_kt,delta_ISA)

% Calcula va (kt) dado zp (ft), vc (kt) e delta ISA
    R = 287.053;
    gamma = 1.4;
    ta_K = zp2ta(zp_ft,delta_ISA);
    a_ms = sqrt(gamma.*R.*ta_K);
    M = vczp2m(vc_kt,zp_ft);
    va_ms = a_ms .* M;
    va_kt = va_ms .* 1.944;    

end