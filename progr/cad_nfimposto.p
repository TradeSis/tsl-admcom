/*
*
*    cad_nfimposto.p    -    Esqueleto de Programacao    com esqvazio
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
    initial [" Inclusao "," Alteracao "," Exclusao "," "," "].
def var esqcom2         as char format "x(15)" extent 5
    initial ["  "," ","","",""].
            
def var esqhel1         as char format "x(80)" extent 5
    initial [" Inclusao do Imposto",
             " Alteracao do Imposto ",
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


def buffer bNF_Serv_Imposto_Ret  for NF_Serv_Imposto_Ret.
def buffer bServ_forne         for Serv_forne.
def buffer bforne              for forne.


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

def var vcondicao-retencao as char.
def var vfinalidade-retencao as char.
def var vdescricao-observacao as char.

bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        if esqascend
        then
            find first NF_Serv_Imposto_Ret of NF_Serv_Itens
                       no-lock no-error.
        else
            find last  NF_Serv_Imposto_Ret of NF_Serv_Itens 
                       no-lock no-error.
    else
        find NF_Serv_Imposto_Ret where 
             recid(NF_Serv_Imposto_Ret) = recatu1 no-lock no-error.

    if not avail NF_Serv_Imposto_Ret
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then              
        run pi-frame-a. 

    recatu1 = recid(NF_Serv_Imposto_Ret).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        if esqascend
        then
            find next NF_Serv_Imposto_Ret of NF_Serv_Itens 
                      no-lock no-error.
        else
            find prev NF_Serv_Imposto_Ret of NF_Serv_Itens 
                      no-lock no-error.

        if not avail NF_Serv_Imposto_Ret
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
            
            find NF_Serv_Imposto_Ret where 
                 recid(NF_Serv_Imposto_Ret) = recatu1 no-lock no-error.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> "" then
                                  string(NF_Serv_Imposto_Ret.Cod_Imposto_Ret)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> "" then
                                  string(NF_Serv_Imposto_Ret.Cod_Imposto_Ret)
                                        else "".

            choose field NF_Serv_Imposto_Ret.Cod_Imposto_Ret help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return) .

            status default "".

        end.
        
        {esquema.i &tabela = "NF_Serv_Imposto_Ret"
                   &campo  = "NF_Serv_Imposto_Ret.Cod_Imposto_Ret"
        &where  = 
            "NF_Serv_Imposto_Ret.Cod_Estab  = NF_Serv_Itens.Cod_Estab and      
             NF_Serv_Imposto_Ret.Tipo_Operacao = NF_Serv_Itens.Tipo_Operacao and
             NF_Serv_Imposto_Ret.Cod_Modelo    = NF_Serv_Itens.Cod_Modelo and   
             NF_Serv_Imposto_Ret.Num_Docto     = NF_Serv_Itens.Num_Docto and    
             NF_Serv_Imposto_Ret.Num_Serie     = NF_Serv_Itens.Num_Serie and   
             NF_Serv_Imposto_Ret.Cod_Parceiro  = NF_Serv_Itens.Cod_Parceiro and
             NF_Serv_Imposto_Ret.Data_Emissao  = NF_Serv_Itens.Data_Emissao"
             NF_Serv_Imposto_Ret.Cod_Item      = NF_Serv_Itens.Cod_Item
                   &frame  = "frame-a"}

        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do on error undo, retry on endkey undo, leave:
            form  
            with frame f-NF_Serv_Imposto_Ret  color black/cyan centered  
            row 5 side-labels width 80 1 down.
            hide frame frame-a no-pause.
            if esqregua
            then do:                                   
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-NF_Serv_Imposto_Ret side-labels
                on error undo.
                    
                    pause 0.
                    disp NF_Serv_Itens.Num_Docto     colon 23
                         NF_Serv_Itens.Num_Serie     colon 55
                         NF_Serv_Itens.Data_Emissao  colon 23
                         NF_Serv_Itens.Tipo_Operacao colon 55
                         NF_Serv_Itens.Cod_Modelo    colon 23
                         NF_Serv_Itens.Cod_Estab     colon 55
                         NF_Serv_Itens.Cod_Parceiro  colon 23
                            format "x(10)".
                    find Serv_forne where 
                         Serv_forne.forcod = 
                         int(NF_Serv_Itens.Cod_Parceiro) no-lock no-error.
                    find forne of Serv_forne no-lock no-error.
                    disp forne.fornom at 35 no-label format "X(30)".
                         
                         
                    disp NF_Serv_Itens.Cod_item colon 23
                            format "X(10)"
                         NF_Serv_Itens.Desc_Compl at 35 
                         no-label format "X(30)".
                    
                    prompt-for NF_Serv_Imposto_Ret.Cod_Receita colon 23
                     validate(input NF_Serv_Imposto_Ret.Cod_Receita <> "",
                        "Cod. Receita invalido.").
                    
                    if can-find (first NF_Serv_Imposto_Ret where
                                       NF_Serv_Imposto_Ret.Num_Docto =
                                       NF_Serv_Itens.Num_Docto and
                                       NF_Serv_Imposto_Ret.Num_Serie =
                                       NF_Serv_Itens.Num_Serie and
                                       NF_Serv_Imposto_Ret.Data_Emissao =
                                       NF_Serv_Itens.Data_Emissao and
                                       NF_Serv_Imposto_Ret.Tipo_Operacao =
                                       NF_Serv_Itens.Tipo_Operacao and
                                       NF_Serv_Imposto_Ret.Cod_Modelo =
                                       NF_Serv_Itens.Cod_Modelo and
                                       NF_Serv_Imposto_Ret.Cod_Item = 
                                       NF_Serv_Itens.Cod_Item and
                                       NF_Serv_Imposto_Ret.Cod_Receita = 
                                       input NF_Serv_Imposto_Ret.Cod_Receita)
                    then do:
                        message "Imposto ja cadastrado para este item. "
                                "Verifique."
                                view-as alert-box.
                        undo.
                    end.
                    /*
                    prompt-for NF_Serv_Imposto_Ret.Cod_Empresa colon 23
                        format "x(50)"
                        validate(input NF_Serv_Imposto_Ret.Cod_Empresa <> "",
                        "Cod. Empresa invalido.").                             
                    */    
                    prompt-for NF_Serv_Imposto_Ret.Num_item colon 23 
                        validate(input NF_Serv_Imposto_Ret.Num_item <> 0,
                        "Numero do item invalido.").
                        
                    vdataes = NF_Serv_Itens.Data_ES.
                    disp vdataes.
                    prompt-for vdataes
                               /*NF_Serv_Imposto_Ret.Data_ES*/ colon 55
                               NF_Serv_Imposto_Ret.Cod_Imposto colon 23
                                format "x(10)"
                               NF_Serv_Imposto_Ret.Var_Cod_Receita colon 55
                               NF_Serv_Imposto_Ret.Data_Pagto colon 23.

                    prompt-for NF_Serv_Imposto_Ret.Tipo_Repasse colon 55
                    with frame f-NF_Serv_Imposto_Ret no-validate.

                    prompt-for NF_Serv_Imposto_Ret.Valor_Ret        colon 23
                               NF_Serv_Imposto_Ret.Aliquota_Ret     colon 23
                               NF_Serv_Imposto_Ret.Val_Base_Ret     colon 23
                               NF_Serv_Imposto_Ret.Val_Alim         colon 23   
                               NF_Serv_Imposto_Ret.val_Apos15       colon 23
                               NF_Serv_Imposto_Ret.Val_Apos20       colon 23   
                               NF_Serv_Imposto_Ret.Val_Apos25       colon 23   
                               /*
                               NF_Serv_Imposto_Ret.Val_Cont_Gil     colon 23    
                               NF_Serv_Imposto_Ret.Val_Cont_Prev    colon 23    
                               NF_Serv_Imposto_Ret.Val_Cont_Senar   colon 23   
                               */
                               NF_Serv_Imposto_Ret.Val_Dep_Jud      colon 23   
                               NF_Serv_Imposto_Ret.Val_Dep_Jud_R    colon 23   
                                 label "Val.Dep.Judicial Ret." 
                               NF_Serv_Imposto_Ret.Val_Mat_Equip    colon 23    
                               /*
                               NF_Serv_Imposto_Ret.Val_Nao_Ret_Ad   colon 23   
                                label  "Val.Nao Retido Adic."
                               NF_Serv_Imposto_Ret.Val_Nao_Ret_PR   colon 23   
                                label  "Val.Nao Retido Princ."
                               */
                               NF_Serv_Imposto_Ret.Val_Nao_Out_Desp colon 23
                               NF_Serv_Imposto_Ret.Val_Ret_Ad15     colon 23    
                               NF_Serv_Imposto_Ret.Val_Ret_Ad20     colon 23   
                               NF_Serv_Imposto_Ret.Val_Ret_Ad25     colon 23    
                               NF_Serv_Imposto_Ret.Val_Ret_Sub      colon 23
                                   label "Val.Ret.SubContratadas"
                               NF_Serv_Imposto_Ret.Val_Transp       colon 23
                               .  
                    vcondicao-retencao = "R".
                    vfinalidade-retencao = "E".
                    vdescricao-observacao = "Servico".

                    prompt-for 
                    NF_Serv_Imposto_Ret.aliq_contri_adicional     colon 23
                    NF_Serv_Imposto_Ret.aliq_contrib_sistema      colon 23
                    .
                    disp vcondicao-retencao
                         vfinalidade-retencao.

                    prompt-for
                    vcondicao-retencao
                    /*NF_Serv_Imposto_Ret.condicao_retencao*/     colon 23
                    vfinalidade-retencao
                    /*NF_Serv_Imposto_Ret.finalidade_retencao*/   colon 23
                    NF_Serv_Imposto_Ret.valor_contrib_adicional   colon 23
                    NF_Serv_Imposto_Ret.valor_contrib_sistema     colon 23
                    .
                    
                    disp vdescricao-observacao.
                    
                    prompt-for
                    vdescricao-observacao
                    /*NF_Serv_Imposto_Ret.descricao_observacao*/  colon 23
                                format "x(50)"
                                .
                    
                    
                    create NF_Serv_Imposto_Ret.
                    assign 
                 NF_Serv_Imposto_Ret.Num_Docto     = NF_Serv_Itens.Num_Docto  
                 NF_Serv_Imposto_Ret.Cod_Modelo    = NF_Serv_Itens.Cod_Modelo
                 NF_Serv_Imposto_Ret.Cod_Estab     = NF_Serv_Itens.Cod_Estab
                 NF_Serv_Imposto_Ret.Num_Serie     = NF_Serv_Itens.Num_Serie 
                 NF_Serv_Imposto_Ret.Cod_Item      = NF_Serv_Itens.Cod_Item
                 NF_Serv_Imposto_Ret.Data_Emissao  = NF_Serv_Itens.Data_Emissao
                 NF_Serv_Imposto_Ret.Tipo_Operacao = NF_Serv_Itens.Tipo_Operacao
                 NF_Serv_Imposto_Ret.Cod_Parceiro  = NF_Serv_Itens.Cod_Parceiro
                 NF_Serv_Imposto_Ret.Cod_Imposto_Ret
                 NF_Serv_Imposto_Ret.Cod_Empresa = "001"
                 NF_Serv_Imposto_Ret.Num_item  
                 NF_Serv_Imposto_Ret.Data_ES = input vdataes
                 NF_Serv_Imposto_Ret.Cod_Receita
                 NF_Serv_Imposto_Ret.Var_Cod_Receita 
                 NF_Serv_Imposto_Ret.Data_Pagto 
                 NF_Serv_Imposto_Ret.Tipo_Repasse 
                 NF_Serv_Imposto_Ret.Valor_Ret
                 NF_Serv_Imposto_Ret.Val_Base_Ret
                 NF_Serv_Imposto_Ret.Aliquota_Ret
                 NF_Serv_Imposto_Ret.Val_Alim
                 NF_Serv_Imposto_Ret.val_Apos15
                 NF_Serv_Imposto_Ret.Val_Apos20
                 NF_Serv_Imposto_Ret.Val_Apos25
                 /*
                 NF_Serv_Imposto_Ret.Val_Cont_Gil
                 NF_Serv_Imposto_Ret.Val_Cont_Prev
                 NF_Serv_Imposto_Ret.Val_Cont_Senar
                 */
                 NF_Serv_Imposto_Ret.Val_Dep_Jud
                 NF_Serv_Imposto_Ret.Val_Dep_Jud_R
                 NF_Serv_Imposto_Ret.Val_Mat_Equip
                 /*
                 NF_Serv_Imposto_Ret.Val_Nao_Ret_Ad
                 NF_Serv_Imposto_Ret.Val_Nao_Ret_PR
                 */
                 NF_Serv_Imposto_Ret.Val_Nao_Out_Desp
                 NF_Serv_Imposto_Ret.Val_Ret_Ad15
                 NF_Serv_Imposto_Ret.Val_Ret_Ad20
                 NF_Serv_Imposto_Ret.Val_Ret_Ad25
                 NF_Serv_Imposto_Ret.Val_Ret_Sub
                 NF_Serv_Imposto_Ret.Val_Transp
                 NF_Serv_Imposto_Ret.aliq_contri_adicional
                    NF_Serv_Imposto_Ret.aliq_contrib_sistema
                    NF_Serv_Imposto_Ret.condicao_retencao = 
                                input vcondicao-retencao
                    NF_Serv_Imposto_Ret.descricao_observacao =
                                                input vdescricao-observacao
                    NF_Serv_Imposto_Ret.finalidade_retencao =                                                 input vfinalidade-retencao
                    NF_Serv_Imposto_Ret.valor_contrib_adicional
                    NF_Serv_Imposto_Ret.valor_contrib_sistema

                 .
                    
                    recatu1 = recid(NF_Serv_Imposto_Ret).      
                    leave.
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-NF_Serv_Imposto_Ret on error undo.
                    find NF_Serv_Imposto_Ret where 
                         recid(NF_Serv_Imposto_Ret) = recatu1 exclusive.
                         
                    disp NF_Serv_Itens.Num_Docto     colon 23
                         NF_Serv_Itens.Num_Serie     colon 55
                         NF_Serv_Itens.Data_Emissao  colon 23
                         NF_Serv_Itens.Tipo_Operacao colon 55
                         NF_Serv_Itens.Cod_Modelo    colon 23
                         NF_Serv_Itens.Cod_Estab     colon 55
                         NF_Serv_Itens.Cod_Parceiro  colon 23.
                    
                    find Serv_forne where
                         Serv_forne.forcod =
                         int(NF_Serv_Imposto_Ret.Cod_Parceiro)
                         no-lock no-error.
                    find forne of Serv_forne no-lock no-error.
                    disp forne.fornom at 35 no-label format "X(30)".
                    
                    disp NF_Serv_Itens.Cod_item colon 23
                            format "X(10)"
                         NF_Serv_Itens.Desc_Compl at 35
                            no-label format "X(30)"
                         NF_Serv_Imposto_Ret.Cod_Receita colon 23
                         /*NF_Serv_Imposto_Ret.Cod_empresa colon 23
                            format "x(50)"
                         NF_Serv_Imposto_Ret.Num_item colon 55
                         NF_Serv_Imposto_Ret.Data_ES colon 55
                         NF_Serv_Imposto_Ret.Cod_Empresa colon 23
                         */
                         NF_Serv_Imposto_Ret.Num_item colon 23.
                         
                    vdataes = NF_Serv_Itens.Data_ES.     
                    disp vdataes /*NF_Serv_Imposto_Ret.Data_ES*/ colon 55
                         NF_Serv_Imposto_Ret.Cod_Imposto_Ret colon 23
                            format "x(10)"
                         NF_Serv_Imposto_Ret.Var_Cod_Receita colon 55
                         NF_Serv_Imposto_Ret.Data_Pagto colon 23
                         NF_Serv_Imposto_Ret.Tipo_Repasse colon 55
                         NF_Serv_Imposto_Ret.Valor_Ret colon 23
                         NF_Serv_Imposto_Ret.Aliquota_Ret     colon 23
                         NF_Serv_Imposto_Ret.Val_Base_Ret     colon 23
                         NF_Serv_Imposto_Ret.Val_Alim         colon 23
                         NF_Serv_Imposto_Ret.val_Apos15       colon 23
                         NF_Serv_Imposto_Ret.Val_Apos20       colon 23
                         NF_Serv_Imposto_Ret.Val_Apos25       colon 23
                         NF_Serv_Imposto_Ret.Val_Cont_Gil     colon 23
                         NF_Serv_Imposto_Ret.Val_Cont_Prev    colon 23
                         NF_Serv_Imposto_Ret.Val_Cont_Senar   colon 23
                         NF_Serv_Imposto_Ret.Val_Dep_Jud      colon 23
                         NF_Serv_Imposto_Ret.Val_Dep_Jud_R    colon 23
                           label "Val.Dep.Judicial Ret."
                         NF_Serv_Imposto_Ret.Val_Mat_Equip    colon 23
                         NF_Serv_Imposto_Ret.Val_Nao_Ret_Ad   colon 23
                           label  "Val.Nao Retido Adic."
                         NF_Serv_Imposto_Ret.Val_Nao_Ret_PR   colon 23
                           label  "Val.Nao Retido Princ."
                         NF_Serv_Imposto_Ret.Val_Nao_Out_Desp colon 23
                         NF_Serv_Imposto_Ret.Val_Ret_Ad15     colon 23
                         NF_Serv_Imposto_Ret.Val_Ret_Ad20     colon 23
                         NF_Serv_Imposto_Ret.Val_Ret_Ad25     colon 23
                         NF_Serv_Imposto_Ret.Val_Ret_Sub      colon 23
                           label "Val.Ret.SubContratadas"
                         NF_Serv_Imposto_Ret.Val_Transp       colon 23.
                   
                    prompt-for NF_Serv_Imposto_Ret.Cod_Receita .
                      
                     /*
                     prompt-for NF_Serv_Imposto_Ret.Cod_Empresa colon 23
                         format "x(50)"
                        validate(input NF_Serv_Imposto_Ret.Cod_Empresa <> "",
                        "Cod. Empresa invalido.").
                     */
                    prompt-for NF_Serv_Imposto_Ret.Num_item colon 23
                        validate(input NF_Serv_Imposto_Ret.Num_item <> 0,
                        "Numero do item invalido.").
                    disp vdataes.
                    prompt-for vdataes /*NF_Serv_Imposto_Ret.Data_ES*/ colon 55
                               NF_Serv_Imposto_Ret.Cod_Imposto_Ret colon 23
                               NF_Serv_Imposto_Ret.Var_Cod_Receita colon 55
                               NF_Serv_Imposto_Ret.Data_Pagto colon 23.
                               
                    prompt-for NF_Serv_Imposto_Ret.Tipo_Repasse colon 55.

                    prompt-for NF_Serv_Imposto_Ret.Valor_Ret colon 23
                               NF_Serv_Imposto_Ret.Aliquota_Ret     colon 23
                               NF_Serv_Imposto_Ret.Val_Base_Ret     colon 23
                               NF_Serv_Imposto_Ret.Val_Alim         colon 23   
                               NF_Serv_Imposto_Ret.val_Apos15       colon 23
                               NF_Serv_Imposto_Ret.Val_Apos20       colon 23   
                               NF_Serv_Imposto_Ret.Val_Apos25       colon 23   
                               /*
                               NF_Serv_Imposto_Ret.Val_Cont_Gil     colon 23    
                               NF_Serv_Imposto_Ret.Val_Cont_Prev    colon 23    
                               NF_Serv_Imposto_Ret.Val_Cont_Senar   colon 23   
                               */
                               NF_Serv_Imposto_Ret.Val_Dep_Jud      colon 23   
                               NF_Serv_Imposto_Ret.Val_Dep_Jud_R    colon 23   
                                 label "Val.Dep.Judicial Ret." 
                               NF_Serv_Imposto_Ret.Val_Mat_Equip    colon 23    
                               /*
                               NF_Serv_Imposto_Ret.Val_Nao_Ret_Ad   colon 23   
                                label  "Val.Nao Retido Adic."
                               NF_Serv_Imposto_Ret.Val_Nao_Ret_PR   colon 23   
                                label  "Val.Nao Retido Princ."
                               */
                               NF_Serv_Imposto_Ret.Val_Nao_Out_Desp colon 23
                               NF_Serv_Imposto_Ret.Val_Ret_Ad15     colon 23    
                               NF_Serv_Imposto_Ret.Val_Ret_Ad20     colon 23   
                               NF_Serv_Imposto_Ret.Val_Ret_Ad25     colon 23    
                               NF_Serv_Imposto_Ret.Val_Ret_Sub      colon 23
                                   label "Val.Ret.SubContratadas"
                               NF_Serv_Imposto_Ret.Val_Transp       colon 23.  


                    prompt-for
                    NF_Serv_Imposto_Ret.aliq_contri_adicional     colon 25
                    NF_Serv_Imposto_Ret.aliq_contrib_sistema      colon 25
                    NF_Serv_Imposto_Ret.condicao_retencao         colon 25
                    NF_Serv_Imposto_Ret.finalidade_retencao       colon 25
                    NF_Serv_Imposto_Ret.valor_contrib_adicional   colon 25
                    NF_Serv_Imposto_Ret.valor_contrib_sistema     colon 25
                    NF_Serv_Imposto_Ret.descricao_observacao    colon 25
                                format "x(50)"
                                .

                    
                    assign NF_Serv_Imposto_Ret.Cod_Empresa = "001"
                           NF_Serv_Imposto_Ret.Num_item
                           NF_Serv_Imposto_Ret.Data_ES = input vdataes
                           NF_Serv_Imposto_Ret.Cod_Receita
                           NF_Serv_Imposto_Ret.Cod_Imposto_Ret
                           NF_Serv_Imposto_Ret.Var_Cod_Receita
                           NF_Serv_Imposto_Ret.Data_Pagto
                           NF_Serv_Imposto_Ret.Tipo_Repasse
                           NF_Serv_Imposto_Ret.Valor_Ret
                           NF_Serv_Imposto_Ret.Val_Base_Ret
                           NF_Serv_Imposto_Ret.Aliquota_Ret
                           NF_Serv_Imposto_Ret.Val_Alim
                           NF_Serv_Imposto_Ret.val_Apos15
                           NF_Serv_Imposto_Ret.Val_Apos20
                           NF_Serv_Imposto_Ret.Val_Apos25
                           /*
                           NF_Serv_Imposto_Ret.Val_Cont_Gil
                           NF_Serv_Imposto_Ret.Val_Cont_Prev
                           NF_Serv_Imposto_Ret.Val_Cont_Senar
                           */
                           NF_Serv_Imposto_Ret.Val_Dep_Jud
                           NF_Serv_Imposto_Ret.Val_Dep_Jud_R
                           NF_Serv_Imposto_Ret.Val_Mat_Equip
                           /*
                           NF_Serv_Imposto_Ret.Val_Nao_Ret_Ad
                           NF_Serv_Imposto_Ret.Val_Nao_Ret_PR
                           */
                           NF_Serv_Imposto_Ret.Val_Nao_Out_Desp
                           NF_Serv_Imposto_Ret.Val_Ret_Ad15
                           NF_Serv_Imposto_Ret.Val_Ret_Ad20
                           NF_Serv_Imposto_Ret.Val_Ret_Ad25
                           NF_Serv_Imposto_Ret.Val_Ret_Sub
                           NF_Serv_Imposto_Ret.Val_Transp
                           NF_Serv_Imposto_Ret.aliq_contrib_sistema
                    NF_Serv_Imposto_Ret.condicao_retencao
                    NF_Serv_Imposto_Ret.descricao_observacao
                    NF_Serv_Imposto_Ret.finalidade_retencao
                    NF_Serv_Imposto_Ret.valor_contrib_adicional
                    NF_Serv_Imposto_Ret.valor_contrib_sistema

                           .
                end.
                if esqcom1[esqpos1] = " Exclusao "
                then do:
                    sresp = no.
                    message "Confirma excluir registro?" update sresp.
                    if sresp
                    then do on error undo:
                        find NF_Serv_Imposto_Ret where
                              recid(NF_Serv_Imposto_Ret) = recatu1 exclusive.
                        if avail NF_Serv_Imposto_Ret
                        then delete NF_Serv_Imposto_Ret.
                    end.
                end.          
            end.
        end.
        if not esqvazio
        then 
            run pi-frame-a. 

        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(NF_Serv_Imposto_Ret).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.        
                    
procedure pi-frame-a:
    disp NF_Serv_Imposto_Ret.Cod_Imposto_Ret format "x(10)" 
            column-label "Cod.!Imposto"
         NF_Serv_Imposto_Ret.cod_item format "x(10)" column-label "Cod.Item"
         NF_Serv_Imposto_Ret.Num_Docto
         NF_Serv_Imposto_Ret.Num_Serie column-label "Num.!Serie" format "x(4)"
         NF_Serv_Imposto_Ret.Data_Emissao column-label "Data!Emissao"
         NF_Serv_Imposto_Ret.Cod_Parceiro column-label "Codigo!Parceiro"
           format "x(8)"
         NF_Serv_Imposto_Ret.Cod_Estab format "x(8)" column-label "Cod.!Estab"
        (if string(NF_Serv_Imposto_Ret.Tipo_Operacao) = "0" then "0-Ent"
         else "1-Sai") column-label "Tipo!Oper" format "x(5)"
         NF_Serv_Imposto_Ret.Cod_Modelo column-label "Cod.!Mod." format "x(4)"
         with frame frame-a 11 down centered row 5 width 80
         title " Impostos Retidos do item " +
         string(NF_Serv_Imposto_Ret.Cod_Item) + " ".
end procedure.                  
