/*
*
*    mdfnfe.p    -    Esqueleto de Programacao    com esqvazio
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
    initial [" Consulta "," Inclui"," Rota "," Elimina",""].

form
    esqcom1
    with frame f-com1 row screen-lines no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

def buffer atu-estab for estab.

def input parameter par-rec-mdfviagem as recid.

find mdfviagem where recid(mdfviagem) = par-rec-mdfviagem no-lock.
find estab  where estab.etbcod = mdfviagem.etbcod no-lock.
   
            recatu1 = ?.


    
    form
        mdfnfe.rotaseq column-label "Rot"  
        vemitpro 
        mdfnfe.nfeid    format "xxxxxxxxxxxx..."
        vserie
        vnumero
        "EMITE"
        mdfnfe.tabemite no-label format  "x(3)"
        mdfnfe.emite    no-label format ">>>>>>99"
        vufemi          no-label
        vmunicemi       no-label        

        mdfe.mdfenumero column-label "MDFe"
        
        skip
        space(33)
        "DESTI"
        mdfnfe.tabdesti no-label format  "x(3)"
        mdfnfe.desti    no-label format ">>>>>>99"
        vufdes          no-label 
        vmunicdes no-label

        with frame frame-a 3 down centered color white/red row 10
        title " NFEs " no-underline width 80.

 find first mdfnfe of mdfviagem 
        use-index MdfNfeRota no-lock no-error.
 if not avail mdfnfe
 then do: 
        run mdfe/incmdfnfe.p (input recid(mdfviagem)).
 end.
 
bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find mdfnfe where recid(mdfnfe) = recatu1 no-lock.
    if not available mdfnfe
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

    recatu1 = recid(mdfnfe).
    color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available mdfnfe
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
            find mdfnfe where recid(mdfnfe) = recatu1 no-lock.
            find mdfe of mdfnfe no-lock no-error.
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
        mdfnfe.rotaseq 
        vemitpro 
        mdfnfe.nfeid  
        vserie
        vnumero
        mdfnfe.tabemite
        mdfnfe.emite 
        vufemi 
        vmunicemi
        mdfe.mdfenumero
        mdfnfe.tabdesti 
        mdfnfe.desti   
        vufdes 
        vmunicdes.
            
            choose field mdfnfe.rotaseq help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      PF4 F4 ESC return).

            status default "".
 
        color disp normal
        mdfnfe.rotaseq 
        vemitpro 
        mdfnfe.nfeid  
        vserie
        vnumero
        mdfnfe.tabemite
        mdfnfe.emite 
        vufemi 
        vmunicemi
        mdfe.mdfenumero
        mdfnfe.tabdesti 
        mdfnfe.desti   
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
                    if not avail mdfnfe
                    then leave.
                    recatu1 = recid(mdfnfe).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail mdfnfe
                    then leave.
                    recatu1 = recid(mdfnfe).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail mdfnfe
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail mdfnfe
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
                            a01_infnfe.chave = mdfnfe.infnfechave 
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
                    
                    run mdfe/incmdfnfe.p (input recid(mdfviagem)).

                    leave.
                end.
                if esqcom1[esqpos1] = " Elimina "
                then do on error undo:
                    hide message no-pause.
                    if mdfnfe.mdfecod <> ?
                    then do:
                        message "Chave ja associada a MDFe".
                        leave.
                    end.
                    message "Confirma eliminar da viagem a nota?"
                        update sresp.
                    if not sresp
                        then leave.
                    find current mdfnfe exclusive.
                    delete mdfnfe.
                    recatu1 = ?.
                    leave.
                end.
                
                if esqcom1[esqpos1] = " Rota "
                then do.
                    hide frame fcom1 no-pause.
                    hide frame frame-a no-pause.
                    run mdfe/manviagrota.p (input recid(mdfviagem)).
                    recatu1 = ?.
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
        recatu1 = recid(mdfnfe).
    end.
end.
hide frame f-com1  no-pause.
hide frame frame-a no-pause.
hide frame f-dados no-pause.

procedure frame-a.

    find mdfe of mdfnfe no-lock no-error.
    
    vufemi = "**". vmunicemi = "**".
    vufdes = "**". vmunicdes = "**".
    
    if mdfnfe.tabemite = "ESTAB" or 
       mdfnfe.tabemite = ""
    then do:
        find estab where estab.etbcod = mdfnfe.emite no-lock no-error.
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
    if mdfnfe.tabemite = "FORNE"
    then do:
        find forne where forne.forcod = mdfnfe.emite no-lock no-error.
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
 
    if mdfnfe.tabdesti = "ESTAB" or 
       mdfnfe.tabdesti = ""
    then do:
        find estab where estab.etbcod = mdfnfe.desti no-lock no-error.
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
    
    if mdfnfe.tabdesti = "FORNE"
    then do:
        find forne where forne.forcod = mdfnfe.desti no-lock no-error.
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
        a01_infnfe.chave = mdfnfe.infnfechave
        no-lock  no-error.

    vserie  = mdfnfe.serie.
    vnumero = mdfnfe.numero.

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
        mdfnfe.rotaseq 
        vemitpro
        mdfnfe.nfeid  
        vserie
        vnumero
        mdfnfe.tabemite 
        mdfnfe.emite   
        vufemi 
            vmunicemi
        
        mdfe.mdfenumero when avail mdfe
        
        mdfnfe.tabdesti 
        mdfnfe.desti   
        vufdes   
            vmunicdes

        with frame frame-a.
        
end procedure.

procedure leitura.
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then find first mdfnfe of mdfviagem 
        use-index MdfNfeRota no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then find next mdfnfe of mdfviagem  
        use-index MdfNfeRota no-lock no-error.
             
if par-tipo = "up" 
then find prev mdfnfe of mdfviagem 
    use-index MdfNfeRota no-lock no-error.

end procedure.

