/*
*
*    cad_nfprocesso.p    -    Esqueleto de Programacao    com esqvazio
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


def buffer bNF_Serv_Item_Proc  for NF_Serv_Item_Proc.
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


bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        if esqascend
        then
            find first NF_Serv_Item_Proc of NF_Serv_Itens 
                       no-lock no-error.
        else
            find last  NF_Serv_Item_Proc of NF_Serv_Itens 
                       no-lock no-error.
    else                                                          
        find NF_Serv_Item_Proc where 
             recid(NF_Serv_Item_Proc) = recatu1 no-lock no-error.

    if not avail NF_Serv_Item_Proc
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then              
        run pi-frame-a. 

    recatu1 = recid(NF_Serv_Item_Proc).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        if esqascend
        then
            find next NF_Serv_Item_Proc of NF_Serv_Itens 
                      no-lock no-error.
        else
            find prev NF_Serv_Item_Proc of NF_Serv_Itens 
                      no-lock no-error.

        if not avail NF_Serv_Item_Proc
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
            
            find NF_Serv_Item_Proc where 
                 recid(NF_Serv_Item_Proc) = recatu1 no-lock no-error.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then 
                                        string(NF_Serv_Item_Proc.Num_Processo)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                   then string(NF_Serv_Item_Proc.Num_Processo)
                                   else "".

            choose field NF_Serv_Item_Proc.Num_Processo help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return) .

            status default "".

        end.
        
        {esquema.i &tabela = "NF_Serv_Item_Proc"
                   &campo  = "NF_Serv_Item_Proc.Num_processo"
        &where  = 
            "NF_Serv_Item_Proc.Cod_Estab  = NF_Serv_Itens.Cod_Estab and        
             NF_Serv_Item_Proc.Tipo_Operacao = NF_Serv_Itens.Tipo_Operacao and
             NF_Serv_Item_Proc.Cod_Modelo    = NF_Serv_Itens.Cod_Modelo and   
             NF_Serv_Item_Proc.Num_Docto     = NF_Serv_Itens.Num_Docto and    
             NF_Serv_Item_Proc.Num_Serie     = NF_Serv_Itens.Num_Serie and   
             NF_Serv_Item_Proc.Cod_Parceiro  = NF_Serv_Itens.Cod_Parceiro and
             NF_Serv_Item_Proc.Data_Emissao  = NF_Serv_Itens.Data_Emissao"
             NF_Serv_Item_Proc.Cod_Item      = NF_Serv_Itens.Cod_Item
                   &frame  = "frame-a"}

        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do on error undo, retry on endkey undo, leave:
            form  
            with frame f-NF_Serv_Item_Proc  color black/cyan centered  
            row 5 side-labels width 80 1 down.
            hide frame frame-a no-pause.
            if esqregua
            then do:                                   
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-NF_Serv_Item_Proc side-labels
                on error undo.
                    
                    disp NF_Serv_Itens.Num_Docto     colon 18
                         NF_Serv_Itens.Num_Serie     colon 55
                         NF_Serv_Itens.Data_Emissao  colon 18
                         NF_Serv_Itens.Tipo_Operacao colon 55
                         NF_Serv_Itens.Cod_Modelo    colon 18
                         NF_Serv_Itens.Cod_Estab     colon 55
                         NF_Serv_Itens.Cod_Parceiro  colon 18
                            format "x(10)".
                    find Serv_forne where 
                         Serv_forne.forcod = 
                         int(NF_Serv_Itens.Cod_Parceiro) no-lock no-error.
                    find forne of Serv_forne no-lock no-error.
                    disp forne.fornom at 30 no-label format "X(40)".
                         
                         
                    disp NF_Serv_Itens.Cod_item colon 18
                            format "X(10)"
                         NF_Serv_Itens.Desc_Compl at 30 
                         no-label format "X(40)".
                    
                    prompt-for NF_Serv_Item_Proc.Num_Processo colon 18
                        validate(input NF_Serv_Item_Proc.Num_Processo <> "",
                        "Numero do processo invalido.").
                    
                    
                    if can-find (first NF_Serv_Item_Proc where
                                       NF_Serv_Item_Proc.Num_Docto =
                                       NF_Serv_Itens.Num_Docto and
                                       NF_Serv_Item_Proc.Num_Serie =
                                       NF_Serv_Itens.Num_Serie and
                                       NF_Serv_Item_Proc.Data_Emissao =
                                       NF_Serv_Itens.Data_Emissao and
                                       NF_Serv_Item_Proc.Tipo_Operacao =
                                       NF_Serv_Itens.Tipo_Operacao and
                                       NF_Serv_Item_Proc.Cod_Modelo =
                                       NF_Serv_Itens.Cod_Modelo and
                                       NF_Serv_Item_Proc.Cod_Item = 
                                       NF_Serv_Itens.Cod_Item and
                                       NF_Serv_Item_Proc.Num_processo = 
                                       input NF_Serv_Item_Proc.Num_processo)
                    then do:
                        message "Processo ja cadastrado para este item. "
                                "Verifique."
                                view-as alert-box.
                        undo.
                    end.
                    
                            
                    prompt-for NF_Serv_Item_Proc.Num_item colon 55 
                        validate(input NF_Serv_Item_Proc.Num_item <> 0,
                        "Numero do item invalido.").
                        
                    prompt-for NF_Serv_Item_Proc.Tipo_Processo colon 18
                    validate(length(input NF_Serv_Item_Proc.Tipo_Processo) <> 0
                          and input NF_Serv_Item_Proc.Tipo_Processo <> ?
                        , "Tipo de Processo invalido.").
                    
                    vdataes = NF_Serv_Itens.Data_ES.
                    disp vdataes.
                    prompt-for vdataes /*NF_Serv_Item_Proc.Data_ES*/ colon 55.

                    prompt-for NF_Serv_Item_Proc.cod_Mun_IBGE colon 18.

                    prompt-for NF_Serv_Item_Proc.cod_Suspensao colon 55.

                    do on error undo:
                        prompt-for NF_Serv_Item_Proc.cod_Parceiro_Adv colon 18
                            label "Cod.Parceiro Adv." format "x(10)".
                    
                        find bServ_forne where
                             bServ_forne.forcod =
                             int(input NF_Serv_Item_Proc.Cod_Parceiro_Adv) 
                             no-lock no-error.
                        find bforne of bServ_forne no-lock no-error.
                        if not avail bforne then do:
                            message "Parceiro deve ser de servico. Verifique."
                                    view-as alert-box.
                            undo.        
                        end.                        
                        disp bforne.fornom at 30 no-label format "X(40)".
                    end.
                    
                    prompt-for NF_Serv_Item_Proc.Val_Serv_Adv colon 18
                        format "-z,zzz,zzz,zz9.99"
                        label "Valor Serv. Adv.".
                    
                    prompt-for NF_Serv_Item_Proc.Data_Pagto_Adv colon 55
                        label "Dt.Pagto.Advogado".
                    
                    
                    create NF_Serv_Item_Proc.
                    assign 
                   NF_Serv_Item_Proc.Num_Docto     = NF_Serv_Itens.Num_Docto  
                   NF_Serv_Item_Proc.Cod_Modelo    = NF_Serv_Itens.Cod_Modelo
                   NF_Serv_Item_Proc.Cod_Estab     = NF_Serv_Itens.Cod_Estab
                   NF_Serv_Item_Proc.Num_Serie     = NF_Serv_Itens.Num_Serie 
                   NF_Serv_Item_Proc.Cod_Item      = NF_Serv_Itens.Cod_Item
                   NF_Serv_Item_Proc.Data_Emissao  = NF_Serv_Itens.Data_Emissao
                   NF_Serv_Item_Proc.Tipo_Operacao = NF_Serv_Itens.Tipo_Operacao
                   NF_Serv_Item_Proc.Cod_Parceiro  = NF_Serv_Itens.Cod_Parceiro
                   NF_Serv_Item_Proc.Num_Processo
                   NF_Serv_Item_Proc.Num_item  
                   NF_Serv_Item_Proc.Data_ES = input vdataes
                   NF_Serv_Item_Proc.Tipo_Processo
                   NF_Serv_Item_Proc.cod_Mun_IBGE
                   NF_Serv_Item_Proc.Cod_Suspensao
                   NF_Serv_Item_Proc.cod_Parceiro_Adv
                   NF_Serv_Item_Proc.Val_Serv_Adv
                   NF_Serv_Item_Proc.Data_Pagto_Adv
                    
                    recatu1 = recid(NF_Serv_Item_Proc).      
                    leave.
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-NF_Serv_Item_Proc on error undo.
                    find NF_Serv_Item_Proc where 
                         recid(NF_Serv_Item_Proc) = recatu1 exclusive.
                         
                    disp NF_Serv_Itens.Num_Docto     colon 18
                         NF_Serv_Itens.Num_Serie     colon 55
                         NF_Serv_Itens.Data_Emissao  colon 18
                         NF_Serv_Itens.Tipo_Operacao colon 55
                         NF_Serv_Itens.Cod_Modelo    colon 18
                         NF_Serv_Itens.Cod_Estab     colon 55
                         NF_Serv_Itens.Cod_Parceiro  colon 18.
                    
                    find Serv_forne where
                         Serv_forne.forcod =
                         int(NF_Serv_Item_Proc.Cod_Parceiro)
                         no-lock no-error.
                    find forne of Serv_forne no-lock no-error.
                    disp forne.fornom at 30 no-label format "X(40)".
                    
                    disp NF_Serv_Itens.Cod_item colon 18
                            format "X(10)"
                         NF_Serv_Itens.Desc_Compl at 30
                            no-label format "X(40)"
                         NF_Serv_Item_Proc.Num_Processo colon 18
                         NF_Serv_Item_Proc.Num_item colon 55
                         NF_Serv_Item_Proc.Tipo_Processo colon 18
                         .
                    vdataes = NF_Serv_Item_Proc.Data_ES.
                    disp vdataes     
                         /*NF_Serv_Item_Proc.Data_ES*/ colon 55
                         NF_Serv_Item_Proc.cod_Mun_IBGE colon 18
                         NF_Serv_Item_Proc.cod_Suspensao colon 55
                         NF_Serv_Item_Proc.cod_Parceiro_Adv colon 18
                            label "Cod.Parceiro Adv." format "x(10)".
                    
                    find bServ_forne where
                         bServ_forne.forcod =
                         int(NF_Serv_Item_Proc.Cod_Parceiro_Adv) 
                         no-lock no-error.
                    find bforne of bServ_forne no-lock no-error.
                    disp bforne.fornom at 30 no-label format "X(40)".
                    
                    disp NF_Serv_Item_Proc.Val_Serv_Adv colon 18
                            format "-z,zzz,zzz,zz9.99" 
                            label "Valor Serv. Adv."
                         NF_Serv_Item_Proc.Data_Pagto_Adv colon 55
                            label "Dt.Pagto.Advogado".
                                            
                    
                    prompt-for NF_Serv_Item_Proc.Num_item colon 18
                        validate(input NF_Serv_Item_Proc.Num_item <> 0,
                            "Numero do item invalido.").
                    
                    prompt-for NF_Serv_Item_Proc.Tipo_Processo colon 18
                    validate(length(input NF_Serv_Item_Proc.Tipo_Processo) <> 0
                             and input NF_Serv_Item_Proc.Tipo_Processo <> ?,
                        "Tipo de Processo invalido.").
                    
                    prompt-for vdataes /*NF_Serv_Item_Proc.Data_ES*/ colon 55.
                    
                    prompt-for NF_Serv_Item_Proc.cod_Mun_IBGE colon 18.
                    
                    prompt-for NF_Serv_Item_Proc.cod_Suspensao colon 55.
                    
                    prompt-for NF_Serv_Item_Proc.cod_Parceiro_Adv colon 18
                        label "Cod.Parceiro Adv." format "x(10)".
                    
                    
                    find bServ_forne where
                         bServ_forne.forcod =
                         int(input NF_Serv_Item_Proc.Cod_Parceiro_Adv) 
                         no-lock no-error.
                    find bforne of bServ_forne no-lock no-error.
                    disp bforne.fornom at 30 no-label format "X(40)".
                    
                    
                    prompt-for NF_Serv_Item_Proc.Val_Serv_Adv colon 18
                        format "-z,zzz,zzz,zz9.99"
                        label "Valor Serv. Adv.".
                    
                    prompt-for NF_Serv_Item_Proc.Data_Pagto_Adv colon 55
                        label "Dt.Pagto.Advogado".
                    
                    
                    assign NF_Serv_Item_Proc.Num_item
                           NF_Serv_Item_Proc.Data_ES = input vdataes
                           NF_Serv_Item_Proc.Tipo_Processo
                           NF_Serv_Item_Proc.cod_Mun_IBGE
                           NF_Serv_Item_Proc.Cod_Suspensao
                           NF_Serv_Item_Proc.cod_Parceiro_Adv
                           NF_Serv_Item_Proc.Val_Serv_Adv
                           NF_Serv_Item_Proc.Data_Pagto_Adv.
                end.

            end.
        end.
        if not esqvazio
        then 
            run pi-frame-a. 

        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(NF_Serv_Item_Proc).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.        
                    
procedure pi-frame-a:
    disp NF_Serv_Item_Proc.Num_Processo format "x(10)" 
            column-label "Num.!Processo"
         NF_Serv_Item_Proc.cod_item format "x(10)" column-label "Cod.Item"
         NF_Serv_Item_Proc.Num_Docto
         NF_Serv_Item_Proc.Num_Serie column-label "Num.!Serie" format "x(4)"
         NF_Serv_Item_Proc.Data_Emissao column-label "Data!Emissao"
         NF_Serv_Item_Proc.Cod_Parceiro column-label "Codigo!Parceiro"
           format "x(8)"
         NF_Serv_Item_Proc.Cod_Estab format "x(8)" column-label "Cod.!Estab"
        (if string(NF_Serv_Item_Proc.Tipo_Operacao) = "0" then "0-Ent"
         else "1-Sai") column-label "Tipo!Oper" format "x(5)"
         NF_Serv_Item_Proc.Cod_Modelo column-label "Cod.!Mod." format "x(4)"
         with frame frame-a 11 down centered row 5 width 80
         title " Processos do item " +
         string(NF_Serv_Item_Proc.Cod_Item) + " ".
end procedure.                  
