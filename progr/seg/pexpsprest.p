def input param psai        as char.
def input param vdtini  as date.
def input param vdtfim as date.

{seg/segprest.i}
def var vlcsaida  as longchar.
def var hsaida as handle.
def var lokJson as log.
hSaida = TEMP-TABLE ttjsonContratos:HANDLE.
def var vj as int.

def var varq as char format "x(76)".
def var vcp  as char init ";".
def var vautomatico as char.

if psai = "csv" 
then do:
    varq = "/admcom/tmp/prestamista" + 
                                   string(vdtini,"99999999") + "_" + 
                                   string(vdtfim,"99999999") + "_" +
                                   string(today,"999999")  +  
                                 replace(string(time,"HH~:MM"),":","") +
                                 ".csv" .
    pause 0.
    update skip(2) varq skip(2)
        with
        centered 
        overlay
        color messages
        no-labels
        row 8
        title "arquivo de saida".

    message "Aguarde... gerando arquivo".
    
    output to value(varq).    
            
        put unformatted
"Contrato;Filial;Certificado;Data Emissao;Valor Contrato;Valor Liquido;Seguro Contrato;Codigo Seguro;Nome Seguro;Valor Seguro;Cliente;CPF;Plano;Descricao Plano;Automatico;Modalidade;filialOrigem;"         
            skip.        
end.

    for each ttcontrato.

        find contrato where recid(contrato) = ttcontrato.rec no-lock.
        vautomatico = "NAO".        
        find first cybacparcela where cybacparcela.contnum = contrato.contnum and
                                       cybacparcela.parcela = 0
                                       no-lock no-error.
        if avail cybacparcela
        then do:
            find cybacordo of cybacparcela no-lock.
            if cybacordo.SeguroPrestamistaAutomatico
            then vautomatico = "SIM".
        end.            
                                               
        
        find clien where clien.clicod = contrato.clicod no-lock.
        find produ where produ.procod = ttcontrato.codigoseguro no-lock.
        find finan where finan.fincod = contrato.crecod no-lock.

        if psai = "csv" 
        then do:
            put unformatted
            contrato.contnum vcp
            contrato.etbcod  vcp
            ttcontrato.certifi  vcp
            string(contrato.dtinicial,"99/99/9999") vcp
            trim(string(contrato.vltotal,"->>>>>>>>>>9.99")) vcp
            trim(string(contrato.vltotal - contrato.vlentra,"->>>>>>>>>>9.99")) vcp
            trim(string(contrato.vlseguro,"->>>>>>>>>>9.99")) vcp
            ttcontrato.codigoseguro vcp
            if avail produ then produ.pronom else "" vcp
            trim(string(ttcontrato.prseguro,"->>>>>>>>>>9.99")) vcp
            contrato.clicod vcp 
            clien.ciccgc vcp
            contrato.crecod vcp            
            finan.finnom vcp
            vautomatico vcp
            contrato.modcod vcp
            if vautomatico = "NAO" then contrato.etbcod else 999 vcp
            skip.
        end.    
        if psai = "json"
        then do:
            vj = vj + 1.
            if vj > 80 /* Helio 06032024 - Exportar Json de 80 em 80 registros */
            then do:
                run criaInterface.
                empty temp-table ttjsonContratos.
            end.
            
            create ttjsonContratos.
            ttjsonContratos.contnum = string(contrato.contnum).
            ttjsonContratos.etbcod  = string(contrato.etbcod).
            ttjsonContratos.certifi = ttcontrato.certifi.
            ttjsonContratos.dataEmissao = enviadata(contrato.dtinicial).
            ttjsonContratos.valorContrato = trim(string(contrato.vltotal,"->>>>>>>>>>9.99")).
            ttjsonContratos.valorLiquido  = trim(string(contrato.vltotal - contrato.vlentra,"->>>>>>>>>>9.99")).
            ttjsonContratos.valorSeguroContrato = trim(string(contrato.vlseguro,"->>>>>>>>>>9.99")).
            ttjsonContratos.codigoSeguro    = string(ttcontrato.codigoseguro).
            ttjsonContratos.nomeSeguro  = if avail produ then produ.pronom else "".
            ttjsonContratos.valorSeguro =  trim(string(ttcontrato.prseguro,"->>>>>>>>>>9.99")).
            ttjsonContratos.codigoCliente = string(contrato.clicod).
            ttjsonContratos.cpfCliente = clien.ciccgc.
            ttjsonContratos.plano   = string(contrato.crecod).
            ttjsonContratos.descPlano = finan.finnom.
            ttjsonContratos.automatico = vautomatico.
            ttjsonContratos.modalidade  = contrato.modcod.
            ttjsonContratos.filialOrigem = string(if vautomatico = "NAO" then contrato.etbcod else 999 ).
            
        end.
    end.
    
    if psai = "csv"
    then do:
        output close.
        message "gerado com sucesso.".
        pause 1 no-message.
    end.
    if psai = "json"    
    then do:
        run criaInterface.
    end.
    
    hide message no-pause.




procedure criaInterface.

    find first ttjsonContratos no-error.
    if avail ttjsonContratos
    then do:
        lokJson = hSaida:WRITE-JSON("LONGCHAR", vlcsaida, TRUE) no-error.

          pause 1 no-message. /* helio 26032024, para nao gerar 2 horain no mesmo time */                   
          create verusJsonOUT.
          ASSIGN
            verusJsonOUT.interface     = "segurosAutomatizados".
            verusJsonOUT.jsonStatus    = "NP".
            verusJsonOUT.dataIn        = today.
            verusJsonOUT.horaIn        = time.
    
        copy-lob from vlcsaida to verusJsonOUT.jsondados.
    end.
 
 
 end procedure.
