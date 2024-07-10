{admcab.i}

def buffer btitulo for fin.titulo.
def var vpassa as log.
def buffer bb-titulo for fin.titulo.

def buffer d-titulo for d.titulo.

def var vdtini as date format "99/99/9999".
def var vdtfin as date format "99/99/9999".
def var vdata  as date format "99/99/9999".

def var vetbcod as int format ">>9".

def new shared temp-table tt-cli
    
    field clicod like clien.clicod
    field clinom like clien.clinom
    
    index iclicod is primary unique clicod.

repeat:
    for each tt-cli:
        delete tt-cli.
    end.
    
    do on error undo:
        /*
        update vetbcod label "Estabelecimento"
               with frame f-dados width 80 side-labels.
        if vetbcod <> 0 
        then do:
            find estab where estab.etbcod = vetbcod no-lock no-error.
            if not avail estab
            then do:
                message "Estabelecimento nao cadastrado.".
                undo.
            end.
            else disp estab.etbnom no-label with frame f-dados.
        end.
        else disp "Todos" @ estab.etbnom no-label with frame f-dados.
        */
        /* antonio */
        disp vetbcod label "Estabelecimento"
             "" @ estab.etbnom
             with frame f-dados width 80 side-labels.
        {selestab.i vetbcod f-dados}
    end.
    
    update skip
           vdtini label "Dt.Pagamento de"
           vdtfin label "ate"
           with frame f-dados width 80.
    
    
    do vdata = vdtini to vdtfin:

      disp vdata with frame f-d centered 1 down row 8 no-labels.
      /* 
      for each estab where estab.etbcod = (if vetbcod <> 0
                                           then vetbcod
                                           else estab.etbcod) no-lock:
      */
      /* Antonio */
      for each tt-lj, first estab where estab.etbcod = tt-lj.etbcod no-lock:
      
        for each fin.titulo use-index titdtpag
                        where titulo.empcod   = 19
                          and titulo.titnat   = no
                          and titulo.modcod   = "CRE"
                          and titulo.titdtpag = vdata
                          and titulo.etbcod   = estab.etbcod no-lock:
            
            
            disp titulo.clifor format ">>>>>>>>>9"
                 with frame f-d centered 1 down row 8 no-labels.

            find first btitulo where btitulo.clifor = titulo.clifor
                                 and btitulo.titsit = "LIB"
                                 and btitulo.modcod = "CRE"
                                 no-lock no-error.
                                 
            if avail btitulo
            then next.           

            find clien where clien.clicod = titulo.clifor no-lock no-error.
            if not avail clien 
            then next.
            
            if clien.estciv = 6 then next.
            
            find rfvcli where rfvcli.setor = 0 and
                              rfvcli.clicod = clien.clicod
                              no-lock no-error.
            if avail rfvcli  and
               rfvcli.etbcod <> estab.etbcod
            then next.
                                
            vpassa = no.
            
            for each bb-titulo use-index iclicod where 
                     bb-titulo.clifor = titulo.clifor no-lock:

                if bb-titulo.titdtpag > titulo.titdtpag
                then vpassa = yes.
            
            end.
            
            if vpassa
            then next.

            find tt-cli where tt-cli.clicod = clien.clicod no-error.
            if not avail tt-cli
            then do:
                
                create tt-cli.
                assign tt-cli.clicod = clien.clicod
                       tt-cli.clinom = clien.clinom.
            end.

    
        end.
      end.
    end.
    for each tt-cli:
        find first d-titulo where d-titulo.clifor = tt-cli.clicod
                                 and d-titulo.titsit = "LIB"
                                 and d-titulo.modcod = "CRE"
                                 no-lock no-error.
                                 
        if avail d-titulo
        then do:
            delete tt-cli.
        end.
    end.

    hide frame f-dados no-pause.
    hide frame f-d no-pause.

    run rfv000-brw.p.

end.