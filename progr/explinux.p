/***************************************************************************
** Programa        : Expmatb4.p
** Objetivo        : Exportacao de Dados para a Loja
** Ultima Alteracao: 24/06/96
** Programador     :
****************************************************************************/
{admcab.i}


def var contcli as int.
def var contcon as int.
def var conttit as int.
def var contest as int.
def var contpro as int.
def var contpla as int.
def var contmov as int.
def var regsai  as char.
def buffer bestab for estab.
def var vdt as date format "99/99/9999".
def stream tela.
def var vdata as date initial today.

def new shared frame fmostra.
def new shared var conta1       as integer.
def new shared var conta2       as integer.
def new shared var conta3       as integer.
def new shared var conta4       as integer.
def new shared var conta5       as integer.
def new shared var conta6       as integer.
def var conta7 as int.


def var varq                    as char                     no-undo.
def var vachou                  as log                      no-undo.
def var v-dtini                 as date format "99/99/9999" init today no-undo.
def var v-dtfin                 as date format "99/99/9999" init today no-undo.
def var v-etbcod                like estab.etbcod           no-undo.
def var i-cont                  as integer init 0           no-undo.
def var vmodcod                 like titulo.modcod.
def var verro                   as log.
def var funcao                  as char.
def var parametro               as char.
def var vregcod                 like regiao.regcod.
output stream tela  to terminal.

pause 0 before-hide.
form v-dtini         colon 16 label "Data Inicial"
     v-dtfin         label "Data Final"
     with overlay row 5 side-labels frame f-selecao centered color white/cyan
     2 column title " PERIODO ".

assign conta1 = 0
       conta2 = 0
       conta3 = 0
       conta4 = 0
       conta5 = 0
       conta7 = 0
       contcli = 0
       contcon = 0
       conttit = 0
       contest = 0
       contpro = 0
       contpla = 0
       contmov = 0.

form skip(1)
     "Arquivo de Saldos   :" conta2 skip
     "Arquivo de Controle :" conta1 skip
     "Titulos             :" conta3 skip
     "Clientes            :" conta4 skip
     "Contratos           :" conta5 skip
     "Fornecedores        :" conta7 
     skip(1)
     with frame fmostra row 9 column 18 color blue/cyan no-label
     title " EXPORTACAO DE DADOS - CPD ".

form skip(01)
     conta2 skip
     conta1 skip
     skip(04)
     with frame flimpa row 9 column 52 color blue/cyan no-label
     title " LIMPA ".


view stream tela frame flimpa.
view stream tela frame fmostra.

update v-dtini
       v-dtfin
       with frame f-selecao.

update  sresp label "Confirma Exportacao de Dados ? "
        with row 19 column 03 color white/red side-labels frame f1.

if  not sresp then
    leave.

do on error undo, retry:
    update setbcod 
           with row 19 column 42 color white/red side-labels frame f2.
     find estab where estab.etbcod = setbcod no-lock no-error.
      if not avail estab
    then do:
        bell.
        message "Estabelecimento nao Cadastrado !!".
        undo, retry.
    end.

    display estab.etbnom no-label format "x(20)"
            with frame f2.
end.
    if opsys = "UNIX" then        
 regsai = "/drebes02/sys/admcom/export/".

output to value(regsai + "export.d").
put setbcod " " v-dtini " " v-dtfin.
output close.

output to value(regsai + "titulo.d").
for each titulo where
         titulo.datexp >= v-dtini  and
         titulo.datexp <= v-dtfin  and
         titulo.etbcod = setbcod no-lock:
         
    if titulo.titnat = yes
    then next.
    if titulo.modcod <> "CRE"
    then next.
    
    if titulo.clifor = 1
    then next.

    vmodcod = titulo.modcod.
    if titulo.titdtpag = ?
    then
        vmodcod = "VDP".
    if titulo.titpar    = 0 or
       titulo.clifor    = 1
    then do:
        if titulo.clifor = 1
        then vmodcod = "VDV".
        else vmodcod = "ENT".
    end.
    export titulo.    
    
    conttit = conttit + 1.
    conta3 = conta3 + 1.
    display stream tela conta3 with frame fmostra.

    conta1 = conta1 + 1.
    display stream tela conta1 with frame fmostra.
    pause 0.
end.
output close.

verro = no.

output to value(regsai + "fabri.d").
for each fabri where fabri.fabdtcad >= v-dtini and
                     fabri.fabdtcad <= v-dtfin:
    export fabri.
    conta7 = conta7 + 1.
    display stream tela conta7 with frame fmostra.
    pause 0.
end.
output close.

 


i-cont = 0.
output to value(regsai + "clien.d").
for each clien where clien.datexp >= v-dtini and
                     clien.datexp <= v-dtfin:
      export clien.
      contcli = contcli + 1.
      conta4 = conta4 + 1.
      display stream tela conta4 with frame fmostra.
      pause 0.
end.
output close.

output to value(regsai + "produ.d").
for each produ where produ.datexp >= v-dtini and
                     produ.datexp <= v-dtfin no-lock:
    export produ.
    contpro = contpro + 1.
end.
output close.

output to value(regsai + "glopre.d").
for each glopre where glopre.datexp >= v-dtini and
                      glopre.datexp <= v-dtfin and 
                      glopre.etbcod = setbcod no-lock:
    export glopre.
    contpro = contpro + 1.
end.
output close.



/*
output to value(regsai + "finan.d").
for each cpag no-lock:
    find finan where finan.fincod = cpag.cpagcod no-lock no-error.
    if avail finan
    then export finan.
end.
output close. */

output to value(regsai + "estoq.d").
for each estoq where estoq.datexp >= v-dtini and
                     estoq.datexp <= v-dtfin and
                     estoq.etbcod = setbcod no-lock:
        export estoq.
        contest = contest + 1.
end.
output close.

output to value(regsai + "tabmen.d").
for each tabmen where tabmen.datexp >= v-dtini and
                      tabmen.datexp <= v-dtfin no-lock:
    export tabmen.
end.
output close.
    output to value(regsai + "plani.d").
    do vdt = v-dtini to v-dtfin:
        for each plani use-index datexp where plani.datexp = vdt no-lock:
            if plani.usercod = "NAO"
            then next.
            if plani.etbcod <> setbcod and
               plani.desti  <> setbcod 
               then next.
               
            if plani.movtdc = 6 or
               plani.movtdc = 7 or
               plani.movtdc = 8 or
               plani.movtdc = 17 or
               plani.movtdc = 18
            then do:
                export plani.
                contpla = contpla + 1.
            end.
        end.
    end.
    output close.

    output to value(regsai + "movim.d").
    do vdt = v-dtini to v-dtfin:
        for each plani use-index datexp where plani.datexp = vdt no-lock:
            if plani.etbcod <> setbcod and
               plani.desti  <> setbcod
               then next.
            if plani.movtdc = 6 or
               plani.movtdc = 7 or
               plani.movtdc = 8 or
               plani.movtdc = 17 or
               plani.movtdc = 18
            then do:
                for each movim where movim.etbcod = plani.etbcod and
                                     movim.placod = plani.placod and
                                     movim.movtdc = plani.movtdc and
                                     movim.movdat = plani.pladat no-lock:
                    export movim.
                    contmov = contmov + 1.
                end.
            end.
        end.
    end.
    output close.

i-cont = 0.
output to value(regsai + "contrato.d").
for each contrato where contrato.datexp >= v-dtini and
                        contrato.datexp <= v-dtfin and
                        contrato.etbcod = setbcod:

    export contrato.
    contcon = contcon + 1.
    conta5 = conta5 + 1.
    display stream tela conta5 with frame fmostra.
    pause 0.
end.
output close.




