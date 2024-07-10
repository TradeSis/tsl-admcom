/* Consulta CreditScore do Cliente e emite extratificacao */

{/admcom/progr/cntgendf.i}

find first tbcntgen where tbcntgen.etbcod = 1036 no-lock no-error.
if not avail tbcntgen  or 
    (tbcntgen.validade <> ? and
     tbcntgen.validade < today)
then do:
    message "Controle para INFORMATIVO nao cadastrado ou desativado".
    pause 0.
    return.
end.

{admcab-batch.i new}

def var vsenha as char format "x(10)".
hide frame f-senha no-pause.
def var vkont as int.
def var vtot as dec.
def var vlib as dec.
def var vuti as dec.
def var vant as dec.
def var vtotlib as dec.
def var vtotuti as dec.
def var vlimant as dec.

def buffer bestab for estab.
            
def var vfilial  like estab.etbcod.
def var vfilialf like estab.etbcod.
def var vfilcli like estab.etbcod.
def var vdt     as date no-undo.

def var vtotpar as int.
def var vtotdev as dec.

def var vdatini as date.
def var vdatfin as date.
def var vdetal as log format "Sim/Nao".

def var vperc as dec.
def var vtama as int.

def temp-table tt-estab
    field etbcod like estab.etbcod
    field etbnom like estab.etbnom
    index etb1 etbcod. 
    
def temp-table tt-cli
    field filial like estab.etbcod
    field etbnom like estab.etbnom
    field clicod like clien.clicod
    field clinom like clien.clinom
    field rec_as as recid
    field limlib as dec
    field limuti as dec
    index clicod clicod
    index i1 filial clinom.

def var vclfcod like clien.clicod.
def var vesc              as dec.
def var vcontapar         as int.
def var vnumparcpg        as int.
def var vcalclimite       as dec.
def var vmediaatraso      as dec.
def var vpercrenda        as dec.
def var vpardias          as int.
def var vcalclim          as dec.

def var vguardaval        as dec.
def var vguardacampo      as char.

def var v-rcomtotpg       as dec extent 4.
def var v-rcomdeved       as dec extent 4.

def var qtdpos as int no-undo.
def var v-acho-car as log no-undo.
def var vrelato as char extent 3 format "x(40)" initial
[" Todos Clientes da Filial ", 
 " Clientes c/cartao emitido ", 
 " Clientes c/compra c/cartao no Periodo "].
def var vop-relato as int. 

def var /*output parameter*/ varquivo as char.

def var vdisponivel as dec.
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

do.   /*repeat: */
 
   for each tt-dados.
       delete tt-dados.
   end.
   
   for each tt-cli.
       delete tt-cli.
   end.       
   
   assign vclfcod = 0.

   if keyfunction(lastkey) = "end-error"
   then return.
   
do on error undo:
      
    hide frame fdt.
    pause 0.

    for each estab where estab.etbcod = 1
             no-lock:
                 
             create tt-estab.
             assign tt-estab.etbcod = estab.etbcod
                    tt-estab.etbnom = estab.etbnom.
        
    end.         

    vop-relato = 1.
    case vop-relato:
        when 1 then
            run p-relat1.
    end case.
        
   for each tt-cli where tt-cli.limuti = 0.
        delete tt-cli.
   end.

   connect dragao -H "erp.lebes.com.br" -S sdragao -N tcp -ld dragao
                                            no-error.
   if connected("dragao") then do:
        vkont = 0.
        for each tt-cli :
            vdisponivel = 0.
            run calccredscore.p (input "",
                        input tt-cli.rec_as,
                        output vcalclim,
                        output vpardias,
                        output vdisponivel).
            vkont = vkont + 1.
            if vkont modulo 50 = 0
            then do:
                hide message no-pause.
                message "P2 : " tt-cli.clicod "Registros " vkont skip.
            end.
            
            if vcalclim <> ? and string(vcalclim) <> "?" and vcalclim > 0
            then assign tt-cli.limlib = vcalclim no-error.
            else assign tt-cli.limlib = 0.
                        
        end.
        disconnect dragao.
   end. 
   else do:
            message "Problema na Conexão com banco Remoto(D) !" 
                    view-as alert-box.
            next.
   end.

   /**** Final Sol 26231 ****/
   
   find first tt-cli no-lock no-error.
   if avail tt-cli then do:
    run p-imprime.
    run exporta-csv.   
   end.
   else do:
    message 
    "Nao foram encontrados clientes com os parametros informados." 
    view-as alert-box.
   end.
   
  end.
end.

procedure p-imprime.

varquivo = "/admcom/TI/joao/limites." + string(time).

        {mdad_l.i
            &Saida     = "value(varquivo)"
            &Page-Size = "0"
            &Cond-Var  = "100"
            &Page-Line = "66"
            &Nom-Rel   = ""GERAL""
            &Nom-Sis   = """LIMITES LIBERADOS X LIMITES UTILIZADOS - "" + 
            vrelato[vop-relato]"
            &Tit-Rel   = """PERIODO "" + string(vdatini) + "" a "" + string(vdatfin) + "" - ESTAB:"" + (if vfilial = 0 then ""GERAL"" else tt-estab.etbnom) "
            &Width     = "100"
            &Form      = "frame f-cabcab"}


        for each tt-cli no-lock break by tt-cli.filial
                                      by tt-cli.clinom:
        
            if first-of(tt-cli.filial) then do:

                down with frame f-filial.
                disp tt-cli.filial label "Filial: " format ">>>9"
                     tt-cli.etbnom no-label skip 
                     with frame f-filial side-labels.
            
            end.

            assign vlimant = tt-cli.limlib + tt-cli.limuti no-error.
            
            if tt-cli.limlib > 0
            then assign vperc = (tt-cli.limuti * 100) / tt-cli.limlib no-error.
            else assign vperc = 0.
            disp tt-cli.clicod column-label "Cliente" format ">>>>>>>>>>>>>9"
                 tt-cli.clinom column-label "Nome"  /*aqui*/
                 /*vlimant       column-label "Limite!Anterior"*/
                 "   "
                 tt-cli.limlib column-label "Limite!Liberado"
                               format "->>>,>>>,>>>,>>9.99"
                 "   "
                 tt-cli.limuti column-label "Limite!Utilizado"
                               format "->>>,>>>,>>>,>>9.99"
                 "   "                 
                 vperc column-label "Percentual!Utilizacao"
                 format ">>>>>>>>>>9.99"
                 with frame fmostra width 210 down.
                 
            assign vtot = vtot + 1.
            assign vant = vant + (tt-cli.limlib + tt-cli.limuti) no-error.
            assign vlib = vlib + tt-cli.limlib no-error.
            assign vuti = vuti + tt-cli.limuti no-error.

            if last-of(tt-cli.filial)
            then do:
            
                disp
                 "Total" at 15
                 /*vant column-label  "Limite!Anterior" at 19
                    format "->>>,>>>,>>9.99" */
                 vlib  column-label "Limite!Liberado" at 49
                    format "->>>,>>>,>>>,>>9.99"
                 "   "
                 vuti  column-label "Limite!Utilizado"
                    format "->>>,>>>,>>>,>>9.99"
                 /*vperc column-label "Percentual"*/
                 with frame fmostra1 width 100 down.

                assign vtotlib = vtotlib + vlib no-error.
                assign vtotuti = vtotuti + vuti no-error.
            
                vlib = 0.
                vuti = 0.

            end.                
            if vdetal = yes
            then do:
                /****
                for each titulo use-index iclicod where 
                                      titulo.clifor = tt-cli.clicod 
                                  and titulo.titnat = no
                                  and titulo.titdtpag = ?
                                  and titulo.titsit = "LIB"
                                       no-lock.
                    if titulo.modcod = "DEV" or
                       titulo.modcod = "BON" or
                       titulo.modcod = "CHP"
                    then next.            
                end. /* for each titulo ... */    
                ****/
            end.
        end.
        
            if vlib > 0
            then assign vperc = (vuti * 100) / vlib no-error.
            else assign vperc = 0.

            disp
                 "Total Geral" at 15
                 /*vant column-label  "Limite!Anterior" at 23
                    format "->>>,>>>,>>>,>>9.99"*/
                 vtotlib  column-label "Limite!Liberado" at 49
                    format "->>>,>>>,>>>,>>9.99"
                 "   "
                 vtotuti  column-label "Limite!Utilizado"
                    format "->>>,>>>,>>>,>>9.99"
                 /*vperc column-label "Percentual"*/
                 with frame fmostra2 width 100 down.
            

    output close.
    
end procedure.

procedure p-relat1:

    for each clien where 
             clien.clicod > 9 
             no-lock:
        if clien.clinom = "" then next.
        vtama = length(string(clien.clicod)).
        
        if vtama >= 10
        then do:
            if int(substr(string(clien.clicod), 1, 3)) = 101 or
               int(substr(string(clien.clicod), 1, 3)) = 102
            then vfilcli = int(substr(string(clien.clicod), 1, 3)).
            else vfilcli = int(substr(string(clien.clicod), 2, 3)).
        end.
        else vfilcli = int(substr(string(clien.clicod),
                       length(string(clien.clicod)) - 1, 2)).

        vkont = vkont + 1.
        if vkont modulo 10000 = 0
        then do:
            hide message no-pause.
            message "P1 : " clien.clicod "Registros " vkont skip.
        end.

        if not can-find(tt-estab where
                        tt-estab.etbcod = vfilcli) then do:
            next.             
        end. 
                      
        find first estab where estab.etbcod = vfilcli no-lock no-error.                  
        find first tt-cli where tt-cli.clicod = clien.clicod
                use-index clicod no-lock no-error.
        if not avail tt-cli 
        then do:
            create  tt-cli.
            assign  tt-cli.clicod = clien.clicod no-error.
            assign  tt-cli.rec_as = recid(clien) no-error.
            assign  tt-cli.clinom = clien.clinom no-error.
            assign  tt-cli.filial = vfilcli no-error.
            
            if avail estab then assign tt-cli.etbnom = estab.etbnom.        
                    
            vtotdev = 0.
            vtotpar = 0.

            for each titulo use-index iclicod where 
                     titulo.clifor = clien.clicod
                 and titulo.titnat = no
                 and titulo.titdtpag = ?
                 and titulo.modcod = "CRE" /*Claudir*/
                 and titulo.titsit = "LIB"
                     no-lock .

                              
                    if  titulo.modcod = "DEV" or
                        titulo.modcod = "BON" or
                        titulo.modcod = "CHP"
                    then next.

                    assign vtotdev = vtotdev + titulo.titvlcob no-error.
                    vtotpar = vtotpar + 1.
            end.            
            assign tt-cli.limuti = vtotdev no-error.
        end.
    end.

end procedure.





procedure exporta-csv.

def var vlimlib-aux as char.
def var vlimuti-aux as char.
def var vperc-aux   as char.
def var vok-fil as log.

/* Verifica se deve exportar o arquivo no formato csv */
def var vcsv as log format "Sim/Nao".

vcsv = yes.
/*
message "Deseja gerar o arquivo csv?" update vcsv.
*/
if vcsv = no then leave.

    
    if opsys = "UNIX"
    then varquivo = "/admcom/TI/joao/limitecsv.csv".
    else varquivo = "..\relat\limites" + string(time) + ".csv".
    
output to value(varquivo).

    put unformatted
        "FILIAL"
        ";"
        "CLIENTE"
        ";"
        "NOME"
        ";"
        "LIMITE LIBERADO"
        ";"
        "LIMITE UTILIZADO"
        ";"
        "PERCENTUAL UTILIZACAO"
    skip.
    
def var ger-limlib as dec.
def var tot-limlib as dec.
def var des-limlib as char.
def var ger-limuti as dec.
def var tot-limuti as dec.
def var des-limuti as char.

for each estab no-lock: 
    assign
        tot-limlib = 0
        tot-limuti = 0
        vok-fil = no.
        .
    for each tt-cli where
             tt-cli.filial = estab.etbcod
             no-lock use-index i1:
             
        assign
            tot-limlib = tot-limlib + tt-cli.limlib
            tot-limuti = tot-limuti + tt-cli.limuti
            no-error.
            
        assign vlimlib-aux = string(tt-cli.limlib)
               vlimuti-aux = string(tt-cli.limuti) no-error.
                
        assign vlimlib-aux = replace(vlimlib-aux,",","#")
               vlimuti-aux = replace(vlimuti-aux,",","#") no-error.
                
        assign vlimlib-aux = replace(vlimlib-aux,".",",")
               vlimuti-aux = replace(vlimuti-aux,".",",") no-error.
                
        assign vlimlib-aux = replace(vlimlib-aux,"#",".")
               vlimuti-aux = replace(vlimuti-aux,"#",".") no-error.

        if tt-cli.limlib > 0
        then assign vperc = (tt-cli.limuti * 100) / tt-cli.limlib no-error.
        else assign vperc = 0.
            
        assign vperc-aux = string(vperc).
        
        assign vperc-aux = replace(vperc-aux,",","#").
        
        assign vperc-aux = replace(vperc-aux,".",",").
        
        assign vperc-aux = replace(vperc-aux,"#",".").

        put unformatted
            tt-cli.filial
            ";"
            tt-cli.clicod
            ";"                                                                ~             tt-cli.clinom          
            ";"
            vlimlib-aux
            ";"
            vlimuti-aux
            ";"
            vperc-aux
        skip.
        vok-fil = yes.
    end.   
    if vok-fil
    then do:
        assign
            ger-limlib = ger-limlib + tot-limlib
            ger-limuti = ger-limuti + tot-limuti
            des-limlib = string(tot-limlib)
            des-limlib = replace(des-limlib,",","#")
            des-limlib = replace(des-limlib,".",",")
            des-limlib = replace(des-limlib,"#",".")
            des-limuti = string(tot-limuti)
            des-limuti = replace(des-limuti,",","#") 
            des-limuti = replace(des-limuti,".",",")
            des-limuti = replace(des-limuti,"#",".")
            no-error .

        if tot-limlib > 0
        then assign vperc = (tot-limuti * 100) / tot-limlib no-error.
        else assign vperc = 0.
            
        assign vperc-aux = string(vperc).
        
        assign vperc-aux = replace(vperc-aux,",","#").
        
        assign vperc-aux = replace(vperc-aux,".",",").
        
        assign vperc-aux = replace(vperc-aux,"#",".").
        put unformatted
        "; ;"
        "TOTAL FILIAL " + string(estab.etbcod) format "x(25)"
        ";"
        des-limlib
        ";"
        des-limuti
        ";"
        vperc-aux
        skip.
    end.
end.    


assign
        des-limlib = string(ger-limlib)
        des-limlib = replace(des-limlib,",","#")
        des-limlib = replace(des-limlib,".",",")
        des-limlib = replace(des-limlib,"#",".")
        des-limuti = string(ger-limuti)
        des-limuti = replace(des-limuti,",","#") 
        des-limuti = replace(des-limuti,".",",")
        des-limuti = replace(des-limuti,"#",".")
        .

if ger-limlib > 0
        then assign vperc = (ger-limuti * 100) / ger-limlib no-error.
        else assign vperc = 0.
            
        assign vperc-aux = string(vperc).
        
        assign vperc-aux = replace(vperc-aux,",","#").
        
        assign vperc-aux = replace(vperc-aux,".",",").
        
        assign vperc-aux = replace(vperc-aux,"#",".").

/*
put unformatted
    "; ;"
    "TOTAL GERAL " format  "x(25)"
    ";"
    des-limlib
    ";"
    des-limuti
    ";"
    vperc-aux
    skip.

*/

output close.
    
end procedure. 

