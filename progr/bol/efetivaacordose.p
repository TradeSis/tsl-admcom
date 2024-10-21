
/* helio 17022022 263458 - Revisão da regra de novações */
/* #H1 helio.neto 30072021 - ajustou a moecod, para a mesma regra de outras, que é pelo tipo de baixa */

/* Gestao de Boletos   - rotinas
   bol/efetivaacordo_v2101.p
   Efetiva acordo criando Contrato/Titulos e Baixando TitulosOriginais 
#1 22.02.2018 Helio - Corretiva TP 22125274 - Acerto para baixar titulo origem
   pelo valor do titulo, e nao o do parametro que é o valor da entrada do acordo
#2 TP 28872041 16.01.19 - Etbcod e modcod na origem
*/

/**
    {cabec.i}
**/
def input parameter par-pdvmov as recid.
def input parameter par-seqreg  as int.

def input parameter par-bolorigem as recid.
def input parameter par-titdtpag  as date.
def input parameter par-titvlpag  as dec.
def input parameter par-titjuro   as dec.  
def output param    par-ok as log.

def buffer origem-aoacparcela for aoacparcela.
def buffer ocontrato for contrato.

def var vvlentra as dec.
def var vcontnum like contrato.contnum.
def var vetbcod  as int.
def var vmodcod     like titulo.modcod.
def var vparc    as int.
def var vseq as int.
par-ok = no.
def buffer epdvmov for pdvmov.
def var prec as recid.

find pdvmov where recid(pdvmov) = par-pdvmov no-lock.

            /* helio 25.11.2021 - cria movimento soh com a entrada */
            
                    find first pdvtmov where pdvtmov.ctmcod = "BSE" no-lock.

                    find cmon where cmon.etbcod = 999 and cmon.cxacod = 99 no-lock.
                    
                    run fin/cmdincdt.p (recid(cmon), recid(pdvtmov), 
                                        par-titdtpag,
                                        output prec).

                    find epdvmov where recid(epdvmov) = prec no-lock.


find banbolorigem where recid(banbolorigem) = par-bolorigem no-lock.
find banboleto of banbolorigem no-lock.
 
find origem-aoacparcela where 
     origem-aoacparcela.idacordo = int(entry(1,banbolorigem.dadosOrigem)) and
     origem-aoacparcela.parcela  = int(entry(2,banbolorigem.dadosOrigem))
    no-lock no-error.
    
if not avail origem-aoacparcela
then return.
find aoacordo of origem-aoacparcela no-lock no-error.
if not avail aoacordo
then return.

def var psicred as recid.

if aoacordo.dtefetiva = ? 
then do:
    
    do for geranum on error undo on endkey undo: 
    /*** Numeracao para CONTRATOS criados na matriz ***/ 
        find geranum where geranum.etbcod = 999 exclusive no-error. 
        if not avail geranum 
        then do: 
            create geranum. 
            assign geranum.etbcod  = 999 
                geranum.clicod  = 300000000 
                geranum.contnum = 300000000. 
        end. 
        geranum.contnum = geranum.contnum + 1. 
        find current geranum no-lock. 
        vcontnum = geranum.contnum. 
    end.

    find first aoacorigem of aoacordo /* #2 */ NO-LOCK no-error.
    find ocontrato of aoacorigem no-lock.
    vetbcod = ocontrato.etbcod.

    if ocontrato.modcod begins "CP" 
    then vmodcod = "CPN".
    else vmodcod = ocontrato.modcod.
    
    if aoacordo.etbcod = 982
    then vmodcod = "RFN".

    do on error undo:
        create contrato.
        ASSIGN
            contrato.contnum   = vcontnum
            contrato.clicod    = aoacordo.clifor
            contrato.dtinicial = par-titdtpag
            contrato.etbcod    = aoacordo.etbcod
            contrato.vltotal   = 0
            contrato.vlentra   = 0
            contrato.modcod    = vmodcod
            contrato.crecod    = 500
            contrato.banco = if vmodcod = "CPN"
                             then 13 else 10
            contrato.tpcontrato = if vmodcod = "RFN" then "" else "N". /* helio 21062024 -- */

        /* helio 25.11.2021 ID 98001 - Novações cslog fora da estrutura padrão para origem e novo.
                criando forma e pdvmoeda */
            find first pdvforma where      
                     pdvforma.etbcod     = pdvmov.etbcod and
                 pdvforma.cmocod     = pdvmov.cmocod and
                 pdvforma.DataMov    = pdvmov.DataMov and
                 pdvforma.Sequencia  = pdvmov.Sequencia and
                 pdvforma.ctmcod     = pdvmov.ctmcod and
                 pdvforma.COO        = pdvmov.COO and
                 pdvforma.seqforma   = 1
                no-error.
            if not avail pdvforma 
            then do: 
                create pdvforma.
                assign
                    pdvforma.etbcod     = pdvmov.etbcod
                    pdvforma.DataMov    = pdvmov.DataMov
                    pdvforma.cmocod     = pdvmov.cmocod
                    pdvforma.COO        = pdvmov.COO
                    pdvforma.Sequencia  = pdvmov.Sequencia
                    pdvforma.ctmcod     = pdvmov.ctmcod 
                    pdvforma.seqforma   = 1.
            end.                     

            find pdvtforma where pdvtforma.pdvtfcod = "93" no-lock no-error.
            pdvforma.crecod       = contrato.crecod.
            pdvforma.modcod       = contrato.modcod.
            pdvforma.pdvtfcod     = "93".
            pdvforma.fincod       = 1.
            pdvforma.valor_forma  = contrato.vlTotal.
            pdvforma.valor        = contrato.vlTotal.


            pdvforma.contnum      = string(contrato.contnum).
            pdvforma.clifor       = contrato.clicod.
            pdvforma.crecod       = 2.
            
            pdvforma.qtd_parcelas = contrato.nro_parcela.
            pdvforma.valor_ACF    = contrato.vlf_Acrescimo.
            pdvforma.valor        = contrato.vlTotal.
        /* helio 25.11.2021 ID 98001 - Novações cslog fora da estrutura padrão para origem e novo.
                criando forma e pdvmoeda */

    end.                                                    

    /* helio 17022022 263458 - Revisão da regra de novações */
    def var vtitvlori as dec.
    def var vvalorparcela as dec.
    def var vqtdparcelas as int.
    def var vtitvlaco as dec.
    def var vvalorAcrescimo as dec.
    def var pcobcod as int.
    
    for each aoacorigem of aoacordo /* #2 */ NO-LOCK.
                
                vtitvlori = vtitvlori + aoacorigem.vlcob. 
    end.            
    
    vvalorparcela = ?.        
    vqtdParcelas = 0.
    vtitvlaco = 0.
    vvlentra = 0.
    for each aoacparcela of aoacordo
        by aoacparcela.parcela.

        vtitvlaco = vtitvlaco + aoacparcela.vlCobrado.
        
        if aoacparcela.parcela = origem-aoacparcela.parcela
        then do:    
            if aoacparcela.parcela = 0
            then vvlentra = aoacparcela.vlCobrado.
            next.
        end.    
        
        if vvalorparcela = ?
        then vvalorparcela = aoacparcela.vlCobrado.
        vqtdParcelas = vqtdParcelas + 1.
    end.  
    vvalorAcrescimo = vtitvlaco - vtitvlori - vvlentra.
    if vvalorAcrescimo < 0 then vvalorAcrescimo = 0.
              /* #27092022 helio */
              if vvalorAcrescimo > 0 and vvalorAcrescimo <= 5.00
              then do:
                    vtitvlori = vtitvlori + vvalorAcrescimo.
                    vvalorAcrescimo = 0.   
              end.
    
    do on error undo:
        
        contrato.vlf_acrescimo = vvalorAcrescimo.
        contrato.vlf_principal = vtitvlori.
        contrato.nro_parcelas  = vqtdParcelas.     
        if vvlentra > 0
        then vqtdParcelas =  vqtdParcelas + 1.
        
    end.    

     /* helio 122022 - onda 3 */ 
     if contrato.crecod = 500
     then do: 
                     /* depara */
                     find last findepara where 
                             findepara.prazo      = vqtdparcelas and
                             findepara.comentrada = yes and
                             (
                             if vvalorAcrescimo > 0
                             then  (findepara.taxa_juros <=  100 and findepara.taxa_juros > 0)
                             else  (findepara.taxa_juros = 0)
                             )
                         no-lock no-error.
                     if avail findepara
                     then do:
                         contrato.crecod = findepara.fincod. 
                     end.
     end.
 /* onda 3 */ 
    
            /**/
    run api/verificacarteira.p (input "CSLOG", 
                                input vvalorParcela, 
                                input vqtdParcelas, 
                                input vvalorAcrescimo, 
                                output pcobcod ).

    release sicred_contrato.
    find cobra where cobra.cobcod = pcobcod no-lock no-error.
    if not avail cobra 
    then pcobcod = 1.
    
    if pcobcod = 10 /*sicred*/
    then do:
        
        /** chamar sicred para cet **/
        
        contrato.banco = 13.
        
        run /admcom/progr/fin/sicrecontr_create.p (recid(pdvforma),
                                                 contrato.contnum,
                                                 output psicred).

        find sicred_contrato where recid(sicred_contrato) = psicred no-lock no-error.
        
    end.
    
    /***/
    
    for each aoacparcela of aoacordo
        by aoacparcela.parcela.
        
        if aoacparcela.vlcobrado = 0 then next.
                        
        create titulo.
        ASSIGN
            titulo.empcod     = 19
            titulo.modcod     = contrato.modcod
            titulo.tpcontrato = contrato.tpcontrato 
            titulo.CliFor     = contrato.Clicod
            titulo.titnum     = string(contrato.contnum)
            titulo.titpar     = aoacparcela.parcela
            titulo.titnat     = no
            titulo.etbcod     = contrato.etbcod
            titulo.titdtemi   = par-titdtpag
            titulo.titdtven   = aoacparcela.dtVencimento
            titulo.titvlcob   = aoacparcela.vlCobrado.


        /* helio 25.11.2021 ID 98001 - Novações cslog fora da estrutura padrão para origem e novo.
                criando forma e pdvmoeda */.
                find first pdvmoeda where      
                     pdvmoeda.etbcod       = pdvmov.etbcod and
                     pdvmoeda.cmocod       = pdvmov.cmocod and
                     pdvmoeda.DataMov      = pdvmov.DataMov and
                     pdvmoeda.Sequencia    = pdvmov.Sequencia and
                     pdvmoeda.ctmcod       = pdvmov.ctmcod and
                     pdvmoeda.COO          = pdvmov.COO and
                     pdvmoeda.seqforma     = pdvforma.seqforma and
                     pdvmoeda.seqfp        = 1 and
                     pdvmoeda.titpar       = titulo.titpar
                    no-error.
                if not avail pdvmoeda
                then do: 
                    create pdvmoeda.
                    /*pdvmoeda.titcod   = next-value(titcod).*/
                    assign
                         pdvmoeda.etbcod       = pdvmov.etbcod
                         pdvmoeda.DataMov      = pdvmov.DataMov
                         pdvmoeda.cmocod       = pdvmov.cmocod
                         pdvmoeda.COO          = pdvmov.COO
                         pdvmoeda.Sequencia    = pdvmov.Sequencia
                         pdvmoeda.ctmcod       = pdvmov.ctmcod
                         pdvmoeda.seqforma     = pdvforma.seqforma
                         pdvmoeda.seqfp        = 1
                         pdvmoeda.titpar       = titulo.titpar.   
                end.                  
                assign
                    pdvmoeda.contrato_p2k = pdvforma.contnum.
                pdvmoeda.clifor = contrato.clicod.
                pdvmoeda.titnum = string(contrato.contnum).
                pdvmoeda.moecod = pdvforma.modcod.
                pdvmoeda.modcod = pdvforma.modcod.

                pdvmoeda.valor = titulo.titvlcob.
                pdvmoeda.titdtven = titulo.titdtven.
        /* helio 25.11.2021 ID 98001 - Novações cslog fora da estrutura padrão para origem e novo.
                criando forma e pdvmoeda */.
        
        assign
            aoacparcela.contnum    = contrato.contnum.

        if aoacparcela.parcela = origem-aoacparcela.parcela
        then do:
            assign
                titulo.titdtpag = par-titdtpag
                titulo.titvlpag = titulo.titvlcob + par-titjuro /* #1 */ 
                        /*par-titvlpag*/
                titulo.titjuro  = par-titjuro
                titulo.titsit   = "PAG". 
                
                titulo.etbcobra = 999.
                titulo.moecod    = epdvmov.ctmcod. /* #H1 */
                
            assign
                aoacparcela.dtbaixa  = today
                aoacparcela.situacao = "B". /* Baixado */ 
            vseq = vseq + 1.    
            create pdvdoc.
            ASSIGN
                pdvdoc.etbcod            = epdvmov.etbcod
                pdvdoc.cmocod            = epdvmov.cmocod
                pdvdoc.DataMov           = epdvmov.DataMov
                pdvdoc.Sequencia         = epdvmov.Sequencia
                pdvdoc.ctmcod            = epdvmov.ctmcod
                pdvdoc.COO               = epdvmov.COO
                pdvdoc.seqreg            = par-seqreg + vseq
                pdvdoc.CliFor            = titulo.CliFor
                pdvdoc.ContNum           = string(titulo.titnum)
                pdvdoc.titpar            = titulo.titpar
                pdvdoc.titdtven          = titulo.titdtven.
            ASSIGN
                pdvdoc.pago_parcial      = "N"
                pdvdoc.modcod            = titulo.modcod
                pdvdoc.Desconto_Tarifa   = 0
                pdvdoc.Valor_Encargo     = 0
                pdvdoc.hispaddesc        = "BAIXA ACORDO SERASA " + string(aoacordo.idacordo) + "/" + string(aoacparcela.parcela)   
                                         + " BOLETO " + string(banboleto.nossonumero) . /* ENTRADA */
                pdvdoc.valor             = titulo.titvlcob. /*par-titvlpag.*/
                pdvdoc.titvlcob          = titulo.titvlcob.
                pdvdoc.valor_encargo    = 0.
            if pdvdoc.valor_encargo < 0
            then do:
                    pdvdoc.desconto = pdvdoc.valor_encargo * -1.
                    pdvdoc.valor_encargo = 0.
            end.
            pdvdoc.pstatus = yes.
        end.
        else do: 
            titulo.titsit     = "LIB".
        
            if aoacparcela.parcela = origem-aoacparcela.parcela + 1
            then aoacparcela.situacao = "ENVIARBOLETO".
            else aoacparcela.Situacao = "E".
            
            
            /* helio 17022022 263458 - Revisão da regra de novações */
            
            titulo.cobcod = pcobcod. 
            titulo.vlf_acrescimo  = contrato.vlf_acrescimo / contrato.nro_parcela.
            titulo.vlf_principal  = contrato.vlf_principal / vqtdParcelas.
            
            /**/
        end.            
    
        contrato.vltotal = contrato.vltotal + aoacparcela.vlCobrado.
        if aoacparcela.parcela = 0
        then contrato.vlentra = contrato.vlentra + aoacparcela.vlCobrado.
    end.

    for each aoacorigem of aoacordo /* #2 */ NO-LOCK.
        find ocontrato of aoacorigem no-lock.
        
            find first titulo where
                titulo.empcod = 19 and
                titulo.titnat = no and
                titulo.modcod = ocontrato.modcod /* #2 aoacordo */ and
                titulo.etbcod = ocontrato.etbcod /* #2 aoacordo.etbcod */ and
                titulo.clifor = ocontrato.clicod and
                titulo.titnum = string(ocontrato.contnum) and
                titulo.titpar = aoacorigem.titpar
                exclusive no-error.
            if avail titulo
            then do.
                assign /* #2 */
                    titulo.titdtpag = par-titdtpag
                    titulo.titvlpag = titulo.titvlcob + par-titjuro /* #1 */ 
                        /*par-titvlpag*/ 
                    titulo.titjuro  = par-titjuro
                    titulo.titsit   = "PAG"
                    titulo.moecod   = if vmodcod = "RFN" then vmodcod else pdvmov.ctmcod /* #H1 */
                    titulo.etbcobra = pdvmov.etbcod.
                find current titulo no-lock. /* #2 */

                vseq = vseq + 1.
                do on error undo, next.
                    
                    create pdvdoc.
                    ASSIGN
                        pdvdoc.etbcod            = pdvmov.etbcod
                        pdvdoc.cmocod            = pdvmov.cmocod
                        pdvdoc.DataMov           = pdvmov.DataMov
                        pdvdoc.Sequencia         = pdvmov.Sequencia
                        pdvdoc.ctmcod            = pdvmov.ctmcod
                        pdvdoc.COO               = pdvmov.COO
                        pdvdoc.seqreg            = par-seqreg + vseq
                        pdvdoc.CliFor            = titulo.CliFor
                        pdvdoc.ContNum           = string(titulo.titnum)
                        pdvdoc.titpar            = titulo.titpar
                        pdvdoc.titdtven          = titulo.titdtven.
                    ASSIGN
                        pdvdoc.pago_parcial      = "N"
                        pdvdoc.modcod            = titulo.modcod
                        pdvdoc.Desconto_Tarifa   = 0
                        pdvdoc.Valor_Encargo     = 0
                        pdvdoc.hispaddesc        = "BAIXA ENTRADA ACORDO SERASA " + string(aoacordo.idacordo)
                                                 + " BOLETO " + string(banboleto.nossonumero) . /* ENTRADA */
                        
                        pdvdoc.valor             = titulo.titvlcob. 
                        pdvdoc.titvlcob          = titulo.titvlcob.
                        pdvdoc.valor_encargo    = 0.
                
                    if pdvdoc.valor_encargo < 0
                    then do:
                        pdvdoc.desconto = pdvdoc.valor_encargo * -1.
                        pdvdoc.valor_encargo = 0.
                    end.
                    pdvdoc.pstatus = yes.
                    
                    find cobra of titulo no-lock.
                    if cobra.sicred
                    then run /admcom/progr/fin/sicrepagam_create.p 
                                (recid(pdvdoc),
                                 int(pdvdoc.contnum), 
                                 pdvdoc.titpar,
                                 output psicred).
                    
                    find first tit_novacao where
                         tit_novacao.ori_empcod   = titulo.empcod and
                         tit_novacao.ori_titnat   = titulo.titnat and
                         tit_novacao.ori_modcod   = titulo.modcod and
                         tit_novacao.ori_etbcod   = titulo.etbcod and
                         tit_novacao.ori_clifor   = titulo.clifor and
                         tit_novacao.ori_titnum   = titulo.titnum and
                         tit_novacao.ori_titpar   = titulo.titpar and
                         tit_novacao.ori_titdtemi = titulo.titdtemi and
                         tit_novacao.tipo         = ""
                        exclusive no-error.
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
                         tit_novacao.id_acordo    = ?.
                    end.                         
                    
                    assign
                         tit_novacao.tipo         = "RENEGOCIACAO"
                         tit_novacao.ger_contnum  = contrato.contnum
                         tit_novacao.ori_titdtpag = titulo.titdtpag
                         tit_novacao.ori_titdtpag = pdvmov.datamov
                         tit_novacao.dtnovacao    = pdvmov.datamov
                         tit_novacao.hrnovacao    = pdvmov.horamov
                         tit_novacao.etbnovacao   = pdvmov.etbcod
                         tit_novacao.funcod       = int(pdvmov.codigo_operador)
                         tit_novacao.datexp       = today
                         tit_novacao.exportado    = no.
                end.
                
            end.

    end.
    do on error undo.

        find current aoacordo exclusive.
        assign
            aoacordo.situacao = "E"
            aoacordo.dtefetiva = today. 
        par-ok = yes.
    end.
end.
else do:  /* Acordo j� efetivado, ent�o s� baixca um parcvela */
    find aoacparcela where 
            aoacparcela.idacordo = int(entry(1,banbolorigem.dadosOrigem)) and
            aoacparcela.parcela  = int(entry(2,banbolorigem.dadosOrigem))
        no-lock no-error.
    if not avail aoacparcela
    then return.
    find aoacordo of aoacparcela no-lock no-error.
    if not avail aoacordo
    then return.

    if aoacordo.dtefetiva <> ? 
    then do on error undo:
        find contrato where contrato.contnum = aoacparcela.contnum no-lock.
        find first titulo where
            titulo.empcod = 19 and
            titulo.titnat = no and
            titulo.modcod = contrato.modcod and
            titulo.etbcod = contrato.etbcod and
            titulo.clifor = aoacordo.clifor and
            titulo.titnum = string(aoacparcela.contnum) and
            titulo.titpar = aoacparcela.parcela
        exclusive no-error.
        if avail titulo
        then do:
            /**
            assign
                titulo.titdtpag = par-titdtpag
                titulo.titvlpag = par-titvlpag
                titulo.titjuro  = if titulo.titvlpag > titulo.titvlcob
                                  then titulo.titvlpag - titulo.titvlcob
                                  else 0
                titulo.titsit   = "PAG"
                titulo.etbcobra = 999
                titulo.moecod   = "BCO".
            **/
            
            find current aoacparcela exclusive.
            assign
                aoacparcela.dtbaixa  = today
                aoacparcela.situacao = "B". /* Baixado */ 
        
            
            par-ok = yes.
            
    
            create pdvdoc.
          ASSIGN
            pdvdoc.etbcod            = pdvmov.etbcod
            pdvdoc.cmocod            = pdvmov.cmocod
            pdvdoc.DataMov           = pdvmov.DataMov
            pdvdoc.Sequencia         = pdvmov.Sequencia
            pdvdoc.ctmcod            = pdvmov.ctmcod
            pdvdoc.COO               = pdvmov.COO
            pdvdoc.seqreg            = par-seqreg
            pdvdoc.CliFor            = titulo.CliFor
            pdvdoc.ContNum           = string(titulo.titnum)
            pdvdoc.titpar            = titulo.titpar
            pdvdoc.titdtven          = titulo.titdtven.
          ASSIGN
            pdvdoc.pago_parcial      = "N"
            pdvdoc.modcod            = titulo.modcod
            pdvdoc.Desconto_Tarifa   = 0
            pdvdoc.Valor_Encargo     = 0
                        pdvdoc.hispaddesc        = "BAIXA PARCELA " + string(aoacparcela.parcela) + " ACORDO SERASA " + string(aoacordo.idacordo)
                                                 + " BOLETO " + string(banboleto.nossonumero) .
                        
            pdvdoc.valor             = titulo.titvlcob. /*par-titvlpag.*/
            pdvdoc.titvlcob          = titulo.titvlcob.
            pdvdoc.valor_encargo    = par-titvlpag - titulo.titvlcob.
            if pdvdoc.valor_encargo < 0
            then do:
                pdvdoc.desconto = pdvdoc.valor_encargo * -1.
                pdvdoc.valor_encargo = 0.
            end. 
            
            if titulo.titsit = "LIB" /* #H1 */
            then run /admcom/progr/fin/baixatitulo.p (recid(pdvdoc),
                                                       recid(titulo)).

            else pdvdoc.pstatus = YES.     
            
        end.
    end.
end.




