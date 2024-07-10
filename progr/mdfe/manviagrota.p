/*
*
*    mdfnfe.p    -    Esqueleto de Programacao    com esqvazio
*
*/
{cabec.i}

def var vrotaseq as int.
def var vreordena as int. 

def var vufemi      like plani.ufemi.
def var vufdes      like plani.ufdes.
def var vmunicemi   like munic.cidnom format "x(12)".
def var vmunicdes   like munic.cidnom format "x(12)".

def var vemite like plani.emite.
def var vdesti like plani.desti.
def var vtabemite as char.
def var vtabdesti as char.

def var recatu1         as recid.
def var recatu2 as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(13)" extent 5
    initial [" Ordem "," Reordena "," NFe ","",""].

form
    esqcom1
    with frame f-com1 row screen-lines no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

def input parameter par-rec-mdfviagem as recid.

find mdfviagem where recid(mdfviagem) = par-rec-mdfviagem no-lock.
find estab  where estab.etbcod = mdfviagem.etbcod no-lock.

   
   
            recatu1 = ?.

def temp-table tt-rota no-undo
    field Reordena   like mdfnfe.rotaseq column-label "Nova!Ordem"
        init 0
    field rotaseq   like mdfnfe.rotaseq
    field ufemi    like munic.ufecod
    field cidemi    like munic.cidcod
    field municemi  like munic.cidnom
    field ufdes    like munic.ufecod
    field ciddes    like munic.cidcod
    field municdes  like munic.cidnom
    index x rotaseq desc.

def temp-table tt-mdfnfe no-undo
    field rotaseq as int
    field rec    as recid.


def buffer btt-rota for tt-rota.    

    
    form
        tt-rota.Reordena
        tt-rota.rotaseq column-label "Rot"
        "ORIGEM"
        tt-rota.ufemi          no-label
        tt-rota.municemi no-label format "x(20)"
        "DESTINO"
        tt-rota.ufdes          no-label 
        tt-rota.municdes no-label format "x(20)"

        with frame frame-a 7 down centered color white/red row 10
        title " ROTA " + mdfviagem.placa
        no-underline width 80.

run pesquisa.
find first tt-rota no-error.
if not avail tt-rota then return.    


bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find tt-rota where recid(mdfnfe) = recatu1 no-lock.
    if not available tt-rota
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then
        run frame-a.
    else do.
        recatu1 = ?.
        leave.
    end.

    recatu1 = recid(tt-rota).
    color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tt-rota
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        run frame-a.
    end.
    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        if not esqvazio
        then do:
            find tt-rota where recid(tt-rota) = recatu1 no-lock.

            disp esqcom1 with frame f-com1.
        color disp messages
        tt-rota.Reordena tt-rota.rotaseq
        tt-rota.ufemi 
        tt-rota.municemi
        tt-rota.ufdes
        tt-rota.municdes.

            choose field tt-rota.rotaseq
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      PF4 F4 ESC return).

            status default "".
 
        color disp normal
        tt-rota.rotaseq
        tt-rota.Reordena
        tt-rota.ufemi 
        tt-rota.municemi
        tt-rota.ufdes 
        tt-rota.municdes.
 
        end.
            if keyfunction(lastkey) = "cursor-right"
            then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                next.
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                next.
            end.
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail tt-rota
                    then leave.
                    recatu1 = recid(tt-rota).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-rota
                    then leave.
                    recatu1 = recid(tt-rota).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-rota
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-rota
                then next.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then do:
            leave bl-princ.
        end.    

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            hide frame frame-a no-pause.
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.
                if esqcom1[esqpos1] = " Ordem "
                then do .
                    if tt-rota.reordena = 0
                    then do:
                        vreordena = vreordena + 1.
                        tt-rota.Reordena = vreordena.
                    end.
                    else do:
                        tt-rota.reordena = 0.
                        vreordena = 0.    
                        for each btt-rota where btt-rota.reordena <> 0
                            by btt-rota.reordena.
                            vreordena = vreordena + 1.
                            btt-rota.reordena = vreordena.
                        end.    
                        recatu2 = recid(tt-rota).
                        recatu1 = ?. 
                        leave.
                    end.    
                        
                    disp tt-rota.Reordena
                        with frame frame-a.
                end. 
                if esqcom1[esqpos1] = " Reordena "
                then do .
                        vreordena = 0.
                        for each btt-rota where btt-rota.reordena <> 0
                            by btt-rota.reordena
                            by btt-rota.rotaseq.
                            vreordena = vreordena + 1.
                            btt-rota.reordena = vreordena.
                        end.    
                        for each btt-rota where btt-rota.reordena = 0
                            by btt-rota.reordena
                            by btt-rota.rotaseq.
                            vreordena = vreordena + 1.
                            btt-rota.reordena = vreordena.
                        end.    
                        
                        for each btt-rota 
                            break by btt-rota.reordena.
                            for each tt-mdfnfe where
                                tt-mdfnfe.rotaseq = btt-rota.rotaseq.

                                find mdfnfe where recid(mdfnfe) = 
                                        tt-mdfnfe.rec.
                                mdfnfe.rotaseq = btt-rota.reordena.
                            end.
                        end.        
                        for each tt-rota.
                            delete tt-rota.
                        end.
                        for each tt-mdfnfe.
                            delete tt-mdfnfe.
                        end.
                        run pesquisa.
                        recatu1 = ?.
                        color disp normal
                        esqcom1[esqpos1] 
                        with frame f-com1.
                        esqpos1 = 1.
                        vreordena = 0.
                        leave.
                end. 
                
                if esqcom1[esqpos1] = " *Consulta* "
                then do with frame f-mdfnfe 2 col centered row 13.
                    disp mdfnfe.
                    pause.
                end.
                if esqcom1[esqpos1] = " *Altera* "
                then do on error undo with frame f-altera side-label 2 col.
                    disp mdfnfe.
                    find current mdfnfe exclusive.
                    find current mdfnfe no-lock.
                end.
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(tt-rota).
    end.
end.
hide frame f-com1  no-pause.
hide frame frame-a no-pause.
hide frame f-dados no-pause.

procedure frame-a.

    display 
        tt-rota.rotaseq
        tt-rota.Reordena
        tt-rota.ufemi     
        tt-rota.municemi
        tt-rota.ufdes   
        tt-rota.municdes
        

        with frame frame-a.
        
end procedure.

procedure leitura.
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then find last tt-rota  no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then find prev tt-rota  no-lock no-error.
             
if par-tipo = "up" 
then find next tt-rota no-lock no-error.

end procedure.



procedure pesquisa.


    find veiculo where veiculo.placa = mdfviagem.placa no-lock.
    find frete of mdfviagem no-lock.
    find tpfrete of frete no-lock.
    find forne of frete   no-lock.

vrotaseq = 1.
for each mdfnfe of mdfviagem no-lock
    by mdfnfe.rotaseq.


    vufemi = "**". vmunicemi = "**".
    vufdes = "**". vmunicdes = "**".
    
    if mdfnfe.tabemite = "ESTAB" or 
       mdfnfe.tabemite = ""
    then do:
        find estab where estab.etbcod = mdfnfe.emite no-lock no-error.
        if avail estab 
        then do:
            find first munic where munic.ufecod = estab.ufecod and
                             munic.cidnom = estab.munic
                no-lock no-error  .
            if avail munic
            then do:
                vmunicemi = munic.cidnom.
            end.                
            vufemi = estab.ufecod.
            
        end.    
    end.
    if mdfnfe.tabemite = "FORNE"
    then do:
        find forne where forne.forcod = mdfnfe.emite no-lock no-error.
        if avail forne 
        then do:
            find first munic where munic.ufecod = forne.ufecod and
                             munic.cidnom = forne.formunic
                no-lock no-error  .
            if avail munic
            then do:
                vmunicemi = munic.cidnom.
            end.                
            vufemi = forne.ufecod.
        end. 
    end.        
 
    if mdfnfe.tabdesti = "ESTAB" or 
       mdfnfe.tabdesti = ""
    then do:
        find estab where estab.etbcod = mdfnfe.desti no-lock no-error.
        if avail estab 
        then do:
            find first munic where munic.ufecod = estab.ufecod and
                             munic.cidnom = estab.munic
                no-lock no-error  .
            if avail munic
            then do:
                vmunicdes = munic.cidnom.
            end.                
            vufdes = estab.ufecod.
        end.            
    end.        
    
    if mdfnfe.tabdesti = "FORNE"
    then do:
        find forne where forne.forcod = mdfnfe.desti no-lock no-error.
        if avail forne 
        then do:
            find first munic where munic.ufecod = forne.ufecod and
                             munic.cidnom = forne.formunic
                no-lock no-error  .
            if avail munic
            then do:
                vmunicdes = munic.cidnom.
            end.                
            vufdes = forne.ufecod.
        end.            
    end.        

    find first tt-rota where
        tt-rota.ufemi       = vufemi and
        tt-rota.municemi    = vmunicemi and
        tt-rota.ufdes       = vufdes and
        tt-rota.municdes    = vmunicdes
        no-error.
    if not avail tt-rota    
    then do:
        create tt-rota.
        tt-rota.ufemi       = vufemi.
        tt-rota.municemi    = vmunicemi.
        tt-rota.ufdes       = vufdes.
        tt-rota.municdes    = vmunicdes.
        tt-rota.rotaseq     = vrotaseq.
        vrotaseq = vrotaseq + 1.
    end.
    create tt-mdfnfe.
    tt-mdfnfe.rotaseq = tt-rota.rotaseq.
    tt-mdfnfe.rec     = recid(mdfnfe).
    
            
end.

 

end procedure.

/****
procedure cria.

message "!ajusta a rota".
pause.

/**
vrota = 1.
voperacao = no.

for each tt-rota where tt-rota.Reordena = yes.

    find first a01_infnfe where
        a01_infnfe.chave = tt-rota.nfechave
        no-lock no-error.
        
    if avail a01_infnfe
    then do:
        find plani where plani.etbcod = a01_infnfe.etbcod and
                         plani.placod = a01_infnfe.placod
            no-lock no-error.
        if avail plani
        then do:
            vserie = plani.serie.
            vnumero = plani.numero.
            vemissao = plani.pladat.
            vplatot = plani.platot.
        end.
                                             
    end.
    else next.    
    

    create mdfnfe.

    ASSIGN
    mdfnfe.etbcod      = mdfviagem.etbcod
    mdfnfe.NfeChave    = tt-rota.nfechave
    mdfnfe.MdfVCod     = mdfviagem.MdfVCod
    mdfnfe.RotaSeq     = vrota
    mdfnfe.tabemite    = tt-rota.tabemite
    mdfnfe.Emite       = tt-rota.emite
    mdfnfe.tabdesti    = tt-rota.tabdesti
    mdfnfe.Desti       = tt-rota.desti
    mdfnfe.serie       = vserie
    mdfnfe.numero      = vnumero
    mdfnfe.MdfeCod     = ?.

    if voperacao = no then voperacao = yes.
    vrota = vrota + 1.

end.
*/
 
end procedure.

***/
