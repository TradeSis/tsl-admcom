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
def var tipoOper        as int.
def var esqcom1         as char format "x(12)" extent 5
    initial ["Inclusao","Alteracao"," "," "," "].
def var esqcom2         as char format "x(12)" extent 5
            initial ["  "," ","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial ["Inclusao do Processo",
             "Alteracao do Processo",
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

def buffer bserv_titulo_proc for serv_titulo_proc.


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

tipoOper = if avail servi_titulo and 
                    servi_titulo.tipoOperacao = 'R' then 0 else 1.

bl-princ:
repeat:
    
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ? then
        if esqascend then
            find first serv_titulo_proc where
           serv_titulo_proc.TipoOperacao = tipoOper
 and serv_titulo_proc.codEstabelecimento = servi_titulo.codEstabelecimento
 and serv_titulo_proc.codParceiro = servi_titulo.codparceiro
 and serv_titulo_proc.dataOperacao = servi_titulo.dataOperacao
 and serv_titulo_proc.numeroDocumento = servi_titulo.numeroDocumento
 and serv_titulo_proc.numeroParcela = servi_titulo.numeroParcela
            no-lock no-error.
        else
            find last serv_titulo_proc where
      serv_titulo_proc.TipoOperacao = tipoOper
 and serv_titulo_proc.codEstabelecimento = servi_titulo.codEstabelecimento
 and serv_titulo_proc.codParceiro = servi_titulo.codparceiro
 and serv_titulo_proc.dataOperacao = servi_titulo.dataOperacao
 and serv_titulo_proc.numeroDocumento = servi_titulo.numeroDocumento
 and serv_titulo_proc.numeroParcela = servi_titulo.numeroParcela
                      no-lock no-error.
    else
        find serv_titulo_proc where 
             recid(serv_titulo_proc) = recatu1 no-lock no-error.

    if not avail serv_titulo_proc then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio then do:
        
        disp serv_titulo_proc.TipoOperacao
             column-label "Oper."
             serv_titulo_proc.codEstabelecimento
             format "x(8)" column-label "Estab."
             serv_titulo_proc.CodParceiro
             format "x(8)" column-label "Parceiro"
             serv_titulo_proc.DataOperacao
             column-label "Dt Oper."
             serv_titulo_proc.NumeroDocumento
             format "x(8)" column-label "Num Doc"
             serv_titulo_proc.NumeroParcela
             column-label "Num Parc"
             serv_titulo_proc.codItem
             format "x(8)" column-label "Item"
             serv_titulo_proc.numeroProcesso
             format "x(8)" column-label "Num Proc"                  
        with frame frame-a 11 down centered row 5 width 80
        title " Processos do item " +
        string(servi_titulo.descricao, "x(30)") + " ".   
             
    end.

    recatu1 = recid(serv_titulo_proc).
    if esqregua then 
        color display message esqcom1[esqpos1] with frame f-com1.
    else 
        color display message esqcom2[esqpos2] with frame f-com2.
    
    if not esqvazio then repeat:
        if esqascend then
            find next serv_titulo_proc where
      serv_titulo_proc.TipoOperacao = tipoOper
  and serv_titulo_proc.codEstabelecimento = servi_titulo.codEstabelecimento
  and serv_titulo_proc.codParceiro = servi_titulo.codparceiro
  and serv_titulo_proc.dataOperacao = servi_titulo.dataOperacao
  and serv_titulo_proc.numeroDocumento = servi_titulo.numeroDocumento
  and serv_titulo_proc.numeroParcela = servi_titulo.numeroParcela
    no-lock no-error.
        else
            find prev serv_titulo_proc where
       serv_titulo_proc.TipoOperacao = tipoOper
   and serv_titulo_proc.codEstabelecimento = servi_titulo.codEstabelecimento
   and serv_titulo_proc.codParceiro = servi_titulo.codparceiro
   and serv_titulo_proc.dataOperacao = servi_titulo.dataOperacao
   and serv_titulo_proc.numeroDocumento = servi_titulo.numeroDocumento
   and serv_titulo_proc.numeroParcela = servi_titulo.numeroParcela
    no-lock no-error.

        if not avail serv_titulo_proc then leave.
        if frame-line(frame-a) = frame-down(frame-a) then leave.
        down with frame frame-a.
        

        disp serv_titulo_proc.TipoOperacao
             column-label "Oper."
             serv_titulo_proc.codEstabelecimento
             format "x(8)" column-label "Estab."
             serv_titulo_proc.CodParceiro
             format "x(8)" column-label "Parceiro"
             serv_titulo_proc.DataOperacao
             column-label "Dt Oper"                                                         serv_titulo_proc.NumeroDocumento
             format "x(8)" column-label "Num Doc"
             serv_titulo_proc.NumeroParcela
             column-label "Num Parc"
             serv_titulo_proc.codItem
             format "x(8)" column-label "Item"
             serv_titulo_proc.numeroProcesso
             format "x(8)" column-label "Num Proc"
             with frame frame-a.
                                      
    end.
    if not esqvazio then 
        up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        if not esqvazio then do:
            
            find serv_titulo_proc where 
                 recid(serv_titulo_proc) = recatu1 no-lock no-error.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> "" then
                                            serv_titulo_proc.codEstabelecimento
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> "" then
                                            serv_titulo_proc.codEstabelecimento
                                        else "".

            choose field serv_titulo_proc.tipoOperacao help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return) .

            status default "".

        end.
        
        {esquema.i &tabela = "serv_titulo_proc"
                   &campo  = "serv_titulo_proc.tipoOperacao"
 &where  = "serv_titulo_proc.TipoOperacao = tipoOper
 and serv_titulo_proc.codEstabelecimento = servi_titulo.codEstabelecimento
 and serv_titulo_proc.codParceiro = servi_titulo.codparceiro
 and serv_titulo_proc.dataOperacao = servi_titulo.dataOperacao
 and serv_titulo_proc.numeroDocumento = servi_titulo.numeroDocumento
 and serv_titulo_proc.numeroParcela = servi_titulo.numeroParcela"
                   &frame  = "frame-a"}

        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do on error undo, retry on endkey undo, leave:
            
            form  
            with frame f-serv_titulo_proc  color black/cyan centered  
            row 5 side-labels width 80 1 down.
            
            hide frame frame-a no-pause.
            if esqregua
            then do:                                   
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = "Inclusao" or esqvazio
                then do with frame f-serv_titulo_proc side-labels
                on error undo.
                    
                              
                    create serv_titulo_proc.
assign serv_titulo_proc.TipoOperacao =  tipoOper
       serv_titulo_proc.codEstabelecimento = servi_titulo.codEstabelecimento
       serv_titulo_proc.CodParceiro = servi_titulo.codParceiro
       serv_titulo_proc.DataOperacao = servi_titulo.dataOperacao
       serv_titulo_proc.NumeroDocumento = servi_titulo.numeroDocumento
       serv_titulo_proc.NumeroParcela = servi_titulo.numeroParcela.

                    disp serv_titulo_proc.TipoOperacao
                         serv_titulo_proc.codEstabelecimento
                         serv_titulo_proc.CodParceiro
                         serv_titulo_proc.DataOperacao
                         serv_titulo_proc.NumeroDocumento
                         serv_titulo_proc.NumeroParcela.
       


                    do on error undo, retry:
                        prompt-for serv_titulo_proc.CodItem.
                        
                        if input serv_titulo_proc.CodItem <> "" or
                           length(input serv_titulo_proc.CodItem) < 1
                           then do:
                            message "Cod. Item deve ser informado."
                                    view-as alert-box.
                            undo, retry.                                    
                        end.
                    end.
                    
                    prompt-for serv_titulo_proc.NumeroProcesso.
                    prompt-for serv_titulo_proc.DataPagamentoAdvogado.
                    prompt-for serv_titulo_proc.ValorServicoAdvocaticio.
                    prompt-for serv_titulo_proc.CodMunicipioIBGE.
                    prompt-for serv_titulo_proc.CodParceiroAdv.
                    prompt-for serv_titulo_proc.CodSuspensao.
                    prompt-for serv_titulo_proc.TipoDocumento.
                    prompt-for serv_titulo_proc.Tipo.
                    prompt-for serv_titulo_proc.TipoProcesso.
              
                    assign serv_titulo_proc.CodItem
                           serv_titulo_proc.NumeroProcesso
                           serv_titulo_proc.DataPagamentoAdvogado
                           serv_titulo_proc.ValorServicoAdvocaticio
                           serv_titulo_proc.CodMunicipioIBGE
                           serv_titulo_proc.CodParceiroAdv
                           serv_titulo_proc.CodSuspensao
                           serv_titulo_proc.TipoDocumento
                           serv_titulo_proc.Tipo
                           serv_titulo_proc.TipoProcesso.

                    recatu1 = recid(serv_titulo_proc).      
                    leave.                             
                end.
                
                if esqcom1[esqpos1] = "Alteracao"
                then do with frame f-serv_titulo_proc on error undo.
                    find serv_titulo_proc where 
                         recid(serv_titulo_proc) = recatu1 exclusive.
                    
                    disp serv_titulo_proc.TipoOperacao
                         serv_titulo_proc.codEstabelecimento
                         serv_titulo_proc.CodParceiro
                         serv_titulo_proc.DataOperacao
                         serv_titulo_proc.NumeroDocumento
                         serv_titulo_proc.NumeroParcela
                         serv_titulo_proc.CodItem
                         serv_titulo_proc.NumeroProcesso
                         serv_titulo_proc.DataPagamentoAdvogado
                         serv_titulo_proc.ValorServicoAdvocaticio
                         serv_titulo_proc.CodMunicipioIBGE
                         serv_titulo_proc.CodParceiroAdv
                         serv_titulo_proc.CodSuspensao
                         serv_titulo_proc.TipoDocumento
                         serv_titulo_proc.Tipo
                         serv_titulo_proc.TipoProcesso.
                           
                               
                    prompt-for serv_titulo_proc.DataPagamentoAdvogado.
                    prompt-for serv_titulo_proc.ValorServicoAdvocaticio.
                    prompt-for serv_titulo_proc.CodMunicipioIBGE.
                    prompt-for serv_titulo_proc.CodParceiroAdv.
                    prompt-for serv_titulo_proc.CodSuspensao.
                    prompt-for serv_titulo_proc.TipoDocumento.
                    prompt-for serv_titulo_proc.Tipo.
                    prompt-for serv_titulo_proc.TipoProcesso.
                                                
                    assign serv_titulo_proc.DataPagamentoAdvogado
                           serv_titulo_proc.ValorServicoAdvocaticio
                           serv_titulo_proc.CodMunicipioIBGE
                           serv_titulo_proc.CodParceiroAdv
                           serv_titulo_proc.CodSuspensao
                           serv_titulo_proc.TipoDocumento
                           serv_titulo_proc.Tipo
                           serv_titulo_proc.TipoProcesso.
                end.
                
            end.
        end.
        if not esqvazio then do:
             disp serv_titulo_proc.TipoOperacao
                  column-label "Oper."
                  serv_titulo_proc.codEstabelecimento
                  format "x(8)" column-label "Estab."
                  serv_titulo_proc.CodParceiro
                  format "x(8)" column-label "Parceiro"
                  serv_titulo_proc.DataOperacao
                  column-label "Dt Oper."
                  serv_titulo_proc.NumeroDocumento
                  format "x(8)" column-label "Num Doc"
                  serv_titulo_proc.NumeroParcela
                  column-label "Num Parc"
                  serv_titulo_proc.codItem
                  format "x(8)" column-label "Item"
                  serv_titulo_proc.numeroProcesso
                  format "x(8)" column-label "Num Proc"
                  with frame frame-a.
        end.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(serv_titulo_proc).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.                            
