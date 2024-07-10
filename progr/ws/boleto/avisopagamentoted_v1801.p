
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


                                                            
def shared temp-table Parcelas
    field codigo_cpfcnpj as char
    field numero_contrato as char 
    field seq_parcela as char
    field venc_parcela as char
    field vlr_parcela_pago as char.

def shared temp-table AvisoPagamentoTedEntrada
    field codigo_cpfcnpj as char
    field banco as char
    field idted as char.
def var vidted as char.


   
    assign
            vstatus = "S"
            vmensagem_erro = "".


find first AvisoPagamentoTedEntrada no-lock no-error.
if avail AvisoPagamentoTedEntrada
then do.
    vstatus = "S".
    vcod     =  int(AvisoPagamentoTedEntrada.codigo_cpfcnpj) no-error.

    vidted = AvisoPagamentoTedentrada.idted no-error.    
    if vidted = ? or vidted = ""
    then do: 
        vstatus = "E". 
        vmensagem_erro = "Id Ted invalido " + AvisoPagamentoTedentrada.idted.
    end.
   
    if vcod <> 0 and vcod <> ?
    then do.

        find first clien where 
                    clien.clicod = int(AvisoPagamentoTedEntrada.codigo_cpfcnpj)
                    no-lock no-error.
    end.
        
    if not avail clien
    then find first clien where 
                clien.ciccgc = AvisoPagamentoTedEntrada.codigo_cpfcnpj
                no-lock no-error.

    if not avail clien
    then assign
            vstatus = "E"
            vmensagem_erro = "Cliente " + 
                    AvisoPagamentoTedEntrada.codigo_cpfcnpj~ + 
            " nao encontrado.".
    
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

                          
      

    for each parcelas.
        vcontnum =  int(Parcelas.numero_contrato) no-error.
        vtitpar  =  int(parcelas.seq_parcela) no-error.

            par-tabelaorigem = "titulo". 
            par-chaveOrigem  = "contnum,titpar". 
            par-dadosOrigem  = string(int(Parcelas.numero_contrato)) + "," + 
                                string(int(parcelas.seq_parcela)).
            find first banaviorigem where
                banaviorigem.tabela = par-tabelaorigem and
                banaviorigem.chaveorigem = par-chaveOrigem and
                banaviorigem.dadosOrigem = par-dadosOrigem
                exclusive no-error.
            find banavisopag of banaviorigem no-lock no-error.
            if avail banavisopag
            then do:
                if banavisopag.situacao = "E"
                then delete banaviorigem.
            end.

    end.
                              
end.
else assign
        vstatus = "E"
        vmensagem_erro = "Parametros de Entrada nao recebidos.".



if vstatus = "S"
then do:

   
    vdtvencimento = today.
 
    find first banco where banco.numban = int(AvisoPagamentoTedEntrada.banco) no-lock no-error.
             
    run bol/geradadosaviso_v1701.p (
                    input if avail banco then banco.numban else ?, /* Banco do Boleto */
                    input ?,      /* Bancarteira especifico */
                    input "WSTED",
                    input clien.clicod,
                    input "",
                    input vdtvencimento,
                    input  vvlr_total_pago,
                    input vidted,
                    output par-recid-aviso,
                    output vstatus,
                    output vmensagem_erro).

    find banavisopag where recid(banavisopag) = par-recid-aviso no-lock no-error.     
    if not avail banavisopag
    then do:
        vstatus = "E".
        vmensagem_erro = if vmensagem_erro = ""
                        then "Erro ao Criar Aviso na Base de Dados."
                        else vmensagem_erro.
    end.

    if vstatus = "S" and avail banavisopag
    then for each parcelas.
 
        vcontnum =  int(Parcelas.numero_contrato) no-error.
        vtitpar  =  int(parcelas.seq_parcela) no-error.
        vvlr_pago =  dec(parcelas.vlr_parcela_pago) no-error.
        find contrato where contrato.contnum = vcontnum no-lock no-error.
        find first  titulo where
                titulo.empcod = 19 and
                titulo.titnat = no and
                titulo.modcod = contrato.modcod and
                titulo.etbcod = contrato.etbcod and
                titulo.clifor = contrato.clicod and
                titulo.titnum = string(contrato.contnum) and
                titulo.titpar = vtitpar
                exclusive no-error.
        if avail titulo
        then do:  
            par-tabelaorigem = "titulo". 
            par-chaveOrigem  = "contnum,titpar". 
            par-dadosOrigem  = string(contrato.contnum) + "," + 
                                string(titulo.titpar).

            run bol/vinculaaviso_v1701.p (
                        input recid(banavisopag),
                        input par-tabelaorigem,
                        input par-chaveorigem,
                        input par-dadosorigem,
                        input vvlr_pago,
                        output vstatus,
                        output vmensagem_erro).
            
                                                
                        
        end.
    end.

    /**
    if vstatus = "S"
    then do on error undo:
        find banavisopag where recid(banavisopag) = par-recid-aviso 
                exclusive no-wait no-error.     
        if avail banavisopag
        then do:
            banavisopag.situacao = "L". 
            banavisopag.dtbaixa = today. 
            banavisopag.hrbaixa = time. 
            banavisopag.dtPagamento = ?. /*vdtvencimento.*/
            banavisopag.vlPagamento = vvlr_total_pago.
        end.
    end.                    
    **/
    
end.

BSXml("ABREXML","").
bsxml("abretabela","AvisoPagamentoTedRetorno").
bsxml("status",vstatus).
bsxml("mensagem_erro",vmensagem_erro).
bsxml("NomeMetodo","AvisoPagamentoTed").

bsxml("fechatabela","AvisoPagamentoTedRetorno").
BSXml("FECHAXML","").

