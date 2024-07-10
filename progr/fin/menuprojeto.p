/* 18022022 helio carteira FIDC FINANCEIRA */

{admcab.i}

def var menp1   as char format "x(20)" extent 4   
        init  ["                    ",
               "    Posicao ",
               "   do Cliente  ",
               ""].
              
def var prop1  as char init "cob/hiscli2compor.p".

def var menp2   as char format "x(20)" extent 4   
        init  ["                    ",
               "   Consulta  ",
               "   Contrato",
               ""].
def var prop2   as char init "conco_v1701.p".

def var menp3   as char format "x(20)" extent 4   
        init  ["                    ",
               "   Consulta  ",
               "   Movimentos",
               ""].
def var prop3   as char init "dpdv/pdvcons.p".

/* retirado em 17022022 - helio - colocado o projeto iepro no lugar 
*def var menp4   as char format "x(20)" extent 4   
*        init  ["                    ",
*               "   Posicao da",
*               "   Carteira  ",
*               "               ",
*               ""].
*              
*def var prop4  as char init "fin/telaposcartini.p".
*/
def var menp4   as char format "x(20)" extent 4   
        init  [
               "   Gestao de",
               "   protestos  ",
               "     iepro    ",
               ""].
              
def var prop4  as char init "iep/tfilini.p".


def var menp5   as char format "x(20)" extent 4 
        init  ["                    ",
               "     Baixas ",
               "     Crediario ",
               ""].
def var prop5   as char init "fin/cmmovcai.p".

def var menp6   as char format "x(20)" extent 4   
        init  ["                    ",
               "     Novacao",
               "   de Dividas ",
               ""].
              
def var prop6  as char init "cob/hiscli2compor.p".

def var menp7   as char format "x(20)" extent 4   
        init  ["                    ",
               "   Seguros",
               "   ",
               ""].
              
def var prop7  as char init "fin/cdvndseguro.p".

def var menp8   as char format "x(20)" extent 4   
        init  ["                    ",
               "   Resumo de",
               "   Operacoes ",
               ""].
              
def var prop8  as char init "fin/telapdvdocini.p".

def var menp9   as char format "x(20)" extent 4   
        init  ["                    ",
               "   Higienizacao ",
               "   de CPFs  ",
               ""].
              
def var prop9  as char init "fin/cdhigieniza_v2003.p".

def var menp10   as char format "x(20)" extent 4   
        init  [
               "   Integracao   ",
               "     SiCred  ",
               "   Financeira ",
               ""].
              
def var prop10  as char init "fin/opesicini.p".


def var menp11   as char format "x(20)" extent 4 
        init  ["                    ",
               "   Parametros   ",
               "    ",
               ""].

def var prop11  as char init "fin/parametros.p".
              
def var menp12   as char format "x(20)" extent 4   
        init  ["                    ",
               "   Relatorios   ",
               "   ",
               ""].
              
def var prop12  as char init "fin/relatorios.p".

def var menp13   as char format "x(20)" extent 4 init  
              ["",
               "  Busca Pagamentos  ",
               "   Financeira",
               ""].
def var prop13  as char init "fin/gerarqpgfin-ini.p".

def var menp14   as char format "x(20)" extent 4 init  
              [
               "   Integracao   ",
               "     FIDC  ",
               "   Financeira ",
               ""].
def var prop14  as char init "fin/fidcmenu.p".
def var menp15   as char format "x(20)" extent 5   
        init  ["                    ",
               ""].
              
def var prop15  as char init "".

def var menp16   as char format "x(20)" extent 4 init  
              ["",
               "        - ",
               
               "  ",
               ""].
def var prop16  as char init "".

              
              
              


form menp1[1] skip menp1[2] skip menp1[3] skip menp1[4] 
     with frame p1  row 3  no-labels 1 column
    no-box.
form  menp1[1] skip menp1[2] skip menp1[3] skip menp1[4] 
    with frame c1  row 3  no-labels 1 column
    no-box
    color messages.

form menp2[1] skip menp2[2] skip menp2[3] skip menp2[4] 
     with frame p2  row 3  no-labels 1 column col 21
    no-box.
form  menp2[1] skip menp2[2] skip menp2[3] skip menp2[4]
    with frame c2  row 3  no-labels 1 column col 21
    no-box
    color messages.

form menp3[1] skip menp3[2] skip menp3[3] skip menp3[4] 
     with frame p3  row 3  no-labels 1 column col 41
    no-box.
form  menp3[1] skip menp3[2] skip menp3[3] skip menp3[4] 
    with frame c3  row 3  no-labels 1 column col 41
    no-box
    color messages.
    
form menp4[1] skip menp4[2] skip menp4[3] skip menp4[4] 
     with frame p4  row 3  no-labels 1 column col 61
    no-box.
form  menp4[1] skip menp4[2] skip menp4[3] skip menp4[4] 
    with frame c4  row 3  no-labels 1 column col 61
    no-box
    color messages.

form menp5[1] skip menp5[2] skip menp5[3] skip menp5[4] 
     with frame p5  row 8  no-labels 1 column
    no-box.
form  menp5[1] skip menp5[2] skip menp5[3] skip menp5[4] 
    with frame c5  row 8  no-labels 1 column
    no-box
    color messages.

form menp6[1] skip menp6[2] skip menp6[3] skip menp6[4] 
     with frame p6  row 8  no-labels 1 column col 21
    no-box.
form  menp6[1] skip menp6[2] skip menp6[3] skip menp6[4] 
    with frame c6  row 8  no-labels 1 column col 21
    no-box
    color messages.

form menp7[1] skip menp7[2] skip menp7[3] skip menp7[4] 
     with frame p7  row 8  no-labels 1 column col 41
    no-box.
form  menp7[1] skip menp7[2] skip menp7[3] skip menp7[4] 
    with frame c7  row 8  no-labels 1 column col 41
    no-box
    color messages.
    
form menp8[1] skip menp8[2] skip menp8[3] skip menp8[4] 
     with frame p8  row 8  no-labels 1 column col 61
    no-box.
form  menp8[1] skip menp8[2] skip menp8[3] skip menp8[4] 
    with frame c8  row 8  no-labels 1 column col 61
    no-box
    color messages.
 

    
form menp9[1] skip menp9[2] skip menp9[3] skip menp9[4] 
     with frame p9  row 13  no-labels 1 column
    no-box.
form  menp9[1] skip menp9[2] skip menp9[3] skip menp9[4] 
    with frame c9  row 13  no-labels 1 column
    no-box
    color messages.

form menp10[1] skip menp10[2] skip menp10[3] skip menp10[4] 
     with frame p10  row 13  no-labels 1 column col 21
    no-box.
form  menp10[1] skip menp10[2] skip menp10[3] skip menp10[4] 
    with frame c10  row 13  no-labels 1 column col 21
    no-box
    color messages.

form menp11[1] skip menp11[2] skip menp11[3] skip menp11[4]
     with frame p11  row 13  no-labels 1 column col 41
    no-box.
form  menp11[1] skip menp11[2] skip menp11[3] skip menp11[4] 
    with frame c11  row 13  no-labels 1 column col 41
    no-box
    color messages.
    
form menp12[1] skip menp12[2] skip menp12[3] skip menp12[4] 
     with frame p12  row 13  no-labels 1 column col 61
    no-box.
form  menp12[1] skip menp12[2] skip menp12[3] skip menp12[4] 
    with frame c12  row 13  no-labels 1 column col 61
    no-box
    color messages.
 

 
 form menp13[1] skip menp13[2] skip menp13[3] skip menp13[4] 
     with frame p13  row 18  no-labels 1 column
    no-box.
form  menp13[1] skip menp13[2] skip menp13[3] skip menp13[4] 
    with frame c13  row 18  no-labels 1 column
    no-box
    color messages.

form menp14[1] skip menp14[2] skip menp14[3] skip menp14[4] 
     with frame p14  row 18  no-labels 1 column col 21
    no-box.
form  menp14[1] skip menp14[2] skip menp14[3] skip menp14[4] 
    with frame c14  row 18  no-labels 1 column col 21
    no-box
    color messages.

form menp15[1] skip menp15[2] skip menp15[3] skip menp15[4]
     with frame p15  row 18  no-labels 1 column col 41
    no-box.
form  menp15[1] skip menp15[2] skip menp15[3] skip menp15[4] 
    with frame c15  row 18  no-labels 1 column col 41
    no-box
    color messages.
    
form menp16[1] skip menp16[2] skip menp16[3] skip menp16[4] 
     with frame p16  row 18  no-labels 1 column col 61
    no-box.
form  menp16[1] skip menp16[2] skip menp16[3] skip menp16[4] 
    with frame c16  row 18  no-labels 1 column col 61
    no-box
    color messages.
 
 
    

def var vpos as int.
vpos = 1.

disp menp1 with frame c1.
disp menp2 with frame p2.
disp menp3 with frame p3.
disp menp4 with frame p4.

disp menp5 with frame p5.
disp menp6 with frame p6.
disp menp7 with frame p7.
disp menp8 with frame p8.

disp menp9 with frame p9.
disp menp10 with frame p10.
disp menp11 with frame p11.
disp menp12 with frame p12.

disp menp13 with frame p13.
disp menp14 with frame p14.
disp menp15 with frame p15.
disp menp16 with frame p16.


repeat:
    hide message no-pause.
    readkey.
    if keyfunction(lastkey) = "end-error"
    then do:
        hide all no-pause.
        leave.
    end.    
    pause 0.
    if keyfunction(lastkey) = "return"
    then do:
        hide all no-pause.
        if vpos = 5
        then do:
            def var vetbcod as int.
            vetbcod = setbcod.
/*          message "Filial" update setbcod . */
            run value(prop5) (input "EXT,99").
            setbcod = vetbcod.
            
        end.
        if vpos = 2
         then do:
            run value(prop2) ("MENU").
         end.
        
        if vpos = 3
         then do:
            run value(prop3).
         end.
        if vpos = 4
         then do:
            run value(prop4).
         end.
        if vpos = 1
         then do:
            run value(prop1) (?,"").
         end.
        if vpos = 6
         then do:
            run value(prop6) (?,"NOVACAO").
         end.
         
        if vpos = 7
         then do:
            run value(prop7) ("").
         end.
        if vpos = 8         
        then do:
            run value(prop8).
         end.
        if vpos = 9         
        then do:
            run value(prop9).
         end.
        if vpos = 10         
        then do:
            run value(prop10).
         end.
        if vpos = 11         
        then do:
            run value(prop11).
         end.
        if vpos = 12         
        then do:
            run value(prop12).
         end.
         if vpos = 13
         then run value(prop13).
        if vpos = 14         
        then do:
            run value(prop14).
         end.
         
         

         
         
        disp menp1 with frame p1.
        disp menp2 with frame p2.
        disp menp3 with frame p3.
        disp menp4 with frame p4.
        disp menp5 with frame p5.
        disp menp6 with frame p6.
        disp menp7 with frame p7.
        disp menp8 with frame p8.
        disp menp9 with frame p9.
        disp menp10 with frame p10.
        disp menp11 with frame p11.
        disp menp12 with frame p12.
        
        disp menp13 with frame p13.
        disp menp14 with frame p14.
        disp menp15 with frame p15.
        disp menp16 with frame p16.

    end.
    
    if vpos = 1
    then do:
        hide frame c1 no-pause.
        disp    menp1 
        with frame p1.
    end.
    if vpos = 2
    then do:
        hide frame c2 no-pause.
        disp    menp2 
        with frame p2.
    end.
    if vpos = 3
    then do:
        hide frame c3 no-pause.
        disp    menp3 
        with frame p3.
    end.
    if vpos = 4
    then do:
        hide frame c4 no-pause.
        disp    menp4 
        with frame p4.
    end.
    
    if vpos = 5
    then do:
        hide frame c5 no-pause.
        disp    menp5 
        with frame p5.
    end.
    if vpos = 6
    then do:
        hide frame c6 no-pause.
        disp    menp6 
        with frame p6.
    end.
    if vpos = 7
    then do:
        hide frame c7 no-pause.
        disp    menp7 
        with frame p7.
    end.
    if vpos = 8
    then do:
        hide frame c8 no-pause.
        disp    menp8 
        with frame p8.
    end.
    
    if vpos = 9
    then do:
        hide frame c9 no-pause.
        disp    menp9 
        with frame p9.
    end.
    if vpos = 10
    then do:
        hide frame c10 no-pause.
        disp    menp10 
        with frame p10.
    end.
    if vpos = 11
    then do:
        hide frame c11 no-pause.
        disp    menp11 
        with frame p11.
    end.
    if vpos = 12
    then do:
        hide frame c12 no-pause.
        disp    menp12 
        with frame p12.
    end.
    
    if vpos = 13
    then do:
        hide frame c13 no-pause.
        disp    menp13 
        with frame p13.
    end.
    if vpos = 14
    then do:
        hide frame c14 no-pause.
        disp    menp14 
        with frame p14.
    end.
    if vpos = 15
    then do:
        hide frame c15 no-pause.
        disp    menp15 
        with frame p15.
    end.
    if vpos = 16
    then do:
        hide frame c16 no-pause.
        disp    menp16 
        with frame p16.
    end.

    
    if keyfunction(lastkey) = "cursor-right"
    then do:
        vpos = vpos + 1.
        if vpos > 16
        then vpos = vpos - 1.
    end.     
    if keyfunction(lastkey) = "cursor-left"
    then do:
        vpos = vpos - 1.
        if vpos <= 0 then vpos = vpos + 1.
    end.     
    if keyfunction(lastkey) = "cursor-down"
    then do:
        vpos = vpos + 4.
        if vpos < 0
        then vpos = vpos - 4.
        if vpos > 16
        then vpos = vpos - 4.
    end.    
    if keyfunction(lastkey) = "cursor-up"
    then do:
        vpos = vpos - 4.
        if vpos <= 0
        then vpos = vpos + 4.
        if vpos > 16
        then vpos = vpos + 4.
    end.    
    
    if vpos = 1 
    then do: 
        hide frame p1 no-pause.
        disp    menp1 
        with frame c1.
    end.
    if vpos = 2 
    then do: 
        hide frame p2 no-pause.
        disp    menp2 
        with frame c2.
    end.
    if vpos = 3 
    then do: 
        hide frame p3 no-pause.
        disp    menp3 
        with frame c3.
    end.
    if vpos = 4 
    then do: 
        hide frame p4 no-pause.
        disp    menp4 
        with frame c4.
    end.
    
    if vpos = 5
    then do: 
        hide frame p5 no-pause.
        disp    menp5 
        with frame c5.
    end.
    if vpos = 6 
    then do: 
        hide frame p6 no-pause.
        disp    menp6 
        with frame c6.
    end.
    if vpos = 7 
    then do: 
        hide frame p7 no-pause.
        disp    menp7 
        with frame c7.
    end.
    if vpos = 8 
    then do: 
        hide frame p8 no-pause.
        disp    menp8 
        with frame c8.
    end.
    if vpos = 9
    then do: 
        hide frame p9 no-pause.
        disp    menp9 
        with frame c9.
    end.
    if vpos = 10 
    then do: 
        hide frame p10 no-pause.
        disp    menp10 
        with frame c10.
    end.
    if vpos = 11 
    then do: 
        hide frame p11 no-pause.
        disp    menp11 
        with frame c11.
    end.
    if vpos = 12 
    then do: 
        hide frame p12 no-pause.
        disp    menp12 
        with frame c12.
    end.
    
    if vpos = 13 
    then do: 
        hide frame p13 no-pause.
        disp    menp13 
        with frame c13.
    end.
    if vpos = 14 
    then do: 
        hide frame p14 no-pause.
        disp    menp14 
        with frame c14.
    end.
    if vpos = 15 
    then do: 
        hide frame p15 no-pause.
        disp    menp15 
        with frame c15.
    end.
    if vpos = 16 
    then do: 
        hide frame p16 no-pause.
        disp    menp16 
        with frame c16.
    end.
    
end.    

