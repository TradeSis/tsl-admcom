/********** parametros ************
Recebe patametro atraves da variavel sparam do sitemas definida no admcab.
sparam = "" le parametros do informativo 1038 
sparam = "NOTAFISCAL=SIM|" indica se reprocessamento a partir de uma NF
         "MOVTDC=|ETBCOD=|EMITE=|SERIE=|NUMERO=|"
sparam = "PRODUTO=SIM|" indica se reprocessamento a partir de um produto
         "PROCOD=|ETBCOD=|"
sparam = "ATUALIZAR=SIM|" indica se atualiza estoque estatual e hiest sivergente
         "CONFIRMA=SIM|"  indica se pede confirmação para atualizar             ~              estoque.estatual e hiest.hiestf
         "DATAINICIO=|"   indica data inicio
         "RELATORIO=SIM|" indica gerar relatorio com divergencias
                         solicita caminho e nome
sparam = "MOVIMENTO=SIM|" indica se reprocessamento por tipo de movimento
         "TIPMOV=|ETBCOD=|DTAINCLUINI=|DATAINCLUFIM=|"
****************************/
     
{/admcom/progr/admcab-batch.i new}

if program-name(2) matches "*runcode*"
then do:
    bell.
    message color red/with
            "Programa critico..." skip    
            "Favor nao executar desta maneira."
            view-as alert-box
            .
    return.
end.            

{/admcom/progr/extrato11-def.i new}
def var vatu-est as log.
vatu-est = no.
vatu-est = yes.
def var varqlog as char.

pause 0 before-hid.
def var vtotdia like plani.platot.
def var vtot  like movim.movpc.
def var vtotg like movim.movpc.
def var vtotgeral like plani.platot.
def var vtotal like plani.platot.
def var vtoticm like plani.icms.
def var vtotmovim   like movim.movpc.
def var vsalant   like estoq.estatual.
def var vprimeiro as int.
def var vestatual as char.
def var vsalatual as char.
def var vdiferest as char.
def var vatualizar as char.
def var vrelatorio as char.
def var vconfirmar as char.
def var vdatainicio as date.
             
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

def var vdti as date.
def var vdtf as date.
def var vmovtdc like plani.movtdc.
def var vetbnot like plani.etbcod.
def var vemite like plani.emite.
def var vserie like plani.serie.
def var vnumnot like plani.numero.
def var vnomarq as char.
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

    varquivo = "/admcom/relat/removest20142_" +
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
    assign
        dt-aux = 01/01/2000
        vrelatorio = "SIM"
        vatualizar = "NAO"
        vconfirmar = "NAO"
        .
end. /*sparam = ""*/
else do:
    if acha("MOVIMENTO",sparam) <> ? and
       acha("MOVIMENTO",sparam) = "SIM" 
    then do:
        if acha("MOVTDC",sparam) <> ?
        then vmovtdc = int(acha("MOVTDC",sparam)).
        if acha("ETBCOD",sparam) <> ?
        then vetbnot = int(acha("ETBCOD",sparam)).
        if acha("DATAINCLUINI",sparam) <> ?
        then vdti = date(acha("DATAINCLUINI",sparam)).
        if acha("DATAINCLUFIM",sparam) <> ?
        then vdtf = date(acha("DATAINCLUFIM",sparam)).
        
        create tt-etbpro.
        tt-etbpro.etbcod = vetbnot.
        dt-aux = vdtf.
        
        for each plani where plani.etbcod = vetbnot and
                             plani.movtdc = vmovtdc and
                             plani.dtinclu >= vdti and
                             plani.dtinclu <= vdtf
                             no-lock.
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
    end.
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
        if not avail plani then return.
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
     if acha("CONFIRMAR",sparam) <> ?
     then vconfirmar = acha("CONFIRMAR",sparam).
     else vconfirmar = "".
     if acha("ATUALIZAR",sparam) <> ?
     then vatualizar = acha("ATUALIZAR",sparam).
     else vatualizar = "".
     if acha("RELATORIO",sparam) <> ?
     then vrelatorio = acha("RELATORIO",sparam).
     else vrelatorio = "".
     if acha("DATAINICIO",sparam) <> ?
     then dt-aux = date(acha("DATAINICIO",sparam)).
     if dt-aux = ?
     then dt-aux = 01/01/2000.
     if vrelatorio = "SIM"
     then repeat on endkey undo:
        varquivo = "/admcom/relat/removest20142_" +
                string(vetbcod,"999") + "_" + 
                string(today,"99999999") + "_" +
                string(time) + ".csv".
        update varquivo format "x(60)" label "Arquivo"
            with frame f-arquivo 1 down side-label width 80.
            
        if varquivo = ""
        then undo.
        leave.
     end.
end.
def buffer destoq for estoq. 
   
vdata1 = dt-aux.
if day(vdata1) <> 1
then vdata1 = date(month(vdata1),01,year(vdata1)).
vdata2 = today.  

def buffer cprodu for produ.

for each tt-etbpro no-lock:
    vtotmovim = 0.
    vtotgeral = 0.
    sal-atu = 0.
    sal-ant = 0.
    vsalant = 0.
 
    vetbcod = tt-etbpro.etbcod.
    find estab where estab.etbcod = vetbcod no-lock no-error.
    if not avail estab then next.
 
    if sparam = "" or vrelatorio = "SIM"
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
        find cprodu where cprodu.procod = tt-produ.procod no-lock no-error.
        if not avail cprodu then next.
            
        vprocod = tt-produ.procod.

        do on error undo:
            for each hiest where hiest.etbcod = vetbcod and
                                 hiest.procod = vprocod and
                                 hiest.hiemes = 0
                                 :
                delete hiest.
            end.                     
        end.     

        vproini = vprocod.
        vdt = vdata1.
    
        vdisp = no.
 
        for each tt-saldo: delete tt-saldo. end.
        for each tt-movest: delete tt-movest. end.
         
        run /admcom/progr/movest11-ctbhie.p.

        
        find first cestoq where cestoq.etbcod = vetbcod and
                              cestoq.procod = vprocod
                              no-lock no-error.

        if avail cestoq 
        then do:
            if cestoq.estatual <> sal-atu
            then do:
                if vatualizar = "SIM"
                then do:
                    find first destoq where destoq.etbcod = vetbcod and
                              destoq.procod = vprocod
                              no-error.
                    for each tt-saldo where tt-saldo.procod = vprocod
                            and tt-saldo.ano-cto > 0.
                        find first hiest where
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
                        then do on error undo:
                             hiest.hiestf = tt-saldo.sal-atu .
                             find current hiest no-lock.
                        end. 
                    end.
                    sresp = yes.
                    if vconfirmar = "SIM"
                    then do:
                        disp vprocod                  label "Codigo"
                             sal-ant                  label "Saldo Aterior  "
                             format "->>>>>9"
                             t-ent                    label "Entradas       "
                             format "->>>>>9"
                             t-sai                    label "Saidas         "
                             format "->>>>>9"
                             sal-atu                  label "Saldo Movimento" 
                             format "->>>>>9"
                             cestoq.estatual          label "Estoque Atual  "
                             format "->>>>>9"
                             (sal-atu - cestoq.estatual) label "Diferenca      "
                             format "->>>>>9"
                            with side-label 1 column.
                        /*message "Confirma Atualizar?" update sresp.*/
                        message "Atualizando...". pause 2.
                    end.
                    else sresp = yes.
                         
                    if sresp 
                    then do on error undo:
                       destoq.estatual = sal-atu.
                       find current destoq no-lock.
                    end.
                end.
                
                find last bmovim where bmovim.procod = vprocod and
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
                    vprimeiro = vprimeiro + 1.
                
                if sparam = "" or vrelatorio = "SIM"
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
                        
                    put cprodu.procod format ">>>>>>>>9" ";"
                        cprodu.pronom ";"
                        cprodu.prodtcad ";"
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
            else do:
                if vatualizar = "SIM"
                then do:
                    for each tt-saldo where tt-saldo.procod = vprocod
                        and tt-saldo.ano-cto > 0.
                        find first hiest where
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
                        then do on error undo:
                            hiest.hiestf = tt-saldo.sal-atu .
                            find current hiest no-lock.
                        end.
                    end.
                    if vconfirmar = "SIM"
                    then do:
                        bell.
                        message 
                            "Nenhuma divergencia encontrada."
                            .
                            pause 2.
                    end.
                end.    
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
    if sparam = ""  or vrelatorio = "SIM"
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
if sparam = ""  or vrelatorio = "SIM"
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
    /**
    if search(varquivo) <> ?
    then do:
        run /admcom/progr/envia_info_anexo.p(input "1038", input varqlog,
                input varquivo, input vassunto).
    end.
    **/    
    output to value(varqlog) append.
    put "FIM: " string(today,"99/99/9999") " " string(time,"hh:mm:ss")
        skip.
    output close.

end.

return.
