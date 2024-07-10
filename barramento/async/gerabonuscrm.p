def new global shared var scontador as int.

def input parameter par-rec as recid.

{/admcom/progr/acha.i}
def var vnome as  char.
def var hbonusCrmEntrada as handle.
def var lcJsonSaida as longchar.
def var lokJson as log.

def temp-table ttbonuscrm no-undo serialize-name 'bonusCrm'
    field dataEmisao    as char 
    field descricao     as char
    field codigoLoja    as char
    field numero        as char
    field codigoCliente as char
    field valor         as char
    field vencimento    as char /*    ":"2020-01-30", */
    field tstatus       as char serialize-name 'status'
    field dataUtilizacao    as char.

DEFINE DATASET bonusCrmEntrada FOR ttbonuscrm.

hbonusCrmEntrada = DATASET bonusCrmEntrada:HANDLE.

find titulo where recid(titulo) = par-rec no-lock no-error.
if not avail titulo
then return.

if titulo.titnat = yes and
   titulo.modcod = "BON"
then. /* segue */
else return.   

create ttbonuscrm.
dataEmisao  =   string(year(titulo.titdtemi),"9999") + "-" +
               string(month(titulo.titdtemi),"99")   + "-" +
                 string(day(titulo.titdtemi),"99"). 

        if titulo.titobs[1] <> "" 
        then do: 
            find acao where acao.acaocod = int(titulo.titobs[1])
                      no-lock no-error. 
            if avail acao 
            then ttbonuscrm.descricao = acao.descricao. 
        end.
        else if titulo.titobs[2] <> ""
        then do.
            vnome = acha("bonus", titulo.titobs[2]).
            if vnome <> ?
            then ttbonuscrm.descricao = vnome.
         end.

codigoLoja  = string(titulo.etbcod).
numero      = titulo.titnum.
codigoCliente   = string(titulo.clifor).
ttbonuscrm.valor       = string(titulo.titvlcob,">>>>>>>>>>9.99").
vencimento  =  string(year(titulo.titdtven),"9999") + "-" +
               string(month(titulo.titdtven),"99")   + "-" +
                 string(day(titulo.titdtven),"99"). 
tstatus     = titulo.titsit.
dataUtilizacao  = if titulo.titdtpag = ? 
                  then ""
                  else 
                string(year(titulo.titdtpag),"9999") + "-" +
               string(month(titulo.titdtpag),"99")   + "-" +
                 string(day(titulo.titdtpag),"99"). 

lokJson = hbonusCrmEntrada:WRITE-JSON("LONGCHAR", lcJsonSaida, TRUE) no-error.
if lokJson
then do: 
    
       
      scontador = scontador + 1.
      create verusjsonout.
      ASSIGN
        verusjsonout.interface     = "bonusCrm".
        verusjsonout.jsonStatus    = "NP".
        verusjsonout.dataIn        = today.
        verusjsonout.horaIn        = scontador.
    
        copy-lob from lcJsonSaida to verusjsonout.jsondados.
        
    
/**    hbonusCrmEntrada:WRITE-JSON("FILE","bonusCrmEntrada.json", true).**/
    
end.    

/*


for each ttbonuscrm.
    disp ttbonuscrm.
    disp ttbonuscrm.saldo (total).
    disp ttbonuscrm.qtd  ( total).
    find modal of ttbonuscrm no-lock no-error.
    disp modal.modnom when avail modal.
    find cobra of ttbonuscrm no-lock.
    disp cobra.cobnom.
end.
    */
