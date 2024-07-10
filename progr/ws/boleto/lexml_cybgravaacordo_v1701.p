
def input parameter p-arquivo as char.
def var vtabela as char.
def var Hdoc   as handle.
def var Hroot  as handle.

create x-document HDoc.
Hdoc:load("file",p-arquivo,false).
create x-noderef hroot.
hDoc:get-document-element(hroot).



def shared temp-table ParcelasAcordo
    field NumeroParcela as char
    field Vencimento as char 
    field VlPrincipal as char
    field VlJuros as char
    field VlMulta as char
    field VlHonorarios as char
    field VlEncargos as char.

   def var vNumeroParcela as char.
    def var vVencimento as char .
    def var vVlPrincipal as char.
    def var vVlJuros as char.
    def var vVlMulta as char.
    def var vVlHonorarios as char.
    def var vVlEncargos as char.
    

def shared temp-table ContratosOrigem
    field grupo as char
    field NumeroContrato as char.

def var vgrupo as char.
def var vcontrato as char.

def shared temp-table GravaAcordoEntrada
    field CNPJ_CPF as char
    field IDAcordo as char
    field DataAcordo as char
    field QtdContratosOrigem as char
    field VlPrincipal as char
    field VlJuros   as char
    field VlMulta   as char
    field VlHonorarios as char
    field VlEncargos as char
    field VlTotalAcordo as char
    field VlDesconto as char
    field OrigemAcordo as char.

    
create GravaAcordoEntrada.

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
            if vh:name = "GravaAcordoEntrada"
            then do:
                vtabela = "GravaAcordoEntrada".
            end.
            if vh:name = "Contrato"
            then do:
                vtabela = "ContratosOrigem".
            end.
            if vh:name = "Parcela"
            then do:
                vtabela = "ParcelasAcordo".
            end.
            
        end.
    
        if hc:subtype = "text"
        then do:
            if vtabela = "GravaAcordoEntrada"
            then do:
                case vh:name:
                when "CNPJ_CPF"        
                    then GravaAcordoEntrada.CNPJ_CPF = hc:node-value.
                when "IDAcordo"       
                    then GravaAcordoEntrada.IDAcordo = hc:node-value.
                when "DataAcordo"      
                    then GravaAcordoEntrada.DataAcord = hc:node-value.
                when "QtdContratosOrigem"        
                    then GravaAcordoEntrada.QtdContratosOrigem = hc:node-value.
                when "VlPrincipal"           
                    then GravaAcordoEntrada.VlPrincipal = hc:node-value.
                when "VlJuros"           
                    then GravaAcordoEntrada.VlJuros = hc:node-value.
                when "VlMulta"           
                    then GravaAcordoEntrada.VlMulta = hc:node-value.
                when "VlHonorarios"           
                    then GravaAcordoEntrada.VlHonorarios = hc:node-value.
                when "VlEncargos"           
                    then GravaAcordoEntrada.VlEncargos = hc:node-value.
                when "VlTotalAcordo"           
                    then GravaAcordoEntrada.VlTotalAcordo = hc:node-value.
                when "VlDesconto"           
                    then GravaAcordoEntrada.VlDesconto = hc:node-value.
                when "OrigemAcordo"           
                    then GravaAcordoEntrada.OrigemAcordo = hc:node-value.
                end case.
            end.
            if vtabela = "ContratosOrigem"
            then do: 
                case vh:name:
                when "grupo"       then vgrupo      = hc:node-value. 
                when "NumeroContrato" then  do:
                      create ContratosOrigem.
                      ContratosOrigem.grupo     = vgrupo.  
                      ContratosOrigem.NumeroContrato  = hc:node-value.
                end.                    
                end case.
            end.

            if vtabela = "ParcelasAcordo"
            then do: 
                case vh:name:
                when "NumeroParcela"       then vNumeroParcela = hc:node-value. 
                when "Vencimento"          then vvencimento = hc:node-value. 
                when "VlPrincipal"         then vVlPrincipal = hc:node-value. 
                when "VlJuros"             then vvljuros = hc:node-value. 
                when "VlMulta"             then vvlmulta = hc:node-value. 
                when "VlHonorarios"        then vvlhonorarios = hc:node-value. 
                
                when "VlEncargos" then  do:
                      vvlencargos = hc:node-value.
                      create ParcelasAcordo.
                      ParcelasAcordo.NumeroParcela = vNumeroParcela.
                      ParcelasAcordo.Vencimento    = vvencimento .
                      ParcelasAcordo.VlPrincipal   = vvlprincipal .
                      ParcelasAcordo.VlJuros       = vvljuros .
                      ParcelasAcordo.VlMulta       = vvlmulta .
                      ParcelasAcordo.VlHonorarios  = vvlhonorarios .
                      ParcelasAcordo.VlEncargos    = vvlencargos.
                      
                end.                    
                end case.
            end.
            
        end.

        run obtemnode (input hc:handle).
    
    end.
    
    
end procedure.