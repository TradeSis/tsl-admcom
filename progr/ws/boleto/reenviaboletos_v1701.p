
/* buscarplanopagamento */
def new global shared var setbcod       as int.

def var vcod as int64.
def var vnossonumero as int.

{/u/bsweb/progr/bsxml.i}

def var vstatus as char.
def var vmensagem_erro as char.


def shared temp-table ReenviaBoletosEntrada
    field codigo_cpfcnpj as char
    field banco as char
    field nossonumero as char.
 
   
    assign
            vstatus = "S"
            vmensagem_erro = "".


find first reenviaboletosEntrada no-lock no-error.
if avail reenviaboletosEntrada
then do.
    vstatus = "S".
    vcod     =  int(reenviaboletosEntrada.codigo_cpfcnpj) no-error.
   
    if vcod <> 0 and vcod <> ?
    then do.

        find first clien where 
                    clien.clicod = int(reenviaboletosEntrada.codigo_cpfcnpj)
                    no-lock no-error.
    end.
        
    if not avail clien
    then find first clien where 
                clien.ciccgc = reenviaboletosEntrada.codigo_cpfcnpj
                no-lock no-error.

    if not avail clien
    then assign
            vstatus = "E"
            vmensagem_erro = "Cliente " + 
                    reenviaboletosEntrada.codigo_cpfcnpj~ + 
            " nao encontrado.".

end.
else assign
        vstatus = "E"
        vmensagem_erro = "Parametros de Entrada nao recebidos.".


     
BSXml("ABREXML","").
bsxml("abretabela","ReenviaBoletosRetorno").
bsxml("status",vstatus).
bsxml("mensagem_erro",vmensagem_erro).
bsxml("NomeMetodo","ReenviaBoletos").
bsxml("NomeWebService","Boleto").



if vstatus = "S"
then do:

    bsxml("abreregistro","BoletosCliente").


    for each banboleto where
        banboleto.clifor = clien.clicod and
        banboleto.dtpagamento = ?
        no-lock.

        vnossonumero = int(reenviaboletosentrada.nossonumero) no-error.
         if vnossonumero <> ? and vnossonumero <> 0
         then do:
            if vnossonumero <> banboleto.nossonumero
            then next.
         end.
        find banco where banco.bancod = banboleto.bancod no-lock.
        find banCarteira of banBoleto no-lock.
        
        BSXml("ABREREGISTRO","Boleto"). 
            bsxml("Banco",string(banco.numban,"999")).
            bsxml("Agencia",string(banboleto.agencia)).
            bsxml("codigoCedente",banCarteira.banCedente).
            bsxml("contaCorrente",string(banboleto.contacor)).
            bsxml("Carteira",banboleto.banCart).
            bsxml("nossoNumero",string(banBoleto.nossonumero,"99999999")).
            bsxml("DVnossoNumero",string(banBoleto.DvNossoNumero)).
            bsxml("dtEmissao",string(month(banboleto.dtemissao),"99") +
                              string(day(  banboleto.dtemissao),"99") +
                              string(year(banboleto.dtemissao ),"9999")). 
            bsxml("dtVencimento",string(month(banboleto.dtvencimento),"99") +
                              string(day(  banboleto.dtvencimento),"99") +
                              string(year(banboleto.dtvencimento ),"9999")). 
            bsxml("fatorVencimento",string(banboleto.fatorVencimento,"9999")).
            bsxml("numeroDocumento",banboleto.Documento).
            bsxml("sacadoNome",clien.clinom).
            bsxml("sacadoEndereco",clien.endereco[1]).
            bsxml("sacadoCEP",string(clien.cep[1],"99999999")).
            bsxml("linhaDigitavel",banboleto.linhaDigitavel).
            bsxml("codigoBarras",banboleto.codigoBarras).
            bsxml("VlPrincipal",string(banboleto.vlCobrado,">>>>>>>9.99")).
        BSXml("FECHAREGISTRO","Boleto"). 
    
    end.

    bsxml("fecharegistro","BoletosCliente").
end.

bsxml("fechatabela","ReenviaBoletosRetorno").
BSXml("FECHAXML","").

