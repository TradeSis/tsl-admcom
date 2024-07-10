{admcab.i}
def var vfin as l.
def var vplatot like plani.platot.
def var vfincod like finan.fincod extent 40.
def var vlmin   like titulo.titvlcob.
def var vlmax   like titulo.titvlcob.
def var i as    i.
def var v as    i.
def var vdt     as date format "99/99/9999".
def var vdtven  as date format "99/99/9999".
def var vdti    as date format "99/99/9999".
def var vdtf    as date format "99/99/9999".
def var vlcont  like titulo.titvlcob.
def var vvlent   like titulo.titvlcob format ">,>>9.99".
def var vok     as l.
def var vok1    as l.
def stream      stela.
def buffer bcontnf for contnf.
def var vtotal like titulo.titvlcob.
def temp-table wcdci
    field wplano like finan.fincod
    field wqtd   as int
    field wnf    like plani.platot
    field went   like plani.platot
    field wfin   like plani.platot
    field wacr   like plani.platot
    field wbru   like plani.platot.

repeat:
    if vtotal <> 0
    then display vtotal with frame f-tot centered side-label row 4 OVERLAY.
    vtotal = 0.
    for each wcdci:
        delete wcdci.
    end.

    update vdti label "Periodo"
           "a"
           vdtf no-label
           vlmax label "Valor Maximo"
           vlmin label "Valor Min.NF"
                with frame f-dat centered color blue/cyan row 8
                                    title " Periodo ".
        update vfincod
               no-label with frame f-planos title "PLANOS".

        {mdadmcab.i
            &Saida     = "printer"
            &Page-Size = "64"
            &Cond-Var  = "130"
            &Page-Line = "66"
            &Nom-Rel   = ""x""
            &Nom-Sis   = """ """
            &Tit-Rel   = """RELACOES DOS CONTRATOS CDCI NEGOCIADOS"""
            &Width     = "130"
            &Form      = "frame f-cabcab"}

        vok1 = yes.
        do vdt = vdti to vdtf:
            do i = 1 to 32:
                for each plani where plani.movtdc = 5             and
                                     plani.etbcod = i             and
                                     plani.pladat = vdt no-lock:

                    if plani.crecod = 1
                    then next.
                    if plani.vlserv > 0
                    then next.
                    if plani.outras > 0
                    then do:
                        if plani.outras < vlmin
                        then next.
                    end.
                    else do:
                        if plani.platot < vlmin
                        then next.
                    end.
                    find clien where clien.clicod = plani.desti
                                                        no-lock no-error.
                    if not avail clien
                    then next.
                    if clien.ciccgc = ?
                    then next.
                    if clien.ciccgc = ""
                    then next.
                    if substring(string(clien.ciccgc),1,1) = "0"
                    then next.
                    if substring(string(clien.ciccgc),1,1) = "*"
                    then next.
                    if substring(string(clien.ciccgc),1,1) = ""
                    then next.
                    vok = yes.
                    vlcont = 0.
                    vvlent  = 0.
                    vfin = no.
                    for each contnf where contnf.etbcod  = plani.etbcod and
                                          contnf.placod  = plani.placod no-lock:
                        find contrato where contrato.contnum = contnf.contnum
                                                             no-lock no-error.
                        if not avail contrato
                        then do:
                            vok = no.
                            leave.
                        end.
                        else do:
                            find finan where finan.fincod = contrato.crecod
                                                        no-lock no-error.
                            if avail finan
                            then do:
                                vfin = yes.
                                do v = 1 to 40:
                                    if vfincod[v] = finan.fincod
                                    then do:
                                        vok = yes.
                                        leave.
                                    end.
                                    else vok = no.
                                end.
                            end.
                            if vok = no
                            then leave.
                            assign vlcont = contrato.vltotal
                                   vvlent  = contrato.vlentra.
                            find first titulo where
                                       titulo.empcod = 19           and
                                       titulo.titnat = no           and
                                       titulo.modcod = "CRE"        and
                                       titulo.etbcod = plani.etbcod and
                                       titulo.clifor = plani.desti  and
                                       titulo.titnum =
                                                string(contrato.contnum) and
                                       titulo.titpar = 1 no-lock no-error.
                            if not avail titulo
                            then vok = no.
                            else vdtven = titulo.titdtven.
                        end.
                    end.
                    if vok = no
                    then next.
                    if vfin = no
                    then next.

                    output stream stela to terminal.
                    disp stream stela plani.etbcod
                                      plani.pladat
                                      vtotal label "Total Geral"
                                        with frame fffpla
                                                    centered color white/red.
                    pause 0.
                    output stream stela close.

                    vtotal = vtotal + (if plani.outras > 0
                                       then plani.outras
                                       else plani.platot).
                    if plani.outras > 0
                    then vplatot = plani.outras.
                    else vplatot = plani.platot.

                    find first wcdci where wcdci.wplano = finan.fincod no-error.
                    if not avail wcdci
                    then do:
                        create wcdci.
                        assign wcdci.wplano = finan.fincod.
                    end.
                    assign wcdci.wqtd = wcdci.wqtd + 1
                           wcdci.wnf  = wcdci.wnf  + vplatot
                           wcdci.went = wcdci.went + vvlent
                           wcdci.wfin = wcdci.wfin + (vplatot - vvlent)
                           wcdci.wacr = wcdci.wacr + (vlcont - vplatot)
                           wcdci.wbru = wcdci.wbru + (vplatot - vvlent) +
                                        (vlcont - vplatot).

                    if vtotal > vlmax
                    then do:
                        vok1 = no.
                        leave.
                    end.
                    if vok1 = no
                    then leave.
                end.
                    if vok1 = no
                    then leave.
            end.
            if vok1 = no
            then leave.
        end.
        for each wcdci:
            find finan where finan.fincod = wcdci.wplano no-lock no-error.
            if not avail finan
            then next.
            display finan.finnom        column-label "Plano"
                    wcdci.wqtd          column-label "QTD"
                    wcdci.wnf(total)    column-label "VL.NF"
                    wcdci.went(total)   column-label "VL.ENT"
                    wcdci.wfin(total)   column-label "VL.FIN"
                    wcdci.wacr(total)   column-label "VL.ACR"
                    wcdci.wbru(total)   column-label "VL.BRUTO"
                        with frame f-cdci width 200 down.
        end.
        put skip(4)
        "DECLARAMOS ASSUMIR A RESPONSABILIDADE DE FIEIS DEPOSITARIOS DOS "
        at 30
        "DOCUMENTOS RELACIONADOS NESTE BORDERO, COMPROMETENDO-NOS A VIGIA-LOS"
        AT 30
        "E GUARDA-LOS EM NOME DESTA FINANCEIRA P/ PRAZO DE 5 ANOS,(CINCO)"
        AT 30
        "RESPONDENDO CIVIL E PLENAMENTE PELO ENCARGO ORA FEITO, TUDO CONFORME"
        AT 30
        "O QUE FOI AJUSTADO NO CONTRATO DE DEPOSITO QUE CELEBRAMOS COM VOSSA"
        AT 30
        "SENHORIA, SENDO CERTO QUE OS REFERIDOS DOCUMENTOS ESTARAO A DISPOSICAO"
        AT 30
        "DE V.S¦ AO TEMPO E LUGAR EM QUE NOS FOR EXIGIDOS." AT 30 skip(2)
        "SAO JERONIMO  " at 30
        trim(string(day(today),"99") + " "  +
             caps(vmesabr[month(today)]) + " " +
             string(year(today),"9999")) format "x(30)"
        SKIP(5)
        "_______________________" AT 50
        "DREBES & CIA LTDA"       AT 53.
    output close.
end.
