/***
Jan/2015 - Gerar NFE devolucao
#1 TP 21308480
#2 Garantia/RFQ out/17: unificacao pdvmovim e pdvdevol
#3 Gerar titulo "DEV" liquidado com o que ja foi pago
#4 Maio/2018 - Entrega em outra loja
***/

def input param par-recmov as recid.

/*** NFE ***/
def new shared temp-table tt-plani like plani.
def new shared temp-table tt-movim like movim.
def new shared temp-table tt-nfref like plani.
def var vmovtot   as dec.
def var vmovseq   like movim.movseq.
def var vindicms  like movim.movalicms.
def var valicms   like movim.movalicms.
def var vok       as log.
def var vrec-nota as recid.
def var sresp     as log.
def buffer bcmon   for cmon.
def buffer bpdvdoc for pdvdoc.
def buffer bpdvmov for pdvmov. /* #4 */
def buffer bplani  for plani.

def  shared temp-table tt-devolver
    field procod like movim.procod
    field etbcod like movim.etbcod    
    field movtdc like plani.movtdc
    field placod like plani.placod
    field pladat like plani.pladat
    field movpc  like movim.movpc
    field movqtm like movim.movqtm
    field serie  like plani.serie
    field numero like plani.numero
    field notped like plani.notped
    field movdev like movim.movdev.


def  temp-table tt-devolucao
    field procod like movim.procod
    field etbcod like movim.etbcod
    field movtdc like plani.movtdc
    field placod like plani.placod
    field pladat like plani.pladat
    field movpc  like movim.movpc
    field movqtm like movim.movqtm
    field serie  like plani.serie
    field numero like plani.numero
    field notped like plani.notped
    /*** P2K ***/
    field movdes   like movim.movdes
    field movacfin like movim.movacfin
    field movdev  like movim.movdev.

/*** ***/

find pdvmov where recid(pdvmov) = par-recmov no-lock.
find first pdvdoc of pdvmov no-lock.
find cmon where cmon.cmocod = pdvmov.cmocod no-lock.

/*** Junta produtos ***/
for each pdvmovim of pdvmov no-lock.
    find first tt-devolucao where tt-devolucao.procod = pdvmovim.procod no-error.
    if not avail tt-devolucao
    then do.
        create tt-devolucao.
        assign
            tt-devolucao.procod = pdvmovim.procod
            tt-devolucao.movpc  = pdvmovim.movpc.
    end.
    assign
        tt-devolucao.movqtm = tt-devolucao.movqtm + pdvmovim.movqtm
        tt-devolucao.movdes = tt-devolucao.movdes + pdvmovim.movdes
        tt-devolucao.movacfin = tt-devolucao.movacfin + pdvmovim.movacfin .
    
    find first tt-devolver where tt-devolver.procod = pdvmovim.procod no-error.
    if avail tt-devolver
    then do:
        tt-devolucao.movdev = tt-devolucao.movdev + tt-devolver.movdev.
    end.
end.

if pdvdoc.placod = 0 or
   pdvdoc.placod = ?
then do transaction:
    find estab where estab.etbcod = pdvmov.etbcod no-lock.
    create tt-plani.
    assign
        tt-plani.etbcod   = pdvmov.etbcod
        tt-plani.placod   = ?
        tt-plani.cxacod   = cmon.cxacod
        tt-plani.protot   = 0
        tt-plani.emite    = pdvmov.etbcod
        tt-plani.descpro  = 0
        tt-plani.acfprod  = 0
        tt-plani.frete    = 0
        tt-plani.seguro   = 0
        tt-plani.desacess = 0
        tt-plani.platot   = 0
        tt-plani.serie    = ?
        tt-plani.numero   = ?
        tt-plani.movtdc   = 12
        tt-plani.desti    = pdvmov.etbcod
        tt-plani.pladat   = pdvmov.DataMov
        tt-plani.plaufemi = estab.ufecod
        tt-plani.plaufdes = estab.ufecod
        tt-plani.modcod   = "DEV"
        tt-plani.opccod   = 1202
        tt-plani.vencod   = 0
        tt-plani.notfat   = pdvmov.etbcod
        tt-plani.dtinclu  = pdvmov.DataMov
        tt-plani.horincl  = pdvmov.HoraMov
        tt-plani.notsit   = no
        tt-plani.hiccod   = 1202.

    find bcmon where bcmon.etbcod = pdvdoc.orig_loja
                 and bcmon.cxacod = pdvdoc.orig_componente
               no-lock.
    find first bpdvdoc where
                   bpdvdoc.etbcod    = pdvdoc.orig_loja
               and bpdvdoc.cmocod    = bcmon.cmocod
               and bpdvdoc.datamov   = pdvdoc.orig_data
               and bpdvdoc.Sequencia = pdvdoc.orig_nsu
               no-lock no-error.
    create tt-nfref.
    assign
        tt-nfref.movtdc = 5
        tt-nfref.etbcod = pdvdoc.orig_loja
        tt-nfref.pladat = pdvdoc.orig_data
        tt-nfref.emite  = pdvmov.etbcod
        tt-nfref.desti  = pdvmov.etbcod
        tt-nfref.ufemi  = estab.ufecod
        tt-nfref.numero = ?.

    if avail bpdvdoc
    then do.
        assign
            tt-nfref.placod = bpdvdoc.placod.
        find first bplani where bplani.etbcod = bpdvdoc.etbcod
                            and bplani.placod = bpdvdoc.placod
                          no-lock no-error.
        if avail bplani
        then assign
                tt-nfref.serie  = bplani.serie
                tt-nfref.numero = bplani.numero.

        /* #4 */
        find bpdvmov of bpdvdoc no-lock.
        if bpdvmov.tipo_pedido = 4
        then assign
                tt-nfref.movtdc = 81
                tt-plani.movtdc = 82.
    end.

    if pdvdoc.numero_nfe > 0 /* NFCE */
    then assign
            tt-nfref.serie  = pdvdoc.serie_nfe
            tt-nfref.numero = pdvdoc.numero_nfe
            tt-nfref.notped = pdvdoc.chave_nfe
            tt-nfref.modcod = "NFCE".
    else do.                 /* CF */
        if tt-nfref.numero = ?
        then tt-nfref.numero = pdvdoc.orig_nsu.
        assign
            tt-nfref.notped = "|" + string(tt-nfref.numero) +
                              "|" + string(pdvdoc.orig_componente)
            tt-nfref.modcod = "CF".
    end.

    for each tt-devolucao:
        vmovseq = vmovseq + 1.

        find produ where produ.procod = tt-devolucao.procod no-lock.

        /***
            ICMS
        ***/
        if tt-plani.plaufemi = "RS"
        then do.
            vindicms = produ.proipiper.
            if today <= 12/31/2018
            then
                if produ.proipiper = 98 or
                   produ.proipiper = 99
                then valicms = 0.
                else valicms = 18.
            else
                if produ.proipiper = 98 or
                   produ.proipiper = 99
                then valicms = 0.
                else valicms = 17.
        end.
        else do.
            run /admcom/bs/aliquotaicms.p (produ.procod, 0,
                                           tt-plani.plaufemi, tt-plani.plaufemi,
                                           output vindicms).
            if vindicms = 99 /* ST */
            then valicms = 0.
            else valicms = vindicms.
        end.

            create tt-movim.
            assign
                tt-movim.movtdc    = tt-plani.movtdc
                tt-movim.PlaCod    = ?
                tt-movim.etbcod    = tt-plani.etbcod
                tt-movim.emite     = tt-plani.etbcod
                tt-movim.desti     = tt-plani.etbcod
                tt-movim.movseq    = vmovseq
                tt-movim.movctm    = 0
                tt-movim.procod    = tt-devolucao.procod
                tt-movim.movqtm    = tt-devolucao.movqtm
                tt-movim.movpc     = tt-devolucao.movpc
                tt-movim.MovAlICMS = valicms
                tt-movim.movdat    = tt-plani.pladat
                tt-movim.MovHr     = tt-plani.horincl
                tt-movim.ocnum[7]  = pdvdoc.clifor
                /** P2K **/
                tt-movim.movdes    = tt-devolucao.movdes
                tt-movim.movacfin  = tt-devolucao.movacfin.

                tt-movim.movdev    = tt-devolucao.movdev.
                

            /*** NAO GRAVAR O DESCONTO ***/
            tt-movim.movpc  = tt-movim.movpc 
                              - (tt-movim.movdes / tt-movim.movqtm).
            tt-movim.movdes = 0.
            /*** ***/

            vmovtot = (tt-movim.movpc * tt-movim.movqtm) - tt-movim.movdes
                      + tt-movim.movacfin
                      + tt-movim.movdev.

            if vindicms = 99
            then assign
                    tt-movim.movcsticms = "60"
                    tt-movim.opfcod     = 1411.
            else if vindicms <> 98
            then assign
                    tt-movim.movcsticms = "00"
                    tt-movim.movbicms   = vmovtot
                    tt-movim.movicms    = vmovtot * valicms / 100
                    tt-movim.opfcod     = 1202.
            
            tt-plani.frete = tt-plani.frete + tt-movim.movdev.
            delete tt-devolucao.

            assign
                tt-plani.bicms  = tt-plani.bicms  + tt-movim.movbicms
                tt-plani.icms   = tt-plani.icms   + tt-movim.movicms
                tt-plani.platot = tt-plani.platot + vmovtot 

                /*** P2K ***/
                tt-plani.protot   = tt-plani.protot   + 
                                    (tt-movim.movpc * tt-movim.movqtm)
                tt-plani.descprod = tt-plani.descprod + tt-movim.movdes
                tt-plani.acfprod  = tt-plani.acfprod  + tt-movim.movacfin.
                
                
        end.
        
    run manager_nfe   (output vok).

    do on error undo.
        find first tt-plani no-lock.
        find current pdvdoc exclusive.
        assign
            pdvdoc.placod     = tt-plani.placod
            pdvdoc.contnum    = string(tt-plani.numero).
        find current pdvdoc no-lock.
        for each pdvmovim of pdvmov where pdvmovim.codigo_imei <> "" no-lock.
            /*
            message string(time,"hh:mm:ss") "IMEI" pdvmovim.codigo_imei.
            */
            
            find tbprice where tbprice.tipo   = ""
                           and tbprice.serial = pdvmovim.codigo_imei
                         no-error.
            if avail tbprice
            then assign /* 189:atuger.p */
                    tbprice.etb_venda  = 0
                    tbprice.nota_venda = 0
                    tbprice.data_venda = ?
                    tbprice.char1 = ""
                    tbprice.char2 = ""
                    tbprice.char3 = ""
                    tbprice.vendedor = 0
                    tbprice.venda_efetiva = 0
                    tbprice.dec1  = 0.
        end.
    end.

    if pdvmov.ctmcod = "81" or
       pdvmov.ctmcod = "108"
    then run acertos.
end.
/*
else message string(time,"hh:mm:ss") "ileb/gera-devol Placod =" pdvdoc.placod.
*/

{gerxmlnfe.i}

procedure manager_nfe.

def output parameter v-ok               as log.

def var varquivo  as char.
def var arq_envio as char.
def var vmetodo   as char.
def var vretorno  as char.

def var v-idamb as int format "9".
def var vrec-nota          as recid.
def var vmsg-retorno             as char.
def var vcont    as integer.
def var mail-dest as char.
def var opc-dest as char.
def var mail-tran as char.
def var opc-tran as char initial "".
def var p-valor as char.
def var vnotamax as log.
def var vnum-erro as integer.

run piscofins.p.

run /admcom/progr/loj/nfe_1202_310.p (output sresp, output vrec-nota) no-error.

find first a01_infnfe where recid(a01_infnfe) = vrec-nota no-lock no-error.

find B01_IdeNFe of A01_infnfe no-lock no-error.

v-idamb = 2.
p-valor = "".
run le_tabini.p (A01_infnfe.emite, 0, "NFE - AMBIENTE", OUTPUT p-valor).
if p-valor = "PRODUCAO"
THEN v-idamb = 1.
                       
run arq_xml_nfe_new.p (input recid(A01_infnfe),
                   input v-idamb, 
                   output varquivo).                       


run chama-wsnfe.p(input A01_InfNFe.emite,
               input A01_InfNFe.numero,
               input "NotaMax",
               input "AutorizarNfe",
               input varquivo, 
               input mail-dest,
               input opc-dest,
               input mail-tran,
               input opc-tran,
               output vretorno).

assign p-valor = "".
run le_xml.p(input vretorno,
             input "status_notamax",
             output p-valor).

assign vnum-erro = integer(p-valor).

if vnum-erro = 0
then vnotamax = yes.

if vnum-erro = 1 /**** Erro no Arquivo ****/
then do:
    assign p-valor = "".
    run le_xml.p(input vretorno,
                 input "mensagem_erro",
                 output p-valor).
         
    run trata-retorno-nfe.p (input vretorno,
                             input recid(A01_InfNFe),
                             input 9999,
                             input p-valor,
                             input v-idamb,
                             output vmsg-retorno).
                      
    message string(time,"hh:mm:ss")
            "NF COM ERRO NO ARQUIVO, VERIFIQUE A SITUAÇÃO DA NFE!"
                view-as alert-box.
                             
                                /* Manda 9999 para não conflitar com
                                   retorno "1 - Aguardando Geracao da NFE" */
                             
end.
else if vnum-erro = 0 /**** Arquivo Ok, aguardando envio para a receita ****/
then do:
        
    assign vcont = 0.
           vnotamax = no.
           
    repeat on endkey undo:
        
        message string(time,"hh:mm:ss") "NFE: " A01_InfNFe.numero " enviada, "
                "aguardando retorno da SEFAZ (" vcont ")".
                
        pause 5 no-message.
    
        if vcont > 10
        then do:
            if vnotamax = yes
            then do:
                message string(time,"hh:mm:ss")
                    "NFe NUMERO: " A01_INFNFE.NUMERO SKIP
                    "Nota enviada ao NOTAMAX, verifique a situação no Cockpit".
            end.
            ELSE DO:
                message string(time,"hh:mm:ss")
                    "NFe NUMERO : " A01_INFNFE.NUMERO SKIP
                    "Nota não enviada ao NOTAMAX, verifique a situação no "
                    "Cockpit".
            end.    
            leave.
        end.

        p-valor = "".
        run le_tabini.p (A01_infnfe.emite, 0,
                         "NFE - DIRETORIO ENVIO ARQUIVO", OUTPUT p-valor) .
                         arq_envio = p-valor.

        find C01_Emit of A01_infnfe no-lock.
           
        assign vmetodo = "ConsultarNfe".
        assign varquivo = arq_envio + vmetodo + "_"
                                    + string(A01_infnfe.numero) + "_"
                                    + string(time).

        output to value(varquivo).        
        geraXmlNfe(yes,"cnpj_emitente",C01_Emit.cnpj, no). 
        geraXmlNfe(no, "numero_nota",  string(A01_infnfe.numero),no).
        geraXmlNfe(no, "serie_nota",   string(B01_IdeNFe.serie), yes).
        output close.
    
        /* Apos esperar, realiza uma consulta ao NotaMax */ 
        run chama-wsnfe.p(input A01_infnfe.emite,
                       input A01_InfNFe.numero,
                       input "NotaMax",
                       input vmetodo,
                       input varquivo,
                       input "",
                       input "",
                       input "",
                       input "",
                       output vretorno).

        assign p-valor = "".
        run le_xml.p(input vretorno,
                     input "status_nfe_notamax",
                     output p-valor).
                               
        assign vnum-erro = integer(p-valor).

        if p-valor = ""
        then do:
            assign vcont = vcont + 1.
            next.
        end.
        else case vnum-erro:
            when 1 or  /**   AGUARDA GERAÇÃO DE NF-E                **/
            when 3 or  /**   AGUARDA ASSINATURA                     **/
            when 5 or  /**   AGUARDA ENVIO PARA RECEITA             **/
            when 6 or  /**   AGUARDA AUTORIZAÇÃO DA SEFAZ           **/
            when 11 or /**   AGUARDANDO HOMOLOGAÇÃO DA INUTILIZAÇÃO **/
            when 13 or /**   AGUARDA CANCELAMENTO                   **/
            when 22    /**   AGUARDANDO DESCARTE                    **/
            then do:
                assign vcont = vcont + 1.
                next.
            end.
            otherwise do:
                run trata-retorno-nfe.p (input vretorno,
                                         input recid(A01_InfNFe),
                                         input vnum-erro,
                                         input p-valor,
                                         input v-idamb,
                                         output vmsg-retorno).
                if vnum-erro = 7  /* NFE Autorizada imprime Danfe */
                then do:
                    hide message no-pause.
                    message string(time,"hh:mm:ss") "Autorizada".
                    run /admcom/progr/alt_mov_nfe.p(input "Cria",
                                                    input rowid(A01_infnfe)).
                    /*** run p-imprime-danfe (input recid(A01_InfNFe)). ***/
                    assign v-ok = yes.
                    do on error undo.
                        find current A01_InfNFe exclusive.
                        assign
                            A01_infnfe.sitnfe      = integer(p-valor)
                            A01_infnfe.situacao    = "Autorizada"
                            A01_infnfe.solicitacao = "".
                        find current A01_InfNFe no-lock.
                    end.
                end.    
                else do.
                    hide message no-pause.
                    message string(time,"hh:mm:ss") "vnum-erro = " vnum-erro.
                    assign v-ok = no.
                end.
                leave.
            end.
        end.
    end.
end.
else do:
    run trata-retorno-nfe.p (input vretorno,
                             input recid(A01_InfNFe),
                             input vnum-erro,
                             input p-valor,
                             input v-idamb,
                             output vmsg-retorno).
end.    

end procedure.


procedure acertos.

def var vtpseguro as int.
def buffer ped-cmon   for cmon.
def buffer ped-pdvdoc for pdvdoc.

/**
message string(time,"hh:mm:ss") "Acertos tt-plani:" skip
        "movtdc" tt-plani.movtdc
        "etbcod" tt-plani.etbcod
        "placod" tt-plani.placod
        "numero" tt-plani.serie tt-plani.numero.
**/

for each ctdevven where ctdevven.movtdc = tt-plani.movtdc
                    and ctdevven.etbcod = tt-plani.etbcod
                    and ctdevven.placod = tt-plani.placod
                  no-lock.
    find first plani where plani.etbcod = ctdevven.etbcod-ori
                       and plani.placod = ctdevven.placod-ori
                     no-lock no-error.

    /**
    message string(time,"hh:mm:ss")
        "avail plani origem " avail plani skip
        " ctdevven.etbcod-ori" ctdevven.etbcod-ori skip
        " ctdevven.placod-ori" ctdevven.placod-ori skip
        " ctdevven.serie-ori " ctdevven.serie-ori.
    **/
    if not avail plani
    then return.

    /* #4 Dev.de entrega em outra loja */
    if plani.movtdc = 81
    then do.
        /*
            Busca pedido em outra loja
            Leituras foram testadas em ileb/valida-devol.p
        */
        find ped-cmon where ped-cmon.etbcod = bpdvdoc.orig_loja
                        and ped-cmon.cxacod = bpdvdoc.orig_componente
                   no-lock.
        find first ped-pdvdoc
                        where ped-pdvdoc.etbcod    = bpdvdoc.orig_loja
                          and ped-pdvdoc.cmocod    = ped-cmon.cmocod
                          and ped-pdvdoc.datamov   = bpdvdoc.orig_data
                          and ped-pdvdoc.sequencia = bpdvdoc.orig_nsu
                        no-lock.
        find plani where plani.etbcod = ped-pdvdoc.etbcod
                     and plani.placod = ped-pdvdoc.placod 
                   no-lock.
        if not avail plani
        then next.
    end.

    /* Seguro prestamista - cancelar */
    find vndseguro where vndseguro.tpseguro = 1 /* #2 */
                     and vndseguro.etbcod   = plani.etbcod
                     and vndseguro.placod   = plani.placod
                    no-error.
    if avail vndseguro
    then assign
            vndseguro.dtcanc  = today
            vndseguro.motcanc = 12.

        /*
            Garantia / RFQ. Ex: 781000000000823
        */
        for each pdvitem-garantia of pdvmov no-lock.
            if pdvitem-garantia.tipogarantia = "F"
            then vtpseguro = 6.
            else vtpseguro = 5.

            find pdvmovim where pdvmovim.etbcod   = pdvdoc.etbcod and
                                pdvmovim.cmocod   = pdvdoc.cmocod and
                                pdvmovim.datamov  = pdvdoc.datamov and
                                pdvmovim.sequencia = pdvdoc.sequencia and
                                pdvmovim.ctmcod   = pdvdoc.ctmcod and
                                pdvmovim.coo      = pdvdoc.coo and
                                pdvmovim.seqreg   = pdvdoc.seqreg and
                                pdvmovim.movseq   = pdvitem-garantia.seqproduto
                           no-lock.
            /* Movim tem o indice ERRADO: pegar o movseq que foi gravado e nao
               o do P2K */
            find first tt-movim where tt-movim.procod = pdvmovim.procod no-lock.

            find vndseguro where
                              vndseguro.tpseguro = vtpseguro
                          and vndseguro.etbcod   = pdvitem-garantia.etbcod
                          and vndseguro.certifi  = pdvitem-garantia.certificado
                          no-error.
            if avail vndseguro
            then assign
                    vndseguro.dtcanc  = today
                    vndseguro.motcanc = 12.

                find movim where movim.etbcod = tt-plani.etbcod
                             and movim.placod = tt-plani.placod
                             and movim.procod = pdvitem-garantia.codgarantia
                           no-error.
                if not avail movim
                then do.
                    vmovseq = vmovseq + 1.
                    create movim.
                    assign
                        movim.etbcod = tt-plani.etbcod
                        movim.placod = tt-plani.placod
                        movim.procod = pdvitem-garantia.codgarantia
                        movim.movseq = vmovseq
                        movim.movtdc = tt-plani.movtdc
                        movim.emite  = tt-plani.emite
                        movim.desti  = tt-plani.desti
                        movim.movdat = tt-plani.pladat
                        movim.movhr  = tt-plani.horincl
                        movim.movalicms = 98 /* #2 */
                        movim.movctm = 0.
                end.
                assign
                    movim.movqtm = movim.movqtm + 1
                    movim.vuncom = movim.vuncom + pdvitem-garantia.valorgarantia
                    movim.movctm = movim.movctm + pdvitem-garantia.vlrcusto.
                movim.movpc = movim.vuncom / movim.movqtm. /* vlr.medio */

                create movimseg.
                assign
                    movimseg.etbcod  = movim.etbcod
                    movimseg.placod  = movim.placod
                    movimseg.seg-movseq = movim.movseq
                    movimseg.movseq  = tt-movim.movseq
                    movimseg.movpc   = pdvitem-garantia.valorgarantia
                    movimseg.movctm  = pdvitem-garantia.vlrcusto
                    movimseg.certifi = pdvitem-garantia.certificado
                    movimseg.movdat  = movim.movdat
                    movimseg.tpseguro = vtpseguro
                    movimseg.subtipo = pdvitem-garantia.tipogarantia.
        end.

    if plani.crecod = 1
    then run acerta-titulo (plani.serie + string(plani.numero)).
    else
        /* Crediario - liquidar */
        for each contnf where contnf.etbcod = plani.etbcod
                          and contnf.placod = plani.placod
                        no-lock.
            find contrato of contnf no-lock.
            run acerta-titulo ( string(contrato.contnum) ).
        end.
end.                  

end procedure.


procedure acerta-titulo.

    def input parameter par-titnum like titulo.titnum.

    def var vvlpago as dec. /* #1 */
    def var vvlaber as dec.
    def var vseqreg like pdvdoc.seqreg.
    def var vparam-dev as char.
    def buffer bpdvdoc for pdvdoc.

    vseqreg = pdvdoc.seqreg.

    for each titulo where titulo.empcod = 19
                      and titulo.titnat = no
                      and titulo.modcod = plani.modcod
                      and titulo.etbcod = plani.etbcod
                      and titulo.clifor = plani.desti
                      and titulo.titnum = par-titnum.
        /**
        message string(time,"hh:mm:ss")
            " titulo" 
            " titnum" titulo.titnum
            " titpar" titulo.titpar
            " titsit" titulo.titsit.
        **/
        
        if titulo.titsit = "PAG" or
           titulo.titdtpag <> ?
        then vvlpago = vvlpago + titulo.titvlpag.
        else do.
            vvlaber = titulo.titvlcob.

            vseqreg = vseqreg + 1.
            /* copiado de ip2k/imp-info-pagamento.p */
            create bpdvdoc.
            assign 
                bpdvdoc.etbcod    = pdvmov.etbcod
                bpdvdoc.DataMov   = pdvmov.DataMov
                bpdvdoc.cmocod    = pdvmov.cmocod
                bpdvdoc.COO       = pdvmov.COO
                bpdvdoc.Sequencia = pdvmov.Sequencia
                bpdvdoc.ctmcod    = pdvmov.ctmcod
                bpdvdoc.seqreg    = vseqreg
                bpdvdoc.valor     = vvlaber
                bpdvdoc.clifor    = titulo.clifor
                bpdvdoc.contnum   = string(contrato.contnum)
                bpdvdoc.titdtven  = titulo.titdtven
                bpdvdoc.titpar    = titulo.titpar
                bpdvdoc.titvlcob  = titulo.titvlcob.

            /**message string(time,"hh:mm:ss") "criou bpdvdoc" vvlaber.
            */

            assign
                titulo.titsit   = "PAG"
                titulo.titvlpag = bpdvdoc.valor
                titulo.titdtpag = bpdvdoc.datamov
                titulo.titjuro  = if titulo.titvlpag > titulo.titvlcob
                                  then titulo.titvlpag - titulo.titvlcob
                                  else 0
                titulo.moecod   = "DEV" /*#1 "PDM" */
                /*#1 titulo.etbcobra = bpdvdoc.etbcod */
                /*** RM ***/
                titulo.datexp   = today
                /*#1 titulo.cxmdat   = bpdvdoc.datamov*/
                /*#1 titulo.cxacod   = cmon.cxacod*/.
                    
            /** cria titpag padrao Lebes **/
            create titpag.
            assign
                titpag.empcod = titulo.empcod
                titpag.titnat = titulo.titnat
                titpag.modcod = titulo.modcod
                titpag.etbcod = titulo.etbcod
                titpag.clifor = titulo.clifor
                titpag.titnum = titulo.titnum
                titpag.titpar = titulo.titpar
                titpag.titvlpag = bpdvdoc.valor
                titpag.cxacod   = cmon.cxacod
                titpag.cxmdata  = bpdvdoc.datamov
                titpag.moecod   = titulo.moecod.
            /**
            message string(time,"hh:mm:ss") "acertou titulo e titpag".
            **/
        end.
    end.

    /* #3 Em HML */
    if vvlpago > 0
       and (pdvmov.etbcod = 189 or pdvmov.etbcod = 789)
    then do on error undo.
        /**
        message string(time,"hh:mm:ss") "gera titulo a pagar" vvlpago.
        **/
        
        vparam-dev = "ETBCOD-ORI="  + string(plani.etbcod) +
                     "|PLACOD-ORI=" + string(plani.placod) +
                     "|MOVTDC-ORI=" + string(plani.movtdc) +
                     "|PLADAT-ORI=" + string(plani.pladat) +

                     "|ETBCOD-DEV=" + string(tt-plani.etbcod) +
                     "|PLACOD-DEV=" + string(tt-plani.placod) +
                     "|MOVTDC-DEV=" + string(tt-plani.movtdc) +
                     "|PLADAT-DEV=" + string(tt-plani.pladat).

        create titulo.
        assign
            titulo.empcod    = 19
            titulo.modcod    = "DEV"
            titulo.moecod    = "DEV"
            titulo.cxacod    = cmon.cxacod
            titulo.clifor    = pdvdoc.clifor
            titulo.titnum    = string(tt-plani.numero)
            titulo.titpar    = 1
            titulo.titnat    = yes
            titulo.etbcod    = pdvmov.etbcod
            titulo.titdtemi  = pdvmov.DataMov
            titulo.titdtven  = pdvmov.DataMov
            titulo.titvlcob  = vvlpago
            titulo.cobcod    = 2
            /* titulo.datexp    = today */
            titulo.titobs[1] = vparam-dev
            /*
             Pagamento
            */
            titulo.titsit    = "PAG"
            titulo.titdtpag  = pdvmov.DataMov
            titulo.titobs[2] = "DEVOLUCAO"
            titulo.vencod    = tt-plani.vencod
            titulo.evecod    = 1
            titulo.titvlpag  = vvlpago.
    end.

end procedure.

