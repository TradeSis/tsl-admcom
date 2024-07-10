/* 10 - DESATIVO A ESCRITA NO DIRETORIO MONTADO DO AC DEVIDO A TRAVAMENTOS */ 

DEFINE INPUT PARAMETER lcJsonEntrada      AS LONGCHAR.
DEFINE OUTPUT PARAMETER lcJsonSaida       AS LONGCHAR.


pause 0 before-hide.
    
def var vdec as dec.    
{/admcom/barramento/metodos/geraBoletoContrato.i}

/* LE ENTRADA */
lokJSON = hgeraBoletoEntrada:READ-JSON("longchar",lcJsonEntrada, "EMPTY").


def var vdtvencimento as date.
def var vvlr_boleto as dec.
def var vvlr_servicos as dec .
def var vcontnum as int.
 def var vtitpar as int.
def var par-recid-boleto as recid.
def var auxsituacao as char.
def var vvlr_pAGO AS DEC.

def var par-tabelaorigem as char.
def var par-chaveorigem as char.
def var par-dadosorigem as char.
def var par-valorOrigem  as dec.


create ttstatus.
ttstatus.situacao = "".


find first ttgeraboletoEntrada no-error.
if not avail ttgeraboletoEntrada
then do:
    ttstatus.situacao = "SEM INFORMACAO DE ENTRADA".
end.
else do:
    vdec = dec(ttgeraboletoEntrada.codigo_cpfcnpj) no-error.
    if vdec = ? or vdec = 0 
    then do:
        ttstatus.situacao = "CPF INVALIDO " + ttgeraboletoEntrada.codigo_cpfcnpj.
    end.
    else do:
        ttstatus.chave  = ttgeraboletoEntrada.codigo_cpfcnpj.

        find clien where clien.clicod = int(ttgeraboletoEntrada.codigo_cpfcnpj) no-lock no-error.
        if not avail clien
        then do:
            find neuclien where neuclien.cpfcnpj = dec(ttgeraboletoEntrada.codigo_cpfcnpj) no-lock no-error.
            if avail neuclien
            then find clien where clien.clicod = neuclien.clicod no-lock. 
        end.    
        if not avail neuclien and not avail clien
        then do:
            ttstatus.situacao = "CLIENTE NAO CADASTRADO".
        end.    
        else do.
            vdtvencimento = date (ttgeraboletoEntrada.venc_boleto) no-error.
                                    /*date(int(substr(ttgeraboletoEntrada.venc_boleto,1,2)),
                                 int(substr(ttgeraboletoEntrada.venc_boleto,3,2)),
                                 int(substr(ttgeraboletoEntrada.venc_boleto,5)))
                                 no-error. */
            if vdtvencimento = ?
            then do: 
                ttstatus.situacao = "Vencimento invalido " + ttgeraboletoEntrada.venc_boleto.
            end.
            else 
                if vdtvencimento < today
                then do: 
                    ttstatus.situacao = "Vencimento Boleto " + string(vdtvencimento,"99/99/9999") + 
                                     " ANTERIOR a Hoje.".
                end.
            vvlr_boleto = dec(ttgeraboletoEntrada.vlr_boleto) no-error.    
            if vvlr_boleto = ? or vvlr_boleto = 0
            then do: 
                ttstatus.situacao = "Valor Boleto invalido " + ttgeraboletoEntrada.vlr_boleto.
            end.
            vvlr_servicos = dec(ttgeraboletoEntrada.vlr_servicos) no-error.    
            if vvlr_servicos = ? /*#2 or vvlr_servicos = 0*/
            then do: 
                ttstatus.situacao = "Valor Servicos invalido " + ttgeraboletoEntrada.vlr_servicos.
            end.
   
            if ttstatus.situacao = ""
            then 
                for each ttParcelasEntrada.    
                    vcontnum =   int(ttparcelasEntrada.numero_contrato) no-error.
                    vtitpar  =   int(ttparcelasEntrada.seq_parcela) no-error.
            
                    if vcontnum <> 0 and vcontnum <> ?
                    then do:
                        find contrato where contrato.contnum = vcontnum no-lock no-error.
                    end.
                    if not avail contrato
                    then do:
                        assign
                            ttstatus.situacao = "Contrato " + 
                                    ttparcelasEntrada.numero_contrato + 
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
                                ttstatus.situacao = "Contrato " + 
                                        ttparcelasEntrada.numero_contrato + 
                                        " Parcela " +
                                        ttparcelasEntrada.seq_parcela + 
                                        " nao encontrada.".
                        end.        
                        else do:
                            if titulo.titdtpag <> ? or
                               titulo.titsit   <> "LIB"
                            then do:
                                ttstatus.situacao = "Contrato " + 
                                        ttparcelasEntrada.numero_contrato + 
                                        " Parcela " +
                                        ttparcelasEntrada.seq_parcela + 
                                        " ja liquidada.".
                            end.   
                            else do:
                                if vvlr_boleto <> 0 and vvlr_boleto <> ?
                                then do:
                                    if vvlr_boleto < titulo.titvlcob
                                    then do:
                                        ttstatus.situacao = "Valor de " + 
                                                ttgeraboletoEntrada.vlr_boleto + 
                                                " insuficiente para pagar Parcela " + ttparcelasEntrada.seq_parcela.
                                    end. 
                                end.
                            end.
                        end.
                    end.
                end. /* each ttparcelasEntrada */
        
        end.
    end.
end.    
if ttstatus.situacao = "" and avail ttgeraboletoEntrada
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
                    output auxsituacao,
                    output auxsituacao).
    
    find banBoleto where recid(banBoleto) = par-recid-boleto no-lock no-error.
    if avail banboleto
    then do on error undo: /* #1 */   
        for each ttParcelasEntrada: 
            vvlr_pago =  dec(ttParcelasEntrada.vlr_parcela_pago) no-error. 
            vcontnum =   int(ttParcelasEntrada.numero_contrato) no-error. 
            vtitpar  =   int(ttParcelasEntrada.seq_parcela) no-error.
            find contrato where contrato.contnum = vcontnum no-lock no-error. 
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
            then do:
                par-tabelaorigem = "titulo".
                par-chaveOrigem  = "contnum,titpar".
                par-dadosOrigem  = string(contrato.contnum) + "," +
                                   string(titulo.titpar).
                par-valorOrigem  = vvlr_pago. /* 12.12.2017 */
        
                run bol/vinculaboleto_v1701.p (
                        input recid(banBoleto),
                        input par-tabelaorigem,
                        input par-chaveorigem,
                        input par-dadosorigem,
                        input par-valorOrigem,
                        output auxsituacao,
                        output auxsituacao).
            end.
        end.             
        /* #1 */
        find current banBoleto exclusive.
        if banboleto.situacao <> "V"
        then do:
            ttstatus.situacao = "Boleto nao Gerado Corretamente".
            par-recid-boleto = ?.
            banboleto.situacao = "E".
        end.
        /* #1 */
    end.

    create ttboleto.
    ttboleto.chave = ttstatus.chave.
    
    find banBoleto where recid(banBoleto) = par-recid-boleto no-lock no-error.
    if avail banBoleto
    then do:
        find banco where banco.bancod = banboleto.bancod no-lock.
        find banCarteira of banBoleto no-lock.
        
            ttboleto.Banco          =   string(banco.numban,"999").
            ttboleto.Agencia        =   string(banboleto.agencia).
            ttboleto.codigoCedente  =   banCarteira.banCedente.
            ttboleto.contaCorrente  =   string(banboleto.contacor).
            ttboleto.Carteira       =   banboleto.banCart.
            ttboleto.nossoNumero    =   string(banBoleto.nossonumero,"99999999").
            ttboleto.DVnossoNumero  =   string(banBoleto.DvNossoNumero).
            ttboleto.dtEmissao      =   string(banboleto.dtemissao).
            ttboleto.dtVencimento   =   string(banboleto.dtvencimento).
            ttboleto.fatorVencimento =  string(banboleto.fatorVencimento,"9999").
            ttboleto.numeroDocumento =  banboleto.Documento.
            ttboleto.sacadoNome     =   clien.clinom.
            ttboleto.sacadoEndereco =   clien.endereco[1].
            ttboleto.sacadoCEP      =   string(clien.cep[1],"99999999").
            ttboleto.linhaDigitavel =   banboleto.linhaDigitavel.
            ttboleto.codigoBarras   =   banboleto.codigoBarras.
            ttboleto.VlPrincipal    =   trim(string(banboleto.vlCobrado,">>>>>>>9.99")).
    
    end.

end.     
else do:
    message ttstatus.situacao.
end.


lokJson = hgeraboletoSaida:WRITE-JSON("LONGCHAR", lcJsonSaida, TRUE).
/* 10
hgeraboletoSaida:WRITE-JSON("FILE","helio_boleto.json", true).
*/
