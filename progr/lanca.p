{admcab.i}
def stream stela.
def var totecf like plani.platot.
def var i as i.
def var vetbcod like estab.etbcod.
def var vetbf like estab.etbcod.

def var totavi like titulo.titvlcob.
def var totapr like titulo.titvlcob.
def var totent like titulo.titvlcob.
def var totjur like titulo.titjuro.
def var totpre like titulo.titvlcob.

def var vlpres      like plani.platot.
def var vcta01      as char format "99999".
def var vcta02      as char format "99999".
def var vdata       like titulo.titdtemi.
def var vpago       like titulo.titvlpag.
def var vdesc       like titulo.titdesc.
def var vjuro       like titulo.titjuro.
def var vmodcod     like titulo.modcod.
def var vlvist      like plani.platot.
def var vlpraz      like plani.platot.
def var vlentr      like plani.platot.
def var vljuro      like plani.platot.
def var vldesc      like plani.platot.
def var vlpred      like plani.platot.
def var vldev       like plani.platot.
def var vldevvis    like plani.platot.
def var vljurpre    like plani.platot.
def var vlsubtot    like plani.platot.
def var vtot        like plani.platot.
def var ct-vist     as   int.
def var ct-praz     as   int.
def var ct-entr     as   int.
def var ct-pres     as   int.
def var ct-juro     as   int.
def var ct-desc     as   int.
def var vdt1        as   date  format "99/99/9999". 
def var vdt2        as   date  format "99/99/9999".
def var vlote       as char format "xxxx".
def var tot-lanca like plani.platot.
def stream tela.
def temp-table tt-lanca
    field deb  as int format "99999"
    field cre  as int format "99999"  
    field data like plani.pladat 
    field val  as dec format ">,>>>,>>9.99" 
    field his  as int format "999". 
        


repeat with 1 down side-label width 80 row 4 color blue/white:
    
    update vetbcod colon 20 label "Filial".
    if vetbcod = 0
    then display "GERAL" @ estab.etbnom no-label.
    else do:
        find estab where estab.etbcod = vetbcod no-lock.
        disp estab.etbnom no-label.
    end.
    update vdt1 label "Data Inicial" colon 20
           vdt2 label "Data Final" 
           vlote label "Lote" colon 20.
   
    for each tt-lanca:
        delete tt-lanca.
    end.

    output stream stela to terminal. 
    
    if vetbcod = 0
    then output to value("m:\" + string(00,"99")).
    else output to value("m:\" + string(estab.etbcod,">>9")).

    for each estab where if vetbcod = 0
                         then true
                         else estab.etbcod = vetbcod no-lock:
    
    
        for each tt-lanca:
            delete tt-lanca.
        end.
        
    
    
        assign  vlpraz  = 0 vlvist  = 0 vlentr  = 0 vljuro  = 0 
                vldesc  = 0 vldevvis = 0 vlpres = 0
                ct-pres = 0 ct-juro = 0 ct-desc = 0 ct-vist = 0
                ct-praz = 0 vlpred  = 0 vljurpre = 0 
                totecf = 0.



        totavi = 0.
        totapr = 0.
        totjur = 0.
        totpre = 0.
        totent = 0.


    
        do vdata = vdt1 to vdt2:
            display stream stela estab.etbcod vdata 
                with frame ff side-label 1 down. pause 0.
            assign vcta01 = string(estab.prazo,"99999")
                   vcta02 = string(estab.vista,"99999").
        
            assign  vlpraz  = 0 vlvist  = 0 vlentr  = 0 vljuro  = 0 
                    vldesc  = 0 vldevvis = 0 vlpres = 0
                    ct-pres = 0 ct-juro = 0 ct-desc = 0 ct-vist = 0
                    ct-praz = 0 vlpred  = 0 vljurpre = 0 
                    totecf = 0.
            for each plani use-index pladat 
                            where plani.movtdc = 5       and
                                  plani.etbcod = estab.etbcod and
                                  plani.pladat = vdata no-lock.
                if plani.crecod = 1
                then assign ct-vist = ct-vist + 1
                            vlvist = vlvist +  if plani.outras > 0
                                               then plani.outras
                                               else plani.platot.
                if plani.crecod = 2
                then assign ct-praz = ct-praz + 1
                            vlpraz = vlpraz + if plani.outras > 0
                                              then plani.outras
                                              else plani.platot.

            end.
            for each titulo where titulo.etbcobra = estab.etbcod and
                                  titulo.titdtpag = vdata        no-lock.
                if titulo.clifor = 1
                then next.
                if titulo.titnat = yes
                then next.
                if titulo.modcod <> "CRE"
                then next.
                if titulo.etbcod = estab.etbcod and
                   titulo.titpar = 0
                then do:
                    assign ct-entr = ct-entr + 1
                           vlentr  = vlentr  + titulo.titvlcob.
                end.
                else do:
                    assign vlpres = vlpres + titulo.titvlcob /* titulo.titvlpag
                                    - titulo.titjuro + titulo.titdesc */
                           vljuro = vljuro + titulo.titjuro
                           ct-pres = ct-pres + if titulo.titvlcob > 0
                                               then 1
                                               else 0
                           ct-juro = ct-juro + if titulo.titjuro > 0
                                               then 1
                                               else 0.
                end.
            end.

            for each serial where serial.etbcod = estab.etbcod and
                                  serial.serdat = vdata no-lock.
                totecf = totecf + 
                         (serial.icm12 + serial.icm17 + serial.sersub).
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

            do on error undo, retry:
            
                if vlpraz = 0 and
                   vlvist = 0 and
                   vljuro = 0 and
                   vlpres = 0 and
                   vlentr = 0
                then next.
        
                totavi = totavi + vlvist.
                totapr = totapr + vlpraz.
                totjur = totjur + vljuro.
                totpre = totpre + vlpres.
                totent = totent + vlentr.
            
                create tt-lanca.
                assign tt-lanca.deb  = 169
                       tt-lanca.cre  = int(vcta01)   
                       tt-lanca.data = vdata  
                       tt-lanca.val  = vlpraz  
                       tt-lanca.his  = 109. 
            
                create tt-lanca.
                assign tt-lanca.deb  = 13
                       tt-lanca.cre  = int(vcta02)  
                       tt-lanca.data = vdata
                       tt-lanca.val  = vlvist 
                       tt-lanca.his  = 09.
    
                create tt-lanca.
                assign tt-lanca.deb  = 13
                       tt-lanca.cre  = 169  
                       tt-lanca.data = vdata
                       tt-lanca.val  = vlentr
                       tt-lanca.his  = 39.

            
                create tt-lanca. 
                assign tt-lanca.deb  = 13
                       tt-lanca.cre  = 169   
                       tt-lanca.data = vdata 
                       tt-lanca.val  = vlpres 
                       tt-lanca.his  = 39.
            
            
                create tt-lanca. 
                assign tt-lanca.deb  = 13 
                       tt-lanca.cre  = 6839   
                       tt-lanca.data = vdata 
                       tt-lanca.val  = vljuro 
                       tt-lanca.his  = 39.
            end.
        end.    

        tot-lanca = 0. 
        for each tt-lanca: 
            tot-lanca = tot-lanca + tt-lanca.val.
        end.

           
        for each tt-lanca: 
            if tt-lanca.val <= 0
            then next.
            put tt-lanca.deb format "99999"  
                tt-lanca.cre format "99999"   
                month(tt-lanca.data) format "99"
                day(tt-lanca.data)   format "99"
                year(tt-lanca.data)  format "9999"
                ( tt-lanca.val * 100) format "999999999999999"  
                ( tot-lanca * 100 )   format "999999999999999" 
                tt-lanca.his 
                "X"
                vlote skip.
        end.
    
    end.    
    output close.
    output stream stela close.
end.
