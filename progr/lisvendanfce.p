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
def var val16 as dec.
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

def var vchave-aux as char.
def var vetbcod like estab.etbcod.
def var vdti as date format "99/99/9999".
def var vdtf as date format "99/99/9999".
def var vdata as date format "99/99/9999".
def var vtotal as dec. 
def var vesq as char extent 2  format "x(20)"
    init["Analitico","Sintetico"].
def var vindex as int.
def var ok-serie as log.

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
    
    vindex = 0.
    if vetbcod > 0
    then do with frame f-esq no-label centered:
        disp vesq.
        choose field vesq.
        vindex = frame-index.
    end.
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
        &Cond-Var  = "150"
        &Page-Line = "66"
        &Nom-Rel   = ""rel_map2""
        &Nom-Sis   = """SISTEMA DE CONTABILIDADE  FILIAL - ""
                        + string(vetbcod,"">>9"")"
        &Tit-Rel   = """MOVIMENTACOES DO CUPOM FISCAL - PERIODO DE "" +
                        string(vdti,""99/99/9999"") + "" A "" +
                        string(vdtf,""99/99/9999"") "
        &Width     = "150"
        &Form      = "frame f-cabcab"}
    


    xx = 0.
    if vindex <> 1
    then do:        
    for each estab where if vetbcod = 0
                         then true
                         else estab.etbcod = vetbcod no-lock:
        vtotal = 0.
        for each plani where plani.movtdc = 5 and
                         plani.etbcod = estab.etbcod and
                         plani.emite  = estab.etbcod and
                         /*plani.serie  = "3" and*/
                         plani.pladat >= vdti and
                         plani.pladat <= vdtf 
                         no-lock
                         :
            
            if plani.serie < "A" 
                then.
                else next.

                vchave-aux = "".
                if length(plani.ufemi) > 40
                then vchave-aux = plani.ufemi.
                else if length(plani.ufdes) > 40
                then vchave-aux = plani.ufdes.

                if length(vchave-aux) < 44
                then next.
                
                if length(plani.serie) > 5
                then next.

            /*****
            ok-serie = no.
            run valida-serie-NFCe.p(input plani.serie,
                                    input plani.ufemi,
                                    input plani.notped,
                                    output ok-serie).
            if not ok-serie
            then next.
            if not estab.usap2k
            then do:            
            find A01_InfNFe where
                     A01_InfNFe.etbcod = plani.etbcod and
                     A01_InfNFe.placod = plani.placod
                              no-lock no-error.
            if avail A01_InfNFe and situacao <> "MC015"
            then find W01_total of A01_infnfe no-lock no-error.
            else if not avail A01_InfNFe 
                then do:
                    /*if plani.ufemi = "" or
                        length(plani.ufemi) <> 44
                    then*/ next.        
                end.
            end.
            vtotal = vtotal + plani.protot.
            ****/

            for each movim where movim.etbcod = plani.etbcod and
                                 movim.placod = plani.placod and
                                 movim.movtdc = plani.movtdc and
                                 movim.movdat = plani.pladat
                                 no-lock:
                find produ where produ.procod = movim.procod 
                            no-lock no-error.
                if not avail produ or produ.proipiper = 98
                then next.            
                if movim.movalicms = 7
                then assign
                    val07  = val07 + (movim.movpc * movim.movqtm)
                    icms_07 = icms_07 + ((movim.movpc * movim.movqtm) * 0.07)
                    .
                else if movim.movalicms = 12
                then assign
                    val18  = val18 + (movim.movpc * movim.movqtm)
                    icms_12 = icms_12 + (((movim.movpc * movim.movqtm) 
                            * 0.705889) * 0.17)
                    .
                else if movim.movalicms = 17
                then assign
                    val15  = val15 + (movim.movpc * movim.movqtm)
                    icms_17 = icms_17 + ((movim.movpc * movim.movqtm) * 0.17)
                    .
                else if movim.movalicms = 18
                then assign
                    val16  = val16 + (movim.movpc * movim.movqtm)
                    /*icms_18 = icms_18 + ((movim.movpc * movim.movqtm) * 0.18)
                    */
                    icms_18 = icms_18 + movim.movicms
                    .
                else if movim.movalicms = 00
                then val11  = val11 + (movim.movpc * movim.movqtm).
                vtotal = vtotal + (movim.movpc * movim.movqtm).
            end.
        end.
        if vtotal > 0
        then     
        display estab.etbcod column-label "Fil"
                    vtotal(total) column-label "Venda" format ">>,>>>,>>9.99"
                    val07(total) 
                        column-label "VDA.07%" format ">,>>>,>>9.99"
                    icms_07(total) 
                        column-label "Imposto" format ">,>>>,>>9.99"
                    val18(total) 
                        column-label "VDA.12%" format ">,>>>,>>9.99" 
                    icms_12(total) 
                        column-label "Imposto" format ">,>>>,>>9.99"     
                    val15(total)  
                        column-label "VDA.17%" format ">>,>>>,>>9.99" 
                    icms_17(total) 
                        column-label "Imposto" format ">>,>>>,>>9.99"   
                    val16(total)  
                        column-label "VDA.18%" format ">>,>>>,>>9.99" 
                    icms_18(total) 
                        column-label "Imposto" format ">>,>>>,>>9.99"          
                    val11(total)  format ">>,>>>,>>9.99" 
                        column-label "SUBST  "
                    val12(total)  format ">>,>>>,>>9.99" 
                        column-label "ISENTOS"
                        with frame f2 down width 170.

            assign val18  = 0 
                   val15  = 0 
                   val16  = 0
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
    else do:
    for each estab where if vetbcod = 0
                         then true
                         else estab.etbcod = vetbcod no-lock:
        vtotal = 0.
        do vdata = vdti to vdtf:
        for each plani where plani.movtdc = 5 and
                         plani.etbcod = estab.etbcod and
                         plani.emite  = estab.etbcod and
                         /*plani.serie  = "3" and*/
                         plani.dtinclu = vdata
                         no-lock  :
            
            if plani.serie < "A" 
                then.
                else next.

                vchave-aux = "".
                if length(plani.ufemi) > 40
                then vchave-aux = plani.ufemi.
                else if length(plani.ufdes) > 40
                then vchave-aux = plani.ufdes.

                if length(vchave-aux) < 44
                then next.
                
                if length(plani.serie) > 5
                then next.

            /************
            ok-serie = no.
            run valida-serie-NFCe.p(input plani.serie,
                                    input plani.ufemi,
                                    input plani.notped,
                                    output ok-serie).
            if not ok-serie
            then next.
            if not estab.usap2k
            then do:
                find A01_InfNFe where
                     A01_InfNFe.etbcod = plani.etbcod and
                     A01_InfNFe.placod = plani.placod
                              no-lock no-error.
                if avail A01_InfNFe and situacao <> "MC015"
                then find W01_total of A01_infnfe no-lock no-error.
                else if not avail A01_InfNFe 
                then do:
                    /*if plani.ufemi = "" or
                        length(plani.ufemi) <> 44
                    then*/ next.        
                end.
            end.                    
            ****/
            
            for each movim where movim.etbcod = plani.etbcod and
                                 movim.placod = plani.placod and
                                 movim.movtdc = plani.movtdc and
                                 movim.movdat = plani.pladat
                                 no-lock:

                find produ where produ.procod = movim.procod
                                            no-lock no-error.
                if not avail produ or produ.proipiper = 98
                then next.
            
                if movim.movalicms = 7
                then assign
                    val07  = val07 + (movim.movpc * movim.movqtm)
                    icms_07 = icms_07 + ((movim.movpc * movim.movqtm) * 0.07)
                    .
                else if movim.movalicms = 12
                then assign
                    val18  = val18 + (movim.movpc * movim.movqtm)
                    icms_12 = icms_12 + (((movim.movpc * movim.movqtm) 
                            * 0.705889) * 0.17)
                    .
                else if movim.movalicms = 17
                then assign
                    val15  = val15 + (movim.movpc * movim.movqtm)
                    icms_17 = icms_17 + ((movim.movpc * movim.movqtm) * 0.17)
                    .
                else if movim.movalicms = 18
                then assign
                    val16  = val16 + (movim.movpc * movim.movqtm)
                    /*
                    icms_18 = icms_18 + ((movim.movpc * movim.movqtm) * 0.18)
                    */
                    icms_18 = icms_18 + movim.movicms
                    .
                else if movim.movalicms = 00
                then val11  = val11 + (movim.movpc * movim.movqtm).
                
                vtotal = vtotal + (movim.movpc * movim.movqtm).
                      
            end.
        end.
        if vtotal > 0
        then do:    
        display estab.etbcod column-label "Fil"
                vdata column-label "Data"
                    vtotal(total) column-label "Venda" format ">>,>>>,>>9.99"
                    val07(total) 
                        column-label "VDA.07%" format ">,>>>,>>9.99"
                    icms_07(total) 
                        column-label "Imposto" format ">,>>>,>>9.99"
                    val18(total) 
                        column-label "VDA.12%" format ">,>>>,>>9.99" 
                    icms_12(total) 
                        column-label "Imposto" format ">,>>>,>>9.99"     
                    val15(total)  
                        column-label "VDA.17%" format ">>,>>>,>>9.99" 
                    icms_17(total) 
                        column-label "Imposto" format ">>,>>>,>>9.99"   
                    val16(total)  
                        column-label "VDA.18%" format ">>,>>>,>>9.99" 
                    icms_18(total) 
                        column-label "Imposto" format ">>,>>>,>>9.99"          
                    val11(total)  format ">>,>>>,>>9.99" 
                        column-label "SUBST  "
                    val12(total)  format ">>,>>>,>>9.99" 
                        column-label "ISENTOS"
                        with frame f3 down width 180.
            down with frame f3.
         end.   
            assign val18  = 0 
                   val15  = 0 
                   val16  = 0
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
                   icms_18 = 0
                   vtotal = 0.
        end.
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
