{admcab.i}

def var recimp as recid.

def var fila as char.
def var vreserva like estoq.estatual.
def var varquivo as char.
def var vdata as date format "99/99/9999".
def var vdata1 as date format "99/99/9999".
def var vdata2 as date format "99/99/9999".
def var vest like estoq.estatual.
def temp-table tt-pro
    field procod like produ.procod
    field pronom like produ.pronom
    field fabcod like fabri.fabcod
    field fabnom like fabri.fabnom
    field lipqtd as   integer format "->>>,>>9"
    field lipsep as   integer format "->>>,>>9"
    field manual as   integer format "->>>,>>9"
    field autom  as   integer format "->>>,>>9"
    index ipro as primary unique procod
    index nome fabnom pronom.

repeat:

    for each tt-pro: 
        delete tt-pro. 
    end.
    
    assign vdata1 = today - 1
           vdata2 = today - 1.
           
    update vdata1 label "Data Inicial"
           vdata2 label "Data Final"
           with frame f-dados side-labels width 80.

    if opsys = "unix" 
    then do: 
        varquivo = "/admcom/relat/rpedsep" + string(time).
        find first impress where impress.codimp = setbcod no-lock no-error. 
        if avail impress
        then do:
            run acha_imp.p (input recid(impress), 
                            output recimp).
            find impress where recid(impress) = recimp no-lock no-error.
            assign fila = string(impress.dfimp). 
        end.    
    end.
    else assign fila = ""
                varquivo = "l:\relat\rpedsep" + string(time).

    do vdata = vdata1 to vdata2:
        disp vdata with 1 down centered. pause 0.
        
        for each pedid where pedid.pedtdc = 3
                         and (pedid.sitped = "R" or pedid.sitped = "F")
                         and pedid.peddat = vdata no-lock:
            
            disp pedid.pednum with 1 down centered. pause 0.
            
            for each liped where liped.etbcod = pedid.etbcod
                             and liped.pedtdc = pedid.pedtdc
                             and liped.pednum = pedid.pednum no-lock:
                                 
                find produ where produ.procod = liped.procod no-lock no-error.
                if not avail produ
                then next.
                if produ.catcod = 31 or
                   produ.catcod = 35
                then.
                else next.
                   
                
                find tt-pro where tt-pro.procod = liped.procod no-error.
                if not avail tt-pro
                then do:
                    create tt-pro.
                    assign tt-pro.procod = liped.procod.

                    find produ where 
                         produ.procod = liped.procod no-lock no-error.
                    if avail produ 
                    then 
                        /*find fabri where 
                             fabri.fabcod = produ.fabcod no-lock no-error.*/
                          find forne where
                             forne.forcod = produ.fabcod no-lock no-error.
                
                    assign tt-pro.pronom = (if avail produ
                                            then produ.pronom
                                            else "").
                                            
                           tt-pro.fabcod = (if avail /*fabri*/ forne
                                            then /*fabri.fabcod*/
                                                 forne.forcod
                                            else 0).

                           tt-pro.fabnom = (if avail /*fabri*/ forne
                                            then forne.forfant 
                                            /*fabri.fabfant*/
                                            else "").
                 
                end.

                
                assign  tt-pro.lipqtd = tt-pro.lipqtd + liped.lipqtd
                        tt-pro.lipsep = tt-pro.lipsep + liped.lipent 
                                                             /***sep***/.
                if pedid.pednum > 100000
                then tt-pro.autom = tt-pro.autom + liped.lipqtd.
                else tt-pro.manual = tt-pro.manual + liped.lipqtd.                       
                
            end. 
            
        end.
        
    end.
 
def work-table tt-sitped 
    field sitped as char.
create tt-sitped.
assign tt-sitped.sitped = "E".    
/*
create tt-sitped.
assign tt-sitped.sitped = "L".    

create tt-sitped.
assign tt-sitped.sitped = "F".    
*/

    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "00 "
        &Cond-Var  = "130"
        &Page-Line = "00"
        &Nom-Rel   = ""RPEDSEP""
        &Nom-Sis   = """SISTEMA DE ESTOQUE"""
        &Tit-Rel   = """RELATORIO DE PRODUTOS FALTANTES -""
                        + "" PERIODO DE "" +
                         string(vdata1,""99/99/9999"") + "" A "" +
                         string(vdata2,""99/99/9999"") "
        &Width     = "135"
        &Form      = "frame f-cabcab"}
 
        for each tt-pro no-lock  /*
                    break by tt-pro.fabnom
                          by tt-pro.pronom */:

            if tt-pro.lipqtd > tt-pro.lipsep 
            then do:
    
                vest = 0.
                for each estoq where /* (estoq.etbcod >= 900 or
                            {conv_igual.i estoq.etbcod}) and
                                   */  estoq.procod = tt-pro.procod no-lock:

                    if estoq.etbcod = 998 or
                       estoq.etbcod = 997 or
                       estoq.etbcod = 994 or
                       estoq.etbcod = 999 or
                       estoq.etbcod = 996
                    then next.

                    if estoq.etbcod < 900 and
                      {conv_difer.i estoq.etbcod} then next.

                    vest = vest + estoq.estatual.                        
                end.             
                
                vreserva = 0.
                for each liped where liped.pedtdc = 3
                                 and liped.procod = tt-pro.procod no-lock,
                  /*  find */ 
                     first pedid where pedid.etbcod = liped.etbcod and
                                       pedid.pedtdc = liped.pedtdc and
                                       pedid.pednum = liped.pednum no-lock,
                                     /* no-error.*/
                     first tt-sitped where tt-sitped.sitped = pedid.sitped 
                            no-lock.             
      /*
                    if not avail pedid 
                    then next.

                    if pedid.sitped <> "E" and
                       pedid.sitped <> "L" and 
                       pedid.sitped <> "F"
                    then next.
                                          /*
                    if pedid.sitped <> "F"
                    then next.              */
                */
                    vreserva = vreserva + liped.lipqtd.
            
                end.
                
                if (vest - vreserva) > 0 then next.
                
                display tt-pro.procod column-label "Produto"
                        tt-pro.pronom  
                             column-label "Descricao" format "x(40)"
                        tt-pro.fabnom
                             column-label "Fabricante" format "x(20)"
                        tt-pro.lipqtd   
                             column-label "Qtde!Pedida"   (total)
                        tt-pro.lipsep   column-label "Qtde!Separada" (total)
                        (tt-pro.lipqtd - tt-pro.lipsep) column-label "Faltou" 
                                                (total)
                        vest column-label "Est.!Dep " format "->>>>>>9"
                       (vest - vreserva) column-label "Est.!Disp. "
                                      format "->>>>>>9"
                         tt-pro.autom column-label  "Pedido!Autom." (total)
                         tt-pro.manual column-label "Pedido!Manual"  (total)        
                            with frame f-pro width 145 down.
            end.
        end.
     
    output close.
    
    
    if opsys = "UNIX"
    then do:
        sresp = no.
        message "Deseja imprimir relatorio" update sresp.
        if sresp
        then os-command silent lpr value(fila + " " + varquivo).
        else run visurel.p(varquivo,"").
        
    end.
    else do:
        {mrod.i}
    end.    
    
end.
