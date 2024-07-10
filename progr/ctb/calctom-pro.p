
{extrato12-def.i new}


def input parameter p-procod like produ.procod.
def input parameter p-dti as date.
def input parameter p-dtf as date.
def input parameter p-tipo as char.

/***
p-custo = "CtoTransf" /*Custo de transferencia*/
p-custo = "CtoMedio"  /*Custo Medio*/
p-custo = "CtoNota"   /*custo ultima entrada*/
***/

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
def var vctotra-ant as dec.
def var vctotra-atu as dec.
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
def var vmovtrans as dec.
def var vicms as dec.
def var vicmssubst as dec.
def buffer bestab for estab. 
def var mvcusto-ok as log.

def var vi as int.
def buffer bprodu for produ.
def var vdtref as date.

def new shared temp-table tt-plani like plani.
def new shared temp-table tt-movim like movim.
def temp-table tt-bmovim like movim.

def temp-table cc-movim
    field rec-movim as recid
    field rec-plani as recid
    field dtinclu like plani.dtinclu
    field horincl like plani.horincl
    index i1 dtinclu horincl.
    
def var vdtf as date.
def var vdatai as date.
def var vdataf as date.
def var vmesi as int.
def var vanoi as int.
def var vmovii as dec.
vdatai = p-dti.
vdataf = p-dtf.

def var vcustoimp as dec.

def buffer bmvcusto for mvcusto.

if month(vdatai) = 1
then assign vmesi = 12
            vanoi = year(vdatai) - 1.
else assign vmesi = month(vdatai) - 1
            vanoi = year(vdatai).
assign
        vdti = vdatai
        vdtf = vdataf
        vdtref = vdti.
 
for each bprodu where bprodu.procod = p-procod no-lock:
    
    output to ./produ.ultimo.
    put "b1 " bprodu.procod format ">>>>>>>>>9".
    output close.
    
    find clafis where clafis.codfis = bprodu.codfis no-lock no-error.
    if not avail clafis then next.
    /*
    if bprodu.catcod <> 31 and
       bprodu.catcod <> 41
    then next.   
    */
    /*
    disp bprodu.procod format ">>>>>>>>9" 
    bprodu.codfis format "99999999"
    clafis.mva_estado1
    with 1 down.
    pause 0.
    */
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
            vqtdest-ant = ctbhie.ctbven /*ctbhie.ctbest*/.   
    else find last ctbhie use-index ind-2 where
                    ctbhie.etbcod = 0 and
                    ctbhie.procod = bprodu.procod and
                    ctbhie.ctbano = vano and
                    ctbhie.ctbmes < vmes
                    no-lock no-error.
        if avail ctbhie
        then assign
                 vctomed-ant = ctbhie.ctbcus
                 vqtdest-ant = ctbhie.ctbven /*ctbhie.ctbest*/
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
                vqtdest-ant = ctbhie.ctbven /*ctbhie.ctbest*/.
                leave.
            end.
        end. 
    mvcusto-ok = no.
    find last bmvcusto where bmvcusto.procod = bprodu.procod and
                            bmvcusto.dativig <= vdti
                no-lock no-error.
    if avail bmvcusto 
    then do:
        /*if p-tipo <> "REPROCESSAMENTO"
                and bmvcusto.valctomedio <> vctomed-ant
        then*/ vctomed-ant = bmvcusto.valctomedio.    
        vctotra-ant = bmvcusto.valctotransf.
        mvcusto-ok = yes.
    end.
    
    if not mvcusto-ok
    then vctomed-ant = 0.
    
    assign
        vdti = vdatai
        vdtf = vdataf
        vdtref = vdti.
    for each tt-bmovim:
        delete tt-bmovim.
    end.    
    
    do vdata = vdti to vdtf:
        for each movim  where movim.movtdc = 4 and
                         movim.procod = bprodu.procod and
                         movim.datexp = vdata
                         no-lock,
            first plani where plani.etbcod = movim.etbcod and
                         plani.placod = movim.placod and
                         plani.movtdc = movim.movtdc
                         no-lock by plani.dtinclu by plani.horincl.
            create cc-movim.
            assign
                cc-movim.rec-movim = recid(movim)
                cc-movim.rec-plani = recid(plani)
                cc-movim.dtinclu   = plani.dtinclu
                cc-movim.horincl   = plani.horincl
                .
        end.
    end.
    
    
    do vdata = vdti to vdtf:
    find first auxmvcus where
         auxmvcus.procod = bprodu.procod and
         auxmvcus.dativig = vdata and
         auxmvcus.horivig = 0 no-lock no-error.
    if avail auxmvcus 
    then do:
            vqtdest-ant = 0.
            vdata1 = date(month(auxmvcus.dativig - 1),01,
                            year(auxmvcus.dativig - 1)).
                 
            vdata2 = auxmvcus.dativig - 1.
            vprocod = bprodu.procod.
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

        vmovtot = vctomed-ant.
        vqtdest-atu = vqtdest-ant.
        find last ctbhie where ctbhie.procod = bprodu.procod and
                               ctbhie.etbcod = 0 and
                               ctbhie.ctbano = year(auxmvcus.dativig) and
                               ctbhie.ctbmes = month(auxmvcus.dativig)
                               no-error .
        if not avail ctbhie
        then do:
            create ctbhie.
            assign
                ctbhie.etbcod = 0 
                ctbhie.procod = bprodu.procod 
                ctbhie.ctbano = year(auxmvcus.dativig)
                ctbhie.ctbmes = month(auxmvcus.dativig)
                .
        end.
        assign
            vicms = auxmvcus.custo2 / auxmvcus.estoque
            vctomed-atu = vctomed-ant - vicms
            ctbhie.ctbcus = vctomed-atu
            ctbhie.ctbest = vctomed-ant
            ctbhie.ctbven = vqtdest-ant
            .
        
        find first mvcusto where 
                   mvcusto.procod = bprodu.procod and
                   mvcusto.dativig = auxmvcus.dativig and
                   mvcusto.horivig = 0
                   no-error.
       if not avail mvcusto
       then  do:
            create mvcusto.
            assign
                mvcusto.procod = bprodu.procod
                mvcusto.dativig = auxmvcus.dativig
                mvcusto.horivig = 0
                .
        end.        
        assign
            mvcusto.etbcod = ?
            mvcusto.placod = ?
            mvcusto.serie  = ?
            mvcusto.valctonotaf = 0
            mvcusto.valctomedio = vctomed-atu
            mvcusto.estoque = vqtdest-ant
            mvcusto.custo1 = vctomed-ant
            mvcusto.datinclu = auxmvcus.dativig
            mvcusto.char1 = "QTDESTANT=" + string(vqtdest-ant) + "|" +
                            "QTDESTATU=" + string(vqtdest-atu) + "|" +
                            "CTOMEDANT=" + string(vctomed-ant) + "|" +
                            "CTOMEDATU=" + string(vctomed-atu) + "|"
            mvcusto.char2 = "CFOP1949 - CREDITO ICMS ST = " +
                        string(vicms,">>>,>>9.99")
            vicms = 0.            

        assign
            vdtref = auxmvcus.dativig
            vctomed-ant = vctomed-atu
            vqtdest-ant = vqtdest-atu
            vctomed-atu = 0
            vqtdest-atu = 0.
 
    end.
    for each tt-bmovim:
        delete tt-bmovim.
    end. 
    for each cc-movim where 
             cc-movim.dtinclu = vdata no-lock,
        first movim  where recid(movim) = cc-movim.rec-movim
                         no-lock,
        first plani where recid(plani) = cc-movim.rec-plani
                        no-lock:
        
        find first forne where forne.forcod = movim.emite no-lock no-error.
        find cpforne of forne no-lock no-error.
        find first clafis where clafis.codfis = bprodu.codfis no-lock no-error.
        assign 
            vmovtot = movim.movpc
            vmovfre = if plani.frete > 0 and
                         movim.movdev > 0
                      then movim.movdev
                      else if movim.movdev > 0   
                           then (movim.movdev / movim.movqtm)
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
                        then movim.movsubst / movim.movqtm
                        else 0
            vicms =  if movim.movalicms > 0
                     then (movim.movpc + vmovfre) *
                      (movim.movalicms / 100)
                     else 0
            vmovii = movim.movii / movim.movqtm.
            vmovcusto = (vmovtot + vmovfre + vmovseg + vmovacre +
                        vmovipi + vmovdacess + vmovii) - vmovdes  .
        
        /*
        if vmovfre > vmovtot
        then vmovfre = vmovfre / movim.movqtm.
        */
        vcustoimp = 0.
        if substr(string(movim.opfcod),1,1) = "3"
        then do:
            for each fatudesp where
                     fatudesp.numerodi = plani.numprocimp and
                     fatudesp.modctb   = "DIP"
                     no-lock:
                vcustoimp = vcustoimp + 
                        ((fatudesp.val-liquido *
                    ((movim.movpc * movim.movqtm) / plani.protot))
                    / movim.movqtm).
 
            end.         
        end.
        vmovdacess = vmovdacess + vcustoimp.
        vmovcusto = vmovcusto + vcustoimp.
        
        vprocod = bprodu.procod.
        
        /*************
        if forne.ufecod <> "SP" and
           forne.ufecod <> "AP" and
           forne.ufecod <> "MG" and
           forne.ufecod <> "MT" and
           forne.ufecod <> "PR" and
           forne.ufecod <> "RJ" and
           forne.ufecod <> "RS" and
           forne.ufecod <> "SC"
        /*if forne.ufecod = "AM"*/
        then vicms = (movim.movpc + vmovfre) * .12.
        
        if forne.forcod = 3035 or
           forne.forcod = 5700 or
           forne.forcod = 118505
        then vicms = (movim.movpc + vmovfre) * .07.
        ************/

        if vdtref <> plani.datexp /*and mvcusto-ok*/
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
            
            if vmovdes > 0
            then assign
                    tt-movim.movpc = tt-movim.movpc - vmovdes 
                    vicms = (tt-movim.movpc * (tt-movim.movalicms / 100))
                    .
            /*
            if tt-movim.movicms > 0
            then vicms = tt-movim.movicms / tt-movim.movqtm.
            */

            /*substituto****/
            if avail cpforne and not cpforne.log-1
            then vmovsubst = 0.
            /***/
            
            if tt-movim.opfcod <> 3102
            then do:
                run piscofins.p.

                /*substituto***/
                if avail cpforne and not cpforne.log-1
                then tt-movim.movsubst = 0.
                /*****/
            end.
            else assign
                    vicms = tt-movim.movicms / tt-movim.movqtm
                    vmovtot = (tt-movim.movbicms / tt-movim.movqtm) - 
                           (vmovfre + vmovseg + vmovacre +
                            vmovsubst + vmovipi + vmovdacess + vmovii) 
                            + vmovdes
                    .

            find first tt-movim where tt-movim.procod = movim.procod 
                 no-error.
            if avail tt-movim 
            then do:
                
                assign
                    vpis = tt-movim.movpis / tt-movim.movqtm 
                    vcofins = tt-movim.movcofins / tt-movim.movqtm
                    vmovsubst = tt-movim.movsubst / tt-movim.movqtm
                    .
          
                if vicms = 0 and tt-movim.movicms > 0
                    then
                    vicms = tt-movim.movicms / tt-movim.movqtm.
            end.                               
        end.
        /*substituto*/ 
        if vmovsubst = ? then vmovsubst = 0.
        /**/
        assign
            vmovcusto = (vmovtot + vmovfre + vmovseg + vmovacre + 
                        (vmovsubst /*- vicms*/) 
                        + vmovipi + vmovdacess + vmovii) - vmovdes 
            vmovtrans = vmovcusto + vmovsubst - vicms 
            vctomed-atu = /*(vmovtot + vmovfre + vmovseg + vmovacre 
                                + vmovipi + vmovsubst
                            + vmovii + vmovdacess )*/
                        vmovcusto - (vpis + vcofins + vicms) 
            vctomed-atu =  vctomed-atu  * movim.movqtm.
        
        vmovtrans = vmovcusto.
        if vmovsubst > 0
        then vmovtrans = vmovtrans + (vmovsubst - vicms).
        vctotra-atu = vmovtrans * movim.movqtm.

        if vqtdest-ant = ? or vqtdest-ant < 0
        then vqtdest-ant = 0.            
        if vctomed-ant = ? or vctomed-ant < 0
        then vctomed-ant = 0.
        
        if vctomed-ant = 0 then vqtdest-ant = 0.
        
        if vqtdest-ant > 0 and vctomed-ant > 0
        then vctomed-atu = vctomed-atu +
                      (vctomed-ant * vqtdest-ant).
        vctomed-atu = vctomed-atu / vqtdest-atu.
        if vctotra-atu = ? or vctotra-atu < 0
        then vctotra-atu = 0.
        if vqtdest-ant > 0 and vctotra-ant > 0
        then vctotra-atu = vctotra-atu +
                            (vctotra-ant * vqtdest-ant).
        vctotra-atu = vctotra-atu / vqtdest-atu.                    
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
            mvcusto.valctotransf = vctotra-atu
            mvcusto.valctonotaf = vmovcusto
            mvcusto.valctomedio = vctomed-atu
            mvcusto.estoque = vqtdest-ant
            mvcusto.custo1 = vctomed-ant
            mvcusto.custo2 = vctotra-ant
            mvcusto.datinclu = plani.dtinclu
            mvcusto.char1 = "QTDESTANT=" + string(vqtdest-ant) + "|" +
                            "QTDESTATU=" + string(vqtdest-atu) + "|" +
                            "CTOMEDANT=" + string(vctomed-ant) + "|" +
                            "CTOMEDATU=" + string(vctomed-atu) + "|" +
                            "CTOTRAANT=" + string(vctotra-ant) + "|" +
                            "CTOTRAATU=" + string(vctotra-atu) + "|"
            mvcusto.char2 = "VALPRODU=" + string(vmovtot) + "|" +
                            "VALIPI=" + string(vmovipi) + "|" +
                            "VALFRETE=" + string(vmovfre) + "|" +
                            "VALPIS=" + string(vpis) + "|" +
                            "VALCOFINS=" + string(vcofins) + "|" +
                            "VALSUBST=" + string(vmovsubst) + "|" +
                            "VALICMS=" + string(vicms) + "|" +
                            "VALII=" + string(vmovii) + "|" +
                            "VALSEG=" + string(vmovseg) + "|" +
                            "VALACRE=" + string(vmovacre) + "|" +
                            "VALDESP=" + string(vmovdacess) + "|" +
                            "VALDES=" + string(vmovdes) + "|" +
                            "MVAESTADO=" + string(clafis.mva_estado1) + "|" +
                            "MVAOUTESTADO=" + string(clafis.mva_oestado1) + "|"
                            .
        /*
        run cal-mvcusto-ctomed.p(input recid(mvcusto),output vctomed-atu).
        */
        assign
            /*mvcusto.valctomedio = vctomed-atu
            */
            vdtref = plani.dtinclu
            vctomed-ant = vctomed-atu
            vqtdest-ant = vqtdest-atu
            vctomed-atu = 0
            vqtdest-atu = 0
            vctotra-ant = vctotra-atu
            vctotra-atu = 0.
 
    end.
    end.
end. 

/*************                                  
for each bprodu  where bprodu.procod = p-procod and
                       bprodu.fabcod = 5027
                no-lock:
    output to ./produ.ultimo.
    put "b2 " bprodu.procod format ">>>>>>>>>9" .
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
            vqtdest-ant = ctbhie.ctbven /*ctbhie.ctbest*/.   
    else find last ctbhie use-index ind-2 where
                    ctbhie.etbcod = 0 and
                    ctbhie.procod = bprodu.procod and
                    ctbhie.ctbano = vano and
                    ctbhie.ctbmes < vmes
                    no-lock no-error.
        if avail ctbhie
        then assign
                 vctomed-ant = ctbhie.ctbcus
                 vqtdest-ant = ctbhie.ctbven /*ctbhie.ctbest*/
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
                vqtdest-ant = ctbhie.ctbven /*ctbhie.ctbest*/.
                leave.
            end.
        end. 
    find last bmvcusto where bmvcusto.procod = bprodu.procod and
                            bmvcusto.dativig <= vdti
                no-lock no-error.
    if avail bmvcusto 
    then do:
        if p-tipo <> "REPROCESSAMENTO"
                and bmvcusto.valctomedio <> vctomed-ant
        then vctomed-ant = bmvcusto.valctomedio.    
        vctotra-ant = bmvcusto.valctotransf.
    end.

    vdti = vdatai.
    vdtf = vdataf.
    vdtref = vdti.

    for each tt-bmovim:
        delete tt-bmovim.
    end.    
    do vdata = vdti to vdtf:
    find first auxmvcus where
         auxmvcus.procod = bprodu.procod and
         auxmvcus.dativig = vdata and
         auxmvcus.horivig = 0 no-lock no-error.
    if avail auxmvcus
    then do:
            vqtdest-ant = 0.
            vdata1 = date(month(auxmvcus.dativig - 1),01,
                            year(auxmvcus.dativig - 1)).
                 
            vdata2 = auxmvcus.dativig - 1.
            vprocod = bprodu.procod.
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

        vmovtot = vctomed-ant.
        vqtdest-atu = vqtdest-ant.
        find last ctbhie where ctbhie.procod = bprodu.procod and
                               ctbhie.etbcod = 0 and
                               ctbhie.ctbano = year(auxmvcus.dativig) and
                               ctbhie.ctbmes = month(auxmvcus.dativig)
                               no-error .
        if not avail ctbhie
        then do:
            create ctbhie.
            assign
                ctbhie.etbcod = 0 
                ctbhie.procod = bprodu.procod 
                ctbhie.ctbano = year(auxmvcus.dativig)
                ctbhie.ctbmes = month(auxmvcus.dativig)
                .
        end.
        assign
            vicms = auxmvcus.custo2 / auxmvcus.estoque
            vctomed-atu = vctomed-ant - vicms
            ctbhie.ctbcus = vctomed-atu
            ctbhie.ctbest = vctomed-ant
            ctbhie.ctbven = vqtdest-ant
            .

        
        find first mvcusto where 
                   mvcusto.procod = bprodu.procod and
                   mvcusto.dativig = auxmvcus.dativig and
                   mvcusto.horivig = 0
                   no-error.
       if not avail mvcusto
       then  do:
            create mvcusto.
            assign
                mvcusto.procod = bprodu.procod
                mvcusto.dativig = auxmvcus.dativig
                mvcusto.horivig = 0
                .
        end.        
        assign
            mvcusto.etbcod = ?
            mvcusto.placod = ?
            mvcusto.serie  = ?
            mvcusto.valctonotaf = 0
            mvcusto.valctomedio = vctomed-atu
            mvcusto.estoque = vqtdest-ant
            mvcusto.custo1 = vctomed-ant
            mvcusto.datinclu = auxmvcus.dativig
            mvcusto.char1 = "QTDESTANT=" + string(vqtdest-ant) + "|" +
                            "QTDESTATU=" + string(vqtdest-atu) + "|" +
                            "CTOMEDANT=" + string(vctomed-ant) + "|" +
                            "CTOMEDATU=" + string(vctomed-atu) + "|"
            mvcusto.char2 = "CFOP1949 - CREDITO ICMS ST = " +
                        string(vicms,">>>,>>9.99")
            vicms = 0.            
            /***
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
                **/
        assign
            vdtref = auxmvcus.dativig
            vctomed-ant = vctomed-atu
            vqtdest-ant = vqtdest-atu
            vctomed-atu = 0
            vqtdest-atu = 0.
 
 
    end.
    for each tt-bmovim:
        delete tt-bmovim.
    end.  
    for each movim use-index datsai where movim.movtdc = 6 and
                         movim.procod = bprodu.procod and
                         movim.etbcod = 22 and
                         movim.datexp = vdata
                         /*
                          movim.datexp >= vdti 
                         and movim.datexp < vdtf
                         */
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
            vmovfre = if plani.frete > 0 and
                         movim.movdev > 0
                      then movim.movdev
                      else if movim.movdev > 0   
                           then (movim.movdev / movim.movqtm)
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
        
        /***************
        if forne.ufecod <> "SP" and
           forne.ufecod <> "AP" and
           forne.ufecod <> "MG" and
           forne.ufecod <> "MT" and
           forne.ufecod <> "PR" and
           forne.ufecod <> "RJ" and
           forne.ufecod <> "RS" and
           forne.ufecod <> "SC"
        /*if forne.ufecod = "AM"*/
        then vicms = (movim.movpc + vmovfre) * .12.
        
        *******/
        
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
            vmovtrans = vmovcusto + vmovsubst
            vctomed-atu = (vmovtot + vmovipi + vmovfre)
                     - (vpis + vcofins) + (vmovsubst - vicms) 
            vctomed-atu =  vctomed-atu  * movim.movqtm
            .
            
        vmovtrans = vmovtot + vmovipi + vmovfre  + vmovdacess.
        if vmovsubst > 0
        then vmovtrans = vmovtrans + (vmovsubst - vicms).
        vctotra-atu = vmovtrans * movim.movqtm.
        
        if vqtdest-ant = ? or vqtdest-ant < 0
        then vqtdest-ant = 0.            
        if vctomed-ant = ? or vctomed-ant < 0
        then vctomed-ant = 0.
        if vqtdest-ant > 0 and
               vctomed-ant > 0
        then vctomed-atu = vctomed-atu +
                      (vctomed-ant * vqtdest-ant).
        vctomed-atu = vctomed-atu / vqtdest-atu.
        if vctotra-atu = ? or vctotra-atu < 0
        then vctotra-atu = 0.
        if vqtdest-ant > 0 and vctotra-ant > 0
        then vctotra-atu = vctotra-atu +
                            (vctotra-ant * vqtdest-ant).
        vctotra-atu = vctotra-atu / vqtdest-atu.  
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
            mvcusto.valctotransf = vctotra-atu
            mvcusto.valctonotaf = vmovcusto
            mvcusto.valctomedio = vctomed-atu
            mvcusto.estoque = vqtdest-ant
            mvcusto.custo1 = vctomed-ant
            mvcusto.custo2 = vctotra-ant
            mvcusto.datinclu = plani.dtinclu
            mvcusto.char1 = "QTDESTANT=" + string(vqtdest-ant) + "|" +
                            "QTDESTATU=" + string(vqtdest-atu) + "|" +
                            "CTOMEDANT=" + string(vctomed-ant) + "|" +
                            "CTOMEDATU=" + string(vctomed-atu) + "|" +
                            "CTOTRAANT=" + string(vctotra-ant) + "|" +
                            "CTOTRAATU=" + string(vctotra-atu) + "|"
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
            vqtdest-atu = 0
            vctotra-ant = vctotra-atu
            vctotra-atu = 0
            .
 
    end.
    end.
 end.  
 *********/
