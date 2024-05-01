import xata
from xata import XataClient

xata = XataClient()

resp = xata.data().query("equipment_types")
print(resp)