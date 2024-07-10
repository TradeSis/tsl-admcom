def input param senha as char.
def output param pok   as log.

DEF VAR senha_cri AS RAW. 

def var vhostname as char.
input through hostname.
import vhostname.
input close.

if vhostname = "SV-CA-DB-DEV" or vhostname = "SV-CA-DB-QA"
then ASSIGN senha_cri = ENCRYPT("edpro21" ,GENERATE-PBE-KEY("Sustentacao Lebes")). 
else ASSIGN senha_cri = ENCRYPT("proprd21",GENERATE-PBE-KEY("Sustentacao Lebes")). 

pok = senha = STRING(DECRYPT(senha_cri,GENERATE-PBE-KEY("Sustentacao Lebes")))
