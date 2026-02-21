from django.shortcuts import render
from .models import Purchase, Supplier


def supplier_list(request):

    suppliers = Supplier.objects.all()

    return render(request, "purchase/supplier_list.html", {
        "suppliers": suppliers
    })


def purchase_list(request):

    purchases = Purchase.objects.all()

    return render(request, "purchase/purchase_list.html", {
        "purchases": purchases
    })