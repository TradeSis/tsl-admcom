/*
*
*    cad_itemserv.p    -    Esqueleto de Programacao    com esqvazio
*
*/
{admcab.i}

def var vultimo         as int.
def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Inclusao "," Alteracao "," ", " ", "     "].
def var esqcom2         as char format "x(16)" extent 5
 init ["Codigos Receita","Participantes","Processos", " " , " "].

def var esqhel1         as char format "x(80)" extent 5
    initial [" Inclusao de item ",
             " Alteracao de item ",
             "  ",
             "  ",
             "  "].
def var esqhel2         as char format "x(12)" extent 5.

def buffer bServ_Produ       for Serv_Produ.

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
    then run leitura (input "pri").
    else find Serv_Produ where recid(Serv_Produ) = recatu1 no-lock.
    if not available Serv_Produ
    then esqvazio = yes.
    else esqvazio = no.
    
    clear frame frame-a all no-pause.
    if not esqvazio
    then run frame-a.
    
    recatu1 = recid(Serv_Produ).

    if esqregua
    then color disp message esqcom1[esqpos1] with frame f-com1.
    else color disp message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available Serv_Produ
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:
        if not esqvazio
        then do:
            find Serv_Produ where recid(Serv_Produ) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(Serv_Produ.Descricao)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(Serv_Produ.Descricao)
                                        else "".
            run color-message.
            choose field Serv_Produ.Codigo help ""
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
                    color disp normal esqcom1[esqpos1] with frame f-com1.
                    color disp message esqcom2[esqpos2] with frame f-com2.
                end.
                else do:
                    color disp normal esqcom2[esqpos2] with frame f-com2.
                    color disp message esqcom1[esqpos1] with frame f-com1.
                end.
                esqregua = not esqregua.
            end.
            if keyfunction(lastkey) = "cursor-right"
            then do:
                if esqregua
                then do:
                    color disp normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
                    color disp messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color disp normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 5 then 5 else esqpos2 + 1.
                    color disp messages esqcom2[esqpos2] with frame f-com2.
                end.
                next.
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
                if esqregua
                then do:
                    color disp normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                    color disp messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color disp normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 1 then 1 else esqpos2 - 1.
                    color disp messages esqcom2[esqpos2] with frame f-com2.
                end.
                next.
            end.
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail Serv_Produ
                    then leave.
                    recatu1 = recid(Serv_Produ).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail Serv_Produ
                    then leave.
                    recatu1 = recid(Serv_Produ).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail Serv_Produ
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail Serv_Produ
                then next.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do on error undo, retry on endkey undo, leave:
            form serv_produ.codigo              
                 serv_produ.Descricao           format "x(60)"
                 serv_produ.Cod_Unid_Med_Estoq  
                    label "Cod.Unid.Med.Estoq" 
                 serv_produ.Cod_Tipo_Item      
                 serv_produ.Cod_Lista_Serv     
                 serv_produ.Descricao_Longa     format "x(60)"
                 serv_produ.Cod_Unid_Med_Emb  
                    label "Cod.Unid.Med.Emb."
                 serv_produ.Cod_NBS            
                 serv_produ.Cod_Tipo_Serv      
                 serv_produ.Ind_Serv_Esp       
                 serv_produ.Tipo_Repasse  
                 serv_produ.CFOP     
            with frame f-Serv_Produ color black/cyan centered side-label row 5.
            hide frame frame-a no-pause.
            if esqregua
            then do:
                disp caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-Serv_Produ with no-validate 
                                2 col on error undo.
                    vultimo = 0.
                    for each bServ_Produ no-lock 
                        by int(bServ_Produ.Codigo) desc.
                        vultimo = int(bServ_Produ.Codigo).
                        leave.
                    end.
                    
                    create Serv_Produ.
                    update serv_produ.Descricao           format "x(60)"
                           validate(serv_produ.Descricao <> "",
                            "Descricao deve ser informada.").
                    
                    update serv_produ.Cod_Unid_Med_Estoq
                             label "Cod.Unid.Med.Estoq"
                           serv_produ.Cod_Tipo_Item
                           serv_produ.Cod_Lista_Serv
                           serv_produ.Descricao_Longa     format "x(60)"
                           serv_produ.Cod_Unid_Med_Emb
                             label "Cod.Unid.Med.Emb."
                           serv_produ.Cod_NBS
                           serv_produ.Cod_Tipo_Serv
                           serv_produ.Ind_Serv_Esp
                           serv_produ.Tipo_Repasse
                           serv_produ.CFOP
                           .
                    
                    Serv_Produ.codigo = string(int(vultimo + 1)).
                    recatu1 = recid(Serv_Produ).
                    leave.
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-Serv_Produ with 2 col 
                on error undo.
                    find Serv_Produ where recid(Serv_Produ) = recatu1 exclusive.
                    disp  serv_produ.codigo.
                    update serv_produ.Descricao    format "x(60)"
                        validate(serv_produ.Descricao <> "", 
                            "Descricao deve ser informada.").
                            
                    update serv_produ.Cod_Unid_Med_Estoq
                               label "Cod.Unid.Med.Estoq"
                           serv_produ.Cod_Tipo_Item     
                           serv_produ.Cod_Lista_Serv    
                           serv_produ.Descricao_Longa    format "x(60)"
                           serv_produ.Cod_Unid_Med_Emb 
                               label "Cod.Unid.Med.Emb."
                           serv_produ.Cod_NBS            
                           serv_produ.Cod_Tipo_Serv
                           serv_produ.Ind_Serv_Esp
                           serv_produ.Tipo_Repasse
                           serv_produ.CFOP
                           .
                end.
            end.
            else do:
                disp caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                
                if esqcom2[esqpos2] = "Codigos Receita"
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    hide frame frame-a no-pause.
                    run cad_receita.p(recid(Serv_Produ)).
                    view frame f-com1.
                    view frame f-com2.
                end.
                if esqcom2[esqpos2] = "Participantes"
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    hide frame frame-a no-pause.
                    run cad_partic.p (recid(Serv_Produ)).
                    view frame f-com1.
                    view frame f-com2.
                end.
                if esqcom2[esqpos2] = "Processos"
                then do:
                    hide frame f-com1 no-pause.
                    hide frame f-com2  no-pause.
                    hide frame frame-a no-pause.
                    run cad_processo.p (recid(Serv_Produ)).
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
        then disp esqcom1[esqpos1] with frame f-com1.
        else disp esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(Serv_Produ).
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
    disp 
    Serv_Produ.Codigo             format "x(10)"  column-label "Codigo"
    Serv_Produ.Descricao          format "x(20)"  column-label "Descricao" 
    serv_produ.Cod_Tipo_Item      format "x(2)"   column-label "Tipo!Item" 
    serv_produ.Cod_Lista_Serv format "zzzzzzzzz9" column-label "Lista Serv."
    serv_produ.Cod_NBS            format "x(10)"  column-label "Codigo NBS" 
    serv_produ.Cod_Tipo_Serv  format "zzzzzzzzz9" column-label "Tipo Serv."
    serv_produ.Tipo_Repasse       format "9"      column-label "Tipo!Repasse"
    with frame frame-a 11 down width 80 color white/red row 5.
end procedure.


procedure color-message.
    color disp message Serv_Produ.Codigo format "x(10)"  column-label "Codigo"
    with frame frame-a.
end procedure.


procedure color-normal.
    color disp normal Serv_Produ.Codigo format "x(10)"  column-label "Codigo"
    with frame frame-a.
end procedure.


procedure leitura.
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend 
    then  
        find first Serv_Produ where true no-lock no-error.
    else  
        find last Serv_Produ where true  no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next Serv_Produ where true no-lock no-error.
    else  
        find prev Serv_Produ where true no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev Serv_Produ where true no-lock no-error.
    else   
        find next Serv_Produ where true no-lock no-error.
        
end procedure.
         
