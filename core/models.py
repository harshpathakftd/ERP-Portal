from django.db import models


class Company(models.Model):

    name=models.CharField(max_length=200)
    email=models.EmailField()
    phone=models.CharField(max_length=20)
    address=models.TextField()

    def __str__(self):
        return self.name


class Branch(models.Model):

    company=models.ForeignKey(Company,on_delete=models.CASCADE)
    name=models.CharField(max_length=200)
    city=models.CharField(max_length=100)

    def __str__(self):
        return self.name