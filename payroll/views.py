from django.shortcuts import render
from .models import Payroll


def payroll_list(request):

    payrolls = Payroll.objects.select_related('employee', 'employee__user')

    return render(request, "payroll/payroll_list.html", {

        "payrolls": payrolls

    })