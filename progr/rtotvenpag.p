/*
#1 Julho/2018 - FIDC
*/
{admcab.i}

update vdti as date format "99/99/9999" label "Periodo de"
       vdtf as date format "99/99/9999" label "Ate"
       with frame f-1 side-label width 80.

def var vdata as date.

def temp-table tt-titulo like titulo
    field stenvfinan as char
    field stenvfidc as char
    index i1 titchepag
             clifor
             titnum
             titpar.

def temp-table tt-venda
    field gru  as int
    field seq  as int
    field tipo as char    format "x(14)"           column-label "Tipo"
    field data as date                             column-label "Data"
    field valtotal as dec format ">>>,>>>,>>9.99"  column-label "Total"
    field vallebes as dec format ">>>,>>>,>>9.99"  column-label "Lebes"
    field valfinan as dec format ">>>,>>>,>>9.99"  column-label "Financeira"
    field valfidc  as dec format ">>>,>>>,>>9.99"  column-label "FIDC"
    index i1 gru seq tipo data.

def var val-total as dec.
def var vtipo as char.
def var vq as int.
def var vtabela as char.

def var vparcela like titulo.titpar.
def var vparcial as log.

do vdata = vdti to vdtf:
    disp "Processando... " vdata
         "Contratos" @ vtabela
        with frame f2 no-label.
    pause 0. 
    
    for each contrato where contrato.dtinicial = vdata no-lock:
        
        if contrato.banco = 99 then next.
        
        vtipo = "".
        if contrato.modcod = "CRE"
        then assign
                vq = 1.
                vtipo = "VENDA".
        if contrato.crecod = 500 
        then assign
                vq = 2
                vtipo = "NOVAÇAO".
        if contrato.modcod begins "CP"
        then assign
                vq = 3
                vtipo = "EMPRESTIMO".
 
        find first tt-venda where
               tt-venda.gru  = 1 and
               tt-venda.seq  = vq and 
               tt-venda.tipo = vtipo and
               tt-venda.data = ?
               no-error.
        if not avail tt-venda
        then do:           
            create tt-venda.
            assign
                tt-venda.gru  = 1
                tt-venda.seq  = vq
                tt-venda.tipo = vtipo
                tt-venda.data = ?.
        end.
        
        val-total = contrato.vltotal - contrato.vlentra.
        for each titulo where
                 titulo.empcod = 19 and
                 titulo.titnat = no and
                 titulo.modcod = contrato.modcod and
                 titulo.etbcod = contrato.etbcod and
                 titulo.clifor = contrato.clicod and
                 titulo.titnum = string(contrato.contnum) and
                 titulo.titpar > 0
                 no-lock:

            vparcela = titulo.titpar.
            vparcial = no.
            run retorna-titpar-financeira.p(input recid(titulo),
                                  input-output vparcela,
                                  output vparcial)
                                  .

            find first envfinan where
                   envfinan.empcod = titulo.empcod and
                   envfinan.titnat = titulo.titnat and
                   envfinan.modcod = titulo.modcod and
                   envfinan.etbcod = titulo.etbcod and
                   envfinan.clifor = titulo.clifor and
                   envfinan.titnum = titulo.titnum and
                   envfinan.titpar = vparcela /*titulo.titpar*/
                   no-lock no-error.
            if avail envfinan and (envfinan.envsit = "PAG" or
                                   envfinan.envsit = "INC")
            /*if titulo.cobcod = 10*/
            then do:
                if titulo.titdes > 0 and titulo.modcod = "CRE"
                then do:
                    assign
                        tt-venda.valfinan = tt-venda.valfinan + 
                                            (titulo.titvlcob - titulo.titdes)
                        tt-venda.vallebes = tt-venda.vallebes + titulo.titdes.  
                    create tt-titulo.
                    buffer-copy titulo to tt-titulo.
                    tt-titulo.titchepag = vtipo.
                    tt-titulo.titvlcob = titulo.titdes.
                    tt-titulo.cobcod = 2.

                    create tt-titulo.
                    buffer-copy titulo to tt-titulo.
                    tt-titulo.titchepag = vtipo.
                    tt-titulo.titvlcob = titulo.titvlcob - titulo.titdes.
                    tt-titulo.stenvfinan = envfinan.envsit.
                end.
                else if titulo.cobcod = 2
                then do:
                    tt-venda.vallebes = tt-venda.vallebes + titulo.titvlcob.
                    create tt-titulo.
                    buffer-copy titulo to tt-titulo.
                    tt-titulo.titchepag = vtipo.
                    tt-titulo.cobcod = 2. 
                    tt-titulo.stenvfinan = envfinan.envsit.
                end.
                else do:
                    tt-venda.valfinan = tt-venda.valfinan + titulo.titvlcob.

                    create tt-titulo.
                    buffer-copy titulo to tt-titulo.
                    tt-titulo.titchepag = vtipo.
                    tt-titulo.stenvfinan = envfinan.envsit.
                end.
            end.
            else do:
                tt-venda.vallebes = tt-venda.vallebes + titulo.titvlcob.

                create tt-titulo.
                buffer-copy titulo to tt-titulo.
                tt-titulo.titchepag = vtipo.
                tt-titulo.cobcod = 2. 
                if avail envfinan
                then tt-titulo.stenvfinan = envfinan.envsit.
            end.
            tt-venda.valtotal = tt-venda.valtotal + titulo.titvlcob.

            /*FIDC*/
            find first envfidc where 
                           envfidc.empcod = titulo.empcod and 
                           envfidc.titnat = titulo.titnat and 
                           envfidc.modcod = titulo.modcod and 
                           envfidc.etbcod = titulo.etbcod and 
                           envfidc.clifor = titulo.clifor and 
                           envfidc.titnum = titulo.titnum and 
                           envfidc.titpar = titulo.titpar and 
                           envfidc.lottip = "IMPORTA"
                       no-lock no-error. 
            if avail envfidc 
            then do:
                assign tt-venda.valfidc = tt-venda.valfidc + 
                    (titulo.titvlcob - titulo.titdes).
                
                /*
                find first tt-titulo where 
                           tt-titulo.titchepag = vtipo and
                           tt-titulo.clifor = titulo.clifor and
                           tt-titulo.titnum = titulo.titnum and
                           tt-titulo.titpar = titulo.titpar
                           no-error.
                if not avail tt-titulo
                then do:           
                    create tt-titulo.
                    buffer-copy titulo to tt-titulo. 
                    tt-titulo.titchepag = vtipo.
                end.
                */
            end.
        end.
    end.

    disp "Titulos" @ vtabela with frame f2.
    for each titulo where 
             titulo.titnat   = no and
             titulo.titdtpag = vdata 
             no-lock:

        if titulo.titpar = 0 or
           titulo.modcod = "VVI"
        then next.
        
        vtipo = "".
        vq = 0.
        if titulo.modcod = "CRE" 
        then assign
                vq = 1
                vtipo = "PG.VENDA".
        if titulo.modcod begins "CP"
        then assign
                vq = 3
                vtipo = "PG.EMPRESTIMO".
        if titulo.tpcontrato = "L" or
           titulo.tpcontrato = "N"
        then assign
                vq = 2
                vtipo = "PG.NOVAÇAO".
        
        if vtipo = "" then next.

        find first tt-venda where
               tt-venda.gru = 2 and
               tt-venda.seq = vq and 
               tt-venda.tipo = vtipo and
               tt-venda.data = ?
               no-error.
        if not avail tt-venda
        then do:           
            create tt-venda.
            assign
                tt-venda.gru  = 2
                tt-venda.seq  = vq
                tt-venda.tipo = vtipo
                tt-venda.data = ?.
        end.
        tt-venda.valtotal = tt-venda.valtotal + titulo.titvlcob.
        
        vparcela = titulo.titpar.
            vparcial = no.
            run retorna-titpar-financeira.p(input recid(titulo),
                                  input-output vparcela,
                                  output vparcial)
                                  .

        find first envfinan where
                   envfinan.empcod = titulo.empcod and
                   envfinan.titnat = titulo.titnat and
                   envfinan.modcod = titulo.modcod and
                   envfinan.etbcod = titulo.etbcod and
                   envfinan.clifor = titulo.clifor and
                   envfinan.titnum = titulo.titnum and
                   envfinan.titpar = vparcela
                   no-lock no-error.
        if avail envfinan and (envfinan.envsit = "PAG" or
                               envfinan.envsit = "INC")
        /*if titulo.cobcod = 10*/
        then do:
            if titulo.titvlpag <= titulo.titvlcob - titulo.titdes
            then do:
                tt-venda.valfinan = tt-venda.valfinan + titulo.titvlcob.
                create tt-titulo.
                buffer-copy titulo to tt-titulo.
                tt-titulo.titchepag = vtipo.
                tt-titulo.titvlcob = titulo.titvlcob.
                tt-titulo.titvlpag = titulo.titvlpag.
                tt-titulo.stenvfinan = envfinan.envsit.
            end.
            else do:
                if titulo.titdes > 0 and titulo.modcod = "CRE"
                then do:
                    tt-venda.vallebes = tt-venda.vallebes + titulo.titdes.
                    tt-venda.valfinan = tt-venda.valfinan +
                                        (titulo.titvlpag - titulo.titdes).
                    create tt-titulo.
                    buffer-copy titulo to tt-titulo.
                    tt-titulo.titchepag = vtipo.
                    tt-titulo.titvlpag = titulo.titdes.
                    tt-titulo.cobcod = 2.

                    create tt-titulo.
                    buffer-copy titulo to tt-titulo.
                    tt-titulo.titchepag = vtipo.
                    tt-titulo.titvlcob = titulo.titvlpag - titulo.titdes.
                    tt-titulo.stenvfinan = envfinan.envsit.
                end.
                else do:    
                    tt-venda.valfinan = tt-venda.valfinan + titulo.titvlcob.

                    create tt-titulo.
                    buffer-copy titulo to tt-titulo.
                    tt-titulo.titchepag = vtipo.
                    tt-titulo.titvlcob = titulo.titvlcob.
                    tt-titulo.titvlpag = titulo.titvlpag.
                    tt-titulo.stenvfinan = envfinan.envsit.
                end.
            end.   
        end.                    
        else do:
            tt-venda.vallebes = tt-venda.vallebes + titulo.titvlcob.
            create tt-titulo.
            buffer-copy titulo to tt-titulo.
            tt-titulo.titvlcob = titulo.titvlcob.
            tt-titulo.titvlpag = titulo.titvlpag.
            tt-titulo.titchepag = vtipo.
            tt-titulo.cobcod = 2.
            if avail envfinan
            then tt-titulo.stenvfinan = envfinan.envsit.
        end.
        
        /***FIDC*/
        find first envfidc where 
               envfidc.empcod = titulo.empcod and 
               envfidc.titnat = titulo.titnat and 
               envfidc.modcod = titulo.modcod and 
               envfidc.etbcod = titulo.etbcod and 
               envfidc.clifor = titulo.clifor and 
               envfidc.titnum = titulo.titnum and 
               envfidc.titpar = titulo.titpar and 
               envfidc.lottip = "IMPORTA"
               no-lock no-error. 
        if avail envfidc 
        then do:
            assign tt-venda.valfidc = tt-venda.valfidc + 
                    (titulo.titvlcob - titulo.titdes).
            
            /*
            find first tt-titulo where 
                           tt-titulo.titchepag = vtipo and
                           tt-titulo.clifor = titulo.clifor and
                           tt-titulo.titnum = titulo.titnum and
                           tt-titulo.titpar = titulo.titpar
                           no-error.
            if not avail tt-titulo
            then do:           
                create tt-titulo.
                buffer-copy titulo to tt-titulo. 
                tt-titulo.titchepag = vtipo.
            end.
            */
        end.
    end.
end.
hide frame f2.

def var t-valt as dec.
def var t-vall as dec.
def var t-valf as dec.
def var t-vald as dec.

disp "VALORES A PRAZO" 
with frame f-title color message no-box centered.

for each tt-venda break by gru by seq.
    assign
        t-valt = t-valt + tt-venda.valtotal
        t-vall = t-vall + tt-venda.vallebes
        t-valf = t-valf + tt-venda.valfinan
        t-vald = t-vald + tt-venda.valfidc.
        
    disp tt-venda.tipo
         tt-venda.valtotal(sub-total by gru)
         tt-venda.vallebes(sub-total by gru)
         tt-venda.valfinan(sub-total by gru)
         tt-venda.valfidc(sub-total by gru)
         with centEred no-box /*title " VALORES A PRAZO "*/.
end. 

sresp = no.
message "Deseja imprimir a tela?" update sresp.

hide frame f-title.

if sresp
then do:
    run relatorio(1).
end.

{setbrw.i}                                                                      

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial ["","  RELATORIO","  TUDO CSV","",""].
def var esqcom2         as char format "x(15)" extent 5.

form
    esqcom1
    with frame f-com1
                 row 3  no-labels no-box side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

form " " 
     " "
     with frame f-linha 10 down color with/cyan /*no-box*/ centered.                                                               
disp " " with frame f2 1 down width 80 color message no-box no-label row 20.                                                                     
def buffer btbcntgen for tbcntgen.                            
def var i as int.

l1: repeat:
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    assign
        a-seeid = -1 a-recid = -1 a-seerec = ?
        esqpos1 = 1 esqpos2 = 1. 
    hide frame f-linha no-pause.
    clear frame f-linha all.
    {sklclstb.i  
        &color = with/cyan
        &file = tt-venda   
        &cfield = tt-venda.tipo
        &noncharacter = /* 
        &ofield = " tt-venda.tipo
                    tt-venda.valtotal
                    tt-venda.vallebes
                    tt-venda.valfinan
                    tt-venda.valfidc "  
        &aftfnd1 = " "
        &where  = " "
        &aftselect1 = " run aftselect.
                        a-seeid = -1.
                        next keys-loop."
        &go-on = TAB 
        &naoexiste1 = "  " 
        &otherkeys1 = " run controle. "
        &locktype = " use-index i1 "
        &form   = " frame f-linha "
    }   
    if keyfunction(lastkey) = "end-error"
    then DO:
        leave l1.       
    END.
end.
hide frame f1 no-pause.
hide frame f2 no-pause.
hide frame ff2 no-pause.
hide frame f-linha no-pause.


procedure aftselect:
    clear frame f-linha1 all.
    if esqcom1[esqpos1] = "  RELATORIO"
    THEN DO on error undo:
        RUN relatorio(2).
    END.
    if esqcom1[esqpos1] = "  TUDO CSV"
    THEN DO:
        RUN relatoriocsv.
    END.
 
end procedure.

procedure controle:
        def var ve as int.
            if keyfunction(lastkey) = "TAB"
            then do:
                if esqregua
                then do:
                    esqpos1 = 1.
                    do ve = 1 to 5:
                    color display normal esqcom1[ve] with frame f-com1.
                    end.
                    color display message esqcom2[esqpos2] with frame f-com2.
                end.
                else do:
                    do ve = 1 to 5:
                    color display normal esqcom2[ve] with frame f-com2.
                    end.
                    esqpos2 = 1.
                    color display message esqcom1[esqpos1] with frame f-com1.
                end.
                esqregua = not esqregua.
            end.
            if keyfunction(lastkey) = "cursor-right"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 5 then 5 else esqpos2 + 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                end.
                next.
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 1 then 1 else esqpos2 - 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                end.
                next.
            end.
end procedure.

procedure relatorio:
    def input parameter t-rel as int.
    def var varquivo as char.
    
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/" + string(setbcod) + "." + string(mtime).
    else varquivo = "..~\relat~\" + string(setbcod) + "." + string(time).
    
    {mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "80" 
                &Page-Line = "66" 
                &Nom-Rel   = ""programa"" 
                &Nom-Sis   = """SISTEMA""" 
                &Tit-Rel   = """TITULO""" 
                &Width     = "80"
                &Form      = "frame f-cabcab"}

    disp with frame f-1.
    if t-rel = 1
    then do:
        for each tt-venda break by gru by seq.
        disp tt-venda.tipo
         tt-venda.valtotal(sub-total by gru)
         tt-venda.vallebes(sub-total by gru)
         tt-venda.valfinan(sub-total by gru)
         tt-venda.valfidc(sub-total by gru)
         with centEred no-box /*title " VALORES A PRAZO "*/.
        end. 
    end.
    else do:

        disp tt-venda.tipo 
             tt-venda.valtotal
             tt-venda.vallebes
             tt-venda.valfinan
             tt-venda.valfidc
             with width 130.
        for each tt-titulo where
                 tt-titulo.titchepag = tt-venda.tipo 
                 no-lock break by tt-venda.tipo by tt-titulo.cobcod
                 by tt-titulo.titdtemi by tt-titulo.titnum 
                 by tt-titulo.titpar:
            disp if tt-titulo.cobcod = 10
                 then "FINCEIRA"
                 else if tt-titulo.cobcod = 14
                 then "FIDC"
                 ELSE "LEBES"   
                 tt-titulo.titnum
                 tt-titulo.titpar
                 tt-titulo.titdtemi
                 tt-titulo.titdtven
                 tt-titulo.titdtpag
                 tt-titulo.titvlcob (sub-total by tt-titulo.cobcod)
                    format "->>>,>>9.99"
                 tt-titulo.titvlpag (sub-total by tt-titulo.cobcod)
                    format "->>>,>>9.99"
                 tt-titulo.cobcod
                 tt-titulo.titchepag
                 tt-titulo.stenvfinan column-label "EnvFinan"
                 with width 150.
        end.         
    end.
    output close.

    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}
    end.
end procedure.


procedure relatoriocsv:
    def var varquivo as char.
    def var varqcsv as char.
    
    varquivo = "/admcom/relat/batimento-" 
                + string(vdti,"99999999")
                + "-" + string(vdtf,"99999999")
                + "-" + string(time)
                + ".csv".

    varqcsv = "l:~\relat~\batimento-" 
                + string(vdti,"99999999")
                + "-" + string(vdtf,"99999999")
                + "-" + string(time)
                + ".csv".

    output to value(varquivo).
    put unformatted
        ";Modalidade;Numero;Parcela;Emissao;Vencimento;Pagamento;Valor Cobrado;
        Valor Pago;Cob;EnvFinan;Cobcod" skip.

    for each tt-venda : 
        for each tt-titulo where
                 tt-titulo.titchepag = tt-venda.tipo 
                 no-lock break by tt-venda.tipo by tt-titulo.cobcod
                 by tt-titulo.titdtemi by tt-titulo.titnum 
                 by tt-titulo.titpar:
        
            
            if tt-titulo.cobcod = 10
            then put "FINCEIRA". 
            ELSE put "LEBES"   .
            put ";"  
                 tt-titulo.modcod
                 ";"
                 tt-titulo.titnum
                 ";"
                 tt-titulo.titpar
                 ";"
                 tt-titulo.titdtemi
                 ";"
                 tt-titulo.titdtven
                 ";"
                 tt-titulo.titdtpag
                 ";"
                 tt-titulo.titvlcob format ">>>>>>>9.99"
                 ";"
                 tt-titulo.titvlpag format ">>>>>>>9.99"
                 ";"
                 tt-titulo.titchepag
                 ";"
                 tt-titulo.stenvfinan 
                 ";"
                 tt-titulo.cobcod
                 skip
                 .
        end. 

    end.
    output close.
    
    message color red/with
    "Arquivo gerado"   skip
    varqcsv
    view-as alert-box.
    
end procedure.
                                      
