DEFINE INPUT PARAMETER lcJsonEntrada      AS LONGCHAR.
DEFINE OUTPUT PARAMETER lcJsonSaida       AS LONGCHAR.


pause 0 before-hide.
    
def var vdec as dec.    
{/admcom/barramento/metodos/consultaParcelas.i}

/* LE ENTRADA */
lokJSON = hParcelasEntrada:READ-JSON("longchar",lcJsonEntrada, "EMPTY").


create ttstatus.
ttstatus.situacao = "".


find first ttParcelasEntrada no-error.
if not avail ttParcelasEntrada
then do:
    ttstatus.situacao = "SEM INFORMACAO DE ENTRADA".
end.
else do:
    vdec = dec(ttParcelasEntrada.codigo_cpfcnpj) no-error.
    if vdec = ? or vdec = 0 
    then do:
        ttstatus.situacao = "CPF INVALIDO " + ttParcelasEntrada.codigo_cpfcnpj.
    end.
    else do:
        ttstatus.chave  = ttParcelasEntrada.codigo_cpfcnpj.

        /**24.07 - pesquisa apenas por cpf 
        find clien where clien.clicod = int(ttParcelasEntrada.codigo_cpfcnpj) no-lock no-error.
        if not avail clien
        then do:
        **/
            find neuclien where neuclien.cpfcnpj = dec(ttParcelasEntrada.codigo_cpfcnpj) no-lock no-error.
            if avail neuclien
            then find clien where clien.clicod = neuclien.clicod no-lock. 

        /**24.07 end.    **/
        
        if not avail neuclien and not avail clien
        then do:
            ttstatus.situacao = "CLIENTE NAO CADASTRADO".
        end.    
        else do:
            if ttParcelasEntrada.numero_Contrato <> ? and
               ttparcelasEntrada.numero_Contrato <> ""
            then do:
                find contrato where contrato.contnum = int(ttParcelasEntrada.numero_Contrato) no-lock no-error.
                if not avail contrato
                then do:
                    ttstatus.situacao = "CONTRATO NAO CADASTRADO".
                end.  
            end.   
        end.
    end.
end.    
if ttstatus.situacao = "" and avail ttParcelasEntrada
then do:

def var vcod as int64.

def var p-diasatraso as int.
def temp-table tt-modal no-undo
    field modcod like modal.modcod
    field etbcod as int
    field juros  as dec
    index modal is primary unique modcod.

def var mmodal as char extent 4 init ["CRE", "CP0", "CP1", "CPN"].
def var mestab as int  extent 4 init [0, 0, 0,0].

def new global shared var setbcod       as int.

def var vsituacao_cliente as char.
def var vi        as int.
def var vstatus   as char.   
def var vbloqueia as log.
def var vmensagem as char.
def var vjuros    like titulo.titvlcob.
def var vsaldojur as dec.
def var vmensagem_erro as char.
def var vvalor_contrato       as dec.
def var vvalor_total_pendente as dec.
def var vvalor_total_pago     as dec.
def var vvalor_total_encargo  as dec.
def var vaberto   as log.
def var venviar   as log.
def var vpossui_boleto as char.
def var vpossui_ted as char.


def buffer btitulo for titulo.


def var par-tabelaorigem as char.
def var par-chaveorigem as char.
def var par-dadosorigem as char.
def var par-valorOrigem  as dec.

    create ttclien.
    ttclien.chave = ttparcelasentrada.codigo_cpfcnpj.

 
    ttclien.clinom  = clien.clinom. 
    ttclien.clicod  = string(clien.clicod). 
    ttclien.cpf_cnpj = if avail neuclien then string(neuclien.cpfcnpj) else clien.ciccgc.  

     
    do vi = 1 to 4.
        create tt-modal.
        tt-modal.modcod = mmodal[vi].
        tt-modal.etbcod = mestab[vi].
    end.


    find first agfilcre where
        agfilcre.tipo = "CENTRAL" 
        no-lock no-error.
    
    find first tabparam where
            tabparam.tipo      = agfilcre.tipo  and 
            tabparam.grupo     = agfilcre.codigo and
            tabparam.aplicacao = ""     and
            tabparam.parametro = "DIAS DE ATRASO" /*"VALOR VENDA"*/
            no-lock no-error.
    if not avail tabparam
    then do:
        p-diasatraso = 60.
    end.
    else do:
        p-diasatraso = tabparam.valor.
    end.
    
    venviar = no.
    vsituacao_cliente = "S". 
        
    for each estab no-lock,
            each tt-modal no-lock,
            each titulo use-index titnum where
                titulo.empcod = 19 and
                titulo.titnat = no and
                titulo.modcod = tt-modal.modcod and
                titulo.etbcod = estab.etbcod and
                titulo.clifor = clien.clicod and
                titulo.titsit = "LIB" /* titulo.titdtpag = ? */
                and
                (if ttParcelasEntrada.numero_Contrato <> ? and
                    ttParcelasEntrada.numero_Contrato <> "" and
                    ttParcelasEntrada.numero_Contrato <> "?"
                  then titulo.titnum = 
                    string(int(ttParcelasEntrada.numero_Contrato))
                  else true)
                no-lock.

            find first contrato where
                contrato.contnum = int(titulo.titnum) no-lock
                no-error.
            if not avail contrato    
            then next.
            if contrato.clicod <> titulo.clifor
            then next.
            
            vsituacao_cliente = "N". 
            if titulo.titdtven <= today - p-diasatraso 
            then do:
                vsituacao_cliente = "A".
                venviar = no.    
                leave.
            end.    
            venviar = yes.
            
            /* se tem pelo menos um titulo em atraso, envia tudo */
            
            leave.
    end. 
  
    ttclien.situacao_cliente = vsituacao_cliente.
    

    vaberto = yes. 

    /*10*/ /* Inicio */
    
    if venviar
    then do:
    /*10*/ /* Fim */

        for each estab no-lock,
            each tt-modal no-lock,
            each titulo use-index titnum where
                titulo.empcod = 19 and
                titulo.titnat = no and
                titulo.modcod = tt-modal.modcod and
                titulo.etbcod = estab.etbcod and
                titulo.clifor = clien.clicod and
                titulo.titsit = "LIB" /* titulo.titdtpag = ? */
                    and
                (if ttParcelasEntrada.numero_Contrato <> ? and
                    ttParcelasEntrada.numero_Contrato <> "" and
                    ttParcelasEntrada.numero_Contrato <> "?"
                  then titulo.titnum = 
                    string(int(ttParcelasEntrada.numero_Contrato))
                  else true)
                no-lock
                break 
                      by titulo.titnum
                      by titulo.titpar.
        
            if first-of(titulo.titnum)
            then assign
                    vaberto = no.
            
            find contrato where contrato.contnum = int(titulo.titnum)    
                    no-lock no-error.
            if not avail contrato
            then next.
            if contrato.clicod <> titulo.clifor
            then next.
        
                            
            if vaberto = no
            then do:
                vaberto = yes.
                create ttcontratos.
                ttcontratos.chave = ttclien.chave.
                ttcontratos.clicod = ttclien.clicod.
                ttcontratos.etbcod = string(titulo.etbcod).
                ttcontratos.modcod = titulo.modcod.
                ttcontratos.contnum = string(int(titulo.titnum),"9999999999").
                ttcontratos.titdtemi = string(titulo.titdtemi,"99/99/9999").
                vvalor_contrato = 0. 
                vvalor_total_pago = 0.
                vvalor_total_pendente = 0.
                vvalor_total_encargo = 0.
                for each btitulo where
                        btitulo.empcod = 19 and
                        btitulo.titnat = no and
                        btitulo.modcod = titulo.modcod and
                        btitulo.etbcod = titulo.etbcod and
                        btitulo.clifor = titulo.clifor and
                        btitulo.titnum = titulo.titnum and
                        btitulo.titdtemi = titulo.titdtemi
                        no-lock.
                        
                    vvalor_contrato = vvalor_contrato + btitulo.titvlcob.
                    if btitulo.titsit = "LIB" /* btitulo.titdtpag = ? */
                    then vvalor_total_pendente = vvalor_total_pendente + 
                                                 btitulo.titvlcob.
                    else     vvalor_total_pago     = vvalor_total_pago     + 
                                                 btitulo.titvlcob.

                    if  btitulo.titsit <> "LIB" /* btitulo.titdtpag <> ? */
                    then next.

                    /** BASE MATRIZ  */
                    vjuros = 0.
                    if btitulo.titsit = "LIB" /* btitulo.titdtpag = ? */
                       and btitulo.titdtven < today
                    then run juro_titulo_portal.p (if clien.etbcad = 0 then titulo.etbcod else clien.etbcad, btitulo.titdtven, btitulo.titvlcob,
                                            output vjuros).

                    vvalor_total_encargo = vvalor_total_encargo + vjuros.
                end.        

                ttcontratos.vlrNominal  = trim(string(vvalor_contrato,">>>>>>>>>>>>9.99")).
                ttcontratos.vlrPago     = trim(string(vvalor_total_pago,">>>>>>>>>>>>9.99")).
                ttcontratos.vlrAberto   = trim(string(vvalor_total_pendente,">>>>>>>>>>>>9.99")).
                ttcontratos.vlrEncargos = trim(string(vvalor_total_encargo,">>>>>>>>>>>>9.99")).
                ttcontratos.tpcontrato =  titulo.tpcontrato. 
            end.    

            create ttparcelas.
            ttparcelas.chave    = ttcontratos.chave.
            ttparcelas.contnum  = ttcontratos.contnum.
            
            ttparcelas.seq_parcela  = string(titulo.titpar,"99").
            ttparcelas.venc_parcela = string(titulo.titdtven).
            ttparcelas.vlr_parcela  = trim(string(titulo.titvlcob,">>>>>>>>9.99")).

            /** BASE MATRIZ  */
            vjuros = 0.
            if titulo.titsit = "LIB" /* titulo.titdtpag = ? */
            then run juro_titulo_portal.p (if clien.etbcad = 0 then titulo.etbcod else clien.etbcad, titulo.titdtven, titulo.titvlcob,
                                output vjuros).

            ttparcelas.valor_encargos =  trim(string(vjuros,">>>>>>>>>>9.99")).


            par-tabelaorigem = "titulo".
            par-chaveOrigem  = "contnum,titpar".
            par-dadosOrigem  = string(int(titulo.titnum)) + "," +
                           string(titulo.titpar).
    
            vpossui_boleto = "N".
            vpossui_TED = "N".
        
            find last banbolOrigem 
                where banbolorigem.tabelaOrigem = par-tabelaOrigem and
                  banbolorigem.chaveOrigem  = par-chaveOrigem and
                  banbolorigem.dadosOrigem  = par-dadosOrigem
                no-lock no-error.
            if avail banBolOrigem
            then do:
                find banboleto of banbolOrigem no-lock no-error.
                if avail banboleto
                then 
                    if banboleto.dtpagamento = ? 
                    then vpossui_boleto = "S".
            end.

            ttparcelas.possui_boleto = vpossui_boleto.

            find first banAviOrigem 
                where banAviOrigem.tabelaOrigem = par-tabelaOrigem and
                      banAviOrigem.chaveOrigem  = par-chaveOrigem and
                      banAviOrigem.dadosOrigem  = par-dadosOrigem
                no-lock no-error.
            if avail banAviOrigem
            then do:
                find banaviso of banAviOrigem no-lock.
                if avail banaviso
                then 
                    if banaviso.dtpagamento = ? 
                    then vpossui_ted = "S".
            end.

            ttparcelas.possui_ted = vpossui_ted.
         
        end. /* estab */
    end. /*10*/

end.     
else do:
    message ttstatus.situacao.
end.


lokJson = hParcelasSaida:WRITE-JSON("LONGCHAR", lcJsonSaida, TRUE).

/*hParcelasSaida:WRITE-JSON("FILE","helio_parcelas.json", true).*/

