def var venda as char.
def var vpedtipo as char format "x(15)".
def var varquivo as char.
varquivo = "/admcom/relat/pedido-transferencia-" +
            string(today,"99999999") + "." + string(time)
            .
output to value(varquivo).
 
put "Loja;Data Pedido;Numero Pedido;Tipo Pedido;Produto;Descrição;Quantidade;NF Venda" skip.

for each estab no-lock:
    for each pedid where
             pedid.pedtdc = 3 and
             pedid.etbcod = estab.etbcod and
             pedid.peddat >= today - 90 and
             pedid.sitped <> "R" and
             pedid.sitped <> "F" and
             pedid.sitped <> "C" no-lock,
        each liped of pedid where
            liped.lipsit <> "R" and
            liped.lipsit <> "F" and
            liped.lipsit <> "C" 
            no-lock,
        first produ where produ.procod = liped.procod no-lock
         :
    
        if pedid.modcod = "PEDA"
        then vpedtipo = "Automatico".
        else if pedid.modcod = "PEDM"
        then vpedtipo = "Manual".
        else if pedid.modcod = "PEDR"
        then vpedtipo = "Reposicao".
        else if pedid.modcod = "PEDE"
        then vpedtipo = "Especial".
        else if pedid.modcod = "PEDP"
        then vpedtipo = "Pendente".
        else if pedid.modcod = "PEDO"
        then vpedtipo = "Outra Filial".
        else if pedid.modcod = "PEDF"
        then vpedtipo = "Entrega Futura".
        else if pedid.modcod = "PEDC"
        then vpedtipo = "Comercial".
        else if pedid.modcod = "PEDI"
        then vpedtipo = "Ajuste Minimo".
        else if pedid.modcod = "PEDX"
        then vpedtipo = "Ajuste Mix".
        else if pedid.modcod = "PAEI"
        then vpedtipo = "PAEI".
        else if pedid.modcod = "VEXM"
        then vpedtipo = "VEX Moda".
        else vpedtipo = pedid.modcod
                                .

        venda = "".
        if liped.venda-placod <> ?
        then do:
            find plani where plani.etbcod = liped.etbcod and
                         plani.placod = liped.venda-placod
                         no-lock no-error.
            if avail plani 
            then venda = string(plani.numero).
        end.              
        put unformatted
         pedid.etbcod
         ";"
         pedid.peddat
         ";"
         pedid.pednum
         ";"
         vpedtipo
         ";"
         liped.procod
         ";"
         produ.pronom
         ";"
         liped.lipqtd
         ";"
         venda
         skip.

    end.
    for each pedid where
             pedid.pedtdc = 6 and
             pedid.etbcod = estab.etbcod and
             pedid.peddat >= today - 90 and
             pedid.sitped <> "R" and
             pedid.sitped <> "F" and
             pedid.sitped <> "C" no-lock,
        each liped of pedid where
            liped.lipsit <> "R" and
            liped.lipsit <> "F" and
            liped.lipsit <> "C" 
            no-lock,
        first produ where produ.procod = liped.procod no-lock
         :
    
        if pedid.modcod = "PEDA"
        then vpedtipo = "Automatico".
        else if pedid.modcod = "PEDM"
        then vpedtipo = "Manual".
        else if pedid.modcod = "PEDR"
        then vpedtipo = "Reposicao".
        else if pedid.modcod = "PEDE"
        then vpedtipo = "Especial".
        else if pedid.modcod = "PEDP"
        then vpedtipo = "Pendente".
        else if pedid.modcod = "PEDO"
        then vpedtipo = "Outra Filial".
        else if pedid.modcod = "PEDF"
        then vpedtipo = "Entrega Futura".
        else if pedid.modcod = "PEDC"
        then vpedtipo = "Comercial".
        else if pedid.modcod = "PEDI"
        then vpedtipo = "Ajuste Minimo".
        else if pedid.modcod = "PEDX"
        then vpedtipo = "Ajuste Mix".
        else if pedid.modcod = "PAEI"
        then vpedtipo = "PAEI".
        else if pedid.modcod = "VEXM"
        then vpedtipo = "VEX Moda".
        else vpedtipo = pedid.modcod
                                .

        venda = "".
        if liped.venda-placod <> ?
        then do:
            find plani where plani.etbcod = liped.etbcod and
                         plani.placod = liped.venda-placod
                         no-lock no-error.
            if avail plani 
            then venda = string(plani.numero).
        end.              
        put unformatted
         pedid.etbcod
         ";"
         pedid.peddat
         ";"
         pedid.pednum
         ";"
         vpedtipo
         ";"
         liped.procod
         ";"
         produ.pronom
         ";"
         liped.lipqtd
         ";"
         venda
         skip.

    end.
    for each pedid where
             pedid.pedtdc = 95 and
             pedid.etbcod = estab.etbcod and
             pedid.peddat >= today - 90 and
             pedid.sitped <> "R" and
             pedid.sitped <> "F" and
             pedid.sitped <> "C" no-lock,
        each liped of pedid where
            liped.lipsit <> "R" and
            liped.lipsit <> "F" and
            liped.lipsit <> "C" 
            no-lock,
        first produ where produ.procod = liped.procod no-lock
         :
    
        if pedid.modcod = "PEDA"
        then vpedtipo = "Automatico".
        else if pedid.modcod = "PEDM"
        then vpedtipo = "Manual".
        else if pedid.modcod = "PEDR"
        then vpedtipo = "Reposicao".
        else if pedid.modcod = "PEDE"
        then vpedtipo = "Especial".
        else if pedid.modcod = "PEDP"
        then vpedtipo = "Pendente".
        else if pedid.modcod = "PEDO"
        then vpedtipo = "Outra Filial".
        else if pedid.modcod = "PEDF"
        then vpedtipo = "Entrega Futura".
        else if pedid.modcod = "PEDC"
        then vpedtipo = "Comercial".
        else if pedid.modcod = "PEDI"
        then vpedtipo = "Ajuste Minimo".
        else if pedid.modcod = "PEDX"
        then vpedtipo = "Ajuste Mix".
        else if pedid.modcod = "PAEI"
        then vpedtipo = "PAEI".
        else if pedid.modcod = "VEXM"
        then vpedtipo = "VEX Moda".
        else vpedtipo = pedid.modcod
                                .

        venda = "".
        if liped.venda-placod <> ?
        then do:
            find plani where plani.etbcod = liped.etbcod and
                         plani.placod = liped.venda-placod
                         no-lock no-error.
            if avail plani 
            then venda = string(plani.numero).
        end.              
        put unformatted
         pedid.etbcod
         ";"
         pedid.peddat
         ";"
         pedid.pednum
         ";"
         vpedtipo
         ";"
         liped.procod
         ";"
         produ.pronom
         ";"
         liped.lipqtd
         ";"
         venda
         skip.

    end.

end.         
output close.
varquivo = replace(varquivo,"/","~\").   
varquivo = replace(varquivo,"~\admcom","l:").
 
message color red/with
        varquivo
        view-as alert-box title "Arquivo gerado".
  
