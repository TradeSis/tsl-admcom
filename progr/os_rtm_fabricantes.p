/*
*
*    tt-fab.p    -    Esqueleto de Programacao    com esqvazio


            substituir    tt-fab
                          os
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

def input parameter p-classific-os as char.

def new shared var v-classific-os as char.

def shared var vetbcod like estab.etbcod.
def shared var vforcod  like forne.forcod.
def shared var vfabcod  like produ.fabcod.
def shared var v-filtro-doa   as logical format "Sim/Nao" initial no.
def shared var vdti as date.
def shared var vdtf as date.

def var esqcom1         as char format "x(12)" extent 5
    initial [" PRODUTOS ","   ","   "," "," "].
def var esqcom2         as char format "x(12)" extent 5
            initial [" "," ","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial [" PRODUTOS DE ",
             "  ",
             "  ",
             "  ",
             "  "].
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].

{admcab.i}


def temp-table tt-fab
    field fabcod        as integer
    field fabnom         as character
    field cont          as integer
    field percent       as decimal.

def buffer btt-fab       for tt-fab.
def var vtt-fab          as integer.


form
    esqcom1
    with frame f-com1
                 row 4 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.

assign v-classific-os = p-classific-os.

for each asstec_aux where
         asstec_aux.data_campo >= vdti and
         asstec_aux.data_campo <= vdtf and
         asstec_aux.nome_campo = "REGISTRO-TROCA" 
             no-lock,
         
    first asstec where
          asstec.oscod = asstec_aux.oscod  and
         (if vforcod > 0 then asstec.forcod = vforcod else true) and
         (if vetbcod > 0 then asstec.etbcod = vetbcod else true)
               no-lock,
               
    first produ where produ.procod = asstec.procod 
                       and (if vfabcod = 0  then true
                            else produ.fabcod  = vfabcod) no-lock,
                            
    first fabri where fabri.fabcod = produ.fabcod no-lock:
    
    /**********************************
    if asstec.planum > 0 
        and v-classific-os = "GARANTIA PLANO BI$"
    then do:
        find first plani where plani.etbcod = asstec.etbcod and
                               plani.movtdc = 5 and
                               plani.emite  =  asstec.etbcod and
                               plani.serie = "V" and
                               plani.numero = asstec.planum and
                               plani.pladat = asstec.pladat and
                               plani.pladat >= 11/01/2011
                               no-lock no-error.
        if not avail plani
        then next.

        find first tabaux where tabaux.tabela = "PLANOBIZ" and
                   tabaux.valor_campo = string(plani.pedcod)
                           no-lock no-error.
        if avail tabaux
        then next.
            
    end.
    *******************************/
    
    if v-filtro-doa
    then do:
                   
       if not (acha("DOA",asstec.proobs) = "Yes")
       then next.
                                            
    end.
    
    if p-classific-os <> "### TOTAL GERAL ###"
        and asstec_aux.valor_campo <> p-classific-os
    then next.    
    
    find first btt-fab where btt-fab.fabnom = "### TOTAL GERAL ###"
                                      no-lock no-error.
    if not avail btt-fab
    then create btt-fab.
        
    assign btt-fab.fabcod = 1
           btt-fab.fabnom = "### TOTAL GERAL ###"
           btt-fab.cont = btt-fab.cont + 1. 
    
    find first tt-fab where tt-fab.fabcod = fabri.fabcod
                            no-lock no-error.

    if not avail tt-fab
    then create tt-fab.
    
    assign tt-fab.fabcod = produ.fabcod
           tt-fab.fabnom = fabri.fabnom
           tt-fab.cont = tt-fab.cont + 1.
    
end.

release btt-fab.
find first btt-fab where btt-fab.fabnom = "### TOTAL GERAL ###"
                                      no-lock no-error.

for each tt-fab where tt-fab.fabnom <> "### TOTAL GERAL ###"
                                        no-lock.

    assign tt-fab.percent = (tt-fab.cont * 100 / btt-fab.cont).

end.                                      

assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find tt-fab where recid(tt-fab) = recatu1 no-lock.
    if not available tt-fab
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(tt-fab).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tt-fab
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
            find tt-fab where recid(tt-fab) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + string(tt-fab.fabnom)

                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(tt-fab.fabnom)
                                        else "".
            run color-message.
            choose field tt-fab.fabcod help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return).
            run color-normal.
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
                    if not avail tt-fab
                    then leave.
                    recatu1 = recid(tt-fab).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-fab
                    then leave.
                    recatu1 = recid(tt-fab).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-fab
                then next.
                color display white/red tt-fab.fabcod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-fab
                then next.
                color display white/red tt-fab.fabcod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form tt-fab
                 with frame f-tt-fab color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-tt-fab on error undo.
                    create tt-fab.
                    update tt-fab.
                    recatu1 = recid(tt-fab).
                    leave.
                end.
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Exclusao " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-tt-fab.
                    disp tt-fab.
                end.
                
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-tt-fab on error undo.
                    find tt-fab where
                            recid(tt-fab) = recatu1 
                        exclusive.
                    update tt-fab.
                end.
                
                
                if esqcom1[esqpos1] = " Exclusao "
                then do with frame f-exclui  row 5 1 column centered
                        on error undo.
                    message "Confirma Exclusao de" tt-fab.fabnom
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next tt-fab where true no-error.
                    if not available tt-fab
                    then do:
                        find tt-fab where recid(tt-fab) = recatu1.
                        find prev tt-fab where true no-error.
                    end.
                    recatu2 = if available tt-fab
                              then recid(tt-fab)
                              else ?.
                    find tt-fab where recid(tt-fab) = recatu1
                            exclusive.
                    delete tt-fab.
                    recatu1 = recatu2.
                    leave.
                end.
                if esqcom1[esqpos1] = " Listagem "
                then do with frame f-Lista:
                    update "Deseja Imprimir todas ou a selecionada "
                           sresp format "Todas/Selecionada"
                                 help "Todas/Selecionadas"
                           with frame f-lista row 15 centered color black/cyan
                                 no-label.
                    if sresp
                    then run ltt-fab.p (input 0).
                    else run ltt-fab.p (input tt-fab.fabcod).
                    leave.
                end.
                
                if esqcom1[esqpos1] = " PRODUTOS "
                then do with frame f-tt-fab on error undo.

                    pause 0.
                    run os_rtm_produtos.p(input "Fabricante",
                                          input tt-fab.fabcod,
                                          input tt-fab.fabnom).
                
                end.                
                
            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                if esqcom2[esqpos2] = "  "
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    /* run programa de relacionamento.p (input ). */
                    view frame f-com1.
                    view frame f-com2.
                end.
                leave.
            end.
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(tt-fab).
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

procedure frame-a.
display tt-fab.fabcod format "999999999"          label "COD"
        tt-fab.fabnom format "x(35)"         label "CLASSE"
        tt-fab.cont  format ">>>,>>>,>>9"   label "QUANTIDADE"
        tt-fab.percent  format ">>>,>>9.99%"   label "% QTDE"
        with frame frame-a 11 down centered  color white/red row 5.
end procedure.
procedure color-message.
color display message
        tt-fab.fabcod
        tt-fab.fabnom
        tt-fab.cont
        tt-fab.percent
        with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        tt-fab.fabcod
        tt-fab.fabnom
        tt-fab.cont
        tt-fab.percent
        with frame frame-a.
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first tt-fab where true
                                                no-lock no-error.
    else  
        find last tt-fab  where true
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next tt-fab  where true
                                                no-lock no-error.
    else  
        find prev tt-fab   where true
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev tt-fab where true  
                                        no-lock no-error.
    else   
        find next tt-fab where true 
                                        no-lock no-error.
        
end procedure.
         
