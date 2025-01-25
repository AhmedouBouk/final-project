from django.urls import path
from . import views
from django.contrib.auth import views as auth_views

urlpatterns = [
    path('', views.home, name='home'),  # Page d'accueil
    path('home', views.select_department, name='department_select'),
    path('<str:department_code>/semesters/', views.select_semester, name='semester_select'),
    path('<str:department_code>/<str:semester_code>/schedule/', views.view_schedule, name='schedule'),
    path('<str:department_code>/<str:semester_code>/plan/', views.view_plan, name='plan'),
    path('<str:department_code>/<str:semester_code>/database/', views.CourseListView.as_view(), name='database'),
    path('<str:department_code>/<str:semester_code>/bilan/', views.view_bilan, name='bilan'),
    
    # API endpoints
    path('api/<str:department_code>/<str:semester_code>/courses/', views.get_courses, name='get_courses'),
    path('api/<str:department_code>/<str:semester_code>/course/<str:code>/', views.get_course_info, name='get_course_info'),
    path('api/<str:department_code>/<str:semester_code>/professors/', views.get_professors, name='get_professors'),
    path('api/<str:department_code>/<str:semester_code>/rooms/', views.get_rooms, name='get_rooms'),
    path('api/<str:department_code>/<str:semester_code>/schedule/<int:week>/', views.get_schedule, name='get_schedule'),
    path('api/<str:department_code>/<str:semester_code>/plan/all/', views.get_all_plan, name='get_all_plan'),
    path('api/<str:department_code>/<str:semester_code>/plan/<int:week>/', views.get_plan, name='get_plan'),
    
    # CRUD operations
    path('api/<str:department_code>/<str:semester_code>/save_slot/', views.save_slot, name='save_slot'),
    path('api/<str:department_code>/<str:semester_code>/delete_slot/', views.delete_slot, name='delete_slot'),
    path('api/<str:department_code>/<str:semester_code>/add_course/', views.add_course, name='add_course'),
    path('api/<str:department_code>/<str:semester_code>/update_course/', views.update_course, name='update_course'),
    path('api/<str:department_code>/<str:semester_code>/delete_course/', views.delete_course, name='delete_course'),
    path('api/<str:department_code>/<str:semester_code>/update_bilan/', views.update_bilan, name='update_bilan'),
    path('login/', views.CustomLoginView.as_view(), name='login'),  # Utilisez la vue personnalisée
    path('logout/', auth_views.LogoutView.as_view(), name='logout'),
    path('select_department/', views.select_department, name='select_department'),  # Sélection du département
    path('department/<str:department_code>/', views.department_dashboard, name='department_dashboard'),  
]
