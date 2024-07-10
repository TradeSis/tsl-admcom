{admcab.i}
def var etb_emi like estab.etbcod.
def var etb_des like estab.etbcod.
def var total_nota like plani.platot.
def buffer bestab for estab.
def var total_item like plani.platot.
def var recpla as recid.
def var vmovseq as int.


def new shared temp-table w-movim 
    field marca     as char format "x(01)"
    field procod    like produ.procod
    field pronom    like produ.pronom
    field movqtm    like movim.movqtm 
    field subtotal  like movim.movpc 
    field movpc     like movim.movpc
    field qtd_item  like movim.movqtm
            index ind-1 subtotal desc.



form etb_emi       label "Emitente    " at 1
     estab.etbnom  no-label 
     plani.numero  label "Numero      " at 1
     plani.pladat  label "Data        " at 1
     etb_des       label "Destinatario" at 1
     bestab.etbnom no-label
     total_nota    label "Total Nota  " at 1
            with frame f1 side-label width 80.
     

repeat:

    for each w-movim:
        delete w-movim.
    end.    

    
    update etb_emi 
            with frame f1 side-label.
    find estab where estab.etbcod = etb_emi no-lock no-error.
    if not avail estab
    then do:
        message "Filial Invalida".
        pause.
        undo, retry.
    end.
    display estab.etbnom no-label 
                with frame f1.
                
                
    find first plani use-index nota
               where plani.movtdc = 22  and 
                     plani.etbcod = etb_emi and 
                     plani.emite  = etb_emi and 
                     plani.serie  = "U"      no-lock no-error.
    if not avail plani
    then do:
        message "Nenhuma nota encontrada".
        pause.
        undo, retry.
    end.

    recpla = recid(plani).
    display plani.numero 
            plani.pladat with frame f1.
            
    update etb_des with frame f1.
    find bestab where bestab.etbcod = etb_des no-lock no-error.
    if not avail bestab
    then do:
    
        message "Filial nao Cadastrada".
        pause.
        undo, retry.
    end.

    display bestab.etbnom with frame f1.
    
    total_item = 0.
    total_nota = 0.
    update total_nota with frame f1.

    
    for each estoq where estoq.etbcod = etb_emi no-lock:
    
        if estoq.estatual <= 0.99
        then next.
        if estoq.estcusto <= 1
        then next.

        find produ where produ.procod = estoq.procod no-lock no-error.
        if not avail produ
        then next.
        
        if produ.catcod = 41 or
           produ.catcod = 31
        then. 
        else next.
         
    
        create w-movim.
        assign w-movim.procod = estoq.procod
               w-movim.pronom = produ.pronom 
               w-movim.movpc  = estoq.estcusto
               w-movim.movqtm = estoq.estatual
               w-movim.qtd_item = estoq.estatual 
               w-movim.subtotal = (estoq.estcusto * estoq.estatual).

        display "Gerando tela dos produtos...." estoq.procod
                    with frame f-produto side-label centered no-box.
        pause 0.            

    end.
    hide frame f-produto no-pause.

    run w-movim.p (input total_nota,
                   output total_item).
    if total_item = 0
    then undo, retry.
    
    message "Confirma Nota Fiscal " plani.numero " Total: " total_item update sresp.
    if sresp = no
    then undo, retry.
    
    vmovseq = 0.
    do transaction:
    
        find plani where recid(plani) = recpla.
        plani.desti = etb_des.
        for each w-movim where w-movim.marca = "*" by w-movim.procod:
            vmovseq = vmovseq + 1.

            plani.protot = plani.protot + (w-movim.qtd_item * w-movim.movpc).
            plani.platot = plani.platot + (w-movim.qtd_item * w-movim.movpc).

            create movim.
            assign movim.movtdc = plani.movtdc
                   movim.PlaCod = plani.placod 
                   movim.etbcod = plani.etbcod 
                   movim.movseq = vmovseq 
                   movim.procod = produ.procod 
                   movim.movqtm = w-movim.qtd_item 
                   movim.movpc  = w-movim.movpc 
                   movim.movdat = plani.pladat 
                   movim.MovHr  = int(time) 
                   movim.emite  = plani.emite. 
                   movim.desti  = plani.desti.    
        
        end.
        release plani.
    end.    
    find plani where recid(plani) = recpla no-lock.
end.


