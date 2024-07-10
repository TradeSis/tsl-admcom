/**
connect ninja -H 10.2.0.29 -S 60002 -N tcp.
connect sensei -H db2 -S ssensei -N tcp.
connect nissei -H 10.2.0.29 -S 60001 -N tcp.
**/

{admcab.i}

def var vtipo1 as char.
def var vtipo2 as char.
def var vetbcod like estab.etbcod.
def var vdata as date.
def shared var vdti as date.
def shared var vdtf as date.

form vetbcod at 7 label "Filial"
     estab.etbnom no-label
     vdti at 1 label "Data inicial"
     vdtf label "Data final"
     with frame f1 width 80 side-label.
     
disp vetbcod vdti vdtf with frame f1.
update vetbcod at 7 label "Filial"
       with frame f1 .
if vetbcod > 0
then do:
    find estab where estab.etbcod = vetbcod no-lock no-error.
    if avail estab
    then disp estab.etbnom no-label with frame f1.
    else undo.
end.
else disp "Todas as filiais" @ estab.etbnom with frame f1.
       
update vdti at 1 label "Data inicial"
       vdtf label "Data final"
       with frame f1 side-label.


def temp-table tt-rel
    field ordem as int
    field campo1 as char format "x(60)" 
    field campo2 as char
    field campo3 as char
    field valor  as dec  format "->>>,>>>,>>9.99"
    field soma   as log
    . 

def temp-table tt-valores no-undo
    field t1 as char format "x(15)"
    field t2 as char format "x(15)"
    field t3 as char format "x(15)"
    field t4 as char format "x(15)" 
    field t5 as char format "x(15)"  
    field t6 as char format "x(15)"
    field t7 as char format "x(15)"
    field t8 as char format "x(15)"
    field t9 as char format "x(15)"
    field t0 as char format "x(15)"
    field valor as dec format "->>>,>>>,>>9.99" 
    index i1 
    t1 t2 t3 t4 t5 t6 t7 t8 t9 t0
    .

do vdata = vdti to vdtf:
    for each estab where (if vetbcod > 0 then estab.etbcod = vetbcod
                          else true) no-lock,
        each opctbval where opctbval.etbcod = estab.etbcod and
                        opctbval.datref = vdata and
                        opctbval.t9 = "" and
                        opctbval.t0 = ""
                     no-lock.

        /*if opctbval.t2 begins "CP"
        then next.*/
        
        find first tt-valores where
               tt-valores.t1 = opctbval.t1 and
               tt-valores.t2 = opctbval.t2 and
               tt-valores.t3 = opctbval.t3 and
               tt-valores.t4 = opctbval.t4 and
               tt-valores.t5 = opctbval.t5 and
               tt-valores.t6 = opctbval.t6 and
               tt-valores.t7 = opctbval.t7 and
               tt-valores.t8 = opctbval.t8 and
               tt-valores.t9 = opctbval.t9 and
               tt-valores.t0 = opctbval.t0 
                               no-error.
        if not avail tt-valores
        then do:
            create tt-valores.
            assign
                tt-valores.t1 = opctbval.t1
                tt-valores.t2 = opctbval.t2
                tt-valores.t3 = opctbval.t3
                tt-valores.t4 = opctbval.t4
                tt-valores.t5 = opctbval.t5
                tt-valores.t6 = opctbval.t6
                tt-valores.t7 = opctbval.t7
                tt-valores.t8 = opctbval.t8
                tt-valores.t9 = opctbval.t9
                tt-valores.t0 = opctbval.t0
                .
        end. 
        tt-valores.valor = tt-valores.valor + opctbval.valor.
    end.
end. 
def var vpassa as char.
def var vordem as int.
vtipo1 = "VENDA".
vtipo2 = "A-VISTA".
    
for each tt-valores where tt-valores.t1 = vtipo1 and
                          tt-valores.t2 = vtipo2 and
                          tt-valores.t3 = "VVI"  /*and
                          tt-valores.t4 <> ""      */
                            no-lock break by tt-valores.t1 
                                    by tt-valores.t2 
                                    by tt-valores.t3 
                                    by tt-valores.t4 
                                    by tt-valores.t5 
                                    by tt-valores.t6 
                                    by tt-valores.t7.
      

        vpassa = tt-valores.t1 + tt-valores.t2 + 
                    tt-valores.t3 + tt-valores.t4 + tt-valores.t5
                    + tt-valores.t7.
        if first-of(tt-valores.t3)
        then run cria-ttrel(vordem, 
                            tt-valores.t1 + "-" + tt-valores.t2, 
                            vpassa,
                            tt-valores.valor,
                            no).
        else if first-of(tt-valores.t4)
        then do:
            
            run cria-ttrel(vordem, 
                            "    " + tt-valores.t4,
                            vpassa,
                             tt-valores.valor,
                             no).
        end.
        else if first-of(tt-valores.t5)
        then run cria-ttrel(vordem, 
                            "        " + tt-valores.t5,
                            vpassa,
                            tt-valores.valor,
                            no).
        else if first-of(tt-valores.t7)
        then run cria-ttrel(vordem, 
                            "            " + tt-valores.t7,
                            vpassa,
                            tt-valores.valor,
                            no).
end.

vtipo1 = "VENDA".
vtipo2 = "A-PRAZO".
    
for each tt-valores where tt-valores.t1 = vtipo1 and
                          tt-valores.t2 = vtipo2 
                            no-lock break by tt-valores.t1 
                                    by tt-valores.t2 
                                    by tt-valores.t3 
                                    by tt-valores.t4 
                                    by tt-valores.t5 
                                    by tt-valores.t6 
                                    by tt-valores.t7.

        if first-of(tt-valores.t3)
        then do:
            
            run cria-ttrel(vordem, 
                            tt-valores.t1 + "-" + tt-valores.t2,
                            tt-valores.t1 + tt-valores.t2 ,
                            tt-valores.valor,
                            no).

            if tt-valores.t3 = "CP0" or tt-valores.t3 = "CP1"
            then do:
                vpassa = tt-valores.t1 + tt-valores.t2 + "EMPRESTIMO" +
                            tt-valores.t4 + tt-valores.t5.
                run cria-ttrel(vordem, 
                                "    EMPRESTIMO", 
                                vpassa,
                                tt-valores.valor,
                                no).
            end.
            ELSE do:
                vpassa = tt-valores.t1 + tt-valores.t2 + "CREDIARIO" +
                                            tt-valores.t4 + tt-valores.t5.
                                            
                run cria-ttrel(vordem, 
                                "    CREDIARIO", 
                                vpassa,
                                tt-valores.valor,
                                no).
            end.
        end.    
        else if first-of(tt-valores.t4)
        then run cria-ttrel(vordem, 
                            "        " + tt-valores.t4, 
                            vpassa,
                            tt-valores.valor,
                            no).
        else if first-of(tt-valores.t5)
        then run cria-ttrel(vordem, 
                            "            " + tt-valores.t5,
                            vpassa,
                            tt-valores.valor,
                            no).
end.

vtipo1 = "CONTRATO".
vtipo2 = "A-PRAZO".
    
for each tt-valores where tt-valores.t1 = vtipo1 and
                          tt-valores.t2 = vtipo2 
                            no-lock break by tt-valores.t1 
                                    by tt-valores.t2 
                                    by tt-valores.t3 
                                    by tt-valores.t4 
                                    by tt-valores.t5 
                                    by tt-valores.t6 
                                    by tt-valores.t7
                                    by tt-valores.t8.

        vpassa = tt-valores.t1 + tt-valores.t2 + 
                tt-valores.t3 +
                tt-valores.t4 + tt-valores.t5
                 + tt-valores.t6 + tt-valores.t7 + tt-valores.t8.
        
        if first-of(tt-valores.t2)
        then do:
            run cria-ttrel(vordem, 
                           tt-valores.t1 + "-" + tt-valores.t2 ,
                           tt-valores.t1 + tt-valores.t2,
                           tt-valores.valor,
                           no).
        end.
        else if first-of(tt-valores.t3)
        then do:
            /*run cria-ttrel(vordem, 
                           tt-valores.t1 + "-" + tt-valores.t2 ,
                           tt-valores.t1 + tt-valores.t2,
                           tt-valores.valor,
                           no).
            */
            /**
            if tt-valores.t3 = "CP0" or tt-valores.t3 = "CP1" or
               tt-valores.t3 = "CPN" 
            then run cria-ttrel(vordem, 
                                "    EMPRESTIMO", 
                                vpassa,
                                tt-valores.valor,
                                no).
            ELSE run cria-ttrel(vordem, 
                                "    CLIENTES", 
                                vpassa,
                                tt-valores.valor,
                                no).
            **/

            run cria-ttrel(vordem, 
                                "    " + tt-valores.t3, 
                                vpassa,
                                tt-valores.valor,
                                no).
 
        end.
        else if first-of(tt-valores.t4)
        then run cria-ttrel(vordem, 
                            "        " + tt-valores.t4, 
                            vpassa,
                            tt-valores.valor,
                            no).
        else if first-of(tt-valores.t5)
        then run cria-ttrel(vordem, 
                            "            " + tt-valores.t5,
                            vpassa,
                            tt-valores.valor,
                            no).
        else if first-of(tt-valores.t6)
        then run cria-ttrel(vordem, 
                            "                " + tt-valores.t6,
                            vpassa,
                            tt-valores.valor,
                            no).
        else if first-of(tt-valores.t7)
        then run cria-ttrel(vordem, 
                            "                    " + tt-valores.t7,
                            vpassa,
                            tt-valores.valor,
                            no).
        else if first-of(tt-valores.t8)
        then run cria-ttrel(vordem, 
                            "                        " + tt-valores.t8,
                            vpassa,
                            tt-valores.valor,
                            no).
end.

vordem = 0.
vtipo1 = "RECEBIMENTO".
vtipo2 = "".
    
for each tt-valores where tt-valores.t1 = vtipo1 /*and
                          tt-valores.t2 <> vtipo2  */
                            no-lock break by tt-valores.t1 
                                    by tt-valores.t2 
                                    by tt-valores.t3 
                                    by tt-valores.t4 
                                    by tt-valores.t5 
                                    by tt-valores.t6. 



        vpassa = tt-valores.t1 + tt-valores.t2 + tt-valores.t4 + tt-valores.t5
                 + tt-valores.t6 + tt-valores.t7 + tt-valores.t8.
        
        if first-of(tt-valores.t1)
        then do:
            vpassa = tt-valores.t1.
            run cria-ttrel(1, 
                           tt-valores.t1 ,
                           vpassa ,
                           tt-valores.valor,
                           no).
        end.
        else if first-of(tt-valores.t2)
        then do:
            vpassa = tt-valores.t1 + "|" + tt-valores.t2.
            run cria-ttrel(2, 
                           "   " + tt-valores.t2,
                           vpassa,
                           tt-valores.valor,
                           no).
        end.
        else if first-of(tt-valores.t3)
        then do:
            vpassa = tt-valores.t1 + "|" + tt-valores.t2 + "|" + 
                     tt-valores.t3.
            run cria-ttrel(3, 
                           "      " + tt-valores.t3,
                           vpassa,
                           tt-valores.valor,
                           no).
        end.
        else if first-of(tt-valores.t4)
        then do:
            vpassa = tt-valores.t1 + "|" + tt-valores.t2 + "|" +
                     tt-valores.t3 + "|" + tt-valores.t4.
            run cria-ttrel(4, 
                           "         " + tt-valores.t4,
                           vpassa,
                           tt-valores.valor,
                           no).
        end.
        else if first-of(tt-valores.t5)
        then do:
            vpassa = tt-valores.t1 + "|" + tt-valores.t2 + "|" +
                     tt-valores.t3 + "|" + tt-valores.t4 + "|" +
                     tt-valores.t5.
            run cria-ttrel(5, 
                           "            " + tt-valores.t5,
                           vpassa,
                           tt-valores.valor,
                           no).
        end.
        else if  first-of(tt-valores.t6)
        then do:                 
            vpassa = tt-valores.t1 + "|" + tt-valores.t2 + "|" +
                     tt-valores.t3 + "|" + tt-valores.t4 + "|" +
                     tt-valores.t5 + "|" + tt-valores.t6.        
            run cria-ttrel(6, 
                           "               " + tt-valores.t6,
                           vpassa,
                           tt-valores.valor,
                           no).
        end.
end.

vtipo1 = "DEVOLUCAO".
vtipo2 = "VENDA".
    
for each tt-valores where tt-valores.t1 = vtipo1 and
                          tt-valores.t2 = vtipo2 
                            no-lock break by tt-valores.t1 
                                    by tt-valores.t2 
                                    by tt-valores.t3 
                                    by tt-valores.t4 
                                    by tt-valores.t5 
                                    by tt-valores.t6 
                                    by tt-valores.t7.
      
        if first-of(tt-valores.t2)
        then run cria-ttrel(vordem, tt-valores.t1 + "-" + tt-valores.t2, 
                            tt-valores.t1 + tt-valores.t3,
                            tt-valores.valor,
                            no).
        else if first-of(tt-valores.t3)
        then run cria-ttrel(vordem, 
                            "    " + tt-valores.t3,
                            tt-valores.t1 + tt-valores.t3,
                             tt-valores.valor,
                             no).
        else if first-of(tt-valores.t4)
        then run cria-ttrel(vordem, 
                            "        " + tt-valores.t4,
                            tt-valores.t1 + tt-valores.t3 + tt-valores.t4,
                            tt-valores.valor,
                            no).

end.
vordem = 200.
vtipo1 = "ESTORNO".
vtipo2 = "FINANCEIRA".
    
for each tt-valores where tt-valores.t1 = vtipo1 and
                          tt-valores.t2 = vtipo2 
                            no-lock break by tt-valores.t1 
                                    by tt-valores.t2 
                                    by tt-valores.t3 
                                    .
        if first-of(tt-valores.t1)
        then run cria-ttrel(vordem, tt-valores.t1 + "-" + tt-valores.t2, 
                            tt-valores.t1 + tt-valores.t3,
                            tt-valores.valor,
                            no).
        else if first-of(tt-valores.t3)
        then run cria-ttrel(vordem, 
                            "    " + tt-valores.t3,
                            tt-valores.t1 + tt-valores.t3,
                             tt-valores.valor,
                             no).
end.

def var vtotal as dec format ">>>,>>>,>>9.99".
def var varquivo as char.
varquivo = "/admcom/relat/cliprog1514-v001-2018." + string(time).
output to value(varquivo). 
disp with frame f1.
for each tt-rel with no-label:
    disp campo1 format "x(40)" 
         valor with width 160.
    /*if tt-rel.soma
    then vtotal = vtotal + valor.
    else vtotal = 0.
    if vtotal > 0
    then disp vtotal.*/
end.    
output close.
run visurel.p(varquivo,"").

/************
varquivo = "/admcom/relat/cliprog1514-v001-2018-" + string(time)
                + ".csv".
output to value(varquivo). 
for each tt-rel with no-label:
    campo1 = replace(campo1," ",";").
    put campo1 format "x(60)" 
         ";"
         valor skip .
end.    
output close.
**********/

procedure cria-ttrel:
    def input parameter p-ordem as int.
    def input parameter p-campo1 as char.
    def input parameter p-campo2 as char.
    /*def input parameter p-campo3 as char.*/
    def input parameter p-valor as dec.
    def input parameter p-soma as log.
    find first tt-rel where tt-rel.ordem  = p-ordem and
                            tt-rel.campo1 = p-campo1 and
                            tt-rel.campo2 = p-campo2
                            /*and
                            tt-rel.campo3 = p-campo3   */
                            no-error.
    if not avail tt-rel
    then do:
        create tt-rel.
        assign
            tt-rel.ordem  = p-ordem    
            tt-rel.campo1 = p-campo1
            tt-rel.campo2 = p-campo2
            /*tt-rel.campo3 = p-campo3 */ 
            tt-rel.soma = p-soma
            .

    end.
    tt-rel.valor = tt-rel.valor + p-valor.
    
end procedure.