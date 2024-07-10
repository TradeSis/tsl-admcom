{admcab.i}
def var fila as char.
   
def var vcon as char.
def var vrel as char.
def var vv as int.
def var vdti like plani.pladat.
def var vdtf like plani.pladat.
def var vmovtdc like tipmov.movtdc format "99".
def var vetbcod like plani.etbcod.
def var varquivo as char.
def var varquivo1 as char.

repeat:
    vrel = "".
    vcon = "".
    update vetbcod label "Filial" colon 16 
        with frame f1 side-label width 80.
    find estab where estab.etbcod = vetbcod no-lock.
    disp estab.etbnom no-label with frame f1.
    update vmovtdc label "Tipo de Nota" colon 16
        with frame f1 side-label.
    if vmovtdc = 0
    then display "GERAL" @ tipmov.movtnom with frame f1.
    else do:
        find tipmov where tipmov.movtdc = vmovtdc no-lock.
        disp tipmov.movtnom no-label with frame f1.
    end.
    update vdti label "Data Inicial" colon 16
           vdtf label "Data Final"
                with frame f1 side-label.

     
    assign fila = ""    .
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/conctb" + string(time).
    else varquivo = "l:~\relat~\conctb" + string(time).
                

    {mdad.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "130"
            &Page-Line = "66"
            &Nom-Rel   = ""confctb""
            &Nom-Sis   = """SISTEMA DE CONTABILIDADE"""
            &Tit-Rel   = """MOVIMENTO FILIAL - "" + 
                            string(estab.etbcod) + ""  "" + 
                          string(vdti,""99/99/9999"") + "" ATE "" + 
                          string(vdtf,""99/99/9999"") "
            &Width     = "130"
            &Form      = "frame f-cabcab1"}
                    
    for each tipmov where if vmovtdc = 0 
                          then true 
                          else tipmov.movtdc = vmovtdc no-lock:           
        
        for each plani where plani.etbcod = estab.etbcod and
                             plani.emite  = estab.etbcod and
                             plani.movtdc = tipmov.movtdc and
                             plani.datexp >= vdti and
                             plani.datexp <= vdtf no-lock by plani.numero:
                 
            find first opcom where opcom.opcant = string(plani.hiccod)
                                no-lock no-error.
                                            

            disp plani.movtdc format "99" column-label "TP"
                 tipmov.movtnom format "x(20)"
                 opcom.opccod when avail opcom
                 plani.numero
                 plani.emite
                 plani.desti format ">>>>>>>99"
                 plani.dtinclu format "99/99/9999" column-label "Data Rec."
                 plani.platot(total)
                 plani.bicms(total) 
                 plani.icms(total)
                  with frame f2 down width 200.
        end.
 
        for each plani where plani.desti  = estab.etbcod and
                             plani.movtdc = tipmov.movtdc and
                             plani.dtinclu >= vdti and
                             plani.dtinclu <= vdtf no-lock:
            
            /*
            if plani.movtdc = 6
            then next.
            */
            
            if plani.movtdc = 4
            then find forne where forne.forcod = plani.emite no-lock no-error.
            
            find first opcom where opcom.opcant = string(plani.hiccod)
                                no-lock no-error.
                                            

            disp tipmov.movtnom format "x(20)"
                 opcom.opccod when avail opcom column-label "CFOP"
                 plani.numero
                 plani.emite
                 plani.desti format ">>>>>>>99"
                 plani.dtinclu format "99/99/9999" column-label "Data Rec."
                 plani.platot(total)
                 plani.bicms(total) 
                 plani.icms(total)
                  with frame f4 down width 200.

        end.
    end.
    
    output close. 
    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo, "").
    end.
    else do:    
        {mrod.i}
    end.
    
end.
