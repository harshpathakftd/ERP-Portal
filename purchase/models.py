from django.db import models
from inventory.models import Product
from core.models import Company


class Supplier(models.Model):

    name = models.CharField(max_length=200)

    email = models.EmailField()

    phone = models.CharField(max_length=20)

    address = models.TextField()

    company = models.ForeignKey(Company, on_delete=models.CASCADE)

    def __str__(self):
        return self.name


class Purchase(models.Model):

    supplier = models.ForeignKey(Supplier, on_delete=models.CASCADE)

    date = models.DateTimeField(auto_now_add=True)

    total = models.DecimalField(max_digits=10, decimal_places=2)

    def __str__(self):
        return f"Purchase {self.id}"


class PurchaseItem(models.Model):

    purchase = models.ForeignKey(Purchase, on_delete=models.CASCADE)

    product = models.ForeignKey(Product, on_delete=models.CASCADE)

    quantity = models.IntegerField()

    price = models.DecimalField(max_digits=10, decimal_places=2)

    def __str__(self):
        return self.product.name