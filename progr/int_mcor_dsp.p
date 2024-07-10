/*
K280
*/

/*{admcab.i}*/

def input parameter vetbi as int.
def input parameter vetbf as int.
def input parameter vdti  as date.
def input parameter vdtf  as date.
def input parameter varquivo as char.

/*****
def var sparam as char.
sparam = SESSION:PARAMETER.
if num-entries(sparam,";") > 1
then sparam = entry(2,sparam,";").
****/

def temp-table tt-movim
    field etbcod like movim.etbcod 
    field movdat like movim.movdat
    field procod like movim.procod
    field qtdsom as dec
    field qtddim as dec
    index i1 etbcod movdat procod
    .

/*******
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
***********/

repeat:
    
    /*********
    if opsys = "unix" and sparam <> "AniTA"
    then do:
        input from /file_server/param_inv.
        repeat:
            import varq.
            assign    
                vetbcod = int(substring(varq,1,3))
                vdti    = date(int(substring(varq,6,2)),
                           int(substring(varq,4,2)),
                           int(substring(varq,8,4)))
                /*vdtf    = date(int(substring(varq,14,2)),
                           int(substring(varq,12,2)),
                           int(substring(varq,16,4)))*/.
        
            if vetbcod = 0
            then assign
                    vetbi = 1
                    vetbf = 999
                    varq = "/file_server/mcor_" + 
                        trim(string(vetb,"x(3)")) + "_" +
                         string(day(vdti),"99") +  
                         string(month(vdti),"99") +  
                         string(year(vdti),"9999") /*+ "_" +  
                         string(day(vdtf),"99") +  
                         string(month(vdtf),"99") +  
                         string(year(vdtf),"9999")*/ + ".txt".
            else assign
                    vetbi = vetbcod
                    vetbf = vetbcod
                    varq = "/file_server/mcor_" + 
                        trim(string(vetbcod,"999")) + "_" +
                         string(day(vdti),"99") +  
                         string(month(vdti),"99") +  
                         string(year(vdti),"9999") /*+ "_" +  
                         string(day(vdtf),"99") +  
                         string(month(vdtf),"99") +  
                         string(year(vdtf),"9999")*/ + ".txt".
        end.
        input close.
        vmes = month(vdti).
        vano = year(vdti).
        vdtf = vdti.
        varquivo = varq.
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

        varquivo = "/admcom/decision/mcor_" + 
                trim(string(vetbi,"999")) + "_" +
                trim(string(vetbf,"999")) + "_" +
                /*string(day(vdti),"99") +  
                string(month(vdti),"99") +  
                string(year(vdti),"9999") + "_" +*/ 
                string(day(vdtf),"99") +  
                string(month(vdtf),"99") +  
                string(year(vdtf),"9999") + ".txt".


    end.    
    ***********/
    
    for each estab where estab.etbcod >= vetbi and
                         estab.etbcod <= vetbf
                         no-lock:
        find tabaux where 
                 tabaux.tabela = "ESTAB-" + string(estab.etbcod,"999") and
                 tabaux.nome_campo = "BLOCOK" NO-LOCK no-error.
        if avail tabaux and tabaux.valor_campo = "SIM"
        then.
        else next.

         for each plani where plani.etbcod = estab.etbcod and
                             plani.movtdc = 7 and
                             plani.pladat >= vdti and
                             plani.pladat <= vdtf
                             no-lock:
            for each movim where
                     movim.etbcod = plani.etbcod and
                     movim.placod = plani.placod and
                     movim.movtdc = plani.movtdc
                     no-lock:
                find first tt-movim where
                           tt-movim.etbcod = movim.etbcod and
                           tt-movim.movdat = movim.movdat and
                           tt-movim.procod = movim.procod
                           no-error.
                if not avail tt-movim
                then do:
                    create tt-movim.
                    assign
                        tt-movim.etbcod = movim.etbcod 
                        tt-movim.movdat = movim.movdat 
                        tt-movim.procod = movim.procod 
                        tt-movim.qtdsom = movim.movqtm
                        .
                end.
                else tt-movim.qtdsom = tt-movim.qtdsom + movim.movqtm .
            end.
        end.                                     
        for each plani where plani.etbcod = estab.etbcod and
                             plani.movtdc = 8 and
                             plani.pladat >= vdti and
                             plani.pladat <= vdtf
                             no-lock:
            for each movim where
                     movim.etbcod = plani.etbcod and
                     movim.placod = plani.placod and
                     movim.movtdc = plani.movtdc
                     no-lock:
                find first tt-movim where
                           tt-movim.etbcod = movim.etbcod and
                           tt-movim.movdat = movim.movdat and
                           tt-movim.procod = movim.procod
                           no-error.
                if not avail tt-movim
                then do:           
                    create tt-movim.
                    assign
                        tt-movim.etbcod = plani.etbcod 
                        tt-movim.movdat = movim.movdat 
                        tt-movim.procod = movim.procod 
                        tt-movim.qtddim = movim.movqtm
                        .
                end.
                else tt-movim.qtddim = tt-movim.qtddim + movim.movqtm.
            end.
        end. 
    end.

    output to value(varquivo).
    for each tt-movim:
        put unformatted
            "001" /* 1 */
            ";" string(tt-movim.etbcod,">>9") /* 2 */
            ";" string(year(tt-movim.movdat),"9999")
                string(month(tt-movim.movdat),"99")
                string(day(tt-movim.movdat),"99")   /* 3 */
            ";" string(tt-movim.procod,">>>>>>>>9") /* 4 */
            ";" string(tt-movim.qtdsom,"->>>>>9.999")
            ";" string(tt-movim.qtddim,"->>>>>9.999")
            ";0;;001;1.1.04.01.001"
            ";" string(year(vdtf),"9999")
                string(month(vdtf),"99")
                string(day(vdtf),"99")
            ";ADMCOM" /* 17 */
            skip.
    end.
    output close.
    
    message color red/with "Arquivo gerado:" skip varquivo view-as alert-box.
    leave.
end.
return.

