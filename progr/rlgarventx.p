/*                       
Nov/2017: Projeto Garantia / RFQ
*/
{admcab.i}

{filtro-estab.def}
def var vdata    as date.
def var vdtini   as date.
def var vdtfim   as date.
def var vtiporel as log format "Analitico/Sintetico" init yes.
def var vperc    as dec label "Perc" format ">>9.99%".
def var vpos     as int.
def var vopc     as char format "x(28)" extent 2
    initial [" ESTABELECIMENTO/VENDEDOR "," GERAL "].
def var vmodelo  as int.
def var varquivo as char.

def var vtfuvnd  as int extent 2 format "->>>,>>9".
def var vtfugar  as int extent 2 format "->>>,>>9".
def var vtljvnd  as int extent 2 format "->>>,>>9".
def var vtljgar  as int extent 2 format "->>>,>>9".
def var vtgcanc  as int extent 2 format "->>>,>>9".
def var vtgrecup as int extent 2 format "->>>,>>9".
def var vtgprgar as dec extent 2 format "->>>,>>9".
def var vtgrvnd  as int extent 2 format "->>>,>>9".
def var vtgrgar  as int extent 2 format "->>>,>>9".
def var vpercent as dec extent 2 format "->>>9.9".

def temp-table tt-produ
    field procod   like segprodu.procod
    field etbcod   like plani.etbcod
    field funcod   like plani.vencod
    field tpseguro like segprodu.tpseguro
    field subtipo  like segprodu.subtipo
    field meses    like segprodu.meses
    field Venda    as int extent 2 format "->>>,>>9"
    field Seguro   as int extent 2 format "->>>,>>9"
    field vlmeta   as dec
    index produ is primary unique  procod etbcod funcod.

form
    vEstab   colon 31 label "Todos Estabelecimentos"
             help "Relatorio com Todos os Estabelecimentos ?"
    cestab   no-label format "x(30)"
    vdtini   colon 31 label "Venda"
    vdtfim   label "ate"
    vtiporel colon 31    label "Analitico / Sintetico"
    with frame fopcoes row 3 side-label width 80.

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
    update vtiporel.
end.

if vtiporel
then do.
    displa vopc with frame f-opc centered no-label 1 down
                 title " Ordenacao do Relatorio " row 10.
    choose field vopc with frame f-opc.
    vmodelo = frame-index.
end.

/*
  PROCESSAMENTO DE VENDAS
*/  
for each tipmov where tipmov.movtvenda no-lock.

    for each estab where estab.usap2k no-lock.
        if not vEstab
        then do:
            find wfEstab where wfEstab.Etbcod = Estab.Etbcod no-lock no-error.
            if not avail wfEstab
            then next.
        end.
    
        do vdata = vdtini to vdtfim.
            disp vdata estab.etbcod
                 with 1 down centered side-label with frame f-proc.
            pause 0.

            for each plani where plani.movtdc = tipmov.movtdc
                             and plani.etbcod = estab.etbcod
                             and plani.pladat = vdata
                           no-lock.
                find clien where clien.clicod = plani.desti no-lock no-error.
                if not avail clien
                then next.
                if not clien.tippes
                then next.

                for each movim where movim.etbcod = plani.etbcod
                                 and movim.placod = plani.placod
                                 and movim.movtdc = plani.movtdc
                                 and movim.movdat = plani.pladat
                               no-lock.

                    for each segtipo where segtipo.tpseguro = 5 /* Gar */
                                        or segtipo.tpseguro = 6 /* RFQ */
                                     no-lock.

                        find first segprodu
                                     where segprodu.procod = movim.procod
                                       and segprodu.tpseguro = segtipo.tpseguro
                                       and segprodu.dtivig <= movim.movdat
                                       and (segprodu.dtfvig = ? or
                                            segprodu.dtfvig >= movim.movdat)
                                     no-lock no-error.
                        if not avail segprodu
                        then next.

                        if vtiporel
                        then do.
                            if vmodelo = 1
                            then find first tt-produ where
                                          tt-produ.procod = movim.procod and
                                          tt-produ.etbcod = movim.etbcod and
                                          tt-produ.funcod = plani.vencod
                                          no-error.
                            if vmodelo = 2
                            then find first tt-produ where
                                          tt-produ.procod = movim.procod
                                          no-error.
                        end.
                        else if vmodelo = 1
                        then find first tt-produ
                                        where tt-produ.etbcod = movim.etbcod
                                          and tt-produ.funcod = plani.vencod
                                        no-error.
                        else find first tt-produ
                                        where tt-produ.etbcod = movim.etbcod
                                        no-error.

                        if not avail tt-produ
                        then do.
                            create tt-produ.
                            assign
                                tt-produ.procod = movim.procod
                                tt-produ.etbcod = movim.etbcod
                                tt-produ.funcod = plani.vencod
                                tt-produ.subtipo = segprodu.subtipo
                                tt-produ.vlmeta = 0.
                        end.

                        if segtipo.tpseguro = 5
                        then vpos = 1.
                        else vpos = 2.

                        if tipmov.movtdev = no
                        then tt-produ.venda[vpos] = tt-produ.venda[vpos]
                                                    + movim.movqtm.
                        else tt-produ.venda[vpos] = tt-produ.venda[vpos]
                                                    - movim.movqtm.

                        /* Verificar se teve garan para o item da venda
                           O QUE VENDEU
                        */
                        for each movimseg where movimseg.etbcod = movim.etbcod
                                            and movimseg.placod = movim.placod
                                            and movimseg.movseq = movim.movseq
                                            and movimseg.tpseguro =
                                                             segtipo.tpseguro
                                          no-lock.
                        if tipmov.movtdev = no
                        then tt-produ.Seguro[vpos] = tt-produ.Seguro[vpos] + 1.
                        else tt-produ.Seguro[vpos] = tt-produ.Seguro[vpos] - 1.
                    end.


                    end. /* segtipo */
                end. /* movim */
            end. /* plani */
        end. /* vdata */
    end. /* estab */
end. /* tipmov */
    
varquivo = "/admcom/relat/rlgarventx." + string(mtime).
{mdadmcab.i &Saida     = "value(varquivo)"   
            &Page-Size = "64"  
            &Cond-Var  = "116"
            &Page-Line = "66" 
            &Nom-Rel   = ""rlgarventx"" 
            &Nom-Sis   = """ """ 
            &Tit-Rel   = """TAXA DE CONVERSAO DE SEGUROS: "" +
                          string(vdtini) + "" ATE "" + string(vdtfim)" 
            &Width     = "116"
            &Form      = "frame f-cabcab"}

if vtiporel
then do.

if vmodelo = 1
then /* Estabelecimento */
    for each tt-produ no-lock
                      break by tt-produ.etbcod
                            by tt-produ.funcod
                            by tt-produ.procod.

        if first-of(tt-produ.etbcod)
        then do:
            find estab where estab.etbcod = tt-produ.etbcod no-lock.
            display estab.etbcod /* colon 10*/ label "Estab"
                    estab.etbnom no-label
                    with frame frestab side-label.
        end.

        if first-of(tt-produ.funcod)
        then do:
            find first func where func.funcod = tt-produ.funcod no-lock no-error.
            display tt-produ.funcod colon 20 label "Vendedor"
                    func.funnom no-label when avail func
                    with frame frvendedor side-label /*width 116*/.
        end.

        find produ of tt-produ no-lock.

        assign
            vtfuvnd[1] = vtfuvnd[1] + tt-produ.venda[1]
            vtfugar[1] = vtfugar[1] + tt-produ.seguro[1]
            vtljvnd[1] = vtljvnd[1] + tt-produ.venda[1]
            vtljgar[1] = vtljgar[1] + tt-produ.seguro[1]
            vtgrvnd[1] = vtgrvnd[1] + tt-produ.venda[1]
            vtgrgar[1] = vtgrgar[1] + tt-produ.seguro[1]

            vtfuvnd[2] = vtfuvnd[2] + tt-produ.venda[2]
            vtfugar[2] = vtfugar[2] + tt-produ.seguro[2]
            vtljvnd[2] = vtljvnd[2] + tt-produ.venda[2]
            vtljgar[2] = vtljgar[2] + tt-produ.seguro[2]
            vtgrvnd[2] = vtgrvnd[2] + tt-produ.venda[2]
            vtgrgar[2] = vtgrgar[2] + tt-produ.seguro[2]
            
            vpercent[1] = tt-produ.seguro[1] / tt-produ.venda[1] * 100
            vpercent[2] = tt-produ.seguro[2] / tt-produ.venda[2] * 100.

        disp
            tt-produ.procod
            produ.pronom
            tt-produ.subtipo   column-label "G"
            tt-produ.seguro[1] column-label "Garant"
            tt-produ.venda[1]  column-label "Vendas"
            vpercent[1] column-label "Taxa %"

            tt-produ.seguro[2] column-label "RFQ"
            tt-produ.venda[2]  column-label "Vendas"
            vpercent[2]    column-label "Taxa %"
            with frame f-linha width 160 no-box down.

        if last-of(tt-produ.funcod)
        then do:
            find first func where func.funcod = tt-produ.funcod
                       no-lock no-error.
            put skip(2).
            vpercent[1] = vtfugar[1] / vtfuvnd[1] * 100.
            vpercent[2] = vtfugar[2] / vtfuvnd[2] * 100.
            display
                "Total vendedor" colon 6 tt-produ.funcod
                func.funnom when avail func
                vtfugar[1]
                vtfuvnd[1]
                vpercent[1]
                vtfugar[2]
                vtfuvnd[2]
                vpercent[2]
                with frame ftotvendedor no-labels width 116 no-box.
            assign
                vtfugar = 0
                vtfuvnd = 0.
        end.

        if last-of(tt-produ.etbcod)
        then do:
            find estab where estab.etbcod = tt-produ.etbcod no-lock no-error.
            put skip(2).
            vpercent[1] = vtljgar[1] / vtljvnd[1].
            vpercent[2] = vtljgar[2] / vtljvnd[2].
            display
                "Total Estab." colon 6 tt-produ.etbcod
                estab.etbnom no-label when avail estab format "x(38)"
                vtljgar[1]
                vtljvnd[1]
                vpercent[1]
                vtljgar[2]
                vtljvnd[2]
                vpercent[2]
                with frame ftotestab no-labels width 116 no-box.

            put skip(1) fill("_",116) format "x(116)" skip.
            assign
                vtljgar = 0
                vtljvnd = 0.
        end.
    end.

if vmodelo = 2
then /* Geral */
    for each tt-produ where tt-produ.seguro[1] >= 0 or tt-produ.seguro[2] >= 0,
            produ where produ.procod = tt-produ.procod no-lock
                        break by produ.pronom.

        find produ of tt-produ no-lock.

        assign
            vtgrvnd[1] = vtgrvnd[1] + tt-produ.venda[1]
            vtgrgar[1] = vtgrgar[1] + tt-produ.seguro[1]

            vtgrvnd[2] = vtgrvnd[2] + tt-produ.venda[2]
            vtgrgar[2] = vtgrgar[2] + tt-produ.seguro[2]

            vpercent[1] = tt-produ.seguro[1] / tt-produ.venda[1] * 100.
            vpercent[2] = tt-produ.seguro[2] / tt-produ.venda[2] * 100.

        disp
            tt-produ.procod
            produ.pronom
            tt-produ.subtipo   column-label ""

            tt-produ.seguro[1] column-label "Garant" 
            tt-produ.venda[1]  column-label "Vendas"
            vpercent[1]        column-label "Taxa %"

            tt-produ.seguro[2] column-label "RFQ"
            tt-produ.venda[2]  column-label "Vendas"
            vpercent[2]        column-label "Taxa %"
            with frame f-linha2 width 160 down no-box.
    end.                        

    display skip(2) 
        "*** TOTAL GERAL ***" colon 26 format "x(35)"
        vtgrgar[1]
        vtgrvnd[1]
        vtgrgar[1] / vtgrvnd[1] * 100  format "->>>9.9"
        vtgrgar[2]
        vtgrvnd[2]
        vtgrgar[2] / vtgrvnd[2] * 100  format "->>>9.9"
        with frame ftotger no-labels width 136 no-box.

end.
else do. /*** Sintetico ***/
form with frame f-linha-s.

    for each tt-produ no-lock break by tt-produ.etbcod.
        find estab where estab.etbcod = tt-produ.etbcod no-lock.
        assign
            vtgrvnd[1]  = vtgrvnd[1]  + tt-produ.venda[1]
            vtgrgar[1]  = vtgrgar[1]  + tt-produ.seguro[1]

            vtgrvnd[2]  = vtgrvnd[2]  + tt-produ.venda[2]
            vtgrgar[2]  = vtgrgar[2]  + tt-produ.seguro[2]

            vpercent[1] = tt-produ.seguro[1] / tt-produ.venda[1] * 100
            vpercent[2] = tt-produ.seguro[2] / tt-produ.venda[2] * 100.

        display
            tt-produ.etbcod    column-label "Etb"
            estab.etbnom
            tt-produ.seguro[1] column-label "Garantia"
            tt-produ.venda[1]  column-label "Vendas"
            vpercent[1]        column-label "Taxa %"
            tt-produ.seguro[2] column-label "RFQ"
            tt-produ.venda[2]  column-label "Vendas"
            vpercent[2]        column-label "Taxa %"
            with frame f-linha-s width 136 down no-box.
        down with frame f-linha-s.
    end.

    vpercent[1] = vtgrgar[1] / vtgrvnd[1] * 100.
    vpercent[2] = vtgrgar[2] / vtgrvnd[2] * 100.
    down 1 with frame f-linha-s.
    disp
        vtgrvnd[1]  @ tt-produ.venda[1]
        vtgrgar[1]  @ tt-produ.seguro[1]
        vpercent[1]
        vtgrvnd[2]  @ tt-produ.venda[2]
        vtgrgar[2]  @ tt-produ.seguro[2]
        vpercent[2]
        with frame f-linha-s.
    down with frame f-linha-s.

/***
if vmodelo = 1
then /* Estabelecimento */
    for each tt-produ where tt-produ.seguro[1] >= 0 or tt-produ.seguro[2] >= 0
                      break by tt-produ.etbcod
                            by tt-produ.funcod.
        if first-of(tt-produ.etbcod)
        then do:
            find estab where estab.etbcod = tt-produ.etbcod no-lock.
            display estab.etbcod /* colon 10*/ label "Estab"
                estab.etbnom no-label
                with frame frestab999 side-label.
         end.
    end.                                        

if vmodelo = 2
then do:
    for each tt-produ where tt-produ.seguro[1] >= 0 or tt-produ.seguro[2] >= 0
                break by tt-produ.etbcod.
    end.
end.
***/

end.

output close.

run visurel.p(varquivo,"").

