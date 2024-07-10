def input parameter recpro as recid.
def input parameter vcodfis like clafis.codfis.

find produ where recid(produ) = recpro no-error.
produ.codfis = vcodfis.
 
