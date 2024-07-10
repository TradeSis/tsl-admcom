{admcab.i}
def buffer bprodu for produ.
def var v-exc like produ.procod.
def var vtipo as char format "x(20)" extent 2 initial["Moveis","Confeccoes"].
def var varquivo as char format "x(20)".
def var vok as log.
def var vpreco like estoq.estvenda.
def var i as i.
def var vdata like plani.pladat.
def var vetb  as char format "x(50)".
def var vqtd  as dec.
def var vclacod like produ.clacod.
DEF VAR VDPT AS I FORMAT "99" LABEL "Departamento".
DEF VAR VQTDTOT AS INT FORMAT "->>>9" label "TOT.".
def var vcont   as int initial 0.
def var vtip    as char format "X".
def var vprocod like produ.procod.



def temp-table wfcod
    field cod like produ.procod.

repeat:
    for each wfcod:
        find produ where produ.procod = wfcod.cod no-lock.
        pause 0.
        display produ.procod
                produ.pronom
                produ.catcod with frame f-down row 7
                                down width 80 color white/cyan.
    end.
    update vprocod
                help "[ C ] - Consulta   [ E ] - Exclusao"
                            go-on( "C" "c" "E" "e" return)
            with frame ff2 centered SIDE-LABEL.

    sresp = no.
    if keyfunction(lastkey) = "E" or
       keyfunction(lastkey) = "e"
    then do:
        for each wfcod:
            find produ where produ.procod = wfcod.cod no-lock.
            display produ.procod
                    produ.pronom
                    produ.catcod with frame f-down2
                            10 down width 80 color white/cyan.
        end.

        update v-exc with frame f-exc side-label width 80 row 21
                                        color message no-box.
        find produ where produ.procod = v-exc no-lock no-error.
        if not avail produ
        then do:
            message "Produto nao cadastrado".
            undo, retry.
        end.
        display produ.pronom no-label format "x(30)" with frame f-exc width 80.
        update sresp label "Excluir ? " with frame f-exc overlay.
        if sresp
        then do:
            find first wfcod where wfcod.cod = produ.procod no-error.
            if not avail wfcod
            then do:
                message "Produto nao digitado".
                undo, retry.
            end.
            delete wfcod.
            sresp = no.
        end.
        for each wfcod:
            find produ where produ.procod = wfcod.cod no-lock.
            pause 0.
            display produ.procod
                    produ.pronom
                    produ.catcod with frame f-down4
                            10 down width 80 color white/cyan.
        end.
    end.
    if keyfunction(lastkey) = "C" or
       keyfunction(lastkey) = "c"
    then do:
        for each wfcod:
            find produ where produ.procod = wfcod.cod no-lock.
            display produ.procod
                    produ.pronom
                    produ.catcod with frame f-down1
                            10 down width 80 color white/cyan.
        end.
    end.
    if keyfunction(lastkey) = "return" and sresp = no
    then do:
        find produ where produ.procod = vprocod no-lock no-error.
        if not avail produ
        then do:
            message "produto nao cadastrado".
            undo, retry.
        end.
        display produ.pronom no-label with frame ff2.
        find first wfcod where wfcod.cod = produ.procod no-error.
        if not avail wfcod
        then do:
            create wfcod.
            assign wfcod.cod = produ.procod.
        end.
    end.
 end.
    display vtipo no-label with frame f-tipo side-label centered.
    {confir.i 1 "Livro de Preco"}
    varquivo = "\admcom\relat\anacom" + STRING(day(today)).


    {mdadmcab.i
        &Saida     = "value(varquivo)"
        &Saida     = "printer"
        &Page-Size = "64"
        &Cond-Var  = "160"
        &Page-Line = "66"
        &Nom-Rel   = """LUIZ24"""
        &Nom-Sis   = """SISTEMA DE ESTOQUE"""
        &Tit-Rel   = """CONTROLE DE ESTOQUE"""
        &Width     = "160"
        &Form      = "frame f-cab"}

    for each wfcod:
    for each produ where produ.procod = wfcod.cod no-lock by produ.pronom:

        
        vqtd = 0.
        i = 0.

        vetb = "".
        for each estoq where estoq.procod = produ.procod no-lock:
            vqtd = vqtd + estoq.estatual.
            if estoq.estatual <> 0
            then do:
                vetb = trim(vetb) + " " + string(estoq.etbcod).
            end.
        end.
        if vqtd = 0
        then next.

        find first estoq where estoq.procod = produ.procod no-lock no-error.
        if not avail estoq
        then next.

        display produ.procod
                produ.pronom format "x(45)" 
                estoq.estvenda column-label "Preco!Venda"
                estoq.estproper column-label "Preco!Promocao" format ">>,>>9.99"
                            when estoq.estproper <> 0
                vqtd  column-label "Quant!Estoque" format "->,>>9.99" space(3)
                vetb  column-label "Filiais"    
                    with frame f-frame down width 200.
    end.
    end.
    output close.

    /* dos silent value("type" + varquivo + "prn"). */

     dos silent value("type " + varquivo + " > prn").
