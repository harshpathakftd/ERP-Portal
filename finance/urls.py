from django.urls import path
from .views import invoice_list


urlpatterns = [

    path('invoices/', invoice_list, name="invoice_list"),

]