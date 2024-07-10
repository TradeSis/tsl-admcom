/*
*    cad_nfcapa.p    -    Esqueleto de Programacao    com esqvazio
*
*/

{admcab.i}

def var recatu1         as recid.
def var recatu2         as recid.
def var vforcgc         as char format "x(20)" label "CNPJ/CPF".
def var vfordesc        as char format "x(40)".
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Inclusao "," Alteracao ","Contas/Pagar ","  Excluir","     "].
def var esqcom2         as char format "x(16)" extent 5
 init ["Itens da Nota"," "," ", " " , " "].

def var esqhel1         as char format "x(80)" extent 5
    initial [" Inclusao da nota ",
             " Alteracao da nota ",
             "  ",
             "  ",
             "  "].
def var esqhel2         as char format "x(12)" extent 5.

def buffer bNF_Serv_Capa       for NF_Serv_Capa.

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

def var vdataes like NF_Serv_Capa.Data_ES.
def var v-modelo like NF_Serv_Capa.Cod_Modelo.
 
bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then run leitura (input "pri").
    else find NF_Serv_Capa where recid(NF_Serv_Capa) = recatu1 no-lock.
    if not available NF_Serv_Capa
    then esqvazio = yes.
    else esqvazio = no.
    
    clear frame frame-a all no-pause.
    if not esqvazio
    then run frame-a.
    
    recatu1 = recid(NF_Serv_Capa).

    if esqregua
    then color disp message esqcom1[esqpos1] with frame f-com1.
    else color disp message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available NF_Serv_Capa
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
            find NF_Serv_Capa where recid(NF_Serv_Capa) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(NF_Serv_Capa.Num_Docto)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(NF_Serv_Capa.Num_Docto)
                                        else "".
            run color-message.
            choose field NF_Serv_Capa.Num_Docto help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return p P).
            run color-normal.
            status default "".

            if keyfunction(lastkey) = "p"
            then do:
                pause 0.
                prompt-for  NF_Serv_Capa.Cod_Parceiro format "x(10)"
                            NF_Serv_Capa.Num_Docto
                 with frame f-proc 1 down centered row 8
                 overlay side-label color message 1 column.
                find first NF_Serv_Capa where 
                    NF_Serv_Capa.Cod_Parceiro =
                                input frame f-proc NF_Serv_Capa.Cod_Parceiro
                    and            
                    NF_Serv_Capa.Num_Docto =
                                input frame f-proc NF_Serv_Capa.Num_Docto
                                no-lock no-error.
                if avail NF_Serv_Capa
                then recatu1 = recid(NF_Serv_Capa).
                hide frame f-1 no-pause.
                next bl-princ.                
            end.


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
                    if not avail NF_Serv_Capa
                    then leave.
                    recatu1 = recid(NF_Serv_Capa).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail NF_Serv_Capa
                    then leave.
                    recatu1 = recid(NF_Serv_Capa).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail NF_Serv_Capa
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail NF_Serv_Capa
                then next.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.
        if keyfunction(lastkey) = "return" or esqvazio
        then do on error undo, retry on endkey undo, leave:
            form NF_Serv_Capa.Cod_Estab      colon 15 format "999"
                 vforcgc                     colon 15
                 vfordesc                    colon 35
                 NF_Serv_Capa.Num_Docto      colon 15
                 NF_Serv_Capa.Num_Serie      colon 55
                 NF_Serv_Capa.Data_Emissao   colon 15
                 NF_Serv_Capa.Tipo_Operacao  colon 55
                 NF_Serv_Capa.Data_Emissao   colon 15
                 NF_Serv_Capa.Tipo_Operacao  colon 55
                 v-modelo /*NF_Serv_Capa.Cod_Modelo*/     colon 15
                 vdataes  /*NF_Serv_Capa.Data_ES   */     colon 15
                 NF_Serv_Capa.Data_Exec      colon 55
                 NF_Serv_Capa.Cod_Sit        colon 15
                 NF_Serv_Capa.NF_Emitida     colon 55
                 NF_Serv_Capa.Modelo_NF      colon 15
                 NF_Serv_Capa.Tipo_Pagamento colon 55
                 NF_Serv_Capa.Val_Desconto   colon 15 format "-zzz,zzz,zz9.99"
                 NF_Serv_Capa.Val_Tot_Docto  colon 55
                 NF_Serv_Capa.Val_Servico    colon 15
                 /*NF_Serv_Capa.Codigo_Obra    colon 15 format "X(61)"
                 */
            with frame f-NF_Serv_Capa color black/cyan centered side-label 
            width 80 row 5.
            
            hide frame frame-a no-pause.

            if esqregua
            then do:
                disp caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-NF_Serv_Capa  on error undo.
                    
                    prompt-for NF_Serv_Capa.Cod_Estab
                        validate(NF_Serv_Capa.Cod_Estab <> "0" and
                                 NF_Serv_Capa.Cod_Estab <> "",
                                 "Cod. do estabelecimento invalido.").
                    
                    do on error undo:
                        prompt-for vforcgc  
                            validate(can-find(forne where
                                              forne.forcgc = input vforcgc), 
                            "CNPJ ou CPF invalido").
                            
                        find forne where
                             forne.forcgc = input vforcgc no-lock no-error.
                        
                        find Serv_forne where
                             Serv_forne.forcod = forne.forcod 
                             no-lock no-error.
                                                                               
                        if not avail Serv_forne then do:
                            message "Participante nao cadastrado. Verifique."
                            view-as alert-box.
                            undo.
                        end.
                    end.

                    assign vfordesc = forne.fornom.     
                    disp vfordesc no-label.
                                

                    prompt-for NF_Serv_Capa.Num_Docto
                        validate(NF_Serv_Capa.Num_Docto <> 0,
                            "Num.Docto invalido.").
                            
                    prompt-for NF_Serv_Capa.Num_Serie
                        validate(NF_Serv_Capa.Num_Serie <> "",
                            "Num.Serie invalida.").
                            
                    prompt-for NF_Serv_Capa.Data_Emissao
                        validate(NF_Serv_Capa.Data_Emissao <> ?,
                            "Data Emissao invalida.").
                            
                    prompt-for NF_Serv_Capa.Tipo_Operacao
                    validate(lookup(NF_Serv_Capa.Tipo_Operacao,"0,1") <> 0,
                        "Opcao invalida.").
                               
                    v-modelo = "1".           
                    disp v-modelo.
                    prompt-for v-modelo validate(v-modelo <> "",
                            "Cod. Modelo invalido.").

                    /***
                    07125464000173
                    prompt-for NF_Serv_Capa.Cod_Modelo
                        validate(NF_Serv_Capa.Cod_Modelo <> "",
                            "Cod. Modelo invalido.").
                    ***/        
                                                           
                    
                    if can-find (first NF_Serv_Capa where
                                       NF_Serv_Capa.Num_Docto = 
                                       input NF_Serv_Capa.Num_Docto and   
                                       NF_Serv_Capa.Num_Serie = 
                                       input NF_Serv_Capa.Num_Serie and  
                                       NF_Serv_Capa.Data_Emissao =
                                       input NF_Serv_Capa.Data_Emissao and
                                       NF_Serv_Capa.Tipo_Operacao =
                                       input NF_Serv_Capa.Tipo_Operacao and
                                       NF_Serv_Capa.Cod_Modelo = 
                                       input v-modelo
                                       /*NF_Serv_Capa.Cod_Modelo*/) then do:
                        message "Nota ja cadastrada. Verique."
                                view-as alert-box.
                        undo.
                    end.
                    vdataes = today. 
                    disp vdataes.
                    prompt-for vdataes
                               NF_Serv_Capa.Data_Exec.
                    prompt-for NF_Serv_Capa.Cod_Sit.
                    prompt-for NF_Serv_Capa.NF_Emitida.
                    prompt-for NF_Serv_Capa.Modelo_NF.
                    prompt-for NF_Serv_Capa.Tipo_Pagamento.
                    prompt-for NF_Serv_Capa.Val_Desconto
                        format "-zzz,zzz,zz9.99".
                    prompt-for NF_Serv_Capa.Val_Tot_Docto.
                    prompt-for NF_Serv_Capa.Val_Servico.
                    /*prompt-for NF_Serv_Capa.Codigo_Obra.
                      */         
                    prompt-for NF_Serv_Capa.Ind_Usso_RPS_Retencao at 1
                                    format "!".
                    prompt-for NF_Serv_Capa.Numero_RPS.
                    
                    create NF_Serv_Capa.           
                    assign NF_Serv_Capa.Num_Docto    
                           NF_Serv_Capa.Num_Serie    
                           NF_Serv_Capa.Data_Emissao 
                           NF_Serv_Capa.Tipo_Operacao
                           NF_Serv_Capa.Cod_Modelo = input v-modelo   
                           NF_Serv_Capa.Cod_Estab    
                           NF_Serv_Capa.Cod_Parceiro = string(forne.forcod)
                           NF_Serv_Capa.Data_ES = input vdataes      
                           NF_Serv_Capa.Data_Exec     
                           NF_Serv_Capa.Cod_Sit       
                           NF_Serv_Capa.NF_Emitida    
                           NF_Serv_Capa.Modelo_NF     
                           NF_Serv_Capa.Tipo_Pagamento
                           NF_Serv_Capa.Val_Tot_Docto 
                           NF_Serv_Capa.Val_Desconto  
                           NF_Serv_Capa.Val_Servico   
                           /*NF_Serv_Capa.Codigo_Obra*/
                           NF_Serv_Capa.Ind_Usso_RPS_Retencao
                           NF_Serv_Capa.Numero_RPS
                           .   
                     
                    recatu1 = recid(NF_Serv_Capa).
                    leave.
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-NF_Serv_Capa on error undo.
                    find NF_Serv_Capa where 
                         recid(NF_Serv_Capa) = recatu1 exclusive.
                         
                    v-modelo = NF_Serv_Capa.Cod_Modelo.       
                    disp NF_Serv_Capa.Num_Docto     
                         NF_Serv_Capa.Num_Serie     
                         NF_Serv_Capa.Data_Emissao  
                         NF_Serv_Capa.Tipo_Operacao 
                         v-modelo /*NF_Serv_Capa.Cod_Modelo*/    
                         NF_Serv_Capa.Cod_Estab.
                         

                        
                    find Serv_forne where
                         Serv_forne.forcod = int(NF_Serv_Capa.Cod_Parceiro)
                         no-lock no-error.
                    find forne of Serv_forne no-lock no-error.
                    assign vforcgc = forne.forcgc
                          vfordesc = string(forne.forcod) + ' ' + 
                                     forne.fornom. 
                    disp vforcgc
                         vfordesc no-label.
                    
                    vdataes = NF_Serv_Capa.Data_ES.
                    disp vdataes /*NF_Serv_Capa.Data_ES*/       
                         NF_Serv_Capa.Data_Exec     
                         NF_Serv_Capa.Cod_Sit       
                         NF_Serv_Capa.NF_Emitida    
                         NF_Serv_Capa.Modelo_NF     
                         NF_Serv_Capa.Tipo_Pagamento
                         NF_Serv_Capa.Val_Desconto
                         NF_Serv_Capa.Val_Tot_Docto
                         NF_Serv_Capa.Val_Servico
                         /*NF_Serv_Capa.Codigo_Obra*/.
                         
                     prompt-for vdataes /*NF_Serv_Capa.Data_ES*/
                                NF_Serv_Capa.Data_Exec.
                     prompt-for NF_Serv_Capa.Cod_Sit.
                     prompt-for NF_Serv_Capa.NF_Emitida.
                     prompt-for NF_Serv_Capa.Modelo_NF.
                     prompt-for NF_Serv_Capa.Tipo_Pagamento.
                     prompt-for NF_Serv_Capa.Val_Desconto.
                     prompt-for NF_Serv_Capa.Val_Tot_Docto.
                     prompt-for NF_Serv_Capa.Val_Servico.
                     /*prompt-for NF_Serv_Capa.Codigo_Obra.*/
                     prompt-for NF_Serv_Capa.Ind_Usso_RPS_Retencao at 1
                                    format "!".
                     prompt-for NF_Serv_Capa.Numero_RPS.
                                         
                     
                    assign NF_Serv_Capa.Data_ES  = input vdataes
                           NF_Serv_Capa.Data_Exec
                           NF_Serv_Capa.Cod_Sit
                           NF_Serv_Capa.NF_Emitida
                           NF_Serv_Capa.Modelo_NF
                           NF_Serv_Capa.Tipo_Pagamento
                           NF_Serv_Capa.Val_Tot_Docto
                           NF_Serv_Capa.Val_Desconto
                           NF_Serv_Capa.Val_Servico
                           /*NF_Serv_Capa.Codigo_Obra*/
                           NF_Serv_Capa.Ind_Usso_RPS_Retencao
                           NF_Serv_Capa.Numero_RPS
                           .
                           
                end.
                if esqcom1[esqpos1] = "Contas/Pagar"
                then do:
                    hide frame f-com1 no-pause.
                    hide frame f-com2 no-pause.
                    run infds010-NFS-V0118.p(NF_Serv_Capa.Cod_Estab,
                             NF_Serv_Capa.Tipo_Operacao,
                             NF_Serv_Capa.Cod_Modelo,
                             NF_Serv_Capa.Num_Docto,
                             NF_Serv_Capa.Num_Serie,
                             NF_Serv_Capa.Cod_Parceiro,
                             NF_Serv_Capa.Data_Emissao).
                    view frame f-com1.
                    view frame f-com2.
                end.
                if esqcom1[esqpos1] = "  Excluir"
                then do:
                    view frame frame-a.
                    sresp = no.
                    message 
                    "Confirma excluir documento" NF_Serv_Capa.Num_Docto "?"
                    update sresp.
                    if sresp
                    then do:
                    run cad_nfcapa_excluir.p(recid(NF_Serv_Capa)).
                    recatu1 = ?.
                    leave.
                    end.
                end.    
            end.
            else do:
                disp caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                
                if esqcom2[esqpos2] = "Itens da Nota"
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    hide frame frame-a no-pause.
                    run cad_nfitens.p(recid(NF_Serv_Capa)).
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
        recatu1 = recid(NF_Serv_Capa).
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
    disp NF_Serv_Capa.Num_Docto
         NF_Serv_Capa.Num_Serie
         NF_Serv_Capa.Data_Emissao  column-label "Data!Emissao"
         NF_Serv_Capa.Cod_Parceiro column-label "Codigo!Parceiro" format "x(10)"
         NF_Serv_Capa.Cod_Estab format "999" 
        (if string(NF_Serv_Capa.Tipo_Operacao) = "0" then "0-Entrada"
         else "1-Saida") column-label "Tipo!Operacao" format "x(10)"
         NF_Serv_Capa.Cod_Modelo    column-label "Codigo!Modelo"
    with frame frame-a 11 down width 80 color white/red row 5.
end procedure.


procedure color-message.
    color disp message NF_Serv_Capa.Num_Docto 
    with frame frame-a.
end procedure.


procedure color-normal.
    color disp normal NF_Serv_Capa.Num_Docto 
    with frame frame-a.
end procedure.


procedure leitura.
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend 
    then  
        find first NF_Serv_Capa where true no-lock no-error.
    else  
        find last NF_Serv_Capa where true  no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next NF_Serv_Capa where true no-lock no-error.
    else  
        find prev NF_Serv_Capa where true no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev NF_Serv_Capa where true no-lock no-error.
    else   
        find next NF_Serv_Capa where true no-lock no-error.
        
end procedure.
         
