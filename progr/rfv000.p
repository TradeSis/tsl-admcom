{admcab.i}

def var vdtcadi as date format "99/99/9999".
def var vdtcadf as date format "99/99/9999".
def var vdata   as date format "99/99/9999".
def var vetbcod like estab.etbcod.

def new shared temp-table tt-cli
    
    field clicod like clien.clicod
    field clinom like clien.clinom
    
    index iclicod is primary unique clicod.
    
repeat:

    for each tt-cli:
        delete tt-cli.
    end.

    update vetbcod label "Estabelecimento...." skip
           vdtcadi label "Dt.Cadastro Inicial"
           vdtcadf label "Dt.Cadastro Final"
           with frame f-dados width 80 side-labels.

    if vdtcadi = ? or vdtcadf = ? or (vdtcadi > vdtcadf)
    then do:
        message "Data Invalida.".
        undo.
    end.
    
    vdata = ?.
    do vdata = vdtcadi to vdtcadf:
        
        disp vdata with frame f-d centered 1 down row 8 no-labels.
        
        for each clien where clien.dtcad = vdata no-lock:           
            
            find first plani where plani.movtdc = 5
                               and plani.desti  = clien.clicod 
                                   no-lock no-error.
            if avail plani
            then next.
            
            if vetbcod <> 0 
            then do:
                if length(string(clien.clicod)) < 10 
                then do:
                    if int(substring(string(clien.clicod,"9999999999"),9,2)) 
                                                <> vetbcod
                    then next.
                end.
                else do:
                    if int(substring(string(clien.clicod),2,3)) <> vetbcod
                    then next.
                end.
            end.
            
            find tt-cli where tt-cli.clicod = clien.clicod no-error.
            if not avail tt-cli
            then do:
                create tt-cli.
                assign tt-cli.clicod = clien.clicod
                       tt-cli.clinom = clien.clinom.
            end.
            
        end.
        
    end.

    hide frame f-d no-pause.
    
    run rfv000-brw.p.

end.