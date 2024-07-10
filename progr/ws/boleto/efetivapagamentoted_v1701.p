
/* buscarplanopagamento */
def new global shared var setbcod       as int.

def var vcod as int64.
def var vcontnum as int.
def var vtitpar as int.
def var vvlr_pago as dec.
def var vdtvencimento as date.
def var vvlr_total_pago as dec.

{/u/bsweb/progr/bsxml.i}

def var vstatus as char.
def var vmensagem_erro as char.

def var par-rectitulo as recid.
def var par-recid-aviso as recid.

def var par-tabelaorigem as char.
def var par-chaveorigem as char.
def var par-dadosorigem as char.
def var par-valorOrigem  as dec.


/**                                                            
def shared temp-table Parcelas
    field codigo_cpfcnpj as char
    field numero_contrato as char 
    field seq_parcela as char
    field venc_parcela as char
    field vlr_parcela_pago as char.
**/

def shared temp-table EfetivaPagamentoTedEntrada
    field codigo_cpfcnpj as char
    field idted as char
    field dtefetivacao as char
    field statusted as char.
    
def var vidted as char.


   
    assign
            vstatus = "S"
            vmensagem_erro = "".


find first EfetivaPagamentoTedEntrada no-lock no-error.
if avail EfetivaPagamentoTedEntrada
then do.
    vstatus = "S".
    vcod     =  int(EfetivaPagamentoTedEntrada.codigo_cpfcnpj) no-error.

    vidted = EfetivaPagamentoTedentrada.idted no-error.    
    if vidted = ? or vidted = ""
    then do: 
        vstatus = "E". 
        vmensagem_erro = "Id Ted invalido " + EfetivaPagamentoTedentrada.idted.
    end.
   
    if vcod <> 0 and vcod <> ?
    then do.

        find first clien where 
                    clien.clicod = int(EfetivaPagamentoTedEntrada.codigo_cpfcnpj)
                    no-lock no-error.
    end.
        
    if not avail clien
    then find first clien where 
                clien.ciccgc = EfetivaPagamentoTedEntrada.codigo_cpfcnpj
                no-lock no-error.

    if not avail clien
    then assign
            vstatus = "E"
            vmensagem_erro = "Cliente " + 
                    EfetivaPagamentoTedEntrada.codigo_cpfcnpj~ + 
            " nao encontrado.".

    /**
    vvlr_total_pago = 0.
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
                        vvlr_total_pago = vvlr_total_pago +
                            titulo.titvlcob.
                    end.
                end.
            end.
    end. /* each parcelas */
    **/
    
end.
else assign
        vstatus = "E"
        vmensagem_erro = "Parametros de Entrada nao recebidos.".



if vstatus = "S"
then do on error undo:

                              
    find first bancarteira where
            bancarteira.principal = "PGERAL" no-lock no-error.
      
    find first banavisopag where
        banAvisoPag.bancod         = bancarteira.bancod and
        banAvisoPag.Agencia         = bancarteira.Agencia  and
        banAvisoPag.ContaCor        = bancarteira.ContaCor and
        banAvisoPag.BanCart        = bancarteira.BanCart and
        banAvisoPag.cdoperacao     = EfetivaPagamentoTedEntrada.idTed
    exclusive no-wait no-error.
    if avail banavisopag
    then do:
        if efetivapagamentotedEntrada.statusted = "E"
        then banavisopag.situacao = "E". 
        else do:
            banavisopag.situacao = "L". 
            banavisopag.dtbaixa = today. 
            banavisopag.hrbaixa = time. 
            banavisopag.dtPagamento = today. /*vdtvencimento.*/
            banavisopag.vlPagamento = vvlr_total_pago.
            for each banaviorigem of banavisopag.
                find contrato where contrato.contnum = int(entry(1,banaviorigem.dadosorigem))
                    no-lock.
                find first  titulo where
                    titulo.empcod = 19 and
                    titulo.titnat = no and
                    titulo.modcod = contrato.modcod and
                    titulo.etbcod = contrato.etbcod and
                    titulo.clifor = contrato.clicod and
                    titulo.titnum = string(contrato.contnum) and
                    titulo.titpar =  int(entry(2,banaviorigem.dadosorigem))
                    exclusive-lock  no-wait no-error.
                if avail titulo
                then do:
                    titulo.titdtpag = today.
                    titulo.titvlpag = banaviorigem.valororigem.
                    titulo.titjuro  = if titulo.titvlpag > titulo.titvlcob
                                      then titulo.titvlpag - titulo.titvlcob
                                      else 0.
                    titulo.titsit   = "PAG".
                    titulo.etbcobra = 999.
                    titulo.moecod = "BCO".
                end.
            end.
        end.            
    end.                    

end.

BSXml("ABREXML","").
bsxml("abretabela","EfetivaPagamentoTedRetorno").
bsxml("status",vstatus).
bsxml("mensagem_erro",vmensagem_erro).
bsxml("NomeMetodo","EfetivaPagamentoTed").

bsxml("fechatabela","EfetivaPagamentoTedRetorno").
BSXml("FECHAXML","").

