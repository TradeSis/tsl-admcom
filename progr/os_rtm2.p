/*
*
*    tt-os.p    -    Esqueleto de Programacao    com esqvazio


            substituir    tt-os
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

def new shared var vetbcod like estab.etbcod.
def new shared var vforcod  like forne.forcod.
def new shared var vfabcod  like produ.fabcod.
def new shared var v-filtro-doa   as logical format "Sim/Nao" initial no.
def new shared var vdti as date.
def new shared var vdtf as date.


def var esqcom1         as char format "x(12)" extent 5
    initial [" SUB-CLASSES "," FABRICANTES ","   "," "," "].
def var esqcom2         as char format "x(12)" extent 5
            initial [" "," ","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial [" SUBCLASSES DE ",
             " FABRICANTES DE ",
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


def temp-table tt-os
    field oscod         as integer
    field osnom         as character
    field cont          as integer
    field percent       as decimal.

create tt-os.
assign tt-os.oscod = 1
       tt-os.osnom = "### TOTAL GERAL ###"
       tt-os.percent = 100.00.

create tt-os.
assign tt-os.oscod = 2
       tt-os.osnom = "30 DIAS".

create tt-os.
assign tt-os.oscod = 3
       tt-os.osnom = "REINCIDENCIA".

create tt-os.
assign tt-os.oscod = 4
       tt-os.osnom = "GARANTIA PLANO BI$".
                

def buffer btt-os       for tt-os.
def var vtt-os          as integer.


form
    esqcom1
    with frame f-com1
                 row 4 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.

assign vdti = 12/01/2011
       vdtf = 12/12/2011.

update vetbcod label "Filial      " colon 13
        with frame f1 1 down width 80 side-label.

if vetbcod > 0
then do:
    find estab where estab.etbcod = vetbcod no-lock.
        disp estab.etbnom at 23 no-label with frame f1.
end.
else disp "GERAL" @ estab.etbnom with frame f1.

update vfabcod label "Fabricante  " colon 13 with frame f1.
if vfabcod > 0
then do:
     find fabri where fabri.fabcod = vfabcod no-lock no-error.
     if avail fabri
     then do:
          disp fabri.fabnom at 23 no-label with frame f1.
     end.
end.
else do:
    if vfabcod = 0
    then display "GERAL" @ fabri.fabnom no-label with frame f1.
end.
    

update vforcod label "Fornecedor  " colon 13
       with frame f1 down width 80 side-label.

if vforcod > 0
then do:
    find forne where forne.forcod = vforcod no-lock.
        disp forne.fornom no-label at 23 with frame f1.
end.
else disp "GERAL" @ forne.fornom with frame f1.
                  
update vdti label "Data Inicial" colon 13 format "99/99/9999"
       vdtf label "Data Final  "  colon 13 format "99/99/9999"  with frame f1.

update v-filtro-doa label "DOA         " colon 13 with frame f1.

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
                            else produ.fabcod  = vfabcod) no-lock:
                            
    /**************************************
    if asstec.planum > 0 
        and asstec_aux.valor_campo = "GARANTIA PLANO BI$"
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
        if not avail tabaux
        then next.
            
    end.
    *****************************/
    
    if v-filtro-doa
    then do:
                   
       if not (acha("DOA",asstec.proobs) = "Yes")
       then next.
                                            
    end.
    
    find first tt-os where tt-os.osnom = asstec_aux.valor_campo
                            no-lock no-error.

    if not avail tt-os
    then next.
    else assign tt-os.cont = tt-os.cont + 1.
    
    release btt-os.
    find first btt-os where btt-os.osnom = "### TOTAL GERAL ###"
                                no-lock no-error.
    if avail btt-os 
    then btt-os.cont = btt-os.cont + 1.

end.

release btt-os.
find first btt-os where btt-os.osnom = "### TOTAL GERAL ###"
                               no-lock no-error.
                                    
for each tt-os where tt-os.osnom <> "### TOTAL GERAL ###" exclusive-lock.
    
    assign tt-os.percent = (tt-os.cont * 100 / btt-os.cont).

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
        find tt-os where recid(tt-os) = recatu1 no-lock.
    if not available tt-os
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(tt-os).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tt-os
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
            find tt-os where recid(tt-os) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + string(tt-os.osnom)

                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(tt-os.osnom)
                                        else "".
            run color-message.
            choose field tt-os.oscod help ""
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
                    if not avail tt-os
                    then leave.
                    recatu1 = recid(tt-os).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-os
                    then leave.
                    recatu1 = recid(tt-os).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-os
                then next.
                color display white/red tt-os.oscod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-os
                then next.
                color display white/red tt-os.oscod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form tt-os
                 with frame f-tt-os color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-tt-os on error undo.
                    create tt-os.
                    update tt-os.
                    recatu1 = recid(tt-os).
                    leave.
                end.
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Exclusao " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-tt-os.
                    disp tt-os.
                end.
                
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-tt-os on error undo.
                    find tt-os where
                            recid(tt-os) = recatu1 
                        exclusive.
                    update tt-os.
                end.
                
                if esqcom1[esqpos1] = " Exclusao "
                then do with frame f-exclui  row 5 1 column centered
                        on error undo.
                    message "Confirma Exclusao de" tt-os.osnom
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next tt-os where true no-error.
                    if not available tt-os
                    then do:
                        find tt-os where recid(tt-os) = recatu1.
                        find prev tt-os where true no-error.
                    end.
                    recatu2 = if available tt-os
                              then recid(tt-os)
                              else ?.
                    find tt-os where recid(tt-os) = recatu1
                            exclusive.
                    delete tt-os.
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
                    then run ltt-os.p (input 0).
                    else run ltt-os.p (input tt-os.oscod).
                    leave.
                end.
                
                if esqcom1[esqpos1] = " SUB-CLASSES "
                then do with frame f-tt-os on error undo.
                    
                    pause 0.   
                    
                    if tt-os.cont > 0
                    then do:
                                       
                        run os_rtm_subclasse.p (input tt-os.osnom) .
                        
                    end.
                    else do:
                    
                        message "Não existe OS para a classificação escolhida."
                                view-as alert-box.
                    
                    end.

                end.
                
                
                if esqcom1[esqpos1] = " FABRICANTES "
                then do with frame f-tt-os on error undo.
                    
                    pause 0.    

                    if tt-os.cont > 0
                    then do:
                                        
                        run os_rtm_fabricantes.p (input tt-os.osnom) .

                    end.
                    else do:
                                        
                        message "Não existe OS para a classificação escolhida."
                                view-as alert-box.
                                
                    end.

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
        recatu1 = recid(tt-os).
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
display tt-os.oscod      format ">>>9"          label "COD"
        tt-os.osnom      format "x(35)"         label "CLASSIFICAÇÃO"
        tt-os.cont       format ">>>,>>>,>>9"   label "QUANTIDADE"
        tt-os.percent    format ">>>,>>9.99%"   label "% QTDE"
        with frame frame-a 11 down centered  color white/red row 5.
end procedure.
procedure color-message.
color display message
        tt-os.oscod
        tt-os.osnom
        tt-os.cont
        tt-os.percent
        with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        tt-os.oscod
        tt-os.osnom
        tt-os.cont
        tt-os.percent
        with frame frame-a.
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first tt-os where true
                                                no-lock no-error.
    else  
        find last tt-os  where true
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next tt-os  where true
                                                no-lock no-error.
    else  
        find prev tt-os   where true
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev tt-os where true  
                                        no-lock no-error.
    else   
        find next tt-os where true 
                                        no-lock no-error.
        
end procedure.
         
