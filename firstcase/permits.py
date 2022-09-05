from random import choices

accountDatabase = {}#oluşturulan hesapları tutan dict(database)

def generateAccountNumber():#rastgele özgün hesap kodu oluşturan fonksiyon
    charset = "abcdef1234567890"
    accountNumber = "".join(choices(charset, k=8))

    if accountDatabase.get(accountNumber) is not None:
        accountNumber = generateAccountNumber()

    return accountNumber

class Person:#isim soyisimleri tutacak structure
    def __init__(self, name, surname):
        self.name = name
        self.surname = surname

class HGSAccount:
    def __init__(self, name=None, surname=None):
        self.no = generateAccountNumber()
        self.balance = 0.0
        self.owner = Person(name, surname)
        self.typeId = 0
        self.typeName = "geçersiz"

    def editOwner(self, name, surname):
        self.owner.edit(name, surname)

    def pay(self, amount):
        newBalance = self.balance-amount
        if newBalance < 0.0: return False
        else: self.balance = newBalance
        return True

    def getType(self):
        return f"{self.typeId}. Sınıf: {self.typeName}"

    def addBalance(self, amount):
        self.balance += amount

class AutoHGSAccount(HGSAccount):
    def __init__(self, name=None, surname=None):
        super().__init__(name, surname)
        self.typeId = 1
        self.typeName = "otomobil"


class MinibusHGSAccount(HGSAccount):
    def __init__(self, name=None, surname=None):
        super().__init__(name, surname)
        self.typeId = 2
        self.typeName = "minibüs"

class BusHGSAccount(HGSAccount):
    def __init__(self, name=None, surname=None):
        super().__init__(name, surname)
        self.typeId = 3
        self.typeName = "otobüs"