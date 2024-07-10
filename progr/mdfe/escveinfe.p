/*
*
*    mdfnfe.p    -    Esqueleto de Programacao    com esqvazio
*
*/
{cabec.i}


def var vserie       like plani.serie column-label "Ser".
def var vnumero      like plani.numero.
def var vemissao     like plani.pladat.
def var vplatot      like plani.platot.
def var vufemi      like plani.ufemi.
def var vufdes      like plani.ufdes.
def var vmunicemi   like munic.cidnom format "x(12)".
def var vmunicdes   like munic.cidnom format "x(12)".

def var vrota as int.
def var voperacao as log.

def var vdtemi as date format "99/99/9999" label "Emissao".

def var vemite like plani.emite.
def var vdesti like plani.desti.
def var vtabemite as char.
def var vtabdesti as char.

def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(13)" extent 5
    initial [" Marca "," Todos "," Emissao","",""].

form
    esqcom1
    with frame f-com1 row screen-lines no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

def input parameter par-rec-mdfviagem as recid.

find mdfviagem where recid(mdfviagem) = par-rec-mdfviagem no-lock.
find estab  where estab.etbcod = mdfviagem.etbcod no-lock.

vdtemi = today.   
   
            recatu1 = ?.

def temp-table tt-mdfnfe no-undo
    field marca   as log format "*/ " column-label "*"
    field placa    like x01_transp.placa
    field infnfechave like mdfnfe.Infnfechave
    field nfeID    like mdfnfe.nfeID
    
    field tabemite like mdfnfe.tabemite
    field emite    like mdfnfe.emite
    field tabdesti like mdfnfe.tabdesti 
    field desti    like mdfnfe.desti
    field pesobrutokg like mdfnfe.pesobrutokg
    field valornf   like mdfnfe.valornota.

def buffer btt-mdfnfe for tt-mdfnfe.    
    
    form
        tt-mdfnfe.marca
        tt-mdfnfe.nfeID    format "xxxxxxxxxxxx..."
        vserie
        vnumero
        "EMIT"
        tt-mdfnfe.tabemite no-label format  "x(3)"
        tt-mdfnfe.emite    no-label format ">>>>>>99"
        vufemi          no-label
        vmunicemi no-label
        vplatot     
        skip
        space(2)
        tt-mdfnfe.placa no-label
                vemissao no-label 

        space(08)
        "DEST"
        tt-mdfnfe.tabdesti no-label format  "x(3)"
        tt-mdfnfe.desti    no-label format ">>>>>>99"
        vufdes          no-label 
        vmunicdes no-label

        with frame frame-a 3 down centered color white/red row 10
        title " Selecao NFEs para " + mdfviagem.placa + 
              " Emissao = " + string(vdtemi,"99/99/9999")
        no-underline width 80.

run pesquisa.
find first tt-mdfnfe no-error.
if not avail tt-mdfnfe
then do:
    run emissao.
    /**
        run mdfe/incmdfnfe.p (input recid(mdfviagem)).
    **/
end.
find first tt-mdfnfe no-error.
if not avail tt-mdfnfe
then do:
    return.
end.


bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find tt-mdfnfe where recid(mdfnfe) = recatu1 no-lock.
    if not available tt-mdfnfe
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then
        run frame-a.
    else do.
        run emissao.
        recatu1 = ?.
        leave.
    end.

    recatu1 = recid(tt-mdfnfe).
    color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tt-mdfnfe
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
            find tt-mdfnfe where recid(tt-mdfnfe) = recatu1 no-lock.

            disp esqcom1 with frame f-com1.
        color disp messages
        tt-mdfnfe.nfeID  
        vserie
        vnumero
        vemissao
        vplatot
        tt-mdfnfe.tabemite
        tt-mdfnfe.emite 
        vufemi 
        vmunicemi
        tt-mdfnfe.placa
        tt-mdfnfe.tabdesti 
        tt-mdfnfe.desti   
        vufdes
         vmunicdes.

            choose field tt-mdfnfe.nfeID
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      PF4 F4 ESC return).

            status default "".
 
        color disp normal
        tt-mdfnfe.nfeID  
        vserie
        vnumero
        vemissao
        vplatot
        tt-mdfnfe.tabemite
        tt-mdfnfe.emite 
        vufemi 
        vmunicemi
        tt-mdfnfe.placa
        tt-mdfnfe.tabdesti 
        tt-mdfnfe.desti   
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
                    if not avail tt-mdfnfe
                    then leave.
                    recatu1 = recid(tt-mdfnfe).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-mdfnfe
                    then leave.
                    recatu1 = recid(tt-mdfnfe).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-mdfnfe
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-mdfnfe
                then next.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then do:
            run cria.
            leave bl-princ.
        end.    

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            hide frame frame-a no-pause.
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.
                if esqcom1[esqpos1] = " Marca "
                then do .
                    tt-mdfnfe.marca = not tt-mdfnfe.marca.
                    disp tt-mdfnfe.marca
                        with frame frame-a.
                end. 
                if esqcom1[esqpos1] = " Todos "
                then do .
                    def var vmarca as log.
                    vmarca = tt-mdfnfe.marca.
                    for each btt-mdfnfe where btt-mdfnfe.marca = vmarca.
                        btt-mdfnfe.marca = not  vmarca.
                    end.  
                    recatu1 = ?.   
                    leave.
                end. 
                
                if esqcom1[esqpos1] = " Emissao "
                then do.
                    run emissao.
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
        recatu1 = recid(tt-mdfnfe).
    end.
end.
hide frame f-com1  no-pause.
hide frame frame-a no-pause.
hide frame f-dados no-pause.

procedure frame-a.

    vufemi = "**". vmunicemi = "**".
    vufdes = "**". vmunicdes = "**".
    
    if tt-mdfnfe.tabemite = "ESTAB" or 
       tt-mdfnfe.tabemite = ""
    then do:
        find estab where estab.etbcod = tt-mdfnfe.emite no-lock no-error.
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
    if tt-mdfnfe.tabemite = "FORNE"
    then do:
        find forne where forne.forcod = tt-mdfnfe.emite no-lock no-error.
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
 
    if tt-mdfnfe.tabdesti = "ESTAB" or 
       tt-mdfnfe.tabdesti = ""
    then do:
        find estab where estab.etbcod = tt-mdfnfe.desti no-lock no-error.
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
    
    if tt-mdfnfe.tabdesti = "FORNE"
    then do:
        find forne where forne.forcod = tt-mdfnfe.desti no-lock no-error.
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




    find first a01_infnfe where
        a01_infnfe.chave = tt-mdfnfe.infnfechave
        no-lock  no-error.

    vserie  = "".
    vnumero = 0.
    vemissao = ?.
    vplatot = ?.

    
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
    
    display 
        tt-mdfnfe.marca
        tt-mdfnfe.nfeID  
        vserie
        vnumero
        vemissao when vemissao <> ?
        vplatot when vplatot <> ?
        tt-mdfnfe.tabemite 
        tt-mdfnfe.emite   
        vufemi     
        vmunicemi
        
        tt-mdfnfe.placa
        tt-mdfnfe.tabdesti 
        tt-mdfnfe.desti   
        vufdes   
        vmunicdes
        

        with frame frame-a.
        
end procedure.

procedure leitura.
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then find last tt-mdfnfe  no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then find prev tt-mdfnfe  no-lock no-error.
             
if par-tipo = "up" 
then find next tt-mdfnfe no-lock no-error.

end procedure.



procedure pesquisa.


find veiculo where veiculo.placa = mdfviagem.placa no-lock.
find frete of mdfviagem no-lock.
find tpfrete of frete no-lock.
find forne of frete   no-lock.

for each x01_transp where
        x01_transp.dtmdf    = ? and
        (
        x01_transp.placa    = veiculo.placa /**or
        x01_transp.placa    = ""**/
        )
        no-lock.

    find A01_InfNFe of x01_transp no-lock no-error. 
    if not avail a01_infnfe 
    then next.  

    find first mdfnfe where mdfnfe.nfeid =  a01_infnfe.ID 
         no-lock no-error.
    if avail mdfnfe then next. 
    
    find x26_vol of a01_infnfe no-lock no-error.
    
    find plani where plani.etbcod = a01_infnfe.etbcod and 
                     plani.placod = a01_infnfe.placod and 
                     plani.serie  = a01_infnfe.serie 
               no-lock no-error. 
    if not avail plani then next.   

    if plani.pladat <> vdtemi /* so pega emissao da data */
    then next.
            
            vemite = plani.emite.
            vdesti = plani.desti.

            find tipmov of plani no-lock.
            if tipmov.movtnota 
            then do:
                vtabemite = "ESTAB".
                if tipmov.movttra or tipmov.movtdc = 36
                then do:
                    vtabdesti = "ESTAB".
                end.    
                else do:
                    if tipmov.movtvenda
                    then vtabdesti = "CLIEN".
                    else vtabdesti = "FORNE".
                end.
            end.
            else do:
                vtabemite = "FORNE".
                vtabdesti = "ESTAB".
            end.
    
    create tt-mdfnfe.
    
    assign
        tt-mdfnfe.marca = no
        tt-mdfnfe.infnfechave = a01_infnfe.chave
        tt-mdfnfe.nfeID    = a01_infnfe.ID 
        tt-mdfnfe.tabemite = vtabemite
        tt-mdfnfe.emite    = vemite
        tt-mdfnfe.tabdesti = vtabdesti
        tt-mdfnfe.desti    = vdesti.
        
    tt-mdfnfe.placa = x01_transp.placa.
    
    tt-mdfnfe.valornf = plani.platot.
    
    tt-mdfnfe.pesobrutokg = if avail x26_vol
                            then x26_vol.pesob
                            else 0.
                             
        
end.

 

end procedure.


procedure cria.

vrota = 1.
voperacao = no.

for each tt-mdfnfe where tt-mdfnfe.marca = yes.

    find first a01_infnfe where
        a01_infnfe.chave = tt-mdfnfe.infnfechave
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
    
    find first mdfnfe where mdfnfe.nfeid = tt-mdfnfe.nfeid
     no-lock no-error.
    if avail mdfnfe then next. 

    create mdfnfe.

    ASSIGN
    mdfnfe.etbcod      = mdfviagem.etbcod
    mdfnfe.InfNfeChave = tt-mdfnfe.Infnfechave
    mdfnfe.NfeID       = tt-mdfnfe.nfeID
    
    mdfnfe.MdfVCod     = mdfviagem.MdfVCod
    mdfnfe.RotaSeq     = vrota
    mdfnfe.tabemite    = tt-mdfnfe.tabemite
    mdfnfe.Emite       = tt-mdfnfe.emite
    mdfnfe.tabdesti    = tt-mdfnfe.tabdesti
    mdfnfe.Desti       = tt-mdfnfe.desti
    mdfnfe.serie       = vserie
    mdfnfe.numero      = vnumero
    mdfnfe.MdfeCod     = ?.
    mdfnfe.pesobrutoKG = tt-mdfnfe.pesobrutokg.
    mdfnfe.valorNota     = tt-mdfnfe.valornf.

    if voperacao = no then voperacao = yes.
    vrota = vrota + 1.

end.
 
end procedure.


procedure emissao.

vdtemi = today.

update
    vdtemi label "Data Emissao NFe"
    with frame femissao
    row 11 overlay centered width 40 side-labels. 

for each tt-mdfnfe.
    delete tt-mdfnfe.
end.

run pesquisa.
recatu1 = ?.

end procedure.
