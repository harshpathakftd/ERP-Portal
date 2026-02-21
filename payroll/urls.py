from django.urls import path
from .views import payroll_list


urlpatterns = [

    path('payrolls/', payroll_list, name="payroll_list"),

]