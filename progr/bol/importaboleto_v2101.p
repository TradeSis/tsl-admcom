/* helio 05042023 - complementos */
/* helio 04042023 cashback antecipacao */
/* helio 16/11/2021 ID 92468 - Pagamento pendente boleto */
def var vbaixaparcelas as log.
def var prec as recid.
def var vgeramov as char.
def var vseqreg as int.
def var vdtbaixa as date.
def var vhrbaixa as int. 
def var par-titdtpag  as date. 
def var par-titvlpag  as dec. 
def var par-titjuro   as dec.  
def var verro as char format "x(60)".
def var vok as log no-undo.

def temp-table tt-csv no-undo
    field banco as char
    field agencia as char
    field conta as char
    field carteira as char
    field cpf_cnpj as char
    field nossonumero as char
    field dvnossonumero as char
    field numerodocumento as char
    field vencimento as char
    field valor as char
    field emissao as char
    field dataPagamento as char
    field valorPago as char
    field valorjuros as char
    field ocorrencia as char.
    
def temp-table tt-arq no-undo
    field arqent as char format "x(70)".

message today string(time,"HH:MM:SS") "procurando arquivos...".

unix silent value("find /admcom/tmp/boleto/access/ " +
                  "-name \"*_boleto_retorno.csv\" -print >" +
                  "lista_boleto_retorno.txt").
    
input from ./lista_boleto_retorno.txt.
repeat transaction:
    create tt-arq.
    import tt-arq.
end.
input close.
for each tt-arq where arqent = "" or arqent = ?.
    delete tt-arq.
end.    

def var varqui as char format "x(50)" label "Arquivo".
def var vbkp as char.

find first tt-arq no-error.
if not avail tt-arq
then do:
    message today string(time,"HH:MM:SS") "Arquivos nao encontrados".
    return.
end.
else do:
    message today string(time,"HH:MM:SS") "Vai importar arquivos encontratos".
end.    

vdtbaixa = today. 
vhrbaixa = time.
def var vconta as int.
def var vx as int.
vconta  = 0.


for each tt-arq.
    varqui = tt-arq.arqent.
    if search(varqui) = ?
    then do:
        hide message no-pause.
        message today string(time,"HH:MM:SS") "Nao Existe" varqui.
        delete tt-arq.
        next.
    end.
    for each tt-csv.
        delete tt-csv.
    end.
    
    input from value(varqui).
    repeat transaction on error undo, next.
        create tt-csv.
        import delimiter ";"
            tt-csv no-error.
        vconta = vconta + 1.    
    end.
    input close.
            
    message today string(time,"HH:MM:SS") "Importando" varqui " Registros " vconta.
        
    vx = 0.
    
    for each tt-csv.
        vx = vx + 1.
        message today string(time,"HH:MM:SS") "Importando" varqui " Registro" vx "/" vconta.

        if tt-csv.banco = "Banco" or
           tt-csv.banco = ""
        then do:
            delete tt-csv.
            next.
        end.
        verro = "".

        /* Valida Bancos jah homologados */    
        if int(tt-csv.banco) = 341
        then do:
            find banco where banco.bancod = 86 no-lock.
            find bancarteira where
                bancarteira.bancod   = banco.bancod and
                bancarteira.agencia = int(tt-csv.agencia) and
                bancarteira.contacor   = int(tt-csv.conta) and
                bancarteira.bancart = tt-csv.carteira
                no-lock no-error.
            if not avail bancarteira
            then do:
                verro = "Sem registro >>" +
                        " Banco " + string(tt-csv.banco,"999") +
                        " Ag " + tt-csv.agencia + 
                        " CC " + tt-csv.conta +
                        " Cart " + string(tt-csv.carteira,"999").
            end.       
        end.
        else do:
            if int(tt-csv.banco) = 104
            then do:
                find banco where banco.bancod = 104 and banco.situacao = yes no-lock.
                find first bancarteira where
                    bancarteira.bancod   = banco.bancod /*and
                    bancarteira.agencia = int(tt-csv.agencia) and
                    bancarteira.contacor   = int(tt-csv.conta) and
                    bancarteira.bancart = tt-csv.carteira */
                    no-lock no-error.
                if not avail bancarteira
                then do:
                    verro = "Sem registro >>" +
                            " Banco " + string(tt-csv.banco,"999") +
                            " Ag " + tt-csv.agencia + 
                            " CC " + tt-csv.conta +
                            " Cart " + string(tt-csv.carteira,"999").
                end.       
            end.
            else do:  
                verro = "Banco Invalido" + tt-csv.banco.
            end.    
        end.    
        if verro <> ""
        then do:
            message today string(time,"HH:MM:SS") "Erro" verro.
            delete tt-csv.
            next.
        end.            
        if bancarteira.bancod = 104
        then do:
            if trim(tt-csv.nossonumero) begins "14"
            then tt-csv.nossonumero = substring(tt-csv.nossonumero,3).
        end.
        
        if bancarteira.bancod = 104
        then
            find first banboleto where banboleto.bancod = bancarteira.bancod  and 
                             banboleto.agencia = bancarteira.agencia and
                             banboleto.contacor = bancarteira.contacor and
                             banboleto.bancart  = bancarteira.bancart and      
                             banboleto.nossonumero = int(tt-csv.nossonumero)
                no-lock no-error.
        else
            find banboleto where banboleto.bancod = bancarteira.bancod and
                             banboleto.agencia = bancarteira.agencia and
                             banboleto.contacor = bancarteira.contacor and
                             banboleto.bancart  = bancarteira.bancart and
                             banboleto.nossonumero = int(tt-csv.nossonumero)
                no-lock no-error.
                
        if not avail banboleto
        then do:
                verro = "Boleto " + tt-csv.nossonumero + " Nao encontrado!".
        end.     
        else do:
            if banboleto.dtbaixa <> ?   
            then do: 
                verro = "Boleto " + tt-csv.nossonumero + " Baixado em "
                        + string(banboleto.dtbaixa).
            end.
        end.
        
        if verro <> ""
        then do:
            message today string(time,"HH:MM:SS") "Erro" verro.
            delete tt-csv.
            next.
        end.            

        vok = yes.
        verro = "".
        
        if banboleto.dtbaixa <> ?  then do:
            vok = no.
            verro = "Ja Baixado".
        end.            
        
        /* 16/11/1967 ID 92468 mesmo sem origem, deixa o boleto como baixado
        find first banbolorigem of banboleto no-lock no-error.
        if not avail banbolorigem
        then  find first banbolorigem where
                    banbolorigem.bancod = banboleto.bancod and
                    banbolorigem.nossonumero  = banboleto.nossonumero no-lock no-error.         
        if not avail banbolorigem
        then do:
            vok = no.
            verro = "Sem Origem".
        end.    */

        par-titvlpag = 0. par-titjuro = 0.
        par-titdtpag = date(tt-csv.dataPagamento) no-error.
        if par-titdtpag <> ?
        then do:
            par-titvlpag = dec(tt-csv.valorPago) no-error.
            par-titjuro  = dec(tt-csv.valorJuro) no-error.
        end.
        if bancarteira.bancod = 104
        then do:
            if par-titvlpag > 0 and  par-titdtpag <> ?
            then.
            else do:
                vok = no.
                verro = "Boleto "  + string(banboleto.nossonumero) +  " sem Data de Pagamento e/ou sem Valor pago " .
            end.
        end.
        
      if vok
      then do:
        if bancarteira.bancod = 104
        then 
            find first banocorr where 
                banocorr.bancod = bancarteira.bancod and
                banocorr.ocbtipo   = no 
           no-lock no-error.
        else
            find banocorr where 
                banocorr.bancod = bancarteira.bancod and
                banocorr.ocbtipo   = no and /* retorno */
                banocorr.ocbcod = int(tt-csv.ocorrencia)
           no-lock no-error.
           
        if not avail banocorr
        then do:
            vok = no. 
            verro = "Ocorrencia " + tt-csv.ocorrencia + " NAO CADASTRADA".
        end.    
        else do:
            if not banocorr.ocbliquida
            then do:
                vok = no.
                verro = "Ocorrencia " + tt-csv.ocorrencia + 
                    " setada como NAO LIQUIDA".
            end.
            else do:
                
                prec = ?.
                vgeramov = "".
                vseqreg = 0.
                
                vbaixaparcelas = no.
                
                for each banbolorigem of banboleto NO-LOCK.

                    if banbolorigem.tabelaOrigem = "cybacparcela"
                    then vgeramov = "NCY".

                    if banbolorigem.tabelaorigem = "api/acordo,negociacaoboleto"  
                    then vgeramov = "BAO".

                    if banbolorigem.tabelaOrigem = "titulo" or
                       banbolorigem.tabelaOrigem = ?        or     
                       banbolorigem.tabelaorigem = "promessa" or
                       banbolorigem.tabelaorigem = "api/acordo,parcelasboleto"
                    then vgeramov = "BOL".
                    
                     if banbolorigem.tabelaOrigem = "titulo" or 
                       (banbolorigem.tabelaOrigem = ? and  banbolorigem.ChaveOrigem = "idacordo,contnum,parcela")  or                      
                        banbolorigem.tabelaorigem = "promessa" or
                        banbolorigem.tabelaorigem = "api/acordo,parcelasboleto" or
                       ((banbolorigem.tabelaOrigem = "titulo" or banbolorigem.tabelaOrigem = ?) and banBolOrigem.ChaveOrigem  = "contnum,titpar")
                     then vbaixaparcelas = yes.   
                    
                end.
                if vgeramov = "BAO"
                then do:
                    find first pdvtmov where pdvtmov.ctmcod = vgeramov no-lock.

                    find cmon where cmon.etbcod = 998 and cmon.cxacod = 99 no-lock.
                    
                    run fin/cmdincdt.p (recid(cmon), recid(pdvtmov), 
                                        par-titdtpag,
                                        output prec).

                    find pdvmov where recid(pdvmov) = prec no-lock.
                    

                end.
                else do:                
                    if vgeramov <> ""
                    then do:
                        find first pdvtmov where pdvtmov.ctmcod = vgeramov no-lock.
                
                        find cmon where cmon.etbcod = 999 and cmon.cxacod = 99 no-lock.
                    
                        run fin/cmdincdt.p (recid(cmon), recid(pdvtmov), 
                                            par-titdtpag,
                                            output prec).
                
                        find pdvmov where recid(pdvmov) = prec no-lock.
                    end.

                end.
                
                for each banbolorigem of banboleto NO-LOCK.

                    verro = "".
                    message banboleto.nossonumero banbolorigem.tabelaOrigem banBolOrigem.ChaveOrigem banBolOrigem.dadosorigem vgeramov prec par-titdtpag .
                
                    vseqreg = vseqreg + 1.                

                    if banbolorigem.tabelaorigem = "promessa" or (banbolorigem.tabelaOrigem = ? and  banbolorigem.ChaveOrigem = "idacordo,contnum,parcela")
                    then do:
                        run bol/baixaparcela_v2101.p  /* incluido ao */
                                                ( prec, vseqreg,
                                                  recid(banbolorigem), 
                                                  par-titdtpag,
                                                  banbolorigem.valororigem,
                                                  par-titjuro,
                                                  output vok).
                    
                    end.
                    else
                    if banbolorigem.tabelaorigem = "api/acordo,parcelasboleto" 
                    then do:
                        run bol/baixaparcelaao.p  /* incluido ao */
                                                ( prec, vseqreg,
                                                  recid(banbolorigem), 
                                                  par-titdtpag,
                                                  banbolorigem.valororigem,
                                                  par-titjuro,
                                                  output vok).
                    
                    end.
                    else
                    
                    if banbolorigem.tabelaOrigem = "cybacparcela"  
                    then do:
                        run bol/baixaacordo_v2101.p (prec, vseqreg, /* 16.04.2021 helio */
                                                    recid(banbolorigem),
                                                 par-titdtpag,
                                                 banbolorigem.valor,
                                                 par-titjuro,
                                                 output vok).
                        if vok = no
                        then verro = "Erro Baixa Acordo".
                        par-titjuro = 0.
                    end.    
                    else
                    if  banbolorigem.tabelaorigem = "api/acordo,negociacaoboleto" /*2201*/
                    then do:
                        run bol/baixaacordoao.p (prec, vseqreg, /* 16.04.2021 helio */
                                                    recid(banbolorigem),
                                                 par-titdtpag,
                                                 banbolorigem.valor,
                                                 par-titjuro,
                                                 output vok).
                        if vok = no
                        then verro = "Erro Baixa Acordo ".
                        par-titjuro = 0.
                    end.    
                    
                    else if (banbolorigem.tabelaOrigem = "titulo" or banbolorigem.tabelaOrigem = ?) and
                            banBolOrigem.ChaveOrigem  = "contnum,titpar"
                    then do:
                        run bol/baixaparcela_v2101.p  
                                                ( prec, vseqreg,
                                                  recid(banbolorigem), 
                                                  par-titdtpag,
                                                  banbolorigem.valororigem,
                                                  par-titjuro,
                                                  output vok).
                        if vok = no
                        then verro = "Erro Baixa Parcela".
                        par-titjuro = 0.
                    end.
                    else do:
                        vok = no.
                        verro = "Origem Desconhecida " +
                            banbolorigem.tabelaOrigem.
                    end.    
                end.
                
                if vbaixaparcelas
                then do:
                    run loj/cashbackpormov.p (prec).
                end.
                
            end.
        end.
        
        if vok or (par-titdtpag <> ? and par-titvlpag <> 0)
        then do:
            run bol/baixaboleto_v1701.p (recid(banboleto),
                                   banocorr.ocbcod,
                                   par-titdtpag,
                                   par-titvlpag,
                                   par-titjuro).
        end.
        else do:
            verro = "Boleto " + tt-csv.nossonumero + " Nao executou baixa -> "
                + verro.
        end.
      end.
      
        if verro <> ""
        then do:
            message today string(time,"HH:MM:SS") "Erro" verro.
            delete tt-csv.
            next.
        end.            
        
    end.
    input close.
        
    message today string(time,"HH:MM:SS") "Importou " varqui.
    vbkp = replace(varqui,"_boleto_retorno.csv","_IMPORTADO_retorno.csv"). 
    unix silent value("mv " + varqui + " " + vbkp).

end.

hide message no-pause.
message today string(time,"HH:MM:SS") "Processo encerrado".

