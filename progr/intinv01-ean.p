/* ---------------------------------------------------------------------------
*  Nome.....: invinv01.p
*  Funcao...: integracao ADMCOM e AUTOMATEC  INV999AAAAMMDD.TXT
*  Data.....: 28/03/2006
*  Autor....: Gerson Mathias
*  Alterado.: Lucas Leote Ago/2016
--------------------------------------------------------------------------- */
{admcab.i}

pause 0 no-message.

def var varqsai as char.
def var vemail as char.
def var vassunto as char.
def var varquivo as char.

def buffer cmovim for movim.
def buffer dmovim for movim.

def var vnumero like plani.numero.
def var cfabcod like fabri.fabcod no-undo.
def var sclacod like clase.clacod no-undo.
/* ------------------------------------------------------------------------- */
def var vendereco as char format "x(50)".
def temp-table tt-inv                                no-undo
    field clacod        like clase.clacod
    field nomGrupo      as      char    form "x(30)"
    field proCod        as      char    form "x(06)"
    field proNom        as      char    form "x(50)"
    field proUnVen      as      char    form "x(03)"
    field estCusto      as      char    form "x(10)"
    field estAtual      as      char    form "x(07)"
    field catcod        like categoria.catcod
    field catnom        like categoria.catnom
        field ean           like produ.proindice
    index chPri         is primary procod
    index chClacod      clacod.

def temp-table tt-browse
    field marca  as    char form "x(1)" column-label "Marca"
    field procod like  produ.procod     column-label "Produto"
    field pronom like  produ.pronom     column-label "Nome"
    index ch-procod   procod.

/* ------------------------------------------------------------------------- */

def var lconfirma       as logi form "Sim/Nao"      init no         no-undo.
def var rRecid          as recid                                    no-undo.
def var cCaminho        as char form "x(100)"       init ""         no-undo.
def var cArqgera        as char form "x(60)"        init ""         no-undo.
def var cArqinte        as char form "x(160)"       init ""         no-undo.
def var ilinfra         as inte                     init 0          no-undo.
def var cdata           as char form "x(08)"        init ""         no-undo.
def var ddtainv         as date form "99/99/9999"   init today      no-undo.
def var cProCod         as inte form "999999"       init ""         no-undo.
def var lSelec          as logi                     init no         no-undo.
 
def var cClaNom         like clase.clanom                           no-undo.
def var iestCusto       like estoq.estcusto                         no-undo.
def var iestatual       like estoq.estatual                         no-undo.
def var vetbcod         like estab.etbcod                           no-undo.
def var icatcod         like categoria.catcod                       no-undo.
def var cProNom         like produ.pronom                           no-undo.
def var iprocod         like produ.procod.
def var cforcod         like forne.forcod no-undo.
def var cclacod         like clase.clacod no-undo.

def var vmanda-email as log format "Sim/Nao".

def button btn-pro label "PROCESSA".  
def button btn-inv label "EXPORTA INVENTARIO".  
def button btn-pes label "PESQUISA". 
def button btn-sai label "SAIR".

def var rd-selecao as inte 
    view-as radio-set horizontal radio-buttons
            "Categoria", 1,
            "Nome Produto", 2,
            "Digita Produto", 3,
            "Fornecdedor/Classe", 4,
            "NFs", 5
                        size 78 by 1.19. 

def query q_inv  for tt-inv
    fields(tt-inv.nomGrupo
           tt-inv.procod
           tt-inv.pronom
           tt-inv.prounven
           tt-inv.estcusto
           tt-inv.estatual
           tt-inv.catcod
           tt-inv.catnom
                   tt-inv.ean)
           scrolling.

def browse b_inv query q_inv no-lock
    display tt-inv.nomgrupo   column-label "Grupo"
            tt-inv.procod     column-label "Codigo"
            tt-inv.pronom     column-label "Nome"
            tt-inv.prounven   column-label "Unidade"
            tt-inv.estcusto   column-label "Custo"
            tt-inv.estatual   column-label "Estoque"
            tt-inv.catcod     column-label "Categoria"
            tt-inv.catnom     column-label "Descricao"
                        tt-inv.ean        column-label "EAN"
    with width 60 5 down no-row-markers.

def frame f-browse
    rd-selecao        no-label                       at 01
    b_inv                                            at 10
    btn-pro                                          at 01
    btn-inv                                          at 12
    btn-pes                                          at 45
    btn-sai                                          at 73
    with side-labels width 80 col 1 row 3
         title "MANUTENCAO INVENTARIO - INTINV01".

def frame f-browse-1
    iprocod label "Produto "                         at 01
    with side-labels width 80 col 1 row 16 keep-tab-order. 

def frame f-exp
    cArqInte     label     "Gerar em"
    lconfirma    label "Confirma"
    with side-labels 1 col 1 down width 80 title "GERACAO DO ARQUIVO DE INVENTARIO"
                     at row 15 col 1.
          
&scoped-define frame-name f-browse
&scoped-define open-query open query q_inv for each tt-inv no-lock by tt-inv.clacod
&scoped-define list-1 rd-selecao btn-pro btn-inv btn-pes btn-sai

&scoped-define frame-name-1 f-browse-1

&scoped-define inatprod if produ.procar = "INATIVO" then next.

 
/* ------------- MAIN ------------------------------------------------------- */

on choose of btn-pro in frame {&frame-name} /* Processa */
do:
   if input rd-selecao <> 5
   then do:
   assign cProNom = ""
          cfabcod = 0
          sclacod = 0  .
          
   update skip
          "Estabelecimento: "                  at row 1 col 001 
          vetbcod no-label                     at row 1 col 019  
          with frame f-inf1 row 14 col 1 width 80
          title "INFORME DADOS DO FILTRO" side-label
          overlay.

  find first estab where
             estab.etbcod = vetbcod no-lock no-error.
  if avail estab
  then disp estab.etbnom no-label              at row 1 col 024
       with frame f-inf1.
  else do:
          disp "Estabeleciemento nao existe!" @ estab.etbnom
                                               at row 1 col 024
                with frame f-inf1.
          undo, retry.
  end.                                  
  update  ddtainv label "Dt. Inventario"       at row 2 col 001 
          with frame f-inf1.
  if input rd-selecao = 1    
  then do:
          update icatcod label "Departamento"  at row 3 col 001
                 with frame f-inf1.
  end.
  if input rd-selecao = 2
  then do:               
          update cProNom label "Produto"       at row 4 col 001
                 with frame f-inf1.
  end.
  if input rd-selecao = 4
  then do on error undo:
    update cfabcod label "Fornecedor" at row 5 col 001
                with frame f-inf1.
    if cfabcod > 0
    then do:
    find fabri where fabri.fabcod = cfabcod no-lock no-error.
    if not avail fabri
    then do:
        message "Não Cadastrado.". pause.
        undo.
    end.
    disp fabri.fabnom no-label with frame f-inf1.
    pause 0.
    end.
    
    update sclacod label "Sub-Classe" at row 6 col 001
            with frame f-inf1.
    if sclacod > 0
    then do:
        find clase where clase.clacod = sclacod no-lock no-error.
        find first produ where produ.clacod = sclacod no-lock no-error.
        if not avail clase or
           not avail produ 
        then do:
            message "Sub-Classe não cadastrada". pause.
            undo.
        end.
        disp clase.clanom no-label with frame f-inf1.
        pause 0.    
        end.    
  end.

   assign cdata = string(day(ddtainv),"99")   +
                  string(month(ddtainv),"99") +
                  string(year(ddtainv),"9999").

   hide frame f-inf1.

   for each tt-inv:
     delete tt-inv.
   end.   

   if input rd-selecao = 1
   then do:
        run pi-sele1. 
   end.     
   if input rd-selecao = 2
   then do:
        run pi-sele2.
   end.        
   if input rd-selecao = 3        
   then do:
        run pi-sele3.
   end.        
   if input rd-selecao = 4        
   then do:
        run pi-sele4.
   end.
   end. 

   if input rd-selecao = 5        
   then do:
        for each tt-inv. delete tt-inv. end.
        run pi-sele5.
   end. 
   hide frame f-msg1.
   
   run pi-atualiza.
   
   hide frame f-msg1.
end.   

on choose of btn-inv in frame {&frame-name} /* Exporta inventario */
do:
   if opsys = "UNIX"
   then do:
           assign cCaminho  = "/admcom/auditoria/"
                  cArqGera  = "inv" + string(vetbcod,"999") + cdata + ".txt".                      cArqInte  = trim(cCaminho) + trim(cArqGera).
   end. 
   else do:
           assign cCaminho  = "c:~\temp~\"
                  cArqGera  = "inv" + string(vetbcod,"999") + cdata + ".txt".                      cArqInte  = trim(cCaminho) + trim(cArqGera).
   end.

   update 
          cArqInte  form "x(60)"
          lConfirma
          with frame f-exp.
   
           
   if lconfirma = yes
   then do:        
            if opsys = "UNIX"
            then do:
                do on error undo:
                    
                    update vmanda-email label "Mandar por email"
                           with frame f-exp1.
                           
                    if vmanda-email
                    then update vendereco label "Email" format "x(40)"
                                with frame f-exp1 side-labels.
                    if vmanda-email and vendereco = ""
                    then undo, retry.
                end.
            end.

            output to value(cArqInte).
   
                    for each tt-inv no-lock by tt-inv.clacod:
                       put screen "Gerando arquivo!" 
                           color messages col 20 row 15.
                       put   tt-inv.nomGrupo
                             tt-inv.procod
                             tt-inv.pronom
                             tt-inv.prounven
                             tt-inv.estcusto
                             tt-inv.estatual
                                                         tt-inv.ean
                             skip.
                    end.
            output close.
            
            if vmanda-email and vendereco <> ""
            then do:

                vassunto = "Inventario".
                vemail = vendereco.
                varqsai = "/admcom/logs/mail-audi.log".
                varquivo = cArqInte.
                
                unix silent value("/admcom/progr/mail.sh "
                             + "~"" + vassunto + "~" "
                             + varquivo
                             + " "
                             + vemail
                             + " "
                             + "informativo@lebes.com.br"
                             + " "
                             + "~"zip~""
                             + " > "
                             + varqsai
                             + " 2>&1 ").   
            end.
            
            put screen "                " 
                       col 20 row 15.
                                    
            message "Operacao concluida" view-as alert-box.
   end.
   hide frame f-exp.
end.

on choose of btn-pes in frame {&frame-name} /* Pesquisa */
do:
  
   update cProCod label "Produto"  
          with frame f-pesq side-labels 1 col width 80
               title "PESQUISA PRODUTO".
               
   open query q_inv for each tt-inv where
                             tt-inv.procod >= string(cProCod,">>>>>9") no-lock.
   disp b_inv with frame {&frame-name}.
   hide frame f-pesq.

end.    

on choose of btn-sai in frame {&frame-name} /* Sair */
do:
    apply "window-close" to current-window.
end.

/* ------------------------------------------------------------------------- */  procedure pi-atualiza:

  {&open-query}.

   enable b_inv 
          {&list-1} with frame {&frame-name}.

end procedure.
   
procedure pi-sele1:

   for each produ where
            produ.catcod = (if icatcod <> 0
                           then icatcod
                           else produ.catcod) no-lock:
    {&inatprod} /* Filtra inativo */
    
    if produ.catcod = 41 
    then do:
            find first cmovim use-index movim3
                       where cmovim.procod = produ.procod and
                             cmovim.etbcod = vetbcod and
                             cmovim.movdat >= (today - 730) no-lock no-error.
            if not avail cmovim
            then do:
                
                find first dmovim use-index desti
                           where dmovim.procod = produ.procod and
                                 dmovim.desti = vetbcod and
                                 dmovim.datexp >= (today - 730) 
                                 no-lock no-error.
                if not avail dmovim
                then next.
                
            end.                 
    end.
    
    find first estoq where
               estoq.procod = produ.procod and
               estoq.etbcod = vetbcod no-lock no-error.
    if avail estoq
    then do:
             find first clase where
                        clase.clacod = produ.clacod no-lock no-error.
             if avail clase
             then assign cClaNom = clase.clanom.            
             else assign cClaNom = "".
             
             find first estoq where
                        estoq.procod = produ.procod   and
                        estoq.etbcod = vetbcod        no-lock no-error.
             if avail estoq
             then assign iestcusto = round(estoq.estcusto,2)
                         iestatual = estoq.estatual.
             else assign iestcusto = ?
                         iestatual = ?.
             
             find first tt-inv where
                        tt-inv.procod   = string(produ.procod) 
                        exclusive-lock no-error.
             if not avail tt-inv
             then do:
                     disp "AGUARDE PROCESSANDO..!"  
                          with frame f-msg1 row 16 col 25.
                     pause 0 no-message.
                     
                     create tt-inv.
                     assign tt-inv.clacod   = produ.clacod
                            tt-inv.nomgrupo = string(cClanom,"x(30)")
                            tt-inv.procod   = string(produ.procod,">>>>>9")
                            tt-inv.pronom   = string(produ.pronom,"x(50)")
                            tt-inv.prounven = string(produ.prounven,"x(03)")
                            tt-inv.estcusto = string((iestcusto * 100),"->>>>>>>99")                            
                                                        tt-inv.estatual = string((iestatual),"->>>>>9")
                            tt-inv.catcod   = produ.catcod
                                                        tt-inv.ean      = string(produ.proindice,"x(15)").

                     find first categoria where
                                categoria.catcod = produ.catcod 
                                no-lock no-error.
                     if avail categoria 
                     then assign tt-inv.catnom = categoria.catnom.           
             end.                      
     end.
   end. 

hide frame f-msg1.
    
end procedure.

procedure pi-sele2:

   for each produ where
            produ.catcod = (if icatcod <> 0
                           then icatcod
                           else produ.catcod)  and
            produ.pronom begins(cPronom) no-lock:
    
    {&inatprod} /* Filtra inativo */
    
    if produ.catcod = 41 
    then do:
           find first cmovim use-index movim3
                       where cmovim.procod = produ.procod and
                             cmovim.etbcod = vetbcod and
                             cmovim.movdat >= (today - 730) no-lock no-error.
            if not avail cmovim
            then do:
                
                find first dmovim use-index desti
                           where dmovim.procod = produ.procod and
                                 dmovim.desti = vetbcod and
                                 dmovim.datexp >= (today - 730) 
                                 no-lock no-error.
                if not avail dmovim
                then next.
                
            end.  
            
     end.
    
    find first estoq where
               estoq.procod = produ.procod and
               estoq.etbcod = vetbcod no-lock no-error.
    if avail estoq
    then do:
             find first clase where
                        clase.clacod = produ.clacod no-lock no-error.
             if avail clase
             then assign cClaNom = clase.clanom.            
             else assign cClaNom = "".
             
             find first estoq where
                        estoq.procod = produ.procod   and
                        estoq.etbcod = vetbcod        no-lock no-error.
             if avail estoq
             then assign iestcusto = round(estoq.estcusto,2)
                         iestatual = estoq.estatual.
             else assign iestcusto = ?
                         iestatual = ?.
             
             find first tt-inv where
                        tt-inv.procod   = string(produ.procod) 
                        exclusive-lock no-error.
             if not avail tt-inv
             then do:
                     disp "AGUARDE PROCESSANDO..!"  
                          with frame f-msg1 row 16 col 25.
                     pause 0 no-message.
                     
                     create tt-inv.
                     assign tt-inv.clacod   = produ.clacod
                            tt-inv.nomgrupo = string(cClanom,"x(30)")
                            tt-inv.procod   = string(produ.procod,">>>>>9")
                            tt-inv.pronom   = string(produ.pronom,"x(50)")
                            tt-inv.prounven = string(produ.prounven,"x(03)")
                            tt-inv.estcusto = string((iestcusto * 100),"->>>>>>>99")
                                                        tt-inv.estatual = string((iestatual),"->>>>>9")
                            tt-inv.catcod   = produ.catcod
                                                        tt-inv.ean      = string(produ.proindice,"x(15)").

                     find first categoria where
                                categoria.catcod = produ.catcod 
                                no-lock no-error.
                     if avail categoria 
                     then assign tt-inv.catnom = categoria.catnom.           
             end.                      
     end.
   end.
    
hide frame f-msg1.
    
end procedure.

procedure pi-sele3:

  repeat:
     assign iprocod = 0.
     update iprocod 
            with frame f-browse-1.
     if iprocod = 0
     then do:
             leave.
     end.        
     find first produ where
                produ.procod = iprocod no-lock no-error.
     if not avail produ
     then do:
             message "Produto nao encontrado!"
                             view-as alert-box.
                     undo, retry.
     end.
     else do:
             find first estoq where
                        estoq.procod = produ.procod and
                        estoq.etbcod = vetbcod no-lock no-error.
             if not avail estoq
             then do:
                     message "Produto nao encontrado!"
                             view-as alert-box.
                     undo, retry.        
             end.
             else do:
                     if estoq.estatual = 0
                     then do:
                             message "Produto com estoque zero, confirma" skip
                                     "utilizacao deste codigo?"
                                     view-as alert-box buttons yes-no
                                     title "ESTOQUE" update lconfirma.
                             if lconfirma = no
                             then undo, retry.        
                     end.
                     find first clase where
                                clase.clacod = produ.clacod no-lock no-error.
                     if avail clase
                     then assign cClaNom = clase.clanom.            
                     else assign cClaNom = "".
             
                     assign iestcusto = round(estoq.estcusto,2)
                            iestatual = estoq.estatual.
             
                     find first tt-inv where
                                tt-inv.procod   = string(produ.procod) 
                                exclusive-lock no-error.
                     if avail tt-inv
                     then do:
                             message "Produto ja cadastrado!" 
                                     view-as alert-box.
                             undo, retry.        
                     end.
                     else do:
                            create tt-inv.
                            assign tt-inv.clacod   = produ.clacod
                                   tt-inv.nomgrupo = string(cClanom,"x(30)")
                                   tt-inv.procod   = string(produ.procod,">>>>>9")
                                   tt-inv.pronom   = string(produ.pronom,"x(50)")
                                   tt-inv.prounven = string(produ.prounven,"x(03)")
                                   tt-inv.estcusto = string((iestcusto * 100),"->>>>>>>99") 
                                   tt-inv.estatual = string((iestatual),"->>>>>9")
                                   tt-inv.catcod   = produ.catcod
                                                                   tt-inv.ean      = string(produ.proindice,"x(15)").

                            find first categoria where
                                       categoria.catcod = produ.catcod 
                                       no-lock no-error.
                            if avail categoria 
                            then assign tt-inv.catnom = 
                                 categoria.catnom.
                     end.
             end. 
     end.
     
     run pi-atualiza.
     
end. 

hide frame f-browse-1.

end procedure.

procedure pi-sele4:

   for each produ where
            produ.catcod = (if icatcod <> 0
                           then icatcod
                           else produ.catcod) no-lock:
    {&inatprod} /* Filtra inativo */
    
    if cfabcod > 0 and
       produ.fabcod <> cfabcod
    then next.
    if sclacod > 0 and
       produ.clacod <> sclacod
    then next.   

    if produ.catcod = 41 
    then do:
            find first cmovim use-index movim3
                       where cmovim.procod = produ.procod and
                             cmovim.etbcod = vetbcod and
                             cmovim.movdat >= (today - 730) no-lock no-error.
            if not avail cmovim
            then do:
                
                find first dmovim use-index desti
                           where dmovim.procod = produ.procod and
                                 dmovim.desti = vetbcod and
                                 dmovim.datexp >= (today - 730) 
                                 no-lock no-error.
                if not avail dmovim
                then next.
                
            end.                 
    end.
    
    find first estoq where
               estoq.procod = produ.procod and
               estoq.etbcod = vetbcod no-lock no-error.
    if avail estoq
    then do:
             find first clase where
                        clase.clacod = produ.clacod no-lock no-error.
             if avail clase
             then assign cClaNom = clase.clanom.            
             else assign cClaNom = "".
             
             find first estoq where
                        estoq.procod = produ.procod   and
                        estoq.etbcod = vetbcod        no-lock no-error.
             if avail estoq
             then assign iestcusto = round(estoq.estcusto,2)
                         iestatual = estoq.estatual.
             else assign iestcusto = ?
                         iestatual = ?.
             
             find first tt-inv where
                        tt-inv.procod   = string(produ.procod) 
                        exclusive-lock no-error.
             if not avail tt-inv
             then do:
                     disp "AGUARDE PROCESSANDO..!"  
                          with frame f-msg1 row 16 col 25.
                     pause 0 no-message.
                     
                     create tt-inv.
                     assign tt-inv.clacod   = produ.clacod
                            tt-inv.nomgrupo = string(cClanom,"x(30)")
                            tt-inv.procod   = string(produ.procod,">>>>>9")
                            tt-inv.pronom   = string(produ.pronom,"x(50)")
                            tt-inv.prounven = string(produ.prounven,"x(03)")
                            tt-inv.estcusto = string((iestcusto * 100),"->>>>>>>99")
                                                        tt-inv.estatual = string((iestatual),"->>>>>9")
                            tt-inv.catcod   = produ.catcod
                                                        tt-inv.ean      = string(produ.proindice,"x(15)").

                     find first categoria where
                                categoria.catcod = produ.catcod 
                                no-lock no-error.
                     if avail categoria 
                     then assign tt-inv.catnom = categoria.catnom.           
             end.                      
     end.
   end. 

hide frame f-msg1.
    
end procedure.

procedure pi-sele5:

    repeat:
    vetbcod = 0.
    vnumero = 0.
    hide frame f2 no-pause.
    hide frame f-com1 no-pause.
    hide frame f-com2 no-pause.
    hide frame f-linha no-pause.
    clear frame f1 no-pause.
    update vetbcod column-label "Estab.Origem " 
                with frame f-inf2 row 14 col 1 width 80
                          title "INFORME DADOS DO FILTRO" 
                                    overlay down.

    find estab where estab.etbcod = vetbcod no-lock.
    
    disp estab.etbnom no-label with frame f-inf2.
    
    update vnumero  label "Nota Fiscal  " skip 
                    with frame f-inf2  .
                    
    if vnumero <> 0
    then do:
        find last plani where 
                  plani.movtdc = 6 and
                  plani.etbcod = vetbcod and
                  plani.emite  = vetbcod and
                  plani.serie  = "U" and
                  plani.numero = vnumero
                  no-lock no-error.
        if not avail plani 
        then do:
            message "Nota nao Econtrada" view-as alert-box.
            undo, retry.
        end.
        for each movim where movim.etbcod = plani.etbcod and
                             movim.placod = plani.placod and
                             movim.movtdc = plani.movtdc and
                             movim.movdat = plani.pladat
                             no-lock:
            find produ where produ.procod = movim.procod no-lock no-error.
            if not avail produ then next. 

            find first clase where
                        clase.clacod = produ.clacod no-lock no-error.
            if avail clase
            then assign cClaNom = clase.clanom.            
            else assign cClaNom = "".
             
             find first estoq where
                        estoq.procod = produ.procod   and
                        estoq.etbcod = vetbcod        no-lock no-error.
             if avail estoq
             then assign iestcusto = round(estoq.estcusto,2)
                         iestatual = movim.movqtm.
             else assign iestcusto = ?
                         iestatual = ?.

            find first tt-inv where
                        tt-inv.procod   = string(produ.procod) 
                        exclusive-lock no-error.
            if not avail tt-inv
            then do:
                     disp "AGUARDE PROCESSANDO..!"  
                          with frame f-msg1 row 16 col 25.
                     pause 0 no-message.
                     
                     create tt-inv.
                     assign tt-inv.clacod   = produ.clacod
                            tt-inv.nomgrupo = string(cClanom,"x(30)")
                            tt-inv.procod   = string(produ.procod,">>>>>9")
                            tt-inv.pronom   = string(produ.pronom,"x(50)")
                            tt-inv.prounven = string(produ.prounven,"x(03)")
                            tt-inv.estcusto = string((iestcusto * 100),"->>>>>>>99") 
                            tt-inv.estatual = string((iestatual),"->>>>>9")
                            tt-inv.catcod   = produ.catcod
                                                        tt-inv.ean      = string(produ.proindice,"x(15)").

                     find first categoria where
                                categoria.catcod = produ.catcod 
                                no-lock no-error.
                     if avail categoria 
                     then assign tt-inv.catnom = categoria.catnom.           
             end.
        end.
     end.
     end.

hide frame f-msg1.
    
end procedure.


/* ------------------------------------------------------------------------- */

{&open-query}.

enable {&list-1}
       b_inv with frame {&frame-name}.
       
apply "leave" to rd-selecao.

wait-for window-close of current-window.