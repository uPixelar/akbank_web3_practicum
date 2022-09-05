from datetime import date, datetime

def getDayKey():#bugünün tarihini "yyyy-aa-gg" formatında dönen fonksiyon
    return str(date.today())

class Management:#Yönetim classı
    def __init__(self):
        self.__booths = []#Yönetime ait gişelerin tutulduğu dizi

    def addBooth(self, booth):#Yeni gişe ekleme fonksiyonu
        self.__booths.append(booth)

    def getDailyData(self, day):#istenen gün için geliri dönen fonksiyon
        revenue = 0.0
        failed = 0
        total = 0
        types = {}
        for booth in self.__booths:
            (_revenue, _total, _failed, _types) = booth.getDailyData(day)
            revenue += _revenue
            total += _total
            failed += _failed

            for k,v in _types.items():
                current = types.get(k, 0)
                types[k] = current+v

        return revenue, total, failed, types
        

    def dailyReport(self, day=getDayKey()):
        if not isinstance(day, str):
            day = str(day)
        
        revenue, total, failed, types = self.getDailyData(day)
        succeed = total-failed

        typestext = ""
        for k,v in types.items():
            typestext += f"{v} {k} "
        print(
            f"Tüm Gişeler {day} raporu\n"
            f"Toplam {total} geçiş: {succeed} başarılı | {failed} başarısız\n"
            f"Toplam gelir: {revenue} TL\n"
            f"{typestext}"
        )
    

class Transaction:#Araç geçiş bilgilerinin daha iyi kaydedilebilmesini sağlayan structure
    def __init__(self, account, price, succeed):
        self.account = account
        self.price = price
        self.succeed = succeed
        self.datetime = datetime.now()

class TollBooth:#Gişe classı
    def __init__(self, management:Management):
        self.__prices = {#default ücretler
            1: 8.25,
            2: 10.75,
            3: 23.25
        }
        self.transactions = {}#her gün için geçişleri tutan dict
        self.management = management#bu projede kullanılmıyor ancak tutulabilir
        self.management.addBooth(self)

    def setPrices(self, prices):#ücretleri değiştirmeye yarayan fonksiyon
        self.__prices = prices

    def transaction(self, account):#bir geçiş işlemi
        paid = False
        valid = False

        price = self.__prices.get(account.typeId)
        if price is not None:
            valid = True
            if account.pay(price):
                paid = True

        self.transactionMade(account, price, paid, valid)

    def transactionMade(self, account, price, paid, valid):
        transaction = Transaction(account, price, paid and valid)

        today = getDayKey()
        dailyTransactions = self.transactions.get(today)

        if dailyTransactions is None:
            dailyTransactions = []
            self.transactions[today] = dailyTransactions

        dailyTransactions.append(transaction)

        if not valid: 
            print("Geçersiz hesap\n")
            return

        if not paid:
            print("Yetersiz bakiye\n")
            return

        print(
            "GEÇİŞ\n"
            f"{account.getType()}\n"
            f"{price} TL\n"
        )
            

    def getDailyData(self, day):
        dailyTransactions = self.transactions.get(day, [])
        failed = 0#başarısız geçişler
        total = 0#toplam geçiş
        types = {}#toplam araç türleri

        revenue = 0.0
        for transaction in dailyTransactions:
            if transaction.succeed:
                revenue += transaction.price
            else:
                failed+=1
            total+=1
            typeName = transaction.account.typeName
            current = types.get(typeName, 0)
            types[typeName] = current+1
        
        return revenue, total, failed, types

    def dailyReport(self, day=getDayKey()):
        if not isinstance(day, str):
            day = str(day)
        
        revenue, total, failed, types = self.getDailyData(day)
        succeed = total-failed

        typestext = ""
        for k,v in types.items():
            typestext += f"{v} {k} "
        print(
            f"{day} raporu\n"
            f"Toplam {total} geçiş: {succeed} başarılı | {failed} başarısız\n"
            f"Toplam gelir: {revenue} TL\n"
            f"{typestext}"
        )
