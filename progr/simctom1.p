{admcab.i}
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
def var cton-liq as dec.

def temp-table tt-movim 
    field tipo as char
    field movdat    like movim.movdat
    field movqtm    like movim.movqtm
    field movpc     like movim.movpc
    field movalicms like movim.movalicms
    field movdes    like movim.movdes
    field movipi    like movim.movipi
    field movctm    like movim.movctm
    field piscof    as dec
    field ctoliq    as dec
    field qtdatu as dec
    index i1 movdat.

 
def var vdti as date format "99/99/9999".
def var vdtf as date format "99/99/9999".
def var vmes as int.
def var vano as int.

def var vmes-aux as int.
def var vano-aux as int.
def var vmes-ant as int.
def var vano-ant as int.

def var vprocod as int.
/*
update vprocod label "Produto"
       vmes format "99"   label "Mes"
       vano format "9999" label "Ano"
       with frame f1 width 80.
*/

vdti = 01/01/2009.
disp vdti label "Data inicial" with frame f1.
update /*vprocod label "Produto"
       vdti label "Data inicial"
       */
       vdtf label "Data Final"
       with frame f1 width 80.

if vdtf < vdti then undo.

vmes = month(vdti).
vano = year(vdtf).
       
if vmes = 12
then assign
        vmes-aux = 1
        vano-aux = vano + 1
        .
else assign
        vmes-aux = vmes + 1  
        vano-aux = vano
        .

if vmes = 1
then assign
        vmes-ant = 12
        vano-ant = vano - 1.
else assign
        vmes-ant = vmes - 1
        vano-ant = vano.
/*
vdti = date(vmes,01,vano).
vdtf = date(vmes-aux,01,vano-aux) - 1.
*/

def var vdt-aux as date.

def var vqtdsai as dec.
def var varquivo as char.
   /**** 
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/" + string(setbcod) + "."
                    + string(time).
    else varquivo = "..~\relat~\" + string(setbcod) + "."
                    + string(time).
    
    {mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "130" 
                &Page-Line = "66" 
                &Nom-Rel   = ""extctom0"" 
                &Nom-Sis   = """Contabil Fiscal""" 
                &Tit-Rel   = """   CUSTO MEDIO CONTABIL """ 
                &Width     = "130"
                &Form      = "frame f-cabcab"}
    **/
def var vdata as date.

def var vsal-ant as dec.
def var vsal-ent as dec.
def var vsal-sai as dec.
def var vsal-atu as dec.
def var vest-atu as dec.

def var vtot31 as dec.
def var vtot41 as dec.
def var vtot35 as dec.
def var vmed31 as dec.
def var vmed41 as dec.
def var vmed35 as dec.
def var vok as log.
def var vval as dec.

def temp-table tthiest like hiest
    index i-ano-mes hieano hiemes.

def temp-table tt-estoq
    field etbcod like estoq.etbcod
    field est41  like estoq.estatual
    field est31  like estoq.estatual
    field est35  like estoq.estatual
    field med41  like estoq.estatual
    field med31  like estoq.estatual
    field med35  like estoq.estatual
    field qtd as dec
    field val as dec.

def temp-table ant-estoq
    field etbcod like estoq.etbcod
    field est41  like estoq.estatual
    field est31  like estoq.estatual
    field est35  like estoq.estatual
    field med41  like estoq.estatual
    field med31  like estoq.estatual
    field med35  like estoq.estatual
    field qtd as dec
    field val as dec.
    
    
def var valicms as dec.
def var vqpro as int. 
for each produ /*where produ.procod = 2587 */ no-lock:
    /*disp produ.procod format ">>>>>>>>9" with 1 down.
    pause 0.*/
    
    disp produ.procod label "Produto"
         produ.pronom no-label
         with frame f-produ 1 down side-label no-box.
    pause 0.
    /* 
    vqpro = vqpro + 1.
    if vqpro = 100
    then leave.
     */
    vctomed-ant = 0.
    find first ctbhie where ctbhie.procod = produ.procod and
                      ctbhie.etbcod = 0 and
                      ctbhie.ctbano = vano-ant and
                      ctbhie.ctbmes = vmes-ant
                      no-lock no-error.
    if avail ctbhie
    then vctomed-ant = ctbhie.ctbcus. 
    vqtdest-ant = 0.
    vtot35 = 0.
            vtot31 = 0.
            vtot41 = 0.
            vmed35 = 0.
            vmed31 = 0.
            vmed41 = 0.


            vqtd = 0.
            vval = 0.
            vok = no.
    for each estab no-lock:
        find ctbhie where ctbhie.procod = produ.procod and
                          ctbhie.etbcod = estab.etbcod and
                          ctbhie.ctbano = vano-ant and
                          ctbhie.ctbmes = vmes-ant no-lock no-error.
        if not avail ctbhie
        then next.
        
        vqtdest-ant = vqtdest-ant + ctbhie.ctbest.
        if vctomed-ant = 0
        then vctomed-ant = ctbhie.ctbcus.
        find first ant-estoq where
                   ant-estoq.etbcod = estab.etbcod
                       no-error.
        if not avail ant-estoq
        then do:
            create ant-estoq.
            ant-estoq.etbcod = estab.etbcod.
                
        end.  
        assign
                ant-estoq.qtd = ctbhie.ctbest
                ant-estoq.val = vctomed-ant.

        find hiest where hiest.etbcod = estab.etbcod and
                             hiest.procod = produ.procod and
                             hiest.hiemes = vmes and
                             hiest.hieano = vano no-lock no-error.
        if avail hiest
        then do:
                assign vqtd = vqtd + hiest.hiestf
                       vval = vval + (hiest.hiepcf * hiest.hiestf) 
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
                        assign 
                            vqtd = vqtd + hiest.hiestf 
                            vval = vval + ( hiest.hiepcf * hiest.hiestf )
                            vok = yes. 
                    end.
                end.
                
        end.
        
        find first tt-estoq where tt-estoq.etbcod = estab.etbcod no-error.
        if not avail tt-estoq
        then do:
            create  tt-estoq.
            assign  tt-estoq.etbcod = estab.etbcod.
        end.
        if avail hiest
        then assign
                tt-estoq.qtd = hiest.hiestf
                tt-estoq.val = hiest.hiepcf.
        else assign
                tt-estoq.qtd = 0
                tt-estoq.val = 0.
    end.
    if vqtd < 0
    then vqtd = 0.
            
    if vqtd = 0 then next.

    create tt-movim.
    assign
        tt-movim.tipo   = "Ant"
        tt-movim.movdat = vdti - 1
        tt-movim.movqtm = vqtdest-ant
        tt-movim.movpc  = vctomed-ant
        tt-movim.qtdatu = vqtdest-ant.
        
    vpis = 0.
    vcofins = 0.
    run piscofal.p( input no, 
                        input 4, 
                        input produ.procod, 
                        output vpis,
                        output vcofins).
    valicms = 0.    
    find last movim where /*movim.etbcod = 993 and*/
                              movim.movtdc = 4 and
                              movim.procod = produ.procod and
                              movim.movdat <= vdti no-lock no-error.
    if not avail movim
    then valicms = 12.
    else valicms = movim.movalicms.
    if valicms = ? then valicms = 0.
    if valicms = 0 then valicms = 12.
    
    if vpis > 0
    then vpis = vctomed-ant * (vpis / 100).
    if vcofins > 0
    then vcofins = vctomed-ant  * (vcofins / 100).         
    vctomed-atu = (vctomed-ant - (vctomed-ant * (valicms / 100))) 
                    - (vpis + vcofins).

    if vctomed-atu = ? then vctomed-atu = 0.
    assign
        tt-movim.movctm = vctomed-atu 
        tt-movim.movalicms = valicms
        tt-movim.piscof = vpis + vcofins
        .
    vctomed-ant = vctomed-atu.
    vctomed-atu = 0.
    if vctomed-ant > 0
    then    
    for each estab no-lock:
        find first ant-estoq where ant-estoq.etbcod = estab.etbcod no-error.
        if not avail ant-estoq
        then next.
        
        vtot35 = 0.
            vtot31 = 0.
            vtot41 = 0.
            vmed35 = 0.
            vmed31 = 0.
            vmed41 = 0.
        if ant-estoq.qtd = 0 or
           ant-estoq.val = 0 or
           ant-estoq.qtd = ? or
           ant-estoq.val = ? 
        then next.   
        if produ.catcod = 31
        then  assign
            vtot31 = ant-estoq.qtd * ant-estoq.val
            vmed31 = vctomed-ant * ant-estoq.qtd.
        if produ.catcod = 41
        then  assign
            vtot41 = ant-estoq.qtd * ant-estoq.val
            vmed41 = vctomed-ant * ant-estoq.qtd.
        if produ.catcod <> 31 and
            produ.catcod <> 41
        then  assign
            vtot35 = ant-estoq.qtd * ant-estoq.val
            vmed35 = vctomed-ant * ant-estoq.qtd. 

        assign ant-estoq.est41 = ant-estoq.est41 + vtot41
                   ant-estoq.est31 = ant-estoq.est31 + vtot31
                   ant-estoq.est35 = ant-estoq.est35 + vtot35
                   ant-estoq.med41 = ant-estoq.med41 + vmed41
                   ant-estoq.med31 = ant-estoq.med31 + vmed31
                   ant-estoq.med35 = ant-estoq.med35 + vmed35
                   .
               
    end.
               
    vdt-aux = vdti.
    vqtdest-ant = 0.
    for each movim where movim.movtdc = 4 and
                         movim.procod = produ.procod
                         and movim.movdat >= vdti and
                             movim.movdat <= vdtf 
                          no-lock:
        for each estab no-lock:
            find estoq where estoq.etbcod = estab.etbcod and
                        estoq.procod = produ.procod
                        no-lock no-error.
            if not avail estoq
            then next.
            run extmovpr.p(input estab.etbcod,
                                      input vdt-aux,
                                      input movim.movdat,
                                      input produ.procod,
                                      output vsal-ant,
                                      output vsal-ent,
                                      output vsal-sai,
                                      output vsal-atu,
                                      output vest-atu).
            vqtdsai = vqtdsai + vsal-sai.
            vqtdest-ant = vqtdest-ant + vsal-atu. 
        end.  
        if vqtdest-ant < 0
        then vqtdest-ant = 0.
    
        create tt-movim.
        assign
                tt-movim.tipo   = "Sai"
                tt-movim.movdat = movim.movdat
                tt-movim.movqtm = vqtdsai
                tt-movim.qtdatu = vqtdest-ant
                tt-movim.movpc  = 0.
            
        vqtdest-atu = vqtdest-ant + movim.movqtm.
        
        vpis = 0.
        vcofins = 0.
        run piscofal.p( input no, 
                        input movim.movtdc, 
                        input movim.procod, 
                        output vpis,
                        output vcofins).
        
        if vpis > 0
        then vpis = (movim.movpc * movim.movqtm) * (vpis / 100).
        if vcofins > 0
        then vcofins = (movim.movpc * movim.movqtm) * (vcofins / 100).         
        vctomed-atu =  
            ((movim.movpc - (movim.movpc * (movim.movalicms / 100))) *
                             movim.movqtm) - (movim.movdes * movim.movqtm)
                             + movim.movipi - vpis - vcofins.
        cton-liq = vctomed-atu / movim.movqtm.
        if vqtdest-ant = ? or vqtdest-ant < 0
        then vqtdest-ant = 0.            
        if vctomed-ant = ? or vctomed-ant < 0
        then vctomed-ant = 0.
        
        if vqtdest-ant > 0 and
               vctomed-ant > 0
        then vctomed-atu = vctomed-atu +
                      (vctomed-ant * vqtdest-ant).
               
        vctomed-atu = vctomed-atu / vqtdest-atu.
        
        create tt-movim.
        assign
                tt-movim.tipo   = "Ent"
                tt-movim.movdat = movim.movdat
                tt-movim.movqtm = movim.movqtm
                tt-movim.movpc  = movim.movpc
                tt-movim.movalicms = movim.movalicms
                tt-movim.movdes = movim.movdes
                tt-movim.movipi = movim.movipi 
                tt-movim.piscof = vpis + vcofins
                tt-movim.ctoliq = cton-liq  
                tt-movim.movctm = vctomed-atu
                tt-movim.qtdatu = vqtdest-atu.
        vdt-aux = movim.movdat.
        vctomed-ant = vctomed-atu.
        vqtdest-ant = vqtdest-atu.
                 
    end.

    for each estab no-lock:
        find first tt-estoq where tt-estoq.etbcod = estab.etbcod no-error.
        if not avail tt-estoq
        then do:
            create  tt-estoq.
            assign  tt-estoq.etbcod = estab.etbcod.
        end.
        
        vtot35 = 0.
            vtot31 = 0.
            vtot41 = 0.
            vmed35 = 0.
            vmed31 = 0.
            vmed41 = 0.

        if produ.catcod = 31
        then  assign
            vtot31 = tt-estoq.qtd * tt-estoq.val
            vmed31 = vctomed-ant * tt-estoq.qtd.
        if produ.catcod = 41
        then  assign
            vtot41 = tt-estoq.qtd * tt-estoq.val
            vmed41 = vctomed-ant * tt-estoq.qtd.
        if produ.catcod <> 31 and
            produ.catcod <> 41
        then  assign
            vtot35 = tt-estoq.qtd * tt-estoq.val
            vmed35 = vctomed-ant * tt-estoq.qtd. 

        assign tt-estoq.est41 = tt-estoq.est41 + vtot41
                   tt-estoq.est31 = tt-estoq.est31 + vtot31
                   tt-estoq.est35 = tt-estoq.est35 + vtot35
                   tt-estoq.med41 = tt-estoq.med41 + vmed41
                   tt-estoq.med31 = tt-estoq.med31 + vmed31
                   tt-estoq.med35 = tt-estoq.med35 + vmed35
                   .
    end.
    create tt-movim.
    assign
                tt-movim.tipo   = "FIM"
                tt-movim.movdat = vdtf
                tt-movim.movqtm = 0
                tt-movim.qtdatu = vqtdest-ant
                tt-movim.movpc  = 0.
    /*** 
    for each tt-movim use-index i1 no-lock:
    
    disp tt-movim.tipo format "x(6)"
         tt-movim.movdat column-label "Data"
         tt-movim.movpc  column-label "Custo!Nota" format ">>>>>,>>9.99"
         when tt-movim.movpc <> 0
         tt-movim.movalicms column-label "Aliq"  format ">>9.99%"
         when tt-movim.movalicms <> 0
         (tt-movim.movpc * (tt-movim.movalicms / 100))
                        column-label "ICMS"  format ">>,>>9.99"
         when tt-movim.movpc <> 0
         tt-movim.movdes  column-label "Desconto" format ">>,>>9.99"
         when tt-movim.movdes <> 0
         tt-movim.movipi / tt-movim.movqtm
            column-label "IPI"      format ">>,>>9.99"
         when tt-movim.movipi <> 0
         tt-movim.piscof / tt-movim.movqtm column-label "Pis/Cof"
         when tt-movim.piscof <> 0
         tt-movim.ctoliq  column-label "Custo!Liquido"
         when tt-movim.ctoliq <> 0
         tt-movim.movqtm column-label "Quant!Nota"
         when tt-movim.movqtm <> 0
         tt-movim.movctm column-label "Custo!Atual"
         when tt-movim.movctm <> ?
         tt-movim.qtdatu column-label "Quant!Atual"
                        format "->>>,>>9.99"
         with frame f-imp down width 140.

    end.
    ***/
end. 
/**
if opsys = "UNIX"
    then varquivo = "/admcom/relat/est-simulado-ant" + 
                    string(day(vdti - 1),"99") +
                    string(vmes-ant,"99") +
                    string(vano-ant,"9999") + ".txt" .
    else varquivo = "..~\relat~\est-simulado-ant" + 
                    string(day(vdti - 1),"99") +
                    string(vmes-ant,"99") +
                    string(vano-ant,"9999") + ".txt" .
    
    {mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "130" 
                &Page-Line = "66" 
                &Nom-Rel   = ""extctom0"" 
                &Nom-Sis   = """Contabil Fiscal""" 
                &Tit-Rel   = """   CUSTO MEDIO CONTABIL EM ""
                                + string(vdti - 1 ,""99/99/9999"") " 
                &Width     = "130"
                &Form      = "frame f-cabcab"}


def var vtpcus as char.
    def var t31 as dec.
    def var t41 as dec.
    def var t35 as dec.
    def var vtt as dec.
    
    for each ant-estoq by ant-estoq.etbcod:
        disp "Filial - " 
             ant-estoq.etbcod column-label "Filial" 
             ant-estoq.med31(total) column-label "CtoMedio Moveis" 
                                format "->>>>,>>>,>>9.99" 
             ant-estoq.med41(total) column-label "CtoMedio Confeccoes" 
                                format "->>>>,>>>,>>9.99" 
             ant-estoq.med35(total) column-label "CtoMedio Outros"
                                format "->>>>,>>>,>>9.99"    
             (ant-estoq.med31 + ant-estoq.med41 + ant-estoq.med35)(total) 
                            column-label "CtoMedio Total" 
                         format "->>>>,>>>,>>9.99"      
             with frame f-impant width 160 down.
 
    end.

output close.
**/

if opsys = "UNIX"
    then varquivo = "/admcom/relat/est-simulado-" + 
                    string(day(vdtf),"99") +
                    string(month(vdtf),"99") +
                    string(year(vdtf),"9999") + ".txt" .
    else varquivo = "..~\relat~\est-simulado-" + 
                    string(day(vdtf),"99") +
                    string(month(vdtf),"99") +
                    string(year(vdtf),"9999") + ".txt" .
    
    {mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "130" 
                &Page-Line = "66" 
                &Nom-Rel   = ""extctom0"" 
                &Nom-Sis   = """Contabil Fiscal""" 
                &Tit-Rel   = """   CUSTO MEDIO CONTABIL EM ""
                                + string(vdtf,""99/99/9999"") " 
                &Width     = "130"
                &Form      = "frame f-cabcab"}


    for each tt-estoq by tt-estoq.etbcod:
        disp "Filial - " 
             tt-estoq.etbcod column-label "Filial" 
             /**
             tt-estoq.est31(total) column-label "Vl.Custo Moveis" 
                                format "->>,>>>,>>9.99" 
             tt-estoq.est41(total) column-label "Vl.Custo Confeccoes" 
                                format "->>,>>>,>>9.99" 
             tt-estoq.est35(total) column-label "Vl.Custo Outros"
                                format "->>,>>>,>>9.99"    
             (tt-estoq.est31 + tt-estoq.est41 + tt-estoq.est35)(total) 
                            column-label "Vl.Custo Total" 
                         format "->>,>>>,>>9.99"
             **/
             tt-estoq.med31(total) column-label "CtoMedio Moveis" 
                                format "->>,>>>,>>9.99" 
             tt-estoq.med41(total) column-label "CtoMedio Confeccoes" 
                                format "->>,>>>,>>9.99" 
             tt-estoq.med35(total) column-label "CtoMedio Outros"
                                format "->>,>>>,>>9.99"    
             (tt-estoq.med31 + tt-estoq.med41 + tt-estoq.med35)(total) 
                            column-label "CtoMedio Total" 
                         format "->>,>>>,>>9.99"      
             with frame f-imp1 width 200 down.
 
    end.

output close.

    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}
    end.
                                 