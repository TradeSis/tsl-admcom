{admcab.i}

def input parameter p-acao as int.

def new shared var vtitulo as char.

def new shared temp-table tt-dados
    field parametro as char
    field valor     as dec
    field valoralt  as dec
    field percent   as dec
    field vcalclim  as dec
    field operacao  as char format "x(1)" column-label ""
    field numseq    as int
    index dado1 numseq.

def var varquivo       as char.
def var varquivo-label as char.
def buffer bclien for clien.
def shared var vetbcod like estab.etbcod.
def var vlimite  as dec.
def var vcalclim as dec.
def var vpardias as int.

def temp-table tt-cons
    field clicod like clien.clicod
    field clinom like clien.clinom format "x(20)"
    field recencia as date format "99/99/99"
    field frequencia as int label "Freq" format ">>>9"
    field valor as dec format ">,>>,>>9.99"
    field etbcod like estab.etbcod 
    field vendedor like func.funnom
    field limite-d as dec format "->>,>>9.99"
    field limite-disp as dec format "->>,>>9.99"
    field descri   like acao.descri
    field aniver as char
    index iclicod as primary unique clicod
    index irec    recencia   descending
    index ifre    frequencia descending
    index ival    valor      descending
    index iclinom clinom
    index icod    clicod.

for each tt-cons. delete tt-cons. end.


message "Aguarde, gerando consulta ...".

for each acao-cli where acao-cli.acaocod = p-acao no-lock:
    find clien where clien.clicod = acao-cli.clicod no-lock no-error.
    if avail clien
    then do:
        find first acao where acao.acaocod = p-acao no-lock.
        find rfvcli where rfvcli.setor = 0 and
                          rfvcli.clicod = clien.clicod 
                          no-lock no-error. 
        find first campanha where
                   campanha.acaocod = acao-cli.acaocod and
                   campanha.crmcod  = 0 and
                       campanha.clicod  = acao-cli.clicod
                   no-lock no-error.
        find tt-cons where tt-cons.clicod = acao-cli.clicod no-error.
        if not avail tt-cons
        then do:
            create tt-cons.
            assign tt-cons.clicod     = acao-cli.clicod
                   tt-cons.clinom     = clien.clinom
                   tt-cons.recencia   = acao-cli.recencia
                   tt-cons.frequencia = acao-cli.frequencia
                   tt-cons.valor      = acao-cli.valor
                   tt-cons.descri     = acao.descri
                   tt-cons.aniver     = string(day(clien.dtnasc)) + "/" + string(month(clien.dtnasc)).
                   /*tt-cons.rfv        = acao-cli.rfv*/.
                   
            if avail rfvcli
            then tt-cons.etbcod = rfvcli.etbcod.
            
            if avail campanha and
                campanha.etbcod <> ? and
                campanha.etbcod > 0
            then tt-cons.etbcod = campanha.etbcod.   
             
            find last plani where plani.movtdc = 5 and
                                  plani.desti = clien.clicod
                                  no-lock no-error.
            if avail plani
            then do:
                find func where func.etbcod = plani.etbcod and
                                func.funcod = plani.vencod
                                no-lock no-error.
                if avail func
                then tt-cons.vendedor = func.funnom.                
            end.
            /* Antonio */
            if not connected("dragao")
            then  connect dragao -H "erp.lebes.com.br" -S sdragao -N tcp -ld dragao
                                            no-error.
            run calccredscore.p(input "Tela",
                              input recid(clien),
                              output vcalclim,
                              output vpardias,
                              output vlimite).
            assign tt-cons.limite-d    = vcalclim
                   tt-cons.limite-disp = vlimite.

            /*
            find ncrm where ncrm.clicod = clien.clicod no-lock no-error.
            if avail ncrm
            then
            assign tt-cons.limite-d    = ncrm.limcrd
                   tt-cons.limite-disp = ncrm.limite
                   .
            */
        end.
    end.        
end.
/* antonio */
if connected("dragao") then disconnect dragao.


/*if sfuncod = 101 then for each tt-cons : disp tt-cons. end.*/



hide message no-pause.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.

def var vordem as char extent 5 format "x(22)"
                init["1. Recencia   ",
                     "2. Frequencia ",
                     "3. Valor      ",
                     "4. Alfabetica ",
                     "5. Codigo     "].

def var vordenar as integer.

def var esqcom1         as char format "x(14)" extent 5
    initial [" Ordenacao "," Listagem "," Excel ", " Cadastro "," Notas "].

def var esqcom2         as char format "x(14)" extent 5
            initial [" Inclui Partic. "," Exclui Partic. ","","",""].


def buffer btt-cons       for tt-cons.
/*def var vtt-cons         like tt-cons.rfv.*/
def buffer bacao-cli for acao-cli.


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

procedure inc-participante:
    def var vclicod like clien.clicod.
    do on error undo:
        update vclicod label "Codigo Cliente" format ">>>>>>>>>9"
            with frame f-inclui 1 down side-label row 7 centered
            overlay.
        find clien where clien.clicod = vclicod no-lock no-error.
        if not avail clien then next.
        disp clien.clinom no-label with frame f-inclui title " Incluir ".
        find first acao-cli where acao-cli.acaocod = p-acao and
                                  acao-cli.clicod  = clien.clicod
                                  no-lock no-error.
        if not avail acao-cli
        then do:
            create acao-cli.
            assign
                acao-cli.acaocod = p-acao
                acao-cli.clicod  = clien.clicod
                .
            find rfvcli where rfvcli.setor = 0 and
                          rfvcli.clicod = clien.clicod 
                          no-lock no-error. 
            find tt-cons where tt-cons.clicod = acao-cli.clicod no-error.
            if not avail tt-cons
            then do:
                create tt-cons.
                assign tt-cons.clicod = acao-cli.clicod
                   tt-cons.clinom     = clien.clinom
                   tt-cons.recencia   = acao-cli.recencia
                   tt-cons.frequencia = acao-cli.frequencia
                   tt-cons.valor      = acao-cli.valor
                   tt-cons.aniver     = string(day(clien.dtnasc)) + "/" + string(month(clien.dtnasc)).
                   /*tt-cons.rfv      = acao-cli.rfv*/.

                   /* Antonio */
                  if not connected("dragao")
                  then  
                  connect dragao -H "erp.lebes.com.br" -S sdragao -N tcp -ld dragao
                                            no-error.
                  run calccredscore.p(input "Tela",
                              input recid(clien),
                              output vcalclim,
                              output vpardias,
                              output vlimite).
                  assign tt-cons.limite-d    = vcalclim
                         tt-cons.limite-disp = vlimite.
                  if connected("dragao") then disconnect dragao.

                  /*
                  find ncrm where ncrm.clicod = clien.clicod no-lock no-error.
                  if avail ncrm
                  then
                  assign tt-cons.limite-d    = ncrm.limcrd
                         tt-cons.limite-disp = ncrm.limite
                         .
                  */
                   
                if avail rfvcli
                then tt-cons.etbcod = rfvcli.etbcod.
                
                find last plani where plani.movtdc = 5 and
                                  plani.desti = clien.clicod
                                  no-lock no-error.
                if avail plani
                then do:
                    find func where func.etbcod = plani.etbcod and
                                func.funcod = plani.vencod
                                no-lock no-error.
                    if avail func
                    then tt-cons.vendedor = func.funnom.                
                end.                       
            end.
        end. 
    end.  
    hide frame f-inclui.  
end procedure.

bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    
    if vordenar = 0 
    then vordenar = 3.
    
    if recatu1 = ?
    then
        run leitura (input "pri").
    else do:
        if vordenar = 1
        then find tt-cons use-index irec
                              where recid(tt-cons) = recatu1 no-error. 
        else 
        if vordenar = 2 
        then find tt-cons use-index ifre 
                              where recid(tt-cons) = recatu1  no-error. 
        else 
        if vordenar = 3
        then find tt-cons use-index ival
                              where recid(tt-cons) = recatu1  no-error.
        else                                    
        if vordenar = 4
        then find tt-cons use-index iclinom
                              where recid(tt-cons) = recatu1  no-error.
        else
        if vordenar = 5
        then find tt-cons use-index icod
                              where recid(tt-cons) = recatu1  no-error.
        
    end.
        
    if not available tt-cons
    then esqvazio = yes.
    else esqvazio = no.
    
    clear frame frame-a all no-pause.
    
    if not esqvazio
    then do:
        run frame-a.
    end.
    else do:
        sresp = no.
        message "Nenhum registro encontrado. Deseja incluir?" update sresp.
        if not sresp then leave bl-princ.
        run inc-participante.
        recatu1 = recid(tt-cons).
        next.
    end.    
    recatu1 = recid(tt-cons).
    
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    
    if not esqvazio
    then repeat:
        run leitura (input "seg").
    
        if not available tt-cons
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
             if vordenar = 1
             then find tt-cons use-index irec
                                   where recid(tt-cons) = recatu1
                                    no-error.
             else
             if vordenar = 2
             then find tt-cons use-index ifre
                                   where recid(tt-cons) = recatu1
                                    no-error.
             else
             if vordenar = 3
             then find tt-cons use-index ival
                                   where recid(tt-cons) = recatu1
                                    no-error.
             else                                    
             if vordenar = 4
             then find tt-cons use-index iclinom
                                   where recid(tt-cons) = recatu1
                                    no-error.
             else
             if vordenar = 5
             then find tt-cons use-index icod
                                   where recid(tt-cons) = recatu1
                                    no-error.


            run color-message.
            
            choose field tt-cons.clicod 
                         tt-cons.clinom
                         tt-cons.recencia
                         tt-cons.frequencia
                         tt-cons.valor
                         tt-cons.limite-d
                         tt-cons.aniver
                         help ""
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
                    if not avail tt-cons
                    then leave.
                    recatu1 = recid(tt-cons).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-cons
                    then leave.
                    recatu1 = recid(tt-cons).
                end.
                leave.
            end.
    
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-cons
                then next.
                color display white/red 
                              tt-cons.clicod
                              tt-cons.clinom
                              tt-cons.recencia
                              tt-cons.frequencia
                              tt-cons.valor
                              tt-cons.limite-d
                              tt-cons.aniver
                              with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-cons
                then next.
                color display white/red tt-cons.clicod
                                        tt-cons.clinom
                                        tt-cons.recencia
                                        tt-cons.frequencia
                                        tt-cons.valor
                                        tt-cons.limite-d
                                        tt-cons.aniver
                                        with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do:
            form tt-cons.clicod 
                 tt-cons.clinom 
                 tt-cons.recencia 
                 tt-cons.frequencia
                 tt-cons.valor
                 tt-cons.limite-d 
                 tt-cons.aniver
                 with frame f-tt-cons color black/cyan
                      centered side-label row 5 .

            if esqcom2[esqpos2] <> " Exclui Partic. " then
            hide frame frame-a no-pause.
            
            if esqregua
            then do:
            
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Ordenacao "
                then do with frame f-ordem on error undo.

                    view frame frame-a. pause 0.
            
                    disp  vordem[1] skip   
                          vordem[2] skip 
                          vordem[3] skip
                          vordem[4] skip
                          vordem[5]
                          with frame f-esc title "Ordenar por" row 7
                             centered color with/black no-label overlay. 
    
                    choose field vordem auto-return with frame f-esc.
                    vordenar = frame-index.

                    clear frame f-esc no-pause.
                    hide frame f-esc no-pause.
                    
                    recatu1 = ?.
                    next bl-princ.
                 
                end.
                
                if esqcom1[esqpos1] = " Listagem "
                then do with frame f-list on error undo.
                
                    run emite-listagem.
                    leave.
                
                end.
                
                if esqcom1[esqpos1] = " Excel "
                then do with frame f-excel on error undo.
                
                    run p-excel.
                    leave.
                
                end.
                
                if esqcom1[esqpos1] = " Cadastro "
                then do:
                    
                    find bclien where bclien.clicod = tt-cons.clicod no-lock.
                    if not avail bclien then leave.

                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    disp bclien.clicod label "Cliente"
                         bclien.clinom no-label
                         with frame f-cliii centered side-labels.
                    run clidis.p (input recid(bclien)).
                    hide frame f-cliii no-pause.
                    view frame f-com1.
                    view frame f-com2.
                        
                    leave.
                end.
                
                
                if esqcom1[esqpos1] = " Notas "
                then do:
                    
                    find bclien where bclien.clicod = tt-cons.clicod no-lock.
                    if not avail bclien then leave.

                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    assign vtitulo = ""
                           vtitulo = string(" " + /*
                                            string(bclien.clicod) + " - " +
                                                  */  
                                            bclien.clinom + " ").
                           
                    run crm20-consnf.p (input bclien.clicod).

                    view frame f-com1.
                    view frame f-com2.
                        
                    leave.
                end.
                
            end.
            else do:
            
                if esqcom2[esqpos2] = " Inclui Partic. "
                then do:
                    run inc-participante.
                    recatu1 = recid(tt-cons).
                    next bl-princ.
                end.
                if esqcom2[esqpos2] = " Exclui Partic. "
                then do:
                    pause 0.
                    def var vclicodi like clien.clicod label "De".
                    def var vclicodf like clien.clicod label "ate".
                    
                    update vclicodi vclicodf
                    with frame fpercli row 12 overlay side-labels centered.
                    
                    message "Confirma Exclusao de Participantes ?"
                            update sresp.
                    if not sresp
                    then undo, leave.
                    /*
                    find next <tabela> where true no-error.
                    if not available <tabela>
                    then do:
                        find <tabela> where recid(<tabela>) = recatu1.
                        find prev <tabela> where true no-error.
                    end.
                    recatu2 = if available <tabela>
                              then recid(<tabela>)
                              else ?.
                    */
                    for each tt-cons where tt-cons.clicod >= vclicodi
                                       and tt-cons.clicod <= vclicodf.
                         
                        find bacao-cli where bacao-cli.acaocod = p-acao
                                         and bacao-cli.clicod = tt-cons.clicod
                                              exclusive-lock no-error.
                        if avail bacao-cli
                        then delete bacao-cli.  /* chamado 22566 */
                                       
                        delete tt-cons.              
                     end.                     
                     hide frame fpercli.   
                     recatu1 = ?.
                     leave.
                end.
            
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
        recatu1 = recid(tt-cons).
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

    display tt-cons.clicod     column-label "Codigo"
            tt-cons.clinom     column-label "Cliente"
            tt-cons.recencia   column-label "Recen"
            tt-cons.frequencia column-label "Freq"
            tt-cons.valor      column-label "Valor"
            tt-cons.limite-d   column-label "Lim.Cred."
            tt-cons.aniver     column-label "Aniver"
            with frame frame-a 11 down centered color white/red row 5
                       title vtitulo.
            
end procedure.

procedure color-message.
    color display message
                  tt-cons.clicod     column-label "Codigo" 
                  tt-cons.clinom     column-label "Cliente" 
                  tt-cons.recencia   column-label "Recen" 
                  tt-cons.frequencia column-label "Freq" 
                  tt-cons.valor      column-label "Valor"
                  tt-cons.limite-d  column-label "Lim.Cred."
                  tt-cons.aniver    column-label "Aniver"
                  with frame frame-a.
end procedure.

procedure color-normal.
    color display normal
                  tt-cons.clicod     column-label "Codigo"
                  tt-cons.clinom     column-label "Cliente"
                  tt-cons.recencia   column-label "Recen"
                  tt-cons.frequencia column-label "Freq"
                  tt-cons.valor      column-label "Valor"
                  tt-cons.limite-d  column-label "Lim.Cred."
                  tt-cons.aniver    column-label "Aniver"
                  with frame frame-a.
end procedure.

procedure leitura.

    def input parameter par-tipo as char.
        
    if par-tipo = "pri"
    then do: 
        if esqascend
        then do:
             if vordenar = 1
             then find first tt-cons use-index irec
                                    where true  no-error.
             else
             if vordenar = 2
             then find first tt-cons use-index ifre
                                    where true  no-error.
             else
             if vordenar = 3
             then find first tt-cons use-index ival
                                    where true  no-error.
             else                                    
             if vordenar = 4
             then find first tt-cons use-index iclinom
                                    where true  no-error.
             else
             if vordenar = 5
             then find first tt-cons use-index icod
                                    where true  no-error.
        end.     
        else do: 
             if vordenar = 1
             then find last tt-cons use-index irec
                                   where true  no-error.
             else
             if vordenar = 2
             then find last tt-cons use-index ifre
                                   where true  no-error.
             else
             if vordenar = 3
             then find last tt-cons use-index ival
                                   where true  no-error.
             else                                    
             if vordenar = 4
             then find last tt-cons use-index iclinom
                                   where true  no-error.
             else
             if vordenar = 5
             then find last tt-cons use-index icod
                                   where true  no-error.
                                   
        end.
    end.                                         
                                             
    if par-tipo = "seg" or par-tipo = "down" 
    then do:
        if esqascend  
        then do:
             if vordenar = 1
             then find next tt-cons use-index irec 
                                   where true  no-error.
             else
             if vordenar = 2
             then find next tt-cons use-index ifre
                                   where true  no-error.
             else
             if vordenar = 3
             then find next tt-cons use-index ival
                                   where true  no-error.
             else                                    
             if vordenar = 4
             then find next tt-cons use-index iclinom
                                   where true  no-error.
             else
             if vordenar = 5
             then find next tt-cons use-index icod
                                   where true  no-error.
                                   
        end.            
        else do: 
             if vordenar = 1
             then find prev tt-cons use-index irec
                                   where true  no-error.
             else
             if vordenar = 2
             then find prev tt-cons use-index ifre
                                   where true  no-error.
             else
             if vordenar = 3
             then find prev tt-cons use-index ival
                                   where true  no-error.
             else                                    
             if vordenar = 4
             then find prev tt-cons use-index iclinom
                                   where true  no-error.
             else
             if vordenar = 5
             then find prev tt-cons use-index icod
                                   where true  no-error.
  
        end.            
    end.
             
             
    if par-tipo = "up" 
    then do:
        if esqascend   
        then do:  
             if vordenar = 1
             then find prev tt-cons use-index irec
                                   where true  no-error.
             else
             if vordenar = 2
             then find prev tt-cons use-index ifre
                                   where true  no-error.
             else
             if vordenar = 3
             then find prev tt-cons use-index ival
                                   where true  no-error.
             else                                    
             if vordenar = 4
             then find prev tt-cons use-index iclinom
                                   where true  no-error.
             else
             if vordenar = 5
             then find prev tt-cons use-index icod
                                   where true  no-error.
        
        end.
        else do:
             if vordenar = 1
             then find next tt-cons use-index irec
                                   where true  no-error.
             else
             if vordenar = 2
             then find next tt-cons use-index ifre
                                   where true  no-error.
             else
             if vordenar = 3
             then find next tt-cons use-index ival
                                   where true  no-error.
             else                                    
             if vordenar = 4
             then find next tt-cons use-index iclinom
                                   where true  no-error.
             else
             if vordenar = 5
             then find next tt-cons use-index icod
                                   where true  no-error.
                                   
        end.
    end.        
        
end procedure.



procedure emite-listagem:

    if opsys = "UNIX"
    then assign
            varquivo = "/admcom/relat/crm20-con" + string(time).
    else assign
            varquivo = "l:\relat\crm20-con" + string(time).

    {mdadmcab.i 
        &Saida     = "value(varquivo)" 
        &Page-Size = "0" 
        &Cond-Var  = "180"
        &Page-Line = "0"
        &Nom-Rel   = ""crm20-con""  
        &Nom-Sis   = """CRM"""  
        &Tit-Rel   = """RECENCIA, FREQUENCIA e VALOR - LISTAGEM DE CLIENTES """
        &Width     = "180"
        &Form      = "frame f-cabcab"}

        for each tt-cons break  by tt-cons.vendedor
                                by tt-cons.valor descending:
            find clien where
                 clien.clicod = tt-cons.clicod no-lock no-error.
                 
            display
                  tt-cons.clicod     column-label "Codigo"
                  tt-cons.clinom     column-label "Cliente"
                  clien.fone         column-label "Telefone" when avail clien
                  clien.fax          column-label "Celular" when avail clien
                  tt-cons.recencia   column-label "Recen"
                  tt-cons.frequencia column-label "Freq"
                  (total)
                  tt-cons.valor      column-label "Valor"
                  (total)
                  tt-cons.etbcod     column-label "Fil" format ">>>9"
                  tt-cons.vendedor   column-label "Vendedor" format "x(20)"
                  tt-cons.descri     column-label "Acao" format "x(30)"
                  tt-cons.aniver     column-label  "Aniver"
                  with frame f-imp-con width 175 down.

            down with frame f-imp-con.
        
        end.    


    output close.
    
    if opsys = "UNIX"
    then do:
        run visurel.p (input varquivo,
                       input "").
    end.
    else do:
        {mrod.i}.
    end.        
end.

procedure p-excel:

    def var vtime as character.

    assign vtime = string(time).

    if opsys = "UNIX"
    then assign
            varquivo = "/admcom/relat/crm20-con-"
                            + vtime + ".xls"
            varquivo-label = "l:~\relat~\crm20-con-"
                                        + vtime + ".xls".
    else assign
            varquivo = "l:~\relat~\crm20-con-"
                            + vtime + ".xls"
            varquivo-label = "l:~\relat~\crm20-con-"
                            + vtime + ".xls".

    /*{mdadmcab.i 
        &Saida     = "value(varquivo)" 
        &Page-Size = "0" 
        &Cond-Var  = "170"
        &Page-Line = "0"
        &Nom-Rel   = ""crm20-con""  
        &Nom-Sis   = """CRM"""  
        &Tit-Rel   = """RECENCIA, FREQUENCIA e VALOR - LISTAGEM DE CLIENTES """
        &Width     = "170"
        &Form      = "frame f-cabcab"}
    */
    output to value(varquivo) page-size 0.
           /*
        put unformatted
            "Codigo;Cliente;Telefone;Celular;Recencia;Frequencia;Valor" skip.
             */
             
        for each tt-cons break  by tt-cons.vendedor
                                by tt-cons.valor descending:
            find clien where
                 clien.clicod = tt-cons.clicod no-lock no-error.

            
            display
                  tt-cons.clicod     column-label "Codigo"
                  ";"
                  tt-cons.clinom     column-label "Cliente"
                  ";"
                  clien.fone         column-label "Telefone" when avail clien
                  ";"
                  clien.fax          column-label "Celular" when avail clien
                  ";"
                  tt-cons.recencia   column-label "Recencia"
                  ";"
                  tt-cons.frequencia column-label "Frequencia"
                  (total)
                  ";"
                  tt-cons.valor      column-label "Valor"
                  (total)
                  ";" 
                  tt-cons.etbcod     column-label "Fil" format ">>>9"
                  ";"
                  tt-cons.vendedor   column-label "Vendedor" format "x(20)"
                  ";"
                  tt-cons.descri     column-label "Acao"     format "x(30)" 
                  ";"
                  tt-cons.aniver     column-label "Aniver"
                  ";"
                  today              column-label "Geracao"
                  ";"
                  tt-cons.limite-d   column-label "Lim. Credito"
                  ";"
                  tt-cons.limite-disp column-label "Lim. Disponivel"
                  with frame f-imp-con width 235 down.
            down with frame f-imp-con.
            
            
            /*
            put unformatted
                  tt-cons.clicod
                  ";"
                  tt-cons.clinom
                  ";"
                  clien.fone
                  ";"
                  clien.fax
                  ";"
                  tt-cons.recencia
                  ";"
                  tt-cons.frequencia
                  ";"
                  tt-cons.valor skip.
            */
        
        end.    


    output close.
    
    if opsys = "UNIX"
    then do:
        message color red/with
        "Arquivo para ECXEL gerado " varquivo-label
        view-as alert-box.

        /*
        run visurel.p(input varquivo, input "").
        */
    end.
    else do:
        os-command silent start value(varquivo).
    end.        
end.



