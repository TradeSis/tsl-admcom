{admcab.i }
def var vclacod like produ.clacod.

def var vdiminui as int.
def var vsoma as int.
def input parameter recpla as recid. 

def var vgrupo as int.
def var vtot as int extent 30 format ">>>>>>>>999".
def var vtotal as char format "x(130)".
def var vpro as char format "x(130)".
def temp-table tt-produ
    field procod like produ.procod extent 99
    field etbcod like estab.etbcod
    field distr  as int format ">>>>>>>99" extent 99
    field grupo as int.

def var varquivo as char format "x(20)".
def var ii as int. 
def var i as int.
def temp-table tt-estab
    field etbcod   like estab.etbcod
    field estatual like estoq.estatual
    field estdistr like estoq.estatual
    field estdif   like estoq.estatual
    field proper   like distr.proper.

def var vdif as int.
def var q as int.
def var e as int.
def var tot01 as int.
def var vest as int.

for each tt-produ:
    delete tt-produ.
end.

find plani where recid(plani) = recpla no-lock.

ii = 0.
for each movim where movim.etbcod = plani.etbcod and
                     movim.placod = plani.placod and
                     movim.movtdc = plani.movtdc and
                     movim.movdat = plani.pladat no-lock:

    vpro = vpro + "     " + string(movim.procod,">>>>99").

    ii = ii + 1.

    for each tt-estab:
        delete tt-estab.
    end.

    e = 0.
    q = 0.
    vdif = 0.

   for each estab where estab.etbcod < 900 no-lock:
       if {conv_igual.i estab.etbcod} then next.

        find estoq where estoq.etbcod = estab.etbcod and
                         estoq.procod = movim.procod no-lock no-error.
        if not avail estoq or estoq.estatual <= 0
        then next.
        e = e + estoq.estatual.
   end.
 
     
    e = e + movim.movqtm.
    
    if movim.movqtm > 150
    then vgrupo = 0.
    else do:
        if e >= 200
        then vgrupo = 0.
        else vgrupo = 99.
    end.
     


    find produ where produ.procod = movim.procod no-lock no-error.
    if not avail produ
    then next.
    
    if movim.movqtm <= 150 and (produ.clacod >= 270 and
                                produ.clacod <= 290)
    then vclacod = 700.
    else vclacod = produ.clacod.            
    


    for each estab where estab.etbcod < 900 and
                         estab.etbcod <> 22 no-lock:
       if {conv_igual.i estab.etbcod} then next.
                  
       find estoq where estoq.etbcod = estab.etbcod and
                        estoq.procod = movim.procod no-lock no-error.
        if not avail estoq
        then next.
        
        
        find distr where distr.etbcod = estab.etbcod and
                         distr.clacod = produ.clacod no-lock no-error.
        if not avail distr
        then do: 
            find first distr where distr.clacod = produ.clacod 
                            no-lock no-error.
            if avail distr
            then next.
            else do:
            
                find distr where distr.etbcod = estab.etbcod and
                                 distr.clacod = vgrupo no-lock no-error.
                if not avail distr 
                then do:
                    e = e - estoq.estatual.
                    next.
                end.
            end.
        end.


        if estoq.estatual <= 0
        then vest = 0.
        else vest = estoq.estatual.

        q = int(( e * (distr.proper / 100))).
        if q < 0
        then q = 0.
    
        if vest >= q
        then assign e = e - ( vest - q).
    end.

    vdif = 0.
    for each estab where estab.etbcod < 900 and
                         estab.etbcod <> 22 no-lock:
        if {conv_igual.i estab.etbcod} then next.
        
        find distr where distr.etbcod = estab.etbcod and
                         distr.clacod = vclacod no-lock no-error.
        if not avail distr
        then do:
         
           find distr where distr.etbcod = estab.etbcod and
                            distr.clacod = vgrupo no-lock no-error.
           if not avail distr
           then next.
  
           find first distr where distr.clacod = vclacod 
                           no-lock no-error.
           if avail distr
           then next.

  
        end.


        find estoq where estoq.etbcod = estab.etbcod and
                         estoq.procod = movim.procod no-lock no-error.
        if not avail estoq
        then next.


        if estoq.estatual <= 0
        then vest = 0.
        else vest = estoq.estatual.

        q = int(( e * (distr.proper / 100))).
        if q < 0
        then q = 0.

        if vest >= q
        then next.


        create tt-estab.
        assign tt-estab.etbcod   = estab.etbcod
               tt-estab.estatual = estoq.estatual
               tt-estab.estdistr = q
               tt-estab.proper   = distr.proper.

        vdif = vdif + (tt-estab.estdistr - tt-estab.estatual).

    end. 
  
    vdiminui = 0.
    vsoma    = 0.

    if vdif > movim.movqtm
    then vdiminui = vdif - movim.movqtm.

    
    if vdif < movim.movqtm
    then vsoma = movim.movqtm - vdif.

    repeat:
    for each tt-estab by tt-estab.proper desc:
        
        if vsoma > 0 and (tt-estab.estdistr - tt-estab.estatual) > 1
        then do:
            tt-estab.estdistr = tt-estab.estdistr + 1.
            vsoma = vsoma - 1.
        end.
        
        if vdiminui > 0 and (tt-estab.estdistr - tt-estab.estatual) > 1
        then do:
            tt-estab.estdistr = tt-estab.estdistr - 1.
            vdiminui = vdiminui - 1.
            
            if (tt-estab.estdistr - tt-estab.estatual) <= 0
            then assign tt-estab.estdistr = tt-estab.estdistr + 1
                        vdiminui = vdiminui + 1. 

        end.

        find first tt-produ where tt-produ.etbcod = tt-estab.etbcod no-error.
        if not avail tt-produ
        then do:
            create tt-produ.
            assign tt-produ.etbcod = tt-estab.etbcod.
        end.
        assign tt-produ.procod[ii] = movim.procod
               tt-produ.distr[ii]  = (tt-estab.estdistr - tt-estab.estatual)
               tt-produ.grupo      = vgrupo.
    end.
    if vsoma    = 0 and
       vdiminui = 0
    then leave.
    end.
end.                    

        
    varquivo = "i:\admcom\relat\distr" + string(day(today)).

    {mdadmcab.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "130"
        &Page-Line = "66"
        &Nom-Rel   = ""disdep""
        &Nom-Sis   = """SISTEMA DE ESTOQUE"""
        &Tit-Rel   = """DISTRIBUICAO DE MERCADORIA POR FILIAL""" 
        &Width     = "130"
        &Form      = "frame f-cabcab"}



    put skip "Filial   Perc         ".

    i = 0.
    do i = 1 to ii:
        put "Codigo" "     ".
        vtot[i] = 0.
    end.
    put skip.


    find first tt-produ no-error.
    if not avail tt-produ
    then next.
    i = 0.

    put vpro at 18 skip fill("-",130) format "x(130)" skip.
    
    for each tt-produ by tt-produ.etbcod:
        
        
        find distr where distr.etbcod = tt-produ.etbcod and
                         distr.clacod = vclacod no-lock no-error.
        if not avail distr
        then do: 
            find distr where distr.etbcod = tt-produ.etbcod and
                             distr.clacod = vgrupo no-lock no-error.
            if not avail distr
            then next.
            find first distr where distr.clacod = vclacod 
                            no-lock no-error.
            if avail distr
            then next.

 
        end.

        i = 0.
        put tt-produ.etbcod "   "
            distr.proper "  ".

        do i = 1 to ii:
           put tt-produ.distr[i] "  ".

           vtot[i] = vtot[i] + tt-produ.distr[i].
        end.
        put skip.

        i = 0.
   
    end.
    
    do i = 1 to ii:
        vtotal = vtotal + string(vtot[i],">>>>>>>>>99").
    end.
    
    put skip 
        fill("-",130) format "x(130)" skip
        "Totais........."
        vtotal at 16                  skip
        fill("-",130) format "x(130)" skip.

    output close.
    dos silent value("type " + varquivo + "  > prn").
         

