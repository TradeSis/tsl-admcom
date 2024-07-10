/****************************************************************************
****************************************************************************
** Program: s-setbrw.i
** Created: 6/21/89
**   Descr: Set-up for s-browse.i variables.
**
****************************************************************************
\****************************************************************************/

/* Copyright (c) by Progress Software 1988,1989
- All Rights Reserved -                                */


DEF {1} {2} VAR an-seeid  AS INT NO-UNDO.
DEF         VAR an-seerec AS INT EXTENT 20 NO-UNDO.
DEF         VAR an-seekey AS CHAR.
DEF         VAR an-seelst AS CHAR.
def         var an-recid  as int initial -1  no-undo.

 