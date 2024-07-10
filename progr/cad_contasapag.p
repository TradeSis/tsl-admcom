/*
*
*    cad_contasapag.p    -    Esqueleto de Programacao    com esqvazio
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
def var esqcom2         as char format "x(15)" extent 5
    initial ["  "," ","","",""].
            
def var esqhel1         as char format "x(80)" extent 5
    initial [" Inclusao do Contas a pagar",
             " Alteracao do Contas a pagar  ",
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

def input param par-rec as recid.

def var vdataes like NF_Serv_Itens.Data_ES.

find NF_Serv_Itens where recid(NF_Serv_Itens) = par-rec no-lock no-error.


bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        if esqascend
        then
            find first NF_Serv_CPG of NF_Serv_Itens where
                       NF_Serv_CPG.cod_Item = NF_Serv_Itens.Cod_Item
                       no-lock no-error.
        else
            find last  NF_Serv_CPG of NF_Serv_Itens where
                       NF_Serv_CPG.cod_Item = NF_Serv_Itens.Cod_Item
                       no-lock no-error.
    else
        find NF_Serv_CPG where 
             recid(NF_Serv_CPG) = recatu1 no-lock no-error.

    if not avail NF_Serv_CPG
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then              
        run pi-frame-a. 

    recatu1 = recid(NF_Serv_CPG).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        if esqascend
        then
            find next NF_Serv_CPG of NF_Serv_Itens where
                      NF_Serv_CPG.cod_Item = NF_Serv_Itens.Cod_Item
                      no-lock no-error.
        else
            find prev NF_Serv_CPG of NF_Serv_Itens where
                      NF_Serv_CPG.cod_Item = NF_Serv_Itens.Cod_Item
                      no-lock no-error.

        if not avail NF_Serv_CPG
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        
        run pi-frame-a.
    end.
    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        if not esqvazio
        then do:
            
            find NF_Serv_CPG where 
                 recid(NF_Serv_CPG) = recatu1 no-lock no-error.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then 
                                        string(NF_Serv_CPG.Num_Docto_PR)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                   then string(NF_Serv_CPG.Num_Docto_PR)
                                   else "".

            choose field NF_Serv_CPG.Num_Docto_PR help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return) .

            status default "".

        end.
        
        {esquema.i &tabela = "NF_Serv_CPG"
                   &campo  = "NF_Serv_CPG.Num_Docto_PR"
        &where  = 
            "NF_Serv_CPG.Cod_Estab  = NF_Serv_Itens.Cod_Estab and        
             NF_Serv_CPG.Tipo_Operacao = NF_Serv_Itens.Tipo_Operacao and
             NF_Serv_CPG.Cod_Modelo    = NF_Serv_Itens.Cod_Modelo and   
             NF_Serv_CPG.Num_Docto     = NF_Serv_Itens.Num_Docto and    
             NF_Serv_CPG.Num_Serie     = NF_Serv_Itens.Num_Serie and   
             NF_Serv_CPG.Cod_Parceiro  = NF_Serv_Itens.Cod_Parceiro and
             NF_Serv_CPG.Data_Emissao  = NF_Serv_Itens.Data_Emissao"
             NF_Serv_CPG.Cod_Item      = NF_Serv_Itens.Cod_Item
                   &frame  = "frame-a"}

        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do on error undo, retry on endkey undo, leave:
            form  
            with frame f-NF_Serv_CPG  color black/cyan centered  
            row 5 side-labels width 80 1 down.
            hide frame frame-a no-pause.
            if esqregua
            then do:                                   
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-NF_Serv_CPG side-labels
                on error undo.
                    
                    disp NF_Serv_Itens.Num_Docto     colon 23
                         NF_Serv_Itens.Num_Serie     colon 55
                         NF_Serv_Itens.Data_Emissao  colon 23
                         NF_Serv_Itens.Tipo_Operacao colon 55
                         NF_Serv_Itens.Cod_Modelo    colon 23
                         NF_Serv_Itens.Cod_Estab     colon 55
                         NF_Serv_Itens.Cod_Parceiro  colon 23
                            format "x(10)".
                    vdataes = NF_Serv_Itens.Data_ES.
                    find Serv_forne where 
                         Serv_forne.forcod = 
                         int(NF_Serv_Itens.Cod_Parceiro) no-lock no-error.
                    find forne of Serv_forne no-lock no-error.
                    disp forne.fornom at 30 no-label format "X(40)".
                         
                         
                    disp NF_Serv_Itens.Cod_item colon 23
                            format "X(10)"
                         NF_Serv_Itens.Desc_Compl at 30 
                         no-label format "X(40)".
                    
                    prompt-for NF_Serv_CPG.Num_Docto_PR colon 23
                        format "X(10)"
                        validate(input NF_Serv_CPG.Num_Docto_PR <> "",
                            "Num. Docto. PR invalido.").

                    prompt-for NF_Serv_CPG.Tipo_Operacao_PR colon 55
                         label "Tipo.Oper.Pag.Rec."
                         validate(input NF_Serv_CPG.Tipo_Operacao_PR <> "",
                         "Tipo Operacao PR. invalido.").
                         
                    prompt-for NF_Serv_CPG.Num_Parcela_PR colon 23
                        validate(input NF_Serv_CPG.Num_Parcela_PR <> 0,
                         "Num. Parcela PR invalida.").
                    
                    if can-find (first NF_Serv_CPG where
                                       NF_Serv_CPG.Num_Docto =
                                       NF_Serv_Itens.Num_Docto and
                                       NF_Serv_CPG.Num_Serie =
                                       NF_Serv_Itens.Num_Serie and
                                       NF_Serv_CPG.Data_Emissao =
                                       NF_Serv_Itens.Data_Emissao and
                                       NF_Serv_CPG.Tipo_Operacao =
                                       NF_Serv_Itens.Tipo_Operacao and
                                       NF_Serv_CPG.Cod_Modelo =
                                       NF_Serv_Itens.Cod_Modelo and
                                       NF_Serv_CPG.Cod_Item = 
                                       NF_Serv_Itens.Cod_Item and
                                       NF_Serv_CPG.Num_Docto_PR = 
                                       input NF_Serv_CPG.Num_Docto_PR and      
                                       NF_Serv_CPG.Num_Parcela_PR =      
                                       input NF_Serv_CPG.Num_Parcela_PR and
                                       NF_Serv_CPG.Tipo_Operacao_PR = 
                                       input NF_Serv_CPG.Tipo_Operacao_PR)
                    then do:
                        message "Contas a Pagar ja cadastrada para este item. "
                                "Verifique."
                                view-as alert-box.
                        undo.
                    end.
                    
                    
                    prompt-for NF_Serv_CPG.Tipo_Docto_PR colon 55.
                    prompt-for NF_Serv_CPG.Tipo_Conta_PR colon 23.
                    prompt-for NF_Serv_CPG.Data_Operacao_PR colon 55.
                    disp vdataes.
                    prompt-for vdataes /*NF_Serv_CPG.Data_ES*/ colon 23.

                    
                    create NF_Serv_CPG.
                    assign 
                   NF_Serv_CPG.Num_Docto     = NF_Serv_Itens.Num_Docto  
                   NF_Serv_CPG.Cod_Modelo    = NF_Serv_Itens.Cod_Modelo
                   NF_Serv_CPG.Cod_Estab     = NF_Serv_Itens.Cod_Estab
                   NF_Serv_CPG.Num_Serie     = NF_Serv_Itens.Num_Serie 
                   NF_Serv_CPG.Cod_Item      = NF_Serv_Itens.Cod_Item
                   NF_Serv_CPG.Data_Emissao  = NF_Serv_Itens.Data_Emissao
                   NF_Serv_CPG.Tipo_Operacao = NF_Serv_Itens.Tipo_Operacao
                   NF_Serv_CPG.Cod_Parceiro  = NF_Serv_Itens.Cod_Parceiro
                   NF_Serv_CPG.Tipo_Operacao_PR
                   NF_Serv_CPG.Num_Docto_PR 
                   NF_Serv_CPG.Num_Parcela_PR
                   NF_Serv_CPG.Tipo_Docto_PR 
                   NF_Serv_CPG.Tipo_Conta_PR 
                   NF_Serv_CPG.Data_Operacao_PR
                   NF_Serv_CPG.Data_ES = input vdataes. 
                   
                    
                    recatu1 = recid(NF_Serv_CPG).      
                    leave.
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-NF_Serv_CPG on error undo.
                    find NF_Serv_CPG where 
                         recid(NF_Serv_CPG) = recatu1 exclusive.
                         
                    disp NF_Serv_Itens.Num_Docto     colon 23
                         NF_Serv_Itens.Num_Serie     colon 55
                         NF_Serv_Itens.Data_Emissao  colon 23
                         NF_Serv_Itens.Tipo_Operacao colon 55
                         NF_Serv_Itens.Cod_Modelo    colon 23
                         NF_Serv_Itens.Cod_Estab     colon 55
                         NF_Serv_Itens.Cod_Parceiro  colon 23.
                    
                    find Serv_forne where
                         Serv_forne.forcod =
                         int(NF_Serv_CPG.Cod_Parceiro)
                         no-lock no-error.
                    find forne of Serv_forne no-lock no-error.
                    disp forne.fornom at 35 no-label format "X(30)".
                    
                    vdataes = NF_Serv_CPG.Data_ES.
                    
                    disp NF_Serv_Itens.Cod_item colon 23  format "X(10)"
                         NF_Serv_Itens.Desc_Compl at 35
                            no-label format "X(30)"
                         NF_Serv_CPG.Num_Docto_PR colon 23 format "X(10)"
                         NF_Serv_CPG.Tipo_Operacao_PR colon 55
                          label "Tipo.Oper.Pag.Rec."
                         NF_Serv_CPG.Num_Parcela_PR colon 23
                         NF_Serv_CPG.Tipo_Docto_PR colon 55
                         NF_Serv_CPG.Tipo_Conta_PR colon 23
                         NF_Serv_CPG.Data_Operacao_PR colon 55
                         vdataes /*NF_Serv_CPG.Data_ES*/ colon 23.
                         
                    prompt-for NF_Serv_CPG.Tipo_Docto_PR colon 55.
                    prompt-for NF_Serv_CPG.Tipo_Conta_PR colon 23.
                    prompt-for NF_Serv_CPG.Data_Operacao_PR colon 55.
                    prompt-for vdataes /*NF_Serv_CPG.Data_ES*/ colon 23.
                    
                    assign NF_Serv_CPG.Data_ES  = input vdataes
                           NF_Serv_CPG.Tipo_Docto_PR 
                           NF_Serv_CPG.Tipo_Conta_PR                           
                           NF_Serv_CPG.Data_Operacao_PR.
                end.

            end.
        end.
        if not esqvazio
        then 
            run pi-frame-a. 

        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(NF_Serv_CPG).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.        
                    
procedure pi-frame-a:
    disp NF_Serv_CPG.Num_Docto_PR format "x(10)" column-label "Num.Docto!PR."
         NF_Serv_CPG.Num_Parcela_PR column-label "Parc!PR." format "zz9"
        (if string(NF_Serv_CPG.Tipo_Operacao_PR) = "0" then "0-E"
         else "1-S") column-label "Oper!PR." format "x(3)"
         NF_Serv_CPG.cod_item format "x(8)" column-label "Cod.Item"
         NF_Serv_CPG.Num_Docto format "zzzzzzzzz9" column-label "Num.Docto"
         NF_Serv_CPG.Num_Serie column-label "Ser" format "x(4)"
         NF_Serv_CPG.Data_Emissao column-label "Data!Emissao" 
         format "99/99/99"
         NF_Serv_CPG.Cod_Parceiro column-label "Cod.!Parc."
           format "x(6)"
         NF_Serv_CPG.Cod_Estab format "x(5)" column-label "Estab"
        (if string(NF_Serv_CPG.Tipo_Operacao) = "0" then "0-E"
         else "1-S") column-label "Tipo!Oper" format "x(3)"
         NF_Serv_CPG.Cod_Modelo column-label "Cod.!Mod." format "x(4)"
         with frame frame-a 11 down centered row 5 width 80
         title " Contas a Pagar do item " +
         string(NF_Serv_CPG.Cod_Item) + " ".
end procedure.                  
