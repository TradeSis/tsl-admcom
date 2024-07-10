find first fin.tabjur where fin.tabjur.etbcod = {1} no-lock no-error.
if avail fin.tabjur
then find fin.tabjur where fin.tabjur.etbcod = {1} and
                  fin.tabjur.nrdias = {2} no-lock no-error.
else find fin.tabjur where fin.tabjur.etbcod = 0 and
                  fin.tabjur.nrdias = {2} no-lock no-error.
