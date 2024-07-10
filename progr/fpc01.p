{admcab.i} 

def var v-im as log format "Tela/Impressora".
def var fila as char.

def var visu as log format "Sim/Nao".

def var v-cons-fi  as logical format "Sim/Nao" initial yes.

def temp-table tt-forfilho no-undo
field fabcod like fabri.fabcod
field paifil as char format "x(1)"
index k1  fabcod.


def buffer xclase for clase.
def buffer cclase for clase.
def buffer dclase for clase.
def buffer eclase for clase.
def buffer fclase for clase.
def buffer gclase for clase.
def buffer bclase for clase.

def temp-table tt-cla
    field clacod like clase.clacod
    field clanom like clase.clanom
    index iclase is primary unique clacod.

def var ii as int.
def var v-de like plani.platot.
def var v-ac like plani.platot.
def var vtotal_platot like plani.platot.
def var vlcontrato like plani.platot.
def var vcla-cod like clase.clacod.
def var vano as int.
def var vmes as int.
def var varquivo as char format "x(20)".
def temp-table tt-curva
    field pos    like curva.pos
    field cod    like curva.cod
    field valven like curva.valven
    field qtdven like curva.qtdven
    field valcus like curva.valcus
    field qtdest like curva.qtdest
    field estcus like curva.estcus
    field estven like curva.estven
    field giro   like curva.giro.
def buffer btt-curva for tt-curva.
def buffer bmovim for movim.
def var i as i.
def var tot-c like plani.platot.
def var tot-v like plani.platot format "->>9.99".
def var tot-m like plani.platot.
def var vacum like plani.platot format "->>9.99".
def var wnp as i.
def var vvltotal as dec.
def var vvlcont  as dec.
def var wacr     as dec.
def var wper     as dec.
def var valortot as dec.
def var vval     as dec.
def var vval1    as dec.
def var vsal     as dec.
def var vlfinan  as dec.
def var vdti    as date format "99/99/9999".
def var vdtf    as date format "99/99/9999".
def var vetbi   like estab.etbcod.
def var vetbf   like estab.etbcod.
def var vvlcusto    like plani.platot column-label "Vl.Custo".
def var vvlvenda    like plani.platot column-label "Vl.Venda".
def var vvlmarg     like plani.platot column-label "Margem".
def var vvlperc     as dec format ">>9.99 %" column-label "Perc".
def var vvldesc     like plani.descprod column-label "Desconto".
def var vvlacre     like plani.acfprod column-label "Acrescimo".
def var vacrepre    like plani.acfprod column-label "Acr.Previsto".
def var vcatcod     like produ.catcod.
def var vcatcod2    like produ.catcod.
def var vfabcod     like produ.fabcod.
def stream stela.
def buffer bcontnf for contnf.
def buffer bplani for plani.

repeat:
    for each tt-curva:
        delete tt-curva.
    end.
    for each tt-cla. delete tt-cla. end.
    
    update vcatcod label "Departamento" colon 16
                with frame f-dep centered side-label color blue/cyan row 4.
    find categoria where categoria.catcod = vcatcod no-lock.
    disp categoria.catnom no-label with frame f-dep.
    if vcatcod = 31
    then vcatcod2 = 35.
    if vcatcod = 41
    then vcatcod2 = 45.

    
    /*update vcla-cod label "Clase Inferior" colon 16 with frame f-dep.
    find clase where clase.clacod = vcla-cod no-lock no-error.
    display clase.clanom no-label with frame f-dep.*/
    
    update vcla-cod label "Classe" colon 16 with frame f-dep.
    if vcla-cod <> 0
    then do:
        find xclase where xclase.clacod = vcla-cod no-lock no-error.
        display xclase.clanom no-label with frame f-dep.
    end.
    else disp "Todas" @ xclase.clanom with frame f-dep.
    
    if vcla-cod <> 0
    then do:
    
        find first clase where clase.clasup = vcla-cod no-lock no-error. 
        if avail clase 
        then do:
            run cria-tt-cla. 
            hide message no-pause.
        end. 
        else do:
            find clase where clase.clacod = vcla-cod no-lock no-error.
            if not avail clase
            then do:
                message "Classe nao Cadastrada".
                undo.
            end.

            create tt-cla.
            assign tt-cla.clacod = clase.clacod
                   tt-cla.clanom = clase.clanom.

        end.
    end.

    update vfabcod label "Fornecedor"
                with frame f-depf centered side-label color blue/cyan row 8.
    find fabri where fabri.fabcod = vfabcod no-lock.
    disp fabri.fabnom no-label with frame f-depf.

     /* Antonio */
    for each tt-forfilho:
        delete tt-forfilho .
    end.

    message "Deseja Considerar Fornecedores Filhos ? " update v-cons-fi.
    create tt-forfilho.
    assign tt-forfilho.fabcod = vfabcod.
    if v-cons-fi = yes
    then do:
        for each forne where forne.forpai = vfabcod no-lock:
            find first tt-forfilho 
                    where tt-forfilho.fabcod = vfabcod no-error. 
            if not avail tt-forfilho
            then do:
                create tt-forfilho.
                assign tt-forfilho.fabcod = forne.forcod.
            end.
        end.
    end.
    /**/


    vdti = today - 31.
    vdtf = today.
    update vdti no-label
           "a"
           vdtf no-label with frame f-dat centered color blue/cyan row 12
                                    title " Periodo ".

    vetbi = 1.
    vetbf = 999.
    update vetbi no-label format ">>9"
           "a"
           vetbf no-label format ">>9" with frame f-etb centered color blue/cyan row 16
                                    title " Filial ".
    for each tt-curva:
        delete tt-curva.
    end.
    
    /*** antonio 
    for each produ where (produ.catcod = vcatcod or
                          produ.catcod = vcatcod2) and
                          produ.fabcod = fabri.fabcod /*and
                          produ.clacod = clase.clacod*/ no-lock:
    ****/
    
    for each tt-forfilho,
        each produ where (produ.catcod = vcatcod or
                          produ.catcod = vcatcod2) and
                          produ.fabcod = tt-forfilho.fabcod /*and
                          produ.clacod = clase.clacod*/ no-lock:
        

            if vcla-cod = 0
            then.
            else do:
                find tt-cla where tt-cla.clacod = produ.clacod no-lock no-error.
                if not avail tt-cla
                then next.
            end.
        
        
        find first bmovim where bmovim.procod = produ.procod and
                                bmovim.movtdc = 5 and
                                bmovim.movdat >= vdti and
                                bmovim.movdat <= vdtf no-lock no-error.
        if not avail bmovim
        then next.

        output stream stela to terminal.
        disp stream stela produ.procod with frame ffff centered
                                       color white/red 1 down.
        pause 0.
        output stream stela close.

        find first tt-curva where tt-curva.cod = produ.procod no-error.
        if not avail tt-curva
        then do:
            create tt-curva.
            find last btt-curva no-error.
            if not avail btt-curva
            then tt-curva.pos = 1000000.
            else tt-curva.pos = btt-curva.pos + 1.
            tt-curva.cod = produ.procod.
        end.

        for each movim where movim.procod = produ.procod and
                             movim.movtdc = 5 and
                             movim.movdat >= vdti and
                             movim.movdat <= vdtf no-lock:
            
            
            if movim.movqtm = 0 or
               movim.movpc  = 0
            then next.
            v-de = 0.
            v-ac = 0.
            if movim.etbcod >= vetbi and
               movim.etbcod <= vetbf
            then do:
                find first plani where plani.etbcod = movim.etbcod and
                                       plani.placod = movim.placod and
                                       plani.movtdc = movim.movtdc and
                                       plani.pladat = movim.movdat and
                                       plani.platot >= 1
                                            no-lock no-error.
                if not available plani
                then next.
                vlcontrato = plani.platot - plani.vlserv.
                if avail plani and plani.crecod = 2
                then vlcontrato = plani.biss.

                if ( ( movim.movqtm * movim.movpc ) * 
                     ( vlcontrato / plani.platot  ) ) > 0
                then do:
                    assign
                        tt-curva.qtdven = tt-curva.qtdven + movim.movqtm
                        tt-curva.valven = tt-curva.valven + 
                                      ( ( movim.movqtm * movim.movpc ) * 
                                        ( vlcontrato / plani.platot ) ).
                    find estoq where estoq.etbcod = setbcod and
                                     estoq.procod = produ.procod 
                                            no-lock no-error.
                    if avail estoq
                    then tt-curva.valcus = tt-curva.valcus + 
                            (movim.movqtm * estoq.estcusto).
                end.
            end.
        end.
        /*************************************/
        ii = 0.
        do ii = vetbi to vetbf:
            find estoq where estoq.etbcod = ii and
                             estoq.procod = produ.procod no-lock no-error.
            if avail estoq
            then assign
            tt-curva.qtdest = tt-curva.qtdest + estoq.estatual 
            tt-curva.estcus = tt-curva.estcus +
                              (estoq.estatual * estoq.estcusto)
            tt-curva.estven = tt-curva.estven + 
                              (estoq.estatual * estoq.estvenda).
        end.
        /**************************************/

    end.

    i = 1.
    tot-v = 0.
    tot-c = 0.
    for each tt-curva by tt-curva.valven descending:
        tt-curva.pos = i.
        tot-v = tot-v + tt-curva.valven.
        tot-c = tot-c + (tt-curva.valven - tt-curva.valcus).
        i = i + 1.
    end.


if opsys = "UNIX"
then do:
    v-im = yes.
    message "Gerar relatorio em tela ou impressora? " update v-im.
    if not v-im
    then do:
        disp " Prepare a Impressora para Imprimir Relatorio e pressione ENTER"
                            with frame f-imp3 centered row 10.
        pause.
        message "Imprimindo Relatorio... Aguarde".

        find first impress where impress.codimp = setbcod no-lock no-error.
        if avail impress
        then assign fila = string(impress.dfimp)
                    varquivo = "/admcom/relat/fpc"
                                + string(time)
                                + STRING(day(today)) +
                                string(xclase.clacod,"999999999").

    
    end. 
    else varquivo = "/admcom/relat/fpc" + string(time) + STRING(day(today)) +
                                string(xclase.clacod,"999999999").

                       
end.
else assign fila = ""
            varquivo = "..\relat\fpc" + string(time) + STRING(day(today)) +
                                string(xclase.clacod,"999999999").

    {mdad.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "150"
            &Page-Line = "66"
            &Nom-Rel   = ""FPC01""
            &Nom-Sis   = """SISTEMA DE ESTOQUE"""
            &Tit-Rel   = """CURVA ABC PRODUTOS POR FORNECEDOR - DA FILIAL ""
+                                   string(vetbi,"">>9"") + "" A "" +
                                  string(vetbf,"">>9"") +
                          "" PERIODO DE "" +
                                  string(vdti,""99/99/9999"") + "" A "" +
                                  string(vdtf,""99/99/9999"") "
            &Width     = "150"
            &Form      = "frame f-cabcab"}

    disp categoria.catcod label "Departamento"
         categoria.catnom no-label with frame f-dep2 side-label.
    disp fabri.fabcod label "Fornecedor"
         fabri.fabnom no-label with frame f-dep22 side-label width 200.

    if avail xclase
    then
        display xclase.clacod label "Clase"
                xclase.clanom no-label with frame f-dep22 side-labe.
    else
        display "0" @ xclase.clacod label "Clase"
                "Todas" @ xclase.clanom no-label with frame f-dep22 side-labe.

    
    vacum = 0.
    for each tt-curva by tt-curva.pos:
        if tt-curva.qtdven = 0 and
           tt-curva.estcus = 0 and
           tt-curva.estven = 0
        then next.
        vacum = vacum + ((tt-curva.valven / tot-v) * 100).
        find produ where produ.procod = tt-curva.cod no-lock no-error.
        tt-curva.giro = (tt-curva.estven / tt-curva.valven).
        disp tt-curva.pos format "9999" column-label "Pos."
             tt-curva.cod format ">>>>>9" column-label "Codigo"
             produ.pronom when avail produ format "x(30)" column-label "Nome"
             tt-curva.qtdven(total) format "->>>,>>9"    column-label "Qtd.Ven"
             tt-curva.valcus(total) format "->>>,>>9.99" column-label "Val.Cus"
             tt-curva.valven(total) format "->>>,>>9.99" column-label "Venda(4)"
             ((tt-curva.valven / tot-v) * 100)(total)
                                 format "->>9.99"     column-label "%S/VEN"
             vacum               format "->>9.99"     column-label "% ACUM"
             (tt-curva.valven - tt-curva.valcus)(total) format "->>>,>>9.99"
                                                      column-label "LUCRO"
             (((tt-curva.valven - tt-curva.valcus) / tot-c) * 100)(total)
                                 format "->>9.99"     column-label "%P/MAR"
             tt-curva.qtdest(total) format "->>>,>>9"    column-label "Qtd.Est"
             tt-curva.estcus(total) format "->>>,>>9.99" column-label "Est.Cus"
             tt-curva.estven(total) format "->>>,>>9.99" column-label "Est.Ven"
             tt-curva.giro when tt-curva.giro > 0
                                 format "->>>>9.99" column-label "Giro"
                     with frame f-imp width 200 down.
    end.
    output close.

    if opsys = "unix"
    then do:
        if v-im 
        then do:

            visu = no.
            message "Arquivo gerado em " varquivo " visualizar?" update visu.
            if visu
            then
                run visurel.p (input varquivo, input "").
                
        end.    
        else os-command silent lpr value(fila + " " + varquivo).
    end.
    else do:
        {mrod.i}.
    end.
    
end.

 procedure cria-tt-cla.
 for each clase where clase.clasup = vcla-cod no-lock:
   find first bclase where bclase.clasup = clase.clacod no-lock no-error.
   if not avail bclase
   then do: 
     find tt-cla where tt-cla.clacod = clase.clacod no-error. 
     if not avail tt-cla 
     then do: 
       create tt-cla. 
       assign tt-cla.clacod = clase.clacod 
              tt-cla.clanom = clase.clanom.
     end.
   end.
   else do: 
     for each bclase where bclase.clasup = clase.clacod no-lock: 
         find first cclase where cclase.clasup = bclase.clacod no-lock no-error.
         if not avail cclase
         then do: 
           find tt-cla where tt-cla.clacod = bclase.clacod no-error. 
           if not avail tt-cla 
           then do: 
             create tt-cla. 
             assign tt-cla.clacod = bclase.clacod 
                    tt-cla.clanom = bclase.clanom.
           end.
         end.
         else do: 
           for each cclase where cclase.clasup = bclase.clacod no-lock: 
             find first dclase where dclase.clasup = cclase.clacod 
                                                     no-lock no-error. 
             if not avail dclase 
             then do: 
               find tt-cla where tt-cla.clacod = cclase.clacod no-error. 
               if not avail tt-cla 
               then do: 
                 create tt-cla. 
                 assign tt-cla.clacod = cclase.clacod 
                        tt-cla.clanom = cclase.clanom.
               end.                          
             end.
             else do: 
               for each dclase where dclase.clasup = cclase.clacod no-lock: 
                 find first eclase where eclase.clasup = dclase.clacod 
                                                         no-lock no-error. 
                 if not avail eclase 
                 then do: 
                   find tt-cla where tt-cla.clacod = dclase.clacod no-error.
                   if not avail tt-cla 
                   then do: 
                     create tt-cla. 
                     assign tt-cla.clacod = dclase.clacod 
                            tt-cla.clanom = dclase.clanom. 
                   end.       
                 end. 
                 else do:  
                   for each eclase where eclase.clasup = dclase.clacod no-lock:
                     find first fclase where fclase.clasup = eclase.clacod 
                                                             no-lock no-error.
                     if not avail fclase 
                     then do: 
                       find tt-cla where tt-cla.clacod = eclase.clacod
                                                             no-error.
                       if not avail tt-cla 
                       then do: 
                         create tt-cla. 
                         assign tt-cla.clacod = eclase.clacod 
                                tt-cla.clanom = eclase.clanom.
                       end.
                     end.
                     else do:
                     
                       for each fclase where fclase.clasup = eclase.clacod
                                    no-lock:
                         find first gclase where gclase.clasup = fclase.clacod 
                                                             no-lock no-error.
                         if not avail gclase 
                         then do: 
                           find tt-cla where tt-cla.clacod = fclase.clacod
                                                                 no-error.
                           if not avail tt-cla 
                           then do: 
                             create tt-cla. 
                             assign tt-cla.clacod = fclase.clacod 
                                    tt-cla.clanom = fclase.clanom.
                           end.
                         end.
                         else do:
                             find tt-cla where tt-cla.clacod = gclase.clacod 
                                                        no-error.
                             if not avail tt-cla
                             then do:
                             
                                 create tt-cla. 
                                 assign tt-cla.clacod = gclase.clacod 
                                        tt-cla.clanom = gclase.clanom.
                                        
                             end.  
                         end.
                       end.
                     end.
                   end.
                 end.
               end.
             end.
           end.                                  
         end.
     end.
   end.
 end.
end procedure.
