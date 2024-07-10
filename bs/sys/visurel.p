&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          dados            PROGRESS
*/
&Scoped-define WINDOW-NAME WINDOW-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS WINDOW-1 
/*------------------------------------------------------------------------

  File: 

  Description: 

  Input Parameters:
      <none>

  Output Parameters:
      <none>

  Author: 

  Created: 07/25/97 - 11:16 am

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* Create an unnamed pool to store all the widgets created 
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures 
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */
def input parameter varq   as char.
def input parameter vtitle as char.

/* Parameters Definitions ---                                           */

def temp-table tt-linha no-undo 
    field linha as int format "9" column-label ""
    field campo1 as char format "x(20)"
    field campo as char format "x(76)" extent 10
        index linha is primary linha.

def var a as char.
def var vi as i.
def var vj as i.
do vi = 1 to (3 * 80).
    vj = vj + 1.
    if vj mod 10 = 0
    then do:
        a = a + "X".
        vj = 0.
    end.
    else  a = a + string(vj).
end.
def var vp as i.
def var vt as i.
/*
do vj = 1 to 40.
    create tt-linha.
    tt-linha.linha = vj.
    vp = 1.
    vt = 0.
    do vi = 1 to 10.
        vp = vp + vt. vt = 78.        
        tt-linha.campo[vi] = substring(a,vp,vt).
    end.
end.
*/
vj = 0.
input from value(varq) no-convert no-echo.
repeat on error undo, return.
    vj = vj + 1.
    create tt-linha.
    tt-linha.linha = vj.
    import unformatted a.
    if vj = 1 then do:
            delete tt-linha.
            next.
    end.        
    vp = 1.
    vt = 0.
    do vi = 1 to 10.
        vp = vp + vt. vt = 76.        
        tt-linha.campo[vi] = substring(a,
                if vp - 50 <= 0 then 1 else vp - 50,vt).
    end.
end.
input close.    

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE WINDOW

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME FRAME-A
&Scoped-define BROWSE-NAME browse-tt-linha

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-linha tt-linha

/* Definitions for BROWSE browse-tt-linha                               */
&Scoped-define FIELDS-IN-QUERY-browse-tt-linha tt-linha.Cgc tt-linha.clfcod tt-linha.clfnom 
&Scoped-define ENABLED-FIELDS-IN-QUERY-browse-tt-linha 
&Scoped-define FIELD-PAIRS-IN-QUERY-browse-tt-linha
&Scoped-define OPEN-QUERY-browse-tt-linha OPEN QUERY tt-linha FOR EACH tt-linha NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-browse-tt-linha tt-linha
&Scoped-define FIRST-TABLE-IN-QUERY-browse-tt-linha  tt-linha


/* Definitions for BROWSE browse-tt-linha                             */
&Scoped-define FIELDS-IN-QUERY-browse-tt-linha tt-linha.cgc tt-linha.clfcod tt-linha.clfnom tt-linha.qtd   
&Scoped-define ENABLED-FIELDS-IN-QUERY-browse-tt-linha   
&Scoped-define FIELD-PAIRS-IN-QUERY-browse-tt-linha
&Scoped-define SELF-NAME browse-tt-linha
&Scoped-define OPEN-QUERY-browse-tt-linha OPEN QUERY {&SELF-NAME}         FOR EACH tt-linha use-index linha indexed-reposition. 
&Scoped-define TABLES-IN-QUERY-browse-tt-linha tt-linha
&Scoped-define FIRST-TABLE-IN-QUERY-browse-tt-linha tt-linha


/* Definitions for FRAME FRAME-A                                        */
&Scoped-define OPEN-BROWSERS-IN-QUERY-FRAME-A     ~{&OPEN-QUERY-browse-tt-linha}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS Btn_Done-2 RECT-68 RADIO-SET-tt-linha RECT-71 Btn-PedOrcamos Btn-Inclusao RECT-70 FILL-IN_clfcod BUTTON-8 RADIO-SET-Ordem 
&Scoped-Define DISPLAYED-OBJECTS RADIO-SET-tt-linha vtotal-PedOrcamos FILL-IN_clfcod RADIO-SET-Ordem 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR WINDOW-1 AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */

/* Query definitions                                                    */
&ANALYZE-SUSPEND

DEFINE QUERY browse-tt-linha FOR 
      tt-linha SCROLLING.
&ANALYZE-RESUME

DEFINE BROWSE browse-tt-linha
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS browse-tt-linha WINDOW-1 _FREEFORM
  QUERY browse-tt-linha DISPLAY
      tt-linha.campo
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH SIZE 80 BY 21
    title vtitle no-labels.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME FRAME-A
     browse-tt-linha AT ROW 1 COL 1
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 80 BY 21.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: WINDOW
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW WINDOW-1 ASSIGN
         HIDDEN             = YES
         TITLE              = ""
         COLUMN             = 14.57
         ROW                = 3.29
         HEIGHT             = 17.75
         WIDTH              = 250
         MAX-HEIGHT         = 17.75
         MAX-WIDTH          = 250
         VIRTUAL-HEIGHT     = 17.75
         VIRTUAL-WIDTH      = 250
         RESIZE             = yes
         SCROLL-BARS        = yes
         STATUS-AREA        = no
         BGCOLOR            = ?
         FGCOLOR            = ?
         KEEP-FRAME-Z-ORDER = yes
         THREE-D            = yes
         MESSAGE-AREA       = no
         SENSITIVE          = yes.
ELSE {&WINDOW-NAME} = CURRENT-WINDOW.
/* END WINDOW DEFINITION                                                */
&ANALYZE-RESUME


/* ***************  Runtime Attributes and UIB Settings  ************** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW WINDOW-1
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME FRAME-A
                                                                        */
/* BROWSE-TAB browse-tt-linha browse-tt-linha FRAME-A */
/* SETTINGS FOR BROWSE browse-tt-linha IN FRAME FRAME-A
   NO-ENABLE                                                            */
ASSIGN 
       browse-tt-linha:HIDDEN  IN FRAME FRAME-A            = TRUE.

IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(WINDOW-1)
THEN WINDOW-1:HIDDEN = no.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE browse-tt-linha
/* Query rebuild information for BROWSE browse-tt-linha
     _TblList          = "dados.tt-linha"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _FldNameList[1]   = dados.tt-linha.linha
     _FldNameList[2]   = dados.tt-linha.campo
     _Query            is NOT OPENED
*/  /* BROWSE browse-tt-linha */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE browse-tt-linha
/* Query rebuild information for BROWSE browse-tt-linha
     _START_FREEFORM
    OPEN QUERY {&SELF-NAME}
        FOR EACH tt-linha use-index linha indexed-reposition.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE browse-tt-linha */
&ANALYZE-RESUME

 




/* ************************  Control Triggers  ************************ */

&Scoped-define BROWSE-NAME browse-tt-linha


&Scoped-define BROWSE-NAME browse-tt-linha
&Scoped-define SELF-NAME browse-tt-linha

&Scoped-define BROWSE-NAME browse-tt-linha
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK WINDOW-1 


/* ***************************  Main Block  *************************** */

/* Set CURRENT-WINDOW: this will parent dialog-boxes and frames.        */
ASSIGN CURRENT-WINDOW                = {&WINDOW-NAME} 
       THIS-PROCEDURE:CURRENT-WINDOW = {&WINDOW-NAME}.


/* The CLOSE event can be used from inside or outside the procedure to  */
/* terminate it.                                                        */
ON CLOSE OF THIS-PROCEDURE 
do:
    run disable_UI.
end.
/* These events will close the window and terminate the procedure.      */
/* (NOTE: this will override any user-defined triggers previously       */
/*  defined on the window.)                                             */
ON WINDOW-CLOSE OF {&WINDOW-NAME} DO:
  
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.
ON ENDKEY, END-ERROR OF {&WINDOW-NAME} ANYWHERE DO:
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* Best default for GUI applications is...                              */
PAUSE 0 BEFORE-HIDE.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */

MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.
  run p-monta-query.

  IF NOT THIS-PROCEDURE:PERSISTENT THEN
    WAIT-FOR CLOSE OF THIS-PROCEDURE.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI WINDOW-1 _DEFAULT-DISABLE
PROCEDURE disable_UI :
/*------------------------------------------------------------------------------
  Purpose:     DISABLE the User Interface
  Parameters:  <none>
  Notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide 
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
------------------------------------------------------------------------------*/
  /* Delete the WINDOW we created */
  IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(WINDOW-1)
  THEN DELETE WIDGET WINDOW-1.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI WINDOW-1 _DEFAULT-ENABLE
PROCEDURE enable_UI :
/*------------------------------------------------------------------------------
  Purpose:     ENABLE the User Interface
  Parameters:  <none>
  Notes:       Here we display/view/enable the widgets in the
               user-interface.  In addition, OPEN all queries
               associated with each FRAME and BROWSE.
               These statements here are based on the "Other 
               Settings" section of the widget Property Sheets.
------------------------------------------------------------------------------*/

  enable  browse-tt-linha with frame frame-a.
  {&OPEN-BROWSERS-IN-QUERY-FRAME-A}
  VIEW WINDOW-1.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE P-Controla-Habilitacao WINDOW-1 
PROCEDURE P-Controla-Habilitacao :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
def input parameter par-acao as char.   
do with frame {&Frame-name}:    
end.
                
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE p-monta-query WINDOW-1 
PROCEDURE p-monta-query :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
do with frame {&FRAME-NAME}.
    ASSIGN 
           browse-tt-linha:HIDDEN = no.

    close query browse-tt-linha.

    run p-mostra-dados ("todos").   
    
   
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE P-Mostra-Dados WINDOW-1 
PROCEDURE P-Mostra-Dados :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
def input parameter par-acao as char.
do with frame {&Frame-Name}:

        {&OPEN-QUERY-browse-tt-linha}   
        find first tt-linha no-lock.
        apply "Home" to browse-tt-linha.


end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE P-Reposiciona WINDOW-1 
PROCEDURE P-Reposiciona :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
def input parameter p-clfcod-achado as int.
def input parameter p-procura-outro as log.

def var sresp as l format "Sim/Nao".

/*
do with frame {&FRAME-NAME}.

find tt-linha where 
        tt-linha.clfcod = p-clfcod-achado no-lock.

find first tt-linha where
        tt-linha.clfcod = tt-linha.clfcod
    no-lock no-error.

if radio-set-tt-linha = "Todo"
then do:
    reposition browse-tt-linha to recid recid(tt-linha).
    apply "entry" TO browse-tt-linha IN FRAME {&FRAME-NAME}.  
end.
else
    if avail tt-linha
    then do:
        reposition browse-tt-linha to recid recid(tt-linha).
        apply "entry" TO browse-tt-linha IN FRAME {&FRAME-NAME}.  
    end.
    else do:
        if not p-procura-outro    
        then do:
            Run P-Mostra-Dados ("Todos").
            return.
        end.
        sresp = yes.
        message "tt-linha Nao Encontrado Nesta Selecao!!!                "
                "Deseja que Sistema Procure Na Opcao Todos tt-linha?"
                view-as Alert-Box buttons Yes-No
                update sresp.  
        if not sresp
        then do:
            Run P-Mostra-Dados ("Todos").
        end.
        else do:
            assign        
                radio-set-tt-linha = "Todo".
            disp radio-set-tt-linha.
            Btn-PedOrcamos:Label = "Faturados".
            run p-monta-query.
            run P-Controla-Habilitacao (radio-set-tt-linha).
            Run P-Mostra-Dados ("Todos").
            run p-procura.
        end.
    end.
end.
*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



