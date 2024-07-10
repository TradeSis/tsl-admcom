/**********************************************************************
* Coanfecx.p    Consultas Analiticas de Caixas (Parte I - Resumo) 
*               Individuais ou por Estabelecimentos
* Data     :    13/05/2009
* Autor    :    Antonio Maranghello
*
***********************************************************************/
{admcab.i}
{setbrw.i}
def var aux-vl-cart as dec.   
def var aux-vljuro  as dec.     

def new shared temp-table d-titulo like fin.titulo.
def var val-pago as dec.
def var v-gravou-ana as logical initial no.     
def new shared var v-flg-achou as int.
def new shared var val-anali-opc as dec.
def new shared var v-soma-caixa  as dec.
def new shared var vnext       as logical.
def new shared var qtd-pagar   as int.
def new shared var vchedia     like titulo.titvlcob.
def new shared var vpag        like titulo.titvlcob.
def new shared var vpredre     like titulo.titvlcob.
def new shared var vlnov       like titulo.titvlcob.  
def new shared var vlpagcartao like plani.platot.
def new shared var vdevolucao  like plani.platot.
def new shared var vdeposito   like plani.platot.
def new shared var vcaixa      like titulo.cxacod.
def new shared var vetbcod     as int.
def new shared var qtd-cart    as int.
def new shared var gloqtd      as int.
def new shared var vcx         as int.
def new shared var totglo      like globa.gloval.
def new shared var vlpres      like plani.platot.
def new shared var vlauxt      like plani.platot.
def new shared var vcta01      as char format "99999".
def new shared var vcta02      as char format "99999".
def new shared var vdata       like titulo.titdtemi.
def new shared var vl-pagar    like titulo.titvlpag.
def new shared var vl-cart     like titulo.titvlpag.
def new shared var vpago       like titulo.titvlpag.
def new shared var vdesc       like titulo.titdesc.
def new shared var vjuro       like titulo.titjuro.
def new shared var sresumo     as log format "Resumo/Geral" initial yes.
def new shared var wpar        as int format ">>9" .
def new shared var p-juro      as dec.
def new shared var vcxacod     like titulo.cxacod.
def new shared var vmodcod     like titulo.modcod.
def new shared var vlvist      like plani.platot.
def new shared var vlpraz      like plani.platot.
def new shared var vlentr      like plani.platot.
def new shared var vljuro      like plani.platot.
def new shared var vldesc      like plani.platot.
def new shared var vlpred      like plani.platot.
def new shared var vldev       like plani.platot.
def new shared var vldevvis    like plani.platot.
def new shared var vljurpre    like plani.platot.
def new shared var vlsubtot    like plani.platot.
def new shared var vtot        like plani.platot.
def new shared var vnumtra     like plani.platot.
def new shared var total_cheque_devolvido   like plani.platot.
def new shared var  conta_cheque_devolvido as int.
def new shared var ct-vist        as   int.
def new shared var ct-praz        as   int.
def new shared var ct-entr        as   int.
def new shared var ct-pres        as   int.
def new shared var ct-juro        as   int.
def new shared var ct-desc        as   int.
def new shared var ct-dev         as   int.
def new shared var ct-nov         as   int.
def new shared var ct-devvis      as   int.
def new shared var ct-devolucao   as   int.
def new shared var ct-pagcartao   as   int.
def new shared var vqtdcart       as   int.
def new shared var vconta         as   int.
def new shared var vachatextonum  as char.
def new shared var vachatextoval  as char.
def new shared var vvalor-cartpre as dec.
def new shared var vdtexp         as   date.
def new shared var vdtimp         as   date.
def new shared var vdescricao     as char format "x(60)".
def var esqcom2         as char format "x(15)" extent 2
    initial [" Analitico ","F4 - Encerrar"].

def var esqhel1         as char format "x(80)" extent 5
    initial ["  ",
             "",
             "",
             "",
             ""].
                
def var v-opcao-ana as char extent 13 format "X(15)" initial     
    [ "Valor Prazo ",
      "Vendas Vista",
      "Entradas    ",    
      "Prestacoes  ",  
      "Juros       ",  
      "Descontos   ",  
      "Devolucao   ",  
      "Novacao     ",   
      "Cheq.Devolv.",
      "Desp.Finan I", 
      "Cheq.Dia    ",  
      "Cheq.Pre-Drebes ",  
      "Cartao Credito" ].                          
         
def var v-opcao-ana-ind as int extent 15 format ">9" initial  
[1,2,3,4,5,6,8,10,11,12,13,15,16].   


def buffer bmoeda for moeda.


def temp-table tt-cartpre  no-undo
    field seq    as int
    field numero as int
    field valor as dec.

/* Table de caixas p/Dragao */ 
def new shared temp-table tt-work-caixa no-undo
    field etbcod like estab.etbcod
    field cxacod like caixa.cxacod.


/********* Tipo de Registro tt-caixa-anali *********
1-  Valor a Prazo           2-  Vendas  a Vista   
3-  Entradas                4-  Prestacoes      
5-  Juros                   6-  Descontos      
7-  Val./Quant. Entradas    8-  Devolucao              
9-  Global                 10-  Novacao
11- Valor Descontos        12-  Cheq.Dia
13- Valor Depoósito        14-  Cheq.Drebes
15- Cartao Credito  
***************************************************/ 
def new shared temp-table tt-caixa-anali no-undo
    field etbcod  like estab.etbcod
    field cxacod  like caixa.cxacod label "Caixa"
    field numdoc  as   char         label "Documento" format "x(25)"
    field data    as   date  format "99/99/9999"
    field tpreg   as   int              
    field clifor  like titulo.clifor    
    field vlcob   like titulo.titvlcob
    field vltrans  like titulo.titvlcob        
    field ctaprazo as int
    field ctavista as int
    field parcela  like titulo.titpar    /* 0 - 999 (zero a Vista) */
    field modcod as char               /* CRE - VDV - VDP - ENT etc... */ 
    field qttrans as int
    field moecod like titulo.moecod
    field cxmhora as int
    index key1  etbcod 
                clifor
                data    
                cxmhora
                cxacod 
                numdoc 
                tpreg
    index key2  numdoc.  
    
def new shared temp-table tt-aux-lis like tt-caixa-anali.

for each tt-caixa-anali:
    delete tt-caixa-anali.
end.    

for each tt-work-caixa:
    delete tt-work-caixa.
end.
def var vestab as log.
def var cestab like estab.etbnom.

def new shared temp-table wfestab
    field etbcod        like estab.etbcod init 0.
def buffer bwfestab    for wfestab.



form
    vEstab    colon 30    label "Todos Estabelecimentos.."
                help "Relatorio com Todos os Estabelecimentos ?"
    cestab no-label format "x(40)"
    with frame fopcoes row 3 side-label width 80.

do with 1 down side-label width 80 row 3 color blue/white:
   /***
   if sparam = "totais"
   then do:
   end.
   else do:
   update vetbcod label "Estabelecimento" format "zz9". 
   if vetbcod <> 0
   then do:
        find estab where estab.etbcod = vetbcod no-lock no-error.
        if not avail estab 
        then do:
            message "Estabelecimento nao Cadastrado" view-as alert-box.
            undo, retry.
        end.
        display estab.etbnom no-label.
   end.                
   else disp "Geral " @ estab.etbnom.
   end.
   ***/
   
   {filtro-estab.i}
   
   update vdata with frame fopcoes.
   update vcaixa with frame fopcoes.

   run conecta_d.p.
    
   for each d-titulo: delete d-titulo. end.
   
   for each wfEstab :
        run titulo-d-titulo.p(input wfestab.etbcod, input vdata).    
   end.

    if connected ("d")
    then disconnect "d".
   
   
   assign vcta01 = string(estab.prazo,"99999")
          vcta02 = string(estab.vista,"99999").

   assign  vlpraz    = 0 vlvist   = 0 vlauxt = 0
           vlentr    = 0 vljuro   = 0  aux-vl-cart = 0
           vldev     = 0 vldesc   = 0 vldevvis = 0
           ct-pres   = 0 ct-juro  = 0 ct-desc = 0 
           ct-vist   = 0 ct-praz  = 0 vpredre = 0 
           vljurpre  = 0 vnumtra  = 0 ct-dev = 0
           ct-devvis = 0 vlpres   = 0.

   assign totglo = 0.
   
   for each estab where estab.etbcod = (if vetbcod <> 0 then vetbcod 
                                                       else estab.etbcod) 
        no-lock:                                       
        
        if not( estab.etbnom begins "DREBES-FIL" ) then next.
        for each globa where globa.glodat = vdata no-lock :
            totglo = totglo + globa.gloval.
        end.
  end.
  
  run Pi-Processa. /* Processa Banco Local */
  
  if setbcod = 999 then do:
        run conecta_d.p .
        run coanfecx_d.p. /* Processa Dragao */ 
        disconnect d.
  end.
  
  
  /* Principal */

  l20: 
    repeat :
    run Pi-Disp-geral.
    pause 0.
    choose field esqcom2 with frame f-com2.
    if frame-index = 1 
    then do:
      disp " Selecione -> " with frame f-seta
            row 20 col 40 no-box overlay.
      pause 0.
      disp v-opcao-ana with 1 col 
              with frame f-selana row 19 col 55
                no-labels width 17 overlay no-box.

      choose field v-opcao-ana with frame f-selana.
      for each tt-aux-lis:
        delete tt-aux-lis.
      end.
      assign val-anali-opc = 0.

      /*
      if sfuncod = 100
      then do:
            for each tt-caixa-anali where tt-caixa-anali.tpreg = 13:
                disp tt-caixa-anali.etbcod tt-caixa-anali.tpreg tt-caixa-anali.vltrans (total).
            end.
            pause.
      end.
      */
      
      for each tt-caixa-anali :
        if vetbcod <> 0 and tt-caixa-anali.etbcod <> vetbcod then next.
        if vcaixa  <> 0 and tt-caixa-anali.cxacod <> vcaixa then next. 
        if int(tt-caixa-anali.tpreg) = int(v-opcao-ana-ind[frame-index]) and
           tt-caixa-anali.vltrans <> 0 and tt-caixa-anali.vltrans <> ?
        then do :
           create tt-aux-lis.
           buffer-copy tt-caixa-anali to tt-aux-lis.
            assign val-anali-opc = val-anali-opc + tt-caixa-anali.vltrans.
        end.
      end.

      vdescricao =  v-opcao-ana[frame-index] + " : R$ " + 
      string(val-anali-opc,">,>>>,>>9.99") + "      Caixa : " +
      (if vcaixa <> 0 then string(vcaixa) else "Geral"). 
      hide frame f-com2.
      run coanfecx_a.p(input vdescricao, input val-anali-opc).
    end.
    next.
  end.  

end.
      
Procedure Pi-Disp-Geral.

pause 0.
def var vtotaux1 as dec.
def var vtotaux2 as dec.
def var vtotaux3 as dec.
aux-vljuro = 0.
for each tt-caixa-anali where tt-caixa-anali.tpreg  = 5 no-lock.
    aux-vljuro = aux-vljuro + tt-caixa-anali.vltrans.
end.            




    assign  vtotaux1 = vlvist + vlentr + vlpres + /*vljuro*/
                                                aux-vljuro
                              + total_cheque_devolvido
                               - vldesc - vdevolucao + totglo - vlnov.
    disp  
      vlpraz  
      label " 1.Val. Prazo   " format "->>>,>>9.99"                                      ct-praz label "Qt" format ">>>9" "" skip
      vlvist  
      label " 2.Val. Vista   " format "->>>,>>9.99"                                      ct-vist label "Qt" format ">>>9" "" skip
      vlentr  
      label " 3.Entrada      " format "->>>,>>9.99"                                    ct-entr label "Qt" format ">>>9" "" skip
      vlpres  
      label " 4.Prestacoes   " format "->>>,>>9.99"                                    ct-pres label "Qt" format ">>>9" ""  skip
      aux-vljuro @ vljuro  label " 5.Juros        " format "->>>,>>9.99"
                          ct-juro label "Qt" format ">>>9" "" skip
      vldesc  
      label " 6.Descontos    " format "->>>,>>9.99"                                    ct-desc label "Qt" format ">>>9" 
      vl-pagar  label "Desp.Financeiras I" format "->>>,>>9.99" skip                 
   /*
      vldev  label " 7.Devol. Prazo    "
      ct-dev no-label format ">>>>>>9"  to 40 skip
   */
   vdevolucao   label " 8.Devolucao    " format "->>>,>>9.99"
   ct-devolucao label "Qt" format ">>>9"  
   vchedia   label "Cheque  Dia  R$   "   format "->>>>,>>9.99"                
   totglo    label " 9.Global       "  format "->>>,>>9.99"                       gloqtd    label "Qt" format ">>>9"  
   vpredre   label "Cheque Pre-Drebes "  format "->>>,>>9.99"  
   vlnov     label "10. Novacao     "   format "->>>,>>9.99"                   
   ct-nov    label "Qt" format ">>>9"  
   vdeposito 
   label "Deposito     R$   "  format "->>>,>>9.99"                       
   total_cheque_devolvido
   label "11. Cheque Devol" format "->>>,>>9.99"                                
   conta_cheque_devolvido label "Qt" format ">>>9"
   aux-vl-cart @ vl-cart label "Cartao Credito    "  format "->>>,>>9.99"  
    with  with frame fresumo row 7
                     no-box side-labels.           
   
     assign vtotaux2 =  vpag + vchedia + vdeposito 
                             + vpredre + vl-pagar + /*vl-cart*/ 
                                                    aux-vl-cart.

     assign vtotaux3 = vtotaux2 - vtotaux1.
     
     disp vtotaux1 label "TOTAL PROCESSADO "  format "->>,>>,>>>,>>9.99"  
          vtotaux2 label "TOTAL NUMERARIO  "  format "->>,>>,>>>,>>9.99"  
          vtotaux3 label "DIFERENCA        "  format "->>,>>,>>>,>>9.99"  
             with 1 col with frame fresumo3 no-box WIDTH 60.
 
     disp esqcom2 no-labels with frame f-com2 row 22 no-box
     width 40.

end procedure.
      
Procedure pi-processa. 
     
def var vmostra as char format "x(15)".
def var vfase   as char format "x(25)".

assign vpredre = 0
       vchedia = 0
       vdeposito = 0.

do with frame fdisplay:

for each estab where  ( if vetbcod > 0
                        then estab.etbcod = vetbcod else true)
                        no-lock:
     
     find first wfEstab where wfEstab.Etbcod = Estab.Etbcod no-error.
              if not avail wfEstab
                       then next.
                       

      if not( estab.etbnom begins "DREBES-FIL" ) then next.
      
      vetbcod = estab.etbcod.
      
      if vetbcod <> 0 and estab.etbcod <> vetbcod then next.
      
      find first deposito where deposito.etbcod = estab.etbcod
            and deposito.datmov = vdata no-lock no-error.
                           
      if avail deposito and vcaixa = 0
      then assign vdeposito = vdeposito + deposito.depdep.
      
    disp "Filial : " + string(estab.etbcod) + " Fase 1 " @ vfase      
          with frame fdisplay no-labels no-box centered row 10.
        pause 0.
    
    /* cheq a vista */
    for each caixa where (if vetbcod > 0
                          then caixa.etbcod = vetbcod else true)
                          no-lock:
        
      if vcaixa <> 0 and caixa.cxacod <> vcaixa then next.
      for each chq where chq.datemi = vdata no-lock:

          find first chqtit where chqtit.banco   = chq.banco and
                              chqtit.agencia = chq.agencia and
                              chqtit.conta   = chq.conta and
                              chqtit.numero  = chq.numero and
                              chqtit.etbcod = estab.etbcod
                              no-lock no-error.
          if not avail chqtit then next.
          if chqtit.etbcod <> caixa.etbcod then next.
          find first titulo where titulo.empcod = 19 and
                     titulo.titnat = chqtit.titnat   and
                     titulo.modcod = chqtit.modcod   and
                     titulo.etbcod   = chqtit.etbcod and
                     titulo.clifor   = chqtit.clifor and
                     titulo.titnum   = chqtit.titnum and
                     titulo.titpar   = chqtit.titpar
                     no-lock no-error. 
          if avail titulo then /* next. */
          if titulo.cxacod <> caixa.cxacod then next.
          if chq.data <= vdata
          then do:
                 assign v-gravou-ana = no.
                 run Pi-Cria-Anali(input "cheque", input 13,
                                   input "", input "",
                                   input 0,  input chq.valor, 1).
                 if v-gravou-ana
                 then assign vchedia = vchedia + chq.valor.
          end.
          if chq.data > vdata
          then do:
                assign v-gravou-ana = no.
                run Pi-Cria-Anali(input "cheque", input 15,
                                   input "", input "",
                                   input 0, input chq.valor, 1).
                if v-gravou-ana then  assign vpredre = vpredre + chq.valor.
          end.
      end.
    
    end.

    for each contrato where contrato.dtinicial = vdata and
                                contrato.etbcod = estab.etbcod no-lock:

        if substr(string(contrato.contnum,"9999999999"),9,2) = "00"
        then next.
        
        
        find first contnf where contnf.contnum = contrato.contnum and
                          contnf.etbcod = contrato.etbcod
                          no-lock no-error.
        if avail contnf
        then do:
            find first plani where plani.etbcod = contnf.etbcod and
                         plani.placod = contnf.placod and
                         plani.movtdc = 5 and
                         plani.pladat = contrato.dtinicial
                         no-lock no-error.
            if avail plani 
            then do:
                if vcaixa > 0 and plani.cxacod <> vcaixa
                then next.   
                /*
                if (plani.platot - plani.vlserv) > contrato.vltotal
                then next.
                */ 
            end.
        end.
        
        if contrato.etbcod  = estab.etbcod
        then do :
                assign  ct-praz = ct-praz + 1
                        vlpraz  = vlpraz + contrato.vltotal.
                /* Val.Prazo (Contratos) */
                run Pi-Cria-Anali(input "contrato", input 1, 
                                  input "", input "",
                                  input 0, 
                                  input contrato.vltotal, input 1).
        end.                      
    end.

    disp "Filial : " + string(estab.etbcod) + " Fase 2 "  @ vfase 
                 with frame fdisplay no-labels no-box centered row 10.
            pause 0.

    for each titulo  
             where titulo.etbcobra = estab.etbcod and  /* tttt */
                 titulo.titdtpag = vdata   /*** and
                 titulo.modcod   = "CAR"***/ no-lock.
            /*
            if vcaixa <> 0 and titulo.cxacod <> vcaixa then next.
            if vcaixa <> 0
            then do:
                find first caixa where caixa.etbcod = estab.etbcod and
                                       caixa.cxacod = vcaixa
                                       no-lock no-error.
                if not avail caixa then next.
                if titulo.cxacod <> caixa.cxacod
                then next.
            end.
            */
            
            if titulo.titsit <> "PAG" then next.
            if titulo.moecod <> "CAR" and
               titulo.moecod <> "PDM" then next.
        
            if titulo.moecod <> "PDM"
            then do:
                qtd-cart = qtd-cart + 1.
                
                vl-cart = vl-cart + titulo.titvlpag.
                run Pi-Cria-Anali(input "titulo", input 16, 
                              input titulo.modcod, input "",
                              input 0, input titulo.titvlpag, 
                              input 1).
                aux-vl-cart = aux-vl-cart + titulo.titvlpag.
                                              
            end.
            else do:
                for each titpag where
                        titpag.empcod = titulo.empcod and
                        titpag.titnat = titulo.titnat and
                        titpag.modcod = titulo.modcod and
                        titpag.etbcod = titulo.etbcod and
                        titpag.clifor = titulo.clifor and
                        titpag.titnum = titulo.titnum and
                        titpag.titpar = titulo.titpar
                        no-lock: 
                    if titpag.moecod = "CAR"
                    then do:
                        qtd-cart = qtd-cart + 1.
                        vl-cart = vl-cart + titpag.titvlpag.
                        aux-vl-cart = aux-vl-cart + titpag.titvlpag.

                        run Pi-Cria-Anali(input "titulo", input 16, 
                              input titulo.modcod, input titpag.moecod,
                              input titpag.cxmhora, input titpag.titvlpag, 
                              input 1).
                    end.
                end.
            end.

            /****
            /**** Laureano - Descarte comentado para atender chamado 29696*** 
            if titulo.etbcod <> estab.etbcod then next.
            */
            if titulo.titsit <> "PAG" then next.
            
            if titulo.moecod <> "CAR" and
                titulo.moecod <> "PDM"
            then next.

            if titulo.moecod = "CAR"
            then do:
                qtd-cart = qtd-cart + 1.        
                vl-cart = vl-cart + titulo.titvlpag.
                aux-vl-cart = aux-vl-cart + titulo.titvlpag.
            end.
            /* C.Credito */
            run Pi-Cria-Anali(input "titulo", input 16, 
                              input titulo.modcod, input titulo.titvlpag, 
                              input 1).
           ****/
           

    end.
    
    for each d-titulo  
             where d-titulo.etbcobra = estab.etbcod and
                 d-titulo.titdtpag = vdata   
                 no-lock.
            
            if d-titulo.titsit <> "PAG" then next.
            if d-titulo.moecod <> "CAR" and
               d-titulo.moecod <> "PDM" then next.
        
            find first titulo where
                       titulo.empcod = d-titulo.empcod and
                       titulo.titnat = d-titulo.titnat and
                       titulo.modcod = d-titulo.modcod and
                       titulo.etbcod = d-titulo.etbcod and
                       titulo.clifor = d-titulo.clifor and
                       titulo.titnum = d-titulo.titnum and
                       titulo.titpar = d-titulo.titpar
                       no-lock no-error.
            if avail titulo then next.            
            if d-titulo.moecod <> "PDM"
            then do:
                qtd-cart = qtd-cart + 1.
                
                vl-cart = vl-cart + d-titulo.titvlpag.
                run Pi-Cria-Anali(input "d-titulo", input 16, 
                              input d-titulo.modcod, input "",
                              input 0, input d-titulo.titvlpag, 
                              input 1).
                aux-vl-cart = aux-vl-cart + d-titulo.titvlpag.
                                              
            end.
            else do:
                for each titpag where
                        titpag.empcod = d-titulo.empcod and
                        titpag.titnat = d-titulo.titnat and
                        titpag.modcod = d-titulo.modcod and
                        titpag.etbcod = d-titulo.etbcod and
                        titpag.clifor = d-titulo.clifor and
                        titpag.titnum = d-titulo.titnum and
                        titpag.titpar = d-titulo.titpar
                        no-lock: 
                    if titpag.moecod = "CAR"
                    then do:
                        qtd-cart = qtd-cart + 1.
                        vl-cart = vl-cart + titpag.titvlpag.
                        aux-vl-cart = aux-vl-cart + titpag.titvlpag.

                        run Pi-Cria-Anali(input "d-titulo", input 16, 
                              input d-titulo.modcod, input titpag.moecod,
                              input titpag.cxmhora, input titpag.titvlpag, 
                              input 1).
                    end.
                end.
            end.


    end.

    
    /***
    for each caixa where caixa.etbcod = estab.etbcod no-lock:  
        if vcaixa <> 0 and caixa.cxacod <> vcaixa then next.  

         for each titulo where titulo.datexp = vdata no-lock.
                if titulo.datexp <> titulo.cxmdat  then next.
                if titulo.titdtpag <> vdata then next.
                if titulo.cxacod <> caixa.cxacod then next.
                if vmodcod <> "CRE" then next.
                if titulo.moecod = "PRE"  
                then assign  vljurpre = vljurpre + titulo.titjuro.
         end.
         
    end.
    ***/
    disp "Filial : " + string(estab.etbcod) +  " Fase 3 " @ vfase
        with frame fdisplay no-labels no-box centered row 10.
    pause 0.

    for each caixa where caixa.etbcod = estab.etbcod no-lock:
         
          if vcaixa <> 0 and caixa.cxacod <> vcaixa then next.
        
        for each titulo where titulo.empcod = 19
                      and titulo.titnat = no
                      and titulo.modcod = "CHQ" 
                      and titulo.etbcod = estab.etbcod no-lock:

            if titulo.etbcobra <> estab.etbcod then next.
            if titulo.cxacod <> caixa.cxacod
            then next.
        
            if titulo.titdtpag = vdata
            then do:
                    assign total_cheque_devolvido = total_cheque_devolvido +  
                                             titulo.titvlpag
                    conta_cheque_devolvido = conta_cheque_devolvido + 1.
      
                /* Cheque Devolvido */
                run Pi-Cria-Anali(input "titulo", input 11, 
                              input titulo.modcod, input "",
                              input 0, input titulo.titvlpag, 
                              input 1).
             end.
        end.
 
    end.

    disp "Filial : " + string(estab.etbcod) + " Fase 4  " @ vfase  
        with frame fdisplay no-labels no-box centered row 10.
    pause 0.

    for each titulo where titulo.etbcobra = estab.etbcod and
                          titulo.titdtpag = vdata
                          no-lock        .

            if titulo.titnat = yes
            then next.

            if vcaixa <> 0 and titulo.cxacod <> vcaixa then next.
            
            if titulo.etbcobra <> estab.etbcod
            then next.
            if titulo.cxmdat <> vdata
            then next.
            if titulo.titdtpag = ?
            then next.
            if titulo.titsit = "LIB"
            then next.
            if titulo.titdtpag <> vdata
            then next.
            if titulo.titpar    = 0
            then next.
            if titulo.clifor = 1
            then next.
            if titulo.modcod = "LUZ"
            then next.
            /*
            find first caixa where  caixa.etbcod = estab.etbcod and
                                    caixa.cxacod = titulo.cxacod 
                                    no-lock no-error.
            if not avail caixa then next.
            */
            if titulo.modcod = "VVI" or titulo.modcod = "CHQ" or
               titulo.modcod = "CHP" /** Masiero **/
            then next.
            if titulo.modcod = "CRE" and titulo.moecod = "DEV" then next.
            
            if titulo.moecod = "PDM"
            then do:
                for each titpag where
                           titpag.empcod = titulo.empcod and
                           titpag.titnat = titulo.titnat and
                           titpag.modcod = titulo.modcod and
                           titpag.etbcod = titulo.etbcod and
                           titpag.clifor = titulo.clifor and
                           titpag.titnum = titulo.titnum and
                           titpag.titpar = titulo.titpar
                           no-lock:
                    find bmoeda where bmoeda.moecod = titpag.moecod
                                no-lock no-error.
                    if avail bmoeda
                    then do:
                        if bmoeda.moetit = yes
                        then vlpagcartao = vlpagcartao + titpag.titvlpag.
                        else do:
                            vlpres = vlpres +  titpag.titvlpag.
                            run Pi-Cria-Anali(input "titulo", input 4, 
                               input titpag.modcod, input titpag.moecod,
                               input titpag.cxmhora,
                               input titpag.titvlpag, 
                               input 1).
                        end.
                        if bmoeda.moecod = "PRE"
                        then assign  vljurpre = vljurpre + titulo.titjuro.

                    end.
                    else do:
                        vlpres = vlpres +  titpag.titvlpag.
                        run Pi-Cria-Anali(input "titulo", input 4, 
                               input titpag.modcod, input titpag.moecod,
                               input 0, input titpag.titvlpag, 
                               input 1).
                        if titpag.moecod = "PRE"
                        then assign  vljurpre = vljurpre + titulo.titjuro.

                    end.
                end.
            end.
            else do:        
                
                /*if titulo.titvlcob > titulo.titvlpag
                then val-pago = titulo.titvlpag.
                else*/ 
                val-pago = titulo.titvlcob.
                
                find bmoeda where 
                    bmoeda.moecod = titulo.moecod no-lock no-error.

                if avail bmoeda
                then do:
           
                    if bmoeda.moetit = yes
                    then do:
                        vlpagcartao = vlpagcartao + val-pago.
                    end.
                    else do:
                        vlpres = vlpres + val-pago.
                        run Pi-Cria-Anali(input "titulo", input 4, 
                           input titulo.modcod, input titulo.moecod,
                           input 0, input val-pago, 
                           input 1).
                    end.    
                    if bmoeda.moecod = "PRE"
                        then assign  vljurpre = vljurpre + titulo.titjuro.
                end.
                else do:
                    vlpres = vlpres + val-pago.
                    run Pi-Cria-Anali(input "titulo", input 4, 
                               input titulo.modcod, input titulo.moecod,
                               input 0, input val-pago, 
                               input 1).
                    if titulo.moecod = "PRE"
                        then assign  vljurpre = vljurpre + titulo.titjuro.
                end.    
            end.
            if titulo.moecod = "NOV"
            then do:
                    assign vlnov  = vlnov + titulo.titvlcob
                           ct-nov = ct-nov + 1.
                           run Pi-Cria-Anali(input "titulo", input 10, 
                           input titulo.modcod, input titulo.moecod,
                           input 0, input titulo.titvlcob, 
                           input 1).
            end.
    end.

 disp "Filial : " + string(estab.etbcod) + " Fase 5  " @ vfase                      with frame fdisplay no-labels no-box centered row 10.
 pause 0.

 
 for each caixa where caixa.etbcod = estab.etbcod no-lock:
        
        if vcaixa <> 0 and caixa.cxacod <> vcaixa then next.

        for each titulo where  titulo.etbcobra = estab.etbcod and
                               titulo.titdtpag = vdata
                               no-lock:
            
            if titulo.modcod = "VVI" or
               titulo.modcod = "CHQ" /*or
               titulo.moecod = "CAR"*/
            then next.
               
            if titulo.cxacod   = caixa.cxacod and
                titulo.etbcod   = estab.etbcod and
               titulo.titpar   = 0            and
               titulo.titdtpag = vdata        
            then do:
                assign ct-entr = ct-entr + 1
                       vlentr  = vlentr  + titulo.titvlcob.
                run Pi-Cria-Anali(input "titulo", input 3,                                                         input titulo.modcod, 
                                    input titulo.moecod,
                                    input 0, input titulo.titvlcob,
                                  input 1).
            end.
        end.
 end.
 disp "Filial : " + string(estab.etbcod) + " Fase 6  " @ vfase                             with frame fdisplay no-labels centered row 10.
            pause 0.

 for each caixa where caixa.etbcod = estab.etbcod no-lock:
  
         if vcaixa <> 0 and caixa.cxacod <> vcaixa then next.
        
         for each titulo where  titulo.etbcobra = estab.etbcod and
                                titulo.titdtpag = vdata
                                no-lock.
         /*titulo.datexp = vdata 
                and titulo.cxacod = caixa.cxacod no-lock. */
                        assign vmodcod = titulo.modcod.
            if titulo.datexp <> titulo.cxmdat
            then next.
            if titulo.titdtpag <> vdata
            then next.

            if titulo.etbcobra <> estab.etbcod
            then next.
            
            /***
            if titulo.modcod = "CHQ"
            then do.
                vljuro = vljuro + titulo.titjuro.
                next.
            end.
            ***/
            
            if titulo.titdtpag = ?
            then vmodcod = "VDP".
            
            if titulo.cxacod <> caixa.cxacod
            then next.
            
            if titulo.titpar    = 0 or
               titulo.clifor    = 1
            then do:
                if titulo.clifor = 1
                then vmodcod = "VDV".
                else vmodcod = "ENT".
            end.

            if titulo.modcod = "VVI"
            then vmodcod = "VDV".

            if titulo.modcod = "CRE"
            then do:
             
                assign vljuro = vljuro + titulo.titjuro
                       vldesc = vldesc + titulo.titdesc.
                p-juro = 0.
                if titulo.titjuro > 0
                then
                run Pi-Cria-Anali(input "titulo", input 5, 
                           input titulo.modcod, input titulo.moecod,
                           input 0, input titulo.titjuro, 
                           input 1).
                if titulo.titdesc > 0
                then
                run Pi-Cria-Anali(input "titulo", input 6, 
                           input titulo.modcod, input titulo.moecod,
                           input 0, input titulo.titdesc, 
                           input 1).
            end.

            if vmodcod <> "CRE"
            then next.
            
            find bmoeda where bmoeda.moecod = titulo.moecod no-lock no-error.
            if avail bmoeda
            then do:
                if bmoeda.moetit = yes
                then ct-pagcartao = ct-pagcartao + (if titulo.titvlcob > 0
                                                    then 1 else 0).
                else assign
                        ct-pres = ct-pres + (if titulo.titvlcob > 0
                                          then 1 else 0).
            end.
            else assign
                    ct-pres = ct-pres + if titulo.titvlcob > 0
                                     then 1
                                     else 0.
                                
            ct-juro = ct-juro + if titulo.titjuro > 0
                                then 1
                                else 0.
            ct-desc = ct-desc + if titulo.titdesc > 0
                                then 1
                                else 0.
         end.
 end.

/*
 for each caixa where caixa.etbcod = estab.etbcod no-lock:

        if vcaixa <> 0 and caixa.cxacod <> vcaixa then next.
  */

        for each titulo where titulo.datexp = vdata
                          and titulo.modcod = "DEV"
                          and titulo.etbcod = estab.etbcod
                                                no-lock:
                /*if titulo.cxacod <> caixa.cxacod then next.
                 */
                 
                if titulo.titobs[2] = "DEVOLUCAO" and titulo.titvlpag <> 0
                then do:
                         
                        run Pi-Cria-Anali(input "titulo", input 7, 
                           input titulo.modcod, input titulo.moecod,
                           input 0, input titulo.titvlpag, 
                           input 1).
                        assign vdevolucao = vdevolucao + titulo.titvlpag
                               ct-devolucao = ct-devolucao + 1.
                end.
        end.

for each caixa where caixa.etbcod = estab.etbcod no-lock:

        if vcaixa <> 0 and caixa.cxacod <> vcaixa then next.
         
        /****
    for each movim where /*movim.procod = produ.procod and*/
                             movim.emite  = estab.etbcod      and
                             movim.datexp = vdata no-lock by movim.datexp
                                                          by movim.movtdc desc:
            if movim.movtdc = 22 or movim.movtdc = 30
            or movim.movtdc = 50 or movim.movtdc = 45 or
            movim.movtdc = 31
            then next.
    
            find first plani where plani.etbcod = movim.etbcod and
                                   plani.placod = movim.placod and
                                   plani.movtdc = movim.movtdc and
                                   plani.pladat = movim.movdat no-lock no-error.
            
            if avail plani
            then do:
                if  plani.movtdc = 4 and
                    plani.notsit = yes
                then next. 
                
                /* if plani.emite = 22 and plani.desti = 996
                then next. */
            end.
            else next.
            
            if movim.movtdc = 5  or
               movim.movtdc = 3  or
               movim.movtdc = 6  or
               movim.movtdc = 12 or
               movim.movtdc = 13 or 
               movim.movtdc = 14 or 
               movim.movtdc = 16 or
               movim.movtdc = 59 or
               movim.movtdc = 64 or
               movim.movtdc = 26 or
               movim.movtdc = 46
            then. 
            else next.
            
            if avail plani and plani.modcod = "CAN"
            then next.
            if avail plani and plani.serie = "VC"
            then next.

            if plani.cxacod <> caixa.cxacod then next.

            find tipmov of movim no-lock.
            
            if movim.movtdc = 12
            then do:
                vdevolucao = vdevolucao + movim.movpc.
                ct-devolucao = ct-devolucao + movim.movqtm.
            end.        
    end.
        
             ************/
        
        
        
        disp "Filial : " + string(estab.etbcod) + " Fase  7 " @ vfase 
            with frame fdisplay no-labels centered row 10.
                pause 0.

        for each plani use-index pladat where plani.movtdc = 5 and
                                      plani.etbcod = estab.etbcod and
                                      plani.pladat = vdata no-lock:
                                      
            if plani.cxacod = caixa.cxacod
            then do:
                find titulo where titulo.empcod = wempre.empcod and
                                  titulo.titnat = no            and
                                  titulo.modcod = "CRE"         and
                                  titulo.etbcod = estab.etbcod       and
                                  titulo.clifor = 1             and
                                  titulo.titnum = string(plani.numero) no-lock
                                  no-error.

                if avail titulo
                then do:
                    if plani.crecod = 1 and
                       titulo.titdtpag <> plani.pladat
                    then assign vnumtra = vnumtra + plani.protot
                                                  /* + plani.frete */
                                                  + plani.acfprod.
                end.

                if plani.crecod = 1
                then do:
                    assign ct-vist  = ct-vist + 1
                            vlauxt  = (plani.protot /* + plani.frete */
                                    + plani.acfprod - plani.descprod)
                                    - plani.vlserv.
                            
                            vlvist = vlvist + (plani.protot /* + plani.frete */
                                            + plani.acfprod - plani.descprod)
                                            - plani.vlserv.
                                           
                                           for each tt-cartpre. 
                        delete tt-cartpre. 
                    end.

                    assign vqtdcart = 0
                           vconta   = 0
                           vachatextonum = ""
                           vachatextoval = ""
                           vvalor-cartpre = 0.
                 
                    if plani.notobs[3] <> ""
                    then do:
                        if acha("QTDCHQUTILIZADO",plani.notobs[3]) <> ? 
                        then vqtdcart =
                             int(acha("QTDCHQUTILIZADO",plani.notobs[3])).
                    
                        if vqtdcart > 0 
                        then do: 
                        
                            do vconta = 1 to vqtdcart:  
                                vachatextonum = "". 
                                vachatextonum = "NUMCHQPRESENTEUTILIZACAO" 
                                              + string(vconta).
        
                                vachatextoval = "". 
                                vachatextoval = "VALCHQPRESENTEUTILIZACAO" 
                                              + string(vconta).

                                if acha(vachatextonum,plani.notobs[3]) <> ? and
                                   acha(vachatextoval,plani.notobs[3]) <> ?
                                then do: 
                                    find tt-cartpre where tt-cartpre.numero = 
                                     int(acha(vachatextonum,plani.notobs[3]))
                                         no-error. 
                                    if not avail tt-cartpre 
                                    then do:  
                                        create tt-cartpre. 
                                        assign tt-cartpre.numero =
                                        int(acha(vachatextonum,plani.notobs[3]))
                                           tt-cartpre.valor  =
                                       dec(acha(vachatextoval,plani.notobs[3])).
                                    end.
                                end.
                            end.
                        end.
                    end.
                    vvalor-cartpre = 0.
                    find first tt-cartpre no-lock no-error.
                    if avail tt-cartpre 
                    then do:
                        for each tt-cartpre.
                            vvalor-cartpre = vvalor-cartpre + tt-cartpre.valor.
                        end.
                    end.
                     
                    vlvist = vlvist - vvalor-cartpre.
                    
                    vlauxt = vlauxt - vvalor-cartpre.
                    run Pi-Cria-Anali(input "plani", input 2, 
                                       input plani.modcod, 
                                       input "", input 0,
                                       input vlauxt,
                                       input 1).
                    vlauxt = 0.
                    
                end.
                                                            
                if plani.crecod = 2
                then do:
                        vlpraz = vlpraz - plani.vlserv.
                        /* Val.Prazo (Contratos) */
                        run Pi-Cria-Anali(input "plani", input 1, 
                           input "", input "", input 0, 
                           input (plani.vlserv * - 1), input 1).
                end.
                
                /***
                if plani.crecod = 1 and
                   plani.vlserv > 0
                then do:
                    message plani.numero plani.pladat plani.vlserv.
                    pause.
                        assign ct-devolucao = ct-devolucao + 1
                               vdevolucao = vdevolucao + plani.vlserv.

                        run Pi-Cria-Anali(input "plani", input 8, 
                           input plani.modcod, input "",
                           input 0,
                           input plani.vlserv, 
                           input 1).

                end.
                ****/
                /********
                
                if plani.crecod = 2 and
                   plani.vlserv > 0
                then do:
                     assign ct-dev = ct-dev + 1
                            vldev = vldev + plani.vlserv.
                            
                     run Pi-Cria-Anali(input "plani", input 8, 
                           input plani.modcod, input plani.vlserv, 
                           input 1).
                     
                end.
                *****/
            end.
        end.
 end.

 /***
 for each caixa where caixa.etbcod = estab.etbcod no-lock:

    if vcaixa <> 0 and caixa.cxacod <> vcaixa then next.
    
    for each titulo where titulo.datexp = vdata no-lock.

            if vcaixa <> 0 and titulo.cxacod <> caixa.cxacod then next.

            if titulo.datexp <> titulo.cxmdat
            then next.
            if titulo.titdtpag <> vdata
            then next.
            if titulo.cxacod <> caixa.cxacod
            then next.
            if vmodcod <> "CRE"
            then next.
            /******************
            if titulo.moecod = "PRE" 
            then do:
                assign  vpredre = vpredre + titulo.titjuro
                        vljurpre = vljurpre + titulo.titjuro.
                run Pi-Cria-Anali(input "titulo", input 15, 
                                  input "", input titulo.titjuro, input 1).
            end.
            *****************/
    end.
    
 end.
 ***/
 
 /****************  DESPESAS FINANCEIRAS ****************************/
    
 qtd-pagar = 0.
 vl-pagar  = 0.
 disp "Filial : " + string(estab.etbcod) +  " Fase  8 " @ vfase 
                        with frame fdisplay no-labels centered row 10.
          pause 0.
 for each titluc where titluc.etbcobra = estab.etbcod and
                       titluc.titdtpag = vdata no-lock:
          
          if vcaixa <> 0 and titluc.cxacod <> vcaixa then next.
          vl-pagar = vl-pagar + titluc.titvlpag.
          qtd-pagar = qtd-pagar + 1.

          /* Desp.Financeiras */
          run Pi-Cria-Anali(input "titluc", input 12, input titluc.modcod, 
                            input titluc.moecod,
                            input 0,
                            input titluc.titvlpag, input 1).
            
 end.
 
end.

end.
end procedure.



procedure Pi-Cria-Anali.

def input parameter p-tipo    as char.
def input parameter p-reg     as int.
def input parameter p-mod-cod as char.
def input parameter p-moe-cod as char.
def input parameter p-hor-pag as int.
def input parameter p-vltrans as dec.
def input parameter p-qtde    as int.

def var vnumdoc as char.

if p-tipo = "contrato" 
then do:

    find first clien where clien.clicod = contrato.clicod no-lock no-error.
    find first titulo use-index titnum
         where titulo.empcod = wempre.empcod and
               titulo.titnat = no and
               titulo.modcod = "CRE" and
               titulo.etbcod = contrato.etbcod and
               titulo.clifor = contrato.clicod and
               titulo.titnum = string(contrato.contnum)
               no-lock no-error.
    if vcaixa <> 0 and titulo.cxacod <> vcaixa then leave.
    else do:
        find first tt-caixa-anali use-index key1 where 
               tt-caixa-anali.data   = titulo.cxmda   and 
               tt-caixa-anali.etbcod = titulo.etbcod  and
               tt-caixa-anali.cxacod = titulo.cxacod  and
               tt-caixa-anali.numdoc = titulo.titnum and
               tt-caixa-anali.tpreg  = p-reg
           no-error.                                                          
                  
        if not avail tt-caixa-anali
        then do:
            create tt-caixa-anali.
            assign
             tt-caixa-anali.etbcod   = contrato.etbcod 
             tt-caixa-anali.cxacod   = titulo.cxacod 
             tt-caixa-anali.numdoc   = titulo.titnum
             tt-caixa-anali.cxmhora  = int(titulo.cxmhora)
             tt-caixa-anali.tpreg    = p-reg
             tt-caixa-anali.data     = contrato.datexp
             tt-caixa-anali.modcod   = titulo.modcod 
             tt-caixa-anali.parcela  = titulo.titpar    
             tt-caixa-anali.clifor   = titulo.clifor
             tt-caixa-anali.vlcob    = p-vltrans
             tt-caixa-anali.vltrans  = p-vltrans
             tt-caixa-anali.qttrans  = p-qtde.
        end.
    end.          
    return.
end.

if p-tipo = "titluc"
then do:
   find first tt-caixa-anali use-index key1 where 
        tt-caixa-anali.data   = titluc.cxmda and 
        tt-caixa-anali.etbcod = titluc.etbcobra and
        tt-caixa-anali.cxacod = titluc.cxacod and
        tt-caixa-anali.numdoc = titluc.titnum and
        tt-caixa-anali.parcela = titluc.titpar and
        tt-caixa-anali.tpreg  = p-reg
               no-error.                                                       
        if not avail tt-caixa-anali                                                    then do: 
            create tt-caixa-anali.
            assign tt-caixa-anali.etbcod   = titluc.etbcobra
            tt-caixa-anali.cxacod   = titluc.cxacod
            tt-caixa-anali.numdoc   = titluc.titnum   
            tt-caixa-anali.tpreg    = p-reg
            tt-caixa-anali.data     = titluc.cxmdat 
            tt-caixa-anali.modcod   = p-mod-cod 
            tt-caixa-anali.parcela  = titluc.titpar    
            tt-caixa-anali.clifor   = titluc.clifor 
            tt-caixa-anali.vlcob    = p-vltrans
            tt-caixa-anali.vltrans  = p-vltrans
            tt-caixa-anali.qttrans  = p-qtde.      
        end.
        return.      

end.

if p-tipo = "cheque" 
then do:
   assign vnumdoc = string(chq.banco) + "/" + string(chq.agencia) + "/" + 
                    string(chq.conta) + "/" + string(chq.numero).
   find first tt-caixa-anali use-index key1 where 
        tt-caixa-anali.data    = chq.data and 
        tt-caixa-anali.etbcod  = chqtit.etbcod and /*titulo.etbcod  and */
        tt-caixa-anali.cxacod  = 0  and
        tt-caixa-anali.numdoc  = vnumdoc and
        tt-caixa-anali.parcela = chqtit.titpar and /* titulo.titpar and */  
        tt-caixa-anali.tpreg  = p-reg
               no-error.                                                       
       if not avail tt-caixa-anali                                                      then do: 
            v-flg-achou = 1.
            create tt-caixa-anali.
            assign 
            tt-caixa-anali.etbcod   = chqtit.etbcod /* titulo.etbcod */
            tt-caixa-anali.cxacod   = 0
            tt-caixa-anali.numdoc   = vnumdoc   
            tt-caixa-anali.tpreg    = p-reg
            tt-caixa-anali.data     = chq.data 
            tt-caixa-anali.modcod   = p-mod-cod 
            tt-caixa-anali.parcela  = chqtit.titpar /* titulo.titpar */ 
            tt-caixa-anali.clifor   = chqtit.clifor /* titulo.clifor */
            tt-caixa-anali.vlcob    = p-vltrans
            tt-caixa-anali.vltrans  = p-vltrans
            tt-caixa-anali.qttrans  = tt-caixa-anali.qttrans + p-qtde.
            v-gravou-ana = yes.
         end.         
        return.                                
end.

if p-tipo = "titulo" 
then do:
   find first tt-caixa-anali use-index key1 where 
        tt-caixa-anali.data   = titulo.cxmda and 
        tt-caixa-anali.etbcod = titulo.etbcobra and
        tt-caixa-anali.cxacod = titulo.cxacod and
        tt-caixa-anali.numdoc = titulo.titnum and
        tt-caixa-anali.moecod = p-moe-cod and
        tt-caixa-anali.parcela = titulo.titpar and
        tt-caixa-anali.tpreg  = p-reg
               no-error.                                                       
        if not avail tt-caixa-anali                                                    then do: 
               
            create tt-caixa-anali.
            assign tt-caixa-anali.etbcod   = titulo.etbcobra
            tt-caixa-anali.cxacod   = titulo.cxacod
            tt-caixa-anali.numdoc   = titulo.titnum   
            tt-caixa-anali.tpreg    = p-reg
            tt-caixa-anali.data     = titulo.cxmdat 
            tt-caixa-anali.modcod   = p-mod-cod 
            tt-caixa-anali.moecod   = p-moe-cod
            tt-caixa-anali.cxmhora  = p-hor-pag
            tt-caixa-anali.parcela  = titulo.titpar    
            tt-caixa-anali.clifor   = titulo.clifor 
            tt-caixa-anali.vlcob    = titulo.titvlcob
            tt-caixa-anali.vltrans  = p-vltrans
            tt-caixa-anali.qttrans  = p-qtde.      
        
                 
        end.
        return.                                
end.

if p-tipo = "d-titulo" 
then do:
   find first tt-caixa-anali use-index key1 where 
        tt-caixa-anali.data   = d-titulo.cxmda and 
        tt-caixa-anali.etbcod = d-titulo.etbcobra and
        tt-caixa-anali.cxacod = d-titulo.cxacod and
        tt-caixa-anali.numdoc = d-titulo.titnum and
        tt-caixa-anali.moecod = p-moe-cod and
        tt-caixa-anali.parcela = d-titulo.titpar and
        tt-caixa-anali.tpreg  = p-reg
               no-error.                                                       
        if not avail tt-caixa-anali                                            ~        then do: 
               
            create tt-caixa-anali.
            assign tt-caixa-anali.etbcod   = d-titulo.etbcobra
            tt-caixa-anali.cxacod   = d-titulo.cxacod
            tt-caixa-anali.numdoc   = d-titulo.titnum   
            tt-caixa-anali.tpreg    = p-reg
            tt-caixa-anali.data     = d-titulo.cxmdat 
            tt-caixa-anali.modcod   = p-mod-cod 
            tt-caixa-anali.moecod   = p-moe-cod
            tt-caixa-anali.cxmhora  = p-hor-pag
            tt-caixa-anali.parcela  = d-titulo.titpar    
            tt-caixa-anali.clifor   = d-titulo.clifor 
            tt-caixa-anali.vlcob    = d-titulo.titvlcob
            tt-caixa-anali.vltrans  = p-vltrans
            tt-caixa-anali.qttrans  = p-qtde.      
        
                 
        end.
        return.                                
end.


if p-tipo = "plani" 
then do:
    find first tt-caixa-anali use-index key1 where
          tt-caixa-anali.data = plani.pladat 
          and tt-caixa-anali.etbcod = plani.etbcod 
          and tt-caixa-anali.cxacod = plani.cxacod
          and tt-caixa-anali.numdoc = string(plani.numero)
          and tt-caixa-anali.tpreg  = p-reg no-error.
    if not avail tt-caixa-anali                                                      then do:                                                                           create tt-caixa-anali.                                               
          assign tt-caixa-anali.etbcod   = plani.etbcod            
          tt-caixa-anali.cxacod   = plani.cxacod
          tt-caixa-anali.numdoc   = string(plani.numero)
          tt-caixa-anali.tpreg    = p-reg
          tt-caixa-anali.data     = plani.pladat 
          tt-caixa-anali.modcod   = p-mod-cod
          tt-caixa-anali.parcela  = 0 
          tt-caixa-anali.clifor   = plani.emite
          tt-caixa-anali.vltrans  = p-vltrans
          tt-caixa-anali.vlcob    = plani.platot.
    end.
end.

end procedure.

