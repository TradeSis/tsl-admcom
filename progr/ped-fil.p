/***************************************************************************
** Programa        : impmat.p
****************************************************************************/
{admcab.i}
def var vprog as char format "x(30)".

/* def new shared frame fmostra. */
def new shared frame fperiodo.
/* def new shared frame flimpa.  */
def new shared frame fhora.
def new shared var conta1      as integer.
def new shared var conta2      as integer.
def new shared var conta3      as integer.
def new shared var conta4      as integer.
def new shared var conta5      as integer.
def new shared var conta6      as integer.
def new shared var conta7      as integer.
def new shared var conta8      as integer.
def new shared var vhora       as integer.
def new shared var v-etbcod    like estab.etbcod.

def var varq        as char                                      no-undo.
def var vmiccod     like micro.miccod.
def var v-dtini     as date init today                           no-undo.
def var v-dtfin     as date init today                           no-undo.
def var vdata       as date                                      no-undo.
def var vdata1      as date initial today                        no-undo.
def var vtotcli     as   int.
def var vtotcont    as   int.
def var vtitpg      as   int.
def var vtotparc    as   int.
def var vtotpag     like titulo.titvlpag.
def var vtotvl      like contrato.vltotal.
def var vtitsit     like titulo.titsit.
def var vtitdtpag   like titulo.titdtpag.
def var vmodcod     like titulo.modcod.
def var verro       as log.
def buffer vestab   for estab.
def stream tela.

assign conta1 = 0
       conta2 = 0
       conta3 = 0
       conta4 = 0
       conta5 = 0
       conta6 = 0
       conta7 = 0
       conta8 = 0
       vhora  = time.

form v-dtini    label "Data Inicial"
     v-dtfin    label "Data Final"
     with side-label 2 column color white/cyan title " PERIODO A IMPORTAR "
     row 4 centered frame fperiodo.

form skip(1)
     "Titulos             :" conta3 skip
     "Contratos           :" conta4 skip
     "Clientes            :" conta5 skip
     with frame fmostra row 8 column 18 color blue/cyan no-label
     title " IMPORTACAO DE DADOS - CPD ".

form skip
     vhora
     skip
     with frame fhora row 10 column 52 color blue/cyan no-label
     title " TEMPO ".

form skip(1)
     "*** ATENCAO :  Arquivo de Controle"
     "               Danificado ou inexistente !!"
     skip(1)
     with centered  color blink/red title " ERRO DE IMPORTACAO " 1 column
     no-label row 8 frame faviso.


def var vi as int.
def var vmarcado as dec format ">>>,>>>,>>>,>>9 Bytes" .
def var vtotal   as dec format ">>>,>>>,>>>,>>9 Bytes".
def var vCOPIADO as dec format ">>>,>>>,>>>,>>9 Bytes".
DEF VAR vunida-origem  AS CHAR INITIAL ".." label "Unidade Origem".
DEF VAR vunida-destino AS CHAR INITIAL "A:" label "Unidade Destino".
def var vdir as char.
def var vaux as char.
def var vokdos  as log.
DEF VAR A AS CHAR FORMAT "X(40)".
DEF Var       B like a.
DEF Var       C like a.
DEF Var       D like a.
DEF Var       E like a.
DEF Var       F like a.
DEF Var       G like a.
DEF Var       H like a.
DEF Var       I like a.
DEF Var       J like a.
def temp-table wf-dir
    field diretorio as char format "x(50)".
def temp-table wf-prog
    field ast   as char format "x" column-label "*"
    field dir as char   format "x(25)" column-label "Diretorio"
    field prog as char  format "x(8)" column-label "Arquivo"
    field exten as char  format "x(3)" column-label "Ext"
    field taman as int                column-label "Tamanho"
    field data  as date                column-label "Alteracao".

if opsys = "MSDOS"
then do:
    DOS
    SILENT DIR VALUE("i:\admcom\import\*.zip /OD /S") > ADMCOPI.ARQ.
end.

INPUT FROM ./admcopi.arq no-echo.
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
      WITH 1 DOWN
            side-labels.
    if a = "DIRETORIO-" or
       (a begins "dire" and
        (b = "de" or
         b = "of"))
    then vdir = if opsys = "UNIX"
                then b
                else substring(c,r-index(c,"~\") + 1).

    if b = "<DIR>" or
       a begins "direc" or
       a = "DIRETORIO-"     or
       b = "File(s)"
    then next.

    vokdos = no.
    if opsys = "MSDOS"
    then
        if substring(d,3,1) = "/" or
           substring(d,3,1)= "-"
        then
            if date(int(substring(d,4,2)),
                int(substring(d,1,2)),
                1900 + int(substring(d,7,2))) >= vdata1
            then
                vokdos = yes.
    /*
    if opsys = "MSDOS" and
       not vokdos
    then
        next.
    */
    do:
        do vi = 1 to 20:
            substring(c,vi,1) = if substring(c,vi,1) = "."
                                then ""
                                else substring(c,vi,1).
        end.
        if b = "DB"  or
           b = "BI"  or
           b = "LG"  or
           b = "LK"  or
           b = "log" or
           b = "TXT" or
           b = "r"
        then
            next.
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
    end.
end.
input close.

message "Confirma Importacao de Dados ? " update sresp.
if not sresp then return.

for each wf-prog where wf-prog.exten <> "zip":
    delete wf-prog.
end.

for each wf-prog by wf-prog.prog:
    vprog = trim("..\import\" + wf-prog.prog + "." + wf-prog.exten).
    dos silent pkunzip -do value(vprog) ..\import.

    /****************************/

    pause 0 before-hide.

    output stream tela to terminal.

    view stream tela frame fmostra.
    view stream tela frame f1.


    input from ..\import\export.d no-echo.
    repeat:
        set v-etbcod v-dtini v-dtfin.
    end.

    display v-dtini
            v-dtfin with frame fperiodo.

    find vestab where vestab.etbcod = v-etbcod no-lock.

    display stream tela
            caps(vestab.etbnom) label "FILIAL" format "x(25)" colon 18
            vprog colon 18 label "ARQUIVO"
                with row 19 column 10 color white/red side-labels
                    title " LOJA A IMPORTAR " frame f1.

    view stream tela frame f1.

    if search("..\import\pedid.d") <> ?
    then do:
        pause 0.
        input from ..\import\pedid.d no-echo.
        repeat:
            create pedid.
            import pedid.
        end.
        input close.
    end.

    if search("..\import\liped.d") <> ?
    then do:
        pause 0.
        input from ..\import\liped.d no-echo.
        repeat:
            prompt-for liped.pedtdc
                       liped.pednum
                       liped.procod
                       liped.lipqtd
                       liped.lippreco
                       liped.lipsit
                       liped.lipent
                       liped.predtf
                       liped.predt
                       liped.lipcor
                       liped.etbcod with no-validate with frame f-liped.
            find liped where liped.pedtdc = input liped.pedtdc and
                             liped.etbcod = input liped.etbcod and
                             liped.pednum = input liped.pednum and
                             liped.procod = input liped.procod and
                             liped.predt  = input liped.predt  and
                             liped.lipcor = input liped.lipcor no-error.
            if not avail liped
            then do:
                create liped.
                ASSIGN liped.pedtdc   = input liped.pedtdc
                       liped.pednum   = input liped.pednum
                       liped.procod   = input liped.procod
                       liped.lipqtd   = input liped.lipqtd
                       liped.lippreco = input liped.lippreco
                       liped.lipsit   = input liped.lipsit
                       liped.lipent   = input liped.lipent
                       liped.predtf   = input liped.predtf
                       liped.predt    = input liped.predt
                       liped.lipcor   = input liped.lipcor
                       liped.etbcod   = input liped.etbcod.
                find produ where produ.procod = input liped.procod
                                                        no-lock no-error.
                if avail produ
                then do:
                    if produ.catcod = 31 or
                       produ.catcod = 35
                    then liped.protip = "M".
                    else liped.protip = "C".
                end.
            end.
        end.
        input close.
    end.

    delete wf-prog.

    dos silent del ..\import\*.d.
end.
