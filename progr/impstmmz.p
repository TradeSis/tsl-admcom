{admcab.i}
def stream tela.
def shared frame fmostra.
def shared frame fperiodo.
def shared frame flimpa.
def shared frame fhora.
def shared var vdire       as char      format "x(15)".
def shared var conta1      as integer.
def shared var conta2      as integer.
def shared var conta3      as integer.
def shared var conta4      as integer.
def shared var conta5      as integer.
def shared var conta6      as integer.
def shared var conta7      as integer.
def shared var conta8      as integer.
def shared var vhora       as integer.

output stream tela to terminal.

def var vmiccod     like micro.miccod.
def var v-dtini     as date init today                           no-undo.
def var v-dtfin     as date init today                           no-undo.
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

form v-dtini    label "Data Inicial"
     v-dtfin    label "Data Final"
     with side-label 2 column color white/cyan title " PERIODO A IMPORTAR "
     row 4 centered frame fperiodo.

form skip(1)
     "Arquivo de Saldos   :" conta1 skip
     "Arquivo de Controle :" conta2 skip
     "Integridade de Dados:" conta6 skip(1)
     "Titulos             :" conta3 skip
     "Contratos           :" conta4 skip
     "Clientes            :" conta5 skip
     with frame fmostra row 8 column 18 color blue/cyan no-label
     title " IMPORTACAO DE DADOS - CPD ".

form skip(1)
     conta7 skip
     conta8
     skip(2)
     with frame flimpa row 8 column 52 color blue/cyan no-label
     title " LIMPA ".

form skip
     vhora
     skip
     with frame fhora row 15 column 52 color blue/cyan no-label
     title " TEMPO ".

/***************************************************************************
 IMPORTA OS DADOS PARA A TABELA TITULO
***************************************************************************/
display stream tela string((time - vhora),"HH:MM:SS")
		    @ vhora with frame fhora.

input from value(vdire + "\titulo.d") no-echo.
repeat with frame ftitulo:
    prompt-for titulo with no-validate with frame ftitulo.

    find titulo where
	 titulo.empcod = input titulo.empcod and
	 titulo.titnat = input titulo.titnat and
	 titulo.modcod = input titulo.modcod and
	 titulo.etbcod = input titulo.etbcod and
	 titulo.clifor = input titulo.clifor and
	 titulo.titnum = input titulo.titnum and
	 titulo.titpar = input titulo.titpar no-error.
    if  not available titulo
    then do:
	create titulo.
	ASSIGN titulo.empcod    = input titulo.empcod
	       titulo.modcod    = input titulo.modcod
	       titulo.CliFor    = input titulo.CliFor
	       titulo.titnum    = input titulo.titnum
	       titulo.titpar    = input titulo.titpar
	       titulo.titnat    = input titulo.titnat
	       titulo.etbcod    = input titulo.etbcod
	       titulo.titdtemi  = input titulo.titdtemi
	       titulo.titdtven  = input titulo.titdtven
	       titulo.titvlcob  = input titulo.titvlcob
	       titulo.titdtdes  = input titulo.titdtdes
	       titulo.titvldes  = input titulo.titvldes
	       titulo.titvljur  = input titulo.titvljur
	       titulo.cobcod    = input titulo.cobcod
	       titulo.bancod    = input titulo.bancod
	       titulo.agecod    = input titulo.agecod
	       titulo.titdtpag  = input titulo.titdtpag
	       titulo.titdesc   = input titulo.titdesc
	       titulo.titjuro   = input titulo.titjuro
	       titulo.titvlpag  = input titulo.titvlpag
	       titulo.titbanpag = input titulo.titbanpag
	       titulo.titagepag = input titulo.titagepag
	       titulo.titchepag = input titulo.titchepag
	       titulo.titobs[1] = input titulo.titobs[1]
	       titulo.titobs[2] = input titulo.titobs[2]
	       titulo.titsit    = if input titulo.titsit = "IMP"
				  then "LIB"
				  else input titulo.titsit
	       titulo.titnumger = input titulo.titnumger
	       titulo.titparger = input titulo.titparger
	       titulo.cxacod    = input titulo.cxacod
	       titulo.evecod    = input titulo.evecod
	       titulo.cxmdata   = input titulo.cxmdata
	       titulo.cxmhora   = input titulo.cxmhora
	       titulo.vencod    = input titulo.vencod
	       titulo.etbCobra  = input titulo.etbCobra
	       titulo.datexp    = input titulo.datexp
	       titulo.datexp    = today
	       titulo.moecod    = input titulo.moecod.
     end.
     else do:
	if  input titulo.titdtpag <> ? and
	    titulo.titdtpag   =  ?
	then do:
		assign
		       titulo.titdtdes  = input titulo.titdtdes
		       titulo.titvldes  = input titulo.titvldes
		       titulo.titvljur  = input titulo.titvljur
		       titulo.cobcod    = input titulo.cobcod
		       titulo.bancod    = input titulo.bancod
		       titulo.agecod    = input titulo.agecod
		       titulo.titdtpag  = input titulo.titdtpag
		       titulo.titdesc   = input titulo.titdesc
		       titulo.titjuro   = input titulo.titjuro
		       titulo.titvlpag  = input titulo.titvlpag
		       titulo.titbanpag = input titulo.titbanpag
		       titulo.titagepag = input titulo.titagepag
		       titulo.titchepag = input titulo.titchepag
		       titulo.titobs[1] = input titulo.titobs[1]
		       titulo.titobs[2] = input titulo.titobs[2]
		       titulo.titsit    = input titulo.titsit
		       titulo.titnumger = input titulo.titnumger
		       titulo.titparger = input titulo.titparger
		       titulo.cxacod    = input titulo.cxacod
		       titulo.evecod    = input titulo.evecod
		       titulo.cxmdata   = input titulo.cxmdata
		       titulo.cxmhora   = input titulo.cxmhora
		       titulo.vencod    = input titulo.vencod
		       titulo.etbCobra  = input titulo.etbCobra
		       titulo.datexp    = input titulo.datexp
		       titulo.datexp    = today
		       titulo.moecod    = input titulo.moecod.
	end.
    end.
    conta3 = conta3 + 1.
    display stream tela conta3 with frame fmostra.
    display stream tela string((time - vhora),"HH:MM:SS")
			@ vhora with frame fhora.
end.

if search(vdire + "\contrato.d") <> ?
then do:
    pause 0.
    input from value(vdire + "\contrato.d") no-echo.
    repeat:
	prompt-for contrato with no-validate.
	find contrato where
	     contrato.contnum = input contrato.contnum no-error.

	if  not available contrato
	then create contrato.
	    ASSIGN
		contrato.contnum   = input contrato.contnum
		contrato.clicod    = input contrato.clicod
		contrato.autoriza  = input contrato.autoriza
		contrato.dtinicial = input contrato.dtinicial
		contrato.etbcod    = input contrato.etbcod
		contrato.banco     = input contrato.banco
		contrato.vltotal   = input contrato.vltotal
		contrato.vlentra   = input contrato.vlentra
		contrato.situacao  = input contrato.situacao
		contrato.indimp    = input contrato.indimp
		contrato.lotcod    = input contrato.lotcod
		contrato.crecod    = input contrato.crecod
		contrato.datexp    = input contrato.datexp
		contrato.datexp    = today
		contrato.vlfrete   = input contrato.vlfrete.
	assign
	    vtotcont = vtotcont + 1
	    vtotvl   = vtotvl   + contrato.vltotal.

	conta4 = conta4 + 1.
	display stream tela conta4 with frame fmostra.
	display stream tela string((time - vhora),"HH:MM:SS")
			    @ vhora with frame fhora.

    end.
    input close.
end.

if search(vdire + "\clien.d") <> ?
then do:
    pause 0.
    input from value(vdire + "\clien.d") no-echo.
    repeat:
	prompt-for clien with no-validate.
	find clien where
	     clien.clicod = input clien.clicod no-error.
	if  not available clien
	then create clien.
	    ASSIGN
		clien.clicod         = input clien.clicod
		clien.clinom         = input clien.clinom
		clien.tippes         = input clien.tippes
		clien.sexo           = input clien.sexo
		clien.estciv         = input clien.estciv
		clien.nacion         = input clien.nacion
		clien.natur          = input clien.natur
		clien.dtnasc         = input clien.dtnasc
		clien.ciinsc         = input clien.ciinsc
		clien.ciccgc         = input clien.ciccgc
		clien.pai            = input clien.pai
		clien.mae            = input clien.mae
		clien.endereco[1]    = input clien.endereco[1]
		clien.endereco[2]    = input clien.endereco[2]
		clien.endereco[3]    = input clien.endereco[3]
		clien.endereco[4]    = input clien.endereco[4]
		clien.numero[1]      = input clien.numero[1]
		clien.numero[2]      = input clien.numero[2]
		clien.numero[3]      = input clien.numero[3]
		clien.numero[4]      = input clien.numero[4]
		clien.numdep         = input clien.numdep
		clien.compl[1]       = input clien.compl[1]
		clien.compl[2]       = input clien.compl[2]
		clien.compl[3]       = input clien.compl[3]
		clien.compl[4]       = input clien.compl[4]
		clien.bairro[1]      = input clien.bairro[1]
		clien.bairro[2]      = input clien.bairro[2]
		clien.bairro[3]      = input clien.bairro[3]
		clien.bairro[4]      = input clien.bairro[4]
		clien.cidade[1]      = input clien.cidade[1]
		clien.cidade[2]      = input clien.cidade[2]
		clien.cidade[3]      = input clien.cidade[3]
		clien.cidade[4]      = input clien.cidade[4]
		clien.ufecod[1]      = input clien.ufecod[1]
		clien.ufecod[2]      = input clien.ufecod[2]
		clien.ufecod[3]      = input clien.ufecod[3]
		clien.ufecod[4]      = input clien.ufecod[4]
		clien.fone           = input clien.fone
		clien.tipres         = input clien.tipres
		clien.vlalug         = input clien.vlalug
		clien.temres         = input clien.temres
		clien.proemp[1]      = input clien.proemp[1]
		clien.proemp[2]      = input clien.proemp[2]
		clien.protel[1]      = input clien.protel[1]
		clien.protel[2]      = input clien.protel[2]
		clien.prodta[1]      = input clien.prodta[1]
		clien.prodta[2]      = input clien.prodta[2]
		clien.proprof[1]     = input clien.proprof[1].
	    assign
		clien.proprof[2]     = input clien.proprof[2]
		clien.prorenda[1]    = input clien.prorenda[1]
		clien.prorenda[2]    = input clien.prorenda[2]
		clien.conjuge        = input clien.conjuge
		clien.nascon         = input clien.nascon
		clien.refcom[1]      = input clien.refcom[1]
		clien.refcom[2]      = input clien.refcom[2]
		clien.refcom[3]      = input clien.refcom[3]
		clien.refcom[4]      = input clien.refcom[4]
		clien.refcom[5]      = input clien.refcom[5]
		clien.refnome        = input clien.refnome
		clien.reftel         = input clien.reftel
		clien.classe         = input clien.classe
		clien.limite         = input clien.limite
		clien.medatr         = input clien.medatr
		clien.dtcad          = input clien.dtcad
		clien.situacao       = input clien.situacao
		clien.dtspc[1]       = input clien.dtspc[1]
		clien.dtspc[2]       = input clien.dtspc[2]
		clien.dtspc[3]       = input clien.dtspc[3]
		clien.autoriza[1]    = input clien.autoriza[1]
		clien.autoriza[2]    = input clien.autoriza[2]
		clien.autoriza[3]    = input clien.autoriza[3]
		clien.autoriza[4]    = input clien.autoriza[4]
		clien.autoriza[5]    = input clien.autoriza[5]
		clien.conjpai        = input clien.conjpai
		clien.conjmae        = input clien.conjmae
		clien.cep[1]         = input clien.cep[1]
		clien.cep[2]         = input clien.cep[2]
		clien.cep[3]         = input clien.cep[3]
		clien.cep[4]         = input clien.cep[4]
		clien.cobbairro[1]   = input clien.cobbairro[1]
		clien.cobbairro[2]   = input clien.cobbairro[2]
		clien.cobbairro[3]   = input clien.cobbairro[3]
		clien.cobbairro[4]   = input clien.cobbairro[4]
		clien.cobcep[1]      = input clien.cobcep[1]
		clien.cobcep[2]      = input clien.cobcep[2]
		clien.cobcep[3]      = input clien.cobcep[3]
		clien.cobcep[4]      = input clien.cobcep[4]
		clien.cobcidade[1]   = input clien.cobcidade[1]
		clien.cobcidade[2]   = input clien.cobcidade[2]
		clien.cobcidade[3]   = input clien.cobcidade[3]
		clien.cobcidade[4]   = input clien.cobcidade[4]
		clien.cobcompl[1]    = input clien.cobcompl[1]
		clien.cobcompl[2]    = input clien.cobcompl[2]
		clien.cobcompl[3]    = input clien.cobcompl[3]
		clien.cobcompl[4]    = input clien.cobcompl[4]
		clien.cobendereco[1] = input clien.cobendereco[1]
		clien.cobendereco[2] = input clien.cobendereco[2]
		clien.cobendereco[3] = input clien.cobendereco[3]
		clien.cobendereco[4] = input clien.cobendereco[4]
		clien.cfobnumero[1]  = input clien.cfobnumero[1]
		clien.cfobnumero[2]  = input clien.cfobnumero[2]
		clien.cfobnumero[3]  = input clien.cfobnumero[3]
		clien.cfobnumero[4]  = input clien.cfobnumero[4].
	    assign
		clien.cobrefcom[1]   = input clien.cobrefcom[1]
		clien.cobrefcom[2]   = input clien.cobrefcom[2]
		clien.cobrefcom[3]   = input clien.cobrefcom[3]
		clien.cobrefcom[4]   = input clien.cobrefcom[4]
		clien.cobrefcom[5]   = input clien.cobrefcom[5]
		clien.cobrefnome     = input clien.cobrefnome
		clien.cobufecod[1]   = input clien.cobufecod[1]
		clien.cobufecod[2]   = input clien.cobufecod[2]
		clien.cobufecod[3]   = input clien.cobufecod[3]
		clien.cobufecod[4]   = input clien.cobufecod[4]
		clien.refccont[1]    = input clien.refccont[1]
		clien.refccont[2]    = input clien.refccont[2]
		clien.refccont[3]    = input clien.refccont[3]
		clien.refccont[4]    = input clien.refccont[4]
		clien.refccont[5]    = input clien.refccont[5]
		clien.refctel[1]     = input clien.refctel[1]
		clien.refctel[2]     = input clien.refctel[2]
		clien.refctel[3]     = input clien.refctel[3]
		clien.refctel[4]     = input clien.refctel[4]
		clien.refctel[5]     = input clien.refctel[5]
		clien.refcinfo[1]    = input clien.refcinfo[1]
		clien.refcinfo[2]    = input clien.refcinfo[2]
		clien.refcinfo[3]    = input clien.refcinfo[3]
		clien.refcinfo[4]    = input clien.refcinfo[4]
		clien.refcinfo[5]    = input clien.refcinfo[5]
		clien.refbcont[1]    = input clien.refbcont[1]
		clien.refbcont[2]    = input clien.refbcont[2]
		clien.refbcont[3]    = input clien.refbcont[3]
		clien.refbcont[4]    = input clien.refbcont[4]
		clien.refbcont[5]    = input clien.refbcont[5]
		clien.refbinfo[1]    = input clien.refbinfo[1]
		clien.refbinfo[2]    = input clien.refbinfo[2]
		clien.refbinfo[3]    = input clien.refbinfo[3]
		clien.refbinfo[4]    = input clien.refbinfo[4]
		clien.refbinfo[5]    = input clien.refbinfo[5]
		clien.refban[1]      = input clien.refban[1]
		clien.refban[2]      = input clien.refban[2]
		clien.refban[3]      = input clien.refban[3]
		clien.refban[4]      = input clien.refban[4]
		clien.refban[5]      = input clien.refban[5].
	  assign
		clien.refbtel[1]     = input clien.refbtel[1]
		clien.refbtel[2]     = input clien.refbtel[2]
		clien.refbtel[3]     = input clien.refbtel[3]
		clien.refbtel[4]     = input clien.refbtel[4]
		clien.refbtel[5]     = input clien.refbtel[5]
		clien.entbairro[1]   = input clien.entbairro[1]
		clien.entbairro[2]   = input clien.entbairro[2]
		clien.entbairro[3]   = input clien.entbairro[3]
		clien.entbairro[4]   = input clien.entbairro[4]
		clien.entcep[1]      = input clien.entcep[1]
		clien.entcep[2]      = input clien.entcep[2]
		clien.entcep[3]      = input clien.entcep[3]
		clien.entcep[4]      = input clien.entcep[4]
		clien.entcidade[1]   = input clien.entcidade[1]
		clien.entcidade[2]   = input clien.entcidade[2]
		clien.entcidade[3]   = input clien.entcidade[3]
		clien.entcidade[4]   = input clien.entcidade[4]
		clien.entcompl[1]    = input clien.entcompl[1]
		clien.entcompl[2]    = input clien.entcompl[2]
		clien.entcompl[3]    = input clien.entcompl[3]
		clien.entcompl[4]    = input clien.entcompl[4]
		clien.entendereco[1] = input clien.entendereco[1]
		clien.entendereco[2] = input clien.entendereco[2]
		clien.entendereco[3] = input clien.entendereco[3]
		clien.entendereco[4] = input clien.entendereco[4]
		clien.entrefcom[1]   = input clien.entrefcom[1]
		clien.entrefcom[2]   = input clien.entrefcom[2]
		clien.entrefcom[3]   = input clien.entrefcom[3]
		clien.entrefcom[4]   = input clien.entrefcom[4]
		clien.entrefcom[5]   = input clien.entrefcom[5]
		clien.entrefnome     = input clien.entrefnome
		clien.entufecod[1]   = input clien.entufecod[1]
		clien.entufecod[2]   = input clien.entufecod[2]
		clien.entufecod[3]   = input clien.entufecod[3]
		clien.entufecod[4]   = input clien.entufecod[4].
	    assign
		clien.fax            = input clien.fax
		clien.contato        = input clien.contato
		clien.tracod         = input clien.tracod
		clien.vencod         = input clien.vencod
		clien.entfone        = input clien.entfone
		clien.cobfone        = input clien.cobfone
		clien.entnumero[1]   = input clien.entnumero[1]
		clien.entnumero[2]   = input clien.entnumero[2]
		clien.entnumero[3]   = input clien.entnumero[3]
		clien.entnumero[4]   = input clien.entnumero[4]
		clien.cobnumero[1]   = input clien.cobnumero[1]
		clien.cobnumero[2]   = input clien.cobnumero[2]
		clien.cobnumero[3]   = input clien.cobnumero[3]
		clien.cobnumero[4]   = input clien.cobnumero[4]
		clien.ccivil         = input clien.ccivil
		clien.zona           = input clien.zona
		clien.datexp         = input clien.datexp
		clien.datexp         = today
		clien.limcrd         = input clien.limcrd.
	vtotcli = vtotcli + 1.

	conta5 = conta5 + 1.
	display stream tela conta5 with frame fmostra.
	display stream tela string((time - vhora),"HH:MM:SS")
			@ vhora with frame fhora.

    end.
    input close.
end.
