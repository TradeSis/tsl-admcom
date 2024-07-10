{admcab.i}

def var vdti      as date no-undo.
def var vdtf      as date no-undo.
def var vtipo     as char no-undo.
def var varquivo  as char no-undo.

def temp-table tt-pedido 
    field pednum    as integer
    field clicod    as integer
    field clinom    as char
    field peddat    as date
    field val-ped   as decimal
    field tipo      as char
    field qtd-parc  as integer
    field procod    as integer
    field pronom    as char
    field lipqtd    as integer
    field prc-item  as decimal
    index idx01 pednum peddat.

form
    vdti label "Periodo" format "99/99/9999"
    "a"
    vdtf    no-label     format "99/99/9999" skip
    vtipo label "Filtro " format "x(1)"
   help " Escolha um filtro: A=Ambos  B=Boletos  C=Cartoes de Credito "
            with frame f-dat centered color blue/cyan row 4
                           title " Periodo " side-labels  .

assign vdti = today - 15
       vdtf = today
       vtipo = "A". 

update vdti 
       vdtf
        with frame f-dat.
       
do on error undo:         
    update vtipo
            with frame f-dat.
    
    if vtipo <> "A"
        and vtipo <> "B"
        and vtipo <> "C"                                
    then do:
    
       message "Filtro inválido!!" skip(1)
               "Escolha uma opcao: A=Ambos  B=Boletos  C=Cartoes de Credito"
               view-as alert-box.   
    
       undo, retry.

    end.
    
end.

for each pedid where pedid.etbcod = 200
                 and pedid.pedtdc = 3 
                 and pedid.peddat >= vdti
                 and pedid.peddat <= vdtf
                 and pedid.sitped = "F" no-lock,
                 
    first pedecom of pedid no-lock,
    
    first clien where clien.clicod = pedid.clfcod no-lock,
    
    each liped of pedid no-lock,
    
    first produ of liped no-lock.          
    
    if vtipo = "B" and pedecom.formapagto <> "Boleto"
    then next.
    else if vtipo = "C" and pedecom.formapagto = "Boleto"
    then next.
                  
                  
    create tt-pedido.
    assign tt-pedido.pednum   = pedid.pednum 
           tt-pedido.clicod   = clien.clicod
           tt-pedido.clinom   = clien.clinom
           tt-pedido.peddat   = pedid.peddat
           tt-pedido.val-ped  = pedecom.valor
           tt-pedido.tipo     = pedecom.formapagto
           tt-pedido.qtd-parc = pedecom.qtdparcelas
           tt-pedido.procod   = produ.procod
           tt-pedido.pronom   = produ.pronom
           tt-pedido.lipqtd   = liped.lipqtd
           tt-pedido.prc-item = liped.lippreco.
                    
end.                    

if opsys = "UNIX"
then varquivo = "/admcom/relat/lista_vendas_ecom_" + string(time).
else varquivo = "l:\relat\lista_vendas_ecom_" + string(time).
                                         /*
output to value(varquivo).
                                           */
{mdad.i
      &Saida     = "value(varquivo)"
      &Page-Size = "64"
      &Cond-Var  = "120"
      &Page-Line = "64"
      &Nom-Rel   = ""relat_vendas_ecom.p""
      &Nom-Sis   = """SISTEMA GERENCIAL"""
      &Tit-Rel   = """VENDAS NO E-COMMERCE DE "" +
                             string(vdti,""99/99/9999"") + "" ATE "" +
                             string(vdtf,""99/99/9999"") "
      &Width     = "132"
      &Form      = "frame f-cabcab"}


display "PEDIDO"         at 02
        "CLIENTE"        at 18
        "DATA"           at 50
        "PAGTO"          at 59
        "PARC"           at 65
        "VAL.PEDIDO"     at 71
        "COD"            at 85
        "PRODUTO"        at 94
        "QTD"            at 120
        "VAL.UNIT"       at 125
         skip
                with frame f01 width 136 down.

for each tt-pedido no-lock break by tt-pedido.pednum
                                 by tt-pedido.peddat: 
    
    if first-of(tt-pedido.pednum)
    then
    put tt-pedido.pednum format ">>>>>9"             at 01
            tt-pedido.clicod format ">>>>>>>>>9"     at 10
          /*  "-"  */
            ""
            tt-pedido.clinom   format "x(25)"       
            tt-pedido.peddat   format "99/99/9999"   at 48
            tt-pedido.tipo     format "x(6)"         at 59
            tt-pedido.qtd-parc format ">9"           at 67
            tt-pedido.val-ped                        at 71  
         /* fill("-",50)       format "x(50)"   at 50  */        
            /*with frame f02 width 136 down*/.
                                                          
                                 
    put tt-pedido.procod   format ">>>>>9"       at 83
            tt-pedido.pronom   format "x(28)"     at 90
            tt-pedido.lipqtd   format ">>9"     at 120
            tt-pedido.prc-item  format ">>>,>>>.99"     at 123
                                         .
    
    if last-of(tt-pedido.pednum)
    then put skip(1).
              
                                 
end.                                
output close.
    
if opsys = "UNIX"
then do:

    message "Arquivo gerado: " varquivo. pause 0.
               
    run visurel.p (input varquivo, input "").
                        
end.
else do:
    {mrod.i}
end.
                                            
