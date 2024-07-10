/*
{admcab.i}
*/
def var lresp   as l format "Sim/Nao".
def temp-table  wf-titulo   like titulo.
def temp-table  wf-contrato like contrato.
def temp-table  wf-clien    like clien.
def var         i-cont as int.
def var         l-imp   as logical init no                          no-undo.

def stream stitnok.
def buffer btitulo for titulo.
def buffer bcontrato for contrato.
def buffer bclien for clien.

message "Confirma IMPORTACAO DE DADOS ? " update lresp.

output stream stitnok to ../import/titnok.d.
output stream stitnok close.

if  not lresp then
    leave.

dos "copy a:*.d ..\import "   .

    input from ..\import\titulo.d.
    repeat:
        l-imp = no.
        for each wf-titulo:
            delete wf-titulo.
        end.
        create wf-titulo.
        import wf-titulo.
        find btitulo where btitulo.empcod = wf-titulo.empcod and
                           btitulo.titnat = wf-titulo.titnat and
                           btitulo.modcod = wf-titulo.modcod and
                           btitulo.etbcod = wf-titulo.etbcod and
                           btitulo.clifor = wf-titulo.clifor and
                           btitulo.titnum = wf-titulo.titnum and
                           btitulo.titpar = wf-titulo.titpar no-error.
        if  not available btitulo then do:
            i-cont = i-cont + 1.
            create titulo.
            ASSIGN titulo.empcod    = wf-titulo.empcod
                   titulo.modcod    = wf-titulo.modcod
                   titulo.CliFor    = wf-titulo.CliFor
                   titulo.titnum    = wf-titulo.titnum
                   titulo.titpar    = wf-titulo.titpar
                   titulo.titnat    = wf-titulo.titnat
                   titulo.etbcod    = wf-titulo.etbcod
                   titulo.titdtemi  = wf-titulo.titdtemi
                   titulo.titdtven  = wf-titulo.titdtven
                   titulo.titvlcob  = wf-titulo.titvlcob
                   titulo.titdtdes  = wf-titulo.titdtdes
                   titulo.titvldes  = wf-titulo.titvldes
                   titulo.titvljur  = wf-titulo.titvljur
                   titulo.cobcod    = wf-titulo.cobcod
                   titulo.bancod    = wf-titulo.bancod
                   titulo.agecod    = wf-titulo.agecod
                   titulo.titdtpag  = wf-titulo.titdtpag
                   titulo.titdesc   = wf-titulo.titdesc
                   titulo.titjuro   = wf-titulo.titjuro
                   titulo.titvlpag  = wf-titulo.titvlpag
                   titulo.titbanpag = wf-titulo.titbanpag
                   titulo.titagepag = wf-titulo.titagepag
                   titulo.titchepag = wf-titulo.titchepag
                   titulo.titobs[1] = wf-titulo.titobs[1]
                   titulo.titobs[2] = wf-titulo.titobs[2]
                   titulo.titsit    = wf-titulo.titsit
                   titulo.titnumger = wf-titulo.titnumger
                   titulo.titparger = wf-titulo.titparger
                   titulo.cxacod    = wf-titulo.cxacod
                   titulo.evecod    = wf-titulo.evecod
                   titulo.cxmdata   = wf-titulo.cxmdata
                   titulo.cxmhora   = wf-titulo.cxmhora
                   titulo.vencod    = wf-titulo.vencod
                   titulo.etbCobra  = wf-titulo.etbCobra
                   titulo.datexp    = wf-titulo.datexp
                   l-imp            = yes.
            disp titulo.etbcod
                 titulo.datexp
                 titulo.titnum
                 titulo.titpar
                 i-cont label "Quantos"
                 with centered title "Titulos" frame f1.
            pause 1 no-message.
        end.
        else do:
            if  wf-titulo.titdtpag <> ? and
                btitulo.titdtpag    = ? then do:
                i-cont = i-cont + 1.
                delete btitulo.
                create titulo.
                ASSIGN titulo.empcod    = wf-titulo.empcod
                       titulo.modcod    = wf-titulo.modcod
                       titulo.CliFor    = wf-titulo.CliFor
                       titulo.titnum    = wf-titulo.titnum
                       titulo.titpar    = wf-titulo.titpar
                       titulo.titnat    = wf-titulo.titnat
                       titulo.etbcod    = wf-titulo.etbcod
                       titulo.titdtemi  = wf-titulo.titdtemi
                       titulo.titdtven  = wf-titulo.titdtven
                       titulo.titvlcob  = wf-titulo.titvlcob
                       titulo.titdtdes  = wf-titulo.titdtdes
                       titulo.titvldes  = wf-titulo.titvldes
                       titulo.titvljur  = wf-titulo.titvljur
                       titulo.cobcod    = wf-titulo.cobcod
                       titulo.bancod    = wf-titulo.bancod
                       titulo.agecod    = wf-titulo.agecod
                       titulo.titdtpag  = wf-titulo.titdtpag
                       titulo.titdesc   = wf-titulo.titdesc
                       titulo.titjuro   = wf-titulo.titjuro
                       titulo.titvlpag  = wf-titulo.titvlpag
                       titulo.titbanpag = wf-titulo.titbanpag
                       titulo.titagepag = wf-titulo.titagepag
                       titulo.titchepag = wf-titulo.titchepag
                       titulo.titobs[1] = wf-titulo.titobs[1]
                       titulo.titobs[2] = wf-titulo.titobs[2]
                       titulo.titsit    = wf-titulo.titsit
                       titulo.titnumger = wf-titulo.titnumger
                       titulo.titparger = wf-titulo.titparger
                       titulo.cxacod    = wf-titulo.cxacod
                       titulo.evecod    = wf-titulo.evecod
                       titulo.cxmdata   = wf-titulo.cxmdata
                       titulo.cxmhora   = wf-titulo.cxmhora
                       titulo.vencod    = wf-titulo.vencod
                       titulo.etbCobra  = wf-titulo.etbCobra
                       titulo.datexp    = wf-titulo.datexp
                       l-imp            = yes.
                disp titulo.etbcod
                     titulo.datexp
                     titulo.titnum
                     titulo.titpar
                     i-cont  label "Quantos"
                    with centered title "Titulos" frame f1.
                pause 1 no-message.
            end.
            else do:
                 output stream stitnok to ../import/titnok.d append.
                 export stream stitnok wf-titulo.
                 output stream  stitnok close.
            end.
        end.
    end.
    for each wf-titulo:
        delete wf-titulo.
    end.

    hide frame f1.
    input from ..\import\contrato.d.
    repeat:
        for each wf-contrato:
            delete wf-contrato.
        end.
        create wf-contrato.
        import wf-contrato.
        find bcontrato where
             bcontrato.contnum = wf-contrato.contnum no-error.
        if  not available bcontrato then do:
            create contrato.
            ASSIGN
                contrato.contnum   = wf-contrato.contnum
                contrato.clicod    = wf-contrato.clicod
                contrato.autoriza  = wf-contrato.autoriza
                contrato.dtinicial = wf-contrato.dtinicial
                contrato.etbcod    = wf-contrato.etbcod
                contrato.banco     = wf-contrato.banco
                contrato.vltotal   = wf-contrato.vltotal
                contrato.vlentra   = wf-contrato.vlentra
                contrato.situacao  = wf-contrato.situacao
                contrato.indimp    = wf-contrato.indimp
                contrato.lotcod    = wf-contrato.lotcod
                contrato.crecod    = wf-contrato.crecod
                contrato.vlfrete   = wf-contrato.vlfrete
                contrato.datexp    = wf-contrato.datexp.
            disp contrato.contnum
                 contrato.clicod
                 with frame f2.
            pause 0.
        end.
        else next.
    end.
    for each wf-contrato:
        delete wf-contrato.
    end.
    hide frame f2.

    input from ..\import\clien.d.
    repeat:
        for each wf-clien:
            delete wf-clien.
        end.
        create wf-clien.
        import wf-clien.
        pause 0.
        find bclien where
             bclien.clicod = wf-clien.clicod no-error.
        if  not available bclien then do:
            create clien.
            ASSIGN
                clien.clicod         = wf-clien.clicod
                clien.clinom         = wf-clien.clinom
                clien.tippes         = wf-clien.tippes
                clien.sexo           = wf-clien.sexo
                clien.estciv         = wf-clien.estciv
                clien.nacion         = wf-clien.nacion
                clien.natur          = wf-clien.natur
                clien.dtnasc         = wf-clien.dtnasc
                clien.ciinsc         = wf-clien.ciinsc
                clien.ciccgc         = wf-clien.ciccgc
                clien.pai            = wf-clien.pai
                clien.mae            = wf-clien.mae
                clien.endereco[1]    = wf-clien.endereco[1]
                clien.endereco[2]    = wf-clien.endereco[2]
                clien.endereco[3]    = wf-clien.endereco[3]
                clien.endereco[4]    = wf-clien.endereco[4]
                clien.numero[1]      = wf-clien.numero[1]
                clien.numero[2]      = wf-clien.numero[2]
                clien.numero[3]      = wf-clien.numero[3]
                clien.numero[4]      = wf-clien.numero[4]
                clien.numdep         = wf-clien.numdep
                clien.compl[1]       = wf-clien.compl[1]
                clien.compl[2]       = wf-clien.compl[2]
                clien.compl[3]       = wf-clien.compl[3]
                clien.compl[4]       = wf-clien.compl[4]
                clien.bairro[1]      = wf-clien.bairro[1]
                clien.bairro[2]      = wf-clien.bairro[2]
                clien.bairro[3]      = wf-clien.bairro[3]
                clien.bairro[4]      = wf-clien.bairro[4]
                clien.cidade[1]      = wf-clien.cidade[1]
                clien.cidade[2]      = wf-clien.cidade[2]
                clien.cidade[3]      = wf-clien.cidade[3]
                clien.cidade[4]      = wf-clien.cidade[4]
                clien.ufecod[1]      = wf-clien.ufecod[1]
                clien.ufecod[2]      = wf-clien.ufecod[2]
                clien.ufecod[3]      = wf-clien.ufecod[3]
                clien.ufecod[4]      = wf-clien.ufecod[4]
                clien.fone           = wf-clien.fone
                clien.tipres         = wf-clien.tipres
                clien.vlalug         = wf-clien.vlalug
                clien.temres         = wf-clien.temres
                clien.proemp[1]      = wf-clien.proemp[1]
                clien.proemp[2]      = wf-clien.proemp[2]
                clien.protel[1]      = wf-clien.protel[1]
                clien.protel[2]      = wf-clien.protel[2]
                clien.prodta[1]      = wf-clien.prodta[1]
                clien.prodta[2]      = wf-clien.prodta[2]
                clien.proprof[1]     = wf-clien.proprof[1].
            assign
                clien.proprof[2]     = wf-clien.proprof[2]
                clien.prorenda[1]    = wf-clien.prorenda[1]
                clien.prorenda[2]    = wf-clien.prorenda[2]
                clien.conjuge        = wf-clien.conjuge
                clien.nascon         = wf-clien.nascon
                clien.refcom[1]      = wf-clien.refcom[1]
                clien.refcom[2]      = wf-clien.refcom[2]
                clien.refcom[3]      = wf-clien.refcom[3]
                clien.refcom[4]      = wf-clien.refcom[4]
                clien.refcom[5]      = wf-clien.refcom[5]
                clien.refnome        = wf-clien.refnome
                clien.reftel         = wf-clien.reftel
                clien.classe         = wf-clien.classe
                clien.limite         = wf-clien.limite
                clien.medatr         = wf-clien.medatr
                clien.dtcad          = wf-clien.dtcad
                clien.situacao       = wf-clien.situacao
                clien.dtspc[1]       = wf-clien.dtspc[1]
                clien.dtspc[2]       = wf-clien.dtspc[2]
                clien.dtspc[3]       = wf-clien.dtspc[3]
                clien.autoriza[1]    = wf-clien.autoriza[1]
                clien.autoriza[2]    = wf-clien.autoriza[2]
                clien.autoriza[3]    = wf-clien.autoriza[3]
                clien.autoriza[4]    = wf-clien.autoriza[4]
                clien.autoriza[5]    = wf-clien.autoriza[5]
                clien.conjpai        = wf-clien.conjpai
                clien.conjmae        = wf-clien.conjmae
                clien.cep[1]         = wf-clien.cep[1]
                clien.cep[2]         = wf-clien.cep[2]
                clien.cep[3]         = wf-clien.cep[3]
                clien.cep[4]         = wf-clien.cep[4]
                clien.cobbairro[1]   = wf-clien.cobbairro[1]
                clien.cobbairro[2]   = wf-clien.cobbairro[2]
                clien.cobbairro[3]   = wf-clien.cobbairro[3]
                clien.cobbairro[4]   = wf-clien.cobbairro[4]
                clien.cobcep[1]      = wf-clien.cobcep[1]
                clien.cobcep[2]      = wf-clien.cobcep[2]
                clien.cobcep[3]      = wf-clien.cobcep[3]
                clien.cobcep[4]      = wf-clien.cobcep[4]
                clien.cobcidade[1]   = wf-clien.cobcidade[1]
                clien.cobcidade[2]   = wf-clien.cobcidade[2]
                clien.cobcidade[3]   = wf-clien.cobcidade[3]
                clien.cobcidade[4]   = wf-clien.cobcidade[4]
                clien.cobcompl[1]    = wf-clien.cobcompl[1]
                clien.cobcompl[2]    = wf-clien.cobcompl[2]
                clien.cobcompl[3]    = wf-clien.cobcompl[3]
                clien.cobcompl[4]    = wf-clien.cobcompl[4]
                clien.cobendereco[1] = wf-clien.cobendereco[1]
                clien.cobendereco[2] = wf-clien.cobendereco[2]
                clien.cobendereco[3] = wf-clien.cobendereco[3]
                clien.cobendereco[4] = wf-clien.cobendereco[4]
                clien.cfobnumero[1]  = wf-clien.cfobnumero[1]
                clien.cfobnumero[2]  = wf-clien.cfobnumero[2]
                clien.cfobnumero[3]  = wf-clien.cfobnumero[3]
                clien.cfobnumero[4]  = wf-clien.cfobnumero[4].
            assign
                clien.cobrefcom[1]   = wf-clien.cobrefcom[1]
                clien.cobrefcom[2]   = wf-clien.cobrefcom[2]
                clien.cobrefcom[3]   = wf-clien.cobrefcom[3]
                clien.cobrefcom[4]   = wf-clien.cobrefcom[4]
                clien.cobrefcom[5]   = wf-clien.cobrefcom[5]
                clien.cobrefnome     = wf-clien.cobrefnome
                clien.cobufecod[1]   = wf-clien.cobufecod[1]
                clien.cobufecod[2]   = wf-clien.cobufecod[2]
                clien.cobufecod[3]   = wf-clien.cobufecod[3]
                clien.cobufecod[4]   = wf-clien.cobufecod[4]
                clien.refccont[1]    = wf-clien.refccont[1]
                clien.refccont[2]    = wf-clien.refccont[2]
                clien.refccont[3]    = wf-clien.refccont[3]
                clien.refccont[4]    = wf-clien.refccont[4]
                clien.refccont[5]    = wf-clien.refccont[5]
                clien.refctel[1]     = wf-clien.refctel[1]
                clien.refctel[2]     = wf-clien.refctel[2]
                clien.refctel[3]     = wf-clien.refctel[3]
                clien.refctel[4]     = wf-clien.refctel[4]
                clien.refctel[5]     = wf-clien.refctel[5]
                clien.refcinfo[1]    = wf-clien.refcinfo[1]
                clien.refcinfo[2]    = wf-clien.refcinfo[2]
                clien.refcinfo[3]    = wf-clien.refcinfo[3]
                clien.refcinfo[4]    = wf-clien.refcinfo[4]
                clien.refcinfo[5]    = wf-clien.refcinfo[5]
                clien.refbcont[1]    = wf-clien.refbcont[1]
                clien.refbcont[2]    = wf-clien.refbcont[2]
                clien.refbcont[3]    = wf-clien.refbcont[3]
                clien.refbcont[4]    = wf-clien.refbcont[4]
                clien.refbcont[5]    = wf-clien.refbcont[5]
                clien.refbinfo[1]    = wf-clien.refbinfo[1]
                clien.refbinfo[2]    = wf-clien.refbinfo[2]
                clien.refbinfo[3]    = wf-clien.refbinfo[3]
                clien.refbinfo[4]    = wf-clien.refbinfo[4]
                clien.refbinfo[5]    = wf-clien.refbinfo[5]
                clien.refban[1]      = wf-clien.refban[1]
                clien.refban[2]      = wf-clien.refban[2]
                clien.refban[3]      = wf-clien.refban[3]
                clien.refban[4]      = wf-clien.refban[4]
                clien.refban[5]      = wf-clien.refban[5]
                clien.refbtel[1]     = wf-clien.refbtel[1]
                clien.refbtel[2]     = wf-clien.refbtel[2]
                clien.refbtel[3]     = wf-clien.refbtel[3]
                clien.refbtel[4]     = wf-clien.refbtel[4]
                clien.refbtel[5]     = wf-clien.refbtel[5]
                clien.entbairro[1]   = wf-clien.entbairro[1]
                clien.entbairro[2]   = wf-clien.entbairro[2]
                clien.entbairro[3]   = wf-clien.entbairro[3]
                clien.entbairro[4]   = wf-clien.entbairro[4]
                clien.entcep[1]      = wf-clien.entcep[1]
                clien.entcep[2]      = wf-clien.entcep[2]
                clien.entcep[3]      = wf-clien.entcep[3]
                clien.entcep[4]      = wf-clien.entcep[4]
                clien.entcidade[1]   = wf-clien.entcidade[1]
                clien.entcidade[2]   = wf-clien.entcidade[2]
                clien.entcidade[3]   = wf-clien.entcidade[3]
                clien.entcidade[4]   = wf-clien.entcidade[4]
                clien.entcompl[1]    = wf-clien.entcompl[1]
                clien.entcompl[2]    = wf-clien.entcompl[2]
                clien.entcompl[3]    = wf-clien.entcompl[3]
                clien.entcompl[4]    = wf-clien.entcompl[4]
                clien.entendereco[1] = wf-clien.entendereco[1]
                clien.entendereco[2] = wf-clien.entendereco[2]
                clien.entendereco[3] = wf-clien.entendereco[3]
                clien.entendereco[4] = wf-clien.entendereco[4]
                clien.entrefcom[1]   = wf-clien.entrefcom[1]
                clien.entrefcom[2]   = wf-clien.entrefcom[2]
                clien.entrefcom[3]   = wf-clien.entrefcom[3]
                clien.entrefcom[4]   = wf-clien.entrefcom[4]
                clien.entrefcom[5]   = wf-clien.entrefcom[5]
                clien.entrefnome     = wf-clien.entrefnome
                clien.entufecod[1]   = wf-clien.entufecod[1]
                clien.entufecod[2]   = wf-clien.entufecod[2]
                clien.entufecod[3]   = wf-clien.entufecod[3]
                clien.entufecod[4]   = wf-clien.entufecod[4].
            assign
                clien.fax            = wf-clien.fax
                clien.contato        = wf-clien.contato
                clien.tracod         = wf-clien.tracod
                clien.vencod         = wf-clien.vencod
                clien.entfone        = wf-clien.entfone
                clien.cobfone        = wf-clien.cobfone
                clien.entnumero[1]   = wf-clien.entnumero[1]
                clien.entnumero[2]   = wf-clien.entnumero[2]
                clien.entnumero[3]   = wf-clien.entnumero[3]
                clien.entnumero[4]   = wf-clien.entnumero[4]
                clien.cobnumero[1]   = wf-clien.cobnumero[1]
                clien.cobnumero[2]   = wf-clien.cobnumero[2]
                clien.cobnumero[3]   = wf-clien.cobnumero[3]
                clien.cobnumero[4]   = wf-clien.cobnumero[4]
                clien.ccivil         = wf-clien.ccivil
                clien.zona           = wf-clien.zona
                clien.datexp         = wf-clien.datexp.
            disp clien.clicod
                 with frame f3.
            pause 0.
        end.
        else next.
    end.
    for each wf-clien:
        delete wf-clien.
    end.
    hide frame f3.
    bell. bell.
