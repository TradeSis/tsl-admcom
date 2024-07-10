/* Programa de envio do arquivo atualizacao cadastral Lebes para Access */
/* Arquivo de envio Lote Access */
{admcab.i}

def input parameter par-reclotcre  as recid.


def temp-table tt-cliente           
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

for each tt-cliente:
    delete tt-cliente.
end.

def var vreftel as char.
def var vprotel as char.        
def var vfone   as char.
def var vcelular as char.
def buffer bclien for clien.
def buffer bcontrato for contrato.
def buffer btitulo for titulo.
def var vqtdparcelas as int.

find lotcre where recid(lotcre) = par-reclotcre no-lock.
find lotcretp of lotcre no-lock.

vseqarq = lotcretp.ultimo + 1.
if opsys = "unix"
then varq = "/admcom/custom/nede/arquivos/" + "2A" + string(vseqarq, "9~99999").
else varq = "l:~\access~\titulos~\dreb" + "2A" + string(vseqarq, "99999~9").

disp
    varq    label "Arquivo"   colon 15 format "x(50)"
    vseqarq label "Sequencia" colon 15
    with side-label title "Remessa - " + lotcretp.ltcretnom.


for each lotcretit of lotcre where lotcretit.ltsituacao = yes
                               and lotcretit.ltvalida   = ""
                             exclusive,
                         titulo where titulo.empcod = wempre.empcod
                                  and titulo.titnat = lotcretp.titnat
                                  and titulo.modcod = lotcretit.modcod
                                  and titulo.etbcod = lotcretit.etbcod
                                  and titulo.clifor = lotcretit.clfcod
                                  and titulo.titnum = lotcretit.titnum
                                  and titulo.titpar = lotcretit.titpar
                                no-lock
                   break by lotcretit.spcetbcod /***titulo.etbcod***/
                         by titulo.clifor.

    find lotcreag of lotcretit no-lock.
    if lotcreag.ltsituacao <> yes /* desmarcado */ or
       lotcreag.ltvalida   <> ""  /* invalido */
    then next.


    find clien where clien.clicod = lotcreag.clfcod no-lock.

    run ajusta-telefone (input clien.fone, output vfone).
    run ajusta-telefone (input clien.reftel, output vreftel).
    run ajusta-telefone (input clien.fax, output vcelular).
    /*run ajusta-telefone (input clien.protel[1], output vprotel).*/
    
    find first tt-cliente where tt-cliente.codigo = clien.clicod
    no-lock no-error.
    
    
    if not avail tt-cliente 
    then do:

        create tt-cliente.
        assign
        tt-cliente.registro             = 2
        tt-cliente.tipooper             = "A"
        tt-cliente.codigo               = clien.clicod
        tt-cliente.nome                 = clien.clinom
        tt-cliente.cgccpf               = clien.ciccgc
        tt-cliente.datanascim           = clien.dtnasc
        tt-cliente.dddresidenc          = int(substring(vfone,1,2)) 
        tt-cliente.foneresidenc         = if clien.fone = ? then 0 else
                                                int(substring(vfone,3,10))     ~         tt-cliente.dddcelular           = int(substring(vcelular,1,2))   
        tt-cliente.fonecelular          = if clien.fax = ? then 0 else
                                                int(substring(vcelular,3,10))          tt-cliente.tipologresid         = ""
        tt-cliente.enderecoresid        = clien.endereco[1]
        tt-cliente.complresid           = if clien.compl[1] = ? then "" else
                                                                clien.compl[1]
        tt-cliente.numeroresid          = string(clien.numero[1])
        tt-cliente.numeroaptoresid      = ""         
        tt-cliente.referenciaend        = ""
        tt-cliente.cepresid             = 0
        tt-cliente.bairroresid          = if clien.bairro[1] = ? then "" 
                                            else clien.bairro[1]
        tt-cliente.cidaderesid          = clien.cidade[1]
        tt-cliente.ufresid              = clien.ufecod[1]
        tt-cliente.empresa              = if clien.proemp[1] = ? then "" else 
                                                                clien.proemp[1]
        tt-cliente.tipologrtrab         = ""
        tt-cliente.enderecotrab         = ""
        tt-cliente.compltrab            = ""
        tt-cliente.numerotrab           = ""
        tt-cliente.ceptrab              = 0
        tt-cliente.bairrotrab           = ""
        tt-cliente.cidadetrab           = ""
        tt-cliente.uftrab               = ""
        tt-cliente.dddtrab              = 0 
        tt-cliente.fonetrab             = if clien.protel[1] = ? then 0 
                                            else int(substring(vprotel,3,10))
        tt-cliente.cargo                = ""
        tt-cliente.profissao            = ""
        tt-cliente.nomepai              = if clien.pai = ? then "" 
                                                           else clien.pai
        tt-cliente.nomemae              = if clien.mae = ? then "" 
                                                           else  clien.mae
        tt-cliente.nomeref1             = if clien.refnome = ? or 
                                          clien.refnome = "" then "TESTE" 
                                          else clien.refnome
        tt-cliente.foneref1             = if clien.reftel = ? then 0 
                                            else int(vreftel)
        tt-cliente.nomeref2             = if clien.refnome = ? or 
                                          clien.refnome = "" then "TESTE" 
                                          else clien.refnome
        tt-cliente.foneref2             = 0
        tt-cliente.codconjuge           = 0
        tt-cliente.nomeconjuge          = if clien.conjuge = ? then "" 
                                            else clien.conjuge
        tt-cliente.cpfconjuge           = 0
        tt-cliente.empresaconjuge       = ""
        tt-cliente.tipologrconjuge      = ""
        tt-cliente.enderecoconjuge      = ""
        tt-cliente.complconjuge         = ""
        tt-cliente.numeroconjuge        = ""
        tt-cliente.cepconjuge           = 0
        tt-cliente.bairroconjuge        = ""
        tt-cliente.cidadeconjuge        = ""
        tt-cliente.ufconjuge            = ""
        tt-cliente.dddtrabconjuge       = 0
        tt-cliente.fonetrabconjuge      = 0
        tt-cliente.cargoconjuge         = ""
        tt-cliente.profissaoconjuge     = ""
        tt-cliente.codigoavalista       = 0
        tt-cliente.nomeavalista         = ""
        tt-cliente.cpfavalista          = 0
        tt-cliente.tipologravalista     = ""
        tt-cliente.enderresavalista     = ""
        tt-cliente.complendavalista     = ""
        tt-cliente.numeroresavalista    = ""
        tt-cliente.refenderavalista     = ""
        tt-cliente.cepresavalista       = 0
        tt-cliente.dddresavalista       = 0
        tt-cliente.foneresavalisra      = 0
        tt-cliente.bairroresavalista    = ""
        tt-cliente.cidaderesavalista    = ""
        tt-cliente.ufresavalista        = ""
        tt-cliente.emprtrabavalista     = ""
        tt-cliente.tipologrtrabavalista = ""
        tt-cliente.endertrabavalista    = ""
        tt-cliente.compltrabavalista    = ""
        tt-cliente.numerotrabavalista   = ""
        tt-cliente.ceptrabavalista      = 0 
        tt-cliente.bairrotrabavalista   = ""
        tt-cliente.cidadetrabavalista   = ""
        tt-cliente.uftrabavalista       = ""
        tt-cliente.dddtrabavalista      = 0
        tt-cliente.fonetrabavalista     = 0 .
    end.
    assign
        vlotereg = vlotereg + 1
        vlotevlr = vlotevlr + titulo.titvlcob
        vtotreg  = vtotreg + 1
        vbancod2 = vbancod.


end.

run pi-exporta-arquivo. 
message "Arquivo " + varqexp + " gerado com sucesso" view-as alert-box.

procedure pi-exporta-arquivo.
output to value(varq).

    for each tt-cliente no-lock.
    
        run pi-registro2.
        
    end.

output close.
end procedure.         
/*
if vlotereg > 0
then do.
    vtotreg = vtotreg + 1.
end.

do on error undo.
    find current lotcretp exclusive.
    lotcretp.ultimo = lotcretp.ultimo + 1.
    
    find lotcre where recid(lotcre) = par-reclotcre exclusive.
    assign
        lotcre.ltdtenvio = today
        lotcre.lthrenvio = time
        lotcre.ltfnenvio = sfuncod
        lotcre.arqenvio  = varq.
end.
find lotcre where recid(lotcre) = par-reclotcre no-lock.
*/
if opsys = "unix"
then do.                      /*
    unix silent unix2dos value(varq).
    unix silent chmod 777 value(varq). */
end.

message "Registros gerados: " vtotreg " " varq view-as alert-box.

         
procedure pi-registro2.

    /* Registro tipo 2 */    
    put unformatted
        tt-cliente.registro             format "9"
        tt-cliente.tipooper             format "x(1)"
        tt-cliente.codigo               format "9999999999"
        tt-cliente.nome                 format "x(50)"
        dec(tt-cliente.cgccpf)          format "999999999999999"
        tt-cliente.datanascim           format "99999999"
        tt-cliente.dddresidenc          format "9999"
        tt-cliente.foneresidenc         format "99999999"
        tt-cliente.dddcelular           format "9999"
        tt-cliente.fonecelular          format "99999999"
        tt-cliente.tipologresid         format "x(2)"
        tt-cliente.enderecoresid        format "x(70)"
        tt-cliente.complresid           format "x(40)"
        tt-cliente.numeroresid          format "x(6)"
        tt-cliente.numeroaptoresid      format "x(4)"
        tt-cliente.referenciaend        format "x(100)"
        tt-cliente.cepresid             format "99999999"
        tt-cliente.bairroresid          format "x(30)"
        tt-cliente.cidaderesid          format "x(30)"
        tt-cliente.ufresid              format "x(2)"
        tt-cliente.empresa              format "x(40)"
        tt-cliente.tipologrtrab         format "x(2)"
        tt-cliente.enderecotrab         format "x(70)"
        tt-cliente.compltrab            format "x(40)"
        tt-cliente.numerotrab           format "x(6)"
        tt-cliente.ceptrab              format "99999999"
        tt-cliente.bairrotrab           format "x(30)"
        tt-cliente.cidadetrab           format "x(30)"
        tt-cliente.uftrab               format "x(2)"
        tt-cliente.dddtrab              format "9999"
        tt-cliente.fonetrab             format "99999999"
        tt-cliente.cargo                format "x(30)"
        tt-cliente.profissao            format "x(30)"
        tt-cliente.nomepai              format "x(50)"
        tt-cliente.nomemae              format "x(50)"
        tt-cliente.nomeref1             format "x(30)"
        tt-cliente.foneref1             format "99999999"
        tt-cliente.nomeref2             format "x(30)"
        tt-cliente.foneref2             format "99999999"
        tt-cliente.codconjuge           format "9999999999"
        tt-cliente.nomeconjuge          format "x(50)"
        dec(tt-cliente.cpfconjuge)      format "999999999999999"
        tt-cliente.empresaconjuge       format "x(40)"
        tt-cliente.tipologrconjuge      format "x(2)"
        tt-cliente.enderecoconjuge      format "x(70)"
        tt-cliente.complconjuge         format "x(40)"
        tt-cliente.numeroconjuge        format "x(6)"
        tt-cliente.cepconjuge           format "99999999"
        tt-cliente.bairroconjuge        format "x(30)"
        tt-cliente.cidadeconjuge        format "x(30)"
        tt-cliente.ufconjuge            format "x(2)"
        tt-cliente.dddtrabconjuge       format "9999"
        tt-cliente.fonetrabconjuge      format "99999999"
        tt-cliente.cargoconjuge         format "x(30)"
        tt-cliente.profissaoconjuge     format "x(30)"
        tt-cliente.codigoavalista       format "9999999999"
        tt-cliente.nomeavalista         format "x(50)"
        dec(tt-cliente.cpfavalista)     format "999999999999999"
        tt-cliente.tipologravalista     format "x(2)"
        tt-cliente.enderresavalista     format "x(70)"
        tt-cliente.complendavalista     format "x(40)"
        tt-cliente.numeroresavalista    format "x(6)"
        tt-cliente.refenderavalista     format "x(100)"
        tt-cliente.cepresavalista       format "99999999"
        tt-cliente.dddresavalista       format "9999"
        tt-cliente.foneresavalisra      format "99999999"
        tt-cliente.bairroresavalista    format "x(30)"
        tt-cliente.cidaderesavalista    format "x(30)"
        tt-cliente.ufresavalista        format "x(2)"
        tt-cliente.emprtrabavalista     format "x(40)"
        tt-cliente.tipologrtrabavalista format "x(2)"
        tt-cliente.endertrabavalista    format "x(70)"
        tt-cliente.compltrabavalista    format "x(40)"
        tt-cliente.numerotrabavalista   format "x(6)"
        tt-cliente.ceptrabavalista      format "9999999"
        tt-cliente.bairrotrabavalista   format "x(30)"
        tt-cliente.cidadetrabavalista   format "x(30)"
        tt-cliente.uftrabavalista       format "x(2)"
        tt-cliente.dddtrabavalista      format "9999"
        tt-cliente.fonetrabavalista     format "99999999" 
    skip.
end procedure.

         
procedure ajusta-telefone.
def input parameter par-char as char.
def output parameter par-resp as char.


    def var v-i as int.
    def var v-lst as char extent 66
       init ["@",":",";",".",",","*","/","-",">","!","'",'"',"[","]",
       "q","Q","w","W","e","E","r","R","t","T","y","Y","u","U","i","I",
       "o","O","p","P","a","A","s","S","D","d","f","F","g","G","h","H",
       "j","J","L","l","Ç","ç","z","Z","x","X","c","C","v","V","b","B",
       "n","N","m","M"].
         
    if par-char = ?
    then par-char = "".
    else do v-i = 1 to 66:
         par-resp = replace(par-char,v-lst[v-i],"").
         par-char = par-resp.
    end.


end procedure.


