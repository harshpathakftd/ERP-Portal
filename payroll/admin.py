from django.contrib import admin
from .models import Payroll


@admin.register(Payroll)
class PayrollAdmin(admin.ModelAdmin):

    list_display = (

        'employee',
        'basic_salary',
        'bonus',
        'deduction',
        'net_salary',
        'pay_date'

    )

    search_fields = ('employee__user__username',)