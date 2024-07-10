/* medico na tela 042022 - helio DOC24 */
/* HUBSEG 19/10/2021 */

DEFINE INPUT  PARAMETER lcJsonEntrada      AS LONGCHAR.
def    output param     verro as char no-undo.
verro = "".
def var vecommerce as log init no.

def var vtpseguro as int.
def var vpronom as char.

def var vctmcod  like pdvmov.ctmcod.
def var vmodcod     like contrato.modcod.
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

{/admcom/barramento/async/cupomvendaservico_01.i}

/* LE ENTRADA */
lokJSON = hcupomvendaservicoEntrada:READ-JSON("longchar",lcJsonEntrada, "EMPTY").


def var vsaida as char.
find first ttcupomvendaservico.
vsaida = "./json/servico/" + trim(tipoServico) + "_"
                           + trim(ttcupomvendaservico.codigoLoja)  + "_"
                           + trim(dataTransacao) + "_"
                           + trim(numeroComponente) + "_"
                           + trim(nsuTransacao) + "_"
                           + "cupomvendaservico.json".
hcupomvendaservicoEntrada:WRITE-JSON("FILE",vsaida, true).





/*


*/

for each ttcupomvendaservico on error undo, return.
    /*
        field  statusAtivacao as char
        field  horaTransacao as char
        field  numeroTelefone as char
        field  codigoPlanoPos as char
        field  descricaoPlanoPos as char
        field  dataCadastroPos as char
        field  numeroCartaoPresente as char
        field  idOperacaoMotor as char
        field  geolocalizacaoLatitude as char
        field  geolocalizacaoLongitude as char
    */

    vctmcod  = if tipoServico = "REC_TELEFONIA"
               then "P9"
               else if tipoServico = "CRED_PESSOAL_0"
                    then "P44"
                    else if tipoServico = "CRED_PESSOAL_1"
                         then "P47"
                         else if tipoServico = "VEND_GIFT_CARD"
                              then "P8"
                              else if tipoServico = "HUBSEG" 
                                   then "VHS"
                                   else if tipoServico = "DOC24"
                                        then "D24"
                                        else "10".
                                        
    vmodcod = if vctmcod = "P44"
              then "CP0"
              else if vctmcod = "P47" 
                   then "CP1" 
                   else vmodcod.
                   
    vdatamov = aaaa-mm-dd_todate(ttcupomvendaservico.dataTransacao).
    vnsu     = int(ttcupomvendaservico.nsuTransacao).

    find cmon where
            cmon.etbcod = int(ttcupomvendaservico.codigoLoja) and
            cmon.cxacod = int(ttcupomvendaservico.numeroComponente)
            no-lock no-error.
    if not avail cmon 
    then do on error undo: 
        create cmon. 
        assign 
            cmon.cmtcod = "PDV" 
            cmon.etbcod = int(ttcupomvendaservico.codigoLoja)
            cmon.cxacod = int(ttcupomvendaservico.numeroComponente)
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

    pdvmov.valortot   = if dec(valorTotalAPrazo) > 0
                        then dec(valorTotalAPrazo)
                        else dec( valorTotalVenda).
    pdvmov.valortroco = dec(valortroco).

    pdvmov.codigo_operador =  codigoOperador.
        
    pdvmov.HoraMov    = hora_totime(horaTransacao).
    pdvmov.EntSai     = yes.
    pdvmov.statusoper = "".
/*    pdvmov.tipo_pedido = int(ora-coluna("tipo_pedido")).  */

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
    if vctmcod = "VHS" or vctmcod= "D24"
    then do:
        message vctmcod tipoServico ttcupomvendaservico.idAdesao.
        pdvdoc.idAdesaoHubSeg = ttcupomvendaservico.idAdesao.
        
    end.
    pdvdoc.valor_encargo = dec(valorEncargos). 
    pdvdoc.valor        = pdvmov.valortot.

    if pdvdoc.tipo_venda = 0
    then pdvdoc.tipo_venda = 7.

    find first ttcliente where ttcliente.idpai = ttcupomvendaservico.id no-error.
    if avail ttcliente
    then do:
        /*
        field tipoCliente as char 
        field codigoCliente as char 
        field cpfCnpj as char 
        field nome as char 
        */
        pdvdoc.clifor         = dec(ttcliente.codigoCliente) no-error.

        if vctmcod = "D24"
        then do:
            find medadesao where medadesao.idadesao = int(ttcupomvendaservico.idAdesao) 
                    exclusive no-wait no-error.
            if avail medadesao
            then do:
                medadesao.clicod = pdvdoc.clifor.
            end.        
        
        end.
                
        /*delete ttcliente.*/
        
    end.        
    /* Lebes pega consumidor final */
    if pdvdoc.clifor = ? or pdvdoc.clifor = 0
    then pdvdoc.clifor = 1.

    vvencod = int(codigoVendedor) no-error.
    if vvencod = ?
    then vvencod = 150.

    if pdvmov.ctmcod = "P9"
    then do on error undo.
        find pdvmovim where pdvmovim.etbcod    = pdvdoc.etbcod and
                            pdvmovim.cmocod    = pdvdoc.cmocod and
                            pdvmovim.datamov   = pdvdoc.datamov and
                            pdvmovim.sequencia = pdvdoc.sequencia and
                            pdvmovim.ctmcod    = pdvdoc.ctmcod and
                            pdvmovim.coo       = pdvdoc.coo and
                            pdvmovim.seqreg    = pdvdoc.seqreg and
                            pdvmovim.movseq    = 1
                      no-lock no-error.
        if not avail pdvmovim
        then do.
            vpronom = "RECARGA " + ttcupomvendaservico.operadora + " VIRTUAL " +
                      ttcupomvendaservico.valorTotalVenda.
            find first produ where produ.pronom = vpronom
                               and produ.proseq < 98
                             no-lock no-error.
            if not avail produ
            then do.
                vpronom = "RECARGA " + ttcupomvendaservico.operadora + " VIRTUAL ".
                find first produ where produ.pronom begins vpronom
                                   and produ.proseq < 98
                                 no-lock no-error.
            end.
            create pdvmovim.
            assign
                pdvmovim.etbcod    = pdvdoc.etbcod
                pdvmovim.cmocod    = pdvdoc.cmocod
                pdvmovim.datamov   = pdvdoc.datamov
                pdvmovim.sequencia = pdvdoc.sequencia
                pdvmovim.ctmcod    = pdvdoc.ctmcod
                pdvmovim.coo       = pdvdoc.coo
                pdvmovim.seqreg    = pdvdoc.seqreg
                pdvmovim.movseq    = 1
                pdvmovim.procod    = if avail produ
                                     then  produ.procod
                                     else 0
                pdvmovim.movqtm    = 1
                pdvmovim.movpc     = dec(ttcupomvendaservico.valorTotalVenda).
        end.
    end.

    do on error undo. 
        vmovseq = vmovseq + 1. 
        create tt-movim.
                tt-movim.movseq = vmovseq.
                tt-movim.procod = int(codigoServico).
                tt-movim.movqtm = 1.
                tt-movim.movpc  = dec(valorTotalVenda).
   end.
    
    /* CRIA PLANI */

    
    find plani where plani.etbcod = pdvdoc.etbcod and
                     plani.placod = pdvdoc.placod 
               NO-LOCK no-error.
    if not avail plani or
       pdvdoc.placod = 0 or
       pdvdoc.placod = ?
    then do:
        run bas/grplanum.p (pdvmov.etbcod, "", output vplacod, output par-num).

        par-ser = string(cmon.cxacod,"999") +  
                  string(pdvmov.datamov,"999999").
        par-num = pdvmov.sequencia.
    end.
    
    do on error undo.  
        create plani. 
        assign 
            plani.placod   = vplacod 
            plani.etbcod   = pdvdoc.etbcod 
            plani.numero   = par-num  
            plani.cxacod   = cmon.cxacod 
            plani.emite    = pdvdoc.etbcod 
            plani.serie    = par-ser 
            plani.movtdc   = vmovtdc  
            plani.desti    = int(pdvdoc.clifor) 
            plani.pladat   = pdvmov.datamov 
            plani.dtinclu  = plani.pladat 
            plani.horincl  = pdvmov.horamov  
            plani.notsit   = no 
            plani.datexp   = today 

            plani.vlserv   = dec(valorTotalVenda)
            plani.acfprod  = pdvdoc.valor_encargo 
            plani.platot   = dec(valorTotalVenda)
            plani.biss     = dec(valorTotalAPrazo).
            plani.vencod  =  vvencod. 
            /* 
            plani.hiccod = vcfop. 
            */  

            if false /*vpedidoutloj*/
            then .
            else if pdvdoc.numero_nfe = 0 /* Cupom fiscal */
            then assign
                    plani.notped = "C|" + string(pdvmov.coo) + "|" + 
                              string(cmon.cxacod) + "|" 
                              /** + vnser**/
                    /*** plani.ufemi numero de serie ***/.
            else assign /* NFCE ***/
                    plani.notped = "C"
                    plani.ufdes  = pdvdoc.chave_nfe.

            assign
                pdvdoc.placod = plani.placod.

        pdvdoc.pstatus = yes. /* FECHADO */ 
        find first ttdepositoCP no-error. 
        if avail ttdepositoCP 
        then do: 
            create contCP. 
            contCP.etbcod = plani.etbcod. 
            contCP.placod = plani.placod. 
            contCP.contnum = ?. 
            contcp.banco   = ttdepositoCP.banco. 
            contCP.agencia = ttdepositoCP.agencia. 
            contCP.tipoConta = ttdepositoCP.tipoConta. 
            contCP.numeroConta = ttdepositoCP.numeroConta.
            
            find first ttcliente no-error.
            if avail ttcliente
            then do:
                contcp.clicod    = int(ttcliente.codigoCliente).
                contcp.cpfdesti  = dec(ttcliente.cpfCnpj).
                contcp.nomedesti = ttcliente.nome.
            end.
            
        end.
        
    end.   
    for each tt-movim.  
        create movim.
        assign 
            movim.movtdc = plani.movtdc 
            movim.etbcod = plani.etbcod 
            movim.placod = plani.placod 
            movim.emite  = plani.emite 
            movim.desti  = plani.desti 
            movim.movdat = plani.pladat 
            movim.movhr  = plani.horincl 
            movim.movseq = tt-movim.movseq 
            movim.procod = tt-movim.procod 
            movim.movpc  = tt-movim.movpc 
            movim.movqtm = tt-movim.movqtm 
            movim.movdes = tt-movim.movdes 
            movim.movacfin  = tt-movim.movacfin 
            movim.movicms   = tt-movim.movicms 
            movim.movalicms = tt-movim.movalicms.   
            movim.desc-cam  = tt-movim.desc-cam.  
            movim.desc-crm  = tt-movim.desc-crm. 
            movim.nrobonus-crm = tt-movim.nrobonus-crm. 
            movim.desc-man  = tt-movim.desc-man. 
            movim.desc-tot  = tt-movim.desc-tot.  
    end.  
    
    /* RECEBIMENTOS */
    
    {/admcom/barramento/async/recebimentos.i ttcupomvendaservico.id}
     
    do on error undo:
        if avail plani
        then do:
            if plani.seguro > 0 or val_tfc > 0
            then do:
                find first movim where
                    movim.etbcod = plani.etbcod and
                    movim.placod = plani.placod and 
                    movim.procod = int(codigoServico)
                    no-error.
                if avail movim
                then do on error undo:
                    find current plani.
                    movim.movpc = movim.movpc - plani.seguro.
                    movim.movpc = movim.movpc + val_tfc.
                    plani.platot = plani.platot + val_tfc.
                end.
                find current plani no-lock.
            end.
        end.
    end.
             
                 
end.    



  

