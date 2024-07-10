{admcab.i}

def var vetbcod-1 like estab.etbcod.
def var vetbcod-2 like estab.etbcod.

def var vdti as date.
def var vdtf as date.
def var vdata as date.

def var vmovtdc like tipmov.movtdc.

update vetbcod-1 at 1 label "     Filial de"
       with frame f-1 1 down side-label width 80
       .

vetbcod-2 = 0.

if vetbcod-1 > 0
then update vetbcod-2 label "Ate" with frame f-1.

disp vetbcod-2 with frame f-1.

if vetbcod-1 > vetbcod-2
then undo.

update vdti at 1 label "  Data inicial" format "99/99/9999"
       vdtf      label "Data final" format "99/99/9999"
       with frame f-1.

if vdti = ? or
   vdtf = ? or
   vdti > vdtf
then undo.
   
vmovtdc = 37.

update vmovtdc at 1 label "Tipo Movimento"
    with frame f-1.
    
find tipmov where tipmov.movtdc = vmovtdc no-lock.
    
disp tipmov.movtnom no-label with frame f-1.    

def temp-table tt-plani
    field tipo as char
    field etbcod like estab.etbcod
    field emite like plani.emite
    field modcod like modal.modcod
    field pladat like plani.pladat
    field plaven like plani.pladat
    field plapag like plani.pladat
    field numero like plani.numero
    field platot like plani.platot
    index i1 tipo etbcod numero
    index i2 tipo etbcod plapag
    .

def temp-table tt-clifor
   field clfcod as int.
def temp-table tt-modal
   field modcod like modal.modcod.
   

for each estab no-lock:
    if vetbcod-1 > 0 and
       (estab.etbcod < vetbcod-1 or
       estab.etbcod > vetbcod-2 )
    then next.
    do vdata = (vdti - 30) to (vdtf + 30):   
    for each plani where plani.etbcod = estab.etbcod and
                         plani.movtdc = vmovtdc and
                         plani.pladat = vdata
                         no-lock:
    
        find first foraut where foraut.forcod = plani.emite no-lock no-error.          if avail foraut then
        for each titulo where
                 titulo.empcod = 19 and
                 titulo.titnat = yes and
                 titulo.modcod = foraut.modcod and
                 titulo.etbcod = estab.etbcod and
                 titulo.clifor = foraut.forcod and
                 titulo.titnum = string(plani.numero)
                 no-lock:    
            if titulo.titdtpag >= vdti and
               titulo.titdtpag <= vdtf
            then do:   
            create tt-plani.
            assign
                tt-plani.tipo   = "Doc. Fiscal"
                tt-plani.emite  = plani.emite
                tt-plani.etbcod = plani.etbcod 
                tt-plani.modcod = titulo.modcod
                tt-plani.numero = plani.numero
                tt-plani.pladat = plani.pladat
                tt-plani.plaven = titulo.titdtven
                tt-plani.plapag = titulo.titdtpag
                tt-plani.platot = plani.platot
                .
            end.
        end.
        
        find first tt-clifor where tt-clifor.clfcod = plani.emite no-error.
        if not avail tt-clifor
        then do:
            create tt-clifor.
            assign
                tt-clifor.clfcod = plani.emite.
        end.
                
        if avail foraut
        then do:
            find first tt-modal where tt-modal.modcod = foraut.modcod no-error.
            if not avail tt-modal
            then do:
                create tt-modal.
                tt-modal.modcod = foraut.modcod.
            end.    
        end.

    end.
    end.
end.                
find first tt-modal where 
           tt-modal.modcod = "LUZ" no-error.
if not avail tt-modal
then do:
    create tt-modal.            
    tt-modal.modcod = "LUZ".
end.    

find first tt-clifor where 
           tt-clifor.clfcod = 100071 no-error.
if not avail tt-clifor
then do:
    create tt-clifor.
    tt-clifor.clfcod = 100071.
end.
find first tt-clifor where 
           tt-clifor.clfcod = 111782 no-error.
if not avail tt-clifor
then do:
    create tt-clifor.
    tt-clifor.clfcod = 111782.
end.
find first tt-clifor where 
           tt-clifor.clfcod = 103444 no-error.
if not avail tt-clifor
then do:
    create tt-clifor.
    tt-clifor.clfcod = 103444.
end.
find first tt-clifor where 
           tt-clifor.clfcod = 111768 no-error.
if not avail tt-clifor
then do:
    create tt-clifor.
    tt-clifor.clfcod = 111768.
end.
find first tt-clifor where 
           tt-clifor.clfcod = 111937 no-error.
if not avail tt-clifor
then do:
    create tt-clifor.
    tt-clifor.clfcod = 111937.
end.

for each estab no-lock:
    if vetbcod-1 > 0 and
       (estab.etbcod < vetbcod-1 or
       estab.etbcod > vetbcod-2 )
    then next.

    for each tt-modal:
        for each tt-clifor:
        do vdata = vdti to vdtf: 
        for each titulo where titulo.clifor = tt-clifor.clfcod and
                          titulo.modcod = tt-modal.modcod and
                          titulo.etbcod = estab.etbcod and
                          titulo.titdtpag = vdata 
                          no-lock:
            find first tt-plani where
                       tt-plani.emite = titulo.clifor and
                       tt-plani.numero = int(titulo.titnum)
                       no-error.
            if not avail tt-plani
            then do:
                create tt-plani.           
                assign
                    tt-plani.tipo   = "Despesa"
                    tt-plani.emite  = titulo.clifor
                    tt-plani.etbcod = titulo.etbcod 
                    tt-plani.modcod = titulo.modcod
                    tt-plani.numero = int(titulo.titnum)
                    tt-plani.pladat = titulo.titdtemi
                    tt-plani.plaven = titulo.titdtven
                    tt-plani.plapag = titulo.titdtpag
                    tt-plani.platot = titulo.titvlcob
                    .
           end.
        end.
        end.
        end.
        do vdata = vdti to vdtf:
        for each titulo where titulo.empcod = 19 and
                          titulo.titnat = yes and
                          titulo.modcod = tt-modal.modcod and
                          titulo.etbcod = estab.etbcod and
                          titulo.titdtpag = vdata
                          no-lock:
            find first tt-plani where
                       tt-plani.emite = titulo.clifor and 
                       tt-plani.numero = int(titulo.titnum)
                       no-error.
            if not avail tt-plani
            then do:

                create tt-plani.
                assign
                    tt-plani.tipo   = "Despesa"
                    tt-plani.emite  = titulo.clifor
                    tt-plani.etbcod = titulo.etbcod 
                    tt-plani.modcod = titulo.modcod
                    tt-plani.numero = int(titulo.titnum)
                    tt-plani.pladat = titulo.titdtemi
                    tt-plani.plaven = titulo.titdtven
                    tt-plani.plapag = titulo.titdtpag
                    tt-plani.platot = titulo.titvlcob
                    .
            end.
        end.
        end.
    end.    
end.

for each tt-plani:
    if tt-plani.plapag < vdti or
       tt-plani.plapag > vdtf
    then delete tt-plani.
end.       

def var varquivo as char.
if opsys = "UNIX"
then varquivo = "/admcom/relat/releeele." + string(time).
else varquivo = "l:\relat\releeele." + string(time).
DEF VAR VTITREL AS CHAR.
vtitrel = "PAGAR".

{mdad.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "80"
            &Page-Line = "64"
            &Nom-Rel   = ""PAG4""
            &Nom-Sis   = """SISTEMA FINANCEIRO - CONTAS A "" + vtitrel "
            &Tit-Rel   = """ENTRADA DE ENERGIA ELÉTRICA"""
            &Width     = "80"
            &Form      = "frame f-cabcab"}
 
disp with frame f-1.
pause 0.
 
for each tt-plani break by tt-plani.etbcod
                        by tt-plani.pladat.
    find forne where forne.forcod = tt-plani.emite no-lock.
    disp tt-plani.tipo     format "x(12)"
         tt-plani.etbcod   column-label "Fil"
         tt-plani.emite    column-label "Emitente"
         forne.fornom no-label format "x(20)" 
         tt-plani.numero format ">>>>>>>>9"  column-label "Numero"
         tt-plani.plapag   column-label "Pagamento"
         tt-plani.platot(sub-total by tt-plani.etbcod)
         with frame fdisp down width 120
         .
end.

output close.

        if opsys = "UNIX"
        then do:
            run visurel.p(varquivo,"").
        end.
        else do:
            {mrod.i} .
        end.
                                