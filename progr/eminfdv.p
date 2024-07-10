{admcab.i}

if setbcod <> 995
then do on endkey undo.
    message "Voce não esta logado como 995."
            "Esta logado logado como" setbcod
            view-as alert-box. 
    return.
end.

def var vetbcod like estab.etbcod.       
       
def temp-table ttestoq like estoq.
def new shared temp-table tt-plani like plani.
def new shared temp-table tt-movim like movim.

def var v-nota as int.
def var vnfs as int.

def buffer cplani for plani.
def buffer bplani for plani.
def buffer dplani for plani.

def buffer cplani1 for plani.
def buffer bplani1 for plani.
def buffer dplani1 for plani.


def var vplacod like plani.placod.
def var vnumero like plani.numero.
def var vserie like plani.serie.
def var vprotot like plani.protot.
def var vmovseq like movim.movseq.

def var vetb-desti like estab.etbcod.
def var vcatcod like produ.catcod.
repeat:                   

    update vetbcod vcatcod with 1 down.
    
    find first estab where estab.etbcod = vetbcod no-lock.
          
    
    sresp = no.  
    message "Confirma a emissao da NF de Transferencia ?"   
    update sresp.  
    if not sresp then leave.
                
    for each estoq where estoq.etbcod = estab.etbcod and
                         estoq.estatual > 0 no-lock:
                                                     
        find produ where produ.procod = estoq.procod 
                                no-lock no-error.
        if not avail produ
        then next.
        
        if vcatcod > 0 and
           produ.catcod <> vcatcod
        then next.   
                                        
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
    end.
                
        /*message "1". pause.*/
                
    output to estdv99.d . 
    for each ttestoq: 
        export ttestoq.
    end.      
    output close.
                
        /*********** controle de quantidade 11/04/2000 ***********/

    do transaction:    
        find last cplani where cplani.etbcod = estab.etbcod
                           and cplani.placod <= 500000 exclusive-lock no-error.
        if avail cplani   
        then vplacod = cplani.placod + 1.  
        else vplacod = 1.
                
        find last bplani use-index numero 
                       where bplani.etbcod = estab.etbcod
                         and bplani.emite  = estab.etbcod
                         and bplani.serie  = "V"
                         and bplani.movtdc = 3 exclusive-lock no-error.
        if not avail bplani
        then vnumero = 1.
        else vnumero = bplani.numero + 1.

        vserie  = "V".

        find tipmov where tipmov.movtdc = 3 no-lock. 
        
        disp vnumero 
             vserie with frame f-num centered row 10 overlay 
                                     side-label title " Nota Fiscal " 
                                     color blue/cyan.
                                                                    
                                                
        find dplani where dplani.movtdc = 3 
                      and dplani.etbcod = estab.etbcod
                      and dplani.emite  = estab.etbcod
                      and dplani.serie  = vserie
                      and dplani.numero = vnumero no-lock no-error.
        if avail dplani
        then do:
            message "Numero da NF ja existe neste Estabelecimento".
            undo,retry.
        end.
                
        /*message "2". pause.*/
        create plani.
        assign plani.etbcod   = estab.etbcod 
               plani.placod   = vplacod 
               plani.emite    = estab.etbcod 
               plani.serie    = vserie 
               plani.numero   = vnumero 
               plani.movtdc   = 3 
               plani.desti    = setbcod 
               plani.pladat   = today 
               plani.datexp   = today 
               plani.modcod   = tipmov.modcod 
               plani.notfat   = setbcod 
               plani.dtinclu  = today 
               plani.horincl  = time 
               plani.notsit   = no.
        vprotot = 0. vmovseq = 0.
    end.
     
    for each ttestoq:  
        vmovseq = vmovseq + 1.  
       
        do transaction:
            create movim. 
            ASSIGN movim.movtdc = plani.movtdc 
                   movim.PlaCod = plani.placod 
                   movim.etbcod = plani.etbcod 
                   movim.movseq = vmovseq 
                   movim.procod = ttestoq.procod 
                   movim.movqtm = ttestoq.estatual 
                   movim.movpc  = ttestoq.estcusto 
                   movim.movdat = plani.pladat 
                   movim.MovHr  = int(time) 
                   movim.desti  = plani.desti 
                   movim.emite  = plani.emite. 
                   
                   plani.platot = plani.platot + (movim.movpc * movim.movqtm).
                   plani.protot = plani.protot + (movim.movpc * movim.movqtm).
                   vprotot = vprotot +
                           (ttestoq.estcusto * ttestoq.estatual).
       
        end.
    end.
                
        /*message "3". pause.*/
    vmovseq = 0.
    for each movim where movim.etbcod = plani.etbcod 
                     and movim.placod = plani.placod 
                     and movim.movtdc = plani.movtdc 
                     and movim.movdat = plani.pladat no-lock:

        vmovseq = vmovseq + 1.
        
        run atuest.p (input recid(movim), 
                      input "I", 
                      input 0).
                                  
    end.

    vetb-desti = estab.etbcod.
    message "Filial destino da transferencia "  update vetb-desti.
        
        /*message "4". pause.*/
               
        /*********** controle de quantidade 11/04/2000 ***********/
    
    
    vnfs = int(substr(string(vmovseq / 999,">>9.999"),1,3)).
    if int(substr(string(vmovseq / 999,">>9.999"),5,3)) > 0
    then vnfs = vnfs + 1.

    if vmovseq > 999
    then do:
            bell.
            message color red/with
                    "Numero de itens no pedido: " vmovseq skip
                    "Numero maximo de itens NF: 999" skip
                    "Serão geradas" vnfs "NF(s)"
                     view-as alert-box.
    end.

    if vnfs = 0
    then do:
        message color red/with
        "Nao ha estoque para transferir."
                view-as alert-box.
        undo.        
    end.
                
    do v-nota = 1 to vnfs:
 
        for each tt-plani: delete tt-plani. end.
        for each tt-movim: delete tt-movim. end.
        
    vmovseq = 0.
        
    do transaction:
        /****
        find last cplani1 where cplani1.etbcod = setbcod
                            and cplani1.placod <= 500000 exclusive-lock.
        
        vplacod = cplani1.placod + 1.
        find last bplani1 use-index numero 
                              where bplani1.etbcod = setbcod
                                and bplani1.emite  = setbcod
                                and bplani1.serie  = "U"     
                                and bplani1.movtdc <> 4      
                                and bplani1.movtdc <> 5 exclusive-lock no-error.
        if not avail bplani1
        then vnumero = 1.
        else vnumero = bplani1.numero + 1.

        vserie  = "U".
        find tipmov where tipmov.movtdc = 6 no-lock. 
        
        update vnumero 
               vserie with frame f-num centered row 10 overlay
                           side-label title " Nota Fiscal " color blue/cyan.

        find dplani1 where dplani1.movtdc = 6
                       and dplani1.etbcod = setbcod
                       and dplani1.emite  = setbcod
                       and dplani1.serie  = vserie
                       and dplani1.numero = vnumero no-lock no-error.
        if avail dplani1
        then do:
            message "Numero da NF ja existe neste Estabelecimento". 
            undo,retry.
        end. 
        ***/
        
        find tipmov where tipmov.movtdc = 6 no-lock.
        find last opcom where opcom.movtdc = tipmov.movtdc no-lock.
        
        vplacod = ?.
        vnumero = ?.
        vserie = "1".
        
        create tt-plani.  
        assign tt-plani.etbcod   = setbcod   
               tt-plani.placod   = vplacod   
               tt-plani.emite    = setbcod   
               tt-plani.serie    = vserie   
               tt-plani.numero   = vnumero   
               tt-plani.movtdc   = 6   
               tt-plani.desti    = vetb-desti /*estab.etbcod*/   
               tt-plani.pladat   = today   
               tt-plani.datexp   = today   
               tt-plani.modcod   = tipmov.modcod   
               tt-plani.notfat   = vetb-desti /*estab.etbcod*/   
               tt-plani.dtinclu  = today   
               tt-plani.horincl  = time   
               tt-plani.notsit   = no
               tt-plani.opccod   = int(opcom.opccod)
               tt-plani.hiccod   = int(opcom.opccod). 
                   
    end.         
    vprotot = 0. vmovseq = 0. 
                
        /*message "5". pause.*/
    vmovseq = 0.    
    for each ttestoq:   
        vmovseq = vmovseq + 1. 

        do transaction:
            create tt-movim. 
            ASSIGN tt-movim.movtdc = tt-plani.movtdc 
                   tt-movim.PlaCod = tt-plani.placod 
                   tt-movim.etbcod = tt-plani.etbcod 
                   tt-movim.movseq = vmovseq 
                   tt-movim.procod = ttestoq.procod 
                   tt-movim.movqtm = ttestoq.estatual 
                   tt-movim.movdat = tt-plani.pladat 
                   tt-movim.MovHr  = int(time) 
                   tt-movim.desti  = tt-plani.desti 
                   tt-movim.emite  = tt-plani.emite.
                    
            tt-movim.movpc  = ttestoq.estcusto.

            tt-plani.platot = tt-plani.platot + 
                        (tt-movim.movpc * tt-movim.movqtm).
            tt-plani.protot = tt-plani.protot + 
                        (tt-movim.movpc * tt-movim.movqtm).
            vprotot = vprotot + 
                    (ttestoq.estcusto * ttestoq.estatual).
        end.
        delete ttestoq.
        
    end.
    
    run emissao-NFe.
                    
    /*
    message "PREPARE A IMPRESSORA". 
                
    pause. 
    run imptra_l.p (input recid(plani)).
                
    for each movim where movim.etbcod = plani.etbcod
                         and movim.placod = plani.placod
                         and movim.movtdc = plani.movtdc
                         and movim.movdat = plani.pladat no-lock:

        run atuest.p (input recid(movim),
                      input "I",
                      input 0).

    end.
    */
    end.    
end.           

procedure emissao-NFe:
    def var p-ok as log init no.
    def var p-valor as char.
    p-valor = "".
    def var nfe-emite like plani.emite.
    if setbcod = 998
    then nfe-emite = 900.
    else nfe-emite = setbcod.
    run le_tabini.p (nfe-emite, 0,
            "NFE - TIPO DOCUMENTO", OUTPUT p-valor) .
    if p-valor = "NFE"
    then do:
        run manager_nfe.p (input "5152",
                           input ?,
                           output p-ok).
    end.
end procedure.
