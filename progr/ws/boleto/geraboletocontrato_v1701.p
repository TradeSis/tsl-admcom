/* #1 - helio 05.18 - erro vinculo, Acerto na transacao, tornando-a unica */
/* #2 01.11.2018 Ricardo - TP 27296856 - Aceitar taxa zerada */
/* #3 01.11.2018 Ricardo - TP 27480414 - Gravar VlServico */

/* buscarplanopagamento */
def new global shared var setbcod       as int.

def var vcod as int64.
def var vcontnum as int.
def var vtitpar as int.
def var vvlr_pago as dec.
def var vdtvencimento as date.

{/u/bsweb/progr/bsxml.i}

def var vstatus as char.
def var vmensagem_erro as char.

def var par-rectitulo as recid.
def var par-recid-boleto as recid.

def var par-tabelaorigem as char.
def var par-chaveorigem as char.
def var par-dadosorigem as char.
def var par-valorOrigem  as dec.


                                                            
def shared temp-table Parcelas 
    field codigo_cpfcnpj as char
    field numero_contrato as char 
    field seq_parcela as char
    field venc_parcela as char
    field vlr_parcela_pago as char.

def shared temp-table GeraBoletoContratoEntrada
    field codigo_cpfcnpj as char
    field venc_boleto as char
    field vlr_boleto  as char
    field vlr_servicos as char.
def var vvlr_boleto as dec.
def var vvlr_servicos as dec.

   
   
    assign
            vstatus = "S"
            vmensagem_erro = "".


find first GeraBoletoContratoEntrada no-lock no-error.
if avail GeraBoletoContratoEntrada
then do.
    vstatus = "S".
    vcod     =  int(GeraBoletoContratoEntrada.codigo_cpfcnpj) no-error.
    vdtvencimento = date(int(substr(geraboletocontratoentrada.venc_boleto,1,2)),
                         int(substr(geraboletocontratoentrada.venc_boleto,3,2)),
                         int(substr(geraboletocontratoentrada.venc_boleto,5)))
                         no-error. 
    if vdtvencimento = ?
    then do: 
        vstatus = "E". 
            vmensagem_erro = "Vencimento invalido " + geraboletocontratoentrada.venc_boleto.
    end.
    else 
        if vdtvencimento < today
        then do: 
            vstatus = "E". 
            vmensagem_erro = "Vencimento Boleto " + string(vdtvencimento,"99/99/9999") + 
                             " ANTERIOR a Hoje.".
        end.
    vvlr_boleto = dec(geraboletocontratoentrada.vlr_boleto) no-error.    
    if vvlr_boleto = ? or vvlr_boleto = 0
    then do: 
        vstatus = "E". 
        vmensagem_erro = "Valor Boleto invalido " + geraboletocontratoentrada.vlr_boleto.
    end.
    vvlr_servicos = dec(geraboletocontratoentrada.vlr_servicos) no-error.    
    if vvlr_servicos = ? /*#2 or vvlr_servicos = 0*/
    then do: 
        vstatus = "E". 
            vmensagem_erro = "Valor Servicos invalido " + geraboletocontratoentrada.vlr_servicos.
    end.
   
    if vcod <> 0 and vcod <> ?
    then do.
        find first clien where 
                    clien.clicod = int(GeraBoletoContratoEntrada.codigo_cpfcnpj)
                    no-lock no-error.
    end.
        
    if not avail clien
    then find first clien where 
                clien.ciccgc = GeraBoletoContratoEntrada.codigo_cpfcnpj
                no-lock no-error.

    if not avail clien
    then assign
            vstatus = "E"
            vmensagem_erro = "Cliente " + 
                    GeraBoletoContratoEntrada.codigo_cpfcnpj + 
            " nao encontrado.".

    if vstatus = "S"
    then 
        for each Parcelas.    
            vcontnum =   int(Parcelas.numero_contrato) no-error.
            vtitpar  =   int(Parcelas.seq_parcela) no-error.
            
            if vcontnum <> 0 and vcontnum <> ?
            then do:
                find contrato where contrato.contnum = vcontnum no-lock no-error.
            end.
            if not avail contrato
            then do:
                assign
                    vstatus = "E"
                    vmensagem_erro = "Contrato " + 
                            Parcelas.numero_contrato + 
                            " nao encontrado.".
            end.    
            else do:
                find first  titulo where
                    titulo.empcod = 19 and
                    titulo.titnat = no and
                    titulo.modcod = contrato.modcod and
                    titulo.etbcod = contrato.etbcod and
                    titulo.clifor = contrato.clicod and
                    titulo.titnum = string(contrato.contnum) and
                    titulo.titpar = vtitpar
                    no-lock no-error.
                if not avail titulo
                then do:
                    assign
                        vstatus = "E"
                        vmensagem_erro = "Contrato " + 
                                Parcelas.numero_contrato + 
                                " Parcela " +
                                parcelas.seq_parcela + 
                                " nao encontrada.".
                end.        
                else do:
                    if titulo.titdtpag <> ? or
                       titulo.titsit   <> "LIB"
                    then do:
                        vstatus = "E".
                        vmensagem_erro = "Contrato " + 
                                Parcelas.numero_contrato + 
                                " Parcela " +
                                Parcelas.seq_parcela + 
                                " ja liquidada.".
                    end.   
                    else do:
                        if vvlr_boleto <> 0 and vvlr_boleto <> ?
                        then do:
                            if vvlr_boleto < titulo.titvlcob
                            then do:
                                vstatus = "E".
                                vmensagem_erro = "Valor de " + 
                                        GeraBoletoContratoEntrada.vlr_boleto + 
                                        " insuficiente para pagar Parcela " + Parcelas.seq_parcela.
    
                            end. 
                        end.
                    end.
                end.
            end.
    end. /* each parcelas */
end.
else assign
        vstatus = "E"
        vmensagem_erro = "Parametros de Entrada nao recebidos.".

if vstatus = "S"
then do:    
    run bol/geradadosboleto_v1801.p /* #3 */ (
                    input ?, /* Banco do Boleto */
                    input ?,      /* Bancarteira especifico */
                    input "WSBoleto",
                    input clien.clicod,
                    input clien.clicod,
                    input vdtvencimento,
                    input vvlr_boleto,
                    input vvlr_servicos /* #3 */,
                    output par-recid-boleto,
                    output vstatus,
                    output vmensagem_erro).

            
    find banBoleto where recid(banBoleto) = par-recid-boleto no-lock no-error.
    if avail banboleto
    then do on error undo: /* #1 */   
        for each Parcelas: 
            vvlr_pago =  dec(parcelas.vlr_parcela_pago) no-error. 
            vcontnum =   int(Parcelas.numero_contrato) no-error. 
            vtitpar  =   int(Parcelas.seq_parcela) no-error.
            /*
            find contrato where contrato.contnum = vcontnum
                no-lock no-error.
            if avail contrato
            then do:    
            find first  titulo where
                    titulo.empcod = 19 and
                    titulo.titnat = no and
                    titulo.modcod = contrato.modcod and
                    titulo.etbcod = contrato.etbcod and
                    titulo.clifor = contrato.clicod and
                    titulo.titnum = string(contrato.contnum) and
                    titulo.titpar = vtitpar
                    no-lock no-error.
            if avail titulo
            then 
            */
            
            do:
                par-tabelaorigem = "titulo".
                par-chaveOrigem  = "contnum,titpar".
                par-dadosOrigem  = string(vcontnum) + "," +
                                   string(vtitpar).
                par-valorOrigem  = vvlr_pago. /* 12.12.2017 */
        
                run bol/vinculaboleto_v1701.p (
                        input recid(banBoleto),
                        input par-tabelaorigem,
                        input par-chaveorigem,
                        input par-dadosorigem,
                        input par-valorOrigem,
                        output vstatus,
                        output vmensagem_erro).
                /*        
                vstatus = "S".
                vmensagem_erro = "".        
                */
            end.
        end.             
        /* #1 */
        do on error undo:
        find current banBoleto exclusive.
        if banboleto.situacao <> "V"
        then do:
            vstatus = "N".
            vmensagem_erro = "Boleto nao Gerado Corretamente".
            par-recid-boleto = ?.
            banboleto.situacao = "E".
        end.
        end.
        /* #1 */
    end.
end.

BSXml("ABREXML","").
bsxml("abretabela","GeraBoletoRetorno").
bsxml("status",vstatus).
bsxml("mensagem_erro",vmensagem_erro).
bsxml("NomeMetodo","GeraBoletoContrato").
bsxml("NomeWebService","Boleto").


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
            bsxml("sacadoNome",clien.clinom).
            bsxml("sacadoEndereco",clien.endereco[1]).
            bsxml("sacadoCEP",string(clien.cep[1],"99999999")).
            bsxml("linhaDigitavel",banboleto.linhaDigitavel).
            bsxml("codigoBarras",banboleto.codigoBarras).
            bsxml("VlPrincipal",string(banboleto.vlCobrado,">>>>>>>9.99")).
        BSXml("FECHAREGISTRO","Boleto"). 
    
    end.

bsxml("fechatabela","GeraBoletoRetorno").
BSXml("FECHAXML","").

