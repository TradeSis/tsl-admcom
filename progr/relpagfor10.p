{admcab.i}

def var vdti like plani.pladat.
def var vdtf like plani.pladat.
def var vdata as date.
def var varquivo as char.
def temp-table tt-titulo like titulo.

repeat:
    update vdti label "Periodo" 
           vdtf no-label with frame f1 width 80 side-label.
    
    for each tt-titulo: delete tt-titulo. end.
    /*
    for each estab no-lock:
    for each modal no-lock:
        for each titulo where
                 titulo.empcod = 19 and
                 titulo.titnat = yes and
                 titulo.modcod = modal.modcod and
                 titulo.etbcod = estab.etbcod and
                 titulo.titdtven >= vdti and
                 titulo.titdtven <= vdtf 
                 no-lock:

            if titulo.modcod = "BON" or
                       titulo.modcod = "DEV" or
                                  titulo.modcod = "CHP" then next.
    
            if titulo.etbcobra <> ? then next. 
             
            if titulo.titdtpag < vdti or
               titulo.titdtpag > vdtf
            then next.
           
            if titulo.evecod = 4 or
               titulo.evecod = 10 then next.
               
            create tt-titulo.
            buffer-copy titulo to tt-titulo.
        end.
    end.
    end. 
    */
    
    do vdata = vdti to vdtf.
        for each titulo where
                 titulo.titnat and
                 titulo.titdtpag = vdata
                 no-lock:
             /* EtbCobra valido */
             find estab where estab.etbcod = titulo.etbcobra no-lock no-error.
             if not avail estab
             then next.

             if titulo.evecod <> 4 and
                titulo.evecod <> 10
             then next.

            if titulo.modcod = "BON" or
               titulo.modcod = "DEV" or
               titulo.modcod = "CHP" then next.
    
            find first tt-titulo where
                       tt-titulo.empcod = titulo.empcod and
                       tt-titulo.titnat = titulo.titnat and
                       tt-titulo.modcod = titulo.modcod and
                       tt-titulo.etbcod = titulo.etbcod and 
                       tt-titulo.clifor = titulo.clifor and
                       tt-titulo.titnum = titulo.titnum and
                       tt-titulo.titpar = titulo.titpar and
                       tt-titulo.titdtemi = titulo.titdtemi
                       no-error.
            if not avail tt-titulo
            then do:           
                create tt-titulo.
                buffer-copy titulo to tt-titulo.
            end.
        end.
    end.

    do vdata = vdti to vdtf.
        for each titulo where
                 titulo.titnat and
                 titulo.titdtpag = vdata and
                 titulo.etbcobra = ?
                 no-lock:

             if titulo.evecod <> 4 /*and
                titulo.evecod <> 10*/
             then.
             else next.         

            if titulo.modcod = "BON" or
                       titulo.modcod = "DEV" or
                                  titulo.modcod = "CHP" then next.
    
            find first tt-titulo where
                       tt-titulo.empcod = titulo.empcod and
                       tt-titulo.titnat = titulo.titnat and
                       tt-titulo.modcod = titulo.modcod and
                       tt-titulo.etbcod = titulo.etbcod and 
                       tt-titulo.clifor = titulo.clifor and
                       tt-titulo.titnum = titulo.titnum and
                       tt-titulo.titpar = titulo.titpar and
                       tt-titulo.titdtemi = titulo.titdtemi
                       no-error.
            if not avail tt-titulo
            then do:           
                create tt-titulo.
                buffer-copy titulo to tt-titulo.
            end.
        end.
    end.

    if opsys = "UNIX"
   then varquivo = "/admcom/relat/paga" + STRING(day(today)) + string(day(vdti),"99")
        + string(time).
   else varquivo = "..\relat\lana" + STRING(day(today)) + string(day(vdti),"99").
     
    {mdad.i
            &Saida     = "value(varquivo)" 
            &Page-Size = "64"
            &Cond-Var  = "136"
            &Page-Line = "66"
            &Nom-Rel   = ""rellan01""
            &Nom-Sis   = """SISTEMA DE CONTABILIDADE"""
            &Tit-Rel   = """RELATORIO DE PAGAMENTOS DE "" +
                          string(vdti,""99/99/9999"") + "" ATE "" +
                          string(vdtf,""99/99/9999"") "
            &Width     = "136"
            &Form      = "frame f-cabcab"}
    
    for each tt-titulo no-lock,
        forne where forne.forcod = tt-titulo.clifor no-lock
                break by fornom:
/*#1
        if first-of(forne.fornom)
        then disp forne.forcod forne.fornom format "x(20)"
            with frame f-disp.
*/
        disp
             forne.forcod
             forne.fornom format "x(20)"
             tt-titulo.titnum
             tt-titulo.titpar   format ">>>>>9"
             tt-titulo.modcod
             tt-titulo.titdtemi
             tt-titulo.titdtven
             tt-titulo.titdtpag
             tt-titulo.titvlcob(total by forne.fornom)
             tt-titulo.titvljur(total by forne.fornom)
             tt-titulo.titvldes(total by forne.fornom)
             tt-titulo.titvlpag(total by forne.fornom)
             tt-titulo.evecod format ">>9" column-label "Eve"
             tt-titulo.titsit format "x(3)" column-label "Sit" 
             with frame f-disp down width 170
              .
        down with frame f-disp.      
    end.

    output close.
    
    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}
    end.
end.

