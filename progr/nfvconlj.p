{admcab.i}

def new shared temp-table tp-pro like com.produ.
def new shared temp-table tpb-pedid like com.pedid.
def new shared temp-table tpb-liped like com.liped.
def new shared temp-table tpb-contnf
        field etbcod  like contnf.etbcod
        field placod  like contnf.placod
        field contnum like contnf.contnum
        field marca   as   char format "x".
def new shared temp-table tpb-contrato like contrato.
def new shared temp-table tt-asstec
    field etbcod  as int  format ">>9"
    field oscod   as int  format ">>>>>>9"
    field procod  as int  format ">>>>>>>9"
    field clicod  as int  format ">>>>>>>>9"
    field plaetb  as int  format ">>9"
    field planum  as int  format ">>>>>>>9"
    field serie   as char format "x(8)"
    field apaser  as char format "x(20)"
    field proobs  as char format "x(60)"
    field defeito as char format "x(60)"
    field nftnum  as int  format ">>>>>>>9"
    field dtentdep as date format "99/99/9999"
    field dtenvass as date format "99/99/9999"
    field reincid as log format "Sim/Nao"
    field dtretass as date format "99/99/9999"    
    field dtenvfil as date format "99/99/9999"
    field osobs as char format "x(60)"
    field pladat as date format "99/99/9999"
    field forcod as int format ">>>>>9"
    field datexp as date format "99/99/9999".
 
def var vetbcod like plani.etbcod.
def var vnumero like plani.numero format ">>>>>>9".
def var vserie  like plani.serie.
def var varquivo as char.
def var vtotal as dec.
def var ttotal as dec.
def var vchave like plani.ufemi.

form with frame f6.

def temp-table tp-plani like plani.
def temp-table tp-movim like movim.
repeat:
    vetbcod = setbcod.
    disp vetbcod with frame f1 centered side-labels color white/red.
    find estab where estab.etbcod = vetbcod no-lock.
    disp estab.etbnom no-label with frame f1.

    update vnumero
           vserie format "x(3)"
           with frame f1.

     find first plani where plani.movtdc = 5 and
                            plani.etbcod = vetbcod and
                            plani.emite  = vetbcod and
                            plani.serie  = vserie and
                            plani.numero = vnumero NO-LOCK no-error.
     if not avail plani
     then do:
        sresp = no.
        message "Nota Fiscal nao encontrada.".
        pause.
        next.
     end.
     else do:
        create tp-plani.
        buffer-copy plani to tp-plani.
        for each movim where movim.etbcod = plani.etbcod and
                             movim.placod = plani.placod and
                             movim.movdat = plani.pladat and
                             movim.movtdc = plani.movtdc no-lock:
            create tp-movim.
            buffer-copy movim to tp-movim.
        end.    
     end.
     sresp = no.
     for each tp-plani:
        find func where func.etbcod = tp-plani.etbcod and
                        func.funcod = tp-plani.vencod no-lock no-error.
        disp tp-plani.pladat
             tp-plani.vencod 
             func.funnom when avail func
             string(tp-plani.horincl,"hh:mm") label "Hora" with frame f1.
        find clien where clien.clicod = tp-plani.desti no-lock no-error.
        if avail clien
        then do:
            disp clien.clicod
                 clien.clinom no-label
                 clien.endereco[1] + " , " + string(clien.numero[1])
                 format "x(50)" label "Endereco"
                 with frame f3 centered color black/cyan side-labels.
        end.

        if tp-plani.ufemi = "" then vchave = tp-plani.ufdes.
        else vchave = tp-plani.ufemi.

        find finan where finan.fincod = tp-plani.pedcod no-lock.
        disp finan.fincod label "Plano"
             finan.finnom
             finan.finfat no-label 
             tp-plani.cxacod label "CX"
             tp-plani.vlserv label "Devolucao"
             vchave format "x(50)"  label "Chave" 
             /*tp-plani.biss   label "Total Contrato"*/ with frame f1.

        sresp = yes.
        for each tp-movim where tp-movim.etbcod = tp-plani.etbcod and
                             tp-movim.placod = tp-plani.placod and
                             tp-movim.movdat = tp-plani.pladat and
                             tp-movim.movtdc = tp-plani.movtdc no-lock:
            find produ where produ.procod = tp-movim.procod no-lock no-error.
            if produ.catcod = 41
            then sresp = yes.
            disp tp-movim.procod
                 produ.pronom format "x(25)" when avail produ
                 tp-movim.movqtm (total)
                 tp-movim.movpc
                (tp-movim.movqtm * tp-movim.movpc) (total)
                 with frame f2 centered color white/cyan down.
        end.
     end.
     sresp = no.
     if sresp
     then do:
        sresp = no.
        message "Deseja imprimir?" update sresp.
        if sresp
        then do:
            ttotal = 0.
            varquivo = "/usr/admcom/relat/nfvenco".
            output to value(varquivo).
             /*
            {mdadmcab.i &Saida     = "value(varquivo)"
                &Page-Size = "64"
                &Cond-Var  = "100"
                &Page-Line = "66"
                &Nom-Rel   = ""nfvenco""
                &Nom-Sis   = """SISTEMA DE VENDAS"""
                &Tit-Rel   = """ """
                &Width     = "100"
                &Form      = "frame f-cabcab"}
            */
            for each tp-plani:
                find func where func.etbcod = tp-plani.etbcod and
                        func.funcod = tp-plani.vencod no-lock no-error.
                disp vetbcod    label "Filial"
                     estab.etbnom   no-label
                     vnumero    at 1     label "Numero"
                     /*vserie          label "Serie" */
                     tp-plani.pladat
                     string(tp-plani.horincl,"hh:mm") label "Hora"                      tp-plani.vencod  at 1
                     func.funnom when avail func    no-label
                    with frame f5 side-label.
                find clien where 
                    clien.clicod = tp-plani.desti no-lock no-error.
                if avail clien
                then do:
                    disp clien.clicod at 1 label "Cliente"
                    clien.clinom no-label
                    clien.endereco[1] + " , " + string(clien.numero[1])
                     format "x(50)" label "Endereco"
                    with frame f5 .
                end.
                vtotal = 0.
                put fill("=",80) format "x(60)".
                for each tp-movim where tp-movim.etbcod = tp-plani.etbcod and
                             tp-movim.placod = tp-plani.placod and
                             tp-movim.movdat = tp-plani.pladat and
                             tp-movim.movtdc = tp-plani.movtdc no-lock:
                    find produ where 
                    produ.procod = tp-movim.procod no-lock no-error.
                    vtotal = (tp-movim.movqtm * tp-movim.movpc).

                    disp tp-movim.procod column-label "Codigo"
                        produ.pronom format "x(27)" when avail produ
                            column-label "Descricao"
                        tp-movim.movqtm  column-label "Qtd" format ">>>9"
                        tp-movim.movpc   format ">>,>>9.99"
                            column-label "Valor!Unitario"
                        vtotal column-label "Total" format ">>>,>>9.99"
                        with frame f6 down no-box.
                        down with frame f6.
                        ttotal = ttotal + vtotal.

                end.
                down(2) with frame f6.
                disp ttotal @ vtotal with frame f6.
                output close.
                /*
                run visurel.p(varquivo,"").
                */
                os-command silent /fiscal/lp value(varquivo).
            end.
        end.
    end.
    leave.
end.
