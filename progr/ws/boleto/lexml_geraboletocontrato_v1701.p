
def input parameter p-arquivo as char.
def var vtabela as char.
def var Hdoc   as handle.
def var Hroot  as handle.

create x-document HDoc.
Hdoc:load("file",p-arquivo,false).
create x-noderef hroot.
hDoc:get-document-element(hroot).


                                                            
def shared temp-table Parcelas
    field codigo_cpfcnpj as char
    field numero_contrato as char 
    field seq_parcela as char
    field venc_parcela as char
    field vlr_parcela_pago as char.

    def var vcodigo_cpfcnpj as char.
    def var vnumero_contrato as char .
    def var vseq_parcela as char.
    def var vvenc_parcela as char.
    def var vvlr_parcela_pago as char.

def shared temp-table GeraBoletoContratoEntrada
    field codigo_cpfcnpj as char
    field venc_boleto as char
    field vlr_boleto  as char
    field vlr_servicos as char.

create GeraBoletoContratoEntrada.

run obtemnode (input hroot).


procedure obtemnode.
    
    def input parameter vh as handle.
    def var hc as handle.
    def var loop  as int.
            
    create x-noderef hc.
                   
    do loop = 1 to vh:num-children.
    
        vh:get-child(hc,loop).
        if hc:subtype = "Element"
        then do:
            if vh:name = "GeraBoletoContratoEntrada"
            then do:
                vtabela = "GeraBoletoContratoEntrada".
            end.
            if vh:name = "Parcelas"
            then do:
                vtabela = "Parcelas".
            end.
            
        end.
    
        if hc:subtype = "text"
        then do:
        
            if vtabela = "GeraBoletoContratoEntrada"
            then do:
                case vh:name:
                when "codigo_cpfcnpj"        
                    then GeraBoletoContratoEntrada.codigo_cpfcnpj = hc:node-value.
                when "venc_boleto"       
                    then GeraBoletoContratoEntrada.venc_boleto = hc:node-value.
                when "vlr_boleto"      
                    then GeraBoletoContratoEntrada.vlr_boleto = hc:node-value.
                when "vlr_servicos"        
                    then GeraBoletoContratoEntrada.vlr_servicos = hc:node-value.
                end case.
            end.
            if vtabela = "Parcelas"
            then do: 

                case vh:name:
                when "codigo_cpfcnpj"       then vcodigo_cpfcnpj = hc:node-value. 
                when "numero_contrato"      then vnumero_contrato = hc:node-value. 
                when "seq_parcela"          then vseq_parcela = hc:node-value. 
                when "venc_parcela"         then vvenc_parcela = hc:node-value. 
                when "vlr_parcela_pago" then  do:
                      vvlr_parcela_pago = hc:node-value.
                      create Parcelas.
                      Parcelas.codigo_cpfcnpj   = vcodigo_cpfcnpj. 
                      Parcelas.numero_contrato  = vnumero_contrato .
                      Parcelas.seq_parcela      = vseq_parcela .
                      Parcelas.venc_parcela     = vvenc_parcela .
                      Parcelas.vlr_parcela_pago = vvlr_parcela_pago .
                      
                end.                    
                end case.
            end.
            
        end.

        run obtemnode (input hc:handle).
    
    end.
    
    
end procedure.