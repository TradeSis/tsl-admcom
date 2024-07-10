{admcab.i}
def input parameter par-rec as recid.
def var vt as int.
find cobdata where recid(cobdata) = par-rec no-lock.
def var par-todos as log.

    find cobfil of cobdata no-lock.
    disp 
        cobdata.etbcod
        cobdata.cobcod
        cobfil.cobnom
        cobdata.cobgera
        cobdata.cobqtd
            with frame fcab
            centered 1 down row 3
            no-underline color messages no-box width 80.

def var vopcao as char format "x(20)" extent 2 init
    [" SOh OS LIQUIDADOS","        TODOS "].
    par-todos = no.
    disp vopcao
        with frame f row 8 no-labels side-labels  width 60 centered
        title " Escolha a forma de Exclusao"
        overlay.
    choose field vopcao
            with frame f.
    par-todos = frame-index = 2.        
    
    message "Confirma Exclusao" update sresp.
    if not sresp 
    then next.
    for each cobranca of cobdata.
        if not par-todos
        then do:
            if (today - cobranca.cobgera) <= 45
            then next.
            find first titulo where titulo.clifor = cobranca.clicod     and
                                titulo.titnat = no                  and
                                titulo.modcod = "CRE"               and
                                titulo.titdtpag >= cobranca.cobgera and
                                titulo.titdtpag <= (cobranca.cobgera + 45)
                                no-lock no-error.
            if avail titulo
            then next.
            display cobranca.cobcod
                cobranca.clicod with frame f2 down. pause 0.
        end.
                        
        delete cobranca.
    end.
    
    vt = 0.
    for each cobranca of cobdata no-lock.
        vt = vt + 1.
    end.    
    do on error undo:
        find current cobdata exclusive.
        if vt = 0
        then do:
            delete cobdata.
        end.
        else do:
            cobdata.cobqtd = vt.
        end.
    end.

    hide frame f no-pause.
    hide frame fcab no-pause.
