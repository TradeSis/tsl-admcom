{admcab.i}
def var varquivo as char.
def var vpdf as char no-undo.


def var vaux as log.
def var vdescontos as dec.
def var vvenda as dec.
def var vperc as dec.
def var vcatcod as int.

def var vp31 as dec format ">>9.99%" label "Desc Moveis" init 5.
def var vp41 as dec format ">>9.99%" label "  Desc Moda" init 10.

def var vdtini  as date format "99/99/9999" label " De".
def var vdtfim  as date format "99/99/9999" label "Ate".

def var vetbcod like estab.etbcod.

def temp-table tt-cli no-undo
    field etbcod    like plani.etbcod
    field placod    like plani.placod format ">>>>>>>>>"
    field procod    like movim.procod
    field movseq    like movim.movseq
    field catcod    like produ.catcod
    field vencod    like plani.vencod format ">>>>>>"
    field clicod    like plani.desti  format ">>>>>>>>>>"
    field vlrbruto  as dec format ">>>>>>>>9.99" column-label "Vlr!Bruto"
    field descontos like plani.descprod column-label "Desc"
    field perc      as dec format ">>>9.99%" column-label "Perc"
    field valtotal  as dec  format ">>>>>>>>9.99" column-label "Vlr!Liquido"

    index x is unique primary etbcod asc placod asc movseq asc procod asc.
    

update vetbcod colon 20
    with frame fcab 
        width 80
        side-labels
        title 
        "Lista Descontos Por Percentuais para Clientes".        
find estab where estab.etbcod = vetbcod no-lock no-error.
if not avail estab
then do:
    if vetbcod <> 0
    then do:
        message "Filial " vetbcod " Nao cadastrada"
        view-as alert-box.
        undo.
    end.
end.

update vdtini colon 20 vdtfim
    with frame fcab.
    
update vp31 colon 20 vp41 colon 20
    with frame fcab.

pause 0 before-hide.
def var vtime as int.

vtime = time.

for each estab 
    where if vetbcod = 0 then true
    else (estab.etbcod = vetbcod)
no-lock.
disp estab.etbcod colon 20 label "...."
    with frame fcab.
for each plani where plani.movtdc = 5 and 
        plani.etbcod = estab.etbcod and
        plani.pladat >= vdtini and plani.pladat <= vdtfim no-lock.
    vcatcod = 0.
    
        hide message no-pause.
        message "Processando" string(time - vtime,"HH:MM:SS") /* time - vtime (time - vtime) mod 10*/ .
    
    for each movim where movim.etbcod = plani.etbcod and movim.placod = plani.placod no-lock.
        find produ of movim no-lock.
        if produ.catcod = 31
        then vcatcod = 31.
        else if produ.catcod = 41
             then vcatcod = 41.
             else vcatcod.

        vaux = no.
        vdescontos = 0.
        find first movimaux of movim where
                 movimaux.nome_campo begins "DESCONTO" no-lock no-error.
        if avail movimaux
        then do:
            vaux = yes.
            vdescontos = dec(valor_campo).
        end.
        if vaux
        then do:
            vvenda = (movim.movpc * movim.movqtm) + vdescontos.
            vperc  = vdescontos / vvenda * 100.
            if (vp31 > 0 and vperc = vp31 and vcatcod = 31) or
               (vp41 > 0 and vperc = vp41 and vcatcod = 41)
            then do:
                find clien where clien.clicod = plani.desti no-lock.
                find tipo_clien of clien no-lock.
                if clien.tipocod <> 3
                then do:
                    create tt-cli.
                    tt-cli.etbcod = plani.etbcod.
                    tt-cli.placod = plani.placod.
                    tt-cli.procod = movim.procod.
                    tt-cli.movseq = movim.movseq.
                    tt-cli.catcod = produ.catcod.
                    tt-cli.vencod = plani.vencod.
                    tt-cli.clicod = plani.desti.
                    tt-cli.vlrbruto = vvenda.
                    tt-cli.descontos = vdescontos.
                    tt-cli.perc    = vperc.
                    tt-cli.valtotal = (movim.movqtm * movim.movpc).
                end.
            end.
        end.
    end.
end.
end.

pause before-hide.


hide message no-pause.
message "Gerando o Relatorio ".

def buffer bestab for estab.
def var varq as char format "x(20)".

    /**
    if opsys = "UNIX"
    then varquivo = "../relat/rdessusp_" + string(mtime) + ".txt".
    else varquivo = "l:~\relat~\rdessusp" + string(time).
    **/
    
    varquivo = "/admcom/relat/rdessusp_" + string(day(today)) + ".csv".     
    message "gerando arquivo" varquivo.
     
    /*
    64
    66
    */
    
    /* versao csv
    {mdad.i
            &Saida     = "value(varquivo)" 
            &Page-Size = "0"
            &Cond-Var  = "140"
            &Page-Line = "0"
            &Nom-Rel   = ""rdessusp""
            &Nom-Sis   = """SISTEMA DE CREDIARIO"""
            &Tit-Rel   = """ LISTA VENDAS COM DESCONTOS MOVEIS "" + string(vp31) +  ""% "" +
                                "" MODA "" + string(vp41) + ""% ""
                                + "" - PARA CLIENTES, FILIAL -> "" + 
                              string(vetbcod) + "" DE "" + 
                              string(vdtini,""99/99/9999"") + "" ATE "" + 
                              string(vdtfim,""99/99/9999"")

                              " 
            &Width     = "140"
            &Form      = "frame f-cabcab"}
    **/
    
    output to value(varquivo).
    put unformatted " LISTA VENDAS COM DESCONTOS " +
                    (if vp31 > 0
                    then (" MOVEIS " + string(vp31) + "% ")
                    else "")
                    + 
                    (if vp41 > 0
                    then (" MODA " + string(vp41) + "% ")
                    else "")
                    + 
                    " - PARA CLIENTES, FILIAL -> " + 
                    (if vetbcod = 0
                    then "TODAS"
                    else string(vetbcod))
                     + " DE " + 
                    string(vdtini,"99/99/9999") + " ATE " + string(vdtfim,"99/99/9999")
                              
    skip(2).
                                  
    put unformatted skip
    "CODIGO_VENDEDOR;" +
    "NOME_VENDEDOR;"   +
    "CODIGO_CLIENTE;"  +
    "NOME_CLIENTE;"    +
    "FILIAL;"          +
    "SERIE;" +
    "EMISSAO;" +
    "NUMERO;" +
    "CATEGORIA;" +
    "PRODUTO;" +
    "DESCRICAO;" +
    "VLR_BRUTO;" +
    "VLR_DESCONTOS;" +
    "PERC_DESCONTO;" +
    "VLR_LQUIDO"
    skip.
    
for each tt-cli
    with width 300 
    break by tt-cli.vencod
          by tt-cli.clicod
          by tt-cli.etbcod
          
          by tt-cli.placod.
    find plani where tt-cli.etbcod = plani.etbcod and tt-cli.placod = plani.placod no-lock.
    find produ of tt-cli no-lock.
    find func where func.etbcod = plani.etbcod and func.funcod = tt-cli.vencod no-lock no-error.
    find clien of tt-cli no-lock.

    /** versao csv
    disp tt-cli.vencod.
    disp func.funnom when avail func.

    find clien of tt-cli no-lock.
    disp tt-cli.clicod.
    disp clien.clinom.
     
    disp plani.etbcod
         plani.serie
         plani.pladat
         plani.numero.
    disp tt-cli.catcod.
    disp tt-cli.procod.
    disp produ.pronom.
    disp vlrbruto 
            descontos  (total by tt-cli.vencod)
            tt-cli.perc (average by tt-cli.vencod)
            valtotal (total by tt-cli.vencod).
    **/
        
    put unformatted
        tt-cli.vencod ";"
        (if avail func then func.funnom else "") ";"
         tt-cli.clicod ";"
         clien.clinom ";"
         plani.etbcod ";"
         plani.serie ";"
         plani.pladat ";"
         plani.numero ";"
         tt-cli.catcod ";"
         tt-cli.procod ";"
         produ.pronom ";"
         vlrbruto ";"
         descontos ";"
         tt-cli.perc ";"
         valtotal 
         skip.

end.    

output close.

/** versao csv
if sremoto /* #3 */
then run pdfout.p (input varquivo,
                  input "/admcom/kbase/pdfout/",
                  input "rdessusp" + string(mtime) + ".pdf",
                  input "Portrait",
                  input 8.2,
                  input 1,
                  output vpdf).
else if opsys = "UNIX"
then do:
    run visurel.p(varquivo, "").
 
    /*
    varquivo = "l:~\relat~\" + substr(varquivo,10,15).
    message skip "Arquivo gerado: " varquivo view-as alert-box.
    */
end.
else do:    
    {mrod.i}.
end.

**/


    message skip "Arquivo gerado: " varquivo view-as alert-box.

