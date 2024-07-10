/* helio 06122022 - ajustes projeto prestamista gratis */
/***
Prestamista
Nov/2015
Alterado 05/1016 para mostrar quando novação ou quando cancelar
#1 TP 23757044
29/09/20-https://trello.com/c/3CYVcYas/32-conciliacao-de-seguros

***/

{admcab.i}

def var vetbcod   like estab.etbcod.
def var vdtini    as date    label "Data Inicial" form "99/99/99".
def var vdtfim    as date    label "Data Final"   form "99/99/99".
def var vdata     as date.
def var vparc     as int.
def var varqsai   as char.
def var vtiporel  as int.
def var mtiporel  as char extent 3 init [" Analitico"," Sintetico"," Excel"].

do on error undo with frame f-filtro side-label.
    update vetbcod colon 16.
    /*
        Datas
    */
    assign
        vdtini = date( month(today), 1, year(today) )
        vdtfim = date( month(today + 30), 1, year(today + 30) ) - 1.
    update vdtini colon 16 vdtfim.
    if vDtFim < vDtIni
    then do:
        message "Data invalida" view-as alert-box.
        undo.
    end.

    disp mtiporel colon 16 format "x(20)" no-label.
    choose field mtiporel.
    vtiporel = frame-index.
end.

def temp-table tt-seguro no-undo
    field rec  as recid
    field data as date
    field Valor  as dec format "->,>>9.99"
    field ValorCanc  as dec format "->,>>9.99"
    index tt is unique primary rec asc 
    index seguro data.

def temp-table tt-venda no-undo
    field etbcod like vndseguro.etbcod
    field Data   as date
    field Venda  as int format ">>,>>>"
    field Cancel as int format ">>,>>>"
    field Valor  as dec format "->,>>9.99"
    field ValorCanc  as dec format "->,>>9.99"
    
    index venda is primary unique etbcod data.

for each estab where estab.etbcod < 500 no-lock.
    if vetbcod > 0 and estab.etbcod <> vetbcod
    then next.
    do vdata = vdtini to vdtfim.
        for each segtipo where (segtipo.tpseguro = 1 or segtipo.tpseguro = 3) no-lock.
        for each vndseguro where vndseguro.tpseguro = segtipo.tpseguro 
                             and vndseguro.etbcod   = estab.etbcod
                             and vndseguro.dtincl   = vdata
                           no-lock.
            create tt-seguro.
            assign
                tt-seguro.rec   = recid(vndseguro)
                tt-seguro.data  = vdata
                tt-seguro.valor = vndseguro.prseguro.

            find tt-venda where tt-venda.etbcod = estab.etbcod
                            and tt-venda.data   = vdata
                          no-error.
            if not avail tt-venda
            then do.
                create tt-venda.
                assign
                    tt-venda.etbcod = estab.etbcod
                    tt-venda.data = vdata.
            end.
            tt-venda.venda = tt-venda.venda + 1.
            tt-venda.valor = tt-venda.valor + vndseguro.prseguro.
            
            /* helio 06122022 -  nao duplicar mais os cancelados */
            if vndseguro.dtcanc >= vdtini and vndseguro.dtcanc <= vdtfim
            then  do:
                tt-seguro.valorcanc = - vndseguro.prseguro.
                tt-venda.cancel = tt-venda.cancel + 1.
                tt-venda.valorcanc  = tt-venda.valorcanc - vndseguro.prseguro.
            end.    
            
        end.

        for each vndseguro where vndseguro.tpseguro = segtipo.tpseguro
                             and vndseguro.etbcod   = estab.etbcod
                             and vndseguro.dtcanc   = vdata
                           no-lock.

            /* helio 06122022 -  nao duplicar mais os cancelados */
            find first tt-seguro where tt-seguro.rec = recid(vndseguro) no-error.
            if avail tt-seguro
            then next.

            create tt-seguro.
            assign
                tt-seguro.rec   = recid(vndseguro)
                tt-seguro.data  = vdata
                tt-seguro.valorCanc = - vndseguro.prseguro.

            find tt-venda where tt-venda.etbcod = estab.etbcod
                            and tt-venda.data = vdata
                          no-error.
            if not avail tt-venda
            then do.
                create tt-venda.
                assign
                    tt-venda.etbcod = estab.etbcod
                    tt-venda.data = vdata.
            end.
            tt-venda.cancel = tt-venda.cancel + 1.
            tt-venda.valorCanc  = tt-venda.valorCanc - vndseguro.prseguro.
        end.
        end.
    end.
end.

if vtiporel <= 2
then varqsai = "/admcom/relat/segventx" +  string(time).
else varqsai = "/admcom/relat/segventx" +  string(time) + ".csv".

if vtiporel <= 2
then do.
    {mdadmcab.i 
        &Saida     = "value(varqsai)"
        &Page-Size = "0"
        &Cond-Var  = "96"
        &Page-Line = "66"
        &Nom-Rel   = ""SEGVENTX""
        &Nom-Sis   = """SISTEMA CREDIARIO"""
        &Tit-Rel   = """VENDA DE SEGUROS - "" + string(vdtini) + "" ATE "" +
                  string(vdtfim)"
        &Width     = "96"
        &Form      = "frame f-cabcab1"}
end.
else
    output to value(varqsai).

def var log-operacao as char.

if vtiporel = 1
then do:
    for each tt-seguro,
        vndseguro where recid(vndseguro) = tt-seguro.rec no-lock
        break by vndseguro.etbcod
              by tt-seguro.data.
        find produ of vndseguro no-lock.
        /* corretiva day 20/05/2016
        find plani where plani.etbcod = vndseguro.etbcod
                     and plani.placod = vndseguro.placod
                   no-lock no-error.
        if avail plani
        then find finan where finan.fincod = plani.pedcod no-lock.
        */
        /*Acrescentado corretiva day 20/05/2016 */
        release contrato.
        release contnf.
        release plani.
        release finan.
        release titulo.
        find contrato where contrato.contnum = vndseguro.contnum 
                no-lock no-error.
        if avail contrato
        then find first contnf where 
                  contnf.etbcod = contrato.etbcod and
                  contnf.contnum = contrato.contnum
                  no-lock no-error.
             if avail contnf
             then find first plani where plani.etbcod = contnf.etbcod and
                                   plani.placod = contnf.placod and
                                   plani.movtdc = 5 and
                                   plani.pladat = contrato.dtinicial
                                   no-lock no-error.
        if avail plani
        then do:
            find finan where finan.fincod = plani.pedcod no-lock.
            /* helio 06122022 */
            for each movim where movim.etbcod = plani.etbcod and
                movim.placod = plani.placod
                no-lock.
                find produ of movim no-lock.
                if produ.catcod = 31 or produ.catcod = 41
                then leave.
            end.
        end.            
        else if avail contrato
            then find finan where finan.fincod = contrato.crecod no-lock. 
        log-operacao = "".
        if vndseguro.placod = ? or
            not avail plani
        then do: 
            find first titulo where
                       titulo.clifor = vndseguro.clicod and
                       titulo.titnum = string(vndseguro.contnum) and
                       titulo.titpar > 0
                       no-lock no-error.
            if avail titulo
            then do:
                if titulo.tpcontrato <> ""
                then log-operacao = "Novacao".
                else if titulo.modcod begins "CP"
                    then log-operacao = "C.Pessoal". 
                    else log-operacao = "Cancelar".
            end.
            else log-operacao = "Cancelar".    
        end.

        disp
            vndseguro.etbcod
            vndseguro.certifi
            vndseguro.dtincl
            tt-seguro.valor (total by tt-seguro.data)
            
            /* helio 06122022 */
            tt-seguro.valorcanc (total by tt-seguro.data)
            tt-seguro.valor + tt-seguro.valorcanc (total by tt-seguro.data) column-label "valor!liquido"
            
            produ.catcod column-label "Cat"
            vndseguro.clicod
            vndseguro.dtcanc
            plani.pedcod when avail plani column-label "Plano"
            plani.platot when avail plani format ">>,>>9.99"
                         column-label "Tot.Nota"
            finan.finnom when avail plani format "x(15)"
            log-operacao
            with frame f-lin width 120 down.
 
    end.
end.    
if vtiporel <= 2
then
    for each tt-venda.
        disp
            tt-venda.etbcod
            tt-venda.data
            tt-venda.venda (total)
            tt-venda.cancel (total)
            tt-venda.valor (total)
            /* helio 06122022 */
            tt-venda.valorcanc (total)
            tt-venda.valor + tt-venda.valorcanc (total) column-label "valor!Liquido"            
            
            with frame f-venda down.
    end.
def var vcatnom as char.
if vtiporel = 3
then do:
    put unformatted
            "Filial"  ";"
            "Certificado" ";"
            "Dt Venda"  ";"
            "valor venda"   ";"
            "Valor Cancelado"   ";"
            "Valor Liquido"    ";"
            
            "Categoria"    ";"
            "codigoProduto"     ";"
            "Nome Produto"   ";"  

            "Cliente"  ";"
            "Dt Cancela"  ";"
            "Nota" ";"
            "Vlr Tot Nnota" ";"
            "Plano" ";"
            ";;;;"
            skip.

    for each tt-seguro,
        vndseguro where recid(vndseguro) = tt-seguro.rec no-lock
        break by vndseguro.etbcod
              by tt-seguro.data.
        find produ of vndseguro no-lock.
        release contrato.
        release contnf.
        release plani.
        release finan.
        release titulo.
        
        vcatnom = "".
         
        find contrato where contrato.contnum = vndseguro.contnum 
                no-lock no-error.
        if avail contrato
        then find first contnf where 
                  contnf.etbcod = contrato.etbcod and
                  contnf.contnum = contrato.contnum
                  no-lock no-error.
             if avail contnf
             then find first plani where plani.etbcod = contnf.etbcod and
                                   plani.placod = contnf.placod and
                                   plani.movtdc = 5 and
                                   plani.pladat = contrato.dtinicial
                                   no-lock no-error.
        if avail plani
        then do:
            find finan where finan.fincod = plani.pedcod no-lock.
                for each movim where movim.etbcod = plani.etbcod and
                                    movim.placod  = plani.placod
                                    no-lock .
                    find produ of movim no-lock no-error.
                    if avail produ
                    then do: 
                        if produ.catcod = 31 or produ.catcod = 41 
                        then do:
                            find categoria of produ no-lock.
                            vcatnom = categoria.catnom.
                            leave.
                        end.
                    end.
                end.            
        end.
            
        else if avail contrato
            then find finan where finan.fincod = contrato.crecod no-lock. 
        log-operacao = "".
        if vndseguro.placod = ? or
            not avail plani
        then do: 
            find first titulo where
                       titulo.clifor = vndseguro.clicod and
                       titulo.titnum = string(vndseguro.contnum) and
                       titulo.titpar > 0
                       no-lock no-error.
            if avail titulo
            then do:
                if titulo.tpcontrato <> ""
                then log-operacao = "Novacao".
                else if titulo.modcod begins "CP"
                    then log-operacao = "C.Pessoal". 
                    else log-operacao = "Cancelar".
            end.
            else log-operacao = if vndseguro.dtcanc = ?
                                then "Cancelar"
                                else "".    
        end.

        find produ of vndseguro no-lock.

        put unformatted
            vndseguro.etbcod  ";"
            vndseguro.certifi ";"
            vndseguro.dtincl  ";"
            tt-seguro.valor   ";"
            tt-seguro.valorCanc   ";"
            tt-seguro.valor + tt-seguro.valorCanc    ";"
            
            vcatnom    ";"
            produ.procod      ";"
            produ.pronom      ";"  
            vndseguro.clicod  ";"
            vndseguro.dtcanc  ";".

        if avail plani
        then
            put unformatted
                plani.pedcod ";"
                plani.platot ";"
                finan.finnom ";".
        else if log-operacao <> ""
            then put unformatted ";;;" log-operacao.
            else put unformatted ";;;;".    
        put unformatted skip.
    end.
end.        
output close.

if vtiporel <= 2
then run visurel.p (varqsai, "").
else message "Arquivo gerado:" varqsai view-as alert-box.

