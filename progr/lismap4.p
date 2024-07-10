{admcab.i}

def var vdtini  like plani.pladat.
def var vdtfin  like plani.pladat.
def var vativo  as log.
def var vprocod like produ.procod.
 
def temp-table tt-icms
    field procod like produ.procod
    field dtini  like plani.pladat
    field dtfin  like plani.pladat
    field ativo  as log
        index ind-1 procod.

def var tot as dec.
def var icms_07 as dec.
def var icms_17 as dec.
def var icms_12 as dec.
def var icms_18 as dec.
def temp-table tt-caixa
    field cxacod like serial.cxacod.
    
def var i as i.
def var icm07 as dec.
  

def temp-table tt-07
    field etbcod like estab.etbcod
    field cxacod like plani.cxacod
    field data   like plani.pladat
    field valor  like plani.platot.
    

def var val07 as dec.
def var val11 as dec.
def var val12 as dec.
def var val15 as dec.
def var val18 as dec.
def var val19 as dec.
def var val21 as dec.
def var val17 as dec.


def var t01 like plani.platot.
def var t02 like plani.platot.
def var t03 like plani.platot.
def var t04 like plani.platot.
def var t05 like plani.platot.
def var t06 like plani.platot.
def var t07 like plani.platot.
def var t08 like plani.platot.



def var vok as l.
def var xx as i.
def var vred as int.
def var valcon as dec.
def var valicm as dec.
def var varquivo as char format "x(20)".
def var vlinha as char format "x(25)".
def  var vcont as int.
def var vcxacod like caixa.cxacod.
def var vdia    as int format "99".
def var vmes    as int format "99".
def temp-table warquivo
    field warq as char format "x(50)"
    field wetb as c format ">>9"
    field wcxa as c format "99"
    field wmes as c format "99"
    field wdia as c format "99".

def var vetbcod like estab.etbcod.
def var vdti as date format "99/99/9999".
def var vdtf as date format "99/99/9999".
def var vdata as date format "99/99/9999".
 
    
repeat:

    for each tt-07.
        delete tt-07.
    end.
    
    
    for each tt-caixa:
        delete tt-caixa.
    end.

    
    update vetbcod with frame f1 side-label width 80.
   
    if vetbcod = 0
    then display "Geral" @ estab.etbnom no-label with frame f1. 
    else do:
        find estab where estab.etbcod = vetbcod no-lock.
        display estab.etbnom no-label with frame f1.
    end.
    
    update vdti label "Data Inicial" colon 16
           vdtf label "Data Final" with frame f1.
    
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/ecf" + string(vetbcod,"999") +
                            string(day(vdti),"99") +
                            string(month(vdtf),"99") +
                            "." + string(time)
                            .
                            
    else
    varquivo = "..\relat\ecf" + string(vetbcod,"999") +
                               string(day(vdti),"99") +
                               string(month(vdtf),"99").
    
    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "116"
        &Page-Line = "66"
        &Nom-Rel   = ""rel_map2""
        &Nom-Sis   = """SISTEMA DE CONTABILIDADE  FILIAL - ""
                        + string(vetbcod,"">>9"")"
        &Tit-Rel   = """MOVIMENTACOES DO CUPOM FISCAL - PERIODO DE "" +
                        string(vdti,""99/99/9999"") + "" A "" +
                        string(vdtf,""99/99/9999"") "
        &Width     = "116"
        &Form      = "frame f-cabcab"}
    


    xx = 0.

             
    for each estab where if vetbcod = 0
                         then true
                         else estab.etbcod = vetbcod no-lock,
        each mapctb where mapctb.etbcod = estab.etbcod and
                          mapctb.datmov >= vdti        and
                          mapctb.datmov <= vdtf        and
                          mapctb.ch2 <> "E" no-lock
                                    break by mapctb.etbcod:

        
        
        assign val07  = val07   + mapctb.t03
               val12  = val12   + mapctb.t02 
               val18  = val18   + mapctb.t05
               val17  = val17   + mapctb.t01
               val11  = val11   + mapctb.vlsub
               
               icms_12 = icms_12 + ((mapctb.t02 * 0.705889) * 0.17)
               icms_17 = icms_17 + (mapctb.t01 * 0.17)
               icms_07 = icms_07 + (mapctb.t03 * 0.07)
               icms_18 = icms_18 + (mapctb.t05 * 0.18).
        
        
        if last-of(mapctb.etbcod)
        then do:
            
            display mapctb.etbcod column-label "Fil"
                    val07(total) 
                        column-label "VDA.07%" format ">>,>>>,>>9.99"
                    icms_07(total) 
                        column-label "Imposto" format ">>,>>>,>>9.99"
                    val12(total) 
                        column-label "VDA.12%" format ">>,>>>,>>9.99" 
                    icms_12(total) 
                        column-label "Imposto" format ">>,>>>,>>9.99"     
                    val17(total)  
                        column-label "VDA.17%" format ">>,>>>,>>9.99" 
                    icms_17(total) 
                        column-label "Imposto" format ">>,>>>,>>9.99"     
                    val18(total)  
                        column-label "VDA.18%" format ">>,>>>,>>9.99" 
                    icms_18(total) 
                        column-label "Imposto" format ">>,>>>,>>9.99" 
                    val11(total)  format ">>,>>>,>>9.99" 
                        column-label "SUBST  "
                    val12(total)  format ">>,>>>,>>9.99" 
                        column-label "ISENTOS"
                        with frame f2 down width 160.

            assign val18  = 0 
                   val17  = 0 
                   val11  = 0 
                   valcon = 0
                   val19  = 0
                   val15  = 0
                   val12  = 0
                   valicm = 0
                   val07  = 0
                   icms_12 = 0
                   icms_07 = 0
                   icms_17 = 0
                   icms_18 = 0.
            
        
        end.


    end.
    
    output close.
    
    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:    
    {mrod.i}
    end.

end.
