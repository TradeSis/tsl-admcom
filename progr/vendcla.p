{admcab.i}
def var vdti    as date.
def var vdtf    as date.
def var vfuncod like func.funcod label "Funcionario".
def var vetbcod like plani.etbcod.
DEF VAR VCLACOD LIKE CLASE.CLACOD.
DEF VAR VCLANOM LIKE CLASE.CLANOM.

def buffer bclase for clase.
def buffer cclase for clase.
def buffer dclase for clase.
def buffer eclase for clase.
def buffer fclase for clase.

def temp-table wfuncla
    field etbcod like estab.etbcod
    field funcod like func.funcod
    field clacod like clase.clacod
    field clanom like clase.clanom
    field quant  as dec
    field valor  as dec
    field quantdev as dec
    field valordev as dec.

vdti = today - 30.
vdtf = today.

do:

    update vetbcod vfuncod with frame f1 centered side-label color blue/cyan
                                            row 4 width 80.
    find estab where estab.etbcod = vetbcod no-lock no-error.
    if not avail estab
    then do:
        message "Estabelecimento nao Cadastrado".
        undo.
    end.
    if vfuncod <> 0
    then do:
        find func where func.etbcod = vetbcod and
                        func.funcod = vfuncod no-lock.
        disp func.funnom no-label with frame f1.
    end.
    update vdti label "Dt.Inicial"
           vdtf label "Dt.Final" with frame f-dat centered row 8 color blue/cyan
                                        side-label title(" Periodo ").

        {mdadmcab.i
            &Saida     = "printer"
            &Page-Size = "64"
            &Cond-Var  = "80"
            &Page-Line = "66"
            &Nom-Rel   = ""VENDCLA""
            &Nom-Sis   = """SISTEMA DE VENDAS"""
       &Tit-Rel   = """RELATORIO DE VENDAS POR VENDEDOR/CLASSE - PERIODO DE "" +
                                  string(vdti,""99/99/9999"") + "" A "" +
                                  string(vdtf,""99/99/9999"") "
            &Width     = "80"
            &Form      = "frame f-cabcab"}

        disp space "Loja:" space(2)
        estab.etbnom no-label space.

        put fill("-",80) format "x(80)" skip.

        for each plani where plani.etbcod = vetbcod and
                             (plani.movtdc = 5 or
                              plani.movtdc = 12) and
                             plani.pladat >= vdti and
                             plani.pladat <= vdtf and
                             plani.vencod > 0 and
                             (if vfuncod = 0
                                then true
                                else plani.vencod = vfuncod) no-lock:

            if plani.movtdc = 5
            then do:
                for each movim where movim.etbcod = plani.etbcod and
                                     movim.placod = plani.placod:

                    find produ of movim no-lock.
                    vclacod = produ.clacod.


                    find first wfuncla where wfuncla.funcod = plani.vencod and
                                             wfuncla.clacod = vclacod
                                             no-error.
                    if not avail wfuncla
                    then do:
                        find clase where clase.clacod = vclacod no-lock.
                        vclanom = clase.clanom.
                        create wfuncla.
                        assign wfuncla.etbcod = plani.etbcod
                               wfuncla.funcod = plani.vencod
                               wfuncla.clacod = vclacod
                               wfuncla.clanom = vclanom.
                    end.
                    wfuncla.quant = wfuncla.quant + movim.movqtm.
                end.
            end.
            /*
            if plani.movtdc = 12
            then do:
                for each movim where movim.etbcod = plani.etbcod and
                                     movim.placod = plani.placod:

                    find produ of movim no-lock.

                    find bclase of produ no-lock.
                    if bclase.clasup = 19
                    then assign vclacod = bclase.clacod
                         vclanom = bclase.clanom.

                    if avail bclase then do:
                        find cclase where cclase.clacod = bclase.clasup
                                          no-lock no-error.
                        if avail cclase then do:
                            if cclase.clasup = 19
                            then assign vclacod = cclase.clacod
                                        vclanom = cclase.clanom.

                            find dclase where dclase.clacod = cclase.clasup
                                              no-lock no-error.
                            if avail dclase then do:
                                if dclase.clasup = 19
                                then assign vclacod = dclase.clacod
                                            vclanom = dclase.clanom.

                                find eclase where eclase.clacod = dclase.clasup
                                              no-lock no-error.
                                if avail eclase then do:
                                    if eclase.clasup = 19
                                    then assign vclacod = eclase.clacod
                                                vclanom = eclase.clanom.

                                    find fclase
                                         where fclase.clacod = eclase.clasup
                                         no-lock no-error.
                                    if avail fclase then do:
                                        if fclase.clasup = 19
                                        then assign vclacod = fclase.clacod
                                                    vclanom = fclase.clanom.
                                    end.
                                end.
                            end.
                        end.
                    end.

                    find first wfuncla where wfuncla.funcod = plani.vencod and
                                             wfuncla.clacod = vclacod no-error.
                    if not avail wfuncla
                    then do:
                        create wfuncla.
                        assign wfuncla.etbcod = plani.etbcod
                               wfuncla.funcod = plani.vencod
                               wfuncla.clacod = vclacod
                               wfuncla.clanom = vclanom.
                    end.
                    wfuncla.quantdev = wfuncla.quantdev + movim.movqtm.
                end.
            end.
            */
        end.

        for each wfuncla where wfuncla.quant > 0
                         break by wfuncla.funcod
                               by wfuncla.clacod:

            find func where func.etbcod = wfuncla.etbcod and
                            func.funcod = wfuncla.funcod no-lock.
            if first-of(wfuncla.funcod)
            then do:
                disp func.funcod
                     func.funnom no-label
                     skip(1) with frame f-vend side-label.
            end.

            disp wfuncla.clacod
                 wfuncla.clanom
                 space(5)
                 wfuncla.quant column-label "Qtd.Vendida"
                 (TOTAL BY WFUNCLA.FUNCOD)
                 space(5)
                 wfuncla.quantdev column-label "Qtd.Devolvida"
                 (TOTAL BY WFUNCLA.FUNCOD)
                 with frame fff down.
        end.
    output close.
end.
