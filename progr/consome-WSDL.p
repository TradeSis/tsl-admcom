def input parameter par-wsdl as char.
def input parameter par-porta as char.
def input parameter par-metodo as char.
def input parameter par-xml as longchar.
def var hWebService as handle no-undo.
def var hConsultaValor as handle no-undo.
def var ConsultaValor as longchar no-undo.
def output parameter ConsultaValorResposta as longchar no-undo.

ConsultaValor = par-xml.

create server hWebService.
hWebService:connect("-WSDL " + par-wsdl). 
if not hWebService:connected() 
then do:
    message "SERVER: "  
    par-wsdl
    "não conectou".
    pause 0.
    return.
end.    

run value(par-porta) set hConsultaValor on  hWebService.

if not valid-handle(hConsultaValor) 
then do:
    message "Porta: " valid-handle(hConsultaValor) " nao disponivel".
    pause 0.
    return.
end.
                
run value(par-metodo) IN hConsultaValor(input ConsultaValor, 
                                        output ConsultaValorResposta).

if ERROR-STATUS:ERROR 
then message 'Error: ' + ERROR-STATUS:GET-MESSAGE(1).
pause 0. 

delete procedure hConsultaValor.
hWebService:disconnect().
delete object hWebService.

return.
