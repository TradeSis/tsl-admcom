{admcab.i}

def var vdti as date.
def var vdtf as date.
def var vipi as dec.

def temp-table tt-ipi
    field etbcod like estab.etbcod
    field pladat like plani.pladat
    field dtincl like plani.dtincl
    field numero like plani.numero
    field serie  like plani.serie
    field emite like plani.emite
    field desti like plani.desti
    field procod like movim.procod
    field pronom like produ.pronom
    field movpc  like movim.movpc
    field movqtm like movim.movqtm
    field movalipi like movim.movalipi
    field movipi like movim.movipi
    field fornom like forne.fornom
    field movsubst as dec  format ">>,>>>,>>9.99"
    index i1 emite serie numero procod
    .
    
update vdti label "Periodo de"
       vdtf label "Ate"
       with frame f1 side-label width 80
       1 down.

for each estab no-lock:
    disp " Processando...  " estab.etbcod 
    with frame f-proc 1 down width 80 row 10 centered no-box
    color message.
    pause 0.
    for each plani where plani.movtdc = 4 and
                         plani.etbcod = estab.etbcod and
                         plani.desti = estab.etbcod and
                         plani.pladat >= vdti and
                         plani.pladat <= vdtf and
                         plani.ipi > 0
                         no-lock .
        disp plani.numero format ">>>>>>>>9" 
         plani.pladat with frame f-proc
        .
        pause 0.
        find forne where forne.forcod = plani.emite no-lock no-error.
        if not avail forne then next.
        vipi = 0.
        for each movim where movim.etbcod = plani.etbcod and
                             movim.placod = plani.placod and
                             movim.movtdc = plani.movtdc and
                             movim.movdat = plani.pladat and
                             movim.movipi > 0
                             no-lock.
            find produ where produ.procod = movim.procod no-lock no-error.
            if not avail produ then next.
            find first tt-ipi where
                       tt-ipi.emite = plani.emite and
                       tt-ipi.serie = plani.serie and
                       tt-ipi.numero = plani.numero and
                       tt-ipi.procod = movim.procod
                       no-error.
            if not avail tt-ipi
            then do:
                create tt-ipi.
                assign
                    tt-ipi.emite = plani.emite
                    tt-ipi.serie = plani.serie
                    tt-ipi.numero = plani.numero
                    tt-ipi.procod = movim.procod
                    tt-ipi.pronom = produ.pronom
                    tt-ipi.etbcod = movim.etbcod 
                    tt-ipi.pladat = plani.pladat
                    tt-ipi.dtincl = plani.dtincl
                    tt-ipi.desti  = plani.desti
                    tt-ipi.movpc  = movim.movpc
                    tt-ipi.movqtm = movim.movqtm
                    tt-ipi.movalipi = movim.movalipi
                    tt-ipi.movipi = movim.movipi
                    tt-ipi.fornom = forne.fornom
                    tt-ipi.movsubst = movim.movsubst
                    .   
            end.
        end.    
    end.
end.

def var varquivo as char.
varquivo = "/admcom/relat/nfentrada-com-ipi." + string(time).

    {mdadmcab.i &Saida     = "value(varquivo)" 
                &Page-Size = "64" 
                &Cond-Var  = "180" 
                &Page-Line = "66" 
                &Nom-Rel   = ""nfentrada-com-ipi"" 
                &Nom-Sis   = """WMS """ 
                &Tit-Rel   = """ RELATORIO ENTRADAS COM IPI """
                &Width     = "180" 
                &Form      = "frame f-cabcab"}

    
    disp with frame f1.
 
for each tt-ipi where tt-ipi.emite > 0 no-lock:
    disp tt-ipi.emite
         tt-ipi.fornom format "x(25)"
         tt-ipi.serie
         tt-ipi.numero format ">>>>>>>>9"
         tt-ipi.pladat format "99/99/99"
         tt-ipi.dtincl format "99/99/99"
         tt-ipi.desti
         tt-ipi.procod format ">>>>>>>>9"
         tt-ipi.pronom  format "x(25)"
         tt-ipi.movpc
         tt-ipi.movqtm
         (tt-ipi.movpc * tt-ipi.movqtm)(total) column-label "Val.Total"
         format ">>,>>>,>>9.99"
         tt-ipi.movipi(total) format ">,>>>,>>9.99"
         tt-ipi.movsubst(total) format ">,>>>,>>9.99" column-label "ICMS ST"
         with frame f-disp down width 200
         .
end.
    
output close.
    
message color red/with
    "Arquivo gerado: " varquivo
    view-as alert-box.
    
run visurel.p (input varquivo, input "").
                      
