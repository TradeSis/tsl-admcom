/*
*
*    clasecom.p    -    Esqueleto de Programacao    com esqvazio


            substituir    clasecom
                          cla
*
*/

{admcab.i}

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend       as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Inclusao "," Alteracao "," Exclusao "," Consulta "," Listagem "].
def var esqcom2         as char format "x(12)" extent 5
            initial [" "," ","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial [" Inclusao  de clasecom ",
             " Alteracao da clasecom ",
             " Exclusao  da clasecom ",
             " Consulta  da clasecom ",
             " Listagem  Geral de clasecom "].
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].

def buffer bclasecom       for clasecom.
def var vclasecom         like clasecom.clacod.
def var varquivo           as character.

def var vclasup-ecom      like clasecom.clasup.

def buffer cclasecom for clasecom.
def buffer dclasecom for clasecom.


form
    clasecom.clacod      skip
    clasecom.clanome     skip
    clasecom.clatipo2    skip    
    vclasup-ecom     format ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>9"     skip
    clasecom.catcod      skip
    clasecom.fatfrete    skip
       with frame f-clasecom1
                    row 6 side-labels centered 1 column
                        width 70.

/*        
form
    clasecom.clacod      column-label "Cod"
    clasecom.clanome     
    clasecom.clasup      
    clasecom.catcod      
    clasecom.clatipo     
    clasecom.fatfrete    skip
       with frame f-relat overlay
                    .

*/        
                    
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
        find clasecom where recid(clasecom) = recatu1 no-lock.
    if not available clasecom
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(clasecom).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available clasecom
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
            find clasecom where recid(clasecom) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(clasecom.clanom)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(clasecom.clanom)
                                        else "".
            run color-message.
            choose field clasecom.clacod help ""
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
                    if not avail clasecom
                    then leave.
                    recatu1 = recid(clasecom).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail clasecom
                    then leave.
                    recatu1 = recid(clasecom).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail clasecom
                then next.
                color display white/red clasecom.clacod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail clasecom
                then next.
                color display white/red clasecom.clacod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form clasecom
                 with frame f-clasecom color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do on error undo.
                
                    display "Digite apenas a letra em destaque:" skip
                            "(S)uperior" skip
                            "(A)ssociavel" skip
                            "Su(P)erClasse" skip
                            "(U)ltimaClasse" skip
                            with frame f-help-clatipo2
                                    row 15 centered overlay.
                    pause 0.
    
                    hide frame f-help-clatipo2.

                    create clasecom.
                    update clasecom.clacod
                           clasecom.clanome
                             with frame f-clasecom1.
                           
                    view frame f-help-clatipo2.

                    repeat:

                        update clasecom.clatipo2 format "x(1)"
                                    with frame f-clasecom1.
        
                        case (clasecom.clatipo2):
                        when "S" then assign clasecom.clatipo2 = "Superior".
                        when "A" then assign clasecom.clatipo2 = "Associavel".
                        when "P" then assign clasecom.clatipo2 = "SuperClasse".
                        when "U" then assign clasecom.clatipo2 = "UltimaClasse".
                        otherwise do:
                        
                            message "Tipo de Classe inválido!"
                                    view-as alert-box.
                            next.
                            
                        end.
                        
                        end case.
                        
                        leave.
                        
                    end.
                    
                    hide frame f-help-clatipo2.
                    
                    display clasecom.clatipo2 format "x(20)"
                                with frame f-clasecom1.

                    repeat on error undo, retry:
                    
                        assign vclasup-ecom = clasecom.clasup.
                        
                        update vclasup-ecom
                                with frame f-clasecom1.
                    
                        assign clasecom.clasup = vclasup-ecom.
                        
                        release cclasecom.
                        find first cclasecom
                             where cclasecom.clacod = clasecom.clasup
                                        no-lock no-error.

                        if clasecom.clatipo2 = "Superior"
                            and clasecom.clasup <> 0
                        then do:
                                      
                            message "Uma Classe superior não pode "
                                    "estar abaixo de outra classe."
                                           view-as alert-box.                         
                            next.                          
                        end.
                        
                        else if clasecom.clatipo2 = "Associavel"
                              and cclasecom.clatipo2 <> "Superior"
                        then do:
                            
                            message "Uma Classe Associavel precisa "
                                    "estar abaixo de uma classe Superior"
                                          view-as alert-box.
                                           
                            next.
                            
                        end.    
                        else if clasecom.clatipo2 = "SuperClasse"
                              and cclasecom.clatipo2 <> "Associavel"
                        then do:
                            
                            message "Uma Super Classe precisa "
                                    "estar abaixo de uma classe Associavel"
                                          view-as alert-box.
                                           
                            next.
                            
                        end.    
                        else if clasecom.clatipo2 = "UltimaClasse"
                              and cclasecom.clatipo2 <> "SuperClasse"
                        then do:
                            
                            message "Uma Ultima Classe precisa "
                                    "estar abaixo de uma SuperClasse "
                                          view-as alert-box.
                                           
                            next.
                            
                        end.    
                        
                        leave.
                    
                    end.
                    
                    if keyfunction(lastkey) = "END-ERROR"
                    then undo, retry.
                    
                    update clasecom.catcod
                           clasecom.fatfrete
                            with frame f-clasecom1.
                            
                    recatu1 = recid(clasecom).
                    leave.
                end.
                if esqcom1[esqpos1] = " Consulta " 
                then do with frame f-clasecom.
                
                    assign vclasup-ecom = clasecom.clasup.
                
                    disp clasecom.clacod
                         clasecom.clanome
                         clasecom.clatipo2
                         vclasup-ecom
                         clasecom.catcod
                         clasecom.fatfrete
                          with frame f-clasecom1.
                end.
                
                if esqcom1[esqpos1] = " Exclusao " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-clasecom.
                
                    assign vclasup-ecom = clasecom.clasup.
                
                    disp clasecom.clacod
                         clasecom.clanome
                         clasecom.clatipo2
                         vclasup-ecom
                         clasecom.catcod
                         clasecom.fatfrete
                           with frame f-clasecom1.
                    pause 0.                
                end.
                
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-clasecom on error undo.
                    find clasecom where
                            recid(clasecom) = recatu1 
                        exclusive.
                    
                    update clasecom.clacod
                           clasecom.clanome
                           clasecom.clatipo2
                            with frame f-clasecom1.
                           
                    /*       
                    if can-find(first dclasecom
                                where dclasecom.clasup = clasecom.clacod)
                    then do:
            
                        message "Esta Classe possui outras Classes abaixo dela"
                                " e não pode ser selecionada.".
                        
                        undo, retry.
                                        
                    end.
                    */
                                                    
                    repeat on error undo, retry:
                    
                        assign vclasup-ecom = clasecom.clasup.
                        
                        update vclasup-ecom
                                with frame f-clasecom1.
                    
                        assign clasecom.clasup = vclasup-ecom.
                        
                        release cclasecom.
                        find first cclasecom
                             where cclasecom.clacod = clasecom.clasup
                                        no-lock no-error.

                        if clasecom.clatipo2 = "Superior"
                            and clasecom.clasup <> 0
                        then do:
                                      
                            message "Uma Classe superior não pode "
                                    "estar abaixo de outra classe."
                                           view-as alert-box.                                              next.                          
                        end.
                        
                        else if clasecom.clatipo2 = "Associavel"
                              and cclasecom.clatipo2 <> "Superior"
                        then do:
                            
                            message "Uma Classe Associavel precisa "
                                    "estar abaixo de uma classe Superior"
                                          view-as alert-box.
                                           
                            next.
                            
                        end.    
                        else if clasecom.clatipo2 = "SuperClasse"
                              and cclasecom.clatipo2 <> "Associavel"
                        then do:
                            
                            message "Uma Super Classe precisa "
                                    "estar abaixo de uma classe Associavel"
                                          view-as alert-box.
                                           
                            next.
                            
                        end.    
                        else if clasecom.clatipo2 = "UltimaClasse"
                              and cclasecom.clatipo2 <> "SuperClasse"
                        then do:
                            
                            message "Uma Ultima Classe precisa "
                                    "estar abaixo de uma SuperClasse "
                                          view-as alert-box.
                                           
                            next.
                            
                        end.    
                        
                        leave.
                    
                    end.
                    
                                
                    update clasecom.catcod
                           clasecom.fatfrete
                             with frame f-clasecom1.
                    
                    assign clasecom.clasup = vclasup-ecom.         
                             
                end.
                if esqcom1[esqpos1] = " Exclusao "
                then do with frame f-exclui  row 5 1 column centered
                        on error undo.
                    message "Confirma Exclusao de" clasecom.clanom
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next clasecom where true no-error.
                    if not available clasecom
                    then do:
                        find clasecom where recid(clasecom) = recatu1.
                        find prev clasecom where true no-error.
                    end.
                    recatu2 = if available clasecom
                              then recid(clasecom)
                              else ?.
                    
                    find clasecom where recid(clasecom) = recatu1
                                                no-lock.
                   
                    if avail clasecom
                    then do:
                      
                        if clasecom.clatipo
                        then do:
                   
                            if can-find(first bclasecom where bclasecom.clasup = clasecom.clacod)
                            then do:
                   
                                message "A classe superior selecionada nao pode ~ ser excluida, existem sub-classes associadas.".
                                leave.
                   
                            end.
                           
                        end.
                        else do:
                   
                            if can-find(first prodecom where prodecom.clacod = clasecom.clacod)
                            then do:
                   
                                message "A classe selecionada nao pode ser excluida, existem produtos associados.".
                                leave.
                   
                            end.
                   
                        end.
                       
                        find bclasecom where recid(bclasecom) = recatu1
                                                    exclusive-lock.
                        delete bclasecom.
                   
                        recatu1 = recatu2.
                        leave.

                    end.

                end.
                if esqcom1[esqpos1] = " Listagem "
                then do with frame f-Lista:
                    /*
                    update "Deseja Imprimir todas ou a selecionada "
                           sresp format "Todas/Selecionada"
                                 help "Todas/Selecionadas"
                           with frame f-lista row 15 centered color black/cyan
                                 no-label.
                    if sresp
                    then run lclasecom.p (input 0).
                    else run lclasecom.p (input clasecom.clacod).
                    */
                    
                    run p-listagem.
                    
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
        recatu1 = recid(clasecom).
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
display clasecom.clacod
        clasecom.clanome format "x(28)"
        clasecom.clasup
        clasecom.catcod
        clasecom.clatipo2 format "x(13)"
        clasecom.fatfrete column-label "Fat.Fret"
        with frame frame-a 11 down centered color white/red row 5 width 80.
end procedure.
procedure color-message.
color display message
        clasecom.clacod  
        clasecom.clanome 
        clasecom.clasup  
        clasecom.catcod  
        clasecom.clatipo2 
        clasecom.fatfrete
        with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        clasecom.clacod  
        clasecom.clanome 
        clasecom.clasup  
        clasecom.catcod  
        clasecom.clatipo2 
        clasecom.fatfrete
        with frame frame-a.
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first clasecom where true
                                                no-lock no-error.
    else  
        find last clasecom  where true
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next clasecom  where true
                                                no-lock no-error.
    else  
        find prev clasecom   where true
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev clasecom where true  
                                        no-lock no-error.
    else   
        find next clasecom where true 
                                        no-lock no-error.
        
end procedure.

         
         

procedure p-listagem:
    
    def buffer bclasecom for clasecom.
    
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/lclasecom." + string(time).
    else varquivo = "l:~\relat~\lclasecom." + string(time).
    
    {mdadmcab.i &Saida     = "value(varquivo)"
                &Page-Size = "64"
                &Cond-Var  = "80"
                &Page-Line = "66"
                &Nom-Rel   = ""clasecom""
                &Nom-Sis   = """SISTEMA ECOMMERCE"""
                &Tit-Rel   = """LISTAGEM DE CLASSES DO E-COMMERCE """
                &Width     = "80"
                &Form      = "frame f-cabcab"}
    
    disp with frame f-dados.

    for each bclasecom no-lock:

        disp bclasecom
          /*   with frame f-relat */.
                                  
    end.
    
    output close.
    
    message "Custom - Caminho do arquivo: " varquivo.
    pause.

    if opsys = "UNIX"
    then run visurel.p (input varquivo, input "").
    else {mrod.i}.


end procedure.


         
