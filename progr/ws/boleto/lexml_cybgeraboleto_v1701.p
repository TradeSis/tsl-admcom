
def input parameter p-arquivo as char.
def var vtabela as char.
def var Hdoc   as handle.
def var Hroot  as handle.

create x-document HDoc.
Hdoc:load("file",p-arquivo,false).
create x-noderef hroot.
hDoc:get-document-element(hroot).

def shared temp-table GeraBoletoEntrada
    field CNPJ_CPF as char
    field IDAcordo as char
    field NumeroParcela as char
    field Vencimento as char
    field Valor as char.
    
create GeraBoletoEntrada.

run obtemnode (input hroot).


procedure obtemnode.
    
    def input parameter vh as handle.
    def var hc as handle.
    def var loop  as int.
            
    create x-noderef hc.
                   
    do loop = 1 to vh:num-children.
    
/**        message loop hc:subtype vh:name. **/
        vh:get-child(hc,loop).
        if hc:subtype = "Element"
        then do:
            if vh:name = "GeraBoletoEntrada"
            then do:
                vtabela = "GeraBoletoEntrada".
            end.
            
        end.
    
        if hc:subtype = "text"
        then do:
            if vtabela = "GeraBoletoEntrada"
            then do:
                case vh:name:
                when "CNPJ_CPF"        
                    then GeraBoletoEntrada.CNPJ_CPF = hc:node-value.
                when "IDAcordo"       
                    then GeraBoletoEntrada.IDAcordo = hc:node-value.
                when "NumeroParcela"      
                    then GeraBoletoEntrada.NumeroParcela = hc:node-value.
                when "Vencimento"        
                    then GeraBoletoEntrada.Vencimento = hc:node-value.
                when "Valor"           
                    then GeraBoletoEntrada.Valor = hc:node-value.
                end case.
            end.
            
        end.

        run obtemnode (input hc:handle).
    
    end.
    
    
end procedure.