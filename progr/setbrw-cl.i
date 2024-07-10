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


DEF {1} {2} VAR i-seeid  AS int NO-UNDO.
DEF         VAR i-seerec AS INT EXTENT 20 NO-UNDO.
DEF         VAR i-seekey AS CHAR.
DEF         VAR i-seelst AS CHAR.
def         var i-recid  as recid initial -1  no-undo.

def {1} {2} var a-seeid as int no-undo.
def         var a-seerec as int extent 40 no-undo.
def         var a-seekey as char.
def         var a-seelst as char.
def         var a-recid  as recid initial -1 no-undo.


def {1} {2} var b-seeid as int no-undo.
def         var b-seerec as int extent 40 no-undo.
def         var b-seekey as char.
def         var b-seelst as char.
def         var b-recid  as recid initial -1 no-undo.

ASSIGN
    i-seeid = -1
    a-seeid = -1
    b-seeid = -1.
 