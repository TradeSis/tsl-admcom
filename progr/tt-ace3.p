/*************************INFORMA€OES DO PROGRAMA******************************
***** Nome do Programa             : menuaces.p
***** Diretorio                    : 
***** Autor                        : Claudir Santolin
***** Descri‡ao Abreviada da Funca : Controle de acessos 
***** Data de Criacao              : 
*******************************************************************************/

{admcab.i new}
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

def var v-recid     as int.
def var p-mencod    as int.
def var v-i         as int.
def var vcod        like func.funcod.
def var v-func      as int.
def buffer bmenu    for menu.
def buffer dmenu    for menu.
def buffer emenu    for menu.
def var v-tit2      as char.
def var v-tit1      as char.
def var vindex as int.
def var v-opc2 as char format "x(10)" extent 2 initial
    ["POR FUNCAO"," POR NOME "].

def var v-cont      as int.
def var v-funcod    like func.funcod.
def var v-cod       like func.funcod.
def var p-aplicod   like aplicativo.aplicod.

form
    aplicativo.aplinom   format "x(15)"
        help "ENTER=Marca  F1=Itens  F4=Desiste  F8=Atualiza"
    with frame f-aplicativo
        row 6 column 1 
        down overlay    color withe/green
        no-label  title color red/withe  " APLICATIVOS " .
        
form
    dmenu.mentit    format "x(25)" 
        help "ENTER=Marca  F1=Itens  F4=Desiste  F8=Atualiza"  
    with frame f-linha
        row 6 9 down no-labels
        overlay column 20           color withe/black
        title v-tit1 .
        
form
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
        
clear frame f-nomefunc all.
hide frame f-nomefunc.

for each tt-admaplic: 
    delete tt-admaplic. 
end.
for each tt-aplifun: 
    delete tt-aplifun.
end.
for each tt-func: 
    delete tt-func.
end.

   
l1: repeat :
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
        l2: repeat :        
            hide frame f-linha no-pause.
            clear frame f-linha no-pause.
            assign 
                a-seeid = -1 
                a-recid = -1 
                a-seerec = ? 
                a-seelst = "".
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
           
            l3: repeat :
                hide frame f-linha1 no-pause.
                clear frame f-linha1 all.
                assign a-seeid = -1 a-recid = -1 
                    a-seerec = ? a-seelst = "".
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
