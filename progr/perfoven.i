
find ttvendedor where recid(ttvendedor) =  an-seeid.
p-vencod = ttvendedor.etbcod.


if keyfunction(lastkey) = "CLEAR" /* F8 Impressao */
then do :
    {selimpre.i}.
    varqsai = "../impress/perfoven." + string(time).
    
    {mdadmcab.i
        &Saida     = "value(varqsai)"
        &Page-Size = "60"
        &Cond-Var  = "100"
        &Page-Line = "66"
        &Nom-Rel   = ""PERFOVEN""
        &Nom-Sis   = """SISTEMA COMERCIAL"""
        &Tit-Rel   = """PERFOMANCE DE VENDAS POR VENDEDOR "" +
                      string(vdti) + "" ate "" + string(vdtf) "
        &Width     = "120"
        &Form      = "frame f-cabcab"
    }.

  v-perc     = ttloja.platot * 100 / ttloja.metlj. 
  v-percproj = ttloja.medproj * 100 / ttloja.metlj. 

  disp
    ttloja.nome    format "x(20)" column-label "Estabel." 
    ttloja.cusmed  format "->>>,>>9" column-label "CMV"
    ttloja.margem  column-label "Marg" format "->>9.9"
    ttloja.platot  format "->,>>>,>>9" column-label "Venda"
    ttloja.acfprod format ">>,>>9" column-label "Fin"
    ttloja.metlj   column-label "Meta" format ">,>>>,>>9" 
    v-perc         column-label "%" format ">>9"
    ttloja.medven  column-label "Med.Dia" format ">>,>>9"
    ttloja.medproj column-label "Proj" format ">,>>>,>>9"
    v-percproj     column-label "%" format ">,>>9"
    with frame f-implojas width 120.

  disp "*** V E N D E D O R E S ***" with frame f-cabec down. 

  for each ttVendedor where ttvendedor.etbcod  = p-loja
           break by ttvendedor.platot desc :
    v-perc     = ttvendedor.platot * 100 / ttvendedor.metlj. 
    v-percproj = ttvendedor.medproj * 100 / ttvendedor.metlj. 
    disp
      ttvendedor.nome    format "x(20)" column-label "Vendedor" 
      ttvendedor.cusmed  format "->>>,>>9" column-label "CMV"
      ttvendedor.margem  column-label "Marg" format "->99.9"
      ttvendedor.platot  format "->,>>>,>>9" column-label "Venda"
      ttvendedor.acfprod format ">>,>>9" column-label "Out"
      ttvendedor.metlj   column-label "Meta" format ">,>>>,>>9" 
      v-perc             column-label "%" format ">>9"
      ttvendedor.medven  column-label "DiaM" format ">>,>>9"
      ttvendedor.tktmed  column-label "TktM" format ">,>>9"
      ttvendedor.medproj column-label "Proj" format ">,>>>,>>9"
      v-percproj         column-label "%" format ">>9"
      with frame f-imprvend width 120 down.
  end.
  
    {mdadmrod.i &Saida     = "value(varqsai)"
                &NomRel    = """PERFOVEN"""
                &Page-Size = "60"
                &Width     = "100"
                &Traco     = "65"
                &Form      = "frame f-rod3"}.
                
    run rastfun.p 
        (input sfuncod , input "1" , 
         input "convger" , 
         input string(vdti) , input "relatorio" , input "convloj.ok").
    
    an-seeid = -1.
    next keys-loop.
end.

if keyfunction(lastkey) = "INSERT-MODE"
then do:
find func where func.funcod = ttvendedor.vencod no-lock.
find estab where estab.etbcod = func.etbcod no-lock.
disp
    estab.etbcod label "Estab" colon 30
    estab.etbnom no-label
    ttvendedor.nome format "x(30)" label "Vendedor" colon 30
    ttvendedor.cusmed  format "->>>,>>9.99" label "CMV" colon 30
    ttvendedor.margem label "Margem" format "->99.99%" 
    ttvendedor.platot  format "->,>>>,>>9.99" label "Venda" colon 30
    ttvendedor.acfprod format ">>,>>9.99" label "Outras Receitas" colon 30
    ttvendedor.acfprod + ttvendedor.platot format "->,>>>,>>9.99" label "Total"
            colon 30
            skip(1)
    ttvendedor.metlj  label "Meta" format ">,>>>,>>9.99"  colon 30
    v-perc no-label format ">>9.99%" 
    ttvendedor.medven   label "Media/Dia" format ">>,>>9.99" colon 30
    ttvendedor.tktmed   label "Tkt Medio" format ">,>>9.99" colon 30
    ttvendedor.qtdnota  label "Qtd Notas" format ">,>>9"    colon 30
    ttvendedor.qtditem  label "Qtd Items" format ">>,>>9" colon 30
    ttvendedor.qtditem / ttvendedor.qtdnota label "Media Itens P/Nota" format ">>,>>9"
            colon 30
    skip(1)
    ttvendedor.medproj label "Projecao Mes" format ">,>>>,>>9.99" colon 30
    
    v-percproj label "Da Meta" format ">>9.99%"
    with frame f-lojasside
        width 80
        centered
        row 6
        side-labels
        overlay
        title color normal " Detalhe "
        color messages.
    pause .
                    
    hide frame f-lojasside no-pause.                        
    an-seeid = -1.
    next keys-loop.
end.

