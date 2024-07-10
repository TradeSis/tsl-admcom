{admcab.i}

def var vetbcod like estab.etbcod.
def var vdatini as date.
def var vdatfin as date.

form vetbcod label "Filial"
    help "Informe a Filial ou 0 para todas"
    estab.etbnom no-label
    vdatini at 1  label "Periodo de" format "99/99/9999"
    vdatfin label "Ate" format "99/99/9999"
    with frame f-p1 side-label width 80 1 down
    color with/cyan
    .
     
do on error undo with frame f-p1:
    update vetbcod.
    if vetbcod > 0
    then do:
        find estab where estab.etbcod = vetbcod no-lock no-error.
        if not avail estab
        then do:
            bell.
            message color red/with
                "Filial nao cadastrada."
                view-as alert-box.
            undo.    
        end.
        disp estab.etbnom.
    end.
    else disp "Geral" @ estab.etbnom.
    update vdatini validate(vdatini <> ?,"").
    update vdatfin validate(vdatfin <> ? and vdatfin >= vdatini,"")
           .
end.

def temp-table tt-filial
    field etbcod like estab.etbcod
    field etbnom like estab.etbnom
    field valsai as dec
    field valent as dec
    field valdif as dec
    field valpct as dec
    index i1 etbcod
    .
    
def temp-table tt-ent
    field etbcod like estab.etbcod
    field numero like plani.numero
    field pladat like plani.pladat
    field clifor like agcom.clifor
    field procod like produ.procod
    field valor as dec
    index i1 etbcod pladat clifor
    .
def temp-table tt-sai
    field etbcod like estab.etbcod
    field numero like plani.numero
    field pladat like plani.pladat
    field clifor like agcom.clifor
    field procod like produ.procod
    field valor as dec
    index i1 etbcod pladat clifor
    .
def temp-table tt-ori
    field etbcod like estab.etbcod
    field numero like plani.numero
    field pladat like plani.pladat
    field clifor like agcom.clifor
    field procod like produ.procod
    field valor as dec
    index i1 etbcod pladat clifor
    .
    
     
def var ventrada as dec.
def var vsaida as dec.
def var vorigem as dec.
def buffer bplani for plani.
def buffer cplani for plani.
def buffer bmovim for movim.
def buffer cmovim for movim.

format "Processando ........>>>  "
    with frame f-processa 1 down no-box
    centered row 10 no-label.
    
for each estab where ( if vetbcod > 0
            then estab.etbcod = vetbcod else true) no-lock:
    assign ventrada = 0 vsaida = 0 vorigem = 0.
    disp estab.etbcod with frame f-processa.
    pause 0.
    for each ctdevven where ctdevven.etbcod = estab.etbcod and
                            ctdevven.pladat >= vdatini and
                            ctdevven.pladat <= vdatfin and
                            ctdevven.placod-ven <> 0
                             no-lock break by etbcod by placod :
        disp ctdevven.pladat with frame f-processa.
        pause 0.
        if first-of(placod)
        then do: 
            find first plani where plani.movtdc = ctdevven.movtdc and
                          plani.etbcod = ctdevven.etbcod and
                          plani.placod = ctdevven.placod
                          no-lock no-error.
            if  avail plani
            then  do:
                disp plani.numero with frame f-processa.
                pause 0.
                for each movim where movim.movtdc = plani.movtdc and
                             movim.etbcod = plani.etbcod and
                             movim.placod = plani.placod
                             no-lock:
                    find produ where produ.procod = movim.procod no-lock.
                    if produ.catcod <> 41
                    then next.
                    ventrada = ventrada + (movim.movpc * movim.movqtm).
                    create tt-ent.
                    assign
                        tt-ent.etbcod = estab.etbcod
                        tt-ent.numero = plani.numero
                        tt-ent.clifor = movim.ocnum[7]                    
                        tt-ent.pladat = plani.pladat
                        tt-ent.procod = movim.procod
                        tt-ent.valor  = movim.movpc * movim.movqtm
                        .
                end.
            end.
        end.
        find first bplani where bplani.movtdc = ctdevven.movtdc-ven and
                          bplani.etbcod = ctdevven.etbcod-ven and
                          bplani.placod = ctdevven.placod-ven 
                          no-lock no-error.
        find first cplani where cplani.movtdc = ctdevven.movtdc-ori and
                          cplani.etbcod = ctdevven.etbcod-ori and
                          cplani.placod = ctdevven.placod-ori
                          no-lock no-error.
        /*
        if avail plani
        then                  
        for each movim where movim.movtdc = plani.movtdc and
                             movim.etbcod = plani.etbcod and
                             movim.placod = plani.placod
                             no-lock:
            find produ where produ.procod = movim.procod no-lock.
            if produ.catcod <> 41
            then next.
            ventrada = ventrada + (movim.movpc * movim.movqtm).
            create tt-ent.
            assign
                tt-ent.etbcod = estab.etbcod
                tt-ent.numero = plani.numero
                tt-ent.clifor = movim.ocnum[7]                    
                tt-ent.pladat = plani.pladat
                tt-ent.procod = movim.procod
                tt-ent.valor  = movim.movpc * movim.movqtm
                .
        end.
        */
        
        if avail bplani
        then               
        for each bmovim where bmovim.movtdc = bplani.movtdc and
                             bmovim.etbcod = bplani.etbcod  and
                             bmovim.placod = bplani.placod
                             no-lock:
            find produ where produ.procod = bmovim.procod no-lock.
            if produ.catcod <> 41
            then next.
            create tt-sai.
            assign
                tt-sai.etbcod = estab.etbcod
                tt-sai.numero = bplani.numero
                tt-sai.clifor = bplani.desti 
                tt-sai.pladat = bplani.pladat
                tt-sai.procod = bmovim.procod
                tt-sai.valor  = bmovim.movpc * bmovim.movqtm
                .
             
            vsaida = vsaida + (bmovim.movpc * bmovim.movqtm).
        end.
        if avail cplani
        then
        for each cmovim where cmovim.movtdc = cplani.movtdc and
                             cmovim.etbcod = cplani.etbcod and
                             cmovim.placod = cplani.placod
                             no-lock:
            find produ where produ.procod = cmovim.procod no-lock.
            if produ.catcod <> 41
            then next.
            vorigem = vorigem + (cmovim.movpc * cmovim.movqtm).
            create tt-ori.
            assign
                tt-ori.etbcod = estab.etbcod
                tt-ori.numero = cplani.numero
                tt-ori.clifor = cplani.desti 
                tt-ori.pladat = cplani.pladat
                tt-ori.procod = cmovim.procod
                tt-ori.valor  = cmovim.movpc * cmovim.movqtm
                .
 
        end.

    end.
    find first tt-filial where tt-filial.etbcod = estab.etbcod no-error.
    if not avail tt-filial
    then do:
            create tt-filial.
            assign
                tt-filial.etbcod = estab.etbcod
                tt-filial.etbnom = estab.etbnom  
                .
    end.
    assign    
            tt-filial.valsai = tt-filial.valsai + vsaida
            tt-filial.valent = tt-filial.valent + ventrada
            .
end.
hide frame f-processa.

form tt-filial.etbcod no-label
     tt-filial.etbnom column-label "Filial"    format "x(20)"
     tt-filial.valsai column-label "Venda"     format ">>,>>>,>>9.99"
     tt-filial.valent column-label "Devolucao" format ">>,>>>,>>9.99"
     tt-filial.valdif column-label "Diferenca" format "->,>>>,>>9.99"
     tt-filial.valpct column-label "   %  "    format ">>>,>>9.99%"
     with frame f-filial width 100 down
     .
     
form tt-ent.pladat     column-label "Emissao" format "99/99/9999"
     tt-ent.clifor     column-label "Cliente" format ">>>>>>>>9"
     tt-ent.numero     column-label "Numero"  format ">>>>>>>>9"
     tt-ent.procod     column-label "Produto" format ">>>>>>9"
     produ.pronom      column-label "Descricao" format "x(30)"
     v-valent as dec   column-label "Entrada" format ">>,>>>,>>9.99"
     v-valsai as dec   column-label "Saida"   format ">>,>>>,>>9.99"
     tvaldif  as dec   column-label "Diferenca" format "->,>>>,>>9.99"
     tvalpct  as dec   column-label "  % " format ">>>,>>9.99%"      
     with frame f-filial1 width 130 down
     .
     
def var tvalsai as dec.
def var tvalent as dec.
def var t1valent as dec.
def var t1valsai as dec.
def var t1valdif as dec.
def var t1valpct as dec.

form "         T O T A I S      "
     tvalsai format ">>,>>>,>>9.99"
     tvalent format ">>,>>>,>>9.99"
     tvaldif format "->,>>>,>>9.99"
     tvalpct format ">>>,>>9.99%"
     with frame f-tot 1 down no-box row 21 no-label.

     
def var ttvalent as dec.
def var ttvalsai as dec.
def var ttvaldif as dec.
def var ttvalpct as dec.
def var varquivo as char.

if opsys = "UNIX"
then  varquivo = "../relat/ctdevcon" + string(vetbcod,"999").
else  varquivo = "l:~\relat~\ctdevcon" + string(vetbcod,"999").

{mdadmcab.i
            &Saida     = "value(varquivo)"
            &Page-Size = "0"
            &Cond-Var  = "120"
            &Page-Line = "66"
            &Nom-Rel   = ""ctdevcon""
            &Nom-Sis   = """SISTEMA DE COBRANCA"""
            &Tit-Rel   = """ TROCA DE CONFECCAO """
            &Width     = "120"
            &Form      = "frame f-cabcab"}

DISP WITH FRAME F-P1.

assign
    tvalent = 0 tvalsai = 0 tvaldif = 0 tvalpct = 0
    t1valent = 0 t1valsai = 0 t1valdif = 0 t1valpct = 0
    .

if vetbcod = 0
then do:
     for each tt-filial where valent <> 0 :
        tt-filial.valdif = tt-filial.valsai - tt-filial.valent.
        tt-filial.valpct = (tt-filial.valdif / tt-filial.valent) * 100. 
        disp tt-filial.etbcod
             tt-filial.etbnom
             tt-filial.valent
             tt-filial.valsai
             tt-filial.valdif
             tt-filial.valpct
             with frame f-filial
              .
        down with frame f-filial.
        assign
            t1valent = t1valent + tt-filial.valent
            t1valsai = t1valsai + tt-filial.valsai
            .
    end.
    put fill ("-",130) format "x(100)" skip.
    t1valdif = t1valsai - t1valent.
    t1valpct = (t1valdif / t1valsai) * 100.
    disp "      T O T A I S " @ tt-filial.etbnom
         t1valent @ tt-filial.valent
         t1valsai @ tt-filial.valsai
         t1valdif @ tt-filial.valdif
         t1valpct @ tt-filial.valpct
        with frame f-filial.
end.
else do:
    for each tt-ent break by tt-ent.etbcod 
                            by tt-ent.pladat  
                                by tt-ent.clifor   .
        find produ where produ.procod = tt-ent.procod no-lock.
        if first-of(tt-ent.pladat)
        then disp tt-ent.pladat with frame f-filial1.
        if first-of(tt-ent.clifor)
        then disp tt-ent.clifor with frame f-filial1.
        
        disp  tt-ent.procod
             produ.pronom
             tt-ent.valor  @ v-valent
             with frame f-filial1.
        down with frame f-filial1.
        tvalent = tvalent + tt-ent.valor.
        ttvalent = ttvalent + tt-ent.valor.
        if last-of(tt-ent.clifor)
        then do:
            for each tt-sai where tt-sai.etbcod = tt-ent.etbcod and   
                                  tt-sai.pladat = tt-ent.pladat and
                                  tt-sai.clifor = tt-ent.clifor
                                      .
                find produ where produ.procod = tt-sai.procod no-lock.
                disp tt-sai.numero @ tt-ent.numero
                     tt-sai.procod @ tt-ent.procod
                     produ.pronom
                     tt-sai.valor  @ v-valsai
                     with frame f-filial1.
                down with frame f-filial1.
                tvalsai = tvalsai + tt-sai.valor.
                ttvalsai = ttvalsai + tt-sai.valor. 
            end.
            tvaldif = tvalsai - tvalent.
            tvalpct = (tvalent / tvalsai) * 100.
            put fill ("-",130) format "x(120)" skip.
            disp "    S U B T O T A L "   @ produ.pronom
                 tvalent @ v-valent
                 tvalsai @ v-valsai
                 tvaldif 
                 tvalpct
                 with frame f-filial1.
            down with frame f-filial1.     
            assign tvalent = 0 tvalsai = 0.
            put space(30) fill ("=",130) format "x(90)" skip.
        end.

    end.
    put fill ("=",130) format "x(120)" skip.
    ttvaldif = ttvalsai - ttvalent.
    ttvalpct = (ttvalent / ttvalsai) * 100.
    disp "     T O T A L " @ produ.pronom
         ttvalent @ v-valent
         ttvalsai @ v-valsai
         ttvaldif @ tvaldif
         ttvalpct @ tvalpct
         with frame f-filial1.
                                   

end.
disp "". pause 0.
output close.
/*
unix silent cat value(varquivo) > /dev/lp0 .
*/    
if opsys = "UNIX"
then do:
    run visurel.p (input varquivo, input "").
end.
else do:
    {mrod.i}
end. 
return.                    
