
def input parameter p-arquivo as char.
def var vtabela as char.
def var Hdoc   as handle.
def var Hroot  as handle.

create x-document HDoc.
Hdoc:load("file",p-arquivo,false).
create x-noderef hroot.
hDoc:get-document-element(hroot).



def var vtitnum as char.
   def var vNumeroParcela as char.
    def var vVencimento as char .
    def var vVlPrincipal as char.
    def var vVlJuros as char.
    def var vVlMulta as char.
    def var vVlHonorarios as char.
    def var vVlEncargos as char.
    


def var vgrupo as char.
def var vcontrato as char.

def shared temp-table GravaPromessaEntrada
    field CNPJ_CPF as char
    field IDAcordo as char
    field DataAcordo as char
    field QtdContratosPromessa as char
    field VlPrincipal as char
    field VlJuros   as char
    field VlMulta   as char
    field VlHonorarios as char
    field VlEncargos as char
    field VlTotalAcordo as char
    field VlDesconto as char
    field OrigemAcordo as char.


def shared temp-table ContratosPromessa
    field grupo as char
    field NumeroContrato as char.


def shared temp-table ParcelasPromessa
    field NumeroParcela as char
    field Vencimento as char 
    field VlPrincipal as char
    field VlJuros as char
    field VlMulta as char
    field VlHonorarios as char
    field VlEncargos as char
    field NumeroContrato as char.


    
create GravaPromessaEntrada.

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
            if vh:name = "GravaPromessaEntrada"
            then do:
                vtabela = "GravaPromessaEntrada".
            end.
            if vh:name = "Contrato"
            then do:
                vtabela = "ContratosPromessa".
            end.
            if vh:name = "Parcela"
            then do:
                vtabela = "ParcelasPromessa".
            end.
            
        end.
    
        if hc:subtype = "text"
        then do:
            if vtabela = "GravaPromessaEntrada"
            then do:
                case vh:name:
                when "CNPJ_CPF"        
                    then GravaPromessaEntrada.CNPJ_CPF = hc:node-value.
                when "IDAcordo"       
                    then GravaPromessaEntrada.IDAcordo = hc:node-value.
                when "DataAcordo"      
                    then GravaPromessaEntrada.DataAcord = hc:node-value.
                when "QtdContratosPromessa"        
                    then GravaPromessaEntrada.QtdContratosPromessa = hc:node-value.
                when "VlPrincipal"           
                    then GravaPromessaEntrada.VlPrincipal = hc:node-value.
                when "VlJuros"           
                    then GravaPromessaEntrada.VlJuros = hc:node-value.
                when "VlMulta"           
                    then GravaPromessaEntrada.VlMulta = hc:node-value.
                when "VlHonorarios"           
                    then GravaPromessaEntrada.VlHonorarios = hc:node-value.
                when "VlEncargos"           
                    then GravaPromessaEntrada.VlEncargos = hc:node-value.
                when "VlTotalAcordo"           
                    then GravaPromessaEntrada.VlTotalAcordo = hc:node-value.
                when "VlDesconto"           
                    then GravaPromessaEntrada.VlDesconto = hc:node-value.
                when "OrigemAcordo"           
                    then GravaPromessaEntrada.OrigemAcordo = hc:node-value.
                end case.
            end.
            if vtabela = "ContratosPromessa"
            then do: 
                case vh:name:
                when "grupo"       then vgrupo      = hc:node-value. 
                when "NumeroContrato" then  do:
                      create ContratosPromessa.
                      ContratosPromessa.grupo     = vgrupo.  
                      ContratosPromessa.NumeroContrato  = hc:node-value.
                      vtitnum = ContratosPromessa.NumeroContrato.
                end.                    
                end case.
            end.

            if vtabela = "ParcelasPromessa"
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
                      create ParcelasPromessa.
                      parcelasPromessa.NumeroContrato = vtitnum.
                      ParcelasPromessa.NumeroParcela = vNumeroParcela.
                      ParcelasPromessa.Vencimento    = vvencimento .
                      ParcelasPromessa.VlPrincipal   = vvlprincipal .
                      ParcelasPromessa.VlJuros       = vvljuros .
                      ParcelasPromessa.VlMulta       = vvlmulta .
                      ParcelasPromessa.VlHonorarios  = vvlhonorarios .
                      ParcelasPromessa.VlEncargos    = vvlencargos.
                      
                end.                    
                end case.
            end.
            
        end.

        run obtemnode (input hc:handle).
    
    end.
    
    
end procedure.