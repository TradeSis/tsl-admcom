def input parameter vmenprinc as char format "x(15)".
def input parameter vsubmenu as char format "x(30)".   
def input parameter vmentit as char format "x(40)".   
def input parameter vmenpro as char format "x(15)". 

def var vcont as int.
def var vaplicod like gerloja.aplicativo.aplicod.
def var vordsup as int.
def var vmenord as int.
         
/* TESTAR ENTRADA DE DADOS "MENU PRINCIPAL" */
find gerloja.aplicativo where aplinom = vmenprinc no-error.              
    if not avail gerloja.aplicativo
    then do:
        message "MENU PRINCIPAL Invalido" view-as alert-box.
        return.
    end.
    else do:
            vaplicod = gerloja.aplicativo.aplicod. 
    end. 

/* vcont = 0.
for each gerloja.menu where gerloja.menu.aplicod = vaplicod.
    vcont = vcont + 1.
end.

if vcont <= 0 
then 
    message "APLICOD Invalido" view-as alert-box.*/


/* TESTAR ENTRADA DE DADOS "SUB-MENU"  */
find gerloja.menu where gerloja.menu.aplicod = vaplicod and 
                        gerloja.menu.mentit = vsubmenu no-error.
if not avail gerloja.menu
then do:
    message "SUB-MENU Invalido" view-as alert-box.
    leave.
end. 
         

/* BUSCAR ORDEM SUPERIOR DO SUB-MENU */
find gerloja.menu where gerloja.menu.aplicod = vaplicod and                                gerloja.menu.mentit = vsubmenu.
    vordsup = gerloja.menu.menord.
 

/* BUSCAR ORDEM DO ULTIMO MENU */
find last gerloja.menu where gerloja.menu.aplicod = vaplicod and  
                     gerloja.menu.ordsup = vordsup and gerloja.menu.menniv = 2
                     no-error.
    if avail gerloja.menu
    then do:
        vmenord = gerloja.menu.menord + 1.
       end.
    else do:
        vmenord = 1.
       end.

/* CRIAR MENU NOVO */
create gerloja.menu.
gerloja.menu.aplicod = vaplicod.
gerloja.menu.ordsup = vordsup.  
gerloja.menu.menord = vmenord.
gerloja.menu.menniv = 2.
gerloja.menu.mentit = vmentit.
gerloja.menu.menpro = vmenpro.  

display "FILIAL ATUALIZADA COM SUCESSO" with frame f3 centered.
disconnect gerloja.   


