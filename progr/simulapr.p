{admcab.i}

def var vprocod like produ.procod.
def var vl-produto as dec.
def var pct-in as dec.
def var val-in as dec.
def var val-in2 as dec.
def var pct-ipi as dec.
def var val-ipi as dec.
def var val-out as dec.
def var val-fre as dec.
def var val-custo1 as dec.
def var pct-mva as dec.
def var val-mva as dec.
def var base-st as dec.
def var pct-redbas as dec decimals 3.
def var val-redbas as dec.
def var pct-icms-rs as dec.
def var val-icms-st as dec.
def var val-icms1 as dec.
def var val-icms2 as dec.
def var val-custo2 as dec.
def var val-piscof as dec.
def var val-custo3 as dec.
def var val-prvenda as dec.
def var pct-margem as dec.
def var pct-pisc as dec.
def var pct-pisd as dec.
def var pct-cofinsc as dec.
def var pct-cofinsd as dec.
def var cre-pis as dec.
def var cre-cofins as dec.
def var deb-pis as dec.
def var deb-cofins as dec.
def var vicms as dec.

update vprocod label "Produto"
    with frame f1 1 down width 80 side-label no-box row 4
    color message.

find produ where produ.procod = vprocod no-lock.

disp produ.pronom no-label with frame f1.

find estoq where estoq.etbcod = 900 and
                 estoq.procod = produ.procod
                 no-lock no-error.
if not avail estoq
then
find estoq where estoq.etbcod = 993 and
                 estoq.procod = produ.procod
                 no-lock no-error.
if avail estoq
then assign
        val-prvenda = estoq.estvenda
        vl-produto  = estoq.estcusto.
                                        
disp    vl-produto at 1  label "Valor Produto"       format ">>,>>9.99"
        val-in           label "ICMS Entrada    "
        pct-in           no-label format ">>9.99%" 
        val-ipi    at 26 label "IPI Entrada     "
        pct-ipi          no-label format ">>9.99%"
        val-out    at 26 label "Outras despesas "
        val-fre    at 26 label "Valor do Frete  "
        val-custo1 at 1  label "Custo Nota   "       format ">>,>>9.99"
        val-mva          label "Valor MVA       " 
        pct-mva          no-label format ">>9.99%"
        base-st    at 26 label "Base ST         "
        val-redbas at 26 label "Reducao de base "
        pct-redbas       no-label format ">>9.999%"
        "ICMS Local      :" at 26
        "          "
        pct-icms-rs      no-label  format ">>9.99%"
        val-icms-st at 26 label "ICMS S.T.       "
        val-in2     at 26 label "ICMS Entrada    "
        val-icms1   at 26 label "ICMS            "
        val-icms2   at 26 label "ICMS            "
        val-custo2  at 1  label "Custo Venda  "        format ">>,>>9.99"
        val-piscof  at 26 label "Pis/Cofins      "
        val-custo3  at 1  label "Custo Total  "        format ">>,>>9.99"
        val-prvenda at 1  label "Preco Venda  "        format ">>,>>9.99"
        pct-margem  at 26 label "Margem          "
        with frame f2 side-label row 5 1 down.
/****
disp   pct-pis label "PIS    " 

       
       format ">>9.99%"
       cre-pis label "Credito" format ">>9.99"
                
       deb-pis label "Debito " format ">>9.99"
       skip(2)
       pct-cofins label "COFINS "  format ">>9.99%"
       cre-cofins label "Credito" format ">>9.99"
       deb-cofins label "Debito "  format ">>9.99"
        with frame f3 row 6 1 down column 65 
        no-box side-label.
***/


update  vl-produto with frame f2.
 
assign
    pct-pisc = 0
    pct-pisd = 0
    cre-pis = 0
    deb-pis = 0
    pct-cofinsc = 0
    pct-cofinsd = 0
    cre-cofins = 0
    deb-cofins = 0
    .
    
run p-piscofins(input produ.codfis).

assign
    cre-pis = vl-produto * (pct-pisc / 100)
    deb-pis = val-prvenda * (pct-pisd / 100)
    cre-cofins = vl-produto * (pct-cofinsc / 100)
    deb-cofins = val-prvenda * (pct-cofinsd / 100)
    .
disp   "PIS CREDITO" 
       pct-pisc no-label  format ">>9.99%"
       cre-pis no-label  format ">>9.99"
       "PIS DEBITO"
       pct-pisd no-label  format ">>9.99%"         
       deb-pis  no-label  format ">>9.99"
       skip(1)
       "COFINS CREDITO"
       pct-cofinsc no-label format ">>9.99%"
       cre-cofins  no-label format ">,>>9.99"
       "COFINS DEBITO"
       pct-cofinsd no-label format ">>9.99%"
       deb-cofins  no-label format ">,>>9.99"
       with frame f3 row 6 1 down column 65 
       no-box side-label.
val-piscof = (deb-pis + deb-cofins) - (cre-pis + cre-cofins).
disp    skip(1)
        "Pis/Cofins" skip
        val-piscof no-label format ">,>>9.99"
        with frame f3.

update pct-in  with frame f2.
    if pct-in > 0
    then val-in = vl-produto * (pct-in / 100).
    disp val-in with frame f2.

update  pct-ipi with frame f2.
    if pct-ipi > 0
    then val-ipi = vl-produto * (pct-ipi / 100).
    disp val-ipi with frame f2.

update  val-out 
        val-fre with frame f2.
    val-custo1 = vl-produto + val-ipi + val-out + val-fre.
    disp  val-custo1 with frame f2.

update  pct-mva  with frame f2.
    if pct-mva > 0
    then val-mva = val-custo1 * (pct-mva / 100).
    disp val-mva with frame f2.
    
    base-st  = val-custo1 + val-mva.
    disp base-st with frame f2.
    
update  pct-redbas with frame f2.
    val-redbas = base-st * (pct-redbas / 100).
    disp val-redbas with frame f2.
    
vicms = 0.
run busca-aliquota.
pct-icms-rs = vicms.

disp  pct-icms-rs with frame f2.
    if val-redbas > 0
    then val-icms-st = val-redbas * (pct-icms-rs / 100).
    else if base-st > 0
    then val-icms-st = base-st * (pct-icms-rs / 100).
    disp val-icms-st 
         val-in with frame f2.
    val-icms1 = val-icms-st - val-in.
    if val-icms1 < 0
    then val-icms1 = 0.
    val-custo2 = val-custo1 + val-icms1.
    val-custo3 = val-custo2 + val-piscof.
    pct-margem = ((val-prvenda - val-custo3) / val-prvenda) * 100. 
    disp val-icms1 
         val-custo2
         val-piscof
         val-custo3
         val-prvenda
         pct-margem
         with frame f2 side-label.

pause.

procedure busca-aliquota:
   def var vali as char.
        
       if produ.proipiper = 17 or
          produ.proipiper = 0
       then vali = "01".
       if produ.proipiper = 12.00 or
          produ.pronom begins "Computa"
       then vali = "FF".
       if produ.pronom begins "Pneu" or
          produ.proipiper = 99
       then vali = "FF".
       if produ.proseq = 1
          then vali = "03".
    
        if vali = "01"
        then vicms = 17.
        else if vali = "02"
             then vicms = 12.
             else if vali = "03"
                  then vicms = 7.
                  else if vali = "04"
                       then vicms = 25.
                       else vicms = 0.
                                    
end procedure.

procedure p-piscofins:
    def input parameter pcodfis as char.
    def var base-pis as dec.
    def var aux-uf as char.

    pcodfis = replace(pcodfis,".","").
       
    if aux-uf = "AM"
    then assign 
            pct-pisc    = 1
            pct-pisd    = 1
            pct-cofinsc = 4.6
            pct-cofinsd = 4.6
            .     
    else 
        if int(pcodfis) = 0
        then assign 
                pct-pisc = 1.65
                pct-pisd = 1.65
                pct-cofinsc = 7.6
                pct-cofinsd = 7.6
                .  
        else do:
            find clafis where clafis.codfis = int(pcodfis) 
                    no-lock no-error.
            if avail clafis
            then assign
                pct-pisc    = clafis.pisent
                pct-cofinsc = clafis.cofinsent
                pct-pisd    = clafis.pissai
                pct-cofinsd = clafis.cofinssai
                .
        end.
     

end procedure.


/**********************
procedure p-pis-capa.
    def buffer bxmovim for movim.
     
     assign valpis-capa = 0
            basepis-capa = 0
            valcofins-capa = 0.

  
     for each bxmovim where bxmovim.etbcod = plani.etbcod and
                                         bxmovim.placod = plani.placod and
                                         bxmovim.movtdc = plani.movtdc and
                                         bxmovim.movdat = plani.pladat no-lock:
                   
                        
                        frete_item = 0.
                        if bxmovim.movdev > 0
                        then frete_item = bxmovim.movdev.
                        
                        
                        if bxmovim.movpc = 0 or
                           bxmovim.movqtm = 0
                        then next. 
 
                        tot_pro = bxmovim.movqtm * bxmovim.movpc.
                        vcodfis = "".
                        vsittri = "".
                    
                        find produ where produ.procod = bxmovim.procod 
                                            no-lock no-error.
                                        
                        if not avail produ
                        then next.
                        
                    
                        if produ.codfis > 0
                        then vcodfis = substring(string(produ.codfis),1,4) + 
                                       "." +   
                                       substring(string(produ.codfis),5,2) +  
                                       "." +  
                                       substring(string(produ.codfis),7,2).
                        if produ.codori > 0
                        then vsittri = string(produ.codori) + 
                                       string(produ.codtri).
                        
                        base_subs  = 0.
                        valor_subs = 0.
                    
                        /****
                        if (vsittri = "170" or
                            vsittri = "270") and
                           fiscal.movtdc <> 12 
                        then do:
                        
                            base_subs  = tot_pro + 
                                         ((tot_pro - (tot_pro * 0.0519)) 
                                         * 0.578259).
                                    
                            valor_subs = (tot_pro + ((tot_pro - 
                                         (tot_pro * 0.0519)) * 0.578259))
                                          * 0.0965156.

                        end.   
                        ***/
                        
                        base_ipi = 0.
                    
                        if plani.ipi > 0
                        then base_ipi = ((bxmovim.movpc + frete_item) 
                                         * bxmovim.movqtm).
                            
                        if plani.protot > 0
                        then

                        base_icms = (fiscal.bicms / plani.protot) * 
                                    (bxmovim.movpc * bxmovim.movqtm).
     
                        if fiscal.platot > 0
                        then vdes = (plani.descprod / fiscal.platot) * 
                                    (bxmovim.movpc * bxmovim.movqtm).
                  
                        vipi  = base_ipi  * (bxmovim.movalipi / 100).
                        vicms = base_icms * (bxmovim.movalicms / 100). 
                    
                        
                       
                        val_contabil = ((bxmovim.movpc + frete_item) 
                                        * bxmovim.movqtm) + vipi.
 

                        visenta = val_contabil - base_icms - vipi.
                        if visenta < 0
                        then visenta = 0.

                        voutras = val_contabil - base_icms - vipi - visenta.
                        
                                                       
                        if fiscal.opfcod = 1915 or
                           fiscal.opfcod = 2915 
                        then assign voutras = val_contabil
                                    visenta = 0.

                        
                        if voutras < 0
                        then voutras = 0.
                        
                        valor_item = bxmovim.movpc.

                        if vopccod = "1949" or 
                           vopccod = "2949"
                        then do:   
                
                            if plani.bicms > 0
                            then assign base_icms = val_contabil
                                        voutras   = 0.
                            else assign base_icms = 0
                                        voutras   = val_contabil.    
                        end.
                        
                        valicm = ((valor_item * bxmovim.movqtm) * 
                                     (bxmovim.movalicms / 100)).
                        
                        if vopccod = "1102" or
                           vopccod = "2102" or
                           vopccod = "1202" /*
                           vopccod = "1910" or
                           vopccod = "2910" or
                           vopccod = "2102" or
                           vopccod = "1949" or
                           vopccod = "2949" or
                           vopccod = "2124" or
                           vopccod = "2353" */
                        then do: 
                            
                            visenta = 0.
                            run trata_cfop.p (input vopccod, 
                                              input bxmovim.procod,
                                              input ((bxmovim.movpc + 
                                                      frete_item)
                                                     * bxmovim.movqtm),
                                              input bxmovim.movalicms,   
                                              input bxmovim.movicms,   
                                              input bxmovim.movsubst,
                                              output base_icms,  
                                              output visenta,  
                                              output voutras,  
                                              output vsittri,
                                              output valicm).
                            
                        end.   
                        
               run p-piscofins(produ.codfis,"E",(bxmovim.movpc * bxmovim.movqtm)
               /*(base_icms - valicm) */ ).

               assign valpis-capa = valpis-capa + val-pis
                      basepis-capa = basepis-capa + base-pis
                      valcofins-capa = valcofins-capa + val-cofins.
               /*
        if plani.numero = 235087 
        then message  produ.procod "movpc:" bxmovim.movpc 
                     "mqt:" bxmovim.movqt 
                     "val:" (bxmovim.movqt * bxmovim.movpc)
             "b:" base_icms "v:" valicm      skip
             val-pis val-cofins "codfis:" produ.codfis " vcf:" vcodfis
               view-as alert-box.
                 */
           end.           

end procedure.

*************/
