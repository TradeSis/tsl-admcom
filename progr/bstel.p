/*  bstelcli.p                 */
def buffer bclien for clien.
def new global shared var tetbcod like estab.etbcod.
def new global shared var tfuncod like func.funcod.
def var vetbcod like estab.etbcod .
tetbcod = 0.
tfuncod = 0. 

def var vnumparcpg as int.
def var vsomapar as int.

    /* Quantidade de Parcelas Pagas */                                         
    find first credscore where credscore.campo = "NUMPARCPG"                             no-lock no-error.                                                          if avail credscore                          
    then assign vnumparcpg = credscore.vl-ini.
   else assign vnumparcpg = 0.
                
def var vsetor like clilig.setor.
def var vsettipo like clilig.settipo.

/*
def var vtipo as char format "x(5)" extent 3
        init ["TODOS","COBRA","CRIIC"].
        
display vtipo with frame fesc centered row 10 overlay no-label.
    choose field vtipo auto-return
    with frame fesc.
hide frame fesc no-pause.    
    
if frame-index = 1
then vsetor = "".
else if frame-index = 2
then vsetor = "COBRA".
else if frame-index = 3
then*/ vsetor = "COBRA".

/*update vsetor vsettipo.*/
/*vsetor = "".*/

def new shared var vtotvencido as dec.
def new shared var vparvencido as int.
def new shared var vencvencido as dec.
def new shared var totalvencido as dec.

def new shared var vtotvencer as dec.
def new shared var vparvencer as int.

def new shared var vtotpagas as dec.
def new shared var vparpagas as int.
def new shared var vencpagas as dec.

def var vjuros as dec.
def var vsaldoatualizado as dec.

def var vdatopc7    as date label "Data" /*"A partir de"*/.
def var vdatopc8ini as date label "Periodo - de".
def var vdatopc8fin as date label "a".

def var p-fone as char.

def var varquivo as char.

def var vrgccod     like rgcobra.rgccod.
def var vclicod     like clien.clicod.
def var vmodcod like modal.modcod init "geral".
def var vdiasini       as int format ">>>9" label "Dias Atraso".
/*def var vdiasfin       as int format ">>>9" label "ate".*/

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esq-periodo     as log initial no.
def var esqcom1         as   char format "x(12)" extent 6
      initial [" Relatorio "," Acoes Cob "," Dados ",
                        " Cliente ", " Simulacao "," Arq.SMS "].
def var esqhel1         as char format "x(80)" extent 5
    initial [" Inclusao  de clilig ",
             " Alteracao da clilig ",
             " Exclusao  da clilig ",
             " Consulta  da clilig ",
             " Listagem  Geral de clilig "].
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].

{admcab.i}

/***
message "Aguarde nova versao do Call Center...".
return.
***/

def var vcelular as char.
def temp-table tt-cel
    field celular as char
    index i1 celular.
                   
def var vendereco     as char format "x(60)"  .
def var vdesfone        as   char.
def var vspc            as   log format "SIM/NAO".
def var vdescricao      as   char.

def var vtoday as date format "99/99/9999".
vtoday = today .
def var vtelobs         as   char extent 4 format "x(60)".

find first clilig where clilig.DtProxLig >= vtoday - 1 no-lock no-error.
if not avail clilig
then do on error undo.
    message "Processo para selecionar as Ligacoes deve ser processado."
            " ****  AVISAR O SETOR DE TI ****"
            view-as alert-box.
    return.            
end.

/*
find first clilig where (if vsetor <> "" then clilig.setor = vsetor else true)
        no-lock no-error.
if not avail clilig
then do on error undo.
    message "Processo para selecionar as Ligacoes deve ser processado."
            " ****  AVISAR O SETOR DE TI ****"
            view-as alert-box.
    return.            
end.         
*/

def var vsenha like func.senha.
vsenha = "".
do on error undo, return on endkey undo, retry:
    if keyfunction(lastkey) = "END-ERROR"
    then return.
    vsenha = "".
    update tetbcod label "Estab"
           tfuncod label "Matricula"
           vsenha blank with frame f-senh side-label centered row 10.
    find first func where func.funcod = tfuncod and
                          func.etbcod = tetbcod and
                          func.senha  = vsenha no-lock no-error.
    if not avail func
    then do:
        message "Funcionario Invalido.".
        undo, retry.
    end.
    else do:
        assign tetbcod = func.etbcod
               tfuncod = func.funcod.
        if tetbcod <> 999
        then esqcom1[6] = "".
    end.                
end.
hide frame f-senh no-pause.  

def buffer bclilig       for clilig.
def buffer celclilig     for clilig.
def var vclilig         like clilig.clicod.
def var vdivida         like titulo.titvlcob format "->>,>>>,>>9.99".
def var vnumdias        as   int    format   ">>>9"    column-label "Dias".
def var vdatahora as char init "". 
def var vtitle as char.
def var vvalini        like titulo.titvlcob.
def var vvalfin        like titulo.titvlcob.
def var vnovacao       as log format "Sim/Nao" init yes.
def var vcrediario     as log format "Sim/Nao" init yes.
def var vnovos         as log format "Novos/Todos" init no. 
def var vagendadas as log format "Agendados/Nao realizadas".

def var vtipos as char   format "x(30)" extent 4
    init [/*" 1)  11 A 11 DIAS      ", 
          " 2)  25 A 25 DIAS      ",
          " 3)  40 A 40 DIAS      ",
          " 4)  55 A 55 DIAS      ",*/
          " 1)  AGENDADOS         ",
          " 2)  AGEND. POR DATA   ",
          " 5)  PERIODO LIVRE     ",
          " 4)  PER.LIVRE POR DATA"
          /*
          " 7)  FEITAS NO DIA ",
          " 8)  NAO FEITAS DIA ANTERIOR ",
          " 9)  POR DATA "
          */
          ].
form
    clien.clicod     colon 12 format ">>>>>>>>>9"
    clien.clinom     no-label format    "x(40)"
    clilig.valdivtot           label "Divida"
    clien.ciins      label "Identidade" colon 11
    clien.ciccgc
    with frame fclien row 14 title " Cliente " color white/cyan width 80
                       side-labels.

form clien.clicod format ">>>>>>>>>9"
     clien.clinom no-label format "x(40)"
     clien.endereco[1] label "End"
     clien.fone format "x(15)"
     clien.fax         label "Celular"  at 48
     with frame f-cliente
        width 80 no-box row 3 side-labels color messages.

   assign
      vdiasini = 1
      /*vdiasfin = 0*/ .


repeat with frame f-filtro side-labels  no-box row 3.
    assign esqregua = yes esqpos1  = 1 esqpos2  = 1 recatu1  = ?.
    vetbcod = tetbcod.
    display vetbcod.
    find estrgcobra where estrgcobra.etbcod = vetbcod no-lock no-error.
    vrgccod = if avail estrgcobra
              then estrgcobra.rgccod
              else 1.
    update vetbcod .
    find estab where estab.etbcod = vetbcod no-lock no-error.
    disp if avail estab
         then estab.etbnom
         else "GERAL" @ estab.etbnom no-label.
    if avail estab
    then vrgccod = 0.
    else do on error undo.  
        display vrgccod.
        update vrgccod. 
        if vrgccod <> 0 
        then do: 
            find rgcobra where rgcobra.rgccod = vrgccod no-lock no-error. 
            if not avail rgcobra 
            then do: 
                message "Regiao invalida". 
                undo. 
            end. 
        end. 
    end.    
    display vrgccod.
    
    vvalini = 0. vvalfin = 9999999.
    update vvalini  label "Valor maior que".
/*    update vprofcod label "Profissao".*/

    /*
    def var tmodcod like modal.modcod extent 2
                     init ["GERAL",
                           "CRE"].
    def var tmodnom like modal.modnom extent 2.
    def var x as int.
    do x = 2 to 2.
        find modal where modal.modcod = tmodcod[x] no-lock.
        tmodnom[x] = modal.modnom.
    end.
    
    repeat.
        DISPLAY tmodcod[1] tmodnom[1]  skip 
                tmodcod[2] tmodnom[2]  skip 
                /*
                tmodcod[3] tmodnom[3]  skip 
                tmodcod[4] tmodnom[4]  skip 
                tmodcod[5] tmodnom[5]  skip 
                tmodcod[6] tmodnom[6]  skip 
                tmodcod[7] tmodnom[7]  SKIP
                tmodcod[8] tmodnom[8]  skip
                tmodcod[9] tmodnom[9]  */ 
                
                WITH FRAME Fmmodal 
                        NO-LABEL row 6 
                            title " Modalidades ". 
        CHOOSE field tmodcod auto-return with frame fmmodal .
            
        vmodcod = tmodcod[frame-index].
        leave.
    end.    
    */
/***    
    update vnovos label "Somente Clientes Novos ?" help "Novos ou Todos".
    
    update vcrediario label "Crediario ?" vnovacao label "Novacoes ?".
    vmodcod = "CRE".
***/
    repeat.
    DISPLAY VTIPOS[1] skip 
            vtipos[2] skip 
            vtipos[3] skip 
            vtipos[4] /*skip 
            vtipos[5] skip 
            vtipos[6] skip 
            vtipos[7] SKIP
            vtipos[8]*/ /*skip
            vtipos[9]*/
            WITH FRAME FTIPOS 
                    NO-LABEL row 6 column 40
                        title " Filtros ". 
        CHOOSE field vtipos auto-return with frame ftipos .
        def var ctipos as char.
        
    ctipos = vtipos[frame-index].

    if ctipos = "" 
    then next.
    else leave.
    end.    
    def var vlivre as log.
    def var vdodia as log.
    def var vdiaanterior as log init no.
    
    def var v-faixa-datas as log init no no-undo.
    def var dt-ini        as date format "99/99/9999" no-undo.
    def var dt-fim        as date format "99/99/9999" no-undo.
    
    vdiaanterior = no.
    vlivre = no.
    hide frame ftipos no-pause.
    hide frame f-data-aux no-pause.
    vagendadas = ?.
    esq-periodo = ?.
    vlivre = ?.
    vdodia = no.
    /*
    if frame-index = 1
    then assign vdiasini = 11
                /*vdiasfin = 11 */
                esq-periodo = yes
                vagendadas = no.        
    else
    if frame-index = 2
    then assign vdiasini = 25
                /*vdiasfin = 25 */
                esq-periodo = yes
                vagendadas = no.        
    else
    if frame-index = 3
    then assign vdiasini = 40
                /*vdiasfin = 40 */
                esq-periodo = yes
                vagendadas = no.        
    else
    if frame-index = 4
    then assign vdiasini = 55
                /*vdiasfin = 55 */
                esq-periodo = yes
                vagendadas = no.        
    else */
    if frame-index = 1 or frame-index = 2
    then do:
      if frame-index = 2
      then
        update vdatopc7 validate(vdatopc7 <> ?,"Necessário informar uma data")
               /*vdiasfin*/ with frame ffff2  row 5 side-label
                            no-box .
         assign vdiasini = 0
                /*vdiasfin = 0 */
                esq-periodo = no
                vagendadas   = yes.        
    end.                   
    else
    if frame-index = 3 or frame-index = 4
    then do:
      if frame-index = 3
      then
        update vdiasini validate(vdiasini >= 10,"Atraso maior que 9 dias")
               /*vdiasfin*/ with frame ffff  row 5 side-label
                            no-box .
      else                       
        update vdatopc8ini vdatopc8fin
               /*vdiasfin*/ with frame ffff1  row 5 side-label
                            no-box .
        esq-periodo = yes .
        vlivre = yes.
        vagendadas   = no.
    end.             
    /***
    else
    if frame-index = 7
    then assign vdiasini = ?
                /*vdiasfin = ? */
                vdodia = yes
                vagendadas   = ?.        
    else
    if frame-index = 8
    then assign vdiasini = ?
                /*vdiasfin = ? */
                vdiaanterior = yes
                vagendadas   = ?.        
    ***/           
    if frame-index = 9 /*por faixa de datas*/
    then do:
       assign dt-ini = vtoday
              dt-fim = vtoday.
       
       disp dt-ini label "Data inicial" 
            " a "
            dt-fim label "Data Final"
            with frame f-data-aux.
                  
       update dt-ini 
              dt-fim 
              with frame f-data-aux.
              
       if dt-ini > dt-fim
       then do:
          message "Data Inválida!" view-as alert-box.
          undo.
       end.   
       else do:
       
           assign v-faixa-datas = yes
                  vdiasini      = ?
                  vdatopc8ini   = ?
                  vdatopc8fin   = ?
                  /*vdiasfin      = ?*/
                  vagendadas    = ?
                  vdiaanterior  = ?.
              
           hide frame f-data-aux no-pause.
          
       end.
      
       
    end.      


    def var vdtini as date.
    def var vdtfin as date.
    vdtini = vtoday - vdiasini.
/*    vdtfin = vtoday - vdiasini.*/

recatu1 = ?.
recatu2 = ?.



Form
     esqcom1
     with frame f-com1 row 6 no-box no-labels side-labels column 1.
     
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

def var vqtd as int.
vqtd = 0.
if  esq-periodo   
then  do.
    if vdatopc8ini <> ?
    then
        for each clilig where (if vsetor <> ""
                               then clilig.setor = vsetor
                               else true) and
                              clilig.dtven >= vdatopc8ini and
                              clilig.dtven <= vdatopc8fin and
/*                              clilig.dtacor    = ?      and             */ 

                              (clilig.dtacor    = ? or 
                               clilig.dtacor    < today)  and
                               
                              clilig.DtUltLig  <= vtoday  and                  
                              clilig.titvlcob >= vvalini     and              
                                   (if vetbcod = 0 
                               then true                                      
                               else if clilig.etbcod = 0 and
                                       can-find(first cliletb where
                                     cliletb.clicod = clilig.clicod and
                                     cliletb.etbcod = vetbcod)
                                    then true
                                    else if clilig.etbcod = vetbcod
                                         then true
                                         else false) and                                   (if vrgccod = 0                                                                     then true                                                                 else clilig.rgccod = vrgccod) /*and              
                               (if vmodcod = "GERAL" or vnovacao = yes                                       then true                                      
                                 else clilig.modcod = vmodcod)*/ and
                       (if ((vnovacao = yes and clilig.modcod = "NOV") or
                           (vcrediario = yes and clilig.modcod <> "NOV"))
                                then true
                                else false)
                     and (if vnovos = yes then clilig.tipo = "N" else true)
                                use-index clilig2
                                                     no-lock.                        
            vqtd = vqtd + 1.                                                        end.    
    else 
    for each clilig where (if vsetor <> ""
                               then clilig.setor = vsetor
                               else true) and clilig.dtven    = vdtini  and
/*                                clilig.dtacor    = ?      and*/
                                (clilig.dtacor    = ? or 
                                 clilig.dtacor    < today) and
                                
                                clilig.DtUltLig  <= vtoday  and
                                clilig.titvlcob >= vvalini     and
                                   (if vetbcod = 0 
                               then true                                      
                               else if clilig.etbcod = 0 and
                                       can-find(first cliletb where
                                     cliletb.clicod = clilig.clicod and
                                     cliletb.etbcod = vetbcod)
                                    then true
                                    else if clilig.etbcod = vetbcod
                                         then true
                                         else false) and                                   (if vrgccod = 0                                                                     then true                                                                 else clilig.rgccod = vrgccod) and
                                (if vrgccod = 0
                                 then true
                                 else clilig.rgccod = vrgccod) /*and
                                (if vmodcod = "GERAL"
                                 then true
                                 else clilig.modcod = vmodcod)*/ and
                       (if (
                            (vnovacao = yes and clilig.modcod = "NOV") or
                            (vcrediario = yes and clilig.modcod <> "NOV")
                            )
                        then true
                        else false)
                        and (if vnovos = yes then clilig.tipo = "N" else true)
                                use-index clilig2
                                                no-lock.
        vqtd = vqtd + 1.
    end.
end. 
else  do.
    if vdatopc7 <> ?
    then 
        for each clilig  where  /*clilig.dtacor    >= vdatopc7*/
                                 clilig.dtacor <> ? and
                                (if clilig.modcod = "CRE"
                                 then clilig.dtacor = vdatopc7
                                 else clilig.dtacor >= vdatopc7) /*Lu and 
                                clilig.dtacor    < vtoday Lu*/      and
                                clilig.DtUltLig  <= vtoday  and
                                clilig.titvlcob >= vvalini     and
                                
                                   (if vetbcod = 0 
                               then true                                      
                               else if clilig.etbcod = 0 and
                                       can-find(first cliletb where
                                     cliletb.clicod = clilig.clicod and
                                     cliletb.etbcod = vetbcod)
                                    then true
                                    else if clilig.etbcod = vetbcod
                                         then true
                                         else false) and                                   (if vrgccod = 0                                                                     then true                                                                 else clilig.rgccod = vrgccod) and
                                (if vrgccod = 0
                                 then true
                                 else clilig.rgccod = vrgccod) /*and
                                (if vmodcod = "GERAL"
                                 then true
                                 else clilig.modcod = vmodcod)*/ and
(if ((vnovacao = yes and clilig.modcod = "NOV") or
                           (vcrediario = yes and clilig.modcod <> "NOV"))
                                then true
                                else false)
and (if vnovos = yes then clilig.tipo = "N" else true)                                
                                use-index clilig3
                                                 no-lock.
        vqtd = vqtd + 1.
    end.    
    else
    for each clilig  where 
                                clilig.dtacor    < vtoday      and
                                clilig.DtUltLig  <= vtoday  and
                                clilig.titvlcob >= vvalini     and
                                 (if vetbcod = 0 
                               then true                                      
                               else if clilig.etbcod = 0 and
                                       can-find(first cliletb where
                                     cliletb.clicod = clilig.clicod and
                                     cliletb.etbcod = vetbcod)
                                    then true
                                    else if clilig.etbcod = vetbcod
                                         then true
                                         else false) and                                (if vrgccod = 0
                                 then true
                                 else clilig.rgccod = vrgccod) /*and
                                (if vmodcod = "GERAL"
                                 then true
                                 else clilig.modcod = vmodcod)*/  and
(if ((vnovacao = yes and clilig.modcod = "NOV") or
                           (vcrediario = yes and clilig.modcod <> "NOV"))
                                then true
                                else false)
and (if vnovos = yes then clilig.tipo = "N" else true)                                
                                use-index clilig3
                                                 no-lock.
        vqtd = vqtd + 1.
    end.
end.



vtitle = "Etb=" + string(vetbcod) +
         " Rg="  + string(vrgccod)  +
         " MODAL=" + vmodcod + " " +
                ctipos  + "QDT CLIENTES = " + string(vqtd).

bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find clilig where recid(clilig) = recatu1 no-lock.
    if not available clilig
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.
    else do on endkey undo.
        message "Nenhum registro selecionado neste filtro"
                    view-as alert-box.
        leave.        
    end.

    recatu1 = recid(clilig).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available clilig
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        run frame-a.
        
    end.
    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        if not esqvazio
        then do:
            find clilig where recid(clilig) = recatu1 no-lock.
            find clien where
                    clien.clicod = clilig.clicod no-lock.
            vclicod = clien.clicod.
    
            assign vtelobs = "".
    
            find last clitel where clitel.clicod = clien.clicod
                               no-lock no-error.
            if avail clitel 
            then do:
               find tipcont of clitel no-lock no-error.
               vtelobs[1] = substr(string(clitel.teldat,"99/99/99"),1,5) + " " 
                                +
                            string(clitel.telhor,"HH:MM") + " " + 
                            string(clitel.codcont) + " - " + 
                        (if avail tipcont then tipcont.desccont else "").
               vtelobs[1] = vtelobs[1] + " -OBS:" +  clitel.telobs[1] + " " +
                            clitel.telobs[2] + " "  +  clitel.telobs[3].
            end.
            def var i as int.
            do i = 2 to 4:
               find prev clitel where clitel.clicod = clien.clicod
                               no-lock no-error.
               if avail clitel
               then do:
                  find tipcont of clitel no-lock no-error.
                  vtelobs[i] = substr(string(clitel.teldat,"99/99/99"),1,5) + 
                                " "  +
                               string(clitel.telhor,"HH:MM") + " " + 
                           string(clitel.codcont) + " - " + 
                           (if avail tipcont then tipcont.desccont else "").
                  vtelobs[i] = vtelobs[i] + " -OBS:" + clitel.telobs[1] + 
                            " " +
                           clitel.telobs[2] + " " + clitel.telobs[3].
               end.
            end.
            run p-totais.            
            vtelobs[1] = " Vencido: " 
                       + string(vtotvencido,">>>>,>>9.99") 
                       + "  Parc: " 
                       + string(vparvencido,">>>>9") 
                       + "   Encargos: " 
                       + string(vencvencido,">>>,>>9.99")
                       + "   Geral"
                       + string(vtotvencido + vencvencido,">>>>,>>9.99").
            vtelobs[2] = "A Vencer: "
                       + string(vtotvencer,">>>>,>>9.99")
                       + "  Parc: "
                       + string(vparvencer,">>>>9")
                       + "   Total de Parcelas do Cliente: "
                       + string(vparvencido + vparvencer + vparpagas,">>>>9").
            vtelobs[3] = "T. Geral: "
                       + string(vtotvencido + vtotvencer,">>>>,>>9.99")
                       + "  Parc: "
                       + string(vparvencido + vparvencer,">>>>9")
                       + "   Pagas: "
                       + string(vtotpagas,">>>>,>>9.99")
                       + "   Abertas: "
                       + string(vtotvencido + vtotvencer,">>>>,>>9.99").
            vtelobs[4] = "Vl Pagas: "
                       + string(vtotpagas,">>>>,>>9.99")
                       + "Tot. Juros: "
                       + string(vencpagas,">>>,>>9.99")
                       + "Total Pago: "
                       + string(vtotpagas + vencpagas,">>>>,>>9.99").            
            display vtelobs[1] format "x(78)" skip
                    vtelobs[2] format "x(78)"
                    vtelobs[3] format "x(78)"
                    vtelobs[4] format "x(78)"
                    with frame telobs with row 19
                    no-labels 1 col no-box color messages width 80.
find clien where clien.clicod = clilig.clicod no-lock.
        display clien.clicod 
                clien.clinom 
                clien.fone   clien.fax
                  trim(trim(clien.endereco[1]) + "," + 
                      trim(string(clien.numero[1]))      + " " +
                       trim(clien.compl[1])  + " " +
                       trim(clien.cidade[1]) + " " +
                            clien.ufecod[1] ) @  clien.endereco[1] 
                               
            with frame f-cliente.
            
            
            status default "CONSULTAS: H-Hist.Lig/C-AnaliseCred/T-Telefones/S-SimulaNovacao".
            choose field clilig.clicod help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up  h H c C t T s S
                      tab PF4 F4 ESC return) .

            status default "".

        end.
        if keyfunction(lastkey) = "H" or
           keyfunction(lastkey) = "h"
        then do.
            hide frame f-com1 no-pause. 
            find clien where
                    clien.clicod = clilig.clicod no-lock.
            run bscrclitel.p ( input recid(clien), 
                                  input ?).
            view frame f-com1.
            next bl-princ.
        end.
        if keyfunction(lastkey) = "C" or
           keyfunction(lastkey) = "c"
        then do.
            hide frame f-com1 no-pause. 
            find clien where
                    clien.clicod = clilig.clicod no-lock.
            run hiscli3.p(clien.clicod).                    
            view frame f-com1.
            next bl-princ.
        end.
        if keyfunction(lastkey) = "T" or
           keyfunction(lastkey) = "t"
        then do.
            hide frame f-com1 no-pause. 
            find clien where
                    clien.clicod = clilig.clicod no-lock.
            run resutel1.p(clien.clicod, output p-fone).
            view frame f-com1.
            next bl-princ.
        end.        
        if keyfunction(lastkey) = "S" or
           keyfunction(lastkey) = "s"
        then do.
            hide frame f-com1 no-pause. 
            find clien where
                    clien.clicod = clilig.clicod no-lock.        
            pause 0.
            sretorno = "CLICOD=" + string(clien.clicod).
            run novacao2.p.
            sretorno = "".
            view frame f-com1.
            next bl-princ.
        end.        
        
            if keyfunction(lastkey) = "TAB"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display message esqcom1[esqpos1] with frame f-com1.
                end.
                esqregua = not esqregua.
            end.
            if keyfunction(lastkey) = "cursor-right"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 6 then 6 else esqpos1 + 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    esqpos2 = if esqpos2 = 6 then 6 else esqpos2 + 1.
                end.
                next.
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    esqpos2 = if esqpos2 = 1 then 1 else esqpos2 - 1.
                end.
                next.
            end.
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail clilig
                    then leave.
                    recatu1 = recid(clilig).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail clilig
                    then leave.
                    recatu1 = recid(clilig).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail clilig
                then next.
                color display normal clilig.clicod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail clilig
                then next.
                color display normal clilig.clicod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form clilig
                 with frame f-clilig color black/cyan
                      centered side-label row 5 .
            if esqcom1[esqpos1] <> " Cliente "
            then do:
                clear frame ftitulo all.
                clear frame fpag1 all.
                /*
                hide  frame frame-a no-pause.
                */
            end.

            if esqregua
            then do:
                pause 0.
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.
                pause 0.
                if esqcom1[esqpos1] = " Cliente  "
                then do on error undo:
                    update vclicod
                            with frame fcliented
                                    centered row 10
                                            side-label.
                    find bclien where bclien.clicod = vclicod
                                        no-lock no-error.
                    if avail bclien
                    then do:

                       /***/
                       find clien where clien.clicod = bclien.clicod no-lock.
                       run p-totais. 
vtelobs[1] = " Vencido: " 
                       + string(vtotvencido,">>>>,>>9.99") 
                       + "  Parc: " 
                       + string(vparvencido,">>>>9") 
                       + "   Encargos: " 
                       + string(vencvencido,">>>,>>9.99")
                       + "   Geral"
                       + string(vtotvencido + vencvencido,">>>>,>>9.99").
            vtelobs[2] = "A Vencer: "
                       + string(vtotvencer,">>>>,>>9.99")
                       + "  Parc: "
                       + string(vparvencer,">>>>9")
                       + "   Total de Parcelas do Cliente: "
                       + string(vparvencido + vparvencer + vparpagas,">>>>9").
            vtelobs[3] = "T. Geral: "
                       + string(vtotvencido + vtotvencer,">>>>,>>9.99")
                       + "  Parc: "
                       + string(vparvencido + vparvencer,">>>>9")
                       + "   Pagas: "
                       + string(vtotpagas,">>>>,>>9.99")
                       + "   Abertas: "
                       + string(vtotvencido + vtotvencer,">>>>,>>9.99").
            vtelobs[4] = "Vl Pagas: "
                       + string(vtotpagas,">>>>,>>9.99")
                       + "Tot. Juros: "
                       + string(vencpagas,">>>,>>9.99")
                       + "Total Pago: "
                       + string(vtotpagas + vencpagas,">>>>,>>9.99").                      display vtelobs[1] format "x(78)" skip
                    vtelobs[2] format "x(78)"
                    vtelobs[3] format "x(78)"
                    vtelobs[4] format "x(78)"
                    with frame telobs with row 19
                    no-labels 1 col no-box color messages width 80.            
message vtelobs[1] view-as alert-box.                    
        pause 0.                               
                       /***/
                       
                       
                        /*
                        vtitcod = ?.
                        for first titulo where titulo.titnat = no and
                              titulo.clifor = vclicod and
                              titulo.titdtpag = ? and
                              titulo.titdtven < vtoday
                                        no-lock by titulo.titdtven.
                            vtitcod = titulo.titcod.
                        end.
                        */
                        find clilig where clilig.clicod = vclicod no-lock
                                                    no-error.
                        if not avail clilig
                        then do.
                            message "Nao encontrado.".
                            pause 3 no-message.
                            /***
                            create clilig.
                            clilig.clicod = vclicod.
                            if vsetor <> "" and vsetor <> clilig.setor
                            then do:
                                message "Cliente em " clilig.setor view-as alert-box.
                            end.
                            ***/                            
                        end.
                        find current clilig no-lock.
                        recatu1 = recid(clilig).
                        leave.
                    end.
                    else do.
                        message "Cliente Invalido".
                        pause 3 no-message.
                    end.
                end.
                if esqcom1[esqpos1] = " Arq.SMS "
                then do on error undo:
                
                    for each tt-cel.
                    delete tt-cel.
                    end.

                    run p-arquivosms.
                                        
                    def var varqsai as char.
                    
                    if opsys = "UNIX"
                    then varqsai = "/admcom/relat/celcob-" + string(time)
                                 + ".txt".
                    else  varqsai = "l:~\relat~\celcob-" + string(time) + ".txt".
                    output to value(varqsai) page-size 0.
for each tt-cel:
    put tt-cel.celular format "x(15)" skip.
end.                    
                    output close.
                    message color red/with
                        "Arquivo celulares gerado: "  varqsai 
                        view-as alert-box.                
                
                end.
                
                if esqcom1[esqpos1] = " Dados "
                then do on error undo:
                   hide frame f-com1 no-pause.
                   hide frame telobs no-pause.
                   hide frame frame-a no-pause.
                   pause 0.
                    run clidis.p (input recid(clien)) .         
                    pause 0.
                   view frame frame-a.   pause 0.
                   view frame f-com1.    pause 0.
                   view frame telobs.    pause 0.
                end.
                if esqcom1[esqpos1] = " Simulacao "
                then do on error undo:
                   hide frame f-com1 no-pause.
                   hide frame telobs no-pause.
                   hide frame frame-a no-pause.
                   pause 0.
                    run bsfqtitsim.p (input clien.clicod) .         
                    pause 0.
                   view frame frame-a.   pause 0.
                   view frame f-com1.    pause 0.
                   view frame telobs.    pause 0.
                end.
     
                if esqcom1[esqpos1] = " Relatorio "
                then do with frame fimprime.
varquivo = "./bstelcli." + string(time).
          {mdad_l.i
           &Saida     = "value(varquivo)"
           &Page-Size = "0"
           &Cond-Var  = "150"
           &Page-Line = "66"
           &Nom-Rel   = ""GERAL""
           &Nom-Sis   = """Clientes para Cobrar"""
           &Tit-Rel   = """POSICAO EM "" + string(today) "
           &Width     = "150"
           &Form      = "frame f-cabcab"}
                    run p-relatorio.

                    
    output close.
    if opsys = "UNIX"
    then do:
        run visurel.p (input varquivo, input "").
    end.
    else do:
        {mrod.i}.
    end.
                    
                end.

                if esqcom1[esqpos1] = " Acoes Cob "
                then do on error undo:
                   find clien where clien.clicod = vclicod exclusive
                            no-wait no-error.
                   if not avail clien
                   then do:
                       bell. bell.
                       message "LIGACAO SENDO FEITA POR OUTRO COBRADOR"
                           view-as alert-box.
                   end.
                   else do:
                        hide frame ftitulo no-pause.
                        hide frame frame-a no-pause.
                        hide frame telobs no-pause.

                        /*
                        if not avail cpfis
                        then do on error undo:
                            create cpfis.
                            assign cpfis.clicod = clien.clicod.
                        end.
                        */

                        vendereco =
                           trim(trim(clien.endereco[1]) + "," + 
                           trim(string(clien.numero[1]))      + " " +
                           trim(clien.compl[1])  + " " +
                           trim(clien.cidade[1]) + " " +
                                clien.ufecod[1] ).

/*                        if avail cpfis
                        then vendcom = trim(cpfis.endcom + ","
                            + cpfis.numcob + " - " + cpfis.complcob + " " +
                            cpfis.bairro + " " + cpfis.munic).
                        else*/ /*vendcom = ""*/ .

/*                        if avail cpfis
                        then vconjend = trim(cpfis.conjend /**+ ","
                        + string(cpfis.conjnumero) + " - " +
                          cpfis.conjcomplemento + " "
                          + cpfis.conjbairro + " " + cpfis.conjcidade**/) .

                        if (avail cpfis and cpfis.spcdtin <> ? and
                           cpfis.spcdtin >= cpfis.spcdtfi) or
                           (cpfis.spcdtfi = ? and cpfis.spcdtin <> ?)
                        then vspc = yes.
                        else vspc = no.
                         */
             /***************tela nova para telefornar*************/

                     disp clien.clicod format ">>>>>>>>>9"
                             clien.clinom no-label format "x(30)"
                             /*cpfis.mtbcod label "Sit. C/C"*/
                             /*cpfis.sitspc label "SPC"*/
                             vspc label "SPC"
                             /*cpfis.assecod label "Asses."*/
                                    with frame f-cliente2
                            width 80 no-box row 4 side-labels color 
messages.               
                         vdescricao = " ".

                        disp vendereco          label "End."  skip
                             clien.fone format "x(15)" label "Telefone"
                             clien.fax          label "Celular"
                             /*cpfis.fonepes      label "Tl.Res"*/
/*                             cpfis.estado-fone label "Tipo"*/
                             vdescricao no-label
                             with frame f-res side-labels
                             width 80 row 5 overlay no-box.

                        run bscrclitel.p ( input recid(clien),
                                         input recid(clilig)).
                        find last clitel where 
                                clitel.clicod = clilig.clicod 
                                    no-lock no-error.
                        if avail clitel and
                           cliTEL.teldat = vtoday
                        then do:
                            find clilig where recid(clilig) = recatu1.
                            recatu1 = ?.
                            clilig.dtultlig = today.
                            clilig.dtacor = clitel.dtpagcont.
                            /*
                            if time - ini-time > 7200 
                            then do.
                                /*
                                hide message no-pause.
                                message "Arquivo de Ligacoes feitas a mais de"
                                            string(time - ini-time,"HH:MM:SS")
                                        ". Refazendo Arquivo para ligacoes".    
                                pause 4 no-message.
                                run cria-tt.   
                                hide message no-pause.
                                */
                            end.
                            */
                            find current clilig no-lock.
                            recatu1 = ?. 
                            leave.
                        end.
                    end.
                    recatu1 = ?.
                    leave.
                end.


            end.
            else do:
            end.
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(clilig).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame f-com2  no-pause.
hide frame frame-a no-pause.
end.

procedure frame-a.

    /*
    vdivida = 0.
    for each titulo where titulo.titnat = no and
                          
                          titulo.clifor = clilig.clicod and
                          titulo.modcod  = "CRE" and
                          titulo.titsit = "LIB" and
                          titulo.titdtven < vtoday
                    no-lock.
        vdivida = vdivida + titulo.titvlcob - titulo.titvlpag.
    end.
    */
    
    vnumdias = vtoday - clilig.dtven.
    if vnumdias < 0
    then vnumdias = 0.

    find last clitel where clitel.clicod = clilig.clicod /*and
               clitel.teldat > clilig.dtven and
              (clitel.dtpagcont < vtoday or clitel.dtpagcont = ?)*/
                 no-lock no-error.

    def var vdlig as int format "->>>9".
    vdlig = 0.
    vdatahora = "".
    def var vdataprom as date.
    vdataprom = ?.
    if avail clitel then do:
       vdatahora = (if cliTEL.teldat = vtoday
                   then "  HOJE  "
                   else string(clitel.teldat,"99/99/99")) + " " + 
                   string(clitel.telhor,"HH:MM").
        vdlig = vtoday - clitel.teldat.
        vdataprom = clitel.dtpagcont.
    end.
    def buffer bclitel for clitel.
    for each bclitel of clilig where bclitel.dtpagcont  <> ? no-lock.
         
         vdataprom = bclitel.dtpagcont.  
    end.
    
    vdataprom = clilig.dtacor.
    
    /*** Media Atraso ***/
    
def var vcontrpar as int. /* controla as ultimas 10 parcelas */                
def var vmaioratraso as int.                                                  
def var vmediaatraso as dec.

def var vatraso as dec.
vcontrpar = 0.                                                                 ~vmaioratraso = 0.                                                               
for each fin.titulo where fin.titulo.titnat = no
                  and fin.titulo.titdtpag <> ?
                  and fin.titulo.clifor = clien.clicod
                  and fin.titulo.titsit = "PAG"
                  and fin.titulo.modcod =  "CRE"  /*Claudir*/
                  /*and fin.titulo.moecod <> "DEV" */
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

vmediaatraso = vmaioratraso / vcontrpar.
if vmediaatraso < 0
then vmediaatraso = 0.
    
    /***/
    
                
    find func of clitel no-lock no-error.
    find clien of clilig no-lock no-error.
    vnumdias = vtoday - clilig.dtven.
    if vnumdias < 0
    then vnumdias = 0.
    display
       clilig.clicod column-label "Conta" format ">>>>>>>>>9"
       clilig.dtven format "99/99/99"   column-label "Maior!Atraso"
       vnumdias
       vmediaatraso format "->>9" column-label "MA"
       clilig.valdivtot column-label "Sld Aberto" format ">>,>>9.99"
       clitel.funcod when avail clitel column-label "- UL!Func."
                     format ">>>>>9"
       func.funnom   when avail func   column-label "TIMA L!Nome" 
                     format "x(6)"
       vdatahora  column-label "I G A C A O -! Data  Hora" format "x(14)"
       vdataprom   column-label "Promessa" when vdataprom <> ?
          with frame frame-a 7 down centered
            row 7 title vtitle.
find clien where clien.clicod = clilig.clicod no-lock.
        display clien.clicod 
                clien.clinom 
                clien.fone   clien.fax
                  trim(trim(clien.endereco[1]) + "," + 
                      trim(string(clien.numero[1]))      + " " +
                       trim(clien.compl[1])  + " " +
                       trim(clien.cidade[1]) + " " +
                            clien.ufecod[1] ) @  clien.endereco[1] 
                               
            with frame f-cliente.

end procedure.


procedure frame-asss.
display clilig.clicod 
        dtven
        with frame frame-asss 11 down centered color white/red row 5.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.

if par-tipo = "pri" 
then  
    if esq-periodo  
    then  
        if vdatopc8ini <> ?
        then
        find first clilig where (if vsetor <> ""
                               then clilig.setor = vsetor
                               else true) and clilig.dtven    >= vdatopc8ini and
                                clilig.dtven    <= vdatopc8fin and
                                /*clilig.dtacor    = ?      and*/
                                (clilig.dtacor    = ? or 
                                 clilig.dtacor    < today) and
                                
                                clilig.DtUltLig  <= vtoday  and
                                clilig.titvlcob >= vvalini     and
                                
                                (if vetbcod = 0 
                               then true                                      
                               else if clilig.etbcod = 0 and
                                       can-find(first cliletb where
                                     cliletb.clicod = clilig.clicod and
                                     cliletb.etbcod = vetbcod)
                                    then true
                                    else if clilig.etbcod = vetbcod
                                         then true
                                         else false) and                                (if vrgccod = 0
                                 then true
                                 else clilig.rgccod = vrgccod) /*and
                                (if vmodcod = "GERAL"
                                 then true
                                 else clilig.modcod = vmodcod)*/  and
                                 (if ((vnovacao = yes and clilig.modcod = "NOV") or
                           (vcrediario = yes and clilig.modcod <> "NOV"))
                                then true
                                else false)
and (if vnovos = yes then clilig.tipo = "N" else true)                                
                                use-index clilig2
                                                no-lock no-error.
    else 
        find first clilig where (if vsetor <> ""
                               then clilig.setor = vsetor
                               else true) and clilig.dtven    = vdtini  and
                                /*clilig.dtacor    = ?      and*/

                                (clilig.dtacor    = ? or 
                                 clilig.dtacor    < today) and
                                
                                clilig.DtUltLig  <= vtoday  and
                                clilig.titvlcob >= vvalini     and
                                
       (if vetbcod = 0 
                               then true                                      
                               else if clilig.etbcod = 0 and
                                       can-find(first cliletb where
                                     cliletb.clicod = clilig.clicod and
                                     cliletb.etbcod = vetbcod)
                                    then true
                                    else if clilig.etbcod = vetbcod
                                         then true
                                         else false) and
                                                (if vrgccod = 0
                                 then true
                                 else clilig.rgccod = vrgccod) /*and
                                (if vmodcod = "GERAL"
                                 then true
                                 else clilig.modcod = vmodcod)*/  and
(if ((vnovacao = yes and clilig.modcod = "NOV") or
                           (vcrediario = yes and clilig.modcod <> "NOV"))
                                then true
                                else false)                                
and (if vnovos = yes then clilig.tipo = "N" else true)                                
                                use-index clilig2
                                                no-lock no-error.                                                    

    else 
      if vdatopc7 <> ?
      then
            find last clilig  where (if vsetor <> ""
                               then clilig.setor = vsetor
                               else true) and /*clilig.dtacor    >= vdatopc7*/
                                 clilig.dtacor <> ? and
                                (if clilig.modcod = "CRE"
                                 then clilig.dtacor = vdatopc7
                                 else clilig.dtacor >= vdatopc7) /*Luand
                                clilig.dtacor    <= vtoday - 1Lu*/     
                                /***and
                                clilig.DtUltLig  < vtoday***/  and
                                clilig.titvlcob >= vvalini     and
                                
                                (if vetbcod = 0 
                               then true                                      
                               else if clilig.etbcod = 0 and
                                       can-find(first cliletb where
                                     cliletb.clicod = clilig.clicod and
                                     cliletb.etbcod = vetbcod)
                                    then true
                                    else if clilig.etbcod = vetbcod
                                         then true
                                         else false) and                                (if vrgccod = 0
                                 then true
                                 else clilig.rgccod = vrgccod) /*and
                                (if vmodcod = "GERAL"
                                 then true
                                 else clilig.modcod = vmodcod)*/  and
(if ((vnovacao = yes and clilig.modcod = "NOV") or
                           (vcrediario = yes and clilig.modcod <> "NOV"))
                                then true
                                else false)                                
and (if vnovos = yes then clilig.tipo = "N" else true)                                
                                use-index clilig3
                                                 no-lock no-error.      
      else
        find last clilig  where (if vsetor <> ""
                               then clilig.setor = vsetor
                               else true) and
                                clilig.dtacor    <= vtoday - 1     and
                                clilig.DtUltLig  <= vtoday  and
                                clilig.titvlcob >= vvalini     and
                                
                                (if vetbcod = 0 
                               then true                                      
                               else if clilig.etbcod = 0 and
                                       can-find(first cliletb where
                                     cliletb.clicod = clilig.clicod and
                                     cliletb.etbcod = vetbcod)
                                    then true
                                    else if clilig.etbcod = vetbcod
                                         then true
                                         else false) and                                (if vrgccod = 0
                                 then true
                                 else clilig.rgccod = vrgccod) /*and
                                (if vmodcod = "GERAL"
                                 then true
                                 else clilig.modcod = vmodcod)*/ and
(if ((vnovacao = yes and clilig.modcod = "NOV") or
                           (vcrediario = yes and clilig.modcod <> "NOV"))
                                then true
                                else false)                                
and (if vnovos = yes then clilig.tipo = "N" else true)                                
                                use-index clilig3
                                                 no-lock no-error.
                                             



if par-tipo = "seg" or par-tipo = "down" 
then  
    if esq-periodo  
    then  
        if vdatopc8ini <> ?
        then 
        find next clilig  where  (if vsetor <> ""
                               then clilig.setor = vsetor
                               else true) and clilig.dtven    >= vdatopc8ini and
                                 clilig.dtven <= vdatopc8fin and
                                
                                /*clilig.dtacor    = ?      and*/

                                (clilig.dtacor    = ? or 
                                 clilig.dtacor    < today) and
                                
                                
                                clilig.DtUltLig  <= vtoday  and
                                clilig.titvlcob >= vvalini     and
                                (if vetbcod = 0 
                               then true                                      
                               else if clilig.etbcod = 0 and
                                       can-find(first cliletb where
                                     cliletb.clicod = clilig.clicod and
                                     cliletb.etbcod = vetbcod)
                                    then true
                                    else if clilig.etbcod = vetbcod
                                         then true
                                         else false) and                                (if vrgccod = 0
                                 then true
                                 else clilig.rgccod = vrgccod) /*and
                                (if vmodcod = "GERAL"
                                 then true
                                 else clilig.modcod = vmodcod)*/  and
(if ((vnovacao = yes and clilig.modcod = "NOV") or
                           (vcrediario = yes and clilig.modcod <> "NOV"))
                                then true
                                else false)
and (if vnovos = yes then clilig.tipo = "N" else true)                                
                                use-index clilig2
                                                no-lock no-error.
        else                                                        
        find next clilig  where  (if vsetor <> ""
                               then clilig.setor = vsetor
                               else true) and clilig.dtven    = vdtini and 

                                /*clilig.dtacor    = ?      and*/
                                (clilig.dtacor    = ? or 
                                 clilig.dtacor    < today) and
                                
                                clilig.DtUltLig  <= vtoday  and
                                clilig.titvlcob >= vvalini     and
                                (if vetbcod = 0 
                               then true                                      
                               else if clilig.etbcod = 0 and
                                       can-find(first cliletb where
                                     cliletb.clicod = clilig.clicod and
                                     cliletb.etbcod = vetbcod)
                                    then true
                                    else if clilig.etbcod = vetbcod
                                         then true
                                         else false) and                                (if vrgccod = 0
                                 then true
                                 else clilig.rgccod = vrgccod) /*and
                                (if vmodcod = "GERAL"
                                 then true
                                 else clilig.modcod = vmodcod)*/  and
(if ((vnovacao = yes and clilig.modcod = "NOV") or
                           (vcrediario = yes and clilig.modcod <> "NOV"))
                                then true
                                else false)
and (if vnovos = yes then clilig.tipo = "N" else true)                                
                                use-index clilig2
                                                no-lock no-error.
    else  
      if vdatopc7 <> ?
      then 
        find prev clilig  where (if vsetor <> ""
                               then clilig.setor = vsetor
                               else true) and /*clilig.dtacor    >= vdatopc7*/
                                 clilig.dtacor <> ? and
                                (if clilig.modcod = "CRE"
                                 then clilig.dtacor = vdatopc7
                                 else clilig.dtacor >= vdatopc7) /*Luand
                                clilig.dtacor    <= vtoday - 1Lu*/     
                                /***and
                                clilig.DtUltLig  < vtoday***/  and
                                clilig.titvlcob >= vvalini     and
                                (if vetbcod = 0 
                               then true                                      
                               else if clilig.etbcod = 0 and
                                       can-find(first cliletb where
                                     cliletb.clicod = clilig.clicod and
                                     cliletb.etbcod = vetbcod)
                                    then true
                                    else if clilig.etbcod = vetbcod
                                         then true
                                         else false) and                                (if vrgccod = 0
                                 then true
                                 else clilig.rgccod = vrgccod) /*and
                                (if vmodcod = "GERAL"
                                 then true
                                 else clilig.modcod = vmodcod)*/  and
(if ((vnovacao = yes and clilig.modcod = "NOV") or
                           (vcrediario = yes and clilig.modcod <> "NOV"))
                                then true
                                else false)                                
and (if vnovos = yes then clilig.tipo = "N" else true)                                
                                use-index clilig3
                                                no-lock no-error.
      else
        find prev clilig    where (if vsetor <> ""
                               then clilig.setor = vsetor
                               else true) and clilig.dtacor    <= vtoday - 1     and
                                clilig.DtUltLig  <= vtoday  and
                                clilig.titvlcob >= vvalini     and

                                (if vetbcod = 0 
                               then true                                      
                               else if clilig.etbcod = 0 and
                                       can-find(first cliletb where
                                     cliletb.clicod = clilig.clicod and
                                     cliletb.etbcod = vetbcod)
                                    then true
                                    else if clilig.etbcod = vetbcod
                                         then true
                                         else false) and
                                (if vrgccod = 0
                                 then true
                                 else clilig.rgccod = vrgccod) /*and
                                (if vmodcod = "GERAL"
                                 then true
                                 else clilig.modcod = vmodcod)*/  and
(if ((vnovacao = yes and clilig.modcod = "NOV") or
                           (vcrediario = yes and clilig.modcod <> "NOV"))
                                then true
                                else false)                                
and (if vnovos = yes then clilig.tipo = "N" else true)                                
                                use-index clilig3
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esq-periodo   
    then   
    if vdatopc8ini <> ?
    then 
                   find prev clilig where (if vsetor <> ""
                               then clilig.setor = vsetor
                               else true) and
                                 clilig.dtven  >= vdatopc8ini
                                      and clilig.dtven <= vdatopc8fin and
                                
                                /*clilig.dtacor    = ?      and*/
                                
                                (clilig.dtacor    = ? or 
                                 clilig.dtacor    < today) and
                                
                                
                                clilig.DtUltLig  <= vtoday  and
                                clilig.titvlcob >= vvalini     and
                                (if vetbcod = 0 
                               then true                                      
                               else if clilig.etbcod = 0 and
                                       can-find(first cliletb where
                                     cliletb.clicod = clilig.clicod and
                                     cliletb.etbcod = vetbcod)
                                    then true
                                    else if clilig.etbcod = vetbcod
                                         then true
                                         else false) and                                (if vrgccod = 0
                                 then true
                                 else clilig.rgccod = vrgccod) /*and
                                (if vmodcod = "GERAL"
                                 then true
                                 else clilig.modcod = vmodcod)*/  and
(if ((vnovacao = yes and clilig.modcod = "NOV") or
                           (vcrediario = yes and clilig.modcod <> "NOV"))
                                then true
                                else false)
and (if vnovos = yes then clilig.tipo = "N" else true)                                
                                use-index clilig2  
                                        no-lock no-error.
    else                                         
        find prev clilig where (if vsetor <> ""
                               then clilig.setor = vsetor
                               else true) and  clilig.dtven    = vdtini and 

                                /*clilig.dtacor    = ?      and*/
                                
                                (clilig.dtacor    = ? or 
                                 clilig.dtacor    < today) and
                                 
                                clilig.DtUltLig  <= vtoday  and
                                clilig.titvlcob >= vvalini     and
                                (if vetbcod = 0 
                               then true                                      
                               else if clilig.etbcod = 0 and
                                       can-find(first cliletb where
                                     cliletb.clicod = clilig.clicod and
                                     cliletb.etbcod = vetbcod)
                                    then true
                                    else if clilig.etbcod = vetbcod
                                         then true
                                         else false) and                                (if vrgccod = 0
                                 then true
                                 else clilig.rgccod = vrgccod) /*and
                                (if vmodcod = "GERAL"
                                 then true
                                 else clilig.modcod = vmodcod)*/  and
(if ((vnovacao = yes and clilig.modcod = "NOV") or
                           (vcrediario = yes and clilig.modcod <> "NOV"))
                                then true
                                else false)
and (if vnovos = yes then clilig.tipo = "N" else true)                                
                                use-index clilig2  
                                        no-lock no-error.
    else   
      if vdatopc7 <> ?
      then
        find next clilig where  (if vsetor <> ""
                               then clilig.setor = vsetor
                               else true) and /*clilig.dtacor    >= vdatopc7*/
                                 clilig.dtacor <> ? and
                                (if clilig.modcod = "CRE"
                                 then clilig.dtacor = vdatopc7
                                 else clilig.dtacor >= vdatopc7) /*Luand
                                clilig.dtacor    <= vtoday - 1Lu*/       
                                /***and
                                clilig.DtUltLig  < vtoday***/  and
                                clilig.titvlcob >= vvalini     and
                                
                                (if vetbcod = 0 
                               then true                                      
                               else if clilig.etbcod = 0 and
                                       can-find(first cliletb where
                                     cliletb.clicod = clilig.clicod and
                                     cliletb.etbcod = vetbcod)
                                    then true
                                    else if clilig.etbcod = vetbcod
                                         then true
                                         else false) and                                (if vrgccod = 0
                                 then true
                                 else clilig.rgccod = vrgccod) /*and
                                (if vmodcod = "GERAL"
                                 then true
                                 else clilig.modcod = vmodcod)*/  and
(if ((vnovacao = yes and clilig.modcod = "NOV") or
                           (vcrediario = yes and clilig.modcod <> "NOV"))
                                then true
                                else false)                                
and (if vnovos = yes then clilig.tipo = "N" else true)                                
                                use-index clilig3 
                                        no-lock no-error.      
      else
        find next clilig where (if vsetor <> ""
                               then clilig.setor = vsetor
                               else true) and  clilig.dtacor    <= vtoday - 1      and
                                clilig.DtUltLig  <= vtoday  and
                                clilig.titvlcob >= vvalini     and
                                
                                (if vetbcod = 0 
                               then true                                      
                               else if clilig.etbcod = 0 and
                                       can-find(first cliletb where
                                     cliletb.clicod = clilig.clicod and
                                     cliletb.etbcod = vetbcod)
                                    then true
                                    else if clilig.etbcod = vetbcod
                                         then true
                                         else false) and                                (if vrgccod = 0
                                 then true
                                 else clilig.rgccod = vrgccod) /*and
                                (if vmodcod = "GERAL"
                                 then true
                                 else clilig.modcod = vmodcod)*/  and
(if ((vnovacao = yes and clilig.modcod = "NOV") or
                           (vcrediario = yes and clilig.modcod <> "NOV"))
                                then true
                                else false)                                
and (if vnovos = yes then clilig.tipo = "N" else true)                                
                                use-index clilig3 
                                        no-lock no-error.
        
end procedure.

procedure p-relatorio.
    if esq-periodo  
    then do: 
        if vdatopc8ini <> ?
        then do:
        for each clilig  where (if vsetor <> ""
                               then clilig.setor = vsetor
                               else true) and clilig.dtven    >= vdatopc8ini and
                                 clilig.dtven <= vdatopc8fin and

                                /*clilig.dtacor    = ?      and*/
                                
                                (clilig.dtacor    = ? or 
                                 clilig.dtacor    < today) and
                                
                                clilig.DtUltLig  <= vtoday  and
                                clilig.titvlcob >= vvalini     and
                                (if vetbcod = 0 
                               then true                                      
                               else if clilig.etbcod = 0 and
                                       can-find(first cliletb where
                                     cliletb.clicod = clilig.clicod and
                                     cliletb.etbcod = vetbcod)
                                    then true
                                    else if clilig.etbcod = vetbcod
                                         then true
                                         else false) and                                (if vrgccod = 0
                                 then true
                                 else clilig.rgccod = vrgccod) /*and
                                (if vmodcod = "GERAL"
                                 then true
                                 else clilig.modcod = vmodcod)*/ and
(if ((vnovacao = yes and clilig.modcod = "NOV") or
                           (vcrediario = yes and clilig.modcod <> "NOV"))
                                then true
                                else false)
and (if vnovos = yes then clilig.tipo = "N" else true)                                
                                use-index clilig2 no-lock.
            run p-imprime.
        end. /* for each */
        end.
        else do:                                                        
        for each  clilig  where (if vsetor <> ""
                               then clilig.setor = vsetor
                               else true) and clilig.dtven    = vdtini and 

                                /*clilig.dtacor    = ?      and*/
                                
                                (clilig.dtacor    = ? or 
                                 clilig.dtacor    < today) and
                                 
                                clilig.DtUltLig  <= vtoday  and
                                clilig.titvlcob >= vvalini     and
                                (if vetbcod = 0 
                               then true                                      
                               else if clilig.etbcod = 0 and
                                       can-find(first cliletb where
                                     cliletb.clicod = clilig.clicod and
                                     cliletb.etbcod = vetbcod)
                                    then true
                                    else if clilig.etbcod = vetbcod
                                         then true
                                         else false) and                                (if vrgccod = 0
                                 then true
                                 else clilig.rgccod = vrgccod) /*and
                                (if vmodcod = "GERAL"
                                 then true
                                 else clilig.modcod = vmodcod)*/ and
(if ((vnovacao = yes and clilig.modcod = "NOV") or
                           (vcrediario = yes and clilig.modcod <> "NOV"))
                                then true
                                else false)
and (if vnovos = yes then clilig.tipo = "N" else true)                                
                                 no-lock.
            run p-imprime.
        end.                                 
        end.
    end.        
    else do:  
      if vdatopc7 <> ?
      then do:
        for each clilig  where (if vsetor <> ""
                               then clilig.setor = vsetor
                               else true) and /*clilig.dtacor    >= vdatopc7*/
                                 clilig.dtacor <> ? and
                                (if clilig.modcod = "CRE"
                                 then clilig.dtacor = vdatopc7
                                 else clilig.dtacor >= vdatopc7) /*and
                                clilig.dtacor    <= vtoday - 1*/    /***
                                 and
                                clilig.DtUltLig  < vtoday ***/ and
                                clilig.titvlcob >= vvalini     and
                                (if vetbcod = 0 
                               then true                                      
                               else if clilig.etbcod = 0 and
                                       can-find(first cliletb where
                                     cliletb.clicod = clilig.clicod and
                                     cliletb.etbcod = vetbcod)
                                    then true
                                    else if clilig.etbcod = vetbcod
                                         then true
                                         else false) and                                (if vrgccod = 0
                                 then true
                                 else clilig.rgccod = vrgccod) /*and
                                (if vmodcod = "GERAL"
                                 then true
                                 else clilig.modcod = vmodcod)*/ and
(if ((vnovacao = yes and clilig.modcod = "NOV") or
                           (vcrediario = yes and clilig.modcod <> "NOV"))
                                then true
                                else false)
and (if vnovos = yes then clilig.tipo = "N" else true)                                                            no-lock.
            run p-imprime.
        end.
     end.                                         
      else do:
        for each clilig   where (if vsetor <> ""
                               then clilig.setor = vsetor
                               else true) and clilig.dtacor    <= vtoday - 1     and
                                clilig.DtUltLig  <= vtoday  and
                                clilig.titvlcob >= vvalini     and
                                (if vetbcod = 0 
                               then true                                      
                               else if clilig.etbcod = 0 and
                                       can-find(first cliletb where
                                     cliletb.clicod = clilig.clicod and
                                     cliletb.etbcod = vetbcod)
                                    then true
                                    else if clilig.etbcod = vetbcod
                                         then true
                                         else false) and                                (if vrgccod = 0
                                 then true
                                 else clilig.rgccod = vrgccod) /*and
                                (if vmodcod = "GERAL"
                                 then true
                                 else clilig.modcod = vmodcod)*/ and
(if ((vnovacao = yes and clilig.modcod = "NOV") or
                           (vcrediario = yes and clilig.modcod <> "NOV"))
                                then true
                                else false)
and (if vnovos = yes then clilig.tipo = "N" else true)                                
                                use-index clilig3 no-lock.
            run p-imprime.                                
        end.
    end.                                        
    end.
end procedure.

procedure p-imprime.

    /*
    vdivida = 0.
    for each titulo where titulo.titnat = no and
                          
                          titulo.clifor = clilig.clicod and
                          titulo.modcod  = "CRE" and
                          titulo.titsit = "LIB" and
                          titulo.titdtven < vtoday
                    no-lock.
        vdivida = vdivida + titulo.titvlcob - titulo.titvlpag.
    end.
    */
    
    vnumdias = vtoday - clilig.dtven.
    if vnumdias < 0
    then vnumdias = 0.

    find last clitel where clitel.clicod = clilig.clicod /*and
               clitel.teldat > clilig.dtven and
              (clitel.dtpagcont < vtoday or clitel.dtpagcont = ?)*/
                 no-lock no-error.

    def var vdlig as int format "->>>9".
    vdlig = 0.
    vdatahora = "".
    def var vdataprom as date.
    vdataprom = ?.
    if avail clitel then do:
       vdatahora = (if cliTEL.teldat = vtoday
                   then "  HOJE  "
                   else string(clitel.teldat,"99/99/99")) + " " + 
                   string(clitel.telhor,"HH:MM").
        vdlig = vtoday - clitel.teldat.
        vdataprom = clitel.dtpagcont.
    end.
    def buffer bclitel for clitel.
    for each bclitel of clilig where bclitel.dtpagcont  <> ? no-lock.
         
         vdataprom = bclitel.dtpagcont.  
    end.
                
    find func of clitel no-lock no-error.
    find clien of clilig no-lock no-error.
    vnumdias = vtoday - clilig.dtven.
    if vnumdias < 0
    then vnumdias = 0.    
    display
       clilig.clicod column-label "Conta" format ">>>>>>>>>>>9"
       clilig.dtven format "99/99/9999"   column-label "Maior!Atraso"
       vnumdias
       clilig.valdivtot column-label "Sld Aberto" format "->>>,>>9.99"
       clitel.funcod when avail clitel column-label "- U L!Func."
                     format ">>>>>9"
       func.funnom   when avail func   column-label "T I M A  L!Nome" 
                     format "x(6)"
       vdatahora  column-label "I G A C A O -! Data  Hora" format "x(14)"
       vdataprom   column-label "Promessa" when vdataprom <> ?
          with frame fimprime 7 down centered
            row 7 title vtitle.
            down with frame fimprime.            

end procedure.

procedure p-arquivosms.
    if esq-periodo  
    then do: 
        if vdatopc8ini <> ?
        then do:
        for each celclilig  where (if vsetor <> ""
                               then celclilig.setor = vsetor
                               else true) and celclilig.dtven    >= vdatopc8ini and
                                 celclilig.dtven <= vdatopc8fin and
                                
                                /*celclilig.dtacor    = ?      and*/
                                (celclilig.dtacor    = ? or 
                                 celclilig.dtacor    < today) and
                                
                                
                                celclilig.DtUltLig  <= vtoday  and
                                celclilig.titvlcob >= vvalini     and
                                (if vetbcod = 0 
                               then true                                      
                               else if celclilig.etbcod = 0 and
                                       can-find(first cliletb where
                                     cliletb.clicod = celclilig.clicod and
                                     cliletb.etbcod = vetbcod)
                                    then true
                                    else if celclilig.etbcod = vetbcod
                                         then true
                                         else false) and                                (if vrgccod = 0
                                 then true
                                 else celclilig.rgccod = vrgccod) /*and
                                (if vmodcod = "GERAL"
                                 then true
                                 else celclilig.modcod = vmodcod)*/ and
(if ((vnovacao = yes and clilig.modcod = "NOV") or
                           (vcrediario = yes and clilig.modcod <> "NOV"))
                                then true
                                else false)
and (if vnovos = yes then clilig.tipo = "N" else true)
                                use-index clilig2 no-lock.

            run val-celular.
        end. /* for each */
        end.
        else do:                                                        
        for each  celclilig  where (if vsetor <> ""
                               then celclilig.setor = vsetor
                               else true) and celclilig.dtven    = vdtini and 

                                /*celclilig.dtacor    = ?      and*/
                                
                                (celclilig.dtacor    = ? or 
                                 celclilig.dtacor    < today) and
                                
                                celclilig.DtUltLig  <= vtoday  and
                                celclilig.titvlcob >= vvalini     and
(if vetbcod = 0 
                               then true                                      
                               else if celclilig.etbcod = 0 and
                                       can-find(first cliletb where
                                     cliletb.clicod = celclilig.clicod and
                                     cliletb.etbcod = vetbcod)
                                    then true
                                    else if celclilig.etbcod = vetbcod
                                         then true
                                         else false) and
                                (if vrgccod = 0
                                 then true
                                 else celclilig.rgccod = vrgccod) /*and
                                (if vmodcod = "GERAL"
                                 then true
                                 else celclilig.modcod = vmodcod)*/ and
(if ((vnovacao = yes and clilig.modcod = "NOV") or
                           (vcrediario = yes and clilig.modcod <> "NOV"))
                                then true
                                else false)
and (if vnovos = yes then clilig.tipo = "N" else true)                                
                                 no-lock.
            run val-celular.
        end.                                 
        end.
    end.        
    else do:  
      if vdatopc7 <> ?
      then do:
        for each celclilig  where (if vsetor <> ""
                               then celclilig.setor = vsetor
                               else true) and /*clilig.dtacor    >= vdatopc7*/
                                 celclilig.dtacor <> ? and
                                (if celclilig.modcod = "CRE"
                                 then celclilig.dtacor = vdatopc7
                                 else celclilig.dtacor >= vdatopc7) /*and
                                celclilig.dtacor    <= vtoday - 1*/     
                                /***and
                                celclilig.DtUltLig  < vtoday***/  and
                                celclilig.titvlcob >= vvalini     and
                                (if vetbcod = 0 
                               then true                                      
                               else if celclilig.etbcod = 0 and
                                       can-find(first cliletb where
                                     cliletb.clicod = celclilig.clicod and
                                     cliletb.etbcod = vetbcod)
                                    then true
                                    else if celclilig.etbcod = vetbcod
                                         then true
                                         else false) and                                (if vrgccod = 0
                                 then true
                                 else celclilig.rgccod = vrgccod) /*and
                                (if vmodcod = "GERAL"
                                 then true
                                 else celclilig.modcod = vmodcod)*/ and
(if ((vnovacao = yes and clilig.modcod = "NOV") or
                           (vcrediario = yes and clilig.modcod <> "NOV"))
                                then true
                                else false)
and (if vnovos = yes then clilig.tipo = "N" else true)                                
                                 no-lock.
            run val-celular.
        end.
     end.                                         
      else do:
        for each celclilig   where  (if vsetor <> ""
                               then celclilig.setor = vsetor
                               else true) and celclilig.dtacor    <= vtoday - 1     and
                                celclilig.DtUltLig  <= vtoday  and
                                celclilig.titvlcob >= vvalini     and
(if vetbcod = 0 
                               then true                                      
                               else if celclilig.etbcod = 0 and
                                       can-find(first cliletb where
                                     cliletb.clicod = celclilig.clicod and
                                     cliletb.etbcod = vetbcod)
                                    then true
                                    else if celclilig.etbcod = vetbcod
                                         then true
                                         else false) and
                                (if vrgccod = 0
                                 then true
                                 else celclilig.rgccod = vrgccod) /*and
                                (if vmodcod = "GERAL"
                                 then true
                                 else celclilig.modcod = vmodcod)*/ and
(if ((vnovacao = yes and clilig.modcod = "NOV") or
                           (vcrediario = yes and clilig.modcod <> "NOV"))
                                then true
                                else false)                                 
and (if vnovos = yes then clilig.tipo = "N" else true)
                                use-index clilig3 no-lock.
            run val-celular.
        end.
    end.                                        
    end.
end procedure.

procedure val-celular:
    def var vcelular as char.
    vcelular = "".
    find clien where clien.clicod = celclilig.clicod no-lock.
    
    if substr(clien.fax,1,1) = "1" or
       substr(clien.fax,1,1) = "2" or
       substr(clien.fax,1,1) = "3" or
       substr(clien.fax,1,1) = "4" or
       substr(clien.fax,1,1) = "5" or
       substr(clien.fax,1,1) = "6" or
       substr(clien.fax,1,1) = "7" or
       substr(clien.fax,1,1) = "8" or
       substr(clien.fax,1,1) = "9" or
       substr(clien.fax,1,1) = "0"
    then do:
        if length(clien.fax) <= 10
        then do:
            if length(clien.fax) = 10
            then vcelular = clien.fax.
            else do:
                vcelular = "51" + clien.fax.
                if length(vcelular) <> 10
                then vcelular = "".
            end.
        end.        
        if substr(vcelular,3,2) <> "81" and
           substr(vcelular,3,2) <> "82" and
           substr(vcelular,3,2) <> "83" and
           substr(vcelular,3,2) <> "84" and
           substr(vcelular,3,2) <> "85" and
           substr(vcelular,3,2) <> "86" and
           substr(vcelular,3,2) <> "87" and
           substr(vcelular,3,2) <> "88" and
           substr(vcelular,3,2) <> "89" and
           substr(vcelular,3,2) <> "90" and
           substr(vcelular,3,2) <> "91" and
           substr(vcelular,3,2) <> "92" and
           substr(vcelular,3,2) <> "93" and
           substr(vcelular,3,2) <> "94" and
           substr(vcelular,3,2) <> "95" and
           substr(vcelular,3,2) <> "96" and
           substr(vcelular,3,2) <> "97" and
           substr(vcelular,3,2) <> "98" and
           substr(vcelular,3,2) <> "99" and
           substr(vcelular,3,2) <> "80"            
        then.
        else do:
            find first tt-cel where tt-cel.celular = vcelular
                no-error.
            if not avail tt-cel
            then do:
                create tt-cel.
                tt-cel.celular = vcelular.
            end.
        end.
    end.                            
end procedure.

procedure p-totais.
vtotvencido     = 0.
vparvencido     = 0.
vencvencido     = 0.
vtotvencer      = 0.
vparvencer      = 0.
vtotpagas       = 0.
vparpagas       = 0.
vencpagas       = 0.

for each fin.titulo where fin.titulo.clifor = clien.clicod
                      and fin.titulo.empcod = 19
                      and fin.titulo.modcod = "CRE"
                      and fin.titulo.titsit = "LIB" 
                      /*and fin.titulo.titdtven < today*/ no-lock.
     
    if fin.titulo.titdtven < today 
    then do:
        vtotvencido = vtotvencido + fin.titulo.titvlcob.
        vparvencido = vparvencido + 1.
        run bstitjuro.p (input  recid(fin.titulo), 
                         input  today,         
                         output vjuros,        
                         output vsaldoatualizado).        
        vencvencido = vencvencido + (vsaldoatualizado - fin.titulo.titvlcob).     end.
    else do:
        vtotvencer = vtotvencer + fin.titulo.titvlcob.                    
        vparvencer = vparvencer + 1.
    end.
    
end.

for each fin.titulo where fin.titulo.clifor = clien.clicod
                      and fin.titulo.empcod = 19
                      and fin.titulo.modcod = "CRE"
                      and fin.titulo.titsit <> "LIB" no-lock.
    vtotpagas = vtotpagas + fin.titulo.titvlcob.                      
    vparpagas = vparpagas + 1. 
    vencpagas = vencpagas + fin.titulo.titjur.
end.

   connect dragao -H "erp.lebes.com.br" -S sdragao -N tcp -ld dragao
                                            no-error.
run totbstecli1.p (clien.clicod).
disconnect dragao.

end.
