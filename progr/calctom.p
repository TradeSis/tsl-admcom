                                      
{extrato12-def.i new}

pause 0 before-hide.

def var vultimo as dec.
def var vcusto as dec.
def var vqtd as dec.
def var vcto-atu as dec.
def var vqtd-atu as dec.
def var vctomed-ini as dec.
def var vctomed-atu as dec.
def var vctomed-ant as dec.
def var vqtdest-ant as dec.
def var vqtdest-atu as dec.
def var vpis as dec.
def var vcofins as dec.
def buffer vmovim for movim.
def var vdti as date.
def var vmovtot as dec.
def var vmovfre as dec.
def var vmovseg as dec.
def var vmovacre as dec.
def var vmovipi as dec.
def var vmovdacess as dec.
def var vmovdes as dec.
def var vmovacf as dec.
def var vmovsubst as dec.
def var vmovcusto as dec.
def var vicms as dec.
def var vicmssubst as dec.
def buffer bestab for estab. 

def var vi as int.
def buffer bprodu for produ.
def var vdtref as date.

def new shared temp-table tt-plani like plani.
def new shared temp-table tt-movim like movim.
def temp-table tt-bmovim like movim.

def var vdtf as date.
def var vdatai as date.
def var vdataf as date.
def var vmesi as int.
def var vanoi as int.

update vdatai vdataf with frame f-data.
if month(vdatai) = 1
then assign vmesi = 12
            vanoi = year(vdatai) - 1.
else assign vmesi = month(vdatai) - 1
            vanoi = year(vdatai).
 

for each bprodu no-lock:
    
    output to ./produ.ultimo.
    put "b1 " bprodu.procod .
    output close.
    
    find clafis where clafis.codfis = bprodu.codfis no-lock no-error.
    if not avail clafis then next.
    /*if clafis.mva_estado1 = 0
    then next.
    */
    if bprodu.catcod <> 31 and
       bprodu.catcod <> 41
    then next.   
    disp bprodu.procod format ">>>>>>>>9" 
    bprodu.codfis format "99999999"
    clafis.mva_estado1
    with 1 down.
    pause 0.
    assign
        vctomed-ant = 0
        vqtdest-ant = 0
        .
    vano = vanoi.
    vmes = vmesi.
    find first ctbhie where ctbhie.procod = bprodu.procod and
                      ctbhie.etbcod = 0 and
                      ctbhie.ctbano = vano and
                      ctbhie.ctbmes = vmes
                      no-lock no-error.
    if avail ctbhie
    then assign
            vctomed-ant = ctbhie.ctbcus
            vqtdest-ant = ctbhie.ctbest.   
    else find last ctbhie use-index ind-2 where
                    ctbhie.etbcod = 0 and
                    ctbhie.procod = bprodu.procod and
                    ctbhie.ctbano = vano and
                    ctbhie.ctbmes < vmes
                    no-lock no-error.
        if avail ctbhie
        then assign
                 vctomed-ant = ctbhie.ctbcus
                 vqtdest-ant = ctbhie.ctbest
                 .
        else do vi = 1 to 10:
            find last ctbhie use-index ind-2 where
                     ctbhie.etbcod = 0 and
                     ctbhie.procod = bprodu.procod and
                     ctbhie.ctbano = vano - vi 
                     no-lock no-error.
            if avail ctbhie
            then do:
                vctomed-ant = ctbhie.ctbcus.
                vqtdest-ant = ctbhie.ctbest.
                leave.
            end.
        end. 
     
    vdti = vdatai.
    vdtf = vdataf.
    vdtref = vdti.

    for each tt-bmovim:
        delete tt-bmovim.
    end.    
    
    for each movim  where movim.movtdc = 4 and
                         movim.procod = bprodu.procod
                         and movim.datexp >= vdti 
                         and movim.datexp < vdtf
                         no-lock by datexp.

        
        find first plani where plani.etbcod = movim.etbcod and
                         plani.placod = movim.placod and
                         plani.movtdc = movim.movtdc
                         no-lock no-error.
        if not avail plani then next.
        

        find first forne where forne.forcod = plani.emite no-lock no-error.
        find first clafis where clafis.codfis = bprodu.codfis no-lock no-error.
        assign 
            vmovtot = movim.movpc
            vmovfre = if movim.movdev > 0 then (movim.movdev / movim.movqtm)
                      else if plani.frete > 0
                           then (plani.frete / plani.protot) * movpc
                           else 0 
            vmovseg = if plani.seguro > 0
                      then (plani.seguro / plani.protot) * movpc
                      else 0
            vmovacre = if plani.acfprod > 0
                       then (plani.acfprod / plani.protot) * movpc
                       else 0
            vmovipi  = if movim.movipi > 0
                       then movim.movipi / movim.movqtm
                       else 0
            vmovdacess = if plani.desacess > 0
                    then (plani.desacess / plani.protot) * movpc
                    else 0
            vmovdes = if movim.movdes > 0  then movim.movdes
                      else if plani.descprod > 0
                           then (plani.descprod / plani.protot) * movpc
                           else 0
            vmovsubst = if movim.movbsubst > 0 and
                           movim.movsubst  > 0
                        then movim.movsubst
                        else 0
            vicms =  if movim.movalicms > 0
                     then (movim.movpc + vmovfre) *
                      (movim.movalicms / 100)
                     else 0
            vmovcusto = vmovtot + vmovfre + vmovseg + vmovacre +
                        vmovipi + vmovdacess - vmovdes  .
        
        vprocod = bprodu.procod.
        
        if forne.ufecod = "AM"
        then vicms = (movim.movpc + vmovfre) * .12.
        
        if vdtref <> plani.datexp
        then do:
            vqtdest-ant = 0.
            vdata1 = 
                 date(month(plani.datexp - 1),01,year(plani.datexp - 1)).
                vdata2 = plani.datexp - 1.
 
            for each bestab no-lock:
                vetbcod = bestab.etbcod.
                sal-atu = 0.
                for each tt-saldo: delete tt-saldo. end.
                for each tt-movest: delete tt-movest. end.
                assign
                    sal-atu = 0
                    sal-ant = 0
                    t-sai = 0
                    t-ent = 0
                    vdisp = no.

                if vetbcod = 981
                then run movest11-e.p.
                else run movest11.p.
                vqtdest-ant = vqtdest-ant + sal-atu.
            end.
        end.    
        if vqtdest-ant < 0
        then vqtdest-ant = 0.
        vqtdest-atu = vqtdest-ant + movim.movqtm.
        
        vpis = 0.
        vcofins = 0.

        for each tt-movim: delete tt-movim. end.
        for each tt-plani: delete tt-plani. end.
        
        do:        
            create tt-plani.
            buffer-copy plani to tt-plani.
            create tt-movim.
            buffer-copy movim to tt-movim.
            /*
            run piscofins-claudir.p.
            */
            
            run piscofins.p.

            find first tt-movim where tt-movim.procod = movim.procod 
                 no-error.
            if avail tt-movim 
            then assign
                    vpis = tt-movim.movpis / tt-movim.movqtm 
                    vcofins = tt-movim.movcofins / tt-movim.movqtm
                    vmovsubst = tt-movim.movsubst / tt-movim.movqtm
                    .
        end.
        
        assign
            vmovcusto = vmovtot + vmovipi + vmovfre
            vctomed-atu = (vmovtot + vmovipi + vmovfre)
                     - (vpis + vcofins) + (vmovsubst - vicms) 
            vctomed-atu =  vctomed-atu  * movim.movqtm
            .
                     
        
        if vqtdest-ant = ? or vqtdest-ant < 0
        then vqtdest-ant = 0.            
        if vctomed-ant = ? or vctomed-ant < 0
        then vctomed-ant = 0.
        
        if vqtdest-ant > 0 and
               vctomed-ant > 0
        then vctomed-atu = vctomed-atu +
                      (vctomed-ant * vqtdest-ant).
        
        vctomed-atu = vctomed-atu / vqtdest-atu.
        
        find last ctbhie where ctbhie.procod = bprodu.procod and
                               ctbhie.etbcod = 0 and
                               ctbhie.ctbano = year(plani.dtinclu) and
                               ctbhie.ctbmes = month(plani.dtinclu)
                               no-error .
        if not avail ctbhie
        then do:
            create ctbhie.
            assign
                ctbhie.etbcod = 0 
                ctbhie.procod = bprodu.procod 
                ctbhie.ctbano = year(plani.dtinclu)
                ctbhie.ctbmes = month(plani.dtinclu)
                .
        end.
        assign
            ctbhie.ctbcus = vctomed-atu
            ctbhie.ctbest = vctomed-ant
            ctbhie.ctbven = vqtdest-ant
            .
        
        find first mvcusto where 
                   mvcusto.procod = movim.procod and
                   mvcusto.dativig = plani.dtinclu and
                   mvcusto.horivig = plani.horincl
                   no-error.
       if not avail mvcusto
       then  do:
            create mvcusto.
            assign
                mvcusto.procod = movim.procod
                mvcusto.dativig = plani.dtinclu
                mvcusto.horivig = plani.horincl
                .
        end.        
        assign
            mvcusto.etbcod = plani.etbcod
            mvcusto.placod = plani.placod
            mvcusto.serie  = plani.serie
            mvcusto.valctonotaf = vmovcusto
            mvcusto.valctomedio = vctomed-atu
            mvcusto.estoque = vqtdest-ant
            mvcusto.custo1 = vctomed-ant
            mvcusto.datinclu = plani.dtinclu
            mvcusto.char1 = "QTDESTANT=" + string(vqtdest-ant) + "|" +
                            "QTDESTATU=" + string(vqtdest-atu) + "|" +
                            "CTOMEDANT=" + string(vctomed-ant) + "|" +
                            "CTOMEDATU=" + string(vctomed-atu) + "|"
            mvcusto.char2 = "VALPRODU=" + string(vmovtot) + "|" +
                            "VALIPI=" + string(vmovipi) + "|" +
                            "VALFRETE=" + string(vmovfre) + "|" +
                            "VALPIS=" + string(vpis) + "|" +
                            "VALCOFINS=" + string(vcofins) + "|" +
                            "VALSUBST=" + string(vmovsubst) + "|" +
                            "VALICMS=" + string(vicms) + "|" +
                            "VALSEG=" + string(vmovseg) + "|" +
                            "VALACRE=" + string(vmovacre) + "|" +
                            "VALDESP=" + string(vmovdacess) + "|" +
                            "VALDES=" + string(vmovdes) + "|" +
                            "MVAESTADO=" + string(clafis.mva_estado1) + "|" +
                            "MVAOUTESTADO=" + string(clafis.mva_oestado1) + "|"
                            .
        
        assign
            vdtref = plani.dtinclu
            vctomed-ant = vctomed-atu
            vqtdest-ant = vqtdest-atu
            vctomed-atu = 0
            vqtdest-atu = 0.
 
    end.
 end. 
                                  
for each bprodu  where bprodu.fabcod = 5027
                no-lock:
    output to ./produ.ultimo.
    put "b2 " bprodu.procod .
    output close.
    
    find clafis where clafis.codfis = bprodu.codfis no-lock no-error.
    if not avail clafis then next.
    /*if clafis.mva_estado1 = 0
    then next.
    */
    if bprodu.catcod <> 31 and
       bprodu.catcod <> 41
    then next.   
    disp bprodu.procod format ">>>>>>>>9" 
    bprodu.codfis format "99999999"
    clafis.mva_estado1
    with 1 down.
    pause 0.
    assign
        vctomed-ant = 0
        vqtdest-ant = 0
        .
    vano = vanoi.
    vmes = vmesi.
    find first ctbhie where ctbhie.procod = bprodu.procod and
                      ctbhie.etbcod = 0 and
                      ctbhie.ctbano = vano and
                      ctbhie.ctbmes = vmes
                      no-lock no-error.
    if avail ctbhie
    then assign
            vctomed-ant = ctbhie.ctbcus
            vqtdest-ant = ctbhie.ctbest.   
    else find last ctbhie use-index ind-2 where
                    ctbhie.etbcod = 0 and
                    ctbhie.procod = bprodu.procod and
                    ctbhie.ctbano = vano and
                    ctbhie.ctbmes < vmes
                    no-lock no-error.
        if avail ctbhie
        then assign
                 vctomed-ant = ctbhie.ctbcus
                 vqtdest-ant = ctbhie.ctbest
                 .
        else do vi = 1 to 10:
            find last ctbhie use-index ind-2 where
                     ctbhie.etbcod = 0 and
                     ctbhie.procod = bprodu.procod and
                     ctbhie.ctbano = vano - vi 
                     no-lock no-error.
            if avail ctbhie
            then do:
                vctomed-ant = ctbhie.ctbcus.
                vqtdest-ant = ctbhie.ctbest.
                leave.
            end.
        end. 
     
    vdti = vdatai.
    vdtf = vdataf.
    vdtref = vdti.

    for each tt-bmovim:
        delete tt-bmovim.
    end.    
    
    for each movim use-index datsai where movim.movtdc = 6 and
                         movim.procod = bprodu.procod and
                         movim.etbcod = 22 and
                          movim.datexp >= vdti 
                         and movim.datexp < vdtf
                         no-lock .
    
    
    
        find first plani where plani.etbcod = movim.etbcod and
                         plani.placod = movim.placod and
                         plani.movtdc = movim.movtdc
                         no-lock no-error.
        if not avail plani then next.
        

        find first forne where forne.forcod = plani.emite no-lock no-error.
        find first clafis where clafis.codfis = bprodu.codfis no-lock no-error.
        assign 
            vmovtot = movim.movpc
            vmovfre = if movim.movdev > 0 then (movim.movdev / movim.movqtm)
                      else if plani.frete > 0
                           then (plani.frete / plani.protot) * movpc
                           else 0 
            vmovseg = if plani.seguro > 0
                      then (plani.seguro / plani.protot) * movpc
                      else 0
            vmovacre = if plani.acfprod > 0
                       then (plani.acfprod / plani.protot) * movpc
                       else 0
            vmovipi  = if movim.movipi > 0
                       then movim.movipi / movim.movqtm
                       else 0
            vmovdacess = if plani.desacess > 0
                    then (plani.desacess / plani.protot) * movpc
                    else 0
            vmovdes = if movim.movdes > 0  then movim.movdes
                      else if plani.descprod > 0
                           then (plani.descprod / plani.protot) * movpc
                           else 0
            vmovsubst = if movim.movbsubst > 0 and
                           movim.movsubst  > 0
                        then movim.movsubst
                        else 0
            vicms =  if movim.movalicms > 0
                     then (movim.movpc + vmovfre) *
                      (movim.movalicms / 100)
                     else 0
            vmovcusto = vmovtot + vmovfre + vmovseg + vmovacre +
                        vmovipi + vmovdacess - vmovdes  .
        
        vprocod = bprodu.procod.
        
        if forne.ufecod = "AM"
        then vicms = (movim.movpc + vmovfre) * .12.
        
        if vdtref <> plani.datexp
        then do:
            vqtdest-ant = 0.
            vdata1 = 
                 date(month(plani.datexp - 1),01,year(plani.datexp - 1)).
                vdata2 = plani.datexp - 1.
 
            for each bestab no-lock:
                vetbcod = bestab.etbcod.
                sal-atu = 0.
                for each tt-saldo: delete tt-saldo. end.
                for each tt-movest: delete tt-movest. end.
                assign
                    sal-atu = 0
                    sal-ant = 0
                    t-sai = 0
                    t-ent = 0
                    vdisp = no.

                if vetbcod = 981
                then run movest11-e.p.
                else run movest11.p.
                vqtdest-ant = vqtdest-ant + sal-atu.
            end.
        end.    
        if vqtdest-ant < 0
        then vqtdest-ant = 0.
        vqtdest-atu = vqtdest-ant + movim.movqtm.
        
        vpis = 0.
        vcofins = 0.

        for each tt-movim: delete tt-movim. end.
        for each tt-plani: delete tt-plani. end.
        
        do:        
            create tt-plani.
            buffer-copy plani to tt-plani.
            create tt-movim.
            buffer-copy movim to tt-movim.
            /*
            run piscofins-claudir.p.
            */
            
            run piscofins.p.

            find first tt-movim where tt-movim.procod = movim.procod 
                 no-error.
            if avail tt-movim 
            then assign
                    vpis = tt-movim.movpis / tt-movim.movqtm 
                    vcofins = tt-movim.movcofins / tt-movim.movqtm
                    vmovsubst = tt-movim.movsubst / tt-movim.movqtm
                    .
        end.
        
        assign
            vmovcusto = vmovtot + vmovipi + vmovfre
            vctomed-atu = (vmovtot + vmovipi + vmovfre)
                     - (vpis + vcofins) + (vmovsubst - vicms) 
            vctomed-atu =  vctomed-atu  * movim.movqtm
            .
                     
        
        if vqtdest-ant = ? or vqtdest-ant < 0
        then vqtdest-ant = 0.            
        if vctomed-ant = ? or vctomed-ant < 0
        then vctomed-ant = 0.
        
        if vqtdest-ant > 0 and
               vctomed-ant > 0
        then vctomed-atu = vctomed-atu +
                      (vctomed-ant * vqtdest-ant).
        
        vctomed-atu = vctomed-atu / vqtdest-atu.
        
        find last ctbhie where ctbhie.procod = bprodu.procod and
                               ctbhie.etbcod = 0 and
                               ctbhie.ctbano = year(plani.dtinclu) and
                               ctbhie.ctbmes = month(plani.dtinclu)
                               no-error .
        if not avail ctbhie
        then do:
            create ctbhie.
            assign
                ctbhie.etbcod = 0 
                ctbhie.procod = bprodu.procod 
                ctbhie.ctbano = year(plani.dtinclu)
                ctbhie.ctbmes = month(plani.dtinclu)
                .
        end.
        assign
            ctbhie.ctbcus = vctomed-atu
            ctbhie.ctbest = vctomed-ant
            ctbhie.ctbven = vqtdest-ant
            .
        
        find first mvcusto where 
                   mvcusto.procod = movim.procod and
                   mvcusto.dativig = plani.dtinclu and
                   mvcusto.horivig = plani.horincl
                   no-error.
       if not avail mvcusto
       then  do:
            create mvcusto.
            assign
                mvcusto.procod = movim.procod
                mvcusto.dativig = plani.dtinclu
                mvcusto.horivig = plani.horincl
                .
        end.        
        assign
            mvcusto.etbcod = plani.etbcod
            mvcusto.placod = plani.placod
            mvcusto.serie  = plani.serie
            mvcusto.valctonotaf = vmovcusto
            mvcusto.valctomedio = vctomed-atu
            mvcusto.estoque = vqtdest-ant
            mvcusto.custo1 = vctomed-ant
            mvcusto.datinclu = plani.dtinclu
            mvcusto.char1 = "QTDESTANT=" + string(vqtdest-ant) + "|" +
                            "QTDESTATU=" + string(vqtdest-atu) + "|" +
                            "CTOMEDANT=" + string(vctomed-ant) + "|" +
                            "CTOMEDATU=" + string(vctomed-atu) + "|"
            mvcusto.char2 = "VALPRODU=" + string(vmovtot) + "|" +
                            "VALIPI=" + string(vmovipi) + "|" +
                            "VALFRETE=" + string(vmovfre) + "|" +
                            "VALPIS=" + string(vpis) + "|" +
                            "VALCOFINS=" + string(vcofins) + "|" +
                            "VALSUBST=" + string(vmovsubst) + "|" +
                            "VALICMS=" + string(vicms) + "|" +
                            "VALSEG=" + string(vmovseg) + "|" +
                            "VALACRE=" + string(vmovacre) + "|" +
                            "VALDESP=" + string(vmovdacess) + "|" +
                            "VALDES=" + string(vmovdes) + "|" +
                            "MVAESTADO=" + string(clafis.mva_estado1) + "|" +
                            "MVAOUTESTADO=" + string(clafis.mva_oestado1) + "|"
                            .
        
        assign
            vdtref = plani.dtinclu
            vctomed-ant = vctomed-atu
            vqtdest-ant = vqtdest-atu
            vctomed-atu = 0
            vqtdest-atu = 0.
 
    end.
 end.  
