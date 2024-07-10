/*
*
*    cad_receita.p    -    Esqueleto de Programacao    com esqvazio
*
*/

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
    initial [" Inclusao "," Alteracao "," "," "," "].
def var esqcom2         as char format "x(12)" extent 5
            initial ["  "," ","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial [" Inclusao do Cod. Receita",
             " Alteracao do Cod. Receita ",
             " ",
             " ",
             " "].
def var esqhel2         as char format "x(12)" extent 5
    initial [" ",
            " ",
            " ",
            " ",
            " "].

{cabec.i}

def buffer bPS_cod_receita for PS_Cod_receita.


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

def input param par-rec as recid .


find Serv_produ where recid(Serv_produ) = par-rec no-lock no-error.


bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        if esqascend
        then
            find first PS_Cod_Receita where 
                       PS_Cod_Receita.cod_item = Serv_produ.codigo
                       no-lock no-error.
        else
            find last PS_Cod_Receita where
                      PS_Cod_Receita.cod_item = Serv_produ.codigo
                      no-lock no-error.
    else
        find PS_Cod_Receita where 
             recid(PS_Cod_Receita) = recatu1 no-lock no-error.

    if not avail PS_Cod_Receita
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        disp PS_Cod_Receita.cod_Receita     format "x(10)"
             PS_Cod_Receita.cod_item        format "x(10)"     
             PS_Cod_Receita.Var_Cod_Receita format "x(4)"
             PS_Cod_Receita.Cod_Imposto_Ret format "x(30)"
             with frame frame-a 11 down centered row 5 width 80
             title " Codigos Receitas do item " + 
             string(Serv_produ.descricao, "x(30)") + " ".
             
    end.

    recatu1 = recid(PS_Cod_Receita).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        if esqascend
        then
            find next PS_Cod_Receita where
                      PS_Cod_Receita.cod_item = Serv_produ.codigo 
                      no-lock no-error.
        else
            find prev PS_Cod_Receita where
                      PS_Cod_Receita.cod_item = Serv_produ.codigo 
                      no-lock no-error.

        if not avail PS_Cod_Receita
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        
        disp PS_Cod_Receita.cod_receita     format "x(10)"
             PS_Cod_Receita.Cod_Item        format "x(10)"
             PS_Cod_Receita.Var_Cod_Receita format "x(4)"
             PS_Cod_Receita.Cod_Imposto_Ret format "x(30)"
             with frame frame-a.
    end.
    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        if not esqvazio
        then do:
            
            find PS_Cod_Receita where 
                 recid(PS_Cod_Receita) = recatu1 no-lock no-error.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then PS_Cod_Receita.cod_receita
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then PS_Cod_Receita.cod_receita
                                        else "".

            choose field PS_Cod_Receita.cod_receita help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return) .

            status default "".

        end.
        
        {esquema.i &tabela = "PS_Cod_Receita"
                   &campo  = "PS_Cod_Receita.cod_receita"
                   &where  = "PS_Cod_Receita.cod_item = Serv_produ.codigo"
                   &frame  = "frame-a"}

        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do on error undo, retry on endkey undo, leave:
            form  
            with frame f-PS_Cod_Receita  color black/cyan centered  
            row 5 side-labels width 80 1 down no-validate.
            hide frame frame-a no-pause.
            if esqregua
            then do:                                   
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-PS_Cod_Receita side-labels
                on error undo.
                    vultimo = 0.
                    /*for each bPS_cod_receita where
                             bPS_cod_receita.cod_item = Serv_produ.codigo
                             no-lock by int(bPS_cod_receita.cod_receita) desc.
                        vultimo = int(bPS_cod_receita.cod_receita).
                        leave.
                    end. */
                    prompt-for PS_Cod_Receita.cod_Receita.
                    
                    create PS_Cod_Receita.
                    assign PS_Cod_Receita.cod_item = Serv_produ.codigo
                           PS_Cod_Receita.cod_Receita 
                            .
                    find Serv_produ where
                         Serv_produ.codigo = PS_Cod_Receita.cod_item 
                         no-lock.
                    
                    disp PS_Cod_Receita.cod_Receita colon 20
                         PS_Cod_Receita.Var_Cod_Receita colon 60 skip
                         PS_Cod_Receita.cod_item colon 20 format  "x(10)" 
                         Serv_produ.descricao format "x(35)" colon 30 
                         no-label skip.
                         
                    update  PS_Cod_Receita.Var_Cod_Receita 
                            PS_Cod_Receita.Cod_Imposto_Ret
                                label "Cod. Imposto Retido".

                    /*PS_Cod_Receita.cod_receita = string(int(vultimo + 1)).
                      */
                      
                    recatu1 = recid(PS_Cod_Receita).      
                    leave.
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-PS_Cod_Receita on error undo.
                    find PS_cod_receita where 
                         recid(PS_cod_receita) = recatu1 exclusive.
                         
                    disp PS_cod_receita.cod_receita 
                         PS_cod_receita.cod_item.
                    
                    find Serv_produ where 
                         Serv_produ.codigo = PS_cod_receita.cod_item no-lock.
                    disp Serv_produ.descricao format "x(10)".
                         
                    update PS_Cod_Receita.Var_Cod_Receita
                           PS_Cod_Receita.Cod_Imposto_Ret.
                         
                end.
            end.
        end.
        if not esqvazio
        then do:
            disp PS_Cod_Receita.cod_receita     format "x(10)"
                 PS_Cod_Receita.Cod_Item        format "x(10)"  
                 PS_Cod_Receita.Var_Cod_Receita format "x(4)"
                 PS_Cod_Receita.Cod_Imposto_Ret format "x(30)"
                 with frame frame-a.
        end.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(PS_Cod_Receita).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.                            
