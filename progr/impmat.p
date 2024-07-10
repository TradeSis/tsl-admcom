/***************************************************************************
** Programa        : impmat.p
****************************************************************************/
{admcab.i}
def var recpla as recid.
def var recmov as recid.
def temp-table tt-deposito like deposito.
def temp-table tt-depban like depban.
def temp-table tt-cartao like cartao.
def temp-table tt-glopre like glopre.
def temp-table tt-globa like globa.
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

/*
run contimp.p.
*/


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

output stream stela to ..\import\exp.cpd.
for each wf-prog by wf-prog.prog:
    vprog = trim("..\import\" + wf-prog.prog + "." + wf-prog.exten).
    dos silent pkunzip -do value(vprog) ..\import.
    
    
    
    
    /****************************/

    pause 0 before-hide.

    output stream tela to terminal.

    view stream tela frame fmostra.
    view stream tela frame f1.
    view stream tela frame f-periodo.

    input from ..\import\export.d no-echo.
    repeat:
        set v-etbcod v-dtini v-dtfin.
        put stream stela v-etbcod "  "
                         v-dtini  "  "
                         v-dtfin  "  " skip.
    end.
    input close.

    
    {serial.i}
    

    display stream tela v-dtini
            v-dtfin with frame fperiodo.

    find vestab where vestab.etbcod = v-etbcod no-lock.

    display stream tela
            caps(vestab.etbnom) label "FILIAL" format "x(25)" colon 18
            vprog colon 18 label "ARQUIVO"
                with row 19 column 10 color white/red side-labels
                    title " LOJA A IMPORTAR " frame f1.

    view stream tela frame f1.
    
    def temp-table tt-nottra like nottra.
    
    if search("..\import\nottra.d") <> ?
    then do transaction:
        input from ..\import\nottra.d.
        repeat:
            for each tt-nottra.
                delete tt-nottra.
            end.
            create tt-nottra.
            import tt-nottra.
            find nottra where nottra.etbcod = tt-nottra.etbcod and
                              nottra.desti  = tt-nottra.desti  and
                              nottra.movtdc = tt-nottra.movtdc and
                              nottra.numero = tt-nottra.numero and
                              nottra.serie  = tt-nottra.serie no-error.
            if not avail nottra
            then do:
                create nottra.
                assign nottra.etbcod = tt-nottra.etbcod
                       nottra.desti  = tt-nottra.desti
                       nottra.movtdc = tt-nottra.movtdc
                       nottra.numero = tt-nottra.numero
                       nottra.serie  = tt-nottra.serie
                       nottra.datexp = tt-nottra.datexp.
            end.
        end.
    end.
    
    if search("..\import\deposito.d") <> ?
    then do:
        pause 0.
        input from ..\import\deposito.d no-echo.
        repeat:
            for each tt-deposito:
                delete tt-deposito.
            end.
            create tt-deposito.
            import tt-deposito.
            find deposito where deposito.etbcod = tt-deposito.etbcod and
                                deposito.datmov = tt-deposito.datmov no-error.
            if not avail deposito
            then do:
                create deposito.
                {tt-deposito.i deposito tt-deposito}.
             end.
        end.
        input close.
    end.

 
    
    if search("..\import\contnf.d") <> ?
    then do:
        pause 0.
        input from ..\import\contnf.d no-echo.
        repeat:
            create contnf.
            import contnf.
        end.
        input close.
    end.

    if search("..\import\montagem.d") <> ?
    then do:
        pause 0.
        input from ..\import\montagem.d no-echo.
        repeat:
            create montagem.
            import montagem.
        end.
        input close.
    end.
                         
                                                                   
    if search("..\import\cartao.d") <> ?
    then do:
        pause 0.
        input from ..\import\cartao.d no-echo.
        repeat:
    
            for each tt-cartao:
                delete tt-cartao.
            end.
            create tt-cartao.
            import tt-cartao.


            find cartao where cartao.carcod = tt-cartao.carcod and
                              cartao.numero = tt-cartao.numero and
                              cartao.placod = tt-cartao.placod no-error.
            if not avail cartao
            then do:
                create cartao.  
                assign cartao.carcod = tt-cartao.carcod  
                       cartao.numero = tt-cartao.numero  
                       cartao.placod = tt-cartao.placod
                       cartao.carval = tt-cartao.carval  
                       cartao.carven = tt-cartao.carven  
                       cartao.datexp = tt-cartao.datexp  
                       cartao.etbcod = tt-cartao.etbcod.
            end.
        end.                                                           
    end.
                                                                   
    if search("..\import\depban.d") <> ?
    then do:
        pause 0.
        input from ..\import\depban.d no-echo.
        repeat:
    
            for each tt-depban:
                delete tt-depban.
            end.
            create tt-depban.
            import tt-depban.


            find depban where depban.etbcod  = tt-depban.etbcod and
                              depban.datexp  = tt-depban.datexp and
                              depban.dephora = tt-depban.dephora no-error.
            if not avail depban
            then do:
                create depban.
                {depban.i depban tt-depban}.
            end.
        end.                                                           
    end.
    


    if search("..\import\globa.d") <> ?
    then do:
        pause 0.
        input from ..\import\globa.d no-echo.
        repeat:
            for each tt-globa:
                delete tt-globa.
            end.
            create tt-globa.
            import tt-globa.etbcod 
                   tt-globa.gloval 
                   tt-globa.glopar 
                   tt-globa.glogru 
                   tt-globa.glocot 
                   tt-globa.glodat
                   tt-globa.vencod
                   tt-globa.glocon.

            find globa where globa.etbcod = tt-globa.etbcod and
                             globa.glopar = tt-globa.glopar and
                             globa.glogru = tt-globa.glogru and
                             globa.glocot = tt-globa.glocot and
                             globa.glodat = tt-globa.glodat no-error.
            if not avail globa
            then do:
                create globa.
                assign globa.etbcod = tt-globa.etbcod
                       globa.gloval = tt-globa.gloval
                       globa.glopar = tt-globa.glopar
                       globa.glogru = tt-globa.glogru
                       globa.glocot = tt-globa.glocot
                       globa.glodat = tt-globa.glodat
                       globa.vencod = tt-globa.vencod
                       globa.glocon = tt-globa.glocon.

            end.           
            
        end.
        input close.
    end.

    if search("..\import\glopre.d") <> ?
    then do:
        pause 0.
        input from ..\import\glopre.d no-echo.
        repeat:
            for each tt-glopre:
                delete tt-glopre.
            end.
            create tt-glopre.
            import tt-glopre.etbcod 
                   tt-glopre.clicod 
                   tt-glopre.numero 
                   tt-glopre.parcela
                   tt-glopre.grupo  
                   tt-glopre.cota   
                   tt-glopre.gfcod  
                   tt-glopre.valpar 
                   tt-glopre.dtemi  
                   tt-glopre.dtven  
                   tt-glopre.dtpag  
                   tt-glopre.vencod 
                   tt-glopre.tippag 
                   tt-glopre.dtche  
                   tt-glopre.datexp 
                   tt-glopre.glosit.
            find glopre where glopre.etbcod  = tt-glopre.etbcod and
                              glopre.clicod  = tt-glopre.clicod and
                              glopre.numero  = tt-glopre.numero and
                              glopre.parcela = tt-glopre.parcela no-error.
            if not avail glopre
            then do:
                create glopre.
                assign glopre.etbcod  = tt-glopre.etbcod 
                       glopre.clicod  = tt-glopre.clicod 
                       glopre.numero  = tt-glopre.numero 
                       glopre.parcela = tt-glopre.parcela 
                       glopre.grupo   = tt-glopre.grupo 
                       glopre.cota    = tt-glopre.cota 
                       glopre.gfcod   = tt-glopre.gfcod 
                       glopre.valpar  = tt-glopre.valpar 
                       glopre.dtemi   = tt-glopre.dtemi 
                       glopre.dtven   = tt-glopre.dtven 
                       glopre.dtpag   = tt-glopre.dtpag 
                       glopre.vencod  = tt-glopre.vencod 
                       glopre.tippag  = tt-glopre.tippag 
                       glopre.dtche   = tt-glopre.dtche 
                       glopre.datexp  = tt-glopre.datexp 
                       glopre.glosit  = tt-glopre.glosit.
            end.
            else do:
                if tt-glopre.glosit = "PAG"
                then assign glopre.glosit = tt-glopre.glosit
                            glopre.datexp = tt-glopre.datexp
                            glopre.dtpag  = tt-glopre.dtpag.
            
            end.
        end.                      
    end.



    
    
    if search("..\import\nota.d") <> ?
    then do:
        pause 0.
        input from ..\import\nota.d no-echo.
        repeat:
            create nota.
            import nota.
        end.
        input close.
    end.

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
            create liped.
            import liped.
        end.
        input close.
    end.


    if search("..\import\plani.d") <> ?
    then do:
        pause 0.
        input from ..\import\plani.d no-echo.
        repeat:
            for each tt-plani:
                delete tt-plani.
            end.
            create tt-plani.
            import tt-plani.
            
            if tt-plani.etbcod >= 995
            then do:
                
                output to l:\gener\transm.log append.
                
                display tt-plani.etbcod
                        tt-plani.desti
                        tt-plani.movtdc format "99"
                        tt-plani.numero
                        tt-plani.serie with frame f-alerta width 80 down.
                output close.
                next.
            
            end.    
                     
                     
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
        end.
        input close.
    end.


    if search("..\import\movim.d") <> ?
    then do:
        pause 0.
        input from ..\import\movim.d no-echo.
        repeat:
            for each tt-movim:
                delete tt-movim.
            end.
            create tt-movim.
            import tt-movim.
            if tt-movim.etbcod >= 995
            then next.
            
            find movim where movim.etbcod = tt-movim.etbcod and
                             movim.placod = tt-movim.placod and
                             movim.procod = tt-movim.procod no-error.
            if not avail movim
            then do transaction:
                create movim.
                ASSIGN movim.movtdc    = tt-movim.movtdc 
                       movim.PlaCod    = tt-movim.PlaCod 
                       movim.etbcod    = tt-movim.etbcod 
                       movim.movseq    = tt-movim.movseq 
                       movim.procod    = tt-movim.procod 
                       movim.movqtm    = tt-movim.movqtm 
                       movim.movpc     = tt-movim.movpc 
                       movim.MovDev    = tt-movim.MovDev 
                       movim.MovAcFin  = tt-movim.MovAcFin 
                       movim.movipi    = tt-movim.movipi 
                       movim.MovPro    = tt-movim.MovPro 
                       movim.MovICMS   = tt-movim.MovICMS 
                       movim.MovAlICMS = tt-movim.MovAlICMS 
                       movim.MovPDesc  = tt-movim.MovPDesc 
                       movim.MovCtM    = tt-movim.MovCtM 
                       movim.MovAlIPI  = tt-movim.MovAlIPI 
                       movim.movdat    = tt-movim.movdat 
                       movim.MovHr     = tt-movim.MovHr 
                       movim.MovDes    = tt-movim.MovDes 
                       movim.MovSubst  = tt-movim.MovSubst. 
                       
                assign movim.OCNum[1]  = tt-movim.OCNum[1] 
                       movim.OCNum[2]  = tt-movim.OCNum[2] 
                       movim.OCNum[3]  = tt-movim.OCNum[3] 
                       movim.OCNum[4]  = tt-movim.OCNum[4] 
                       movim.OCNum[5]  = tt-movim.OCNum[5] 
                       movim.OCNum[6]  = tt-movim.OCNum[6] 
                       movim.OCNum[7]  = tt-movim.OCNum[7] 
                       movim.OCNum[8]  = tt-movim.OCNum[8] 
                       movim.OCNum[9]  = tt-movim.OCNum[9] 
                       movim.datexp    = tt-movim.datexp. 
 
                find first plani where plani.placod = movim.placod and
                                 plani.etbcod = movim.etbcod and
                                 plani.pladat = movim.movdat and
                                 plani.movtdc = movim.movtdc no-lock no-error.
                if avail plani
                then assign movim.desti = plani.desti
                            movim.emite = plani.emite.
       
                recmov = recid(movim).
                release movim.
                run atuest.p (input recmov,
                              input "I",
                              input 0).
            end.                  
        end.
        input close.
    end.

    run impmatmz.p.

    varq = "..\relat\" + STRING(TIME) + ".REL".

    output to value(varq).
    view frame fmostra.
    page.
    output to close.
    /*
    message "Imprime o Arquivo" varq "?" update sresp.
    if sresp
    then dos silent value("type " + varq + " > prn").
    */

    do transaction:
        do vdata = v-dtini to v-dtfin:
            find importa where importa.etbcod  = v-etbcod and
                               importa.importa = vdata no-error.
            if not avail importa
            then create importa.
            assign importa.etbcod  = v-etbcod
                   importa.importa = vdata.
        end.
    end.

    delete wf-prog.
    dos silent copy ..\import\l??????.d ..\import\log .
    
    dos silent del ..\import\*.d.
    dos silent del value(vprog).
end.
output stream stela close.
message "Imprimir importacao ?" update sresp.
if sresp
then dos silent value("type ..\import\exp.cpd " + " >prn").
