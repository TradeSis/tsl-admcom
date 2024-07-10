/*--------------------------------------------Etiquetas Butique peao----------*/
/* admcom/cp/peaoetiq.p                                                       */
/*----------------------------------------------------------------------------*/

{admcab.i}

def var vini as date format "99/99/99" label "Data Inicial".
def var vfin as date format "99/99/99" label  "Data Final".
def var vtotal      as char  extent 8 format "x(10)".
def var vclicod like clien.clicod  extent 3.
def var vclinom like clien.clinom  extent 3.
def var vtitpar like titulo.titpar extent 3.
def var vtitnum like titulo.titnum extent 3 .
def var vnumero like clien.numero  extent 3 .
def var vendereco like clien.endereco extent 3 .
def var vcep      like clien.cep extent 3 .
def var vcompl  like clien.compl extent 3.
def var vetbcod like titulo.etbcod extent 3 .
def var vcidade like clien.cidade extent 3 .
def var vtitvlpag like titulo.titvlpag extent 3 .
def var vtitdtven like titulo.titdtven extent 3 .
def var n-etiq  as int.

def var t as i.
def var i as int.
def var v as i.


do with width 80 title " Emissao de Etiquetas " frame f1 side-label:
    prompt-for titulo.etbcod with frame f1.
    update vini
           vfin with frame f1 row 4 1 column.

    output to printer page-size 0.

    for each titulo where titulo.empcod = 19    and
                          titulo.titnat = no    and
                          titulo.modcod = "CRE" and
                          titulo.titdtven >= vini and
                          titulo.titdtven <= vfin and
                          titulo.etbcod = input titulo.etbcod and
                          titulo.titsit <> "PAG"
                          use-index titdtven.

        find clien where clien.clicod = titulo.clifor no-error.
        if avail clien
            then do:

            put

                trim("Cod:" + string(clicod))
                "contr." titnum format "999999"  space(2)
                "Par." titpar         skip
                clinom                skip
                trim(endereco[1] + "," + string(clien.numero[1])
                                       + " " + string(clien.compl[1])) skip
                cep[1] cidade[1]      skip
                etbcod space(1) titulo.titdtven at 10
                titulo.titvlpag format ">,>>>,>>9.99" at 23
                skip (1).
        end.
    end.
    output  close.
    message "Emissao de Etiquetas p/ Cobranca encerrada.".
end.
