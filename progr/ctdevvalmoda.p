/*
#1 P2K - 18.10.2017
*/
{admcab.i}

def var vetbcod like estab.etbcod.
def var vdatini as date.
def var vdatfin as date.

def buffer ctitulo for titulo.

form vetbcod label "Filial"
    help "Informe a Filial ou 0 para todas"
    estab.etbnom no-label
    vdatini at 1  label "Periodo de" format "99/99/9999"
    vdatfin label "Ate" format "99/99/9999"
    with frame f-p1 side-label width 80 1 down color with/cyan.
     
do on error undo with frame f-p1:
    update vetbcod.
    if vetbcod > 0
    then do:
        find estab where estab.etbcod = vetbcod no-lock no-error.
        if not avail estab
        then do:
            message color red/with "Filial nao cadastrada." view-as alert-box.
            undo.    
        end.
        disp estab.etbnom.
    end.
    else disp "Geral" @ estab.etbnom.
    update vdatini validate(vdatini <> ?,"").
    update vdatfin validate(vdatfin <> ? and vdatfin >= vdatini,"").
end.

def temp-table tt-filial
    field etbcod like estab.etbcod
    field etbnom like estab.etbnom
    field valvista as dec
    field valprazo as dec
    field valpago  as dec
    field valdevol  as dec
    field qtd-plani  as int
    index i1 etbcod.

def temp-table tt-datav
    field pladat as date
    field conta  as int
    field nfvenda as int
    field nfdevol as int
    field valdevolvido as dec.
    
def temp-table tt-datap
    field pladat as date
    field conta  as int
    field contrato as dec
    field nfvenda as int
    field dtvenda as date
    field nfdevol as int
    field valquitado as dec
    field valdevolvido as dec.
    
def var ventrada as dec.
def var vsaida as dec.
def var vorigem as dec.
def buffer bplani for plani.
def buffer cplani for plani.
def buffer bmovim for movim.
def buffer cmovim for movim.
def var vtitdev as dec.
def var vtitpag as dec.
def var vvista as dec.
def var vprazo as dec.
def var vclifor as int.
def var vcontrato like contnf.contnum.
def var vconta-plani as integer.
def var tot-qtd-plani as integer.

def temp-table tt-plaqtd
    field placod like plani.placod.
    
format "Processando ........>>>  "
    with frame f-processa 1 down no-box
    centered row 10 no-label.
    
def var vok-moda as log .

for each estab where ( if vetbcod > 0
            then estab.etbcod = vetbcod else true) no-lock:
    assign ventrada = 0 vsaida = 0 vorigem = 0.
    disp estab.etbcod with frame f-processa.
    pause 0.
    assign
        ventrada = 0 vsaida = 0 vvista = 0 vprazo = 0
        vtitdev = 0 vtitpag = 0.
        
    vconta-plani = 0.
    for each tt-plaqtd: delete tt-plaqtd. end.
    
    for each ctdevven where ctdevven.etbcod = estab.etbcod and
                            ctdevven.pladat >= vdatini and
                            ctdevven.pladat <= vdatfin and
                            ctdevven.placod-ven = 0  /*#1and
                            ctdevven.serie = "1"*/
                             no-lock break by ctdevven.placod :
        disp ctdevven.pladat with frame f-processa.
        pause 0.
        /*
        if first-of(etbcod)
        then assign vconta-plani = 0.

        if first-of(placod)
        then assign vconta-plani = vconta-plani + 1.
        */
        /**
        find first tt-plaqtd where
                   tt-plaqtd.placod = ctdevven.placod
                   no-lock no-error.
        if not avail tt-plaqtd
        then do:
            create tt-plaqtd.
            tt-plaqtd.placod = ctdevven.placod.
            vconta-plani = vconta-plani + 1.
        end.
        **/            
        vok-moda = no.
        if first-of(ctdevven.placod)
        then do: 
            find first plani where plani.movtdc = ctdevven.movtdc and
                                   plani.etbcod = ctdevven.etbcod and
                                   plani.placod = ctdevven.placod /*#1 and
                                   plani.serie = "1"*/
                          no-lock no-error.
            if not avail plani
            then next.
            disp plani.numero with frame f-processa.
            pause 0.
            vok-moda = no.
            for each movim where movim.movtdc = plani.movtdc and
                                 movim.etbcod = plani.etbcod and
                                 movim.placod = plani.placod
                             no-lock:
                vclifor = movim.ocnum[7].
                ventrada = ventrada + (movim.movpc * movim.movqtm).
                find produ where produ.procod = movim.procod no-lock no-error.
                if avail produ 
                    and produ.catcod = 41
                then vok-moda = yes.    
            end.
        end.
        if not vok-moda
        then next.
        
        find first tt-plaqtd where
                   tt-plaqtd.placod = ctdevven.placod
                   no-lock no-error.
        if not avail tt-plaqtd
        then do:
            create tt-plaqtd.
            tt-plaqtd.placod = ctdevven.placod.
            vconta-plani = vconta-plani + 1.
        end. 
        
        find first bplani where bplani.movtdc = ctdevven.movtdc-ven and
                          bplani.etbcod = ctdevven.etbcod-ven and
                          bplani.placod = ctdevven.placod-ven 
                          no-lock no-error.
        
        find first cplani where cplani.movtdc = ctdevven.movtdc-ori and
                          cplani.etbcod = ctdevven.etbcod-ori and
                          cplani.placod = ctdevven.placod-ori
                          no-lock no-error.
        if avail bplani
        then
            for each bmovim where bmovim.movtdc = bplani.movtdc and
                             bmovim.etbcod = bplani.etbcod  and
                             bmovim.placod = bplani.placod
                             no-lock:
                vsaida = vsaida + (bmovim.movpc * bmovim.movqtm).
            end.

        if avail cplani
        then do:
            for each cmovim where cmovim.movtdc = cplani.movtdc and
                             cmovim.etbcod = cplani.etbcod and
                             cmovim.placod = cplani.placod
                             no-lock:
                vorigem = vorigem + (cmovim.movpc * cmovim.movqtm).
            end.              
            find first contnf where contnf.etbcod = cplani.etbcod and
                              contnf.placod = cplani.placod
                              no-lock no-error.
            vclifor = cplani.desti.
            if avail contnf
            then vcontrato = contnf.contnum.
            else vcontrato = cplani.numero.
            find first tt-datap where 
                   tt-datap.pladat = ctdevven.pladat and
                   tt-datap.nfdevol = ctdevven.numero and
                   tt-datap.conta = vclifor   and
                   tt-datap.contrato = vcontrato
                    no-error.
            if not avail tt-datap
            then do:
                create tt-datap.
                assign
                    tt-datap.pladat = ctdevven.pladat
                    tt-datap.nfdevol = ctdevven.numero
                    tt-datap.conta = vclifor
                    tt-datap.contrato = vcontrato.
            end. 
            tt-datap.nfvenda = cplani.numero.
            tt-datap.dtvenda = cplani.pladat.
            
            if avail contnf
            then                    
            for each titulo where titulo.empcod = 19 and
                                  titulo.titnat = no and
                                  titulo.modcod = "CRE" and
                                  titulo.etbcod = cplani.etbcod and
                                  titulo.clifor = cplani.desti  and
                                  titulo.titnum = string(vcontrato) 
                                  no-lock:
                                  
                if titulo.titdtemi = cplani.pladat and titulo.moecod = "DEV"
                    and titulo.etbcob = ?
                then assign
                   vtitpag = vtitpag + titulo.titvlcob
                   tt-datap.valquitado = tt-datap.valquitado + titulo.titvlcob
                   .
                else if titulo.etbcob = cplani.etbcod 
                        and titulo.moecod <> "DEV" 
                        and (titulo.titdtpag < plani.pladat
                             or (titulo.titdtpag = plani.pladat and
                                 titulo.titpar = 0))
                then 
                assign
                 tt-datap.valdevolvido = tt-datap.valdevolvido + titulo.titvlpag
                 vtitdev = vtitdev + titulo.titvlpag.
 
            end.
            else do:
                find first ctitulo where ctitulo.empcod = 19 and
                                        ctitulo.titnat = yes and
                                        ctitulo.modcod = "DEV" and
                                        ctitulo.etbcod = cplani.etbcod and
                                        ctitulo.clifor = cplani.desti  and
                                        ctitulo.titnum = string(vcontrato)
                                        no-lock no-error.
                if avail ctitulo
                then do:
                    for each titulo where titulo.empcod = 19 and
                                  titulo.titnat = yes and
                                  titulo.modcod = "DEV" and
                                  titulo.etbcod = cplani.etbcod and
                                /*titulo.clifor = cplani.desti  and*/
                                  titulo.titnum = string(vcontrato) and
                                  titulo.titdtpag <> ? 
                                  no-lock:
                        assign
                 tt-datap.valdevolvido = tt-datap.valdevolvido + titulo.titvlcob
                 vtitdev = vtitdev + titulo.titvlpag.
 
                    end.
                end.
                else do:
                    find first titulo where titulo.empcod = 19 and
                                  titulo.titnat = yes and
                                  titulo.modcod = "DEV" and
                                  titulo.etbcod = cplani.etbcod and
                                  titulo.titnum = string(vcontrato) 
                                  no-lock no-error.
                    if avail titulo
                    then do:
                        for each titulo where titulo.empcod = 19 and
                                  titulo.titnat = yes and
                                  titulo.modcod = "DEV" and
                                  titulo.etbcod = cplani.etbcod and
                                  /*titulo.clifor = cplani.desti  and*/
                                  titulo.titnum = string(vcontrato) 
                                  no-lock:
                        assign
                 tt-datap.valdevolvido = tt-datap.valdevolvido + titulo.titvlcob
                 vtitdev = vtitdev + titulo.titvlpag.
                        end.
                    end.
                    else do:
                        for each titulo where titulo.empcod = 19 and
                                  titulo.titnat = yes and
                                  titulo.modcod = "DEV" and
                                  titulo.etbcod = cplani.etbcod and
                                  /*titulo.clifor = cplani.desti  and*/
                                  titulo.titnum = string(ctdevven.numero) 
                                  no-lock:
                           assign
                 tt-datap.valdevolvido = tt-datap.valdevolvido + titulo.titvlcob
                 vtitdev = vtitdev + titulo.titvlpag.
                        end.
                     end.
                end.
            end.
            if cplani.crecod = 1
            then vvista = vvista + cplani.platot.
            else vprazo = vprazo + cplani.platot. 
        end.
    end.
    find first tt-filial where tt-filial.etbcod = estab.etbcod no-error.
    if not avail tt-filial
    then do:
        create tt-filial.
        assign
            tt-filial.etbcod = estab.etbcod
            tt-filial.etbnom = estab.etbnom.
    end.
    assign    
        tt-filial.valvista  = tt-filial.valvista + vvista
        tt-filial.valprazo  = tt-filial.valprazo + vprazo
        tt-filial.valpago   = tt-filial.valpago  + vtitpag
        tt-filial.valdevol  = tt-filial.valdevol + vtitdev
        tt-filial.qtd-plani = tt-filial.qtd-plani + vconta-plani.
end.
hide frame f-processa.

form tt-filial.etbcod no-label
     tt-filial.etbnom    column-label "Filial"    format "x(20)"
     tt-filial.valvista  column-label "A Vista"   format ">>,>>>,>>9.99"
     tt-filial.valprazo  column-label "A Prazo"   format ">>,>>>,>>9.99"
     tt-filial.valpago   column-label "Quitado"   format ">>,>>>,>>9.99"
     tt-filial.valdevol  column-label "Devolvido" format ">>>,>>9.99"
     tt-filial.qtd-plani column-label "QTD Devol" format ">>>>>9"
     with frame f-filial width 100 down.

form tt-datap.pladat    column-label "Emissao"  format "99/99/9999"
     tt-datap.contrato  column-label "Contrato" format ">>>>>>>>>9"
     tt-datap.conta     column-label "Conta"    format ">>>>>>>>>9"
     tt-datap.nfvenda   column-label "NFVenda"  format ">>>>>>>>9"
     tt-datap.dtvenda   column-label "DtVenda"  format "99/99/9999"
     tt-datap.nfdevol   column-label "NFEntrada" format ">>>>>>>>9"
     tt-datap.valquitado column-label "Quitado" format ">>,>>>,>>9.99"
     tt-datap.valdevolvido column-label "Devolvido" format ">>,>>>,>>9.99"
     with frame f-datap down no-box width 100.

def var tvalvista as dec.
def var tvalprazo as dec.
def var tvalpago  as dec.
def var tvaldevol as dec.
def var ttvalent as dec.
def var ttvalsai as dec.
def var ttvaldif as dec.
def var ttvalpct as dec.
def var varquivo as char.

if opsys = "UNIX"
then varquivo = "../relat/ctdevval" + string(vetbcod,"999") +
                "." + string(time).
else varquivo = "l:~\relat~\ctdevval" + string(vetbcod,"999").

{mdadmcab.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "100"
            &Page-Line = "66"
            &Nom-Rel   = ""ctdevval""
            &Nom-Sis   = """SISTEMA DE COBRANCA"""
            &Tit-Rel   = """ DEVOLUCAO DE MODA """
            &Width     = "100"
            &Form      = "frame f-cabcab"}

DISP WITH FRAME F-P1.

assign
    tvalvista = 0
    tvalvista = 0
    tvalpago  = 0
    tvaldevol = 0.

def var tquitado as dec.
def var ttdevolvido as dec.
def var tdevolvido as dec.
def var ttquitado as dec.

if vetbcod = 0
then do:
     for each tt-filial where tt-filial.qtd-plani > 0 :
        disp tt-filial.etbcod
             tt-filial.etbnom
             tt-filial.valvista
             tt-filial.valprazo
             tt-filial.valpago
             tt-filial.valdevol
             tt-filial.qtd-plani
             with frame f-filial.
        down with frame f-filial.
        assign
            tvalvista = tvalvista + tt-filial.valvista
            tvalprazo = tvalprazo + tt-filial.valprazo
            tvalpago  = tvalpago  + tt-filial.valpago
            tvaldevol = tvaldevol + tt-filial.valdevol
            tot-qtd-plani = tot-qtd-plani + tt-filial.qtd-plani.
    end.
    put fill ("-",100) format "x(100)" skip.
    disp tvalvista     @ tt-filial.valvista
         tvalprazo     @ tt-filial.valprazo
         tvalpago      @ tt-filial.valpago
         tvaldevol     @ tt-filial.valdevol
         tot-qtd-plani @ tt-filial.qtd-plani
         with frame f-filial.
end.                  
else do:
    for each tt-datap break by tt-datap.pladat 
                            by tt-datap.conta
                            by tt-datap.contrato:
        if first-of(tt-datap.pladat)
        then disp tt-datap.pladat with frame f-datap.
        /*if first-of(tt-datap.conta)
        then*/ disp tt-datap.conta with frame f-datap.
        disp tt-datap.contrato
             tt-datap.nfvenda
             tt-datap.dtvenda
             tt-datap.nfdevol
             tt-datap.valquitado
             tt-datap.valdevolvido
             with frame f-datap.
        down with frame f-datap.
        assign
            tquitado = tquitado + tt-datap.valquitado
            ttquitado = ttquitado + tt-datap.valquitado
            tdevolvido = tdevolvido + tt-datap.valdevolvido
            ttdevolvido = ttdevolvido + tt-datap.valdevolvido.    
    end.
    put fill ("=",150) format "x(100)" skip.
    disp ttquitado @ tt-datap.valquitado
         ttdevolvido @ tt-datap.valdevolvido
         with frame f-datap.
end.

disp "". pause 0.
output close.
if opsys = "UNIX"
then run visurel.p (input varquivo, input "").
else do:
    {mrod.i}
end.

