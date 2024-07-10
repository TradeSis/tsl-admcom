/***********
connect ninja -H db2 -S sdrebninja -N tcp.
connect sensei -H db2 -S ssensei -N tcp.
connect nissei -H db2 -S 60002 -N tcp.
*********/

{admcab.i}

def temp-table tt-titpag
    field clifor like titulo.clifor
    field clinom like clien.clinom
    field cpf    like clien.ciccgc
    field titnum like titulo.titnum
    field titpr  like titulo.titpar
    field titdtven like titulo.titdtven
    field titdtpag like titulo.titdtpag
    field titvlcob like titulo.titvlcob
    field titvlpag like titulo.titvlpag
    .
def temp-table tt-titmoe
    field moeda as char format "x(20)"
    field valor as dec format ">>>,>>>,>>9.99"
    index i1 moeda.
    
def var vdti as date.
def var vdtf as date.
update vdti label "Periodo" 
        vdtf no-label 
        with frame f1 side-label width 80.
if vdti = ? or vdtf = ? or
    vdti > vdtf
then return.
    
def var vlebes as log format "Sim/Nao".
def var vfinan as log format "Sim/Nao".
update vlebes at 1 label "Parcelas Lebes?" with frame f1.
update vfinan at 1 label "Parcelas Financeira?" with frame f1.
if not vlebes and not vfinan then return.

def var vdata as date.
do vdata = vdti to vdtf:
def var v-moeda as char.
disp vdata at 40 no-label with frame f1 .
pause 0.
    for each titulo where 
         titulo.titnat  = no and
         titulo.titdtpag = vdata and
         titulo.titdtven <= vdata - 181 
         no-lock:
         find clien where clien.clicod = titulo.clifor no-lock.

        if not vlebes and titulo.cobcod < 10 then next.
        if not vfinan and titulo.cobcod > 9 then next.
         
        create tt-titpag.
        assign
        tt-titpag.clifor = titulo.clifor
        tt-titpag.clinom = clien.clinom
        tt-titpag.cpf    = clien.ciccgc
        tt-titpag.titnum = titulo.titnum
        tt-titpag.titpr  = titulo.titpar
        tt-titpag.titdtven = titulo.titdtven
        tt-titpag.titdtpag = titulo.titdtpag
        tt-titpag.titvlcob = titulo.titvlcob
        tt-titpag.titvlpag = titulo.titvlpag
        .   

        v-moeda = "".
        v-moeda = titulo.moecod.
        /*
        else do:    
        find first opctbval where
             opctbval.etbcod = titulo.etbcobra and
             opctbval.datref = titulo.titdtpag and
             opctbval.t1 = "RECEBIMENTO" and
             opctbval.t6 = "FINANCEIRA" and
             opctbval.t7 = "PRINCIPAL" and
             opctbval.t8 <> "" and
             opctbval.t9 = titulo.titnum and
             opctbval.t0 = string(titulo.titpar)
                     no-lock no-error.
        if avail opctbval
        then v-moeda = opctbval.t8.
        end.
        */
        if v-moeda = "PDM"
        then do:
            find first titpag where
                       titpag.empcod = titulo.empcod and
                       titpag.titnat = titulo.titnat and
                       titpag.modcod = titulo.modcod and
                       titpag.etbcod = titulo.etbcod and
                       titpag.clifor = titulo.clifor and
                       titpag.titnum = titulo.titnum and
                       titpag.titpar = titulo.titpar
                       no-lock no-error.
            if avail titpag
            then v-moeda = titpag.moecod.
        end.
        find moeda where moeda.moecod = v-moeda no-lock no-error.
        if avail moeda
        then v-moeda = v-moeda + "-" + moeda.moenom. 
        find first tt-titmoe where
                   tt-titmoe.moeda = v-moeda no-error.
        if not avail tt-titmoe
        then do:
            create tt-titmoe.
            tt-titmoe.moeda = v-moeda.
        end.
        tt-titmoe.valor = tt-titmoe.valor + titulo.titvlcob.
                   
     end.
end.

def var varquivo as char.
varquivo = "/admcom/relat/pagamento-incobraveis.txt".
{mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "80" 
                &Page-Line = "66" 
                &Nom-Rel   = """" "" 
                &Nom-Sis   = """ADMCOM - CREDIARIO""" 
                &Tit-Rel   = """ RECEBIMENTO INCOBRAVEIS """ 
                &Width     = "120"
                &Form      = "frame f-cabcab"}

disp vdti vdtf with frame f1 . 

for each tt-titpag:
    disp tt-titpag.clifor 
        tt-titpag.clinom 
        tt-titpag.cpf    
        tt-titpag.titnum 
        tt-titpag.titpr  
        tt-titpag.titdtven 
        tt-titpag.titdtpag 
        tt-titpag.titvlcob(total)
        with frame f-disp down width 150
         .
    down with frame f-disp.
end.

for each tt-titmoe:
    disp tt-titmoe with no-label.
end.    
output close.

run visurel.p(varquivo,"").
