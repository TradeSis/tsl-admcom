{admcab.i}.
{anset.i}.
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
def var p-vende     like func.funcod.
def input parameter par-etbcod      like estab.etbcod.
def input parameter par-vencod      like func.funcod.
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


def /*new*/ shared temp-table ttvendedor
    field vencod    like plani.vencod
    field etbcod    like estab.etbcod
    field nome      like estab.etbnom 
    field qtdmerca  as int column-label "Total"
    field qtdmercaent   as int column-label "Entregue"
    field qtdsaldo  as int column-label "Saldo"
    field qtdatrasado   as int column-label "Atrasado"
    field qtdposterior    as int column-label "Posterior"
    field vlrsaldo     as dec 
    field vlratrasado     as dec 
 
    index loja     is unique etbcod asc vencod asc 
    index platot   is primary qtdsaldo desc.

        
def  temp-table ttsetor 
    field setcod    like setor.setcod
    field etbcod    like estab.etbcod
    field vencod    like plani.vencod
    
    field nome      like estab.etbnom 
    field qtdmerca  as int column-label "Total"
    field qtdmercaent   as int column-label "Entregue"
    field qtdsaldo  as int column-label "Saldo"
    field qtdatrasado   as int column-label "Atrasado"
    field qtdposterior    as int column-label "Posterior"
    field vlrsaldo     as dec 
    field vlratrasado     as dec 
 
    index setor     etbcod vencod setcod 
    index valor     qtdsaldo desc.

def  temp-table ttgrupo
    field grupo-clacod    like clase.clacod
    field setcod    like setor.setcod
    field etbcod    like estab.etbcod
    field vencod    like plani.vencod
    
    field nome      like estab.etbnom 
    field qtdmerca  as int column-label "Total"
    field qtdmercaent as int column-label "Entregue"
    field qtdsaldo  as int column-label "Saldo"
    field qtdatrasado   as int column-label "Atrasado"
    field qtdposterior    as int column-label "Posterior"
    field vlrsaldo     as dec 
    field vlratrasado     as dec 
 
    index grupo     etbcod vencod setcod grupo-clacod 
    index valor     qtdsaldo desc.

def temp-table ttclase
    field setcod    like setor.setcod
    field etbcod    like plani.etbcod
    field grupo-clacod    like clase.clacod
    field clase-clacod    like clase.clasup    
    field vencod    like plani.vencod
    field qtdmerca as int column-label "Total"
    field qtdmercaent as int column-label "Entregue"
    field qtdsaldo  as int column-label "Saldo"
    field qtdatrasado   as int column-label "Atrasado"
    field qtdposterior    as int column-label "Posterior"
    field vlrsaldo     as dec 
    field vlratrasado     as dec 
 
    field nome      like estab.etbnom 
    index loja     is unique etbcod asc
                             setcod asc
                             grupo-clacod asc
                             clase-clacod asc
    index platot  is primary qtdsaldo desc.    

def temp-table ttsclase
    field setcod    like setor.setcod
    field etbcod    like plani.etbcod
    field  grupo-clacod    like clase.clacod
    field  clase-clacod    like clase.clacod    
    field sclase-clacod    like clase.clacod    
    field vencod    like plani.vencod
    field qtdmerca as int column-label "Total"
    field qtdmercaent as int column-label "Entregue"
    field qtdsaldo  as int column-label "Saldo"
    field qtdatrasado   as int column-label "Atrasado"
    field qtdposterior    as int column-label "Posterior"
    field vlrsaldo     as dec 
    field vlratrasado     as dec 
 
    field nome      like estab.etbnom 
    index loja     is unique  etbcod       asc
                              setcod       asc
                              grupo-clacod asc
                              clase-clacod asc
                             sclase-clacod asc
    index platot  is primary qtdsaldo desc.    

def temp-table ttvenpro
    field platot    like plani.platot
    field funcod    like /*movim.funcod*/ func.funcod 
    field pladia    like plani.platot
    field qtd       like movim.movqtm
    field procod    like produ.procod
    field etbcod    like plani.etbcod
    index valor     platot desc.

def temp-table ttprodu
    field setcod    like setor.setcod
    field etbcod    like plani.etbcod
    field  grupo-clacod    like clase.clacod
    field  clase-clacod    like clase.clacod    
    field sclase-clacod    like clase.clacod    
    field procod           like produ.procod 
    field vencod    like plani.vencod
    field qtdmerca as int column-label "Total"
    field qtdmercaent as int column-label "Entregue"
    field qtdsaldo  as int column-label "Saldo"
    field qtdatrasado   as int column-label "Atrasado"
    field qtdposterior    as int column-label "Posterior"
    field vlrsaldo     as dec 
    field vlratrasado     as dec 
 
    field nome      like estab.etbnom 
    index loja     is unique  etbcod       asc
                              setcod       asc
                              grupo-clacod asc
                              clase-clacod asc
                             sclase-clacod asc
                              procod       asc 
    index platot  is primary qtdsaldo desc.    

def temp-table ttfabri
    field setcod    like setor.setcod
    field etbcod    like plani.etbcod
    field  grupo-clacod    like clase.clacod
    field  clase-clacod    like clase.clacod    
    field sclase-clacod    like clase.clacod    
    field fabcod           like produ.fabcod 
    field vencod    like plani.vencod
    field nome      like estab.etbnom 
    field qtdmerca as int column-label "Total"
    field qtdmercaent  as int column-label "Entregue"
    field qtdsaldo  as int column-label "Saldo"
    field qtdatrasado   as int column-label "Atrasado"
    field qtdposterior    as int column-label "Posterior"
    field vlrsaldo     as dec 
    field vlratrasado     as dec 
  
    index loja     is unique  etbcod       asc
                              setcod       asc
                              grupo-clacod asc
                              clase-clacod asc
                             sclase-clacod asc
                              fabcod       asc 
    index platot  is primary qtdsaldo desc.    

form
    clase.clacod
    clase.clanom
        help " ENTER = Seleciona" 
    "clase.setcod"
    setor.setnom
    with frame f-consulta
        color yellow/blue centered down overlay title " CLASSES " .

form
    ttvenpro.procod
       help "F8=Imprime"
    produ.pronom    format "x(18)" 
    ttvenpro.qtd     column-label "Qtd" format ">>>9" 
    ttvenpro.pladia  format "->,>>9.99" column-label "Vnd.Dia" 
    v-perdia        column-label "% Dia" format "->>9.99" 
    ttvenpro.platot  format "->,>>9.99"  column-label "Vnd.Acum" 
    v-perc          column-label "%Acum"    format "->>9.99"
    with frame f-vendpro
        centered
        down   overlay
        title v-titvenpro.

form header 
        fill("_",73) + "SETORES" format "x(80)"
        
     with frame f-setor no-underline.

form
    ttsetor.nome  column-label "Comprador." 
        format "x(20)"
        help "ENTER=Seleciona F4=Encerra F8=Imprime F9-Detalhe" 
    ttsetor.qtdmerca    column-label "Total"  format ">>>>>>9" 
    ttsetor.qtdmercaent column-label "Entr"  format ">>>>9"
    ttsetor.qtdsaldo column-label     "!Qtd"  format "->>>>,>>9" 
    ttsetor.vlrsaldo column-label " !Valor"
                format "->>>>>>9.99"

    ttsetor.qtdatrasado column-label  "Atraso!Qtd" format ">>>>>9"
    ttsetor.vlratrasado column-label  "      !Valor" format ">>>>>9,99"
    
    ttsetor.qtdposterior column-label "Futuro!Qtd" format ">>>>>9"

    with frame f-setor
        width 80
        centered 
        down 
        row if par-vencod = 0 then 8 else 11
        no-box  no-label
        overlay.
                
form header 
        fill("_",74) + "GRUPOS" format "x(80)"

     with frame f-grupo no-underline OVERLAY. 

form
    ttgrupo.nome  column-label "Comprador." 
        format "x(22)"
        help "ENTER=Seleciona F4=Encerra F8=Imprime F9-Detalhe" 
    ttgrupo.qtdmerca    column-label "Total"  format ">>>>>>9" 
    ttgrupo.qtdmercaent column-label "Entr"  format ">>>>9"
    ttgrupo.qtdsaldo column-label     "!Qtd"  format ">>>>,>>9" 
    ttgrupo.vlrsaldo column-label " !Valor"
                format ">>>>>>9.99"

    ttgrupo.qtdatrasado column-label  "Atraso!Qtd" format ">>>>>9"
    ttgrupo.vlratrasado column-label  "      !Valor" format ">>>>>9,99"
    
    ttgrupo.qtdposterior column-label "Futuro!Qtd" format ">>>>>9"



    with frame f-grupo
        width 81
        centered 
        down 
        row if par-vencod = 0 then 10 else 13
        no-box no-label
        overlay.

form header
        fill("_",73) + "CLASSES" format "x(80)"

     with frame f-clase no-underline. 

form
    ttclase.nome  column-label "Comprador." 
        format "x(22)"
        help "ENTER=Seleciona F4=Encerra F8=Imprime F9-Detalhe" 
    ttclase.qtdmerca    column-label "Total"  format ">>>>>>9" 
    ttclase.qtdmercaent column-label "Entr"  format ">>>>9"
    ttclase.qtdsaldo column-label     "!Qtd"  format ">>>>,>>9" 
    ttclase.vlrsaldo column-label " !Valor"
                format ">>>>>>9.99"

    ttclase.qtdatrasado column-label  "Atraso!Qtd" format ">>>>>9"
    ttclase.vlratrasado column-label  "      !Valor" format ">>>>>9,99"
    
    ttclase.qtdposterior column-label "Futuro!Qtd" format ">>>>>9"


    with frame f-clase
        width 80
        centered 
        down 
        row /*if par-vencod = 0 then 12 else 15*/
        if par-vencod = 0 then 10 else 13

        no-box no-label
        overlay.

form header 
        fill("_",69) + "SUB-CLASSES" format "x(80)"

     with frame f-sclase no-underline OVERLAY. 

form
    ttsclase.nome  column-label "Comprador." 
        format "x(22)"
        help "ENTER=Seleciona F4=Encerra F8=Imprime F9-Detalhe" 
    ttsclase.qtdmerca    column-label "Total"  format ">>>>>>9" 
    ttsclase.qtdmercaent column-label "Entr"  format ">>>>9"
    ttsclase.qtdsaldo column-label     "!Qtd"  format ">>>>,>>9" 
    ttsclase.vlrsaldo column-label " !Valor"
                format ">>>>>>9.99"

    ttsclase.qtdatrasado column-label  "Atraso!Qtd" format ">>>>>9"
    ttsclase.vlratrasado column-label  "      !Valor" format ">>>>>9,99"
    
    ttsclase.qtdposterior column-label "Futuro!Qtd" format ">>>>>9"


    with frame f-sclase
        width 80
        centered 
        down 
        row if par-vencod = 0 then /*14*/ 12 else /*17*/ 15
        no-box no-label
        overlay.

form header v-titpro /*vheader*/
     with frame f-produ OVERLAY.

form
    ttprodu.nome  column-label "Comprador." 
        format "x(22)"
        help "ENTER=Seleciona F4=Encerra F8=Imprime F9-Detalhe" 
    ttprodu.qtdmerca    column-label "Total"  format ">>>>>>9" 
    ttprodu.qtdmercaent column-label "Entr"  format ">>>>9"
    ttprodu.qtdsaldo column-label     "!Qtd"  format ">>>>,>>9" 
    ttprodu.vlrsaldo column-label " !Valor"
                format ">>>>>>9.99"

    ttprodu.qtdatrasado column-label  "Atraso!Qtd" format ">>>>>9"
    ttprodu.vlratrasado column-label  "      !Valor" format ">>>>>9,99"
    
    ttprodu.qtdposterior column-label "Futuro!Qtd" format ">>>>>9"


    with frame f-produ
        width 80
        centered 
        down 
        row 8
        
        no-box  no-label
        overlay.

form header v-titpro /*vheader*/
     with frame f-fabri OVERLAY.


form
    ttfabri.nome  column-label "Comprador." 
        format "x(22)"
        help "ENTER=Seleciona F4=Encerra F8=Imprime F9-Detalhe" 
    ttfabri.qtdmerca    column-label "Total"  format ">>>>>>9" 
    ttfabri.qtdmercaent column-label "Entr"  format ">>>>9"
    ttfabri.qtdsaldo column-label     "!Qtd"  format ">>>>,>>9" 
    ttfabri.vlrsaldo column-label " !Valor"
                format ">>>>>>9.99"

    ttfabri.qtdatrasado column-label  "Atraso!Qtd" format ">>>>>9"
    ttfabri.vlratrasado column-label  "      !Valor" format ">>>>>9,99"
    
    ttfabri.qtdposterior column-label "Futuro!Qtd" format ">>>>>9"


    with frame f-fabri
        width 80
        centered 
        16 down 
        row 9
        no-box  no-label
        overlay.

form
    par-etbcod  label  "Lj"
    estab.etbnom no-label format "x(15)" 
    vdti     label "Dt.Inic"
    vdtf     label "Dt.Fim"
    vhora    label "H"
    with frame f-etb
        centered
        1 down side-labels title "Dados Iniciais"
        color white/bronw row 4 width 80.

        /*find func where func.funcod = par-vencod no-lock no-error.
        if avail func*/
        
        find compr where compr.comcod = par-vencod no-lock no-error.
        if avail compr
        then vheader = "*** VENDEDOR " +
                    /*func.funnom*/ compr.comnom .
            find first ttsetor where ttsetor.etbcod = par-etbcod and
                               ttsetor.vencod = par-vencod no-error.
            if not avail ttsetor
            then do :       
                run calcvnw2.
            end.    
            clear frame f-opcao all.
            hide frame f-opcao.
            repeat :
                if par-etbcod <> 999
                then
                    find first estab where estab.etbcod = par-etbcod no-lock.
            
                assign an-seeid = -1 an-recid = -1 an-seerec = ?
                v-titset  = "SETORES DA LOJA " + 
                    if par-etbcod <> 999
                    then string(estab.etbnom) else "EMPRESA"
                v-totger = 0 v-totdia = 0.
                /*********************
                for each ttsetor where ttsetor.etbcod = par-etbcod:
                    assign  v-totdia = v-totdia + ttsetor.pladia
                            v-totger = v-totger + ttsetor.platot.
                end.    
                *********************/
                hide frame f-mostr1.
                
                {anbrowse.i &File   = ttsetor 
                            &CField = ttsetor.nome 
                            &color  = write/cyan 
                            &ofield = "
                                ttsetor.nome 
                                ttsetor.qtdmerca 
                                ttsetor.qtdmercaent
                                ttsetor.qtdsaldo
                                ttsetor.vlrsaldo
                                ttsetor.qtdatrasado
                                ttsetor.vlratrasado
                                ttsetor.qtdposterior"
                            &Where = " ttsetor.etbcod = par-etbcod and
                                       ttsetor.vencod = par-vencod " 
                            &NonCharacter = /* 
                            &Aftfnd = "
                "
                            &AftSelect1 = "p-setor = ttsetor.setcod. 
                                       clear frame f-setor all no-pause.
                                       pause 0.
                                       display  
                                       ttsetor.nome 
                                        ttsetor.qtdmerca
                                        ttsetor.qtdmercaent
                                        ttsetor.qtdsaldo
                                        ttsetor.vlrsaldo
                                        ttsetor.qtdatrasado
                                        ttsetor.vlratrasado
                                        ttsetor.qtdposterior
                                               with frame f-setor.
                                               pause 0.
                                       leave keys-loop. "
                            &LockType = "use-index valor" 
                            &Form = " frame f-setor" 
                        }.
        
                if keyfunction(lastkey) = "END-ERROR"
                then do: 
                    hide frame f-setor no-pause. 
                    leave.
                end.                        
                        pause 0.
                repeat :
                    find first setor where setor.setcod = p-setor no-lock
                       no-error.
                    if not avail setor
                    then do:
                         message "Setor " p-setor "nao cadastrado"
                                    view-as alert-box.
                         return.
                    end.
                    
                    if par-etbcod <> 999
                    then
                    find first estab where estab.etbcod = par-etbcod no-lock.
                    
                    /*
                    assign an-seeid = -1 an-recid = -1 an-seerec = ?
                        v-titgru  = "GRUPOS DO SETOR " + 
                                string(setor.setnom)  + " DA LOJA " + 
                                if par-etbcod <> 999
                                then string(estab.etbnom)  else "EMPRESA"
                        v-totdia = 0 v-totger = 0.        
                    pause 0.
                    
                    {anbrowse.i &File   = ttgrupo 
                            &CField = ttgrupo.nome 
                            &color  = write/cyan 
                            &ofield = " 
                            ttgrupo.nome 
                                ttgrupo.qtdmerca 
                                ttgrupo.qtdmercaent
                                ttgrupo.qtdsaldo
                                ttgrupo.vlrsaldo
                                ttgrupo.qtdatrasado
                                ttgrupo.vlratrasado
                                ttgrupo.qtdposterior"
                            &Where = " ttgrupo.etbcod = par-etbcod and
                                       ttgrupo.setcod = p-setor" 
                            &NonCharacter = /* 
                            &Aftfnd = "
                
                "
                            &AftSelect1 = " p-grupo = ttgrupo.grupo-clacod. 
                                pause 0.
                                   clear frame f-grupo all no-pause.
                                   pause 0.
                    display 
                                ttgrupo.nome 
                                ttgrupo.qtdmerca
                                ttgrupo.qtdmercaent
                                ttgrupo.qtdsaldo
                                ttgrupo.vlrsaldo
                                ttgrupo.qtdatrasado
                                ttgrupo.vlratrasado
                                ttgrupo.qtdposterior

                            with frame f-grupo.
                            pause 0.
                                   leave keys-loop. "
                            &LockType = "use-index valor" 
                            &Form = " frame f-grupo" 
                        }. */                   */
                     
                    if keyfunction(lastkey) = "END-ERROR"
                    then do: 
                        hide frame f-grupo no-pause. 
                        leave.
                    end.
                    repeat :
                        find first grupo where grupo.clacod = p-grupo no-lock.
                        if par-etbcod <> 999
                        then
                        find first estab where estab.etbcod = par-etbcod
                                                no-lock.
        
                        assign an-seeid = -1 an-recid = -1 an-seerec = ?
                                v-titcla  = "CLASSES DO GRUPO " + 
                                    string(grupo.clanom) + " DA LOJA " + 
                                    if par-etbcod <> 999
                                    then string(estab.etbnom) else "EMPRESA"
                                v-totdia = 0 v-totger = 0.        
                        /*
                        for each ttclase where ttclase.etbcod = par-etbcod 
                                           and ttclase.clasup = p-grupo :
                            assign v-totdia = v-totdia + ttclase.pladia
                            v-totger = v-totger + ttclase.platot.
                        end.    
                        */
                        /**/
                        pause 0.
                        {anbrowse.i &File   = ttclase 
                            &CField = ttclase.nome 
                            &color  = write/cyan 
                            &ofield = " 
                                ttclase.nome 
                                ttclase.qtdmerca
                                ttclase.qtdmercaent
                                ttclase.qtdsaldo
                                ttclase.vlrsaldo
                                ttclase.qtdatrasado
                                ttclase.vlratrasado
                                ttclase.qtdposterior"
                            &Where = "  ttclase.etbcod = par-etbcod and
                                        ttclase.setcod = p-setor   and
                                        ttclase.grupo-clacod = p-grupo" 
                            &NonCharacter = /* 
                            &Aftfnd = "
                "
                            &AftSelect1 = " p-clase = ttclase.clase-clacod. 
                                   clear frame f-clase all no-pause.
                    display                                 ttclase.nome 
                                ttclase.qtdmerca 
                                ttclase.qtdmercaent
                                ttclase.qtdsaldo
                                ttclase.vlrsaldo
                                ttclase.qtdatrasado
                                ttclase.vlratrasado
                                ttclase.qtdposterior

                            with frame f-clase.
                                   leave keys-loop. "
                            &LockType = "use-index platot" 
                            &Form = " frame f-clase" 
                        }.                    

                        /**/
                        
                        if keyfunction(lastkey) = "END-ERROR" 
                        then do:  
                            hide frame f-clase no-pause.  
                            leave. 
                        end.
                        repeat :
                            find first clase where clase.clacod = p-clase 
                                       no-lock no-error.
                            if par-etbcod <> 999
                            then
                            find first estab where estab.etbcod = par-etbcod 
                                        no-lock.
        
                            assign an-seeid = -1 an-recid = -1 an-seerec = ?
                                v-titscla  = "SUBCLASSES DA CLASSE " + 
                                string(clase.clanom) + " DA LOJA " + 
                                if par-etbcod <> 999
                                then string(estab.etbnom) else "EMPRESA"
                               v-totdia = 0 v-totger = 0.
                            /*
                            for each ttsclase where ttsclase.etbcod = par-etbcod 
                                              and ttsclase.clasup = p-clase :
                        assign v-totdia = v-totdia + ttsclase.pladia
                                v-totger = v-totger + ttsclase.platot.
                            end.    
                            */
                            /**/
                            pause 0.
                        {anbrowse.i &File   = ttsclase 
                            &CField = ttsclase.nome 
                            &color  = write/cyan 
                            &ofield = "
                                                            ttsclase.nome 
                                ttsclase.qtdmerca 
                                ttsclase.qtdmercaent
                                ttsclase.qtdsaldo
                                ttsclase.vlrsaldo
                                ttsclase.qtdatrasado
                                ttsclase.vlratrasado
                                ttsclase.qtdposterior"
                            &Where = "  ttsclase.etbcod = par-etbcod and
                                        ttsclase.setcod = p-setor   and
                                        ttsclase.grupo-clacod = p-grupo and
                                        ttsclase.clase-clacod = p-clase
                                        " 
                            &NonCharacter = /* 
                            &Aftfnd = "
                "
                            &AftSelect1 = " p-sclase = ttsclase.sclase-clacod. 
                                   leave keys-loop. "
                            &LockType = "use-index platot" 
                            &Form = " frame f-sclase" 
                        }.                    

                             /***/
                            
                            if keyfunction(lastkey) = "END-ERROR"
                            then do: 
                                hide frame f-esc no-pause.
                                hide frame f-sclase no-pause. 
                                leave.
                            end.

                            disp vfapro with frame f-esc 1 down
                                 centered color with/black no-label 
                                 overlay.
                            choose field vfapro with frame f-esc.
                            
                            hide frame f-esc no-pause.
                            if frame-index = 1
                            then do:
                            clear frame f-esc all.
                            hide frame f-esc no-pause.

                            l1:
                            repeat :
                                find first sclase where 
                                           sclase.clacod = p-sclase no-lock
                                           no-error.
                                if par-etbcod <> 999
                                then
                                find first estab where 
                                           estab.etbcod = par-etbcod no-lock.
                                assign 
                                    an-seeid = -1 an-recid = -1 an-seerec = ?
                                    v-titpro  = "PRODUTOS DA SUBCLASSE " + 
                                    string(clase.clanom) + " DA LOJA " + 
                                    (if par-etbcod <> 999
                                    then string(estab.etbnom) else "EMPRESA")
                                    .
                                    assign
                                    v-totdia = 0 v-totger = 0.
                                /*
                                for each ttprodu where ttprodu.etbcod = par-etbcod
                                           and ttprodu.clacod = sclase.clacod:
                              assign v-totdia = v-totdia + ttprodu.pladia
                                    v-totger = v-totger + ttprodu.platot.
                                end.    
                                */
                                /*********
                                *******/
                                    pause 0.
                        {anbrowse.i &File   = ttprodu 
                            &CField = ttprodu.nome 
                            &color  = write/cyan 
                            &ofield = "
                                                            ttprodu.nome 
                                ttprodu.qtdmerca
                                ttprodu.qtdmercaent
                                ttprodu.qtdsaldo
                                ttprodu.vlrsaldo
                                ttprodu.qtdatrasado
                                ttprodu.vlratrasado
                                ttprodu.qtdposterior"
                            &Where = "  ttprodu.etbcod = par-etbcod and
                                        ttprodu.setcod = p-setor   and
                                        ttprodu.grupo-clacod = p-grupo and
                                        ttprodu.clase-clacod = p-clase and
                                        ttprodu.sclase-clacod = p-sclase
                                        " 
                            &NonCharacter = /* 
                            &Aftfnd = "
                
                "
                            &AftSelect1 = " p-procod = ttprodu.procod. 
                                   leave keys-loop. "

                            &LockType = "use-index platot" 
                            &Form = " frame f-produ" 
                        }.                    

                                if keyfunction(lastkey) = "END-ERROR"
                                then do:
                                    hide frame f-produ no-pause.
                                    hide frame f-esc no-pause.
                                    leave l1.
                                end.
                                
                                run perfped9.p
                                    (input p-procod,
                                     input vdti,
                                     input vdtf,
                                     input par-etbcod).
                            end.
                            end.
                            else do:
                            clear frame f-esc all.
                            hide frame f-esc no-pause.

                            l2:
                            repeat :
                                find first sclase where 
                                           sclase.clacod = p-sclase no-lock
                                           no-error.
                                if par-etbcod <> 999
                                then
                                find first estab where 
                                           estab.etbcod = par-etbcod no-lock.
                                    
                                assign 
                                    an-seeid = -1 an-recid = -1 an-seerec = ?
                                    v-titpro  = "FABRICANTES DA SUBCLASSE " + 
                                    string(clase.clanom) + " DA LOJA " + 
                                    if par-etbcod <> 999
                                    then string(estab.etbnom) else "EMPRESA"
                                    v-totdia = 0 v-totger = 0.
                            /*************                            
                                for each ttprodu where ttprodu.etbcod = par-etbcod
                                           and ttprodu.clacod = sclase.clacod:
                                    find first produ where 
                                               produ.procod = ttprodu.procod
                                               no-lock.
                                    find first tt-fabri where
                                               tt-fabri.fabcod = produ.fabcod 
                                               no-error.
                                    if not avail tt-fabri
                                    then do:
                                        create tt-fabri.
                                        tt-fabri.fabcod = produ.fabcod.
                                    end.
                        assign
                            tt-fabri.platot = tt-fabri.platot + ttprodu.platot
                            tt-fabri.qtd    = tt-fabri.qtd    + ttprodu.qtd
                            tt-fabri.pladia = tt-fabri.pladia + ttprodu.pladia.
                                    assign 
                                        v-totdia = v-totdia + ttprodu.pladia
                                        v-totger = v-totger + ttprodu.platot.
                                end.    
                                          ****************/
                                     pause 0.
                        {anbrowse.i &File   = ttfabri 
                            &CField = ttfabri.nome 
                            &color  = write/cyan 
                            &ofield = "
                                                            ttfabri.nome 
                                ttfabri.qtdmerca 
                                ttfabri.qtdmercaent
                                ttfabri.qtdsaldo
                                ttfabri.vlrsaldo
                                ttfabri.qtdatrasado
                                ttfabri.vlratrasado
                                ttfabri.qtdposterior"
                            &Where = "  ttfabri.etbcod = par-etbcod and
                                        ttfabri.setcod = p-setor   and
                                        ttfabri.grupo-clacod = p-grupo and
                                        ttfabri.clase-clacod = p-clase and
                                        ttfabri.sclase-clacod = p-sclase
                                        " 
                            &NonCharacter = /* 
                            &Aftfnd = "
                "
                            &LockType = "use-index platot" 
                            &Form = " frame f-fabri" 
                        }.                    

                                if keyfunction(lastkey) = "END-ERROR"
                                then do:
                                    hide frame f-fabri no-pause.
                                    leave l2.
                                end.
                           end.

                            end.
                            clear frame f-esc all.
                            hide frame f-esc no-pause.
                        end.
                    end.
                end.        
            end. 

                            hide frame f-esc no-pause.

PROCEDURE calcvnw2.
/*************************INFORMA€OES DO PROGRAMA******************************
***** Nome do Programa             : calcvnw2.i
***** Diretorio                    : movim
***** Autor                        : Andre
***** Descri‡ao Abreviada da Funcao: Include Performance de Vendas
***** Data de Criacao              : ??????

                                ALTERACOES
***** 1) Autor     : Caludir Santolin
***** 1) Descricao : Adaptacoes Sale2000
***** 1) Data      : ????2001

***** 2) Autor     :
***** 2) Descricao : 
***** 2) Data      :

***** 3) Autor     :
***** 3) Descricao : 
***** 3) Data      :
*******************************************************************************/
def var vloop as int.
def var vmens as char.
def var vmens2 as char.

vmens  = " - PROCESSANDO - ".
vmens2 = " C U S T O M    *    *    *    *    *    *    *    *    *    *    *"
+ "   *    *".
def var vtime  as int.
vtime = time.
vmens  = trim(vmens) + fill(" ",80 - length(vmens)).

vmens2 = fill(" ",80 - length(vmens2)) + trim(vmens2) .


def var vdata as date.
def var vconta as int.

   for each bestab /*where bestab.etbcod = 999*/ no-lock.

   do vdat-aux = /*vdti - 180 to vdtf + 365*/
                date(1,1,year(vdti)) to date(12,31,year(vdti)):
   
   for each pedid where pedid.etbcod = bestab.etbcod
                    and pedid.pedtdc = 1
                    and pedid.peddat = vdat-aux no-lock:
                    
   for each liped where liped.etbcod = pedid.etbcod 
                    and liped.pedtdc = 1
                    and liped.pednum = pedid.pednum no-lock:   

      /*if (liped.lipqtd - liped.lipent) <= 0
      then next.*/

      if pedid.peddat >= vdti and
         pedid.peddat <= vdtf
      then next.
      
      run criatt.
      
   end.
   end.
   end.

   do vdat-aux = vdti to vdtf:
     for each pedid where pedid.etbcod = bestab.etbcod
                      and pedid.pedtdc = 1 
                      and pedid.peddat = vdat-aux no-lock:
     
       for each liped where liped.etbcod = pedid.etbcod and
                            liped.pednum = pedid.pednum and
                            liped.pedtdc = 1 no-lock:
           run criatt.
       end. 
   end. 
   end.
    end.
hide frame f-mostr no-pause.

        /* apaga mensagem na tela */
                                put screen color messages  row 17  column 15
                        " Decorridos : " + string(time - vtime,"HH:MM:SS")
                               + " Minutos    - Lidos " +
                               string(vconta,"zzzzz9") + " Registros ".

        pause 1 no-message.
        put screen row 15  column 1 fill(" ",80).
        put screen row 16  column 1 fill(" ",80).
        put screen row 17  column 1 fill(" ",80).

end procedure.


procedure criatt.

def var vetbcod like estab.etbcod.

/*def buffer bproenoc for proenoc.
def buffer bproenocdistr for proenocdistr.*/

def buffer bliped for liped.
      

   /*find produ of proenoc no-lock .*/

   find produ where produ.procod = liped.procod no-lock no-error.
   if not avail produ then next.   
   find sclase where sclase.clacod = produ.clacod no-lock no-error.
   if not avail sclase
   then next.
   
   find clase where clase.clacod = sclase.clasup  no-lock.
   find grupo where grupo.clacod = clase.clasup   no-lock.
   
   /*find  setor no-lock.*/
   find categoria where categoria.catcod = produ.catcod no-lock.
   
   /*find setor where setor.setcod = sclase.setcod  no-lock .*/
   
   find fabri of produ no-lock.
 
      vetbcod = /*proenoc.etbentrega*/ liped.etbcod.

   aux-i = 0.    
   repeat.
      aux-i = aux-i + 1.
      if aux-i > 1 and
         par-etbcod <> 999
      then leave.
      if aux-i > 2
      then leave.
      if aux-i = 1
      then aux-etbcod = vetbcod.
      else aux-etbcod = 999.

      find first ttsetor where 
                    ttsetor.etbcod = aux-etbcod and
                    ttsetor.vencod = par-vencod and
                    ttsetor.setcod = categoria.catcod /*setor.setcod */
                no-error.
      if not avail ttsetor
      then do:
                create ttsetor.
                assign 
                    ttsetor.etbcod = aux-etbcod
                    ttsetor.vencod = par-vencod
                    ttsetor.setcod = categoria.catcod /*setor.setcod*/
                    ttsetor.nome   = categoria.catnom /*setor.setnom*/.
      end. 

      /*  
        grupo
      */
            find first ttgrupo where 
                    ttgrupo.etbcod = aux-etbcod and
                    ttgrupo.vencod = par-vencod and
                    ttgrupo.setcod = /*setor.setcod*/ categoria.catcod and
                    ttgrupo.grupo-clacod = grupo.clacod
                no-error.
            if not avail ttgrupo
            then do:
                create ttgrupo.
                assign 
                    ttgrupo.etbcod = aux-etbcod
                    ttgrupo.vencod = par-vencod
                    ttgrupo.setcod = /*setor.setcod*/ categoria.catcod
                    ttgrupo.grupo-clacod = grupo.clacod
                    ttgrupo.nome   = grupo.clanom.
            end. 

            /*
              clase
            */
            find first ttclase where 
                    ttclase.etbcod       = aux-etbcod and
                    ttclase.setcod       = /*setor.setcod*/ categoria.catcod and
                    ttclase.grupo-clacod = grupo.clacod and
                    ttclase.clase-clacod = clase.clacod
                no-error.
            if not avail ttclase
            then do:
                create ttclase.
                assign 
                    ttclase.etbcod          = aux-etbcod
                    ttclase.setcod          = categoria.catcod /*setor.setcod*/
                    ttclase.grupo-clacod    = grupo.clacod
                    ttclase.clase-clacod    = clase.clacod
                    ttclase.nome            = clase.clanom.
            end. 

            /*
              sub-clase
            */
            find first ttsclase where 
                    ttsclase.etbcod        = aux-etbcod and
                    ttsclase.setcod        = /*setor.setcod*/ categoria.catcod and
                    ttsclase.grupo-clacod  = grupo.clacod and
                    ttsclase.clase-clacod  = clase.clacod and
                    ttsclase.sclase-clacod = sclase.clacod
                                    no-error.
            if not avail ttsclase
            then do:
                create ttsclase.
                assign 
                    ttsclase.etbcod          = aux-etbcod
                    ttsclase.setcod          = /*setor.setcod*/ categoria.catcod
                    ttsclase.grupo-clacod    = grupo.clacod
                    ttsclase.clase-clacod    = clase.clacod
                    ttsclase.sclase-clacod   = sclase.clacod
                    ttsclase.nome            = sclase.clanom.
            end. 

        /*  
          produto
        */
            find first ttprodu where 
                    ttprodu.etbcod        = aux-etbcod and
                    ttprodu.setcod        = /*setor.setcod*/ categoria.catcod and
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
                    ttprodu.setcod          = categoria.catcod /*setor.setcod*/
                    ttprodu.grupo-clacod    = grupo.clacod
                    ttprodu.clase-clacod    = clase.clacod
                    ttprodu.sclase-clacod   = sclase.clacod
                    ttprodu.procod          = produ.procod
                    ttprodu.nome            = produ.pronom.
            end.  

            /*  fabricante */
            find first ttfabri where 
                    ttfabri.etbcod        = aux-etbcod and
                    ttfabri.setcod        = categoria.catcod /*setor.setcod*/ and
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
                    ttfabri.setcod          = categoria.catcod /*setor.setcod*/
                    ttfabri.grupo-clacod    = grupo.clacod
                    ttfabri.clase-clacod    = clase.clacod
                    ttfabri.sclase-clacod   = sclase.clacod
                    ttfabri.fabcod          = produ.fabcod
                    ttfabri.nome            = fabri.fabnom.
            end. 
            
            run totaliza.  

   end. /* repeat */
end.



PROCEDURE totaliza.

        /* Setor */

        assign 
            ttsetor.qtdatrasado   = ttsetor.qtdatrasado +
                            if (liped.lipqtd - liped.lipent) > 0 and
                               liped.predt < vdti
                            then (liped.lipqtd - liped.lipent)
                            else 0
            ttsetor.vlratrasado      = ttsetor.vlratrasado +
                            if (liped.lipqtd - liped.lipent) > 0 and
                               liped.predt < vdti
                            then ((liped.lipqtd - liped.lipent) *
                                 liped.lippreco           )
                            else 0

            ttsetor.qtdposterior  = ttsetor.qtdposterior +
                            if (liped.lipqtd - liped.lipent) > 0 and
                               liped.predt > vdtf
                            then (liped.lipqtd - liped.lipent)
                            else 0
                                                        
            ttsetor.qtdmerca      = ttsetor.qtdmerca + 
                            if liped.predt >= vdti and
                               liped.predt <= vdtf
                            then liped.lipqtd                            
                            else 0

            ttsetor.qtdmercaent   = ttsetor.qtdmercaent + 
                            if liped.predt >= vdti and
                               liped.predt <= vdtf
                            then liped.lipent
                            else 0
                            
            ttsetor.qtdsaldo      = ttsetor.qtdsaldo +
                            if liped.predt >= vdti and
                               liped.predt <= vdtf
                            then liped.lipqtd - liped.lipent
                            else 0
                        
            ttsetor.vlrsaldo      = ttsetor.vlrsaldo +
                            if liped.predt >= vdti and
                               liped.predt <= vdtf
                            then  (liped.lipqtd - liped.lipent) *
                                            liped.lippreco
                            else 0.
        /***/        


        /* grupo */
        assign 
            ttgrupo.qtdatrasado   = ttgrupo.qtdatrasado +
                            if (liped.lipqtd - liped.lipent) > 0 and
                               liped.predt < vdti
                            then (liped.lipqtd - liped.lipent)
                            
                            else 0
            ttgrupo.vlratrasado      = ttgrupo.vlratrasado +
                            if (liped.lipqtd - liped.lipent) > 0 and
                               liped.predt < vdti
                            then ((liped.lipqtd - liped.lipent) *
                                 liped.lippreco           )

                            else 0

            ttgrupo.qtdposterior  = ttgrupo.qtdposterior +
                            if (liped.lipqtd - liped.lipent) > 0 and
                               liped.predt > vdtf
                            then (liped.lipqtd - liped.lipent)
                            else 0.
                            
            ttgrupo.qtdmerca      = ttgrupo.qtdmerca + 
                            if liped.predt >= vdti and
                               liped.predt <= vdtf
                            then liped.lipqtd
                            else 0.
                            
            ttgrupo.qtdmercaent   = ttgrupo.qtdmercaent + 
                            if liped.predt >= vdti and
                               liped.predt <= vdtf
                            then liped.lipent
                            else 0.
                            
            ttgrupo.qtdsaldo      = ttgrupo.qtdsaldo +
                            if liped.predt >= vdti and
                               liped.predt <= vdtf
                            then liped.lipqtd - liped.lipent
                            else 0.
                        
            ttgrupo.vlrsaldo      = ttgrupo.vlrsaldo +
                            if liped.predt >= vdti and
                               liped.predt <= vdtf
                            then  (liped.lipqtd - liped.lipent) *
                                            liped.lippreco
                            else 0.
                

        /* clase */
        assign 
            ttclase.qtdatrasado   = ttclase.qtdatrasado +
                            if (liped.lipqtd - liped.lipent) > 0 and
                               liped.predt < vdti
                            then (liped.lipqtd - liped.lipent)
                            else 0
            ttclase.vlratrasado      = ttclase.vlratrasado +
                            if (liped.lipqtd - liped.lipent) > 0 and
                               liped.predt < vdti
                            then (liped.lipqtd - liped.lipent) *
                                 liped.lippreco           
                            else 0

            ttclase.qtdposterior  = ttclase.qtdposterior +
                            if (liped.lipqtd - liped.lipent) > 0 and
                               liped.predt > vdtf
                            then (liped.lipqtd - liped.lipent)
                            else 0
                            
            ttclase.qtdmerca      = ttclase.qtdmerca + 
                            if liped.predt >= vdti and
                               liped.predt <= vdtf
                            then liped.lipqtd
                            else 0
            ttclase.qtdmercaent   = ttclase.qtdmercaent + 
                            if liped.predt >= vdti and
                               liped.predt <= vdtf
                            then liped.lipent
                            else 0
            ttclase.qtdsaldo      = ttclase.qtdsaldo +
                            if liped.predt >= vdti and
                               liped.predt <= vdtf
                            then liped.lipqtd - liped.lipent
                            else 0
                        
            ttclase.vlrsaldo      = ttclase.vlrsaldo +
                            if liped.predt >= vdti and
                               liped.predt <= vdtf
                            then  (liped.lipqtd - liped.lipent) *
                                            liped.lippreco
                            else 0.
                
        /* sclase */
        assign 
            ttsclase.qtdatrasado   = ttsclase.qtdatrasado +
                            if (liped.lipqtd - liped.lipent) > 0 and
                               liped.predt < vdti
                            then (liped.lipqtd - liped.lipent)
                            else 0
            ttsclase.vlratrasado      = ttsclase.vlratrasado +
                            if (liped.lipqtd - liped.lipent) > 0 and
                               liped.predt < vdti
                            then (liped.lipqtd - liped.lipent) *
                                 liped.lippreco           
                            else 0

            ttsclase.qtdposterior  = ttsclase.qtdposterior +
                            if (liped.lipqtd - liped.lipent) > 0 and
                               liped.predt > vdtf
                            then (liped.lipqtd - liped.lipent)
                            else 0
                            
            ttsclase.qtdmerca      = ttsclase.qtdmerca + 
                            if liped.predt >= vdti and
                               liped.predt <= vdtf
                            then liped.lipqtd
                            else 0
            ttsclase.qtdmercaent   = ttsclase.qtdmercaent + 
                            if liped.predt >= vdti and
                               liped.predt <= vdtf
                            then liped.lipent
                            else 0
            ttsclase.qtdsaldo      = ttsclase.qtdsaldo +
                            if liped.predt >= vdti and
                               liped.predt <= vdtf
                            then liped.lipqtd - liped.lipent
                            else 0
                        
            ttsclase.vlrsaldo      = ttsclase.vlrsaldo +
                            if liped.predt >= vdti and
                               liped.predt <= vdtf
                            then  (liped.lipqtd - liped.lipent) *
                                            liped.lippreco
                            else 0.
                
        /* produ */
        assign 
            ttprodu.qtdatrasado   = ttprodu.qtdatrasado +
                            if (liped.lipqtd - liped.lipent) > 0 and
                               liped.predt < vdti
                            then (liped.lipqtd - liped.lipent)
                            else 0
            ttprodu.vlratrasado      = ttprodu.vlratrasado +
                            if (liped.lipqtd - liped.lipent) > 0 and
                               liped.predt < vdti
                            then (liped.lipqtd - liped.lipent) *
                                 liped.lippreco           
                            else 0

            ttprodu.qtdposterior  = ttprodu.qtdposterior +
                            if (liped.lipqtd - liped.lipent) > 0 and
                               liped.predt > vdtf
                            then (liped.lipqtd - liped.lipent)
                            else 0
                            
            ttprodu.qtdmerca      = ttprodu.qtdmerca + 
                            if liped.predt >= vdti and
                               liped.predt <= vdtf
                            then liped.lipqtd
                            else 0
            ttprodu.qtdmercaent   = ttprodu.qtdmercaent + 
                            if liped.predt >= vdti and
                               liped.predt <= vdtf
                            then liped.lipent
                            else 0
            ttprodu.qtdsaldo      = ttprodu.qtdsaldo +
                            if liped.predt >= vdti and
                               liped.predt <= vdtf
                            then liped.lipqtd - liped.lipent
                            else 0
                        
            ttprodu.vlrsaldo      = ttprodu.vlrsaldo +
                            if liped.predt >= vdti and
                               liped.predt <= vdtf
                            then  (liped.lipqtd - liped.lipent) *
                                            liped.lippreco
                            else 0.
                
        /* fabri */
        assign 
            ttfabri.qtdatrasado   = ttfabri.qtdatrasado +
                            if (liped.lipqtd - liped.lipent) > 0 and
                               liped.predt < vdti
                            then (liped.lipqtd - liped.lipent)
                            else 0
            ttfabri.vlratrasado      = ttfabri.vlratrasado +
                            if (liped.lipqtd - liped.lipent) > 0 and
                               liped.predt < vdti
                            then (liped.lipqtd - liped.lipent) *
                                 liped.lippreco           
                            else 0

            ttfabri.qtdposterior  = ttfabri.qtdposterior +
                            if (liped.lipqtd - liped.lipent) > 0 and
                               liped.predt > vdtf
                            then (liped.lipqtd - liped.lipent)
                            else 0
                            
            ttfabri.qtdmerca      = ttfabri.qtdmerca + 
                            if liped.predt >= vdti and
                               liped.predt <= vdtf
                            then liped.lipqtd
                            else 0
            ttfabri.qtdmercaent   = ttfabri.qtdmercaent + 
                            if liped.predt >= vdti and
                               liped.predt <= vdtf
                            then liped.lipent
                            else 0
            ttfabri.qtdsaldo      = ttfabri.qtdsaldo +
                            if liped.predt >= vdti and
                               liped.predt <= vdtf
                            then liped.lipqtd - liped.lipent
                            else 0
                        
            ttfabri.vlrsaldo      = ttfabri.vlrsaldo +
                            if liped.predt >= vdti and
                               liped.predt <= vdtf
                            then  (liped.lipqtd - liped.lipent) *
                                            liped.lippreco
                            else 0.
                

end procedure.
