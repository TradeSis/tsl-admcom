/* Programa de envio Assessoria Global */
{admcab.i}

def input parameter par-reclotcre  as recid.

    
def new shared temp-table tt-titulo like titulo.
    
def temp-table tt-remessa
    field cnpjemp           as dec
    field nomeemp           as char
    field cnpjdev           as dec
    field nomedev           as char
    field enderecodev       as char
    field bairrodev         as char
    field cidadedev         as char
    field estadodev         as char
    field cepdev            as int
    field ddddev            as char
    field telefonedev       as char
    field especietit        as char
    field titulocod         as char
    field titulopar         as char
    field titulodtemis      as date
    field titulodtvenc      as date
    field titulovalor       as dec
    field titulovalorprot   as dec
    field tituloobs         as char
    field nomerepres        as char
    field fonerepres        as char.

def var vetbcod     like estab.etbcod.
def var varquivo    as char.
def var varqexp     as char.
def var vdti        like plani.pladat.
def var vdtf        like plani.pladat.
def var vvlrtitulo  as dec.
def var vcnpjemp    as char.
def var vendereco   as char.
def var vcep        as char.
def var vcpfdev     as char.

def var vct      as int.
def var vseqarq  as int.
def var vcgc     as dec  init 96662168000131.
def var vlotenro as int.
def var vlotereg as int.
def var vlotevlr as dec.
def var vtotreg  as int.
def var varq     as char.
def var vvalor   as char.
def var vlivre   as char.
def var vtime    as char.


for each tt-remessa:
    delete tt-remessa.
end.

def var vreftel as char.
def var vprotel as char.        
def var vfone   as char.
def buffer bclien for clien.
def buffer bcontrato for contrato.
def buffer btitulo for titulo.
def var vqtdparcelas as int.

find lotcre where recid(lotcre) = par-reclotcre no-lock.
find lotcretp of lotcre no-lock.

vseqarq = lotcretp.ultimo + 1.
if opsys = "unix"
then 
varq = "/admcom/custom/nede/arquivos/" + "gl" + 
substring(string(lotcre.ltcrecod),4,6) + ".txt".
else 
varq = "l:~\global~\titulos~\dreb" + "gl" + 
substring(string(lotcre.ltcrecod),4,6) + ".txt".

disp
    varq    label "Arquivo"   colon 15 format "x(50)"
    vseqarq label "Sequencia" colon 15
    with side-label title "Remessa - " + lotcretp.ltcretnom.


/* TITULOS LP */
if connected ("d") then disconnect d.
run conecta_d.p.
if connected ("d")
then do:
    run ltglobalenvlp.p (input recid(lotcre)).
    disconnect d.
end.                     
hide message no-pause.



/* TITULOS BANCO FIN */
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
    
    create tt-titulo.
    buffer-copy titulo to tt-titulo.
end.
    
    
for each tt-titulo:
    
    find clien where clien.clicod = tt-titulo.clifor no-lock.
    
    find estab where tt-titulo.etbcod = estab.etbcod  no-lock.    
    find contrato where int(tt-titulo.titnum) = contrato.contnum 
    no-lock no-error.
    
    find contnf where contnf.etbcod = contrato.etbcod and
                      contnf.contnum = contrato.contnum no-lock no-error.
    find plani where plani.etbcod = contnf.etbcod
                     and plani.placod = contnf.placod no-lock no-error. 
    
    find func where func.funcod = plani.vencod 
                    and func.etbcod = plani.etbcod no-lock no-error.
    vcnpjemp = replace(replace(replace(estab.etbcgc,".",""),"/",""),"-","").

    vendereco = if clien.endereco[1] = ? then "" else clien.endereco[1] + " " +
                string(clien.numero[1]) + "/" + 
                if clien.compl[1] = ? then " " else clien.compl[1].
    vcep = if clien.cep[1] = ? then "0" else clien.cep[1].
    run retira-letras (input vcep, output vcep).
    
    vcpfdev = replace(replace(replace(clien.ciccgc,".",""),"/",""),"-","").
    
    
    create tt-remessa.
    assign 
        tt-remessa.cnpjemp           = dec(vcnpjemp)
        tt-remessa.nomeemp           = estab.etbnom
        tt-remessa.cnpjdev           = dec(vcpfdev)
        tt-remessa.nomedev           = clien.clinom
        tt-remessa.enderecodev       = vendereco
        tt-remessa.bairrodev         = if clien.bairro[1] = ? then "" else 
                                       clien.bairro[1]
        tt-remessa.cidadedev         = clien.cidade[1]
        tt-remessa.estadodev         = clien.ufecod[1]
        tt-remessa.cepdev            = int(substring(vcep,1,8))
        tt-remessa.ddddev            = if clien.fone = ? or clien.fone = ""                                            then substring(clien.fax,1,2) 
                                       else substring(clien.fone,1,2)
        tt-remessa.telefonedev       = if clien.fone = ? or clien.fone = "" 
                                       then substring(clien.fax,3,10) 
                                       else  substring(clien.fone,3,10)
        tt-remessa.especietit        = "BL"
        tt-remessa.titulocod         = tt-titulo.titnum
        tt-remessa.titulopar         = string(tt-titulo.titpar)
        tt-remessa.titulodtemis      = tt-titulo.titdtemi
        tt-remessa.titulodtvenc      = tt-titulo.titdtven
        tt-remessa.titulovalor       = tt-titulo.titvlcob
        tt-remessa.titulovalorprot   = 0
        tt-remessa.tituloobs         = ""
        tt-remessa.nomerepres        = func.funnom when avail func
        tt-remessa.fonerepres        = estab.etbserie.
    
        assign vtotreg  = vtotreg + 1.

end.
run pi-exporta-arquivo. 

procedure pi-exporta-arquivo.
output to value(varq).
    for each tt-remessa no-lock.
        put unformatted
            tt-remessa.cnpjemp           format "99999999999999"
            tt-remessa.nomeemp           format "x(50)"
            tt-remessa.cnpjdev           format "99999999999999"
            tt-remessa.nomedev           format "x(50)"
            tt-remessa.enderecodev       format "x(50)"
            tt-remessa.bairrodev         format "x(20)"
            tt-remessa.cidadedev         format "x(20)"
            tt-remessa.estadodev         format "x(2)"
            tt-remessa.cepdev            format "99999999"
            tt-remessa.ddddev            format "x(3)"
            tt-remessa.telefonedev       format "x(8)"
            tt-remessa.especietit        format "x(2)"
            tt-remessa.titulocod         format "x(12)"
            tt-remessa.titulopar         format "x(2)"
            tt-remessa.titulodtemis      format "99/99/9999"
            tt-remessa.titulodtvenc      format "99/99/9999"
            tt-remessa.titulovalor       format "999999999999.99"
            tt-remessa.titulovalorprot   format "999999999999.99"
            tt-remessa.tituloobs         format "x(255)"
            tt-remessa.nomerepres        format "x(40)"
            tt-remessa.fonerepres        format "x(12)"
        skip.   
    end.
output close.
end procedure.         

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
if opsys = "unix"
then do.                      /*
    unix silent unix2dos value(varq).
    unix silent chmod 777 value(varq). */
end.
message "Registros gerados: " vtotreg " " varq view-as alert-box.

         
procedure retira-letras.
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


