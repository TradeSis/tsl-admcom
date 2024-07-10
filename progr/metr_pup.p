{admcab.i}

def temp-table tt-sel
    field etbcod like plani.etbcod 
    field clifor like plani.desti
    field qtdp    as int
    field qtdr    as int
    field valor  as dec
    index i1 etbcod clifor.

def temp-table tt-clien
    field clicod like clien.clicod.

def new shared temp-table tt-cli
    
    field clicod like clien.clicod
    field clinom like clien.clinom
    
    index iclicod is primary unique clicod.
 
def var vqtd as int.    
def var vetbcod like estab.etbcod .
def var vetbcod1 like estab.etbcod.
def var vclifor like titulo.clifor.
def var vtipo as char extent 2 format "x(15)"
    init["ANALITICO","SINTETICO"].
    
def var vindex as int.
def var vdtini as date .
def var vdtfin as date.

def buffer btitulo for titulo.
def buffer ctitulo for titulo.
def buffer dtitulo for titulo.

/*
update vetbcod label "Filial" 
       vetbcod1 label  "Ate Filial" 
       with frame f-upd 1 down width 80 side-label.
*/

disp  vetbcod label "Filial" 
      "" @ estab.etbnom
       /* vetbcod1 label  "Ate Filial" */
       with frame f-upd 1 down width 80 side-label.

{selestab.i vetbcod f-upd}
        
update vdtini at 1  label "Periodo de"
       vdtfin label "Ate" 
       with frame f-upd.
disp vtipo with frame f-sel 1 down centered no-label.
choose field vtipo with frame f-sel.
vindex = frame-index.
def var vdata as date.
def var vok as log.


/* Antonio */
for each tt-lj, first estab where estab.etbcod = tt-lj.etbcod no-lock:

/*
for each estab where  estab.etbcod >= vetbcod and
        estab.etbcod <= vetbcod1 
                    no-lock.
*/
    disp estab.etbcod with frame f1. pause 0.
    for each tt-clien:
        delete tt-clien.
    end.    
    do vdata = vdtini to vdtfin:
        disp vdata with frame f1 no-label.
        pause 0.

        for each titulo where /*titulo.empcod = 19 and
                      titulo.titnat = no and
                      titulo.modcod = "CRE" and*/
                      titulo.etbcobra = estab.etbcod and    
                      titulo.titdtpag = vdata  and
                      titulo.titnat = no and
                      titulo.modcod = "CRE"
                      no-lock by titulo.clifor by titulo.titnum by
                                                           titulo.titpar. 
            disp titulo.titnum with frame f1.
            pause 0.

            if titulo.titpar > 0 and
               titulo.titdtemi = titulo.titdtpag 
            then next.

            /* listar somente qdo for última parcela - Ch.22429 */
            if can-find(first dtitulo 
                                where dtitulo.empcod = titulo.empcod and
                                      dtitulo.titnat = titulo.titnat and
                                      dtitulo.modcod = titulo.modcod and
                                      dtitulo.etbcod = titulo.etbcod and
                                      dtitulo.clifor = titulo.clifor and
                                      dtitulo.titnum = titulo.titnum and
                                      dtitulo.titpar > titulo.titpar)
             then next.


            find first dtitulo where 
                       dtitulo.clifor = titulo.clifor and
                       dtitulo.titnum <> titulo.titnum
                        no-lock no-error.
            if not avail dtitulo
            then next.            
                     

            if titulo.clifor = 1 then next.
            if titulo.titdtven - titulo.titdtemi < 60
            then next.
            if titulo.moecod = "NOV"
            then next.
    
   
            find first btitulo where
               btitulo.clifor   = titulo.clifor and
               btitulo.titdtemi < vdtini and
               btitulo.titdtven > vdata and
               (btitulo.titsit = "LIB" or
                btitulo.titdtpag > vdata)
                              no-lock no-error.
            if avail btitulo
            then next.

            
            find first ctitulo where 
               ctitulo.clifor   = titulo.clifor and
               ctitulo.titnum   = btitulo.titnum and
               ctitulo.titpar  < btitulo.titpar and
               ( ctitulo.titsit  = "LIB"  or
                ctitulo.titdtpag > vdata)  
                              no-lock no-error.
            if avail ctitulo
            then do:
        
                 disp ctitulo.titnum ctitulo.titpar ctitulo.titsit .
                 
                 find first tt-clien where
                      tt-clien.clicod = titulo.clifor
                      no-error.
                 if avail tt-clien
                 then delete tt-clien.
                 next.                          
            end.
    
    find first tt-clien where
               tt-clien.clicod = titulo.clifor
               no-error.
    if not avail tt-clien
    then do:
        create tt-clien.
        tt-clien.clicod = titulo.clifor.
    end.
    else next.
               
    if vindex = 1
    then assign
                vetbcod = 0 vclifor = titulo.clifor.
    else assign
                vetbcod = titulo.etbcobra vclifor = 0.
        
    find first tt-sel where
                   tt-sel.etbcod = vetbcod  and
                   tt-sel.clifor = vclifor no-error.
    if not avail tt-sel
    then do:           
            create tt-sel.
            assign
                tt-sel.etbcod = vetbcod
                tt-sel.clifor = vclifor.
    end.
    tt-sel.qtdp = tt-sel.qtdp + 1.
    vok = no.
    for each contrato where 
             contrato.etbcod = estab.etbcod and
             contrato.clicod = titulo.clifor and
             contrato.dtinicial = titulo.titdtpag
             no-lock.
        vok = yes.
        tt-sel.valor = tt-sel.valor + contrato.vltotal + contrato.vlentra.
    
    end.
    if vok = yes
    then tt-sel.qtdr = tt-sel.qtdr + 1.

end.
end.
end.

def var vqtdp as int.
def var vqtdr as int.
def var vind as dec.
def var tvind as dec.
def var vvalor as dec.
form with frame f-disp.
form with frame f-disp1.

def var varquivo as char.
if opsys = "UNIX"
then varquivo = "/admcom/relat/metrpdm." + string(time).
else varquivo = "l:\relat\metrpdb." + string(time).

def var vrelat as log format "Sim/Nao".
def var vacao as log format "Sim/Nao".

repeat:
    vrelat = no . vacao = no.
    
    if vindex = 2
    then vrelat = yes.
    else do:
    update vrelat label "Relatorio"
           vacao   label "Acao"
           with frame f-tipo 1 down centered row 10 side-label.
    end.
    if vrelat = no and vacao = no
    then leave.       
    if vrelat
    then do:
{mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "100"
        &Page-Line = "66"
        &Nom-Rel   = ""nf_conf""
        &Nom-Sis   = """SISTEMA FINANCEIRO"""
        &Tit-Rel   = """    METRICA FIQUE AQUI    """
        &Width     = "100"
        &Form      = "frame f-cabcab"}
 
disp with frame f-upd.

if vindex = 1
then do:
vqtdp = 0. vqtdr = 0. vvalor = 0.  vind = 0. tvind = 0.
for each tt-sel :
    find clien where clien.clicod = tt-sel.clifor no-lock.
    if tt-sel.valor > 0
    then do:
        disp tt-sel.clifor  format ">>>>>>>>9"
         clien.clinom  no-label format "x(20)"
         tt-sel.valor  column-label "Valor venda"  
         format ">>>,>>>,>>>.99"
         with frame f-disp down width 100.
         down with frame f-disp.
        vqtdr = vqtdr + 1.
        vvalor = vvalor + tt-sel.valor.
    end.
    vqtdp = vqtdp + 1.
end.    
    
    down(1) with frame f-disp.
     
    tvind = (vqtdr / vqtdp) * 100.
    disp vqtdp format ">>>>9" label "Qtd. Clientes"   
         vqtdr format ">>>>9" label "Qtd. Retorno"
         tvind format ">>9.99%" label "Indice"
         vvalor format ">>,>>>,>>9.99" label "Valor Venda"
         with frame fd1 side-label width 100
          .
end.
else do:
vqtdp = 0. vqtdr = 0. vvalor = 0.  vind = 0. tvind = 0.
for each tt-sel:
    find estab where estab.etbcod = tt-sel.etbcod no-lock.
    vind = (tt-sel.qtdr / tt-sel.qtdp) * 100 .
    disp tt-sel.etbcod  format ">>>>>>>>9"  column-label "Filial"
         estab.etbnom  no-label format "x(20)"
         tt-sel.qtdp   column-label "Qtd.!Clientes"
         tt-sel.qtdr   column-label "Qtd.!Retorno"
         vind format ">>9.99%" column-label "Indice"
         tt-sel.valor  column-label "Valor venda"  
         format ">>>,>>>,>>>.99"
         with frame f-disp1 down.
         
    assign
        vqtdp = vqtdp + tt-sel.qtdp
        vqtdr = vqtdr + tt-sel.qtdr
        vvalor = vvalor + tt-sel.valor.
end. 
down 1 with frame f-disp1.
tvind = (vqtdr / vqtdp) * 100.
disp vqtdp @ tt-sel.qtdp
     vqtdr @ tt-sel.qtdr
     tvind @ vind
     vvalor @ tt-sel.valor
     with frame f-disp1.
end.     
output close.
if opsys = "UNIX"
then do:
    run visurel.p(varquivo,"").
    leave.
end.
else do:
    {mrod.i}
    leave.
end.
leave.
end.
else if vacao
then do:
if connected ("crm")
then disconnect crm.

/*** Conectando Banco CRM no server CRM ***/
connect crm -H "erp.lebes.com.br" -S sdrebcrm -N tcp -ld crm no-error.

               
if not connected ("crm")
then do:
    message "Nao foi possivel conectar o banco CRM. Avise o CPD.".
    pause.
    leave.
end.


for each tt-sel :
    find clien where clien.clicod = tt-sel.clifor no-lock.
    create tt-cli.
    tt-cli.clicod = clien.clicod.
    tt-cli.clinom = clien.clinom.
end.    
run rfv000-brw.p.

if connected ("crm")
then disconnect crm.


end.
end.
