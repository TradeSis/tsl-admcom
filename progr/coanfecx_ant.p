/**********************************************************************
* Coanfecx.p    Consultas Analiticas de Caixas (Parte I - Resumo) 
*               Individuais ou por Estabelecimentos
* Data     :    13/05/2009
* Autor    :    Antonio Maranghello
*
***********************************************************************/
{admcab.i}
{setbrw.i}
def var val-anali-opc as dec.
def var v-soma-caixa  as dec.
def var vnext       as logical.
def var qtd-pagar   as int.
def var vchedia     like titulo.titvlcob.
def var vpag        like titulo.titvlcob.
def var vpredre     like titulo.titvlcob.
def var vlnov       like titulo.titvlcob.  
def var vlpagcartao like plani.platot.
def var vdevolucao  like plani.platot.
def var vdeposito   like plani.platot.
def var vcaixa      like titulo.cxacod.
def var vetbcod     as int.
def var qtd-cart    as int.
def var gloqtd      as int.
def var vcx         as int.
def var totglo      like globa.gloval.
def var vlpres      like plani.platot.
def var vlauxt      like plani.platot.
def var vcta01      as char format "99999".
def var vcta02      as char format "99999".
def var vdata       like titulo.titdtemi.
def var vl-pagar    like titulo.titvlpag.
def var vl-cart     like titulo.titvlpag.
def var vpago       like titulo.titvlpag.
def var vdesc       like titulo.titdesc.
def var vjuro       like titulo.titjuro.
def var sresumo     as log format "Resumo/Geral" initial yes.
def var wpar        as int format ">>9" .
def var p-juro      as dec.
def var vcxacod     like titulo.cxacod.
def var vmodcod     like titulo.modcod.
def var vlvist      like plani.platot.
def var vlpraz      like plani.platot.
def var vlentr      like plani.platot.
def var vljuro      like plani.platot.
def var vldesc      like plani.platot.
def var vlpred      like plani.platot.
def var vldev       like plani.platot.
def var vldevvis    like plani.platot.
def var vljurpre    like plani.platot.
def var vlsubtot    like plani.platot.
def var vtot        like plani.platot.
def var vnumtra     like plani.platot.
def var total_cheque_devolvido   like plani.platot.
def var  conta_cheque_devolvido as int.
def var ct-vist        as   int.
def var ct-praz        as   int.
def var ct-entr        as   int.
def var ct-pres        as   int.
def var ct-juro        as   int.
def var ct-desc        as   int.
def var ct-dev         as   int.
def var ct-nov         as   int.
def var ct-devvis      as   int.
def var ct-devolucao   as   int.
def var ct-pagcartao   as   int.
def var vqtdcart       as   int.
def var vconta         as   int.
def var vachatextonum  as char.
def var vachatextoval  as char.
def var vvalor-cartpre as int.
def var vdtexp         as   date.
def var vdtimp         as   date.
def var vdescricao     as char format "x(60)".
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

/********* Tipo de Registro tt-caixa-anali *********
1-  Valor a Prazo           2-  Vendas  a Vista   
3-  Entradas                4-  Prestacoes      
5-  Juros                   6-  Descontos      
7-  Val./Quant. Entradas    8-  Devolucao              
9-  Global                 10-  Novacao
11- Valor Descontos        12-  Cheq.Dia
13- Valor Depo�sito        14-  Cheq.Drebes
15- Cartao Credito  
***************************************************/ 
def new shared temp-table tt-caixa-anali no-undo
    field etbcod  like estab.etbcod
    field cxacod  like caixa.cxacod label "Caixa"
    field numdoc  as   char         label "Documento"
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
    index key1  etbcod 
                data    
                cxacod 
                numdoc 
                tpreg.  
    
def new shared temp-table tt-aux-lis like tt-caixa-anali.

for each tt-caixa-anali:
    delete tt-caixa-anali.
end.    

do with 1 down side-label width 80 row 3 color blue/white:
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
   update vdata.
   update vcaixa.

   assign vcta01 = string(estab.prazo,"99999")
          vcta02 = string(estab.vista,"99999").

   assign  vlpraz    = 0 vlvist   = 0 vlauxt = 0
           vlentr    = 0 vljuro   = 0 
           vldev     = 0 vldesc   = 0 vldevvis = 0
           ct-pres   = 0 ct-juro  = 0 ct-desc = 0 
           ct-vist   = 0 ct-praz  = 0 vlpred = 0 
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
  run Pi-Processa.
   
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
            
      for each tt-caixa-anali :
        if vetbcod <> 0 and tt-caixa-anali.etbcod <> vetbcod then next.
        if vcaixa  <> 0 and tt-caixa-anali.cxacod <> vcaixa then next. 
        if tt-caixa-anali.tpreg = v-opcao-ana-ind[frame-index] and
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


    assign  vtotaux1 = vlvist + vlentr + vlpres + vljuro 
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
      vljuro  label " 5.Juros        " format "->>>,>>9.99"                               ct-juro label "Qt" format ">>>9" "" skip
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
   totglo    label " 9.Global       "  format "->>>,>>9.99"                         gloqtd    label "Qt" format ">>>9"  
   vpredre   label "Cheque Pre-Drebes "  format "->>>,>>9.99"  
   vlnov     label "10. Novacao     "   format "->>>,>>9.99"                   
   ct-nov    label "Qt" format ">>>9"  
   vdeposito 
   label "Deposito     R$   "  format "->>>,>>9.99"                       
   total_cheque_devolvido
   label "11. Cheque Devol" format "->>>,>>9.99"                                
   conta_cheque_devolvido label "Qt" format ">>>9"
   vl-cart label "Cartao Credito    "  format "->>>,>>9.99"  
   /* antigo - cartao
          vl-cart  label "13. Cartoes      "
          qtd-cart no-label format ">>>>>>9"  to 40 skip(2)
          vlpagcartao   label "14.Parcel c/ Cartao"
          ct-pagcartao no-label format ">>>>>>9" to 40 skip
       antigo - desp Financ
          vl-pagar label "12. Desp. Finac."
          qtd-pagar no-label format ">>>9" to 40  skip(2)
   */
    with  with frame fresumo row 7
                     no-box side-labels.
   
     assign vtotaux2 =  vpag + vchedia + vdeposito 
                             + vpredre + vl-pagar + vl-cart.

     assign vtotaux3 = vtotaux1 - vtotaux2.
     
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

for each estab where estab.etbcod = (if vetbcod <> 0 then vetbcod 
                                     else estab.etbcod) no-lock:                     
      if not( estab.etbnom begins "DREBES-FIL" ) then next.

      if vetbcod <> 0 and estab.etbcod <> vetbcod then next.
      
      find first deposito where deposito.etbcod = estab.etbcod
             and deposito.datmov = vdata no-lock no-error.
                           
      if avail deposito
      then assign vdeposito = vdeposito + deposito.depdep.
 
 for each chq where chq.datemi = vdata no-lock:
              
   find first chqtit where chqtit.banco   = chq.banco and
                           chqtit.agencia = chq.agencia and
                           chqtit.conta   = chq.conta and
                           chqtit.numero  = chq.numero 
                           no-lock no-error.
        if not avail chqtit then next.
        if chqtit.etbcod <> estab.etbcod then next.
        find first titulo where titulo.empcod = 19 and
                                titulo.etbcod = chqtit.etbcod and
                                titulo.clifor = chqtit.clifor and
                                titulo.titpar = chqtit.titpar and
                                titulo.modcod = chqtit.modcod and
                                titulo.titnat = chqtit.titnat no-lock no-error.
        if not avail titulo then next.                        
        if vcaixa <> 0 and titulo.cxacod <> vcaixa then next.
        
        if chq.datemi <> chq.data
         then do:
            run Pi-Cria-Anali(input "titulo", input 15, 
                              input "", input chq.valor, input 1).
             assign vpredre = vpredre + chq.valor.
        end.
        else do:
            run Pi-Cria-Anali(input "titulo", input 13, 
                              input "", input chq.valor, input 1).
            assign vchedia = vchedia + chq.valor.
        end.                           
 end.
 for each contrato where contrato.datexp = vdata no-lock:
        
        disp "Filial : " + string(estab.etbcod) + " Fase 1 :" @ vfase      
               string(contrato.contnum) @ vmostra
             with frame fdisplay no-labels no-box centered.
        pause 0.
                      
        if contrato.etbcod  = estab.etbcod
        then do :
                assign  ct-praz = ct-praz + 1
                        vlpraz  = vlpraz + contrato.vltotal.
                /* Val.Prazo (Contratos) */
                run Pi-Cria-Anali(input "contrato", input 1, 
                                  input "", input contrato.vltotal, input 1).
        end.                      
 end.

 for each caixa where caixa.etbcod = estab.etbcod no-lock:

         if vcaixa <> 0 and caixa.cxacod <> vcaixa then next.
         
         for each titulo use-index etbcod 
             where titulo.etbcobra = estab.etbcod and  /* tttt */
                 titulo.titdtpag = vdata   /*** and
                 titulo.modcod   = "CAR"***/ no-lock.
            
            /*****
             message "-> " titulo.etbcod titulo.titnum 
             titulo.titvlcob titulo.etbcobra
                view-as alert-box.
            ****/
            if titulo.cxacod <> caixa.cxacod
            then next.

            if titulo.titsit <> "PAG" then next.
            
            if titulo.moecod <> "CAR" then next.

            disp "Filial : " + string(estab.etbcod) + " Fase 2 : " 
            @ vfase string(titulo.titnum) @ vmostra
                 with frame fdisplay no-labels no-box centered.
            pause 0.
            
        
            qtd-cart = qtd-cart + 1.
            vl-cart = vl-cart + titulo.titvlpag.
            /* C.Credito */
            run Pi-Cria-Anali(input "titulo", input 16, 
                              input titulo.modcod, input titulo.titvlpag, 
                              input 1).
         end.
 end.

 for each caixa where caixa.etbcod = estab.etbcod no-lock:
         
        if vcaixa <> 0 and caixa.cxacod <> vcaixa then next.
        
        for each titulo where titulo.empcod = 19
                      and titulo.titnat = no
                      and titulo.modcod = "CHQ" no-lock:

            /*if titulo.etbcod <> setbcod then next.*/
            if titulo.etbcobra <> estab.etbcod then next.
            if titulo.cxacod <> caixa.cxacod
            then next.
        
            if titulo.titdtpag = vdata
            then do:
                    assign total_cheque_devolvido = total_cheque_devolvido +  
                                             titulo.titvlpag
                    conta_cheque_devolvido = conta_cheque_devolvido + 1.
      
                 disp "Filial : " + string(estab.etbcod) + 
                " Fase 3 : " @ vfase
                                    string(titulo.titnum) @ vmostra
                 with frame fdisplay no-labels no-box centered.
                pause 0.
                /* Cheque Devolvido */
                run Pi-Cria-Anali(input "titulo", input 11, 
                              input titulo.modcod, input titulo.titvlpag, 
                              input 1).
             end.
        end.
 
 end.

 for each caixa where caixa.etbcod = estab.etbcod no-lock:

        if vcaixa <> 0 and caixa.cxacod <> vcaixa then next.

        for each titulo where titulo.datexp = vdata no-lock
                                                    by titulo.moecod
                                                    by titulo.titnum
                                                    by titulo.titpar:
 
            if titulo.etbcobra <> estab.etbcod
            then next.
            if titulo.cxacod <> caixa.cxacod 
            then next.
            if titulo.datexp <> titulo.cxmdat
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
            if titulo.modcod = "VVI" or titulo.modcod = "CHQ" or
               titulo.modcod = "CHP" /** Masiero **/
            then next.
            if titulo.modcod = "CRE" and titulo.moecod = "DEV" then next.
            find bmoeda where bmoeda.moecod = titulo.moecod no-lock no-error.
            if avail bmoeda
            then do:
            
                if bmoeda.moetit = yes
                then do:
                    vlpagcartao = vlpagcartao + titulo.titvlcob.
                    /*
                     run Pi-Cria-Anali(input "titulo", input 99, 
                           input titulo.modcod, input titulo.titvlcob, 
                           input 1).
                    */
                end.
                else do:
                    vlpres = vlpres + titulo.titvlcob.
                    run Pi-Cria-Anali(input "titulo", input 4, 
                           input titulo.modcod, input titulo.titvlcob, 
                           input 1).
                end.    

            end.
            else do:
                vlpres = vlpres + titulo.titvlcob.
                run Pi-Cria-Anali(input "titulo", input 4, 
                           input titulo.modcod, input titulo.titvlcob, 
                           input 1).
            end.    
            
            if titulo.moecod = "NOV"
            then do:
                    assign vlnov  = vlnov + titulo.titvlcob
                           ct-nov = ct-nov + 1.
                           run Pi-Cria-Anali(input "titulo", input 10, 
                           input titulo.modcod, input titulo.titvlcob, 
                           input 1).
            end.
            disp "Filial : " + string(estab.etbcod) + " Fase 4  : " @ vfase                 string(titulo.titnum) @ vmostra
                 with frame fdisplay no-labels no-box centered.
            pause 0.
        end.
 end.

 for each caixa where caixa.etbcod = estab.etbcod no-lock:
        
        if vcaixa <> 0 and caixa.cxacod <> vcaixa then next.

        for each titulo where titulo.datexp = vdata no-lock.
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
                run Pi-Cria-Anali(input "titulo", input 3,                                                         input titulo.modcod, input titulo.titvlcob,
                                  input 1).
            end.
            disp "Filial : " + string(estab.etbcod) + " Fase 5  : " @ vfase                 string(titulo.titnum) @ vmostra
                 with frame fdisplay no-labels no-box centered.
            pause 0.

        end.
 end.

 for each caixa where caixa.etbcod = estab.etbcod no-lock:
  
         if vcaixa <> 0 and caixa.cxacod <> vcaixa then next.
        
         for each titulo where titulo.datexp = vdata 
                and titulo.cxacod = caixa.cxacod no-lock.

            disp "Filial : " + string(estab.etbcod) + " Fase 6  : " @ vfase                string(titulo.titnum) @ vmostra
            with frame fdisplay no-labels centered.
            pause 0.
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
            /*
            if vmodcod <> "CRE"
            then next.
            */

            if titulo.moecod = "PRE"
            then assign  vlpred = vlpred + titulo.titvlcob
                         vljurpre = vljurpre + titulo.titjuro.

            if titulo.modcod = "CRE"
            then do:
                assign vljuro = vljuro + titulo.titjuro
                       vldesc = vldesc + titulo.titdesc.
                p-juro = 0.
                if titulo.titjuro > 0
                then
                run Pi-Cria-Anali(input "titulo", input 5, 
                           input titulo.modcod, input titulo.titjuro, 
                           input 1).
                if titulo.titdesc > 0
                then
                run Pi-Cria-Anali(input "titulo", input 6, 
                           input titulo.modcod, input titulo.titdesc, 
                           input 1).
 
                 
                /**************************************
                find first tt-juro where 
                           tt-juro.cxacod = caixa.cxacod no-error.
                if not avail tt-juro
                then do:
                    create tt-juro.
                    tt-juro.cxacod = caixa.cxacod.
                end.
                if today - titulo.titdtven <= 180 and
                    titulo.moecod <> "NOV" and
                    titulo.moecod <> "CHV" and
                    titulo.moecod <> "PRE"
                then do:
                    run jurocal1.p(recid(titulo),output p-juro).
                    if p-juro = ? then p-juro = 0.
                    if p-juro > titulo.titjuro
                    then tt-juro.juro-cal = tt-juro.juro-cal + p-juro.
                    else tt-juro.juro-cal = tt-juro.juro-cal + titulo.titjuro.
                    tt-juro.juro-inf = tt-juro.juro-inf + titulo.titjuro .
                end.
                **************************************/
            end.

            if vmodcod <> "CRE"
            then next.
            
            find bmoeda where bmoeda.moecod = titulo.moecod no-lock no-error.
            if avail bmoeda
            then do:
                if bmoeda.moetit = yes
                then ct-pagcartao = ct-pagcartao + (if titulo.titvlcob > 0
                                                    then 1 else 0).
                else ct-pres = ct-pres + (if titulo.titvlcob > 0
                                          then 1 else 0).
            end.
            else ct-pres = ct-pres + if titulo.titvlcob > 0
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


 for each caixa where caixa.etbcod = estab.etbcod no-lock:

        if vcaixa <> 0 and caixa.cxacod <> vcaixa then next.

        for each titulo where titulo.datexp = vdata
                          and titulo.modcod = "DEV"
                          and titulo.etbcod = estab.etbcod
                                                no-lock:
                if titulo.cxacod <> caixa.cxacod then next.

                if titulo.titobs[2] = "DEVOLUCAO"
                then
                        assign vdevolucao = vdevolucao + titulo.titvlpag
                               ct-devolucao = ct-devolucao + 1.

                run Pi-Cria-Anali(input "titulo", input 7, 
                           input titulo.modcod, input titulo.titvlpag, 
                           input 1).
        
        end.                                    

        for each plani use-index pladat where plani.movtdc = 5 and
                                      plani.etbcod = estab.etbcod and
                                      plani.pladat = vdata no-lock:
                                      
            if plani.cxacod = caixa.cxacod
            then do:
                disp "Filial : " + string(estab.etbcod) + " Fase  7 : " @                        vfase string(caixa.cxacod) @ vmostra
                with frame fdisplay no-labels centered.
                pause 0.
                find titulo where titulo.empcod = wempre.empcod and
                                  titulo.titnat = no            and
                                  titulo.modcod = "CRE"         and
                                  titulo.etbcod = setbcod       and
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
                                       input plani.modcod, input vlauxt,
                                       input 1).
                    vlauxt = 0.
                    
                end.
                                                            
                if plani.crecod = 2
                then do:
                        vlpraz = vlpraz - plani.vlserv.
                        /* Val.Prazo (Contratos) */
                        run Pi-Cria-Anali(input "plani", input 1, 
                           input "", input (plani.vlserv * - 1), input 1).
                end.
                /*********
                if plani.crecod = 1 and
                   plani.vlserv > 0
                then do:
                        assign ct-devolucao = ct-devolucao + 1
                               vdevolucao = vdevolucao + plani.vlserv.
                        run Pi-Cria-Anali(input "plani", input 8, 
                           input plani.modcod, input plani.vlserv, 
                           input 1).


                end.
                ********/
                if plani.crecod = 2 and
                   plani.vlserv > 0
                then do:
                     assign ct-dev = ct-dev + 1
                            vldev = vldev + plani.vlserv.
                     /*       
                     run Pi-Cria-Anali(input "plani", input 8, 
                           input plani.modcod, input plani.vlserv, 
                           input 1).
                     */
                end.
            end.
        end.
 end.

 for each caixa where caixa.etbcod = estab.etbcod no-lock:

    if vcaixa <> 0 and caixa.cxacod <> vcaixa then next.

    
    /********************* Desp Financ. Anterior **********************
    
    for each plani use-index pladat 
                           where plani.movtdc = 5       
                           and plani.etbcod = estab.etbcod 
                           and plani.pladat = vdata no-lock.
                           
                    if plani.cxacod = caixa.cxacod and
                       (plani.pedcod = 15 or plani.pedcod = 17 or 
                        plani.pedcod = 43 or plani.pedcod = 42)
                    then do: 

                        vnext = no.
                        for each movim where movim.etbcod = plani.etbcod
                                         and movim.placod = plani.placod
                                         and movim.movtdc = plani.movtdc
                                         and movim.movdat = plani.pladat
                                         no-lock:

                            find produ where 
                                 produ.procod = movim.procod no-lock no-error.
                            if not avail produ then next.
                            
                            if produ.clacod >= 131 and
                               produ.clacod <= 139
                            then.
                            else do:
                                if produ.clacod = 81
                                then.
                                else vnext = yes.
                            end.
                        end.
                        if vnext then next.

                        find first contnf where contnf.etbcod = plani.etbcod
                                            and contnf.placod = plani.placod
                                            no-lock no-error.
                        if avail contnf 
                        then do:
                             find last titulo 
                                  where titulo.empcod = wempre.empcod
                                      and titulo.titnat = no
                                      and titulo.modcod = "CRE"
                                      and titulo.etbcod = setbcod  
                                      and titulo.clifor = plani.desti
                                      and titulo.titnum = string(contnf.contnum)
                                      no-lock no-error.
                            if avail titulo
                            then do:

                                vl-pagar = vl-pagar +
                                       (titulo.titvlcob * 0.10) /*+
                                       (titulo.titvlcob * 0.01)*/ .

                                qtd-pagar = qtd-pagar + 1. 
                                disp "Filial : " + string(estab.etbcod) + 
                                " Fase  8 : " @ vfase 
                                string(caixa.cxacod) @ vmostra
                                with frame fdisplay no-labels centered.
                                pause 0.
                                /* Desp.Financeiras */
                                run Pi-Cria-Anali(input "titulo", 
                                    input 12, input titulo.modcod, 
                                    input (titulo.titvlcob * 0.01), input 1).
                             end.
                        end.
                    end.
    end.

    ******************************************************************/
    for each titulo where titulo.datexp = vdata no-lock.

            if vcaixa <> 0 and titulo.cxacod <> vcaixa then next.

            if titulo.datexp <> titulo.cxmdat
            then next.
            if titulo.titdtpag <> vdata
            then next.
            if titulo.cxacod <> caixa.cxacod
            then next.
            if vmodcod <> "CRE"
            then next.
            if titulo.moecod = "PRE"
            then assign  vlpred = vlpred + titulo.titvlcob
                         vljurpre = vljurpre + titulo.titjuro.
    end.
    
 end.
 /****************  DESPESAS FINANCEIRAS ****************************/
    
 qtd-pagar = 0.
 vl-pagar  = 0.
 for each titluc where titluc.etbcobra = estab.etbcod and
                    titluc.titdtpag = vdata no-lock:
          
          if vcaixa <> 0 and titluc.cxacod <> vcaixa then next.
          vl-pagar = vl-pagar + titluc.titvlpag.
          qtd-pagar = qtd-pagar + 1.

          disp "Filial : " + string(estab.etbcod) + 
                " Fase  8 : " @ vfase 
                  string(titluc.cxacod) @ vmostra
                        with frame fdisplay no-labels centered.
          pause 0.
          
          /* Desp.Financeiras */
          run Pi-Cria-Anali(input "titluc", input 12, input titluc.modcod, 
                            input titluc.titvlpag, input 1).
            
 end.
 
end.

end.
end procedure.



procedure Pi-Cria-Anali.

def input parameter p-tipo    as char.
def input parameter p-reg     as int.
def input parameter p-mod-cod as char.
def input parameter p-vltrans as dec.
def input parameter p-qtde    as int.


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
           no-error.                                                                 if not avail tt-caixa-anali                                                    then do:                                                                            create tt-caixa-anali.                                                           assign
             tt-caixa-anali.etbcod   = contrato.etbcod                                      tt-caixa-anali.cxacod   = titulo.cxacod 
             tt-caixa-anali.numdoc   = titulo.titnum
             tt-caixa-anali.tpreg    = p-reg
             tt-caixa-anali.data     = contrato.datexp
             tt-caixa-anali.modcod   = titulo.modcod                                        tt-caixa-anali.parcela  = titulo.titpar    
             tt-caixa-anali.clifor   = titulo.clifor
             tt-caixa-anali.vlcob    = p-vltrans
             tt-caixa-anali.vltrans  = p-vltrans
             tt-caixa-anali.qttrans  = p-qtde.                                         end.
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


if p-tipo = "titulo" 
then do:
   find first tt-caixa-anali use-index key1 where 
        tt-caixa-anali.data   = titulo.cxmda and 
        tt-caixa-anali.etbcod = titulo.etbcobra and
        tt-caixa-anali.cxacod = titulo.cxacod and
        tt-caixa-anali.numdoc = titulo.titnum and
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
            tt-caixa-anali.parcela  = titulo.titpar    
            tt-caixa-anali.clifor   = titulo.clifor 
            tt-caixa-anali.vlcob    = titulo.titvlcob
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

