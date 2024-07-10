{admcab.i}

def var vetbcod like estab.etbcod.
def var vdti as date format "99/99/9999".
def var vdtf as date format "99/99/9999".
def var vescolha as char format "x(15)" extent 2
    init["Sintetico","Analitico"].
def var vindex as int.    
def var vtt-venda as dec.
def var vcatcod as int.
def var vqtd-cup as int.
def var v-c as int.
def var vpromocupfa as char.
def var vnumcup as int.
def var dnumcup as int.
def var vseq-cupom-promo as char.
def var vqt-tot as int.
def var vbis as log.
def var vprocod like produ.procod.
 
update vetbcod label "Filial"
    with frame f1 side-label width 80.

if vetbcod > 0
then do:
    find estab where estab.etbcod = vetbcod no-lock.
    disp estab.etbnom no-label with frame f1.
end.
    
update vdti at 1 label "Data inicial"
       vdtf label "Data final"
        with frame f1.

disp vescolha with frame fesc 1 down side-label no-label centered.
choose field vescolha with frame fesc.
vindex = frame-index.
def temp-table tt-cupom
    field etbcod like estab.etbcod
    field catcod like produ.catcod
    field qtdcup as int
    index i1 etbcod catcod
     .
def temp-table tt-venda
    field etbcod like estab.etbcod
    field numero like plani.numero
    field pladat like plani.pladat
    field protot like plani.protot
    field catcod like produ.catcod
    field calcup as int
    field qtdcup as int
    field fincod like finan.fincod
    field lplbis  as log
    field clicod like clien.clicod
    field dtcad  like clien.dtcad
    field procod like produ.procod
    index i1 etbcod numero.

def var vdata as date.

for each estab where
     (if vetbcod > 0 then estab.etbcod = vetbcod else true) and
     estab.etbcod < 200
     no-lock.
     disp "Processando... " estab.etbcod
        with frame fdd 1 down centered row 10 no-box
        color message no-label.
     pause 0.   
     do vdata = vdti to vdtf:
        disp vdata with frame fdd.
        pause 0.
        for each plani where plani.etbcod = estab.etbcod and
                             plani.movtdc = 5 and
                             plani.pladat = vdata
                             no-lock:
            find clien where clien.clicod = plani.desti no-lock no-error.
            
            if acha("PROMOCUPFA",plani.notobs[1]) <> ?
            then vpromocupfa = acha("PROMOCUPFA",plani.notobs[1]).
            else vpromocupfa = ";". 
            
            assign
                vcatcod = 0
                vtt-venda = 0
                vtt-venda = plani.protot
                vqtd-cup = 0
                vprocod = 0
                .
            
            run cal-cup-fa.

            if vqtd-cup > 0
            then do:
                find first tt-cupom where tt-cupom.etbcod = estab.etbcod and
                                      tt-cupom.catcod = vcatcod 
                                      no-error.
                if not avail tt-cupom
                then do:
                    create tt-cupom.
                    assign
                        tt-cupom.etbcod = estab.etbcod 
                        tt-cupom.catcod = vcatcod
                        .
                end.
                tt-cupom.qtdcup = tt-cupom.qtdcup + vqtd-cup.

                create tt-venda.
                assign
                    tt-venda.etbcod = plani.etbcod
                    tt-venda.numero = plani.numero
                    tt-venda.pladat = plani.pladat
                    tt-venda.protot = vtt-venda
                    tt-venda.catcod = vcatcod
                    tt-venda.calcup = vqtd-cup
                    tt-venda.qtdcup = int(entry(1,vpromocupfa,";"))
                    tt-venda.fincod = plani.pedcod
                    tt-venda.lplbis = vbis
                    tt-venda.clicod = plani.desti
                    tt-venda.dtcad  = if avail clien then clien.dtcad else ?
                    tt-venda.procod = vprocod
                    . 
            end.        
        end.
    end.
end.                        

def var varquivo as char.

if opsys = "UNIX"
then varquivo = "/admcom/relat/relcupfa1." + string(time).
else varquivo = "l:~\relat~\relcupfa1." + string(time).

{mdadmcab.i 
        &Saida     = "value(varquivo)" 
        &Page-Size = "63" 
        &Cond-Var  = "120"  
        &Page-Line = "66"
        &Nom-Rel   = ""relcupfa1""  
        &Nom-Sis   = """SISTEMA ADMINISTRATIVO  SAO JERONIMO"""  
        &Tit-Rel   = """ CUPONS EMITIDOS PROMOCAO FINAL DE ANO """
        &Width     = "80"
        &Form      = "frame f-cabcab"}

disp with frame f1.
disp vescolha[vindex] label "Tipo" with side-label.
pause 0.

if vindex = 1
then for each tt-cupom where
              tt-cupom.catcod <> 81
              break by tt-cupom.etbcod:
        if first-of(tt-cupom.etbcod)
        then do:
            find estab where estab.etbcod = tt-cupom.etbcod no-lock.
            disp tt-cupom.etbcod column-label "Fil"
                 estab.etbnom no-label
                 with frame f-rel.
        end.
        disp tt-cupom.catcod column-label "Setor"
             tt-cupom.qtdcup column-label "Quantidade"
            (total by tt-cupom.etbcod)
             with frame f-rel down.
        down with frame f-rel.
    end.
else if vindex = 2
then for each tt-venda where
              tt-venda.catcod <> 81
            no-lock break by tt-venda.etbcod:
        disp tt-venda.etbcod column-label "Fil"
             tt-venda.numero column-label "Venda"   format ">>>>>>>>9"
             tt-venda.pladat column-label "DtVenda" format "99/99/9999"
             tt-venda.protot(total by tt-venda.etbcod) column-label "ProTot"
             tt-venda.catcod column-label "Cat"
             tt-venda.qtdcup(total by tt-venda.etbcod) column-label "Calc!Venda"
             tt-venda.calcup(total by tt-venda.etbcod) column-label "Calc!Relat"
             tt-venda.fincod column-label "Plano"
             tt-venda.lplbis column-label "Bis"
             tt-venda.clicod column-label "Ciente"
             tt-venda.dtcad  column-label "DtCadastro" format "99/99/9999"
             tt-venda.procod column-label "Produto"
             with frame f-rel1 down width 120.
        down with frame f-rel1.
    end.
    
output close.


if opsys = "UNIX"
then do:
    run visurel.p(varquivo,"").
end.
else do:
   {mrod.i}
end.

procedure cal-cup-fa:
    
    if vtt-venda >= 200 
    then do:
        vbis = no.
        if plani.pedcod = 110  or
           /*plani.pedcod = 111  or*/
           plani.pedcod = 112  or
           plani.pedcod = 113  or
           plani.pedcod = 115  or
           plani.pedcod = 116  or
           plani.pedcod = 120  or
           plani.pedcod = 121  or
           plani.pedcod = 125  or
           plani.pedcod = 126  or
           plani.pedcod = 310  or
           plani.pedcod = 312  or
           plani.pedcod = 313  or
           plani.pedcod = 314  or
           plani.pedcod = 315  or
           plani.pedcod = 316  or
           plani.pedcod = 317  or
           plani.pedcod = 318  or
           plani.pedcod = 320  or
           plani.pedcod = 321  or
           plani.pedcod = 323  or
           plani.pedcod = 324  or
           plani.pedcod = 325  or
           plani.pedcod = 326  or
           plani.pedcod = 410  or
           plani.pedcod = 418  or
           plani.pedcod = 421  or
           plani.pedcod = 422  or
           plani.pedcod = 613  or
           plani.pedcod = 614  or
           plani.pedcod = 617  or
           plani.pedcod = 716  or
           plani.pedcod = 718  or
           plani.pedcod = 721  or
           plani.pedcod = 722  or
           plani.pedcod = 723  or
           plani.pedcod = 724  or
           plani.pedcod =  15  or
           plani.pedcod =  17  or
           plani.pedcod =  21  or
           plani.pedcod =  24  or
           plani.pedcod =  42  or
           plani.pedcod =  43  or
           plani.pedcod =  66  or
           plani.pedcod =  67  or
           plani.pedcod =  68  or
           plani.pedcod =  69  or
           plani.pedcod =  76  or
           plani.pedcod =  77  or
           plani.pedcod =  80  or
           plani.pedcod =  89  or
           plani.pedcod =  90  or
           plani.pedcod =  91  or
           plani.pedcod =  98  or
           plani.pedcod =  100 or
           plani.pedcod =  122 or
           plani.pedcod =  123 or
           plani.pedcod =  124 or
           plani.pedcod =  200 or
           plani.pedcod =  201 or
           plani.pedcod =  202 or
           plani.pedcod =  322 or
           plani.pedcod =  414 or
           plani.pedcod =  419 or
           plani.pedcod =  424 or
           plani.pedcod =  426 or
           plani.pedcod =  514 or
           plani.pedcod =  517 or
           plani.pedcod =  519 or
           plani.pedcod =  523 or
           plani.pedcod =  524 or
           plani.pedcod =  525 or
           plani.pedcod =  530 or
           plani.pedcod =  531 or
           plani.pedcod =  610 or
           plani.pedcod =  612 or
           plani.pedcod =  717 or
           plani.pedcod =  610 or
           plani.pedcod =  710 or
           plani.pedcod =  510 or
           plani.pedcod =  612 or
           plani.pedcod =  714 or
           plani.pedcod =  414 or
           plani.pedcod =  615 or
           plani.pedcod =  515 or
           plani.pedcod =  717 or
           plani.pedcod =  417 or
           plani.pedcod =  720 or
           plani.pedcod =  420 or
           plani.pedcod =  620 or
           plani.pedcod =  520 or
           plani.pedcod =  622 or
           plani.pedcod =  522 or
           plani.pedcod =  626 or
           plani.pedcod =  526 or
           plani.pedcod =  725 or
           plani.pedcod =  525
        then vbis = yes.
       
        vtt-venda = 0.
        for each movim where movim.etbcod = plani.etbcod and
                         movim.placod = plani.placod and
                         movim.movtdc = plani.movtdc and
                         movim.movdat = plani.pladat
                         no-lock:
            find produ where produ.procod = movim.procod no-lock no-error.
            if not avail produ then next.
            vtt-venda = vtt-venda + (movim.movpc * movim.movqtm).
            if vcatcod = 0
            then vcatcod = produ.catcod.
            if vcatcod = 41 and
               produ.catcod = 31
            then vcatcod = produ.catcod. 
            
            if produ.procod = 558023 and plani.pedcod = 311
            then assign
                     vprocod = produ.procod   
                     vqtd-cup = vqtd-cup + 12.
            if produ.procod = 572647 and plani.pedcod = 526
            then assign
                    vprocod = produ.procod
                    vqtd-cup = vqtd-cup + 3.
            if produ.procod = 572697 and plani.pedcod = 100
            then assign
                    vprocod = produ.procod
                    vqtd-cup = vqtd-cup + 3.
            if produ.procod = 547261 and plani.pedcod = 311
            then assign
                    vprocod = produ.procod
                    vqtd-cup = vqtd-cup + 12. 
        end.           
        vqt-tot = int(substr(string(vtt-venda / 200,">>>9.999"),1,4)).
        if vbis = no 
        then vqtd-cup = vqtd-cup + vqt-tot.
        else vqtd-cup = vqtd-cup + (vqt-tot * 3). 
    end.
    
    if vqtd-cup > 0 and
       avail clien and 
       clien.dtcad = plani.pladat
    then vqtd-cup = vqtd-cup + 1.

end procedure.

