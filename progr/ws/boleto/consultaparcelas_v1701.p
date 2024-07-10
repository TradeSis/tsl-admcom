
def var vcod as int64.

def var p-diasatraso as int.
def temp-table tt-modal no-undo
    field modcod like modal.modcod
    field etbcod as int
    field juros  as dec
    index modal is primary unique modcod.

def var mmodal as char extent 4 init ["CRE", "CP0", "CP1", "CPN"].
def var mestab as int  extent 4 init [0, 0, 0, 0].

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



def shared temp-table ClienteContratoEntrada
    field codigo_cpfcnpj as char
    field numero_contrato as char.


{/u/bsweb/progr/bsxml.i}

find first ClienteContratoEntrada no-lock no-error.
if avail ClienteContratoEntrada
then do.
    vstatus = "S".
    
    vcod = int(ClienteContratoEntrada.codigo_cpfcnpj) no-error.
    if vcod <> 0 and vcod <> ?
    then do.

        find first clien where 
                    clien.clicod = int(ClienteContratoEntrada.codigo_cpfcnpj)
                    no-lock no-error.
    end.
        
    if not avail clien
    then find first clien where 
                clien.ciccgc = ClienteContratoEntrada.codigo_cpfcnpj
                no-lock no-error.
    

    if not avail clien
    then assign
            vstatus = "E"
            vmensagem_erro = "Cliente " + ClienteContratoEntrada.codigo_cpfcnpj + 
            " nao encontrado.".

end.
else assign
        vstatus = "E"
        vmensagem_erro = "Parametros de Entrada nao recebidos.".

BSXml("ABREXML","").
bsxml("abretabela","ParcelasRetorno").
bsxml("status",vstatus).
bsxml("mensagem_erro",vmensagem_erro).
    
if vstatus = "S" /* avail clien*/
then do:        
    bsxml("codigo_cliente",string(clien.clicod)).
    bsxml("cpf_cnpj", Texto(clien.ciccgc)).
    bsxml("nome",Texto(clien.clinom)).
     
    do vi = 1 to 4.
        create tt-modal.
        tt-modal.modcod = mmodal[vi].
        tt-modal.etbcod = mestab[vi].
    end.


    find first agfilcre where
        agfilcre.tipo = "CENTRAL" /*and
        agfilcre.etbcod = setbcod */
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
            each titulo where
                titulo.empcod = 19 and
                titulo.titnat = no and
                titulo.modcod = tt-modal.modcod and
                titulo.etbcod = estab.etbcod and
                titulo.clifor = clien.clicod and
                titulo.titsit = "LIB" /* titulo.titdtpag = ? */
                and
                (if ClienteContratoEntrada.numero_contrato <> ? and
                    ClienteContratoEntrada.numero_contrato <> "" and
                    ClienteContratoEntrada.numero_contrato <> "?"
                  then titulo.titnum = 
                    string(int(ClienteContratoEntrada.numero_contrato))
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
  
    bsxml("situacao_cliente",vsituacao_cliente).
    

  vaberto = yes. 

  /*10*/ /* Inicio */
  if venviar
  then do:
  /*10*/ /* Fim */

    for each estab no-lock,
        each tt-modal no-lock,
        each titulo where
            titulo.empcod = 19 and
            titulo.titnat = no and
            titulo.modcod = tt-modal.modcod and
            titulo.etbcod = estab.etbcod and
            titulo.clifor = clien.clicod and
            titulo.titsit = "LIB" /* titulo.titdtpag = ? */
                and
            (if ClienteContratoEntrada.numero_contrato <> ? and
                ClienteContratoEntrada.numero_contrato <> "" and
                ClienteContratoEntrada.numero_contrato <> "?"
              then titulo.titnum = 
                string(int(ClienteContratoEntrada.numero_contrato))
              else true)
            no-lock
            break by titulo.titnum
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
            BSXml("ABREREGISTRO","contratos"). 
            bsxml("filial_contrato",string(titulo.etbcod)).
            bsxml("modalidade",titulo.modcod).
            bsxml("numero_contrato",string(int(titulo.titnum),"9999999999")).
            bsxml("data_emissao_contrato",EnviaData(titulo.titdtemi)).
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
                else vvalor_total_pago     = vvalor_total_pago     + 
                                             btitulo.titvlcob.

                if  btitulo.titsit <> "LIB" /* btitulo.titdtpag <> ? */
                then next.

                /** BASE MATRIZ  */
                vjuros = 0.
                if btitulo.titsit = "LIB" /* btitulo.titdtpag = ? */
                   and btitulo.titdtven < today
                then run juro_titulo_portal.p (if clien.etbcad = 0 then titulo.etbcod else clien.etbcad, /* helio 07112020 */
                                        btitulo.titdtven, btitulo.titvlcob,
                                        output vjuros).

                vvalor_total_encargo = vvalor_total_encargo + vjuros.
            end.        

            bsxml("valor_contrato",string(vvalor_contrato,">>>>>>>>>>>>9.99")).
            bsxml("valor_total_pago",
                                string(vvalor_total_pago,">>>>>>>>>>>>9.99")).
            bsxml("valor_total_pendente",string(vvalor_total_pendente,
                            ">>>>>>>>>>>>9.99")).
            bsxml("valor_total_encargo",string(vvalor_total_encargo,
                            ">>>>>>>>>>>>9.99")).
            bsxml("tp_contrato", titulo.tpcontrato). /* #1 */
        end.

        BSXml("ABREREGISTRO","parcelas").
        bsxml("seq_parcela",string(titulo.titpar)).
        bsxml("venc_parcela",string(year(titulo.titdtven),"9999") + "-" +
                             string(month(titulo.titdtven),"99")   + "-" + 
                             string(day(titulo.titdtven),"99")   + 
                                     "T00:00:00").
        bsxml("vlr_parcela",string(titulo.titvlcob,">>>>>>>>9.99")).

        /** BASE MATRIZ  */
        vjuros = 0.
        if titulo.titsit = "LIB" /* titulo.titdtpag = ? */
        then run juro_titulo_portal.p (if clien.etbcad = 0 then titulo.etbcod else clien.etbcad, /* helio 07112020 */
                        titulo.titdtven, titulo.titvlcob,
                                output vjuros).

        bsxml("valor_encargos",string(vjuros,">>>>>>>>>>9.99")).


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

        bsxml("possui_boleto",vpossui_boleto).

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

        bsxml("possui_ted",vpossui_ted).
         
        /**
        bsxml("percentual_encargo_dia",string(0)).
        bsxml("valor_desconto",if titulo.titvlpag = 0 or
                                  titulo.titvlpag >= titulo.titvlcob
                               then string("0.00")
                               else string(titulo.titvlcob - titulo.titvlpag,
                                    ">>>>>>>>>>9.99")).
           **/
        BSXml("FECHAREGISTRO","parcelas").

        if last-of(titulo.titnum)
        then do:
            BSXml("FECHAREGISTRO","contratos"). 
        end.        
    end. /* estab */
 end. /*10*/
    /** 
    bsxml("aviso", vmensagem).
    bsxml("bloqueia", if vbloqueia then "sim" else "nao").
    **/
end.

bsxml("fechatabela","ParcelasRetorno").
BSXml("FECHAXML","").

