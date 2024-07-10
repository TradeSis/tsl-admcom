{admcab.i}
def var vperc as dec format ">>9.99%".
def var vfincod like finan.fincod.
def var ii as int.
def var vok as log.
def var vcatcod like produ.catcod.
def var i as i.
def var varquivo as char format "x(20)".
def var wtotal     like plani.platot.
def var vdata      like plani.pladat.
def var vdtini     like plani.pladat         initial today.
def var vdtfim     like plani.pladat         initial today.
def var vetbi like estab.etbcod.
def var vetbf like estab.etbcod.
def stream stela.
def var vlcomis as dec.

def temp-table wplano
             field etbcod   like plani.etbcod
             field vencod   like plani.vencod
             field contra   as integer
             field valor    as dec format ">>,>>>,>>9.99".
repeat:
    wtotal = 0.
    I = 0.
    for each wplano:
        delete wplano.
        I = I + 1.
        display "AGUARDE, ZERANDO ARQUIVOS   " I
                with frame f-disp side-label row 15 centered.
        pause 0.
    end.
    hide frame f-disp no-pause.

    update vcatcod label "Departamento"
                    with frame f1.
    find categoria where categoria.catcod = vcatcod no-lock.
    display categoria.catnom no-label with frame f1.
    update vetbi colon 13 label "Filial"
           vetbf label "Filial"
            with frame f1 side-label width 80 color white/cyan.



    update vdtini    label "Data Inicial"
           vdtfim    label "Data Final" with frame f2
                        side-label width 80 color white/cyan.
                        
    update vfincod label "Plano" colon 13 with frame f2.

    vperc = 0.
    find finan where finan.fincod = vfincod no-lock no-error.
    display finan.finnom no-label with frame f2.
    update vperc label "% Comissao" with frame f2.
                        

    for each estab where estab.etbcod >= vetbi and
                         estab.etbcod <= vetbf no-lock:
        do vdata = vdtini to vdtfim:

            for each plani where plani.movtdc = 5             and
                                 plani.etbcod = estab.etbcod  and
                                 plani.pladat = vdata         and
                                 plani.pedcod = finan.fincod no-lock:
                vok = no.
                for each movim where movim.placod = plani.placod and
                                     movim.etbcod = plani.etbcod and
                                     movim.movtdc = plani.movtdc and
                                     movim.movdat = plani.pladat no-lock:
                    find produ where produ.procod = movim.procod 
                                                no-lock no-error.
                    if not avail produ
                    then next.
                    if produ.catcod = vcatcod 
                    then vok = yes.
                end.
                if vok = no
                then next.
                output stream stela to terminal.
                    display stream stela
                            plani.etbcod
                            plani.pladat with frame f-stream row 12
                                                    centered side-label.
                    pause 0.
                output stream stela close.
                find first wplano where wplano.etbcod = plani.etbcod and
                                        wplano.vencod = plani.vencod
                                                no-error.
                if not avail wplano
                then do:
                    create wplano.
                    assign wplano.etbcod = plani.etbcod
                           wplano.vencod = plani.vencod.
                end.
                assign wplano.contra = wplano.contra + 1.
                if plani.crecod = 2
                then wplano.valor  = wplano.valor + plani.biss.
                else wplano.valor  = wplano.valor + plani.platot -
                                     plani.vlserv - plani.descprod +
                                     plani.acfprod.
            end.
        end.
    end.

    for each wplano:
        wtotal = wtotal + wplano.valor.
    end.

    varquivo = "..\relat\comipla" +  STRING(month(today)).

    {mdad.i &Saida     = "value(varquivo)"
                &Page-Size = "64"
                &Cond-Var  = "160"
                &Page-Line = "66"
                &Nom-Rel   = ""COMI_PLA""
                &Nom-Sis   = """DEPARTAMENTO PESSOAL"""
                &Tit-Rel   = """COMISSAO DE VENDAS POR PLANO "" +
                                "" PERIODO DE "" +
                                string(vdtini) + "" A "" + string(vdtfim) +
                                ""  "" + string(vcatcod) + ""  FILIAL "" +
                                string(vetbi,"">>9"") + "" A "" +
                                string(vetbf,"">>9"")"
                &Width     = "160"
                &Form      = "frame f-cabcab"}


    for each wplano break by wplano.etbcod
                          by wplano.vencod.

        if first-of(wplano.etbcod)
        then do:
            display "F I L I A L - " wplano.etbcod no-label format ">>9"
                    "     P L A N O : " vfincod format "99" no-label
                    " " finan.finnom no-label          
                    "     D E P.    " categoria.catnom no-label
                            with frame f-1 side-label width 200.
        end.
        find func where func.etbcod = wplano.etbcod and
                        func.funcod = wplano.vencod no-lock no-error.
        
        vlcomis = (wplano.valor * (vperc / 100)).        

                
        display wplano.vencod label "Vendedor"  format "99"
                func.funnom no-label when avail func
                wplano.contra column-label "N.Contratos." 
                                (total by wplano.etbcod)
                wplano.valor column-label "Valor Total" 
                                (total by wplano.etbcod)
                ((wplano.valor / wtotal) * 100)(total by wplano.etbcod) 
                                 label " % " format ">>9.99 %"
                vlcomis(total by wplano.etbcod) label "       "
                    with color white/red width 200 row 8 centered down.
                    
        vlcomis:label = string(vperc,">>9.99%").        

    end.
    output close.
    {mrod.i}
end. 

