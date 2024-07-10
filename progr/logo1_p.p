{admcab.i}
def var vplacod like plani.placod.
def buffer bplani for plani.
def var vmovseq as int.
def var vpro like produ.procod. 
def var vv as int.
def var cgc-admcom as char.
def var vreg as char.
def var varquivo as char format "x(15)".
def var varq as char.
def var varq2 as char.
def var vetbcod like estab.etbcod.
def var vetb like estab.etbcod.                    
def var vcgc like forne.forcgc.
def var vemite like plani.emite.

/************** plani **************/

def var vnumero like plani.numero.
def var vserie  like plani.serie.
def var vpladat like plani.pladat.
def var vplarec like plani.pladat.
def var vopccod like plani.opccod format "9999".
def var vprotot like plani.protot.
def var vplatot like plani.platot.
def var vbicms like plani.bicms.
def var vicms like plani.icms.
def var vipi  like plani.ipi.
def var vdescprod like plani.descprod.
def var vacfprod like plani.acfprod.
def var voutras like plani.outras.
def var visenta like plani.isenta.


/************ movim ****************/
def var vprocod as char format "x(06)".
def var vmovqtm as dec format ">>>,>>9.999".
def var vmovpc  like movim.movpc.
def var vmovdat like movim.movdat.
def var vmovicms like movim.movicms.
def var vmovpdes like movim.movpdes.
def var vmovdes  like movim.movdes.
def var vmovalicms like movim.movalicms.
def var vmovalipi like movim.movalipi.
def var vmovfre  like movim.movdev.
def var vmovipi  like movim.movipi.


def var vtitnum   like titulo.titnum.
def var vtitdtemi like titulo.titdtemi. 
def var vtitdtven like titulo.titdtven.  
def var vtitpar   like titulo.titpar.
def var vtitvlcob like titulo.titvlcob.

def temp-table tt-titulo
    field emite    like titulo.clifor
    field titnum   like titulo.titnum 
    field titdtemi like titulo.titdtemi  
    field titdtven like titulo.titdtven   
    field titpar   like titulo.titpar 
    field titvlcob like titulo.titvlcob.
 

def temp-table tt-movim
    field emite  like forne.forcod
    field numero like plani.numero
    field serie  like plani.serie
    field procod as char format "x(06)"
    field movqtm like movim.movqtm /*as dec*/
    field movdat like movim.movdat
    field movpc  like movim.movpc 
    field movicms like movim.movicms 
    field movpdes like movim.movpdes 
    field movdes  like movim.movdes 
    field movalicms like movim.movalicms 
    field movalipi like movim.movalipi 
    field movipi   like movim.movipi 
    field movfre  like movim.movdev.


def temp-table tt-plani
    field emite like plani.emite 
    field numero like plani.numero 
    field serie  like plani.serie 
    field pladat like plani.pladat 
    field plarec like plani.pladat 
    field opccod like plani.opccod format "9999" 
    field protot like plani.protot 
    field platot like plani.platot 
    field bicms like plani.bicms 
    field icms like plani.icms 
    field ipi  like plani.ipi 
    field descprod like plani.descprod 
    field acfprod like plani.acfprod 
    field outras like plani.outras 
    field isenta like plani.isenta.

def temp-table tt-erro
    field forcgc like forne.forcgc
    field numero like plani.numero
    field serie  like plani.serie
    field pladat like plani.pladat
    field platot like plani.platot.


def temp-table tt-forne
    field forcgc like forne.forcgc
    field forcod like forne.forcod.

def var vqtd as int.    
repeat:
    vqtd = 0.
    for each tt-titulo:
        delete tt-titulo.
    end.    
    for each tt-forne:
        delete tt-forne.
    end.    

    for each tt-plani:
        delete tt-plani.
    end.
    
    for each tt-movim:
        delete tt-movim.
    end.    
    
    for each tt-erro.
        delete tt-erro.
    end.    

    vetb = 22.
    update vetb label "Filial" with frame f1 side-label width 80.
    if vetb = 0
    then display "Geral" @ estab.etbnom with frame f1.
    else do:
        find estab where estab.etbcod = vetb no-lock no-error.
        display estab.etbnom no-label with frame f1.
    end.
    
    for each forne no-lock:
        if forne.forcgc = ""
        then next.
        
        cgc-admcom = forne.forcgc.
        vv = 0.    
        do vv = 1 to 18:      
            if substring(cgc-admcom,vv,1) = "-" or  
               substring(cgc-admcom,vv,1) = "." or                       
               substring(cgc-admcom,vv,1) = "/" or   
               substring(cgc-admcom,vv,1) = "-"  
            then substring(cgc-admcom,vv,1) = "".  
        end.  
        create tt-forne. 
        assign tt-forne.forcgc = cgc-admcom
               tt-forne.forcod = forne.forcod.
        
    end.    
    
    if opsys = "UNIX"
    then assign varquivo = "/admcom/logosystem/nf.txt" 
                varq     = "/admcom/logosystem/nf-itens.txt"
                varq2    =  "/admcom/logosystem/c-pagar.txt".
    else assign varquivo = "l:~\logosystem~\nf.txt"
                varq     = "l:~\logosystem~\nf-itens.txt"
                varq2    = "l:~\logosystem~\c-pagar.txt".
            
    
    if search(varquivo) = "" or
       search(varq)     = "" or
       search(varq2)    = ""
    then do:
        message "Arquivo nao encontrado".
        pause.
        undo, retry.
    end.
    
    message "Confirma importar arquivos? " 
        view-as alert-box buttons yes-no update sresp.

    if not sresp
    then return.

    disp "Preparando arquivos......>>          "
        with frame fd1 1 down no-box no-label.
    if opsys = "unix"
    then do:
        vqtd = vqtd + 1.
        disp vqtd with frame fd1.
        unix silent  
        value("quoter -d % " + varquivo + 
              " > /admcom/logosystem/nf.quo").
        vqtd = vqtd + 1.
        disp vqtd with frame fd1.
        unix silent 
        value("quoter -d % " + varq + 
              " > /admcom/logosystem/nf-itens.quo").
        vqtd = vqtd + 1.
        disp vqtd with frame fd1.
        unix silent 
        value("quoter -d % " + varq2 + 
              " > /admcom/logosystem/c-pagar.quo").
    end.          
    else do:
        vqtd = vqtd + 1.
        disp vqtd with frame fd1.
        dos silent 
        value("c:~\dlc~\bin~\quoter -d % " + varquivo + 
              " > l:~\logosystem~\nf.quo").
        vqtd = vqtd + 1.
        disp vqtd with frame fd1.
        dos silent 
        value("c:~\dlc~\bin~\quoter -d % " + varq + 
              " > l:~\logosystem~\nf-itens.quo").
        vqtd = vqtd + 1.
        disp vqtd with frame fd1.
         dos silent 
        value("c:~\dlc~\bin~\quoter -d % " + varq2 + 
              " > l:~\logosystem~\c-pagar.quo").
    end.
    if opsys = "unix"
    then assign varquivo = "/admcom/logosystem/nf.quo" 
                varq     = "/admcom/logosystem/nf-itens.quo"
                varq2    = "/admcom/logosystem/c-pagar.quo".
    else assign varquivo = "l:~\logosystem~\nf.quo"
                varq     = "l:~\logosystem~\nf-itens.quo"
                varq2    = "l:~\logosystem~\c-pagar.quo".
    
    disp "Importando arquivo.......>> nf.txt       " 
        with frame fd2 1 down no-box no-label.
    pause 0.
    input from value(varquivo) no-echo.
    repeat:   
        
        import vreg.
        vcgc    = substring(vreg,1,18).
        vnumero = int(substring(vreg,19,06)).
        vserie  = substring(vreg,25,03).
        vpladat = date(int((substring(vreg,30,2))),
                       int((substring(vreg,28,2))),
                       int((substring(vreg,32,4)))). 
        vplarec = date(int((substring(vreg,38,2))),
                       int((substring(vreg,36,2))),
                       int((substring(vreg,40,4)))). 
        vopccod = int(substring(vreg,44,4)).
        vprotot = dec(substring(vreg,48,16)) / 100.        
        vplatot = dec(substring(vreg,64,16)) / 100.       
        vbicms  = dec(substring(vreg,80,16)) / 100.       
        vicms   = dec(substring(vreg,96,16)) / 100.       
        vipi    = dec(substring(vreg,112,16)) / 100.       
        vdescprod = dec(substring(vreg,128,16)) / 100.       
        vacfprod  = dec(substring(vreg,144,16)) / 100.       
        voutras   = dec(substring(vreg,160,16)) / 100.       
        visenta   = dec(substring(vreg,176,16)) / 100.       
        if voutras = 0
        then voutras = vplatot - (vbicms + visenta).
        
        disp vnumero with frame fd2.
        pause 0.
        find first tt-forne where tt-forne.forcgc = vcgc no-error.
        if avail tt-forne
        then find forne where 
                  forne.forcod = tt-forne.forcod no-lock no-error.
        if avail forne
        then do:
            create tt-plani.
            assign tt-plani.emite = forne.forcod
                   tt-plani.numero = vnumero   
                   tt-plani.serie  = vserie   
                   tt-plani.pladat = vpladat   
                   tt-plani.plarec = vplarec   
                   tt-plani.opccod = vopccod 
                   tt-plani.protot = vprotot   
                   tt-plani.platot = vplatot   
                   tt-plani.bicms = vbicms   
                   tt-plani.icms = vicms   
                   tt-plani.ipi  = vipi   
                   tt-plani.descprod = vdescprod   
                   tt-plani.acfprod = vacfprod   
                   tt-plani.outras = voutras   
                   tt-plani.isenta = visenta. 
        end.
        else do:
            create tt-erro.
            assign tt-erro.forcgc = vcgc
                   tt-erro.numero = vnumero  
                   tt-erro.serie  = vserie  
                   tt-erro.pladat = vpladat  
                   tt-erro.platot = vplatot.
        end.
    end.    
    input close.
    
    disp "Importando arquivo.......>> nf-itens.txt " 
        with frame fd3 1 down no-box no-label.
    pause 0.
    
    input from value(varq) no-echo.
    repeat:   
        
        import vreg.
        vcgc    = substring(vreg,1,18).
        vnumero = int(substring(vreg,19,06)).
        vserie  = substring(vreg,25,03).
        vmovdat = date(int((substring(vreg,30,2))),
                       int((substring(vreg,28,2))),
                       int((substring(vreg,32,4)))). 
        vprocod  = substring(vreg,36,6).
        vmovqtm  = dec(substring(vreg,42,16)) / 100000.
        vmovpc   = dec(substring(vreg,58,16)) / 100000. 
        
        vmovicms = dec(substring(vreg,74,16)) / 100. 
        
        vmovpdes = dec(substring(vreg,90,08)) / 100. 
        
        vmovdes  = dec(substring(vreg,98,16)) / 100. 
        vmovalicms = dec(substring(vreg,114,08)) / 100. 
        
        vmovalipi  = dec(substring(vreg,122,08)) / 100. 
        
        vmovfre    = dec(substring(vreg,130,16)) / 100.
        vmovipi    = dec(substring(vreg,146,16)) / 100.
        
        disp vprocod with frame fd3.
        pause 0.
        find first tt-forne where tt-forne.forcgc = vcgc no-error.
        if avail tt-forne
        then find forne where 
                  forne.forcod = tt-forne.forcod no-lock no-error.
        if avail forne
        then do:
            create tt-movim.
            assign tt-movim.emite = forne.forcod
                   tt-movim.numero = vnumero   
                   tt-movim.serie  = vserie   
                   tt-movim.movdat = vmovdat
                   tt-movim.procod = vprocod
                   tt-movim.movqtm = vmovqtm
                   tt-movim.movpc  = vmovpc
                   tt-movim.movicms = vmovicms
                   tt-movim.movpdes = vmovpdes
                   tt-movim.movdes = vmovdes
                   tt-movim.movalicms = vmovalicms
                   tt-movim.movalipi = vmovalipi
                   tt-movim.movfre = vmovfre
                   tt-movim.movipi = vmovipi.
        end.
    end.
    input close.
    
    disp "Importando arquivo.......>> c-pagar.txt  " 
        with frame fd4 1 down no-box no-label.
    pause 0.
 
    input from value(varq2) no-echo.
    repeat:   
        
        import vreg.
        vcgc      = substring(vreg,1,18).
        vtitnum   = (substring(vreg,19,11)).
        vtitdtemi = date(int((substring(vreg,32,2))),
                         int((substring(vreg,30,2))),
                         int((substring(vreg,34,4)))). 
        vtitdtven = date(int((substring(vreg,40,2))),
                         int((substring(vreg,38,2))),
                         int((substring(vreg,42,4)))). 
        vtitpar   = int(substring(vreg,46,2)).
        vtitvlcob = dec(substring(vreg,48,16)) / 100.        

        disp vtitnum with frame fd4.
        pause 0.
        find first tt-forne where tt-forne.forcgc = vcgc no-error.
        if avail tt-forne
        then find forne where 
                  forne.forcod = tt-forne.forcod no-lock no-error.
        if avail forne
        then do:
            create tt-titulo.
            assign tt-titulo.emite    = forne.forcod
                   tt-titulo.titnum   = vtitnum
                   tt-titulo.titdtemi = vtitdtemi
                   tt-titulo.titdtven = vtitdtven
                   tt-titulo.titpar   = vtitpar
                   tt-titulo.titvlcob = vtitvlcob.
        end.
    end.    
    input close.
    
    /***
    for each tt-plani :
         display tt-plani.numero
                tt-plani.pladat
                tt-plani.plarec
                tt-plani.serie
                tt-plani.protot column-label "Total!Produto"
                tt-plani.platot column-label "Total!Nota" 
                tt-plani.bicms
                tt-plani.icms
                tt-plani.ipi
                tt-plani.descprod
                tt-plani.acfprod.
                
        vpro = 360.
        for each tt-movim where 
                 tt-movim.emite  = tt-plani.emite  and
                 tt-movim.numero = tt-plani.numero and
                 tt-movim.serie  = tt-plani.serie  and
                 tt-movim.movdat = tt-plani.pladat:
                 
            tt-movim.procod = string(vpro).           
            vpro = vpro + 1.
            display tt-movim.procod
                    tt-movim.emite
                    tt-movim.numero
                    tt-movim.movpc   format ">>>>,>>9.999"
                    tt-movim.movqtm (total) format ">>>>,>>9.999"
                    (tt-movim.movpc * tt-movim.movqtm)(total)
                    tt-movim.movicm
                    tt-movim.movalicms.
        end.
        
        for each tt-titulo where
             tt-titulo.titnum = string(tt-plani.numero)
             no-lock.
            disp tt-titulo.titnum  
                 tt-titulo.titpar
                 tt-titulo.titdtemi
                 tt-titulo.titdtven
                 tt-titulo.titvlcob 
                 .   
        end.                    
    end.

    message "fim". pause.
    ***/  
    /***/
    disp "Gravando dados...........>>              " 
        with frame fd5 1 down no-box no-label.
    pause 0.

    for each tt-plani: 
        find first plani where plani.numero = tt-plani.numero and
                               plani.emite  = tt-plani.emite  and 
                               plani.desti  = 22              and 
                               plani.serie  = tt-plani.serie  and 
                               plani.etbcod = 22              and 
                               plani.movtdc = 23 no-lock no-error.
        if avail plani 
        then next.
        
        do transaction:
            find last bplani where bplani.etbcod = 22      and
                                   bplani.placod <= 500000 and
                                   bplani.placod <> ? no-lock no-error.
            if not avail bplani 
            then vplacod = 1. 
            else vplacod = bplani.placod + 1. 
            create plani. 
            assign plani.etbcod   = 22 
                   plani.placod   = vplacod 
                   plani.protot   = tt-plani.protot 
                   plani.emite    = tt-plani.emite
                   plani.bicms    = tt-plani.bicms 
                   plani.icms     = tt-plani.icms 
                   plani.descpro  = tt-plani.descprod
                   plani.acfprod  = tt-plani.acfprod 
                   plani.ipi      = tt-plani.ipi 
                   plani.platot   = tt-plani.platot 
                   plani.serie    = tt-plani.serie 
                   plani.numero   = tt-plani.numero 
                   plani.movtdc   = 23 
                   plani.desti    = 22 
                   plani.modcod   = "DUP"
                   plani.opccod   = tt-plani.opccod
                   plani.notfat   = tt-plani.emite 
                   plani.dtinclu  = tt-plani.plarec 
                   plani.pladat   = tt-plani.pladat
                   plani.datexp   = today 
                   plani.horincl  = time 
                   plani.hiccod   = tt-plani.opccod
                   plani.notsit   = no 
                   plani.outras   = tt-plani.outras 
                   plani.isenta   = tt-plani.isenta.
            disp plani.numero with frame fd5.        
            pause 0.
            vpro = 360. 
            vmovseq = 0.
            for each tt-movim where  
                     tt-movim.emite  = tt-plani.emite  and 
                     tt-movim.numero = tt-plani.numero and 
                     tt-movim.serie  = tt-plani.serie  and 
                     tt-movim.movdat = tt-plani.pladat:
                 
                tt-movim.procod = string(vpro).           
                vpro = vpro + 1. 
                
                create movim. 
                assign movim.movtdc = plani.movtdc 
                       movim.PlaCod = plani.placod 
                       movim.etbcod = plani.etbcod 
                       movim.movseq = vmovseq
                       movim.procod = vpro
                       movim.movqtm = tt-movim.movqtm 
                       movim.movpc  = tt-movim.movpc 
                       movim.movicms = tt-movim.movicms
                       movim.movpdes = tt-movim.movdes 
                       movim.movdes  = tt-movim.movdes
                       movim.Movalicms = tt-movim.movalicms 
                       movim.Movalipi  = tt-movim.movalipi 
                       movim.movipi    = ((tt-movim.movpc * tt-movim.movqtm) * 
                                           (tt-movim.movalipi / 100)) 
                       movim.movdev    = tt-movim.movfre  
                       movim.movdat    = plani.pladat 
                       movim.MovHr     = int(time) 
                       movim.datexp    = plani.datexp 
                       movim.desti     = plani.desti 
                       movim.emite     = plani.emite.
            
                disp movim.procod with frame fd5.
                pause 0.
            end.
        end.
    end.
    /*****************
    for each tt-titulo by tt-titulo.titdtven.
    
        find first titulo use-index iclicod where 
                   titulo.empcod = 19  and 
                   titulo.titnat = yes and 
              /*   titulo.modcod = ""  and */ 
                   titulo.etbcod = 22  and 
                   titulo.clifor = tt-titulo.emite  and 
                   titulo.titnum = tt-titulo.titnum and 
                   titulo.titpar = tt-titulo.titpar no-lock no-error. 
                   
        find forne where forne.forcod = tt-titulo.emite no-lock.
              
        find titulo where titulo.empcod = 19     and   
                          titulo.titnat = yes    and    
                          titulo.modcod = "DUP"  and     
                          titulo.etbcod = 22     and    
                          titulo.clifor = tt-titulo.emite  and    
                          titulo.titnum = tt-titulo.titnum and   
                          titulo.titpar = tt-titulo.titpar no-lock no-error. 
                          
        if not avail titulo 
        then do transaction:  
            create titulo. 
            assign titulo.exportado = yes 
                   titulo.empcod = 19
                   titulo.titsit = "lib" 
                   titulo.titnat = yes 
                   titulo.modcod = "DUP" 
                   titulo.etbcod = 22
                   titulo.datexp = today 
                   titulo.clifor = tt-titulo.emite
                   titulo.titnum = tt-titulo.titnum
                   titulo.titpar  = tt-titulo.titpar
                   titulo.titdtemi = tt-titulo.titdtemi
                   titulo.titdtven = tt-titulo.titdtven
                   titulo.titvlcob = tt-titulo.titvlcob
                   titulo.cobcod   = 0  
                   titulo.bancod   = 0  
                   titulo.agecod   = "0"  
                   titulo.evecod   = 3  
                   titulo.titvljur = 0 
                   titulo.titvldes = 0 
                   titulo.titobs[1] = "" 
                   titulo.titobs[2] = "".
            disp titulo.titnum with frame fd5.
            pause 0.
        end.
    end.
    ***********/
end.
