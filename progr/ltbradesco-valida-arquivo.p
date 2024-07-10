def input parameter p-recid as recid.

find lotcre where recid(lotcre) = p-recid no-lock.

def var vlinha as char.

def var varquivo as char.
/*
varquivo = "/admcom/bradesco/titulos/PG250903.REM".
*/
varquivo = lotcre.arqenvio.
if search(varquivo) <> ?
then.
else do:
    message color red/with
    "Arquivo não encontrado." skip
    varquivo
    view-as alert-box.
    return.
end.    

def temp-table tt-arquivo
    field linha as char
    field campo as char extent 60
    .

input from value(varquivo).
repeat:
    import unformatted vlinha.

    create tt-arquivo.
    tt-arquivo.linha = vlinha.
    
    if substr(vlinha,1,1) = "0"
    then do:
        assign  /*REGISTRO 500*/
            campo[1] = substr(vlinha,1,1)
            campo[2] = substr(vlinha,2,8)
            campo[3] = substr(vlinha,10,1)
            campo[4] = substr(vlinha,11,15)
            campo[5] = substr(vlinha,26,40)
            campo[6] = substr(vlinha,66,2)
            
            campo[7] = substr(vlinha,68,1)
            campo[8] = substr(vlinha,69,5)
            campo[9] = substr(vlinha,74,5)
            campo[10] = substr(vlinha,79,4)
            campo[11] = substr(vlinha,83,2)
            campo[12] = substr(vlinha,85,2)
            campo[13] = substr(vlinha,87,2)
            campo[14] = substr(vlinha,89,2)
            campo[15] = substr(vlinha,91,2)
            campo[16] = substr(vlinha,93,5)
            campo[17] = substr(vlinha,98,3)
            campo[18] = substr(vlinha,101,5)
            campo[19] = substr(vlinha,106,1)
            campo[20] = substr(vlinha,107,74)
            campo[21] = substr(vlinha,181,80)
            campo[22] = substr(vlinha,261,217)
            campo[23] = substr(vlinha,478,9)
            campo[24] = substr(vlinha,487,8)
            campo[25] = substr(vlinha,495,6)
            .
            
    end.
    else if substr(vlinha,1,1) = "1"
        then do:
            assign  /*REGISTRO 500*/
                campo[1] = substr(vlinha,1,1)
                campo[2] = substr(vlinha,2,1)
                campo[3] = substr(vlinha,3,15)
                campo[4] = substr(vlinha,18,30)
                campo[5] = substr(vlinha,48,40)
                campo[6] = substr(vlinha,88,8)
                campo[7] = substr(vlinha,96,3)
                campo[8] = substr(vlinha,99,5)
                campo[9] = substr(vlinha,104,1)
                campo[10] = substr(vlinha,105,13)
                campo[11] = substr(vlinha,118,2)
                campo[12] = substr(vlinha,120,16)
                campo[13] = substr(vlinha,136,3)
                campo[14] = substr(vlinha,139,12)
                campo[15] = substr(vlinha,151,15)
                campo[16] = substr(vlinha,166,4)
                campo[17] = substr(vlinha,170,2)
                campo[18] = substr(vlinha,172,2)
                campo[19] = substr(vlinha,174,4)
                campo[20] = substr(vlinha,178,2)
                campo[21] = substr(vlinha,180,2)
                campo[22] = substr(vlinha,182,8)
                campo[23] = substr(vlinha,190,1)
                campo[24] = substr(vlinha,191,4)
                campo[25] = substr(vlinha,195,10)
                campo[26] = substr(vlinha,205,15)
                campo[27] = substr(vlinha,220,15)
                campo[28] = substr(vlinha,235,15)
                campo[29] = substr(vlinha,250,2)
                campo[30] = substr(vlinha,252,10)
                campo[31] = substr(vlinha,262,2)
                campo[32] = substr(vlinha,264,2)
                campo[33] = substr(vlinha,266,4)
                campo[34] = substr(vlinha,270,2)
                campo[35] = substr(vlinha,272,2)
                campo[36] = substr(vlinha,274,3)
                campo[37] = substr(vlinha,277,2)
                campo[38] = substr(vlinha,279,10)
                campo[39] = substr(vlinha,289,1)
                campo[40] = substr(vlinha,290,2)
                campo[41] = substr(vlinha,292,4)
                campo[42] = substr(vlinha,296,15)
                campo[43] = substr(vlinha,311,15)
                campo[44] = substr(vlinha,326,6)
                campo[45] = substr(vlinha,332,40)
                campo[46] = substr(vlinha,372,1)
                campo[47] = substr(vlinha,373,1)
                campo[48] = substr(vlinha,374,40)
                campo[49] = substr(vlinha,414,2)
                campo[50] = substr(vlinha,416,35)
                campo[51] = substr(vlinha,451,22)
                campo[52] = substr(vlinha,473,5)
                campo[53] = substr(vlinha,478,1)
                campo[54] = substr(vlinha,479,1)
                campo[55] = substr(vlinha,480,7)
                campo[56] = substr(vlinha,487,8)
                campo[57] = substr(vlinha,495,6)
                .

        end.
        else if substr(vlinha,1,1) = "9"
            then do:
                assign /*REGISTRO 500*/
                    campo[1] = substr(vlinha,1,1)
                    campo[2] = substr(vlinha,2,6)
                    campo[3] = substr(vlinha,8,17)
                    campo[4] = substr(vlinha,25,470)
                    campo[5] = substr(vlinha,495,6)
                    .

            end.
end.
input close.

function digitomodulo11p2a9 returns integer
    (input par-numero as char,
     input-output par-dv10   as int).
   
   par-numero = replace(par-numero,"0","").
   
   def var vct    as int.
   def var vparc  as int.
   def var vsoma  as int.
   def var vresto as int.
   def var vpeso as int.   

   def var vdd as char.
   def var c-tam as int.

   c-tam = int(length(par-numero)).
   vpeso = 2.
   do vct = c-tam to 1 by -1.
        vparc = (int(substr(par-numero,vct,1))).
        if vparc = 0 then .
        else do:
        vparc = vparc * vpeso.
        vdd = vdd + string(vparc) + "+".
        vsoma  = vsoma + vparc.
        end.
        vpeso = vpeso + 1.
        if vpeso = 9
        then vpeso = 2.
    end.        
    
    if vsoma < 11
    then vresto = vsoma.
    else vresto = vsoma modulo 11.

    if vresto = 0
    then return 0. 
    else do:
        if 11 - vresto = 0 or
           11 - vresto > 9
        then return 1.
        else return 11 - vresto.
    end.

end function.


def var tamanho-reg as log init yes.
def var transacao-reg as log init no.
def var transacao-qtd as int   init 0.
def var header-reg as log init no.
def var header-qtd as int      init 0.
def var trailler-reg as log init no.
def var trailler-qtd as int    init 0.
def var problema-valor as int  init 0.
def var valor-documento as dec init 0.
def var valor-pagamento as dec init 0.
def var valor-acrescimo as dec init 0.
def var valor-desconto as dec  init 0.
def var cod-barras as char.
def var dig-codbarras as log init yes.
def var tamanho-codbarras as log init yes.
def var val-digito as int.
def var par-dv10 as int.
for each tt-arquivo:
    
    assign
        valor-documento = 0
        valor-pagamento = 0
        valor-desconto = 0
        valor-acrescimo = 0
        .
        
    if length(vlinha) <> 500
    then tamanho-reg = no.
    if campo[1] = "0"
    then assign
            header-reg = yes
            header-qtd = header-qtd + 1
            .
    if campo[1] = "1"
    then do:
        assign
            transacao-reg = yes
            transacao-qtd = transacao-qtd + 1
            valor-documento = int(campo[25]) / 100
            valor-pagamento = int(campo[26]) / 100
            valor-desconto = int(campo[27]) / 100
            valor-acrescimo = int(campo[28]) / 100
            .
         if campo[40] = "31"
         then do:  
            cod-barras = (campo[7] +
                substr(campo[48],27,1) +
                substr(campo[48],26,1) +
                campo[24] + campo[25]  +
                subst(campo[48],1,25)) .
                
            cod-barras = trim(cod-barras) + "0" .
            if length(cod-barras) <> 47
            then tamanho-codbarras = no.
            val-digito = digitomodulo11p2a9(string(cod-barras),
                                        input-output par-dv10)
                                        .
            if val-digito <> int(substr(campo[49],26,1))
            then dig-codbarras = no. 
        end.
        
        if (valor-documento + valor-acrescimo - valor-desconto)    
            <> valor-pagamento
        then problema-valor = problema-valor + 1.    

        /*
        message cod-barras campo[48]
        length(cod-barras) 
        val-digito substr(campo[48],26,1). pause.
        */

    end.        
    if campo[1] = "9"
    then assign
            trailler-reg = yes
            trailler-qtd = trailler-qtd + 1
            .
    
    /*
    disp valor-documento
         valor-pagamento
         valor-desconto
         valor-acrescimo.
    */     

    /*
    disp campo[1]
         campo[2]
         campo[3]
         campo[4]
         length(vlinha).
         */
end.

do with frame f-1 row 7 no-label title " ALERTAS DE INCONSISTENCIA ":
    if header-reg = no
    then disp "ARQUIVO SEM REGISTRO HEADER." skip.
    if transacao-reg = no 
    then disp "ARQUIVO SEM REGISTRO DE TRANSAÇÃO." skip.
    if trailler-reg = no
    then disp "ARQUIVO SEM REGISTRO TRAILLER."  skip.
    if tamanho-reg = no
    then disp "HÁ REGISTRO(S) COM INCOSISTENCIA DE TAMANHO." skip. 
    if problema-valor > 0
    then disp "HÁ REGISTRO(S) COM INCOSISTENCIA DE VALOR." skip.
    if tamanho-codbarras = no
    then disp "PROBLEMA CODIGO DE BARRAS." skip.
    /*
    if dig-codbarras = no
    then disp "PROBLEMA DIGITO VERIFICADOR CODIGO DE BARRAS." skip.
    */
end.
pause.
