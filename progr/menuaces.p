/*************************INFORMA€OES DO PROGRAMA******************************
***** Nome do Programa             : menuaces.p
***** Diretorio                    : 
***** Autor                        : Claudir Santolin
***** Descri‡ao Abreviada da Funca : Controle de acessos 
***** Data de Criacao              : 
*******************************************************************************/

{admcab.i}
{setbrw.i}

on F5 get.
on PF5 get.

def temp-table tt-func like func.
def temp-table tt-admaplic like admaplic
    field situacao as log.
def temp-table tt-admaplic1 like admaplic
    field situacao as log.
def temp-table tt-aplifun like aplifun
    field situacao as log.
def temp-table tt-aplicativo like aplicativo.
def temp-table tt-menu like menu.

def new shared temp-table tt-func-aux
    field funcod like func.funcod
    field funnom like func.funnom
    index ifunc is primary unique funcod.
            
def var v-recid     as int.
def var p-mencod    as int.
def var v-i         as int.
def var vcod        like func.funcod.
def var v-func      as int.
def buffer bmenu    for menu.
def buffer dmenu    for menu.
def buffer emenu    for menu.
def buffer bfunc    for func.
def var v-tit2      as char.
def var v-tit1      as char.
def var vindex as int.
def var v-opc2 as char format "x(10)" extent 2 initial
    ["POR FUNCAO"," POR NOME "].

def var v-cont          as int.
def var v-funcod        like func.funcod.
def var v-cod           like func.funcod.
def var p-aplicod       like aplicativo.aplicod.
def var vcha-asterisco  as character.

form
    a-seelst format "x" column-label "*" 
    aplicativo.aplinom   format "x(15)"
        help "ENTER=Marca  F1=Itens  F4=Desiste  F8=Atualiza"
    with frame f-aplicativo
        row 6 column 1 
        down overlay    color withe/green
        no-label  title color red/withe  " APLICATIVOS " .
        
form
    a-seelst format "x" column-label "*" 
    dmenu.mentit    format "x(25)" 
        help "ENTER=Marca  F1=Itens  F4=Desiste  F8=Atualiza"  
    with frame f-linha
        row 6 9 down no-labels
        overlay column 20           color withe/black
        title v-tit1 .
        
form
    a-seelst format "x" column-label "*" 
    emenu.mentit    format "x(28)" 
        help "ENTER=Marca  F1=Itens  F4=Desiste  F8=Atualiza"  
    with frame f-linha1
        row 6 12 down
        overlay no-labels 
        column 49 color withe/cyan
        title v-tit2 .

def var vfuncod like func.funcod.
def var vfunape like func.funape.

form
    vfuncod  column-label "Cod" format ">>>>9"
    vfunape format "x(18)"  column-label "Des"
    with frame f-nomefunc
        column 55 row 7
        no-labels overlay 
        8 down    color withe/red 
        title color red/withe " SELECIONADOS ".

form
    v-opc2[1]
    v-opc2[2]
    with frame f-opcao
        column 55
        no-labels  color red/withe
        1 down
        title color withe/red " OPCOES ".
        
form
    a-seelst format "x" column-label "*"
    func.funcod     format ">>>>9"
    func.funnom
        help "ENTER=Seleciona  F4=Confirma F5=Procura"
    with frame f-nome
        centered
        row 8   color withe/red
        title color red/withe " POR NOME "
        down.

form func.funcod
     func.funape    no-label
     func.funnom    no-label
     vcha-asterisco no-label
        with 1 down side-label width 80 color white/cyan frame fmostra
                title "SEGURANCA DE MENU POR USUARIO".

prompt-for func.funcod
        with frame fmostra.

find func where func.etbcod = 999 and
                func.funcod = input func.funcod no-lock.

display funnom
        funape with frame fmostra.

clear frame f-nomefunc all.
hide frame f-nomefunc.

for each tt-admaplic: delete tt-admaplic. end.
for each tt-aplifun: delete tt-aplifun. end.
for each tt-func: delete tt-func. end.
create tt-func.
buffer-copy func to tt-func.

sresp = no.
     
message "Deseja aplicar as alterações a outras matrículas?" update sresp.

if sresp
then do:
    
    run zoomfunc.p.

    for each tt-func-aux no-lock:
    
        release bfunc.
        find bfunc where bfunc.etbcod = 999 and
                         bfunc.funcod = tt-func-aux.funcod no-lock.
                
        if available bfunc       
        then do:
        
            create tt-func.
            buffer-copy bfunc to tt-func.
            
        end.
        else do:
                                                              
            message "Erro - O Funcionário " tt-func-aux.funcod " - " tt-func-aux.funnom " não foi encontrado e não será atualizado.".
            pause.
                                                                
        end.    
        /*
        display tt-func-aux.funcod tt-func-aux.funnom skip.
        */
    end.
    
    assign vcha-asterisco = "****".
    
    display vcha-asterisco format "x(4)"
                with frame fmostra.


end.
     
for each aplicativo no-lock:
    find aplifun where aplifun.funcod = func.funcod and
                       aplifun.aplicod = aplicativo.aplicod
                       no-lock no-error.
    if not avail aplifun
    then find aplifun where aplifun.funcod = func.funcod and
                            aplifun.aplicod = "(D)" + aplicativo.aplicod
                            no-lock no-error.
    if avail aplifun
    then do:                        
    create tt-aplifun.
    assign
        tt-aplifun.funcod = func.funcod 
        tt-aplifun.aplicod = aplicativo.aplicod
        tt-aplifun.situacao = no.
    end.    
    /*
    if avail aplifun and substr(string(aplifun.aplicod),1,3) = "(D)"
    then tt-aplifun.situacao = no.
    */
end.            
    
l1: repeat :
        a-seelst = "".
        for each aplicativo no-lock :
                find first tt-aplifun where
                           tt-aplifun.funcod  = func.funcod and
                           tt-aplifun.aplicod = aplicativo.aplicod
                           no-error.
                if avail tt-aplifun and tt-aplifun.situacao = no
                then a-seelst = a-seelst + "," + 
                                    string(recid(aplicativo),"9999999999").
        end.     

        assign 
            a-seeid = -1 
            a-recid = -1 
            a-seerec = ?.
    
        {sklcls.i
            &color = withe/green
            &File = aplicativo
            &CField = aplicativo.aplinom
            &Where = " true no-lock " 
            &Otherkeys = " menuace1.ok "
            &UsePick = "*"
            &PickFld = "recid(aplicativo)"
            &PickFrm = "9999999999" 
            &Form = " frame f-aplicativo " 
        }.                    
        if keyfunction(lastkey) = "END-ERROR"
        then leave l1.
        view frame f-aplicativo.
        for each tt-admaplic:
            delete tt-admaplic.
        end.    
        for each dmenu where dmenu.aplicod = p-aplicod and
                             dmenu.menniv = 1 no-lock.
            find admaplic where admaplic.cliente = string(func.funcod) and
                                admaplic.aplicod = dmenu.aplicod and
                                admaplic.menniv  = dmenu.menniv and
                                admaplic.ordsup  = dmenu.ordsup and
                                admaplic.menord  = dmenu.menord
                                no-lock no-error.
            if not avail admaplic
            then find admaplic where admaplic.cliente = string(func.funcod) and
                                admaplic.aplicod = "(D)" + dmenu.aplicod and
                                admaplic.menniv  = dmenu.menniv and
                                admaplic.ordsup  = dmenu.ordsup and
                                admaplic.menord  = dmenu.menord
                                no-lock no-error.

            if avail admaplic
            then do:
            create tt-admaplic.
            assign
                tt-admaplic.cliente = string(func.funcod) 
                tt-admaplic.aplicod = dmenu.aplicod
                tt-admaplic.menniv  = dmenu.menniv
                tt-admaplic.ordsup  = dmenu.ordsup 
                tt-admaplic.menord  = dmenu.menord
                tt-admaplic.situacao = no
                .
            end.
            /*    
            if avail admaplic and substr(string(admaplic.aplicod),1,3) = "(D)"
            then tt-admaplic.situacao = no.
            */
        end.                     
        l2: repeat :        
            hide frame f-linha no-pause.
            clear frame f-linha no-pause.
            assign 
                a-seeid = -1 
                a-recid = -1 
                a-seerec = ? 
                a-seelst = "".
          
            for each dmenu where dmenu.menniv = 1 
                                and dmenu.aplicod = p-aplicod 
                              no-lock :
                    find first tt-admaplic where
                               tt-admaplic.cliente  = string(func.funcod) and
                               tt-admaplic.aplicod = dmenu.aplicod and
                               tt-admaplic.menniv  = dmenu.menniv and
                               tt-admaplic.ordsup  = dmenu.ordsup and
                               tt-admaplic.menord  = dmenu.menord 
                               no-error.
                    if avail tt-admaplic and
                        tt-admaplic.situacao = no
                    then a-seelst = a-seelst + "," + 
                                    string(recid(dmenu),"9999999999").
            end.                                

            find first aplicativo where aplicativo.aplicod = p-aplicod
                                  no-lock. 
            v-tit1 = "OPCOES de " + aplicativo.aplinom.

            {sklcls.i
                &color = withe/black
                &File   = dmenu
                &CField = dmenu.mentit    
                &Where = " dmenu.menniv = 1 and 
                      dmenu.aplicod = p-aplicod "  
                &Otherkeys = " menuace2.ok "
                &UsePick = "*"
                &PickFld = "recid(dmenu)"
                &PickFrm = "9999999999" 
                &Form = " frame f-linha "
            }.

            view frame f-linha. pause 0.
            if keyfunction(lastkey) = "END-ERROR"
            then do :
                hide frame f-linha.
                leave l2.
            end.    
            for each tt-admaplic1:
                delete tt-admaplic1.
            end.    
            for each emenu where 
                     emenu.aplicod = p-aplicod and
                     emenu.menniv = 2 and
                     emenu.ordsup = p-mencod no-lock.
                find admaplic where 
                            admaplic.cliente = string(func.funcod) and
                            admaplic.aplicod = emenu.aplicod and
                            admaplic.menniv  = emenu.menniv and
                            admaplic.ordsup  = emenu.ordsup and
                            admaplic.menord  = emenu.menord
                            no-lock no-error.
                if not avail admaplic
                then find admaplic where 
                            admaplic.cliente = string(func.funcod) and
                            admaplic.aplicod = "(D)" + emenu.aplicod and
                            admaplic.menniv  = emenu.menniv and
                            admaplic.ordsup  = emenu.ordsup and
                            admaplic.menord  = emenu.menord
                            no-lock no-error.

                if avail admaplic
                then do:
                find first tt-admaplic1 where
                               tt-admaplic1.cliente  = string(func.funcod) and
                               tt-admaplic1.aplicod = emenu.aplicod and
                               tt-admaplic1.menniv  = emenu.menniv and
                               tt-admaplic1.ordsup  = emenu.ordsup and
                               tt-admaplic1.menord  = emenu.menord 
                               no-error.
                if not avail tt-admaplic1
                then do:
                create tt-admaplic1.
                assign
                    tt-admaplic1.cliente = string(func.funcod) 
                    tt-admaplic1.aplicod = emenu.aplicod
                    tt-admaplic1.menniv  = emenu.menniv
                    tt-admaplic1.ordsup  = emenu.ordsup 
                    tt-admaplic1.menord  = emenu.menord
                    tt-admaplic1.situacao = no
                    .
                end.
                end.
                /*
                if avail admaplic and 
                         substr(string(admaplic.aplicod),1,3) = "(D)"
                then tt-admaplic1.situacao = no.
                */
            end.             
            l3: repeat :
                hide frame f-linha1 no-pause.
                clear frame f-linha1 all.
                assign a-seeid = -1 a-recid = -1 
                    a-seerec = ? a-seelst = "".
            
                for each emenu where emenu.menniv = 2 
                                    and emenu.aplicod = p-aplicod 
                                    and emenu.ordsup  = p-mencod 
                                  no-lock :
                    find first tt-admaplic1 where
                               tt-admaplic1.cliente  = string(func.funcod) and
                               tt-admaplic1.aplicod = emenu.aplicod and
                               tt-admaplic1.menniv  = emenu.menniv and
                               tt-admaplic1.ordsup  = emenu.ordsup and
                               tt-admaplic1.menord  = emenu.menord 
                               no-error.
                    if avail tt-admaplic1 and
                        tt-admaplic1.situacao = no
                    then a-seelst = a-seelst + "," + 
                                    string(recid(emenu),"9999999999").

                end.                                
    
                v-tit2 = "OPCOES de " + string(dmenu.mentit).

                {sklcls.i
                    &color = withe/cyan
                    &File   = emenu
                    &CField = emenu.mentit    
                    &Where = " emenu.menniv = 2 and 
                              emenu.aplicod = p-aplicod and 
                              emenu.ordsup = p-mencod " 
                    &Otherkeys = " menuace3.ok " 
                    &UsePick = "*"
                    &PickFld = "recid(emenu)"
                    &PickFrm = "9999999999" 
                    &Form = " frame f-linha1 "
                }.
                if keyfunction(lastkey) = "END-ERROR"
                then do :
                    hide frame f-linha1. 
                    leave l3.
                end.    
            end.
        end. 
end.
