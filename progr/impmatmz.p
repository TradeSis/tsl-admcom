{admcab.i}
def temp-table tt-func like func.
def temp-table wtit like titulo.
def temp-table wtitulo
    field wdata like titulo.titdtemi
    field wvalor like titulo.titvlcob.

def var totpar like contrato.vlentra.
def var totpre like contrato.vlentra.
def var vlog as log.
def stream tela.
/* def shared frame fmostra. */
def frame fper.
/* def shared frame flimpa. */
def shared frame fhora.
def shared var conta1      as integer.
def shared var conta2      as integer.
def shared var conta3      as integer.
def shared var conta4      as integer.
def shared var conta5      as integer.
def shared var conta6      as integer.
def shared var conta7      as integer.
def shared var conta8      as integer.
def shared var vhora       as integer.
def shared var v-etbcod    like estab.etbcod.

output stream tela to terminal.

def var varq        as char format "x(15)".
def var vmiccod     like micro.miccod.
def var v-dtini     as date init today                           no-undo.
def var v-dtfin     as date init today                           no-undo.
def var vdata       as date                                      no-undo.
def var vtotcont    as   int.
def var vtitpg      as   int.
def var vtotparc    as   int.
def var vtotpag     like titulo.titvlpag.
def var vtotvl      like contrato.vltotal.
def var vtitsit     like titulo.titsit.
def var vtitdtpag   like titulo.titdtpag.
def var vmodcod     like titulo.modcod.
def var verro       as log.

form v-dtini    label "Data Inicial"
     v-dtfin    label "Data Final"
     with side-label 2 column color white/cyan title " PERIODO A IMPORTAR "
     row 4 centered frame fper.

form skip(1)                   /*
     "Arquivo de Saldos   :" conta1 skip
     "Arquivo de Controle :" conta2 skip
     "Integridade de Dados:" conta6 skip(1)  */
     "Titulos             :" conta3 skip
     "Contratos           :" conta4 skip
     "Clientes            :" conta5 skip
     with frame fmostra row 8 column 18 color blue/cyan no-label
     title " IMPORTACAO DE DADOS - CPD ".
                /*
form skip(1)
     conta7 skip
     conta8
     skip(2)
     with frame flimpa row 8 column 52 color blue/cyan no-label
     title " LIMPA ".  */

form skip
     vhora
     skip
     with frame fhora row 10 column 52 color blue/cyan no-label
     title " TEMPO ".

/***************************************************************************
 IMPORTA OS DADOS PARA A TABELA TITULO
***************************************************************************/

display stream tela string((time - vhora),"HH:MM:SS")
                    @ vhora with frame fhora.
conta3 = 0.
conta4 = 0.
conta5 = 0.
for each wtitulo.
    delete wtitulo.
end.
input from ..\import\titulo.d no-echo.
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
    display stream tela conta3 with frame fmostra.
    display stream tela string((time - vhora),"HH:MM:SS")
                        @ vhora with frame fhora.
end.


def temp-table tt-contrato like contrato.
if search("..\import\contrato.d") <> ?
then do:
    pause 0.
    input from ..\import\contrato.d no-echo.
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
            display stream tela conta4 with frame fmostra.
            display stream tela string((time - vhora),"HH:MM:SS")
                                @ vhora with frame fhora.
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

run impcli.p.
if search("..\import\func.d") <> ?
then do:
    pause 0.
    input from ..\import\func.d no-echo.
    repeat:
        for each tt-func:
            delete tt-func.
        end.
        create tt-func.
        import tt-func.

        find func where func.etbcod  = tt-func.etbcod and
                        func.funcod  = tt-func.funcod no-error.
        do transaction:
            if not available func
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
        display stream tela string((time - vhora),"HH:MM:SS")
                            @ vhora with frame fhora.

    end.
    input close.
end.
