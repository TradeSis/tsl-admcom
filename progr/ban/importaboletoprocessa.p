def input param pdir as char.

def var vcashback as log.
def var prec as recid.
def var vseqreg as int.
def var vdtbaixa as date.
def var vhrbaixa as int. 
def var par-titdtpag  as date. 
def var par-titvlpag  as dec. 
def var par-titjuro   as dec.  
def var verro as char format "x(60)".
def var vok as log no-undo.

/*
Banco;Agencia;Conta;Carteira;Cpf_Cnpj;NossoNumero;DVNossoNumero;NumeroDocumento;Vencimento;Valor;Emissao;DataPagamento;ValorPago;ValorJuros;TipoBaixa
041;00878;0000710844806;1;000003247626077;666837455;5;91;03/11/2024;18,29;;03/09/2024;18,29;0;
*/
def temp-table tt-csv no-undo
    field banco as char
    field agencia as char
    field conta as char
    field carteira as char
    field cpf_cnpj as char
    field nossonumero as int64
/*    field dvnossonumero as char */
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

unix silent value("find " + pdir + " " +
                  "-name \"*_boleto_retorno.csv\" -print >" +
                  "lista_boleto_banrisul_retorno.txt").
    
input from ./lista_boleto_banrisul_retorno.txt.
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
    end.
    input close.
    for each tt-csv where tt-csv.nossonumero = 0.
        delete tt-csv.
    end. 
    vconta = 0.
    for each tt-csv.
        vconta = vconta + 1.
    end.        
            
    message today string(time,"HH:MM:SS") "Importando" varqui " Registros " vconta.
        
    vx = 0.
    
    for each tt-csv.
        vx = vx + 1.
        message today string(time,"HH:MM:SS") "Importando" varqui " Registro" vx "/" vconta " Banco " tt-csv.banco "NN" tt-csv.nossonumero.

        if tt-csv.banco = "Banco" or
           tt-csv.banco = ""
        then do:
            delete tt-csv.
            next.
        end.
        verro = "".

        /* Valida Bancos jah homologados */    
        if int(tt-csv.banco) = 041
        then do:
            find banco where banco.bancod = 041 no-lock.
        end.
        else do: 
            verro = "Banco Invalido" + tt-csv.banco.
        end.    
        if verro <> ""
        then do:
            message today string(time,"HH:MM:SS") "Erro" verro.
            delete tt-csv.
            next.
        end.            

        find boletagbol where boletagbol.bancod = banco.bancod and
                              boletagbol.nossonumero = tt-csv.nossonumero
                no-lock no-error.
                
        if not avail boletagbol
        then do:
            verro = "Boleto " + string(banco.bancod) + "/" + string(tt-csv.nossonumero) + " Nao encontrado!".
        end.     
        else do:
            if boletagbol.situacao <> "A"
            then do:
                verro = "Boleto " + string(string(tt-csv.nossonumero)) + " Com situacao " + boletagbol.situacao.
                                        
            end.
            else do:
                if boletagbol.dtbaixa <> ?   
                then do: 
                    verro = "Boleto " + string(string(tt-csv.nossonumero)) + " Baixado em "
                        + string(boletagbol.dtbaixa).
                end.
                if boletagbol.dtpagamento <> ?   
                then do: 
                    verro = "Boleto " + string(tt-csv.nossonumero) + " Pago em "
                        + string(boletagbol.dtpagamento).
                end.
            end.        
        end.
        
        if verro <> ""
        then do:
            message today string(time,"HH:MM:SS") "Erro" verro. pause.
            delete tt-csv.
            next.
        end.            

        vok = yes.
        verro = "".
        
        par-titvlpag = 0. par-titjuro = 0.
        par-titdtpag = date(tt-csv.dataPagamento) no-error.
        if par-titdtpag <> ?
        then do:
            par-titvlpag = dec(tt-csv.valorPago) no-error.
            par-titjuro  = dec(tt-csv.valorJuro) no-error.
        end.
        if par-titvlpag > 0 and  par-titdtpag <> ?
        then.
        else do:
            vok = no.
            verro = "Boleto "  + string(boletagbol.nossonumero) +  " sem Data de Pagamento e/ou sem Valor pago " .
        end.
        message today string(time,"HH:MM:SS") "Erro" verro vok string(boletagbol.nossonumero) boletagbol.origem par-titdtpag par-titvlpag. 
        if vok
        then do:

                prec = ?.
                vseqreg = 0. 
                verro = "".
                
                vcashback = no.
                if boletagbol.origem = "BOLETAGEM"
                then do:
                    find first pdvtmov where pdvtmov.ctmcod = "BAN" no-lock.
                
                    find cmon where cmon.etbcod = 999 and cmon.cxacod = 99 no-lock.
                    
                    run fin/cmdincdt.p (recid(cmon), recid(pdvtmov), 
                                                par-titdtpag,
                                                output prec).
                
                    find pdvmov where recid(pdvmov) = prec no-lock.
                            
                    run ban/boletopagaparcela.p (prec, recid(boletagbol), par-titdtpag,
                                                par-titvlpag, par-titjuro,
                                                output vok).

                end.
                if not vok        
                then do:
                    verro = "Boleto " + string(tt-csv.nossonumero) + " Nao executou baixa -> "
                        + verro.
                end.
      
                if verro <> ""
                then do:
                    message today string(time,"HH:MM:SS") "Erro" verro.
                    delete tt-csv.
                    next.
                end.            
        
        end.
    end.    
    message today string(time,"HH:MM:SS") "Importou " varqui.
    vbkp = replace(varqui,"_boleto_retorno.csv","_IMPORTADO_retorno.csv"). 
    unix silent value("mv " + varqui + " " + vbkp).

end.

hide message no-pause.
message today string(time,"HH:MM:SS") "Processo encerrado".

