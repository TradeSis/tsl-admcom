/*************************INFORMA€OES DO PROGRAMA****************************** ***** Nome do Programa             : perfoped.p
*******************************************************************************/

{admcab.i}
{setbrw.i}

def var /*input parameter*/ p-pedtdc like pedid.pedtdc.
p-pedtdc = 1.

def var vdt-aux as date format "99/99/9999".

def var vi as int.
def var aux-i as int.
def var aux-etbcod like estab.etbcod.

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

def new shared temp-table ttloja
    field etbcod        like estab.etbcod
    field nome          like estab.etbnom 
    field qtdmerca      as int  column-label "Total"
    field qtdmercaent   as int  column-label "Entregue"
    field qtdsaldo      as int  column-label "Saldo"
    field qtdatrasado   as int  column-label "Atrasado"
    field qtdposterior  as int  column-label "Posterior"
    field vlrsaldo      as dec 
    field vlratrasado   as dec 
    index loja     is unique etbcod asc
    index totalqtd is primary qtdsaldo desc etbcod desc.

def new shared temp-table ttcomprador
    field comcod    like pedid.comcod
    field comnom    as char
    field etbcod    like estab.etbcod
    field etbnom    like estab.etbnom 
    field qtdmerca  as int  column-label "Total"
    field qtdmercaent   as int  column-label "Entregue"
    field qtdsaldo  as int  column-label "Saldo"
    field qtdatrasado   as int  column-label "Atrasado"
    field qtdposterior  as int  column-label "Posterior"
    field vlrsaldo     as dec 
    field vlratrasado     as dec 
    index loja     is unique etbcod asc comcod asc 
    index platot   is primary qtdsaldo desc.

form
    clase.clacod
    clase.clanom
        help " ENTER = Seleciona" 
    "clase.setcod"
    "setor.setnom"
    with frame f-consulta
        color yellow/blue centered down overlay title " CLASSES " .

def var tqtdmerca like ttloja.qtdmerca       format ">>>>>>>9".
def var tqtdmercaent like ttloja.qtdmercaent format ">>>>>>>9".
def var tqtdsaldo like ttloja.qtdsaldo       format "->>>>>>>9".
def var tvlrsaldo like ttloja.vlrsaldo       format "->>>>,>>9.99".
def var tqdtatrasado like ttloja.qtdatrasado format ">>>>>>>9".
def var tvlratrasado like ttloja.vlratrasado format ">>>>,>>9.99".

form
    ttloja.nome  column-label "Estab."  format "x(16)"
    ttloja.qtdmerca    column-label "QTotal"  format   ">>>>>>>9" 
    ttloja.qtdmercaent column-label "QEntra"  format   ">>>>>>>9"
    ttloja.qtdsaldo column-label     "QSaldo"  format "->>>>>>>9" 
    ttloja.vlrsaldo column-label "VSaldo" format      "->>>>,>>9.99"
    ttloja.qtdatrasado column-label  "QAtraso" format  ">>>>>>>9"
    ttloja.vlratrasado column-label  "VAtraso" format  ">>>>,>>9.99"
     with frame f-lojas
        width 80
        centered
        10 down 
        row 7
        overlay title " ESTABELECIMENTOS ".
  
form
    vetbcod  label  "Estab."
    estab.etbnom no-label format "x(60)" 
    vforcod 
    forne.fornom
    vdti at 1 label "Periodo de" format "99/99/9999"
    vdtf      label "a" format "99/99/9999"
    with frame f-etb
        1 down side-labels 
        row 3 width 80
        .

def var v-opcao as char format "x(14)" extent 3 initial
    ["POR COMPRADOR","POR PRODUTO","POR FABRICANTE"].
    
def var vindex as int.
form
    v-opcao[1]  format "x(20)"
    v-opcao[2]  format "x(20)"
    v-opcao[3]  format "x(20)"
    with frame f-opcao
        centered down no-labels overlay row 15 color normal
        1 column. 

form "Processando.....>>> " 
    bestab.etbcod vdt-aux format "99/99/9999" pedid.pednum
    with frame f-1 1 down centered row 10 no-label no-box
    overlay.
    
{selestab.i vetbcod f-etb}

repeat:                         
    hide frame f-lojas no-pause.
    clear frame f-mat all.
    hide frame f-mat.

    for each ttloja :  delete ttloja. end.
    
    update vforcod with frame f-etb.
    find forne where forne.forcod = vforcod no-lock.
    disp forne.fornom no-label with frame f-etb.
    update  vdti  vdtf   with frame f-etb.
    
    run propedid.

    hide frame f-1 no-pause.
    

    hide frame f-mostr.

    tqtdmerca = 0.
    tqtdmercaent = 0.
    tqtdsaldo = 0.
    tvlrsaldo = 0.
    tqdtatrasado = 0.
    tvlratrasado = 0.

    for each ttloja:
        tqtdmerca = tqtdmerca + ttloja.qtdmerca.
        tqtdmercaent = tqtdmercaent + ttloja.qtdmercaent.
        tqtdsaldo = tqtdsaldo + ttloja.qtdsaldo.
        tvlrsaldo = tvlrsaldo + ttloja.vlrsaldo.
        tqdtatrasado = tqdtatrasado + ttloja.qtdatrasado.
        tvlratrasado = tvlratrasado + ttloja.vlratrasado.
    end.    

    l1: repeat :
        disp "        TOTAIS   "
             tqtdmerca  tqtdmercaent  tqtdsaldo  tvlrsaldo  
             tqdtatrasado  tvlratrasado 
             with frame f-tot 1 down no-box no-label
             row 21 .
 
        disp with frame f-etb .    
        pause 0.
        assign  a-seeid = -1 a-recid = -1 
                a-seerec = ? 
                v-totdia = 0 v-totger = 0.
        
        {sklcls.i
            &help = "ENTER=Seleciona F1=Sair F4=Retorna"
            &File   = ttloja
            &CField = ttloja.nome
            &Ofield = " ttloja.nome ttloja.qtdmerca 
                                   ttloja.qtdmercaent
                                   ttloja.qtdsaldo
                                   ttloja.vlrsaldo
                                   ttloja.qtdatrasado
                                   ttloja.vlratrasado
                    "
            &Where = " ttloja.etbcod  = (if vetbcod = 0
                                        then ttloja.etbcod
                                        else vetbcod)    
                        use-index totalqtd "                
            &AftSelect1 = " 
                        
                        if keyfunction(lastkey) <> ""RETURN"" and
                           keyfunction(lastkey) <> ""GO""
                        then next keys-loop.   
                        p-loja = ttloja.etbcod. 
                        leave keys-loop. "

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
        
        message "Por Comprador ? " update sresp.
        if sresp then vindex = 1.
        
        clear frame f-lojas all.
        display 
                ttloja.nome 
                ttloja.qtdmerca
                ttloja.qtdmercaent
                ttloja.qtdsaldo
                ttloja.vlrsaldo
                ttloja.qtdatrasado
                ttloja.vlratrasado
                with frame f-lojas.
        
        pause 0.
        hide frame f-lojas no-pause.
        hide frame f-tot no-pause.
        run perfop01.p (ttloja.etbcod, vindex , p-pedtdc, vforcod).
        if keyfunction(lastkey) = "GO"
        then do:
            hide frame f-lojas no-pause.
            hide frame f-etb no-pause.
            return.
        end.
    end. 
    hide frame f-1 no-pause.       
end.     

procedure propedid:

    for each tt-lj:
        find bestab where bestab.etbcod = tt-lj.etbcod no-lock no-error.
        if not avail bestab then next.

        disp bestab.etbcod with frame f-1.
        pause 0.
        do vdt-aux = vdti to vdtf:
            disp vdt-aux with frame f-1.
            pause 0.
            for each pedid where pedid.pedtdc = p-pedtdc
                    and pedid.etbcod = bestab.etbcod 
                    and pedid.peddat = vdt-aux no-lock.
                if vforcod > 0 and
                   pedid.clfcod <> vforcod
                then next.   
                disp pedid.pednum with frame f-1.
                pause 0.
                find compr where compr.comcod = pedid.comcod no-lock no-error.
   
                for each liped where liped.etbcod = bestab.etbcod and
                             liped.pedtdc = pedid.pedtdc  and
                             liped.pednum = pedid.pednum no-lock:

                    if vetbcod = 0
                    then do:
                        aux-etbcod = 999. 
                        find first ttloja where
                               ttloja.etbcod = aux-etbcod no-error.
                        if not avail ttloja
                        then do:
                            create ttloja.
                            assign
                                ttloja.etbcod = aux-etbcod
                            ttloja.nome   = if aux-etbcod = 999 then "GERAL"
                                        else (string(bestab.etbcod,"zz9") 
                                            + "-" + bestab.etbnom).
                        end.

                        find first ttcomprador where 
                              ttcomprador.etbcod = aux-etbcod and
                              ttcomprador.comcod = pedid.comcod
                                no-error.
                        if not avail ttcomprador
                        then do:
                            find compr where 
                                compr.comcod = pedid.comcod no-lock no-error.
                                            
                            create ttcomprador.
                            assign 
                                ttcomprador.etbcod = aux-etbcod
                                ttcomprador.comcod = pedid.comcod 
                                ttcomprador.comnom   = if not avail compr
                                 then "COMPRADOR-" + string(pedid.comcod)
                                 else compr.comnom.
                        end. 
                        run totaliza.
                    end.
                    find first ttloja where
                           ttloja.etbcod = bestab.etbcod no-error.
                    if not avail ttloja
                    then do:
                        create ttloja.
                        assign
                            ttloja.etbcod = bestab.etbcod
                            ttloja.nome   =  (string(bestab.etbcod,"zz9") 
                                            + "-" + bestab.etbnom).
                    end.

                    find first ttcomprador where 
                          ttcomprador.etbcod = bestab.etbcod and
                          ttcomprador.comcod = pedid.comcod
                        no-error.
                    if not avail ttcomprador
                    then do:
                        find compr where 
                            compr.comcod = pedid.comcod no-lock no-error.
                                            
                        create ttcomprador.
                        assign 
                            ttcomprador.etbcod = bestab.etbcod
                            ttcomprador.comcod = pedid.comcod 
                            ttcomprador.comnom   = if not avail compr
                                 then "COMPRADOR-" + string(pedid.comcod)
                                 else compr.comnom.
                    end. 
                    run totaliza.

                end.
            end.            
        end.
    end.

end procedure.

PROCEDURE totaliza.

        assign 
            ttloja.qtdatrasado   = ttloja.qtdatrasado +
                            if (liped.lipqtd - liped.lipent) > 0 and
                               liped.predt < vdti 
                            then liped.lipqtd - liped.lipent
                            else 0
            ttloja.vlratrasado  = ttloja.vlratrasado +
                            if (liped.lipqtd - liped.lipent) > 0 and
                               liped.predt < vdti
                            then (liped.lipqtd - liped.lipent) *
                                 liped.lippreco           
                            else 0
            ttloja.qtdposterior  = ttloja.qtdposterior +
                            if (liped.lipqtd - liped.lipent) > 0 and
                               liped.predt > vdtf
                            then (liped.lipqtd - liped.lipent)
                            else 0
            ttloja.qtdmerca  = ttloja.qtdmerca + 
                            if  liped.predt >= vdti and
                               liped.predt <= vdtf
                            then liped.lipqtd 
                            else 0

            ttloja.qtdmercaent   = ttloja.qtdmercaent + 
                            if liped.predt >= vdti and
                               liped.predt <= vdtf
                            then liped.lipent
                            else 0
            ttloja.qtdsaldo      = ttloja.qtdsaldo +
                            if liped.predt >= vdti and
                               liped.predt <= vdtf
                            then  liped.lipqtd - liped.lipent
                            else 0
            ttloja.vlrsaldo      = ttloja.vlrsaldo +
                            if liped.predt >= vdti and
                               liped.predt <= vdtf
                            then (liped.lipqtd - liped.lipent) *
                                 liped.lippreco           
                            else 0.
                
        assign 
            ttcomprador.qtdatrasado   = ttcomprador.qtdatrasado +
                            if (liped.lipqtd - liped.lipent) > 0 and
                                liped.predt < vdti
                            then (liped.lipqtd - liped.lipent)
                            else 0
            ttcomprador.vlratrasado      = ttcomprador.vlratrasado +
                            if (liped.lipqtd - liped.lipent) > 0 and
                                liped.predt < vdti
                            then (liped.lipqtd - liped.lipent) *
                                 liped.lippreco           
                            else 0
            ttcomprador.qtdposterior  = ttcomprador.qtdposterior +
                            if (liped.lipqtd - liped.lipent) > 0 and
                                liped.predt > vdtf
                            then (liped.lipqtd - liped.lipent)
                            else 0
            ttcomprador.qtdmerca      = ttcomprador.qtdmerca + 
                            if liped.predt >= vdti and
                               liped.predt <= vdtf
                            then liped.lipqtd
                            else 0
            ttcomprador.qtdmercaent   = ttcomprador.qtdmercaent + 
                            if liped.predt >= vdti and
                               liped.predt <= vdtf
                            then liped.lipent 
                            else 0
            ttcomprador.qtdsaldo      = ttcomprador.qtdsaldo +
                            if liped.predt >= vdti and
                               liped.predt <= vdtf
                            then  liped.lipqtd - liped.lipent
                            else 0
            ttcomprador.vlrsaldo      = ttcomprador.vlrsaldo +
                            if liped.predt >= vdti and
                               liped.predt <= vdtf
                            then (liped.lipqtd - liped.lipent) * liped.lippreco
                            else 0.

end procedure.

