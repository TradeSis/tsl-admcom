{/admcom/progr/admcab-batch.i new}
{/admcom/progr/admcom_funcoes.i}

sparam = SESSION:PARAMETER.

def var vdti as date.
def var vdtf as date.
def var par-etbcod like estab.etbcod.
par-etbcod = int(substr(sparam,1,3)).
vdti = date(int(substr(sparam,6,2)),int(substr(sparam,4,2)),
                int(substr(sparam,8,4))).
vdtf = vdti.
/*
vdtf = date(int(substr(sparam,12,2)),int(substr(sparam,14,2)),
                int(substr(sparam,16,4))).
*/
def var /*output parameter*/ varquivo as char.
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
    field setcod    like setor.setcod
    field data       like plani.pladat
    field qtd       like movim.movqtm
    field pladia    like plani.platot
    field etbcod    like plani.etbcod
    index setor     etbcod data setcod 
    index valor     platot desc.
    
def new shared temp-table ttgrupo
    field platot    like plani.platot
    field clacod    like clase.clacod
    field pladia    like plani.platot
    field qtd       like movim.movqtm
    field etbcod    like plani.etbcod
    field setcod    like produ.catcod
    index grupo     etbcod setcod clacod 
    index valor     platot desc.
    
def new shared temp-table ttvend
    field platot    like plani.platot
    field funcod    like plani.vencod
    field pladia    like plani.platot
    field qtd       like movim.movqtm
    field numseq    like movim.movseq
    field etbcod    like plani.etbcod
    index valor     platot desc.
    
def new shared temp-table ttvenpro
    field platot    like plani.platot
    field funcod    like plani.vencod 
    field pladia    like plani.platot
    field qtd       like movim.movqtm
    field procod    like produ.procod
    field etbcod    like plani.etbcod
    index valor     platot desc.

def new shared temp-table ttprodu
    field platot    like plani.platot
    field etbcod    like plani.etbcod
    field qtd       like movim.movqtm
    field pladia    like plani.platot
    field procod    like produ.procod
    field clacod    like plani.placod 
    index produ     procod etbcod clacod
    index valor     platot desc.
    
def new shared temp-table ttclase 
    field platot    like plani.platot
    field etbcod    like plani.etbcod
    field qtd       like movim.movqtm
    field clacod    like clase.clacod
    field pladia    like plani.platot
    field clasup    like clase.clasup
    index clase     etbcod clacod.
    
/***/

def new shared temp-table ttnivel1
    field platot    like plani.platot
    field etbcod    like plani.etbcod
    field qtd       like movim.movqtm
    field clacod    like clase.clacod
    field pladia    like plani.platot
    field clasup    like clase.clasup
    index clase     etbcod clacod.

def new shared temp-table ttnivel2 
    field platot    like plani.platot
    field etbcod    like plani.etbcod
    field qtd       like movim.movqtm
    field clacod    like clase.clacod
    field pladia    like plani.platot
    field clasup    like clase.clasup
    index clase     etbcod clacod.

/***/    

def new shared temp-table ttsclase 
    field platot    like plani.platot
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

/**** plani-4 *****/
def var vvldesc     like plani.descprod column-label "Desconto".
def var vvlacre     like plani.acfprod column-label "Acrescimo".
def var dt     like plani.pladat.
def var acum-c like plani.platot.
def var acum-m like plani.platot.
def var vdia as int format ">9".
def var meta-c like plani.platot.
def var meta-m like plani.platot.
def var vcon like plani.platot.
def var vmov like plani.platot.
def buffer cmovim for movim.
def var vcat like produ.catcod initial 41.
def var vj   as int.
def var lfin as log.
def var lcod as i.
def var vldev like plani.vlserv.
def buffer bmovim for movim.
def var wnp as i.
def var vvltotal as dec.
def var vvlcont  as dec.
def var wacr     as dec.
def var wper     as dec.
def var valortot as dec.
def var vval     as dec.
def var vval1    as dec.
def var vsal     as dec.
def var vlfinan  as dec.
def var aa-c like plani.platot.
def var aa-m like plani.platot.
def var mm-c like plani.platot.
def var mm-m like plani.platot.
def var vdtimp as date.
def var vfer as int.
def var vdtultatu as date.
def var ii as int.
def var vv as date.
def var dia-m as int.
def var dia-c as int.
def var vvalor as dec.
def var vignora as log.
def var vcatcod like produ.catcod.
def buffer bplani for plani.
def var tt-acum-c as dec.
def var tt-acum-m as dec.
def temp-table wplani
    field   wetbcod  like estab.etbcod
    field   wmeta    as char format "X"
    field   wetbcon  like estab.etbcon format ">>,>>>,>>9.99"
    field   wetbmov  like estab.etbmov format ">>,>>>,>>9.99"
    field   wdia     as int format "99"
    field   wmes     as int format "99"
    field   wmeta-c  like plani.platot
    field   wacum-c  like plani.platot
    field   wmeta-m  like plani.platot
    field   wacum-m  like plani.platot
    field   wdia-c   like plani.platot
    field   wdia-m   like plani.platot.


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
        vdti = date(month(today),1,year(today) - 1)  
        vdtf = today - 1. 
        /*date(month(today),day(today),year(today) - 1) .
            */
    */
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
    
    /*
    run calcv101.
    */
    
    run plani-4.
    
    leave.

end. 

def var val-31 as dec.
def var val-41 as dec.
def var acum-31 as dec.
def var acum-41 as dec.
def var tota-3141 as dec.
def var acum-3141 as dec.
vlinha = 1.

for each wplani where wplani.wetbcod > 0 
        no-lock break by wplani.wetbcod:
    tota-3141 = wplani.wdia-m + wplani.wdia-c.
    create tt-dados.
    assign
        tt-dados.linha = vlinha
        tt-dados.campo[1] = string(wplani.wetbcod,">>9")
        tt-dados.campo[2] = string(wplani.wacum-m,">>>>>>>>>>9.99")
        tt-dados.campo[3] = string(wplani.wacum-c,">>>>>>>>>>9.99")
        tt-dados.campo[4] = string(tota-3141,">>>>>>>>>>9.99")
        .
                   
    tota-3141 = 0.
    
    vlinha = vlinha + 1.

end.    

/*         
for each ttsetor where ttsetor.etbcod <> 0 
            no-lock break   by ttsetor.etbcod
                            by ttsetor.setcod:
    if first-of(ttsetor.etbcod)
    then do:
        create tt-dados.
        assign
            tt-dados.linha = vlinha
            tt-dados.campo[1] = string(ttsetor.etbcod,">>9")
            .
    end.            
    if ttsetor.setcod = 31
    then do:
        tt-dados.campo[2] = string(ttsetor.platot,">>>>>>>>>>9.99").
        tota-3141 = tota-3141 + ttsetor.platot.
    end.
    if ttsetor.setcod = 41
    then do:
        tt-dados.campo[3] = string(ttsetor.platot,">>>>>>>>>>9.99"). 
        tota-3141 = tota-3141 + ttsetor.platot.
    end.
    if last-of(ttsetor.etbcod)
    then do:
        tt-dados.campo[4] = string(tota-3141,">>>>>>>>>>9.99").
        
        assign
            val-31 = 0
            val-41 = 0
            tota-3141 = 0
            vlinha = vlinha + 1.

    end.
END.
*/
/*
output close. 
varquivo = varqsai.
*/
varqexc = "/var/www/drebes/progress/eis/" + string(day(vdti),"99") + "-" + 
                                   string(month(vdti),"99") + "-" + 
                                   string(year(vdti),"9999") +
                                   ".txt".
 
def var vi as int.
output to value(varqexc) page-size 0.
    for each tt-dados use-index i1 no-lock:
        put unformatted 
            tt-dados.campo[1] format "x(15)"  ";"
            tt-dados.campo[2] format "x(15)" ";"
            tt-dados.campo[3] format "x(15)" ";"
            tt-dados.campo[4] format "x(15)" ";"
            string(year(vdti),"9999") + "-" +
            string(month(vdti),"99") + "-" +
            string(day(vdti),"99")    format "x(12)"
            skip.
    end.    
output close.

procedure plani-4:

        assign vvldesc  = 0
               vvlacre  = 0
               vmov    = 0
               vcon    = 0
               acum-m   = 0
               acum-c   = 0
               mm-c     = 0
               mm-m     = 0
               aa-c     = 0
               aa-m     = 0.
    for each estab where (if par-etbcod > 0
                       then estab.etbcod = par-etbcod else true) /* AND
        estab.etbnom begins "DREBES-FIL" */ NO-LOCK:
     
        find first duplic where duplic.duppc = month(vdti) and
                                duplic.fatnum = estab.etbcod no-lock no-error.
        if not avail duplic
        then next.
        
        if estab.etbcod = 22
        then next.
        vdtimp = today.
        vfer = 0.

        find last bplani where bplani.etbcod = estab.etbcod and
                               bplani.movtdc = 5 and
                               month(bplani.pladat) <= month(vdti) no-lock
                                    use-index pladat no-error.

        if avail bplani
        then vdtultatu = bplani.pladat.
                              
        if vdtf > vdtultatu
        then vdtimp = vdtultatu.
        else vdtimp = vdtf.

        ii = 0.
        vfer = 0.
        vdia = 0.
        do vv = vdti to vdtf /*vdtimp*/:
           if weekday(vv) = 1
           then ii = ii + 1.
           find dtextra where dtextra.exdata  = vv no-lock no-error.
           if avail dtextra
           then vfer = vfer + 1.
           find dtesp where dtesp.datesp = vv and
                            dtesp.etbcod = estab.etbcod no-lock no-error.
           if avail dtesp
           then vfer = vfer + 1.
        end.
        
        vdia = int(day(vdtimp)) - ii - vfer.
        assign vmov    = 0
               vcon    = 0
               acum-c  = 0
               acum-m  = 0
               dia-m   = 0
               dia-c   = 0.

        do dt = vdti to vdtimp : 
          
          do vj = 1 to 2:

            if vj = 1 then vcatcod = 31 . /* Moveis */
            if vj = 2 then vcatcod = 41 . /*  Confeccoes */ 
          
            for each plani where plani.movtdc = 5             and
                                 plani.etbcod = estab.etbcod  and
                                 plani.pladat = dt no-lock:
                vvldesc = 0.
                vvlacre = 0.
                vvalor = 0.
                /* antonio */
                if vcatcod <> 31
                then vignora = no.
                else vignora = yes.
                if vcatcod > 0
                then
                for each movim where movim.etbcod = plani.etbcod and
                                     movim.placod = plani.placod and
                                     movim.movtdc = plani.movtdc and
                                     movim.movdat = plani.pladat
                                     no-lock:
                       find first produ where produ.procod = movim.procod
                            no-lock no-error.
                       if avail produ
                       then do:
                            if vcatcod <> 31 
                            then if produ.catcod <> vcatcod 
                                 then vignora = yes.
                            if vcatcod = 31 
                            then if produ.catcod = vcatcod or
                                    produ.procod = 88888
                                 then vignora = no. /* pelo menos 1 movel */
                       end.
                end.
                if vignora = yes then next.
                
                val_com = 0.

                /* antonio */
                for each bmovim where bmovim.etbcod = plani.etbcod and
                                      bmovim.placod = plani.placod and
                                      bmovim.movtdc = plani.movtdc and
                                      bmovim.movdat = plani.pladat
                                      no-lock:

                    find first produ where produ.procod = bmovim.procod
                                                        no-lock no-error.
                    if avail produ
                    then do:
                        if produ.procod = 88888
                        then vcat = 31.
                        else vcat = produ.catcod.
                    end.
                
                    find estoq where estoq.etbcod = plani.etbcod and
                                     estoq.procod = produ.procod
                                                no-lock no-error.
                    if not avail estoq
                    then next.
                    /*
                    run calculo.
                    vvalor = vvalor + val_com.
                    */
                end.

                /************* Calculo do acrescimo *****************/

                wacr = 0.
                if plani.crecod >= 1
                then do:
                    if plani.biss > (plani.platot - plani.vlserv)
                    then assign wacr = plani.biss - 
                                      (plani.platot - plani.vlserv).
                    else wacr = plani.acfprod.

                    if wacr < 0 or wacr = ?
                    then wacr = 0.

                    assign vvldesc  = vvldesc  + plani.descprod
                           vvlacre  = vvlacre  + wacr.
                end.
                /*
                else assign vvldesc  = vvldesc  + plani.descprod
                            vvlacre  = vvlacre  + plani.acfprod.
                  */
                if (vcatcod = 31 or
                    vcatcod = 35 or
                    vcatcod = 50)
                then do:
                    assign acum-m = acum-m + (plani.platot - /* plani.vlserv -*/
                                               vvldesc + vvlacre)
                     vmov   = vmov + /*vvalor.*/ (plani.platot - plani.vlserv 
                                    - vvldesc + vvlacre).
                    if plani.pladat = vdtimp
                    then dia-m = dia-m + /*vvalor.*/
                         (plani.platot - /*plani.vlserv -*/ vvldesc + vvlacre).
         
                    assign acum-m = acum-m - val_com.                          
                          
                end.
                else if vcatcod <> 88
                then do:
                     assign
                        acum-c = acum-c + (plani.platot /* - plani.vlserv */
                                    - vvldesc + vvlacre) .
                     if plani.pladat = vdtimp
                        then dia-c = dia-c + /*vvalor.*/
                        (plani.platot - /*plani.vlserv -*/ vvldesc + vvlacre).

                     assign acum-c = acum-c - val_com.
                     
                end.
                 /***
                if (vcat = 31 or
                    vcat = 35 or
                    vcat = 50)
                then do:

                    assign acum-m = acum-m + /*vvalor.*/
                    (plani.platot - plani.vlserv - vvldesc + vvlacre).
                    vmov   = vmov + /*vvalor.*/ (plani.platot - plani.vlserv -
                                           vvldesc + vvlacre).
                    if plani.pladat = vdtimp
                    then dia-m = dia-m + /*vvalor.*/
                                    (plani.platot - plani.vlserv -
                                                           vvldesc + vvlacre).

                end.
                else if vcat <> 88
                     then do:
                        assign
                               acum-c = acum-c +  /*vvalor.*/
                               (plani.platot /* - plani.vlserv */
                                       - vvldesc + vvlacre).

                        if plani.pladat = vdtimp
                        then dia-c = dia-c + /*vvalor.*/
                        (plani.platot - plani.vlserv - vvldesc + vvlacre).

                     end.
               **/
            end.
          end.
        end.
        
        create wplani.
        assign wplani.wetbcod = estab.etbcod
               wplani.wdia    = day(vdtimp)
               wplani.wmes    = month(vdtimp)
               wplani.wdia-c  = dia-c
               wplani.wdia-m  = dia-m.
        find first duplic where duplic.duppc = month(vdti) and
                                duplic.fatnum = estab.etbcod no-lock no-error.
        if avail duplic
        then assign wplani.wetbcon = duplic.dupval
                    wplani.wetbmov = duplic.dupjur.

        if duplic.dupval > 0 and
           duplic.dupjur = 0
        then wplani.wmeta = "C".
                   
        if duplic.dupval = 0 and
           duplic.dupjur > 0
        then wplani.wmeta = "M".


        if duplic.dupval > 0
        then assign wplani.wmeta-c  = ((duplic.dupval / duplic.dupdia) * vdia).

        wplani.wacum-c  = acum-c.


        if duplic.dupjur > 0
        then assign wplani.wmeta-m  = ((duplic.dupjur / duplic.dupdia) * vdia).

        wplani.wacum-m  = acum-m.

        tt-acum-c = tt-acum-c + acum-c.
        tt-acum-m = tt-acum-m + acum-m.
    end.
        
    /****************        
        a
        ssign vvldesc  = 0
               vvlacre  = 0
               vmov    = 0
               vcon    = 0
               acum-m   = 0
               acum-c   = 0
               mm-c     = 0
               mm-m     = 0
               aa-c     = 0
               aa-m     = 0.

    for each estab where (if par-etbcod > 0
                       then estab.etbcod = par-etbcod else true) /* AND
        estab.etbnom begins "DREBES-FIL" */ NO-LOCK:
     
        find first duplic where duplic.duppc = month(vdti) and
                                duplic.fatnum = estab.etbcod no-lock no-error.
        if not avail duplic
        then next.
        
        if estab.etbcod = 22
        then next.
        vdtimp = today.
        vfer = 0.

        find last bplani where bplani.etbcod = estab.etbcod and
                               bplani.movtdc = 5 and
                               month(bplani.pladat) <= month(vdti) no-lock
                                    use-index pladat no-error.

        if avail bplani
        then vdtultatu = bplani.pladat.
                              
        if vdtf > vdtultatu
        then vdtimp = vdtultatu.
        else vdtimp = vdtf.

        ii = 0.
        vfer = 0.
        vdia = 0.
        do vv = vdti to vdtf /*vdtimp*/:
           if weekday(vv) = 1
           then ii = ii + 1.
           find dtextra where dtextra.exdata  = vv no-error.
           if avail dtextra
           then vfer = vfer + 1.
           find dtesp where dtesp.datesp = vv and
                            dtesp.etbcod = estab.etbcod no-lock no-error.
           if avail dtesp
           then vfer = vfer + 1.
        end.
        
        vdia = int(day(vdtimp)) - ii - vfer.
        assign vmov    = 0
               vcon    = 0
               acum-c  = 0
               acum-m  = 0
               dia-m   = 0
               dia-c   = 0.

        do dt = vdti to vdtimp : 
          
          do vj = 1 to 2:

            if vj = 1 then vcatcod = 31 . /* Moveis */
            if vj = 2 then vcatcod = 41 . /*  Confeccoes */ 
          
            for each plani where plani.movtdc = 5             and
                                 plani.etbcod = estab.etbcod  and
                                 plani.pladat = dt no-lock:
                vvldesc = 0.
                vvlacre = 0.
                vvalor = 0.
                if vcatcod <> 31
                then vignora = no.
                else vignora = yes.
                if vcatcod > 0
                then
                for each movim where movim.etbcod = plani.etbcod and
                                     movim.placod = plani.placod and
                                     movim.movtdc = plani.movtdc and
                                     movim.movdat = plani.pladat
                                     no-lock:
                       find first produ where produ.procod = movim.procod
                            no-lock no-error.
                       if avail produ
                       then do:
                            if vcatcod <> 31 
                            then if produ.catcod <> vcatcod 
                                 then vignora = yes.
                            if vcatcod = 31 
                            then if produ.catcod = vcatcod or
                                    produ.procod = 88888
                                 then vignora = no. 
                       end.
                end.
                if vignora = yes then next.
                for each bmovim where bmovim.etbcod = plani.etbcod and
                                      bmovim.placod = plani.placod and
                                      bmovim.movtdc = plani.movtdc and
                                      bmovim.movdat = plani.pladat
                                      no-lock:

                    find first produ where produ.procod = bmovim.procod
                                                        no-lock no-error.
                    if avail produ
                    then do:
                        if produ.procod = 88888
                        then vcat = 31.
                        else vcat = produ.catcod.
                    end.
                    find estoq where estoq.etbcod = plani.etbcod and
                                     estoq.procod = produ.procod
                                                no-lock no-error.
                    if not avail estoq
                    then next.
                    /*
                    run calculo.
                    vvalor = vvalor + val_com.
                    */
                end.

                /************* Calculo do acrescimo *****************/

                wacr = 0.
                if plani.crecod >= 1
                then do:
                    if plani.biss > (plani.platot - plani.vlserv)
                    then assign wacr = plani.biss - 
                                      (plani.platot - plani.vlserv).
                    else wacr = plani.acfprod.

                    if wacr < 0 or wacr = ?
                    then wacr = 0.

                    assign vvldesc  = vvldesc  + plani.descprod
                           vvlacre  = vvlacre  + wacr.
                end.
                /*
                else assign vvldesc  = vvldesc  + plani.descprod
                            vvlacre  = vvlacre  + plani.acfprod.
                  */
                if (vcat = 31 or     
                    vcat = 35 or
                    vcat = 50)
                then do:
                    acum-m = acum-m + (plani.platot - 
                                               vvldesc + vvlacre).
                    if plani.pladat = vdtimp
                    then dia-m = dia-m + 
                          (plani.platot /*- plani.vlserv*/ - vvldesc + vvlacre).
                end.
                else if vcat <> 88
                then do:
                        acum-c = acum-c + (plani.platot 
                                    - vvldesc + vvlacre) .
                     if plani.pladat = vdtimp
                        then dia-c = dia-c + 
                        (plani.platot /*- plani.vlserv*/ - vvldesc + vvlacre).

                end.
            end.
          end.
        end.
        
        create wplani.
        assign wplani.wetbcod = estab.etbcod
               wplani.wdia    = day(vdtimp)
               wplani.wmes    = month(vdtimp)
               wplani.wdia-c  = dia-c
               wplani.wdia-m  = dia-m.
        find first duplic where duplic.duppc = month(vdti) and
                                duplic.fatnum = estab.etbcod no-lock no-error.
        if avail duplic
        then assign wplani.wetbcon = duplic.dupval
                    wplani.wetbmov = duplic.dupjur.

        if duplic.dupval > 0 and
           duplic.dupjur = 0
        then wplani.wmeta = "C".
                   
        if duplic.dupval = 0 and
           duplic.dupjur > 0
        then wplani.wmeta = "M".


        if duplic.dupval > 0
        then assign wplani.wmeta-c  = ((duplic.dupval / duplic.dupdia) * vdia).

        wplani.wacum-c  = acum-c.
 

        if duplic.dupjur > 0
        then assign wplani.wmeta-m  = ((duplic.dupjur / duplic.dupdia) * vdia).

        wplani.wacum-m  = acum-m.

        tt-acum-c = tt-acum-c + acum-c.
        tt-acum-m = tt-acum-m + acum-m.
    end.
    ****/
    
end procedure.

procedure calcv101:

def var vcatcod like produ.catcod.
def var v-data-aux as date.

IF VFABCOD = 0
THEN DO:
 find first tipmov where movtdc = 5 no-lock.
 
 for each estab where (if par-etbcod > 0
                       then estab.etbcod = par-etbcod else true) AND
        estab.etbnom begins "DREBES-FIL" NO-LOCK,
    each plani where plani.movtdc = tipmov.movtdc
                 and plani.etbcod = estab.etbcod
                 and plani.pladat = vdti
                 /*and plani.pladat <= vdtf*/ no-lock,
            each movim where movim.etbcod = plani.etbcod
                         and movim.placod = plani.placod
                         and movim.movtdc = plani.movtdc
                         and movim.movdat = plani.pladat no-lock,
            first produ where produ.procod = movim.procod no-lock.
            /*first sclase where sclase.clacod = produ.clacod no-lock,
            first clase where clase.clacod = sclase.clasup no-lock,
            first nivel2 where nivel2.clacod = clase.clasup no-lock,
            first nivel1 where nivel1.clacod = nivel2.clasup no-lock.
            */
            /**
            disp  "Processando " estab.etbnom no-label
                  plani.pladat format "99/99/9999" 
                /*skip
                 produ.procod no-label produ.pronom format "x(40)" no-label*/
                 with frame f-vvv1
                            side-labels width 80. pause 0.
            **/
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
            /*
            val_dev =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                        plani.vlserv.
            */
            if val_dev = ? then val_dev = 0.
            if (plani.platot - plani.vlserv - plani.descprod) < plani.biss
            then
                val_fin =  ((((movim.movpc * movim.movqtm) - val_dev - val_des)~ /
                            (plani.platot - plani.vlserv - plani.descprod))
                            * plani.biss) - ((movim.movpc * movim.movqtm) - 
                            val_dev - val_des).
            if val_fin = ? then val_fin = 0.
            
            val_com = (movim.movpc * movim.movqtm) - val_dev - val_des + 
                    val_acr +  val_fin. 

            if val_com = ? then val_com = 0.
             
           
            v-valor = val_com.

            if produ.catcod = 31 or
               produ.catcod = 35 or
               produ.catcod = 50
            then vcatcod = 31.
            else vcatcod = 41.   
            find first ttsetor where ttsetor.etbcod = estab.etbcod
                                 and ttsetor.setcod = vcatcod
                                 and ttsetor.data   = plani.pladat
                                 use-index setor no-error.
            if not avail ttsetor then do:
                create ttsetor.
                assign  ttsetor.setcod = vcatcod
                        ttsetor.etbcod = estab.etbcod
                        ttsetor.data = plani.pladat.
            end. 
            
            ttsetor.platot = ttsetor.platot + v-valor. 
            ttsetor.qtd = ttsetor.qtd + movim.movqtm.
            if plani.pladat = vdtf
            then ttsetor.pladia = ttsetor.pladia + v-valor.
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

      disp  v-data-aux format "99/99/9999"
            label "Processando"   /*skip
            produ.procod no-label produ.pronom format "x(40)" no-label*/
            
            with frame f-vvv2 width 80 side-labels. pause 0.
    
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






