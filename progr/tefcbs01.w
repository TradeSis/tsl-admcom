/* ---------------------------------------------------------------------------
*  Nome.....: tefcbs01.p
*  Funcao...: integracao ADMCOM e FET
*  Data.....: 28/03/2006
*  Autor....: Gerson Mathias
--------------------------------------------------------------------------- */

def temp-table restricao
    field ressel   as logi init no
    field rescod   as int form ">>>9"
    field resnom   as char form "x(80)".

&Scoped-define WINDOW-NAME W-Win

&Scoped-define PROCEDURE-TYPE SmartWindow
&Scoped-define DB-AWARE no

&Scoped-define ADM-CONTAINER WINDOW

&Scoped-define FRAME-NAME F-Main
&Scoped-define BROWSE-NAME BROWSE-1

&Scoped-define INTERNAL-TABLES restricao

&Scoped-define FIELDS-IN-QUERY-BROWSE-1 restricao.resSel restricao.resCod restricao.resNom 
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-1 restricao.resSel 
&Scoped-define ENABLED-TABLES-IN-QUERY-BROWSE-1 restricao
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BROWSE-1 restricao
&Scoped-define OPEN-QUERY-BROWSE-1 OPEN QUERY BROWSE-1 FOR EACH restricao NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BROWSE-1 restricao
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-1 restricao


&Scoped-define OPEN-BROWSERS-IN-QUERY-F-Main     ~{&OPEN-QUERY-BROWSE-1}

&Scoped-Define ENABLED-OBJECTS fl-ip EDITOR-1 bt-cinfig bt-inicializa rd-operacao bt-leCtProEx bt-leCtProprio bt-correbco bt-confEstor bt-intTrans fl-resultado BROWSE-1 EDITOR-2 fl-conteudo fl-digitacao 
&Scoped-Define DISPLAYED-OBJECTS fl-ip EDITOR-1 rd-operacao fl-resultado EDITOR-2 fl-conteudo fl-digitacao 

/* Customizar Listas Definicoes                                             */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

   
/* ***********************  Controles Definiticao  ********************** */

DEFINE BUTTON bt-cinfig 
     LABEL "Configura" 
     SIZE 35 BY .88.

DEFINE BUTTON bt-confEstor 
     LABEL "Confirmação/Estorno" 
     SIZE 35 BY .88.

DEFINE BUTTON bt-correbco 
     LABEL "Correspondente Bancário" 
     SIZE 35 BY .88.

DEFINE BUTTON bt-inicializa 
     LABEL "Inicializa" 
     SIZE 35 BY .88.

DEFINE BUTTON bt-intTrans 
     LABEL "Interromper Transação" 
     SIZE 35 BY .88.

DEFINE BUTTON bt-leCtProEx 
     LABEL "Lê Cartão Próprio EX" 
     SIZE 17 BY .88
     FONT 1.

DEFINE BUTTON bt-leCtProprio 
     LABEL "Lê Cartão Próprio" 
     SIZE 17 BY .88
     FONT 1.

DEFINE VARIABLE EDITOR-1 AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 40 BY 10 NO-UNDO.

DEFINE VARIABLE EDITOR-2 AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 36.57 BY 4.5 NO-UNDO.

DEFINE VARIABLE fl-conteudo AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 60 BY .88 NO-UNDO.

DEFINE VARIABLE fl-digitacao AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 60 BY .88 NO-UNDO.

DEFINE VARIABLE fl-ip AS CHARACTER FORMAT "X(20)":U 
     LABEL "IP SiTef" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 20 BY .88
     FONT 2 NO-UNDO.

DEFINE VARIABLE fl-resultado AS CHARACTER FORMAT "X(10)":U 
     LABEL "Resultado" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 17.29 BY .88 NO-UNDO.

DEFINE VARIABLE rd-operacao AS INTEGER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Faz Venda", 1,
"Funcoes Administrativas", 2,
"Recarga Celular", 3
     SIZE 27.43 BY 2
     FONT 1 NO-UNDO.

/* Query definicao                                                    */
DEFINE QUERY BROWSE-1 FOR 
      restricao SCROLLING.

/* Browse definiticao                                                   */
DEFINE BROWSE BROWSE-1
  QUERY BROWSE-1 NO-LOCK DISPLAY
      restricao.resSel COLUMN-LABEL "Seleção" FORMAT "Sim/Nao":U
      restricao.resCod FORMAT ">>>>9":U
      restricao.resNom FORMAT "X(80)":U
  ENABLE
      restricao.resSel /*AUTO-RETURN*/
    WITH NO-LABELS SIZE 40 BY 4 /* EXPANDABLE*/.


/* ************************  Frame Definicao ************************* */

DEFINE FRAME F-Main
     fl-ip AT ROW 1 COL 1 /*COLON-ALIGNED*/ form "x(20)"
     bt-cinfig AT ROW 2.35 COL 2.29
     bt-inicializa AT ROW 3.35 COL 2.29
     rd-operacao AT ROW 4.46 COL 6.72 NO-LABEL
     bt-leCtProEx AT ROW 6.65 COL 20.29
     bt-leCtProprio AT ROW 6.69 COL 2.29
     bt-correbco AT ROW 7.69 COL 2.29
     bt-confEstor AT ROW 8.73 COL 2.29
     bt-intTrans AT ROW 11.96 COL 2.29
     fl-resultado AT ROW 13.08 COL 10 COLON-ALIGNED
     EDITOR-1 AT ROW 1.19 COL 38.43 NO-LABEL 
     BROWSE-1 AT ROW 13.92 col 38.5 
     EDITOR-2 AT ROW 14.08 COL 1.43 NO-LABEL 
     fl-conteudo AT ROW 18.69 COL 08.57 COLON-ALIGNED NO-LABEL
     fl-digitacao AT ROW 19.65 COL 08.57 COLON-ALIGNED NO-LABEL
     "Restrições selecionadas para transação:" VIEW-AS TEXT
     SIZE 40 BY .62 AT ROW 13.08 COL 38.57 
     WITH ROW SCREEN-LINES - 22 width 80 side-labels title "TEF CBS - TEFCBS01".

/* *********************** Procedures ******************************** */


/* *************************  Criar Window  ************************** */


enable all with frame {&frame-name}.

update BROWSE-1 with frame {&frame-name}.


wait-for window-close of current-window.
