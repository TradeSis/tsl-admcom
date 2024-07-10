{/admcom/progr/admcab.i.ssh}

def var v-procod like produ.procod.
def var v-param as char.
def var v-etbcod like estab.etbcod.
/*v-param = os-getenv("teclar").
v-etbcod = int(substr(string(v-param),1,3)).
v-procod = int(substr(string(v-param),4,9)).
  */
v-etbcod = SETBCOD.  
def buffer bestoq for estoq.  
def var vlipqtd like liped.lipqtd.
def var vdata as date.
def buffer bpedid for pedid.
def var q as int.
def var v-entregar like liped.lipqtd.
def var vreserva-ecm    as int.
def temp-table tt-produ 
            field procod like produ.procod.

update v-procod with frame f side-label WIDTH 80.
find produ where produ.procod = v-procod no-lock no-error.
if not avail produ then undo.
disp produ.pronom no-label with frame f.

DISP "Aguarde processamento..."
     with frame f1 no-box 1 down.
     
create tt-produ.
tt-produ.procod = v-procod.


for each produaux where 
         produaux.nome_campo = "PRODUTO-EQUIVALENTE" AND
         produaux.valor_campo = string(v-procod)
         no-lock:
    create tt-produ.
    tt-produ.procod = produaux.procod .
end.                
def temp-table tt-estoq like estoq.
    
    for each tt-produ:
    v-procod = tt-produ.procod.
    find estoq where estoq.etbcod = 993 and
                     estoq.procod = v-procod no-lock no-error.
    if avail estoq
    then do:
        find bestoq where bestoq.etbcod = 900 and
                            bestoq.procod = v-procod no-lock no-error.
        create tt-estoq.
        buffer-copy estoq to tt-estoq.
        assign 
            tt-estoq.estpedven = 0
            tt-estoq.estpedcom = 0
            tt-estoq.estinvqtd = 0
            tt-estoq.estinvctm = 0
            tt-estoq.estloc = ""  .
        if avail bestoq and
                   bestoq.estatual > 0
        then tt-estoq.estatual = tt-estoq.estatual + bestoq.estatual.
          
        do vdata = today - 40 to today.
            for each liped where liped.pedtdc = 3
                             and liped.predt  = vdata
                             and liped.procod = estoq.procod no-lock:
                                         
                find pedid where pedid.etbcod = liped.etbcod and
                                 pedid.pedtdc = liped.pedtdc and
                                 pedid.pednum = liped.pednum no-lock no-error.
                if not avail pedid 
                then next.

                if pedid.sitped <> "E" and
                   pedid.sitped <> "L"
                then next.
                
                tt-estoq.estpedven = tt-estoq.estpedven + liped.lipqtd.
            
            end.
        end.

        for each liped where /*liped.etbcod = 86 and*/
                                 liped.procod = estoq.procod and
                                 liped.pedtdc = 1 and
                                 (liped.lipsit = "A" or
                                  liped.lipsit = "P") and
                                 (liped.predtf = ? or
                                 liped.predtf >= today - 30) no-lock,
              first pedid of liped where pedid.pedsit = yes and
                            pedid.sitped <> "F"  and
                            pedid.peddat > today - 180   no-lock:
                            
              find first bpedid where 
                        (bpedid.pedtdc = 4 or
                         bpedid.pedtdc = 6) and
                         bpedid.pedsit = yes and
                         bpedid.comcod = pedid.pednum
                         no-lock no-error.
              if avail bpedid
              then next.
              v-entregar = liped.lipqtd - liped.lipent.
              if v-entregar <= 0
              then next.
              tt-estoq.estpedcom = tt-estoq.estpedcom + v-entregar.
                            
              if pedid.peddtf = ?
              then do:
                tt-estoq.estloc = tt-estoq.estloc +
                    "SEM PREVISAO=" +
                    string(v-entregar,">>>9") + " | ".
              end.
              else if pedid.peddtf >= today
              then do:
                tt-estoq.estloc = tt-estoq.estloc +
                    string(pedid.peddtf,"99/99/9999") + "=" +
                    string(v-entregar,">>>9") + " | ".
              end.
              else do:
                tt-estoq.estloc = tt-estoq.estloc +
                    "Previsao estourada=" +
                    string(v-entregar,">>>9") + " | ".
              end.
        end.
        
        find bestoq where bestoq.etbcod = v-etbcod and
                            bestoq.procod = v-procod no-lock no-error.
        if avail bestoq
        then  do:
            find last movim where 
                      movim.etbcod = v-etbcod and
                      movim.movtdc = 5 and
                      movim.procod = bestoq.procod
                      no-lock no-error.
            tt-estoq.estinvqtd = bestoq.estatual.
            if avail movim
            then tt-estoq.estinvctm = movim.placod.
            else tt-estoq.estinvctm = 0.
        end.  
        else tt-estoq.estinvqtd = 0.
        
        run disponivel.p (v-procod, output vreserva-ecm).
        
        assign tt-estoq.estpedven = tt-estoq.estpedven + vreserva-ecm.

    end.
    end.

def temp-table tp-estoq like tt-estoq.

for each tt-estoq where tt-estoq.procod > 0 no-lock.
    create tp-estoq.
    buffer-copy tt-estoq to tp-estoq.
end. 

hide frame f no-pause.
hide frame f1 no-pause. 
run estoque-disponivel.
         
procedure estoque-disponivel:

    def var vdisponivel like estoq.estatual.
    def var vest-filial like estoq.estatual.
    def var vprocod like v-procod.
    vprocod = v-procod.
    def buffer bprodu for produ.
    form 
         "                       DISPONIBILIDADE DO PRODUTO " skip
         " " skip
         vprocod label "Produto"
         with frame est-disp.

    if vprocod = 0
    then update vprocod   with frame est-disp overlay.

    disp vprocod with frame est-disp.

    find first tp-estoq where tp-estoq.procod = int(vprocod) no-lock no-error.
    if not avail tp-estoq
    then do:
    
    end.
    else do:
        find produ where produ.procod = tp-estoq.procod no-lock.
        vdisponivel = tp-estoq.estatual - tp-estoq.estpedven.
        if vdisponivel < 0
        then vdisponivel = 0.
        vest-filial = tp-estoq.estinvqtd.
        if vest-filial = ?
        then vest-filial = 0.
        if tp-estoq.estloc = "5"
        then tp-estoq.estloc = "".
        if tp-estoq.estinvctm > 0
        then do:
            for each movim where movim.etbcod = tp-estoq.etbcod and
                                 movim.movtdc = 5 and
                                 movim.procod = tp-estoq.procod and
                                 movim.placod > tp-estoq.estinvctm 
                                 no-lock:
                vest-filial = vest-filial - movim.movqtm.
            end.    
        end.
        disp vprocod   at 8
             produ.pronom no-label
             vest-filial at 1 label "Estoque Filial" format "->>>,>>9"
             vdisponivel at 1 label "Disponivel Dep"     format ">>>,>>9"
             tp-estoq.estpedcom label "Pedidos de compra" format ">>>,>>9"
             substr(tp-estoq.estloc,1,64) at 5 format "x(64)" label "  Previsao"
             substr(tp-estoq.estloc,65,64) at 15 format "x(64)" no-label
             with frame est-disp overlay row 8
             width 80 15 down color message no-box side-label.
             pause 0 .
        if vdisponivel = 0
        then do:
            for each tp-estoq where
                     tp-estoq.procod <> vprocod no-lock:
                find bprodu where bprodu.procod = tp-estoq.procod 
                        no-lock no-error.
                if not avail bprodu then next.        
                vdisponivel = tp-estoq.estatual - tp-estoq.estpedven.
                if vdisponivel < 0
                then vdisponivel = 0.
                if vdisponivel = 0
                then next.
                    
                disp bprodu.procod 
                     bprodu.pronom
                     vdisponivel column-label "Disponivel"
                     with frame f-equiv 4 down  overlay
                     title " Produtos equivalentes "
                     centered
                     .
            end.
        end.
        pause 30.

    end. 
end procedure.
         
