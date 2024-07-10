{admcab.i}

def var vdifer as dec.
def new shared var vmes as int format "99".
def new shared var vano as int format "9999".
def new shared var vdti as date.
def new shared var vdtf as date.
def new shared var vdtblo as date.

if month(today) = 1
then vdtblo = date(12,01,year(today) - 1).
else vdtblo = date(month(today) - 1,01,year(today)).
vmes = month(vdtblo).
vano = year(vdtblo).

pause 0.

do on error undo:
    update vmes label "Competencia Mes"
           vano label "Ano"
           with frame f1 1 down width 80 side-label.
    if vmes = 0 or
       vano = 0
    then undo.        
end.

/****
find first ninja.ctcartcl where
           ctcartcl.datref >= vdti and
           ctcartcl.datref <= vdtf and
           ctcartcl.etbcod > 0
           no-lock no-error.
if avail ctcartcl
then do:
    bell.
    message color red/with
    "Mes " vmes " Ano " vano " ja processado" 
    view-as alert-box.
    return.
end.      

find first ninja.tabdac where
           tabdac.anolan = vano and
           tabdac.meslan = vmes and
           tabdac.tiplan = "RECEBIMENTO"
           no-lock no-error.
if avail ninja.tabdac
then do:
    bell.
    message color red/with
    "Mes " vmes " Ano " vano "ja processado."
    view-as alert-box.
    return.  
end.  
*****/

def var vsenha like func.senha format "x(10)".

def temp-table tt-devol
    field etbcod like estab.etbcod
    field data as date
    field valor as dec
    index i1 etbcod data.

def temp-table tt-financeira
    field etbcod like estab.etbcod
    field data as date
    field valor as dec
    index i1 etbcod data.
 
def temp-table tt-difer
    field etbcod like estab.etbcod
    field data as date
    field emissao as dec
    field acrescimo as dec
    field recebimento as dec
    index i1 etbcod data.
    
vdti = date(vmes,01,vano).
vdtf = date(month(vdti + 32),01,year(vdti + 31)) - 1.


def NEW shared temp-table tt-venda
        field etbcod like estab.etbcod
        field data as date
        field vl-prazo as dec 
        field vl-vista as dec
        field avista as dec
        field aprazo as dec
        index i1 etbcod data.
 
def NEW shared temp-table tt-index
    field etbcod like estab.etbcod
    field data as date
    field indx as dec 
    field venda as dec 
    field titulo as dec
    field vl-prazo as dec  decimals 2
    field vl-titulo as dec decimals 2
    index i1 etbcod data.

def NEW shared temp-table tt-acretb
    field etbcod like estab.etbcod
    field valor as dec
    field valpr as dec.

def NEW shared temp-table tt-estab
    field etbcod like estab.etbcod
    .
    
def buffer bestab for estab.
for each bestab /*where bestab.etbnom begins "DREBES-FIL"*/ no-lock.
    create tt-estab.
    tt-estab.etbcod = bestab.etbcod.
end.    

def new shared temp-table tt-titulo
      field data      as date
      field etbcod like estab.etbcod
      field tipo      as char format "X(15)"  Label "Tipo"
      field titvlcob  like fin.titulo.titvlcob label "Valor"
      field titvlpag  like fin.titulo.titvlpag
      field entrada as dec
      index ix is primary unique
                  tipo
                  etbcod
                  data
                  .

def stream tl.
def temp-table tt-tipo
    field seq as int
    field feito as char format "x"
    field vdesc as char format "x(35)"
    field valor as dec format ">>>,>>>,>>9.99" 
    index i1 seq
    index i2 vdesc.

/*if vdti >= vdtblo
then*/ do:

    create tt-tipo.
    assign
        tt-tipo.seq = 1
        tt-tipo.vdesc = "01-RELATORIO TOTAIS DA BASE" .
    create tt-tipo.
    assign
        tt-tipo.seq = 2
        tt-tipo.vdesc = "02-RELATORIO TABELA VALORES" . 
    create tt-tipo.
    assign
        tt-tipo.seq = 3
        tt-tipo.vdesc = "03-GERA ARQUIVO SISPRO"
        .
    create tt-tipo.
    assign
       tt-tipo.seq = 4
       tt-tipo.vdesc = "04-VALOR PAGO REFERENTE INCOBRAVEIS".
    
    create tt-tipo.
    assign
       tt-tipo.seq = 5
       tt-tipo.vdesc = "05-EXPORTA DIARIO LAYOUT DSP".

    create tt-tipo.
    assign
       tt-tipo.seq = 6
       tt-tipo.vdesc = "06-RECEBIMENTOS 2018" /*RELATORIOS CTB"*/.
    
    create tt-tipo.
    assign
       tt-tipo.seq = 7
       tt-tipo.vdesc = "07-REPROCESSAMENTO TOTAIS 12/2018".

    create tt-tipo.
    assign
       tt-tipo.seq = 8
       tt-tipo.vdesc = "08-".

    create tt-tipo.
    assign
       tt-tipo.seq = 9
       tt-tipo.vdesc = "09-RELATORIO TOTAIS PARCELA" /*IMPORTA E/C FINANCEIRA"*/.
  
    create tt-tipo.
    assign
       tt-tipo.seq = 10
       tt-tipo.vdesc = "10-PROCESSAMENTO".
    /*create tt-tipo.
    assign
       tt-tipo.seq = 11
       tt-tipo.vdesc = "11-" /*RELATORIO ACRESCIMO VENDA"*/.
    */
    /*create tt-tipo.
    assign
       tt-tipo.seq = 12
       tt-tipo.vdesc = "12-" /*RELATORIO ACRESCIMO FILIAL"*/.
    */
    create tt-tipo.
    assign
       tt-tipo.seq = 11
       tt-tipo.vdesc = "11-RELATORIO REPARCELAMENTOS". 
    create tt-tipo.   
    assign
       tt-tipo.seq = 12
       tt-tipo.vdesc = "12-RECEBIMENTOS MOEDA". 
    create tt-tipo.
    assign
       tt-tipo.seq = 13
       tt-tipo.vdesc = "13-RELATORIO ABERTURA DE LANCAMENTOS".
    create tt-tipo.
    assign
       tt-tipo.seq = 14
       tt-tipo.vdesc = "14-CONTABILIDADE 2018".      
end.

{setbrw.i}
    
assign
    a-seeid = -1
    a-recid = -1
    a-seerec = ?
        .

l1: repeat:        
 
    assign
        a-seeid = -1
        a-recid = -1
        a-seerec = ?
        .
    {sklcls.i
        &file = tt-tipo
        &cfield = tt-tipo.vdesc
        &ofield = " tt-tipo.feito "
        &where = " true use-index i1 "    
        &aftselect1 = " 
            if keyfunction(lastkey) = ""RETURN""
            THEN leave keys-loop. 
            else next keys-loop. "
        &form = " frame f-linha down no-label row 6 "
        }

     if keyfunction(lastkey) = "END-ERROR"
     THEN leave l1.

     if tt-tipo.seq = 1 then run ctb/rel-valores-CTB-0119.p.
                                /*ctb/cliprog1514-v0218.p.*/
                                /*cliprog1514-v0118.p*/  
     else if tt-tipo.seq = 2 then run cliprog6-v0118.p.
     else if tt-tipo.seq = 3
     then  run ctb/cliprog77-v0118.p. /*EXPORTA CTB*/
     else if tt-tipo.seq = 4
     then run valpagincob-v0118.p. /*expdauxclisispro-v0118.p.*/
     else if tt-tipo.seq = 5
     then run ctb/expdauxclidsp-v0119.p.
     else if tt-tipo.seq = 6
     THEN run /admcom/custom/Claudir/cliprog1514-v0118-opctbv2018.p.
     else if tt-tipo.seq = 7
          THEN run /admcom/custom/Claudir/cliprog1514-v0118-opctbvt18.p.
     else if tt-tipo.seq = 9
          then run /admcom/progr/ctb/rel-valores-CTB-0120.p. /*run cliprog0619-v0118.p.*/
     /*
     else if tt-tipo.seq = 6
     then run cliprog78-v0118.p.
     */
     /*else if tt-tipo.seq = 7
     then run cliprog1514-v0118.p.*/
     else if tt-tipo.seq = 10
     then do:
        vsenha = "".
        update vsenha label "Senha"
            with frame f-senha side-label overlay 1 down column 20
            row 15.
        hide frame f-senha.
        if vsenha = "1357"
        then do:
            run cliprog_proc-v0118.p.
        end.
     end.
     /****
     else if tt-tipo.seq = 11
     then do:
         sresp = no.
         message "Confirma emitir arquivo csv ACRESCIMO VENDA? "
         update sresp.
         if sresp
         then run diario-acrescimo-venda.p. 
     end.
     else if tt-tipo.seq = 12
     then do:
         sresp = no.                                        
         message "Confirma emitir arquivo csv ACRESCIMO FILIAL? "
         update sresp.
         if sresp
         then do:
            run desconecta_d.p.
            run diario-acrescimo-filial.p.
            run conecta_d.p.
         end.
     end.
     *****/
     else if tt-tipo.seq = 11
     then run ctb/relrepar-v0119.p. /*Reparcelamentos***/
     else if tt-tipo.seq = 12
     then run ctb/pagreb5-v0119.p. /*Recebimento moeda***/
     else if tt-tipo.seq = 13
     then run ctb/cliprog13-v0118.p.
     else if tt-tipo.seq = 14
     then run cliprog77-v0118.p.
end.

procedure cliprog1-p:
    def var val-acrescimo as dec.
    def var val-vendavista as dec.
    def var val-vendabanri as dec.
    def var val-vendavisa as dec.
    def var val-vendamaster as dec.
    def var val-vendaprazo as dec.
    def var val-devprazo as dec.
    def var val-devvista as dec.
    def var val-recebimento as dec.
    def var val-financeira as dec.
    def var tot-venda as dec.
    def var tot-devol as dec.
    def var rec-financeira as dec.
    
    find first ninja.ctcartcl where
               ctcartcl.etbcod = 0        and
               ctcartcl.datref = vdtf
               no-error .
    
    if avail ctcartcl
    then assign
            val-acrescimo   = ctcartcl.acrescimo
            val-vendavista  = ctcartcl.ecfvista
            val-vendabanri  = ctcartcl.avista
            val-vendavisa   = ctcartcl.aprazo
            val-vendamaster = ctcartcl.emissao
            val-vendaprazo  = ctcartcl.ecfprazo
            val-devprazo    = ctcartcl.dec3 / 100
            rec-financeira  = ctcartcl.dec2 / 100   
            val-devvista    = ctcartcl.devolucao
            val-recebimento = ctcartcl.recebimento
            val-financeira  = ctcartcl.dif-ecf-contrato
            .
    
    tot-venda = /*val-acrescimo*/
                  val-financeira  + val-vendavista + val-vendabanri +
                  val-vendavisa + val-vendamaster + val-vendaprazo
                .
    
    tot-devol = val-devprazo  + val-devvista.            
    disp val-acrescimo   label    "Acrescimo   "  format ">>>,>>>,>>9.99"
           val-vendavista  label    "Venda Vista "  format ">>>,>>>,>>9.99"
           val-financeira  label    "Financeira  "  format ">>>,>>>,>>9.99"
           val-vendabanri  label    "Venda Banri "  format ">>>,>>>,>>9.99"
           val-vendavisa   label    "Venda Visa  "  format ">>>,>>>,>>9.99"
           val-vendamaster label    "Venda Master"  format ">>>,>>>,>>9.99"
           val-vendaprazo  label    "Venda Prazo "  format ">>>,>>>,>>9.99"
           tot-venda label "Total Venda " format ">>>,>>>,>>9.99"
           val-devprazo    label    "Devol Prazo "  format ">>>,>>>,>>9.99"
           val-devvista    label    "Devol Vista "  format ">>>,>>>,>>9.99"
           tot-devol label     "Total Devol "  format ">>>,>>>,>>9.99"
           val-recebimento label    "Recebimento "  format ">>>,>>>,>>9.99"
           rec-financeira  label    "Rec.Financeira" format ">>>,>>>,>>9.99"
           with frame f-par 1 down 1 column row 7 column 40
           title "   Parametros   " .
     
    update val-acrescimo   label    "Acrescimo   "  format ">>>,>>>,>>9.99"
           val-vendavista  label    "Venda Vista "  format ">>>,>>>,>>9.99"
           val-financeira  label    "Financeira  "  format ">>>,>>>,>>9.99"
           val-vendabanri  label    "Venda Banri "  format ">>>,>>>,>>9.99"
           val-vendavisa   label    "Venda Visa  "  format ">>>,>>>,>>9.99"
           val-vendamaster label    "Venda Master"  format ">>>,>>>,>>9.99"
           val-vendaprazo  label    "Venda Prazo "  format ">>>,>>>,>>9.99"
           with frame f-par.
    
    tot-venda =       val-financeira + val-vendavista + val-vendabanri +
            val-vendavisa + val-vendamaster + val-vendaprazo
            .
    
    disp tot-venda
            label "Total Venda" format ">>>,>>>,>>9.99"
            with frame f-par.
    update   val-devprazo    label    "Devol Prazo "  format ">>>,>>>,>>9.99"
           val-devvista    label    "Devol Vista "  format ">>>,>>>,>>9.99"
            with frame f-par.
            
    tot-devol =        val-devprazo  + val-devvista
            .
    disp tot-devol        
            label     "Total Devol "  format ">>>,>>>,>>9.99"
            with frame f-par.
    update   val-recebimento label    "Recebimento "  format ">>>,>>>,>>9.99"
             rec-financeira  label    "Rec.Financeira" format ">>>,>>>,>>9.99"
           with frame f-par 1 down 1 column row 7 column 40
           title "   Parametros   "
               .
    if not avail ctcartcl
    then do:
        create ctcartcl.
        assign
            ctcartcl.etbcod = 0
            ctcartcl.datref = vdtf
            .
    end.
    assign
        ctcartcl.acrescimo = val-acrescimo
        ctcartcl.ecfvista  = val-vendavista
        ctcartcl.avista    = val-vendabanri
        ctcartcl.aprazo    = val-vendavisa
        ctcartcl.emissao   = val-vendamaster 
        ctcartcl.ecfprazo  = val-vendaprazo
        ctcartcl.dec3      = val-devprazo * 100
        ctcartcl.devolucao = val-devvista
        ctcartcl.recebimento = val-recebimento
        ctcartcl.dif-ecf-contrato = val-financeira
        ctcartcl.dec2      = rec-financeira * 100
        .

end procedure.

def temp-table tt-cartcl like ninja.ctcartcl. 

procedure difer:
    def var val-acrescimo as dec.
    def var val-vendavista as dec.
    def var val-vendabanri as dec.
    def var val-vendavisa as dec.
    def var val-vendamaster as dec.
    def var val-vendaprazo as dec init 0.
    def var val-devprazo as dec.
    def var val-devvista as dec.
    def var val-recebimento as dec init 0.
    def var val-financeira as dec.
    def var tot-venda as dec.
    def var tot-devol as dec.
    
    find first ninja.ctcartcl where
               ctcartcl.etbcod = 0        and
               ctcartcl.datref = vdtf
               no-error .
    
    if avail ctcartcl
    then assign
            val-acrescimo   = ctcartcl.acrescimo
            val-vendavista  = ctcartcl.ecfvista
            val-vendabanri  = ctcartcl.avista
            val-vendavisa   = ctcartcl.aprazo
            val-vendamaster = ctcartcl.emissao
            val-vendaprazo  = ctcartcl.ecfprazo
            val-devprazo    = ctcartcl.dec3 / 100
            val-devvista    = ctcartcl.devolucao
            val-recebimento = ctcartcl.recebimento
            val-financeira  = ctcartcl.dif-ecf-contrato
            .
    
    tot-venda = val-acrescimo + val-vendavista + val-vendabanri +
                val-vendavisa + val-vendamaster + val-vendaprazo
                .
    
    tot-devol = val-devprazo  + val-devvista.            
    
    for each ctcartcl where ctcartcl.datref >= vdti and
                        ctcartcl.datref <= vdtf AND
                        ctcartcl.ETBCOD > 0
                        no-lock:
        find first tt-cartcl where
               tt-cartcl.etbcod = 999 and
               tt-cartcl.datref = ?
               no-error.
        if not avail tt-cartcl
        then do:
            create tt-cartcl.
            assign
            tt-cartcl.etbcod = 999
            tt-cartcl.datref = ?
                    .
        end.               
        assign
        tt-cartcl.avista   = tt-cartcl.avista + ctcartcl.avista
        tt-cartcl.aprazo   = tt-cartcl.aprazo + ctcartcl.aprazo
        tt-cartcl.devolucao = tt-cartcl.devolucao + ctcartcl.devolucao 
        tt-cartcl.ecfvista = tt-cartcl.ecfvista +  ctcartcl.ecfvista
        tt-cartcl.ecfprazo = tt-cartcl.ecfprazo +  ctcartcl.ecfprazo
        tt-cartcl.emissao  = tt-cartcl.emissao  +  ctcartcl.emissao
        tt-cartcl.dec1     = tt-cartcl.dec1 + (ctcartcl.dec1 / 100)
        tt-cartcl.acrescimo = tt-cartcl.acrescimo +  ctcartcl.acrescimo
        tt-cartcl.recebimento = tt-cartcl.recebimento + ctcartcl.recebimento
        tt-cartcl.juro = tt-cartcl.juro +  ctcartcl.juro
        tt-cartcl.dec2 = tt-cartcl.dec2 + ctcartcl.dec2 
        tt-cartcl.dec3 = tt-cartcl.dec3 + ctcartcl.dec3 
        tt-cartcl.dif-ecf-contrato = tt-cartcl.dif-ecf-contrato 
        + ctcartcl.dif-ecf-contrato
        .
    end.
    for each contarqm where contarqm.datexp >= vdti and
                        contarqm.datexp <= vdtf and
                        contarqm.situacao = 4
                        .
        find first tt-cartcl where
               tt-cartcl.etbcod = contarqm.etbcod and
               tt-cartcl.datref = vdtf
               no-error.
        if not avail tt-cartcl
        then do:
            create tt-cartcl.
            assign
            tt-cartcl.etbcod = contarqm.etbcod
            tt-cartcl.datref = vdtf
                    .
        end.
        tt-cartcl.devprazo = tt-cartcl.devprazo + contarqm.vltotal.
        tt-cartcl.estorno  = tt-cartcl.estorno  + 
                    (contarqm.vltotal - contarqm.vlfrete).
    end. 
    
    find first tt-cartcl where tt-cartcl.etbcod = 999.
    disp   /*val-acrescimo - tt-cartcl.acrescimo  label    "Acrescimo   "  format~  "->>>,>>>,>>9.99"
           val-vendavista - tt-cartcl.ecfvista label    "Venda Vista "  format "->>>,>>>,>>9.99"
           val-financeira - tt-cartcl.dif-ecf-contrato label    "Financeira  "  format "->>>,>>>,>>9.99"
           val-vendabanri  label    "Venda Banri "  format ">>>,>>>,>>9.99"
           val-vendavisa   label    "Venda Visa  "  format ">>>,>>>,>>9.99"
           val-vendamaster label    "Venda Master"  format ">>>,>>>,>>9.99"
           */
           val-vendaprazo - tt-cartcl.ecfprazo label    "Venda Prazo "  format "->>>,>>>,>>9.99"
           /*tot-venda label "Total Venda " format ">>>,>>>,>>9.99"
           val-devprazo    label    "Devol Prazo "  format ">>>,>>>,>>9.99"
           val-devvista    label    "Devol Vista "  format ">>>,>>>,>>9.99"
           tot-devol label     "Total Devol "  format ">>>,>>>,>>9.99"
           */
           val-recebimento - tt-cartcl.recebimento label    "Recebimento "  format "->>>,>>>,>>9.99"
           with frame f-par 1 down 1 column row 8 column 40
           title "   Diferença   " .
 
    
    vdifer = tt-cartcl.ecfvista - val-vendavista.
    if vdifer > 0
    then do:
        sresp = no.
        message "Ajustar venda vista? " update sresp.
        if sresp
        then /*run ac-vendaprazo*/.
    end.
    vdifer = tt-cartcl.ecfprazo - val-vendaprazo.
    if vdifer > 0
    then do:
        sresp = no.
        message "Ajustar venda prazo? " update sresp.
        if sresp
        then /*run ac-vendaprazo*/.
    end.
    vdifer = tt-cartcl.recebimento - val-recebimento.
    if vdifer > 0
    then do:
        sresp = no.
        message "Ajustar Recebimento? " update sresp.
        if sresp
        then /*run ac-recebimento*/.
    end.
end procedure.

