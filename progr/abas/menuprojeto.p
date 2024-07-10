{admcab.i new}
def var imenu as int.
def var vmenu as char format "x(60)" extent 25.
def var vprog as char format "x(25)" extent 25.
def var vopc  as char format "x(25)" extent 25.

def var im as int.
im = 1.  
vmenu[im] = "Parametrizacao de Tipos de Pedido".                       vprog[im] = "abas/abastipo.p".          im = im + 1. 
vmenu[im] = "Cockpit de Sugestao de Compras".                       vprog[im] = "abas/compramen.p".        im = im + 1. 
/*vmenu[im] = "Digitacao manual de Sug Compras".                      vprog[im] =~  "abas/comprainc.p".          im = im + 1.*/
vmenu[im] = "Novo cadastro de grade exposicao".                     vprog[im] = "abas/grademan.p".          im = im + 1.
vmenu[im] = "Novo campo cadastro fornecedor".                       vprog[im] = "forne.p".                  im = im + 1.
vmenu[im] = "Tela de LeadTime PADRAO".                         vprog[im] = "abas/ltpadraoman.p".       im = im + 1.
vmenu[im] = "Tela de Consulta do LeadTime".                         vprog[im] = "abas/resopercons.p".       im = im + 1.
vmenu[im] = "Tela de transferencia com Digitação Manual".           vprog[im] = "fipedido.p". vopc[im] = "MAN".        im = im + 1. 
vmenu[im] = "Tela de transferencia com Digitação Comercial".        vprog[im] = "abas/transfinc.p". vopc[im] = "COM".        im = im + 1.
vmenu[im] = "Tela de transferencia com Digitação ECOMERCE".        vprog[im] = "abas/transfinc.p". vopc[im] = "WEB".        im = im + 1.

vmenu[im] = "LOJAS - Consulta Pedidos        ".   
    vprog[im] = "pedautlj.p".  im = im + 1.

vmenu[im] = "Manutencao em Ped.Transferencias".       vprog[im] = "abas/transfcons.p".  im = im + 1.
vmenu[im] = "CockPit de Transferencias/Cortes".       vprog[im] = "abas/transfcorte.p".  im = im + 1.
vmenu[im] = "CockPit de Carregamento/Emissao NFE".       vprog[im] = "abas/cargamen.p".  im = im + 1.

vmenu[im] = "Consulta Disponivel por Produto".                      vprog[im] = "abas/atende.p".         im = im + 1.
vmenu[im] = "Consulta Cortes por Produto".                      vprog[im] = "abas/cortes.p".         im = im + 1.


vmenu[im] = "--------- BATCH ----------".                           vprog[im] = "".                         im = im + 1.
vmenu[im] = "CRON Exporta Neogrid         scripts/expabasneogrid-cron.sh".            vprog[im] = "abas/expabasneogrid-cron.p".    im = im + 1.
vmenu[im] = "CRON Calcula LeadTime        scripts/hlt-cron.sh".                               vprog[im] = "abas/hlt-cron.p".               im = im + 1.
vmenu[im] = "CRON busca ALCIS   CONF scripts/buscaalcis-cron.sh".                        vprog[im] = "abas/buscaalcis-cron.p".       im = im + 1.
vmenu[im] = "CRON busca NEOGRID TRA   scripts/buscaneogridtra-cron.sh".             vprog[im] = "abas/buscaneogridtra-cron.p".       im = im + 1.
vmenu[im] = "CRON busca NEOGRID COM   scripts/buscaneogridcom-cron.sh".             vprog[im] = "abas/buscaneogridcom-cron.p".       im = im + 1.





 
repeat.
    disp vmenu
        with 
        row 3 centered
        no-labels
        side-labels
        1 down
        title "Projeto Planejamento Compras / Abastecimento ".
    choose field vmenu.
    imenu = frame-index.
    
    hide.
    
    message "Confirma Execucao?" 
            vmenu[imenu]
            vprog[imenu] update sresp.
    if sresp and vprog[imenu] <> ""
    then do:
        if vprog[imenu] =  "abas/comprainc.p"
        then run value(vprog[imenu])(0,0,"MAN").
        else 
        if vprog[imenu] =  "fipedido.p" and vopc[imenu] = "MAN"
        then do:
            def var vetbcod as int.
            vetbcod = setbcod.
            message "FILIAL" update setbcod.
            run value(vprog[imenu]).
            setbcod = vetbcod.
        end.    
        else
        if vprog[imenu] =  "abas/transfinc.p" and vopc[imenu] = "WEB"
        then do:
            vetbcod = setbcod.
            setbcod = 200.
            run value(vprog[imenu])("WEB").
            setbcod = vetbcod.
        end.    
        else
        if vprog[imenu] =  "pedautlj.p" 
        then do:
            vetbcod = setbcod.
            message "FILIAL" update setbcod.
            run value(vprog[imenu]).
            setbcod = vetbcod.
        end.    
        
        if vprog[imenu] =  "abas/transfinc.p" and vopc[imenu] = "COM"
        then run value(vprog[imenu])("COM").
        else
        if vprog[imenu] =  "abas/atende.p" 
        then run value(vprog[imenu])("MENU").
        else 
        if vprog[imenu] =  "abas/cortes.p" 
        then run value(vprog[imenu])("MENU").
        else 
        if vprog[imenu] =  "abas/cortesmen.p" and vopc[imenu] = "MOVEIS"
        then run value(vprog[imenu])("ALCIS_MOVEIS").
        else
        
        if vprog[imenu] =  "abas/transfman.p" and vopc[imenu] = "MOVEIS"
        then run value(vprog[imenu])("ALCIS_MOVEIS,AC").
        else
        if vprog[imenu] =  "abas/transfman.p" and vopc[imenu] = "MODA"
        then run value(vprog[imenu])("ALCIS_MODA,AC").
        else
        if vprog[imenu] =  "abas/transfman.p" and vopc[imenu] = "VEXMODA"
        then run value(vprog[imenu])("ALCIS_VEX,AC").
        else
        if vprog[imenu] =  "abas/transfman.p" and vopc[imenu] = "ESPECIAL"
        then run value(vprog[imenu])("ALCIS_ESP,AC").
        else        
            run value(vprog[imenu]).
    end.    

end.    
            
