/* helio 04042022 id 116474 - estava achando que a entrada era do titulo tit-nov*/
/* helio 21022022 - ajustes moedas - acrescentado moeda NCY */
/*
#1 TP 25423783 11.07.18
*/
{admcab.i}
{setbrw.i}
{tt-modalidade-padrao.i new}
create tt-modalidade-padrao.
tt-modalidade-padrao.modcod = "CPN".

def var vetbcod like estab.etbcod.
def var vdti like plani.pladat.
def var vdtf like plani.pladat.
def var v-feirao-nome-limpo as log format "Sim/Nao" initial no.
def var vv   as int.

def var v-cont as integer.
def var v-cod as char.
def var vmod-sel as char.

def temp-table tit-nov like titulo.

def temp-table tt-nova
    field etbcod like estab.etbcod
    field qtd    as int
    field val    like plani.platot
    field vtotal like titulo.titvlcob
    field ventra like titulo.titvlcob
    field japlic like titulo.titvlcob
    field clifor like clien.clicod
    field origem as dec
    index i1 etbcod.

def temp-table tt-data
    field data as date
    field qtd    as int
    field val    like plani.platot
    field vtotal like titulo.titvlcob
    field ventra like titulo.titvlcob
    field japlic like titulo.titvlcob
    field clifor like clien.clicod
    field origem as dec
    index i1 data.

def var vesc as char format "x(15)" extent 3
        init["ANALITICO","SINTETICO","POR DATA"]. 
    
def temp-table tt-cli
    field clicod like clien.clicod
    field vltotal like contrato.vltotal
    field origem  as dec
    field entrada as dec
    index i1 clicod.

def temp-table tt-modalidade-selec
    field modcod as char
    index pk modcod.
    
def temp-table tt-cont
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
def temp-table tt-titulo like titulo.
def temp-table tt-contrato like contrato.
def var varquivo as char.
def var t-entrada as dec.
def var t-total as dec.
def var vezes as int.
def var vparcela as dec.
def var val-juro as dec.
def var val-origem as dec.
def buffer btitulo for titulo.
def var vindex as int.
def var vval-carteira as dec.                                
                                
form
   a-seelst format "x" column-label "*"
   tt-modalidade-padrao.modcod no-label
   with frame f-nome
       centered down title "Modalidades"
       color withe/red overlay.    
                                                        
repeat:
    /*
    update vetbcod label "Filial" with frame f1 side-label width 80.
    find estab where estab.etbcod = vetbcod no-lock.
    display estab.etbnom no-label with frame f1.
    */
    
    for each tt-nova. delete tt-nova. end.
    for each tt-data: delete tt-data. end.
    
    update vdti label "Data Inicial"  colon 25
           vdtf label "Data Final " with frame f1 side-label width 80.
        
    do on error undo:
        message "Informe a Filial para analitico" update vetbcod.  
        if vetbcod > 0
        then do:
            find estab where estab.etbcod = vetbcod no-lock no-error.
            if not avail estab then undo.
        end.     
    end.
    
    assign sresp = false.
           
    update sresp label "Seleciona Modalidades?" colon 25
           help "Não = Modalidade CRE Padrão / Sim = Seleciona Modalidades"
           with side-label
           width 80 frame f1.
              
    if sresp
    then do:
        bl_sel_filiais:
        repeat:
            run p-seleciona-modal.
                                                      
            if keyfunction(lastkey) = "end-error"
            then leave bl_sel_filiais.
        end.
    end.
    else do:
        create tt-modalidade-selec.
        assign tt-modalidade-selec.modcod = "CRE".
    end.
    
    assign vmod-sel = "  ".
    for each tt-modalidade-selec.
        assign vmod-sel = vmod-sel + tt-modalidade-selec.modcod + "  ".
    end.
        
    display vmod-sel format "x(40)" no-label with frame f1.

    update v-feirao-nome-limpo label "Considerar apenas feirao" colon 25
        with frame f1.

    for each tt-contrato:
        delete tt-contrato.
    end.
    for each tt-titulo:
        delete tt-titulo.
    end.    
    for each tt-cont: delete tt-cont. end.
    IF VETBCOD = 0
    then do:
        disp vesc with frame f-esc 1 down no-label.
        choose field vesc with frame f-esc.
        vindex = frame-index.
        hide frame f-esc.
        message "AGUARDE PROCESSAMENTO... " VESC[vindex].
    end.

    run sel-contrato.
    
    disp "Aguarde... Montando relatorio."
        with frame f-disp1 1 down no-box no-label color message.
    pause 0.
        
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/lin." + string(time).
    else varquivo = "l:~\relat~\lin." + string(time).

    {mdadmcab.i &Saida = "value(varquivo)"
                &Page-Size = "64"
                &Cond-Var  = "80"
                &Page-Line = "66"
                &Nom-Rel   = ""connov""
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
        for each tt-nova /*where
                 tt-nova.origem > 0*/ use-index i1:

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
        for each tt-data /*where
                 tt-data.origem > 0*/ use-index i1:
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
    
    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
    {mrod.i}
    end.
    return.
end.

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
                 tit-nov.etbcobra = tt-cont.etbcod /*and
                 tit-nov.titdtpag = tt-cont.dtinicial and
                 tit-nov.clifor   = tt-cont.clicod*/ 
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

        /***************
        if cli-cod <> tt-cont.clicod  
        then do:
            for each tit-nov where
                 tit-nov.etbcobra = tt-cont.etbcod and
                 tit-nov.titdtpag = tt-cont.dtinicial and
                 tit-nov.clifor   = tt-cont.clicod 
                 no-lock:
                val-origem = val-origem + tit-nov.titvlcob.
            end.
            cli-cod = tt-cont.clicod.
        end.
        if val-origem > 0
        then 
        assign
            /*tt-nova.origem = tt-nova.origem + val-origem*/
            tt-data.origem = tt-data.origem + val-origem
            tt-cli.origem  = tt-cli.origem + val-origem.
        **************/
    end. 

end procedure.

procedure sel-contrato.
    def var vdtinclu as date.
    disp "Aguarde... Selecionando contratos."
        with frame f-disp 1 down no-label color message no-box
        row 8.
    pause 0.
    def var vdata as date.
    do vdata = vdti to vdtf:    
    for each tt-modalidade-selec,
        each contrato where contrato.dtinicial /*#1datexp*/ = vdata
                        and contrato.modcod = tt-modalidade-selec.modcod
                      no-lock:
        disp contrato.contnum format ">>>>>>>>>9"
            with frame f-disp .
        pause 0.
            
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
            /*        tt-cont.vlentra = contrato.vlentra*/
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
                     /*otitulo.etbcobra = contrato.etbcod and*/
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

        disp titulo.titnum @ contrato.contnum with frame f-disp.
        pause 0.

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

procedure p-seleciona-modal:
            
{sklcls.i
    &File   = tt-modalidade-padrao
    &help   = "                ENTER=Marca F4=Retorna F8=Marca Tudo"
    &CField = tt-modalidade-padrao.modcod    
    &Ofield = " tt-modalidade-padrao.modcod"
    &Where  = " true"
    &noncharacter = /*
    &LockType = "NO-LOCK"
    &UsePick = "*"          
    &PickFld = "tt-modalidade-padrao.modcod" 
    &PickFrm = "x(4)" 
    &otherkeys1 = "
        if keyfunction(lastkey) = ""CLEAR""
        then do:
            V-CONT = 0.
            for each tt-modalidade-padrao no-lock:
                a-seelst = a-seelst + "","" + tt-modalidade-padrao.modcod.
                v-cont = v-cont + 1.
            end.
            message ""                         SELECIONADAS "" 
            V-CONT ""FILIAIS                                   ""
            .
                         a-seeid = -1.
            a-recid = -1.
            next keys-loop.
        end. "
    &Form = " frame f-nome" 
}. 

hide frame f-nome.
v-cont = 2.
repeat :
    v-cod = "".
    if num-entries(a-seelst) >= v-cont
    then v-cod = entry(v-cont,a-seelst).

    v-cont = v-cont + 1.

    if v-cod = ""
    then leave.
    create tt-modalidade-selec.
    assign tt-modalidade-selec.modcod = v-cod.
end.


end.


