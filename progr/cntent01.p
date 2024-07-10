{admcab.i}
{setbrw.i}                                                                      

def var vkont as int init 0.
def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def buffer sclase for clase.
def var vcarcod like caract.carcod.
def var vforcod like forne.forcod.
def var vsclacod  like clase.clacod.
def var vclacod   like clase.clacod.
def var vestilo  as char format "x(30)".
def var vestacao like produ.etccod.
def var vsubcod  like procaract.subcod.    
def var vcat like produ.catcod.
def var vdti as date.
def var vdtf as date.
def var imp-r as log.
def var vfabcod like produ.fabcod.
def buffer bclase for clase.
def buffer cclase for clase.
def buffer dclase for clase.
def buffer eclase for clase.

def temp-table tt-classe
    field clacod like clase.clacod.
    

def var esqcom1         as char format "x(17)" extent 5
    initial ["","IMPRIME TELA","IMPRIME ANALITICO", "",""].
def var esqcom2         as char format "x(15)" extent 5
            initial ["","","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial ["teste teste",
             "",
             "",
             "",
             ""].
def var esqhel2         as char format "x(12)" extent 5
   initial ["teste teste  ",
            " ",
            " ",
            " ",
            " "].

form
    esqcom1
    with frame f-com1
                 row 10 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.

form  vdti    label "Periodo de"  format "99/99/9999"
      vdtf    label "Ate"         format "99/99/9999"
      vcat    label "Setor"       categoria.catnom no-label  
      vforcod label "Fornecedor"  forne.fornom no-label skip    
      vclacod label "Clase     "  clase.clanom no-label skip 
      vsclacod label "Sub-Clase " sclase.clanom no-label skip 
      vestacao label "Estacao"  estac.etcnom no-label
      vcarcod  label "Cod.Carac." 
      vsubcod  label "Sub-Caracteriristica"
      with frame f-f1 1 down side-label width 80 row 3.


assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

def var i as int.

def new shared temp-table  tt-proped
    field procod like produ.procod
    field pednum like liped.pednum
    field pedtdc like liped.pedtdc 
    field pedetb like liped.etbcod
    field clifor like plani.emite
    field plaetb like plani.etbcod 
    field movtdc like plani.movtdc 
    field placod like plani.placod 
    field numero like plani.numero
    field pladat like plani.pladat
    field movqtm like movim.movqtm
    field movpc  like movim.movpc
    field lipqtd like liped.lipqtd
    field lipent like liped.lipent
    field lippreco like liped.lippreco
    field peddti like pedid.peddti
    field peddtf like pedid.peddtf
    field plaent like plani.dtinclu
    index i1 clifor procod pednum plaent
    .
 
def temp-table tt-forped
    field forcod like forne.forcod
    field fornom like forne.fornom
    field ddatr as int
    index i1 ddatr descending.

def temp-table tt-pedidfor
    field pednum like pedid.pednum  
    field forcod like forne.forcod
    field fornom like forne.fornom format "x(25)"
    field valor  as dec  format "->>,>>>,>>9.99"
    field movqtm as int  format ">>>>>9"
    field ddatr as int
    index i0 pednum asc
             forcod asc
             ddatr desc
    index i1 ddatr descending.


   
for each tt-pedidfor:
    delete tt-pedidfor.
end.
    
run processamento.

/******
form " " 
     tt-forped.forcod
     tt-forped.fornom  format "x(50)"
     tt-forped.ddatr   column-label "Maior Atraso"
     " "
     with frame f-linha 10 down color with/cyan /*no-box*/
     centered.
*****/

form " " 
     tt-pedidfor.pednum
     tt-pedidfor.forcod
     tt-pedidfor.fornom  format "x(25)"
     tt-pedidfor.valor   column-label "Valor"
     tt-pedidfor.movqtm  column-label "Qtde"
     tt-pedidfor.ddatr   column-label "Maior Atraso"
     with frame f-linha 4 down color with/cyan /*no-box*/
     centered.
  
disp "  CONTROLE DE ENTREGA PEDIDOS SETOR " + string(vcat) + " PERIODO "
+ string(vdti,"99/99/9999") + " ATE " +  string(vdtf,"99/99/9999") + " "
format "x(80)"
            with frame f1 1 down width 80                                       
            color message no-box no-label row 9 overlay.
                                                  
disp " " with frame f2 1 down width 80 color message no-box no-label            
    row 20.  

esqregua = no.    
l1: repeat:
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    assign
        a-seeid = -1 a-recid = -1 a-seerec = ?
        esqpos1 = 1 esqpos2 = 1. 
    hide frame f-linha no-pause.
    clear frame f-linha all.

    /**********************************
    {sklclstb.i  
        &color  = with/cyan
        &file   = tt-forped  
        &cfield = tt-forped.fornom
        &noncharacter = /* */
        &ofield = " tt-forped.forcod
                    tt-forped.ddatr
                  "  
        &where  = " true use-index i1 "
        &aftselect1 = " run aftselect.
                        a-seeid = -1.
                        if esqcom1[esqpos1] = ""  EXCLUI"" or
                           esqcom2[esqpos2] = ""  CLASSE""
                        then do:
                            next l1.
                        end.
                        else next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = "  bell.
                    message color red/with
                    ""Nenhum registro encontrado.""
                    view-as alert-box.
                    leave l1.
                    " 
        &otherkeys1 = " run controle. "
        &locktype = " "
        &form   = " frame f-linha "
    } 
    *************************************/
    /* Antonio */
    
    pause 0.
    {sklclstb.i  
        &color  = with/cyan
        &file   = tt-pedidfor  
        &cfield = tt-pedidfor.pednum column-label ""Pedido"
        &noncharacter = /* */
        &ofield = " tt-pedidfor.forcod  column-label ""Fornec.""
                    tt-pedidfor.fornom
                    tt-pedidfor.valor
                    tt-pedidfor.movqtm
                    tt-pedidfor.ddatr"
        &where  = " true use-index i0 "
        &aftselect1 = " run aftselect.
                        a-seeid = -1.
                        if esqcom1[esqpos1] = ""  EXCLUI"" or
                           esqcom2[esqpos2] = ""  CLASSE""
                        then do:
                            next l1.
                        end.
                        else next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = "  bell.
                    message color red/with
                    ""Nenhum registro encontrado.""
                    view-as alert-box.
                    leave l1.
                    " 
        &otherkeys1 = " run controle. "
        &locktype = " "
        &form   = " frame f-linha "
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
    clear frame f-linha1 all.
    if esqcom1[esqpos1] = "IMPRIME TELA"
    THEN DO on error undo:
        imp-r = yes.
        run relatorio.
        imp-r = no.
    END.
    if esqcom1[esqpos1] = "IMPRIME ANALITICO"
    THEN DO:
        imp-r = no.
        run relatorio.
    END.
    if esqcom1[esqpos1] = "  EXCLUI"
    THEN DO:
        
    END.
    if esqcom2[esqpos2] = "    "
    THEN DO on error undo:
    
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

procedure relatorio:

    def var varquivo as char.
    
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/" + string(setbcod) + "."
                    + string(time).
    else varquivo = "..~\relat~\" + string(setbcod) + "."
                    + string(time).
    
    {mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "130" 
                &Page-Line = "66" 
                &Nom-Rel   = ""cntent01"" 
                &Nom-Sis   = """SISTEMA COMERCIAL""" 
                &Tit-Rel   = " ""  CONTROLE DE ENTREGA PEDIDOS SETOR "" 
                    + string(vcat) + "" PERIODO ""
                    + string(vdti,""99/99/9999"") + "" ATE "" + 
                    string(vdtf,""99/99/9999"") "
                &Width     = "130"
                &Form      = "frame f-cabcab"}

    if imp-r
    then
    for each tt-pedidfor use-index i1:
        /* antonio */
        disp tt-pedidfor.pednum  column-label "Pedido"
             tt-pedidfor.forcod
             tt-pedidfor.fornom format "Quantx(45)"
             tt-pedidfor.valor   column-label "Valor"  format "->>,>>>,>>9.99"
             tt-pedidfor.movqtm  column-label "Quant." 
             tt-pedidfor.ddatr column-label "Maior atraso"
             with frame f-rel width 130 down.
             down with frame f-rel.
        /*****
        disp tt-forped.forcod
             tt-forped.fornom format "x(50)"
             tt-forped.ddatr column-label "Maior atrazo"
             with frame f-rel down.
        down with frame f-rel. 
       *****/     
    end.
    else do:
        /* antonio */
        disp tt-pedidfor.pednum  column-label "Pedido"
             tt-pedidfor.forcod
             tt-pedidfor.fornom format "x(45)"
             tt-pedidfor.valor   column-label "Valor"  format "->>,>>>,>>9.99"
             tt-pedidfor.movqtm  column-label "Quant." 
             tt-pedidfor.ddatr column-label "Maior atrazo"
             with frame f-rel1 width 130 down.
        /****
        disp tt-forped.forcod
             tt-forped.fornom format "x(50)"
             tt-forped.ddatr column-label "Maior atrazo"
             with frame f-rel1 down.
        ****/     
        pause 0.
        
        for each tt-proped where
                 tt-proped.clifor = tt-pedidfor.forcod 
                 no-lock .
            find produ where produ.procod = tt-proped.procod
                        no-lock.
            disp tt-proped.procod
                 produ.pronom      format "x(30)"
                 tt-proped.pednum column-label "Numero!Pedido"
                 tt-proped.peddtf column-label "Entrega!Final" 
                    format "99/99/9999"
                 tt-proped.numero column-label "Numero!Nota"
                 tt-proped.plaent column-label "Data!Entrada"
                 tt-proped.movqtm column-label "Qtd!Nota"   
                 tt-proped.lipqtd column-label "Qtd!Pedido"
                 tt-proped.lipent column-label "Qtd!Entregue"
                 tt-proped.plaent - tt-proped.peddtf 
                 column-label "Dias!Atraso" format "->>>>9"
                 with frame f-rel2 down width 120.
                 down with frame f-rel2.
       end.
    end.
    output close.
    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}
    end.
end procedure.

procedure processamento:

def var vdat as date.

do on error undo:
    
    update vdti 
           vdtf 
           vcat 
           with frame f-f1 1 down side-label width 80
           row 3.
          
  find categoria where 
         categoria.catcod = vcat no-lock no-error.
  if avail categoria then disp categoria.catnom no-label with frame f-f1.     
  else do:
        message "Setor Invalido" view-as alert-box.
        undo, retry.
  end. 
  do on error undo:     
  update vforcod    
         with frame f-f1 1 down side-label width 80.
   
    
    if vforcod > 0
    then do:
        find first forne 
            where forne.forcod = vforcod no-lock no-error.       
        if avail forne then disp forne.fornom with frame f-f1. 
        else do:
            message "Fornecedor naso Cadastrado" VIEW-AS ALERT-BOX.
            UNDO, RETRY.
        end.
    end.
    else disp "Geral" @ forne.fornom with frame f-f1.   
    do on error undo:
       update vclacod 
            with frame f-f1 1 down side-label width 80.
       if vclacod > 0
       then do:
         find first clase 
            where clase.clacod = vclacod no-lock no-error.       
        if avail clase then  disp clase.clanom with frame f-f1. 
        else do:
            message "Classe inexistente" VIEW-AS ALERT-BOX.
            UNDO, RETRY.
        end.
        find first sclase where sclase.clasup = vclacod no-lock no-error.
        if not avail sclase
        then do:
            message "Parametro invalido para Classe"
                view-as alert-box.
            undo, retry.
        end.
    end.
    else disp "Geral" @ clase.clanom with frame f-f1.   
    do on error undo:
      update vsclacod
            with frame f-f1 1 down side-label width 80.
    
      if vsclacod > 0
      then do:
        find first sclase 
            where sclase.clacod = vsclacod no-lock no-error.       
        if avail sclase then  disp sclase.clanom with frame f-f1. 
        else do:
            message "Sub-Classe inexistente" VIEW-AS ALERT-BOX.
            undo, retry.
        end.
        find first clase where clase.clasup = vsclacod no-lock no-error.
        if avail clase
        then do:
            message "Parametro invalido para Sub-Classe" VIEW-AS ALERT-BOX.
            undo, retry.
        end.
    end.
    else disp "Geral" @ sclase.clanom with frame f-f1.   
    do on error undo:
        update vestacao
        with frame f-f1 1 down side-label width 80.
        if vestacao <> 0
        then do:
            find first estac where estac.etccod = vestacao no-lock no-error.
            if not avail estac
            then do:
                message "Estacao Invalida" view-as alert-box.
                undo, retry.
            end.
            else disp estac.etcnom with frame f-f1.
        end.
        else disp "Geral" @ estac.etcnom with frame f-f1.
        
        update vcarcod
               vsubcod
          with frame f-f1 1 down side-label width 80.
          
        run criattclasse.
        /*run criattprodu.  */
          
    end.
   end. 
  end.
 end.
end. 

    
assign vkont = 0.

for each produ where produ.catcod = (if vcat <> 0 
                                           then vcat 
                                             else produ.catcod ) no-lock:
       
       /******
        if vkont > 1000 then leave.
       ******/
        
        vkont = vkont + 1.
        if vkont modulo 200 = 0
        then 
        disp "Registros" vkont no-label "->" 
        produ.procod produ.pronom format "x(40)"
            with frame f-fp 1 down centered row 10 
            no-label no-box.
        pause 0.
        
        /* antonio - Sol 26339 */
        if vfabcod <> 0 /* Fabricante */
        then do:
            if produ.fabcod <> vfabcod then next.
        end.
        if vclacod  <> 0  /* Clase */
        then do:
        find first tt-classe where tt-classe.clacod = produ.clacod no-lock no-error. 
           if not avail tt-classe then next. 
                                 
        end.
        if vsclacod <> 0  /* Subclase */ 
        then do:
          if produ.clacod <> vsclacod then next.
        end.  
        if vestacao <> 0 /* Estacao */
        then do:
             if vestacao <> produ.etccod then next.
        end.
        if vcarcod <> 0  /* Carcteristica */
        then do:
          find first procaract 
               where procaract.procod = produ.procod no-lock no-error.
                    if avail procaract
                    then do:
                        find first subcaract 
                           where subcaract.subcod = procaract.subcod
                                    no-lock no-error.
                        if not avail subcaract then next.   
                        if subcaract.carcod <> vcarcod  then next.
                     end.
         end.
         if vsubcod <> 0  /* Sub-Caracteriristica */
         then do:
             find first procaract 
               where procaract.procod = produ.procod no-lock no-error.
             if procaract.subcod <> vsubcod then next.
        end.
        /***/

        pause 0.
        do vdat = vdti to vdtf:
                             
          for each movim where movim.procod = produ.procod and
                             movim.movtdc = 4 and
                             movim.datexp = vdat
                             no-lock.
          
          find first plani where plani.etbcod = movim.etbcod and
                             plani.placod = movim.placod and
                             plani.movtdc = movim.movtdc and
                             plani.pladat = movim.movdat                             no-lock no-error.
            

            for each plaped where plaped.forcod = plani.emite and
                                  plaped.numero = plani.numero
                                  no-lock:
                find liped where liped.etbcod = plaped.pedetb and
                                 liped.pedtdc = plaped.pedtdc and
                                 liped.pednum = plaped.pednum and
                                 liped.procod = movim.procod
                                 no-lock no-error.
                if avail liped
                then do:
                    find first pedid of liped no-lock no-error.
                    vkont = vkont + 1.
                    /*
                    disp vkont no-label "-> " movim.movqtm liped.lipqtd
                        with frame f-fp centered .
                    pause 0.    
                    */
                    create tt-proped.
                    assign
                        tt-proped.procod = produ.procod
                        tt-proped.pednum = liped.pednum
                        tt-proped.pedtdc = liped.pedtdc 
                        tt-proped.pedetb = liped.etbcod
                        tt-proped.clifor = plani.emite
                        tt-proped.plaetb = plani.etbcod 
                        tt-proped.movtdc = plani.movtdc 
                        tt-proped.placod = plani.placod 
                        tt-proped.numero = plani.numero
                        tt-proped.pladat = plani.pladat
                        tt-proped.movqtm = movim.movqtm
                        tt-proped.movpc  = movim.movpc
                        tt-proped.lipqtd = liped.lipqtd
                        tt-proped.lipent = liped.lipent
                        tt-proped.lippreco = liped.lippreco
                        tt-proped.peddti = pedid.peddti
                        tt-proped.peddtf = pedid.peddtf
                        tt-proped.plaent = plani.dtinclu.
                end.                     
            end.                      
       /* end.*/
        end.
        end.
    end.
    for each tt-proped no-lock:
        /* antonio */
        find first tt-pedidfor where
                   tt-pedidfor.forcod = tt-proped.clifor  and
                   tt-pedidfor.pednum = tt-proped.pednum
                   no-error.
        if not avail tt-pedidfor
        then do:
            find forne where forne.forcod =
                tt-proped.clifor no-lock.
            create tt-pedidfor.
            tt-pedidfor.pednum = tt-proped.pednum.
            tt-pedidfor.forcod = tt-proped.clifor.
            tt-pedidfor.fornom = forne.fornom.
        end.
        if tt-pedidfor.ddatr < tt-proped.plaent - tt-proped.peddtf
        then tt-pedidfor.ddatr = tt-proped.plaent - tt-proped.peddtf.
        assign tt-pedidfor.movqtm = tt-pedidfor.movqtm + tt-proped.movqtm
               tt-pedidfor.valor  = tt-pedidfor.valor + 
                                    (tt-proped.movqtm * tt-proped.movpc).
        /**/
        
                                                                   
        
        find first tt-forped where
                   tt-forped.forcod = tt-proped.clifor
                   no-error.
        if not avail tt-forped
        then do:
            find forne where forne.forcod =
                tt-proped.clifor no-lock.
            create tt-forped.
            tt-forped.forcod = tt-proped.clifor.
            tt-forped.fornom = forne.fornom.
        end.
        if tt-forped.ddatr < tt-proped.plaent - tt-proped.peddtf
        then tt-forped.ddatr = tt-proped.plaent - tt-proped.peddtf.
    end. 
end procedure. 

procedure criattclasse:

find clase where clase.clacod = vclacod no-lock.
     create tt-classe.
     tt-classe.clacod = clase.clacod.
for each bclase where bclase.clasup = clase.clacod no-lock.
     create tt-classe.
     tt-classe.clacod = bclase.clacod.
        for each cclase where cclase.clasup = bclase.clacod no-lock.
            create tt-classe.
            tt-classe.clacod = cclase.clacod.
                for each dclase where dclase.clasup = cclase.clacod no-lock.
                    create tt-classe.
                    tt-classe.clacod = dclase.clacod.
                        for each eclase where eclase.clasup = dclase.clacod no-lock.
                            create tt-classe.
                            tt-classe.clacod = eclase.clacod.
                        end.
                end.
        end.
end.          

end procedure.

