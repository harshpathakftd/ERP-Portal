from django.db import models
from sales.models import Order


class Invoice(models.Model):

    order = models.ForeignKey(Order, on_delete=models.CASCADE)

    invoice_number = models.CharField(max_length=100)

    amount = models.DecimalField(max_digits=10, decimal_places=2)

    status = models.CharField(max_length=50, choices=[

        ('PAID', 'Paid'),
        ('PENDING', 'Pending'),

    ])

    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.invoice_number