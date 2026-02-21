from django.shortcuts import render
from .models import Invoice


def invoice_list(request):

    invoices = Invoice.objects.all()

    return render(request, "finance/invoice_list.html", {
        "invoices": invoices
    })