/* Consulta CreditScore do Cliente e emite extratificacao */

{admcab.i}

def var vclfcod like clien.clicod.
def var vtipo   as log format "Atual/Novo" init yes.
def var vesc as dec.
def var vcontapar         as int.
def var vnumparcpg        as int.
def var vcalclimite       as dec.
def var vmediaatraso as dec.
def var vpercrenda        as dec.
def var vpardias as int.
def var vcalclim as dec.
def var limite-disponivel as dec.

def var vguardaval        as dec.
def var vguardacampo      as char.

def var v-rcomtotpg       as dec extent 4.
def var v-rcomdeved       as dec extent 4.

def var qtdpos as int no-undo.

def new shared temp-table tt-dados
    field parametro as char
    field valor     as dec
    field valoralt  as dec
    field percent   as dec
    field vcalclim  as dec
    field operacao  as char format "x(1)" column-label ""
    field numseq    as int
    index dado1 numseq.
def buffer btt-dados for tt-dados.

 repeat: 
 
   for each tt-dados.
       delete tt-dados.
   end.
   
   assign
      vclfcod = 0.

   if keyfunction(lastkey) = "end-error"
   then return.

   update vclfcod validate (vclfcod > 0, "") label "Cliente........."
          skip
          vtipo label "Tipo de Extrato."
          with frame f-cli 1 down side-label row 3 width 80.

   find clien where clien.clicod = vclfcod no-lock no-error.
   if not avail clien then do:
       message
            "Codigo Invalido para Cliente"
            view-as alert-box title " Atencao!! ".
        undo.
   end.
   display clien.clinom no-label with frame f-cli.

   connect dragao -H "erp.lebes.com.br" -S sdragao -N tcp -ld dragao
                                            no-error.
   if connected("dragao")
   then do:
       if vtipo = yes /* Atual */ 
       then run calccredscore.p(input "Tela",
                                 input recid(clien),
                                output vcalclim,
                                output vpardias,
                                output limite-disponivel).
        else run calccredsc.p(input "Tela",
                                input recid(clien),
                                output vcalclim,
                                output vpardias,
                                output limite-disponivel).
        disconnect dragao.
   end.     

   disp vcalclim format ">>,>>9.99" label "Score de Credito".
   
   message " Deseja Imprimir extratificacao do Cred Score? " update sresp.
   if sresp = no
   then next.
   else run p-imprime.

end.

procedure p-imprime.
def var varquivo as char.
/*
if opsys = "UNIX"
then varquivo = "/admcom/desenv/credscore/credscore." + string(time).
else varquivo = "\admcom\desenv\credscore\credscore." + string(time).
*/
varquivo = "./credscore." + string(time).
    
        {mdad_l.i
            &Saida     = "value(varquivo)"
            &Page-Size = "0"
            &Cond-Var  = "150"
            &Page-Line = "66"
            &Nom-Rel   = ""GERAL""
            &Nom-Sis   = """EXTRATO DE CREDSCORE"""
            &Tit-Rel   = """POSICAO EM "" + string(today) "
            &Width     = "150"
            &Form      = "frame f-cabcab"}


def var vrendacalclim as dec.
def var vpercrenda as dec.
def var vnumparcpg as int.
def var vcontapar as int.

def var vtotdev as dec.
def var vtotpar as int.

vrendacalclim = clien.prorenda[1].
find first credscore where credscore.campo = "PERCRENDA"
    no-lock no-error.
if avail credscore
then assign vpercrenda = credscore.vl-ini.
else assign vpercrenda = 60.

/* Quantidade de Parcelas Pagas */                                              find first credscore where credscore.campo = "NUMPARCPG"                             no-lock no-error.                                                         if avail credscore                          
then assign vnumparcpg = credscore.vl-ini.
else assign vnumparcpg = 0.

for each fin.titulo where titulo.titnat = no
                  and titulo.clifor = clien.clicod
                  and titulo.titsit = "PAG"
                      no-lock.
    if titulo.modcod = "DEV" or
       titulo.modcod = "BON" or
       titulo.modcod = "CHP"
    then next.
    vcontapar = vcontapar + 1.
end.
find first posicli where posicli.clicod = clien.clicod
       no-lock no-error.
if avail posicli
then assign
        vcontapar = vcontapar + posicli.qtdparpg.



def var vsomapar as int.
def var vcontrpar as int. /* controla as ultimas 10 parcelas */                
def var vmaioratraso as int.                                                  
def var vmediaatraso as dec.

def var vatraso as dec.
vcontrpar = 0. 
vmaioratraso = 0. 
                                                              
for each fin.titulo where fin.titulo.titnat = no
                  and fin.titulo.titdtpag <> ?
                  and fin.titulo.clifor = clien.clicod
                  and fin.titulo.titsit = "PAG"
                  /*and fin.titulo.modcod =  "CRE"
                  and fin.titulo.moecod <> "DEV" */
                      no-lock
     break by fin.titulo.titdtpag descending.      
     if titulo.modcod = "DEV" or
       titulo.modcod = "BON" or
       titulo.modcod = "CHP"
    then next.

     if vatraso = 0 or ((today - fin.titulo.titdtven) > 0 and
                         vatraso < (today - fin.titulo.titdtven))
     then vatraso = (today - fin.titulo.titdtven).
     if vcontrpar < vnumparcpg
     then do:
      vcontrpar = vcontrpar + 1.                                               ~    vmaioratraso = vmaioratraso + (fin.titulo.titdtpag - fin.titulo.titdtven).
    end.
    vsomapar = vsomapar + 1.
end.
find first posicli where posicli.clicod = clien.clicod
       no-lock no-error.
if avail posicli
then assign
        vsomapar = vsomapar + posicli.qtdparpg
        .

vmediaatraso = vmaioratraso / vcontrpar.

if vmediaatraso < 0
then vmediaatraso = 0.

disp vclfcod clien.clinom vcalclim label "Limite"
     vrendacalclim label "Renda p/ Calculo de Limite"
     vpercrenda    label "Perc. p/ Calculo de Limite" format ">>9.99%"
     clien.vlalug  label "Valor do Aluguel"
     skip
     vnumparcpg label "Numero de Parcelas Pagas a Considerar"
     vcontapar  label "Numero de Parcelas Pagas do Cliente"
     skip
     clien.fone
     clien.sexo
     clien.estciv
     vmediaatraso label "Media Dias Atraso"
     with frame f-mostra side-labels width 100.

put skip(1).

for each tt-dados where tt-dados.valor <> 0 or tt-dados.percent <> 0 /***(tt-dados.valoralt > 0 or tt-dados.parametro = "Renda p ara Calculo de Limite") /*and tt-dados.valor > 0*/  and tt-dados.vcalclim  > 0 ***/  by tt-dados.numseq.
    disp tt-dados.parametro column-label "Parametro" format "x(40)"
         tt-dados.valoralt column-label  "Valor Ant." when valoralt > 0
         tt-dados.operacao when valoralt > 0
         tt-dados.valor column-label "Valor" when valoralt > 0
         tt-dados.percent column-label "Percentual" when valoralt > 0 and percent > 0
         tt-dados.vcalclim column-label "Limite Atualizado" with frame fmostra width 150 no-box down.
end.

        vtotdev = 0.
        vtotpar = 0.
        for each titulo where titulo.titnat = no
                          and titulo.clifor = clien.clicod
                          and titulo.titdtpag = ?
                          and titulo.titsit = "LIB"
                          /*and titulo.modcod =  "CRE"
                          and titulo.moecod <> "DEV"*/                          
                              no-lock use-index iclicod  by titulo.titdtemi .            if titulo.modcod = "DEV" or
               titulo.modcod = "BON" or
                titulo.modcod = "CHP"
            then next.

            vtotdev = vtotdev + titulo.titvlcob.                              
            vtotpar = vtotpar + 1.
            disp titulo.etbcod titulo.titdtemi titulo.titnum titulo.titpar titulo.titvlcob (total) titulo.titdtven.
        end.
        
        put skip(2).
        disp vcalclim           label "Limite de Compras......"
             skip
             vtotdev            label "Parcelas em Aberto....."
             skip
             vtotpar            label "Qtd Parcelas em Aberto."
             skip
             vcalclim - vtotdev label "Limite Total Disponível"
             with frame ffim side-labels.
        
        

    output close.
    if opsys = "UNIX"
    then do:
        run visurel.p (input varquivo, input "").
    end.
    else do:
        {mrod.i}.
    end.
end procedure.

