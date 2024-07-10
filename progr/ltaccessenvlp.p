/* Programa que exporta os titulos LP para o arquivo de remessa */

def input param par-lotcre as recid.

def shared temp-table tt-cliente           
    field registro          as int  
    field tipooper          as char
    field codigo            as int
    field nome              as char
    field cgccpf            as char
    field datanascim        as date
    field dddresidenc       as int
    field foneresidenc      as int
    field dddcelular        as int
    field fonecelular       as int
    field tipologresid      as char
    field enderecoresid     as char
    field complresid        as char
    field numeroresid       as char
    field numeroaptoresid   as char
    field referenciaend     as char
    field cepresid          as int
    field bairroresid       as char
    field cidaderesid       as char
    field ufresid           as char
    field empresa           as char
    field tipologrtrab      as char
    field enderecotrab      as char
    field compltrab         as char
    field numerotrab        as char
    field ceptrab           as int
    field bairrotrab        as char
    field cidadetrab        as char
    field uftrab            as char
    field dddtrab           as int
    field fonetrab          as int
    field cargo             as char
    field profissao         as char
    field nomepai           as char
    field nomemae           as char
    field nomeref1          as char
    field foneref1          as int
    field nomeref2          as char
    field foneref2          as int
    field codconjuge        as int
    field nomeconjuge       as char
    field cpfconjuge        as int
    field empresaconjuge    as char
    field tipologrconjuge   as char
    field enderecoconjuge   as char
    field complconjuge      as char
    field numeroconjuge     as char
    field cepconjuge        as int
    field bairroconjuge     as char
    field cidadeconjuge     as char
    field ufconjuge         as char
    field dddtrabconjuge    as int
    field fonetrabconjuge   as int
    field cargoconjuge      as char
    field profissaoconjuge  as char
    field codigoavalista    as int
    field nomeavalista      as char
    field cpfavalista       as int
    field tipologravalista  as char
    field enderresavalista  as char
    field complendavalista  as char
    field numeroresavalista as char
    field refenderavalista  as char
    field cepresavalista    as int
    field dddresavalista    as int
    field foneresavalisra   as int
    field bairroresavalista as char
    field cidaderesavalista as char
    field ufresavalista     as char
    field emprtrabavalista  as char
    field tipologrtrabavalista as char
    field endertrabavalista  as char
    field compltrabavalista  as char
    field numerotrabavalista as char
    field ceptrabavalista    as int
    field bairrotrabavalista as char
    field cidadetrabavalista as char
    field uftrabavalista     as char
    field dddtrabavalista    as int
    field fonetrabavalista   as int.
    
def shared temp-table tt-contrato
    field registro           as int format 9 initial 3
    field tipooper           as char
    field etbcod             like estab.etbcod
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
    field numultparcpaga     as char
    field saldocontrato      as int
    field vlrentcontrreneg   as int.
    
def shared temp-table tt-parcela    
    field registro           as int format 9 initial 4
    field tipooper           as char
    field numerotitulo       as char
    field numeroparcela      as char
    field vctoparcela        as date
    field valorparcela       as dec.

def shared temp-table tt-acordo
    field registro           as int format 9 initial 5
    field tipooper           as char
    field numerotitulo       as char
    field dataacordo         as int
    field descriacordo       as char
    field dataagendamento    as int.


def shared temp-table tt-produto
    field registro           as int format 9 initial 5
    field tipooper           as char
    field numerotitulo       as char
    field descrproduto       as char
    field qtdcomprada        as int
    field procod             as int.
    


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
                                no-lock
                   break by lotcretit.spcetbcod /***titulo.etbcod***/
                         by titulo.clifor.

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



