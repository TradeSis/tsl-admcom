/* ***************************************************************************
*  Programa........: rlvddes1.p
*  Funcao..........: Relatorio de vendas com filtro de % de
*                    desconto concedido
*  Data............: 02/03/2007
*  Autor...........: Gerson L.S. Mathias
*************************************************************************** */ 

{admcab.i}

def var i_regs       as inte form ">>>>>>9"     init 0              no-undo.  
def var i_cont       as inte form ">>>>>>9"     init 0              no-undo.
def var t_dataini    as date form "99/99/9999"  init today          no-undo.
def var t_datafin    as date form "99/99/9999"  init today          no-undo.
def var d_prcdsci    as deci form ">>9.99"      init 0              no-undo.  
def var d_prcdscf    as deci form ">>9.99"      init 0              no-undo.

def var i_etbcod     like estab.etbcod.
def var c_etbnom     like estab.etbnom.
def var i_catcod     like categoria.catcod.
def var c_catnom     like categoria.catnom.
def var c_funnom     like func.funnom.  

def var v_perc   as deci form ">>9.99"        init 0.
def var v_vldes  as deci form ">>>,>>9.99"    init 0.

def temp-table tt-mov         no-undo
    field procod    like produ.procod
    field pronom    like produ.pronom
    field precdes   like v_perc
    field platot    like plani.platot 
    field plaori    like plani.platot
    field vlrdes    like plani.platot
    field funnom    like func.funnom.
/* ------------------------------------------------------------------------ */

   assign t_dataini = today - 10. 

/* ------------------------------------------------------------------------ */

form 
     i_etbcod  label "Estab"
     c_etbnom  no-label
     skip 
     t_dataini label "Data Inicial"
     t_datafin label "Data final"
     skip
     d_prcdsci label "% desc Inicial"
     d_prcdscf label "% Final"
     skip
     i_catcod  label "Depto"  form ">>9"
     c_catnom  no-label   form "x(20)"
     with side-labels 3 col 1 down frame f-upd
          width 80 title "RELATORIO VENDAS COM DESCONTO".

update i_etbcod  label "Estab"
       with frame f-upd.

if i_etbcod <> 0
then do: 
    find first estab where
               estab.etbcod = (if i_etbcod <> 0
                               then i_etbcod
                               else estab.etbcod) no-lock no-error.
    if avail estab
    then do:
            assign c_etbnom = estab.etbnom.
            disp c_etbnom
                 with frame f-upd.                    
    end.
    else do:
            assign c_etbnom = "Estab nao encontrado!".
            disp c_etbnom
                 with frame f-upd.
            undo, retry.     
    end.
end.
else do:
        assign c_etbnom = "Todos!".
        disp c_etbnom
             with frame f-upd.
end.    
       
update t_dataini label "Data Inicial"
       t_datafin label "Data final"
       d_prcdsci
       d_prcdscf
       i_catcod 
       with frame f-upd.

find first categoria where
           categoria.catcod = i_catcod no-lock no-error.
if avail categoria
then do:
        assign c_catnom = categoria.catnom.
        disp c_catnom
             with frame f-upd.
end.
else do:
        assign c_catnom = "Nao encontrada".
        disp c_catnom
             with frame f-upd.
        undo, retry.     
end.

run pi-processo.
run pi-imprime.

procedure pi-processo:

    for each tt-mov:
    
        delete tt-mov.

    end.

    for each plani where
             plani.movtdc = 5          and
             plani.etbcod = i_etbcod   and
             plani.pladat >= t_dataini and
             plani.pladat <= t_datafin no-lock:
             
        for each movim where
                 movim.etbcod = plani.etbcod  and
                 movim.placod = plani.placod  no-lock:
                 
            find first produ where
                       produ.procod = movim.procod and
                       produ.catcod = i_catcod no-lock no-error.
            if avail produ
            then do:
                   find estoq where
                        estoq.procod = produ.procod   and
                        estoq.etbcod = plani.etbcod   no-lock no-error.
                   if avail estoq
                   then do:
                        if movim.movpc <> estoq.estvenda
                        then do:  
                              
                           disp plani.placod form ">>>>>>>>>>>>9"
                                with centered no-label 1 col 1 down 
                                     frame f-dis title "Processando".
                           pause 0 no-message.
                           
                           find first func where
                                      func.funcod = plani.vencod 
                                      no-lock no-error.
                           if avail func
                           then assign c_funnom = func.funnom.
                           else assign c_funnom = "".            

                           assign v_perc  = 0
                                  v_vldes = 0.

                           assign v_vldes = estoq.estvenda - movim.movpc.
                           assign v_perc  = (estoq.estvenda * v_vldes) / 100.
       
                           v_perc = movim.movpc * 100 / estoq.estvenda.

                           if v_perc >= d_prcdsci and
                              v_perc <= d_prcdscf
                           then do:
                           
                              create tt-mov.
                              assign tt-mov.procod  = produ.procod
                                     tt-mov.pronom  = produ.pronom
                                     tt-mov.platot  = movim.movpc
                                     tt-mov.plaori  = estoq.estvenda  
                                     tt-mov.funnom  = c_funnom
                                     tt-mov.vlrdes  = v_vldes
                                     tt-mov.precdes = v_perc.    
                           end.
                                  
                        end.
                   end.
            end.
       end.     
    end.

end procedure. 

procedure pi-imprime:

def var varquivo as char.
def var vdata    as date form "99/99/9999" init today. 
def var vhora    as char form "x(06)"      init  "".
def var iqtdProd as inte                   init 0.
def var dVlrCDes like plani.platot         init 0.
def var dVlrSDes like plani.platot         init 0.
def var dVlrDesc like plani.platot         init 0.

assign vhora = substring(string(time,"HH:MM:SS"),1,2) +
               substring(string(time,"HH:MM:SS"),4,2) +
               substring(string(time,"HH:MM:SS"),7,2).

  if opsys = "UNIX"
  then do:
          assign varquivo = "/admcom/relat/rlvdes"   +
                            vhora + ".txt".
  end.
  else do:
          assign varquivo = "l:~\relat~\rlvdes" + 
                            vhora + ".txt".
  end.

    
    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "68"
        &Cond-Var  = "118"
        &Page-Line = "68"
        &Nom-Rel   = ""RELVDES""
        &Nom-Sis   = """SISTEMA DE ESTOQUE"""
        &Tit-Rel   = """RELATORIO DE VENDAS COM DESCONTO""    +
                     "" DE: "" + string(d_prcdsci,"">>9.99"") + 
                     "" A "" +   string(d_prcdscf,"">>9.99"") +
                     "" % "" + "" CATEGORIA: "" + string(c_catnom,""x(18)"")"
        &Width     = "118"
        &Form      = "frame f-cab"}
                        /*
  output to value(varquivo).    
                          */
  assign iqtdProd = 0
         dVlrCDes = 0
         dVlrSDes = 0
         dVlrDesc = 0.
                        
  for each tt-mov no-lock:

      assign iqtdProd = iqtdProd + 1
             dVlrCDes = dVlrCDes + tt-mov.platot
             dVlrSDes = dVlrSDes + tt-mov.plaori
             dVlrDesc = dVlrDesc + tt-mov.vlrdes.
  
      disp 
           procod  
           pronom  form "x(35)"
           precdes column-label "% Desconto"
           platot  column-label "Vlr C/Desc"
           plaori  column-label "Vlr S/Desc"
           vlrdes  column-label "Vlr Desconto"
           funnom  column-label "Vendedor"     form "x(20)"
           with width 132 centered.
  
  end.

  put skip(1)
      "Qtde Produtos: "  at 001
      iqtdProd           at 017
      "Total"            at 043
      dVlrCDes           at 056
      dVlrSDes           at 069
      dVlrDesc           at 082
      skip.

  output close.

  if opsys = "WIN32"
  then do:
          {mrod_l.i}.
  end.
  if opsys = "UNIX"
  then do:        
          run visurel.p (input varquivo, input ""). 
        
  end.
 
end procedure.