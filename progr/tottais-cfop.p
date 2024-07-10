{admcab.i}   

def temp-table tt-uf
    field ufecod  like forne.ufecod
    field uftotal like plani.platot format ">>,>>>,>>9.99".
    
def var v-an as char format "x(15)" extent 2
    init["  SINTETICO","  ANALITICO"].

def var varquivo as char.
def var vali like fiscal.alicms.
def var vemi like fiscal.plaemi.
def var vrec like fiscal.plarec.
def var vopf like fiscal.opfcod.

 def var tot-pla like fiscal.platot format "->>,>>>,>>9.99".
 def var tot-bic like fiscal.platot format "->>,>>>,>>9.99".
 def var tot-icm like fiscal.platot format "->>,>>>,>>9.99".
 def var tot-ipi like fiscal.platot format "->>,>>>,>>9.99". 
 def var tot-out like fiscal.platot format "->>,>>>,>>9.99".
 

def temp-table tt-op
    field desti  like estab.etbcod
    field ali    like fiscal.alicms 
    field opfcod like fiscal.opfcod 
    field totpla like fiscal.platot format ">>>,>>>,>>9.99"
    field totbic like fiscal.bicms  format ">>>,>>>,>>9.99"
    field toticm like fiscal.icms   format ">>>,>>>,>>9.99"
    field totipi like fiscal.ipi    format ">>>,>>>,>>9.99"
    field totout like fiscal.out    format ">>>,>>>,>>9.99".

def temp-table tt-nf
    field emite  like plani.emite 
    field desti  like plani.desti
    field serie  like plani.serie
    field numero like plani.numero
    field ali    like fiscal.alicms 
    field opfcod like fiscal.opfcod 
    field totpla like fiscal.platot format ">>>,>>>,>>9.99"
    field totbic like fiscal.bicms  format ">>>,>>>,>>9.99"
    field toticm like fiscal.icms   format ">>>,>>>,>>9.99"
    field totipi like fiscal.ipi    format ">>>,>>>,>>9.99"
    field totout like fiscal.out    format ">>>,>>>,>>9.99"
    field chave  as char format "x(44)"
    index i1 opfcod emite serie numero.

def var vnumero like fiscal.numero.
def var vforcod like forne.forcod.
def var totpla like plani.platot. 
def var totbic like plani.platot.
def var toticm like plani.platot.
def var totipi like plani.platot.
def var totout like plani.platot.
    
def var valicms like movim.movalicms.
def var vopfcod like plani.opccod.
def var vcfop as int.

def var vetbcod like estab.etbcod.
def var vdti like plani.pladat.
def var vdtf like plani.pladat.
def var vmovtdc like tipmov.movtdc.
def var vdesti like plani.desti.

repeat:

    for each tt-op:
        delete tt-op.
    end.    
    
    update vetbcod label "Filial" colon 15
            with frame f1 side-label width 80.
    if vetbcod = 0
    then display "GERAL" @ estab.etbnom no-label with frame f1.
    else do:
        find estab where estab.etbcod = vetbcod no-lock no-error.
        display estab.etbnom no-label with frame f1.
    end.
                
                
    update vdti label "Data Inicial" colon 15
           vdtf label "Data Final" 
                with frame f1 side-label width 80.
                
    def var vindex as int.            
    disp v-an with frame f-an 1 down centered no-label.
    choose field v-an with frame f-an.
    vindex = frame-index.

    for each estab where if vetbcod = 0
                         then true
                         else estab.etbcod = vetbcod no-lock:  
        disp estab.etbcod label "Processando filial"
        with frame f-reg 1 down side-label.
        pause 0.
        for each tipmov where not tipmov.tipemite
            or can-find (first tipmovaux where
                            tipmovaux.movtdc = tipmov.movtdc and
                            tipmovaux.nome_campo = "PROGRAMA-NF" AND
                            tipmovaux.valor_campo = "nfentall")
                no-lock :
        for each plani where
                 plani.movtdc = tipmov.movtdc and
                 (plani.desti = estab.etbcod or
                    (plani.movtdc = 4 and plani.emite = estab.etbcod)) and
                 plani.dtinclu >= vdti and
                 plani.dtinclu <= vdtf
                 no-lock:
            if plani.movtdc = 12 and
               plani.serie = "U"
            then next.
            vdesti = plani.desti.
            if plani.movtdc = 4 and
               plani.desti <> estab.etbcod
            then vdesti = plani.emite.   
            vopfcod = plani.hiccod.
            find first movim where
                       movim.etbcod = plani.etbcod and
                       movim.placod = plani.placod and
                       movim.movtdc = plani.movtdc /*and
                       movim.movdat = plani.pladat */
                       no-lock no-error.
            if avail movim
            then           
            for each movim where movim.etbcod = plani.etbcod and
                                 movim.placod = plani.placod and
                                 movim.movtdc = plani.movtdc and
                                 movim.movdat = plani.pladat /*and
                                 movim.opfcod = 3102*/
                                 no-lock:
                
                if movim.movtdc = 12 and
                   plani.horincl <> movim.movhr
                then next.
                vopfcod = plani.hiccod.            
                if movim.opfcod > 0
                then vopfcod = movim.opfcod.             
                         
                if vopfcod = 0 then next.
                if plani.serie = "TR" then next.
                
                find first tt-op where tt-op.desti  = vdesti  and
                                   tt-op.ali    = movim.movalicms and
                                   tt-op.opfcod = vopfcod no-error.
                if not avail tt-op
                then do:
                    create tt-op.
                    assign tt-op.desti  = vdesti
                       tt-op.ali    = movim.movalicms
                       tt-op.opfcod = vopfcod.
                end.
                assign tt-op.totpla = tt-op.totpla + 
                        (movim.movpc * movim.movqtm) 
                       tt-op.totbic = tt-op.totbic + movim.movbicms 
                       tt-op.toticm = tt-op.toticm + movim.movicms. 
                find first tt-op where tt-op.desti  = 0  and
                                   tt-op.ali    = movim.movalicms and
                                   tt-op.opfcod = vopfcod no-error.
                if not avail tt-op
                then do:
                    create tt-op.
                    assign tt-op.desti  = 0
                       tt-op.ali    = movim.movalicms
                       tt-op.opfcod = vopfcod.
                end.
                assign tt-op.totpla = tt-op.totpla + 
                        (movim.movpc * movim.movqtm) 
                       tt-op.totbic = tt-op.totbic + movim.movbicms 
                       tt-op.toticm = tt-op.toticm + movim.movicms. 
            end.
            else do:
                find first tt-op where tt-op.desti  = vdesti  and
                                   tt-op.ali    = 0 and
                                   tt-op.opfcod = vopfcod no-error.
                if not avail tt-op
                then do:
                    create tt-op.
                    assign tt-op.desti  = vdesti
                       tt-op.ali    = 0
                       tt-op.opfcod = vopfcod.
                end.
                assign tt-op.totpla = tt-op.totpla + plani.platot
                       tt-op.totbic = tt-op.totbic + plani.bicms 
                       tt-op.toticm = tt-op.toticm + plani.icms. 
                find first tt-op where tt-op.desti  = 0  and
                                   tt-op.ali    = 0 and
                                   tt-op.opfcod = vopfcod no-error.
                if not avail tt-op
                then do:
                    create tt-op.
                    assign tt-op.desti  = 0
                       tt-op.ali    = 0
                       tt-op.opfcod = vopfcod.
                end.
                assign tt-op.totpla = tt-op.totpla + plani.platot 
                       tt-op.totbic = tt-op.totbic + plani.bicms 
                       tt-op.toticm = tt-op.toticm + plani.icms. 
 
            end.
            find first tt-nf where
                       tt-nf.opfcod = vopfcod and
                       tt-nf.emite  = plani.emite  and
                       tt-nf.desti  = vdesti  and
                       tt-nf.serie  = plani.serie  and
                       tt-nf.numero = plani.numero
                       no-error.
            if not avail tt-nf
            then do:
                create tt-nf.
                assign
                    tt-nf.opfcod = vopfcod
                    tt-nf.emite  = plani.emite
                    tt-nf.desti  = vdesti
                    tt-nf.serie  = plani.serie
                    tt-nf.numero = plani.numero
                    .
            end.
            assign
                /*tt-nf.ali    = fiscal.alicms*/
                tt-nf.totpla = tt-nf.totpla + plani.platot 
                tt-nf.totbic = tt-nf.totbic + plani.bicms 
                tt-nf.toticm = tt-nf.toticm + plani.icms 
                tt-nf.totipi = tt-nf.totipi + plani.ipi 
                tt-nf.totout = tt-nf.totout + plani.outras
                .
    
            find a01_infnfe where 
                 a01_infnfe.emite = plani.emite and
                 a01_infnfe.serie = plani.serie and
                 a01_infnfe.numero = plani.numero
                 no-lock no-error.
            if avail a01_infnfe
            then tt-nf.chave = a01_infnfe.id.     
            else do:
                /*
                find plani where plani.etbcod = plani.etbcod and
                                 plani.emite  = plani.emite and
                                 plani.desti = vdesti and
                                 plani.numero = plani.numero and
                                 plani.serie = plani.serie
                                 no-lock no-error.
                if avail plani
                then*/ tt-nf.chave = plani.ufdes.
            end. 
        end.
        end.           
        for each tipmov where tipmov.tipemite
                        no-lock,
            each plani where plani.movtdc = tipmov.movtdc and
                         plani.etbcod = estab.etbcod and
                         /*plani.desti = estab.etbcod and*/
                         plani.emite = estab.etbcod and
                         plani.pladat >= vdti and
                         plani.pladat <= vdtf and
                         plani.modcod <> "CAN"
                         no-lock:

            vopfcod = plani.hiccod.
            for each movim where
                     movim.etbcod = plani.etbcod and
                     movim.placod = plani.placod and
                     movim.movtdc = plani.movtdc and
                     movim.movdat = plani.pladat
                     no-lock,
                first produ where produ.procod = movim.procod no-lock:
                if produ.proipiper = 98 then next.
                if produ.pronom matches "*RECARGA*"
                then next.
                vopfcod = plani.hiccod.
                if movim.opfcod > 0
                then vopfcod = movim.opfcod.
                
                if vopfcod = 0 then next.
                valicms = movim.movalicms.
                if vopfcod = 5405 then valicms = 0.
                find first tt-op where tt-op.desti  = plani.emite  and
                                   tt-op.ali    = valicms and
                                   tt-op.opfcod = vopfcod no-error.
                if not avail tt-op
                then do:
                    create tt-op.
                    assign tt-op.desti  = plani.emite
                       tt-op.ali    = valicms
                       tt-op.opfcod = vopfcod.
                end.
                assign tt-op.totpla = tt-op.totpla + 
                            (movim.movpc * movim.movqtm) 
                   tt-op.totbic = tt-op.totbic + movim.movbicms
                   tt-op.toticm = tt-op.toticm + movim.movicms 
                   .

                find first tt-op where tt-op.desti  = 0  and
                                   tt-op.ali    = valicms and
                                   tt-op.opfcod = vopfcod no-error.
                if not avail tt-op
                then do:
                    create tt-op.
                    assign tt-op.desti  = 0
                           tt-op.ali    = valicms
                           tt-op.opfcod = vopfcod.
                end.
                assign tt-op.totpla = tt-op.totpla + 
                                (movim.movpc * movim.movqtm) 
                   tt-op.totbic = tt-op.totbic + movim.movbicms
                   tt-op.toticm = tt-op.toticm + movim.movicms 
                   .
            end.
            
            find first tt-nf where
                       tt-nf.opfcod = plani.opccod and
                       tt-nf.emite  = plani.desti  and
                       tt-nf.desti  = plani.emite  and
                       tt-nf.serie  = plani.serie  and
                       tt-nf.numero = plani.numero
                       no-error.
            if not avail tt-nf
            then do:
                create tt-nf.
                assign
                    tt-nf.opfcod = plani.opccod
                    tt-nf.emite  = plani.desti
                    tt-nf.desti  = plani.emite
                    tt-nf.serie  = plani.serie
                    tt-nf.numero = plani.numero
                    .
            end.
            assign
                tt-nf.ali    = 0
                tt-nf.totpla = tt-nf.totpla + plani.platot 
                tt-nf.totbic = tt-nf.totbic + plani.bicms 
                tt-nf.toticm = tt-nf.toticm + plani.icms 
                tt-nf.totipi = tt-nf.totipi + plani.ipi 
                tt-nf.totout = tt-nf.totout + plani.out
                tt-nf.chave  = plani.ufemi
                .

            find a01_infnfe where 
                 a01_infnfe.emite  = plani.emite and
                 a01_infnfe.serie  = plani.serie and
                 a01_infnfe.numero = plani.numero
                 no-lock no-error.
            if avail a01_infnfe
            then tt-nf.chave = a01_infnfe.id. 

        end.
        for each tipmov where 
                           (tipmov.movtdc = 6 or
                            tipmov.movtdc = 36 /*or
                           tipmov.movtdc = 9 or
                           tipmov.movtdc = 22 or
                           tipmov.movtdc = 34 or
                           tipmov.movtdc = 54 */) /*and
                            movtnota = no*/ no-lock,
            each plani where plani.movtdc = tipmov.movtdc and 
                             plani.desti  = estab.etbcod  and 
                             plani.pladat >= vdti         and
                             plani.pladat <= vdtf  no-lock:
            
            vopfcod = plani.hiccod.
            
            for each movim where movim.etbcod = plani.etbcod and
                                 movim.placod = plani.placod and
                                 movim.movtdc = plani.movtdc and
                                 movim.movdat = plani.pladat
                                 no-lock:
            
                vopfcod = plani.hiccod.
                if movim.opfcod > 0
                then vopfcod = movim.opfcod.
                if substr(string(vopfcod),1,1) = "5"
                then vopfcod = int("1" + substr(string(vopfcod),2,3)).
                if substr(string(vopfcod),1,1) = "6"
                then vopfcod = int("2" + substr(string(vopfcod),2,3)).

                if vopfcod = 0 then next.
                find first tt-op where tt-op.desti  = plani.desti  and
                                   tt-op.ali    = movim.movalicms and
                                   tt-op.opfcod = vopfcod
                                                  no-error.
                if not avail tt-op
                then do:
                    create tt-op.
                    assign tt-op.desti  = plani.desti
                       tt-op.ali    = movim.movalicms
                       tt-op.opfcod = vopfcod.
                end.
                assign tt-op.totpla = tt-op.totpla + 
                            (movim.movpc * movim.movqtm) 
                   tt-op.totbic = tt-op.totbic + movim.movbicms 
                   tt-op.toticm = tt-op.toticm + movim.movicms 
                   .
                   
                find first tt-op where tt-op.desti  = 0  and
                                   tt-op.ali    = movim.movalicms and
                                   tt-op.opfcod = vopfcod no-error.
                if not avail tt-op
                then do:
                    create tt-op.
                    assign tt-op.desti  = 0
                       tt-op.ali    = movim.movalicms
                       tt-op.opfcod = vopfcod.
                end.
                assign tt-op.totpla = tt-op.totpla + 
                            (movim.movpc * movim.movqtm) 
                   tt-op.totbic = tt-op.totbic + movim.movbicms 
                   tt-op.toticm = tt-op.toticm + movim.movicms
                    .
            end.
            
            find first tt-nf where
                       tt-nf.opfcod = vopfcod and
                       tt-nf.emite  = plani.emite  and
                       tt-nf.desti  = plani.desti  and
                       tt-nf.serie  = plani.serie  and
                       tt-nf.numero = plani.numero
                       no-error.
            if not avail tt-nf
            then do:
                create tt-nf.
                assign
                    tt-nf.opfcod = vopfcod
                    tt-nf.emite  = plani.emite
                    tt-nf.desti  = plani.desti
                    tt-nf.serie  = plani.serie
                    tt-nf.numero = plani.numero
                    .
            end.
            assign
                tt-nf.ali    = 0
                tt-nf.totpla = tt-nf.totpla + plani.platot 
                tt-nf.totbic = tt-nf.totbic + plani.bicms 
                tt-nf.toticm = tt-nf.toticm + plani.icms 
                tt-nf.totipi = tt-nf.totipi + plani.ipi 
                tt-nf.totout = tt-nf.totout + plani.out
                tt-nf.chave  = plani.ufemi
                .
            find a01_infnfe where 
                 a01_infnfe.emite = plani.emite and
                 a01_infnfe.serie = plani.serie and
                 a01_infnfe.numero = plani.numero
                 no-lock no-error.
            if avail a01_infnfe
            then tt-nf.chave = a01_infnfe.id. 
        end.
    end.                     
    def var varqcsv as char.
                
    varquivo = "/admcom/relat/totaisCFOP_" + string(time) + ".txt".
    varqcsv = "/admcom/relat/totaisCFOP_" + string(time) + ".csv".

    {mdad.i 
        &Saida     = "value(varquivo)" 
        &Page-Size = "64" 
        &Cond-Var  = "130" 
        &Page-Line = "66" 
        &Nom-Rel   = ""totaisCFOP""
        &Nom-Sis   = """SISTEMA DE CONTABILIDADE"""
        &Tit-Rel   = """LISTAGEM DE NOTAS DE ENTRADA  "" + 
                     ""ESTABELECIMENTO:  "" + string(vetbcod) + 
                     "" "" +
                     string(vdti,""99/99/9999"") + "" ate "" +
                     string(vdtf,""99/99/9999"")"
        &Width     = "130"
        &Form      = "frame f-cabcab3"}

        
    for each tt-op where tt-op.desti > 0 break by tt-op.desti
                                    by tt-op.opfcod:
        
        display tt-op.desti
                tt-op.opfcod format "9999"
                tt-op.ali 
                tt-op.totpla(total by tt-op.desti) column-label "Total"
                tt-op.totbic(total by tt-op.desti) column-label "Base ICMS"
                tt-op.toticm(total by tt-op.desti) column-label "ICMS"
                tt-op.totipi(total by tt-op.desti) column-label "IPI"
                tt-op.totout(total by tt-op.desti) column-label "Outras"
                                        with frame flista1 width 200 down.
        
        if vindex = 2
        then do:
            for each tt-nf where
                     tt-nf.opfcod = tt-op.opfcod:
                disp tt-nf.opfcod column-label "Cfop" format ">>>>9"
                     tt-nf.numero column-label "Numero" format ">>>>>>>>9"
                     tt-nf.emite  column-label "Emite"
                     tt-nf.desti  column-label "Desti"
                     tt-nf.totpla(total) column-label "TNota"
                     tt-nf.totbic(total) column-label "TBase"
                     tt-nf.toticm(total) column-label "Ticms"
                     /*tt-nf.totipi
                     tt-nf.totout */
                     tt-nf.chave 
                     with frame flista2 width 200 down.

            end.
            put fill("=",100) format "x(100)" skip.
        end.
        
    end.
    if vetbcod  = 0
    then do:
        put skip(1) "TOTAL GERAL" SKIP.
        
    for each tt-op where tt-op.desti = 0 :
        
        display 
                tt-op.opfcod format "9999"
                tt-op.ali 
                tt-op.totpla(total) column-label "Total"
                tt-op.totbic(total) column-label "Base ICMS"
                tt-op.toticm(total) column-label "ICMS"
                tt-op.totipi(total) column-label "IPI"
                tt-op.totout(total) column-label "Outras"
                                        with frame flista3 width 200 down.
     
    end.
    end.

    output close.

    run visurel.p ( input varquivo, "" ).

    output to value(varqcsv).

    put "Filial;CFOP;Aliq;Total;Base;Icms;IPI;Outras" skip.
    
    for each tt-op where tt-op.desti > 0 break by tt-op.desti
                                    by tt-op.opfcod:
    
        put unformatted 
                tt-op.desti
                ";"
                tt-op.opfcod format "9999"
                ";"
                tt-op.ali 
                ";"
                tt-op.totpla
                ";"
                tt-op.totbic
                ";"
                tt-op.toticm
                ";"
                tt-op.totipi
                ";"
                tt-op.totout
                skip
                .
                    
    end.     
    output close.
    
    message color red/with
            "Arquivo csv gerado:" skip
            varqcsv
            view-as alert-box.
    leave.        
end.    
 