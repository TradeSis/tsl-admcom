
{admcab.i new}   

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
             
              /**** Campo usado para guardar o no. da planilha ****/
   
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

repeat:
    vtotmovim = 0.
    vtotgeral = 0.
    sal-atu = 0.
    sal-ant = 0.
    vsalant = 0.
 
    clear frame f-val all.
    update vetbcod label " Filial" with frame f-pro.
    find estab where estab.etbcod = vetbcod no-lock.
    disp estab.etbnom no-label with frame f-pro.
    
    update vdata1 label "Data Inicio" colon 55
           with frame f-pro.
    if day(vdata1) <> 1
    then vdata1 = date(month(vdata1),01,year(vdata1)).
    vdata2 = today.       
    disp  vdata1 vdata2 no-label with frame f-pro.

    if vdata1 < 01/01/11 and vetbcod < 990
    then vdata1 = 01/01/11.
    disp vdata1 with frame f-pro.
        
    update vprocod
               with frame f-pro centered width 80 color blue/cyan 
                            row 3 side-label.
    if vprocod > 0
    then do:
        find produ where produ.procod = vprocod no-lock.
    
        disp produ.pronom no-label with frame f-pro.
    end.
    else disp "Todos os produtos" @ produ.pronom with frame f-pro.
    
    vproini = vprocod.
    vdt = vdata1.
    
    vdisp = no.

    varquivo = "/admcom/relat/recalmov_" +
                string(vetbcod,"999") + "_" + 
                string(vproini,"999999999") + "_" +
                string(time) + ".csv".
                
    update varquivo format "x(78)" 
        label "Arquivo para salvar divergencias".
    
    for each estab where (if vetbcod > 0
                          then estab.etbcod = vetbcod else true)
                          no-lock:
        vetbcod = estab.etbcod.
        disp "Processando.... " vetbcod
            with frame f-disp 1 down no-label.
        pause 0.

        create tt-pro.
        tt-pro.etbcod = estab.etbcod.
        
        for each produ where (if vproini > 0
                              then produ.procod = vproini else true)
                          no-lock:
            
            vprocod = produ.procod.
            
            disp vprocod format ">>>>>>>>>9" with frame f-disp.
            pause 0.
            /*
            vdata1 = produ.prodtcad - 30.
            */
            vdata2 = today.

            if vdata1 < 01/01/11 and vetbcod < 990
            then vdata1 = 01/01/11.
            
            disp vdata1 vdata2 with frame f-disp.
            pause 0.
            

            run movest10.p.

            find first cestoq where cestoq.etbcod = vetbcod and
                              cestoq.procod = vprocod
                              no-lock no-error.

            if avail cestoq 
            then do:
                /*
                if sal-atu = 0 and cestoq.estatual <> 0
                then do:
                    vdt-aux = vdata1.
                    run ver-hiest-ultimo.
                    run movest10.p.
                    vdata1 = vdt-aux.
                end.
                */
            if cestoq.estatual <> sal-atu
            then do:
                find last bmovim where bmovim.procod = produ.procod and
                                       bmovim.emite = vetbcod
                                       no-lock no-error.
                if avail bmovim
                then vdatamov = bmovim.datexp.
                else vdatamov = ?.
                find last bmovim where bmovim.procod = produ.procod and
                                       bmovim.desti = vetbcod
                                       no-lock no-error.
                if avail bmovim and
                    (vdatamov = ? or vdatamov < bmovim.datex)
                then vdatamov = bmovim.datexp.    


                assign
                    tt-pro.d-pro = tt-pro.d-pro + 1
                    tt-pro.d-ant = tt-pro.d-ant + sal-ant
                    tt-pro.d-ent = tt-pro.d-ent + t-ent
                    tt-pro.d-sai = tt-pro.d-sai + t-sai
                    tt-pro.d-atu = tt-pro.d-atu + sal-atu
                    tt-pro.d-adm = tt-pro.d-adm + cestoq.estatual
                    .
 
                vprimeiro = vprimeiro + 1.
                
                output to value(varquivo) append.
                if vprimeiro = 1
                then put "CODIGO;DESCRICAO;CADASTRO;ULTIMA MOV;SALDO ANTERIOR;ENTRADAS;SAIDAS;SALDO ATUAL;SALDO ADMCOM;DIFERENCA"
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
            else if vproini > 0
            then do:
                message color red/with
                "Slado anterior: " sal-ant skip
                "      Entradas: " t-ent skip
                "        Saidas: " t-sai skip
                "   Saldo Atual: " sal-atu   skip
                view-as alert-box title " Sem divergencias "
                .
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
        end.
        find first tt-pro where
                           tt-pro.etbcod = estab.etbcod
                           no-error.
 
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

    if search(varquivo) <> ?
    then do:
        output to value(varquivo) append.
        put skip(2). 
        put "FIM" skip.
        output close.

        message color red/with
            "Divergencias salvas em " varquivo
            view-as alert-box.
    end.
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
