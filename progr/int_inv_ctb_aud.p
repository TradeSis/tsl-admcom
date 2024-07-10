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
           
    update skip
           vmes label "Mes..........."
           vano label "  Ano........."
           with frame f-etb.
    
    if vmes = 12
    then dtfim = date(1 , 1 , vano + 1).
    else dtfim = date(vmes + 1,1,vano).
    
    dtfim = dtfim - 1.
    vdtf = dtfim.

    for each tt-saldo: delete tt-saldo. end.

    def var vtot-custo as dec.
    /*if vetbi = 22
    then*/ do:
        for each estab where estab.etbcod >= vetbi and
                             estab.etbcod <= vetbf no-lock.

        for each ctbhie where
                 ctbhie.etbcod = estab.etbcod and
                 ctbhie.ctbmes = vmes and
                 ctbhie.ctbano = vano
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
    end.
    /***else
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
    ***/
    
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
    
    /*
    disp vtot-custo format ">>>,>>>,>>9.99".
    pause.
    */
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
    varquivo = "/admcom/decision/inv_" + trim(string(vetbi,"999")) + "_" +
                trim(string(vetbf,"999")) + "_" +
                /*string(day(vdti),"99") +  
                string(month(vdti),"99") +  
                string(year(vdti),"9999") + "_" +*/ 
                string(day(vdtf),"99") +  
                string(month(vdtf),"99") +  
                string(year(vdtf),"9999") + ".txt".

    output to value(varquivo). 
    
    for each tt-saldo:
         aux-custo = tt-saldo.cto-med.
        /****                         
        if vicms = 18                            
        then aux-icms  = trunc(aux-custo * (vicms / 100),2).
        else aux-subst = trunc(aux-custo * (vicms / 100),2). 
              
        assign aux-liq  = aux-custo - aux-icms
               aux-pis  = ((if vopc then aux-liq else aux-custo)
                             * (vpis / 100))
               ux-cofins = ((if vopc then aux-liq else aux-custo) 
                                 * (vcofins / 100)).
      
        ******/
        
        put unformatted
            /* 001-003 */ string(tt-saldo.etbcod,">>9") at 01.
      
      
      put unformatted
/* 004-031 */  "1.1.04.01.001" format "x(28)"  /* código c. contabil */
/* 032-059 */  " " format "x(28)"   /* Centro de custo */
/* 060-067 */ string(year(vdtf),"9999")
              string(month(vdtf),"99") 
              string(day(vdtf),"99")
/* 068-087 */ string(tt-saldo.procod) format "x(20)"
/* 088-097 */ string(tt-saldo.codfis) format "x(10)"
/* 098-100 */ "UN " format "x(3)"
/* 101-116 */ tt-saldo.sal-atu format "999999999999.999"
/* 117-132 */ tt-saldo.sal-atu * aux-custo format "-9999999999999.99"
/* 133-148 */ aux-custo format "-999999999.999999"
/* 149-151 */ "PR "
/* 152-152 */ "0"    /*tipo de estoque*/
/* 153-170 */ " " format "x(18)"
/* 171-188 */ " " format "x(18)"
/* 189-208 */ " " format "x(20)"
/* 209-210 */ " "  format "x(2)"
/* 211-226 */ /*tt-saldo.sal-ant*/ "0000000000000.000"
            format "-9999999999999.999" /* qtde inicial do estoque */
/* 227-242 */ aux-icms
                    format "-99999999999999.99" /* icms proprio */
/* 243-258 */ aux-subst
                    format "-99999999999999.99" /* icms subst trib. */
/* 259-264 */ obs-cod format "x(6)"
/* 265-280 */ sal-val-icms           format "-99999999999999.99"
/* 281-296 */ qtd-est-periodo        format "9999999999999.999"
/* 297-312 */ custo-unitario-periodo format "9999999999.999999"
/* 313-328 */ val-icms-periodo       format "-99999999999999.99"
 skip .


        vtot-custo = vtot-custo + (tt-saldo.sal-atu * aux-custo).
    end.
    output close.
    
    message color red/with
        "Arquivo gerado:" skip
        varquivo
        view-as alert-box.
        
end procedure.

