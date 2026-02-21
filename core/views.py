from django.shortcuts import render
from .models import Company


def dashboard(request):

    total_company=Company.objects.count()

    return render(request,"dashboard.html",{

        "total_company":total_company

    })


def company_list(request):

    companies=Company.objects.all()

    return render(request,"core/company_list.html",{

        "companies":companies

    })