/* 26042021 helio */

def input param vdtreffim as date.

def var vdtrefini as date.
vdtrefini = date(month(vdtreffim),01,year(vdtreffim)).

def var vdt as date.
pause 0 before-hide.
message "MES" month(vdtrefini) year(vdtreffim).
pause 0 before-hide.


for each ctbposhiscart where dtref = vdtrefini and dtrefsaida = vdtrefini.
    if ctbposhiscart.operacaoentrada = "TROCA" or 
       ctbposhiscart.operacaosaida   = "TROCA" 
    then next.
               
    delete ctbposhiscart.
end. 
for each ctbposhiscart where dtref = vdtrefini and dtrefsaida = ?.
        if ctbposhiscart.operacaoentrada = "TROCA" or 
       ctbposhiscart.operacaosaida   = "TROCA" 
    then next.
    delete ctbposhiscart.
end. 
for each ctbposhiscart where dtref < vdtrefini and dtrefsaida = vdtrefini.
    if ctbposhiscart.operacaosaida   = "TROCA" 
    then next.

    dtrefsaida = ?.
    valorsaida = 0.
    operacaosaida = "".
end.
for each ctbposcart where dtref = vdtrefini.
    delete ctbposcart.
end.    
  
   
for each estab no-lock.
    disp estab.etbcod.

    for each modal where modal.modcod = "cre" or modal.modcod = "CP0" or modal.modcod = "CP1" or modal.modcod = "CPN" no-lock.
        do vdt = vdtrefini to vdtreffim.
            disp vdt.
            for each titulo where titnat = no and titulo.titdtemi = vdt and titulo.etbcod = estab.etbcod and titulo.modcod = modal.modcod no-lock.
                if titulo.titdtven = ? then next.
                if titulo.titsit = "LIB" or
                   titulo.titsit = "PAG"
                then.
                else next.   
                run finct/gerahisposcart.p   
                    (recid(titulo),  
                     "emissao",  
                     vdt,
                     titulo.titvlcob,
                     titulo.cobcod,
                     titulo.cobcod). 
                
            end.
            for each titulo where titnat = no and titulo.titdtpag = vdt and titulo.etbcod = estab.etbcod and titulo.modcod = modal.modcod no-lock.
                if titulo.titdtven = ?          then next.
                if  titulo.titsit <> "PAG"
                then next.
                run finct/gerahisposcart.p   
                    (recid(titulo),  
                     "pagamento",  
                     vdt,
                     titulo.titvlcob,
                     titulo.cobcod,
                     titulo.cobcod). 
                
             end. 
        end.

    end.
end.
message "gerando saldos...".
run finct/montasaldo.p (input  vdtreffim).
message "gerando saldos por produto...".
run finct/montasaldoprod.p (input  vdtreffim).
hide message no-pause.

