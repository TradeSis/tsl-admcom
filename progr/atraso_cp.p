{admcab.i}

display "VERIFICANDO PARCELAS CP...".


for each titulo where (modcod = "CP0" or 
                       modcod = "CP1" or 
                       modcod = "CP2" or
                       modcod = "CPN"
                      ) and 
                      titdtven < today and 
                      titsit <> "PAG" and 
                      titsit <> "EXC" and 
                      titdtven >= 01/01/2016 no-lock.

        disp titulo.etbcod clifor titnum titsit modcod titdtven titvlcob.


end.
