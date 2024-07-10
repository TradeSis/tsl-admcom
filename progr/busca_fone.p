{admcab.i}

def input  parameter vforcod like germatriz.forne.forcod.
def output parameter vfornom like germatriz.forne.fornom.
def output parameter vfone   like germatriz.forne.forfone.

find germatriz.forne where germatriz.forne.forcod = vforcod no-lock no-error.
if avail germatriz.forne
then assign vfornom = germatriz.forne.fornom
            vfone   = germatriz.forne.forfone.
            
