/*{admcab.i}*/ 

def var sparam as char.
sparam = SESSION:PARAMETER.
if num-entries(sparam,";") > 1
then sparam = entry(2,sparam,";").

def var vcusto as dec.
def buffer bctbhie for ctbhie.
def var vi as int. 

def new shared temp-table tt-saldo
    field tipo as char
    field etbcod like estab.etbcod 
    field procod like produ.procod
    field und-ven as char
    field und-com as char
    field und-trib as char
    field codfis as int
    field sal-ant as dec
    field qtd-ent as dec
    field qtd-sai as dec
    field sal-atu as dec
    field cto-med as dec
    field ano-cto as int
    index i1 tipo etbcod procod
    .
    
def new shared temp-table tt-trib
    field tipo as char
    field etbcod like estab.etbcod 
    field procod like produ.procod
    field csticms as char
    field baseicms as dec
    field valoricms as dec
    field alicms as dec
    index i1 tipo etbcod procod
    .

def temp-table utribcomex no-undo
    field ncm as in format ">>>>>>>>9"
    field ivig_siscomex as date
    field fvig_siscomex as date
    field utrib_exportacao as char
    field desc_utrib_exportacao as char
    index i1 ncm
    .
input from /admcom/progr/UTribComEx.CsV.
repeat:
    create utribcomex.
    import delimiter ";" utribcomex.
end.
input close.    
for each utribcomex where utribcomex.ncm = 0:
    delete utribcomex.
end. 

def var varqH020 as char.
def var vtipo as char.
def var vtot-custo as dec.

def var vdti as date.
def var vdtf as date.
def var vetbi as int.
def var vetbf as int.
def var vmes like hiest.hiemes.
def var vano like hiest.hieano.
def var vetbcod like estab.etbcod.
def var vetb as char.
def var varq as char.
def var varquivo as char.
def var varqajus as char.
repeat:
    varquivo = "".
    if opsys = "unix" and sparam <> "AniTA"
    then do:
        input from /file_server/ESTOQUE.
        repeat:
            import varq.
            assign    
                vetbcod = int(substring(varq,1,3))
                vdti    = date(int(substring(varq,6,2)),
                           int(substring(varq,4,2)),
                           int(substring(varq,8,4)))
                vdtf    = date(int(substring(varq,14,2)),
                           int(substring(varq,12,2)),
                           int(substring(varq,16,4))).
        
            if vetbcod = 0
            then assign
                    vetbi = 1
                    vetbf = 999
                    varquivo = "/file_server/minv_" + 
                        trim(string(vetb,"x(3)")) + "_" +
                         string(day(vdti),"99") +  
                         string(month(vdti),"99") +  
                         string(year(vdti),"9999") + "_" +  
                         string(day(vdtf),"99") +  
                         string(month(vdtf),"99") +  
                         string(year(vdtf),"9999") + ".txt"
                    varqH020 = "/file_server/H020_" + 
                        trim(string(vetb,"x(3)")) + "_" +
                         string(day(vdti),"99") +  
                         string(month(vdti),"99") +  
                         string(year(vdti),"9999") + "_" +  
                         string(day(vdtf),"99") +  
                         string(month(vdtf),"99") +  
                         string(year(vdtf),"9999") + ".txt"
                     varqajus = "/file_server/mcor_" + 
                        trim(string(vetb,"x(3)")) + "_" +
                         string(day(vdti),"99") +  
                         string(month(vdti),"99") +  
                         string(year(vdti),"9999") + "_" +  
                         string(day(vdtf),"99") +  
                         string(month(vdtf),"99") +  
                         string(year(vdtf),"9999") + ".txt"
     
                         .
            else assign
                    vetbi = vetbcod
                    vetbf = vetbcod
                    varquivo = "/file_server/minv_" + 
                        trim(string(vetbcod,"999")) + "_" +
                         string(day(vdti),"99") +  
                         string(month(vdti),"99") +  
                         string(year(vdti),"9999") + "_" +  
                         string(day(vdtf),"99") +  
                         string(month(vdtf),"99") +  
                         string(year(vdtf),"9999") + ".txt"
                    varqH020 = "/file_server/H020_" + 
                        trim(string(vetbcod,"999")) + "_" +
                         string(day(vdti),"99") +  
                         string(month(vdti),"99") +  
                         string(year(vdti),"9999") + "_" +  
                         string(day(vdtf),"99") +  
                         string(month(vdtf),"99") +  
                         string(year(vdtf),"9999") + ".txt"
                     varqajus = "/file_server/mcor_" + 
                        trim(string(vetbcod,"999")) + "_" +
                         string(day(vdti),"99") +  
                         string(month(vdti),"99") +  
                         string(year(vdti),"9999") + "_" +  
                         string(day(vdtf),"99") +  
                         string(month(vdtf),"99") +  
                         string(year(vdtf),"9999") + ".txt" .
        end.
        input close.
        vmes = month(vdti).
        vano = year(vdti).
    end.
    else do:
        update vetbi label "Filial Inicial"
           vetbf label "Filial Final"
           with frame f-etb centered color blue/cyan side-labels
                    width 80.
           
        update skip
           vmes label "Mes..........."
           vano label "  Ano........."
           with frame f-etb.

        if vmes = 12
        then vdtf = date(1 , 1 , vano + 1).
        else vdtf = date(vmes + 1,1,vano).
        vdtf = vdtf - 1.
        vdti = date(vmes,1,vano).
        
        varquivo = "/admcom/decision/minv_" + 
                trim(string(vetbi,"999")) + "_" +
                trim(string(vetbf,"999")) + "_" +
                string(day(vdti),"99") +  
                string(month(vdti),"99") +  
                string(year(vdti),"9999") + "_" + 
                string(day(vdtf),"99") +  
                string(month(vdtf),"99") +  
                string(year(vdtf),"9999") + ".txt".
        varqH020 = "/admcom/decision/H020_" + 
                trim(string(vetbi,"999")) + "_" +
                trim(string(vetbf,"999")) + "_" +
                string(day(vdti),"99") +  
                string(month(vdti),"99") +  
                string(year(vdti),"9999") + "_" + 
                string(day(vdtf),"99") +  
                string(month(vdtf),"99") +  
                string(year(vdtf),"9999") + ".txt".
        varqajus = "/admcom/decision/mcor_" + 
                trim(string(vetbi,"999")) + "_" +
                trim(string(vetbf,"999")) + "_" +
                string(day(vdti),"99") +  
                string(month(vdti),"99") +  
                string(year(vdti),"9999") + "_" + 
                string(day(vdtf),"99") +  
                string(month(vdtf),"99") +  
                string(year(vdtf),"9999") + ".txt".
        
    end.    

    for each estab where estab.etbcod >= vetbi and
                             estab.etbcod <= vetbf no-lock.
        find tabaux where 
                 tabaux.tabela = "ESTAB-" + string(estab.etbcod,"999") and
                 tabaux.nome_campo = "BLOCOK" NO-LOCK no-error.
        if avail tabaux and tabaux.valor_campo = "SIM"
        then vtipo = "A".
        else vtipo = "H".

        for each ctbhie where
                 ctbhie.etbcod = estab.etbcod and
                 ctbhie.ctbmes = vmes and
                 ctbhie.ctbano = vano
                 no-lock:
          
            find produ where produ.procod = ctbhie.procod no-lock no-error.
            if not avail produ
            then find prodnewfree where
                      prodnewfree.procod = ctbhie.procod no-lock no-error.

            if not avail produ and
               not avail prodnewfree
            then next.   
            if avail produ and produ.proipiper = 98 then next.
            if avail prodnewfree and prodnewfree.proipiper = 98 then next.
            
            if avail produ and
               produ.catcod <> 31 and
               produ.catcod <> 35 and
               produ.catcod <> 41 
            then next.

            if avail prodnewfree and
               prodnewfree.catcod <> 31 and
               prodnewfree.catcod <> 35 and
               prodnewfree.catcod <> 41 
            then next.
            
            run val-custo.

            if vcusto = 0 then next.
            
            find first tt-saldo where
                       tt-saldo.tipo   = vtipo and
                       tt-saldo.etbcod = ctbhie.etbcod and
                       tt-saldo.procod = ctbhie.procod
                       no-error.
            if not avail tt-saldo
            then do:           
                create tt-saldo.
                assign
                    tt-saldo.tipo = vtipo
                    tt-saldo.etbcod = ctbhie.etbcod
                    tt-saldo.procod = ctbhie.procod
                    tt-saldo.codfis = 0
                    tt-saldo.sal-atu = ctbhie.ctbest
                    tt-saldo.cto-med = vcusto.
            end.
            else assign
                     tt-saldo.sal-atu = tt-saldo.sal-atu + ctbhie.ctbest.
    
            find first tt-trib where
                       tt-trib.tipo = vtipo and
                       tt-trib.etbcod = ctbhie.etbcod and
                       tt-trib.procod = ctbhie.procod
                       no-error.
            if not avail tt-trib
            then do:
                create tt-trib.
                assign
                    tt-trib.tipo = vtipo
                    tt-trib.etbcod = ctbhie.etbcod
                    tt-trib.procod = ctbhie.procod
                    tt-trib.csticms = "000"
                    .
            end.            

            if avail produ 
            then do:
                find first clafis where clafis.codfis = produ.codfis
                                no-lock no-error.

                assign
                    tt-saldo.und-com = produ.prouncom
                    tt-saldo.und-ven = produ.prounven
                    tt-saldo.codfis = produ.codfis
                    .
                if avail clafis
                then tt-trib.csticms = string(clafis.sittri,"999").
                
                if produ.proipiper > 0 and produ.proipiper <> 99
                then assign
                    tt-trib.alicms   = produ.proipiper
                    tt-trib.baseicms = tt-saldo.cto-med 
                    tt-trib.valoricms  = tt-trib.baseicms * 
                                            (produ.proipiper / 100)
                    tt-trib.csticms = "000"                        
                                            .
                else assign
                     tt-trib.alicms    = 0
                     tt-trib.baseicms  = 0
                     tt-trib.valoricms = 0
                     tt-trib.csticms = "060"
                     .
                
                find first utribcomex where
                           utribcomex.ncm = produ.codfis no-lock no-error.
                if avail utribcomex and 
                         utribcomex.utrib_exportacao <> ""
                then tt-saldo.und-trib = utribcomex.utrib_exportacao.
                else tt-saldo.und-trib = produ.prounven.
         
            end.
            else if avail prodnewfree
                then do:
                    
                    find first clafis where 
                               clafis.codfis = prodnewfree.codfis
                                no-lock no-error.
                    assign
                        tt-saldo.und-com = prodnewfre.prouncom
                        tt-saldo.und-ven = prodnewfre.prounven
                        tt-saldo.codfis = prodnewfree.codfis.
                    if avail clafis
                    then tt-trib.csticms = string(clafis.sittri,"999").

                    if prodnewfree.proipiper > 0 and 
                       prodnewfree.proipiper <> 99
                    then assign
                    tt-trib.alicms   = prodnewfree.proipiper
                    tt-trib.baseicms = tt-saldo.cto-med 
                    tt-trib.valoricms  = tt-trib.baseicms * 
                                            (prodnewfree.proipiper / 100)
                    tt-trib.csticms = "000"                        
                                            .
                    else assign
                     tt-trib.alicms    = 0
                     tt-trib.baseicms  = 0
                     tt-trib.valoricms = 0
                     tt-trib.csticms = "060"
                     .
                    
                    find first utribcomex where
                           utribcomex.ncm = prodnewfree.codfis no-lock no-error.
                    if avail utribcomex and 
                         utribcomex.utrib_exportacao <> ""
                    then tt-saldo.und-trib = utribcomex.utrib_exportacao.
                    else tt-saldo.und-trib = prodnewfree.prounven.
                 end.
        end. 
    end.

     run inventario.    
    
    /*
    disp vtot-custo format ">>>,>>>,>>9.99".
    pause.
    */
    leave.
end.
/******** K280 não se aplica na Lebes
if vdtf <> ?
then do:
vdti = date(month(vdtf),01,year(vdtf)).
run /admcom/progr/int_mcor_dsp.p(input vetbi,
                   input vetbf,
                   input vdti,
                   input vdtf,
                   input varqajus).
end.
else
************/ 

pause 1 no-message.                   

return.

procedure inventario: /* K200 */
    def var aux-custo as dec decimals 6. 
    def var aux-icms  as dec.
    def var aux-liq  as dec. 
    def var aux-pis  as dec.  
    def var aux-cofins  as dec.
    def var aux-econt   as dec.
    def var aux-subst as dec.
    def var obs-cod as char.
    def var sal-val-icms as dec.
    def var qtd-est-periodo as dec.
    def var custo-unitario-periodo as dec.
    
    output to value(varquivo). 
    
    for each tt-saldo where tt-saldo.sal-atu > 0:
        
        aux-custo = tt-saldo.cto-med.
        
        put unformatted
            "001"
            ";" string(tt-saldo.etbcod,">>9")       /* 2 */
            ";" string(year(vdtf),"9999")
                string(month(vdtf),"99")
                string(day(vdtf),"99")              /* 3 */
            ";" string(tt-saldo.procod,">>>>>>>>9") /* 4 */
            ";" tt-saldo.und-trib format "x(10)"     /* 5 */
            ";" string(tt-saldo.sal-atu,"->>>>>9.999") /* 6 */
            ";" string(aux-custo,">>>>>>>>9.99")    /* 7 */
            ";" string(tt-saldo.sal-atu * aux-custo,"->>>>>>>>9.99") /* 8 */
            ";0;;001;1.1.04.01.001;" /* 11 */
            ";" string(tt-saldo.tipo,"x")
            ";ADMCOM"       
            skip.

        vtot-custo = vtot-custo + (tt-saldo.sal-atu * aux-custo).
    end.
    output close.
    
    output to value(varqH020).
    for each tt-trib no-lock:
        put unformatted
            "001"
            ";" string(tt-trib.etbcod,">>9")       /* 2 */
            ";" tt-trib.csticms
            ";" string(tt-trib.procod,">>>>>>>>9") /* 4 */
            ";"
            ";" string(year(vdtf),"9999")
                string(month(vdtf),"99")
                string(day(vdtf),"99") 
            ";" string(tt-trib.tipo,"x")
            ";0"  /* Propriedade */
            ";01" /* Motivo */
            ";ADMCOM" /* Origem */
            ";"
            ";" string(tt-trib.baseicms,">>>>>>>>9.99")
            ";" string(tt-trib.valoricms,">>>>>>>>9.99")
            /*";" string(tt-trib.alicms,">>>>>>>>9.99")*/
            skip.
    end.
    output close.    


    if sparam = "AniTA"
    then do:
        message color red/with "Arquivos gerados:" 
        skip varquivo skip varqH020
            view-as alert-box.
    end.    
end procedure.

procedure val-custo:
                if ctbhie.ctbmed > 0
                then vcusto = ctbhie.ctbmed.
                else do:
                    vcusto = ctbhie.ctbcus.
                
                    find last bctbhie where
                        bctbhie.etbcod = 0 and
                        bctbhie.procod = produ.procod and
                        bctbhie.ctbano = vano and
                        bctbhie.ctbmes <= vmes 
                        no-lock no-error.
                    if not avail bctbhie
                    then do vi = 1 to 10:
                        find last bctbhie use-index ind-2 where
                             bctbhie.etbcod = 0 and
                             bctbhie.procod = produ.procod and
                             bctbhie.ctbano = vano - vi 
                             no-lock no-error.
                        if avail bctbhie
                        then do:
                            leave.
                        end.
                    end.     
                    if avail bctbhie and bctbhie.ctbcus <> ?
                    then vcusto = bctbhie.ctbcus.
                    else vcusto = 0.
                end.

end procedure.
