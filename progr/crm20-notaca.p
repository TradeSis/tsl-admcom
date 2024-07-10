{admcab.i}

def var d-datai    like plani.pladat.
def var d-dataf    like plani.pladat.
def var i-acaocod  like acao.acaocod.
def var c-contenz  as char form "x(08)" init "".
def var c-contenx  as char form "x(08)" init "".
def var m-totvend  like plani.platot.
def var m-totclie  like plani.platot.
def var m-totsele  like plani.platot.
def var m-totslcl  like plani.platot.
def var m-totdesc  like plani.platot. 
def var i-retorno  as inte.
def var w-rowid    as rowid.
def var c-clinom   as char form "x(35)".
def var l-confirma as logi init no.
def var c-mensagem as char form "x(40)". 
 
def buffer bf-movim for movim.

assign d-datai   = today - 30
       d-dataf   = today
       i-acaocod = 0
       c-contenz = "NEW"
       c-contenx = "FREE"
       m-totvend = 0
       m-totclie = 0
       m-totsele = 0
       m-totslcl = 0
       m-totdesc = 0
       i-retorno = 0.


repeat:

assign c-contenz = "NEW"
       c-contenx = "FREE"
       m-totvend = 0
       m-totclie = 0
       m-totsele = 0
       m-totslcl = 0
       m-totdesc = 0
       i-retorno = 0.

    update d-datai   label "Data"   form "99/99/9999"  at 001
           d-dataf   label "Final"  form "99/99/9999"  at 018 
           i-acaocod label "Acao"                      at 036
           c-contenz label "Contem"                    at 050
           c-contenx label "Ou"                        at 067
           with frame f-acao side-labels 1 down width 80
                title "RESUMO DE NOTAS DA ACAO".

    for each acao-cli where
             acao-cli.acaocod = i-acaocod no-lock,
        each plani where plani.movtdc  = 5
                     and plani.desti   = acao-cli.clicod
                     and plani.pladat >= d-datai
                     and plani.pladat <= d-dataf
                     no-lock break by acao-cli.clicod:
    
        assign w-rowid = rowid(acao-cli).
                  
    end.                  

    for each acao-cli where 
             acao-cli.acaocod = i-acaocod no-lock,
        each plani where plani.movtdc  = 5 
                     and plani.desti   = acao-cli.clicod 
                     and plani.pladat >= d-datai 
                     and plani.pladat <= d-dataf
                     no-lock break by plani.desti
                                   by acao-cli.clicod:

        find first clien where
                   clien.clicod = acao-cli.clicod no-lock no-error.
        if avail clien
        then assign c-clinom = substring(clien.clinom,1,35).
        else assign c-clinom = "".           
               
        disp c-clinom        form "x(16)" column-label "Nome"
             plani.DescProd 
             plani.EtbCod 
             plani.Numero 
             plani.plades 
             plani.PLaTot 
             plani.ProTot 
             with frame f-disp width 80 1 down.

        for each movim where
                 movim.etbcod = plani.etbcod and
                 movim.placod = plani.placod no-lock:
    
            disp movim.MovDes       form ">,>>9.99"
                 movim.movpc        form ">,>>9.99"
                 movim.MovPDesc     form ">>9.99"
                 movim.movqtm       form ">>9.99"  column-label "Qtde" 
                 movim.procod
                 with frame f-lin  width 80 5 down.
             
            find first produ where
                       produ.procod = movim.procod no-lock no-error.
            if avail produ
            then disp produ.pronom   form "x(30)"
                      with frame f-lin.  
          
            if produ.pronom  matches("*" + trim(c-contenz) + "*") or
               produ.pronom  matches("*" + trim(c-contenx) + "*")
            then do:
                    disp "*" with frame f-lin.
                    assign m-totsele = m-totsele + movim.movpc * movim.movqtm.
                           m-totslcl = m-totslcl + movim.movpc * movim.movqtm.

                   if first(acao-cli.clicod)
                   then assign i-retorno = i-retorno + 1.

                end.
                
                assign m-totvend = m-totvend + movim.movpc * movim.movqtm
                       m-totclie = m-totclie + movim.movpc * movim.movqtm.
                
        end.

    
        disp 
             "Total Cliente....: "                 no-label
             m-totclie        form ">,>>9.99"      no-label
             " Selecao Cliente.: "                 no-label
             m-totslcl        form ">,>>9.99"      no-label
             " = Retorno"
             skip
             "Total Venda......: "                 no-label
             m-totvend        form ">,>>9.99"      no-label
             " Total Selecao...: "                 no-label
             m-totsele        form ">,>>9.99"      no-label
             " = Retorno"
             with frame f-tot width 80 side-label 1 down no-box.

        if first-of(acao-cli.clicod)
        then do:
                 assign c-mensagem = "".
                 assign c-mensagem = "<segue>". 
                 disp c-mensagem  no-label 
                      with side-labels at row 22 col 78 no-box.
        end.

        if last-of(acao-cli.clicod)
        then do:
                 assign c-mensagem = "".
                 assign m-totclie  = 0
                        m-totslcl  = 0
                        c-mensagem = "<Final cliente>".
                 disp c-mensagem  no-label 
                      with side-labels at row 22 col 67 no-box.
                 
        end.
  
        if w-rowid = rowid(acao-cli)
        then do:
                 assign c-mensagem = "".  
                 assign c-mensagem = "<Final do Resumo>".
                        
                 disp c-mensagem no-label 
                      with side-labels at row 22 col 64 no-box.
        end.
        
    end.
end.
hide frame f-disp.     
hide frame f-tot.
hide frame f-lin.
hide frame f-acao.         

