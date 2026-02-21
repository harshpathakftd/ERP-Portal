from django.urls import path
from .views import dashboard,company_list

urlpatterns=[

path('dashboard/',dashboard,name="dashboard"),
path('companies/',company_list,name="company_list"),

]