{/admcom/progr/admcab-batch.i new}

def var vatu-est as log.
vatu-est = no.
vatu-est = yes.
def var varqlog as char.

pause 0 before-hid.
def var p-retorna as log.
def var vdest as log.
def var vemit as log.
def var vdestaj as log.
def var datasai  like plani.pladat.
def new shared var vdt like plani.pladat.
def var vnumero as char format "x(07)".
def var vmovqtm like movim.movqtm.
def var vmes as int format "99".
def var vano as int format "9999".
def new shared var t-sai   like plani.platot.
def new shared var t-ent   like plani.platot.
def var vdata   like plani.pladat.
def new shared var vetbcod like estab.etbcod.
def new shared var vprocod like produ.procod.
def var vtotdia like plani.platot.
def var vtot  like movim.movpc.
def var vtotg like movim.movpc.
def var vtotgeral like plani.platot.
def new shared var vdata1 like plani.pladat label "Data".
def new shared var vdata2 like plani.pladat label "Data".
def var vtotal like plani.platot.
def var vtoticm like plani.icms.
def var vtotmovim   like movim.movpc.
def var vmovtnom  like tipmov.movtnom.
def var vsalant   like estoq.estatual.
def new shared var sal-ant   like estoq.estatual.
def new shared var sal-atu   like estoq.estatual.
def new shared var vdisp as log.
def var vprimeiro as int.
def var vestatual as char.
def var vsalatual as char.
def var vdiferest as char.
             
def temp-table tt-pro
    field etbcod like estab.etbcod
    field q-pro as int
    field q-ant as dec 
    field q-ent as dec
    field q-sai as dec
    field q-atu as dec
    field q-adm as dec
    field d-pro as dec
    field d-ant as dec
    field d-ent as dec
    field d-sai as dec
    field d-atu as dec
    field d-adm as dec
    .
    
def new shared temp-table tt-movest
    field etbcod like estab.etbcod
    field procod like produ.procod
    field data as date
    field movtdc like tipmov.movtdc
    field tipmov as char
    field numero as char
    field serie like plani.serie
    field emite like plani.emite
    field desti like plani.desti
    field movqtm like movim.movqtm
    field movpc like movim.movpc
    field sal-ant as dec
    field sal-atu as dec
    field cus-ent as dec
    field cus-med as dec
    field qtd-ent as dec
    field qtd-sai as dec 
    .
     
def new shared temp-table tt-saldo
    field etbcod like estab.etbcod 
    field procod like produ.procod
    field codfis as int
    field sal-ant as dec
    field qtd-ent as dec
    field qtd-sai as dec
    field sal-atu as dec
    field cto-mes as dec
    field ano-cto as int
    field mes-cto as int
    field cus-ent as dec
    field cus-med as dec
    index i1 ano-cto mes-cto etbcod procod
    .

def var vdesti like movim.desti.

form datasai format "99/99/9999" column-label "Data Saida"
    vmovtnom column-label "Operacao" format "x(12)"
    vnumero 
    plani.serie column-label "SE" format "x(03)"
    movim.emite column-label "Emitente" format ">>>>>>"
    vdesti      column-label "Desti" format ">>>>>>>>>>"
    vmovqtm     format "->>>>9" column-label "Quant"
    movim.movpc format ">,>>9.99" column-label "Valor"
    sal-atu     format "->>>>9" column-label "Saldo" 
    with frame f-val screen-lines - 11 down overlay
                                 ROW 8 CENTERED color white/gray width 80.
                                 
form sal-ant label "Saldo Anterior" format "->>>>9"
     t-ent   label "Ent" format ">>>>>9"
     t-sai   label "Sai" format ">>>>>9"
     estoq.estatual label "Saldo Atual" format "->>>>9"
     with frame f-sal centered row screen-lines side-label no-box
                                        color white/red overlay.

def buffer bmovim for movim.
def var vdatamov as date.

def var vproini as int.
def var varquivo as char.

def buffer cestoq for estoq.
def var vdt-aux as date.

def temp-table tt-produ 
    field etbcod like estab.etbcod
    field procod like produ.procod
    index i1 etbcod procod.

def var log-caminho as char.
def var quem-processar as char.
def var q-entra as int.
def var q-i as int.
def var q-a as int.
def temp-table tt-etbpro
    field etbcod like estab.etbcod 
    index i1 etbcod.
def var dt-aux as date.

def var vmovtdc like plani.movtdc.
def var vetbnot like plani.etbcod.
def var vemite like plani.emite.
def var vserie like plani.serie.
def var vnumnot like plani.numero.

for each tt-produ: delete tt-produ. end.

if sparam = ""
then do:
    find first tbcntgen where tbcntgen.etbcod = 1038 no-lock no-error.
    if not avail tbcntgen  or 
        (tbcntgen.validade <> ? and
        tbcntgen.validade < today)
    then do:
        message "Controle para INFORMATIVO nao cadastrado ou desativado".
        pause 0.
        return.
    end.
    log-caminho = acha("LOG",tbcntgen.campo3[3]).

    varqlog = log-caminho + "removest20141.log".

    output to value(varqlog) append.
        put "Inicio: " string(today,"99/99/9999") " " string(time,"hh:mm:ss")
        skip.
    output close.    

    quem-processar = acha("PROCESSAR",tbcntgen.campo3[3]).
    q-entra = num-entries(quem-processar,";").
    do q-i = 1 to q-entra:
        if num-entries(entry(q-i,quem-processar,";"),"a") = 1
        then do:
            create tt-etbpro.
            tt-etbpro.etbcod = int(entry(q-i,quem-processar,";")).
        end.
        else if num-entries(entry(q-i,quem-processar,";"),"a") = 2
        then do:
            do q-a = int(entry(1,entry(q-i,quem-processar,";"),"a")) to
              int(entry(2,entry(q-i,quem-processar,";"),"a"))
              :
                create tt-etbpro.
                tt-etbpro.etbcod = q-a.  
            end.      
        end.     
    end.
    output to value(varqlog) append.
    put "Parametro: " tbcntgen.campo3[3] format "x(70)" skip.
    output close.    

    varquivo = "/admcom/relat/removest20141_" +
                string(vetbcod,"999") + "_" + 
                string(today,"99999999") + "_" +
                string(time) + ".csv".
 

    if time > 43200 and
       time < 86400
    then dt-aux = today.
    else dt-aux = today - 1.

    output to value(varqlog) append.
        put "Data auxiliar: " string(dt-aux,"99/99/9999")
        skip.
    output close.


    for each tt-etbpro no-lock:
        for each produ no-lock:
            for each movim where
                 movim.procod = produ.procod and
                 movim.emite  = tt-etbpro.etbcod and
                 movim.datexp >= dt-aux   
                   no-lock:
                find first tt-produ where
                   tt-produ.etbcod = tt-etbpro.etbcod and
                   tt-produ.procod = movim.procod
                   no-error.
                if not avail tt-produ
                then do:           
                    create tt-produ.
                    assign
                        tt-produ.etbcod = tt-etbpro.etbcod
                        tt-produ.procod = movim.procod
                        .
                end.
            end.
            for each movim where
                 movim.procod = produ.procod and
                 movim.desti  = tt-etbpro.etbcod and
                 movim.datexp >= dt-aux   
                   no-lock:
                find first tt-produ where
                   tt-produ.etbcod = tt-etbpro.etbcod and
                   tt-produ.procod = movim.procod
                   no-error.
                if not avail tt-produ
                then do:           
                    create tt-produ.
                    assign
                        tt-produ.etbcod = tt-etbpro.etbcod
                        tt-produ.procod = movim.procod
                        .
                end.
            end.
        end.
    end.
end. /*sparam = ""*/
else do:
    if acha("NOTAFISCAL",sparam) <> ? and
       acha("NOTAFISCAL",sparam) = "SIM" 
    then do:
        if acha("MOVTDC",sparam) <> ?
        then vmovtdc = int(acha("MOVTDC",sparam)).
        if acha("ETBCOD",sparam) <> ?
        then vetbnot = int(acha("ETBCOD",sparam)).
        if acha("EMITE",sparam) <> ?
        then vemite = int(acha("EMITE",sparam)).
        if acha("SERIE",sparam) <> ?
        then vserie = acha("SERIE",sparam).
        if acha("NUMERO",sparam) <> ?
        then vnumnot = int(acha("NUMERO",sparam)).
        find plani where
             plani.movtdc = vmovtdc and
             plani.etbcod = vetbnot and
             plani.emite = vemite and
             plani.serie = vserie and
             plani.numero = vnumnot
             no-lock no-error.
        if not avail plani then next.
        create tt-etbpro.
        tt-etbpro.etbcod = vetbnot.
        dt-aux = plani.datexp.
        for each movim where movim.etbcod = plani.etbcod and
            movim.placod = plani.placod and
            movim.movtdc = plani.movtdc and
            movim.movdat = plani.pladat
            no-lock:
            find first tt-produ where
                   tt-produ.etbcod = movim.etbcod and
                   tt-produ.procod = movim.procod
                   no-error.
            if not avail tt-produ
            then do:           
                create tt-produ.
                assign
                    tt-produ.etbcod = movim.etbcod
                    tt-produ.procod = movim.procod
                    .
            end.
        end.    
    end.
    if acha("PRODUTO",sparam) <> ?  and
       acha("PRODUTO",sparam) = "SIM"
    then do:
        if acha("PROCOD",sparam) <> ?
        then vprocod = int(acha("PROCOD",sparam)).
        if acha("ETBCOD",sparam) <> ?
        then vetbnot = int(acha("ETBCOD",sparam)).
        if vetbnot <> ? and vetbnot > 0 and
           vprocod <> ? and vprocod > 0
        then do:
            create tt-etbpro.
            tt-etbpro.etbcod = vetbnot.
            create tt-produ.
            assign
                    tt-produ.etbcod = vetbnot
                    tt-produ.procod = vprocod
                    .
            vatu-est = no.
        end.
        dt-aux = date(month(today),01,year(today)).
     end. 
end.
def buffer destoq for estoq.    

for each tt-etbpro no-lock:
    vtotmovim = 0.
    vtotgeral = 0.
    sal-atu = 0.
    sal-ant = 0.
    vsalant = 0.
 
    vetbcod = tt-etbpro.etbcod.
    find estab where estab.etbcod = vetbcod no-lock no-error.
    if not avail estab then next.
 
    if sparam = ""
    then do:
        output to value(varquivo) append.
        put skip(3) "Filial: " string(vetbcod,">>9") skip(1).
        output close.
    end.
    for each tt-pro: delete tt-pro. end.
    
    create tt-pro.
    tt-pro.etbcod = estab.etbcod.

    for each tt-produ where
             tt-produ.etbcod = tt-etbpro.etbcod
             no-lock:
            
        vdata1 = dt-aux.
        if day(vdata1) <> 1
        then vdata1 = date(month(vdata1),01,year(vdata1)).
        vdata2 = today.       

        vprocod = tt-produ.procod.
        

        find produ where produ.procod = vprocod no-lock no-error.
        if not avail produ then next.
    
        vproini = vprocod.
        vdt = vdata1.
    
        vdisp = no.
        for each tt-saldo : delete tt-saldo. end.
        
        
        run /admcom/progr/movest10.p.

        find first cestoq where cestoq.etbcod = vetbcod and
                              cestoq.procod = vprocod
                              no-lock no-error.

        if avail cestoq 
        then do:
            if cestoq.estatual <> sal-atu
            then do:
                vdt-aux = vdata1.

                find last   coletor where 
                    coletor.etbcod = vetbcod and
                    coletor.procod = vprocod no-lock no-error.
                disp coletor. pause.
                if avail coletor
                then vdata1 =
                     date(month(coletor.coldat),01,year(coletor.coldat)).
                else vdata1 = date(01,01,year(today)).
                                 
                for each tt-saldo : delete tt-saldo. end.
                run /admcom/progr/movest10.p.
                vdata1 = vdt-aux.
          
                if cestoq.estatual <> sal-atu
                then do:
                    vdata1 = date(01,01,year(today) - 3).
                                 
                    for each tt-saldo : delete tt-saldo. end.
                    run /admcom/progr/movest10.p.
                    vdata1 = vdt-aux.
                end.    
                if cestoq.estatual = sal-atu
                then do:
                    for each tt-saldo where tt-saldo.procod = produ.procod.
                        find hiest where
                             hiest.etbcod = tt-saldo.etbcod and
                             hiest.procod = tt-saldo.procod and
                             hiest.hiemes = tt-saldo.mes-cto and
                             hiest.hieano = tt-saldo.ano-cto
                             no-error.
                        if not avail hiest
                        then do:
                                                                                                           create hiest.
                            assign
                                hiest.etbcod = tt-saldo.etbcod
                                hiest.procod = tt-saldo.procod
                                hiest.hiemes = tt-saldo.mes-cto
                                hiest.hieano = tt-saldo.ano-cto
                                hiest.procod = tt-saldo.procod
                                    .
                                    

                        end.
                        if tt-saldo.sal-atu <> hiest.hiestf
                        then do:
                            if vatu-est
                            then do on error undo:
                                hiest.hiestf = tt-saldo.sal-atu
                                .
                                find current hiest no-lock.
                            end. 
                            else do:  
                                disp 
                                    tt-saldo.etbcod  label "Filial"
                                    tt-saldo.procod  label "Produto"
                                    tt-saldo.ano     label "Ano"
                                    tt-saldo.mes     label "Mes"
                                    tt-saldo.sal-ant 
                                    tt-saldo.qtd-ent 
                                    tt-saldo.qtd-sai 
                                    tt-saldo.sal-atu
                                    hiest.hiestf      label "Hiestf"
                                    cestoq.estatual   label "Estatual"
                                    sal-atu           label "Saldo"
                                    with 1 column.
                                pause .

                            end.                    
                        end.
                    end.    
                end.
                else if cestoq.estatual <> sal-atu
                then do:
                    
                    if vatu-est 
                    then do on error undo:
                        find first destoq where destoq.etbcod = vetbcod and
                              destoq.procod = vprocod
                              no-error.
                        destoq.estatual = sal-atu.
                        find current destoq no-lock.
                        
                        for each tt-saldo where tt-saldo.procod = produ.procod.
                            find hiest where
                             hiest.etbcod = tt-saldo.etbcod and
                             hiest.procod = tt-saldo.procod and
                             hiest.hiemes = tt-saldo.mes-cto and
                             hiest.hieano = tt-saldo.ano-cto
                             no-error.
                             if not avail hiest
                             then do:
                                create hiest.
                                assign
                                    hiest.etbcod = tt-saldo.etbcod
                                    hiest.procod = tt-saldo.procod
                                    hiest.hiemes = tt-saldo.mes-cto
                                    hiest.hieano = tt-saldo.ano-cto
                                    .
                            end.        
                            if tt-saldo.sal-atu <> hiest.hiestf
                            then do:
                                if vatu-est
                                then do on error undo:
                                    hiest.hiestf = tt-saldo.sal-atu
                                    .
                                    find current hiest no-lock.
                                end. 
                                else do:  
                                
                                    disp 
                                    tt-saldo.etbcod  label "Filial"
                                    tt-saldo.procod  label "Produto"
                                    tt-saldo.ano     label "Ano"
                                    tt-saldo.mes     label "Mes"
                                    tt-saldo.sal-ant 
                                    tt-saldo.qtd-ent 
                                    tt-saldo.qtd-sai 
                                    tt-saldo.sal-atu
                                    hiest.hiestf      label "Hiestf"
                                    cestoq.estatual   label "Estatual"
                                    sal-atu           label "Saldo"
                                    with 1 column.
                                    pause .
                                
                                end.                    
                            end.
                        end.
                    end.          


                    find last bmovim where bmovim.procod = produ.procod and
                                       bmovim.etbcod = vetbcod
                                       no-lock no-error.
                    if avail bmovim
                    then vdatamov = bmovim.datexp.
                    else vdatamov = ?.
                
                    assign
                        tt-pro.d-pro = tt-pro.d-pro + 1
                        tt-pro.d-ant = tt-pro.d-ant + sal-ant
                        tt-pro.d-ent = tt-pro.d-ent + t-ent
                        tt-pro.d-sai = tt-pro.d-sai + t-sai
                        tt-pro.d-atu = tt-pro.d-atu + sal-atu
                        tt-pro.d-adm = tt-pro.d-adm + cestoq.estatual
                        .
 
                    vprimeiro = vprimeiro + 1.
                
                    if sparam = ""
                    then do:
                    output to value(varquivo) append.
                    if vprimeiro = 1
                    then put "CODIGO;DESCRICAO;CADASTRO;ULTIMA MOV;
                        SALDO ANTERIOR;ENTRADAS;SAIDAS;SALDO ATUAL;SALDO                         ADMCOM;DIFERENCA"
                        skip.
                    assign
                        vestatual = string(cestoq.estatual)
                        vsalatual = string(sal-atu)  
                        vdiferest = string(cestoq.estatual - sal-atu)
                        vdiferest = replace(vdiferest,",","")
                        vdiferest = replace(vdiferest,".",",")
                        vestatual = replace(vestatual,",","")
                        vestatual = replace(vestatual,".",",")
                        vsalatual = replace(vsalatual,",","")
                        vsalatual = replace(vsalatual,".",",")
                        .
                        
                    put produ.procod format ">>>>>>>>9"
                        ";"
                        produ.pronom ";"
                        produ.prodtcad ";"
                        vdatamov ";"
                        sal-ant         format "->>>>>>>>>9" ";"
                        t-ent           format "->>>>>>>>>9" ";"
                        t-sai           format "->>>>>>>>>9" ";"
                        sal-atu         format "->>>>>>>>>9" ";"
                        cestoq.estatual format "->>>>>>>>>9" ";"
                        sal-atu - cestoq.estatual format "->>>>>>>>>9"
                        skip.
                    
                    output close.    
                    end.
                end. 
                vdata1 = vdt-aux.                     
            end.
        end.
        assign
                    tt-pro.q-pro = tt-pro.q-pro + 1
                    tt-pro.q-ant = tt-pro.q-ant + sal-ant
                    tt-pro.q-ent = tt-pro.q-ent + t-ent
                    tt-pro.q-sai = tt-pro.q-sai + t-sai
                    tt-pro.q-atu = tt-pro.q-atu + sal-atu
                    tt-pro.q-adm = tt-pro.q-adm + cestoq.estatual
                    .
    end.    
    if sparam = ""
    then do:
    output to value(varquivo) append.
    put skip(2).
    put " ;Intens processados ;" tt-pro.q-pro format "->>>>>>>9" skip 
            " ;Saldo Anterior     ;" tt-pro.q-ant format "->>>>>>>9" skip
            " ;Total de entradas  ;" tt-pro.q-ent format "->>>>>>>9" skip
            " ;Total de saidas    ;" tt-pro.q-sai format "->>>>>>>9" skip
            " ;Saldo Atual        ;" tt-pro.q-atu format "->>>>>>>9" skip
            " ;Saldo ADMCOM       ;" tt-pro.q-adm format "->>>>>>>9" skip
            " ;Itens divergentes  ;" tt-pro.d-pro format "->>>>>>>9" skip
            " ;Saldo anterior divergentes;" tt-pro.d-ant format "->>>>>>>9"
            skip
            " ;Total entradas divergentes;" tt-pro.d-ent format "->>>>>>>9"
            skip
            " ;Total saidas divergentes  ;" tt-pro.d-sai format "->>>>>>>9"
            skip
            " ;Saldo atual divergentes   ;" tt-pro.d-atu format "->>>>>>>9"
            skip
            " ;Saldo ADMCOM divergentes  ;" tt-pro.d-adm format "->>>>>>>9"
            skip
            .
        
    output close.
    end.
end.
if sparam = ""
then do:    
output to value(varquivo) append.
put skip(2). 
put "FIM" skip.
output close.
end.

def var vaspas as char.
def var vassunto as char.
def var varqtexto as char.
def var vemail2 as char.

if sparam = ""
then do:
output to value(varqlog) append.
put "Arquivo gerado:" varquivo format "x(70)"
    skip.
output close.

varqtexto = "/admcom/relat/email" + string(time).
output to value(varqtexto).
put unformatted
    "Segue em anexo arquivo reprocessamento CD1 " skip(1)
     .
output close.

vaspas   = chr(34).

def var e-mail as char extent 10.


vassunto = "Recalculo-" + string(dt-aux,"99999999").

if search(varquivo) <> ?
then do:
    run /admcom/progr/envia_info_anexo.p(input "1038", input varqlog,
                input varquivo, input vassunto).
end.
        
/***
assign
        e-mail[1] = acha("email1",tbcntgen.campo3[1]) 
        e-mail[2] = acha("email2",tbcntgen.campo3[1])
        e-mail[3] = acha("email3",tbcntgen.campo3[1])
        e-mail[4] = acha("email4",tbcntgen.campo3[1])
        e-mail[5] = acha("email5",tbcntgen.campo3[1])
        e-mail[6] = acha("email6",tbcntgen.campo3[1])
        .

def var i as int.
do i = 1 to 6:
    if e-mail[i] <> "" and
           e-mail[i] <> "?"
    then do: 
        vemail2 = e-mail[i].
        
        unix silent value(
                "echo | mutt -s " + 
            vaspas + vassunto + vaspas +
            " -a " + varquivo +
            " -i " + varqtexto +
            " -- " + vemail2 ).
    end.
end.
***/

output to value(varqlog) append.
put "FIM: " string(today,"99/99/9999") " " string(time,"hh:mm:ss")
    skip.
output close.

end.
procedure ver-hiest-ultimo:
    def var p-mes as int.
    def var p-ano as int.
    find last hiest where hiest.etbcod = vetbcod      and
                          hiest.procod = produ.procod and
                          hiest.hiemes < month(vdata1) and
                          hiest.hieano = year(vdata1) and
                          hiest.hiestf <> 0 no-lock no-error.
    if not avail hiest
    then do:
        
        find last hiest where hiest.etbcod = vetbcod      and
                              hiest.procod = produ.procod and
                              hiest.hieano = year(vdata1) - 1 and
                              hiest.hiestf <> 0
                              no-lock no-error.
        if not avail hiest
        then do:
            find last hiest where hiest.etbcod = vetbcod      and
                                  hiest.procod = produ.procod and
                                  hiest.hieano = year(vdata1) - 2 and
                                  hiest.hiestf <> 0
                                        no-lock no-error.
            if not avail hiest
            then do:
                find last hiest where hiest.etbcod = vetbcod      and
                                  hiest.procod = produ.procod and
                                  hiest.hieano < year(vdata1) - 2 and
                                  hiest.hiestf <> 0
                                        no-lock no-error.
                if not avail hiest
                then do:

                find last hiest where hiest.etbcod = vetbcod      and
                          hiest.procod = produ.procod             and
                          hiest.hiemes = month(vdata1)             and
                          hiest.hieano = year(vdata1) no-lock no-error.
                if not avail hiest
                then assign 
                            p-mes    = month(vdata1) 
                            p-ano    = year(vdata1).
            
                else assign 
                            p-mes    = hiest.hiemes - 1
                            p-ano    = hiest.hieano.

                end.
                else assign 
                        p-mes    = hiest.hiemes
                        p-ano    = hiest.hieano.
            end.
            else assign 
                        p-mes    = hiest.hiemes
                        p-ano    = hiest.hieano.
        end.
        else assign 
                    p-mes    = hiest.hiemes
                    p-ano    = hiest.hieano.
    end.
    else assign 
                p-mes    = hiest.hiemes
                p-ano    = hiest.hieano.

    vdata1 = date(if p-mes = 12 then 1 else p-mes + 1,01,
                  if p-mes = 12 then p-ano + 1 else p-ano).
                  
end procedure.
