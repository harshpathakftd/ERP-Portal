from django.shortcuts import render
from .models import Order


def order_list(request):

    orders=Order.objects.all()

    return render(request,"sales/order_list.html",{

        "orders":orders

    })