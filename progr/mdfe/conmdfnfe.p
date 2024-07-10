/*
*
*    mdfhistnfe.p    -    Esqueleto de Programacao    com esqvazio
*
*/
{cabec.i}

def buffer emiclifor for forne.
def buffer desclifor for forne.
def buffer emiestab  for estab.
def buffer desestab  for estab.

def var vemitpro      as log format " /T" label "".
def var vserie       like plani.serie column-label "Ser".
def var vnumero      like plani.numero.
def var vufemi      like plani.ufemi.
def var vufdes      like plani.ufdes.
def var vmunicemi   like munic.cidnom format "x(12)".
def var vmunicdes   like munic.cidnom format "x(12)".


def var vnome as char.
def var vemitente as int format ">>>>>>9".
def var vdestinat as int format ">>>>>>9".

def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(13)" extent 5
    initial [" Consulta ",""," ","",""].

form
    esqcom1
    with frame f-com1 row screen-lines no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

def buffer atu-estab for estab.

def input parameter par-rec-mdfe as recid.

find mdfe where recid(mdfe) = par-rec-mdfe no-lock.
find estab  where estab.etbcod = mdfe.etbcod no-lock.
   
            recatu1 = ?.


    
    form
        mdfhistnfe.rotaseq column-label "Rot"  
        vemitpro 
        mdfhistnfe.nfeid    format "xxxxxxxxxxxx..."
        vserie
        vnumero
        "EMITE"
        mdfhistnfe.tabemite no-label format  "x(3)"
        mdfhistnfe.emite    no-label format ">>>>>>99"
        vufemi          no-label
        vmunicemi       no-label        

        mdfe.mdfenumero column-label "MDFe"
        
        skip
        space(33)
        "DESTI"
        mdfhistnfe.tabdesti no-label format  "x(3)"
        mdfhistnfe.desti    no-label format ">>>>>>99"
        vufdes          no-label 
        vmunicdes no-label

        with frame frame-a 3 down centered color white/red row 10
        title " NFEs da MDFe (Historico) " no-underline width 80.

 
bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find mdfhistnfe where recid(mdfhistnfe) = recatu1 no-lock.
    if not available mdfhistnfe
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

    recatu1 = recid(mdfhistnfe).
    color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available mdfhistnfe
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
            find mdfhistnfe where recid(mdfhistnfe) = recatu1 no-lock.
            find mdfe of mdfhistnfe no-lock no-error.
            esqcom1[2] = " Inclui".
            esqcom1[4] = " Elimina".
            if avail mdfe
            then do:
                if mdfe.situacao <> "A"
                then assign
                        esqcom1[2] = ""
                        esqcom1[4] = "".
            end.
            disp esqcom1 with frame f-com1.
        color disp messages
        mdfhistnfe.rotaseq 
        vemitpro 
        mdfhistnfe.nfeid  
        vserie
        vnumero
        mdfhistnfe.tabemite
        mdfhistnfe.emite 
        vufemi 
        vmunicemi
        mdfe.mdfenumero
        mdfhistnfe.tabdesti 
        mdfhistnfe.desti   
        vufdes 
        vmunicdes.
            
            choose field mdfhistnfe.rotaseq help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      PF4 F4 ESC return).

            status default "".
 
        color disp normal
        mdfhistnfe.rotaseq 
        vemitpro 
        mdfhistnfe.nfeid  
        vserie
        vnumero
        mdfhistnfe.tabemite
        mdfhistnfe.emite 
        vufemi 
        vmunicemi
        mdfe.mdfenumero
        mdfhistnfe.tabdesti 
        mdfhistnfe.desti   
        vufdes 
        vmunicdes.
 
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
                    if not avail mdfhistnfe
                    then leave.
                    recatu1 = recid(mdfhistnfe).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail mdfhistnfe
                    then leave.
                    recatu1 = recid(mdfhistnfe).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail mdfhistnfe
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail mdfhistnfe
                then next.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.
                if esqcom1[esqpos1] = " Consulta "
                then do .
                    hide frame f-com1 no-pause.
                    
                    find a01_infnfe where 
                            a01_infnfe.chave = mdfhistnfe.infnfechave 
                            no-lock
                            no-error.
                    if avail a01_infnfe
                    then do:
                        find plani where plani.etbcod = a01_infnfe.etbcod and
                                         plani.placod = a01_infnfe.placod
                                   no-lock no-error.
                        if avail plani
                        then            run not_consnota.p (recid(plani)).
                    end.
                    view frame f-com1.
                end. 
                if esqcom1[esqpos1] = " Inclui "
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-sub   no-pause.
                    
                    run mdfe/incmdfhistnfe.p (input recid(mdfe)).

                    leave.
                end.
                if esqcom1[esqpos1] = " Elimina "
                then do on error undo:
                    hide message no-pause.
                    if mdfhistnfe.mdfecod <> ?
                    then do:
                        message "Chave ja associada a MDFe".
                        leave.
                    end.
                    message "Confirma eliminar da viagem a nota?"
                        update sresp.
                    if not sresp
                        then leave.
                    find current mdfhistnfe exclusive.
                    delete mdfhistnfe.
                    recatu1 = ?.
                    leave.
                end.
                
                if esqcom1[esqpos1] = " Rota "
                then do.
                    hide frame fcom1 no-pause.
                    hide frame frame-a no-pause.
                    run mdfe/manviagrota.p (input recid(mdfe)).
                    recatu1 = ?.
                    leave.
                end.
                if esqcom1[esqpos1] = " *Consulta* "
                then do with frame f-mdfhistnfe 2 col centered row 13.
                    disp mdfhistnfe.
                    pause.
                end.
                if esqcom1[esqpos1] = " *Altera* "
                then do on error undo with frame f-altera side-label 2 col.
                    disp mdfhistnfe.
                    find current mdfhistnfe exclusive.
                    find current mdfhistnfe no-lock.
                end.
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(mdfhistnfe).
    end.
end.
hide frame f-com1  no-pause.
hide frame frame-a no-pause.
hide frame f-dados no-pause.

procedure frame-a.

    find mdfe of mdfhistnfe no-lock no-error.
    
    vufemi = "**". vmunicemi = "**".
    vufdes = "**". vmunicdes = "**".
    
    if mdfhistnfe.tabemite = "ESTAB" or 
       mdfhistnfe.tabemite = ""
    then do:
        find estab where estab.etbcod = mdfhistnfe.emite no-lock no-error.
        if avail estab 
        then do:
            find munic where munic.ufecod = estab.ufecod and
                             munic.cidnom = estab.munic
                no-lock no-error  .
            if avail munic
            then do:
                vmunicemi = munic.cidnom.
            end.                
            vufemi = estab.ufecod.
            
        end.    
    end.
    if mdfhistnfe.tabemite = "FORNE"
    then do:
        find forne where forne.forcod = mdfhistnfe.emite no-lock no-error.
        if avail forne 
        then do:
            find munic where munic.ufecod = forne.ufecod and
                             munic.cidnom = forne.formunic
                no-lock no-error  .
            if avail munic
            then do:
                vmunicemi = munic.cidnom.
            end.                
            vufemi = forne.ufecod.
        end. 
    end.        
 
    if mdfhistnfe.tabdesti = "ESTAB" or 
       mdfhistnfe.tabdesti = ""
    then do:
        find estab where estab.etbcod = mdfhistnfe.desti no-lock no-error.
        if avail estab 
        then do:
            find munic where munic.ufecod = estab.ufecod and
                             munic.cidnom = estab.munic
                no-lock no-error  .
            if avail munic
            then do:
                vmunicdes = munic.cidnom.
            end.                
            vufdes = estab.ufecod.
        end.            
    end.        
    
    if mdfhistnfe.tabdesti = "FORNE"
    then do:
        find forne where forne.forcod = mdfhistnfe.desti no-lock no-error.
        if avail forne 
        then do:
            find munic where munic.ufecod = forne.ufecod and
                             munic.cidnom = forne.formunic
                no-lock no-error  .
            if avail munic
            then do:
                vmunicdes = munic.cidnom.
            end.                
            vufdes = forne.ufecod.
        end.            
    end.        



    find first a01_infnfe where
        a01_infnfe.chave = mdfhistnfe.infnfechave
        no-lock  no-error.

    vserie  = mdfhistnfe.serie.
    vnumero = mdfhistnfe.numero.

    vemitpro = avail a01_infnfe.
    
    if avail a01_infnfe
    then do:
        find plani where plani.etbcod = a01_infnfe.etbcod and
                         plani.placod = a01_infnfe.placod
            no-lock no-error.
        if avail plani
        then do:
            vserie = plani.serie.
            vnumero = plani.numero.
        end.
                                             
    end.    
    
    display 
        mdfhistnfe.rotaseq 
        vemitpro
        mdfhistnfe.nfeid  
        vserie
        vnumero
        mdfhistnfe.tabemite 
        mdfhistnfe.emite   
        vufemi 
            vmunicemi
        
        mdfe.mdfenumero when avail mdfe
        
        mdfhistnfe.tabdesti 
        mdfhistnfe.desti   
        vufdes   
            vmunicdes

        with frame frame-a.
        
end procedure.

procedure leitura.
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then find first mdfhistnfe of mdfe 
         no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then find next mdfhistnfe of mdfe  
         no-lock no-error.
             
if par-tipo = "up" 
then find prev mdfhistnfe of mdfe 
     no-lock no-error.

end procedure.

