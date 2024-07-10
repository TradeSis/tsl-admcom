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
def var vetbcod like estab.etbcod.
if par-etbcod = 999
then vetbcod = 0. else vetbcod =  par-etbcod.
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

def shared temp-table ttsetor 
    field setcod    like setor.setcod
    field etbcod    like estab.etbcod
    field nome      like estab.etbnom 
    field gqtdven  like plani.platot
    field gvalcus  like plani.platot
    field gvalven  like plani.platot
    field gqtdest  like plani.platot
    field gvestcus like plani.platot
    field gvestven like plani.platot
    field giro     like plani.platot
    index setor     etbcod  setcod 
    index valor     giro desc.

def shared temp-table ttgrupo
    field grupo-clacod    like clase.clacod
    field setcod    like setor.setcod
    field etbcod    like estab.etbcod
    field nome    like estab.etbnom 
    field gqtdven  like plani.platot
    field gvalcus  like plani.platot
    field gvalven  like plani.platot
    field gqtdest  like plani.platot
    field gvestcus like plani.platot
    field gvestven like plani.platot
    field giro     like plani.platot
    index grupo     etbcod setcod grupo-clacod 
    index valor     giro desc.

def shared temp-table ttclase
    field setcod    like setor.setcod
    field etbcod    like plani.etbcod
    field grupo-clacod    like clase.clacod
    field clase-clacod    like clase.clasup    
    field nome      like estab.etbnom 
    field gqtdven  like plani.platot
    field gvalcus  like plani.platot
    field gvalven  like plani.platot
    field gqtdest  like plani.platot
    field gvestcus like plani.platot
    field gvestven like plani.platot
    field giro     like plani.platot
    index loja     is unique etbcod asc
                             setcod asc
                             grupo-clacod asc
                             clase-clacod asc
    index platot  is primary giro desc.    

def shared temp-table ttsclase
    field setcod    like setor.setcod
    field etbcod    like plani.etbcod
    field  grupo-clacod    like clase.clacod
    field  clase-clacod    like clase.clacod    
    field sclase-clacod    like clase.clacod  
    field nome      like estab.etbnom 
    field gqtdven  like plani.platot
    field gvalcus  like plani.platot
    field gvalven  like plani.platot
    field gqtdest  like plani.platot
    field gvestcus like plani.platot
    field gvestven like plani.platot
    field giro     like plani.platot
    index loja     is unique  etbcod       asc
                              setcod       asc
                              grupo-clacod asc
                              clase-clacod asc
                             sclase-clacod asc
    index platot  is primary giro desc.    

def shared temp-table ttprodu
    field setcod    like setor.setcod
    field etbcod    like plani.etbcod
    field  grupo-clacod    like clase.clacod
    field  clase-clacod    like clase.clacod    
    field sclase-clacod    like clase.clacod    
    field procod           like produ.procod 
    field nome     like estab.etbnom 
    field gqtdven  like plani.platot
    field gvalcus  like plani.platot
    field gvalven  like plani.platot
    field gqtdest  like plani.platot
    field gvestcus like plani.platot
    field gvestven like plani.platot
    field giro     like plani.platot
    index loja     is unique  etbcod       asc
                              setcod       asc
                              grupo-clacod asc
                              clase-clacod asc
                             sclase-clacod asc
                              procod       asc 
    index platot  is primary giro desc.    

def shared temp-table ttfabri
    field setcod    like setor.setcod
    field etbcod    like plani.etbcod
    field  grupo-clacod    like clase.clacod
    field  clase-clacod    like clase.clacod    
    field sclase-clacod    like clase.clacod    
    field fabcod           like produ.fabcod 
    field nome      like estab.etbnom 
    field gqtdven  like plani.platot
    field gvalcus  like plani.platot
    field gvalven  like plani.platot
    field gqtdest  like plani.platot
    field gvestcus like plani.platot
    field gvestven like plani.platot
    field giro     like plani.platot
    index loja     is unique  etbcod       asc
                              setcod       asc
                              grupo-clacod asc
                              clase-clacod asc
                             sclase-clacod asc
                              fabcod       asc 
    index platot  is primary giro desc.    

form header 
        "----<SETORES>" + fill("-",73) format "x(80)"
     with frame f-setor no-underline.

form
    ttsetor.nome  column-label "Setor"  format "x(20)"
    ttsetor.giro     format "->>9.99"      column-label " Giro "
    ttsetor.gqtdven  format "->>>>>9"        column-label "QVenda"
    ttsetor.gqtdest  format "->>>>>9"       column-label "QEstoq"
    ttsetor.gvalcus  format "->>>>>9"       column-label "VCusto"
    ttsetor.gvalven  format "->>>>>9"       column-label "VVenda"
    ttsetor.gvestcus format "->>>>>>>9"     column-label "ECusto"
    ttsetor.gvestven format "->>>>>>>9"   column-label "EVenda"
    with frame f-setor
        width 80
        centered 
        down 
        row 8
        no-box  no-label
        overlay.
                
form header 
        "----<GRUPOS>" + fill("-",74) format "x(80)"
     with frame f-grupo no-underline OVERLAY. 

form
    ttgrupo.nome  column-label "Grupo"  format "x(20)"
    ttgrupo.giro     format "->>9.99"      column-label " Giro "
    ttgrupo.gqtdven  format "->>>>>9"        column-label "QVenda"
    ttgrupo.gqtdest  format "->>>>>9"       column-label "QEstoq"
    ttgrupo.gvalcus  format "->>>>>9"       column-label "VCusto"
    ttgrupo.gvalven  format "->>>>>9"       column-label "VVenda"
    ttgrupo.gvestcus format "->>>>>>>9"     column-label "ECusto"
    ttgrupo.gvestven format "->>>>>>>9"   column-label "EVenda"
    with frame f-grupo
        width 81
        centered 
        down 
        row 10
        no-box no-label
        overlay.

form header
        "----<CLASSES>" + fill("-",73) format "x(80)"
     with frame f-clase no-underline. 

form
    ttclase.nome  column-label "Classe"  format "x(20)"
    ttclase.giro     format "->>9.99"      column-label " Giro "
    ttclase.gqtdven  format "->>>>>9"        column-label "QVenda"
    ttclase.gqtdest  format "->>>>>9"       column-label "QEstoq"
    ttclase.gvalcus  format "->>>>>9"       column-label "VCusto"
    ttclase.gvalven  format "->>>>>9"       column-label "VVenda"
    ttclase.gvestcus format "->>>>>>>9"     column-label "ECusto"
    ttclase.gvestven format "->>>>>>>9"   column-label "EVenda"
    with frame f-clase
        width 80
        centered 
        down 
        row  12
        no-box no-label
        overlay.

form header 
        "----<SUB-CLASSES>" + fill("-",69) format "x(80)"
     with frame f-sclase no-underline OVERLAY. 

form
    ttsclase.nome  column-label "Sub-Classe"  format "x(20)"
    ttsclase.giro     format "->>9.99"      column-label " Giro "
    ttsclase.gqtdven  format "->>>>>9"        column-label "QVenda"
    ttsclase.gqtdest  format "->>>>>9"       column-label "QEstoq"
    ttsclase.gvalcus  format "->>>>>9"       column-label "VCusto"
    ttsclase.gvalven  format "->>>>>9"       column-label "VVenda"
    ttsclase.gvestcus format "->>>>>>>9"     column-label "ECusto"
    ttsclase.gvestven format "->>>>>>>9"   column-label "EVenda"
    with frame f-sclase
        width 80
        centered 
        down 
        row 14
        no-box no-label
        overlay.

form header 
        "----<PRODUTOS>" + fill("-",69) format "x(80)"
     with frame f-produ no-underline OVERLAY. 

form
    ttprodu.nome  column-label "Produto"  format "x(20)"
    ttprodu.giro     format "->>9.99"      column-label " Giro "
    ttprodu.gqtdven  format "->>>>>9"        column-label "QVenda"
    ttprodu.gqtdest  format "->>>>>9"       column-label "QEstoq"
    ttprodu.gvalcus  format "->>>>>9"       column-label "VCusto"
    ttprodu.gvalven  format "->>>>>9"       column-label "VVenda"
    ttprodu.gvestcus format "->>>>>>>9"     column-label "ECusto"
    ttprodu.gvestven format "->>>>>>>9"   column-label "EVenda"
    with frame f-produ
        width 80
        centered 
        down 
        row 16
        no-box  no-label
        overlay.

form header 
        "----<FABRICANTES>" + fill("-",69)  format "x(80)"
     with frame f-fabri no-underline OVERLAY. 

form
    ttfabri.nome  column-label "Fabricante"  format "x(20)"
    ttfabri.giro     format "->>9.99"      column-label " Giro "
    ttfabri.gqtdven  format "->>>>>9"        column-label "QVenda"
    ttfabri.gqtdest  format "->>>>>9"       column-label "QEstoq"
    ttfabri.gvalcus  format "->>>>>9"       column-label "VCusto"
    ttfabri.gvalven  format "->>>>>9"       column-label "VVenda"
    ttfabri.gvestcus format "->>>>>>>9"     column-label "ECusto"
    ttfabri.gvestven format "->>>>>>>9"   column-label "EVenda"
    with frame f-fabri
        width 80
        centered 
        down 
        row 16
        no-box  no-label
        overlay.

form "Processando.....>>> " 
    bestab.etbcod vdt-aux format "99/99/9999" pedid.pednum
    with frame f-1 1 down centered row 10 no-label no-box
    overlay.
 
status default "ENTER=Seleciona F1=Sair F4=Retorna".

l1: repeat :
    if par-etbcod <> 999
    then find first estab where estab.etbcod = par-etbcod no-lock.
            
    assign 
        a-seeid = -1 a-recid = -1 a-seerec = ? .

    hide frame f-mostr1 no-pause.
    
    {sklcls.i
        &File   = ttsetor 
        &CField = ttsetor.nome 
        &ofield = "
                     ttsetor.gqtdven  
                     ttsetor.gvalcus 
                     ttsetor.gvalven  
                     ttsetor.gqtdest 
                     ttsetor.gvestcus 
                     ttsetor.gvestven 
                     ttsetor.giro 
                    "
        &Where = " ttsetor.etbcod = par-etbcod 
                 "
        &AftSelect1 = " 
                    if keyfunction(lastkey) <> ""return"" and
                       keyfunction(lastkey) <> ""GO""
                    then next keys-loop.    
                    p-setor = ttsetor.setcod. 
                    clear frame f-setor all no-pause.
                    display  
                             ttsetor.nome
                             ttsetor.gqtdven  
                             ttsetor.gvalcus 
                             ttsetor.gvalven  
                             ttsetor.gqtdest 
                             ttsetor.gvestcus 
                             ttsetor.gvestven 
                             ttsetor.giro 
                             with frame f-setor.
                       pause 0.
                       leave keys-loop. "
        &LockType = " use-index valor " 
        &Form = " frame f-setor " 
         }
        
    if keyfunction(lastkey) = "END-ERROR" or
       keyfunction(lastkey) = "GO" 
    then do: 
        hide frame f-setor no-pause. 
        leave l1.
    end.                        
    
    l2: repeat :
        find first setor where 
                setor.setcod = p-setor no-lock no-error.
        if not avail setor
        then do:
            message "Setor " p-setor "nao cadastrado"
                       view-as alert-box.
            leave l2.
        end.
                    
        if par-etbcod <> 999
        then find first estab where estab.etbcod = par-etbcod no-lock.
                    
        assign
            a-seeid = -1 a-recid = -1 a-seerec = ? .
            
        {sklcls.i 
            &File   = ttgrupo 
            &CField = ttgrupo.nome 
            &ofield = " 
                     ttgrupo.gqtdven  
                     ttgrupo.gvalcus 
                     ttgrupo.gvalven  
                     ttgrupo.gqtdest 
                     ttgrupo.gvestcus 
                     ttgrupo.gvestven 
                     ttgrupo.giro 
                        "
            &Where = " ttgrupo.etbcod = par-etbcod and
                       ttgrupo.setcod = p-setor " 
            &AftSelect1 = " 
                        if keyfunction(lastkey) <> ""RETURN"" and
                           keyfunction(lastkey) <> ""GO""
                        then next keys-loop.  
                        p-grupo = ttgrupo.grupo-clacod. 
                            clear frame f-grupo all no-pause.
                        display 
                           ttgrupo.nome 
                           ttgrupo.gqtdven  
                           ttgrupo.gvalcus 
                           ttgrupo.gvalven  
                           ttgrupo.gqtdest 
                           ttgrupo.gvestcus 
                           ttgrupo.gvestven 
                           ttgrupo.giro                                                            with frame f-grupo.
                         pause 0.
                         leave keys-loop. "
            &LockType = " use-index valor " 
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
            leave l1.
        end.

        l3: repeat :
            find first grupo where grupo.clacod = p-grupo no-lock.
            if par-etbcod <> 999
            then find first estab where estab.etbcod = par-etbcod no-lock.
        
            assign 
                a-seeid = -1 a-recid = -1 a-seerec = ?.
               
            {sklcls.i 
                &File   = ttclase 
                &CField = ttclase.nome 
                &ofield = " 
                     ttclase.gqtdven  
                     ttclase.gvalcus 
                     ttclase.gvalven  
                     ttclase.gqtdest 
                     ttclase.gvestcus 
                     ttclase.gvestven 
                     ttclase.giro 
                                 "
                &Where = "  ttclase.etbcod = par-etbcod and
                                        ttclase.setcod = p-setor   and
                                        ttclase.grupo-clacod = p-grupo " 
                &AftSelect1 = " 
                            if keyfunction(lastkey) <> ""RETURN"" and
                               keyfunction(lastkey) <> ""GO""
                            then next keys-loop. 
                            p-clase = ttclase.clase-clacod. 
                            clear frame f-clase all no-pause.
                            display     
                                ttclase.nome 
                                ttclase.gqtdven  
                                ttclase.gvalcus 
                                ttclase.gvalven  
                                ttclase.gqtdest 
                                ttclase.gvestcus 
                                ttclase.gvestven 
                                ttclase.giro 
                                with frame f-clase.
                            pause 0.
                            leave keys-loop. "
                &LockType = "use-index platot " 
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
                leave l1. 
            end.
 
            l4: repeat :
                find first clase where clase.clacod = p-clase 
                                       no-lock no-error.
                if par-etbcod <> 999
                then find first estab where estab.etbcod = par-etbcod 
                                        no-lock.
        
                assign 
                    a-seeid = -1 a-recid = -1 a-seerec = ? .

                {sklcls.i 
                    &File   = ttsclase 
                    &CField = ttsclase.nome 
                    &ofield = "
                        ttsclase.gqtdven  
                        ttsclase.gvalcus 
                        ttsclase.gvalven  
                        ttsclase.gqtdest 
                        ttsclase.gvestcus 
                        ttsclase.gvestven 
                        ttsclase.giro 
                                "
                    &Where = "  ttsclase.etbcod = par-etbcod and
                                        ttsclase.setcod = p-setor   and
                                        ttsclase.grupo-clacod = p-grupo and
                                        ttsclase.clase-clacod = p-clase
                                        " 
                    &AftSelect1 = " 
                                    if keyfunction(lastkey) <> ""RETURN"" and
                                       keyfunction(lastkey) <> ""GO""
                                    then next keys-loop. 
                                    p-sclase = ttsclase.sclase-clacod. 
                                    hide frame f-sclase no-pause.
                                    disp
                                        ttsclase.nome 
                                        ttsclase.gqtdven  
                                        ttsclase.gvalcus 
                                        ttsclase.gvalven  
                                        ttsclase.gqtdest 
                                        ttsclase.gvestcus 
                                        ttsclase.gvestven 
                                        ttsclase.giro 
                                        with frame f-sclase.
                                    pause 0.
                                    leave keys-loop. "
                    &LockType = " use-index platot " 
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
                    leave l1.
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

                         find first sclase where 
                                           sclase.clacod = p-sclase no-lock
                                           no-error.
                         if par-etbcod <> 999
                         then
                         find first estab where 
                                    estab.etbcod = par-etbcod no-lock.
                         assign
                             a-seeid = -1 a-recid = -1 a-seerec = ?.
                        {sklcls.i 
                            &File   = ttprodu 
                            &CField = ttprodu.nome 
                            &ofield = "
                                ttprodu.gqtdven  
                                ttprodu.gvalcus 
                                ttprodu.gvalven  
                                ttprodu.gqtdest 
                                ttprodu.gvestcus 
                                ttprodu.gvestven 
                                ttprodu.giro 
                                "
                            &Where = "  ttprodu.etbcod = par-etbcod and
                                        ttprodu.setcod = p-setor   and
                                        ttprodu.grupo-clacod = p-grupo and
                                        ttprodu.clase-clacod = p-clase and
                                        ttprodu.sclase-clacod = p-sclase
                                        " 
                            &AftSelect1 = " 
                                   if keyfunction(lastkey) = ""GO""
                                   then leave keys-loop.  
                                   else next keys-loop. "
                            &LockType = " use-index platot " 
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
                            leave l1.
                        end.

                    end.
                    else do:
                        clear frame f-esc all.
                        hide frame f-esc no-pause.

                        find first sclase where 
                                           sclase.clacod = p-sclase no-lock
                                           no-error.
                        if par-etbcod <> 999
                        then find first estab where 
                                           estab.etbcod = par-etbcod no-lock.
                                    
                        assign 
                            a-seeid = -1 a-recid = -1 a-seerec = ?.

                        {sklcls.i 
                            &File   = ttfabri 
                            &CField = ttfabri.nome 
                            &ofield = "
                                ttfabri.gqtdven  
                                ttfabri.gvalcus 
                                ttfabri.gvalven  
                                ttfabri.gqtdest 
                                ttfabri.gvestcus 
                                ttfabri.gvestven 
                                ttfabri.giro 
                                "
                            &Where = "  ttfabri.etbcod = par-etbcod and
                                        ttfabri.setcod = p-setor   and
                                        ttfabri.grupo-clacod = p-grupo and
                                        ttfabri.clase-clacod = p-clase and
                                        ttfabri.sclase-clacod = p-sclase
                                        " 
                            &aftselect1 = " 
                                   if keyfunction(lastkey) = ""GO""
                                   then leave keys-loop. 
                                   else next keys-loop. "
                            &LockType = " use-index platot " 
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
                             leave l1.
                        end.

                    end.
                end.        
            end. 
        end.
    end.      
end.
hide frame f-setor no-pause.
hide frame f-grupo no-pause.
hide frame f-clase no-pause.
hide frame f-sclase no-pause.
hide frame f-produ no-pause.
hide frame f-fabri no-pause.



