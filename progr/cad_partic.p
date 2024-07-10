/*
*
*    cad_partic.p    -    Esqueleto de Programacao    com esqvazio

*
*/

def var vforcod like PS_participante.cod_parceiro.

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
    initial [" Inclusao do Participante",
             " Alteracao do Participante ",
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

def buffer bPS_participantes for PS_participantes.


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
            find first PS_participantes where 
                       PS_participantes.cod_item = Serv_produ.codigo
                       no-lock no-error.
        else
            find last PS_participantes where
                      PS_participantes.cod_item = Serv_produ.codigo
                      no-lock no-error.
    else
        find PS_participantes where 
             recid(PS_participantes) = recatu1 no-lock no-error.

    if not avail PS_participantes
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:

        find forne where 
             forne.forcod = int(PS_participantes.cod_parceiro)
             no-lock no-error.
             
        disp PS_participantes.cod_parceiro      format "x(10)"
             forne.fornom format "x(20)"  column-label "Descricao"
             PS_participantes.cod_item          format "x(10)"     
             PS_participantes.Ind_Forn_Alim     format "Sim/Nao"
                column-label "Forn.!Alim."
             PS_participantes.Ind_Forn_Transp   format "Sim/Nao"
                column-label "Forn.!Transp."
             PS_participantes.Ind_Outras_Desp   format "Sim/Nao"
                column-label "Outras!Despesas"
             PS_participantes.Ind_Mat_Eqto      format "Sim/Nao"
                column-label "Material!e Equip."
             with frame frame-a 11 down centered row 5 width 80
             title " Participantes do item " + 
             string(Serv_produ.descricao, "x(30)") + " ".
             
    end.

    recatu1 = recid(PS_participantes).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        if esqascend
        then
            find next PS_participantes where
                      PS_participantes.cod_item = Serv_produ.codigo 
                      no-lock no-error.
        else
            find prev PS_participantes where
                      PS_participantes.cod_item = Serv_produ.codigo 
                      no-lock no-error.

        if not avail PS_participantes
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        
         find forne where
              forne.forcod = int(PS_participantes.cod_parceiro)
             no-lock no-error.
        
        disp PS_participantes.cod_parceiro      format "x(10)"
             forne.fornom format "x(20)" column-label "Descricao"
             PS_participantes.cod_item          format "x(10)"
             PS_participantes.Ind_Forn_Alim     format "Sim/Nao"
                column-label "Descricao"
             PS_participantes.Ind_Forn_Transp   format "Sim/Nao"
                column-label "Forn.!Transp."
             PS_participantes.Ind_Outras_Desp   format "Sim/Nao"
                column-label "Outras!Despesas"
             PS_participantes.Ind_Mat_Eqto      format "Sim/Nao"
                column-label "Material!e Equip."
             with frame frame-a.
    end.
    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        if not esqvazio
        then do:
            
            find PS_participantes where 
                 recid(PS_participantes) = recatu1 no-lock no-error.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then PS_participantes.cod_parceiro
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then PS_participantes.cod_parceiro
                                        else "".

            choose field PS_participantes.cod_parceiro help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return) .

            status default "".

        end.
        
        {esquema.i &tabela = "PS_participantes"
                   &campo  = "PS_participantes.cod_parceiro"
                   &where  = "PS_participantes.cod_item = Serv_produ.codigo"
                   &frame  = "frame-a"}

        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do on error undo, retry on endkey undo, leave:
            form  
            with frame f-PS_participantes  color black/cyan centered  
            row 5 side-labels width 80 1 down.
            hide frame frame-a no-pause.
            if esqregua
            then do:                                   
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-PS_participantes side-labels
                on error undo.
                    
                    create PS_participantes.
                    assign PS_participantes.cod_item     = Serv_produ.codigo
                           PS_participantes.cod_parceiro = "0".
                           
                    find Serv_produ where
                         Serv_produ.codigo = PS_participantes.cod_item 
                         no-lock no-error.

                    disp vforcod colon 20 label "Cod. Parceiro".
                    do on error undo:
                        vforcod = "".
                        update vforcod colon 20
                            help "Informe o codigo do participante"
                            validate(vforcod <> "",
                                "Participante invalido.").
                            

                        if can-find(first bPS_participantes where
                                          bPS_participantes.cod_item = 
                                          PS_participantes.cod_item and
                                     bPS_participantes.cod_parceiro = 
                                          vforcod) then do:
                            message "Participante ja cadastrado para este"
                                    "item. Verifique."
                                    view-as alert-box.
                            undo.
                        end.                                          
                        
                        find serv_forne where
                             serv_forne.forcod = int(vforcod)
                             no-lock no-error.
                        if not avail serv_forne then do:
                            message "O participante informado nao esta"
                                    "cadastrado. Verifique."
                                     view-as alert-box .
                            undo.             
                        end.
                    end.
 
                    find forne of serv_forne no-lock no-error.
                    
                    disp vforcod colon 20 label "Cod. Parceiro"
                         forne.fornom colon 20 label "Descricao" format "x(50)"
                         PS_participantes.cod_item colon 20 format "x(10)"
                         Serv_produ.descricao format "x(35)" colon 30 no-label
                         PS_participantes.Ind_Forn_Alim   colon 20
                         PS_participantes.Ind_Forn_Transp colon 60
                         PS_participantes.Ind_Outras_Desp colon 20
                         PS_participantes.Ind_Mat_Eqto    colon 60.
                         
                    update PS_participantes.Ind_Forn_Alim
                           PS_participantes.Ind_Forn_Transp
                           PS_participantes.Ind_Outras_Desp
                           PS_participantes.Ind_Mat_Eqto.

                    assign PS_participantes.cod_parceiro     = vforcod
                           PS_participantes.Descricao_Partic = forne.fornom.

                    update PS_participantes.codigo_receita_nat
                                    label "Codigo Receita       "
                           PS_participantes.cod_imposto_retido_nat
                                    label "Codigo Imposto Retido"
                           PS_participantes.var_cod_receita_nat
                                    label "Variacao Cod Receita "
                           . 
                    recatu1 = recid(PS_participantes).      
                    leave.
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-PS_participantes on error undo.
                    find PS_participantes where 
                         recid(PS_participantes) = recatu1 exclusive.
                         
                    find Serv_produ where 
                         Serv_produ.codigo = PS_participantes.cod_item 
                         no-lock no-error.
                    
                    find serv_forne where
                         serv_forne.forcod = int(PS_participantes.cod_parceiro)
                         no-lock no-error.
                    
                    find forne of serv_forne no-lock no-error.
                    vforcod = PS_participantes.cod_parceiro.
                    
                    
                    disp forne.fornom colon 20 label "Descricao" format "x(50)"
                         PS_participantes.cod_item
                         Serv_produ.descricao format "x(10)".
                         
                    do on error undo:
                        update vforcod colon 20
                            help "Informe o codigo do participante"
                            validate(vforcod <> "",
                                "Participante invalido.").
                            

                        if can-find(first bPS_participantes where
                                       rowid(bPS_participantes) <>
                                       rowid(PS_participantes)  and
                                          bPS_participantes.cod_item = 
                                          PS_participantes.cod_item and
                                     bPS_participantes.cod_parceiro = 
                                          vforcod) then do:
                            message "Participante ja cadastrado para este"
                                    "item. Verifique."
                                    view-as alert-box.
                            undo.
                        end.                                          
                        
                        find serv_forne where
                             serv_forne.forcod = int(vforcod)
                             no-lock no-error.
                        if not avail serv_forne then do:
                            message "O participante informado nao esta"
                                    "cadastrado. Verifique."
                                     view-as alert-box .
                            undo.             
                        end.
                    end.
 
                    find forne of serv_forne no-lock no-error.
                    
                    disp vforcod colon 20 label "Cod. Parceiro"
                         forne.fornom colon 20 label "Descricao" format "x(50)"
                         PS_participantes.cod_item colon 20 format "x(10)"
                         Serv_produ.descricao format "x(35)" colon 30 no-label.
                    
                    update PS_participantes.Ind_Forn_Alim
                           PS_participantes.Ind_Forn_Transp
                           PS_participantes.Ind_Outras_Desp
                           PS_participantes.Ind_Mat_Eqto.
                    
                    assign PS_participantes.cod_parceiro = vforcod
                           PS_participantes.Descricao_Partic = forne.fornom.

                    update PS_participantes.codigo_receita_nat
                                    label "Codigo Receita       "
                           PS_participantes.cod_imposto_retido_nat
                                    label "Codigo Imposto Retido"
                           PS_participantes.var_cod_receita_nat
                                    label "Variacao Cod Receita "
                           . 

                     recatu1 = recid(PS_participantes).
                end.
            end.
        end.
        if not esqvazio
        then do:
            find forne where
                 forne.forcod = int(PS_participantes.cod_parceiro)
                 no-lock no-error.
            
            disp PS_participantes.cod_parceiro      format "x(10)"
                 forne.fornom format "x(20)" column-label "Descricao"
                 PS_participantes.cod_item          format "x(10)"
                 PS_participantes.Ind_Forn_Alim     format "Sim/Nao"
                    column-label "Forn.!Alim."
                 PS_participantes.Ind_Forn_Transp   format "Sim/Nao"
                    column-label "Forn.!Transp."
                 PS_participantes.Ind_Outras_Desp   format "Sim/Nao"
                    column-label "Outras!Despesas"
                 PS_participantes.Ind_Mat_Eqto      format "Sim/Nao"
                    column-label "Material!e Equip."
                 with frame frame-a.
        end.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(PS_participantes).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.                            
