
DEFINE INPUT  PARAMETER lcJsonEntrada      AS LONGCHAR.
def    output param     verro as char no-undo.
verro = "".
def var vcupomb2b as int.
def var par-clicod like clien.clicod.
def var vecommerce as log.
def buffer ocmon for cmon.
def buffer opdvmov for pdvmov.
def buffer opdvdoc for pdvdoc.
def buffer oplani for plani.
def var vcontnum  as int.
def var vtpseguro  as int.

def var vctmcod  like pdvmov.ctmcod.
def var vmodcod  like contrato.modcod initial "".

def var vdatamov as date. /* 01.12.2017 */
def var vnsu     as int.

def var vseq    as int.
def var vprocod like pdvmovim.procod.
def var vmovdes like pdvmovim.movdes. /* #1 */
def var vmovpc  like pdvmovim.movpc.  /* #1 */
def var vmovqtm like pdvmovim.movqtm. /* #1 */
def var vcodigo_forma  as char. 
def var vtitpar as int.
def var vi as int.
def var vmes as int.
def var vano as int.
def var vdia as int.
def var vvenc as date.
def var vseqforma as int.
def var vseqfp as int.
def var vtitvlcob as dec.
def var vultima as dec.
def var vtotal as dec.
def var vtotalsemjuros as dec.
def var vtitvlcobsemjuros as dec.
def var par-ser as char.

def var par-num  as int.
def var vplacod  like plani.placod.
def var vmovtdc  as int init 5. 
def var vvencod  as int.
def var vmovseq  as int.
def var vvalor_vista as dec.
def var vvalor_contrato as dec.

def temp-table tt-movim no-undo like pdvmovim
    field movdes-combo as dec
    field desc-cam      like movim.desc-cam
    field desc-crm      like movim.desc-crm
    field nrobonus-crm like movim.nrobonus-crm /**/
    field desc-man      like movim.desc-man
    field desc-total      like movim.desc-total.

{/admcom/barramento/functions.i}
{/admcom/barramento/async/cupomvendageavulsa_01.i}
/* LE ENTRADA */
lokJSON = hcupomvendageavulsaEntrada:READ-JSON("longchar",lcJsonEntrada, "EMPTY").

def var vsaida as char.
find first ttcupomvendageavulsa no-error.  
      
message avail ttcupomvendageavulsa.      
if not avail ttcupomvendageavulsa then leave. 

vsaida = "./json/" +  "cupomvendageavulsa.json".
hcupomvendageavulsaEntrada:WRITE-JSON("FILE",vsaida, true).


find first ttcupomvendageavulsa no-error.  
/* dpge/fassinatura 03072024 */
def var vversaoComponente as char.
def var vnomeComponente as char.
if avail ttcupomvendageavulsa
then do:
    vversaoComponente = ttcupomvendageavulsa.versaoComponente.
    vnomeComponente   = ttcupomvendageavulsa.nomeComponente.
    message vversaoComponente vnomeComponente.
end.
if vversaoComponente = ? then vversaoComponente = "".
if vnomeComponente   = ? then vnomeComponente = "".

vctmcod = "GEA".
def var tiposervico as char.

    /* 26/04/2021 - orc - cria cadastro cliente - para ecommerce */

    find first ttcliente where ttcliente.idpai = ttcupomvendageavulsa.id no-error.
    if avail ttcliente
    then do:
        if int(ttcupomvendageavulsa.codigoLoja) = 200 /** ecommerce */
        then do:
            release clien.
            if dec(ttcliente.codigoCliente) <> ? and 
               dec(ttcliente.codigoCliente) <> 0
            then do: 
                find clien where clien.clicod = int64(ttcliente.codigoCliente) no-lock no-error.
            end.     
            if not avail clien 
            then do: 
                find neuclien where neuclien.cpf = dec(ttcliente.cpf) no-lock no-error. 
                if avail neuclien 
                then do: 
                    find clien where clien.clicod = neuclien.clicod no-lock no-error. 
                    if avail clien 
                    then ttcliente.codigoCliente = string(clien.clicod). 
                end.
                else do:
                    find clien where clien.ciccgc = ttcliente.cpf no-lock no-error.
                    if avail clien 
                    then ttcliente.codigoCliente = string(clien.clicod).
                end.
            end.
            
            if not avail clien
            then do:
                run /admcom/progr/p-geraclicod.p (output par-clicod). 
                ttcliente.codigoCliente = string(par-clicod).
                do on error undo. 
                
                    create clien. 
                    assign 
                        clien.clicod = int(ttcliente.codigoCliente) .
                        clien.ciccgc = string(ttcliente.cpf).
                        clien.clinom = string(ttcliente.nome).
                        clien.tippes = ttcliente.tipoCliente = "F".
                        clien.etbcad = int(ttcupomvendageavulsa.codigoLoja). 

                    create neuclien. 
                    neuclien.cpfcnpj = dec(clien.ciccgc).
                    neuclien.tippes  = clien.tippes.
                    neuclien.etbcod  = clien.etbcad.
                    neuclien.dtcad   = today.
                    neuclien.nome_pessoa = clien.clinom.
                    neuclien.clicod = clien.clicod.
                        
                        
                    create cpclien. 
                    assign  
                    cpclien.clicod     = clien.clicod
                    cpclien.var-char11 = ""
                    cpclien.datexp     = today.
                    
                    for each ttendereco where ttendereco.idpai = ttcliente.id.
                        clien.endereco[1]   = caps(ttendereco.rua).
                        clien.numero[1]     = int(ttendereco.numero) no-error.
                        clien.compl[1]      = caps(ttendereco.complemento).
                        clien.bairro[1]     = caps(ttendereco.bairro).
                        clien.cidade[1]     = caps(ttendereco.cidade).
                        clien.ufecod[1]     = caps(ttendereco.uf).
                        clien.cep[1]        = (ttendereco.cep).
                    end.     
                    find first ttcontato no-error.
                    if avail ttcontato
                    then clien.zona = ttcontato.email. 
                    
                    find first tttelefones where tttelefones.tipo = "CELULAR" no-error. 
                    if avail tttelefones
                    then clien.fax = tttelefones.numero.
                    find first tttelefones where tttelefones.tipo <> "CELULAR" no-error. 
                    if avail tttelefones
                    then clien.fone = tttelefones.numero.
                end.
            end.      
        end.
    end.    


for each ttcupomvendageavulsa.

    vdatamov = aaaa-mm-dd_todate(ttcupomvendageavulsa.dataTransacao).
    vnsu     = int(ttcupomvendageavulsa.nsuTransacao).

    find cmon where
            cmon.etbcod = int(ttcupomvendageavulsa.codigoLoja) and
            cmon.cxacod = int(ttcupomvendageavulsa.numeroComponente)
            no-lock no-error.

    if not avail cmon 
    then do on error undo: 
        create cmon. 
        assign 
            cmon.cmtcod = "PDV" 
            cmon.etbcod = int(ttcupomvendageavulsa.codigoLoja)
            cmon.cxacod = int(ttcupomvendageavulsa.numeroComponente)
            cmon.cmocod = int(string(cmon.etbcod) + string(cmon.cxacod,"999")) 
            cmon.cxanom = "Lj " + string(cmon.etbcod) + " " + 
                          "Cx " + string(cmon.cxacod). 
    end.
                                          
                                          
    find first pdvmov where
        pdvmov.etbcod = cmon.etbcod and
        pdvmov.cmocod = cmon.cmocod and
        pdvmov.datamov = vdatamov and
        pdvmov.sequencia = vnsu and
        pdvmov.ctmcod = vctmcod and
        pdvmov.coo    = if int(numeroCupom) = 0 or int(numeroCupom) = ?
                        then vnsu
                        else int(numeroCupom)
        no-error.
    if not avail pdvmov
    then do:            
        create pdvmov.
        pdvmov.etbcod = cmon.etbcod.
        pdvmov.cmocod = cmon.cmocod.
        pdvmov.datamov = vdatamov.
        pdvmov.sequencia = vnsu.
        pdvmov.ctmcod = vctmcod.
        pdvmov.coo    = if int(numeroCupom) = 0 or int(numeroCupom) = ? 
                        then vnsu
                        else int(numeroCupom).
    end.        
    else do:
        find first pdvdoc of pdvmov no-lock no-error.
        if avail pdvdoc
        then do: 
            message pdvmov.etbcod cmon.cxacod pdvmov.datamov "NSU" pdvmov.sequencia "NumeroCupom" pdvmov.coo pdvmov.ctmcod.
            verro = "JA INCLUIDO".
            return.
        end.
    end.    
    vecommerce = no.
    if pdvmov.etbcod = 200 or ttcupomvendageavulsa.canalOrigem = "SITE"
    then do:
        vecommerce = yes.
    end.    
    message pdvmov.etbcod cmon.cxacod pdvmov.datamov "NSU" pdvmov.sequencia "numeroCupom" pdvmov.coo pdvmov.ctmcod ttcupomvendageavulsa.canalOrigem.

    pdvmov.valortot   = if dec(valorTotalAPrazo) = 0
                        then dec(valorTotalVenda)
                        else dec(valorTotalAPrazo).
    pdvmov.valortroco = dec(ttcupomvendageavulsa.valortroco).

    pdvmov.codigo_operador = /*ITEM?*/ ?.
        
    pdvmov.HoraMov    = hora_totime(horaTransacao).
    pdvmov.EntSai     = if vctmcod = "10"
                        then yes
                        else no.
    pdvmov.statusoper = tstatus.
/*    pdvmov.tipo_pedido = int(ora-coluna("tipo_pedido")).  */

    if tstatus <> "200"
    then return.
    
    find first pdvdoc of pdvmov where pdvdoc.seqreg = 1 no-error.
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
            pdvdoc.seqreg    = 1
            /*pdvdoc.titcod    = ?*/ .
    end.    
    pdvdoc.valor        = pdvmov.valortot.
    pdvdoc.tipo_venda   = if vctmcod = "10"
                          then 9
                          else if vctmcod = "108"
                               then 5
                               else 6. /* Padrao venda int(ora-coluna("tipo_venda")). */
                               
    pdvdoc.numero_pedido = int(ttcupomvendageavulsa.numeroPedido). 
    vnumeroPedido        = ttcupomvendageavulsa.numeroPedido. 

    if pdvdoc.tipo_venda = 7 /* 7.Cancelamento de cupom fiscal no recebimento*/
    then assign
            pdvmov.EntSai     = ?
            pdvmov.statusoper = "CAN".
    else if pdvdoc.tipo_venda = 4
    then assign
            pdvmov.EntSai     = ?
            pdvmov.statusoper = "ANU".   
    else if pdvdoc.tipo_venda = 5 or
            pdvdoc.tipo_venda = 13
    then assign     
            pdvmov.EntSai     = no
            pdvmov.statusoper = "DEV".   
    else if pdvdoc.tipo_venda = 6
    then assign
            pdvmov.EntSai     = no
            pdvmov.statusoper = "TRO".   
    
     
    find first ttcliente where ttcliente.idpai = ttcupomvendageavulsa.id no-error.
    if avail ttcliente
    then do:
        /*
        field tipoCliente as char 
        field codigoCliente as char 
        field cpfCnpj as char 
        field nome as char 
        */
        pdvdoc.clifor         = dec(ttcliente.codigoCliente) no-error.
    
    end.        
    /* Lebes pega consumidor final */
    if pdvdoc.clifor = ? or pdvdoc.clifor = 0
    then pdvdoc.clifor = 1.

    /*
    pdvdoc.tipo_desc_sub   = ora-coluna("tipo_desconto_sub_total").
    pdvdoc.valor_desc_sub  = dec(ora-coluna("valor_desconto_sub_total")).
    */

    /* CRIA PLANI */

    find plani where plani.etbcod = pdvdoc.etbcod and
                     plani.placod = pdvdoc.placod 
               NO-LOCK no-error.
    if not avail plani or
       pdvdoc.placod = 0 or
       pdvdoc.placod = ?
    then do:
        run bas/grplanum.p (pdvmov.etbcod, "", output vplacod, output par-num).

        
        if false
        then /*** PEDIDO OUTRA LOJA ***/
            assign
                par-ser = "PEDO"
                par-num = pdvdoc.numero_pedido.
        else 
        if pdvdoc.numero_nfe = 0
        then               
            assign
                par-ser = string(cmon.cxacod)
                par-num = pdvmov.coo.
        else /*** NFCE ***/
            assign
                par-ser = pdvdoc.serie_nfe
                par-num = pdvdoc.numero_nfe.
    end.
    
    do on error undo.  
    
        create plani. 
        assign 
            plani.placod   = vplacod 
            plani.etbcod   = pdvdoc.etbcod 
            plani.numero   = par-num
            plani.cxacod   = cmon.cxacod 
            plani.emite    = pdvdoc.etbcod 
            plani.vlserv   = 0 /*vdevval */ 
            plani.serie    = par-ser 
            plani.movtdc   = vmovtdc  
            plani.desti    = int(pdvdoc.clifor)  
            plani.dtinclu  = plani.pladat 
            plani.pladat   = pdvmov.datamov 
            plani.horincl  = pdvmov.horamov  
            plani.notsit   = no 
            plani.datexp   = today 
                                                                  
            plani.vlserv   = dec(valorTotalVenda)
            plani.protot   = 0 /*dec(valorMercadorias) */
            plani.acfprod  = dec(valorEncargos)
            plani.descprod = 0 /*dec(descontos) */
            plani.platot   = dec(valorTotalVenda)
                             
            plani.biss     = dec(valorTotalAPrazo).
            plani.vencod  =  vvencod. 
            
            assign
                pdvdoc.placod = plani.placod.


        pdvdoc.pstatus = yes. /* FECHADO */

    end.   

        
        for each ttgarantias.
            
            if ttgarantias.tipo = "R" or
               ttgarantias.tipo = "Y"
            then vtpseguro = 5.
            else if ttgarantias.tipo = "F"
            then vtpseguro = 6.

/*            find first tt-movim where tt-movim.procod = int(ttgarantias.codigo) no-lock. */

            find vndseguro where
                              vndseguro.tpseguro = vtpseguro
                          and vndseguro.etbcod   = pdvmov.etbcod
                          and vndseguro.certifi  = ttgarantias.certificado
                          no-lock no-error.
            if not avail vndseguro
            then do.
                /** deveria vir do barramento 
                plani.seguro = plani.seguro + ttgarantias.valorgarantia.
                **/

                create vndseguro.
                assign
                    vndseguro.tpseguro = vtpseguro.
                    vndseguro.certifi  = ttgarantias.certificado.
                    vndseguro.etbcod   = pdvmov.etbcod.
                    vndseguro.placod   = plani.placod.
                    vndseguro.prseguro = dec(ttgarantias.valor).
                    vndseguro.pladat   = plani.pladat.
                    vndseguro.dtincl   = plani.pladat.
/*                    vndseguro.movseq   = tt-movim.movseq. */
                    vndseguro.procod   = int(ttgarantias.origemCodigoProduto).
                    vndseguro.clicod   = plani.desti.
                    vndseguro.dtivig   = aaaa-mm-dd_todate(ttgarantias.dataInicioGarantia).
                    vndseguro.dtfvig   = aaaa-mm-dd_todate(ttgarantias.dataFimGarantia).
                    
                    vndseguro.vencod   = plani.vencod.
                    vndseguro.datexp   = ?. /* nao replicar */
                    vndseguro.tempo    = int(ttgarantias.tempoGarantia).
                    vndseguro.exportado = yes.            
            
            end.

            find first movim where movim.etbcod = plani.etbcod
                               and movim.placod = plani.placod
                               and movim.procod = int(ttgarantias.codigo)
                           no-error.
            if not avail movim 
            then do:
                vmovseq = vmovseq + 1.  
                create movim. 
                assign
                        movim.etbcod = plani.etbcod
                        movim.placod = plani.placod
                        movim.procod = int(ttgarantias.codigo)
                        movim.movseq = vmovseq
                        movim.movtdc = plani.movtdc
                        movim.emite  = plani.emite
                        movim.desti  = plani.desti
                        movim.movdat = plani.pladat
                        movim.movhr  = plani.horincl
                        movim.movalicms = 98 /* #3 */
                        movim.vuncom = 0
                        movim.movctm = 0.
            end. 
            assign
                    movim.movqtm = movim.movqtm + 1.
                    movim.vuncom = movim.vuncom + dec(ttgarantias.valor).
                    movim.movctm = movim.movctm + dec(ttgarantias.custoGarantia).
            movim.movpc = movim.vuncom / movim.movqtm. /* vlr.medio */

           /*     
            find first movimseg where movimseg.etbcod = movim.etbcod and
                movimseg.placod  = movim.placod and
                movimseg.seg-movseq = movim.movseq  and
                        movimseg.movseq  = tt-movim.movseq 
                no-lock no-error.
            if not avail movimseg then do:        
                create movimseg.
                assign 
                    movimseg.etbcod  = movim.etbcod 
                    movimseg.placod  = movim.placod 
                    movimseg.seg-movseq = movim.movseq 
                    movimseg.movseq  = tt-movim.movseq 
                    movimseg.movpc   = dec(ttgarantias.valor)

                    movimseg.movctm  = dec(ttgarantias.custoGarantia)
                    movimseg.certifi = ttgarantias.certificado 
                    movimseg.movdat  = movim.movdat 
                    movimseg.tpseguro = vtpseguro 
                    movimseg.subtipo = ttgarantias.tipo 
                    movimseg.tempo   = int(ttgarantias.tempo).
            end.
            */
        end.        
    
    /* RECEBIMENTOS */
    
              {/admcom/barramento/async/recebimentos.i ttcupomvendageavulsa.id}
    
end.    


  

procedure acerta-titulo.

    def input parameter par-contnum like titulo.contnum.

    def var vvlpago as dec. /* #1 */
    def var vvlaber as dec.
    def var vseqreg like pdvdoc.seqreg.
    def var vparam-dev as char.
    def buffer bpdvdoc for pdvdoc.

    vseqreg = 1.
    find contrato where contrato.contnum = par-contnum no-lock.
    
    for each titulo where titulo.contnum = contrato.contnum
                      no-lock.
        message string(time,"hh:mm:ss")
            " titulo" 
            " titnum" titulo.titnum
            " titpar" titulo.titpar
            " titsit" titulo.titsit.

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
                bpdvdoc.contnum   = string(titulo.contnum)
                bpdvdoc.titdtven  = titulo.titdtven
                bpdvdoc.titpar    = titulo.titpar
                bpdvdoc.titvlcob  = titulo.titvlcob.

            message "DEVOLUCAO" bpdvdoc.contnum bpdvdoc.titpar string(time,"hh:mm:ss") "criou bpdvdoc" vvlaber.

            run /admcom/progr/fin/baixatitulo.p (recid(bpdvdoc),recid(titulo)) no-error.
            if error-status:error
            then do:
                MESSAGE ERROR-STATUS:ERROR RETURN-VALUE. 
                undo, return.
            end.    
            
            
            run p.

            message "DEVOLUCAO" bpdvdoc.contnum bpdvdoc.titpar string(time,"hh:mm:ss") "baixou".
            
        end.
    end.

end procedure.

procedure p.

            do on error undo:
                find current titulo
                    exclusive no-wait no-error.
                if avail titulo
                then do:    
                    titulo.moecod   = "DEV". /*#1 "PDM" */
                    titulo.datexp   = today.
                end.
            end.                    


end procedure.
