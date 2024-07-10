def input parameter p-etbcod like estab.etbcod.
def input parameter p-dti as date.
def input parameter p-dtf as date.
def shared temp-table tt-contrato like contrato.

def var vlentr as dec.
def var vlpres as dec.
def var vljuro as dec.
def var vtotal as dec.
def var vicms as dec.
def var totecf as dec.
def var vlprazo as dec.
def var vlvist as dec.
def var vdata as date.
def var tprazo as dec.
def var tvist as dec.
def var vlpraz as dec.
def var vind as dec.
def var vper as dec.
def var tt-geral as dec.
def var vdti-1 as date.
def var vdtf-1 as date.
def var vdti-2 as date.
def var vdtf-2 as date.
vdti-1 = p-dti.
vdtf-1 = p-dtf.
vdti-2 = vdtf-1 + 1.
if month(vdtf-1) = 11
then do:
    vdtf-2 = date(02,01,year(vdtf-1) + 1) - 1. 
end.
else if month(vdtf-1) = 12
    then do:
        vdtf-2 = date(03,01,year(vdtf-1) + 1) - 1. 
    end.
    else do:
        vdtf-2 = date(month(vdtf-1) + 3,01,year(vdtf-1)) - 1. 
    end.

for each tt-contrato:
    delete tt-contrato.
end.    
for each estab where estab.etbcod = p-etbcod no-lock.
    for each titold where titold.etbcobra = estab.etbcod and
                      titold.titdtpag >= vdti-2 and
                      titold.titdtpag <= vdtf-2 and
                      titold.titpar = 1  no-lock.
                if titold.titdtemi >= vdti-1 and
                   titold.titdtemi <= vdtf-1
                then.
                else next.   
                if titold.clifor = 1
                then next.
                if titold.titnat = yes
                then next.
                if titold.modcod <> "CRE"
                then next.
                find contrato where 
                        contrato.contnum = int(titold.titnum) no-lock.
                find first contnf where   contnf.etbcod  = contrato.etbcod and
                                    contnf.contnum = contrato.contnum
                                    no-lock.
                create tt-contrato.
                buffer-copy contrato to tt-contrato.
                find first plani where plani.etbcod = contnf.etbcod and
                                 plani.placod = contnf.placod and
                                 plani.serie = "V"
                                 no-lock no-error.
                if avail plani
                then tt-contrato.vltotal = plani.platot.
                vtotal = vtotal + tt-contrato.vltotal.
                disp vtotal.
                pause 0.
    end.
    run venda-prazo.
end.
vind = (tprazo / vtotal) * 100.
/*disp vtotal tprazo tvist vind.
*/
for each tt-contrato:
    tt-contrato.vltotal = (tt-contrato.vltotal * vind) / 100 .
    tt-geral = tt-geral + tt-contrato.vltotal.
end.    
/*disp tt-geral.
*/
procedure venda-prazo:
    do vdata = vdti-1 to vdtf-1.
        vlvist = 0.
        vlpraz = 0.
        totecf = 0.
        for each plani use-index pladat 
                   where plani.movtdc = 5 and
                         plani.etbcod = estab.etbcod and
                         plani.pladat = vdata
                         no-lock.

            if plani.crecod = 1
            then do:
                vlvist = vlvist + plani.platot.
            end.
            else vlpraz = vlpraz  + plani.platot.
                      
        end.                    
        for each mapctb where mapctb.etbcod = estab.etbcod and
                                  mapctb.datmov = vdata
                                    no-lock.

                if mapctb.ch2 = "E"                 
                then next.
                 
                totecf = totecf + 
                        (mapctb.t01 + 
                         mapctb.t02 + 
                         mapctb.t03 +
                         mapctb.vlsub).
            
        end.
        if vlpraz > 0
        then do:
            if vlvist < vlpraz
            then do:
                    vlvist = (vlvist / vlpraz) * totecf.
                    vlpraz = totecf - vlvist.
            end.
            else do:
                    vlpraz = (vlpraz / vlvist) * totecf.
                    vlvist = totecf - vlpraz.
            end.
        end.
        else vlvist = totecf.

        tprazo = tprazo + vlpraz.
        tvist = tvist + vlvist.
        vlpraz = 0.
        vlvist = 0.
        totecf = 0.
    end.

end procedure.
