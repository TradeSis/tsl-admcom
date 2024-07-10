/*---------------------------------------------------------------- 
 Programa..: kb-manmettel.p 
 Autor.....: Andre Raubach (Kbase) 
 Descricao.: CADASTRO DE METAS DE TELEFONIA 
             Programa para manutencao de metas de telefonia 
 Alterações: 28/03/2016 - Criacao - Andre Raubach (Kbase) 
----------------------------------------------------------------*/

{admcab.i}

def var vano  like metas-telefonia.ano.
def var vmes  like metas-telefonia.mes.
def var vloja like metas-telefonia.etbcod no-undo.

def var recatu1   as recid.
def var recatu2   as recid.
def var reccont   as int.
def var esqpos1   as int.
def var esqvazio  as log.
def var esqascend as log initial yes.
def var esqcom1 as char format "x(16)" extent 4
    initial ["     Incluir "," Alter. Manual "," Alter. em Massa ",
             "      Consultar " ].

def temp-table tt-metas like metas-telefonia.

form metas-telefonia.etbcod label "Estab." skip(1)
     metas-telefonia.vivopre
     metas-telefonia.vivopos
     metas-telefonia.claropre
     metas-telefonia.claropos
     metas-telefonia.timpre
     metas-telefonia.timpos
     with frame f-visualiza 2 col side-label overlay row 8 
     centered width 45 color white/cyan.

form vloja label "Estab." skip(1)
     metas-telefonia.vivopre
     metas-telefonia.vivopos
     metas-telefonia.claropre
     metas-telefonia.claropos
     metas-telefonia.timpre
     metas-telefonia.timpos
     with frame f-incluir 2 col side-label overlay row 8 
     centered width 45 color white/cyan.

form metas-telefonia.etbcod label "Estab." skip(1)
     metas-telefonia.vivopre
     metas-telefonia.vivopos
     metas-telefonia.claropre
     metas-telefonia.claropos
     metas-telefonia.timpre
     metas-telefonia.timpos
     with frame f-altera 2 col side-label overlay row 8 
     centered width 45 color white/cyan.

form esqcom1 with frame f-com1
    row 6 no-box no-labels side-labels column 1 centered.

form vano  label "Ano"
     vmes  label "Mes"
     with frame f-dados row 3 side-label column 1 centered.
     
assign esqpos1 = 1.
     
assign vano = year(today)
       vmes = month(today).

dados:
repeat:
    update vano  label "Ano"
           vmes  label "Mes"
           with 2 col frame f-dados side-label centered width 70.
    
    if not (vmes > 0 and vmes < 13) or not (vano > 0) then do:
        message "Mes/Ano invalido".
        pause.
        hide message no-pause.
        undo.
    end.
    
    leave dados.
end.

b-principal:
repeat:
    disp vano vmes with frame f-dados.
    disp esqcom1 with frame f-com1 side-label centered width 70.

    if recatu1 = ? then run leitura (input "pri").
    else find metas-telefonia where recid(metas-telefonia) = recatu1 no-lock.

    if not available metas-telefonia then esqvazio = yes.
    else esqvazio = no.

    clear frame frame-a all no-pause.
    if not esqvazio then    
        run frame-a.    

    recatu1 = recid(metas-telefonia).
    color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio then
        repeat:    
            run leitura (input "seg").    
            if not available metas-telefonia then leave.        
            if frame-line(frame-a) = frame-down(frame-a) then leave.        
            down with frame frame-a.        
            run frame-a.
        end.
    
    if not esqvazio then
        up frame-line(frame-a) - 1 with frame frame-a.
    
    repeat with frame frame-a:
        
        if not esqvazio then do:
            find metas-telefonia where recid(metas-telefonia) = recatu1 no-lock.
            
            status default "".
            run color-message.
            choose field metas-telefonia.etbcod help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      PF4 F4 ESC return) .
            run color-normal.
            status default "".
        end.
        
        if keyfunction(lastkey) = "cursor-right" then do:
            color display normal esqcom1[esqpos1] with frame f-com1.
            esqpos1 = if esqpos1 = 4 then 4 else esqpos1 + 1.
            color display messages esqcom1[esqpos1] with frame f-com1.
            next.
        end.
        
        if keyfunction(lastkey) = "cursor-left" then do:
            color display normal esqcom1[esqpos1] with frame f-com1.
            esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
            color display messages esqcom1[esqpos1] with frame f-com1.
            next.
        end.
        
        if keyfunction(lastkey) = "page-down" then do:
            do reccont = 1 to frame-down(frame-a):
                run leitura (input "down").
                if not avail metas-telefonia then leave.
                
                recatu1 = recid(metas-telefonia).
            end.
            leave.
        end.
        
        if keyfunction(lastkey) = "page-up" then do:
            do reccont = 1 to frame-down(frame-a):
                run leitura (input "up").
                if not avail metas-telefonia then leave.   

                recatu1 = recid(metas-telefonia).
            end.
            leave.
        end.
        
        if keyfunction(lastkey) = "cursor-down" then do:
            run leitura (input "down").
            if not avail metas-telefonia then next.
            color display white/red metas-telefonia.etbcod with frame frame-a.
            if frame-line(frame-a) = frame-down(frame-a) then
                scroll with frame frame-a.
            else down with frame frame-a.
        end.
        
        if keyfunction(lastkey) = "cursor-up" then do:
            run leitura (input "up").
            if not avail metas-telefonia then next.
            color display white/red metas-telefonia.etbcod with frame frame-a.
            if frame-line(frame-a) = 1 then
                scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        
        if keyfunction(lastkey) = "end-error" then leave b-principal.
        
        if keyfunction(lastkey) = "return" or esqvazio then do:
            form metas-telefonia.vivopre
                 metas-telefonia.vivopos
                 metas-telefonia.claropre
                 metas-telefonia.claropos
                 metas-telefonia.timpre
                 metas-telefonia.timpos
                 with frame f-metas color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                                                with frame f-com1.
            
           if esqcom1[esqpos1] = "     Incluir " or esqvazio then 
                do with frame f-incluir on error undo:
                    
                    do on error undo:
                        update vloja.
                        
                        find first estab where estab.etbcod = vloja 
                                                    no-lock no-error.
                        if not avail estab or vloja <= 0 then do:
                            message "Loja invalida.".
                            pause.
                            hide message no-pause.
                            undo.
                        end.
                        /* Ignora pavilhoes e depositos */
                        if estab.etbcod >= 500 then do:
                            message "Informe uma loja de codigo menor 
                                     do que 500.".
                            pause.
                            hide message no-pause.
                            undo.
                         end.
                    end.
                    
                    if can-find(metas-telefonia where 
                                    metas-telefonia.ano = vano
                                and metas-telefonia.mes = vmes
                                and metas-telefonia.etbcod = vloja) 
                                then do:

                        message ("Meta para Cobranca ja cadastrada para " +
                                 "Estabelecimento " + string(vloja)  +
                                 " Mes " + string(vmes)                   +
                                 " Ano " + string(vano)) view-as alert-box.
                        leave.                        
                    end.
                    else create metas-telefonia.
                
                    assign metas-telefonia.ano = vano
                           metas-telefonia.mes = vmes
                           metas-telefonia.etbcod = vloja.
                    
                    update metas-telefonia.vivopre
                           metas-telefonia.vivopos
                           metas-telefonia.claropre
                           metas-telefonia.claropos
                           metas-telefonia.timpre
                           metas-telefonia.timpos.

                    recatu1 = recid(metas-telefonia).
                    leave.
                    
                end. /* Fim INCLUIR */
           
                
            if esqcom1[esqpos1] = "      Consultar " then
                run consulta.
            

            if esqcom1[esqpos1] = " Alter. Manual " then
                do with frame f-altera on error undo:
                
                    find current metas-telefonia exclusive.
                    
                    assign metas-telefonia.ano = vano
                           metas-telefonia.mes = vmes.
                    
                    disp metas-telefonia.etbcod.
                    
                    update metas-telefonia.vivopre
                           metas-telefonia.vivopos
                           metas-telefonia.claropre
                           metas-telefonia.claropos
                           metas-telefonia.timpre
                           metas-telefonia.timpos.
                           
                    if keyfunction(lastkey) = "end-error" then do:
                        hide frame f-altera.
                    end.
                    
                end. /* Fim Alter. manual */
        end.
            
            if esqcom1[esqpos1] = " Alter. em Massa " then do:
                run importa-metas.
                recatu1 = ?.
                leave.
            end.
            
            if not esqvazio then run frame-a.
            display esqcom1[esqpos1] with frame f-com1.
            disp vmes vano with frame f-dados.
            
            recatu1 = recid(metas-telefonia).
    end.
    
    if keyfunction(lastkey) = "end-error" then do:
        hide all.
    end.
    
end.

hide frame f-visualiza no-pause.
hide frame f-altera    no-pause.
hide frame f-dados     no-pause.
hide frame f-com1      no-pause.
hide frame frame-a     no-pause.

    
procedure frame-a:
    disp metas-telefonia.etbcod
         metas-telefonia.vivopre
         metas-telefonia.vivopos
         metas-telefonia.claropre
         metas-telefonia.claropos
         metas-telefonia.timpre
         metas-telefonia.timpos
         with frame frame-a 9 down centered color white/red row 7.
end procedure.
    
procedure color-message:
    color display message
        metas-telefonia.etbcod
        with frame frame-a.
end procedure.
    
procedure color-normal:
    color display normal
        metas-telefonia.etbcod
        with frame frame-a.
end procedure.

procedure leitura:
    def input parameter par-tipo as char.           

    if par-tipo = "pri" then          
        if esqascend then       
            find first metas-telefonia where metas-telefonia.ano = vano
                                         and metas-telefonia.mes = vmes
                                                            no-lock no-error.
        else              
            find last metas-telefonia where metas-telefonia.ano = vano
                                        and metas-telefonia.mes = vmes
                                                            no-lock no-error.

     if par-tipo = "seg" or par-tipo = "down" then        
        if esqascend then     
            find next metas-telefonia where metas-telefonia.ano = vano
                                        and metas-telefonia.mes = vmes
                                                            no-lock no-error.
        else              
            find prev metas-telefonia where metas-telefonia.ano = vano
                                        and metas-telefonia.mes = vmes
                                                            no-lock no-error.
                                                                         
    if par-tipo = "up" then                          
        if esqascend then                    
            find prev metas-telefonia where metas-telefonia.ano = vano
                                        and metas-telefonia.mes = vmes
                                                            no-lock no-error.
        else                
            find next metas-telefonia where metas-telefonia.ano = vano
                                        and metas-telefonia.mes = vmes
                                                            no-lock no-error.
              
end procedure.

procedure consulta:
    do with frame f-visualiza:
        disp metas-telefonia.etbcod
             metas-telefonia.vivopre
             metas-telefonia.vivopos
             metas-telefonia.claropre
             metas-telefonia.claropos
             metas-telefonia.timpre
             metas-telefonia.timpos.
    end.
end procedure.

procedure importa-metas:
    def var vpasta   as char init "/admcom/import/".
    def var varquivo as char.
    def var cont     as inte init 0.
    
    update vpasta   label "Pasta"   format "x(20)"
           varquivo label "Arquivo" format "x(40)"
           with frame f-arquivo side-label centered.
    
    empty temp-table tt-metas.
    input from value(vpasta + varquivo).
    repeat:
        create tt-metas.
        import delimiter ";" tt-metas.
    end.
    input close.
    
    for each tt-metas:
        if not (tt-metas.ano > 0 and
               (tt-metas.mes > 0 and tt-metas.mes < 13)) then next.
        if not can-find(estab where estab.etbcod = tt-metas.etbcod) then next.
        if not (tt-metas.etbcod < 500) then next.

        find metas-telefonia of tt-metas exclusive-lock no-error.
        if not avail metas-telefonia then do:
            create metas-telefonia.
            buffer-copy tt-metas to metas-telefonia.
            cont = cont + 1.
        end.
        else do:
            assign metas-telefonia.ano      = tt-metas.ano
                   metas-telefonia.mes      = tt-metas.mes
                   metas-telefonia.etbcod   = tt-metas.etbcod
                   metas-telefonia.vivopre  = tt-metas.vivopre
                   metas-telefonia.vivopos  = tt-metas.vivopos
                   metas-telefonia.claropre = tt-metas.claropre
                   metas-telefonia.claropos = tt-metas.claropos
                   metas-telefonia.timpre   = tt-metas.timpre
                   metas-telefonia.timpos   = tt-metas.timpos.
            cont = cont + 1.
        end.
    end.
    message "Registros importados: " cont view-as alert-box.
end procedure.
