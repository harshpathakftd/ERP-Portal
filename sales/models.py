from django.db import models
from inventory.models import Product


class Customer(models.Model):

    name=models.CharField(max_length=200)
    phone=models.CharField(max_length=20)

    def __str__(self):
        return self.name


class Order(models.Model):

    customer=models.ForeignKey(Customer,on_delete=models.CASCADE)
    total=models.DecimalField(max_digits=10,decimal_places=2)
    date=models.DateTimeField(auto_now_add=True)


class OrderItem(models.Model):

    order=models.ForeignKey(Order,on_delete=models.CASCADE)
    product=models.ForeignKey(Product,on_delete=models.CASCADE)
    quantity=models.IntegerField()