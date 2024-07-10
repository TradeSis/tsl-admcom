{admcab.i}

def var vdifer as dec.
def var vmes as int format "99".
def var vano as int format "9999".
def new shared var vdti as date.
def new shared var vdtf as date.
def var vdtblo as date.

vdtblo = 01/01/2015.
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

/*
vdtblo = vdti.
*/
if vdti >= vdtblo
then do:
    /**
    create tt-tipo.
    assign
        tt-tipo.seq = 1
        tt-tipo.vdesc = "01-GERA BASE DE DADOS"
        .
    create tt-tipo.
    assign
        tt-tipo.seq = 2
        tt-tipo.vdesc = "02-VALORES CONTABILIDADE"
        .
    create tt-tipo.
    assign
        tt-tipo.seq = 3
        tt-tipo.vdesc = "02-CONCILIACAO"
        .
    **/
    /*
    create tt-tipo.
    assign
        tt-tipo.seq = 5
        tt-tipo.vdesc = "05-IMPORTA ARQUIVOS FINANCEIRA"
        . 
    */

    create tt-tipo.
    assign
        tt-tipo.seq = 6
        tt-tipo.vdesc = "06-RELATORIO"
        .
    create tt-tipo.
    assign
        tt-tipo.seq = 7
        tt-tipo.vdesc = "07-EXPORTA CTB"
        . 
    create tt-tipo.
    assign
        tt-tipo.seq = 8
        tt-tipo.vdesc = "08-RELATORIO DE TOTAIS"
        .
    create tt-tipo.
    assign
       tt-tipo.seq = 9
       tt-tipo.vdesc = "09-EXPORTA LAYOUT SISPRO".
    
    create tt-tipo.
    assign
       tt-tipo.seq = 10
       tt-tipo.vdesc = "10-EXPORTA LAYOUT AUDIT".
   
                            
/*****
create tt-tipo.
assign
    tt-tipo.seq = 1
    tt-tipo.vdesc = "01-PARAMETROS"
    .
create tt-tipo.
assign
    tt-tipo.seq = 2
    tt-tipo.vdesc = "02-EMISSAO"
    .
create tt-tipo.
assign
    tt-tipo.seq = 3
    tt-tipo.vdesc = "03-ACRESCIMO"
    .
create tt-tipo.
assign
    tt-tipo.seq = 4
    tt-tipo.vdesc = "04-EMISSAO COBRANCA"
    .
create tt-tipo.
assign
    tt-tipo.seq = 5
    tt-tipo.vdesc = "05-RECEBIMENTO"
    .
create tt-tipo.
assign
    tt-tipo.seq = 6
    tt-tipo.vdesc = "06-RECEBIMENTO COBRANCA"
    .
end.
create tt-tipo.
assign
    tt-tipo.seq = 7
    tt-tipo.vdesc = "10-RELATORIO"
    .   
create tt-tipo.
assign
    tt-tipo.seq = 8
    tt-tipo.vdesc = "11-EXPORTA CTB"
    . 
create tt-tipo.
assign
    tt-tipo.seq = 9
    tt-tipo.vdesc = "12-ARQUIVO SPED"
    .

create tt-tipo.
assign
    tt-tipo.seq = 16
    tt-tipo.vdesc = "16-ATUALIZA DBRP "
    .

if vdti >= vdtblo
then do:
create tt-tipo.
assign
    tt-tipo.seq = 10
    tt-tipo.vdesc = "13-ALTERA "
    .
create tt-tipo.
assign
    tt-tipo.seq = 11
    tt-tipo.vdesc = "07-FINANCEIRA"
    .

create tt-tipo.
assign
    tt-tipo.seq = 12
    tt-tipo.vdesc = "08-CARTAO"
    .
create tt-tipo.
assign
    tt-tipo.seq = 13
    tt-tipo.vdesc = "09-DEVOLUCAO "
    .
create tt-tipo.
assign
    tt-tipo.seq = 14
    tt-tipo.vdesc = "14-AJUSTE"
    .
create tt-tipo.
assign
    tt-tipo.seq = 15
    tt-tipo.vdesc = "15-LIMPA "
    .
*******************/

end.
else if vdti >= 01/01/14
then do:
    create tt-tipo.
    assign
       tt-tipo.seq = 9
       tt-tipo.vdesc = "09-EXPORTA LAYOUT SISPRO"
                            .
    create tt-tipo.
    assign
       tt-tipo.seq = 10
       tt-tipo.vdesc = "10-EXPORTA LAYOUT AUDIT"
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
        &form = " frame f-linha down no-label row 6 "
        }

     if keyfunction(lastkey) = "END-ERROR"
     THEN leave l1.
     /****
     if tt-tipo.seq = 1
     then do:
        run cliprog0513.p. /*GERA BASE DE DADOS*/
     end.
     if tt-tipo.seq = 2
     then do:
        run cliprog1-p. /*PARAMETROS - VALORES CONTABILIDADE*/
     end.
     else if tt-tipo.seq = 3 /*CONCILIACAO*/
     then do:
        run cliprog10.p.
     end.
     if tt-tipo.seq = 5
     then do:
        run imp-recebimento-emissao-cancelamento-estorno-financeira.bca.
     end.
     ***/
     
     if tt-tipo.seq = 6
     then run cliprog6.p. /*RELATORIO*/
     else if tt-tipo.seq = 7
     then  run cliprog77.p. /*EXPORTA CTB*/
     else if tt-tipo.seq = 8
     then run cliprog0514.p. /*RELATORIO VENDA E RECEBIMENTO*/
     else if tt-tipo.seq = 9
     then run expdauxclisispro.p.
     else if tt-tipo.seq = 10
     then run expdauxcliaudit.p.
     
     
     
      /**************************
     if tt-tipo.seq = 1
     then do:
        run cliprog1-p. /*PARAMETROS*/
     end.
     if tt-tipo.seq = 2
     then do:
        run cliprog01.p. /*EMISSAO*/
     end.
     else if tt-tipo.seq = 3
     then do:
        run cliprog2-2.p. /*ACRESCIMO*/
     end.
     else if tt-tipo.seq = 4
     then do:
        run cliprog5.p. /*EMISSAO COBRANCA*/
     end.
     else if tt-tipo.seq = 5
     then do:
        run cliprog4.p. /*RECEBIMENTO*/
     end.
     else if tt-tipo.seq = 6
     then do:
        run cliprog3.p. /*RECEBIMENTO COBRANCA*/
     end.
     else if tt-tipo.seq = 7
     then do:
        run cliprog6.p. /*RELATORIO*/
     end.
     else if tt-tipo.seq = 8
     then do:
        run cliprog77.p. /*EXPORTA CTB*/
     end.
     else if tt-tipo.seq = 9           
     then do:
        run cliprog0513.p. /*EXPORTA SPED*/
     end.
     else if tt-tipo.seq = 10
     then do:
        run cliprog9.p. /*ALTERA*/
     end.
     else if tt-tipo.seq = 11
     then do:
        run venda-financeira.
     end.
     else if tt-tipo.seq = 12
     then do:
        run cal-cartao.
     end.
     else if tt-tipo.seq = 13
     then do:
        run cal-devolucao.
     end.
     else if tt-tipo.seq = 14
     then do:
        run difer.
     end.
     else if tt-tipo.seq = 15
     THEN DO:
        run limpa-dd.
     end.
     else if tt-tipo.seq = 16
     THEN DO:
        run atualiza-dbrp.p.
     end.    
    ***************************/
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

/**************
procedure cal-cartao:
    def var valtotalven as dec.
    def var vl-financeira as dec.
    def var tt-financeira as dec.
    def buffer bctcartcl for ctcartcl.
    def buffer dctcartcl for ctcartcl.
    find first dctcartcl where
               dctcartcl.etbcod = 0 and
               dctcartcl.datref = vdtf
                no-lock no-error.
    valtotalven = 0.
    vl-financeira = 0.
    tt-financeira = 0.
    for each tt-estab no-lock:
        for each ctcartcl where ctcartcl.etbcod = tt-estab.etbcod and
                                ctcartcl.datref >= vdti and
                                ctcartcl.datref <= vdtf
                                .
            valtotalven = valtotalven + ctcartcl.ecfvista.
            tt-financeira = tt-financeira + ctcartcl.dif-ecf-contrato.
            ctcartcl.avista = 0.
            ctcartcl.aprazo = 0.
            ctcartcl.emissao = 0.
            
        end.
    end.
    if valtotalven > 0 and
           valtotalven <> ? and
           dctcartcl.avista > 0 and
           dctcartcl.avista <> ?
    then do: 
        output stream tl to terminal.
        for each tt-estab no-lock:
        disp stream tl "Processando Cartao... " tt-estab.etbcod  
                with frame gxy1 no-label 1 down centered no-box
                color message .
             pause 0.

    
        for each ctcartcl where ctcartcl.etbcod = tt-estab.etbcod and
                                ctcartcl.datref >= vdti and
                                ctcartcl.datref <= vdtf
                                .
            if ctcartcl.ecfvista > 0
            then do:
                ctcartcl.avista = dctcartcl.avista *
                            (ctcartcl.ecfvista / valtotalven).
                ctcartcl.aprazo = dctcartcl.aprazo *      
                            (ctcartcl.ecfvista / valtotalven).
                ctcartcl.emissao = dctcartcl.emissao *
                            (ctcartcl.ecfvista / valtotalven).
                /*
                ctcartcl.devolucao = dctcartcl.devolucao *
                            (ctcartcl.ecfvista / valtotalven).
                */
            end.
            if ctcartcl.dif-ecf-contrato > 0
            then do:
                ctcartcl.dif-ecf-contrato = (dctcartcl.dif-ecf-contrato *
                   ((ctcartcl.dif-ecf-contrato / 100) / tt-financeira)) * 100.
            end.
        end.  
        end. 
        output stream tl close.  
    end.                                
end procedure. 

form with frame fxy1.      
procedure cal-devolucao:
    def var vestorno as dec.
    def var vtotal as dec.
    def var vtotdevol as dec.
    def var t-devol as dec.
    def var vdata as date.
    vtotdevol = 0.
    vestorno = 0.
    vtotal = 0.
    t-devol = 0.
    
    for each ctcartcl where
            ctcartcl.datref >= vdti and
            ctcartcl.datref <= vdtf and
            ctcartcl.etbcod = 0
            no-lock:
        vtotdevol = vtotdevol + (ctcartcl.dec3 / 100).
    end.
    for each tt-devol:
        delete tt-devol.
    end.    
    output stream tl to terminal.
    for each tt-estab no-lock:
        disp stream tl "Processando Devolucao... " tt-estab.etbcod  
                with frame fxy1 no-label 1 down centered no-box
                color message .
             pause 0.
        
        for each ctcartcl where
            ctcartcl.datref >= vdti and
            ctcartcl.datref <= vdtf and
            ctcartcl.etbcod = tt-estab.etbcod
            .
            ctcartcl.devolucao = 0.
        end.

        for each ctdevven where ctdevven.etbcod = tt-estab.etbcod and
                            ctdevven.pladat >= vdti and
                            ctdevven.pladat <= vdtf and
                            ctdevven.movtdc = 12   and
                            ctdevven.pladat-ori < vdti
                            no-lock.
        find first plani where plani.etbcod = ctdevven.etbcod-ori and
                         plani.placod = ctdevven.placod-ori and
                         plani.movtdc = ctdevven.movtdc-ori 
                         no-lock no-error.

        if avail plani  and plani.crecod = 2 and plani.pladat < vdti
        then do:
            find contnf where contnf.etbcod = plani.etbcod and
                              contnf.placod = plani.placod
                              no-lock no-error.
            if avail contnf
            then do:
                find contrato where contrato.contnum = contnf.contnum
                            no-lock no-error.
                if avail contrato
                then do:
                    find first envfinan where 
                                       envfinan.empcod = 19
                                    and envfinan.titnat = no
                                    and envfinan.modcod = "CRE"
                                    and envfinan.etbcod = contrato.etbcod
                                    and envfinan.clifor = contrato.clicod
                                  and envfinan.titnum = string(contrato.contnum)
                                    no-lock no-error.
                    if  avail envfinan
                    then.
                    else do:

                    find cpcontrato where 
                            cpcontrato.contnum  = contrato.contnum /*and
                            cpcontrato.indecf = yes*/
                            no-error.
                    if avail cpcontrato and
                            (vtotdevol = 0 or
                           t-devol + contrato.vltotal <= vtotdevol )
                    then do:
                        find contarqm where 
                            contarqm.contnum = contrato.contnum no-error.
                        if not avail contarqm
                        then do:
                            create contarqm.
                            buffer-copy contrato to contarqm.
                        end.
                        
                        if contarqm.situacao = 4
                        then.
                        else do:
                        assign    
                            contarqm.situacao = 4
                            contarqm.datexp    = ctdevven.pladat
                            .
                        for each titulo where
                                 titulo.empcod = 19 and
                                 titulo.titnat = no and
                                 titulo.modcod = "CRE" and
                                 titulo.etbcod = contrato.etbcod and
                                 titulo.clifor = contrato.clicod and
                                 titulo.titnum = string(contrato.contnum)
                                 no-lock .
                            if titulo.titdtpag < vdti
                            then vestorno = vestorno + titulo.titvlcob.
                            else do:
                                vtotal = vtotal + titulo.titvlcob.
                                contarqm.vlfrete = 
                                     contarqm.vlfrete + titulo.titvlcob.
                            end.
                        end.
                        end.
                        find first tt-devol where
                                   tt-devol.etbcod = tt-estab.etbcod and
                                   tt-devol.data   = ctdevven.pladat
                                   no-error.
                        if not avail tt-devol
                        then do:
                            create tt-devol.
                            assign
                                tt-devol.etbcod = tt-estab.etbcod
                                tt-devol.data   = ctdevven.pladat
                                    .
                        end.
                        tt-devol.valor = tt-devol.valor + contarqm.vltotal.
                        t-devol = t-devol + contarqm.vltotal.
                        if contarqm.vlfrete > contarqm.vltotal
                        then contarqm.vlfrete = contarqm.vltotal.
                        cpcontrato.indecf = yes.
                    end.
                    /*else if avail cpcontrato
                    then cpcontrato.indecf = no.
                    */ end.
                end.
            end.
        end.
        else if avail plani  and plani.crecod <> 2 and plani.pladat < vdti
        then do:
            find first ctcartcl where 
                       ctcartcl.etbcod = plani.etbcod and
                       ctcartcl.datref = plani.pladat 
                       no-error.
            if not avail ctcartcl
            then do:
                create ctcartcl.
                assign
                    ctcartcl.etbcod = plani.etbcod
                    ctcartcl.datref = plani.pladat
                    .
            end.     
            ctcartcl.devolucao = ctcartcl.devolucao + plani.platot.
        end.
        end.
    end.
    
    for each tt-estab no-lock:
        disp stream tl "Processando Devolucao... " tt-estab.etbcod  
                with frame fxy1 no-label 1 down centered no-box
                color message .
             pause 0.
        
        for each ctdevven where ctdevven.etbcod = tt-estab.etbcod and
                            ctdevven.pladat >= vdti and
                            ctdevven.pladat <= vdtf and
                            ctdevven.movtdc = 12    and
                            ctdevven.pladat-ori >= vdti
                            no-lock.
        find first plani where plani.etbcod = ctdevven.etbcod-ori and
                         plani.placod = ctdevven.placod-ori and
                         plani.movtdc = ctdevven.movtdc-ori and
                         plani.pladat = ctdevven.pladat-ori
                         no-lock no-error.

        if avail plani  and plani.crecod = 2 and plani.pladat >= vdti and
                plani.pladat <= vdtf
        then do:
            find contnf where contnf.etbcod = plani.etbcod and
                              contnf.placod = plani.placod
                              no-lock no-error.
            if avail contnf
            then do:
                find contrato where contrato.contnum = contnf.contnum
                            no-lock no-error.
                if avail contrato
                then do:
                    find first envfinan where 
                                       envfinan.empcod = 19
                                    and envfinan.titnat = no
                                    and envfinan.modcod = "CRE"
                                    and envfinan.etbcod = contrato.etbcod
                                    and envfinan.clifor = contrato.clicod
                                  and envfinan.titnum = string(contrato.contnum)
                                    no-lock no-error.
                    if  avail envfinan
                    then.
                    else do:

                    find cpcontrato where 
                            cpcontrato.contnum  = contrato.contnum /*and
                            cpcontrato.indecf = yes                  */
                            no-error.
                    if avail cpcontrato and
                           ( vtotdevol = 0 or
                           t-devol + contrato.vltotal <= vtotdevol )
                    then do:
                        find contarqm where 
                            contarqm.contnum = contrato.contnum no-error.
                        if not avail contarqm
                        then do:
                            create contarqm.
                            buffer-copy contrato to contarqm.
                        end.
                        
                        if contarqm.situacao = 4
                        then.
                        else do:
                        assign    
                            contarqm.situacao = 4
                            contarqm.datexp    = ctdevven.pladat
                            .
                        for each titulo where
                                 titulo.empcod = 19 and
                                 titulo.titnat = no and
                                 titulo.modcod = "CRE" and
                                 titulo.etbcod = contrato.etbcod and
                                 titulo.clifor = contrato.clicod and
                                 titulo.titnum = string(contrato.contnum)
                                 no-lock .
                            if titulo.titdtpag < vdti
                            then vestorno = vestorno + titulo.titvlcob.
                            else do:
                                vtotal = vtotal + titulo.titvlcob.
                                contarqm.vlfrete = 
                                     contarqm.vlfrete + titulo.titvlcob.
                            end. 
                        end.
                        end. 
                        find first tt-devol where
                                   tt-devol.etbcod = tt-estab.etbcod and
                                   tt-devol.data   = ctdevven.pladat
                                   no-error.
                        if not avail tt-devol
                        then do:
                            create tt-devol.
                            assign
                                tt-devol.etbcod = tt-estab.etbcod
                                tt-devol.data   = ctdevven.pladat
                                    .
                        end.
                        tt-devol.valor = tt-devol.valor + contarqm.vltotal.
                        t-devol = t-devol + contarqm.vltotal. 
                        if contarqm.vlfrete > contarqm.vltotal
                        then contarqm.vlfrete = contarqm.vltotal.
                        cpcontrato.indecf = yes.
                    end.
                    /*else if avail cpcontrato
                    then cpcontrato.indecf = no.
                    */ end.
                end.
            end.
        end.
        else if avail plani  and plani.crecod <> 2 and 
            plani.pladat >= vdti and
            plani.pladat <= vdtf
        then do:
                                
            find first ctcartcl where 
                       ctcartcl.etbcod = plani.etbcod and
                       ctcartcl.datref = plani.pladat 
                       no-error.
            if not avail ctcartcl
            then do:
                create ctcartcl.
                assign
                    ctcartcl.etbcod = plani.etbcod
                    ctcartcl.datref = plani.pladat
                    .
            end.     
            ctcartcl.devolucao = ctcartcl.devolucao + plani.platot.
        end.
        
        
        end.
        
    end.                                    
    output stream tl close.
    for each tt-devol.
        disp tt-devol.
    end.    
    disp vtotdevol format ">>,>>>,>>9.99" t-devol format ">>,>>>,>>9.99". pause.
    if vtotdevol <> t-devol
    then do:
        find first ctcartcl where
            ctcartcl.datref = vdtf and
            ctcartcl.etbcod = 0
            no-error.
        if avail ctcartcl
        then assign
                ctcartcl.devolucao = ctcartcl.devolucao + 
                                            (vtotdevol - t-devol)
                ctcartcl.dec3 = t-devol * 100.    

    end.

    for each tt-devol where tt-devol.etbcod > 0:
        find first ctcartcl where 
                       ctcartcl.etbcod = tt-devol.etbcod and
                       ctcartcl.datref = tt-devol.data 
                       no-error.
        if not avail ctcartcl
        then do:
            create ctcartcl.
            assign
                ctcartcl.etbcod = tt-devol.etbcod
                ctcartcl.datref = tt-devol.data
               .
        end.     
        ctcartcl.dec3 = tt-devol.valor * 100.
    end.    
end procedure.  

procedure venda-financeira:
    def var vetbcod like estab.etbcod.
    def var val-financeira as dec.
    def var vdata as date.
    def var vtotal as dec.
    def var t-financeira as dec init 0.
    def var vdtifin as date format "99/99/9999".
    def var vdtffin as date format "99/99/9999".
    
    val-financeira = 0.
    vtotal = 0.
    /*
    update vdtifin label "Periodo de"
           vdtffin label "Ate"
           with frame fdtf 1 down side-label centered
           row 7.
    */
    for each ctcartcl where
            ctcartcl.datref >= vdti and
            ctcartcl.datref <= vdtf and
            ctcartcl.etbcod = 0
            no-lock:
        val-financeira = val-financeira + ctcartcl.dif-ecf-contrato.
    end.
    for each tt-financeira:
        delete tt-financeira.
    end.    
    if val-financeira > 0
    then
    for each tt-estab no-lock:
        do vdata = vdti to vdtf:
        disp "Processando... " tt-estab.etbcod vdata
        with frame f-find 1 down no-label color message no-box row 10
        centered.
        pause 0.
        t-financeira = 0.
        for each contrato where contrato.dtinicial = vdata and
                            contrato.etbcod = tt-estab.etbcod no-lock:
        for each titulo where titulo.empcod = 19 and
                              titulo.titnat = no and
                              titulo.modcod = "CRE" and
                              titulo.etbcod = contrato.etbcod and
                              titulo.clifor = contrato.clicod and
                              titulo.titnum = string(contrato.contnum) and
                              titulo.cobcod = 10
                              no-lock:
            find envfinan of titulo no-lock no-error.
            if avail envfinan and
                vtotal + titulo.titvlcob <= val-financeira
            then do:
                vtotal = vtotal + titulo.titvlcob.
                t-financeira = t-financeira + titulo.titvlcob.
            end.
        end.
        end.
        find first tt-financeira where
                   tt-financeira.etbcod = tt-estab.etbcod and
                   tt-financeira.data = vdata
                   no-error.
        if not avail tt-financeira
        then do:
            create tt-financeira.
            assign
                tt-financeira.etbcod = tt-estab.etbcod 
                tt-financeira.data   = vdata.
                
        end.    
        tt-financeira.valor = t-financeira.       
        end.
    end.
    for each ctcartcl where ctcartcl.etbcod > 0 and
                             ctcartcl.datref >= vdti and
                             ctcartcl.datref <= vdtf
                             .
        ctcartcl.dif-ecf-contrato = 0.
    end.
                                 
    message vtotal val-financeira. pause.
    for each tt-financeira:
        find ctcartcl where ctcartcl.etbcod = tt-financeira.etbcod and
                            ctcartcl.datref = tt-financeira.data
                             no-error.
        if not avail ctcartcl
        then do:
            create ctcartcl.
            assign
                ctcartcl.etbcod = tt-financeira.etbcod
                ctcartcl.datref = tt-financeira.data.
        end.    
        ctcartcl.dif-ecf-contrato = tt-financeira.valor.
    end.

    /*****
    update vetbcod  label "Filial" 
            val-financeira label "Valor Financeira" 
            with frame f-etb 1 down centered row 10
        side-label.
    do vdata = vdti to vdtf:
        find ctcartcl where ctcartcl.etbcod = vetbcod and
                             ctcartcl.datref = vdata
                             no-error.
        if not avail ctcartcl
        then do:
            create ctcartcl.
            assign
                ctcartcl.etbcod = vetbcod 
                ctcartcl.datref = vdata.
        end.
        ctcartcl.dif-ecf-contrato = 0.        
        for each titulo where cobcod = 10 and
                titdtemi = vdata  and
                titulo.etbcod = vetbcod  no-lock:
            ctcartcl.dif-ecf-contrato = ctcartcl.dif-ecf-contrato +
                                titulo.titvlcob.
            t-financeira = t-financeira + titulo.titvlcob.
        end.

    end.
    find ctcartcl where ctcartcl.etbcod = vetbcod and
                             ctcartcl.datref = vdtf
                             no-error.
    ctcartcl.dif-ecf-contrato = ctcartcl.dif-ecf-contrato +
                val-financeira - t-financeira.
    ****/
end procedure.    
***/

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
