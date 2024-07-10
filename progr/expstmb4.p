/***************************************************************************
** Programa        : ExpSTMb4.p
** Objetivo        : Exportacao de Dados para a Loja via STM
** Ultima Alteracao: 24/09/96
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

def var vdire                   as char.

def var varq                    as char                     no-undo.
def var vachou                  as log                      no-undo.
def var v-dtini                 as date    init today       no-undo.
def var v-dtfin                 as date    init today       no-undo.
def var v-etbcod                like estab.etbcod           no-undo.
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
     "Clientes            :" conta4 skip
     "Contratos           :" conta5
     skip(1)
     with frame fmostra row 9 column 18 color blue/cyan no-label
     title " EXPORTACAO DE DADOS - CPD ".

form skip(01)
     conta2 skip
     conta1 skip
     skip(04)
     with frame flimpa row 9 column 52 color blue/cyan no-label
     title " LIMPA ".

run contexp.p.

view stream tela frame flimpa.
view stream tela frame fmostra.


message "Exportar todas as regioes ?" update sresp.

if not sresp
then do:
    /*
    hide frame all no-pause.
    clear frame all no-pause.
    */
    run expregb4.p.
    run expstm.p.
    leave.
end.

update v-dtini
       v-dtfin
       with frame f-selecao.

update  sresp label "Confirma Exportacao de Dados ? "
        with row 19 column 03 color white/red side-labels frame f1.

if  not sresp
then leave.

for each regiao no-lock:
    if regiao.regcod = 99 or
       regiao.regcod = 90
    then next.
    dos silent value("md ..\EXPORT\REG" + string(regiao.regcod,"99")).
end.

for each regiao:
    if regiao.regcod = 99
    then next.

    vdire = "..\EXPORT\REG" + string(regiao.regcod,"99") + "\".

    assign conta1 = 0
           conta2 = 0
           conta3 = 0
           conta4 = 0
           conta5 = 0.

    hide stream tela frame flimpa  no-pause.
    hide stream tela frame fmostra no-pause.
    display stream tela conta1
                        conta2 with frame flimpa.
    display stream tela conta1
                        conta2
                        conta3
                        conta4
                        conta5 with frame fmostra.

do on error undo, retry:
    display stream tela regiao.regcod label "Reg"
            with row 19 column 42 color white/red side-labels frame f2.
    display stream tela regiao.regnom no-label format "x(20)"
            with frame f2.
end.

for each salexporta.
    delete salexporta.
end.

output to value(vdire + "titulo.d").
for each titulo where
         titulo.datexp >= v-dtini  and
         titulo.datexp <= v-dtfin :

    if titulo.etbcod <> 990
    then do:
        find estab where estab.etbcod = titulo.etbcod no-lock.
        if estab.regcod <> regiao.regcod
        then next.
    end.

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
    find first salexporta where salexporta.etbcod   = setbcod
                        and salexporta.cxacod  = titulo.cxacod
                        and salexporta.saldt   = titulo.datexp
                        and salexporta.moecod  = titulo.moecod
                        and salexporta.modcod  = vmodcod no-error.
            if not avail salexporta
            then create salexporta.
            assign
                salexporta.etbcod = setbcod
                salexporta.modcod = vmodcod
                salexporta.moecod = titulo.moecod
                salexporta.cxacod = titulo.cxacod
                salexporta.saldt  = titulo.datexp
                salexporta.salexp = salexporta.salexp + titulo.titvlcob
                salexporta.dtexp  = today.
    find first salexporta where salexporta.etbcod   = setbcod
                        and salexporta.cxacod  = titulo.cxacod
                        and salexporta.saldt   = titulo.datexp
                        and salexporta.moecod  = ""
                        and salexporta.modcod  = "TOT" no-error.
            if not avail salexporta
            then create salexporta.
            assign
                salexporta.etbcod = setbcod
                salexporta.modcod = "TOT"
                salexporta.moecod = ""
                salexporta.cxacod = titulo.cxacod
                salexporta.saldt  = titulo.datexp
                salexporta.salexp  = salexporta.salexp + titulo.titvlpag.
                salexporta.dtexp  = today.
    if titulo.titjuro > 0
    then do:
            find first salexporta where salexporta.etbcod   = setbcod
                        and salexporta.cxacod  = titulo.cxacod
                        and salexporta.saldt   = titulo.datexp
                        and salexporta.moecod  = titulo.moecod
                        and salexporta.modcod  = "JUR"
                            no-error.
            if not avail salexporta
            then create salexporta.
            assign
                salexporta.etbcod = setbcod
                salexporta.modcod = "JUR"
                salexporta.moecod = titulo.moecod
                salexporta.cxacod = titulo.cxacod
                salexporta.saldt  = titulo.datexp
                salexporta.salexp  = salexporta.salexp + titulo.titjuro.
                salexporta.dtexp  = today.
    end.
    if titulo.titdesc > 0
    then do:
            find first salexporta where salexporta.etbcod   = setbcod
                        and salexporta.cxacod  = titulo.cxacod
                        and salexporta.saldt   = titulo.datexp
                        and salexporta.moecod  = titulo.moecod
                        and salexporta.modcod  = "DES"
                            no-error.
            if not avail salexporta
            then create salexporta.
            assign
                salexporta.etbcod = setbcod
                salexporta.modcod = "DES"
                salexporta.moecod = titulo.moecod
                salexporta.cxacod = titulo.cxacod
                salexporta.saldt  = titulo.datexp
                salexporta.salexp = salexporta.salexp + titulo.titdesc.
                salexporta.dtexp  = today.
    end.

    if titulo.titsit = "IMP"
    then assign titulo.titsit = "LIB".

    export titulo.
    conta3 = conta3 + 1.
    display stream tela conta3 with frame fmostra.

    conta1 = conta1 + 1.
    display stream tela conta1 with frame fmostra.
    pause 0.
end.
output close.

verro = no.

i-cont = 0.
output to value(vdire + "clien.d").
for each clien where clien.datexp >= v-dtini and
                     clien.datexp <= v-dtfin:

    vachou = no.

    for each titulo where titulo.clifor = clien.clicod no-lock:
        if titulo.etbcod <> 990
        then do:
            find estab where estab.etbcod = titulo.etbcod no-lock.
            if estab.regcod <> regiao.regcod
            then next.
            else do:
                vachou = yes.
                leave.
            end.
        end.
    end.

    if vachou
    then do:
        export clien.
        conta4 = conta4 + 1.
        display stream tela conta4 with frame fmostra.
        pause 0.
    end.
end.
output close.
i-cont = 0.
output to value(vdire + "contrato.d").
for each contrato where contrato.datexp >= v-dtini and
                        contrato.datexp <= v-dtfin:

    if contrato.etbcod <> 990
    then do:
        find estab where estab.etbcod = contrato.etbcod no-lock.
        if estab.regcod <> regiao.regcod
        then next.
    end.

    export contrato.
    conta5 = conta5 + 1.
    display stream tela conta5 with frame fmostra.
    pause 0.
end.
output close.
output to value(vdire + "salexpor.d").
for each salexporta where salexporta.saldt >= v-dtini and
                          salexporta.saldt <= v-dtfin:
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



DOS SILENT DIR VALUE("..\export\*.d /OD ") > exporta.arq.

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

output to value(vdire + "export.d").
put setbcod " " v-dtini " " v-dtfin.
output close.

message "Confirma a Geracao de DISQUETE ?" update sresp.

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

        varq = "..\relat\" + STRING(TIME) + ".REL".

        output to value(varq).
        view frame fmostra.
        output to close.

        message "Imprime o Arquivo" varq "?" update sresp.
        if sresp
        then dos silent value("type " + varq + " > prn").

        do transaction:
            find first estab where estab.regcod = regiao.regcod no-lock
                                                    no-error.
            do vdata = v-dtini to v-dtfin:
                find exporta where exporta.etbcod  = estab.etbcod and
                                   exporta.exporta = vdata no-error.
                if not avail exporta
                then do:
                    create exporta.
                    assign exporta.etbcod  = estab.etbcod
                           exporta.exporta = vdata.
                end.
            end.
        end.

        run exprel.p ( input v-dtini,
                       input v-dtfin,
                       input setbcod).

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

varq = "..\relat\" + STRING(TIME) + ".REL".

output to value(varq).
view frame fmostra.
output to close.

message "Imprime o Arquivo" varq "?" update sresp.
if sresp
then dos silent value("type " + varq + " > prn").

do transaction:
    find first estab where estab.regcod = regiao.regcod no-lock no-error.
    do vdata = v-dtini to v-dtfin:
        find exporta where exporta.etbcod  = estab.etbcod and
                           exporta.exporta = vdata no-error.
        if not avail exporta
        then do:
            create exporta.
            assign exporta.etbcod  = estab.etbcod
                   exporta.exporta = vdata.
        end.
    end.
end.

run exprel.p ( input v-dtini,
               input v-dtfin,
               input setbcod).

/******************************************************************************
 ZERANDO OS ARQUIVOS DE CONTROLE
******************************************************************************/
conta2 = 0.
for each salexporta:
    delete salexporta.
    conta2 = conta2 + 1.
    display stream tela conta2 with frame flimpa.
end.
end.

run expstm.p.
