{admcab.i}

def stream stela.

def var vdti    as date format "99/99/9999".
def var vdtf    as date format "99/99/9999".
def var vfuncod like func.funcod label "Funcionario".
def var vetbcod like plani.etbcod.

def var vplatottot      like plani.platot.
def var vdevtottot      like plani.platot.
def var vqtdplatot      as i.
def var vqtdmovtot      as i.
def var vqtdpladevtot   as i.
def var vqtdmovdevtot   as i.

def var vplatot         like plani.platot.
def var vdevtot         like plani.platot.
def var vqtdpla         as i.
def var vqtdmov         as i.
def var vqtdpladev      as i.
def var vqtdmovdev      as i.


vdti = today - 30.
vdtf = today.

repeat:
    assign vplatot = 0
           vdevtot = 0
           vqtdpla = 0
           vqtdmov = 0
           vqtdpladev = 0
           vqtdmovdev = 0.

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
            &Cond-Var  = "119"
            &Page-Line = "66"
            &Nom-Rel   = ""VENDSIN""
            &Nom-Sis   = """SISTEMA DE VENDAS"""
            &Tit-Rel   = """RELATORIO DE VENDAS POR VENDEDOR - PERIODO DE "" +
                                  string(vdti,""99/99/9999"") + "" A "" +
                                  string(vdtf,""99/99/9999"") "
            &Width     = "119"
            &Form      = "frame f-cabcab"}

        disp space "Loja:" space(2)
        estab.etbnom no-label space.

        put fill("-",119) format "x(119)" skip.

        for each plani where plani.etbcod = vetbcod and
                             (plani.movtdc = 5 or
                              plani.movtdc = 12) and
                             plani.pladat >= vdti and
                             plani.pladat <= vdtf and
                             plani.vencod >0 and
                             (if vfuncod = 0
                                then true
                                else plani.vencod = vfuncod) no-lock
                                break by plani.vencod
                                      by plani.pladat
                                      by plani.numero.

            output stream stela to terminal.
            disp stream stela plani.pladat plani.numero with 1 down. pause 0.
            output stream stela close.

            if first-of(plani.vencod)
            then do:

                find func where func.etbcod = plani.etbcod and
                                func.funcod = plani.vencod no-lock no-error.
                if not avail func
                then next.

                disp plani.vencod
                     func.funnom no-label with frame f-vend side-label.
            end.

            if plani.movtdc = 5
            then do:
                assign vplatot = vplatot + plani.platot
                       vqtdpla = vqtdpla + 1.
                for each movim where movim.etbcod = plani.etbcod and
                                     movim.placod = plani.placod:
                    vqtdmov = vqtdmov + movim.movqtm.
                end.
            end.

            if plani.movtdc = 12
            then do:
                assign vdevtot = vdevtot + plani.platot
                       vqtdpladev = vqtdpladev + 1.
                for each movim where movim.etbcod = plani.etbcod and
                                     movim.placod = plani.placod:
                    vqtdmovdev = vqtdmovdev + movim.movqtm.
                end.
            end.


            if last-of(plani.pladat)
            then do:

                if (vplatot - vdevtot) > 0
                then do:
                    if (vqtdpla - vqtdpladev) = 0
                    then vqtdpla = vqtdpla + 1.
                    if (vqtdmov - vqtdmovdev) = 0
                    then vqtdmov = vqtdmov + 1.
                end.

                if (vplatot - vdevtot) > 0
                then do:

                disp plani.pladat           label "Data"            SPACE(5)
                     (vplatot - vdevtot)    label "Venda"
                     (TOTAL BY PLANI.VENCOD)                        SPACE(5)
                     (vqtdpla - vqtdpladev) label "Qtd.NFs"
                     (TOTAL BY PLANI.VENCOD)                        SPACE(5)
                     (vqtdmov - vqtdmovdev) label "Qtd.Pecas"
                     (TOTAL BY PLANI.VENCOD)                        SPACE(5)
                     ((vqtdmov - vqtdmovdev) / (vqtdpla - vqtdpladev))
                                            label "Media Pecas/NFs"
                     (AVERAGE BY PLANI.VENCOD)                      SPACE(5)
                     ((vplatot - vdevtot) / (vqtdpla - vqtdpladev))
                                            label "Media Valor/NFs"
                     (AVERAGE BY PLANI.VENCOD)                      SPACE(5)
                     with frame f-pla down WIDTH 130.
                end.
                assign vplatottot = vplatottot + vplatot
                       vdevtottot = vdevtottot + vdevtot
                       vqtdplatot = vqtdplatot + vqtdpla
                       vqtdmovtot = vqtdmovtot + vqtdmov
                       vqtdpladevtot = vqtdpladevtot + vqtdpladev
                       vqtdmovdevtot = vqtdmovdevtot + vqtdmovdev.

                assign vplatot = 0
                       vdevtot = 0
                       vqtdpla = 0
                       vqtdmov = 0
                       vqtdpladev = 0
                       vqtdmovdev = 0.

            end.
            if last-of(plani.vencod)
            then do:

                put skip(1).

                /*
                disp plani.pladat           label "Data"
                     (vplatot - vdevtot)    label "Total no Dia"
                     (vqtdpla - vqtdpladev) label "Qtd.NFs"
                     (vqtdmov - vqtdmovdev) label "Qtd.Pecas"
                     ((vqtdmov - vqtdmovdev) / (vqtdpla - vqtdpladev))
                                            label "Media Pecas/NFs"
                     ((vplatot - vdevtot) / (vqtdpla - vqtdpladev))
                                            label "Media Valor/NFs"
                     with frame f-pla down.



                put "___________" at 13 skip
                    "Total Vend" space(1)
                    vtotven skip(1).
                */

                assign vplatottot = 0
                       vdevtottot = 0
                       vqtdplatot = 0
                       vqtdmovtot = 0
                       vqtdpladevtot = 0
                       vqtdmovdevtot = 0.

            end.
        end.
    output close.
end.
