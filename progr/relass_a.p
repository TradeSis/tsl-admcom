/****************************************************************************
* Browse analitico de Assistencia Tecnica
* Criado        : 19/04/2009 
* Autor         : Antonio
* Ult.Alteracao : Quebrar por Fabricante 
******************************************************************************/
pause 0.

def input parameter  p-dti as date format "99/99/9999".
def input parameter  p-dtf as date format "99/99/9999".
def input parameter  p-forcod like forne.forcod.
def input parameter  p-etbcod like estab.etbcod.

def var v-descri    as char format "x(78)".
def var recimp      as recid.
def var fila        as char.
def var v-nivel-up  as char.  

{admcab.i}
{setbrw.i}

def var v-kont as int.
def var descricao-ger as char format "x(28)" extent 14 initial
["Total Geral                ",
 "Produtos de Cliente        ",
 "Produtos de Estoque        ",
 "Total Pendente             ",
 "Total Solucionado          ",
 "Solucionados de 0 a 15 dias",
 "Solucionados de 0 a 20 dias",
 "Solucionados de 0 a 30 dias",
 "Solucionados de Clientes   ",
 "Solucionados de Estoque    ",
 "Pendentes    de Clientes   ",
 "Pendentes    de Estoque    ",
 "Pendentes    de Fornecedor ",
 "Pendentes    de Fabricante "].  
 
def var vkont           as int.
def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
   initial ["CLASSE","FABRICANTE","IMPRIME","",""].
def var esqcom2         as char format "x(15)" extent 5
            initial ["F4 - Retorna","","","",""].

def shared temp-table tw-assist-ger
field clfcod         like forne.forcod 
field fornome        as char format "x(25)"
field os-total       as int
field v-os-total     like plani.platot                                      
field os-pend        as int
field v-os-pen       like plani.platot
field os-sol         as int
field v-os-sol       like plani.platot 
field os-15          as int
field v-os-15        like plani.platot
field os-20          as int
field v-os-20        like plani.platot
field os-30          as int
field v-os-30        like plani.platot
field os-cli         as int
field v-os-cli       like plani.platot
field os-est         as int
field v-os-est       like plani.platot
field os-pencli      as int
field v-os-pencli    like plani.platot
field os-solcli      as int
field v-os-solcli    like plani.platot
field os-penest      as int
field v-os-penest    like plani.platot
field os-solest      as int
field v-os-solest    like plani.platot
field os-fornec      as int
field v-os-fornec    like plani.platot 
field os-fabri       as int   
field v-os-fabri     like plani.platot
field os-penfornec   as int
field v-os-penfornec like plani.platot
field os-penfabri    as int
field v-os-penfabri  like plani.platot.

def shared temp-table tw-assist-cla no-undo
field clacod         like clase.clacod
field clanom         like clase.clanom
field os-total       as int
field v-os-total     like plani.platot 
field os-pend        as int
field v-os-pen       like plani.platot
field os-sol         as int
field v-os-sol       like plani.platot 
field os-15          as int
field v-os-15        like plani.platot
field os-20          as int
field v-os-20        like plani.platot
field os-30          as int
field v-os-30        like plani.platot
field os-cli         as int
field v-os-cli       like plani.platot
field os-est         as int
field v-os-est       like plani.platot
field os-pencli      as int
field v-os-pencli    like plani.platot
field os-solcli      as int
field v-os-solcli    like plani.platot
field os-penest      as int
field v-os-penest    like plani.platot
field os-solest      as int
field v-os-solest    like plani.platot
field os-fornec      as int
field v-os-fornec    like plani.platot 
field os-fabri       as int   
field v-os-fabri     like plani.platot
field os-penfornec   as int
field v-os-penfornec like plani.platot
field os-penfabri    as int
field v-os-penfabri  like plani.platot.

def shared temp-table tw-assist-fabri no-undo
field fabcod         like fabri.fabcod
field fabnom         like fabri.fabnom
field os-total       as int
field v-os-total     like plani.platot 
field os-pend        as int
field v-os-pen       like plani.platot
field os-sol         as int
field v-os-sol       like plani.platot 
field os-15          as int
field v-os-15        like plani.platot
field os-20          as int
field v-os-20        like plani.platot
field os-30          as int
field v-os-30        like plani.platot
field os-cli         as int
field v-os-cli       like plani.platot
field os-est         as int
field v-os-est       like plani.platot
field os-pencli      as int
field v-os-pencli    like plani.platot
field os-solcli      as int
field v-os-solcli    like plani.platot
field os-penest      as int
field v-os-penest    like plani.platot
field os-solest      as int
field v-os-solest    like plani.platot
field os-fornec      as int
field v-os-fornec    like plani.platot 
field os-fabri       as int   
field v-os-fabri     like plani.platot
field os-penfornec   as int
field v-os-penfornec like plani.platot
field os-penfabri    as int
field v-os-penfabri  like plani.platot.


def shared temp-table tw-assist-pro no-undo
field procod         like produ.procod
field pronom         like produ.pronom
field os-total       as int
field v-os-total     like plani.platot 
field os-pend        as int
field v-os-pen       like plani.platot
field os-sol         as int
field v-os-sol       like plani.platot 
field os-15          as int
field v-os-15        like plani.platot
field os-20          as int
field v-os-20        like plani.platot
field os-30          as int
field v-os-30        like plani.platot
field os-cli         as int
field v-os-cli       like plani.platot
field os-est         as int
field v-os-est       like plani.platot
field os-pencli      as int
field v-os-pencli    like plani.platot
field os-solcli      as int
field v-os-solcli    like plani.platot
field os-penest      as int
field v-os-penest    like plani.platot
field os-solest      as int
field v-os-solest    like plani.platot
field os-fornec      as int
field v-os-fornec    like plani.platot 
field os-fabri       as int   
field v-os-fabri     like plani.platot
field os-penfornec   as int
field v-os-penfornec like plani.platot
field os-penfabri    as int
field v-os-penfabri  like plani.platot.


def temp-table tt-geral no-undo
field sequencia as int 
field descricao as char format "x(40)"  label "Descricao"
field quant     as int                  label "Qtde"
field valor     like plani.platot       label "Valor"
field perc      as dec format ">>9.99%" label "% Qtde" .  

def temp-table tt-clase no-undo
field sequencia as int 
field descricao as char format "x(40)"  label "Classe"
field quant     as int                  label "Qtde"
field valor     like plani.platot       label "Valor"
field perc      as dec format ">>9.99%" label "% Qtde".  

def temp-table tt-fabri no-undo
field sequencia as int 
field descricao as char format "x(40)"  label "Classe"
field quant     as int                  label "Qtde"
field valor     like plani.platot       label "Valor"
field perc      as dec format ">>9.99%" label "% Qtde".  

def temp-table tt-produ no-undo
field sequencia as int
field clacod    like produ.clacod 
field fabcod    like produ.fabcod
field descricao as char format "x(40)"  label "Produto"
field quant     as int                  label "Qtde"
field valor     like plani.platot       label "Valor"
field perc      as dec format ">>9.99%" label "% Qtde".  

form
    esqcom1
    with frame f-com1
                 row 3 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.
                

form " " 
     " "
     with frame f-linha 10 down color with/cyan /*no-box*/
     centered.
                                                                         
form " " 
     " "
     with frame f-linha1 10 down color with/cyan /*no-box*/
    centered.

form " " 
     " "
     with frame f-linha2 10 down color with/cyan /*no-box*/ centered.
                                                 
disp " " with frame f2 1 down width 80 color message no-box no-label            
    row 20.                                                                     
def buffer btw-assist-ger for tw-assist-ger.                            
def var i as int.

for each tt-geral:
    delete tt-geral.
end.

/***** TELA GERAL *****/
for each tw-assist-ger:
  do v-kont = 1 to 14:
    create tt-geral.
    assign      tt-geral.sequencia = v-kont
                tt-geral.descricao = descricao-ger [v-kont].
    
    if v-kont = 1 
    then assign tt-geral.quant = tw-assist-ger.os-total
                tt-geral.valor = tw-assist-ger.v-os-total.
                tt-geral.per   = 100.
               
    if v-kont = 2
           then assign tt-geral.quant = tw-assist-ger.os-cli
             tt-geral.valor = tw-assist-ger.v-os-cli
             tt-geral.perc  = ((tw-assist-ger.os-cli / tw-assist-ger.os-total) 
                                * 100).
    if v-kont = 3 
    then assign tt-geral.quant = tw-assist-ger.os-est
                tt-geral.valor = tw-assist-ger.v-os-est
                tt-geral.perc  = ((tw-assist-ger.os-est /
                                   tw-assist-ger.os-total) * 100).
    if v-kont = 4 
    then assign tt-geral.quant = tw-assist-ger.os-pend
                tt-geral.valor = tw-assist-ger.v-os-pen
                tt-geral.perc  = ((tw-assist-ger.os-pend /
                                   tw-assist-ger.os-total) * 100).
    if v-kont = 5 
    then assign tt-geral.quant = tw-assist-ger.os-sol
            tt-geral.valor = tw-assist-ger.v-os-sol
            tt-geral.perc  = ((tw-assist-ger.os-sol / tw-assist-ger.os-total) 
                               * 100).
    if v-kont = 6 
    then assign tt-geral.quant = tw-assist-ger.os-15
        tt-geral.valor = tw-assist-ger.v-os-15
        tt-geral.perc  = ((tw-assist-ger.os-15 / tw-assist-ger.os-total) 
                           * 100).
    if v-kont = 7 
    then assign tt-geral.quant = tw-assist-ger.os-20
        tt-geral.valor = tw-assist-ger.v-os-20
        tt-geral.perc  = ((tw-assist-ger.os-20 / tw-assist-ger.os-total) 
                           * 100).
    if v-kont = 8 
    then assign tt-geral.quant = tw-assist-ger.os-30
        tt-geral.valor = tw-assist-ger.v-os-30
        tt-geral.perc  = ((tw-assist-ger.os-30 / tw-assist-ger.os-total) 
                           * 100).
    if v-kont = 9 
    then assign tt-geral.quant = tw-assist-ger.os-solcli
        tt-geral.valor = tw-assist-ger.v-os-solcli
        tt-geral.perc  = ((tw-assist-ger.os-solcli / tw-assist-ger.os-total) 
                           * 100).
    if v-kont = 10 
    then assign tt-geral.quant = tw-assist-ger.os-solest
        tt-geral.valor = tw-assist-ger.v-os-solest
        tt-geral.perc  = ((tw-assist-ger.os-solest / tw-assist-ger.os-total) 
                           * 100).
    if v-kont = 11
    then assign tt-geral.quant = tw-assist-ger.os-pencli
      tt-geral.valor = tw-assist-ger.v-os-pencli
      tt-geral.perc  = ((tw-assist-ger.os-pencli / tw-assist-ger.os-total) 
                         * 100).
    if v-kont = 12
    then assign tt-geral.quant = tw-assist-ger.os-penest
      tt-geral.valor = tw-assist-ger.v-os-penest
      tt-geral.perc  = ((tw-assist-ger.os-penest / tw-assist-ger.os-total) 
                         * 100).
    if v-kont = 13
    then assign tt-geral.quant = tw-assist-ger.os-penfornec
      tt-geral.valor = tw-assist-ger.v-os-penfornec
      tt-geral.perc  = ((tw-assist-ger.os-penfornec / tw-assist-ger.os-total) 
                         * 100).
    if v-kont = 14
        then assign tt-geral.quant = tw-assist-ger.os-penfabri
          tt-geral.valor = tw-assist-ger.v-os-penfabri
          tt-geral.perc = ((tw-assist-ger.os-penfabri / tw-assist-ger.os-total)                          * 100).
  end.
end.
find first tt-geral no-error.
if not avail tt-geral
then do:
    message "Nenhum registro Selecionado" view-as alert-box.
    undo, retry.
end.

l1: repeat:
    assign esqcom2[1] = "F4 - Retorna".
    assign esqcom1[1] = "CLASSE"
           esqcom1[2] = "FABRICANTE"
           esqcom1[3] = "IMPRIME".
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.

    assign
        a-seeid = -1 a-recid = -1 a-seerec = ?
        esqpos1 = 1 esqpos2 = 1. 
    do i = 2 to 5:
        color display normal esqcom1[i] with frame f-com1.
    end.
    color display message esqcom1[1] with frame f-com1.
    color display normal esqcom2[1] with frame f-com2.
    pause 0.
    hide frame f-linha no-pause.
    clear frame f-linha all.
    pause 0.
    disp "                  RESUMO DE ASSISTENCIA TECNICA       "  @ v-descri
            with frame f1 1 down width 80                                       
            color message no-box no-label row 4.
     assign esqpos1 = 1.
     do i = 2 to 5:
        color display normal esqcom1[i] with frame f-com1.
     end.
     color display message esqcom1[1] with frame f-com1.
     assign v-nivel-up = "".
     for each tt-clase:
        delete tt-clase.
     end.
     for each tt-fabri:
        delete tt-fabri.
     end.

     {sklclstb.i  
        &color   = with/cyan
        &file    = tt-geral 
        &cfield  = tt-geral.descricao
        &noncharacter = /* 
        &ofield  = "tt-geral.quant tt-geral.perc tt-geral.valor"  
        &aftfnd1 = " "
        &where   = " "
        &aftselect1 = "run aftselect.
                       a-seeid = -1.
                       if esqcom1[esqpos1] = ""IMPRIME""
                       then leave l1.
                       if esqcom1[esqpos1] = ""CLASSE"" 
                       then do:
                            next l1.
                       end.
                       if esqcom1[esqpos1] = ""FABRICANTE"" 
                       then do:
                            next l1.
                       end.
                       else next keys-loop."
        &go-on = TAB 
        &naoexiste1 = " "
        &otherkeys1 = "run controle."
        &locktype   = " "
        &form       = " frame f-linha "
    }   
    if keyfunction(lastkey) = "end-error"
    then DO:
        leave l1.       
    END.
end.
hide frame f1 no-pause.
hide frame f2 no-pause.
hide frame ff2 no-pause.               
hide frame f-linha no-pause.

procedure aftselect:

    clear frame f-linha all.
    clear frame f-linha1 all.
    clear frame f-linha2 all.

    if esqcom1[esqpos1] = "IMPRIME"
    then run relatorio.

    if esqcom1[esqpos1] = "CLASSE"
    THEN DO on error undo:
        assign v-descri = tt-geral.descricao.
        run Pi-Classe(input tt-geral.sequencia, input tt-geral.quant).
        disp "           RESUMO DE ASSISTENCIA TECNICA - CLASSE     "  @ 
              v-descri with frame f1 1 down width 80
              color message no-box no-label row 4.
        assign v-nivel-up = "CLASSE".
        hide frame f1 no-pause.
        assign esqcom1[1] = "CLASSE" 
               esqcom1[2] = "IMPRIME".
        return.
    END.

    if esqcom1[esqpos1] = "FABRICANTE"
    THEN DO on error undo:
        assign v-descri = tt-geral.descricao.
        run Pi-Fabricante(input tt-geral.sequencia, input tt-geral.quant).
        disp "     RESUMO DE ASSISTENCIA TECNICA - FABRICANTE    "  @ 
               v-descri with frame f1 1 down width 80
               color message no-box no-label row 4.
        assign v-nivel-up = "FABRICANTE".
        hide frame f1 no-pause.
        assign esqcom1[1] = "FABRICANTE" 
               esqcom1[2] = "IMPRIME".
        return.
    END.

    if esqcom1[esqpos1] = "PRODUTO  "  /* com 2 brancos antes Fabricante */ 
    THEN DO on error undo:
              assign esqcom1[1] = "" 
                     esqcom1[2] = "".

              run Pi-Produto-f(input v-kont, input tt-fabri.sequencia, 
                              input tt-fabri.descricao, input tt-fabri.quant).

              assign esqcom1[1] = "PRODUTO"
                     esqcom1[2] = "IMPRIME"
                     esqcom1[3] = "".
              disp esqcom1 with frame f-com1.
              pause 0.
              disp 
              string ("FABRICANTES EM ASSISTENCIA TECNICA ( " +          
              descricao-ger[v-kont] + " )") @ v-descri 
              with frame f1 1 down width 80 color message no-box no-label row 4.              disp " " with frame f2 1 down width 80
              color normal no-box no-label row 20.
              pause 0. 
    end.
    if esqcom1[esqpos1] = "  PRODUTO"  /* 2 brancos de classes  apos */
    THEN DO on error undo:
              assign esqcom1[1] = "" 
                     esqcom1[2] = "".

              run Pi-Produto-c(input v-kont, input tt-clase.sequencia, 
                             input v-descri, input tt-clase.quant).

              
              assign esqcom1[1] = "PRODUTO"
                     esqcom1[2] = "IMPRIME"
                     esqcom1[3] = "".
              disp esqcom1 with frame f-com1.
              pause 0.
              disp string ("CLASSES EM ASSISTENCIA TECNICA ( " + 
              descricao-ger[v-kont] + " )") @ v-descri 
              with frame f1 1 down width 80 color message no-box no-label row 4.              disp " " with frame f2 1 down width 80
              color normal no-box no-label row 20. 
              pause 0.
    END.

end procedure.

procedure controle:


def var ve as int.

            if keyfunction(lastkey) = "TAB"
            then do:
                if esqregua
                then do:
                    esqpos1 = 1.
                    do ve = 1 to 5:
                    color display normal esqcom1[ve] with frame f-com1.
                    end.
                    color display message esqcom2[esqpos2] with frame f-com2.
                end.
                 else do:
                    do ve = 1 to 5:
                    color display normal esqcom2[ve] with frame f-com2.
                    end.
                    esqpos2 = 1.
                    color display message esqcom1[esqpos1] with frame f-com1.
                end.
                esqregua = not esqregua.
            end.
            if keyfunction(lastkey) = "cursor-right"
            then do:
                if esqregua
                then do:                
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 5 then 5 else esqpos2 + 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                end.
                next.
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 1 then 1 else esqpos2 - 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                end.
                next.
            end.
 end procedure.


/***** PRODUTOS ****/

/* De Clases */
Procedure Pi-Produto-c.

def input parameter p-ocorre as int.
def input parameter p-clase like produ.clacod.
def input parameter p-descricao as char format "x(25)".
def input parameter p-tot-ocor as int.

assign v-kont = p-ocorre.

find first clase where clase.clacod = p-clase no-lock no-error. 


disp string( "PRODUTOS DA CLASSE " + clase.clanom +
 " ( " + p-descricao + " )" + " EM ASSISTENCIA TECNICA") @ v-descri with frame f1 1 down width 80         
                   color message no-box no-label row 4.
                                                  
disp " " with frame f2 1 down width 80 color message no-box no-label row 20.   
                                                                
/* Tela Produto */

for each tw-assist-pro:
 
    find produ where produ.procod = tw-assist-pro.procod no-lock no-error.
    if produ.clacod <> p-clase then next.
    find first tt-produ where tt-produ.sequencia = tw-assist-pro.procod 
                        and tt-produ.clacod    = produ.clacod
                        and tt-produ.descricao = tw-assist-pro.pronom
                        no-error.
    if avail tt-produ then next.                    
    create tt-produ.
    assign  tt-produ.sequencia = tw-assist-pro.procod 
            tt-produ.clacod    = produ.clacod
            tt-produ.descricao = tw-assist-pro.pronom.
     
    if v-kont = 1 
    then assign tt-produ.quant = tw-assist-pro.os-total
                tt-produ.valor = tw-assist-pro.v-os-total
                tt-produ.perc  = ((tw-assist-pro.os-total / p-tot-ocor) * 100).
    
    if v-kont = 2
           then assign tt-produ.quant = tw-assist-pro.os-cli
             tt-produ.valor = tw-assist-pro.v-os-cli
             tt-produ.perc  = ((tw-assist-pro.os-cli / p-tot-ocor) * 100).
    if v-kont = 3 
    then assign tt-produ.quant = tw-assist-pro.os-est
                tt-produ.valor = tw-assist-pro.v-os-est
                tt-produ.perc  = ((tw-assist-pro.os-est / p-tot-ocor) * 100).
    if v-kont = 4 
    then assign tt-produ.quant = tw-assist-pro.os-pend
                tt-produ.valor = tw-assist-pro.v-os-pen
                tt-produ.perc  = ((tw-assist-pro.os-pend / p-tot-ocor) * 100).
    if v-kont = 5 
    then assign tt-produ.quant = tw-assist-pro.os-sol
            tt-produ.valor = tw-assist-pro.v-os-sol
            tt-produ.perc  = ((tw-assist-pro.os-sol / p-tot-ocor) * 100).
    if v-kont = 6 
    then assign tt-produ.quant = tw-assist-pro.os-15
        tt-produ.valor = tw-assist-pro.v-os-15
        tt-produ.perc  = ((tw-assist-pro.os-15 / p-tot-ocor) * 100).
    if v-kont = 7 
    then assign tt-produ.quant = tw-assist-pro.os-20
        tt-produ.valor = tw-assist-pro.v-os-20
        tt-produ.perc  = ((tw-assist-pro.os-20 / p-tot-ocor) * 100).
    if v-kont = 8 
    then assign tt-produ.quant = tw-assist-pro.os-30
        tt-produ.valor = tw-assist-pro.v-os-30
        tt-produ.perc  = ((tw-assist-pro.os-30 / p-tot-ocor) * 100).
    if v-kont = 9 
    then assign tt-produ.quant = tw-assist-pro.os-solcli
        tt-produ.valor = tw-assist-pro.v-os-solcli
        tt-produ.perc  = ((tw-assist-pro.os-solcli / p-tot-ocor) * 100).
    if v-kont = 10 
    then assign tt-produ.quant = tw-assist-pro.os-solest
        tt-produ.valor = tw-assist-pro.v-os-solest
        tt-produ.perc  = ((tw-assist-pro.os-solest / p-tot-ocor) * 100).
    if v-kont = 11
    then assign tt-produ.quant = tw-assist-pro.os-pencli
      tt-produ.valor = tw-assist-pro.v-os-pencli
      tt-produ.perc  = ((tw-assist-pro.os-pencli / p-tot-ocor) * 100).
    if v-kont = 12
    then assign tt-produ.quant = tw-assist-pro.os-penest
      tt-produ.valor = tw-assist-pro.v-os-penest
      tt-produ.perc  = ((tw-assist-pro.os-penest / p-tot-ocor) * 100).
    if v-kont = 13
    then assign tt-produ.quant = tw-assist-pro.os-penfornec
      tt-produ.valor = tw-assist-pro.v-os-penfornec
      tt-produ.perc  = ((tw-assist-pro.os-penfornec / p-tot-ocor) * 100).
    if v-kont = 14
        then assign tt-produ.quant = tw-assist-pro.os-penfabri
          tt-produ.valor = tw-assist-pro.v-os-penfabri
          tt-produ.perc  = ((tw-assist-pro.os-penfabri / p-tot-ocor) * 100).
end.

for each tt-produ:
    if tt-produ.quant = 0 then delete tt-produ.
end.    

l1: repeat:
    assign esqcom2[1] = "F4 - Retorna".
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    assign
        a-seeid = -1 a-recid = -1 a-seerec = ?
        esqpos1 = 1 esqpos2 = 1. 
    do i = 1 to 5:
        color display normal esqcom1[i] with frame f-com1.
    end.
    color display message esqcom2[1] with frame f-com2.
    hide frame f-linha2 no-pause.
    clear frame f-linha2 all.
     pause 0.
    {sklclstb.i  
        &color = with/cyan
        &file  =  tt-produ 
        &cfield = tt-produ.descricao
        &noncharacter = /* 
        &ofield = " tt-produ.quant tt-produ.perc tt-produ.valor "  
        &aftfnd1 = " "
        &where  = " tt-produ.clacod = p-clase "
        &aftselect1 = " run aftselect.
                        a-seeid = -1.
                        if esqcom2[esqpos2] = ""  PRODUTO""
                        then do:
                            next l1.
                        end.
                        else  next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = "  " 
        &otherkeys1 = " run controle. "
        &locktype = " "
        &form   = " frame f-linha2 down "
    }   
    if keyfunction(lastkey) = "end-error"
    then DO:
         leave l1.       
    END.
end.

hide frame f1 no-pause.
hide frame f2 no-pause.
hide frame ff2 no-pause.
hide frame f-linha2 no-pause.

end procedure.


/* De Fabricantes */
Procedure Pi-Produto-f.

def input parameter p-ocorre as int.
def input parameter p-fabcod like fabri.fabcod.
def input parameter p-descricao as char format "x(25)".
def input parameter p-tot-ocor as int.

assign v-kont = p-ocorre.


find first fabri where fabri.fabcod = p-fabcod no-lock no-error. 

disp string( "PRODUTOS DO FABRICANTE " + fabri.fabnom + " EM ASSISTENCIA TECNICA" ) @ v-descri with frame f1 1 down width 80         
           color message no-box no-label row 4.
                                                  
disp " " with frame f2 1 down width 80 color message no-box no-label row 20.   
                                                                
/* Tela Produto */

for each tw-assist-pro:
 
    find produ where produ.procod = tw-assist-pro.procod no-lock no-error.
    if produ.fabcod <> p-fabcod then next.
    find first tt-produ where tt-produ.sequencia = tw-assist-pro.procod 
                        and tt-produ.sequencia   = produ.fabcod
                        and tt-produ.descricao = tw-assist-pro.pronom
                        no-error.

    if avail tt-produ then next.                    
    create tt-produ.
    assign  tt-produ.sequencia = tw-assist-pro.procod 
            tt-produ.sequencia  = produ.fabcod
            tt-produ.descricao = tw-assist-pro.pronom.
     
    if v-kont = 1 
    then assign tt-produ.quant = tw-assist-pro.os-total
                tt-produ.valor = tw-assist-pro.v-os-total
                tt-produ.perc  = ((tw-assist-pro.os-total / p-tot-ocor) * 100).
    
    if v-kont = 2
           then assign tt-produ.quant = tw-assist-pro.os-cli
             tt-produ.valor = tw-assist-pro.v-os-cli
             tt-produ.perc  = ((tw-assist-pro.os-cli / p-tot-ocor) * 100).
    if v-kont = 3 
    then assign tt-produ.quant = tw-assist-pro.os-est
                tt-produ.valor = tw-assist-pro.v-os-est
                tt-produ.perc  = ((tw-assist-pro.os-est / p-tot-ocor) * 100).
    if v-kont = 4 
    then assign tt-produ.quant = tw-assist-pro.os-pend
                tt-produ.valor = tw-assist-pro.v-os-pen
                tt-produ.perc  = ((tw-assist-pro.os-pend / p-tot-ocor) * 100).
    if v-kont = 5 
    then assign tt-produ.quant = tw-assist-pro.os-sol
            tt-produ.valor = tw-assist-pro.v-os-sol
            tt-produ.perc  = ((tw-assist-pro.os-sol / p-tot-ocor) * 100).
    if v-kont = 6 
    then assign tt-produ.quant = tw-assist-pro.os-15
        tt-produ.valor = tw-assist-pro.v-os-15
        tt-produ.perc  = ((tw-assist-pro.os-15 / p-tot-ocor) * 100).
    if v-kont = 7 
    then assign tt-produ.quant = tw-assist-pro.os-20
        tt-produ.valor = tw-assist-pro.v-os-20
        tt-produ.perc  = ((tw-assist-pro.os-20 / p-tot-ocor) * 100).
    if v-kont = 8 
    then assign tt-produ.quant = tw-assist-pro.os-30
        tt-produ.valor = tw-assist-pro.v-os-30
        tt-produ.perc  = ((tw-assist-pro.os-30 / p-tot-ocor) * 100).
    if v-kont = 9 
    then assign tt-produ.quant = tw-assist-pro.os-solcli
        tt-produ.valor = tw-assist-pro.v-os-solcli
        tt-produ.perc  = ((tw-assist-pro.os-solcli / p-tot-ocor) * 100).
    if v-kont = 10 
    then assign tt-produ.quant = tw-assist-pro.os-solest
        tt-produ.valor = tw-assist-pro.v-os-solest
        tt-produ.perc  = ((tw-assist-pro.os-solest / p-tot-ocor) * 100).
    if v-kont = 11
    then assign tt-produ.quant = tw-assist-pro.os-pencli
      tt-produ.valor = tw-assist-pro.v-os-pencli
      tt-produ.perc  = ((tw-assist-pro.os-pencli / p-tot-ocor) * 100).
    if v-kont = 12
    then assign tt-produ.quant = tw-assist-pro.os-penest
      tt-produ.valor = tw-assist-pro.v-os-penest
      tt-produ.perc  = ((tw-assist-pro.os-penest / p-tot-ocor) * 100).
    if v-kont = 13
    then assign tt-produ.quant = tw-assist-pro.os-penfornec
      tt-produ.valor = tw-assist-pro.v-os-penfornec
      tt-produ.perc  = ((tw-assist-pro.os-penfornec / p-tot-ocor) * 100).
    if v-kont = 14
        then assign tt-produ.quant = tw-assist-pro.os-penfabri
                    tt-produ.valor = tw-assist-pro.v-os-penfabri
                    tt-produ.perc  = 
                    ((tw-assist-pro.os-penfabri / p-tot-ocor) * 100).
end.
for each tt-produ:
    if tt-produ.quant = 0 then delete tt-produ.
end.    

l1: repeat:
    assign esqcom2[1] = "F4 - Retorna".
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    assign
        a-seeid = -1 a-recid = -1 a-seerec = ?
        esqpos1 = 1 esqpos2 = 1. 
    
    do i = 1 to 5:
        color display normal esqcom1[i] with frame f-com1.
    end.
     color display message esqcom2[1] with frame f-com2.
    hide frame f-linha2 no-pause.
    clear frame f-linha2 all.
     pause 0.
    {sklclstb.i  
        &color = with/cyan
        &file  =  tt-produ 
        &cfield = tt-produ.descricao
        &noncharacter = /* 
        &ofield = " tt-produ.quant tt-produ.perc tt-produ.valor "  
        &aftfnd1 = " "
        &where  = " tt-produ.sequencia = p-fabcod "
        &aftselect1 = " run aftselect.
                        a-seeid = -1.
                        if esqcom2[esqpos2] = ""  PRODUTO""
                        then do:
                            next l1.
                        end.
                        else  next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = "  " 
        &otherkeys1 = " run controle. "
        &locktype = " "
        &form   = " frame f-linha2 down "
    }   
    if keyfunction(lastkey) = "end-error"
    then DO:
         leave l1.       
    END.
end.

hide frame f1 no-pause.
hide frame f2 no-pause.
hide frame ff2 no-pause.
hide frame f-linha2 no-pause.

end procedure.



/***** CLASSES ****/
Procedure Pi-Classe.

def input parameter p-ocorre   as int.
def input parameter p-tot-ocor as int.

assign v-kont = p-ocorre.

assign esqcom1[1] = "PRODUTO"
       esqcom1[2] = "IMPRIME"
       esqcom1[3] = "".
disp 
string ("CLASSES EM ASSISTENCIA TECNICA ( " + descricao-ger[p-ocorre] + ")") 
@ v-descri with frame f1 1 down width 80  color message no-box no-label row 4.
                                                  
disp " " with frame f2 1 down width 80 color message no-box no-label row 20.                                                                   
/* Tela Classe */
for each tw-assist-cla :
  
    create tt-clase.
    assign  tt-clase.sequencia  = tw-assist-cla.clacod 
                tt-clase.descricao = tw-assist-cla.clanom.
    
    if v-kont = 1 
    then assign tt-clase.quant = tw-assist-cla.os-total
                tt-clase.valor = tw-assist-cla.v-os-total
                v-os-total     = tw-assist-cla.os-total
                tt-clase.perc  = ((tw-assist-cla.os-total / p-tot-ocor) * 100).
                                                  
    if v-kont = 2
    then assign tt-clase.quant = tw-assist-cla.os-cli
                tt-clase.valor = tw-assist-cla.v-os-cli
                tt-clase.perc  = ((tw-assist-cla.os-cli / p-tot-ocor)  * 100).
    if v-kont = 3 
    then assign tt-clase.quant = tw-assist-cla.os-est
                tt-clase.valor = tw-assist-cla.v-os-est
                tt-clase.perc  = ((tw-assist-cla.os-est / p-tot-ocor) * 100).
    if v-kont = 4 
    then assign tt-clase.quant = tw-assist-cla.os-pend
                tt-clase.valor = tw-assist-cla.v-os-pen
                tt-clase.perc  = ((tw-assist-cla.os-pend / p-tot-ocor) * 100).
    if v-kont = 5 
    then assign tt-clase.quant = tw-assist-cla.os-sol
            tt-clase.valor = tw-assist-cla.v-os-sol
            tt-clase.perc  = ((tw-assist-cla.os-sol / p-tot-ocor) 
                               * 100).
    if v-kont = 6 
    then assign tt-clase.quant = tw-assist-cla.os-15
        tt-clase.valor = tw-assist-cla.v-os-15
        tt-clase.perc  = ((tw-assist-cla.os-15 / p-tot-ocor) * 100).
    if v-kont = 7 
    then assign tt-clase.quant = tw-assist-cla.os-20
        tt-clase.valor = tw-assist-cla.v-os-20
        tt-clase.perc  = ((tw-assist-cla.os-20 / p-tot-ocor) * 100).
    if v-kont = 8 
    then assign tt-clase.quant = tw-assist-cla.os-30
        tt-clase.valor = tw-assist-cla.v-os-30
        tt-clase.perc  = ((tw-assist-cla.os-30 / p-tot-ocor) * 100).
    if v-kont = 9 
    then assign tt-clase.quant = tw-assist-cla.os-solcli
        tt-clase.valor = tw-assist-cla.v-os-solcli
        tt-clase.perc  = ((tw-assist-cla.os-solcli /  p-tot-ocor) * 100).
    if v-kont = 10 
    then assign tt-clase.quant = tw-assist-cla.os-solest
        tt-clase.valor = tw-assist-cla.v-os-solest
        tt-clase.perc  = ((tw-assist-cla.os-solest /  p-tot-ocor ) * 100).
    if v-kont = 11
    then assign tt-clase.quant = tw-assist-cla.os-pencli
      tt-clase.valor = tw-assist-cla.v-os-pencli
      tt-clase.perc  = ((tw-assist-cla.os-pencli /  p-tot-ocor ) * 100). 
    if v-kont = 12
    then assign tt-clase.quant = tw-assist-cla.os-penest
      tt-clase.valor = tw-assist-cla.v-os-penest
      tt-clase.perc  = ((tw-assist-cla.os-penest / p-tot-ocor) * 100).
    if v-kont = 13
    then assign tt-clase.quant = tw-assist-cla.os-penfornec
      tt-clase.valor = tw-assist-cla.v-os-penfornec
      tt-clase.perc  = ((tw-assist-cla.os-penfornec /  p-tot-ocor) * 100).
    if v-kont = 14
        then assign tt-clase.quant = tw-assist-cla.os-penfabri
          tt-clase.valor = tw-assist-cla.v-os-penfabri
          tt-clase.perc  = ((tw-assist-cla.os-penfabri /  p-tot-ocor) * 100).
end.
for each tt-clase:
    if tt-clase.quant = 0 then delete tt-clase.
end.


for each tt-produ:
  delete tt-produ.
end.


l1: repeat:
    assign esqcom2[1] = "F4 - Retorna".
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    assign
        a-seeid = -1 a-recid = -1 a-seerec = ?
        esqpos1 = 1 esqpos2 = 1. 
    hide frame f-linha1 no-pause.
    clear frame f-linha1 all.
    pause 0.
    {sklclstb.i  
        &color = with/cyan
        &file  =  tt-clase 
        &cfield = tt-clase.descricao
        &noncharacter = /* 
        &ofield = " tt-clase.quant tt-clase.perc tt-clase.valor "  
        &aftfnd1 = " "
        &where  = " true "
        &aftselect1 = " run aftselect.
                        a-seeid = -1.
                        if esqcom2[esqpos2] = ""  PRODUTO""
                        then do:
                            next l1.
                        end.
                        else next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = "  " 
        &otherkeys1 = " run controle. "
        &locktype = " "
        &form   = " frame f-linha1 down "
    }   
    if keyfunction(lastkey) = "end-error"
    then DO:
        leave l1.       
    END.
end.
hide frame f1 no-pause.
hide frame f2 no-pause.
hide frame ff2 no-pause.
hide frame f-linha1 no-pause.

end procedure.


/***** FABRICANTES ****/
Procedure Pi-Fabricante.

def input parameter p-ocorre   as int.
def input parameter p-tot-ocor as int.

assign v-kont = p-ocorre.

assign esqcom1[1] = "PRODUTO"
       esqcom1[2] = "IMPRIME"
       esqcom1[3] = "".
disp string 
        ("FABRICANTES EM ASSISTENCIA TECNICA ( " + descricao-ger[p-ocorre] +  ")") 
        @ v-descri with frame f1 1 
    down width 80 color message no-box no-label row 4.
                                                  
disp " " with frame f2 1 down width 80 color message no-box no-label row 20.                                                                   
                                                                

/* Tela Fabricante */
for each tw-assist-fabri :
  
    create tt-fabri.
    assign  tt-fabri.sequencia = tw-assist-fabri.fabcod 
            tt-fabri.descricao = tw-assist-fabri.fabnom.
    
    if v-kont = 1 
    then assign tt-fabri.quant = tw-assist-fabri.os-total
              tt-fabri.valor = tw-assist-fabri.v-os-total
              v-os-total     = tw-assist-fabri.os-total
              tt-fabri.perc  = ((tw-assist-fabri.os-total / p-tot-ocor) * 100).
                                                  
    if v-kont = 2
    then assign tt-fabri.quant = tw-assist-fabri.os-cli
                tt-fabri.valor = tw-assist-fabri.v-os-cli
                tt-fabri.perc  = ((tw-assist-fabri.os-cli / p-tot-ocor)  * 100).
    if v-kont = 3 
    then assign tt-fabri.quant = tw-assist-fabri.os-est
                tt-fabri.valor = tw-assist-fabri.v-os-est
                tt-fabri.perc  = ((tw-assist-fabri.os-est / p-tot-ocor) * 100).
    if v-kont = 4 
    then assign tt-fabri.quant = tw-assist-fabri.os-pend
                tt-fabri.valor = tw-assist-fabri.v-os-pen
                tt-fabri.perc  = ((tw-assist-fabri.os-pend / p-tot-ocor) * 100).
    if v-kont = 5 
    then assign tt-fabri.quant = tw-assist-fabri.os-sol
            tt-fabri.valor = tw-assist-fabri.v-os-sol
            tt-fabri.perc  = ((tw-assist-fabri.os-sol / p-tot-ocor) 
                               * 100).
    if v-kont = 6 
    then assign tt-fabri.quant = tw-assist-fabri.os-15
      tt-fabri.valor = tw-assist-fabri.v-os-15
      tt-fabri.perc  = ((tw-assist-fabri.os-15 / p-tot-ocor) * 100).
    if v-kont = 7 
    then assign tt-fabri.quant = tw-assist-fabri.os-20
      tt-fabri.valor = tw-assist-fabri.v-os-20
      tt-fabri.perc  = ((tw-assist-fabri.os-20 / p-tot-ocor) * 100).
    if v-kont = 8 
    then assign tt-fabri.quant = tw-assist-fabri.os-30
      tt-fabri.valor = tw-assist-fabri.v-os-30
      tt-fabri.perc  = ((tw-assist-fabri.os-30 / p-tot-ocor) * 100).
    if v-kont = 9 
    then assign tt-fabri.quant = tw-assist-fabri.os-solcli
      tt-fabri.valor = tw-assist-fabri.v-os-solcli
      tt-fabri.perc  = ((tw-assist-fabri.os-solcli /  p-tot-ocor) * 100).
    if v-kont = 10 
    then assign tt-fabri.quant = tw-assist-fabri.os-solest
      tt-fabri.valor = tw-assist-fabri.v-os-solest
      tt-fabri.perc  = ((tw-assist-fabri.os-solest /  p-tot-ocor ) * 100).
    if v-kont = 11
    then assign tt-fabri.quant = tw-assist-fabri.os-pencli
      tt-fabri.valor = tw-assist-fabri.v-os-pencli
      tt-fabri.perc  = ((tw-assist-fabri.os-pencli /  p-tot-ocor ) * 100). 
    if v-kont = 12
    then assign tt-fabri.quant = tw-assist-fabri.os-penest
      tt-fabri.valor = tw-assist-fabri.v-os-penest
      tt-fabri.perc  = ((tw-assist-fabri.os-penest / p-tot-ocor) * 100).
    if v-kont = 13
    then assign tt-fabri.quant = tw-assist-fabri.os-penfornec
      tt-fabri.valor = tw-assist-fabri.v-os-penfornec
      tt-fabri.perc  = ((tw-assist-fabri.os-penfornec /  p-tot-ocor) * 100).
    if v-kont = 14
    then assign tt-fabri.quant = tw-assist-fabri.os-penfabri
      tt-fabri.valor = tw-assist-fabri.v-os-penfabri
      tt-fabri.perc  = ((tw-assist-fabri.os-penfabri /  p-tot-ocor) * 100).
end.
for each tt-fabri:
    if tt-fabri.quant = 0 then delete tt-fabri.
end.


for each tt-produ:
  delete tt-produ.
end.


l1: repeat:
    assign esqcom2[1] = "F4 - Retorna".
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
     assign
        a-seeid = -1 a-recid = -1 a-seerec = ?
        esqpos1 = 1 esqpos2 = 1. 
        do i = 2 to 5:
        color display normal esqcom1[i] with frame f-com1.
    end.
    color display message esqcom1[1] with frame f-com1.
    color display normal esqcom2[1] with frame f-com2.
    pause 0.
    hide frame f-linha1 no-pause.
    clear frame f-linha1 all.
    pause 0.
    {sklclstb.i  
        &color = with/cyan
        &file  =  tt-fabri 
        &cfield = tt-fabri.descricao
        &noncharacter = /* 
        &ofield = " tt-fabri.quant tt-fabri.perc tt-fabri.valor "  
        &aftfnd1 = " "
        &where  = " true "
        &aftselect1 = " run aftselect.
                        a-seeid = -1.
                        if esqcom2[esqpos2] = ""PRODUTO""
                        then do:
                            next l1.
                        end.
                        else next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = "  " 
        &otherkeys1 = " run controle. "
        &locktype = " "
        &form   = " frame f-linha11 12 down"
    }   
    if keyfunction(lastkey) = "end-error"
    then DO:
        leave l1.       
    END.
end.
hide frame f1 no-pause.
hide frame f2 no-pause.
hide frame ff2 no-pause.
hide frame f-linha11 no-pause.

end procedure.



procedure relatorio:

    def var varquivo as char.

/***
    if opsys = "unix" 
    then do:
        find first impress where impress.codimp = setbcod no-lock no-error. 
        if avail impress
        then do:
             run acha_imp.p (input recid(impress), 
                             output recimp).
             find impress where recid(impress) = recimp no-lock no-error.
             assign fila = string(impress.dfimp).
        end.
***/
        /* mdadmcab.i */
        varquivo = "/admcom/relat/relass_a" + string(time).
        {mdad.i 
            &Saida     = "value(varquivo)"
            &Page-Size = "63"
            &Cond-Var  = "120" 
            &Page-Line = "66" 
            &Nom-Rel   = ""relass_a""
            &Nom-Sis   = """SISTEMA ADMINISTRATIVO"""
            &Tit-Rel   = """RESUMO DE ASSISTENCIA TECNICA"" +  
                         "" FILIAL ""  + string(p-etbcod) +
                         "" Data: "" + string(p-dti) + "" A "" + string(p-dtf)"             &Width     = "120"
            &Form      = "frame f-cabcab"}
/***
    end.                    
    else do:
        assign fila = "" 
        varquivo = "l:\relat\aud" + string(time).
        {mdad_l.i
            &Saida     = "value(varquivo)"
            &Page-Size = "0"
            &Cond-Var  = "100"
            &Page-Line = "66"
            &Nom-Rel   = ""asstec""
            &Nom-Sis   = """SISTEMA ADMINISTRATIVO  SAO JERONIMO"""
            &Tit-Rel   = """RESUMO DE ASSISTENCIA TECNICA "" +
                        "" Data: "" + string(p-dti) + "" A "" +
                            string(p-dtf)"
            &Width     = "100"
            &Form      = "frame f-cabcab1"}
     end.
***/
     for each tt-geral :
        disp  tt-geral.descricao column-label "Descricao"
              tt-geral.quant     column-label "Quant."
              tt-geral.per       column-label "% RefQtde"
              tt-geral.valor     column-label "Valor" 
              with frame fimp centered down.
       down with frame fimp.
     end.

    output close.
    if opsys = "UNIX"
    then do:
        run visurel.p (input varquivo, input "").
        /*** os-command silent lpr value(fila + " " + varquivo). ***/
    end.
    else do:
        {mrod.i}
    end.
    
end procedure.

