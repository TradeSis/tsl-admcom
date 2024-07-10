{admcab.i}
pause 0 before-hide.
def var vsep as char.
vsep = ";".
def var vmovseq like movim.movseq.
def var tot-bicmscapa as dec.
def var ind-complementar as char.
def var ind-tiponota as char.
def var obs-complementar as char.
def var cod-observacao as char.
def var cod-obsfiscal  as char.
def var tot-basesubst  as dec.
def var ind-movestoque as char.                
def var varq-lista       as char.
def var vokpagamento     as log init yes .
def var vimporta-lista   as log format "Sim/Nao".
def var vlinha           as char.
def var vtotprodu like plani.protot.
def var codigo-bc as char.
def var conta-pis as char.
def var conta-cofins as char.
def var cst-piscofins as char.
def var tipo-credito as char.
def var ipi_retido as dec.
def var cof_retido as dec.
def var dat_conclu as char.
def var nat_frete as char.
def var tipo_cte as char.
def var dat_contingencia as char.
def var hor_contingencia as char.
def var mot_contingencia as char.
def var ccc_fiscal as char.
def var ipi_capa  like plani.platot.
def var ipi_item  like plani.platot.
def var vmovalipi like movim.movalipi.
def var frete_item like movim.movpc.
def var valicm  as dec.
def var tip-doc as char.
def var ie_subst_trib as char.
def var per_desc like plani.platot.
def var valor_item as dec decimals 4 format "->>>,>>9.9999".
def var protot_capa like plani.platot.
def var desc_capa like plani.platot.
def var valor_ipi as dec.
def var nome_produto as char format "x(45)".  
def var v-ser as char.
def var v-mod as char.
def var v-tipo as char format "x(01)". 
def var vnumero like fiscal.numero.
def var totpla like plani.platot.
def buffer bmovim for movim.
def var vemi like plani.emite.
def var vdesti like plani.etbcod.
def var data_rec like plani.pladat.
def var recpla as recid.
def var varq as char.
def var tot_pro like plani.platot.
def var base_subs  like plani.platot.
def var valor_subs like plani.platot.
def var vcodfis as char format "x(10)".
def var vsittri as int format "999".
def var base_icms like plani.platot.
def var base_ipi  like plani.platot.
def var vdes      like plani.platot. 
def var vipi      like plani.platot.
def var vicms     like plani.platot.
def var visenta   like plani.isenta.
def var voutras   like plani.platot.
def var val_contabil like plani.platot.
def var vdti like plani.pladat.
def var vdtf like plani.pladat.
def var vetbcod like estab.etbcod.
def var vopccod as char.
def var vali    as int.
def var vcod as char format "x(18)".
def var ali_icms like movim.movalipi.
def var ali_ipi  like movim.movalicms.
def var vobs     like plani.notobs.
def var vmovpc as dec decimals 4 format "->>>,>>9.9999".
def var valoricms as dec.
def var vetb as char.

def var aux-uf     as char.
def var val-pis    as dec.
def var val-cofins as dec.
def var per-pis    as dec.
def var per-cofins as dec.
def var base-pis   as dec.
def var vbicms00 as dec.
def var vbicms99 as dec.
    
def var tipo-documento as char.
def var valpis-capa    as dec.
def var basepis-capa   as dec.
def var valcofins-capa as dec.
def var vemite like plani.emite.
def var vestab_etbcod     like estab.etbcod.
def var vplani_etbcod     like plani.etbcod.
def var vdebug            as logical.
def var vnumero-nota      as integer.
def var vmovtdc           as integer.
def var item-icms-naocreditado as dec.
def var capa-icms-naocreditado as dec.
def var capa-icms-creditado as dec.

def temp-table tt-imp
    field etbcod as int
    field numero as int
        index idx01 etbcod numero .

def var vmovsubst like movim.movsubst.
def var bST-item as dec.
def var iST-item as dec.
def var vmovqtm like movim.movqtm.
def buffer smovim for movim.

procedure item-ST:
        for each smovim where
                               smovim.etbcod = plani.etbcod and
                               smovim.placod = plani.placod and
                               smovim.movtdc = plani.movtdc and
                               smovim.movdat = plani.pladat 
                             no-lock.
                            find produ where produ.procod = smovim.procod
                                        no-lock no-error.
                            if not avail produ then next.
                            if produ.proipiper <> 99 then next.
            vmovqtm = vmovqtm + smovim.movqtm.
        end.
        
        iST-item = plani.bsubst / vmovqtm.
        iST-item = plani.icmssubst / vmovqtm.
        
end procedure.

def var sparam as char.
sparam = SESSION:PARAMETER.
if num-entries(sparam,";") > 1
then sparam = entry(2,sparam,";").
 
def var varquivo as char format "x(65)".
def var vnom as char.
def var vdir as char.
vdir = "/admcom/relat/".

repeat:
                       
    /*if opsys = "unix" and sparam <> "AniTA"
    then do:
        input from /admcom/audit/param_nfe.
        repeat:
            import varq.
            vetbcod = int(substring(varq,1,3)).
            vdti    = date(int(substring(varq,6,2)),
                           int(substring(varq,4,2)),
                           int(substring(varq,8,4))).
            vdtf    = date(int(substring(varq,14,2)),
                           int(substring(varq,12,2)),
                           int(substring(varq,16,4))).
        end.
        input close.
    
        if vetbcod = 999
        then return.    
    end.
    else*/ do:
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
    
    if vetbcod = 0
    then vetb = "".
    else vetb = string(vetbcod,"999").
    
    vnom = "entradas_MTP_" + trim(string(vetb,"x(3)")) + "_" +
                         string(day(vdti),"99") +  
                         string(month(vdti),"99") +  
                         string(year(vdti),"9999") + "_" +  
                         string(day(vdtf),"99") +  
                         string(month(vdtf),"99") +  
                         string(year(vdtf),"9999") + ".csv".
        
    varquivo = vdir + vnom.
    
    update varquivo label "Arquivo" with frame f2
        side-label width 80.
    
    output to value(varquivo).

        put "Filial;Tipo;Numero;Data;CFOP;Produto;Descrição;NCM;Val.Unit;Quant.;Total;B.Calculo;AliqICMS;val.ICMS;B.Reduzida;ST;MVA.Interna;MVA.InerEstadual;Aliq.PIS;Aliq.COFINS;BaseIPI;Aliq.IPI;Val.IPI" skip.

    for each tipmov where 
                        tipmov.movtdc =  4 or
                        tipmov.movtdc = 10 or
                        tipmov.movtdc = 11 or
                        tipmov.movtdc = 12 or
                        tipmov.movtdc = 15 or
                        tipmov.movtdc = 27 or
                        tipmov.movtdc = 28 or
                        tipmov.movtdc = 32 or
                        tipmov.movtdc = 35 or
                        tipmov.movtdc = 47 or
                        tipmov.movtdc = 51 or
                        tipmov.movtdc = 53 or
                        tipmov.movtdc = 57 or
                        tipmov.movtdc = 60 or
                        tipmov.movtdc = 61 or
                        tipmov.movtdc = 62 or
                        tipmov.movtdc = 65 or
                        tipmov.movtdc = 67
        or can-find (first tipmovaux where
                            tipmovaux.movtdc = tipmov.movtdc and
                            tipmovaux.nome_campo = "PROGRAMA-NF" AND
                            tipmovaux.valor_campo = "nfentall")
                no-lock :
        
        vmovtdc = tipmov.movtdc.
        
        for each estab no-lock.
            
            /*
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
            */
            
            for each fiscal where fiscal.movtdc = tipmov.movtdc and
                                  fiscal.desti  = estab.etbcod  and
                                  fiscal.plarec >= vdti         and
                                  fiscal.plarec <= vdtf 
                                  no-lock:
          
           /*Tipo 27 emite NF de Saidas e Entradas, portanto descarta saidas*/
                if fiscal.movtdc = 27
                    and fiscal.opfcod = 5603
                then next.    
                
                if vimporta-lista                
                then do:
                
                    if not can-find(first tt-imp
                                    where tt-imp.etbcod = fiscal.desti
                                      and tt-imp.numero = fiscal.numero)
                    then next.                  
                
                end.
                
                if vnumero-nota > 0 and vnumero-nota <> fiscal.numero
                then next.
                
                v-mod  = "01".
                v-ser  = "01".
                vcod   = "".
                recpla = ?.
                v-tipo = "T".
                
                /*
                if fiscal.platot = 0 and fisca.movtdc <> 27
                then next.      /* Ressarcimento ICMS*/
                */
                if tipmov.movtdc <> 12 /*= 4 11/12/2009*/ 
                then do:  
                    find plani where plani.etbcod = estab.etbcod 
                                 and plani.emite  = fiscal.emite   
                                 and plani.movtdc = tipmov.movtdc  
                                 and plani.serie  = fiscal.serie   
                                 and plani.numero = fiscal.numero 
                                            no-lock no-error.
                    if not avail plani  
                    then do:                        
                        find plani where plani.etbcod = estab.etbcod 
                                     and plani.emite  = fiscal.emite 
                                     and plani.movtdc = 15 
                                     and plani.serie  = fiscal.serie 
                                     and plani.numero = fiscal.numero 
                                             no-lock no-error.
                        if avail plani
                        then recpla = recid(plani).
                        else do:
                            find plani where plani.etbcod = estab.etbcod 
                                     and plani.emite  = fiscal.emite 
                                     and plani.movtdc = 23 
                                     and plani.serie  = fiscal.serie 
                                     and plani.numero = fiscal.numero 
                                             no-lock no-error.
                            if avail plani
                            then recpla = recid(plani).
                            else if fiscal.emite = 998 or fiscal.emite = 991
                            then do:
                                 find plani where plani.etbcod = fiscal.emite
                                              and plani.emite  = fiscal.emite
                                              and plani.movtdc = tipmov.movtdc
                                              and plani.serie  = fiscal.serie
                                              and plani.numero = fiscal.numero
                                                     no-lock no-error.
                                 if avail plani
                                 then recpla = recid(plani).
                            end.
                            else if fiscal.emite = 993
                            then do:
                                find plani where 
                                     plani.etbcod = 998
                                 and plani.emite  = fiscal.emite
                                 and plani.movtdc = tipmov.movtdc
                                 and plani.serie  = fiscal.serie
                                 and plani.numero = fiscal.numero
                                                     no-lock no-error.
                                if avail plani
                                 then recpla = recid(plani).
                            end.
                        end.        
                    end.
                    else recpla = recid(plani).
                end.     
                else do:
                        find first plani where plani.etbcod = estab.etbcod 
                                           and plani.emite  = fiscal.emite 
                                           and plani.movtdc = 12 
                                           and plani.serie  = fiscal.serie 
                                           and plani.numero = fiscal.numero 
                                         no-lock no-error.
                        if avail plani
                        then assign vcod = "E" + 
                                           string(fiscal.emite,"9999999") + 
                                           "          "
                                    recpla = recid(plani)
                                    v-tipo = "P".
                end. 
                if not avail plani
                then next.
                find opcom where opcom.opccod = string(plani.opccod) no-lock
                no-error.
                if not avail opcom then next.
                
                /*if fiscal.movtdc = 27
                then*/
                    assign tot-basesubst = plani.bsubst.

                aux-uf = "".
                tipo-documento = "NF".
                find first tipmovaux where
                           tipmovaux.movtdc = tipmov.movtdc and
                           tipmovaux.nome_campo = "Modelo-Documento"
                           no-lock no-error.
                if avail tipmovaux
                then v-mod = tipmovaux.valor_campo.
                find first tipmovaux where
                           tipmovaux.movtdc = tipmov.movtdc and
                           tipmovaux.nome_campo = "Tipo-Documento"
                           no-lock no-error.
                if avail tipmovaux
                then tipo-documento = tipmovaux.valor_campo.
                
                if ((estab.etbcod > 900 or
                   {/admcom/progr/conv_igual.i estab.etbcod} or
                    estab.etbcod = 22) and
                    fiscal.movtdc = 4   ) or
                    can-find (first tipmovaux where
                            tipmovaux.movtdc = tipmov.movtdc and
                            tipmovaux.nome_campo = "PROGRAMA-NF" AND
                            tipmovaux.valor_campo = "nfentall")
                then do:
                    find forne where forne.forcod = fiscal.emite 
                                no-lock no-error.  
                    if not avail forne  
                    then next.

                    aux-uf = forne.ufecod.
                    
                    vcod = "F" + string(forne.forcod,"9999999") + "          ".
                    
                    find cpforne where
                         cpforne.forcod = forne.forcod no-lock no-error.
                    if avail cpforne and
                         cpforne.date-1 <> ?
                    then do:
                        if date(cpforne.date-1) > today
                        then assign
                                v-mod = "01"
                                tipo-documento = "NF".
                        else assign
                                v-mod = "55"
                                tipo-documento = "NF-e".
                    end.
                    else if avail cpforne and
                        cpforne.date-1 = ?
                    then assign 
                            v-mod = "01"
                            tipo-documento = "NF".

                    /*** conhecimento de frete *****/
                    find first frete where frete.forcod = forne.forcod
                            no-lock no-error.
                    if avail frete 
                    then do:
                        assign
                            vcod = "T" + string(forne.forcod,"9999999") +
                                "          "
                            v-ser = "U"
                            v-mod = "08"
                            tipo-documento = "CTRC".  
                        
                        if avail cpforne and
                           cpforne.date-1 <> ?
                        then assign
                                v-mod = "57"
                                tipo-documento = "CT-e".
                    end.
                    
                    /*****************************/
                end.
                else assign vcod = "E" + string(fiscal.emite,"9999999") + 
                                    "          "
                                    v-tipo = "P".  
                                                   
                if fiscal.opfcod = 1102 or
                   fiscal.opfcod = 2102 or
                   fiscal.opfcod = 1949 or
                   fiscal.opfcod = 2949
                then do:
                    find forne where forne.forcod = fiscal.emite 
                            no-lock no-error.  
                    if avail forne and fiscal.desti <> fiscal.emite 
                    then do:
                        vcod = "F"
                            + string(forne.forcod,"9999999") + "          ".
                        v-tipo = "T".  
                    end.
                    else if fiscal.desti = fiscal.emite
                    then do:
                        vcod = "E"
                            + string(fiscal.emite,"9999999") + "          ".
                        v-tipo = "P".  
                    end.
                end.
                   
                if fiscal.opfcod = 1915 or
                   fiscal.opfcod = 2915 or
                   fiscal.opfcod = 2910 
                then do:
                    find forne where forne.forcod = fiscal.emite 
                                no-lock no-error.  
                    if not avail forne  
                    then next.
 
                    find cpforne where
                         cpforne.forcod = forne.forcod no-lock no-error.
                    if avail cpforne and
                         cpforne.date-1 <> ?
                    then do:
                        if date(cpforne.date-1) > today
                        then assign
                                v-mod = "01"
                                tipo-documento = "NF".
                        else assign
                                v-mod = "55"
                                tipo-documento = "NF-e".
                    end.
                    else assign
                            v-mod = "01"
                            tipo-documento = "NF".
                            
                    vcod = "F" + string(forne.forcod,"9999999") +
                            "          ".               
                end.   
                   
                if fiscal.opfcod = 1253 
                then do:
                    find forne where forne.forcod = fiscal.emite 
                                no-lock no-error.  
                    if not avail forne  
                    then next.
 
                    find cpforne where
                         cpforne.forcod = forne.forcod no-lock no-error.
                    if avail cpforne and
                         cpforne.date-1 <> ?
                    then do:
                        if date(cpforne.date-1) > today
                        then assign
                                v-mod = "01"
                                tipo-documento = "NF".
                        else assign
                                v-mod = "55"
                                tipo-documento = "NF-e".
                    end.
                    else assign
                            v-mod = "06"
                            tipo-documento = "NFEE".
                            
                    vcod = "F" + string(forne.forcod,"9999999") +
                            "          ".               
                end.
                
                if fiscal.opfcod = 1353 or
                   fiscal.opfcod = 2353
                then do: 
                    find first frete where frete.forcod = forne.forcod
                            no-lock no-error.
                    if avail frete 
                    then do:
                        assign
                         vcod = "T" + string(forne.forcod,"9999999") + 
                                "          "
                         v-ser = "U"
                         v-mod = "08"
                         tipo-documento = "CTRC".          
                        
                        if avail cpforne and
                           cpforne.date-1 <> ?
                        then assign
                                v-mod = "57"
                                tipo-documento = "CT-e".
                    end.
                end.

                /** SPED
                if fiscal.opfcod = 1353 or
                   fiscal.opfcod = 2353
                then assign v-mod = "08" 
                            v-ser = "U".
                **/

                vopccod = string(fiscal.opfcod). 
                
                /*
                if length(vopccod) = 4
                    and fiscal.movtdc = 63 /* ESTORNO ENTRADA CONSERTO*/
                then assign vopccod = "1" + substring(vopccod,2,3).
                */
                
                if fiscal.bicms > 0 
                then vali = int((fiscal.icms * 100) / fiscal.bicms). 
                else vali = 0.
                
                if recpla <> ?
                then find plani where recid(plani) = recpla no-lock no-error. 
                
                if avail plani and
                         plani.movtdc = 12 and
                         plani.serie = "U"
                then next.
                         
                if fiscal.desti = fiscal.emite
                    or (fiscal.desti = 993 and fiscal.emite = 998)
                then v-tipo = "P".
                else v-tipo = "T".
                
                if avail plani
                then do:
                    run pagamento.
                    if not vokpagamento
                    then next.

                    if tipmov.movtnota = no /* Digita */ and
                       plani.notpis = 0
                    then run piscofins2.p (recid(plani)).

                    if tipmov.movtnota = no /* Digita */ and
                       tipmov.movtcompra
                    then run not_noticms.p (recid(plani)).

                    v-ser = plani.serie.
                    if v-ser = "U"  or
                       v-ser = "M1" or
                       v-ser = "55"
                    then v-ser = "01".

                    ie_subst_trib = "".
                    if plani.icmssubst > 0
                    then do:
                        find forne where forne.forcod = plani.emite 
                                    no-lock no-error.
                        if avail forne
                        then ie_subst_trib = forne.foriesub.
                    end.
                    
                    if plani.movtdc = 12
                    then data_rec = plani.pladat.
                    else data_rec = plani.datexp.
               
                    if plani.movtdc = 4 and
                       plani.bsubst > 0
                    then do:
                        vmovqtm  = 0.
                        bST-item = 0.
                        iST-item = 0.
                        run item-ST.
                    end.
                    
                    vmovseq = 0.
                    
                    find first bmovim where 
                               bmovim.etbcod = plani.etbcod and
                               bmovim.placod = plani.placod and
                               bmovim.movtdc = plani.movtdc and
                               bmovim.movdat = plani.pladat 
                                    no-lock no-error.
                    if avail bmovim
                    then do:
                        if plani.opccod = 1102 or
                           plani.opccod = 2101 or
                           plani.opccod = 1101 or
                           plani.opccod = 1202
                        then run p-pis-capa.
                                    
                        for each movim where movim.etbcod = plani.etbcod and
                                         movim.placod = plani.placod and
                                         movim.movtdc = plani.movtdc and
                                         movim.movdat = plani.pladat 
                                         no-lock
                                         by movim.movseq:
                            if movim.movqtm = 0
                            then next.

                            frete_item = 0.
                            if movim.movdev > 0
                            then frete_item = movim.movdev.
                        
                            /*
                            if (movim.movpc = 0 or
                                movim.movqtm = 0) and movim.movtdc <> 27
                            then next. 
                            */
                            
                            tot_pro = movim.movqtm * movim.movpc.
                            vcodfis = "".
                            vsittri = 0.
                    
                            find produ where produ.procod = movim.procod 
                                            no-lock no-error.
                            if not avail produ
                            then do:
                                if plani.movtdc = 4 and
                                   plani.etbcod = 22
                                then do:
                                    find first prodnewfree where
                                        prodnewfree.procod = movim.procod
                                        no-lock no-error.
                                    if not avail prodnewfree
                                    then next.
                                    vcodfis = string(prodnewfree.codfis).
                                    vsittri = int(string(prodnewfree.codori) + 
                                            string(prodnewfree.codtri)).
                                end.
                                else next.
                            end.
                            else do:
                              if produ.codfis > 0
                              then vcodfis = string(produ.codfis).
                              if produ.codori > 0
                              then vsittri = int(string(produ.codori) + 
                                       string(produ.codtri)).
                            end.
                            
                            base_subs  = 0.
                            valor_subs = 0.
                            base_ipi = 0.
                            vmovpc = movim.movpc - movim.movdes.
                            
                            if plani.ipi > 0
                            then base_ipi = (vmovpc + frete_item) 
                                         * movim.movqtm.
                            if plani.protot > 0 and
                               plani.bicms > 0
                            then base_icms = (fiscal.bicms / plani.protot) * 
                                    (vmovpc * movim.movqtm).
                            else base_icms = 0.
                            if fiscal.platot > 0
                            then vdes = (plani.descprod / fiscal.platot) * 
                                    (vmovpc * movim.movqtm).
                            if vdes = ? then vdes = 0.
                            vipi  = base_ipi  * (movim.movalipi / 100).
                            vicms = base_icms * (movim.movalicms / 100). 

                            if plani.ipi > 0 and plani.protot > 0
                            then vipi = movim.movipi.

                            if vipi = ?
                            then vipi = 0.
                            if vicms = ?
                            then vicms = 0.
                            if base_icms = ? then base_icms = 0.
                        
                            val_contabil = ((vmovpc + frete_item) 
                                        * movim.movqtm) + vipi.
 
                            visenta = val_contabil - base_icms - vipi.
                            if visenta < 0 or visenta = ?
                            then visenta = 0.

                            voutras = val_contabil - base_icms - vipi - visenta.
                            if voutras = ? then voutras = 0.
                                                       
                            if fiscal.opfcod = 1915 or
                               fiscal.opfcod = 2915 
                            then assign voutras = val_contabil
                                        visenta = 0.

                            if voutras < 0 or voutras = ?
                            then voutras = 0.

                            /* Laureano - 17-04-2012 */
                            valor_item  = movim.movpc.
                            protot_capa = plani.protot.
                            desc_capa   = plani.descprod.
                        
                            if plani.protot > 0
                            then per_desc = plani.descprod / plani.protot.
                            else per_desc = 0.
                        
                            if vopccod = "1949" or 
                               vopccod = "2949"
                            then
                                if plani.bicms > 0
                                then assign
                                        base_icms = val_contabil
                                        voutras   = 0.
                                else assign
                                        base_icms = 0
                                        voutras   = val_contabil.    
                        
                            /* Laureano - 17-04-2012 */
                            if movim.movicms <> ? and
                               movim.movicms > 0  /***08042014 and
                               plani.opccod = 5202 ***/
                            then valicm = movim.movicms.
                            else valicm = ((vmovpc * movim.movqtm) * 
                                     (movim.movalicms / 100)).

                            if valicm = ? then valicm = 0.
                            vmovsubst = movim.movsubst.
                            if vopccod = "1101" or
                               vopccod = "1102" or
                               vopccod = "2101" or
                               vopccod = "2102" or
                               vopccod = "1202" or 
                               vopccod = "1910" or
                               vopccod = "2910" or
                               vopccod = "1949" or
                               vopccod = "2949" or
                               vopccod = "1124" or
                               vopccod = "2124" or
                               vopccod = "1551"
                            then do: 
                                visenta = 0.
                                run /admcom/progr/trata_cfop.p (input vopccod, 
                                              input movim.procod,
                                              input ((vmovpc + frete_item)
                                                     * movim.movqtm),
                                              input movim.movalicms,   
                                              input movim.movicms,   
                                              input vmovsubst,
                                              output base_icms,  
                                              output visenta,  
                                              output voutras,  
                                              output vsittri,
                                              output valicm).
                                if vsittri = 0 or
                                   vsittri = ?  
                                then do:
                                find clafis where clafis.codfis = 
                                        (if avail produ then produ.codfis
                                        else prodnewfree.codfis)
                                        no-lock no-error.
                                if avail clafis
                                then vsittri = clafis.sittri.
                                if vsittri = ? or
                                   vsittri = 0       
                                then assign vsittri = 0.    
                                end.
                            end.   

                            if fiscal.movtdc = 27 or
                               fiscal.movtdc = 60 or /*** ***/
                               fiscal.movtdc = 62 or /*** ***/
                               fiscal.movtdc = 67
                            then
                                assign vsittri = 90.

                            else if fiscal.movtdc = 12
                            then
                                if movim.movalicms = 0
                                then assign vsittri = 60.
                                else assign vsittri = 0.

                            if movim.MovCstIcms <> ""
                            then vsittri = int(movim.MovCstIcms).
                            if movim.movbicms > 0
                            then base_icms = movim.movbicms.
                            
                            vobs[1] = plani.notobs[1].
                            vobs[2] = plani.notobs[2].
                        
                            if vobs[1] = "" and
                                fiscal.ipi > 0
                            then vobs[1] = "VALOR IPI: " + 
                                       string(fiscal.ipi,">>>,>>9.99").

                            if tipmov.movtnota = no /* Digita */ or
                                movim.movpis > 0 or
                                opcom.piscofins
                            then assign
                                    base-pis   = movim.movbpiscof
                                    val-pis    = movim.movpis
                                    val-cofins = movim.movcofins
                                    per-pis    = movim.movalpis
                                    per-cofins = movim.movalcofins
                                    cst-piscofins = string(movim.movcstpiscof)
                                                  + string(movim.movcstpiscof).
                            else if 
                               /***plani.opccod = 1101 or
                               plani.opccod = 1102 or
                               plani.opccod = 1202 or
                               plani.opccod = 2101 or
                               plani.opccod = 2102 or***/
                               plani.opccod = 1910 or
                               plani.opccod = 2910
                            then run p-piscofins(
                                if avail produ then produ.codfis
                                else prodnewfree.codfis ,"E",
                            ((movim.movpc /*- movim.movdes*/) * movim.movqtm)).

                            if plani.icms - valicm < 0
                            then valicm = 
                              dec(substr(string(valicm,">>>>>>>9.999"),1,11)).
                            if visenta < 0
                            then visenta = 0.
        
                            vmovalipi = movim.movalipi.
                            if vmovalipi = ?
                            then vmovalipi = 0.
                            vdes = movim.movdes * movim.movqtm.
                            if vdes = ?
                            then vdes = 0.

                            if basepis-capa < 0
                            then basepis-capa = 0.  

                            if valpis-capa < 0
                            then valpis-capa = 0.

                            if valcofins-capa < 0 
                            then valcofins-capa = 0.

                            run  put-1.

                            assign 
                                base-pis = 0
                                per-pis = 0
                                val-pis = 0
                                per-cofins = 0
                                val-cofins = 0.
                        end.
                    end.
                    /************ sem itens
                    else do:
                    
                        if plani.movtdc = 12
                        then next.
                        
                        if fiscal.emite = 101998 or
                           fiscal.emite = 102044 or 
                           fiscal.emite = 533    or 
                           fiscal.emite = 100071 or 
                           fiscal.emite = 103114
                        then vcod = "F" + "0100725" + "          ".  
 
                        tot_pro = fiscal.platot.
                        vcodfis = "".
                        vsittri = 0.
                        base_subs  = 0.
                        valor_subs = 0.
                        
                        vipi  = fiscal.ipi.
                        if vipi = ?
                        then vipi = 0.
                        if plani.bicms > 0
                        then base_icms = ((fiscal.bicms / fiscal.platot) * 
                                     (fiscal.platot)) - vipi.
                        else base_icms = 0.
                        
                        base_ipi = base_icms.
                        vdes = 0.
                  
                        vicms = base_icms * (fiscal.alicms / 100). 
                    
                        /*
                        val_contabil = base_icms + vipi.
                        */
                        
                        /*Laureano - 17-04-2012*/
                        val_contabil = fiscal.platot + vipi.

                        visenta = val_contabil - (fiscal.platot) - vipi.
                        if visenta < 0
                        then visenta.
                        
                        voutras = val_contabil - fiscal.platot - vipi - visenta.
                        if voutras < 0
                        then voutras = 0.
                        
                        if fiscal.opfcod = 1915 or
                           fiscal.opfcod = 2915 
                        then voutras = val_contabil.
                                   
                        if /*vopccod = "1949" or
                           vopccod = "2949" or*/
                           vopccod = "2019"
                        then
                            if plani.bicms > 0
                            then assign base_icms = val_contabil
                                        voutras   = 0.
                            else assign base_icms = 0
                                        voutras   = val_contabil.    
                        
                        vnumero = fiscal.numero.
                        /*
                        if vnumero >= 1000000
                        then vnumero = int(substring(string(vnumero),2,6)).
                        */
                        vobs[1] = fiscal.plaobs[1].
                        vobs[2] = fiscal.plaobs[2].
                        
                        if vobs[1] = "" and
                           fiscal.ipi > 0
                        then vobs[1] = "VALOR IPI: " + 
                                       string(fiscal.ipi,">>>,>>9.99").

                        if fiscal.opfcod = 1124 or
                           fiscal.opfcod = 1902 or
                           fiscal.opfcod = 2124 or
                           /*fiscal.opfcod = 2902   */
                           fiscal.opfcod = 1556 or
                           fiscal.opfcod = 1253 or
                           fiscal.opfcod = 1303 
                        then do:
                            val_contabil = val_contabil + fiscal.ipi.
                            
                            run /admcom/progr/trata_cfop.p (input vopccod, 
                                          input 0,
                                          input fiscal.platot, 
                                          input 0 /*fiscal.alicms*/,    
                                          input 0 /*fiscal.icms*/,     
                                          input 0,      
                                          output base_icms,   
                                          output visenta,   
                                          output voutras,   
                                          output vsittri, 
                                          output valicm).
                                          
                            if fiscal.opfcod = 1556 or
                               fiscal.opfcod = 1253 or
                               fiscal.opfcod = 1303
                            then vsittri = 090.
                            if vsittri = ?
                            then vsittri = 0.
                        end.
                               
                        if fiscal.opfcod = 1102 or
                           fiscal.opfcod = 2102 or
                           fiscal.opfcod = 1949 or
                           fiscal.opfcod = 2949
                        then do:
                            val_contabil = val_contabil + fiscal.ipi.
                            
                            run /admcom/progr/trata_cfop.p (input vopccod, 
                                          input 0,
                                          input (fiscal.platot - fiscal.ipi), 
                                          input fiscal.alicms,    
                                          input fiscal.icms,     
                                          input 0,      
                                          output base_icms,   
                                          output visenta,   
                                          output voutras,   
                                          output vsittri, 
                                          output valicm).
                            base_ipi = base_icms.    
                            if vsittri = ?
                            then vsittri = 0.          
                        end.
                           
                        valor_ipi =  round(((vipi / base_ipi) * 100),0).
                        if valor_ipi = ? then valor_ipi = 0.
                      
                        if visenta < 0 then visenta = 0.
 
                        if vdes = ? then vdes = 0.
                    
                        run put-2.
                    
                        assign 
                            basepis-capa = 0
                            valpis-capa = 0
                            valcofins-capa = 0
                            base_icms = 0
                            valicm = 0
                            visenta = 0
                            voutras = 0
                            base_subs = 0
                            valor_subs = 0
                            base_ipi = 0
                            valor_ipi = 0
                            vipi = 0
                            val_contabil = 0.
                    end.
                    ******************/
                end.
                /***** não plani
                else do: 
                    tot_pro = fiscal.platot.
                    vcodfis = "".
                    vsittri = 0.
                    base_subs  = 0.
                    valor_subs = 0.
                    base_ipi = 0.
                    
                    if fiscal.ipi > 0
                    then base_ipi = fiscal.platot.
                    if plani.bicms > 0
                    then base_icms = (fiscal.bicms / fiscal.platot) * 
                                (fiscal.platot).
                    else base_icms = 0.
                    
                    vdes = 0.
                    vipi  = 0.
                    vicms = base_icms * (fiscal.alicms / 100). 
                    val_contabil = fiscal.platot + vipi.
                    visenta = val_contabil - (fiscal.platot) - vipi.
                    if visenta < 0
                    then visenta.

                    voutras = val_contabil - fiscal.platot - vipi - visenta.
                    if voutras < 0
                    then voutras = 0.

                    vnumero = fiscal.numero. 
                    /*
                    if vnumero >= 1000000
                    then vnumero = int(substring(string(vnumero),2,6)).
                    */
                    if fiscal.opfcod = 1124 or
                       fiscal.opfcod = 2124 or
                       fiscal.opfcod = 2902 or
                       fiscal.opfcod = 1102 or
                       fiscal.opfcod = 2102 or
                       fiscal.opfcod = 1949 or
                       fiscal.opfcod = 2949
                    then do:
                        val_contabil = val_contabil + fiscal.ipi.
               
                        run /admcom/progr/trata_cfop.p (input vopccod, 
                                          input 0,
                                          input fiscal.platot, 
                                          input fiscal.alicms,    
                                          input fiscal.icms,     
                                          input 0,      
                                          output base_icms,   
                                          output visenta,   
                                          output voutras,   
                                          output vsittri, 
                                          output valicm).
                        if vsittri = ?
                        then vsittri = 0.
                    end.
                    
                    if fiscal.opfcod = 1902 or  
                       fiscal.opfcod = 1915 or 
                       fiscal.opfcod = 2915 
                    then voutras = val_contabil.
                                  
                    if /*vopccod = "1949" or 
                       vopccod = "2949" or*/
                       vopccod = "1253" or
                       vopccod = "1908" or
                       vopccod = "2908" or
                       vopccod = "1923" or
                       vopccod = "2923" or
                       vopccod = "2910" or
                       vopccod = "1910" 
                    then
                        if fiscal.bicms > 0
                        then assign base_icms = val_contabil
                                    voutras   = 0.
                        else assign base_icms = 0
                                    voutras   = val_contabil.    

                    vobs[1] = fiscal.plaobs[1].
                    vobs[2] = fiscal.plaobs[2].

                    if vobs[1] = "" and 
                       fiscal.ipi > 0
                    then vobs[1] = "VALOR IPI: " + 
                                   string(fiscal.ipi,">>>,>>9.99").

                    /*
                    tip-doc = "NF".
                    if v-mod = "08"
                    then assign tip-doc = "CTRC"
                                v-ser   = "U".
                    **/
                    
                    if visenta < 0 then visenta = 0.
                
                    run put-3.
                    
                   assign basepis-capa = 0
                          valpis-capa = 0
                          valcofins-capa = 0.
                end.
                ****************/
            end.                                 
        end.
    end.
    
    /**** TRANSFERENCIA ****/
    def var vtotalmov as dec.
    for each estab no-lock:
        
        /*
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
        */
        
        for each tipmov where 
                           tipmov.movtdc = 6 or
                           tipmov.movtdc = 9 or
                           tipmov.movtdc = 22 or
                           tipmov.movtdc = 34 or
                           tipmov.movtdc = 36 or
                           tipmov.movtdc = 54 no-lock,
            
            each plani where plani.movtdc = tipmov.movtdc and 
                             plani.desti  = estab.etbcod  and 
                             plani.pladat >= vdti         and
                             plani.pladat <= vdtf  no-lock:
/***
                             plani.datexp >= vdti         and
                             plani.datexp <= vdtf  no-lock:
***/
            
            if vimporta-lista                
            then do:
                if not can-find(first tt-imp
                                where tt-imp.etbcod = plani.desti
                                  and tt-imp.numero = plani.numero)
                then next.                  
            end.

            vmovtdc = tipmov.movtdc.
                             
            if plani.numero = 0
            then next.
                    
            if vnumero-nota > 0 and vnumero-nota <> plani.numero
            then next.
                               /*  
            if plani.protot = 0 and plani.movtdc <> 27 /*Ressarcimento ICMS*/
            then next.           */
            
            /*
            if plani.serie <> "1"
            then next.
            */
            
            if plani.modcod = "CAN"
            then next.
            
            find first bmovim where bmovim.etbcod = plani.etbcod and
                                    bmovim.placod = plani.placod and
                                    bmovim.movtdc = plani.movtdc and
                                    bmovim.movdat = plani.pladat
                                               no-lock no-error.
            if not avail bmovim
            then next.
            
            /*                                                
            if plani.serie = "U" or
               plani.serie = "U1" or
               plani.serie = "55" or
               plani.serie = "1"  /* incluido em 13/02/2012 para entrar as
                                     notas NFE desta serie */
            then.
            else next.
            */
            
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
            if plani.emite = 998 and
               plani.desti = 993 /*95*/
            then next.   
            if plani.emite = 995 and
               plani.desti = 991
            then next.
            if plani.emite = 991 and
               plani.desti = 995
            then next.   
        
            totpla = totpla + plani.platot.
            
            vemi = plani.emite.
            
            if vemi = 998
            then vemi = 993 /*95*/.
            if vemi = 991
            then vemi = 995.
            vdesti = plani.desti.
            if vdesti = 998
            then vdesti = 993 /*95*/.
            if vdesti = 991
            then vdesti = 995 .
             
            assign vopccod = string(plani.opccod).
             
            if length(vopccod) = 4
            then assign vopccod = "1" + substring(vopccod,2,3).
            else assign vopccod = "1152".
             
            vcod = "E" + string(vemi,"9999999") + "          ". 

            if plani.bicms > 0  
            then vali = int((plani.icms * 100) / plani.bicms). 
            else vali = 0.
            vmovseq = 0.
            find first bmovim where bmovim.etbcod = plani.etbcod and
                                    bmovim.placod = plani.placod and
                                    bmovim.movtdc = plani.movtdc and
                                    bmovim.movdat = plani.pladat 
                                                no-lock no-error.
            if avail bmovim  
            then do: 

            for each movim where movim.etbcod = plani.etbcod and
                                 movim.placod = plani.placod and
                                 movim.movtdc = plani.movtdc and
                                 movim.movdat = plani.pladat
                           no-lock
                           by movim.movseq :
                
                if movim.movqtm = 0 and plani.movtdc <> 6
                then next.
                  
                frete_item = 0. 
                if movim.movdev > 0 
                then frete_item = movim.movdev.
                
                /*        
                if movim.movpc = 0 or
                   movim.movqtm = 0
                then next.       
                */
                
                tot_pro = movim.movqtm * movim.movpc. 
                vcodfis = "". 
                vsittri = 0.
                    
                find produ where produ.procod = movim.procod no-lock no-error.
                if not avail produ 
                then next.
                                    
                if produ.codfis > 0
                then vcodfis = string(produ.codfis).
                if produ.codori > 0
                then vsittri = int(string(produ.codori) + string(produ.codtri)).
                    
                base_subs  = 0. 
                valor_subs = 0.
                    
                base_ipi = 0.                    
                if plani.ipi > 0 
                then base_ipi = (movim.movpc * movim.movqtm).

                if plani.protot > 0 and
                   plani.bicms > 0
                then base_icms = (plani.bicms / plani.protot) * 
                                   (movim.movpc * movim.movqtm).
                else base_icms = 0.
 
                vdes = (plani.descprod / plani.platot) * 
                       (movim.movpc * movim.movqtm).
                if vdes = ? then vdes = 0.           
                  
                vipi  = base_ipi  * (movim.movalipi / 100).
                vicms = base_icms * (movim.movalicms / 100). 
                
                if plani.ipi > 0 and plani.protot > 0
                then vipi = movim.movipi
                    /*vipi = plani.ipi * ((movim.movpc * movim.movqtm)
                                / plani.protot)*/.
                    
                val_contabil = (movim.movpc * movim.movqtm) + vipi.
                
                visenta = val_contabil - (movim.movpc * movim.movqtm) 
                              - vipi.
                if visenta < 0
                then visenta = 0.
                           
                voutras = val_contabil.

                vsittri = 51.
                
                if visenta < 0 then visenta = 0.
                    vmovalipi = movim.movalipi.
                if vmovalipi = ? then vmovalipi = 0.
                if vdes = ? then vdes = 0.
        
                run put-4.
            end.
            end. 
            else do:
                
                /*
                run recal-out.
                */
                
                tot_pro = plani.platot.
                vcodfis = "". 
                vsittri = 0.
                base_subs  = 0. 
                valor_subs = 0.
                base_ipi = 0.
                    
                if plani.ipi > 0 
                then base_ipi = plani.platot.

                if plani.protot > 0 and
                   plani.bicms > 0
                then base_icms = (plani.bicms / plani.protot) * 
                                      plani.platot.
                else base_icms = 0.
 
                vdes = (plani.descprod / plani.platot) * 
                       plani.platot.
                if vdes = ? then vdes = 0.           
                  
                vipi  = base_ipi  * (plani.alipi / 100).
                vicms = base_icms * (plani.alicms / 100). 
                
                val_contabil = plani.platot + vipi.
                visenta = val_contabil - plani.platot - vipi.
                
                if visenta < 0
                then visenta = 0.

                voutras = val_contabil.

                if visenta < 0 then visenta = 0.
        vmovalipi = plani.alipi.
        if vmovalipi = ? then vmovalipi = 0.
             
             run put-5.
             
            end.   
        end.  
    end.            
    
    /**************** energia eletrica ********************/
                
    /**
    for each estab where if vetbcod = 0 
                         then true  
                         else estab.etbcod = vetbcod no-lock:
                         
        for each plani where plani.movtdc = 11            and 
                             plani.desti  = estab.etbcod  and 
                             plani.datexp >= vdti         and
                             plani.datexp <= vdtf  no-lock:
            
            /**                     
            run recal-out.
            **/
            vmovseq = 0.
            nome_produto = "Credito 50% Energia Eletrica - Ref. Mes " +
                           string(month(plani.datexp),"99").

            totpla = totpla + plani.platot.

            
            vemi = plani.emite.
            if vemi = 998
            then vemi = 993 /*95*/.
            if vemi = 991
            then vemi = 995.
            vdesti = plani.desti.
            if vdesti = 998
            then vdesti = 993 /*95*/.
            if vdesti = 991
            then vdesti = 995.

            vopccod = "1949". 
            vcod = "E" + string(vemi,"9999999") + "          ". 

            if plani.bicms > 0  
            then vali = int((plani.icms * 100) / plani.bicms). 
            else vali = 0.
                
            tot_pro = plani.platot. 
            vcodfis = "".  
            vsittri = 0.
            base_subs  = 0. 
            valor_subs = 0.
            base_ipi = 0.
                   
            if plani.ipi > 0  
            then base_ipi = plani.platot.

            base_icms = plani.bicms.
     
 
                  
            vipi  = base_ipi  * (plani.alipi / 100). 
            vicms = base_icms * (plani.alicms / 100). 
                    
                    
            val_contabil = plani.platot + vipi.
            visenta = val_contabil - plani.platot - vipi.
                
            if visenta < 0
            then visenta = 0.

            voutras = val_contabil.
            
            find first bmovim where bmovim.etbcod = plani.etbcod and
                                    bmovim.placod = plani.placod and
                                    bmovim.movtdc = plani.movtdc and
                                    bmovim.movdat = plani.pladat 
                                                no-lock no-error.
            if avail bmovim  
            then do: 
                vcod = "F" + string(vemi,"9999999") + "          ". 

                for each movim where movim.etbcod = plani.etbcod and
                                     movim.placod = plani.placod and
                                     movim.movtdc = plani.movtdc and
                                     movim.movdat = plani.pladat no-lock:
                   
                    frete_item = 0. 
                    if movim.movdev > 0 
                    then frete_item = movim.movdev.
                    /*    
                    if movim.movpc = 0 or
                       movim.movqtm = 0
                    then next.       
                    */
                    tot_pro = movim.movqtm * movim.movpc. 
                    vcodfis = "". 
                    vsittri = 0.
                    
                    find produ where produ.procod = movim.procod 
                            no-lock no-error.
                                        
                    if not avail produ 
                    then next.
                    
                    if produ.codfis > 0
                    then vcodfis = string(produ.codfis).
                    if produ.codori > 0
                    then vsittri = int(string(produ.codori) + 
                                       string(produ.codtri)).
                    
                    base_subs  = 0. 
                    valor_subs = 0.
                    base_ipi = 0.
                    
                    if plani.ipi > 0 
                    then base_ipi = (movim.movpc * movim.movqtm).

                    if plani.protot > 0 and
                       plani.bicms > 0
                    then base_icms = (plani.bicms / plani.protot) * 
                                       (movim.movpc * movim.movqtm).
                    else base_icms = 0.                   
     
 
                    vdes = (plani.descprod / plani.platot) * 
                           (movim.movpc * movim.movqtm).
                    if vdes = ? then vdes = 0.       
                  
                    vipi  = base_ipi  * (movim.movalipi / 100).
                    vicms = base_icms * (movim.movalicms / 100). 
                    
                    if plani.ipi > 0 and plani.protot > 0
                    then  vipi = movim.movipi
                          /*vipi = plani.ipi * ((movim.movpc * movim,movqtm)
                            / plani.protot)*/.
                    
                    val_contabil = (movim.movpc * movim.movqtm) + vipi. 
                    visenta = val_contabil - (movim.movpc * movim.movqtm) 
                              - vipi.
                    
                    if visenta < 0
                    then visenta = 0.
                    voutras = val_contabil.
                    
                    
                    if plani.bicms > 0
                    then assign base_icms = val_contabil
                                voutras   = 0.
                    else assign base_icms = 0
                                voutras   = val_contabil.    
                
 
                    if length(vsittri) = 2
                            then vsittri = "0" + vsittri.
                            else if length(vsittri) = 1
                                then vsittri = "00" + vsittri.
                    if visenta < 0 then visenta = 0.
                     
                     run put-6.
                     
                end.
            end. 
            else do:
                if length(vsittri) = 2
                            then vsittri = "0" + vsittri.
                            else if length(vsittri) = 1
                                then vsittri = "00" + vsittri.
                if visenta < 0 then visenta = 0.
                run put-7.
            end.    
        end.  
    end.
    **/
    
    output close. 
    
    message color red/with
                  "Arquivo gerado: " skip
                                varquivo
                                              view-as alert-box.
                                              
    
end.    

procedure cal-base-icms:

def buffer vsb-movim for movim.
def buffer vsb-produ for produ.
def buffer vsb-prodnewfree for prodnewfree.
def buffer vsb-clafis for clafis.
def buffer vsb-forne for forne.

def var vsb-bicms as dec.
def var vsb-vicms as dec.
def var p-red     as dec.

find vsb-forne where vsb-forne.forcod = plani.emite no-lock no-error.

for each vsb-movim where
             vsb-movim.etbcod = plani.etbcod and
             vsb-movim.placod = plani.placod and
             vsb-movim.movtdc = plani.movtdc
             no-lock:
    find vsb-produ where vsb-produ.procod = vsb-movim.procod
                no-lock no-error.
    if not avail vsb-produ
    then find vsb-prodnewfree where vsb-prodnewfree.procod = vsb-movim.procod
                     no-lock no-error.
    if avail vsb-produ
    then find vsb-clafis where 
                  vsb-clafis.codfis = vsb-produ.codfis no-lock no-error.
    else if avail vsb-prodnewfree
    then find vsb-clafis where
                  vsb-clafis.codfis = vsb-prodnewfree.codfis no-lock no-error.
    if avail vsb-clafis and plani.movtdc = 4
    then p-red = vsb-clafis.perred.

    if not avail vsb-forne or vsb-forne.ufecod <> "RS"
    then p-red = 0.
        
    assign
        vsb-bicms = ((vsb-movim.movpc + vsb-movim.movdev - vsb-movim.movdes)
                    * vsb-movim.movqtm) * (1 - (p-red / 100))
        vsb-vicms = (((vsb-movim.movpc + vsb-movim.movdev - vsb-movim.movdes)
                    * vsb-movim.movqtm) * (1 - (p-red / 100)))
                    * (vsb-movim.movalicms / 100) .

    /*** 02/05/2014 ***/
    if movim.movbicms > 0
    then vsb-bicms = vsb-movim.movbicms.
    if movim.movicms > 0
    then vsb-vicms = vsb-movim.movicms.

    if (avail vsb-produ and vsb-produ.proipiper = 99) or
       (avail vsb-prodnewfree and vsb-prodnewfree.proipiper = 99)
    then assign
            vbicms99 = vbicms99 + vsb-bicms
            capa-icms-naocreditado = capa-icms-naocreditado + vsb-vicms.
    else assign
            vbicms00 = vbicms00 + vsb-bicms
            capa-icms-creditado = capa-icms-creditado + vsb-vicms.

    if avail movim and
       movim.procod = vsb-movim.procod
    then assign
            base_icms = vsb-bicms.    
end.

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
         find clafis where clafis.codfis = int(pcodfis) no-lock no-error.
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
                     clafis.codfis,
                     yes).
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
                            bxmovim.movdat = plani.pladat
                      no-lock:

        if tipmov.movtnota = no /* Digita */ or
           bxmovim.movpis > 0 or
           bxmovim.etbcod = 22 or
           bxmovim.etbcod > 900 or
           opcom.piscofins /*** 25/04/2014 ***/
        then assign
                val-pis    = bxmovim.movpis
                val-cofins = bxmovim.movcofins
                base-pis   = bxmovim.movbpiscof.
        else do.
            find produ where produ.procod = bxmovim.procod no-lock no-error.
            if not avail produ
            then next.
            run p-piscofins(produ.codfis,"E",
                      ((bxmovim.movpc /*- bxmovim.movdes*/) * bxmovim.movqtm)).
        end.                                

        assign valpis-capa    = valpis-capa  + val-pis
               valcofins-capa = valcofins-capa + val-cofins
               basepis-capa   = basepis-capa + base-pis.
    end.

    if plani.notpis > 0 or opcom.piscofins /*** 25/04/2014 ***/
    then assign
            valpis-capa    = plani.notpis
            valcofins-capa = plani.notcofins.

end procedure.


procedure put-1:

    def var v-mod-aux    as character.    

    if vimporta-lista
    then do:
        if not can-find(first tt-imp
                        where tt-imp.etbcod = plani.etbcod
                          and tt-imp.numero = plani.numero)
        then return.
    end.

    vmovseq = vmovseq + 1.
    
    /*Em notas de entrada, procura pelo emitente do plani.*/
    find first A01_InfNFe where
               A01_InfNFe.etbcod = plani.emite /*plani.etbcod*/ and
               A01_InfNFe.placod = plani.placod
                         no-lock no-error.
    if plani.serie = "55"
    then v-mod = "55".
    
    if (plani.etbcod = plani.desti
        or plani.emite = plani.desti)
        and v-tipo = "P"
    then v-mod = "55".

    {/admcom/progr/nf-situacao.i}

    assign
        ipi_capa = fiscal.ipi
        ipi_item = round(vipi,2).
    codigo-bc = "".

    if movim.movcstpiscof > 0
    then cst-piscofins = string(movim.movcstpiscof, "99") + 
                         string(movim.movcstpiscof, "99").

    find first clafis where clafis.codfis = int(vcodfis) no-lock no-error.

    if plani.movtdc = 4   /* Compra */
    then do:
        assign
            conta-pis = "4.1.01"
            conta-cofins = "4.1.01"
            codigo-bc = "01". 
        if per-pis = 0 and per-cofins = 0
        then assign
                cst-piscofins = "5353"
                tipo-credito   = "102".
        else assign
                cst-piscofins = "5050"
                tipo-credito   = "101".
    end.
    else if plani.movtdc = 11   /* Outras entradas */
         or vopccod = "1949"
    then do:
        assign
            conta-pis = "3.4.01.01"
            conta-cofins = "3.4.01.01"
            cst-piscofins = "9898"
            codigo-bc = "12" 
            basepis-capa = 0
            valpis-capa = 0
            valcofins-capa = 0.                                  

        if per-pis = 0 and per-cofins = 0
        then tipo-credito   = "102".
        else tipo-credito   = "101".
    end.
    else if plani.movtdc = 12   /* Devolução de Venda */
    then do:
        assign
            conta-pis    = tipmov.contapiscof /*"3.4.01.01"*/
            conta-cofins = tipmov.contapiscof /*"3.4.01.01"*/
            codigo-bc    = "12". 
        if per-pis = 0 and per-cofins = 0
        then tipo-credito   = "102".
        else tipo-credito   = "101".
    end.
    else if plani.movtdc = 37  /* Energia elétrica */
    then do:
        assign
            conta-pis = "5.1.01.02.045"
            conta-cofins = "5.1.01.02.045"
            cst-piscofins = "5353"
            tipo-credito = "199"
            codigo-bc = "04"
            per-pis = 1.65
            per-cofins = 7.6
            base-pis   = val_contabil
            val-pis    = val_contabil * (per-pis / 100)
            val-cofins = val_contabil * (per-cofins / 100).
    end.
    else if plani.movtdc = 51 /* Entrada de conserto */
    then
        assign
            cst-piscofins = "9898".
    
    if tipmov.movtnom matches("*estorno*")
    then
        assign
            cst-piscofins = "9898". 
    
    assign
        valor_subs = 0
        base_subs  = 0.

    assign
        capa-icms-naocreditado = 0
        capa-icms-creditado = 0
        vbicms00 = 0
        vbicms99 = 0.

    run cal-base-icms.

    if vbicms00 = 0 and
        plani.icms > 0 and
        plani.icmssubst > 0
    then capa-icms-naocreditado = plani.icms.

    if (avail produ and produ.proipiper = 99) or
       (avail prodnewfree and prodnewfree.proipiper = 99)
    then do:
        if plani.icmssubst > 0 and vbicms99 > 0
        then assign
                valor_subs = if movim.movsubst > 0
                             then movim.movsubst
                             else plani.icmssubst *
                                ((movim.movpc * movim.movqtm) / plani.protot)
                base_subs = if movim.movbsubst > 0
                            then movim.movbsubst
                            else plani.bsubst *
                             ((movim.movpc * movim.movqtm) / plani.protot).
                tot-bicmscapa = tot-bicmscapa - base_icms.
    end.

    if plani.movtdc = 27
    then assign valor_subs = plani.icmssubst.

    if base_subs = 0 and plani.bsubst > 0
    then base_subs = plani.bsubst.

    val_contabil = val_contabil + valor_subs.
    
    /* Quando tem chave de acesso NFE e o modelo ainda é 01 troca para 55 */
    if v-mod = "01"
        and (length(plani.ufdes) = 44
            or (avail A01_InfNFe and length(A01_InfNFe.id) = 44))
    then assign v-mod-aux = "55".
    else assign v-mod-aux = v-mod.
    
    assign vplani_etbcod = plani.etbcod.
    
    if vplani_etbcod = 998
    then vplani_etbcod = 993.
    if vplani_etbcod = 991
    then vplani_etbcod = 995.

    if vcod = "E0000998"
    then vcod = "E0000993".
    
    if vcod = "E0000991"
    then vcod = "E0000995".

    if vobs[1] = ?
    then assign vobs[1] = "".

    if vobs[2] = ?
    then assign vobs[2] = "".

    if base_icms = ?
    then assign base_icms = 0.
    
    if visenta = ?
    then assign visenta = 0.
    
    find first clafis where clafis.codfis = int(vcodfis) no-lock no-error.
    
    find opcom where opcom.opccod = vopccod no-lock no-error.
    if avail opcom and opcom.piscofins = no
    then assign
                 per-pis = 0
                 per-cofins = 0
                 base-pis   = 0
                 val-pis    = 0
                 val-cofins = 0
                 basepis-capa = 0
                 valpis-capa = 0
                 valcofins-capa = 0
                 cst-piscofins =  string(opcom.cstpiscofins,"99")
                                  + string(opcom.cstpiscofins,"99").

    find first tabaux where
               tabaux.tabela = "OPCOM" + vopccod and
               tabaux.nome_campo = "Codigo Base de credito Pis e Cofins"
               no-lock no-error.
    if avail tabaux
    then codigo-bc = tabaux.valor_campo.
    
    if vopccod = "1303"
    then v-mod-aux = "22".      
    
    if tot-basesubst = ? then tot-basesubst = 0.
    if base_subs = ? then base_subs = 0.
    if valor_subs = ? then valor_subs = 0.
    if valicm = ? then valicm = 0.
              
    if val_contabil = base_icms
    then assign voutras = 0
                visenta = 0.
    visenta = 0.
    if val_contabil > base_icms
    then voutras = val_contabil - base_icms.
    
    tot-bicmscapa = plani.bicms.
    def var vpronom like produ.pronom.
    def var vproipiper like produ.proipiper.
    vproipiper = 0.
    find produ where produ.procod = movim.procod no-lock no-error.
    if not avail produ
    then find  prodnewfree where 
                   prodnewfree.procod = movim.procod no-lock no-error.
    if avail produ
    then assign
            vproipiper = produ.proipiper
            vpronom = produ.pronom.
    else if avail prodnewfree
        then assign
                vproipiper = prodnewfree.proipiper
                vpronom = prodnewfree.pronom.
        
    if vproipiper = 99
    then do:
        item-icms-naocreditado = ((movim.movpc + movim.movdev) * movim.movqtm) *
                (movim.movalicms / 100).
    end.    
    else item-icms-naocreditado = 0.

    if capa-icms-naocreditado = ? then capa-icms-naocreditado = 0.
    if item-icms-naocreditado = ? then item-icms-naocreditado = 0.
    if capa-icms-creditado = ? then capa-icms-creditado = 0.
    
    valicm = base_icms * (movim.movalicms / 100).
    if valicm = ? then valicm = 0.
    
    find first clafis where clafis.codfis = produ.codfis no-lock no-error.

 
    def var s-movpc as char format "x(15)".
    def var s-movqt as char format "x(15)".
    def var s-total as char format "x(15)".
    def var s-bicms as char format "x(15)".
    def var s-vicms as char format "x(15)".
    def var s-aicms as char format "x(15)".
    def var s-bsubs as char format "x(15)".
    def var s-vsubs as char format "x(15)".
    def var s-mvaes as char format "x(15)".
    def var s-mvaoe as char format "x(15)".
    def var s-apis as char  format "x(15)".
    def var s-acofins as char format "x(15)".
    def var s-bipi as char format "x(15)".
    def var s-aipi as char format "x(15)".
    def var s-vipi as char format "x(15)".
    
    if valor_item < 0 then valor_item = 0.
    if base_icms < 0 then base_icms = 0. 
    if valicm < 0 then valicm = 0.
    assign
    s-movpc = string(round(valor_item,4),"->>>,>>>,>>9.99")
    s-movpc = replace(s-movpc,",","")
    s-movpc = replace(s-movpc,".",",")
    s-movqt = string(movim.movqtm,"->>>,>>>,>>9.99")
    s-movqt = replace(s-movqt,",","")
    s-movqt = replace(s-movqt,".",",")
    s-total = string(round((valor_item * movim.movqtm),2),"->>>,>>>,>>9.99")
    s-total = replace(s-total,",","")
    s-total = replace(s-total,".",",")
    s-bicms = if vproipiper <> 99  
              then string(round(base_icms,2),"->>>,>>>,>>9.99")
              else string(0.00,"->>>,>>>,>>9.99")
    s-bicms = replace(s-bicms,",","")
    s-bicms = replace(s-bicms,".",",")
    s-aicms = if movim.movalicms <> ? and vproipiper <> 99 
              then string(movim.movalicms,"->>>,>>>,>>9.99")
              else string(0.00,"->>>,>>>,>>9.99")
    s-aicms = replace(s-aicms,",","")
    s-aicms = replace(s-aicms,".",",")
    s-vicms = if vproipiper <> 99 
              then string(round(valicm,2),"->>>,>>>,>>9.99")
              else string(0.00,"->>>,>>>,>>9.99")
    s-vicms = replace(s-vicms,",","")
    s-vicms = replace(s-vicms,".",",")
    s-bsubs = if vproipiper <> 99 
              then string(round(base_subs,2),"->>>,>>>,>>9.99")
              else string(0.00,"->>>,>>>,>>9.99")
    s-bsubs = replace(s-bsubs,",","")
    s-bsubs = replace(s-bsubs,".",",")
    s-vsubs = if vproipiper <> 99 
              then string(round(valor_subs,2),"->>>,>>>,>>9.99")
              else string(0.00,"->>>,>>>,>>9.99")
    s-vsubs = replace(s-vsubs,",","")
    s-vsubs = replace(s-vsubs,".",",")
    s-mvaes = if avail clafis 
              then string(clafis.mva_estado1,"->>>,>>>,>>9.99")
              else string(0.00,"->>>,>>>,>>9.99")
    s-mvaes = replace(s-mvaes,",","")
    s-mvaes = replace(s-mvaes,".",",")
    s-mvaoe = if avail clafis 
              then string(clafis.mva_oestado1,"->>>,>>>,>>9.99")
              else string(0.00,"->>>,>>>,>>9.99")
    s-mvaoe = replace(s-mvaoe,",","")
    s-mvaoe = replace(s-mvaoe,".",",")
    s-apis  = string(per-pis,"->>>,>>>,>>9.99")
    s-apis  = replace(s-apis,",","")
    s-apis  = replace(s-apis,".",",")
    s-acofins = string(per-cofins,"->>>,>>>,>>9.99") 
    s-acofins = replace(s-acofins,",","")
    s-acofins = replace(s-acofins,".",",")
    s-bipi  = string(round((valor_item * movim.movqtm),2),"->>>,>>>,>>9.99")
    s-bipi  = replace(s-bipi,",","")
    s-bipi  = replace(s-bipi,".",",")
    s-aipi  = string(movim.movalipi,"->>>,>>>,>>9.99")  
    s-aipi  = replace(s-aipi,",","")
    s-aipi  = replace(s-aipi,".",",")
    s-vipi  = string(ipi_item,"->>,>>>,>>9.99")
    s-vipi  = replace(s-vipi,",","")
    s-vipi  = replace(s-vipi,".",",")
    .  
 

 put unformatted 
        string(vplani_etbcod,">>9")             
        vsep   
        v-tipo  format "x(1)"       
        vsep 
        string(plani.numero,">>>>>>>>9")  
        vsep
        fiscal.plarec format "99/99/9999" 
        vsep 
        /**********************
        vcod format "x(18)" 
        vsep
        fiscal.platot 
        vsep 
        /* 081-096 */   desc_capa format "9999999999999.99" 
        /* 097-112 */   protot_capa     format "9999999999999.99". 

        if vproipiper <> 99 or valor_subs = 0
        then put /* 113-128 */  capa-icms-creditado format "9999999999999.99".
        else put                0                   format "9999999999999.99".

        put  /* 129-144 */   0 /*fiscal.ipi*/      format "9999999999999.99".
        put
        /* 145-160 */   0 format "9999999999999.99".

        put 
        /* 161-180 */   ie_subst_trib   format "x(20)" 
        /* 181-196 */   plani.frete    format "9999999999999.99" 
        /* 197-212 */   plani.seguro   format "9999999999999.99" 
        /* 213-228 */   plani.desacess format "9999999999999.99"  
        /* 229-243 */   "RODOVIARIO"   format "x(15)" 
        /* 244-246 */   "CIF"          format "x(3)"  
        /* 247-264 */   " " format "x(18)" 
        /* 265-280 */   "0000000000000.00" 
        /* 281-290 */   "UNIDADE" format "x(10)"  
        /* 291-306 */   "000000000000.000" 
        /* 307-322 */   "000000000000.000" 
        /* 323-339 */   " " format "x(17)" 
        /* 340-355 */   plani.vlserv format "9999999999999.99" 
        /* 356-362 */   "0000.00" 
        /* 363-378 */   "0000000000000.00" 
        /* 379-394 */   "0000000000000.00"  
        /* 395-410 */   "0000000000000.00"  
        /* 411-426 */   "0000000000000.00"  
        /* 427-442 */   "0000000000000.00"  
        /* 443-458 */   "0000000000000.00"  
        /* 459-474 */   "0000000000000.00"  
        /* 475-490 */   "0000000000000.00"  
        /* 491-506 */   "0000000000000.00"  
        /* 507-522 */   basepis-capa   format "9999999999999.99"  
        /* 523-538 */   valpis-capa    format "9999999999999.99"  
        /* 539-554 */   basepis-capa   format "9999999999999.99"  
        /* 555-570 */   valcofins-capa format "9999999999999.99"  
        /* 571-670 */   vobs[1] format "x(50)" 
        /* 571-670 */   vobs[2] format "x(50)" 
        /* 671-700 */   " " format "x(30)"
        /* 701-701 */   " " format "x(1)"  
        **********************/
        vopccod format "x(6)"
        vsep
        movim.procod format ">>>>>>>>>9"
        vsep 
        vpronom 
        vsep
        vcodfis format "x(10)" 
       /* vsep
        vsittri format "999"  
        */
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
        s-bsubs
        vsep
        s-vsubs
        vsep
        s-mvaes
        vsep
        s-mvaoe
        vsep
        s-apis 
        vsep  
        s-acofins 
        vsep
        s-bipi
        vsep
        s-aipi
        vsep
        s-vipi  
        skip.

        assign
            tot-bicmscapa = 0
            ind-complementar = ""
            ind-situacao = ""
            ind-tiponota = ""
            obs-complementar = ""
            cod-observacao = ""
            cod-obsfiscal = ""
            tot-basesubst = 0
            ind-movestoque = ""
            ipi_capa = 0
            ipi_item = 0
            ipi_retido = 0
            cof_retido = 0
            dat_conclu = ""
            nat_frete = ""
            tipo_cte = ""
            dat_contingencia = ""
            hor_contingencia = ""
            mot_contingencia = ""
            ccc_fiscal = ""
            cst-piscofins = ""
            tipo-credito = ""
            codigo-bc = ""
            conta-pis = ""
            conta-cofins = ""
            base-pis = 0
            per-pis = 0
            val-pis = 0
            per-cofins = 0
            val-cofins = 0.

end procedure.

/********************
procedure put-2:

    if vimporta-lista
    then do:
        if not can-find(first tt-imp
                        where tt-imp.etbcod = plani.etbcod
                          and tt-imp.numero = plani.numero)
        then return.
    end.
        
    assign
        ipi_capa = fiscal.ipi
        ipi_item = vipi
        vmovseq  = vmovseq + 1.

    find A01_InfNFe where
                         A01_InfNFe.etbcod = plani.etbcod and
                         A01_InfNFe.placod = plani.placod
                         no-lock no-error.
    if avail A01_InfNFe and vsittri = 0
    then do:
        find first I01_prod of A01_InfNFe 
                where I01_prod.cprod = string(produ.procod) no-lock no-error.
        if avail I01_prod
        then do:
            find N01_icms of I01_Prod no-lock no-error.
            if avail N01_icms
            then
              vsittri = int(string(N01_icms.orig) + string(int(N01_icms.cst))).
        end.            
    end.

    find first tipmovaux where
                           tipmovaux.movtdc = plani.movtdc and
                           tipmovaux.nome_campo = "Modelo-Documento"
                           no-lock no-error.
    if avail tipmovaux
    then v-mod = tipmovaux.valor_campo.

    if plani.serie = "55"
    then v-mod = "55".
    
    if (plani.etbcod = plani.desti
        or plani.emite = plani.desti)
        and v-tipo = "P"
    then v-mod = "55".
    
    {/admcom/progr/nf-situacao.i}
        
    if plani.movtdc = 4   /* Compra */
    then do:
        assign
            conta-pis = "4.1.01"
            conta-cofins = "4.1.01"
            codigo-bc = "01". 
        if per-pis = 0 and per-cofins = 0
        then assign
                cst-piscofins = "5353"
                tipo-credito   = "102".
        else assign
                cst-piscofins = "5050"
                tipo-credito   = "101".
    end.
    else if plani.movtdc = 12   /* Devolução de Venda */
    then do:
        assign
            conta-pis = "3.4.01.01"
            conta-cofins = "3.4.01.01"
            cst-piscofins = "9898"
            codigo-bc = "12"
            . 
        if per-pis = 0 and per-cofins = 0
        then tipo-credito   = "102".
        else tipo-credito   = "101".
    end.
    else if plani.movtdc = 37  /* Energia elétrica */
    then do:
        assign
            conta-pis = "5.1.01.02.045"
            conta-cofins = "5.1.01.02.045"
            cst-piscofins = "5353"
            tipo-credito = "199"
            codigo-bc = "04"
            per-pis = 1.65
            per-cofins = 7.6
            base-pis    = val_contabil
            val-pis    = val_contabil * (per-pis / 100)
            val-cofins = val_contabil * (per-cofins / 100)
            basepis-capa = base-pis
            valpis-capa  = val-pis
            valcofins-capa = val-cofins
            v-mod = "06"
            tipo-documento = "NFEE".
    end.
        
    assign vestab_etbcod = estab.etbcod.
    
    if vestab_etbcod = 998
    then vestab_etbcod = 993.
    if vestab_etbcod = 991
    then vestab_etbcod = 995.
    
    if vcod = "E0000998"
    then vcod = "E0000993".
    
    if vcod = "E0000991"
    then vcod = "E0000995".

    if vobs[1] = ?
    then assign vobs[1] = "".
    
    if vobs[2] = ?
    then assign vobs[2] = "".
    
    if base_icms = ?
    then assign base_icms = 0.

    if visenta = ?
    then assign visenta = 0.

    find opcom where opcom.opccod = vopccod no-lock no-error.
    if avail opcom and  not opcom.piscofins
    then assign
                 per-pis = 0
                 per-cofins = 0
                 base-pis   = 0
                 val-pis    = 0
                 val-cofins = 0
                 basepis-capa = 0
                 valpis-capa = 0
                 valcofins-capa = 0
                 cst-piscofins =  string(opcom.cstpiscofins,"99")
                  + string(opcom.cstpiscofins,"99").
    find first tabaux where
               tabaux.tabela = "OPCOM" + vopccod and
               tabaux.nome_campo = "Codigo Base de credito Pis e Cofins"
               no-lock no-error.
    if avail tabaux
    then codigo-bc = tabaux.valor_campo.
    
    if vopccod = "1303"
    then v-mod = "22".
    
    if tot-basesubst = ? then tot-basesubst = 0.
    if base_subs = ? then base_subs = 0.
    if valor_subs = ? then valor_subs = 0.
    if valicm = ? then valicm = 0.
    
    if val_contabil = base_icms
    then assign voutras = 0
                visenta = 0.
    visenta = 0.
    voutras = val_contabil - base_icms.

    valor_subs = plani.icmssubs.
    base_subs = plani.bsubst.
    /*
    message base_subs valor_subs. pause.
    */
    put unformatted 
            /* 001-003 */   string(vestab_etbcod,">>9")    
            /* 004-004 */   "T"  format "x(1)"                            
            /* 005-006 */   v-mod format "x(2)"  
            /* 007-011 */   tipo-documento format "x(05)"            
            /* 012-016 */   v-ser  format "x(05)"           
            /* 017-028 */   string(vnumero,">>>>>>999999") 
            /* 029-036 */   string(year(fiscal.plaemi),"9999")  
            /* 029-036 */   string(month(fiscal.plaemi),"99") 
            /* 029-036 */   string(day(fiscal.plaemi),"99") 
            /* 037-044 */   string(year(fiscal.plarec),"9999") 
            /* 037-044 */   string(month(fiscal.plarec),"99") 
            /* 037-044 */   string(day(fiscal.plarec),"99") 
            /* 045-062 */   vcod format "x(18)" 
            /* 063-063 */   ind-cancelada format "x(1)"        
            /* 064-064 */   "V" format "x(1)" 
            /* 065-080 */   fiscal.platot   format "9999999999999.99" 
            /* 081-096 */   "0000000000000.00" 
            /* 097-112 */   fiscal.platot  format "9999999999999.99". 

            if valor_subs = 0  and avail fiscal
            then put /* 113-128 */   fiscal.icms format "9999999999999.99".
            else put 0 format "9999999999999.99".

            put 
            /* 129-144 */   0 /*fiscal.ipi*/      format "9999999999999.99" 
            /* 145-160 */   "0000000000000.00"  
            /* 161-180 */   ie_subst_trib format "x(20)" 
            /* 181-196 */   "0000000000000.00" 
            /* 197-212 */   "0000000000000.00" 
            /* 213-228 */   plani.desacess format "9999999999999.99"  
            /* 229-243 */   "RODOVIARIO"   format "x(15)" 
            /* 244-246 */   "CIF"          format "x(3)"  
            /* 247-264 */   " " format "x(18)" 
            /* 265-280 */   "0000000000000.00" 
            /* 281-290 */   "UNIDADE" format "x(10)"  
            /* 291-306 */   "000000000000.000" 
            /* 307-322 */   "000000000000.000" 
            /* 323-339 */   " " format "x(17)" 
            /* 340-355 */   "0000000000000.00" 
            /* 356-362 */   "0000.00" 
            /* 363-378 */   "0000000000000.00" 
            /* 379-394 */   "0000000000000.00"  
            /* 395-410 */   "0000000000000.00"  
            /* 411-426 */   "0000000000000.00"  
            /* 427-442 */   "0000000000000.00"  
            /* 443-458 */   "0000000000000.00"  
            /* 459-474 */   "0000000000000.00"  
            /* 475-490 */   "0000000000000.00"  
            /* 491-506 */   "0000000000000.00"  
            /* 507-522 */   basepis-capa format "9999999999999.99"
            /* 523-538 */   valpis-capa  format "9999999999999.99"
            /* 539-554 */   basepis-capa format "9999999999999.99"
            /* 555-570 */   valcofins-capa format "9999999999999.99"
            /* 571-670 */   vobs[1] format "x(50)" 
            /* 571-670 */   vobs[2] format "x(50)" 
            /* 671-700 */   " " format "x(30)"
            /* 701-701 */   " " format "x(1)"  
            /* 702-721 */   " " format "x(20)"  /*codigo do produto*/
            /* 722-766 */   " " format "x(45)" 
            /* 767-772 */   vopccod format "x(6)" 
            /* 773-778 */   " " format "x(6)" 
            /* 779-788 */   vcodfis format "x(10)" 
            /* 789-791 */   vsittri format "999"  
            /* 792-807 */   "00000000001.0000"
            /* 808-810 */   "UN" format "x(3)" 
            /* 811-826 */   fiscal.platot   format "99999999999.9999" 
            /* 827-842 */   fiscal.platot   format "99999999999.9999" 
            /* 843-858 */   vdes format "9999999999999.99"  
            /* 859-859 */   " " format "x(1)".
            if valor_subs > 0
            then put 0 format "9999999999999.99" .
            else put
            /* 860-875 */   base_icms       format "9999999999999.99".
            if valor_subs > 0
            then put 0 format "9999.99" .
            else put  
            /* 876-882 */   fiscal.alicms format "9999.99".       
            if valor_subs = 0
            then put
            /*883-898 */   valicm /*vicms*/ format "9999999999999.99".
            else put 0 format "9999999999999.99".
            put 
            /* 899-914 */   visenta      format "9999999999999.99" 
            /* 915-930 */   voutras      format "9999999999999.99". 
            if valor_subs = 0
            then put
            /* 931-946 */   base_subs    format "9999999999999.99".
            else put 0 format "9999999999999.99".
            if valor_subs = 0
            then put 
            /* 947-962 */   valor_subs   format "9999999999999.99".
            else put 0 format "9999999999999.99".
            put 
            /* 963-963 */   " " format "x(1)"  
            /* 964-979 */   0 /*base_ipi*/ format "9999999999999.99" 
            /* 980-986 */   0 /*valor_ipi*/ format "9999.99" 
            /* 987-1002 */  0 /*vipi*/ format "9999999999999.99" 
            /* 1003-1018 */ "0000000000000.00" 
            /* 1019-1034 */ "0000000000000.00" 
            /* 1035-1050 */ "0000000000000.00" 
            /* 1051-1066 */ "0000000000000.00" 
            /* 1067-1073 */ "0000.00"    
            /* 1074-1089 */ "0000000000000.00"  
            /* 1090-1105 */ "0000000000000.00"
            /* 1106-1112 */ "0000.00"  
            /* 1113-1128 */ "0000000000000.00" 
            /* 1129-1144 */ "0000000000000.00" 
            /* 1145-1151 */ "0000.00"  
            /* 1152-1167 */ "0000000000000.00" 
            /* 1168-1183 */ "0000000000000.00"
            /* 1184-1190 */ "0000.00"
            /* 1191-1206 */ "0000000000000.00"
            /* 1207-1220 */ " " format "x(14)"
            /* 1221-1236 */ base-pis format "9999999999999.99" 
            /* 1237-1243 */ per-pis format "9999.99"  
            /* 1244-1259 */ val-pis format "9999999999999.99"  
            /* 1260-1275 */ base-pis format "9999999999999.99"  
            /* 1276-1282 */ per-cofins format "9999.99"  
            /* 1283-1298 */ val-cofins format "9999999999999.99" 
            /* 1299-1314 */ val_contabil format "9999999999999.99" 
            /* 1315-1330 */ "0000000000000.00"
            /* 1331      */ cst-piscofins format "x(4)" .
            if valor_subs = 0 
            then put
            /* 1335      */ tot-bicmscapa format "9999999999999.99".
            else put 0 format "9999999999999.99".
            put
            /* 1351      */ "" format "x"
            /* 1352      */ "" format "xx"
            /* 1354      */ ind-complementar format "x"
            /* 1355      */ ind-situacao        format "xx"
            /* 1357      */ "" format "x"
            /* 1358      */ ind-tiponota format "x"
            /* 1359      */ obs-complementar format "x(254)"
            /* 1613      */ cod-observacao   format "x(6)"
            /* 1619      */ cod-obsfiscal    format "x(6)".
            if valor_subs = 0
            then put
            /* 1625      */ tot-basesubst    format "9999999999999.99".
            else put 0 format "9999999999999.99".
            put
            /* 1641      */ ind-movestoque   format "x".
            /* 1642      */ if avail plani and length(plani.ufdes) > 30
                then put plani.ufdes format "x(44)".
                else if avail A01_InfNFe
                then put A01_InfNFe.id format "x(44)".
                else put " " format "x(44)".
            /* 1686      */ put " " format "x(28)" .
            /* 1714      */ put ipi_capa format "99999999999999.99"
            /* 1731      */     ipi_item format "99999999999999.99"
            /* 1748      */     ipi_retido format "9999.99"
            /* 1755      */     cof_retido format "9999.99"
            /* 1762      */     dat_conclu format "x(8)"
            /* 1770      */     nat_frete format "x"
            /* 1771      */     tipo_cte format "x"
            /* 1772      */     dat_contingencia format "x(8)"
            /* 1780      */     hor_contingencia format "x(10)"
            /* 1790      */     mot_contingencia format "x(254)"
            /* 2044      */     ccc_fiscal format "x(2)"
            /* 2046      */     "0"
            /* 2047      */     "0"
            /* 2048      */     " " format "x(28)"
            /* 2076      */     " " format "x(6)"
            /* 2082      */     " " format "x(6)"
            /* 2088      */   /*tipo-credito*/ " " format "x(3)"
            /* 2091      */     codigo-bc format "x(2)"
            /* 2093      */     conta-pis     format "x(28)"
            /* 2121      */     conta-cofins  format "x(28)"
            /* 2149      */     " " format "x(2)"
            /* 2151      */     string(vmovseq,">>>9") format "x(4)"
            /* 2160      */     "PUT-2"      at  2160  
            /* 2170      */     vmovtdc      at 2170.
        put tot-basesubst   at 2190 format "9999999999999.99"
                 plani.icmssubst at 2206 format "9999999999999.99"
                 valicm  at 2222 format "9999999999999.99"
                 .
        if valor_subs > 0
        then put         
                 base_subs       at 2238 format "9999999999999.99"
                 valor_subs      at 2254 format "9999999999999.99"
                 valicm          at 2270 format "9999999999999.99"
                 .
        else put /*0 at 2190 format "9999999999999.99"
                 0 at 2206 format "9999999999999.99"
                 0 at 2222 format "9999999999999.99"*/
                 0 at 2238 format "9999999999999.99"
                 0 at 2254 format "9999999999999.99"
                 0 at 2270 format "9999999999999.99"
                 .

        put skip.

        assign
            tot-bicmscapa = 0
            ind-complementar = ""
            ind-situacao = ""
            ind-tiponota = ""
            obs-complementar = ""
            cod-observacao = ""
            cod-obsfiscal = ""
            tot-basesubst = 0
            ind-movestoque = ""
            ipi_capa = 0
            ipi_item = 0
            ipi_retido = 0
            cof_retido = 0
            dat_conclu = ""
            nat_frete = ""
            tipo_cte = ""
            dat_contingencia = ""
            hor_contingencia = ""
            mot_contingencia = ""
            ccc_fiscal = ""
            basepis-capa = 0
            valpis-capa = 0
            valcofins-capa = 0
            cst-piscofins = ""
            tipo-credito = ""
            codigo-bc = ""
            conta-pis = ""
            conta-cofins = ""
            base-pis = 0
            per-pis = 0
            val-pis = 0
            per-cofins = 0
            val-cofins = 0.

end procedure.
 
procedure put-3:

    if vimporta-lista
    then do:
        if not can-find(first tt-imp
                        where tt-imp.etbcod = plani.etbcod
                          and tt-imp.numero = plani.numero)
        then return.
    end.
            
    assign
        ipi_capa = fiscal.ipi
        ipi_item = vipi
        vmovseq = vmovseq + 1.
    /*
    if fiscal.serie = "55"
    then do:
        find A01_InfNFe where
                         A01_InfNFe.emite = fiscal.plaemi and
                         A01_InfNFe.serie = " 55" and   
                         A01_InfNFe.numero = fiscal.numero
                         no-lock no-error.
        v-mod = "55".
    end. */

    if fiscal.emite = fiscal.desti
        and v-tipo = "P"
    then v-mod = "55".
    
    {/admcom/progr/nf-situacao.i}
    
    if fiscal.movtdc = 4   /* Compra */
    then do:
        assign
            conta-pis = "4.1.01"
            conta-cofins = "4.1.01"
            codigo-bc = "01". 
        if per-pis = 0 and per-cofins = 0
        then assign
                cst-piscofins = "5353"
                tipo-credito   = "102".
        else assign
                cst-piscofins = "5050"
                tipo-credito   = "101".
    end.
    else if fiscal.movtdc = 12   /* Devolução de Venda */
    then do:
        assign
            conta-pis = "3.4.01.01"
            conta-cofins = "3.4.01.01"
            cst-piscofins = "9898"
            codigo-bc = "12". 
        if per-pis = 0 and per-cofins = 0
        then tipo-credito   = "102".
        else tipo-credito   = "101".
    end.
    else if plani.movtdc = 37  /* Energia elétrica */
    then do:
        assign
            conta-pis = "5.1.01.02.045"
            conta-cofins = "5.1.01.02.045"
            cst-piscofins = "5353"
            tipo-credito = "199"
            codigo-bc = "04"
            per-pis = 1.65
            per-cofins = 7.6
            base-pis   = val_contabil
            val-pis    = val_contabil * (per-pis / 100)
            val-cofins = val_contabil * (per-cofins / 100)
            basepis-capa = val_contabil
            valpis-capa = val_contabil * (per-pis / 100)
            valcofins-capa = val_contabil * (per-cofins / 100).
    end.
    
    assign vestab_etbcod = estab.etbcod.
    
    if vestab_etbcod = 998
    then vestab_etbcod = 993.
    if vestab_etbcod = 991
    then vestab_etbcod = 995.

    if vcod = "E0000998"
    then vcod = "E0000993".
    
    if vcod = "E0000991"
    then vcod = "E0000995".

    if vobs[1] = ?
    then assign vobs[1] = "".
    
    if vobs[2] = ?
    then assign vobs[2] = "".
    
    if base_icms = ?
    then assign base_icms = 0.
     
    if visenta = ?
    then assign visenta = 0.

    find opcom where opcom.opccod = vopccod no-lock no-error.
    if avail opcom and  not opcom.piscofins
    then assign
                 per-pis = 0
                 per-cofins = 0
                 base-pis   = 0
                 val-pis    = 0
                 val-cofins = 0
                 basepis-capa = 0
                 valpis-capa = 0
                 valcofins-capa = 0
                 cst-piscofins =  string(opcom.cstpiscofins,"99")
                  + string(opcom.cstpiscofins,"99").
    find first tabaux where
               tabaux.tabela = "OPCOM" + vopccod and
               tabaux.nome_campo = "Codigo Base de credito Pis e Cofins"
               no-lock no-error.
    if avail tabaux
    then codigo-bc = tabaux.valor_campo.
    
    if vopccod = "1303"
    then v-mod = "22".
    
    if tot-basesubst = ? then tot-basesubst = 0.
    if base_subs = ? then base_subs = 0.
    if valor_subs = ? then valor_subs = 0.
    if valicm = ? then valicm = 0.
    
    if val_contabil = base_icms
    then assign voutras = 0
                visenta = 0
                .
    visenta = 0.
    voutras = val_contabil - base_icms.

    put unformatted 
        /* 001-003 */   string(vestab_etbcod,">>9")    
        /* 004-004 */   v-tipo format "x(1)"                            
        /* 005-006 */   v-mod  format "x(2)"  
        /* 007-011 */   tipo-documento format "x(05)"            
        /* 012-016 */   v-ser  format "x(05)"           
        /* 017-028 */   string(vnumero,">>>>>>999999") 
        /* 029-036 */   string(year(fiscal.plaemi),"9999")  
        /* 029-036 */   string(month(fiscal.plaemi),"99") 
        /* 029-036 */   string(day(fiscal.plaemi),"99") 
        /* 037-044 */   string(year(fiscal.plarec),"9999") 
        /* 037-044 */   string(month(fiscal.plarec),"99") 
        /* 037-044 */   string(day(fiscal.plarec),"99") 
        /* 045-062 */   vcod format "x(18)" 
        /* 063-063 */   ind-cancelada format "x(1)"        
        /* 064-064 */   "V" format "x(1)" 
        /* 065-080 */   fiscal.platot   format "9999999999999.99" 
        /* 081-096 */   "0000000000000.00" 
        /* 097-112 */   fiscal.platot  format "9999999999999.99". 
        if valor_subs = 0 and avail fiscal
        then put
        /* 113-128 */   fiscal.icms     format "9999999999999.99".
        else put 0 format "9999999999999.99".
        put 
        /* 129-144 */   0 /*fiscal.ipi*/      format "9999999999999.99" 
        /* 145-160 */   "0000000000000.00"  
        /* 161-180 */   " " format "x(20)" 
        /* 181-196 */   "0000000000000.00" 
        /* 197-212 */   "0000000000000.00" 
        /* 213-228 */   "0000000000000.00"  
        /* 229-243 */   "RODOVIARIO"   format "x(15)" 
        /* 244-246 */   "CIF"          format "x(3)"  
        /* 247-264 */   " " format "x(18)" 
        /* 265-280 */   "0000000000000.00" 
        /* 281-290 */   "UNIDADE" format "x(10)"  
        /* 291-306 */   "000000000000.000" 
        /* 307-322 */   "000000000000.000" 
        /* 323-339 */   " " format "x(17)" 
        /* 340-355 */   "0000000000000.00" 
        /* 356-362 */   "0000.00" 
        /* 363-378 */   "0000000000000.00" 
        /* 379-394 */   "0000000000000.00"  
        /* 395-410 */   "0000000000000.00"  
        /* 411-426 */   "0000000000000.00"  
        /* 427-442 */   "0000000000000.00"  
        /* 443-458 */   "0000000000000.00"  
        /* 459-474 */   "0000000000000.00"  
        /* 475-490 */   "0000000000000.00"  
        /* 491-506 */   "0000000000000.00"  
        /* 507-522 */   basepis-capa format "9999999999999.99"  
        /* 523-538 */   valpis-capa  format "9999999999999.99"  
        /* 539-554 */   basepis-capa format "9999999999999.99"  
        /* 555-570 */   valcofins-capa format "9999999999999.99"  
        /* 571-670 */   vobs[1] format "x(50)" 
        /* 571-670 */   vobs[2] format "x(50)" 
        /* 671-700 */   " " format "x(30)"
        /* 701-701 */   " " format "x(1)"  
        /* 702-721 */   " " format "x(20)" 
        /* 722-766 */   " " format "x(45)" 
        /* 767-772 */   vopccod format "x(6)" 
        /* 773-778 */   " " format "x(6)" 
        /* 779-788 */   vcodfis format "x(10)" 
        /* 789-791 */   vsittri format "999"  
        /* 792-807 */   "00000000001.0000"
        /* 808-810 */   "UN" format "x(3)" 
        /* 811-826 */   fiscal.platot   format "99999999999.9999" 
        /* 827-842 */   fiscal.platot   format "99999999999.9999" 
        /* 843-858 */   vdes format "9999999999999.99"  
        /* 859-859 */   " " format "x(1)"
        /* 860-875 */   base_icms       format "9999999999999.99" 
        /* 876-882 */   fiscal.alicms format "9999.99" .      
        if valor_subs = 0
        then put
        /* 883-898 */   vicms format "9999999999999.99" .
        else  put 0 format "9999999999999.99".
        put
        /* 899-914 */   visenta      format "9999999999999.99" 
        /* 915-930 */   voutras      format "9999999999999.99". 
        if valor_subs = 0
        then put
        /* 931-946 */   base_subs    format "9999999999999.99" .
        else put 0 format "9999999999999.99".
        if valor_subs = 0
        then put
        /* 947-962 */   valor_subs   format "9999999999999.99".
        else put 0 format "9999999999999.99".
        put 
        /* 963-963 */   " " format "x(1)"  
        /* 964-979 */   0 /*base_ipi*/ format "9999999999999.99" 
        /* 980-986 */   "0000.00" 
        /* 987-1002 */  0 /*vipi*/ format "9999999999999.99" 
        /* 1003-1018 */ "0000000000000.00" 
        /* 1019-1034 */ "0000000000000.00" 
        /* 1035-1050 */ "0000000000000.00" 
        /* 1051-1066 */ "0000000000000.00" 
        /* 1067-1073 */ "0000.00"    
        /* 1074-1089 */ "0000000000000.00"  
        /* 1090-1105 */ "0000000000000.00"
        /* 1106-1112 */ "0000.00"  
        /* 1113-1128 */ "0000000000000.00" 
        /* 1129-1144 */ "0000000000000.00" 
        /* 1145-1151 */ "0000.00"  
        /* 1152-1167 */ "0000000000000.00" 
        /* 1168-1183 */ "0000000000000.00"
        /* 1184-1190 */ "0000.00"
        /* 1191-1206 */ "0000000000000.00"
        /* 1207-1220 */ " " format "x(14)"
        /* 1221-1236 */ base-pis format "9999999999999.99" 
        /* 1237-1243 */ per-pis format "9999.99"  
        /* 1244-1259 */ val-pis format "9999999999999.99"  
        /* 1260-1275 */ base-pis format "9999999999999.99"  
        /* 1276-1282 */ per-cofins format "9999.99"  
        /* 1283-1298 */ val-cofins format "9999999999999.99" 
        /* 1299-1314 */ val_contabil format "9999999999999.99" 
        /* 1315-1330 */ "0000000000000.00"
            /* 1331      */ /*vcodsit*/ cst-piscofins format "x(4)" 
            /* 1335      */ tot-bicmscapa format "9999999999999.99"
            /* 1351      */ "" format "x"
            /* 1352      */ "" format "xx"
            /* 1354      */ ind-complementar format "x"
            /* 1355      */ ind-situacao        format "xx"
            /* 1357      */ "" format "x"
            /* 1358      */ ind-tiponota format "x"
            /* 1359      */ obs-complementar format "x(254)"
            /* 1613      */ cod-observacao   format "x(6)"
            /* 1619      */ cod-obsfiscal    format "x(6)".
            if valor_subs = 0
            then put
            /* 1625      */ tot-basesubst    format "9999999999999.99".
            else put 0 format "9999999999999.99".
            put
            /* 1641      */ ind-movestoque   format "x".
            /* 1642      */ if avail plani and length(plani.ufdes) > 30
                then put plani.ufdes format "x(44)".
                else if avail A01_InfNFe
                then put A01_InfNFe.id format "x(44)".
                else put " " format "x(44)".
        /* 1686      */ put " " format "x(28)" .
        /* 1714      */ put ipi_capa format "99999999999999.99"
        /* 1731      */     ipi_item format "99999999999999.99"
        /* 1748      */     ipi_retido format "9999.99"
        /* 1755      */     cof_retido format "9999.99"
        /* 1762      */     dat_conclu format "x(8)"
        /* 1770      */     nat_frete format "x"
        /* 1771      */     tipo_cte format "x"
        /* 1772      */     dat_contingencia format "x(8)"
        /* 1780      */     hor_contingencia format "x(10)"
        /* 1790      */     mot_contingencia format "x(254)"
        /* 2044      */     ccc_fiscal format "x(2)"
        /* 2046      */     "0"
        /* 2047      */     "0"
        /* 2048      */     " " format "x(28)"
        /* 2076      */     " " format "x(6)"
        /* 2082      */     " " format "x(6)"
        /* 2088      */   /*tipo-credito*/ " " format "x(3)"
        /* 2091      */     codigo-bc format "x(2)"
        /* 2093      */     conta-pis     format "x(28)"
        /* 2121      */     conta-cofins  format "x(28)"
        /* 2149      */     " " format "x(2)"
        /* 2151      */     string(vmovseq,">>>9") format "x(4)"
        /* 2160      */     "PUT-3"      at 2160         
        /* 2170      */     vmovtdc      at 2170 .
        put tot-basesubst   at 2190 format "9999999999999.99"
                 plani.icmssubst at 2206 format "9999999999999.99"
                 0     at 2222 format "9999999999999.99"
                .
        if valor_subs > 0
        then put         
                 base_subs       at 2238 format "9999999999999.99"
                 valor_subs      at 2254 format "9999999999999.99"
                 vicms          at 2270 format "9999999999999.99"
                 .
        else put /*0 at 2190 format "9999999999999.99"
                 0 at 2206 format "9999999999999.99"
                 0 at 2222 format "9999999999999.99"*/
                 0 at 2238 format "9999999999999.99"
                 0 at 2254 format "9999999999999.99"
                 0 at 2270 format "9999999999999.99"
                 .
        put skip.

        assign
            tot-bicmscapa = 0
            ind-complementar = ""
            ind-situacao = ""
            ind-tiponota = ""
            obs-complementar = ""
            cod-observacao = ""
            cod-obsfiscal = ""
            tot-basesubst = 0
            ind-movestoque = ""
            ipi_capa = 0
            ipi_item = 0
            ipi_retido = 0
            cof_retido = 0
            dat_conclu = ""
            nat_frete = ""
            tipo_cte = ""
            dat_contingencia = ""
            hor_contingencia = ""
            mot_contingencia = ""
            ccc_fiscal = ""
            basepis-capa = 0
            valpis-capa = 0
            basepis-capa = 0
            valcofins-capa = 0
            cst-piscofins = ""
            tipo-credito = ""
            codigo-bc = ""
            conta-pis = ""
            conta-cofins = ""
            base-pis = 0
            per-pis = 0
            val-pis = 0
            per-cofins = 0
            val-cofins = 0
            .

end procedure.
****************************/

procedure put-4:

    def var vdatexp like plani.datexp.

    if vimporta-lista
    then do:
        if not can-find(first tt-imp
                        where tt-imp.etbcod = plani.etbcod
                          and tt-imp.numero = plani.numero)
        then return.
    end.
    
    assign
        ipi_capa = plani.ipi
        ipi_item = vipi
        vmovseq  = vmovseq + 1
        vdatexp  = plani.datexp.
    
    find A01_InfNFe where
                         A01_InfNFe.etbcod = plani.emite and
                         A01_InfNFe.placod = plani.placod
                         no-lock no-error.
    if avail A01_InfNFe and vsittri = 0
    then do:
        find first I01_prod of A01_InfNFe 
                where I01_prod.cprod = string(produ.procod) no-lock no-error.
        if avail I01_prod
        then do:
            find N01_icms of I01_Prod no-lock no-error.
            if avail N01_icms
            then do:
                vsittri = int(string(N01_icms.orig) +     
                                string(int(N01_icms.cst),"99")).
            end.     
        end.            
    end.

    
    /*
    if plani.serie = "55" 
    then v-mod = "55".
    */
    
    if ((plani.etbcod = plani.desti
        or plani.emite = plani.desti)
        and v-tipo = "P")
        or plani.movtdc = 6 /* NF TRANSFERENCIA */
    then v-mod = "55".
    
    if (plani.etbcod = plani.desti
        or plani.emite = plani.desti)
        and v-tipo = "P"
    then v-mod = "55".

    {/admcom/progr/nf-situacao.i}
    /*
    if ind-situacao = "02" then next.
    */

    if plani.movtdc = 4   /* Compra */
    then do:
        assign
            conta-pis = "4.1.01"
            conta-cofins = "4.1.01"
            codigo-bc = "01"
            . 
        if per-pis = 0 and per-cofins = 0
        then assign
                cst-piscofins = "5353"
                tipo-credito   = "102".
        else assign
                cst-piscofins = "5050"
                tipo-credito   = "101".
    end.
    else if plani.movtdc = 12   /* Devolução de Venda */
    then do:
        assign
            conta-pis = "3.4.01.01"
            conta-cofins = "3.4.01.01"
            cst-piscofins = "9898"
            codigo-bc = "12"
            . 
        if per-pis = 0 and per-cofins = 0
        then tipo-credito   = "102".
        else tipo-credito   = "101".
    end.
    else if plani.movtdc = 37  /* Energia elétrica */
    then do:
        assign
            conta-pis = "5.1.01.02.045"
            conta-cofins = "5.1.01.02.045"
            cst-piscofins = "5353"
            tipo-credito = "199"
            codigo-bc = "04"
            per-pis = 1.65
            per-cofins = 7.6
            base-pis    = val_contabil
            val-pis    = val_contabil * (per-pis / 100)
            val-cofins = val_contabil * (per-cofins / 100)
            .
    end.
    else if plani.movtdc = 6 /*tranferencia*/
    then do:
        assign
            conta-pis = "3.4.01.01"
            conta-cofins = "3.4.01.01"
            cst-piscofins = "9898"
            tipo-credito = "199"
            codigo-bc = "12"
            vdatexp = plani.pladat. 
    end.        
    else if plani.movtdc = 9
    then do:
        assign
            conta-pis = "3.4.01.01"
            conta-cofins = "3.4.01.01"
            cst-piscofins = "9898"
            tipo-credito = "199"
            codigo-bc = "12"
            . 
    end.
    def var valicms like movim.movalicms.
    def var vmovicms like movim.movicms.
    valicms = movim.movalicms.
    if valicms = ?
    then valicms = 0.
    
    if valicms = 0
    then vmovicms = 0.
    else vmovicms = ((movim.movpc * movim.movqtm) * 
                         (valicms / 100)).
    
    if vcod = "E0000998"
    then vcod = "E0000993".
    
    if vcod = "E0000991"
    then vcod = "E0000995".
    
    if base_icms = ?
    then assign base_icms = 0.

    if visenta = ?
    then assign visenta = 0.
    
    find opcom where opcom.opccod = vopccod no-lock no-error.
    if avail opcom and  not opcom.piscofins
    then assign
                 per-pis = 0
                 per-cofins = 0
                 base-pis   = 0
                 val-pis    = 0
                 val-cofins = 0
                 basepis-capa = 0
                 valpis-capa = 0
                 valcofins-capa = 0
                 cst-piscofins =  string(opcom.cstpiscofins,"99")
                  + string(opcom.cstpiscofins,"99")
                 .

    find first tabaux where
               tabaux.tabela = "OPCOM" + vopccod and
               tabaux.nome_campo = "Codigo Base de credito Pis e Cofins"
               no-lock no-error.
    if avail tabaux
    then codigo-bc = tabaux.valor_campo.
                         
    if vopccod = "1303"
    then v-mod = "22".
    
    if tot-basesubst = ? then tot-basesubst = 0.
    if base_subs = ? then base_subs = 0.
    if valor_subs = ? then valor_subs = 0.
    if valicm = ? then valicm = 0.
    
    if val_contabil = base_icms
    then assign voutras = 0
                visenta = 0
                .
    visenta = 0.
    voutras = val_contabil - base_icms.

    find first clafis where clafis.codfis = int(vcodfis) no-lock no-error.
    

        def var s-movpc as char format "x(15)".
    def var s-movqt as char format "x(15)".
    def var s-total as char format "x(15)".
    def var s-bicms as char format "x(15)".
    def var s-vicms as char format "x(15)".
    def var s-aicms as char format "x(15)".
    def var s-bsubs as char format "x(15)".
    def var s-vsubs as char format "x(15)".
    def var s-mvaes as char format "x(15)".
    def var s-mvaoe as char format "x(15)".
    def var s-apis as char  format "x(15)".
    def var s-acofins as char format "x(15)".
    def var s-bipi as char format "x(15)".
    def var s-aipi as char format "x(15)".
    def var s-vipi as char format "x(15)".
    
    if valor_item < 0 then valor_item = 0.
    if base_icms < 0 then base_icms = 0. 
    if valicm < 0 then valicm = 0.
    assign
    s-movpc = string(round(valor_item,4),"->>>,>>>,>>9.99")
    s-movpc = replace(s-movpc,",","")
    s-movpc = replace(s-movpc,".",",")
    s-movqt = string(movim.movqtm,"->>>,>>>,>>9.99")
    s-movqt = replace(s-movqt,",","")
    s-movqt = replace(s-movqt,".",",")
    s-total = string(round((valor_item * movim.movqtm),2),"->>>,>>>,>>9.99")
    s-total = replace(s-total,",","")
    s-total = replace(s-total,".",",")
    s-bicms = if produ.proipiper <> 99  
              then string(round(base_icms,2),"->>>,>>>,>>9.99")
              else string(0.00,"->>>,>>>,>>9.99")
    s-bicms = replace(s-bicms,",","")
    s-bicms = replace(s-bicms,".",",")
    s-aicms = if movim.movalicms <> ? and produ.proipiper <> 99 
              then string(movim.movalicms,"->>>,>>>,>>9.99")
              else string(0.00,"->>>,>>>,>>9.99")
    s-aicms = replace(s-aicms,",","")
    s-aicms = replace(s-aicms,".",",")
    s-vicms = if produ.proipiper <> 99 
              then string(round(valicm,2),"->>>,>>>,>>9.99")
              else string(0.00,"->>>,>>>,>>9.99")
    s-vicms = replace(s-vicms,",","")
    s-vicms = replace(s-vicms,".",",")
    s-bsubs = if produ.proipiper <> 99 
              then string(round(base_subs,2),"->>>,>>>,>>9.99")
              else string(0.00,"->>>,>>>,>>9.99")
    s-bsubs = replace(s-bsubs,",","")
    s-bsubs = replace(s-bsubs,".",",")
    s-vsubs = if produ.proipiper <> 99 
              then string(round(valor_subs,2),"->>>,>>>,>>9.99")
              else string(0.00,"->>>,>>>,>>9.99")
    s-vsubs = replace(s-vsubs,",","")
    s-vsubs = replace(s-vsubs,".",",")
    s-mvaes = if avail clafis 
              then string(clafis.mva_estado1,"->>>,>>>,>>9.99")
              else string(0.00,"->>>,>>>,>>9.99")
    s-mvaes = replace(s-mvaes,",","")
    s-mvaes = replace(s-mvaes,".",",")
    s-mvaoe = if avail clafis 
              then string(clafis.mva_oestado1,"->>>,>>>,>>9.99")
              else string(0.00,"->>>,>>>,>>9.99")
    s-mvaoe = replace(s-mvaoe,",","")
    s-mvaoe = replace(s-mvaoe,".",",")
    s-apis  = string(per-pis,"->>>,>>>,>>9.99")
    s-apis  = replace(s-apis,",","")
    s-apis  = replace(s-apis,".",",")
    s-acofins = string(per-cofins,"->>>,>>>,>>9.99") 
    s-acofins = replace(s-acofins,",","")
    s-acofins = replace(s-acofins,".",",")
    s-bipi  = string(round((movim.movpc * movim.movqtm),2),"->>>,>>>,>>9.99")
    s-bipi  = replace(s-bipi,",","")
    s-bipi  = replace(s-bipi,".",",")
    s-aipi  = string(movim.movalipi,"->>>,>>>,>>9.99")  
    s-aipi  = replace(s-aipi,",","")
    s-aipi  = replace(s-aipi,".",",")
    s-vipi  = string(ipi_retido,"->>,>>>,>>9.99")
    s-vipi  = replace(s-vipi,",","")
    s-vipi  = replace(s-vipi,".",",")
    .  
 
 put unformatted 
        string(vplani_etbcod,">>9")             
        vsep   
        v-tipo  format "x(1)"       
        vsep 
        string(plani.numero,">>>>>>>>9")  
        vsep
        plani.dtinclu format "99/99/9999" 
        vsep 
        vopccod format "x(6)"
        vsep
        movim.procod format ">>>>>>>>>9"
        vsep 
        produ.pronom 
        vsep
        vcodfis format "x(10)" 
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
        s-bsubs
        vsep
        s-vsubs
        vsep
        s-mvaes
        vsep
        s-mvaoe
        vsep
        s-apis 
        vsep  
        s-acofins 
        vsep
        s-bipi
        vsep
        s-aipi
        vsep
        s-vipi  
        skip.

    /*
    put unformatted 
        string(vdesti,">>9")
        vsep    
        "T"   
        vsep                           
        plani.numero format ">>>>>>>>9"
        vsep
        vdatexp format "99/99/9999"
        vsep  
        movim.procod format ">>>>>>>>>9"
        vsep
        produ.pronom
        vsep 
        vopccod format "x(6)" 
        vsep
        vcodfis 
        vsep 
        vsittri 
        vsep  
        movim.movqtm  
        vsep
        movim.movpc 
        vsep                 
        (movim.movpc * movim.movqtm) 
        vsep
        base_icms
        vsep       
        valicms
        vsep 
        if valor_subs = 0
        then vmovicms else 0
        if valor_subs = 0
        then base_subs else 0
        vsep
        if valor_subs = 0
        then valor_subs else 0
        vsep
        if avail clafis
        then clafis.mva_estado1 else 0
        vsep
        if avail clafis 
        then clafis.mva_oestado1 else 0
        vsep
        per-pis  
        vsep  
        per-cofins 
        vsep  
        (movim.movpc * movim.movqtm)
        vsep
        ipi_item  
        vsep
        ipi_retido   
        skip
        .
      ****/
      
        assign
            tot-bicmscapa = 0
            ind-complementar = ""
            ind-situacao = ""
            ind-tiponota = ""
            obs-complementar = ""
            cod-observacao = ""
            cod-obsfiscal = ""
            tot-basesubst = 0
            ind-movestoque = ""
            ipi_capa = 0
            ipi_item = 0
            ipi_retido = 0
            cof_retido = 0
            dat_conclu = ""
            nat_frete = ""
            tipo_cte = ""
            dat_contingencia = ""
            hor_contingencia = ""
            mot_contingencia = ""
            ccc_fiscal = ""
            basepis-capa = 0
            valpis-capa = 0
            basepis-capa = 0
            valcofins-capa = 0
            cst-piscofins = ""
            tipo-credito = ""
            codigo-bc = ""
            conta-pis = ""
            conta-cofins = ""
            base-pis = 0
            per-pis = 0
            val-pis = 0
            per-cofins = 0
            val-cofins = 0
            .
 
end procedure.

/*************************
procedure put-5:

    if vimporta-lista
    then do:
        
        if not can-find(first tt-imp
                        where tt-imp.etbcod = plani.etbcod
                          and tt-imp.numero = plani.numero)
        then return.
    end.
     
    assign
        ipi_capa = plani.ipi
        ipi_item = vipi
        vmovseq = vmovseq + 1.
        .


    /*
    find A01_InfNFe where
                         A01_InfNFe.etbcod = plani.etbcod and
                         A01_InfNFe.placod = plani.placod
                         no-lock no-error.
    if plani.serie = "55"
    then v-mod = "55".
    */

    
    if (plani.etbcod = plani.desti
        or plani.emite = plani.desti)
        and v-tipo = "P"
    then v-mod = "55".

    {/admcom/progr/nf-situacao.i}

    if plani.movtdc = 4   /* Compra */
    then do:
        assign
            conta-pis = "4.1.01"
            conta-cofins = "4.1.01"
            codigo-bc = "01"
            . 
        if per-pis = 0 and per-cofins = 0
        then assign
                cst-piscofins = "5353"
                tipo-credito   = "102".
        else assign
                cst-piscofins = "5050"
                tipo-credito   = "101".
    end.
    else if plani.movtdc = 12   /* Devolução de Venda */
    then do:
        assign
            conta-pis = "3.4.01.01"
            conta-cofins = "3.4.01.01"
            cst-piscofins = "9898"
            codigo-bc = "12"
            . 
        if per-pis = 0 and per-cofins = 0
        then tipo-credito   = "102".
        else tipo-credito   = "101".
    end.
    else if plani.movtdc = 37  /* Energia elétrica */
    then do:
        assign
            conta-pis = "5.1.01.02.045"
            conta-cofins = "5.1.01.02.045"
            cst-piscofins = "5353"
            tipo-credito = "199"
            codigo-bc = "04"
            per-pis = 1.65
            per-cofins = 7.6
            base-pis    = val_contabil
            val-pis    = val_contabil * (per-pis / 100)
            val-cofins = val_contabil * (per-cofins / 100)
            .
    end.
        
    if vcod = "E0000998"
    then vcod = "E0000993".
    
    if vcod = "E0000991"
    then vcod = "E0000995".

    if base_icms = ?
    then assign base_icms = 0.

    if visenta = ?
    then assign visenta = 0.

    find opcom where opcom.opccod = vopccod no-lock no-error.
    if avail opcom and  not opcom.piscofins
    then assign
                 per-pis = 0
                 per-cofins = 0
                 base-pis   = 0
                 val-pis    = 0
                 val-cofins = 0
                 basepis-capa = 0
                 valpis-capa = 0
                 valcofins-capa = 0
                 cst-piscofins =  string(opcom.cstpiscofins,"99")
                  + string(opcom.cstpiscofins,"99")
                 .
    find first tabaux where
               tabaux.tabela = "OPCOM" + vopccod and
               tabaux.nome_campo = "Codigo Base de credito Pis e Cofins"
               no-lock no-error.
    if avail tabaux
    then codigo-bc = tabaux.valor_campo.
    
    if tot-basesubst = ? then tot-basesubst = 0.
    if base_subs = ? then base_subs = 0.
    if valor_subs = ? then valor_subs = 0.
    if valicm = ? then valicm = 0.

    if val_contabil = base_icms
    then assign voutras = 0
                visenta = 0
                .
    visenta = 0.
    voutras = val_contabil - base_icms.

    put unformatted 
        /* 001-003 */   string(vdesti,">>9")    
        /* 004-004 */   "T"  format "x(1)"                            
        /* 005-006 */   "01" format "x(2)"  
        /* 007-011 */   "NF" format "x(05)"            
        /* 012-016 */   "01"  format "x(05)"           
        /* 017-028 */   string(plani.numero,">>>>>>999999") 
        /* 029-036 */   string(year(plani.datexp),"9999")  
        /* 029-036 */   string(month(plani.datexp),"99") 
        /* 029-036 */   string(day(plani.datexp),"99") 
        /* 037-044 */   string(year(plani.datexp),"9999") 
        /* 037-044 */   string(month(plani.datexp),"99") 
        /* 037-044 */   string(day(plani.datexp),"99") 
        /* 045-062 */   vcod format "x(18)" 
        /* 063-063 */   " " format "x(1)" 
        /* 064-064 */   "V" format "x(1)" 
        /* 065-080 */   plani.platot   format "9999999999999.99" 
        /* 081-096 */   plani.descprod format "9999999999999.99" 
        /* 097-112 */   plani.protot   format "9999999999999.99". 
        if valor_subs = 0
        then put
        /* 113-128 */   plani.icms     format "9999999999999.99".
        else put 0 format "9999999999999.99".
        put 
        /* 129-144 */   0 /*plani.ipi*/      format "9999999999999.99". 
        if valor_subs = 0
        then put
        /* 145-160 */   plani.icmssubst format "9999999999999.99".
        else put 0 format "9999999999999.99".
        put  
        /* 161-180 */   " " format "x(20)" 
        /* 181-196 */   plani.frete    format "9999999999999.99" 
        /* 197-212 */   plani.seguro   format "9999999999999.99" 
        /* 213-228 */   "0000000000000.00"  
        /* 229-243 */   "RODOVIARIO"   format "x(15)" 
        /* 244-246 */   "CIF"          format "x(3)"  
        /* 247-264 */   " " format "x(18)" 
        /* 265-280 */   "0000000000000.00" 
        /* 281-290 */   "UNIDADE" format "x(10)"  
        /* 291-306 */   "000000000000.000" 
        /* 307-322 */   "000000000000.000" 
        /* 323-339 */   " " format "x(17)" 
        /* 340-355 */   plani.vlserv format "9999999999999.99" 
        /* 356-362 */   "0000.00" 
        /* 363-378 */   "0000000000000.00" 
        /* 379-394 */   "0000000000000.00"  
        /* 395-410 */   "0000000000000.00"  
        /* 411-426 */   "0000000000000.00"  
        /* 427-442 */   "0000000000000.00"  
        /* 443-458 */   "0000000000000.00"  
        /* 459-474 */   "0000000000000.00"  
        /* 475-490 */   "0000000000000.00"  
        /* 491-506 */   "0000000000000.00"  
        /* 507-522 */   "0000000000000.00"  
        /* 523-538 */   "0000000000000.00"  
        /* 539-554 */   "0000000000000.00"  
        /* 555-570 */   "0000000000000.00"  
        /* 571-670 */   plani.notobs[1] format "x(50)" 
        /* 571-670 */   plani.notobs[2] format "x(50)" 
        /* 671-700 */   " " format "x(30)"
        /* 701-701 */   " " format "x(1)"  
        /* 702-721 */   " " format "x(20)" 
        /* 722-766 */   " " format "x(45)" 
        /* 767-772 */   vopccod format "x(6)" 
        /* 773-778 */   " " format "x(6)" 
        /* 779-788 */   vcodfis format "x(10)" 
        /* 789-791 */   vsittri format "999"  
        /* 792-807 */   "00000000001.0000"
        /* 808-810 */   "UN" format "x(3)" 
        /* 811-826 */   plani.platot format "99999999999.9999" 
        /* 827-842 */   plani.platot format "99999999999.9999" 
        /* 843-858 */   vdes format "9999999999999.99"  
        /* 859-859 */   " " format "x(1)"
        /* 860-875 */   base_icms       format "9999999999999.99" .
        
        if avail movim
        then
        put
        /* 876-882 */   movim.movalicms format "9999.99"       .
        else
         put
          /* 876-882 */ " " format "9999.99".
        if valor_subs = 0
        then   put  
         /* 883-898 */   (plani.platot * 
                        (movim.movalicms / 100)) format "9999999999999.99".
        else put 0 format "9999999999999.99".
        put                 
        /* 899-914 */   visenta      format "9999999999999.99" 
        /* 915-930 */   voutras      format "9999999999999.99". 
        if valor_subs = 0
        then put
        /* 931-946 */   base_subs    format "9999999999999.99".
        else put 0 format "9999999999999.99".
        if valor_subs = 0
        then put 
        /* 947-962 */   valor_subs   format "9999999999999.99".
        else put 0 format "9999999999999.99".
        put 
        /* 963-963 */   " " format "x(1)"  
        /* 964-979 */   0 /*base_ipi*/ format "9999999999999.99" 
        /* 980-986 */   0 /*vmovalipi*/ format "9999.99" 
        /* 987-1002 */  0 /*vipi*/ format "9999999999999.99" 
        /* 1003-1018 */ "0000000000000.00" 
        /* 1019-1034 */ "0000000000000.00" 
        /* 1035-1050 */ "0000000000000.00" 
        /* 1051-1066 */ "0000000000000.00" 
        /* 1067-1073 */ "0000.00"    
        /* 1074-1089 */ "0000000000000.00"  
        /* 1090-1105 */ "0000000000000.00"
        /* 1106-1112 */ "0000.00"  
        /* 1113-1128 */ "0000000000000.00" 
        /* 1129-1144 */ "0000000000000.00" 
        /* 1145-1151 */ "0000.00"  
        /* 1152-1167 */ "0000000000000.00" 
        /* 1168-1183 */ "0000000000000.00"
        /* 1184-1190 */ "0000.00"
        /* 1191-1206 */ "0000000000000.00"
        /* 1207-1220 */ " " format "x(14)"
        /* 1221-1236 */ base-pis format "9999999999999.99" 
        /* 1237-1243 */ per-pis format "9999.99"  
        /* 1244-1259 */ val-pis format "9999999999999.99"  
        /* 1260-1275 */ base-pis format "9999999999999.99"  
        /* 1276-1282 */ per-cofins format "9999.99"  
        /* 1283-1298 */ val-cofins format "9999999999999.99" 
        /* 1299-1314 */ val_contabil format "9999999999999.99" 
        /* 1315-1330 */ "0000000000000.00"
        /* 1331      */ cst-piscofins format "x(4)" 
            /* 1335      */ tot-bicmscapa format "9999999999999.99"
            /* 1351      */ "" format "x"
            /* 1352      */ "" format "xx"
            /* 1354      */ ind-complementar format "x"
            /* 1355      */ ind-situacao        format "xx"
            /* 1357      */ "" format "x"
            /* 1358      */ ind-tiponota format "x"
            /* 1359      */ obs-complementar format "x(254)"
            /* 1613      */ cod-observacao   format "x(6)"
            /* 1619      */ cod-obsfiscal    format "x(6)".
            if valor_subs = 0
            then put
            /* 1625      */ tot-basesubst    format "9999999999999.99".
            else put 0 format "9999999999999.99".
            put
            /* 1641      */ ind-movestoque   format "x".
            /* 1642      */ if avail plani and length(plani.ufdes) > 30
                then put plani.ufdes format "x(44)".
                else if avail A01_InfNFe
                then put A01_InfNFe.id format "x(44)".
                else put " " format "x(44)".
         /* 1686      */ put " " format "x(28)" .
        /* 1714      */ put ipi_capa format "99999999999999.99"
        /* 1731      */     ipi_item format "99999999999999.99"
        /* 1748      */     ipi_retido format "9999.99"
        /* 1755      */     cof_retido format "9999.99"
        /* 1762      */     dat_conclu format "x(8)"
        /* 1770      */     nat_frete format "x"
        /* 1771      */     tipo_cte format "x"
        /* 1772      */     dat_contingencia format "x(8)"
        /* 1780      */     hor_contingencia format "x(10)"
        /* 1790      */     mot_contingencia format "x(254)"
        /* 2044      */     ccc_fiscal format "x(2)"
        /* 2046      */     "0"
        /* 2047      */     "0"
        /* 2048      */     " " format "x(28)"
        /* 2076      */     " " format "x(6)"
        /* 2082      */     " " format "x(6)"
        /* 2088      */   /*tipo-credito*/ " " format "x(3)"
        /* 2091      */     codigo-bc format "x(2)"
        /* 2093      */     conta-pis     format "x(28)"
        /* 2121      */     conta-cofins  format "x(28)"
        /* 2149      */     " " format "x(2)"
        /* 2151      */     string(vmovseq,">>>9") format "x(4)"
        /* 2160      */     "PUT-5"      at 2160 
        /* 2170      */     vmovtdc      at 2170.
        put tot-basesubst   at 2190 format "9999999999999.99"
                 plani.icmssubst at 2206 format "9999999999999.99"
                 0     at 2222 format "9999999999999.99"
            .
        if valor_subs > 0
        then put
                 base_subs       at 2238 format "9999999999999.99"
                 valor_subs      at 2254 format "9999999999999.99"
                 (plani.platot *  (movim.movalicms / 100)) 
                        at 2270 format "9999999999999.99"
                 .
        else put /*0 at 2190 format "9999999999999.99"
                 0 at 2206 format "9999999999999.99"
                 0 at 2222 format "9999999999999.99"*/
                 0 at 2238 format "9999999999999.99"
                 0 at 2254 format "9999999999999.99"
                 0 at 2270 format "9999999999999.99"
                 .
                    
        put skip.

        assign
            tot-bicmscapa = 0
            ind-complementar = ""
            ind-situacao = ""
            ind-tiponota = ""
            obs-complementar = ""
            cod-observacao = ""
            cod-obsfiscal = ""
            tot-basesubst = 0
            ind-movestoque = ""
            ipi_capa = 0
            ipi_item = 0
            ipi_retido = 0
            cof_retido = 0
            dat_conclu = ""
            nat_frete = ""
            tipo_cte = ""
            dat_contingencia = ""
            hor_contingencia = ""
            mot_contingencia = ""
            ccc_fiscal = ""
            basepis-capa = 0
            valpis-capa = 0
            basepis-capa = 0
            valcofins-capa = 0
            cst-piscofins = ""
            tipo-credito = ""
            codigo-bc = ""
            conta-pis = ""
            conta-cofins = ""
            base-pis = 0
            per-pis = 0
            val-pis = 0
            per-cofins = 0
            val-cofins = 0
            .
     
end procedure.

procedure put-6:

    
    if vimporta-lista
    then do:
        
        if not can-find(first tt-imp
                        where tt-imp.etbcod = plani.etbcod
                          and tt-imp.numero = plani.numero)
        then return.
    end.
    
    assign
        ipi_capa = plani.ipi
        ipi_item = vipi
        vmovseq = vmovseq + 1.
        .
    /*
    find A01_InfNFe where
                         A01_InfNFe.etbcod = plani.etbcod and
                         A01_InfNFe.placod = plani.placod
                         no-lock no-error.
    if plani.serie = "55"
    then v-mod = "55".
    */
    
    if (plani.etbcod = plani.desti
        or plani.emite = plani.desti)
        and v-tipo = "P"
    then v-mod = "55".
    
    {/admcom/progr/nf-situacao.i}
    
    /*
    vcodsit = "". 
    */
    if plani.movtdc = 4   /* Compra */
    then do:
        assign
            conta-pis = "4.1.01"
            conta-cofins = "4.1.01"
            codigo-bc = "01"
            . 
        if per-pis = 0 and per-cofins = 0
        then assign
                cst-piscofins = "5353"
                tipo-credito   = "102".
        else assign
                cst-piscofins = "5050"
                tipo-credito   = "101".
    end.
    else if plani.movtdc = 12   /* Devolução de Venda */
    then do:
        assign
            conta-pis = "3.4.01.01"
            conta-cofins = "3.4.01.01"
            cst-piscofins = "9898"
            codigo-bc = "12"
            . 
        if per-pis = 0 and per-cofins = 0
        then tipo-credito   = "102".
        else tipo-credito   = "101".
    end.
    else if plani.movtdc = 11   /* Outras entradas */
    then do:
        assign
            conta-pis = "3.4.01.01"
            conta-cofins = "3.4.01.01"
            cst-piscofins = "9898"
            codigo-bc = "12"
            . 
        if per-pis = 0 and per-cofins = 0
        then tipo-credito   = "102".
        else tipo-credito   = "101".
    end.
    else if plani.movtdc = 37  /* Energia elétrica */
    then do:
        assign
            conta-pis = "5.1.01.02.045"
            conta-cofins = "5.1.01.02.045"
            cst-piscofins = "5353"
            tipo-credito = "199"
            codigo-bc = "04"
            per-pis = 1.65
            per-cofins = 7.6
            base-pis    = val_contabil
            val-pis    = val_contabil * (per-pis / 100)
            val-cofins = val_contabil * (per-cofins / 100)
            .
    end.
    
    if vcod = "E0000998"
    then vcod = "E0000993".
    
    if vcod = "E0000991"
    then vcod = "E0000995".

    if base_icms = ?
    then assign base_icms = 0.

    if visenta = ?
    then assign visenta = 0.

    find opcom where opcom.opccod = vopccod no-lock no-error.
    if avail opcom and  not opcom.piscofins
    then assign
                 per-pis = 0
                 per-cofins = 0
                 base-pis   = 0
                 val-pis    = 0
                 val-cofins = 0
                 basepis-capa = 0
                 valpis-capa = 0
                 valcofins-capa = 0
                 cst-piscofins =  string(opcom.cstpiscofins,"99")
                  + string(opcom.cstpiscofins,"99")
                 .
    find first tabaux where
               tabaux.tabela = "OPCOM" + vopccod and
               tabaux.nome_campo = "Codigo Base de credito Pis e Cofins"
               no-lock no-error.
    if avail tabaux
    then codigo-bc = tabaux.valor_campo.

    if tot-basesubst = ? then tot-basesubst = 0.
    if base_subs = ? then base_subs = 0.
    if valor_subs = ? then valor_subs = 0.
    if valicm = ? then valicm = 0.

    if val_contabil = base_icms
    then assign voutras = 0
                visenta = 0
                .
    visenta = 0.
    voutras = val_contabil - base_icms.

    put unformatted 
        /* 001-003 */   string(vdesti,">>9")    
        /* 004-004 */   "T"  format "x(1)"                            
        /* 005-006 */   "01" format "x(2)"  
        /* 007-011 */   "NF" format "x(05)"            
        /* 012-016 */   "01"  format "x(05)"           
        /* 017-028 */   string(plani.numero,">>>>>>999999") 
        /* 029-036 */   string(year(plani.datexp),"9999")  
        /* 029-036 */   string(month(plani.datexp),"99") 
        /* 029-036 */   string(day(plani.datexp),"99") 
        /* 037-044 */   string(year(plani.datexp),"9999") 
        /* 037-044 */   string(month(plani.datexp),"99") 
        /* 037-044 */   string(day(plani.datexp),"99") 
        /* 045-062 */   vcod format "x(18)" 
        /* 063-063 */   " " format "x(1)" 
        /* 064-064 */   "V" format "x(1)" 
        /* 065-080 */   plani.platot   format "9999999999999.99" 
        /* 081-096 */   plani.descprod format "9999999999999.99" 
        /* 097-112 */   plani.protot   format "9999999999999.99". 
        if valor_subs = 0
        then put
        /* 113-128 */   plani.icms     format "9999999999999.99".
        else put 0 format "9999999999999.99".
        put 
        /* 129-144 */   0 /*plani.ipi*/      format "9999999999999.99". 
        if valor_subs = 0
        then put
        /* 145-160 */   plani.icmssubst format "9999999999999.99".
        else put 0 format "9999999999999.99".
        put  
        /* 161-180 */   " " format "x(20)" 
        /* 181-196 */   plani.frete    format "9999999999999.99" 
        /* 197-212 */   plani.seguro   format "9999999999999.99" 
        /* 213-228 */   "0000000000000.00"  
        /* 229-243 */   "RODOVIARIO"   format "x(15)" 
        /* 244-246 */   "CIF"          format "x(3)"  
        /* 247-264 */   " " format "x(18)" 
        /* 265-280 */   "0000000000000.00" 
        /* 281-290 */   "UNIDADE" format "x(10)"  
        /* 291-306 */   "000000000000.000" 
        /* 307-322 */   "000000000000.000" 
        /* 323-339 */   " " format "x(17)" 
        /* 340-355 */   plani.vlserv format "9999999999999.99" 
        /* 356-362 */   "0000.00" 
        /* 363-378 */   "0000000000000.00" 
        /* 379-394 */   "0000000000000.00"  
        /* 395-410 */   "0000000000000.00"  
        /* 411-426 */   "0000000000000.00"  
        /* 427-442 */   "0000000000000.00"  
        /* 443-458 */   "0000000000000.00"  
        /* 459-474 */   "0000000000000.00"  
        /* 475-490 */   "0000000000000.00"  
        /* 491-506 */   "0000000000000.00"  
        /* 507-522 */   "0000000000000.00"  
        /* 523-538 */   "0000000000000.00"  
        /* 539-554 */   "0000000000000.00"  
        /* 555-570 */   "0000000000000.00"  
        /* 571-670 */   plani.notobs[1] format "x(50)" 
        /* 571-670 */   plani.notobs[2] format "x(50)" 
        /* 671-700 */   " " format "x(30)"
        /* 701-701 */   " " format "x(1)"  
        /* 702-721 */   string(movim.procod) format "x(20)" 
        /* 722-766 */   " " format "x(45)" 
        /* 767-772 */   vopccod format "x(6)" 
        /* 773-778 */   " " format "x(6)" 
        /* 779-788 */   vcodfis format "x(10)" 
        /* 789-791 */   vsittri format "999"  
        /* 792-807 */   movim.movqtm   format "99999999999.9999"
        /* 808-810 */   "UN" format "x(3)" 
        /* 811-826 */   movim.movpc                  format "99999999999.9999" 
        /* 827-842 */   (movim.movpc * movim.movqtm) format "99999999999.9999" 
        /* 843-858 */   vdes format "9999999999999.99"  
        /* 859-859 */   " " format "x(1)"
        /* 860-875 */   base_icms       format "9999999999999.99" .
                
        if avail movim
        then
        put
        /* 876-882 */   movim.movalicms format "9999.99"       .
        else
         put
          /* 876-882 */ " " format "9999.99".
        if valor_subs  = 0
        then put
        /* 883-898 */   ((movim.movpc * movim.movqtm) * 
                         (movim.movalicms / 100)) format "9999999999999.99".
        else put 0 format "9999999999999.99".
        put                  
        /* 899-914 */   visenta      format "9999999999999.99" 
        /* 915-930 */   voutras      format "9999999999999.99". 
        if valor_subs = 0
        then put
        /* 931-946 */   base_subs    format "9999999999999.99".
        else put 0 format "9999999999999.99".
        if valor_subs = 0
        then put 
        /* 947-962 */   valor_subs   format "9999999999999.99".
        else put 0 format "9999999999999.99".
        put 
        /* 963-963 */   " " format "x(1)"  
        /* 964-979 */   0 /*base_ipi*/ format "9999999999999.99" 
        /* 980-986 */   0 /*movim.movalipi*/ format "9999.99" 
        /* 987-1002 */  0 /*vipi*/ format "9999999999999.99" 
        /* 1003-1018 */ "0000000000000.00" 
        /* 1019-1034 */ "0000000000000.00" 
        /* 1035-1050 */ "0000000000000.00" 
        /* 1051-1066 */ "0000000000000.00" 
        /* 1067-1073 */ "0000.00"    
        /* 1074-1089 */ "0000000000000.00"  
        /* 1090-1105 */ "0000000000000.00"
        /* 1106-1112 */ "0000.00"  
        /* 1113-1128 */ "0000000000000.00" 
        /* 1129-1144 */ "0000000000000.00" 
        /* 1145-1151 */ "0000.00"  
        /* 1152-1167 */ "0000000000000.00" 
        /* 1168-1183 */ "0000000000000.00"
        /* 1184-1190 */ "0000.00"
        /* 1191-1206 */ "0000000000000.00"
        /* 1207-1220 */ " " format "x(14)"
        /* 1221-1236 */ base-pis format "9999999999999.99" 
        /* 1237-1243 */ per-pis format "9999.99"  
        /* 1244-1259 */ val-pis format "9999999999999.99"  
        /* 1260-1275 */ base-pis format "9999999999999.99"  
        /* 1276-1282 */ per-cofins format "9999.99"  
        /* 1283-1298 */ val-cofins format "9999999999999.99" 
        /* 1299-1314 */ val_contabil format "9999999999999.99" 
        /* 1315-1330 */ "0000000000000.00"
        /* 1331      */ /*vcodsit*/ cst-piscofins format "x(4)" 
            /* 1335      */ tot-bicmscapa format "9999999999999.99"
            /* 1351      */ "" format "x"
            /* 1352      */ "" format "xx"
            /* 1354      */ ind-complementar format "x"
            /* 1355      */ ind-situacao        format "xx"
            /* 1357      */ "" format "x"
            /* 1358      */ ind-tiponota format "x"
            /* 1359      */ obs-complementar format "x(254)"
            /* 1613      */ cod-observacao   format "x(6)"
            /* 1619      */ cod-obsfiscal    format "x(6)" .
            if valor_subs = 0
            then put
            /* 1625      */ tot-basesubst    format "9999999999999.99".
            else put 0 format "9999999999999.99".
            put
            /* 1641      */ ind-movestoque   format "x".
            /* 1642      */ if avail plani and length(plani.ufdes) > 30
                then put plani.ufdes format "x(44)".
                else if avail A01_InfNFe
                then put A01_InfNFe.id format "x(44)".
                else put " " format "x(44)".
         /* 1686      */ put " " format "x(28)" .
        /* 1714      */ put ipi_capa format "99999999999999.99"
        /* 1731      */     ipi_item format "99999999999999.99"
        /* 1748      */     ipi_retido format "9999.99"
        /* 1755      */     cof_retido format "9999.99"
        /* 1762      */     dat_conclu format "x(8)"
        /* 1770      */     nat_frete format "x"
        /* 1771      */     tipo_cte format "x"
        /* 1772      */     dat_contingencia format "x(8)"
        /* 1780      */     hor_contingencia format "x(10)"
        /* 1790      */     mot_contingencia format "x(254)"
        /* 2044      */     ccc_fiscal format "x(2)"
        /* 2046      */     "0"
        /* 2047      */     "0"
        /* 2048      */     " " format "x(28)"
        /* 2076      */     " " format "x(6)"
        /* 2082      */     " " format "x(6)"
        /* 2088      */   /*tipo-credito*/ " " format "x(3)"
        /* 2091      */     codigo-bc format "x(2)"
        /* 2093      */     conta-pis     format "x(28)"
        /* 2121      */     conta-cofins  format "x(28)"
        /* 2149      */     " " format "x(2)"
        /* 2151      */     string(vmovseq,">>>9") format "x(4)"
        /* 2160      */     "PUT-6"      at 2160
        /* 2170      */     vmovtdc      at 2170.
        put tot-basesubst   at 2190 format "9999999999999.99"
                 plani.icmssubst at 2206 format "9999999999999.99"
                 0     at 2222 format "9999999999999.99"
                .
        if valor_subs > 0
        then put
                 base_subs       at 2238 format "9999999999999.99"
                 valor_subs      at 2254 format "9999999999999.99"
                 ((movim.movpc * movim.movqtm) *  (movim.movalicms / 100)) 
                                at 2270 format "9999999999999.99"
                 .
        else put /*0 at 2190 format "9999999999999.99"
                 0 at 2206 format "9999999999999.99"
                 0 at 2222 format "9999999999999.99"*/
                 0 at 2238 format "9999999999999.99"
                 0 at 2254 format "9999999999999.99"
                 0 at 2270 format "9999999999999.99"
                 .
                    
        put skip.

        assign
            tot-bicmscapa = 0
            ind-complementar = ""
            ind-situacao = ""
            ind-tiponota = ""
            obs-complementar = ""
            cod-observacao = ""
            cod-obsfiscal = ""
            tot-basesubst = 0
            ind-movestoque = ""
            ipi_capa = 0
            ipi_item = 0
            ipi_retido = 0
            cof_retido = 0
            dat_conclu = ""
            nat_frete = ""
            tipo_cte = ""
            dat_contingencia = ""
            hor_contingencia = ""
            mot_contingencia = ""
            ccc_fiscal = ""
            basepis-capa = 0
            valpis-capa = 0
            basepis-capa = 0
            valcofins-capa = 0
            cst-piscofins = ""
            tipo-credito = ""
            codigo-bc = ""
            conta-pis = ""
            conta-cofins = ""
            base-pis = 0
            per-pis = 0
            val-pis = 0
            per-cofins = 0
            val-cofins = 0
            .
 
end procedure.

procedure put-7:

    if vimporta-lista
    then do:
        
        if not can-find(first tt-imp
                        where tt-imp.etbcod = plani.etbcod
                          and tt-imp.numero = plani.numero)
        then return.
    end.
    
    assign
        ipi_capa = plani.ipi
        ipi_item = vipi
        vmovseq = vmovseq + 1.
        .
    /*
    find A01_InfNFe where
                         A01_InfNFe.etbcod = plani.etbcod and
                         A01_InfNFe.placod = plani.placod
                         no-lock no-error.
    if plani.serie = "55"
    then v-mod = "55".
    */
    
    if (plani.etbcod = plani.desti
        or plani.emite = plani.desti)
        and v-tipo = "P"
    then v-mod = "55".
    
    {/admcom/progr/nf-situacao.i}
    
    /*
    vcodsit = "". 
    */

    if plani.movtdc = 4   /* Compra */
    then do:
        assign
            conta-pis = "4.1.01"
            conta-cofins = "4.1.01"
            codigo-bc = "01"
            . 
        if per-pis = 0 and per-cofins = 0
        then assign
                cst-piscofins = "5353"
                tipo-credito   = "102".
        else assign
                cst-piscofins = "5050"
                tipo-credito   = "101".
    end.
    else if plani.movtdc = 12   /* Devolução de Venda */
    then do:
        assign
            conta-pis = "3.4.01.01"
            conta-cofins = "3.4.01.01"
            cst-piscofins = "9898"
            codigo-bc = "12"
            . 
        if per-pis = 0 and per-cofins = 0
        then tipo-credito   = "102".
        else tipo-credito   = "101".
    end.
    else if plani.movtdc = 11   /* outras entradas */
    then do:
        assign
            conta-pis = "3.4.01.01"
            conta-cofins = "3.4.01.01"
            cst-piscofins = "9898"
            codigo-bc = "12"
            . 
        if per-pis = 0 and per-cofins = 0
        then tipo-credito   = "102".
        else tipo-credito   = "101".
    end.
    else if plani.movtdc = 37  /* Energia elétrica */
    then do:
        assign
            conta-pis = "5.1.01.02.045"
            conta-cofins = "5.1.01.02.045"
            cst-piscofins = "5353"
            tipo-credito = "199"
            codigo-bc = "04"
            per-pis = 1.65
            per-cofins = 7.6
            base-pis    = val_contabil
            val-pis    = val_contabil * (per-pis / 100)
            val-cofins = val_contabil * (per-cofins / 100)
            .
    end.
    
        
    if vcod = "E0000998"
    then vcod = "E0000993".
    
    if vcod = "E0000991"
    then vcod = "E0000995".
 
    if base_icms = ?
    then assign base_icms = 0.

    if visenta = ?
    then assign visenta = 0.

    find opcom where opcom.opccod = vopccod no-lock no-error.
    if avail opcom and  not opcom.piscofins
    then assign
                 per-pis = 0
                 per-cofins = 0
                 base-pis   = 0
                 val-pis    = 0
                 val-cofins = 0
                 basepis-capa = 0
                 valpis-capa = 0
                 valcofins-capa = 0
                 cst-piscofins =  string(opcom.cstpiscofins,"99")
                  + string(opcom.cstpiscofins,"99")
                 .
    find first tabaux where
               tabaux.tabela = "OPCOM" + vopccod and
               tabaux.nome_campo = "Codigo Base de credito Pis e Cofins"
               no-lock no-error.
    if avail tabaux
    then codigo-bc = tabaux.valor_campo.

    if tot-basesubst = ? then tot-basesubst = 0.
    if base_subs = ? then base_subs = 0.
    if valor_subs = ? then valor_subs = 0.
    if valicm = ? then valicm = 0.

    if val_contabil = base_icms
    then assign voutras = 0
                visenta = 0
                .
    visenta = 0.
    voutras = val_contabil - base_icms.

    put unformatted 
        /* 001-003 */   string(vdesti,">>9")    
        /* 004-004 */   "P"  format "x(1)"                            
        /* 005-006 */   "01" format "x(2)"  
        /* 007-011 */   "NF" format "x(05)"            
        /* 012-016 */   "01"  format "x(05)"           
        /* 017-028 */   string(plani.numero,">>>>>>999999") 
        /* 029-036 */   string(year(plani.datexp),"9999")  
        /* 029-036 */   string(month(plani.datexp),"99") 
        /* 029-036 */   string(day(plani.datexp),"99") 
        /* 037-044 */   string(year(plani.datexp),"9999") 
        /* 037-044 */   string(month(plani.datexp),"99") 
        /* 037-044 */   string(day(plani.datexp),"99") 
        /* 045-062 */   vcod format "x(18)" 
        /* 063-063 */   " " format "x(1)" 
        /* 064-064 */   "V" format "x(1)" 
        /* 065-080 */   plani.platot   format "9999999999999.99" 
        /* 081-096 */   plani.descprod format "9999999999999.99" 
        /* 097-112 */   plani.protot   format "9999999999999.99". 
        if valor_subs = 0
        then put
        /* 113-128 */   plani.icms     format "9999999999999.99".
        else put 0 format "9999999999999.99".
        put 
        /* 129-144 */   0 /*plani.ipi*/      format "9999999999999.99". 
        if valor_subs = 0
        then put
        /* 145-160 */   plani.icmssubst format "9999999999999.99".
        else put 0 format "9999999999999.99".
        put  
        /* 161-180 */   " " format "x(20)" 
        /* 181-196 */   plani.frete    format "9999999999999.99" 
        /* 197-212 */   plani.seguro   format "9999999999999.99" 
        /* 213-228 */   "0000000000000.00"  
        /* 229-243 */   "RODOVIARIO"   format "x(15)" 
        /* 244-246 */   "CIF"          format "x(3)"  
        /* 247-264 */   " " format "x(18)" 
        /* 265-280 */   "0000000000000.00" 
        /* 281-290 */   "UNIDADE" format "x(10)"  
        /* 291-306 */   "000000000000.000" 
        /* 307-322 */   "000000000000.000" 
        /* 323-339 */   " " format "x(17)" 
        /* 340-355 */   plani.vlserv format "9999999999999.99" 
        /* 356-362 */   "0000.00" 
        /* 363-378 */   "0000000000000.00" 
        /* 379-394 */   "0000000000000.00"  
        /* 395-410 */   "0000000000000.00"  
        /* 411-426 */   "0000000000000.00"  
        /* 427-442 */   "0000000000000.00"  
        /* 443-458 */   "0000000000000.00"  
        /* 459-474 */   "0000000000000.00"  
        /* 475-490 */   "0000000000000.00"  
        /* 491-506 */   "0000000000000.00"  
        /* 507-522 */   "0000000000000.00"  
        /* 523-538 */   "0000000000000.00"  
        /* 539-554 */   "0000000000000.00"  
        /* 555-570 */   "0000000000000.00"  
        /* 571-670 */   plani.notobs[1] format "x(50)" 
        /* 571-670 */   plani.notobs[2] format "x(50)" 
        /* 671-700 */   " " format "x(30)"
        /* 701-701 */   " " format "x(1)"  
        /* 702-721 */   "GENERICO" format "x(20)" 
        /* 722-766 */   nome_produto format "x(45)" 
        /* 767-772 */   vopccod format "x(6)" 
        /* 773-778 */   " " format "x(6)" 
        /* 779-788 */   vcodfis format "x(10)" 
        /* 789-791 */   vsittri format "999"  
        /* 792-807 */   "00000000001.0000"
        /* 808-810 */   "UN" format "x(3)" 
        /* 811-826 */   plani.platot   format "99999999999.9999" 
        /* 827-842 */   plani.platot   format "99999999999.9999" 
        /* 843-858 */   plani.descprod format "9999999999999.99"  
        /* 859-859 */   " " format "x(1)"
        /* 860-875 */   base_icms       format "9999999999999.99" 
        /* 876-882 */   plani.alicms format "9999.99".       
        if valor_subs = 0
        then put
        /* 883-898 */   plani.icms format "9999999999999.99".
        else put 0 format "9999999999999.99".
        put 
        /* 899-914 */   visenta      format "9999999999999.99" 
        /* 915-930 */   voutras      format "9999999999999.99". 
        if valor_subs = 0
        then put
        /* 931-946 */   base_subs    format "9999999999999.99".
        else put 0 format "9999999999999.99".
        if valor_subs = 0
        then put 
        /* 947-962 */   valor_subs   format "9999999999999.99".
        else put 0 format "9999999999999.99".
        put 
        /* 963-963 */   " " format "x(1)"  
        /* 964-979 */   0 /*base_ipi*/ format "9999999999999.99" 
        /* 980-986 */   0 /*plani.alipi*/ format "9999.99" 
        /* 987-1002 */  0 /*vipi*/ format "9999999999999.99" 
        /* 1003-1018 */ "0000000000000.00" 
        /* 1019-1034 */ "0000000000000.00" 
        /* 1035-1050 */ "0000000000000.00" 
        /* 1051-1066 */ "0000000000000.00" 
        /* 1067-1073 */ "0000.00"    
        /* 1074-1089 */ "0000000000000.00"  
        /* 1090-1105 */ "0000000000000.00"
        /* 1106-1112 */ "0000.00"  
        /* 1113-1128 */ "0000000000000.00" 
        /* 1129-1144 */ "0000000000000.00" 
        /* 1145-1151 */ "0000.00"  
        /* 1152-1167 */ "0000000000000.00" 
        /* 1168-1183 */ "0000000000000.00"
        /* 1184-1190 */ "0000.00"
        /* 1191-1206 */ "0000000000000.00"
        /* 1207-1220 */ " " format "x(14)"
        /* 1221-1236 */ base-pis format "9999999999999.99" 
        /* 1237-1243 */ per-pis format "9999.99"  
        /* 1244-1259 */ val-pis format "9999999999999.99"  
        /* 1260-1275 */ base-pis format "9999999999999.99"  
        /* 1276-1282 */ per-cofins format "9999.99"  
        /* 1283-1298 */ val-cofins format "9999999999999.99" 
        /* 1299-1314 */ val_contabil format "9999999999999.99" 
        /* 1331      */ /*vcodsit*/ cst-piscofins format "x(4)" 
            /* 1335      */ tot-bicmscapa format "9999999999999.99"
            /* 1351      */ "" format "x"
            /* 1352      */ "" format "xx"
            /* 1354      */ ind-complementar format "x"
            /* 1355      */ ind-situacao        format "xx"
            /* 1357      */ "" format "x"
            /* 1358      */ ind-tiponota format "x"
            /* 1359      */ obs-complementar format "x(254)"
            /* 1613      */ cod-observacao   format "x(6)"
            /* 1619      */ cod-obsfiscal    format "x(6)".
            if valor_subs = 0
            then put
            /* 1625      */ tot-basesubst    format "9999999999999.99".
            else put 0 format "9999999999999.99".
            put
            /* 1641      */ ind-movestoque   format "x".
            /* 1642      */ if avail plani and plani.ufdes <> ""
                then put plani.ufdes format "x(44)".
                else if avail A01_InfNFe
                then put A01_InfNFe.id format "x(44)".
                else put " " format "x(44)".
         /* 1686      */ put " " format "x(28)" .
        /* 1714      */ put ipi_capa format "99999999999999.99"
        /* 1731      */     ipi_item format "99999999999999.99"
        /* 1748      */     ipi_retido format "9999.99"
        /* 1755      */     cof_retido format "9999.99"
        /* 1762      */     dat_conclu format "x(8)"
        /* 1770      */     nat_frete format "x"
        /* 1771      */     tipo_cte format "x"
        /* 1772      */     dat_contingencia format "x(8)"
        /* 1780      */     hor_contingencia format "x(10)"
        /* 1790      */     mot_contingencia format "x(254)"
        /* 2044      */     ccc_fiscal format "x(2)"
        /* 2046      */     "0"
        /* 2047      */     "0"
        /* 2048      */     " " format "x(28)"
        /* 2076      */     " " format "x(6)"
        /* 2082      */     " " format "x(6)"
        /* 2088      */   /*tipo-credito*/ " " format "x(3)"
        /* 2091      */     codigo-bc format "x(2)"
        /* 2093      */     conta-pis     format "x(28)"
        /* 2121      */     conta-cofins  format "x(28)"
        /* 2149      */     " " format "x(2)"
        /* 2151      */     string(vmovseq,">>>9") format "x(4)"
        /* 2160      */     "PUT-7"      at 2160
        /* 2170      */     vmovtdc      at 2170.
        put tot-basesubst   at 2190 format "9999999999999.99"
                 plani.icmssubst at 2206 format "9999999999999.99"
                 0     at 2222 format "9999999999999.99"
                 .
        if valor_subs > 0
        then put         
                 base_subs       at 2238 format "9999999999999.99"
                 valor_subs      at 2254 format "9999999999999.99"
                 plani.icms at 2270 format "9999999999999.99"
                 .
        else put /* at 2190 format "9999999999999.99"
                 0 at 2206 format "9999999999999.99"
                 0 at 2222 format "9999999999999.99" */
                 0 at 2238 format "9999999999999.99"
                 0 at 2254 format "9999999999999.99"
                 0 at 2270 format "9999999999999.99"
                 .
        put skip.

        assign
            tot-bicmscapa = 0
            ind-complementar = ""
            ind-situacao = ""
            ind-tiponota = ""
            obs-complementar = ""
            cod-observacao = ""
            cod-obsfiscal = ""
            tot-basesubst = 0
            ind-movestoque = ""
            ipi_capa = 0
            ipi_item = 0
            ipi_retido = 0
            cof_retido = 0
            dat_conclu = ""
            nat_frete = ""
            tipo_cte = ""
            dat_contingencia = ""
            hor_contingencia = ""
            mot_contingencia = ""
            ccc_fiscal = ""
            basepis-capa = 0
            valpis-capa = 0
            basepis-capa = 0
            valcofins-capa = 0
            cst-piscofins = ""
            tipo-credito = ""
            codigo-bc = ""
            conta-pis = ""
            conta-cofins = ""
            base-pis = 0
            per-pis = 0
            val-pis = 0
            per-cofins = 0
            val-cofins = 0.

end procedure.
*****/

procedure pagamento:
    vokpagamento = yes.
    if plani.movtdc = 37
    then do:
        find first titulo where titulo.empcod = 19 and
                          titulo.titnat = yes and
                          titulo.modcod = "LUZ" and
                          titulo.etbcod = plani.etbcod and
                          titulo.clifor = plani.emite and
                          titulo.titnum = string(plani.numero) and
                          titulo.titvlcob = plani.platot /*and
                          titulo.titsit = "PAG"            */
                          no-lock no-error.
        if not avail titulo
        then vokpagamento = no.
    end.
end.


