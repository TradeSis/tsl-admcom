{admcab.i}

def var v-comando as char.
def var varq-bat as char.
def var vcatcod like categoria.catcod.
def var varquivo-clasite as char.
def var vpreco like estoq.estcusto.
def var varquivo-fab as char. 
def var varquivo-cla as char.
def var varquivo-pro as char.
def var vest-minimo as dec.
def var dpreco as char.
def var vaspas as char. 
def var vestatual like estoq.estatual.
 
vaspas = chr(34).

message "Confirma a exportacao dos arquivos para o site?" update sresp.
if not sresp 
then leave.
    /* Exportacao arquivo de Fabricantes */

    if opsys = "UNIX"
    then varquivo-fab = "/admcom/arq-site/fabricante_" 
                      + string(year(today),"9999")
                      + "_" + string(month(today),"99") 
                      + "_" +  string(day(today),"99") 
                      + ".csv".
    else varquivo-fab = "l:\arq-site\fabricante_"                      
                      + string(year(today),"9999")
                      + "_" + string(month(today),"99") 
                      + "_" +  string(day(today),"99") 
                      + ".csv".

    message "Exportando Fabricantes ...". pause 2 no-message.

    unix silent value("umask 000;touch " + varquivo-fab).
    
    output to value(varquivo-fab).

        for each fabri no-lock:

            put unformatted
                vaspas fabri.fabcod vaspas ","
                vaspas fabri.fabnom format "x(40)" vaspas ","
                vaspas " " vaspas skip.
                
        end.

    output close.

    /* Exportacao arquivo (Categoria) */
    if opsys = "UNIX"
    then varquivo-cla = "/admcom/arq-site/categoria_"  
                      + string(year(today),"9999") 
                      + "_" + string(month(today),"99") 
                      + "_" +  string(day(today),"99") 
                      + ".csv".
    else varquivo-cla = "l:\arq-site\categoria_"  
                      + string(year(today),"9999") 
                      + "_" + string(month(today),"99") 
                      + "_" +  string(day(today),"99") 
                      + ".csv".

    
    message "Exportando (Categorias) ...". pause 2 no-message.
    
    unix silent value("umask 000;touch " + varquivo-cla).

    output to value(varquivo-cla).

        for each clasite no-lock break by clasite.clacod:
            
            find clase where 
                 clase.clacod = clasite.claerp no-lock no-error.
            if not avail clase
            then next.

            
            /**********
            find last produ where 
                       produ.clacod = clase.clacod and
                       (produ.catcod = 31 or produ.catcod = 41)
                       no-lock no-error.
            if not avail produ
            then next.
            
            find categoria where 
                 categoria.catcod = produ.catcod no-lock no-error.
            if not avail categoria
            then next.
            
            vcatcod = 0.
            vcatcod = categoria.catcod.
            
            if vcatcod = 45
            then vcatcod = 41.
            
            if vcatcod = 35
            then vcatcod = 31.
            
            *********/
            
            if clasite.claordem = yes
            then vcatcod = 31.
            else vcatcod = 41.


            if first-of(clasite.clacod)
            then
                put unformatted
                    vaspas clasite.clacod                  vaspas ","
                    vaspas clasite.clanom   format "x(40)" vaspas ","
                    vaspas clasite.clasup                  vaspas ","
                    vaspas vcatcod                         vaspas skip.

        end.

    output close.

    /* Exportando arquivo de Produtos */

    if opsys = "UNIX"
    then varquivo-pro = "/admcom/arq-site/produto_" 
                      + string(year(today),"9999") 
                      + "_" + string(month(today),"99") 
                      + "_" +  string(day(today),"99") 
                      + ".csv".
    else varquivo-pro = "l:\arq-site\produto_" 
                      + string(year(today),"9999") 
                      + "_" + string(month(today),"99") 
                      + "_" +  string(day(today),"99") 
                      + ".csv".

    message "Exportando Produtos ...". pause 2 no-message.

    if opsys = "UNIX"
    then varq-bat = "/admcom/arq-site/bat/cop_img_"
                  + string(year(today),"9999")
                  + string(month(today),"99")
                  + string(day(today),"99")
                  + "_"
                  + string(time).
                  
                  /*+ ".bat".*/
    else varq-bat = "L:\arq-site\bat\cop_img_"
                  + string(year(today),"9999")
                  + string(month(today),"99")
                  + string(day(today),"99")
                  + "_"
                  + string(time)
                  + ".bat".
    
    unix silent value("umask 000;touch " + varquivo-pro).
    
    output to value(varquivo-pro).
    
        for each prodsite where prodsite.exportar = yes no-lock:
    
            
            find produ where produ.procod = prodsite.procod no-lock no-error.
            if not avail produ
            then next.

            find first clasite where 
                       clasite.claerp = produ.clacod no-lock no-error.
            if not avail clasite
            then next.
            
            run ve-est.
            
            find first estoq where 
                       estoq.etbcod <> 1 and 
                       estoq.procod = produ.procod no-lock no-error.
            if avail estoq
            then do:
                vpreco = estoq.estvenda.

                if estoq.estprodat >= today
                then if estoq.estproper > 0
                     then vpreco = estoq.estproper.
            end.
            dpreco = string(vpreco).
            /*
            if (produ.clacod <> 56 and
               produ.clacod <> 35 and
               produ.clacod <> 16) or
               produ.proipival = 0
            then*/ do:
                vest-minimo = 50.
            
                if prodsite.cd1 > 0
                then vest-minimo = prodsite.cd1.
                else if clasite.claper > 0
                    then vest-minimo = clasite.claper.
            end.
            /*else vest-minimo = 0.
            */     
            if /*not avail estoq or*/
               vestatual < vest-minimo
            then dpreco = "PRODUTO ESGOTADO".     
            assign vcatcod = 0 
                   vcatcod = produ.catcod.

            if vcatcod = 45
            then vcatcod = 41.
            
            if vcatcod = 35
            then vcatcod = 31.
            
            put unformatted
                vaspas prodsite.procod             vaspas ","
                vaspas /*produ.pronom*/ prodsite.cc1 format "x(50)" vaspas ","
                vaspas prodsite.visivel            vaspas ","
                vaspas produ.corcod                vaspas ","
                vaspas produ.prounven              vaspas ","
                vaspas /* especificacao */         vaspas ","
                vaspas /* peso */                  vaspas ","
                vaspas /* obs */                   vaspas ","
                vaspas clasite.clacod              vaspas ","
              /*vaspas vpreco format ">>,>>9.99"   vaspas ","*/
                vaspas dpreco format "x(16)"       vaspas ","  
                vaspas produ.fabcod                vaspas ","
                vaspas vcatcod                     vaspas ","
                vaspas prodsite.ci1       format ">>>9" vaspas skip.
        
        end.

    output close.

    unix silent value("umask 000;touch " + varq-bat).
    
    output to value(varq-bat).
   
        put "echo off" skip.
        put "cd L:~\site~\img~\" skip.
        
        for each prodsite where prodsite.exportar = yes no-lock:
    
            find produ where produ.procod = prodsite.procod no-lock no-error.
            if not avail produ
            then next.

            find first clasite where 
                       clasite.claerp = produ.clacod no-lock no-error.
            if not avail clasite
            then next.
                                                    
            put unformatted 
                "copy " 
                string(prodsite.procod) 
                ".jpg " 
                "L:~\arq-site~\Imagens" 
                skip.

        end.

        put "exit" skip.        
        
    output close.

    if opsys = "UNIX"
    then do:
    
        for each prodsite where prodsite.exportar = yes no-lock:
    
            find produ where produ.procod = prodsite.procod no-lock no-error.
            if not avail produ
            then next.

            find first clasite where 
                       clasite.claerp = produ.clacod no-lock no-error.
            if not avail clasite
            then next.
                                                    
            v-comando = "".
            v-comando = "cp /admcom/site/img/" + string(prodsite.procod)
                      + ".jpg  /admcom/arq-site/Imagens/".

            os-command silent value(v-comando).
            
            v-comando = "".
            v-comando = "cp /admcom/site/img/" + string(prodsite.procod)
                      + ".JPG  /admcom/arq-site/Imagens/".

            os-command silent value(v-comando).
            
            
        end.

    end.
    else do:
        
        os-command silent value(varq-bat).

    end.
    
    disp skip(1)
         varquivo-pro format "x(48)"     label "Produtos..............."
         varquivo-cla format "x(48)"     label "Categorias............."
         varquivo-fab format "x(48)"     label "Fabricantes............"
         skip(1)
         with centered row 8 side-labels.

    pause.





procedure ve-est:
    vestatual = 0.
    for each estab no-lock:

        find estoq where estoq.etbcod = estab.etbcod and
                         estoq.procod = produ.procod no-lock no-error.
        if not avail estoq
        then next.
        
        if estab.etbcod = 93
        then do:                         
            
            for each liped where liped.pedtdc = 3
                             and liped.procod = produ.procod no-lock:
                                         
                /**find first pedid use-index pedid2 
                           where pedid.pedtdc = liped.pedtdc and
                                 pedid.etbcod = liped.etbcod 
                                 no-lock no-error.**/
                find pedid where pedid.etbcod = liped.etbcod and
                                 pedid.pedtdc = liped.pedtdc and
                                 pedid.pednum = liped.pednum no-lock no-error.
                                 
                                 
                if not avail pedid 
                then next.

                if pedid.sitped <> "E" and
                   pedid.sitped <> "L"
                then next.
                
                vestatual = vestatual - liped.lipqtd.
            
            end.
            
            /*for each liped where liped.pedtdc = 3 and
                                 liped.procod = produ.procod and
                                 liped.lipsit = "A" no-lock.
                            
                find pedid where pedid.etbcod = liped.etbcod and
                                 pedid.pedtdc = liped.pedtdc and
                                 pedid.pednum = liped.pednum no-lock no-error.
                if not avail pedid 
                then next.
                                                
                            
                if pedid.sitped = "R"
                then next.
                            
                vestatual = vestatual - liped.lipqtd.            
                                                
            end.
            */
        end.               
         
        vestatual = vestatual + estoq.estatual.
    end.
end procedure.
