{admcab.i}
def var vtipo as char format "x(10)" extent 2 initial["GERAL","EM ATRASO"].
def var vv as char.
        
def var varquivo as char format "x(30)".


def var vetbcod like estab.etbcod.
def temp-table tt-cli 
    field clicod like clien.clicod
    field clinom like clien.clinom
    field etbcod like estab.etbcod
    field totatr like titulo.titvlcob
    field totabe like titulo.titvlcob
    field totdia like titulo.titdtven
        index nome clinom.
repeat:
    update vetbcod with frame f1 side-label width 80.
    if vetbcod = 0
    then disp "GERAL" @ estab.etbnom with frame f1.
    else do:
        find estab where estab.etbcod = vetbcod no-lock.
        disp estab.etbnom no-label with frame f1.
    end.
    display vtipo with frame f-esc no-label centered title "Tipo de Relatorio".
    choose field vtipo with frame f-esc.
    if frame-index = 1
    then vv = "G".
    else vv = "A".

    for each tt-cli:
        delete tt-cli.
    end.

    if vetbcod = 0
    then do:
        FOR EACH TOTCLI.
            find clien where clien.clicod = totcli.empcod no-lock.
            find tt-cli where tt-cli.clicod = clien.clicod no-error.
            if not avail tt-cli
            then do:
                create tt-cli.
                assign tt-cli.clicod = clien.clicod
                       tt-cli.clinom = clien.clinom.
            end.    
            for each estab no-lock:
                for each titulo use-index iclicod 
                                where titulo.empcod = 19           and
                                      titulo.etbcod = estab.etbcod and
                                      titulo.titnat = no and
                                      titulo.modcod = "CRE"and
                                      titulo.titsit = "LIB" and    
                                      titulo.clifor = clien.clicod   no-lock:
                    if titulo.titdtven < today
                    then tt-cli.totatr = tt-cli.totatr + titulo.titvlcob.
                    else tt-cli.totabe = tt-cli.totabe + titulo.titvlcob.
                    display tt-cli.clicod
                            clien.clinom
                             with frame ff2 1 down. pause 0.
                    if tt-cli.totdia = ?
                    then tt-cli.totdia = titulo.titdtven.
                    else if titulo.titdtven < tt-cli.totdia
                         then tt-cli.totdia = titulo.titdtven.
                end.
            end.
        end.
    end.
    else do:
        FOR EACH TOTCLI.
            find clien where clien.clicod = totcli.empcod no-lock.
            find first titulo where titulo.empcod = 19  and
                                  titulo.etbcod = vetbcod and
                                  titulo.titnat = no and
                                  titulo.modcod = "CRE"and
                                  titulo.titdtpag = ? and    
                                  titulo.clifor = clien.clicod no-lock no-error.
            if not avail titulo
            then next.
                    
                                  
            find tt-cli where tt-cli.clicod = clien.clicod no-error.
            if not avail tt-cli
            then do:
                create tt-cli.
                assign tt-cli.clicod = clien.clicod
                       tt-cli.clinom = clien.clinom.
            end.    
            for each titulo use-index iclicod 
                            where titulo.empcod = 19           and
                                  titulo.etbcod = estab.etbcod and
                                  titulo.titnat = no and
                                  titulo.modcod = "CRE"and
                                  titulo.titsit = "LIB" and    
                                  titulo.clifor = clien.clicod   no-lock:
                if titulo.titdtven < today
                then tt-cli.totatr = tt-cli.totatr + titulo.titvlcob.
                else tt-cli.totabe = tt-cli.totabe + titulo.titvlcob.

                if tt-cli.totdia = ?
                then tt-cli.totdia = titulo.titdtven.
                else if titulo.titdtven < tt-cli.totdia
                     then tt-cli.totdia = titulo.titdtven.


                display tt-cli.clicod
                        clien.clinom
                         with frame f2 1 down. pause 0.
            end.
        end.
    end.

    
    varquivo = "i:\admcom\relat\crefun" + string(day(today)).

    {mdadmcab.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "130"
            &Page-Line = "66"
            &Nom-Rel   = ""crefun""
            &Nom-Sis   = """SISTEMA DE CREDIARIO"""
            &Tit-Rel   = """PRESTACOES EM ABERTO DA FILIAL "" +
                          string(vetbcod)"
            &Width     = "130"
            &Form      = "frame f-cabcab"}

    for each tt-cli by tt-cli.clinom :
        if vv = "A"
        then if tt-cli.totatr = 0
             then next.

        disp tt-cli.clicod
             tt-cli.clinom 
             tt-cli.totabe(total) column-label "Total Aberto"
             tt-cli.totatr(total) column-label "Total Atraso" 
             (tt-cli.totabe + tt-cli.totatr) (total) column-label "Total Geral"
             (today - tt-cli.totdia) column-label "Dias!Atraso" format "->>>9"
                     with frame f3 down width 200.
    end.
    
    output close.
    /*
    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}
    end. 
    */
end.
