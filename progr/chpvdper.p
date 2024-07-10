{admcab.i} 

def var vetbcod  like estab.etbcod.
def var vdatini     as date.
def var vdatfin     as date.
def var vdata-aux   as date. 
def var vetbvenda like estab.etbcod.
def var vplavenda like plani.placod.
def var vetbutil  like plani.etbcod.

def var vqtdven   as int.
def var vqtdabe   as int.
def var vvalabe   as dec.
def var vservenda like plani.serie.

def var varquivo as char.
 
form with frame frame-a.

def temp-table tt-vencar
    field titdtven like titulo.titdtven
    field etbcod like plani.etbcod 
    field numero like plani.numero
    field desti  like plani.dest
    field celular like clien.fax 
    field titnum like titulo.titnum
    field titvlcob like titulo.titvlcob
    field titsit like  titulo.titsit 
    field etbutil like estab.etbcod
    index i1 titdtven etbcod numero.
    
repeat:
    vetbcod = 0.
    vdatini = ?.
    vdatfin = ?.

    for each tt-vencar: delete tt-vencar. end.
    
    update vetbcod label "Estabelecimento"
               help "0(zero) para Todos"
           with frame fopcoes.
    find estab where estab.etbcod = vetbcod no-lock no-error.           
    if vetbcod <> 0 and not avail estab
    then do:
        message "Estabelecimento Invalido".
        undo.
    end.
    update vdatini label "Data Inicial"
           vdatfin label "Data Final"
           with frame fopcoes side-labels.
    if vdatini = ? or vdatfin = ? or (vdatini > vdatfin)           
    then do:
        message "Periodo Invalido".
        undo.
    end.

    vqtdven   = 0.
    vqtdabe   = 0.
    vvalabe   = 0.
    

    do vdata-aux = vdatini to vdatfin:
      for each titulo where titulo.empcod = 19
                      and titulo.titnat = yes
                      and titulo.modcod = "CHP"
                      and titulo.etbcod = 999
                      and titulo.titdtven =  vdata-aux 
                      and titulo.clifor = 110165 
                      and titulo.cxmdata <> vdata-aux
                      no-lock.
      
        vetbvenda = ?.
        vplavenda = ?.
        vservenda = ""    .
        vetbutil = ?.
        release plani.

        vetbvenda = int(acha("ETBCODVENDACHP",titulo.titobs[1])).
        vplavenda = int(acha("PLACODVENDACHP",titulo.titobs[1])).
        vservenda = acha("SERIEVENDACHP",titulo.titobs[1]).
        if vetbvenda = ? or vplavenda = ? then next.
        if vetbcod <> 0 and vetbcod <> vetbvenda then next.
        
        find first plani where plani.etbcod = vetbvenda
                          and plani.placod = vplavenda 
                          and plani.serie = vservenda 
                          no-lock no-error.
                          
          find first clien where clien.clicod = plani.dest no-lock no-error.                                   
        vetbutil = int(acha("ETBCODUTILIZACHP",titulo.titobs[2])).
        
        vqtdven = vqtdven + 1.
        if titulo.titsit = "LIB"
        then assign vqtdabe = vqtdabe + 1
                    vvalabe = vvalabe + titulo.titvlcob.
        
         find first tt-vencar where
                    tt-vencar.titdtven = titulo.titdtven and
                    tt-vencar.etbcod   = plani.etbcod and
                    tt-vencar.titnum   = titulo.titnum
                    no-error.
         if not avail tt-vencar
         then do:     
               
            create tt-vencar.
            assign 
                tt-vencar.titdtven = titulo.titdtven
                tt-vencar.etbcod = plani.etbcod 
                tt-vencar.numero = plani.numero
                tt-vencar.desti  = plani.dest 
                tt-vencar.celular = clien.fax
                tt-vencar.titnum = titulo.titnum
                tt-vencar.titvlcob = titulo.titvlcob
                tt-vencar.titsit = titulo.titsit 
                tt-vencar.etbutil = vetbutil
                .
         end.
      end. 
      end.
      for each titulo where  titulo.empcod = 19
                      and titulo.titnat = yes
                      and titulo.modcod = "CHP"
                      and titulo.etbcod = 999
                      and titulo.clifor = 110165   
                      and titulo.cxmdata >= vdatini
                      and titulo.cxmdata <= vdatfin  
                      no-lock :
               
        vetbvenda = ?.
        vplavenda = ?.
        vservenda = "".
        vetbutil = ?.
        release plani.

        vetbvenda = int(acha("ETBCODVENDACHP",titulo.titobs[1])).
        vplavenda = int(acha("PLACODVENDACHP",titulo.titobs[1])).
        vservenda = acha("SERIEVENDACHP",titulo.titobs[1]).
        
        if vetbvenda = ? or vplavenda = ? then next.
        if vetbcod <> 0 and vetbcod <> vetbvenda then next.
        
        find first plani where plani.etbcod = vetbvenda
                          and plani.placod = vplavenda 
                          and plani.serie = vservenda                                                    no-lock no-error.
                          
         find first clien where clien.clicod = plani.dest no-lock no-error.                  
                  
        vetbutil = int(acha("ETBCODUTILIZACHP",titulo.titobs[2])).
        
        vqtdven = vqtdven + 1.
        if titulo.titsit = "LIB"
        then assign vqtdabe = vqtdabe + 1
                    vvalabe = vvalabe + titulo.titvlcob.
             
        find first tt-vencar where
                    tt-vencar.titdtven = titulo.titdtven and
                    tt-vencar.etbcod   = plani.etbcod and
                    tt-vencar.titnum   = titulo.titnum
                    no-error.
        if not avail tt-vencar
        then do:           
            create tt-vencar.
            assign 
                tt-vencar.titdtven = titulo.cxmdata
                tt-vencar.etbcod = plani.etbcod 
                tt-vencar.numero = plani.numero
                tt-vencar.desti  = plani.dest 
                tt-vencar.celular = clien.fax
                tt-vencar.titnum = titulo.titnum
                tt-vencar.titvlcob = titulo.titvlcob
                tt-vencar.titsit = titulo.titsit 
                tt-vencar.etbutil = vetbutil
                .
        end.            
    end. 
    
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/chpvdper" + string(setbcod) + "."
                    + string(time).     
    else varquivo = "..~\relat~\chpvdper" + string(setbcod) + "."
                    + string(time).
    
    {mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "0"  
                &Cond-Var  = "80" 
                &Page-Line = "66" 
                &Nom-Rel   = ""chpvdper"" 
                &Nom-Sis   = """SISTEMA""" 
                &Tit-Rel   = """CARTAO PRESENTE - VENDAS POR PERIODO "" +
                                  string(vdatini,""99/99/9999"") + "" a "" +
                                  string(vdatfin,""99/99/9999"") + "" - ESTAB:""
                                  + string(vetbcod) " 
                &Width     = "80"
                &Form      = "frame f-cabcab"}    

    vqtdven   = 0.
    vqtdabe   = 0.
    vvalabe   = 0.
     for each tt-vencar:
        disp tt-vencar.titdtven   column-label "Dt.Venda do!C.Presente"
             tt-vencar.etbcod when tt-vencar.etbcod > 0 
                    column-label "Filial de!Venda"
             tt-vencar.numero   column-label "Nota Fiscal!de Venda" 
                          format ">>>>>>9"
             tt-vencar.desti column-label  "Cliente" format ">>>>>>>>>>>9"
             tt-vencar.celular column-label "Celular" format "x(15)"
             tt-vencar.titnum                 column-label "Cartao!Presente"
             tt-vencar.titvlcob               column-label "Valor"
             tt-vencar.titsit                 column-label "Sit"
             tt-vencar.etbutil when tt-vencar.etbutil <> ? 
                        column-label "Filial!Utilizacao"
             with frame frame-a 10 down centered color white/red row 5 width 200.
        down with frame frame-a.
     end.
     
     disp skip(3)
         vqtdven label "Quantidade Cartoes Vendidos no Periodo" 
         skip
         vqtdabe label "Quantidade de Cartoes em Aberto......."
         skip
         vvalabe label "Valor em Aberto......................."
         with frame f-tot side-labels.
    
    output close.

    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}
    end.    
end. /* repeat */
    
