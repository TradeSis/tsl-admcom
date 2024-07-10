/***************************************************************************
** Programa        : impmat.p
****************************************************************************/
{admcab.i}
def var recpla as recid.
def temp-table tt-plani like plani.
def temp-table tt-movim like movim.
def var ii as int.
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
def var v-dtini     as date format "99/99/9999" init today no-undo.
def var v-dtfin     as date format "99/99/9999" init today no-undo.
def var vdata       as date format "99/99/9999" no-undo.
def var vdata1      as date format "99/99/9999" initial today  no-undo.
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
def stream stela.
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
     "Depositos           :" conta3 skip
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
    field data  as date         column-label "Alteracao" format "99/99/9999".

    dos silent copy i:\admcom\import\*.zip i:\admcom\guido .
    dos silent DIR VALUE("i:\admcom\guido\*.zip /OD /S") > dep.ARQ.

INPUT FROM ./dep.arq no-echo.
REPEAT:
    
    pause 0.
    SET A
        B
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

    create wf-prog.
    assign  wf-prog.prog = lc(a)
            wf-prog.exten = lc(b).
end.
input close.

message "Confirma Importacao de Dados ? " update sresp.
if not sresp then return.

for each wf-prog where wf-prog.exten <> "zip":
    delete wf-prog.
end.


output stream stela to ..\guido\exp.cpd.
for each wf-prog by wf-prog.prog:
    vprog = trim("..\guido\" + wf-prog.prog + "." + wf-prog.exten).
    dos silent pkunzip -do value(vprog) plani.d export.d ..\guido .

    /****************************/

    pause 0 before-hide.

    output stream tela to terminal.

    view stream tela frame fmostra.
    view stream tela frame f1.
    view stream tela frame f-periodo.

    input from ..\guido\export.d no-echo.
    repeat:
        set v-etbcod v-dtini v-dtfin.
        put stream stela v-etbcod "  "
                         v-dtini  "  "
                         v-dtfin  "  " skip.
    end.
    
    display stream tela v-dtini
            v-dtfin with frame fperiodo.

    find vestab where vestab.etbcod = v-etbcod no-lock.

    display stream tela
            caps(vestab.etbnom) label "FILIAL" format "x(25)" colon 18
            vprog colon 18 label "ARQUIVO"
                with row 19 column 10 color white/red side-labels
                    title " LOJA A IMPORTAR " frame f1.

    view stream tela frame f1.
    
    
    if search("..\guido\plani.d") <> ?
    then do:
        pause 0.
        input from ..\guido\plani.d no-echo.
        repeat:
            for each tt-plani:
                delete tt-plani.
            end.
            create tt-plani.
            import tt-plani.
            
            if tt-plani.serie = "a"
            then tt-plani.serie = "C".
            if tt-plani.serie = "B"
            then tt-plani.serie = "M".


            find plani where plani.etbcod = tt-plani.etbcod and
                             plani.emite  = tt-plani.emite  and
                             plani.movtdc = tt-plani.movtdc and
                             plani.numero = tt-plani.numero and
                             plani.serie  = tt-plani.serie no-error.
            if not avail plani
            then do:
                find plani where plani.etbcod = tt-plani.etbcod and
                                 plani.placod = tt-plani.placod and
                                 plani.serie  = tt-plani.serie no-error.
                if not avail plani
                then do transaction:
                    create plani.
                    
                    ASSIGN plani.movtdc    = tt-plani.movtdc
                           plani.PlaCod    = tt-plani.PlaCod
                           plani.Numero    = tt-plani.Numero
                           plani.PlaDat    = tt-plani.PlaDat
                           plani.Serie     = tt-plani.Serie
                           plani.vencod    = tt-plani.vencod
                           plani.plades    = tt-plani.plades
                           plani.crecod    = tt-plani.crecod
                           plani.VlServ    = tt-plani.VlServ
                           plani.DescServ  = tt-plani.DescServ
                           plani.AcFServ   = tt-plani.AcFServ
                           plani.PedCod    = tt-plani.PedCod
                           plani.ICMS      = tt-plani.ICMS
                           plani.BSubst    = tt-plani.BSubst
                           plani.ICMSSubst = tt-plani.ICMSSubst
                           plani.BIPI      = tt-plani.BIPI
                           plani.AlIPI     = tt-plani.AlIPI
                           plani.IPI       = tt-plani.IPI
                           plani.Seguro    = tt-plani.Seguro
                           plani.Frete     = tt-plani.Frete
                           plani.DesAcess  = tt-plani.DesAcess
                           plani.DescProd  = tt-plani.DescProd
                           plani.AcFProd   = tt-plani.AcFProd
                           plani.ModCod    = tt-plani.ModCod
                           plani.AlICMS    = tt-plani.AlICMS
                           plani.Outras    = tt-plani.Outras
                           plani.AlISS     = tt-plani.AlISS
                           plani.BICMS     = tt-plani.BICMS
                           plani.UFEmi     = tt-plani.UFEmi
                           plani.BISS      = tt-plani.BISS
                           plani.CusMed    = tt-plani.CusMed
                           plani.UserCod   = tt-plani.UserCod
                           plani.DtInclu   = tt-plani.DtInclu
                           plani.HorIncl   = tt-plani.HorIncl
                           plani.NotSit    = tt-plani.NotSit
                           plani.NotFat    = tt-plani.NotFat
                           plani.HiCCod    = tt-plani.HiCCod
                           plani.NotObs[1] = tt-plani.NotObs[1]
                           plani.NotObs[2] = tt-plani.NotObs[2]
                           plani.NotObs[3] = tt-plani.NotObs[3]
                           plani.RespFre   = tt-plani.RespFre
                           plani.NotTran   = tt-plani.NotTran
                           plani.Isenta    = tt-plani.Isenta
                           plani.ISS       = tt-plani.ISS
                           plani.NotPis    = tt-plani.NotPis
                           plani.NotAss    = tt-plani.NotAss
                           plani.NotCoFinS = tt-plani.NotCoFinS
                           plani.TMovDev   = tt-plani.TMovDev
                           plani.Desti     = tt-plani.Desti
                           plani.IndEmi    = tt-plani.IndEmi
                           plani.Emite     = tt-plani.Emite
                           plani.NotPed    = tt-plani.NotPed
                           plani.PLaTot    = tt-plani.PLaTot
                           plani.OpCCod    = tt-plani.OpCCod
                           plani.UFDes     = tt-plani.UFDes 
                           plani.ProTot    = tt-plani.ProTot
                           plani.EtbCod    = tt-plani.EtbCod
                           plani.cxacod    = tt-plani.cxacod
                           plani.datexp    = tt-plani.datexp.
                    recpla = recid(plani).
                    release plani.
                    find plani where recid(plani) = recpla no-lock.
                end.
            end.
            

            find deposito where deposito.etbcod = plani.etbcod and
                                deposito.datmov = plani.datexp no-error.
            if not avail deposito and plani.seguro > 0
            then do transaction:
                create deposito.
                assign deposito.etbcod = plani.etbcod
                       deposito.datmov = plani.datexp
                       deposito.chedia = plani.iss
                       deposito.chedre = plani.notpis
                       deposito.cheglo = plani.cusmed
                       deposito.deppag = plani.notcofins
                       deposito.depdep = plani.seguro.
            end.
            
            conta3 = conta3 + 1.
            disp conta3 with frame fmostra.
        end.
        input close.
    end.
    delete wf-prog.
end.
output stream stela close.
