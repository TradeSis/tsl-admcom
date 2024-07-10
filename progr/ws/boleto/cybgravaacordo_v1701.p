
/* buscarplanopagamento */
def new global shared var setbcod       as int.

{/u/bsweb/progr/bsxml.i}

def var vstatus as char.
def var vmensagem_erro as char.
def var vetbcod as int.
def var vcontnum as int.


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


def shared temp-table ContratosOrigem
    field grupo as char
    field NumeroContrato as char.


def shared temp-table ParcelasAcordo
    field NumeroParcela as char
    field Vencimento as char 
    field VlPrincipal as char
    field VlJuros as char
    field VlMulta as char
    field VlHonorarios as char
    field VlEncargos as char.


find first ContratosOrigem no-error.
find first GravaAcordoEntrada no-lock no-error.
find first ParcelasAcordo no-lock no-error.
if avail GravaAcordoEntrada and
   avail ContratosOrigem and
   avail ParcelasAcordo
then do.
    find first clien where clien.ciccgc = GravaAcordoEntrada.cnpj_cpf
            no-lock no-error.
    if not avail clien
    then assign
            vstatus = "N"
            vmensagem_erro = "Cliente Nao Encontrado".
    else assign
            vstatus = "S"
            vmensagem_erro = "".
            
    for each ContratosOrigem.
        vetbcod   = int(substr(contratosOrigem.numeroContrato,1,3)).
        vcontnum  = int(substr(ContratosOrigem.NumeroContrato,4)).
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

    run bol/gravacybacordo_v1701.p (output vstatus, 
                              output vmensagem_erro).

end.




BSXml("ABREXML","").
bsxml("abretabela","GravaAcordoRetorno").
bsxml("status",vstatus).
bsxml("mensagem_erro",vmensagem_erro).
bsxml("NomeMetodo","gravaacordo").
bsxml("NomeWebService","cyberboleto").

bsxml("fechatabela","GravaAcordoRetorno").
BSXml("FECHAXML","").

