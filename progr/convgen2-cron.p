{admcab-batch.i new}
{admcom_funcoes.i}

def output parameter varquivo as char.
def var /*output parameter*/ varqexc as char.

def var vlinha as int.

def temp-table tt-dados
    field linha as int
    field tipo as char
    field qtdext as int
    field campo as char extent 50
    index i1  linha
    .

def var val_acr like plani.platot.
def var val_des like plani.platot.
def var val_dev like plani.platot.
def var val_com like plani.platot.
def var val_fin like plani.platot.

def var vrodameta   as   log init yes.
def var vdtim       as   date.
def var vdtfm       as   date.
def var v-totcom    as   dec.
def var v-totalzao  as   dec.
def var vpago       as   dec.
def var vhora       as   char.
def var vok         as   logical.
def var vquant      like movim.movqtm.
def var flgetb      as   log.
def var vmovtdc     like tipmov.movtdc.
def var v-totaldia  as   dec.
def var v-total     as   dec.
def var v-totdia    as   dec.
def var v-nome      like estab.etbnom.
def var d           as   date.
def var i           as   int.
def var v-qtd       as   dec.
def var v-tot       as   dec.
def var v-movtdc    like plani.movtdc.
def var v-dif       as dec.
def var v-valor     as dec decimals 2.
def var fila as char.
def var recimp as recid.
def var vetbcod     like plani.etbcod no-undo.
def var v-totger    as dec.
def new shared      var vdti        as date format "99/99/9999" no-undo.
def new shared      var vdtf        as date format "99/99/9999" no-undo.
def var p-vende     like func.funcod.
def new shared var p-loja      like estab.etbcod.
def var p-setor     like setor.setcod.
def var p-grupo     like clase.clacod.
def var p-clase     like clase.clacod.
def var p-sclase    like clase.clacod.
def var varqsai     as char.
def var v-totperc   as dec.
def var v-titset    as char.
def var v-titgru    as char.
def var v-titcla    as char.
def var v-titscla   as char.
def var v-titvenpro as char.
def var v-titven    as char.
def var v-titpro    as char.
def var v-perdia    as dec label "% Dia".
def var v-perdia2   like v-perdia .
def var v-perc      as dec label "% Acum".
def var v-perdev    as dec label "% Dev" format ">9.99".
def var v-totcom0   as dec.
def var v-totsem0   as dec.
def new shared var v-etccod    like estac.etccod.
def new shared var v-carcod    like caract.carcod.
def new shared var v-subcod    like subcaract.subcod.
def new shared var v-subcar    like subcaract.subcar.
def buffer sclase   for clase.
def buffer grupo    for clase.

def buffer nivel1 for clase.
def buffer nivel2 for clase.

def new shared temp-table ttloja
    field medven    like plani.platot
    field medqtd    like movim.movqtm
    field metlj     like plani.platot
    field platot    like plani.platot
    field etbnom    like estab.etbnom
    field etbcod    like plani.etbcod
    field pladia    like plani.platot
    index loja      etbcod 
    index ranking platot desc.

def buffer bttloja for ttloja.

def var v-meta as log format "Sim/Nao".

def new shared temp-table ttsetor 
    field platot    like plani.platot
    field platot-ant    like plani.platot
    field setcod    like setor.setcod
    field data       like plani.pladat
    field qtd       like movim.movqtm
    field pladia    like plani.platot
    field etbcod    like plani.etbcod
    index setor     etbcod data setcod 
    index valor     platot desc.
    
def new shared temp-table ttgrupo
    field platot    like plani.platot
    field platot-ant    like plani.platot
    field clacod    like clase.clacod
    field pladia    like plani.platot
    field qtd       like movim.movqtm
    field etbcod    like plani.etbcod
    field setcod    like produ.catcod
    index grupo     etbcod setcod clacod 
    index valor     platot desc.
    
def new shared temp-table ttvend
    field platot    like plani.platot
    field platot-ant    like plani.platot
    field funcod    like plani.vencod
    field pladia    like plani.platot
    field qtd       like movim.movqtm
    field numseq    like movim.movseq
    field etbcod    like plani.etbcod
    index valor     platot desc.
    
def new shared temp-table ttvenpro
    field platot    like plani.platot
    field platot-ant    like plani.platot
    field funcod    like plani.vencod 
    field pladia    like plani.platot
    field qtd       like movim.movqtm
    field procod    like produ.procod
    field etbcod    like plani.etbcod
    index valor     platot desc.

def new shared temp-table ttprodu
    field platot    like plani.platot
    field platot-ant    like plani.platot
    field etbcod    like plani.etbcod
    field qtd       like movim.movqtm
    field pladia    like plani.platot
    field procod    like produ.procod
    field clacod    like plani.placod 
    index produ     procod etbcod clacod
    index valor     platot desc.
    
def new shared temp-table ttclase 
    field platot    like plani.platot
    field platot-ant    like plani.platot
    field etbcod    like plani.etbcod
    field qtd       like movim.movqtm
    field clacod    like clase.clacod
    field pladia    like plani.platot
    field clasup    like clase.clasup
    index clase     etbcod clacod.
    
/***/

def new shared temp-table ttnivel1
    field platot    like plani.platot
    field platot-ant    like plani.platot
    field etbcod    like plani.etbcod
    field qtd       like movim.movqtm
    field clacod    like clase.clacod
    field pladia    like plani.platot
    field clasup    like clase.clasup
    index clase     etbcod clacod.

def new shared temp-table ttnivel2 
    field platot    like plani.platot
    field platot-ant    like plani.platot
    field etbcod    like plani.etbcod
    field qtd       like movim.movqtm
    field clacod    like clase.clacod
    field pladia    like plani.platot
    field clasup    like clase.clasup
    index clase     etbcod clacod.

/***/    

def new shared temp-table ttsclase 
    field platot    like plani.platot
    field platot-ant    like plani.platot
    field qtd       like movim.movqtm
    field etbcod    like plani.etbcod
    field clacod    like clase.clacod
    field pladia    like plani.platot
    field clasup    like clase.clasup
    index sclase    etbcod clacod.

form
    clase.clacod
    clase.clanom
        help " ENTER = Seleciona" 
    produ.catcod 
    categoria.catnom
    with frame f-consulta
        color yellow/blue centered down overlay title " CLASSES " .

form
    ttvend.numseq   column-label "Rk" format ">>9" 
    help " F8 = Imprime "
    ttvend.funcod   column-label "Cod" format ">>>>9"
    func.funnom    format "x(18)" 
    ttvend.qtd     column-label "Qtd" format ">>>9" 
    ttvend.pladia  format "->>,>>>,>>9.99" column-label "Vnd.Dia" 
    v-perdia        column-label "% Dia" format "->>9.99" 
    ttvend.platot  format "->>,>>>,>>9.99"  column-label "Vnd.Acum" 
    v-perc          column-label "%Acum"    format "->>9.99"
    with frame f-vend
        centered
        down 
        title v-titven.
        
form
    ttvenpro.procod
       help "F8=Imprime"
    produ.pronom    format "x(18)" 
    ttvenpro.qtd     column-label "Qtd" format ">>>9" 
    ttvenpro.pladia  format "->>,>>>,>>9.99" column-label "Vnd.Dia" 
    v-perdia        column-label "% Dia" format "->>9.99" 
    ttvenpro.platot  format "->>,>>>,>>9.99"  column-label "Vnd.Acum" 
    v-perc          column-label "%Acum"    format "->>9.99"
    with frame f-vendpro
        centered
        down 
        title v-titvenpro.
 
form
    ttloja.etbcod
        help "ENTER=Seleciona F4=Encerra F8=Imprime" 
    ttloja.metlj  column-label "Meta Loja" format "->>,>>>,>>9.99" 
    ttloja.platot  format "->>,>>>,>>9.99" column-label "Vnd.Acum"
    v-perdia      column-label "% V/M C0"
    v-perdia2     column-label "% V/M S0" format "->>9.99"
    ttloja.pladia     column-label "Prest.Paga" format  ">>,>>>,>>9.99"
    with frame f-lojas
        width 80
        centered
        color white/red
        down 
        title " VENDAS POR LOJA ".
        
form
    ttloja.etbcod
    estab.etbnom  format "x(14)" column-label "Estabel."  
    ttloja.metlj  column-label "Meta Loja" format "->>,>>>,>>9.99" 
    ttloja.platot  format "->>,>>>,>>9.99" column-label "Vnd.Acum"
    v-perdia      column-label "% V/M C0"
    v-perdia2     column-label "% V/M S0" format "->>9.99"
    ttloja.pladia column-label "Prest.Paga" format ">>,>>>,>>9.99" 
    with frame f-lojaimp
        width 180 
        centered
        down
        no-box.

form
    ttsetor.setcod
    setor.setnom    format "x(15)" 
    ttsetor.qtd     format ">>>9"  column-label "Qtd"
    ttsetor.pladia  format "->>,>>>,>>9.99" column-label "Vnd.Dia"
    v-perdia        format "->.99" column-label "% Dia" 
    ttsetor.platot  format "->>,>>>,>>9.99" column-label "Vnd.Acum" 
    v-perc          format "-9.99" column-label "% Acum" 
    with frame f-setor 
        centered
        width 80
        color white/green
        down  overlay
        title v-titset.
        
form
    ttgrupo.clacod
    clase.clanom    format "x(17)" 
    ttgrupo.qtd     format ">>>9" column-label "Qtd"
    ttgrupo.pladia  format "->>,>>>,>>9.99" column-label "Vnd.Dia"
    v-perdia        column-label "% Dia"    format "->>9.99"
    ttgrupo.platot  format "->>,>>>,>>9.99" column-label "Vnd.Acum" 
    v-perc          column-label "% Acum" format "->>9.99" 
    with frame f-grupo
        centered
        down 
        title v-titgru.
        
form
    ttprodu.procod  column-label "Cod" 
    produ.pronom    format "x(13)" 
    ttprodu.qtd     format ">>9" column-label "Qtd" 
    v-perdev  format ">9.99" column-label "% Dev"  
    ttprodu.pladia  format "->>,>>>,>>9.99"   column-label "V.Dia" 
    v-perdia        column-label "% Dia"  format "->>9.99" 
    ttprodu.platot  format "->>,>>>,>>9.99"    column-label "V.Acum" 
    v-perc          column-label "%Acum"  format "->>9.99" 
    with frame f-produ
        centered
        down 
        title v-titpro.
        
form
    ttclase.clacod
    clase.clanom    format "x(18)" 
    ttclase.qtd     column-label "Qtd" format ">>>9" 
    ttclase.pladia  format "->>,>>>,>>9.99" column-label "Vnd.Dia" 
    v-perdia        column-label "% Dia" format "->>9.99" 
    ttclase.platot  format "->>,>>>,>>9.99"  column-label "Vnd.Acum" 
    v-perc          column-label "%Acum"    format "->>9.99"
    with frame f-clase
        centered
        down 
        title v-titcla.
       
form
    ttsclase.clacod
    sclase.clanom    format "x(18)" 
    ttsclase.qtd        column-label "Qtd"   format ">>>9"    
    ttsclase.pladia  column-label "Vnd.Dia" format "->>,>>>,>>9.99"
    v-perdia         column-label "% Dia"
    ttsclase.platot  format "->>,>>>,>>9.99" column-label "Vnd.Acum"
    v-perc           column-label "% Acum" 
    with frame f-sclase
        centered down title v-titscla.

def var vfabcod like fabri.fabcod.
def var vforcod like forne.forcod.
        
form
    vetbcod  label  "Lj"
    /*estab.etbnom no-label format "x(15)" */
    /*vfabcod label "Fab"*/
    vforcod label "For"
    fabri.fabnom no-label format "x(10)"
    
    vdti     label "Dt.In"
    vdtf     label "Dt.Fi"
    vhora    label "H"
    v-etccod label "Estacao"
    v-carcod label "Caracteristica"
    v-subcod label "Sub-Caracteristica"
    with frame f-etb
        centered
        1 down side-labels title "Dados Iniciais"
        color white/bronw row 3 width 80.

def var v-opcao as char format "x(12)" extent 2 initial
    ["POR VENDEDOR","POR PRODUTOS"].
    
form
    v-opcao[1]  format "x(12)"
    v-opcao[2]  format "x(12)"
    with frame f-opcao
        centered 1 down no-labels overlay row 10 color white/green. 

/*
{selestab.i vetbcod f-etb} */

def buffer testab for estab.    
repeat:
    clear frame f-mat all.
    hide frame f-mat.
    for each ttvenpro : delete ttvenpro. end.
    for each ttvend : delete ttvend. end.
    for each ttprodu :  delete ttprodu. end.
    for each ttloja :  delete ttloja. end.
    for each ttsetor : delete ttsetor. end.
    for each ttgrupo : delete ttgrupo. end.
    for each ttclase : delete ttclase. end. 
    for each ttsclase : delete ttsclase. end.
    /*
    assign 
        vdti = date(month(today),1,year(today))  
        vdtf = date(month(today),day(today) - 1,year(today)).
    */
    assign 
        vdti = today - 1 .
        vdti = date(month(vdti),1 ,year(vdti)).  
        /* Acumulado desde inicio do mes */
        vdtf = today - 1.
 
    vfabcod = vforcod.
    
    scopias = 0.     
    for each ttvenpro : delete ttvenpro. end.
    for each ttvend : delete ttvend. end.
    for each ttprodu :  delete ttprodu. end.
    for each ttloja :  delete ttloja. end.
    for each ttnivel1: delete ttnivel1. end.
    for each ttnivel2: delete ttnivel2. end.
    for each ttsetor : delete ttsetor. end.
    for each ttgrupo : delete ttgrupo. end.
    for each ttclase : delete ttclase. end. 
    for each ttsclase : delete ttsclase. end.

    hide frame f-fab0 no-pause.
    hide frame f-fab1 no-pause.
    
    assign v-totcom0 = 0 v-totsem0 = 0  v-qtd = 0 vpago = 0.
    
    run calcv101.

    leave.
end. 
vlinha =  1.
create tt-dados.
assign
        tt-dados.linha = vlinha
        tt-dados.tipo  = "C"
        tt-dados.qtdext = 11
        tt-dados.campo[2] = "PERIODO DE"
        tt-dados.campo[3] = STRING(VDTI,"99/99/99")
        tt-dados.campo[4] = "  ATE "
        tt-dados.campo[5] = string(vdtf,"99/99/99")        
        .
 
vlinha = vlinha + 1.
create tt-dados.
assign
        tt-dados.linha = vlinha
        tt-dados.tipo  = "L"
        tt-dados.qtdext = 11
        tt-dados.campo[1] = "Data"
        tt-dados.campo[2] = "Moveis"
        tt-dados.campo[3] = "Acumulado"
        tt-dados.campo[4] = "Confeccao"
        tt-dados.campo[5] = "Acumulado"
        tt-dados.campo[6] = "Total Dia"
        tt-dados.campo[7] = "Acumulado"
                .

def var v01 as int.
def var v02 as int.
def var v03 as int.
def var v04 as int.
def var v05 as int.

varqsai = "/admcom/relat-auto/" + string(day(today),"99") + "-" + 
                                   string(month(today),"99") + "-" + 
                                   string(year(today),"9999") +
                        "/PERFV-" + string(day(vdtf),"99") +  
                                   string(month(vdtf),"99") + 
                                   string(year(vdtf),"9999") +
                            "." + string(time).
 
  
   {mdad_l.i
            &Saida     = "value(varqsai)"
            &Page-Size = "0"
            &Cond-Var  = "147"
            &Page-Line = "64"
            &Nom-Rel   = ""convgen2-cron""
            &Nom-Sis   = """SISTEMA COMERCIAL"""
            &Tit-Rel   = """ VENDAS - PERIODO DE "" 
                          + string (vdti, ""99/99/9999"") +
                          "" ATE  "" + string(vdtf,""99/99/9999"")"
            &Width     = "147"
            &Form      = "frame f-cabcab"}

def var val-31 as dec.
def var val-41 as dec.
def var acum-31 as dec.
def var acum-41 as dec.
def var tota-3141 as dec.
def var acum-3141 as dec.
def var vesp as char.
form with frame f-d1.
assign v01 = 0 v02 = 0 v03 = 0 v04 = 0 v05 = 0.
def var vtotal-ant as dec.
def var vtotal-atu as dec.
assign vtotal-ant = 0 vtotal-atu = 0.
for each ttsetor where ttsetor.etbcod = 0 
            no-lock :
    find categoria  where categoria.catcod = ttsetor.setcod
                    no-lock no-error.
    v01 = ttsetor.setcod.
    disp v01 column-label "Setor"  format ">>>>9"  when v01 > 0
         v02 column-label "Nivel1"  format ">>>>9"  when v02 > 0
         v03 column-label "Nivel2" format ">>>>9"  when v03 > 0
         v04 column-label "Nivel3" format  ">>>>9"  when v04 > 0
         v05 column-label "Novel4" format ">>>>9"  when v05 > 0
         categoria.catnom no-label when avail categoria   
         ttsetor.platot  column-label "Mes atual"
         ttsetor.platot-ant column-label "Ano Anterior"
         with frame f-d1 down width 120.
    down with frame f-d1.
    assign
        vtotal-atu = vtotal-atu + ttsetor.platot
        vtotal-ant = vtotal-ant + ttsetor.platot-ant
        . 
end.
put fill("-",100) format "x(90)".
disp vtotal-atu @ ttsetor.platot
     vtotal-ant @ ttsetor.platot-ant
          with frame f-d1.
          down with frame f-d1.
put fill("-",100) format "x(90)".
          
assign vtotal-ant = 0 vtotal-atu = 0.
assign v01 = 0 v02 = 0 v03 = 0 v04 = 0 v05 = 0.
for each ttnivel1 where ttnivel1.etbcod = 0 no-lock:
                  /*where ttnivel1.clasup = ttsetor.setcod no-lock:*/
        find nivel1 where nivel1.clacod = ttnivel1.clacod no-lock.
        v02 = ttnivel1.clacod.
        disp v01   format ">>>>9" when v01 > 0
             v02   format ">>>>9" when v02 > 0
             v03   format ">>>>9" when v03 > 0
             v04   format ">>>>9" when v04 > 0
             v05   format ">>>>9" when v05 > 0
             nivel1.clanom   @ categoria.catnom   
             ttnivel1.platot @ ttsetor.platot   
             ttnivel1.platot-ant @ ttsetor.platot-ant
             with frame f-d1.
        down with frame f-d1.
        assign
        vtotal-atu = vtotal-atu + ttnivel1.platot
        vtotal-ant = vtotal-ant + ttnivel1.platot-ant
        . 
        assign vtotal-ant = 0 vtotal-atu = 0.
        /**/
        assign v01 = 0 v02 = 0 v03 = 0 v04 = 0 v05 = 0.
        /**/
        for each ttnivel2 where ttnivel2.etbcod = 0 and
                        ttnivel2.clasup = ttnivel1.clacod no-lock:
            find nivel2 where nivel2.clacod = ttnivel2.clacod no-lock.
            v03 = ttnivel2.clacod.
            disp v01   format ">>>>9" when v01 > 0
                 v02   format ">>>>9" when v02 > 0
                 v03   format ">>>>9" when v03 > 0
                 v04   format ">>>>9" when v04 > 0
                 v05   format ">>>>9" when v05 > 0
                 nivel2.clanom   @ categoria.catnom
                 ttnivel2.platot @ ttsetor.platot
                 ttnivel2.platot-ant @ ttsetor.platot-ant
                 with frame f-d1.
            down with frame f-d1.
            assign
            vtotal-atu = vtotal-atu + ttnivel2.platot
            vtotal-ant = vtotal-ant + ttnivel2.platot-ant
            . 
        
            assign vtotal-ant = 0 vtotal-atu = 0.
            /**/
            assign v01 = 0 v02 = 0 v03 = 0 v04 = 0 v05.
              /**/
            for each ttclase where  ttclase.etbcod = 0 and
                        ttclase.clasup = ttnivel2.clacod no-lock:
                find clase where clase.clacod = ttclase.clacod no-lock.
                v04 = ttclase.clacod.
                disp v01   format ">>>>9" when v01 > 0
                     v02   format ">>>>9" when v02 > 0
                     v03   format ">>>>9" when v03 > 0
                     v04   format ">>>>9" when v04 > 0
                     v05   format ">>>>9" when v05 > 0
                     clase.clanom   @ categoria.catnom
                     ttclase.platot @ ttsetor.platot
                     ttclase.platot-ant @ ttsetor.platot-ant
                     with frame f-d1.
                down with frame f-d1.
                assign
                vtotal-atu = vtotal-atu + ttclase.platot
                vtotal-ant = vtotal-ant + ttclase.platot-ant
                .
                assign vtotal-ant = 0 vtotal-atu = 0.
                /**/
                assign v01 = 0 v02 = 0 v03 = 0 v04 = 0 v05 = 0.
                 /**/
                for each ttsclase where  ttsclase.etbcod = 0 and
                         ttsclase.clasup = ttclase.clacod no-lock:
                    find sclase where sclase.clacod = ttsclase.clacod
                            no-lock.
                    v05 = ttsclase.clacod.
                    disp v01  format ">>>>9" when v01 > 0
                         v02  format ">>>>9" when v02 > 0
                         v03  format ">>>>9" when v03 > 0
                         v04  format ">>>>9" when v04 > 0
                         v05  format ">>>>9" when v05 > 0
                         sclase.clanom   @ categoria.catnom
                         ttsclase.platot @ ttsetor.platot
                         ttsclase.platot-ant @ ttsetor.platot-ant
                         with frame f-d1.
                    down with frame f-d1.
                    assign
                    vtotal-atu = vtotal-atu + ttsclase.platot
                    vtotal-ant = vtotal-ant + ttsclase.platot-ant
                    . 
                end.
            end.
        end.
    assign vtotal-ant = 0 vtotal-atu = 0.
end.
/**
            end.
        end.
    end.
    if ttsetor.setcod = 31
    then do:
        val-31 = val-31 + ttsetor.platot.
        tt-dados.campo[2] = troca-padrao-separador(ttsetor.platot).
        /* string(ttsetor.platot,">>,>>>,>>9.99").*/
        tota-3141 = tota-3141 + ttsetor.platot.
        acum-31 = acum-31 + ttsetor.platot.
        tt-dados.campo[3] = troca-padrao-separador(acum-31).
        /*string(acum-31,">>,>>>,>>9.99"). */
    end.
    if ttsetor.setcod = 41
    then do:
        val-41 = val-41 + ttsetor.platot.
        tt-dados.campo[4] = troca-padrao-separador(ttsetor.platot). 
        /*string(ttsetor.platot,">>,>>>,>>9.99").*/
        tota-3141 = tota-3141 + ttsetor.platot.
        acum-41 = acum-41 + ttsetor.platot.
        tt-dados.campo[5] = troca-padrao-separador(acum-41).
        /*string(acum-31,">>,>>>,>>9.99").*/
    end.
    if last-of(ttsetor.data)
    then do:
        tt-dados.campo[6] = troca-padrao-separador(tota-3141).
        /*string(tota-3141,">>,>>>,>>9.99").*/
        acum-3141 = acum-3141 + tota-3141.
        tt-dados.campo[7] = troca-padrao-separador(acum-3141).
        /*string(acum-3141,">>,>>>,>>9.99").*/
        
        disp ttsetor.data  column-label "Data"      format "99/99/9999"
             val-31        column-label "Moveis"    format ">>,>>>,>>9.99"
             acum-31       column-label "Acumulado" format ">>>,>>>,>>9.99"
             val-41        column-label "Confeccao" format ">>,>>>,>>9.99"
             acum-41       column-label "Acumulado" format ">>>,>>>,>>9.99"
             tota-3141     column-label  "Total Dia" format ">>>,>>>,>>9.99"
             acum-3141     column-label "Acumulado" format ">>>,>>>,>>9.99"
             with frame f-disp down width 125.
        down with frame f-disp.     

        assign
            val-31 = 0
            val-41 = 0
            tota-3141 = 0.
    end.
END.
**/
output close.
 /*
run visurel.p(varqsai,"").
*/
varquivo = varqsai.
/***********************************/
varqexc = "/admcom/relat-auto/" + string(day(today),"99") + "-" + 
                                   string(month(today),"99") + "-" + 
                                   string(year(today),"9999") +
                        "/PERFV-" + string(day(vdtf),"99") +  
                                   string(month(vdtf),"99") + 
                                   string(year(vdtf),"9999") +
                            string(time) + ".csv".
 
def var varqexc1 as char.
varqexc1 = "/admcom/relat-auto/" + string(day(today),"99") + "-" + 
                                   string(month(today),"99") + "-" + 
                                   string(year(today),"9999") +
                        "/PERFV-" + string(day(vdtf),"99") +  
                                   string(month(vdtf),"99") + 
                                   string(year(vdtf),"9999") +
                            string(time) + ".log".
 
def var vi as int.
/***********
output to value(varqexc) page-size 0.
    for each tt-dados use-index i1 no-lock:
        put unformatted 
            tt-dados.campo[1] format "x(15)"  ";"
            tt-dados.campo[2] format "x(15)" ";"
            tt-dados.campo[3] format "x(15)" ";"
            tt-dados.campo[4] format "x(15)" ";"
            tt-dados.campo[5] format "x(15)" ";"
            tt-dados.campo[6] format "x(15)" ";"
            tt-dados.campo[7] format "x(15)" ";"
            skip.
    end.    
output close.
def var vassunto as char.
vassunto = "teste".
def var v-mail as char.
v-mail = "claudir@custombs.com.br".
unix silent value("/admcom/progr/mail.sh "
                             + "~"" + vassunto + "~" "
                             + varqexc
                             + " "
                             + v-mail
                             + " "
                             + "informativo@lebes.com.br"
                             + " "
                             + "~"zip~""
                             + " > "
                             + varqexc1
                             + " 2>&1 ").      
*************/
 
procedure calcv101:

def var v-data-aux as date.
def var aux-dti as date.
def var aux-dtf as date.
assign
    aux-dti = date(month(vdti),day(vdti),year(vdti) - 1)
    aux-dtf = date(month(vdtf),day(vdtf),year(vdtf) - 1).
/* Antonio - Acumulado desde o começo do mes */
assign aux-dti = date(month(vdti),1,year(vdti) - 1).
/**/
    
IF VFABCOD = 0
THEN DO:
    find first tipmov where movtdc = 5 no-lock.
 
    for each estab where estab.etbnom begins "DREBES-FIL" NO-LOCK,
    each plani where plani.movtdc = tipmov.movtdc
                 and plani.etbcod = estab.etbcod
                 and plani.pladat >= vdti
                 and plani.pladat <= vdtf no-lock,
            each movim where movim.etbcod = plani.etbcod
                         and movim.placod = plani.placod
                         and movim.movtdc = plani.movtdc
                         and movim.movdat = plani.pladat no-lock,
            first produ where produ.procod = movim.procod no-lock,
            first sclase where sclase.clacod = produ.clacod no-lock,
            first clase where clase.clacod = sclase.clasup no-lock,
            first nivel2 where nivel2.clacod = clase.clasup no-lock,
            first nivel1 where nivel1.clacod = nivel2.clasup no-lock.
            
            /*
            disp  "Processando " estab.etbnom no-label
                  plani.pladat format "99/99/9999" 
                /*skip
                 produ.procod no-label produ.pronom format "x(40)" no-label*/
                 with frame f-vvv1
                            side-labels width 80. pause 0.
            */
            val_fin = 0.                    
            val_des = 0.   
            val_dev = 0.   
            val_acr = 0. 
                         
            val_acr =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                        plani.acfprod.
            if val_acr = ? then val_acr = 0.
            
            val_des =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                        plani.descprod.
            if val_des = ? then val_des = 0.
            val_dev =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                        plani.vlserv.
            if val_dev = ? then val_dev = 0.
            if (plani.platot - plani.vlserv - plani.descprod) < plani.biss
            then
                val_fin =  ((((movim.movpc * movim.movqtm) - val_dev - val_des)
                 / (plani.platot - plani.vlserv - plani.descprod))
                            * plani.biss) - ((movim.movpc * movim.movqtm) - 
                            val_dev - val_des).
            if val_fin = ? then val_fin = 0.
            
            val_com = (movim.movpc * movim.movqtm) - val_dev - val_des + 
                    val_acr +  val_fin. 

            if val_com = ? then val_com = 0.
             
           
            v-valor = val_com.

            find first ttsetor where ttsetor.etbcod = 0
                                 and ttsetor.setcod = produ.catcod
                                 and ttsetor.data   = ?
                                 use-index setor no-error.
            if not avail ttsetor then do:
                create ttsetor.
                assign  ttsetor.setcod = produ.catcod
                        ttsetor.etbcod = 0
                        ttsetor.data = ?.
            end. 
            ttsetor.platot = ttsetor.platot + v-valor. 
            
            find first ttnivel1 where ttnivel1.etbcod = 0 
                                 and ttnivel1.clacod = nivel1.clacod
                                 and ttnivel1.clasup = produ.catcod
                               use-index clase no-error.
            if not avail ttnivel1
            then do:
                create ttnivel1.
                assign  ttnivel1.clacod = nivel1.clacod
                        ttnivel1.clasup = produ.catcod
                        ttnivel1.etbcod = 0.
            end.
            ttnivel1.platot = ttnivel1.platot + v-valor.
  
            find first ttnivel2 where ttnivel2.etbcod = 0 
                                 and ttnivel2.clacod = nivel2.clacod
                                 and ttnivel2.clasup = nivel1.clacod
                               use-index clase no-error.
            if not avail ttnivel2
            then do:
                create ttnivel2.
                assign  ttnivel2.clacod = nivel2.clacod
                        ttnivel2.clasup = nivel1.clacod
                        ttnivel2.etbcod = 0.
            end.
            ttnivel2.platot = ttnivel2.platot + v-valor.
            
            find first ttclase where ttclase.etbcod = 0 
                                     and ttclase.clacod = clase.clacod
                                     and ttclase.clasup = nivel2.clacod
                                   use-index clase no-error.
            if not avail ttclase
            then do:
                    create ttclase.
                    assign  ttclase.clacod = clase.clacod
                            ttclase.clasup = nivel2.clacod
                            ttclase.etbcod = 0.
            end.
            ttclase.platot = ttclase.platot + v-valor.

            find first ttsclase where ttsclase.etbcod = 0
                                      and ttsclase.clacod = sclase.clacod
                                      and ttsclase.clasup = clase.clacod
                                      use-index sclase no-error.
            if not avail ttsclase
            then do:
                    create ttsclase.
                    assign  ttsclase.clacod = sclase.clacod
                            ttsclase.clasup = clase.clacod
                            ttsclase.etbcod = 0.
            end.
            ttsclase.platot = ttsclase.platot + v-valor.

    end.
    for each estab where estab.etbnom begins "DREBES-FIL" NO-LOCK,
    each plani where plani.movtdc = tipmov.movtdc
                 and plani.etbcod = estab.etbcod
                 and plani.pladat >= aux-dti
                 and plani.pladat <= aux-dtf no-lock,
            each movim where movim.etbcod = plani.etbcod
                         and movim.placod = plani.placod
                         and movim.movtdc = plani.movtdc
                         and movim.movdat = plani.pladat no-lock,
            first produ where produ.procod = movim.procod no-lock,
            first sclase where sclase.clacod = produ.clacod no-lock,
            first clase where clase.clacod = sclase.clasup no-lock,
            first nivel2 where nivel2.clacod = clase.clasup no-lock,
            first nivel1 where nivel1.clacod = nivel2.clasup no-lock.
            
            /**/
            disp  "Processando 1 " estab.etbnom no-label
                  plani.pladat format "99/99/9999" 
                /*skip
                 produ.procod no-label produ.pronom format "x(40)" no-label*/
                 with frame f-vvv11
                            side-labels width 80. pause 0.
            /**/
            val_fin = 0.                    
            val_des = 0.   
            val_dev = 0.   
            val_acr = 0. 
                         
            val_acr =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                        plani.acfprod.
            if val_acr = ? then val_acr = 0.
            
            val_des =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                        plani.descprod.
            if val_des = ? then val_des = 0.
            val_dev =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                        plani.vlserv.
            if val_dev = ? then val_dev = 0.
            if (plani.platot - plani.vlserv - plani.descprod) < plani.biss
            then
                val_fin =  ((((movim.movpc * movim.movqtm) - val_dev - val_des)
                 / (plani.platot - plani.vlserv - plani.descprod))
                            * plani.biss) - ((movim.movpc * movim.movqtm) - 
                            val_dev - val_des).
            if val_fin = ? then val_fin = 0.
            
            val_com = (movim.movpc * movim.movqtm) - val_dev - val_des + 
                    val_acr +  val_fin. 

            if val_com = ? then val_com = 0.
             
           
            v-valor = val_com.

            find first ttsetor where ttsetor.etbcod = 0
                                 and ttsetor.setcod = produ.catcod
                                 and ttsetor.data   = ?
                                 use-index setor no-error.
            if not avail ttsetor then do:
                create ttsetor.
                assign  ttsetor.setcod = produ.catcod
                        ttsetor.etbcod = 0
                        ttsetor.data = ?.
            end. 
            ttsetor.platot-ant = ttsetor.platot-ant + v-valor. 
            
            find first ttnivel1 where ttnivel1.etbcod = 0 
                                 and ttnivel1.clacod = nivel1.clacod
                                 and ttnivel1.clasup = produ.catcod
                               use-index clase no-error.
            if not avail ttnivel1
            then do:
                create ttnivel1.
                assign  ttnivel1.clacod = nivel1.clacod
                        ttnivel1.clasup = produ.catcod
                        ttnivel1.etbcod = 0.
            end.
            ttnivel1.platot-ant = ttnivel1.platot-ant + v-valor.
  
            find first ttnivel2 where ttnivel2.etbcod = 0 
                                 and ttnivel2.clacod = nivel2.clacod
                                 and ttnivel2.clasup = nivel1.clacod
                               use-index clase no-error.
            if not avail ttnivel2
            then do:
                create ttnivel2.
                assign  ttnivel2.clacod = nivel2.clacod
                        ttnivel2.clasup = nivel1.clacod
                        ttnivel2.etbcod = 0.
            end.
            ttnivel2.platot-ant  = ttnivel2.platot-ant + v-valor.
            
            find first ttclase where ttclase.etbcod = 0 
                                     and ttclase.clacod = clase.clacod
                                     and ttclase.clasup = nivel2.clacod
                                   use-index clase no-error.
            if not avail ttclase
            then do:
                    create ttclase.
                    assign  ttclase.clacod = clase.clacod
                            ttclase.clasup = nivel2.clacod
                            ttclase.etbcod = 0.
            end.
            ttclase.platot-ant = ttclase.platot-ant + v-valor.

            find first ttsclase where ttsclase.etbcod = 0
                                      and ttsclase.clacod = sclase.clacod
                                      and ttsclase.clasup = clase.clacod
                                      use-index sclase no-error.
            if not avail ttsclase
            then do:
                    create ttsclase.
                    assign  ttsclase.clacod = sclase.clacod
                            ttsclase.clasup = clase.clacod
                            ttsclase.etbcod = 0.
            end.
            ttsclase.platot-ant = ttsclase.platot-ant + v-valor.

    end.
END.
ELSE DO:

      for each produ use-index iprofab where produ.fabcod = vfabcod no-lock:  
        if v-etccod > 0 and
           produ.etccod <> v-etccod
        then next.
        if v-carcod > 0 and v-subcod > 0
        then do:
            find first procar where procar.procod = produ.procod and
                                 procar.subcod = v-subcod
                                 no-lock no-error.
            if not avail procar 
            then next.
        end.     
      
      do v-data-aux = vdti to vdtf:

        /*
      disp  v-data-aux format "99/99/9999"
            label "Processando"   /*skip
            produ.procod no-label produ.pronom format "x(40)" no-label*/
            
            with frame f-vvv2 width 80 side-labels. pause 0.
        */
        if vetbcod <> 0 
        then do:
            for each movim use-index icurva 
                       where movim.etbcod = vetbcod
                         and movim.movtdc = 5
                         and movim.procod = produ.procod
                         and movim.movdat = v-data-aux no-lock:
                
                find plani where plani.etbcod = movim.etbcod
                             and plani.placod = movim.placod 
                             and plani.pladat = movim.movdat
                             and plani.movtdc = movim.movtdc no-lock.
        
                find estab where estab.etbcod = plani.etbcod no-lock.
             
                find sclase where sclase.clacod = produ.clacod no-lock.
                find clase where clase.clacod = sclase.clasup no-lock.
            
                find nivel2 where nivel2.clacod = clase.clasup no-lock.
                find nivel1 where nivel1.clacod = nivel2.clasup no-lock.
 
                
                val_fin = 0.                   
                val_des = 0.  
                val_dev = 0.  
                val_acr = 0. 
                         
                val_acr =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                            plani.acfprod.
                if val_acr = ? then val_acr = 0.
                val_des =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                            plani.descprod.
                if val_des = ? then val_des = 0.            
                val_dev =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                            plani.vlserv.
                if val_dev = ? then val_dev = 0.
                if (plani.platot - plani.vlserv - plani.descprod) < plani.biss
                then
                val_fin =  ((((movim.movpc * movim.movqtm) - val_dev - val_des)~ /
                            (plani.platot - plani.vlserv - plani.descprod))
                            * plani.biss) - ((movim.movpc * movim.movqtm) - 
                            val_dev - val_des).
                if val_fin = ? then val_fin = 0.
                val_com = (movim.movpc * movim.movqtm) - val_dev - val_des + va~l_acr + 
                          val_fin. 

                if val_com = ? then val_com = 0.
                 
                v-valor = val_com.

                find first ttsetor where ttsetor.etbcod = plani.etbcod 
                                     and ttsetor.setcod = produ.catcod
                                     use-index setor no-error.
                if not avail ttsetor
                then do:
                    create ttsetor.
                    assign  ttsetor.setcod = produ.catcod
                            ttsetor.etbcod = plani.etbcod.
                end.

                ttsetor.platot = ttsetor.platot + v-valor. 
                ttsetor.qtd = ttsetor.qtd + movim.movqtm.
                if plani.pladat = vdtf
                then ttsetor.pladia = ttsetor.pladia + v-valor.

                find first ttsetor where ttsetor.etbcod = 0
                                     and ttsetor.setcod = produ.catcod
                                     use-index setor no-error.
                if not avail ttsetor
                then do:
                    create ttsetor.
                    assign  ttsetor.setcod = produ.catcod
                            ttsetor.etbcod = 0.
                end.

                if movim.movtdc <> 12 then do:
                    ttsetor.platot = ttsetor.platot + v-valor.
                    ttsetor.qtd = ttsetor.qtd + movim.movqtm.
                    if plani.pladat = vdtf
                    then ttsetor.pladia = ttsetor.pladia + v-valor.
                end.    

/*******/

            find first ttnivel1 where ttnivel1.etbcod = plani.etbcod
                                 and ttnivel1.clacod = nivel1.clacod
                                 and ttnivel1.clasup = produ.catcod
                               use-index clase no-error.
            if not avail ttnivel1
            then do:
                create ttnivel1.
                assign  ttnivel1.clacod = nivel1.clacod
                        ttnivel1.clasup = produ.catcod
                        ttnivel1.etbcod = plani.etbcod.
            end.
            if movim.movtdc <> 12
            then do :
                assign ttnivel1.qtd    = ttnivel1.qtd + movim.movqtm
                       ttnivel1.platot = ttnivel1.platot + v-valor.
                if plani.pladat = vdtf
                then ttnivel1.pladia = ttnivel1.pladia + v-valor.
            end.    
            
            find first ttnivel1 where ttnivel1.etbcod = 0 
                                 and ttnivel1.clacod = nivel1.clacod
                                 and ttnivel1.clasup = produ.catcod
                               use-index clase no-error.
            if not avail ttnivel1
            then do:
                create ttnivel1.
                assign  ttnivel1.clacod = nivel1.clacod
                        ttnivel1.clasup = produ.catcod
                        ttnivel1.etbcod = 0.
            end.
            if movim.movtdc <> 12
            then do :
                assign ttnivel1.qtd    = ttnivel1.qtd + movim.movqtm
                       ttnivel1.platot = ttnivel1.platot + v-valor.
                if plani.pladat = vdtf
                then ttnivel1.pladia = ttnivel1.pladia + v-valor.
            end.    
  
  /**************/
  
            find first ttnivel2 where ttnivel2.etbcod = plani.etbcod 
                                 and ttnivel2.clacod = nivel2.clacod
                                 and ttnivel2.clasup = nivel1.clacod
                                 use-index clase no-error.
            if not avail ttnivel2
            then do:
                create ttnivel2.
                assign  ttnivel2.clacod = nivel2.clacod
                        ttnivel2.clasup = nivel1.clacod
                        ttnivel2.etbcod = plani.etbcod.
            end.
            if movim.movtdc <> 12
            then do :
                assign ttnivel2.qtd    = ttnivel2.qtd + movim.movqtm
                       ttnivel2.platot = ttnivel2.platot + v-valor.
                if plani.pladat = vdtf
                then ttnivel2.pladia = ttnivel2.pladia + v-valor.
            end.    
            
            find first ttnivel2 where ttnivel2.etbcod = 0 
                                 and ttnivel2.clacod = nivel2.clacod
                                 and ttnivel2.clasup = nivel1.clacod
                               use-index clase no-error.
            if not avail ttnivel2
            then do:
                create ttnivel2.
                assign  ttnivel2.clacod = nivel2.clacod
                        ttnivel2.clasup = nivel1.clacod
                        ttnivel2.etbcod = 0.
            end.
            if movim.movtdc <> 12
            then do :
                assign ttnivel2.qtd    = ttnivel2.qtd + movim.movqtm
                       ttnivel2.platot = ttnivel2.platot + v-valor.
                if plani.pladat = vdtf
                then ttnivel2.pladia = ttnivel2.pladia + v-valor.
            end.    
    

/******/



                
                
                /************ gerando vendas para a clase *******/

                find first ttclase where ttclase.etbcod = plani.etbcod 
                                     and ttclase.clacod = clase.clacod
                                     and ttclase.clasup = nivel2.clacod
                                     use-index clase no-error.
                if not avail ttclase
                then do:
                    create ttclase.
                    assign  ttclase.clacod = clase.clacod
                            ttclase.clasup = nivel2.clacod
                            ttclase.etbcod = plani.etbcod.
                end.
                if movim.movtdc <> 12 then do:
                    assign ttclase.qtd    = ttclase.qtd + movim.movqtm
                           ttclase.platot = ttclase.platot + v-valor.
                    if plani.pladat = vdtf
                    then ttclase.pladia = ttclase.pladia + v-valor.
                end.    
            
                find first ttclase where ttclase.etbcod = 0 
                                     and ttclase.clacod = clase.clacod
                                     and ttclase.clasup = nivel2.clacod
                                   use-index clase no-error.
                if not avail ttclase
                then do:
                    create ttclase.
                    assign  ttclase.clacod = clase.clacod
                            ttclase.clasup = nivel2.clacod
                            ttclase.etbcod = 0.
                end.
                if movim.movtdc <> 12 then do:
                    assign ttclase.qtd    = ttclase.qtd + movim.movqtm
                           ttclase.platot = ttclase.platot + v-valor.
                    if plani.pladat = vdtf
                    then ttclase.pladia = ttclase.pladia + v-valor.
                end.    

                /******** gerando vendas para a sclase *******/
                            
                find first ttsclase where ttsclase.etbcod = plani.etbcod 
                                      and ttsclase.clacod = sclase.clacod
                                      and ttsclase.clasup = clase.clacod
                                      use-index sclase no-error.
                if not avail ttsclase
                then do:
                    create ttsclase.
                    assign  ttsclase.clacod = sclase.clacod
                            ttsclase.clasup = clase.clacod
                            ttsclase.etbcod = plani.etbcod.
                end.
                if movim.movtdc <> 12 then do:
                    assign  ttsclase.qtd = ttsclase.qtd + movim.movqtm
                            ttsclase.platot = ttsclase.platot + v-valor.
                    if plani.pladat = vdtf
                    then ttsclase.pladia = ttsclase.pladia + v-valor.
                end.    

                find first ttsclase where ttsclase.etbcod = 0
                                      and ttsclase.clacod = sclase.clacod
                                      and ttsclase.clacod = clase.clacod
                                      use-index sclase no-error.
                if not avail ttsclase
                then do:
                    create ttsclase.
                    assign  ttsclase.clacod = sclase.clacod
                            ttsclase.clasup = clase.clacod
                            ttsclase.etbcod = 0.
                end.
                if movim.movtdc <> 12 then do:
                    assign  ttsclase.qtd = ttsclase.qtd + movim.movqtm
                            ttsclase.platot = ttsclase.platot + v-valor.
                    if plani.pladat = vdtf
                    then ttsclase.pladia = ttsclase.pladia + v-valor.
                end.    
                        
                /************ gerando vendas para os produtos ********/

                find first ttprodu where ttprodu.etbcod = plani.etbcod 
                                     and ttprodu.procod = produ.procod
                                     and ttprodu.clacod = sclase.clacod
                                   use-index produ no-error.
                if not avail ttprodu
                then do:
                    create ttprodu.
                    assign  ttprodu.procod = produ.procod
                            ttprodu.clacod = sclase.clacod
                            ttprodu.etbcod = plani.etbcod.
                end.
                if movim.movtdc <> 12 then do:
                    assign  ttprodu.qtd = ttprodu.qtd + movim.movqtm
                            ttprodu.platot = ttprodu.platot + v-valor.
                    if plani.pladat = vdtf
                    then ttprodu.pladia = ttprodu.pladia + v-valor.
                end.    

                find first ttprodu where ttprodu.etbcod = 0
                                     and ttprodu.procod = produ.procod 
                                     and ttprodu.clacod = sclase.clacod
                                     use-index produ no-error.
                if not avail ttprodu
                then do:
                    create ttprodu.
                    assign  ttprodu.procod = produ.procod
                            ttprodu.clacod = sclase.clacod
                            ttprodu.etbcod = 0.
                end.
            
                if movim.movtdc <> 12 then do:
                    assign  ttprodu.qtd = ttprodu.qtd + movim.movqtm
                            ttprodu.platot = ttprodu.platot + v-valor.
                    if plani.pladat = vdtf
                    then ttprodu.pladia = ttprodu.pladia + v-valor.
                end.    
        
            end.
        end.
        else do:
        
            for each movim use-index datsai where movim.procod = produ.procod
                                      and movim.movtdc = 5
                                      and movim.movdat = v-data-aux no-lock:
                find plani where plani.etbcod = movim.etbcod
                     and plani.placod = movim.placod 
                     and plani.pladat = movim.movdat
                     and plani.movtdc = movim.movtdc no-lock.
                find estab where estab.etbcod = plani.etbcod no-lock.
                find sclase where sclase.clacod = produ.clacod no-lock.
                find clase where clase.clacod = sclase.clasup no-lock.
                find nivel2 where nivel2.clacod = clase.clasup no-lock.
                find nivel1 where nivel1.clacod = nivel2.clasup no-lock.
                
                val_fin = 0.                   
                val_des = 0.  
                val_dev = 0.  
                val_acr = 0. 
                         
                val_acr =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                            plani.acfprod.
                if val_acr = ? then val_acr = 0.
                val_des =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                            plani.descprod.
                if val_des = ? then val_des = 0.            
                val_dev =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                            plani.vlserv.
                if val_dev = ? then val_dev = 0.
                if (plani.platot - plani.vlserv - plani.descprod) < plani.biss
                then
                val_fin =  ((((movim.movpc * movim.movqtm) - val_dev - val_des)
                 / (plani.platot - plani.vlserv - plani.descprod))
                            * plani.biss) - ((movim.movpc * movim.movqtm) - 
                            val_dev - val_des).
                if val_fin = ? then val_fin = 0.
                val_com = (movim.movpc * movim.movqtm) - val_dev - val_des + 
                val_acr +  val_fin. 

                if val_com = ? then val_com = 0.
                 
                v-valor = val_com.

                find first ttsetor where ttsetor.etbcod = plani.etbcod 
                                     and ttsetor.setcod = produ.catcod
                                     use-index setor no-error.
                if not avail ttsetor
                then do:
                    create ttsetor.
                    assign  ttsetor.setcod = produ.catcod
                            ttsetor.etbcod = plani.etbcod.
                end.

                ttsetor.platot = ttsetor.platot + v-valor. 
                ttsetor.qtd = ttsetor.qtd + movim.movqtm.
                if plani.pladat = vdtf
                then ttsetor.pladia = ttsetor.pladia + v-valor.

                find first ttsetor where ttsetor.etbcod = 0
                                     and ttsetor.setcod = produ.catcod
                                     use-index setor no-error.
                if not avail ttsetor
                then do:
                    create ttsetor.
                    assign  ttsetor.setcod = produ.catcod
                            ttsetor.etbcod = 0.
                end.

                if movim.movtdc <> 12 then do:
                    ttsetor.platot = ttsetor.platot + v-valor.
                    ttsetor.qtd = ttsetor.qtd + movim.movqtm.
                    if plani.pladat = vdtf
                    then ttsetor.pladia = ttsetor.pladia + v-valor.
                end.    

/*******/

            find first ttnivel1 where ttnivel1.etbcod = plani.etbcod
                                 and ttnivel1.clacod = nivel1.clacod
                               use-index clase no-error.
            if not avail ttnivel1
            then do:
                create ttnivel1.
                assign  ttnivel1.clacod = nivel1.clacod
                        ttnivel1.clasup = produ.catcod
                        ttnivel1.etbcod = plani.etbcod.
            end.
            if movim.movtdc <> 12
            then do :
                assign ttnivel1.qtd    = ttnivel1.qtd + movim.movqtm
                       ttnivel1.platot = ttnivel1.platot + v-valor.
                if plani.pladat = vdtf
                then ttnivel1.pladia = ttnivel1.pladia + v-valor.
            end.    
            
            find first ttnivel1 where ttnivel1.etbcod = 0 
                                 and ttnivel1.clacod = nivel1.clacod
                               use-index clase no-error.
            if not avail ttnivel1
            then do:
                create ttnivel1.
                assign  ttnivel1.clacod = nivel1.clacod
                        ttnivel1.clasup = produ.catcod
                        ttnivel1.etbcod = 0.
            end.
            if movim.movtdc <> 12
            then do :
                assign ttnivel1.qtd    = ttnivel1.qtd + movim.movqtm
                       ttnivel1.platot = ttnivel1.platot + v-valor.
                if plani.pladat = vdtf
                then ttnivel1.pladia = ttnivel1.pladia + v-valor.
            end.    
  
  /**************/
  
            find first ttnivel2 where ttnivel2.etbcod = plani.etbcod 
                                 and ttnivel2.clacod = nivel2.clacod
                                 use-index clase no-error.
            if not avail ttnivel2
            then do:
                create ttnivel2.
                assign  ttnivel2.clacod = nivel2.clacod
                        ttnivel2.clasup = /*produ.catcod */ nivel1.clacod
                        ttnivel2.etbcod = plani.etbcod.
            end.
            if movim.movtdc <> 12
            then do :
                assign ttnivel2.qtd    = ttnivel2.qtd + movim.movqtm
                       ttnivel2.platot = ttnivel2.platot + v-valor.
                if plani.pladat = vdtf
                then ttnivel2.pladia = ttnivel2.pladia + v-valor.
            end.    
            
            find first ttnivel2 where ttnivel2.etbcod = 0 
                                 and ttnivel2.clacod = nivel2.clacod
                               use-index clase no-error.
            if not avail ttnivel2
            then do:
                create ttnivel2.
                assign  ttnivel2.clacod = nivel2.clacod
                        ttnivel2.clasup = /*produ.catcod */ nivel1.clacod
                        ttnivel2.etbcod = 0.
            end.
            if movim.movtdc <> 12
            then do :
                assign ttnivel2.qtd    = ttnivel2.qtd + movim.movqtm
                       ttnivel2.platot = ttnivel2.platot + v-valor.
                if plani.pladat = vdtf
                then ttnivel2.pladia = ttnivel2.pladia + v-valor.
            end.    
    

/******/



                
                
                /************ gerando vendas para a clase *******/

                find first ttclase where ttclase.etbcod = plani.etbcod 
                                     and ttclase.clacod = clase.clacod
                                     use-index clase no-error.
                if not avail ttclase
                then do:
                    create ttclase.
                    assign  ttclase.clacod = clase.clacod
                            ttclase.clasup = /*produ.catcod*/ nivel2.clacod
                            ttclase.etbcod = plani.etbcod.
                end.
                if movim.movtdc <> 12 then do:
                    assign ttclase.qtd    = ttclase.qtd + movim.movqtm
                           ttclase.platot = ttclase.platot + v-valor.
                    if plani.pladat = vdtf
                    then ttclase.pladia = ttclase.pladia + v-valor.
                end.    
            
                find first ttclase where ttclase.etbcod = 0 
                                     and ttclase.clacod = clase.clacod
                                   use-index clase no-error.
                if not avail ttclase
                then do:
                    create ttclase.
                    assign  ttclase.clacod = clase.clacod
                            ttclase.clasup = /*produ.catcod*/ nivel2.clacod
                            ttclase.etbcod = 0.
                end.
                if movim.movtdc <> 12 then do:
                    assign ttclase.qtd    = ttclase.qtd + movim.movqtm
                           ttclase.platot = ttclase.platot + v-valor.
                    if plani.pladat = vdtf
                    then ttclase.pladia = ttclase.pladia + v-valor.
                end.    

                /******** gerando vendas para a sclase *******/
                            
                find first ttsclase where ttsclase.etbcod = plani.etbcod 
                                      and ttsclase.clacod = sclase.clacod
                                      use-index sclase no-error.
                if not avail ttsclase
                then do:
                    create ttsclase.
                    assign  ttsclase.clacod = sclase.clacod
                            ttsclase.clasup = clase.clacod
                            ttsclase.etbcod = plani.etbcod.
                end.
                if movim.movtdc <> 12 then do:
                    assign  ttsclase.qtd = ttsclase.qtd + movim.movqtm
                            ttsclase.platot = ttsclase.platot + v-valor.
                    if plani.pladat = vdtf
                    then ttsclase.pladia = ttsclase.pladia + v-valor.
                end.    

                find first ttsclase where ttsclase.etbcod = 0
                                      and ttsclase.clacod = sclase.clacod
                                      use-index sclase no-error.
                if not avail ttsclase
                then do:
                    create ttsclase.
                    assign  ttsclase.clacod = sclase.clacod
                            ttsclase.clasup = clase.clacod
                            ttsclase.etbcod = 0.
                end.
                if movim.movtdc <> 12 then do:
                    assign  ttsclase.qtd = ttsclase.qtd + movim.movqtm
                            ttsclase.platot = ttsclase.platot + v-valor.
                    if plani.pladat = vdtf
                    then ttsclase.pladia = ttsclase.pladia + v-valor.
                end.    
                        
                /************ gerando vendas para os produtos ********/

                find first ttprodu where ttprodu.etbcod = plani.etbcod 
                                     and ttprodu.procod = produ.procod
                                     and ttprodu.clacod = sclase.clacod
                                   use-index produ no-error.
                if not avail ttprodu
                then do:
                    create ttprodu.
                    assign  ttprodu.procod = produ.procod
                            ttprodu.clacod = sclase.clacod
                            ttprodu.etbcod = plani.etbcod.
                end.
                if movim.movtdc <> 12 then do:
                    assign  ttprodu.qtd = ttprodu.qtd + movim.movqtm
                            ttprodu.platot = ttprodu.platot + v-valor.
                    if plani.pladat = vdtf
                    then ttprodu.pladia = ttprodu.pladia + v-valor.
                end.    

                find first ttprodu where ttprodu.etbcod = 0
                                     and ttprodu.procod = produ.procod 
                                     and ttprodu.clacod = sclase.clacod
                                     use-index produ no-error.
                if not avail ttprodu
                then do:
                    create ttprodu.
                    assign  ttprodu.procod = produ.procod
                            ttprodu.clacod = sclase.clacod
                            ttprodu.etbcod = 0.
                end.
            
                if movim.movtdc <> 12 then do:
                    assign  ttprodu.qtd = ttprodu.qtd + movim.movqtm
                            ttprodu.platot = ttprodu.platot + v-valor.
                    if plani.pladat = vdtf
                    then ttprodu.pladia = ttprodu.pladia + v-valor.
                end. 

        end.
      end.
    end.
    end.
    hide frame f-vvv2 no-pause.
END.
end procedure.




