/*
*
*    cad_processo.p     -    Esqueleto de Programacao    com esqvazio

*
*/

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
    initial [" Inclusao do Processo",
             " Alteracao do Processo ",
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

def buffer bPS_Processo for PS_Processo.


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
            find first PS_Processo where 
                       PS_Processo.cod_item = Serv_produ.codigo
                       no-lock no-error.
        else
            find last PS_Processo where
                      PS_Processo.cod_item = Serv_produ.codigo
                      no-lock no-error.
    else
        find PS_Processo where 
             recid(PS_Processo) = recatu1 no-lock no-error.

    if not avail PS_Processo
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        disp PS_processo.Num_Processo   format "x(28)"
             PS_processo.Cod_Item       format "x(8)"
                column-label "Codigo!Item"
             PS_processo.Cod_Parceiro   format "x(8)"
                column-label "Codigo!Parceiro"
             PS_processo.Cod_Mun_IBGE   format "zzzzzzzzz9"
                column-label "Munic.IBGE"
             PS_processo.Cod_Suspensao  format "x(13)"
                column-label "Codigo!Suspensao"
             PS_processo.Tipo_Processo  format "Adm./Jud."
                column-label "Tipo!Proc."
        with frame frame-a 11 down centered row 5 width 80
        title " Processos do item " +
        string(Serv_produ.descricao, "x(30)") + " ".   
             
    end.

    recatu1 = recid(PS_Processo).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        if esqascend
        then
            find next PS_Processo where
                      PS_Processo.cod_item = Serv_produ.codigo 
                      no-lock no-error.
        else
            find prev PS_Processo where
                      PS_Processo.cod_item = Serv_produ.codigo 
                      no-lock no-error.

        if not avail PS_Processo
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        

        disp PS_processo.Num_Processo   format "x(28)"
             PS_processo.Cod_Item       format "x(8)"
                column-label "Codigo!Item"
             PS_processo.Cod_Parceiro   format "x(8)"
                column-label "Codigo!Parceiro"
             PS_processo.Cod_Mun_IBGE   format "zzzzzzzzz9"
                column-label "Munic.IBGE"    
             PS_processo.Cod_Suspensao  format "x(13)"
                column-label "Codigo!Suspensao"
             PS_processo.Tipo_Processo  format "Adm./Jud."
                column-label "Tipo!Proc."
             with frame frame-a.
    end.
    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        if not esqvazio
        then do:
            
            find PS_Processo where 
                 recid(PS_Processo) = recatu1 no-lock no-error.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then PS_Processo.cod_parceiro
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then PS_Processo.cod_parceiro
                                        else "".

            choose field PS_Processo.num_processo help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return) .

            status default "".

        end.
        
        {esquema.i &tabela = "PS_Processo"
                   &campo  = "PS_Processo.cod_parceiro"
                   &where  = "PS_Processo.cod_item = Serv_produ.codigo"
                   &frame  = "frame-a"}

        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do on error undo, retry on endkey undo, leave:
            form  
            with frame f-PS_Processo  color black/cyan centered  
            row 5 side-labels width 80 1 down.
            hide frame frame-a no-pause.
            if esqregua
            then do:                                   
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-PS_Processo side-labels
                on error undo.
                    find last bPS_Processo where
                              bPS_Processo.cod_item = Serv_produ.codigo
                              no-lock no-error.
                              
                    create PS_Processo.
                    assign PS_Processo.cod_item = Serv_produ.codigo.
                    find Serv_produ where
                         Serv_produ.codigo = PS_Processo.cod_item 
                         no-lock no-error.

                    disp PS_processo.Num_Processo format "x(30)" colon 20
                         PS_processo.Cod_Item     format "x(10)" colon 20
                         Serv_produ.descricao     format "x(35)" colon 30
                            no-label
                         PS_Processo.cod_parceiro format "x(10)" colon 20.
                         
                    update PS_processo.Num_Processo
                        validate( PS_processo.Num_Processo <> "",
                            "Numero do processo deve ser informado.").
                                    
                    do on error undo:
                       prompt-for PS_Processo.cod_parceiro.
                        
                        find first serv_forne where
                                   serv_forne.forcod =
                                   int(input PS_Processo.cod_parceiro)
                                   no-lock no-error.
                        if not avail serv_forne then do:
                            message "O participante informado nao esta"
                                    "cadastrado. Verifique."
                                    view-as alert-box .
                            undo.
                        end.
                    end.
                    find forne of Serv_forne no-lock no-error.
                    
                    disp forne.fornom format "x(35)" no-label colon 30.
                         
                            
                    if can-find(first bPS_processo where
                                      bPS_processo.Num_Processo = 
                                            PS_processo.Num_Processo and
                                      bPS_processo.Cod_Item =
                                            PS_processo.Cod_Item and
                                      bPS_Processo.cod_parceiro = 
                                            input PS_processo.cod_parceiro)
                    then do:
                        message "Numero do processo ja cadastrado. Verifique."
                                view-as alert-box.
                        undo.                                
                    end.                      
                     
                    
                    do on error undo, retry:
                        update PS_processo.Cod_Mun_IBGE  colon 20.

                        find munic where
                             munic.cidcod = int(PS_processo.Cod_Mun_IBGE)
                             no-lock no-error.
                        if not avail munic then do:
                            message "Municipio inexistente. Verifique."
                                    view-as alert-box.
                            undo, retry.
                        end.
                        disp munic.cidnom no-label format "X(30)".
                    end.                
                    
                    update PS_processo.Cod_Suspensao colon 20
                           PS_processo.Tipo_Processo colon 20.

                    PS_processo.ind_suspensao_nat = "92".
                    update PS_processo.ind_suspensao_nat.
                    
                    PS_Processo.cod_parceiro = input PS_Processo.cod_parceiro.
                    recatu1 = recid(PS_Processo).      
                    leave.                             
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-PS_Processo on error undo.
                    find PS_Processo where 
                         recid(PS_Processo) = recatu1 exclusive.
                         
                    disp PS_Processo.num_processo
                         PS_Processo.cod_item.
                    
                    find Serv_produ where 
                         Serv_produ.codigo = PS_Processo.cod_item no-lock.
                    disp Serv_produ.descricao format "x(10)".
                         

                    find forne where
                         forne.forcod = int(PS_Processo.cod_parceiro)
                         no-lock no-error.
                         
                    disp PS_Processo.cod_parceiro
                         forne.fornom format "x(35)" no-label colon 30.
                             

                    do on error undo, retry:
                        update PS_processo.Cod_Mun_IBGE.
                        
                        find first munic where
                                   munic.cidcod = int(PS_processo.Cod_Mun_IBGE)
                                   no-lock no-error.
                        if not avail munic then do:
                            message "Municipio inexistente. Verofique."
                                    view-as alert-box.
                            undo, retry.                                    
                        end.
                        disp munic.cidnom no-label format "X(30)".
                    end.
                    update PS_processo.Cod_Suspensao
                           PS_processo.Tipo_Processo.
                    update PS_processo.ind_suspensao_nat.
                end.
            end.
        end.
        if not esqvazio
        then do:
            disp PS_processo.Num_Processo   format "x(28)"
                 PS_processo.Cod_Item       format "x(8)"
                    column-label "Codigo!Item"
                 PS_processo.Cod_Parceiro   format "x(8)"
                    column-label "Codigo!Parceiro"
                 PS_processo.Cod_Mun_IBGE   format "zzzzzzzzz9"
                    column-label "Munic.IBGE"
                 PS_processo.Cod_Suspensao  format "x(13)"
                    column-label "Codigo!Suspensao"
                 PS_processo.Tipo_Processo  format "Adm./Jud."
                    column-label "Tipo!Proc."
                 with frame frame-a.
        end.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(PS_Processo).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.                           
