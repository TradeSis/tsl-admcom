 /*****************************************************************************
  Programa          : Consulta de exportacoes por fazer.
  Nome do Programa  : ContExp.p
  Criacao           : 29/11/1996
 *****************************************************************************/
 {admcab.i}

 def var vdtexp         as date.
 def buffer bexporta    for exporta.
 def var vsem                    as char format "x(03)" extent 7
                                 initial ["Dom","Seg","Ter","Qua","Qui","Sex",
                                          "Sab"].
 def temp-table wf-atu
              field regcod  like regiao.regcod
              field exporta like exporta.exporta.

 for each estab no-lock:
    find last exporta where exporta.etbcod = estab.etbcod no-lock no-error.
    if avail exporta
    then vdtexp = exporta.exporta - 1.
    else next.

    find regiao where regiao.regcod = estab.regcod no-lock no-error.
    if not avail regiao
    then next.

    if avail exporta
    then repeat:
        vdtexp = vdtexp + 1.
        if vdtexp = today
        then leave.
        if weekday(vdtexp) = 1
        then next.
        find dtextra where dtextra.exdata  = vdtexp no-error.
        if avail dtextra
        then do:
            find next exporta where exporta.etbcod = estab.etbcod no-lock
                                                                no-error.
            next.
        end.

        find bexporta where bexporta.etbcod  = estab.etbcod and
                            bexporta.exporta = vdtexp no-lock no-error.
        if not avail bexporta
        then do:
            find first wf-atu where wf-atu.exporta = ? no-error.
            if not avail wf-atu
            then create wf-atu.
            assign  wf-atu.regcod  = regiao.regcod
                    wf-atu.exporta = vdtexp.
        end.
        find next exporta where exporta.etbcod = estab.etbcod no-lock no-error.
    end.
end.

bell.

for each regiao no-lock:
    for each wf-atu where wf-atu.regcod = regiao.regcod
                                        break by wf-atu.exporta
                                              by wf-atu.regcod:
        if wf-atu.regcod = 99
        then next.
        if last-of(wf-atu.exporta)
        then do:
            display wf-atu.regcod
                    wf-atu.exporta
                    vsem[weekday(wf-atu.exporta)] label "Dia"
                    with centered color white/red title " EXPORTACOES A FAZER "
                        15 down row 4.
            pause.
            delete wf-atu.
        end.
    end.
end.
