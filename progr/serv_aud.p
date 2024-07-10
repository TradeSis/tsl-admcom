
def var tot-bicmscapa as dec.
def var ind-complementar as char.
def var ind-tiponota as char.
def var obs-complementar as char.
def var cod-observacao as char.
def var cod-obsfiscal  as char.
def var tot-basesubst  as dec.
def var ind-movestoque as char.
def var chave-nfe as char.

def var ipi_retido as dec.
def var cof_retido as dec.
def var dat_conclu as char.
def var nat_frete as char.
def var tipo_cte as char.
def var dat_contingencia as char.
def var hor_contingencia as char.
def var mot_contingencia as char.
def var ccc_fiscal as char.
 
def var uf-emite                 as char.
def var ind-fatura               as char.
def var aliquota_irrf            as dec.
def var base_irrf                as dec.
def var valor_irrf               as dec.
def var cidigo_retencao_irrf     as char.
def var database_retencao_irrf   as char.
def var base_iss                 as dec.
def var aliquota_iss             as dec.
def var valor_iss                as dec.
def var base_pis                 as dec.
def var aliquota_pis             as dec.
def var valor_pis                as dec.
def var base_cofins              as dec.
def var aliquota_cofins          as dec.
def var valor_cofins             as dec.
def var base_csll                as dec.
def var aliquota_csll            as dec.
def var valor_csll               as dec.
def var base_inss                as dec.
def var aliquota_inss            as dec.
def var total_retencao_inss      as dec.
def var database_retencao_inss   as char.
def var base_total_iss           as dec.
def var valor_total_iss          as dec.
def var data_retencao_csrf       as char.
def var data_retencao_iss        as char.
def var base_total_pis           as dec.
def var valor_total_pis          as dec.
def var base_total_cofins        as dec.
def var valor_total_cofins       as dec.
def var codigo_observacao        as char.
def var base_pis_retido          as dec.
def var aliquota_pis_retido      as dec.
def var valor_pis_retido         as dec.

def var base_cofins_retido          as dec.
def var aliquota_cofins_retido      as dec.
def var valor_cofins_retido         as dec.

def var base_iss_retido          as dec.
def var aliquota_iss_retido      as dec.
def var valor_iss_retido         as dec.

def var base_irrf_retido          as dec.
def var aliquota_irrf_retido      as dec.
def var valor_irrf_retido         as dec.

def var base_inss_retido          as dec.
def var aliquota_inss_retido      as dec.
def var valor_inss_retido         as dec.

def var base_csll_retido          as dec.
def var aliquota_csll_retido      as dec.
def var valor_csll_retido         as dec.

def var ipi_capa  like plaservi.platot.
def var ipi_item  like plaservi.platot.
def var vmovalipi like movservi.movalipi.
def var frete_item like movservi.movpc.
def var valicm  as dec.
def var tip-doc as char.
def var ie_subst_trib as char.
def var per_desc like plaservi.platot.
def var valor_item as dec decimals 4 format "->>>,>>9.9999".
def var protot_capa like plaservi.platot.
def var desc_capa like plaservi.platot.
def var valor_ipi as dec.
def var nome_produto as char format "x(45)".  
def var v-ser as char.
def var v-mod as char.
def var v-tipo as char format "x(01)". 
def var vnumero like fiscal.numero.
def var totpla like plaservi.platot.
def buffer bmovservi for movservi.
def var vemi like plaservi.emite.
def var vdesti like plaservi.etbcod.
def var data_rec like plaservi.pladat. 
def var recpla as recid.
def var varq as char.
def var tot_pro like plaservi.platot.
def var base_subs  like plaservi.platot.
def var valor_subs like plaservi.platot.
def var vcodfis as char format "x(10)".
def var vsittri as char format "x(03)".
def var base_icms like plaservi.platot.
def var base_ipi  like plaservi.platot.
def var vdes      like plaservi.platot. 
def var vipi      like plaservi.platot.
def var vicms     like plaservi.platot.
def var visenta   like plaservi.isenta.
def var voutras   like plaservi.platot.
def var val_contabil like plaservi.platot.
def var vdti like plaservi.pladat.
def var vdtf like plaservi.pladat.
def var vetbcod like estab.etbcod.
def var vopccod as char.
def var vali    as int.
def var vcod as char format "x(18)".
def var ali_icms like movservi.movalipi.
def var ali_ipi  like movservi.movalicms.
def var vobs     like plaservi.notobs.
def var vmovpc as dec decimals 4 format "->>>,>>9.9999".
def var valoricms as dec.
def var vetb as char.

def var aux-uf    as char.
def var val-pis    as dec.
def var val-cofins as dec.
def var per-pis    as dec.
def var per-cofins as dec.
def var base-pis   as dec.
def var vcodsit    as char.

def var tipo-documento as char.
def var valpis-capa as dec.
def var basepis-capa as dec.
def var valcofins-capa as dec.
def var vemite like plaservi.emite.

procedure gera-fiscal:
    for each tipmov where tipmov.movtdc = 47 no-lock:
        
        for each estab where if vetbcod = 0
                             then true 
                             else estab.etbcod = vetbcod no-lock:
        
        for each plaservi where plaservi.movtdc = tipmov.movtdc and
                             plaservi.etbcod = estab.etbcod  and
                             plaservi.dtinclu >= vdti        and
                             plaservi.dtinclu <= vdtf        and
                             plaservi.notsit  = no no-lock:
        
            if plaservi.numero = 0
            then next.
        
            find forne where forne.forcod = plaservi.emite no-lock no-error.
            if not avail forne
            then next.
            
            vemite = plaservi.emite.
            if plaservi.emite = 998
            then vemite = 993.
            find fiscal where fiscal.emite  = vemite and
                              fiscal.desti  = plaservi.desti and
                              fiscal.movtdc = plaservi.movtdc and
                              fiscal.numero = plaservi.numero and
                              fiscal.serie  = plaservi.serie no-error.
            if not avail fiscal
            then do transaction:
                create fiscal.
                assign  fiscal.emite  = vemite
                        fiscal.desti  = plaservi.desti
                        fiscal.movtdc = plaservi.movtdc
                        fiscal.numero = plaservi.numero
                        fiscal.serie  = plaservi.serie
                        fiscal.outras = plaservi.outras
                        fiscal.plaemi = plaservi.pladat
                        fiscal.plarec = plaservi.dtinclu
                        fiscal.platot = plaservi.platot 
                        fiscal.bicms  = plaservi.bicms     
                        fiscal.icms   = plaservi.icms   
                        fiscal.ipi    = plaservi.ipi
                        fiscal.opfcod = int(plaservi.opccod).
                
            end.
        end.
        end.
    end.        
end procedure.

def var vmovsubst like movservi.movsubst.
def var vicmsubst as dec.
def var bST-item as dec.
def var iST-item as dec.
def var vmovqtm like movservi.movqtm.
def buffer smovservi for movservi.

procedure item-ST:
        for each smovservi where
                               smovservi.etbcod = plaservi.etbcod and
                               smovservi.placod = plaservi.placod and
                               smovservi.movtdc = plaservi.movtdc and
                               smovservi.movdat = plaservi.pladat 
                             no-lock.
                            find produ where produ.procod = smovservi.procod
                                        no-lock no-error.
                            if not avail produ then next.
                            if produ.proipiper <> 99 then next.
            vmovqtm = vmovqtm + smovservi.movqtm.
        end.
        
        iST-item = plaservi.bsubst / vmovqtm.
        iST-item = plaservi.icmssubst / vmovqtm.
        
end procedure.

def var sparam as char.
sparam = SESSION:PARAMETER.
if num-entries(sparam,";") > 1
then sparam = entry(2,sparam,";").

def var vesc as char format "x(20)" extent 3
    Init["   ENTRADAS","   SAIDAS","ENTRADAS E SAIDAS"].
    
def var vindex as int. 
repeat:
    if opsys = "unix" and sparam <> "AniTA"
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
        vindex = 0.
    end.
    else do:
    
        update vetbcod with frame f1.
        if vetbcod = 0
        then display "GERAL" @ estab.etbnom with frame f1.
        else do:
            find estab where estab.etbcod = vetbcod no-lock.
            display estab.etbnom no-label with frame f1.
        end.
    
        update vdti label "Data Inicial" colon 15
               vdtf label "Data Final" with frame f1 side-label width 80.

        disp vesc with frame f-e 1 down centered side-label
            no-label.
        choose field vesc with frame f-e.
        vindex = frame-index.
        if vindex = 3 then vindex = 0.
        hide frame f-e no-pause.     
    end.
    /*
    run gera-fiscal.
    */
    if vetbcod = 0
    then vetb = "".
    else vetb = string(vetbcod,"999").
    
    if vindex = 0 or vindex = 1
    then do:
    
    if opsys = "unix"
    then varq = "/admcom/audit/entserv_" + trim(string(vetb,"x(3)")) + "_" +
                string(day(vdti),"99") +  
                string(month(vdti),"99") +  
                string(year(vdti),"9999") + "_" +  
                string(day(vdtf),"99") +  
                string(month(vdtf),"99") +  
                string(year(vdtf),"9999") + ".txt".
    else varq = "l:\audit\entserv_" + trim(string(vetb,"x(3)")) + "_" +
                string(day(vdti),"99") + 
                string(month(vdti),"99") +  
                string(year(vdti),"9999") + "_" +  
                string(day(vdtf),"99") +  
                string(month(vdtf),"99") +  
                string(year(vdtf),"9999") + ".txt".

    output to value(varq).

    for each estab where if vetbcod = 0 
                         then true  
                         else estab.etbcod = vetbcod no-lock:
        for each tipmov where tipmov.movtdc = 47 no-lock,
            each plaservi where plaservi.movtdc = tipmov.movtdc and 
                             plaservi.desti  = estab.etbcod  and 
                             plaservi.datexp >= vdti         and
                             plaservi.datexp <= vdtf  exclusive-lock:

            if plaservi.numero = 0
            then next.
                                 
            if plaservi.platot = 0 or
               plaservi.protot = 0
            then next.

            if plaservi.serie = "U" or
               plaservi.serie = "U1" or
               plaservi.serie = "55"
            then.
            else next.
            
            totpla = totpla + plaservi.platot.
            
            vemi = plaservi.emite.
            
            if vemi = 998
            then vemi = 993 /*95*/.
            
            if vemi = 991
            then vemi = 995.
            
            vdesti = plaservi.desti.
            
            if vdesti = 998
            then vdesti = 993 /*95*/.
            
            if vdesti = 991
            then vdesti = 995 .



            vopccod = "1152". 
            vcod = "E" + string(vemi,"9999999") + "          ". 


            if plaservi.bicms > 0  
            then vali = int((plaservi.icms * 100) / plaservi.bicms). 
            else vali = 0.

            for each movservi where movservi.etbcod = plaservi.etbcod and
                                 movservi.placod = plaservi.placod and
                                 movservi.movtdc = plaservi.movtdc and
                                 movservi.movdat = plaservi.pladat and
                                 movservi.desti  = plaservi.desti no-lock:
                  
                frete_item = 0. 
                if movservi.movdev > 0 
                then frete_item = movservi.movdev.
                        
                if movservi.movpc = 0 or
                   movservi.movqtm = 0
                then next.       
 
                tot_pro = movservi.movqtm * movservi.movpc. 
                vcodfis = "". 
                vsittri = "".
                    
                find produ where produ.procod = movservi.procod no-lock no-error.
                                        
                if not avail produ 
                then next.
                    
                if produ.codfis > 0
                then vcodfis = substring(string(produ.codfis),1,4) + 
                                   "." +   
                               substring(string(produ.codfis),5,2) +  
                                   "." +  
                               substring(string(produ.codfis),7,2).
                if produ.codori > 0
                then vsittri = string(produ.codori) + string(produ.codtri).
                    
                base_subs  = 0. 
                valor_subs = 0.
                    
                    
                base_ipi = 0.
                    
                if plaservi.ipi > 0 
                then base_ipi = (movservi.movpc * movservi.movqtm).

                base_icms = (plaservi.bicms / plaservi.protot) * 
                            (movservi.movpc * movservi.movqtm).
     
 
                vdes = (plaservi.descprod / plaservi.platot) * 
                       (movservi.movpc * movservi.movqtm).
                if vdes = ? then vdes = 0.           
                  
                vipi  = base_ipi  * (movservi.movalipi / 100).
                vicms = base_icms * (movservi.movalicms / 100). 
                    
                    
                val_contabil = (movservi.movpc * movservi.movqtm) + vipi.
                
                visenta = val_contabil - (movservi.movpc * movservi.movqtm) 
                              - vipi.
                if visenta < 0
                then visenta = 0.
                           
                voutras = val_contabil.

                 
                if length(vsittri) = 2
                            then vsittri = "0" + vsittri.
                            else if length(vsittri) = 1
                                then vsittri = "00" + vsittri.

                vsittri = "051".
                
                if visenta < 0 then visenta = 0.
                vmovalipi = movservi.movalipi.
                if vmovalipi = ? then vmovalipi = 0.
                if vdes = ? then vdes = 0.
        
                run put-1.
        
            end.
        end.  
    end. 
    end.
    else if vindex = 0 or vindex = 2
    then do:
    if opsys = "unix"
    then varq = "/admcom/audit/saiserv_" + trim(string(vetb,"x(3)")) + "_" +
                string(day(vdti),"99") +  
                string(month(vdti),"99") +  
                string(year(vdti),"9999") + "_" +  
                string(day(vdtf),"99") +  
                string(month(vdtf),"99") +  
                string(year(vdtf),"9999") + ".txt".
    else varq = "l:\audit\saiserv_" + trim(string(vetb,"x(3)")) + "_" +
                string(day(vdti),"99") + 
                string(month(vdti),"99") +  
                string(year(vdti),"9999") + "_" +  
                string(day(vdtf),"99") +  
                string(month(vdtf),"99") +  
                string(year(vdtf),"9999") + ".txt".

    output to value(varq).

    for each estab where if vetbcod = 0 
                         then true  
                         else estab.etbcod = vetbcod no-lock:
        for each tipmov where tipmov.movtdc = 49 no-lock,
            each plaservi where plaservi.movtdc = tipmov.movtdc and 
                             plaservi.desti  = estab.etbcod  and 
                             plaservi.datexp >= vdti         and
                             plaservi.datexp <= vdtf  exclusive-lock:

            if plaservi.numero = 0
            then next.
                                 
            if plaservi.platot = 0 or
               plaservi.protot = 0
            then next.

            if plaservi.serie = "U" or
               plaservi.serie = "U1" or
               plaservi.serie = "55"
            then.
            else next.
            
            totpla = totpla + plaservi.platot.
            
            vemi = plaservi.emite.
            
            if vemi = 998
            then vemi = 993 /*95*/.
            
            if vemi = 991
            then vemi = 995.
            
            vdesti = plaservi.desti.
            
            if vdesti = 998
            then vdesti = 993 /*95*/.
            
            if vdesti = 991
            then vdesti = 995 .



            vopccod = "1152". 
            vcod = "E" + string(vemi,"9999999") + "          ". 


            if plaservi.bicms > 0  
            then vali = int((plaservi.icms * 100) / plaservi.bicms). 
            else vali = 0.

            for each movservi where movservi.etbcod = plaservi.etbcod and
                                 movservi.placod = plaservi.placod and
                                 movservi.movtdc = plaservi.movtdc and
                                 movservi.movdat = plaservi.pladat and
                                 movservi.desti  = plaservi.desti no-lock:
                  
                frete_item = 0. 
                if movservi.movdev > 0 
                then frete_item = movservi.movdev.
                        
                if movservi.movpc = 0 or
                   movservi.movqtm = 0
                then next.       
 
                tot_pro = movservi.movqtm * movservi.movpc. 
                vcodfis = "". 
                vsittri = "".
                    
                find produ where produ.procod = movservi.procod no-lock no-error.
                                        
                if not avail produ 
                then next.
                    
                if produ.codfis > 0
                then vcodfis = substring(string(produ.codfis),1,4) + 
                                   "." +   
                               substring(string(produ.codfis),5,2) +  
                                   "." +  
                               substring(string(produ.codfis),7,2).
                if produ.codori > 0
                then vsittri = string(produ.codori) + string(produ.codtri).
                    
                base_subs  = 0. 
                valor_subs = 0.
                    
                    
                base_ipi = 0.
                    
                if plaservi.ipi > 0 
                then base_ipi = (movservi.movpc * movservi.movqtm).

                base_icms = (plaservi.bicms / plaservi.protot) * 
                            (movservi.movpc * movservi.movqtm).
     
 
                vdes = (plaservi.descprod / plaservi.platot) * 
                       (movservi.movpc * movservi.movqtm).
                if vdes = ? then vdes = 0.           
                  
                vipi  = base_ipi  * (movservi.movalipi / 100).
                vicms = base_icms * (movservi.movalicms / 100). 
                    
                    
                val_contabil = (movservi.movpc * movservi.movqtm) + vipi.
                
                visenta = val_contabil - (movservi.movpc * movservi.movqtm) 
                              - vipi.
                if visenta < 0
                then visenta = 0.
                           
                voutras = val_contabil.

                 
                if length(vsittri) = 2
                            then vsittri = "0" + vsittri.
                            else if length(vsittri) = 1
                                then vsittri = "00" + vsittri.

                vsittri = "051".
                
                if visenta < 0 then visenta = 0.
                vmovalipi = movservi.movalipi.
                if vmovalipi = ? then vmovalipi = 0.
                if vdes = ? then vdes = 0.
        
                run put-2.
        
            end.
        end.  
    end. 
    end.
    leave.
end.

procedure put-1:

    find A01_InfNFe where
                         A01_InfNFe.etbcod = plaservi.etbcod and
                         A01_InfNFe.placod = plaservi.placod
                         no-lock no-error.
    if plaservi.serie = "55"
    then v-mod = "55".
    
    {nf-situacao.i}

    assign
        ipi_capa = fiscal.ipi
        ipi_item = round(vipi,2)
        .
    
    put unformatted 
        /* 001-003 */   string(plaservi.etbcod,">>9")    
        /* 004-004 */   v-tipo  format "x(1)"  /** propria/terceiros ***/
        /* 005-006 */   v-mod  format "x(2)"   /** modelo documento **/
        /* 007-011 */   tipo-documento format "x(05)"  /** tipo documento **/ 
        /* 012-016 */   v-ser  format "x(05)"  /** serie documento **/
        /* 017-028 */   string(plaservi.numero,">>>>>>999999") 
        /* 029-036 */   string(year(plaservi.pladat),"9999")  
        /* 029-036 */   string(month(plaservi.pladat),"99") 
        /* 029-036 */   string(day(plaservi.pladat),"99") 
        /* 037-044 */   string(year(fiscal.plarec),"9999") 
        /* 037-044 */   string(month(fiscal.plarec),"99") 
        /* 037-044 */   string(day(fiscal.plarec),"99") 
        /* 045-062 */   vcod format "x(18)" 
        /* 063-064 */   uf-emite format "x(2)"
        /* 065-066 */   ind-situacao format "x(2)"
        /* 067-067 */   ind-cancelada format "x" 
        /* 068-068 */   ind-complementar format "x" 
        /* 069-069 */   ind-fatura format "x" 
        /* 070-085 */   plaservi.platot    format "9999999999999.99" 
        /* 086-101 */   plaservi.descprod format "9999999999999.99" 
        /* 102-117 */   plaservi.vlserv   format "9999999999999.99" 
        /* 118-124 */   aliquota_irrf  format "9999.99" 
        /* 125-140 */   base_irrf format "9999999999999.99"  
        /* 141-156 */   valor_irrf format "9999999999999.99" 
        /* 157-162 */   cidigo_retencao_irrf  format "x(6)" 
        /* 163-170 */   database_retencao_irrf  format "x(8)" 
        /* 171-186 */   base_iss format "9999999999999.99"  
        /* 187-193 */   base_iss   format "9999.99" 
        /* 194-209 */   valor_iss format "9999999999999.99"
        /* 210-225 */   base_pis format "9999999999999.99" 
        /* 226-232 */   aliquota_pis format "9999.99" 
        /* 233-248 */   valor_pis format "9999999999999.99"  
        /* 249-264 */   base_cofins format "9999999999999.99" 
        /* 265-271 */   aliquota_cofins format "9999.99" 
        /* 272-287 */   valor_cofins format "9999999999999.99" 
        /* 288-303 */   base_csll format "9999999999999.99" 
        /* 304-310 */   aliquota_csll format "9999.99" 
        /* 311-326 */   valor_csll format "9999999999999.99" 
        /* 327-342 */   base_inss format "9999999999999.99"  
        /* 343-349 */   aliquota_inss format "9999.99"  
        /* 350-365 */   total_retencao_inss format "9999999999999.99"  
        /* 366-373 */   database_retencao_inss format "x(8)"  
        /* 374-389 */   base_total_iss format "9999999999999.99"  
        /* 390-405 */   valor_total_iss format "9999999999999.99"  
        /* 406-413 */   data_retencao_csrf format "x(8)"  
        /* 414-421 */   data_retencao_iss format "x(8)"  
        /* 422-449 */   " " format "x(28)"  
        /* 450-465 */   base_total_pis  format "9999999999999.99"  
        /* 466-481 */   base_total_pis format "9999999999999.99"  
        /* 482-497 */   base_total_pis format "9999999999999.99"  
        /* 498-513 */   valor_total_cofins format "9999999999999.99" 
        /* 514-519 */   codigo_observacao format "x(6)" 
        /* 520-769 */   plaservi.notobs[1] + " " + plaservi.notobs[2] + " "
                        + plaservi.notobs[3] format "x(250)"
        /* 770-1023 */  " " format "x(254)"  
        /* 1024-1029 */ " " format "x(6)" 
        /* 1030-1283 */ " " format "x(254)" 
        /* 1284-1333 */ " " format "x(50)" 
        /* 1334-1334 */ " " format "x" 
        /* 1335-1335 */ " " format "x" 
        /* 1336-1345 */ " " format "x(10)"  
        /* 1346-1365 */ " " format "x(20)"
        /* 1366-1373 */ " " format "x(8)" 
        /* 1374-1378 */ " " format "x(5)" 
        /* 1379-1390 */ " " format "x(12)" 
        /* 1391-1398 */ " " format "x(8)"
        /* 1399-1500 */ " " format "x(102)"
        
        /***** FIM CAPA INICIO ITENS *****/
        
        /* 1501-1503 */ movservi.movseq format "999" 
        /* 1504-1504 */ "S"       
        /* 1505-1524 */ movservi.procod format "x(20)" 
        /* 1525-1569 */ " " "x(45)" 
        /* 1570-1575 */ plaservi.opccod format "x(6)" /* movservi.cfop */  
        /* 1576-1581 */ " " format "x(6)" 
        /* 1582-1601 */ " " format "x(20)" 
        /* 1602-1617 */ (movservi.movpc * movservi.movqtm) format "9999999999999.99"
        /* 1617-1633 */ movservi.movdes  format "9999999999999.99" 
        /* 1634-1649 */ base_irrf    format "9999999999999.99"
        /* 1650-1656 */ aliquota_irrf format "9999.99" 
        /* 1657-1672 */ valor_irrf   format "9999999999999.99"
        /* 1673-1678 */ " " format "x(6)" 
        /* 1679-1694 */ base_iss_retido    format "9999999999999.99"
        /* 1695-1701 */ aliquota_iss_retido format "9999.99"
        /* 1702-1717 */ valor_iss_retido  format "9999999999999.99"  
        /* 1718-1718 */ " " format "x"  
        /* 1719-1738 */ " " format "x(20)"
        /* 1739-1744 */ " " format "x(6)"  
        /* 1745-1760 */ base_pis_retido format "9999999999999.99" 
        /* 1761-1767 */ aliquota_pis_retido format "9999.99" 
        /* 1768-1783 */ valor_pis_retido format "9999999999999.99"  
        /* 1784-1799 */ base_cofins_retido format "9999999999999.99" 
        /* 1800-1806 */ aliquota_cofins_retido format "9999.99"
        /* 1807-1822 */ valor_cofins_retido format "9999999999999.99"
        /* 1823-1838 */ base_csll_retido format "9999999999999.99"
        /* 1839-1845 */ aliquota_csll_retido format "9999.99"
        /* 1846-1861 */ valor_csll_retido format "9999999999999.99" 
        /* 1862-1877 */ base_inss_retido format "9999999999999.99"  
        /* 1878-1884 */ aliquota_inss_retido format "9999.99"  
        /* 1885-1900 */ valor_inss_retido format "9999999999999.99"  
        /* 1901-1916 */ base_iss format "9999999999999.99"  
        /* 1917-1923 */ aliquota_iss format "9999.99" 
        /* 1924-1939 */ valor_iss format "9999999999999.99"
        /* 1940-1953 */ " " format "x(14)"  
        /* 1954-1969 */ base_pis format "9999999999999.99" 
        /* 1970-1976 */ aliquota_pis format "9999.99"
        /* 1977-1992 */ valor_pis format "9999999999999.99"
        /* 1993-2008 */ base_cofins format "9999999999999.99"
        /* 2009-2015 */ aliquota_cofins format "9999.99"
        /* 2016-2031 */ valor_cofins format "9999999999999.99"
        /* 2032-2059 */ " " format "x(20)"
        /* 2060-2079 */ " " format "x(20)"
        /* 2080-2095 */ (movservi.movpc * movservi.movqtm) format "9999999999999.99"
        /* 2096-2200 */ " " format "x(105)"
        .

end procedure.

procedure put-2:

    find A01_InfNFe where
                         A01_InfNFe.etbcod = plaservi.etbcod and
                         A01_InfNFe.placod = plaservi.placod
                         no-lock no-error.
    if plaservi.serie = "55"
    then v-mod = "55".
    
    {nf-situacao.i}

    assign
        ipi_capa = fiscal.ipi
        ipi_item = round(vipi,2)
        .
    
    put unformatted 
        /* 001-003 */   string(plaservi.etbcod,">>9")    
        /* 004-004 */   v-tipo  format "x(1)"  /** propria/terceiros ***/
        /* 005-006 */   v-mod  format "x(2)"   /** modelo documento **/
        /* 007-011 */   tipo-documento format "x(05)"  /** tipo documento **/ 
        /* 012-016 */   v-ser  format "x(05)"  /** serie documento **/
        /* 017-028 */   string(plaservi.numero,">>>>>>999999") 
        /* 029-036 */   string(year(plaservi.pladat),"9999")  
        /* 029-036 */   string(month(plaservi.pladat),"99") 
        /* 029-036 */   string(day(plaservi.pladat),"99") 
        /* 037-044 */   string(year(fiscal.plarec),"9999") 
        /* 037-044 */   string(month(fiscal.plarec),"99") 
        /* 037-044 */   string(day(fiscal.plarec),"99") 
        /* 045-062 */   vcod format "x(18)" 
        /* 063-064 */   uf-emite format "x(2)"
        /* 065-066 */   ind-situacao format "x(2)"
        /* 067-067 */   ind-cancelada format "x" 
        /* 068-068 */   ind-complementar format "x" 
        /* 069-069 */   ind-fatura format "x" 
        /* 070-085 */   plaservi.platot    format "9999999999999.99" 
        /* 086-101 */   plaservi.descprod format "9999999999999.99" 
        /* 102-117 */   plaservi.vlserv   format "9999999999999.99" 
        /* 118-124 */   aliquota_irrf  format "9999.99" 
        /* 125-140 */   base_irrf format "9999999999999.99"  
        /* 141-156 */   valor_irrf format "9999999999999.99" 
        /* 157-162 */   cidigo_retencao_irrf  format "x(6)" 
        /* 163-170 */   database_retencao_irrf  format "x(8)" 
        /* 171-186 */   base_iss format "9999999999999.99"  
        /* 187-193 */   base_iss   format "9999.99" 
        /* 194-209 */   valor_iss format "9999999999999.99"
        /* 210-225 */   base_pis format "9999999999999.99" 
        /* 226-232 */   aliquota_pis format "9999.99" 
        /* 233-248 */   valor_pis format "9999999999999.99"  
        /* 249-264 */   base_cofins format "9999999999999.99" 
        /* 265-271 */   aliquota_cofins format "9999.99" 
        /* 272-287 */   valor_cofins format "9999999999999.99" 
        /* 288-303 */   base_csll format "9999999999999.99" 
        /* 304-310 */   aliquota_csll format "9999.99" 
        /* 311-326 */   valor_csll format "9999999999999.99" 
        /* 327-342 */   base_inss format "9999999999999.99"  
        /* 343-349 */   aliquota_inss format "9999.99"  
        /* 350-365 */   total_retencao_inss format "9999999999999.99"  
        /* 366-373 */   database_retencao_inss format "x(8)"  
        /* 374-389 */   base_total_iss format "9999999999999.99"  
        /* 390-405 */   valor_total_iss format "9999999999999.99"  
        /* 406-413 */   data_retencao_csrf format "x(8)"  
        /* 414-421 */   data_retencao_iss format "x(8)"  
        /* 422-449 */   " " format "x(28)"  
        /* 450-465 */   base_total_pis  format "9999999999999.99"  
        /* 466-481 */   base_total_pis format "9999999999999.99"  
        /* 482-497 */   base_total_pis format "9999999999999.99"  
        /* 498-513 */   valor_total_cofins format "9999999999999.99" 
        /* 514-519 */   codigo_observacao format "x(6)" 
        /* 520-769 */   plaservi.notobs[1] + " " + plaservi.notobs[2] + " "
                        + plaservi.notobs[3] format "x(250)"
        /* 770-1023 */  " " format "x(254)"  
        /* 1024-1029 */ " " format "x(6)" 
        /* 1030-1283 */ " " format "x(254)" 
        /* 1284-1333 */ " " format "x(50)" 
        /* 1334-1334 */ " " format "x" 
        /* 1335-1335 */ " " format "x" 
        /* 1336-1345 */ " " format "x(10)"  
        /* 1346-1365 */ " " format "x(20)"
        /* 1366-1373 */ " " format "x(8)" 
        /* 1374-1378 */ " " format "x(5)" 
        /* 1379-1390 */ " " format "x(12)" 
        /* 1391-1398 */ " " format "x(8)"
        /* 1399-1500 */ " " format "x(102)"
        
        /***** FIM CAPA INICIO ITENS *****/
        
        /* 1501-1503 */ movservi.movseq format "999" 
        /* 1504-1504 */ "S"       
        /* 1505-1524 */ movservi.procod format "x(20)" 
        /* 1525-1569 */ " " "x(45)" 
        /* 1570-1575 */ plaservi.opccod format "x(6)" /* movservi.cfop */  
        /* 1576-1581 */ " " format "x(6)" 
        /* 1582-1601 */ " " format "x(20)" 
        /* 1602-1617 */ (movservi.movpc * movservi.movqtm) format "9999999999999.99"
        /* 1617-1633 */ movservi.movdes  format "9999999999999.99" 
        /* 1634-1649 */ base_irrf    format "9999999999999.99"
        /* 1650-1656 */ aliquota_irrf format "9999.99" 
        /* 1657-1672 */ valor_irrf   format "9999999999999.99"
        /* 1673-1678 */ " " format "x(6)" 
        /* 1679-1694 */ base_iss_retido    format "9999999999999.99"
        /* 1695-1701 */ aliquota_iss_retido format "9999.99"
        /* 1702-1717 */ valor_iss_retido  format "9999999999999.99"  
        /* 1718-1718 */ " " format "x"  
        /* 1719-1738 */ " " format "x(20)"
        /* 1739-1744 */ " " format "x(6)"  
        /* 1745-1760 */ base_pis_retido format "9999999999999.99" 
        /* 1761-1767 */ aliquota_pis_retido format "9999.99" 
        /* 1768-1783 */ valor_pis_retido format "9999999999999.99"  
        /* 1784-1799 */ base_cofins_retido format "9999999999999.99" 
        /* 1800-1806 */ aliquota_cofins_retido format "9999.99"
        /* 1807-1822 */ valor_cofins_retido format "9999999999999.99"
        /* 1823-1838 */ base_csll_retido format "9999999999999.99"
        /* 1839-1845 */ aliquota_csll_retido format "9999.99"
        /* 1846-1861 */ valor_csll_retido format "9999999999999.99" 
        /* 1862-1877 */ base_inss_retido format "9999999999999.99"  
        /* 1878-1884 */ aliquota_inss_retido format "9999.99"  
        /* 1885-1900 */ valor_inss_retido format "9999999999999.99"  
        /* 1901-1916 */ base_iss format "9999999999999.99"  
        /* 1917-1923 */ aliquota_iss format "9999.99" 
        /* 1924-1939 */ valor_iss format "9999999999999.99"
        /* 1940-1953 */ " " format "x(14)"  
        /* 1954-1969 */ base_pis format "9999999999999.99" 
        /* 1970-1976 */ aliquota_pis format "9999.99"
        /* 1977-1992 */ valor_pis format "9999999999999.99"
        /* 1993-2008 */ base_cofins format "9999999999999.99"
        /* 2009-2015 */ aliquota_cofins format "9999.99"
        /* 2016-2031 */ valor_cofins format "9999999999999.99"
        /* 2032-2059 */ "6.1.01.01.013" format "x(20)"
        /* 2060-2079 */ " " format "x(20)"
        /* 2080-2095 */ (movservi.movpc * movservi.movqtm) format "9999999999999.99"
        /* 2096-2200 */ " " format "x(105)"
        .

end procedure.


