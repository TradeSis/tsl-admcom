
def input parameter p-oscod like asstec.oscod.
find asstec where asstec.oscod = p-oscod no-lock.

def var vi as in init 0.
def var va as int init 0.


run reg-troca.

procedure reg-troca:
    def var vsel as char format "x(15)" extent 2
        init["30 DIAS","REINCIDENCIA"].
    def var vmarca as char format "x" extent 2.
    format "[" space(0) vmarca[1] space(0) "]"  
       vsel[1]             skip
       "[" space(0) vmarca[2] space(0) "]"  
       vsel[2]             skip
       /*
       "[" space(0) vmarca[3] space(0) "]"
       vsel[3]            skip
       */
       with frame f-sel
       1 down centered no-label row 12 overlay
       title " Aut. Troca ".

    def var vi as in init 0.
    def var va as int init 0.

    vi = 1.
    vmarca = "".
    find first asstec_aux where
               asstec_aux.oscod = asstec.oscod and
               asstec_aux.nome_campo = "REGISTRO-TROCA"
               no-lock no-error.
    if avail asstec_aux
    then do:
        if asstec_aux.valor_campo = "30 DIAS"
        then assign
                vi = 1
                vmarca[vi] = "*".
        else if asstec_aux.valor_campo = "REINCIDENCIA"
        THEN assign
                 vi = 2
                 vmarca[vi] = "*".
    end.                
    
    disp     vmarca
         vsel with frame f-sel.
    va = vi.    
   
    /*if vmarca[va] = ""
    then*/ do:           
    
    repeat:
        choose field vsel with frame f-sel.

        if keyfunction(lastkey) = "end-error"
        then leave.
        if va <> frame-index and
            vmarca[va] = "*"
        then next.    
        if vmarca[frame-index] = "*"
        then do :
            vmarca[frame-index] = "".
            va = frame-index.
            run med(va).
        end.
        else vmarca[frame-index] = "*".
        va = frame-index.    
        disp vmarca
           with frame f-sel.
    end.
    
    if vmarca[va] = "*"
    then do:
        find first asstec_aux where
               asstec_aux.oscod = asstec.oscod and
               asstec_aux.nome_campo = "REGISTRO-TROCA"
               no-error.
        if not avail asstec_aux
        then do:
            create asstec_aux.
            assign
                asstec_aux.oscod = asstec.oscod
                asstec_aux.nome_campo = "REGISTRO-TROCA"
                asstec_aux.data_campo = today
                .
        end.        
        if va = 1
        then do:
            asstec_aux.valor_campo = "30 DIAS".
        end.
        else if va = 2
            then do:
                asstec_aux.valor_campo = "REINCIDENCIA".
            end.
    end.
    end.
    /*else pause.
      */
end procedure.

procedure med:
    def input parameter va as int.
    find first asstec_aux where
               asstec_aux.oscod = asstec.oscod and
               asstec_aux.nome_campo = "REGISTRO-TROCA"
               no-error.
    if avail asstec_aux
    then do on error undo:
        if va = 1
        then do:
            if asstec_aux.valor_campo = "30 DIAS"
            then asstec_aux.valor_campo = "".
        end.
        else if va = 2
            then do:
                if asstec_aux.valor_campo = "REINCIDENCIA"
                then asstec_aux.valor_campo = "".
            end.
    end. 
 end procedure.
