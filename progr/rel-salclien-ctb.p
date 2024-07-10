{admcab.i}

def var varquivo    as char.
def var varquivo1   as char.
def var varquivo2   as char.
def var varquivo3   as char.

def var vnum-dias as int.
def var vincob as log.
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
    field forcgc like clien.ciccgc
    field titnum like fin.titulo.titnum
    field titpar like fin.titulo.titpar
    field modcod like fin.titulo.modcod
    field titdtemi like fin.titulo.titdtemi
    field titdtent like plani.dtinclu
    field titdtven like fin.titulo.titdtven
    field titdtpag like fin.titulo.titdtpag
    field titvlcob like fin.titulo.titvlcob
    field titvlpag like fin.titulo.titvlpag
    field titvldes like fin.titulo.titvldes
    field titsit   like fin.titulo.titsit
    field etbcod   like fin.titulo.etbcod
    index i1 forcod.

def temp-table tt-incob
    field forcod like forne.forcod
    field fornom like forne.fornom
    field forcgc like clien.ciccgc
    field titnum like fin.titulo.titnum
    field titpar like fin.titulo.titpar
    field modcod like fin.titulo.modcod
    field titdtemi like fin.titulo.titdtemi
    field titdtent like plani.dtinclu
    field titdtven like fin.titulo.titdtven
    field titdtpag like fin.titulo.titdtpag
    field titvlcob like fin.titulo.titvlcob
    field titvlpag like fin.titulo.titvlpag
    field titvldes like fin.titulo.titvldes
    field titsit   like fin.titulo.titsit
    field etbcod   like fin.titulo.etbcod
    index i1 forcod.

form
        with frame f01 side-labels .

def var vcsv as log format "Sim/Nao".

assign v-ano = year(today).

vdatref = date(month(today),01,year(today)) - 1.

vforcod = 0.    
vanalitico = yes.
vcsv = yes.
update vdatref at 1 format "99/99/9999" label "Data referencia"
       help "Informe a data de referencia para saldo." 
       vnum-dias label "Informe dias de atraso para incobraveis"
       help "Informe zero para não gerar incobraveis."
       /*vanalitico at 1 label "Relatorio Analitico"
       vcsv at 1 label "Gerar Excel" */
       with frame f01 width 80.
        
vdt-aux = vdatref.        
def var vok as log.
def var vtp as char
.
if vanalitico
then vtp = "a_".
else vtp = "s_".


def buffer btabdac for tabdac.
def var vdirearq as char.
def var vnomearq as char.
def var vnomearq1 as char.
def var vnomearq2 as char.
def var vnomearq3 as char.
vdirearq = "/admcom/relat/".
vnomearq = "relsalclienctb" 
                    + "_"
                    + string(vdatref,"99999999")
                    + "___"
                    + string(time)
                    + ".csv".
vnomearq1 = "relsalclienctb" 
                    + "_"
                    + string(vdatref,"99999999")
                    + "___"
                    + string(time)
                    + ".txt".

vnomearq2 = "relincobclienctb" 
                    + "_"
                    + string(vdatref,"99999999")
                    + "___"
                    + string(time)
                    + ".csv".

vnomearq3 = "relincobclienctb" 
                    + "_"
                    + string(vdatref,"99999999")
                    + "___"
                    + string(time)
                    + ".txt".


def var vqtd as int.
vqtd = 0.
def var vdtinclu like plani.dtinclu.

def var vi as int.
for each fin.titulo where      
                           fin.titulo.empcod = 19 and
                          fin.titulo.titnat = no    and
                          fin.titulo.modcod = "CRE" and
                          (fin.titulo.titdtpag >  vdt-aux or
                           fin.titulo.titdtpag = ?) and
                             fin.titulo.titdtemi <= vdt-aux
                              no-lock .
        

        if fin.titulo.titsit = "EXC" or
           fin.titulo.titsit = "CAN"                         
        then next.
        
        if fin.titulo.clifor = 0 then next.
        if fin.titulo.clifor = 1 then next.
        if fin.titulo.clifor = 1513 then next.
        if fin.titulo.clifor = 1313 then next.


        disp "Processando ...  " fin.titulo.clifor fin.titulo.titnum
            with frame frame-f 1 down no-label row 10 centered color message
            no-box.
        pause 0.   
        
        vok = yes.
        if fin.titulo.titdtemi >= 02/01/2009
        then run ver-emissao(input fin.titulo.etbcod,
                             input fin.titulo.clifor,
                             input fin.titulo.titnum,
                             input fin.titulo.titdtemi).
        if vok = no then next.
        
        /*                     
        find first tabdac where
                   tabdac.etbcod = fin.titulo.etbcod and
                   tabdac.clicod = fin.titulo.clifor and
                   tabdac.numlan = fin.titulo.titnum and
                   tabdac.parlan = ? and
                   tabdac.datemi = fin.titulo.titdtemi and
                   (tabdac.tiplan = "EMISSAO")
                   tabdac.tiplan <> "EMISSAO" and
                       tabdac.tiplan <> "EMICANFINAN" and
                           tabdac.tiplan <> "EMINOVACAO" and
                               substr(tabdac.tiplan,1,12) <> "RENEGOCIACAO" and
                                   tabdac.tiplan <> "FINESTEMI" and
                                       tabdac.tiplan <> "EMICANFIN" AND
                                       
                   no-lock no-error.
        if not avail tabdac and fin.titulo.titdtemi >= 02/01/2009
        then next.           
        **/

        run p-carrega-tt.

        vi = vi + 1.
        /*
        if vi = 50 then leave.
        */
end.
for each d.titulo where      
                           d.titulo.empcod = 19 and
                          d.titulo.titnat = no    and
                          d.titulo.modcod = "CRE" and
                          (d.titulo.titdtpag >  vdt-aux or
                           d.titulo.titdtpag = ?)  and
                            d.titulo.titdtemi <= vdt-aux
                              no-lock .
        

        if d.titulo.titsit = "EXC" or
           d.titulo.titsit = "CAN"                         
        then next.
        
        if d.titulo.clifor = 0 then next.
        if d.titulo.clifor = 1 then next.
        if d.titulo.clifor = 1513 then next.
        if d.titulo.clifor = 1313 then next.


        disp "Processando ...  " d.titulo.clifor d.titulo.titnum
            with frame frame-fff 1 down no-label row 10 centered color message
            no-box.
        pause 0.   

        vok = yes.
        if d.titulo.titdtemi >= 02/01/2009
        then run ver-emissao(input d.titulo.etbcod,
                             input d.titulo.clifor,
                             input d.titulo.titnum,
                             input d.titulo.titdtemi).
        if vok = no then next.
                    
        run p-carrega-dtt.

        vi = vi + 1.
        /*
        if vi = 50 then leave.
        */
end.

for each contratodd where contratodd.dtinicial <= vdt-aux  
    and contratodd.situacao = 2 no-lock:

    /*
    find first titulodd where
               titulodd.empcod = 19 and
               titulodd.titnat = no    and
               titulodd.modcod = "CRE" and
               titulodd.etbcod = contratodd.etbcod and
               titulodd.clifor = contratodd.clicod and
               titulodd.titnum = string(contratodd.cont-num)
               no-lock no-error.
    if avail titulodd and
             titulodd.titsit = "PAG" and
             titulodd.titdtpag <= vdt-aux
    then next.
          
    find first titulosal where
               titulosal.empcod = 19 and
               titulosal.titnat = no and
               titulosal.modcod = "CRE" and
               titulosal.etbcod = contratodd.etbcod and
               titulosal.clifor = contratodd.clicod and
               titulosal.titnum = string(contratodd.cont-num)
               no-lock no-error.
    if avail titulosal and
             titulosal.titsit = "PAG" and
             titulosal.titdtpag <= vdt-aux
    then next.
    */
           
    if contratodd.clicod = 0 then next.
    if contratodd.clicod = 1 then next.
    if contratodd.clicod = 1513 then next.
    if contratodd.clicod = 1313 then next.


        disp "Processando ...  " contratodd.clicod contratodd.cont-num
            with frame frame-ff 1 down no-label row 10 centered color message
            no-box.
        pause 0.   

    vok = yes.

    run ver-emissao(input contratodd.etbcod,
                             input contratodd.clicod,
                             input string(contratodd.cont-num),
                             input contratodd.dtinicial).
    if vok = no then next.
              
    find first btabdac where
                   btabdac.etbcod = contratodd.etbcod and
                   btabdac.clicod = contratodd.clicod and
                   btabdac.numlan = string(contratodd.cont-num) and
                   btabdac.parlan = 1 and
                   btabdac.datemi = contratodd.dtinicial and
                   btabdac.tiplan = "RECEBIMENTO"
                   no-lock no-error.
    if avail btabdac and btabdac.datlan <= vdt-aux 
    then next.                 

    run p-carrega-dd.

end.

def var vtotsaldo as dec format ">>>,>>>,>>9.99" init 0.
def var vtotincob as dec format ">>>,>>>,>>9.99" init 0.
vtotsaldo = 0.
run p-gera-arquivo-sal-analitico.
vtotincob = 0.
run p-gera-arquivo-incob-analitico.

def var vs as int.
vs = 0.
repeat on endkey undo:

if keyfunction(lastkey) = "END-ERROR"
then leave.

if vnum-dias > 0
then do:
message color red/with
    "Arquivos gerados  ...  SALDO:" varquivo1 SKIP    "                             " varquivo skip
    "                 SALDO TOTAL:" string(vtotsaldo,">>>,>>>,>>9.99") skip
    "Arquivos gerados INCOBRAVEIS:" varquivo3 SKIP
    "                             " varquivo2 skip
    "           SALDO INCOBRAVEIS:" string(vtotincob,">>>,>>>,>>9.99") skip  
    view-as alert-box.
    sresp = no.
    message "Deseja imprimir saldo de clientes?" update sresp.
    if sresp
    then do:
        run visurel.p(varquivo1,"").
    end.
    sresp = no.
    message "Deseja imprimir saldo de incobraveis?" update sresp.
    if sresp
    then do:
        run visurel.p(varquivo3,"").
    end.
end.
else do:
    message color red/with
    "Arquivos gerados  ...  SALDO:" varquivo1 SKIP    
    "                             " varquivo skip
    "                 SALDO TOTAL:" string(vtotsaldo,">>>,>>>,>>9.99") skip
    view-as alert-box.
    
    run visurel.p(varquivo1,"").
    
end.

vs = vs + 1.
if vs = 2 then leave.
end.

/****************
if vanalitico
then run p-gera-arquivo-analitico.
else run p-gera-arquivo-sintetico.

/*if vcsv = no 
then*/ do:
    run visurel.p(varquivo1,"").
end.
*****************/

procedure p-carrega-tt.

    find first clien where clien.clicod = fin.titulo.clifor no-lock no-error.

    create tt-ana.
    assign
            tt-ana.forcod = fin.titulo.clifor
            tt-ana.fornom = if avail clien then clien.clinom
                        else "Nao Cadastrado"
            tt-ana.forcgc = clien.ciccgc
            tt-ana.titnum = fin.titulo.titnum
            tt-ana.titpar = fin.titulo.titpar
            tt-ana.modcod = fin.titulo.modcod
            tt-ana.titdtemi = fin.titulo.titdtemi
            tt-ana.titdtent = fin.titulo.titdtemi
            tt-ana.titdtven = fin.titulo.titdtven
            tt-ana.titdtpag = fin.titulo.titdtpag
            tt-ana.titvlcob = fin.titulo.titvlcob
            tt-ana.titvlpag = fin.titulo.titvlpag
            tt-ana.titvldes = fin.titulo.titvldes
            tt-ana.titsit   = fin.titulo.titsit
            tt-ana.etbcod   = fin.titulo.etbcod
            .

    if vnum-dias > 0 and
        fin.titulo.titdtven < vdt-aux - vnum-dias
    then do:
        create tt-incob.
        assign
            tt-incob.forcod = fin.titulo.clifor
            tt-incob.fornom = if avail clien then clien.clinom
                        else "Nao Cadastrado"
            tt-incob.forcgc = clien.ciccgc
            tt-incob.titnum = fin.titulo.titnum
            tt-incob.titpar = fin.titulo.titpar
            tt-incob.modcod = fin.titulo.modcod
            tt-incob.titdtemi = fin.titulo.titdtemi
            tt-incob.titdtent = fin.titulo.titdtemi
            tt-incob.titdtven = fin.titulo.titdtven
            tt-incob.titdtpag = fin.titulo.titdtpag
            tt-incob.titvlcob = fin.titulo.titvlcob
            tt-incob.titvlpag = fin.titulo.titvlpag
            tt-incob.titvldes = fin.titulo.titvldes
            tt-incob.titsit   = fin.titulo.titsit
            tt-incob.etbcod   = fin.titulo.etbcod
            .

    end.
                        
end procedure.

procedure p-carrega-dtt.

    find first clien where clien.clicod = d.titulo.clifor no-lock no-error.

    create tt-ana.
    assign
            tt-ana.forcod = d.titulo.clifor
            tt-ana.fornom = if avail clien then clien.clinom
                        else "Nao Cadastrado"
            tt-ana.forcgc = clien.ciccgc
            tt-ana.titnum = d.titulo.titnum
            tt-ana.titpar = d.titulo.titpar
            tt-ana.modcod = d.titulo.modcod
            tt-ana.titdtemi = d.titulo.titdtemi
            tt-ana.titdtent = d.titulo.titdtemi
            tt-ana.titdtven = d.titulo.titdtven
            tt-ana.titdtpag = d.titulo.titdtpag
            tt-ana.titvlcob = d.titulo.titvlcob
            tt-ana.titvlpag = d.titulo.titvlpag
            tt-ana.titvldes = d.titulo.titvldes
            tt-ana.titsit   = d.titulo.titsit
            tt-ana.etbcod   = d.titulo.etbcod
            .

    if vnum-dias > 0 and 
       d.titulo.titdtven < vdt-aux - vnum-dias
    then do:
        create tt-incob.
        assign
            tt-incob.forcod = d.titulo.clifor
            tt-incob.fornom = if avail clien then clien.clinom
                        else "Nao Cadastrado"
            tt-incob.forcgc = clien.ciccgc
            tt-incob.titnum = d.titulo.titnum
            tt-incob.titpar = d.titulo.titpar
            tt-incob.modcod = d.titulo.modcod
            tt-incob.titdtemi = d.titulo.titdtemi
            tt-incob.titdtent = d.titulo.titdtemi
            tt-incob.titdtven = d.titulo.titdtven
            tt-incob.titdtpag = d.titulo.titdtpag
            tt-incob.titvlcob = d.titulo.titvlcob
            tt-incob.titvlpag = d.titulo.titvlpag
            tt-incob.titvldes = d.titulo.titvldes
            tt-incob.titsit   = d.titulo.titsit
            tt-incob.etbcod   = d.titulo.etbcod
            .

    end.
                        
end procedure.


procedure p-carrega-dd.

    find first clien where clien.clicod = contratodd.clicod no-lock no-error.

    create tt-ana.
    assign
            tt-ana.forcod = contratodd.clicod
            tt-ana.fornom = if avail clien then clien.clinom
                        else "Nao Cadastrado"
            tt-ana.forcgc = clien.ciccgc
            tt-ana.titnum = string(contratodd.cont-num)
            tt-ana.titpar = 1
            tt-ana.modcod = "CRE"
            tt-ana.titdtemi = contratodd.dtinicial
            tt-ana.titdtent = contratodd.dtinicial
            tt-ana.titdtven = contratodd.dtinicial + 30
            tt-ana.titdtpag = ?
            tt-ana.titvlcob = contratodd.vltotal
            tt-ana.titvlpag = 0
            tt-ana.titvldes = 0
            tt-ana.titsit   = "LIB"
            tt-ana.etbcod   = contratodd.etbcod
            .

    if vnum-dias > 0 and 
       contratodd.dtinicial + 30 < vdt-aux - vnum-dias
    then do:
        create tt-incob.
        assign
            tt-incob.forcod = contratodd.clicod
            tt-incob.fornom = if avail clien then clien.clinom
                        else "Nao Cadastrado"
            tt-incob.forcgc = clien.ciccgc
            tt-incob.titnum = string(contratodd.cont-num)
            tt-incob.titpar = 1
            tt-incob.modcod = "CRE"
            tt-incob.titdtemi = contratodd.dtinicial
            tt-incob.titdtent = contratodd.dtinicial
            tt-incob.titdtven = contratodd.dtinicial + 30
            tt-incob.titdtpag = ?
            tt-incob.titvlcob = contratodd.vltotal
            tt-incob.titvlpag = 0
            tt-incob.titvldes = 0
            tt-incob.titsit   = "LIB"
            tt-incob.etbcod   = contratodd.etbcod
            .

    end.
                        
end procedure.



procedure p-gera-arquivo-sal-analitico:


    /*if vcsv
    then*/ 
    do:
    varquivo = vdirearq + vnomearq.
    output to value(varquivo).

    put
   "Cliente"
   vsp
   "Nome"
   vsp
   "C.P.F."
   vsp
   "Titulo"
   vsp
   "Valor"
   vsp
   "Dt.Emissao"
   vsp
   "DT.Vencimento"
   skip.
   
   for each tt-ana no-lock:
        if tt-ana.titvlcob < 0 then next.
        
        put
        tt-ana.forcod format ">>>>>>>>>9"
        vsp
        tt-ana.fornom format "x(60)"
        vsp
        tt-ana.forcgc
        vsp
        tt-ana.titnum
        vsp
        tt-ana.titvlcob
        vsp
        tt-ana.titdtemi
        vsp
        tt-ana.titdtven
        skip.
   end.

   output close.


   end.
   /*else*/ do:
        varquivo1 = vdirearq + vnomearq1.
        {mdad.i
            &Saida     = "value(varquivo1)"
            &Page-Size = "0"
            &Cond-Var  = "120"
            &Page-Line = "0"
            &Nom-Rel   = ""sal_for1""
            &Nom-Sis   = """SISTEMA DE CONTABILIDADE"""
            &Tit-Rel   = """SALDO DE CLIENTE "" + 
                          string(vdatref,""99/99/9999"")"
            &Width     = "120"
            &Form      = "frame f-cabcab"}
 
        disp with frame f01.
        for each tt-ana no-lock:
            if tt-ana.titvlcob < 0 then next.                        
                                
            /*
            if first-of(tt-ana.forcod)
            then do:
                disp 
                    tt-ana.forcod format ">>>>>>>>>9"
                        column-label "Cliente"
                    tt-ana.fornom format "x(30)"
                        column-label "Nome"
                    tt-ana.forcgc column-label "C.P.F."
                    with frame f-disp.
            end.
            */
            
            disp
                tt-ana.forcod format ">>>>>>>>>9"
                        column-label "Cliente"
                tt-ana.fornom format "x(30)"
                        column-label "Nome"
                tt-ana.forcgc column-label "C.P.F."
                tt-ana.titnum format "x(15)"
                column-label "Titulo"
                tt-ana.titvlcob(total)
                format ">>>,>>>,>>9.99"
                tt-ana.titdtent  column-label "Dt.Emissao"
                tt-ana.titdtven
                with frame f-disp width 180 down.
            down with frame f-disp.
            vtotsaldo = vtotsaldo + tt-ana.titvlcob.
        end.
        output close.
    end.

end procedure.

procedure p-gera-arquivo-incob-analitico:

    varquivo2 = vdirearq + vnomearq2.
    output to value(varquivo2).

    put
   "Cliente"
   vsp
   "Nome"
   vsp
   "C.P.F."
   vsp
   "Titulo"
   vsp
   "Valor"
   vsp
   "Dt.Emissao"
   vsp
   "DT.Vencimento"
   skip.
   
   for each tt-incob no-lock:
        if tt-incob.titvlcob < 0 then next.
        
        put
        tt-incob.forcod format ">>>>>>>>>9"
        vsp
        tt-incob.fornom format "x(60)"
        vsp
        tt-incob.forcgc
        vsp
        tt-incob.titnum
        vsp
        tt-incob.titvlcob
        vsp
        tt-incob.titdtemi
        vsp
        tt-incob.titdtven
        skip.
   end.

   output close.


   do:
        varquivo3 = vdirearq + vnomearq3.
        
        {mdad.i
            &Saida     = "value(varquivo3)"
            &Page-Size = "0"
            &Cond-Var  = "120"
            &Page-Line = "0"
            &Nom-Rel   = ""sal_for1""
            &Nom-Sis   = """SISTEMA DE CONTABILIDADE"""
            &Tit-Rel   = """SALDO DE CLIENTE "" + 
                          string(vdatref,""99/99/9999"")"
            &Width     = "120"
            &Form      = "frame f-cabcab"}
 
        disp with frame f01.
        for each tt-incob no-lock:
            if tt-incob.titvlcob < 0 then next.                        
                                
            /*
            if first-of(tt-incob.forcod)
            then do:
                disp 
                    tt-incob.forcod format ">>>>>>>>>9"
                        column-label "Cliente"
                    tt-incob.fornom format "x(30)"
                        column-label "Nome"
                    tt-incob.forcgc column-label "C.P.F."
                    with frame f-disp.
            end.
            */
            
            disp
                tt-incob.forcod format ">>>>>>>>>9"
                        column-label "Cliente"
                tt-incob.fornom format "x(30)"
                        column-label "Nome"
                tt-incob.forcgc column-label "C.P.F."
                tt-incob.titnum format "x(15)"
                column-label "Titulo"
                tt-incob.titvlcob(total)
                format ">>>,>>>,>>9.99"
                tt-incob.titdtent  column-label "Dt.Emissao"
                tt-incob.titdtven
                with frame f-disp width 180 down.
            down with frame f-disp.
            vtotincob = vtotincob + tt-incob.titvlcob.
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

procedure ver-emissao:
    def input parameter p-etbcod like fin.titulo.etbcod.
    def input parameter p-clifor like fin.titulo.clifor.
    def input parameter p-titnum like fin.titulo.titnum.
    def input parameter p-datemi like fin.titulo.titdtemi.
    
    find first tabdac where
               tabdac.etbcod = p-etbcod and
               tabdac.clicod = p-clifor and
               tabdac.numlan = p-titnum and
               tabdac.parlan = ? and
               tabdac.datemi = p-datemi and
               tabdac.tiplan = "EMISSAO"
               no-lock no-error.
    if not avail tabdac 
    then find first tabdac where
               tabdac.etbcod = p-etbcod and
               tabdac.clicod = p-clifor and
               tabdac.numlan = p-titnum and
               tabdac.parlan = ? and
               tabdac.datemi = p-datemi and
               tabdac.tiplan = "EMICANFINAN"
               no-lock no-error.
    if not avail tabdac 
    then find first tabdac where
               tabdac.etbcod = p-etbcod and
               tabdac.clicod = p-clifor and
               tabdac.numlan = p-titnum and
               tabdac.parlan = ? and
               tabdac.datemi = p-datemi and
               tabdac.tiplan = "EMINOVACAO"
               no-lock no-error.
    if not avail tabdac 
    then find first tabdac where
               tabdac.etbcod = p-etbcod and
               tabdac.clicod = p-clifor and
               tabdac.numlan = p-titnum and
               tabdac.parlan = ? and
               tabdac.datemi = p-datemi and
               tabdac.tiplan = "FINESTEMI"
               no-lock no-error.
    if not avail tabdac 
    then find first tabdac where
               tabdac.etbcod = p-etbcod and
               tabdac.clicod = p-clifor and
               tabdac.numlan = p-titnum and
               tabdac.parlan = ? and
               tabdac.datemi = p-datemi and
               tabdac.tiplan = "EMICANFIN"
               no-lock no-error.
    if not avail tabdac 
    then find first tabdac where
               tabdac.etbcod = p-etbcod and
               tabdac.clicod = p-clifor and
               tabdac.numlan = p-titnum and
               tabdac.parlan = ? and
               tabdac.datemi = p-datemi and
               tabdac.tiplan begins "RENEGO"
               no-lock no-error.


    if avail tabdac 
    then.
    else vok = no.  
end procedure.        
