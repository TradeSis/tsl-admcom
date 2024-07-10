/*----------------------------------------------------------------
 Programa..: kb-manperda.p
 Autor.....: Rafael A. (Kbase)
 Descricao.: CADASTRO DE NUMERO IDEAL DE PERDA
             Programa para manutencao de perda ideal anual por filial
 Alterações: 20/03/2015 - Criacao - Rafael A. (Kbase)
----------------------------------------------------------------*/

{admcab.i}

/*
/* temp-table para testes */
def temp-table perd-ide-fil
    field etbcod   like estab.etbcod
    field pidano   as int format "9999" label "Ano"
    field pidideal as dec format "zz9.99" label "Perda Ideal"
    index idx01 is primary unique
        etbcod pidano
    index idx02 
        pidano.
*/
def buffer b-perd-ide-fil for perd-ide-fil.

def var vetbcodaux like estab.etbcod no-undo.

form perd-ide-fil.etbcod
     perd-ide-fil.pidideal
     with frame f-visualiza side-label
     overlay row 7 centered color white/cyan.
     
form vetbcodaux
     perd-ide-fil.pidideal
     with frame f-incluir side-label
     overlay row 7 centered color white/cyan.
                              

form perd-ide-fil.etbcod
     perd-ide-fil.pidideal
     with frame f-altera1 side-label
     overlay row 7 centered color white/cyan.

def var vano            as int   no-undo format "9999".

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 4
    initial [" Incluir "," Alterar "," Consultar "," Excluir" ].

form esqcom1
     with frame f-com1
     row 6 no-box no-labels side-labels column 1 centered.

form vano label "Ano"
     with frame f-dados-busca row 3 side-label column 1 centered.

assign esqpos1  = 1.

assign vano = year(today).

dados-busca:
repeat:
    update vano label "Ano"
           with frame f-dados-busca side-label centered width 60.
    leave dados-busca.    
end.

bl-princ:
repeat:
    disp vano with frame f-dados-busca.
    
    disp esqcom1 with frame f-com1.
    
    if recatu1 = ? then run leitura (input "pri").
    else find perd-ide-fil where recid(perd-ide-fil) = recatu1 no-lock.
    
    if not available perd-ide-fil
        then esqvazio = yes.
    else esqvazio = no.
    
    clear frame frame-a all no-pause.
    
    if not esqvazio then
        run frame-a.
        
    recatu1 = recid(perd-ide-fil).
    
    color display message esqcom1[esqpos1] with frame f-com1.
    
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available perd-ide-fil then leave.
        
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        
        down with frame frame-a.
        
        run frame-a.
    end.
    
    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        if not esqvazio then do:
            find perd-ide-fil where recid(perd-ide-fil) = recatu1 no-lock.

            status default "".
            run color-message.
            choose field perd-ide-fil.etbcod help ""
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
                if not avail perd-ide-fil
                then leave.
                
                recatu1 = recid(perd-ide-fil).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up" then do:
            do reccont = 1 to frame-down(frame-a):
                run leitura (input "up").
                if not avail perd-ide-fil
                then leave.
                recatu1 = recid(perd-ide-fil).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "cursor-down" then do:
            run leitura (input "down").
            if not avail perd-ide-fil
            then next.
            color display white/red perd-ide-fil.etbcod with frame frame-a.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up" then do:
            run leitura (input "up").
            if not avail perd-ide-fil
            then next.
            color display white/red perd-ide-fil.etbcod with frame frame-a.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form perd-ide-fil.etbcod
                 perd-ide-fil.pidideal
                 with frame f-ideal color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

            if esqcom1[esqpos1] = " Incluir " or esqvazio
            then do with frame f-incluir on error undo.

                create perd-ide-fil.
                
                assign perd-ide-fil.pidano = vano.
                
                update vetbcodaux
                       perd-ide-fil.pidideal no-error.
                
                if can-find(perd-ide-fil where perd-ide-fil.etbcod = vetbcodaux
                                          and perd-ide-fil.pidano = vano)
                then do:
                    message ("Numero Ideal da Perda ja cadastrado para " +
                             "Estabelecimento " + string(vetbcodaux) +
                             " Ano " + string(vano)) view-as alert-box.
                    delete perd-ide-fil.
                    leave.
                end.
                else assign perd-ide-fil.etbcod = vetbcodaux.
                
                if perd-ide-fil.etbcod = 0 then do:
                    delete perd-ide-fil.
                    leave.
                end.

                /*
                run criarepexporta.p ("ESTAB",
                                      "INCLUSAO",
                                      recid(estab)).
                */
                
                recatu1 = recid(perd-ide-fil).
                leave.
            end.

            if esqcom1[esqpos1] = " Consultar " or
               esqcom1[esqpos1] = " Excluir "
            then do.
                run consulta.
            end.

            if esqcom1[esqpos1] = " Alterar "
            then do with frame f-altera1 on error undo.

                find current perd-ide-fil exclusive.
    
                assign perd-ide-fil.pidano = vano.
                
                disp   perd-ide-fil.etbcod.
                update perd-ide-fil.pidideal with no-validate.
                
                /*
                run criarepexporta.p ("ESTAB",
                                      "ALTERACAO",
                                      recid(estab)).
                */
            end.
            if esqcom1[esqpos1] = " Excluir "
            then do with frame f-exclui  row 5 1 column centered
            on error undo.
                message "Confirma Exclusao de" perd-ide-fil.etbcod
                update sresp.
                    
                if not sresp
                then undo, leave.
                
                find next perd-ide-fil where perd-ide-fil.pidano = vano 
                                             no-error.
                
                if not available metas-mes-fil then do:
                    find perd-ide-fil where recid(perd-ide-fil) = recatu1.
                    find prev perd-ide-fil where true no-error.
                end.
                
                recatu2 = if available perd-ide-fil
                          then recid(perd-ide-fil)
                          else ?.
                
                find perd-ide-fil where recid(perd-ide-fil) = recatu1
                                         exclusive.
                delete perd-ide-fil.
                    
                recatu1 = recatu2.
                leave.
            end.
        end.
        
        if not esqvazio
        then run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        disp vano with frame f-dados-busca.
        
        recatu1 = recid(perd-ide-fil).
    end.
    
    if keyfunction(lastkey) = "end-error" then do:
        view frame fc1.
        view frame fc2.
    end.
end.

hide frame f-visualiza   no-pause.
hide frame f-altera1     no-pause.
hide frame f-dados-busca no-pause.
hide frame f-com1        no-pause.
hide frame frame-a       no-pause.

procedure frame-a.

    disp perd-ide-fil.etbcod
         perd-ide-fil.pidideal
         with frame frame-a 9 down centered color white/red row 7.
end procedure.

procedure color-message.
color display message
        perd-ide-fil.etbcod
        with frame frame-a.
end procedure.

procedure color-normal.
color display normal
        perd-ide-fil.etbcod
        with frame frame-a.
end procedure.

procedure leitura . 
    def input parameter par-tipo as char.
        
    if par-tipo = "pri" then  
        if esqascend  
            then  
                find first perd-ide-fil where perd-ide-fil.pidano = vano
                                              no-lock no-error.
        else  
            find last perd-ide-fil where perd-ide-fil.pidano = vano
                                         no-lock no-error.
                                             
    if par-tipo = "seg" or par-tipo = "down" then  
        if esqascend  
            then  
                find next perd-ide-fil where perd-ide-fil.pidano = vano
                                             no-lock no-error.
        else  
            find prev perd-ide-fil where perd-ide-fil.pidano = vano
                                         no-lock no-error.
             
    if par-tipo = "up" then                  
        if esqascend   
            then   
                find prev perd-ide-fil where perd-ide-fil.pidano = vano
                                             no-lock no-error.
        else   
            find next perd-ide-fil where perd-ide-fil.pidano = vano
                                         no-lock no-error.
        
end procedure.

procedure consulta.

    do with frame f-visualiza.

         disp perd-ide-fil.etbcod
              perd-ide-fil.pidideal.
                       
    end.
end procedure.

/*
procedure email.

    def var varqmail as char.
    def var vassunto as char.
    def var varquivo as char.
    def var vdestino as char.
    
    assign
        vassunto = "Manutencao de Estabelecimentos" 
        vdestino = "sistema@lebes.com.br;" /*ricardo.mascarello@linx.com.br*/
        varquivo = "/admcom/relat/email" + string(time) + ".html".

    output to value(varquivo).
    put "<html>" skip
        "<head>" skip
        "<meta http-equiv=~"Content-Languag~" content=~"pt-br~">" skip
        "<meta name=~"GENERATOR~" content=~"Microsoft FrontPage 5.0~">" skip
        "<meta name=~"ProgId~" content=~"FrontPage.Editor.Document~">" skip
        "<meta http-equiv=~"Content-Type~" content=~"text/html; ".
    put "charset=windows-1252~">" skip
        "<title>Nova pagina</title>" skip
        "</head>" skip
        "<body>" skip.
    put unformatted
        "<h1>Sistema Admcom</h1></p>"
        "<b>Operacao:</b> " esqcom1[esqpos1] "</p>"
        "<b>Estabelecimento:</b> " estab.etbcod " - " estab.etbnom "</p>"
        "<b>Funcionario:</b> " sfuncod "</p></p>". 
    put "</body>" skip.
    put "</html>" skip.
    
    output close.
        
    varqmail = "/admcom/progr/mail.sh " +
                        " ~"" + vassunto + "~"" +
                        " ~"" + varquivo + "~"" +
                        " ~"" + vdestino + "~"" +
                        " ~"" + vdestino + "~"" +
                        " ~"text/html~"". 
    unix silent value(varqmail).

end procedure.
*/         
