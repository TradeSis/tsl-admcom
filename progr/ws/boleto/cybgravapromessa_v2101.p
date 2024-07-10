
/* grava boleto cslog */
def new global shared var setbcod       as int.

{/u/bsweb/progr/bsxml.i}

def var vstatus as char.
def var vmensagem_erro as char.
def var vetbcod as int.
def var vcontnum as int.

def var vpromessacslog as log.


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


find first ContratosPromessa no-error.
find first GravaPromessaEntrada no-lock no-error.
find first ParcelasPromessa no-lock no-error.
if avail GravaPromessaEntrada and
   avail ContratosPromessa and
   avail ParcelasPromessa
then do.
    find first clien where clien.ciccgc = GravaPromessaEntrada.cnpj_cpf
            no-lock no-error.
    if not avail clien
    then assign
            vstatus = "N"
            vmensagem_erro = "Cliente Nao Encontrado".
    else assign
            vstatus = "S"
            vmensagem_erro = "".
            
    /* cslog */
    /***
    vpromessacslog = no. 
    if int64(GravaPromessaEntrada.IDAcordo) >= 90000000 and 
       int64(GravaPromessaEntrada.IDAcordo) <= 99999999  
    then 
    ***/
    vpromessacslog = yes. /* WS DE PROMESSA*/
    
    for each ContratosPromessa.
        vetbcod   = int(substr(ContratosPromessa.numeroContrato,1,3)).
        vcontnum  = int(substr(ContratosPromessa.NumeroContrato,4)).
        find contrato where contrato.contnum = vcontnum no-lock no-error.
        if not avail contrato
        then do:
            vstatus = "N".
            vmensagem_erro = vmensagem_erro + 
                        (if vmensagem_erro = ""
                        then ""
                        else " - ")
                    + "Contrato Origem Inexistente".
            leave.            
        end.
    end.

end.
else assign
        vstatus = "E"
        vmensagem_erro = "Parametros de Entrada nao recebidos.".




if vstatus = "S"
then do:
    
    
    
    /**if vpromessacslog 
    *then do:
    *    
    *    run csl/gravapromessa_v2001.p ( output vstatus, output vmensagem_erro).
    *end.    
    *else run bol/gravacybacordo_v1701.p (output vstatus, 
    *                                     output vmensagem_erro).
    **/
    
    run csl/gravapromessa_v2101.p ( output vstatus, output vmensagem_erro). /* 2101 versao deste ws */

end.




BSXml("ABREXML","").
bsxml("abretabela","GravaPromessaRetorno").
bsxml("status",vstatus).
bsxml("mensagem_erro",vmensagem_erro).
bsxml("NomeMetodo","GravaPromessa").
bsxml("NomeWebService","cyberboleto").

bsxml("fechatabela","GravaPromessaRetorno").
BSXml("FECHAXML","").

