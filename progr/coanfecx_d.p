/**********************************************************************
* Coanfecx.p    Consultas Analiticas de Caixas (Parte II - Resumo Dragao) 
*               Individuais ou por Estabelecimentos
* Data     :    09/06/2009
* Autor    :    Antonio Maranghello
*
***********************************************************************/
{admcab.i}

def shared temp-table tt-titulo like fin.titulo.
def var v-gravou-ana as logical initial no.     
def shared var v-flg-achou as int.
def shared var val-anali-opc as dec.
def shared var v-soma-caixa  as dec.
def shared var vnext       as logical.
def shared var qtd-pagar   as int.
def shared var vchedia     like d.titulo.titvlcob.
def shared var vpag        like d.titulo.titvlcob.
def shared var vpredre     like d.titulo.titvlcob.
def shared var vlnov       like d.titulo.titvlcob.  
def shared var vlpagcartao like plani.platot.
def shared var vdevolucao  like plani.platot.
def shared var vdeposito   like plani.platot.
def shared var vcaixa      like d.titulo.cxacod.
def shared var vetbcod     as int.
def shared var qtd-cart    as int.
def shared var gloqtd      as int.
def shared var vcx         as int.
def shared var totglo      like globa.gloval.
def shared var vlpres      like plani.platot.
def shared var vlauxt      like plani.platot.
def shared var vcta01      as char format "99999".
def shared var vcta02      as char format "99999".
def shared var vdata       like d.titulo.titdtemi.
def shared var vl-pagar    like d.titulo.titvlpag.
def shared var vl-cart     like d.titulo.titvlpag.
def shared var vpago       like d.titulo.titvlpag.
def shared var vdesc       like d.titulo.titdesc.
def shared var vjuro       like d.titulo.titjuro.
def shared var sresumo     as log format "Resumo/Geral" initial yes.
def shared var wpar        as int format ">>9" .
def shared var p-juro      as dec.
def shared var vcxacod     like d.titulo.cxacod.
def shared var vmodcod     like d.titulo.modcod.
def shared var vlvist      like plani.platot.
def shared var vlpraz      like plani.platot.
def shared var vlentr      like plani.platot.
def shared var vljuro      like plani.platot.
def shared var vldesc      like plani.platot.
def shared var vlpred      like plani.platot.
def shared var vldev       like plani.platot.
def shared var vldevvis    like plani.platot.
def shared var vljurpre    like plani.platot.
def shared var vlsubtot    like plani.platot.
def shared var vtot        like plani.platot.
def shared var vnumtra     like plani.platot.
def shared var total_cheque_devolvido   like plani.platot.
def shared var  conta_cheque_devolvido as int.
def shared var ct-vist        as   int.
def shared var ct-praz        as   int.
def shared var ct-entr        as   int.
def shared var ct-pres        as   int.
def shared var ct-juro        as   int.
def shared var ct-desc        as   int.
def shared var ct-dev         as   int.
def shared var ct-nov         as   int.
def shared var ct-devvis      as   int.
def shared var ct-devolucao   as   int.
def shared var ct-pagcartao   as   int.
def shared var vqtdcart       as   int.
def shared var vconta         as   int.
def shared var vachatextonum  as char.
def shared var vachatextoval  as char.
def shared var vvalor-cartpre as dec.
def shared var vdtexp         as   date.
def shared var vdtimp         as   date.
def shared var vdescricao     as char format "x(60)".

def buffer bmoeda for d.moeda.

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
13- Valor Depoósito        14-  Cheq.Drebes
15- Cartao Credito  
***************************************************/ 

/* Table de caixas p/Dragao */ 
def shared temp-table tt-work-caixa no-undo
    field etbcod like estab.etbcod
    field cxacod like fin.caixa.cxacod.
def shared temp-table wfestab
    field etbcod        like estab.etbcod init 0.
def buffer bwfestab    for wfestab.

def shared temp-table tt-caixa-anali no-undo
    field etbcod  like estab.etbcod
    field cxacod  like fin.caixa.cxacod label "Caixa"
    field numdoc  as   char         label "Documento" format "x(25)"
    field data    as   date  format "99/99/9999"
    field tpreg   as   int              
    field clifor  like d.titulo.clifor    
    field vlcob   like d.titulo.titvlcob
    field vltrans  like d.titulo.titvlcob        
    field ctaprazo as int
    field ctavista as int
    field parcela  like d.titulo.titpar    /* 0 - 999 (zero a Vista) */
    field modcod as char               /* CRE - VDV - VDP - ENT etc... */ 
    field qttrans as int
    field moecod like d.titulo.moecod
    field cxmhora as int
    index key1  etbcod 
                clifor
                data    
                cxmhora
                cxacod 
                numdoc 
                tpreg  
    index key2  numdoc.  
    
def shared temp-table tt-aux-lis like tt-caixa-anali.

  
run Pi-Processa-drag. /* Processa Banco DRAGAO */
disconnect d.
      
Procedure Pi-Processa-drag. 
     
def var vmostra as char format "x(15)".
def var vfase   as char format "x(25)".

do with frame fdisplay:

for each estab /*where estab.etbcod = (if vetbcod <> 0 then vetbcod 
                                     else estab.etbcod)*/
                                      no-lock:               
      find first wfEstab where wfEstab.Etbcod = Estab.Etbcod no-error.
              if not avail wfEstab
                       then next.
 
       if not( estab.etbnom begins "DREBES-FIL" ) then next.

    vetbcod = estab.etbcod.
      if vetbcod <> 0 and estab.etbcod <> vetbcod then next.
      
    disp "Filial : " + string(estab.etbcod) + " Fase 1.1 " @ vfase      
          with frame fdisplay no-labels no-box centered row 10.
        pause 0.
    
    /* cheq a vista */
    for each fin.caixa where fin.caixa.etbcod = estab.etbcod no-lock:
        
         if vcaixa <> 0 and fin.caixa.cxacod <> vcaixa then next.
         for each chq where chq.datemi = vdata no-lock:
                     
                   find first chqtit where chqtit.banco   = chq.banco and
                              chqtit.agencia = chq.agencia and
                              chqtit.conta   = chq.conta and
                              chqtit.numero  = chq.numero
                              no-lock no-error.
          if not avail chqtit then next.
          if chqtit.etbcod <> fin.caixa.etbcod then next.

          find first d.titulo where d.titulo.empcod = 19 and
                     d.titulo.etbcod   = chqtit.etbcod and
                     d.titulo.clifor   = chqtit.clifor and
                     d.titulo.titpar   = chqtit.titpar and
                     d.titulo.modcod = chqtit.modcod and
                     d.titulo.titnat = chqtit.titnat no-lock no-error.    

          if avail d.titulo 
          then do: /* next. */

                if d.titulo.titpar < 50 then next.
                if d.titulo.cxacod <> caixa.cxacod then next.
          end.
          if chq.data <= vdata
          then do:
                 run Pi-Cria-Anali(input "cheque", input 13,
                                   input "", input chq.valor, 1).
                 if v-gravou-ana = yes 
                 then assign vchedia = vchedia + chq.valor.
          end.
         end.
    end.
    /* che pre */
    for each fin.caixa where fin.caixa.etbcod = estab.etbcod no-lock:
       if vetbcod <> 0 and fin.caixa.cxacod = 20 then next.
       if vcaixa <> 0 and fin.caixa.cxacod <> vcaixa then next.
       for each chq where chq.datemi = vdata no-lock:
           assign v-flg-achou = 0.
           for each chqtit where chqtit.banco   = chq.banco and
                                   chqtit.agencia = chq.agencia and
                                   chqtit.conta   = chq.conta and
                                   chqtit.numero  = chq.numero
                                no-lock :
           if chqtit.etbcod <> caixa.etbcod then next.
           if chqtit.etbcod <> fin.caixa.etbcod then next.
           find first d.titulo where d.titulo.empcod = 19 and
                                  d.titulo.etbcod   = chqtit.etbcod and
                                  d.titulo.clifor   = chqtit.clifor and
                                  d.titulo.titpar   = chqtit.titpar and
                                  d.titulo.modcod   = chqtit.modcod and
                                  d.titulo.titnum   = chqtit.titnum and
                                  d.titulo.titnat   = chqtit.titnat no-lock                                     no-error.
           if not avail d.titulo then next.
           if d.titulo.titpar < 50 then next.
           if d.titulo.cxacod <> caixa.cxacod then next.
           v-flg-achou = 1.
           leave.
          end.
          if v-flg-achou = 0 then next.
          
          if vetbcod <> 999 and chq.data > vdata and titulo.datexp = vdata 
          then do:
             run Pi-Cria-Anali(input "cheque", input 15,
                               input "", input chq.valor, 1).
             if v-gravou-ana = yes then assign vpredre = vpredre + chq.valor.
          end.
          /*
          else do:
              run Pi-Cria-Anali(input "cheque", input 13,
                                input "", input chq.valor, 1).
              if v-gravou-ana = yes then assign vchedia = vchedia + chq.valor.
          end.
          */
       end.
    end.   
    
    disp "Filial : " + string(estab.etbcod) + " Fase 2.1 "  @ vfase 
                 with frame fdisplay no-labels no-box centered row 10.
            pause 0.
    
    for each d.titulo  
             where d.titulo.etbcobra = estab.etbcod and  /* tttt */
                 d.titulo.titdtpag = vdata   /*** and
                 titulo.modcod   = "CAR"***/ no-lock.
            
            if vcaixa <> 0 and d.titulo.cxacod <> vcaixa then next.
            if vcaixa <> 0
            then do:
                find first caixa where caixa.etbcod = estab.etbcod and
                                       caixa.cxacod = vcaixa
                                       no-lock no-error.
                if not avail caixa then next.
                if titulo.cxacod <> caixa.cxacod
                then next.
            end.

            /**** Laureano - Descarte comentado para atender chamado 29696*** 
            if d.titulo.etbcod <> estab.etbcod then next.
            */
            if d.titulo.titsit <> "PAG" then next.
            
            if d.titulo.moecod <> "CAR" and
               d.titulo.moecod <> "PDM" and
               (not d.titulo.moecod begins "TC") and
               (not d.titulo.moecod begins "TD")
            then next.

            find first tt-titulo where
               tt-titulo.empcod = d.titulo.empcod and
               tt-titulo.titnat = d.titulo.titnat and
               tt-titulo.modcod = d.titulo.modcod and
               tt-titulo.etbcod = d.titulo.etbcod and
               tt-titulo.clifor = d.titulo.clifor and
               tt-titulo.titnum = d.titulo.titnum and
               tt-titulo.titpar = d.titulo.titpar
               no-lock no-error.
            if avail tt-titulo then next.  
            
            if d.titulo.moecod <> "PDM"
            then do:
            qtd-cart = qtd-cart + 1.
            vl-cart = vl-cart + d.titulo.titvlpag.

            /* C.Credito */
            run Pi-Cria-Anali(input "titulo", input 16, 
                              input d.titulo.modcod, input d.titulo.titvlpag, 
                              input 1).
            end.
            else do:
                for each titpag where
                        titpag.empcod = d.titulo.empcod and
                        titpag.titnat = d.titulo.titnat and
                        titpag.modcod = d.titulo.modcod and
                        titpag.etbcod = d.titulo.etbcod and
                        titpag.clifor = d.titulo.clifor and
                        titpag.titnum = d.titulo.titnum and
                        titpag.titpar = d.titulo.titpar
                        no-lock: 
                    if (titpag.moecod = "CAR" or
                        titpag.moecod begins "TC" or
                        titpag.moecod begins "TD") and
                        titpag.cxmdat = d.titulo.cxmdat and
                        titpag.cxmhor = d.titulo.cxmhor
                    then do:
                        qtd-cart = qtd-cart + 1.
                        vl-cart = vl-cart + titpag.titvlpag.

                        run Pi-Cria-Anali(input "titulo", input 16, 
                              input d.titulo.modcod, input titpag.moecod,
                              input titpag.cxmhora, input titpag.titvlpag, 
                              input 1).
                        
                        run cria-totetb(estab.etbcod, vdata, 0, titpag.titvlpag, "+"~ ~).
                        
                    end.
                end.
            end.
            create tt-titulo.
            buffer-copy d.titulo to tt-titulo.

    end.
    
    disp "Filial : " + string(estab.etbcod) +  " Fase 3.1 " @ vfase
        with frame fdisplay no-labels no-box centered row 10.
    pause 0.

    for each fin.caixa where fin.caixa.etbcod = estab.etbcod no-lock:
         
          if vcaixa <> 0 and fin.caixa.cxacod <> vcaixa then next.
        
        for each d.titulo where d.titulo.empcod = 19
                      and d.titulo.titnat = no
                      and d.titulo.modcod = "CHQ" no-lock:

            /*if d.titulo.etbcod <> setbcod then next.*/
            if d.titulo.etbcobra <> estab.etbcod then next.
            if d.titulo.cxacod <> fin.caixa.cxacod
            then next.
        
            if d.titulo.titdtpag = vdata
            then do:
                           
                /* Cheque Devolvido */
                run Pi-Cria-Anali(input "titulo", input 11, 
                              input d.titulo.modcod, input d.titulo.titvlpag, 
                              input 1).
                if v-gravou-ana = yes then
                assign  total_cheque_devolvido = total_cheque_devolvido +  
                                                 d.titulo.titvlpag
                        conta_cheque_devolvido = conta_cheque_devolvido + 1.
             end.
        end.
 
    end.

    disp "Filial : " + string(estab.etbcod) + " Fase 4.1  " @ vfase  
        with frame fdisplay no-labels no-box centered row 10.
    pause 0.

    for each d.titulo where d.titulo.etbcobra = estab.etbcod and
                          d.titulo.titdtpag = vdata 
                          no-lock        .

            find first tt-titulo where
               tt-titulo.empcod = d.titulo.empcod and
               tt-titulo.titnat = d.titulo.titnat and
               tt-titulo.modcod = d.titulo.modcod and
               tt-titulo.etbcod = d.titulo.etbcod and
               tt-titulo.clifor = d.titulo.clifor and
               tt-titulo.titnum = d.titulo.titnum and
               tt-titulo.titpar = d.titulo.titpar
               no-lock no-error.
            if avail tt-titulo then next.  
    
            if titulo.datexp <> vdata then next.

            if d.titulo.titpar = 0 then next.
            if d.titulo.clifor = 1 then next.
            if d.titulo.moecod = "DEV" then next.
            if d.titulo.modcod <> "CRE" then next.
            if d.titulo.titnat = yes then next.

            if vcaixa <> 0 and titulo.cxacod <> vcaixa then next.
            
            if titulo.titnat = yes then next.
            if d.titulo.etbcobra <> estab.etbcod
            then next.
            if d.titulo.cxmdat <> vdata
            then next.
            if d.titulo.titdtpag = ?
            then next.
            if d.titulo.titsit = "LIB"
            then next.
            if d.titulo.titdtpag <> vdata
            then next.
            if d.titulo.titpar    = 0
            then next.
            if d.titulo.clifor = 1
            then next.
            /*
            find first fin.caixa where  fin.caixa.etbcod = estab.etbcod and
                                    fin.caixa.cxacod = d.titulo.cxacod 
                                    no-lock no-error.
            if not avail fin.caixa then next.
            */
            if d.titulo.modcod = "VVI" or d.titulo.modcod = "CHQ" or
               d.titulo.modcod = "CHP" /** Masiero **/
            then next.
            if d.titulo.modcod = "CRE" and d.titulo.moecod = "DEV" then next.
            
            find first fin.titulo where
                       fin.titulo.empcod = d.titulo.empcod and 
                       fin.titulo.titnat = d.titulo.titnat and
                       fin.titulo.modcod = d.titulo.modcod and
                       fin.titulo.etbcod = d.titulo.etbcod and
                       fin.titulo.clifor = d.titulo.clifor and
                       fin.titulo.titnum = d.titulo.titnum and
                       fin.titulo.titpar = d.titulo.titpar
                       no-lock no-error.
            if avail fin.titulo
            then next.            
            if d.titulo.moecod = "PDM"
            then  for each titpag where
                           titpag.empcod = d.titulo.empcod and
                           titpag.titnat = d.titulo.titnat and
                           titpag.modcod = d.titulo.modcod and
                           titpag.etbcod = d.titulo.etbcod and
                           titpag.clifor = d.titulo.clifor and
                           titpag.titnum = d.titulo.titnum and
                           titpag.titpar = d.titulo.titpar
                           no-lock:
                     if   titpag.cxmdat = d.titulo.cxmdat and
                        titpag.cxmhor = d.titulo.cxmhor
                     then. else next.

                    find bmoeda where bmoeda.moecod = titpag.moecod
                                no-lock no-error.
                    if avail bmoeda
                    then do:
                        if bmoeda.moetit = yes
                        then vlpagcartao = vlpagcartao + titpag.titvlpag.
                        else do:
                            vlpres = vlpres +  titpag.titvlpag.
                            run Pi-Cria-Anali(input "titulo", input 4, 
                               input titpag.moecod, input titpag.titvlpag, 
                               input 1).
                        end.
                        if bmoeda.moecod = "PRE"
                        then assign  vljurpre = vljurpre + d.titulo.titjuro.

                    end.
                    else do:
                        vlpres = vlpres +  titpag.titvlpag.
                        run Pi-Cria-Anali(input "titulo", input 4, 
                               input titpag.moecod, input titpag.titvlpag, 
                               input 1).
                        if titpag.moecod = "PRE"
                        then assign  vljurpre = vljurpre + d.titulo.titjuro.

                    end.
                  end.
            else do: 
            
            find bmoeda where bmoeda.moecod = d.titulo.moecod no-lock no-error.
            if avail bmoeda
            then do:
           
                if bmoeda.moetit = yes
                then do:
                    vlpagcartao = vlpagcartao + d.titulo.titvlcob.
                end.
                else do:
                   run Pi-Cria-Anali(input "titulo", input 4, 
                           input d.titulo.modcod, input d.titulo.titvlcob, 
                           input 1).
                    if v-gravou-ana = yes then
                    vlpres = vlpres + d.titulo.titvlcob.
                end.    

            end.
            else do:
                run Pi-Cria-Anali(input "titulo", input 4, 
                           input d.titulo.modcod, input d.titulo.titvlcob, 
                           input 1).
                if v-gravou-ana = yes then
                vlpres = vlpres + d.titulo.titvlcob.
            end.    
            
            if d.titulo.moecod = "NOV"
            then do:
               run Pi-Cria-Anali(input "titulo", input 10, 
                           input d.titulo.modcod, input d.titulo.titvlcob, 
                           input 1).
               if v-gravou-ana = yes
               then assign vlnov  = vlnov + d.titulo.titvlcob
                           ct-nov = ct-nov + 1.
            end.
            end.
            create tt-titulo.
            buffer-copy d.titulo to tt-titulo.
            
    end.

 disp "Filial : " + string(estab.etbcod) + " Fase 5.1  " @ vfase                     with frame fdisplay no-labels no-box centered row 10.
 pause 0.

 
 for each fin.caixa where fin.caixa.etbcod = estab.etbcod no-lock:
        
        if vcaixa <> 0 and fin.caixa.cxacod <> vcaixa then next.

        for each d.titulo where d.titulo.datexp = vdata no-lock.
            if d.titulo.modcod = "VVI" or
               d.titulo.modcod = "CHQ" /*or
               d.titulo.moecod = "CAR"*/
            then next.
               
            if d.titulo.cxacod   = fin.caixa.cxacod and
               d.titulo.etbcod   = estab.etbcod and
               d.titulo.titpar   = 0            and
               d.titulo.titdtpag = vdata        
            then do:
                run Pi-Cria-Anali(input "titulo", input 3,                                                       input d.titulo.modcod, input                                     d.titulo.titvlcob,
                                  input 1).
                if v-gravou-ana = yes
                then   assign ct-entr = ct-entr + 1
                       vlentr  = vlentr + d.titulo.titvlcob.
            end.
        end.
 end.
 disp "Filial : " + string(estab.etbcod) + " Fase 6.1  " @ vfase                             with frame fdisplay no-labels centered row 10.
            pause 0.

 for each fin.caixa where fin.caixa.etbcod = estab.etbcod no-lock:
  
         if vcaixa <> 0 and fin.caixa.cxacod <> vcaixa then next.
        
         for each d.titulo where d.titulo.datexp = vdata 
                and d.titulo.cxacod = fin.caixa.cxacod no-lock.
                        assign vmodcod = d.titulo.modcod.
            if d.titulo.datexp <> d.titulo.cxmdat
            then next.
            if d.titulo.titdtpag <> vdata
            then next.

            if d.titulo.etbcobra <> estab.etbcod
            then next.
            
            if d.titulo.titdtpag = ?
            then vmodcod = "VDP".
            
            if d.titulo.cxacod <> fin.caixa.cxacod
            then next.
            
            if d.titulo.titpar    = 0 or
               d.titulo.clifor    = 1
            then do:
                if d.titulo.clifor = 1
                then vmodcod = "VDV".
                else vmodcod = "ENT".
            end.

            if d.titulo.modcod = "VVI"
            then vmodcod = "VDV".

            if d.titulo.modcod = "CRE"
            then do:
             
                 p-juro = 0.
                if d.titulo.titjuro > 0
                then do:
                    run Pi-Cria-Anali(input "titulo", input 5, 
                           input d.titulo.modcod, input d.titulo.titjuro, 
                           input 1).
                    /*
                    if v-gravou-ana = yes
                    then*/ assign vljuro = vljuro + d.titulo.titjuro.
                end.
                if d.titulo.titdesc > 0
                then do:
                        run Pi-Cria-Anali(input "titulo", input 6, 
                                input d.titulo.modcod, input d.titulo.titdesc, 
                                input 1).
                        /*
                        if v-gravou-ana = yes
                        then */
                        assign vldesc = vldesc + d.titulo.titdesc.
                end.
            end.

            if vmodcod <> "CRE"
            then next.
            
            find bmoeda where bmoeda.moecod = d.titulo.moecod no-lock no-error.
            if avail bmoeda
            then do:
                if bmoeda.moetit = yes
                then ct-pagcartao = ct-pagcartao + (if d.titulo.titvlcob > 0
                                                    then 1 else 0).
                else ct-pres = ct-pres + (if d.titulo.titvlcob > 0
                                          then 1 else 0).
            end.
            else ct-pres = ct-pres + if d.titulo.titvlcob > 0
                                     then 1
                                     else 0.
                                
            ct-juro = ct-juro + if d.titulo.titjuro > 0
                                then 1
                                else 0.
            ct-desc = ct-desc + if d.titulo.titdesc > 0
                                then 1
                                else 0.
         end.
 end.


 for each fin.caixa where fin.caixa.etbcod = estab.etbcod no-lock:

        if vcaixa <> 0 and fin.caixa.cxacod <> vcaixa then next.

        for each d.titulo where d.titulo.datexp = vdata
                          and d.titulo.modcod = "DEV"
                          and d.titulo.etbcod = estab.etbcod
                                                no-lock:
                if d.titulo.cxacod <> fin.caixa.cxacod then next.

                if d.titulo.titobs[2] = "DEVOLUCAO" and d.titulo.titvlpag <> 0
                then do:
                    assign v-gravou-ana = no.     
                    run Pi-Cria-Anali(input "titulo", input 7, 
                           input d.titulo.modcod, input d.titulo.titvlpag, 
                           input 1).
                    if v-gravou-ana = yes 
                    then assign vdevolucao = vdevolucao + d.titulo.titvlpag
                            ct-devolucao = ct-devolucao + 1.
                end.
        
        end.                                    
        disp "Filial : " + string(estab.etbcod) + " Fase  7.1 " @ vfase                          with frame fdisplay no-labels centered row 10.
                pause 0.

        for each plani use-index pladat where plani.movtdc = 5 and
                                      plani.etbcod = estab.etbcod and
                                      plani.pladat = vdata no-lock:
                                      
            if plani.cxacod = fin.caixa.cxacod
            then do:
                find d.titulo where d.titulo.empcod = wempre.empcod and
                                  d.titulo.titnat = no            and
                                  d.titulo.modcod = "CRE"         and
                                  d.titulo.etbcod = setbcod       and
                                  d.titulo.clifor = 1             and
                                  d.titulo.titnum = string(plani.numero) no-lock
                                  no-error.

                if avail d.titulo
                then do:
                    if plani.crecod = 1 and
                       d.titulo.titdtpag <> plani.pladat
                    then assign vnumtra = vnumtra + plani.protot
                                                  /* + plani.frete */
                                                  + plani.acfprod.
                end.

                if plani.crecod = 1
                then do:
                   /****************************
                    assign ct-vist  = ct-vist + 1
                           
                            vlauxt  = (plani.protot /* + plani.frete */
                                    + plani.acfprod - plani.descprod)
                                    - plani.vlserv.
                            vlvist = vlvist + (plani.protot /* + plani.frete */
                                            + plani.acfprod - plani.descprod)
                                            - plani.vlserv.
                    *****************/
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
                     
                    run Pi-Cria-Anali(input "plani", input 2, 
                                       input plani.modcod, input vlauxt,
                                       input 1).
                    if v-gravou-ana = yes
                    then 
                    assign vlauxt = vlauxt - vvalor-cartpre
                                    vlvist = vlvist - vvalor-cartpre.
                    vlauxt = 0.
                    
                end.
                                                            
                if plani.crecod = 2
                then do:
                        /* Val.Prazo (Contratos) */
                        run Pi-Cria-Anali(input "plani", input 1, 
                           input "", input (plani.vlserv * - 1), input 1).
                        if v-gravou-ana = yes 
                        then vlpraz = vlpraz - plani.vlserv.

                end.
                if plani.crecod = 2 and
                   plani.vlserv > 0
                then do:
                     assign ct-dev = ct-dev + 1
                            vldev = vldev + plani.vlserv.
                end.
            end.
        end.
 end.

 for each fin.caixa where fin.caixa.etbcod = estab.etbcod no-lock:

    if vcaixa <> 0 and fin.caixa.cxacod <> vcaixa then next.
    
    for each d.titulo where d.titulo.datexp = vdata no-lock.

            if vcaixa <> 0 and d.titulo.cxacod <> fin.caixa.cxacod then next.

            if d.titulo.datexp <> d.titulo.cxmdat
            then next.
            if d.titulo.titdtpag <> vdata
            then next.
            if d.titulo.cxacod <> fin.caixa.cxacod
            then next.
            if vmodcod <> "CRE"
            then next.
    end.
    
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

def var vnumdoc as char.

assign v-gravou-ana = no.

if p-tipo = "contrato" 
then do:

    find first clien where clien.clicod = d.contrato.clicod no-lock no-error.
    find first d.titulo use-index titnum
         where d.titulo.empcod = wempre.empcod and
               d.titulo.titnat = no and
               d.titulo.modcod = "CRE" and
               d.titulo.etbcod = contrato.etbcod and
               d.titulo.clifor = contrato.clicod and
               d.titulo.titnum = string(contrato.contnum)
               no-lock no-error.
    if vcaixa <> 0 and d.titulo.cxacod <> vcaixa then leave.
    else do:
        find first tt-caixa-anali use-index key1 where 
               tt-caixa-anali.data   = d.titulo.cxmda   and 
               tt-caixa-anali.etbcod = d.titulo.etbcod  and
               tt-caixa-anali.cxacod = d.titulo.cxacod  and
               tt-caixa-anali.numdoc = d.titulo.titnum and
               tt-caixa-anali.tpreg  = p-reg
           no-error.                                                                 if not avail tt-caixa-anali                                                    then do:           
             assign v-gravou-ana     = yes.
             create tt-caixa-anali.                                                          assign
             tt-caixa-anali.etbcod   = contrato.etbcod                                      tt-caixa-anali.cxacod   = d.titulo.cxacod 
             tt-caixa-anali.numdoc   = d.titulo.titnum
             tt-caixa-anali.tpreg    = p-reg
             tt-caixa-anali.data     = contrato.datexp
             tt-caixa-anali.modcod   = d.titulo.modcod                                        tt-caixa-anali.parcela  = titulo.titpar    
             tt-caixa-anali.clifor   = d.titulo.clifor
             tt-caixa-anali.vlcob    = p-vltrans
             tt-caixa-anali.vltrans  = p-vltrans
             tt-caixa-anali.qttrans  = p-qtde.                                         end.
    end.          
    return.
end.

if p-tipo = "titluc"
then do:
   find first tt-caixa-anali use-index key1 where 
        tt-caixa-anali.data   = d.titluc.cxmda and 
        tt-caixa-anali.etbcod = d.titluc.etbcobra and
        tt-caixa-anali.cxacod = d.titluc.cxacod and
        tt-caixa-anali.numdoc = d.titluc.titnum and
        tt-caixa-anali.parcela = d.titluc.titpar and
        tt-caixa-anali.tpreg  = p-reg
               no-error.                                                       
        if not avail tt-caixa-anali                                                    then do:
            assign v-gravou-ana     = yes.
            create tt-caixa-anali.
            assign tt-caixa-anali.etbcod   = d.titluc.etbcobra
            tt-caixa-anali.cxacod   = d.titluc.cxacod
            tt-caixa-anali.numdoc   = d.titluc.titnum   
            tt-caixa-anali.tpreg    = p-reg
            tt-caixa-anali.data     = d.titluc.cxmdat 
            tt-caixa-anali.modcod   = p-mod-cod 
            tt-caixa-anali.parcela  = d.titluc.titpar    
            tt-caixa-anali.clifor   = d.titluc.clifor 
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
        tt-caixa-anali.etbcod  = chqtit.etbcod and /* titulo.etbcod  and */
        tt-caixa-anali.parcela = chqtit.titpar and /* titulo.titpar  and */
        tt-caixa-anali.cxacod  = 0 and
        tt-caixa-anali.numdoc  = vnumdoc and
        tt-caixa-anali.tpreg  = p-reg
               no-error.                                                       
       if not avail tt-caixa-anali                                                      then do: 
            assign v-gravou-ana     = yes.
            create tt-caixa-anali.
            assign 
            tt-caixa-anali.etbcod   = chqtit.etbcod /* titulo.etbcod */
            tt-caixa-anali.cxacod   = 0 
            tt-caixa-anali.numdoc   = vnumdoc   
            tt-caixa-anali.tpreg    = p-reg
            tt-caixa-anali.data     = chq.data 
            tt-caixa-anali.modcod   = p-mod-cod 
            tt-caixa-anali.parcela  = chqtit.titpar  
            tt-caixa-anali.clifor   = chqtit.clifor 
            tt-caixa-anali.vlcob    = p-vltrans
            tt-caixa-anali.vltrans  = p-vltrans
            tt-caixa-anali.qttrans  = tt-caixa-anali.qttrans + p-qtde.      
        end.
        else v-gravou-ana = no.
        return.                                
end.

if p-tipo = "titulo" 
then do:
   find first tt-caixa-anali use-index key1 where 
        tt-caixa-anali.data   = d.titulo.cxmda and 
        tt-caixa-anali.etbcod = d.titulo.etbcobra and
        tt-caixa-anali.clifor = d.titulo.clifor and
        tt-caixa-anali.cxacod = d.titulo.cxacod and
        tt-caixa-anali.numdoc = d.titulo.titnum and
        tt-caixa-anali.parcela = d.titulo.titpar and
        tt-caixa-anali.tpreg   = p-reg
               no-error.                                                       
        if not avail tt-caixa-anali                                                     then do: 
            assign v-gravou-ana = yes.
            create tt-caixa-anali.
            assign tt-caixa-anali.etbcod   = d.titulo.etbcobra
            tt-caixa-anali.cxacod   = d.titulo.cxacod
            tt-caixa-anali.numdoc   = d.titulo.titnum   
            tt-caixa-anali.tpreg    = p-reg
            tt-caixa-anali.data     = d.titulo.cxmda 
            tt-caixa-anali.modcod   = p-mod-cod 
            tt-caixa-anali.parcela  = d.titulo.titpar    
            tt-caixa-anali.clifor   = d.titulo.clifor 
            tt-caixa-anali.vlcob    = d.titulo.titvlcob
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
    if not avail tt-caixa-anali                                                      then do:                            
          assign v-gravou-ana     = yes.
          create tt-caixa-anali.                                               
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

