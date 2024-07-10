{admcab.i}

def var vetbcod like estab.etbcod.
def var vmes    as int format "99".
def var vano    as int format "9999".

def var qcon as dec.
def var qmov as dec.
def var qout as dec.


def var vcon as dec.
def var vmov as dec.
def var vout as dec.

def var vsalfin as dec format "->>,>>>,>>9.99".
repeat:

    vout = 0.
    vmov = 0.
    vcon = 0.
    
    vmes = 12.
    vano = year(today) - 1.
    update vetbcod label "Filial" with frame f1 side-label width 80.
    if vetbcod = 0
    then display "GERAL" @ estab.etbnom with frame f1.
    else do:
        find estab where estab.etbcod = vetbcod no-lock.
        display estab.etbnom no-label with frame f1.
    end.
    update vmes label "MES"
           vano label "ANO" with frame f1.
    
 
    display "Processando....." with frame f2 side-label centered.
    
                                    
    find ctbcad where ctbcad.etbcod = estab.etbcod and
                      ctbcad.ctbmes = vmes         and
                      ctbcad.ctbano = vano no-error.
    if not avail ctbcad
    then do transaction:
        create ctbcad.
        assign ctbcad.etbcod = estab.etbcod
               ctbcad.ctbmes = vmes
               ctbcad.ctbano = vano.

        for each ctbhie where ctbhie.etbcod = estab.etbcod and
                              ctbhie.ctbmes = vmes         and
                              ctbhie.ctbano = vano no-lock:
            disp ctbhie.procod no-label with frame f2.
            pause 0.

            find produ where produ.procod = ctbhie.procod no-lock no-error.
            if not avail produ
            then next.
        
            if produ.catcod = 41
            then vcon = vcon + (ctbhie.ctbest * ctbhie.ctbcus).
        
            if produ.catcod = 31
            then vmov = vmov + (ctbhie.ctbest * ctbhie.ctbcus).
        

            if produ.catcod <> 41 and
               produ.catcod <> 31
            then vout = vout + (ctbhie.ctbest * ctbhie.ctbcus).
        end.    
        ctbcad.salini = vout + vcon + vmov.
        ctbcad.salfin = vout + vcon + vmov.

    end.
    
    else do:
        for each ctbhie where ctbhie.etbcod = estab.etbcod and
                              ctbhie.ctbmes = vmes         and
                              ctbhie.ctbano = vano no-lock:
            disp ctbhie.procod no-label with frame f2.
            pause 0.

            find produ where produ.procod = ctbhie.procod no-lock no-error.
            if not avail produ
            then next.
        
            if produ.catcod = 41
            then vcon = vcon + (ctbhie.ctbest * ctbhie.ctbcus).
        
            if produ.catcod = 31
            then vmov = vmov + (ctbhie.ctbest * ctbhie.ctbcus).
        

            if produ.catcod <> 41 and
               produ.catcod <> 31
            then vout = vout + (ctbhie.ctbest * ctbhie.ctbcus).
        end.    
        do transaction:
            ctbcad.salfin = vout + vcon + vmov.
        end.
    
    end.
    
    hide frame f2 no-pause.
    
    disp vcon column-label "Confeccao"            format "->>,>>>,>>9.99"
         vmov column-label "Moveis"               format "->>,>>>,>>9.99"
         vout column-label "Outros"               format "->>,>>>,>>9.99"
         ctbcad.salini column-label "Saldo Inicial" format "->>,>>>,>>9.99"
         ctbcad.salfin column-label "Saldo Final  " format "->>,>>>,>>9.99"
            with frame f3 1 down centered.
            
    do on error undo, retry:
        qcon = 0.
        qmov = 0.
        qout = 0.
        display "Cus :" with frame f4.
        do transaction:
            update ctbcad.percon format "->>9.99999%" to 16
                   ctbcad.permov format "->>9.99999%" to 31
                   ctbcad.perout format "->>9.99999%" to 46
                   "Qtd :"                            at 01
                   qcon          format "->>9.99999%" to 16
                   qmov          format "->>9.99999%" to 31
                   qout          format "->>9.99999%" to 46
                     with frame f4 1 down color black/cyan no-label.
        end.
        disp ctbcad.salini to 61 with frame f4.           
                   
        message "Confirma Percentuais ?" update sresp.
        if not sresp
        then undo, retry.
 
        vcon = 0.
        vmov = 0.
        vout = 0.
        for each ctbhie where ctbhie.etbcod = estab.etbcod and
                              ctbhie.ctbmes = vmes         and
                              ctbhie.ctbano = vano:
            disp ctbhie.procod no-label with frame f2.
            pause 0.

            find produ where produ.procod = ctbhie.procod no-lock no-error.
            if not avail produ
            then next.
            do transaction:
                if produ.catcod = 41
                then do:
                     if ctbhie.ctbest > 1
                     then ctbhie.ctbest = ctbhie.ctbest + int(ctbhie.ctbest *
                                                            ((qcon / 100))).
                     assign ctbhie.ctbcus = ctbhie.ctbcus + (ctbhie.ctbcus * 
                                                        (ctbcad.percon / 100)) 
                            vcon = vcon + (ctbhie.ctbest * ctbhie.ctbcus).
                end.
                if produ.catcod = 31
                then do:
                     if ctbhie.ctbest > 1
                     then ctbhie.ctbest = ctbhie.ctbest + int(ctbhie.ctbest *
                                                            ((qmov / 100))).
                     assign ctbhie.ctbcus = ctbhie.ctbcus + (ctbhie.ctbcus * 
                                                        (ctbcad.permov / 100)) 
                            vmov = vmov + (ctbhie.ctbest * ctbhie.ctbcus).
                end.
                if produ.catcod <> 41 and
                   produ.catcod <> 31
                then do:
                     if ctbhie.ctbest > 1
                     then ctbhie.ctbest = ctbhie.ctbest + int(ctbhie.ctbest *
                                                            ((qout / 100))).
                     assign ctbhie.ctbcus = ctbhie.ctbcus + (ctbhie.ctbcus * 
                                                        (ctbcad.perout / 100)) 
                            vout = vout + (ctbhie.ctbest * ctbhie.ctbcus).
                end.
            end.
        end.    
        do transaction:
            ctbcad.salfin = vout + vcon + vmov.
        end.
        
        display ctbcad.salfin format "->>,>>>,>>9.99" with frame f4.
        
    end.
    
end.         
   
