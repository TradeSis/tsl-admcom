/*
*
*    conta_pag01a.p     -    Esqueleto de Programacao    com esqvazio

*
*/

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend       as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial ["Inclusao","Alteracao"," "," "," "].
def var esqcom2         as char format "x(12)" extent 5
            initial ["  "," ","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial ["Inclusao do Imposto",
             "Alteracao do Imposto " ,
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

def buffer bserv_titulo_iret for serv_titulo_iret.


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


find servi_titulo where recid(servi_titulo) = par-rec no-lock no-error.
                    

bl-princ:
repeat:
    
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ? then
        if esqascend then
            find first serv_titulo_iret where
     serv_titulo_iret.TipoOperacaoContaPagRec = servi_titulo.tipoOperacao
 and serv_titulo_iret.codEstabelecimento = servi_titulo.codEstabelecimento
 and serv_titulo_iret.codParceiro = servi_titulo.codParceiro
 and serv_titulo_iret.dataOperacaoContaPagRec = servi_titulo.dataOperacao
 and serv_titulo_iret.NumeroDocumentoContaPagRec = servi_titulo.numeroDocumento
 and serv_titulo_iret.NumeroParcelaContaPagRec = servi_titulo.NumeroParcela          no-lock no-error.
        else
            find last serv_titulo_iret where
     serv_titulo_iret.TipoOperacaoContaPagRec = servi_titulo.tipoOperacao
 and serv_titulo_iret.codEstabelecimento = servi_titulo.codEstabelecimento
 and serv_titulo_iret.codParceiro = servi_titulo.codParceiro
 and serv_titulo_iret.dataOperacaoContaPagRec = servi_titulo.dataOperacao
 and serv_titulo_iret.NumeroDocumentoContaPagRec = servi_titulo.numeroDocumento
 and serv_titulo_iret.NumeroParcelaContaPagRec = servi_titulo.NumeroParcela
      no-lock no-error.
    else
        find serv_titulo_iret where 
             recid(serv_titulo_iret) = recatu1 no-lock no-error.

    if not avail serv_titulo_iret then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio then do:
        
        disp serv_titulo_iret.TipoOperacaoContaPagRec
             column-label "Oper."
             serv_titulo_iret.codEstabelecimento   
             format "x(8)" column-label "Estab."
             serv_titulo_iret.CodParceiro
             format "x(8)" column-label "Parceiro"
             serv_titulo_iret.DataOperacaoContaPagRec
             column-label "Dt Oper."
             serv_titulo_iret.NumeroDocumentoContaPagRec
             format "x(8)" column-label "Num Doc"
             serv_titulo_iret.NumeroParcelaContaPagRec
             column-label "Num Parc"
             serv_titulo_iret.codItem
             format "x(8)" column-label "Item"
             serv_titulo_iret.varcodReceita
             format "x(8)" column-label "Cod. Receita"
        with frame frame-a 11 down centered row 5 width 80
        title " Impostos do item " +
        string(servi_titulo.descricao, "x(30)") + " ".   
             
    end.

    recatu1 = recid(serv_titulo_iret).
    if esqregua then 
        color display message esqcom1[esqpos1] with frame f-com1.
    else 
        color display message esqcom2[esqpos2] with frame f-com2.
    
    if not esqvazio then repeat:
        if esqascend then
            find next serv_titulo_iret where
     serv_titulo_iret.TipoOperacaoContaPagRec = servi_titulo.tipoOperacao
 and serv_titulo_iret.codEstabelecimento = servi_titulo.codEstabelecimento
 and serv_titulo_iret.codParceiro = servi_titulo.codParceiro
 and serv_titulo_iret.dataOperacaoContaPagRec = servi_titulo.dataOperacao
 and serv_titulo_iret.NumeroDocumentoContaPagRec = servi_titulo.numeroDocumento
 and serv_titulo_iret.NumeroParcelaContaPagRec = servi_titulo.NumeroParcela
 and Serv_Titulo_IRet.TipoDocumentoContaPagRec = servi_titulo.TipoDocumento
no-lock no-error.
        else
            find prev serv_titulo_iret where
     serv_titulo_iret.TipoOperacaoContaPagRec = servi_titulo.tipoOperacao
 and serv_titulo_iret.codEstabelecimento = servi_titulo.codEstabelecimento
 and serv_titulo_iret.codParceiro = servi_titulo.codParceiro
 and serv_titulo_iret.dataOperacaoContaPagRec = servi_titulo.dataOperacao
 and serv_titulo_iret.NumeroDocumentoContaPagRec = servi_titulo.numeroDocumento
 and serv_titulo_iret.NumeroParcelaContaPagRec = servi_titulo.NumeroParcela
 and Serv_Titulo_IRet.TipoDocumentoContaPagRec = servi_titulo.TipoDocumento    
no-lock no-error.

        if not avail serv_titulo_iret then leave.
        if frame-line(frame-a) = frame-down(frame-a) then leave.
        down with frame frame-a.
        

        disp serv_titulo_iret.TipoOperacaoContaPagRec
             column-label "Oper."
             serv_titulo_iret.codEstabelecimento
             format "x(8)" column-label "Estab."
             serv_titulo_iret.CodParceiro
             format "x(8)" column-label "Parceiro"
             serv_titulo_iret.DataOperacaoContaPagRec
             column-label "Dt Oper."
             serv_titulo_iret.NumeroDocumentoContaPagRec
             format "x(8)" column-label "Num Doc"
             serv_titulo_iret.NumeroParcelaContaPagRec
             column-label "Num Parc"
             serv_titulo_iret.codItem
             format "x(8)" column-label "Item"
             serv_titulo_iret.varcodReceita
             format "x(8)" column-label "Cod. Receita"
             with frame frame-a.
    end.
    if not esqvazio then 
        up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        if not esqvazio then do:
            
            find serv_titulo_iret where 
                 recid(serv_titulo_iret) = recatu1 no-lock no-error.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> "" then
                                            serv_titulo_iret.codEstabelecimento
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> "" then
                                            serv_titulo_iret.codEstabelecimento
                                        else "".

            choose field serv_titulo_iret.TipoOperacaoContaPagRec help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return) .

            status default "".

        end.
        
        {esquema.i &tabela = "serv_titulo_iret"
                   &campo  = "serv_titulo_iret.TipoOperacaoContaPagRec"
&where  = "serv_titulo_iret.TipoOperacaoContaPagRec = tipoOper
 and serv_titulo_iret.codEstabelecimento = servi_titulo.codEstabelecimento
 and serv_titulo_iret.codParceiro = servi_titulo.codParceiro
 and serv_titulo_iret.dataOperacaoContaPagRec = servi_titulo.dataOperacao
 and serv_titulo_iret.NumeroDocumentoContaPagRec = servi_titulo.numeroDocumento
 and serv_titulo_iret.NumeroParcelaContaPagRec = servi_titulo.NumeroParcela
 and Serv_Titulo_IRet.TipoDocumentoContaPagRec = servi_titulo.TipoDocumento"
                   &frame  = "frame-a"}

        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do on error undo, retry on endkey undo, leave:
            
            form  
            with frame f-serv_titulo_iret  color black/cyan centered  
            row 5 side-labels width 80 1 down.
            
            hide frame frame-a no-pause.
            if esqregua
            then do:                                   
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = "Inclusao" or esqvazio
                then do with frame f-serv_titulo_iret side-labels
                on error undo.
                    
                              
                    create serv_titulo_iret.
                    assign serv_titulo_iret.TipoOperacaoContaPagRec = 
                                servi_titulo.tipoOperacao
                           serv_titulo_iret.codEstabelecimento = 
                                servi_titulo.codEstabelecimento
                           serv_titulo_iret.CodParceiro = 
                                servi_titulo.codParceiro
                           serv_titulo_iret.DataOperacaoContaPagRec = 
                                servi_titulo.dataOperacao
                           serv_titulo_iret.NumeroDocumentoContaPagRec = 
                                servi_titulo.numeroDocumento
                           serv_titulo_iret.NumeroParcelaContaPagRec = 
                                servi_titulo.numeroParcela
                           Serv_Titulo_IRet.TipoDocumentoContaPagRec =
                                servi_titulo.TipoDocumento.
                    
                    disp serv_titulo_iret.TipoOperacaoContaPagRec
                         serv_titulo_iret.codEstabelecimento
                         serv_titulo_iret.CodParceiro
                         serv_titulo_iret.DataOperacaoContaPagRec
                         serv_titulo_iret.NumeroDocumentoContaPagRec
                         serv_titulo_iret.NumeroParcelaContaPagRec.
                    
                    do on error undo, retry:
                        prompt-for serv_titulo_iret.CodItem.
    
                        if input serv_titulo_iret.CodItem <> "" or
                            length(input serv_titulo_iret.CodItem) < 1 then do:
                            message "Cod. Item deve ser informado."
                                    view-as alert-box.
                            undo, retry.
                        end.
                    end.
                    prompt-for serv_titulo_iret.VarCodReceita.
                    prompt-for serv_titulo_iret.TipoContaPagRec.
                    prompt-for serv_titulo_iret.DataPagamento.
                    prompt-for serv_titulo_iret.CodImpostoRetido.
                    prompt-for serv_titulo_iret.ValorBaseRetencao.
                    prompt-for serv_titulo_iret.AliquotaRetencao.
                    prompt-for serv_titulo_iret.ValorRetido.
                    prompt-for serv_titulo_iret.ValorDepositoJudicial.
                    prompt-for serv_titulo_iret.CodFormaTributacaoExt.
                    prompt-for serv_titulo_iret.CodTipoRendimentoExt.
                    prompt-for serv_titulo_iret.ValorDeducaoBC.
                                        
                    assign serv_titulo_iret.CodItem
                           serv_titulo_iret.VarCodReceita
                           serv_titulo_iret.TipoContaPagRec
                           serv_titulo_iret.DataPagamento
                           serv_titulo_iret.CodImpostoRetido
                           serv_titulo_iret.ValorBaseRetencao
                           serv_titulo_iret.AliquotaRetencao
                           serv_titulo_iret.ValorRetido
                           serv_titulo_iret.ValorDepositoJudicial
                           serv_titulo_iret.CodFormaTributacaoExt
                           serv_titulo_iret.CodTipoRendimentoExt
                           serv_titulo_iret.ValorDeducaoBC.

                    recatu1 = recid(serv_titulo_iret).      
                    leave.                             
                end.
                
                if esqcom1[esqpos1] = "Alteracao"
                then do with frame f-serv_titulo_iret on error undo.
                    find serv_titulo_iret where 
                         recid(serv_titulo_iret) = recatu1 exclusive.
                                 
                    disp serv_titulo_iret.TipoOperacaoContaPagRec                                       serv_titulo_iret.codEstabelecimento
                         serv_titulo_iret.CodParceiro
                         serv_titulo_iret.DataOperacaoContaPagRec
                         serv_titulo_iret.NumeroDocumentoContaPagRec
                         serv_titulo_iret.NumeroParcelaContaPagRec
                         serv_titulo_iret.CodItem
                         serv_titulo_iret.VarCodReceita
                         serv_titulo_iret.TipoDocumentoContaPagRec
                         serv_titulo_iret.TipoContaPagRec
                         serv_titulo_iret.DataPagamento
                         serv_titulo_iret.CodImpostoRetido
                         serv_titulo_iret.ValorBaseRetencao
                         serv_titulo_iret.AliquotaRetencao
                         serv_titulo_iret.ValorRetido
                         serv_titulo_iret.ValorDepositoJudicial
                         serv_titulo_iret.CodFormaTributacaoExt
                         serv_titulo_iret.CodTipoRendimentoExt
                         serv_titulo_iret.ValorDeducaoBC.
                         
                    prompt-for serv_titulo_iret.TipoContaPagRec.
                    prompt-for serv_titulo_iret.DataPagamento.
                    prompt-for serv_titulo_iret.CodImpostoRetido.
                    prompt-for serv_titulo_iret.ValorBaseRetencao.
                    prompt-for serv_titulo_iret.AliquotaRetencao.
                    prompt-for serv_titulo_iret.ValorRetido.
                    prompt-for serv_titulo_iret.ValorDepositoJudicial.
                    prompt-for serv_titulo_iret.CodFormaTributacaoExt.
                    prompt-for serv_titulo_iret.CodTipoRendimentoExt.
                    prompt-for serv_titulo_iret.ValorDeducaoBC.
                
                    assign serv_titulo_iret.TipoDocumentoContaPagRec
                           serv_titulo_iret.TipoContaPagRec
                           serv_titulo_iret.DataPagamento
                           serv_titulo_iret.CodImpostoRetido
                           serv_titulo_iret.ValorBaseRetencao
                           serv_titulo_iret.AliquotaRetencao
                           serv_titulo_iret.ValorRetido
                           serv_titulo_iret.ValorDepositoJudicial
                           serv_titulo_iret.CodFormaTributacaoExt
                           serv_titulo_iret.CodTipoRendimentoExt
                           serv_titulo_iret.ValorDeducaoBC.

                
                end.
                
                
            end.
        end.
        if not esqvazio then do:
            disp serv_titulo_iret.TipoOperacaoContaPagRec
                 column-label "Oper."
                 serv_titulo_iret.codEstabelecimento
                 format "x(8)" column-label "Estab."
                 serv_titulo_iret.CodParceiro
                 format "x(8)" column-label "Parceiro"
                 serv_titulo_iret.DataOperacaoContaPagRec
                 column-label "Dt Oper."
                 serv_titulo_iret.NumeroDocumentoContaPagRec
                 format "x(8)" column-label "Num Doc"
                 serv_titulo_iret.NumeroParcelaContaPagRec
                 column-label "Num Parc"
                 serv_titulo_iret.codItem
                 format "x(8)" column-label "Item"
                 serv_titulo_iret.varcodReceita
                 format "x(8)" column-label "Cod. Receita"
             with frame frame-a.
        end.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(serv_titulo_iret).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.                            
