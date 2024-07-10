/***************************************************************************
** Programa        : Expmatb4.p
** Objetivo        : Exportacao de Dados para a Loja
** Ultima Alteracao: 24/06/96
** Programador     : Cristiano Borges Brasil
****************************************************************************/
{admcab.i}
def stream tela.

def new shared frame fmostra.
def new shared var conta1       as integer.
def new shared var conta2       as integer.
def new shared var conta3       as integer.
def new shared var conta4       as integer.
def new shared var conta5       as integer.
def new shared var conta6       as integer.

def var cbb                     as integer.
def var data                   as date extent 28.

def var vdire                   as char format "x(08)".
def var v-dtini                 as date    init today       no-undo.
def var v-dtfin                 as date    init today       no-undo.
def var i-cont                  as integer init 0           no-undo.
def var vmodcod                 like titulo.modcod.
def var verro                   as log.
def var funcao                  as char.
def var parametro               as char.

output stream tela  to terminal.

form v-dtini         colon 16 label "Data Inicial"
     v-dtfin         colon 35 label "Data Final"
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
     "Arquivo de Saldos   :" conta2 skip
     "Arquivo de Controle :" conta1 skip
     "Titulos             :" conta3 skip
     "Contratos           :" conta4 skip
     "Clientes            :" conta5
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

input from ..\gener\admcom.ini no-echo.
repeat:
    set funcao parametro.
    if funcao = "ESTAB"
    then setbcod = int(parametro).
end.
input close.

find estab where estab.etbcod = setbcod.

update v-dtini
       v-dtfin with frame f-selecao.

vdire = "..\export\" + string(day(v-dtini),"99") + string(month(v-dtini),"99").

dos silent value("md " + vdire).

for each salexporta where salexporta.dtexp >= v-dtini and
                          salexporta.dtexp <= v-dtfin EXCLUSIVE-LOCK.
    delete salexporta.
end.
for each titexporta:
    delete titexporta.
end.

display v-dtini
        v-dtfin with frame f-selecao.

for each titulo where
         titulo.datexp >= v-dtini  and
         titulo.datexp <= v-dtfin :
    vmodcod = titulo.modcod.
    if titulo.titdtpag = ?
    then vmodcod = "VDP".
    if titulo.titpar    = 0 or
       titulo.clifor    = 1
    then do:
        if titulo.clifor = 1
        then vmodcod = "VDV".
        else vmodcod = "ENT".
    end.
    find first salexporta where salexporta.etbcod   = estab.etbcod
                        and salexporta.cxacod  = titulo.cxacod
                        and salexporta.saldt   = titulo.datexp
                        and salexporta.moecod  = titulo.moecod
                        and salexporta.modcod  = vmodcod
                        exclusive-lock no-error .
            if not avail salexporta
            then create salexporta.
            assign
                salexporta.etbcod = estab.etbcod
                salexporta.modcod = vmodcod
                salexporta.moecod = titulo.moecod
                salexporta.cxacod = titulo.cxacod
                salexporta.saldt  = titulo.datexp
                salexporta.salexp = salexporta.salexp + titulo.titvlcob
                salexporta.dtexp  = today.
    find first salexporta where salexporta.etbcod   = estab.etbcod
                        and salexporta.cxacod  = titulo.cxacod
                        and salexporta.saldt   = titulo.datexp
                        and salexporta.moecod  = ""
                        and salexporta.modcod  = "TOT"
                        exclusive-lock no-error .
            if not avail salexporta
            then create salexporta.
            assign
                salexporta.etbcod = estab.etbcod
                salexporta.modcod = "TOT"
                salexporta.moecod = ""
                salexporta.cxacod = titulo.cxacod
                salexporta.saldt  = titulo.datexp
                salexporta.salexp  = salexporta.salexp + titulo.titvlpag.
                salexporta.dtexp  = today.
    if titulo.titjuro > 0
    then do:
            find first salexporta where salexporta.etbcod   = estab.etbcod
                        and salexporta.cxacod  = titulo.cxacod
                        and salexporta.saldt   = titulo.datexp
                        and salexporta.moecod  = titulo.moecod
                        and salexporta.modcod  = "JUR"
                        exclusive-lock no-error.
            if not avail salexporta
            then create salexporta.
            assign
                salexporta.etbcod = estab.etbcod
                salexporta.modcod = "JUR"
                salexporta.moecod = titulo.moecod
                salexporta.cxacod = titulo.cxacod
                salexporta.saldt  = titulo.datexp
                salexporta.salexp  = salexporta.salexp + titulo.titjuro.
                salexporta.dtexp  = today.
    end.
    if titulo.titdesc > 0
    then do:
            find first salexporta where salexporta.etbcod   = estab.etbcod
                        and salexporta.cxacod  = titulo.cxacod
                        and salexporta.saldt   = titulo.datexp
                        and salexporta.moecod  = titulo.moecod
                        and salexporta.modcod  = "DES"
                        exclusive-lock no-error.
            if not avail salexporta
            then create salexporta.
            assign
                salexporta.etbcod = estab.etbcod
                salexporta.modcod = "DES"
                salexporta.moecod = titulo.moecod
                salexporta.cxacod = titulo.cxacod
                salexporta.saldt  = titulo.datexp
                salexporta.salexp = salexporta.salexp + titulo.titdesc.
                salexporta.dtexp  = today.
    end.
    conta1 = conta1 + 1.
    display stream tela conta1 with frame fmostra.
end.
verro = no.

output to value(vdire + "\titulo.d").
for each titulo where
         titulo.datexp >= v-dtini  and
         titulo.datexp <= v-dtfin .
    if titsit = "IMP" then titsit = "LIB".
    export titulo.
    conta3 = conta3 + 1.
    display stream tela conta3 with frame fmostra.
    pause 0.
end.
output close.
i-cont = 0.
output to value(vdire + "\clien.d").
for each clien where clien.datexp >= v-dtini and
                     clien.datexp <= v-dtfin:
    export clien.
    conta4 = conta4 + 1.
    display stream tela conta4 with frame fmostra.
    pause 0.
end.
output close.
i-cont = 0.
output to value(vdire + "\contrato.d").
for each contrato where contrato.datexp >= v-dtini and
                        contrato.datexp <= v-dtfin:
    export contrato.
    conta5 = conta5 + 1.
    display stream tela conta5 with frame fmostra.
    pause 0.
end.
output close.
output to value(vdire + "\salexport.d").
for each salexporta where salexporta.saldt >= v-dtini and
                          salexporta.saldt <= v-dtfin exclusive-lock.
    export salexporta.
    conta2 = conta2 + 1.
    display stream tela conta2 with frame fmostra.
    pause 0.
end.
output close.

bell.
bell.

def var vi as int.
def var vmarcado as dec format ">>>,>>>,>>>,>>9 Bytes" .
def var vtotal   as dec format ">>>,>>>,>>>,>>9 Bytes".
def var vCOPIADO as dec format ">>>,>>>,>>>,>>9 Bytes".
DEF VAR vunida-origem  AS CHAR INITIAL ".." label "Unidade Origem".
DEF VAR vunida-destino AS CHAR INITIAL "A:" label "Unidade Destino".
def var vdata as date initial today.
def var vdir as char.
def var vaux as char.
def var vokdos  as log.
DEF VAR A AS CHAR FORMAT "X(40)".
def var B   as char  format "x(40)".
def var C   as char  format "x(40)".
def var D   as char  format "x(40)".
def var E   as char  format "x(40)".
def var F   as char format "x(40)".
def var G   as char format "x(40)".
def var H   as char format "x(40)".
def var I   as char format "x(40)".
def var J   as char format "x(40)".
def temp-table wf-dir
    field diretorio as char format "x(50)".

def temp-table wf-prog
    field ast   as char format "x" column-label "*"
    field dir as char   format "x(25)" column-label "Diretorio"
    field prog as char  format "x(8)" column-label "Arquivo"
    field exten as char  format "x(3)" column-label "Ext"
    field taman as int                column-label "Tamanho"
    field data  as date                column-label "Alteracao".



DOS SILENT DIR VALUE("..\work\*.d /OD /S") > exporta.arq.

INPUT FROM ./exporta.arq no-echo.
REPEAT:
    pause 0.
    SET A
        B
        C
        D
        E
        F
        G
        H
        I
        J
      WITH 1 DOWN 1 column
            side-labels.
    if b <> "D" then next.

    do:
        do vi = 1 to 20:
            substring(c,vi,1) = if substring(c,vi,1) = "."
                                then ""
                                else substring(c,vi,1).
        end.
        create wf-prog.
        assign
            wf-prog.ast  = if b = "p" or
                              b begins "i"
                           then "*"
                           else ""
            wf-prog.dir  = lc(vdir)
            wf-prog.prog = lc(a)
            wf-prog.exten = lc(b)

            wf-prog.taman = dec(c).
            wf-prog.data = if opsys = "UNIX"
                           then ?
                           else date(int(substring(d,4,2)),
                                int(substring(d,1,2)),
                                 1900 + int(substring(d,7,2))).
            if wf-prog.ast = "*"
            then vmarcado = vmarcado + wf-prog.taman.
            vtotal   = vtotal   + wf-prog.taman.
    end.
end.
input close.

find micro where micro.etbcod = setbcod .

output to value(vdire + "\export.d").
put micro.miccod " " v-dtini " " v-dtfin.
output close.

/*message "Confirma a Geracao de DISQUETE ?" update sresp. */

sresp = no.

if sresp
then do:
    if vtotal > 1440000 and sresp
    then do on endkey undo:
        bell.
        bell.
        bell.
        message
            "Houve falta de espaco no Disquete  /  Comunicar ao *** CPD ***".
        pause.
        leave.
    end.

    bell.
    pause message "Coloque Diskette na Unidade A: e pressione uma tecla".

    dos silent "copy /y ..\export\contrato.d  a: ".
    dos silent "copy /y ..\export\clien.d     a: ".
    dos silent "copy /y ..\export\titulo.d    a: ".
    dos silent "copy /y ..\export\salexpor.d  a: ".
    dos silent "copy /y ..\export\export.d    a: ".
end.

/*
output to printer.
view frame fmostra.
output to close. */

do transaction:
    find micro where micro.miccod = 2 no-lock.

    do vdata = v-dtini to v-dtfin:
        find expmic where expmic.miccod = micro.miccod and
                          expmic.dtexp  = vdata no-lock no-error.
        if not avail expmic
        then do:
            create expmic.
            assign expmic.miccod = micro.miccod
                   expmic.dtexp  = vdata.
        end.
    end.
end.

/*
run exprel.p ( input v-dtini,
               input v-dtfin,
               input estab.etbcod).
*/

/******************************************************************************
 ZERANDO OS ARQUIVOS DE CONTROLE
******************************************************************************/
conta2 = 0.
output to value(string(v-dtini,"99999999") + ".sae").
for each salexporta where salexporta.saldt >= v-dtini  and
                          salexporta.saldt <= v-dtfin exclusive-lock.
    export salexporta.
    delete salexporta.
    conta2 = conta2 + 1.
    display stream tela conta2 with frame flimpa.
end.
output to close.

conta1 = 0.
output to value(string(v-dtini,"99999999") + ".tie").
for each titexporta where titexporta.datexp >= v-dtini  and
                          titexporta.datexp <= v-dtfin:
    export titexporta.
    delete titexporta.
    conta1 = conta1 + 1.
    display stream tela conta1 with frame flimpa.
end.
output to close.
