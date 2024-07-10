{admcab.i}
       
def var vetbcod like estab.etbcod.       
       
def temp-table ttestoq like estoq.

def buffer cplani for plani.
def buffer bplani for plani.
def buffer dplani for plani.

def buffer cplani1 for plani.
def buffer bplani1 for plani.
def buffer dplani1 for plani.

def var vplacod like plani.placod.
def var vnumero like plani.numero format ">>>>>>>9".
def var vserie like plani.serie.
def var vprotot like plani.protot.
def var vmovseq like movim.movseq.

def var vetb-desti like estab.etbcod.
def buffer bestab for estab.
def var q-itens as dec.
def var q-notas as dec.
def var q-estoque as dec.
def var i as int.
repeat:                   

    update vetbcod label "Emitente" with 1 down side-label
            width 80.
    
    find first estab where estab.etbcod = vetbcod no-lock.
          
    disp estab.etbnom no-label.
    
    update vetb-desti at 1 label " Destino".
    if vetb-desti = vetbcod
    then next.
    
    find bestab where bestab.etbcod = vetb-desti no-lock.
    disp bestab.etbnom no-label.
    
    for each estoq where estoq.etbcod = estab.etbcod and
                         estoq.estatual > 0 no-lock:
                                                     
        find produ where produ.procod = estoq.procod 
                                no-lock no-error.
        if not avail produ
        then next.
        
        disp "Verificando itens de estoque: " produ.procod no-label
            with frame f-ver .
        pause 0.
            
        create ttestoq.   
        ASSIGN ttestoq.etbcod    = estoq.etbcod 
               ttestoq.procod    = estoq.procod 
               ttestoq.pronomc   = estoq.pronomc  
               ttestoq.fabfant   = estoq.fabfant  
               ttestoq.estatual  = estoq.estatual  
               ttestoq.estmin    = estoq.estmin  
               ttestoq.estrep    = estoq.estrep  
               ttestoq.estideal  = estoq.estideal  
               ttestoq.estloc    = estoq.estloc  
               ttestoq.estmgoper = estoq.estmgoper  
               ttestoq.estmgluc  = estoq.estmgluc  
               ttestoq.estcusto  = estoq.estcusto  
               ttestoq.estvenda  = estoq.estvenda  
               ttestoq.estdtcus  = estoq.estdtcus  
               ttestoq.estdtven  = estoq.estdtven  
               ttestoq.estreaj   = estoq.estreaj  
               ttestoq.estimp    = estoq.estimp  
               ttestoq.estinvqtd = estoq.estinvqtd  
               ttestoq.estinvdat = estoq.estinvdat  
               ttestoq.ctrcod    = estoq.ctrcod. 
                   
        ASSIGN ttestoq.estinvctm = estoq.estinvctm  
               ttestoq.tabcod    = estoq.tabcod  
               ttestoq.estbaldat = estoq.estbaldat  
               ttestoq.estbalqtd = estoq.estbalqtd  
               ttestoq.estprodat = estoq.estprodat  
               ttestoq.estproper = estoq.estproper  
               ttestoq.estpedcom = estoq.estpedcom  
               ttestoq.estpedven = estoq.estpedven  
               ttestoq.datexp    = estoq.datexp. 
        q-itens = q-itens + 1.
        q-estoque = q-estoque + estoq.estatual.
        
    end.

    q-notas  = int(substr(string(q-itens / 999,">>>>9.99"),1,5))            
    .
    if int(substr(string(q-itens / 999,">>>>9.99"),7,2)) > 0
    then q-notas = q-notas + 1.
    
    disp "Em estoque: " 
          q-estoque label "Quantidade" format ">>>>>9"
          q-itens label "Itens" format ">>>>>>9" 
          q-notas label "NFs" format ">>9"
             with frame fff2.
    pause 0.
    sresp = no.  
    message "Confirma a emissao da NF de Transferencia ?"   
    update sresp.
    if sresp
    then do i = 1 to q-notas:
        find last cplani1 where cplani1.etbcod = vetbcod
                            and cplani1.placod <= 500000 
                            no-lock.
        
        vplacod = cplani1.placod + 1.
        find last bplani1 use-index numero 
                              where bplani1.etbcod = vetbcod
                                and bplani1.emite  = vetbcod
                                and bplani1.serie  = "U"     
                                and bplani1.movtdc <> 4      
                                and bplani1.movtdc <> 5 
                                no-lock no-error.
        if not avail bplani1

        then vnumero = 1.
        else vnumero = bplani1.numero + 1.
        vserie  = "U".
        find tipmov where tipmov.movtdc = 6 no-lock. 
        
        update vnumero 
               vserie with frame f-num centered row 10 overlay
                           side-label title " Nota Fiscal " color blue/cyan.

        find dplani1 where dplani1.movtdc = 6
                       and dplani1.etbcod = vetbcod
                       and dplani1.emite  = vetbcod
                       and dplani1.serie  = vserie
                       and dplani1.numero = vnumero no-lock no-error.
        if avail dplani1
        then do:
            message "Numero da NF ja existe neste Estabelecimento". 
            undo,retry.
        end. 

        run cria-mov.
        
        /*
        pause. 
        run imptra_l.p (input recid(plani)).
        */
                
    end.    
    leave.      
end.     
      
procedure cria-mov:
    do transaction:
        create plani.  
        assign plani.etbcod   = vetbcod   
               plani.placod   = vplacod
                  
               plani.emite    = vetbcod   
               plani.serie    = vserie   
               plani.numero   = vnumero   
               plani.movtdc   = 6   
               plani.desti    = vetb-desti /*estab.etbcod*/   
               plani.pladat   = today   
               plani.datexp   = today   
               plani.modcod   = tipmov.modcod   
               plani.notfat   = vetb-desti /*estab.etbcod*/   
               plani.dtinclu  = today   
               plani.horincl  = time   
               plani.notsit   = no. 
                   
        vprotot = 0. vmovseq = 0. 
                
        for each ttestoq:   
            vmovseq = vmovseq + 1. 
            if vmovseq = 1000
            then leave.
            
            create movim. 
            ASSIGN movim.movtdc = plani.movtdc 
                   movim.PlaCod = plani.placod 
                   movim.etbcod = plani.etbcod 
                   movim.movseq = vmovseq 
                   movim.procod = ttestoq.procod 
                   movim.movqtm = ttestoq.estatual 
                   movim.movdat = plani.pladat 
                   movim.MovHr  = int(time) 
                   movim.desti  = plani.desti 
                   movim.emite  = plani.emite.
                    
            movim.movpc  = ttestoq.estcusto.

            plani.platot = plani.platot + (movim.movpc * movim.movqtm).
            plani.protot = plani.protot + (movim.movpc * movim.movqtm).
            vprotot = vprotot + 
                    (ttestoq.estcusto * ttestoq.estatual).
            delete ttestoq.
        end.
    end.

    for each movim where movim.etbcod = plani.etbcod
                         and movim.placod = plani.placod
                         and movim.movtdc = plani.movtdc
                         and movim.movdat = plani.pladat no-lock:

        run atuest.p (input recid(movim),
                      input "I",
                      input 0).

    end.

          
end procedure.          
