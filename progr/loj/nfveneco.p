{admcab.i}
 
def var vresumo as log.

/***
def workfile wfclien
    field clicod        like clien.clicod init 0.
def buffer bwfclien for wfclien.
***/

def var vmovtdc like tipmov.movtdc.
def var vemite  like plani.emite.
def var vemitet as log init yes.
def var vdesti  like plani.desti.
def var vdtini  as date format "99/99/9999".
def var vdtfin  as date format "99/99/9999".
def var vdata as date. 
def var vtransf as log.
def buffer bclien for clien.
def new shared  temp-table tt-plani
    field rec   as recid.

/***
def var clacod-grupo like clase.clacod.
def var setcod-setor like setor.setcod.
def var vfabcod      like fabri.fabcod.
***/

form vmovtdc label "Tipo de Movimento" colon 20 format ">>>"
     tipmov.movtnom  no-label   
     setbcod colon 20
     estab.etbnom no-label
     skip    
     vdtini  label "Data Inicial"   colon 20 help "Informe a Data Inicial"
     vdtfin  label "Data Final"     help "Informe a Data Final"
     with frame f1 1 down side-label width 80 color with/cyan.

repeat with frame f1.       
    clear frame f1 all.
    assign
        vmovtdc = 0 
        vemite = 0
        vdesti = 0
/***
        clacod-grupo = 0
        vfabcod = 0
***/
        vtransf = no.

    vmovtdc = 5.
    find tipmov where tipmov.movtdc = vmovtdc no-lock no-error.
    display vmovtdc tipmov.movtnom with frame f1.

    disp setbcod.
    find estab where estab.etbcod = setbcod no-lock no-error.
    if not avail estab
    then do.
        message "Estabelecimento invalido" view-as alert-box.
        undo.
    end.
    disp estab.etbnom.

/***
    for each wfclien.
        delete wfclien.
    end.
    if vemitet = yes
    then do:
        create wfclien.
        wfclien.clicod = 0.
    end.
    else   
    repeat with frame fclien title "Selecao de Emitentes"
                        centered retain 1 row 14 overlay.
        find first wfclien no-error.
        if not avail wfclien 
        then do:
            create wfclien.
            wfclien.clicod = 0.
        end.
        else do:
            create wfclien.
        end.
        if wfclien.clicod = 0
        then do:
            leave.
        end.
        find first bwfclien where bwfclien.clicod = wfclien.clicod and
                             recid(bwfclien) <> recid(wfclien)
                        no-error.
        if avail bwfclien
        then undo.
        find first clien where clien.clicod = wfclien.clicod no-lock no-error.
        if not avail clien
        then do:
            message "Emitente Invalido".
            delete wfclien.
            undo.
        end.
        disp clien.clinom.
    end.
    hide frame fclien no-pause.

    find first wfclien where wfclien.clicod = 0 no-lock no-error.
    find first bwfclien where bwfclien.clicod <> 0 no-lock no-error.
    if avail bwfclien and avail wfclien
    then delete wfclien.    
***/
    
    update vdesti = 0 with frame f1.
    if vdesti > 0
    then do:
        find bclien where bclien.clicod = vdesti no-lock no-error.
        if not avail bclien
        then do:
            message color red/with
                "Codigo Invalido para Destino"
                view-as alert-box title " Atencao!! ".
            next.
        end.
    end.
/***
    update setcod-setor = 0 with frame f1.
    if setcod-setor <> 0
    then do.
        find setor where setor.setcod = setcod-setor no-lock no-error.
        if not avail setor
        then do.
            message "Setor invalido".
            undo.
        end.
    end.

    update clacod-grupo = 0  /*when setcod-setor not entered */ with frame f1.
    if clacod-grupo <> 0
    then do.
        find clase where clase.clacod = clacod-grupo no-lock no-error.
        if not avail clase
        then do.
            message "Grupo invalido".
            undo.
        end.
    end.
    update vfabcod = 0 with frame f1.
    if vfabcod <> 0
    then do.
        find fabri where fabri.fabcod = vfabcod no-lock no-error.
        if not avail fabri
        then do.
            message "Fabricante invalido".
            undo.
        end.
    end.
***/
    vdtini = today.
    vdtfin = today.
    update vdtini vdtfin with frame f1.
    if vdtini = ? or vdtfin = ? or vdtini > vdtfin
    then do:
        message "Periodo Invalido" view-as alert-box title " Atencao!! ".
        next.
    end.        

for each tt-plani.
   delete tt-plani.
end.

/***
def var vokcla as log.
def var vokfab as log.
def var vokset as log.
vokfab = yes.
vokcla = yes.
vokset = yes.
***/

do vdata = vdtini to vdtfin.
    for each plani where plani.pladat = vdata
                     and plani.movtdc = vmovtdc 
                     and plani.etbcod = setbcod 
                  use-index pladat
                  no-lock.
        if plani.desti = 1
        then next.           

        if plani.notped = ""
        then next.
        
/***
        /* Luciane - 25/04/2007 - 15209 */          
        find first wfclien no-error.
        if avail wfclien
        then do:
            if wfclien.clicod = 0
            then.
            else do:
                find first wfclien where wfclien.clicod = plani.emite
                                                                    no-error.
                if not avail wfclien
                then next.
            end.
        end.
***/
/***
        if clacod-grupo <> 0 or
           vfabcod <> 0  or
           setcod-setor <> 0
        then do.
            vokfab = no.
            vokcla = no.
            vokset = no.
            for each movim where movim.etbcod = plani.etbcod and
                                 movim.placod = plani.placod no-lock.
                find produ of movim no-lock no-error.
                if not avail produ
                then next. 
            end.
            if vfabcod      <> 0 and vokfab = no then next.
            if clacod-grupo <> 0 and vokcla = no then next.
            if setcod-setor <> 0 and vokset = no then next.
        end.
***/
        if vtransf 
        then . 
        if plani.movtdc = 19 or plani.movtdc = 20  
        then next. 

        create tt-plani. 
        tt-plani.rec = recid(plani).
    end.
    for each plani where plani.pladat = vdata
                     and plani.movtdc = 81 
                     and plani.etbcod = setbcod 
                  use-index pladat
                  no-lock.
        if plani.desti = 1
        then next.           

        if plani.notped = ""
        then next.
        
/***
        /* Luciane - 25/04/2007 - 15209 */          
        find first wfclien no-error.
        if avail wfclien
        then do:
            if wfclien.clicod = 0
            then.
            else do:
                find first wfclien where wfclien.clicod = plani.emite
                                                                    no-error.
                if not avail wfclien
                then next.
            end.
        end.
***/
/***
        if clacod-grupo <> 0 or
           vfabcod <> 0  or
           setcod-setor <> 0
        then do.
            vokfab = no.
            vokcla = no.
            vokset = no.
            for each movim where movim.etbcod = plani.etbcod and
                                 movim.placod = plani.placod no-lock.
                find produ of movim no-lock no-error.
                if not avail produ
                then next. 
            end.
            if vfabcod      <> 0 and vokfab = no then next.
            if clacod-grupo <> 0 and vokcla = no then next.
            if setcod-setor <> 0 and vokset = no then next.
        end.
***/
        if vtransf 
        then . 
        if plani.movtdc = 19 or plani.movtdc = 20  
        then next. 

        create tt-plani. 
        tt-plani.rec = recid(plani).
    end.
end.

/*
*
*    <tabela>.p    -    Esqueleto de Programacao    com esqvazio
*
*/

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Consulta "," ", " "].
def var esqcom2         as char format "x(12)" extent 5
    initial [" Acoberta "," Devolucao "," ","",""].

esqcom2[2] = "".

form
    esqcom1
    with frame f-com1
                 row 4 no-box no-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels column 1 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.
    recatu1 = ?.

def var vpor       as log format "Destinatario/Emitente".

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then run leitura (input "pri").
    else find tt-plani where recid(tt-plani) = recatu1 no-lock.
    if not available tt-plani
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then run frame-a.
    else do.
       message "Notas fiscais nao localizadas" view-as alert-box.
       leave.
    end.

    recatu1 = recid(tt-plani).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tt-plani
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        if not esqvazio
        then do:
            find tt-plani where recid(tt-plani) = recatu1 no-lock.

            choose field plani.numero help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return).

            status default "".

        end.
            if keyfunction(lastkey) = "TAB"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    color display message esqcom2[esqpos2] with frame f-com2.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    color display message esqcom1[esqpos1] with frame f-com1.
                end.
                esqregua = not esqregua.
            end.
            if keyfunction(lastkey) = "cursor-right"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 5 then 5 else esqpos2 + 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                end.
                next.
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 1 then 1 else esqpos2 - 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                end.
                next.
            end.
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail tt-plani
                    then leave.
                    recatu1 = recid(tt-plani).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-plani
                    then leave.
                    recatu1 = recid(tt-plani).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-plani
                then next.
                color display white/red plani.numero with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-plani
                then next.
                color display white/red plani.numero with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Consulta "
                then do.
                    hide frame frame-a no-pause.
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    run not_consnota.p (recid(plani)). 
                    view frame frame-a.
                    view frame f-com1.
                    view frame f-com2.
                    leave.
                end.
            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.

                if esqcom2[esqpos2] = " Devolucao "
                then do.
                    hide frame frame-a no-pause.
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    run devven-ecom_nfe.p (recid(plani)).
                    view frame f-com1.
                    view frame frame-a.
                    view frame f-com2.
                    leave.
                end.
                if esqcom2[esqpos2] =  " Acoberta "
                then do.
/***
                    if plani.notped = "C" /*** plani.serie = "3" or
                       plani.serie = "V3"***/
                    then do:
                        message "NFCe não permite acobertamento."
                        view-as alert-box.
                        leave.
                    end. 
***/
                    hide frame frame-a no-pause.
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    nota_acobertada:
                    do:
                        run loj/nfacobecom_nfe.p (recid(plani)) no-error.
                        if error-status:error
                        then do:
                            message "Erro ao gerar nota acobertada!"
                                            view-as alert-box.
                            undo, leave.
                        end.    
                        else leave.
                    end.
                    view frame f-com1.
                    view frame frame-a.
                    view frame f-com2.
                    leave.
                end.
            end.
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(tt-plani).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame f-com2  no-pause.
hide frame frame-a no-pause.
end.


procedure frame-a.

   def var vnome as char.

   find plani where recid(plani) = tt-plani.rec no-lock.

   find clien where 
                         clien.clicod  = if vpor
                                        then plani.emite
                                        else plani.desti no-lock no-error.
        vnome = if avail clien
                then clien.clinom
                else "*******"  .
            
        display
                plani.etbcod
                plani.serie column-label "Ser"
                plani.numero  format ">>>>>>>9"
                plani.dtinclu format "99/99/99" 
                clien.clinom  format "x(30)"
                plani.platot 
                with frame frame-a 8 down centered  row 6 no-box.

end procedure.
 
procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then   find first tt-plani where true no-lock no-error.
    else   find last tt-plani  where true no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then   find next tt-plani  where true no-lock no-error.
    else   find prev tt-plani   where true no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then    find prev tt-plani where true   no-lock no-error.
    else    find next tt-plani where true  no-lock no-error.
        
end procedure.
 
