/*
*
*    tbacao.p    -    Esqueleto de Programacao    com esqvazio


            substituir    tbacao
                          acao
*
*/

def var vconta-acoes    as integer.
def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var vcha-classe     as char.
def var vcha-acao-aux   as char extent 12.

def var vint-cla-cod   as integer no-undo.

def temp-table tt-tbacao like tbacao
    field nivel         as char
    field dt-realiza    as char.

/*
def var esqcom1         as char format "x(12)" extent 5
    initial [" Inclusao "," Alteracao "," Exclusao "," Consulta "," Listagem "].
*/

def var esqcom1         as char format "x(15)" extent 5
   initial ["    ","    Marcar    ","   Visualizar  "
                ,"     ","   "].

def var esqcom2         as char format "x(12)" extent 5
         initial [" "," ","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial [" Inclusao  de tbacao ",
             " Alteracao da tbacao ",
             " Exclusao  da tbacao ",
             " Consulta  da tbacao ",
             " Listagem  Geral de tbacao "].
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].

{admcab.i}

def input parameter ip-row-id    as rowid.

find last tbmeta where rowid(tbmeta) = ip-row-id no-lock no-error.

for each tbacao where tbacao.cla-cod = tbmeta.cla-cod no-lock.

    release tbacao-fil.
    find first tbacao-fil where tbacao-fil.acaocod = tbacao.acaocod
                            and tbacao-fil.etbcod = tbmeta.etbcod
                            and tbacao-fil.cla-cod = tbacao.cla-cod
                            and tbacao-fil.ano = tbmeta.ano
                            and tbacao-fil.mes = tbmeta.mes
                                        no-lock no-error.
                        
    create tt-tbacao.
    buffer-copy tbacao to tt-tbacao.
    if avail tbacao-fil
    then do:
        assign tt-tbacao.dt-realiza = string(tbacao-fil.datsit,"99/99/9999")
               tt-tbacao.nivel = "Filial"
               tt-tbacao.situacao = tbacao-fil.situacao
               tt-tbacao.datsit = tbacao-fil.datsit.
        
    end.
    else do:
    
        assign tt-tbacao.situacao = "PENDENTE"
               tt-tbacao.nivel = "Lebes" .
    
    end.
    
end.


def buffer btt-tbacao       for tt-tbacao.

def buffer ctt-tbacao       for tt-tbacao.

def var vtbacao         like tbacao.acaocod.


form tt-tbacao.cla-cod format ">>>>>>>>9"  label "Cod. Setor"   at 06        skip
     tt-tbacao.acaocod      label "Cod. Acao"    at 07       
     vcha-acao-aux[1]    label "Desc da Acao" at 4 format "x(58)"
     vcha-acao-aux[2]    no-label at 1 format "x(78)"
     vcha-acao-aux[3]    no-label at 1 format "x(78)"
     vcha-acao-aux[4]    no-label at 1 format "x(78)"
     vcha-acao-aux[5]    no-label at 1 format "x(78)"
     vcha-acao-aux[6]    no-label at 1 format "x(78)"
     vcha-acao-aux[7]    no-label at 1 format "x(78)"
     vcha-acao-aux[8]    no-label at 1 format "x(78)"
     vcha-acao-aux[9]    no-label at 1 format "x(78)"
     vcha-acao-aux[10]    no-label at 1 format "x(78)"
     vcha-acao-aux[11]    no-label at 1 format "x(78)"
     vcha-acao-aux[12]    no-label at 1 format "x(78)"
        with frame f-tbacao width 80 centered row 5 1 down
                             OVERLAY side-labels color black/cyan.


form 
     tt-tbacao.cla-cod    format ">>>>>>>>9"   label "Cod. Setor"   at 06        skip
     tt-tbacao.acaocod      label "Cod. Acao"    at 07       skip
     vcha-acao-aux[1]    label "Desc da Acao" at 4 format "x(58)"
     vcha-acao-aux[2]    no-label at 1 format "x(78)"
     vcha-acao-aux[3]    no-label at 1 format "x(78)"
     vcha-acao-aux[4]    no-label at 1 format "x(78)"
     vcha-acao-aux[5]    no-label at 1 format "x(78)"
     vcha-acao-aux[6]    no-label at 1 format "x(78)"
     vcha-acao-aux[7]    no-label at 1 format "x(78)"
     vcha-acao-aux[8]    no-label at 1 format "x(78)"
     vcha-acao-aux[9]    no-label at 1 format "x(78)"
     vcha-acao-aux[10]    no-label at 1 format "x(78)"
     vcha-acao-aux[11]    no-label at 1 format "x(78)"
     vcha-acao-aux[12]    no-label at 1 format "x(78)"
        with frame f-tbacao-inc width 80 centered row 5 1 down
                             OVERLAY side-labels color black/cyan.


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

bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find tt-tbacao where recid(tt-tbacao) = recatu1 no-lock.
    if not available tt-tbacao
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(tt-tbacao).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tt-tbacao
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
            find tt-tbacao where recid(tt-tbacao) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(tt-tbacao.acaodes)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(tt-tbacao.acaodes)
                                        else "".
            run color-message.
            choose field tt-tbacao.cla-cod help ""
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
                    if not avail tt-tbacao
                    then leave.
                    recatu1 = recid(tt-tbacao).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-tbacao
                    then leave.
                    recatu1 = recid(tt-tbacao).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-tbacao
                then next.
                color display white/red tt-tbacao.cla-cod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-tbacao
                then next.
                color display white/red tt-tbacao.cla-cod with frame frame-a.
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
                        
                pause 0.        

                if esqcom1[esqpos1] = "   Inclusao    " or esqvazio
                then do with frame f-tbacao-inc on error undo.

                    clear frame f-tbacao-inc.
                    
                    message "Não existem ações cadastradas para este setor!"
                            view-as alert-box.
                    
                    /*
                    release tt-tbacao.

                    create tt-tbacao.
                    
                    update tt-tbacao.cla-cod.

                    assign vconta-acoes = 0.
                    
                    for each ctt-tbacao where ctt-tbacao.cla-cod = tt-tbacao.cla-cod                                                  no-lock:
                    
                        assign vconta-acoes = vconta-acoes + 1.
                    
                    end.
                    
                    if vconta-acoes >= 5
                    then do: 
                        message "O setor " tt-tbacao.cla-cod
                                " já atingiu o limite de 5 ações"                                              "cadastradas." view-as alert-box.
                    
                        undo,retry.
                    
                    end.
                    
                    update tt-tbacao.acaocod.
                    update text(vcha-acao-aux) go-on("TAB").
                                        
                    assign tt-tbacao.acaodes = string(vcha-acao-aux[1],"x(58)")
                                            + string(vcha-acao-aux[2],"x(78)")
                                            + string(vcha-acao-aux[3],"x(78)")
                                            + string(vcha-acao-aux[4],"x(78)")
                                            + string(vcha-acao-aux[5],"x(78)")
                                            + string(vcha-acao-aux[6],"x(78)")
                                            + string(vcha-acao-aux[7],"x(78)")
                                            + string(vcha-acao-aux[8],"x(78)")
                                            + string(vcha-acao-aux[9],"x(78)")
                                            + string(vcha-acao-aux[10],"x(78)")
                                            + string(vcha-acao-aux[11],"x(78)")
                                            + string(vcha-acao-aux[12],"x(78)").

                    assign tt-tbacao.datsit = today
                           tt-tbacao.datcad = today.
                    
                    create tbacao-fil.
                    assign tbacao-fil.acaocod  = tt-tbacao.acaocod
                           tbacao-fil.etbcod   = tbmeta.etbcod
                           tbacao-fil.situacao = tt-tbacao.situacao
                           tbacao-fil.datcad   = tt-tbacao.datcad
                           tbacao-fil.datexp   = tt-tbacao.datcad
                           tbacao-fil.datsit   = tt-tbacao.datsit
                           tbacao-fil.ano      = tbmeta.ano
                           tbacao-fil.mes      = tbmeta.mes
                           tbacao-fil.cla-cod  = tt-tbacao.cla-cod.
                    
                    
                    recatu1 = recid(tt-tbacao).
                    */
                    
                    leave bl-princ.
                end.
                
                if esqcom1[esqpos1] = "   Procura   "
                then do with frame f-procura overlay row 6 2 column centered
                        on endkey undo, retry:
                   prompt-for tt-tbacao.cla-cod format ">>>>>>>>9" label "Setor"
                                    with no-validate.
                   find first tt-tbacao using tt-tbacao.cla-cod.
                   if not avail tt-tbacao
                   then do:
                         message "Setor Invalido".
                         undo.
                    end.
                    recatu1 = recid(tt-tbacao).
                    leave.
                end.     

                if esqcom1[esqpos1] = "   Visualizar  " or
                   esqcom1[esqpos1] = "    Exclusao" or
                   esqcom1[esqpos1] = "   Alteracao    "
                then do with frame f-tbacao.
                     assign vcha-acao-aux[1] = substring(tt-tbacao.acaodes,1,58).
                     assign vcha-acao-aux[2] = substring(tt-tbacao.acaodes,59,78).
                     assign vcha-acao-aux[3] = substring(tt-tbacao.acaodes,137,78).
                     assign vcha-acao-aux[4] = substring(tt-tbacao.acaodes,215,78).
                     assign vcha-acao-aux[5] = substring(tt-tbacao.acaodes,293,78).
                     assign vcha-acao-aux[6] = substring(tt-tbacao.acaodes,371,78).
                     assign vcha-acao-aux[7] = substring(tt-tbacao.acaodes,449,78).
                     assign vcha-acao-aux[8] = substring(tt-tbacao.acaodes,527,78).
                     assign vcha-acao-aux[9] = substring(tt-tbacao.acaodes,605,78).
                    assign vcha-acao-aux[10] = substring(tt-tbacao.acaodes,683,78).
                    assign vcha-acao-aux[11] = substring(tt-tbacao.acaodes,761,78).

                    disp tt-tbacao.cla-cod
                         tt-tbacao.acaocod     
                         vcha-acao-aux.
                end.
                if esqcom1[esqpos1] = "   Alteracao    "
                then do with frame f-tbacao-inc on error undo.
                    hide frame f-tbacao no-pause.
                    find tt-tbacao where
                            recid(tt-tbacao) = recatu1 
                        exclusive.
                    
                    update tt-tbacao.cla-cod
                           tt-tbacao.acaocod
                           text(vcha-acao-aux).
                    
                    assign tt-tbacao.acaodes = string(vcha-acao-aux[1],"x(58)")
                                            + string(vcha-acao-aux[2],"x(78)")
                                            + string(vcha-acao-aux[3],"x(78)")
                                            + string(vcha-acao-aux[4],"x(78)")
                                            + string(vcha-acao-aux[5],"x(78)")
                                            + string(vcha-acao-aux[6],"x(78)")
                                            + string(vcha-acao-aux[7],"x(78)")
                                            + string(vcha-acao-aux[8],"x(78)")
                                            + string(vcha-acao-aux[9],"x(78)")
                                            + string(vcha-acao-aux[10],"x(78)")
                                            + string(vcha-acao-aux[11],"x(78)")
                                           + string(vcha-acao-aux[12],"x(78)").
                                             
                                            
                    assign tt-tbacao.datsit = today.
                                            
                    view frame f-tbacao.

                end.
                
                if esqcom1[esqpos1] = "    Marcar    "
                then do with frame f-tbacao on error undo.
  
                    find tt-tbacao where
                            recid(tt-tbacao) = recatu1
                        exclusive.
    
                    sresp = no.
                    
                    if tt-tbacao.situacao <> "REALIZADA"
                    then do:
                        
                        run mensagem.p (input-output sresp,
                                 input " Deseja marcar a Acao como REALIZADA?",                                   input "",
                                 input " Sim ",
                                 input " Nao ").
                
                        if sresp
                        then do:
                            assign tt-tbacao.datsit = today
                                   tt-tbacao.situacao = "REALIZADA"
                                   tt-tbacao.nivel = "Filial".
 
                            find first tbacao-fil
                                 where tbacao-fil.acaocod = tt-tbacao.acaocod
                                   and tbacao-fil.etbcod = tbmeta.etbcod
                                   and tbacao-fil.cla-cod = tt-tbacao.cla-cod
                                   and tbacao-fil.ano = tbmeta.ano   
                                   and tbacao-fil.mes = tbmeta.mes
                                                exclusive-lock no-error.
                                                
                            if not avail tbacao-fil
                            then create tbacao-fil.
                            assign tbacao-fil.acaocod  = tt-tbacao.acaocod
                                   tbacao-fil.etbcod   = tbmeta.etbcod
                                   tbacao-fil.situacao = tt-tbacao.situacao
                                   tbacao-fil.datcad   = tt-tbacao.datcad
                                   tbacao-fil.datexp   = tt-tbacao.datcad
                                   tbacao-fil.datsit   = tt-tbacao.datsit
                                   tbacao-fil.ano      = tbmeta.ano
                                   tbacao-fil.mes      = tbmeta.mes
                                   tbacao-fil.cla-cod  = tt-tbacao.cla-cod.
                                   
                        end.
                                
                    end.
                    else message "Esta Acao ja foi marcada como REALIZADA."                                         view-as alert-box.
                    
                    
                    
                    
                end.
                
                if esqcom1[esqpos1] = "    Exclusao"
                then do with frame f-exclui  row 5 1 column centered
                        on error undo.
                    message "Confirma Exclusao de" tt-tbacao.acaodes
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next tt-tbacao where true no-error.
                    if not available tt-tbacao
                    then do:
                        find tt-tbacao where recid(tt-tbacao) = recatu1.
                        find prev tt-tbacao where true no-error.
                    end.
                    recatu2 = if available tt-tbacao
                              then recid(tt-tbacao)
                              else ?.
                    find tt-tbacao where recid(tt-tbacao) = recatu1
                            exclusive.
                    delete tt-tbacao.
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
                    then run ltbacao.p (input 0).
                    else run ltbacao.p (input tbacao.acaocod).
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
        recatu1 = recid(tt-tbacao).
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
display tt-tbacao.cla-cod  format ">>>>>>>>9" column-label "Setor"
        tt-tbacao.acaocod  format ">>>9"
        tt-tbacao.acaodes  format "x(35)"
        tt-tbacao.datsit   format "99/99/9999"   column-label "Dat.Alt"
        tt-tbacao.situacao format "x(10)"
        with frame frame-a 11 down centered color white/red row 5 width 80.
end procedure.
procedure color-message.
color display message
        tt-tbacao.cla-cod column-label "Setor"
        tt-tbacao.acaocod
        tt-tbacao.acaodes
        tt-tbacao.datsit
        tt-tbacao.situacao
        with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        tt-tbacao.cla-cod column-label "Setor"
        tt-tbacao.acaocod
        tt-tbacao.acaodes
        tt-tbacao.datsit
        tt-tbacao.situacao
        with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first tt-tbacao where true no-lock no-error.
    else  
        find last tt-tbacao where true no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next tt-tbacao  where true no-lock no-error.
    else  
        find prev tt-tbacao   where true no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev tt-tbacao where true no-lock no-error.
    else   
        find next tt-tbacao where true no-lock no-error.
        
end procedure.
         
