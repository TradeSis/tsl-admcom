{admcab.i}

def temp-table tt-titulo like fin.titulo.
def temp-table tt-pagdia like fin.titulo.

def temp-table tt-cli
    field etbcod like estab.etbcod
    field clicod like clien.clicod
    field etbcob like estab.etbcod
    field cxacod like fin.titulo.cxacod
    index i1 etbcob clicod.
    
def var vcxacod like fin.titulo.cxacod.

def var vv as char format "x(15)" extent 3
    init["Vencidos","A Vencer","Ambos"] .
def var vdtaux as date.
vdtaux = date(month(today) + 1,01,if month(today) = 12
                then year(today) + 1 else year(today)) - 1.
                
def var varquivo as char.
def var vetbi   like estab.etbcod.
def var vetbf   like estab.etbcod.
def var vdti as date.
def var vdtf as date.
def var vdata as date.
def var vanalitico as log label "Analitico/Sintetico"
                     format "Analitico/Sintetico" init yes.
def var v-desc as char.

def var vfinan as dec.
def var v-perdido as dec no-undo.
def var vclinom   like clien.clinom.
def var vlimite as dec format ">>,>>>,>>>,>>9.99" init 0.
def var auxlimite as dec format ">>>,>>>,>>>,>>9.99".

def var vtotal as dec.
def var vqtde  as int.
def var vt-cli as dec.
def var vt-val as dec.
def var vtt-cli as dec.
def var vtt-val as dec.


form
    skip 
    vetbi  label   "Filial"    
    vetbf  label   "Ate"
    skip
    vcxacod label "Caixa"
    skip
    vdti   label   "Perido de"   format "99/99/9999"
    vdtf   label   "Ate"         format "99/99/9999"
    with frame f-etb side-label 1 down width 80.

form "Executando  filtro... " with frame f-disp 1 down side-label.
form "Montando relatorio... " with frame f-disp1 1 down side-label.
form with frame f-rel.
    
def var vindex as int. 
def var vt-ppag as int.
def var vt-vpag as dec.
def var vtt-ppag as int.
def var vtt-vpag as dec.

   
repeat:
    for each tt-titulo :
        delete tt-titulo.
    end.
        
    vetbi = 0.
    vetbf = 0.
    vdti = today.
    vdtf = today.
    
    update vetbi
           with frame f-etb.
    vetbf = vetbi.
    if vetbi > 0
    then update vetbf with frame f-etb.
    
    if vetbf < vetbi then undo.
    
    vcxacod = 0.
    if vetbi = vetbf
    then update vcxacod with frame f-etb.
    
    update vdti with frame f-etb.
    vdtf = vdti.
    update vdtf with frame f-etb.
    if vdtf < vdti then undo.
     
    disp vv with frame f-vv 1 down no-label centered.
    choose field vv with frame f-vv.
    vindex = frame-index.
    
    for each estab no-lock:
        if vetbi > 0 and
            (estab.etbcod < vetbi or
             estab.etbcod > vetbf)
        then next.     
        disp estab.etbcod with frame f-disp. 
        do vdata = vdti to vdtf:
            disp vdata with frame f-disp.
            
            for each fin.titulo where 
                     fin.titulo.etbcobra = estab.etbcod and
                     fin.titulo.titdtpag = vdata
                     no-lock:

                if fin.titulo.titpar = 0 then next.
                if fin.titulo.modcod <> "CRE" then next.
                if fin.titulo.clifor = 1 then next.
                if fin.titulo.clifor = 1513 then next.
                
                if vcxacod > 0 and fin.titulo.cxacod <> vcxacod
                then next.
                 
                find first tt-cli where
                           tt-cli.etbcob = estab.etbcod and
                           tt-cli.clicod = fin.titulo.clifor
                           no-error.
                if not avail tt-cli
                then do:
                    create tt-cli.
                    assign
                        tt-cli.clicod = fin.titulo.clifor
                        tt-cli.etbcod = fin.titulo.etbcod
                        tt-cli.etbcob = estab.etbcod
                        tt-cli.cxacod = fin.titulo.cxacod
                    .
                end.
                find first tt-pagdia of fin.titulo no-lock no-error.
                if not avail tt-pagdia
                then do:
                    create tt-pagdia.
                    buffer-copy fin.titulo to tt-pagdia.
                end.
            end.

            for each d.titulo where
                     d.titulo.etbcobra = estab.etbcod and
                     d.titulo.titdtpag = vdata
                     no-lock:
                
                if d.titulo.titpar = 0 then next.
                if d.titulo.modcod <> "CRE" then next.
                if d.titulo.clifor = 1 then next.
                if d.titulo.clifor = 1513 then next.

                if vcxacod > 0 and d.titulo.cxacod <> vcxacod
                then next.
 
                find first tt-cli where
                           tt-cli.etbcob = estab.etbcod and
                           tt-cli.clicod = d.titulo.clifor
                           no-error.
                if not avail tt-cli
                then do:
                    create tt-cli.
                    assign
                        tt-cli.clicod = d.titulo.clifor
                        tt-cli.etbcod = d.titulo.etbcod
                        tt-cli.etbcob = estab.etbcod
                        tt-cli.cxacod = d.titulo.cxacod
                     .
                end.
                find first tt-pagdia where
                           tt-pagdia.empcod = d.titulo.empcod and
                           tt-pagdia.titnat = d.titulo.titnat and
                           tt-pagdia.modcod = d.titulo.modcod and
                           tt-pagdia.etbcod = d.titulo.etbcod and
                           tt-pagdia.clifor = d.titulo.clifor and
                           tt-pagdia.titnum = d.titulo.titnum and
                           tt-pagdia.titpar = d.titulo.titpar 
                           no-lock no-error.
                if not avail tt-pagdia
                then do:
                    create tt-pagdia.
                    buffer-copy d.titulo to tt-pagdia.
                end.
            end.             
                     
        end.
    end.  
    def var vok as log.
    for each tt-cli :
        disp tt-cli.etbcod tt-cli.clicod with frame f-disp1.
        pause 0.
        vok = no.
        
        for each fin.titulo where
                   fin.titulo.clifor = tt-cli.clicod and
                   fin.titulo.titdtven <= vdtaux and
                   fin.titulo.titsit = "LIB" 
                   no-lock:
            
            if vindex = 1 and fin.titulo.titdtven >= today
            then next.
            if vindex = 2 and fin.titulo.titdtven < today
            then next.
            
            if fin.titulo.modcod <> "CRE"
            then next.
            find first tt-titulo of fin.titulo no-lock no-error.
            if not avail tt-titulo
            then do:
                create tt-titulo.
            buffer-copy fin.titulo to tt-titulo.
            end.      
            vok = yes.  
        end.

        for each d.titulo where
                   d.titulo.clifor = tt-cli.clicod and
                   d.titulo.titdtven <= vdtaux and
                   d.titulo.titsit = "LIB"
                   no-lock:
            if d.titulo.modcod <> "CRE"
            then next.

            if vindex = 1 and fin.titulo.titdtven >= today
            then next.
            if vindex = 2 and fin.titulo.titdtven < today
            then next.

            find first tt-titulo where
                           tt-titulo.empcod = d.titulo.empcod and
                           tt-titulo.titnat = d.titulo.titnat and
                           tt-titulo.modcod = d.titulo.modcod and
                           tt-titulo.etbcod = d.titulo.etbcod and
                           tt-titulo.clifor = d.titulo.clifor and
                           tt-titulo.titnum = d.titulo.titnum and
                           tt-titulo.titpar = d.titulo.titpar 
                           no-lock no-error.
            if not avail tt-titulo
            then do:
                create tt-titulo.
                buffer-copy d.titulo to tt-titulo.
            end.
            vok = yes.
        end.                

        if vok = no
        then delete tt-cli.
    end.        
    varquivo = "/admcom/relat/pagedeve." + string(time).
    
    
    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64" 
        &Cond-Var  = "147" 
        &Page-Line = "64" 
        &Nom-Rel   = ""pagedev""
        &Nom-Sis   = """SISTEMA CREDIARIO"""
        &Tit-Rel   = """ PAGOU E FICOU SALDO DEVEDOR """ 
        &Width     = "130"
        &Form      = "frame f-cabcab"}
 
     DISP WITH FRAME F-DAT.


     vt-cli = 0.
     for each tt-cli break by tt-cli.etbcob
                           by tt-cli.clicod :
        find clien where clien.clicod = tt-cli.clicod no-lock no-error.
        /*
        vt-cli = vt-cli + 1.
        */
        for each tt-titulo where
                 tt-titulo.clifor = clien.clicod
                 :
                 
            disp tt-cli.etbcob
                    column-label "Fil"
                 tt-cli.clicod format ">>>>>>>>>9"
                    column-label "Conta"
                 clien.clinom when avail clien  format "x(30)"
                    column-label "Nome"
                 tt-titulo.titnum format "x(10)"
                    column-label "Contrato"
                 tt-titulo.titpar
                    column-label "Pc"
                 tt-titulo.titvlcob
                    column-label "Valor"
                 tt-titulo.titdtven
                    column-label "Vencimento"
                 today - tt-titulo.titdtven
                    column-label "Atraso"
                 tt-cli.cxacod column-label "Caixa"
                 with frame f-rel down width 130.
            down with frame f-rel.
            vt-cli = vt-cli + 1.
            vt-val = vt-val + tt-titulo.titvlcob.
        end.
        /**    
        for each tt-pagdia where tt-pagdia.clifor = clien.clicod:
            assign
                vt-ppag = vt-ppag + 1
                vt-vpag = vt-vpag + tt-pagdia.titvlpag.       
        end.
        **/ 
        if last-of(tt-cli.etbcob)
        then do:
            for each tt-pagdia where tt-pagdia.etbcobra = tt-cli.etbcod:
                assign
                    vt-ppag = vt-ppag + 1
                    vt-vpag = vt-vpag + tt-pagdia.titvlpag.       
            end.

            
            disp "Total aberto" @ clien.clinom
                 vt-cli @ tt-cli.clicod
                 vt-val @ tt-titulo.titvlcob
                 with frame f-rel.
            down(1) with frame f-rel.
            assign
                vtt-cli = vtt-cli + vt-cli
                vtt-val = vtt-val + vt-val
                vt-cli = 0
                vt-val = 0.  
            
            disp "Total recebido" @ clien.clinom
                 vt-ppag @ tt-cli.clicod
                 vt-vpag @ tt-titulo.titvlcob
                 with frame f-rel.
            down(2) with frame f-rel.
            assign
                vtt-ppag = vtt-ppag + vt-ppag
                vtt-vpag = vtt-vpag + vt-vpag
                vt-ppag = 0
                vt-vpag = 0
                .
         end.     
    end.
    
    disp    "Total geral aberto" @ clien.clinom
            vtt-cli @ tt-cli.clicod
                 vtt-val @ tt-titulo.titvlcob
                 with frame f-rel.
    down(1) with frame f-rel.

    disp "Total geral recebido" @ clien.clinom
         vtt-ppag @ tt-cli.clicod
                 vtt-vpag @ tt-titulo.titvlcob
                 with frame f-rel.
            down(1) with frame f-rel.
            
    
    output close.
    
    run visurel.p(input varquivo, input "").
                 
end.




