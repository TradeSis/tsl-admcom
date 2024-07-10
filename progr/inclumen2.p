def input parameter vindex as int.
def input parameter vmenuprinc as char format "x(15)".
def input parameter vsubmenu as char format "x(30)".   
def input parameter vmentit as char format "x(40)".   
def input parameter nmentit as char format "x(40)".
def input parameter vmenpro as char format "x(15)". 
def input parameter vmenpar as char .
def var vcont as int.
def var vaplicod like gerloja.aplicativo.aplicod.
def var vordsup as int.
def var vmenord as int.
def output parameter vstatus as char format "x(40)".
         
/* ----- TESTA SE O MENU JA EXISTE --------- */
for each gerloja.aplicativo where aplinom = vmenuprinc.
    find gerloja.menu where menu.aplicod = aplicativo.aplicod and
                        menu.menniv = 2 and
                        menu.mentit = vmentit no-error.
    if avail gerloja.menu
    then do:
        if vindex = 3
        then do:
            delete gerloja.menu.
            vstatus = "MENU EXCLUIDO".
        end.
        else do:
        if gerloja.menu.menpar <> vmenpar 
        then do:
             gerloja.menu.menpar = vmenpar.
             vstatus = "Parametro Alterado".
        end.
        if nmentit <> "" and
           nmentit <> vmentit
        then do:
            gerloja.menu.mentit = nmentit.
            vstatus = "MENU ALTERADO".
        end.   
        else do:
             if gerloja.menu.menpro <> vmenpro
             and length(vmenpro) > 1 
             then do:
                  gerloja.menu.menpro = vmenpro.
                  vstatus = "PROGRAMA ALTERADO".
                  end.
             else   
                 vstatus = "MENU JA EXISTE NESSA FILIAL".
         end.
        end.
        disconnect gerloja.
        return.
     end.
     else if vindex = 2
     then do:
        if nmentit <> ""
        then do:
            vstatus = "MENU NAO ENCONTRADO PARA ALTERACAO".
            disconnect gerloja.
            return.
        end.
     end.

end.  
                                                
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
  

/* ------- TESTAR ENTRADA DE DADOS "SUB-MENU" ---------  */
find gerloja.menu where gerloja.menu.aplicod = vaplicod and
                        gerloja.menu.menniv = 1 and
                        gerloja.menu.mentit = vsubmenu no-error.
if not avail gerloja.menu
then do:
    vstatus = "SUB-MENU INVALIDO".
    disconnect gerloja.
    return.
    /* message "SUB-MENU Invalido" view-as alert-box.
    leave. */
    end.
         

/* ------- BUSCAR ORDEM SUPERIOR DO SUB-MENU --------- */

if vmenuprinc = "DEPOSITO"
then do:
find gerloja.menu where gerloja.menu.aplicod begins vaplicod and                                                    gerloja.menu.mentit = vsubmenu no-error.
end.
else do:
find gerloja.menu where gerloja.menu.aplicod = vaplicod and                                                    gerloja.menu.mentit = vsubmenu no-error.
end.    
    
    if avail gerloja.menu
    then do:
        vordsup = gerloja.menu.menord.
    end.
    else do:
        vstatus = "ORDEM SUPERIOR NAO ENCONTRADA".
        return.
    end.
 

/* ------- BUSCAR ORDEM DO ULTIMO MENU ---------- */
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



/* -------- CRIA 0 MENU NOVO ------------------*/
create gerloja.menu.
gerloja.menu.aplicod = vaplicod.
gerloja.menu.ordsup = vordsup.  
gerloja.menu.menord = vmenord.
gerloja.menu.menniv = 2.
gerloja.menu.mentit = vmentit.
gerloja.menu.menpro = vmenpro.  

vstatus = "MENU INCLUIDO COM SUCESSO".
disconnect gerloja.   


