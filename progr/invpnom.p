{admcab.i}

def var recimp as recid.
def var vofield as char.
def var varqsai as char.
def var fila as char.
def var v-title as char.
def var v-opcao-ordem as char format "x(10)" extent 3 initial
[ "Produto", "Fornecedor",  "Classe" ].
def var v-ordem-opcao as int.
def var vkont as int init 0.
def var ac  as i.
def var tot as i.
def var de  as i.
def var vdata like plani.pladat.
def var est like estoq.estatual.
def var vetbcod    like estab.etbcod.
def var vpronom    like produ.pronom.
def var vfornom    like forne.fornom.
def var vclanom    like clase.clanom.

def var varquivo as char.
def var lEtiqueta  as logi form "Sim/Nao"        init no        no-undo.
def var iContEtq   as inte form ">>>>>9"         init 0         no-undo.
   
def temp-table tt-etiqueta                 no-undo
    field rProdu    as recid
    field qtd-etq   as inte  form ">>>>>9"
    field procod    like produ.procod
    field pronom    like produ.pronom
    field qtdest    like estoq.estatual.

def temp-table tw-etiqueta like tt-etiqueta.

def temp-table tt-relato
field procod like produ.procod
field pronom like produ.pronom format "x(20)"
field forcod like forne.forcod 
field fornom like forne.fornom  format "x(15)"
field clacod like clase.clacod label "Clase"
field clanom like clase.clanom format "x(15)"
field qtest  as int label "Qtd." format "->>>>9"
field estcusto  as dec column-label "Pc.Custo" format ">,>>9.99"
field vtotal    as dec column-label "Total Custo" format "->>,>>9.99"
field chave  as char
index chave chave.

form vetbcod estab.etbnom skip
     vpronom skip
     vfornom skip
     vclanom skip
     vdata skip
     "Ordenacao : " 
     v-opcao-ordem[1] v-opcao-ordem[2] v-opcao-ordem[3]
     with frame f1.

repeat:
    view frame fc1.
    view frame fc2.
    if setbcod = 999
    then update vetbcod with frame f1 side-label centered.
    else vetbcod = setbcod.
    disp vetbcod with frame f1.
    find estab where estab.etbcod = vetbcod no-lock.
    disp estab.etbnom no-label with frame f1.

    vpronom = "".

    update vpronom 
           vfornom label "Fornecedor"
           vclanom
           vdata with frame f1.
    disp v-opcao-ordem[1] no-label
         v-opcao-ordem[2] no-label 
         v-opcao-ordem[3] no-label with frame f1.          
    choose field v-opcao-ordem with frame f1.
    assign v-ordem-opcao = frame-index.
    {confir.i 1 "Posicao de Estoque"}
    for each tt-relato:
        delete tt-relato.
    end.
    for each tt-etiqueta:
        delete tt-etiqueta.
    end.

    /* Processando */
    assign vkont = 0.
    for each produ where produ.pronom begins vpronom no-lock.
         assign vkont = vkont + 1.
        
        /*****************************
        if vkont > 5000 then leave.
        ******************************/

        disp "Produto : " produ.procod produ.pronom with frame fmost
            centered no-box no-labels.
        pause 0.
        find estoq where estoq.etbcod = estab.etbcod and
                         estoq.procod = produ.procod no-lock no-error.
        if not avail estoq
        then next.
        est = estoq.estatual.
        find first forne where forne.forcod = produ.fabcod no-lock no-error.
        if vfornom <> ""
        then do:
           if avail forne and forne.fornom begins vfornom then vkont = vkont + 0.
           else next.
        end.
        find first clase where clase.clacod = produ.clacod no-lock no-error.
        if vclanom <> ""
        then do:
           if avail clase and clase.clanom begins vclanom 
           then vkont = vkont + 1. 
           else next.
        end.
 
        for each movim where movim.procod = produ.procod and
                             movim.movdat >= vdata no-lock:

            find first plani where plani.etbcod = movim.etbcod and
                                   plani.placod = movim.placod and
                                   plani.movtdc = movim.movtdc and
                                   plani.pladat = movim.movdat no-lock no-error.

            if not avail plani
            then next.
            if plani.etbcod <> estab.etbcod and
               plani.desti  <> estab.etbcod
            then next.
            if plani.emite = 22 and
               plani.serie = "m1"
            then next.

            if plani.movtdc = 5 and
               plani.emite  <> estab.etbcod
            then next.

            find tipmov of movim no-lock.
            if movim.movtdc = 5 or
               movim.movtdc = 13 or
               movim.movtdc = 14 or
               movim.movtdc = 16 or
               movim.movtdc = 8  or
               movim.movtdc = 18
               then if movim.movdat > vdata
                    then est = est + movim.movqtm.

            if movim.movtdc = 4 or
               movim.movtdc = 1 or
               movim.movtdc = 7 or
               movim.movtdc = 12 or
               movim.movtdc = 15 or
               movim.movtdc = 17
            then if movim.movdat > vdata
                 then est = est - movim.movqtm.

            if movim.movtdc = 6
            then do:
                if plani.etbcod = estab.etbcod
                then if movim.movdat > vdata
                     then est = est + movim.movqtm.
                if plani.desti = estab.etbcod
                then if movim.movdat > vdata
                     then est = est - movim.movqtm.
            end.
        end.


        if est = 0
        then next.

        create  tt-relato.
        assign  tt-relato.procod   = produ.procod
                tt-relato.pronom   = if produ.pronom <> "" then produ.pronom
                                     else produ.pronomc
                tt-relato.qtest    = est
                tt-relato.estcusto = estoq.estcusto
                tt-relato.clanom   = clase.clanom
                tt-relato.clacod   = clase.clacod
                tt-relato.forcod   = forne.forcod
                tt-relato.fornom   = forne.fornom
                tt-relato.vtotal   =  (estoq.estcusto * EST).
        /* ETIQUETAS */
        if est > 0
        then do:
                 create tt-etiqueta.
                 assign tt-etiqueta.rprodu  = recid(produ)
                        tt-etiqueta.qtd-etq = est
                        tt-etiqueta.procod  = produ.procod
                        tt-etiqueta.pronom  = produ.pronom
                        tt-etiqueta.qtdest  = est.
        end. 

        /* antonio - Ordenacao por Chave */
        case v-ordem-opcao : 
          when 1 then tt-relato.chave = produ.pronom.
          when 2 then tt-relato.chave = forne.fornom.
          when 3 then tt-relato.chave = clase.clanom.
        end case.

end.
find first tt-relato no-error.
if not avail tt-relato
then do:
    message "Nada Selecionado com parametros informados" 
    view-as alert-box.
    undo.
end.

if v-ordem-opcao = 1 then run Pi-brow-produto.
else if v-ordem-opcao = 2 then run Pi-brow-fornece.
     else if v-ordem-opcao = 3 then run Pi-brow-classe.

end.

Procedure Pi-brow-produto.

    ON F6 PUT.
    ON PF6 PUT.        
  {setbrw.i}
  bl-princ:
  repeat:
    assign
        a-seeid = -1
        a-recid = -1
        a-seerec = ?.

    hide frame f-linha no-pause.
    clear frame f-linha all.
    {sklcls.i
        &help = " F6 = Relatorio  F10 = Etiqueta"
        &file = tt-relato
        &cfield = tt-relato.pronom
        &noncharacter = /*
        &ofield = " tt-relato.procod tt-relato.qtest tt-relato.estcusto tt-relato.vtotal "
        &where = " true "
        &aftfnd1 = " "
        &naoexiste1 = " "
        &aftselect1 = " 
        if keyfunction(lastkey) = ""RETURN""
                then do:
                    /*un preco-inicial.
                    next keys-loop.
                    */
                end. "    
         &otherkeys1 = " 
         
         if keyfunction(lastkey) = ""PUT"" OR
                            keyfunction(lastkey) = ""INSERT-MODE""
                         then do: 
                                  run Pi-Relato.
                                  leave bl-princ.
                         end.                   
                         if keyfunction(lastkey) = ""DELETE-LINE"" or
                            keyfunction(lastkey) = ""CUT""
                         then do:
                              run Pi-Etiqueta. 
                              leave bl-princ.
                         end. 
                         next keys-loop. "
         &form   = " frame f-linha 10 down row 7 
                    title "" Inventario por Produto "" 
                    color with/cyan centered "
    }                        
    if keyfunction(lastkey) = "end-error"
    then do:
        hide frame f-linha no-pause.
        leave bl-princ.
    end.    
  end.

end procedure.

Procedure Pi-brow-classe.

  ON F6 PUT.
    ON PF6 PUT.  
            
  {setbrw.i}
  bl-princ:
  repeat:
    assign
        a-seeid = -1
        a-recid = -1
        a-seerec = ?.

    hide frame f-linha no-pause.
    clear frame f-linha all.
    {sklcls.i
        &help = " F6 = Relatorio  F10 = Etiqueta"
        &file = tt-relato
        &cfield = tt-relato.clanom
        &noncharacter = /*
        &ofield = " tt-relato.clacod tt-relato.procod tt-relato.qtest tt-relato.estcusto tt-relato.vtotal "
        &where = " true "
        &aftfnd1 = " "
        &naoexiste1 = " "
        &aftselect1 = " if keyfunction(lastkey) = ""RETURN""
                then do:
                    /*run preco-inicial.
                    next keys-loop.
                    */
                end. "    
         &otherkeys1 = " if keyfunction(lastkey) = ""PUT"" OR
                            keyfunction(lastkey) = ""INSERT-MODE""
                         then do: 
                                  run Pi-Relato.
                                  leave bl-princ.
                         end.                   
                         if keyfunction(lastkey) = ""DELETE-LINE"" or
                            keyfunction(lastkey) = ""CUT""
                         then do:
                              run Pi-Etiqueta. 
                              leave bl-princ.
                         end. 
                         next keys-loop. "
         &form   = " frame f-linha 10 down row 7 
                    title "" Inventario por Classe "" 
                    color with/cyan centered "
    }                        
    if keyfunction(lastkey) = "end-error"
    then do:
        hide frame f-linha no-pause.
        leave bl-princ.
    end.    
  end.

end procedure.

Procedure Pi-brow-fornece.
        
  {setbrw.i}
  

bl-princ:
repeat:
    ON F6 PUT.
    ON PF6 PUT.
    assign
        a-seeid = -1
        a-recid = -1
        a-seerec = ?
        v-title = v-opcao-ordem[v-ordem-opcao].

   hide frame f-linha no-pause.
   clear frame f-linha all.
   { sklcls.i
        &help = " F6 = Relatorio  F10 = Etiqueta"
        &file = tt-relato
        &cfield = tt-relato.fornom
        &ofield = " tt-relato.procod tt-relato.pronom tt-relato.clacod tt-relato.qtest tt-relato.estcusto tt-relato.vtotal "
        &noncharacter = /*
        &where = " true "
        &aftfnd1 = " "
        &naoexiste1 = " "
        &aftselect1 = " if keyfunction(lastkey) = ""RETURN""
                then do:
                    /*un preco-inicial.
                    next keys-loop.
                    */
                end. "    
         &otherkeys1 = " if keyfunction(lastkey) = ""PUT"" OR
                            keyfunction(lastkey) = ""INSERT-MODE""
                         then do: 
                                  run Pi-Relato.
                                  leave bl-princ.
                         end.                   
                         if keyfunction(lastkey) = ""DELETE-LINE"" or
                            keyfunction(lastkey) = ""CUT""
                         then do:
                              run Pi-Etiqueta. 
                              leave bl-princ.
                         end. 
                         next keys-loop. "
         &form   = " frame f-linha 10 down row 7 
         color with/cyan centered Title ""Invetario Ordenado por Fornecedor""  "
         }   
    if keyfunction(lastkey) = "end-error"
    then do:
        hide frame f-linha no-pause.
        leave bl-princ.
    end.    
  end.
end procedure.


Procedure Pi-Relato.

    if opsys = "UNIX"
    then do: 
            find first impress where impress.codimp = setbcod 
                            no-lock no-error.
            if avail impress 
            then do:
                run acha_imp.p (input recid(impress),
                                        output recimp). 
                find impress where recid(impress) = recimp
                            no-lock no-error.
                            
                                        
                assign fila = string(impress.dfimp). 
            end. 
            assign varqsai = "/admcom/relat/pla" + STRING(month(vdata),"99") + 
                              string(estab.etbcod,"999")
                              + "." + string(time).
    end.
    else  assign varqsai = "c:~\temp~\pla" + STRING(month(vdata),"99") + 
                                      string(estab.etbcod,"999")
                                      + "." + string(time).
     
     {mdadmcab.i
        &Saida     = "value(varqsai)"
        &Page-Size = "64"
        &Cond-Var  = "100"
        &Page-Line = "66"
        &Nom-Rel   = """invpnom.P"""
        &Nom-Sis   = """SISTEMA DE ESTOQUE"""
        &Tit-Rel   = """CONTROLE DE ESTOQUE - "" + estab.etbnom 
                        + ""  Data: "" + string(vdata,""99/99/9999"")"
        &Width     = "100"
        &Form      = "frame f-cab"}

    for each tt-relato break by tt-relato.chave
                             by tt-relato.procod:

        if v-ordem-opcao = 2
        then if first-of(tt-relato.chave)
             then do:
                find first forne where forne.forcod = tt-relato.forcod 
                    no-lock no-error.
                disp skip(2) forne.fornom label "Fornecedor" with frame
                        f-cab-rel1 side-labels no-box.
             end.
 
        if v-ordem-opcao = 3
        then if first-of(tt-relato.chave)
             then do:
                disp skip(2)  tt-relato.clanom label "Classe" with frame
                        f-cab-rel2 side-labels no-box.
             end.
  
        display tt-relato.procod column-label "Codigo"
                tt-relato.pronom format "x(35)"
                tt-relato.qtest    column-label "Qtd."     format "->>>>9"
                tt-relato.estcusto column-label "Pc.Custo" format ">,>>9.99"
                tt-relato.vtotal  column-label "Total Custo" 
                                                           format "->>,>>9.99"
                            with frame f2 down width 79.
    end.
    output close.
    if opsys = "UNIX"
    then do:
        run visurel.p(varqsai,"").
    end.
    else do:
        def var varquivo as char.
        varquivo = varqsai.
        {mrod.i}
    end.    
    
    

end procedure.

Procedure Pi-Etiqueta.

    update lEtiqueta label "Geracao Etiquetas "
           with frame f-1 side-labels 1 col width 40
                row 15 col 10 title "GERA ETIQUETAS".
    if lEtiqueta = yes
    then do:
             /* Regrava por Chave - Antonio */
             for each tw-etiqueta:
                delete tw-etiqueta.
             end.   
             for each tt-relato  by tt-relato.chave
                                 by tt-relato.procod:
                find first 
                    tt-etiqueta where tt-etiqueta.procod = tt-relato.procod                                 no-error.
                create tw-etiqueta.
                buffer-copy tt-etiqueta to tw-etiqueta.
             end.
             /**/
             run etq3cl1a.p (input table tw-etiqueta,
                             input "invpnom").
    end.   

 end procedure.

 Procedure Pi-troca-label.       
 
    def input parameter  par-handle as handle.
    def input parameter par-label  as char.
                                                             
    if par-label = "NO-LABEL"                           
    then par-handle:label    = ?.                       
    else par-handle:label    = "  " + par-label.               
                                                         
end procedure.  