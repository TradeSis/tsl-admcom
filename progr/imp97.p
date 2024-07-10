/***************************************************************************
** Programa        : impmatb4.p
** Objetivo        : Importacao de Dados do CPD
** Ultima Alteracao: 22/07/96
** Programador     : Cristiano Borges Brasil
** Chama Programa  : ImpMatMz.p
****************************************************************************/
{admcab.i}


def temp-table tt-pedid  like pedid.
def temp-table tt-liped  like liped.
def temp-table tt-nottra like nottra.
def temp-table tt-plaped like plaped.
def temp-table tt-movim like movim.
def var recmov as recid.
def var recpla as recid.
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
def var v-dtini     as date init today format "99/99/9999".
def var v-dtfin     as date init today format "99/99/9999".
def var vdata       as date                                      no-undo.
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

form v-etbcod   label "Deposito"
     v-dtini    label "Data Inicial"
     v-dtfin    label "Data Final"
     with side-label color white/cyan title " PERIODO A IMPORTAR "
     row 4 centered frame fperiodo.

form skip(1)
     "Notas               :" conta1 skip
     "Movimentos          :" conta2 skip
     "Contas a Pagar      :" conta3 skip
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

pause 0 before-hide.

output stream tela to terminal.

view stream tela frame fmostra.

message "Confirma Importacao de Dados ? " update sresp.

if not sresp then leave.
if search("..\import\export.d") <> ?
then do:
    input from ..\import\export.d no-echo.
    repeat:
        set v-etbcod v-dtini v-dtfin.
        display stream tela v-etbcod 
                            v-dtini  
                            v-dtfin   with frame fperiodo.
    end.
    input close.
end.




if search("..\import\plani.d") <> ?
then do transaction:
    pause 0.
    input from ..\import\plani.d no-echo.
    repeat:
        create plani.
        import plani.
        release plani.
        conta1 = conta1 + 1.
        display stream tela conta1 with frame fmostra.
    end.
    input close.
end.
                                                       
if search("..\import\movim.d") <> ?
then do:
    pause 0.
    input from value("..\import\movim.d") no-echo.
    repeat:
            
        for each tt-movim:
            delete tt-movim.
        end. 
        create tt-movim. 
        import tt-movim.

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
                                 
            recmov = recid(movim).
            release movim.

            if tt-movim.movtdc = 4 or
               tt-movim.movtdc = 1
            then do:
               find first plani where plani.etbcod = tt-movim.etbcod and
                                      plani.placod = tt-movim.placod and
                                      plani.movtdc = tt-movim.movtdc 
                                                   no-lock no-error.
               if avail plani
               then do:
                   for each estoq where estoq.procod = tt-movim.procod.
                       estoq.estcusto = ((tt-movim.movpc *
                                        (tt-movim.movalipi / 100)) +
                                         tt-movim.movpc).
                                   
                       estoq.estcusto = ((tt-movim.movpc * 
                                        ((plani.frete / plani.protot))) +
                                          estoq.estcusto).
                       estoq.datexp = today.                   
                   end.
               end.    
            end.
            
            run atuest.p (input recmov,
                          input "I",
                          input 0).
        
        end.

        conta2 = conta2 + 1.
        display stream tela conta2 with frame fmostra.
        display stream tela string((time - vhora),"HH:MM:SS")
                                @ vhora with frame fhora.

    end.
    input close.
end.

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
    
    
    if search("..\import\plaped.d") <> ?
    then do:
        input from ..\import\plaped.d.
        repeat:
            for each tt-plaped.
                delete tt-plaped.
            end.
            create tt-plaped.
            import tt-plaped.

     
            find plaped where plaped.pedetb = tt-plaped.pedetb and
                              plaped.plaetb = tt-plaped.plaetb and
                              plaped.pedtdc = tt-plaped.pedtdc and
                              plaped.pednum = tt-plaped.pednum and
                              plaped.placod = tt-plaped.placod and
                              plaped.serie  = tt-plaped.serie  no-error.
            if not avail plaped
            then do transaction:
                create plaped.
                assign plaped.pedetb = tt-plaped.pedetb
                       plaped.plaetb = tt-plaped.plaetb
                       plaped.pedtdc = tt-plaped.pedtdc
                       plaped.pednum = tt-plaped.pednum
                       plaped.placod = tt-plaped.placod
                       plaped.serie  = tt-plaped.serie
                       plaped.numero = tt-plaped.numero
                       plaped.forcod = tt-plaped.forcod.
            end.
        end.
    end.

    if search("..\import\pedid.d") <> ?
    then do:
        input from ..\import\pedid.d.
        repeat:
            for each tt-pedid.
                delete tt-pedid.
            end.
            create tt-pedid.
            import tt-pedid.

     
            find pedid where pedid.etbcod = tt-pedid.etbcod and
                             pedid.pednum = tt-pedid.pednum and
                             pedid.pedtdc = tt-pedid.pedtdc  no-error.
            if not avail pedid
            then do transaction:
                create pedid.
            end.
            do transaction:
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
                
                ASSIGN pedid.modcod    = tt-pedid.modcod 
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
    end.

    if search("..\import\liped.d") <> ?
    then do:
        input from ..\import\liped.d.
        repeat:
            for each tt-liped.
                delete tt-liped.
            end.
            create tt-liped.
            import tt-liped.

     
            find liped where liped.etbcod = tt-liped.etbcod and
                             liped.pednum = tt-liped.pednum and
                             liped.pedtdc = tt-liped.pedtdc and
                             liped.procod = tt-liped.procod and
                             liped.lipcor = tt-liped.lipcor and
                             liped.predt  = tt-liped.predt no-error.
            if not avail liped
            then do transaction:
                create liped.
            end.
            do transaction:
                assign liped.pedtdc   = tt-liped.pedtdc 
                       liped.pednum   = tt-liped.pednum 
                       liped.procod   = tt-liped.procod 
                       liped.lipqtd   = tt-liped.lipqtd 
                       liped.lippreco = tt-liped.lippreco 
                       liped.lipsit   = tt-liped.lipsit 
                       liped.lipent   = tt-liped.lipent 
                       liped.predtf   = tt-liped.predtf 
                       liped.predt    = tt-liped.predt 
                       liped.lipcor   = tt-liped.lipcor 
                       liped.etbcod   = tt-liped.etbcod 
                       liped.lipsep   = tt-liped.lipsep 
                       liped.protip   = tt-liped.protip.

            end.
        end.
    end.









if search("..\import\titulo.d") <> ?
then do transaction:
    pause 0.
    input from ..\import\titulo.d no-echo.
    repeat:
        create titulo.
        import titulo.empcod   
               titulo.modcod   
               titulo.CliFor   
               titulo.titnum   
               titulo.titpar   
               titulo.titnat   
               titulo.etbcod   
               titulo.titdtemi 
               titulo.titdtven 
               titulo.titvlcob 
               titulo.titdtdes 
               titulo.titvldes 
               titulo.titvljur 
               titulo.cobcod   
               titulo.bancod   
               titulo.agecod   
               titulo.titdtpag 
               titulo.titdesc  
               titulo.titjuro  
               titulo.titvlpag
               titulo.titbanpag 
               titulo.titagepag 
               titulo.titchepag 
               titulo.titobs[1] 
               titulo.titobs[2] 
               titulo.titsit    
               titulo.titnumger 
               titulo.titparger 
               titulo.cxacod    
               titulo.evecod    
               titulo.cxmdata   
               titulo.cxmhora   
               titulo.vencod    
               titulo.etbCobra  
               titulo.datexp    
               titulo.moecod.   
        
        conta3 = conta3 + 1.
        display stream tela conta3 with frame fmostra.
        find titctb where titctb.forcod = titulo.clifor and
                          titctb.titnum = titulo.titnum and
                          titctb.titpar = titulo.titpar no-error.
        if not avail titctb
        then do:
            create titctb.
            ASSIGN titctb.etbcod   = titulo.etbcod
                   titctb.forcod   = titulo.clifor
                   titctb.titnum   = titulo.titnum
                   titctb.titpar   = titulo.titpar
                   titctb.titsit   = titulo.titsit
                   titctb.titvlpag = titulo.titvlpag
                   titctb.titvlcob = titulo.titvlcob
                   titctb.titdtven = titulo.titdtven
                   titctb.titdtemi = titulo.titdtemi
                   titctb.titdtpag = titulo.titdtpag.
        end.
    end.
    input close.
end.

