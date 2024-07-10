

if keyfunction(lastkey) = "CLEAR" /* F8 Impressao */
then do :
/***********************    
    {selimpre.i}.
    varqsai = "../impress/perfopro." + string(estab.etbcod).
    
    {mdadmcab.i
        &Saida     = "value(varqsai)"
        &Page-Size = "60"
        &Cond-Var  = "100"
        &Page-Line = "66"
        &Nom-Rel   = ""PERFOPRO""
        &Nom-Sis   = """SISTEMA COMERCIAL"""
        &Tit-Rel   = """ PERFORMANCE DE VENDAS POR PRODUTO "" +
                      string(vdti) + "" ate "" + string(vdtf) "
        &Width     = "120"
        &Form      = "frame f-cabcab"
    }.

    {mdadmrod.i &Saida     = "value(varqsai)"
                &NomRel    = """PERFOPRO"""
                &Page-Size = "60"
                &Width     = "100"
                &Traco     = "65"
                &Form      = "frame f-rod3"}.

                
  assign v-perc = ttsetor.platot * 100 / ttsetor.metlj. 
  assign v-percproj = ttsetor.medproj * 100 / ttsetor.metlj. 
                
  display ttsetor.platot 
                         ttsetor.nome 
                         ttsetor.metlj 
                         ttsetor.cusmed  
                         v-perc 
                         ttsetor.margem 
                         ttsetor.medven 
                         ttsetor.medproj 
                         ttsetor.acfprod  
                         v-percproj 
                         with frame f-imprsetor.
             
                
    run rastfun.p 
        (input sfuncod , input "1" , 
         input "convger" , 
         input string(vdti) , input "relatorio" , input "convloj.ok").
    
    an-seeid = -1.
    next keys-loop.
*********************/
end.