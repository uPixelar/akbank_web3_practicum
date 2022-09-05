#coded by uPixelar | Omer C.

from random import choice, randint
from permits import AutoHGSAccount, MinibusHGSAccount, BusHGSAccount
from tollbooth import Management, TollBooth
from datetime import date

management = Management()#yönetim nesnesi

onbestemmuz = TollBooth(management)#15 Temmuz Şehitler köprüsü
fsm = TollBooth(management)#Fatih Sultan Mehmet köprüsü

for i in range(50):#Gişelerden geçen rasgele 50 araç
    vehicle = choice([AutoHGSAccount, MinibusHGSAccount, BusHGSAccount])()#rastgele bir araç
    vehicle.addBalance(randint(8, 50))#8 ile 50 tl arasında rastgele bir bakiye
    choice([onbestemmuz, fsm]).transaction(vehicle)#rasgele gişeden geçen araç

management.dailyReport(date.today())#yönetim raporu(tüm gişeler)

print("\n15 Temmuz Şehitler köprüsü raporu")
onbestemmuz.dailyReport()#gişeye özel rapor

print("\nFatih Sultan Mehmet köprüsü raporu")
fsm.dailyReport()#gişeye özel rapor