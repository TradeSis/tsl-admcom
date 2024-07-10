/*************************************************
*    Antonio Maranghello
*    circuitit.p    -    Cadastro de Circuitos e titulos
*    26/06/2009
**************************************************/

pause 0.

def input parameter p-recid as recid.

def buffer btitcircui       for titcircui.

def var v-data-aux      as date. 
def var recatu1         as recid.
def var recatu2         as recid.
def var v-ok            as logical format "Sim/Nao".
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.                                     
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend       as log initial yes.
def var vnumcircui      like titcircui.ncircuito.
def var esqcom1         as char format "x(18)" extent 5
    initial ["Vincula Titulo","Desvincula Titulo"," "," ",""].
def var esqcom2         as char format "x(12)" extent 5
            initial [" "," ","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial [" Vincula Titulo a Circuito ",
             " Desvincula Titulo a Circuito ",
             " ",
             " ",
             ""].
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].

def shared temp-table tt-titcircui like titcircui.

def temp-table tt-wtitcircui like titcircui.

find first btitcircui where recid(btitcircui) = p-recid no-lock no-error.

for each tt-wtitcircui:
    delete tt-wtitcircui.
end.

for each titcircui  
        where titcircui.empcod = 19     
             and titcircui.etbcod <> 0  
             and titcircui.ncircuito = btitcircui.ncircuito
                       no-lock:

        create tt-wtitcircui.
        buffer-copy titcircui to tt-wtitcircui.
end.

{admcab.i new}

def buffer btt-wtiticircui for tt-wtitcircui.
def var vtitcircui         like titcircui.ncircuito.

form
    esqcom1
    with frame f-com1
                 row 8 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

    display btitcircui.ncircuito 
        btitcircui.descricao 
        btitcircui.compleme label "Complemento"
        with frame frame-exibe centered color white/red 
            title " Circuito " row 3.
    assign vnumcircui = btitcircui.ncircuito.

bl-princ:
repeat:

    pause 0.
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find tt-wtitcircui where recid(tt-wtitcircui) = recatu1 no-lock.
    if not available tt-wtitcircui
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(tt-wtitcircui).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tt-wtitcircui
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
            find tt-wtitcircui where recid(tt-wtitcircui) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then string(tt-wtitcircui.titnum)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                       then string(tt-wtitcircui.titnum)
                                        else "".
            run color-message.
            run frame-a.
            choose field tt-wtitcircui.titnum help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return) . /* color white/black.*/
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
                    if not avail tt-wtitcircui
                    then leave.
                    recatu1 = recid(tt-wtitcircui).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-wtitcircui
                    then leave.
                    recatu1 = recid(tt-wtitcircui).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-wtitcircui
                then next.
                color display white/red 
                    tt-wtitcircui.titnum with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-wtitcircui
                then next.
                color display white/red tt-wtitcircui.titnum 
                with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form tt-wtitcircui             
                 with frame f-tt-wtitcircui color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = "Vincula Titulo"
                                        or esqvazio 
                then do with frame f-tt-wtitcircui on error undo.
                    create tt-wtitcircui.
                    assign tt-wtitcircui.clifor = 0
                           tt-wtitcircui.ncircuito = vnumcircui
                           tt-wtitcircui.modcod = "LIK".
                    update tt-wtitcircui.etbcod label "Filial" skip
                           tt-wtitcircui.clifor label "Fabricante" 
                           with frame f-manut
                           centered row 14 side-labels title "Titulos".
                    
                    find first forne where 
                            forne.forcod = tt-wtitcircui.clifor
                            no-lock no-error.
                    if not avail forne
                    then do:
                        message "Fornecedor nao Cadastrado !"
                        view-as alert-box.
                        undo, retry.
                    end.        
                    else disp forne.fornom no-label with frame f-manut.
                    
                    update tt-wtitcircui.titnum label "Titulo Num."
                           tt-wtitcircui.parcela label "Parcela" 
                           with frame f-manut
                           centered row 14 side-labels.
                     if  tt-wtitcircui.etbcod = 0 or 
                         tt-wtitcircui.titnum = "0" or
                         tt-wtitcircui.clifor = 0  
                    then do:
                        message "Titulo Invalido !" 
                        view-as alert-box.
                        undo, retry.
                    end.
                    find first titcircui 
                         where titcircui.empcod  = 19 and 
                               titcircui.etbcod  = tt-wtitcircui.etbcod and
                               titcircui.clifor  = tt-wtitcircui.clifor and
                               titcircui.modcod  = tt-wtitcircui.modcod and
                               titcircui.titnum  = tt-wtitcircui.titnum and
                               titcircui.parcela = tt-wtitcircui.parcela 
                             exclusive no-error.
                    if avail titcircui 
                    then do:
                        message "Titulo ja Cadastrado para circuito" titcircui.ncircuito "!"  
                        view-as alert-box.
                        undo, retry.
                    end.
                    find first  titulo 
                         where  titulo.empcod = 19 and
                                titulo.etbcod = tt-wtitcircui.etbcod and
                                titulo.titnat = yes and
                                titulo.etbcod = tt-wtitcircui.etbcod and
                                titulo.titnum = tt-wtitcircui.titnum
                                no-lock no-error.
                    disp titulo.titdtemi format "99/99/9999"
                    label "Data Emissao"
                    tt-wtitcircui.modcod  label "Modalidade"                                              with frame f-manut.
                    message "Confirma Vinculo ao Titulo no Circuito" vnumcircui "?" update v-ok.
                    pause 1 before-hide.
                    hide message.  
                    if v-ok = no then undo.
                    else do:
                        create titcircui.
                        assign titcircui.empcod    = 19
                           titcircui.etbcod    = tt-wtitcircui.etbcod
                           titcircui.titnat    = yes
                           titcircui.modcod    = titulo.modcod
                           titcircui.ncircuito = tt-wtitcircui.ncircuito
                           titcircui.clifor    = tt-wtitcircui.clifor
                           titcircui.titnum    = tt-wtitcircui.titnum
                           titcircui.parcela   = tt-wtitcircui.parcela.    
                    end.
                end.

                if esqcom1[esqpos1] = "Desvincula Titulo"
                then do with frame f-exclui  row 5 1 column centered
                        on error undo.
                    assign v-ok = no.
                    message "Confirma Desvincular Titulo" titulo.titnum 
                    "do circuito" tt-wtitcircui.ncircuito "?" 
                    update v-ok. 
                    if v-ok = no
                    then undo, leave.
                    find current tt-wtitcircui no-error.
                    find first btitcircui
                            where btitcircui.empcod = 19 and
                             btitcircui.etbcod    = tt-wtitcircui.etbcod  and
                             btitcircui.ncircuito = tt-wtitcircui.ncircuito and
                             btitcircui.modcod    = tt-wtitcircui.modcod and
                             btitcircui.titnat    = yes and
                             btitcircui.clifor    = tt-wtitcircui.clifor
                             exclusive no-error.
                    if avail btitcircui
                    then delete btitcircui.
                    delete tt-wtitcircui.
                    recatu1 = ?.
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
                    then run ltitcircui.p (input 0).
                    else run ltitcircui.p (input titcircui.ncircuito).
                    leave.
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
        recatu1 = recid(tt-wtitcircui).
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
find first titulo where titulo.empcod = 19 and 
        titulo.titnat = yes and
        titulo.clifor = tt-wtitcircui.clifor and
        titulo.titpar = tt-wtitcircui.parcela and
        titulo.titnum = tt-wtitcircui.titnum and
        titulo.etbcod = tt-wtitcircui.etbcod no-lock no-error.
pause 0.
display tt-wtitcircui.titnum
        titulo.titdtemi
        tt-wtitcircui.parcela
        titulo.titvlcob
        titulo.titdtpag
        tt-wtitcircui.clifor 
         with frame frame-a 5 down centered color white/red row 10.
end procedure.

procedure color-message.
color display message
        tt-wtitcircui.titnum
        with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        tt-wtitcircui.titnum
        with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first tt-wtitcircui where true
                                                no-lock no-error.
    else  
        find last tt-wtitcircui  where true
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next tt-wtitcircui  where true
                                                no-lock no-error.
    else  
        find prev tt-wtitcircui   where true
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev tt-wtitcircui where true  
                                        no-lock no-error.
    else   
        find next tt-wtitcircui where true 
                                        no-lock no-error.
        
end procedure.
         
