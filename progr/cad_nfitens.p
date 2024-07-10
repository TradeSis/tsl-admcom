/*
*
*    cad_nfitens.p    -    Esqueleto de Programacao    com esqvazio
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
    initial ["Impostos Retido","   Processos   ","Contas a Pagar","",""].
            
def var esqhel1         as char format "x(80)" extent 5
    initial [" Inclusao do Item",
             " Alteracao do Item ",
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


def var vmod-ctb like titulo.modcod.
def var vmod-nom like modal.modnom.
def buffer bNF_Serv_Itens  for NF_Serv_Itens.


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

def var vmov_item like NF_Serv_Itens.Movimenta_Item.
def var vdataes like NF_Serv_Itens.Data_ES.

def var vcfop like serv_produ.cfop.

find NF_Serv_Capa where recid(NF_Serv_Capa) = par-rec no-lock no-error.


bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        if esqascend
        then
            find first NF_Serv_Itens of NF_Serv_Capa   
                       no-lock no-error.
        else
            find last  NF_Serv_Itens of NF_Serv_Capa
                      no-lock no-error.
    else
        find NF_Serv_Itens where 
             recid(NF_Serv_Itens) = recatu1 no-lock no-error.

    if not avail NF_Serv_Itens
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then              
        run pi-frame-a. 

    recatu1 = recid(NF_Serv_Itens).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        if esqascend
        then
            find next NF_Serv_Itens of NF_Serv_Capa
                      no-lock no-error.
        else
            find prev NF_Serv_Itens of NF_Serv_Capa
                      no-lock no-error.

        if not avail NF_Serv_Itens
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
            
            find NF_Serv_Itens where 
                 recid(NF_Serv_Itens) = recatu1 no-lock no-error.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then 
                                        string(NF_Serv_Itens.Cod_Item)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(NF_Serv_Itens.Cod_Item)
                                        else "".

            choose field NF_Serv_Itens.Cod_Item help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return) .

            status default "".

        end.
        
        {esquema.i &tabela = "NF_Serv_Itens"
                   &campo  = "NF_Serv_Itens.Cod_Item"
        &where  = "NF_Serv_Itens.Cod_Estab     = NF_Serv_Capa.Cod_Estab and   
                   NF_Serv_Itens.Tipo_Operacao = NF_Serv_Capa.Tipo_Operacao and
                   NF_Serv_Itens.Cod_Modelo    = NF_Serv_Capa.Cod_Modelo and   
                   NF_Serv_Itens.Num_Docto     = NF_Serv_Capa.Num_Docto and    
                   NF_Serv_Itens.Num_Serie     = NF_Serv_Capa.Num_Serie and   
                   NF_Serv_Itens.Cod_Parceiro  = NF_Serv_Capa.Cod_Parceiro and
                   NF_Serv_Itens.Data_Emissao  = NF_Serv_Capa.Data_Emissao"
                   &frame  = "frame-a"}

        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do on error undo, retry on endkey undo, leave:
            form  
            with frame f-NF_Serv_Itens  color black/cyan centered  
            row 5 side-labels width 80 1 down.
            hide frame frame-a no-pause.
            if esqregua
            then do :                                   
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-NF_Serv_Itens side-labels
                on error undo: 
                    disp NF_Serv_Capa.Num_Docto     colon 16
                         NF_Serv_Capa.Num_Serie     colon 55
                         NF_Serv_Capa.Data_Emissao  colon 16
                         NF_Serv_Capa.Tipo_Operacao colon 55
                         NF_Serv_Capa.Cod_Modelo    colon 16
                         NF_Serv_Capa.Cod_Estab     colon 55
                         NF_Serv_Capa.Cod_Parceiro  colon 16
                            format "x(10)".
                    find Serv_forne where 
                         Serv_forne.forcod = 
                         int(NF_Serv_Capa.Cod_Parceiro) no-lock no-error.
                    find forne of Serv_forne no-lock no-error.
                    disp forne.fornom at 30 no-label format "X(40)".
                         
                    prompt-for NF_Serv_Itens.Cod_item colon 16
                        format "x(10)"
                        validate(input NF_Serv_Itens.Cod_item <> "",
                            "Cod. Item deve ser informado.").
                    
                    find first Serv_Produ where
                            Serv_Produ.Codigo = input NF_Serv_Itens.Cod_item 
                            no-lock no-error.
                            
                    vcfop = Serv_Produ.cfop.
                    if forne.ufecod = "RS"
                    then vcfop = 1933.
                    else vcfop = 2933.
                    
                    if can-find (first NF_Serv_itens where
                                       NF_Serv_Itens.Num_Docto =
                                       NF_Serv_Capa.Num_Docto and
                                       NF_Serv_Itens.Num_Serie =
                                       NF_Serv_Capa.Num_Serie and
                                       NF_Serv_Itens.Data_Emissao =
                                       NF_Serv_Capa.Data_Emissao and
                                       NF_Serv_Itens.Tipo_Operacao =
                                       NF_Serv_Capa.Tipo_Operacao and
                                       NF_Serv_Itens.Cod_Modelo =
                                       NF_Serv_Capa.Cod_Modelo and
                                       NF_Serv_Itens.Cod_Item = 
                                       input NF_Serv_Itens.Cod_Item) then do:
                        message "Item ja cadastrado para esta nota. Verique."
                                view-as alert-box.
                        undo.
                    end.
                    
                    prompt-for NF_Serv_Itens.Qtde_Item colon 55
                        validate(input NF_Serv_Itens.Qtde_Item <> 0,
                            "Quantidade invalida.").
                        
                    
                    prompt-for NF_Serv_Itens.Desc_Compl colon 16 format "x(61)"
                        label "Descr.Complem."
                        validate(NF_Serv_Itens.Desc_Compl <> "",
                            "Descricao invalida.").
                            
                    prompt-for NF_Serv_Itens.Numero_item colon 16 
                        validate(input NF_Serv_Itens.Numero_item <> 0,
                        "Numero do item invalido.").
                        
                    prompt-for NF_Serv_Itens.Valor_Item  colon 55
                        validate(input NF_Serv_Itens.Valor_Item <> 0,
                        "Valor do item deve ser informado.").

                    prompt-for NF_Serv_Itens.Valor_Desconto  colon 16
                        format "-zzz,zzz,zz9.99".
                        
                    vmov_item = no.
                    disp vmov_item.
                    prompt-for vmov_item
                    /*NF_Serv_Itens.Movimenta_Item*/  colon 55.
                    
                    vdataes = NF_Serv_Capa.Data_ES.
                    disp vdataes.
                    prompt-for vdataes /*NF_Serv_Itens.Data_ES*/ colon 16.
                    disp vcfop. 
                    update vcfop 
                               /*NF_Serv_Itens.CFOP*/ colon 55 .
                    
                    /*****
                    disp vmod-ctb colon 16 label "Modalidade CTB" .
                         
                    do on error undo with frame f-NF_Serv_Itens:
                    
                        update vmod-ctb 
                        validate(can-find(modal where modal.modcod = vmod-ctb),
                                "Modalidade Invalida") .
                        find modal where modal.modcod = vmod-ctb 
                                    NO-LOCK.
                        vmod-nom = modal.modnom.
                        display vmod-nom no-label .
                        if modal.modcod = "CRE"
                        then do:
                            message "modalidade nao cadatrada".
                            pause.
                            undo, retry.
                        end.

                        find first lancactb where
                            lancactb.id = 0  and
                            lancactb.etbcod = 0 and
                            lancactb.forcod = 0 and
                            lancactb.modcod = modal.modcod
                            no-lock no-error.
                        if not avail lancactb or lancactb.contadeb = 0
                        then do:
                            message
                            "Modalidade" vmod-ctb 
                            "deve estar associada a uma conta contabil." skip
                        "Favor entrar em contato com o SETOR DE CONTABILIDADE."
                            view-as alert-box.
                            undo, retry.         
                        end.
                    end. 
                    ***/
                               
                    prompt-for NF_Serv_Itens.Cod_Plano_Conta colon 16     
                                    format "x(18)" label "Conta Contabil"
                               NF_Serv_Itens.Cod_Grupo_Contabil  colon 55
                                    format "x(20)" label "Grupo Contabil"
                               NF_Serv_Itens.Valor_Contabil colon 16     
                               NF_Serv_Itens.Cod_Unid_Med colon 55
                                   format "x(2)"
                               /*NF_Serv_Itens.Cod_Obra colon 16*/.            

                    create NF_Serv_Itens.
                    assign 
                       NF_Serv_Itens.Num_Docto     = NF_Serv_Capa.Num_Docto    
                       NF_Serv_Itens.Num_Serie     = NF_Serv_Capa.Num_Serie    
                       NF_Serv_Itens.Data_Emissao  = NF_Serv_Capa.Data_Emissao
                       NF_Serv_Itens.Tipo_Operacao = NF_Serv_Capa.Tipo_Operacao
                       NF_Serv_Itens.Cod_Modelo    = NF_Serv_Capa.Cod_Modelo   
                       NF_Serv_Itens.Cod_Estab     = NF_Serv_Capa.Cod_Estab    
                       NF_Serv_Itens.Cod_Parceiro  = NF_Serv_Capa.Cod_Parceiro
                       NF_Serv_Itens.Cod_Item
                       NF_Serv_Itens.Desc_Compl
                       NF_Serv_Itens.Numero_item  
                       NF_Serv_Itens.Qtde_Item    
                       NF_Serv_Itens.Valor_Item   
                       NF_Serv_Itens.Valor_Desconto  
                       NF_Serv_Itens.Movimenta_Item = input vmov_item  
                       NF_Serv_Itens.Data_ES  = input vdataes
                       NF_Serv_Itens.CFOP = input vcfop
                       NF_Serv_Itens.Cod_Plano_Conta 
                       NF_Serv_Itens.Valor_Contabil 
                       NF_Serv_Itens.Cod_Grupo_Contabil
                       NF_Serv_Itens.Cod_Unid_Med 
                       /*NF_Serv_Itens.Cod_Obra*/.
                    
                    recatu1 = recid(NF_Serv_Itens).      
                    leave.
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-NF_Serv_Itens on error undo.
                    find NF_Serv_Itens where 
                         recid(NF_Serv_Itens) = recatu1 exclusive.
                         
                    disp NF_Serv_Capa.Num_Docto     colon 16
                         NF_Serv_Capa.Num_Serie     colon 55
                         NF_Serv_Capa.Data_Emissao  colon 16
                         NF_Serv_Capa.Tipo_Operacao colon 55
                         NF_Serv_Capa.Cod_Modelo    colon 16
                         NF_Serv_Capa.Cod_Estab     colon 55
                         NF_Serv_Capa.Cod_Parceiro  colon 16.
                    
                    vcfop = NF_Serv_Itens.cfop.
                    find Serv_forne where
                         Serv_forne.forcod =
                         int(NF_Serv_Itens.Cod_Parceiro)
                         no-lock no-error.
                    find forne of Serv_forne no-lock no-error.
                    disp forne.fornom at 30 no-label format "X(40)".
                    
                    vdataes = NF_Serv_Itens.Data_ES.
                    
                    disp NF_Serv_Itens.Cod_item colon 16 
                            format "x(10)"
                         NF_Serv_Itens.Qtde_Item colon 55
                         NF_Serv_Itens.Desc_Compl colon 16 
                            format "x(61)" label "Descr.Complem."
                         NF_Serv_Itens.Numero_item colon 16
                         NF_Serv_Itens.Valor_Item colon 55
                         NF_Serv_Itens.Valor_Desconto colon 16
                            format "-zzz,zzz,zz9.99".
                    vmov_item = NF_Serv_Itens.Movimenta_Item.
                            
                    disp vmov_item /*NF_Serv_Itens.Movimenta_Item*/ colon 55
                         vdataes /*NF_Serv_Itens.Data_ES*/ colon 16
                         vcfop /*NF_Serv_Itens.CFOP*/ colon 55.

                    vmod-ctb = "".
                    vmod-nom = "".
                    /*
                    vmod-ctb = NF_Serv_Itens.modcod-ctb.     
                    disp vmod-ctb colon 16 label "Modalidade CTB" .
                    find modal where modal.modcod = vmod-ctb NO-LOCK no-error.
                    if avail modal then vmod-nom = modal.modnom.
                    display vmod-nom no-label
                     */
                    disp  NF_Serv_Itens.Cod_Plano_Conta colon 16
                             format "x(18)" label "Conta Contabil"
                         NF_Serv_Itens.Cod_Grupo_Contabil colon 55
                             format "x(20)" label "Grupo Contabil"
                         NF_Serv_Itens.Valor_Contabil colon 16
                         NF_Serv_Itens.Cod_Unid_Med colon 55
                             format "x(2)"
                         /*NF_Serv_Itens.Cod_Obra colon 16 
                             format "X(61)"*/.
                                        
                    prompt-for NF_Serv_Itens.Qtde_Item colon 55
                        validate(input NF_Serv_Itens.Qtde_Item <> 0,
                            "Quantidade do itemm invalida.").
                    
                    prompt-for NF_Serv_Itens.Desc_Compl colon 16 
                        format "x(61)" label "Descr.Complem."
                        validate(input NF_Serv_Itens.Desc_Compl <> "",
                            "Descricao invalida.").
                    
                    prompt-for NF_Serv_Itens.Numero_item colon 16
                        validate(input NF_Serv_Itens.Numero_item <> 0,
                            "Numero do item invalido.").
                    
                    prompt-for NF_Serv_Itens.Valor_Item colon 55
                        validate(input NF_Serv_Itens.Valor_Item <> 0,
                            "Valor do item invalido.").
                    
                    prompt-for NF_Serv_Itens.Valor_Desconto colon 16.
                    
                    prompt-for vmov_item
                            /*NF_Serv_Itens.Movimenta_Item*/ colon 55.
                    
                    disp vdataes.
                    prompt-for vdataes /*NF_Serv_Itens.Data_ES*/ colon 16.
                    disp vcfop.
                    update vcfop /*NF_Serv_Itens.CFOP*/ colon 55
                               .
                    /***
                    do on error undo with frame f-NF_Serv_Itens:
                        update vmod-ctb 
                        validate(can-find(modal where modal.modcod = vmod-ctb),
                                "Modalidade Invalida") .
                        find modal where modal.modcod = vmod-ctb 
                                    NO-LOCK.
                        vmod-nom = modal.modnom.
                        display vmod-nom no-label .
                        if modal.modcod = "CRE"
                        then do:
                            message "modalidade nao cadatrada".
                            pause.
                            undo, retry.
                        end.

                        find first lancactb where
                            lancactb.id = 0  and
                            lancactb.etbcod = 0 and
                            lancactb.forcod = 0 and
                            lancactb.modcod = modal.modcod
                            no-lock no-error.
                        if not avail lancactb or lancactb.contadeb = 0
                        then do:
                            message
                            "Modalidade" vmod-ctb 
                            "deve estar associada a uma conta contabil." skip
                        "Favor entrar em contato com o SETOR DE CONTABILIDADE."
                            view-as alert-box.
                            undo, retry.         
                        end.
                    end. 
                    ***/           
                    prompt-for NF_Serv_Itens.Cod_Plano_Conta colon 16
                                    format "x(18)" label "Conta Contabil"
                               NF_Serv_Itens.Cod_Grupo_Contabil colon 55
                                    format "x(20)" label "Grupo Contabil"
                               NF_Serv_Itens.Valor_Contabil colon 16
                               NF_Serv_Itens.Cod_Unid_Med colon 55
                                    format "x(2)"
                               /*NF_Serv_Itens.Cod_Obra colon 16*/.
                    
                    
                    assign NF_Serv_Itens.Desc_Compl
                           NF_Serv_Itens.Numero_item 
                           NF_Serv_Itens.Qtde_Item   
                           NF_Serv_Itens.Valor_Item 
                           NF_Serv_Itens.Valor_Desconto  
                           NF_Serv_Itens.Movimenta_Item = input vmov_item 
                           NF_Serv_Itens.Data_ES = input vdataes
                           NF_Serv_Itens.CFOP = input vcfop
                           NF_Serv_Itens.Cod_Plano_Conta 
                           NF_Serv_Itens.Valor_Contabil
                           NF_Serv_Itens.Cod_Grupo_Contabil
                           NF_Serv_Itens.Cod_Unid_Med
                           /*NF_Serv_Itens.Cod_Obra*/.
                end.
            end.
            else do:
                disp caps(esqcom2[esqpos2]) @ esqcom2[esqpos2] 
                     with frame f-com2.
                if esqcom2[esqpos2] = "Impostos Retido"
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    hide frame frame-a no-pause.
                    run cad_nfimposto.p(recid(NF_Serv_Itens)).
                    view frame f-com1.
                    view frame f-com2.
                end.
                
                if esqcom2[esqpos2] = "   Processos   "
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    hide frame frame-a no-pause.
                    run cad_nfprocesso.p(recid(NF_Serv_Itens)).
                    view frame f-com1.
                    view frame f-com2.
                end.
                
                if esqcom2[esqpos2] = "Contas a Pagar"
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    hide frame frame-a no-pause.
                    run cad_contasapag.p(recid(NF_Serv_Itens)).
                    view frame f-com1.
                    view frame f-com2.
                end.
                
                leave.
            end.
        end.
        if not esqvazio
        then 
            run pi-frame-a. 

        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(NF_Serv_Itens).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.        
                    
procedure pi-frame-a:
    disp NF_Serv_Itens.cod_item format "x(10)" column-label "Cod.Item"
         NF_Serv_Itens.Num_Docto
         NF_Serv_Itens.Num_Serie column-label "Num.!Serie" format "x(4)"
         NF_Serv_Itens.Data_Emissao column-label "Data!Emissao"
         NF_Serv_Itens.Cod_Parceiro column-label "Codigo!Parceiro"
           format "x(10)"
         NF_Serv_Itens.Cod_Estab format "x(10)"
        (if string(NF_Serv_Itens.Tipo_Operacao) = "0" then "0-Entrada"
         else "1-Saida") column-label "Tipo!Operacao" format "x(9)"
         NF_Serv_Itens.Cod_Modelo column-label "Codigo!Modelo"
         with frame frame-a 11 down centered row 5 width 80
         title " Itens da nota " +
         string(NF_Serv_Itens.Num_Docto) + " ".
end procedure.   
               
