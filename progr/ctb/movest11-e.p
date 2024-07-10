{ctb/extrato12-def.i}

form datasai format "99/99/9999" column-label "Data Saida"
    vmovtnom column-label "Operacao" format "x(12)"
    vnumero  column-label "Documento" format "x(9)"
    plani.serie column-label "SE" format "x(02)"
    movim.emite column-label "Emite" format ">>>>>>"
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


find estab where estab.etbcod = vetbcod no-lock.
find produ where produ.procod = vprocod no-lock.
def var p-etbcod like estab.etbcod.
def var p-forcod like forne.forcod extent 3.
if vetbcod = 981 
then assign
    /*  p-forcod[1] = 115198 - removido no dia 14/06/2017 */
        p-forcod[1] = 101463
    /*  p-forcod[2] = 115815 - removido no dia 08/05/2019 TP 30126948 */
        p-forcod[3] = 116199
        p-etbcod = 900.

    find last hiest where hiest.etbcod = vetbcod      and
                          hiest.procod = produ.procod and
                          hiest.hiemes < month(vdata1) and
                          hiest.hieano = year(vdata1) no-lock no-error.
    if not avail hiest
    then do:
        
        find last hiest where hiest.etbcod = vetbcod      and
                              hiest.procod = produ.procod and
                              hiest.hieano = year(vdata1) - 1 no-lock no-error.
        if not avail hiest
        then do:
            find last hiest where hiest.etbcod = vetbcod      and
                                  hiest.procod = produ.procod and
                                  hiest.hieano = year(vdata1) - 2
                                        no-lock no-error.
            if not avail hiest
            then do:
                find last hiest where hiest.etbcod = vetbcod      and
                                  hiest.procod = produ.procod and
                                  hiest.hieano < year(vdata1) - 2
                                        no-lock no-error.
                if not avail hiest
                then do:

                find last hiest where hiest.etbcod = vetbcod      and
                          hiest.procod = produ.procod             and
                          hiest.hiemes = month(vdata1)             and
                          hiest.hieano = year(vdata1) no-lock no-error.
                if not avail hiest
                then assign sal-ant = 0
                            vmes    = month(vdata1) 
                            vano    = year(vdata1).
            
                else assign sal-ant = 0 /* hiest.hiestf */
                            vmes    = hiest.hiemes - 1
                            vano    = hiest.hieano.

                end.
                else assign sal-ant = hiest.hiestf
                        vmes    = hiest.hiemes
                        vano    = hiest.hieano.
            end.
            else assign sal-ant = hiest.hiestf
                        vmes    = hiest.hiemes
                        vano    = hiest.hieano.
        end.
        else assign sal-ant = hiest.hiestf
                    vmes    = hiest.hiemes
                    vano    = hiest.hieano.
    end.
    else assign sal-ant = hiest.hiestf
                vmes    = hiest.hiemes
                vano    = hiest.hieano.

    sal-atu = sal-ant.
    t-sai   = 0.
    t-ent   = 0.

    find estoq where estoq.etbcod = estab.etbcod and
                     estoq.procod = produ.procod no-lock no-error.
    if not avail estoq
    then return.

          /* movimentações antes do dia da data inicial */

    do vdata = date(month(vdata1),1,year(vdata1)) to vdata1: 
        if vdata = vdata1
        then next. 
        for each movim where movim.procod = produ.procod and
                             movim.emite  = p-etbcod and
                             movim.desti  = p-forcod[1]  and
                             movim.datexp = vdata no-lock by movim.datexp
                                                          by movim.movtdc desc:
            
            
            vemit = yes.
            vdest = no.
            vdestaj = no.
            
            p-retorna = no.
            {movest10-e.i}
            if p-retorna then next.
            
        end.

        for each movim where movim.procod = produ.procod and
                             movim.desti   = p-etbcod and
                              movim.emite  = p-forcod[2] and
                             movim.datexp = vdata no-lock by movim.datexp
                                                          by movim.movtdc desc:
            
            
            vemit = yes.
            vdest = no.
            vdestaj = no.
            
            p-retorna = no.
            {movest10-e.i}
            if p-retorna then next.
            
        end.
        for each movim where movim.procod = produ.procod and
                             movim.desti   = p-etbcod and
                              movim.emite  = p-forcod[3] and
                             movim.datexp = vdata no-lock by movim.datexp
                                                          by movim.movtdc desc:
            
            
            vemit = yes.
            vdest = no.
            vdestaj = no.
            
            p-retorna = no.
            {movest10-e.i}
            if p-retorna then next.
            
        end.
        for each movim where movim.procod = produ.procod and
                             movim.desti = p-etbcod and
                             movim.emite  = p-forcod[1] and
                             movim.datexp = vdata no-lock by movim.datexp
                                                          by movim.movtdc desc:
            
            vdest = yes.
            vemit = no.
            vdestaj = no.
            
            p-retorna = no.
            {movest10-e.i}
            if p-retorna then next.
            
        end.
        for each movim where movim.procod = produ.procod and
                             movim.desti = p-etbcod and
                             movim.emite = p-forcod[2] and
                             movim.datexp = vdata no-lock by movim.datexp
                                                          by movim.movtdc desc:
            
            vdest = yes.
            vemit = no.
            vdestaj = no.
            
            p-retorna = no.
            {movest10-e.i}
            if p-retorna then next.
            
        end.
        for each movim where movim.procod = produ.procod and
                             movim.desti = p-etbcod and
                             movim.emite = p-forcod[3] and
                             movim.datexp = vdata no-lock by movim.datexp
                                                          by movim.movtdc desc:
            
            vdest = yes.
            vemit = no.
            vdestaj = no.
            
            p-retorna = no.
            {movest10-e.i}
            if p-retorna then next.
            
        end.

        for each movim where movim.procod = produ.procod and
                             movim.desti = 981 and
                             movim.emite = 981 and
                             movim.datexp = vdata no-lock by movim.datexp
                                                          by movim.movtdc desc:
            
            vdest = no.
            vemit = no.
            vdestaj = yes.
            
            p-retorna = no.
            {movest11.i}
            if p-retorna then next.
            
        end.   
        
    end.
    
    /***** saldo antes 993 ****/
    p-etbcod = 993.
    do vdata = date(month(vdata1),1,year(vdata1)) to vdata1: 
        if vdata = vdata1
        then next. 
        for each movim where movim.procod = produ.procod and
                             movim.emite  = p-etbcod and
                             movim.desti  = p-forcod[1]  and
                             movim.datexp = vdata no-lock by movim.datexp
                                                          by movim.movtdc desc:
            
            
            vemit = yes.
            vdest = no.
            vdestaj = no.
            
            p-retorna = no.
            {movest10-e.i}
            if p-retorna then next.
            
        end.
        for each movim where movim.procod = produ.procod and
                             movim.desti   = p-etbcod and
                              movim.emite  = p-forcod[2] and
                             movim.datexp = vdata no-lock by movim.datexp
                                                          by movim.movtdc desc:
            
            
            vemit = yes.
            vdest = no.
            vdestaj = no.
            
            p-retorna = no.
            {movest10-e.i}
            if p-retorna then next.
            
        end.
        for each movim where movim.procod = produ.procod and
                             movim.desti   = p-etbcod and
                              movim.emite  = p-forcod[3] and
                             movim.datexp = vdata no-lock by movim.datexp
                                                          by movim.movtdc desc:
            
            
            vemit = yes.
            vdest = no.
            vdestaj = no.
            
            p-retorna = no.
            {movest10-e.i}
            if p-retorna then next.
            
        end.
        for each movim where movim.procod = produ.procod and
                             movim.desti = p-etbcod and
                             movim.emite  = p-forcod[1] and
                             movim.datexp = vdata no-lock by movim.datexp
                                                          by movim.movtdc desc:
            
            vdest = yes.
            vemit = no.
            vdestaj = no.
            
            p-retorna = no.
            {movest10-e.i}
            if p-retorna then next.
            
        end.
        for each movim where movim.procod = produ.procod and
                             movim.desti = p-etbcod and
                             movim.emite = p-forcod[2] and
                             movim.datexp = vdata no-lock by movim.datexp
                                                          by movim.movtdc desc:
            
            vdest = yes.
            vemit = no.
            vdestaj = no.
            
            p-retorna = no.
            {movest10-e.i}
            if p-retorna then next.
            
        end.
        for each movim where movim.procod = produ.procod and
                             movim.desti = p-etbcod and
                             movim.emite = p-forcod[3] and
                             movim.datexp = vdata no-lock by movim.datexp
                                                          by movim.movtdc desc:
            
            vdest = yes.
            vemit = no.
            vdestaj = no.
            
            p-retorna = no.
            {movest10-e.i}
            if p-retorna then next.
            
        end.

    end.
    
    
    sal-ant = sal-ant + t-ent - t-sai.
    sal-atu = sal-ant.

    t-sai = 0.
    t-ent = 0.
    
    if vdt <> vdata1 and vdisp
    then do:
        pause 0.
        display "Produto com Problema em " month(vdt) format "99"
                "/" 
                year(vdt) format "9999"
                with frame f-message side-label color white/black
                         no-box row 06 overlay column 40.
        pause.
    end. 
    
    p-etbcod = 900.
    do vdata = vdata1  /**date(month(vdata1),1,year(vdata1))**/ to vdata2: 
        for each movim where movim.procod = produ.procod and
                             movim.emite = p-etbcod and
                             movim.desti  = p-forcod[1] and
                             movim.datexp = vdata no-lock by movim.datexp
                                                          by movim.movtdc desc:

            vemit = yes.
            vdest = no.
            vdestaj = no.
            v-ent = 0.
            v-sai = 0.
            p-retorna = no.
            {movest10-e.i}
            if p-retorna then next.
            
            if vdisp
            then do:
                display datasai  
                    VMOVTNOM 
                    vnumero  
                    plani.serie when avail plani 
                    movim.emite 
                    vdesti 
                    vmovqtm 
                    movim.movpc 
                    sal-atu  with frame f-val.
                color display red/gray vmovqtm with frame f-val. 
                down with frame f-val.
            end.
            else run cria-temp-movimento.

        end.
        for each movim where movim.procod = produ.procod and
                             movim.emite = p-etbcod and
                             movim.desti  = p-forcod[2] and
                             movim.datexp = vdata no-lock by movim.datexp
                                                          by movim.movtdc desc:

            vemit = yes.
            vdest = no.
            vdestaj = no.
            v-ent = 0.
            v-sai = 0.
            p-retorna = no.
            {movest10-e.i}
            if p-retorna then next.
            
            if vdisp
            then do:
                display datasai  
                    VMOVTNOM 
                    vnumero  
                    plani.serie when avail plani 
                    movim.emite 
                    vdesti 
                    vmovqtm 
                    movim.movpc 
                    sal-atu  with frame f-val.
                color display red/gray vmovqtm with frame f-val. 
                down with frame f-val.
            end.
            else run cria-temp-movimento.

        end.
        for each movim where movim.procod = produ.procod and
                             movim.emite = p-etbcod and
                             movim.desti  = p-forcod[3] and
                             movim.datexp = vdata no-lock by movim.datexp
                                                          by movim.movtdc desc:

            vemit = yes.
            vdest = no.
            vdestaj = no.
            v-ent = 0.
            v-sai = 0.
            p-retorna = no.
            {movest10-e.i}
            if p-retorna then next.
            
            if vdisp
            then do:
                display datasai  
                    VMOVTNOM 
                    vnumero  
                    plani.serie when avail plani 
                    movim.emite 
                    vdesti 
                    vmovqtm 
                    movim.movpc 
                    sal-atu  with frame f-val.
                color display red/gray vmovqtm with frame f-val. 
                down with frame f-val.
            end.
            else run cria-temp-movimento.

        end.
        for each movim where movim.procod = produ.procod and
                             movim.desti = p-etbcod and
                             movim.emite  = p-forcod[1] and
                             movim.datexp = vdata no-lock by movim.datexp
                                                          by movim.movtdc desc:
            
            vdest = yes.
            vemit = no.
            vdestaj = no.
            v-ent = 0.
            v-sai = 0.
            p-retorna = no.
            {movest10-e.i}
            if p-retorna then next.
            if vdisp
            then do:
                display datasai 
                    VMOVTNOM 
                    vnumero 
                    plani.serie when avail plani
                    movim.emite 
                    vdesti 
                    vmovqtm 
                    movim.movpc 
                    sal-atu 
                    with frame f-val
                     .
                
                color display red/gray vmovqtm with frame f-val. 
                down with frame f-val.

            end.
            else run cria-temp-movimento.
        end. 
        for each movim where movim.procod = produ.procod and
                             movim.desti = p-etbcod and
                             movim.emite  = p-forcod[2] and
                             movim.datexp = vdata no-lock by movim.datexp
                                                          by movim.movtdc desc:
            
            vdest = yes.
            vemit = no.
            vdestaj = no.
            v-ent = 0.
            v-sai = 0.
            p-retorna = no.
            {movest10-e.i}
            if p-retorna then next.
            if vdisp
            then do:
                display datasai 
                    VMOVTNOM 
                    vnumero 
                    plani.serie when avail plani
                    movim.emite 
                    vdesti 
                    vmovqtm 
                    movim.movpc 
                    sal-atu 
                    with frame f-val
                     .
                
                color display red/gray vmovqtm with frame f-val. 
                down with frame f-val.

            end.
            else run cria-temp-movimento.
        end. 
        for each movim where movim.procod = produ.procod and
                             movim.desti = p-etbcod and
                             movim.emite  = p-forcod[3] and
                             movim.datexp = vdata no-lock by movim.datexp
                                                          by movim.movtdc desc:
            
            vdest = yes.
            vemit = no.
            vdestaj = no.
            v-ent = 0.
            v-sai = 0.
            p-retorna = no.
            {movest10-e.i}
            if p-retorna then next.
            if vdisp
            then do:
                display datasai 
                    VMOVTNOM 
                    vnumero 
                    plani.serie when avail plani
                    movim.emite 
                    vdesti 
                    vmovqtm 
                    movim.movpc 
                    sal-atu 
                    with frame f-val
                     .
                
                color display red/gray vmovqtm with frame f-val. 
                down with frame f-val.

            end.
            else run cria-temp-movimento.
        end. 
        for each movim where movim.procod = produ.procod and
                             movim.desti  = p-etbcod and
                             movim.emite  = p-forcod[1] and
                             movim.movdat = vdata no-lock:
            
            vdestaj = yes.
            vdest = no.
            vemit = no.
            v-ent = 0.
            v-sai = 0.
            p-retorna = no.
            {movest10-e.i}
            if p-retorna then next.
            if vdisp
            then do:
                display datasai
                    VMOVTNOM 
                    vnumero  
                    plani.serie when avail plani
                    movim.emite 
                    vdesti 
                    vmovqtm 
                    movim.movpc 
                    sal-atu 
                    with frame f-val
                    .
                
                color display red/gray vmovqtm with frame f-val. 
                down with frame f-val.
            end.
            else run cria-temp-movimento.
        end.
        for each movim where movim.procod = produ.procod and
                             movim.desti  = p-etbcod and
                             movim.emite  = p-forcod[2] and
                             movim.movdat = vdata no-lock:
            
            vdestaj = yes.
            vdest = no.
            vemit = no.
            v-ent = 0.
            v-sai = 0.
            p-retorna = no.
            {movest10-e.i}
            if p-retorna then next.
            if vdisp
            then do:
                display datasai
                    VMOVTNOM 
                    vnumero  
                    plani.serie when avail plani
                    movim.emite 
                    vdesti 
                    vmovqtm 
                    movim.movpc 
                    sal-atu 
                    with frame f-val
                    .
                
                color display red/gray vmovqtm with frame f-val. 
                down with frame f-val.
            end.
            else run cria-temp-movimento.
        end.
        for each movim where movim.procod = produ.procod and
                             movim.desti  = p-etbcod and
                             movim.emite  = p-forcod[3] and
                             movim.movdat = vdata no-lock:
            
            vdestaj = yes.
            vdest = no.
            vemit = no.
            v-ent = 0.
            v-sai = 0.
            p-retorna = no.
            {movest10-e.i}
            if p-retorna then next.
            if vdisp
            then do:
                display datasai
                    VMOVTNOM 
                    vnumero  
                    plani.serie when avail plani
                    movim.emite 
                    vdesti 
                    vmovqtm 
                    movim.movpc 
                    sal-atu 
                    with frame f-val
                    .
                
                color display red/gray vmovqtm with frame f-val. 
                down with frame f-val.
            end.
            else run cria-temp-movimento.
        end.
        for each movim where movim.procod = produ.procod and
                             movim.desti  = 981 and
                             movim.emite  = 981 and
                             movim.movdat = vdata no-lock:
            vdestaj = yes.
            vdest = no.
            vemit = no.
            v-ent = 0.
            v-sai = 0.
            p-retorna = no.
            {movest11.i}
            if p-retorna then next.
            if vdisp
            then do:
                display datasai
                    VMOVTNOM 
                    vnumero  
                    plani.serie when avail plani
                    movim.emite 
                    vdesti 
                    vmovqtm 
                    movim.movpc 
                    sal-atu 
                    with frame f-val
                    .
                
                color display red/gray vmovqtm with frame f-val. 
                down with frame f-val.
            end.
            else run cria-temp-movimento.
        end.

    end.
    p-etbcod = 993.
    do vdata = vdata1  /**date(month(vdata1),1,year(vdata1))**/ to vdata2: 
        for each movim where movim.procod = produ.procod and
                             movim.emite = p-etbcod and
                             movim.desti  = p-forcod[1] and
                             movim.datexp = vdata no-lock by movim.datexp
                                                          by movim.movtdc desc:

            vemit = yes.
            vdest = no.
            vdestaj = no.
            v-ent = 0.
            v-sai = 0.
            p-retorna = no.
            {movest10-e.i}
            if p-retorna then next.
            
            if vdisp
            then do:
                display datasai  
                    VMOVTNOM 
                    vnumero  
                    plani.serie when avail plani 
                    movim.emite 
                    vdesti 
                    vmovqtm 
                    movim.movpc 
                    sal-atu  with frame f-val.
                color display red/gray vmovqtm with frame f-val. 
                down with frame f-val.
            end.
            else run cria-temp-movimento.

        end.
        for each movim where movim.procod = produ.procod and
                             movim.emite = p-etbcod and
                             movim.desti  = p-forcod[2] and
                             movim.datexp = vdata no-lock by movim.datexp
                                                          by movim.movtdc desc:

            vemit = yes.
            vdest = no.
            vdestaj = no.
            v-ent = 0.
            v-sai = 0.
            p-retorna = no.
            {movest10-e.i}
            if p-retorna then next.
            
            if vdisp
            then do:
                display datasai  
                    VMOVTNOM 
                    vnumero  
                    plani.serie when avail plani 
                    movim.emite 
                    vdesti 
                    vmovqtm 
                    movim.movpc 
                    sal-atu  with frame f-val.
                color display red/gray vmovqtm with frame f-val. 
                down with frame f-val.
            end.
            else run cria-temp-movimento.

        end.
        for each movim where movim.procod = produ.procod and
                             movim.emite = p-etbcod and
                             movim.desti  = p-forcod[3] and
                             movim.datexp = vdata no-lock by movim.datexp
                                                          by movim.movtdc desc:

            vemit = yes.
            vdest = no.
            vdestaj = no.
            v-ent = 0.
            v-sai = 0.
            p-retorna = no.
            {movest10-e.i}
            if p-retorna then next.
            
            if vdisp
            then do:
                display datasai  
                    VMOVTNOM 
                    vnumero  
                    plani.serie when avail plani 
                    movim.emite 
                    vdesti 
                    vmovqtm 
                    movim.movpc 
                    sal-atu  with frame f-val.
                color display red/gray vmovqtm with frame f-val. 
                down with frame f-val.
            end.
            else run cria-temp-movimento.

        end.
        for each movim where movim.procod = produ.procod and
                             movim.desti = p-etbcod and
                             movim.emite  = p-forcod[1] and
                             movim.datexp = vdata no-lock by movim.datexp
                                                          by movim.movtdc desc:
            
            vdest = yes.
            vemit = no.
            vdestaj = no.
            v-ent = 0.
            v-sai = 0.
            p-retorna = no.
            {movest10-e.i}
            if p-retorna then next.
            if vdisp
            then do:
                display datasai 
                    VMOVTNOM 
                    vnumero 
                    plani.serie when avail plani
                    movim.emite 
                    vdesti 
                    vmovqtm 
                    movim.movpc 
                    sal-atu 
                    with frame f-val
                     .
                
                color display red/gray vmovqtm with frame f-val. 
                down with frame f-val.

            end.
            else run cria-temp-movimento.
        end. 
        for each movim where movim.procod = produ.procod and
                             movim.desti = p-etbcod and
                             movim.emite  = p-forcod[2] and
                             movim.datexp = vdata no-lock by movim.datexp
                                                          by movim.movtdc desc:
            
            vdest = yes.
            vemit = no.
            vdestaj = no.
            v-ent = 0.
            v-sai = 0.
            p-retorna = no.
            {movest10-e.i}
            if p-retorna then next.
            if vdisp
            then do:
                display datasai 
                    VMOVTNOM 
                    vnumero 
                    plani.serie when avail plani
                    movim.emite 
                    vdesti 
                    vmovqtm 
                    movim.movpc 
                    sal-atu 
                    with frame f-val
                     .
                
                color display red/gray vmovqtm with frame f-val. 
                down with frame f-val.

            end.
            else run cria-temp-movimento.
        end. 
        for each movim where movim.procod = produ.procod and
                             movim.desti = p-etbcod and
                             movim.emite  = p-forcod[3] and
                             movim.datexp = vdata no-lock by movim.datexp
                                                          by movim.movtdc desc:
            
            vdest = yes.
            vemit = no.
            vdestaj = no.
            v-ent = 0.
            v-sai = 0.
            p-retorna = no.
            {movest10-e.i}
            if p-retorna then next.
            if vdisp
            then do:
                display datasai 
                    VMOVTNOM 
                    vnumero 
                    plani.serie when avail plani
                    movim.emite 
                    vdesti 
                    vmovqtm 
                    movim.movpc 
                    sal-atu 
                    with frame f-val
                     .
                
                color display red/gray vmovqtm with frame f-val. 
                down with frame f-val.

            end.
            else run cria-temp-movimento.
        end. 
        for each movim where movim.procod = produ.procod and
                             movim.desti  = p-etbcod and
                             movim.emite  = p-forcod[1] and
                             movim.movdat = vdata no-lock:
            
            vdestaj = yes.
            vdest = no.
            vemit = no.
            v-ent = 0.
            v-sai = 0.
            p-retorna = no.
            {movest10-e.i}
            if p-retorna then next.
            if vdisp
            then do:
                display datasai
                    VMOVTNOM 
                    vnumero  
                    plani.serie when avail plani
                    movim.emite 
                    vdesti 
                    vmovqtm 
                    movim.movpc 
                    sal-atu 
                    with frame f-val
                    .
                
                color display red/gray vmovqtm with frame f-val. 
                down with frame f-val.
            end.
            else run cria-temp-movimento.
        end.
        for each movim where movim.procod = produ.procod and
                             movim.desti  = p-etbcod and
                             movim.emite  = p-forcod[2] and
                             movim.movdat = vdata no-lock:
            
            vdestaj = yes.
            vdest = no.
            vemit = no.
            v-ent = 0.
            v-sai = 0.
            p-retorna = no.
            {movest10-e.i}
            if p-retorna then next.
            if vdisp
            then do:
                display datasai
                    VMOVTNOM 
                    vnumero  
                    plani.serie when avail plani
                    movim.emite 
                    vdesti 
                    vmovqtm 
                    movim.movpc 
                    sal-atu 
                    with frame f-val
                    .
                
                color display red/gray vmovqtm with frame f-val. 
                down with frame f-val.
            end.
            else run cria-temp-movimento.
        end.
        for each movim where movim.procod = produ.procod and
                             movim.desti  = p-etbcod and
                             movim.emite  = p-forcod[3] and
                             movim.movdat = vdata no-lock:
            
            vdestaj = yes.
            vdest = no.
            vemit = no.
            v-ent = 0.
            v-sai = 0.
            p-retorna = no.
            {movest10-e.i}
            if p-retorna then next.
            if vdisp
            then do:
                display datasai
                    VMOVTNOM 
                    vnumero  
                    plani.serie when avail plani
                    movim.emite 
                    vdesti 
                    vmovqtm 
                    movim.movpc 
                    sal-atu 
                    with frame f-val
                    .
                
                color display red/gray vmovqtm with frame f-val. 
                down with frame f-val.
            end.
            else run cria-temp-movimento.
        end.
    end.

    pause 0.
    if vdisp
    then do:
        disp sal-ant label "Saldo Anterior" format "->>>>9"
         t-ent   label "Ent" format ">>>>>9"
         t-sai   label "Sai" format ">>>>>9"
         estoq.estatual label "Saldo Atual" format "->>>>9"
                    with frame f-sal.
        pause.
        hide frame f-sal no-pause.
        clear frame f-sal all.
    end.

procedure cria-temp-movimento:
    create tt-movest.
    assign
        tt-movest.etbcod = movim.etbcod
        tt-movest.procod = movim.procod
        tt-movest.data   = movim.movdat
        tt-movest.hora   = movim.movhr
        tt-movest.movtdc = movim.movtdc
        tt-movest.movtnom = vmovtnom
        tt-movest.numero = vnumero
        tt-movest.serie  = if avail plani then plani.serie else ""
        tt-movest.emite  = movim.emite
        tt-movest.desti  = vdesti
        tt-movest.movqtm = movim.movqtm
        tt-movest.movpc  = movim.movpc
        tt-movest.sal-ant = sal-ant
        tt-movest.sal-atu = sal-atu
        tt-movest.cus-ent = estoq.estcusto
        tt-movest.qtd-ent = v-ent
        tt-movest.qtd-sai = v-sai
        .

    find first tt-saldo where 
               tt-saldo.etbcod = vetbcod and
               tt-saldo.ano-cto = year(movim.movdat) and
               tt-saldo.mes-cto = month(movim.movdat) and
               tt-saldo.procod = produ.procod
               no-error. 
    if not avail tt-saldo
    then do:
        create tt-saldo.
        assign 
            tt-saldo.ano-cto = year(movim.movdat)
            tt-saldo.mes-cto = month(movim.movdat)
            tt-saldo.etbcod = vetbcod 
            tt-saldo.procod = produ.procod
            tt-saldo.codfis = produ.codfis
            tt-saldo.sal-ant = sal-ant
            .
    end.
    assign        
        tt-saldo.qtd-ent = tt-saldo.qtd-ent + v-ent
        tt-saldo.qtd-sai = tt-saldo.qtd-sai + v-sai
        tt-saldo.sal-atu = sal-atu
        tt-saldo.cto-mes = estoq.estcusto
        tt-saldo.cus-ent = estoq.estcusto
        tt-saldo.cus-med = 0
        .

    find first tt-saldo where 
               tt-saldo.etbcod = vetbcod and
               tt-saldo.ano-cto = 0 and
               tt-saldo.mes-cto = 0 and
               tt-saldo.procod = produ.procod
               no-error. 
    if not avail tt-saldo
    then do:
        create tt-saldo.
        assign 
            tt-saldo.ano-cto = 0
            tt-saldo.mes-cto = 0
            tt-saldo.etbcod = vetbcod 
            tt-saldo.procod = produ.procod
            tt-saldo.codfis = produ.codfis
            tt-saldo.sal-ant = sal-ant
            .
    end.
    assign        
        tt-saldo.qtd-ent = tt-saldo.qtd-ent + v-ent
        tt-saldo.qtd-sai = tt-saldo.qtd-sai + v-sai
        tt-saldo.sal-atu = sal-atu
        tt-saldo.cto-mes = estoq.estcusto
        tt-saldo.cus-ent = estoq.estcusto
        tt-saldo.cus-med = 0
        .
    

end procedure.  
  
