def var v-cheinc like chedat.datexp.
def var v-chedec like chedat.chedec.
def var v-banco like banco.bandesc.
def var v-clien like clien.clinom.

output to "/admcom/lebesintel/bi_cheques.csv".

    /*put "CLICOD;CLINOM;BANCOD;BANNOM;BANAGE;BANCID;FILCOD;FILNOM;CHEEMI;CHEVEN;CHEVAL;CHENUM;CHEALINEA;CHEDTI;CHEDTF;CHESIT;COBCOD;COBNOM;CHEPAG;CHEJUR;CHECONTA;CHEINC;CHEDEC" skip.*/

    for each fin.cheque /*where cheemi >= today - 5*/ no-lock.

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
            cheque.clicod ";"
            v-clien ";"
            cheque.cheban ";"
            v-banco ";"
            cheque.cheage ";"
            cheque.checid ";"
            cheque.cheetb format ">>9" ";"
            estab.etbnom ";"
            /*cheque.cheemi ";"*/
            STRING(YEAR(cheque.cheemi),"9999") + "-" + STRING(MONTH(cheque.cheemi),"99") + "-" + STRING(DAY(cheque.cheemi),"99") format "x(10)" ";"
            /*cheque.cheven ";"*/
            STRING(YEAR(cheque.cheven),"9999") + "-" + STRING(MONTH(cheque.cheven),"99") + "-" + STRING(DAY(cheque.cheven),"99") format "x(10)" ";"
            cheque.cheval ";"
            cheque.chenum ";"
            cheque.chealin ";"
            /*cheque.chedti ";"*/
            STRING(YEAR(cheque.chedti),"9999") + "-" + STRING(MONTH(cheque.chedti),"99") + "-" + STRING(DAY(cheque.chedti),"99") format "x(10)" ";"
            /*cheque.chedtf ";"*/
            STRING(YEAR(cheque.chedtf),"9999") + "-" + STRING(MONTH(cheque.chedtf),"99") + "-" + STRING(DAY(cheque.chedtf),"99") format "x(10)" ";"
            cheque.chesit ";"
            cheque.codcob format ">>9" ";"
            cobrador.nome ";"
            /*cheque.chepag ";"*/
            STRING(YEAR(cheque.chepag),"9999") + "-" + STRING(MONTH(cheque.chepag),"99") + "-" + STRING(DAY(cheque.chepag),"99") format "x(10)" ";"
            cheque.chejur ";"
            cheque.checon ";"
            /*v-cheinc ";"*/
            STRING(YEAR(v-cheinc),"9999") + "-" + STRING(MONTH(v-cheinc),"99") + "-" + STRING(DAY(v-cheinc),"99") format "x(10)" ";"
            v-chedec
        skip.
    end.
output close.
