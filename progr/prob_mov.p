{admcab.i}

def stream stela.
def var vtotcus like plani.platot.
def var varquivo as char format "x(20)".
def var i as i.
def var v-de like plani.platot.
def var v-ac like plani.platot.
def var vetbcod like estab.etbcod.
def var vdti like plani.pladat.
def var vdtf like plani.pladat.
def var vcatcod like produ.catcod.

def temp-table tt-tipmov 
    field data    like plani.pladat
    field custo   like plani.platot extent 20.

def var totcus like plani.platot extent 20.

def temp-table tt-plani
    field movtdc like plani.movtdc
    field movtnom like tipmov.movtnom.

def var totsai like plani.platot.
def var totent like plani.platot.


repeat:
    
    update vetbcod colon 16 label "Filial" 
            with frame f1 side-label width 80.
    if vetbcod = 0
    then display "GERAL" @ estab.etbnom with frame f1.
    else do:
            
        find estab where estab.etbcod = vetbcod no-lock no-error.
        disp estab.etbnom no-label with frame f1.
    end.
    
    update vdti colon 16 label "Data Inicial"
           vdtf colon 16 label "Data Final"
                    with frame f1.
    
    /*        
    for each estab where if vetbcod = 0 
                         then true
                         else estab.etbcod = vetbcod no-lock,
        each movim where movim.movdat >= vdti              and
                         movim.movdat <= vdtf              and
                         movim.etbcod = estab.etbcod no-lock:
            
            
        find first plani where plani.etbcod = movim.etbcod and
                               plani.placod = movim.placod and
                               plani.movtdc = movim.movtdc and
                               plani.pladat = movim.movdat 
                                           no-lock no-error.
        if not avail plani
        then do:
            find tipmov where tipmov.movtdc = movim.movtdc no-lock no-error.
            find produ where produ.procod = movim.procod no-lock no-error.
            
            display movim.etbcod column-label "Filial"
                    movim.desti  column-label "Cliente" format ">>>>>>>>9"
                    movim.procod column-label "Produto"
                    produ.pronom format "x(20)" when avail produ
                    movim.movdat 
                    tipmov.movtnom format "x(20)" when avail tipmov
                        with frame f2 down centered. 
        end.
    end.


   
    */
        output stream stela to terminal.
        varquivo = "..\relat\prob" + string(time).
        
        {mdadmcab.i
                &Saida     = "value(varquivo)" 
                &Page-Size = "64"
                &Cond-Var  = "160"
                &Page-Line = "66"
                &Nom-Rel   = ""prob_mov""
                &Nom-Sis   = """SISTEMA DE ESTOQUE"""
                &Tit-Rel   = """MOVIMENTOS SEM NOTAS -  "" +
                                      string(vetbcod,"">>9"") +
                              "" PERIODO DE "" +
                                      string(vdti,""99/99/9999"") + "" A "" +
                                      string(vdtf,""99/99/9999"")" 
                &Width     = "160"
                &Form      = "frame f-cabcab"}

            
        for each estab where if vetbcod = 0 
                         then true
                         else estab.etbcod = vetbcod no-lock,
            each movim where movim.movdat >= vdti              and
                             movim.movdat <= vdtf              and
                             movim.etbcod = estab.etbcod no-lock:
            
            
            find first plani where plani.etbcod = movim.etbcod and
                                   plani.placod = movim.placod and
                                   plani.movtdc = movim.movtdc and
                                   plani.pladat = movim.movdat 
                                               no-lock no-error.
            if not avail plani
            then do:
                find tipmov where tipmov.movtdc = movim.movtdc 
                                                    no-lock no-error.
                find produ where produ.procod = movim.procod 
                                                    no-lock no-error.
                display stream stela 
                        movim.etbcod column-label "Filial"
                        movim.desti  column-label "Cliente" format ">>>>>>>>9"
                        movim.procod column-label "Produto"
                        produ.pronom format "x(20)" when avail produ
                        movim.movdat 
                        tipmov.movtnom format "x(15)" when avail tipmov
                            with frame f3 down centered.
                              
                display  
                        movim.etbcod column-label "Filial"
                        movim.desti  column-label "Cliente" format ">>>>>>>>9"
                        movim.procod column-label "Produto"
                        produ.pronom format "x(30)" when avail produ
                        movim.movdat 
                        tipmov.movtnom format "x(30)" when avail tipmov
                            with frame f4 down centered width 200. 
                     
            
            end.
        end.    
        output stream stela close.
        output close.
        message "Deseja imprimir listagem" update sresp.
        if sresp
        then os-command silent type value(varquivo) > prn.
 
end.



            
    
