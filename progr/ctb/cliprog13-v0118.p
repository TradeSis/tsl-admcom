{admcab.i}

form vetbcod like estab.etbcod at 2 label "Filial"
     estab.etbnom no-label
     vdti as date at 1 format "99/99/9999" label "Periodo"
     vdtf as date format "99/99/9999" no-label
     with frame f-1 width 55 side-label
     column 25.

def var v-escolha as char extent 7 format "x(20)"
    init["VENDA PRAZO(80)",
         "VENDA VISTA(60)",
         "RECEBIMENTO(70)",
         "JUROS RECEBIMENTO",
         "CARTAO(95)",
         "DEVOLUCAO(75)",
         "NOVACAO(71)"].    
     
def var vindex as int init 0.
disp with frame f-1.
DISP v-escolha with frame f-escolha no-label 1 column.
choose field v-escolha with frame f-escolha.
vindex = frame-index.

if vindex > 7
then return.


update vetbcod with frame f-1.
if vetbcod > 0
then do:
    find estab where estab.etbcod = vetbcod no-lock.
    disp estab.etbnom with frame f-1.
end.
else disp "GERAL" @ estab.etbnom with frame f-1.    
update vdti vdtf with frame f-1.
if vdti = ? or vdtf = ? or vdti > vdtf
then undo.

def buffer bopctbval for opctbval.

def var vdata as date.

def temp-table tt-plani like plani.

def temp-table tt-titulo like titulo
    field opctbval as dec.
    
def temp-table tt-contrato like contrato
    field entrada as dec
    field finan as dec
    field lebes as dec
    field acres as dec 
    field desco as dec
    field local as char
.

def temp-table tt-valetb
    field etbcod like estab.etbcod 
    field valor as dec
    index i1 etbcod.

def var v-aprazo as dec.
def var t-aprazo as dec.
def var v-avista as dec.
def var t-avista as dec.
def var val-lebes as dec.
def var val-finan as dec.

for each estab no-lock:
    if vetbcod > 0 and vetbcod <> estab.etbcod then next.
    do vdata = vdti to vdtf:                         

        v-aprazo = 0.
        v-avista = 0.
        for each ct-cartcl where ct-cartcl.etbcod = estab.etbcod and
                                 ct-cartcl.datref = vdata
                                 no-lock:
            if vindex = 1
            then v-aprazo = v-aprazo + ct-cartcl.aprazo.
            if vindex = 2
            then v-avista = v-avista + ct-cartcl.avista.
        end. 
        /*if vindex <> 7
        then*/ do:
        for each opctbval where
             opctbval.etbcod = estab.etbcod and
             opctbval.datref = vdata and
             opctbval.t9 <> "" /*and
             opctbval.t0 = ""    */         
             no-lock /*by valor descending*/:

            /*VENDA PRAZO*/
            if vindex = 1 and  
               opctbval.t1 = "CONTRATO" and
               opctbval.t2 = "A-PRAZO" and
               opctbval.t3 = "CRE" and
               opctbval.t4 = "LEBES" and 
               (opctbval.t5 = "PRINCIPAL" /*or
                opctbval.t5 = "ABATE" or
                opctbval.t5 = "ENTRADA"*/) AND /*
               opctbval.t6 = "FISCAL" and  
               opctbval.t7 = ""  and
               opctbval.t8 = ""  and  */  
               opctbval.t9 <> ""  and  
               opctbval.t0 = "" 
            then do:
                
                find contrato where  contrato.contnum = int(opctbval.t9)
                            no-lock.
                find last contnf where contnf.etbcod = contrato.etbcod and
                                  contnf.contnum = contrato.contnum
                                  no-lock.
                if avail contnf
                then do:
                    find first plani where plani.etbcod = contnf.etbcod and
                                     plani.placod = contnf.placod and
                                     plani.serie = contnf.notaser
                                     no-lock no-error.
                    if avail plani and plani.platot <= v-aprazo
                    then do:
                        create tt-plani.
                        buffer-copy plani to tt-plani.
                        v-aprazo = v-aprazo - plani.platot.
                    end.
                end.
            end.
            
            /*VENDA VISTA*/
            if vindex = 2 and
               opctbval.t1 = "RECEBIMENTO" and
               opctbval.t2 = "VVI" and
               opctbval.t3 = "" and
               opctbval.t4 = "" and
               opctbval.t5 = "" and
               opctbval.t6 = "LEBES"   and
               opctbval.t7 = ""  and
               opctbval.t8 = ""  and
               opctbval.t9 <> "" and
               opctbval.t0 <> ""   
            then do:
                if int(opctbval.t0) = 1 then next.
                find first titulo where
                               titulo.empcod = 19 and
                               titulo.titnat = no and
                               titulo.modcod = "VVI" and
                               titulo.etbcod = opctbval.etbcod and
                               /*titulo.clifor = 1 and */
                               titulo.titnum = opctbval.t0
                               + opctbval.t9 /*and
                               titulo.titpar = int(opctbval.t0)*/
                               no-lock no-error.
                if avail titulo 
                then do:                           
                    if titulo.moecod = "PDM"
                    then do:
                        for each titpag where
                                     titpag.empcod = titulo.empcod and
                                     titpag.titnat = titulo.titnat and
                                     titpag.modcod = titulo.modcod and
                                     titpag.etbcod = titulo.etbcod and
                                     titpag.clifor = titulo.clifor and
                                     titpag.titnum = titulo.titnum and
                                     titpag.titpar = titulo.titpar and
                                     titpag.moecod = "REA"
                                     no-lock:
                            if titpag.moecod = "REA" and
                               titpag.titvlpag <= v-avista
                            then do:
                                create tt-titulo.
                                buffer-copy titulo to tt-titulo.
                                if tt-titulo.titvlpag > titpag.titvlpag
                                then do:
                                    tt-titulo.titvlpag = titpag.titvlpag.
                                    v-avista = v-avista - titpag.titvlpag.
                                end.
                                else v-avista = v-avista - tt-titulo.titvlpag.
                            end.     
                        end.
                    end.
                    /*
                    else if titulo.moecod = "REA"
                        and titulo.titvlcob <= v-avista
                    then do:    
                            create tt-titulo.
                            buffer-copy titulo to tt-titulo.
                            v-avista = v-avista - titulo.titvlcob.
                    end.
                    */
                end.
                
                /***************
                disp opctbval.t0 opctbval.t9.
                find first plani where plani.etbcod = opctbval.etbcod and
                                       plani.emite  = opctbval.etbcod and
                                       plani.serie  = opctbval.t0     and
                                       plani.numero = int(opctbval.t9) and
                                       plani.movtdc = 5
                                     no-lock no-error.
                if avail plani /*and
                    length(plani.serie) = 2  and
                     plani.platot <= v-avista*/ 
                then do:

                    disp plani.numero.
                    
                    find first titulo where
                               titulo.empcod = 19 and
                               titulo.titnat = no and
                               titulo.modcod = "VVI" and
                               titulo.etbcod = plani.etbcod and
                               titulo.clifor = plani.desti and
                               titulo.titnum = plani.serie +                                                 string(plani.numero) 
                               no-lock no-error.
                    if avail titulo /*and titulo.moecod = "REA"*/
                          and titulo.titvlcob <= v-avista
                    then do:                           
                        create tt-titulo.
                        buffer-copy titulo to tt-titulo.
                        v-avista = v-avista - titulo.titvlcob.
                    end.
                end.
                **************/
            end.
            
            /*RECEBIMENTO*/
            if vindex = 3 
            then do:
                if  opctbval.t1 = "RECEBIMENTO" and
                    opctbval.t2 = "CRE" and
                    opctbval.t3 = "" and
                    opctbval.t4 = "" and
                    opctbval.t5 = "" and
                    opctbval.t6 = "LEBES" and
                    opctbval.t7 = "ENTRADA" and
                    opctbval.t8 = "" and
                    opctbval.t9 <> "" and
                    opctbval.t0 <> ""
                then do:
                    find contrato where contrato.contnum = int(opctbval.t9)
                                    no-lock no-error.
                    if avail contrato
                    then do:
                        find first titulo where
                               titulo.titnat = no and
                               titulo.clifor = contrato.clicod and
                               titulo.titnum = opctbval.t9 and
                               titulo.titpar = int(opctbval.t0)
                               no-lock no-error.
                        if avail titulo 
                        then do:
                            create tt-titulo.
                            buffer-copy titulo to tt-titulo. 
                            tt-titulo.opctbval = opctbval.valor.
                        end.
                    end.            
                end.
                /**********
                if  opctbval.t1 = "RECEBIMENTO" and
                    opctbval.t2 = "CRE" and
                    opctbval.t3 = "" and
                    opctbval.t4 = "" and
                    opctbval.t5 = "" and
                    opctbval.t6 = "LEBES"   and
                    opctbval.t7 = "ACRESCIMO" and
                    opctbval.t8 = "" and
                    opctbval.t9 <> "" and
                    opctbval.t0 <> ""
                then. /* run recebimento-moeda(estab.etbcod, vdata, opctbval.t7,
                                       substr(opctbval.t8,1,3), 
                                       opctbval.valor).  */
                ********/
                
                if  opctbval.t1 = "RECEBIMENTO" and
                    opctbval.t2 = "CRE" and
                    opctbval.t3 = "" and
                    opctbval.t4 = "" and
                    opctbval.t5 = "" and
                    opctbval.t6 = "LEBES"   and
                    opctbval.t7 = "PRINCIPAL" and
                    opctbval.t8 = "" and
                    opctbval.t9 <> "" and
                    opctbval.t0 <> ""
                then do:
                    find contrato where contrato.contnum = int(opctbval.t9)
                                    no-lock no-error.
                    if avail contrato
                    then do:
                        find first titulo where
                               titulo.titnat = no and
                               titulo.clifor = contrato.clicod and
                               titulo.titnum = opctbval.t9 and
                               titulo.titpar = int(opctbval.t0)
                               no-lock no-error.
                        if avail titulo 
                        then do:
                            create tt-titulo.
                            buffer-copy titulo to tt-titulo. 
                            tt-titulo.opctbval = opctbval.valor.
                        end.
                    end. 
                end.             
            end.
            /*********************************/
            
            if vindex = 4 and
               opctbval.t1 = "RECEBIMENTO" and
               opctbval.t2 = "CRE" and
               opctbval.t3 = "" and
               opctbval.t4 = "" and
               opctbval.t5 = "" and
               opctbval.t6 = "LEBES"   and
               opctbval.t7 = "JURO ATRASO" /*and
               opctbval.t8 <> "" and
               opctbval.t9 = "" and
               opctbval.t0 = ""              */
            then do:
                find contrato where contrato.contnum = int(opctbval.t9)
                        no-lock no-error.
                if avail contrato
                then do:
                    find first titulo where
                               titulo.titnat = no and
                               titulo.clifor = contrato.clicod and
                               titulo.titnum = opctbval.t9 and
                               titulo.titpar = int(opctbval.t0)
                               no-lock no-error.
                    if avail titulo and titulo.moecod = "REA"
                    then do:
                        find first  tt-valetb where 
                                    tt-valetb.etbcod = opctbval.etbcod 
                                    no-error.
                        if not avail tt-valetb
                        then do:
                            create tt-valetb.
                            tt-valetb.etbcod = opctbval.etbcod.
                        end.            
                        tt-valetb.valor = tt-valetb.valor + opctbval.valor. 
                        create tt-titulo.
                        buffer-copy titulo to tt-titulo. 
                        tt-titulo.opctbval = opctbval.valor.
                    end.            
                end.
            end.

            /*CARTAO*/
            if vindex = 5 and
               opctbval.t1 = "RECEBIMENTO" and
               opctbval.t2 = "VVI" and
               opctbval.t3 = "" and
               opctbval.t4 = "" and
               opctbval.t5 = "" and
               opctbval.t6 = "LEBES"   and
               opctbval.t7 = "" and
               opctbval.t8 = ""
            then do:
                for each bopctbval where
                           bopctbval.etbcod = opctbval.etbcod and
                           bopctbval.datref = opctbval.datref and
                           bopctbval.t1 = opctbval.t1 and
                           bopctbval.t2 = opctbval.t2 and
                           bopctbval.t3 = opctbval.t3 and
                           bopctbval.t4 = opctbval.t4 and
                           bopctbval.t5 = opctbval.t5 and
                           bopctbval.t6 = opctbval.t6 and
                           bopctbval.t7 = opctbval.t7 and
                           bopctbval.t8 <> ""  and
                           bopctbval.valor = opctbval.valor
                           no-lock .
                /*if avail bopctbval
                then do:*/
                    if bopctbval.t8 begins "BON" or
                       bopctbval.t8 begins "CHP" or
                       bopctbval.t8 begins "CHV" or
                       bopctbval.t8 begins "REA" or
                       bopctbval.t8 begins "DEV"
                    then.
                    else do:
                        find first  plani where 
                                    plani.etbcod = opctbval.etbcod and
                                       plani.emite  = opctbval.etbcod and
                                       plani.serie  = opctbval.t0     and
                                       plani.numero = int(opctbval.t9)
                                     no-lock no-error.
                        if avail plani 
                        then do:
                            create tt-plani.
                            buffer-copy plani to tt-plani.
                        end.

                    end.
                end.
            end.              

            /*DEVOLUCAO*/
            if vindex = 6 
            then do:
                        
                if  opctbval.t1 = "DEVOLUCAO" and
                    opctbval.t2 = "VENDA" and
                    opctbval.t3 = "A-PRAZO" /*and
                    opctbval.t4 = "" and
                    opctbval.t5 = "" and
                    opctbval.t6 = "" and
                    opctbval.t7 = "" and
                    opctbval.t8 = ""          */
                then do:
                    disp opctbval.
                end.
                if  opctbval.t1 = "DEVOLUCAO" and
                    opctbval.t2 = "VENDA" and
                    opctbval.t3 = "A-VISTA" and
                    opctbval.t4 = "" and
                    opctbval.t5 = "" and
                    opctbval.t6 = ""   and
                    opctbval.t7 = "" and
                    opctbval.t8 = "" 
                then do: 
                    disp opctbval.
                end.
            end.
            /***********/
            /*NOVACOES*/
            if vindex = 7 and  
               opctbval.t1 = "CONTRATO" and
               opctbval.t2 = "OUTROS" and
               opctbval.t3 = "CRE" and
               opctbval.t4 <> "OUTROS"  and
               opctbval.t5 = "LEBES"  and
               (opctbval.t6 = "PRINCIPAL" /*or
                opctbval.t6 = "ACRESCIMO" or
                opctbval.t6 = "ENTRADA"*/) AND /*
               opctbval.t6 = "FISCAL" and  
               opctbval.t7 = ""  and
               opctbval.t8 = ""  and  */  
               opctbval.t9 <> ""  and  
               opctbval.t0 = "" 
            then do:
                
                for each contrato where  contrato.contnum = int(opctbval.t9)
                            no-lock .
            
                    /*if contrato.contnum = 78811960 then next.
                     */
                /*if contrato.crecod <> 500 then next.*/
                find first envfinan where
                           envfinan.empcod = 19 and
                           envfinan.titnat = no and
                           envfinan.modcod = contrato.modcod and
                           envfinan.etbcod = contrato.etbcod and
                           envfinan.clifor = contrato.clicod and
                           envfinan.titnum = string(contrato.contnum)
                no-lock no-error.
                /*if not avail envfinan
                then*/ do:
                    find first tt-contrato where
                               tt-contrato.contnum = contrato.contnum
                               no-error.
                    if not avail tt-contrato
                    then do:           
                        create tt-contrato.
                        buffer-copy contrato to tt-contrato.
                    end.
           
                    /*find first titulo where 
                               titulo.titnat = no and
                               titulo.clifor = tt-contrato.clicod and
                               titulo.titnum = string(tt-contrato.contnum) and
                               titulo.titpar = 0
                               no-lock no-error.
                    if avail titulo 
                    then tt-contrato.vlentra = titulo.titvlcob.
                    */
                    val-lebes = 0.
                    val-finan = 0.            
                    for each tit_novacao where
                             tit_novacao.ger_contnum = contrato.contnum
                             no-lock:   
                        find first titulo where
                                   titulo.clifor = tit_novacao.ori_clifor and
                                   titulo.titnum = tit_novacao.ori_titnum and
                                   titulo.titpar = tit_novacao.ori_titpar
                                   no-lock no-error.
                        if avail titulo 
                        then do:
                            if titulo.cobcod >= 10 and 
                                contrato.contnum <> 78811960
                            then val-finan = val-finan + titulo.titvlcob.
                            else val-lebes = val-lebes + titulo.titvlcob.
                        end.    
                        if contrato.contnum = 106136616
                        then val-lebes = 62.63.                
                    end.
                    if contrato.contnum = 34968000
                    then assign
                            val-finan = 0
                            val-lebes = 5810.00
                            .
                    assign
                        tt-contrato.finan = val-finan
                        tt-contrato.lebes = val-lebes
                        .
                    /*if tt-contrato.vltotal > tt-contrato.vlentra
                    then*/ do:    
                        tt-contrato.acres = 
                                (tt-contrato.vltotal /*- tt-contrato.vlentra*/)
                                - (tt-contrato.finan + tt-contrato.lebes).
                    if tt-contrato.acres < 0
                    then do:
                        tt-contrato.desco = (-1) * tt-contrato.acres. 
                        tt-contrato.acres = 0.            
                    end.
                    end.
                    if avail envfinan
                    then tt-contrato.local = "FINAN".
                    else tt-contrato.local = "LEBES".
                    
                    if val-finan = 0 and val-lebes = 0
                        and tt-contrato.clicod <> 11034968
                    then delete tt-contrato.
                    
                end.
                end.
            end.
            /************/
        end.
        end.
        if vindex = 7
        then do:
            def buffer btitulo for titulo.
            for each contrato where  
                     contrato.etbcod = estab.etbcod and
                     contrato.dtinicial = vdata and
                     contrato.crecod = 500 
                     no-lock,
                first btitulo where
                      btitulo.empcod = 19 and
                      btitulo.titnat = no and
                      btitulo.modcod = contrato.modcod and
                      btitulo.etbcod = contrato.etbcod and
                      btitulo.clifor = contrato.clicod and
                      btitulo.titnum = string(contrato.contnum) and
                      btitulo.titpar > 30
                no-lock:      
                /*
                if contrato.contnum = 78811960 then next.
                */
                find first envfinan where
                           envfinan.empcod = 19 and
                           envfinan.titnat = no and
                           envfinan.modcod = contrato.modcod and
                           envfinan.etbcod = contrato.etbcod and
                           envfinan.clifor = contrato.clicod and
                           envfinan.titnum = string(contrato.contnum)
                           no-lock no-error.
                if not avail envfinan
                then do:    
                    find first tt-contrato where
                               tt-contrato.contnum = contrato.contnum
                               no-error.
                    if not avail tt-contrato
                    then do:           
                        create tt-contrato.
                        buffer-copy contrato to tt-contrato.
                    
           
                   /* find first titulo where 
                               titulo.titnat = no and
                               titulo.clifor = tt-contrato.clicod and
                               titulo.titnum = string(tt-contrato.contnum) and
                               titulo.titpar = 0
                               no-lock no-error.
                    if avail titulo 
                    then tt-contrato.vlentra = titulo.titvlcob.
                    */            
                    for each tit_novacao where
                             tit_novacao.ger_contnum = contrato.contnum
                             no-lock:   
                        find first titulo where
                                   titulo.clifor = tit_novacao.ori_clifor and
                                   titulo.titnum = tit_novacao.ori_titnum and
                                   titulo.titpar = tit_novacao.ori_titpar
                                   no-lock no-error.
                        if titulo.cobcod >= 10 
                            and contrato.contnum <> 78811960
                        then tt-contrato.finan = tt-contrato.finan +
                                        titulo.titvlcob.
                        else tt-contrato.lebes = tt-contrato.lebes +
                                        titulo.titvlcob.
                                        
                    end.
                    /*if tt-contrato.vltotal > tt-contrato.vlentra
                    then*/ do:
                    tt-contrato.acres = 
                                (tt-contrato.vltotal /*- tt-contrato.vlentra*/)
                                - (tt-contrato.finan + tt-contrato.lebes).
                    if tt-contrato.acres < 0
                    then do:
                        tt-contrato.desco = (-1) * tt-contrato.acres. 
                        tt-contrato.acres = 0.            
                    end.
                    end.
                    if avail envfinan
                    then tt-contrato.local = "FINAN".
                    else tt-contrato.local = "LEBES".
                    end.
                end.
            end.
        end.
        /****/
    end.
end.

def var varquivo as char.
varquivo = "/admcom/relat/".


if vindex = 1         
then varquivo = varquivo + "vendaprazo-"
            + string(vetbcod,"999") +
            "-" + string(vdti,"99999999") +
            "-" + string(vdtf,"99999999") + ".txt".
else if vindex = 2
then varquivo = varquivo + "vendavista-"
            + string(vetbcod,"999") +
            "-" + string(vdti,"99999999") +
            "-" + string(vdtf,"99999999") + ".txt".
else if vindex = 3
then varquivo = varquivo + "recebimento-"
            + string(vetbcod,"999") +
            "-" + string(vdti,"99999999") +
            "-" + string(vdtf,"99999999") + ".txt".
else if vindex = 4
then varquivo = varquivo + "jurorecebe-"
            + string(vetbcod,"999") +
            "-" + string(vdti,"99999999") +
            "-" + string(vdtf,"99999999") + ".txt".
else if vindex = 5
then varquivo = varquivo + "vendacartao-"
            + string(vetbcod,"999") +
            "-" + string(vdti,"99999999") +
            "-" + string(vdtf,"99999999") + ".txt".
else if vindex = 6
then varquivo = varquivo + "devolucao-"
            + string(vetbcod,"999") +
            "-" + string(vdti,"99999999") +
            "-" + string(vdtf,"99999999") + ".txt".
else if vindex = 7
then varquivo = varquivo + "novacoes-"
            + string(vetbcod,"999") +
            "-" + string(vdti,"99999999") +
            "-" + string(vdtf,"99999999") + ".txt".
             
varquivo = varquivo + string(time).

/**
{mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "70" 
                &Page-Line = "66" 
                &Nom-Rel   = """ """ 
                &Nom-Sis   = """ """ 
                &Tit-Rel   = " v-escolha[vindex] " 
                &Width     = "120"
                &Form      = "frame f-cabcab"}
**/

form header
    wempre.emprazsoc
    space(6) "PAGRE"   at 60
    "Pag.: " at 71 page-number format ">>9" skip
    "           "  v-escolha[vindex]   at 1
    today format "99/99/9999" at 60
    string(time,"hh:mm:ss") at 73
    skip fill("-",80) format "x(80)" skip
    with frame fcab no-label page-top no-box width 137.


output to value(varquivo).
view frame fcab.
                
DISP with frame f-1.

if vindex = 1
then do:
    for each tt-plani where tt-plani.serie <> "V" 
                no-lock with frame f-disp down.
        disp tt-plani.etbcod column-label "Filial"
             tt-plani.numero format ">>>>>>>>9" column-label "Numero"
             tt-plani.serie  format "x(5)" column-label "Serie"
             tt-plani.pladat column-label "Emissao" 
             tt-plani.platot(total) column-label "Valor total"
             tt-plani.seguro(total) column-label "Valor seguro"
             .
    end.    
end.
if vindex = 2
then do:
    for each tt-titulo no-lock with frame f-disp2 down width 150.
    
        disp tt-titulo.etbcod column-label "Filial"
             tt-titulo.clifor column-label "Cliente" format ">>>>>>>>>9"
             tt-titulo.titnum column-label "Numero"  
             tt-titulo.titpar column-label "Parcela" format ">>>>>>9"
             tt-titulo.titdtemi column-label "Emissao"
             tt-titulo.titdtven column-label "Vencimento"
             tt-titulo.titdtpag column-label "Pagamento"
             tt-titulo.titvlcob(total) column-label "Valor cobrado"
                    format "->>>,>>9.99"
             tt-titulo.titvlpag(total) column-label "Valor pago"
                    format "->>>,>>9.99"
         .
    end.
    
    /***
    for each tt-plani where tt-plani.serie <> "V" 
                no-lock with frame f-disp2 down.
        disp tt-plani.etbcod column-label "Filial"
             tt-plani.numero format ">>>>>>>>9" column-label "Numero"
             tt-plani.serie  format "x(15)" column-label "Serie"
             tt-plani.pladat column-label "Emissao" 
             tt-plani.platot(total) column-label "Valor total"
             .
    end.    
    ***/
end.
if vindex = 3
then do:    
    for each tt-titulo no-lock with frame f-disp3 down width 150.
    
        disp tt-titulo.etbcod column-label "Filial"
             tt-titulo.clifor column-label "Cliente" format ">>>>>>>>>9"
             tt-titulo.titnum column-label "Numero"  
             tt-titulo.titpar column-label "Parcela"  format ">>>>>>9"
             tt-titulo.titdtemi column-label "Emissao"
             tt-titulo.titdtven column-label "Vencimento"
             tt-titulo.titdtpag column-label "Pagamento"
             tt-titulo.titvlcob(total) column-label "Valor cobrado"
                    format "->>>,>>9.99"
             tt-titulo.titvlpag(total) column-label "Valor pago"
                    format "->>>,>>9.99"
             tt-titulo.titjuro (total) column-label "Juro"
                    format "->>>,>>9.99"
         .

    end.
end.
 
if vindex = 4
then do:    
    for each tt-titulo no-lock with frame f-disp4 down width 150.
    
        disp tt-titulo.etbcod column-label "Filial"
             tt-titulo.clifor column-label "Cliente" format ">>>>>>>>>9"
             tt-titulo.titnum column-label "Numero"  
             tt-titulo.titpar column-label "Parcela"  format ">>>>>>9"
             tt-titulo.titdtemi column-label "Emissao"
             tt-titulo.titdtven column-label "Vencimento"
             tt-titulo.titdtpag column-label "Pagamento"
             tt-titulo.titvlcob(total) column-label "Valor cobrado"
                    format "->>>,>>9.99"
             tt-titulo.titvlpag(total) column-label "Valor pago"
                    format "->>>,>>9.99"
             tt-titulo.titjuro (total) column-label "Juro"
                    format "->>>,>>9.99"
         .

    end.

end.
if vindex = 5
then do:

    for each tt-plani where tt-plani.serie <> "V" 
                no-lock with frame f-disp5 down.
        disp tt-plani.etbcod column-label "Filial"
             tt-plani.numero format ">>>>>>>>9" column-label "Numero"
             tt-plani.serie  format "x(15)" column-label "Serie"
             tt-plani.pladat column-label "Emissao" 
             tt-plani.platot(total) column-label "Valor total"
             .
    end.    

end.
if vindex = 7
then do:
    for each tt-contrato:
        find clien where clien.clicod = tt-contrato.clicod 
                        no-lock no-error.
        disp tt-contrato.etbcod            column-label "Fil"
             tt-contrato.clicod            column-label "Cliente"
             clien.clinom when avail clien column-label "Nome"
             tt-contrato.contnum           column-label "Contrato"
                    format ">>>>>>>>>9"
             tt-contrato.dtinicial         column-label "Emisao"
             tt-contrato.vltotal(total)    column-label "Valor"
             tt-contrato.vlentra(total)    column-label "Entrada"
             tt-contrato.finan(total)      column-label "O.Finan"
             tt-contrato.lebes(total)      column-label "O.Lebes"
             tt-contrato.acres(total)      column-label "Acrscimo"
             tt-contrato.desco(total)      column-label "Desconto"
             tt-contrato.local             column-label "Cob"
               with width 175
             .
    end.
end.


output close.
run visurel.p(varquivo,"").

if vindex > 0
then do:
    message color red/with
        "Arquivo gerado "
        varquivo
        view-as alert-box.
end.