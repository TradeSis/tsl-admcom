{admcab.i}

def var vdifer as dec.
def shared var vmes as int format "99".
def shared var vano as int format "9999".
def shared var vdti as date.
def shared var vdtf as date.
def shared var vdtblo as date.


vdtblo = 01/01/2017.

/****
vmes = month(vdtblo).
vano = year(vdtblo).

do on error undo:
    update vmes label "Competencia Mes"
           vano label "Ano"
           with frame f1 1 down width 80 side-label.
    if vmes = 0 or
       vano = 0
    then undo.        
end.
***/

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
    field vdesc as char format "x(30)"
    field valor as dec format ">>>,>>>,>>9.99" 
    index i1 seq
    index i2 vdesc.

if vdti >= vdtblo
then do:
    create tt-tipo.
    assign
        tt-tipo.seq = 1
        tt-tipo.vdesc = "01-VALORES CONTABILIDADE"
        .

    create tt-tipo.
    assign
        tt-tipo.seq = 2
        tt-tipo.vdesc = "02-GERA BASE DE DADOS"
        .
    
    create tt-tipo.
    assign
        tt-tipo.seq = 3
        tt-tipo.vdesc = "03-GERA TABELA DE VALORES"
        .

    create tt-tipo.
    assign
        tt-tipo.seq = 4
        tt-tipo.vdesc = "04-CONCILIACAO VALORES"
        .

    create tt-tipo.
    assign
        tt-tipo.seq = 5
        tt-tipo.vdesc = "05-TRANSFERE RECEBIMENTO"
        .

    create tt-tipo.
    assign
        tt-tipo.seq = 6
        tt-tipo.vdesc = "06-" /*PAGA CONTRATODD"*/
        .

    create tt-tipo.
    assign
        tt-tipo.seq = 7
        tt-tipo.vdesc = "07-" /*AVISTA GERA CONTRATODD"*/
        .

    create tt-tipo.
    assign
        tt-tipo.seq = 8
        tt-tipo.vdesc = "08-" /*TABDAC GERA TITSALCTB"*/
        .

    create tt-tipo.
    assign
        tt-tipo.seq = 9
        tt-tipo.vdesc = "09-IMPORTA E/C FINANCEIRA"
        .

    create tt-tipo.
    assign
        tt-tipo.seq = 10
        tt-tipo.vdesc = "" /*"10-GERA MOVIMENTO E/C FINANCEIRA"*/
        .

    create tt-tipo.
    assign
        tt-tipo.seq = 11
        tt-tipo.vdesc = "11-" /*GERA BASE DE SALDO"*/
        .
    create tt-tipo.
    assign
        tt-tipo.seq = 12
        tt-tipo.vdesc = "12-" /*AJUSTA BASE DE SALDO"*/
        .

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
        &where = " true use-index i2 "    
        &aftselect1 = " 
            if keyfunction(lastkey) = ""RETURN""
            THEN leave keys-loop. 
            else next keys-loop. "
        &form = " frame f-linha down no-label row 6 
        title "" Processamento "" "
        }

     if keyfunction(lastkey) = "END-ERROR"
     THEN leave l1.
     if tt-tipo.seq = 1
     then do:
        run cliprog0516. /*PARAMETROS - VALORES CONTABILIDADE*/
     end.
     if tt-tipo.seq = 2
     then do:
        if vdti < vdtblo or sfuncod <> 101
        then do:
        message color red/with
        "Opção bloqueada temporariamente."
        view-as alert-box.
        return.
        end.
        run /admcom/progr/ctb/operacao-ctb-v0119.p.
        /*run /admcom/progr/operacao-ctb-v0118.p.    
        */
     end.
     if tt-tipo.seq = 3
     then do:
        run cliprog1515-v0118.p. /*GERA TABELA DE VALORES*/
     end.
     if tt-tipo.seq = 4 /*CONCILIACAO*/
     then do:
        run cliprog0517-v0118.p.
     end.
     if tt-tipo.seq = 5
     then do:
        run cliprog0518-v0118.p.
     end.
     /*if tt-tipo.seq = 6
     then do:
        run cliprog0519.p.
     end.*/
     /*if tt-tipo.seq = 7
     then do:
        message color red/with
        "Opção bloqueada."
        view-as alert-box.
        /*
        run cliprog0521.p.
        */
     end.*/
     /*if tt-tipo.seq = 8
     then do:
        message color red/with
        "Opção bloqueada."
        view-as alert-box.
        /***
        run cliprog0520.p.
        ***/
     end.*/
     if tt-tipo.seq = 9
     then do:
        run cliprog0619-v0118.p.
     end.
     if tt-tipo.seq = 10
     then do:
        run cliprog0620-v0118.p.
     end.
     /*if tt-tipo.seq = 11
     then do:
        message color red/with
        "Opção bloqueada."
        view-as alert-box.
        /* run cliprog0520.p. */
     end.
     if tt-tipo.seq = 12
     then do:
        message color red/with
        "Opção bloqueada."
        view-as alert-box.
        /*
        run cliprog-ajusta-saldo.p.
        */
     end. */
     /***
     if tt-tipo.seq = 21
     then do:
        run cliprog0513-real.p.
     end.
     ***/
end.

procedure cliprog0516:
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
    def var vrec-banri as dec.
    def var vrec-master as dec.
    
    find first ct-cartcl where
               ct-cartcl.etbcod = 0        and
               ct-cartcl.datref = vdtf
               no-error .
    
    if avail ct-cartcl
    then assign
            val-acrescimo   = ct-cartcl.acrescimo
            val-vendavista  = ct-cartcl.avista
            val-vendabanri  = ct-cartcl.banri
            val-vendavisa   = ct-cartcl.visa
            val-vendamaster = ct-cartcl.master
            val-vendaprazo  = ct-cartcl.aprazo
            val-devprazo    = ct-cartcl.devprazo
            /*rec-financeira  = ct-cartcl.dec2 / 100*/   
            val-devvista    = ct-cartcl.devvista
            val-recebimento = ct-cartcl.recebimento
            /*val-financeira  = ct-cartcl.dif-ecf-contrato*/
            vrec-banri       = ct-cartcl.rec-banri
            vrec-master      = ct-cartcl.rec-master
            .
    
    tot-venda = 
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
           vrec-banri      label    "Rec. Banri  "  format ">>>,>>>,>>9.99"
           vrec-master     label    "Rec. Master "  format ">>>,>>>,>>9.99"
           /*
           rec-financeira  label    "Rec.Financeira" format ">>>,>>>,>>9.99"
           */
           with frame f-par 1 down 1 column row 6 column 40
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
             vrec-banri
             vrec-master
             /*
             rec-financeira  label    "Rec.Financeira" format ">>>,>>>,>>9.99"
             */
           with frame f-par /*1 down 1 column row 6 column 40
           title "   Parametros   "*/
               .
    if not avail ct-cartcl
    then do:
        create ct-cartcl.
        assign
            ct-cartcl.etbcod = 0
            ct-cartcl.datref = vdtf
            .
    end.
    assign
        ct-cartcl.acrescimo = val-acrescimo
        ct-cartcl.avista  = val-vendavista
        ct-cartcl.banri    = val-vendabanri
        ct-cartcl.visa    = val-vendavisa
        ct-cartcl.master   = val-vendamaster 
        ct-cartcl.aprazo  = val-vendaprazo
        ct-cartcl.devprazo      = val-devprazo * 100
        ct-cartcl.devvista = val-devvista
        ct-cartcl.recebimento = val-recebimento
        /*ct-cartcl.dif-ecf-contrato = val-financeira
        ct-cartcl.dec2      = rec-financeira * 100*/
        ct-cartcl.rec-banri = vrec-banri
        ct-cartcl.rec-master = vrec-master
        .

end procedure.
/*
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
****/

/****
procedure ac-vendaprazo:
    def var vtitvlcob as dec format ">>>,>>>,>>9.99".
    def var vacrescimo as dec format ">>>,>>>,>>9.99".
    def var vdata1 as date.
    def var vi as int.
    def var va as int.
    for each tt-difer:
        delete tt-difer.
    end.    
    message vdti vdtf. pause.
    do vi = 1 to 5.
    do vdata1 = vdti to vdtf:
        disp "Processando.... "vdata1 no-label
            with frame fff1 1 down centered row 12
            color message no-box overlay column 20.
        pause 0.    
        for each estab no-lock.
             disp estab.etbcod no-label
                vtitvlcob no-label with frame fff1.
             pause 0.   
             find first tt-difer where
                        tt-difer.etbcod = estab.etbcod and
                        tt-difer.data = vdata1
                        no-error.
             if not avail tt-difer
             then do:
                 create tt-difer.
                 assign
                     tt-difer.etbcod = estab.etbcod
                     tt-difer.data = vdata1
                            .
             end.               
             va = 0.
             for each contrato where contrato.etbcod = estab.etbcod and
                                    contrato.dtinicial = vdata1
                                    no-lock:
                if contrato.vltotal <= 0
                then next.
                find first contnf where 
                            contnf.etbcod = contrato.etbcod and
                            contnf.contnum = contrato.contnum
                        no-lock no-error.
                if not avail contnf
                then next.
                find first plani where plani.etbcod = contnf.etbcod and
                                 plani.placod = contnf.placod and
                                 plani.serie  = "V"
                                 no-lock no-error.
                if avail plani and
                   plani.notped <> "C"
                then next.                 

                find first envfinan where 
                                       envfinan.empcod = 19
                                    and envfinan.titnat = no
                                    and envfinan.modcod = "CRE"
                                    and envfinan.etbcod = contrato.etbcod
                                    and envfinan.clifor = contrato.clicod
                                  and envfinan.titnum = string(contrato.contnum)
                                    no-lock no-error.
                if  avail envfinan
                then next.

                
                find cpcontrato where 
                     cpcontrato.contnum = contrato.contnum
                      no-error.
                if not avail cpcontrato or
                    cpcontrato.indecf = no 
                then next.
                if cpcontrato.financeira <> 0
                then next.
                
                find contarqm where contarqm.contnum = contrato.contnum
                    no-lock no-error.
                    
                if avail contarqm and
                    contarqm.situacao = 4
                then next.    
                
                /*
                if cpcontrato.carteira = 66 then next.
                */
                if cpcontrato.indacr = yes
                then next.
                /*
                assign
                         vtitvlcob = vtitvlcob + cpcontrato.dec3
                         vacrescimo = vacrescimo +
                         (contrato.vltotal - cpcontrato.dec3) .
                else if cpcontrato.carteira = 77
                then assign
                        vtitvlcob = vtitvlcob + cpcontrato.dec3
                        .
                else assign
                        vtitvlcob = vtitvlcob + contrato.vltotal
                        .
                */
                /*if contrato.vltotal = cpcontrato.dec3
                then*/ do:
                    if vtitvlcob + contrato.vltotal <= vdifer
                    then do:
                        find first titulo where 
                               titulo.empcod = 19 and
                               titulo.titnat   = no and
                               titulo.modcod   = "CRE" and
                               titulo.etbcod   = contrato.etbcod and
                               titulo.clifor   = contrato.clicod and
                               titulo.titnum   = string(contrato.contnum) and
                               titulo.titdtpag <> ? and
                               titulo.titdtpag >= vdti and
                               titulo.titdtpag <= vdtf
                               no-lock no-error.
                        if not avail titulo
                        then do: 
                            vtitvlcob = vtitvlcob + contrato.vltotal. 
                            cpcontrato.indecf = no.
                            cpcontrato.carteira = 91.
                            tt-difer.emissao = tt-difer.emissao +
                                contrato.vltotal.
                            va = va + 1.
                        end.
                    end.
                end.
                if va = 6
                then leave.
            end.
        end.
    end.
    end.
    
    message "Atualizando....".
    
    for each tt-difer where tt-difer.etbcod > 0 and
                            tt-difer.data <> ?:
        
        find first ctcartcl where ctcartcl.etbcod = tt-difer.etbcod and
                            ctcartcl.datref = tt-difer.data
                            no-error.
        if avail ctcartcl
        then
        ctcartcl.ecfprazo = ctcartcl.ecfprazo - tt-difer.emissao.
    
    end.                         

end procedure.

procedure ac-recebimento:
    def var vtotal as dec.
    def var vdata1 as date.

    def var vi as int.
    def var va as int.
    def var vb as int.
    
    for each tt-difer:
        delete tt-difer.
    end.    

    for each estab where estab.etbcod > 899 no-lock:
        do vdata1 = vdti to vdtf:
        disp "Processando.... " vdata1 no-label estab.etbcod no-label
            with frame fff2 1 down centered row 12
            color message no-box overlay column 20.
        pause 0.
        find first tt-difer where
                tt-difer.etbcod = estab.etbcod and
                tt-difer.data = vdata1
                no-error.
        if not avail tt-difer
        then do:
            create tt-difer.
            assign
                tt-difer.etbcod = estab.etbcod
                tt-difer.data = vdata1
                .
        end.        
        for each titulo use-index etbcod where
                 titulo.etbcobra = estab.etbcod and
                 titulo.titdtpag = vdata1 no-lock:
                 if titulo.titvlcob <= 0
                 THEN NEXT.
                if titulo.clifor = 1 then next.
                if titulo.titnat = yes then next.
                if titulo.titpar = 0 then next. 
                if titulo.modcod <> "CRE" then next.

                find tituarqm of titulo no-lock no-error.
                if avail tituarqm and
                    tituarqm.etbcobra = estab.etbcod and
                    tituarqm.titdtpag = vdata1 and
                    tituarqm.titsit = "PAGCTB"
                then next.                    

                find first envfinan where 
                                       envfinan.empcod = 19
                                    and envfinan.titnat = no
                                    and envfinan.modcod = "CRE"
                                    and envfinan.etbcod = titulo.etbcod
                                    and envfinan.clifor = titulo.clifor
                                    and envfinan.titnum = titulo.titnum
                                    no-lock no-error.
                if  avail envfinan
                then next.
                
                find cpcontrato where 
                     cpcontrato.contnum = int(titulo.titnum)
                     no-error.
                if titulo.titdtemi >= 01/01/2009 and
                   not avail cpcontrato
                then next. 
                if avail cpcontrato and
                   cpcontrato.indecf = no
                then next. 
                if /*avail cpcontrato and*/ 
                    vtotal + titulo.titvlcob <= vdifer
                then do:
                    find tituarqm of titulo no-error.
                    if not avail tituarqm
                    then create tituarqm.
                    buffer-copy titulo to tituarqm.
                    tituarqm.datexp = vdata1.
                    tituarqm.titsit = "PAGCTB".
                    tituarqm.cobcod = 10.
                    vtotal = vtotal + titulo.titvlcob.
                    tt-difer.recebimento = tt-difer.recebimento +
                            titulo.titvlcob.
                end.
            end.
            disp vtotal no-label with frame fff2.
            pause 0.
        end.
    end. 
    
    do vi = 1 to 3:
    
    for each estab where estab.etbcod < 150 no-lock:
        do vdata1 = vdti to vdtf:
        disp "Processando.... " vdata1 no-label estab.etbcod no-label
            with frame fff3 1 down centered row 12
            color message no-box overlay column 20.
        pause 0.
        find first tt-difer where
                tt-difer.etbcod = estab.etbcod and
                tt-difer.data = vdata1
                no-error.
        if not avail tt-difer
        then do:
            create tt-difer.
            assign
                tt-difer.etbcod = estab.etbcod
                tt-difer.data = vdata1
                .
        end. 
        va = 0.
        for each titulo use-index etbcod where
                 titulo.etbcobra = estab.etbcod and
                 titulo.titdtpag = vdata1 /*and
                 titulo.titpar = 1*/ no-lock:
                 if titulo.titvlcob <= 0
                 THEN NEXT.
                if titulo.clifor = 1 then next.
    
                if titulo.titnat = yes then next.
                if titulo.titpar = 0 then next. 
                if titulo.modcod <> "CRE" then next.

                find tituarqm of titulo no-lock no-error.
                if avail tituarqm and
                    tituarqm.etbcobra = estab.etbcod and
                    tituarqm.titdtpag = vdata1 and
                    tituarqm.titsit = "PAGCTB"
                then next.                    

                find first envfinan where 
                                       envfinan.empcod = 19
                                    and envfinan.titnat = no
                                    and envfinan.modcod = "CRE"
                                    and envfinan.etbcod = titulo.etbcod
                                    and envfinan.clifor = titulo.clifor
                                    and envfinan.titnum = titulo.titnum
                                    no-lock no-error.
                if  avail envfinan
                then next.
                
                find cpcontrato where 
                     cpcontrato.contnum = int(titulo.titnum)
                     no-error.
                if titulo.titdtemi >= 01/01/2009 and
                   not avail cpcontrato
                then next.
                if avail cpcontrato and
                   cpcontrato.indecf = no
                then next. 
              
                if /*avail cpcontrato and*/
                    vtotal + titulo.titvlcob <= vdifer
                then do:
                    find tituarqm of titulo no-error.
                    if not avail tituarqm
                    then create tituarqm.
                    buffer-copy titulo to tituarqm.
                    tituarqm.datexp = vdata1.
                    tituarqm.titsit = "PAGCTB".
                    tituarqm.cobcod = 10.
                    vtotal = vtotal + titulo.titvlcob.
                    tt-difer.recebimento = tt-difer.recebimento +
                        titulo.titvlcob.
                    va = va + 1.
                end.
            
            if va = 6
            then leave.
        end.
        disp vtotal no-label with frame fff3.
        pause 0.
        end.
    end.         
    end.
    for each tt-difer where
             tt-difer.etbcod > 0:
        find first ctcartcl where ctcartcl.etbcod = tt-difer.etbcod and
                            ctcartcl.datref   = tt-difer.data
                            no-error.
        if avail ctcartcl
        then
        ctcartcl.recebimento = ctcartcl.recebimento -
                                tt-difer.recebimento.
    end.                            
end procedure.

procedure limpa-dd:
    sresp = no.
    message "Confirma limpar dados? " update sresp.
    def var vdata as date.
    if sresp then do:
    for each estab no-lock:
        disp "Aguarade... " estab.etbcod with frame f-ldd 1 down
            centered row 10 color message no-box no-label.
        pause 0.    
        do vdata = vdti to vdtf:
            disp vdata with frame f-ldd.
            pause 0.
            for each ctcartcl where ctcartcl.etbcod = estab.etbcod and
                ctcartcl.datref = vdata
                :
                delete ctcartcl.
            end.
            for each contrato where contrato.dtinicial = vdata and
                                    contrato.etbcod = estab.etbcod no-lock:
                find cpcontrato where cpcontrato.contnum = contrato.contnum
                    no-error.
                if avail cpcontrato
                then delete cpcontrato.
            end.
            for each contarqm where 
                        contarqm.etbcod = estab.etbcod and
                        contarqm.dtinicial = vdata and
                        contarqm.situacao = 4
                        :
                delete contarqm.                     
            end.
            for each tituarqm  where
                 tituarqm.etbcobra = estab.etbcod and
                 tituarqm.titdtpag = vdata and
                 tituarqm.titsit = "PAGCTB" and
                 tituarqm.cobcod = 10.
                delete tituarqm.
            end.    
                        
        end.
    end. 
    end.
end procedure.

***************************/
