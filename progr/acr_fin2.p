{admcab.i}
def var indice as char.
def var vlista  as char format "x(10)" extent 3 
        initial ["Alfabetica","   Conta  ","Valor"].
        
def var totacr  like plani.platot.
def var acutot  like plani.platot.
def var minacr  like plani.platot.
def var varquivo as char format "x(30)".
def var vdti     like plani.pladat.
def var vdtf     like plani.pladat.
def var v-sai    as log. 

def temp-table wplani
    field   wclicod  like clien.clicod
    field   wclinom  like clien.clinom
    field   wven     like plani.platot
    field   wacr     like plani.platot
        index ind-1 wclinom
        index ind-2 wclicod
        index ind-3 wven.
       
def var dt     like plani.pladat.

repeat:

    for each wplani:
        delete wplani.
    end.

    assign totacr = 0
           minacr = 0
           acutot = 0.

    update totacr label "Total do Acrescimo"
           minacr label "Vlrs.Inferiores a "
                with frame f1 side-label width 80.
        

    update vdti label "Periodo"
           vdtf no-label with frame f1.


    v-sai = no.
    do dt = vdti to vdtf:
        if v-sai = no
        then do:

        for each estab no-lock,
            each plani where plani.pladat = dt and
                    plani.etbcod = estab.etbcod and
                    plani.movtdc = 5 no-lock,
            first movim where movim.etbcod = plani.etbcod and
                              movim.placod = plani.placod and
                              movim.movtdc = plani.movtdc and
                              movim.movdat = plani.pladat
                              no-lock
                    :

            if /*plani.movtdc <> 5 or
               plani.desti  = 1  or */
               (plani.biss <= (plani.platot - plani.vlserv))
            then next.

            if plani.biss = ?
            then next.
            find clien where clien.clicod = plani.desti no-lock no-error.
            if not avail clien
            then .

            if (plani.biss - (plani.platot - plani.vlserv)) >= minacr
            then next.
            
            if (plani.biss - (plani.platot - plani.vlserv)) < 2
            then .

            if (acutot + (plani.biss - (plani.platot - plani.vlserv))) > 
               (totacr + minacr) 
            then next.  
            
            create wplani.
            assign wplani.wclicod = plani.desti
                   wplani.wclinom = if avail clien then clien.clinom 
                                        else ""
                   wplani.wven    = if plani.platot > plani.vlserv
                                    then plani.platot - plani.vlserv
                                    else 0.
                   wplani.wacr    = plani.biss - (plani.platot - plani.vlserv).
                   
                   
            acutot = acutot + (plani.biss - (plani.platot - plani.vlserv)).
            
            display plani.pladat
                    acutot column-label "Total"
                        with 1 down centered. pause 0.
                    
             
            if acutot >= totacr
            then do:
                v-sai = yes.
                leave.
            end.
                   
        end.    
        end.
    end.
        
    display vlista no-label with frame f-lista centered no-label.
    choose field vlista with frame f-lista.
    if frame-index = 1
    then indice = "ind-1".
    if frame-index = 2
    then indice = "ind-2". 
    if frame-index = 3
    then indice = "ind-3".
        
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/geral_" + string(time).
    else varquivo = "..\relat\geral" + string(time).

    {mdad_l.i
        &Saida     = "value(varquivo)"
        &Page-Size = "0"
        &Cond-Var  = "130"
        &Page-Line = "66"
        &Nom-Rel   = ""acr_fin""
        &Nom-Sis   = """SISTEMA CONTABIL"""
        &Tit-Rel   = """ACRESCIMO SOBRE A VENDA A PRAZO "" +
                        string(vdti,""99/99/9999"") + "" A "" +
                        string(vdtf,""99/99/9999"") "
        &Width     = "130"
        &Form      = "frame f-cabcab"}
    
    disp with frame f1.
        
    totacr = 0.
        if indice = "ind-1"
        then do:
            for each wplani use-index ind-1:
        
                display wplani.wclicod column-label "Conta"
                        wplani.wclinom column-label "Nome do Cliente"
                        wplani.wven    column-label "Valor!Venda"
                        wplani.wacr    column-label "Valor!Acrescimo"
                        (wplani.wven + wplani.wacr)
                                   column-label "Valor!Total"
                            with frame f-ind1 down width 200.
                    
               totacr = totacr + wplani.wacr.
 
            end.
        end.
        
        if indice = "ind-2"
        then do:
            for each wplani use-index ind-2:
        
                display wplani.wclicod column-label "Conta"
                        wplani.wclinom column-label "Nome do Cliente"
                        wplani.wven    column-label "Valor!Venda"
                        wplani.wacr    column-label "Valor!Acrescimo"
                        (wplani.wven + wplani.wacr)
                                   column-label "Valor!Total"
                            with frame f-ind2 down width 200.
                totacr = totacr + wplani.wacr.    
 
            end.
        end.
        
        if indice = "ind-3"
        then do:
            for each wplani use-index ind-3:
        
                display wplani.wclicod column-label "Conta"
                        wplani.wclinom column-label "Nome do Cliente"
                        wplani.wven    column-label "Valor!Venda"
                        wplani.wacr    column-label "Valor!Acrescimo"
                        (wplani.wven + wplani.wacr)
                                   column-label "Valor!Total"
                            with frame f-ind3 down width 200.
                totacr = totacr + wplani.wacr.    
 
            end.
        end.
        


        put skip(1)
            "Total" at 35
            totacr to 77.
    
 
    output close.

    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:    
        {mrod.i}
    end.    
end.
