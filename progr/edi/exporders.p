/*#3 helio.neto 11.09.2019 - enviar setor do primeiro liped no cabecalho */

def var vdiretoriosaida as char init "/EDI_NeogridClient/out/".  /* 03.10.19 */

def input param par-rec       as recid.

def var vdtven as date.
/*#2*/
def var vsetcod     as char.   
def buffer sclase   for clase.
def buffer grupo    for clase.
def buffer setclase for clase.
def buffer depto    for clase.

/*#3*/
def var vdatahora   as char.
def var par-arquivo as char.

def var vproindice as char.
def var vpack as int. /*#4*/

def var vpeddat     like pedid.peddat.
def var vpeddti     like pedid.peddti.
def var vpeddtf     like pedid.peddtf.

def var vinterface as char.
def var vfuncao    as char.
def var voperacao   as char. /* 21.10.2019 */

 
def var vpedtot like pedid.pedtot.
def var vseq as int.

def var vpedtdc like pedid.pedtdc.
def var vetbcod like pedid.etbcod.
def var vpednum like pedid.pednum.

find edipedid where recid(edipedid) = par-rec no-lock.

find estab where estab.etbcod = 900 no-lock.
find pedid where pedid.pedtdc = edipedid.pedtdc and 
                 pedid.etbcod = edipedid.etbcod and 
                 pedid.pednum = edipedid.pednum no-lock.
find forne where forne.forcod = pedid.clfcod no-lock no-error.
find crepl of pedid no-lock no-error.

vpedtot = 0.
for each liped of pedid no-lock.
    vpedtot = vpedtot + (liped.lipqtd * liped.lippreco).
end.    

 
function retira-acento returns character(input texto as character):

    define variable c-retorno as character no-undo.
    define variable c-letra   as character no-undo case-sensitive.
    define variable i-conta         as integer   no-undo.
    def var i-asc as int.
    def var c-caracter as char.

    do i-conta = 1 to length(texto):
        
        c-letra = substring(texto,i-conta,1).
        i-asc = asc(c-letra).
        
        if i-asc <= 160                         
        then do:
            if i-asc = 42 
            then c-caracter = "". 
            else c-caracter = c-letra.
        end.    
        else if i-asc >= 161 and i-asc <= 191  or
                i-asc >= 215 and i-asc <= 216  or
                i-asc >= 222 and i-asc <= 223  or
                i-asc >= 247 and i-asc <= 248       then c-caracter = " ".
        else if i-asc >= 192 and i-asc <= 198       then c-caracter = "A".
        else if i-asc = 199                     then c-caracter = "C".
        else if i-asc >= 200 and i-asc <= 203       then c-caracter = "E".
        else if i-asc >= 204 and i-asc <= 207       then c-caracter = "I".
        else if i-asc =  208                     then c-caracter = "D".
        else if i-asc = 209                     then c-caracter = "N".
        else if i-asc >= 210 and i-asc <= 214       then c-caracter = "O".
        else if i-asc >= 217 and i-asc <= 220       then c-caracter = "U".
        else if i-asc = 221                     then c-caracter = "Y".
        else if i-asc >= 192 and i-asc <= 198       then c-caracter = "A".
        else if i-asc >= 224 and i-asc <= 230       then c-caracter = "a".
        else if i-asc = 231                     then c-caracter = "c".
        else if i-asc >= 223 and i-asc <= 235       then c-caracter = "e".
        else if i-asc >= 236 and i-asc <= 239       then c-caracter = "i".
        else if i-asc = 240                     then c-caracter = "o".
        else if i-asc = 241                     then c-caracter = "n".
        else if i-asc >= 242 and i-asc <= 246       then c-caracter = "o".
        else if i-asc >= 249 and i-asc <= 252       then c-caracter = "u".
        else if i-asc >= 253 and i-asc <= 255       then c-caracter = "y".
        else c-caracter = c-letra.
        c-retorno = c-retorno + c-caracter.

    end.
    if c-retorno = "" then c-retorno = "NULO".
    return c-retorno.
end function.


if edipedid.acao = "INSERT"
then do:
    vinterface = "orders".
    vfuncao    = "9".
    voperacao  = "1".
end.    
else do:
    vinterface = "ordchg".
    vfuncao    = "4".
    voperacao  = "3".
end.    

vpeddat = if pedid.peddat = ? then pedid.peddti else pedid.peddat.
vpeddti = if pedid.peddti = ? then vpeddat else pedid.peddti.
vpeddtf = if pedid.peddtf = ? then vpeddat else pedid.peddtf.
vdtven = pedid.peddtf + (if avail crepl then crepl.credias[1] else 0)  .

if vpeddat = ? or vpeddti = ? or vpeddtf = ?
then return.

/*#3*/
vsetcod = "".
    find first liped of pedid no-lock.
    find produ of liped no-lock.
    find sClase     where sClase.clacod   = produ.clacod    no-lock no-error.
    if avail sClase 
    then do: 
        find Clase      where Clase.clacod    = sClase.clasup   no-lock no-error.
        if avail clase 
        then do:
            find grupo      where grupo.clacod    = Clase.clasup    no-lock no-error.
            if avail grupo 
            then do:
                find setClase   where setClase.clacod = grupo.clasup    no-lock no-error.  
                if avail setclase 
                then do:
                    vsetcod = substring(string(setclase.clacod),1,3).
                    find depto   where depto.clacod = setclase.clasup    no-lock no-error.   
                    if avail depto 
                    then do:
                    end.
                end.
            end.
        end.
    end.                                                                  
/*#3*/


vdatahora = string(today,"999999") + replace(string(time,"HH:MM:SS"),":","").
par-arquivo = vinterface + "_" + string(pedid.pednum,"9999999") + "_" + vdatahora + ".txt".

output to value(vdiretoriosaida + par-arquivo).

put unformatted 
    "01"            format "x(02)"
    vfuncao         format "x(03)"
    if pedid.etbcod = 925 then "002" else "001"     format "x(03)"
    string(pedid.pednum)    format "x(20)"
    ""              format "x(20)"
    string( year(vpeddat) ,"9999")  + 
    string(month(vpeddat),"99") + 
    string(  day(vpeddat)  ,"99") +
    "0000"                               format "x(12)"
    string( year(vpeddti) ,"9999")  + 
    string(month(vpeddti),"99") + 
    string(  day(vpeddti)  ,"99") +
    "0000"                               format "x(12)"
    string( year(vpeddtf) ,"9999")  + 
    string(month(vpeddtf),"99") + 
    string(  day(vpeddtf)  ,"99") +
    "0000"                               format "x(12)"
    ""              format "x(15)"
    ""              format "x(15)"
    fill("0",13)              format "x(13)"
    fill("0",13)              format "x(13)"
    fill("0",13)              format "x(13)"
    fill("0",13)              format "x(13)"
    
    if avail forne then forne.forcgc else fill("0",14)   format "x(14)"
    replace(replace(replace(estab.etbcgc,".",""),"/",""),"-","") format "x(14)"
    replace(replace(replace(estab.etbcgc,".",""),"/",""),"-","") format "x(14)"    
    replace(replace(replace(estab.etbcgc,".",""),"/",""),"-","") format "x(14)"    

    ""              format "x(03)"
    fill("0",14)              format "x(14)"
    ""              format "x(30)"
    string(pedid.fobcif,"FOB/CIF") format "x(03)"
    vsetcod           format "x(03)" /*#3*/
    ""              format "x(40)"
       skip.

put unformatted 
    "02"            format "x(02)"
    "1"           format "x(03)"
    "66"           format "x(03)"
    "1"             format "x(03)"
    "CD"            format "x(03)"
    if avail crepl then crepl.credias[1] else 0            format "999"

    string( year(vdtven) ,"9999")  + 
    string(month(vdtven),"99") + 
    string(  day(vdtven)  ,"99") format "x(08)"
    
    vpedtot * 100   format "999999999999999"
    10000           format "99999"
    skip.
/*
put unformatted 
    "03"            format "x(02)"
    0   format "99999"
    0   format "999999999999999"
    0   format "99999"
    0   format "999999999999999"
    0   format "99999"
    0   format "999999999999999"
    0   format "99999"
    0   format "999999999999999"
    0   format "99999"
    0   format "999999999999999"
    0   format "99999"
    0   format "999999999999999"
        skip    .
*/

vseq = 0.
for each liped of pedid no-lock.
    find produ of liped no-lock.
    vseq = vseq + 1.
    vproindice = string(produ.procod).
    if produ.proindice <> ?  and produ.proindice <> ""
    then do:
        vproindice =  if trim(produ.proindice) begins "SEM GTIN"
                      then vproindice
                      else produ.proindice.
    end.        

    /*#4*/
    find first produaux of produ where produaux.nome_campo = "PACK"
                no-lock no-error.

    vpack = (if avail produaux
             then int(produaux.valor_campo)
             else 0)
                no-error.
    if vpack = ? or vpack = 0 
    then vpack = 1.
    /*#4*/

    put unformatted 
        "04"            format "x(02)"
        vseq   format "9999" 
        vseq   format "99999"  
        voperacao  format "x(03)" 
        "EN"  format "x(03)" 
        vproindice  format "x(14)" 
        retira-acento(produ.pronom)  format "x(40)" 
        produ.prorefter   format "x(20)" 
        "EA"  format "x(03)" 
        vpack   format "99999" 
        liped.lipqtd  * 100 format "999999999999999" 
        0  * 100 format "999999999999999" 
        0  * 100 format "999999999999999" 
        "" format "x(03)" 
        0 format "99999"  
        liped.lipqtd   * liped.lippreco * 100  format "999999999999999"
        liped.lipqtd   * liped.lippreco * 100  format "999999999999999"
        liped.lippreco * 100  format "999999999999999"
        liped.lippreco * 100  format "999999999999999"
        0   format "99999" 
        ""  format "x(03)"
        0 * 100  format "999999999999999"
        0 * 100  format "99999" /*#3 */
        0 * 100  format "999999999999999"
        0 * 100  format "99999" /* #3 */
        0 * 100  format "999999999999999"
        0 * 100  format "999999999999999"
        0 * 100  format "999999999999999".
    if edipedid.acao = "INSERT"
    then do:
        put unformatted    
            0 * 100  format "9999999"
            0        format "99999999"
            "" format "x(10)".
    end.
    put unformatted
       skip.
end.       

/*#2
put unformatted 
        "05"            format "x(02)"
        ""      format "x(02)"
        ""      format "x(03)"
        ""      format "x(14)"
        0  * 100    format "999999999999999"
        ""  format "x(03)"
        skip.
        
put unformatted 
        "06"            format "x(02)"
        0   format "9999999999999"
        0   format "99999999999999"
        0   format "999999999999"
        0   format "999999999999"
        0 * 100 format "999999999999999"
        ""  format "x(03)"
        skip.
*/
        
put unformatted 
        "09"            format "x(02)"
        vpedtot * 100 format "999999999999999"
        0 * 100 format "999999999999999"
        0 * 100 format "999999999999999"
        0 * 100 format "999999999999999"
        0 * 100 format "999999999999999"
        0 * 100 format "999999999999999"
        0 * 100 format "999999999999999"
        vpedtot * 100 format "999999999999999"
            skip.
output close.

run pok (par-rec, par-arquivo).



procedure pok.
    def input param prec as recid.
    def input param parquivo as char.
    
    do on error undo:
        find edipedid where recid(edipedid) = prec exclusive no-wait no-error.
        if avail edipedid
        then do:
            edipedid.diretorio = vdiretoriosaida.
            edipedid.arquivo = parquivo.
            edipedid.acao   = "ENVIADO".
            edipedid.dtenvio = today.
            edipedid.hrenvio = time.
        end.
    end.


end procedure.

