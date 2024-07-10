/* Programa  - _extrato.p         
*                                                                             *
* Funcao    - relatorio de conferencia das notas de devolucao de vendas       *
*                                                                             *
* Data       Autor          Caracteristica                                    *
* ---------  -------------  ------------------------------------------------- *
******************************************************************************/

{admcab.i}   
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
              
              /**** Campo usado para guardar o no. da planilha ****/
   
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

repeat:
    vtotmovim = 0.
    vtotgeral = 0.
    sal-atu = 0.
    sal-ant = 0.
    vsalant = 0.
 
    clear frame f-val all.
    if setbcod < 200 
    then vetbcod = setbcod.
    else update vetbcod label " Filial" with frame f-pro.
    find estab where estab.etbcod = vetbcod no-lock.
    disp vetbcod estab.etbnom no-label with frame f-pro.
    update vdata1 label "Periodo" colon 55
           vdata2 no-label with frame f-pro.

    if vdata1 < 01/01/11 and vetbcod < 990
    then vdata1 = 01/01/11.
    disp vdata1 with frame f-pro.
    
    update vprocod
               with frame f-pro centered width 80 color blue/cyan 
                            row 3 side-label.

    find produ where produ.procod = vprocod no-lock.
    
    disp produ.pronom no-label with frame f-pro.

    vdt = vdata1.
    
    if setbcod < 200
    then do:
        MESSAGE "Atencao : Este produto pode ter Movimentado o estoque"            ~              "nos ultimos 30 minutos!"                                       
            "Favor aguardar atualizacao p/executar a consulta."                 
            view-as alert-box.                                                  
                                                                                   MESSAGE 
    "Atencao :   Este produto pode ter Movimentacoes de Devolução de Venda," sk~ip 
    "que irao aparecer apos o encerramento dos Caixas e emissao de N.Fiscais" s~kip     "Tais Operacoes devem ser consideradas no Saldo Final do Produto!"    
           view-as alert-box.                                                  
    

    end. 
    for each movdat where movdat.procod = produ.procod no-lock.
    
        find movim where movim.procod = movdat.procod and
                         movim.etbcod = movdat.etbcod and
                         movim.placod = movdat.placod no-lock no-error.
        if not avail movim or movim.movtdc > 9000
        then next.

        if movim.movdat < 01/01/11 and vetbcod < 990
        then next.
        
        if movim.etbcod = vetbcod or
           movim.desti  = vetbcod 
        then do:
            if vdt > movim.movdat
            then vdt = movim.movdat.
        end.
        
    end.    
    
    vdisp = yes.
    
    if vetbcod = 981
    then run movest10-e.p.
    else run movest10.p.

    for each tt-movest:
    disp tt-movest.procod
         tt-movest.data
         tt-movest.sal-ant
         tt-movest.qtd-ent (total)
         tt-movest.qtd-sai (total)
         tt-movest.sal-atu
         .
         
    end.
    for each tt-saldo.
        
        disp tt-saldo.sal-ant 
             tt-saldo.qtd-ent (total)
             tt-saldo.qtd-sai (total)
             tt-saldo.sal-atu.
     end.    
end.
