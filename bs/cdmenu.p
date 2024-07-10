 /*************************INFORMA€OES DO PROGRAMA******************************
***** Nome do Programa             : logandre.p
***** Diretorio                    : gener
***** Autor                        : Andre Baldini
***** Descri‡ao Abreviada da Funcao: Manutencao do Menu
***** Data de Criacao              : 29/12/1998

                                ALTERACOES
***** 1) Autor     : Claudir Santolin
***** 1) Descricao : Alteracao Browse/Cores
***** 1) Data      : 14/09/2000

***** 2) Autor     :
***** 2) Descricao : 
***** 2) Data      :

***** 3) Autor     :
***** 3) Descricao : 
***** 3) Data      :
*******************************************************************************/
def new global shared var senha_sis     as char.
def new global shared var senha_cli     as char.
def new shared buffer menu2             for menu.
def new shared buffer menu3             for menu.

{cabec.i}

def var pmenord as int.
def buffer bmenu    for menu.
def var v-cont      as int.
def var v-down1     as int.
def var v-ordem     like menu.menord.
def buffer bmenu2   for menu.
def buffer dfunc    for func.
def var vfuncod2    like func.funcod.
def var vsenha2     like func.senha.
def var vfuncod     like func.funcod.
def var v-down      as int.
def var vpro        like menu.menpro.
def var p-menu1     like menu.menord.
def var v-title as char.
def var p-tit as char.

form
    menu2.mencod 
    menu2.menord format ">>>9"
    menu2.mentit
        help "ENTER=Altera  F9=Inclui  F10=Exclui  F11=Acima  F12=Abaixo" 
    menu2.menpro
    menu2.invisivel format "Remoto/Normal"
    with frame f-menu2                      
        column 14
        no-labels
        16 down
        title p-tit color withe/green
        overlay 
        row 5.

form
    vfuncod2
    vsenha2
    with frame f-senha2
        centered
        1 down   color withe/red
        side-labels
        overlay
        row 10.
        
form
    menu.mencod
    menu.menord format ">>>9" 
    menu.mentit
        help "ENTER=Altera  F9=Inclui  F10=Exclui" 
    menu.menpro
    with frame f-menu
        column 1
        no-labels 
         color withe/black
        title v-title
        row 4
        16 down.
        
def var funcao          as char.
def var parametro       as char format "x(75)".
def var vok             as log.

wdata = today.

def var p-aplica like menu.aplicod.

find first func where func.funcod = sfuncod no-lock no-error.
if func.admin = no 
then do:
    bell. bell.
    message "funcionario nao autorizado".
    pause. return.
end.
    
find estab where estab.etbcod = setbcod no-lock.
find first wempre.

{setbrw.i}.

repeat :
    clear frame f-aplicativo.
    clear frame f-menu1 all.
    clear frame f-menu2 all.
    hide frame f-menu1.
    hide frame f-menu2.
    
    v-down1 = 0.
    for each aplicativo no-lock : 
        v-down1 = v-down1 + 1.
    end.    

    assign
        a-seeid = -1
        a-recid = -1
        a-seerec = ?.
    form aplicativo.aplinom
         aplicativo.ordem format ">>9"
         aplicativo.aplicod format "x(6)"
         with frame f-aplicativo title " Aplicativos ".
    
    {sklcls.i
         &File = aplicativo
        &CField = aplicativo.aplinom
        &Ofield = "aplicativo.ordem aplicativo.aplicod" 
        &Where = true and 
             not can-find( aplifun where aplifun.funcod = func.funcod and
                           aplifun.aplicod = aplicativo.aplicod) " 
        &AftSelect1 = " 
                    update aplicativo.aplinom aplicativo.ordem 
                        aplicativo.aplicod.
                        p-aplica = aplicativo.aplicod.
                   leave keys-loop. "
        &otherkeys = " logand0.ok "                       
        &Locktype = " "
/***
        &Locktype = "use-index ordem" 
***/
        &form = " frame f-aplicativo centered 
                  v-down1 down no-labels row 3 color withe/brown" 
    }.
    
    if keyfunction(lastkey) = "END-ERROR" 
    then leave.

    repeat :
        v-down = 0.
        find first aplicativo where aplicativo.aplicod = p-aplica
                              no-lock.
        
        for each menu where menu.aplicod = p-aplica 
                        and menu.menniv = 1 
                      no-lock :
            v-down = v-down + 1.
        end.                     
        v-title = aplicativo.aplinom.
        hide frame f no-pause.
        hide frame f-senha2 no-pause.
    
        assign 
            a-seeid = -1
            a-recid = -1
            a-seerec = ?.
             form menu.mentit
                        menu.menord
                        menu.menniv menu.ordsup menu.aplicod
                        menu.menare
                        menu.menpro format "x(12)"
                        menu.menpar format "x(60)"
                        with frame f side-labels 1 down overlay row 10
                        color withe/cyan. 
        
        {sklcls.i
            &file = menu
            &CField = menu.mentit
            &Ofield = "menu.menord menu.menpro menu.mencod " 
            &Where = "menu.aplicod = p-aplica and 
                      menu.menniv = 1 and
                      menu.ordsup = 0" 
           &AftSelect1 = " 
                        pmenord = menu.menord.
                        update menu.mentit
                        menu.menord menu.menniv menu.ordsup menu.aplicod
                        menu.menpro
                        menu.menpar 
                        menu.invisivel
                        with frame f side-labels 1 down overlay row 10
                        color withe/cyan. 
                        for each menu2 where
                                menu2.ordsup = pmenord and 
                                 menu2.menniv = 2 and
                                 menu2.aplicod = p-aplica.
                            menu2.ordsup = menu.menord.
                        end.
                           p-menu1 = menu.menord .
                           p-tit = menu.mentit.
                           hide frame f no-pause.
                           leave keys-loop. " 
           &Otherkeys = " logand1.ok " 
           &naoexiste = " logand1.in " 
           &Form = " frame f-menu " 
        }. 
                    
        if keyfunction(lastkey) = "END-ERROR" 
        then leave.

        view frame f-menu. pause 0.

        assign 
            a-seeid     = -1
            a-recid     = -1
            a-seerec    = ?.
                   form menu2.mentit 
                        menu2.menord format ">>>9"
                        menu2.menniv menu2.ordsup menu2.aplicod format "x(6)"
                        menu2.menare
                        menu2.menpro format "x(12)"
                         menu2.menpar format "x(60)"
                         menu2.invisivel format "Remoto/Local" label "Remoto"
                        with frame f-altera centered 1 down
                        side-labels  overlay
                        color withe/cyan no-validate. 
        
        {sklcls.i
            &file = menu2
            &CField = menu2.mentit
            &Ofield = "menu2.menord menu2.menpro menu2.mencod
                    menu2.invisivel "
            &Where = "menu2.ordsup = p-menu1 and 
                      menu2.menniv = 2 and
                      menu2.aplicod = p-aplica " 
            &AftSelect1 = "
                    update menu2.mentit 
                        menu2.menord menu2.menniv menu2.ordsup menu2.aplicod
                        menu2.menare
                        menu2.menpro 
                         menu2.menpar
                         menu2.invisivel
                        with frame f-altera centered 1 down
                        side-labels row 10 overlay
                        color withe/cyan no-validate. 
                    update menu2.menhel[1]
                            with frame fhelp.   
                              hide frame f-altera no-pause.
                              hide frame fhelp no-pause.                  
                vpro = if menu2.menare = "" ""
                then menu2.menpro + "".p""
                else trim(menu2.menare) + ""/"" + menu2.menpro + "".p"".
                next keys-loop. " 
            &Otherkeys = " logand2.ok " 
            &naoexiste  = " logand2.in "
            &Form = " frame f-menu2 " 
        }.
        
        form 
            menu2.menhel[1] 
                        with frame fhelp width 80 title " HELP "
                    row 15 color message no-label overlay.
    end.                          
end.
