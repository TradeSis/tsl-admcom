/***************************************************************************
** Programa        : Expmatb4.p
** Objetivo        : Exportacao de Dados para a Loja
** Ultima Alteracao: 24/06/96
** Programador     :
****************************************************************************/
{admcab.i}


def stream sped97.
def stream sped95.
def stream slip97.
def stream slip95.
 def var contcli as int.
def var contest as int.
def var contpro as int.
def var contpla as int.
def var contmov as int.
def var vdt as date format "99/99/9999".
def stream tela.
def var vdata as date format "99/99/9999" initial today.

def new shared frame fmostra.
def new shared var conta1       as integer.
def new shared var conta2       as integer.
def new shared var conta3       as integer.
def new shared var conta4       as integer.
def new shared var conta5       as integer.
def new shared var conta6       as integer.

def var varq                    as char                     no-undo.
def var vachou                  as log                      no-undo.
def var v-dtini as date format "99/99/9999" init today no-undo. 
def var v-dtfin as date format "99/99/9999" init today no-undo. 
def var i-cont                  as integer init 0           no-undo.
def var vmodcod                 like titulo.modcod.
def var verro                   as log.
def var funcao                  as char.
def var parametro               as char.
def var vetbcod                 like estab.etbcod.

output stream tela  to terminal.

pause 0 before-hide.
form v-dtini         colon 16 label "Data Inicial"
     v-dtfin          label "Data Final"
     with overlay row 5 side-labels frame f-selecao centered color white/cyan
     2 column title " PERIODO ".

assign conta1 = 0
       conta2 = 0
       conta3 = 0
       conta4 = 0
       conta5 = 0.

form skip(1)
     "*** ATENCAO :  Saldo do Caixa nao fechou "
     "               com o Saldo Exportado !!"
     skip(1)
     with centered  color blink/red title " ERRO DE EXPORTACAO " 1 column
     no-label row 8 frame faviso.

form skip(1)
     "Produtos            :" conta1 skip
     "Estoque             :" conta2 skip
     "Pedidos             :" conta5 skip
     "Notas               :" conta3 skip
     "Movimentos          :" conta4 skip
     skip(1)
     with frame fmostra row 9 column 18 color blue/cyan no-label
     title " EXPORTACAO DE DADOS - CPD " centered.


view stream tela frame flimpa.
view stream tela frame fmostra.

update v-dtini
       v-dtfin
       with frame f-selecao.

update  sresp label "Confirma Exportacao de Dados ? "
        with row 19 column 03 color 
            white/cyan side-labels frame f1 centered.

if  not sresp then
    leave.

output to ..\export\cpd97\export.d.
    put setbcod " " v-dtini " " v-dtfin.
output close.

output to ..\export\cpd95\export.d.
    put setbcod " " v-dtini " " v-dtfin.
output close.


output to ..\export\cpd97\produ.d.
for each produ where produ.datexp >= v-dtini and
                     produ.datexp <= v-dtfin no-lock:

    conta1 = conta1 + 1.
    display stream tela conta1 with frame fmostra.
    export produ.
    contpro = contpro + 1.
end.
output close.

output to ..\export\cpd95\produ.d.
for each produ where produ.datexp >= v-dtini and
                     produ.datexp <= v-dtfin no-lock:

    conta1 = conta1 + 1.
    display stream tela conta1 with frame fmostra.
    export produ.
    contpro = contpro + 1.
end.
output close.


output to ..\export\cpd97\propg.d.
for each propg where propg.prpdata >= v-dtini and
                     propg.prpdata <= v-dtfin no-lock:

    export propg.
end.
output close.

output to ..\export\cpd95\propg.d.
for each propg where propg.prpdata >= v-dtini and
                     propg.prpdata <= v-dtfin no-lock:

    export propg.
end.
output close.


output to ..\export\cpd97\estoq.d.
for each produ where produ.datexp >= v-dtini and
                     produ.datexp <= v-dtfin no-lock:
    for each estoq where estoq.procod = produ.procod and
                         estoq.etbcod = 997 no-lock:
        conta2 = conta2 + 1.
        display stream tela conta2 with frame fmostra.
        export estoq.
        contest = contest + 1.
    end.
end.
output close.


output to ..\export\cpd95\estoq.d.
for each produ where produ.datexp >= v-dtini and
                     produ.datexp <= v-dtfin no-lock:
    for each estoq where estoq.procod = produ.procod and
                         estoq.etbcod = 995 no-lock:
        conta2 = conta2 + 1.
        display stream tela conta2 with frame fmostra.
        export estoq.
        contest = contest + 1.
    end.
end.
output close.



output to ..\export\cpd97\tabmen.d.
for each tabmen where tabmen.datexp >= v-dtini and
                      tabmen.datexp <= v-dtfin no-lock:
    export tabmen.
end.
output close.


output to ..\export\cpd95\tabmen.d.
for each tabmen where tabmen.datexp >= v-dtini and
                      tabmen.datexp <= v-dtfin no-lock:
    export tabmen.
end.
output close.



output stream sped97 to ..\export\cpd97\pedid.d.
output stream sped95 to ..\export\cpd95\pedid.d.
output stream slip97 to ..\export\cpd97\liped.d.
output stream slip95 to ..\export\cpd95\liped.d.
for each estab where estab.etbcod >= 995 no-lock,
    each pedid where pedid.pedtdc = 01            and
                     pedid.etbcod = estab.etbcod  and
                     pedid.peddat >= v-dtini      and
                     pedid.peddat <= v-dtfin no-lock:
    if pedid.etbcod = 996
    then next.
    for each liped where liped.etbcod = pedid.etbcod and
                         liped.pedtdc = pedid.pedtdc and
                         liped.pednum = pedid.pednum no-lock:

        export stream slip97 liped.
        export stream slip95 liped.
    end.
    
    export stream sped97 pedid.
    export stream sped95 pedid.
    
    conta5 = conta5 + 1.
    display stream tela conta5 with frame fmostra.
end.
output stream sped97 close.
output stream sped95 close.
output stream slip97 close.
output stream slip95 close.





output to ..\export\cpd97\plani.d.
do vdt = v-dtini to v-dtfin:
   for each plani use-index datexp where plani.datexp = vdt no-lock:
        if plani.etbcod = 997 or
           plani.desti  = 997
        then do:
            export plani.
            contpla = contpla + 1.
            conta3 = conta3 + 1.
            display stream tela conta3 with frame fmostra.
        end.
   end.
end.
output close.

output to ..\export\cpd95\plani.d.
do vdt = v-dtini to v-dtfin:
   for each plani use-index datexp where plani.datexp = vdt no-lock:
        if plani.etbcod = 995 or
           plani.desti  = 995
        then do:
            export plani.
            contpla = contpla + 1.
            conta3 = conta3 + 1.
            display stream tela conta3 with frame fmostra.
        end.
   end.
end.
output close.


    output to ..\export\cpd97\movim.d.
    do vdt = v-dtini to v-dtfin:
        for each plani use-index datexp where plani.datexp = vdt no-lock:
                if plani.etbcod = 997 or
                   plani.desti  = 997
                then do:
                    for each movim where movim.etbcod = plani.etbcod and
                                         movim.placod = plani.placod and
                                         movim.movtdc = plani.movtdc and
                                         movim.movdat = plani.pladat no-lock:
                        conta4 = conta4 + 1.
                        display stream tela conta4 with frame fmostra.
                        export  movim.movtdc   
                                movim.PlaCod   
                                movim.etbcod   
                                movim.movseq   
                                movim.procod   
                                movim.movqtm   
                                movim.movpc    
                                movim.MovDev   
                                movim.MovAcFin 
                                movim.movipi   
                                movim.MovPro   
                                movim.MovICMS  
                                movim.MovAlICMS  
                                movim.MovPDesc   
                                movim.MovCtM     
                                movim.MovAlIPI   
                                movim.movdat     
                                movim.MovHr      
                                movim.MovDes     
                                movim.MovSubst   
                                movim.OCNum[1]   
                                movim.OCNum[2]   
                                movim.OCNum[3]   
                                movim.OCNum[4]   
                                movim.OCNum[5]   
                                movim.OCNum[6]   
                                movim.OCNum[7]   
                                movim.OCNum[8]   
                                movim.OCNum[9]   
                                movim.datexp.     
                        contmov = contmov + 1.
                    end.
                end.
        end.
    end.
    output close.
    
    output to ..\export\cpd95\movim.d.
    do vdt = v-dtini to v-dtfin:
        for each plani use-index datexp where plani.datexp = vdt no-lock:
                if plani.etbcod = 995 or
                   plani.desti  = 995
                then do:
                    for each movim where movim.etbcod = plani.etbcod and
                                         movim.placod = plani.placod and
                                         movim.movtdc = plani.movtdc and
                                         movim.movdat = plani.pladat no-lock:
                        conta4 = conta4 + 1.
                        display stream tela conta4 with frame fmostra.
                        export  movim.movtdc   
                                movim.PlaCod   
                                movim.etbcod   
                                movim.movseq   
                                movim.procod   
                                movim.movqtm   
                                movim.movpc    
                                movim.MovDev   
                                movim.MovAcFin 
                                movim.movipi   
                                movim.MovPro   
                                movim.MovICMS  
                                movim.MovAlICMS  
                                movim.MovPDesc   
                                movim.MovCtM     
                                movim.MovAlIPI   
                                movim.movdat     
                                movim.MovHr      
                                movim.MovDes     
                                movim.MovSubst   
                                movim.OCNum[1]   
                                movim.OCNum[2]   
                                movim.OCNum[3]   
                                movim.OCNum[4]   
                                movim.OCNum[5]   
                                movim.OCNum[6]   
                                movim.OCNum[7]   
                                movim.OCNum[8]   
                                movim.OCNum[9]   
                                movim.datexp.     
                        contmov = contmov + 1.
                    end.
                end.
        end.
    end.
    output close.
    

    output to ..\export\cpd97\controle.d.
        put contcli " "
            contpro " "
            contest " "
            contpla " "
            contmov " " 
            v-dtini " " 
            v-dtfin.
    output close.

    
    output to ..\export\cpd95\controle.d.
        put contcli " "
            contpro " "
            contest " "
            contpla " "
            contmov " " 
            v-dtini " " 
            v-dtfin.
    output close.





