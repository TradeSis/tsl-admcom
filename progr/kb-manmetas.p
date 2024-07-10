/*----------------------------------------------------------------
 Programa..: kb-manmetas.p
 Autor.....: Rafael A. (Kbase)
 Descricao.: CADASTRO DE METAS PARA COBRANCA
             Programa para manutencao de metas mensais por filial
 Alterações: 18/03/2015 - Criacao - Rafael A. (Kbase)
----------------------------------------------------------------*/

{admcab.i}

def buffer b-metas-mes-fil for metas-mes-fil.

def var vetbcodaux like estab.etbcod no-undo.

form metas-mes-fil.etbcod
     metas-mes-fil.metpont
     metas-mes-fil.metm1
     metas-mes-fil.metm2
     metas-mes-fil.metperda
     with frame f-visualiza side-label
     overlay row 7 centered color white/cyan.
     
form vetbcodaux
     metas-mes-fil.metpont
     metas-mes-fil.metm1
     metas-mes-fil.metm2
     metas-mes-fil.metperda
     with frame f-incluir side-label
     overlay row 7 centered color white/cyan.

form metas-mes-fil.metpont
     metas-mes-fil.metm1
     metas-mes-fil.metm2
     metas-mes-fil.metperda
     with frame f-altera1 side-label
     overlay row 7 centered color white/cyan.

def var vano            as int   no-undo format "9999".
def var vmes            as int   no-undo format "99".

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

form vmes label "Mes"
     vano label "Ano"
     with frame f-dados-busca row 3 side-label column 1 centered.

assign esqpos1  = 1.

assign vmes = month(today)
       vano = year(today).

dados-busca:
repeat:
    update vmes label "Mes"
           vano label "Ano"
           with 2 col frame f-dados-busca side-label centered width 60.
    
    if (vmes > 0 and vmes < 13)
        then leave dados-busca.
    else
        message "Mes/Ano invalido".
end.

bl-princ:
repeat:
    disp vmes vano with frame f-dados-busca.
    
    disp esqcom1 with frame f-com1.
    
    if recatu1 = ? then run leitura (input "pri").
    else find metas-mes-fil where recid(metas-mes-fil) = recatu1 no-lock.
    
    if not available metas-mes-fil
        then esqvazio = yes.
    else esqvazio = no.
    
    clear frame frame-a all no-pause.
    
    if not esqvazio then
        run frame-a.
        
    recatu1 = recid(metas-mes-fil).
    
    color display message esqcom1[esqpos1] with frame f-com1.
    
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available metas-mes-fil then leave.
        
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        
        down with frame frame-a.
        
        run frame-a.
    end.
    
    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        if not esqvazio then do:
            find metas-mes-fil where recid(metas-mes-fil) = recatu1 no-lock.

            status default "".
            run color-message.
            choose field metas-mes-fil.etbcod help ""
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
                if not avail metas-mes-fil
                then leave.
                
                recatu1 = recid(metas-mes-fil).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up" then do:
            do reccont = 1 to frame-down(frame-a):
                run leitura (input "up").
                if not avail metas-mes-fil
                then leave.
                recatu1 = recid(metas-mes-fil).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "cursor-down" then do:
            run leitura (input "down").
            if not avail metas-mes-fil
            then next.
            color display white/red metas-mes-fil.etbcod with frame frame-a.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up" then do:
            run leitura (input "up").
            if not avail metas-mes-fil
            then next.
            color display white/red metas-mes-fil.etbcod with frame frame-a.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form metas-mes-fil.etbcod
                 metas-mes-fil.metpont
                 metas-mes-fil.metm1
                 metas-mes-fil.metm2
                 metas-mes-fil.metperda
                 with frame f-metas color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

            if esqcom1[esqpos1] = " Incluir " or esqvazio
            then do with frame f-incluir on error undo.

                create metas-mes-fil.
                
                assign metas-mes-fil.metano = vano
                       metas-mes-fil.metmes = vmes.
                
                update vetbcodaux
                       metas-mes-fil.metpont
                       metas-mes-fil.metm1
                       metas-mes-fil.metm2
                       metas-mes-fil.metperda.
                
                if can-find(metas-mes-fil where metas-mes-fil.etbcod =
                                                                    vetbcodaux
                                            and metas-mes-fil.metano = vano
                                            and metas-mes-fil.metmes = vmes)
                then do:
                   message ("Meta para Cobranca ja cadastrada para " +
                            "Estabelecimento " + string(vetbcodaux) +
                            " Mes " + string(vmes) +
                            " Ano " + string(vano)) view-as alert-box.
                   delete metas-mes-fil.
                   leave.
                end.
                else assign metas-mes-fil.etbcod = vetbcodaux.
                 
                if metas-mes-fil.etbcod = 0 then do:
                    delete metas-mes-fil.
                    leave.
                end.

                /*
                run criarepexporta.p ("ESTAB",
                                      "INCLUSAO",
                                      recid(estab)).
                */
                
                recatu1 = recid(metas-mes-fil).
                leave.
            end.

            if esqcom1[esqpos1] = " Consultar " or
               esqcom1[esqpos1] = " Excluir "
            then do.
                run consulta.
            end.

            if esqcom1[esqpos1] = " Alterar "
            then do with frame f-altera1 on error undo.

                find current metas-mes-fil exclusive.
    
                assign metas-mes-fil.metano = vano
                       metas-mes-fil.metmes = vmes.
                
                update metas-mes-fil.metpont
                       metas-mes-fil.metm1
                       metas-mes-fil.metm2
                       metas-mes-fil.metperda with no-validate.
                
                /*
                run criarepexporta.p ("ESTAB",
                                      "ALTERACAO",
                                      recid(estab)).
                */
            end.
            if esqcom1[esqpos1] = " Excluir "
            then do with frame f-exclui  row 5 1 column centered
            on error undo.
                message "Confirma Exclusao de" metas-mes-fil.etbcod
                update sresp.
                    
                if not sresp
                then undo, leave.
                
                find next metas-mes-fil where metas-mes-fil.metano = vano
                                          and metas-mes-fil.metmes = vmes
                                              no-error.
                
                if not available metas-mes-fil then do:
                    find metas-mes-fil where recid(metas-mes-fil) = recatu1.
                    find prev metas-mes-fil where metas-mes-fil.metano = vano
                                              and metas-mes-fil.metmes = vmes
                                                  no-error.
                end.
                
                recatu2 = if available metas-mes-fil
                          then recid(metas-mes-fil)
                          else ?.
                
                find metas-mes-fil where recid(metas-mes-fil) = recatu1
                                         exclusive.
                delete metas-mes-fil.
                    
                recatu1 = recatu2.
                leave.
            end.
        end.
        
        if not esqvazio
        then run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        disp vmes vano with frame f-dados-busca.
        
        recatu1 = recid(metas-mes-fil).
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

    disp metas-mes-fil.etbcod
         metas-mes-fil.metpont
         metas-mes-fil.metm1
         metas-mes-fil.metm2
         metas-mes-fil.metperda
         with frame frame-a 9 down centered color white/red row 7.
end procedure.

procedure color-message.
color display message
        metas-mes-fil.etbcod
        with frame frame-a.
end procedure.

procedure color-normal.
color display normal
        metas-mes-fil.etbcod
        with frame frame-a.
end procedure.

procedure leitura . 
    def input parameter par-tipo as char.
        
    if par-tipo = "pri" then  
        if esqascend  
            then  
                find first metas-mes-fil where metas-mes-fil.metano = vano
                                           and metas-mes-fil.metmes = vmes
                                               no-lock no-error.
        else  
            find last metas-mes-fil where metas-mes-fil.metano = vano
                                      and metas-mes-fil.metmes = vmes 
                                          no-lock no-error.
                                             
    if par-tipo = "seg" or par-tipo = "down" then  
        if esqascend  
            then  
                find next metas-mes-fil where metas-mes-fil.metano = vano
                                          and metas-mes-fil.metmes = vmes
                                              no-lock no-error.
        else  
            find prev metas-mes-fil where metas-mes-fil.metano = vano
                                      and metas-mes-fil.metmes = vmes 
                                          no-lock no-error.
             
    if par-tipo = "up" then                  
        if esqascend   
            then   
                find prev metas-mes-fil where metas-mes-fil.metano = vano
                                          and metas-mes-fil.metmes = vmes
                                              no-lock no-error.
        else   
            find next metas-mes-fil where metas-mes-fil.metano = vano
                                      and metas-mes-fil.metmes = vmes
                                          no-lock no-error.
        
end procedure.

procedure consulta.

    do with frame f-visualiza.

         disp metas-mes-fil.etbcod
              metas-mes-fil.metpont
              metas-mes-fil.metm1
              metas-mes-fil.metm2
              metas-mes-fil.metperda.
                       
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
