{/admcom/progr/admcab-batch.i new}    

def var v-cheinc like chedat.datexp.
def var v-chedec like chedat.chedec.
def var v-banco like banco.bandesc.
def var v-clien like clien.clinom.

output to "/admcom/lebesintel/CHQ-bsi-eiscob-regula3.csv". 

  for each fin.cheque no-lock:

    find banco where banco.bancod = cheque.cheban no-lock no-error.
    if avail banco then
        v-banco = banco.bandesc.
    else v-banco = "".

    find fin.cobrador where cobrador.codcob = cheque.codcob no-lock no-error.
    find estab where estab.etbcod = cheque.cheetb no-lock no-error.

    find chedat where chedat.chenum = cheque.chenum and
                      chedat.cheage = cheque.cheage and
                      chedat.cheban = cheque.cheban no-lock no-error.
    if avail chedat then do:
        v-cheinc = chedat.datexp.
        v-chedec = chedat.chedec.
    end.
    else do:
        v-cheinc = ?.
        v-chedec = no.
    end.

    find clien where clien.clicod = cheque.clicod no-lock no-error.
    if avail clien then
        v-clien = clien.clinom.
    else v-clien = "".

    put 
      cheque.cheetb format ">>9" ";" 
      cheque.chenum ";" 
      cheque.clicod ";" 
      "0;" 
      cheque.codcob format ">>9" ";" 
      "19;"
      YEAR(cheque.cheven) format "9999" "-" MONTH(cheque.cheven) format "99" "-" DAY(cheque.cheven) format "99" ";"             
      cheque.cheval ";" 
      YEAR(cheque.chepag) format "9999"  "-" MONTH(cheque.chepag) format "99" "-" DAY(cheque.chepag) format "99" ";" 
      cheque.cheval ";" 
      cheque.chesit ";"            
      "CHE;" 
      "C;"                
      YEAR(cheque.cheemi) format "9999"  "-" MONTH(cheque.cheemi) format "99" "-" DAY(cheque.cheemi) format "99" ";" 
      "CHQ;" 
      "NAO;"
      STRING(cheque.cheetb) + "|" + STRING(cheque.chenum) + "|" + STRING(cheque.clicod) + "|" + STRING(cheque.checon)
    skip.
  end.

output close.