{admcab.i}

def shared temp-table tt-cli
    field clicod like clien.clicod
    field clinom like clien.clinom
    index iclicod is primary unique clicod.

def temp-table tt-acao       like acao.
def temp-table tt-acao-cli   like acao-cli.

def temp-table tt-clinacao
    field acaocod   like acao-cli.acaocod
    field clicod    like acao-cli.clicod
    index ch_clicod is primary clicod
    index ch_acao   acaocod clicod.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.

def var esqcom1         as char format "x(12)" extent 5
    initial [" Gerar Acao "," "," "," "," "].

def var esqcom2         as char format "x(12)" extent 5
            initial [" "," ","","",""].

/*
def var esqhel1         as char format "x(80)" extent 5
    initial [" Inclusao  de tt-cli ",
             " Alteracao da tt-cli ",
             " Exclusao  da tt-cli ",
             " Consulta  da tt-cli ",
             " Listagem  Geral de tt-cli "].
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].
*/

def buffer btt-cli       for tt-cli.
def var vtt-cli         like tt-cli.clicod.

def var vtotal as int format ">>>>>>>>9".

form vtotal label "Total de Clientes"
    with frame f-tot row 20 no-box side-labels centered.

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
    esqpos2  = 1.

find first tt-cli no-error.
if not avail tt-cli
then do:
    message "Nenhum cliente encontrado.".
    pause 2 no-message.
    leave.
end.

vtotal = 0.
for each tt-cli:
    vtotal = vtotal + 1.
end.

bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find tt-cli where recid(tt-cli) = recatu1 no-lock.
    if not available tt-cli
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:

        run frame-a.
        disp vtotal with frame f-tot.
        
    end.

    recatu1 = recid(tt-cli).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tt-cli
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
            find tt-cli where recid(tt-cli) = recatu1 no-lock.

            status default "".
            /*    if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(tt-cli.clicod)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(tt-cli.clicod)
                                        else "".*/
            run color-message.
            choose field tt-cli.clicod help ""
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
                    if not avail tt-cli
                    then leave.
                    recatu1 = recid(tt-cli).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-cli
                    then leave.
                    recatu1 = recid(tt-cli).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-cli
                then next.
                color display white/red tt-cli.clicod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-cli
                then next.
                color display white/red tt-cli.clicod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form tt-cli
                 with frame f-tt-cli color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Gerar Acao "
                then do with frame f-tt-cli on error undo.
                    run p-acao.
                    leave.
                end.
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Exclusao " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-tt-cli.
                    disp tt-cli.
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-tt-cli on error undo.
                    find tt-cli where
                            recid(tt-cli) = recatu1 
                        exclusive.
                    update tt-cli.
                end.
                if esqcom1[esqpos1] = " Exclusao "
                then do with frame f-exclui  row 5 1 column centered
                        on error undo.
                    message "Confirma Exclusao de" tt-cli.clicod
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next tt-cli where true no-error.
                    if not available tt-cli
                    then do:
                        find tt-cli where recid(tt-cli) = recatu1.
                        find prev tt-cli where true no-error.
                    end.
                    recatu2 = if available tt-cli
                              then recid(tt-cli)
                              else ?.
                    find tt-cli where recid(tt-cli) = recatu1
                            exclusive.
                    delete tt-cli.
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
                    then run ltt-cli.p (input 0).
                    else run ltt-cli.p (input tt-cli.clicod).
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
        recatu1 = recid(tt-cli).
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
display tt-cli 
        with frame frame-a 11 down centered color white/red row 5.
end procedure.
procedure color-message.
color display message
        tt-cli.clicod
        with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        tt-cli.clicod
        with frame frame-a.
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first tt-cli where true
                                                no-lock no-error.
    else  
        find last tt-cli  where true
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next tt-cli  where true
                                                no-lock no-error.
    else  
        find prev tt-cli   where true
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev tt-cli where true  
                                        no-lock no-error.
    else   
        find next tt-cli where true 
                                        no-lock no-error.
        
end procedure.
         


procedure p-acao:
    def var vnumacao as int.
    def var vdescricao as char.
    def var vdata1 as date format "99/99/9999".
    def var vdata2 as date format "99/99/9999".
    def var vvalor like acao.valor.
    def var vconfirma  as logi format "Sim/Nao".
    def var lMostra    as logi init no.
    def var iMostra    as inte init 0.
    def var cMostra    as char init "".
    
    hide message no-pause.
    view frame frame-a. pause 0.

    do on error undo:
        
         update skip(1)
                space(2) vdescricao label "Tipo de Acao" 
                         format "x(50)" space(2)
                skip
                space(2) vdata1     label "Data Inicio."
                vdata2     label "Final"
                skip
                space(2) vvalor     label "Valor......."
                skip(1)
                with frame f-acao centered overlay
                            row 10 side-labels
                            title " Acao ".
         vconfirma = no.
         message 
         "Excluir participantes de outras acoes do mesmo periodo?  "
         update vconfirma.

    end.

    sresp = yes.
    message "Gerar Acao para estes clientes ?" update sresp.
    if sresp
    then do:
        
        
        hide message no-pause.
        message "Aguarde ... Gerando Acao ...".
        for each tt-acao:
           delete tt-acao.
        end.
        for each tt-acao-cli:
            delete tt-acao-cli.
        end.    
        
        find last acao no-lock no-error.
        if not avail acao
        then vnumacao = 1.
        else vnumacao = acao.acaocod + 1.
        
        create tt-acao.
        assign tt-acao.acaocod   = vnumacao
               tt-acao.descricao = caps(vdescricao)
               tt-acao.dtini     = vdata1
               tt-acao.dtfin     = vdata2
               tt-acao.valor     = vvalor.
        
        for each tt-cli no-lock:  
            
            find tt-acao-cli where tt-acao-cli.acaocod = tt-acao.acaocod
                               and tt-acao-cli.clicod  = tt-cli.clicod 
                               use-index iacao-cli exclusive-lock no-error.
            if not avail tt-acao-cli 
            then do: 
                create tt-acao-cli. 
                assign tt-acao-cli.acaocod = tt-acao.acaocod 
                       tt-acao-cli.clicod  = tt-cli.clicod.
            end.
        end.
    end.
    
    for each tt-acao no-lock:
          
        create acao.
        assign  acao.acaocod        = tt-acao.acaocod
                acao.descricao      = tt-acao.descricao
                acao.DtIni          = tt-acao.DtIni
                acao.DtFin          = tt-acao.DtFin
                acao.Valor          = tt-acao.Valor.
        
    end.

/* NAO GERAR ACAO QUANDO PARTICIPAR NO PERIODO */

for each tt-clinacao exclusive-lock:
    delete tt-clinacao.
end.

if vconfirma 
then do:

        for each acao where
                 acao.dtini   >= vdata1           and
                 acao.dtini   <= vdata2           or
                 acao.dtfin   >= vdata1           and
                 acao.dtfin   <= vdata2           no-lock:
            for each acao-cli where
                     acao-cli.acaocod = acao.acaocod no-lock:
                find first tt-acao-cli where 
                           tt-acao-cli.clicod  = acao-cli.clicod
                           exclusive-lock no-error.
                if avail tt-acao-cli
                then do:
                        find first tt-clinacao where
                                   tt-clinacao.acaocod = acao.acaocod and
                                   tt-clinacao.clicod  = acao-cli.clicod
                                   exclusive-lock no-error.
                        if not avail tt-clinacao
                        then do:           
                                create tt-clinacao.
                                assign tt-clinacao.acaocod = acao.acaocod
                                       tt-clinacao.clicod  = acao-cli.clicod.
                        end.
                        delete tt-acao-cli.
                end.     
            end.    
        end.

end.
/* ------------------------------------------- */

    for each tt-acao-cli no-lock:
        
        find first acao-cli where
                   acao-cli.acaocod = tt-acao-cli.acaocod  and
                   acao-cli.clicod  = tt-acao-cli.clicod 
                   exclusive-lock no-error.
        if not avail acao-cli
        then do: 
            create acao-cli. 
            assign acao-cli.acaocod    = tt-acao-cli.acaocod 
                   acao-cli.clicod     = tt-acao-cli.clicod 
                   acao-cli.aux        = tt-acao-cli.aux 
                   acao-cli.recencia   = tt-acao-cli.recencia
                   acao-cli.frequencia = tt-acao-cli.frequencia
                   acao-cli.Valor      = tt-acao-cli.valor.
        end.
       
    end.      

    find first tt-acao no-lock no-error.
    if avail tt-acao
    then do:
            hide message no-pause.
            message "Acao gerada com sucesso! Numero da acao:" tt-acao.acaocod.
            pause 6 no-message.
            hide message no-pause.
    end.
    else do:
            hide message no-pause.
            message "Acao nao foi gerada, favor verificar!".
            pause 6 no-message.
            hide message no-pause.
    end.

    find first tt-clinacao no-lock no-error.
    if avail tt-clinacao
    then do:
           for each tt-clinacao no-lock:
                assign iMostra = iMostra + 1.
           end.
    
            message "Deseja ver participantes em outras acoes?" skip
                    "Quantidade total = " string(iMostra,">>>>9")
                    view-as alert-box buttons yes-no
                            title "ATENCAO" update lMostra.
            if lMostra = yes
            then do:
                    for each tt-clinacao no-lock:
                        find first clien where
                                   clien.clicod = tt-clinacao.clicod
                                   no-lock no-error.
                        disp tt-clinacao.acaocod column-label "Acao"
                             tt-clinacao.clicod  column-label "Codigo"
                             when avail clien clien.clinom
                                        column-label "Nome"
                             with frame f-ver width 80 down
                                  title "MOSTRA PARTICIPANTES EM ACOES" 
                                  at col 01 row 10 overlay.
                    end.            
            end.                
    end.


end procedure.

