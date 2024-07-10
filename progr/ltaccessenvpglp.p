/* Exportacao dos pagamentos titulos lp */

def input param par-lotcre as recid.
    
def new shared temp-table tt-contrato
    field registro           as int 
    field tipooper           as char
    field etbcod             as int
    field codigocliente      as int
    field numerotitulo       as char
    field qtdrenegociacao    as int
    field datacompra         as date
    field valorentrada       as dec
    field constaspc          as char
    field qtdparcelascontr   as int
    field valorcontrato      as dec
    field dataultpagamento   as date
    field lojacompra         as int
    field nomeagente         as char
    field especietitulo      as char
    field numultparcpaga     as int
    field saldocontrato      as int
    field vlrentcontrreneg   as int.
     
def var vetbcod  like estab.etbcod.
def var varquivo as char.
def var varqexp  as char.
def var vdti     like plani.pladat.
def var vdtf     like plani.pladat.
def var vvlrtitulo as dec.
def var vct      as int.
def var vseqarq  as int.
def var vcgc     as dec  init 96662168000131.
def var vcodconv as int  init 5348.
def var vagencia as int  init 878.
def var vconta   as char init "0608896002".
def var vlotenro as int.
def var vlotereg as int.
def var vlotevlr as dec.
def var vtotreg  as int.
def var varq     as char.
def var vbancod  as char.
def var vmoeda   as char.
def var vdac     as char.
def var vfatorv  as char.
def var vvalor   as char.
def var vlivre   as char.
def var vdv123   as char.
def var vbarcode as char.
def var vbancod2 as char.
def var vtime    as char.
def var vreftel as char.
def var vprotel as char.        
def var vfone   as char.
def var vcelular as char.
def buffer bclien for clien.
def var vqtdparcelas as int.

def shared temp-table tt-titulo like fin.titulo.
def shared temp-table tt-contratolp like fin.contrato.

find lotcre where recid(lotcre) = par-lotcre no-lock.


for each lotcretit of lotcre where lotcretit.ltsituacao = yes
                               and lotcretit.ltvalida   = ""
                             exclusive,
                         d.titulo where d.titulo.empcod = 19
                                  and d.titulo.titnat = no
                                  and d.titulo.modcod = lotcretit.modcod
                                  and d.titulo.etbcod = lotcretit.etbcod
                                  and d.titulo.clifor = lotcretit.clfcod
                                  and d.titulo.titnum = lotcretit.titnum
                                  and d.titulo.titpar = lotcretit.titpar
                                no-lock.

    create tt-titulo.
    buffer-copy d.titulo to tt-titulo.

    find d.contrato where int(d.titulo.titnum) = d.contrato.contnum 
    no-lock no-error.

    if avail d.contrato then do:
        find first tt-contratolp where 
        tt-contratolp.contnum = d.contrato.contnum no-lock no-error.
        if not avail tt-contratolp then do:
        create tt-contratolp.
        buffer-copy d.contrato to tt-contratolp.
        end.
    end.
end.





