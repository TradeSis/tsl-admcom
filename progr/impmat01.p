/***************************************************************************
** Programa        : impmat.p
****************************************************************************/
{admcab.i}
def temp-table tt-deposito like deposito.
def temp-table tt-depban like depban.
def temp-table tt-cartao like cartao.
def temp-table tt-liped like liped.
def temp-table tt-pedid like pedid.
def temp-table tt-globa like globa.
def temp-table tt-contnf like contnf.
def temp-table wclien like clien.
def var vlog as l.
def temp-table tt-func like func.
def temp-table wtit like titulo.
def temp-table wtitulo
    field wdata like titulo.titdtemi
    field wvalor like titulo.titvlcob.



def var vetbi like estab.etbcod format ">>9".
def var vetbf like estab.etbcod format ">>9".

def var i as int.
def var vprog as char format "x(30)".
def var vdir as char format "x(30)".


def var recpla as recid.
def var recmov as recid.
def temp-table tt-plani like plani.
def temp-table tt-movim like movim.
def var ii as int.
def new shared frame fperiodo.
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
     "Notas               :" conta1 skip
     "Movimentos          :" conta2 skip
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
def var vaux as char.
def var vokdos  as log.
DEF VAR A AS CHAR FORMAT "X(40)".
/*
update vetbi label "Filial"
       vetbf label "Filial" 
        with frame ff1 side-label title "IMPORTACAO" CENTERED.
*/
vetbi = 01.
vetbf = 53.

/*
message "Confirma Importacao de Dados ? " update sresp.
if not sresp then return.
*/
do i = vetbi to vetbf:
    
    vdir  = "..\import\" + string(i,"99").
    

    vprog = "..\import\" + string(i,"99") + "\*.zip".
    
    dos silent pkunzip -o value(vprog) value(vdir).
end.


i = 0.


do i = vetbi to vetbf:
    find estab where estab.etbcod = i no-lock no-error.
    
    vdir  = "..\import\" + string(i,"99").
    
    conta1 = 0.
    conta2 = 0.
    conta3 = 0.

    pause 0 before-hide.
    if search("..\import\" + string(i,"99") + "\export.d") = ?
    then next.

    input from value("..\import\" + string(i,"99") + "\export.d") no-echo.
    repeat:
        set v-etbcod v-dtini v-dtfin.
    end.
    input close.

    {l:\progr\serial00.i}

    display v-dtini
            v-dtfin with frame fperiodo side-label centered.

    find vestab where vestab.etbcod = v-etbcod no-lock.

    display 
            caps(estab.etbnom) label "FILIAL" format "x(25)" colon 18
            vdir colon 18 label "ARQUIVO"
            vetbi label "Filial" colon 18
            " A "
            vetbf no-label 
                with row 17 column 10 color white/red side-labels
                    title " LOJA A IMPORTAR " frame f1.

    
    def temp-table tt-nottra like nottra.
    
    if search("..\import\" + string(i,"99") + "\nottra.d") <> ?
    then do transaction:
        
        input from value("..\import\" + string(i,"99") + "\nottra.d") no-echo.
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
    
    if search("..\import\" + string(i,"99") + "\deposito.d") <> ?
    then do:
        pause 0.
        input from value("..\import\" + string(i,"99") + "\deposito.d") no-echo.
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

 
                                                                   
    if search("..\import\" + string(i,"99") + "\contnf.d") <> ?
    then do:
        pause 0.
        input from value("..\import\" + string(i,"99") + "\contnf.d") no-echo.
        repeat:
            for each tt-contnf:
                delete tt-contnf.
            end.
            create tt-contnf.
            import tt-contnf.

            find contnf where contnf.etbcod  = tt-contnf.etbcod and
                              contnf.placod  = tt-contnf.placod and
                              contnf.contnum = tt-contnf.contnum no-error.
            if not avail contnf
            then do transaction:
                create contnf.
                assign contnf.contnum = tt-contnf.contnum
                       contnf.PlaCod  = tt-contnf.PlaCod
                       contnf.notanum = tt-contnf.notanum
                       contnf.notaser = tt-contnf.notaser 
                       contnf.EtbCod  = tt-contnf.EtbCod.            
            end.
        end.
        input close.
    end.
                                                                   
    if search("..\import\" + string(i,"99") + "\montagem.d") <> ?
    then do:
        pause 0.
        input from value("..\import\" + string(i,"99") + "\montagem.d") no-echo.
        repeat:
            create montagem.
            import montagem.
        end.
        input close.
    end.

                                                                   
    if search("..\import\" + string(i,"99") + "\globa.d") <> ?
    then do:
        pause 0.
        input from value("..\import\" + string(i,"99") + "\globa.d") no-echo.
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
    
                                                                   
    if search("..\import\" + string(i,"99") + "\cartao.d") <> ?
    then do:
        pause 0.
        input from value("..\import\" + string(i,"99") + "\cartao.d") no-echo.
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
                                                               
    if search("..\import\" + string(i,"99") + "\depban.d") <> ?
    then do:
        pause 0.

        input from value("..\import\" + string(i,"99") + "\depban.d") no-echo.
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
    

    
    if search("..\import\" + string(i,"99") + "\nota.d") <> ?
    then do:
        pause 0.
        input from value("..\import\" + string(i,"99") + "\nota.d") no-echo.
        repeat:
            create nota.
            import nota.
        end.
        input close.
    end.
                     
    /*                                                               
    if search("..\import\" + string(i,"99") + "\pedid.d") <> ?
    then do:
        pause 0.
        input from value("..\import\" + string(i,"99") + "\pedid.d") no-echo.
        repeat:
            for each tt-pedid.
                delete tt-pedid.
            end.
            create tt-pedid.
            import tt-pedid.
            find pedid where pedid.etbcod = tt-pedid.etbcod and
                             pedid.pedtdc = tt-pedid.pedtdc and
                             pedid.pednum = tt-pedid.pednum no-error.
            if not avail pedid
            then do:
                create pedid.
                assign pedid.pedtdc    = tt-pedid.pedtdc
                       pedid.pednum    = tt-pedid.pednum
                       pedid.regcod    = tt-pedid.regcod
                       pedid.peddat    = tt-pedid.peddat
                       pedid.comcod    = tt-pedid.comcod
                       pedid.pedsit    = tt-pedid.pedsit
                       pedid.fobcif    = tt-pedid.fobcif
                       pedid.nfdes     = tt-pedid.nfdes
                       pedid.ipides    = tt-pedid.ipides
                       pedid.dupdes    = tt-pedid.dupdes
                       pedid.cusefe    = tt-pedid.cusefe
                       pedid.condes    = tt-pedid.condes
                       pedid.condat    = tt-pedid.condat
                       pedid.crecod    = tt-pedid.crecod
                       pedid.peddti    = tt-pedid.peddti
                       pedid.peddtf    = tt-pedid.peddtf
                       pedid.acrfin    = tt-pedid.acrfin
                       pedid.sitped    = tt-pedid.sitped
                       pedid.vencod    = tt-pedid.vencod
                       pedid.frecod    = tt-pedid.frecod.
        
                assign pedid.modcod    = tt-pedid.modcod
                       pedid.etbcod    = tt-pedid.etbcod
                       pedid.pedtot    = tt-pedid.pedtot
                       pedid.clfcod    = tt-pedid.clfcod
                       pedid.pedobs[1] = tt-pedid.pedobs[1]
                       pedid.pedobs[2] = tt-pedid.pedobs[2]
                       pedid.pedobs[3] = tt-pedid.pedobs[3]
                       pedid.pedobs[4] = tt-pedid.pedobs[4]
                       pedid.pedobs[5] = tt-pedid.pedobs[5].
            end.
        end.
        input close.
    end.
                                                                   
    if search("..\import\" + string(i,"99") + "\liped.d") <> ?
    then do:
        pause 0.
        input from value("..\import\" + string(i,"99") + "\liped.d") no-echo.
        repeat:
            for each tt-liped:
                delete tt-liped.
            end.
            create tt-liped.
            import tt-liped.

            find liped where liped.pedtdc = tt-liped.pedtdc and
                             liped.etbcod = tt-liped.etbcod and
                             liped.pednum = tt-liped.pednum and
                             liped.procod = tt-liped.procod and
                             liped.predt  = tt-liped.predt  and
                             liped.lipcor = tt-liped.lipcor no-error.
            if not avail liped
            then do:
                create liped.
                ASSIGN liped.pedtdc   = tt-liped.pedtdc
                       liped.pednum   = tt-liped.pednum
                       liped.procod   = tt-liped.procod
                       liped.lipqtd   = tt-liped.lipqtd
                       liped.lippreco = tt-liped.lippreco
                       liped.lipsit   = tt-liped.lipsit
                       liped.lipent   = tt-liped.lipent
                       liped.predtf   = tt-liped.predtf
                       liped.predt    = tt-liped.predt
                       liped.lipcor   = tt-liped.lipcor
                       liped.etbcod   = tt-liped.etbcod.
                find produ where produ.procod = tt-liped.procod 
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
    */
                                     
    if search("..\import\" + string(i,"99") + "\plani.d") <> ?
    then do:
        pause 0.
        input from value("..\import\" + string(i,"99") + "\plani.d") no-echo.
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
        
            
            conta1 = conta1 + 1.
           

        end.
        input close.
        
    end.


                                                                   
    if search("..\import\" + string(i,"99") + "\movim.d") <> ?
    then do:
        pause 0.
        input from value("..\import\" + string(i,"99") + "\movim.d") no-echo.
        repeat:
            for each tt-movim:
                delete tt-movim.
            end.
            create tt-movim.
            import tt-movim.
            if tt-movim.etbcod = 999
            then next.
            find movim where movim.etbcod = tt-movim.etbcod and
                             movim.placod = tt-movim.placod and
                             movim.procod = tt-movim.procod no-error.
            if not avail movim
            then do transaction:
                create movim.
                assign movim.movtdc    = tt-movim.movtdc
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
                       movim.MovSubst  = tt-movim.MovSubst
                       movim.OCNum[1]  = tt-movim.OCNum[1]
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
                run l:\progr\atuest.p (input recmov,
                              input "I",
                              input 0).
        
            end.

            conta2 = conta2 + 1.
          end.
        input close.
    end.

    /***********/
    conta3 = 0.
    conta4 = 0.
    conta5 = 0.


    for each wtitulo.
        delete wtitulo.
    end.
    input from value("..\import\" + string(i,"99") + "\titulo.d") no-echo.
    repeat with frame ftitulo:
        
        for each wtit:
            delete wtit.
        end.
        create wtit.
        import wtit.empcod   
               wtit.modcod   
               wtit.CliFor   
               wtit.titnum   
               wtit.titpar   
               wtit.titnat   
               wtit.etbcod   
               wtit.titdtemi 
               wtit.titdtven 
               wtit.titvlcob 
               wtit.titdtdes 
               wtit.titvldes 
               wtit.titvljur 
               wtit.cobcod   
               wtit.bancod   
               wtit.agecod   
               wtit.titdtpag 
               wtit.titdesc  
               wtit.titjuro  
               wtit.titvlpag
               wtit.titbanpag 
               wtit.titagepag 
               wtit.titchepag 
               wtit.titobs[1] 
               wtit.titobs[2] 
               wtit.titsit    
               wtit.titnumger 
               wtit.titparger 
               wtit.cxacod    
               wtit.evecod    
               wtit.cxmdata   
               wtit.cxmhora   
               wtit.vencod    
               wtit.etbCobra  
               wtit.datexp    
               wtit.moecod.   

        
        find titulo where
             titulo.empcod = wtit.empcod and
             titulo.titnat = wtit.titnat and
             titulo.modcod = wtit.modcod and
             titulo.etbcod = wtit.etbcod and
             titulo.clifor = wtit.clifor and
             titulo.titnum = wtit.titnum and
             titulo.titpar = wtit.titpar no-error.

        vlog = no.
        if not available titulo
        then do:
            if  wtit.clifor <> 1 and
                wtit.titsit = "PAG" and
                wtit.titpar <> 0
            then do transaction:
                create titexporta.
                ASSIGN titexporta.empcod    = wtit.empcod
                       titexporta.modcod    = wtit.modcod
                       titexporta.CliFor    = wtit.CliFor
                       titexporta.titnum    = wtit.titnum
                       titexporta.titpar    = wtit.titpar
                       titexporta.titnat    = wtit.titnat
                       titexporta.etbcod    = wtit.etbcod
                       titexporta.titdtemi  = wtit.titdtemi
                       titexporta.titdtven  = wtit.titdtven
                       titexporta.titvlcob  = wtit.titvlcob
                       titexporta.titdtdes  = wtit.titdtdes
                       titexporta.titvldes  = wtit.titvldes
                       titexporta.titvljur  = wtit.titvljur
                       titexporta.cobcod    = wtit.cobcod
                       titexporta.bancod    = wtit.bancod
                       titexporta.agecod    = wtit.agecod
                       titexporta.titdtpag  = wtit.titdtpag
                       titexporta.titdesc   = wtit.titdesc
                       titexporta.titjuro   = wtit.titjuro
                       titexporta.titvlpag  = wtit.titvlpag
                       titexporta.titbanpag = wtit.titbanpag
                       titexporta.titagepag = wtit.titagepag
                       titexporta.titchepag = wtit.titchepag
                       titexporta.titobs[1] = wtit.titobs[1]
                       titexporta.titobs[2] = wtit.titobs[2]
                       titexporta.titsit    = wtit.titsit
                       titexporta.titnumger = wtit.titnumger
                       titexporta.titparger = wtit.titparger
                       titexporta.cxacod    = wtit.cxacod
                       titexporta.evecod    = wtit.evecod
                       titexporta.cxmdata   = wtit.cxmdata
                       titexporta.cxmhora   = wtit.cxmhora
                       titexporta.vencod    = wtit.vencod
                       titexporta.etbCobra  = wtit.etbCobra
                       titexporta.datexp    = wtit.datexp
                       titexporta.moecod    = wtit.moecod.
            end.
            do transaction:
                create titulo.
                ASSIGN titulo.empcod    = wtit.empcod
                       titulo.modcod    = wtit.modcod
                       titulo.CliFor    = wtit.CliFor
                       titulo.titnum    = wtit.titnum
                       titulo.titpar    = wtit.titpar
                       titulo.titnat    = wtit.titnat
                       titulo.etbcod    = wtit.etbcod
                       titulo.titdtemi  = wtit.titdtemi
                       titulo.titdtven  = wtit.titdtven
                       titulo.titvlcob  = wtit.titvlcob
                       titulo.titdtdes  = wtit.titdtdes
                       titulo.titvldes  = wtit.titvldes
                       titulo.titvljur  = wtit.titvljur
                       titulo.cobcod    = wtit.cobcod
                       titulo.bancod    = wtit.bancod
                       titulo.agecod    = wtit.agecod
                       titulo.titdtpag  = wtit.titdtpag
                       titulo.titdesc   = wtit.titdesc
                       titulo.titjuro   = wtit.titjuro
                       titulo.titvlpag  = wtit.titvlpag
                       titulo.titbanpag = wtit.titbanpag
                       titulo.titagepag = wtit.titagepag
                       titulo.titchepag = wtit.titchepag
                       titulo.titobs[1] = wtit.titobs[1]
                       titulo.titobs[2] = wtit.titobs[2]
                       titulo.titsit    = if wtit.titsit = "IMP"
                                          then "LIB"
                                          else wtit.titsit
                       titulo.titnumger = wtit.titnumger
                       titulo.titparger = wtit.titparger
                       titulo.cxacod    = wtit.cxacod
                       titulo.evecod    = wtit.evecod
                       titulo.cxmdata   = wtit.cxmdata
                       titulo.cxmhora   = wtit.cxmhora
                       titulo.vencod    = wtit.vencod
                       titulo.etbCobra  = wtit.etbCobra
                       titulo.datexp    = wtit.datexp
                       titulo.datexp    = today
                       titulo.moecod    = wtit.moecod.
            
            end.    
        end.
        else do:
            if wtit.titdtpag <> ? and
               titulo.titsit <> "PAG"
            then do transaction:
                assign    titulo.titdtdes  = wtit.titdtdes
                          titulo.titvldes  = wtit.titvldes
                           titulo.titvljur  = wtit.titvljur
                           titulo.cobcod    = wtit.cobcod
                           titulo.bancod    = wtit.bancod
                           titulo.agecod    = wtit.agecod
                           titulo.titdtpag  = wtit.titdtpag
                           titulo.titdesc   = wtit.titdesc
                           titulo.titjuro   = wtit.titjuro
                           titulo.titvlpag  = wtit.titvlpag
                           titulo.titbanpag = wtit.titbanpag
                           titulo.titagepag = wtit.titagepag
                           titulo.titchepag = wtit.titchepag
                           titulo.titobs[1] = wtit.titobs[1]
                           titulo.titobs[2] = wtit.titobs[2]
                           titulo.titsit    = wtit.titsit
                           titulo.titnumger = wtit.titnumger
                           titulo.titparger = wtit.titparger
                           titulo.cxacod    = wtit.cxacod
                           titulo.evecod    = wtit.evecod
                           titulo.cxmdata   = wtit.cxmdata
                           titulo.cxmhora   = wtit.cxmhora
                           titulo.vencod    = wtit.vencod
                           titulo.etbCobra  = wtit.etbCobra
                           titulo.datexp    = wtit.datexp
                           titulo.datexp    = today
                           titulo.moecod    = wtit.moecod.
            end.
        end.
        if vlog = no
        then do:
            if wtit.titdtpag <> ? and
               titulo.titdtpag <> ?
            then do:
                if wtit.titdtpag <> titulo.titdtpag or
                   wtit.titvlpag <> titulo.titvlpag or
                   wtit.etbcobra <> titulo.etbcobra
                then do transaction:
                    create titexporta.
                    ASSIGN titexporta.empcod    = wtit.empcod
                           titexporta.modcod    = wtit.modcod
                           titexporta.CliFor    = wtit.CliFor
                           titexporta.titnum    = wtit.titnum
                           titexporta.titpar    = wtit.titpar
                           titexporta.titnat    = wtit.titnat
                           titexporta.etbcod    = wtit.etbcod
                           titexporta.titdtemi  = wtit.titdtemi
                           titexporta.titdtven  = wtit.titdtven
                           titexporta.titvlcob  = wtit.titvlcob
                           titexporta.titdtdes  = wtit.titdtdes
                           titexporta.titvldes  = wtit.titvldes
                           titexporta.titvljur  = wtit.titvljur
                           titexporta.cobcod    = wtit.cobcod
                           titexporta.bancod    = wtit.bancod
                           titexporta.agecod    = wtit.agecod
                           titexporta.titdtpag  = wtit.titdtpag
                           titexporta.titdesc   = wtit.titdesc
                           titexporta.titjuro   = wtit.titjuro
                           titexporta.titvlpag  = wtit.titvlpag
                           titexporta.titbanpag = wtit.titbanpag
                           titexporta.titagepag = wtit.titagepag
                           titexporta.titchepag = wtit.titchepag
                           titexporta.titobs[1] = wtit.titobs[1]
                           titexporta.titobs[2] = wtit.titobs[2]
                           titexporta.titsit    = wtit.titsit
                           titexporta.titnumger = wtit.titnumger
                           titexporta.titparger = wtit.titparger
                           titexporta.cxacod    = wtit.cxacod
                           titexporta.evecod    = wtit.evecod
                           titexporta.cxmdata   = wtit.cxmdata
                           titexporta.cxmhora   = wtit.cxmhora
                           titexporta.vencod    = wtit.vencod
                           titexporta.etbCobra  = wtit.etbCobra
                           titexporta.datexp    = wtit.datexp
                           titexporta.moecod    = wtit.moecod.

                end.
            end.
        end.
   
        conta3 = conta3 + 1.
   end.

    def temp-table tt-contrato like contrato.
    if search("..\import\" + string(i,"99") + "\contrato.d") <> ?
    then do:
        pause 0.
        input from value("..\import\" + string(i,"99") + "\contrato.d") no-echo.
        repeat:
        
            do transaction:
                for each tt-contrato:
                    delete tt-contrato.
                end.
                create tt-contrato.
                import tt-contrato.
                find contrato where
                     contrato.contnum = tt-contrato.contnum no-error.
        
                if not available contrato
                then create contrato.
                ASSIGN
                        contrato.contnum   = tt-contrato.contnum
                        contrato.clicod    = tt-contrato.clicod
                        contrato.autoriza  = tt-contrato.autoriza
                        contrato.dtinicial = tt-contrato.dtinicial
                        contrato.etbcod    = tt-contrato.etbcod
                        contrato.banco     = tt-contrato.banco
                        contrato.vltotal   = tt-contrato.vltotal
                        contrato.vlentra   = tt-contrato.vlentra
                        contrato.situacao  = tt-contrato.situacao
                        contrato.indimp    = tt-contrato.indimp
                        contrato.lotcod    = tt-contrato.lotcod
                        contrato.crecod    = tt-contrato.crecod
                        contrato.datexp    = tt-contrato.datexp
                        contrato.datexp    = today
                        contrato.vlfrete   = tt-contrato.vlfrete.
                assign      
                    vtotcont = vtotcont + 1
                    vtotvl   = vtotvl   + contrato.vltotal.
                
                conta4 = conta4 + 1.
                 find salexporta where salexporta.etbcod = contrato.etbcod
                                  and salexporta.cxacod = 0
                                  and salexporta.saldt  = contrato.dtinicial
                                  and salexporta.modcod = "CRE"
                                  and salexporta.moecod = "REA" no-error.
                                
                if not avail salexporta
                then create salexporta.
                assign salexporta.etbcod = contrato.etbcod
                       salexporta.cxacod = 0
                       salexporta.SalDt  = contrato.dtinicial
                       salexporta.dtexp  = contrato.dtinicial
                       salexporta.moecod = "REA"
                       salexporta.modcod = "CRE"
                   salexporta.salimp = salexporta.salimp + tt-contrato.vltotal.
                for each titulo use-index titnum where
                                    titulo.empcod = wempre.empcod and
                                    titulo.titnat = no and
                                    titulo.modcod = "CRE" and
                                    titulo.etbcod = contrato.etbcod and
                                    titulo.clifor = contrato.clicod and
                                    titulo.titnum = string(contrato.contnum)
                                        no-lock:
                    salexporta.salexp = salexporta.salexp + titulo.titvlcob.
            
                end.
            end.
             end.
        output close.
     end.

    if search("..\import\" + string(i,"99") + "\func.d") <> ?
    then do:
        pause 0.
        input from value("..\import\" + string(i,"99") + "\func.d") no-echo.
        repeat:
            for each tt-func:
                delete tt-func.
            end.
            create tt-func.
            import tt-func.

            find func where func.etbcod  = tt-func.etbcod and
                            func.funcod  = tt-func.funcod no-error.
            do transaction:
                if  not available func
                then do:
                    create func.
                    ASSIGN func.aplicod   = tt-func.aplicod
                           func.etbcod    = tt-func.etbcod
                           func.funcod    = tt-func.funcod
                           func.funape    = tt-func.funape
                           func.fundtcad  = tt-func.fundtcad
                           func.funfunc   = tt-func.funfunc
                           func.funmec    = tt-func.funmec
                           func.funnom    = tt-func.funnom
                           func.funsit    = tt-func.funsit
                           func.opatual   = tt-func.opatual
                           func.senha     = tt-func.senha.
                       /*  func.usercod   = tt-func.usercod. */
                end.
            end.
         end.
        input close.
     end.
    /******* clientes *********/
    if search("..\import\" + string(i,"99") + "\clien.d") <> ?
    then do:
        pause 0.
        input from value("..\import\" + string(i,"99") + "\clien.d") no-echo.
        repeat:
            for each wclien:
                delete wclien.
            end.
            create wclien.
            import wclien.
            find clien where
                 clien.clicod = wclien.clicod no-error.
            if not available clien
            then do:
                create clien.
                assign clien.clinom         = wclien.clinom
                       clien.sexo           = wclien.sexo
                       clien.dtnasc         = if wclien.dtnasc <> ?
                                              then wclien.dtnasc
                                              else clien.dtnasc
                       clien.ciinsc         = if wclien.ciinsc <> ?
                                              then wclien.ciinsc
                                              else clien.ciinsc
                       clien.ciccgc         = if wclien.ciccgc <> ?
                                              then wclien.ciccgc
                                              else clien.ciccgc
                       clien.pai            = if wclien.pai <> ?
                                              then wclien.pai
                                              else clien.pai
                       clien.mae            = if wclien.mae <> ?
                                              then wclien.mae
                                              else clien.mae.
            end.
            ASSIGN
                clien.clicod         = wclien.clicod
                clien.tippes         = wclien.tippes
                clien.estciv         = if wclien.estciv <> ?
                                       then wclien.estciv
                                       else clien.estciv
                clien.nacion         = if wclien.nacion <> ?
                                       then wclien.nacion
                                       else clien.nacion
                clien.natur          = if wclien.natur <> ?
                                       then wclien.natur
                                        else clien.natur
                clien.endereco[1]    = if wclien.endereco[1] <> ?
                                       then wclien.endereco[1]
                                       else clien.endereco[1]
                clien.endereco[2]    = if wclien.endereco[2] <> ?
                                       then wclien.endereco[2]
                                       else clien.endereco[2]
                clien.endereco[3]    = if wclien.endereco[3] <> ?
                                       then wclien.endereco[3]
                                       else clien.endereco[3]
                clien.endereco[4]    = if wclien.endereco[4] <> ?
                                       then wclien.endereco[4]
                                       else clien.endereco[4]
                clien.numero[1]      = if wclien.numero[1] <> ?
                                       then wclien.numero[1]
                                       else clien.numero[1]
                clien.numero[2]      = if wclien.numero[2] <> ?
                                       then wclien.numero[2]
                                       else clien.numero[2]
                clien.numero[3]      = if wclien.numero[3] <> ?
                                       then wclien.numero[3]
                                       else clien.numero[3]
                clien.numero[4]      = if wclien.numero[4] <> ?
                                       then wclien.numero[4]
                                       else clien.numero[4]
                clien.numdep         = if wclien.numdep <> ?
                                       then wclien.numdep
                                       else clien.numdep
                clien.compl[1]       = if wclien.compl[1] <> ?
                                       then wclien.compl[1]
                                       else clien.compl[1]
                clien.compl[2]       = if wclien.compl[2] <> ?
                                       then wclien.compl[2]
                                       else clien.compl[2]
                clien.compl[3]       = if wclien.compl[3] <> ?
                                       then wclien.compl[3]
                                       else clien.compl[3]
                clien.compl[4]       = if wclien.compl[4] <> ?
                                       then wclien.compl[4]
                                       else clien.compl[4]
                clien.bairro[1]      = if wclien.bairro[1] <> ?
                                       then wclien.bairro[1]
                                       else clien.bairro[1].
            
            assign
                clien.bairro[2]      = if wclien.bairro[2] <> ?
                                       then wclien.bairro[2]
                                       else clien.bairro[2]
                clien.bairro[3]      = if wclien.bairro[3] <> ?
                                       then wclien.bairro[3]
                                       else clien.bairro[3]
                clien.bairro[4]      = if wclien.bairro[4] <> ?
                                       then wclien.bairro[4]
                                       else clien.bairro[4]
                clien.cidade[1]      = if wclien.cidade[1] <> ?
                                       then wclien.cidade[1]
                                       else clien.cidade[1]
                clien.cidade[2]      = if wclien.cidade[2] <> ?
                                       then wclien.cidade[2]
                                       else clien.cidade[2]
                clien.cidade[3]      = if wclien.cidade[3] <> ?
                                       then wclien.cidade[3]
                                       else clien.cidade[3]
                clien.cidade[4]      = if wclien.cidade[4] <> ?
                                       then wclien.cidade[4]
                                       else clien.cidade[4]
                clien.ufecod[1]      = if wclien.ufecod[1] <> ?
                                       then wclien.ufecod[1]
                                       else clien.ufecod[1]
                clien.ufecod[2]      = if wclien.ufecod[2] <> ?
                                       then wclien.ufecod[2]
                                       else clien.ufecod[2]
                clien.ufecod[3]      = if wclien.ufecod[3] <> ?
                                       then wclien.ufecod[3]
                                       else clien.ufecod[3]
                clien.ufecod[4]      = if wclien.ufecod[4] <> ?
                                       then wclien.ufecod[4]
                                       else clien.ufecod[4]
                clien.fone           = if wclien.fone <> ?
                                       then wclien.fone
                                       else clien.fone
                clien.tipres         = if wclien.tipres <> ?
                                       then wclien.tipres
                                       else clien.tipres
                clien.vlalug         = if wclien.vlalug <> ?
                                       then wclien.vlalug
                                       else clien.vlalug
                clien.temres         = if wclien.temres <> ?
                                       then wclien.temres
                                       else clien.temres
                clien.proemp[1]      = if wclien.proemp[1] <> ?
                                       then wclien.proemp[1]
                                       else clien.proemp[1]
                clien.proemp[2]      = if wclien.proemp[2] <> ?
                                       then wclien.proemp[2]
                                       else clien.proemp[2]
                clien.protel[1]      = if wclien.protel[1] <> ?
                                       then wclien.protel[1]
                                       else clien.protel[1]
                clien.protel[2]      = if wclien.protel[2] <> ?
                                       then wclien.protel[2]
                                       else clien.protel[2]
                clien.prodta[1]      = if wclien.prodta[1] <> ?
                                       then wclien.prodta[1]
                                       else clien.prodta[1]
                clien.prodta[2]      = if wclien.prodta[2] <> ?
                                       then wclien.prodta[2]
                                       else clien.prodta[2]
                clien.proprof[1]     = if wclien.proprof[1] <> ?
                                           then wclien.proprof[1]
                                           else clien.proprof[1].
            assign
                clien.proprof[2]     = if wclien.proprof[2] <> ?
                                       then wclien.proprof[2]
                                       else clien.proprof[2]
                clien.prorenda[1]    = if wclien.prorenda[1] <> ?
                                       then wclien.prorenda[1]
                                       else clien.prorenda[1]
                clien.prorenda[2]    = if wclien.prorenda[2] <> ?
                                       then wclien.prorenda[2]
                                       else clien.prorenda[2]
                clien.conjuge        = if wclien.conjuge <> ?
                                       then wclien.conjuge
                                       else clien.conjuge
                clien.nascon         = if wclien.nascon <> ?
                                       then wclien.nascon
                                       else clien.nascon
                clien.refcom[1]      = if wclien.refcom[1] <> ?
                                       then wclien.refcom[1]
                                       else clien.refcom[1]
                clien.refcom[2]      = if wclien.refcom[2] <> ?
                                       then wclien.refcom[2]
                                       else clien.refcom[2]
                clien.refcom[3]      = if wclien.refcom[3] <> ?
                                       then wclien.refcom[3]
                                       else clien.refcom[3]
                clien.refcom[4]      = if wclien.refcom[4] <> ?
                                       then wclien.refcom[4]
                                       else clien.refcom[4]
                clien.refcom[5]      = if wclien.refcom[5] <> ?
                                       then wclien.refcom[5]
                                       else clien.refcom[5]
                clien.refnome        = if wclien.refnome <> ?
                                       then wclien.refnome
                                       else clien.refnome
                clien.reftel         = if wclien.reftel <> ?
                                       then wclien.reftel
                                       else clien.reftel
                clien.classe         = if wclien.classe <> ?
                                       then wclien.classe
                                       else clien.classe
                clien.limite         = if wclien.limite <> ?
                                       then wclien.limite
                                       else clien.limite
                clien.medatr         = if wclien.medatr <> ?
                                       then wclien.medatr
                                       else clien.medatr
                clien.dtcad          = if wclien.dtcad <> ?
                                       then wclien.dtcad
                                       else clien.dtcad
                clien.situacao       = if wclien.situacao <> ?
                                       then wclien.situacao
                                       else clien.situacao
                clien.dtspc[1]       = if wclien.dtspc[1] <> ?
                                       then wclien.dtspc[1]
                                       else clien.dtspc[1]
                clien.dtspc[2]       = if wclien.dtspc[2] <> ?
                                       then wclien.dtspc[2]
                                       else clien.dtspc[2]
                clien.dtspc[3]       = if wclien.dtspc[3] <> ?
                                       then wclien.dtspc[3]
                                       else clien.dtspc[3]
                clien.autoriza[1]    = if wclien.autoriza[1] <> ?
                                       then wclien.autoriza[1]
                                       else clien.autoriza[1]
                clien.autoriza[2]    = if wclien.autoriza[2] <> ?
                                       then wclien.autoriza[2]
                                       else clien.autoriza[2]
                clien.autoriza[3]    = if wclien.autoriza[3] <> ?
                                       then wclien.autoriza[3]
                                       else clien.autoriza[3]
                clien.autoriza[4]    = if wclien.autoriza[4] <> ?
                                           then wclien.autoriza[4]
                                           else clien.autoriza[4]
                clien.autoriza[5]    = if wclien.autoriza[5] <> ?
                                       then wclien.autoriza[5]
                                       else clien.autoriza[5]
                clien.conjpai        = if wclien.conjpai <> ?
                                       then wclien.conjpai
                                       else clien.conjpai.
                assign
                    clien.conjmae        = if wclien.conjmae <> ?
                                           then wclien.conjmae
                                           else clien.conjmae
                    clien.cep[1]         = if wclien.cep[1] <> ?
                                           then wclien.cep[1]
                                           else clien.cep[1]
                    clien.cep[2]         = if wclien.cep[2] <> ?
                                           then wclien.cep[2]
                                           else clien.cep[2]
                    clien.cep[3]         = if wclien.cep[3] <> ?
                                           then wclien.cep[3]
                                           else clien.cep[3]
                    clien.cep[4]         = if wclien.cep[4] <> ?
                                           then wclien.cep[4]
                                           else clien.cep[4]
                    clien.cobbairro[1]   = if wclien.cobbairro[1] <> ?
                                           then wclien.cobbairro[1]
                                           else clien.cobbairro[1]
                    clien.cobbairro[2]   = if wclien.cobbairro[2] <> ?
                                           then wclien.cobbairro[2]
                                           else clien.cobbairro[2]
                    clien.cobbairro[3]   = if wclien.cobbairro[3] <> ?
                                           then wclien.cobbairro[3]
                                           else clien.cobbairro[3]
                    clien.cobbairro[4]   = if wclien.cobbairro[4] <> ?
                                           then wclien.cobbairro[4]
                                           else clien.cobbairro[4]
                    clien.cobcep[1]      = if wclien.cobcep[1] <> ?
                                           then wclien.cobcep[1]
                                           else clien.cobcep[1]
                    clien.cobcep[2]      = if wclien.cobcep[2] <> ?
                                           then wclien.cobcep[2]
                                           else clien.cobcep[2]
                    clien.cobcep[3]      = if wclien.cobcep[3] <> ?
                                           then wclien.cobcep[3]
                                           else clien.cobcep[3]
                    clien.cobcep[4]      = if wclien.cobcep[4] <> ?
                                           then wclien.cobcep[4]
                                           else clien.cobcep[4]
                    clien.cobcidade[1]   = if wclien.cobcidade[1] <> ?
                                           then wclien.cobcidade[1]
                                           else clien.cobcidade[1]
                    clien.cobcidade[2]   = if wclien.cobcidade[2] <> ?
                                           then wclien.cobcidade[2]
                                           else clien.cobcidade[2]
                    clien.cobcidade[3]   = if wclien.cobcidade[3] <> ?
                                           then wclien.cobcidade[3]
                                           else clien.cobcidade[3]
                    clien.cobcidade[4]   = if wclien.cobcidade[4] <> ?
                                           then wclien.cobcidade[4]
                                           else clien.cobcidade[4]
                    clien.cobcompl[1]    = if wclien.cobcompl[1] <> ?
                                           then wclien.cobcompl[1]
                                           else clien.cobcompl[1]
                    clien.cobcompl[2]    = if wclien.cobcompl[2] <> ?
                                           then wclien.cobcompl[2]
                                           else clien.cobcompl[2]
                    clien.cobcompl[3]    = if wclien.cobcompl[3] <> ?
                                           then wclien.cobcompl[3]
                                           else clien.cobcompl[3]
                    clien.cobcompl[4]    = if wclien.cobcompl[4] <> ?
                                           then wclien.cobcompl[4]
                                           else clien.cobcompl[4]
                    clien.cobendereco[1] = if wclien.cobendereco[1] <> ?
                                           then wclien.cobendereco[1]
                                           else clien.cobendereco[1]
                    clien.cobendereco[2] = if wclien.cobendereco[2] <> ?
                                           then wclien.cobendereco[2]
                                           else clien.cobendereco[2]
                    clien.cobendereco[3] = if wclien.cobendereco[3] <> ?
                                           then wclien.cobendereco[3]
                                           else clien.cobendereco[3]
                    clien.cobendereco[4] = if wclien.cobendereco[4] <> ?
                                           then wclien.cobendereco[4]
                                           else clien.cobendereco[4]
                    clien.cfobnumero[1]  = if wclien.cfobnumero[1] <> ?
                                           then wclien.cfobnumero[1]
                                           else clien.cfobnumero[1]
                    clien.cfobnumero[2]  = if wclien.cfobnumero[2] <> ?
                                           then wclien.cfobnumero[2]
                                           else clien.cfobnumero[2]
                    clien.cfobnumero[3]  = if wclien.cfobnumero[3] <> ?
                                           then wclien.cfobnumero[3]
                                           else clien.cfobnumero[3]
                    clien.cfobnumero[4]  = if wclien.cfobnumero[4] <> ?
                                           then wclien.cfobnumero[4]
                                           else clien.cfobnumero[4].
                assign
                    clien.cobrefcom[1]   = if wclien.cobrefcom[1] <> ?
                                           then wclien.cobrefcom[1]
                                           else clien.cobrefcom[1]
                    clien.cobrefcom[2]   = if wclien.cobrefcom[2] <> ?
                                           then wclien.cobrefcom[2]
                                           else clien.cobrefcom[2]
                    clien.cobrefcom[3]   = if wclien.cobrefcom[3] <> ?
                                           then wclien.cobrefcom[3]
                                           else clien.cobrefcom[3]
                    clien.cobrefcom[4]   = if wclien.cobrefcom[4] <> ?
                                           then wclien.cobrefcom[4]
                                           else clien.cobrefcom[4]
                    clien.cobrefcom[5]   = if wclien.cobrefcom[5] <> ?
                                           then wclien.cobrefcom[5]
                                           else clien.cobrefcom[5]
                    clien.cobrefnome     = if wclien.cobrefnome <> ?
                                           then wclien.cobrefnome
                                           else clien.cobrefnome
                    clien.cobufecod[1]   = if wclien.cobufecod[1] <> ?
                                           then wclien.cobufecod[1]
                                           else clien.cobufecod[1]
                    clien.cobufecod[2]   = if wclien.cobufecod[2] <> ?
                                           then wclien.cobufecod[2]
                                           else clien.cobufecod[2]
                    clien.cobufecod[3]   = if wclien.cobufecod[3] <> ?
                                           then wclien.cobufecod[3]
                                           else clien.cobufecod[3]
                    clien.cobufecod[4]   = if wclien.cobufecod[4] <> ?
                                           then wclien.cobufecod[4]
                                           else clien.cobufecod[4]
                    clien.refccont[1]    = if wclien.refccont[1] <> ?
                                           then wclien.refccont[1]
                                           else clien.refccont[1]
                    clien.refccont[2]    = if wclien.refccont[2] <> ?
                                           then wclien.refccont[2]
                                           else clien.refccont[2]
                    clien.refccont[3]    = if wclien.refccont[3] <> ?
                                           then wclien.refccont[3]
                                           else clien.refccont[3]
                    clien.refccont[4]    = if wclien.refccont[4] <> ?
                                           then wclien.refccont[4]
                                           else clien.refccont[4]
                    clien.refccont[5]    = if wclien.refccont[5] <> ?
                                           then wclien.refccont[5]
                                           else clien.refccont[5]
                    clien.refctel[1]     = if wclien.refctel[1] <> ?
                                           then wclien.refctel[1]
                                           else clien.refctel[1]
                    clien.refctel[2]     = if wclien.refctel[2] <> ?
                                           then wclien.refctel[2]
                                           else clien.refctel[2]
                    clien.refctel[3]     = if wclien.refctel[3] <> ?
                                           then wclien.refctel[3]
                                           else clien.refctel[3]
                    clien.refctel[4]     = if wclien.refctel[4] <> ?
                                           then wclien.refctel[4]
                                           else clien.refctel[4]
                    clien.refctel[5]     = if wclien.refctel[5] <> ?
                                           then wclien.refctel[5]
                                           else clien.refctel[5].
                assign
                    clien.refcinfo[1]    = if wclien.refcinfo[1] <> ?
                                           then wclien.refcinfo[1]
                                           else clien.refcinfo[1]
                    clien.refcinfo[2]    = if wclien.refcinfo[2] <> ?
                                           then wclien.refcinfo[2]
                                           else clien.refcinfo[2]
                    clien.refcinfo[3]    = if wclien.refcinfo[3] <> ?
                                           then wclien.refcinfo[3]
                                           else clien.refcinfo[3]
                    clien.refcinfo[4]    = if wclien.refcinfo[4] <> ?
                                           then wclien.refcinfo[4]
                                           else clien.refcinfo[4]
                    clien.refcinfo[5]    = if wclien.refcinfo[5] <> ?
                                           then wclien.refcinfo[5]
                                           else clien.refcinfo[5]
                    clien.refbcont[1]    = if wclien.refbcont[1] <> ?
                                           then wclien.refbcont[1]
                                           else clien.refbcont[1]
                    clien.refbcont[2]    = if wclien.refbcont[2] <> ?
                                           then wclien.refbcont[2]
                                           else clien.refbcont[2]
                    clien.refbcont[3]    = if wclien.refbcont[3] <> ?
                                           then wclien.refbcont[3]
                                           else clien.refbcont[3]
                    clien.refbcont[4]    = if wclien.refbcont[4] <> ?
                                           then wclien.refbcont[4]
                                           else clien.refbcont[4]
                    clien.refbcont[5]    = if wclien.refbcont[5] <> ?
                                           then wclien.refbcont[5]
                                           else clien.refbcont[5]
                    clien.refbinfo[1]    = if wclien.refbinfo[1] <> ?
                                           then wclien.refbinfo[1]
                                           else clien.refbinfo[1]
                    clien.refbinfo[2]    = if wclien.refbinfo[2] <> ?
                                           then wclien.refbinfo[2]
                                           else clien.refbinfo[2]
                    clien.refbinfo[3]    = if wclien.refbinfo[3] <> ?
                                           then wclien.refbinfo[3]
                                           else clien.refbinfo[3]
                    clien.refbinfo[4]    = if wclien.refbinfo[4] <> ?
                                           then wclien.refbinfo[4]
                                           else clien.refbinfo[4]
                    clien.refbinfo[5]    = if wclien.refbinfo[5] <> ?
                                           then wclien.refbinfo[5]
                                           else clien.refbinfo[5]
                    clien.refban[1]      = if wclien.refban[1] <> ?
                                           then wclien.refban[1]
                                           else clien.refban[1]
                    clien.refban[2]      = if wclien.refban[2] <> ?
                                           then wclien.refban[2]
                                           else clien.refban[2]
                    clien.refban[3]      = if wclien.refban[3] <> ?
                                           then wclien.refban[3]
                                           else clien.refban[3]
                    clien.refban[4]      = if wclien.refban[4] <> ?
                                           then wclien.refban[4]
                                           else clien.refban[4]
                    clien.refban[5]      = if wclien.refban[5] <> ?
                                           then wclien.refban[5]
                                           else clien.refban[5].
                assign
                    clien.refbtel[1]     = if wclien.refbtel[1] <> ?
                                           then wclien.refbtel[1]
                                           else clien.refbtel[1]
                    clien.refbtel[2]     = if wclien.refbtel[2] <> ?
                                           then wclien.refbtel[2]
                                           else clien.refbtel[2]
                    clien.refbtel[3]     = if wclien.refbtel[3] <> ?
                                           then wclien.refbtel[3]
                                           else clien.refbtel[3]
                    clien.refbtel[4]     = if wclien.refbtel[4] <> ?
                                           then wclien.refbtel[4]
                                           else clien.refbtel[4]
                    clien.refbtel[5]     = if wclien.refbtel[5] <> ?
                                           then wclien.refbtel[5]
                                           else clien.refbtel[5]
                    clien.entbairro[1]   = if wclien.entbairro[1] <> ?
                                           then wclien.entbairro[1]
                                           else clien.entbairro[1]
                    clien.entbairro[2]   = if wclien.entbairro[2] <> ?
                                           then wclien.entbairro[2]
                                           else clien.entbairro[2]
                    clien.entbairro[3]   = if wclien.entbairro[3] <> ?
                                           then wclien.entbairro[3]
                                           else clien.entbairro[3]
                    clien.entbairro[4]   = if wclien.entbairro[4] <> ?
                                           then wclien.entbairro[4]
                                           else clien.entbairro[4]
                    clien.entcep[1]      = if wclien.entcep[1] <> ?
                                           then wclien.entcep[1]
                                           else clien.entcep[1]
                    clien.entcep[2]      = if wclien.entcep[2] <> ?
                                           then wclien.entcep[2]
                                           else clien.entcep[2]
                    clien.entcep[3]      = if wclien.entcep[3] <> ?
                                           then wclien.entcep[3]
                                           else clien.entcep[3]
                    clien.entcep[4]      = if wclien.entcep[4] <> ?
                                           then wclien.entcep[4]
                                           else clien.entcep[4]
                    clien.entcidade[1]   = if wclien.entcidade[1] <> ?
                                           then wclien.entcidade[1]
                                           else clien.entcidade[1]
                    clien.entcidade[2]   = if wclien.entcidade[2] <> ?
                                           then wclien.entcidade[2]
                                           else clien.entcidade[2]
                    clien.entcidade[3]   = if wclien.entcidade[3] <> ?
                                           then wclien.entcidade[3]
                                           else clien.entcidade[3]
                    clien.entcidade[4]   = if wclien.entcidade[4] <> ?
                                           then wclien.entcidade[4]
                                           else clien.entcidade[4]
                    clien.entcompl[1]    = if wclien.entcompl[1] <> ?
                                           then wclien.entcomp[1]
                                           else clien.entcomp[1]
                    clien.entcompl[2]    = if wclien.entcompl[2] <> ?
                                           then wclien.entcomp[2]
                                           else clien.entcomp[2]
                    clien.entcompl[3]    = if wclien.entcompl[3] <> ?
                                           then wclien.entcomp[3]
                                           else clien.entcomp[3].
                assign
                    clien.entcompl[4]    = if wclien.entcompl[4] <> ?
                                           then wclien.entcomp[4]
                                           else clien.entcomp[4]
                    clien.entendereco[1] = if wclien.entendereco[1] <> ?
                                           then wclien.entendereco[1]
                                           else clien.entendereco[1]
                    clien.entendereco[2] = if wclien.entendereco[2] <> ?
                                           then wclien.entendereco[2]
                                           else clien.entendereco[2]
                    clien.entendereco[3] = if wclien.entendereco[3] <> ?
                                           then wclien.entendereco[3]
                                           else clien.entendereco[3]
                    clien.entendereco[4] = if wclien.entendereco[4] <> ?
                                           then wclien.entendereco[4]
                                           else clien.entendereco[4]
                    clien.entrefcom[1]   = if wclien.entrefcom[1] <> ?
                                           then wclien.entrefcom[1]
                                           else clien.entrefcom[1]
                    clien.entrefcom[2]   = if wclien.entrefcom[2] <> ?
                                           then wclien.entrefcom[2]
                                           else clien.entrefcom[2]
                    clien.entrefcom[3]   = if wclien.entrefcom[3] <> ?
                                           then wclien.entrefcom[3]
                                           else clien.entrefcom[3]
                    clien.entrefcom[4]   = if wclien.entrefcom[4] <> ?
                                           then wclien.entrefcom[4]
                                           else clien.entrefcom[4]
                    clien.entrefcom[5]   = if wclien.entrefcom[5] <> ?
                                           then wclien.entrefcom[5]
                                           else clien.entrefcom[5]
                    clien.entrefnome     = if wclien.entrefnome <> ?
                                           then wclien.entrefnome
                                           else clien.entrefnome
                    clien.entufecod[1]   = if wclien.entufecod[1] <> ?
                                           then wclien.entufecod[1]
                                           else clien.entufecod[1]
                    clien.entufecod[2]   = if wclien.entufecod[2] <> ?
                                           then wclien.entufecod[2]
                                           else clien.entufecod[2]
                    clien.entufecod[3]   = if wclien.entufecod[3] <> ?
                                           then wclien.entufecod[3]
                                           else clien.entufecod[3]
                    clien.entufecod[4]   = if wclien.entufecod[4] <> ?
                                           then wclien.entufecod[4]
                                           else clien.entufecod[4].
                assign
                    clien.fax            = if wclien.fax <> ?
                                           then wclien.fax
                                           else clien.fax
                    clien.contato        = if wclien.contato <> ?
                                           then wclien.contato
                                           else clien.contato
                    clien.tracod         = if wclien.tracod <> ?
                                           then wclien.tracod
                                           else clien.tracod
                    clien.vencod         = if wclien.vencod <> ?
                                           then wclien.vencod
                                           else clien.vencod
                    clien.entfone        = if wclien.entfone <> ?
                                           then wclien.entfone
                                           else clien.entfone
                    clien.cobfone        = if wclien.cobfone <> ?
                                           then wclien.cobfone
                                           else clien.cobfone
                    clien.entnumero[1]   = if wclien.entnumero[1] <> ?
                                           then wclien.entnumero[1]
                                           else clien.entnumero[1]
                    clien.entnumero[2]   = if wclien.entnumero[2] <> ?
                                           then wclien.entnumero[2]
                                           else clien.entnumero[2]
                    clien.entnumero[3]   = if wclien.entnumero[3] <> ?
                                           then wclien.entnumero[3]
                                           else clien.entnumero[3]
                    clien.entnumero[4]   = if wclien.entnumero[4] <> ?
                                           then wclien.entnumero[4]
                                           else clien.entnumero[4]
                    clien.cobnumero[1]   = if wclien.cobnumero[1] <> ?
                                           then wclien.cobnumero[1]
                                           else clien.cobnumero[1]
                    clien.cobnumero[2]   = if wclien.cobnumero[2] <> ?
                                           then wclien.cobnumero[2]
                                           else clien.cobnumero[2]
                    clien.cobnumero[3]   = if wclien.cobnumero[3] <> ?
                                           then wclien.cobnumero[3]
                                           else clien.cobnumero[3]
                    clien.cobnumero[4]   = if wclien.cobnumero[4] <> ?
                                           then wclien.cobnumero[4]
                                           else clien.cobnumero[4]
                    clien.ccivil         = if wclien.ccivil <> ?
                                           then wclien.ccivil
                                           else clien.ccivil
                    clien.zona           = if wclien.zona <> ?
                                           then wclien.zona
                                           else clien.zona
                    clien.datexp         = wclien.datexp
                    clien.datexp         = today
                    clien.limcrd         = if wclien.limcrd <> 0
                                           then wclien.limcrd
                                           else if clien.limcrd <> 0
                                                then clien.limcrd
                                                else 499.50.

            conta5 = conta5 + 1.
        end.
        input close.

    end.



    /******* fim dos clientes ********/



    /************/
    
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
    
    dos silent deltree /y value("..\import\" + string(i,"99") + "\*.*" ).
    
    dos silent copy value("..\import\" + string(i,"99") 
                           + "\l??????.d") ..\import\log .
    
    display conta1 
            conta2
            conta3
            conta4
            conta5 
            with frame fmostra.
    display string((time - vhora),"HH:MM:SS")
                            @ vhora with frame fhora.

end.

