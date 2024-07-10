{admcab.i new}
def var imenu as int.
def var vmenu as char format "x(60)" extent 15.
def var vprog as char format "x(15)" extent 15.
def var vopc  as char format "x(15)" extent 15.

def var im as int.
im = 1.  
vmenu[im] = "COCKPIT - Exportador Pedidos (order,ordchg)".         vprog[im] = "edi/cockpitorders.p".           im = im + 1. 
vmenu[im] = "   CRON - Exportador Pedidos (order,ordchg)".  vprog[im] = "edi/exportador-cron.p".           im = im + 1. 

vmenu[im] = "COCKPIT - Importador RESPOSTA (ordrsp)".              vprog[im] = "edi/cockpitrsp.p".         im = im + 1.
vmenu[im] = "   CRON - Importador RESPOSTA (ordrsp)".       vprog[im] = "edi/importadorrsp-cron.p".         im = im + 1.

vmenu[im] = "COCKPIT - Importador CONFIRMA AGENDAM. (confage)".    vprog[im] = "edi/cockpitage.p".        im = im + 1. 

vmenu[im] = "   CRON - Importador CONFIRMA AGENDAM. (confage)".    vprog[im] = "edi/importadorage-cron.p". im = im + 1. 


vmenu[im] = "CONSULTA NOTAS - Exportador Aviso REC (recadv)".   vprog[im] = "not_nfpagc.p".         im = im + 1.

vmenu[im] = "MOVEIS - ENTRADA MERCADORIAS(RECEBIMENTO XML) (recadv)".   vprog[im] = "inc_nf_entrada_xml.p".         im = im + 1.

vmenu[im] = "CRON - Importador NFe".                            vprog[im] = "edi/importadornfe-cron.p".          im = im + 1.
 
repeat.
    disp vmenu
        with 
        row 3 centered
        no-labels
        side-labels
        1 down
        1 col
        title "Projeto Planejamento Compras / EDI ".
    choose field vmenu.
    imenu = frame-index.
    
    hide.
    
    message "Confirma Execucao?" 
            vmenu[imenu]
            vprog[imenu] update sresp.
    if sresp and vprog[imenu] <> ""
    then do:
        if vprog[imenu] = "not_nfpagc.p"
        then run value(vprog[imenu]) (input "consulta|4").
        else
        if vprog[imenu] = "inc_nf_entrada_xml.p"
        then run value(vprog[imenu]) (input "MOVEIS").
        
        else 
            run value(vprog[imenu]).
    end.    

end.    
            
