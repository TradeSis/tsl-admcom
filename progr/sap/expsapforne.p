/* Exportador SAP - Fornecedores*/
/*#1 - helio.neto - Exportacao Planilha CSV , fornecedores com Regra de Negocio igual abas/expabasneogrid.p */


def var vdir-arquivo as char format "x(50)" init "/admcom/tmp/expsap/".
def var par-datacadastramento as date.

par-datacadastramento = today.

def var xtime as int.
xtime = time.

def var vloop as int.

def var tmp-arquivo  as char extent 1.
def var nome-arquivo as char extent 1 format "x(70)" .

    
def var vsysdata     as char.  
vsysdata = string(year(today) ,"9999") 
         + string(month(today),"99")
         + string(day(today)  ,"99")
         + string(time,"HH:MM").
vsysdata = replace(vsysdata,":","").

def var cdata     as char.  
cdata = string(year(par-datacadastramento) ,"9999") 
         + string(month(par-dataCadastramento),"99")
         + string(day(par-dataCadastramento)  ,"99").

tmp-arquivo[1] = vdir-arquivo  + "tmp1".

nome-arquivo[1] = vdir-arquivo + "lebes-" + cdata + "-sap-" + vsysdata + "_fornecedor.csv".

if SESSION:BATCH-MODE = no
then do:
    disp
        nome-arquivo no-label
        with side-labels
        1 down
        centered
        frame farquivo
        width 80.
    update
        nome-arquivo
        with frame farquivo.
end.    

def var vcp     as char no-undo init ";".

function retira-acento returns character(input texto as character):

    define variable c-retorno as character no-undo.
    define variable c-letra   as character no-undo case-sensitive.
    define variable i-conta         as integer   no-undo.
    def var i-asc as int.
    def var c-caracter as char.

    do i-conta = 1 to length(texto):
        
        c-letra = substring(texto,i-conta,1).
        i-asc = asc(c-letra).

        if c-letra = ";"                       then c-caracter = ",". /* csv */
        else
        if i-asc <= 160                         then c-caracter = c-letra.
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
    if c-retorno = "" or c-retorno = ? then c-retorno = "NULO".
    return trim(c-retorno).
end function.


pause 0 before-hide.

IF NOME-ARQUIVO[1] <> ""
THEN do:
    hide message no-pause.
    message today string(time,"HH:MM:SS") string(time - xtime,"HH:MM:SS") "Exportando Fornecedores...".
        
    output to value(tmp-arquivo[1]).

        put  unformatted 
            "Codigo"        vcp
            "CNPJ"          vcp
            "Razao Social"  vcp
            "Endereco"      vcp
            "Bairro"        vcp
            "CEP"           vcp
            
            "Municipio"         vcp
            "UF"            vcp
            "Pais"          vcp
            "Nome Fantasia"
            vcp "Telefone"
            vcp "EMail"
            
            skip.

    for each forne no-lock. 
        put unformatted 
            forne.forcod        vcp
            trim(forne.forcgc)        vcp
            retira-acento(forne.fornom) format "x(40)"       vcp
            retira-acento(forne.forrua)        vcp
            forne.forbairro        vcp
            retira-acento(forne.forcep)        vcp
            retira-acento(forne.formunic)      vcp
            retira-acento(forne.ufecod)        vcp
            retira-acento(forne.forpais)       vcp        
            retira-acento(forne.forfant)       vcp        
            vcp forne.forfone
            vcp forne.email
            
            skip.
    end.
    output close.       
END.
    

hide message no-pause.

message today string(time,"HH:MM:SS") string(time - xtime,"HH:MM:SS") "Encerrando...".

do vloop = 1 to 1:
    IF NOME-ARQUIVO[VLOOP] = "" THEN NEXT.
    unix silent value ("unix2dos -q " + tmp-arquivo[vloop]).
    unix silent value ("mv -f " + tmp-arquivo[vloop] + " " + nome-arquivo[vloop]).
    
end.    

 
hide message no-pause.
message today string(time,"HH:MM:SS") string(time - xtime,"HH:MM:SS") "FIM".

