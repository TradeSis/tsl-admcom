/******************************************************************************
* Programa  - confdev1.p                                                      *
*                                                                             *
* Funcao    - relatorio de conferencia das notas de devolucao de vendas       *
*                                                                             *
* Data       Autor          Caracteristica                                    *
* ---------  -------------  ------------------------------------------------- *
* 15/01/97   Jeanine        Manutencao-relatorio tbem em tela                 *
*******************************************************************************/

{admcab.i}

def var vetbcod like estab.etbcod.
def var vtotdia like plani.platot.
def var vtot  like movim.movpc.
def var vtotg like movim.movpc.
def var vtotgeral like plani.platot.
def var vdata1 like plani.pladat label "Data".
def var vdata2 like plani.pladat label "Data".
def var vtotal like plani.platot.
def var vtoticm like plani.icms.
              /**** Campo usado para guardar o no. da planilha ****/

def var varquivo as char.
def var fila as char.
def var recimp as recid.

repeat:
    vtotgeral = 0.
    update vetbcod
           vdata1
           vdata2 label "A " with frame f1 side-labe centered
           color blue/cyan  title "Periodo" row 4.

    if opsys = "UNIX"
    then do:
        varquivo = "/admcom/relat/conffor." + string(time).
        
        find first impress where impress.codimp = setbcod no-lock no-error. 
        if avail impress
        then do: 
            run acha_imp.p (input recid(impress),  
                            output recimp). 
            find impress where recid(impress) = recimp no-lock no-error.
            assign fila = string(impress.dfimp).
        end.    

    end.        
    else varquivo = "l:\relat\conffor." + string(time).
    {mdadmcab.i
        &Saida     = "printer" 
        &Page-Size = "63"
        &Cond-Var  = "120"
        &Page-Line = "66"
        &Nom-Rel   = ""CONFFOR""
        &Nom-Sis   = """SISTEMA ADMINISTRATIVO"""
        &Tit-Rel   = """CONFERENCIA DAS NOTAS DE DEVOLUCAO DE COMPRAS NA "" +
                    ""FILIAL "" + string(vetbcod) +
                    ""  - Data: "" + string(vdata1) + "" A "" +
                        string(vdata2)"
        &Width     = "120"
        &Form      = "frame f-cabcab"}


    for each plani where plani.movtdc = 13 
                     and plani.etbcod = vetbcod 
                     and plani.pladat >= vdata1     
                     and plani.pladat <= vdata2 no-lock,
        each movim where movim.etbcod = plani.etbcod
                     and movim.placod = plani.placod
                     and movim.movtdc = plani.movtdc
                     and movim.movdat = plani.pladat
                                        break by plani.pladat  
                                              by plani.numero:

            find produ where produ.procod = movim.procod.

            find forne where forne.forcod = plani.desti no-lock.

            display
                plani.pladat
                plani.numero 
                plani.serie
                forne.fornom format "x(20)"
                produ.procod
                produ.pronom format "x(30)"
                movim.movqtm format ">>>>9"
                movim.movpc
                (movim.movpc * movim.movqtm) (TOTAL)
                column-label "Total"
                             with frame f-val down no-box width 200.
    end.
    output close.
    
    if opsys = "UNIX"
    then os-command /* silent*/ lpr value(fila + " " + varquivo).
    else {mrod.i}.
        
end.
