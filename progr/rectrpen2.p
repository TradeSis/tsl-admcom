/*
*   Selecao de Titulos de Pendentes em Filiais X Matriz
*   Antonio
*/
def input parameter           p-clicod  like clien.clicod.
def input parameter           p-contnum like fin.contrato.contnum.

def buffer bcontrato for fin.contrato.
def buffer btitulo   for fin.titulo.

def shared temp-table tt-titulo    like fin.titulo
    field selecionar AS LOGICAL. 
def shared temp-table tt-contrato  like fin.contrato.

/* Cria Pendencias na Loja */
message "Buscando Pendencias de Crediario ...".
pause 2 before-hide.
for each  finloja.titulo where titulo.clifor = p-clicod no-lock:
          
          if p-contnum <> 0 and titulo.titnum <> string(p-contnum)  
          then next.

          if finloja.titulo.titnat = yes then next.
          if finloja.titulo.modcod <> "CRE" then next.
          if finloja.titulo.titsit <> "LIB" and 
             finloja.titulo.titsit <> "PAG" then next.
          
          find finloja.contrato where contrato.contnum = int(titulo.titnum)
                    no-lock no-error.

          find first tt-contrato where 
                    tt-contrato.contnum = int(titulo.titnum) no-error.
          if not avail tt-contrato
          then do:
               find first finloja.contrato where 
                    contrato.contnum = int(finloja.titulo.titnum) no-error.
               if  avail contrato
               then do:
                    create tt-contrato.
                    buffer-copy contrato to tt-contrato. 
               end.          
          end.

          create tt-titulo.
          buffer-copy finloja.titulo to tt-titulo
          assign tt-titulo.selecionar = no.
      
end.

for each finloja.contrato where finloja.contrato.clicod = p-clicod and     finloja.contrato.contnum = (if p-contnum <> 0 then p-contnum else                                     finloja.contrato.contnum) no-lock:

     find first tt-contrato where 
                    tt-contrato.contnum = finloja.contrato.contnum no-error.
     if not avail tt-contrato 
     then do:
        create tt-contrato.
        buffer-copy finloja.contrato to tt-contrato.
     end.
end.

/**/
      
disconnect finloja.


/* Verifica Somente Titulo & Contratos Pendentes */

for each tt-titulo:

    /* Verifica se titulo ja esta na Matriz com a mesma Situacao */
    find first fin.titulo where fin.titulo.empcod = tt-titulo.empcod and
                            fin.titulo.titnat = tt-titulo.titnat and
                            fin.titulo.modcod = tt-titulo.modcod and
                            fin.titulo.titnum = tt-titulo.titnum and
                            fin.titulo.titsit = tt-titulo.titsit and
                            fin.titulo.titpar = tt-titulo.titpar and
                            fin.titulo.etbcod = tt-titulo.etbcod no-lock
     no-error.
        
     if avail fin.titulo 
     then delete tt-titulo.

end.

for each tt-contrato:
    /* Verifica s contrato ja esta na matriz */
    find first fin.contrato where fin.contrato.contnum = tt-contrato.contnum
                            and   fin.contrato.clicod  = tt-contrato.clicod
                            no-lock no-error.
    if avail fin.contrato then delete tt-contrato.

end.    

find first tt-titulo no-error.
find first tt-contrato no-error.
if not avail tt-titulo and not avail tt-contrato
then do:
    message "Sem Pendencias de Crediario a atualizar !!"
    view-as alert-box.
    return.
end.

if avail tt-contrato and not avail tt-titulo
then do:
    message  "Aguarde Atualizando Tabela de Contratos....".
    pause 0.
    for each tt-contrato:
        find first fin.contrato 
            where fin.contrato.contnum = tt-contrato.contnum
            and   fin.contrato.clicod  = tt-contrato.clicod
                            exclusive no-error.
        if not avail fin.contrato
        then do:
            create fin.contrato.
            buffer-copy tt-contrato to fin.contrato.
        end.
    end.    
    return.
end.






else do:

message "Aguarde....".
pause 0.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.


def var esqcom1         as char format "x(18)" extent 3
    initial ["Marca","Marca/Desmarca Tudo","Atualiza Matriz"].

def var esqcom2         as char format "x(12)" extent 3
            initial [" "," ",""].
def var esqhel1         as char format "x(80)" extent 3
    initial [" ",
             "",
             ""].
def var esqhel2         as char format "x(12)" extent 3
   initial ["  ",
            " ",
            " "].

{admcab.i}

def buffer btt-titulo       for tt-titulo.
def var vtt-titulo          like tt-titulo.titnum.

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
        find tt-titulo where recid(tt-titulo) = recatu1 no-lock.
    if not available tt-titulo
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(tt-titulo).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tt-titulo
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
            find tt-titulo where recid(tt-titulo) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(tt-titulo.titnum)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(tt-titulo.titnum)
                                        else "".
            run color-message.
            choose field tt-titulo.titnum help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return). /*color white/black.*/
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
                    esqpos1 = if esqpos1 = 3 then 3 else esqpos1 + 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 3 then 3 else esqpos2 + 1.
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
                    if not avail tt-titulo
                    then leave.
                    recatu1 = recid(tt-titulo).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-titulo
                    then leave.
                    recatu1 = recid(tt-titulo).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-titulo
                then next.
                color display white/red tt-titulo.titnum with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-titulo
                then next.
                color display white/red tt-titulo.titnum with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form tt-titulo.titnum tt-titulo.titpar 
                 tt-titulo.titdtemi tt-titulo.titvlcob
                 with frame tt-titulo color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.
                if esqcom1[esqpos1] = "Marca"
                then do:
                        for each btt-titulo where 
                            btt-titulo.titnum = tt-titulo.titnum
                            exclusive:
                            if btt-titulo.selecionar = no 
                            then assign btt-titulo.selecionar = yes.
                            else assign btt-titulo.selecionar = no.
                        end.
                        recatu1 = recid(tt-titulo).
                        leave.
                end.
                if esqcom1[esqpos1] = "Marca/Desmarca Tudo"
                then do:
                        for each btt-titulo 
                            exclusive:
                            if btt-titulo.selecionar = no 
                            then assign btt-titulo.selecionar = yes.
                            else assign btt-titulo.selecionar = no.
                        end.
                        leave.
                end.
                if esqcom1[esqpos1] = "Atualiza Matriz"
                then do:
                    for each tt-titulo where tt-titulo.selecionar:
                        find first tt-contrato 
                        where tt-contrato.contnum = int(tt-titulo.titnum)
                                    no-error.
                        if avail tt-contrato
                        then do:
                            find first bcontrato 
                                where bcontrato.contnum = tt-contrato.contnum 
                            no-lock no-error.
                            if not avail bcontrato
                            then do:
                                create bcontrato.
                                buffer-copy tt-contrato to bcontrato.
                            end.
                        end.
                        find first btitulo where 
                             btitulo.empcod = tt-titulo.empcod and
                             btitulo.titnat = tt-titulo.titnat and
                             btitulo.modcod = tt-titulo.modcod and
                             btitulo.titnum = tt-titulo.titnum and
                             btitulo.titpar = tt-titulo.titpar and
                             btitulo.etbcod = tt-titulo.etbcod 
                             exclusive no-error.
                         /* Cria Inexistente */
                        if not avail btitulo
                        then do:
                            create btitulo.
                            buffer-copy tt-titulo to btitulo. 
                        end.
                        /* Atualiza os  Pagos nas Lojas e Lib. Matriz */
                        else do:
                            if  tt-titulo.titdtpag <> ? and 
                                tt-titulo.titvlpag <> 0 and 
                                btitulo.titsit = "LIB"
                            then do:
                                assign btitulo.titdtpag = tt-titulo.titdtpag
                                       btitulo.titvlpag = tt-titulo.titvlpag
                                       btitulo.titsit   = tt-titulo.titsit
                                       btitulo.etbcob   = tt-titulo.etbcob
                                       btitulo.cxacod   = tt-titulo.cxacod.
                            end.
                        
                        end.

                   end.
                   message "Titulos/Contrato Atualizados"
                            view-as alert-box.

                
                end.
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Exclusao " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-tt-titulo.
                    disp tt-titulo.
                end.
                /*
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-tt-titulo on error undo.
                    find tt-titulo where
                            recid(tt-titulo) = recatu1 
                        exclusive.
                    update tt-titulo.
                end.
                if esqcom1[esqpos1] = " Exclusao "
                then do with frame f-exclui  row 5 1 column centered
                        on error undo.
                    message "Confirma Exclusao de" tt-titulo.titnum
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next tt-titulo where true no-error.
                    if not available tt-titulo
                    then do:
                        find tt-titulo where recid(tt-titulo) = recatu1.
                        find prev tt-titulo where true no-error.
                    end.
                    recatu2 = if available tt-titulo
                              then recid(tt-titulo)
                              else ?.
                    find tt-titulo where recid(tt-titulo) = recatu1
                            exclusive.
                    delete tt-titulo.
                    recatu1 = recatu2.
                    leave.
                end.
                */
                /*
                if esqcom1[esqpos1] = " Listagem "
                then do with frame f-Lista:
                    update "Deseja Imprimir todas ou a selecionada "
                           sresp format "Todas/Selecionada"
                                 help "Todas/Selecionadas"
                           with frame f-lista row 15 centered color black/cyan
                                 no-label.
                    if sresp
                    then run ltt-titulo.p (input 0).
                    else run ltt-titulo.p (input tt-titulo.titnum).
                    leave.
                end.
                */
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
        recatu1 = recid(tt-titulo).
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

return.

procedure frame-a.
display tt-titulo.titnum    tt-titulo.titpar 
        tt-titulo.titdtemi  tt-titulo.titdtven  tt-titulo.titvlcob
        tt-titulo.selecionar format "S/N"
        with frame frame-a 11 down centered color white/red row 5.
end procedure.
procedure color-message.
color display message
        tt-titulo.titnum
        with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        tt-titulo.titnum
        with frame frame-a.
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first tt-titulo where true
                                                no-lock no-error.
    else  
        find last tt-titulo  where true
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next tt-titulo  where true
                                                no-lock no-error.
    else  
        find prev tt-titulo   where true
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev tt-titulo where true  
                                        no-lock no-error.
    else   
        find next tt-titulo where true 
                                        no-lock no-error.
        
end procedure.
         
