/***************************************************************************
** Programa        : impmat.p
****************************************************************************/

{admcab.i}

def temp-table tt-deposito  like deposito.
def temp-table tt-depban    like depban.
def temp-table tt-cartao    like cartao.
def temp-table tt-pedid     like pedid.
def temp-table tt-liped     like liped.
def temp-table tt-glopre    like glopre.
def temp-table tt-globa     like globa.
def temp-table tt-contnf    like contnf.
def temp-table wclien       like clien.
def var vlog                as l.
def temp-table tt-func      like func.
def temp-table wtit         like titulo.
def temp-table wtitulo
    field wdata like titulo.titdtemi
    field wvalor like titulo.titvlcob.

def var vetbi               like estab.etbcod format ">>9".
def var vetbf               like estab.etbcod format ">>9".

def var i                   as int.
def var vprog               as char format "x(30)".
def var vdir                as char format "x(30)".

def var recpla              as recid.
def var recmov              as recid.
def temp-table tt-plani     like plani.
def temp-table tt-movim     like movim.
def var ii                  as int.
def new shared frame fperiodo.
def new shared frame fhora.
def new shared var conta1   as integer.
def new shared var conta2   as integer.
def new shared var conta3   as integer.
def new shared var conta4   as integer.
def new shared var conta5   as integer.
def new shared var conta6   as integer.
def new shared var conta7   as integer.
def new shared var conta8   as integer.
def new shared var vhora    as integer.
def new shared var v-etbcod like estab.etbcod.

def var varq                as char  no-undo.
def var vmiccod             like micro.miccod.
def var v-dtini             as date format "99/99/9999" init today no-undo.
def var v-dtfin             as date format "99/99/9999" init today no-undo.
def var vdata               as date format "99/99/9999" no-undo.
def var vdata1              as date format "99/99/9999" initial today  no-undo.
def var vtotcli             as   int.
def var vtotcont            as   int.
def var vtitpg              as   int.
def var vtotparc            as   int.
def var vtotpag             like titulo.titvlpag.
def var vtotvl              like contrato.vltotal.
def var vtitsit             like titulo.titsit.
def var vtitdtpag           like titulo.titdtpag.
def var vmodcod             like titulo.modcod.
def var verro               as log.
def buffer vestab           for estab.
def stream tela.
def stream stela.

assign conta1 = 0 conta2 = 0 conta3 = 0 conta4 = 0
       conta5 = 0 conta6 = 0 conta7 = 0 conta8 = 0
       vhora  = time.

form v-dtini    label "Data Inicial"
     v-dtfin    label "Data Final"
     with side-label 2 column color white/cyan title " PERIODO A IMPORTAR "
     row 4 centered frame fperiodo.


def temp-table tto
    field etbcod like estab.etbcod.

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

def var vi              as int.
def var vmarcado        as dec format ">>>,>>>,>>>,>>9 Bytes" .
def var vtotal          as dec format ">>>,>>>,>>>,>>9 Bytes".
def var vCOPIADO        as dec format ">>>,>>>,>>>,>>9 Bytes".
DEF VAR vunida-origem   AS CHAR INITIAL ".." label "Unidade Origem".
DEF VAR vunida-destino  AS CHAR INITIAL "A:" label "Unidade Destino".
def var vaux            as char.
def var vokdos          as log.
DEF VAR A               AS CHAR FORMAT "X(40)".

update vetbi label "Filial"
       vetbf label "Filial" 
        with frame ff1 side-label title "IMPORTACAO" CENTERED.

output stream tela to terminal.
output stream stela to terminal.

    
    conta1 = 0.
    conta2 = 0.
    conta3 = 0.

    pause 0 before-hide.
    
    view stream tela frame fmostra.
    view stream tela frame f1.
    view stream tela frame f-periodo.


    display stream tela v-dtini
            v-dtfin with frame fperiodo.

    find vestab where vestab.etbcod = v-etbcod no-lock.

    display stream tela
            caps(estab.etbnom) label "FILIAL" format "x(25)" colon 18
            vdir colon 18 label "ARQUIVO"
            vetbi label "Filial" COLON 18
            " A "
            vetbf no-label 
                with row 17 column 10 color white/red side-labels
                    title " LOJA A IMPORTAR " frame f1.

    view stream tela frame f1.
    
    def temp-table tt-nottra like nottra.

    /******* clientes *********/
    if search("/admcom/import/43/clien.d") <> ?
    then do:
        pause 0.
        input from value("/admcom/import/43/clien.d") no-echo.
        repeat:
            for each wclien:
                delete wclien.
            end.
            create wclien.
            import wclien.
            do transaction:
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
            end.
            conta5 = conta5 + 1.
            display stream tela conta5 with frame fmostra.
            display stream tela string((time - vhora),"HH:MM:SS")
                            @ vhora with frame fhora.

        end.
        input close.
    end.



    /******* fim dos clientes ********/



    /************/
    
