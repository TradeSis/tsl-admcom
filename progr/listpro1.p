{admcab.i new}

define variable vcatcod           as integer no-undo.
define variable vforcod           as integer no-undo.
define variable vetbcod           as integer no-undo.
define variable vcla-cod          as integer no-undo.
define variable vlog-so-promocao  as logical format "Sim/Nao"  no-undo.
define variable vcha-forne-label  as character no-undo.
define variable vcha-clase-label  as character no-undo.
define variable vcha-filial-label as character no-undo.
define variable varquivo          as character no-undo.  
define variable vint-cont         as integer   no-undo.


form
    vcatcod           label "Departamento"  format ">>9"    at 05
    categoria.catnom  no-label              format "x(10)"  at 23   
    vforcod           label "Fornecedor"    format ">>>9"   at 05  
    vcha-forne-label  no-label              format "x(20)"  at 23
    vetbcod           label "Filial"                        at 05
    vcha-filial-label no-label             format "x(20)"   at 23
    vcla-cod          label "Classe"                        at 05
    vcha-clase-label  no-label              format "x(20)"  at 23
    vlog-so-promocao  label "Somente Promocao?"             at 50
        with frame f01 side-labels.

form
    "              *** Gerando Relatorio ***  " skip(2)
    produ.pronom label "Produto"  at 05
        with frame f02 side-labels centered overlay.

define temp-table tt-produto no-undo
    field procod        like produ.procod
    field clacod        like produ.clacod
    field clanom        like clase.clanom
    field pronom        like produ.pronom
    field preco-venda   like estoq.estvenda
    field preco-prom    like estoq.estproper
    field valid-prom    as date
    field vlog-ecom     as logical format "Sim/Nao"
    field vlog-ativo    as logical format "Sim/Nao"
     index idx01 clacod procod.

update vcatcod            with frame f01.

find categoria where categoria.catcod = vcatcod no-lock no-error.
display categoria.catnom no-label with frame f01.

bloco_forne:
repeat:
    update vforcod            with frame f01.

    if vforcod = 0
    then do:
        assign vcha-forne-label = "Todos".
    end.
    
    find first fabri where fabri.fabcod = vforcod no-lock no-error.
    if avail fabri
    then do:
        assign vcha-forne-label = fabri.fabnom.
    end.    
    else do:
    
         message "Fornecedor invalido.".
         undo, retry.
    end.
    
    display vcha-forne-label with frame f01.
    leave bloco_forne.
    
end.

if keyfunction(lastkey) = "end-error"
then undo, retry.

update vetbcod            with frame f01.
if vetbcod = 0
then assign vcha-filial-label = "TODAS AS FILIAIS".
display vcha-filial-label  with frame f01.

bloco_clase: 
repeat: 
    update vcla-cod           with frame f01.

    if vcla-cod = 0
    then assign vcha-clase-label = "TODAS AS CLASSES".
    else do:                                        
         find first clase where clase.clasup = vcla-cod no-lock no-error.
         if avail clase
         then assign vcha-clase-label = clase.clanom.
         else do:
         
              message "Classe invalida.".
              undo, retry.

         end.
    end.            
    
    display vcha-clase-label with frame f01.
    leave bloco_clase.
    
end.                         
                                                                                                    
                    

update vlog-so-promocao   with frame f01.

if vetbcod = 0
then assign vetbcod = 900.

for each produ where produ.procod > 0 no-lock,

    first estoq where estoq.procod = produ.procod
                  and estoq.etbcod = vetbcod  no-lock,
    
    first fabri where fabri.fabcod = produ.fabcod no-lock,

    first clase where clase.clacod = produ.clacod no-lock:
    
    if vcla-cod > 0 and vcla-cod <> clase.clacod
    then next.
    
    if vforcod > 0 and vforcod <> produ.fabcod
    then next.
    
    if vcatcod > 0 and vcatcod <> produ.catcod
    then next.
    
    if vlog-so-promocao
    then do:
     
        if estoq.estprodat = ?
        then next.
        
        if estoq.estprodat <= today
            or estoq.estbaldat >= today
        then next.    
     
    end. 
     
    display produ.pronom with frame  f02.

    run p-carrega-tt-produto.

end.

if opsys = "UNIX"
then varquivo = "/admcom/relat/listpro." + string(time).
else varquivo = "l:~\relat~\listpro." + string(time).
            
{mdad.i &Saida = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "130"
        &Page-Line = "66"
        &Nom-Rel   = ""listpro2""
        &Nom-Sis   = """SISTEMA GERENCIAL"""
        &Tit-Rel   = """LISTAGEM DE PRODUTOS"""
        &Width     = "130"
        &Form      = "frame f-cabcab1"}

for each tt-produto no-lock by tt-produto.clacod
                            by tt-produto.procod:
                          
    display tt-produto.clacod      column-label "Classe"  format ">>>>>9"
            tt-produto.clanom      column-label "Nome"    format "x(19)"
            tt-produto.procod      column-label "Produto" format ">>>>>>>9"
            tt-produto.pronom      column-label "Nome"    format "x(45)"
            tt-produto.preco-venda column-label "Preco Venda"
                                                    format ">>>,>>9.99"
            tt-produto.preco-prom  column-label "Preco Prom"
                                                    format ">>,>>9.99"
            tt-produto.valid-prom  column-label "Valid.Prom."
                                                    format "99/99/9999"
            tt-produto.vlog-ecom   column-label "E-Com"
            tt-produto.vlog-ativo  column-label "Ativo"
                    with frame f-03 down width 130.
            
            down with frame f-03.
     
end.                          

output close.
if opsys = "UNIX"
then do:
    run visurel.p(varquivo,"").
end.
else do:
    {mrod.i}
end.

procedure p-carrega-tt-produto:

    create tt-produto.
    assign tt-produto.procod      = produ.procod
           tt-produto.clacod      = produ.clacod
           tt-produto.clanom      = clase.clanom
           tt-produto.pronom      = produ.pronom
           tt-produto.preco-venda = estoq.estvenda
           tt-produto.preco-prom  = estoq.estproper
           tt-produto.valid-prom  = estoq.estprodat.
    
    release produaux.
    find first produaux where produaux.procod = produ.procod
                          and produaux.nome_campo = "exporta-e-com"
                                                              no-lock no-error.
    if avail produaux and ProduAux.Valor_Campo = "yes"       
    then assign tt-produto.vlog-ecom = Yes.
    else assign tt-produto.vlog-ecom = No.
    
    if produ.proseq = 99
    then tt-produto.vlog-ativo = No.
    else tt-produto.vlog-ativo = Yes.
    
end procedure.