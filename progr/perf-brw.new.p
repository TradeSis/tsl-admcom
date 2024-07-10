def input parameter v-titulo as char format "X(50)".
def var varquivo as char.

def shared temp-table tresu
    field etbcod      like estab.etbcod
    field etbnom      like estab.etbnom
    field platot      like plani.platot
    field qtd         like movim.movqtm
    field perc-val    as dec format "->>9.99"
    field perc-qtd    as dec format "->>9.99".

def buffer b-tresu for tresu.

def var v-totqtd as int.
def var v-totval as dec.

find first tresu where tresu.etbcod = 0 no-error.
if avail tresu
then if tresu.etbcod = 0 
     then assign perc-val     = 100 
                 perc-qtd     = 100
                 tresu.etbnom = "G E R A L"
                 v-totqtd     = tresu.qtd
                 v-totval     = tresu.platot.

for each tresu where tresu.etbcod <> 0:
    find estab where estab.etbcod = tresu.etbcod no-lock no-error.
    if avail estab
    then tresu.etbnom = estab.etbnom.
    else tresu.etbnom = "NAO CADASTRADO".
    
    assign tresu.perc-qtd = tresu.qtd * 100 / v-totqtd
           tresu.perc-val = tresu.platot * 100 / v-totval.
end.


def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.

def var esqcom1         as char format "x(12)" extent 5
    initial [" "," "," "," "," "].

def var esqcom2         as char format "x(12)" extent 5
            initial [" "," ","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial [" ",
             " ",
             " ",
             " ",
             " "].
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].

{admcab.i}

def buffer btresu       for tresu.
def var vtresu         like tresu.etbcod.


form
    esqcom1
    with frame f-com1
                 row 7 no-box no-labels side-labels column 1 centered
                              overlay.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered overlay.
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
        find tresu where recid(tresu) = recatu1 no-lock.
    if not available tresu
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(tresu).
    if esqregua
    then color display /*message*/ normal esqcom1[esqpos1] with frame f-com1.
    else color display /*message*/ normal esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tresu
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
            find tresu where recid(tresu) = recatu1 no-lock.

            /*
            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(tresu.etbnom)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(tresu.etbnom)
                                        else "".
            */
            message  "F4=Retorna   I = Imprimir ".

            
            run color-message.
            
            choose field tresu.etbcod 
                         tresu.etbnom
                         help "F4=Retorna   I = Imprimir "
                         tresu.qtd
                         tresu.perc-qtd
                         tresu.platot
                         tresu.perc-val
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up i I
                      tab PF4 F4 ESC return) color white/black.

            run color-normal.
            /*status default "".       */
        end.
            if keyfunction(lastkey) = "i" or
               keyfunction(lastkey) = "I"
            then do:
                run p-imprime.
            end.
                        
                        
            if keyfunction(lastkey) = "TAB"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    color display 
                    /*message*/ normal esqcom2[esqpos2] with frame f-com2.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    color display /*message*/
                     normal esqcom1[esqpos1] with frame f-com1.
                end.
                esqregua = not esqregua.
            end.
            if keyfunction(lastkey) = "cursor-right"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
                    color display /*messages*/
                                normal esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 5 then 5 else esqpos2 + 1.
                    color display /*messages*/ 
                                normal esqcom2[esqpos2] with frame f-com2.
                end.
                next.
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                    color display /*messages*/
                                normal esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 1 then 1 else esqpos2 - 1.
                    color display /*messages*/
                                normal esqcom2[esqpos2] with frame f-com2.
                end.
                next.
            end.
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail tresu
                    then leave.
                    recatu1 = recid(tresu).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tresu
                    then leave.
                    recatu1 = recid(tresu).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tresu
                then next.
                
                color display white/red
                         tresu.etbcod
                         tresu.etbnom
                         help "F4=Retorna   I = Imprimir "
                         tresu.qtd
                         tresu.perc-qtd
                         tresu.platot
                         tresu.perc-val
                         with frame frame-a.
                         
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tresu
                then next.
                
                color display white/red 
                         tresu.etbcod 
                         tresu.etbnom
                         help "F4=Retorna   I = Imprimir "
                         tresu.qtd
                         tresu.perc-qtd
                         tresu.platot
                         tresu.perc-val
                         with frame frame-a.
                         
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form tresu
                 with frame f-tresu color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-tresu on error undo.
                    create tresu.
                    update tresu.
                    recatu1 = recid(tresu).
                    leave.
                end.
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Exclusao " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-tresu.
                    disp tresu.
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-tresu on error undo.
                    find tresu where
                            recid(tresu) = recatu1 
                        exclusive.
                    update tresu.
                end.
                if esqcom1[esqpos1] = " Exclusao "
                then do with frame f-exclui  row 5 1 column centered
                        on error undo.
                    message "Confirma Exclusao de" tresu.etbnom
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next tresu where true no-error.
                    if not available tresu
                    then do:
                        find tresu where recid(tresu) = recatu1.
                        find prev tresu where true no-error.
                    end.
                    recatu2 = if available tresu
                              then recid(tresu)
                              else ?.
                    find tresu where recid(tresu) = recatu1
                            exclusive.
                    delete tresu.
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
                    then run ltresu.p (input 0).
                    else run ltresu.p (input tresu.etbcod).
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
        recatu1 = recid(tresu).
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
    display tresu.etbcod column-label "Etb"
            help "F4=Retorna   I = Imprimir "
            tresu.etbnom   column-label "Estabelecimento"
            tresu.qtd      column-label "Qtd"
            tresu.perc-qtd column-label "% Qtd"
            tresu.platot   column-label "Valor"
            tresu.perc-val column-label "% Valor"
            with frame frame-a 9 down centered color white/red row 8
                               overlay title v-titulo.
end procedure.

procedure color-message.
    color display message tresu.etbcod     column-label "Etb" 
                          help "F4=Retorna   I = Imprimir "
                          tresu.etbnom     column-label "Estabelecimento"
                          tresu.qtd        column-label "Qtd"
                          tresu.perc-qtd   column-label "% Qtd"
                          tresu.platot     column-label "Valor" 
                          tresu.perc-val   column-label "% Valor"
                          with frame frame-a.
end procedure.

procedure color-normal.
    color display normal tresu.etbcod   column-label "Etb"
                         tresu.etbnom   column-label "Estabelecimento"
                         help "F4=Retorna   I = Imprimir "
                         tresu.qtd      column-label "Qtd"
                         tresu.perc-qtd column-label "% Qtd"
                         tresu.platot   column-label "Valor"
                         tresu.perc-val column-label "% Valor"
                         with frame frame-a.
end procedure.


procedure leitura.
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first tresu where true
                                                no-lock no-error.
    else  
        find last tresu  where true
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next tresu  where true
                                                no-lock no-error.
    else  
        find prev tresu   where true
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev tresu where true  
                                        no-lock no-error.
    else   
        find next tresu where true 
                                        no-lock no-error.
        
end procedure.

hide frame frame-a no-pause.


procedure p-imprime:

    if opsys = "UNIX"
    then varquivo = "/admcom/relat/perf-p." + string(time).
    else varquivo = "l:\relat\perf-p." + string(time).
    
    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "0"
        &Cond-Var  = "115"
        &Page-Line = "0"
        &Nom-Rel   = ""convgen2""
        &Nom-Sis   = """SISTEMA COMERCIAL"""
        &Tit-Rel   = """PERFORMANCE DE VENDAS"""
        &Width     = "115"
        &Form      = "frame f-cabcab"}

        for each b-tresu no-lock:
    
            display b-tresu.etbcod   column-label "Etb"
                    b-tresu.etbnom   column-label "Estabelecimento"
                    b-tresu.qtd      column-label "Qtd"
                    b-tresu.perc-qtd column-label "% Qtd"
                    b-tresu.platot   column-label "Valor"
                    b-tresu.perc-val column-label "% Valor"
                    with frame frame-p down centered.

            down with frame frame-p.
        end.    
    
    output close.
        
    if opsys = "UNIX"
    then do:
        run visurel.p (input varquivo, input "").
    end.
    else do:
        {mrod.i}.
    end.    

end procedure.
