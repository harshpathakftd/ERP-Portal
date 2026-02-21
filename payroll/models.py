from django.db import models
from hrm.models import Employee


class Payroll(models.Model):

    employee = models.ForeignKey(Employee, on_delete=models.CASCADE)

    basic_salary = models.DecimalField(max_digits=10, decimal_places=2)

    bonus = models.DecimalField(max_digits=10, decimal_places=2, default=0)

    deduction = models.DecimalField(max_digits=10, decimal_places=2, default=0)

    net_salary = models.DecimalField(max_digits=10, decimal_places=2)

    pay_date = models.DateField()

    created_at = models.DateTimeField(auto_now_add=True)

    def save(self, *args, **kwargs):

        # automatic net salary calculation
        self.net_salary = self.basic_salary + self.bonus - self.deduction

        super().save(*args, **kwargs)

    def __str__(self):

        return f"{self.employee.user.username} - {self.pay_date}"