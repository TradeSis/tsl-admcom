/*************************INFORMA€OES DO PROGRAMA******************************
***** Nome do Programa             : perfop01.p
******************************************************************************/
{admcab.i}.
{setbrw.i}
def var vdat-aux as date format "99/99/9999".
def var vheader as char format "x(20)".
def var aux-i as int.
def var aux-etbcod like estab.etbcod.
def buffer bestab for estab.
def var vacfprod like plani.acfprod.
def var v-percproj  as dec.
def var v-totcom    as dec.
def var v-ttmet     as dec /*like metven.vlmeta*/.
def var v-totalzao  as dec.
def var vhora       as char.
def var vok         as logical.
def var vquant      like movim.movqtm.
def var flgetb      as log.
def var vmovtdc     like tipmov.movtdc.
def var v-totaldia  as dec.
def var v-total     as dec.
def var v-totdia    as dec.
def var v-nome      like estab.etbnom.
def var d           as date.
def var i           as int.
def var v-qtd       as dec.
def var v-tot       as dec.
def var v-movtdc    like plani.movtdc.
def var v-dif       as dec.
def var v-valor     as dec decimals 2.
def var v-totger    as dec.
def shared      var vdti        as date format "99/99/9999" no-undo.
def shared      var vdtf        as date format "99/99/9999" no-undo.
def shared      var vdiasatu    as int.
def var vdt-aux as date.
def var p-vende     like func.funcod.
def input parameter par-etbcod      like estab.etbcod.
def input parameter par-vencod      like func.funcod.
def input parameter p-pedtdc        like pedid.pedtdc.
def var vetbcod like estab.etbcod.
if par-etbcod = 999
then vetbcod = 0. else vetbcod =  par-etbcod.
def var p-comcod    like func.funcod.
def var p-catcod    like categ.catcod.
def var p-setor     like setor.setcod.
def var p-grupo     like clase.clacod.
def var p-clase     like clase.clacod.
def var p-sclase    like clase.clacod.
def var p-procod as int.
def var v-titset    as char.
def var v-titgru    as char.
def var v-titcla    as char.
def var v-titscla   as char.
def var v-titvenpro as char.
def var v-titven    as char.
def var v-titpro    as char format "x(78)".
def var v-perdia    as dec label "% Dia".
def var v-perc      as dec label "% Acum".
def var v-perdev    as dec label "% Dev" format ">9.99".
def var vnomabr     like produ.pronom format "x(20)" /*like produ.nomabr. */.

def var vfapro as char extent 2  format "x(15)"
                init["  PRODUTO  "," FABRICANTE "].

def buffer sclase   for clase.
def buffer grupo    for clase.

def shared  temp-table ttcateg 
    field catcod    like categoria.catcod
    field etbcod    like estab.etbcod
    field comcod    like pedid.comcod
    field nome      like estab.etbnom 
    field itens     as int
    field valor     as dec
    index categ     etbcod comcod catcod 
    .

def shared  temp-table ttsetor 
    field catcod    like ttcateg.catcod
    field setcod    like setor.setcod
    field etbcod    like estab.etbcod
    field comcod    like pedid.comcod
    field nome      like estab.etbnom 
    field itens     as int
    field valor     as dec
    index setor     etbcod comcod catcod setcod 
    .

def shared temp-table ttgrupo
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

def shared temp-table ttclase
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

def shared temp-table ttsclase
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
                              catcod        asc
                              setcod       asc
                              grupo-clacod asc
                              clase-clacod asc
                             sclase-clacod asc
    .

def shared temp-table ttprodu
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
    index nome  nome 
    index loja     is unique  etbcod       asc
                              comcod       asc
                              catcod        asc
                              setcod       asc
                              grupo-clacod asc
                              clase-clacod asc
                             sclase-clacod asc
                              procod       asc 
    .

def temp-table ttproduaux like ttprodu.

def shared temp-table ttfabri
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
                              catcod       asc
                              setcod       asc
                              grupo-clacod asc
                              clase-clacod asc
                             sclase-clacod asc
                              fabcod       asc 
    .

def temp-table ttfabriaux like ttfabri.

def shared temp-table ttdtmov
        field etbcod like estab.etbcod
        field dtmov as date
        field itens as int
        field valor as dec
        index dtmov dtmov desc
        .
def shared temp-table ttprodt
        field etbcod like estab.etbcod
        field dtmov as date
        field procod like produ.procod
        field pronom like produ.pronom
        field itens as int
        field valor as dec
        field ocnum like movim.ocnum
        index pronom pronom
        .

def shared temp-table ttfabdt
        field etbcod like estab.etbcod
        field dtmov as date
        field fabcod like fabri.fabcod
        field fabnom like fabri.fabnom
        field itens as int
        field valor as dec
        index fabnom fabnom
        . 


def var v-title as char.

form
    ttcateg.catcod no-label format ">>>>>>>9"
    ttcateg.nome  column-label "Categoria"  format "x(35)"
    ttcateg.itens    column-label "Itens"            format ">>>>>>>9" 
    ttcateg.valor    column-label "Valor"     format ">>>,>>>,>>9.99"
    with frame f-categ
        width 80
        centered 
        10 down 
        row 6
        overlay
        title " " + v-title + " ".

/*
form header 
        "---------<SETORES>" + fill("-",73) format "x(80)"
     with frame f-setor no-underline.
*/ 
form
    ttsetor.setcod no-label   format ">>>>>>>9"
    ttsetor.nome  column-label "Setor"  format "x(35)"
    ttsetor.itens    column-label "Itens"            format ">>>>>>>9" 
    ttsetor.valor    column-label "Valor"     format ">>>,>>>,>>9.99"
    with frame f-setor
        width 80
        centered 
        10 down 
        row 6
        overlay
        title " " + v-title + " ".
/*                
form header 
        "---------<GRUPOS>" + fill("-",74) format "x(80)"
     with frame f-grupo no-underline OVERLAY. 
*/
form
    ttgrupo.grupo-clacod no-label   format ">>>>>>>9"
    ttgrupo.nome  column-label "Grupo"  format "x(35)"
    ttgrupo.itens    column-label "Itens"            format ">>>>>>>9" 
    ttgrupo.valor    column-label "Valor"     format ">>>,>>>,>>9.99"
    with frame f-grupo
        width 80
        centered 
        10 down 
        row 6
        overlay title " " + v-title + " ".
/*
form header
        "---------<CLASSES>" + fill("-",73) format "x(80)"
     with frame f-clase no-underline. 
*/
form
    ttclase.clase-clacod no-label     format ">>>>>>>9"
    ttclase.nome  column-label "Classe"  format "x(35)"
    ttclase.itens    column-label "Itens"            format ">>>>>>>9" 
    ttclase.valor    column-label "Valor"     format ">>>,>>>,>>9.99"
    with frame f-clase
        width 80
        centered 
        10 down 
        row  6
        overlay title " " + v-title + " ".
/*
form header 
        "---------<SUB-CLASSES" + fill("-",69) format "x(80)"
     with frame f-sclase no-underline OVERLAY. 
*/
form
    ttsclase.sclase-clacod no-label      format ">>>>>>>9"
    ttsclase.nome  column-label "Sub-Classe"  format "x(35)"
    ttsclase.itens    column-label "Itens"            format ">>>>>>>9" 
    ttsclase.valor    column-label "Valor"     format ">>>,>>>,>>9.99"
    with frame f-sclase
        width 80
        centered 
        10 down 
        row  6
        overlay title " " + v-title + " ".
/*
form header 
        "---------<PRODUTOS>" + fill("-",69) format "x(80)"
     with frame f-produ no-underline OVERLAY. 
*/
form
    ttprodu.procod no-label format ">>>>>>>9"
    ttprodu.nome  column-label "Produto"  format "x(35)"
    ttprodu.itens    column-label "Itens"            format ">>>>>>>9" 
    ttprodu.valor    column-label "Valor"     format ">>>,>>>,>>9.99"
    ttprodu.ocnum[1] column-label "Pedido"
    with frame f-produ
        width 80
        centered 
        10 down 
        row 6
        overlay title " " + v-title + " ".

form
    ttproduaux.procod no-label format ">>>>>>>9"
    ttproduaux.nome  column-label "Produto"  format "x(35)"
    ttproduaux.itens    column-label "Itens"            format ">>>>>>>9" 
    ttproduaux.valor    column-label "Valor"     format ">>>,>>>,>>9.99"
    ttproduaux.ocnum[1] column-label "Pedido"
    with frame f-produ1
        width 80
        centered 
        10 down 
        row 6
        overlay title " " + v-title + " ".

/*
form header 
        "---------<FABRICANTES>" + fill("-",69)  format "x(80)"
     with frame f-fabri no-underline OVERLAY. 
*/
form
    ttfabri.fabcod no-label format ">>>>>>>9"
    ttfabri.nome  column-label "Fabricante"  format "x(35)"
    ttfabri.itens    column-label "Itens"            format ">>>>>>>9" 
    ttfabri.valor    column-label "Valor"     format ">>>,>>>,>>9.99"
    with frame f-fabri
        width 80
        centered 
        10 down 
        row 6
        overlay title " " + v-title + " " .

form
    ttfabriaux.fabcod no-label format ">>>>>>>9"
    ttfabriaux.nome  column-label "Fabricante"  format "x(35)"
    ttfabriaux.itens    column-label "Itens"            format ">>>>>>>9" 
    ttfabriaux.valor    column-label "Valor"     format ">>>,>>>,>>9.99"
    with frame f-fabri1
        width 80
        centered 
        10 down 
        row 6
        overlay title " " + v-title + " " .

form ttdtmov.dtmov   at 12  no-label format "99/99/9999"
     "                      "
     ttdtmov.itens    column-label "Itens"            format ">>>>>>>9" 
     ttdtmov.valor    column-label "Valor"     format ">>>,>>>,>>9.99"
     with frame f-dtmov
        width 80
        centered 
        10 down 
        row 6
        overlay title " " + v-title + " " .

form ttprodt.procod format ">>>>>>>9"  no-label
     ttprodt.pronom format "x(35)" column-label "Produtos"
     ttprodt.itens    column-label "Itens"            format ">>>>>>>9" 
     ttprodt.valor    column-label "Valor"     format ">>>,>>>,>>9.99"
     ttprodt.ocnum[1] column-label "Pedido"
     with frame f-prodt
        width 80
        centered 
        10 down 
        row 6
        overlay title " " + v-title + " " .


form "Processando.....>>> " 
    bestab.etbcod vdt-aux format "99/99/9999" pedid.pednum
    with frame f-1 1 down centered row 10 no-label no-box
    overlay.

hide frame f-1 no-pause.
form    "                       T O T A I S "  
        t-itens as int    format ">>>>>>>9"    to 54
        t-valor as dec       format ">>>,>>>,>>9.99"
        with frame f-tot no-label row 20 no-box width 80.

l0: repeat :
    if par-etbcod <> 0
    then find first estab where estab.etbcod = par-etbcod no-lock.
    if par-vencod = 2
    then     
    l1: repeat:
        assign 
            a-seeid = -1 a-recid = -1 a-seerec = ? 
            t-itens = 0 t-valor = 0
            v-title  = " CATEGORIAS " +  " DO ESTAB. " + 
                if par-etbcod <> 999
                then string(estab.etbnom) else "EMPRESA"
                .

        for each ttcateg where 
                 ttcateg.etbcod = par-etbcod and
                 ttcateg.comcod = p-comcod: 
            t-itens = t-itens + ttcateg.itens.
            t-valor = t-valor + ttcateg.valor.
        end.
        disp t-itens t-valor with frame f-tot. 
        {sklcls.i 
        &help   = "ENTER=Seleciona F1=Sair F4=Retorna"
        &File   = ttcateg 
        &CField = ttcateg.nome 
        &ofield = " ttcateg.catcod
                    ttcateg.nome 
                    ttcateg.itens 
                    ttcateg.valor
                    "
        &Where = " ttcateg.etbcod = par-etbcod and
                   ttcateg.comcod = p-comcod " 
        &AftSelect1 = " 
                       if keyfunction(lastkey) <> ""RETURN"" and
                          keyfunction(lastkey) <> ""GO""
                       then next keys-loop.
                       else do:              
                       p-catcod = ttcateg.catcod.
                        
                       clear frame f-setor all no-pause.
                       pause 0.
                       run pro-op ( ""p-catcod"" ) .
                       if keyfunction(lastkey) = ""END-ERROR""
                       then next l0.  
                       leave keys-loop. 
                       end. "
        &LockType = " use-index categ " 
        &Form = " frame f-categ " 
         }
        if keyfunction(lastkey) = "END-ERROR" or
           keyfunction(lastkey) = "GO"
        then do: 
            hide frame f-categ no-pause. 
            leave l0.
        end.
        l15: repeat:

            assign 
                a-seeid = -1 a-recid = -1 a-seerec = ? 
                t-itens = 0 t-valor = 0
                v-title  = " SETORES DA CATEGORIA " + 
                               string(TTCATEG.nome)  + " D0 ESTAB " + 
                if par-etbcod <> 999
                then string(estab.etbnom) else "EMPRESA"
                 .

            for each ttsetor where 
                 ttsetor.etbcod = par-etbcod and
                 ttsetor.comcod = p-comcod and
                 ttsetor.catcod = p-catcod: 
                t-itens = t-itens + ttsetor.itens.
                t-valor = t-valor + ttsetor.valor.
            end.
            disp t-itens t-valor with frame f-tot. 
    
        {sklcls.i 
        &help   = "ENTER=Seleciona F1=Sair F4=Retorna"
        &File   = ttsetor 
        &CField = ttsetor.nome 
        &ofield = " ttsetor.setcod
                    ttsetor.nome 
                    ttsetor.itens 
                    ttsetor.valor
                    "
        &Where = " ttsetor.etbcod = par-etbcod and
                   ttsetor.comcod = p-comcod and
                   ttsetor.catcod = p-catcod " 
        &AftSelect1 = " 
                       if keyfunction(lastkey) <> ""RETURN"" and
                          keyfunction(lastkey) <> ""GO""
                       then next keys-loop.
                       else do:              
                       p-setor = ttsetor.setcod. 
                       clear frame f-setor all no-pause.
                       pause 0.
                       run pro-op ( ""p-setor"" ) .
                       if keyfunction(lastkey) = ""END-ERROR""
                       then next l0. 
                       leave keys-loop. 
                       end. "
        &LockType = " use-index setor " 
        &Form = " frame f-setor " 
         }
        
    if keyfunction(lastkey) = "END-ERROR"
    then do: 
        hide frame f-setor no-pause.
        leave l15 .
    end.                   
    if keyfunction(lastkey) = "GO"
    then do:
        hide frame f-setor no-pause.
        leave l0.
    end.     
    
    l2: repeat :
                    
        assign 
                a-seeid = -1 a-recid = -1 a-seerec = ? 
                t-itens = 0 t-valor = 0
                v-title  = " GRUPOS DO SETOR " + 
                               string(ttsetor.nome)  + " DO ESTAB. " + 
                if par-etbcod <> 999
                then string(estab.etbnom) else "EMPRESA"
                .

        for each ttgrupo where 
                 ttgrupo.etbcod = par-etbcod and
                 ttgrupo.comcod = p-comcod and
                 ttgrupo.catcod = p-catcod and
                 ttgrupo.setcod = p-setor: 
                t-itens = t-itens + ttgrupo.itens.
                t-valor = t-valor + ttgrupo.valor.
        end.
        disp t-itens t-valor with frame f-tot. 
                    
        {sklcls.i 
            &help = "ENTER=Seleciona F1=Sair F4=Retorna"
            &File   = ttgrupo 
            &CField = ttgrupo.nome 
            &ofield = " 
                       ttgrupo.grupo-clacod
                       ttgrupo.nome 
                       ttgrupo.itens 
                       ttgrupo.valor
                        "
            &Where = " ttgrupo.etbcod = par-etbcod and
                       ttgrupo.comcod = p-comcod and 
                       ttgrupo.catcod = p-catcod and
                       ttgrupo.setcod = p-setor " 
            &AftSelect1 = " 
                    if keyfunction(lastkey) <> ""RETURN"" and
                       keyfunction(lastkey) <> ""GO""
                    then next keys-loop.
                    else do:                 
                        p-grupo = ttgrupo.grupo-clacod. 
                        clear frame f-grupo all no-pause.
                        pause 0.
                        run pro-op ( ""p-grupo"" ) .
                        if keyfunction(lastkey) = ""END-ERROR""
                        then next l0. 
                        leave keys-loop.
                         end. "
            &LockType = " use-index grupo " 
            &Form = " frame f-grupo " 
            }. 
                     
        if keyfunction(lastkey) = "END-ERROR"
        then do: 
            hide frame f-grupo no-pause. 
            leave l2.
        end.
        if keyfunction(lastkey) = "GO"
        then do:
            hide frame f-grupo no-pause.
            leave l0.
        end. 
        l3: repeat :
        
            assign 
                a-seeid = -1 a-recid = -1 a-seerec = ? 
                t-itens = 0 t-valor = 0
                v-title  = " CLASSES DO GRUPO " + 
                               string(ttgrupo.nome)  + " DO ESTAB. " + 
                if par-etbcod <> 999
                then string(estab.etbnom) else "EMPRESA"
                 .


            for each ttclase where 
                 ttclase.etbcod = par-etbcod and
                 ttclase.comcod = p-comcod and
                 ttclase.catcod = p-catcod and
                 ttclase.setcod = p-setor and
                 ttclase.grupo-clacod = p-grupo: 
                t-itens = t-itens + ttclase.itens.
                t-valor = t-valor + ttclase.valor.
            end.
            disp t-itens t-valor with frame f-tot. 

            {sklcls.i 
                &help = "ENTER=Seleciona F1=Sair F4=Retorna"
                &File   = ttclase 
                &CField = ttclase.nome 
                &ofield = "     ttclase.clase-clacod
                                ttclase.nome 
                                ttclase.itens
                                ttclase.valor
                                 "
                &Where = "  ttclase.etbcod = par-etbcod and
                            ttclase.comcod = p-comcod and
                            ttclase.catcod = p-catcod and
                            ttclase.setcod = p-setor  and
                            ttclase.grupo-clacod = p-grupo " 
                &AftSelect1 = " 
                            if keyfunction(lastkey) <> ""RETURN"" and
                            keyfunction(lastkey) <> ""GO""
                            then next keys-loop.
                            else do:         
                            p-clase = ttclase.clase-clacod. 
                            clear frame f-clase all no-pause.
                            run pro-op ( ""p-clase"" ) .
                            if keyfunction(lastkey) = ""END-ERROR""
                            then next l0. 
                            leave keys-loop. 
                            end. "
                &LockType = " use-index loja " 
                &Form = " frame f-clase " 
                }                    
                        
            if keyfunction(lastkey) = "END-ERROR" 
            then do:  
                hide frame f-clase no-pause.  
                leave l3. 
            end.
            if keyfunction(lastkey) = "GO"
            then do:
                hide frame f-clase no-pause.
                leave l0.
            end. 

            l4: repeat :

                assign 
                    a-seeid = -1 a-recid = -1 a-seerec = ? 
                    t-itens = 0 t-valor = 0
                    v-title  = " SUB-CLASSES DA CLASSE " + 
                               string(ttclase.nome)  + " DO ESTAB. " + 
                    if par-etbcod <> 999
                    then string(estab.etbnom) else "EMPRESA"
                    .
 

                for each ttsclase where 
                     ttsclase.etbcod = par-etbcod and
                     ttsclase.comcod = p-comcod and
                     ttsclase.catcod = p-catcod and
                     ttsclase.setcod = p-setor and
                     ttsclase.grupo-clacod = p-grupo and
                     ttsclase.clase-clacod = p-clase: 
                    t-itens = t-itens + ttsclase.itens.
                    t-valor = t-valor + ttsclase.valor.
                end.
                disp t-itens t-valor with frame f-tot. 

                {sklcls.i 
                    &help = "ENTER=Seleciona F1=Sair F4=Retorna"
                    &File   = ttsclase 
                    &CField = ttsclase.nome 
                    &ofield = " ttsclase.sclase-clacod
                                ttsclase.nome 
                                ttsclase.itens 
                                ttsclase.valor
                                "
                    &Where = "  ttsclase.etbcod = par-etbcod and
                                ttsclase.comcod = p-comcod and
                                ttsclase.catcod = p-catcod and
                                        ttsclase.setcod = p-setor   and
                                        ttsclase.grupo-clacod = p-grupo and
                                        ttsclase.clase-clacod = p-clase
                                        " 
                    &AftSelect1 = " 
                                    if keyfunction(lastkey) <> ""RETURN"" and
                                       keyfunction(lastkey) <> ""GO""
                                    then next keys-loop.
                                    else do:   
                                    p-sclase = ttsclase.sclase-clacod. 
                                    hide frame f-sclase no-pause.
                                    pause 0.
                                    run pro-op ( ""p-sclase"" ) .
                                    if keyfunction(lastkey) = ""END-ERROR""
                                    then next l0. 
                                    leave keys-loop. 
                                    end. "
                    &LockType = " use-index loja " 
                    &Form = " frame f-sclase " 
                     }                    

                if keyfunction(lastkey) = "END-ERROR"
                then do: 
                    hide frame f-sclase no-pause. 
                    leave l4.
                end.
                if keyfunction(lastkey) = "GO"
                then do:
                    hide frame f-sclase no-pause.
                    leave l0.
                end. 

                l5: repeat:
                    disp vfapro with frame f-esc 1 down
                                 centered color with/black no-label 
                                 overlay row 17.
                    choose field vfapro with frame f-esc.
                            
                    hide frame f-esc no-pause.
                    if frame-index = 1
                    then do:
                         clear frame f-esc all.
                         hide frame f-esc no-pause.

                         assign 
                            a-seeid = -1 a-recid = -1 a-seerec = ? 
                            t-itens = 0 t-valor = 0
                            v-title  = " PRODUTOS DA SUB-CLASSE" + 
                               strinG(ttsclase.nome) + " DO ESTAB. " + 
                                if par-etbcod <> 999
                                then string(estab.etbnom) else "EMPRESA"
                                .
 

                        for each ttprodu where 
                                ttprodu.etbcod = par-etbcod and
                                ttprodu.comcod = p-comcod and
                                ttprodu.catcod = p-catcod and
                                ttprodu.setcod = p-setor and
                                ttprodu.grupo-clacod = p-grupo and
                                ttprodu.clase-clacod = p-clase and
                                ttprodu.sclase-clacod = p-sclase: 
                            t-itens = t-itens + ttprodu.itens.
                            t-valor = t-valor + ttprodu.valor.
                        end.
                        disp t-itens t-valor with frame f-tot. 
                            
                        {sklcls.i 
                            &help = "F1=Sair F4=Retorna"
                            &File   = ttprodu 
                            &CField = ttprodu.nome 
                            &ofield = "
                                ttprodu.procod
                                ttprodu.nome 
                                ttprodu.itens
                                ttprodu.valor
                                ttprodu.ocnum[1]
                                "
                            &Where = "  ttprodu.etbcod = par-etbcod and
                                        ttprodu.comcod = p-comcod and
                                        ttprodu.catcod = p-catcod and
                                        ttprodu.setcod = p-setor   and
                                        ttprodu.grupo-clacod = p-grupo and
                                        ttprodu.clase-clacod = p-clase and
                                        ttprodu.sclase-clacod = p-sclase
                                        " 
                            &AftSelect1 = " 
                                     if keyfunction(lastkey) <> ""RETURN"" and
                                     keyfunction(lastkey) <> ""GO""
                                     then next keys-loop.
                                     else leave keys-loop.
                                    "
                            &LockType = " use-index loja " 
                            &Form = " frame f-produ " 
                        }.                    

                        if keyfunction(lastkey) = "END-ERROR"
                        then do:
                            hide frame f-produ no-pause.
                            leave l5.
                        end.
                        if keyfunction(lastkey) = "GO"
                        then do:
                            hide frame f-produ no-pause.
                            leave l0.
                        end.
                    end.
                    else do:
                        clear frame f-esc all.
                        hide frame f-esc no-pause.

                        assign 
                            a-seeid = -1 a-recid = -1 a-seerec = ? 
                            t-itens = 0 t-valor = 0
                            v-title  = " FABRICABTES DA SUB-CLASSE " + 
                               string(ttsclase.nome)  + " DO ESTAB. " + 
                                if par-etbcod <> 999
                                then string(estab.etbnom) else "EMPRESA"
                                .


                        for each ttfabri where 
                                ttfabri.etbcod = par-etbcod and
                                ttfabri.comcod = p-comcod and
                                ttfabri.catcod = p-catcod and
                                ttfabri.setcod = p-setor and
                                ttfabri.grupo-clacod = p-grupo and
                                ttfabri.clase-clacod = p-clase and
                                ttfabri.sclase-clacod = p-sclase: 
                            t-itens = t-itens + ttfabri.itens.
                            t-valor = t-valor + ttfabri.valor.
                        end.
                        disp t-itens t-valor with frame f-tot. 

                        {sklcls.i 
                            &help = "F1=Sair F4=Retorna"
                            &File   = ttfabri 
                            &CField = ttfabri.nome 
                            &ofield = "
                                ttfabri.fabcod
                                ttfabri.nome 
                                ttfabri.itens 
                                ttfabri.valor
                                "
                            &Where = "  ttfabri.etbcod = par-etbcod and
                                        ttfabri.comcod = p-comcod and  
                                        ttfabri.catcod = p-catcod and     
                                        ttfabri.setcod = p-setor   and
                                        ttfabri.grupo-clacod = p-grupo and
                                        ttfabri.clase-clacod = p-clase and
                                        ttfabri.sclase-clacod = p-sclase
                                        " 
                            &aftselect1 = "  
                                   if keyfunction(lastkey) <> ""RETURN"" and
                                      keyfunction(lastkey) <> ""GO""
                                   then next keys-loop.
                                   else leave keys-loop.  
                                    "
                            &LockType = " use-index loja " 
                            &Form = " frame f-fabri " 
                        }.                    

                        if keyfunction(lastkey) = "END-ERROR"
                        then do:
                             hide frame f-fabri no-pause.
                             leave l5.
                        end.
                        if keyfunction(lastkey) = "GO"
                        then do:
                            hide frame f-fabri no-pause.
                            leave l0.
                        end.                  
                    end.
                end.        
            end. 
        end.
    end. 
    end.
    end.
    else do:
        if par-vencod = 3
        then do:
            l31: repeat: 
            assign  
                a-seeid = -1 a-recid = -1 a-seerec = ? 
                v-title  = " TRANFERENCIAS " +  " ESTAB. " + 
                if par-etbcod <> 999
                then string(estab.etbnom) else "EMPRESA"
                .

            assign t-itens = 0 t-valor = 0.
            for each ttdtmov where
                     ttdtmov.etbcod = par-etbcod:
            
                assign
                    t-itens = t-itens + ttdtmov.itens
                    t-valor = t-valor + ttdtmov.valor.
            end.         
                            
            disp t-itens t-valor with frame f-tot.
            
            {sklcls.i 
                &File   = ttdtmov 
                            &CField = ttdtmov.dtmov
                            &noncharacter = /* 
                            &ofield = "
                                ttdtmov.itens
                                ttdtmov.valor
                                "
                            &Where = " ttdtmov.etbcod = par-etbcod "
                            &AftSelect1 = " 
                                    if keyfunction(lastkey) = ""RETURN""
                                    then leave keys-loop.
                                    else
                                   next keys-loop. "
                            &LockType = " use-index dtmov " 
                            &Form = " frame f-dtmov " 
            }.                    

            if keyfunction(lastkey) = "END-ERROR"
            then do:
                            hide frame f-produ no-pause.
                            leave l0.
            end.

            if keyfunction(lastkey) = "RETURN"
            then do:
                assign  
                    a-seeid = -1 a-recid = -1 a-seerec = ? 
                    v-title  = " PRODUTOS TRANFERIDOS EM " +
                                STRING(ttdtmov.dtmov,"99/99/9999")
                    +  " ESTAB. " + 
                if par-etbcod <> 999
                then string(estab.etbnom) else "EMPRESA"
                .
                assign t-itens = 0 t-valor = 0.
                for each ttprodt where
                         ttprodt.etbcod = par-etbcod and
                         ttprodt.dtmov = ttdtmov.dtmov :
                    assign
                        t-itens = t-itens + ttprodt.itens
                        t-valor = t-valor + ttprodt.valor.
                end.         
                disp t-itens t-valor with frame f-tot.

                {sklcls.i 
                            &File   = ttprodt 
                            &CField = ttprodt.pronom 
                            &ofield = "
                                ttprodt.procod
                                ttprodt.itens
                                ttprodt.valor
                                ttprodt.ocnum[1]
                                "
                            &Where = "  ttprodt.etbcod = par-etbcod and
                                        ttprodt.dtmov = ttdtmov.dtmov "
                            &AftSelect1 = " 
                                    if keyfunction(lastkey) = ""GO""
                                    then leave keys-loop.
                                    else
                                   next keys-loop. "
                            &LockType = " use-index pronom " 
                            &Form = " frame f-prodt " 
                }.                    

                if keyfunction(lastkey) = "END-ERROR"
                then do:
                            hide frame f-prodt no-pause.
                            next l31.
                end.
                if keyfunction(lastkey) = "GO"
                then do:
                            hide frame f-setor no-pause.
                            leave l0.
                end.
            end.
            end.     
        end.
        if par-vencod = 4
        then do:
                        assign
                            a-seeid = -1 a-recid = -1 a-seerec = ? 
                            v-title  = " TRANFERIDOS POR RABRICANTE "
                    +  " ESTAB. " + 
                if par-etbcod <> 999
                then string(estab.etbnom) else "EMPRESA"
                .
 
                assign t-itens = 0 t-valor = 0. 
                for each ttfabri where
                         ttfabri.etbcod = par-etbcod:
                    assign
                        t-itens = t-iteNs + ttfabri.itens
                        t-valor = t-valor + ttfabri.valor.    
                end.         
                disp t-itens t-valor with frame f-tot.
                                
                        {sklcls.i 
                            &File   = ttfabri 
                            &CField = ttfabri.nome 
                            &ofield = "
                                ttfabri.fabcod
                                ttfabri.itens 
                                ttfabri.valor 
                                "
                            &Where = "  ttfabri.etbcod = par-etbcod "
                            &aftselect1 = " 
                                    if keyfunction(lastkey) = ""GO""
                                    then leave keys-loop.
                                    else
                                    next keys-loop. "
                            &LockType = " use-index loja " 
                            &Form = " frame f-fabri " 
                        }.                    

                        if keyfunction(lastkey) = "END-ERROR"
                        then do:
                             hide frame f-fabri no-pause.
                             leave l0.
                        end.
            if keyfunction(lastkey) = "GO"
            then do:
                hide frame f-setor no-pause.
                leave l0.
            end.     
    

        end.  
    end.
    hide frame f-1 no-pause.  
end.
hide frame f-comprador no-pause.
hide frame f-setor no-pause.
hide frame f-grupo no-pause.
hide frame f-clase no-pause.
hide frame f-sclase no-pause.
hide frame f-produ no-pause.
hide frame f-fabri no-pause.

procedure pro-op.
    
    def input parameter p-var as char.

    def var vfapro-op as char extent 3  format "x(15)"
                init[" DESCER ", "  PRODUTO  "," FABRICANTE "].


    disp vfapro-op
         with frame f-esc-op 1 down centered color with/black 
         no-label overlay row 11.
   
    choose field vfapro-op with frame f-esc-op.
    
    clear frame f-esc-op all. 
    hide frame f-esc-op no-pause.
    for each ttproduaux: delete ttproduaux. end.
    for each ttfabriaux: delete ttfabriaux. end.
    assign
        t-itens = 0 t-valor = 0.
    if frame-index = 2
    then do:
        if p-var = "p-catcod"
        then do:
                for each ttprodu where  ttprodu.etbcod = par-etbcod and
                                        ttprodu.comcod = p-comcod and
                                        ttprodu.catcod = p-catcod
                                        : 
                    create ttproduaux.
                    buffer-copy ttprodu to ttproduaux.
                    assign
                        t-itens = t-itens + ttprodu.itens
                        t-valor = t-valor + ttprodu.valor
                        .
                end.    
                v-title  = " PRODUTOS DA CATEGORIA " + 
                               string(ttcateg.nome)  + " DO ESTAB. " + 
                                if par-etbcod <> 999
                                then string(estab.etbnom) else "EMPRESA"
                                .
                         
        end.

        if p-var = "p-setor"
        then do:
                for each ttprodu where  ttprodu.etbcod = par-etbcod and
                                        ttprodu.comcod = p-comcod and
                                        ttprodu.catcod = p-catcod and
                                        ttprodu.setcod = p-setor
                                        : 
                    create ttproduaux.
                    buffer-copy ttprodu to ttproduaux.
                    assign
                        t-itens = t-itens + ttprodu.itens
                        t-valor = t-valor + ttprodu.valor
                        .
                end.     
                v-title  = " PRODUTOS DO SETOR " + 
                               string(ttSETOR.NOME)  + " DO ESTAB. " + 
                                if par-etbcod <> 999
                                then string(estab.etbnom) else "EMPRESA"
                                .
             
                         
        end.
        if p-var = "p-grupo"
        then do:
                for each ttprodu where  ttprodu.etbcod = par-etbcod and
                                        ttprodu.comcod = p-comcod and
                                        ttprodu.catcod = p-catcod and
                                        ttprodu.setcod = p-setor   and
                                        ttprodu.grupo-clacod = p-grupo 
                                        : 
                    create ttproduaux.
                    buffer-copy ttprodu to ttproduaux.
                    assign
                        t-itens = t-itens + ttprodu.itens
                        t-valor = t-valor + ttprodu.valor
                        .

                end.                 
                v-title  = " PRODUTOS DO GRUPO " + 
                               string(ttGRUPO.NOME)  + " DO ESTAB. " + 
                                if par-etbcod <> 999
                                then string(estab.etbnom) else "EMPRESA"
                                .
          
        end.
        else
        if p-var = "p-clase"
        then do:
                for each ttprodu where  ttprodu.etbcod = par-etbcod and
                                        ttprodu.comcod = p-comcod and
                                        ttprodu.catcod = p-catcod and
                                        ttprodu.setcod = p-setor   and
                                        ttprodu.grupo-clacod = p-grupo and
                                        ttprodu.clase-clacod = p-clase 
                                        : 
                    create ttproduaux.
                    buffer-copy ttprodu to ttproduaux.
                    assign
                        t-itens = t-itens + ttprodu.itens
                        t-valor = t-valor + ttprodu.valor
                        .
                end. 
                v-title  = " PRODUTOS DA CLASSE " + 
                               string(ttCLASE.NOME)  + " DO ESTAB. " + 
                                if par-etbcod <> 999
                                then string(estab.etbnom) else "EMPRESA"
                                .
         end.
        else
        if p-var = "p-sclase"
        then do:
                for each ttprodu where  ttprodu.etbcod = par-etbcod and
                                        ttprodu.comcod = p-comcod and
                                        ttprodu.catcod = p-catcod and
                                        ttprodu.setcod = p-setor   and
                                        ttprodu.grupo-clacod = p-grupo and
                                        ttprodu.clase-clacod = p-clase and
                                        ttprodu.sclase-clacod = p-sclase
                                        : 
                    create ttproduaux.
                    buffer-copy ttprodu to ttproduaux.
                    assign
                        t-itens = t-itens + ttprodu.itens
                        t-valor = t-valor + ttprodu.valor
                        .

                end. 
                v-title  = " PRODUTOS DA SUB-CLASSE " + 
                               string(ttSCLASE.NOME)  + " DO ESTAB. " + 
                                if par-etbcod <> 999
                                then string(estab.etbnom) else "EMPRESA"
                                .
         end.
 
                disp t-itens
                     t-valor  with frame f-tot.
                        assign  
                            a-seeid = -1 a-recid = -1 a-seerec = ? .
                            
                        {sklcls.i 
                            &help = "F1=Sair F4=Retorna F8=Imprime"
                            &File   = ttproduaux 
                            &CField = ttproduaux.nome 
                            &ofield = "
                                ttproduaux.itens 
                                ttproduaux.valor
                                ttproduaux.ocnum[1]
                                "
                            &Where = " true use-index nome "
                            &Otherkeys1 = " 
                                     if keyfunction(lastkey) <> ""RETURN"" and
                                     keyfunction(lastkey) <> ""GO"" and
                                     keyfunction(lastkey) <> ""CLEAR"" 
                                     then next keys-loop.
                                     else do:
                                        if  keyfunction(lastkey) = ""CLEAR""
                                        then do:
                                            run imp-pro.
                                            next keys-loop.
                                        end.
                                        leave keys-loop.
                                     end.
                                    "
                            &Form = " frame f-produ1 " 
                        }.                    

 
    end.
                        
    else if frame-index = 3
        then do:
            if p-var = "p-catcod"
            then do:
                for each ttfabri where  ttfabri.etbcod = par-etbcod and
                                        ttfabri.comcod = p-comcod and 
                                        ttfabri.catcod = p-catcod 
                                        :
                    create ttfabriaux.
                    buffer-copy ttfabri to ttfabriaux.
                    assign
                        t-itens = t-itens + ttfabri.itens
                        t-valor = t-valor + ttfabri.valor
                        .

                end.
                v-title  = " FABRICABTES DA CATEGORIA " + 
                               string(ttcateg.nome)  + " DO ESTAB. " + 
                                if par-etbcod <> 999
                                then string(estab.etbnom) else "EMPRESA"
                                .
                            
            end.
            if p-var = "p-setor"
            then do:
                for each ttfabri where  ttfabri.etbcod = par-etbcod and
                                        ttfabri.comcod = p-comcod and 
                                        ttfabri.catcod = p-catcod and      
                                        ttfabri.setcod = p-setor 
                                        :
                    create ttfabriaux.
                    buffer-copy ttfabri to ttfabriaux.
                    assign
                        t-itens = t-itens + ttfabri.itens
                        t-valor = t-valor + ttfabri.valor
                        .

                end.
                v-title  = " FABRICABTES DO SETOR " + 
                               string(ttsetor.nome)  + " DO ESTAB. " + 
                                if par-etbcod <> 999
                                then string(estab.etbnom) else "EMPRESA"
                                .
                            
            end.
            if p-var = "p-grupo"
            then do:
                for each ttfabri where  ttfabri.etbcod = par-etbcod and
                                        ttfabri.comcod = p-comcod and 
                                        ttfabri.catcod = p-catcod and      
                                        ttfabri.setcod = p-setor   and
                                        ttfabri.grupo-clacod = p-grupo 
                                        :
                    create ttfabriaux.
                    buffer-copy ttfabri to ttfabriaux.
                    assign
                        t-itens = t-itens + ttfabri.itens
                        t-valor = t-valor + ttfabri.valor
                        .

                end.
                v-title  = " FABRICABTES DO GRUPO" + 
                               string(ttgrupo.nome)  + " DO ESTAB. " + 
                                if par-etbcod <> 999
                                then string(estab.etbnom) else "EMPRESA"
                                .
                            
            end.
            if p-var = "p-clase"
            then do:
                for each ttfabri where  ttfabri.etbcod = par-etbcod and
                                        ttfabri.comcod = p-comcod and 
                                        ttfabri.catcod = p-catcod and      
                                        ttfabri.setcod = p-setor   and
                                        ttfabri.grupo-clacod = p-grupo and
                                        ttfabri.clase-clacod = p-clase 
                                        :
                    create ttfabriaux.
                    buffer-copy ttfabri to ttfabriaux.
                    assign
                        t-itens = t-itens + ttfabri.itens
                        t-valor = t-valor + ttfabri.valor
                        .

                end.
                v-title  = " FABRICABTES DA CLASSE " + 
                               string(ttclase.nome)  + " DO ESTAB. " + 
                                if par-etbcod <> 999
                                then string(estab.etbnom) else "EMPRESA"
                                .
                            
            end.
            if p-var = "p-sclase"
            then do:
                for each ttfabri where  ttfabri.etbcod = par-etbcod and
                                        ttfabri.comcod = p-comcod and 
                                        ttfabri.catcod = p-catcod and      
                                        ttfabri.setcod = p-setor   and
                                        ttfabri.grupo-clacod = p-grupo and
                                        ttfabri.clase-clacod = p-clase and
                                        ttfabri.sclase-clacod = p-sclase
                                        :
                    create ttfabriaux.
                    buffer-copy ttfabri to ttfabriaux.
                    assign
                        t-itens = t-itens + ttfabri.itens
                        t-valor = t-valor + ttfabri.valor
                        .

                end.
                v-title  = " FABRICABTES DA SUB-CLASSE " + 
                               string(ttsclase.nome)  + " DO ESTAB. " + 
                                if par-etbcod <> 999
                                then string(estab.etbnom) else "EMPRESA"
                                .
                            
            end.

                disp t-itens 
                     t-valor with frame f-tot.   

                    assign
                            a-seeid = -1 a-recid = -1 a-seerec = ? 
                            .

                        {sklcls.i 
                            &help = "F1=Sair F4=Retorna F8=Imprime"
                            &File   = ttfabriaux 
                            &CField = ttfabriaux.nome 
                            &ofield = "
                                ttfabriaux.itens 
                                ttfabriaux.valor
                                "
                            &Where = " true use-index nome " 
                            &Otherkeys1 = "  
                                   if keyfunction(lastkey) <> ""RETURN"" and
                                      keyfunction(lastkey) <> ""GO"" and
                                      keyfunction(lastkey) <> ""CLEAR""
                                     then next keys-loop.
                                     else do:
                                        if  keyfunction(lastkey) = ""CLEAR""
                                        then do:
                                            run imp-fab.
                                            next keys-loop.
                                        end.
                                        leave keys-loop.
                                     end.
                                    "
                            &Form = " frame f-fabri1 " 
                        }. 

        end.
end procedure.    

procedure imp-pro:
    def var varquivo as char.
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/perfop01" + string(time).
    else varquivo = "l:\relat\perfop01" + string(time).
    
    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "0"
        &Cond-Var  = "100"
        &Page-Line = "0"
        &Nom-Rel   = ""perfop01""
        &Nom-Sis   = """SISTEMA DE COMPRAS"""
        &Tit-Rel   = """PERFORMANCE DE PEDIDOS - PRODUTOS"""
        &Width     = "100"
        &Form      = "frame f-cabcab"}

    put skip
        v-titpro format "x(80)"
        skip.
    for each ttproduaux,
        first produ where  produ.procod = ttproduaux.procod 
        no-lock break by produ.pronom:
                
        disp
            ttproduaux.nome  
            column-label "Produtos"  format "x(30)"
            ttproduaux.itens (total)   
            column-label "Itens"            format ">>>>>>>9" 
            ttproduaux.valor (total)
            column-label "Valor"             format ">>>>>>>9"
            with frame f-produaux1 down width 100.
        down with frame f-produaux1.    
    end.         

    output close.
        
    if opsys = "UNIX"
    then do:
        run visurel.p (input varquivo, input "").
    end.
    else do:
        {mrod.i}.
    end.
        
end procedure.

procedure imp-fab:
    def var varquivo as char.
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/perfop01" + string(time).
    else varquivo = "l:\relat\perfop01" + string(time).
    
    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "0"
        &Cond-Var  = "100"
        &Page-Line = "0"
        &Nom-Rel   = ""perfop01""
        &Nom-Sis   = """SISTEMA DE COMPRAS"""
        &Tit-Rel   = """PERFORMANCE DE PEDIDOS - FABRICANTES"""
        &Width     = "100"
        &Form      = "frame f-cabcab"}

    put skip
        v-title format "x(80)"
        skip.
    for each ttfabriaux,
        first fabri where  fabri.fabcod = ttfabriaux.fabcod 
        no-lock break by fabri.fabnom:
                
        disp
            ttfabriaux.nome  
            column-label "Fabricante"  format "x(16)"
            ttfabriaux.itens (total)   
            column-label "Itens"            format ">>>>>>>9" 
            ttfabriaux.valor (total)
            column-label "Valor"             format ">>>>>>>9"
            with frame f-fabriaux1 down width 100.
        down with frame f-fabriaux1.    
    end.         

    output close.
        
    if opsys = "UNIX"
    then do:
        run visurel.p (input varquivo, input "").
    end.
    else do:
        {mrod.i}.
    end.
        
end procedure.


