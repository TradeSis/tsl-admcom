
/* buscarplanopagamento */
def new global shared var setbcod       as int.

{/u/bsweb/progr/bsxml.i}

def var vtipo as char.
def var vstatus as char.
def var vmensagem_erro as char.

def var par-recid-boleto as recid.
def var vdtvencimento as date.

def var par-tabelaorigem as char.
def var par-chaveorigem as char.
def var par-dadosorigem as char.
def var par-valorOrigem  as dec.

def buffer bclien for clien.
def shared temp-table GeraBoletoEntrada
    field CNPJ_CPF as char
    field IDAcordo as char
    field NumeroParcela as char
    field Vencimento as char
    field Valor as char.
 
    assign
            vstatus = "S"
            vmensagem_erro = "".

vtipo = "NOV".

find first geraboletoEntrada no-error.
if avail GeraBoletoEntrada 
then do.
    find first clien where clien.ciccgc = GeraBoletoEntrada.cnpj_cpf
            no-lock no-error.
    if not avail clien
    then assign
            vstatus = "N"
            vmensagem_erro = "Cliente Nao Encontrado".

    if avail clien
    then do:
        find first CybAcordo where
            cybAcordo.idacordo = int(geraboletoEntrada.idacordo)
                no-lock no-error.
        if not avail cybacordo
        then do:
            vstatus = "N".
            vmensagem_erro = "Acordo " + geraboletoentrada.idacordo +
                             " nao existe.".
        end.
        else do:
            
            if cybacordo.tipo <> "" /* promessa */
            then vtipo = cybacordo.tipo.
            
            if cybacordo.clifor <> clien.clicod
            then do:
                find bclien where bclien.clicod = cybacordo.clifor
                    no-lock.
                vstatus = "N".
                vmensagem_erro = "Acordo " + geraboletoentrada.idacordo +
                             " eh do cliente " +
                             bclien.ciccgc + " " +
                             bclien.clinom.
            end.
            else do: 
             find first cybAcParcela of cybAcordo where
                 cybAcParcela.parcela = int(geraboletoEntrada.numeroparcela)
                 no-lock no-error.
             if not avail cybacParcela and not vtipo = "PRO"
             then do:
                 vstatus = "N".
                 vmensagem_erro = "Parcela " + geraboletoEntrada.numeroparcela +
                                 " Nao Existe no Acordo " +
                             geraboletoEntrada.idacordo.
             end.      
             else do:
                vdtvencimento = 
                    date(int(substr(geraboletoentrada.vencimento,1,2)),
                     int(substr(geraboletoentrada.vencimento,3,2)),
                     int(substr(geraboletoentrada.vencimento,5,4))). 
                if vdtvencimento < today
                then do:
                    vstatus = "N".
                    vmensagem_erro = "Vencimento ANTERIOR a Hoje " +
                            string(vdtvencimento,"99/99/9999").
                end.
                /**
                if cybacparcela.vlcobrado <> 
                        dec(geraboletoentrada.vlprincipal)
                then do:
                    vstatus = "N".
                    vmensagem_erro = "Valor da parcela eh " +
                            string(cybacparcela.vlcobrado,">>>>,>>9.99").
                end.
                **/
                
             end.
            end.    
        end.
    end.                                         

end.
else assign
        vstatus = "E"
        vmensagem_erro = "Parametros de Entrada nao recebidos.".


if vstatus = "S"
then do:
    if vtipo <> "PRO"
    then do:
        par-tabelaorigem = "cybacparcela".
        par-chaveOrigem  = "idacordo,parcela".
        par-dadosOrigem  = string(cybacordo.idacordo) + "," +
                       string(cybacparcela.parcela).
        par-valorOrigem  = cybacparcela.vlcobrado + cybacparcela.vljuro. /* helio 0310 */
    
        find first banbolOrigem 
            where banbolorigem.tabelaOrigem = par-tabelaOrigem and
                  banbolorigem.chaveOrigem  = par-chaveOrigem and
                  banbolorigem.dadosOrigem  = par-dadosOrigem 
            no-lock no-error.
        if avail banBolOrigem
        then do:
            vstatus = "N".
            vmensagem_erro = "Boleto " + 
                            string(banbolorigem.nossonumero,"99999999")
                         + " ja foi emitido para esta solicitacao.".
            find banboleto of banbolOrigem no-lock.
            par-recid-Boleto = recid(banboleto).                         
        end.
    end.
end.



if vstatus = "S"
then do:
    vdtvencimento = date(int(substr(geraboletoentrada.vencimento,1,2)),
                     int(substr(geraboletoentrada.vencimento,3,2)),
                     int(substr(geraboletoentrada.vencimento,5,4))). 
    
    run bol/geradadosboleto_v1701.p (
                    input ?, /* Banco do Boleto */
                    input ?,      /* Bancarteira especifico */
                    input "WSCyberBoleto",
                    input clien.clicod,
                    input replace(par-dadosOrigem,",","/"),
                    input vdtvencimento,
                    input dec(geraboletoentrada.valor),
                    output par-recid-boleto,
                    output vstatus,
                    output vmensagem_erro).

    find banBoleto where recid(banBoleto) = par-recid-boleto no-lock
        no-error.
    if vstatus = "S" and avail banBoleto
    then do: 
        if vtipo = "PRO"
        then do:
            for each CSLpromessa of cybacordo no-lock.
                par-tabelaorigem = "promessa".
                par-chaveOrigem  = "idacordo,contnum,parcela".
                par-dadosOrigem  = string(cybacordo.idacordo)   + "," +
                               string(cslpromessa.contnum) + "," +
                               string(cslpromessa.parcela) .
                par-valorOrigem  = cslpromessa.vlcobrado + cslpromessa.vljuro. /* helio 0310 */
                run bol/vinculaboleto_v2101.p (
                        input recid(banBoleto),
                        input par-tabelaorigem,
                        input par-chaveorigem,
                        input par-dadosorigem,
                        input par-valorOrigem,
                        output vstatus,
                        output vmensagem_erro).
            end.
        end.
        else do:
            run bol/vinculaboleto_v2101.p (
                    input recid(banBoleto),
                    input par-tabelaorigem,
                    input par-chaveorigem,
                    input par-dadosorigem,
                    input par-valorOrigem,
                    output vstatus,
                    output vmensagem_erro).
        end.
        
    end.
end.

BSXml("ABREXML","").
bsxml("abretabela","GeraBoletoRetorno").
bsxml("status",vstatus).
bsxml("mensagem_erro",vmensagem_erro).
bsxml("NomeMetodo","geraboleto").
bsxml("NomeWebService","cyberboleto").


    find banBoleto where recid(banBoleto) = par-recid-boleto no-lock no-error.
    if not avail banBoleto
    then do:
        BSXml("ABREREGISTRO","Boleto"). 
            bsxml("Banco","001").
            bsxml("Agencia","").
            bsxml("codigoCedente","").
            bsxml("contaCorrente","").
            bsxml("Carteira","").
            bsxml("nossoNumero","").
            bsxml("DVnossoNumero","").
            bsxml("dtEmissao","").
            bsxml("dtVencimento","").
            bsxml("fatorVencimento","").
            bsxml("numeroDocumento","").
            bsxml("sacadoNome","").
            bsxml("sacadoEndereco","").
            bsxml("sacadoCEP","").
            bsxml("sacadoCidade","").
            bsxml("sacadoUF","").
            bsxml("linhaDigitavel","").
            bsxml("codigoBarras","").
            bsxml("VlPrincipal","").
        BSXml("FECHAREGISTRO","Boleto"). 
    end.
    else do:
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

            bsxml("CNPJ_CPF",clien.ciccgc).
            bsxml("sacadoNome",texto(clien.clinom)).
            bsxml("sacadoEndereco",texto(clien.endereco[1])).
            bsxml("sacadoCEP",string(clien.cep[1],"99999999")).
            bsxml("sacadoCidade",texto(string(clien.cidade[1]))).
            bsxml("sacadoUF",string(clien.uf[1])).
            
            bsxml("linhaDigitavel",banboleto.linhaDigitavel).
            bsxml("codigoBarras",banboleto.codigoBarras).
            bsxml("VlPrincipal",string(banboleto.vlCobrado,">>>>>>>9.99")).
        BSXml("FECHAREGISTRO","Boleto"). 
    
    end.

bsxml("fechatabela","GeraBoletoRetorno").
BSXml("FECHAXML","").

