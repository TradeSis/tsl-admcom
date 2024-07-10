def input param petbcod as int.
def input param pvalortransacao as dec.
def input param pclicod as int.
def input param pcpf    as dec.
def input param pdatavenda as date. 
def input param plojavenda as int.
def input param ppdvvenda  as int.
def input param pcupomvenda as int.
def input param pseq  as int.

def output param vMensagemPDV as char.
def output param vNSUSafe     as char.
def output param vTextoCupom  as char.
def output param vCartao      as char.

def var ptoday as date init today.


def shared temp-table tt-EmissaoValeTroca93 no-undo       
        field cestabelecimento      as char 
        field ccodigoloja       as char  
        field cpdv              as char  
        field cvalortransacao   as char  
        field choralocal        as char  
        field cdatalocal        as char  
        field ctipocliente      as char  
        field cnomecliente      as char  
        field ccpfcnpj          as char  
        field crg               as char  
        field corgaoemissaorg   as char  
        field cdatanascimento   as char  
        field cnumerotelefone   as char  
        field cnumerocupomtroca as char 
        field cnumerocupomvale  as char 
        field cdatavenda        as char 
        field cnumerolojavenda  as char 
        field cnumeropdvvenda   as char 
        field cnsuvenda         as char 
        field cnumerocupomvenda as char 
        field cnumerooperadorvenda as char 
        field cnumerooperadoremissao as char
        field cnumeroFiscalEmissao as char 
        field cdataSensibilizacao as char 
        field clojaSensibilizacao  as char
        field cpdvSensibilizacao  as char 
        field cnsuSensibilizacao  as char 
        field coperadorSensibilizacao  as char
        field cfiscalSensibilizacao  as char 
        field cmac  as char 
        field cnsuSafe as char.


def new shared temp-table tt-xmlretorno
    field child-num  as int
    field root       as char format "x(15)"
    field tag        as char format "x(20)"
    field valor      as char format "x(20)"
    /*index x is unique primary child-num asc root asc tag asc valor asc*/.

    find clien where clien.clicod = pclicod no-lock no-error.

    CREATE tt-EmissaoValeTroca93.        
       assign
         cestabelecimento  = string(string(petbcod,"9999"),"x(15)").
         ccodigoloja       = string(int(petbcod),"9999").
         cpdv              = '020'                       .
         cvalortransacao   = string(pvalortransacao).
         choralocal        = replace(string(time,"HH:MM:SS"),":","").
         cdatalocal        = string(month(ptoday),"99") + string(day(ptoday),"99")  .
         ctipocliente      = 'F'  .
         cnomecliente      = if avail clien
                             then clien.clinom
                             else "CONSUMIDOR CONSUMIDOR".
         ccpfcnpj          = string(pcpf,"999999999999999")  .
         crg               = "0".
         corgaoemissaorg   = ''  .
         cdatanascimento   = '19480101'  .
         cnumerotelefone   = '5134439999'  .
         cnumerocupomtroca = string(pseq,"999999").
         cnumerocupomvale  = string(pseq + 1,"999999").
         cdatavenda        = string(year(pdatavenda),"9999") +
                            string(month(pdatavenda),"99")   +
                              string(day(pdatavenda),"99").
         cnumerolojavenda  = string(int(plojavenda),"9999") .
         cnumeropdvvenda   = string(int(ppdvvenda),"999") .
         cnsuvenda         = '000001' .
         cnumerocupomvenda = string(int(pcupomvenda),"999999") .
         cnumerooperadorvenda = '000200' .
         cnumerooperadoremissao = '000200'.
         cnumeroFiscalEmissao = '000200' .
         cdataSensibilizacao = string(year(ptoday),"9999") +
                              string(month(ptoday),"99")   +
                                string(day(ptoday),"99").
         clojaSensibilizacao  = ccodigoloja.
         cpdvSensibilizacao  = '020' .
         cnsuSensibilizacao  = string(pseq,"999999").
         coperadorSensibilizacao  = '000200'.
         cfiscalSensibilizacao  = '000200' .
         
         
         run calcula-mac (output cmac).
          
run hnc/wssafe.p ("EmissaoValeTroca93").


find current tt-EmissaoValeTroca93.


find first tt-xmlretorno where tag = "MensagemPDV" no-error.
if avail tt-xmlretorno
         then vmensagemPdv = tt-xmlretorno.valor.

find first tt-xmlretorno where tag = "NSUSafe" no-error.
if avail tt-xmlretorno
         then do:
            vNSUSafe = tt-xmlretorno.valor.
            tt-EmissaoValeTroca93.cNSUSafe = vNSUSafe.
         end.   

find first tt-xmlretorno where tag = "TextoCupom" no-error.
if avail tt-xmlretorno
         then vTextoCupom = tt-xmlretorno.valor.

find first tt-xmlretorno where tag = "Cartao" no-error.
if avail tt-xmlretorno
         then vcartao = tt-xmlretorno.valor.



procedure calcula-mac.
def output param cmac as char.

def var passo1 as int64.
def var passo2 as int.
def var passo3 as int64.
def var passo4 as int64.
def var passo5 as char.

def var pdv as int init "20".
def var nsu as int.
def var data as int.
def var valor as int.

valor = int(replace(replace(string(pvalortransacao,"99999999999999999.99"),".",""),",","")).
nsu = pseq.


data = int(string( year(ptoday),"9999") +
           string(month(ptoday),"99")   +
           string(  day(ptoday),"99")).
           
/* Passo 1
 * Soma os valores de:
  * -> Data sensibilização;
   * -> Número da loja;
    * -> Número do PDV;
     * -> NSU Sensibilização
      */


      passo1 = (data + petbcod + pdv + nsu).

      /* Passo 2
       * Divide o valor pago pelo número do PDV e trunca, obtendo a parte inteira dessa divisão.
        * Porém, precisamos apenas da parte inteira.
        */
        passo2 = int(STRING(TRUNCATE((valor / pdv) * 1,00))).

        /* Passo 3
        * Soma o resultado do Passo 1 com o Passo 2
        */
        passo3 = passo1 + passo2.

        /* Passo 4:
        * Multiplica o valor do Passo 3 com a soma da Loja + NSU Sensibilização
        */
        passo4 = (petbcod + nsu) * passo3.

        /* Passo 5:
         * Converte o resultado obtido Passo 4 em string e completa
          * com zeros a esquerda até ficar com 4 posições, caso o resultado do
           * Passo 4 seja menor que 4 dígitos. No nosso exemplo, o passo 4 tem
            * tamanho 8, logo não é necessário completar com zeros a esquerda.
             */
             if passo4 > 999 then do:
               passo5 = string(passo4).
               end.
               else do:
                 passo5 = string(passo4, "9999").
                 end.

                 /* Passo 6
                  * Inverte a string obtida no Passo 5 e devolve os 4 primeiros bytes dela
                   */
                   DEFINE VARIABLE reverse AS CHARACTER   NO-UNDO.
                   DEFINE VARIABLE ii      AS INTEGER     NO-UNDO.

                      DO ii = LENGTH( passo5 ) TO 1 BY -1:
                            reverse = reverse + SUBSTRING( passo5, ii, 1 ).
                               END.
                               cmac = SUBSTRING(reverse,1,4,"CHARACTER") .


/*valor = 31255.
data = 20180903.
pdv = 99.
loja = 189.
nsu = 0.
  */



end procedure.
