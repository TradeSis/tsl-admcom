{admcab.i}


def var vsep as char.
vsep = ";".
def temp-table tt-imp
    field etbcod as int
    field numero as int
        index idx01 etbcod numero .

def var nat-receita as char.

def var frete-item as dec.
def var vmovseq like movim.movseq.
def var icms_item like movim.movicms.
def var vobs like plani.notobs.
def var itvaloroutroicm like plani.platot.
def var vimporta-lista   as log format "Sim/Nao".
def var vlinha           as char.
def var varq-lista       as char.

def var vcodfis as char.
def var vsittri as int.
def var ind-complementar as char.
def var ind-tiponota as char.
def var obs-complementar as char.
def var cod-observacao as char.
def var cod-obsfiscal  as char.
def var tot-basesubst  as dec.
def var ind-movestoque as char.
def var chave-nfe as char.
def var v-mod     as char.

def var conta-pis as char.
def var conta-cofins as char.
def var cst-piscofins as char.
def var cst-icms as char.
def var ipi_base  like plani.platot.
def var ipi_capa  like plani.platot.
def var ipi_item  like plani.platot.
def var vmovbicms like plani.platot.
def var vpladat like plani.pladat.
def var vcod as char format "x(18)".
def var vemite like plani.emite.
def var vdesti like plani.desti.
def var vdti like plani.pladat.
def var vdtf like plani.pladat.
def var vetbcod like estab.etbcod.
def var vopccod as char.
def var vali    as int.
def var varq    as char. 
def var val_contabil like plani.platot.
def var visenta like plani.platot.
def var voutras like plani.platot.
def buffer bmovim for movim.
def buffer bmovcon for movcon.
def buffer ba01_infnfe for a01_infnfe.
def var vetb as char. 

def var vplani_etbcod      like plani.etbcod.    
def var vplani_placod      like plani.placod.
def var vplani_movtdc      as integer format ">>>>>>>>>9". 
def var vmovim_procod      like movim.procod.
def var vmovim_pronom      like produ.pronom.
def var vprodu_codfis      like produ.codfis.
def var vplani_serie       like plani.serie.
def var vplani_numero      like plani.numero.
def var vplani_platot      like plani.platot.
def var vplani_descprod    like plani.descprod.
def var vplani_protot      like plani.protot.
def var vplani_icms        like plani.icms.
def var vplani_icmssubst   like plani.icmssubst.
def var vplani_frete       like plani.frete.
def var vplani_seguro      like plani.seguro.
def var vplani_vlserv      like plani.vlserv.
def var vplani_bicms       like plani.bicms.
def var vplani_ipi          like plani.ipi.
def var vmovim_BSubst       like plani.BSubst.
def var vmovim_ICMSSubst    like plani.ICMSSubst.
def var vmovim_movalicms    like movim.movalicms.
def var vmovim_movqtm       like movim.movqtm.
def var vmovim_movpc        like movim.movpc.
def var vmovim_movdes       like movim.movdes.
def var vmovim_movcstpiscof like movim.movcstpiscof.
def var vmovim_movcsticms   like movim.movcsticms.

def var vmovpc  as dec decimals 4 format ">>,>>>,>>9.9999".
def var vmovqtm as dec decimals 4 format ">>>,>>9.9999".
def var vmovdes as dec decimals 4 format ">>>,>>9.9999".

def var aux-uf     as char init "". 
def var val-pis    as dec.
def var val-cofins as dec.
def var per-pis    as dec.
def var per-cofins as dec.
def var base-pis   as dec.

def var valpis-capa as dec.
def var basepis-capa as dec.
def var valcofins-capa as dec.
def var sparam as char.

def var aliquota_pis as dec.
def var aliquota_cofins as dec.
def var data_contingencia as char.
def var hora_contingencia as char.
def var motivo_contingencia as char.
def var ccc_fiscal as char.
def var st_ipi as char.
def var icms_naodebitado as dec.
def var vforcod like forne.forcod.
def var vufecod like forne.ufecod. 

sparam = SESSION:PARAMETER.
if num-entries(sparam,";") > 1
then sparam = entry(2,sparam,";").

def var vnumero-aux  as int.
def var vchave-aux     as char.

def var vdir as char.
def var vnom as char.
def var varquivo as char format "x(65)".
vdir = "/admcom/relat/" .
                                         
repeat:
    do on error undo:                                         
        update vetbcod with frame f1.
        if vetbcod = 0
        then do:
            display "GERAL" @ estab.etbnom with frame f1.
        end.    
        else do:
            find estab where estab.etbcod = vetbcod no-lock.
            display estab.etbnom no-label with frame f1.
        end.

        update vdti label "Data Inicial" colon 16 
               vdtf label "Data Final" with frame f1 side-label width 80.

    end.
    
    for each tt-imp:
        display tt-imp.
    end.
    
    if vetbcod = 0
    then vetb = "".
    else vetb = string(vetbcod,"999").

    vnom = "saidas_MTP_" + trim(string(vetb,"x(3)")) + "_" +
                string(day(vdti),"99") +  
                string(month(vdti),"99") +  
                string(year(vdti),"9999") + "_" + 
                string(day(vdtf),"99") +  
                string(month(vdtf),"99") +  
                string(year(vdtf),"9999") + ".csv".
                 
    varquivo = vdir + vnom.                                                         update varquivo label "Arquivo"
        with frame f2 1 down side-label width 80.
      
    output to value(varquivo).
    
        put "Filial;Numero;Data;CFOP;Produto;Descrição;NCM;Val.Unit;Quant. ;Total;B.Calculo;AliqICMS;val.ICMS;B.Reduzida;ST;MVA.Interna;MVA.InerEstadual;Aliq.PIS;Aliq.COFINS;BaseIPI;Aliq.IPI;Val.IPI" skip.

    for each tipmov where tipmov.tipemite or
                          tipmov.movtdc = 27
                    no-lock:        

        for each estab no-lock:
         
            if vetbcod > 0
            then do:            
                if vetbcod = 993
                    and estab.etbcod <> 993
                    and estab.etbcod <> 998
                then next.
                    
                if vetbcod = 995
                    and estab.etbcod <> 995
                    and estab.etbcod <> 991
                then next.
                
                if vetbcod <> 993
                    and vetbcod <> 995
                    and vetbcod <> estab.etbcod
                then next.    
            
            end.            
                        
            /****************
            INICIO DO BLOCO DE EXPORTAÇÃO DE NOTAS AUTORIZADAS E CANCELADAS
            *****************/
            
            for each plani where plani.etbcod = estab.etbcod  and
                                 plani.movtdc = tipmov.movtdc and
                                 plani.pladat >= vdti         and
                                 plani.pladat <= vdtf no-lock:
               
                /**** Tipo 27 emite NF de Saidas e Entradas, *****
                 **** portanto descarta entradas             *****/
                
                if plani.movtdc = 27 and plani.opccod < 5000 /*= 1603*/
                then next.
                if plani.movtdc = 5 and plani.serie <> "1"
                then next.
                
                /*Ressarcimento ICMS coloca ICMS Substituicao da Capa no item*/
                if plani.movtdc = 26 or
                   plani.movtdc = 27 or
                   plani.movtdc = 67                   
                then
                    assign vmovim_BSubst    = plani.bsubst
                           vmovim_ICMSSubst = plani.ICMSSubst
                           tot-basesubst    = plani.bsubst.
                else
                    assign vmovim_BSubst    = 0
                           vmovim_ICMSSubst = 0.
                
                ipi_base = 0.
                ipi_item = 0.
                ipi_capa = 0.
                
                find A01_InfNFe where
                     A01_InfNFe.etbcod = plani.etbcod and
                     A01_InfNFe.placod = plani.placod
                              no-lock no-error.
                if avail A01_InfNFe
                then find W01_total of A01_infnfe no-lock no-error.

                assign
                    vplani_etbcod    = plani.etbcod    
                    vplani_placod    = plani.placod
                    vplani_movtdc    = plani.movtdc 
                    vplani_serie     = plani.serie
                    vplani_numero    = plani.numero
                    vplani_vlserv    = plani.vlserv
                    vplani_ipi       = plani.ipi.

                assign
                    vplani_platot    = plani.platot
                    vplani_descprod  = plani.descprod
                    vplani_protot    = plani.protot
                    vplani_icms      = plani.icms
                    vplani_icmssubst = plani.icmssubst
                    vplani_frete     = plani.frete
                    vplani_seguro    = plani.seguro
                    vplani_bicms     = plani.bicms.
 
                if plani.movtdc = 27
                then
                    assign vmovim_ICMSSubst = plani.icmssubst.
                
                if plani.serie <> "1"
                then do:
                    if (plani.emite = 22 and
                       plani.serie = "55")
                       or plani.emite = 200
                    then.
                    else next.
                end.
                
                if plani.serie = "U" or
                   plani.serie = "U1" or
                   plani.serie = "55" or
                   plani.serie = "1"
                then. 
                else next.

                if (plani.movtdc = 6 or plani.movtdc = 16) and 
                    month(vdti) = 12 and
                    plani.emite = 998 and
                    plani.emite = 991
                then do:    
                    find fiscal where fiscal.emite  = plani.emite  and
                              fiscal.desti  = plani.desti  and
                              fiscal.movtdc = plani.movtdc  and
                              fiscal.numero = plani.numero  and
                              fiscal.serie  = plani.serie no-error.
                    if not avail fiscal then next.
                end.

                if plani.emite = 993 /*95*/ and
                   plani.desti = 998 
                then next.

                if plani.emite = 995 and
                   plani.desti = 991
                then next.   

                if plani.emite = 998 and
                   plani.desti = 993 /*95*/
                then next.

                if plani.emite = 991 and
                   plani.desti = 995
                then next.   
                
                vpladat = plani.pladat.
                if plani.movtdc = 13 and
                   plani.pladat >= 01/01/2005 and
                   plani.pladat <= 05/31/2005
                then vpladat = date(07,
                                    day(plani.pladat),
                                    year(plani.pladat)).
             
                vemite = plani.emite.  
                if vemite = 998  
                then vemite = 993 /*95*/.
                if vemite = 991
                then vemite = 995.
                vdesti = plani.desti.  
                if vdesti = 998  
                then vdesti = 993 /*95*/.
                if vdesti = 991
                then vdesti = 995.
               
                assign visenta      = 0 
                       voutras      = 0.
             
                if plani.movtdc =  6 or
                   plani.movtdc = 22 or
                   plani.movtdc = 60 or
                   plani.movtdc = 61 or
                   plani.movtdc = 62 or
                   plani.movtdc = 63 or
                   plani.movtdc = 64 or
                   plani.movtdc = 51 or
                   plani.movtdc = 53
                then do:   
                    vcod = "E" + string(vdesti,"9999999") + "          ". 
                end.    
                else if plani.movtdc = 9
                        or plani.movtdc = 59
                then do:
                    vopccod = string(plani.opccod).
                    vcod = "E" + string(vdesti,"9999999") + "          ".
                end.
                else do: 
                    find forne where forne.forcod = vdesti no-lock no-error.
                    if avail forne and plani.movtdc <> 48
                    then assign
                            vforcod = forne.forcod
                            vufecod = forne.ufecod
                            vcod = "F" + string(forne.forcod,"9999999") +
                                    "          ".
                    else do:
                        find clien where clien.clicod = vdesti
                                            no-lock no-error.
                        if avail clien
                        then assign
                                vforcod = clien.clicod
                                vufecod = clien.ufecod[1]
                                vcod = "C" + string(vforcod,"9999999999") +
                                "          ".
                    end.
                    
                    if vufecod = "RS"
                    then find first opcom
                              where opcom.movtdc = plani.movtdc
                                and opcom.opccod = string(plani.opccod)
                                     no-lock no-error.
                    else find last opcom
                             where opcom.movtdc = plani.movtdc
                               and opcom.opccod = string(plani.opccod)
                                    no-lock no-error.
                                   
                    if plani.opccod = 5949
                        or plani.opccod = 5602
                        or plani.opccod = 5901
                    then find last opcom
                             where opcom.opccod = string(plani.opccod)
                                            no-lock no-error.
                    
                    if not avail opcom
                        and plani.movtdc = 46
                    then find first opcom where
                                    opcom.opccod = string(plani.opccod)
                                    no-lock no-error.
                    
                    if not avail opcom
                    then do:
                        if plani.hiccod <> 0
                        then do:
                            find first opcom where 
                                opcom.opccod = string(plani.hiccod)
                                no-lock no-error. 
                        end.
                        else do:
                            message "Operacao Comercial Inexistente"
                                 plani.opccod skip
                                "para Nota Fiscal " plani.numero " em " skip
                                plani.pladat " estabelecimento: " plani.etbcod
                            view-as alert-box. 
                            next.
                        end.
                    end.
                end.

                assign vopccod = string(plani.opccod).

                assign val-pis = 0
                       val-cofins = 0
                       per-pis = 0
                       per-cofins = 0
                       base-pis = 0
                       valpis-capa = 0
                       basepis-capa = 0
                       valcofins-capa = 0
                       aux-uf = "".

                if plani.bicms > 0
                then vali = int((plani.icms * 100) / plani.bicms).
                else vali = 0. 
             
                vmovbicms = 0.
                vmovseq = 0.
                
                find first bmovim where bmovim.etbcod = plani.etbcod and
                                        bmovim.placod = plani.placod and
                                        bmovim.movtdc = plani.movtdc and
                                        bmovim.movdat = plani.pladat 
                                  no-lock no-error.
                if avail bmovim 
                then do:
                    if plani.movtdc = 13
                    then run p-pis-capa.
    
                    if plani.movtdc <> 6
                    then do :
                    for each movim where movim.etbcod = plani.etbcod and
                                         movim.placod = plani.placod and
                                         movim.movtdc = plani.movtdc and
                                         movim.movdat = plani.pladat 
                                         no-lock by movim.movseq:
                        
                        if movim.movqtm = 0
                        then next.
                        
                        assign
                        vmovim_procod    = movim.procod.
                        find first I01_prod of A01_InfNFe
                             where I01_prod.cprod = string(movim.procod)
                                       no-lock no-error.
                                       
                        assign vsittri = 0.

                        if avail I01_prod
                        then do.
                            find Q01_pis of I01_Prod no-lock no-error.
                            find S01_cofins of I01_Prod no-lock no-error.
                            find N01_icms of I01_Prod no-lock no-error.
                            if avail N01_icms
                            then assign vsittri = N01_icms.cst.
                        end.

                        assign
                            vmovim_movalicms = movim.movalicms
                            vmovim_movqtm    = movim.movqtm
                            vmovim_movpc     = movim.movpc
                            vmovim_movdes    = movim.movdes * movim.movqtm
                            vmovim_movcstpiscof = movim.movcstpiscof
                            vmovim_movcsticms = movim.movcsticms.
                            
                        assign
                            vmovpc  = movim.movpc
                            vmovqtm = movim.movqtm
                            vmovdes = movim.movdes * movim.movqtm.
                            
                        itvaloroutroicm =  movim.movpc * movim.movqtm.

                        vcodfis = "".
                        vprodu_codfis = 0.
                        find produ where produ.procod = movim.procod 
                                    no-lock no-error.
                        if not avail produ 
                        then do:
                            if plani.etbcod = 22
                            then do:
                                find first prodnewfree where
                                        prodnewfree.procod = movim.procod
                                        no-lock no-error.
                                if not avail prodnewfree
                                then next.
                                vmovim_pronom = prodnewfree.pronom.
                                vcodfis = string(prodnewfree.codfis).
                                vprodu_codfis = prodnewfree.codfis.
                                vsittri = int(string(prodnewfree.codori) + 
                                            string(prodnewfree.codtri)).
                             end.
                             else next.
                        end.
                        else
                            assign
                                vmovim_pronom = produ.pronom
                                vcodfis = string(produ.codfis)
                                vprodu_codfis = produ.codfis.

                        vmovbicms = 0.  
                        
                        if plani.frete > 0
                        then frete-item =  plani.frete * 
                            ((movim.movpc * movim.movqtm) / plani.protot).
                        
                        ipi_capa = plani.ipi.
                        ipi_item = 0.
                        
                        if plani.ipi > 0
                        then ipi_item = plani.ipi *
                            ((movim.movpc * movim.movqtm) / plani.protot).
                        
                        val_contabil = ((movim.movpc * movim.movqtm)
                                          - (movim.movdes * movim.movqtm))
                                          + frete-item + ipi_item.
 
                        if vopccod = "6901" 
                        then assign visenta = val_contabil  
                                              - (movim.movpc * movim.movqtm) 
                                              - plani.ipi.
                                    voutras = val_contabil 
                                              - (movim.movpc * movim.movqtm) 
                                              - plani.ipi - visenta.

                        if vopccod = "5202" or 
                           vopccod = "6202" or
                           vopccod = "5102"
                        then do:
                            assign vmovbicms = (movim.movpc * movim.movqtm)
                                               + (movim.movdev * movim.movqtm)
                                   visenta = (movim.movpc * movim.movqtm) - 
                                               ((movim.movicms /
                                                 movim.movalicms) * 100)
                                   itvaloroutroicm = 0 
                                    /*
                                    val_contabil = val_contabil + 
                                                ((movim.movpc * movim.movqtm) * 
                                                (movim.movalipi / 100))
                                    */
                                    ipi_capa = plani.ipi
                                    /*
                                    ipi_item =  ((movim.movpc * movim.movqtm) * 
                                                (movim.movalipi / 100))
                                    */
                                    ipi_base = if movim.movalipi <> 0
                                               then (movim.movpc *   
                                                     movim.movqtm)
                                               else 0.
                            if visenta < 0 then visenta = 0. 
                            
                            /*Verificar se o item tem base reduzida*/
                            find first clafis where
                                       clafis.codfis = vprodu_codfis
                                           no-lock no-error.
                            if avail clafis
                                and clafis.perred > 0
                                and (vopccod = "1102" or
                                     vopccod = "5202")
                            then
                                vmovbicms = ((movim.movpc * movim.movqtm)
                                            + (movim.movdev * movim.movqtm))
                                          - (((movim.movpc * movim.movqtm) +
                                               (movim.movdev * movim.movqtm))
                                            * (clafis.perred / 100)).
                        end.
                        else assign ipi_capa = 0
                                    ipi_item = 0
                                    ipi_base = 0.
                        
                        if (plani.movtdc = 13 or plani.movtdc = 59) and
                           movim.movicms > 0
                        then
                            assign vmovbicms = ((movim.movpc * movim.movqtm)
                                            + (movim.movdev * movim.movqtm)).
                        
                        if plani.movtdc = 27
                        then
                            assign vmovim_BSubst    = plani.bsubst
                                   vmovim_ICMSSubst = plani.ICMSSubst
                                   tot-basesubst    = plani.bsubst
                                   vmovbicms = 0.
                        
                        vobs[1] = plani.notobs[1].
                        vobs[2] = plani.notobs[2].
                        
                        if vobs[1] = "" and
                           ipi_capa > 0
                        then vobs[1] = "VALOR IPI: " + 
                                       string(ipi_capa,">>,>>9.99").
                        
                        /*Verificar se o item tem base reduzida*/
                        find first clafis where clafis.codfis = vprodu_codfis
                                       no-lock no-error.
                        if avail clafis
                            and clafis.perred > 0
                            and (vopccod = "1102" or
                                             vopccod = "5202")
                        then icms_item = (vmovbicms * (movim.movalicms / 100)).
                        else icms_item = (((movim.movpc * movim.movqtm)
                                      + (movim.movdev * movim.movqtm) )
                                       * (movim.movalicms / 100)).

                        if movim.movtdc = 48
                        then assign icms_item = 0
                                    vmovim_movalicms = 0.
                        
                   /**
                      Comentado para exportar notas exatamente igual a NFE
                        if vopccod = "5202" or
                           vopccod = "6202"
                        then icms_item = movim.movicms.   
                    **/
                        
                        if plani.movtdc = 13 /*or plani.movtdc = 5*/
                        then run p-piscofins(vcodfis,"S",
                                             movim.movpc * movim.movqtm).
                        /* Vendas Ecom */
                        if movim.movbicms > 0 /* movtdc = 5 */
                        then
                            assign
                                vopccod   = string(movim.opfcod)
                                vmovbicms = movim.movbicms
                                icms_item = movim.movicms
                                vsittri   = int(movim.movcsticms)
                                vmovim_movalicms = movim.movalicms.
                        if movim.opfcod > 0
                        then assign vopccod   = string(movim.opfcod).
                        else vopccod = string(plani.opccod).
                        run put-01.

                assign
                    basepis-capa = 0
                    valpis-capa = 0
                    valcofins-capa = 0
                    base-pis = 0
                    per-pis = 0
                    val-pis = 0
                    per-cofins = 0
                    val-cofins = 0.
                    end.
                    end.
                    /***********************
                    else do:
                        vmovseq = 0.
                        for each movim where movim.etbcod = plani.etbcod and
                                             movim.placod = plani.placod and
                                             movim.movtdc = plani.movtdc and
                                             movim.movdat = plani.pladat
                                         no-lock by movim.movseq:
                             
                            if movim.movqtm = 0 and plani.movtdc <> 6
                            then next.

                        find first produ of movim no-lock no-error.

                        assign
                            vmovim_procod    = movim.procod
                            vmovim_pronom    = produ.pronom
                            vmovim_movalicms = movim.movalicms
                            vmovim_movqtm    = movim.movqtm
                            vmovim_movpc     = movim.movpc
                            vmovim_movdes    = movim.movdes * movim.movqtm
                            vmovim_movcstpiscof = movim.movcstpiscof
                            vmovim_movcsticms = movim.movcsticms.
                        
                        assign
                            vmovpc  = movim.movpc
                            vmovqtm = movim.movqtm
                            vmovdes = movim.movdes * movim.movqtm.
                        
                        itvaloroutroicm =  movim.movpc * movim.movqtm.
                    
                        vmovbicms = 0.  
                        
                        val_contabil = ((movim.movpc * movim.movqtm)
                                       - (movim.movdes * movim.movqtm)).
 
                        if vopccod = "6901" 
                        then assign visenta = val_contabil  
                                              - (movim.movpc * movim.movqtm) 
                                              - plani.ipi.
                                    voutras = val_contabil 
                                              - (movim.movpc * movim.movqtm) 
                                              - plani.ipi - visenta.

                        if vopccod = "5202" or 
                           vopccod = "6202"
                        then do:
                             assign vmovbicms = ((movim.movpc * movim.movqtm)
                                              + (movim.movdev * movim.movqtm))
                                    visenta = (movim.movpc * movim.movqtm) - 
                                               ((movim.movicms /
                                                 movim.movalicms) * 100)
                                    itvaloroutroicm = 0 
                                    val_contabil = val_contabil + 
                                              (((movim.movpc * movim.movqtm) 
                                              - (movim.movdes * movim.movqtm))
                                                * 
                                                (movim.movalipi / 100))
                                    ipi_capa = plani.ipi
                                    ipi_item =  ((movim.movpc * movim.movqtm) * 
                                                (movim.movalipi / 100))
                                    ipi_base = if movim.movalipi <> 0
                                               then (movim.movpc *   
                                                     movim.movqtm)
                                               else 0.
                            if visenta < 0 then visenta = 0. 
                        end.
                        else assign ipi_capa = 0
                                    ipi_item = 0
                                    ipi_base = 0.

                        vobs[1] = plani.notobs[1].
                        vobs[2] = plani.notobs[2].
                        
                        if vobs[1] = "" and
                           ipi_capa > 0
                        then vobs[1] = "VALOR IPI: " + 
                                       string(ipi_capa,">>,>>9.99").
                                       
                        icms_item = (((movim.movpc * movim.movqtm)  
                                        + (movim.movdev * movim.movqtm) )
                                      * (movim.movalicms / 100)).
                        
                        if movim.movtdc = 48
                        then assign icms_item = 0
                                    vmovim_movalicms = 0.
                        
                        run put-03.
                        
                        assign
                    basepis-capa = 0
                    valpis-capa = 0
                    valcofins-capa = 0
                    base-pis = 0
                    per-pis = 0
                    val-pis = 0
                    per-cofins = 0
                    val-cofins = 0.
 
                    end.

                    end.
                    ******/
                end.
                /***************
                else do:
                
                    vmovbicms = 0.
                    itvaloroutroicm = plani.platot.
                    val_contabil = plani.platot.
                    visenta = 0.
                    voutras = val_contabil.
  
                    if vopccod = "6901"  
                    then assign visenta = val_contabil  
                                          - (plani.platot) - plani.ipi.
                                voutras = val_contabil 
                                          - (plani.platot) 
                                          - plani.ipi - visenta.
                    
                    if vopccod = "5202" or
                       vopccod = "6202"
                    then assign vmovbicms = plani.platot 
                                itvaloroutroicm = 0
                                val_contabil = val_contabil + plani.ipi.
                  
                    vobs[1] = plani.notobs[1]. 
                    vobs[2] = plani.notobs[2].
                        
                    if vobs[1] = "" and 
                       plani.ipi > 0
                    then vobs[1] = "VALOR IPI: " +
                                                string(plani.ipi,">>,>>9.99").

                    run put-02.
                    
                    assign
                        basepis-capa = 0
                        valpis-capa = 0
                        valcofins-capa = 0
                        base-pis = 0
                        per-pis = 0
                        val-pis = 0
                        per-cofins = 0
                        val-cofins = 0.
                 end.
                 *******/
            end.                                 
            /****************
            FIM DO BLOCO DE EXPORTAÇÃO DE NOTAS AUTORIZADAS E CANCELADAS
            *****************/
            
        end.
         
    end.      
    /******
    for each tipmov no-lock:

        if /*tipmov.movtdc =  5 or*/
           tipmov.movtdc = 30
        then next.
        
        for each estab no-lock:
         
            if vetbcod > 0
            then do:
            
                if vetbcod = 993
                    and estab.etbcod <> 993
                    and estab.etbcod <> 998
                then next.
                    
                if vetbcod = 995
                    and estab.etbcod <> 995
                    and estab.etbcod <> 991
                then next.
                
                if vetbcod <> 993
                    and vetbcod <> 995
                    and vetbcod <> estab.etbcod
                then next.    
            end.            
            
            /****************
            INICIO DO BLOCO DE EXPORTAÇÃO DE NOTAS INUTILIZADAS      
            *****************/
            for each placon where placon.etbcod = estab.etbcod  and
                                 placon.movtdc =  tipmov.movtdc and
                                 placon.pladat >= vdti         and
                                 placon.pladat <= vdtf no-lock,
                                 
                first ba01_infnfe where ba01_infnfe.etbcod = placon.etbcod
                                    and ba01_infnfe.placod = placon.placod
                                    and ba01_infnfe.situacao = "inutilizada"
                                  no-lock.
                if vnumero-aux > 0
                    and vnumero-aux <> placon.numero
                then next.

                if vimporta-lista
                then
                    if not can-find(first tt-imp
                                    where tt-imp.etbcod = placon.etbcod
                                      and tt-imp.numero = placon.numero)
                    then next.

                ipi_base = 0.
                ipi_item = 0.
                ipi_capa = 0.
                
                assign
                vplani_etbcod    = placon.etbcod    
                vplani_placod    = placon.placod
                vplani_movtdc    = placon.movtdc 
                vplani_serie     = placon.serie
                vplani_numero    = placon.numero
                vplani_platot    = placon.platot
                vplani_descprod  = placon.descprod
                vplani_protot    = placon.protot
                vplani_icms      = placon.icms
                vplani_icmssubst = placon.icmssubst
                vplani_frete     = placon.frete
                vplani_seguro    = placon.seguro
                vplani_vlserv    = placon.vlserv
                vplani_bicms     = placon.bicms
                vplani_ipi       = placon.ipi
                vopccod  = string(placon.hiccod)
                vpladat  = placon.pladat
                vemite   = placon.emite.
/***
                if placon.movtdc = 13 and
                   placon.pladat >= 01/01/2005 and
                   placon.pladat <= 05/31/2005
                then vpladat = date(07,
                                    day(placon.pladat),
                                    year(placon.pladat)).
***/
             
                if vemite = 998  
                then vemite = 993 /*95*/.
                if vemite = 991
                then vemite = 995.
                vdesti = placon.desti.  
                if vdesti = 998  
                then vdesti = 993 /*95*/.
                if vdesti = 991
                then vdesti = 995.
               
                assign visenta      = 0 
                       voutras      = 0.
             
                if placon.movtdc = 6 or
                   placon.movtdc = 9 or
                   placon.movtdc = 22
                then vcod = "E" + string(vdesti,"9999999") + "          ". 
                else do: 
                    find forne where forne.forcod = vdesti no-lock no-error.
                    if avail forne and placon.movtdc <> 48
                    then assign
                            vforcod = forne.forcod
                            vufecod = forne.ufecod
                            vcod = "F" + string(forne.forcod,"9999999") +
                                    "          ".
                    else do:
                        find clien where clien.clicod = vdesti no-lock no-error.
                        if avail clien
                        then assign
                                vforcod = clien.clicod
                                vufecod = clien.ufecod[1]
                                vcod = "C" + string(vforcod,"9999999999") +
                                "          ".
                    end.
                    
                    if vufecod = "RS"
                    then find first opcom where 
                                    opcom.movtdc = placon.movtdc no-lock
                                    no-error.
                    else find last opcom where 
                                   opcom.movtdc = placon.movtdc no-lock
                                   no-error.
                    if not avail opcom
                    then do:
                        if placon.hiccod <> 0
                        then do:
                            find first opcom where 
                                opcom.opccod = string(placon.hiccod)
                                no-lock no-error. 
                        end.
                        else do:
                            message "Operacao Comercial Inexistente " skip
                                "para Nota Fiscal " placon.numero " em " skip
                                placon.pladat " estabelecimento " placon.etbcod
                                view-as alert-box. 
                            next.
                        end.
                    end.
                end.

/***
                assign vopccod = "5949".
***/
                
                assign val-pis = 0
                       val-cofins = 0
                       per-pis = 0
                       per-cofins = 0
                       base-pis = 0
                       valpis-capa = 0
                       basepis-capa = 0
                       valcofins-capa = 0
                       aux-uf = "".

                if placon.bicms > 0
                then vali = int((placon.icms * 100) / placon.bicms).
                else vali = 0. 
             
                vmovbicms = 0.
                vmovseq = 0.
                
                find first bmovcon where bmovcon.etbcod = placon.etbcod and
                                         bmovcon.placod = placon.placod and
                                         bmovcon.movtdc = placon.movtdc and
                                         bmovcon.movdat = placon.pladat 
                                   no-lock no-error.
                if avail bmovcon 
                then do: 
                    /* Nota Inutilizada nao precisa calcula PIS-CAPA.
                    if placon.movtdc = 13
                    then run p-pis-capa.
                    */
                    
                    if placon.movtdc <> 6
                    then do :
                    for each movcon where movcon.etbcod = placon.etbcod and
                                         movcon.placod = placon.placod and
                                         movcon.movtdc = placon.movtdc and
                                         movcon.movdat = placon.pladat 
                                         no-lock by movcon.movseq:
                             
                        assign
                            vmovim_procod    = movcon.procod
                            vmovim_movalicms = movcon.movalicms
                            vmovim_movqtm    = movcon.movqtm
                            vmovim_movpc     = movcon.movpc
                            vmovim_movdes    = movcon.movdes * movcon.movqtm
                            vmovim_movcstpiscof = movcon.movcstpiscof
                            vmovim_movcsticms = movcon.movcsticms.
                        
                        assign
                            vmovpc = movcon.movpc
                            vmovqtm = movcon.movqtm
                            vmovdes = movcon.movdes * movcon.movqtm
                            itvaloroutroicm =  movcon.movpc * movcon.movqtm.

                        vcodfis = "".
                        vsittri = 0.
                        find produ where produ.procod = movcon.procod 
                                    no-lock no-error.
                        if not avail produ 
                        then do:
                            if placon.movtdc = 13 and
                               placon.etbcod = 22
                            then do:
                                find first prodnewfree where
                                        prodnewfree.procod = movcon.procod
                                        no-lock no-error.
                                if not avail prodnewfree
                                then next.
                                vcodfis = string(prodnewfree.codfis).
                                vsittri = int(string(prodnewfree.codori) + 
                                              string(prodnewfree.codtri)).
                                vprodu_codfis = prodnewfree.codfis.
                            end.
                            else next.
                        end.
                        else do:
                            vcodfis = string(produ.codfis).
                            vsittri = int(string(produ.codori) + 
                                            string(produ.codtri)).
                            vprodu_codfis = produ.codfis.
                        end.

                        vmovbicms = 0.  
                        
                        if placon.frete > 0
                        then frete-item =  placon.frete * 
                            ((movcon.movpc * movcon.movqtm) / placon.protot).
                        
                        ipi_capa = placon.ipi.
                        ipi_item = 0.
                        
                        if placon.ipi > 0
                        then ipi_item = placon.ipi *
                            ((movcon.movpc * movcon.movqtm) / placon.protot).
                        
                        val_contabil = ((movcon.movpc * movcon.movqtm)
                                         - (movcon.movdes * movcon.movqtm))
                                         + frete-item + ipi_item.
 
                        if vopccod = "6901" 
                        then assign visenta = val_contabil  
                                              - (movcon.movpc * movcon.movqtm) 
                                              - placon.ipi.
                                    voutras = val_contabil 
                                              - (movcon.movpc * movcon.movqtm) 
                                              - placon.ipi - visenta.

                        if vopccod = "5202" or 
                           vopccod = "6202"
                        then do:
                            assign vmovbicms = ((movcon.movpc * movcon.movqtm)
                                             + (movcon.movdev * movcon.movqtm))
                                    visenta = (movcon.movpc * movcon.movqtm) - 
                                               ((movcon.movicms /
                                                 movcon.movalicms) * 100)
                                    itvaloroutroicm = 0 
                                    /*
                                    val_contabil = val_contabil + 
                                              ((movcon.movpc * movcon.movqtm) * 
                                                (movcon.movalipi / 100))
                                    */
                                    ipi_capa = placon.ipi
                                    /*
                                   ipi_item = ((movcon.movpc * movcon.movqtm) * 
                                                (movcon.movalipi / 100))
                                    */
                                    ipi_base = if movcon.movalipi <> 0
                                               then (movcon.movpc *   
                                                     movcon.movqtm)
                                               else 0.
                            if visenta < 0 then visenta = 0. 
                            
                            /*Verificar se o item tem base reduzida*/
                            find clafis where clafis.codfis = vprodu_codfis
                                           no-lock no-error.
                            if avail clafis
                                and clafis.perred > 0
                                and (vopccod = "1102" or
                                     vopccod = "5202")
                            then
                                vmovbicms = ((movcon.movpc * movcon.movqtm)
                                            + (movcon.movdev * movcon.movqtm))
                                                -
                                          (((movcon.movpc * movcon.movqtm) + 
                                          (movcon.movdev * movcon.movqtm)) *
                                             (clafis.perred / 100)).
                        end.
                        else assign ipi_capa = 0
                                    ipi_item = 0
                                    ipi_base = 0.
                                    
                        vobs[1] = placon.notobs[1].
                        vobs[2] = placon.notobs[2].
                        
                        if vobs[1] = "" and
                           ipi_capa > 0
                        then vobs[1] = "VALOR IPI: " + 
                                       string(ipi_capa,">>,>>9.99").
                        
                        /*Verificar se o item tem base reduzida*/
                        find clafis where clafis.codfis = vprodu_codfis
                                       no-lock no-error.
                        if avail clafis
                            and clafis.perred > 0
                            and (vopccod = "1102" or
                                 vopccod = "5202")
                        then
                            icms_item =  (vmovbicms * (movcon.movalicms / 100)).
                        else
                            icms_item = (((movcon.movpc * movcon.movqtm)
                                        + (movcon.movdev * movcon.movqtm) )
                                       * (movcon.movalicms / 100)).

                        if movcon.movbicms > 0
                        then assign
                                vmovbicms = movcon.movbicms
                                icms_item = movcon.movicms.
                        
                        if movcon.movtdc = 48
                        then assign icms_item = 0
                                    vmovim_movalicms = 0.
                        
                   /**
                      Comentado para exportar notas exatamente igual a NFE
                        if vopccod = "5202" or
                           vopccod = "6202"
                        then icms_item = movcon.movicms.   
                    **/
                        
                        if placon.movtdc = 13
                        then run p-piscofins(vcodfis,"S",
                                             movcon.movpc * movcon.movqtm).
                        run put-01.

                assign
                    basepis-capa = 0
                    valpis-capa = 0
                    valcofins-capa = 0
                    base-pis = 0
                    per-pis = 0
                    val-pis = 0
                    per-cofins = 0
                    val-cofins = 0.
                    end.
                    end.
                    else do:
                        vmovseq = 0.
                        
                        for each movcon where movcon.etbcod = placon.etbcod and
                                         movcon.placod = placon.placod and
                                         movcon.movtdc = placon.movtdc and
                                         movcon.movdat = placon.pladat and
                                         movcon.desti  = placon.desti 
                                         no-lock by movcon.movseq:
                             
                        find first produ of movcon no-lock no-error.

                        assign
                            vmovim_procod = movcon.procod
                            vmovim_movalicms = movcon.movalicms
                            vmovim_movqtm    = movcon.movqtm
                            vmovim_movpc     = movcon.movpc
                            vmovim_movdes    = movcon.movdes * movcon.movqtm
                            vmovim_movcstpiscof = movcon.movcstpiscof
                            vmovim_movcsticms = movcon.movcsticms.
                        
                        assign
                            vmovpc  = movcon.movpc
                            vmovqtm = movcon.movqtm
                            vmovdes = movcon.movdes * movcon.movqtm.
                        
                        if avail produ
                        then assign vprodu_codfis = produ.codfis
                        
                        itvaloroutroicm =  movcon.movpc * movcon.movqtm.
                    
                        vmovbicms = 0.  
                        
                        val_contabil = (movcon.movpc * movcon.movqtm)
                                       - (movcon.movdes * movcon.movqtm).
 
                        if vopccod = "6901" 
                        then assign visenta = val_contabil  
                                              - (movcon.movpc * movcon.movqtm) 
                                              - placon.ipi.
                                    voutras = val_contabil 
                                              - (movcon.movpc * movcon.movqtm) 
                                              - placon.ipi - visenta.

                        if vopccod = "5202" or 
                           vopccod = "6202"
                        then do:
                            assign vmovbicms = ((movcon.movpc * movcon.movqtm)
                                              + (movcon.movdev * movcon.movqtm))
                                   visenta = (movcon.movpc * movcon.movqtm) - 
                                               ((movcon.movicms /
                                                 movcon.movalicms) * 100)
                                   itvaloroutroicm = 0 
                                   val_contabil = val_contabil + 
                                            (((movcon.movpc * movcon.movqtm)
                                            - (movcon.movdes * movcon.movqtm))
                                             * 
                                                (movcon.movalipi / 100))
                                   ipi_capa = placon.ipi
                                   ipi_item = ((movcon.movpc * movcon.movqtm) *
                                                (movcon.movalipi / 100))
                                   ipi_base = if movcon.movalipi <> 0
                                               then (movcon.movpc *   
                                                     movcon.movqtm)
                                               else 0.
                            if visenta < 0 then visenta = 0. 
                        end.
                        else assign ipi_capa = 0
                                    ipi_item = 0
                                    ipi_base = 0.
                        
                        vobs[1] = placon.notobs[1].
                        vobs[2] = placon.notobs[2].
                        
                        if vobs[1] = "" and
                           ipi_capa > 0
                        then vobs[1] = "VALOR IPI: " + 
                                       string(ipi_capa,">>,>>9.99").
                                       
                        icms_item = (((movcon.movpc * movcon.movqtm)  
                                      + (movcon.movdev * movcon.movqtm) )
                                    * (movcon.movalicms / 100)).
                        
                        if movcon.movtdc = 48
                        then assign icms_item = 0
                                    vmovim_movalicms = 0.
                         
                        /***            
                        if vopccod = "5202" or
                           vopccod = "6202"
                        then icms_item = movcon.movicms.   
                        ***/                              
                        
                        run put-03.
                        
                        assign
                        basepis-capa = 0
                        valpis-capa = 0
                        valcofins-capa = 0
                        base-pis = 0
                        per-pis = 0
                        val-pis = 0
                        per-cofins = 0
                        val-cofins = 0.
 
                        leave.

                        end.

                    end.
                end.
                else do:
                
                    vmovbicms = 0.
                    itvaloroutroicm = placon.platot.

                    val_contabil = placon.platot.
                    visenta = 0.

                    voutras = val_contabil.
 
                    if vopccod = "6901"  
                    then assign visenta = val_contabil  
                                          - (placon.platot) 
                                          - placon.ipi.
                                voutras = val_contabil 
                                          - (placon.platot) 
                                          - placon.ipi - visenta.
                    
                    if vopccod = "5202" or
                       vopccod = "6202"
                    then assign vmovbicms = placon.platot 
                                itvaloroutroicm = 0
                                val_contabil = val_contabil + placon.ipi.
                  
                    vobs[1] = placon.notobs[1]. 
                    vobs[2] = placon.notobs[2].
                        
                    if vobs[1] = "" and 
                       placon.ipi > 0
                    then vobs[1] = "VALOR IPI: " + 
                                   string(placon.ipi,">>,>>9.99").

                    run put-02.
                    
                    assign
                    basepis-capa = 0
                    valpis-capa = 0
                    valcofins-capa = 0
                    base-pis = 0
                    per-pis = 0
                    val-pis = 0
                    per-cofins = 0
                    val-cofins = 0.
                 end.
            end.                     

            /****************
            FIM DO BLOCO DE EXPORTAÇÃO DE NOTAS INUTILIZADAS
            *****************/
        end.
    end.
    ******/
    
    output close.

    message color red/with
    "Arquivo gerado:" skip
    varquivo
    view-as alert-box.
    
end.

def new shared temp-table tt-aviso
    field tabela as char
    field campo  as char
    field codigo as int
    field descr  as char
    field qtde   as int
    field erro   as log
    index aviso tabela descr campo codigo.

procedure c-aviso.
    def input parameter par-tabela  as char.
    def input parameter par-campo   as char.
    def input parameter par-descr   as char.
    def input parameter par-codigo  as int.
    def input parameter par-erro    as log.
    

    find tt-aviso where tt-aviso.tabela = par-tabela
                    and tt-aviso.descr  = par-descr 
                    and tt-aviso.campo  = par-campo
                    and tt-aviso.codigo = par-codigo
                  no-error.
    if not avail tt-aviso
    then do.
        create tt-aviso.
        assign
            tt-aviso.tabela = par-tabela
            tt-aviso.descr  = par-descr
            tt-aviso.campo  = par-campo
            tt-aviso.codigo = par-codigo
            tt-aviso.erro   = par-erro.
    end.
    tt-aviso.qtde = tt-aviso.qtde + 1.

end procedure.    
    
procedure p-piscofins:
   def input parameter pcodfis as char.
   def input parameter ptp     as char.
   def input parameter pbase   as dec.

assign pcodfis = replace(pcodfis,".","")
       base-pis = pbase.
       
if aux-uf = "AM"
then assign per-pis    = 1
            per-cofins = 4.6.     
else 
    if int(pcodfis) = 0
    then do.
        assign per-pis = 1.65
               per-cofins = 7.6.  
        run c-aviso("Produ", "NCM", "Produto sem NCM",
                    if avail produ then produ.procod else prodnewfree.procod,
                    no).
    end.
    else do:
         find first clafis where clafis.codfis = int(pcodfis) no-lock no-error.
         if not avail clafis
         then do.
            assign val-pis = 0
                   per-pis = 0
                   val-cofins = 0
                   per-cofins = 0
                   base-pis = 0.
            run c-aviso("Clafis", "NCM", "NCM nao cadastrado",
                    if avail produ then produ.codfis else prodnewfree.codfis,
                    yes).
         end.
         else do:
              if ptp = "E"
              then assign per-pis    = clafis.pisent
                          per-cofins = clafis.cofinsent.
              else assign per-pis    = clafis.pissai
                          per-cofins = clafis.cofinssai.
            
            if per-pis = 0 or per-cofins = 0
            then run c-aviso("Clafis", "NCM", "NCM com PIS/COFINS zerados",
                     clafis.codfis, yes).
        end.                 
     end.
     
assign val-pis    = base-pis * (per-pis / 100)
       val-cofins = base-pis * (per-cofins / 100).
       
end procedure.

procedure p-pis-capa.
def buffer bxmovim for movim.
     
    assign valpis-capa = 0
           basepis-capa = 0
           valcofins-capa = 0.

    for each bxmovim where bxmovim.etbcod = plani.etbcod and
                            bxmovim.placod = plani.placod and
                            bxmovim.movtdc = plani.movtdc and
                            bxmovim.movdat = plani.pladat no-lock:
     
              if bxmovim.movpc = 0 or
                 bxmovim.movqtm = 0
             then next.   
                        itvaloroutroicm =  bxmovim.movpc * bxmovim.movqtm.

                        find produ where produ.procod = bxmovim.procod 
                                    no-lock no-error.
                        if not avail produ then next.
                        
                        vmovbicms = 0.  
                        
                        val_contabil = bxmovim.movpc * bxmovim.movqtm.
 
                       if vopccod = "6901" 
                       then assign visenta = val_contabil  
                                            - (bxmovim.movpc * bxmovim.movqtm)
                                            - plani.ipi.
                                   voutras = val_contabil 
                                            - (bxmovim.movpc * bxmovim.movqtm)
                                            - plani.ipi - visenta.

                        if vopccod = "5202" or 
                           vopccod = "6202"
                        then do:
                            assign vmovbicms = ((bxmovim.movicms /
                                                  bxmovim.movalicms) * 100)
                                  visenta = (bxmovim.movpc * bxmovim.movqtm)
                                            - ((bxmovim.movicms /
                                                 bxmovim.movalicms) * 100)
                                  itvaloroutroicm = 0 
                                  val_contabil = val_contabil + 
                                            ((bxmovim.movpc * bxmovim.movqtm)
                                                * (bxmovim.movalipi / 100))
                                  ipi_capa = plani.ipi
                                  ipi_item =  ((bxmovim.movpc * bxmovim.movqtm)
                                             * (bxmovim.movalipi / 100))
                                  ipi_base = if bxmovim.movalipi <> 0
                                               then (bxmovim.movpc *   
                                                     bxmovim.movqtm)
                                               else 0.
                            if visenta < 0 then visenta = 0. 
                        end.
                        else assign ipi_capa = 0
                                    ipi_item = 0
                                    ipi_base = 0.
                                    
                        vobs[1] = plani.notobs[1].
                        vobs[2] = plani.notobs[2].
                        
                        icms_item = ((bxmovim.movpc * bxmovim.movqtm) * 
                                    (bxmovim.movalicms / 100)).
                                    
                        if vopccod = "5202" or
                           vopccod = "6202"
                        then icms_item = bxmovim.movicms.
                        
                        if bxmovim.movtdc = 48
                        then assign icms_item = 0
                                    vmovim_movalicms = 0.

        if bxmovim.movpis > 0
        then assign
                val-pis    = bxmovim.movpis
                val-cofins = bxmovim.movcofins
                per-pis    = bxmovim.movalpis
                per-cofins = bxmovim.movalcofins
                base-pis   = bxmovim.movbpiscof.
        else
            if avail produ
            then run p-piscofins(produ.codfis,"S",
                                 bxmovim.movpc * bxmovim.movqtm).

        assign valpis-capa    = valpis-capa + val-pis
               basepis-capa   = basepis-capa + base-pis
               valcofins-capa = valcofins-capa + val-cofins.
    end.           

    if plani.notpis > 0
    then valpis-capa    = plani.notpis.
    if plani.notcofins > 0
    then valcofins-capa = plani.notcofins.

end procedure.

procedure put-01:

    assign vmovseq = vmovseq + 1.
    
    /* Remover trecho*/                                               
    
    find A01_InfNFe where
         A01_InfNFe.etbcod = vplani_etbcod and
         A01_InfNFe.placod = vplani_placod
         no-lock no-error.
    
    {nf-situacao.i}
    
    if vplani_movtdc = 13
    then do:
        assign
            conta-pis    = "4.1.03.02"
            conta-cofins = "4.1.03.02"
            cst-piscofins = "4949".
        if vplani_etbcod = 22 and
           avail A01_InfNFe
        then do:
            find first I01_prod of A01_InfNFe where
                       I01_prod.cprod = string(vmovim_procod)
                       no-lock no-error.
            if avail I01_prod
            then assign
                    vmovpc  = vuncom
                    vmovqtm = qcom.            
        end.   
    end.       
    else if vplani_movtdc = 6 or
            vplani_movtdc = 9
    then
        assign
            conta-pis    = "4.1.03.02"
            conta-cofins = "4.1.03.02"
            cst-piscofins = "4949".
     else if vplani_movtdc = 5 or
             vplani_movtdc = 33 
     then do:
        assign
            conta-pis    = "3.1.01"
            conta-cofins = "3.1.01".           

        if per-pis = 0 and per-cofins = 0
        then do:
            cst-piscofins = "0606".
            if substr(string(vprodu_codfis),1,4) = "4013"
            then cst-piscofins = "0404".
            if substr(string(vprodu_codfis),1,5) = "85272"
            then cst-piscofins = "0404".
            if vprodu_codfis = 85071000
            then cst-piscofins = "0404".
        end.
        else cst-piscofins = "0101".

        if avail clafis and
           clafis.log1 /* Monofasico */
        then cst-piscofins = "0404".  
    end.
    else assign
            conta-pis    = "4.1.03.02"
            conta-cofins = "4.1.03.02"
            cst-piscofins = "4949".

    if avail A01_InfNFe
    then do:
        find I01_Prod of A01_infnfe where
                    I01_Prod.cprod = string(vmovim_procod)
                    no-lock no-error.
        if avail I01_Prod
        then do:               
            find Q01_pis of I01_Prod no-lock no-error.
            if avail Q01_pis
            then cst-piscofins = string(Q01_pis.cst,"99").
            find S01_cofins of I01_Prod no-lock no-error.
            if avail S01_cofins
            then cst-piscofins = cst-piscofins + string(S01_cofins.cst,"99").
        end.
    end.

    if vmovbicms = ? then vmovbicms = 0.
    if visenta = ? then visenta = 0.
    
    if vplani_serie = "55"
    then assign v-mod = "55".
    else assign v-mod = "01".  

    if v-mod = "01"
        and avail a01_infnfe
    then assign v-mod = "55".     
 
    if avail ba01_infnfe 
    then assign ind-situacao = "05"
                ind-cancelada = "S".

    if vplani_movtdc = 48
        and ind-situacao = "00"
    then assign ind-situacao = "08".

    assign 
        v-mod = "55".
    
    if avail produ
    then do:
        if vcodfis = "" and
           produ.codfis > 0
        then vcodfis = string(produ.codfis).
        if vsittri = 0 and
           produ.codori > 0
        then vsittri = int(string(produ.codori) + string(produ.codtri)).
    end.

    if avail plani and plani.ufdes <> "" and length(plani.ufdes) = 44
    then assign vchave-aux = plani.ufdes .
    else if avail A01_InfNFe
         then assign vchave-aux = A01_InfNFe.id.
         else assign vchave-aux = "".
    
    if ind-situacao = "05"
    then vchave-aux = "".
    
    if vobs[1] = ?
    then assign vobs[1] = "".
    
    if vobs[2] = ?
    then assign vobs[2] = "".
    
    if vplani_icms = ?
    then assign vplani_icms = 0.
    
    if vmovim_movalicms = ?
    then assign vmovim_movalicms = 0.

    if icms_item = ?
    then assign icms_item = 0.
    
    if vsittri = ? then vsittri = 0.
    if val_contabil < 0 then val_contabil = 0.
    
    assign
        cst-piscofins = string(vmovim_MovCstPisCof)
        cst-icms      = string(vmovim_movcsticms). 
    
    if vopccod = "5405" or
       vopccod = "6404"
    then run regras-5405-6404.

    if length(trim(cst-piscofins)) = 1
    then cst-piscofins = "0" + string(trim(cst-piscofins)).
    
    if length(trim(cst-piscofins)) = 2
    then cst-piscofins = cst-piscofins + cst-piscofins.

    cst-icms = string(int(cst-icms),"999").
    
    if cst-piscofins = "0000"
    then cst-piscofins = "".
    
    def var s-movpc as char.
    def var s-movqt as char.
    def var s-total as char.
    def var s-bicms as char.
    def var s-aicms as char.
    def var s-vicms as char.
    def var s-apis  as char.
    def var s-acofins as char.
    
    
    assign
        s-movpc = string(vmovpc,">>>,>>>,>>9.99")
        s-movpc = replace(s-movpc,",","")
        s-movpc = replace(s-movpc,".",",")
        s-movqt = string(vmovqtm,">>>,>>>,>>9.99")
        s-movqt = replace(s-movqt,",","")
        s-movqt = replace(s-movqt,".",",")
        s-total = string(vmovpc * vmovqtm,">>>,>>>,>>9.99")
        s-total = replace(s-total,",","")
        s-total = replace(s-total,".",",")
        s-bicms = string(vmovbicms,">>>,>>>,>>9.99")
        s-bicms = replace(s-bicms,",","")
        s-bicms = replace(s-bicms,".",",")
        s-aicms = string(vmovim_movalicms,">>>,>>>,>>9.99")
        s-aicms = replace(s-aicms,",","")
        s-aicms = replace(s-aicms,".",",")
        s-vicms = string(icms_item,">>>,>>>,>>9.99")
        s-vicms = replace(s-vicms,",","")
        s-vicms = replace(s-vicms,".",",")
        s-apis    = string(per-pis,">>>,>>>,>>9.99")
        s-apis    = replace(s-apis,",","")
        s-apis    = replace(s-apis,".",",")
        s-acofins = string(per-cofins,">>>,>>>,>>9.99")
        s-acofins = replace(s-acofins,",","")
        s-acofins = replace(s-acofins,".",",")
        .
     
    put unformatted 
    vemite    
    vsep
    vplani_numero  
    vsep
    vpladat
    vsep
    vopccod format "x(6)"
    vsep
    string(vmovim_procod) format "x(15)" 
    vsep
    vmovim_pronom
    vsep
    vprodu_codfis
    vsep
    s-movpc  
    vsep
    s-movqt 
    vsep
    s-total 
    vsep
    s-bicms
    vsep
    s-aicms
    vsep
    s-vicms 
    vsep
    vsep
    vsep
    vsep
    vsep
    s-apis   
    vsep
    s-acofins 
    vsep
    vsep
    vsep
    skip
    .
        
        assign
            nat-receita = ""
            ind-complementar = ""
            ind-situacao = ""
            ind-tiponota = ""
            obs-complementar = ""
            cod-observacao = ""
            cod-obsfiscal = ""
            tot-basesubst = 0
            ind-movestoque = ""
            aliquota_pis = 0
            aliquota_cofins = 0
            data_contingencia = ""
            hora_contingencia = ""
            motivo_contingencia = ""
            ccc_fiscal = ""
            st_ipi = ""
            icms_naodebitado = 0
            conta-pis = ""
            conta-cofins = ""
            cst-piscofins = ""
            frete-item = 0
            v-mod = ""
            vmovim_movalicms = 0
            vmovim_procod   = 0
            vprodu_codfis   = 0
            vmovpc          = 0
            vmovqtm         = 0 
            vmovdes         = 0
            vmovim_movqtm  = 0
            vmovim_movpc   = 0
            vmovim_movdes  = 0
            vmovim_movcstpiscof = 0
            vmovim_movcsticms = "".

end procedure.

/************************
procedure put-02:
    
    vmovseq = vmovseq + 1.
    ipi_capa = vplani_ipi.
    
    find A01_InfNFe where
                         A01_InfNFe.etbcod = vplani_etbcod and
                         A01_InfNFe.placod = vplani_placod
                         no-lock no-error.
    {nf-situacao.i}

    if vplani_movtdc = 13
    then do:
        assign
            conta-pis    = "4.1.03.02"
            conta-cofins = "4.1.03.02"
            cst-piscofins = "4949".
     end. 
     else if vplani_movtdc = 6
     then
        assign
            conta-pis     = "4.1.03.02"
            conta-cofins  = "4.1.03.02"
            cst-piscofins = "4949".
     else if vplani_movtdc = 9
     then do:
        assign
            conta-pis    = "4.1.03.02"
            conta-cofins = "4.1.03.02"
            cst-piscofins = "4949".
     end. 
     else if vplani_movtdc = 5 or
             vplani_movtdc = 33 
     then do:
        assign
            conta-pis    = "3.1.01"
            conta-cofins = "3.1.01".           

        if per-pis = 0 and per-cofins = 0
        then do:
            cst-piscofins = "0606".
            if substr(string(vprodu_codfis),1,4) = "4013"
            then cst-piscofins = "0404".
            if substr(string(vprodu_codfis),1,5) = "85272"
            then cst-piscofins = "0404".
            if vprodu_codfis = 85071000
            then cst-piscofins = "0404".
        end.
        else cst-piscofins = "0101".

        if avail clafis and
           clafis.log1 /* Monofasico */
        then cst-piscofins = "0404".  
    end.
    else assign
            conta-pis    = "4.1.03.02"
            conta-cofins = "4.1.03.02"
            cst-piscofins = "4949".

    if avail A01_InfNFe
    then do:
        find I01_Prod of A01_infnfe where
                    I01_Prod.cprod = string(vmovim_procod)
                    no-lock no-error.
        if avail I01_Prod
        then do:               
            find Q01_pis of I01_Prod no-lock no-error.
            if avail Q01_pis
            then cst-piscofins = string(Q01_pis.cst,"99").
            find S01_cofins of I01_Prod no-lock no-error.
            if avail S01_cofins
            then cst-piscofins = cst-piscofins + string(S01_cofins.cst,"99").
        end.
    end.

    if vmovbicms = ? then vmovbicms = 0.
    if visenta = ? then visenta = 0.
    
    if vplani_serie = "55"
    then assign v-mod = "55".
    else assign v-mod = "01".  

    if v-mod = "01"
        and avail a01_infnfe
    then assign v-mod = "55".     

    if avail ba01_infnfe
    then assign ind-situacao = "05"
                ind-cancelada = "S".

    if vplani_movtdc = 48
        and ind-situacao = "00"
    then assign ind-situacao = "08".

    assign v-mod = "55".
    
    if avail produ
    then do:
        if vcodfis = "" and
            produ.codfis > 0
        then vcodfis = string(produ.codfis).
        if vsittri = 0 and
           produ.codori > 0
        then vsittri = int(string(produ.codori) + string(produ.codtri)).
    end.
        
    if vobs[1] = ?
    then assign vobs[1] = "".
    
    if vobs[2] = ?
    then assign vobs[2] = "".
    
    if vplani_icms = ?
    then assign vplani_icms = 0.

    if avail plani and plani.ufdes <> "" and length(plani.ufdes) = 44
    then assign vchave-aux = plani.ufdes .
    else if avail A01_InfNFe
         then assign vchave-aux = A01_InfNFe.id.
         else assign vchave-aux = "".
         if vsittri = ? then vsittri = 0.
         if val_contabil < 0 then val_contabil = 0.
                
    /*
    if vopccod = 5405 or
       vopccod = 6404
    then run regras-5405-6404.
      */
                    
                    cst-icms = string(int(cst-icms),"999").
                    put unformatted 
                        string(vemite,">>9")    
                        "P"  format "x(1)" 
                        v-mod format "x(02)"
                        "NF" format "x(05)"            
                        "01 " format "x(05)" 
                        string(vplani_numero,">>>>>>999999")  
                        string(year(vpladat),"9999") 
                        string(month(vpladat),"99") 
                        string(day(vpladat),"99") 
                        string(year(vpladat),"9999")
                        string(month(vpladat),"99") 
                        string(day(vpladat),"99") 
                        vcod  format "x(18)" 
                        ind-cancelada format "x(1)" 
                        "V" format "x(1)" 
                        vplani_platot   format "9999999999999.99" 
                        vplani_descprod format "9999999999999.99" 
                        vplani_protot   format "9999999999999.99" 
                        vplani_icms     format "9999999999999.99" 
                        0 /*plani.ipi*/      format "9999999999999.99" 
                        vplani_icmssubst format "9999999999999.99"  
                        " " format "x(20)" 
                        vplani_frete    format "9999999999999.99" 
                        vplani_seguro   format "9999999999999.99" 
                        "0000000000000.00"  
                        "RODOVIARIO"   format "x(15)" 
                        "CIF"          format "x(3)"  
                        " " format "x(18)" 
                        "0000000000000.00" 
                        "UNIDADE" format "x(10)"  
                        "000000000000.000" 
                        "000000000000.000" 
                        " " format "x(17)" 
                        vplani_vlserv format "9999999999999.99" 
                        "0000.00" 
                        "0000000000000.00" 
                        "0000000000000.00"  
                        "0000000000000.00"  
                        "0000000000000.00"  
                        "0000000000000.00"  
                        "0000000000000.00"  
                        "0000000000000.00"  
                        "0000000000000.00"  
                        "0000000000000.00"  
                        "0000000000000.00"  
                        "0000000000000.00"  
                        "0000000000000.00"  
                        "0000000000000.00"  
                        vobs[1] format "x(50)" 
                        vobs[2] format "x(50)" 
                        " " format "x(30)" 
                        " " format "x(1)"  
                        " " format "x(20)" 
                        " " format "x(45)" 
                        vopccod format "x(6)" 
                        " " format "x(6)" 
        /* 779-788 */   vcodfis format "x(10)" 
        /* 789-791 */   cst-icms format "x(3)"  
                        "00000000001.0000" /* 792-807 */
                        "UN" format "x(3)" 
                        vplani_platot format "99999999999.9999" 
                        vplani_platot format "9999999999999.99" 
                        "0000000000000.00"  
                        " " format "x(1)"
     /*860-875 */      vmovbicms format "9999999999999.99" 
     /* 876-882 */     "0000.00"       
                        (vplani_platot * 
                        (vplani_icms / 100)) format "9999999999999.99" 
     /* 899-914 */      visenta      format "9999999999999.99" 
     /* 915-930 */      itvaloroutroicm  format "9999999999999.99" 
     /* 931-946 */      vmovim_BSubst   format "9999999999999.99"
     /* 947-962 */      vmovim_ICMSSubst  format "9999999999999.99"
                        " " format "x(1)"  
                        "0000000000000.00" 
     /* 980-986  */     "0000.00" 
     /* 987-1002 */     "0000000000000.00" 
                        "0000000000000.00" 
                        "0000000000000.00" 
                        "0000000000000.00" 
                        "0000000000000.00" 
     /* 1067-1073 */    "0000.00"    
                        "0000000000000.00"  
                        "0000000000000.00"
     /* 1106-1112 */    "0000.00"  
                        "0000000000000.00" 
                        "0000000000000.00" 
     /* 1145-1151 */    "0000.00"  
                        "0000000000000.00" 
                        "0000000000000.00"
    /*  1184-1190 */    "0000.00"
                        "0000000000000.00"
                        " " format "x(14)"
                        "0000000000000.00" 
                        "0000.00"  
                        "0000000000000.00"  
                        "0000000000000.00"  
                        "0000.00"  
                        "0000000000000.00"  
        
        /* 1299-1314 */ val_contabil format "9999999999999.99" 
        /* 1315-1330 */ " " format "x(16)"
        /* 1331-1334 */ cst-piscofins format "x(4)"
        /* 1335-     */ vplani_bicms  format "9999999999999.99"
        /* 1351-     */ ind-complementar format "x"
        /* 1352-     */ ind-situacao format "x(2)"
        /* 1354-     */ ind-tiponota format "x"
        /* 1355-     */ obs-complementar format "x(254)"
        /* 1609-     */ cod-observacao format "x(6)"
        /* 1615-     */ cod-obsfiscal  format "x(6)"
        /* 1621-     */ tot-basesubst  format "9999999999999.99"
        /* 1637-     */ ind-movestoque format "x" .
        /* 1638-     */ put vchave-aux format "x(44)".
        /* 1682      */ put " " format "x(28)" .
        /* 1710      */ put ipi_capa format "99999999999999.99"
        /* 1727      */     ipi_item format "99999999999999.99" .
        /* 1744      */ put vplani_bicms format "99999999999999.99"
        /* 1761      */     aliquota_pis format "9999.99"
        /* 1768      */     aliquota_cofins format "9999.99"
        /* 1775      */     data_contingencia format "x(8)"
        /* 1783      */     hora_contingencia format "x(10)"
        /* 1793      */     motivo_contingencia format "x(254)"
        /* 2047      */     ccc_fiscal format "x(2)"
        /* 2049      */     st_ipi format "x(3)"
        /* 2052      */     icms_naodebitado format "99999999999999.99"
        /* 2069      */     aliquota_pis format "9999.99"
        /* 2076      */     aliquota_cofins format "9999.99"
        /* 2083      */     "0" format "x"
        /* 2084      */     "0" format "x"
        /* 2085      */     " " format "x(28)"
        /* 2113      */     " " format "x(6)"
        /* 2119      */     " " format "x(6)"
        /* 2125      */     " " format "x(3)"
        /* 2128      */     " " format "x(2)"
        /* 2130      */     conta-pis    format "x(28)"
        /* 2158      */     conta-cofins format "x(28)"
        /* 2186      */     string(vmovseq,">>>9") format "x(4)"
        /* 2190      */     frete-item format "9999999999999.99"
        /* 2230      */     "put-02"  at 2230
        /* 2240      */      vplani_movtdc at 2240
                             nat-receita format "x(3)"
           .
                put skip.
        
        assign
            nat-receita = ""
            ind-complementar = ""
            ind-situacao = ""
            ind-tiponota = ""
            obs-complementar = ""
            cod-observacao = ""
            cod-obsfiscal = ""
            tot-basesubst = 0
            ind-movestoque = ""
            aliquota_pis = 0
            aliquota_cofins = 0
            data_contingencia = ""
            hora_contingencia = ""
            motivo_contingencia = ""
            ccc_fiscal = ""
            st_ipi = ""
            icms_naodebitado = 0
            conta-pis = ""
            conta-cofins = ""
            cst-piscofins = ""
            frete-item = 0
            v-mod = ""
            vmovim_movalicms = 0
            vmovim_procod    = 0
            vprodu_codfis    = 0
            vmovpc           = 0
            vmovqtm          = 0
            vmovdes          = 0
            vmovim_movqtm  = 0
            vmovim_movpc   = 0
            vmovim_movdes  = 0
            vmovim_movcstpiscof = 0
            vmovim_movcsticms = ""
             .

end procedure.

procedure put-03:

    vmovseq = vmovseq + 1.
    find A01_InfNFe where
                         A01_InfNFe.etbcod = vplani_etbcod and
                         A01_InfNFe.placod = vplani_placod
                         no-lock no-error.
    {nf-situacao.i}             

    if vplani_movtdc = 13
     then do:
        assign
            conta-pis = "4.1.03.02"
            conta-cofins = "4.1.03.02"
            cst-piscofins = "4949".
     end. 
     else if vplani_movtdc = 6
     then
        assign
            conta-pis    = "4.1.03.02"
            conta-cofins = "4.1.03.02"
            cst-piscofins = "4949".
     else if vplani_movtdc = 9
     then do:
        assign
            conta-pis = "4.1.03.02"
            conta-cofins = "4.1.03.02"
            cst-piscofins = "4949".
     end. 
     else if vplani_movtdc = 5 or
             vplani_movtdc = 33 
     then do:
        assign
            conta-pis    = "3.1.01"
            conta-cofins = "3.1.01".           

        if per-pis = 0 and per-cofins = 0
        then do:
            cst-piscofins = "0606".
            if substr(string(vprodu_codfis),1,4) = "4013"
            then cst-piscofins = "0404".
            if substr(string(vprodu_codfis),1,5) = "85272"
            then cst-piscofins = "0404".
            if vprodu_codfis = 85071000
            then cst-piscofins = "0404".
        end.
        else cst-piscofins = "0101".

        if avail clafis and
           clafis.log1 /* Monofasico */
        then cst-piscofins = "0404".  
    end.
    else assign
            conta-pis    = "4.1.03.02"
            conta-cofins = "4.1.03.02"
            cst-piscofins = "4949".
 
    if avail A01_InfNFe
    then do:
        find I01_Prod of A01_infnfe where
                    I01_Prod.cprod = string(vmovim_procod)
                    no-lock no-error.
        if avail I01_Prod
        then do:               
            find Q01_pis of I01_Prod no-lock no-error.
            if avail Q01_pis
            then cst-piscofins = string(Q01_pis.cst,"99").
            find S01_cofins of I01_Prod no-lock no-error.
            if avail S01_cofins
            then cst-piscofins = cst-piscofins + string(S01_cofins.cst,"99").
        end.
    end.

    if vmovbicms = ? then vmovbicms = 0.
    if visenta = ? then visenta = 0.

    if avail produ
    then do:
        if vcodfis = "" and
            produ.codfis > 0
        then vcodfis = string(produ.codfis).
        if vsittri = 0 and
            produ.codori > 0
        then vsittri = int(string(produ.codori) + string(produ.codtri)).
        
    end.
    vsittri = 051.
    
    if vplani_serie = "55"
    then assign v-mod = "55".
    else assign v-mod = "01".  

    if v-mod = "01"
        and avail a01_infnfe
    then assign v-mod = "55".     
    
    if avail ba01_infnfe
    then assign ind-situacao = "05"
                ind-cancelada = "S".

    if vplani_movtdc = 48
        and ind-situacao = "00"
    then assign ind-situacao = "08".

    assign v-mod = "55".
        
    if vobs[1] = ?
    then assign vobs[1] = "".
    
    if vobs[2] = ?
    then assign vobs[2] = "".

    if vplani_icms = ?
    then assign vplani_icms = 0.
    
    if avail plani and plani.ufdes <> "" and length(plani.ufdes) = 44
    then assign vchave-aux = plani.ufdes .
    else if avail A01_InfNFe
         then assign vchave-aux = A01_InfNFe.id.
         else assign vchave-aux = "".
         if vsittri = ? then vsittri = 0.
         if val_contabil < 0 then val_contabil = 0.
    /*                    
    if vopccod = 5405 or
       vopccod = 6404
    then run regras-5405-6404.
    */                  
    cst-icms = string(int(cst-icms),"999").

    put unformatted 
                            string(vemite,">>9")    
                            "P"  format "x(1)"                           
                            v-mod format "x(02)"
                            "NF" format "x(05)"            
                            "01 " format "x(05)" 
                            string(vplani_numero,">>>>>>999999")  
                            string(year(vpladat),"9999") 
                            string(month(vpladat),"99") 
                            string(day(vpladat),"99") 
                            string(year(vpladat),"9999")
                            string(month(vpladat),"99") 
                            string(day(vpladat),"99") 
                        vcod  format "x(18)" 
                        ind-cancelada format "x(1)" 
                        "V" format "x(1)" 
                        vplani_platot   format "9999999999999.99" 
                        vplani_descprod format "9999999999999.99" 
                        vplani_protot   format "9999999999999.99" 
                        vplani_icms     format "9999999999999.99" 
                        ipi_capa       format "9999999999999.99" 
                        vplani_icmssubst format "9999999999999.99"  
                        " " format "x(20)" 
                        vplani_frete    format "9999999999999.99" 
                        vplani_seguro   format "9999999999999.99" 
                        "0000000000000.00"  
                        "RODOVIARIO"   format "x(15)" 
                        "CIF"          format "x(3)"  
                        " " format "x(18)" 
                        "0000000000000.00" 
                        "UNIDADE" format "x(10)"  
                        "000000000000.000" 
                        "000000000000.000" 
                        " " format "x(17)" 
                        vplani_vlserv format "9999999999999.99" 
                        "0000.00" 
                        "0000000000000.00" 
                        "0000000000000.00"  
                        "0000000000000.00"  
                        "0000000000000.00"  
                        "0000000000000.00"  
                        "0000000000000.00"  
                        "0000000000000.00"  
                        "0000000000000.00"  
                        "0000000000000.00"  
                        "0000000000000.00"  
                        "0000000000000.00"  
                        "0000000000000.00"  
                        "0000000000000.00"  
                        vobs[1] format "x(50)" 
                        vobs[2] format "x(50)" 
                        " " format "x(30)" 
                        " " format "x(1)"  
                        string(vmovim_procod) format "x(20)" 
                        " " format "x(45)" 
                        vopccod format "x(6)" 
                        " " format "x(6)" 
        /* 779-788 */   vcodfis format "x(10)" 
        /* 789-791 */   cst-icms format "x(3)" 
                        vmovim_movqtm  format "99999999999.9999" /* 792-807 */
                        "UN" format "x(3)" 
                        vmovim_movpc                  format "99999999999.9999" 
                       (vmovim_movpc * vmovim_movqtm) format "9999999999999.99" 
                        vmovim_movdes                 format "9999999999999.99"
                        " " format "x(1)"
     /* 860-875 */       vmovbicms format "9999999999999.99" 
     /* 876-882 */      vmovim_movalicms              format "9999.99"       
                        icms_item format "9999999999999.99" 
     /* 899-914 */      visenta      format "9999999999999.99" 
     /* 915-930 */      itvaloroutroicm format "9999999999999.99" 
     /* 931-946 */      vmovim_BSubst     format "9999999999999.99"
     /* 947-962 */      vmovim_ICMSSubst   format "9999999999999.99"
     /* 963-963 */      " " format "x(1)"  
     /* 964-979 */      0 /*ipi_base*/       format "9999999999999.99" 
     /* 980-986  */     0 /*movim.movalipi*/ format "9999.99" 
     /* 987-1002 */     0 /*ipi_item*/       format "9999999999999.99" 
                        "0000000000000.00" 
                        "0000000000000.00" 
                        "0000000000000.00" 
                        "0000000000000.00" 
     /* 1067-1073 */    "0000.00"    
                        "0000000000000.00"  
                        "0000000000000.00"
     /* 1106-1112 */    "0000.00"  
                        "0000000000000.00" 
                        "0000000000000.00" 
     /* 1145-1151 */    "0000.00"  
                        "0000000000000.00" 
                        "0000000000000.00"
    /*  1184-1190 */    "0000.00"
                        "0000000000000.00"
                        " " format "x(14)"
                        "0000000000000.00" 
                        "0000.00"  
                        "0000000000000.00"  
                        "0000000000000.00"  
                        "0000.00"  
                        "0000000000000.00"  
        /* 1299-1314 */ val_contabil format "9999999999999.99" 
        /* 1315-1330 */ " " format "x(16)"
        /* 1331-1334 */ cst-piscofins format "x(4)"
        /* 1335-     */ vplani_bicms  format "9999999999999.99"
        /* 1351-     */ ind-complementar format "x"
        /* 1352-     */ ind-situacao format "x(2)"
        /* 1354-     */ ind-tiponota format "x"
        /* 1355-     */ obs-complementar format "x(254)"
        /* 1609-     */ cod-observacao format "x(6)"
        /* 1615-     */ cod-obsfiscal  format "x(6)"
        /* 1621-     */ tot-basesubst  format "9999999999999.99"
        /* 1637-     */ ind-movestoque format "x" .
        /* 1638-     */ put vchave-aux format "x(44)".
        /* 1682      */ put " " format "x(28)" .
        /* 1710      */ put ipi_capa format "99999999999999.99"
        /* 1727      */     ipi_item format "99999999999999.99" .
        /* 1744      */ put vplani_bicms format "99999999999999.99"
        /* 1761      */     aliquota_pis format "9999.99"
        /* 1768      */     aliquota_cofins format "9999.99"
        /* 1775      */     data_contingencia format "x(8)"
        /* 1783      */     hora_contingencia format "x(10)"
        /* 1793      */     motivo_contingencia format "x(254)"
        /* 2047      */     ccc_fiscal format "x(2)"
        /* 2049      */     st_ipi format "x(3)"
        /* 2052      */     icms_naodebitado format "99999999999999.99"
        /* 2069      */     aliquota_pis    format "9999.99"
        /* 2076      */     aliquota_cofins format "9999.99"
        /* 2083      */     "0" format "x"
        /* 2084      */     "0" format "x"
        /* 2085      */     " " format "x(28)"
        /* 2113      */     " " format "x(6)"
        /* 2119      */     " " format "x(6)"
        /* 2125      */     " " format "x(3)"
        /* 2128      */     " " format "x(2)"
        /* 2130      */     conta-pis    format "x(28)"
        /* 2158      */     conta-cofins format "x(28)"
        /* 2186      */     string(vmovseq,">>>9") format "x(4)"
        /* 2190      */     frete-item format "9999999999999.99"
        /* 2230      */     "put-03" at 2230
        /* 2240      */      vplani_movtdc at 2240
                             nat-receita format "x(3)"
           .
        put skip.
        
        assign
            nat-receita = ""
            ind-complementar = ""
            ind-situacao = ""
            ind-tiponota = ""
            obs-complementar = ""
            cod-observacao = ""
            cod-obsfiscal = ""
            tot-basesubst = 0
            ind-movestoque = ""
            aliquota_pis = 0
            aliquota_cofins = 0
            data_contingencia = ""
            hora_contingencia = ""
            motivo_contingencia = ""
            ccc_fiscal = ""
            st_ipi = ""
            icms_naodebitado = 0
            conta-pis = ""
            conta-cofins = ""
            cst-piscofins = ""
            frete-item = 0
            v-mod = ""
            vmovim_movalicms = 0
            vmovim_procod   = 0
            vmovim_movqtm  = 0
            vmovim_movpc   = 0
            vmovim_movdes  = 0.
    
end procedure.
***************************/

procedure regras-5405-6404:

    assign
        cst-piscofins = string(movim.MovCstPisCof)
        cst-icms      = string(movim.movcsticms).         

    if avail clafis
    then do:

    nat-receita = string(clafis.int3,"999").
             
    if clafis.log1 = yes 
    then assign
             per-pis = 0
             val-pis = 0
             per-cofins = 0
             val-cofins = 0.

    if clafis.codfis = 84715010 and
       movim.movpc   <= 2000
    then assign
            cst-piscofins = "0606"
            nat-receita   = "401"
            per-pis = 0
             val-pis = 0
             per-cofins = 0
             val-cofins = 0
             .

    if (clafis.codfis = 84713012 or
       clafis.codfis = 84713019 or
       clafis.codfis = 84713090) and 
       movim.movpc <= 4000
    then assign
             cst-piscofins = "0606"
             nat-receita   = "402"
             per-pis = 0
             val-pis = 0
             per-cofins = 0
             val-cofins = 0
             .

    if clafis.codfis = 847141 and
       movim.movpc <= 2500
    then assign
             cst-piscofins = "0606"
             nat-receita   = "407"
             per-pis = 0
             val-pis = 0
             per-cofins = 0
             val-cofins = 0
             .

    if (clafis.codfis = 85176255 or
       clafis.codfis = 85176262 or
       clafis.codfis = 85176272) and
       movim.movpc <= 200
    then assign
             cst-piscofins = "0606"
             nat-receita   = "408"
             per-pis = 0
             val-pis = 0
             per-cofins = 0
             val-cofins = 0
             .

    if clafis.codfis = 85171231 and
       movim.movpc <= 1500
    then assign
            cst-piscofins = "0606"
            nat-receita   = "409"
            per-pis = 0
             val-pis = 0
             per-cofins = 0
             val-cofins = 0
             .

    if substr(string(clafis.codfis),1,4) = "4011" or
       substr(string(clafis.codfis),1,4) = "4013"
    then assign
            cst-piscofins = "0404"
            nat-receita   = "304".
    if substr(string(clafis.codfis),1,6) = "850710" 
    then assign
             cst-piscofins = "0404"
             nat-receita   = "302".
    if substr(string(clafis.codfis),1,5) = "85272"
    then assign
            cst-piscofins = "0404"
            nat-receita   = "302".
    if string(clafis.codfis) = "85365090"
    then assign
             cst-piscofins = "0404"
             nat-receita   = "302".

    end.

end procedure.


