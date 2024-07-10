{admcab.i}
def var varquivo as char format "x(20)".
def var totecf like plani.platot.
def var i as i.
def var vetbi like estab.etbcod.
def var vetbf like estab.etbcod.
def var totvis like titulo.titvlcob.
def var totpra like titulo.titvlcob.
def var totent like titulo.titvlcob.
def var totjur like titulo.titjuro.
def var totpre like titulo.titvlcob.
def var totpla like titulo.titvlcob.
def var v-perc as dec.
def var totold like plani.platot.
def var vsoma  like plani.platot.
def var vdimi  like plani.platot.

def var x as i.
def var vcx as int.
def var totglo like globa.gloval.
def var vlpres      like plani.platot.
def var vcta01      as char format "99999".
def var vcta02      as char format "99999".
def var vdata       like titulo.titdtemi.
def var vpago       like titulo.titvlpag.
def var vdesc       like titulo.titdesc.
def var vjuro       like titulo.titjuro.
def var sresumo     as   log format "Resumo/Geral" initial yes.
def var wpar        as int format ">>9" .
def var vcxacod     like titulo.cxacod.
def var vmodcod     like titulo.modcod.
def var vlvist      like plani.platot.
def var vlpraz      like plani.platot.
def var vlentr      like plani.platot.
def var vljuro      like plani.platot.
def var vldesc      like plani.platot.
def var vlpred      like plani.platot.
def var vljurpre    like plani.platot.
def var vlsubtot    like plani.platot.
def var vtot        like plani.platot.
def var vnumtra     like plani.platot.
def var vdtexp      as   date format "99/99/9999".
def var vdtimp      as   date  format "99/99/9999".
def var vdt1        as   date  format "99/99/9999". 
def var vdt2        as   date  format "99/99/9999".
def stream tela.

def temp-table wf-atu
             field imp      as date
             field exporta  as date.

def buffer bimporta for importa.
def buffer bexporta for exporta.

output stream tela to terminal.

form wf-atu.imp label "Falta Importar do CPD"
     wf-atu.exporta label "Falta Exportar para CPD"
     with frame fatu centered no-box down.

repeat with 1 down side-label width 80 row 4 color blue/white:
    update vetbi label "Filial" colon 20
           vetbf label "Filial".
    x = 0.
    totvis = 0.
    totpra = 0.
    totjur = 0.
    totpre = 0.
    totent = 0.

    update vdt1 label "Data Inicial" colon 20
           vdt2 label "Data Final" colon 20.
        

    for each estab where estab.etbcod >= vetbi and
                         estab.etbcod <= vetbf no-lock:

        vlpres = 0.
        vljuro = 0.
        vlentr = 0.
        totpra = 0.
        totvis = 0.
        totpla = 0.
        totold = 0.

        assign vcta01 = string(estab.prazo,"99999")
               vcta02 = string(estab.vista,"99999").
        
        do vdata = vdt1 to vdt2:
            vlvist = 0.
            vlpraz = 0.
            totecf = 0.
            for each plani use-index pladat 
                                     where plani.movtdc = 5 and
                                           plani.etbcod = estab.etbcod and
                                           plani.pladat = vdata no-lock.

                if plani.crecod = 1
                then vlvist = vlvist + plani.platot.
                if plani.crecod = 2
                then do:
                    
                    
                    vlpraz = vlpraz + plani.platot.
                    totpla = totpla + plani.platot.
                    
                    
                end.    
                

            end.
            
            for each serial where serial.etbcod = estab.etbcod and
                                  serial.serdat = vdata no-lock.
            
                totecf = totecf + (serial.icm12 + serial.icm17 + serial.sersub).
            
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
            
            totvis = totvis + vlvist.
            totpra = totpra + vlpraz.
            
        end.

        if totpra = 0 and
           totvis = 0 and
           vljuro = 0 and
           vlpres = 0 and
           vlentr = 0
        then next.
        
        v-perc =  (( 100 - ((totpra * 100) / totpla)) / 100).
        
        totold = 0.
        vsoma  = 0.
        vdimi  = 0.
        do vdata = vdt1 to vdt2:
            for each plani use-index pladat 
                                where plani.movtdc = 5 and
                                      plani.etbcod = estab.etbcod and
                                      plani.pladat = vdata no-lock.

                if plani.crecod = 2
                then do:
                    find plaold where plaold.etbcod = plani.etbcod and
                                      plaold.placod = plani.placod and
                                      plaold.serie  = plani.serie no-error.
                    if not avail plaold
                    then do transaction:
                                      
                        create plaold.
                        {plani.i plaold plani}.
                
                        plaold.platot = plaold.platot - 
                                        (plaold.platot * v-perc).
                    end.
                    
                    totold = totold + plaold.platot.
                
                end.    

            end.
        
        end.    
        if totpra > totold
        then vsoma = totpra - totold.
        else vdimi = totold - totpra.
        
        find first plaold use-index pladat 
                                where plaold.movtdc = 5 and
                                      plaold.etbcod = estab.etbcod and
                                      plaold.pladat >= vdt1 and
                                      plaold.pladat <= vdt2 no-error.
                                      
        if avail plaold
        then do transaction:
            plaold.platot = plaold.platot + vsoma - vdimi.
        end.
        totold = 0.
        do vdata = vdt1 to vdt2:
            for each plaold use-index pladat 
                                where plaold.movtdc = 5 and
                                      plaold.etbcod = estab.etbcod and
                                      plaold.pladat = vdata no-lock.

                totold = totold + plaold.platot.
                
            end.    

        end.    

        

        
        
        
        display estab.etbcod column-label "Filial"
                totpra(total)  column-label "Venda Prazo" 
              /*  totpla(total)
                ( 100 - ((totpra * 100) / totpla)) format ">>9.99999"
                totold(total) column-label "Venda Alterada" */
                    with frame f3 down width 80.
    end.

end.
