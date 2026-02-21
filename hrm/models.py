from django.db import models
from accounts.models import User
from core.models import Branch


class Department(models.Model):

    name=models.CharField(max_length=100)

    def __str__(self):
        return self.name


class Employee(models.Model):

    user=models.OneToOneField(User,on_delete=models.CASCADE)

    department=models.ForeignKey(Department,on_delete=models.SET_NULL,null=True)

    branch=models.ForeignKey(Branch,on_delete=models.CASCADE)

    salary=models.DecimalField(max_digits=10,decimal_places=2)

    joining_date=models.DateField()

    def __str__(self):
        return self.user.username