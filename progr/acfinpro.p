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

def temp-table wmovim
    field   wprocod  like produ.procod
    field   wpronom  like produ.pronom
    field   wven     like plani.platot
    field   wacr     like plani.platot
    field   wali     as dec
        index ind-1 wpronom
        index ind-2 wprocod
        index ind-3 wven.
 
def temp-table wicms
       field wali as dec
       field wven as dec
       field wacr as dec
       index i1 wali
       .
       
def var dt     like plani.pladat.

form with frame f-ind1.
def var vtotal as dec.
def var totn as dec.
def var tots as dec.
def var vacrn as dec.
def var vacrs as dec.
def var v99 as log.
def var vout as log.
def var vretornar as log.
repeat:

    for each wplani:
        delete wplani.
    end.
    for each wmovim. delete wmovim. end. 

    assign totacr = 0
           minacr = 0
           acutot = 0.

    update totacr label "Total do Acrescimo"
           minacr label "Vlrs.Inferiores a "
                with frame f1 side-label width 80.
        

    update vdti label "Periodo"
           vdtf no-label with frame f1.

    tots = totacr * .30.
    totn = totacr - tots.
    v-sai = no.
    do dt = vdti to vdtf:
        if v-sai = no
        then do:

        for each plani where plani.datexp = dt no-lock:

            if plani.movtdc <> 5 or
               plani.desti  = 1  or
               (plani.biss <= (plani.platot - plani.vlserv))
            then next.

            find clien where clien.clicod = plani.desti no-lock no-error.
            if not avail clien
            then next.

            if (plani.biss - (plani.platot - plani.vlserv)) >= minacr
            then next.
            
            if (plani.biss - (plani.platot - plani.vlserv)) < 2
            then next.

            display plani.pladat
                    plani.biss column-label "Valor" 
                        with 1 down centered. pause 0.
                    
                       
            if (acutot + (plani.biss - (plani.platot - plani.vlserv))) > 
               (totacr + minacr) 
            then next. 
            v99 = no.
            vout = no. 
            vretornar = no.
            for each movim where movim.etbcod = plani.etbcod and
                                 movim.placod = plani.placod and
                                 movim.movtdc = plani.movtdc
                                 no-lock:
                find produ where produ.procod = movim.procod no-lock.
                if produ.pronom = "SALDO"
                then vretornar = yes. 
                if produ.proipiper = 99
                then v99 = yes.
                else vout = yes. 
            end. 
            if vretornar = yes
            then next.
            if vout = yes and
               vacrn >= totn
            then next.
            if v99 = yes and
               vacrs >= tots
            then next.   
            
            for each movim where movim.etbcod = plani.etbcod and
                                 movim.placod = plani.placod and
                                 movim.movtdc = plani.movtdc
                                 no-lock:
                find produ where produ.procod = movim.procod no-lock.

                find first wmovim where
                           wmovim.wprocod = movim.procod no-error.
                if not avail wmovim
                then do:
                    create wmovim.
                    assign
                        wmovim.wprocod = movim.procod 
                        wmovim.wpronom = produ.pronom
                        wmovim.wali = produ.proipiper.
                end.
                wmovim.wven = wmovim.wven +
                        ((plani.platot - plani.vlserv) * 
                        ((movim.movpc * movim.movqtm) /
                        (plani.platot - plani.vlserv)))
                        .
                if wmovim.wali = 99
                then vacrs = vacrs +
                        (((plani.biss) * 
                        ((movim.movpc * movim.movqtm) /
                        (plani.platot - plani.vlserv)))
                        - ((plani.platot - plani.vlserv) * 
                        ((movim.movpc * movim.movqtm) /
                        (plani.platot - plani.vlserv))))
                    .
                else vacrn = vacrn +
                        (((plani.biss) * 
                        ((movim.movpc * movim.movqtm) /
                        (plani.platot - plani.vlserv)))
                        - ((plani.platot - plani.vlserv) * 
                        ((movim.movpc * movim.movqtm) /
                        (plani.platot - plani.vlserv))))
                    .         

                wmovim.wacr = wmovim.wacr + 
                        (((plani.biss) * 
                        ((movim.movpc * movim.movqtm) /
                        (plani.platot - plani.vlserv)))
                        - ((plani.platot - plani.vlserv) * 
                        ((movim.movpc * movim.movqtm) /
                        (plani.platot - plani.vlserv))))
                    .    

            end.
                                 
            create wplani.
            assign wplani.wclicod = clien.clicod
                   wplani.wclinom = clien.clinom
                   wplani.wven    = plani.platot - plani.vlserv
                   wplani.wacr    = plani.biss - (plani.platot - plani.vlserv).
                   
                   
            acutot = acutot + (plani.biss - (plani.platot - plani.vlserv)).
            

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
    then varquivo = "/admcom/relat/acfinpro" + string(time).
    else varquivo = "l:/relat/acfinpro" + string(time).

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

        
        if indice = "ind-1"
        then do:
            vtotal = 0.
            for each wmovim use-index ind-1:
                find first wicms where 
                           wicms.wali = wmovim.wali no-error.
                if not avail wicms
                then do:
                    create wicms.
                    wicms.wali = wmovim.wali.
                end.
                assign
                    wicms.wven = wicms.wven + wmovim.wven
                    wicms.wacr = wicms.wacr + wmovim.wacr
                    .
                vtotal = wmovim.wven + wmovim.wacr.           
                display wmovim.wprocod column-label "Produto"
                        wmovim.wpronom column-label "Descricao"
                        wmovim.wali    column-label "ICMS"
                        wmovim.wven    column-label "Valor!Venda"
                            format ">>,>>>,>>9.99"
                        wmovim.wacr    column-label "Valor!Acrescimo"
                        vtotal(total) column-label "Valor!Total"
                            format ">>,>>>,>>9.99"
                            with frame f-ind1 down width 120.
                down with frame f-ind1.    
 
            end.
        end.
        
        if indice = "ind-2"
        then do:
            vtotal = 0.
            for each wmovim use-index ind-2:
                find first wicms where 
                           wicms.wali = wmovim.wali no-error.
                if not avail wicms
                then do:
                    create wicms.
                    wicms.wali = wmovim.wali.
                end.
                assign
                    wicms.wven = wicms.wven + wmovim.wven
                    wicms.wacr = wicms.wacr + wmovim.wacr
                    .
                vtotal = wmovim.wven + wmovim.wacr.
                display wmovim.wprocod column-label "Produto"
                        wmovim.wpronom column-label "Descricao"
                        wmovim.wali    column-label "ICMS"
                        wmovim.wven    column-label "Valor!Venda"
                        wmovim.wacr    column-label "Valor!Acrescimo"
                        vtotal(total) column-label "Valor!Total"
                            with frame f-ind1 down width 120.
                down with frame f-ind1.    
 
            end.
        end.
        
        if indice = "ind-3"
        then do:
            vtotal = 0.
            for each wmovim use-index ind-3:
                find first wicms where 
                           wicms.wali = wmovim.wali no-error.
                if not avail wicms
                then do:
                    create wicms.
                    wicms.wali = wmovim.wali.
                end.
                assign
                    wicms.wven = wicms.wven + wmovim.wven
                    wicms.wacr = wicms.wacr + wmovim.wacr
                    .

                vtotal = wmovim.wven + wmovim.wacr.
                display wmovim.wprocod column-label "Produto"
                        wmovim.wpronom column-label "Descricao"
                        wmovim.wali    column-label "ICMS"
                        wmovim.wven    column-label "Valor!Venda"
                        wmovim.wacr    column-label "Valor!Acrescimo"
                        vtotal(total) column-label "Valor!Total"
                            with frame f-ind1 down width 120.
              down with frame f-ind1.
            end.
        end.
        
        down(1) with frame f-ind1.
        vtotal = 0.
        /**
        for each wicms use-index i1:
            vtotal = wicms.wven + wicms.wacr.
            display "Totais ICMS" @ wmovim.wpronom column-label "Descricao"
                    wicms.wali    @ wmovim.wali  column-label "ICMS"
                    wicms.wven    @ wmovim.wven  column-label "Valor!Venda"
                    wicms.wacr    @ wmovim.wacr  column-label "Valor!Acrescimo"
                    vtotal(total) column-label "Valor!Total"
                            with frame f-ind1 down width 120.
 
            down with frame f-ind1.
        end.
        **/
        for each wicms use-index i1:
            vtotal = wicms.wven + wicms.wacr.
            display "Totais ICMS" @ wmovim.wpronom column-label "Descricao"
                    wicms.wali    @ wmovim.wali  column-label "ICMS"
                    wicms.wven(total)  column-label "Valor!Venda"
                        format ">>,>>>,>>9.99"
                    wicms.wacr(total)  column-label "Valor!Acrescimo"
                    vtotal(total) column-label "Valor!Total"
                        format ">>,>>>,>>9.99"
                            with frame f-ind2 down width 120.
 
            down with frame f-ind2.
        end.
        /**
        put skip(1)
            "Total.........................." at 35
            totacr to 77.
        **/
    output close.

    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:    
        {mrod.i}
    end.
end.
