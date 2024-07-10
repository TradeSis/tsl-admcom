/**********************************************************    
* codreca.p - Compras p/Filial/Vendedor/Cartao Drebes Parte 2         
* Autor : A.Maranghello                                        
* Data Criacao :16/07/2009                                     
* Ultima Alteracao :                                           
* Descricao Sumaria Alteracao :                                
***********************************************************/   

{admcab.i}
pause 0 before-hide.   
                                                               

def var v-opc-rel as char format "x(11)" extent 2 initial
[" Analitico ", " Sintetico "].  
def var v-ana-sin as int.                                          
def stream splanilha.                                                          def var vnumcart as dec.
def buffer bestab for estab.
def var vconsiderav as logical format "sim/nao".
def var v-excel     as logical format "sim/nao".                          
def var vendacar  as logical.
def var vdescfiliais as char.
def var v-desc-estab like estab.etbnom.         
def var v-ok as logical.
def var vkont as int.
def var vfilial like estab.etbcod.                             
def var vdatini  as date format "99/99/9999".                     
def var vcalcdis as dec.                  
def var vdatfin as date  format "99/99/9999".                                  def var vdt     as date no-undo.

def temp-table tt-cli
    field etbcod like estab.etbcod
    field clicod like clien.clicod
    field vencod like func.funcod
    field limdis1 as dec
    field limdis2 as dec
    field percen  as dec format "->>9.99"
    field qtdcom-ca  as int
    field qtdcom-sc  as int 
    field qtdcom-ger as int 
    field vlcom-ca  as dec
    field vlcom-sc  as dec
    field vlcom-ger as dec
    index clicod clicod.

def temp-table tt-ven
    field etbcod like estab.etbcod
    field vencod like func.funcod
    field clicod like clien.clicod
    field vennome as char 
    field qtdcom-ca  as int
    field qtdcom-sc  as int 
    field qtdcom-ger as int 
    field vlcom-ca  as dec format ">,>>>,>>9.99"
    field vlcom-sc  as dec format ">,>>>,>>9.99"
    field vlcom-ger as dec format ">,>>>,>>9.99"
     index vencod etbcod
                 vencod
                 clicod.

def temp-table tt-loja
    field etbcod like estab.etbcod
    field etbnom like estab.etbnom
    field qtdcar as int
    field qtdcom-ca  as int
    field qtdcom-sc  as int 
    field qtdcom-ger as int 
    field vlcom-ca  as dec
    field vlcom-sc  as dec
    field vlcom-ger as dec
    index filial etbcod.
    

def var vclfcod like clien.clicod.
def var vesc         as dec.
def var vcontapar    as int.
def var vnumparcpg   as int.
def var vcalclimite  as dec.
def var vmediaatraso as dec.
def var vpercrenda   as dec.
def var vpardias     as int.
def var vcalclim     as dec.

def var varquivo as char.

def var varquivo2 as char.

form  vfilial label "Filial..........."
      estab.etbnom no-label
      skip
      vdatini label "Data Inicial....."
      skip
      vdatfin label "Data Final......." skip
      v-opc-rel[1] label  "Tipo de Relatorio" v-opc-rel[2] no-label
      with frame f-param 1 down side-label row 3 width 80
      title "Analise Compras C/Cartao Drebes e S/Cartao".


do on error undo:
 
   for each tt-ven.
       delete tt-ven.
   end.
   
   for each tt-loja.
       delete tt-loja.
   end.       
   
   for each tt-cli.
       delete tt-cli.
   end.

   assign vclfcod = 0
          vfilial = 0.

   if keyfunction(lastkey) = "end-error"
   then return.


  do on error undo:
        
        update vfilial with frame f-param.
        if vfilial <> 0
        then do:
            find first estab where estab.etbcod = vfilial no-lock no-error.
            if not avail estab then undo, retry.
            else disp estab.etbnom no-label with frame f-param.
            assign v-desc-estab = estab.etbnom.
        end.
        else do:
            disp "Geral" @ estab.etbnom with frame f-param.
            assign v-desc-estab = "Geral".
        end. 
        update vdatini vdatfin  with frame f-param.
        
        if keyfunction(last-key) = "end-error" then next.
        assign vkont = 0.    
        
        disp v-opc-rel 
                with frame f-param.
        choose field v-opc-rel with frame f-param.
        assign v-ana-sin = frame-index.
        assign vconsiderav = no.
        message "Considerar Vendas a Vista ? " update vconsiderav.

 
        hide frame f-most no-pause.
        
        /*  Vendas */
        for each bestab 
           where bestab.etbcod = (if vfilial <> 0 
                                  then vfilial
                                  else bestab.etbcod) no-lock:
           
            
           do vdt = vdatini to vdatfin:

               disp "Processando Vendas : " vdt no-label bestab.etbcod no-label 
                       with frame f-most3 centered no-box 
                            row 10 side-labels.
              pause 0.
              for each plani where plani.movtdc = 5 and
                                   plani.etbcod = bestab.etbcod and
                                   plani.pladat = vdt 
                                   no-lock:

                  find func where func.etbcod = plani.etbcod and   
                           func.funcod = plani.vencod       
                                         no-lock no-error.                
                  if not avail func then next.
                  if vconsiderav = no and plani.desti = 1 then next.
                  
                  assign vendacar = no.
                  if plani.notobs[1] matches "*CARTAO-LEBES*"
                  then  do:
                    vnumcart = dec(acha("CARTAO-LEBES", plani.notobs[1])) + 0.                      if vnumcart > 0 then vendacar = yes.
                  end.
                  
                  find first tt-loja where tt-loja.etbcod = plani.etbcod 
                        no-error.
                  if not avail tt-loja 
                  then do: 
                    create tt-loja.
                    assign tt-loja.etbcod = plani.etbcod
                           tt-loja.etbnom = bestab.etbnom 
                                        when avail estab.
                  end.
                  
                  find first tt-cli where tt-cli.etbcod = plani.etbcod and
                                          tt-cli.clicod = plani.desti no-error.

                  if not avail tt-cli 
                  then do:
                      create tt-cli.
                      assign tt-cli.etbcod = plani.etbcod
                             tt-cli.clicod = plani.desti
                             tt-cli.limdis1 = ?
                             tt-cli.limdis2 = ?.
                  end.
                  
                  if plani.notobs[1] matches "*LIMITE-DISPONIVEL*"
                  then do: 
                    assign tt-cli.limdis2 = dec(acha("LIMITE-DISPONIVEL",
                                            plani.notobs[1])) - 
                       (if plani.biss <> 0 then plani.biss
                                           else plani.platot).
                    if tt-cli.limdis1 = ? 
                    then assign tt-cli.limdis1 = dec(acha("LIMITE-DISPONIVEL",  
                                                     plani.notobs[1])).                          
                  end.

                  /* Limite Disponivel apenas p/Compras c/Cartao */
                  /* Jessica em 02/10/2009 */
                  if vendacar = no
                  then assign 
                       tt-cli.limdis1 = ?
                       tt-cli.limdis2 = ?
                       tt-cli.perce   = ?.
                  /**/
                  if tt-cli.limdis2 > 0 and tt-cli.limdis2 <> ? and
                    tt-cli.limdis1 > 0 and tt-cli.limdis1 <> ?
                  then  
                  assign tt-cli.perce = (tt-cli.limdis2 / tt-cli.limdis1) * 100.
                  /* Vendedores */
                  find first tt-ven where tt-ven.etbcod = plani.etbcod and
                                          tt-ven.vencod = plani.vencod and
                                          tt-ven.clicod = plani.desti no-error.
                  if not avail tt-ven
                  then do:
                      create tt-ven.
                      assign tt-ven.vencod = plani.vencod
                             tt-ven.etbcod = plani.etbcod
                             tt-ven.clicod = plani.desti.
                      find func where func.etbcod = plani.etbcod and   
                           func.funcod = plani.vencod       
                                         no-lock no-error.                
                       if avail func                                   
                      then tt-ven.vennome = func.funnom.             
                  end.

                  if vendacar = yes 
                  then do:
                        assign tt-ven.vlcom-ca = tt-ven.vlcom-ca  + 
                            (if plani.biss <> 0 then 
                            plani.biss else plani.platot)
                            tt-ven.qtdcom-ca = tt-ven.qtdcom-ca + 1.
                  end.
                  if vendacar = no 
                  then do:
                        assign tt-ven.vlcom-sc = tt-ven.vlcom-sc  + 
                            (if plani.biss <> 0 then 
                            plani.biss else plani.platot)
                            tt-ven.qtdcom-sc = tt-ven.qtdcom-sc + 1.
                  end.
                  
                  /* Geral */
                  assign tt-ven.vlcom-ger = tt-ven.vlcom-ger  + 
                            (if plani.biss <> 0 then 
                            plani.biss else plani.platot)
                            tt-ven.qtdcom-ger = tt-ven.qtdcom-ger + 1.
              
              end. /* plani */
           end. /* Data */
        end. /* estab */
        assign vdescfiliais = "Geral".
        if vfilial <> 0 
        then do:
            find first estab where estab.etbcod = vfilial no-lock no-error.
            assign vdescfiliais = estab.etbnom.
        end.
        v-excel = no.
        if setbcod = 999
        then do:
            v-excel = yes.
            message "Deseja Gerar Arquivo p/Excel ? " update v-excel.
        end.
        run Pi-Relato.
        next.
    end.    
end.

Procedure Pi-Relato.

def var v-aux-percen     as dec format "->>9.99".

def var v-tot-vend-lim1  as dec format "->>,>>>,>>9.99".
def var v-tot-vend-lim2  as dec format "->>,>>>,>>9.99".
def var v-tot-loja-lim1  as dec format "->>,>>>,>>9.99".
def var v-tot-loja-lim2  as dec format "->>,>>>,>>9.99".
def var v-tot-geral-lim1 as dec format "->>,>>>,>>9.99".
def var v-tot-geral-lim2 as dec format "->>,>>>,>>9.99".

def var v-totq-vend-ca  as int init 0.
def var v-totq-vend-sc  as int init 0.
def var v-totq-vend-ger as int init 0.
def var v-totv-vend-ca  as dec init 0.
def var v-totv-vend-sc  as dec init 0.
def var v-totv-vend-ger as dec init 0.

def var v-totq-loja-ca  as int init 0.
def var v-totq-loja-sc  as int init 0.
def var v-totq-loja-ger as int init 0.
def var v-totv-loja-ca  as dec init 0.
def var v-totv-loja-sc  as dec init 0.
def var v-totv-loja-ger as dec init 0.

def var v-totq-geral-ca  as int init 0.
def var v-totq-geral-sc  as int init 0.
def var v-totq-geral-ger as int init 0.
def var v-totv-geral-ca  as dec init 0.
def var v-totv-geral-sc  as dec init 0.
def var v-totv-geral-ger as dec init 0.

if opsys = "UNIX"
then assign varquivo  = "/admcom/relat/rcodreca." + string(time)
            varquivo2 = "/admcom/relat/rcodreca" + string(time) + ".csv".
else assign varquivo  = "l:~\relat~\rcodreca." + string(time)
            varquivo2 = "l:~\relat~\rcodreca" + string(time) + ".csv".

{mdad_l.i
 &Saida     = "value(varquivo)"
 &Page-Size = "66"
 &Cond-Var  = "132"
 &Page-Line = "66"
 &Nom-Rel   = ""CODRECA""
 &Nom-Sis   = """COMPRAS COMPARATIVAS COM/SEM CARTAO DREBES - FILIAL : "" + 
  vdescfiliais"
 &Tit-Rel   = """PERIODO "" + string(vdatini) + "" a "" + 
        string(vdatfin) + "" - FILIAL:"" + v-desc-estab "
 &Width     = "132"
 &Form      = "frame f-cabcab"}


if v-excel = yes 
then output stream splanilha to value(varquivo2).

def var v-cabec-exe as log init no.

for each tt-loja ,
    each tt-ven where tt-ven.etbcod = tt-loja.etbcod,
    each tt-cli where tt-cli.clicod = tt-ven.clicod
                   break by tt-ven.etbcod
                         by tt-ven.vencod
                         by tt-ven.clicod :


      if first-of(tt-ven.etbcod)
      then do:
              find first estab where estab.etbcod = tt-loja.etbcod
                    no-lock no-error.
              disp "Filial : " at 1 tt-loja.etbcod estab.etbnom skip(2)
                        with frame f-loja no-labels no-box.
      
              if v-excel = yes
              then do:
                     put stream splanilha
                        "Filial" ";" 
                        "Vendedor" ";"
                        "Nome" ";"
                        "Cliente" ";"
                        "Nome" ";"
                        "Limite Anterior" ";"
                        "Deixou De Vender" ";"
                        "% DV" ";"
                        "Qtde.Compras c/cartao" ";"
                        "Vl Compras c/cartao" ";"
                        "Qtde.Compras s/cartao" ";"
                        "Vl.Compras s/cartao" ";" 
                        "Total Qtde.Compras" ";"
                        "Total Vl. Compras" ";" skip.
              end.
      
      end.
      if first-of(tt-ven.vencod)  
      then do:
            if v-ana-sin = 1 
            then disp  skip(2) "Vendedor : " at 5 tt-ven.vencod tt-ven.vennom
                       with frame f-vende no-labels no-box.
      end.
      find first clien where clien.clicod = tt-ven.clicod no-lock no-error.

      if tt-cli.limdis1 = ? then tt-cli.limdis1 = 0.
      if tt-cli.limdis2 = ? then tt-cli.limdis2 = 0.
      if tt-cli.limdis2 < 1 then tt-cli.limdis2 = 0.
      if tt-cli.limdis1 < 1 then tt-cli.limdis1 = 0.
      if tt-cli.percen < 0 then tt-cli.percen = ?.
      
      if tt-ven.qtdcom-sc = ? then tt-ven.qtdcom-sc = 0.
      if tt-ven.vlcom-sc = ? then tt-ven.vlcom-sc = 0.
      if tt-ven.vlcom-ger = ? then tt-ven.vlcom-ger = 0.
      if tt-ven.qtdcom-ger = ? then tt-ven.qtdcom-ger = 0.
      if tt-ven.qtdcom-ca = ? then tt-ven.qtdcom-ca = 0.
      if tt-ven.vlcom-ca = ? then tt-ven.vlcom-ca = 0.
                 
      if v-ana-sin = 1
      then
         disp 
           tt-ven.clicod  column-label "Cliente"
           clien.clinom   column-label "Nome" FORMAT "x(35)"
            when avail clien
           tt-cli.limdis1 column-label "Limite!Anterior"
                when tt-cli.limdis1 <> ?  format "->,>>>,>>9.99"
           tt-cli.limdis2 column-label "Deixou!De Vender"
                when tt-cli.limdis2 <> ?  format "->,>>>,>>9.99"
           tt-cli.percen  column-label "% DV"
                when tt-cli.percen <> ?
           tt-ven.qtdcom-ca column-label "C/Cartao!Qtde.Comp."
           tt-ven.vlcom-ca  column-label "C/Cartao!Valor Comp." 
                                         format "->,>>>,>>9.99"
           tt-ven.qtdcom-sc  column-label "S/Cartao!Qtde.Comp."
           tt-ven.vlcom-sc   column-label "S/Cartao!Val Comp." 
                                        format "->,>>>,>>9.99"
           tt-ven.qtdcom-ger column-label "Total!Qtde.Compras"
           tt-ven.vlcom-ger  column-label "Total!Val. Compras" 
                                        format "->,>>>,>>9.99"
        with frame fmostra width 152 down.
      down with frame fmostra.

      if v-excel = yes and v-ana-sin = 1
      then do:
           put  stream splanilha
                tt-loja.etbcod ";"
                tt-ven.vencod  ";"
                tt-ven.vennom ";"
                tt-ven.clicod ";"
                clien.clinom  ";"
                (if tt-cli.limdis1 <> ? then string(tt-cli.limdis1) else "") ";"
                (if tt-cli.limdis2 <> ? then string(tt-cli.limdis2) else "") ";"
                (if tt-cli.percen <>  ? then string(tt-cli.percen) else "") ";"
                tt-ven.qtdcom-ca format ">>>>>>>>9" ";"
                tt-ven.vlcom-ca  format ">>>,>>>,>>9.99" ";" 
                tt-ven.qtdcom-sc format ">>>>>>>>9" ";"
                tt-ven.vlcom-sc  format ">>>,>>>,>>9.99" ";" 
                tt-ven.qtdcom-ger format ">>>>>>>>9" ";"
                tt-ven.vlcom-ger format ">>>,>>>,>>9.99"  ";" skip.
      end.
 
      /* Total dos Vendedores */
      assign v-totq-vend-ca = v-totq-vend-ca + tt-ven.qtdcom-ca /* Com Cartao */
             v-totv-vend-ca = v-totv-vend-ca + tt-ven.vlcom-ca
             v-totq-vend-sc = v-totq-vend-sc + tt-ven.qtdcom-sc /* Sem Cartao */
             v-totv-vend-sc = v-totv-vend-sc + tt-ven.vlcom-sc
             v-totq-vend-ger  = v-totq-vend-ger  /*  Geral  */
                                                    + tt-ven.qtdcom-ca 
                                                    + tt-ven.qtdcom-sc
              v-totv-vend-ger  = v-totv-vend-ger            
                                                    + tt-ven.vlcom-ca 
                                                    + tt-ven.vlcom-sc.
      assign v-tot-vend-lim1 = v-tot-vend-lim1 + tt-cli.limdis1
             v-tot-vend-lim2 = v-tot-vend-lim2 + tt-cli.limdis2.
       
      /* Total das lojas */
      assign v-totq-loja-ca = v-totq-loja-ca + tt-ven.qtdcom-ca /* Com Cartao */
             v-totv-loja-ca = v-totv-loja-ca + tt-ven.vlcom-ca
             v-totq-loja-sc = v-totq-loja-sc + tt-ven.qtdcom-sc /* Sem Cartao */
             v-totv-loja-sc = v-totv-loja-sc + tt-ven.vlcom-sc
             v-totq-loja-ger  = v-totq-loja-ger            /*  Geral  */
                                                    + tt-ven.qtdcom-ca 
                                                    + tt-ven.qtdcom-sc
              v-totv-loja-ger  = v-totv-loja-ger            
                                                    + tt-ven.vlcom-ca 
                                                    + tt-ven.vlcom-sc.

        assign v-tot-loja-lim1 = v-tot-loja-lim1 + tt-cli.limdis1
               v-tot-loja-lim2 = v-tot-loja-lim2 + tt-cli.limdis2.
   
      /* Total Geral */
      assign v-totq-geral-ca = v-totq-geral-ca + tt-ven.qtdcom-ca /* C/Cartao */
             v-totv-geral-ca = v-totv-geral-ca + tt-ven.vlcom-ca
             v-totq-geral-sc = v-totq-geral-sc + tt-ven.qtdcom-sc /* S/Cartao */
             v-totv-geral-sc = v-totv-geral-sc + tt-ven.vlcom-sc
             v-totq-geral-ger  = v-totq-geral-ger    /*  Geral  */
                                                    + tt-ven.qtdcom-ca 
                                                    + tt-ven.qtdcom-sc
              v-totv-geral-ger  = v-totv-geral-ger            
                                                    + tt-ven.vlcom-ca 
                                                    + tt-ven.vlcom-sc.

       assign v-tot-geral-lim1 = v-tot-geral-lim1 + tt-cli.limdis1
              v-tot-geral-lim2 = v-tot-geral-lim2 + tt-cli.limdis2.

      if last-of(tt-ven.vencod)
      then do:

          v-aux-percen = (v-tot-vend-lim2 / v-tot-vend-lim1) * 100. 
          
          if v-ana-sin = 1
          then
           disp "" @ tt-ven.clicod
               "    Total do Vendedor => " @ clien.clinom
               v-tot-vend-lim1  @ tt-cli.limdis1
               v-tot-vend-lim2  @ tt-cli.limdis2
               v-aux-percen     @ tt-cli.percen
               v-totq-vend-ca  @ tt-ven.qtdcom-ca
               v-totv-vend-ca  @ tt-ven.vlcom-ca  
               v-totq-vend-sc  @ tt-ven.qtdcom-sc
               v-totv-vend-sc  @ tt-ven.vlcom-sc  
               v-totq-vend-ger @ tt-ven.qtdcom-ger
               v-totv-vend-ger @ tt-ven.vlcom-ger   
               with frame fmostra width 148 down.
           else
           disp "" @ tt-ven.clicod no-label
               tt-ven.vennom    @ func.funnom label "Vendedor"
               v-tot-vend-lim1  @ tt-cli.limdis1    format "->,>>>,>>9.99"
               v-tot-vend-lim2  @ tt-cli.limdis2    format "->,>>>,>>9.99"
               v-aux-percen     @ tt-cli.percen
               v-totq-vend-ca  @ tt-ven.qtdcom-ca
               v-totv-vend-ca  @ tt-ven.vlcom-ca    format "->,>>>,>>9.99"
               v-totq-vend-sc  @ tt-ven.qtdcom-sc
               v-totv-vend-sc  @ tt-ven.vlcom-sc    format "->,>>>,>>9.99"
               v-totq-vend-ger @ tt-ven.qtdcom-ger
               v-totv-vend-ger @ tt-ven.vlcom-ger   format "->,>>>,>>9.99"
          with frame fmostrav width 148 down.
          
          if v-excel = yes
          then do:
            put stream splanilha
                tt-loja.etbcod ";"
                tt-ven.vencod ";"
                tt-ven.vennom ";"
                ";"
                ";"
                v-tot-vend-lim1 ";"
                v-tot-vend-lim2 ";"
                v-aux-percen    ";"
                v-totq-vend-ca format ">>>>>>>>9" ";"
                v-totv-vend-ca  format ">>>,>>>,>>9.99" ";"  
                v-totq-vend-sc  format ">>>>>>>>9" ";"
                v-totv-vend-sc  format ">>>,>>>,>>9.99" ";"  
                v-totq-vend-ger format ">>>>>>>>9" ";"
                v-totv-vend-ger format ">>>,>>>,>>9.99" ";" skip.             
          end.

          assign    v-tot-vend-lim1 = 0
                    v-tot-vend-lim2 = 0
                    v-totq-vend-ca = 0
                    v-totv-vend-ca = 0
                    v-totq-vend-sc = 0
                    v-totv-vend-sc = 0
                    v-totq-vend-ger = 0
                    v-totv-vend-ger = 0.
      end.

      if last-of(tt-ven.etbcod)
      then do:
          v-aux-percen = (v-tot-loja-lim2 / v-tot-loja-lim1) * 100. 
          if v-ana-sin = 1
          then
          disp "" @ tt-ven.clicod
               "Total da Loja => " @ clien.clinom
               v-tot-loja-lim1     @ tt-cli.limdis1
               v-tot-loja-lim2     @ tt-cli.limdis2
               v-aux-percen        @ tt-cli.percen
               v-totq-loja-ca      @ tt-ven.qtdcom-ca
               v-totv-loja-ca      @ tt-ven.vlcom-ca  
               v-totq-loja-sc      @ tt-ven.qtdcom-sc
               v-totv-loja-sc      @ tt-ven.vlcom-sc  
               v-totq-loja-ger     @ tt-ven.qtdcom-ger
               v-totv-loja-ger     @ tt-ven.vlcom-ger  
               with frame fmostra width 178 down.
           else
           disp "" @ tt-ven.clicod
               "Total da Loja => " @ func.funnom
               v-tot-loja-lim1     @ tt-cli.limdis1      format "->,>>>,>>9.99"
               v-tot-loja-lim2     @ tt-cli.limdis2      format "->,>>>,>>9.99"
               v-aux-percen        @ tt-cli.percen
               v-totq-loja-ca      @ tt-ven.qtdcom-ca
               v-totv-loja-ca      @ tt-ven.vlcom-ca     format "->,>>>,>>9.99"
               v-totq-loja-sc      @ tt-ven.qtdcom-sc
               v-totv-loja-sc      @ tt-ven.vlcom-sc     format "->,>>>,>>9.99"
               v-totq-loja-ger     @ tt-ven.qtdcom-ger
               v-totv-loja-ger     @ tt-ven.vlcom-ger    format "->,>>>,>>9.99"
               with frame fmostrav width 178 down.
 


          if v-excel = yes
          then do:
          put stream splanilha 
                ";"
                "Total da Loja" ";"
                ";"
                ";"
                ";"
                v-tot-loja-lim1 ";"
                v-tot-loja-lim2 ";"
                v-aux-percen    ";"
                v-totq-loja-ca  ";"
                v-totv-loja-ca  format ">>>,>>>,>>9.99" ";"  
                v-totq-loja-sc  format ">>>>>>>>9" ";"
                v-totv-loja-sc  format ">>>,>>>,>>9.99" ";"  
                v-totq-loja-ger format ">>>>>>>>9" ";"
                v-totv-loja-ger format ">>>,>>>,>>9.99" ";" skip.             
          end.

          assign   v-tot-loja-lim1 = 0
                   v-tot-loja-lim2 = 0
                   v-totq-loja-ca = 0
                   v-totv-loja-ca = 0
                   v-totq-loja-sc = 0
                   v-totv-loja-sc = 0
                   v-totq-loja-ger = 0
                   v-totv-loja-ger = 0.
      end.
end.

v-aux-percen = (v-tot-geral-lim2 / v-tot-geral-lim1) * 100. 

disp "" @ tt-ven.clicod
               "Total Geral =>" @ clien.clinom
               v-tot-geral-lim1 @ tt-cli.limdis1    format "->,>>>,>>9.99"
               v-tot-geral-lim2 @ tt-cli.limdis2    format "->,>>>,>>9.99"
               v-aux-percen    @ tt-cli.percen
               v-totq-geral-ca  @ tt-ven.qtdcom-ca
               v-totv-geral-ca  @ tt-ven.vlcom-ca   format "->,>>>,>>9.99"
               v-totq-geral-sc  @ tt-ven.qtdcom-sc
               v-totv-geral-sc  @ tt-ven.vlcom-sc   format "->,>>>,>>9.99"
               v-totq-geral-ger @ tt-ven.qtdcom-ger
               v-totv-geral-ger @ tt-ven.vlcom-ger  format "->>>,>>>,>>9.99"
          with frame fmostraf no-label width 178 down.


if v-excel = yes
then do:
    output stream splanilha close.   
    message "Arquivo gerado para Excel :" skip
             varquivo2 view-as alert-box.
end.

output close.

run visurel.p (varquivo,"").

sresp = no.
if setbcod = 999
then 
message "Deseja Imprimir o Relatorio?" update sresp.
if sresp = no then leave.

if opsys = "UNIX"
then do:
  run visurel.p (input varquivo, input "").
end.
else do:
  {mrod.i}.
end.

end procedure.
