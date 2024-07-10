{admcab.i}

def stream stela.

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

def var vtipo as char.

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

def var vcpf like clien.ciccgc.
def var vnome like clien.clinom.

def var vetbcod like estab.etbcod.
def var vdti as date format "99/99/9999".
def var vdtf as date format "99/99/9999".
def var vdata as date format "99/99/9999".
def var vtotal as dec. 
def var vesq as char extent 2  format "x(20)"
    init["Analitico","Sintetico"].
def var vindex as int.
def var ok-serie as log.

def temp-table tt-numero
    field etbcod like plani.etbcod
    field pladat like plani.pladat
    field serie  like plani.serie
    field numero like plani.numero
    field valor as dec format ">>>>>>>>9.99"
    .
    
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
    
    /**************
    vindex = 0.
    if vetbcod > 0
    then do with frame f-esq no-label centered:
        disp vesq.
        choose field vesq.
        vindex = frame-index.
    end.
    ************/

    def var p-avista as log format "Sim/Nao" init no.
    def var p-aprazo as log format "Sim/Nao" init no.
    def var p-filial as log format "Sim/Nao" init no.
    def var p-data   as log format "Sim/Nao" init no.
    def var p-documento as log format "Sim/Nao" init no.
    def var p-produto as log format "Sim/Nao" init no.
    
    /*
    update p-filial    at 1 when vetbcod = 0 label "Por filial?    "
            with frame ff2.
    */
    p-filial = yes.
    disp p-filial label "Por filial?    " with frame ff2.
    
    update p-avista    at 1 label "Venda a Vista? "
                        with frame ff2.
    if p-avista = no
    then p-aprazo = yes.
    update p-aprazo    at 1 label "Venda a Prazo? "
                        with frame ff2.
    
    if p-avista = no and p-aprazo = no then undo.
    
    update p-data      at 1 label "Por Data?      "
        with frame ff2 1 down side-label no-box.
        
    if p-data = no
    then
    update p-documento at 1 label "Por Documento? "
           p-produto   at 1 label "Por Produto?   "
           with frame ff2 1 down side-label no-box. 

    if not p-filial and
       not p-documento and
       not p-produto
    then next.

    output stream stela to terminal.
    
    varquivo = "/admcom/relat/venda" + string(vetbcod,"999") +
                            string(day(vdti),"99") +
                            string(month(vdtf),"99") +
                            "." + string(time)
                            .
                            
    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "200"
        &Page-Line = "66"
        &Nom-Rel   = ""rel_map2""
        &Nom-Sis   = """SISTEMA DE CONTABILIDADE  FILIAL - ""
                        + string(vetbcod,"">>9"")"
        &Tit-Rel   = """MOVIMENTACOES DE VENDA - PERIODO DE "" +
                        string(vdti,""99/99/9999"") + "" A "" +
                        string(vdtf,""99/99/9999"") "
        &Width     = "200"
        &Form      = "frame f-cabcab"}
    

    xx = 0.
    if p-produto 
    then
    for each estab where if vetbcod = 0
                         then true
                         else estab.etbcod = vetbcod no-lock:
        vtotal = 0.
        do vdata = vdti to vdtf:
        disp stream stela estab.etbcod vdata label "Data" with side-label.
        pause 0.
        for each plani where plani.movtdc = 5 and
                         plani.etbcod = estab.etbcod and
                         plani.emite  = estab.etbcod and
                         plani.pladat = vdata
                         no-lock by etbcod by pladat by serie by numero 
                         :

            if p-avista = no and plani.crecod = 1 then next.
            if p-aprazo = no and plani.crecod = 2 then next.

            if plani.modcod = "CAN" then next.
            if plani.platot < plani.protot then next.
            if substr(plani.notped,1,1) = "C" and
                       (plani.ufemi <> "" or
                        (plani.ufdes <> "" and
                         plani.ufdes <> "C"))
            then.
            else if plani.etbcod <> 200 then next.
 
            if substr(plani.ufemi,1,1) = "B" or
               substr(plani.ufemi,1,1) = "E" or
               num-entries(plani.notped,"|") > 1
            then vtipo = "CUPOM".
            else vtipo = "NFCe".
            for each movim where movim.etbcod = plani.etbcod and
                                 movim.placod = plani.placod and
                                 movim.movtdc = plani.movtdc and
                                 movim.movdat = plani.pladat
                                 no-lock:
                find produ where produ.procod = movim.procod
                                            no-lock no-error.
                
                {valida-venda-fiscal.i}
                
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
                    icms_18 = icms_18 + ((movim.movpc * movim.movqtm) * 0.18)
                    .
                else if movim.movalicms = 00
                then val11  = val11 + (movim.movpc * movim.movqtm).     
                vtotal = vtotal + (movim.movpc * movim.movqtm).  
                if p-produto and vtotal > 0
                then do:
                    disp plani.etbcod column-label "Fil"
                         plani.pladat column-label "Data"
                         plani.serie  column-label "Serie"
                         plani.numero column-label "Numero" format ">>>>>>>>9"
                         vtipo        no-label
                         vtotal column-label "Valor"
                         movim.procod column-label "Produto"
                         produ.pronom column-label "Descricao" format "x(25)"
                         movim.opfcod column-label "CFOP"
                         movim.movpc  column-label "Preco"
                         movim.movqtm column-label "Quant"
                    val07 
                        column-label "VDA.07%" format ">>>,>>9.99"
                    icms_07 
                        column-label "Imposto" format ">>>,>>9.99"
                    val18 
                        column-label "VDA.12%" format ">>>,>>9.99" 
                    icms_12 
                        column-label "Imposto" format ">>>,>>9.99"     
                    val15  
                        column-label "VDA.17%" format ">>>,>>9.99" 
                    icms_17 
                        column-label "Imposto" format ">>>,>>9.99"   
                    val16  
                        column-label "VDA.18%" format ">>>,>>9.99" 
                    icms_18 
                        column-label "Imposto" format ">>>,>>9.99"          
                    val11  format ">>>,>>9.99" 
                        column-label "SUBST  "
                    val12  format ">>>,>>9.99" 
                        column-label "ISENTOS"
                       with frame f-produ down width 250.
                                           down with frame f-produ.
                                           
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
        end.
    end.
    else if p-documento
    then
    for each estab where if vetbcod = 0
                         then true
                         else estab.etbcod = vetbcod no-lock:
        vtotal = 0.
        do vdata = vdti to vdtf:
        disp stream stela estab.etbcod vdata with side-label.
        pause 0.
        for each plani where plani.movtdc = 5 and
                         plani.etbcod = estab.etbcod and
                         plani.emite  = estab.etbcod and
                         /*plani.serie  = "3" and*/
                         plani.pladat = vdata
                         no-lock by etbcod by pladat by serie by numero  :

            if p-avista = no and plani.crecod = 1 then next.
            if p-aprazo = no and plani.crecod = 2 then next.
            
            if plani.modcod = "CAN" then next.
            if plani.platot < plani.protot then next.
            if substr(plani.notped,1,1) = "C" and
                       (plani.ufemi <> "" or
                        (plani.ufdes <> "" and
                         plani.ufdes <> "C"))
            then.
            else if plani.etbcod <> 200 then next.
            
            if substr(plani.ufemi,1,1) = "B" or
               substr(plani.ufemi,1,1) = "E" or
               num-entries(plani.notped,"|") > 1
            then vtipo = "CUPOM".
            else vtipo = "NFCe".

            for each movim where movim.etbcod = plani.etbcod and
                                 movim.placod = plani.placod and
                                 movim.movtdc = plani.movtdc and
                                 movim.movdat = plani.pladat
                                 no-lock:
                find produ where produ.procod = movim.procod
                                            no-lock no-error.
                
                {valida-venda-fiscal.i}
                
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
                    icms_18 = icms_18 + ((movim.movpc * movim.movqtm) * 0.18)
                    .
                else if movim.movalicms = 00
                then val11  = val11 + (movim.movpc * movim.movqtm).   
                vtotal = vtotal + (movim.movpc * movim.movqtm).    
            end.
 
            if p-documento and vtotal > 0
            then do:
                
                create tt-numero.
                assign
                    tt-numero.etbcod = plani.etbcod 
                    tt-numero.pladat = plani.pladat
                    tt-numero.serie  = plani.serie
                    tt-numero.numero = plani.numero
                    .
                find first clien where 
                    clien.clicod = plani.desti no-lock no-error.
                if avail clien
                then assign
                        vcpf = clien.ciccgc   
                        vnome = clien.clinom
                             .
                else assign
                         vcpf = "" vnome = "".
                                
                disp plani.etbcod column-label "Fil"
                        plani.pladat column-label "Data"
                        plani.serie  column-label "Serie"
                        plani.numero column-label "Numero" format ">>>>>>>>9"
                        vtipo no-label
                        vcpf         column-label "CPF" format "x(15)"
                        vnome        column-label "NOME" format "x(25)"
                        vtotal column-label "Total"
                        val07 
                            column-label "VDA.07%" format ">>>,>>9.99"
                        icms_07 
                            column-label "Imposto" format ">>>,>>9.99"
                        val18 
                            column-label "VDA.12%" format ">>>,>>9.99" 
                        icms_12 
                            column-label "Imposto" format ">>>,>>9.99"     
                        val15  
                            column-label "VDA.17%" format ">>>,>>9.99" 
                        icms_17 
                            column-label "Imposto" format ">>>,>>9.99"   
                        val16  
                            column-label "VDA.18%" format ">>>,>>9.99" 
                        icms_18 
                            column-label "Imposto" format ">>>,>>9.99"
                        val11  format ">>>,>>9.99" 
                            column-label "SUBST  "
                        val12  format ">>>,>>9.99" 
                            column-label "ISENTOS"
                        with frame f-doc down width 205.
                    down with frame f-doc.   
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
    end.
    else if p-filial
    then
    for each estab where if vetbcod = 0
                         then true
                         else estab.etbcod = vetbcod no-lock:
        vtotal = 0.
        do vdata = vdti to vdtf:
        disp stream stela estab.etbcod vdata with side-label.
        pause 0.
        for each plani where plani.movtdc = 5 and
                         plani.etbcod = estab.etbcod and
                         plani.emite  = estab.etbcod and
                         /*plani.serie  = "3" and*/
                         plani.pladat = vdata
                         no-lock by etbcod by pladat by serie by numero  :
            
            if p-avista = no and plani.crecod = 1 then next.
            if p-aprazo = no and plani.crecod = 2 then next.

            if plani.modcod = "CAN" then next.
            if plani.platot < plani.protot
            then next.
            if substr(plani.notped,1,1) = "C" and
                       (plani.ufemi <> "" or
                        (plani.ufdes <> "" and
                         plani.ufdes <> "C"))
            then.
            else if plani.etbcod <> 200 then next.
 
            if substr(plani.ufemi,1,1) = "B" or
               substr(plani.ufemi,1,1) = "E" or
               num-entries(plani.notped,"|") > 1
            then vtipo = "CUPOM".
            else vtipo = "NFCe".

            for each movim where movim.etbcod = plani.etbcod and
                                 movim.placod = plani.placod and
                                 movim.movtdc = plani.movtdc and
                                 movim.movdat = plani.pladat
                                 no-lock:
                find produ where produ.procod = movim.procod no-lock no-error.
                
                {valida-venda-fiscal.i}
                
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
                    icms_18 = icms_18 + ((movim.movpc * movim.movqtm) * 0.18)
                    .
                else if movim.movalicms = 00
                then val11  = val11 + (movim.movpc * movim.movqtm).       
                vtotal = vtotal + (movim.movpc * movim.movqtm).
            end.
        end.
        if vtotal > 0 and p-data
        then do:    
            display estab.etbcod column-label "Fil"
                vdata column-label "Data"
                    vtipo no-label
                    vtotal(total) column-label "Venda" format ">>>>>,>>9.99"
                    val07(total)
                        column-label "VDA.07%" format ">>>,>>9.99"
                    icms_07(total)
                        column-label "Imposto" format ">>>,>>9.99"
                    val18(total) 
                        column-label "VDA.12%" format ">>>,>>9.99" 
                    icms_12(total) 
                        column-label "Imposto" format ">>>,>>9.99"     
                    val15(total) 
                        column-label "VDA.17%" format ">>>,>>9.99" 
                    icms_17(total) 
                        column-label "Imposto" format ">>>>>,>>9.99"   
                    val16(total)  
                        column-label "VDA.18%" format ">>>>>,>>9.99" 
                    icms_18(total) 
                        column-label "Imposto" format ">>>>>,>>9.99"          
                    val11(total)  format ">>>>>,>>9.99" 
                        column-label "SUBST  "
                    val12(total)  format ">>>>>,>>9.99" 
                        column-label "ISENTOS"
                        with frame f-fil down width 180.
            down with frame f-fil.
         
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
        if p-data = no
        then do:
            find first tt-numero where
                       tt-numero.etbcod = estab.etbcod
                       no-error.
            if not avail tt-numero
            then do:           
                create tt-numero.
                tt-numero.etbcod = estab.etbcod.
            end.    
            tt-numero.valor  = tt-numero.valor + vtotal .

            display estab.etbcod column-label "Fil"
                /*vdata column-label "Data"
                    vtipo no-label*/
                    vtotal(total) column-label "Venda" format ">>>>>,>>9.99"
                    val07(total)
                        column-label "VDA.07%" format ">>>,>>9.99"
                    icms_07(total)
                        column-label "Imposto" format ">>>,>>9.99"
                    val18(total) 
                        column-label "VDA.12%" format ">>>,>>9.99" 
                    icms_12(total) 
                        column-label "Imposto" format ">>>,>>9.99"     
                    val15(total) 
                        column-label "VDA.17%" format ">>>,>>9.99" 
                    icms_17(total) 
                        column-label "Imposto" format ">>>>>,>>9.99"   
                    val16(total)  
                        column-label "VDA.18%" format ">>>>>,>>9.99" 
                    icms_18(total) 
                        column-label "Imposto" format ">>>>>,>>9.99"          
                    val11(total)  format ">>>>>,>>9.99" 
                        column-label "SUBST  "
                    val12(total)  format ">>>>>,>>9.99" 
                        column-label "ISENTOS"
                        with frame f-fil down width 180.
            down with frame f-fil1.
         
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

    output close.
    output stream stela close.
    
    output to /admcom/relat/relatorio-documento-fiscal.csv.
    for each tt-numero:
        put tt-numero.etbcod ";"
            tt-numero.pladat ";"
            tt-numero.serie  ";"
            tt-numero.numero ";"
            tt-numero.valor
            skip.
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

