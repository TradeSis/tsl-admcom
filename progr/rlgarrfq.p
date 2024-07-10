/*                       
Nov/2017: Projeto Garantia / RFQ
*/
{admcab.i}

{filtro-estab.def}
def var vdata    as date.
def var vdtini   as date.
def var vdtfim   as date.

def var vtiporel  as int.
def var mtiporel  as char extent 3 init [" Analitico"," Sintetico"," Excel"].
def var vtitrel   as char.

def var varquivo as char.

def var vqtvnd    as int.
def var vqtcan    as int.
def var vqtgervnd as int.
def var vqtgercan as int.
def var vqtetbvnd as int.
def var vqtetbcan as int.
def var vvlvnd    as dec.
def var vvlcan    as dec.
def var vvlgervnd as dec.
def var vvlgercan as dec.
def var vvletbvnd as dec.
def var vvletbcan as dec.
def var vttvnd    as dec format ">>>,>>9.99".
def var vttcan    as dec format ">>>,>>9.99".
def var vttgervnd as dec format ">,>>>,>>9.99".
def var vttgercan as dec format ">,>>>,>>9.99".

def temp-table tt-mvg
    field etbcod    like vndseguro.etbcod
    field vencod    like vndseguro.vencod
    field data      as date
    field rec       as recid
    field prgar     like vndseguro.prseguro
    field inclusao  as log
    field cancela   as log
    field etbfunc   as int
    index rec is unique primary rec asc.

def var mopc as char format "x(18)" extent 2
       initial [" Estab/Vendedor "," Data "].
def var vfil-tpseguro as char init "5,6".
{filtro-segtipo.i vfil-tpseguro}

form
    vEstab   colon 31 label "Todos Estabelecimentos"
             help "Relatorio com Todos os Estabelecimentos ?"
    cestab   no-label format "x(30)"
    vdtini   colon 31 label "Venda"
    vdtfim   label "ate"
    mtiporel colon 16 format "x(20)" no-label
    
    with frame fopcoes row 3 side-label width 80 title vtpnome.

do on error undo with frame fopcoes.
    {filtro-estab.i}
    update
        vdtini validate (vdtini <> ?, "")
        vdtfim validate (vdtfim <> ?, "").
    if vDtFim < vDtIni
    then do:
        message "Data invalida" view-as alert-box.
        undo.
    end.
    disp mtiporel colon 16 format "x(20)" no-label.
    choose field mtiporel.
    vtiporel = frame-index.

end.

hide message no-pause.
message "Processando...".

    for each estab where estab.usap2k no-lock.
        if not vEstab
        then do:
            find wfEstab where wfEstab.Etbcod = estab.Etbcod no-error.
            if not avail wfEstab
            then next.
        end.

        do vdata = vdtini to vdtfim.

            for each vndseguro where vndseguro.tpseguro = vtpseguro
                                 and vndseguro.etbcod   = estab.etbcod
                                 and vndseguro.dtincl   = vdata
                               no-lock.
                create tt-mvg.
                assign             
                    tt-mvg.data     = vndseguro.dtincl
                    tt-mvg.etbcod   = vndseguro.etbcod
                    tt-mvg.vencod   = vndseguro.vencod
                    tt-mvg.rec      = recid(vndseguro)
                    tt-mvg.prgar    = vndseguro.prseguro
                    tt-mvg.inclusao = yes.
            end.

            for each vndseguro where vndseguro.tpseguro = vtpseguro
                                 and vndseguro.etbcod   = estab.etbcod
                                 and vndseguro.dtcanc   = vdata
                               no-lock.
                run cria-registros.
            end.
        end.
    end.


procedure cria-registros.

/*
    if vndseguro.dtincl >= vdtini and
       vndseguro.dtincl <= vdtfim
    then do:
        find first func where func.funcod = vndseguro.vencod no-lock.
                                                                                        create tt-mvg.
        assign             
            tt-mvg.data     = vndseguro.dtincl
            tt-mvg.etbcod   = vndseguro.etbcod
            tt-mvg.vencod   = vndseguro.vencod
            tt-mvg.rec      = recid(vndseguro)
            tt-mvg.prgar    = vndseguro.prseguro
            tt-mvg.inclusao = yes
            tt-mvg.etbfunc  = func.etbcod.
    end.
*/

    if vndseguro.dtcanc >= vdtini and
       vndseguro.dtcanc <= vdtfim
    then do:   
        find first tt-mvg where tt-mvg.rec = recid(vndseguro) no-error.
    
        if vndseguro.dtincl >= vdtini and
           vndseguro.dtincl <= vdtfim
        /* inclusao e cancelamento no mesmo mes */
        then assign
            tt-mvg.cancela = yes.
        else do:
            find first func where func.funcod = vndseguro.vencod no-lock.
            if not avail tt-mvg
            then do.
                create tt-mvg.
                tt-mvg.rec     = recid(vndseguro).
            end.
            assign
                tt-mvg.data    = vndseguro.dtcanc
                tt-mvg.etbcod  = vndseguro.etbcod
                tt-mvg.vencod  = vndseguro.vencod
                tt-mvg.prgar   = vndseguro.prseguro
                tt-mvg.cancela = yes 
                tt-mvg.etbfunc = func.etbcod.
        end.
    end.      

end procedure.


if vtiporel <= 2
then varquivo = "/admcom/relat/rlgarrfq." + string(mtime).
else varquivo = "/admcom/relat/rlgarrfq." + string(mtime) + ".csv".

if vtiporel <= 2
then do.
    {mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "136"
                &Page-Line = "66" 
                &Nom-Rel   = ""rlgarrfq"" 
                &Nom-Sis   = """ """ 
                &Tit-Rel   = """VENDA DE SEGUROS: "" + vtpnome + "" DE "" +
                              string(vdtini) + "" ATE "" + string(vdtfim)" 
                &Width     = "136"
                &Form      = "frame f-cabcab"}

end.
else
    output to value(varquivo).

if vtiporel <= 2
then do:
form with frame fsintetico down no-box width 96.

    put unformatted skip
        "PARAMETROS SOLICITADOS "   at 1.
    if not vEstab
    then put unformatted "Estabelecimentos...: "     at 27 cEstab.


    for each tt-mvg no-lock,
         first vndseguro where recid(vndseguro) = tt-mvg.rec no-lock
                      break by tt-mvg.etbcod 
                            by tt-mvg.vencod
                            by tt-mvg.inclusao desc
                            by vndseguro.certifi.

        if vtiporel = 1 and first-of(tt-mvg.etbcod)
        then do:
            find estab where estab.etbcod = vndseguro.etbcod no-lock.
            display estab.etbcod /* colon 10*/ label "Estab"
                 estab.etbnom no-label
                 with frame ffiltro side-label.
        end.  

        if vtiporel = 1 and first-of(tt-mvg.vencod)
        then do:
            find first func where func.funcod = vndseguro.vencod
                       no-lock no-error.
            display vndseguro.vencod format "99999" colon 20 label "Vendedor"
                  func.funnom no-label when avail func
                  with frame fvendedor side-label width 100. 
        end.

        if vtiporel = 1 and first-of(tt-mvg.inclusao) and
           tt-mvg.inclusao = no
        then put skip(1).

        find produ  of vndseguro no-lock no-error.
        find clien  of vndseguro no-lock no-error.

        if vtiporel = 1
        then display 
/*
              if vmarca then "*" else " " column-label "*" format "x(1)"
*/
                vndseguro.procod   column-label "Codigo"
                produ.pronom when avail produ   column-label "Descricao"
                vndseguro.certifi  column-label "Certificado" format "x(15)"
                vndseguro.tempo    column-label "Tmp"
                vndseguro.pladat   column-label "Dt.Nota"   format "99/99/99"
                vndseguro.dtincl   column-label "Dt.Venda"  format "99/99/99"
                vndseguro.prseguro column-label "Vl.Seguro" format ">>>>>9.99"
                vndseguro.dtcanc   column-label "Cancelam"  format "99/99/99"
                vndseguro.clicod   column-label "Cliente"   format ">>>>>>>>>>9"
                clien.clinom       when avail clien format "x(15)"
                with frame flin width 150 down no-box.

        if tt-mvg.inclusao /*tipo = "INCLUSAO"*/
        then do:
            vqtvnd = vqtvnd + 1.
            vvlvnd = vvlvnd + tt-mvg.prgar.
            vqtetbvnd = vqtetbvnd + 1.
            vvletbvnd = vvletbvnd + tt-mvg.prgar.
            vqtgervnd = vqtgervnd + 1.
            vvlgervnd = vvlgervnd + tt-mvg.prgar.
            vttvnd = vttvnd + vndseguro.prseguro.
            vttgervnd = vttgervnd + vndseguro.prseguro.
        end.

        if tt-mvg.cancela /*tipo = "CANCELA"*/
        then assign
                vqtcan = vqtcan + 1
                vvlcan = vvlcan + tt-mvg.prgar
                vqtgercan = vqtgercan + 1
                vvlgercan = vvlgercan + tt-mvg.prgar
                vqtetbcan = vqtetbcan + 1
                vvletbcan = vvletbcan + tt-mvg.prgar
                vttcan = vttcan + vndseguro.prseguro
                vttgercan = vttgercan + vndseguro.prseguro.

        if vtiporel = 1 and last-of(tt-mvg.vencod)
        then do:
            find first func where func.funcod = vndseguro.vencod
                        no-lock no-error.
            display skip(1)
               "Total vendedor " + string(vndseguro.vencod) colon 5
                                  format "x(20)"
                func.funnom no-label when avail func
                "  Qtd" colon 65 space(6) vqtvnd format ">>,>>9"
                "   Cancel." space(6) vqtcan format ">>,>>9"
                "     Total" space(6) vqtvnd - vqtcan format "->>,>>9" 
                with frame ftotvendedor no-labels width 160 no-box.
           display 
                "Venda" colon 65 vvlvnd   format ">>>>,>>9.99"
                "   Cancel." vvlcan format ">>>>,>>9.99"
                "     Total" vvlvnd - vvlcan format "->>>>,>>9.99"
                with frame fvltotvendedor no-labels width 160 no-box.
           vqtvnd = 0.
           vvlvnd = 0.
           vqtcan = 0.
           vvlcan = 0.
        end. 

        /**** Sintético ****/
        if vtiporel = 2 
        then do:
            if first-of(tt-mvg.etbcod)
            then do:
                find estab where estab.etbcod = vndseguro.etbcod no-lock.
                display estab.etbcod label "Estab"
                    estab.etbnom no-label
                    with frame fetbsint side-label.
            end.
            if first-of(tt-mvg.vencod) 
            then do:
                find func where func.funcod = vndseguro.vencod no-lock no-error.
                display 
                    vndseguro.vencod format "99999" label "Vendedor"
                    func.funnom no-label when avail func
                    with frame fvendsint side-label width 100. 
            end.

            if last-of(tt-mvg.vencod)
            then do:
                display skip(1)
                    "Total vendedor " 
                    "  Qtd" colon 39 space(6) vqtvnd format ">>,>>9"
                    "   Cancel."     space(6) vqtcan format ">>,>>9"
                    "     Total"     space(6) vqtvnd - vqtcan format "->>,>>9"
                    with frame ftotvendsint no-labels width 160 no-box.
                display 
                    "Venda" colon 39    vvlvnd    format ">>>>,>>9.99" 
                    "   Cancel."        vvlcan format ">>>>,>>9.99"
                    "     Total"        vvlvnd - vvlcan format "->>>>,>>9.99"
                    with frame fvltotvendsint no-labels width 160 no-box.

                vqtvnd = 0.
                vvlvnd = 0.
                vqtcan = 0.
                vvlcan = 0.
            end.
        end.

        if last-of(tt-mvg.etbcod)
        then do.
            find estab where estab.etbcod = vndseguro.etbcod no-lock no-error.

                put skip(2).
                display 
                    "Total Estab" vndseguro.etbcod /* colon 10 */
                    estab.etbnom no-label when avail estab
                    "  Qtd" colon 65 space(6) vqtetbvnd format ">>,>>9"
                    "   Cancel." space(6) vqtetbcan format ">>,>>9"
                    "     Total" space(6) vqtetbvnd - vqtetbcan
                            format "->>,>>9"
                    with frame ftotestab no-labels width 160 no-box.
                display
                    "Venda" colon 65   vvletbvnd format ">>>>,>>9.99"
                    "   Cancel."       vvletbcan format ">>>>,>>9.99"
                    "     Total"   vvletbvnd - vvletbcan format "->>>>,>>9.99"
                with frame fvltotestab no-labels width 160 no-box.
                put skip(1) fill("_",150) format "x(150)" skip.

            vqtetbvnd = 0.
            vvletbvnd = 0.
            vqtetbcan = 0.
            vvletbcan = 0.
        end.
    end.

    display "TOTAL DE VENDAS         " vqtgervnd vttgervnd skip(1)
        "TOTAL DE CANCELADOS     " vqtgercan vttgercan skip(1)
        "TOTAL LIQUIDO           " vqtgervnd - vqtgercan
        vttgervnd - vttgercan format ">,>>>,>>9.99"
        with frame ftotger no-labels.
end.


if vtiporel = 3
then
    for each tt-mvg no-lock,
         first vndseguro where recid(vndseguro) = tt-mvg.rec no-lock
                      break by tt-mvg.etbcod 
                            by tt-mvg.vencod
                            by tt-mvg.inclusao desc
                            by vndseguro.certifi.
        find produ of vndseguro no-lock.

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
        then find finan where finan.fincod = plani.pedcod no-lock.
        else if avail contrato
            then find finan where finan.fincod = contrato.crecod no-lock. 
        
        /**
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
        **/
        
        put unformatted
            vndseguro.etbcod  ";"
            vndseguro.certifi ";"
            vndseguro.dtincl  ";"
            tt-mvg.prgar   ";"
            produ.catcod      ";"
            vndseguro.clicod  ";"
            vndseguro.dtcanc  ";".

        if avail plani
        then
            put unformatted
                plani.pedcod ";"
                plani.platot ";"
                finan.finnom ";".
        /*else if log-operacao <> ""
            then put unformatted ";;;" log-operacao.
            */ else put unformatted ";;;;".    
        put unformatted skip.
    end.
        
output close.

if vtiporel <= 2
then run visurel.p (varquivo, "").
else message "Arquivo gerado:" varquivo view-as alert-box.



























































output close.

run visurel.p(varquivo,"").


