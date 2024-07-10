/*************************INFORMA€OES DO PROGRAMA******************************
***** Nome do Programa             : rconfnfe.p
***** Diretorio                    : 
*******************************************************************************/

{admcab.i}

def var varqsai as char.
def buffer bestab for estab.
def var vdtini      as date.
def var vdtfin      as date.
def var vetbcod     like estab.etbcod.
def var vok         as log.
def var vtotc1 as dec.
def var vs as log.
def var vop as char format "x(10)" extent 2
    initial ["ANALITICO","SINTETICO"].

def var vquant      like movim.movqtm.
def var vqtd        like movim.movqtm format "->>>9".
def var vdes        like movim.movdes format "->>>9.99".
def var vper        like movim.movpdesc format "->>9.99%".
def var vrec        like movim.movpc format "->>>>,>>9.99".
def var vori        as dec.
def var vqtd1       like vqtd.
def var vdes1       like vdes.
def var vper1       like vper.
def var vrec1       like vrec.
def var vori1       like vori.

def var vtotqtd     like movim.movqtm format ">>>9".
def var vtotdes     like movim.movdes format "->>>9.99".
def var vtotper     like movim.movpdesc format "->>>9.99%".
def var vtotrec     like movim.movpc format ">>>>,>>9.99".
def var vtotori     like movim.movpc format ">>>,>>9.99".
def var vcreper     like movim.movpdesc format "->>9.99%".
def buffer btipmov  for tipmov.
def buffer bmovim   for movim.
def buffer bplani   for plani.
def var vetbnom     like estab.etbnom.
def var vqtdmov     as dec.
def var vvaltotal   as dec.
def var vdesconto   as dec.
def var vpronom     like produ.pronom.
def var vvalreceb   as dec.
def var ttotger     like plani.platot.
def var vcxacod like caixa.cxacod.

def temp-table tt-venda
    field funcod    like func.funcod
    field pladat    like plani.pladat
    field numero    like plani.numero
    field serie     like plani.serie
    field clfcod    like clien.clicod
    field setcod    like setor.setcod
    field procod    like produ.procod
    field movpc     like movim.movpc
    field movqtm    like movim.movqtm
    field precoori  like movim.movpc
    field valtotal  like plani.platot
    field movdes    like movim.movdes
    field movpdesc  like movim.movpdesc
    field valreceb  as dec
    field crecod    like crepl.crecod
    field movsit    like plani.notsit.
def temp-table tt-plani like plani.    
def temp-table tt-movim like movim.
def temp-table tt-can like tt-venda.
def temp-table tt-dev like tt-venda.
def var vcatcod like categoria.catcod.
form with frame fmap.
def var varquivo as char.

form
    vop[1]
    vop[2]
    with frame f-op
        centered 1 down no-labels .

repeat:

    assign 
        vtotqtd = 0 vtotdes = 0 vtotper = 0 vtotrec = 0        
        vqtd = 0 vdes = 0 vper = 0 vrec = 0.

    {selestab.i vetbcod fdata}  
    if vetbcod = 0
    then vetbnom = "DA EMPRESA".
    else vetbnom = "DO ESTAB " + string(estab.etbcod) + " - " + estab.etbnom.
    
    do on error undo:
        update vdtini format "99/99/9999" label "Data Inicial"
               vdtfin format "99/99/9999" label "Data Final" 
            with frame fdata color white/brown side-labels centered.
        if vdtini > vdtfin or
            vdtini = ? or vdtfin = ?
        then do:
            bell.
            message color red/withe
                "Periodo Invalido" view-as alert-box title " Mensagem ".
            undo.
        end.
    end.     
    do on error undo:
       
        vcatcod = 0.
        update vcatcod at 1 with frame fdata.

        if vcatcod > 0
        then do:
            find categoria where  categoria.catcod = vcatcod no-lock no-error.
            if not avail categoria
            then do:
                bell.
                message color red/with
                "Categoria nao cadastrada".
                pause.
                
                undo.
           end.   
           disp categoria.catnom no-label with frame fdata.  
        end.
    end.
    vs = no.
        
    for each tt-plani:
        delete tt-plani.
    end.    
    for each tt-can:
        delete tt-can.
    end.
    for each tt-dev:
        delete tt-dev.
    end.    
        
    vok = no.

    for each tipmov where tipmov.movtdc = 4 no-lock,
        each bestab where if vetbcod > 0
                          then bestab.etbcod = vetbcod
                          else true no-lock,
        each plani where plani.etbcod  =  bestab.etbcod and
                         plani.pladat >= vdtini and 
                         plani.pladat <= vdtfin and
                         plani.movtdc  = tipmov.movtdc and
                         plani.notsit  = no
                         no-lock,
        each movim where movim.etbcod = plani.etbcod
                     and movim.placod = plani.placod 
                        no-lock, 
        first produ where produ.procod = movim.procod no-lock , 
        first clase where clase.clacod = produ.clacod no-lock.
                           
        if vcatcod <> 0 and
           produ.catcod <> vcatcod
        then next.                           
        create tt-venda.
        assign
                tt-venda.pladat   = plani.pladat
                tt-venda.numero   = plani.numero
                tt-venda.serie    = plani.serie
                tt-venda.clfcod   = plani.desti
                tt-venda.setcod   = produ.catcod
                tt-venda.procod   = movim.procod
                tt-venda.movqtm   = movim.movqtm
                tt-venda.movpc    = movim.movpc
                tt-venda.precoori = movim.movpc
                tt-venda.valtotal = movim.movpc * movim.movqtm
                tt-venda.movdes   = movim.movdes * movim.movqtm 
                tt-venda.valreceb = tt-venda.valtotal - tt-venda.movdes
                tt-venda.movpdesc = movim.movpdesc
                tt-venda.crecod   = plani.crecod.
        
        find first tt-plani where 
                   tt-plani.etbcod = plani.etbcod and
                   tt-plani.placod = plani.placod 
                   no-error.
        if not avail tt-plani
        then do:
            create tt-plani.
            buffer-copy plani to tt-plani.
        end.           
        
        create tt-movim.
        buffer-copy movim to tt-movim.
    end.
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/relnfe" + string(time).
    else varquivo = "l:\relat\relnfe" + string(time).
    
    {mdadmcab.i
           &Saida     = "value(varquivo)" 
           &Page-Size = "62"  
           &Cond-Var  = "100"
           &Page-Line = "66"
           &Nom-Rel   = ""rconfnfe""
           &Nom-Sis   = """ """
           &Tit-Rel   = """ RELATORIO NOTAS DE ENTRADA """
           &Width     = "100"
           &Form      = "frame f-cabcab"}

    put skip.

    DISP WITH FRAME FDATA.
    vtotc1 = 0.
    ttotger = 0.

    for each tt-plani:
        display tt-plani.emite format ">>>>>>>9"  label "Emitente"
                tt-plani.desti format ">>>>>>>9"  label "Destinatario"
                tt-plani.serie
                tt-plani.numero skip
                tt-plani.notsit
                tt-plani.pladat skip
                tt-plani.platot format "->>>,>>9.99" 
                tt-plani.bicms format "->>>,>>9.99"  
                tt-plani.icms format "->>>,>>9.99"
                tt-plani.ipi format ">>>,>>9.99"  skip
                tt-plani.descprod format ">>>,>>9.99" 
                tt-plani.acfprod format ">>>,>>9.99" skip(1)
                    with frame f3 side-label width 100.

            for each tt-movim where
                     tt-movim.etbcod = tt-plani.etbcod and
                     tt-movim.placod = tt-plani.placod
                     no-lock:
                find produ where produ.procod = tt-movim.procod no-lock.
                
                display tt-movim.procod
                        produ.pronom format "x(30)"
                        tt-movim.movqtm (total)  column-label "Qtd."
                                    format ">>>>9.99"
                        tt-movim.movpc      column-label "Unit." 
                                            format "->>,>>9.99"
                        tt-movim.movpc * tt-movim.movqtm (total)  
                        column-label "Total"  format "->>,>>9.99"
                        with frame f4 down width 100.
               
               vtotqtd = vtotqtd + tt-movim.movqtm.
           end.
           ttotger = ttotger + tt-plani.platot.         
    end.
    put skip(1)
        "Total Geral" at 40 
         ttotger format ">>>,>>>,>>9.99".
    output close.
    
    if opsys = "UNIX"
    then message "Arquivo gerado: " varquivo.
    else do:
        {mrod.i}
    end.  
    return.
end.


         
                             
                             


 







