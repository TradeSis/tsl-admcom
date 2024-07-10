/*  helio 24102022 - ID 152286 - Valor de novação - Principal menor que as parcelas - fim*/

DEFINE INPUT  PARAMETER lcJsonEntrada      AS LONGCHAR.
def    output param     verro as char no-undo.
verro = "".
def var tiposervico as char.
DEFINE var lcJsonsaida      AS LONGCHAR.

def var vecommerce as log.
/*helio*/ def var vidacordo as char. def var vt as int. def var vint64 as int64.
def var voriginal as dec.
def var vtpseguro as int.
def var vctmcod  like pdvmov.ctmcod.
def var vmodcod     like contrato.modcod.
def var vdatamov as date. /* 01.12.2017 */
def var vnsu     as int.
def var vseqreg as int.

def var vmovseq as int.
def var vcodigo_forma  as char. 
def var vtitpar as int.

def var vultima as dec.
def var vtotal as dec.
def var vtotalsemjuros as dec.
def var vtitvlcobsemjuros as dec.
def var vtitvlcob as dec.
def var vi as int.
def var vmes as int.
def var vano as int.
def var vdia as int.
def var vvenc as date.
def var vseqforma as int.
def var vseqfp as int.

def var vvalor_vista as dec.
def var vvalor_contrato as dec.

{/admcom/barramento/functions.i}

{/admcom/barramento/async/renegociacaocrediario_01.i}

/* LE ENTRADA */
lokJSON = hrenegociacaoCrediarioEntrada:READ-JSON("longchar",lcJsonEntrada, "EMPTY").


/**def var vsaida as char.
find first ttrenegociacaocrediario.
vsaida = "./json/"  
                           + trim(ttrenegociacaocrediario.codigoLoja)  + "_"
                           + trim(ttrenegociacaocrediario.dataTransacao) + "_"
                           + trim(ttrenegociacaocrediario.numeroComponente) + "_"
                           + trim(ttrenegociacaocrediario.nsuTransacao) + "_"
                           + "renegociacaocrediario.json".
hrenegociacaocrediarioEntrada:WRITE-JSON("FILE",vsaida, true).
**/

for each ttrenegociacaocrediario.
    
    for each ttparcelasRenegociadas where ttparcelasRenegociadas.idpai = ttrenegociacaocrediario.id.
                /*
                     field cpfCnpjCliente as char
        field codigoCliente as char
        field numeroContrato as char
        field modalidadeContrato as char
        field carteiraContrato as char
        field seqParcela as char
        field dataVencimentoParcela as char
        field dataPagamentoParcela as char
        field valorParcela as char
        field valorEncargoAtraso as char
        field valorDispensaJuros as char
        field valorPago as char
        field pagtoParcial as char
            */
        find contrato where contrato.contnum = int(ttparcelasRenegociadas.numeroContrato) no-lock no-error.
        if not avail contrato
        then do:
            verro = "Contrato " + ttparcelasRenegociadas.numeroContrato + " Nao existe no TS Crediario".
            leave.
        end.
        else do:
            find titulo where titulo.empcod = 19 and
                              titulo.titnat = no and  
                              titulo.modcod = contrato.modcod and
                              titulo.etbcod = contrato.etbcod and
                              titulo.clifor = contrato.clicod and
                              titulo.titnum = string(contrato.contnum) and
                              titulo.titpar = 
                                int(ttparcelasRenegociadas.seqParcela) and
                              titulo.titdtemi = contrato.dtinicial
                              no-lock no-error.
            if not avail titulo
            then find titulo where titulo.empcod = 19 and
                              titulo.titnat = no and  
                              titulo.modcod = contrato.modcod and
                              titulo.etbcod = contrato.etbcod and
                              titulo.clifor = contrato.clicod and
                              titulo.titnum = string(contrato.contnum) and
                              titulo.titpar = 
                                int(ttparcelasRenegociadas.seqParcela)
                              no-lock no-error.
 
            if not avail titulo
            then do:
                verro = "Parcela " + string(contrato.contnum) + "/" + ttparcelasRenegociadas.seqParcela + " Nao existe no TS Crediario".
                leave.
            end.
        end.
    end.
end.    

if verro <> ""
then return.

for each ttrenegociacaocrediario.

        /*
        */
        
    vctmcod  = "P48".
                   
    vdatamov = aaaa-mm-dd_todate(ttrenegociacaocrediario.dataTransacao).
    vnsu     = int(ttrenegociacaocrediario.nsuTransacao).

    find cmon where
            cmon.etbcod = int(ttrenegociacaocrediario.codigoLoja) and
            cmon.cxacod = int(ttrenegociacaocrediario.numeroComponente)
            no-lock no-error.
    if not avail cmon 
    then do on error undo: 
        create cmon. 
        assign 
            cmon.cmtcod = "PDV" 
            cmon.etbcod = int(ttrenegociacaocrediario.codigoLoja)
            cmon.cxacod = int(ttrenegociacaocrediario.numeroComponente)
            cmon.cmocod = int(string(cmon.etbcod) + string(cmon.cxacod,"999")) 
            cmon.cxanom = "Lj " + string(cmon.etbcod) + " " + 
                          "Cx " + string(cmon.cxacod). 
    end.

    do on error undo:
    find first pdvmov where
        pdvmov.etbcod = cmon.etbcod and
        pdvmov.cmocod = cmon.cmocod and
        pdvmov.datamov = vdatamov and
        pdvmov.sequencia = vnsu and
        pdvmov.ctmcod = vctmcod and
        pdvmov.coo    = int(vnsu)
        no-error.
    if not avail pdvmov
    then do:            
        create pdvmov.
        pdvmov.etbcod = cmon.etbcod.
        pdvmov.cmocod = cmon.cmocod.
        pdvmov.datamov = vdatamov.
        pdvmov.sequencia = vnsu.
        pdvmov.ctmcod = vctmcod.
        pdvmov.coo    = int(vnsu).
    end.        
    else do:
        verro = "JA INCLUIDO".
        return.
    end.    

    pdvmov.valortot   = dec(valorTotalRecebido).
    pdvmov.valortroco = dec(valortroco).

    pdvmov.codigo_operador =  codigoOperador.
        
    pdvmov.HoraMov    = hora_totime(horaTransacao).
    pdvmov.EntSai     = yes.
    pdvmov.statusoper = "".
/*    pdvmov.tipo_pedido = int(ora-coluna("tipo_pedido")).  */

    end.
    
    vseqreg = 0.
    for each ttparcelasRenegociadas where ttparcelasRenegociadas.idpai = ttrenegociacaocrediario.id.
                /* 
        field carteiraContrato as char
         field dataPagamentoParcela as char
            */
    
        vseqreg = vseqreg + 1.
        
        find first pdvdoc of pdvmov where pdvdoc.seqreg = vseqreg no-error.
        if not avail pdvdoc
        then do:
            create pdvdoc.
            assign 
                pdvdoc.etbcod    = pdvmov.etbcod
                pdvdoc.DataMov   = pdvmov.DataMov
                pdvdoc.cmocod    = pdvmov.cmocod
                pdvdoc.COO       = pdvmov.COO
                pdvdoc.Sequencia = pdvmov.Sequencia
                pdvdoc.ctmcod    = pdvmov.ctmcod
                pdvdoc.seqreg    = vseqreg
                /*pdvdoc.titcod    = ?*/ .
        end.  
        
        pdvdoc.valor = dec(valorPago).
        pdvdoc.clifor = dec(codigoCliente) no-error.
        if pdvdoc.clifor = ? or
           pdvdoc.clifor = 0
        then pdvdoc.clifor = 1.

       pdvdoc.contnum  = trim(ttparcelasRenegociadas.numeroContrato).
       pdvdoc.titpar   = int(seqParcela).
       pdvdoc.titdtven = aaaa-mm-dd_todate(dataVencimentoParcela).
       pdvdoc.modcod   = modalidadeContrato.

              
        find titulo where titulo.contnum = int(pdvdoc.contnum) and
                         titulo.titpar   = pdvdoc.titpar
                         no-lock no-error.
        if not avail titulo
        then do:                           
            find contrato where contrato.contnum = int(pdvdoc.contnum) no-lock no-error.
            if avail contrato
            then do: 
                find titulo where
                        titulo.empcod = 19 and
                        titulo.titnat = no and
                        titulo.etbcod = contrato.etbcod and
                        titulo.clifor = contrato.clicod and
                        titulo.modcod = contrato.modcod and
                        titulo.titnum = pdvdoc.contnum and
                        titulo.titpar = pdvdoc.titpar /*and
                        titulo.titdtemi = contrato.dtinicial*/
                    no-lock no-error.
                if not avail titulo
                then do:
                    verro = 
                           " SEQ=" + string(vseqreg) +
                           " Titulo nao encontrado:" +
                           " Clien=" + string(pdvdoc.clifor) +
                           " Titulo=" + pdvdoc.contnum +
                           " Vecto=" + string(pdvdoc.titdtven) +
                           " Valor=" + string(pdvdoc.titvlcob) +
                           " Modal=" + vmodcod.
                end.
                else do:
                    find current titulo exclusive.
                    titulo.contnum = int(pdvdoc.contnum).
                end.
            end.         
        end.
    
       pdvdoc.pago_parcial =  string(true_tolog(pagtoParcial),"S/N"). 
       
       /** 15.06.20202 marretar para pagar o titulo pelo seu saldo , sem juros 
       *pdvdoc.desconto_tarifa = 0 /*dec(valorDispensaJuros)*/ .
       *pdvdoc.valor_encargo   = dec(valorEncargoAtraso).
       *pdvdoc.valor = dec(valorPago).
       *if pdvdoc.pago_parcial = "N"
       *then if pdvdoc.valor < (if avail titulo then titulo.titvlcob else pdvdoc.valor)
       *     then  pdvdoc.desconto_tarifa = (if avail titulo then titulo.titvlcob else pdvdoc.valor) - pdvdoc.valor.
       *     else  pdvdoc.valor_encargo   = if pdvdoc.valor - dec(ttparcelasrenegociadas.valorParcela) > pdvdoc.valor_encargo
       *                                    then pdvdoc.valor - dec(ttparcelasrenegociadas.valorParcela)
       *                                    else pdvdoc.valor_encargo.  
       *pdvdoc.titvlcob = pdvdoc.valor - pdvdoc.valor_encargo + pdvdoc.desconto_tarifa.
       ***/
       /* novacao baixa parcela origem pelo saldo */
       pdvdoc.valor_encargo = 0 /*dec(valorEncargoAtraso)*/.
       pdvdoc.desconto       = 0 /*dec(valorDispensaJuros)*/.
       pdvdoc.valor         = titulo.titvlcob.
       pdvdoc.titvlcob      = titulo.titvlcob.
       
                find titprotparc where 
                        titprotparc.operacao = "IEPRO" and
                        titprotparc.contnum  = int(titulo.titnum) and
                        titprotparc.titpar   = titulo.titpar
                        no-lock no-error.
                if avail titprotparc
                then do:
                    find titprotesto of titprotparc no-lock no-error.
                    if avail titprotesto
                    then     if titprotesto.pagacustas then pdvdoc.titvlrcustas = titprotparc.titvlrcustas.
                    
                end.
       /**/
    end.



    /* RECEBIMENTOS */
    
    message "RECBIMENTOS".    
    {/admcom/barramento/async/recebimentos.i ttrenegociacaocrediario.id}
    
    voriginal = 0.
    vmodcod = "".
    vidacordo = ?.
           
    message "transaction?" transaction.
    def var vconta as int.
    for each pdvdoc of pdvmov no-lock.
        vconta  = vconta + 1.
    end.

    for each pdvdoc of pdvmov.
        message "BAIXANDO" vconta pdvdoc.contnum "/" pdvdoc.titpar. 
        vconta = vconta - 1. 
    
        find titulo where titulo.contnum = int(pdvdoc.contnum) and
                         titulo.titpar   = pdvdoc.titpar
                         exclusive no-wait no-error.
        if avail titulo
        then do: 
            /* helio 
                acha acordo */
            message "   " string(time,"HH:MM:SS") " Achando Acordo origem" pdvdoc.contnum    .
            for each cybacorigem where cybacorigem.contnum = int(pdvdoc.contnum) no-lock.
                do vt = 1 to num-entries(cybacorigem.ParcelasLista).
                    if int(entry(vt,cybacorigem.ParcelasLista)) = titulo.titpar
                    then do:
                        vidacordo = string(cybacorigem.idacordo).
                        leave.
                    end.
                end.
                if vidacordo <> ? then leave.
            end.     
            message "   " string(time,"HH:MM:SS") " Achando Acordo origem" pdvdoc.contnum    "ACORDO " vidacordo.

            voriginal = voriginal + pdvdoc.titvlcob.

            run /admcom/progr/fin/baixatitulo.p (recid(pdvdoc),
                                                 recid(titulo)).
            message "   " string(time,"HH:MM:SS") " rodando baixa titulo  fim" .

            assign     
                titulo.moecod   = if pdvmov.ctmcod = "P7" 
                                  then "PDM"
                                  else "NOV"
                titulo.etbcobra = pdvdoc.etbcod 
                titulo.datexp   = today 
                titulo.cxmdata  = pdvdoc.datamov 
                titulo.cxmhora  = string(pdvmov.horamov) 
                titulo.cxacod   = cmon.cxacod.
                
                
                if pdvmov.ctmcod = "P48"
                then do:
                    
                    titulo.moecod = "NOV".
                    if titulo.modcod begins "CP"
                    then vmodcod = "CPN". /* Se origem for CP */

                    find first pdvforma of pdvmov where pdvforma.modcod = "CRE" no-lock no-error.

                    message "   " string(time,"HH:MM:SS") " achando tit_novacao    tit_novacao3" 
                        vidacordo
                        titulo.empcod titulo.titnat titulo.modcod titulo.etbcod titulo.clifor titulo.titnum titulo.titpar titulo.titdtemi .
                    
                    do on error undo, next.
                    if vidacordo <>  ?
                    then find first tit_novacao  where
                         tit_novacao.ori_empcod   = titulo.empcod and
                         tit_novacao.ori_titnat   = titulo.titnat and
                         tit_novacao.ori_modcod   = titulo.modcod and
                         tit_novacao.ori_etbcod   = titulo.etbcod and
                         tit_novacao.ori_clifor   = titulo.clifor and
                         tit_novacao.ori_titnum   = titulo.titnum and
                         tit_novacao.ori_titpar   = titulo.titpar and
                         tit_novacao.ori_titdtemi = titulo.titdtemi and
                         tit_novacao.id_acordo   = vidacordo and
                         tit_novacao.tipo         = ""
                        exclusive no-wait no-error.
                    if not avail tit_novacao
                    then 
                    find first tit_novacao use-index tit_novacao3 where
                         tit_novacao.ori_empcod   = titulo.empcod and
                         tit_novacao.ori_titnat   = titulo.titnat and
                         tit_novacao.ori_modcod   = titulo.modcod and
                         tit_novacao.ori_etbcod   = titulo.etbcod and
                         tit_novacao.ori_clifor   = titulo.clifor and
                         tit_novacao.ori_titnum   = titulo.titnum and
                         tit_novacao.ori_titpar   = titulo.titpar and
                         tit_novacao.ori_titdtemi = titulo.titdtemi and
                         tit_novacao.tipo         = ""
                        exclusive no-wait no-error.
                    if not avail tit_novacao
                    then do:
                        create tit_novacao.
                        assign
                         tit_novacao.ori_empcod   = titulo.empcod
                         tit_novacao.ori_titnat   = titulo.titnat
                         tit_novacao.ori_modcod   = titulo.modcod
                         tit_novacao.ori_etbcod   = titulo.etbcod
                         tit_novacao.ori_clifor   = titulo.clifor
                         tit_novacao.ori_titnum   = titulo.titnum
                         tit_novacao.ori_titpar   = titulo.titpar
                         tit_novacao.ori_titdtemi = titulo.titdtemi
                         tit_novacao.ori_titvlcob = titulo.titvlcob
                         tit_novacao.ori_titdtven = titulo.titdtven.
                         tit_novacao.id_acordo    = vidacordo.
                    end.                         
                    
                        assign
                         tit_novacao.tipo         = "RENEGOCIACAO"
                         tit_novacao.ger_contnum  = if avail pdvforma then int(pdvforma.contnum) else ?
                         tit_novacao.ori_titdtpag = titulo.titdtpag
                         tit_novacao.ori_titdtpag = pdvmov.datamov
                         tit_novacao.dtnovacao    = pdvmov.datamov
                         tit_novacao.hrnovacao    = pdvmov.horamov
                         tit_novacao.etbnovacao   = pdvmov.etbcod
                         tit_novacao.funcod       = int(pdvmov.codigo_operador)
                         tit_novacao.datexp       = today
                         tit_novacao.exportado    = no.
                         vidacordo = tit_novacao.id_acordo.
                    end.   
                   message "   " string(time,"HH:MM:SS") " achando titnovacao fim" vidacordo.
                    
                end.

    
        end.
        message "BAIXANDO" pdvdoc.contnum "/" pdvdoc.titpar "fim". 
        
    end.
    message "Ajustes acrescimo".
    do on error undo.
        find first pdvforma of pdvmov where pdvforma.modcod = "CRE" no-lock no-error.
        if avail pdvforma
        then do on error undo:
            find contrato where contrato.contnum = int(pdvforma.contnum) exclusive no-error.
            if avail contrato
            then do:
                if vmodcod <> ""
                then contrato.modcod = vmodcod.
                                
                /* 24102022 ID 152286 - Valor de novação - Principal menor que as parcelas*/
                def var voriginal_financiado as dec.
                def var voriginal_desconto as dec.
                def var vfinanciado as dec.
                def var vdesconto   as dec.

                /* nova formula                */

                voriginal_financiado = voriginal - contrato.vlentra.
                if voriginal_financiado < 0 then voriginal_financiado = 0.

                vfinanciado = (contrato.vltotal - contrato.vlentra) /*SEM IOF- contrato.vliof*/ - contrato.vlseguro. 
                
                voriginal_desconto = voriginal_financiado - vfinanciado.
                if voriginal_desconto < 0
                then voriginal_desconto = 0.
                
                contrato.vlf_principal = if voriginal_financiado > 0
                                         then if voriginal_desconto > 0
                                              then voriginal_financiado - voriginal_desconto
                                              else voriginal_financiado 
                                         else 0.
                contrato.vlf_acrescimo  = vfinanciado - contrato.vlf_principal.
                
                message "ID 152286" contrato.contnum "ORIGINAL=" voriginal "ORIG_FINANC=" voriginal_financiado
                    "FINANCIADO=" vfinanciado "ORIG_DESCONTO=" voriginal_desconto.                              
                /***/
                                                
                /** ID 152286
                    antiga formula
                    contrato.vlf_principal = if voriginal < contrato.vltotal - contrato.vliof - contrato.vlseguro
                                         then voriginal
                                         else contrato.vltotal - contrato.vliof - contrato.vlseguro.
                contrato.vlf_acrescimo = contrato.vltotal - contrato.vlentra - contrato.vliof - contrato.vlseguro - contrato.vlf_principal.
                if contrato.vlf_acrescimo < 0
                then contrato.vlf_acrescimo = 0.
                **/
                /* ID 152286 - Valor de novação - Principal menor que as parcelas - fim*/
                
                    /* helio 02092022 - projeto Criar Produtos - ADM */
                     if contrato.vlf_acrescimo < 1
                     then contrato.crecod = 501. 
                     else contrato.crecod = 500.
                    
                
                for each titulo where titulo.contnum = contrato.contnum.
                    titulo.modcod = contrato.modcod.

                    /* ID 152286 */
                    if titulo.titpar = 0
                    then do:
                        titulo.vlf_principal = 0.
                        titulo.vlf_acrescimo = 0.
                    end.
                    else do:
                        titulo.vlf_principal = contrato.vlf_principal / contrato.nro_parcelas.
                        titulo.vlf_acrescimo = contrato.vlf_acrescimo / contrato.nro_parcelas.
                    end.  
                                  
                    
                    if vidacordo <> ?
                    then do:
                        vint64 = int64(vidacordo) no-error.
                        if vint64 <> ?
                        then do:
                            find first cybacparcela where cybacparcela.idacordo = int64(vidacordo) and
                                                          cybacparcela.parcela  = titulo.titpar
                                                          no-error.
                            if avail cybacparcela and cybacparcela.contnum = ?
                            then cybacparcela.contnum =  contrato.contnum.
                        end.
                    end.       
                end.
            end.
        end.
    end.
    message "fim loop" transaction.
end.
message "final".







