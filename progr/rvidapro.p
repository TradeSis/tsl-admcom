{admcab.i}

def var vint-fil-ini   as integer.
def var vint-fil-fim   as integer.

def var vperc-menor    as decimal.
def var vperc-maior    as decimal.

def var vperiodo-ini   as integer.
def var vperiodo-fim   as integer.

def var vdti           as date.
def var vdtf           as date.

def var vcla-cod         as integer.

def var varquivo        as character.

def buffer bclase for clase.
def buffer cclase for clase.
def buffer dclase for clase.
def buffer eclase for clase.


def temp-table tt-produ no-undo
    field procod as integer format ">>>>>>>>>>>9"
    field pronom   as character format "x(40)"
    field qtdcomp  as integer
    field qtdvend  as integer
    field perc     as decimal
    field faixa  as logical
    index idx01 procod.

def temp-table tt-classe no-undo
    field clacod like clase.clacod.
    

form
    vint-fil-ini format ">>>" label "Filial" 
    " a "
    vint-fil-fim format ">>>" no-label skip(1)
    vperc-menor format ">>>9.99%"  label "Faixa de percentual de venda"
    " a "
    vperc-maior format ">>>>9.99%" no-label skip(1)
    vperiodo-ini format ">>>>"    label "Periodo"
    " a "
    vperiodo-fim format ">>>>"    no-label skip(1)
    vcla-cod format ">>>>>>"      label "Classe " 
      with frame f-01 side-label centered row 5 title " Relatório Ciclo de Vida do Produto ".



bloco_filial:
do on error undo,retry:
    update vint-fil-ini
           vint-fil-fim
              with frame f-01.
           
    if vint-fil-ini > vint-fil-fim or vint-fil-ini = 0 or vint-fil-fim = 0
    then do:
        
        message "A Filhal inicial precisa ser menor que a final.".
        undo,retry.
            
    end.
    
    update vperc-menor
           vperc-maior     
           vperiodo-ini
           vperiodo-fim
              with frame f-01.
            
    
    if vperiodo-ini < vperiodo-fim or vperiodo-ini = 0 or vperiodo-fim = 0
    then do:
    
        message "O Período inicial precisa ser anterior ao período final.".
        undo,retry.
    
    end.
    
    update vcla-cod
              with frame f-01.
            
    
    if vcla-cod = 0 or not can-find(first clase where clase.clacod = vcla-cod)
    then do:
    
        message "Classe inválida, pressione F7 para pesquisar.".
        undo,retry.
    
    end.
    
    leave bloco_filial.
        
end.

find clase where clase.clacod = vcla-cod no-lock.
disp clase.clanom no-label with frame f-01.
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
        

assign vdti = today - vperiodo-ini
       vdtf = today - vperiodo-fim.
     
message "Gerando relatório... Por favor aguarde...".

for each estab where estab.etbcod >= 900 no-lock,

    each plani where plani.etbcod  = estab.etbcod
                 and plani.pladat >= 01/01/1980
                 and plani.pladat <= 12/31/2050
                 and plani.movtdc = 4 /* Compras */
                          no-lock,

    each movim where movim.etbcod = plani.etbcod
                 and movim.placod = plani.placod
                          no-lock,
                          
    first produ where produ.procod = movim.procod
                  and can-find(first tt-classe
                               where tt-classe.clacod = produ.clacod)   
                          no-lock:
    
    release tt-produ.                      
    find first tt-produ where tt-produ.procod = produ.procod
                            exclusive-lock no-error.                      
                            
    if not avail tt-produ
    then do:
        
        create tt-produ.
        assign tt-produ.procod = produ.procod
               tt-produ.pronom = produ.pronom.                       
                            
    end.
                            
    assign tt-produ.qtdcomp = tt-produ.qtdcomp + movim.movqtm.
                          
end.                          

for each tt-produ exclusive-lock,

    each movim where movim.etbcod >= vint-fil-ini
                 and movim.etbcod <= vint-fil-fim
                 and movim.movtdc = 5
                 and movim.movdat >= vdti
                 and movim.movdat <= vdtf   
                 and movim.procod = tt-produ.procod no-lock:
                          
    assign tt-produ.qtdvend = tt-produ.qtdvend + movim.movqtm.
                          
end.                          

for each tt-produ exclusive-lock:

  /* precisa descartar venda menor q 2 */
  if tt-produ.qtdvend < 2
  then delete tt-produ.
  else do:
      assign tt-produ.perc =
            round(((tt-produ.qtdvend * 100) / tt-produ.qtdcomp),2).

      if tt-produ.perc >= vperc-menor
          and tt-produ.perc <= vperc-maior
      then assign tt-produ.faixa = yes.
      else assign tt-produ.faixa = no.
  end.  
  
end.

run p-display.

procedure p-display:
    
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/rvidapro." + string(time).
    else varquivo = "l:\relat\rvidapro." + string(time).
                
    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "0"
        &Cond-Var  = "110"
        &Page-Line = "0"
        &Nom-Rel   = ""rvidapro""
        &Nom-Sis   = """SISTEMA DE COMPRAS"""
        &Tit-Rel   = """Ciclo de Vida dos Produtos"""
        &Width     = "110"
        &Form      = "frame f-cabcab"}

    display
"===========================================================================================" skip
    "=================== Produtos na faixa de " vperc-menor no-label
    "% a " vperc-maior no-label "% ====================" skip
"===========================================================================================" skip
    with frame f-00 width 160.            
    
    for each tt-produ where tt-produ.faixa
                                no-lock break by tt-produ.perc desc:
                                
        display
          tt-produ.procod                       column-label "Cod"
          tt-produ.pronom                       column-label "Produto"
          tt-produ.qtdcomp                      column-label "Qtd Compras"
          tt-produ.qtdvend                      column-label "Qtd Vendas"
          tt-produ.perc    format ">>>,>>9.99%" column-label "Percent. Venda"
                  with frame f-02  width 160 down.
    
    end.
    
        display
"===========================================================================================" skip
"=================================  Outras faixas ==========================================" skip
"===========================================================================================" skip
    with frame f-04 width 160.            
                                       
    for each tt-produ where not tt-produ.faixa 
                                no-lock break by tt-produ.perc desc:

        display
          tt-produ.procod                       column-label "Cod"
          tt-produ.pronom                       column-label "Produto"
          tt-produ.qtdcomp                      column-label "Qtd Compras"
          tt-produ.qtdvend                      column-label "Qtd Vendas"
          tt-produ.perc    format ">>>,>>9.99%" column-label "Percent. Venda"
                  with frame f-03  width 160 down.
    
    end.

    output close.
    
    if opsys = "UNIX"
    then run visurel.p (input varquivo, input "").
    else do:
       {mrod.i}.
    end.

    message "Arquivo gerado com sucesso em: " varquivo.                        
    
end procedure.                            
