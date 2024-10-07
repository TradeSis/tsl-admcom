/* helio 04042022 id 116474 - estava achando que a entrada era do titulo tit-nov*/
/* helio 21022022 - ajustes moedas - acrescentado moeda NCY */
/*
#1 TP 25423783 11.07.18
*/
{admcab.i}
DEF INPUT  PARAM    lcJsonEntrada AS LONGCHAR.
def input  param    ptela         as log.
def output param    varquivo1     as char.
DEF OUTPUT PARAM    vpdf          AS CHAR.

{tsr/tsrelat.i}
{api/acentos.i}

DEF VAR hentrada AS HANDLE.

def temp-table ttparametros no-undo serialize-name "parametros"
    field codigoFilial      as int
    field dataInicial       as char
    field dataFinal         as char
    field considerarFeirao  as log
    field mod-sel           as char
    field vindex            as int.
                        
hEntrada = temp-table ttparametros:HANDLE.

hentrada:READ-JSON("longchar",lcjsonentrada, "EMPTY").
       
find first ttparametros no-error.
if not avail ttparametros then return.

def var vetbcod like estab.etbcod.
def var vdti like plani.pladat.
def var vdtf like plani.pladat.
def var v-feirao-nome-limpo as log format "Sim/Nao" initial no.
def var vv   as int.

def var v-cont as integer.
def var v-cod as char.
def var vmod-sel as char.

def temp-table tit-nov NO-UNDO like titulo .

def temp-table tt-nova no-undo
    field etbcod like estab.etbcod
    field qtd    as int
    field val    like plani.platot
    field vtotal like titulo.titvlcob
    field ventra like titulo.titvlcob
    field japlic like titulo.titvlcob
    field clifor like clien.clicod
    field origem as dec
    index i1 etbcod.

def temp-table tt-data no-undo
    field data as date
    field qtd    as int
    field val    like plani.platot
    field vtotal like titulo.titvlcob
    field ventra like titulo.titvlcob
    field japlic like titulo.titvlcob
    field clifor like clien.clicod
    field origem as dec
    index i1 data.

    
def temp-table tt-cli no-undo
    field clicod like clien.clicod
    field vltotal like contrato.vltotal
    field origem  as dec
    field entrada as dec
    index i1 clicod.

def temp-table tt-modalidade-selec no-undo
    field modcod as char
    index pk modcod.
    
def temp-table tt-cont no-undo
    field etbcod like estab.etbcod
    field clicod like contrato.clicod
    field contnum like contrato.contnum
    field dtinicial like contrato.dtinicial
    field vltotal like contrato.vltotal
    field vlentra like contrato.vlentra
    field modcod like contrato.modcod
    index i1 etbcod clicod contnum.

def var clf-cod like clien.clicod.
def buffer otitulo for titulo.
def temp-table tt-titulo no-undo like titulo.
def temp-table tt-contrato NO-UNDO like contrato.
def var t-entrada as dec.
def var t-total as dec.
def var vezes as int.
def var vparcela as dec.
def var val-juro as dec.
def var val-origem as dec.
def buffer btitulo for titulo.
def var vindex as int.
def var vval-carteira as dec.  
def var vconta as int.                              
                                
    vetbcod = ttparametros.codigoFilial.
    vindex  = ttparametros.vindex.
    v-feirao-nome-limpo = ttparametros.considerarFeirao .
    vmod-sel = ttparametros.mod-sel. 
    do vconta = 1 to num-entries(vmod-sel,",").
      if entry(vconta,vmod-sel,",") = "" then next.
      create tt-modalidade-selec.
      tt-modalidade-selec.modcod = entry(vconta,vmod-sel,",").
    end. 

    if ttparametros.dataFinal BEGINS "#" then do:
        vdtf = calculadata(ttparametros.dataFinal,TODAY).
    end.
    ELSE DO:
        vdtf = convertedata(ttparametros.dataFinal).
    END.
    if ttparametros.dataInicial BEGINS "#" then do:
        vdti = calculadata(ttparametros.dataInicial,today).
    end.
    ELSE DO:
        vdti  = convertedata(ttparametros.dataInicial).
    END.

    for each tt-nova. delete tt-nova. end.
    for each tt-data: delete tt-data. end.
    
    for each tt-contrato:
        delete tt-contrato.
    end.
    for each tt-titulo:
        delete tt-titulo.
    end.    
    for each tt-cont: delete tt-cont. end.
   

    run sel-contrato.
        

    if AVAIL tsrelat then do:
        varquivo = replace(RemoveAcento(tsrelat.nomerel)," ","") +
            "-ID" + STRING(tsrelat.idrelat) + "-" +  
            STRING(TODAY,"99999999") +
            replace(STRING(TIME,"HH:MM:SS"),":","").
    end.
    ELSE DO:
        varquivo = "connov01-" + STRING(TODAY,"99999999") +
                        replace(STRING(TIME,"HH:MM:SS"),":","").
    END.

    {mdadmcab.i &Saida = "VALUE(vdir + varquivo + """.txt""")"
                &Page-Size = "64"
                &Cond-Var  = "80"
                &Page-Line = "66"
                &Nom-Rel   = ""connov01""
                &Nom-Sis   = """SISTEMA CREDIARIO"""
                &Tit-Rel   = """ LISTAGEM DE INCLUSOES DE NOVACAO ""  +
                            "" PERIODO "" + string(vdti) + "" ATE "" +
                            string(vdtf)"
                &Width     = "80"
                &Form      = "frame f-cabc1"}

    if vetbcod > 0
    then
    disp "Analitico da Filial: " vetbcod
        with frame ff-f 1 down no-label.
         
    clf-cod = 0.
    run por-filial.
    
    for each tt-cont no-lock:
        find first tt-cli where 
                   tt-cli.clicod = tt-cont.clicod
                   no-error.
        if not avail tt-cli
        then next.           
        find first titulo where titulo.empcod = 19 and
                          titulo.titnat = no and
                          titulo.modcod = tt-cont.modcod and
                          titulo.etbcod = tt-cont.etbcod and
                          titulo.clifor = tt-cont.clicod and
                          titulo.titnum = string(tt-cont.contnum)  and
                          titulo.tpcontrato = "N" /*titpar = 31*/
                          no-lock no-error. 
        if avail titulo
        then do:                   
            find first tt-nova where tt-nova.etbcod = tt-cont.etbcod 
                           no-error.
            if not avail tt-nova
            then do:
                create tt-nova.
                assign 
                    tt-nova.etbcod = tt-cont.etbcod.
            end.
            assign tt-nova.qtd = tt-nova.qtd + 1
                   tt-nova.val = tt-nova.val + tt-cont.vltotal.
            create tt-titulo.
            buffer-copy titulo to tt-titulo.
            find first tt-data where tt-data.data = titulo.titdtemi no-error.
            if not avail tt-data
            then do:
                create tt-data.
                tt-data.data = titulo.titdtemi.
            end.
            assign
                tt-data.qtd = tt-data.qtd + 1
                tt-data.val = tt-data.val + tt-cont.vltotal.
        end.
    end.
    if vetbcod = 0 
    then do:
        if vindex = 2
        then do:
        for each tt-nova use-index i1:

            if tt-nova.vtotal > 0
            then tt-nova.japlic = tt-nova.vtotal - tt-nova.origem.
            else tt-nova.japlic = 0.
            
            disp tt-nova.etbcod column-label "Filial"
                 tt-nova.qtd(total) column-label "Quant"
                 tt-nova.vtotal(total) column-label "Valor Total"
                 tt-nova.ventra(total) column-label "Valor Entrada"
                 tt-nova.origem(total) column-label "Valor Original"
                        format "->>,>>>,>>9.99"
                 tt-nova.japlic(total) column-label "Juro Aplicado"
                        format "->>,>>>,>>9.99"
                 with frame f2 down width 120.
        end.
        end.
        if vindex = 3
        then do:
        for each tt-data use-index i1:
            if tt-data.vtotal > 0
            then tt-data.japlic = tt-data.vtotal - tt-data.origem.
            else tt-data.japlic = 0.
            disp tt-data.data column-label "Data"
                 tt-data.qtd(total) column-label "Quant"
                 tt-data.vtotal(total) column-label "Valor Total"
                 tt-data.ventra(total) column-label "Valor Entrada"
                 tt-data.origem(total) column-label "Valor Original"
                        format "->>,>>>,>>9.99"
                 tt-data.japlic(total) column-label "Juro Aplicado"
                        format "->>,>>>,>>9.99"
                 with frame f9 down width 120.
        end.
        end.
    end.

    if vetbcod > 0 or vindex = 1
    then do:
    for each tt-cli /*where tt-cli.clicod > 1 and
            tt-cli.origem > 0*/:
        find clien where clien.clicod = tt-cli.clicod no-lock no-error.
           
        if tt-cli.vltotal > 0
        then val-juro = tt-cli.vltotal - tt-cli.origem.
        else val-juro = 0.
        
        disp 
             clien.clicod
             clien.clinom format "x(30)"
             tt-cli.vltotal(total) column-label "Valor Total"
             tt-cli.entrada(total) column-label "Valor Entrada"
             tt-cli.origem(total) column-label "Valor Original"
                format "->>,>>>,>>9.99"
             val-juro (total) column-label "Juro!Aplicado" 
             with frame f-cont down width 130.
    end.         
    end.
    output close.
    
    run pdfout.p (INPUT vdir + varquivo + ".txt",
                  input vdir,
                  input varquivo + ".pdf",
                  input "Landscape", /* Landscape/Portrait */
                  input 7,
                  input 1,
                  output vpdf).
    varquivo1 = vdir + varquivo + ".txt".

procedure por-filial:
    
    def var cli-cod like clien.clicod.
    def var etb-cod like estab.etbcod.
    
    for each tt-cli: delete tt-cli. end. 
    for each tt-nova: delete tt-nova. end.
    for each tt-data: delete tt-data. end.

    for each tt-cont  
           by tt-cont.etbcod
           by tt-cont.dtinicial
           by tt-cont.clicod :
        
        find clien where clien.clicod = tt-cont.clicod no-lock.
        t-entrada = tt-cont.vlentra.
    
        t-total = 0.
        vezes = 0.
        vparcela = 0.
        
        for each titulo where titulo.empcod = 19 and
                          titulo.titnat = no and
                          titulo.modcod = tt-cont.modcod and
                          titulo.etbcod = tt-cont.etbcod and
                          titulo.clifor = tt-cont.clicod and
                          titulo.titnum = string(tt-cont.contnum)
                          no-lock:
            if titulo.tpcontrato <> "" 
            then vparcela = titulo.titvlcob.   
            if vezes < titulo.titpar
            then vezes = titulo.titpar.
            t-total = t-total + titulo.titvlcob.
        end.
        if vezes > 30 
        then
            if tt-cont.vlentra > 0
            then vezes = vezes - 30.
            else vezes = vezes - 31.
        val-origem = 0.

        find first tt-nova where
                   tt-nova.etbcod = tt-cont.etbcod 
                    no-error.
        if not avail tt-nova
        then do:
            create tt-nova.
            tt-nova.etbcod = tt-cont.etbcod.
            for each tit-nov where
                 tit-nov.etbcobra = tt-cont.etbcod  
                 no-lock:
                tt-nova.origem = tt-nova.origem + tit-nov.titvlcob.
            end.
        end.
        assign
            tt-nova.vtotal = tt-nova.vtotal + tt-cont.vltotal
            tt-nova.ventra = tt-nova.ventra + t-entrada.
        
        find first tt-data where tt-data.data = tt-cont.dtinicial no-error.
        if not avail tt-data
        then do:
            create tt-data.
            tt-data.data = tt-cont.dtinicial.
            for each tit-nov where
                 tit-nov.titdtpag = tt-cont.dtinicial
                 no-lock:
                tt-data.origem = tt-data.origem + tit-nov.titvlcob.
            end.
        end.    
        assign
            tt-data.vtotal = tt-data.vtotal + tt-cont.vltotal
            tt-data.ventra = tt-data.ventra + t-entrada.
            
        find first  tt-cli where 
                    tt-cli.clicod = tt-cont.clicod
                     no-error.
        if not avail tt-cli
        then do:
            create tt-cli.
            tt-cli.clicod  = tt-cont.clicod.
            for each tit-nov where
                 tit-nov.clifor   = tt-cont.clicod 
                 no-lock:
                tt-cli.origem = tt-cli.origem + tit-nov.titvlcob.
            end.
        end.
        assign
            tt-cli.vltotal = tt-cli.vltotal + tt-cont.vltotal
            tt-cli.entrada = tt-cli.entrada + t-entrada.
 
        val-origem = 0.

        
    end. 

end procedure.

procedure sel-contrato.
    def var vdtinclu as date.
    if ptela
    then do:
        disp "Aguarde... Selecionando contratos."
            with frame f-disp 1 down no-label color message no-box
            row 8.
        pause 0.
    end.        
    def var vdata as date.
    do vdata = vdti to vdtf:    
    for each tt-modalidade-selec,
        each contrato where contrato.dtinicial /*#1datexp*/ = vdata
                        and contrato.modcod = tt-modalidade-selec.modcod
                      no-lock:
        if ptela
        then do:
            disp contrato.contnum format ">>>>>>>>>9"
                with frame f-disp .
            pause 0.
        end.
            
        if vetbcod > 0 and
           contrato.etbcod <> vetbcod
        then next. 
        
        
        if contrato.clicod = 1
        then next.
        find first titulo where titulo.empcod = 19 and
                          titulo.titnat = no and
                          titulo.modcod = contrato.modcod and
                          titulo.etbcod = contrato.etbcod and
                          titulo.clifor = contrato.clicod and
                          titulo.titnum = string(contrato.contnum)  and
                          titulo.tpcontrato = "N"
                          no-lock no-error. 
        if avail titulo
        then do:
            {filtro-feiraonl.i}

            find first tt-cont where
                       tt-cont.contnum = contrato.contnum
                       no-error.
            if not avail tt-cont
            then do:           
                create tt-cont.
                assign
                    tt-cont.etbcod = contrato.etbcod 
                    tt-cont.clicod = contrato.clicod
                    tt-cont.contnum = contrato.contnum
                    tt-cont.vltotal = contrato.vltotal
                    tt-cont.dtinicial = contrato.dtinicial
                    tt-cont.modcod = contrato.modcod.

                for each btitulo where 
                     btitulo.clifor = titulo.clifor and
                     btitulo.titnum = titulo.titnum and
                     btitulo.modcod = titulo.modcod 
                     no-lock .
                
                    if btitulo.titpar = 0 or btitulo.titdtven = btitulo.titdtemi
                    then tt-cont.vlentra = tt-cont.vlentra + btitulo.titvlcob.  
                 
                end.

                for each otitulo where
                     otitulo.clifor   = contrato.clicod and
                     otitulo.titdtpag = contrato.dtinicial and
                     otitulo.modcod = contrato.modcod and
                   ( otitulo.moecod = "NOV"  or otitulo.moecod = "NCY")                               no-lock.
                    find first tit-nov where tit-nov.empcod   = otitulo.empcod 
                                     and tit-nov.titnat   = otitulo.titnat
                                     and tit-nov.modcod   = otitulo.modcod
                                     and tit-nov.etbcod   = otitulo.etbcod
                                     and tit-nov.CliFor   = otitulo.CliFor
                                     and tit-nov.titnum   = otitulo.titnum
                                     and tit-nov.titpar   = otitulo.titpar
                                     and tit-nov.titdtemi = otitulo.titdtemi
                                            no-lock no-error.
                
                    if not avail tit-nov
                    then do:
                        if otitulo.titpar > 0 /* estava pegando a propria entrada */
                        then do:
                            create tit-nov.
                            buffer-copy otitulo to tit-nov.         
                        end.
                    end.
                end.
            end.
        end.
    end.    

    for each tt-modalidade-selec,
        each titulo where
                 titulo.empcod = 19 /* #1 */
             and titulo.titnat = no /* #1 */
             and titulo.titdtemi = /* #1 titulo.datexp */ vdata
             and titulo.modcod = tt-modalidade-selec.modcod
             no-lock:

        
        if titulo.tpcontrato  = "N" /*titpar = 31*/
        then.
        else next.

        {filtro-feiraonl.i}

        if ptela
        then do:
            disp titulo.titnum @ contrato.contnum with frame f-disp.
            pause 0.
        end.

        if vetbcod > 0 and
            titulo.etbcod <> vetbcod
        then next.

        vdtinclu = titulo.titdtemi.
        
        if vdtinclu < vdti then next.
        if vdtinclu > vdtf then next.
        
        find first tt-cont where
                   tt-cont.etbcod = titulo.etbcod and
                   tt-cont.clicod = titulo.clifor and
                   tt-cont.modcod = titulo.modcod and
                   tt-cont.contnum = int(titulo.titnum)
                     no-error.
        if not avail tt-cont
        then do:             
            create tt-cont.
            assign
                tt-cont.etbcod = titulo.etbcod
                tt-cont.clicod = titulo.clifor
                tt-cont.contnum = int(titulo.titnum)
                tt-cont.dtinicial = vdtinclu
                tt-cont.modcod = titulo.modcod.
             
            for each btitulo where 
                     btitulo.clifor = titulo.clifor and
                     btitulo.titnum = titulo.titnum and
                     btitulo.modcod = titulo.modcod 
                     no-lock .
                
                tt-cont.vltotal = tt-cont.vltotal + btitulo.titvlcob.
                if btitulo.titpar = 0 or btitulo.titdtven = btitulo.titdtemi
                then tt-cont.vlentra = tt-cont.vlentra + btitulo.titvlcob.  
                 
            end.
  
            
            for each otitulo where
                     otitulo.etbcobra = titulo.etbcod and
                     otitulo.titdtpag = vdata and
                     otitulo.modcod = titulo.modcod and
                     
                     (otitulo.moecod = "NOV" or otitulo.moecod = "NCY")          
                     
                     no-lock.
                
                find first tit-nov where tit-nov.empcod   = otitulo.empcod 
                                     and tit-nov.titnat   = otitulo.titnat
                                     and tit-nov.modcod   = otitulo.modcod
                                     and tit-nov.etbcod   = otitulo.etbcod
                                     and tit-nov.CliFor   = otitulo.CliFor
                                     and tit-nov.titnum   = otitulo.titnum
                                     and tit-nov.titpar   = otitulo.titpar
                                     and tit-nov.titdtemi = otitulo.titdtemi
                                            no-lock no-error.
                
                if not avail tit-nov
                then do:
                    if otitulo.titpar > 0
                    then do:
                        create tit-nov.
                        buffer-copy otitulo to tit-nov.         
                    end.
                end.
            end.
        end.
    end.
    for each tt-modalidade-selec:
        for each otitulo where
                     otitulo.etbcobra = vetbcod and
                     otitulo.titdtpag = vdata and
                     otitulo.modcod = tt-modalidade-selec.modcod and

                     (otitulo.moecod = "NOV" or otitulo.moecod = "NCY")
                     no-lock.
            if otitulo.titpar = 0
            then next.        

                find first tt-cont where
                   tt-cont.etbcod = otitulo.etbcod and
                   tt-cont.clicod = otitulo.clifor and
                   tt-cont.modcod = otitulo.modcod and
                   tt-cont.contnum = int(otitulo.titnum)
                     no-error.
                if not avail tt-cont
                then do:             
            create tt-cont.
            assign
                tt-cont.etbcod = otitulo.etbcod
                tt-cont.clicod = otitulo.clifor
                tt-cont.contnum = int(otitulo.titnum)
                tt-cont.dtinicial = vdtinclu
                tt-cont.modcod = otitulo.modcod.
                 end.
                 find first tit-nov where tit-nov.empcod   = otitulo.empcod 
                                     and tit-nov.titnat   = otitulo.titnat
                                     and tit-nov.modcod   = otitulo.modcod
                                     and tit-nov.etbcod   = otitulo.etbcod
                                     and tit-nov.CliFor   = otitulo.CliFor
                                     and tit-nov.titnum   = otitulo.titnum
                                     and tit-nov.titpar   = otitulo.titpar
                                     and tit-nov.titdtemi = otitulo.titdtemi
                                            no-lock no-error.
                
                if not avail tit-nov
                then do:
                    if otitulo.titpar > 0
                    then do:
                        create tit-nov.
                        buffer-copy otitulo to tit-nov.         
                    end.
                end.
            end.
        end.
    
    end.            
end procedure.





