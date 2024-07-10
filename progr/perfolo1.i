
find ttloja where recid(ttloja) =  an-seeid.
p-loja = ttloja.etbcod.
/*************************************
if keyfunction(lastkey) = "CLEAR"

/*or func.etbcod = 0*/
then do :
    /****
    {selimpre.i}.
     ***/
    varqsai = string(estab.etbcod) /*dirrel*/ +  "perfoloj." + string(month(vdti)).
    
    {mdadmcab.i
        &Saida     = "value(varqsai)"
        &Page-Size = "60"
        &Cond-Var  = "136"
        &Page-Line = "66"
        &Nom-Rel   = ""PERFOLOJ""
        &Nom-Sis   = """SISTEMA COMERCIAL"""
        &Tit-Rel   = """ RELATORIO DE VENDAS POR LOJA "" +
                      string(vdti) + "" ate "" + string(vdtf) "
        &Width     = "136"
        &Form      = "frame f-cabcab"
    }.

/***
    for each ttloja  where ttloja.etbcod <> 999  :
        assign  v-totdia = v-totdia + ttloja.cusmed
                v-totger = v-totger + ttloja.platot.
    end.    
****/

    for each ttloja /*** where ttloja.etbcod <> 999 ***/
                          break by ttloja.platot desc :
      /***  
        find bbestab where bbestab.etbcod = ttloja.etbcod no-lock no-error.
          ***/

        assign v-perc = ttloja.platot * 100 / ttloja.metlj
               v-percproj = ttloja.medproj * 100 / ttloja.metlj
/****             v-perdia = ttloja.cusmed * 100 / v-totdia****/.

                   /***/
    disp
    ttloja.nome  
    ttloja.cusmed  
    ttloja.margem 
    ttloja.platot  
    ttloja.acfprod 
    ttloja.metlj   
    v-perc 
    ttloja.medven 
    ttloja.tktmed 
    ttloja.medproj 
    v-percproj column-label "%" 
     with frame f-lojaimp.
        down
            with frame f-lojaimp.
    end.

    /***
    if vetbcod = 0
    then do:
          find ttloja where ttloja.etbcod = 999 no-lock.
          down 1 with frame f-lojaimp.
          disp
              /*ttloja.etbcod */
              "G E R A L" @ ttloja.nome /* bbestab.etbnom */
              ttloja.metlj
              ttloja.cusmed
           /*   "100.00" @ v-perdia  */
              ttloja.platot
           /*   "100.00" @ v-perc      */
              with frame f-lojaimp.
    end.    
    *****/
    
    {mdadmrod.i &Saida     = "value(varqsai)"
                &NomRel    = """PERFOLOJ"""
                &Page-Size = "60"
                &Width     = "136"
                &Traco     = "65"
                &Form      = "frame f-rod3"}.
                
    run rastfun.p 
        (input sfuncod , input "1" , 
         input "convger" , 
         input string(vdti) , input "relatorio" , input "convloj.ok").
    
    an-seeid = -1.
    next keys-loop.
end.
*******************************/

if keyfunction(lastkey) = "INSERT-MODE"
then do:

disp
    ttloja.nome format "x(30)" label "Estabel." colon 30
    ttloja.cusmed  format "->>>,>>9.99" label "CMV" colon 30
    ttloja.margem label "Margem" format "->99.99%" 
    ttloja.platot  format "->,>>>,>>9.99" label "Venda" colon 30
    ttloja.acfprod format ">>,>>9.99" label "Outras Receitas" colon 30
    ttloja.acfprod + ttloja.platot format "->,>>>,>>9.99" label "Total"
            colon 30
            skip(1)
    ttloja.metlj  label "Meta" format ">,>>>,>>9.99"  colon 30
    v-perc no-label format ">>9.99%" 
    ttloja.medven   label "Media/Dia" format ">>>,>>9.99" colon 30
    skip(1)
    ttloja.tktmed   label "Tkt Medio" format ">,>>9.99" colon 30
    ttloja.qtdnota  label "Qtd Notas" format ">,>>9"    colon 30
    ttloja.qtditem  label "Qtd Items" format ">>,>>9" colon 30
    ttloja.qtditem / ttloja.qtdnota label "Media Itens P/Nota" format ">>,>>9"
            colon 30
    skip(1)
    ttloja.medproj label "Projecao Mes" format ">,>>>,>>9.99" colon 30
    
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


     
