from django.urls import path
from .views import supplier_list, purchase_list


urlpatterns = [

    path('suppliers/', supplier_list, name="supplier_list"),

    path('purchases/', purchase_list, name="purchase_list"),

]