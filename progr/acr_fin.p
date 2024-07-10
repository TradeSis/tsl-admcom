{admcab.i}
def var indice as char.
def var vlista  as char format "x(10)" extent 3 
        initial ["Alfabetica","   Conta  ","Valor"].
        
def var aux-acr  as dec.
def var totacr  like plani.platot.
def var acutot  like plani.platot.
def var minacr  like plani.platot.
def var varquivo as char format "x(30)".
def var vdti     like plani.pladat.
def var vdtf     like plani.pladat.
def var v-sai    as log. 
def var vsubst   as log.
def var vtot30   like plani.platot.
def var vtot70   like plani.platot.
def var vtotsubs like plani.platot.
def var vnormal  like plani.platot.

def var vlst   as char.
def temp-table tt-x
    field placod like plani.placod
    field etbcod as int
    field lst as char
     field normal as dec
     field subst as dec
     field acr as dec
     field log  as log
     index ix is primary unique etbcod placod.
 


def temp-table wplani
    field   wclicod  like clien.clicod
    field   wclinom  like clien.clinom
    field   wven     like plani.platot
    field   wacr     like plani.platot
    field   subst    as log 
        index ind-1 subst wclinom
        index ind-2 subst wclicod
        index ind-3 subst wven.
       
def var dt     like plani.pladat.

repeat:

    for each wplani:
        delete wplani.
    end.
    for each tt-x: delete tt-x. end.

    assign totacr = 0
           minacr = 0
           acutot = 0
           vtotsubs = 0
           vnormal = 0
           v-sai = no.

    update totacr label "Total do Acrescimo"
           minacr label "Vlrs.Inferiores a "
                with frame f1 side-label width 80.

    update vdti label "Periodo"
           vdtf no-label with frame f1.

    assign vtot30 = totacr * 0.30
           vtot70 = totacr * 0.70.

    v-sai = no.
    do dt = vdti to vdtf:
      
        display dt with 1 down centered. pause 0.
              
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

/******
            display plani.pladat
                    plani.biss column-label "Valor"  
              /*      (plani.biss - (plani.platot - plani.vlserv))
                                  column-label "Acr"
                        acutot vnormal vtotsubs     ***/     
                        with 1 down centered. pause 0.
                  ****/ 
                       
            if (acutot + (plani.biss - (plani.platot - plani.vlserv))) > 
               (totacr + minacr ) 
            then next. 
             
            vsubst = no.
            vlst = "".
            for each movim where movim.etbcod = plani.etbcod
                             and movim.placod = plani.placod no-lock.
                             
                 if movim.MovAlICMS <> 17.00 
                 then assign vsubst = yes.

                 vlst = vlst + string(movim.procod) + ",".
                 
             end.

            aux-acr = (plani.biss - (plani.platot - plani.vlserv)).
             
            if vsubst = yes
            then do:
                  if (vtotsubs + aux-acr) > vtot30
                  then aux-acr = vtot30 - vtotsubs.
                  
                  if aux-acr <= 0 then next. 

                  vtotsubs  = vtotsubs + aux-acr.

            end.                 
            else do:

                  if (vnormal + aux-acr) > vtot70
                  then aux-acr = vtot70 - vnormal.
                  
                  if aux-acr <= 0 then next. 

                  vnormal = vnormal + aux-acr.
                  
            end. 
     /****
            create tt-x.
            assign tt-x.placod = plani.placod
                   tt-x.etbcod = plani.etbcod
                   tt-x.lst = vlst.
            if vsubst = no      
           then tt-x.normal = (plani.biss - (plani.platot - plani.vlserv)).
            else tt-x.subst = (plani.biss - (plani.platot - plani.vlserv)).
            tt-x.log = vsubst .
            tt-x.acr = plani.biss - (plani.platot - plani.vlserv).
       ***/     
            
            create wplani.
            assign wplani.wclicod = clien.clicod
                   wplani.wclinom = clien.clinom
                   wplani.wven    = plani.platot - plani.vlserv
                   wplani.wacr    =  aux-acr
                        /* plani.biss - (plani.platot - plani.vlserv) */
                        
                   wplani.subst   = vsubst.
                   
                   
            acutot = acutot + aux-acr.
                 /* (plani.biss - (plani.platot - plani.vlserv)). */ .
            
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
    then varquivo = "../relat/acr_fin" + string(time).
    else varquivo = "..\relat\acr_fin" + string(time).
 
/*     {mdad.i  */

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

   /*******
         display     acutot vnormal vtotsubs .         
       def var v-i as int. 
       for each tt-x no-lock:
             disp tt-x.etbcod tt-x.placod format ">>>>>>>>>>>9"
                 tt-x.acr (total)
                 tt-x.normal (total)
                     tt-x.subs (total) tt-x.log.
       /*    repeat v-i = 1 to num-entries(tt-x.lst):
                 find produ where produ.procod = int(entry(v-i,tt-x.lst))
                             no-lock no-error.
                 if not avail produ then next.
                 disp produ.procod produ.pronom format "x(30)".            
                 
           end.    
           */
       end.
            ****/
        
        if indice = "ind-1"
        then do:
            for each wplani use-index ind-1
                    break by wplani.subst
                          by wplani.wclinom :
        
                display wplani.wclicod column-label "Conta"
                        wplani.wclinom column-label "Nome do Cliente"
                        wplani.wven    column-label "Valor!Venda"
                        wplani.wacr    column-label "Valor!Acrescimo"
                                         (total by wplani.subst)
                        (wplani.wven + wplani.wacr)
                                   column-label "Valor!Total"
                            with frame f-ind1 down width 200.
                    
 
            end.
        end.
        
        if indice = "ind-2"
        then do:
             for each wplani use-index ind-2
                             break by wplani.subst
                                   by wplani.wclicod  
                      :
        
                display wplani.wclicod column-label "Conta"
                        wplani.wclinom column-label "Nome do Cliente"
                        wplani.wven    column-label "Valor!Venda"
                        wplani.wacr    column-label "Valor!Acrescimo"
                                 (total by wplani.subst)
                        (wplani.wven + wplani.wacr)
                                   column-label "Valor!Total"
                            with frame f-ind2 down width 200.
                    
 
            end.
        end.
        
        if indice = "ind-3"
        then do:
            for each wplani use-index ind-3
                      break by wplani.subst
                            by wplani.wven:
        
                display wplani.wclicod column-label "Conta"
                        wplani.wclinom column-label "Nome do Cliente"
                        wplani.wven    column-label "Valor!Venda"
                        wplani.wacr    column-label "Valor!Acrescimo"
                              (total by wplani.subst)
                        (wplani.wven + wplani.wacr)
                                   column-label "Valor!Total"
                            with frame f-ind3 down width 200.
                    
 
            end.
        end.
        


        put skip(1)
            "Total.........................." at 35
            totacr to 77 skip(2).
    
 
    output close.

   if opsys = "UNIX"
   then  run visurel.p(input varquivo, input "").
   else do:
    {mrod.i}
    end.
end.
