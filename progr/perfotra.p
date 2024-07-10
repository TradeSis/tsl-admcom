/*************************INFORMA€OES DO PROGRAMA****************************** ***** Nome do Programa             : perfotra.p
*******************************************************************************/

{admcab.i new} 
{setbrw.i}

def var /*input parameter*/ p-pedtdc like pedid.pedtdc.
p-pedtdc = 6.

def var vdt-aux as date format "99/99/9999".

def var vi as int.
def var aux-i as int.
def var aux-etbcod like estab.etbcod.

def var vetbcodemit like estab.etbcod.
def var vetbcoddest like estab.etbcod.

def var vcont as int.
def var vdiastot as int.
def new shared var vdiasatu as int.
def buffer bestab for estab.
def var vforcod like forne.forcod. 
def var vdia as int.
def var vmes as int format "99".
def var vano as int format "9999".
def var vmesfim as int.
def var vanofim as int.
def var vdiafim as int.

def var v-totcom    as dec.
DEF VAR v-totperc   AS DEC.
def var v-totalzao  as dec.
def var vhora       as char.
def var vok as logical.
def var vquant like movim.movqtm.
def var flgetb      as log.
def var v-totaldia  as dec.
def var v-total     as dec.
def var v-totdia    as dec.
def var v-nome      like estab.etbnom.
def var d           as date.
def var i           as int.
def var v-qtd       as dec.
def var v-tot       as dec.
def var v-dif       as dec.
def var v-valor     as dec decimals 2.
def var vetbcod     like plani.etbcod           no-undo.
def var v-totger    as dec.

def new shared      var vdti        as date format "99/99/99" no-undo.
def new shared      var vdtf        as date format "99/99/99" no-undo.

def var p-vencod     like func.funcod.
def new shared var p-loja      like estab.etbcod.
def var p-setor     like setor.setcod.
def var p-grupo     like clase.clacod.
def var p-clase     like clase.clacod.
def var p-sclase    like clase.clacod.
def var v-titset    as char.
def var v-titgru    as char.
def var v-titcla    as char.
def var v-titscla   as char.
def var v-titvenpro as char.
def var v-titven    as char.
def var v-titpro    as char.
def var v-perdia    as dec label "% Dia".
def var v-perc      as dec label "% Acum".
def var v-percproj  as dec.
def var v-perdev    as dec label "% Dev" format ">9.99".

def buffer sclase   for clase.
def buffer grupo    for clase.
def buffer tsetor   for clase.

def temp-table tt-lj  like estab.
def temp-table tt-lje like estab.
def temp-table tt-ljd like estab.

def new shared temp-table ttloja
    field etbcod        like estab.etbcod
    field nome          like estab.etbnom 
    field itens         as int  
    field valor         as dec 
    index loja     is unique etbcod asc  .

def buffer bttloja for ttloja.

def new shared  temp-table ttcateg 
    field catcod    like categoria.catcod
    field etbcod    like estab.etbcod
    field comcod    like pedid.comcod
    field nome      like estab.etbnom 
    field itens     as int
    field valor     as dec
    index categ     etbcod comcod catcod 
    .

def new shared  temp-table ttsetor 
    field catcod    like ttcateg.catcod
    field setcod    like setor.setcod
    field etbcod    like estab.etbcod
    field comcod    like pedid.comcod
    field nome      like estab.etbnom 
    field itens     as int
    field valor     as dec
    index setor     etbcod comcod catcod setcod 
    .

def new shared temp-table ttgrupo
    field catcod    like ttcateg.catcod
    field grupo-clacod    like clase.clacod
    field setcod    like setor.setcod
    field etbcod    like estab.etbcod
    field comcod    like pedid.comcod
    field nome    like estab.etbnom 
    field itens    as int
    field valor    as dec
    index grupo     etbcod comcod catcod setcod grupo-clacod 
    .

def new shared temp-table ttclase
    field catcod    like ttcateg.catcod
    field setcod    like setor.setcod
    field etbcod    like plani.etbcod
    field grupo-clacod    like clase.clacod
    field clase-clacod    like clase.clasup    
    field comcod    like pedid.comcod
    field itens as int
    field valor as dec
    field nome      like estab.etbnom 
    index loja     is unique etbcod asc
                             comcod asc
                             catcod asc
                             setcod asc
                             grupo-clacod asc
                             clase-clacod asc
    .

def new shared temp-table ttsclase
    field catcod    like ttcateg.catcod
    field setcod    like setor.setcod
    field etbcod    like plani.etbcod
    field  grupo-clacod    like clase.clacod
    field  clase-clacod    like clase.clacod    
    field sclase-clacod    like clase.clacod    
    field comcod    like pedid.comcod
    field itens as int
    field valor as dec
    field nome      like estab.etbnom 
    index loja     is unique  etbcod       asc
                              comcod       asc
                              catcod      asc  
                              setcod       asc
                              grupo-clacod asc
                              clase-clacod asc
                             sclase-clacod asc
    .

def new shared temp-table ttprodu
    field catcod    like ttcateg.catcod
    field setcod    like setor.setcod
    field etbcod    like plani.etbcod
    field  grupo-clacod    like clase.clacod
    field  clase-clacod    like clase.clacod    
    field sclase-clacod    like clase.clacod    
    field procod           like produ.procod 
    field comcod    like pedid.comcod
    field itens    as int
    field valor as dec
    field nome     like estab.etbnom 
    field ocnum like movim.ocnum
    index nome nome
    index loja     is unique  etbcod       asc
                              comcod       asc
                              catcod asc
                              setcod       asc
                              grupo-clacod asc
                              clase-clacod asc
                             sclase-clacod asc
                              procod       asc 
    .

def new shared temp-table ttfabri
    field catcod    like ttcateg.catcod
    field setcod    like setor.setcod
    field etbcod    like plani.etbcod
    field  grupo-clacod    like clase.clacod
    field  clase-clacod    like clase.clacod    
    field sclase-clacod    like clase.clacod    
    field fabcod           like produ.fabcod 
    field comcod    like pedid.comcod
    field nome      like estab.etbnom 
    field itens as int
    field valor as dec
    index nome nome
    index loja     is unique  etbcod       asc
                              comcod       asc
                              catcod  asc  
                              setcod       asc
                              grupo-clacod asc
                              clase-clacod asc
                             sclase-clacod asc
                              fabcod       asc 
    .
    
def new shared temp-table ttdtmov
        field etbcod like estab.etbcod
        field dtmov as date
        field itens as int
        field valor as dec
        index dtmov dtmov desc
        .
def new shared temp-table ttprodt
        field etbcod like estab.etbcod
        field dtmov as date
        field procod like produ.procod
        field pronom like produ.pronom
        field itens as int
        field valor as dec
        field ocnum like movim.ocnum
        index pronom pronom
        .

def new shared temp-table ttfabdt
        field etbcod like estab.etbcod
        field dtmov as date
        field fabcod like fabri.fabcod
        field fabnom like fabri.fabnom
        field itens as int
        field valor as dec
        index fabnom fabnom
        .        

form
    ttloja.etbcod no-label format ">>>>>>>9"
    ttloja.nome  column-label "    LOJAS"  format "x(35)"
    ttloja.itens column-label "Itens"  format   ">>>>>>>9" 
    ttloja.valor column-label "Valor" format ">>>,>>>,>>9.99"
     with frame f-lojas
        width 80
        centered
        15 down 
        row 5
        no-box  
        overlay.
  
form
    vetbcodemit label "Estab. Emitente"
    estab.etbnom  no-label format "x(15)"
    vetbcoddest label "Estab. Destino"
    bestab.etbnom no-label format "x(15)" 
    vdti at 1 label "Periodo de" format "99/99/9999"
    vdtf      label "a" format "99/99/9999"
    with frame f-etb
        centered
        1 down side-labels 
        row 3 width 80
        no-box .

def var v-opcao as char format "x(18)" extent 4 initial
    ["  POR SETOR","  POR PRODUTO"," POR FABRICANTE"," PEDIDOS PENDENTES"].
    
def var vindex as int.
form
    v-opcao[1]  format "x(20)"
    v-opcao[2]  format "x(20)"
    with frame f-opcao
        centered down no-labels overlay row 15 color normal
        1 column WIDTH 80. 

form "Processando.....>>> " 
    bestab.etbcod vdt-aux format "99/99/9999" plani.numero
    with frame f-1 1 down centered row 10 no-label no-box
    overlay.
    
do on error undo:

    update vetbcodemit with frame f-etb.
    if vetbcodemit > 0
    then do:
        find estab where estab.etbcod = vetbcodemit
                    no-lock no-error.
        if not avail estab
        then do:
            bell.
            message color red/with
            "Estab. nao cadastrado" view-as alert-box
            title " Atencao! " .
            undo.
        end.
        disp estab.etbnom with frame f-etb.
        create tt-lje.
        buffer-copy estab to tt-lje.
    end.
    else do:
        for each estab no-lock.
            create tt-lje.
            buffer-copy estab to tt-lje.
        end.
    end.
    do on error undo:
        update vetbcoddest with frame f-etb.
        if vetbcoddest > 0
        then do:
            find bestab where bestab.etbcod = vetbcoddest
                    no-lock no-error.
            if not avail bestab
            then do:
                bell.
                message color red/with
                "Estab. nao cadastrado" view-as alert-box
                title " Atencao! " .
                undo.
            end.
            disp bestab.etbnom with frame f-etb.
            create tt-ljd.
            buffer-copy bestab to tt-ljd.
        end.
        else do:
            for each bestab no-lock:
                create tt-ljd.
                buffer-copy bestab to tt-ljd.
            end.
        end.
    end.
    update vdti vdtf with frame f-etb.
end.         
    
run propedid.
repeat:                         
    hide frame f-lojas no-pause.
    clear frame f-mat all.
    hide frame f-mat.
    hide frame f-1 no-pause.
    
    hide frame f-mostr.
    l1: repeat :
        
        disp with frame f-etb color message.    
        pause 0.
        assign  a-seeid = -1 a-recid = -1 
                a-seerec = ? 
                v-totdia = 0 v-totger = 0.
        
        {sklcls.i
            &help = "ENTER=Seleciona F1=Sair F4=Retorna"
            &File   = ttloja
            &CField = ttloja.nome
            &Ofield = " ttloja.etbcod ttloja.nome ttloja.itens 
                                   ttloja.valor
                    "
            &Where = " true use-index loja "
            &AftSelect1 = " 
                        if keyfunction(lastkey) <> ""RETURN"" and
                           keyfunction(lastkey) <> ""GO""
                        then next keys-loop.   
                        else do:
                        p-loja = ttloja.etbcod. 
                        leave keys-loop. 
                        end. "
            &naoexiste1 = " bell.
                    message color red/with
                        ""Nenhum registro encontrado""
                        view-as alert-box title "" Atencao! "".
                    leave l1.
                        "
            &Form = " frame f-lojas " 
        }.
        
        if keyfunction(lastkey) = "END-ERROR"
        then leave l1.
        if keyfunction(lastkey) = "GO"
        then return.
        vindex = 0.
        sresp = no.

        disp v-opcao with frame f-esc 1 down row 18 side-label
                no-label centered overlay.
        choose field v-opcao with frame f-esc.
        vindex = frame-index + 1.        
        
        hide frame f-esc no-pause.
        
        clear frame f-lojas all.
        display 
                ttloja.etbcod
                ttloja.nome 
                ttloja.itens
                ttloja.valor
                with frame f-lojas.

        pause 0.
        if vindex = 5
        then do:
            run pedidos-pendentes.
        end.
        else do:
            run perfot01.p (ttloja.etbcod, vindex, p-pedtdc).
        end.
        if keyfunction(lastkey) = "GO"
        then do:
            hide frame f-lojas no-pause.
            hide frame f-etb no-pause.
            return.
        end.
    end. 
    hide frame f-1 no-pause.  
    leave.     
end.    

procedure propedid:

    for each tt-ljd:
        find estab where estab.etbcod = tt-ljd.etbcod no-lock no-error.
        if not avail estab then next.

        aux-etbcod = estab.etbcod.
        disp estab.etbcod with frame f-1.
        pause 0.
        do vdt-aux = vdti to vdtf:
            disp vdt-aux with frame f-1.
            pause 0.
            for each plani where plani.movtdc = p-pedtdc and
                                 plani.desti  = tt-ljd.etbcod and
                                 plani.pladat = vdt-aux no-lock:
                if plani.notsit then next.                
                disp plani.numero with frame f-1.
                pause 0.
                find first tt-lje where
                           tt-lje.etbcod = plani.emite no-error.
                if not avail tt-lje
                then next.
                            
                find first ttloja where 
                           ttloja.etbcod = plani.desti no-error.
                if not avail ttloja
                then do:
                    create ttloja.
                    assign
                        ttloja.etbcod = plani.desti
                        ttloja.nome = tt-ljd.etbnom.
                end.
                find first bttloja where 
                           bttloja.etbcod = 0 no-error.
                if not avail bttloja
                then do:
                    create bttloja.
                    assign
                        bttloja.etbcod = 0
                        bttloja.nome = "GERAL".
                end.
                assign
                    ttloja.valor = ttloja.valor + plani.platot        
                    bttloja.valor = bttloja.valor + plani.platot.
                for each movim where
                        movim.etbcod = plani.etbcod and
                        movim.placod = plani.placod
                        no-lock:
                    assign
                        ttloja.itens = ttloja.itens + movim.movqtm
                        bttloja.itens = bttloja.itens + movim.movqtm.
                    run criatt(aux-etbcod).
                    run criatt(0).
                end.
            end.            
        end.
    end.

end procedure.

procedure criatt.
    def input parameter aux-etbcod like estab.etbcod.
    def var p-comcod as int.
    find produ where produ.procod = movim.procod no-lock no-error.
    if not avail produ then next.   
    find sclase where sclase.clacod = produ.clacod no-lock no-error.
    if not avail sclase
    then next.
   
    find clase where clase.clacod = sclase.clasup  no-lock.
    find grupo where grupo.clacod = clase.clasup   no-lock.
    find tsetor where tsetor.clacod = grupo.clasup no-lock.
    find categoria where categoria.catcod = produ.catcod no-lock.
   
     find fabri of produ no-lock.

    find first ttcateg where 
                    ttcateg.etbcod = aux-etbcod and
                    ttcateg.comcod = p-comcod and
                    ttcateg.catcod = categoria.catcod
                no-error.
    if not avail ttcateg
    then do:
        create ttcateg.
        assign 
            ttcateg.etbcod = aux-etbcod
            ttcateg.comcod = p-comcod
            ttcateg.catcod = categoria.catcod 
            ttcateg.nome = categoria.catnom 
            .
    end. 
    assign
        ttcateg.itens = ttcateg.itens + movim.movqtm
        ttcateg.valor = ttcateg.valor + (movim.movqtm * movim.movpc).
    find first ttsetor where 
                    ttsetor.etbcod = aux-etbcod and
                    ttsetor.comcod = p-comcod and
                    ttsetor.catcod = categoria.catcod  and
                    ttsetor.setcod = tsetor.clacod
                no-error.
    if not avail ttsetor
    then do:
        create ttsetor.
        assign 
            ttsetor.etbcod = aux-etbcod
            ttsetor.comcod = p-comcod
            ttsetor.catcod = categoria.catcod 
            ttsetor.setcod = tsetor.clacod
            ttsetor.nome   = tsetor.clanom 
            .
    end. 
    assign
        ttsetor.itens = ttsetor.itens + movim.movqtm
        ttsetor.valor = ttsetor.valor + (movim.movqtm * movim.movpc).
    find first ttgrupo where 
                    ttgrupo.etbcod = aux-etbcod and
                    ttgrupo.comcod = p-comcod and
                    ttgrupo.catcod = categoria.catcod and
                    ttgrupo.setcod = tsetor.clacod and
                    ttgrupo.grupo-clacod = grupo.clacod
                no-error.
    if not avail ttgrupo
    then do:
        create ttgrupo.
        assign 
            ttgrupo.etbcod = aux-etbcod
            ttgrupo.comcod = p-comcod
            ttgrupo.catcod = categoria.catcod
            ttgrupo.setcod = tsetor.clacod
            ttgrupo.grupo-clacod = grupo.clacod
            ttgrupo.nome   = grupo.clanom.
    end. 
    assign
        ttgrupo.itens = ttgrupo.itens + movim.movqtm
        ttgrupo.valor = ttgrupo.valor + (movim.movqtm * movim.movpc).

    find first ttclase where 
                    ttclase.etbcod       = aux-etbcod and
                    ttclase.comcod       = p-comcod and
                    ttclase.catcod       = categoria.catcod and
                    ttclase.setcod       = tsetor.clacod and
                    ttclase.grupo-clacod = grupo.clacod and
                    ttclase.clase-clacod = clase.clacod
                no-error.
    if not avail ttclase
    then do:
          create ttclase.
          assign 
              ttclase.etbcod          = aux-etbcod
              ttclase.comcod     = p-comcod
              ttclase.catcod          = categoria.catcod 
              ttclase.setcod          = tsetor.clacod 
              ttclase.grupo-clacod    = grupo.clacod
              ttclase.clase-clacod    = clase.clacod
              ttclase.nome            = clase.clanom.
    end. 
    assign
        ttclase.itens = ttclase.itens + movim.movqtm
        ttclase.valor = ttclase.valor + (movim.movqtm * movim.movpc).
 
    find first ttsclase where 
                    ttsclase.etbcod        = aux-etbcod and
                    ttsclase.comcod        = p-comcod and
                    ttsclase.catcod        = categoria.catcod and
                    ttsclase.setcod        = tsetor.clacod and
                    ttsclase.grupo-clacod  = grupo.clacod and
                    ttsclase.clase-clacod  = clase.clacod and
                    ttsclase.sclase-clacod = sclase.clacod
                                    no-error.
    if not avail ttsclase
    then do:
        create ttsclase.
        assign 
            ttsclase.etbcod          = aux-etbcod
            ttsclase.comcod = p-comcod
            ttsclase.catcod          = categoria.catcod
            ttsclase.setcod          = tsetor.clacod
            ttsclase.grupo-clacod    = grupo.clacod
            ttsclase.clase-clacod    = clase.clacod
            ttsclase.sclase-clacod   = sclase.clacod
            ttsclase.nome            = sclase.clanom.
    end. 
    assign
        ttsclase.itens = ttsclase.itens + movim.movqtm
        ttsclase.valor = ttsclase.valor + (movim.movqtm * movim.movpc).
 
    find first ttprodu where 
                    ttprodu.etbcod        = aux-etbcod and
                    ttprodu.comcod        = p-comcod and 
                    ttprodu.catcod        = categoria.catcod and   
                    ttprodu.setcod        = tsetor.clacod and
                    ttprodu.grupo-clacod  = grupo.clacod and
                    ttprodu.clase-clacod  = clase.clacod and
                    ttprodu.sclase-clacod = sclase.clacod and
                    ttprodu.procod        = produ.procod  
                                    no-error.
    if not avail ttprodu
    then do:
        create ttprodu.
        assign 
            ttprodu.etbcod          = aux-etbcod
            ttprodu.comcod = p-comcod
            ttprodu.catcod          = categoria.catcod
            ttprodu.setcod          = tsetor.clacod 
            ttprodu.grupo-clacod    = grupo.clacod
            ttprodu.clase-clacod    = clase.clacod
            ttprodu.sclase-clacod   = sclase.clacod
            ttprodu.procod          = produ.procod
            ttprodu.nome            = produ.pronom.
    end.  
    assign
        ttprodu.itens = ttprodu.itens + movim.movqtm
        ttprodu.valor = ttprodu.valor + (movim.movqtm * movim.movpc)
        ttprodu.ocnum[1] = movim.ocnum[1].
 
    find first ttfabri where 
                    ttfabri.etbcod        = aux-etbcod and
                    ttfabri.comcod  = p-comcod and
                    ttfabri.catcod        = categoria.catcod and
                    ttfabri.setcod        = tsetor.clacod  and
                    ttfabri.grupo-clacod  = grupo.clacod and
                    ttfabri.clase-clacod  = clase.clacod and
                    ttfabri.sclase-clacod = sclase.clacod and
                    ttfabri.fabcod        = produ.fabcod  
                                    no-error.
   if not avail ttfabri
   then do:
       create ttfabri.
       assign 
           ttfabri.etbcod          = aux-etbcod
           ttfabri.comcod = p-comcod
           ttfabri.catcod          = categoria.catcod
           ttfabri.setcod          = tsetor.clacod 
           ttfabri.grupo-clacod    = grupo.clacod
           ttfabri.clase-clacod    = clase.clacod
           ttfabri.sclase-clacod   = sclase.clacod
           ttfabri.fabcod          = produ.fabcod
           ttfabri.nome            = fabri.fabnom.
    end. 
    assign
        ttfabri.itens = ttfabri.itens + movim.movqtm
        ttfabri.valor = ttfabri.valor + (movim.movqtm * movim.movpc).
    find first ttdtmov where
               ttdtmov.etbcod = aux-etbcod and 
               ttdtmov.dtmov = movim.movdat no-error.
    if not avail ttdtmov
    then do:
        create ttdtmov.
        ttdtmov.dtmov = movim.movdat.
        ttdtmov.etbcod = aux-etbcod.
    end.
    assign            
        ttdtmov.itens = ttdtmov.itens + movim.movqtm
        ttdtmov.valor = ttdtmov.valor + (movim.movpc * movim.movqtm).
    find first ttprodt where
               ttprodt.etbcod = aux-etbcod and 
               ttprodt.dtmov = movim.movdat and
               ttprodt.procod = movim.procod  no-error.
    if not avail ttprodt
    then do:
        create ttprodt.
        ttprodt.etbcod = aux-etbcod.
        ttprodt.dtmov = movim.movdat.
        ttprodt.procod = movim.procod.
        ttprodt.pronom = produ.pronom.
    end.
    assign            
        ttprodt.itens = ttprodt.itens + movim.movqtm
        ttprodt.valor = ttprodt.valor + (movim.movpc * movim.movqtm)
        ttprodt.ocnum[1] = movim.ocnum[1].
    find first ttfabdt where
               ttfabdt.etbcod = aux-etbcod and 
               ttfabdt.dtmov = movim.movdat and
               ttfabdt.fabcod = fabri.fabcod  no-error.
    if not avail ttfabdt
    then do:
        create ttfabdt.
        ttfabdt.etbcod = aux-etbcod.
        ttfabdt.dtmov = movim.movdat.
        ttfabdt.fabcod = fabri.fabcod .
        ttfabdt.fabnom = fabri.fabnom.
    end.
    assign            
        ttfabdt.itens = ttfabdt.itens + movim.movqtm
        ttfabdt.valor = ttfabdt.valor + (movim.movpc * movim.movqtm).
    


end procedure.


def temp-table tt-pedid like pedid.
def temp-table tt-liped like liped.

procedure pedidos-pendentes:
    def var vdti as date.
    def var vdtf as date.
    def var vclacod like clase.clacod.
    
    update vdti format "99/99/9999" label "Periodo de"
           vdtf format "99/99/9999" label "ate"
           with frame fdt 1 down width 80 side-label.
    update vclacod at 1 with frame fdt.
    
    find clase where
         clase.clacod = vclacod no-lock no-error.
    if not avail clase
    then do:
        bell.
        message color red/with
            "Classe nao cadastrada."  view-as alert-box.
       undo.
    end.        
        
    disp clase.clanom no-label with frame fdt.

    for each tt-pedid: delete tt-pedid. end.
    for each tt-liped: delete tt-liped. end.  
    for each pedid  where 
            pedid.etbcod = 996 and
                   pedid.clfcod = 5027 and     
                   pedid.peddti >= vdti and
                   pedid.peddti <= vdtf and
                   pedid.sitped <> "F" no-lock,
        each liped of pedid where liped.lipsit <> "F" no-lock,           
        first produ of liped where
                (if vclacod > 0 then
                    produ.clacod = vclacod else true) no-lock:

        create tt-liped.
        buffer-copy liped to tt-liped.
        find first tt-pedid where
                   tt-pedid.pednum = pedid.pednum no-error.
        if not avail tt-pedid
        then do:           
            create tt-pedid.
            buffer-copy pedid to tt-pedid.
        end.
    end.
        
    {setbrw.i}
    assign
        a-seeid = -1
        a-recid = -1
        a-seerec = ?
        .
    {sklcls.i 
        &help   = "ENTER=Produtos  F4=Retorna"
        &File   = tt-pedid
        &CField = tt-pedid.pednum 
        &noncharacter = /*
        &ofield = " tt-pedid.peddat
                    tt-pedid.sitped
                    tt-pedid.peddti
                    tt-pedid.peddtf
                    tt-pedid.clfcod
                    forne.fornom  format ""x(15)""
                    "
        &Where = " true "
        &naoexiste1 = " message color red/with
                    ""Nenhum registro encontrado."" view-as alert-box.
                    leave keys-loop.
                    "
        &aftfnd1 = " find forne where
                        forne.forcod = tt-pedid.clfcod no-lock no-error.
                        "
        &aftselect1 = "
            if keyfunction(lastkey) = ""RETURN""
            then do:
                for each tt-liped where 
                         tt-liped.pednum = tt-pedid.pednum no-lock:
                    find produ where produ.procod = tt-liped.procod no-lock.
                    
                    disp tt-liped.procod 
                         produ.pronom
                         tt-liped.lipsit
                         tt-liped.lipqtd
                         with frame f-liped down overlay
                         title "" Produtos do pedido "" +
                         string(tt-pedid.pednum).         
                end.
                pause.
                next keys-loop.
            end.
            "
        &LockType = " no-lock " 
        &Form = " frame f-pedid down " 
     }
end procedure.





