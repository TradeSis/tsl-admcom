{admcab.i}


def var fre    as int.
def var val    as dec.


def var vcatcod like categoria.catcod.

def new shared var vri as date format "99/99/9999" extent 5.
def new shared var vrf as date format "99/99/9999" extent 5.

def new shared var vfi as inte extent 5 format ">>>>>>>9".
def new shared var vff as inte extent 5 format ">>>>>>>9".

def new shared var vvi as dec format ">>>,>>9.99" extent 5.
def new shared var vvf as dec format ">>>,>>9.99" extent 5.

def var vetbcod like estab.etbcod init 8.
    
   /*** teste ****/
   do on error undo:
    
        assign vri[5] = today  - 180
               vri[4] = vri[5] - 180
               vri[3] = vri[4] - 180
               vri[2] = vri[3] - 180
               vri[1] = vri[2] - 180
               vrf[5] = today
               vrf[4] = vri[5] - 1
               vrf[3] = vri[4] - 1
               vrf[2] = vri[3] - 1
               vrf[1] = vri[2] - 1.
        update  vri[1] label "Rec. 1 Ini"
                vrf[1] label "Rec. 1 Fin" skip

                vri[2] label "Rec. 2 Ini"
                vrf[2] label "Rec. 2 Fin" skip

                vri[3] label "Rec. 3 Ini"
                vrf[3] label "Rec. 3 Fin" skip

                vri[4] label "Rec. 4 Ini"
                vrf[4] label "Rec. 4 Fin" skip
        
                vri[5] label "Rec. 5 Ini"
                vrf[5] label "Rec. 5 Fin" skip
                with frame f-dados2 centered side-labels.
    end.
    
    /*
    run p-media(input vri[1], 
                input vrf[5], 
                output fre, 
                output val).
    */
    
    fre = 10.
    val = 1000.
    
    disp fre label "Med.Fre" at 12 skip
         with frame f-dados2 centered side-labels.
    
    
    do on error undo:

        assign vfi[1] = 0
               vfi[2] = (((fre * 2) * 20) / 100)
               vfi[3] = (((fre * 2) * 40) / 100)
               vfi[4] = (((fre * 2) * 60) / 100)
               vfi[5] = (((fre * 2) * 80) / 100)

        
        
               vff[1] = vfi[2] - 1
               vff[2] = vfi[3] - 1
               vff[3] = vfi[4] - 1
               vff[4] = vfi[5] - 1
               vff[5] = 99999999.
                
                
                
        update  vfi[1] label "Fre. 1 Ini" space(2)
                vff[1] label " Fre. 1 Fin" space(2) skip

        
                vfi[2] label "Fre. 2 Ini" space(2)
                vff[2] label " Fre. 2 Fin" space(2) skip
                
                vfi[3] label "Fre. 3 Ini" space(2)
                vff[3] label " Fre. 3 Fin" space(2) skip
                
                vfi[4] label "Fre. 4 Ini" space(2)
                vff[4] label " Fre. 4 Fin" space(2) skip
        
                vfi[5] label "Fre. 5 Ini" space(2)
                vff[5] label " Fre. 5 Fin" space(2) skip
                with frame f-dados2.
    end.       

    disp val label "Med.Val" at 12 skip
         with frame f-dados2.
    
    do on error undo:

        
        assign vvi[1] = 0
               vvi[2] = (((val * 2) * 20) / 100)
               vvi[3] = (((val * 2) * 40) / 100)
               vvi[4] = (((val * 2) * 60) / 100)
               vvi[5] = (((val * 2) * 80) / 100)
               vvf[1] = vvi[2] - 0.01
               vvf[2] = vvi[3] - 0.01
               vvf[3] = vvi[4] - 0.01
               vvf[4] = vvi[5] - 0.01
               vvf[5] = 999999.99.

        
        
        
        
        update  vvi[1] label "Val. 1 Ini"
                vvf[1] label "Val. 1 Fin" skip
     
                vvi[2] label "Val. 2 Ini"
                vvf[2] label "Val. 2 Fin" skip

                vvi[3] label "Val. 3 Ini"
                vvf[3] label "Val. 3 Fin" skip

                vvi[4] label "Val. 4 Ini"
                vvf[4] label "Val. 4 Fin" skip

                vvi[5] label "Val. 5 Ini"
                vvf[5] label "Val. 5 Fin"
                with frame f-dados2.
    end.       

    
    
procedure p-media:

    def input parameter p-data1 as date format "99/99/9999".
    def input parameter p-data2 as date format "99/99/9999".
    def output parameter p-media-fre as int.
    def output parameter p-media-val as int.
    
    def var v-qtd-not as dec.
    def var v-qtd-cli as dec.
    def var v-valor like plani.platot.
    
    message "Calculando Media de Frequencia e Valor...".
    
    for each estab where estab.etbcod = (if vetbcod <> 0
                                         then vetbcod
                                         else estab.etbcod) no-lock:

        for each plani use-index pladat
                           where plani.movtdc = 5
                             and plani.etbcod = estab.etbcod
                             and plani.pladat >= vri[1]
                             and plani.pladat <= vrf[5] no-lock
                             break by plani.desti:

            if plani.desti = 1
            then next.

            find first clien where 
                       clien.clicod = plani.desti no-lock no-error.
            if not avail clien
            then next.
            
            if vcatcod <> 0
            then do:
            
                find first movim use-index movim
                             where movim.etbcod = plani.etbcod and
                                   movim.placod = plani.placod and
                                   movim.movtdc = plani.movtdc and
                                   movim.movdat = plani.pladat
                                   no-lock no-error.

                if not avail movim
                then next.
    
                find produ where produ.procod = movim.procod no-lock no-error.
                if not avail produ
                then next.
    
                if produ.catcod <> vcatcod
                then next.
            
            end.
            
            assign v-qtd-not = v-qtd-not + 1.
                   v-valor = v-valor +(if plani.biss > 0
                                          then plani.biss
                                          else plani.platot).

            if first-of(plani.desti)
            then v-qtd-cli = v-qtd-cli + 1.
        end.
    end.

    assign p-media-fre = (v-qtd-not / v-qtd-cli)
           p-media-val = (v-valor   / v-qtd-cli).
end procedure.
    
