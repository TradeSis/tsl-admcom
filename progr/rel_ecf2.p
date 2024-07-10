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


def var t01 like plani.platot.
def var t02 like plani.platot.
def var t03 like plani.platot.
def var t04 like plani.platot.
def var t05 like plani.platot.
def var t06 like plani.platot.
def var t07 like plani.platot.
def var t08 like plani.platot.

def var tg01 like plani.platot.
def var tg02 like plani.platot.
def var tg03 like plani.platot.
def var tg04 like plani.platot.
def var tg05 like plani.platot.
def var tg06 like plani.platot.
def var tg07 like plani.platot.
def var tg08 like plani.platot.


def var vok as l.
def var xx as i.
def var vred as int.
def var valcon as dec.
def var valicm as dec.
def var varquivo as char format "x(20)".
def var vlinha as char format "x(25)".
def  var vcont as int.
def var v01 as char format "x(2)".
def var v02 as char format "x(8)".
def var v03 as char format "x(10)".
def var v04 as char format "x(4)".
def var v05 as char format "x(5)".
def var v06 as char format "x(5)".
def var v07 as char format "x(5)".
def var v08 as char format "x(21)".
def var v09 as char format "x(21)".
def var v10 as char format "x(21)".
def var v11 as char format "x(21)".
def var v12 as char format "x(21)".
def var v13 as char format "x(21)".
def var v14 as char format "x(21)".

def var v15 as char format "x(21)".
def var v16 as char format "x(21)".
def var v17 as char format "x(21)".

def var v18 as char format "x(21)".
def var v19 as char format "x(21)".
def var v20 as char format "x(21)".

def var v21 as char format "x(21)".
def var v22 as char format "x(18)".
def var v23 as char format "x(21)".

def var v24 as char format "x(05)".
def var v25 as char format "x(18)".
def var v26 as char format "x(18)".

def var v27 as char format "x(05)".
def var v28 as char format "x(18)".
def var v29 as char format "x(18)".

def var v30 as char format "x(05)".
def var v31 as char format "x(18)".
def var v32 as char format "x(18)".

def var v33 as char format "x(05)".
def var v34 as char format "x(18)".
def var v35 as char format "x(18)".

def var v36 as char format "x(05)".
def var v37 as char format "x(18)".
def var v38 as char format "x(18)".

def var v39 as char format "x(05)".
def var v40 as char format "x(18)".
def var v41 as char format "x(18)".

def var v42 as char format "x(05)".
def var v43 as char format "x(18)".
def var v44 as char format "x(18)".

def var v45 as char format "x(06)".
def var v46 as char format "x(06)".
def var v47 as char format "x(06)".

def var v48 as char format "x(18)".
def var v49 as char format "x(18)".
def var v50 as char format "x(18)".
def var v51 as char format "x(18)".
def var v52 as char format "x(18)".
def var v53 as char format "x(18)".
def var v54 as char format "x(18)".

def var v55 as char format "x(09)".
def var v56 as char format "x(09)".
def var vetbcod like estab.etbcod.
def var vcxacod like caixa.cxacod.
def var vdia    as int format "99".
def var vmes    as int format "99".
def temp-table warquivo
    field warq as char format "x(50)"
    field wetb as c format ">>9"
    field wcxa as c format "99"
    field wmes as c format "99"
    field wdia as c format "99".
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

    
    varquivo = "..\relat\ecf" + string(vetbcod,">>9") +
                               string(day(vdti),"99") +
                               string(month(vdtf),"99").
    
    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "116"
        &Page-Line = "66"
        &Nom-Rel   = ""REL_ECF2""
        &Nom-Sis   = """SISTEMA DE CONTABILIDADE  FILIAL - ""
                        + string(vetbcod,"">>9"")"
        &Tit-Rel   = """MOVIMENTACOES DO CUPOM FISCAL - PERIODO DE "" +
                        string(vdti,""99/99/9999"") + "" A "" +
                        string(vdtf,""99/99/9999"") "
        &Width     = "116"
        &Form      = "frame f-cabcab"}
    


    xx = 0.

             
    tg01 = 0.
    tg02 = 0. 
    tg03 = 0. 
    tg04 = 0. 
    tg05 = 0. 
    tg06 = 0. 
    tg07 = 0. 
    tg08 = 0.
    

        
    for each tt-icms:
        delete tt-icms.
    end.
    
    input from ..\progr\icms.txt.
    repeat:
        import vprocod
               vdtini
               vdtfin
               vativo.
        find first tt-icms where tt-icms.procod = vprocod no-error.
        if not avail tt-icms
        then do:
               
        
            create tt-icms.
            assign tt-icms.procod = vprocod
                   tt-icms.dtini  = vdtini
                   tt-icms.dtfin  = vdtfin
                   tt-icms.ativo  = vativo.
                   
                   
            
        end.
        
    end.
    input close.

    for each tt-icms.

        find produ where produ.procod = tt-icms.procod no-lock no-error.
        if not avail produ
        then do:
            delete tt-icms.
            next.
        end.
    
    end.    
     


    for each tt-icms where tt-icms.dtini <= vdti and
                           tt-icms.dtfin >= vdtf:
        for each estab where if vetbcod = 0
                             then true
                             else estab.etbcod = vetbcod no-lock:

        for each movim where movim.etbcod = estab.etbcod and
                             movim.movtdc = 5            and
                             movim.movdat >= vdti        and
                             movim.movdat <= vdtf        and
                             movim.procod = tt-icms.procod no-lock.
                             
            find plani where plani.etbcod = movim.etbcod and
                             plani.placod = movim.placod and
                             plani.movtdc = movim.movtdc and
                             plani.pladat = movim.movdat no-lock no-error.
            if not avail plani
            then next.
            
            find first tt-07 where tt-07.etbcod = plani.etbcod and
                                   tt-07.cxacod = plani.cxacod and
                                   tt-07.data   = plani.pladat no-error.
            if not avail tt-07
            then do:
                create tt-07.
                assign tt-07.etbcod = plani.etbcod
                       tt-07.cxacod = plani.cxacod
                       tt-07.data   = plani.pladat.
            end.
            tt-07.valor = tt-07.valor + (movim.movpc * movim.movqtm).
        end.
        end.
    end.        
         
    
    
    for each estab where if vetbcod = 0
                         then true
                         else estab.etbcod = vetbcod no-lock,
        each serial where serial.etbcod = estab.etbcod and
                          serial.serdat >= vdti        and
                          serial.serdat <= vdtf no-lock
                                    break by serial.etbcod:

        find first tt-07 where tt-07.etbcod = serial.etbcod and
                               tt-07.cxacod = serial.cxacod and
                               tt-07.data   = serial.serdat no-error.
         
        if avail tt-07
        then icm07 = tt-07.valor.
        else icm07 = 0.
        
        
        assign val07  = val07   + icm07
               val18  = val18   + serial.icm12
               val15  = val15   + (serial.icm17 - icm07)
               val11  = val11   + serial.sersub
               val19  = val19   + (serial.icm12 * 0.705889)
               valcon = valcon  + (serial.icm12 + serial.icm17 + serial.sersub)
               valicm = valicm  + 
                        ( ( (serial.icm12 * 0.705889) + 
                            (serial.icm17 - icm07)) * 0.17 +
                            icm07 * 0.07)
               val12  = val12   + (serial.icm12 -  (serial.icm12 * 0.705889)).
        
        
        
        
        if last-of(serial.etbcod)
        then do:
            
            display serial.etbcod column-label "Fil"
                    val07(total)  format ">>,>>>,>>9.99"
                        column-label "VDA.07%"
                    val18(total)  format ">>,>>>,>>9.99" 
                        column-label "VDA.12%"
                    val15(total)  format ">>,>>>,>>9.99" 
                        column-label "VDA.17%"
                    val11(total)  format ">>,>>>,>>9.99" 
                        column-label "SUBST  "
                    valcon(total) format ">>,>>>,>>9.99" 
                        column-label "TOTAL VDA"
                    val19(total)  format ">>,>>>,>>9.99" 
                        column-label "BC.12%"
                    val12(total)  format ">>,>>>,>>9.99" 
                        column-label "ISENTOS"
                    valicm(total) format ">>,>>>,>>9.99" 
                        column-label "ICMS.17%"
                        with frame f2 down width 137.

            assign val18  = 0 
                   val15  = 0 
                   val11  = 0 
                   valcon = 0
                   val19  = 0
                   val15  = 0
                   val12  = 0
                   valicm = 0
                   val07  = 0.
            
        
        end.


    end.
    
    {mrod.i}

end.
