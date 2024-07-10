/*************************************************
*    Antonio Maranghello
*    circuitit.p    -    Cadastro de Circuitos e titulos
*    26/06/2009
**************************************************/

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var v-ok            as char format "x(1)".
def var vbusca          like titcircui.ncircuito.
def var esqascend     as log initial yes.
def buffer btitcircui for titcircui.

def var esqcom1         as char format "x(12)" extent 6 
    initial [" Inclusao "," Alteracao "," Exclusao ",
    "Titulos", " Busca "," "].
def var esqcom2         as char format "x(12)" extent 6
            initial [" "," ","","","",""].
def var esqhel1         as char format "x(80)" extent 6
    initial [" Inclusao  de Circuito ",
             " Alteracao de Circuito ",
             " Exclusao  de Circuito ",
             " Titulos   de Circuito ",
             " Busca de Circuito ",
             ""].
def var esqhel2         as char format "x(12)" extent 6
   initial ["  ",
            " ",
            " ",
            " ",
            " "].

def new shared temp-table tt-titcircui like titcircui.

{admcab.i}

def buffer ctitcircui      for titcircui.
def var vtitcircui         like titcircui.ncircuito.
 

form
    esqcom1
    with frame f-com1
                 row 4 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1
    recatu1 = ?.

bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find titcircui where recid(titcircui) = recatu1 no-lock.
    if not available titcircui
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.
    if avail titcircui
    then recatu1 = recid(titcircui).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available titcircui
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
            find titcircui where recid(titcircui) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then string(titcircui.ncircuito)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(titcircui.ncircuito)
                                        else "".
            run color-message.
            run frame-a.
            choose field titcircui.ncircuito help ""
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
                    if not avail titcircui
                    then leave.
                    recatu1 = recid(titcircui).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail titcircui
                    then leave.
                    recatu1 = recid(titcircui).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail titcircui
                then next.
                color display white/red titcircui.ncircuito with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail titcircui
                then next.
                color display white/red titcircui.ncircuito with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form titcircui
                 with frame f-titcircui color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.
                if esqcom1[esqpos1] = " Busca "
                then do:
                     message "Informe N.Circuito p/Busca: "
                             update vbusca.
                     find first titcircui where titcircui.ncircuito =
                          vbusca no-error.
                     if not avail titcircui
                     then do:
                        message "Circuito Inexistente" 
                            view-as alert-box.
                       undo,retry.     
                     end.
                     assign recatu1 = recid(titcircui).
                     leave.
                end.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-titcircui on error undo.
                    for each tt-titcircui:
                        delete tt-titcircui.
                    end.
                    create tt-titcircui.
                    if esqcom1[esqpos1] = " Alteracao "
                    then do:
                        buffer-copy titcircui to tt-titcircui.
                        disp 
                             tt-titcircui.ncircuito
                             tt-titcircui.descricao
                             tt-titcircui.comple 
                             with frame f-inclui overlay.
                    end.
                    assign tt-titcircui.etbcod = 0.
                    if esqcom1[esqpos1] = " Inclusao "
                    then
                    update  tt-titcircui.ncircuito
                            with frame f-inclui row 8 centered.
                    find first titcircui where 
                               titcircui.empcod    = 19 and
                               titcircui.etbcod    = 0 and
                               titcircui.ncircuito = tt-titcircui.ncircuito and~                              titcircui.titnum    = "0" and
                               titcircui.titpar    = 0 no-error.
                    if not avail titcircui 
                    then do:
                         if esqcom1[esqpos1] = " Alteracao " 
                         then do:
                            message "Circuito nao Cadastrado"
                            view-as alert-box.
                            undo, retry. 
                         end.
                        assign tt-titcircui.descricao = ""
                               tt-titcircui.comple    = "".
                        create titcircui.
                    end.
                    else do:
                         if esqcom1[esqpos1] = " Inclusao " 
                         then do:
                            message "Circuito ja Cadastrado"
                            view-as alert-box.
                            undo, retry. 
                         end.
                          assign tt-titcircui.descricao = titcircui.descricao
                                 tt-titcircui.comple    = titcircui.comple.
                    end.
                    
                    update tt-titcircui.descricao 
                           tt-titcircui.comple label "Complemento"
                           skip with frame f-inclui.
                    assign titcircui.empcod = 19
                           titcircui.etbcod = 0    
                           titcircui.modcod = "LIK"   
                           titcircui.titpar = 0
                           titcircui.titnum = "0"
                           titcircui.ncircuito = tt-titcircui.ncircuito
                           titcircui.descricao = tt-titcircui.descricao
                           titcircui.comple = tt-titcircui.comple.
                     recatu1 = recid(titcircui).
                     leave.
                end.
                if esqcom1[esqpos1] = "Titulos" 
                then do with frame f-titulos-mos.
                   find first titcircui where recid(titcircui) = recatu1
                    no-error.
                   for each ctitcircui where 
                            ctitcircui.ncircuito = titcircui.ncircuito and
                            ctitcircui.titnat    = yes and
                            ctitcircui.titnum <> "0" no-lock:
                    /*
                   disp ctitcircui.etbcod
                        ctitcircui.modcod
                        ctitcircui.titnat
                        ctitcircui.titnum
                        ctitcircui.clifor.
                   pause.
                   */
                   for each titulo where 
                                        titulo.empcod = 19 and
                                        titulo.etbcod = ctitcircui.etbcod and
                                        titulo.titnat = yes and
                                        titulo.modcod = ctitcircui.modcod and
                                        titulo.titnum = ctitcircui.titnum 
                                no-lock:
 
                        find first forne
                                where forne.forcod = ctitcircui.clifor
                                        no-lock no-error.
                        disp titulo.etbcod
                             titulo.titnum
                             titulo.modcod
                             titulo.titpar   skip
                             forne.forcod fornom skip
                             titulo.titdtemi
                             titulo.titdtven
                             titulo.titvlcob
                             titulo.cobcod   skip
                             titulo.titvljur
                             titulo.titjuro
                             titulo.titdtdes skip
                             titulo.titvldes
                             titulo.titdtpag
                             titulo.titvlpag with frame ftitulo centered.
                       message "Tecle enter -> " update v-ok.
                   if key-function(last-key)= "F4" then leave.
                   end.
                   if key-function(last-key)= "F4" then leave.
                   end.
                end.
                if  esqcom1[esqpos1] = " Exclusao "
                then do:
                    disp titcircui.ncircuito titcircui.descricao                                           titcircui.compleme with frame f-exclui.
                end.
                if esqcom1[esqpos1] = " Exclusao "
                then do with frame f-exclui  row 5 1 column centered
                        on error undo.
                    message "Confirma Exclusao do circuito" 
                    titcircui.ncircuito "e de seus Vinculos a Titulos ?"
                    update sresp.
                    if not sresp
                    then undo, leave.
                    find next titcircui where true no-error.
                    if not available titcircui
                    then do:
                        find titcircui where recid(titcircui) = recatu1.
                        find prev titcircui where true no-error.
                    end.
                    recatu2 = if available titcircui
                              then recid(titcircui)
                              else ?.
                    find titcircui where recid(titcircui) = recatu1
                            exclusive.
                    for each btitcircui where
                             btitcircui.etbcod <> 0 and
                             btitcircui.ncircuito = titcircui.ncircuito and
                             btitcircui.titnat    = yes and
                             btitcircui.clifor    <> 0 :
                             delete btitcircui.
                    end.         
                             
                    delete titcircui.
                    recatu1 = recatu2.
                    leave.
                end.
                if esqcom1[esqpos1] = "Vincula Titulo"
                then do:
                    run circuitit_a.p (input recid(titcircui)).
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
                /*
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
                */
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
        recatu1 = recid(titcircui).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end .
end.
hide frame f-com1  no-pause.
hide frame f-com2  no-pause.
hide frame frame-a no-pause.

procedure frame-a.

def var vttitu as logical.

find first ctitcircui where 
                            ctitcircui.ncircuito = titcircui.ncircuito and
                            ctitcircui.titnat    = yes and
                            ctitcircui.titnum <> "0" no-lock no-error.

assign vttitu = no.

if avail ctitcircui
then do:
    find first titulo where
        titulo.titnat = yes and
        titulo.empcod = 19 and
        titulo.modcod = "lik" and
        titulo.titnum = ctitcircui.titnum and 
        titulo.etbcod = ctitcircui.etbcod no-lock no-error.

    assign vttitu = avail titulo.
end.

display titcircui.ncircuito 
        titcircui.descricao 
        titcircui.compleme label "Complemento"
        vttitu column-label "Titulo!Vinculado" format "sim/nao"
        with frame frame-a 6 down centered color white/red row 6.
        
end procedure.
procedure color-message.
color display message
        titcircui.ncircuito
        with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        titcircui.ncircuito
        with frame frame-a.
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first titcircui 
                                                no-lock no-error.
    else  
        find last titcircui  
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next titcircui  
                                                no-lock no-error.
    else  
        find prev titcircui  
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev titcircui  
                                        no-lock no-error.
    else   
        find next titcircui 
                                        no-lock no-error.
        
end procedure.
         
