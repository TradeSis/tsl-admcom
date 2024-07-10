def input parameter vmenuprinc as char format "x(15)".
def input parameter vsubmenu as char format "x(30)".   
def input parameter vmentit as char format "x(40)".   
def input parameter vmenpro as char format "x(15)". 
def var vcont as int.
def var vaplicod like gerloja.aplicativo.aplicod.
def var vordsup as int.
def var vmenord as int.
def output parameter vstatus as char format "x(40)".
         

                                                
/* ----- TESTAR ENTRADA DE DADOS "MENU PRINCIPAL" -------- */
find gerloja.aplicativo where gerloja.aplicativo.aplinom = vmenuprinc                                                        no-error.
    if not avail gerloja.aplicativo
    then do:
        vstatus = "MENU PRINCIPAL INVALIDO".
        disconnect gerloja.
        return.
    end.
    else do:
       vaplicod = gerloja.aplicativo.aplicod. 
    end. 
 
     
find gerloja.menu where menu.aplicod = vaplicod and 
                        menu.mentit = vmentit and
                        menu.menniv = 2  no-error.
       if avail gerloja.menu
       then
            display mentit menpro with frame f-1 centered color white/red.
       else
           vstatus = "MENU NAO ENCONTRADO".    
           
