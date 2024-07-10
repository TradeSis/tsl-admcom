{admcab.i}

def var varquivo    as char.
def var varquivo2   as char.
def var vdt-aux     as date.
def var v-ano       as integer.
def var vsp         as char initial ";".
def var vforcod     like forne.forcod.
def var vdatref as date.
def var vanalitico as log format "Sim/Nao".

def temp-table tt-forne
    field forcod as integer
    field fornom as char
    field saldo as decimal
    index idx01 forcod.

def temp-table tt-ana
    field forcod like forne.forcod
    field fornom like forne.fornom
    field titnum like titulo.titnum
    field titpar like titulo.titpar
    field modcod like titulo.modcod
    field titdtemi like titulo.titdtemi
    field titdtent like plani.dtinclu
    field titdtven like titulo.titdtven
    field titdtpag like titulo.titdtpag
    field titvlcob like titulo.titvlcob
    field titvlpag like titulo.titvlpag
    field titvldes like titulo.titvldes
    field titsit   like titulo.titsit
    field etbcod   like titulo.etbcod
    index i1 forcod.

form
        with frame f01 side-labels .

def var vcsv as log format "Sim/Nao".

assign v-ano = year(today).

vdatref = date(month(today),01,year(today)) - 1.

vforcod = 0.    
update  vforcod at 1 label "Fornecedor"
        help "Informe 0 para todos os fornecedores."
        with frame f01 width 80.

if vforcod > 0
then do:        
    find forne where forne.forcod = vforcod no-lock no-error.
    if not avail forne then undo.
    disp forne.fornom no-label with frame f01.
end.
else disp "Todos os fornecedores" @ forne.fornom with frame f01.

update vdatref at 1 format "99/99/9999" label "Data referencia"
       help "Informe a data de referencia para saldo." 
       vanalitico at 1 label "Relatorio Analitico"
       vcsv at 1 label "Gerar Excel" 
       with frame f01 width 80.
        
vdt-aux = vdatref.        

def var vtp as char
.
if vanalitico
then vtp = "a_".
else vtp = "s_".

varquivo = "/admcom/audit/fornecedores/list_sald_" + vtp
                    + trim(string(vforcod,">>>>>>>>>9"))
                    + "_"
                    + string(vdatref,"99999999")
                    + "___"
                    + string(time)
                    + ".csv".

varquivo2 = "/admcom/audit/fornecedores/list_sald_" + vtp
                    + trim(string(vforcod,">>>>>>>>>9"))
                    + "_"
                    + string(vdatref,"99999999")
                    + "___"
                    + string(time)
                    + ".txt".


def var vqtd as int.
vqtd = 0.

for each titulo where (if vforcod > 0 
                           then titulo.clifor = vforcod else true) and 
                           titulo.empcod = 19 and
                          titulo.titnat = yes    and
                          /*titulo.titdtemi <= vdt-aux and*/
                          (titulo.titdtpag >  vdt-aux or
                           titulo.titdtpag = ?)   /*(Ex. 31/12/2008)*/
                              no-lock .
        
        if titulo.titsit = "EXC"                              
        then next.

        if titulo.clifor =  110165     /* Descarta Cartao Presente */
            or titulo.modcod = "bon"   /* Descarta Bonus           */
        then next.

        
        find first plani where
                   plani.pladat = titulo.titdtemi and
                   plani.etbcod = titulo.etbcod and
                   plani.emite  = titulo.clifor and
                   plani.numero = int(titulo.titnum)
                   no-lock no-error.
        if avail plani and plani.dtinclu > vdt-aux
        then next.
        else if not avail plani and titulo.titdtemi > vdt-aux
             then next.

        run p-carrega-tt.

        disp "Processando ...  " titulo.clifor titulo.titnum
            with 1 down no-label row 10 centered color message
            no-box.
        pause 0.    
end.

if vanalitico
then run p-gera-arquivo-analitico.
else run p-gera-arquivo-sintetico.

if vcsv = no 
then do:
    run visurel.p(varquivo2,"").
end.

procedure p-carrega-tt.

    find first tt-forne where tt-forne.forcod = titulo.clifor
                            exclusive-lock no-error.
                            
    find first forne where forne.forcod = titulo.clifor no-lock no-error.

    if not avail tt-forne
    then do:
        
        create tt-forne.
        assign tt-forne.forcod = titulo.clifor
               tt-forne.fornom = if avail forne then forne.fornom
                                    else "Desconhecido".
        
    end.                        
    
    assign tt-forne.saldo = tt-forne.saldo + titulo.titvlcob.
    
    create tt-ana.
    assign
            tt-ana.forcod = titulo.clifor
            tt-ana.fornom = if avail forne then forne.fornom
                        else "Nao Cadastrado"
            tt-ana.titnum = titulo.titnum
            tt-ana.titpar = titulo.titpar
            tt-ana.modcod = titulo.modcod
            tt-ana.titdtemi = titulo.titdtemi
            tt-ana.titdtent = if avail plani 
                              then plani.dtinclu
                              else titulo.titdtemi
            tt-ana.titdtven = titulo.titdtven
            tt-ana.titdtpag = titulo.titdtpag
            tt-ana.titvlcob = titulo.titvlcob
            tt-ana.titvlpag = titulo.titvlpag
            tt-ana.titvldes = titulo.titvldes
            tt-ana.titsit   = titulo.titsit
            tt-ana.etbcod   = titulo.etbcod
            .

end procedure.


procedure p-gera-arquivo-analitico:

    if vcsv
    then do:
    
    output to value(varquivo).

    put
   "Cod.Forne"
   vsp
   "Razão Social"
   vsp
   "Título"
   vsp
   "Parcela"
   vsp
   "MT"
   vsp
   "DT. Emissao"
   vsp
   "DT. Entrada"
   vsp
   "DT. Vencimento"
   vsp
   "DT. Pagamento"
   vsp
   "VL. Cobrado"
   vsp
   "VL. Pago"
   vsp
   "VL. Desconto"
   vsp
   "Sit"
   vsp
   "Fil" skip.

    for each tt-ana break by tt-ana.forcod:
        
        put
        tt-ana.forcod format ">>>>>>>>>9"
        vsp
        tt-ana.fornom format "x(60)"
        vsp
        tt-ana.titnum
        vsp
        tt-ana.titpar format ">>>>>>>>>9"
        vsp
        tt-ana.modcod
        vsp
        tt-ana.titdtemi
        vsp
        tt-ana.titdtent
        vsp
        tt-ana.titdtven
        vsp
        tt-ana.titdtpag
        vsp
        tt-ana.titvlcob
        vsp
        tt-ana.titvlpag
        vsp
        tt-ana.titvldes
        vsp
        tt-ana.titsit
        vsp
        tt-ana.etbcod skip.
    end.

    output close.
    message "Arquivo Gerado em : " varquivo view-as alert-box title "ATENÇÃO!!!
    ".
    end.
    else do:
        {mdad.i
            &Saida     = "value(varquivo2)"
            &Page-Size = "0"
            &Cond-Var  = "170"
            &Page-Line = "0"
            &Nom-Rel   = ""sal_for1""
            &Nom-Sis   = """SISTEMA DE CONTABILIDADE"""
            &Tit-Rel   = """SALDO DE FORNECEDOR "" + 
                          string(vdatref,""99/99/9999"")"
            &Width     = "170"
            &Form      = "frame f-cabcab"}
 
        disp with frame f01.
        for each tt-ana break by tt-ana.forcod:
        
            if first-of(tt-ana.forcod)
            then do:
                disp 
                    tt-ana.forcod format ">>>>>>>>>9"
                    tt-ana.fornom format "x(30)"
                    with frame f-disp.
            end.
            
            disp
                tt-ana.titnum format "x(15)"
                tt-ana.titpar format ">>>>>>>>>9"
                tt-ana.modcod
                tt-ana.titdtemi
                tt-ana.titdtent
                tt-ana.titdtven
                tt-ana.titdtpag
                tt-ana.titvlcob(total by tt-ana.forcod)
                        format ">>>,>>>,>>9.99"
                tt-ana.titvlpag(total by tt-ana.forcod)
                        format ">>>,>>>,>>9.99"
                tt-ana.titvldes(total by tt-ana.forcod)
                tt-ana.titsit
                tt-ana.etbcod 
                with frame f-disp width 180 down.
            down with frame f-disp.
        end.
        output close.
    end.

end procedure.

procedure p-gera-arquivo-sintetico:

    if vcsv
    then do:
    output to value(varquivo).

    for each tt-forne no-lock by tt-forne.forcod.

        put tt-forne.forcod format ">>>>>>>>>>>>>>9"
            ";"
            tt-forne.fornom format "x(40)"
            ";"
            tt-forne.saldo format "->>>,>>>,>>>,>>>,>>9.99" skip.

    end.
    
    output close.
    
    message "Arquivo SINTETICO gerado em: " varquivo view-as alert-box title "ATENÇÃO!".
    end.
    else do:
        {mdad.i
            &Saida     = "value(varquivo2)"
            &Page-Size = "0"
            &Cond-Var  = "130"
            &Page-Line = "0"
            &Nom-Rel   = ""sal_for1""
            &Nom-Sis   = """SISTEMA DE CONTABILIDADE"""
            &Tit-Rel   = """SALDO DE FORNECEDOR "" + 
                          string(vdatref,""99/99/9999"")"
            &Width     = "130"
            &Form      = "frame f-cabcab"}
 
        disp with frame f01.
        for each tt-forne no-lock by tt-forne.forcod.

            disp tt-forne.forcod format ">>>>>>>>>>>>>>9"
                 tt-forne.fornom format "x(40)"
                 tt-forne.saldo (total) 
                 format "->>>,>>>,>>>,>>>,>>9.99" 
                 with frame f-disp1 width 130 down.

        end.

        output close.
    end.
    
end procedure.

