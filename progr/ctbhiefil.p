{admcab.i}

def temp-table tthiest like hiest
    index i-ano-mes hieano hiemes.

def var vi as int.

def var vctomed as dec.
def var varquivo as char.
def var dtfim as date.
def var vok as log.
def var vqtd as dec.
def var vtot31 as dec.
def var vtot41 as dec.
def var vtot35 as dec.
def var vmed31 as dec.
def var vmed41 as dec.
def var vmed35 as dec.
def var wnp as i.
def var vvltotal as dec.
def var vvlcont  as dec.
def var wacr     as dec.
def var wper     as dec.
def var valortot as dec.
def var vval     as dec.
def var vval1    as dec.
def var vsal     as dec.
def var vlfinan  as dec.
def var vdti    as date format "99/99/9999".
def var vdtf    as date format "99/99/9999".
def var vetbi   like estab.etbcod.
def var vetbf   like estab.etbcod.
def var vvlcusto    like plani.platot column-label "Vl.Custo".
def var vvlvenda    like plani.platot column-label "Vl.Venda".
def var vvlmarg     like plani.platot column-label "Margem".
def var vvlperc     as dec format ">>9.99 %" column-label "Perc".
def var vvldesc     like plani.descprod column-label "Desconto".
def var vvlacre     like plani.acfprod column-label "Acrescimo".
def var vacrepre    like plani.acfprod column-label "Acr.Previsto".
def var vcatcod     like produ.catcod.
def stream stela.
def buffer bcontnf for contnf.
def buffer bplani for plani.
def var vmes like hiest.hiemes.
def var vano like hiest.hieano.
def temp-table tt-estoq
    field etbcod like estoq.etbcod
    field est41  like estoq.estatual
    field est31  like estoq.estatual
    field est35  like estoq.estatual
    field med41  like estoq.estatual
    field med31  like estoq.estatual
    field med35  like estoq.estatual.
    
def new shared temp-table tt-saldo
    field etbcod like estab.etbcod 
    field procod like produ.procod
    field codfis as int
    field sal-ant as dec
    field qtd-ent as dec
    field qtd-sai as dec
    field sal-atu as dec
    field cto-med as dec
    field ano-cto as int
    index i1 etbcod procod
    .
def var vetbest as int.
def var vproest as int.

def buffer btt-saldo for tt-saldo.

repeat:
    for each tt-estoq.
        delete tt-estoq.
    end.

    update vetbi label "Filial Inicial"
           vetbf label "Filial Final"
           with frame f-etb centered color blue/cyan side-labels
                    width 80.
        
    if vetbi = 0 or vetbf = 0 or
       vetbi > vetbf
    then undo.
           
    update skip
           vmes label "Mes..........."
           vano label "  Ano........."
           with frame f-etb.
    
    if vmes = 12
    then dtfim = date(1 , 1 , vano + 1).
    else dtfim = date(vmes + 1,1,vano).
    
    dtfim = dtfim - 1.
    vdtf = dtfim.

    find first ctbhie where ctbhie.etbcod >= vetbi and
                            ctbhie.etbcod <= vetbf and
                            ctbhie.ctbmes = vmes   and
                            ctbhie.ctbano = vano no-error.
    if avail ctbhie
    then do:
        bell.
        message color red/with
        "Saldo ja existe para filial" ctbhie.etbcod
        view-as alert-box.
        undo.
    end.

    for each tt-saldo: delete tt-saldo. end.

    def var vtot-custo as dec.

    /************
    if vetbi = 22
    then do:
        for each ctbhie where
                 ctbhie.etbcod = 22 and
                 ctbhie.ctbmes = month(vdtf) and
                 ctbhie.ctbano = year(vdtf)
                 no-lock:
          
            find produ where produ.procod = ctbhie.procod no-lock no-error.
            if not avail produ
            then find prodnewfree where
                      prodnewfree.procod = ctbhie.procod no-lock no-error.
                      
                      
            find first tt-saldo where
                       tt-saldo.etbcod = ctbhie.etbcod and
                       tt-saldo.procod = ctbhie.procod
                       no-error.
            if not avail tt-saldo
            then do:           
                create tt-saldo.
                assign
                    tt-saldo.etbcod = ctbhie.etbcod
                    tt-saldo.procod = ctbhie.procod
                    tt-saldo.codfis = 0
                    tt-saldo.sal-atu = ctbhie.ctbest
                    tt-saldo.cto-med = ctbhie.ctbcus
                    .
            end.
            else assign
                     tt-saldo.sal-atu = tt-saldo.sal-atu + ctbhie.ctbest.
    
            if avail produ then tt-saldo.codfis = produ.codfis.
            else if avail prodnewfree
                then tt-saldo.codfis = prodnewfree.codfis.
        end.       
    end.
    else  *****/
    
    for each produ no-lock:
        disp "Processando... " produ.procod format ">>>>>>>>>9" with 1 down
        side-label width 80.
        pause 0.
        for each estab where estab.etbcod >= vetbi and
                             estab.etbcod <= vetbf no-lock.

            if estab.etbcod = 22 then next.
            
            vtot35 = 0.
            vtot31 = 0.
            vtot41 = 0.
            vmed35 = 0.
            vmed31 = 0.
            vmed41 = 0.


            vqtd = 0.
            vok = no.
            find hiest where hiest.etbcod = estab.etbcod and
                             hiest.procod = produ.procod and
                             hiest.hiemes = vmes and
                             hiest.hieano = vano no-lock no-error.
            if avail hiest
            then do:
                assign vqtd = hiest.hiestf
                       vok = yes.
            end.
            else do:
                for each tthiest: delete tthiest. end.
                
                for each hiest where hiest.etbcod = estab.etbcod 
                                 and hiest.procod = produ.procod no-lock:

                    if hiest.hieano > vano 
                    then next.
                       
                    if hiest.hiemes > vmes and
                       hiest.hieano = vano
                    then next. 
                    
                    find last tthiest where tthiest.etbcod = estab.etbcod 
                                        and tthiest.procod = produ.procod 
                                        and tthiest.hiemes = hiest.hiemes
                                        and tthiest.hieano = hiest.hieano
                                        no-error.
                    if not avail tthiest 
                    then do:
                        create tthiest.
                        buffer-copy hiest to tthiest.
                    end.
        
                end.

                find last tthiest use-index i-ano-mes 
                                  no-lock no-error.
                if avail tthiest
                then do:
                    find hiest where hiest.etbcod = tthiest.etbcod 
                                 and hiest.procod = tthiest.procod 
                                 and hiest.hiemes = tthiest.hiemes 
                                 and hiest.hieano = tthiest.hieano 
                                 no-lock no-error.
                    if avail hiest 
                    then do: 

                     /*   message tthiest.etbcod
                                tthiest.procod
                                tthiest.hiemes
                                tthiest.hieano 
                                tthiest.hiestf
                                view-as alert-box.*/
                        
                        assign vqtd = hiest.hiestf 
                        vok = yes. 
                    end.
                end.
                
            end.

            if vqtd < 0
            then vqtd = 0.
            
            if vqtd = 0 then next.
            
            find estoq where estoq.etbcod = estab.etbcod and
                             estoq.procod = produ.procod no-lock no-error.
            if not avail estoq
            then next.
            
            find last ctbhie where
                 ctbhie.etbcod = 0 and
                 ctbhie.procod = produ.procod and
                 ctbhie.ctbano = vano and
                 ctbhie.ctbmes = vmes 
                 no-lock no-error.
            if not avail ctbhie
            then do vi = 1 to 10:
                find last ctbhie use-index ind-2 where
                     ctbhie.etbcod = 0 and
                     ctbhie.procod = produ.procod and
                     ctbhie.ctbano = vano - vi 
                     no-lock no-error.
                if avail ctbhie
                then do:
                    leave.
                end.
            end.     
            if avail ctbhie and ctbhie.ctbcus <> ?
            then vctomed = ctbhie.ctbcus.
            else vctomed = hiest.hiepcf.
            
            if estoq.estcusto = ? 
            then next.
            
            if vok = no
            then next.


            if produ.catcod = 31
            then assign
                    vtot31 = (vqtd * estoq.estcusto)
                    vmed31 = vqtd * vctomed.
            if produ.catcod = 41
            then assign
                    vtot41 = (vqtd * estoq.estcusto)
                    vmed41 = vqtd * vctomed.

            if produ.catcod <> 31 and
               produ.catcod <> 41
            then assign
                    vtot35 = (vqtd * estoq.estcusto)
                    vmed35 = vqtd * vctomed. 

            find first tt-estoq where tt-estoq.etbcod = estab.etbcod no-error.
            if not avail tt-estoq
            then do:
                create  tt-estoq.
                assign  tt-estoq.etbcod = estab.etbcod.
            end.
            assign tt-estoq.est41 = tt-estoq.est41 + vtot41
                   tt-estoq.est31 = tt-estoq.est31 + vtot31
                   tt-estoq.est35 = tt-estoq.est35 + vtot35
                   tt-estoq.med41 = tt-estoq.med41 + vmed41
                   tt-estoq.med31 = tt-estoq.med31 + vmed31
                   tt-estoq.med35 = tt-estoq.med35 + vmed35
                   .
        
            vetbest = estab.etbcod.
            vproest = produ.procod.
            
            find first tt-saldo where
                       tt-saldo.etbcod = vetbest and
                       tt-saldo.procod = vproest
                       no-error.
            if not avail tt-saldo
            then do:           
                create tt-saldo.
                assign
                    tt-saldo.etbcod = vetbest
                    tt-saldo.procod = vproest
                    tt-saldo.codfis = produ.codfis
                    tt-saldo.sal-atu = vqtd
                    tt-saldo.cto-med = vctomed
                    .
            end.
            else assign
                     tt-saldo.sal-atu = tt-saldo.sal-atu + vqtd.
    
        
        end.
    end.
    for each tt-saldo:
        if  tt-saldo.etbcod = 901
              or tt-saldo.etbcod = 902
              or tt-saldo.etbcod = 903
              or tt-saldo.etbcod = 905
              or tt-saldo.etbcod = 906
              or tt-saldo.etbcod = 907
              or tt-saldo.etbcod = 910
              or tt-saldo.etbcod = 919
              or tt-saldo.etbcod = 920
              or tt-saldo.etbcod = 921
              or tt-saldo.etbcod = 923
              or tt-saldo.etbcod = 924
              or tt-saldo.etbcod = 990
              or tt-saldo.etbcod = 991 
        then do:
            find first btt-saldo where btt-saldo.etbcod =  995 and
                                     btt-saldo.procod = tt-saldo.procod
                                     no-error.
            if not avail btt-saldo 
            then tt-saldo.etbcod = 995.
            else do:
                btt-saldo.sal-atu = btt-saldo.sal-atu + tt-saldo.sal-atu.
                delete tt-saldo.
            end.                          
        end.
        else if tt-saldo.etbcod = 806 or
              tt-saldo.etbcod = 500 or
              tt-saldo.etbcod = 501 or
              tt-saldo.etbcod = 600 or
              tt-saldo.etbcod = 700 or
              tt-saldo.etbcod = 981 or
              tt-saldo.etbcod = 998 
        then do:    
            find first btt-saldo where btt-saldo.etbcod =  900 and
                                     btt-saldo.procod = tt-saldo.procod
                                     no-error.
            if not avail btt-saldo 
            then tt-saldo.etbcod = 900.
            else do:
                btt-saldo.sal-atu = btt-saldo.sal-atu + tt-saldo.sal-atu.
                delete tt-saldo.
            end. 
        end.
    end.
    
    run inventario.    
    
end.

procedure inventario:
    def var aux-custo as dec decimals 6. 
    def var aux-icms  as dec.
    def var aux-liq  as dec. 
    def var aux-pis  as dec.  
    def var aux-cofins  as dec.
    def var aux-econt   as dec.
    def var aux-subst as dec.
    def var vicms      as dec label "%ICMS".
    def var vpis       as dec label "%PIS".
    def var vcofins    as dec label "%COFINS".
    def var obs-cod as char.
    def var sal-val-icms as dec.
    def var qtd-est-periodo as dec.
    def var custo-unitario-periodo as dec.
    def var val-icms-periodo as dec.
    def var varquivo as char.
    def buffer bctbhie for ctbhie.
    for each tt-saldo:
         aux-custo = tt-saldo.cto-med.

         find bctbhie where bctbhie.etbcod = tt-saldo.etbcod and
                              bctbhie.procod = tt-saldo.procod and
                              bctbhie.ctbmes = vmes         and
                              bctbhie.ctbano = vano no-error.
         if not avail bctbhie
         then do transaction:
                create bctbhie.
                assign bctbhie.etbcod = tt-saldo.etbcod
                       bctbhie.procod = tt-saldo.procod
                       bctbhie.ctbmes = vmes
                       bctbhie.ctbano = vano
                       bctbhie.ctbest = tt-saldo.sal-atu
                       bctbhie.ctbcus = aux-custo
                       bctbhie.ctbven = 0.
         end.
         /***
         else do transaction:
                assign
                    bctbhie.ctbest = tt-saldo.sal-atu
                    bctbhie.ctbven = 0
                    bctbhie.ctbcus = aux-custo.
         end.
         ***/
    end.
end procedure.

