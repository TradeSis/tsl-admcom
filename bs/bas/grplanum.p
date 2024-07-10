/***
    Gera Planum e estserie para Plani
***/

def input  parameter p-etbcod like plani.etbcod.
def input  parameter p-serie  like plani.serie.
def output parameter p-placod like plani.placod.
def output parameter p-numero like plani.numero.

do transaction :
    do for planum on endkey undo, leave:
        find planum where planum.etbcod = p-etbcod exclusive no-error.
        if not available planum
        then do.
            create planum.
            assign
                planum.etbcod = p-etbcod
                planum.placod = 460000000.
            p-placod = planum.placod.
        end.
        else do.
            p-placod = planum.placod + 1.

            if p-placod = 550000000 /* Faixa de NFE */
            then p-placod = 560000000.
            else if p-placod = 650000000 /* Faixa de NFCE */
            then p-placod = 660000000.

            assign
                planum.placod = p-placod.
        end.
        find current planum no-lock. /***release planum***/
    end.
    if p-serie <> ""
    then do for estserie on endkey undo, leave:
        find last estserie where
                           estserie.etbcod = p-etbcod and
                           estserie.serie  = p-serie
                           exclusive   no-error.
        if not avail estserie
        then do:
            create estserie.
            assign
                estserie.etbcod = p-etbcod
                estserie.serie  = p-serie.
        end.
        assign
            estserie.numero = estserie.numero + 1
            p-numero = estserie.numero.
        find current estserie no-lock. /***release estserie***/
    end.
end.
