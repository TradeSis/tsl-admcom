        1   /*************************INFORMA€OES DO PROGRAMA******************************
        2   ***** Nome do Programa             : zooclase.p
        3   ***** Diretorio                    : cadas
        4   ***** Autor                        : Caludir Santolin
        5   ***** Descri‡ao Abreviada da Funcao: Classificacao de Mercadorias
        6   ***** Data de Criacao              : 28/08/2000
        7   
        8                                   ALTERACOES
        9   ***** 1) Autor     :
       10   ***** 1) Descricao : 
       11   ***** 1) Data      :
       12   
       13   ***** 2) Autor     :
       14   ***** 2) Descricao : 
       15   ***** 2) Data      :
       16   
       17   ***** 3) Autor     :
       18   ***** 3) Descricao : 
       19   ***** 3) Data      :
       20   *******************************************************************************/
       21   
       22   
       23   /*----------------------------------------------------------------------------*/
       24   /* /usr/admger/cab.i                           Cabecalho Geral das Aplicacoes */
       25   /*                                                                            */
       26   /* Data     Autor   Caracteristica                                            */
       27   /* -------- ------- ------------------                                        */
       28   /* 27/02/92 Masiero Criacao                                                   */
       29   /*----------------------------------------------------------------------------*/
       30   def  shared variable wdata as date format "99/99/9999"
       31                         label "Data de Processamento".
       32   def  shared variable wtittela as char format "x(30)".
       33   def  shared buffer wempre for empre.
       34   def  shared variable wmodulo as c.
       35   def  shared variable wareasis as char format "x(38)".
       36   def  shared variable wtitulo  as char format "x(80)".
       37   def  shared variable sfuncod  like func.funcod.
       38   def  shared var lclifor as log .
       39   
       40   
       41   def var b1 as char format "x".
       42   def var b2 as char format "x".
       43   def var b3 as char format "x".
       44   def var b4 as char format "x".
       45   def var smens as char format "x(20)".
       46   b1 = "|".
       47   b2 = "|".
       48   b3 = "|".
       49   b4 = "|".
       50   define variable ytit like wtittela.
       51   def new global shared var sparam      as char.
       52   def new global shared var sresp      as log format "Sim/Nao".
       53   def new global shared var setbcod    like estab.etbcod.
       54   def new global shared var scxacod    like estab.etbcod.
       55   def new global shared var scliente   like admcom.cliente.
       56   def new global shared var sautoriza  as char. /* like autoriz.motivo. */
       57   def new global shared var svalor1    as dec . /* like autoriz.valor1. */
       58   def new global shared var svalor2    as dec . /* like autoriz.valor2. */
       59   def new global shared var svalor3    as dec . /* like autoriz.valor3. */
       60   def new global shared var scliaut    like clien.clicod.
       61   def new global shared var stprcod    as int. /* like tippro.tprcod.  */
       62   
       63   def new global shared var slancod       like tablan.lancod.
       64   
       65   def new global shared var scabrel       as char.
       66   def new global shared var sretorno      as char.
       67   def new global shared var scopias       as int.
       68   def new global shared var schave        as char.
       69   
       70   /*def new global shared var sPROGRAMA  like PROGRAMA.PROGRAMA. */
       71   
       72   define            variable vmesabr  as char format "x(04)" extent 12 initial
       73       ["Jan","Fev","Mar","Abr","Maio","Jun","Jul","Ago","Set","Out","Nov","Dez"].
       74   define            variable vmescomp as char format "x(09)" extent 12 initial
       75       ["Janeiro","Fevereiro","Mar‡o","Abril","Maio","Junho",
       76        "Julho","Agosto", "Setembro","Outubro","Novembro","Dezembro"].
       77   define            variable vsemabr  as char extent  7 format "x(03)" initial
       78       ["Dom", "Seg", "Ter", "Qua", "Qui", "Sex", "Sab"].
       79   define            variable vsemcomp as char format "x(7)" extent 7 initial
       80       ["Domingo","Segunda","Ter‡a","Quarta","Quinta","Sexta","S bado"].
       81   
       82   
       83   def  shared frame fc1.
       84   def  shared frame fc2.
       85   if "" = "new"
       86   then do:
       87       find first wempre no-lock.
       88       wdata    = today.
       89       wareasis = " TESTE ".
       90       wtittela = "teste".
       91       wtitulo  = "                             ADMCOM VERSAO 2.0".
       92       setbcod = 999.
       93       scxacod = 1.
       94       stprcod = ?.
       95       on F6  help.
       96       on PF6 help.
       97       on F5  help.
       98       on PF5 help.
       99       on F7  help.
      100       on PF7 help.
      101   end.
      102   sparam = SESSION:PARAMETER.
      103   
      104   ytit = fill(" ",integer((30 - length(wtittela)) / 2)) + wtittela.
      105   
      106   find estab where estab.etbcod = setbcod no-lock.
      107   
      108   form space(1)
      109       wempre.emprazsoc format "x(65)" 
      110       wdata
      111       with column 1 page-top no-labels top-only row 1 width 81 no-hide frame fc1
      112           no-box color black/gray.
      113   
      114   form
      115       wtitulo          format "x(80)"
      116       with column 1 page-top no-labels top-only row 2 width 81 no-hide frame fc2
      117           no-box color blue/cyan overlay.
      118   
      119   
      120   find first func where func.funcod = sfuncod and
      121                         func.etbcod = 999      no-lock no-error.
      122   if avail func
      123   then 
      124       display wempre.emprazsoc + "/" + estab.etbnom + "-" + 
      125           func.funnom @ wempre.emprazsoc
      126               wdata with frame fc1.
      127   else
      128       display wempre.emprazsoc + "/" + estab.etbnom  @ wempre.emprazsoc
      129               wdata with frame fc1.
      130   
      131   display wtitulo                with frame fc2.
      132   
      133   status input "Digite os dados ou pressione [F4] para encerrar.".
      134   if num-entries(sparam,";") > 1
      135   then status default "CUSTOM Business Solutions         Servidor: "
      136                   + entry(1,sparam,";").
      137   else                
      138   status default "CUSTOM Business Solutions              - F5 -> Solicitacoes".
      139   
      140   /*
      141   message program-name(1) program-name(2). pause 0.
      142   */
      143   def var senha-segur as char.
      144   def var men-tit like menu.mentit.
      145   if avail menu
      146   then men-tit = menu.mentit.
      147   else men-tit = "".
      148   
      149   def buffer bsegur for seguranca.
      150   find first seguranca where
      151              seguranca.empcod = 19 and
      152              seguranca.etbcod = setbcod and
      153              /*seguranca.funcod = sfuncod and*/
      154              seguranca.programa = program-name(1)
      155              no-lock no-error.
      156   if avail seguranca
      157   then do:
      158       
      159       find first bsegur where
      160              bsegur.empcod = 19 and
      161              bsegur.etbcod = setbcod and
      162              bsegur.funcod = sfuncod and
      163              bsegur.programa = program-name(1)
      164              no-lock no-error.
      165       if not avail bsegur
      166       then do:
      167           message color red/with
      168           "Usuario sem permissao de acesso " skip
      169           men-tit 
      170           view-as alert-box.
      171           return.
      172       end.
      173       
      174       repeat :
      175           senha-segur = "".
      176           update senha-segur blank  label "Senha" with frame f-senhaseg 1 down
      177               centered row 7 side-label.
      178           if senha-segur = ""
      179           then next.
      180           if senha-segur <> seguranca.senha and
      181              senha-segur <> func.senha
      182           then do:
      183               message color red/with
      184                   "Senha Invalida.". 
      185               pause.    
      186               next.
      187           end.
      188           hide frame f-senhaseg no-pause. 
      189           leave.
      190       end.            
      191   end.   
      192   
      193   if keyfunction(lastkey) = "END-ERROR"
      194   then return.            
      195   
      196   FUNCTION acha returns character
      197       (input par-oque as char,
      198        input par-onde as char).
      199            
      200       def var vx as int.
      201       def var vret as char.  
      202       
      203       vret = ?.  
      204       
      205       do vx = 1 to num-entries(par-onde,"|"). 
      206           if entry(1,entry(vx,par-onde,"|"),"=") = par-oque 
      207           then do: 
      208               vret = entry(2,entry(vx,par-onde,"|"),"="). 
      209               leave. 
      210           end. 
      211       end.
      212       return vret. 
      213   END FUNCTION.
      214            
      215   FUNCTION sel-arq01 returns character .
      216       
      217       DEFINE VARIABLE procname AS CHARACTER NO-UNDO.
      218       DEFINE VARIABLE OKpressed AS LOGICAL INITIAL TRUE.
      219   
      220       def var varquivo as char.
      221       Main: 
      222       REPEAT:
      223           SYSTEM-DIALOG GET-FILE procname
      224               TITLE      "Selecione o arquivo ..."
      225               FILTERS   " " "*.*",
      226                       "txt"  "*.txt", 
      227                    "csv"  "*.csv"
      228               MUST-EXIST
      229               USE-FILENAME
      230               UPDATE OKpressed.
      231         
      232           IF OKpressed = TRUE THEN
      233               varquivo = procname.
      234               LEAVE Main.
      235       END.     
      236       return varquivo. 
      237   END FUNCTION.
      238   
      239   /***
      240   FUNCTION venda-liquida-item return decimal
      241       (input rec-movim as recid).
      242       def var val_fin as dec init 0.
      243       def var val_des as dec init 0.
      244       def var val_dev as dec init 0.
      245       def var val_acr as dec init 0.
      246       def var val_com as dec init 0.
      247       assign
      248           val_fin = 0                   
      249           val_des = 0   
      250           val_dev = 0   
      251           val_acr = 0
      252           val_com = 0. 
      253                            
      254       find movim where recid(movim) = rec-movim no-lock no-error.
      255       if avail movim
      256       then do:
      257           find first plani where plani.etbcod = movim.etbcod and
      258                              plani.placod = movim.placod and
      259                              plani.movtdc = movim.movtdc and
      260                              plani.pladat = movim.movdat
      261                              no-lock no-error.
      262           if avail plani
      263           then do:                       
      264               
      265               val_acr =  ((movim.movpc * movim.movqtm) / plani.platot) * 
      266                           plani.acfprod.
      267               if val_acr = ? then val_acr = 0.
      268               
      269               val_des =  ((movim.movpc * movim.movqtm) / plani.platot) * 
      270                           plani.descprod.
      271               if val_des = ? then val_des = 0.
      272           
      273               val_dev =  ((movim.movpc * movim.movqtm) / plani.platot) * 
      274                           plani.vlserv.
      275               if val_dev = ? then val_dev = 0.
      276           
      277               if (plani.platot - plani.vlserv - plani.descprod) < plani.biss
      278               then val_fin =  
      279                   ((((movim.movpc * movim.movqtm) - val_dev - val_des)
      280                            / (plani.platot - plani.vlserv - plani.descprod))
      281                               * plani.biss) - ((movim.movpc * movim.movqtm) - 
      282                               val_dev - val_des).
      283               if val_fin = ? then val_fin = 0.
      284               
      285               val_com = (movim.movpc * movim.movqtm) - val_dev - val_des + 
      286                           val_acr +  val_fin. 
      287   
      288               if val_com = ? then val_com = 0.
      289                
      290           end.
      291       end.
      292       return val_com.
      293   END FUNCTION.
      294   **/
      295   
      296    .
      297   
      298   /****************************************************************************
      299   ****************************************************************************
      300   ** Program: s-setbrw.i
      301   ** Created: 6/21/89
      302   **   Descr: Set-up for s-browse.i variables.
      303   **
      304   ****************************************************************************
      305   \****************************************************************************/
      306   
      307   /* Copyright (c) by Progress Software 1988,1989
      308   - All Rights Reserved -                                */
      309   
      310   
      311   DEF   VAR i-seeid  AS INT NO-UNDO.
      312   DEF         VAR i-seerec AS INT EXTENT 20 NO-UNDO.
      313   DEF         VAR i-seekey AS CHAR.
      314   DEF         VAR i-seelst AS CHAR.
      315   def         var i-recid  as int initial -1  no-undo.
      316   
      317   def   var a-seeid as int no-undo.
      318   def         var a-seerec as int extent 40 no-undo.
      319   def         var a-seekey as char.
      320   def         var a-seelst as char.
      321   def         var a-recid  as int initial -1 no-undo.
      322   
      323   
      324   def   var b-seeid as int no-undo.
      325   def         var b-seerec as int extent 40 no-undo.
      326   def         var b-seekey as char.
      327   def         var b-seelst as char.
      328   def         var b-recid  as int initial -1 no-undo.
      329   
      330   ASSIGN
      331       i-seeid = -1
      332       a-seeid = -1
      333       b-seeid = -1.
      334    
      335    .
      336   
      337   /****************************************************************************
      338   ****************************************************************************
      339   ** Program: s-setbrw.i
      340   ** Created: 6/21/89
      341   **   Descr: Set-up for s-browse.i variables.
      342   **
      343   ****************************************************************************
      344   \****************************************************************************/
      345   
      346   /* Copyright (c) by Progress Software 1988,1989
      347   - All Rights Reserved -                                */
      348   
      349   
      350   DEF   VAR an-seeid  AS INT NO-UNDO.
      351   DEF         VAR an-seerec AS INT EXTENT 20 NO-UNDO.
      352   DEF         VAR an-seekey AS CHAR.
      353   DEF         VAR an-seelst AS CHAR.
      354   def         var an-recid  as int initial -1  no-undo.
      355   
      356    
      357    .
      358   
      359   
      360   def buffer setor for clase.
      361   
      362   def var i as int.
      363   def var v-cont      as int.
      364   def var v-procod    like produ.procod.
      365   def buffer bprodu   for produ.
      366   
      367   def temp-table ttprodu
      368       field procod like produ.procod.
      369   
      370   def var p-depto     like clase.clacod.
      371   def var p-setor     like clase.clacod.
      372   def var p-clasesup  like clase.clacod.
      373   def var p-clase     like clase.clacod.
      374   def var spclase     like clase.clacod.
      375   def var v-titgru    as char.
      376   def var v-titcla    as char.
      377   def var v-stitcla   as char.
      378   def var vclacod     like clase.clacod.
      379   def var vclacod1    like setor.clacod.
      380   
      381   def buffer depto for clase.
      382   def buffer bclase   for clase.
      383   def buffer clasesup for clase.
      384   def buffer bsetor   for setor.
      385   def buffer sclase   for clase.
      386   def buffer grupo    for clase.
      387   def buffer iclase   for clase.
      388   def var v-titpro    as char format "x(25)".
      389   
      390   form
      391       depto.clacod
      392       depto.clanom
      393       with frame f-depto
      394           row 10
      395           overlay 
      396           down
      397           no-labels  color /*withe/red*/ yellow/blue
      398           title " SETORES ".
      399   
      400   
      401   form
      402       setor.clacod
      403       setor.clanom
      404       with frame f-setor
      405           row 10
      406           overlay 
      407           down
      408           no-labels  color /*withe/red*/ yellow/blue
      409           title " SETORES ".
      410   
      411   form
      412       clasesup.clacod
      413       clasesup.clanome
      414       with frame f-clasesup
      415           column 15 
      416           row 10
      417           overlay
      418           down
      419           no-labels  color /*withe/brown*/ yellow/blue
      420           title v-titgru.
      421   
      422   form
      423       sclase.clacod
      424       sclase.clanome  format "x(20)"
      425       with frame f-sclase
      426           column 45
      427           row  10
      428           overlay
      429           down
      430           no-labels   color /*withe/cyan*/ yellow/blue
      431           width 35
      432           title v-stitcla.
      433   
      434   form
      435       clase.clacod
      436       clase.clanome format "x(20)"
      437       with frame f-clase
      438           column 30
      439           row  10
      440           overlay
      441           down
      442           no-labels  color /*withe/green*/ yellow/blue width 35
      443           title v-titcla.
      444            
      445   l0: repeat:
      446       clear frame f-depto all.
      447       
      448       assign
      449           a-seeid = -1
      450           a-recid = -1
      451           a-seerec = ?.
      452   
      453       
      454   /****************************************************************************
      455   ****************************************************************************
      456   ** Program: fbrowse.i
      457   ** Created: 6/21/89
      458   ** Modifid: 3/14/90 wlb - added additional parameters
      459   **
      460   **Parameters: {&File}     = filename
      461   **            {&CField}   = choose field to display
      462   **            {&Where}    = logical condition for selecting records must be
      463   **                          TRUE at least
      464   **
      465   **   The following parameters are optional
      466   **
      467   **            {&OField}   = other fields to display
      468   **            {&AftFnd}   = code to execute after finding record (ie find
      469   **                          associated record.
      470   **            {&LockType} = type of lock used on records
      471   **            {&NonCharacter} = set to slash-splat if the choose field is
      472   **                           not a character field.
      473   **            {&AftSelect} = code to execute after a record is selected
      474   **            {&GOON}     = other keys to go-on
      475   **            {&chooseeys} = code to check if they have pressed one of the
      476   **                          optional {&GOON} keys.
      477   **
      478   **            {&form}     = Custom FORM Statement
      479   **
      480   **      Pick Multi Records parameters
      481   **            {&UsePick}  = *
      482   **            {&PickFld}  = field name to store in pick list.  This can be
      483   **                          any expression -- even a recid function.
      484   **            {&PickFrm}  = format of &PickFld expression i.e. 9999 or x(10)
      485   ****************************************************************************
      486   \****************************************************************************/
      487   form /*/
      488        a-seelst format "x" no-labels
      489        /{&usepick}*/
      490        with  frame f-depto .
      491   
      492   DO WITH  frame f-depto :
      493   
      494       keys-loop:
      495       DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      496   
      497           IF a-seeid NE -1
      498           THEN DO:
      499               CHOOSE row   depto.clanom help ""
      500                   
      501                   KEYS a-seekey
      502        GO-ON( F1 PF1 F4 PF4 F5 PF5 F7 PF7 TAB F8 PF8 F9 PF9 F10 PF10 )
      503                   NO-ERROR.
      504   
      505               color display withe/red depto.clanom.
      506   
      507               PAUSE 0.
      508               ASSIGN a-seeid = a-seerec[FRAME-LINE].
      509               
      510               IF keyfunction(lastkey) = "TAB" or
      511                   keyfunction(lastkey) = "END-ERROR"
      512               THEN
      513                   LEAVE.
      514               
      515               IF keyfunction(lastkey) = "NEW-LINE" or
      516                  keyfunction(lastkey) = "insert-mode"
      517               THEN DO:
      518                   
      519                   
      520               end.
      521   
      522               IF keyfunction(lastkey) = "GET" or
      523                  keyfunction(lastkey) = "recall" or 
      524                  keyfunction(lastkey) = "CLEAR"
      525               THEN DO:
      526                   
      527                   
      528                   if available depto
      529                   then
      530                       assign
      531                           a-recid = recid(depto)
      532                           a-seeid = -1.
      533               END.
      534               
      535                /*if keyfunction(lastkey) = "GO" 
      536                               then run p-comumset.*/ 
      537   
      538           END.
      539           /* find first record logic */
      540           IF a-seeid = -1
      541                
      542               OR (LASTKEY GE 32 AND LASTKEY LE 127)
      543               /**/
      544           THEN DO:
      545               if a-recid = -1
      546               then do:
      547                   FIND FIRST depto WHERE
      548                           
      549                           depto.clanom BEGINS a-seekey AND /**/
      550                            depto.clatipo = yes and
      551                           depto.clasup = 0
      552                           no-lock  NO-ERROR.
      553               end.
      554               else do:
      555                   find first depto where recid (depto) = a-recid  no-lock .
      556                   ASSIGN
      557                       a-recid = -1.
      558               end.
      559               IF AVAILABLE depto
      560               THEN DO:
      561                   
      562                   
      563                   CLEAR ALL.
      564                   ASSIGN
      565                       a-seeid = -1
      566                       a-seerec[1] = ?
      567                       a-seerec[1] = RECID(depto).
      568                   DISPLAY depto.clanom
      569                            depto.clacod 
      570                           /*/
      571                           IF CAN-DO(a-seelst,STRING({&PickFld},"{&PickFrm}"))
      572                           THEN "*" ELSE "" @ a-seelst
      573                           /{&UsePick}*/ /*color {&color}*/.
      574   
      575               END.
      576               
      577               ELSE
      578                   IF LENGTH(a-seekey) > 1
      579                   THEN DO:
      580                       ASSIGN
      581                           a-seekey = SUBSTRING(a-seekey,LENGTH(a-seekey)).
      582                       NEXT.
      583                   END.
      584                   ELSE
      585                       IF LENGTH(a-seekey) = 1
      586                       THEN DO:
      587                           MESSAGE "Nenhum registro comeca com " KEYLABEL(LASTKEY).
      588                           ASSIGN a-seekey = "".
      589                           NEXT.
      590                       END.
      591                       /**/
      592                       ELSE DO:
      593                           
      594                            bell.
      595           /***
      596                          message color red/withe
      597                               "Nenhum registro encontrado"
      598                               view-as alert-box title " Mensagem " .
      599           ***/                            
      600                          hide frame f-depto no-pause.
      601                          leave l0. 
      602                       END.
      603           END.
      604   
      605           IF LASTKEY LT 32 OR LASTKEY GT 127
      606           THEN
      607               ASSIGN a-seekey = "".
      608           ELSE do:
      609               if "" = "/*"
      610               THEN do:
      611                   ASSIGN a-seekey = "".
      612               end.
      613           end.
      614   
      615           /* loop so that the page-up can come back to the page-down if needed */
      616   
      617           IF CAN-DO
      618           ("PAGE-UP,CURSOR-UP,PAGE-DOWN,CURSOR-DOWN",KEYFUNCTION(LASTKEY)) OR
      619               a-seeid = -1
      620           THEN pge-depto-loop: DO WHILE TRUE:
      621   
      622               /* cursor down */
      623   
      624               IF INDEX(KEYFUNCTION(LASTKEY),"DOWN") > 0 OR
      625                   a-seeid = -1
      626               THEN DO:
      627                   /******* aqui *******/
      628                   IF a-seeid NE -1
      629                   THEN 
      630                       FIND FIRST depto WHERE
      631                       RECID(depto) = a-seerec[FRAME-DOWN]
      632                                                 no-lock  NO-ERROR.
      633                   IF NOT AVAILABLE depto
      634                   THEN
      635                       NEXT keys-loop.
      636                   
      637                   IF a-seeid NE -1
      638                   THEN DO:
      639                       UP FRAME-LINE - 1.
      640                       DOWN FRAME-DOWN - 1.
      641                   END.
      642   
      643                   DO WHILE TRUE:
      644                       FIND NEXT depto WHERE  depto.clatipo = yes and
      645                           depto.clasup = 0
      646                           no-lock  NO-ERROR.
      647                       IF NOT AVAILABLE depto
      648                       THEN leave.
      649   
      650                       
      651                       
      652   
      653                       /* was it a cursor-down */
      654                       IF KEYFUNCTION(LASTKEY) = "Cursor-Down" OR
      655                       /* or are we finishing off an incomplete page-up */
      656                           (a-seerec[1] = ? AND a-seerec[FRAME-DOWN] NE ?)
      657                       THEN DO:
      658                           DO a-seeid = 1 TO FRAME-DOWN - 1:
      659                               ASSIGN a-seerec[a-seeid] = a-seerec[a-seeid + 1].
      660                           END.
      661                           SCROLL UP.
      662                       END.
      663                       ELSE DO:
      664                           IF FRAME-LINE = FRAME-DOWN
      665                           THEN
      666                               ASSIGN a-seerec = ?.
      667                           DOWN.
      668                       END.
      669   
      670                       DISPLAY
      671                           depto.clanom
      672                            depto.clacod 
      673                           /*/
      674                           IF CAN-DO(a-seelst,STRING({&PickFld},"{&PickFrm}"))
      675                           THEN
      676                               "*"
      677                           ELSE
      678                               "" @ a-seelst
      679                           /{&UsePick}*/ /*color {&color}*/.
      680                       
      681                       ASSIGN
      682                           a-seerec[FRAME-LINE] = RECID(depto).
      683                       
      684                       IF FRAME-DOWN = FRAME-LINE AND
      685                           a-seerec[1] NE ?
      686                       THEN
      687                           LEAVE.
      688                   END.
      689   
      690                   IF KEYFUNCTION(LASTKEY) NE "cursor-down"
      691                   THEN
      692                       UP FRAME-LINE - 1.
      693   
      694                   ASSIGN
      695                       a-seeid = 0.
      696                   NEXT keys-loop.
      697               END.
      698               /* cursor up */
      699   
      700               ELSE DO:
      701                   FIND FIRST depto WHERE
      702                               RECID(depto) = a-seerec[1]  no-lock 
      703                               NO-ERROR.
      704                   IF NOT AVAILABLE depto
      705                   THEN
      706                       NEXT keys-loop.
      707                   UP FRAME-LINE - 1.
      708                   DO WHILE TRUE:
      709                       FIND PREV depto WHERE  depto.clatipo = yes and
      710                           depto.clasup = 0
      711                           no-lock  NO-ERROR.
      712   
      713                       IF NOT AVAILABLE depto
      714                       THEN DO:
      715               /* if it is a curs-up or the initial find prev fails then we will */
      716               /* still be on line 1 and we can just leave. */
      717                           IF FRAME-LINE = 1
      718                           THEN
      719                               NEXT keys-loop.
      720                           ASSIGN a-seeid = -1.
      721                           PAUSE 0.
      722                           NEXT pge-depto-loop.
      723                       END.
      724   
      725                       
      726                       
      727   
      728                       IF KEYFUNCTION(LASTKEY) = "Cursor-up"
      729                       THEN DO:
      730                           DO a-seeid = FRAME-DOWN TO 2 BY -1:
      731                               ASSIGN
      732                                   a-seerec[a-seeid] = a-seerec[a-seeid - 1].
      733                           END.
      734                           SCROLL DOWN.
      735                       END.
      736                       ELSE DO:
      737                           IF FRAME-LINE = 1
      738                           THEN
      739                               ASSIGN a-seerec = ?.
      740                           UP  .
      741                       END.
      742   
      743                       DISPLAY
      744                           depto.clanom
      745                            depto.clacod 
      746                           /*/
      747                           IF CAN-DO(a-seelst,STRING({&PickFld},"{&PickFrm}"))
      748                           THEN
      749                               "*"
      750                           ELSE
      751                               "" @ a-seelst
      752                           /{&UsePick}*/ /*color {&color}*/.
      753   
      754                       ASSIGN
      755                           a-seerec[FRAME-LINE] = RECID(depto).
      756   
      757                       IF FRAME-LINE = 1
      758                       THEN
      759                           NEXT keys-loop.
      760                   END.
      761               END.
      762               LEAVE.
      763           END.
      764   
      765           IF LOOKUP
      766   (KEYFUNCTION(LASTKEY),
      767   "RETURN,GO,DELETE-LINE,RECALL,CLEAR,GET,NEW-LINE,INSERT-MODE,PUT") > 0
      768           THEN DO:
      769               IF a-seeid = ?
      770               THEN
      771                   NEXT.
      772   
      773               FIND FIRST depto WHERE RECID(depto) = a-seeid  no-lock 
      774                                                         NO-ERROR.
      775   
      776               
      777                frame-value = ?.
      778                           p-depto = depto.clacod.
      779                           leave keys-loop. 
      780               /*/
      781               IF KEYFUNCTION(LASTKEY) = "RETURN"
      782               THEN DO:
      783                   IF NOT CAN-DO(a-seelst,STRING({&PickFld},"{&PickFrm}"))
      784                   THEN DO:
      785                       DISPLAY "*" @ a-seelst.
      786                       ASSIGN
      787                           a-seelst =
      788                           a-seelst + "," + STRING({&PickFld},"{&PickFrm}").
      789                   END.
      790                   ELSE
      791                       IF CAN-DO(a-seelst,STRING({&PickFld},"{&PickFrm}"))
      792                       THEN DO:
      793                           DISPLAY " " @ a-seelst.
      794                           ASSIGN
      795                               SUBSTRING(a-seelst,
      796                           INDEX(a-seelst,"," + STRING({&PickFld},"{&PickFrm}")),
      797                               LENGTH(STRING({&PickFld},"{&PickFrm}")) + 1) = "".
      798                       END.
      799                   NEXT.
      800               END.
      801               /{&UsePick}*/
      802               
      803               leave. /* this will leave if it is a go or we are not using pick */
      804               
      805           END. /* end of record pick */
      806       END.
      807       /* if they end errored the release the record so that it is not avail
      808       *  to the calling program.  The calling program would think it was selected
      809       */
      810       IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
      811       RELEASE depto.
      812   END.
      813    
      814    .                
      815       /*
      816       if keyfunction(lastkey) = "END-ERROR" or keyfunction(lastkey) = "GO" 
      817       then do:
      818           hide frame f-depto no-pause.
      819           leave l0.
      820       end.
      821   
      822       view frame f-setor.
      823       pause 0.
      824       find first depto where depto.clacod = p-depto no-lock.
      825       v-titgru = "SETOR - " + 
      826               string(depto.clanom).
      827    
      828       l1: repeat :
      829   
      830       clear frame f-setor all.
      831       
      832       assign
      833           a-seeid = -1
      834           a-recid = -1
      835           a-seerec = ?.
      836   
      837       {sklcls.i
      838           &color = withe
      839           &color1 = red
      840           &noncharacter = /*
      841           &file       = setor
      842           &Cfield     = setor.clanom
      843           &OField     = " setor.clacod " 
      844           &Where      = " setor.clatipo = yes and
      845                           setor.clasup = p-depto
      846                         " 
      847           &AftSelect1 = " frame-value = setor.clacod.
      848                           p-setor = setor.clacod.
      849                           leave keys-loop. " 
      850           &OtherKeys1  = " if keyfunction(lastkey) = ""GO"" then run p-comumset. "
      851           &LockType  = " no-lock "
      852           &naoexiste1 = " bell.
      853           /***
      854                          message color red/withe
      855                               ""Nenhum registro encontrado""
      856                               view-as alert-box title "" Mensagem "" .
      857           ***/                            
      858                          hide frame f-setor no-pause.
      859                          leave l1. " 
      860           &form       = " frame f-setor " 
      861       }.                
      862   
      863       if keyfunction(lastkey) = "END-ERROR" or keyfunction(lastkey) = "GO" 
      864       then do:
      865           hide frame f-setor no-pause.
      866           leave l1.
      867       end.
      868   
      869       view frame f-setor.
      870       pause 0.
      871       find first setor where setor.clacod = p-setor no-lock.
      872       v-titgru = "GRUPOS - SETOR " + 
      873               string(setor.clanom).
      874       l2: repeat :
      875           clear frame f-clasesup all.
      876           hide frame f-clasesup.
      877           clear frame f-clase all.
      878           hide frame f-clase.
      879           
      880           assign
      881               a-seeid = -1
      882               a-recid = -1
      883               a-seerec = ?.
      884               
      885           {sklcls.i
      886               &color = withe/brown
      887               &noncharacter = /*
      888               &file       = clasesup
      889               &CField     = clasesup.clanome
      890               &OField     = "clasesup.clacod" 
      891               &Where      = " clasesup.clasup = p-setor
      892                              " 
      893               &OtherKeys1  = " if keyfunction(lastkey) = ""GO"" then run p-comumsup. "
      894               &naoexiste1 = " bell.
      895               /***
      896                          message color red/withe
      897                               ""Nenhum registro encontrado""
      898                               view-as alert-box title "" Menssagem "".
      899               ***/                            
      900                          hide frame f-setor no-pause.
      901                          hide frame f-clasesup no-pause.
      902                          leave l1.                            
      903                          "
      904               &AftSelect1 = " p-clasesup = clasesup.clacod .
      905                               frame-value = clasesup.clacod.
      906                               leave keys-loop. " 
      907               &Form       = " frame f-clasesup " 
      908           }.
      909           if keyfunction(lastkey) = "END-ERROR" or keyfunction(lastkey) = "GO"
      910           then do:
      911               hide frame f-clasesup no-pause.
      912               leave l2.
      913           end.
      914           
      915           view frame f-clasesup.
      916           pause 0.
      917           find first clasesup where clasesup.clacod = p-clasesup no-lock.
      918           v-titcla = "CLASSES - GRUPO " + string(clasesup.clanome).
      919           l3: repeat :
      920               clear frame f-sclase all. hide frame f-sclase.
      921               assign
      922                   a-seeid = -1
      923                   a-recid = -1
      924                   a-seerec = ?.
      925               
      926               {sklcls.i
      927                   &color      = withe/green
      928                   &noncharacter = /*
      929                   &file       = clase
      930                   &CField     = clase.clanome
      931                   &OField     = "clase.clacod
      932                                 " 
      933                   &Where      = " clase.clasup = p-clasesup" 
      934                   &OtherKeys1  = " if keyfunction(lastkey) = ""GO"" then 
      935                           run p-comumcla. "
      936                   &naoexiste1 = " 
      937                          bell.
      938                          /***
      939                          message color red/withe
      940                               ""Nenhum registro encontrado""
      941                               view-as alert-box title "" Mensagem "" .
      942                          ***/                             
      943                           hide frame f-setor no-pause.
      944                           hide frame f-clasesup no-pause.
      945                           hide frame f-clase no-pause.
      946                           leave l1.                       
      947                           " 
      948                   &AftSelect1 = " frame-value = clase.clacod.
      949                                   p-clase = clase.clacod.
      950                                   leave keys-loop." 
      951                   &Form       = "frame f-clase" 
      952              }.      
      953               if keyfunction(lastkey) = "END-ERROR" or keyfunction(lastkey) = "GO"            then do:
      954                   hide frame f-lase no-pause.
      955                   leave l3.
      956               end.
      957   
      958               view frame f-clase.
      959               pause 0.
      960               find first clase where clase.clacod = p-clase no-lock.
      961               v-stitcla = "SUBCLASSES - " + string(clase.clanome).
      962           
      963               l4: repeat :
      964                   clear frame f-produ all. hide frame f-produ.
      965                   clear frame f-sclase all. hide frame f-sclase.
      966                   
      967                   assign a-seeid = -1 a-recid = -1 a-seerec = ?.
      968               
      969                   {sklcls.i
      970                       &color      = withe/cyan
      971                       &noncharacter = /*
      972                       &file       = sclase
      973                       &CField     = sclase.clanome
      974                       &OField     = "sclase.clacod" 
      975                       &Where      = "sclase.clasup  = p-clase" 
      976                       &naoexiste1 = " bell.
      977                       /***
      978                                   message color red/withe
      979                                         ""Nenum registro encontrado""
      980                                         view-as alert-box title "" Menssagem "".
      981                       ***/                                      
      982                                     hide frame f-setor no-pause.
      983                                      hide frame f-sclase. 
      984                                      leave l1.
      985                                       " 
      986                       &AftSelect1 = " frame-value = sclase.clacod.
      987                                       leave l0. " 
      988                       &Form       = "frame f-sclase" 
      989                   }.
      990                   if keyfunction(lastkey) = "END-ERROR" or keyfunction(lastkey) = "GO"
      991                   then do:
      992                       hide frame f-sclase no-pause.
      993                       leave l4.
      994                   end.
      995               end.
      996           end.   
      997           
      998       end.  
      999       
     1000   end.    
     1001            */
     1002   [[]]             */
     1003                    */
     1004                        */
     1005                            */
     1006                            
     1007   end.
     1008   
     1009   /***message frame-value view-as alert-box.***/
     1010   hide frame f-sclase no-pause.
     1011   hide frame f-clase no-pause.
     1012   hide frame f-clasesup no-pause.
     1013   hide frame f-setor no-pause.
     1014                               
     1015   procedure p-comumset.
     1016   /***message 1 view-as alert-box.***/
     1017       frame-value = setor.clacod.
     1018       p-setor = setor.clacod.
     1019       
     1020   end procedure.
     1021   
     1022   procedure p-comumsup.
     1023   /***message 2 view-as alert-box.***/
     1024       frame-value = clasesup.clacod.
     1025       p-setor = clasesup.clacod.
     1026       
     1027   end procedure.
     1028   
     1029   procedure p-comumcla.
     1030   /***message 3 view-as alert-box.***/
     1031       frame-value = clase.clacod.
     1032       p-setor = clase.clacod.
     1033       
     1034   end procedure.
