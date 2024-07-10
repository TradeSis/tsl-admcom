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

update vprocod label "Produto"
       vdti label "Data inicial"
       vdtf label "Data Final"
       with frame f1 width 80.

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
    
    for each tt-movim:
            delete tt-movim.
     end.       
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

def var vdata as date.
for each produ where produ.procod = vprocod /*2587*/ no-lock:
    /*disp produ.procod format ">>>>>>>>9" with 1 down.
    pause 0.*/
    
        disp produ.procod label "Produto"
         produ.pronom no-label
         with frame f-produ 1 down side-label no-box.
    

    vctomed-ant = 0.
    find first ctbhie where ctbhie.procod = produ.procod and
                      ctbhie.etbcod = 0 and
                      ctbhie.ctbano = vano-ant and
                      ctbhie.ctbmes = vmes-ant
                      no-lock no-error.
    if avail ctbhie
    then vctomed-ant = ctbhie.ctbcus. 
    vqtdest-ant = 0.
    for each estab no-lock:
        for each ctbhie where ctbhie.procod = produ.procod and
                          ctbhie.etbcod = estab.etbcod and
                          ctbhie.ctbano = vano-ant and
                          ctbhie.ctbmes = vmes-ant no-lock:
            vqtdest-ant = vqtdest-ant + ctbhie.ctbest.
            if vctomed-ant = 0
            then vctomed-ant = ctbhie.ctbcus.
        end.
    end. 

    /***
    if vqtdest-ant = 0
    then do:
        for each estab no-lock:
            for each hiest where hiest.procod = produ.procod and
                             hiest.etbcod = estab.etbcod and
                             hiest.hieano = vano-ant and
                             hiest.hiemes = vmes-ant
                             no-lock .
                vqtdest-ant = vqtdest-ant + hiest.hiestf.
            end.
 
            /**
            find last hiest where hiest.procod = produ.procod and
                             hiest.etbcod = estab.etbcod and
                             hiest.hieano = vano-ant and
                             hiest.hiemes <= vmes-ant
                             no-lock no-error.
            if not avail hiest
            then do:
                find last ctbhie use-index ind-2 where 
                          ctbhie.procod = produ.procod and
                          ctbhie.etbcod = estab.etbcod and
                          ctbhie.ctbano < vano-ant
                           no-lock no-error.
                if avail ctbhie
                then vqtdest-ant = vqtdest-ant + ctbhie.ctbest.
            end.
            else vqtdest-ant = vqtdest-ant + hiest.hiestf.
            **/
        end.
    end.**/
    /***
    if vdti - date(01,01,2009) > 0
    then do:
        for each movim where movim.movtdc = 4 and
                         movim.procod = produ.procod
                         and movim.movdat >= vdti and
                             movim.movdat <= vdtf 
                          no-lock:
        vqtdsai = 0.
        for each vmovim where
                 vmovim.procod = produ.procod and
                 vmovim.movtdc = 5 and
                 vmovim.movdat >= vdt-aux and
                 vmovim.movdat < movim.movdat
                 no-lock:
            vqtdest-ant = vqtdest-ant - vmovim.movqtm.
            vqtdsai = vqtdsai + vmovim.movqtm. 
        end.         
        for each vmovim where
                 vmovim.procod = produ.procod and
                 vmovim.movtdc = 12 and
                 vmovim.movdat >= vdt-aux and
                 vmovim.movdat < movim.movdat
                 no-lock:
            vqtdsai = vqtdsai - vmovim.movqtm.
            vqtdest-ant = vqtdest-ant + vmovim.movqtm.
        end.
        for each vmovim where
                 vmovim.procod = produ.procod and
                 vmovim.movtdc = 13 and
                 vmovim.movdat >= vdt-aux and
                 vmovim.movdat < movim.movdat
                 no-lock:
            vqtdest-ant = vqtdest-ant - vmovim.movqtm.
            vqtdsai = vqtdsai + vmovim.movqtm.
        end. 
    end.
    ***/
    
    /*
    vdti = 01/01/09.
    */
    create tt-movim.
    assign
        tt-movim.tipo   = "Ant"
        tt-movim.movdat = vdti - 1
        tt-movim.movqtm = vqtdest-ant
        tt-movim.movpc  = vctomed-ant
        tt-movim.qtdatu = vqtdest-ant.
        
    vdt-aux = vdti.
    for each movim where movim.movtdc = 4 and
                         movim.procod = produ.procod
                         and movim.movdat >= vdti and
                             movim.movdat <= vdtf 
                          no-lock:
        vqtdsai = 0.
        for each vmovim where
                 vmovim.procod = produ.procod and
                 vmovim.movtdc = 5 and
                 vmovim.movdat >= vdt-aux and
                 vmovim.movdat < movim.movdat
                 no-lock:
            vqtdest-ant = vqtdest-ant - vmovim.movqtm.
            vqtdsai = vqtdsai + vmovim.movqtm. 
        end.         
        for each vmovim where
                 vmovim.procod = produ.procod and
                 vmovim.movtdc = 12 and
                 vmovim.movdat >= vdt-aux and
                 vmovim.movdat < movim.movdat
                 no-lock:
            vqtdsai = vqtdsai - vmovim.movqtm.
            vqtdest-ant = vqtdest-ant + vmovim.movqtm.
        end.
        for each vmovim where
                 vmovim.procod = produ.procod and
                 vmovim.movtdc = 13 and
                 vmovim.movdat >= vdt-aux and
                 vmovim.movdat < movim.movdat
                 no-lock:
            vqtdest-ant = vqtdest-ant - vmovim.movqtm.
            vqtdsai = vqtdsai + vmovim.movqtm.
        end.  

        create tt-movim.
        assign
                tt-movim.tipo   = "Sai"
                tt-movim.movdat = movim.movdat
                tt-movim.movqtm = vqtdsai
                tt-movim.qtdatu = vqtdest-ant
                tt-movim.movpc  = 0.
            
        if vqtdest-ant < 0
        then vqtdest-ant = 0.
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
                             /*+ movim.movipi*/ - vpis - vcofins.
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
        
        /*                
        disp vctomed-ant vqtdest-ant movim.movdat movim.movqtm movim.movpc 
        vctomed-atu vqtdest-atu vpis vcofins movim.datexp.
        pause.
        */
        /*
        message movim.movctm movim.datexp. pause.
        */
        /**
        find last ctbhie where ctbhie.procod = produ.procod and
                               ctbhie.etbcod = 0 and
                               ctbhie.ctbano = year(movim.movdat) and
                               ctbhie.ctbmes = month(movim.movdat)
                               no-error .
        if not avail ctbhie
        then do:
            create ctbhie.
            assign
                ctbhie.etbcod = 0 
                ctbhie.procod = produ.procod 
                ctbhie.ctbano = year(movim.movdat)
                ctbhie.ctbmes = month(movim.movdat)
                .
        end.
        assign
            ctbhie.ctbcus = vctomed-atu
            ctbhie.ctbest = vctomed-ant
            ctbhie.ctbven = vqtdest-ant
            movim.movctm = vctomed-atu.
        **/
        /*disp produ.procod 
             produ.pronom format "x(20)"
             movim.movdat
             vctomed-ant 
             vqtdest-ant
             vctomed-atu
             vqtdest-atu.
          */   
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
    vqtdsai = vqtdest-ant.
    vqtdest-ant = 0.
    for each estab no-lock:
        for each hiest where hiest.procod = produ.procod and
                          hiest.etbcod = estab.etbcod and
                          hiest.hieano = year(vdtf) and
                          hiest.hiemes = month(vdtf) no-lock:
            vqtdest-ant = vqtdest-ant + hiest.hiestf.
            /*
            if vctomed-ant = 0
            then vctomed-ant = hiest.hiepcf. */
        end.    
    end.
    vqtdsai = vqtdsai - vqtdest-ant.
    create tt-movim.
    assign
                tt-movim.tipo   = "Sai"
                tt-movim.movdat = vdtf
                tt-movim.movqtm = vqtdsai
                tt-movim.qtdatu = vqtdest-ant
                tt-movim.movpc  = 0.
     /**
    vqtdsai = 0.
    for each vmovim where
                 vmovim.procod = produ.procod and
                 vmovim.movtdc = 5 and
                 vmovim.movdat >= vdt-aux and
                 vmovim.movdat <= vdtf
                 no-lock:
            vqtdest-ant = vqtdest-ant - vmovim.movqtm.
            vqtdsai = vqtdsai + vmovim.movqtm. 
    end.         
    for each vmovim where
                 vmovim.procod = produ.procod and
                 vmovim.movtdc = 12 and
                 vmovim.movdat >= vdt-aux and
                 vmovim.movdat <= vdtf 
                 no-lock:
            vqtdest-ant = vqtdest-ant + vmovim.movqtm.
    end.
    for each vmovim where
                 vmovim.procod = produ.procod and
                 vmovim.movtdc = 13 and
                 vmovim.movdat >= vdt-aux and
                 vmovim.movdat <= vdtf
                 no-lock:
            vqtdest-ant = vqtdest-ant - vmovim.movqtm.
            vqtdsai = vqtdsai + movim.movqtm.
    end.  
    ***/
    create tt-movim.
    assign
                tt-movim.tipo   = "FIM"
                tt-movim.movdat = vdtf
                tt-movim.movqtm = 0
                tt-movim.qtdatu = vqtdest-ant
                tt-movim.movpc  = 0.
     
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

     /**
     disp movim.movdat 
         movim.movpc  column-label "Custo!Nota" format ">>>>>,>>9.99"
         movim.movalicms column-label "Aliq"  format ">>9.99%"
         (movim.movpc * (movim.movalicms / 100))
                        column-label "ICMS"  format ">>,>>9.99"
         movim.movdes  column-label "Desconto" format ">>,>>9.99"
         movim.movipi / movim.movqtm
            column-label "IPI"      format ">>,>>9.99"
         (vpis + vcofins) / movim.movqtm column-label "Pis/Cof"
         cton-liq  column-label "Custo!Liquido"
         movim.movqtm column-label "Quant!Nota"
         vctomed-ant column-label "Custo!Anterior"
         vqtdest-ant     column-label "Quant!Anterior"        
         movim.movctm column-label "Custo!Atual"
         vqtdest-ant + movim.movqtm column-label "Quant!Atual"
                        format ">>>,>>9.99"
         with frame f-imp down width 140.
         down(1) with frame f-imp.
     
        vdti = movim.movdat.
        vctomed-ant = vctomed-atu.
        vqtdest-ant = vqtdest-atu.
        ***/
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
                                 
    undo.