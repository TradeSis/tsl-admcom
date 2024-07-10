/***************************************************************************
** Programa        : Impmatb4.p
** Objetivo        : Importacao de Dados da Loja
** Ultima Alteracao: 01/11/96
** Programador     : Cristiano Borges Brasil
** Chama Programa  : ImpMatLj.p
****************************************************************************/
{admcab.i}

def var vfilial like estoq.etbcod.
def var vprocod like estoq.procod.
def var vdata   as cha.
def var vpreven like estoq.estvenda.
def var vprecus like estoq.estcusto.
def var vprevei like estoq.estpedven.

def buffer bestoq for estoq.

def var vunidade    as char initial "A:".


def var vclacod as char format "999".

def var vpronom like produ.pronom.
def var vuni like produ.prouncom.
def var vdep as i format "99". /* like produ.catcod. */
def var vproclafis like produ.proclafis.
def var vproipiper like produ.proipiper.
/*
def var vproipival /* like produ.proipival. */
*/
def var vgrupo as int format "99".
def var vsubgrupo as i. /* as int format "9". */
def var vdigito   as int format "9" no-undo.

def stream tela.

output stream tela to terminal.

update sresp label "Confirma Importacao de Dados ? "
	with row 19 column 13 color white/red side-labels frame f1.
if  not sresp then quit.

message "Com disquete ?" update sresp.
if sresp
then do:
    update vunidade label "Unidade"
	   help "Informe a unidade de Disquete ==>  A:  ou  B: "
	   with frame funidade row 19 column 52 overlay color white/red
			side-label.
    if vunidade = "A:"
    then do:
	dos silent "del  ..\import\cespro01.txt".
	dos silent "del  ..\import\cespre01.txt".

	dos silent "copy a:\cespro01.txt ..\import /Y /V".
	dos silent "copy a:\cespre01.txt ..\import /Y /V".

    end.
    else
	if vunidade = "b:"
	then do:
	    dos silent "del  ..\import\cespro01.txt".
	    dos silent "del  ..\import\cespre01.txt".

	    dos silent "copy b:\cespro01.txt ..\import /Y /V".
	    dos silent "copy b:\cespre01.txt ..\import /Y /V".
	end.
	else do:
	    message "Unidade Invalida". undo.
	end.
end.

dos silent "quoter -d % ..\import\cespro01.txt > ..\import\cespro01.q" .
dos silent "quoter -d % ..\import\cespre01.txt > ..\import\cespre01.q" .


pause 0 before-hide.

input from ../import/cespro01.q no-echo.

repeat:
   import vprocod
	  vdigito
	  vpronom
	  vuni
	  ^
	  vdep
	  vproclafis
	  ^
	  ^
	  ^
	  vproipiper
	  ^                    /* vproipival */
	  vgrupo
	  vsubgrupo
	  ^
	  ^.

   displ vprocod
	 vdigito
	  vpronom with 1 down.
	  /*
	  vuni
	  vdep
	  vproclafis
	  vproipiper
	  /* vproipival  */
	  vgrupo
	  vsubgrupo.

	  pause.
	  */
   vclacod = string(vgrupo,"99") + string(vsubgrupo,"9").

   find produ where produ.procod = vprocod no-error.
   if not avail produ
   then create produ.

   assIGN produ.procod   = vprocod                           .
	  /* produ.fabcod    = {2}.fabcod */
	  /* produ.refer     = {2}.refer  */
	  produ.pronom    = vpronom                          .
	  produ.pronomc   = vpronom                          .
   assign produ.clacod    = int(vclacod)                  .
	  produ.prouncom  = vuni           .
	  produ.prounven  = vuni                     .
	  /* produ.proabc    = {2}.proabc */
	  produ.prodtcad  = today                              .
	  produ.itecod    = produ.procod .
	  produ.proipiper = vproipiper                          .
	  /* produ.proipival = vproipival */
	  produ.proclafis = vproclafis                            .
	  /* produ.procvven  = {2}.procvven */
	  /* produ.procvcom  = {2}.procvcom */
	  /* produ.corcod    = {2}.corcod */
	  produ.etccod    = vdigito                                .
	  /* produ.procar    = {2}.procar */
	  produ.catcod    = vdep /* Codigo do Departamento */       .
	  /* produ.gracod    = {2}.gracod  */
	  /* produ.tamcod    = {2}.tamcod */
	  /* produ.ProPer    = {2}.ProPer */ .

end.

input close.


input from ..\import\cespre01.q no-echo.

pause 0 before-hide.

repeat:
   import vfilial
	  vprocod
	  vdata
	  vpreven
	  vprecus
	  vprevei.

   assign vpreven = vpreven / 100
	  vprecus = vprecus / 100
	  vprevei = vprevei / 100.

   displ setbcod
	  vprocod with 1 down.

   find first estoq where estoq.procod = vprocod and
			  estoq.etbcod = setbcod no-error.
   if not available estoq
   then do:
      create estoq.
      assign estoq.procod    = vprocod
	     estoq.etbcod    = setbcod.
   end.
   assign estoq.estdtven  = date( int( substring( vdata, 3, 2 ) ),
				  int( substring( vdata, 1, 2 ) ),
				  int( substring( vdata, 5, 2 ) ) )
	  estoq.estvenda  = vpreven
	  estoq.estcusto  = vprecus
	  estoq.estpedven = vprevei.

    for each estab:

	if estab.etbcod = setbcod
	then next.

	find bestoq where bestoq.procod = estoq.procod and
			  bestoq.etbcod = estab.etbcod no-error.
	if not avail bestoq
	then do:
	    create bestoq.
	    assign bestoq.procod    = estoq.procod
		   bestoq.etbcod    = estab.etbcod.
	end.
	assign  bestoq.estdtven  = estoq.estdtven
		bestoq.estvenda  = estoq.estvenda
		bestoq.estcusto  = estoq.estcusto
		bestoq.estpedven = estoq.estpedven.
    end.

end.

input close.
