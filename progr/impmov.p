{admcab.i}
do transaction:
if search("plani1.d") <> ?
then do on error undo:
    pause 0.
    input from plani1.d no-echo.
    repeat:
	prompt-for plani.movtdc
		   plani.PlaCod
		   plani.Numero
		   plani.PlaDat
		   plani.Serie
		   plani.vencod
		   plani.plades
		   plani.crecod
		   plani.VlServ
		   plani.DescServ
		   plani.AcFServ
		   plani.PedCod
		   plani.ICMS
		   plani.BSubst
		   plani.ICMSSubst
		   plani.BIPI
		   plani.AlIPI
		   plani.IPI
		   plani.Seguro
		   plani.Frete
		   plani.DesAcess
		   plani.DescProd
		   plani.AcFProd
		   plani.ModCod
		   plani.AlICMS
		   plani.Outras
		   plani.AlISS
		   plani.BICMS
		   plani.UFEmi
		   plani.BISS
		   plani.CusMed
		   plani.UserCod
		   plani.DtInclu
		   plani.HorIncl
		   plani.NotSit
		   plani.NotFat
		   plani.HiCCod
		   plani.NotObs[1]
		   plani.NotObs[2]
		   plani.NotObs[3]
		   plani.RespFre
		   plani.NotTran
		   plani.Isenta
		   plani.ISS
		   plani.NotPis
		   plani.NotAss
		   plani.NotCoFinS
		   plani.TMovDev
		   plani.Desti
		   plani.IndEmi
		   plani.Emite
		   plani.NotPed
		   plani.PLaTot
		   plani.OpCCod
		   plani.UFDes
		   plani.ProTot
		   plani.EtbCod
		   plani.cxacod
		   plani.datexp with no-validate.
	find plani where plani.etbcod = input plani.etbcod and
			 plani.placod = input plani.placod no-error.
	if not avail plani
	then do:
	    if input plani.etbcod = setbcod or
	       input plani.desti  = setbcod
	    then do:
		create plani.
		ASSIGN plani.movtdc    = input plani.movtdc
		       plani.PlaCod    = input plani.PlaCod
		       plani.Numero    = input plani.Numero
		       plani.PlaDat    = input plani.PlaDat
		       plani.Serie     = input plani.Serie
		       plani.vencod    = input plani.vencod
		       plani.plades    = input plani.plades
		       plani.crecod    = input plani.crecod
		       plani.VlServ    = input plani.VlServ
		       plani.DescServ  = input plani.DescServ
		       plani.AcFServ   = input plani.AcFServ
		       plani.PedCod    = input plani.PedCod
		       plani.ICMS      = input plani.ICMS
		       plani.BSubst    = input plani.BSubst
		       plani.ICMSSubst = input plani.ICMSSubst
		       plani.BIPI      = input plani.BIPI
		       plani.AlIPI     = input plani.AlIPI
		       plani.IPI       = input plani.IPI
		       plani.Seguro    = input plani.Seguro
		       plani.Frete     = input plani.Frete
		       plani.DesAcess  = input plani.DesAcess
		       plani.DescProd  = input plani.DescProd
		       plani.AcFProd   = input plani.AcFProd
		       plani.ModCod    = input plani.ModCod
		       plani.AlICMS    = input plani.AlICMS
		       plani.Outras    = input plani.Outras
		       plani.AlISS     = input plani.AlISS
		       plani.BICMS     = input plani.BICMS
		       plani.UFEmi     = input plani.UFEmi
		       plani.BISS      = input plani.BISS
		       plani.CusMed    = input plani.CusMed
		       plani.UserCod   = input plani.UserCod
		       plani.DtInclu   = input plani.DtInclu
		       plani.HorIncl   = input plani.HorIncl
		       plani.NotSit    = input plani.NotSit
		       plani.NotFat    = input plani.NotFat
		       plani.HiCCod    = input plani.HiCCod
		       plani.NotObs[1] = input plani.NotObs[1]
		       plani.NotObs[2] = input plani.NotObs[2]
		       plani.NotObs[3] = input plani.NotObs[3]
		       plani.RespFre   = input plani.RespFre
		       plani.NotTran   = input plani.NotTran
		       plani.Isenta    = input plani.Isenta
		       plani.ISS       = input plani.ISS
		       plani.NotPis    = input plani.NotPis
		       plani.NotAss    = input plani.NotAss
		       plani.NotCoFinS = input plani.NotCoFinS
		       plani.TMovDev   = input plani.TMovDev
		       plani.Desti     = input plani.Desti
		       plani.IndEmi    = input plani.IndEmi
		       plani.Emite     = input plani.Emite
		       plani.NotPed    = input plani.NotPed
		       plani.PLaTot    = input plani.PLaTot
		       plani.OpCCod    = input plani.OpCCod
		       plani.UFDes     = input plani.UFDes
		       plani.ProTot    = input plani.ProTot
		       plani.EtbCod    = input plani.EtbCod
		       plani.cxacod    = input plani.cxacod
		       plani.datexp    = input plani.datexp.
	    end.
	end.
    end.
    input from plani2.d no-echo.
    repeat:
	prompt-for plani.movtdc
		   plani.PlaCod
		   plani.Numero
		   plani.PlaDat
		   plani.Serie
		   plani.vencod
		   plani.plades
		   plani.crecod
		   plani.VlServ
		   plani.DescServ
		   plani.AcFServ
		   plani.PedCod
		   plani.ICMS
		   plani.BSubst
		   plani.ICMSSubst
		   plani.BIPI
		   plani.AlIPI
		   plani.IPI
		   plani.Seguro
		   plani.Frete
		   plani.DesAcess
		   plani.DescProd
		   plani.AcFProd
		   plani.ModCod
		   plani.AlICMS
		   plani.Outras
		   plani.AlISS
		   plani.BICMS
		   plani.UFEmi
		   plani.BISS
		   plani.CusMed
		   plani.UserCod
		   plani.DtInclu
		   plani.HorIncl
		   plani.NotSit
		   plani.NotFat
		   plani.HiCCod
		   plani.NotObs[1]
		   plani.NotObs[2]
		   plani.NotObs[3]
		   plani.RespFre
		   plani.NotTran
		   plani.Isenta
		   plani.ISS
		   plani.NotPis
		   plani.NotAss
		   plani.NotCoFinS
		   plani.TMovDev
		   plani.Desti
		   plani.IndEmi
		   plani.Emite
		   plani.NotPed
		   plani.PLaTot
		   plani.OpCCod
		   plani.UFDes
		   plani.ProTot
		   plani.EtbCod
		   plani.cxacod
		   plani.datexp with no-validate.
	find plani where plani.etbcod = input plani.etbcod and
			 plani.placod = input plani.placod no-error.
	if not avail plani
	then do:
	    if input plani.etbcod = setbcod or
	       input plani.desti  = setbcod
	    then do:
		create plani.
		ASSIGN plani.movtdc    = input plani.movtdc
		       plani.PlaCod    = input plani.PlaCod
		       plani.Numero    = input plani.Numero
		       plani.PlaDat    = input plani.PlaDat
		       plani.Serie     = input plani.Serie
		       plani.vencod    = input plani.vencod
		       plani.plades    = input plani.plades
		       plani.crecod    = input plani.crecod
		       plani.VlServ    = input plani.VlServ
		       plani.DescServ  = input plani.DescServ
		       plani.AcFServ   = input plani.AcFServ
		       plani.PedCod    = input plani.PedCod
		       plani.ICMS      = input plani.ICMS
		       plani.BSubst    = input plani.BSubst
		       plani.ICMSSubst = input plani.ICMSSubst
		       plani.BIPI      = input plani.BIPI
		       plani.AlIPI     = input plani.AlIPI
		       plani.IPI       = input plani.IPI
		       plani.Seguro    = input plani.Seguro
		       plani.Frete     = input plani.Frete
		       plani.DesAcess  = input plani.DesAcess
		       plani.DescProd  = input plani.DescProd
		       plani.AcFProd   = input plani.AcFProd
		       plani.ModCod    = input plani.ModCod
		       plani.AlICMS    = input plani.AlICMS
		       plani.Outras    = input plani.Outras
		       plani.AlISS     = input plani.AlISS
		       plani.BICMS     = input plani.BICMS
		       plani.UFEmi     = input plani.UFEmi
		       plani.BISS      = input plani.BISS
		       plani.CusMed    = input plani.CusMed
		       plani.UserCod   = input plani.UserCod
		       plani.DtInclu   = input plani.DtInclu
		       plani.HorIncl   = input plani.HorIncl
		       plani.NotSit    = input plani.NotSit
		       plani.NotFat    = input plani.NotFat
		       plani.HiCCod    = input plani.HiCCod
		       plani.NotObs[1] = input plani.NotObs[1]
		       plani.NotObs[2] = input plani.NotObs[2]
		       plani.NotObs[3] = input plani.NotObs[3]
		       plani.RespFre   = input plani.RespFre
		       plani.NotTran   = input plani.NotTran
		       plani.Isenta    = input plani.Isenta
		       plani.ISS       = input plani.ISS
		       plani.NotPis    = input plani.NotPis
		       plani.NotAss    = input plani.NotAss
		       plani.NotCoFinS = input plani.NotCoFinS
		       plani.TMovDev   = input plani.TMovDev
		       plani.Desti     = input plani.Desti
		       plani.IndEmi    = input plani.IndEmi
		       plani.Emite     = input plani.Emite
		       plani.NotPed    = input plani.NotPed
		       plani.PLaTot    = input plani.PLaTot
		       plani.OpCCod    = input plani.OpCCod
		       plani.UFDes     = input plani.UFDes
		       plani.ProTot    = input plani.ProTot
		       plani.EtbCod    = input plani.EtbCod
		       plani.cxacod    = input plani.cxacod
		       plani.datexp    = input plani.datexp.
	    end.
	end.
    end.
end.
if search("movim1.d") <> ?
then do on error undo:
    pause 0.
    input from movim1.d no-echo.
    repeat:
	prompt-for movim.movtdc
		   movim.PlaCod
		   movim.etbcod
		   movim.movseq
		   movim.procod
		   movim.movqtm
		   movim.movpc
		   movim.MovDev
		   movim.MovAcFin
		   movim.movipi
		   movim.MovPro
		   movim.MovICMS
		   movim.MovAlICMS
		   movim.MovPDesc
		   movim.MovCtM
		   movim.MovAlIPI
		   movim.movdat
		   movim.MovHr
		   movim.MovDes
		   movim.MovSubst
		   movim.OCNum[1]
		   movim.OCNum[2]
		   movim.OCNum[3]
		   movim.OCNum[4]
		   movim.OCNum[5]
		   movim.OCNum[6]
		   movim.OCNum[7]
		   movim.OCNum[8]
		   movim.OCNum[9]
		   movim.datexp with no-validate.
	find movim where movim.etbcod = input movim.etbcod and
			 movim.placod = input movim.placod and
			 movim.procod = input movim.procod no-error.

	if not avail movim
	then do:
	    find plani where plani.etbcod = input movim.etbcod and
			     plani.placod = input movim.placod no-lock no-error.
	    if avail plani
	    then do:
		create movim.
		ASSIGN movim.movtdc    = input movim.movtdc
		       movim.PlaCod    = input movim.PlaCod
		       movim.etbcod    = input movim.etbcod
		       movim.movseq    = input movim.movseq
		       movim.procod    = input movim.procod
		       movim.movqtm    = input movim.movqtm
		       movim.movpc     = input movim.movpc
		       movim.MovDev    = input movim.MovDev
		       movim.MovAcFin  = input movim.MovAcFin
		       movim.movipi    = input movim.movipi
		       movim.MovPro    = input movim.MovPro
		       movim.MovICMS   = input movim.MovICMS
		       movim.MovAlICMS = input movim.MovAlICMS
		       movim.MovPDesc  = input movim.MovPDesc
			   movim.MovCtM    = input movim.MovCtM
			   movim.MovAlIPI  = input movim.MovAlIPI
			   movim.movdat    = input movim.movdat
			   movim.MovHr     = input movim.MovHr
			   movim.MovDes    = input movim.MovDes
			   movim.MovSubst  = input movim.MovSubst
			   movim.OCNum[1]  = input movim.OCNum[1]
			   movim.OCNum[2]  = input movim.OCNum[2]
			   movim.OCNum[3]  = input movim.OCNum[3]
			   movim.OCNum[4]  = input movim.OCNum[4]
			   movim.OCNum[5]  = input movim.OCNum[5]
			   movim.OCNum[6]  = input movim.OCNum[6]
			   movim.OCNum[7]  = input movim.OCNum[7]
			   movim.OCNum[8]  = input movim.OCNum[8]
			   movim.OCNum[9]  = input movim.OCNum[9]
			   movim.datexp    = input movim.datexp.

	    end.
	end.
    end.
    input from movim2.d no-echo.
    repeat:
	prompt-for movim.movtdc
		   movim.PlaCod
		   movim.etbcod
		   movim.movseq
		   movim.procod
		   movim.movqtm
		   movim.movpc
		   movim.MovDev
		   movim.MovAcFin
		   movim.movipi
		   movim.MovPro
		   movim.MovICMS
		   movim.MovAlICMS
		   movim.MovPDesc
		   movim.MovCtM
		   movim.MovAlIPI
		   movim.movdat
		   movim.MovHr
		   movim.MovDes
		   movim.MovSubst
		   movim.OCNum[1]
		   movim.OCNum[2]
		   movim.OCNum[3]
		   movim.OCNum[4]
		   movim.OCNum[5]
		   movim.OCNum[6]
		   movim.OCNum[7]
		   movim.OCNum[8]
		   movim.OCNum[9]
		   movim.datexp with no-validate.
	find movim where movim.etbcod = input movim.etbcod and
			 movim.placod = input movim.placod and
			 movim.procod = input movim.procod no-error.

	if not avail movim
	then do:
	    find plani where plani.etbcod = input movim.etbcod and
			     plani.placod = input movim.placod no-lock no-error.
	    if avail plani
	    then do:
		create movim.
		ASSIGN movim.movtdc    = input movim.movtdc
		       movim.PlaCod    = input movim.PlaCod
		       movim.etbcod    = input movim.etbcod
		       movim.movseq    = input movim.movseq
		       movim.procod    = input movim.procod
		       movim.movqtm    = input movim.movqtm
		       movim.movpc     = input movim.movpc
		       movim.MovDev    = input movim.MovDev
		       movim.MovAcFin  = input movim.MovAcFin
		       movim.movipi    = input movim.movipi
		       movim.MovPro    = input movim.MovPro
		       movim.MovICMS   = input movim.MovICMS
		       movim.MovAlICMS = input movim.MovAlICMS
		       movim.MovPDesc  = input movim.MovPDesc
			   movim.MovCtM    = input movim.MovCtM
			   movim.MovAlIPI  = input movim.MovAlIPI
			   movim.movdat    = input movim.movdat
			   movim.MovHr     = input movim.MovHr
			   movim.MovDes    = input movim.MovDes
			   movim.MovSubst  = input movim.MovSubst
			   movim.OCNum[1]  = input movim.OCNum[1]
			   movim.OCNum[2]  = input movim.OCNum[2]
			   movim.OCNum[3]  = input movim.OCNum[3]
			   movim.OCNum[4]  = input movim.OCNum[4]
			   movim.OCNum[5]  = input movim.OCNum[5]
			   movim.OCNum[6]  = input movim.OCNum[6]
			   movim.OCNum[7]  = input movim.OCNum[7]
			   movim.OCNum[8]  = input movim.OCNum[8]
			   movim.OCNum[9]  = input movim.OCNum[9]
			   movim.datexp    = input movim.datexp.

	    end.
	end.
    end.
end.
end.
