def var sresp as log format "Sim/Nao".
message "Exportar?" update sresp.
if not sresp then return.

def temp-table tt-cli no-undo
    field clicod like clien.clicod
    index clicod is unique primary clicod asc.

if search("/admcom/tmp/atuHML/clientes.txt") = ?
then do:
    message "Arquivo /admcom/tmp/atuHML/clientes.txt nao existe".
    return.
end.

input from /admcom/tmp/atuHML/clientes.txt.
repeat transaction on error undo, next.
    create tt-cli.
    import tt-cli.
end.
input close.
    
    
for each tt-cli.
    if tt-cli.clicod = 0
    then do:
        delete tt-cli.
        next.
    end.        
    disp tt-cli.
    find clien where clien.clicod = tt-cli.clicod no-lock no-error.
    if avail clien
    then disp clien.ciccgc clien.clinom.
    else do:
        disp "NAO EXISTE" @ clien.clinom.
        delete tt-cli.
    end.
end.    



output to /admcom/tmp/atuHML/clien.d.
for each tt-cli,
    each clien where clien.clicod = tt-cli.clicod
    no-lock. 
    export 
  clien.clicod
  clien.clinom
  clien.tippes
  clien.sexo
  clien.estciv
  clien.nacion
  clien.natur
  clien.dtnasc
  clien.ciinsc
  clien.ciccgc
  clien.pai
  clien.mae
  clien.endereco[1]
  clien.endereco[2]
  clien.endereco[3]
  clien.endereco[4]
  clien.numero[1]
  clien.numero[2]
  clien.numero[3]
  clien.numero[4]
  clien.numdep
  clien.compl[1]
  clien.compl[2]
  clien.compl[3]
  clien.compl[4]
  clien.bairro[1]
  clien.bairro[2]
  clien.bairro[3]
  clien.bairro[4]
  clien.cidade[1]
  clien.cidade[2]
  clien.cidade[3]
  clien.cidade[4]
  clien.ufecod[1]
  clien.ufecod[2]
  clien.ufecod[3]
  clien.ufecod[4]
  clien.fone
  clien.tipres
  clien.vlalug
  clien.temres
  clien.proemp[1]
  clien.proemp[2]
  clien.protel[1]
  clien.protel[2]
  clien.prodta[1]
  clien.prodta[2]
  clien.proprof[1]
  clien.proprof[2]
  clien.prorenda[1]
  clien.prorenda[2]
  clien.conjuge
  clien.nascon
  clien.refcom[1]
  clien.refcom[2]
  clien.refcom[3]
  clien.refcom[4]
  clien.refcom[5]
  clien.refnome
  clien.reftel
  clien.classe
  clien.limite
  clien.medatr
  clien.dtcad
  clien.situacao
  clien.dtspc[1]
  clien.dtspc[2]
  clien.dtspc[3]
  clien.autoriza[1]
  clien.autoriza[2]
  clien.autoriza[3]
  clien.autoriza[4]
  clien.autoriza[5]
  clien.conjpai
  clien.conjmae
  clien.cep[1]
  clien.cep[2]
  clien.cep[3]
  clien.cep[4]
  clien.cobbairro[1]
  clien.cobbairro[2]
  clien.cobbairro[3]
  clien.cobbairro[4]
  clien.cobcep[1]
  clien.cobcep[2]
  clien.cobcep[3]
  clien.cobcep[4]
  clien.cobcidade[1]
  clien.cobcidade[2]
  clien.cobcidade[3]
  clien.cobcidade[4]
  clien.cobcompl[1]
  clien.cobcompl[2]
  clien.cobcompl[3]
  clien.cobcompl[4]
  clien.cobendereco[1]
  clien.cobendereco[2]
  clien.cobendereco[3]
  clien.cobendereco[4]
  clien.cfobnumero[1]
  clien.cfobnumero[2]
  clien.cfobnumero[3]
  clien.cfobnumero[4]
  clien.cobrefcom[1]
  clien.cobrefcom[2]
  clien.cobrefcom[3]
  clien.cobrefcom[4]
  clien.cobrefcom[5]
  clien.cobrefnome
  clien.cobufecod[1]
  clien.cobufecod[2]
  clien.cobufecod[3]
  clien.cobufecod[4]
  clien.refccont[1]
  clien.refccont[2]
  clien.refccont[3]
  clien.refccont[4]
  clien.refccont[5]
  clien.refctel[1]
  clien.refctel[2]
  clien.refctel[3]
  clien.refctel[4]
  clien.refctel[5]
  clien.refcinfo[1]
  clien.refcinfo[2]
  clien.refcinfo[3]
  clien.refcinfo[4]
  clien.refcinfo[5]
  clien.refbcont[1]
  clien.refbcont[2]
  clien.refbcont[3]
  clien.refbcont[4]
  clien.refbcont[5]
  clien.refbinfo[1]
  clien.refbinfo[2]
  clien.refbinfo[3]
  clien.refbinfo[4]
  clien.refbinfo[5]
  clien.refban[1]
  clien.refban[2]
  clien.refban[3]
  clien.refban[4]
  clien.refban[5]
  clien.refbtel[1]
  clien.refbtel[2]
  clien.refbtel[3]
  clien.refbtel[4]
  clien.refbtel[5]
  clien.entbairro[1]
  clien.entbairro[2]
  clien.entbairro[3]
  clien.entbairro[4]
  clien.entcep[1]
  clien.entcep[2]
  clien.entcep[3]
  clien.entcep[4]
  clien.entcidade[1]
  clien.entcidade[2]
  clien.entcidade[3]
  clien.entcidade[4]
  clien.entcompl[1]
  clien.entcompl[2]
  clien.entcompl[3]
  clien.entcompl[4]
  clien.entendereco[1]
  clien.entendereco[2]
  clien.entendereco[3]
  clien.entendereco[4]
  clien.entrefcom[1]
  clien.entrefcom[2]
  clien.entrefcom[3]
  clien.entrefcom[4]
  clien.entrefcom[5]
  clien.entrefnome
  clien.entufecod[1]
  clien.entufecod[2]
  clien.entufecod[3]
  clien.entufecod[4]
  clien.fax
  clien.contato
  clien.tracod
  clien.vencod
  clien.entfone
  clien.cobfone
  clien.entnumero[1]
  clien.entnumero[2]
  clien.entnumero[3]
  clien.entnumero[4]
  clien.cobnumero[1]
  clien.cobnumero[2]
  clien.cobnumero[3]
  clien.cobnumero[4]
  clien.ccivil
  clien.zona
  clien.limcrd
  clien.datexp
  clien.etbcad
  clien.tipocod.

end.    
output close.

output to /admcom/tmp/atuHML/cpclien.d.
for each tt-cli,
    each cpclien where cpclien.clicod = tt-cli.clicod
    no-lock. 
    export 
  cpclien.clicod
  cpclien.clinom
  cpclien.cidcod
  cpclien.baicod
  cpclien.ruacod
  cpclien.tememail
  cpclien.emailpromocional
  cpclien.correspondencia
  cpclien.correspondenciapromocao
  cpclien.correspondenciacobranca
  cpclien.val-log[1]
  cpclien.val-log[2]
  cpclien.val-log[3]
  cpclien.val-log[4]
  cpclien.val-log[5]
  cpclien.val-log[6]
  cpclien.val-log[7]
  cpclien.val-log[8]
  cpclien.val-log[9]
  cpclien.val-log[10]
  cpclien.val-log[11]
  cpclien.val-log[12]
  cpclien.val-log[13]
  cpclien.val-log[14]
  cpclien.val-log[15]
  cpclien.val-log[16]
  cpclien.val-log[17]
  cpclien.val-log[18]
  cpclien.val-log[19]
  cpclien.val-log[20]
  cpclien.var-log1
  cpclien.var-log2
  cpclien.var-log3
  cpclien.var-log4
  cpclien.var-log5
  cpclien.var-log6
  cpclien.var-log7
  cpclien.var-log8
  cpclien.var-log9
  cpclien.var-log10
  cpclien.var-log11
  cpclien.var-log12
  cpclien.var-log13
  cpclien.var-log14
  cpclien.var-log15
  cpclien.var-log16
  cpclien.var-log17
  cpclien.var-log18
  cpclien.var-log19
  cpclien.var-log20
  cpclien.var-char
  cpclien.var-char1
  cpclien.var-char2
  cpclien.var-char3
  cpclien.var-char4
  cpclien.var-char5
  cpclien.var-char6
  cpclien.var-char7
  cpclien.var-char8
  cpclien.var-char9
  cpclien.var-char10
  cpclien.var-char11
  cpclien.var-char12
  cpclien.var-char13
  cpclien.var-char14
  cpclien.var-char15
  cpclien.var-char16
  cpclien.var-char17
  cpclien.var-char18
  cpclien.var-char19
  cpclien.var-char20
  cpclien.var-dec[1]
  cpclien.var-dec[2]
  cpclien.var-dec[3]
  cpclien.var-dec[4]
  cpclien.var-dec[5]
  cpclien.var-dec[6]
  cpclien.var-dec[7]
  cpclien.var-dec[8]
  cpclien.var-dec[9]
  cpclien.var-dec[10]
  cpclien.var-dec[11]
  cpclien.var-dec[12]
  cpclien.var-dec[13]
  cpclien.var-dec[14]
  cpclien.var-dec[15]
  cpclien.var-dec[16]
  cpclien.var-dec[17]
  cpclien.var-dec[18]
  cpclien.var-dec[19]
  cpclien.var-dec[20]
  cpclien.var-dec1
  cpclien.var-dec2
  cpclien.var-dec3
  cpclien.var-dec4
  cpclien.var-dec5
  cpclien.var-dec6
  cpclien.var-dec7
  cpclien.var-dec8
  cpclien.var-dec9
  cpclien.var-dec10
  cpclien.var-dec11
  cpclien.var-dec12
  cpclien.var-dec13
  cpclien.var-dec14
  cpclien.var-dec15
  cpclien.var-dec16
  cpclien.var-dec17
  cpclien.var-dec18
  cpclien.var-dec19
  cpclien.var-dec20
  cpclien.var-int[1]
  cpclien.var-int[2]
  cpclien.var-int[3]
  cpclien.var-int[4]
  cpclien.var-int[5]
  cpclien.var-int[6]
  cpclien.var-int[7]
  cpclien.var-int[8]
  cpclien.var-int[9]
  cpclien.var-int[10]
  cpclien.var-int[11]
  cpclien.var-int[12]
  cpclien.var-int[13]
  cpclien.var-int[14]
  cpclien.var-int[15]
  cpclien.var-int[16]
  cpclien.var-int[17]
  cpclien.var-int[18]
  cpclien.var-int[19]
  cpclien.var-int[20]
  cpclien.var-int1
  cpclien.var-int2
  cpclien.var-int3
  cpclien.var-int4
  cpclien.var-int5
  cpclien.var-int6
  cpclien.var-int7
  cpclien.var-int8
  cpclien.var-int9
  cpclien.var-int10
  cpclien.var-int11
  cpclien.var-int12
  cpclien.var-int13
  cpclien.var-int14
  cpclien.var-int15
  cpclien.var-int16
  cpclien.var-int17
  cpclien.var-int18
  cpclien.var-int19
  cpclien.var-int20
  cpclien.var-ext1[1]
  cpclien.var-ext1[2]
  cpclien.var-ext1[3]
  cpclien.var-ext1[4]
  cpclien.var-ext1[5]
  cpclien.var-ext2[1]
  cpclien.var-ext2[2]
  cpclien.var-ext2[3]
  cpclien.var-ext2[4]
  cpclien.var-ext2[5]
  cpclien.var-ext3[1]
  cpclien.var-ext3[2]
  cpclien.var-ext3[3]
  cpclien.var-ext3[4]
  cpclien.var-ext3[5]
  cpclien.var-ext4[1]
  cpclien.var-ext4[2]
  cpclien.var-ext4[3]
  cpclien.var-ext4[4]
  cpclien.var-ext4[5]
  cpclien.var-ext5[1]
  cpclien.var-ext5[2]
  cpclien.var-ext5[3]
  cpclien.var-ext5[4]
  cpclien.var-ext5[5]
  cpclien.var-ext6[1]
  cpclien.var-ext6[2]
  cpclien.var-ext6[3]
  cpclien.var-ext6[4]
  cpclien.var-ext6[5]
  cpclien.var-ext7[1]
  cpclien.var-ext7[2]
  cpclien.var-ext7[3]
  cpclien.var-ext7[4]
  cpclien.var-ext7[5]
  cpclien.var-ext8[1]
  cpclien.var-ext8[2]
  cpclien.var-ext8[3]
  cpclien.var-ext8[4]
  cpclien.var-ext8[5]
  cpclien.var-ext9[1]
  cpclien.var-ext9[2]
  cpclien.var-ext9[3]
  cpclien.var-ext9[4]
  cpclien.var-ext9[5]
  cpclien.exportado
  cpclien.datexp
  cpclien.datalt
  cpclien.horalt.
    
end.    
output close.


output to /admcom/tmp/atuHML/clispc.d.
for each tt-cli,
    each clispc where clispc.clicod = tt-cli.clicod
    no-lock. 
    export 
  clispc.clicod
  clispc.datexp
  clispc.dtneg
  clispc.dtcanc
  clispc.spcpro
  clispc.contnum.
    
end.    
output close.

output to /admcom/tmp/atuHML/contrato.d.
for each tt-cli,
    each contrato where contrato.clicod = tt-cli.clicod
    no-lock. 
    export 
  contrato.contnum
  contrato.clicod
  contrato.autoriza
  contrato.dtinicial
  contrato.etbcod
  contrato.banco
  contrato.vltotal
  contrato.vlentra
  contrato.situacao
  contrato.indimp
  contrato.lotcod
  contrato.crecod
  contrato.vlfrete
  contrato.datexp
  contrato.vltaxa
  contrato.modcod
  contrato.vlseguro
  contrato.DtEfetiva
  contrato.VlIof
  contrato.Cet
  contrato.TxJuros.
    
end.    
output close.

output to /admcom/tmp/atuHML/titulo.d.
for each tt-cli,
    each titulo where titulo.clifor = tt-cli.clicod
    no-lock. 
    export 
  titulo.empcod
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
  titulo.moecod
  titulo.exportado
  titulo.tpcontrato.
    
end.    
output close.

output to /admcom/tmp/atuHML/posicli.d.
for each tt-cli,
    each posicli where posicli.clicod = tt-cli.clicod
    no-lock. 
    export 
  posicli.clicod
  posicli.qtdparpg
  posicli.qtdparab
  posicli.qtdconab
  posicli.qtdconpg
  posicli.totalpg
  posicli.totalab
  posicli.dataref
  posicli.dtainclu
  posicli.cd1
  posicli.cd2
  posicli.cd3
  posicli.cd4
  posicli.cd5
  posicli.ci1
  posicli.ci2
  posicli.ci3
  posicli.ch1
  posicli.ch2
  posicli.ch3.

end.    
output close.











