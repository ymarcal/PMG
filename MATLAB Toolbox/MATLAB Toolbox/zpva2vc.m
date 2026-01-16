function vc_kt = zpva2vc(zp_ft,va_kt,isamais)

% Calcula vc (kt) dado zp (ft), va (kt) e delta ISA
    R = 287.053;
    gamma = 1.4;
    ta_K = zp2ta(zp_ft,isamais);
    va_ms = va_kt ./1.944;
    a_ms = sqrt(gamma.*R.*ta_K);
    M = va_ms ./ a_ms;
    vc_kt = zpm2vc(zp_ft,M);
   
end