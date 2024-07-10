{admcab.i}   

/*
do:
run tottais-cfop.p.
return.
end.
*/

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
    
def var vopfcod like plani.opccod.

def var vetbcod like estab.etbcod.
def var vdti like plani.pladat.
def var vdtf like plani.pladat.
def var vmovtdc like tipmov.movtdc.

repeat:

    for each tt-op: delete tt-op. end. 
    for each tt-nf: delete tt-nf. end.   
    
    update vmovtdc colon 16 label "Tipo Movimento"
                        with frame f1.
    find tipmov where tipmov.movtdc = vmovtdc no-lock no-error.
    if not avail tipmov
    then display "GERAL" @ tipmov.movtnom no-label with frame f1.
    else display movtnom no-label with frame f1.
    
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
    
    /*
    update vnumero.                     
    */
    
    for each estab where if vetbcod = 0
                         then true
                         else estab.etbcod = vetbcod no-lock:  
        for each tipmov where 
                        tipmov.movtdc =  4 or
                        tipmov.movtdc = 10 or
                        tipmov.movtdc = 11 or
                        tipmov.movtdc = 12 or
                        tipmov.movtdc = 15 or
                        tipmov.movtdc = 27 or
                        tipmov.movtdc = 28 or
                        tipmov.movtdc = 32 or
                        tipmov.movtdc = 35 or
                        tipmov.movtdc = 47 or
                        tipmov.movtdc = 51 or
                        tipmov.movtdc = 53 or
                        tipmov.movtdc = 57 or
                        tipmov.movtdc = 60 or
                        tipmov.movtdc = 61 or
                        tipmov.movtdc = 62 or
                        tipmov.movtdc = 65 or
                        tipmov.movtdc = 67 or
                        tipmov.movtdc = 40
        or can-find (first tipmovaux where
                            tipmovaux.movtdc = tipmov.movtdc and
                            tipmovaux.nome_campo = "PROGRAMA-NF" AND
                            tipmovaux.valor_campo = "nfentall")
                no-lock :
        /*
        for each tipmov where if vmovtdc = 0
                              then true
                              else tipmov.movtdc = vmovtdc no-lock.
            if tipmov.movtdc = 4 or
               tipmov.movtdc = 12 
                           then.
            else next.
        */    
        
        for each fiscal where fiscal.desti = estab.etbcod   and
                              fiscal.movtdc = tipmov.movtdc and  
                              fiscal.plarec >= vdti    and
                              fiscal.plarec <= vdtf no-lock:
            
            if fiscal.movtdc = 12 and
               fiscal.serie = "U"
            then next.
            
            if vnumero > 0 and
               fiscal.numero <> vnumero
            then next.   
                           
            find first tt-op where tt-op.desti  = fiscal.desti  and
                                   tt-op.ali    = fiscal.alicms and
                                   tt-op.opfcod = fiscal.opfcod no-error.
            if not avail tt-op
            then do:
                create tt-op.
                assign tt-op.desti  = fiscal.desti
                       tt-op.ali    = fiscal.alicms
                       tt-op.opfcod = fiscal.opfcod.
            end.
            assign tt-op.totpla = tt-op.totpla + fiscal.platot. 
                   tt-op.totbic = tt-op.totbic + fiscal.bicms. 
                   tt-op.toticm = tt-op.toticm + fiscal.icms. 
                   tt-op.totipi = tt-op.totipi + fiscal.ipi. 
                   tt-op.totout = tt-op.totout + fiscal.out.
            find first tt-op where tt-op.desti  = 0  and
                                   tt-op.ali    = fiscal.alicms and
                                   tt-op.opfcod = fiscal.opfcod no-error.
            if not avail tt-op
            then do:
                create tt-op.
                assign tt-op.desti  = 0
                       tt-op.ali    = fiscal.alicms
                       tt-op.opfcod = fiscal.opfcod.
            end.
            assign tt-op.totpla = tt-op.totpla + fiscal.platot. 
                   tt-op.totbic = tt-op.totbic + fiscal.bicms. 
                   tt-op.toticm = tt-op.toticm + fiscal.icms. 
                   tt-op.totipi = tt-op.totipi + fiscal.ipi. 
                   tt-op.totout = tt-op.totout + fiscal.out.
       
            find first tt-nf where
                       tt-nf.opfcod = fiscal.opfcod and
                       tt-nf.emite  = fiscal.emite  and
                       tt-nf.desti  = fiscal.desti  and
                       tt-nf.serie  = fiscal.serie  and
                       tt-nf.numero = fiscal.numero
                       no-error.
            if not avail tt-nf
            then do:
                create tt-nf.
                assign
                    tt-nf.opfcod = fiscal.opfcod
                    tt-nf.emite  = fiscal.emite
                    tt-nf.desti  = fiscal.desti
                    tt-nf.serie  = fiscal.serie
                    tt-nf.numero = fiscal.numero
                    .
            end.
            assign
                tt-nf.ali    = fiscal.alicms
                tt-nf.totpla = tt-nf.totpla + fiscal.platot 
                tt-nf.totbic = tt-nf.totbic + fiscal.bicms 
                tt-nf.toticm = tt-nf.toticm + fiscal.icms 
                tt-nf.totipi = tt-nf.totipi + fiscal.ipi 
                tt-nf.totout = tt-nf.totout + fiscal.out
                .
    
            find a01_infnfe where 
                 a01_infnfe.emite = fiscal.emite and
                 a01_infnfe.serie = fiscal.serie and
                 a01_infnfe.numero = fiscal.numero
                 no-lock no-error.
            if avail a01_infnfe
            then tt-nf.chave = a01_infnfe.id.     
            else do:
                find plani where plani.etbcod = fiscal.desti and
                                 plani.emite  = fiscal.emite and
                                 plani.desti = fiscal.desti and
                                 plani.numero = fiscal.numero and
                                 plani.serie = fiscal.serie
                                 no-lock no-error.
                if avail plani
                then tt-nf.chave = plani.ufdes.
            end.                     
        end.
        end.           

        /*
        for each tipmov where movtnota = yes no-lock,
            each plani where plani.movtdc = tipmov.movtdc and
                         plani.etbcod = estab.etbcod and
                         plani.desti = estab.etbcod and
                         plani.emite = estab.etbcod and
                         plani.pladat >= vdti and
                         plani.pladat <= vdtf and
                         plani.modcod <> "CAN"
                         no-lock:
            find first tt-op where tt-op.desti  = plani.emite  and
                                   tt-op.ali    = 0 and
                                   tt-op.opfcod = plani.opccod no-error.
            if not avail tt-op
            then do:
                create tt-op.
                assign tt-op.desti  = plani.emite
                       tt-op.ali    = 0
                       tt-op.opfcod = plani.opccod.
            end.
            assign tt-op.totpla = tt-op.totpla + plani.platot 
                   tt-op.totbic = tt-op.totbic + plani.bicms 
                   tt-op.toticm = tt-op.toticm + plani.icms 
                   tt-op.totipi = tt-op.totipi + plani.ipi 
                   tt-op.totout = tt-op.totout + plani.out.

            find first tt-op where tt-op.desti  = 0  and
                                   tt-op.ali    = 0 and
                                   tt-op.opfcod = plani.opccod no-error.
            if not avail tt-op
            then do:
                create tt-op.
                assign tt-op.desti  = 0
                                       tt-op.ali    = 0
                       tt-op.opfcod = plani.opccod.
            end.
            assign tt-op.totpla = tt-op.totpla + plani.platot 
                   tt-op.totbic = tt-op.totbic + plani.bicms 
                   tt-op.toticm = tt-op.toticm + plani.icms 
                   tt-op.totipi = tt-op.totipi + plani.ipi 
                   tt-op.totout = tt-op.totout + plani.out.

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
        */
        
        for each tipmov where 
                           tipmov.movtdc = 6 or
                           tipmov.movtdc = 9 or
                           tipmov.movtdc = 22 or
                           tipmov.movtdc = 34 or
                           tipmov.movtdc = 36 or
                           tipmov.movtdc = 54 no-lock,
            
            each plani where plani.movtdc = tipmov.movtdc and 
                             plani.desti  = estab.etbcod  and 
                             plani.pladat >= vdti         and
                             plani.pladat <= vdtf  no-lock:
        /*
        for each plani where plani.movtdc = 6 and
                         plani.desti = estab.etbcod and
                         plani.pladat >= vdti and
                         plani.pladat <= vdtf and
                         plani.modcod <> "CAN"
                         no-lock:
            */
            
            if vnumero > 0 and
                plani.numero <> vnumero
            then next.
                
            if substr(string(plani.opccod),1,1) = "5"
            then vopfcod = int("1" + substr(string(plani.opccod),2,3)).
            if substr(string(plani.opccod),1,1) = "6"
            then vopfcod = int("2" + substr(string(plani.opccod),2,3)).

            find first tt-op where tt-op.desti  = plani.desti  and
                                   tt-op.ali    = 0 and
                                   tt-op.opfcod = vopfcod
                                                  no-error.
            if not avail tt-op
            then do:
                create tt-op.
                assign tt-op.desti  = plani.desti
                       tt-op.ali    = 0
                       tt-op.opfcod = vopfcod.
            end.
            assign tt-op.totpla = tt-op.totpla + plani.platot 
                   tt-op.totbic = tt-op.totbic + plani.bicms 
                   tt-op.toticm = tt-op.toticm + plani.icms 
                   tt-op.totipi = tt-op.totipi + plani.ipi 
                   tt-op.totout = tt-op.totout + plani.out.
                   
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
                   tt-op.toticm = tt-op.toticm + plani.icms 
                   tt-op.totipi = tt-op.totipi + plani.ipi 
                   tt-op.totout = tt-op.totout + plani.out.
       
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
            if tt-nf.chave = "" and
               length(plani.ufdes) = 44
            then tt-nf.chave = plani.ufdes.   
        end.

        if vetbcod = 900
        then for each tipmov where 
                           tipmov.movtdc = 6 or
                           tipmov.movtdc = 9 or
                           tipmov.movtdc = 22 or
                           tipmov.movtdc = 34 or
                           tipmov.movtdc = 36 or
                           tipmov.movtdc = 54 or
                           tipmov.movtdc = 60 or
                           tipmov.movtdc = 67 
                            no-lock,
            
            each plani where plani.movtdc = tipmov.movtdc and 
                             (plani.desti  = 901 or
                              plani.desti  = 930) and 
                             plani.pladat >= vdti         and
                             plani.pladat <= vdtf  no-lock:
            
            if vnumero > 0 and
               plani.numero <> vnumero
            then next.
               
            if substr(string(plani.opccod),1,1) = "5"
            then vopfcod = int("1" + substr(string(plani.opccod),2,3)).
            if substr(string(plani.opccod),1,1) = "6"
            then vopfcod = int("2" + substr(string(plani.opccod),2,3)).

            find first tt-op where tt-op.desti  = vetbcod  and
                                   tt-op.ali    = 0 and
                                   tt-op.opfcod = vopfcod
                                                  no-error.
            if not avail tt-op
            then do:
                create tt-op.
                assign tt-op.desti  = vetbcod
                       tt-op.ali    = 0
                       tt-op.opfcod = vopfcod.
            end.
            assign tt-op.totpla = tt-op.totpla + plani.platot 
                   tt-op.totbic = tt-op.totbic + plani.bicms 
                   tt-op.toticm = tt-op.toticm + plani.icms 
                   tt-op.totipi = tt-op.totipi + plani.ipi 
                   tt-op.totout = tt-op.totout + plani.out.
                   
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
                   tt-op.toticm = tt-op.toticm + plani.icms 
                   tt-op.totipi = tt-op.totipi + plani.ipi 
                   tt-op.totout = tt-op.totout + plani.out.
       
            find first tt-nf where
                       tt-nf.opfcod = vopfcod and
                       tt-nf.emite  = plani.emite  and
                       tt-nf.desti  = vetbcod  and
                       tt-nf.serie  = plani.serie  and
                       tt-nf.numero = plani.numero
                       no-error.
            if not avail tt-nf
            then do:
                create tt-nf.
                assign
                    tt-nf.opfcod = vopfcod
                    tt-nf.emite  = plani.emite
                    tt-nf.desti  = vetbcod
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
            if tt-nf.chave = ""
            then do:
                find a01_infnfe where 
                     a01_infnfe.emite = vetbcod and
                     a01_infnfe.serie = plani.serie and
                     a01_infnfe.numero = plani.numero
                     no-lock no-error.
                if avail a01_infnfe
                then tt-nf.chave = a01_infnfe.id. 
            end.
            if tt-nf.chave = "" and
               length(plani.ufdes) = 44
            then tt-nf.chave = plani.ufdes. 
        end.
    end.                          
                
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/conctbl_" + string(time) + ".txt".
    else varquivo = "l:~\relat~\conctb.txt".
    
    {mdad.i 
        &Saida     = "value(varquivo)" 
        &Page-Size = "64" 
        &Cond-Var  = "130" 
        &Page-Line = "66" 
        &Nom-Rel   = ""conctb""
        &Nom-Sis   = """SISTEMA DE CONTABILIDADE"""
        &Tit-Rel   = """LISTAGEM DE NOTAS DE ENTRADA  "" + 
                     ""ESTABELECIMENTO:  "" + string(vetbcod) + 
                     "" "" +
                     string(vdti,""99/99/9999"") + "" ate "" +
                     string(vdtf,""99/99/9999"")"
        &Width     = "130"
        &Form      = "frame f-cabcab3"}

        
    for each tt-op where tt-op.desti > 0 break by tt-op.desti:
        
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
    if opsys = "UNIX"
    then do:
        run visurel.p ( input varquivo, "" ).
    end.
    else do:
        {mrod.i}
    end.

end.    
                           
