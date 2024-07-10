/***************************************************************************
** Programa        : Atualiza.p
** Objetivo        : Exportacao de Dados para o CPD
** Ultima Alteracao: 01/11/2000
** Programador     : Nemora da Silva Berdete
****************************************************************************/

{admdisparo.i new}.

def var vult        as dec.
def var vlog        as char.
def var vlog1       as char.
def var i           as int initial 0    no-undo.
def var lg-atuger   as log initial no   no-undo.
def var lg-atufin   as log initial no   no-undo.
def var lg-atucom   as log initial no   no-undo.
def var cont as int.

def new shared temp-table tt-deposito      like ger.deposito.
def new shared temp-table tt-depban        like fin.depban.
def new shared temp-table tt-contnf        like fin.contnf.
def new shared temp-table tt-movim         like com.movim.
def new shared temp-table tt-titulo        like fin.titulo.
def new shared temp-table tt-plani         like com.plani.
def new shared temp-table tt-pedid         like com.pedid.
def new shared temp-table tt-liped         like com.liped.
def new shared temp-table tt-globa         like com.globa.
def new shared temp-table tt-glopre        like ger.glopre.
def new shared temp-table tt-nottra        like com.nottra.
def new shared temp-table tt-clien         like ger.clien.
def new shared temp-table tt-produ         like com.produ.
def new shared temp-table tt-contrato      like fin.contrato.
def new shared temp-table tt-salexporta    like fin.salexporta.
def new shared temp-table tt-func          like ger.func.
def new shared temp-table tt-serial        like ger.serial.
def new shared temp-table tt-correio       like fin.correio.
def new shared temp-table tt-chq           like fin.chq.
def new shared temp-table tt-chqtit        like fin.chqtit.
                            

def shared var vcom as dec.
def shared var vfin as dec.
def shared var vger as dec.

for each tt-serial :
    delete tt-serial.
end.

for each tt-deposito :
    delete tt-deposito.
end.

for each tt-depban:
    delete tt-depban.
end.

for each tt-produ.
    delete tt-produ.
end.    

for each tt-contnf:
    delete tt-contnf.
end.

for each tt-movim:
    delete tt-movim.
end.

for each tt-titulo:
    delete tt-titulo.
end.

for each tt-plani:
    delete tt-plani.
end.

for each tt-pedid:
    delete tt-pedid.
end.

for each tt-liped:
    delete tt-liped.
end.

for each tt-globa:
    delete tt-globa.
end.

for each tt-glopre:
    delete tt-glopre.
end.

for each tt-nottra:
    delete tt-nottra.
end.

for each tt-clien:
    delete tt-clien.
end.

for each tt-contrato:
    delete tt-contrato.
end.

for each tt-correio.
    delete tt-correio.
end.

for each tt-salexporta:
    delete tt-salexporta.
end.

for each tt-chq:
    delete tt-chq.
end.

for each tt-chqtit:
    delete tt-chqtit.
end.


for each tt-func:
    delete tt-func.
end.
                            
vlog = "/usr/admcom/work/atual1" + string(time) + ".log".
vlog1 = "/usr/admcom/work/log." + string(day(today)) + string(month(today)).

output to value(vlog) append.
    put today format "99/99/9999"  space(1)
        string(time,"hh:mm:ss") space(1)         " COMECANDO ... " 
        skip.
output close.        

output to value(vlog1) append.
    put "Atual001.p -   Comecando"  space(2)
        string(time,"hh:mm:ss")
         skip.
output close.


output to value(vlog1) append.
    put "Atual001.p - Ex   Serial" space(2)
        string(time,"hh:mm:ss")
         skip.
output close.

cont = 0.
for each serial where serial.serdat >= today - 2 no-lock :

    output to value(vlog) append.
        put today format "99/99/9999" space(1) 
            " Exportando Serial --> Matriz ." 
            space(1)             
            serial.etbcod 
            skip.
    output close. 
    cont = cont + 1.
    create tt-serial.
    {tt-serial.i tt-serial serial}.
end.

output to value(vlog1) append.
    put "Atual001.p - Seriais " cont 
        skip 
        "Atual001.p - Ex Correio"  space(2)
        string(time,"hh:mm:ss")
         skip.
output close.

cont = 0.
for each correio where correio.dtmens >= today - 1 no-lock :
    output to value(vlog) append.
        put today format "99/99/9999" space(1) 
            " Exportando correio --> Matriz ." 
            space(1)             
            correio.assunto 
            skip.
    output close. 
    cont = cont + 1.
    create tt-correio.
    {tt-correio.i tt-correio correio}.
end.

output to value(vlog1) append.
    put "Atual001.p - Correios " cont
    skip
        "Atual001.p - Ex Deposito"  space(2)
        string(time,"hh:mm:ss")
         skip.
output close.

cont = 0.
for each deposito where deposito.datmov >= today - 2 no-lock :

    output to value(vlog) append.
        put today format "99/99/9999" space(1) 
            " Exportando Depostito Loja --> Matriz ." 
            space(1)
            deposito.etbcod 
            skip.
    output close. 
    cont = cont + 1.
    create tt-deposito.
    {tt-deposito.i tt-deposito deposito}.
end.

output to value(vlog1) append.
    put "Atual001.p - Depositos " cont 
        skip
        "Atual001.p - Ex DepBan"   space(2)
        string(time,"hh:mm:ss")
         skip.
output close.

cont = 0.
for each depban where depban.datexp >= today - 2 no-lock:

    output to value(vlog) append.
        put today format "99/99/9999" space(1) 
            " Exportando Dep.Bancario Loja --> Matriz ." 
            space(1)
            depban.etbcod 
            skip.
    output close. 
    cont = cont + 1.
    create tt-depban.
    {tt-depban.i tt-depban depban}.
end.

output to value(vlog1) append.
    put "Atual001.p - DepBan " cont 
        skip 
        "Atual001.p - Ex GloPre"  space(2)
        string(time,"hh:mm:ss")
         skip.
output close.

cont = 0.
for each glopre where glopre.datexp = today no-lock.
     
    output to value(vlog) append.
        put today format "99/99/9999" space(1) 
            " Exportando Carne de Consorc. Loja --> Matriz ." 
            space(1)
            glopre.numero 
            skip.
    output close. 
    cont = cont + 1.
    create tt-glopre.
    {tt-glopre.i tt-glopre glopre}.
end.
output to value(vlog1) append.
    put "Atual001.p - Glopre " cont 
        skip 
        "Atual001.p - Ex ContNF"   space(2)
        string(time,"hh:mm:ss")
         skip.
output close.
cont = 0.
for each contrato where contrato.dtinicial >= (today - 10) no-lock.
    if contrato.exportado = yes then next.
    for each contnf where contnf.etbcod  = contrato.etbcod and
                          contnf.contnum = contrato.contnum no-lock. 
        if contnf.exportado = yes  then next.
        output to value(vlog) append.
        put today format "99/99/9999" space(1) 
            " Exportando Connf Loja --> Matriz ." 
            space(1)
            contnf.contnum
            skip.
        output close. 
        cont = cont + 1.
        create tt-contnf.
        ASSIGN
            tt-contnf.contnum   = contnf.contnum
            tt-contnf.PlaCod    = contnf.PlaCod
            tt-contnf.notanum   = contnf.notanum
            tt-contnf.notaser   = contnf.notaser
            tt-contnf.EtbCod    = contnf.EtbCod
            tt-contnf.exportado = contnf.exportado.
        lg-atufin = yes.
    end.
end.    
output to value(vlog1) append.
    put "Atual001.p - ContNF " cont 
        skip 
        "Atual001.p - Ex. Globa"  space(2)
        string(time,"hh:mm:ss")
         skip.
output close.
cont = 0.
for each globa where globa.exportado = no no-lock:
    
    output to value(vlog) append.
        put today format "99/99/9999" space(1) 
            " Exportando Globa Loja --> Matriz ." 
            space(1)
            globa.etbcod
            space(1)
            skip.
    output close.
    cont = cont + 1.
    create tt-globa.
    ASSIGN
        tt-globa.etbcod    = globa.etbcod
        tt-globa.gloval    = globa.gloval
        tt-globa.glopar    = globa.glopar
        tt-globa.glogru    = globa.glogru
        tt-globa.glocot    = globa.glocot
        tt-globa.glodat    = globa.glodat
        tt-globa.exportado = globa.exportado.
    lg-atucom = yes.
end.
output to value(vlog1) append.
    put "Atual001.p - GloBa " cont
        skip
        "Atual001.p - Ex NotTra"  space(2)
        string(time,"hh:mm:ss")
         skip.
output close.
cont = 0.
for each nottra where nottra.exportado = no no-lock:
    
    output to value(vlog) append.
        put today format "99/99/9999"  space(1) 
            " Exportando NotTra Loja --> Matriz ." 
            space(1)
            nottra.etbcod
            skip.
    output close. 
    cont = cont + 1.
    create tt-nottra.
    ASSIGN
        tt-nottra.Etbcod    = nottra.Etbcod
        tt-nottra.desti     = nottra.desti
        tt-nottra.movtdc    = nottra.movtdc
        tt-nottra.datexp    = nottra.datexp
        tt-nottra.Serie     = nottra.Serie
        tt-nottra.livre     = nottra.livre
        tt-nottra.numero    = nottra.numero
        tt-nottra.exportado = nottra.exportado.

    lg-atuger = yes.
end.
output to value(vlog1) append.
    put "Atual001.p - NotTra  " cont
        skip 
        "Atual001.p - Ex Plani"  space(2)
        string(time,"hh:mm:ss")
         skip.
output close.
cont = 0.
for each plani where plani.datexp >= today - 10 no-lock.
    if plani.exportado = yes then next.
    output to value(vlog) append.
        put today format "99/99/9999" space(1) 
            " Exportando Plani Loja --> Matriz ." 
            space(1)
            plani.etbcod
            space(1)
            plani.numero
            space(1)
            plani.placod format "999999999999" 
            space(1)
            plani.pladat
            skip.
    output close.        
    cont = cont + 1.
    create tt-plani.
    ASSIGN
        tt-plani.movtdc    = plani.movtdc
        tt-plani.PlaCod    = plani.PlaCod
        tt-plani.Numero    = plani.Numero
        tt-plani.PlaDat    = plani.PlaDat
        tt-plani.Serie     = plani.Serie
        tt-plani.vencod    = plani.vencod
        tt-plani.plades    = plani.plades
        tt-plani.crecod    = plani.crecod
        tt-plani.VlServ    = plani.VlServ
        tt-plani.DescServ  = plani.DescServ
        tt-plani.AcFServ   = plani.AcFServ
        tt-plani.PedCod    = plani.PedCod
        tt-plani.ICMS      = plani.ICMS
        tt-plani.BSubst    = plani.BSubst
        tt-plani.ICMSSubst = plani.ICMSSubst
        tt-plani.BIPI      = plani.BIPI
        tt-plani.AlIPI     = plani.AlIPI
        tt-plani.IPI       = plani.IPI
        tt-plani.Seguro    = plani.Seguro
        tt-plani.Frete     = plani.Frete.

    ASSIGN
        tt-plani.DesAcess  = plani.DesAcess
        tt-plani.DescProd  = plani.DescProd
        tt-plani.AcFProd   = plani.AcFProd
        tt-plani.ModCod    = plani.ModCod
        tt-plani.AlICMS    = plani.AlICMS
        tt-plani.Outras    = plani.Outras
        tt-plani.AlISS     = plani.AlISS
        tt-plani.BICMS     = plani.BICMS
        tt-plani.UFEmi     = plani.UFEmi
        tt-plani.BISS      = plani.BISS
        tt-plani.CusMed    = plani.CusMed
        tt-plani.UserCod   = plani.UserCod
        tt-plani.DtInclu   = plani.DtInclu
        tt-plani.HorIncl   = plani.HorIncl
        tt-plani.NotSit    = plani.NotSit
        tt-plani.NotFat    = plani.NotFat
        tt-plani.HiCCod    = plani.HiCCod
        tt-plani.NotObs[1] = plani.NotObs[1]
        tt-plani.NotObs[2] = plani.NotObs[2]
        tt-plani.NotObs[3] = plani.NotObs[3].

    ASSIGN
        tt-plani.RespFre   = plani.RespFre
        tt-plani.NotTran   = plani.NotTran
        tt-plani.Isenta    = plani.Isenta
        tt-plani.ISS       = plani.ISS
        tt-plani.NotPis    = plani.NotPis
        tt-plani.NotAss    = plani.NotAss
        tt-plani.NotCoFinS = plani.NotCoFinS
        tt-plani.TMovDev   = plani.TMovDev
        tt-plani.Desti     = plani.Desti
        tt-plani.IndEmi    = plani.IndEmi
        tt-plani.Emite     = plani.Emite
        tt-plani.NotPed    = plani.NotPed
        tt-plani.PLaTot    = plani.PLaTot
        tt-plani.OpCCod    = plani.OpCCod
        tt-plani.UFDes     = plani.UFDes
        tt-plani.ProTot    = plani.ProTot
        tt-plani.EtbCod    = plani.EtbCod
        tt-plani.cxacod    = plani.cxacod
        tt-plani.datexp    = plani.datexp
        tt-plani.exportado = plani.exportado.

    lg-atucom = yes.
end.
output to value(vlog1) append.
    put "Atual001.p - Plani " cont
        skip 
        "Atual001.p - Ex Movim"   space(2)
        string(time,"hh:mm:ss")
         skip.
output close.
cont = 0.

for each movim where movim.exportado = no no-lock:
    
    output to value(vlog) append.
        put today format "99/99/9999" space(1) 
            " Export Movim Loja --> Matriz ." 
            space(1)
            movim.procod
            space(1)
            movim.movpc
            space(1)
            movim.movqtm
            space(1)
            movim.etbcod 
            space(1)
            movim.placod  format "99999999999" 
            skip.
    output close.        
    cont = cont + 1.
    create tt-movim.
    ASSIGN
        tt-movim.movtdc    = movim.movtdc
        tt-movim.PlaCod    = movim.PlaCod
        tt-movim.etbcod    = movim.etbcod
        tt-movim.emite     = movim.emite
        tt-movim.desti     = movim.desti 
        tt-movim.movseq    = movim.movseq
        tt-movim.procod    = movim.procod
        tt-movim.movqtm    = movim.movqtm
        tt-movim.movpc     = movim.movpc
        tt-movim.MovDev    = movim.MovDev
        tt-movim.MovAcFin  = movim.MovAcFin
        tt-movim.movipi    = movim.movipi
        tt-movim.MovPro    = movim.MovPro
        tt-movim.MovICMS   = movim.MovICMS
        tt-movim.MovAlICMS = movim.MovAlICMS
        tt-movim.MovPDesc  = movim.MovPDesc
        tt-movim.MovCtM    = movim.MovCtM
        tt-movim.MovAlIPI  = movim.MovAlIPI
        tt-movim.movdat    = movim.movdat
        tt-movim.MovHr     = movim.MovHr
        tt-movim.MovDes    = movim.MovDes
        tt-movim.MovSubst  = movim.MovSubst.

    ASSIGN
        tt-movim.OCNum[1]  = movim.OCNum[1]
        tt-movim.OCNum[2]  = movim.OCNum[2]
        tt-movim.OCNum[3]  = movim.OCNum[3]
        tt-movim.OCNum[4]  = movim.OCNum[4]
        tt-movim.OCNum[5]  = movim.OCNum[5]
        tt-movim.OCNum[6]  = movim.OCNum[6]
        tt-movim.OCNum[7]  = movim.OCNum[7]
        tt-movim.OCNum[8]  = movim.OCNum[8]
        tt-movim.OCNum[9]  = movim.OCNum[9]
        tt-movim.datexp    = movim.datexp
        tt-movim.exportado = movim.exportado.
        
    lg-atucom = yes.
end.
output to value(vlog1) append.
    put "Atual001.p - Movim " cont
        skip
        "Atual001.p - Ex Titulos"  space(2)
        string(time,"hh:mm:ss")
         skip.
output close.

cont = 0.
for each titulo where titulo.exportado = no  no-lock.

    output to value(vlog) append.
        put today format "99/99/9999" space(1)
            " Export Titulo Loja --> Matriz ." 
            space(1)
            titulo.titnum
            space(1)
            titulo.titpar
            space(1)
            titulo.clifor 
            skip.
    output close.        
    cont = cont + 1.
    create tt-titulo.
    ASSIGN
        tt-titulo.empcod    = titulo.empcod
        tt-titulo.modcod    = titulo.modcod
        tt-titulo.CliFor    = titulo.CliFor
        tt-titulo.titnum    = titulo.titnum
        tt-titulo.titpar    = titulo.titpar
        tt-titulo.titnat    = titulo.titnat
        tt-titulo.etbcod    = titulo.etbcod
        tt-titulo.titdtemi  = titulo.titdtemi
        tt-titulo.titdtven  = titulo.titdtven
        tt-titulo.titvlcob  = titulo.titvlcob
        tt-titulo.titdtdes  = titulo.titdtdes
        tt-titulo.titvldes  = titulo.titvldes
        tt-titulo.titvljur  = titulo.titvljur
        tt-titulo.cobcod    = titulo.cobcod
        tt-titulo.bancod    = titulo.bancod
        tt-titulo.agecod    = titulo.agecod
        tt-titulo.titdtpag  = titulo.titdtpag
        tt-titulo.titdesc   = titulo.titdesc
        tt-titulo.titjuro   = titulo.titjuro
        tt-titulo.titvlpag  = titulo.titvlpag.

    ASSIGN
        tt-titulo.titbanpag = titulo.titbanpag
        tt-titulo.titagepag = titulo.titagepag
        tt-titulo.titchepag = titulo.titchepag
        tt-titulo.titobs[1] = titulo.titobs[1]
        tt-titulo.titobs[2] = titulo.titobs[2]
        tt-titulo.titsit    = titulo.titsit
        tt-titulo.titnumger = titulo.titnumger
        tt-titulo.titparger = titulo.titparger
        tt-titulo.cxacod    = titulo.cxacod
        tt-titulo.evecod    = titulo.evecod
        tt-titulo.cxmdata   = titulo.cxmdata
        tt-titulo.cxmhora   = titulo.cxmhora
        tt-titulo.vencod    = titulo.vencod
        tt-titulo.etbCobra  = titulo.etbCobra
        tt-titulo.datexp    = titulo.datexp
        tt-titulo.moecod    = titulo.moecod
        tt-titulo.exportado = titulo.exportado.

    lg-atufin = yes.
end.
output to value(vlog1) append.
    put "Atual001.p - Titulos " cont
        skip 
        "Atual001.p - Ex Clientes"  space(2)
        string(time,"hh:mm:ss")
         skip.
output close.
cont = 0.
for each clien where clien.exportado = no no-lock:

    output to value(vlog) append.
        put today format "99/99/9999" space(1)
            " Export Cliente Loja --> Matriz ." 
            space(1)
            clien.clicod
            space(1)
            clien.clinom
            skip.
    output close.        
    cont = cont + 1.
    create tt-clien.
    ASSIGN
        tt-clien.clicod         = clien.clicod
        tt-clien.clinom         = clien.clinom
        tt-clien.tippes         = clien.tippes
        tt-clien.sexo           = clien.sexo
        tt-clien.estciv         = clien.estciv
        tt-clien.nacion         = clien.nacion
        tt-clien.natur          = clien.natur
        tt-clien.dtnasc         = clien.dtnasc
        tt-clien.ciinsc         = clien.ciinsc
        tt-clien.ciccgc         = clien.ciccgc
        tt-clien.pai            = clien.pai
        tt-clien.mae            = clien.mae
        tt-clien.endereco[1]    = clien.endereco[1]
        tt-clien.endereco[2]    = clien.endereco[2]
        tt-clien.endereco[3]    = clien.endereco[3]
        tt-clien.endereco[4]    = clien.endereco[4]
        tt-clien.numero[1]      = clien.numero[1]
        tt-clien.numero[2]      = clien.numero[2]
        tt-clien.numero[3]      = clien.numero[3]
        tt-clien.numero[4]      = clien.numero[4].

    ASSIGN
        tt-clien.numdep         = clien.numdep
        tt-clien.compl[1]       = clien.compl[1]
        tt-clien.compl[2]       = clien.compl[2]
        tt-clien.compl[3]       = clien.compl[3]
        tt-clien.compl[4]       = clien.compl[4]
        tt-clien.bairro[1]      = clien.bairro[1]
        tt-clien.bairro[2]      = clien.bairro[2]
        tt-clien.bairro[3]      = clien.bairro[3]
        tt-clien.bairro[4]      = clien.bairro[4]
        tt-clien.cidade[1]      = clien.cidade[1]
        tt-clien.cidade[2]      = clien.cidade[2]
        tt-clien.cidade[3]      = clien.cidade[3]
        tt-clien.cidade[4]      = clien.cidade[4]
        tt-clien.ufecod[1]      = clien.ufecod[1]
        tt-clien.ufecod[2]      = clien.ufecod[2]
        tt-clien.ufecod[3]      = clien.ufecod[3]
        tt-clien.ufecod[4]      = clien.ufecod[4]
        tt-clien.fone           = clien.fone
        tt-clien.tipres         = clien.tipres
        tt-clien.vlalug         = clien.vlalug.

    ASSIGN
        tt-clien.temres         = clien.temres
        tt-clien.proemp[1]      = clien.proemp[1]
        tt-clien.proemp[2]      = clien.proemp[2]
        tt-clien.protel[1]      = clien.protel[1]
        tt-clien.protel[2]      = clien.protel[2]
        tt-clien.prodta[1]      = clien.prodta[1]
        tt-clien.prodta[2]      = clien.prodta[2]
        tt-clien.proprof[1]     = clien.proprof[1]
        tt-clien.proprof[2]     = clien.proprof[2]
        tt-clien.prorenda[1]    = clien.prorenda[1]
        tt-clien.prorenda[2]    = clien.prorenda[2]
        tt-clien.conjuge        = clien.conjuge
        tt-clien.nascon         = clien.nascon
        tt-clien.refcom[1]      = clien.refcom[1]
        tt-clien.refcom[2]      = clien.refcom[2]
        tt-clien.refcom[3]      = clien.refcom[3]
        tt-clien.refcom[4]      = clien.refcom[4]
        tt-clien.refcom[5]      = clien.refcom[5]
        tt-clien.refnome        = clien.refnome
        tt-clien.reftel         = clien.reftel.

    ASSIGN
        tt-clien.classe         = clien.classe
        tt-clien.limite         = clien.limite
        tt-clien.medatr         = clien.medatr
        tt-clien.dtcad          = clien.dtcad
        tt-clien.situacao       = clien.situacao
        tt-clien.dtspc[1]       = clien.dtspc[1]
        tt-clien.dtspc[2]       = clien.dtspc[2]
        tt-clien.dtspc[3]       = clien.dtspc[3]
        tt-clien.autoriza[1]    = clien.autoriza[1]
        tt-clien.autoriza[2]    = clien.autoriza[2]
        tt-clien.autoriza[3]    = clien.autoriza[3]
        tt-clien.autoriza[4]    = clien.autoriza[4]
        tt-clien.autoriza[5]    = clien.autoriza[5]
        tt-clien.conjpai        = clien.conjpai
        tt-clien.conjmae        = clien.conjmae
        tt-clien.cep[1]         = clien.cep[1]
        tt-clien.cep[2]         = clien.cep[2]
        tt-clien.cep[3]         = clien.cep[3]
        tt-clien.cep[4]         = clien.cep[4]
        tt-clien.cobbairro[1]   = clien.cobbairro[1].

    ASSIGN
        tt-clien.cobbairro[2]   = clien.cobbairro[2]
        tt-clien.cobbairro[3]   = clien.cobbairro[3]
        tt-clien.cobbairro[4]   = clien.cobbairro[4]
        tt-clien.cobcep[1]      = clien.cobcep[1]
        tt-clien.cobcep[2]      = clien.cobcep[2]
        tt-clien.cobcep[3]      = clien.cobcep[3]
        tt-clien.cobcep[4]      = clien.cobcep[4]
        tt-clien.cobcidade[1]   = clien.cobcidade[1]
        tt-clien.cobcidade[2]   = clien.cobcidade[2]
        tt-clien.cobcidade[3]   = clien.cobcidade[3]
        tt-clien.cobcidade[4]   = clien.cobcidade[4]
        tt-clien.cobcompl[1]    = clien.cobcompl[1]
        tt-clien.cobcompl[2]    = clien.cobcompl[2]
        tt-clien.cobcompl[3]    = clien.cobcompl[3]
        tt-clien.cobcompl[4]    = clien.cobcompl[4]
        tt-clien.cobendereco[1] = clien.cobendereco[1]
        tt-clien.cobendereco[2] = clien.cobendereco[2]
        tt-clien.cobendereco[3] = clien.cobendereco[3]
        tt-clien.cobendereco[4] = clien.cobendereco[4]
        tt-clien.cfobnumero[1]  = clien.cfobnumero[1].

    ASSIGN
        tt-clien.cfobnumero[2]  = clien.cfobnumero[2]
        tt-clien.cfobnumero[3]  = clien.cfobnumero[3]
        tt-clien.cfobnumero[4]  = clien.cfobnumero[4]
        tt-clien.cobrefcom[1]   = clien.cobrefcom[1]
        tt-clien.cobrefcom[2]   = clien.cobrefcom[2]
        tt-clien.cobrefcom[3]   = clien.cobrefcom[3]
        tt-clien.cobrefcom[4]   = clien.cobrefcom[4]
        tt-clien.cobrefcom[5]   = clien.cobrefcom[5]
        tt-clien.cobrefnome     = clien.cobrefnome
        tt-clien.cobufecod[1]   = clien.cobufecod[1]
        tt-clien.cobufecod[2]   = clien.cobufecod[2]
        tt-clien.cobufecod[3]   = clien.cobufecod[3]
        tt-clien.cobufecod[4]   = clien.cobufecod[4]
        tt-clien.refccont[1]    = clien.refccont[1]
        tt-clien.refccont[2]    = clien.refccont[2]
        tt-clien.refccont[3]    = clien.refccont[3]
        tt-clien.refccont[4]    = clien.refccont[4]
        tt-clien.refccont[5]    = clien.refccont[5]
        tt-clien.refctel[1]     = clien.refctel[1]
        tt-clien.refctel[2]     = clien.refctel[2].

    ASSIGN
        tt-clien.refctel[3]     = clien.refctel[3]
        tt-clien.refctel[4]     = clien.refctel[4]
        tt-clien.refctel[5]     = clien.refctel[5]
        tt-clien.refcinfo[1]    = clien.refcinfo[1]
        tt-clien.refcinfo[2]    = clien.refcinfo[2]
        tt-clien.refcinfo[3]    = clien.refcinfo[3]
        tt-clien.refcinfo[4]    = clien.refcinfo[4]
        tt-clien.refcinfo[5]    = clien.refcinfo[5]
        tt-clien.refbcont[1]    = clien.refbcont[1]
        tt-clien.refbcont[2]    = clien.refbcont[2]
        tt-clien.refbcont[3]    = clien.refbcont[3]
        tt-clien.refbcont[4]    = clien.refbcont[4]
        tt-clien.refbcont[5]    = clien.refbcont[5]
        tt-clien.refbinfo[1]    = clien.refbinfo[1]
        tt-clien.refbinfo[2]    = clien.refbinfo[2]
        tt-clien.refbinfo[3]    = clien.refbinfo[3]
        tt-clien.refbinfo[4]    = clien.refbinfo[4]
        tt-clien.refbinfo[5]    = clien.refbinfo[5]
        tt-clien.refban[1]      = clien.refban[1]
        tt-clien.refban[2]      = clien.refban[2].

    ASSIGN
        tt-clien.refban[3]      = clien.refban[3]
        tt-clien.refban[4]      = clien.refban[4]
        tt-clien.refban[5]      = clien.refban[5]
        tt-clien.refbtel[1]     = clien.refbtel[1]
        tt-clien.refbtel[2]     = clien.refbtel[2]
        tt-clien.refbtel[3]     = clien.refbtel[3]
        tt-clien.refbtel[4]     = clien.refbtel[4]
        tt-clien.refbtel[5]     = clien.refbtel[5]
        tt-clien.entbairro[1]   = clien.entbairro[1]
        tt-clien.entbairro[2]   = clien.entbairro[2]
        tt-clien.entbairro[3]   = clien.entbairro[3]
        tt-clien.entbairro[4]   = clien.entbairro[4]
        tt-clien.entcep[1]      = clien.entcep[1]
        tt-clien.entcep[2]      = clien.entcep[2]
        tt-clien.entcep[3]      = clien.entcep[3]
        tt-clien.entcep[4]      = clien.entcep[4]
        tt-clien.entcidade[1]   = clien.entcidade[1]
        tt-clien.entcidade[2]   = clien.entcidade[2]
        tt-clien.entcidade[3]   = clien.entcidade[3]
        tt-clien.entcidade[4]   = clien.entcidade[4].

    ASSIGN
        tt-clien.entcompl[1]    = clien.entcompl[1]
        tt-clien.entcompl[2]    = clien.entcompl[2]
        tt-clien.entcompl[3]    = clien.entcompl[3]
        tt-clien.entcompl[4]    = clien.entcompl[4]
        tt-clien.entendereco[1] = clien.entendereco[1]
        tt-clien.entendereco[2] = clien.entendereco[2]
        tt-clien.entendereco[3] = clien.entendereco[3]
        tt-clien.entendereco[4] = clien.entendereco[4]
        tt-clien.entrefcom[1]   = clien.entrefcom[1]
        tt-clien.entrefcom[2]   = clien.entrefcom[2]
        tt-clien.entrefcom[3]   = clien.entrefcom[3]
        tt-clien.entrefcom[4]   = clien.entrefcom[4]
        tt-clien.entrefcom[5]   = clien.entrefcom[5]
        tt-clien.entrefnome     = clien.entrefnome
        tt-clien.entufecod[1]   = clien.entufecod[1]
        tt-clien.entufecod[2]   = clien.entufecod[2]
        tt-clien.entufecod[3]   = clien.entufecod[3]
        tt-clien.entufecod[4]   = clien.entufecod[4]
        tt-clien.fax            = clien.fax
        tt-clien.contato        = clien.contato.
        
    ASSIGN
        tt-clien.tracod         = clien.tracod
        tt-clien.vencod         = clien.vencod
        tt-clien.entfone        = clien.entfone
        tt-clien.cobfone        = clien.cobfone
        tt-clien.entnumero[1]   = clien.entnumero[1]
        tt-clien.entnumero[2]   = clien.entnumero[2]
        tt-clien.entnumero[3]   = clien.entnumero[3]
        tt-clien.entnumero[4]   = clien.entnumero[4]
        tt-clien.cobnumero[1]   = clien.cobnumero[1]
        tt-clien.cobnumero[2]   = clien.cobnumero[2]
        tt-clien.cobnumero[3]   = clien.cobnumero[3]
        tt-clien.cobnumero[4]   = clien.cobnumero[4]
        tt-clien.ccivil         = clien.ccivil
        tt-clien.zona           = clien.zona
        tt-clien.limcrd         = clien.limcrd
        tt-clien.datexp         = clien.datexp
        tt-clien.flag           = clien.flag
        tt-clien.exportado      = clien.exportado.

    lg-atuger = yes.
end.
output to value(vlog1) append.
    put "Atual001.p - Clientes " cont
        skip 
        "Atual001.p - Ex Contrato"  space(2)
        string(time,"hh:mm:ss")
         skip.
output close.
cont = 0.
for each contrato where contrato.dtinicial >= today - 10 no-lock.
    if contrato.exportado = yes then next.
    create tt-contrato.
    ASSIGN
        tt-contrato.contnum   = contrato.contnum
        tt-contrato.clicod    = contrato.clicod
        tt-contrato.autoriza  = contrato.autoriza
        tt-contrato.dtinicial = contrato.dtinicial
        tt-contrato.etbcod    = contrato.etbcod
        tt-contrato.banco     = contrato.banco
        tt-contrato.vltotal   = contrato.vltotal
        tt-contrato.vlentra   = contrato.vlentra
        tt-contrato.situacao  = contrato.situacao
        tt-contrato.indimp    = contrato.indimp
        tt-contrato.lotcod    = contrato.lotcod
        tt-contrato.crecod    = contrato.crecod
        tt-contrato.vlfrete   = contrato.vlfrete
        tt-contrato.datexp    = contrato.datexp
        tt-contrato.exportado = contrato.exportado.
    cont = cont + 1.
    lg-atufin = yes.
end.
output to value(vlog1) append.
    put "Atual001.p - Contratos " cont
        skip
        "Atual001.p - Ex SalExporta"  space(2)
        string(time,"hh:mm:ss")
         skip.
output close.
cont = 0.
for each salexporta where salexporta.exportado = no no-lock:
    create tt-salexporta.
    ASSIGN
        tt-salexporta.etbcod    = salexporta.etbcod
        tt-salexporta.cxacod    = salexporta.cxacod
        tt-salexporta.SalDt     = salexporta.SalDt
        tt-salexporta.saldo     = salexporta.saldo
        tt-salexporta.dtexp     = salexporta.dtexp
        tt-salexporta.moecod    = salexporta.moecod
        tt-salexporta.modcod    = salexporta.modcod
        tt-salexporta.salqtd    = salexporta.salqtd
        tt-salexporta.salexp    = salexporta.salexp
        tt-salexporta.salimp    = salexporta.salimp
        tt-salexporta.exportado = salexporta.exportado.
    cont = cont + 1.
    lg-atufin = yes.
end.
output to value(vlog1) append.
    put "Atual001.p - Salexporta " cont
        skip
        "Atual001.p - Ex Pedido"  space(2)
        string(time,"hh:mm:ss")
         skip.
output close.
cont = 0.

for each pedid where pedid.exportado = no no-lock:
    create tt-pedid.
    ASSIGN
        tt-pedid.pedtdc    = pedid.pedtdc
        tt-pedid.pednum    = pedid.pednum
        tt-pedid.regcod    = pedid.regcod
        tt-pedid.peddat    = pedid.peddat
        tt-pedid.comcod    = pedid.comcod
        tt-pedid.pedsit    = pedid.pedsit
        tt-pedid.fobcif    = pedid.fobcif
        tt-pedid.nfdes     = pedid.nfdes
        tt-pedid.ipides    = pedid.ipides
        tt-pedid.dupdes    = pedid.dupdes
        tt-pedid.cusefe    = pedid.cusefe
        tt-pedid.condes    = pedid.condes
        tt-pedid.condat    = pedid.condat
        tt-pedid.crecod    = pedid.crecod
        tt-pedid.peddti    = pedid.peddti
        tt-pedid.peddtf    = pedid.peddtf
        tt-pedid.acrfin    = pedid.acrfin
        tt-pedid.sitped    = pedid.sitped
        tt-pedid.vencod    = pedid.vencod
        tt-pedid.frecod    = pedid.frecod.

    ASSIGN
        tt-pedid.modcod    = pedid.modcod
        tt-pedid.etbcod    = pedid.etbcod
        tt-pedid.pedtot    = pedid.pedtot
        tt-pedid.clfcod    = pedid.clfcod
        tt-pedid.pedobs[1] = pedid.pedobs[1]
        tt-pedid.pedobs[2] = pedid.pedobs[2]
        tt-pedid.pedobs[3] = pedid.pedobs[3]
        tt-pedid.pedobs[4] = pedid.pedobs[4]
        tt-pedid.pedobs[5] = pedid.pedobs[5]
        tt-pedid.exportado = pedid.exportado.
    cont = cont + 1.
    lg-atucom = yes.
end.
output to value(vlog1) append.
    put "Atual001.p - Pedidos " cont
        skip
        "Atual001.p - Ex Lin Pedido"  space(2)
        string(time,"hh:mm:ss")
         skip.
output close.
cont = 0.

for each liped where liped.exportado = no  no-lock:
    create tt-liped.
    ASSIGN
        tt-liped.pedtdc    = liped.pedtdc
        tt-liped.pednum    = liped.pednum
        tt-liped.procod    = liped.procod
        tt-liped.lipqtd    = liped.lipqtd
        tt-liped.lippreco  = liped.lippreco
        tt-liped.lipsit    = liped.lipsit
        tt-liped.predtf    = liped.predtf
        tt-liped.predt     = liped.predt
        tt-liped.lipcor    = liped.lipcor
        tt-liped.etbcod    = liped.etbcod
        tt-liped.exportado = liped.exportado.
    cont = cont + 1.
    lg-atucom = yes.
end.
output to value(vlog1) append.
    put "Atual001.p - Lin Pedido " cont
        skip
        "Atual001.p - Ex Funcionario"  space(2)
        string(time,"hh:mm:ss")
         skip.
output close.
cont = 0.
for each func where func.exportado = no  no-lock:
    create tt-func.
    ASSIGN
        tt-func.FunCod    = func.FunCod
        tt-func.FunNom    = func.FunNom
        tt-func.FunApe    = func.FunApe
        tt-func.EtbCod    = func.EtbCod
        tt-func.FunFunc   = func.FunFunc
        tt-func.FunMec    = func~.FunMec
        tt-func.FunSit    = func.FunSit
        tt-func.FunDtCad  = func.FunDtCad
        tt-func.UserCod   = func.UserCod
        tt-func.Senha     = func.Senha
        tt-func.opatual   = func.opatual
        tt-func.exportado = func.exportado.
    cont = cont + 1.
    lg-atuger = yes.
end.             

output to value(vlog1) append.
    put "Atual001.p - Funcionarios " cont 
        skip
        "Atual001.p - Ex Chq       "    space(2)
        string(time,"hh:mm:ss")
         skip.
output close.

cont = 0.
for each chq where chq.exportado = no no-lock :

    output to value(vlog) append.
        put today format "99/99/9999" space(1) 
            " Exportando Chq --> Matriz ." 
            space(1)             
            skip.
    output close. 
    cont = cont + 1.
    create tt-chq.
    ASSIGN tt-chq.banco     = chq.banco 
           tt-chq.agencia   = chq.agencia 
           tt-chq.valor     = chq.valor 
           tt-chq.data      = chq.data 
           tt-chq.controle1 = chq.controle1 
           tt-chq.controle2 = chq.controle2 
           tt-chq.controle3 = chq.controle3 
           tt-chq.comp      = chq.comp 
           tt-chq.exportado = chq.exportado 
           tt-chq.datemi    = chq.datemi 
           tt-chq.conta     = chq.conta 
           tt-chq.numero    = chq.numero.
end.

output to value(vlog1) append.
    put "Atual001.p - Chq       " cont 
        skip
        "Atual001.p - Ex ChqTit     "  space(2)
        string(time,"hh:mm:ss")
         skip.
output close.

cont = 0.
for each chqtit where chqtit.exportado = no no-lock :

    output to value(vlog) append.
        put today format "99/99/9999" space(1) 
            " Exportando ChqTit --> Matriz ." 
            space(1)             
            skip.
    output close. 
    cont = cont + 1.
    create tt-chqtit.
    ASSIGN tt-chqtit.modcod    = chqtit.modcod 
           tt-chqtit.CliFor    = chqtit.CliFor 
           tt-chqtit.titnum    = chqtit.titnum 
           tt-chqtit.titpar    = chqtit.titpar 
           tt-chqtit.titnat    = chqtit.titnat 
           tt-chqtit.etbcod    = chqtit.etbcod 
           tt-chqtit.agencia   = chqtit.agencia 
           tt-chqtit.banco     = chqtit.banco 
           tt-chqtit.exportado = chqtit.exportado 
           tt-chqtit.conta     = chqtit.conta 
           tt-chqtit.numero    = chqtit.numero.
end. 

output to value(vlog1) append.
    put "Atual001.p - ChqTit    " cont 
        skip
        "Atual001.p - Finalizando Exp"  space(2)
        string(time,"hh:mm:ss")
         skip.
output close.

output to value(vlog) append.
    put "Aguarde, conectando os Bancos"  skip.
output close.

lg-atufin = yes.

if connected ("finmatriz") 
then disconnect finmatriz.

if lg-atufin
then do:
    if search("/usr/admcom/ultfin.ini") <> ? 
    then do :
        input from /usr/admcom/ultfin.ini.
        repeat :
            import vult.
            leave.
        end.
        input close.
    end.
    else do :
        output to /usr/admcom/ultfin.ini.
            put time skip.
            vult = time.
        output close.
    end.    

    if true /*(vult + vfin) < time*/
    then do :
        i = 0.
        repeat:
            output to value(vlog) append.
            put "Conectando Banco FIN ......" skip.
            output close.
            output to value(vlog1) append.
                put "Atual001.p - Conectando Banco FIN .... "  space(2)
                    string(time,"hh:mm:ss") 
                skip.
            output close.
            connect fin -H erp.lebes.com.br -S sdrebfin -N tcp -ld finmatriz.
        
            if not connected ("finmatriz")
            then do:
                if i = 5
                then leave.
                i = i + 1.
                next.
            end.
            else leave.
        end.
        
        output to value(vlog1) append.
            put "Atual001.p - Rodando Atufin .... "  space(2)
                string(time,"hh:mm:ss") 
                skip.
        output close.
        
        run atufin.p.
        
        output to /usr/admcom/ultfin.ini.
            put time skip.
        output close.

        disconnect finmatriz.
    end.
end.

if connected ("commatriz") 
then disconnect commatriz.

lg-atucom = yes.
if lg-atucom
then do:
    if search("/usr/admcom/ultcom.ini") <> ? 
    then do :
        input from /usr/admcom/ultcom.ini.
        repeat :
            import vult.
            leave.
        end.
        input close.
    end.
    else do :
        output to /usr/admcom/ultcom.ini.
            put time skip.
            vult = time.
        output close.
    end.    

    if true /*(vult + vcom) < time*/
    then do :
        i = 0.                      
        repeat:
            output to value(vlog) append.
                put "Conectando Banco COM......" skip.
            output close.
            output to value(vlog1) append.
                put "Atual001.p - Conectando Banco COM .... "  space(2)
                    string(time,"hh:mm:ss") 
                skip.
            output close.
        
            connect com -H erp.lebes.com.br -S sdrebcom -N tcp -ld commatriz.
            if not connected ("commatriz")
            then do:
                if i = 5
                then leave.
                i = i + 1.
                next.
            end.
            else leave.
        end.
        output to value(vlog1) append.
            put "Atual001.p - Rodando Atucom .... "  space(2)
                 string(time,"hh:mm:ss") 
            skip.
        output close.

        run atucom.p.
        
        output to /usr/admcom/ultcom.ini.
            put time skip.
        output close.

        disconnect commatriz.
    end.        
end.

lg-atuger = yes.

if connected ("germatriz")
then disconnect germatriz.

if lg-atuger
then do:
    if search("/usr/admcom/ultger.ini") <> ? 
    then do :
        input from /usr/admcom/ultger.ini.
        repeat :
            import vult.
            leave.
        end.
        input close.
    end.
    else do :
        output to /usr/admcom/ultger.ini.
            put time skip.
        output close.
    end.  

    if true /*(vult + vger) < time*/
    then do :
        i = 0.
        repeat:
            output to value(vlog) append.
                put "Conectando Banco GER ......" skip.
            output close.
            output to value(vlog1) append.
                put "Atual001.p - Conectando Banco GER .... "  space(2)
                    string(time,"hh:mm:ss") 
                skip.
            output close.

            connect ger -H erp.lebes.com.br -S sdrebger -N tcp -ld germatriz.
            if not connected ("germatriz")
            then do:
                 if i = 5
                 then leave.
                 i = i + 1.
                 next.
            end.
            else leave.
        end.
        output to value(vlog1) append.
            put "Atual001.p - Rodando Atuger .... "  space(2)
                string(time,"hh:mm:ss") 
            skip.
        output close.

        run atuger.p. 
        output to /usr/admcom/ultger.ini.
            put time skip.
        output close.

        disconnect germatriz. 
    end.
end.
output to value(vlog1) append.
    put "Atual001.p - Processo Encerrado .... "  space(2)
        string(time,"hh:mm:ss") 
    skip(3).
output close.

output to value(vlog) append.
    put "PROCESSO ENCERRADO" skip.
output close.
    
