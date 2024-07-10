{admcab.i}

def var vdtref as date label "Data de Referencia".

def temp-table canreg
    field etbcod like estab.etbcod
    field regmes as i label "Reg.Mes"
    field regdia as i label "Reg.TOT"
    field canmes as i label "Can.Mes"
    field candias as i
    field canmed as i label "Prazo Medio".

repeat:

    update vdtref with frame f1 centered side-labels.

    for each estab:

        create canreg.
        assign canreg.etbcod = estab.etbcod.

    end.

    for each clispc where clispc.dtcan = ?:

        find contrato where contrato.contnum = clispc.contnum no-error.
        if not avail contrato then next.

        find first canreg where canreg.etbcod = contrato.etbcod.

        regdia = regdia + 1.

        disp regdia with 1 down.
        pause 0.

    end.

    for each clispc where month(clispc.dtneg) = month(vdtref):

        find contrato where contrato.contnum = clispc.contnum no-error.
        if not avail contrato then next.

        find first canreg where canreg.etbcod = contrato.etbcod.

        regmes = regmes + 1.

        disp regmes with 1 down.
        pause 0.

    end.

    for each clispc where month(clispc.dtcan) = month(vdtref):

        find contrato where contrato.contnum = clispc.contnum no-error.
        if not avail contrato then next.

        find first canreg where canreg.etbcod = contrato.etbcod.

        canmes = canmes + 1.

        disp canmes with 1 down.
        pause 0.

        candias = candias + (clispc.dtcan - clispc.dtneg).

        disp candias with 1 down.
        pause 0.

    end.

    for each canreg:

        canmed = candias / canmes.

        if canreg.regmes = 0 and
           canreg.regdia = 0 and
           canreg.canmes = 0 and
           canreg.candias = 0
        then delete canreg.

    end.

    for each canreg:

        find estab where estab.etbcod = canreg.etbcod no-lock.

        disp canreg.etbcod
             canreg.regdia (TOTAL)
             canreg.regmes (TOTAL)
             canreg.canmes (TOTAL)
             canreg.canmed (AVERAGE) with frame ff2 down row 5.

    end.

    {mdadmcab.i &Saida = "printer"
             &Page-Size = "64"
             &Cond-Var  = "80"
             &Page-Line = "66"
             &Nom-Rel   = """"
             &Nom-Sis   = """SISTEMA CREDIARIO"""
             &Tit-Rel   = """ DEMONSTRATIVO DO SPC - DATA BASE ""  +
                              STRING(VDTREF)"
             &Width     = "80"
             &Form      = "with frame f-cab1"}

    for each canreg:

        find estab where estab.etbcod = canreg.etbcod no-lock.

        disp canreg.etbcod
             /*estab.etbnom  format "x(20)"*/
             canreg.regdia (TOTAL)
             canreg.regmes (TOTAL)
             canreg.canmes (TOTAL)
             canreg.canmed (AVERAGE).

    end.

    for each canreg:
        delete canreg.
    end.

end.
