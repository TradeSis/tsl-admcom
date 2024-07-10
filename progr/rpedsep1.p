{admcab.i}

def var recimp as recid.

def var fila as char.
def var vreserva like estoq.estatual.
def var vespecial like estoq.estatual.
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
    field modcod like pedid.modcod
    index ipro as primary unique procod modcod
    index nome fabnom pronom.

def buffer bclase for clase.
def var vexcel as log format "Sim/Nao".
def var ped-tipo as char.
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

    do vdata = vdata1 to vdata2 with frame fproces:
        disp vdata label "Data" with frame ff-proc centered . pause 0.
        
        for each pedid where pedid.pedtdc = 3
                         and pedid.sitped = "F"
                         and pedid.peddat = vdata no-lock:
            
            disp pedid.pednum with frame ff-proc centered .
            pause 0.
            
            for each liped where liped.etbcod = pedid.etbcod
                             and liped.pedtdc = pedid.pedtdc
                             and liped.pednum = pedid.pednum no-lock:
                                 
                find produ where produ.procod = liped.procod no-lock no-error.
                if not avail produ
                then next.
                if produ.catcod = 31 or
                   produ.catcod = 35 then.
                else next.
                   
                
                find first tt-pro where tt-pro.procod = liped.procod 
                            and tt-pro.modcod = pedid.modcod
                    no-error.
                if not avail tt-pro
                then do:
                    create tt-pro.
                    assign 
                        tt-pro.procod = liped.procod
                        tt-pro.modcod = pedid.modcod .

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

                assign  
                    tt-pro.lipqtd = tt-pro.lipqtd + liped.lipqtd
                    tt-pro.lipsep = tt-pro.lipsep + liped.lipent 
                    .
                /***    
                if pedid.pednum > 100000
                then tt-pro.autom = tt-pro.autom + liped.lipqtd.
                else tt-pro.manual = tt-pro.manual + liped.lipqtd. 
                ***/                      
                                      
            end. 
        end.
    end.
    vexcel = no.
    message "Arquivo para EXCEL ? " update vexcel.
    disp "Gerando ....." with frame f-procf centered no-box.
    pause 0.
    if vexcel = no
    then do:
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
 
    for each tt-pro where
             tt-pro.lipqtd > tt-pro.lipsep no-lock,
        first produ where produ.procod = tt-pro.procod no-lock,
        first clase where clase.clacod = produ.clacod no-lock,
        first bclase where bclase.clacod = clase.clasup no-lock
            break by bclase.clacod
                  by clase.clacod
                  by tt-pro.modcod :

        if first-of(bclase.clacod)
        then do:
            disp bclase.clacod label "Classe" 
                 bclase.clanom no-label
                 with frame f-clase 1 down no-box side-label.
        end.
        if first-of(clase.clacod)
        then do:
            disp clase.clacod label "Sub-Classe" 
                 clase.clanom no-label
                 with frame f-sclase 1 down no-box side-label.
        end. 
                  
            /*if tt-pro.lipqtd > tt-pro.lipsep 
            then do: */
        do :
                assign  vest = 0 .
                for each estoq where /* (estoq.etbcod >= 900 or
                            {conv_igual.i estoq.etbcod}) and
                                     */  estoq.procod = tt-pro.procod no-lock:

                    /***** antonio *****/
                    /* anterior
                    if estoq.etbcod = 998 or
                       estoq.etbcod = 997 or
                       estoq.etbcod = 994 or
                       estoq.etbcod = 999 or
                       estoq.etbcod = 996
                    then next.
                    if estoq.etbcod < 900 and
                      {conv_difer.i estoq.etbcod} then next.
                    */
                    /* novo igual pesco.p */
                    if (estoq.etbcod < 900 and {conv_igual.i estoq.etbcod})
                       or
                       (estoq.etbcod < 900 and {conv_difer.i estoq.etbcod})
                       or
                       estoq.etbcod >= 900
                    then.
                    else next.
                    if estoq.etbcod = 990 then next.   
                    /**/

                    vest = vest + estoq.estatual.                        
                
                    /** end. **/             
                    /* antonio */
                    if estoq.etbcod = 900
                    then do:
                         assign vespecial = 0
                                vreserva  = 0.
                         do vdata = vdata1  to vdata2 : 
                            for each liped where liped.pedtdc = 3
                                 and liped.procod = tt-pro.procod 
                                 and liped.predt  = vdata
                                 no-lock,
                                 first pedid where 
                                       pedid.etbcod = liped.etbcod and
                                       pedid.pedtdc = liped.pedtdc and
                                       pedid.pednum = liped.pednum :
                     
                                /** antonio **/                   
                                if pedid.sitped <> "E" and pedi.sitped <> "L" 
                                then next.
                                vreserva = vreserva   + liped.lipqtd.
                            end.
                            /* pedido especial */
                            for each liped where liped.pedtdc = 6 
                                 and liped.predt  = vdata
                                 and liped.procod = tt-pro.procod no-lock,
                                 first pedid where 
                                    pedid.etbcod = liped.etbcod and
                                    pedid.pedtdc = liped.pedtdc and
                                    pedid.pednum = liped.pednum and
                                    pedid.pedsit = yes    and
                                    pedid.sitped = "P"
                                 no-lock.
                
                                vespecial = vespecial + liped.lipqtd.
             
                            end.
                        end.
                        if (estoq.estatual - vespecial) < 0
                        then vespecial = 0.
                                     
                        vreserva = vreserva + vespecial .

                    end. /* estab = 900 /
                end. /* bloco estoq. */ 
                /* antonio */
                /*
                if (vest - vreserva) > 0 then next.
                */

                ped-tipo = "".
                if tt-pro.modcod = "PEDA"
                then ped-tipo = "Automatico".
                else if tt-pro.modcod = "PEDM"
                then ped-tipo = "Manual".
                else if tt-pro.modcod = "PEDR"
                then ped-tipo = "Reposicao".
                else if tt-pro.modcod = "PEDE"
                then ped-tipo = "Especial".
                else if tt-pro.modcod = "PEDP"
                   then ped-tipo = "Pendente".
                   else if tt-pro.modcod = "PEDO"
                       then ped-tipo = "Outra Filial".
                       else if tt-pro.modcod = "PEDF"
                          then ped-tipo = "Entrega Futura".
                          else if tt-pro.modcod = "PEDC"
                            then ped-tipo = "Comercial".
                            else if tt-pro.modcod = "PEDI"
                              then ped-tipo = "Ajuste Minimo".
                              else if tt-pro.modcod = "PEDX"
                                then ped-tipo = "Ajuste Mix".
 
 
                display tt-pro.procod column-label "Produto"
                        tt-pro.pronom  
                             column-label "Descricao" format "x(40)"
                        tt-pro.fabnom
                             column-label "Fabricante" format "x(20)"
                        tt-pro.lipqtd    column-label "Qtde!Pedida"   
                             (total by bclase.clacod by clase.clacod)
                        tt-pro.lipsep   column-label "Qtde!Separada" 
                             (total by bclase.clacod by clase.clacod)
                        (tt-pro.lipqtd - tt-pro.lipsep) column-label "Faltou" 
                             (total by bclase.clacod by clase.clacod)
                        vest column-label "Est.!Dep " format "->>>>>>9"
                       (vest - vreserva) column-label "Est.!Disp. "
                                      format "->>>>>>9"
                        ped-tipo format "x(15)" no-label
                       /*               
                         tt-pro.autom column-label  "Pedido!Autom." (total)
                         tt-pro.manual column-label "Pedido!Manual"  (total)                          */
                            with frame f-pro width 145 down.
            end.
            /**
            if last-of(bclase.clacod)
            then do:
                put fill("=",120) format "x(120)" skip.
            end.
            **/
            if last-of(clase.clacod)
            then do:
                put skip(2).
            end.
        end.
     
    output close.
    
    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}
    end.    
    
    end.
    else do:
    varquivo = varquivo + ".csv".
    output to value(varquivo) page-size 0.
    for each tt-pro where
             tt-pro.lipqtd > tt-pro.lipsep no-lock,
        first produ where produ.procod = tt-pro.procod no-lock,
        first clase where clase.clacod = produ.clacod no-lock,
        first bclase where bclase.clacod = clase.clasup no-lock
            break by bclase.clacod
                  by clase.clacod
                  by tt-pro.modcod :

    
                vest = 0.
                for each estoq where /* (estoq.etbcod >= 900 or
                    {conv_igual.i estoq.etbcod}) and
                                     */  estoq.procod = tt-pro.procod no-lock:

                    /* Antonio novo igual pesco.p */
                    if (estoq.etbcod < 900 and {conv_igual.i estoq.etbcod})
                       or
                       (estoq.etbcod < 900 and {conv_difer.i estoq.etbcod})
                       or
                       estoq.etbcod >= 900
                    then.
                    else next.
                    if estoq.etbcod = 990 then next.   
                    /**/

                    vest = vest + estoq.estatual.                        
                
                    /* antonio */
                    if estoq.etbcod = 900
                    then do:
                         assign vespecial = 0
                                vreserva  = 0.
                         do vdata = vdata1  to vdata2 : 
                            for each liped where liped.pedtdc = 3
                                 and liped.procod = tt-pro.procod 
                                 and liped.predt  = vdata
                                 no-lock,
                                 first pedid where 
                                       pedid.etbcod = liped.etbcod and
                                       pedid.pedtdc = liped.pedtdc and
                                       pedid.pednum = liped.pednum :
                     
                                /** antonio **/                   
                                if pedid.sitped <> "E" and pedi.sitped <> "L" 
                                then next.
                                vreserva = vreserva   + liped.lipqtd.
                            end.
                            /* pedido especial */
                            for each liped where liped.pedtdc = 6 
                                 and liped.predt  = vdata
                                 and liped.procod = tt-pro.procod no-lock,
                                 first pedid where 
                                    pedid.etbcod = liped.etbcod and
                                    pedid.pedtdc = liped.pedtdc and
                                    pedid.pednum = liped.pednum and
                                    pedid.pedsit = yes    and
                                    pedid.sitped = "P"
                                 no-lock.
                
                                vespecial = vespecial + liped.lipqtd.
             
                            end.
                        end.
                        if (estoq.estatual - vespecial) < 0
                        then vespecial = 0.
                                     
                        vreserva = vreserva + vespecial .

                    end. /* estab = 900 */
                end. /* bloco estoq. */ 

                ped-tipo = "".
                if tt-pro.modcod = "PEDA"
                then ped-tipo = "Automatico".
                else if tt-pro.modcod = "PEDM"
                then ped-tipo = "Manual".
                else if tt-pro.modcod = "PEDR"
                then ped-tipo = "Reposicao".
                else if tt-pro.modcod = "PEDE"
                then ped-tipo = "Especial".
                else if tt-pro.modcod = "PEDP"
                   then ped-tipo = "Pendente".
                   else if tt-pro.modcod = "PEDO"
                       then ped-tipo = "Outra Filial".
                       else if tt-pro.modcod = "PEDF"
                          then ped-tipo = "Entrega Futura".
                          else if tt-pro.modcod = "PEDC"
                            then ped-tipo = "Comercial".
                            else if tt-pro.modcod = "PEDI"
                              then ped-tipo = "Ajuste Minimo".
                              else if tt-pro.modcod = "PEDX"
                                then ped-tipo = "Ajuste Mix".
 
 
                put bclase.clacod ";"
                    bclase.clanom ";"
                    clase.clacod  ";"
                    clase.clanom  ";"
                    tt-pro.procod ";"
                    tt-pro.pronom ";" 
                    tt-pro.fabnom ";"
                    tt-pro.lipqtd ";"
                    tt-pro.lipsep ";"
                   (tt-pro.lipqtd - tt-pro.lipsep) ";"
                    vest ";"
                   (vest - vreserva) ";"
                    ped-tipo format "x(15)" 
                    skip.
    end.
    output close.
    message color red/with
    "Arquyivo gerado: " skip
    varquivo
    view-as alert-box.
    end.
end.
