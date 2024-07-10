 /* #1 Helio.Neto 22.01.2019 - StatusFeirao com Feirao-Nome-Limpo = FEIRAO1, e FEIRAO-NOVO = Feirao2*/
{/admcom/progr/admcab-batch.i new} 

def var statusfeirao as char.
def var vfeirao-antigo as log.
def var vfeirao-novo   as log.
  
def var vTitvlcob as char.
def var vTitvlpag as char.
def var vTipoParcela as int.     
disp today string(time,"HH:MM:SS").

output to "/admcom/lebesintel/bsi-eiscob-regular.txt".        
                                                                            
for each estab where estab.etbcod >= 1 and estab.etbcod <= 45  no-lock.            
    for each modal where
        modal.modcod = "CRE" or
        modal.modcod = "CP0" or
        modal.modcod = "CP1" or
        modal.modcod = "CPN"
        no-lock.
        for each fin.titulo where  
                fin.titulo.empcod = 19 and
                fin.titulo.titnat = no  and 
                fin.titulo.modcod = modal.modcod and 
                fin.titulo.etbcod = estab.etbcod and 
                fin.titulo.titdtven >= 12/01/1900
                no-lock.                
                
                if titulo.titsit = "LIB"
                then do:
                    run exporta.
                end.    
                else do:
                    if titulo.titdtven >= 01/01/2010
                    then do:
                        run exporta.
                    end.
                end.
        end. 
    end.
end.                     

output close.                      
disp today string(time,"HH:MM:SS").
  
                     

procedure exporta.

        vTitvlcob = string(fin.titulo.titvlcob). 
        vTitvlpag   = string(fin.titulo.titvlpag).         

        /* #1 */
        vfeirao-antigo = acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM".
        vfeirao-novo   = acha("FEIRAO-NOVO",titulo.titobs[1])       = "SIM".
     
        statusfeirao = "NAO".
        if vfeirao-antigo then statusfeirao = "FEIRAO1".
        if vfeirao-novo   then statusfeirao = "FEIRAO2".
             
        /*#1
        *if acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) <> ? and
        *   acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM" then do:
        *       statusfeirao = "SIM".
        *   end.
        *   else do:
        *      statusfeirao = "NAO".
        *   end.
        #1 */

        vTipoParcela = 0.                         
        if titulo.tpcontrato = "N" 
        then do:       
            vTipoParcela = 1.                     
        end.                   
        if titulo.tpcontrato = "L" 
        then do:       
            vTipoParcela = 2.                     
        end.                                       
        put etbcod ";" 
            titnum ";" 
            clifor ";" 
            titpar ";" 
            etbcobra ";" 
            empcod ";"        
            YEAR(titdtven) format "9999"  "-" 
            MONTH(titdtven) format "99" "-" 
            DAY(titdtven) format "99" ";"             
            vTitvlcob ";" 
            YEAR(titdtpag) format "9999"  "-" 
            MONTH(titdtpag) format "99" "-"  
            DAY(titdtpag) format "99" ";" 
            vTitvlpag ";" 
            titsit ";"            
            moecod ";" 
            vTipoParcela ";"                
            YEAR(titdtemi) format "9999"  "-" 
            MONTH(titdtemi) format "99" "-"     
            DAY(titdtemi) format "99" ";" 
            modcod ";" 
            statusfeirao ";;" 
            skip.                            


end procedure.

